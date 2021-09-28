require "ui.dialog"
--require "ui.selectserversdialog"
LoginWaitingDialog = {}
setmetatable(LoginWaitingDialog, Dialog)
LoginWaitingDialog.__index = LoginWaitingDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LoginWaitingDialog.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = LoginWaitingDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LoginWaitingDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = LoginWaitingDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LoginWaitingDialog.getInstanceNotCreate()
    return _instance
end

function LoginWaitingDialog.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function LoginWaitingDialog.ToggleOpenClose()
	if not _instance then 
		_instance = LoginWaitingDialog:new() 
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

function LoginWaitingDialog.GetLayoutFileName()
    return "loginbackdialog.layout"
end

function LoginWaitingDialog:OnCreate()
	print("LoginWaitingDialog begin")
	if GetLoginManager() then
		GetLoginManager():ClearConnections()
	end
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    
    self.m_pReturnSelectSererBtn = CEGUI.Window.toPushButton(winMgr:getWindow("loginbackdialog/back"))

    -- subscribe event
    self.m_pReturnSelectSererBtn:subscribeEvent("Clicked", LoginWaitingDialog.HandleReturnSelectServerBtnPushed, self) 
end

------------------- private: -----------------------------------

function LoginWaitingDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LoginWaitingDialog)
    return self
end

function LoginWaitingDialog:HandleReturnSelectServerBtnPushed(args)
    print("click LoginWaitingDialog:HandleReturnSelectServerBtnPushed")
    self.DestroyDialog()
    SelectServersDialog.getInstanceAndShow()
	return true
end

return LoginWaitingDialog
