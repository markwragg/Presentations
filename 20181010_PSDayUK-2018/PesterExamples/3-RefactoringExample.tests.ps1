. './3-RefactoringExample.ps1'

Describe 'Get-TempFile tests' {
    New-Item c:/test.tmp
    New-Item TestDrive:/tmp.doc

    It 'Should return only .tmp files' {
        (Get-TempFile -Path TestDrive:/).Extension | Should -Be '.tmp'
    }
}