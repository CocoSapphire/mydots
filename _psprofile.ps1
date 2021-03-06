set-location $env:userprofile -PassThru
set-variable -name home -value $env:userprofile -force

try {
    import-module psget -erroraction silentlycontinue
    import-module poshcode -erroraction silentlycontinue
    import-module posh-hg -erroraction silentlycontinue
    import-module posh-git -erroraction silentlycontinue
    import-module find-string -erroraction silentlycontinue
    import-module psurl -erroraction silentlycontinue
} catch {
    echo "could not import all of our typical deps ... try running go.ps1 again!"
}

set-alias which get-command

function read-pass 
{
    [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((Read-Host 'What is your password?' -AsSecureString)))
}

function uninstall
{
    gwmi win32_product | ? { $_.name -match $args[0] } | % { $_.uninstall() }
}

function grep 
{
    get-childitem $args[0] -include $args[1] -rec | select-string -pattern $args[2..-1]
}

function whosws 
{
    @(Get-WmiObject -ComputerName $args[0] -credential (get-credential $args[1]) -class win32_computersystem).UserName
}

function tail
{
    get-content $args[0] -tail 30 -wait
}

function help
{
    get-help $args[0] | out-host -paging
}

function man
{
    get-help $args[0] | out-host -paging
}

function mkdir
{
    new-item -type directory -path $args
}

function md
{
    new-item -type directory -path $args
}

function prompt
{
    "PS " + $(get-location) + "> "
}

function pro 
{ 
    vim $profile 
}

function prompt 
{
	$path = ""
	$pathbits = ([string]$pwd).split("\", [System.StringSplitOptions]::RemoveEmptyEntries)
	if($pathbits.length -eq 1) {
		$path = $pathbits[0] + "\"
	} else {
		$path = $pathbits[$pathbits.length - 1]
	}
	$userLocation = $env:username + '@' + [System.Environment]::MachineName + ' ' + $path
	$host.UI.RawUi.WindowTitle = $userLocation
    Write-Host($userLocation) -nonewline -foregroundcolor Green 

	Write-Host('>') -nonewline -foregroundcolor Green    
	return " "
}


& {
    for ($i = 0; $i -lt 26; $i++) 
    { 
        $funcname = ([System.Char]($i+65)) + ':'
        $str = "function global:$funcname { set-location $funcname } " 
        invoke-expression $str 
    }
}

trap [Exception]
{
	Write-Error "An exception was encountered";
	Write-Error $_.Exception.Message;
	Write-Error $_.Exception.StackTrace;
	Exit;
}
