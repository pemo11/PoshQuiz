<#
 .Synopsis
 A simple quiz script - Version 0.2
#>

Import-LocalizedData -FileName PoshQuizMsgTable.psd1 -BindingVariable PoshQuizMsg

. .\PoshQuizHelpersV1.ps1

$QuizTable =[Ordered]@{}
$CurrentQuiz = $null

<#
.SYNOPSIS
Loads all quiz defs as Json files in the quizzes subdirectory
#>
function LoadQuiz
{
    [CmdletBinding()]
    param([String]$QuizPath = ".\Quizzes")

    Get-ChildItem -path $QuizPath\*.json | ForEach-Object {
        $Quiz = (Get-Content -Path $_.FullName -Encoding Default ) | ConvertFrom-Json
        # $Script:QuizTable.Add($Quiz.QuizId, $Quiz)
        $Script:QuizTable += @{$Quiz.QuizId = $Quiz}
    }
    Write-Verbose ($PoshQuizMsg.QuizLoadedMsg -f $QuizTable.Values.Count)
}

$MainMenu = @()
$MainMenu += "1 - $($PoshQuizMsg.ShowMenuShowQuizzesMsg)"
$MainMenu += "2 - $($PoshQuizMsg.ShowMenuStartQuizMsg)"
$MainMenu += "Q - $($PoshQuizMsg.ShowMenuEndMsg)"

$QuizEndMenu = @()
$QuizEndMenu += "1 - $($PoshQuizMsg.QuizEndTryAgainMsg)"
$QuizEndMenu += "2 - $($PoshQuizMsg.QuizEndTryWrongAnswersMsg)"
$QuizEndMenu += "Q - $($PoshQuizMsg.ShowMenuEndMsg)"

<#
.Synopsis
Displays a multiple choice menu
#>
function ShowMenu
{
    [CmdletBinding()]
    param([String[]]$MenuItems)

    Foreach($MenuItem in $MenuItems)
    {
        Write-Host $MenuItem
    }
    $ChoicePrompt = ((0..($MenuItems.Count -2)).ForEach{[Char]($_+49)} -join ",") + " or Q?"
    $Choice = Read-Host -Prompt $ChoicePrompt
    $Choice.ToUpper()
}

<#
.Synopsis
Displays all available quizzes
#>
function ShowQuizTable
{
    [CmdletBinding()]
    param()
    $i = 0
    $QuizTable.Values.ForEach{
        $Outline = "{0} - {1}/{2} {3}" -f ++$i, $_.Title, $_.QuizID, $_.Author
        Write-Host $Outline
    }
    Write-Host
}

<#
.Synopsis
Start a quizz
#>
function StartQuiz
{
    [CmdletBinding()]
    param([Object]$Quiz)
    $QuizInitPrompt = "Choose a Quiz by ID (" + ($QuizTable.Keys -join ",") + ")"
    [Int32]$QuizId = Read-Host $QuizInitPrompt
    if ($QuizTable.Keys -contains $QuizId)
    {
        $Script:CurrentQuiz = $QuizTable[$QuizId]
        Invoke-QuizRun -Quiz $CurrentQuiz
        ShowMenu $QuizEndMenu
    }
    else {
        Write-Host -Fore Red $PoshQuizMsg.QuizNotFoundMsg
    }
}

LoadQuiz -Verbose

# Start the quiz input loop
do
{
    $ExitMode = $false
    $Choice = ShowMenu $MainMenu
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
