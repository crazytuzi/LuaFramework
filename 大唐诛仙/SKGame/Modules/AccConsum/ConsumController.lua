RegistModules("AccConsum/ConsumModel")
RegistModules("AccConsum/ConsumConst")
RegistModules("AccConsum/View/ConsumItem")
RegistModules("AccConsum/View/ConsumPanel")

ConsumController = BaseClass(LuaController)

function ConsumController:GetInstance()
	if ConsumController.inst == nil then
		ConsumController.inst = ConsumController.New()
	end
	return ConsumController.inst
end

function ConsumController:__init()
	resMgr:AddUIAB("AccConsum")
	self:RegistProto()
end

-- 协议注册
function ConsumController:RegistProto()
	self:RegistProtocal("S_GetTotalSpendReward")
end

-- 获取累计消费奖励
function ConsumController:C_GetTotalSpendReward( id )
	local msg = activity_pb.C_GetTotalSpendReward()
	msg.id = id
	self:SendMsg("C_GetTotalSpendReward", msg)
end

function ConsumController:S_GetTotalSpendReward( buffer )
	local msg = self:ParseMsg(activity_pb.S_GetTotalSpendReward(), buffer)
	ConsumModel:GetInstance():AddRewardIdList( msg.id )
	GlobalDispatcher:DispatchEvent(EventName.RefershConsumRed)
end

function ConsumController:Close()

end

function ConsumController:__delete()
	ConsumController.inst = nil
end