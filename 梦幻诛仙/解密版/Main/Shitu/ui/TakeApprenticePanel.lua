local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TakeApprenticePanel = Lplus.Extend(ECPanelBase, "TakeApprenticePanel")
local ShituUtils = require("Main.Shitu.ShituUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ShiTuConst = require("netio.protocol.mzm.gsp.shitu.ShiTuConst")
local def = TakeApprenticePanel.define
local instance
def.field("table")._checkTag = nil
def.static("=>", TakeApprenticePanel).Instance = function()
  if instance == nil then
    instance = TakeApprenticePanel()
    instance._checkTag = {}
  end
  return instance
end
def.method().ShowTakeApprenticePanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SHITU_COMMON_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateTakeApprenticeConditions()
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, TakeApprenticePanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, TakeApprenticePanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_LEAVE, TakeApprenticePanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_UPGRADE_TO_CAPTION, TakeApprenticePanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, TakeApprenticePanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, TakeApprenticePanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, TakeApprenticePanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendIntimacyChanged, TakeApprenticePanel.OnFriendIntimacyChanged)
end
def.method().InitUI = function(self)
  local panelTitle = self.m_panel:FindDirect("Img_Bg/Img_Title/Label"):GetComponent("UILabel")
  panelTitle:set_text(textRes.Shitu[4])
  local takeApprenticeCondition = self.m_panel:FindDirect("Img_Bg/Label_Tiaojian"):GetComponent("UILabel")
  takeApprenticeCondition:set_text("")
  self.m_panel:FindDirect("Img_Bg/Btn_Apply"):SetActive(true)
  self.m_panel:FindDirect("Img_Bg/Btn_Chushi"):SetActive(false)
  local conditionIds = {
    constant.ShiTuConsts.teamConditionIdShouTu,
    constant.ShiTuConsts.levelConditionIdShouTu,
    constant.ShiTuConsts.apprenticeConditionIdShouTu,
    constant.ShiTuConsts.masterNumLimitConditionIdShouTu,
    constant.ShiTuConsts.punishConditionIdShouTu,
    constant.ShiTuConsts.qinMiDuConditionIdShouTu
  }
  local conditionArgs = {
    {},
    {
      constant.ShiTuConsts.apprenticeMinLevel,
      constant.ShiTuConsts.minHighLevel
    },
    {},
    {},
    {
      constant.ShiTuConsts.relievePunishTime
    },
    {
      constant.ShiTuConsts.minQinMiDu
    }
  }
  local conditionDesc = {}
  for i = 1, #conditionIds do
    local condition = ShituUtils.GetShoutuConditionById(conditionIds[i])
    if #conditionArgs[i] == 1 then
      condition = string.format(condition, conditionArgs[i][1])
    elseif #conditionArgs[i] == 2 then
      condition = string.format(condition, conditionArgs[i][1], conditionArgs[i][2])
    end
    if conditionIds[i] == constant.ShiTuConsts.levelConditionIdShouTu then
      condition = string.gsub(condition, "+0", "")
    end
    table.insert(conditionDesc, condition)
  end
  local conditionList = self.m_panel:FindDirect("Img_Bg/Img_ConditionList/Scroll View_PetList/List_PetList")
  local conditionUIList = conditionList:GetComponent("UIList")
  conditionUIList.itemCount = #conditionIds
  conditionUIList:Resize()
  for i = 1, #conditionIds do
    local item = conditionList:FindDirect(string.format("Img_BgPet01_%d", i))
    if item then
      local conditionLabel = item:FindDirect(string.format("Pet01_%d/Label_PetName01_%d", i, i)):GetComponent("UILabel")
      local imgGou = item:FindDirect(string.format("Pet01_%d/Img_Gou_%d", i, i))
      local imgCha = item:FindDirect(string.format("Pet01_%d/Img_Cha_%d", i, i))
      conditionLabel:set_text(conditionDesc[i])
      imgGou:SetActive(false)
      imgCha:SetActive(true)
      local tag = {}
      tag.tagGou = imgGou
      tag.tagCha = imgCha
      tag.status = false
      self._checkTag[conditionIds[i]] = tag
    end
  end
end
def.method().ResetLocalConditionStatus = function(self)
  local conditionIds = {
    constant.ShiTuConsts.teamConditionIdShouTu,
    constant.ShiTuConsts.levelConditionIdShouTu,
    constant.ShiTuConsts.masterNumLimitConditionIdShouTu,
    constant.ShiTuConsts.qinMiDuConditionIdShouTu
  }
  for i = 1, #conditionIds do
    self:SetConditionTagStatus(conditionIds[i], false)
  end
  local btnDisable = self.m_panel:FindDirect("Img_Bg/Btn_Apply/Img_Zhihui")
  btnDisable:SetActive(true)
end
def.method().UpdateTakeApprenticeConditions = function(self)
  self:ResetLocalConditionStatus()
  if not self:IsTeamMemberCountMeetRequirement() then
    self:CheckConditionStatus(constant.ShiTuConsts.masterNumLimitConditionIdShouTu, TakeApprenticePanel.CheckMasterNumLimit)
  else
    self:CheckLocalContionStatus()
    self:CheckServerConditionStatus()
  end
end
def.method("number", "function").CheckConditionStatus = function(self, conditionId, checkFunction)
  local checked = checkFunction()
  self:SetConditionTagStatus(conditionId, checked)
end
def.method("=>", "boolean").IsTeamMemberCountMeetRequirement = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  return teamData:HasTeam() and teamData:GetMemberCount() == 2
end
def.method().CheckLocalContionStatus = function(self)
  local checkFunction = {
    TakeApprenticePanel.CheckShituTeam,
    TakeApprenticePanel.CheckShituLevel,
    TakeApprenticePanel.CheckMasterNumLimit,
    TakeApprenticePanel.CheckShituQinmidu
  }
  local conditionIds = {
    constant.ShiTuConsts.teamConditionIdShouTu,
    constant.ShiTuConsts.levelConditionIdShouTu,
    constant.ShiTuConsts.masterNumLimitConditionIdShouTu,
    constant.ShiTuConsts.qinMiDuConditionIdShouTu
  }
  for i = 1, #conditionIds do
    local checked = checkFunction[i]()
    self:SetConditionTagStatus(conditionIds[i], checked)
  end
end
def.method("number", "boolean").SetConditionTagStatus = function(self, id, status)
  local tag = self._checkTag[id]
  tag.status = status
  if status then
    tag.tagGou:SetActive(true)
    tag.tagCha:SetActive(false)
  else
    tag.tagGou:SetActive(false)
    tag.tagCha:SetActive(true)
  end
end
def.static("=>", "boolean").CheckShituTeam = function()
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() ~= true or teamData:GetMemberCount() ~= 2 then
    return false
  end
  local members = teamData:GetAllTeamMembers()
  for roleId, member in pairs(members) do
    if member.status ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
      return false
    end
  end
  return true
end
def.static("=>", "boolean").CheckShituLevel = function()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local masterLevel = heroProp.level
  local teamData = require("Main.Team.TeamData").Instance()
  local apprenticeProp = teamData:GetAllTeamMembers()[2]
  local apprenticeLevel = apprenticeProp.level
  return apprenticeLevel >= constant.ShiTuConsts.apprenticeMinLevel and masterLevel >= apprenticeLevel + constant.ShiTuConsts.minHighLevel
end
def.static("=>", "boolean").CheckMasterNumLimit = function()
  local shituData = require("Main.Shitu.ShituData").Instance()
  return shituData:GetNowApprenticeCount() < constant.ShiTuConsts.maxApprenticeNum
end
def.static("=>", "boolean").CheckShituQinmidu = function()
  local friendData = require("Main.friend.FriendData").Instance()
  local teamData = require("Main.Team.TeamData").Instance()
  local apprenticeProp = teamData:GetAllTeamMembers()[2]
  local apprenticeRoleId = apprenticeProp.roleid
  local friendInfo = friendData:GetFriendInfo(apprenticeRoleId)
  return friendInfo ~= nil and friendInfo.relationValue >= constant.ShiTuConsts.minQinMiDu
end
def.method("=>", "userdata").GetApprenticeRoleId = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() and teamData:GetMemberCount() == 2 then
    local apprenticeProp = teamData:GetAllTeamMembers()[2]
    local apprenticeRoleId = apprenticeProp.roleid
    return apprenticeRoleId
  end
  return Int64.new(-1)
end
def.method().CheckServerConditionStatus = function(self)
  local apprenticeRoleId = self:GetApprenticeRoleId()
  if apprenticeRoleId:eq(-1) then
    return
  end
  warn(apprenticeRoleId:tostring())
  local shoutuConditionCheck = require("netio.protocol.mzm.gsp.shitu.CShouTuConditionCheck").new(apprenticeRoleId)
  gmodule.network.sendProtocol(shoutuConditionCheck)
end
def.method("table").OnReceiveServerConditionStatus = function(self, p)
  self:SetServerCheckStatus(p)
  self:CheckTotalConditionStatus()
end
def.method("table").SetServerCheckStatus = function(self, p)
  local result = p.result
  for conditionId, status in pairs(result) do
    local checked = status == ShiTuConst.SUCCESS and true or false
    self:SetConditionTagStatus(conditionId, checked)
  end
end
def.method().CheckTotalConditionStatus = function(self)
  local checkPassed = true
  for conditionId, tag in pairs(self._checkTag) do
    if tag.status == false then
      checkPassed = false
      break
    end
  end
  local btnDisable = self.m_panel:FindDirect("Img_Bg/Btn_Apply/Img_Zhihui")
  if checkPassed then
    btnDisable:SetActive(false)
  else
    btnDisable:SetActive(true)
  end
end
def.method().ApplyTakeApprentice = function(self)
  local shoutuReq = require("netio.protocol.mzm.gsp.shitu.CShouTuReq").new()
  gmodule.network.sendProtocol(shoutuReq)
end
def.static("table", "table").OnTeamMemberChanged = function(param, tbl)
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() and not teamData:MeIsCaptain() then
    instance:Close()
    return
  end
  instance:UpdateTakeApprenticeConditions()
  instance:CheckTotalConditionStatus()
end
def.static("table", "table").OnFriendIntimacyChanged = function(param, tbl)
  instance:CheckConditionStatus(constant.ShiTuConsts.qinMiDuConditionIdShouTu, TakeApprenticePanel.CheckShituQinmidu)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif id == "Btn_Cancel" then
    self:Close()
  elseif id == "Btn_Apply" then
    self:ApplyTakeApprentice()
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self._checkTag = {}
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, TakeApprenticePanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, TakeApprenticePanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_LEAVE, TakeApprenticePanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_UPGRADE_TO_CAPTION, TakeApprenticePanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, TakeApprenticePanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, TakeApprenticePanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, TakeApprenticePanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendIntimacyChanged, TakeApprenticePanel.OnFriendIntimacyChanged)
end
TakeApprenticePanel.Commit()
return TakeApprenticePanel
