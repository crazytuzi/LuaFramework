require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

YesIdoDialog = {}
setmetatable(YesIdoDialog, Dialog)
YesIdoDialog.__index = YesIdoDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function YesIdoDialog.getInstance()
	LogInfo("enter get YesIdoDialog instance")
    if not _instance then
        _instance = YesIdoDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function YesIdoDialog.getInstanceAndShow()
	LogInfo("enter YesIdoDialog instance show")
    if not _instance then
        _instance = YesIdoDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set YesIdoDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function YesIdoDialog.getInstanceNotCreate()
    return _instance
end

function YesIdoDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy YesIdoDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function YesIdoDialog.GetLayoutFileName()
    return "yesido.layout"
end

function YesIdoDialog:OnCreate()
	LogInfo("YesIdoDialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    --text
    self.m_text = winMgr:getWindow("yesido/txt")
    self.m_tips = winMgr:getWindow("yesido/time")

    --button
    self.m_yes = CEGUI.Window.toPushButton(winMgr:getWindow("yesido/ido"))
    self.m_no = CEGUI.Window.toPushButton(winMgr:getWindow("yesido/no"))

    self.m_yes:subscribeEvent("Clicked", YesIdoDialog.HandleYESClicked, self)
    self.m_no:subscribeEvent("Clicked", YesIdoDialog.HandleNOClicked, self)

    self:GetWindow():subscribeEvent("WindowUpdate", YesIdoDialog.HandleWindowUpdate, self)
	LogInfo("YesIdoDialog oncreate end")
end

------------------- private: -----------------------------------
function YesIdoDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YesIdoDialog)
    return self
end

function YesIdoDialog:HandleWindowUpdate(eventArgs)
    local time = CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    self.m_leftTime = self.m_leftTime - time
    if self.m_leftTime <= 0 then
        self.DestroyDialog()
        return
    end

    local formatstr = MHSD_UTILS.get_resstring(3125)
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", tostring(math.ceil(self.m_leftTime)))
    local msg = sb:GetString(formatstr)
    sb:delete()

    self.m_tips:setText(msg)
end

function YesIdoDialog:SetTipMessage(msg)
    LogInfo("YesIdoDialog SetTipMessage msg=." .. tostring(msg))
    self.m_text:setText(msg)

    self.m_leftTime = 30

    local formatstr = MHSD_UTILS.get_resstring(3125)
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", tostring(math.ceil(self.m_leftTime)))
    local msg = sb:GetString(formatstr)
    sb:delete()
    
    self.m_tips:setText(msg)
end

function YesIdoDialog:HandleYESClicked(args)
    LogInfo("YesIdoDialog HandleYESClicked clicked.")
    require "protocoldef.knight.gsp.marry.cmarryappnotice"
    local p = CMarryAPPNotice.Create()
    p.flag = 1
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

function YesIdoDialog:HandleNOClicked(args)
    LogInfo("YesIdoDialog HandleNOClicked clicked.")
    require "protocoldef.knight.gsp.marry.cmarryappnotice"
    local p = CMarryAPPNotice.Create()
    p.flag = 2
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

return YesIdoDialog
