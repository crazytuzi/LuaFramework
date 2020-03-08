local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIGangChallenge = Lplus.Extend(ECPanelBase, "UIGangChallenge")
local GUIUtils = require("GUI.GUIUtils")
local GangChallengeData = require("Main.Soaring.data.GangChallengeData")
local def = UIGangChallenge.define
local instance, G_arrCompleteSections
local G_activityId = 0
local G_bIsInFight = false
local G_iGotTeamMemberAwardTimes = -1
def.field("number")._selectChallengeIdx = 0
def.field("number")._curPage = 1
def.field("table")._tblChallengeInfos = nil
def.field("table")._cfgData = nil
def.field("table")._uiGOs = nil
def.field("table")._ctrlItemList = nil
def.const("number").MAX_NODE_COUNT = 5
def.static("=>", UIGangChallenge).Instance = function()
  if instance == nil then
    instance = UIGangChallenge()
  end
  return instance
end
def.method("table").SetConfigData = function(self, cfgData)
  self._cfgData = cfgData
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, UIGangChallenge.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, UIGangChallenge.OnLeaveFight)
  self:InitUI()
  self:InitUIChangeList()
end
def.override().OnDestroy = function(self)
  warn(debug.traceback("UIGangChallenge OnDestroy"))
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, UIGangChallenge.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, UIGangChallenge.OnLeaveFight)
  self._selectChallengeIdx = 0
  self._tblChallengeInfos = nil
  self._ctrlItemList = nil
  self._uiGOs = nil
  if self._cfgData ~= nil then
    self._cfgData:Release()
    self._cfgData = nil
  end
end
def.method().InitUI = function(self)
  self._uiGOs = self._uiGOs or {}
  local ctrlChallengeListRoot = self.m_panel:FindDirect("Img_Bg/Group_Content/Scroll View/List")
  local lblDetail1 = self.m_panel:FindDirect("Img_Bg/Label01")
  local lblDetail2 = self.m_panel:FindDirect("Img_Bg/Label02")
  self._uiGOs.ctrlChallengeListRoot = ctrlChallengeListRoot
  self._uiGOs.lblDetail1 = lblDetail1
  self._uiGOs.lblDetail2 = lblDetail2
  GUIUtils.SetActive(lblDetail1, true)
  GUIUtils.SetText(lblDetail1, textRes.Soaring.GangChallenge[4])
end
def.override("boolean").OnShow = function(self, s)
  if s and _G.PlayerIsInFight() then
    self:Show(false)
  end
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  if self._cfgData == nil or self._cfgData:IsNil() then
    local TaskGangChallenge = require("Main.Soaring.proxy.TaskGangChallenge")
    local taskGangChallenge = TaskGangChallenge.Instance()
    taskGangChallenge:_loadData()
    self._cfgData = taskGangChallenge._cfgData
  end
  self:CreatePanel(RESPATH.PREFAB_UI_GANGCHANLLENGE, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:HidePanel()
    return
  elseif id == "Btn_Fight" then
    self:OnBtnChallengeClick()
  elseif string.find(id, "Img_BgMissions_%d") ~= nil then
    local idx = tonumber(string.sub(id, string.find(id, "%d")))
    self:OnSelectChallenge(idx)
  end
end
def.method().OnBtnChallengeClick = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() and not teamData:MeIsCaptain() then
    warn(">>>>You must be captain can to challenge<<<<")
    return
  end
  if self:GetSelectedChallengeIdx() == 0 then
    Toast(textRes.Soaring.GangChallenge[2])
    return
  end
  local challengeInfo = self:GetSelectChallengeInfo()
  local actId = self:GetActivityId()
  warn("actid = " .. actId .. " sort_id = " .. challengeInfo.sort_id)
  local bIsSectCompleted = self:IsSectionCompleted(challengeInfo.sort_id)
  if bIsSectCompleted then
    Toast(textRes.Soaring.GangChallenge[1])
    return
  end
  UIGangChallenge.SendAttenFightActivityReq(actId, challengeInfo.sort_id)
end
def.method("number").OnSelectChallenge = function(self, idx)
  if self:GetSelectedChallengeIdx() == idx then
    return
  end
  self:SetSelectChallengeIdx(idx)
end
def.method().InitUIChangeList = function(self)
  self._tblChallengeInfos = self._cfgData:GetChallengeInfos()
  local countChallenge = self._cfgData:CountFightInfos()
  self._ctrlItemList = GUIUtils.InitUIList(self._uiGOs.ctrlChallengeListRoot, countChallenge)
  self:UpdateUIChallengeList()
end
def.method().UpdateUIChallengeList = function(self)
  local count = self:CountChallengeInfos()
  local countComplete = 0
  for i = 1, count do
    local itemGO = self._ctrlItemList[i]
    local challengCfgInfo = self:GetChallengInfoByIdx(i)
    local imgGang = itemGO:FindDirect(("Model_%d"):format(i))
    if challengCfgInfo ~= nil then
      GUIUtils.SetTexture(imgGang, challengCfgInfo.image_id)
    end
    local imgPass = itemGO:FindDirect(("Img_Pass_%d"):format(i))
    local bSectComplete = self:IsSectionCompleted(challengCfgInfo.sort_id)
    imgPass:SetActive(bSectComplete)
    if bSectComplete then
      GUIUtils.SetTextureEffect(imgGang:GetComponent("UITexture"), GUIUtils.Effect.Gray)
      countComplete = countComplete + 1
    end
  end
  if count == countComplete then
    self:HidePanel()
  end
end
def.static("table", "table").OnEnterFight = function(p, context)
  local self = UIGangChallenge.Instance()
  self:HidePanel()
end
def.static("table", "table").OnLeaveFight = function(p, context)
end
def.method("number", "=>", "boolean").IsSectionCompleted = function(self, sortId)
  local completeSects = UIGangChallenge.GetCompleteSectionSortIds()
  if completeSects == nil then
    return false
  end
  for i = 1, #completeSects do
    local sort_id = completeSects[i]
    if sort_id == sortId then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").IsTaskCompleted = function(self)
  local completeSects = UIGangChallenge.GetCompleteSectionSortIds()
  return self._cfgData:CountRecords() == #completeSects
end
def.method("number").SetSelectChallengeIdx = function(self, idx)
  self._selectChallengeIdx = idx
end
def.method("=>", "table").GetSelectChallengeInfo = function(self)
  return self:GetChallengInfoByIdx(self._selectChallengeIdx)
end
def.method("=>", "number").GetSelectedChallengeIdx = function(self)
  return self._selectChallengeIdx
end
def.method("number", "=>", "table").GetChallengInfoByIdx = function(self, idx)
  return self._tblChallengeInfos[idx]
end
def.method("=>", "number").CountChallengeInfos = function(self)
  return #self._tblChallengeInfos
end
def.method("=>", "number").GetActivityId = function(self)
  return self._cfgData:GetActivityId()
end
def.static("=>", "table").GetCompleteSectionSortIds = function(self)
  return G_arrCompleteSections
end
def.static("number", "number").SendAttenFightActivityReq = function(actId, sortId)
  warn(">>>>Send AttenFightActivityReq <<<<")
  local p = require("netio.protocol.mzm.gsp.feisheng.CAttendFightActivityReq").new(actId, sortId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAttendFightActivityFail = function(p)
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>CHECK_NPC_SERVICE_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == 2 then
    warn(">>>>ALREADY_FIGHT<<<<")
  elseif p.res == 3 then
    warn(">>>>AWARD_FAIL<<<<")
  elseif p.res == 4 then
    warn(">>>>TEAM_STATE_CHANGED<<<<")
  elseif p.res == 5 then
    warn(">>>>ROLE_ID_NOT_TEAM_LEADER<<<<")
  end
end
def.static("table").OnSSynFightActivitySchedule = function(p)
  G_activityId = p.activity_cfg_id
  G_iGotTeamMemberAwardTimes = p.daily_get_team_member_award_times
  G_arrCompleteSections = {}
  for _, v in pairs(p.complete_sortids) do
    table.insert(G_arrCompleteSections, v)
  end
  local self = UIGangChallenge.Instance()
  if self:IsShow() then
    self:UpdateUIChallengeList()
  end
  local cfgTeamMemberMaxtimes = 0
  if self._cfgData == nil or self._cfgData:IsNil() then
    local taskGangChallenge = require("Main.Soaring.proxy.TaskGangChallenge").Instance()
    taskGangChallenge:_loadData()
    cfgTeamMemberMaxtimes = taskGangChallenge._cfgData:GetTeamMemberAwardMaxTimes()
    taskGangChallenge:Release()
  else
    cfgTeamMemberMaxtimes = self._cfgData:GetTeamMemberAwardMaxTimes()
  end
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() and teamData:MeIsCaptain() then
    return
  end
  if G_iGotTeamMemberAwardTimes - 1 == -1 then
    return
  end
  if cfgTeamMemberMaxtimes <= G_iGotTeamMemberAwardTimes then
    Toast(textRes.Soaring.GangChallenge[5]:format(G_iGotTeamMemberAwardTimes))
  end
end
def.static().OnResetFightActivitySchedule = function()
  G_arrCompleteSections = {}
  G_iGotTeamMemberAwardTimes = -1
end
def.static().OnCrossDay = function()
  G_iGotTeamMemberAwardTimes = 0
end
return UIGangChallenge.Commit()
