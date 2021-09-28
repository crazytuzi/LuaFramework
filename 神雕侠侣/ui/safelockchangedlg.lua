require "ui.dialog"
SafeLockChangeDlg = {}
setmetatable(SafeLockChangeDlg, Dialog)
SafeLockChangeDlg.__index = SafeLockChangeDlg
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function SafeLockChangeDlg.getInstance()
	LogInfo("____SafeLockChangeDlg.getInstance")
    if not _instance then
        _instance = SafeLockChangeDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SafeLockChangeDlg.getInstanceAndShow()
	LogInfo("____SafeLockChangeDlg.getInstanceAndShow")
    if not _instance then
        _instance = SafeLockChangeDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
    return _instance
end




function SafeLockChangeDlg.getInstanceNotCreate()
    return _instance
end

function SafeLockChangeDlg.DestroyDialog()
	LogInfo("____SafeLockChangeDlg.DestroyDialog")
    if _instance then
		NumInputDlg.DestroyDialog()
		_instance:OnClose()
		_instance = nil
	end
end

function SafeLockChangeDlg.hasCreatedAndShow()
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

function SafeLockChangeDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SafeLockChangeDlg:new() 
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

function SafeLockChangeDlg.GetLayoutFileName()
    return "safelockchangedlg.layout"
end

function SafeLockChangeDlg:new()
    LogInfo("____SafeLockChangeDlg:new")
    
    local self = {}
    self = Dialog:new()
    setmetatable(self, SafeLockChangeDlg)
    return self
end

function SafeLockChangeDlg:OnCreate()
	LogInfo("____enter SafeLockChangeDlg:OnCreate")
    Dialog.OnCreate(self)

    self:GetWindow():setModalState(true)
    
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.oldpass = CEGUI.Window.toEditbox(winMgr:getWindow("safelockchangedlg/into0"))
    self.newpass = CEGUI.Window.toEditbox(winMgr:getWindow("safelockchangedlg/into1"))
    self.renewpass = CEGUI.Window.toEditbox(winMgr:getWindow("safelockchangedlg/into2"))
    self.cancel = CEGUI.Window.toPushButton(winMgr:getWindow("safelockchangedlg/cancel"))
    self.confirm = CEGUI.Window.toPushButton(winMgr:getWindow("safelockchangedlg/ok"))
    self.cancel:subscribeEvent("Clicked", SafeLockChangeDlg.cancelHandler, self)
    self.confirm:subscribeEvent("Clicked", SafeLockChangeDlg.confirmHandler, self)

	self.oldpass:setTextMasked(true)
	self.newpass:setTextMasked(true)
	self.renewpass:setTextMasked(true)

	self.oldpass:setMaxTextLength(8)
	self.newpass:setMaxTextLength(8)
	self.renewpass:setMaxTextLength(8)


	self.oldpass:activate()
	

	self.oldpass:subscribeEvent("MouseClick", SafeLockChangeDlg.HandleEditClicked1, self)
	self.oldpass:setReadOnly(true)

	self.newpass:subscribeEvent("MouseClick", SafeLockChangeDlg.HandleEditClicked2, self)
	self.newpass:setReadOnly(true)
	self.newpass:subscribeEvent("TextChanged", SafeLockChangeDlg.HandleMsgChanged, self)

	self.renewpass:subscribeEvent("MouseClick", SafeLockChangeDlg.HandleEditClicked3, self)
	self.renewpass:setReadOnly(true)



end
function SafeLockChangeDlg:HandleMsgChanged(args)
print("HandleMsgChanged",string.sub(self.newpass:getText(),1,8))
	if string.len(self.newpass:getText()) > 8 then
		GetGameUIManager():AddMessageTipById(145350)
		self.newpass:setText(string.sub(self.newpass:getText(),1,8))
	end
end

require "ui.numinputdlg"
function SafeLockChangeDlg:HandleEditClicked1(args)
--	CNumInputDlg:ToggleOpenHide()
--  CNumInputDlg:GetSingleton():setTargetWindow(self.oldpass)

	NumInputDlg.ToggleOpenClose()
	NumInputDlg.getInstance():setTargetWindow(self.oldpass)

end

function SafeLockChangeDlg:HandleEditClicked2(args)
--	CNumInputDlg:ToggleOpenHide()
--    CNumInputDlg:GetSingleton():setTargetWindow(self.newpass)

	
	NumInputDlg.ToggleOpenClose()
	NumInputDlg.getInstance():setTargetWindow(self.newpass)

end

function SafeLockChangeDlg:HandleEditClicked3(args)
--	CNumInputDlg:ToggleOpenHide()
--  CNumInputDlg:GetSingleton():setTargetWindow(self.renewpass)

	NumInputDlg.ToggleOpenClose()
	NumInputDlg.getInstance():setTargetWindow(self.renewpass)

end


function SafeLockChangeDlg:cancelHandler(args)
	self.DestroyDialog()
	SettingMainFrame.getInstanceAndShow()
	SettingMainFrame.getInstance():CheckLockHandler(1)
end

function SafeLockChangeDlg:confirmHandler(args)
	if  self.oldpass:getText() == "" then
		GetGameUIManager():AddMessageTipById(145388)
	elseif  self.newpass:getText() == "" then
		GetGameUIManager():AddMessageTipById(145389)
	elseif string.len(self.newpass:getText()) < 6 or string.len(self.newpass:getText()) > 8 then
		GetGameUIManager():AddMessageTipById(145350)
		self.renewpass:setText("")
		self.newpass:setText("")
		self.newpass:activate()
	elseif  self.newpass:getText() ~= self.renewpass:getText() then
		self.renewpass:setText("")
		self.newpass:setText("")
		GetGameUIManager():AddMessageTipById(145355)
	else
		local p = require "protocoldef.knight.gsp.lock.creqchangepassword" : new()
			p.oldpassword = self.oldpass:getText() 
		p.newpassword = self.renewpass:getText()
		require "manager.luaprotocolmanager" : send(p)
	end
end
function SafeLockChangeDlg.setSuccess()
	if _instance then
		_instance:cancelHandler()
	end
end
return SafeLockChangeDlg
