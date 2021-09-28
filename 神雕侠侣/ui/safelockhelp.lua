require "ui.dialog"
SafeLockHelpDlg = {}
setmetatable(SafeLockHelpDlg, Dialog)
SafeLockHelpDlg.__index = SafeLockHelpDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SafeLockHelpDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = SafeLockHelpDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SafeLockHelpDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = SafeLockHelpDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function SafeLockHelpDlg.getInstanceNotCreate()
    return _instance
end

function SafeLockHelpDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function SafeLockHelpDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SafeLockHelpDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function SafeLockHelpDlg.GetLayoutFileName()
    return "safelockmessage.layout"
end
function SafeLockHelpDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.msg0 = winMgr:getWindow("safelockmessage/mes0")
	self.msg1 = winMgr:getWindow("safelockmessage/mes1")
	self.msg2 = winMgr:getWindow("safelockmessage/mes2")
	self.msg3 = winMgr:getWindow("safelockmessage/mes3")

	self.closed = CEGUI.Window.toPushButton(winMgr:getWindow("safelockmessage/closed"))

	self.closed:subscribeEvent("Clicked", SafeLockHelpDlg.DestroyDialog, self)


end

------------------- private: -----------------------------------
function SafeLockHelpDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SafeLockHelpDlg)
    return self
end
function SafeLockHelpDlg.ShowMsg(args)
	local sf = SafeLockHelpDlg.getInstanceAndShow()
	sf:SetMsg(args)
end
function SafeLockHelpDlg:SetMsg(args)
	self.msg0:setVisible(false)
	self.msg1:setVisible(false)
	self.msg2:setVisible(false)
	self.msg3:setVisible(false)
	if id == 0 then
		self["msg0"]:setVisible(true)
	elseif id == 1 then
		self["msg1"]:setVisible(true)
	elseif id == 2 then
		self["msg3"]:setVisible(true)
	elseif id == 3 then
		self["msg2"]:setVisible(true)
	end

end

return SafeLockHelpDlg
