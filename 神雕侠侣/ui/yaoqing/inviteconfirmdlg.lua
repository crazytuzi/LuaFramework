require "ui.dialog"
require "protocoldef.knight.gsp.friends.csetinvitepeople"

InviteConfirmDlg = {}
setmetatable(InviteConfirmDlg, Dialog)
InviteConfirmDlg.__index = InviteConfirmDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function InviteConfirmDlg.getInstance()
	print("enter get convertdlg dialog instance")
    if not _instance then
        _instance = InviteConfirmDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function InviteConfirmDlg.getInstanceAndShow()
	print("enter convertdlg dialog instance show")
    if not _instance then
        _instance = InviteConfirmDlg:new()
        _instance:OnCreate()
	else
		print("set convertdlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function InviteConfirmDlg.getInstanceNotCreate()
    return _instance
end

function InviteConfirmDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function InviteConfirmDlg.ToggleOpenClose()
	if not _instance then 
		_instance = InviteConfirmDlg:new() 
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

function InviteConfirmDlg.GetLayoutFileName()
    return "inviteconfirm.layout"
end

function InviteConfirmDlg:OnCreate()
	print("convertdlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pOKBtn = CEGUI.Window.toPushButton(winMgr:getWindow("inviteconfirm/ok"))
    self.m_pCancelBtn = CEGUI.Window.toPushButton(winMgr:getWindow("inviteconfirm/cancel"))
	self.m_pEditBox = CEGUI.Window.toEditbox(winMgr:getWindow("inviteconfirm/editbox"))

    -- subscribe event
    self.m_pOKBtn:subscribeEvent("Clicked", InviteConfirmDlg.HandleOKBtnClicked, self) 
    self.m_pCancelBtn:subscribeEvent("Clicked", InviteConfirmDlg.HandleCancelBtnClicked, self) 

	-- 设置编辑框
	self.m_pEditBox:setMaxTextLength(32)
	self.m_pEditBox:setValidationString("[0-9]*")

	print("convertdlg dialog oncreate end")
end

------------------- private: -----------------------------------


function InviteConfirmDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, InviteConfirmDlg)
    return self
end

function InviteConfirmDlg:HandleOKBtnClicked(args)
	print("convertdlg ok clicked")

	local code_length = string.len(self.m_pEditBox:getText())
	--如果长度不足
	if code_length < 1 then
		GetGameUIManager():AddMessageTipById(145225)
		return true
	end
	local friendid = tonumber(self.m_pEditBox:getText())
	if friendid == nil then
		friendid = 0
	end

	local YaoQingRen = CSetInvitePeople.Create()
	YaoQingRen.inviteid = friendid
	LuaProtocolManager.getInstance():send(YaoQingRen)
	InviteConfirmDlg.DestroyDialog()
	return true
end

function InviteConfirmDlg:HandleCancelBtnClicked(args)
	print("convertdlg cancel clicked")
	InviteConfirmDlg.DestroyDialog()
	return true
end

return InviteConfirmDlg
