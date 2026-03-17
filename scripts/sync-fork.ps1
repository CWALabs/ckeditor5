# Keeps SkyCMS fork branches in sync with upstream.
#
# Branch roles:
# - master: upstream-tracking baseline branch.
# - skycms/main: SkyCMS customization branch.
#
# Workflow:
# 1) Sync master with upstream/master.
# 2) Merge upstream/master into skycms/main.
#
# Documentation:
# - README fork workflow: ./README.md#fork-maintenance-skycms
#
# Usage: pwsh ./scripts/sync-fork.ps1

$ErrorActionPreference = 'Stop'

function Invoke-Git {
	param(
		[Parameter(Mandatory = $true)]
		[string[]]$Args
	)

	Write-Host "> git $($Args -join ' ')" -ForegroundColor Cyan
	& git @Args
	if ($LASTEXITCODE -ne 0) {
		throw "Git command failed: git $($Args -join ' ')"
	}
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Push-Location $repoRoot

try {
	$status = git status --porcelain
	if ($status) {
		throw 'Working tree is not clean. Commit/stash your changes before running this script.'
	}

	Write-Host 'Syncing master with upstream/master...' -ForegroundColor Yellow
	Invoke-Git -Args @('checkout', 'master')
	Invoke-Git -Args @('fetch', 'upstream')
	Invoke-Git -Args @('merge', 'upstream/master')
	Invoke-Git -Args @('push', 'origin', 'master')

	Write-Host 'Syncing skycms/main with upstream/master...' -ForegroundColor Yellow
	Invoke-Git -Args @('checkout', 'skycms/main')
	Invoke-Git -Args @('merge', 'upstream/master')
	# If you prefer rebase here, replace the previous line with:
	# Invoke-Git -Args @('rebase', 'upstream/master')
	Invoke-Git -Args @('push', 'origin', 'skycms/main')

	Write-Host 'Sync complete.' -ForegroundColor Green
}
finally {
	Pop-Location
}
