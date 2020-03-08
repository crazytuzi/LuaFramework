local Lplus = require("Lplus")
local QingYuanMgr = Lplus.Class("QingYuanMgr")
local QingYuanData = require("Main.QingYuan.QingYuanData")
local QingYuanConst = require("netio.protocol.mzm.gsp.qingyuan.QingYuanConst")
local def = QingYuanMgr.define
local instance
def.field("userdata").QingYuanSession = nil
def.static("=>", QingYuanMgr).Instance = function()
  if instance == nil then
    instance = QingYuanMgr()
  end
  return instance
end
def.method("table").SetQingYuanRoleIdList = function(self, roles)
  QingYuanData.Instance():SetCurrentQingYuanRoleIdList(roles)
end
def.method("userdata").AddQingYuanRoleId = function(self, roleId)
  QingYuanData.Instance():AddQingYuanRoleId(roleId)
end
def.method("userdata").RemoveQingYuanRoleId = function(self, delRoleId)
  QingYuanData.Instance():RemoveQingYuanRoleId(delRoleId)
end
def.method("=>", "table").GetCurrentQingYuanRoleIdList = function(self)
  return QingYuanData.Instance():GetCurrentQingYuanRoleIdList()
end
def.method("userdata", "=>", "boolean").IsQingYuanRelationWithRole = function(self, roleId)
  return QingYuanData.Instance():HasQingYuanRole(roleId)
end
def.method("table").SetQingYuanRoleList = function(self, roles)
  QingYuanData.Instance():SetCurrentQingYuanRoleList(roles)
end
def.method("=>", "table").GetQingYuanRoleList = function(self)
  local data = QingYuanData.Instance():GetCurrentQingYuanRoleList()
  local sortedData = {}
  local onlineRole = {}
  local offlineRole = {}
  for idx, roleInfo in ipairs(data) do
    if Int64.lt(roleInfo.offline_time, 0) then
      table.insert(onlineRole, roleInfo)
    else
      table.insert(offlineRole, roleInfo)
    end
  end
  for idx, roleInfo in ipairs(onlineRole) do
    table.insert(sortedData, roleInfo)
  end
  for idx, roleInfo in ipairs(offlineRole) do
    table.insert(sortedData, roleInfo)
  end
  return sortedData
end
def.method("userdata").DeleteQingYuanRoleInfo = function(self, roleId)
  QingYuanData.Instance():DeleteQingYuanRoleInfo(roleId)
end
def.method().GetQingYuanInfo = function(self)
  local req = require("netio.protocol.mzm.gsp.qingyuan.CGetQingYuanInfo").new()
  gmodule.network.sendProtocol(req)
end
def.method("number").DeleteQingYuanByIdx = function(self, idx)
  local data = self:GetQingYuanRoleList()
  if data[idx] ~= nil then
    local req = require("netio.protocol.mzm.gsp.qingyuan.CRelieveQingYuanRelation").new(data[idx].role_id)
    gmodule.network.sendProtocol(req)
  end
end
def.method("number", "function").GetQingYuanRoleInfoByIdx = function(self, idx, callback)
  local data = self:GetQingYuanRoleList()
  if data[idx] ~= nil then
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(data[idx].role_id, callback)
  end
end
def.method().MakeQingYuan = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  if not teamData:HasTeam() or teamData:GetMemberCount() < 2 then
    Toast(textRes.QingYuan[4])
    return
  end
  if teamData:HasTeam() and teamData:GetMemberCount() > 2 then
    Toast(textRes.QingYuan[5])
    return
  end
  local members = teamData:GetAllTeamMembers()
  for idx, member in pairs(members) do
    if member.status ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
      if member.roleid == heroProp.id then
        Toast(string.format(textRes.QingYuan[6], textRes.QingYuan[10]))
      else
        Toast(string.format(textRes.QingYuan[6], member.name))
      end
      return
    end
    if member.level < constant.QingYuanConsts.minRoleLevel then
      if member.roleid == heroProp.id then
        Toast(string.format(textRes.QingYuan[7], textRes.QingYuan[10], constant.QingYuanConsts.minRoleLevel))
      else
        Toast(string.format(textRes.QingYuan[7], member.name, constant.QingYuanConsts.minRoleLevel))
      end
      return
    end
  end
  local otherData = members[2]
  local friendData = require("Main.friend.FriendData").Instance()
  local friendInfo = friendData:GetFriendInfo(otherData.roleid)
  if friendInfo == nil then
    Toast(textRes.QingYuan[8])
    return
  end
  if friendInfo.relationValue < constant.QingYuanConsts.minFriendValue then
    Toast(string.format(textRes.QingYuan[9], constant.QingYuanConsts.minFriendValue))
    return
  end
  if self:IsQingYuanRelationWithRole(otherData.roleid) then
    Toast(textRes.QingYuan[23])
    return
  end
  if QingYuanData.Instance():GetCurrentQingYuanCount() >= constant.QingYuanConsts.maxQingYuanRelationNum then
    Toast(string.format(textRes.QingYuan[11], textRes.QingYuan[10]))
    return
  end
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo ~= nil and mateInfo.mateId == otherData.roleid then
    Toast(string.format(textRes.QingYuan[12], textRes.QingYuan[10], otherData.name))
    return
  end
  local req = require("netio.protocol.mzm.gsp.qingyuan.CMakeQingYuanRelation").new()
  gmodule.network.sendProtocol(req)
end
def.method("userdata").SetQingYuanSession = function(self, sessionId)
  self.QingYuanSession = sessionId
end
def.method().CancelQingYuanReq = function(self)
  local req = require("netio.protocol.mzm.gsp.qingyuan.CCancelQingYuanReq").new(self.QingYuanSession)
  gmodule.network.sendProtocol(req)
end
def.method().RefuseQingYuanReq = function(self)
  local req = require("netio.protocol.mzm.gsp.qingyuan.CAgreeOrRefuseQingYuan").new(QingYuanConst.NOT_MAKE_QING_YUAN, self.QingYuanSession)
  gmodule.network.sendProtocol(req)
end
def.method().AgreeQingYuanReq = function(self)
  local req = require("netio.protocol.mzm.gsp.qingyuan.CAgreeOrRefuseQingYuan").new(QingYuanConst.YES_MAKE_QING_YUAN, self.QingYuanSession)
  gmodule.network.sendProtocol(req)
  Event.DispatchEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.ON_AGREE_QINGYUAN, nil)
end
def.method("=>", "boolean").IsQingYuanFunctionOpen = function(self)
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_QING_YUAN) then
    return true
  end
  return false
end
QingYuanMgr.Commit()
return QingYuanMgr
