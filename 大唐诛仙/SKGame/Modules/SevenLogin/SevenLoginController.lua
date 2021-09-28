RegistModules("SevenLogin/View/DayItem")
RegistModules("SevenLogin/View/SevenLoginPanel")
RegistModules("SevenLogin/SevenLoginModel")
RegistModules("SevenLogin/SevenLoginConst")


SevenLoginController = BaseClass(LuaController)

function SevenLoginController:GetInstance()
	if SevenLoginController.inst == nil then
		SevenLoginController.inst = SevenLoginController.New()
	end
	return SevenLoginController.inst
end

function SevenLoginController:__init()
	self.model = SevenLoginModel:GetInstance()
	resMgr:AddUIAB("FirstRechargeUI")
	resMgr:AddUIAB("SevenLogining")

	self:Config()
	self:InitEvent()
	self:RegistProto()
	self:C_GetOpenServerData()
end

function SevenLoginController:Config()
	self.isTan = false
end

function SevenLoginController:InitEvent()
	local function addEvents()
		self.handler0 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
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

function SevenLoginController:CheckOpen()
	if self.handler0 then
		GlobalDispatcher:RemoveEventListener(self.handler0)
		self.handler0 = nil
	end
	-- 窗口弹出条件
	local isShow = false
	local scene = SceneModel:GetInstance().sceneId
	local isClose = self.model:IsClose() -- 七天登录活动 是否关闭
	local isCanGet = self.model:IsCanGetReward()
	if not isClose and isCanGet and scene and scene ~= 1000 then
		isShow = true
	end
	self:PushToPopList(isShow)
end

function SevenLoginController:PushToPopList(isShow)
	if isShow then
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.SevenLogin, show = true, openCb = self.ShowOpen, args = {self}})
	else
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.SevenLogin, show = false, isClose = false})
	end
end

function SevenLoginController:ShowOpen()
	self.isTan = true
	self:Open()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	self.handler0 = nil
end

function SevenLoginController:Open()
	if not self:GetView() then
		self.view = SevenLoginPanel.New()
	end
	self.view:Open()
end

function SevenLoginController:Close()
	if self:GetView() then
		self.view:Close()
	end
	self.isTan = false
end

function SevenLoginController:GetView()
	if self.view and self.view.isInited then
		return self.view
	end
	return nil
end

function SevenLoginController:RegistProto()
	self:RegistProtocal("S_GetOpenServerData")       			  --获取开福七天数据
	self:RegistProtocal("S_GetOpenServerReward")                  --领取开服七天奖励
end

function SevenLoginController:S_GetOpenServerData(buffer)
	local msg = self:ParseMsg(activity_pb.S_GetOpenServerData(), buffer)
	self.model.isClose = msg.state
	self.model.totleLoginDay = msg.addLoginDay
	self.model.rewardGetState = {}
	SerialiseProtobufList( msg.rewardList, function ( item )      --已领取奖励id列表
		table.insert(self.model.rewardGetState, item)
	end )
	self.model:DispatchEvent(SevenLoginConst.InitSevenData)
	if self.model:IsClose() then
		MainUIModel:GetInstance():CloseSevenLogin()
	end
	self.model:ShowRed()
end

function SevenLoginController:S_GetOpenServerReward(buffer)
	local msg = self:ParseMsg(activity_pb.S_GetOpenServerReward(), buffer)
	table.insert(self.model.rewardGetState, msg.id)
	self.model:DispatchEvent(SevenLoginConst.RewardLQ)
	if self.model:IsClose() then
		MainUIModel:GetInstance():CloseSevenLogin()
	end
	self.model:ShowRed()
end

-----------------------------------------------------------------------

function SevenLoginController:C_GetOpenServerData()
	self:SendEmptyMsg(activity_pb, "C_GetOpenServerData")
end

function SevenLoginController:C_GetOpenServerReward(id)           --Send领取奖励
	local msg = activity_pb.C_GetOpenServerReward()
	msg.id = id
	self:SendMsg("C_GetOpenServerReward", msg)
end

function SevenLoginController:__delete()
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	GlobalDispatcher:RemoveEventListener(self.handler0)
	SevenLoginController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model=nil
end
