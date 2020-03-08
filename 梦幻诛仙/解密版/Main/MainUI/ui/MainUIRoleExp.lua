local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUIRoleExp = Lplus.Extend(ComponentBase, "MainUIRoleExp")
local def = MainUIRoleExp.define
def.const("number").PROGRESS_DURATION_TIME = 1
def.const("number").PROGRESS_BACK_DURATION_TIME = 1
def.field("number").lastProgress = -1
def.field("number").progress = 0
def.field("table").uiObjs = nil
local instance
def.static("=>", MainUIRoleExp).Instance = function()
  if instance == nil then
    instance = MainUIRoleExp()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
end
def.override("=>", "boolean").CanShowInFight = function(self)
  return true
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, MainUIRoleExp.OnInitHeroProp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MainUIRoleExp.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_EXP_CHANGED, MainUIRoleExp.OnHeroExpChanged)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, MainUIRoleExp.OnInitHeroProp)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MainUIRoleExp.OnHeroLevelUp)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_EXP_CHANGED, MainUIRoleExp.OnHeroExpChanged)
  self:Clear()
end
def.override().OnShow = function(self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.method().InitUI = function(self)
end
def.method().UpdateUI = function(self)
  self:UpdateUIEx(false)
  self:UpdateProgressLinePos()
end
def.method("boolean").UpdateUIEx = function(self, isLevelUp)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  self:SetRoleExpBar(heroProp.exp, heroProp.nextLevelExp, isLevelUp)
end
def.static("table", "table").OnInitHeroProp = function(param1, param2)
  if instance.m_panel == nil then
    return
  end
  instance:UpdateUI()
end
def.static("table", "table").OnHeroLevelUp = function(param1, param2)
  instance:UpdateUIEx(true)
end
def.static("table", "table").OnHeroExpChanged = function(param1, param2)
  instance:UpdateUI()
end
local timerId = 0
def.method("number", "number", "boolean").SetRoleExpBar = function(self, exp, maxExp, isLevelUp)
  local slider_exp = self.m_node:GetComponent("UISlider")
  local value = exp / maxExp
  if not (value <= 1) or not value then
    value = 1
  end
  self.progress = value
  if self.lastProgress < 0 then
    slider_exp:set_sliderValue(self.progress)
    self.lastProgress = self.progress
  else
    self.lastProgress = slider_exp.sliderValue
    if isLevelUp then
      local time = self:GetProgressDurationTime(self.lastProgress, 1)
      slider_exp:AutoProgress(true, self.lastProgress, 1, time)
      if timerId ~= 0 then
        GameUtil.RemoveGlobalTimer(timerId)
        timerId = 0
      end
      timerId = GameUtil.AddGlobalTimer(time, true, function(...)
        if slider_exp.isnil then
          return
        end
        local time = self:GetProgressDurationTime(0, self.progress)
        slider_exp:set_sliderValue(0)
        slider_exp:AutoProgress(true, 0, self.progress, time)
        timerId = 0
      end)
    else
      local time = self:GetProgressDurationTime(self.lastProgress, self.progress)
      slider_exp:AutoProgress(true, self.lastProgress, self.progress, time)
    end
  end
end
def.method("number", "number", "=>", "number").GetProgressDurationTime = function(self, lastProgress, progress)
  return math.abs((progress - lastProgress) * MainUIRoleExp.PROGRESS_DURATION_TIME)
end
def.method("number", "number", "=>", "number").GetProgressBackDurationTime = function(self, lastProgress, progress)
  return math.abs((progress - lastProgress) * MainUIRoleExp.PROGRESS_BACK_DURATION_TIME)
end
def.method().UpdateProgressLinePos = function(self)
  local Vector = require("Types.Vector")
  local Grid_Line = self.m_node:FindDirect("Grid_Line")
  GameUtil.AddGlobalLateTimer(0, true, function()
    GameUtil.AddGlobalLateTimer(0, true, function()
      if Grid_Line.isnil then
        return
      end
      local widget = self.m_node:GetComponent("UIWidget")
      local w = widget.width
      local cellw = w / 10
      Grid_Line.transform.localPosition = Vector.Vector3.new(-w / 2, 0, 0)
      for i = 1, 9 do
        local item = Grid_Line:FindDirect("item_" .. i)
        if item then
          item.transform.localPosition = Vector.Vector3.new(i * cellw, 0, 0)
        end
      end
    end)
  end)
end
def.method().Clear = function(self)
  self.lastProgress = -1
  self.progress = 0
end
MainUIRoleExp.Commit()
return MainUIRoleExp
