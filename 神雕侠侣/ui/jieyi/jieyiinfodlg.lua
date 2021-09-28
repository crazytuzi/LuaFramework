require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local JieyiInfoDialog = {}
setmetatable(JieyiInfoDialog, Dialog)
JieyiInfoDialog.__index = JieyiInfoDialog

local function getLabel()
  return require "ui.label".getLabelById("jianghu")
end

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function JieyiInfoDialog.getInstance()
  LogInfo("enter get JieyiInfoDialog instance")
    if not _instance then
        _instance = JieyiInfoDialog:new()
        _instance:OnCreate()
    end
    
    if not getLabel() then
      LabelDlg.InitJianghu()
    end
    
    return _instance
end

function JieyiInfoDialog.getInstanceAndShow()
  LogInfo("enter JieyiInfoDialog instance show")
    if not _instance then
      _instance = JieyiInfoDialog:new()
      _instance:OnCreate()
    else
      LogInfo("set JieyiInfoDialog visible")
      _instance:SetVisible(true)
    end
    
    if not getLabel() then
      LabelDlg.InitJianghu()
    end
    
    return _instance
end

function JieyiInfoDialog.getInstanceNotCreate()
    return _instance
end

function JieyiInfoDialog:OnClose()
  Dialog.OnClose(self)
  _instance = nil
end

function JieyiInfoDialog.DestroyDialog()
  if _instance then
    if _instance.m_personDlgTips then
      _instance.m_personDlgTips.DestroyDialog()
    end
    if _instance.m_allDlgTips then
      _instance.m_allDlgTips.DestroyDialog()
    end
  
    local dlg = LabelDlg.getLabelById("jianghu")
    if dlg then
      dlg:OnClose()
    end
    if _instance then 
      _instance:OnClose()
    end
  end
end

----/////////////////////////////////////////------

function JieyiInfoDialog.GetLayoutFileName()
    return "jiebaixinxi.layout"
end

function JieyiInfoDialog:OnCreate()
  LogInfo("JieyiInfoDialog oncreate begin")
  Dialog.OnCreate(self)

  local winMgr = CEGUI.WindowManager:getSingleton()
  
  self.m_jieyiname = winMgr:getWindow("jiebaixinxi/left/up/name")
  self.m_names = {}
  self.m_names[1] = winMgr:getWindow("jiebaixinxi/left/num/t0/txt")
  self.m_names[2] = winMgr:getWindow("jiebaixinxi/left/num/t0/txt1")
  self.m_names[3] = winMgr:getWindow("jiebaixinxi/left/num/t0/txt2")
  self.m_names[4] = winMgr:getWindow("jiebaixinxi/left/num/t0/txt3")
  self.m_names[5] = winMgr:getWindow("jiebaixinxi/left/num/t0/txt4")
  
  self.m_progress1 = CEGUI.Window.toProgressBar(winMgr:getWindow("jiebaixinxi/left/down/jieyi"))
  self.m_progress2 = CEGUI.Window.toProgressBar(winMgr:getWindow("jiebaixinxi/left/down/zongjieyi"))
  
  self.m_jieyidengji = winMgr:getWindow("jiebaixinxi/left/down/button/text")
  
  self.m_mainItems = {}
  self.m_pPaneContent = CEGUI.Window.toScrollablePane(winMgr:getWindow("jiebaixinxi/right/down/back"))
  
  self.m_btnPerson = CEGUI.Window.toPushButton(winMgr:getWindow("jiebaixinxi/left/up"))
  self.m_btnPerson:subscribeEvent("Clicked", JieyiInfoDialog.HandleButtonPerson, self)

  self.m_btnAll = CEGUI.Window.toPushButton(winMgr:getWindow("jiebaixinxi/left/down/button"))
  self.m_btnAll:subscribeEvent("Clicked", JieyiInfoDialog.HandleButtonAll, self)
  
  self.m_personLevel = 0
  self.m_allLevel = 0
  
  LogInfo("JieyiInfoDialog oncreate end")
end

------------------- private: -----------------------------------
function JieyiInfoDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JieyiInfoDialog)
    return self
end

function JieyiInfoDialog:HandleButtonPerson(data)
  self.m_personDlgTips = require "ui.jieyi.jieyipersontipsdlg".getInstanceAndShow()
  self.m_personDlgTips:SetLevel(self.m_personLevel)
end

function JieyiInfoDialog:HandleButtonAll(data)
  self.m_allDlgTips = require "ui.jieyi.jieyialltipsdlg".getInstanceAndShow()
  self.m_allDlgTips:SetLevel(self.m_allLevel)
end

function JieyiInfoDialog:SetData(data)
  LogInfo("JieyiInfoDialog SetData .")
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  --hide not used items
  winMgr:getWindow("jiebaixinxi/right/down/txt"):setVisible(false)

  --clear old items
  for k, v in pairs(self.m_mainItems) do
    winMgr:destroyWindow(v)
    self.m_pPaneContent:removeChildWindow(v)
  end
  self.m_mainItems = {}
  
  --jiang hu ren cheng
  if data.swornname == nil or data.swornname == "" then
    data.swornname = MHSD_UTILS.get_resstring(3145)
  end
  
  self.m_jieyiname:setText(data.swornname)
  self.m_personLevel = data.titlelevel
  
  local rec = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cpersenaltip"):getRecorder(data.titlelevel)
  self.m_jieyiname:setProperty("TextColours", rec.fontcolor or "tl:FF00FFFF tr:FF00FFFF bl:FF00FFFF br:FF00FFFF")
  self.m_jieyiname:setProperty("BorderColour", rec.bordercolor or "FF003454")
  
  --numbers
  for i=1, #data.membernames do
    self.m_names[i]:setText(data.membernames[i])
    if i> 5 then
      break
    end
  end
  
  --jieyizhi
  if data.sswornscoreup and data.sswornscoreup ~= 0 then
    self.m_progress1:setProgress(data.swornscore*1.0 / data.sswornscoreup)
    self.m_progress1:setText(string.format("%d/%d", data.swornscore, data.sswornscoreup))
  end
  
  -- for ge ren 7 level
  if data.titlelevel == 7 then
    self.m_progress1:setProgress(1.0)
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", tostring(data.swornscore))
    local msg=strbuilder:GetString(MHSD_UTILS.get_resstring(3146))
    strbuilder:delete()
    
    self.m_progress1:setText(msg)
  end
  
  --zong jieyizhi
  if data.totalscoreup and data.totalscoreup ~= 0 then
    self.m_progress2:setProgress(data.totalscore*1.0 / data.totalscoreup)
    self.m_progress2:setText(string.format("%d/%d", data.totalscore, data.totalscoreup))
  end
  
  -- for zong 7 level
  if data.swornlevel == 7 then
    self.m_progress2:setProgress(1.0)
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", tostring(data.totalscore))
    local msg=strbuilder:GetString(MHSD_UTILS.get_resstring(3146))
    strbuilder:delete()
    self.m_progress2:setText(msg)
  end
  
  --jieyi dengji
  self.m_jieyidengji:setText(data.swornlevelstr)
  self.m_allLevel = data.swornlevel
  
  --jieyiyuan
  local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cjieyiyuancontent")
  for i=1, #data.jyybean do
    local cellWnd = winMgr:loadWindowLayout("jiebaixinxicell.layout", tostring(i))
    self.m_pPaneContent:addChildWindow(cellWnd)
    table.insert(self.m_mainItems, cellWnd)
    
    local info = config:getRecorder(data.jyybean[i].jyyid)
    local cur_level = data.jyybean[i].level
    
    local txt1 = winMgr:getWindow(tostring(i) .. "jiebaixinxicell/back/txt")
    local txt2 = winMgr:getWindow(tostring(i) .. "jiebaixinxicell/back/txt1")
    txt1:setMousePassThroughEnabled(true)
    txt2:setMousePassThroughEnabled(true)
    
    txt1:setText(info.title)
    txt2:setText(info.effect)
    
    local icon = CEGUI.toPushButton(winMgr:getWindow(tostring(i) .. "jiebaixinxicell/back/img"))
    if cur_level == 0 then
      icon:setProperty("NormalImage", info.DarkIcon)
      icon:setProperty("HoverImage", info.DarkIcon)
      icon:setProperty("PushedImage", info.DarkIcon)
    else
      icon:setProperty("NormalImage", info.NormalIcon)
      icon:setProperty("HoverImage", info.NormalIcon)
      icon:setProperty("PushedImage", info.NormalIcon)
    end
    
    --for click func callback
    local func_jyyid = info.id
    local func_curlevel = cur_level
    local func = function()
      require "ui.jieyi.jieyiyuandlg".getInstanceAndShow():SetData(func_jyyid, func_curlevel)
    end
    
    --subscribe
    --local btn = CEGUI.toPushButton(winMgr:getWindow(tostring(i) .. "jiebaixinxicell/back/img"))
    icon:subscribeEvent("Clicked", func, self)
    
    --set position
    local y = math.floor((i - 1) * cellWnd:getSize().y.offset) + 1
    cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, y)))
  end
  
end

return JieyiInfoDialog
