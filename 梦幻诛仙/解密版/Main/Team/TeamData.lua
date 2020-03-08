local Lplus = require("Lplus")
local TeamData = Lplus.Class("TeamData")
local TeamUtils = require("Main.Team.TeamUtils")
local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
require("Main.module.ModuleId")
local def = TeamData.define
local instance
local MAX_MEMBER_COUNT = 5
def.field("table").members = nil
def.field("table").invitations = nil
def.field("table").applicants = nil
def.field("table").rolesInView = nil
def.field("table").disposition = nil
def.field("userdata").teamId = nil
def.field("number").formationId = 0
def.field("number").formationLevel = 0
def.field("boolean").roleFighted = false
def.field("boolean").roleMoved = false
def.field("boolean").playerTouched = false
def.field("boolean").hasNewApplicant = false
def.field("number").inviteTime = 0
def.field("table").protectMembers = nil
def.field("table").blockStrangers = nil
def.field("table").teamMountData = nil
def.static("=>", TeamData).Instance = function()
  if instance == nil then
    instance = TeamData()
  end
  return instance
end
def.method().Init = function(self)
  self.members = {}
  self.invitations = {}
  self.applicants = {}
  self.rolesInView = {}
  self.disposition = {}
  self.protectMembers = {}
  self.teamId = nil
  self.formationId = 0
  self.formationLevel = 0
  self.blockStrangers = {}
  Timer:RegisterListener(self.UpdateInviteSession, self)
end
def.method().Reset = function(self)
  self.members = {}
  self.invitations = {}
  self.applicants = {}
  self.rolesInView = {}
  self.disposition = {}
  self.teamId = nil
  self.formationId = 0
  self.formationLevel = 0
  self.blockStrangers = {}
  self.teamMountData = nil
end
def.method("=>", "boolean").HasTeam = function(self)
  return #self:GetAllTeamMembers() > 0
end
def.method("=>", "boolean").IsTeamMembersFully = function(self)
  local teamMemberCount = #self:GetAllTeamMembers()
  local teamCapacity = TeamUtils.GetTeamConsts("TEAM_CAPACITY")
  return teamMemberCount >= teamCapacity
end
def.method("=>", "boolean").MeIsCaptain = function(self)
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  return self:IsCaptain(roleId)
end
def.method("=>", "number").GetMemberCount = function(self)
  return #self:GetAllTeamMembers()
end
def.method("=>", "boolean").isFighting = function(self)
  return self.roleFighted
end
def.method("userdata", "=>", "number").GetMemberIndex = function(self, roleid)
  for k, v in pairs(self.members) do
    if v.roleid == roleid then
      return k
    end
  end
  return 0
end
def.method("userdata", "=>", "table").getMember = function(self, roleid)
  for k, v in pairs(self.members) do
    if v.roleid == roleid then
      return v
    end
  end
  return nil
end
def.method("table").setTeamPosition = function(self, positions)
  self.disposition = positions
  local TeamDispositionMemberInfo = require("netio.protocol.mzm.gsp.team.TeamDispositionMemberInfo")
  for k = 1, #positions do
    if positions[k] and positions[k].dispositionMemberType == TeamDispositionMemberInfo.DT_TEAM_MEMBER then
      for i = 1, #self.members do
        if positions[k].teamDispositionMember_id:eq(self.members[i].roleid) then
          self.members[i].sortIdx = k
          break
        end
      end
    end
  end
  table.sort(self.members, function(a, b)
    if a.sortIdx == nil then
      return false
    else
      return b.sortIdx == nil or a.sortIdx < b.sortIdx
    end
  end)
  for i = 1, #self.members do
    self.members[i].sortIdx = nil
  end
end
def.method("=>", "table").getTeamPosition = function(self)
  return self.disposition
end
def.method("table").AddTeamMember = function(self, member)
  if #self.members >= MAX_MEMBER_COUNT then
    return
  end
  for k, v in pairs(self.members) do
    if v.roleid:eq(member.roleid) then
      self.members[k] = member
      return
    end
  end
  table.insert(self.members, member)
end
def.method("userdata").addProtectMember = function(self, memberid)
  table.insert(self.protectMembers, memberid)
end
def.method("userdata").removeProtectMember = function(self, memberid)
  for k, v in pairs(self.protectMembers) do
    if v:eq(memberid) then
      table.remove(self.protectMembers, k)
    end
  end
end
def.method("userdata", "=>", "boolean").isProtctedMember = function(self, memberid)
  warn(#self.protectMembers)
  for k, v in pairs(self.protectMembers) do
    if v:eq(memberid) then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").hasProtectedMember = function(self)
  if self.protectMembers ~= nil and #self.protectMembers > 0 then
    if #self.protectMembers == 1 and self.protectMembers[1]:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) then
      return false
    end
    for k, v in pairs(self.protectMembers) do
      if v:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) == false then
        for l, member in pairs(self.members) do
          if member.roleid:eq(v) == true and member.status == TeamMember.ST_NORMAL then
            return true
          end
        end
      end
    end
  end
  return false
end
def.method().clearAllProtectMember = function(self)
  self.protectMembers = {}
end
def.method("=>", "boolean").HasLeavingMember = function(self)
  if self:HasTeam() == false then
    return false
  end
  for k, v in pairs(self.members) do
    if v.status == TeamMember.ST_TMP_LEAVE then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").HasOfflineMember = function(self)
  if self:HasTeam() == false then
    return false
  end
  for k, v in pairs(self.members) do
    if v.status == TeamMember.ST_OFFLINE then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").MeIsAFK = function(self)
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  return self:IsAFK(roleId)
end
def.method("userdata", "=>", "boolean").IsAFK = function(self, memberId)
  if self:HasTeam() == false then
    return false
  end
  for k, v in pairs(self.members) do
    if v.roleid:eq(memberId) and v.status == TeamMember.ST_TMP_LEAVE then
      return true
    end
  end
  return false
end
def.method("=>", "table").GetNormalMembers = function(self)
  if self:HasTeam() == false then
    return {}
  end
  local members = {}
  for k, v in pairs(self.members) do
    if v.status == TeamMember.ST_NORMAL then
      members[#members + 1] = v
    end
  end
  return members
end
def.method("userdata", "=>", "table").GetTeamMember = function(self, memberId)
  if memberId == nil then
    return nil
  end
  for k, v in pairs(self.members) do
    if v.roleid:eq(memberId) then
      return v
    end
  end
  return nil
end
def.method("userdata").RemoveTeamMember = function(self, roleId)
  for k, v in pairs(self.members) do
    if v.roleid:eq(roleId) then
      table.remove(self.members, k)
      return
    end
  end
end
def.method("=>", "table").GetAllTeamMembers = function(self)
  return self.members
end
def.method("userdata", "number").SetMemberStatus = function(self, roleId, status)
  for k, v in pairs(self.members) do
    if v.roleid:eq(roleId) then
      v.status = status
      break
    end
  end
end
def.method("userdata", "number").SetMemberLevel = function(self, roleId, level)
  for k, v in pairs(self.members) do
    if v.roleid:eq(roleId) then
      v.level = level
      break
    end
  end
end
def.method().ClearTeam = function(self)
  self.members = {}
  self.formationId = 0
  self.applicants = {}
  self.rolesInView = {}
  self.disposition = {}
  self.teamId = nil
  self.teamMountData = nil
end
def.method("userdata").SetLeader = function(self, roleId)
  for i = 1, #self.members do
    if self.members[i] ~= nil and roleId:eq(self.members[i].roleid) then
      local temp = self.members[1]
      self.members[1] = self.members[i]
      self.members[i] = temp
    end
  end
end
def.method("userdata", "=>", "boolean").IsCaptain = function(self, roleId)
  if self.members == nil or #self.members == 0 then
    return false
  end
  return roleId:eq(self.members[1].roleid)
end
def.method("userdata", "=>", "boolean").IsTeamMember = function(self, roleId)
  for k, v in pairs(self.members) do
    if v.roleid:eq(roleId) then
      return true
    end
  end
  return false
end
def.method("=>", "number").GetStatus = function(self)
  local status = -1
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  for k, v in pairs(self.members) do
    if v.roleid:eq(myId) then
      status = v.status
    end
  end
  return status
end
def.method("userdata", "=>", "number").GetMemberStatus = function(self, roleId)
  local status = -1
  for k, v in pairs(self.members) do
    if v.roleid:eq(roleId) then
      status = v.status
    end
  end
  return status
end
def.method("table").SetTeamInvitation = function(self, invitation)
  if self.inviteTime == 0 then
    local record = DynamicData.GetRecord(CFG_PATH.TEAM_CONSTS, "INVITE_SECONDS")
    self.inviteTime = DynamicRecord.GetIntValue(record, "value")
  end
  invitation.time = self.inviteTime
  table.insert(self.invitations, invitation)
end
def.method("=>", "table").GetTeamInvitation = function(self)
  return self.invitations
end
def.method().ClearTeamInvitation = function(self)
  self.invitations = {}
end
def.method("userdata").removeInviter = function(self, roleid)
  local count = #self.invitations
  for idx = 1, count do
    if self.invitations[idx].inviter == roleid then
      table.remove(self.invitations, idx)
      return
    end
  end
end
def.method("table").AddApplicant = function(self, p)
  if p == nil then
    return
  end
  local duration = DynamicRecord.GetIntValue(record, "value")
  table.insert(self.applicants, {
    roleId = p.applicant_id,
    roleName = p.applicant_name,
    level = p.applicant_level,
    menpai = p.applicant_menpai,
    recommender = p.recommender,
    gender = p.applicant_gender,
    time = duration,
    avatarId = p.avatarId,
    avatarFrameId = p.avatarFrameid
  })
  self.hasNewApplicant = true
end
def.method("=>", "table").GetAllApplicants = function(self)
  return self.applicants
end
def.method("number").RemoveApplicant = function(self, idx)
  table.remove(self.applicants, idx)
end
def.method().ClearApplicants = function(self)
  self.applicants = {}
end
def.method("table").SortTeamMembers = function(self, memberids)
  local i = 1
  local newmembers = {}
  for i = 1, #memberids do
    local member = self:GetTeamMember(memberids[i])
    newmembers[i] = member
  end
  self.members = newmembers
end
def.method("number").UpdateInviteSession = function(self, tk)
  local delete = {}
  if self.invitations == nil then
    return
  end
  for k, v in pairs(self.invitations) do
    if v ~= nil and v.time ~= nil and v.time > 0 then
      v.time = v.time - tk
      if v.time == 0 then
        table.insert(delete, k)
      end
    end
  end
  local i = 0
  if #delete > 0 then
    for i = 1, #delete do
      table.remove(self.invitations, delete[i])
    end
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INVITATION, nil)
  end
  local applicants = {}
  for k, v in pairs(self.applicants) do
    if v.time ~= nil and v.time > 0 then
      v.time = v.time - tk
      if v.time == 0 then
        table.insert(applicants, k)
      end
    end
  end
  if #delete > 0 then
    for i = 1, #delete do
      table.remove(self.applicants, applicants[i])
    end
    warn("UpdateInviteSession")
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, nil)
  end
end
def.method("string").AddBlockStranger = function(self, strangerName)
  if nil == self.blockStrangers then
    self.blockStrangers = {}
  end
  if strangerName then
    self.blockStrangers[strangerName] = true
  end
end
def.method("string", "=>", "boolean").IsStrangerBlocked = function(self, strangerName)
  return self.blockStrangers and self.blockStrangers[strangerName] or false
end
def.method("number", "table").SetTeamMount = function(self, mountId, rider_ids)
  if self.teamMountData == nil then
    self.teamMountData = {}
  end
  self.teamMountData.mountId = mountId
  self.teamMountData.rider_ids = rider_ids
end
def.method("=>", "boolean").IsOnTeamMount = function(self)
  if self.teamMountData == nil or self.teamMountData.rider_ids == nil then
    return false
  end
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  for k, v in pairs(self.teamMountData.rider_ids) do
    if v:eq(myId) then
      return true
    end
  end
  return false
end
TeamData.Commit()
return TeamData
