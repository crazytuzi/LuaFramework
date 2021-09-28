require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local Tudi2ShifuDialog = {}
setmetatable(Tudi2ShifuDialog, Dialog)
Tudi2ShifuDialog.__index = Tudi2ShifuDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function Tudi2ShifuDialog.getInstance()
	LogInfo("enter get Tudi2ShifuDialog instance")
    if not _instance then
        _instance = Tudi2ShifuDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function Tudi2ShifuDialog.getInstanceAndShow()
	LogInfo("enter Tudi2ShifuDialog instance show")
    if not _instance then
        _instance = Tudi2ShifuDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set Tudi2ShifuDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function Tudi2ShifuDialog.getInstanceNotCreate()
    return _instance
end

function Tudi2ShifuDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy Tudi2ShifuDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------
function Tudi2ShifuDialog.GetLayoutFileName()
    return "shitupingjiatudi.layout"
end

function Tudi2ShifuDialog:OnCreate()
  LogInfo("Tudi2ShifuDialog oncreate begin")
  Dialog.OnCreate(self)
  
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  --button
  self.m_bnt1 = CEGUI.Window.toPushButton(winMgr:getWindow("shitupingjiatudi/pingjia"))
  self.m_bnt2 = CEGUI.Window.toPushButton(winMgr:getWindow("shitupingjiatudi/pingjia1"))
  self.m_bnt3 = CEGUI.Window.toPushButton(winMgr:getWindow("shitupingjiatudi/pingjia11"))

  self.m_bnt1:subscribeEvent("Clicked", Tudi2ShifuDialog.HandleBtn1, self)
  self.m_bnt2:subscribeEvent("Clicked", Tudi2ShifuDialog.HandleBtn2, self)
  self.m_bnt3:subscribeEvent("Clicked", Tudi2ShifuDialog.HandleBtn3, self)

  self.m_btnClose = CEGUI.Window.toPushButton(winMgr:getWindow("shitupingjiatudi/close"))
  self.m_btnClose:subscribeEvent("Clicked", Tudi2ShifuDialog.DestroyDialog, self)
  
	LogInfo("Tudi2ShifuDialog oncreate end")
end

------------------- private: -----------------------------------
function Tudi2ShifuDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Tudi2ShifuDialog)
    return self
end

function Tudi2ShifuDialog:SetRoleID(roleId)
  self.m_roleId = roleId
end

function Tudi2ShifuDialog:HandleBtn1(args)
    require "protocoldef.knight.gsp.master.cevaluate"
    local p = CEvaluate.Create()
    p.flag = 1
    p.roleid = self.m_roleId
    p.result = 1
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

function Tudi2ShifuDialog:HandleBtn2(args)
    require "protocoldef.knight.gsp.master.cevaluate"
    local p = CEvaluate.Create()
    p.flag = 1
    p.roleid = self.m_roleId
    p.result = 2
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

function Tudi2ShifuDialog:HandleBtn3(args)
    require "protocoldef.knight.gsp.master.cevaluate"
    local p = CEvaluate.Create()
    p.flag = 1
    p.roleid = self.m_roleId
    p.result = 3
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
end

return Tudi2ShifuDialog
