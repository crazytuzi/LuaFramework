local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangDungeonMainPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local GangDungeonModule = require("Main.GangDungeon.GangDungeonModule")
local GangDungeonUtils = require("Main.GangDungeon.GangDungeonUtils")
local OpenTimeHelper = require("Main.GangDungeon.OpenTimeHelper")
local def = GangDungeonMainPanel.define
def.field("table").m_UIGOs = nil
def.field("dynamic").m_timerId = nil
local instance
def.static("=>", GangDungeonMainPanel).Instance = function()
  if instance == nil then
    instance = GangDungeonMainPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_GANG_DUNGEON_MAIN, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  self.m_timerId = GameUtil.AddGlobalTimer(1, false, function()
    self:UpdateLeftTime()
    self:UpdateConfirmBtn()
    self:UpdateTips()
  end)
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.OpenTimeChanged, GangDungeonMainPanel.OnOpenTimeChanged)
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ParticipateTimesChanged, GangDungeonMainPanel.OnParticipateTimesChanged)
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ActivityReset, GangDungeonMainPanel.OnActivityReset)
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  if self.m_timerId then
    GameUtil.RemoveGlobalTimer(self.m_timerId)
    self.m_timerId = nil
  end
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.OpenTimeChanged, GangDungeonMainPanel.OnOpenTimeChanged)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ParticipateTimesChanged, GangDungeonMainPanel.OnParticipateTimesChanged)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ActivityReset, GangDungeonMainPanel.OnActivityReset)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnClickConfirmBtn()
  elseif id == "Btn_Help" then
    self:ShowTips()
  end
end
def.method().OnClickConfirmBtn = function(self)
  local btnText
  if GangDungeonModule.Instance():IsDungeonOpen() then
    self:DestroyPanel()
    GangDungeonModule.Instance():GoToDungeonEntry()
  elseif GangDungeonModule.Instance():IsDungeonClose() then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local activityId = GangDungeonModule.Instance():GetActivityId()
    local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
    local activityName = activityCfg and activityCfg.activityName or "$activity_name"
    Toast(textRes.GangDungeon[18]:format(activityName))
  else
    if GangDungeonModule.Instance():CheckOpenGangDungeonAuthority() == false then
      return
    end
    if GangDungeonModule.Instance():HasSetOpenTime() then
      if GangDungeonModule.Instance():CheckValidChangeTime() == false then
        return
      end
      self:OpenDateSettingPanel()
    elseif not GangDungeonModule.Instance():IsGangCreateTimeSatisfy() then
      local requiredHours = GangDungeonModule.Instance():GetRequiredGangCreateHours()
      Toast(textRes.GangDungeon[38]:format(requiredHours))
    else
      local costGangMoney = GangDungeonModule.Instance():GetCostGangMoney()
      if costGangMoney > 0 and GangDungeonModule.Instance():IsGangMoneyEnough() then
        self:ShowCostGangMoneyConfirm(costGangMoney, function(s)
          if s == 1 then
            self:OpenDateSettingPanel()
          end
        end)
      elseif costGangMoney > 0 then
        Toast(textRes.GangDungeon[37]:format(costGangMoney))
      else
        self:OpenDateSettingPanel()
      end
    end
  end
end
def.method("number", "function").ShowCostGangMoneyConfirm = function(self, costGangMoney, callback)
  local function showCostConfirm()
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local desc = textRes.GangDungeon[36]:format(costGangMoney)
    CommonConfirmDlg.ShowConfirm(textRes.Common[8], desc, callback, nil)
  end
  if GangDungeonModule.Instance():IsGangMoneyEnoughForMaintain() then
    showCostConfirm()
  else
    self:ShowMoneyNotEnoughForMaintainConfirm(showCostConfirm)
  end
end
def.method("function").ShowMoneyNotEnoughForMaintainConfirm = function(self, callback)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local activityName = GangDungeonModule.Instance():GetActivityName()
  local desc = textRes.GangDungeon[52]:format(activityName)
  CommonConfirmDlg.ShowConfirm(textRes.Gang[293], desc, function(s)
    if s == 1 then
      _G.SafeCallback(callback)
    end
  end, nil)
end
def.method().OpenDateSettingPanel = function(self)
  require("Main.GangDungeon.ui.SetOpenTimePanel").Instance():ShowPanel()
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Label_CurTime = self.m_UIGOs.Img_Bg0:FindDirect("Label_CurTime")
  self.m_UIGOs.Label_LeftTime = self.m_UIGOs.Img_Bg0:FindDirect("Label_NextTime")
  self.m_UIGOs.Btn_Confirm = self.m_UIGOs.Img_Bg0:FindDirect("Btn_Confirm")
  self.m_UIGOs.Label_Confirm = self.m_UIGOs.Btn_Confirm:FindDirect("Label_Confirm")
  self.m_UIGOs.Label_Tips = self.m_UIGOs.Img_Bg0:FindDirect("Label_Tips")
  self.m_UIGOs.Label_NextName = self.m_UIGOs.Img_Bg0:FindDirect("Label_NextName")
  self.m_UIGOs.Label_WeekTime = self.m_UIGOs.Img_Bg0:FindDirect("Label_WeekTime")
  self.m_UIGOs.Label_CurName = self.m_UIGOs.Img_Bg0:FindDirect("Label_CurName")
  GUIUtils.SetText(self.m_UIGOs.Label_CurName, textRes.GangDungeon[59])
end
def.method().UpdateUI = function(self)
  self:UpdateOpenTime()
  self:UpdateLeftTime()
  self:UpdateConfirmBtn()
  self:UpdateTips()
  self:UpdateParticipateTimes()
end
def.method().ShowTips = function(self)
  local tipsId = GangDungeonUtils.GetConstant("Tips")
  GUIUtils.ShowHoverTip(tipsId)
end
def.method().UpdateOpenTime = function(self)
  local openTime = GangDungeonModule.Instance():GetOpenDateTime()
  local timeText = GangDungeonUtils.ConvertOpenTime2Text(openTime)
  GUIUtils.SetText(self.m_UIGOs.Label_CurTime, timeText)
end
def.method().UpdateLeftTime = function(self)
  local timeText
  local openTimestamp = GangDungeonModule.Instance():GetRecentlyOpenTimestamp()
  if openTimestamp == -1 then
    timeText = textRes.GangDungeon[14]
    GUIUtils.SetText(self.m_UIGOs.Label_LeftTime, timeText)
    local nameText = textRes.GangDungeon[56]
    GUIUtils.SetText(self.m_UIGOs.Label_NextName, nameText)
    return
  end
  local nameText = textRes.GangDungeon[56]
  local curTime = _G.GetServerTime()
  local leftSeconds = openTimestamp - curTime
  if leftSeconds > 0 then
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local t = AbsoluteTimer.GetServerTimeTable(openTimestamp)
    timeText = _G.SeondsToTimeText(leftSeconds)
  elseif GangDungeonModule.Instance():IsDungeonClose() then
    timeText = textRes.GangDungeon[16]
  else
    local stage = GangDungeonModule.Instance():GetDungeonStage()
    if stage == GangDungeonModule.DungeonStage.STG_PREPARE then
      nameText, timeText = self:GetPrepareCountDownTxt()
    elseif stage == GangDungeonModule.DungeonStage.STG_BOSS_COUNTDOWN then
      nameText, timeText = self:GetBossAppearCountDownTxt()
    elseif stage == GangDungeonModule.DungeonStage.STG_KILL_BOSS then
      nameText, timeText = self:GetBossDisappearCountDownTxt()
    elseif stage == GangDungeonModule.DungeonStage.STG_FINISH_COUNTDOWN then
      nameText, timeText = self:GetDungeonCloseCountDownTxt()
    else
      nameText, timeText = self:GetDungeonTimeoutCloseCountDownTxt()
    end
  end
  GUIUtils.SetText(self.m_UIGOs.Label_NextName, nameText)
  GUIUtils.SetText(self.m_UIGOs.Label_LeftTime, timeText)
end
def.method("=>", "string", "string").GetPrepareCountDownTxt = function(self)
  local leftSeconds = GangDungeonModule.Instance():GetStageEndLeftSeconds()
  local timeText = _G.SeondsToTimeText(leftSeconds)
  return textRes.GangDungeon[58]:format(""), timeText
end
def.method("=>", "string", "string").GetBossAppearCountDownTxt = function(self)
  local leftSeconds = GangDungeonModule.Instance():GetStageEndLeftSeconds()
  local timeText = _G.SeondsToTimeText(leftSeconds)
  return textRes.GangDungeon[40]:format(""), timeText
end
def.method("=>", "string", "string").GetBossDisappearCountDownTxt = function(self)
  local leftSeconds = GangDungeonModule.Instance():GetStageEndLeftSeconds()
  local timeText = _G.SeondsToTimeText(leftSeconds)
  return textRes.GangDungeon[41]:format(""), timeText
end
def.method("=>", "string", "string").GetDungeonCloseCountDownTxt = function(self)
  local leftSeconds = GangDungeonModule.Instance():GetStageEndLeftSeconds()
  local timeText = _G.SeondsToTimeText(leftSeconds)
  return textRes.GangDungeon[42]:format(""), timeText
end
def.method("=>", "string", "string").GetDungeonTimeoutCloseCountDownTxt = function(self)
  local endTime = GangDungeonModule.Instance():GetTimeoutEndTimestamp()
  local curTime = _G.GetServerTime()
  local leftSeconds = math.max(0, endTime - curTime)
  local timeText = _G.SeondsToTimeText(leftSeconds)
  return textRes.GangDungeon[42]:format(""), timeText
end
def.method().UpdateConfirmBtn = function(self)
  local btnText
  if GangDungeonModule.Instance():IsDungeonOpen() then
    btnText = textRes.GangDungeon[17]
  elseif GangDungeonModule.Instance():IsDungeonClose() then
    btnText = textRes.GangDungeon[16]
  elseif GangDungeonModule.Instance():HasSetOpenTime() then
    btnText = textRes.GangDungeon[34]
  else
    btnText = textRes.GangDungeon[5]
  end
  GUIUtils.SetText(self.m_UIGOs.Label_Confirm, btnText)
end
def.method().UpdateTips = function(self)
  local total = GangDungeonModule.Instance():GetTotalActivateTimes()
  local left = total - GangDungeonModule.Instance():GetActivateTimes()
  left = math.max(0, left)
  local activityName = GangDungeonModule.Instance():GetActivityName()
  local text = textRes.GangDungeon[55]:format(activityName, total, left)
  GUIUtils.SetText(self.m_UIGOs.Label_Tips, text)
end
def.method().UpdateParticipateTimes = function(self)
  local leftTimes = GangDungeonModule.Instance():GetSelfParticipateLeftTimes()
  local text = textRes.GangDungeon[57]:format(leftTimes)
  GUIUtils.SetText(self.m_UIGOs.Label_WeekTime, text)
end
def.static("table", "table").OnOpenTimeChanged = function(params, context)
  instance:UpdateOpenTime()
  instance:UpdateLeftTime()
  instance:UpdateConfirmBtn()
end
def.static("table", "table").OnParticipateTimesChanged = function(params, context)
  instance:UpdateParticipateTimes()
end
def.static("table", "table").OnActivityReset = function(params, context)
  instance:UpdateUI()
end
return GangDungeonMainPanel.Commit()
