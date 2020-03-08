local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattlePanel = Lplus.Extend(ECPanelBase, "CrossBattlePanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local GUIUtils = require("GUI.GUIUtils")
local def = CrossBattlePanel.define
def.const("number").ALL_STAGE_NUM = 6
local instance
def.static("=>", CrossBattlePanel).Instance = function()
  if instance == nil then
    instance = CrossBattlePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_PROGRESS, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setCrossBattleStageInfo()
    self:UpdateBetNotify()
  else
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Apply_SUCCESS, CrossBattlePanel.OnApplySuccess)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Cancel_Apply_SUCCESS, CrossBattlePanel.OnCallApplySuccess)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Apply_SUCCESS, CrossBattlePanel.OnApplySuccess)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Cancel_Apply_SUCCESS, CrossBattlePanel.OnCallApplySuccess)
end
def.static("table", "table").OnApplySuccess = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setCrossBattleStageInfo()
  end
end
def.static("table", "table").OnCallApplySuccess = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setCrossBattleStageInfo()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------CrossBattlePanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Lock" then
    local parentName = clickObj.parent.name
    local parentStrs = string.split(parentName, "_")
    local stage = tonumber(parentStrs[3])
    if stage then
      stage = stage - 1
      local openTime, _ = CrossBattleInterface.Instance():getCrossBattleStageTime(stage)
      if openTime > 0 then
        local nYear = tonumber(os.date("%Y", openTime))
        local nMonth = tonumber(os.date("%m", openTime))
        local nDay = tonumber(os.date("%d", openTime))
        local nHour = tonumber(os.date("%H", openTime))
        local nMin = tonumber(os.date("%M", openTime))
        local nSec = tonumber(os.date("%S", openTime))
        Toast(string.format(textRes.CrossBattle[4], textRes.CrossBattle.stageStr[stage], nYear, nMonth, nDay, nHour, nMin))
      end
    end
  elseif strs[1] == "Img" and strs[2] == "State" then
    local stage = tonumber(strs[3])
    if stage then
      if CrossBattleInterface.Instance().isActivityOpen or not CrossBattleInterface.Instance():isCrossBattleOpen() then
        stage = stage - 1
        Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Stage_Click, {stage})
      else
        Toast(textRes.CrossBattle[46])
      end
    end
  elseif id == "Btn_Prize" then
    GUIUtils.SetLightEffect(clickObj, GUIUtils.Light.None)
    require("Main.CrossBattle.Bet.CrossBattleBetMgr").Instance():ShowBetInfo()
  elseif id == "Btn_Plan" then
    require("Main.CrossBattle.ui.CrossBattleSchedulePanel").Instance():ShowPanel()
  elseif id == "Btn_Look" then
    if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CROSS_BATTLE_WITNESS_BATTLE) then
      Toast(textRes.CrossBattle[39])
      return
    end
    if require("Utility.DeviceUtility").IsNetStreamBufferBugFixed() then
      self:Hide()
      local WatchGamePanel = require("Main.CrossBattle.ui.WatchGamePanel")
      WatchGamePanel.Instance():ShowPanel()
    else
      local CommonConfirm = require("GUI.CommonConfirmDlg")
      CommonConfirm.ShowCerternConfirm(textRes.Common[602], textRes.CrossBattle[68], "", nil, nil)
    end
  elseif id == "Btn_History" then
    Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_History_Click, nil)
  elseif id == "Btn_Prize" or id == "Btn_Look" then
    Toast(textRes.CrossBattle[52])
  elseif id == "Btn_Reward" then
    require("Main.CrossBattle.ui.CrossBattleAwardPanel").Instance():ShowPanel()
  end
end
def.method().setCrossBattleStageInfo = function(self)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  local Group_State = self.m_panel:FindDirect("Img_Bg/Group_State")
  for i = 0, CrossBattleActivityStage.STAGE_FINAL do
    local Img_State = Group_State:FindDirect("Img_State_" .. i + 1)
    if Img_State then
      local Btn_Lock = Img_State:FindDirect("Btn_Lock")
      local Texture_State = Img_State:FindDirect("Texture_State")
      local Img_Texture = Img_State:GetComponent("UITexture")
      if i == CrossBattleActivityStage.STAGE_REGISTER then
        local Img_State_Dis = Img_State:FindDirect("Img_State_Dis")
        local Img_State_Act = Img_State:FindDirect("Img_State_Act")
        if curStage == CrossBattleActivityStage.STAGE_REGISTER and crossBattleInterface:isApplyCrossBattle() then
          Img_State_Dis:SetActive(true)
          Img_State_Act:SetActive(false)
          Img_Texture = Img_State_Dis:GetComponent("UITexture")
        else
          Img_State_Dis:SetActive(false)
          Img_State_Act:SetActive(true)
          Img_Texture = Img_State_Act:GetComponent("UITexture")
        end
      end
      local openFn = crossBattleInterface:getCrossBattleStageFn(i)
      if crossBattleInterface.isActivityOpen and i <= curStage then
        GUIUtils.SetTextureEffect(Img_Texture, GUIUtils.Effect.Normal)
      else
        GUIUtils.SetTextureEffect(Img_Texture, GUIUtils.Effect.Gray)
      end
      if i == curStage then
        if openFn then
          if openFn(i) then
            Texture_State:SetActive(true)
          else
            Texture_State:SetActive(false)
          end
        else
          Texture_State:SetActive(true)
        end
      else
        Texture_State:SetActive(false)
      end
    end
  end
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local Btn_Reward = self.m_panel:FindDirect("Img_Bg/Btn_Reward")
  local isShowAward = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_CROSS_BATTLE_AWARD_PREVIEW)
  GUIUtils.SetActive(Btn_Reward, isShowAward)
end
def.method().UpdateBetNotify = function(self)
  local Btn_Prize = self.m_panel:FindDirect("Img_Bg/Group_Btn/Btn_Prize")
  local hasBetNotify = require("Main.CrossBattle.Bet.CrossBattleBetMgr").Instance():HasBetNotify()
  if hasBetNotify then
    GUIUtils.SetLightEffect(Btn_Prize, GUIUtils.Light.Round)
  else
    GUIUtils.SetLightEffect(Btn_Prize, GUIUtils.Light.None)
  end
end
CrossBattlePanel.Commit()
return CrossBattlePanel
