require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local Shifu2TudiDialog = {}
setmetatable(Shifu2TudiDialog, Dialog)
Shifu2TudiDialog.__index = Shifu2TudiDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function Shifu2TudiDialog.getInstance()
	LogInfo("enter get Shifu2TudiDialog instance")
    if not _instance then
        _instance = Shifu2TudiDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function Shifu2TudiDialog.getInstanceAndShow()
	LogInfo("enter Shifu2TudiDialog instance show")
    if not _instance then
        _instance = Shifu2TudiDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set Shifu2TudiDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function Shifu2TudiDialog.getInstanceNotCreate()
    return _instance
end

function Shifu2TudiDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy Shifu2TudiDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------
function Shifu2TudiDialog.GetLayoutFileName()
    return "shitupingjiashifu.layout"
end

function Shifu2TudiDialog:OnCreate()
	LogInfo("Shifu2TudiDialog oncreate begin")
  Dialog.OnCreate(self)

  local winMgr = CEGUI.WindowManager:getSingleton()

  --button
  self.m_bnt1 = CEGUI.Window.toPushButton(winMgr:getWindow("shitupingjiashifu/pingjia"))
  self.m_bnt2 = CEGUI.Window.toPushButton(winMgr:getWindow("shitupingjiashifu/pingjia1"))
  self.m_bnt3 = CEGUI.Window.toPushButton(winMgr:getWindow("shitupingjiashifu/pingjia11"))

  self.m_bnt1:subscribeEvent("Clicked", Shifu2TudiDialog.HandleBtn1, self)
  self.m_bnt2:subscribeEvent("Clicked", Shifu2TudiDialog.HandleBtn2, self)
  self.m_bnt3:subscribeEvent("Clicked", Shifu2TudiDialog.HandleBtn3, self)

  self.m_btnClose = CEGUI.Window.toPushButton(winMgr:getWindow("shitupingjiashifu/close"))
  self.m_btnClose:subscribeEvent("Clicked", Shifu2TudiDialog.DestroyDialog, self)
  
	LogInfo("Shifu2TudiDialog oncreate end")
end

------------------- private: -----------------------------------
function Shifu2TudiDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Shifu2TudiDialog)
    return self
end

function Shifu2TudiDialog:SetRoleID(roleId)
  self.m_roleId = roleId
end

function Shifu2TudiDialog:HandleBtn1(args)
    LogInfo("Shifu2TudiDialog HandleBtn1 clicked.")
    require "protocoldef.knight.gsp.master.cevaluate"
    local p = CEvaluate.Create()
    p.flag = 2
    p.roleid = self.m_roleId
    p.result = 1
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

function Shifu2TudiDialog:HandleBtn2(args)
    require "protocoldef.knight.gsp.master.cevaluate"
    local p = CEvaluate.Create()
    p.flag = 2
    p.roleid = self.m_roleId
    p.result = 2
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

function Shifu2TudiDialog:HandleBtn3(args)
    require "protocoldef.knight.gsp.master.cevaluate"
    local p = CEvaluate.Create()
    p.flag = 2
    p.roleid = self.m_roleId
    p.result = 3
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

return Shifu2TudiDialog
