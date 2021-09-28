require "ui.dialog"
require "ui.selectserversdialog"

LoginDialog = {}
setmetatable(LoginDialog, Dialog)
LoginDialog.__index = LoginDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LoginDialog.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = LoginDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LoginDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = LoginDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LoginDialog.getInstanceNotCreate()
    return _instance
end

function LoginDialog.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function LoginDialog.ToggleOpenClose()
	if not _instance then 
		_instance = LoginDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function LoginDialog.GetLayoutFileName()
    return "LoginDialog.layout"
end

function LoginDialog:OnCreate()
	print("login enter oncreate begin")
    Dialog.OnCreate(self)

	print("login enter oncreate begin oncreate")
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_Account = CEGUI.Window.toEditbox(winMgr:getWindow("LoginDialog/nameEdit"))
    self.m_KeyEdit = CEGUI.Window.toEditbox(winMgr:getWindow("LoginDialog/keyEdit"))
    self.m_LoginBtn = CEGUI.Window.toPushButton(winMgr:getWindow("LoginDialog/LoginBtn"));
    self.m_pSelectServers = CEGUI.Window.toPushButton(winMgr:getWindow("LoginDialog/servername"));
    self.m_pRegisterAccount = CEGUI.Window.toPushButton(winMgr:getWindow("LoginDialog/back/Regist"));

    -- subscribe event
    self.m_LoginBtn:subscribeEvent("Clicked", LoginDialog.HandleLoginBtnClick, self) 
    self.m_LoginBtn:subscribeEvent("LongPress", LoginDialog.HandleLongPress, self) 

    self.m_pSelectServers:subscribeEvent("Clicked", LoginDialog.HandleSelectServersBtnClick, self) 

    self.m_pRegisterAccount:subscribeEvent("Clicked", LoginDialog.HandleRegisterAccountBtnClick, self) 

    self.m_KeyEdit:subscribeEvent("Activated", LoginDialog.HandleKeyEditActivate, self) 
    self.m_KeyEdit:subscribeEvent("Deactivated", LoginDialog.HandleKeyEditDeactivate, self) 
    
    --init settings
    self.m_KeyEdit:setTextMasked(true);
    self.m_KeyEdit:setMaxTextLength(self.MAX_LENGTH_PASSWORD)

    local selectservername = GetLoginManager():GetSelectServer()
	print(selectservername)
	self.m_pSelectServers:setText(selectservername)

	print("login enter oncreate end")

	self:InitAccountList()
end

------------------- private: -----------------------------------

local SERVER_INFO_INI = "LastServerAccount.ini"

function LoginDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LoginDialog)

    self.MAX_LENGTH_PASSWORD = 16

    return self
end

function LoginDialog:InitAccountList()

	local strLastAccount = GetLoginManager():GetAccount()
    self.m_Account:setText(strLastAccount)
    
    local strLastPassword = GetLoginManager():GetPassword()
    self.m_KeyEdit:setText(strLastPassword)
    
    return true

end

function LoginDialog:HandleLoginBtnClick(args)
    print("login btn clicked") 
    
    self:LoginGame()
    return true
end

function LoginDialog:HandleLongPress(args)
    print("long press") 
    return true
end

function LoginDialog:HandleSelectServersBtnClick(args)
    print("select servers btn clicked") 
	GetLoginManager():ToServerChoose(GetLoginManager():GetSelectArea(), GetLoginManager():GetSelectServer())
	SelectServersDialog.getInstanceAndShow()
	self.DestroyDialog()
    return true
end

function LoginDialog:HandleRegisterAccountBtnClick(args)
    print("register account btn clicked") 
    return true
end

function LoginDialog:HandleKeyEditActivate(args)
    print("Activate servers btn clicked") 
    return true
end

function LoginDialog:HandleKeyEditDeactivate(args)
    print("deactivate key clicked") 
    return true
end

function LoginDialog:LoginGame()

    local account = self.m_Account:getText()
    
    if account == "" then
        GetGameUIManager():AddMessageTipById(144784)
        return true
    end

	print(account)
    local key = self.m_KeyEdit:getText()
	if key == "" then
        GetGameUIManager():AddMessageTipById(144784)
        return true
    end

	print(key)
    local host = GetLoginManager():GetHost()
	print(host)
    local port = GetLoginManager():GetPort()
	print(port)
	local servername = GetLoginManager():GetSelectServer()
	local area = GetLoginManager():GetSelectArea()
	
    GetGameApplication():CreateConnection(account, key, host, port, true, servername, area)
    
    GetLoginManager():SetAccountInfo(account)
    GetLoginManager():SetPassword(key)
end

return LoginDialog
