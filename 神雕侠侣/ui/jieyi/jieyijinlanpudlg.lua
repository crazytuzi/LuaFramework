require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "ui.numinputdlg"

local JieyiJinlanpuDialog = {}
setmetatable(JieyiJinlanpuDialog, Dialog)
JieyiJinlanpuDialog.__index = JieyiJinlanpuDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function JieyiJinlanpuDialog.getInstance()
  LogInfo("enter get JieyiJinlanpuDialog instance")
    if not _instance then
        _instance = JieyiJinlanpuDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function JieyiJinlanpuDialog.getInstanceAndShow()
  LogInfo("enter JieyiJinlanpuDialog instance show")
    if not _instance then
        _instance = JieyiJinlanpuDialog:new()
        _instance:OnCreate()
  else
    LogInfo("set JieyiJinlanpuDialog visible")
    _instance:SetVisible(true)
    end
    
    return _instance
end

function JieyiJinlanpuDialog.getInstanceNotCreate()
    return _instance
end

function JieyiJinlanpuDialog.DestroyDialog()
  if _instance then 
    LogInfo("destroy JieyiJinlanpuDialog")
    _instance:OnClose()
    _instance = nil
  end
end

----/////////////////////////////////////////------

function JieyiJinlanpuDialog.GetLayoutFileName()
    return "jiebaijinlanpu.layout"
end

function JieyiJinlanpuDialog:OnCreate()
  LogInfo("JieyiJinlanpuDialog oncreate begin")
  Dialog.OnCreate(self)
  
  local winMgr = CEGUI.WindowManager:getSingleton()

  self.m_name = winMgr:getWindow("jiebaijinlanpu/titletime/txt")
  
  self.m_year = CEGUI.Window.toEditbox(winMgr:getWindow("jiebaijinlanpu/time0"))
  self.m_year:setText("1990")
  self.m_year:SetOnlyNumberMode(true, 2014)
  self.m_year:setReadOnly(true)
    
  self.m_month = CEGUI.Window.toEditbox(winMgr:getWindow("jiebaijinlanpu/time1"))
  self.m_month:setText("05")
  self.m_month:SetOnlyNumberMode(true, 12)
  self.m_month:setReadOnly(true)
  
  self.m_day = CEGUI.Window.toEditbox(winMgr:getWindow("jiebaijinlanpu/time11"))
  self.m_day:setText("05")
  self.m_day:SetOnlyNumberMode(true, 31)
  self.m_day:setReadOnly(true)
  
  self.m_year:subscribeEvent("MouseClick", JieyiJinlanpuDialog.HandleEdit1Clicked, self)
  self.m_month:subscribeEvent("MouseClick", JieyiJinlanpuDialog.HandleEdit2Clicked, self)
  self.m_day:subscribeEvent("MouseClick", JieyiJinlanpuDialog.HandleEdit3Clicked, self)
  
  self.m_year:subscribeEvent("TextChanged", JieyiJinlanpuDialog.TextChanged, self)
  self.m_month:subscribeEvent("TextChanged", JieyiJinlanpuDialog.TextChanged, self)
  self.m_day:subscribeEvent("TextChanged", JieyiJinlanpuDialog.TextChanged, self)
  
  self:TextChanged()
  
  self.m_sign = CEGUI.Window.toPushButton(winMgr:getWindow("jiebaijinlanpu/qianming"))
  self.m_sign:subscribeEvent("Clicked", JieyiJinlanpuDialog.HandleButtonClicked, self)
  
  LogInfo("JieyiJinlanpuDialog oncreate end")
end

------------------- private: -----------------------------------
function JieyiJinlanpuDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JieyiJinlanpuDialog)
    return self
end

function JieyiJinlanpuDialog:HandleEdit1Clicked()
  NumInputDlg.ToggleOpenClose()
  NumInputDlg.getInstance():setTargetWindow(self.m_year)
end

function JieyiJinlanpuDialog:HandleEdit2Clicked()
  NumInputDlg.ToggleOpenClose()
  NumInputDlg.getInstance():setTargetWindow(self.m_month)
end

function JieyiJinlanpuDialog:HandleEdit3Clicked()
  NumInputDlg.ToggleOpenClose()
  NumInputDlg.getInstance():setTargetWindow(self.m_day)
end

function JieyiJinlanpuDialog:TextChanged()
  local year = tonumber(self.m_year:getText())
  local month = tonumber(self.m_month:getText())
  local day = tonumber(self.m_day:getText())
  
  if year ~= nil then
    year = string.format("%02d", year)
  end
  
  if month ~= nil then
    month = string.format("%02d", month)
  end
  
  if day ~= nil then
    day = string.format("%02d", day)
  end
  
  local strbuilder = StringBuilder:new()
  strbuilder:SetNum("parameter1", GetMainCharacter():GetName() or "CallMeLeiFeng")
  strbuilder:SetNum("parameter2", year or "1990")
  strbuilder:SetNum("parameter3", month or "05")
  strbuilder:SetNum("parameter4", day or "05")

  self.m_name:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(3141)))
  strbuilder:delete()
end

function JieyiJinlanpuDialog:HandleButtonClicked(args)
    LogInfo("JieyiJinlanpuDialog HandleButtonClicked clicked.")
    
    local year = tonumber(self.m_year:getText())
    local month = tonumber(self.m_month:getText())
    local day = tonumber(self.m_day:getText())
    
    if year ~= nil then
      year = string.format("%02d", year)
    end
  
    if month ~= nil then
      month = string.format("%02d", month)
    end
    
    if day ~= nil then
      day = string.format("%02d", day)
    end
  
    local str = string.format("%02d%02d%02d", year or "1990", month or "05", day or "05")
  
    require "protocoldef.knight.gsp.sworn.cswornappsign"
    local p = CSwornAppSign.Create()
    p.birthday = str
    require "manager.luaprotocolmanager":send(p)
end

return JieyiJinlanpuDialog
