
<#PSScriptInfo

.VERSION 0.1.0

.GUID 77d628db-e1bb-4741-b99d-6c1ef48c8ac4

.AUTHOR Michael Greene

.COMPANYNAME Microsoft

.COPYRIGHT 

.TAGS DSCConfiguration

.LICENSEURI https://github.com/Microsoft/WindowsServerContainerHostConfig/blob/master/LICENSE

.PROJECTURI https://github.com/Microsoft/WindowsServerContainerHostConfig

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
https://github.com/Microsoft/WindowsServerContainerHostConfig/blob/master/README.md#releasenotes

.PRIVATEDATA 2016-Datacenter-Server-Core

#>

#Requires -Module @{ModuleName = 'PackageManagement'; ModuleVersion = '1.7.1.0'}
#Requires -Module @{ModuleName = 'xPendingReboot'; ModuleVersion = '0.3.0.0'}

<# 

.DESCRIPTION 
 PowerShell Desired State Configuration for deploying and configuring
 a Windows Server container host.

 This example follows the guidance provided in the document:
 https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/deploy-containers-on-server

#> 

configuration WindowsServerContainerHostConfig
{

Import-DscResource -ModuleName @{ModuleName = 'PackageManagement'; ModuleVersion = '1.1.7.0'}
Import-DscResource -ModuleName @{ModuleName = 'xPendingReboot'; ModuleVersion = '0.3.0.0'}
Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    WindowsFeature Containers
    {
        Ensure = 'Present'
        Name = 'Containers'
    }
    
    PackageManagement DockerMsftProvider
    {
        Ensure  = 'Present'
        Name = 'DockerMsftProvider'
        Source = 'PSGallery'
    }

    PackageManagement Docker
    {
        Ensure = 'Present'
        Name = 'Docker'
        ProviderName = 'DockerMsftProvider'
        Source = 'PSGallery'
        DependsOn = '[PackageManagement]DockerMsftProvider'
    }

    Environment DockerPath
    {
        Ensure = 'Present'
        Name = 'Path'
        Path = $true
        Value = "$env:ProgramFiles\Docker"
        DependsOn = '[PackageManagement]Docker'
    }

    Service Docker
    {
        Ensure = 'Present'
        Name = 'Docker'
        State = 'Running'
        StartupType = 'Automatic'
        Path = "$env:ProgramFiles\Docker\Dockerd.exe"
        DependsOn = '[PackageManagement]Docker'
    }

    xPendingReboot DockerServiceandContainerFeature
    {
        Name = 'DockerServiceandContainerFeature'
        SkipCcmClientSDK = $true
        DependsOn = '[WindowsFeature]Containers','[Service]Docker'
    }
}
