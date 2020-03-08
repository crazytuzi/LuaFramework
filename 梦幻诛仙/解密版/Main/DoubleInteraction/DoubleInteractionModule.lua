local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local DoubleInteractionModule = Lplus.Extend(ModuleBase, MODULE_NAME)
local Cls = DoubleInteractionModule
local def = Cls.define
local instance
local txtConst = textRes.DoubleInteraction
local const = constant.CInteractionConsts
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local InteractionUtils = require("Main.DoubleInteraction.DoubleInteractionUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local PubroleModule = require("Main.Pubrole.PubroleModule")
local PlayType = require("consts.mzm.gsp.interaction.confbean.PlayType")
def.const("number").DEFAULT_AIRCRAFT_ID = 0
def.field("table")._confirmDlg = nil
def.field("table")._inviteConfirmDlg = nil
def.field("table")._couples = nil
def.field("number")._interactState = 0
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
    instance._couples = {}
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interaction.SInviteInteractionSuccess", Cls.OnInviteSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interaction.SInviteInteractionFail", Cls.OnInviteFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interaction.SNotifyReceiveInteractionInvitation", Cls.OnRcvInvitation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interaction.SAcceptInteractionInvitationFail", Cls.OnRcvInvitationFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interaction.SNotifyCancelInteractionInvitation", Cls.OnCancelInteraction)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interaction.SNotifyDeclineInteractionInvitation", Cls.OnOtherRefuse)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interaction.SNotifyStartInteraction", Cls.OnStartInteraction)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interaction.SGetInteractionTargetList", Cls.OnGetRoleList)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, Cls.OnEnterFight)
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local bFeatureOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_INTERACTION)
  return bFeatureOpen
end
def.static("userdata", "userdata", "function")._prepare = function(aRoleId, pRoleId, cb)
  if aRoleId == nil or pRoleId == nil or cb == nil then
    return
  end
  local aId = aRoleId:tostring()
  local pId = pRoleId:tostring()
  local myRoleId = _G.GetHeroProp().id
  local bThirdPerson = not myRoleId:eq(aRoleId) and not myRoleId:eq(pRoleId)
  local pubRole = PubroleModule.Instance()
  local aRole = pubRole.rolesMap[aId]
  local pRole = pubRole.rolesMap[pId]
  if (aRole == nil or pRole == nil) and bThirdPerson then
    return
  end
  if aRole ~= nil then
    aRole:EndInteraction()
  end
  if pRole ~= nil then
    pRole:EndInteraction()
  end
  if aRole == nil then
    if pubRole.invisiblePlayers[aId] then
      aRole = pubRole:CreateRoleModel(pubRole.invisiblePlayers[aId])
      pubRole.visiblePlayers[aId] = aRole
    else
      return
    end
  end
  if pRole == nil then
    if pubRole.invisiblePlayers[pId] then
      pRole = pubRole:CreateRoleModel(pubRole.invisiblePlayers[pId])
      pubRole.visiblePlayers[pId] = pRole
    else
      return
    end
  end
  local bAOk, bBOk = false, false
  local function doAfterAllLoaded()
    if bAOk and bBOk then
      aRole:SetShowModel(true)
      pRole:SetShowModel(true)
      if aRole:IsInState(_G.RoleState.FLY) then
        local pos = pRole:GetPos()
        pRole:FlyAt(pos.x, pos.y, cb)
      else
        aRole:LeaveMount()
        pRole:SetToGround()
        pRole:LeaveMount()
        cb()
      end
    end
  end
  if aRole:IsInLoading() then
    aRole:AddOnLoadCallback("interactionload", function()
      bAOk = true
      doAfterAllLoaded()
    end)
  elseif aRole:IsObjLoaded() then
    bAOk = true
  end
  if pRole:IsInLoading() then
    pRole:AddOnLoadCallback("interactionload", function()
      bBOk = true
      doAfterAllLoaded()
    end)
  elseif pRole:IsObjLoaded() then
    bBOk = true
    doAfterAllLoaded()
  end
end
def.static("table", "table", "table").AddCurrentChannelMsg = function(activeRole, passiveRole, actionCfg)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local msg = actionCfg.channelStr:format(activeRole:GetName(), passiveRole:GetName())
  ChatModule.Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.CURRENT)
end
def.static("table", "table")._adjustTeamMemDir = function(aModel, pModel)
  local teamMap = PubroleModule.Instance().teamMap
  if teamMap == nil or aModel == nil or pModel == nil or aModel.teamId == nil or pModel.teamId == nil or not aModel.teamId:eq(pModel.teamId) then
    return
  end
  local teamInfo = teamMap[aModel.teamId:tostring()]
  if teamInfo == nil or teamInfo.members[1].roleId:eq(aModel.roleId) or #teamInfo.members < 3 then
    return
  end
  local dir = 0
  if aModel:IsInState(_G.RoleState.FLY) then
    if aModel.feijianModel == nil then
      return
    end
    dir = aModel.feijianModel:GetDir()
    aModel.feijianModel:SetDir(dir + 90)
  else
    dir = aModel:GetDir()
    aModel:SetDir(dir + 90)
  end
end
local EC = require("Types.Vector3")
def.static("table", "table", "table").AdjustModelsPosAndDir = function(aModel, pModel, actionCfg)
  if aModel == nil or pModel == nil then
    return
  end
  local offset, aDir
  local function getOffset()
    Cls._adjustTeamMemDir(aModel, pModel)
    aDir = aModel:GetDir()
    if aModel:IsInState(_G.RoleState.FLY) and aModel.feijianModel ~= nil then
      aDir = aModel.feijianModel:GetDir()
    end
    local rad = math.pi * aDir / 180
    local absDirX = math.sin(rad)
    local absDirY = math.cos(rad)
    local relaDirY = EC.Vector3.new(absDirX, 0, absDirY)
    local relaDirX = EC.Vector3.new(absDirY, 0, -absDirX)
    offset = relaDirX * actionCfg.offsetX + relaDirY * actionCfg.offsetY
  end
  getOffset()
  pModel:SetDir(aDir + actionCfg.relativeDir)
  local aPos = aModel:Get3DPos()
  pModel:Set3DPos(EC.Vector3.new(aPos.x + offset.x, aPos.y, aPos.z + offset.z))
end
def.static("userdata", "userdata", "table", "userdata", "userdata").PlayAction = function(aRoleId, pRoleId, actionCfg, inviterId, inviteeId)
  if actionCfg == nil then
    return
  end
  local function cb()
    local aRoleModel = PubroleModule.Instance():GetRole(inviterId)
    local passivRole = PubroleModule.Instance():GetRole(inviteeId)
    if aRoleModel and passivRole then
      Cls.AdjustModelsPosAndDir(aRoleModel, passivRole, actionCfg)
      if not inviterId:eq(aRoleId) then
        local tmp = aRoleModel
        aRoleModel = passivRole
        passivRole = tmp
      end
      Cls.AddCurrentChannelMsg(aRoleModel, passivRole, actionCfg)
      aRoleModel:HideBackup()
      passivRole:HideBackup()
      aRoleModel:ShowWeapon(not actionCfg.activeRoleHideWeapon)
      passivRole:ShowWeapon(not actionCfg.passiveRoleHideWeapon)
      aRoleModel:SetModelIsRender(true)
      aRoleModel:SetBoneIsRender(true)
      passivRole:SetModelIsRender(true)
      passivRole:SetBoneIsRender(true)
      Cls.PlayRoleAction(aRoleModel, actionCfg, true)
      Cls.PlayRoleAction(passivRole, actionCfg, false)
      aRoleModel:SetInteraction(passivRole, actionCfg.boneName)
    end
    if actionCfg.playType == PlayType.NORMAL_AFTER_PLAY then
      return
    end
    local couple = {aRoleId = inviterId, pRoleId = inviteeId}
  end
  Cls._prepare(inviterId, inviteeId, cb)
end
def.static("table", "table", "boolean").PlayRoleAction = function(roleModel, actionCfg, bActive)
  if roleModel == nil or actionCfg == nil then
    return
  end
  roleModel.idleTime = -2
  local commonMove = roleModel:GetOrAddMovePathComp()
  if commonMove then
    commonMove:set_enabled(false)
  end
  local effectPath
  local boneName = ""
  local actionName = ""
  local effectRes
  if bActive then
    effectRes = _G.GetEffectRes(actionCfg.sfxId1)
    boneName = actionCfg.skeletonName1
    actionName = actionCfg.activeActName
  else
    effectRes = _G.GetEffectRes(actionCfg.sfxId2)
    boneName = actionCfg.skeletonName2
    actionName = actionCfg.passiceActName
  end
  if effectRes then
    roleModel.effectPath = effectRes.path
  end
  if actionCfg.playType == PlayType.NORMAL_AFTER_PLAY then
    local function display()
      roleModel:SetStance()
      if effectRes then
        effectPath = effectRes.path
        roleModel:StopChildEffect(effectPath)
        roleModel:AddChildEffect(effectRes.path, BODY_PART.BONE, boneName, 0)
      end
      roleModel:PlayWithBackUp(actionName, function()
        if effectPath then
          roleModel:StopChildEffect(effectPath)
        end
        if roleModel:IsInState(RoleState.FLY) then
          roleModel:ResetFly()
        else
          roleModel:SetStance()
        end
        roleModel.idleTime = -1
        roleModel:HideBackup()
        roleModel:EndInteraction()
        roleModel:RecoveryRole()
        Cls.RecoveryPos(roleModel, nil)
      end)
    end
    if roleModel:IsInLoading() then
      roleModel:AddOnLoadCallback("Interaction", display)
    else
      display()
    end
  elseif actionCfg.playType == PlayType.PAUSE_AFTER_PLAY then
    local function display()
      roleModel:SetStance()
      if effectRes then
        effectPath = effectRes.path
        roleModel:StopChildEffect(effectRes.path)
        roleModel:AddChildEffect(effectRes.path, BODY_PART.BONE, boneName, 0)
      end
      roleModel:PlayWithBackUp(actionName, function()
      end)
    end
    if roleModel:IsInLoading() then
      roleModel:AddOnLoadCallback("Interaction", display)
    else
      display()
    end
  elseif actionCfg.playType == PlayType.CIRCLE then
    do
      local function LoopPlay()
        if roleModel.movePathComp and roleModel.movePathComp.enabled then
          return
        end
        if roleModel:IsInState(RoleState.PASSENGER) then
          local master = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetPassengerMaster(roleModel)
          if master and master.movePath and #master.movePath > 0 then
            return
          end
        end
        roleModel:PlayAnim(ActionName.Stand, nil)
        roleModel:PlayWithBackUp(actionName, function()
          GameUtil.AddGlobalLateTimer(0.01, true, LoopPlay)
        end)
        if effectRes then
          roleModel:StopChildEffect(effectRes.path)
          roleModel:AddChildEffect(effectRes.path, BODY_PART.BONE, boneName, 0)
        end
      end
      if roleModel:IsInLoading() then
        roleModel:AddOnLoadCallback("Interaction", LoopPlay)
      else
        LoopPlay()
      end
    end
  end
end
def.static("table", "table").RecoveryPos = function(roleModel, activeRoleModel)
  if roleModel == nil then
    return
  end
  local _2dPos = roleModel:GetPos()
  if roleModel:IsInState(_G.RoleState.FLY) then
    roleModel.feijianModel:SetPos(_2dPos.x, _2dPos.y)
    if activeRoleModel and activeRoleModel:IsInState(_G.RoleState.FLY) then
      local dir = activeRoleModel.feijianModel:GetDir()
      roleModel.feijianModel:SetDir(dir)
    end
  else
    roleModel:SetPos(_2dPos.x, _2dPos.y)
    if activeRoleModel then
      local dir = roleModel:GetDir()
      roleModel:SetDir(dir)
    end
  end
end
def.static("=>", "boolean").IsLevelEnough = function()
  return _G.GetHeroProp().level >= const.OPEN_LEVEL
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  if p.feature == Feature.TYPE_INTERACTION then
  end
end
def.static("table", "table").OnEnterFight = function(p, c)
  if instance._interactState == 1 or instance._interactState == 3 then
    Cls.ClearConfirmDlg()
    Cls.ClearInviteConfirmDlg()
    instance._interactState = 0
  end
end
def.static().ClearConfirmDlg = function()
  if instance._confirmDlg then
    instance._confirmDlg:DestroyPanel()
    instance._confirmDlg = nil
  end
end
def.static().ClearInviteConfirmDlg = function()
  if instance._inviteConfirmDlg then
    instance._inviteConfirmDlg:DestroyPanel()
    instance._inviteConfirmDlg = nil
  end
end
def.static("number").CSendPullRoleList = function(actionCfgId)
  local p = require("netio.protocol.mzm.gsp.interaction.CGetInteractionTargetList").new(actionCfgId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CSendInviteReq = function(roleId, actionId)
  local cfg = InteractionUtils.GetCfgById(actionId)
  if cfg == nil then
    return
  end
  local gender = require("Main.Hero.Interface").GetBasicHeroProp().gender
  local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  if cfg.boneName ~= "" and gender == SGenderEnum.MALE then
    local myRole = require("Main.Hero.HeroModule").Instance().myRole
    if myRole == nil then
      return
    end
    if not myRole:HasBone(cfg.boneName) then
      Toast(string.format(textRes.DoubleInteraction[39], cfg.name))
      return
    end
  end
  local p = require("netio.protocol.mzm.gsp.interaction.CInviteInteractionReq").new(roleId, actionId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number", "boolean").CSendReplyInvite = function(activeRoleId, actionId, bAccept)
  local CReplyInteractionInvitationReq = require("netio.protocol.mzm.gsp.interaction.CReplyInteractionInvitationReq")
  local iAccept = 0
  if bAccept then
    iAccept = 1
  end
  local reason = CReplyInteractionInvitationReq.USER
  if bAccept then
    local cfg = InteractionUtils.GetCfgById(actionId)
    if cfg == nil then
      return
    end
    local gender = require("Main.Hero.Interface").GetBasicHeroProp().gender
    local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
    if cfg.boneName ~= "" and gender == SGenderEnum.MALE then
      local myRole = require("Main.Hero.HeroModule").Instance().myRole
      if myRole == nil then
        return
      end
      if not myRole:HasBone(cfg.boneName) then
        Toast(string.format(textRes.DoubleInteraction[39], cfg.name))
        iAccept = 0
        reason = CReplyInteractionInvitationReq.ROLE_MODEL_NOT_COMPATIBLE
      end
    end
  end
  local p = require("netio.protocol.mzm.gsp.interaction.CReplyInteractionInvitationReq").new(activeRoleId, actionId, iAccept, reason)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CSendCancel = function(passiveRoleId, actionId)
  local p = require("netio.protocol.mzm.gsp.interaction.CCancelInteractionInvitationReq").new(passiveRoleId, actionId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnInviteSuccess = function(p)
  Cls.ClearConfirmDlg()
  instance._interactState = 1
  instance._confirmDlg = CommonConfirmDlg.ShowCerternConfirm(txtConst[3], txtConst[4], txtConst[5], function(select)
    if select == nil or select == -1 then
      Cls.CSendCancel(p.passive_role_id, p.interaction_id)
    end
    instance._confirmDlg = nil
    instance._interactState = 0
  end, nil)
end
def.static("table").OnInviteFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.interaction.SInviteInteractionFail")
  if p.reason == ERROR_CODE.ACTIVE_ROLE_BANNED then
    warn("[ERROR: ACTIVE_ROLE_BANNED]")
    Toast(txtConst[32])
  elseif p.reason == ERROR_CODE.ACTIVE_ROLE_LEVEL_TOO_LOW then
    Toast(txtConst[10])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_LEVEL_TOO_LOW then
    Toast(txtConst[11])
  elseif p.reason == ERROR_CODE.UNAVAILABLE_TO_SAME_GENDER then
    Toast(txtConst[12])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_NOT_TEAMMATE_NOT_SINGLE then
    warn("[ERROR: PASSIVE ROLE IN UNKNOWN ROLE STATE]")
    Toast(txtConst[35])
  elseif p.reason == ERROR_CODE.ACTIVE_ROLE_IN_INVITING then
    Toast(txtConst[13])
  elseif p.reason == ERROR_CODE.ACTIVE_ROLE_BEING_INVITED then
    Toast(txtConst[14])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_IN_INVITING then
    Toast(txtConst[16])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_BEING_INVITED then
    Toast(txtConst[15])
  elseif p.reason == ERROR_CODE.IN_DIFFERENT_SCENE then
    warn("[ERROR: IN DIFFERENT SCENE]")
    Toast(txtConst[36])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_OFFLINE then
    Toast(txtConst[17])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_IN_COMBAT then
    Toast(txtConst[18])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_IN_WATCHING_MOON then
    Toast(txtConst[19])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_IN_ESCORTING then
    Toast(txtConst[20])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_IN_MARRIAGE_PARADE then
    Toast(txtConst[21])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_IN_PRISON then
    Toast(txtConst[22])
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_IN_OBSERVING_FIGHT then
    Toast(txtConst[28])
  elseif p.reason == ERROR_CODE.ACTIVE_ROLE_ON_MULTI_ROLE_MOUNT then
    local me = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
    if me:IsInState(_G.RoleState.FLY) then
      Toast(txtConst[38])
    else
      Toast(txtConst[30])
    end
  elseif p.reason == ERROR_CODE.PASSIVE_ROLE_ON_MULTI_ROLE_MOUNT then
    Toast(txtConst[31])
  elseif p.reason == ERROR_CODE.ACTIVE_ROLE_NOT_LEADER_PASSIVE_ROLE_NOT_TEAMMATE then
    if require("Main.Team.TeamData").Instance():MeIsCaptain() then
      Toast(txtConst[35])
    else
      Toast(txtConst[34])
    end
  end
  Cls.ClearConfirmDlg()
end
def.static("table").OnRcvInvitation = function(p)
  local roleName = _G.GetStringFromOcts(p.active_role_name)
  local activeCfg = InteractionUtils.GetCfgById(p.interaction_id)
  local content = txtConst[6]:format(roleName, activeCfg.name)
  local defaultRefuse = 0
  if activeCfg.bAcceptAsDefault then
    defaultRefuse = 1
  end
  Cls.ClearInviteConfirmDlg()
  instance._interactState = 3
  instance._inviteConfirmDlg = CommonConfirmDlg.ShowConfirmCoundDown(txtConst[3], content, txtConst[8], txtConst[7], defaultRefuse, const.CONFIRM_COUNTDOWN, function(select)
    warn("_inviteConfirmDlg==================> select =", select)
    if select == 1 then
      Cls.CSendReplyInvite(p.active_role_id, activeCfg.id, true)
    elseif select == -1 then
      Cls.CSendReplyInvite(p.active_role_id, activeCfg.id, false)
    else
      Cls.CSendReplyInvite(p.active_role_id, activeCfg.id, false)
    end
    instance._inviteConfirmDlg = nil
    instance._interactState = 0
  end, {m_level = 1})
end
def.static("table").OnRcvInvitationFail = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.interaction.SAcceptInteractionInvitationFail")
  if p.reason == ERROR_CODE.SAME_TEAM_ACTIVE_ROLE_AWAY then
    Toast(txtConst[33])
  elseif p.reason == ERROR_CODE.DIFFERENT_TEAM_PASSIVE_ROLE_NOT_SINGLE then
    Toast(txtConst[24])
  else
    local activeCfg = InteractionUtils.GetCfgById(p.interaction_id)
    Toast(txtConst[9]:format(activeCfg.name))
  end
  Cls.ClearConfirmDlg()
end
def.static("table").OnCancelInteraction = function(p)
  Cls.ClearInviteConfirmDlg()
  if _G.GetHeroProp().id:eq(p.active_role_id) then
    Toast(txtConst[26])
  else
    Toast(txtConst[25])
  end
end
def.static("table").OnOtherRefuse = function(p)
  Cls.ClearConfirmDlg()
  local activeCfg = InteractionUtils.GetCfgById(p.interaction_id)
  if p.reason == require("netio.protocol.mzm.gsp.interaction.CReplyInteractionInvitationReq").ROLE_MODEL_NOT_COMPATIBLE then
    Toast(txtConst[40]:format(activeCfg.name))
  else
    Toast(txtConst[27]:format(activeCfg.name))
  end
end
def.static("table").OnStartInteraction = function(p)
  if instance._confirmDlg then
    instance._confirmDlg.callback = nil
  end
  Cls.ClearConfirmDlg()
  local actionCfg = InteractionUtils.GetCfgById(p.interaction_id)
  if actionCfg then
    Cls.PlayAction(p.active_role_id, p.passive_role_id, actionCfg, p.inviter_role_id, p.invitee_role_id)
  else
    warn("[ERROR:Interaction Action Cfg not exist, interaction id :]", p.interaction_id)
  end
end
def.static("table").OnGetRoleList = function(p)
  local uiTargetList = require("Main.DoubleInteraction.ui.UITargetList").Instance()
  if uiTargetList:IsLoaded() then
    Event.DispatchEvent(ModuleId.DOUBLE_INTERACTION, gmodule.notifyId.DoubleInteraction.GetRoleList, p.target_list)
  else
    uiTargetList:ShowPanel(p.interaction_id, p.target_list)
  end
end
return Cls.Commit()
