RegistModules("Setting/View/SettingPanel")

RegistModules("Setting/SettingView") -- 设置面板
RegistModules("Setting/SettingModel")
RegistModules("Setting/StgConst")

SettingCtrl = BaseClass(LuaController)

function SettingCtrl:GetInstance()
	if SettingCtrl.inst == nil then
		SettingCtrl.inst = SettingCtrl.New()
	end
	return SettingCtrl.inst
end

function SettingCtrl:__init()
	self.model = SettingModel:GetInstance()
	self.view = nil
	self:RegistProto()
end

--注册协议
function SettingCtrl:RegistProto()
	self:RegistProtocal("S_SetIsAcceptChat") -- 是否接收陌生人信息
	self:RegistProtocal("S_SetIsAcceptApply") -- 设置是否接受好友申请
	self:RegistProtocal("S_GetPlayerOptional") -- 设置信息
end	

function SettingCtrl:IsExistView()
	return self.view and self.view.isInited
end

function SettingCtrl:Open()
	if not self:IsExistView() then
		resMgr:AddUIAB("Setting")
		self.view = SettingView.New()
	end
	if self.view then
		self.view:Open()
	end
end

-- 发送
	function SettingCtrl:C_SetIsAcceptChat( state )
		local msg = player_pb.C_SetIsAcceptChat()
		msg.state = state
		self:SendMsg("C_SetIsAcceptChat", msg)
	end

	function SettingCtrl:C_SetIsAcceptApply( state )
		local msg = player_pb.C_SetIsAcceptApply()
		msg.state = state
		self:SendMsg("C_SetIsAcceptApply", msg)
	end

	function SettingCtrl:C_GetPlayerOptional()
		self:SendEmptyMsg(player_pb, "C_GetPlayerOptional")
	end

-- 接收
	function SettingCtrl:S_SetIsAcceptChat(buffer)
		local msg = self:ParseMsg(player_pb.S_SetIsAcceptChat(), buffer)
	end

	function SettingCtrl:S_SetIsAcceptApply(buffer)
		local msg = self:ParseMsg(player_pb.S_SetIsAcceptApply(), buffer)
	end	

	function SettingCtrl:S_GetPlayerOptional(buffer)
		local msg = self:ParseMsg(player_pb.S_GetPlayerOptional(), buffer)
		self.model:SetComuState(msg.isAcceptChat, msg.isAcceptApply)
		self.model:DispatchEvent(StgConst.DATA_CONTACT)
	end

-- 销毁
function SettingCtrl:__delete()
	SettingCtrl.inst = nil
	if self:IsExistView() then
		self.view:Destroy()
	end
	self.view = nil
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
end