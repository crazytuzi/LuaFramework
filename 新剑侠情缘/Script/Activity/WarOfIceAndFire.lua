
local tbAct    = Activity:GetUiSetting("WarOfIceAndFire");
tbAct.nShowLevel = 20
tbAct.szTitle    = "灭火大作战"
tbAct.FuncContent = function (tbData)
    local szStart   = Lib:TimeDesc7(tbData.nStartTime)
    local szEnd     = Lib:TimeDesc7(tbData.nEndTime + 1)
    local szContent = [[
	[FFFE0D]灭火大作战活动开始了！[-]
	[FFFE0D]活动时间：%s-%s[-]
	[FFFE0D]参与等级：20级[-]
]]
    return string.format(szContent, szStart, szEnd);
end

tbAct.tbSubInfo = {
	{szType = "Item2", szInfo = [[
	单人报名后，自由选择变身为火娃或者水娃，进入特殊地图，进行1V4的灭火大作战。[FFFE0D]（每天比赛时间为13:30、16:00和20:00）[-]
	比赛分火娃水娃两大阵营，火娃通过淘汰所有水娃或者存活到最后获胜，水娃则必须在活动时间内淘汰火娃方可获胜。
	火娃和水娃每场比赛均会根据表现获得积分进入排行，水娃和火娃的[FFFE0D]排行榜分开展示，独立获得排行奖励[-]。
	火娃排行榜奖励如下：
	第1名：[e6d012][url=openwnd:六阶·灭火大作战礼盒, ItemTips, "Item", nil, 11675][-]
	第2至第5名：[ff8f06][url=openwnd:五阶·灭火大作战礼盒, ItemTips, "Item", nil, 11676][-]
	第6至第10名：[ff578c][url=openwnd:四阶·灭火大作战礼盒, ItemTips, "Item", nil, 11677][-]
	第11至第20名：[aa62fc][url=openwnd:三阶·灭火大作战礼盒, ItemTips, "Item", nil, 11678][-]
	第21至第50名：[11adf6][url=openwnd:二阶·灭火大作战礼盒, ItemTips, "Item", nil, 11679][-]
	第51至第100名：[64db00][url=openwnd:一阶·灭火大作战礼盒, ItemTips, "Item", nil, 11680][-]

	水娃排行榜奖励如下：
	第1名：[e6d012][url=openwnd:六阶·灭火大作战礼盒, ItemTips, "Item", nil, 11681][-]
	第2至第5名：[ff8f06][url=openwnd:五阶·灭火大作战礼盒, ItemTips, "Item", nil, 11682][-]
	第6至第10名：[ff578c][url=openwnd:四阶·灭火大作战礼盒, ItemTips, "Item", nil, 11683][-]
	第11至第20名：[aa62fc][url=openwnd:三阶·灭火大作战礼盒, ItemTips, "Item", nil, 11684][-]
	第21至第50名：[11adf6][url=openwnd:二阶·灭火大作战礼盒, ItemTips, "Item", nil, 11685][-]
	第51至第100名：[64db00][url=openwnd:一阶·灭火大作战礼盒, ItemTips, "Item", nil, 11686][-]
	注：[FFFE0D]玩家若进入两个排行榜，则可以分别领取奖励，不会受到影响[-]。
	]]
	},
};


Activity.tbWarOfIceAndFire = Activity.tbWarOfIceAndFire or {}
local tbWarOfIceAndFire = Activity.tbWarOfIceAndFire;

function tbWarOfIceAndFire:OnPlayerDeath(dwAliveMemberNpcId)
	self.bIsPlayerDeath = true;
	Operation:DisableWalking();
	if dwAliveMemberNpcId then
		AutoFight:StartFollowTeammate(dwAliveMemberNpcId);
	end
end

function tbWarOfIceAndFire:OnRightInfoChange(nRemainingGameTime, nMyValue, nPartState)

    Ui:OpenWindow("QYHLeftInfo", "WarOfIceAndFireFight", {nRemainingGameTime, nMyValue, nPartState})
end

function tbWarOfIceAndFire:OnRightInfoInit(nRemainingGameTime)

    Ui:OpenWindow("QYHLeftInfo", "WarOfIceAndFirePre", {nRemainingGameTime})
end

function tbWarOfIceAndFire:OnSyncChooseRoleNum(nChooseFireNum, nChooseIceNum)
	self.nChooseFireNum = nChooseFireNum;
	self.nChooseIceNum = nChooseIceNum;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_WAROFFIREANDICE_CHOOSE_ROLE_NUM);
end

function tbWarOfIceAndFire:GetChooseRoleNum()
	return self.nChooseIceNum, self.nChooseFireNum;
end

function tbWarOfIceAndFire:IsDeathInGame()
	if self.bIsPlayerInGame and self.bIsPlayerDeath then
		if me.nMapTemplateId == self.nPlayMapTID then
			me.CenterMsg("当前状态不能进行该操作")
			return true
		end
	end
end

function tbWarOfIceAndFire:IsPlayerInGame()
	if self.bIsPlayerInGame then
		me.CenterMsg("当前状态不能进行该操作")
		return true;
	end
end

function tbWarOfIceAndFire:OnSynIsPlayerInGame()
	if not self.bIsPlayerInGame then
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnLeaveGame, self)  --进新的非战场图， 正常离开或重连超时时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveGame, self)  --离开战场图  返回登录时
		self.bIsPlayerInGame = true;
	end
end

function tbWarOfIceAndFire:OnSynIsPlayerDeath(bIsPlayerDeath)
	self.bIsPlayerDeath = bIsPlayerDeath;
end

function tbWarOfIceAndFire:OnLeaveGame()
	if self.bIsPlayerInGame then
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)

		self.bIsPlayerInGame = nil;
	end
	self.bIsPlayerDeath = nil;
	Ui:CloseWindow("IconPop");
end

function tbWarOfIceAndFire:OnChangeBoss(nBuffID)
	Timer:Register(1, function ()  me.GetNpc().AddSkillState(nBuffID, 1, 0, 10000, 1, 1); end)
end