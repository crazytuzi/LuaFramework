StrongModel = BaseClass(LuaModel)

function StrongModel:GetInstance()
	if StrongModel.inst == nil then
		StrongModel.inst = StrongModel.New()
	end
	return StrongModel.inst
end

function StrongModel:__init( ... )
	self:Reset()
	self:AddEvent()
end

function StrongModel:Reset()
	self.wakenAverageLv = 0  --注灵平均等级
	self.wakenIsred = false
	self.wakenlvIsFull = false --注灵最低等级是否达到配置(streng 配置表里的 等级上限)
	self.wakenIsFull = false --注灵最低等级是否 达到 角色等级 所能提升的 上限（attUp表里）
	self.skillAverageLv = 0  --技能平均等级
	self.skillIsred = false
	self.skillLvIsFull = false --技能最低等级是否达到配置
	self.skillIsFull = false
	self.equipAverageLv = 0  --装备平均等级
	self.equipIsred = false
end

function StrongModel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()  --全局事件
		self:Reset()
	end)
end

function StrongModel:GetKindLevel()
	local wakenlv = WakanModel:GetInstance():GetWakenTotalLevel()
	self.wakenAverageLv = math.floor(wakenlv/8)	--注灵平均等级
	
	local skilllv = SkillModel:GetInstance():GetSkillLevel()
	self.skillAverageLv = math.floor(skilllv/5)

	local equiplv = PlayerInfoModel:GetInstance():GetEquipLevel()
	self.equipAverageLv = math.floor(equiplv/8)

end

function StrongModel:IsRedStrong()
	local isred = false

	self.wakenIsred = false
	self.wakenlvIsFull = false
	self.skillIsred = false
	self.skillLvIsFull = false

	self.equipIsred = false
	local mainPlayerLev = 0
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayerVo then 
		mainPlayerLev = mainPlayerVo.level 
	end
	local minWakenLv = WakanModel:GetInstance().mini
	local tipsData = self:GetTipsData(3010)
	local lvFull = self:GetWakenLVFull(mainPlayerLev)
	if minWakenLv >= lvFull then
		self.wakenIsFull = true
	else
		self.wakenIsFull = false
	end
	if tipsData then
		for i,v in ipairs(tipsData) do
			if mainPlayerLev >= v[1] then
				if minWakenLv < v[2] then
					self.wakenlvIsFull = true
				end
				if self.wakenAverageLv < v[2] then
					self.wakenIsred = true
				end
			end
		end
	end
	local skillMiniLv = SkillModel:GetInstance().skillMiniLv
	local tipsData = self:GetTipsData(3020)
	local skilllvFull = self:GetSkillLVFull(mainPlayerLev)
	if skillMiniLv >= skilllvFull then
		self.skillIsFull = true
	else
		self.skillIsFull = false
	end
	if tipsData then
		for i,v in ipairs(tipsData) do
			if mainPlayerLev >= v[1] then
				if skillMiniLv < v[2] then
					self.skillLvIsFull = true
				end
				if self.skillAverageLv < v[2] then
					self.skillIsred = true
				end
			end
		end
	end
	local tipsData = self:GetTipsData(3050)
	if tipsData then
		for i,v in ipairs(tipsData) do
			if mainPlayerLev >= v[1] and self.equipAverageLv < v[2] then
				self.equipIsred = true
				break
			end
		end
	end
	--isred = self.wakenIsred or self.skillIsred or self.equipIsred
	--return isred
end

function StrongModel:MainStrongIsEffect()
	return self.wakenIsred or self.skillIsred or self.equipIsred
end

function StrongModel:GetTipsData(id)
	local tipsdata = {}
	local data = GetCfgData("streng"):Get(id)
	if data.tips and #data.tips > 0 then
		for i,v in pairs(data.tips) do
			if type(v) ~= "function" then
				table.insert(tipsdata, v)
			end
		end
	end
	return tipsdata
end

function StrongModel:GetWakenLVFull(playerLv)
	local returnLv = 0
	local data = GetCfgData("attUp")
	if data then
		for i=1, #data do
			if data[i].needLevel == playerLv then
				returnLv = data[i].level
				break
			elseif data[i].needLevel > playerLv then
				if i > 1 then
					returnLv = data[i-1].level
				else
					returnLv = data[i].level
				end
				break
			end
		end
		if returnLv == 0 then
			returnLv = data[#data].level
		end
	end
	return returnLv
end

function StrongModel:GetSkillLVFull(playerLv)
	local retLv = 0
	local data = GetCfgData("streng"):Get(3020).perfectTips
	if data then
		for i=1, #data do
			if data[i][1] == playerLv then
				retLv = data[i][2]
				break
			elseif data[i][1] > playerLv then
				if i > 1 then
					retLv = data[i-1][2]
				else
					retLv = data[i][2]
				end
				break
			end
		end
		if retLv == 0 then
			retLv = data[#data][2]
		end
	end
	return retLv
end

function StrongModel:GetTabData()
	local rtnTabData = {}
	local cfgData = GetCfgData("streng")
	if cfgData then
		for i,v in pairs(cfgData) do
			if type(v) ~= "function" then
				table.insert(rtnTabData, {i, v.standName, v.strengID})
			end
		end
	end
	table.sort(rtnTabData,function(a, b)
		return a[1] < b[1]
	end)
	return rtnTabData
end

function StrongModel:GetItemData(id)
	local tabData = {}
	local data = GetCfgData("streng"):Get(tonumber(id))
	if data.moduleId1 then
		for i,v in ipairs(data.moduleId1) do
			table.insert(tabData, v)
		end
	end
	return tabData
end

function StrongModel:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	StrongModel.inst = nil
end