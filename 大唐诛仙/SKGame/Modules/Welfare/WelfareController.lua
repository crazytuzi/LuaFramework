RegistModules("Welfare/View/WelfarePanel")
RegistModules("Welfare/WelfareModel")
RegistModules("Welfare/WelfareView")

--在线奖励
RegistModules("Welfare/View/OnlineRewardContent")
RegistModules("Welfare/View/OnlineRewardItem")
RegistModules("Welfare/WelfareConst")
RegistModules("Welfare/RewardConst")
-- 实名认证
RegistModules("Welfare/View/IdentifyPanel")

--冲级 战力 激活码 
RegistModules("Welfare/View/PowerLevelItem")
RegistModules("Welfare/View/PowerBattleItem")
RegistModules("Welfare/View/RewardCodePanel")

RegistModules("Welfare/PowerLevelView")
RegistModules("Welfare/PowerBattleView")
RegistModules("Welfare/PowerConst")
RegistModules("Welfare/PowerLevelCtr")
RegistModules("Welfare/PowerModel")
RegistModules("Welfare/RewardCodeCtrl")
RegistModules("Welfare/RewardCodelModel")

WelfareController = BaseClass(LuaController)

function WelfareController:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end

function WelfareController:__delete()
	self:CleanEvent()
	if self.view then
		self.view:Destroy()
	end
	self.view = nil

	if self.model then
		self.model:Destroy()
	end
	self.model = nil

	WelfareController.inst = nil
end

function WelfareController:GetInstance()
	if WelfareController.inst == nil then
		WelfareController.inst = WelfareController.New()
	end

	return WelfareController.inst
end

function WelfareController:Config()
	self.model = WelfareModel:GetInstance()
	self.view =	WelfareView.New()
end

function WelfareController:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
	end)

	self.handler1 = GlobalDispatcher:AddEventListener(EventName.NET_DISCONNECT , function ()
		if self.model then
			self.model:RemoveOnLineTimer()
		end
	end)

	self.handler2 = GlobalDispatcher:AddEventListener(EventName.NET_RECONNECT , function ()
		if self.model then
			self.model:SetOnLineTimer()
		end
	end)

	self.handler3 = GlobalDispatcher:AddEventListener(EventName.NET_TIMEOUT , function()
		if self.model then
			self.model:RemoveOnLineTimer()
		end
	end)
end

function WelfareController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
end

function WelfareController:RegistProto()
	--在线累积时长奖励协议
	self:RegistProtocal("S_GetReward", "HandleGetReward")
	self:RegistProtocal("S_SynRewardList", "HandleSyncRewardList")
end

function WelfareController:HandleGetReward(msgParam)
	local msg = self:ParseMsg(activity_pb:S_GetReward(), msgParam)
	if msg.reward then
		self.model:HandleGetReward(msg.reward)
		GlobalDispatcher:DispatchEvent(EventName.GetOnlineReward, msg.reward.id)
	end
end

function WelfareController:HandleSyncRewardList(msgParam)
	local msg = self:ParseMsg(activity_pb:S_SynRewardList(), msgParam)
	if msg.onlineTime and msg.onlineTime ~= 0 then
		self.model:SetOnlineTime(msg.onlineTime)
	end

	if msg.rewardList then
		self.model:SetOnlineRewardList(msg.rewardList)
	end

	GlobalDispatcher:DispatchEvent(EventName.SyncOnlineRewardList)
	self.model:SetOnLineTimer()
end

function WelfareController:OpenWelfarePanel(tabIdx)
	if self.view then
		self.view:OpenWelfarePanel(tabIdx)
	end
end

function WelfareController:GetWelfarePanel()
	if self.view then
		return self.view:GetWelfarePanel()
	end
	return nil
end

function WelfareController:C_GetReward(rewardId)
	if rewardId then
		local msg = activity_pb:C_GetReward()
		msg.id = rewardId
		self:SendMsg("C_GetReward", msg)
	end
end

function WelfareController:C_GetRewardList()
	local msg = activity_pb:C_GetRewardList()
	self:SendMsg("C_GetRewardList", msg)
end


function WelfareController:StartModel()
	if self.model and self.model:GetOnlineTime() == 0 then
		self:C_GetRewardList()
	end
end