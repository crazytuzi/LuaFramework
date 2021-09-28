require "ui.dialog"

CampBulletinDlg = {}
setmetatable(CampBulletinDlg, Dialog)
CampBulletinDlg.__index = CampBulletinDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CampBulletinDlg.getInstance()
	print("enter get campbulletindlg dialog instance")
    if not _instance then
        _instance = CampBulletinDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampBulletinDlg.getInstanceAndShow()
	print("enter campbulletindlg dialog instance show")
    if not _instance then
        _instance = CampBulletinDlg:new()
        _instance:OnCreate()
	else
		print("set campbulletindlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampBulletinDlg.getInstanceNotCreate()
    return _instance
end

function CampBulletinDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function CampBulletinDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CampBulletinDlg:new() 
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

function CampBulletinDlg.GetLayoutFileName()
    return "campleadernomination.layout"
end

function CampBulletinDlg:OnCreate()
	print("campbulletindlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pOKBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campleadernomination/jingying"))
    self.m_pCancelBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campleadernomination/Pmin"))
	self.m_pEditBox = CEGUI.Window.toRichEditbox(winMgr:getWindow("campleadernomination/Back/editbox"))
	self.m_pTxt = winMgr:getWindow("campleadernomination/Back/text")

    -- subscribe event
    self.m_pOKBtn:subscribeEvent("Clicked", CampBulletinDlg.HandleOKBtnClicked, self) 
    self.m_pCancelBtn:subscribeEvent("Clicked", CampBulletinDlg.HandleCancelBtnClicked, self) 

	self.m_pEditBox:setMaxTextLength(self.MAX_LENGTH)

	print("campbulletindlg dialog oncreate end")
end

------------------- private: -----------------------------------


function CampBulletinDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampBulletinDlg)

	self.MAX_LENGTH = 100
    return self
end

function CampBulletinDlg:Refresh(num)
	local strBuilder = StringBuilder:new()
	strBuilder:Set("parameter1", num)
	self.m_pTxt:setText(strBuilder:GetString(MHSD_UTILS.get_resstring(3038)))
	strBuilder:delete()
end

function CampBulletinDlg:HandleOKBtnClicked(args)
	print("campbulletindlg ok clicked")
	self.m_pEditBox:setMaxTextLength(self.MAX_LENGTH)
--	local code_length = string.len(string.format("%s", self.m_pEditBox:getText()))
--	if code_length > self.MAX_LENGTH then
--		GetGameUIManager():AddMessageTipById(145433)
--		return true
--	end
	local MHSD_UTILS = require "utils.mhsdutils"
	local hasShieldText, strAfterShild = MHSD_UTILS.ShiedText(self.m_pEditBox:GetPureText())
	local req = require "protocoldef.knight.gsp.campleader.csendcampfriendmsg".Create()
	req.frdmsg = strAfterShild
	LuaProtocolManager.getInstance():send(req)
	CampBulletinDlg.DestroyDialog()
	LogErr(strAfterShild)
	return true
end

function CampBulletinDlg:HandleCancelBtnClicked(args)
	print("campbulletindlg cancel clicked")
	CampBulletinDlg.DestroyDialog()
	return true
end

return CampBulletinDlg
