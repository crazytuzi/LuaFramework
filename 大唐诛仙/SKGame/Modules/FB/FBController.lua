require "SKGame/Modules/FB/FBConst"
require "SKGame/Modules/FB/FBModel"
require "SKGame/Modules/FB/view/FBItem"
require "SKGame/Modules/FB/view/FBUI"
require "SKGame/Modules/FB/FBVo/FBVo"
require "SKGame/Modules/FB/view/CDMessageBox"
require "SKGame/Modules/FB/view/FinishFB"
require "SKGame/Modules/FB/view/PoPFinishFB"
require "SKGame/Modules/FB/view/EnterPanel1"

FBController =BaseClass(LuaController)

function FBController:__init()
	self:Config()
	self:InitEvent()
end

function FBController:Config()
	self:RegistProto()
	self.model = FBModel:GetInstance()
	resMgr:AddUIAB("FB")
	self:GetOpenMapList()
end

function FBController:RegistProto()
	self:RegistProtocal("S_GetOpenMapList", "GetOpenMapListCallBack")  --取副本列表返回
	self:RegistProtocal("S_SynTeamState", "SynTeamStateCallBack") --多人副本通知
	self:RegistProtocal("S_InstanceEnd", "InstanceEndCallBack") --副本结束通知
end

function FBController:InitEvent()
	--切换场景的时候把几个弹窗销毁掉
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.UNLOAD_SCENE,function ()
		self:DestroyTips()
	end)
	self.handler2 = self.model:AddEventListener(FBConst.E_DestroyCDMessageBox,function ()
		self:DestroyCDMessageBox()
	end)
	-- self.handler3 = GlobalDispatcher:AddEventListener(EventName.MAIN_ROLE_ADDED, function ()
	-- 	-- self:LoadMainPlayerFinish()
	-- end)
	if not self.reloginHandle then
		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE,function ()
			self:DestroyTips()
			self.model:Reset()
		end)
	end
end

function FBController:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	self.model:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
end

function FBController:LoadMainPlayerFinish()

end

function FBController:OpenFBPanel()
	self:GetMainPanel():Open()
	-- if self.model:IsHasNewFB() then
	-- 	self.model:SetRedTipsData(false)
	-- 	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.copy , state = false})
	-- end
end

function FBController:DestroyTips()
	if self.FinishFBCutDownTips then 
		self.FinishFBCutDownTips:Destroy()
	end
	self.FinishFBCutDownTips = nil
	self:DestroyCDMessageBox()
end

function FBController:DestroyCDMessageBox()
	if self.cdBox then 
		self.cdBox:Destroy()
	end
	self.cdBox = nil
end

-- >>> c2s start
--请求进入副本
function FBController:RequireEnterInstance(mapId)
	local msg = instance_pb.C_EnterInstance()
	msg.mapId = mapId
	self:SendMsg("C_EnterInstance", msg)
end
--请求退出副本
function FBController:RequireQuitInstance()
	self:SendEmptyMsg(instance_pb, "C_QuitInstance")
end
--取开启的副本列表
function FBController:GetOpenMapList()
	self:SendEmptyMsg(instance_pb, "C_GetOpenMapList")
end
--放弃或者同意1：同意  2：拒绝
function FBController:AgreeEnter(state)
	local send = instance_pb.C_AgreeEnter()
	send.state = state
	self:SendMsg("C_AgreeEnter", send)
end
-- <<< c2s end

-- >>> s2c start
function FBController:GetOpenMapListCallBack(buffer)
	local msg = self:ParseMsg(instance_pb.S_GetOpenMapList(), buffer)
	self.model:RefreshFbList(msg)
end
function FBController:InstanceEndCallBack(buffer)--开启副本结束倒计时
	local rev = self:ParseMsg(instance_pb.S_InstanceEnd(), buffer)
	--广播服务器发来的副本结束倒计时
	GlobalDispatcher:DispatchEvent(EventName.FBFinishCutDown)
	if self.FinishFBCutDownTips == nil then
		self.FinishFBCutDownTips = PoPFinishFB.New()
		self.FinishFBCutDownTips:AddTo(layerMgr:GetMSGLayer())
		self.FinishFBCutDownTips.ui:SetXY(0,0)
		self.FinishFBCutDownTips:OnEnable(rev.result, rev.destroyTime)
	end
end

--多人副本通知--队长发起了进入副本的通知
function FBController:SynTeamStateCallBack(buffer)
	local rev = self:ParseMsg(instance_pb.S_SynTeamState(), buffer)
	if rev == nil then return end 
	local map = GetCfgData("mapManger"):Get(rev.mapId)

	for i=1,#rev.teamInsStates do
		print("==>> " .. rev.teamInsStates[i].state)
	end
	
	if rev.teamInsStates == nil then return end
	local t = true
	for i=1,#rev.teamInsStates do
		local teamInfo = rev.teamInsStates[i]
		local teamer = ZDModel:GetInstance():GetMember(teamInfo.teamPlayerId)
		if teamer then 
			teamer.state = teamInfo.state
			if teamer.state == 2 then -- 如果有玩家拒绝就关闭界面
				GlobalDispatcher:DispatchEvent(EventName.HasTeamerNoApplyEnterFB,{teamer})
				if self.cdBox then 
					self.cdBox:Destroy()
				end
				self.cdBox =nil
				return
			end
			
			if teamer.state ~= 1 then  --同意
				t = false
			end
		end
	end

	if t == true then
		-- self.cdBox:OnDisable()
		-- local data = { tType = "onlyshow", text = "副本传送中" }
		-- GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity, data)
		-- FBController:GetInstance():CloseMainPanel()
		return
	end
	--打开准备情况面板
	if self.cdBox == nil then 
		self.cdBox = CDMessageBox.New()
		self.cdBox:AddTo(layerMgr:GetMSGLayer())
	end

	self.cdBox:Refresh(map.map_name)
end
-- <<< s2c end

function FBController:GetInstance()
	if FBController.inst == nil then
		FBController.inst = FBController.New()
	end
	return FBController.inst
end

function FBController:__delete()
	if self.cdBox then 
		self.cdBox:Destroy()
	end
	self.cdBox = nil
	self:RemoveEvent()
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	if self:IsExistView() then
		self.view:Destroy()
	end
	self.view = nil
	FBController.inst = nil
end

function FBController:IsExistView()
	return self.view and self.view.isInited
end

function FBController:GetMainPanel()
	if not self:IsExistView() then
		self.view = FBUI.New()
	end
	return self.view
end

function FBController:CloseMainPanel()
	if self:IsExistView() then
		self.view:Close()
	end
	self.view = nil
end