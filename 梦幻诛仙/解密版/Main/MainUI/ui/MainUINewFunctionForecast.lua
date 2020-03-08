local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUINewFunctionForecast = Lplus.Extend(ComponentBase, "MainUINewFunctionForecast")
local Vector = require("Types.Vector")
local def = MainUINewFunctionForecast.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GrowUtils = require("Main.Grow.GrowUtils")
local FunctionOpenInfo = require("netio.protocol.mzm.gsp.grow.FunctionOpenInfo")
local newFunctionData = require("Main.Grow.NewFunctionData").Instance()
def.static("=>", MainUINewFunctionForecast).Instance = function()
  if instance == nil then
    instance = MainUINewFunctionForecast()
    instance:Init()
  end
  return instance
end
def.field("table")._cfgs = nil
def.field("number")._currIndex = 1
def.override().Init = function(self)
  self._cfgs = {}
  local ModuleType = require("consts.mzm.gsp.grow.confbean.ModuleType")
  local cfgs = GrowUtils.GetAllFunctionOpenForecastCfg()
  for id, cfg in pairs(cfgs) do
    local growAchievementCfg = GrowUtils.GetGrowAchievementCfg(cfg.id)
    cfg.title = growAchievementCfg.title
    cfg.openLevel = growAchievementCfg.openLevel
    cfg.iconId = growAchievementCfg.iconId
    cfg.goalDes = growAchievementCfg.goalDes
    table.insert(self._cfgs, cfg)
  end
  local sortFn = function(l, r)
    local lsortKey = l.openLevel * 100 + l.priority
    local rsortKey = r.openLevel * 100 + r.priority
    return lsortKey < rsortKey
  end
  table.sort(self._cfgs, sortFn)
end
def.override("=>", "boolean").CanShowInFight = function(self)
  return false
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, function(p1, p2)
    self:OnSyncHeroLevel()
  end)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, function(p1, p2)
    self:OnHeroLevelUp()
  end)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.NewFunction_Changed, function(p1, p2)
    self:OnNewFunctionChanged(p1)
  end)
end
def.override().OnDestroy = function(self)
end
def.override().OnShow = function(self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.method().UpdateUI = function(self)
  if self:IsShow() == false then
    return
  end
  local hasFinished = false
  local hasGoing = false
  local hasNil = false
  self._currIndex = 1
  for idx, cfg in pairs(self._cfgs) do
    local targetState = newFunctionData._newFunctionInfo[cfg.id]
    if targetState == FunctionOpenInfo.ST_FINISHED then
      hasFinished = true
    end
    self._currIndex = idx
    if targetState == FunctionOpenInfo.ST_ON_GOING then
      hasGoing = true
      break
    end
    if targetState == nil then
      warn("*********************************UpdateUI() targetState == nil", cfg.id, cfg.title)
      hasNil = true
      break
    end
  end
  local Img_BgNewFunc = self.m_node:FindDirect("Img_BgNewFunc")
  local Img_Red = Img_BgNewFunc:FindDirect("Img_Red")
  Img_Red:SetActive(hasFinished == true)
  local Label_Notice = self.m_node:FindDirect("Label_Notice")
  Label_Notice:SetActive(hasFinished == true)
  if hasFinished == false and hasGoing == false then
    Img_BgNewFunc:SetActive(false)
    return
  else
    Img_BgNewFunc:SetActive(true)
  end
  self:Fill()
end
def.override("string").OnClick = function(self, id)
  if id == "Img_BgNewFunc" then
    local NewFunctionForecast = require("Main.MainUI.ui.NewFunctionForecast")
    local newFunctionForecast = NewFunctionForecast.Instance()
    newFunctionForecast:ShowDlg(self._cfgs)
    return
  end
end
def.method().OnHeroLevelUp = function(self)
  self:UpdateUI()
end
def.method().OnSyncHeroLevel = function(self)
  self:UpdateUI()
end
def.method("table").OnNewFunctionChanged = function(self, p)
  self:UpdateUI()
end
def.method().Fill = function(self)
  local cfg = self._cfgs[self._currIndex]
  local Img_BgNewFunc = self.m_node:FindDirect("Img_BgNewFunc")
  local Textrue_Icon = Img_BgNewFunc:FindDirect("Textrue_Icon")
  local Group_Preview = Img_BgNewFunc:FindDirect("Group_Preview")
  local Label_Lv = Group_Preview:FindDirect("Label_Lv")
  local Label_Name = Group_Preview:FindDirect("Label_Name")
  local Group_Get = Img_BgNewFunc:FindDirect("Group_Get")
  local uiTexture = Textrue_Icon:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, cfg.iconId)
  local targetState = newFunctionData._newFunctionInfo[cfg.id]
  if targetState == FunctionOpenInfo.ST_ON_GOING then
    Label_Lv:SetActive(true)
    Label_Lv:GetComponent("UILabel"):set_text(string.format(textRes.Grow[31], cfg.openLevel))
    Label_Name:SetActive(true)
    Label_Name:GetComponent("UILabel"):set_text(cfg.title)
    Group_Get:SetActive(false)
  else
    Label_Lv:SetActive(false)
    Label_Name:SetActive(false)
    Group_Get:SetActive(true)
  end
end
MainUINewFunctionForecast.Commit()
return MainUINewFunctionForecast
