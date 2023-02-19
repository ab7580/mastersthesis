$jsonString = Get-Content "./dependency-check-report.json"
$jsonObj = $jsonString | ConvertFrom-Json
$low = 0
$medium = 0
$moderate = 0
$high = 0
$critical = 0
foreach ($dep in $jsonObj.dependencies) {
    foreach ($vul in $dep.vulnerabilities) {
        switch ($vul.severity.ToLower()) {
            "low" {
                $low = $low + 1
            }
            "medium" {
                $medium = $medium + 1
            }
            "moderate" {
                $moderate = $moderate + 1
            }
            "high" {
                $high = $high + 1
            }
            "critical" {
                $critical = $critical + 1
            }
        }
    }
}
if ($low -gt [int]${env:DC-MAX-LOW-ALLOWED}) {
    Write-Host "Exceeded maximum allowed low level risk from Dependency Check report"
    exit 1
}
elseif ($medium -gt [int]${env:DC-MAX-MEDIUM-ALLOWED}) {
    Write-Host "Exceeded maximum allowed medium level risk from Dependency Check report"
    exit 1
} 
elseif ($moderate -gt [int]${env:DC-MAX-MODERATE-ALLOWED}) {
    Write-Host "Exceeded maximum allowed moderate level risk from Dependency Check report"
    exit 1
} 
elseif ($high -gt [int]${env:DC-MAX-HIGH-ALLOWED} ) {
    Write-Host "Exceeded maximum allowed high level risk from Dependency Check report"
    exit 1
} 
elseif ($medium -gt [int]${env:DC-MAX-MEDIUM-ALLOWED}) {
    Write-Host "Exceeded maximum allowed medium level risk from Dependency Check report"
    exit 1
} 
elseif ( $critical -gt [int]${env:DC-MAX-CRITICAL-ALLOWED}) {
    Write-Host "Exceeded maximum allowed critical level risk from Dependency Check report"
    exit 1
}