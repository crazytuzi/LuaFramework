require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

QingtieDialog = {}
setmetatable(QingtieDialog, Dialog)
QingtieDialog.__index = QingtieDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function QingtieDialog.getInstance()
	LogInfo("enter get QingtieDialog instance")
    if not _instance then
        _instance = QingtieDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function QingtieDialog.getInstanceAndShow()
	LogInfo("enter QingtieDialog instance show")
    if not _instance then
        _instance = QingtieDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set QingtieDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function QingtieDialog.getInstanceNotCreate()
    return _instance
end

function QingtieDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy QingtieDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function QingtieDialog.GetLayoutFileName()
    return "invitationcard.layout"
end

function QingtieDialog:OnCreate()
    LogInfo("QingtieDialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    --txt
    self.m_txt = CEGUI.Window.toRichEditbox(winMgr:getWindow("invitationcard/back/txt"))
    self.m_txt:setMaxTextLength(50)
    
    --txt man
    self.m_man = winMgr:getWindow("invitationcard/txt")
    self.m_woman = winMgr:getWindow("invitationcard/txt1")
        
    --send button
    self.m_sendBtn = CEGUI.Window.toPushButton(winMgr:getWindow("invitationcard/button"))
    self.m_sendBtn:subscribeEvent("Clicked", QingtieDialog.HandleSendClicked, self)
    
    --random button
    self.m_randomBtn = CEGUI.Window.toPushButton(winMgr:getWindow("invitationcard/random"))
    self.m_randomBtn:subscribeEvent("Clicked", QingtieDialog.HandleRandomClicked, self)

    --send button
    self.m_closeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("invitationcard/close"))
    self.m_closeBtn:subscribeEvent("Clicked", QingtieDialog.DestroyDialog, self)
    
    self.m_serviceid = 0
    
    self:HandleRandomClicked()

    LogInfo("QingtieDialog oncreate end")
end

------------------- private: -----------------------------------

function QingtieDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, QingtieDialog)
    return self
end

function QingtieDialog:SetServiceId(serviceid, man, woman)
    LogInfo("QingtieDialog SetServiceId msg=." .. serviceid)
    self.m_serviceid = serviceid
    
    local formatstr = MHSD_UTILS.get_resstring(3116)
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", man or " ")
    local manname = sb:GetString(formatstr)
    sb:delete()

    local formatstr = MHSD_UTILS.get_resstring(3117)
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", woman or " ")
    local womanname = sb:GetString(formatstr)
    sb:delete()
    
    self.m_man:setText(manname)
    self.m_woman:setText(womanname)
end

function QingtieDialog:HandleSendClicked(args)
    LogInfo("QingtieDialog HandleSendClicked clicked.")
    
    local text = self.m_txt:GetPureText()
    
    require "protocoldef.knight.gsp.marry.csubinvitation"
    local p = CSubInvitation.Create()
    p.serviceid = self.m_serviceid
    p.content = text
    require "manager.luaprotocolmanager":send(p)
end

function QingtieDialog:HandleRandomClicked(args)
    LogInfo("QingtieDialog HandleRandomClicked clicked.")
    local msg = CEGUI.String(MHSD_UTILS.get_resstring(3117 + math.random(7)))
    
    self.m_txt:Clear()
    self.m_txt:AppendText(msg)
    self.m_txt:Refresh()
end

return QingtieDialog
