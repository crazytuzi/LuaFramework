
StyleModel =BaseClass(LuaModel)

function StyleModel:GetInstance()
	if StyleModel.inst == nil then
		StyleModel.inst = StyleModel.New()
	end
	return StyleModel.inst
end

function StyleModel:__init()
	self:Reset()
end

function StyleModel:Reset()
	self.styleData = nil
	self.styleDynamicData = {}
	self.curPutOn = nil
end

function StyleModel:GetStyleData()
	if self.styleData == nil then
		local career = SceneModel:GetInstance():GetMainPlayer().career
		local dataSource = GetCfgData("fashionable")
		local result = {}
		for k, v in pairs(dataSource) do 
			if type(v) ~= "function" and v.career == career then
				table.insert(result, v)
			end
		end
		SortTableByKey(result, "fashionId", true)
		self.styleData = result
	end
	return self.styleData
end

function StyleModel:GetActivedStyleData()
	local career = SceneModel:GetInstance():GetMainPlayer().career
	local dataSource = GetCfgData("fashionable")
	local result = {}
	for k, v in pairs(dataSource) do 
		if type(v) ~= "function" and v.career == career and self:IsActive(v.fashionId) then
			table.insert(result, v)
		end
	end
	SortTableByKey(result, "fashionId", true)
	return result
end

function StyleModel:GetStyleCfgById(fashionId)
	return GetCfgData("fashionable"):Get(fashionId)
end

function StyleModel:GetActiveCount()
	local result = 0
	for k,v in pairs(self.styleDynamicData) do
		result = result + 1
	end
	return result
end

function StyleModel:IsActive(fashionId)
	return self:GetStyleDynamicData(fashionId) ~= nil
end

function StyleModel:IsPutOn(fashionId)
	return self:GetStyleDynamicData(fashionId) and self:GetStyleDynamicData(fashionId).dressFlag == 1
end

function StyleModel:GetStyleDynamicData(fashionId)
	return self.styleDynamicData[fashionId]
end

function StyleModel:AddStyle(data)
	local vo = StyleDynamicVo.New()
	vo.fashionId = data.fashionId
	vo.dressFlag =0	
	self.styleDynamicData[vo.fashionId] = vo
	local cfg = self:GetStyleCfgById(data.fashionId)
	self:DispatchEvent(StyleConst.StyleActive, cfg)
end

function StyleModel:ParseSynStyleData(data)
	SerialiseProtobufList(data.fashionList, function(item)
			local vo = StyleDynamicVo.New()
			vo.fashionId = item.fashionId
			vo.dressFlag = item.dressFlag	
			if vo.dressFlag == 1 then
				self.curPutOn = item.fashionId
			end
			self.styleDynamicData[vo.fashionId] = vo
	end)
	self:DispatchEvent(StyleConst.StyleDataReadyOk)
end

function StyleModel:PutOnStyle(data)
	if self.curPutOn and self.styleDynamicData[self.curPutOn] then
		self.styleDynamicData[self.curPutOn].dressFlag = -1
	end

	self.curPutOn = data.fashionId
	self.styleDynamicData[self.curPutOn].dressFlag = 1
	self:DispatchEvent(StyleConst.StyleDataUpdateOk)
end

function StyleModel:PutDownStyle(data)
	if self.styleDynamicData[data.fashionId] then
		self.styleDynamicData[data.fashionId].dressFlag = -1
	end
	self.curPutOn = -1
	self:DispatchEvent(StyleConst.StyleDataUpdateOk)
end

function StyleModel:__delete()
	self.styleData = nil

	StyleModel.inst = nil
end