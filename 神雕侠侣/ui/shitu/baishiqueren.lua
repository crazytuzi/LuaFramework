require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local BaishiQuerenDialog = {}
setmetatable(BaishiQuerenDialog, Dialog)
BaishiQuerenDialog.__index = BaishiQuerenDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BaishiQuerenDialog.getInstance()
	LogInfo("enter get BaishiQuerenDialog instance")
    if not _instance then
        _instance = BaishiQuerenDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BaishiQuerenDialog.getInstanceAndShow()
	LogInfo("enter BaishiQuerenDialog instance show")
    if not _instance then
        _instance = BaishiQuerenDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set BaishiQuerenDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BaishiQuerenDialog.getInstanceNotCreate()
    return _instance
end

function BaishiQuerenDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy BaishiQuerenDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------
function BaishiQuerenDialog.GetLayoutFileName()
    return "shitubaishiqueren.layout"
end

function BaishiQuerenDialog:OnCreate()
  LogInfo("BaishiQuerenDialog oncreate begin")
  Dialog.OnCreate(self)
  
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  --button
  self.m_btnYes = CEGUI.Window.toPushButton(winMgr:getWindow("shitubaishiqueren/bachu0"))
  self.m_btnNo = CEGUI.Window.toPushButton(winMgr:getWindow("shitubaishiqueren/bachu1"))
  self.m_txt = winMgr:getWindow("shitubaishiqueren/txt")

  self.m_btnYes:subscribeEvent("Clicked", BaishiQuerenDialog.HandleBtnYes, self)
  self.m_btnNo:subscribeEvent("Clicked", BaishiQuerenDialog.HandleBtnNo, self)
  
  self.m_btnClose = CEGUI.Window.toPushButton(winMgr:getWindow("shitubaishiqueren/close"))
  self.m_btnClose:subscribeEvent("Clicked", BaishiQuerenDialog.HandleBtnNo, self)
  
	LogInfo("BaishiQuerenDialog oncreate end")
end

------------------- private: -----------------------------------
function BaishiQuerenDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BaishiQuerenDialog)
    return self
end

function BaishiQuerenDialog:SetData(name)
  local sb = require "utils.stringbuilder":new()
  sb:Set("parameter1", name or "NULL")
  local msg = sb:GetString(MHSD_UTILS.get_resstring(3170))
  sb:delete()
  
  self.m_txt:setText(msg)
end

function BaishiQuerenDialog:HandleBtnYes(args)
  require "protocoldef.knight.gsp.master.CAppMaster"
  local p = CAppMaster.Create()
  p.flag = 1
  require "manager.luaprotocolmanager":send(p)
  self.DestroyDialog()
end

function BaishiQuerenDialog:HandleBtnNo(args)
  require "protocoldef.knight.gsp.master.CAppMaster"
  local p = CAppMaster.Create()
  p.flag = 0
  require "manager.luaprotocolmanager":send(p)
  self.DestroyDialog()
end

return BaishiQuerenDialog
