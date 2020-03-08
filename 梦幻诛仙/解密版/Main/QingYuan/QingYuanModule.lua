local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local QingYuanModule = Lplus.Extend(ModuleBase, "QingYuanModule")
local QingYuanMgr = require("Main.QingYuan.QingYuanMgr")
local QingYuanConst = require("netio.protocol.mzm.gsp.qingyuan.QingYuanConst")
local NPCInterface = require("Main.npc.NPCInterface")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local def = QingYuanModule.define
local instance
def.field("userdata").QingYuanSession = nil
def.static("=>", QingYuanModule).Instance = function()
  if instance == nil then
    instance = QingYuanModule()
    instance.m_moduleId = ModuleId.QINGYUAN
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyuan.SSyncQingYuanInfo", QingYuanModule.OnSyncQingYuanInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyuan.SGetQingYuanInfo", QingYuanModule.OnReceiveQingYuanInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyuan.SRelieveQingYuanSuccess", QingYuanModule.OnRelieveQingYuanSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyuan.SMakeQingYuanRelationSuccess", QingYuanModule.OnMakeQingYuanRelationSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyuan.SCancelQingYuanSuccess", QingYuanModule.OnCancelQingYuanSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyuan.SAgreeOrRefuseQingYuan", QingYuanModule.OnAgreeOrRefuseQingYuan)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyuan.SQingYuanRelationPromotion", QingYuanModule.OnQingYuanRelationPromotion)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyuan.SQingYuanNormalFail", QingYuanModule.OnQingYuanNormalFail)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, QingYuanModule.OnQingYuanService)
  local npcInterface = NPCInterface.Instance()
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.MakeQingYuan, QingYuanModule.OnQingYuanNPCService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.QingYuanYouYuanFang, QingYuanModule.OnQingYuanNPCService)
  ModuleBase.Init(self)
end
def.static("table").OnSyncQingYuanInfo = function(p)
  QingYuanMgr.Instance():SetQingYuanRoleIdList(p.qing_yuan_role_list)
end
def.static("table").OnReceiveQingYuanInfo = function(p)
  QingYuanMgr.Instance():SetQingYuanRoleList(p.qing_yuan_role_list_info)
  Event.DispatchEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.RECEIVE_QINGYUAN_INFO, nil)
end
def.static("table").OnRelieveQingYuanSuccess = function(p)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local qingYuanRoleId
  if heroProp.id == p.active_role_id then
    qingYuanRoleId = p.passive_role_id
  else
    qingYuanRoleId = p.active_role_id
  end
  local friendData = require("Main.friend.FriendData").Instance()
  local friendInfo = friendData:GetFriendInfo(qingYuanRoleId)
  if friendInfo ~= nil then
    Toast(string.format(textRes.QingYuan[2], friendInfo.roleName, constant.QingYuanConsts.friendValueAfterRelieve))
  end
  QingYuanMgr.Instance():DeleteQingYuanRoleInfo(qingYuanRoleId)
  Event.DispatchEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.QINGYUAN_INFO_CHANGE, nil)
end
def.static("table").OnMakeQingYuanRelationSuccess = function(p)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  QingYuanMgr.Instance():SetQingYuanSession(p.sessionid)
  QingYuanModule.OpenQingYuanConfirmPanel(p.team_leader_role_id, p.team_member_role_id)
end
def.static("table").OnCancelQingYuanSuccess = function(p)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local str
  if p.team_leader_role_id == heroProp.id then
    str = string.format(textRes.QingYuan[17], textRes.QingYuan[18])
  else
    str = string.format(textRes.QingYuan[17], p.team_leader_role_name)
  end
  Toast(str)
  Event.DispatchEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.CANCEL_QINGYUAN, nil)
end
def.static("table").OnAgreeOrRefuseQingYuan = function(p)
  if not QingYuanMgr.Instance():IsQingYuanFunctionOpen() then
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local friendData = require("Main.friend.FriendData").Instance()
  if p.operator == QingYuanConst.NOT_MAKE_QING_YUAN then
    local friendInfo
    if p.team_leader_role_id == heroProp.id then
      friendInfo = friendData:GetFriendInfo(p.team_member_role_id)
      if friendInfo ~= nil then
        Toast(string.format(textRes.QingYuan[19], friendInfo.roleName))
      end
    end
    Event.DispatchEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.REFUSE_QINGYUAN, nil)
  else
    local friendInfo
    if p.team_leader_role_id == heroProp.id then
      friendInfo = friendData:GetFriendInfo(p.team_member_role_id)
      QingYuanMgr.Instance():AddQingYuanRoleId(p.team_member_role_id)
    else
      friendInfo = friendData:GetFriendInfo(p.team_leader_role_id)
      QingYuanMgr.Instance():AddQingYuanRoleId(p.team_leader_role_id)
    end
    if friendInfo ~= nil then
      Toast(string.format(textRes.QingYuan[20], friendInfo.roleName))
    end
    Event.DispatchEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.ON_AGREE_QINGYUAN, nil)
    Event.DispatchEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.AGREE_QINGYUAN, nil)
    Event.DispatchEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.QINGYUAN_INFO_CHANGE, nil)
  end
end
def.static("table").OnQingYuanRelationPromotion = function(p)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local friendData = require("Main.friend.FriendData").Instance()
  local roleInfo
  if p.role_id_a == heroProp.id then
    roleInfo = friendData:GetFriendInfo(p.role_id_b)
    QingYuanMgr.Instance():DeleteQingYuanRoleInfo(p.role_id_b)
  else
    roleInfo = friendData:GetFriendInfo(p.role_id_a)
    QingYuanMgr.Instance():DeleteQingYuanRoleInfo(p.role_id_a)
  end
  if roleInfo ~= nil then
    Toast(string.format(textRes.QingYuan[21], roleInfo.roleName))
  end
  Event.DispatchEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.QINGYUAN_INFO_CHANGE, nil)
end
def.static("table").OnQingYuanNormalFail = function(p)
  local SQingYuanNormalFail = require("netio.protocol.mzm.gsp.qingyuan.SQingYuanNormalFail")
  if p.result == SQingYuanNormalFail.MEMBER_QING_YUAN_SIZE_MAX then
    Toast(string.format(textRes.QingYuan.SQingYuanNormalFail[1], p.params[1]))
  elseif p.result == SQingYuanNormalFail.NOT_HAS_THE_QING_YUAN then
    Toast(string.format(textRes.QingYuan.SQingYuanNormalFail[2], p.params[1]))
  elseif p.result == SQingYuanNormalFail.ROLE_LEVEL_NOT_MATCH then
    Toast(string.format(textRes.QingYuan.SQingYuanNormalFail[4], p.params[1]))
  elseif p.result == SQingYuanNormalFail.FRIEND_VALUE_NOT_MATCH then
    Toast(string.format(textRes.QingYuan.SQingYuanNormalFail[5], p.params[1]))
  elseif textRes.QingYuan.SQingYuanNormalFail[p.result] ~= nil then
    Toast(textRes.QingYuan.SQingYuanNormalFail[p.result])
  end
end
def.static("table", "table").OnQingYuanService = function(p1, p2)
  local npcId = p1[2]
  local serviceId = p1[1]
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  if constant.QingYuanConsts.qingYuanNpcId == npcId and NPCServiceConst.MakeQingYuan == serviceId then
    QingYuanMgr.Instance():MakeQingYuan()
  end
end
def.static().OpenQingYuanInfoPanel = function()
  require("Main.QingYuan.ui.QingYuanInfoPanel").Instance():ShowPanel()
end
def.static("userdata", "userdata").OpenQingYuanConfirmPanel = function(activeRoleId, passiveRoleId)
  require("Main.QingYuan.ui.QingYuanConfirmPanel").Instance():ShowPanel(activeRoleId, passiveRoleId)
end
def.static().GotoQingYuanNPC = function()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.QingYuanConsts.qingYuanNpcId
  })
end
def.static("number", "=>", "boolean").OnQingYuanNPCService = function(serviceId)
  return QingYuanMgr.Instance():IsQingYuanFunctionOpen()
end
QingYuanModule.Commit()
return QingYuanModule
