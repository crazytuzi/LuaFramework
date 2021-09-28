require "ui.dialog"
SafeUnlockDlg = {}
setmetatable(SafeUnlockDlg, Dialog)
SafeUnlockDlg.__index = SafeUnlockDlg
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function SafeUnlockDlg.getInstance()
	LogInfo("____SafeUnlockDlg.getInstance")
    if not _instance then
        _instance = SafeUnlockDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SafeUnlockDlg.getInstanceAndShow()
	LogInfo("____SafeUnlockDlg.getInstanceAndShow")
    if not _instance then
        _instance = SafeUnlockDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
    return _instance
end



function SafeUnlockDlg.getInstanceNotCreate()
    return _instance
end

function SafeUnlockDlg.DestroyDialog()
	LogInfo("____SafeUnlockDlg.DestroyDialog")
    if _instance then
		NumInputDlg.DestroyDialog()
		_instance:OnClose()
		_instance = nil
	end
end

function SafeUnlockDlg.hasCreatedAndShow()
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

function SafeUnlockDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SafeUnlockDlg:new() 
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

function SafeUnlockDlg.GetLayoutFileName()
    return "safelockcanceldlg.layout"
end

function SafeUnlockDlg:new()
    LogInfo("____SafeUnlockDlg:new")
    
    local self = {}
    self = Dialog:new()
    setmetatable(self, SafeUnlockDlg)
    return self
end

function SafeUnlockDlg:OnCreate()
	LogInfo("____enter SafeUnlockDlg:OnCreate")
    Dialog.OnCreate(self)

    self:GetWindow():setModalState(true)
    
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.pass = CEGUI.Window.toEditbox(winMgr:getWindow("safelockcanceldlg/into"))
    self.cancel = CEGUI.Window.toPushButton(winMgr:getWindow("safelockcanceldlg/cancel"))
    self.force = CEGUI.Window.toPushButton(winMgr:getWindow("safelockcanceldlg/do"))
    self.unlock = CEGUI.Window.toPushButton(winMgr:getWindow("safelockcanceldlg/ok"))
	
    self.cancel:subscribeEvent("Clicked", SafeUnlockDlg.cancelHandler, self)
    self.force:subscribeEvent("Clicked", SafeUnlockDlg.forceHandler, self)
    self.unlock:subscribeEvent("Clicked", SafeUnlockDlg.unlockHandler, self)

	self.pass:setTextMasked(true)
	self.pass:setMaxTextLength(8)


	self.pass:subscribeEvent("MouseClick", SafeUnlockDlg.HandleEditClicked, self)
	self.pass:setReadOnly(true)


end

require "ui.numinputdlg"
function SafeUnlockDlg:HandleEditClicked(args)
--	CNumInputDlg:ToggleOpenHide()
--  CNumInputDlg:GetSingleton():setTargetWindow(self.pass);
	NumInputDlg.ToggleOpenClose()
	NumInputDlg.getInstance():setTargetWindow(self.pass)
end

function SafeUnlockDlg:okConfirmForceUnlockHandler(args)
	local p = require "protocoldef.knight.gsp.lock.creqforceunlock" : new()
	require "manager.luaprotocolmanager":send(p)
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	
	self:cancelHandler()
end


function SafeUnlockDlg:cancelHandler(args)
	self.DestroyDialog()
	if SafeUnlockDlg.showMode == 1 then
		SettingMainFrame.getInstanceAndShow()
		SettingMainFrame.getInstance():CheckLockHandler(1)
		SafeUnlockDlg.showMode = 0
	end
end


function SafeUnlockDlg:forceHandler(args)
	GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145353),SafeUnlockDlg.okConfirmForceUnlockHandler,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
end


function SafeUnlockDlg:unlockHandler(args)
	if self.pass:getText() ~= "" then
		local p = require "protocoldef.knight.gsp.lock.crequnlock":new()
		p.password = self.pass:getText()
		require "manager.luaprotocolmanager":send(p)
		print("call protocoldef.knight.gsp.lock.crequnlock")
	else
		GetGameUIManager():AddMessageTipById(145380)
	end
end
function SafeUnlockDlg.setSuccess()
	if _instance then
		print("SafeUnlockDlgsetSuccessk")
		_instance:cancelHandler()
	end
end
return SafeUnlockDlg
