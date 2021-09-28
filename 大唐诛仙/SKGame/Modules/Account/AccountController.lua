RegistModules("Account/AccountConst")
RegistModules("Account/AccountModel")
RegistModules("Account/AccountView")

RegistModules("Account/View/ReBindStepOne")
RegistModules("Account/View/ReBindStepTow")
RegistModules("Account/View/AccountPanel")


AccountController =BaseClass(LuaController)

function AccountController:GetInstance()
	if AccountController.inst == nil then
		AccountController.inst = AccountController.New()
	end
	return AccountController.inst
end

function AccountController:__init()
	self.model = AccountModel:GetInstance()
	self.view = nil

	self:InitEvent()
	self:RegistProto()
end

function AccountController:__delete()
	self:CleanEvent()
	if self.view then
		self.view:Destroy()
		self.view = nil
	end

	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	AccountController.inst = nil
end

function AccountController:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
	end)
end

function AccountController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

-- 协议注册
function AccountController:RegistProto()
	self:RegistProtocal("S_BindPhone") --绑定
	self:RegistProtocal("S_GetBindInfo") --获取绑定信息
	self:RegistProtocal("S_GetValidateCode") --获取验证码
end

function AccountController:S_BindPhone(buff)
	local msg = self:ParseMsg(player_pb.S_BindPhone(), buff)
	self.model:ParseSBindPhone(msg)
end

function AccountController:S_GetBindInfo(buff)
	local msg = self:ParseMsg(player_pb.S_GetBindInfo(), buff)
	self.model:ParseSysBindState(msg)
end

function AccountController:S_GetValidateCode(buff)
	local msg = self:ParseMsg(player_pb.S_GetValidateCode(), buff)
	self.model:ParseBindData(msg)
	self.model:DispatchEvent(AccountConst.StartCountDown , msg.telePhone or 0)
end

--获取验证码
function AccountController:C_GetBindInfo(telePhone)
	local msg = player_pb.C_GetBindInfo()
	self:SendMsg("C_GetBindInfo", msg)
end

--获取验证码
function AccountController:C_GetValidateCode(telePhone)
	local msg = player_pb.C_GetValidateCode()
	msg.telePhone = telePhone
	self:SendMsg("C_GetValidateCode", msg)
end

--绑定
function AccountController:C_BindPhone(telePhone, bizId, code)
	local msg = player_pb.C_BindPhone()
	msg.telePhone = telePhone
	msg.bizId = tostring(bizId)
	msg.code = tonumber(code)
	self:SendMsg("C_BindPhone", msg)
end

--领取绑定奖励
function AccountController:C_GetBindReward()
	local msg = player_pb.C_GetBindReward()
	self:SendMsg("C_GetBindReward", msg)
end

function AccountController:GetAccountPanel()
	self:C_GetBindInfo()
	if self.view == nil then
		self.view = AccountView.New()
	end
	return self.view:GetAccountPanel()
end

function AccountController:DestroyAccountPanel()
	if self.view ~= nil then
		self.view:Destroy()
	end
	self.view = nil
end

function AccountController:Close()
	if self.view then 
		self.view:Close()
	end
end

