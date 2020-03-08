local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleRoundRobinReadyPanel = Lplus.Extend(ECPanelBase, "CrossBattleRoundRobinReadyPanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local GUIUtils = require("GUI.GUIUtils")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local def = CrossBattleRoundRobinReadyPanel.define
def.field("number").timerId = 0
def.field("number").readyEndTime = 0
local instance
def.static("=>", CrossBattleRoundRobinReadyPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleRoundRobinReadyPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_BATTLE_IN, 0)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    if _G.PlayerIsInFight() then
      self:Hide()
      return
    end
    self:setReadyEndTime()
    self:setFightInfo()
    self:setCoundDownTime()
    self.timerId = GameUtil.AddGlobalTimer(1, false, function()
      self:setCoundDownTime()
    end)
  else
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method().setReadyEndTime = function(self)
  local index = CrossBattleInterface.Instance().roundRobinRoundIdx
  local readyStartTime, raceTime = CrossBattleInterface.Instance():getRoundRobinTimeByIndex(index)
  self.readyEndTime = raceTime
  warn("-------readyEndTime:", self.readyEndTime)
end
def.method().setCoundDownTime = function(self)
  if self.m_panel == nil then
    return
  end
  local leftTime = self.readyEndTime - _G.GetServerTime()
  if leftTime < 0 then
    leftTime = 0
  end
  local Label_LeftTime = self.m_panel:FindDirect("Img_Bg/Group_ProtectTime/Label_LeftTime")
  if leftTime == 0 then
    Label_LeftTime:GetComponent("UILabel"):set_text("")
    self:Hide()
    return
  end
  local mins = math.floor(leftTime / 60)
  local secs = leftTime - mins * 60
  Label_LeftTime:GetComponent("UILabel"):set_text(string.format(textRes.CrossBattle[37], mins, secs))
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Success, CrossBattleRoundRobinReadyPanel.OnRoundInfoChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Success, CrossBattleRoundRobinReadyPanel.OnRoundInfoChange)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Leave_Game_Scene, nil)
  gmodule.moduleMgr:GetModule(ModuleId.CROSS_BATTLE):SetCrossBattleSelectionState(false)
end
def.static("table", "table").OnRoundInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    local curIndex = CrossBattleInterface.Instance():getCurRoundRobinIndex()
    if curIndex == p1[1] then
      instance:setFightInfo()
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------CrossBattleReadPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Detail" then
    local CrossBattleRoundRobinArrangePanel = require("Main.CrossBattle.ui.CrossBattleRoundRobinArrangePanel")
    CrossBattleRoundRobinArrangePanel.Instance():ShowPanel()
  end
end
def.method("=>", "table", "table").getFightInfo = function(self)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local curIndex = crossBattleInterface:getCurRoundRobinIndex()
  local fightInfos = crossBattleInterface:getRoundRobinFightInfo(curIndex)
  if fightInfos and fightInfos.fightInfos then
    local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
    local myCorpsId
    if myCorpsInfo and myCorpsInfo.corpsId then
      myCorpsId = myCorpsInfo.corpsId
    end
    if myCorpsId then
      for i, v in ipairs(fightInfos.fightInfos) do
        local corpsA = v.corps_a_brief_info
        local corpsB = v.corps_b_brief_info
        if corpsA.corpsId:eq(myCorpsId) then
          return corpsA, corpsB
        end
        if corpsB.corpsId:eq(myCorpsId) then
          return corpsB, corpsA
        end
      end
    end
  end
  return nil, nil
end
def.method().setFightInfo = function(self)
  local Group_Label = self.m_panel:FindDirect("Img_Bg/Img_FightMember/Group_Label")
  local myCorpsInfo, targetCorpsInfo = self:getFightInfo()
  local Label_RedName = Group_Label:FindDirect("Label_RedName")
  local Label_BlueName = Group_Label:FindDirect("Label_BlueName")
  local Img_RedBadge = Group_Label:FindDirect("Img_RedBadge")
  local Img_BlueBadge = Group_Label:FindDirect("Img_BlueBadge")
  local red_texture = Img_RedBadge:GetComponent("UITexture")
  local blue_texture = Img_BlueBadge:GetComponent("UITexture")
  if myCorpsInfo and targetCorpsInfo then
    Label_RedName:GetComponent("UILabel"):set_text(GetStringFromOcts(targetCorpsInfo.name))
    Label_BlueName:GetComponent("UILabel"):set_text(GetStringFromOcts(myCorpsInfo.name))
    local targetBadgeCfg = CorpsUtils.GetCorpsBadgeCfg(targetCorpsInfo.corpsBadgeId)
    if targetBadgeCfg then
      GUIUtils.FillIcon(red_texture, targetBadgeCfg.iconId)
    end
    local myBadgeCfg = CorpsUtils.GetCorpsBadgeCfg(myCorpsInfo.corpsBadgeId)
    if myBadgeCfg then
      GUIUtils.FillIcon(blue_texture, myBadgeCfg.iconId)
    end
  else
    Label_RedName:GetComponent("UILabel"):set_text("")
    Label_BlueName:GetComponent("UILabel"):set_text("")
  end
end
CrossBattleRoundRobinReadyPanel.Commit()
return CrossBattleRoundRobinReadyPanel
