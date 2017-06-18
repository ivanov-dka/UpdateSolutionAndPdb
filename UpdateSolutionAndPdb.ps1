#перед вызовом переходим в папку с dll и pdb файлами
#cd ..

#константы имен пакета и pdb файла
$pdb = "FullUlsMessageExample.pdb"
$wspName = "FullUlsMessageExample.wsp"


#обновляем wsp-пакет
Update-SPSolution -GACDeployment -Identity $wspName -LiteralPath $(Get-Childitem $wspName)    

#дожидаемся установки пакета
$isDeployed = $false
$counter = 0
$lor = [Microsoft.SharePoint.Administration.SPSolutionOperationResult]::DeploymentSucceeded
while(-not($isDeployed))
{
    $counter += 1
    if($counter -le 100) {
	    Write-Progress -Activity 'Установка решения' -CurrentOperation $wspName -PercentComplete ($counter)
    }
    Start-Sleep -Milliseconds 400
	
	$wspID = Get-SPSolution -Identity $wspName;
	if($wspID.Deployed -and (-not($wspID.JobExists)))
	{
		if($wspID.LastOperationResult -ne $lor)
		{
			Write-Host -ForegroundColor Red Решение $wspName обновилось с ошибкой
			exit 1
		}
        $isDeployed = $true        
        Write-Host Решение $wspName обновлено! -ForegroundColor Green 
	}	
}

#путь к сборке в GAC
$assembly = [io.path]::GetFileNameWithoutExtension($pdb)
$gac = "$env:windir\Microsoft.NET\assembly\GAC_MSIL\$assembly"
if (test-path $gac) {
	resolve-path "$gac\*" | % {
        #копируем pdb в папку
        copy $(Get-Childitem $pdb) -destination $_ -force
	}
}

Write-Host $pdb скопирован в GAC -ForegroundColor Green 