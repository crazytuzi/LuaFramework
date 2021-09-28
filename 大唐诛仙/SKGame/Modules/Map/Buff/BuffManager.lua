BuffManager =BaseClass()

function BuffManager:__init( player )
	self.player = player
	self.buffAry = {}
	self:InitEvent()
end

function BuffManager:InitEvent()
	self.handler0 =  GlobalDispatcher:AddEventListener(EventName.BuffDataUpdate , function(flag) self:UpdateBuffData(flag) end)
end

function BuffManager:ClearEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

--更新buff数据
function BuffManager:UpdateBuffData(flag)
	self.flag = flag
	local list = SceneModel:GetInstance():GetBuffList()
	for k , v in pairs(list) do
		if self.player and self.player.guid and self.player.guid == k then
			self:UpdateByList(clone(v))
		end
	end
end

function BuffManager:Refesh(player)
	self.player = player
	for i = 1, #self.buffAry do
		local buff = self.buffAry[i]
		if buff then
			buff:Refesh(player)
		end
	end
end

--添加buff列表
function BuffManager:UpdateByList(buffVoList)
	for i = 1, #buffVoList do
		if buffVoList[i] then
			buffVoList[i].endTime = tonumber(buffVoList[i].endTime)
			self:_AddBuff(buffVoList[i])
		end
	end
	GlobalDispatcher:DispatchEvent(EventName.BUFF_UPDATE_EVENT, {guid = self.player.guid, buffAry = self.buffAry})
end

function BuffManager:HasBuff(buffId)
	if #self.buffAry < 1 then return false end
	for i = 1, #self.buffAry do
		if self.buffAry[i].vo.buffId == buffId then
			return true
		end
	end
	return false
end

function BuffManager:HasBuffGroup(buffId)
	if #self.buffAry < 1 then return false end
	local cfgDataG = BuffManager.GetBuffVo(buffId)
	if cfgDataG == nil then return false end
	for i = 1, #self.buffAry do
		if self.buffAry[i].cfgData.groupId == cfgDataG.groupId then
			return true
		end
	end
	return false
end

--添加buff
function BuffManager:_AddBuff(buffVo)
	local update = self:_UpdateBuff(buffVo)
	if not update and ((buffVo.endTime - TimeTool.GetCurTime() > 0) or buffVo.endTime == -1) then 
		local buff = Buff.New(self.player, self, buffVo)
		table.insert(self.buffAry, buff)
	end
	if buffVo and buffVo.targetGuid then
		GlobalDispatcher:DispatchEvent(EventName.BuffDataChanged, {guid = buffVo.targetGuid, state = 1})
	end
end

--更新buff
function BuffManager:_UpdateBuff(buffVo)
	local buffGuid = buffVo.id
	if buffVo.endTime ~= -1 and (buffVo.endTime == 0 or (buffVo.endTime - TimeTool.GetCurTime() < 0)) then
		self:RemoveBuff(buffGuid, true)
		return true
	end
	
	local buff = self:GetBuff(buffGuid)
	if buff then
		buff:UpdateVo(buffVo)
		return true
	end
	return false
end

--移除buff
--@param guid buff模型数据Id
function BuffManager:RemoveBuff(guid, notDispatchEvent)
	for i = 1, #self.buffAry do
		if self.buffAry[i].guid == guid then
			local buff = table.remove(self.buffAry, i)
			if buff then
				buff:Destroy()
				buff = nil
			end
			break
		end
	end

	if not notDispatchEvent then
		GlobalDispatcher:DispatchEvent(EventName.BUFF_UPDATE_EVENT, {guid = self.player.guid, buffAry = self.buffAry})
	else
		if self.flag then
			GlobalDispatcher:DispatchEvent(EventName.BuffRemove, {playerGuid = self.player.guid, buffGuid = guid})
		end
	end
	if buffVo and buffVo.targetGuid then
		GlobalDispatcher:DispatchEvent(EventName.BuffDataChanged, {guid = buffVo.targetGuid, state = 2})
	end
end

function BuffManager.GetBuffVo(buffId)
	return GetCfgData("buff"):Get(buffId) 
end

function BuffManager:GetBuff(guid)
	for i = 1, #self.buffAry do
		if self.buffAry[i].guid == guid then
			return self.buffAry[i]
		end
	end
end

function BuffManager:Update()
	for i = 1, #self.buffAry do
		local buff = self.buffAry[i]
		if buff then
			buff:Update()
		end
	end
end

function BuffManager:__delete()
	self:ClearEvent()
	for i = 1, #self.buffAry do
		local buff = self.buffAry[i]
		if buff then
			buff:Destroy()
			buff = nil
		end
	end
	GlobalDispatcher:DispatchEvent(EventName.BUFF_UPDATE_EVENT, {guid = self.player.guid, buffAry = {}})
	self.buffAry = nil
end