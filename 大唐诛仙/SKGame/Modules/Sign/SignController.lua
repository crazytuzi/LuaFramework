RegistModules("Sign/View/SignMask")
RegistModules("Sign/View/SignFuliPanel")
RegistModules("Sign/SignPanel")
RegistModules("Sign/SignConst")
RegistModules("Sign/SignModel")

SignController = BaseClass(LuaController)

function SignController:__init( ... )
	self.model = SignModel:GetInstance()
	resMgr:AddUIAB("Sign")
	self:InitEvent()
	self:RegistProto()
end

function SignController:InitEvent()
	local function addEvents()
		local sceneModel = SceneModel:GetInstance()
		if not self.handler2 then
			self.handler2 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function ()
				if sceneModel:IsMain() or sceneModel:IsOutdoor() then
					DelayCall(function ()
						local role = sceneModel:GetMainPlayer()
						if role and role.die then self:PushToPopList(false) return end
						self:CheckOpen(true)
					end, 1)
				else
					self:PushToPopList(false)
				end
			end)
		end
		if not self.handler3 then
			self.hanlder3 = GlobalDispatcher:AddEventListener(EventName.ActivityFirstOpen, function(data)
				local role = sceneModel:GetMainPlayer()
				if role and role.die then return end
				self:CheckOpen()
			end)
		end
	end
	addEvents()
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED, function ()
		self.model:InitData()
	end)
	-- if not self.reloginHandle then
	-- 	addEvents()
	-- 	self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
	-- 		addEvents()
	-- 		self.model:InitData()
	-- 	end)
	-- end
	self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
		if self.inst then
			self.inst:Destroy()
		end
	end)
end

--接收协议
function SignController:RegistProto()
	self:RegistProtocal("S_SynSign")
	self:RegistProtocal("S_GetConSignReward")
end

------------------------------------------------  s2c start >>>>>>>>>>>>>>>>>>>>>>>

function SignController:S_SynSign(buffer)
	local msg = self:ParseMsg(sign_pb.S_SynSign(), buffer)
	if msg.signMsg then 
	     self.model:SetSignInfo(msg.signMsg)
	end
end

function SignController:S_GetConSignReward(buffer)
	local msg = self:ParseMsg(sign_pb.S_GetConSignReward(), buffer)
	if msg.signNum then 
	     self.model:SetConReward(msg.signNum)
	end
end

------------------------------------------------- s2c end <<<<<<<<<<<<<<<<<<<<<<<<<

------------------------------------------------- c2s start >>>>>>>>>>>>>>>>>>>>>>>

function SignController:C_Sign()
	if not self.model:GetLock() then
		self.model:SetLock(true)
		self:SendEmptyMsg(sign_pb, "C_Sign")
	end
end

function SignController:C_GetConSignReward(v)
	local msg = sign_pb.C_GetConSignReward()
	local k = self.model:GetRewardIdx(v)
	msg.signNum = k
	self:SendMsg("C_GetConSignReward", msg)
end

--------------------------------------------------- c2s end <<<<<<<<<<<<<<<<<<<<<<<<

function SignController:CheckOpen(isLoadScene)
	if NewbieGuideModel:GetInstance():IsNeedNewbieGuide() then
		self:PushToPopList(false)
		return
	end

	local open = false 
	local tab = MainUIModel:GetInstance():GetMainUIVoListById(FunctionConst.FunEnum.welfare)
	if tab and tab:GetState() ==  MainUIConst.MainUIItemState.Open then
		open = true
	end
	if self.model then
		local signMsg = self.model:GetSignMsg()
		if signMsg.state and signMsg.day and signMsg.state ~= 1 and signMsg.day <= SignConst.NUM_DAYS and signMsg.signNum and signMsg.signNum < SignConst.NUM_DAYS and open then		
			--self:ShowOpen()
			self:PushToPopList(true)
		else
			
			self:PushToPopList(false)
		end
	end
end

function SignController:ShowOpen()
	self:Open()
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	self.handler2 = nil
	self.handler3 = nil
end

--面板
function SignController:Open()
	if not self:GetView() then
		self.view = SignPanel.New()
		self.view:Open()
	else
	  	if self:GetView():IsOpen()then
	  		-- self:GetView():Update()
	  	else
	  		self:GetView():Open()
	  	end
	end
end
function SignController:Close()
	if self:GetView() then
		self.view:Close()
	end
end
function SignController:GetView()
	if self.view and self.view.isInited then
		return self.view
	end
	return nil
end

function SignController:GetInstance()
	if not SignController.inst  then
		SignController.inst = SignController.New()
	end
	return SignController.inst
end

function SignController:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	if self.handler2 then
		GlobalDispatcher:RemoveEventListener(self.handler2)
	end
	if self.handler3 then
		GlobalDispatcher:RemoveEventListener(self.handler3)
	end
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)

	if self:GetView() then
		self:GetView():Destroy()
	end
	if self.model then
		self.model:Destroy()
	end
	self.view = nil
	self.model = nil
	SignController.inst = nil
end

-- 福利界面签到panel
function SignController:GetFuliPanel()
	if not self:IsExistFuliView() then
		self.fuliView = SignFuliPanel.New()
	end
	return self.fuliView
end

function SignController:IsExistFuliView()
	return self.fuliView --and self.fuliView.isInited
end

function SignController:DestroyFuliPanel()
	self.isFuliDestroying = true
	if self:IsExistFuliView() then
		self.fuliView:Destroy()
	end
	self.fuliView = nil
	self.isFuliDestroying = false
end

function SignController:PushToPopList(isShow)
	if isShow then
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.Sign, show = true, openCb = self.ShowOpen, args = {self}})
	else
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.Sign, show = false, isClose = false})
	end
end