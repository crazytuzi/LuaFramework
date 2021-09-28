require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local JieyiChenghaoDialog = {}
setmetatable(JieyiChenghaoDialog, Dialog)
JieyiChenghaoDialog.__index = JieyiChenghaoDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function JieyiChenghaoDialog.getInstance()
  LogInfo("enter get JieyiChenghaoDialog instance")
    if not _instance then
        _instance = JieyiChenghaoDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function JieyiChenghaoDialog.getInstanceAndShow()
  LogInfo("enter JieyiChenghaoDialog instance show")
    if not _instance then
        _instance = JieyiChenghaoDialog:new()
        _instance:OnCreate()
  else
    LogInfo("set JieyiChenghaoDialog visible")
    _instance:SetVisible(true)
    end
    
    return _instance
end

function JieyiChenghaoDialog.getInstanceNotCreate()
    return _instance
end

function JieyiChenghaoDialog.DestroyDialog()
  if _instance then 
    LogInfo("destroy JieyiChenghaoDialog")
    _instance:OnClose()
    _instance = nil
  end
end

----/////////////////////////////////////////------

function JieyiChenghaoDialog.GetLayoutFileName()
    return "jiebaichenghao.layout"
end

function JieyiChenghaoDialog:OnCreate()
  LogInfo("JieyiChenghaoDialog oncreate begin")
  Dialog.OnCreate(self)
  
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  self.m_chenghao = CEGUI.Window.toEditbox(winMgr:getWindow("jiebaichenghao/chenghao/txt"))
  self.m_chenghao:setMaxTextLength(6)
   
  self.m_btnOK = CEGUI.Window.toPushButton(winMgr:getWindow("jiebaichenghao/btn0"))
  self.m_btnOK:subscribeEvent("Clicked", JieyiChenghaoDialog.HandleButtonClicked, self)
  
  self.m_btnCancel = CEGUI.Window.toPushButton(winMgr:getWindow("jiebaichenghao/btn1"))
  self.m_btnCancel:subscribeEvent("Clicked", JieyiChenghaoDialog.DestroyDialog, self)
  
  LogInfo("JieyiChenghaoDialog oncreate end")
end

------------------- private: -----------------------------------
function JieyiChenghaoDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JieyiChenghaoDialog)
    return self
end

function JieyiChenghaoDialog:SetData(name, spend)
  self.m_chenghao:setText(name)
  self.m_spend = spend
end

function JieyiChenghaoDialog:HandleButtonClicked(args)
  LogInfo("JieyiChenghaoDialog HandleButtonClicked clicked.")
  if self.m_spend == nil then
    return
  end
  
  local tips = self.m_chenghao:getText()
  if string.len(tips) == 0 then
    GetChatManager():AddTipsMsg(140212)
    return
  end
  
  local msg=""
  local functable = {}
  function functable.acceptCallback()
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    require "protocoldef.knight.gsp.sworn.csworntitlechange"
    local p = CSwornTitleChange.Create()
    p.newname = tips
    require "manager.luaprotocolmanager":send(p)
  end
  
  --first time, for free
  if self.m_spend == 0 then
    local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146240).msg
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", tips or "??")
    msg = sb:GetString(formatstr)
  else
    local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146241).msg
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", tostring(self.m_spend))
    sb:Set("parameter2", tips or "??")
    msg = sb:GetString(formatstr)
  end
  
  GetMessageManager():AddConfirmBox(eConfirmNormal,
  msg,
  functable.acceptCallback,
    functable,
    CMessageManager.HandleDefaultCancelEvent,
    CMessageManager)
    
end

return JieyiChenghaoDialog
