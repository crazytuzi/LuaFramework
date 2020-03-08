local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GuideUtils = require("Main.Guide.GuideUtils")
local GuideDirect = require("consts.mzm.gsp.guide.confbean.GuideDirect")
local Vector = require("Types.Vector")
local ISeeGuide = Lplus.Extend(ECPanelBase, "ISeeGuide")
local def = ISeeGuide.define
local _instance
def.static("=>", ISeeGuide).Instance = function()
  if _instance == nil then
    _instance = ISeeGuide()
  end
  return _instance
end
def.const("table").ArrowPos = {
  up = {
    x = 0,
    y = -100,
    r = 180
  },
  down = {
    x = 0,
    y = 100,
    r = 0
  },
  left = {
    x = 100,
    y = 0,
    r = -90
  },
  right = {
    x = -100,
    y = 0,
    r = 90
  }
}
def.field("number").cfgId = 0
def.field("function").callback = nil
def.field("number").correctTimer = 0
def.static("number", "function").ShowISee = function(cfgId, cb)
  local dlg = ISeeGuide.Instance()
  if dlg.m_created then
    warn("ShowISee when a other guide is show")
    return
  end
  dlg.cfgId = cfgId
  dlg.callback = cb
  dlg:SetDepth(4)
  dlg:CreatePanel(RESPATH.PREFAB_FORCE_GUIDE, 0)
end
def.static().Close = function()
  local dlg = ISeeGuide.Instance()
  GameUtil.RemoveGlobalTimer(dlg.correctTimer)
  dlg.correctTimer = 0
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  require("GUI.ECGUIMan").Instance():LockUI(false)
  self:SetGuideHead()
  self:UpdateGuide()
  self.correctTimer = GameUtil.AddGlobalTimer(0, false, function()
    self:UpdateGuide()
  end)
  gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.correctTimer)
  self.correctTimer = 0
end
def.override("boolean").OnShow = function(self, show)
end
def.method().SetGuideHead = function(self)
  local cfg = GuideUtils.GetStepCfg(self.cfgId)
  if cfg.guidevoiceid > 0 then
    local ECSoundMan = require("Sound.ECSoundMan")
    ECSoundMan.Instance():Play2DInterruptSoundByID(cfg.guidevoiceid)
  end
  local groupRight = self.m_panel:FindDirect("Img_Right")
  local groupLeft = self.m_panel:FindDirect("Img_Left")
  local head
  if cfg.guidedirect == GuideDirect.LEFT then
    head = groupLeft
    groupRight:SetActive(false)
    groupLeft:SetActive(true)
  else
    head = groupRight
    groupLeft:SetActive(false)
    groupRight:SetActive(true)
  end
  head:set_localPosition(Vector.Vector3.new(cfg.x, cfg.y, 0))
  local sentence = head:FindDirect("Label"):GetComponent("UILabel")
  sentence:set_text(cfg.textdesc)
end
def.method().UpdateGuide = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local cfg = GuideUtils.GetStepCfg(self.cfgId)
  local uiName = cfg.uipath
  if uiName == "FightTarget" then
    local FightMgr = require("Main.Fight.FightMgr")
    local id, x, y = -1, 0, 0
    if self.teamSelect == 0 and self.targetSelect == 0 then
      id, x, y = FightMgr.Instance():GetFightUnitByPos(2, cfg.param + 1)
    else
      id, x, y = FightMgr.Instance():GetFightUnitByPos(self.teamSelect, self.targetSelect)
    end
    self:SetRectRaw(x, y)
  elseif uiName == "task" then
    local MainUITaskTrace = require("Main.MainUI.ui.MainUITaskTrace")
    local target = MainUITaskTrace.Instance():GetTaskTraceUIItem(cfg.param)
    if target ~= nil and target:get_activeInHierarchy() then
      self:FitSelect(target)
    else
      warn("UI Changed, break this guide")
      self.callback(self.cfgId, false)
    end
  else
    local uiRoot = require("GUI.ECGUIMan").Instance().m_UIRoot
    local target = uiRoot:FindDirect(uiName)
    if target ~= nil and target:get_activeInHierarchy() then
      self:FitSelect(target)
    else
      warn("UI Changed, break this guide")
      self.callback(self.cfgId, false)
    end
  end
end
def.method().FitArrow = function(self)
  local select = self.m_panel:FindDirect("Group_Hand")
  local position = select:get_position()
  local x = position.x ~= 0 and position.x or 1
  local y = position.y ~= 0 and position.y or 1
  local ratio = x / y
  local dir = "up"
  if ratio > 0 then
    if ratio <= 1.5 then
      dir = y > 0 and "up" or "down"
    else
      dir = x > 0 and "right" or "left"
    end
  elseif ratio >= -1.5 then
    dir = y > 0 and "up" or "down"
  else
    dir = x > 0 and "right" or "left"
  end
  local arrow = self.m_panel:FindDirect("Group_Hand/Arrow")
  self:SetArrow(dir, arrow)
end
def.method("string", "userdata").SetArrow = function(self, dir, arrow)
  local x = ISeeGuide.ArrowPos[dir].x
  local y = ISeeGuide.ArrowPos[dir].y
  local r = ISeeGuide.ArrowPos[dir].r
  arrow:set_localPosition(Vector.Vector3.new(x, y, 0))
  arrow:set_localRotation(Quaternion.Euler(Vector.Vector3.new(0, 0, r)))
end
def.method("userdata").FitSelect = function(self, target)
  local widget = target:GetComponent("UIWidget")
  if widget ~= nil then
    local height = widget:get_height()
    local width = widget:get_width()
    local select = self.m_panel:FindDirect("Group_Hand")
    local offset = target:GetComponent("UIWidget"):get_pivotOffset()
    local offsetX = 0 - (offset.x - 0.5) * width
    local offsetY = 0 - (offset.y - 0.5) * height
    local widget1 = select:GetComponent("UIWidget")
    widget1:set_width(width)
    widget1:set_height(height)
    local position = target:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    select:set_localPosition(Vector.Vector3.new(screenPos.x + offsetX, screenPos.y + offsetY, 0))
    self:FitArrow()
  else
    error("This GameObject did't have UIwidget" .. target.name)
  end
end
def.method("number", "number").SetRectRaw = function(self, x, y)
  local select = self.m_panel:FindDirect("Group_Hand")
  local widget1 = select:GetComponent("UIWidget")
  widget1:set_width(128)
  widget1:set_height(128)
  select:set_localPosition(Vector.Vector3.new(x, y + 64, 0))
  self:FitArrow()
end
def.method("string").onClick = function(self, id)
  if id == "Img_Under" then
    self.callback(self.cfgId, true, false)
  elseif id == "Img_Select" then
    self.callback(self.cfgId, true, true)
  end
end
ISeeGuide.Commit()
return ISeeGuide
