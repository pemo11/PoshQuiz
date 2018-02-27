<#
.Synopsis
A few helper functions for PoshQuiz V1
#>

Using Module .\PoshQuizClassesV1.psm1

Import-LocalizedData -FileName PoshQuizMsgTable.psd1 -BindingVariable PoshQuizMsg

Set-StrictMode -Version Latest

[Quiz]$CurrentQuiz = $null
[QuizCard]$CurrentCard = $null
$QuizMode = $false
$CardMode = $false
$CorrectCardCount = 0
$WrongCardCount = 0
$SkippedCardCount = 0

<#
.SYNOPSIS
Tests if a quiz is processed
#>
function TestQuizMode
{
    if (!$QuizMode)
    {
        throw "Element only valid for a Quiz"
    }
}

<#
.SYNOPSIS
Tests if a card is processed
#>
function TestCardMode
{
    if (!$CardMode)
    {
        throw "Element only valid for a Quiz card"
    }
}

<#
.SYNOPSIS
Converts a Json definition to a Quiz object
.Notes
Necessary because of later type conversione errors when doing ConvertFrom-JSON
#>
function ConvertTo-PoshQuiz
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true,ParameterSetname="File")][String]$Path,
          [Parameter(Mandatory=$true,ParameterSetname="Text")][String]$JSON)
    if ($Path)
    {
        $JSONObject = Get-Content -Path $Path -Encoding Default | ConvertFrom-Json
    }
    if ($JSON)
    {
        $JSONObject = $JSON | ConvertFrom-Json
    }
    $Quiz = [Quiz]::new()
    $Quiz.Author = $JSONObject.Author
    $Quiz.Category = $JSONObject.Category
    $Quiz.CreationDate = $JSONObject.CreationDate
    $Quiz.Language = $JSONObject.Language
    $Quiz.QuizId = $JSONObject.QuizId
    $Quiz.Title = $JSONObject.Title
    foreach($Card in $JSONObject.Cards)
    {
        $QuizCard = [QuizCard]::new($Card.Options.Count, $Card.Type)
        $QuizCard.AnswerHint = $Card.Hint
        $QuizCard.AnswerId = $Card.AnswerId
        $QuizCard.Level = $Card.Level
        $QuizCard.Question = $Card.Question
        $QuizCard.Options = $Card.Options
        $Quiz.Cards.Add($QuizCard)
    }
    return $Quiz
}

<#
.SYNOPSIS
Converts a quiz description into a quiz object

.DESCRIPTION
Conversion is done based on a text file that describes the quiz contents with a kind of DSL
.PARAMETER Path
Path of the text file
#>
function Read-PoshQuiz
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][String]$Path)
    $QuizDef = Get-Content -Path $Path

    # Parse the quiz def
    for ($i = 0; $i -lt $QuizDef.Count; $i++)
    {
        $CurLine = $QuizDef[$i]
        # match line keyword
        $Regex = "(\w+)::"
        if ($CurLine -match $Regex)
        {
            # try to match a value following the keyword too
            $Regex = "(\w+)::\s*`"*([\w\s?,/-]+)`"*"
            if ($CurLine -match $Regex)
            {
                $KeywordValue = $Matches.2
            }
            $Keyword = $Matches.1
            switch ($Keyword)
            {
                # start a new quiz
                "Quiz" {
                    $QuizMode = $true
                    $CurrentQuiz = [Quiz]::new()
                }

                "QuizEnd" {
                    $QuizMode = $false
                    break
                }

                "ID" {
                    TestQuizMode
                    $CurrentQuiz.QuizId = $KeywordValue
                }

                "Title" {
                    TestQuizMode
                    $CurrentQuiz.Title = $KeywordValue
                }

                "Category" {
                    TestQuizMode
                    $CurrentQuiz.Category = $KeywordValue
                } 

                "Author" {
                    TestQuizMode
                    $CurrentQuiz.Author = $KeywordValue
                }

                "CreationDate" {
                    TestQuizMode
                    $CurrentQuiz.CreationDate = $KeywordValue
                }

                "Card" {
                    TestQuizMode
                    $CurrentCard = [QuizCard]::new()
                    $CardMode = $true
                    $QuizMode = $false
                }

                "CardEnd" {
                    $CurrentQuiz.Cards.Add($CurrentCard)
                    $CardMode = $false
                    $QuizMode = $true
                }

                "Question" {
                    TestCardMode
                    $CurrentCard.Question = $KeywordValue
                }

                "Level" {
                    TestCardMode
                    $CurrentCard.Level = $KeywordValue
                }

                "Type" {
                    TestCardMode
                    $CurrentCard.Type = $KeywordValue
                }

                "AnswerID" {
                    TestCardMode
                    $CurrentCard.AnswerId = $KeywordValue
                }

                "Hint" {
                    TestCardMode
                    $CurrentCard.Hint = $KeywordValue
                }

                "Options" {
                    TestCardMode
                    # Get all lines until the next blank line
                    $i++
                    $j = $i
                    while ($QuizDef[$j] -ne "" -and $QuizDef[$j] -notlike "*CardEnd::*")
                    {
                        $CurrentCard.Options += $QuizDef[$j]
                        $j++
                    }
                    # update the current line counter
                    $i = $j - 1
                }
            }
        }
    }
    return $CurrentQuiz 
}

<#
.Synopsis
Shows the content of a quiz card
#>
function Show-QuizCard
{
    # Because of the special JSON type conversion this is a QuizCard object
    param([QuizCard]$Card)
    $OptionsCount = $Card.Options.Count
    Write-Host ([String]::new("=", 80))
    Write-Host $Card.Question
    Write-Host ([String]::new("=", 80))
    for($i = 0; $i -lt $OptionsCount;$i++)
    {
        $Option = $Card.Options[$i]
        $Outline = "$([Char][Byte]($i+65)) - $Option"
        Write-Host $Outline
    }
    Write-Host ([String]::new("=", 80))
    $ExitMode = $false
    do {
        $AnswerPrompt = "Your Answer ($((1..($i-1)).ForEach{[Char][Byte]($_+64)} -join ",") or $([Char][Byte]($i+64))) or ! or ?"
        $Answer = Read-Host $AnswerPrompt
        $Answer = $Answer.ToUpper()
        switch ($Answer)
        {
            # show the answer hint and stay with current card
            "?" {
                    Write-Host ([String]::new("*", 80))
                    Write-Host $Card.AnswerHint
                    Write-Host ([String]::new("*", 80))
                    break
            }
            # show all answers and show next card
            "!" {
                    Write-Host ([String]::new("-", 80))
                    Write-Host "The correct answers for the current quizz card:"
                    Write-Host
                    for($i=1;$i -le $Card.AnswerId.Count;$i++)
                    {
                        $Outline = "$i) $($Card.Options[$i-1])"
                        Write-Host $Outline
                    }
                    Write-Host ([String]::new("-", 80))
                    $Script:SkippedCardCount++
                    $ExitMode = $true
                    break
            }
            # Option input? (A, B, C etc.)
            { [Byte][Char]$_ -gt 64 -and (([Byte][Char]$_) - 64) -lt (65+$OptionsCount)} {
                $AnswerId = ([Byte][Char]$Answer) - 65
                if ($Card.AnswerId -contains $AnswerId)
                {
                    Write-Host 
                    Write-Host -Fore Green "This answer is very good"
                    Write-Host 
                    # Mark Card as solved
                    $Card.IsSolved = $true
                    $Script:CorrectCardCount++
                }
                else
                {
                    Write-Host 
                    Write-Host -Fore Red "This answer does not address the truth"    
                    Write-Host
                    $Script:WrongCardCount++
                    $Card.IsSolved = $false
                }
                $ExitMode = $true
            }
        }
    } while ($ExitMode -ne $true)
}

<#
.Synopsis
Shows the statistics of a quizz run
#>
function Show-QuizRunResult
{
    [CmdletBinding()]
    param()
    Write-Host ([String]::new("=", 80))
    Write-Host -Fore Green ("Correct Answers: {0}" -f $CorrectCardCount)
    Write-Host -Fore Red ("Wrong Answers: {0}" -f $WrongCardCount)
    Write-Host -Fore Magenta ("Skipped Cards: {0}" -f $SkippedCardCount)
    $Quota = 0
    if ($CorrectCardCount -gt 0 -or $WrongCardCount -gt 0)
    {
        $Quota = $CorrectCardCount / ($CorrectCardCount + $WrongCardCount) 
    }
    Write-Host -Fore Yellow ("Quota: {0:f}" -f $Quota)
    Write-Host ([String]::new("=", 80))
}

<#
.SYNOPSIS

Runs a PoshQuiz

.DESCRIPTION
Console based displaying of cards
.NOTES
General notes
#>
function Invoke-QuizRun
{
    [CmdletBinding()]
    param([Quiz]$Quiz, [Switch]$SolvedOnly)
    $Script:CorrectCardCount = 0
    $Script:WrongCardCount = 0
    $Script:SkippedCardCount = 0
    if ($SolvedOnly)
    {
        $AllCards = @($CurrentQuiz.Cards | Where-Object IsSolved -eq $false)
    }
    else {
        $AllCards = @($CurrentQuiz.Cards)        
    }
    if ($AllCards.Count -eq 0)
    {
        Write-Host -Fore Red "No cards available for this Quizz"
    }
    # Cards is a List`QuizCard not an array
    $AllCards.ForEach{
        Show-QuizCard $_
    }
    Show-QuizRunResult
}

<#
 .Synopsis
 Shows only the questions of a quizz
#>
function Get-QuizQuestions
{
    [CmdletBinding()]
    param([Quiz]$Quiz)
    Write-Host
    Write-Host ([String]::new("=", 80))
    @($Quiz.Cards).ForEach{
        Write-Host "Q: $($_.Question)"
    }
    Write-Host ([String]::new("=", 80))
    Write-Host
}