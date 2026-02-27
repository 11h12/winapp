$tokens = $null
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    'c:\Users\mark\Documents\GitHub\winapp\setup.ps1',
    [ref]$tokens,
    [ref]$errors
)
if ($errors.Count -eq 0) {
    Write-Host "No parse errors" -ForegroundColor Green
} else {
    foreach ($e in $errors) { Write-Host $e.Message -ForegroundColor Red }
}
