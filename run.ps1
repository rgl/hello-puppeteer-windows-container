# NB if you run this under a stateful CI host you should export the
#    COMPOSE_PROJECT_NAME environment variable to differentiate this build
#    from the others. this is needed because docker-compose uses this name
#    as a container/network name prefix (which should be unique within the
#    CI host machine).
#    see .gitlab-ci.yml as an example of a stateful CI host.
#    see .github/workflows/build.yml as an example of a non-stateful CI host.
#    see https://docs.docker.com/compose/reference/envvars/#compose_project_name

Set-StrictMode -Version Latest
$FormatEnumerationLimit = -1
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
trap {
	"ERROR: $_" | Write-Host
	($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1' | Write-Host
	($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
	Exit 1
}

function exec([ScriptBlock]$externalCommand, [string]$stderrPrefix = '', [int[]]$successExitCodes = @(0)) {
	$eap = $ErrorActionPreference
	$ErrorActionPreference = 'Continue'
	try {
		&$externalCommand 2>&1 | ForEach-Object {
			if ($_ -is [System.Management.Automation.ErrorRecord]) {
				"$stderrPrefix$($_.Exception.Message)"
			} else {
				"$_"
			}
		}
		if ($LASTEXITCODE -notin $successExitCodes) {
			throw "$externalCommand failed with exit code $LASTEXITCODE"
		}
	} finally {
		$ErrorActionPreference = $eap
	}
}

function docker {
	$arguments = $Args
	Write-Host "Running docker $($arguments | ConvertTo-Json -Compress)..."
	exec {docker.exe @arguments}
}

# set the labels that will be associated with the container images
# and containers.
# see docker-compose.yml
if ($env:CI_PROJECT_URL) {
	# GitLab CI.
	# see https://docs.gitlab.com/ee/ci/variables/predefined_variables.html
	$env:LABEL_IMAGE_SOURCE = $env:CI_PROJECT_URL
	$env:LABEL_IMAGE_DESCRIPTION = $env:CI_COMMIT_BRANCH
	$env:LABEL_IMAGE_REVISION = $env:CI_COMMIT_SHA
} elseif ($env:GITHUB_REPOSITORY) {
	# GitHub Actions CI.
	# see https://docs.github.com/en/free-pro-team@latest/actions/reference/environment-variables#default-environment-variables
	$env:LABEL_IMAGE_SOURCE = "$env:GITHUB_SERVER_URL/$env:GITHUB_REPOSITORY"
	$env:LABEL_IMAGE_DESCRIPTION = $env:GITHUB_REF
	$env:LABEL_IMAGE_REVISION = $env:GITHUB_SHA
} else {
	$env:LABEL_IMAGE_SOURCE = git config --get remote.origin.url
	$env:LABEL_IMAGE_DESCRIPTION = git rev-parse --abbrev-ref HEAD
	$env:LABEL_IMAGE_REVISION = git rev-parse HEAD
}

# make sure we start from scratch.
docker compose down
if (!(Test-Path tmp)) {
	mkdir tmp | Out-Null
	# make sure the container can write to the host directory.
	$acl = Get-Acl tmp
	@(
		'S-1-5-93-2-1' # ContainerAdministrator
		'S-1-5-93-2-2' # ContainerUser
	) | ForEach-Object {
		$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
			(New-Object System.Security.Principal.SecurityIdentifier($_)),
			'FullControl',
			'ContainerInherit,ObjectInherit',
			'None',
			'Allow')))
	}
	Set-Acl tmp $acl
}
rm tmp/*

# run the tests. then destroy everything.
try {
	docker compose build
	docker compose run -T tests
} finally {
	docker compose down
}
