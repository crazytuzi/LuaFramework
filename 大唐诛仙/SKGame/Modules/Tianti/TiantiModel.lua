TiantiModel = BaseClass(LuaModel)

function TiantiModel:__init()
	self:Reset()
end

function TiantiModel:Reset()
	self.openType = 0 -- t: nil | 0 主面板， 1排行榜， 2信息榜
	self.rankList = {}
	self.infoData = {}
	self.totalNum = 0 -- 总数量
	self.myRank = 0 -- 我的排名 0：未上榜
	self.curNum = 0 -- 请求排行起始值
	self.matchState = 0 -- 0:未匹配 1:匹配中
	self.pkPlayes = nil
	self.endPkPlayers = nil
	self.pkItemTab = {}
	self.gotStages = {} --已领取奖励的段位列表
	self.cfgScore = nil
	self.cfgScoreTotal = nil
end

function TiantiModel:SetRankPageList(msg)
	SerialiseProtobufList( msg.rankList, function ( item )
		local vo = self.rankList[item.rank]
		if vo then
			vo:Update(item)
		else
			vo = TiantiVo.New(item)
			self.rankList[item.rank] = vo
		end
	end) -- 排行列表
	self.totalNum = msg.totalNum
	self.myRank = msg.myRank
	self.curNum = #self.rankList
	self:DispatchEvent(TiantiConst.Rank_CHANGE)
end
function TiantiModel:ClearRankData()
	self.rankList = {}
	self.curNum = 0
end
function TiantiModel:GetRankPageList()
	return self.rankList or {}
end
function TiantiModel:GetCurNum() -- 当前排行人数
	return self.curNum or 0
end
function TiantiModel:GetTotal() -- 总排行人数
	return self.totalNum or 0
end
function TiantiModel:IsMaxRank() -- 是否达到最多
	return self.curNum < self.totalNum
end
function TiantiModel:GetMyRank() -- 我的排名 0：未上榜
	return self.myRank or 0
end
function TiantiModel:GetMyRankString()
	local s = self:GetMyRank() == 0 and "未上榜" or self.myRank
	return s
end
function TiantiModel:SetTiantiInfo( msg )
	self.infoData = msg
	self.infoData.startTime = toLong(msg.startTime)
	self.infoData.endTime = toLong(msg.endTime)
	self:SetGetStageRewardList(msg, false)
	self:DispatchEvent(TiantiConst.INFO_CHANGE)
end

function TiantiModel:IsOpen()
	local curTime = TimeTool.GetCurTime()
	if curTime >= self.infoData.startTime and curTime < self.infoData.endTime then
		self.isOpen = true
	else
		self.isOpen = false
	end
	return self.isOpen
end

function TiantiModel:GetInfo()
	return self.infoData or {}
end

function TiantiModel:SetOpenType( t )
	self.openType = t or 0
end

function TiantiModel:GetStageCfg( stage )
	return GetCfgData("tiantiStage"):Get(stage)
end
-- 返回名字说明及字体
function TiantiModel:GetRankChar( rank, isMy )
	local font = nil
	if rank>0 then
		if rank<=3 then
			font = TiantiConst.OrderFont[3]
		else
			if isMy then
				font = TiantiConst.OrderFont[2]
			else
				font = TiantiConst.OrderFont[1]
			end
		end
	else
		rank = "未上榜"
	end
	return rank, font
end

function TiantiModel:GetInstance()
	if not TiantiModel.inst then
		TiantiModel.inst = TiantiModel.New()
	end
	return TiantiModel.inst
end
function TiantiModel:__delete()
	TiantiModel.inst = nil
end

function TiantiModel:GetMatchState()
	return self.matchState
end

function TiantiModel:SetMatchState(state)
	if self.matchState and self.matchState ~= state then
		self.matchState = state
		self:DispatchEvent(TiantiConst.E_MATCH_STATE_CHANGE)
	end
end

function TiantiModel:SetLoadPkPlayer(msg)
	local pkPlayers = msg.pkPlayers
	self.playerSelf = nil
	self.playerOther = nil
	if pkPlayers then
		self.pkPlayers = pkPlayers
		local sceneModel = SceneModel:GetInstance()
		for i = 1, #pkPlayers do
			local guid = pkPlayers[i].guid
			if sceneModel:IsMainPlayer(guid) then
				self.playerSelf = pkPlayers[i]
			else
				self.playerOther = pkPlayers[i]
			end
		end
	end
end

function TiantiModel:GetPkPlayerMsg(isSelf)
	if isSelf then
		return self.playerSelf
	else
		return self.playerOther
	end
end

function TiantiModel:GetPkPlayerGuid()
	local msg = self:GetPkPlayerMsg(false)
	if msg then
		return msg.guid
	end
end

function TiantiModel:SetEndPkPlayer(msg)
	local pkPlayers = msg.pkPlayers
	self.endPlayerSelf = nil
	self.endPlayerOther = nil
	if pkPlayers then
		-- self.endPkPlayers = pkPlayers
		-- local sceneModel = SceneModel:GetInstance()
		-- for i = 1, #pkPlayers do
		-- 	local guid = pkPlayers[i].guid
		-- 	if sceneModel:IsMainPlayer(guid) then
		-- 		self.endPlayerSelf = pkPlayers[i]
		-- 	else
		-- 		self.endPlayerOther = pkPlayers[i]
		-- 	end
		-- end
		self.endPlayerSelf = pkPlayers
		GlobalDispatcher:DispatchEvent(EventName.TiantiFinishCutDown)
	end
end

function TiantiModel:GetEndPkPlayerMsg(isSelf)
	if isSelf then
		return self.endPlayerSelf
	else
		return self.endPlayerOther
	end
end
--竞技场使用道具后同步道具数量
function TiantiModel:SetTiantiItemInfo(msg)
	local itemId = msg.itemId
	local num = msg.num
	local itemTab = self:GetPkItemInfo()
	for i = 1, #itemTab do
		if itemTab[i][2] == itemId then
			itemTab[i][3] = num
			self:DispatchEvent(TiantiConst.E_PK_ITEM_CHANGE)
			break
		end
	end
end
--获取已领取奖励的段位列表
function TiantiModel:SetGetStageRewardList(msg, bSendMsg)
	self.gotStages = msg.stages or {}
	table.sort(self.gotStages, function(a, b)
		return a < b
	end)
	if bSendMsg then
		self:DispatchEvent(TiantiConst.E_CF_REWARD_UPDATE)
	end
end
--领取段位奖励
function TiantiModel:SetStageReward(msg)
	local stage = msg.stage
	local pos = 1
	local total = #self.gotStages
	for i = 1, total do
		if stage < self.gotStages[i] then
			break
		else
			pos = pos + 1
		end
	end
	pos = math.min(total + 1, pos)
	table.insert(self.gotStages, pos, stage)
	self:DispatchEvent(TiantiConst.E_CF_REWARD_UPDATE)
end

function TiantiModel:GetItemLev()
	local player1 = self:GetPkPlayerMsg(true) or SceneModel:GetInstance():GetMainPlayer()
	local player2 = self:GetPkPlayerMsg() or self:GetTTPlayerData()
	return math.ceil((player1.level + player2.level) / 2)
end

function TiantiModel:ResetPkItemInfo()
	--local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
	local lev = self:GetItemLev() or 1
	local cfg = GetCfgData("tiantiPkReward"):Get(lev)
	self.pkItemTab = {}
	if cfg then
		self.pkItemTab = clone(cfg.initItem)
	end
	self:DispatchEvent(TiantiConst.E_PK_ITEM_INIT)
end
--获取竞技场道具信息
function TiantiModel:GetPkItemInfo()
	return self.pkItemTab or {}
end
--排位奖励
function TiantiModel:GetRankRewardInfo()
	local curStage = self.infoData.stage or 1
	self:GetScoreCfg()
	self.cfgScore[curStage] = self.cfgScore[curStage] or {}
	return self.cfgScore[curStage].rankReward or {}
end

function TiantiModel:GetScoreCfg()
	if not self.cfgScore then
		local cfg = GetCfgData("tiantiScore")
		self:ParseScoreCfg(cfg)
	end
end

function TiantiModel:ParseScoreCfg(cfg)
	if not cfg then return end
	self.cfgScore = {}
	self.cfgScoreTotal = {}
	for k, v in ipairs(cfg) do
		if v.star == 0 then
			self.cfgScore[v.stage] = v
		end
		self.cfgScoreTotal[v.stage] = self.cfgScoreTotal[v.stage] or {}
		self.cfgScoreTotal[v.stage][v.star] = v
	end
end
--冲锋奖励
function TiantiModel:GetChongfengRewardInfo()
	local gotMaxStage = self.gotStages[#self.gotStages] or 0
	local curStage = self.infoData.stage or 1
	local state = TiantiConst.CF_REWARD_STATE.CANNOT_GET
	local showStage = gotMaxStage + 1
	if curStage > gotMaxStage then
		state = TiantiConst.CF_REWARD_STATE.CAN_GET
	else
		state = TiantiConst.CF_REWARD_STATE.CANNOT_GET
	end
	if showStage == 1 then
		showStage = 2
		if curStage >= 2 then
			state = TiantiConst.CF_REWARD_STATE.CAN_GET
		else
			state = TiantiConst.CF_REWARD_STATE.CANNOT_GET
		end
	end
	return showStage, state
end

function TiantiModel:GetCFRewardData(curStage)
	self:GetScoreCfg()
	self.cfgScore[curStage] = self.cfgScore[curStage] or {}
	return self.cfgScore[curStage]
end

function TiantiModel:GetFightTimesInfo()
	local data = GetCfgData("weekActivity"):Get(104)
	local viplevel = VipModel:GetInstance():GetPlayerVipLV()
	if viplevel > 0 then
		local data = GetCfgData("vipPrivilege"):Get(17)
		local index = "vip"..viplevel
		viplevel = data[index]
	end
	local maxNum = data.maxCount + viplevel
	local gotNum = self.infoData.tiantiNum or 0
	return math.max(maxNum - gotNum, 0), maxNum
end
--主界面积分x/x
function TiantiModel:GetScoreInfo()
	local data = self:GetScoreData()
	if data then
		local total = data.maxScore + 1 - data.minScore
		local score = self.infoData.score or 0
		local cur = score - data.minScore
		return cur, total
	else
		return 0, 100
	end
end

function TiantiModel:GetScoreData(bAllStage)
	self:GetScoreCfg()
	local stage = self.infoData.stage
	if bAllStage then
		return self.cfgScoreTotal[stage]
	else
		local star = self.infoData.star
		return self.cfgScoreTotal[stage][star]
	end
end

function TiantiModel:GetMaxStar()
	local data = self:GetScoreData(true)
	local maxStar = 0
	if data and #data > 0 then
		for k, v in pairs(data) do
			if v.star > maxStar then
				maxStar = v.star
			end
		end
	end
	return maxStar
end

function TiantiModel:SetMatchEnter(state)
	if state and state == 0 then
		self:DispatchEvent(TiantiConst.E_MATCH_ENTER)
	end
end

function TiantiModel:GetCurScore()
	return self.infoData.score or 0
end

function TiantiModel:SetTTPlayerData(data)
	self.ttPlayerData = data
end

function TiantiModel:GetTTPlayerData()
	return self.ttPlayerData
end