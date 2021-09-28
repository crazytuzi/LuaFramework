require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

InvitationCardSmallDialog = {}
setmetatable(InvitationCardSmallDialog, Dialog)
InvitationCardSmallDialog.__index = InvitationCardSmallDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function InvitationCardSmallDialog.getInstance()
	LogInfo("enter get InvitationCardSmallDialog instance")
    if not _instance then
        _instance = InvitationCardSmallDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function InvitationCardSmallDialog.getInstanceAndShow()
	LogInfo("enter InvitationCardSmallDialog instance show")
    if not _instance then
        _instance = InvitationCardSmallDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set InvitationCardSmallDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function InvitationCardSmallDialog.getInstanceNotCreate()
    return _instance
end

function InvitationCardSmallDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy InvitationCardSmallDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function InvitationCardSmallDialog.GetLayoutFileName()
    return "invitationcardsmall.layout"
end

function InvitationCardSmallDialog:OnCreate()
	LogInfo("InvitationCardSmallDialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_data = {}

    --button
    self.m_btn = CEGUI.Window.toPushButton(winMgr:getWindow("invitationcardsmall/button"))
    self.m_btn:subscribeEvent("Clicked", InvitationCardSmallDialog.HandleBtnClicked, self)

  self.m_pMainFrame:moveToBack()
	LogInfo("InvitationCardSmallDialog oncreate end")
end

------------------- private: -----------------------------------
function InvitationCardSmallDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, InvitationCardSmallDialog)
    return self
end

function InvitationCardSmallDialog:SetMessage(msg)
    LogInfo("InvitationCardSmallDialog SetMessage")
    table.insert(self.m_data, msg)
    
    if GetBattleManager():IsInBattle() then
      self:SetVisible(false)
    end
end

function InvitationCardSmallDialog:HandleBtnClicked(args)
    LogInfo("InvitationCardSmallDialog HandleBtnClicked clicked.")
    if table.getn(self.m_data) > 0 then
        local d = self.m_data[1]
        table.remove(self.m_data, 1)

        require "ui.marry.invitationcarddlg".getInstanceAndShow():SetMessage(d)
    end

    if table.getn(self.m_data) == 0 then
        self.DestroyDialog()
    end
end

return InvitationCardSmallDialog
