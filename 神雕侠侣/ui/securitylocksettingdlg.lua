require "ui.dialog"
require "ui.settingmainframe"
require "utils.mhsdutils"
require "ui.safeunlockdlg"
require "ui.safelockcancelalldlg"
require "ui.safelockchangedlg"
SecurityLockSettingDlg = {}
setmetatable(SecurityLockSettingDlg, Dialog)
SecurityLockSettingDlg.__index = SecurityLockSettingDlg
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function SecurityLockSettingDlg.peekInstance()
	return _instance
end

function SecurityLockSettingDlg.getInstance()
	LogInfo("____SecurityLockSettingDlg.getInstance")
    if not _instance then
        _instance = SecurityLockSettingDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SecurityLockSettingDlg.getInstanceAndShow()
	LogInfo("____SecurityLockSettingDlg.getInstanceAndShow")
    if not _instance then
        _instance = SecurityLockSettingDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
    
    if not SettingMainFrame.peekInstance() then
        SettingMainFrame.getInstanceAndShow()
    end
    return _instance
end

function SecurityLockSettingDlg:SetVisible(bV)
	if bV == self.m_pMainFrame:isVisible() then
        return
    end
	self.m_pMainFrame:setVisible(bV);
	if bV and not SettingMainFrame.peekInstance() then
		SettingMainFrame.getInstanceAndShow()	
	end
end

function SecurityLockSettingDlg.getInstanceNotCreate()
    return _instance
end

function SecurityLockSettingDlg.DestroyDialog()
	LogInfo("____SecurityLockSettingDlg.DestroyDialog")
    if _instance then
		_instance:OnClose()
		_instance = nil
	end
    
    if SettingMainFrame:peekInstance() then
		SettingMainFrame.DestroyDialog()
	end
end

function SecurityLockSettingDlg.hasCreatedAndShow()
    if _instance then
        if _instance:IsVisible() then
            return 1
        else
            return 0
        end
    else
        return 0
    end
end
function SecurityLockSettingDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SecurityLockSettingDlg:new() 
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

function SecurityLockSettingDlg.GetLayoutFileName()
    return "safelockdlg.layout"
end

function SecurityLockSettingDlg:new()
    LogInfo("____SecurityLockSettingDlg:new")
    
    local self = {}
    self = Dialog:new()
    setmetatable(self, SecurityLockSettingDlg)
	self.m_bIsVisibleBeforeBattle = false
    return self
end

function SecurityLockSettingDlg:OnCreate()
	LogInfo("____enter SecurityLockSettingDlg:OnCreate")
    Dialog.OnCreate(self)

    self:GetWindow():setModalState(true)
    
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.unlock = CEGUI.Window.toPushButton(winMgr:getWindow("safelockdlg/btn0"))
    self.forceUnlock = CEGUI.Window.toPushButton(winMgr:getWindow("safelockdlg/btn1"))
    self.changePass = CEGUI.Window.toPushButton(winMgr:getWindow("safelockdlg/btn2"))
    self.cancelLock = CEGUI.Window.toPushButton(winMgr:getWindow("safelockdlg/btn3"))
	
    self.unlock:subscribeEvent("Clicked", SecurityLockSettingDlg.unlockHandler, self)
    self.forceUnlock:subscribeEvent("Clicked", SecurityLockSettingDlg.forceUnlockHandler, self)
    self.changePass:subscribeEvent("Clicked", SecurityLockSettingDlg.changePassHandler, self)
    self.cancelLock:subscribeEvent("Clicked", SecurityLockSettingDlg.cancelLockHandler, self)

	self.statusText = winMgr:getWindow("safelockdlg/txt01")

	self.unlockhelp = CEGUI.Window.toPushButton(winMgr:getWindow("safelockdlg/mes0"))
	self.forceUnlockhelp = CEGUI.Window.toPushButton(winMgr:getWindow("safelockdlg/mes1"))
    self.changePasshelp = CEGUI.Window.toPushButton(winMgr:getWindow("safelockdlg/mes2"))
    self.cancelLockhelp = CEGUI.Window.toPushButton(winMgr:getWindow("safelockdlg/mes3"))

	self.unlockhelp:setID(0)
	self.forceUnlockhelp:setID(1)
	self.changePasshelp:setID(2)
	self.cancelLockhelp:setID(3)

	self.unlockhelp:subscribeEvent("Clicked", SecurityLockSettingDlg.HelpHandler, self)
    self.forceUnlockhelp:subscribeEvent("Clicked", SecurityLockSettingDlg.HelpHandler, self)
    self.changePasshelp:subscribeEvent("Clicked", SecurityLockSettingDlg.HelpHandler, self)
    self.cancelLockhelp:subscribeEvent("Clicked", SecurityLockSettingDlg.HelpHandler, self)
	self:RefreshLockStatus()



end

function SecurityLockSettingDlg:HelpHandler(args)
	require "ui.safelockhelp"
	id = CEGUI.toWindowEventArgs(args).window:getID()
	SafeLockHelpDlg.ShowMsg(id)
end

local lockStatus = 0
function SecurityLockSettingDlg.SetLockStatus(status)
	lockStatus = status
	if SecurityLockSettingDlg.peekInstance() ~= nil then
		SecurityLockSettingDlg.peekInstance():RefreshLockStatus()
	end
end
function SecurityLockSettingDlg:RefreshLockStatus()
	if lockStatus == 2 then
		self.statusText:setVisible(true)
		self.statusText:setText(MHSD_UTILS.get_resstring(3010))
	elseif lockStatus == 1 then
		self.statusText:setVisible(true)
		self.statusText:setText(MHSD_UTILS.get_resstring(3009))
	else
		self.statusText:setVisible(false)
	end
end
function SecurityLockSettingDlg:unlockHandler(args)
	SafeUnlockDlg.showMode = 1
	SafeUnlockDlg.getInstanceAndShow()
	SettingMainFrame.DestroyDialog()
end

function SecurityLockSettingDlg:okConfirmForceUnlockHandler(args)
	local p = require "protocoldef.knight.gsp.lock.creqforceunlock" : new()
	require "manager.luaprotocolmanager":send(p)
	self:cancelConfirmForceUnlockHandler()
end
function SecurityLockSettingDlg.cancelConfirmForceUnlockHandler(args)
	if SecurityLockSettingDlg.peekInstance() ~= nil then
		SecurityLockSettingDlg.peekInstance():gSetVisible(true)
	end
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end
function SecurityLockSettingDlg:gSetVisible(b)
	if SettingMainFrame.peekInstance() ~= nil then
		SettingMainFrame.peekInstance():SetVisible(b)
	end
	self:SetVisible(b)
end
function SecurityLockSettingDlg:forceUnlockHandler(args)
	GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145353),SecurityLockSettingDlg.okConfirmForceUnlockHandler,self,SecurityLockSettingDlg.cancelConfirmForceUnlockHandler,SecurityLockSettingDlg)
	self:gSetVisible(false)	
end


function SecurityLockSettingDlg:changePassHandler(args)
SafeLockChangeDlg.getInstanceAndShow()
SettingMainFrame.DestroyDialog()

end


function SecurityLockSettingDlg:cancelLockHandler(args)
	SafeLockCancelAllDlg.getInstanceAndShow()
	SettingMainFrame.DestroyDialog()
end


return SecurityLockSettingDlg
