require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local BatuDialog = {}
setmetatable(BatuDialog, Dialog)
BatuDialog.__index = BatuDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BatuDialog.getInstance()
	LogInfo("enter get BatuDialog instance")
    if not _instance then
        _instance = BatuDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BatuDialog.getInstanceAndShow()
	LogInfo("enter BatuDialog instance show")
    if not _instance then
        _instance = BatuDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set BatuDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BatuDialog.getInstanceNotCreate()
    return _instance
end

function BatuDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy BatuDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------
function BatuDialog.GetLayoutFileName()
    return "shitubatu.layout"
end

function BatuDialog:OnCreate()
  LogInfo("BatuDialog oncreate begin")
  Dialog.OnCreate(self)
  
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  --button
  self.m_btns = {}
  self.m_txts = {}
  
  self.m_btns[1] = CEGUI.Window.toPushButton(winMgr:getWindow("shitubatu/bachu0"))
  self.m_btns[2] = CEGUI.Window.toPushButton(winMgr:getWindow("shitubatu/bachu1"))
  self.m_btns[3] = CEGUI.Window.toPushButton(winMgr:getWindow("shitubatu/bachu2"))
  self.m_btns[4] = CEGUI.Window.toPushButton(winMgr:getWindow("shitubatu/bachu3"))
  self.m_txts[1] = winMgr:getWindow("shitubatu/bachu/txt0")
  self.m_txts[2] = winMgr:getWindow("shitubatu/bachu/txt1")
  self.m_txts[3] = winMgr:getWindow("shitubatu/bachu/txt2")
  self.m_txts[4] = winMgr:getWindow("shitubatu/bachu/txt3")

  self.m_btns[1]:subscribeEvent("Clicked", BatuDialog.HandleBtn, self)
  self.m_btns[2]:subscribeEvent("Clicked", BatuDialog.HandleBtn, self)
  self.m_btns[3]:subscribeEvent("Clicked", BatuDialog.HandleBtn, self)
  self.m_btns[4]:subscribeEvent("Clicked", BatuDialog.HandleBtn, self)
  
  self.m_btns[1]:setVisible(false)
  self.m_btns[2]:setVisible(false)
  self.m_btns[3]:setVisible(false)
  self.m_btns[4]:setVisible(false)
  
  self.m_btnClose = CEGUI.Window.toPushButton(winMgr:getWindow("shitubatu/close"))
  self.m_btnClose:subscribeEvent("Clicked", BatuDialog.DestroyDialog, self)
  
	LogInfo("BatuDialog oncreate end")
end

------------------- private: -----------------------------------
function BatuDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BatuDialog)
    return self
end

function BatuDialog:SetData(data)
  self.m_tudis = data.prenticelist
  if self.m_tudis == nil or #self.m_tudis == 0 then
    return
  end
  
  for i=1, #self.m_tudis do
    if i > 4 then
      break
    end
    self.m_btns[i]:setVisible(true)
    self.m_txts[i]:setText(self.m_tudis[i].rolename)
    self.m_btns[i]:setID(i)
  end
end

function BatuDialog:HandleBtn(args)
  local index = CEGUI.toWindowEventArgs(args).window:getID()
  
  --for free
  if self.m_tudis[index].flag == 1 then
    require "protocoldef.knight.gsp.master.cdismissapprentce"
    local p = CDismissApprentce.Create()
    p.roleid = self.m_tudis[index].roleid
    require "manager.luaprotocolmanager":send(p)
    self.DestroyDialog()
    return
  end
  
  require "ui.shitu.batuqueren".getInstanceAndShow():SetData(self.m_tudis[index].roleid)
  self.DestroyDialog()
end

return BatuDialog
