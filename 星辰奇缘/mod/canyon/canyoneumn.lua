-- 联赛枚举
CanYonEumn = CanYonEumn or {}

CanYonEumn.Status = 
{
	NotStarted = 0,	     --未开始
	Informed = 1,	     --通知
	Reading = 2,         --准备区
	Grouping = 3,        --计算分配
	Preparing = 4,       --战场备战
	Playing = 5,         --战场激活
	Finished = 6         --结束
}

CanYonEumn.CampNames = 
{
	TI18N("联盟"),
	TI18N("部落")
}

CanYonEumn.UnitType = {
    Tower = 1,
    Cannon = 2,
    Home = 3,
}
