require "ui.dialog"
require "utils.mhsdutils"
TeampvpSignupDlg = {}
setmetatable(TeampvpSignupDlg, Dialog)
TeampvpSignupDlg.__index = TeampvpSignupDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeampvpSignupDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = TeampvpSignupDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeampvpSignupDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = TeampvpSignupDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeampvpSignupDlg.getInstanceNotCreate()
    return _instance
end

function TeampvpSignupDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function TeampvpSignupDlg.ToggleOpenClose()
	if not _instance then 
		_instance = TeampvpSignupDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function TeampvpSignupDlg.GetLayoutFileName()
    return "teampvpname.layout"
end
function TeampvpSignupDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

	self.confirm = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpname/ok"))
	self.cancel = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpname/Canle"))
	self.nameinfo = CEGUI.Window.toEditbox(winMgr:getWindow("teampvpname/info"))
	self.confirm:subscribeEvent("Clicked",TeampvpSignupDlg.HandleConfirm,self)
	self.cancel:subscribeEvent("MouseClick",TeampvpSignupDlg.HandleCancelClicked,self)

end

------------------- private: -----------------------------------
function TeampvpSignupDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeampvpSignupDlg)
    return self
end
function TeampvpSignupDlg:HandleConfirm(args)
	if self.nameinfo:getText() == "" then
		return
	end
	local p = require "protocoldef.knight.gsp.faction.capplyfactionteam":new() 
	p.teamname = self.nameinfo:getText()
	require "manager.luaprotocolmanager":send(p)
	self.DestroyDialog()
end

function TeampvpSignupDlg:HandleCancelClicked(args)
	self.DestroyDialog()
end



return TeampvpSignupDlg
