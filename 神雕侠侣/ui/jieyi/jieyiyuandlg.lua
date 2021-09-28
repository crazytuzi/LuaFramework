require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local JieyiyuanDialog = {}
setmetatable(JieyiyuanDialog, Dialog)
JieyiyuanDialog.__index = JieyiyuanDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function JieyiyuanDialog.getInstance()
  LogInfo("enter get JieyiyuanDialog instance")
    if not _instance then
        _instance = JieyiyuanDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function JieyiyuanDialog.getInstanceAndShow()
  LogInfo("enter JieyiyuanDialog instance show")
    if not _instance then
        _instance = JieyiyuanDialog:new()
        _instance:OnCreate()
  else
    LogInfo("set JieyiyuanDialog visible")
    _instance:SetVisible(true)
    end
    
    return _instance
end

function JieyiyuanDialog.getInstanceNotCreate()
    return _instance
end

function JieyiyuanDialog.DestroyDialog()
  if _instance then 
    LogInfo("destroy JieyiyuanDialog")
    _instance:OnClose()
    _instance = nil
  end
end

----/////////////////////////////////////////------

function JieyiyuanDialog.GetLayoutFileName()
    return "jiebaixinxiadd.layout"
end

function JieyiyuanDialog:OnCreate()
  LogInfo("JieyiyuanDialog oncreate begin")
  Dialog.OnCreate(self)

  local winMgr = CEGUI.WindowManager:getSingleton()
  
  self.m_title = winMgr:getWindow("jiebaixinxiadd/title")
  self.m_img = winMgr:getWindow("jiebaixinxiadd/img/tu")
  self.m_imgtxt = winMgr:getWindow("jiebaixinxiadd/img/txt")
  self.m_describe = winMgr:getWindow("jiebaixinxiadd/txt")
  
  self.m_mainItems = {}
  self.m_pane = CEGUI.Window.toScrollablePane(winMgr:getWindow("jiebaixinxiadd/down"))
  
  LogInfo("JieyiyuanDialog oncreate end")
end

------------------- private: -----------------------------------
function JieyiyuanDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JieyiyuanDialog)
    return self
end

function JieyiyuanDialog:SetData(jid, curLevelId)
  LogInfo("JieyiyuanDialog SetData.")
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  --clear old items
  for k, v in pairs(self.m_mainItems) do
    winMgr:destroyWindow(v)
    self.m_pane:removeChildWindow(v)
  end
  self.m_mainItems = {}
  
  local config1 = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cjieyiyuancontent")
  local config2 = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cjieyiyuaninfo")
  local info1 = config1:getRecorder(jid)
  
  self.m_title:setText(info1.title)
  self.m_img:setProperty("Image", info1.NormalIcon)
    
  self.m_imgtxt:setText(info1.description)
  self.m_describe:setText(info1.condition)
  
  local jyy = {}
  local ids = config2:getDisorderAllID()
  for k,v in pairs(ids) do
    if jid == config2:getRecorder(v).yuanid then
      table.insert(jyy, config2:getRecorder(v))
    end
  end
  
  table.sort(jyy, function(a, b) return a.yuanLevel < b.yuanLevel  end)

  for i=1, #jyy do
    local cellWnd = winMgr:loadWindowLayout("jiebaixinxiaddcell.layout", tostring(i))
    self.m_pane:addChildWindow(cellWnd)
    table.insert(self.m_mainItems, cellWnd)
    
    local btn = CEGUI.toPushButton(winMgr:getWindow(tostring(i) .. "jiebaixinxiaddcell/back"))
    if jyy[i].yuanLevel == curLevelId then
      btn:setProperty("NormalImage", "set:MainControl3 image:TrackPushed")
    else
      btn:setProperty("NormalImage", "set:MainControl3 image:TrackNormal")
    end
    
    local tipmsg = jyy[i].GetCondition
    local func = function()
      GetGameUIManager():AddMessageTip(tipmsg);
    end
    btn:subscribeEvent("Clicked", func, self)
    
    local txt = winMgr:getWindow(tostring(i) .. "jiebaixinxiaddcell/back/txt")
    txt:setMousePassThroughEnabled(true)
    txt:setText(jyy[i].detaileffect)
    
    --set position
    local x = (self.m_pane:getPixelSize().width - btn:getPixelSize().width)/2
    local y = math.floor((i - 1) * cellWnd:getSize().y.offset) + i*10
    cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, x), CEGUI.UDim(0, y)))
  end
end

return JieyiyuanDialog
