RechargeModel = BaseClass(LuaModel)

function RechargeModel:__init( ... )
	self:Reset()
	self:AddEvent()
end

function RechargeModel:Reset()
	self.dailyRecharge = 0
	self.isbuyGrowthFund = 0
	self.buyGrowthFundNum = 0

	self.lv = 0

	self.dailyRewardState = {}
	self.growRewardState = {}
	self.allRewardState = {}

	self.lastShowRedTipsFlag = false
	self:ResetTombData()
	self:ResetTurnData()
	self:ResetSevenData()
end

function RechargeModel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener( EventName.BuyJiJinSuccess, function()
		self.isbuyGrowthFund = 1
		self.buyGrowthFundNum = self.buyGrowthFundNum + 1
		self:DispatchEvent(RechargeConst.SuccessJiJinBuy)
	end)	
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()
		self:Reset()
	end)
end

function RechargeModel:GetMainPlayerLv()
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	local lv = 0
	if mainPlayerVo then
		lv = mainPlayerVo.level
	end
	return lv
end

function RechargeModel:GetGrowJJResNum()
	local resNum = 0
	local data = GetCfgData("constant"):Get(49)
	if data then
		resNum = data.value
	end
	return resNum
end

function RechargeModel:GetGrowJJID()
	local cfgData = GetCfgData("charge")
	for k , v in pairs(cfgData) do
		if type(v) ~= 'function' and v and v.type == RechargeConst.RechargeType.GrowUpJijin then
			return v.id
		end
	end
end

function RechargeModel:GetPanelTabData()
	local rtnTabData = {}
	local cfgData = GetCfgData("system"):Get(6)
		if cfgData then
			cfgData = cfgData.data
			for i = 1, #cfgData do
				local cfgInfo = StringSplit(cfgData[i], "_")
				table.insert(rtnTabData, {cfgInfo[1], cfgInfo[2]})
			end
		end
	return rtnTabData
end

function RechargeModel:GetDailyRechargeTabData()
	local rtnTabDataDaily = {}
	-- for i=4, 10 do
	-- 	local cfgData = GetCfgData("reward"):Get(i)
	-- 	if cfgData then
	-- 		table.insert(rtnTabDataDaily, {cfgData.condition, cfgData.reward, cfgData.id})
	-- 	end
	-- end

	local allRewardCfg = GetCfgData("reward")
	for k , v in pairs(allRewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.DailyAccumulatedRecharge then
			table.insert(rtnTabDataDaily, {v.condition, v.reward, v.id})
		end
	end

	table.sort(rtnTabDataDaily , function(a , b)
		return a[3] < b[3]
	end)

	return rtnTabDataDaily
end

function RechargeModel:GetGrowJijinTabData()  --成长基金数据
	local rtnTabDataGrow = {}
	-- for i=13, 19 do
	-- 	local cfgData = GetCfgData("reward"):Get(i)
	-- 	if cfgData then
	-- 		table.insert(rtnTabDataGrow, {cfgData.condition, cfgData.reward, cfgData.id})
	-- 	end
	-- end

	local allRewardCfg = GetCfgData("reward")
	for k , v in pairs(allRewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.GrowthFund then
			table.insert(rtnTabDataGrow, {v.condition, v.reward, v.id})
		end
	end

	table.sort(rtnTabDataGrow , function(a , b)
		return a[3] < b[3]
	end)

	return rtnTabDataGrow
end

function RechargeModel:GetAllTabData()
	local rtnTabDataAll = {}
	-- for i=20, 26 do
	-- 	local cfgData = GetCfgData("reward"):Get(i)
	-- 	if cfgData then
	-- 		table.insert(rtnTabDataAll, {cfgData.condition, cfgData.reward, cfgData.id})
	-- 	end
	-- end

	local allRewardCfg = GetCfgData("reward")
	for k , v in pairs(allRewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.GeneralWelfare then
			table.insert(rtnTabDataAll, {v.condition, v.reward, v.id})
		end
	end

	table.sort(rtnTabDataAll , function(a , b)
		return a[3] < b[3]
	end)

	return rtnTabDataAll
end

function RechargeModel:IsDailyRechargeRed()
	local isRed = false
	local canLqTab = {}
	local tab = self:GetDailyRechargeTabData()
	for i,v in ipairs(tab) do
		if self.dailyRecharge >= v[1] then
			table.insert(canLqTab, v)
		end
	end
	if #canLqTab <= 0 then
		isRed = false
	else
		if #self.dailyRewardState <= 0 then
			isRed = true
		else
			if #self.dailyRewardState >= #canLqTab then
				isRed = false
			else
				isRed = true
			end
		end
	end
	return isRed
end

--基金红点--
function RechargeModel:IsJijinRed()
	local isRed = false
	local canLQJj = {}
	local lv = self:GetMainPlayerLv()
	local tab = self:GetGrowJijinTabData()
	if self.isbuyGrowthFund == 0 then
		isRed = false
	else
		for i,v in ipairs(tab) do
			if lv >= v[1] then
				table.insert(canLQJj, v)
			end
		end
		if #canLQJj <= 0 then
			isRed = false
		else
			if #self.growRewardState <= 0 then
				isRed = true
			else
				if #self.growRewardState >= #canLQJj then
					isRed = false
				else
					isRed = true
				end
			end
		end
	end
	return isRed
end
--

function RechargeModel:IsAllWelfareRed()
	local isRed = false
	local canLQ = {}
	local tab = self:GetAllTabData()
	for i,v in ipairs(tab) do
		if self.buyGrowthFundNum >= v[1] then
			table.insert(canLQ, v)
		end
	end
	if #canLQ <= 0 then
		isRed = false
	else
		if #self.allRewardState <= 0 then
			isRed = true
		else
			if #self.allRewardState >= #canLQ then
				isRed = false
			else
				isRed = true
			end
		end
	end
	return isRed
end

function RechargeModel:ShowRedTips()
	--local cardRed = MonthCardModel:GetInstance():GetRed()
	local dailyRed = self:IsDailyRechargeRed()
	local growUpRed = self:IsJijinRed()
	local allRed = self:IsAllWelfareRed()
	local totalRed = TotalRechargeModel:GetInstance():IsHasRewardCanGet()
	local consumRed = ConsumModel:GetInstance():IsHasCanGet()
	local turnRed = self:GetTurnRed()
	local sevenRed = self:GetSevenRed()

	local isShowRed = dailyRed or growUpRed or allRed or totalRed or consumRed or turnRed or sevenRed
	--if self.lastShowRedTipsFlag ~= isShowRed then
	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS, {moduleId = FunctionConst.FunEnum.carnival , state = isShowRed })
	self.lastShowRedTipsFlag = isShowRed
	--end
end

function RechargeModel:GetInstance()
	if RechargeModel.inst == nil then
		RechargeModel.inst = RechargeModel.New()
	end
	return RechargeModel.inst
end

function RechargeModel:__delete()                                --清除
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	RechargeModel.inst = nil
end

-- 陵墓part
function RechargeModel:ResetTombData()
	self.tombIdList = {}
	self.newTombIdList = {}
	self.KEY_CURLAYER = nil
end

function RechargeModel:HandleGetTomb(msg)
	self.newTombIdList = {}
	self:HandleTombList(msg)
	self:HandleTombNums(msg)
	self:InitGotList()
	self:DispatchEvent(RechargeConst.E_GetTombData)
end

function RechargeModel:InitGotList()
	local keys = {}
	for i = 1, #self.usedTombIdList do
		if self.usedTombIdList[i] > 0 then
			table.insert(keys, i)
		end
	end
	self.tombGotList = {}
	for i = 1, #keys do
		local idx = keys[i]
		local id = self.tombIdList[idx]
		if id then
			self.tombGotList[id] = true
		end
	end
end

function RechargeModel:AddToGotList(tombId)
	self.tombGotList = self.tombGotList or {}
	self.tombGotList[tombId] = true
end

function RechargeModel:IsTombIdGot(tombId)
	--return self.tombGotList[tombId]
	for i = 1, #self.usedTombIdList do
		if self.usedTombIdList[i] > 0 and self.usedTombIdList[i] == tombId then
			return true
		end
	end
	return false
end

function RechargeModel:HandleTombList(msg)
	self.tombIdList = msg.tombIdList or {}
	self.usedTombIdList = msg.usedTombIdList or {}
end

function RechargeModel:HandleTombNums(msg)
	self.tombNum = msg.tombNum or 0
	self.greenNum = msg.greenNum or 0
	self.blueNum = msg.blueNum or 0
	self.violetNum = msg.violetNum or 0
	self.orangeNum = msg.orangeNum or 0
	self.tombNums = { self.tombNum, self.greenNum, self.blueNum, self.violetNum, self.orangeNum }
end

function RechargeModel:HandleTombResult(msg)
	local tombIndex = msg.tombIndex or 0
	self.usedTombIdList[tombIndex + 1] = msg.tombId
	local tombId = msg.tombId or 0
	self:AddToGotList(tombId)
	self.newTombIdList = self.newTombIdList or {}
	self.newTombIdList[tombIndex + 1] = tombId
	self:HandleTombNums(msg)
	self:DispatchEvent(RechargeConst.E_TombResult, tombIndex + 1)
end

function RechargeModel:HandleChangeTomb(msg)
	self:HandleTombList(msg)
	self:SetTombLayer(self:GetTombLayer() + 1)
	self:InitGotList()
	self:DispatchEvent(RechargeConst.E_ChangeTomb)
end

function RechargeModel:GetTombIdList()
	return self.tombIdList
end

function RechargeModel:GetTombNums()
	return self.tombNums or {}
end

function RechargeModel:GetCellState(idx)
	if self.usedTombIdList[idx] == 0 then
		return RechargeConst.TombCellState.NotFinish
	else
		return RechargeConst.TombCellState.Finish
	end
end

-- function  RechargeModel:GetCellStateById(id)
-- 	local idx = self:GetTombIdxById(id)
-- 	return self:GetCellState(idx)
-- end

function RechargeModel:GetTombIdxById(id)
	for k, v in ipairs(self.tombIdList) do
		if v == id then
			return k
		end
	end
	return 1
end

function RechargeModel:GetCellData(idx)
	--local idList = self.tombIdList
	local id = self.newTombIdList[idx] or self.usedTombIdList[idx] --idList[idx]
	return GetCfgData("tomb"):Get(id)
end

function RechargeModel:GetChangeCost()
	if self:IsTombFinish() then
		return 0
	else
		local cfg = GetCfgData("constant"):Get(43)
		if cfg then
			return cfg.value or 10
		end
	end
	return 0
end

-- 当前层是否探索完
function RechargeModel:IsTombFinish()
	return RechargeConst.kMaxCellNum <= self:GetFinishCellNum()
end

function RechargeModel:GetFinishCellNum()
	local cnt = 0
	for _, v in ipairs(self.usedTombIdList) do
		if v and v > 0 then
			cnt = cnt + 1
		end
	end
	return cnt
end
-- 拥有的摸金令数量
function RechargeModel:GetOwnItems()
	local tmp = RechargeConst.TOMB_COST_TAB
	local constData = GetCfgData("constant")
	local numTab = {}
	for i = 1, #tmp do
		local cfg = constData:Get(tmp[i])
		if cfg then
			numTab[i] = numTab[i] or {}
			numTab[i].id = cfg.value or 0
			numTab[i].num = PkgModel:GetInstance():GetTotalByBid(numTab[i].id)
		end
	end
	return numTab
end
-- 消耗的摸金令
function RechargeModel:GetCostItem()
	local num = self:GetFinishCellNum()
	local tab = RechargeConst.TOMB_COST_TAB
	local id = nil
	local tmp = RechargeConst.kMaxCellNum / 3
	if num < tmp then
		id = tab[1]
	elseif num < tmp * 2 then
		id = tab[2]
	else
		id = tab[3]
	end
	local costNum = math.pow(2, num % 3)
	local constData = GetCfgData("constant"):Get(id)
	return {constData.value, costNum}
end

function RechargeModel:GetSortedIdList()
	local idList = clone(self.tombIdList)
	local tombData = GetCfgData("tomb")
	local cfg = GetCfgData("item")
	table.sort(idList, function(a, b)
		local data1 = tombData:Get(a)
		local data2 = tombData:Get(b)
		local dataA = cfg:Get(data1.itemId)
		local dataB = cfg:Get(data2.itemId)
		return dataA.rare > dataB.rare
	end)
	return idList
end

function RechargeModel:GetLayerSaveKey()
	if not self.KEY_CURLAYER then
		local playerVo = SceneModel:GetInstance():GetMainPlayer()
		self.KEY_CURLAYER = StringFormat("{0}_{1}", playerVo.eid, RechargeConst.KEY_CURLAYER)
	end
	return self.KEY_CURLAYER
end

function RechargeModel:GetTombLayer()
	local key = self:GetLayerSaveKey()
	local layerNum = DataMgr.ReadData(key, -1)
	if layerNum == -1 then
		-- 初始
		DataMgr.WriteData(key, 1)
		return 1
	else
		return layerNum
	end
end

function RechargeModel:SetTombLayer(num)
	local key = self:GetLayerSaveKey()
	if num > #RechargeConst.TombName then
		num = 1
	end
	DataMgr.WriteData(key, num)
end

-- 转盘part
function RechargeModel:ResetTurnData()
	self.turnRetData = {}
	self.trIdList = nil
end
function RechargeModel:OnGetTurntableData(msg)
	self.fristTurntableState = msg.fristTurntableState --首次转盘抽奖状态 (0: 未使用, 1:已使用)
	self.trIdList = msg.trIdList or {} --转盘奖励
	self:DispatchEvent(RechargeConst.E_GetTurntableData)
end

function RechargeModel:OnTurntableDraw(msg)
	self.fristTurntableState = 1
	self.turnRewardId = msg.rewardId or 1 --抽中的奖励ID
	self:DispatchEvent(RechargeConst.E_TurntableDraw, self.turnRewardId)
	GlobalDispatcher:DispatchEvent(EventName.TurnRedChange)
end

function RechargeModel:OnGetTurnRecList(msg)
	local turnRecList = msg.turnRecList or {}	--转盘奖励榜单列表
	local idx, offset = self:GetTurnRetListIdx()
	if idx == RechargeConst.TURN_LIST_START_IDX then
		self.turnRetData = {}
		self:DispatchEvent(RechargeConst.E_ResetTurnContent)
	end
	local cur = 1
	for i = idx, idx + offset - 1 do
		if turnRecList[cur] then
			self.turnRetData[i] = turnRecList[cur]
			cur = cur + 1
		end
	end
	self:DispatchEvent(RechargeConst.E_GetTurnRecList, turnRecList)
end

function RechargeModel:GetTurnFirstState()
	return self.fristTurntableState or 0
end

function RechargeModel:SetTurnRetListIdx(start, offset)
	offset = offset or self:GetHistoryOnePageNum()
	self.turnRetListIdx = self.turnRetListIdx or {}
	self.turnRetListIdx.start = start
	self.turnRetListIdx.offset = offset
end

function RechargeModel:GetTurnRetListIdx()
	self.turnRetListIdx = self.turnRetListIdx or {}
	return self.turnRetListIdx.start or 0, self.turnRetListIdx.offset or self:GetHistoryOnePageNum()
end

function RechargeModel:GetTurnRetInfoByIdx(idx)
	local data = self.turnRetData[idx]
	if data then
		return { toLong(data.playerId), data.playerName, data.rewardId }
	end
end

function RechargeModel:GetTurnCost()
	if self.fristTurntableState == 0 then return RechargeConst.TurnCostType.Free end
	local cfg = GetCfgData("constant"):Get(42)
	local itemId = nil
	if cfg then
		itemId = cfg.value
	end
	if itemId then
		local num = PkgModel:GetInstance():GetTotalByBid(itemId)
		if num and num > 0 then
			return RechargeConst.TurnCostType.Item, RechargeConst.TURN_ITEM_COST, itemId
		end
	end
	return RechargeConst.TurnCostType.Diamond, self:GetTurnDiamondCost()
end

function RechargeModel:GetTurnDiamondCost()
	local cfg = GetCfgData("constant"):Get(44)
	if cfg then
		return cfg.value
	end
	return 10
end

function RechargeModel:GetHistoryOnePageNum()
	-- local cfg = GetCfgData("constant"):Get(45)
	-- if cfg then
	-- 	return cfg.value
	-- end
	-- return 10
	return 7
end

function RechargeModel:GetHistoryMaxNum()
	local cfg = GetCfgData("constant"):Get(46)
	if cfg then
		return cfg.value
	end
	return 30
end

function RechargeModel:GetTurnRetData()
	return self.turnRetData or 0
end

function RechargeModel:GetRewardListById(rewardId)
	return GetCfgData("payActivityTurntableCfg"):Get(tonumber(rewardId)).reward or {}
end

function RechargeModel:GetItemsData()
	return self.trIdList or {}
end

function RechargeModel:GetRewardIndex(id)
	for i = 1, #self.trIdList do
		if self.trIdList[i] == id then
			return i
		end
	end
	return 1
end

function RechargeModel:GetRewardIdByIndex(index)
	return self.trIdList[index]
end

function RechargeModel:CheckNeedBroadcast(rewardId)
	local isBroadcast = GetCfgData("payActivityTurntableCfg"):Get(rewardId).isBroadcast
	if isBroadcast and isBroadcast == 1 then
		return true
	else
		return false
	end
end

function RechargeModel:GetTurnRed()
	return self.fristTurntableState == 0
end

-- 七天累计充值
function RechargeModel:OnGetSevenPayData(msg)
	self.sevenPay = msg.sevenPay or 0 --累计充值金额

	self.rewardList = msg.rewardList or {} --已领取累计登录奖励
	-- print("rrr==>>")
	-- for i  =1, #self.rewardList do
	-- 	print(self.rewardList[i])
	-- end
	self:DispatchEvent(RechargeConst.E_GetSevenPayData)
end

function RechargeModel:GetSevenRechargeNum()
	return self.sevenPay
end

function RechargeModel:ResetSevenData()
	self.sevenCfgData = nil
	self:GetSevenCfgData()
end
-- 缓存数据表,并将表中的时间转为毫秒时间戳
function RechargeModel:GetSevenCfgData()
	if not self.sevenCfgData then
		self.sevenCfgData = {}
		local cfg = GetCfgData("chargeActivity") or {}
		for k, v in pairs(cfg) do
			if type(v) ~= 'function' then
				self.sevenCfgData[k] = clone(v)
				self.sevenCfgData[k].startDate = self:GetMilliStampByStr(self.sevenCfgData[k].startDate)
				self.sevenCfgData[k].endDate = self:GetMilliStampByStr(self.sevenCfgData[k].endDate)
			end
		end
	end
end

function RechargeModel:GetMilliStampByStr(str)
	if TimeTool.GetTimeByYYMMDD_HHMMSS(str) ~= nil then
		return TimeTool.GetTimeByYYMMDD_HHMMSS(str) * 1000
	else
		return 1
	end
end

-- 七日充值当前状态
function RechargeModel:GetSevenState()
	self:GetSevenCfgData()
	local curTime = TimeTool.GetCurTime()
	local tabKey = {}
	for k, v in pairs(self.sevenCfgData) do
		if curTime >= v.startDate and curTime < v.endDate then
			return RechargeConst.SevenState.Open, k
		end
		table.insert(tabKey, k)
	end
	table.sort(tabKey, function(v1, v2)
		return v1 < v2
	end)
	local idx = 1
	for i = 1, #tabKey do
		if self.sevenCfgData[tabKey[i]].startDate >= curTime then
			idx = tabKey[i]
			break
		end
	end
	return RechargeConst.SevenState.NotOpen, idx
end

function RechargeModel:IsSevenRewardGot(rewardId)
	if not self.rewardList then return false end
	for i = 1, #self.rewardList do
		if self.rewardList[i] == rewardId then
			return true
		end
	end
	return false
end

function RechargeModel:IsAllRewardGot()
	self.rewardList = self.rewardList or {}
	return #self.rewardList >= 3
end

function RechargeModel:IsRewardCanGet(rewardId, idx)
	local num = self:GetSevenRechargeNum()
	local destNum = GetCfgData("reward"):Get(rewardId).condition
	if num >= destNum and (not self:IsSevenRewardGot(rewardId)) then
		return true
	end
	return false
end

function RechargeModel:GetSevenRed()
	return ( not self:IsSevenReadToday() ) and ( not self:IsAllRewardGot() )
end

function RechargeModel:GetSevenRedSaveKey()
	if not self.KEY_SEVEN_RED then
		local playerVo = SceneModel:GetInstance():GetMainPlayer()
		self.KEY_SEVEN_RED = StringFormat("{0}_{1}", playerVo.eid, RechargeConst.KEY_SEVEN_RED)
	end
	return self.KEY_SEVEN_RED
end

function RechargeModel:IsSevenReadToday()
	if not SceneModel:GetInstance():GetMainPlayer() then return true end
	local key, lastDate, curDate = self:GetSevenReadParams()
	--print("curDate ==>> ", curDate)
	if lastDate == "0" then
		-- 初始
		--DataMgr.WriteData(key, curDate)
		return false
	elseif curDate == lastDate then
		return true
	else
		return false
	end
end

function RechargeModel:GetSevenReadParams()
	local key = self:GetSevenRedSaveKey()
	local lastDate = DataMgr.ReadData(key, "0")
	local curDate = TimeTool.getYMD(TimeTool.GetCurTime())
	return key, lastDate, curDate
end

function RechargeModel:SetSevenRead()
	local key, lastDate, curDate = self:GetSevenReadParams()
	DataMgr.WriteData(key, curDate)
end

function RechargeModel:GetTimeMDByStr(str)
	local tab = StringSplit(str, " ")
	tab = StringSplit(tab[1], "-")
	return self:TrimFirstZero(tab[2]), self:TrimFirstZero(tab[3])
end

function RechargeModel:TrimFirstZero(str)
	if string.sub(str, 1, 1) == '0' then
		str = string.sub(str, 2, -1)
	end
	return str
end

function RechargeModel:GetRewardListByRewardId(rewardId)
	local list = GetCfgData("reward"):Get(tonumber(rewardId)) or {}
	return list.reward or {}
end

function RechargeModel:TransRewardToVo(rewardList)
	local tab = {}
	for i = 1, #rewardList do
		local rewardTab = rewardList[i]
		local vo = GoodsVo.New()
		vo:SetCfg(rewardTab[1], rewardTab[2], rewardTab[3], rewardTab[4])
		tab[i] = vo
	end
	return tab
end