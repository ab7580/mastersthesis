$ErrorActionPreference='Stop'

Write-Host "Script is started"

$AzureDevopsPAT = "" # insert your api key here
# get it from Azure Devops
# User settings ->
# Personal access tokens ->
# New Token ->
# select "Build (Read & execute)" permissions

if ([string]::IsNullOrEmpty($AzureDevopsPAT)) {
  Write-Host "NOK - AzureDevopsPAT is not defined" -ForegroundColor "red"
  Exit
}

$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

$OrganizationName="ab7580"
$UriOrga = "https://dev.azure.com/$($OrganizationName)/"

$repeats = 10

# instructions
# structure of $projects object is as such:
# 1st level = project. Properties: ProjectName, list of Repos
# 2nd level = repo. Properties: RepoName, Branch, list of Pipelines
# 3rd level = pipeline. Properties: ShouldRun, Id, Name. For the pipeline that you want to deploy, set ShouldRun to 1.

# meaning of properties:
# ProjectName: determine in which project to run
# RepoName, (pipeline)Name: just for clarity and logging (not used by code - pipelines know in which repo they work, so this info does not have to be specified. Pipeline Id is enough)
# Branch: determine on which branch to run pipeline (branch is per repo)
# ShouldRun: determine if pipeline will be run
$projects = @(
  #_____________________________________________________________________________________________________#
  [pscustomobject]@{ProjectName = "WebGoat"; Repos = @(
    [pscustomobject]@{RepoName = "WebGoat-8.0.0.M25.git"; Branch = "master"; Pipelines = @(
      [pscustomobject]@{ShouldRun = 1; Id = 22; Name="test_dependencycheck" }
    ) }
  ) }
)
For ($i=0; $i -lt $projects.Length; $i++) {
    $project = $projects[$i].ProjectName
    $repos = $projects[$i].Repos

    For ($j=0; $j -lt $repos.Length; $j++) {

      $repoName = $repos[$j].RepoName
      $branch = $repos[$j].Branch
      $pipelines = $repos[$j].Pipelines

      $body = "{
        'stagesToSkip': [],
        'resources': {
          'repositories': {
            'self': {
              'refName': 'refs/heads/$($branch)'
            }
          }
        },
        'variables': {}
      }"

      For ($k=0; $k -lt $pipelines.Length; $k++) {
        For ($l=0; $l -lt $repeats; $l++) {
          Write-Host "Run $l"
          if ($pipelines[$k].ShouldRun -eq 0) {
            continue
          }
  
          $id = $pipelines[$k].Id
          $name = $pipelines[$k].Name
      
          $UriGeneral = $UriOrga + "$project/_apis/pipelines/$id/runs?api-version=6.0-preview.1"
  
          $msg = "$name on branch $branch in repo $repoName ($project)"
          try {
              Invoke-RestMethod -Uri $UriGeneral -ContentType 'application/json' -Method "post" -Body $body -Headers $AzureDevOpsAuthenicationHeader | Out-Null
              Write-Host "OK - $msg" -ForegroundColor "green"
          } catch {
              # Dig into the exception to get the Response details.
              # Note that value__ is not a typo.
              Write-Host "NOK - $msg" " StatusCode:" $_.Exception.Response.StatusCode.value__ " StatusDescription:" $_.Exception.Response.StatusDescription -ForegroundColor "red"
          }
        }
      }
    }
}
Write-Host "Script is finished"