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

enum QuizCardType
{
    MultipleChoiceSingle
    MultipleChoiceMulti
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

    QuizCard([Int]$OptionsCount, [QuizCardType]$CardType = [QuizCardType]::MultipleChoiceSingle)
    {
        $this.Options = New-Object -TypeName "String[]" -ArgumentList $OptionsCount
        $this.Type = $CardType
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