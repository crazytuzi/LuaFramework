LoginBGComp = BaseClass(LuaUI)

function LoginBGComp:__init(...)
	self.URL = "ui://0qk3a0fjj2mz6";
	self:__property(...)
	self:Config()
end

function LoginBGComp:SetProperty(...)
	
end

function LoginBGComp:Config()
	self:InitUI()
	self:InitEvent()
end

function LoginBGComp:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Login","LoginBGComp")
	self.bg = self.ui:GetChild("bg")
	self.logo = self.ui:GetChild("logo")
	self.btnNotice = self.ui:GetChild("btnNotice")
	self.btnLogin = self.ui:GetChild("btnLogin")
	self.bgTips = self.ui:GetChild("bgTips")
	self.labelTips = self.ui:GetChild("labelTips")
	self.mask = self.ui:GetChild("mask")

	self.bg.url = "Icons/Loader/bg"
	self.logo.url = "Icons/Loader/gamename"
end

function LoginBGComp.Create(ui, ...)
	return LoginBGComp.New(ui, "#", {...})
end

function LoginBGComp:__delete()
end

function LoginBGComp:InitUI()
	self.btnNotice.icon = StringFormat("Icon/Activity/fun_5") 
	self.btnLogin.icon = StringFormat("Icon/Activity/fun_18")
	if isSDKPlat then
		self.btnLogin.visible = false
	end
	self:SetMaskVisible(true) --默认显示黑色透明底图
end

function LoginBGComp:InitEvent()
	local noticeHandle = function ()
		GgController:GetInstance():Open()
	end
	self.btnNotice.onClick:Add(noticeHandle)
	local loginHandle = function ()
		LoginController:GetInstance():OpenAccountManagerPanel()
	end
	self.btnLogin.onClick:Add(loginHandle)
end

function LoginBGComp:UnActiveBtns()
	self.btnLogin.visible = false
	self.btnNotice.visible = false
end

function LoginBGComp:SetMaskVisible(bl)
	if bl ~= nil and type(bl) == 'boolean' then
		self.mask.visible = bl				
	end
end

function LoginBGComp:__delete()
	if self.btnNotice then
		self.btnNotice:Dispose()
		self.btnNotice = nil
	end
	if self.btnLogin then
		self.btnLogin:Dispose()
		self.btnLogin = nil
	end
end