FBConst = {}

FBConst.E_FBListRefresh = "E_FBListRefresh"	-- 副本列表更新
FBConst.E_DestroyCDMessageBox = "E_DestroyCDMessageBox"  --关闭组队列表

-- 副本类型
FBConst.Type = 
{
	Normal = 0,
}

-- 副本当前状态, 0:未开始 / 1:持续中 / 2:开始进入关闭倒计时
FBConst.OpenState = 
{
	NotOpen = 0,
	Opening = 1,
	Cutdown = 2
}

FBConst.StrTitle = "副 本"
FBConst.TypeList = { FBConst.Type.Normal }
FBConst.CellNum = 4	-- FBUI界面可显示cell数量

FBConst.RedTipsDataKey = "FBConst.RedTipsDataKey"

FBConst.RedTipsState = {
	Has = "1",
	HasNo = "0",
	None = "-1"
}

FBConst.EnumDesc = 
{
	[1] = "副本难度较低，可单人前往",
	[2] = "副本难度较高，建议组队前往",
	[3] = "最高难度副本，务必组队前往",
}