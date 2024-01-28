@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

rem 设置游戏路径
set "palworld_path=C:\Steam\steamapps\common\PalServer"
rem 设置备份路径
set "backup_path=C:\gameServer\PalServer"
rem 设置保存最近的多少个存档
set "less_save=5"

rem 设置时间阈值（可以指定小时、天、月、年和分钟）
set "time_threshold_hours=2"
set "time_threshold_days=0"
set "time_threshold_months=0"
set "time_threshold_years=0"
set "time_threshold_minutes=0"
rem 设置备份时间
set interval=1800


start  "" "%palworld_path%\PalServer.exe"
echo [%date% %time%] Server started!

:loop
echo [%date% %time%] Backup server data...

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set datetime=%%a
set datestamp=%datetime:~0,8%
set timestamp=%datetime:~8,6%

set current_year=%datestamp:~0,4%
set current_month=%datestamp:~4,2%
set current_day=%datestamp:~6,2%
set current_hour=%timestamp:~0,2%
set current_minute=%timestamp:~2,2%
set current_second=%timestamp:~4,2%

set foldername=%current_year%-%current_month%-%current_day%_%current_hour%-%current_minute%-%current_second%

echo 当前日期时间：!current_year!-!current_month!-!current_day! !current_hour!:!current_minute!:!current_second!

xcopy "%palworld_path%\Pal\Saved" "%backup_path%\Backup_%foldername%" /E /H /C /I

rem 转换时间阈值为分钟
set /a "total_threshold_minutes = time_threshold_years * 525600 + time_threshold_months * 43800 + time_threshold_days * 1440 + time_threshold_hours * 60 + time_threshold_minutes"

set /a backup_count=0

for /d %%i in ("%backup_path%\*") do (
    set "folder_name=%%~nxi"
    echo !folder_name! | findstr /r "^Backup_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9].*$" > nul
    if !errorlevel! equ 0 (
        set /a backup_count+=1
    )
)
set /a "backup_count=backup_count-less_save"

if !backup_count! leq 0 (
    goto endDelete
)

set /a count=0
rem 遍历指定文件夹
for /d %%i in ("%backup_path%\*") do (
    rem 提取文件夹名称中的日期时间信息
    set "folder_name=%%~nxi"
    echo !folder_name! | findstr /r "^Backup_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9].*$" > nul
    if !errorlevel! equ 0 (
        
        if !count! geq %backup_count% (
            echo [%date% %time%] 保存最近至少 !less_save! 个存档
            goto :endDelete
        )
        set /a count+=1
        set "file_year=!folder_name:~7,4!"
        set "file_month=!folder_name:~12,2!"
        set "file_day=!folder_name:~15,2!"
        set "file_hour=!folder_name:~18,2!"
        set "file_minute=!folder_name:~21,2!"
        
        rem 计算日期和时间差值
        set /a "diff_year=current_year-file_year"
        set /a "diff_month=current_month-file_month"
        set /a "diff_day=current_day-file_day"
        set /a "diff_hour=current_hour-file_hour"
        if !diff_hour! lss 0 set /a "diff_hour=current_hour+24-file_hour" & set /a "diff_day=diff_day-1"
        set /a "diff_minute=current_minute-file_minute"
        if !diff_minute! lss 0 set /a "diff_minute=current_minute+60-file_minute" & set /a "diff_hour=diff_hour-1"
        set /a "diff_second=current_second-file_second"
        if !diff_second! lss 0 set /a "diff_second=current_second+60-file_second" & set /a "diff_minute=diff_minute-1"

        rem 转换时间差为分钟
        set /a "total_diff_minutes = diff_year * 525600 + diff_month * 43800 + diff_day * 1440 + diff_hour * 60 + diff_minute"

        rem 判断时间差是否超过阈值
        if !total_diff_minutes! geq !total_threshold_minutes! (
            echo 子文件夹时间: !file_year!-!file_month!-!file_day! !file_hour!:!file_minute!
            echo 时间差值：!diff_year! 年 !diff_month! 月 !diff_day! 天 !diff_hour! 小时 !diff_minute! 分钟 !diff_second! 秒
            echo.
            rmdir /s/q !folder_name!
            echo !folder_name! 文件夹已删除！
        )
    )
)

:endDelete

timeout /t %interval%

goto loop