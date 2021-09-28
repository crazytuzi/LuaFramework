
PowerLevelCtr = BaseClass(LuaController)

function PowerLevelCtr:__init()
	resMgr:AddUIAB("PowerLevelingActivitiesUI")
	self:Config()
	self:InitEvent()
	self:RegistProto()
end

function PowerLevelCtr:__delete()
	self.model = nil
	PowerLevelCtr.inst = nil
end

function PowerLevelCtr:InitEvent()
	--监听角色等级--------------
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre)
		self:RegidtLevel(key, value, pre)
	end)
end

function PowerLevelCtr:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function PowerLevelCtr:GetInstance()
	if PowerLevelCtr.inst == nil then
		PowerLevelCtr.inst = PowerLevelCtr.New()
	end

	return PowerLevelCtr.inst
end

function PowerLevelCtr:RegistProto()
	--冲级狂人奖励协议
	self:RegistProtocal("S_GetLevelAwardData","S_HandleGetLevelAwardData")
	self:RegistProtocal("S_GetLevelAward","S_HandleGetLevelAward")
	
	--战力奖励协议
	self:RegistProtocal("S_GetBVAwardData","S_HandleGetBVAwardData")
	self:RegistProtocal("S_GetBattleValueAward","S_HandleGetBattleValueAward")
end

function PowerLevelCtr:Config()
	self.model = PowerModel:GetInstance()
end

-------------------------------s2c--冲级狂人--------
function PowerLevelCtr:S_HandleGetLevelAward(msgParam)
	local msg = self:ParseMsg(activity_pb:S_GetLevelAward(),msgParam)
	--对应的id领取的人数
	if msg.id then
		self.model:HandleLeveGetRewardID(msg.id)
		
	end
	if msg.num then
		self.model:HandleLeveGetRewardNum(msg.num)
		
	end
	
end

function PowerLevelCtr:S_HandleGetLevelAwardData(msgParam)

	self.model.ownLevelRewardList = {}
	local msg = self:ParseMsg(activity_pb:S_GetLevelAwardData(),msgParam)
	
	if msg.ownRewardList then
		SerialiseProtobufList(msg.ownRewardList , function (item)
		table.insert(self.model.ownLevelRewardList , item)
	end)

	end
	if msg.allRewardList then
		self.model:HandleLeveAlreadyGetRewardData(msg.allRewardList)
	end
	GlobalDispatcher:DispatchEvent(EventName.SyncOnLevelRewardList)
	
end

--------------------c2s--冲级狂人--------
function PowerLevelCtr:C_GetLevelAward(rewardId)
	if rewardId then
		local msg = activity_pb:C_GetLevelAward()
		msg.id = rewardId
		self:SendMsg("C_GetLevelAward", msg)
	end
end

function PowerLevelCtr:C_GetLevelAwardData()
	local msg = activity_pb:C_GetLevelAwardData()
	self:SendMsg("C_GetLevelAwardData", msg)
end

---------------------s2c----冲战斗力-----------
function PowerLevelCtr:S_HandleGetBattleValueAward(msgParam)
	local msg = self:ParseMsg(activity_pb:S_GetBattleValueAward(),msgParam)
	if msg.id then
		self.model:HandleBattleGetRewardID(msg.id)
		
	end
	if msg.num then
		--对应的ID已领取的人数
		self.model:HandleBattleGetRewardNum(msg.num)
		
	end
	
end

function PowerLevelCtr:S_HandleGetBVAwardData(msgParam)
	self.model.ownBattleRewardList = {}
	local msg = self:ParseMsg(activity_pb:S_GetBVAwardData(),msgParam)
	if msg.ownRewardList then
			SerialiseProtobufList(msg.ownRewardList , function (item)
		table.insert(self.model.ownBattleRewardList , item)
	end)

	end
	if msg.allRewardList then
		self.model:HandleBattleAlreadyGetRewardData(msg.allRewardList)
	end

	GlobalDispatcher:DispatchEvent(EventName.SyncOnBattleRewardList)

end
--------------------c2s---冲战斗力------------
function PowerLevelCtr:C_GetBattleValueAward(rewardId)
	if rewardId then
		local msg = activity_pb:C_GetBattleValueAward()
		msg.id = rewardId
		self:SendMsg("C_GetBattleValueAward", msg)
	end
end

function PowerLevelCtr:C_GetBVAwardData()
	local msg = activity_pb:C_GetBVAwardData()
	self:SendMsg("C_GetBVAwardData", msg)
end

function PowerLevelCtr:RegidtLevel(key, value, pre)
	if key == "level" then
		--print("dengji 等级改变================================",value)
		self.currentLevel = value
			if self.model then
				self:C_GetLevelAwardData()
				self:C_GetBVAwardData()
			end
		self.model:SetOnLevelRewardState()
	end
	if key == "battleValue" then
		--print("攻击力改变=======================现在攻击力",value)
		self.currentBattleValue = value
			if self.model then
				self:C_GetLevelAwardData()
				self:C_GetBVAwardData()
			end
		self.model:SetOnBattleRewardState()

	end
end

function PowerLevelCtr:StartModel()
	if self.model then
		self:C_GetLevelAwardData()
		self:C_GetBVAwardData()

	end
end

function PowerLevelCtr:GetChangedLevel()
	return self.currentLevel or 0
end

function PowerLevelCtr:GetChangedBattleValue()
	return self.currentBattleValue or 0
end