require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

JiezhiDialog = {}
setmetatable(JiezhiDialog, Dialog)
JiezhiDialog.__index = JiezhiDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function JiezhiDialog.getInstance()
	LogInfo("enter get JiezhiDialog instance")
    if not _instance then
        _instance = JiezhiDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function JiezhiDialog.getInstanceAndShow()
	LogInfo("enter JiezhiDialog instance show")
    if not _instance then
        _instance = JiezhiDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set JiezhiDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function JiezhiDialog.getInstanceNotCreate()
    return _instance
end

function JiezhiDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy JiezhiDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function JiezhiDialog.GetLayoutFileName()
    return "jiezhi.layout"
end

function JiezhiDialog:OnCreate()
  LogInfo("JiezhiDialog oncreate begin")
  Dialog.OnCreate(self)
  
  local winMgr = CEGUI.WindowManager:getSingleton()
  --text
  self.m_man = winMgr:getWindow("jiezhi/txt1")
  self.m_woman = winMgr:getWindow("jiezhi/txt2")
  self.m_date = winMgr:getWindow("jiezhi/time")
  self.m_info = winMgr:getWindow("jiezhi/back/txt")
  
  self.m_btnClose = CEGUI.Window.toPushButton(winMgr:getWindow("jiezhi/close"))
  self.m_btnClose:subscribeEvent("Clicked", JiezhiDialog.DestroyDialog, self)
  
  self.m_btnFind = CEGUI.Window.toPushButton(winMgr:getWindow("jiezhi/button"))
  self.m_btnFind:subscribeEvent("Clicked", JiezhiDialog.FindYou, self)
  
  self:GetWindow():subscribeEvent("WindowUpdate", JiezhiDialog.HandleWindowUpdate, self)
      
  LogInfo("JiezhiDialog oncreate end")
end

------------------- private: -----------------------------------
function JiezhiDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JiezhiDialog)
    return self
end

function JiezhiDialog:FindYou()
  --offline
  if self.m_data.flag == -1 then
    local msg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146383).msg
    GetGameUIManager():AddMessageTip(msg)
    return
  end
  
  --fuben
  if self.m_data.flag == 1 then
    local msg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146382).msg
    GetGameUIManager():AddMessageTip(msg)
    return
  end
  
  --time
  if self.m_lefttime > 0.0 then
    local formatstr = ""
    local timeleft = "0"
    if self.m_lefttime >= 3600.0 then
      formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146385).msg
      timeleft = tostring(math.ceil(self.m_lefttime/3600.0))
    else
      formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146386).msg
      timeleft = tostring(math.ceil(self.m_lefttime/60.0))
    end
    
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", timeleft)
    local msg = sb:GetString(formatstr)
    sb:delete()
    
    GetGameUIManager():AddMessageTip(msg)
    return
  end
  
  require "protocoldef.knight.gsp.marry.cmatejump"
  local p = CMateJump.Create()
  require "manager.luaprotocolmanager":send(p)
  
  self.DestroyDialog()
end

function JiezhiDialog:SetData(data)
  self.m_data = data
  self.m_lefttime = data.transfertime/1000.0
  
  --offline
  if data.flag == -1 then
    self.m_info:setText(MHSD_UTILS.get_resstring(3151))
  end

  --fuben
  if data.flag == 0 or data.flag == 1 then
    local msg = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(data.mapid).mapName
    local txt = msg .. "(" .. tostring(data.xpos) .. "," .. tostring(data.ypos) .. ")"
    self.m_info:setText(txt)
  end

  local formatstr = MHSD_UTILS.get_resstring(3116)
  local sb = require "utils.stringbuilder":new()
  sb:Set("parameter1", data.manname or " ")
  local manname = sb:GetString(formatstr)
  sb:delete()
  self.m_man:setText(manname)

  local formatstr = MHSD_UTILS.get_resstring(3117)
  local sb = require "utils.stringbuilder":new()
  sb:Set("parameter1", data.womanname or " ")
  local womanname = sb:GetString(formatstr)
  sb:delete()
  self.m_woman:setText(womanname)

  local formatstr = MHSD_UTILS.get_resstring(3143)
  local sb = require "utils.stringbuilder":new()
  sb:Set("parameter1", tostring(data.year) or " ")
  sb:Set("parameter2", tostring(data.month) or " ")
  sb:Set("parameter3", tostring(data.day) or " ")
  local date = sb:GetString(formatstr)
  sb:delete()
  self.m_date:setText(date)
end

function JiezhiDialog:HandleWindowUpdate(eventArgs)
    local time = CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    if self.m_lefttime == nil or self.m_lefttime <= 0.0 then
      return
    end
    self.m_lefttime = self.m_lefttime - time
end

return JiezhiDialog
