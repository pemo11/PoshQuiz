<#
 .Synopsis
 The class definitions for PoshScript V1
#>

# The level for a quiz card question
enum QuizCardLevel
{
    Easy
    Medium
    Expert
}

# At the moment there is only one type
enum QuizCardType
{
    MultipleChoice
}

# represents a single quiz cards
class QuizCard
{
    [String]$Question
    [QuizCardLevel]$Level
    [Int[]]$AnswerId
    [String[]]$Options
    [QuizCardType]$Type
    [Bool]$IsSolved
    [Bool]$IsHintRequested
    [String]$AnswerHint

    QuizCard([Int]$OptionsCount, [QuizCardType]$Type = [QuizCardType]::MultipleChoice)
    {
        $this.Options = New-Object -TypeName "String[]" -ArgumentList $OptionsCount
        $this.Type = $Type
    }

    QuizCard()
    {
        $this.Options = @()
    }
}

# represents a single quiz
class Quiz
{
    [Int]$QuizId
    [String]$Title
    [String]$Author
    [String]$Category
    [String]$Language = "de"
    [String]$CreationDate
    [System.Collections.Generic.List[QuizCard]]$Cards

    Quiz()
    {
        $this.Cards = [System.Collections.Generic.List[QuizCard]]::new()
    }
}

# A class for details about a quiz run
class QuizRun
{
    [Int]$QuizId
    [Int]$StartTime
    [string]$UserId
    [string]$Hostname
}