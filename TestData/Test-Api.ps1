if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "This script requires PowerShell 7.0 or higher" -ForegroundColor Red
    return
}

# Simple powershell script to test the API
$Port = 7257
$BaseUrl = "http://localhost:$Port"

# Get the Log file count from disk
$LogFiles = Get-ChildItem -Path "$($PSScriptRoot)/Logs" -Filter "*.log" -Recurse

# Get the logs
$Logs = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs" -SkipCertificateCheck -ContentType "application/json"

if ($Logs.Count -eq $LogFiles.Count) {
    Write-Host "/api/Logs: Count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs: Count test failed: expected $($LogFiles.Count) but got $($Logs.Count)" -ForegroundColor Red
}

$LogName = "PAM-Proxy-20220922.log"
$Id = $Logs | Where-Object { $_.Name -eq $LogName } | Select-Object -ExpandProperty Id

$LineCount = (Get-Content "$PSScriptRoot/Logs/$($LogName)").Count
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/$Id" -SkipCertificateCheck -ContentType "application/json"

if ($LogMessage.Count -eq $LineCount) {
    Write-Host "/api/Log/$($Id): LogMessage count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Log/$($Id): LogMessage count count test failed: expected $LineCount but got $($LogMessage.Count)" -ForegroundColor Red
}

if ($LogMessage[0].Date.Kind -ne "Utc") {
    Write-Host "/api/Log/$($Id): LogMessage date kind test failed: expected Utc got $($LogMessage[0].Date.Kind)" -ForegroundColor Red
}
else {
    Write-Host "/api/Log/$($Id): LogMessage date kind test passed" -ForegroundColor Green
}

if ($LogMessage[0].Date.Hour -eq 22) {
    Write-Host "/api/Log/$($Id): LogMessage date hour test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Log/$($Id): LogMessage date hour test failed: expected 10 got $($LogMessage[0].Date.Hour)" -ForegroundColor Red
}

$LastMessage = $LogMessage | Select-Object -Last 1
if ($LastMessage.LineNumber -eq 38) {
    Write-Host "/api/Log/$($Id): Last LogMessage linenumber test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Log/$($Id): Last LogMessage linenumber test failed: expected 1 got $($LastMessage.LineNumber)" -ForegroundColor Red
}

if ($LogMessage[0].LineNumber -eq 1) {
    Write-Host "/api/Log/$($Id): First LogMessage linenumber test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Log/$($Id): First LogMessage linenumber test failed: expected 1 got $($LogMessage[0].LineNumber)" -ForegroundColor Red
}

## Get log file with specific name
$LogName = "PAM-Proxy-20220922.log"
$Log = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs?name=$LogName" -SkipCertificateCheck -ContentType "application/json"
if ($Log.Name -eq $LogName) {
    Write-Host "/api/Logs?name=$($LogName): name test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($LogName): name test failed: expected $LogName got $($Log.Name)" -ForegroundColor Red
}

if ($Log.Count -eq 1) {
    Write-Host "/api/Logs?name=$($LogName): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($LogName): count test failed: expected 1 got $($Log.Count)" -ForegroundColor Red
}

## Get log file with partial name
$Partial = "PAM-Proxy-20220922"
$Log = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs?name=$Partial" -SkipCertificateCheck -ContentType "application/json"
if ($Log.Name -eq $LogName) {
    Write-Host "/api/Logs?name=$($Partial): name test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($Partial): name test failed: expected $LogName got $($Log.Name)" -ForegroundColor Red
}

if ($Log.Count -eq 1) {
    Write-Host "/api/Logs?name=$($Partial): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($Partial): count test failed: expected 1 got $($Log.Count)" -ForegroundColor Red
}

## Get log files using multiple names
$LogName = "PAM-Proxy-20220922.log"
$LogName2 = "PAM-Proxy-20221025.log"

$Log = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs?name=$($LogName)&name=$LogName2" -SkipCertificateCheck -ContentType "application/json"
if ($Log.Count -eq 2) {
    Write-Host "/api/Logs?name=$($LogName)&name=$($LogName2): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($LogName)&name=$($LogName2): count test failed: expected 2 got $($Log.Count)" -ForegroundColor Red
}

if ($Log[0].Name -eq $LogName) {
    Write-Host "/api/Logs?name=$($LogName)&name=$($LogName2): Found $LogName test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($LogName)&name=$($LogName2): Found $LogName test failed: expected $LogName got $($Log[0].Name)" -ForegroundColor Red
}

if ($Log[1].Name -eq $LogName2) {
    Write-Host "/api/Logs?name=$($LogName)&name=$($LogName2): Found $LogName2 test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($LogName)&name=$($LogName2): Found $LogName2 test failed: expected $LogName2 got $($Log[1].Name)" -ForegroundColor Red
}

## Get log files using multiple partial names
$Partial = "PAM-Proxy-20220922"
$Partial2 = "PAM-Proxy-20221025"
$Log = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs?name=$($Partial)&name=$Partial2" -SkipCertificateCheck -ContentType "application/json"
if ($Log.Count -eq 2) {
    Write-Host "/api/Logs?name=$($Partial)&name=$($Partial2): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($Partial)&name=$($Partial2): count test failed: expected 2 got $($Log.Count)" -ForegroundColor Red
}

if ($Log[0].Name -eq $LogName) {
    Write-Host "/api/Logs?name=$($Partial)&name=$($Partial2): Found $LogName test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($Partial)&name=$($Partial2): name test failed: expected $LogName got $($Log[0].Name)" -ForegroundColor Red
}

if ($Log[1].Name -eq $LogName2) {
    Write-Host "/api/Logs?name=$($Partial)&name=$($Partial2): Found $LogName2 test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs?name=$($Partial)&name=$($Partial2): name test failed: expected $LogName2 got $($Log[1].Name)" -ForegroundColor Red
}

## Get log messages using search
$Search = "test42"
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?filterText=$Search" -SkipCertificateCheck -ContentType "application/json"
if ($LogMessage.Count -eq 2) {
    Write-Host "/api/Logs/Search?filterText=$($Search): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?filterText=$($Search): count test failed: expected 2 got $($LogMessage.Count)" -ForegroundColor Red
}

## Get log messages using multiple search filterText params
$Search = "test42"
$Search2 = "a1152c45"
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?filterText=$Search&filterText=$Search2" -SkipCertificateCheck -ContentType "application/json"
if ($LogMessage.Count -eq 1) {
    Write-Host "/api/Logs/Search?filterText=$($Search)&filterText=$($Search2): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?filterText=$($Search)&filterText=$($Search2): count test failed: expected 4 got $($LogMessage.Count)" -ForegroundColor Red
}

## Get log messages using search and logId
$Search = "test42"
$LogId = "PAM-Proxy-20220922.log"
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?filterText=$Search&LogId=$LogId" -SkipCertificateCheck -ContentType "application/json"
if ($LogMessage.Count -eq 1) {
    Write-Host "/api/Logs/Search?filterText=$($Search)&LogId=$($LogId): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?filterText=$($Search)&LogId=$($LogId): count test failed: expected 1 got $($LogMessage.Count)" -ForegroundColor Red
}
if ($LogMessage.LogId -eq $LogId) {
    Write-Host "/api/Logs/Search?filterText=$($Search)&LogId=$($LogId): logId test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?filterText=$($Search)&LogId=$($LogId): logId test failed: expected $LogId got $($LogMessage.LogId)" -ForegroundColor Red
}

## Get log messages using search and loglevel 
$LogLevel = "Critical"
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?level=$LogLevel" -SkipCertificateCheck -ContentType "application/json"
if ($LogMessage.Count -eq 1) {
    Write-Host "/api/Logs/Search?level=$($LogLevel): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?level=$($LogLevel): count test failed: expected 1 got $($LogMessage.Count)" -ForegroundColor Red
}
if ($LogMessage[0].Level -eq $LogLevel -or $LogMessage[0].Level -eq 5) {
    Write-Host "/api/Logs/Search?level=$($LogLevel): logLevel test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?level=$($LogLevel): logLevel test failed: expected $LogLevel got $($LogMessage[0].Level)" -ForegroundColor Red
}

## Now get the log messages using one searchTerm and two logIds and one logLevel
$Search = "test42"
$LogId = "PAM-Proxy-20220922.log"
$LogId2 = "PAM-Proxy-20221028.log"
$LogLevel = "Information"

$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?filterText=$Search&LogId=$LogId&LogId=$LogId2&level=$LogLevel" -SkipCertificateCheck -ContentType "application/json"
if ($LogMessage.Count -eq 1) {
    Write-Host "/api/Logs/Search?filterText=$($Search)&LogId=$($LogId)&LogId=$($LogId2)&level=$($LogLevel): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?filterText=$($Search)&LogId=$($LogId)&LogId=$($LogId2)&level=$($LogLevel): count test failed: expected 1 got $($LogMessage.Count)" -ForegroundColor Red
}

## Search for a log message that does not exist
$Search = "test+for+thing+that+does+not+exist"
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?filterText=$Search" -SkipCertificateCheck -ContentType "application/json"

if ($LogMessage.Count -eq 0) {
    Write-Host "/api/Logs/Search?filterText=$($Search): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?filterText=$($Search): count test failed: expected 0 got $($LogMessage.Count)" -ForegroundColor Red
}

## Test for text on a continuation line
$Search = "System.InvalidOperationException:"
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?filterText=$Search" -SkipCertificateCheck -ContentType "application/json"
if ($LogMessage.Count -eq 70) {
    Write-Host "/api/Logs/Search?filterText=$($Search): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?filterText=$($Search): count test failed: expected 1 got $($LogMessage.Count)" -ForegroundColor Red
}

## Search between dates
$StartDate = "2022-09-27T00:00:00Z"
$EndDate = "2022-09-27T23:59:59Z"
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?startDate=$StartDate&endDate=$EndDate" -SkipCertificateCheck -ContentType "application/json"

if ($LogMessage.Count -eq 57468) {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate): count test failed: expected 1 got $($LogMessage.Count)" -ForegroundColor Red
}

## Search between dates and logId
$StartDate = "2022-09-27T00:00:00Z"
$EndDate = "2022-09-27T23:59:59Z"
$LogId = "PAM-ActionServiceWorker20220927.log"
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?startDate=$StartDate&endDate=$EndDate&LogId=$LogId" -SkipCertificateCheck -ContentType "application/json"

if ($LogMessage.Count -eq 57468) {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate)&LogId=$($LogId): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate)&LogId=$($LogId): count test failed: expected 1 got $($LogMessage.Count)" -ForegroundColor Red
}

## Search between dates and logId and logLevel
$StartDate = "2022-09-27T00:00:00Z"
$EndDate = "2022-09-27T23:59:59Z"
$LogId = "PAM-ActionServiceWorker20220927.log"
$LogLevel = "Error"

$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?startDate=$StartDate&endDate=$EndDate&LogId=$LogId&level=$LogLevel" -SkipCertificateCheck -ContentType "application/json"
if ($LogMessage.Count -eq 30) {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate)&LogId=$($LogId)&level=$($LogLevel): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate)&LogId=$($LogId)&level=$($LogLevel): count test failed: expected 1 got $($LogMessage.Count)" -ForegroundColor Red
}

## Search between dates and logId and logLevel and searchTerm
$StartDate = "2022-09-27T00:00:00Z"
$EndDate = "2022-09-27T23:59:59Z"
$LogId = "PAM-ActionServiceWorker20220927.log"
$LogLevel = "Error"
$Search = "PowerShellExecutionManager"

$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?startDate=$StartDate&endDate=$EndDate&LogId=$LogId&level=$LogLevel&filterText=$Search" -SkipCertificateCheck -ContentType "application/json"
if ($LogMessage.Count -eq 5) {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate)&LogId=$($LogId)&level=$($LogLevel)&filterText=$($Search): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate)&LogId=$($LogId)&level=$($LogLevel)&filterText=$($Search): count test failed: expected 1 got $($LogMessage.Count)" -ForegroundColor Red
}

## Search for a specific line using the date
#2022-09-27 08:42:39.985 
$StartDate = "2022-09-27T12:42:39Z"
$EndDate = "2022-09-27T12:42:39Z"
$LogMessage = Invoke-RestMethod -Method Get -Uri "$($BaseUrl)/api/Logs/Search?startDate=$StartDate&endDate=$EndDate" -SkipCertificateCheck -ContentType "application/json"
if ($LogMessage.Count -eq 5) {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate): count test passed" -ForegroundColor Green
}
else {
    Write-Host "/api/Logs/Search?startDate=$StartDate&endDate=$($EndDate): count test failed: expected 1 got $($LogMessage.Count)" -ForegroundColor Red
}
