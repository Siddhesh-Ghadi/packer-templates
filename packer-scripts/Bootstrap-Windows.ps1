Set-StrictMode -Version 1.0

function Main {
  Install-Chocolatey
  Install-Packages
  Install-Bundler
  Clean-Up
  #Create-TravisUser
  Create-StubFiles
}

function Install-Chocolatey {
  $webClient = New-Object System.Net.WebClient
  $installScript = $webClient.DownloadString('https://chocolatey.org/install.ps1')
  
  invoke-expression "$installScript"
  
  choco feature enable -n allowGlobalConfirmation
}

function Install-Packages {
  foreach ($package in Get-Content "c:/windows/temp/packages.txt" `
           | Select-String -NotMatch "^(#.*|)$") {
    $package = $package.Line.Trim()
    if ($package -ne "") {
      invoke-expression "choco install $package"
    }
  }
}

function Install-Bundler {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    gem install bundler
}

function Clean-Up {
  choco install choco-cleaner
  & C:\ProgramData\chocolatey\bin\choco-cleaner.ps1
  choco uninstall choco-cleaner
}

function Create-TravisUser {
  $randChars = (35..122) | Get-Random -Count 32
  $pwPlain = -join ($randChars | % {[char]$_})
  $pw = $pwPlain | ConvertTo-SecureString -AsPlainText -Force

  echo "setting up travis user"
  New-LocalUser `
    -Name "travis" `
    -FullName "Travis User" `
    -Description "travis user from packer" `
    -Password $pw
  Add-LocalGroupMember -Group "Administrators" -Member "travis"
}

function Create-StubFiles {
  "---" >$env:JOB_BOARD_REGISTER_FILE
  "{}" >$env:SYSTEM_INFO_JSON
}

Main