# Palworld_Backup

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

备份删除的依据，存档时间优先级比存档的个数高