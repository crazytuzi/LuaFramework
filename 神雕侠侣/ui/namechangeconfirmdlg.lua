require "ui.dialog"
require "utils.mhsdutils"

NameChangeConfirmDlg = {}
setmetatable(NameChangeConfirmDlg, Dialog)
NameChangeConfirmDlg.__index = NameChangeConfirmDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function NameChangeConfirmDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = NameChangeConfirmDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function NameChangeConfirmDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = NameChangeConfirmDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function NameChangeConfirmDlg.getInstanceNotCreate()
    return _instance
end

function NameChangeConfirmDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function NameChangeConfirmDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NameChangeConfirmDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function NameChangeConfirmDlg.GetLayoutFileName()
    return "inputdialog.layout"
end
function NameChangeConfirmDlg:OnCreate()
	local prefix = "namechangeconfirmdlg"
    Dialog.OnCreate(self,nil,prefix)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self:GetWindow():setAlwaysOnTop(true)

	self.m_pTitle = winMgr:getWindow(prefix .. "InPutDialog/Title")
	self.m_pText = winMgr:getWindow(prefix .. "InPutDialog/text")
	self.m_pEditBox = CEGUI.Window.toEditbox(winMgr:getWindow(prefix .. "InPutDialog/edit"))
	self.m_pOKBtn =  CEGUI.Window.toPushButton(winMgr:getWindow(prefix .. "InPutDialog/OK"))
	self.m_pCanleBtn = CEGUI.Window.toPushButton(winMgr:getWindow(prefix .. "InPutDialog/Cancle"))
	self.pclosebtn = CEGUI.Window.toPushButton(winMgr:getWindow(prefix .. "InPutDialog/closed"))

	self.m_pOKBtn:subscribeEvent("Clicked",NameChangeConfirmDlg.HandleOkBtnClicked,self)
	self.m_pCanleBtn:subscribeEvent("Clicked",NameChangeConfirmDlg.HandleDefaultEvent,self)
	self.pclosebtn:subscribeEvent("Clicked",NameChangeConfirmDlg.HandleCloseBtnClick,self)

	self.m_pText:setText(MHSD_UTILS.get_resstring(3025))
	self.modifycount = 0
	self.itemid = 0

end

------------------- private: -----------------------------------
function NameChangeConfirmDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NameChangeConfirmDlg)
    return self
end
function NameChangeConfirmDlg:HandleCloseBtnClick(args)
	self.DestroyDialog()
end

function NameChangeConfirmDlg:HandleOkBtnClicked(args)
	if string.len(self.m_pEditBox:getText()) > 24 or string.len(self.m_pEditBox:getText()) <2 then
		GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(145627))
		return
	end

	require "utils.stringbuilder"
	local strBuild = StringBuilder:new()
	strBuild:Set("parameter1", self.modifycount)
	strBuild:Set("parameter2", self.m_pEditBox:getText())
	GetMessageManager():AddConfirmBox(eConfirmNormal,strBuild:GetString(MHSD_UTILS.get_msgtipstring(144667)), self.HandleConfirm,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
	strBuild:delete()
	self.DestroyDialog()
end

function NameChangeConfirmDlg:HandleConfirm(args)
	local p = require "protocoldef.knight.gsp.cchangerolename":new()
	p.newname = self.m_pEditBox:getText()
	p.itemkey = self.itemid 
	require "manager.luaprotocolmanager":send(p)
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function NameChangeConfirmDlg:HandleDefaultEvent(args)
	self.DestroyDialog()
end

function NameChangeConfirmDlg:process(modifycount,itemid)
	self.modifycount = modifycount
	self.itemid = itemid
end


return NameChangeConfirmDlg
