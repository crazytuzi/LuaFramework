RegistModules("FirstRecharge/FirstRechargeModel")
RegistModules("FirstRecharge/FirstRechargeView")
RegistModules("FirstRecharge/FirstRechargeConst")
RegistModules("FirstRecharge/FirstRechargeComBg")
RegistModules("FirstRecharge/FRPanel")

FirstRechargeCtrl = BaseClass(LuaController)

function FirstRechargeCtrl:GetInstance()
	if FirstRechargeCtrl.inst == nil then
		FirstRechargeCtrl.inst = FirstRechargeCtrl.New()
	end

	return FirstRechargeCtrl.inst
end

function FirstRechargeCtrl:__init()	
	resMgr:AddUIAB("FirstRechargeUI")
	self.model = FirstRechargeModel:GetInstance()
	-- self.view = FirstRechargeView.New()
	self.view = FirstRechargeView.New()
	self:RegistProto()
	self:C_GetFristPayData()
	self:InitEvent()
end

function FirstRechargeCtrl:InitEvent()
	local function addEvents()
		self.handler0 = GlobalDispatcher:AddEventListener(EventName.SceneLoader_CLOSE, function()
			self.model.isPop = FirstRechargeConst.PopState.Pop
			self:CheckOpen()
		end)
		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()
			if self.inst then
				self.inst:Destroy()
			end
		end)
		self.handler1 = GlobalDispatcher:AddEventListener(EventName.FinishTask ,function (id)
			if self.model:IsTaskPopId(id) then
				self.model.isPop = FirstRechargeConst.PopState.UnPop
				self:Open()
			end
		end)
	end
	addEvents()
end

function FirstRechargeCtrl:CheckOpen()
	if self.handler0 then
		GlobalDispatcher:RemoveEventListener(self.handler0)
		self.handler0 = nil
	end
	local isShow = not self.model:IsGetFirstPayRewardState() and
		SceneModel:GetInstance():IsMain() and
		(self.model.isPop == FirstRechargeConst.PopState.Pop) and
		not NewbieGuideModel:GetInstance():IsNeedNewbieGuide()
		
	self:PushToPopList(isShow)
end

function FirstRechargeCtrl:PushToPopList(isShow)
	if isShow then
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.FirstRecharge, show = true, openCb = self.ShowOpen, args = {self}})
	else
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.FirstRecharge, show = false, isClose = false})
	end
end

function FirstRechargeCtrl:ShowOpen()
	self:OpenPopPanel()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	self.handler0 = nil
end

function FirstRechargeCtrl:RegistProto()
	self:RegistProtocal("S_GetFristPayReward")
	self:RegistProtocal("S_GetFristPayData")
end

function FirstRechargeCtrl:C_GetFristPayReward( id )
	local msg = activity_pb.C_GetFristPayReward()
	msg.id = id
	self:SendMsg("C_GetFristPayReward", msg)
end

function FirstRechargeCtrl:S_GetFristPayReward( buffer )
	local msg = self:ParseMsg(activity_pb.S_GetFristPayReward(), buffer)
	self.model:SetFirstPayRewardState( FirstRechargeConst.RewardState.Received )
end

-- 首充状态
function FirstRechargeCtrl:C_GetFristPayData()
	self:SendEmptyMsg(activity_pb, "C_GetFristPayData")
end

function FirstRechargeCtrl:S_GetFristPayData( buffer )
	local msg = self:ParseMsg(activity_pb.S_GetFristPayData(), buffer)
	self.model:SetFirstPayRewardState( msg.fristPayRewardState )
	self.model:CloseFirstRechargeByState()
end

function FirstRechargeCtrl:OpenPopPanel()
	if not self.panel then
		self.panel = FRPanel.New()
	end
	self.model.isPop = FirstRechargeConst.PopState.Pop
	self.panel:Open()
end

function FirstRechargeCtrl:Open()
	if self.view then
		self.model.isPop = FirstRechargeConst.PopState.UnPop
		-- self.view:OpenPanel()
		self.view:Open()
		self.model:RedTips(false)
	end
end

function FirstRechargeCtrl:__delete()
	if self.reloginHandle then
		GlobalDispatcher:RemoveEventListener(self.reloginHandle)
		self.reloginHandle = nil
	end
	if self.handler1 then
		GlobalDispatcher:RemoveEventListener(self.handler1)
		self.handler1 = nil
	end
	FirstRechargeCtrl.inst = nil

	if self.view and self.view.Close then 
		self.view:Close()
	end
	self.view = nil

	if self.model then
		self.model:Destroy()
	end
	self.model=nil
end