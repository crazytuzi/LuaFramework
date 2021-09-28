require "SKGame/Modules/ShenJing/ShenJingConst"
require "SKGame/Modules/ShenJing/ShenJingModel"
require "SKGame/Modules/ShenJing/ShenJingView"
require "SKGame/Modules/ShenJing/View/ShenJingPanel"
require "SKGame/Modules/ShenJing/View/InLetBtn"

ShenJingController = BaseClass(LuaController)

function ShenJingController:__init()
	self.model = ShenJingModel:GetInstance()
	self.view = ShenJingView.New()
	self:RegistProtocal("S_GetShenjingData") -- 获取神境面板数据
	self:AddEvent()
end

function ShenJingController:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then self.model:Reset() end
	end)
end

function ShenJingController:OpenShenJingPanel()
	if self.view then 
		self.view:OpenShenJingPanel()
		self:C_GetShenjingData()
		self.model:SetRedTipsData(false)
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.shenjing , state = false})
	end
end
function ShenJingController:S_GetShenjingData(buff)
	local msg = self:ParseMsg(tower_pb.S_GetShenjingData(),buff)
	-- msg.huanjingState -- 幻境状态  1：开启  0结束
	-- msg.huanjingEndTime -- 幻境结束时间搓
	self.model:SetHuanjingInfo(msg)
end
function ShenJingController:C_GetShenjingData() --获取神境面板数据
	self:SendEmptyMsg(tower_pb, "C_GetShenjingData")
end

function ShenJingController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function ShenJingController:GetInstance()
	if ShenJingController.inst == nil then 
		ShenJingController.inst = ShenJingController.New()
	end
	return ShenJingController.inst
end

function ShenJingController:__delete()
	self:CleanEvent()
	if self.model then
		self.model:Destroy()
	end
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
	self.model = nil
	ShenJingController.inst = nil
end

function ShenJingController:CloseShenJingPanel()
	if self.view then 
		self.view:CloseShenJingPanel()
	end
end