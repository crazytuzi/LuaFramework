
WingModel =BaseClass(LuaModel)

WingModel.CostProps = {35013, 35014, 35015, 35016}
WingModel.NewActive = nil

function WingModel:GetInstance()
	if WingModel.inst == nil then
		WingModel.inst = WingModel.New()
	end
	return WingModel.inst
end

function WingModel:__init()
	self:Reset()
	self:AddEvent()
	self.isUp = 1           ------------
	self.totalWingValue = 0
	self.type = 2   --羽化类型
end

function WingModel:Reset()
	self.wingData = nil

	self.wingDynamicData = {}
	self.curPutOn = nil
end

function WingModel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()
		self:Reset()
	end)
end

function WingModel:HasCostItem()
	local count = 0
	for i = 1, #WingModel.CostProps do
		count = count + PkgModel:GetInstance():GetTotalByBid(WingModel.CostProps[i])
	end

	return count > 0
end

function WingModel:HasNumCost(i)
	local num = 0
	if PkgModel:GetInstance():GetTotalByBid(i) then
		num = PkgModel:GetInstance():GetTotalByBid(i)
	end
	return num
end

function WingModel:GetWingDynamicData(wingId)
	return self.wingDynamicData[wingId]
end

function WingModel:GetWingData()
	if self.wingData == nil then
		local dataSource = GetCfgData("wing")
		local result = {}
		for k, v in pairs(dataSource) do 
			if type(v) ~= "function" then
				table.insert(result, v)
			end
		end
		SortTableByKey(result, "wingId", true)
		self.wingData = result
	end
	return self.wingData
end

function WingModel:GetWingMaxData(wingId)
	local data = GetCfgData("wing"):Get(wingId)
	local maxData = {}
	if data.upStarStr[#data.upStarStr] and data.baseProperty then
		table.insert(maxData, {data.upStarStr[#data.upStarStr], data.baseProperty})
	end
	return maxData
end

function WingModel:GetWingCfgById(wingId)
	return GetCfgData("wing"):Get(wingId)
end

function WingModel:GetActiveCount()
	local result = 0
	for k,v in pairs(self.wingDynamicData) do
		result = result + 1
	end
	return result
end

function WingModel:GetTotalCount()
	local result = 0
	for k,v in pairs(self.wingData) do
		result = result + 1
	end
	return result
end

function WingModel:IsActive(wingId)
	return self:GetWingDynamicData(wingId) ~= nil
end

function WingModel:IsPutOn(wingId)
	return self:GetWingDynamicData(wingId) and self:GetWingDynamicData(wingId).dressFlag == 1
end

function WingModel:ActiveWing(data)
	local vo = WingDynamicVo.New()
	vo.wingId = data.wingId
	vo.star = 0
	vo.wingValue = 0
	vo.dressFlag = 0	
	WingModel.NewActive = vo
	self.wingDynamicData[vo.wingId] = vo
	self:DispatchEvent(WingConst.DataReadyOk)
end

function WingModel:ParseSynWingData(data)
	SerialiseProtobufList(data.listWing, function(item)
			local vo = WingDynamicVo.New()
			vo.wingId = item.wingId
			vo.star = item.star	
			vo.wingValue = item.wingValue	
			vo.dressFlag = item.dressFlag	
			if vo.dressFlag == 1 then
				self.curPutOn = item.wingId
			end
			self.wingDynamicData[vo.wingId] = vo
	end)
	self.totalWingValue = data.totalWingValue
	self:DispatchEvent(WingConst.DataReadyOk)
end

function WingModel:ParseEvolveData(data)
	local vo = WingDynamicVo.New()
	vo.wingId = data.wingMsg.wingId
	vo.star = data.wingMsg.star	
	vo.wingValue = data.wingMsg.wingValue	
	vo.dressFlag = data.wingMsg.dressFlag	
	self.wingDynamicData[vo.wingId] = vo
	self.totalWingValue = data.totalWingValue
	self.isUp = 1
	
	self:DispatchEvent(WingConst.DataUpdateOk)
end

function WingModel:PutOnWing(data)
	if self.curPutOn and self.wingDynamicData[self.curPutOn] then
		self.wingDynamicData[self.curPutOn].dressFlag = -1
	end

	self.curPutOn = data.wingId
	self.wingDynamicData[self.curPutOn].dressFlag = 1
	self:DispatchEvent(WingConst.DataUpdateOk)

end

function WingModel:PutDownWing(data)
	if self.wingDynamicData[data.wingId] then
		self.wingDynamicData[data.wingId].dressFlag = -1
	end
	self.curPutOn = -1
	self:DispatchEvent(WingConst.DataUpdateOk)
end

function WingModel:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	self.wingData = nil
	self.wingDynamicData = nil
	self.isUp = 0                --------------
	WingModel.inst = nil
	WingModel.NewActive = nil
end

function WingModel:GetActiveWingIds()
	if not self.wingDynamicData then return end
	local tab = {}
	for wingId, vo in pairs(self.wingDynamicData) do
		if vo then
			tab[wingId] = true
		end
	end
	return tab
end