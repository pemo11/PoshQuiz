<#
 .Synopsis
 A simple quiz script - Version 0.2
#>

Import-LocalizedData -FileName PoshQuizMsgTable.psd1 -BindingVariable PoshQuizMsg

. .\PoshQuizHelpersV1.ps1

$QuizPath = ".\Quizzes"

$QuizTable = @{}
$CurrentQuiz = $null

<#
.SYNOPSIS
Loads all quiz defs as Json files in the quizzes subdirectory
#>
function LoadQuiz
{
    [CmdletBinding()]
    param()

    Get-ChildItem -path $QuizPath\*.json | ForEach-Object {
        $Quiz = (Get-Content -Path $_.FullName -Encoding Default ) | ConvertFrom-Json
        $Script:QuizTable.Add($Quiz.QuizId, $Quiz)
    }
    Write-Verbose ($PoshQuizMsg.QuizLoadedMsg -f $QuizTable.Values.Count)
}


function ShowMenu
{
    [CmdletBinding()]
    param()

    Write-Host "1) $($PoshQuizMsg.ShowMenuShowQuizzesMsg)"
    Write-Host "2) $($PoshQuizMsg.ShowMenuStartQuizMsg)"
    Write-Host "Q - $($PoshQuizMsg.ShowMenuEndMsg)"
    $Choice = Read-Host -Prompt "1,2 or Q?"
    $Choice.ToUpper()
}

function ShowQuizTable
{
    [CmdletBinding()]
    param()
    $i = 0
    $QuizTable.Values.ForEach{
        $i++
        $LineOutput = "{0}) {1} - {2}" -f $i, $_.Title, $_.QuizId   
        Write-Host $LineOutput
    }
}

function StartQuiz
{
    [CmdletBinding()]
    param([Object]$Quiz)
    $QuizInitPrompt = "Choose a Quiz by ID (" + ($QuizTable.Keys -join ",") + ")"
    [Int32]$QuizId = Read-Host $QuizInitPrompt
    $Script:CurrentQuiz = $QuizTable[$QuizId]
    Invoke-QuizRun -Quiz $CurrentQuiz
}

LoadQuiz -Verbose

# Start the quiz input loop
do
{
    $ExitMode = $false
    $Choice = ShowMenu
    switch ($Choice)
    {
        "1" {
            ShowQuizTable
            break
        }
        "2" {
            StartQuiz
            break
        }
        "Q" { $ExitMode = $true}
    }
} until ($ExitMode)

# **** finito V1 ****
