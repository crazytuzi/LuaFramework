local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleApplyPanel = Lplus.Extend(ECPanelBase, "CrossBattleApplyPanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local crossBattleInterface = CrossBattleInterface.Instance()
local CrossBattleCostType = require("consts/mzm/gsp/crossbattle/confbean/CrossBattleCostType")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local GUIUtils = require("GUI.GUIUtils")
local def = CrossBattleApplyPanel.define
def.field("number").timerId = 0
def.field("table").avatarList = nil
def.field("number").selectedIdx = 0
local instance
def.static("=>", CrossBattleApplyPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleApplyPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_CREATE, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setApplyInfo()
  else
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Apply_SUCCESS, CrossBattleApplyPanel.OnApplySuccess)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Cancel_Apply_SUCCESS, CrossBattleApplyPanel.OnCallApplySuccess)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Apply_SUCCESS, CrossBattleApplyPanel.OnApplySuccess)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Cancel_Apply_SUCCESS, CrossBattleApplyPanel.OnCallApplySuccess)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.static("table", "table").OnApplySuccess = function(p1, p2)
  if instance:IsShow() then
    instance:setApplyInfo()
    instance:Hide()
  end
end
def.static("table", "table").OnCallApplySuccess = function(p1, p2)
  if instance:IsShow() then
    instance:setApplyInfo()
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------CrossBattleApplyPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Quit" then
    self:Hide()
  elseif id == "Btn_Creat" then
    if crossBattleInterface.isActivityOpen then
      if not crossBattleInterface:isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_REGISTER) then
        Toast(textRes.CrossBattle[39])
        return
      end
      local p = require("netio.protocol.mzm.gsp.crossbattle.CRegisterInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
      gmodule.network.sendProtocol(p)
      warn("--------CRegisterInCrossBattleReq:")
    else
      Toast(textRes.CrossBattle[20])
    end
  elseif id == "Btn_Cancel" then
    local p = require("netio.protocol.mzm.gsp.crossbattle.CUnregisterInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    gmodule.network.sendProtocol(p)
    warn("--------CUnregisterInCrossBattleReq:")
  end
end
def.method("=>", "table").getConditionList = function()
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local condList = {}
  local isTeamLeader = CorpsInterface.IsCorpsLeader()
  local cond1 = {
    content = textRes.CrossBattle[1],
    isAchieve = isTeamLeader
  }
  table.insert(condList, cond1)
  local memberNum = CorpsInterface.GetCorpsMembersCount()
  local lowerLimit = crossBattleCfg.register_corps_member_num_lower_limit
  if constant.CrossBattleConsts.REGISTER_TEAM_MEMBER_LOWRT_LIMIT then
    lowerLimit = constant.CrossBattleConsts.REGISTER_TEAM_MEMBER_LOWRT_LIMIT
  end
  local upperLimit = crossBattleCfg.register_corps_member_num_upper_limit
  warn("----------corps num:", memberNum, lowerLimit, upperLimit)
  local isNumAchieve = memberNum >= lowerLimit and memberNum <= upperLimit
  local cond2 = {
    content = string.format(textRes.CrossBattle[2], lowerLimit, upperLimit),
    isAchieve = isNumAchieve
  }
  table.insert(condList, cond2)
  local costType, costNum, ownNum = crossBattleInterface:getCrossBattleApplyCostInfo()
  local isGoldEnough = ownNum:gt(costNum) or ownNum:eq(costNum)
  local cond3 = {
    content = string.format(textRes.CrossBattle[3], costNum, textRes.CrossBattle.costTypeStr[costType]),
    isAchieve = isGoldEnough
  }
  table.insert(condList, cond3)
  return condList
end
def.method().setApplyInfo = function(self)
  local condList = self:getConditionList()
  local List_Member = self.m_panel:FindDirect("Img_Bg/Group_Center/Group_List/Scroll View/List_Member")
  local uiList = List_Member:GetComponent("UIList")
  uiList.itemCount = #condList
  uiList:Resize()
  local canApply = true
  for i, v in ipairs(condList) do
    local item = List_Member:FindDirect("item_" .. i)
    local Label_TermName = item:FindDirect("Label_TermName")
    local Img_Right = item:FindDirect("Group_Result/Img_Right")
    local Img_Wrong = item:FindDirect("Group_Result/Img_Wrong")
    Label_TermName:GetComponent("UILabel"):set_text(v.content)
    if v.isAchieve then
      Img_Wrong:SetActive(false)
      Img_Right:SetActive(true)
    else
      Img_Right:SetActive(false)
      Img_Wrong:SetActive(true)
      canApply = canApply and false
    end
  end
  local Btn_Creat = self.m_panel:FindDirect("Img_Bg/Group_Bottom/Btn_Creat")
  local Btn_Cancel = self.m_panel:FindDirect("Img_Bg/Group_Bottom/Btn_Cancel")
  Btn_Cancel:SetActive(false)
  Btn_Creat:SetActive(true)
  local btnCreate = Btn_Creat:GetComponent("UIButton")
  btnCreate.isEnabled = canApply
end
CrossBattleApplyPanel.Commit()
return CrossBattleApplyPanel
