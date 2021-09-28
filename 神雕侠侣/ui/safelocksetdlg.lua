require "ui.dialog"
SafeLockSetDlg = {}
setmetatable(SafeLockSetDlg, Dialog)
SafeLockSetDlg.__index = SafeLockSetDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SafeLockSetDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = SafeLockSetDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SafeLockSetDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = SafeLockSetDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function SafeLockSetDlg.getInstanceNotCreate()
    return _instance
end

function SafeLockSetDlg.DestroyDialog()
	if _instance then
		NumInputDlg.DestroyDialog()
		_instance:OnClose()		
		_instance = nil
	end
end

function SafeLockSetDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SafeLockSetDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function SafeLockSetDlg.GetLayoutFileName()
    return "safelocksetdlg.layout"
end
function SafeLockSetDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	

	
	self.password = CEGUI.Window.toEditbox(winMgr:getWindow("safelocksetdlg/into0"))
	self.rePassword = CEGUI.Window.toEditbox(winMgr:getWindow("safelocksetdlg/into1"))
	self.okButton = CEGUI.Window.toPushButton(winMgr:getWindow("safelocksetdlg/ok"))
	self.cancelButton = CEGUI.Window.toPushButton(winMgr:getWindow("safelocksetdlg/cancel"))


	self.password:setTextMasked(true)
	self.rePassword:setTextMasked(true)
--	self.password:setMaxTextLength(8)
	self.rePassword:setMaxTextLength(8)
--	self.password:SetOnlyNumberMode(true,99999999)
--	self.rePassword:SetOnlyNumberMode(true,99999999)
    -- get windows
  --  self.m_Account = CEGUI.Window.toEditbox(winMgr:getWindow("SafeLockSetDlg/nameEdit"))
  --
	self.password:subscribeEvent("MouseClick", SafeLockSetDlg.HandleEditClicked, self)
	self.password:setReadOnly(true)


	self.rePassword:subscribeEvent("MouseClick", SafeLockSetDlg.HandleReEditClicked, self)
	self.rePassword:setReadOnly(true)


	self.password:subscribeEvent("TextChanged", SafeLockSetDlg.HandleMsgChanged, self)
  
    self.okButton:subscribeEvent("Clicked", SafeLockSetDlg.okHandler, self) 
    self.cancelButton:subscribeEvent("Clicked", SafeLockSetDlg.cancelHandler, self)
	self.password:activate()
	--
end

------------------- private: -----------------------------------
function SafeLockSetDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SafeLockSetDlg)
    return self
end
function SafeLockSetDlg:HandleEditClicked(args)
--	CNumInputDlg:ToggleOpenHide()
--    CNumInputDlg:GetSingleton():setTargetWindow(self.password)

	NumInputDlg.ToggleOpenClose()
    NumInputDlg.getInstance():setTargetWindow(self.password)

end
require "ui.numinputdlg"
function SafeLockSetDlg:HandleReEditClicked(args)
--	CNumInputDlg:ToggleOpenHide()
--    CNumInputDlg:GetSingleton():setTargetWindow(self.rePassword)

	NumInputDlg.ToggleOpenClose()
    NumInputDlg.getInstance():setTargetWindow(self.rePassword)

end


function SafeLockSetDlg:HandleMsgChanged(args)
	if string.len(self.password:getText()) > 8 then
		GetGameUIManager():AddMessageTipById(145350)
		self.password:setText(string.sub(self.password:getText(),1,8))
	end
end
function SafeLockSetDlg:okHandler(args)
--	self.password
--		self.rePassword
	if self.password:getText() == ""  then
		GetGameUIManager():AddMessageTipById(145380)
	elseif string.len(self.password:getText()) < 6 or string.len(self.password:getText()) > 8  then 
		GetGameUIManager():AddMessageTipById(145350)
		self.password:setText("")
		self.rePassword:setText("")
		self.password:activate()
	elseif self.password:getText() ~= self.rePassword:getText() then
		self.password:setText("")
		self.rePassword:setText("")
		GetGameUIManager():AddMessageTipById(145348)
	else
		local p = require "protocoldef.knight.gsp.lock.creqaddlock":new()
		p.password = self.rePassword:getText()
		require "manager.luaprotocolmanager":send(p)
	end
end
function SafeLockSetDlg.setSuccess()
print("SafeLockSetDlgsetSuccess",_instance)
	if _instance then
		_instance:SetVisible(false)
		SettingMainFrame.getInstance():SetVisible(true)
		SettingMainFrame.getInstance():CheckLockHandler(1)
	end
end
function SafeLockSetDlg:cancelHandler(args)
	SettingMainFrame.getInstance():SetVisible(true)
	SettingMainFrame.getInstanceAndShow():HandleButton1Clicked()
	self:SetVisible(false)
	self.password:setText("")
	self.rePassword:setText("") 
end

return SafeLockSetDlg
