require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local BashiDialog = {}
setmetatable(BashiDialog, Dialog)
BashiDialog.__index = BashiDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BashiDialog.getInstance()
	LogInfo("enter get BashiDialog instance")
    if not _instance then
        _instance = BashiDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BashiDialog.getInstanceAndShow()
	LogInfo("enter BashiDialog instance show")
    if not _instance then
        _instance = BashiDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set BashiDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BashiDialog.getInstanceNotCreate()
    return _instance
end

function BashiDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy BashiDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------
function BashiDialog.GetLayoutFileName()
    return "shitubashi.layout"
end

function BashiDialog:OnCreate()
  LogInfo("BashiDialog oncreate begin")
  Dialog.OnCreate(self)
  
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  --button
  self.m_bnt1 = CEGUI.Window.toPushButton(winMgr:getWindow("shitubashi/bachu0"))
  self.m_bnt2 = CEGUI.Window.toPushButton(winMgr:getWindow("shitubashi/bachu1"))

  self.m_bnt1:subscribeEvent("Clicked", BashiDialog.HandleBtn1, self)
  self.m_bnt2:subscribeEvent("Clicked", BashiDialog.HandleBtn2, self)

  self.m_btnClose = CEGUI.Window.toPushButton(winMgr:getWindow("shitubashi/close"))
  self.m_btnClose:subscribeEvent("Clicked", BashiDialog.DestroyDialog, self)
	LogInfo("BashiDialog oncreate end")
end

------------------- private: -----------------------------------
function BashiDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BashiDialog)
    return self
end


function BashiDialog:HandleBtn1(args)
    require "protocoldef.knight.gsp.master.cdismissmaster"
    local p = CDismissMaster.Create()
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

function BashiDialog:HandleBtn2(args)
    self.DestroyDialog()
end

return BashiDialog
