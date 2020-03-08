local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local CorpsModule = Lplus.Extend(ModuleBase, "CorpsModule")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local CorpsData = require("Main.Corps.CorpsData")
local Octets = require("netio.Octets")
local def = CorpsModule.define
local instance
def.static("=>", CorpsModule).Instance = function()
  if instance == nil then
    instance = CorpsModule()
    instance.m_moduleId = ModuleId.CORPS
  end
  return instance
end
def.field(CorpsData).data = nil
def.field("table").confirmDlg = nil
def.field("table").roleCorpsRequest = nil
def.field("table").memberInfoRequest = nil
def.field("table").corpsBriefRequest = nil
def.field("table").corpsDetailRequest = nil
def.field("table").corpsOtherRequest = nil
def.field("table").corpsHistoryRequest = nil
def.field("table").roleMFVRequest = nil
def.field("table").leaderCountDown = nil
def.field("table").kickHandleChain = nil
def.field("table").quitHandleChain = nil
def.field("table").inviteHandleChain = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SSyncCorpsInfo", CorpsModule.OnSSyncCorpsInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SCreateCorpsConfirmTip", CorpsModule.OnSCreateCorpsConfirmTip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SCreateCorpsSucRep", CorpsModule.OnSCreateCorpsSucRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SCreateCorpsSucBro", CorpsModule.OnSCreateCorpsSucBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SCreateErrAlreadyHaveCorps", CorpsModule.OnSCreateErrAlreadyHaveCorps)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SActiveLeaveCorpsBro", CorpsModule.OnSActiveLeaveCorpsBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SFireCorpsMemberBro", CorpsModule.OnSFireCorpsMemberBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SInviteCorpsTrs", CorpsModule.OnSInviteCorpsTrs)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SRefuseJoinCorps", CorpsModule.OnSRefuseJoinCorps)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SNewMemberJoinCorpsBro", CorpsModule.OnSNewMemberJoinCorpsBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SAppointCaptainBro", CorpsModule.OnSAppointCaptainBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SSynMemberExtroInfo", CorpsModule.OnSSynMemberExtroInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SRenameCropsBro", CorpsModule.OnSRenameCropsBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SResetDeclarationBro", CorpsModule.OnSResetDeclarationBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SReplaceBadgeBro", CorpsModule.OnSReplaceBadgeBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SSynMemberInfo", CorpsModule.OnSSynMemberInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SSynMemberModelChange", CorpsModule.OnSSynMemberModelChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SSynMemberMFVChange", CorpsModule.OnSSynMemberMFVChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SCorpsNormalInfo", CorpsModule.OnSCorpsNormalInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SMemberLoginBro", CorpsModule.OnSMemberLoginBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SMemberLogoffBro", CorpsModule.OnSMemberLogoffBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SCorpsBriefInfoRep", CorpsModule.OnSCorpsBriefInfoRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SCreateCorpsConfirmErrBro", CorpsModule.OnSCreateCorpsConfirmErrBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SSynCreateCorpsConfirmBro", CorpsModule.OnSSynCreateCorpsConfirmBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SSyncCorpsInfo2NewMember", CorpsModule.OnSSyncCorpsInfo2NewMember)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SGetXCorpsInfoRep", CorpsModule.OnSGetXCorpsInfoRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SGetXCorpsBriefInfoRep", CorpsModule.OnSGetXCorpsBriefInfoRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SGetCorpsDetailInfoRep", CorpsModule.OnSGetCorpsDetailInfoRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.corps.SGetCorpsHistoryRep", CorpsModule.OnSGetCorpsHistoryRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleMFVRep", CorpsModule.OnSGetRoleMFVRep)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, CorpsModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, CorpsModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CorpsModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, CorpsModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, CorpsModule.OnNpcService)
  ModuleBase.Init(self)
end
def.static("table").OnSSyncCorpsInfo = function(p)
  local self = CorpsModule.Instance()
  self.data = CorpsData.Create(p.corpsInfo)
end
def.static("table").OnSCreateCorpsConfirmTip = function(p)
  local self = CorpsModule.Instance()
  if p.creatorId == GetMyRoleID() then
    require("Main.Corps.ui.CreateCorpsDlg").CloseCreate()
    Toast(textRes.Corps[14])
    self.leaderCountDown = require("GUI.TextCountDown").Start(constant.CorpsConsts.CREATE_CONFIRM_INTERVAL, textRes.Corps[76])
  else
    local CommonConfirm = require("GUI.CommonConfirmDlg")
    local str = string.format(textRes.Corps[19], GetStringFromOcts(p.name))
    self.confirmDlg = CommonConfirm.ShowConfirmCoundDown(textRes.Corps[16], str, textRes.Corps[20], textRes.Corps[21], 0, constant.CorpsConsts.CREATE_CONFIRM_INTERVAL, function(selection, tag)
      self.confirmDlg = nil
      local CCreateCorpsConfirmRep = require("netio.protocol.mzm.gsp.corps.CCreateCorpsConfirmRep")
      if selection == 1 then
        gmodule.network.sendProtocol(CCreateCorpsConfirmRep.new(p.sessionid, CCreateCorpsConfirmRep.REPLY_ACCEPT))
      elseif selection == 0 then
        gmodule.network.sendProtocol(CCreateCorpsConfirmRep.new(p.sessionid, CCreateCorpsConfirmRep.REPLY_REFUSE))
      end
    end, nil)
  end
end
def.static("table").OnSSynCreateCorpsConfirmBro = function(p)
  local self = CorpsModule.Instance()
  local CCreateCorpsConfirmRep = require("netio.protocol.mzm.gsp.corps.CCreateCorpsConfirmRep")
  if p.reply == CCreateCorpsConfirmRep.REPLY_REFUSE then
    local teamData = require("Main.Team.TeamData")
    local playerName = textRes.Corps[23]
    local memberInfo = teamData.Instance():GetTeamMember(p.memberId)
    playerName = memberInfo.name
    Toast(string.format(textRes.Corps[22], playerName))
    if self.confirmDlg then
      self.confirmDlg:DestroyPanel()
      self.confirmDlg = nil
    end
    if self.leaderCountDown then
      self.leaderCountDown:HideDlg()
      self.leaderCountDown = nil
    end
  end
end
def.static("table").OnSCreateCorpsConfirmErrBro = function(p)
  local self = CorpsModule.Instance()
  Toast(textRes.Corps[18])
  if self.confirmDlg then
    self.confirmDlg:DestroyPanel()
    self.confirmDlg = nil
  end
  if self.leaderCountDown then
    self.leaderCountDown:HideDlg()
    self.leaderCountDown = nil
  end
end
def.static("table").OnSCreateCorpsSucRep = function(p)
  local self = CorpsModule.Instance()
  self.data = CorpsData.Create(p.corpsInfo)
  Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsChange, nil)
  Toast(string.format(textRes.Corps[15], self.data:GetName()))
  if self.leaderCountDown then
    self.leaderCountDown:HideDlg()
    self.leaderCountDown = nil
  end
end
def.static("table").OnSCreateCorpsSucBro = function(p)
  local self = CorpsModule.Instance()
  local leaderName = GetStringFromOcts(p.captainName)
  local corpsName = GetStringFromOcts(p.corpsName)
  local AnnouncementTip = require("GUI.AnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local str = string.format(textRes.Corps[25], leaderName, corpsName)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  AnnouncementTip.Announce(str)
end
def.static("table").OnSCreateErrAlreadyHaveCorps = function(p)
  local self = CorpsModule.Instance()
  local names = {}
  for k, v in pairs(p.roleId2Name) do
    table.insert(names, GetStringFromOcts(v))
  end
  Toast(string.format(textRes.Corps[24], table.concat(names, textRes.Common.Dunhao)))
end
def.static("table").OnSActiveLeaveCorpsBro = function(p)
  local self = CorpsModule.Instance()
  local myRoleId = GetMyRoleID()
  if p.memberId == myRoleId then
    self.data = nil
    Toast(textRes.Corps[26])
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsChange, nil)
  elseif self.data then
    local memberInfo = self.data:GetMemberInfoByRoleId(p.memberId)
    if memberInfo then
      self.data:RemoveMember(p.memberId)
      Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberChange, nil)
      Toast(string.format(textRes.Corps[27], memberInfo.name))
    end
  end
end
def.static("table").OnSFireCorpsMemberBro = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    if p.memberId == GetMyRoleID() then
      self.data = nil
      Toast(textRes.Corps[43])
      Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsChange, nil)
    else
      local memberInfo = self.data:GetMemberInfoByRoleId(p.memberId)
      if memberInfo then
        self.data:RemoveMember(p.memberId)
        Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberChange, nil)
        Toast(string.format(textRes.Corps[28], memberInfo.name))
      end
    end
  end
end
def.static("table").OnSInviteCorpsTrs = function(p)
  local self = CorpsModule.Instance()
  local CommonConfirm = require("GUI.CommonConfirmDlg")
  local inviterName = GetStringFromOcts(p.name)
  local corpsName = GetStringFromOcts(p.corpsName)
  local str = string.format(textRes.Corps[30], inviterName, corpsName)
  CommonConfirm.ShowConfirmCoundDown(textRes.Corps[29], str, textRes.Corps[20], textRes.Corps[21], 0, constant.CorpsConsts.INVITE_INTERVAL, function(selection, tag)
    local CInviteCorpsRep = require("netio.protocol.mzm.gsp.corps.CInviteCorpsRep")
    if selection == 1 then
      gmodule.network.sendProtocol(CInviteCorpsRep.new(p.inviter, p.sessionid, CInviteCorpsRep.REPLY_ACCEPT))
    elseif selection == 0 then
      gmodule.network.sendProtocol(CInviteCorpsRep.new(p.inviter, p.sessionid, CInviteCorpsRep.REPLY_REFUSE))
    end
  end, nil)
end
def.static("table").OnSRefuseJoinCorps = function(p)
  local self = CorpsModule.Instance()
  Toast(string.format(textRes.Corps[31], GetStringFromOcts(p.roleName)))
end
def.static("table").OnSNewMemberJoinCorpsBro = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    self.data:AddMember(p.newMember)
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberChange, nil)
    local name = GetStringFromOcts(p.newMember.baseInfo.name)
    Toast(string.format(textRes.Corps[32], name))
  end
end
def.static("table").OnSSyncCorpsInfo2NewMember = function(p)
  local self = CorpsModule.Instance()
  self.data = CorpsData.Create(p.corpsInfo)
  Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsChange, nil)
  Toast(string.format(textRes.Corps[57], self.data:GetName()))
end
def.static("table").OnSAppointCaptainBro = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    local memberInfo = self.data:GetMemberInfoByRoleId(p.newCaptain)
    if memberInfo then
      self.data:ChangeLeader(p.newCaptain)
      Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsLeaderChange, {
        roleId = p.newCaptain
      })
      if p.newCaptain == GetMyRoleID() then
        Toast(textRes.Corps[67])
      else
        Toast(string.format(textRes.Corps[33], memberInfo.name))
      end
    end
  end
end
def.static("table").OnSSynMemberExtroInfo = function(p)
  local self = CorpsModule.Instance()
  local roleIdStr = p.member:tostring()
  if self.memberInfoRequest and self.memberInfoRequest[roleIdStr] then
    local cbs = self.memberInfoRequest[roleIdStr]
    self.memberInfoRequest[roleIdStr] = nil
    for k, v in ipairs(cbs) do
      v(p)
    end
  end
end
def.static("table").OnSRenameCropsBro = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    self.data:SetName(GetStringFromOcts(p.name))
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsInfoChange, nil)
    Toast(string.format(textRes.Corps[34], self.data:GetName()))
  end
end
def.static("table").OnSResetDeclarationBro = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    self.data:SetDeclaration(GetStringFromOcts(p.declaration))
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsInfoChange, nil)
    Toast(textRes.Corps[35])
  end
end
def.static("table").OnSReplaceBadgeBro = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    self.data:SetBadgeId(p.badgeId)
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsInfoChange, nil)
    Toast(textRes.Corps[36])
  end
end
def.static("table").OnSSynMemberInfo = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    self.data:ChangeMemberBaseInfo(p.memberInfo.roleId, p.memberInfo)
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberInfoChange, {
      roleId = p.memberInfo.roleId
    })
  end
end
def.static("table").OnSSynMemberModelChange = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    self.data:ChangeMemberModel(p.roleId, p.model)
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberModelChange, {
      roleId = p.roleId
    })
  end
end
def.static("table").OnSSynMemberMFVChange = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    self.data:ChangeMemberMFV(p.roleId, p.multiFightValue)
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberInfoChange, {
      roleId = p.roleId
    })
  end
end
def.static("table").OnSCorpsNormalInfo = function(p)
  local tip = textRes.Corps.NormalInfo[p.result]
  if tip then
    local args = {}
    for k, v in ipairs(p.args) do
      table.insert(args, GetStringFromOcts(v))
    end
    Toast(string.format(tip, unpack(args)))
  end
end
def.static("table").OnSMemberLoginBro = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    self.data:SetMemberOnlineState(p.memebrId, 0)
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberOnlineChange, {
      roleId = p.memebrId
    })
  end
end
def.static("table").OnSMemberLogoffBro = function(p)
  local self = CorpsModule.Instance()
  if self.data then
    self.data:SetMemberOnlineState(p.memebrId, GetServerTime())
    Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberOnlineChange, {
      roleId = p.memebrId
    })
  end
end
def.static("table").OnSGetRoleMFVRep = function(p)
  local roleStrs = {}
  for k, v in ipairs(p.roleIds) do
    table.insert(roleStrs, v:tostring())
  end
  local key = table.concat(roleStrs)
  local self = CorpsModule.Instance()
  if self.roleMFVRequest and self.roleMFVRequest[key] then
    local ret = {}
    for k, v in ipairs(p.roleIds) do
      ret[v:tostring()] = 0
    end
    for k, v in pairs(p.roleMFVInfo) do
      ret[k:tostring()] = v
    end
    local cbs = self.roleMFVRequest[key]
    self.roleMFVRequest[key] = nil
    for k, v in ipairs(cbs) do
      v(ret)
    end
  end
end
def.static("table").OnSCorpsBriefInfoRep = function(p)
  local roleStrs = {}
  for k, v in ipairs(p.roleIds) do
    table.insert(roleStrs, v:tostring())
  end
  local key = table.concat(roleStrs)
  local self = CorpsModule.Instance()
  if self.roleCorpsRequest and self.roleCorpsRequest[key] then
    local ret = {}
    for k, v in ipairs(p.roleIds) do
      ret[v:tostring()] = false
    end
    for k, v in pairs(p.corpsBriefInfos) do
      ret[k:tostring()] = v
    end
    local cbs = self.roleCorpsRequest[key]
    self.roleCorpsRequest[key] = nil
    for k, v in ipairs(cbs) do
      v(ret)
    end
  end
end
def.static("table").OnSGetXCorpsInfoRep = function(p)
  local self = CorpsModule.Instance()
  local corpsIdStr = p.corpsInfo.corpsBriefInfo.corpsId:tostring()
  if self.corpsDetailRequest and self.corpsDetailRequest[corpsIdStr] then
    local cbs = self.corpsDetailRequest[corpsIdStr]
    self.corpsDetailRequest[corpsIdStr] = nil
    for k, v in ipairs(cbs) do
      v(p.corpsInfo)
    end
  end
end
def.static("table").OnSGetXCorpsBriefInfoRep = function(p)
  local self = CorpsModule.Instance()
  local corpsIdStr = p.corpsBriefInfo.corpsId:tostring()
  if self.corpsBriefRequest and self.corpsBriefRequest[corpsIdStr] then
    local cbs = self.corpsBriefRequest[corpsIdStr]
    self.corpsBriefRequest[corpsIdStr] = nil
    for k, v in ipairs(cbs) do
      v(p.corpsBriefInfo)
    end
  end
end
def.static("table").OnSGetCorpsDetailInfoRep = function(p)
  local self = CorpsModule.Instance()
  local corpsIdStr = p.corpsDetailInfo.corpsBriefInfo.corpsId:tostring()
  if self.corpsOtherRequest and self.corpsOtherRequest[corpsIdStr] then
    local cbs = self.corpsOtherRequest[corpsIdStr]
    self.corpsOtherRequest[corpsIdStr] = nil
    for k, v in ipairs(cbs) do
      v(p.corpsDetailInfo)
    end
  end
end
def.static("table").OnSGetCorpsHistoryRep = function(p)
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local self = CorpsModule.Instance()
  if self.corpsHistoryRequest and self.corpsHistoryRequest[p.corpsId:tostring()] then
    local strs = {}
    local oldIndex = 0
    for k, v in ipairs(p.historyList) do
      local time = v.recordTime
      local formatStr = CorpsUtils.GetHistroyStr(v.historyType)
      local paramsTbl = {}
      for ki, vi in ipairs(v.parameters) do
        table.insert(paramsTbl, GetStringFromOcts(vi))
      end
      local timeTbl = AbsoluteTimer.GetServerTimeTable(time)
      local str = string.format(textRes.Corps[69], timeTbl.year, timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min, string.format(formatStr, unpack(paramsTbl)))
      table.insert(strs, str)
      oldIndex = v.historyId
    end
    local cb = self.corpsHistoryRequest[p.corpsId:tostring()]
    cb(p.start, oldIndex, strs)
    self.corpsHistoryRequest[p.corpsId:tostring()] = nil
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = CorpsModule.Instance()
  self.data = nil
  self.confirmDlg = nil
  self.roleCorpsRequest = nil
  self.memberInfoRequest = nil
  self.corpsBriefRequest = nil
  self.corpsDetailRequest = nil
  self.corpsOtherRequest = nil
  self.corpsHistoryRequest = nil
  self.roleMFVRequest = nil
  self.leaderCountDown = nil
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local NPCInterface = require("Main.npc.NPCInterface")
  NPCInterface.Instance():RegisterNPCServiceCustomCondition(constant.CorpsConsts.SERVICE_ID, function()
    return instance.data == nil
  end)
  NPCInterface.Instance():RegisterNPCServiceCustomCondition(constant.CorpsConsts.OPEN_CORPS_SERVICE_ID, function()
    return instance.data ~= nil
  end)
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local self = CorpsModule.Instance()
  if self:IsOpen() then
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = constant.CorpsConsts.NPC_ID,
      show = true
    })
  else
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = constant.CorpsConsts.NPC_ID,
      show = false
    })
  end
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  local featureType = p1.feature
  if featureType == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CORPS then
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = constant.CorpsConsts.NPC_ID,
      show = p1.open
    })
  end
end
def.static("table", "table").OnNpcService = function(p1, p2)
  local serviceID = p1[1]
  if serviceID == nil then
    return
  end
  local npcId = p1[2]
  if serviceID == constant.CorpsConsts.SERVICE_ID then
    local self = CorpsModule.Instance()
    self:PreCheckCreateCorps()
  elseif serviceID == constant.CorpsConsts.OPEN_CORPS_SERVICE_ID then
    local self = CorpsModule.Instance()
    self:OpenCorpsManage()
  end
end
def.method("=>", CorpsData).GetData = function(self)
  return self.data
end
def.method("=>", "table").GetMembersData = function(self)
  if self.data then
    return self.data:GetAllMemberSorted()
  else
    return nil
  end
end
def.method("userdata", "=>", "boolean").IsInMyCorps = function(self, roleId)
  if self.data then
    return self.data:GetMemberInfoByRoleId(roleId) ~= nil
  else
    return false
  end
end
def.method().PreCheckCreateCorps = function(self)
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():MeIsAFK() then
    Toast(textRes.Corps[75])
    return
  end
  local conditions = {}
  local allMember = teamData.Instance():GetAllTeamMembers()
  if teamData.Instance():GetMemberCount() >= constant.CorpsConsts.MIN_GUY_NUM then
    table.insert(conditions, {
      desc = string.format(textRes.Corps[1], constant.CorpsConsts.MIN_GUY_NUM),
      meet = true
    })
  else
    table.insert(conditions, {
      desc = string.format(textRes.Corps[1], constant.CorpsConsts.MIN_GUY_NUM),
      meet = false
    })
  end
  local memberIds = {}
  if #allMember > 0 then
    local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
    for k, v in ipairs(allMember) do
      if v.status == TeamMember.ST_NORMAL then
        table.insert(memberIds, v.roleid)
      end
    end
  else
    table.insert(memberIds, GetMyRoleID())
  end
  if #memberIds < constant.CorpsConsts.MIN_GUY_NUM then
    table.insert(conditions, {
      desc = string.format(textRes.Corps[2], constant.CorpsConsts.MIN_GUY_NUM),
      meet = false
    })
  else
    table.insert(conditions, {
      desc = string.format(textRes.Corps[2], constant.CorpsConsts.MIN_GUY_NUM),
      meet = true
    })
  end
  local meet = true
  if #allMember > 0 then
    for k, v in ipairs(memberIds) do
      local memberInfo = teamData.Instance():getMember(v)
      if memberInfo.level < constant.CorpsConsts.MIN_LEVEL then
        meet = false
        break
      end
    end
  else
    local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    if heroProp.level < constant.CorpsConsts.MIN_LEVEL then
      meet = false
    end
  end
  table.insert(conditions, {
    desc = string.format(textRes.Corps[3], constant.CorpsConsts.MIN_LEVEL),
    meet = meet
  })
  self:RequestPlayersCorpsInfo(memberIds, function(infos)
    local meet = true
    for k, v in pairs(infos) do
      if v then
        meet = false
        break
      end
    end
    table.insert(conditions, {
      desc = textRes.Corps[4],
      meet = meet
    })
    require("Main.Corps.ui.conditionShow").ShowCondition(conditions, function(yes)
      if yes then
        require("Main.Corps.ui.CreateCorpsDlg").ShowCreate()
      end
    end)
  end)
end
def.method("string", "string", "number").CreateCorps = function(self, name, declare, badgeId)
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  local teamData = require("Main.Team.TeamData")
  local allMember = teamData.Instance():GetAllTeamMembers()
  if teamData.Instance():GetMemberCount() < constant.CorpsConsts.MIN_GUY_NUM then
    Toast(string.format(textRes.Corps[70], constant.CorpsConsts.MIN_GUY_NUM, constant.CorpsConsts.MIN_GUY_NUM))
    return
  end
  local memberIds = {}
  if #allMember > 0 then
    local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
    for k, v in ipairs(allMember) do
      if v.status == TeamMember.ST_NORMAL then
        table.insert(memberIds, v.roleid)
      end
    end
  else
    table.insert(memberIds, GetMyRoleID())
  end
  if #memberIds < constant.CorpsConsts.MIN_GUY_NUM then
    Toast(string.format(textRes.Corps[71], constant.CorpsConsts.MIN_GUY_NUM, constant.CorpsConsts.MIN_GUY_NUM))
    return
  end
  local meet = true
  if #allMember > 0 then
    for k, v in ipairs(memberIds) do
      local memberInfo = teamData.Instance():getMember(v)
      if memberInfo.level < constant.CorpsConsts.MIN_LEVEL then
        meet = false
        break
      end
    end
  else
    local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    if heroProp.level < constant.CorpsConsts.MIN_LEVEL then
      meet = false
    end
  end
  if not meet then
    Toast(string.format(textRes.Corps[72], constant.CorpsConsts.MIN_LEVEL))
    return
  end
  local nameOctets = Octets.rawFromString(name)
  local declareOctets = Octets.rawFromString(declare)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CCreateCorpsReq").new(nameOctets, declareOctets, badgeId))
end
def.method().OpenCorpsManage = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  if self.data then
    self:CheckMFVChange()
    require("Main.Corps.ui.CorpsManagePanel").ShowCorpsManage()
  else
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.CorpsConsts.NPC_ID
    })
    Toast(textRes.Corps[61])
  end
end
def.method("=>", "table").GetAllCorpsBadge = function(self)
  return CorpsUtils.GetAllCorpsBadgeCfg()
end
def.method().LeaveCorps = function(self)
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.data then
    if self.data:IsLeader(GetMyRoleID()) then
      Toast(textRes.Corps[64])
      return
    end
    do
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
      local function showCaptchaConfirm(callback)
        CaptchaConfirmDlg.ShowConfirm(textRes.Corps[39], "", textRes.Corps[40], nil, callback, nil)
      end
      local text = textRes.Corps[38]
      if self.quitHandleChain then
        for k, v in ipairs(self.quitHandleChain) do
          warn("text1", text)
          text = v(text)
          warn("text2", text)
        end
      end
      CommonConfirmDlg.ShowConfirm(textRes.Corps[37], text, function(s)
        if s == 1 then
          showCaptchaConfirm(function(s2)
            if s2 == 1 then
              gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CActiveLeaveCorpsReq").new())
            end
          end)
        end
      end, nil)
    end
  end
end
def.method("userdata").FireMember = function(self, memberId)
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.data then
    if self.data:IsLeader(GetMyRoleID()) then
      if memberId == GetMyRoleID() then
        Toast(textRes.Corps[45])
        return
      end
      local member = self.data:GetMemberInfoByRoleId(memberId)
      if member then
        do
          local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
          local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
          local function showCaptchaConfirm(callback)
            CaptchaConfirmDlg.ShowConfirm(textRes.Corps[39], "", textRes.Corps[41], nil, callback, nil)
          end
          local text = string.format(textRes.Corps[42], member.name)
          if self.kickHandleChain then
            for k, v in ipairs(self.kickHandleChain) do
              text = v(text)
            end
          end
          CommonConfirmDlg.ShowConfirm(textRes.Corps[41], text, function(s)
            if s == 1 then
              showCaptchaConfirm(function(s2)
                if s2 == 1 then
                  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CFireCorpsMemberReq").new(memberId))
                end
              end)
            end
          end, nil)
        end
      end
    else
      Toast(textRes.Corps[44])
    end
  end
end
def.method("userdata", "number").InviteToCorps = function(self, roleId, lv)
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.data then
    do
      local function sendinvite()
        if self.data:GetMemberCount() >= constant.CorpsConsts.CAPACITY then
          Toast(textRes.Corps[47])
          return
        end
        if lv < constant.CorpsConsts.MIN_LEVEL then
          Toast(string.format(textRes.Corps[48], constant.CorpsConsts.CAPACITY))
          return
        end
        if self.data:GetMemberInfoByRoleId(roleId) then
          Toast(textRes.Corps[54])
          return
        end
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CInviteCorpsReq").new(roleId))
        Toast(textRes.Corps[46])
      end
      if self.inviteHandleChain then
        do
          local index, handle
          local function handleInvite(agree)
            if not agree then
              return
            end
            index, handle = next(self.inviteHandleChain, index)
            warn("next handleInvite", index, handle)
            if index and handle then
              handle(roleId, handleInvite)
            else
              sendinvite()
            end
          end
          handleInvite(true)
        end
      else
        sendinvite()
      end
    end
  end
end
def.method("userdata").ChangeCorpsLeader = function(self, memberId)
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.data then
    if self.data:IsLeader(GetMyRoleID()) then
      if memberId == GetMyRoleID() then
        Toast(textRes.Corps[49])
        return
      end
      local member = self.data:GetMemberInfoByRoleId(memberId)
      if member then
        do
          local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
          local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
          local function showCaptchaConfirm(callback)
            CaptchaConfirmDlg.ShowConfirm(textRes.Corps[39], "", textRes.Corps[50], nil, callback, nil)
          end
          CommonConfirmDlg.ShowConfirm(textRes.Corps[50], string.format(textRes.Corps[51], member.name), function(s)
            if s == 1 then
              showCaptchaConfirm(function(s2)
                if s2 == 1 then
                  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CAppointCaptainReq").new(memberId))
                end
              end)
            end
          end, nil)
        end
      end
    else
      Toast(textRes.Corps[66])
    end
  end
end
def.method("string").ChangeCorpsName = function(self, name)
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommonConfirm = require("GUI.CommonConfirmDlg")
  local str = string.format(textRes.Corps[59], constant.CorpsConsts.RENAME_CORPS_COST_GOLD_NUM, name)
  CommonConfirm.ShowConfirm(textRes.Corps[58], str, function(selection, tag)
    if selection == 1 then
      local ItemModule = require("Main.Item.ItemModule")
      local goldNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
      if goldNum < Int64.new(constant.CorpsConsts.RENAME_CORPS_COST_GOLD_NUM) then
        GoToBuyGold(true)
      else
        local nameOctets = Octets.rawFromString(name)
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CRenameCropsReq").new(nameOctets))
      end
    end
  end, nil)
end
def.method("string").ChangeCorpsDeclare = function(self, declare)
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  local declareOctets = Octets.rawFromString(declare)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CResetDeclarationReq").new(declareOctets))
end
def.method("number").ChangeCorpsBadge = function(self, badgeId)
  if not self:IsOpen() then
    Toast(textRes.Corps[63])
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommonConfirm = require("GUI.CommonConfirmDlg")
  local str = string.format(textRes.Corps[60], constant.CorpsConsts.REPLACE_BADGE_COST_GOLD_NUM)
  CommonConfirm.ShowConfirm(textRes.Corps[58], str, function(selection, tag)
    if selection == 1 then
      local ItemModule = require("Main.Item.ItemModule")
      local goldNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
      if goldNum < Int64.new(constant.CorpsConsts.REPLACE_BADGE_COST_GOLD_NUM) then
        GoToBuyGold(true)
      else
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CReplaceBadgeReq").new(badgeId))
      end
    end
  end, nil)
end
def.method("table", "function").RequestPlayersMFV = function(self, roles, cb)
  local roleStrs = {}
  for k, v in ipairs(roles) do
    table.insert(roleStrs, v:tostring())
  end
  local key = table.concat(roleStrs)
  if self.roleMFVRequest == nil then
    self.roleMFVRequest = {}
  end
  if self.roleMFVRequest[key] == nil then
    self.roleMFVRequest[key] = {}
  end
  table.insert(self.roleMFVRequest[key], cb)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.role.CGetRolesMFVReq").new(roles))
end
def.method("table", "function").RequestPlayersCorpsInfo = function(self, roles, cb)
  local roleStrs = {}
  for k, v in ipairs(roles) do
    table.insert(roleStrs, v:tostring())
  end
  local key = table.concat(roleStrs)
  if self.roleCorpsRequest == nil then
    self.roleCorpsRequest = {}
  end
  if self.roleCorpsRequest[key] == nil then
    self.roleCorpsRequest[key] = {}
  end
  table.insert(self.roleCorpsRequest[key], cb)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CGetCorpsBriefInfoReq").new(roles))
end
def.method("userdata", "function").RequestCorpsMemberInfo = function(self, roleId, cb)
  if self.memberInfoRequest == nil then
    self.memberInfoRequest = {}
  end
  if self.memberInfoRequest[roleId:tostring()] == nil then
    self.memberInfoRequest[roleId:tostring()] = {}
  end
  table.insert(self.memberInfoRequest[roleId:tostring()], cb)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CGetMemberExtroInfoReq").new(roleId))
end
def.method("userdata", "function").RequestCorpsBriefInfo = function(self, corpsId, cb)
  if self.corpsBriefRequest == nil then
    self.corpsBriefRequest = {}
  end
  if self.corpsBriefRequest[corpsId:tostring()] == nil then
    self.corpsBriefRequest[corpsId:tostring()] = {}
  end
  table.insert(self.corpsBriefRequest[corpsId:tostring()], cb)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CGetXCorpsBriefInfoReq").new(corpsId))
end
def.method("userdata", "function").RequestCorpsDetailInfo = function(self, corpsId, cb)
  if self.corpsDetailRequest == nil then
    self.corpsDetailRequest = {}
  end
  if self.corpsDetailRequest[corpsId:tostring()] == nil then
    self.corpsDetailRequest[corpsId:tostring()] = {}
  end
  table.insert(self.corpsDetailRequest[corpsId:tostring()], cb)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CGetXCorpsInfoReq").new(corpsId))
end
def.method("userdata", "function").RequestCorpsOtherInfo = function(self, corpsId, cb)
  if self.corpsOtherRequest == nil then
    self.corpsOtherRequest = {}
  end
  if self.corpsOtherRequest[corpsId:tostring()] == nil then
    self.corpsOtherRequest[corpsId:tostring()] = {}
  end
  table.insert(self.corpsOtherRequest[corpsId:tostring()], cb)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CGetCorpsDetailInfoReq").new(corpsId))
end
def.method().ShowMyCorpsHistory = function(self)
  if self.data then
    self:ShowCorpsHistroy(self.data:GetCorpsId())
  end
end
def.method("userdata").ShowCorpsHistroy = function(self, corpsId)
  local requestStep = 16
  local ctx = {corpsId = corpsId}
  require("Main.Corps.ui.StringListDlg").ShowDlg(ctx, requestStep, function(context, start, step, cb)
    if self.corpsHistoryRequest == nil then
      self.corpsHistoryRequest = {}
    end
    local corpsId = context.corpsId
    local corpsStr = corpsId:tostring()
    if self.corpsHistoryRequest[corpsStr] == nil then
      self.corpsHistoryRequest[corpsStr] = {}
    end
    self.corpsHistoryRequest[corpsStr] = cb
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.corps.CGetCorpsHistoryReq").new(corpsId, start, step))
  end)
end
def.method().CheckMFVChange = function(self)
  if self.data then
    local memberIds = self.data:GetMemberRoleIds()
    self:RequestPlayersMFV(memberIds, function(ret)
      if self.data then
        for k, v in pairs(ret) do
          local roleId = Int64.new(k)
          local info = self.data:GetMemberInfoByRoleId(roleId)
          if info and info.mfv ~= v then
            self.data:ChangeMemberMFV(roleId, v)
            Event.DispatchEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberInfoChange, {roleId = roleId})
          end
        end
      end
    end)
  end
end
def.method("function").RegisterKickHandler = function(self, func)
  if self.kickHandleChain == nil then
    self.kickHandleChain = {}
  end
  table.insert(self.kickHandleChain, func)
end
def.method("function").RegisterQuitHandler = function(self, func)
  if self.quitHandleChain == nil then
    self.quitHandleChain = {}
  end
  table.insert(self.quitHandleChain, func)
end
def.method("function").RegisterInviteHandler = function(self, func)
  if self.inviteHandleChain == nil then
    self.inviteHandleChain = {}
  end
  table.insert(self.inviteHandleChain, func)
end
def.method("=>", "boolean").IsOpen = function(self)
  local open, _ = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CORPS)
  return open
end
return CorpsModule.Commit()
