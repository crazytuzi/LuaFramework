require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

InvitationCardDialog = {}
setmetatable(InvitationCardDialog, Dialog)
InvitationCardDialog.__index = InvitationCardDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function InvitationCardDialog.getInstance()
	LogInfo("enter get InvitationCardDialog instance")
    if not _instance then
        _instance = InvitationCardDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function InvitationCardDialog.getInstanceAndShow()
	LogInfo("enter InvitationCardDialog instance show")
    if not _instance then
        _instance = InvitationCardDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set InvitationCardDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function InvitationCardDialog.getInstanceNotCreate()
    return _instance
end

function InvitationCardDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy InvitationCardDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function InvitationCardDialog.GetLayoutFileName()
    return "invitationcard2.layout"
end

function InvitationCardDialog:OnCreate()
	LogInfo("InvitationCardDialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    --text
    self.m_txt = winMgr:getWindow("invitationcard2/back/txt")
    self.m_txtMan = winMgr:getWindow("invitationcard2/txt")
    self.m_txtWoman = winMgr:getWindow("invitationcard2/txt1")
    self.m_txtOwn = winMgr:getWindow("invitationcard2/back/txt2")
    
    self.m_data = {}

    --button
    self.m_yes = CEGUI.Window.toPushButton(winMgr:getWindow("invitationcard2/button"))
    self.m_no = CEGUI.Window.toPushButton(winMgr:getWindow("invitationcard2/button1"))

    self.m_yes:subscribeEvent("Clicked", InvitationCardDialog.HandleYESClicked, self)
    self.m_no:subscribeEvent("Clicked", InvitationCardDialog.HandleNOClicked, self)

	LogInfo("InvitationCardDialog oncreate end")
end

------------------- private: -----------------------------------
function InvitationCardDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, InvitationCardDialog)
    return self
end

function InvitationCardDialog:SetMessage(msg)
    LogInfo("InvitationCardDialog SetMessage")
    self.m_txt:setText(msg.message)
    
    local formatstr = MHSD_UTILS.get_resstring(3116)
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", msg.man or " ")
    local manname = sb:GetString(formatstr)
    sb:delete()
    
    local formatstr = MHSD_UTILS.get_resstring(3117)
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", msg.woman or " ")
    local womanname = sb:GetString(formatstr)
    sb:delete()

    local formatstr = MHSD_UTILS.get_resstring(3115)
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", GetMainCharacter():GetName() or "NULL")
    local ownname = sb:GetString(formatstr)
    sb:delete()

    self.m_txtMan:setText(manname)
    self.m_txtWoman:setText(womanname)
    self.m_txtOwn:setText(ownname)
    
    self.m_data = msg
end

function InvitationCardDialog:HandleYESClicked(args)
    LogInfo("InvitationCardDialog HandleYESClicked clicked.")

    require "protocoldef.knight.gsp.marry.cattendwedding"
    local p = CAttendWedding.Create()
    p.coupleid = self.m_data.ownerid
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

function InvitationCardDialog:HandleNOClicked(args)
    LogInfo("InvitationCardDialog HandleNOClicked clicked.")
    self.DestroyDialog()
end

return InvitationCardDialog
