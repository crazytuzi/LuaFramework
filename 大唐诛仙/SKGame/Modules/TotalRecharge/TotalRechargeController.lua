RegistModules("TotalRecharge/TotalRechargeModel")
RegistModules("TotalRecharge/TotalRechargeView")
RegistModules("TotalRecharge/TotalRechargeConst")
RegistModules("TotalRecharge/View/TotalRechargeItem")
RegistModules("TotalRecharge/View/TotalRechargeUI")


TotalRechargeController = BaseClass(LuaController)

function TotalRechargeController:__init()
	self:InitData()
	self:InitEvent()
	self:RegistProto()
end

function TotalRechargeController:__delete()
	self:CleanEvent()
	self:CleanData()
	self:CleanSingleton()
end

function TotalRechargeController:GetInstance()
	if TotalRechargeController.inst == nil then
		TotalRechargeController.inst = TotalRechargeController.New()
	end
	return TotalRechargeController.inst
end

function TotalRechargeController:CleanSingleton()
	TotalRechargeController.inst = nil
end

function TotalRechargeController:InitEvent()
	self.eventHandler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function()
		if self.model then
			self.model:Reset()
		end
	end)
end

function TotalRechargeController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.eventHandler0)
end

function TotalRechargeController:InitData()
	self.model = TotalRechargeModel:GetInstance()
	self.view = TotalRechargeView.New()
end

function TotalRechargeController:CleanData()
	if self.model then
		self.model:Destroy()
	end
	self.model = nil

	if self.view then
		self.view:Destroy()
	end
	self.view = nil
end

function TotalRechargeController:RegistProto()
	self:RegistProtocal("S_GetTotalRrechargeReward")
end

--获取累计充值奖励协议请求
function TotalRechargeController:C_GetTotalRrechargeReward(rewardId)
	if rewardId then
		local msg = activity_pb:C_GetTotalRrechargeReward()
		msg.id = rewardId
		self:SendMsg("C_GetTotalRrechargeReward" , msg)
	end
end

--获取累计充值奖励协议回包处理
function TotalRechargeController:S_GetTotalRrechargeReward(msgParam)
	local msg = self:ParseMsg(activity_pb.S_GetTotalRrechargeReward() , msgParam)
	self.model:HandleGetTotalRechargeReward(msg.id)
	self.model:DispatchEvent(TotalRechargeConst.RefershTotalRechargeState)
	GlobalDispatcher:DispatchEvent(EventName.RefershTotalRechargeRedTipsState)
end


