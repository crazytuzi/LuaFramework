-- 主界面常量
-- haohu
-- 2014年8月20日11:10:45
_G.classlist['MainMenuConsts'] = 'MainMenuConsts'
_G.MainMenuConsts = {}
MainMenuConsts.objName = 'MainMenuConsts'
MainMenuConsts.HotKeyMap = {
	[_System.KeyM] = "UIBigMap",
}

MainMenuConsts.LineMap = {
	[1]  = { line = 1, label = StrConfig["mainmenuMap101"] },
	[2]  = { line = 2, label = StrConfig["mainmenuMap102"] },
	[3]  = { line = 3, label = StrConfig["mainmenuMap103"] },
	[4]  = { line = 4, label = StrConfig["mainmenuMap104"] },
	[5]  = { line = 5, label = StrConfig["mainmenuMap105"] },
	[6]  = { line = 6, label = StrConfig["mainmenuMap106"] },
	[7]  = { line = 7, label = StrConfig["mainmenuMap107"] },
	[8]  = { line = 8, label = StrConfig["mainmenuMap108"] },
	[9]  = { line = 9, label = StrConfig["mainmenuMap109"] },
	[10] = { line = 10, label = StrConfig["mainmenuMap110"] }
}


MainMenuConsts.PKConsts = {
	PK_Peace 			= 0;  -- 和平
	PK_Team 			= 1;  -- 同队伍
	PK_Guild 			= 2;  -- 同帮派
	PK_Server 			= 3;  -- 同服
	PK_Camp 			= 4;  -- 同阵营
	PK_GoodBad 			= 5;  -- 善恶
	PK_All 				= 6;  -- 全体
	PK_Custom			= 7;  -- 自定义
}

------------------------------在某些活动中or地图中不显示攻击提示----------------------------

MainMenuConsts.HideActivityConsts = {
	[1]	=	{ id = 10002 },
	[2]	=	{ id = 10003 },
	[3]	=	{ id = 10005 },
	[4]	=	{ id = 10006 },
	[5]	=	{ id = 10007 },
}

MainMenuConsts.HideMapConsts = {
	[1] =	{ id = 10320010},
	[2] =	{ id = 10400035},
	[3] =	{ id = 10400036},
	[4] =	{ id = 10400037},
	[5] =	{ id = 10430001},
	[6] =	{ id = 10430002},
	[7] =	{ id = 10430003},
}

----------------------------------------------------------复活相关常量----------------------------------------------


--复活面板无操作倒计时*秒后自动回城复活
MainMenuConsts.ReviveWait = 60;

--可以免费原地复活的等级
local ReviveFreeLevel
function MainMenuConsts:GetReviveFreeLevel()
	if not ReviveFreeLevel then
		ReviveFreeLevel = t_consts[63].val1
	end
	return ReviveFreeLevel
end

-- 复活道具id
local ReviveItem
function MainMenuConsts:GetReviveItem()
	if not ReviveItem then
		ReviveItem = t_consts[7].val1
	end
	return ReviveItem
end

-- 元宝价格
local ReviveYuanBao
function MainMenuConsts:GetReviveYuanBao()
	if not ReviveYuanBao then
		ReviveYuanBao = t_consts[7].val2
	end
	return ReviveYuanBao
end

 -- 绑元价格
local ReviveLijin
function MainMenuConsts:GetReviveLijin()
	if not ReviveLijin then
		ReviveLijin = t_consts[7].val3
	end
	return ReviveLijin
end
