_G.DungeonConsts = {};

DungeonConsts.Type_Find_Path = 1
DungeonConsts.Type_Kill_Monster = 2
DungeonConsts.Type_Npc_Talk = 3
DungeonConsts.Type_Conllection = 4
DungeonConsts.Type_Use_Item = 5

DungeonConsts.AUTO_NEXT_WAIT_TIME = 500
----------------------------组队副本相关----------------------------------

--组队副本队员准备状态
DungeonConsts.PrepareStatus_Agree = 0;
DungeonConsts.PrepareStatus_Confirming = 1;
DungeonConsts.PrepareStatus_Refuse = 2;

--组队副本确认结果
DungeonConsts.Agree = 1;
DungeonConsts.Refuse = 0;

DungeonConsts.SingleDungeon_BXDG = 401;
DungeonConsts.SingleDungeon_SGZC = 601;
DungeonConsts.SingleDungeonGroupID_BXDG = 4;
DungeonConsts.SingleDungeonGroupID_SGZC = 6;

--获取组队副本队员准备状态秒数文本
function DungeonConsts:GetPrepareStatusTxt(status)
	local statusStr = "";
	local statusColor = 0xFFFFFF;
	if status == DungeonConsts.PrepareStatus_Agree then
		statusStr = StrConfig['dungeon3'];
		statusColor = 0x22c50b;
	elseif status == DungeonConsts.PrepareStatus_Confirming then
		statusStr = StrConfig['dungeon4'];
		statusColor = 0xcc0000;
	elseif status == DungeonConsts.PrepareStatus_Refuse then
		statusStr = StrConfig['dungeon5'];
	end
	return statusStr, statusColor;
end

---------------------------------------副本类型------------------------------------
DungeonConsts.fubenType_pata = 21;                --爬塔副本
DungeonConsts.fubenType_lingguang = 7;            --灵光魔冢
DungeonConsts.fubenType_makinoBattle = 32;        --牧野之战
-----------------------------------------------------------------------------------

-- 副本显示类型
DungeonConsts.ShowType_Normal = 1 -- 普通副本，在副本面板显示

-- 副本奖励类型
DungeonConsts.Equip = 1;
DungeonConsts.Exp   = 2;
DungeonConsts.Money = 3;

-- 获取副本奖励类型文本
function DungeonConsts:GetDungeonRewardTypeTxt(reward_type)
	local rewardTypeTxt = "";
	if reward_type == 1 then
		rewardTypeTxt = StrConfig['dungeon201'];
	elseif reward_type == 2 then
		rewardTypeTxt = StrConfig['dungeon202'];
	elseif reward_type == 3 then
		rewardTypeTxt = StrConfig['dungeon203'];
	end
	return rewardTypeTxt;
end

-- 副本类型
DungeonConsts.SinglePlayer = 1;
DungeonConsts.Team         = 2;

-- 获取副本类型文本(单人， 组队)
function DungeonConsts:GetDungeonTypeTxt(type)
	local typeTxt = "";
	if type == DungeonConsts.SinglePlayer then
		typeTxt = StrConfig['dungeon206'];
	elseif type == DungeonConsts.Team then
		typeTxt = StrConfig['dungeon207'];
	end
	return typeTxt;
end

-- 难度等级
DungeonConsts.Normal    = 1; -- 普通难度
DungeonConsts.Difficult = 2; -- 困难难度
DungeonConsts.Nightmare = 3; -- 噩梦难度
DungeonConsts.Legend    = 4; -- 传说难度
DungeonConsts.Myth      = 5; -- 神话难度

DungeonConsts.AllDiff = { DungeonConsts.Normal}; --, DungeonConsts.Difficult, DungeonConsts.Nightmare, DungeonConsts.Legend, DungeonConsts.Myth 



-- 获取难度等级名称
function DungeonConsts:GetDifficultyName(diff, withBracket)
	local name = "";
	if diff == DungeonConsts.Normal then
		name = StrConfig["dungeon217"];
	elseif diff == DungeonConsts.Difficult then
		name = StrConfig["dungeon218"];
	elseif diff == DungeonConsts.Nightmare then
		name = StrConfig["dungeon219"];
	elseif diff == DungeonConsts.Legend then
		name = StrConfig["dungeon220"];
	elseif diff == DungeonConsts.Myth then
		name = StrConfig["dungeon221"];
	end
	if withBracket then
		name = string.format( "【%s】", name );
	end
	return name;
end

function DungeonConsts:GetDifficultyColor( diff )
	local color
	if diff == DungeonConsts.Normal then
		color = "#22C50B"
	elseif diff == DungeonConsts.Difficult then
		color = "#00B7EE"
	elseif diff == DungeonConsts.Nightmare then
		color = "#EC55C8"
	elseif diff == DungeonConsts.Legend then
		color = "#B400FF"
	elseif diff == DungeonConsts.Myth then
		color = "#F9680C"
	else
		color = "#22C50B"
	end
	return color;
end

-- 同组副本难度解锁分数, 比如 困难难度解锁需要普通难度xx分通关，就是这个分。同时也是结算面板的大字评分最高值，超出的显示在额外评分上面
DungeonConsts.UnLockScore = 10000;

--副本结算界面自动退出时间 s
DungeonConsts.AutoQuitDelay = 30;

--组队副本邀请等待自动拒绝时间
DungeonConsts.TeamDungeonAutoRefuse = 10;

--副本战斗结果
DungeonConsts.Pass = 1;
DungeonConsts.Failed = 0;

--副本随机事件状态
DungeonConsts.EventNotify   = 1;
DungeonConsts.EventStart    = 2;
DungeonConsts.EventComplete = 3;
DungeonConsts.EventFail     = 4;


--单人副本vip进入类型
DungeonConsts.VIP_TypeNoItem  = 1;
DungeonConsts.VIP_TypeNoTimes = 2;

--------------------------------------------------------------------------

-- 排行榜操作相关
-- 对排行榜点击的菜单操作
DungeonConsts.ROper_ShowInfo = 1;--查看资料

-- 所有操作
DungeonConsts.AllROper = {
	DungeonConsts.ROper_ShowInfo,
}

-- 获取操作名
function DungeonConsts:GetOperName(oper)
	if oper == DungeonConsts.ROper_ShowInfo then
		return StrConfig['chat401'];
	end
end

-- 钻石vip进入次数(配置)
function DungeonConsts:GetDiamondVipEnterConst( )
	local cfg = t_consts[333]
	if not cfg then return end
	return cfg.val1
end

-- 副本产出功能id和资源(策划进行修改)
-- note:
-- param1:功能id
-- param2:资源名称
-- param3:打开功能id
-- param4:打开功能名称
DungeonConsts.DungeonOpenFuncIdAnaImgUrl = {
	{20,"v_fb_tianshen",115,"天神"},    --天神战场
	{74,"v_fb_shenyi",55,"神翼"},       --组队挑战
	{123,"v_fb_jingjie",25,"境界"},     --牧野之战
	{121,"v_fb_shenbing",21,"神兵"},    --诛仙阵
}