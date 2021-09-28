
MallModel =BaseClass(LuaModel)


MallModel.Type = {
	Consume = 1,   --消耗
	Material = 2,  --材料
	Equipment = 3, --装备
}

MallModel.TypeName = {
	[1] = "消耗",   --消耗
	[2] = "材料",   --材料
	[3] = "装备",   --装备
}

MallModel.Tabs = {MallModel.Type.Consume, MallModel.Type.Material, MallModel.Type.Equipment}

function MallModel:GetInstance()
	if MallModel.inst == nil then
		MallModel.inst = MallModel.New()
	end
	return MallModel.inst
end

function MallModel:__init()
	--self.buyInfoList = {}
	--self.tabData = nil
	self:Reset()
	self:AddEvent()
	self.tab67State = true
end

function MallModel:Reset()--------------------------
	self.buyInfoList = {}
	self.tabData = nil		
	self.tab67State = true
end 					  --------------------------

function MallModel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()
		self:Reset()
	end)
end                       --------------------------

function MallModel:GetTabCfgData()
	if self.tabData == nil then
		self.tabData = {}
		local cfgData = GetCfgData("system"):Get(1)
		if cfgData then
			cfgData = cfgData.data
			local result = {}
			for i = 1, #cfgData do
				local cfgInfo = StringSplit(cfgData[i], "_")
				table.insert(result, {cfgInfo[1], cfgInfo[2]})
			end
			self.tabData = result
		end
	end
	return self.tabData
end

function MallModel:GetDataByType(tabType)
	local dataSource = GetCfgData("market")
	local result = {}
	for k, v in pairs(dataSource) do 
		if type(v) ~= "function" then
			local canShow = true
			if v.onTime ~= "" and v.downTime ~= "" then
				local startTime = TimeTool.GetTimeByYYMMDD_HHMMSS(v.onTime)
				local endTime = TimeTool.GetTimeByYYMMDD_HHMMSS(v.downTime)
				local curTime = TimeTool.GetCurTime()*0.001 --服务器时间
				if curTime > startTime and curTime < endTime then
					canShow = true
				else
					canShow = false
				end
			end
			if canShow and v.pageId == tonumber(tabType) and self:IsMappingCareer(v) then
				table.insert(result, v)
			end
		end
	end
	SortTableByKey(result, "marketId", true)
	return result
end

function MallModel:QuickIndex(marketId)
	local dataSource = GetCfgData("market")
	local result = {}
	for k, v in pairs(dataSource) do 
		if type(v) ~= "function" then
			local canShow = true
			if v.onTime ~= "" and v.downTime ~= "" then
				local startTime = TimeTool.GetTimeByYYMMDD_HHMMSS(v.onTime)
				local endTime = TimeTool.GetTimeByYYMMDD_HHMMSS(v.downTime)
				local curTime = TimeTool.GetCurTime()*0.001 --服务器时间
				if curTime > startTime and curTime < endTime then
					canShow = true
				else
					canShow = false
				end
			end
			if canShow and v.marketId == marketId then
				return v
			end
		end
	end
	return nil
end

function MallModel:IsMappingCareer(marketVo)
	local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
	local goodVo = GoodsVo.GetCfg(marketVo.itemType, marketVo.itemId)
	if goodVo and (goodVo.needJob == 0 or (goodVo.needJob ~= 0 and goodVo.needJob == mainPlayer.career)) then
		return true
	end
	return false
end

function MallModel:SetBuyInfoByList(lsit)
	SerialiseProtobufList(lsit, function(info)
		self:SetBuyInfo(info.marketId, info.curBuyNum)
	end)
end

function MallModel:SetBuyInfo(marketId, curBuyNum)
	self.buyInfoList[marketId] = curBuyNum
end

function MallModel:GetBuyInfo(marketId)
	return self.buyInfoList[marketId]
end

function MallModel:IsWingOrStyleActive(itemId)
	local rtnIsActive = false
	local rtnActiveType = MallConst.ActiveType.None
	if itemId then
		local wingCfg = WingModel:GetInstance():GetWingCfgById(itemId)
		local styleCfg = StyleModel:GetInstance():GetStyleCfgById(itemId)
		if wingCfg and styleCfg then print("策划配置表出错，羽翼表和时装表里有相同的key " , itemId) end
		if wingCfg then
			if WingModel:GetInstance():IsActive(itemId) then
				rtnIsActive = true
				rtnActiveType = MallConst.ActiveType.Wing
			end
		end

		if styleCfg then
			if StyleModel:GetInstance():IsActive(itemId) then
				rtnIsActive = true
				rtnActiveType = MallConst.ActiveType.Style
			end
		end
	end
	return rtnIsActive , rtnActiveType
end

function MallModel:SetTab67State(state)
	self.tab67State = state
end

function MallModel:GetTab67State()
	return self.tab67State
end

function MallModel:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)

	self.tabData = nil
	self.buyInfoList = nil

	MallModel.inst = nil
end