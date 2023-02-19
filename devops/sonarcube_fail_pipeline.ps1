$SonarToken = ${env:SONAR-TOKEN}
$SonarServerName ="3.127.44.243:9000"
$SonarProjectKey ="org.owasp.webgoat:webgoat-parent"
$Token = [System.Text.Encoding]::UTF8.GetBytes($SonarToken + ":")
$TokenInBase64 = [System.Convert]::ToBase64String($Token)
$basicAuth = [string]::Format("Basic {0}", $TokenInBase64)
$Headers = @{ Authorization = $basicAuth }
$QualityGateResult = Invoke-RestMethod -Method Get -Uri http://$SonarServerName/api/measures/component?component=$SonarProjectKey"&"metricKeys=bugs","vulnerabilities","code_smells -Headers $Headers

$QualityGateResult | ConvertTo-Json
foreach ($item in $QualityGateResult.component.measures){
    $value = [int]$item.value
    $metric = $item.metric
    switch ($metric) {
        "bugs" {
            if ($value -gt [int]${env:MAX-BUGS-ALLOWED}) {
                Write-Host "Exceeded maximum allowed bugs from SonarQube report"
                Write-Host "##vso[task.complete result=Failed;]DONE"
            }
        }
        "vulnerabilities" {
            if ($value -gt [int]${env:MAX-VULNERABILITIES-ALLOWED}) {
                Write-Host "Exceeded maximum allowed vulnerabilities from SonarQube report"
                Write-Host "##vso[task.complete result=Failed;]DONE"
            }
        }
        "code_smells" {
            if ($value -gt [int]${env:MAX-CODE-SMELLS-ALLOWED}) {
                Write-Host "Exceeded maximum allowed code_smells from SonarQube report"
                Write-Host "##vso[task.complete result=Failed;]DONE"
            }
        }
    }
}