<#
 .Synopsis
 A few simple tests for PoshQuizV1
#>

Using Module .\PoshQuizClassesV1.psm1

. .\PoshQuizHelpersV1.ps1
function InitSampleQuiz1()
{
    $Quiz = [Quiz]::new()
    # Create the first quizcard
    $QC1 = [QuizCard]::new(3, "MultipleChoiceSingle")
    $QC1.AnswerId = 0
    $QC1.Level = "Easy"
    $QC1.Question = "Was ist ein Mibibyte?"
    $QC1.Options[0] = "Die offizielle Einheit für eine Speichergröße"
    $QC1.Options[1] = "Speichergröße für SmartPhone-Speicherkarten"
    $QC1.Options[2] = "Spielt nur bei Quantencomputern eine Rolle"

    # Create the second quizcard
    $QC2 = [QuizCard]::new(4, "MultipleChoiceSingle")
    $QC2.AnswerId = 0
    $QC2.Level = "Easy"
    $QC2.Question = "Was ist der Workingset?"
    $QC2.Options[0] = "Ein anderer Begriff für die Arbeitsspeicherbelegung eines Prozesses"
    $QC2.Options[1] = "Der Satz an Arbeit, der von einem IT-Prozess pro Sekunde abgearbeitet wird"
    $QC2.Options[2] = "Ein funktionierender Satz an Einstellungen (egal was)"
    $QC2.Options[3] = "Eine provisorische Arbeitsumgebung"

    # Create the second quizcard
    $QC3 = [QuizCard]::new(3, "MultipleChoiceSingle")
    $QC3.AnswerId = 0
    $QC3.Level = "Easy"
    $QC3.Question = "Was versteht man unter einem Thread?"
    $QC3.Options[0] = "Ein Ausführungsfaden innerhalb eines Prozesses"
    $QC3.Options[1] = "Eine Bedrohung durch Viren"
    $QC3.Options[2] = "Ein vollständig gelöschtes (also geschreddertes) Word-Dokument"
    
    $Quiz.Cards.Add($QC1)
    $Quiz.Cards.Add($QC2)
    $Quiz.Cards.Add($QC3)
    return $Quiz
}

function InitSampleQuiz2
{
    param([String]$Path)
    $Quiz = Get-Content -Path $Path | ConvertFrom-JSON
    $Quiz
}

describe "create quizzes with script code" {

    it "should return some cards" {
        $Quiz = InitSampleQuiz1
        $Quiz.Cards.Count | Should be 3
    }
}

describe "create quizzes with JSON files" {

    it "should return cards" {
        $JsonPath = ".\Quizzes\Quiz01.json"
        $Quiz = InitSampleQuiz2 -Path $JsonPath
        $Quiz.Cards.Count | Should be 3
    }

    it "should return options" {
        $JsonPath = ".\Quizzes\Quiz01.json"
        $Quiz = InitSampleQuiz2 -Path $JsonPath
        $Quiz.Cards.Options.Count | Should be 10
    }
}

describe "create quizzes with PoshQuiz DSL" {

    it "Should return cards" {
        $QuizDefPath = ".\Quizzes\Quiz01.txt"
        $Quiz = Read-PoshQuiz -Path $QuizDefPath
        $Quiz.Cards.Count | Should be 3
    }
}