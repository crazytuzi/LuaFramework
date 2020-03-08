Require("CommonScript/EnvDef.lua")

ChangBaiZhiDian.Def = {

	SAVE_GROUP = 196;
	SAVE_VERSION = 1;
	SAVE_LAST_ADD_TIME = 2;
	SAVE_JOIN_TIME = 3;

	bOpen = false;							--是否默认开启
	szOpenTimeFrame = "OpenLevel69";		--开启时间轴
	nMinTeamCount = 6;						--最小开启队伍数
	nTeamMaxPlayerCount = 2;				--队伍最大人数
	nTeamCountPer = 8;						--每个场地中的队伍数量
	nMinSignUpLevel = 55;					--最小参与等级
	nMatchInterval = 60 * 5;				--匹配间隔（秒）
	nPreCreateBattleMapTime = 30;			--提前多久预创建战斗地图（必须小于匹配间隔！）
	nMatchTimes = 3;						--匹配次数
	tbReviveTime = 							--重伤复活时间（秒）
	{10, 15, 20, 25, 30, 35,40};
	nDeathLostRate = 0.05;					--死亡失去的积分比例
	nDelayKickOut = 10;						--活动结束后延迟踢出地图（秒）
	nAddScoreInterval = 10;					--占领NPC后持续加分的间隔
	nRobRate = 0.5;							--抢夺NPC的积分比例
	nAvatarPlayerLevel = 80;				--变身的角色等级
	szAvatarEquipKey = "InDiffer";			--变身的装备Key
	szAvatarInsetKey = "InDiffer";			--变身的镶嵌Key
	nEnhLevel = 80;							--变身的强化等级
	tbSkillBookType = {9, 10, 11, 12};		--变身的秘籍（1-4初级秘籍，2-8中级秘籍，9-12高级秘籍）
	tbForbiddenFaction = {					--禁用的门派
		[6] = true;
	};
	nEverydayAddTimes = 2;					--每天增加的参与次数
	nMaxJoinTimes = 14;						--最多可累计的参与次数

	nReadyMapTID = 8019;					--准备场地图模板ID
	nBattleMapTID = 8018;					--战斗地图模板ID（UiState配置成32|show，跟心魔绝地一样）

	tbReadyMapPos = {						--进入准备场的坐标
		{2706,5659}; 
        {2666,6319}; 
        {2684,5001}; 
        {6931,5712}; 
        {6947,6462}; 
        {6947,4994}; 
	};
	tbBattleMapPos = {						--战斗地图出生点
		{nX = 12857, nY = 11709, szName = "坤", nTitleID = 6880},
		{nX = 8360, nY = 13410, szName = "艮", nTitleID = 6881},
		{nX = 4018, nY = 11180, szName = "坎", nTitleID = 6882},
		{nX = 2719, nY = 8114, szName = "巽", nTitleID = 6883},
		{nX = 4037, nY = 4356, szName = "乾", nTitleID = 6884},
		{nX = 8341, nY = 2833, szName = "兑", nTitleID = 6885},
		{nX = 12179, nY = 4645, szName = "离", nTitleID = 6886},
		{nX = 13667, nY = 7866, szName = "震", nTitleID = 6887},
	};
	tbBattleMapTrapPos = {						--踩到Trap点后传送到的位置（障碍外面）
		{nX = 12413, nY = 11284},
		{nX = 8391, nY = 12812},
		{nX = 4531, nY = 10911},
		{nX = 3324, nY = 8148},
		{nX = 4281, nY = 4616},
		{nX = 8361, nY = 3330},
		{nX = 11932, nY = 4850},
		{nX = 12946, nY = 7812},
	};
	tbTimeState = {					--时间流程
		[1] = { nNextTime = 70, szFunc = "AutoChooseFaction", szDesc = "选择门派"},
		[2] = { nNextTime = 20, szFunc = "EndChooseFaction", szDesc = "选择门派"},	--00:00
		[3] = { nNextTime = 5, szFunc = "RefreshNpc", szDesc = "准备阶段"},			--00:05
		[4] = { nNextTime = 15, szFunc = "StartCountdownTips", szDesc = "准备阶段"},	--00:20
		[5] = { nNextTime = 10, szFunc = "StartBattle", szDesc = "准备阶段"},		--00:30
		[6] = { nNextTime = 270, szFunc = "RefreshBoss", szDesc = "战斗阶段"},		--05:00
		[7] = { nNextTime = 290, szFunc = "EndCountdownTips", szDesc = "战斗阶段"},	--9:50
		[8] = { nNextTime = 10, szFunc = "EndBattle", szDesc = "战斗阶段"},			--10:00
	};
	tbQulity2Score = {						--品质等级对应的需要增加的分数
		[1] = 0,
		[2] = 1000,
		[3] = 2000,
		[4] = 3000,
		[5] = 4000,
		[6] = 5000,
		[7] = 6000,
	};
	tbNameColorByQuality = {				--品质等级对应的名字颜色（从低到高）
		[1] = {"ffffff", "White"},		--白
		[2] = {"64db00", "Green"},		--绿
		[3] = {"11adf6", "Blue"},		--蓝
		[4] = {"aa62fc", "Purple"},		--紫
		[5] = {"ff578c", "Pink"},		--粉
		[6] = {"ff8f06", "Orange"},		--橙
		[7] = {"ffff0e", "Gold"},		--金
	};
	tbRefreshNpcTID = {						--刷新的NPC的模板ID(灵芝、人参、雪莲花)
		3749, 3750, 3751,
	};
	tbNpcType = {							--NPC TID对应的类型
		[3749] = "LingZhi",
		[3750] = "RenShen",
		[3751] = "XueLian",
	};
	tbRefreshNpcPos = {						--刷新NPC的坐标
		{nX =  6776, nY = 4821, nTemplateId = 3749, szIndex = "lingzhi_2"},
		{nX =  5005, nY = 6772, nTemplateId = 3749, szIndex = "lingzhi_4"},
		{nX =  5093, nY = 9485, nTemplateId = 3749, szIndex = "lingzhi_6"},
		{nX =  6859, nY = 11171, nTemplateId = 3749, szIndex = "lingzhi_8"},
		{nX =  9756, nY = 10954, nTemplateId = 3749, szIndex = "lingzhi_10"},
		{nX =  11592, nY = 8901, nTemplateId = 3749, szIndex = "lingzhi_12"},
		{nX =  11317, nY = 6321, nTemplateId = 3749, szIndex = "lingzhi_14"},
		{nX =  9606, nY = 4627, nTemplateId = 3749, szIndex = "lingzhi_16"},
		{nX =  8057, nY = 5892, nTemplateId = 3750, szIndex = "renshen_1"},
		{nX =  6480, nY = 7998, nTemplateId = 3750, szIndex = "renshen_3"},
		{nX =  8146, nY = 9777, nTemplateId = 3750, szIndex = "renshen_5"},
		{nX =  9959, nY = 7927, nTemplateId = 3750, szIndex = "renshen_7"},
		{nX =  7772, nY = 7728, nTemplateId = 3751, szIndex = "xuelian_2"},
		{nX =  8887, nY = 7626, nTemplateId = 3751, szIndex = "xuelian_4"},
	};
	nRefreshNpcLevel = 80;					--NPC等级
	tbRefreshBossPos = {8285, 7996};			--刷新鹿王的坐标
	tbRefreshBossTID = 3753;				--鹿王的模板ID
	tbKillNpcScore = {						--击杀NPC增加的积分
		[3749] = 50,
		[3750] = 60,
		[3751] = 100,
	};
	tbNpcOccupiedScore = {					--占领NPC持续增加的积分
		[3749] = 100,
		[3750] = 200,
		[3751] = 300,
	};
	tbNpcOccupiedBuff = {					--占领NPC提供的buff ID
		[3749] = {4743, 1, "回血效果"}, 				--{nBuffId, nLevel}
		[3750] = {4745, 2, "防御加成效果"},
		[3751] = {4744, 3, "攻击加成效果"},
	};
	tbDmgTipsRange = {						--己方NPC被打多少血的时候队伍消息通知
		0.9, 	--这样的意思是血量掉到90%,70%....时通知
	};
	nTipsMinQualityLevel = 3;				--蓝色及以上才提醒
	tbBossDmgRankScore = {					--鹿王伤害排名增加的积分
		[1] = 8000,
		[2] = 6000,
		[3] = 4000,
	};
	nKillPlayerScore = 50;					--击杀玩家增加的积分

	tbNotOpenMail = {						--人数不够开启的奖励邮件
		Title = "长白之巅补偿",
		From = "独孤剑",
		Text = "很遗憾本轮您未能进入活动，感谢您的耐心等待！",
		tbAttach = {{"Coin", 5000}},
		nLogReazon = Env.LogWay_ChangBaiZhiDian,
	};
	tbBattleEndMail = {						--活动正常结束发的邮件
		Title = "长白之巅奖励",
		From = "独孤剑",
		Text = "您的队伍在本次长白之巅活动中获得[FFFE0D]%d积分[-]，排名[FFFE0D]第%d[-]，增加了[FFFE0D]%d点[-]排行积分，特给予如下奖励，请注意查收附件奖励！",
		nLogReazon = Env.LogWay_ChangBaiZhiDian,
	};
	tbBattleRankAward = {					--排名奖励
		[1] = {1, {{"Contrib", 5000},{"BasicExp", 100}}},			--1
		[2] = {2, {{"Contrib", 4000},{"BasicExp", 90}}},			--1
		[3] = {3, {{"Contrib", 3500},{"BasicExp", 80}}},			--1
		[4] = {4, {{"Contrib", 3000},{"BasicExp", 75}}},			--1
		[5] = {5, {{"Contrib", 2500},{"BasicExp", 70}}},			--1
		[6] = {6, {{"Contrib", 2000},{"BasicExp", 60}}},			--1
		[7] = {7, {{"Contrib", 1000},{"BasicExp", 50}}},			--1
		[8] = {8, {{"Contrib", 500},{"BasicExp", 40}}},			--1
	};
	tbRankboardScore = {					--排名对应的排行榜增加积分
		[1] = 100,
		[2] = 90,
		[3] = 80,
		[4] = 70,
		[5] = 50,
		[6] = 40,
		[7] = 20,
		[8] = 10,
	};
	tbRankboardAward = {					--活动结束时排行榜奖励
		{1, { {"Item", 2804, 30, 0, true},{"Item", 11370, 1} }},				--第1名
		{5, { {"Item", 2804, 20, 0, true},{"Item", 11371, 1} }},				--2-5名
		{10, { {"Item", 2804, 15, 0, true},{"Item", 11372, 1}  }},			--6-10名
		{20, { {"Item", 2804, 10, 0, true} }},			--11-20名
		{50, { {"Item", 2804, 8, 0, true} }},			--21-50名
		{100, { {"Item", 2804, 5, 0, true} }},			--51-100名
		{150, { {"Item", 2804, 2, 0, true} }},			--101-150名
	};
}


function ChangBaiZhiDian:IsOpen()
	return self.Def.bOpen and TimeFrame:GetTimeFrameState(self.Def.szOpenTimeFrame) == 1
end

ChangBaiZhiDian.tbClass = ChangBaiZhiDian.tbClass or {}
function ChangBaiZhiDian:CreateClass(szClass, szBaseClass)
	if szBaseClass and self.tbClass[szBaseClass] then
		self.tbClass[szClass] = Lib:NewClass(self.tbClass[szBaseClass])
	else
		self.tbClass[szClass] = {}
	end
	return self.tbClass[szClass]
end

function ChangBaiZhiDian:GetClass(szClass)
	return self.tbClass[szClass]
end

function ChangBaiZhiDian:GetState2EndTime(nState)
	local nTime = 0
	if nState <=2 then
		for i = nState, 2 do
			nTime = nTime + self.Def.tbTimeState[i].nNextTime
		end
	elseif nState <= 5 then
		for i = nState, 5 do
			nTime = nTime + self.Def.tbTimeState[i].nNextTime
		end
	else
		for i = nState, #self.Def.tbTimeState do
			nTime = nTime + (self.Def.tbTimeState[i].nNextTime or 0)
		end
	end
	return nTime
end

function ChangBaiZhiDian:GetJoinCount(pPlayer)
	if MODULE_GAMESERVER then
		local nStartTime = Activity:__GetActTimeInfo("ChangBaiZhiDian")
		if nStartTime == 0 then
			return 0
		end
		local nVersion = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.SAVE_VERSION)
		if nVersion ~= nStartTime and Activity:IsRunning("ChangBaiZhiDian") then
			pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.SAVE_VERSION, nStartTime)
			pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.SAVE_LAST_ADD_TIME, 0)
			pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.SAVE_JOIN_TIME, 0)
		end
	end

	local nTime = GetTime()
	local nLastAddTime = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.SAVE_LAST_ADD_TIME)
	local nParseTodayTime = Lib:ParseTodayTime("4:00")
	local nUpdateDay = Lib:GetLocalDay((nTime - nParseTodayTime))
	local nUpdateLastDay = 0
	if nLastAddTime == 0 then
		nUpdateLastDay = nUpdateDay - 1
	else
		nUpdateLastDay = Lib:GetLocalDay((nLastAddTime - nParseTodayTime))
	end

	local nJoinCount = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.SAVE_JOIN_TIME)
	local nAddDay = math.abs(nUpdateDay - nUpdateLastDay)
	if nAddDay == 0 then
		return nJoinCount
	end

	if nJoinCount < self.Def.nMaxJoinTimes then
		local nAddCount = nAddDay * self.Def.nEverydayAddTimes
		nJoinCount = nJoinCount + nAddCount
		nJoinCount = math.min(nJoinCount, self.Def.nMaxJoinTimes)
	end

	if MODULE_GAMESERVER then
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.SAVE_JOIN_TIME, nJoinCount)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.SAVE_LAST_ADD_TIME, nTime)
	end

	return nJoinCount
end