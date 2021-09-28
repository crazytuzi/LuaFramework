require "ui.dialog"

CampSayDlg = {}
setmetatable(CampSayDlg, Dialog)
CampSayDlg.__index = CampSayDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CampSayDlg.getInstance()
	print("enter get campsaydlg dialog instance")
    if not _instance then
        _instance = CampSayDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampSayDlg.getInstanceAndShow()
	print("enter campsaydlg dialog instance show")
    if not _instance then
        _instance = CampSayDlg:new()
        _instance:OnCreate()
	else
		print("set campsaydlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampSayDlg.getInstanceNotCreate()
    return _instance
end

function CampSayDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function CampSayDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CampSayDlg:new() 
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

function CampSayDlg.GetLayoutFileName()
    return "campsaydlg.layout"
end

function CampSayDlg:OnCreate()
	print("campsaydlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pOKBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campsaydlg/ok"))
    self.m_pCancelBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campsaydlg/Canle"))
	self.m_pEditBox = CEGUI.Window.toEditbox(winMgr:getWindow("campsaydlg/info"))

    -- subscribe event
    self.m_pOKBtn:subscribeEvent("Clicked", CampSayDlg.HandleOKBtnClicked, self) 
    self.m_pCancelBtn:subscribeEvent("Clicked", CampSayDlg.HandleCancelBtnClicked, self) 

	self.m_pEditBox:setMaxTextLength(self.MAX_LENGTH)

	print("campsaydlg dialog oncreate end")
end

------------------- private: -----------------------------------


function CampSayDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampSayDlg)

	self.MAX_LENGTH = 20
    return self
end

function CampSayDlg:HandleOKBtnClicked(args)
	print("campsaydlg ok clicked")
	self.m_pEditBox:setMaxTextLength(self.MAX_LENGTH)
--	local code_length = string.len(string.format("%s", self.m_pEditBox:getText()))
--	if code_length > self.MAX_LENGTH then
--		GetGameUIManager():AddMessageTipById(145433)
--		return true
--	end
	local MHSD_UTILS = require "utils.mhsdutils"
	local hasShieldText, strAfterShild = MHSD_UTILS.ShiedText(self.m_pEditBox:getText())
	local req = require "protocoldef.knight.gsp.campleader.crequpdatemes".Create()
	req.mes = strAfterShild
	LuaProtocolManager.getInstance():send(req)
	CampSayDlg.DestroyDialog()
	return true
end

function CampSayDlg:HandleCancelBtnClicked(args)
	print("campsaydlg cancel clicked")
	CampSayDlg.DestroyDialog()
	return true
end

return CampSayDlg
