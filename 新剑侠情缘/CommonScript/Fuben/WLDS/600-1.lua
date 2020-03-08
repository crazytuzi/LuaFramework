
local tbFubenSetting = {};
Fuben:SetFubenSetting(152, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "武林大事刺杀"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/WLDS/NpcPos600-1.tab"	-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/1_1/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/WLDS/NpcPath600-1.tab"	-- 寻路点
tbFubenSetting.tbBeginPoint 			= {5492, 9932}											-- 副本出生点
tbFubenSetting.nStartDir				= 56;

--NPC模版ID，NPC等级，NPC五行；


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2800,			nLevel = -1,  nSeries = 0},  --南院大王
	[2] = {nTemplate = 2804,			nLevel = -1,  nSeries = 0},  --金兵
}


--是否允许同伴出战
tbFubenSetting.bForbidPartner = true;
tbFubenSetting.bForbidHelper = true;

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 1, 1147, false},	--剧情1
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4894, 10257},
		},
	},
	[2] = {nTime = 1800, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetShowTime", 2},
		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 1, 1, 5, "boss", "boss", false, 24, 0, 9010, 1},
		},
	},
	[4] = {nTime = 2, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "有刺客！快抓刺客！", 3, 1, 1},
			{"AddNpc", 2, 6, 0, "guaiwu", "guaiwu", false, 24, 0, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "不知天高地厚的狂徒，敢来我大营行刺！", 3, 2, 1},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[6] = {nTime = 2.1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"GameWin"},
		},
	},
}