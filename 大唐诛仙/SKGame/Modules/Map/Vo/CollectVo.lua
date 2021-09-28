CollectVo =BaseClass(PuppetVo)

function CollectVo:__init()
	self.playerCollectId = -1 --前后端标识的唯一采集编号
	self.collectId = -1 --配置表中的采集编号
	self.position = Vector3.New(0, 0, 0) --采集位置
	self.modelId = ""
	self.type = PuppetVo.Type.Collect
	self.collectType = SceneConst.CollectType.None
	self.collectTime = 0 --采集读条时间
	self.id = 0
end

function CollectVo:SetModelRes()
	local collectCfg = self:GetCfg(self.collectId)
	if collectCfg then
		self.modelId = collectCfg.resId or ""
	end
end

function CollectVo:SetCollectPosition()
	if self.collectId ~= -1 then
		local collectCfg = GetCfgData("collect")
		local curCollectInfo = collectCfg:Get(self.collectId)
		if curCollectInfo ~= nil then
			if not TableIsEmpty(curCollectInfo.position) then
				self.position = Vector3.New(curCollectInfo.position[1] or 0, curCollectInfo.position[2] or 0, curCollectInfo.position[3] or 0)
			end
		end
	end
end

function CollectVo:ToString()
	
end

function CollectVo:InitVo(attrs)
	for k,v in pairs(attrs) do
		if type(v) ~= "function" and k ~="_class_type" then
			self[k] = v
		end
	end
	self:SetCollectTime()
	self:SetId()
	self:SetCollectType()
	self:SetModelRes()
	self:SetCollectPosition()
	self:UsedDispatchChange(true)
	self.isComplete = true

end

function CollectVo:SetCollectType()
	local collectCfg = self:GetCfg(self.collectId)
	if collectCfg then
		self.collectType = collectCfg.type or SceneConst.CollectType.None
	end
end

function CollectVo:SetId()
	self.eid = self.playerCollectId or 0
end

function CollectVo:GetCollectType()
	return self.collectType
end


function CollectVo:SetCollectTime()
	local collectCfg = self:GetCfg(self.collectId)
	if collectCfg then
		self.collectTime = collectCfg.collectTime or 0
	end
end

function CollectVo:GetCollectTime()
	return self.collectTime
end

function CollectVo:UpdateVo(attrs)
	
	for k, v in pairs(attrs) do
		if type(k) ~= "function" and k ~= "_class_type" then
			-- body
			if self[k] then
				self:SetValue(k, v, self[k])
			end
		end
	end

	self:SetCollectTime()
	self:SetId()
	self:SetCollectType()
	self:SetModelRes()
	self:SetCollectPosition()
	self:UsedDispatchChange(true)
	self.isComplete = true
end

function CollectVo:UsedDispatchChange(bl)
	self.isUsedispatchchange = bl

end

function CollectVo:SetValue(k, v, oldValue)
	if k ~= nil and v ~= nil and oldValue ~= nil then
		self[k] = v
		self:OnChange(k, v, oldValue)
	end
end

function CollectVo:OnChange(k, v, oldValue)
	if self.isUsedispatchchange then
		self:DispatchEvent(SceneConst.OBJ_UPDATE, key, value, pre)
	end
end

function CollectVo:GetCfg(id)
	return GetCfgData("collect"):Get(id)
end

function CollectVo:GetPosition()
	return self.position
end

function CollectVo:__delete()

end