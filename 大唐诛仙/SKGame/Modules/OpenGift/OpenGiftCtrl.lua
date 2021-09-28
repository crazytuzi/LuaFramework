RegistModules("OpenGift/OpenGiftModel")
RegistModules("OpenGift/OpenGiftPanel")
RegistModules("OpenGift/OpenGiftView")
RegistModules("OpenGift/OpenGiftConst")

OpenGiftCtrl = BaseClass(LuaController)

function OpenGiftCtrl:__init()
	resMgr:AddUIAB("OpenGift")
	self.model = OpenGiftModel:GetInstance()
	self.view = OpenGiftView.New()
	self:RegistProto()
	self:C_BuyArtifactData()
	self:InitEvent()
end

function OpenGiftCtrl:GetInstance()
	if OpenGiftCtrl.inst == nil then
		OpenGiftCtrl.inst = OpenGiftCtrl.New()
	end

	return OpenGiftCtrl.inst
end

function OpenGiftCtrl:InitEvent()
	local function addEvents()
		self.handler0 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
			self.model.isPop = OpenGiftConst.PopState.Pop
			self:CheckOpen()
		end)

		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()
			if self.inst then
				self.inst:Destroy()
			end
		end)
	end
	addEvents()
end

function OpenGiftCtrl:CheckOpen()
	if self.handler0 then
		GlobalDispatcher:RemoveEventListener(self.handler0)
		self.handler0 = nil
	end
	local isShow = not self.model:IsGetRewardState() and
	 SceneModel:GetInstance():IsMain() and
	 self.model:IsOpenActivity() and
	 self.model.isPop == OpenGiftConst.PopState.Pop and
	 not NewbieGuideModel:GetInstance():IsNeedNewbieGuide()

	self:PushToPopList(isShow)
end

function OpenGiftCtrl:PushToPopList(isShow)
	if isShow then
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.OpenGift, show = true, openCb = self.ShowOpen, args = {self}})
	else
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.OpenGift, show = false, isClose = false})
	end
end

function OpenGiftCtrl:ShowOpen()
	self:OpenPopPanel()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	self.handler0 = nil
end

function OpenGiftCtrl:OpenPopPanel()
	if not self.panel then
		self.panel = OpenGiftPanel.New()
	end
	self.model.isPop = FirstRechargeConst.PopState.Pop
	self.panel:Open()
end

function OpenGiftCtrl:Open()
	if self.view then
		self.model.isPop = FirstRechargeConst.PopState.UnPop
		self.view:Open()
	end
end

function OpenGiftCtrl:RegistProto()
	self:RegistProtocal("S_BuyArtifactData") -- 获取神器数据
end

function OpenGiftCtrl:S_BuyArtifactData( buffer )
	local msg = self:ParseMsg(activity_pb.S_BuyArtifactData(), buffer)
	self.model:RefreshOpenState( msg.buyArtActState )
	self.model:RefreshBuyState( msg.buyArtifactState )
	self.model:CloseOpenGiftByState()
end

function OpenGiftCtrl:C_BuyArtifactData()
	self:SendEmptyMsg(activity_pb, "C_BuyArtifactData")
end

function OpenGiftCtrl:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	if self.model then
		self.model:Destroy()
	end
	self.model = nil

	OpenGiftCtrl.inst = nil
end