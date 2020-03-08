local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BattlefieldLoadingPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local MathHelper = require("Common.MathHelper")
local CrossBattlefieldUtils = require("Main.CrossBattlefield.CrossBattlefieldUtils")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local def = BattlefieldLoadingPanel.define
local AUTO_RPOGRESS_DURATION = 0.5
def.field("table").m_UIGOs = nil
def.field("number").m_battlefieldActId = 0
def.field("number").m_progress = 0
def.field("number").m_lastProgress = 0
def.field("function").m_fakeProgressFunc = nil
def.field("number").m_timeId = 0
local instance
def.static("=>", BattlefieldLoadingPanel).Instance = function()
  if instance == nil then
    instance = BattlefieldLoadingPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, BattlefieldLoadingPanel.OnLeaveWorldStage)
  Event.RegisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.EnterSingleBattle, BattlefieldLoadingPanel.OnEnterBattlefield)
end
def.method("number").ShowPanel = function(self, activityId)
  self.m_battlefieldActId = activityId
  self.m_progress = 0
  self.m_lastProgress = self.m_progress
  self.m_fakeProgressFunc = nil
  self:RemoveProgressTimer()
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateUI()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_CROSS_BATTLEFIELD_LOADING_PANEL, -1)
  self:SetDepth(GUIDEPTH.TOP)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_battlefieldActId = 0
  self.m_progress = 0
  self.m_lastProgress = 0
  self.m_fakeProgressFunc = nil
  self:RemoveProgressTimer()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == false then
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Group_Slider = self.m_panel:FindDirect("Group_Slider")
  self.m_UIGOs.Label_Tips = self.m_UIGOs.Group_Slider:FindDirect("Label_Tips")
  self.m_UIGOs.Img_BgSlider = self.m_UIGOs.Group_Slider:FindDirect("Img_BgSlider")
  self.m_UIGOs.Img_Name = self.m_panel:FindDirect("Img_Name")
  self.m_UIGOs.Group_RedName = self.m_panel:FindDirect("Group_RedName")
  self.m_UIGOs.Group_BlueName = self.m_panel:FindDirect("Group_BlueName")
end
def.method().UpdateUI = function(self)
  self:UpdateProgress()
  self:UpdateBattlefielInfo()
end
def.method().UpdateBattlefielInfo = function(self)
  local Img_Red = self.m_UIGOs.Group_RedName:FindDirect("Img_Red")
  local Img_LabelRed = self.m_UIGOs.Group_RedName:FindDirect("Img_LabelRed")
  local Img_Blue = self.m_UIGOs.Group_BlueName:FindDirect("Img_Blue")
  local Img_LabelBlue = self.m_UIGOs.Group_BlueName:FindDirect("Img_LabelBlue")
  local Label_Tips = self.m_UIGOs.Label_Tips
  local camp1Cfg, camp2Cfg, crossfieldDesc, titleSpriteName
  local crossFieldcfg = CrossBattlefieldUtils.GetCrossBattlefieldCfg(self.m_battlefieldActId)
  if crossFieldcfg then
    crossfieldDesc = crossFieldcfg.field_desc
    titleSpriteName = crossFieldcfg.img_name
    local battlefieldCfg = CaptureTheFlagUtils.GetBattleCfg(crossFieldcfg.single_battle_cfg_id)
    if battlefieldCfg then
      camp1Cfg = CaptureTheFlagUtils.GetCampCfg(battlefieldCfg.camp1)
      camp2Cfg = CaptureTheFlagUtils.GetCampCfg(battlefieldCfg.camp2)
    end
  end
  if camp1Cfg then
    GUIUtils.SetSprite(Img_Red, camp1Cfg.icon)
    GUIUtils.SetSprite(Img_LabelRed, camp1Cfg.campNameIcon)
  end
  if camp2Cfg then
    GUIUtils.SetSprite(Img_Blue, camp2Cfg.icon)
    GUIUtils.SetSprite(Img_LabelBlue, camp2Cfg.campNameIcon)
  end
  GUIUtils.SetText(Label_Tips, crossfieldDesc or "unknow")
  GUIUtils.SetSprite(self.m_UIGOs.Img_Name, titleSpriteName or "unknow")
end
def.method("number").SetProgress = function(self, val)
  self.m_lastProgress = self.m_progress
  self.m_progress = MathHelper.Clamp(val, 0, 1)
  if not self:IsLoaded() then
    return
  end
  self:UpdateProgress()
end
def.method("function").SetFakeProgressFunc = function(self, func)
  self.m_fakeProgressFunc = func
  self:StartProgressTimer()
end
def.method().StartProgressTimer = function(self)
  self:RemoveProgressTimer()
  local func = self.m_fakeProgressFunc
  if func == nil then
    return
  end
  local startTick = GameUtil.GetTickCount()
  local function updateProgress()
    local t = (GameUtil.GetTickCount() - startTick) / 1000
    local nextProgress = func(t)
    self:SetProgress(nextProgress)
  end
  self.m_timeId = GameUtil.AddGlobalTimer(AUTO_RPOGRESS_DURATION, false, function()
    updateProgress()
  end)
  updateProgress()
end
def.method().RemoveProgressTimer = function(self)
  if self.m_timeId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_timeId)
    self.m_timeId = 0
  end
end
def.method().UpdateProgress = function(self)
  local uiSlider = self.m_UIGOs.Img_BgSlider:GetComponent("UISlider")
  uiSlider:AutoProgress(true, self.m_lastProgress, self.m_progress, AUTO_RPOGRESS_DURATION)
end
def.method().FinishLoading = function(self)
  self:SetProgress(1)
  self:RemoveProgressTimer()
  GameUtil.AddGlobalTimer(2 * AUTO_RPOGRESS_DURATION, true, function()
    self:DestroyPanel()
  end)
end
def.static("table", "table").OnLeaveWorldStage = function(params, context)
  instance:DestroyPanel()
end
def.static("table", "table").OnEnterBattlefield = function(params, context)
  instance:DestroyPanel()
end
return BattlefieldLoadingPanel.Commit()
