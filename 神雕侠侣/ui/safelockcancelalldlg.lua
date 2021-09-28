require "ui.dialog"
SafeLockCancelAllDlg = {}
setmetatable(SafeLockCancelAllDlg, Dialog)
SafeLockCancelAllDlg.__index = SafeLockCancelAllDlg
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function SafeLockCancelAllDlg.getInstance()
	LogInfo("____SafeLockCancelAllDlg.getInstance")
    if not _instance then
        _instance = SafeLockCancelAllDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SafeLockCancelAllDlg.getInstanceAndShow()
	LogInfo("____SafeLockCancelAllDlg.getInstanceAndShow")
    if not _instance then
        _instance = SafeLockCancelAllDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
    return _instance
end


 
function SafeLockCancelAllDlg.getInstanceNotCreate()
    return _instance
end

function SafeLockCancelAllDlg.DestroyDialog()
	LogInfo("____SafeLockCancelAllDlg.DestroyDialog")
    if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function SafeLockCancelAllDlg.hasCreatedAndShow()
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

function SafeLockCancelAllDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SafeLockCancelAllDlg:new() 
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

function SafeLockCancelAllDlg.GetLayoutFileName()
    return "safelockcancelalldlg.layout"
end

function SafeLockCancelAllDlg:new()
    LogInfo("____SafeLockCancelAllDlg:new")
    
    local self = {}
    self = Dialog:new()
    setmetatable(self, SafeLockCancelAllDlg)
    return self
end

function SafeLockCancelAllDlg:OnCreate()
	LogInfo("____enter SafeLockCancelAllDlg:OnCreate")
    Dialog.OnCreate(self)

    self:GetWindow():setModalState(true)
    
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.pass = CEGUI.Window.toEditbox(winMgr:getWindow("safelockcancelalldlg/into"))
    self.cancel = CEGUI.Window.toPushButton(winMgr:getWindow("safelockcancelalldlg/cancel"))
    self.confirm = CEGUI.Window.toPushButton(winMgr:getWindow("safelockcancelalldlg/ok"))
	
    self.cancel:subscribeEvent("Clicked", SafeLockCancelAllDlg.cancelHandler, self)
    self.confirm:subscribeEvent("Clicked", SafeLockCancelAllDlg.confirmHandler, self)

	self.pass:setTextMasked(true)
	self.pass:setMaxTextLength(8)

	self.pass:subscribeEvent("MouseClick", SafeUnlockDlg.HandleEditClicked, self)
	self.pass:setReadOnly(true)


end
require "ui.numinputdlg"
function SafeUnlockDlg:HandleEditClicked(args)
	NumInputDlg.ToggleOpenClose()
	NumInputDlg.getInstance():setTargetWindow(self.pass)
end



function SafeLockCancelAllDlg:cancelHandler(args)
	self.DestroyDialog()
	SettingMainFrame.getInstanceAndShow()
	SettingMainFrame.getInstance():CheckLockHandler(1)
end


function SafeLockCancelAllDlg:confirmHandler(args)
	if self.pass:getText() ~= "" then
		local p = require "protocoldef.knight.gsp.lock.creqcancellock" : new()
		p.password = self.pass:getText()
		require "manager.luaprotocolmanager":send(p)
	else
		GetGameUIManager():AddMessageTipById(145380)
	end
end
function SafeLockCancelAllDlg.setSuccess()
print("SafeLockCancelAllDlgsetSuccess",_instance)
	if _instance then
		_instance.DestroyDialog()
		SettingMainFrame.getInstanceAndShow():HandleButton1Clicked()
	end
end 
return SafeLockCancelAllDlg
