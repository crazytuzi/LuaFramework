require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local BatuQuerenDialog = {}
setmetatable(BatuQuerenDialog, Dialog)
BatuQuerenDialog.__index = BatuQuerenDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BatuQuerenDialog.getInstance()
	LogInfo("enter get BatuQuerenDialog instance")
    if not _instance then
        _instance = BatuQuerenDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BatuQuerenDialog.getInstanceAndShow()
	LogInfo("enter BatuQuerenDialog instance show")
    if not _instance then
        _instance = BatuQuerenDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set BatuQuerenDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BatuQuerenDialog.getInstanceNotCreate()
    return _instance
end

function BatuQuerenDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy BatuQuerenDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------
function BatuQuerenDialog.GetLayoutFileName()
    return "shitubatuqueren.layout"
end

function BatuQuerenDialog:OnCreate()
  LogInfo("BatuQuerenDialog oncreate begin")
  Dialog.OnCreate(self)
  
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  --button
  self.m_bnt1 = CEGUI.Window.toPushButton(winMgr:getWindow("shitubatuqueren/bachu0"))
  self.m_bnt2 = CEGUI.Window.toPushButton(winMgr:getWindow("shitubatuqueren/bachu1"))

  self.m_bnt1:subscribeEvent("Clicked", BatuQuerenDialog.HandleBtn1, self)
  self.m_bnt2:subscribeEvent("Clicked", BatuQuerenDialog.HandleBtn2, self)

  self.m_btnClose = CEGUI.Window.toPushButton(winMgr:getWindow("shitubatuqueren/close"))
  self.m_btnClose:subscribeEvent("Clicked", BatuQuerenDialog.DestroyDialog, self)
	LogInfo("BatuQuerenDialog oncreate end")
end

------------------- private: -----------------------------------
function BatuQuerenDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BatuQuerenDialog)
    return self
end

function BatuQuerenDialog:SetData(roleid)
  self.m_roleid = roleid
end

function BatuQuerenDialog:HandleBtn1(args)
  require "protocoldef.knight.gsp.master.cdismissapprentce"
  local p = CDismissApprentce.Create()
  p.roleid = self.m_roleid
  require "manager.luaprotocolmanager":send(p)
  self.DestroyDialog()
end

function BatuQuerenDialog:HandleBtn2(args)
    self.DestroyDialog()
end

return BatuQuerenDialog
