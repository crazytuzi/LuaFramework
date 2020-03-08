local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local PubroleModule = Lplus.Extend(ModuleBase, "PubroleModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local ECModel = Lplus.ForwardDeclare("ECModel")
local NpcModel = require("Main.Pubrole.NpcModel")
local ItemModel = require("Main.Map.ItemModel")
local NPCInterface = require("Main.npc.NPCInterface")
local TitleInterface = require("Main.title.TitleInterface")
local MapInterface = require("Main.Map.Interface")
local SETTING_ID = require("Main.SystemSetting.SystemSettingModule").SystemSetting
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local ROLE_SERVER_STATUS = require("netio.protocol.mzm.gsp.status.StatusEnum")
local PetInterface = require("Main.Pet.Interface")
local MapModelInfo = require("netio.protocol.mzm.gsp.map.MapModelInfo")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local DyeData = require("Main.Dyeing.data.DyeData")
local fightMgr
local def = PubroleModule.define
local instance
local EC = require("Types.Vector3")
local MathHelper = require("Common.MathHelper")
local TeamData = require("Main.Team.TeamData")
local GangBattleMgr = require("Main.Gang.GangBattleMgr")
local GangCrossBattleMgr = require("Main.GangCross.GangCrossBattleMgr")
local BattleFieldMgr = require("Main.CaptureTheFlag.mgr.BattleFieldMgr")
local GangData = require("Main.Gang.data.GangData")
local ProtocolManager = require("netio.ProtocolManager")
local Octets = require("netio.Octets")
local XunluTip = require("Main.Hero.ui.XunluTip")
local WeddingUnitType = require("consts.mzm.gsp.marriage.confbean.WeddingUnitType")
local WeddingActionType = require("consts.mzm.gsp.marriage.confbean.WeddingActionType")
local ECFxMan = require("Fx.ECFxMan")
local SRoleEnterView = require("netio.protocol.mzm.gsp.map.SRoleEnterView")
local MapGroupType = require("netio.protocol.mzm.gsp.map.MapGroupType")
local FriendModule = require("Main.friend.FriendModule")
local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local Space = require("consts.mzm.gsp.map.confbean.Space")
local MapGroupExtraInfoType = require("netio.protocol.mzm.gsp.map.MapGroupExtraInfoType")
local BitMap = require("Common.BitMap")
local LRUCache = require("Common.ECLRUCache")
local map_scene, weddingCfg
def.field("table").rolesMap = nil
def.field("table").npcMap = nil
def.field("table").monsterMap = nil
def.field("table").followList = nil
def.field("table").teamMap = nil
def.field("table").coupleMap = nil
def.field("table").watchMoonMap1 = nil
def.field("table").watchMoonMap2 = nil
def.field("table").groupWeddingMap = nil
def.field("number").followTime = 0
def.field("table").itemMap = nil
def.field("boolean").isPlayingCG = false
def.field("table").pendingRoleInfoReqList = nil
def.field("table").pendingRoleModelInfoCallbacks = nil
def.field("table").pendingRoleNameReqs = nil
def.field("table").roleNameCache = nil
def.field("table").visiblePlayers = nil
def.field("table").priorityVisiblePlayers = nil
def.field("table").invisiblePlayers = nil
def.field("table").changemap_target_pos = nil
def.field("number").max_visible_players_num = max_show_players
def.field("boolean").enableSingleMode = true
def.field("number").forcedPlayerNum = -1
def.field("table").weddingScene = nil
def.field("boolean").inGroupWedding = false
def.field("table").NpcMapCfg = nil
def.field("table").MapNpcCfg = nil
def.field("table").MonstersInAir = nil
def.field("table").enterViewRolesInFight = nil
def.field("table").enterViewTeamsInFight = nil
def.field("boolean").isOnlyShowSpecificRoles = false
def.field("table").specificRoles = nil
def.field("table").npcMapToRole = nil
def.field("table").monsterCfgCache = nil
def.field("table").npcChangeModelMap = nil
def.field("table").userNpcMap = nil
def.field("table").disabledNpcList = nil
def.field("table").npcStateMap = nil
def.field("table").mapRoleLocs = nil
def.const("number").VIEW_RADIUS = 640
def.const("number").FOLLOW_APART = 80
def.const("number").DEFAULT_LOW_PLAYERS = 5
def.const("table").NPC_CHANGE_MAP_SRC = {CLIENT = 1, SERVER = 2}
def.const("number").ROLE_NAME_CACHE_LIMIT = 20
def.static("=>", PubroleModule).Instance = function()
  if instance == nil then
    instance = PubroleModule()
    instance.m_moduleId = ModuleId.PUBROLE
  end
  return instance
end
def.override().Init = function(self)
  self.rolesMap = {}
  self.npcMap = {}
  self.monsterMap = {}
  self.followList = {}
  self.teamMap = {}
  self.coupleMap = {}
  self.watchMoonMap1 = {}
  self.watchMoonMap2 = {}
  self.groupWeddingMap = {}
  self.pendingRoleInfoReqList = {}
  self.pendingRoleModelInfoCallbacks = {}
  self.itemMap = {}
  self.visiblePlayers = {}
  self.invisiblePlayers = {}
  self.priorityVisiblePlayers = {}
  self.monsterCfgCache = {}
  self.userNpcMap = {}
  self.npcStateMap = {}
  self.inGroupWedding = false
  fightMgr = require("Main.Fight.FightMgr").Instance()
  Timer:RegisterIrregularTimeListener(self.Update, self)
  GameUtil.AddGlobalTimer(1, false, function()
    self:CheckRolesInView()
    self:UpdateMonsterCfgCache(1)
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SRoleEnterView", PubroleModule.OnSRoleEnterView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SRoleLeaveView", PubroleModule.OnSRoleLeaveView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncRoleMove", PubroleModule.OnSSyncRoleMove)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncSelfPosChange", PubroleModule.OnSSyncSelfPosChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SRoleDirectionChange", PubroleModule.OnSRoleDirectionChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SNPCEnterView", PubroleModule.OnSNPCEnterView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SNPCLeaveView", PubroleModule.OnSNPCLeaveView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SModelNPCEnterView", PubroleModule.OnSModelNPCEnterView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMonsterEnterView", PubroleModule.OnSMonsterEnterView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMonsterLeaveView", PubroleModule.OnSMonsterLeaveView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncMonsterNameChange", PubroleModule.OnSSyncMonsterNameChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SResetRoleModel", PubroleModule.OnSResetRoleModel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapTeamInfo", PubroleModule.OnSMapTeamInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapTeamEnterView", PubroleModule.OnSMapTeamEnterView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapTeamSyncPos", PubroleModule.OnSMapTeamSyncPos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapTeamTransferPos", PubroleModule.OnSMapTeamTransferPos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapTeamLeaveView", PubroleModule.OnSMapTeamLeaveView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapLeaveTeam", PubroleModule.OnSMapLeaveTeam)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapTeamDissole", PubroleModule.OnSMapTeamDismiss)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapGroupInfo", PubroleModule.OnSMapGroupInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapGroupEnterView", PubroleModule.OnSMapGroupEnterView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapGroupSyncPos", PubroleModule.OnSMapGroupSyncPos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapGroupTransferPos", PubroleModule.OnSMapGroupTransferPos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapGroupLeaveView", PubroleModule.OnSMapGroupLeaveView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapGroupDissole", PubroleModule.OnSMapGroupDissole)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncMapGroupExtraInfoChange", PubroleModule.OnSSyncMapGroupExtraInfoChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapGroupForceLand", PubroleModule.OnSMapGroupForceLand)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncRoleModelChange", PubroleModule.OnSSyncRoleModelChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncRoleNameChange", PubroleModule.OnSSyncRoleNameChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapNpcStartMove", PubroleModule.OnSMapNpcStartMove)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapNpcStopMove", PubroleModule.OnSMapNpcStopMove)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapMonsterStartMove", PubroleModule.OnSMapMonsterStartMove)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapMonsterStopMove", PubroleModule.OnSMapMonsterStopMove)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapMonsterFightStart", PubroleModule.OnSMapMonsterFightStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapMonsterFightEnd", PubroleModule.OnSMapMonsterFightEnd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleInfoRes", PubroleModule.OnSGetRoleInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSendRoleModelInfo", PubroleModule.OnSSendRoleModelInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleNameRep", PubroleModule.OnSGetRoleNameRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapItemEnterView", PubroleModule.OnSMapItemEnterView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapItemLeaveView", PubroleModule.OnSMapItemLeaveView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncMapFly", PubroleModule.OnSSyncMapFly)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncLand", PubroleModule.OnSSyncLand)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapFlyErrorRes", PubroleModule.OnSSyncMapFlyError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SLandErrorRes", PubroleModule.OnSSyncLandError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SNotifyPlayEffect", PubroleModule.OnSNotifyPlayEffect)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SForceLandRes", PubroleModule.OnSForceLandRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.STeamForceLandRes", PubroleModule.OnSTeamForceLandRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SGetMonsterLocationRes", PubroleModule.OnSGetMonsterLocationRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncRoleStatusChange", PubroleModule.OnSSyncRoleStatusChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SRoleExtraUpdateBrd", PubroleModule.OnSRoleExtraUpdateBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SRoleExtraRemoveBrd", PubroleModule.OnSRoleExtraRemoveBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SBroadCastMarriage", PubroleModule.OnSBroadCastMarriage)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseFireWorksItemRes", PubroleModule.OnSUseFireWorksItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SParadeRobStageRes", PubroleModule.OnSParadeRobStageRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SBrocastRobMarriageParadeEnd", PubroleModule.OnSBrocastRobMarriageParadeEnd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SSynMarrageParadeAttackRes", PubroleModule.OnSSynMarrageParadeAttackRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SReportRoleRes", PubroleModule.OnSReportRoleRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SGetHeart", PubroleModule.OnSGetHeart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SBroadcastPositionInScene", PubroleModule.OnSBroadcastPositionInScene)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TASK_STATUS_CHANGED, PubroleModule.ShowNpcFlag)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, PubroleModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, PubroleModule.OnLeaveFight)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, PubroleModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PubroleModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PopChat, PubroleModule.OnPopChat)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, PubroleModule.OnStartDrama)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, PubroleModule.OnEndDrama)
  Event.RegisterEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.SETTING_CHANGED, PubroleModule.OnSettingChanged)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.CHANGE_MAP_LOADING_FINISHED, PubroleModule.OnChangeMapFindPath)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, PubroleModule.OnChangeMap)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.ENTER_GANG_BATTLE_MAP, PubroleModule.OnGangBattle)
  Event.RegisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.ENTER_GANG_BATTLE_MAP, PubroleModule.OnGangBattle)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_ROLE, PubroleModule.OnTouchRole)
  Event.RegisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.ENTER_BANQUET, PubroleModule.OnEnterBANQUET)
  Event.RegisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.LEAVE_BANQUET, PubroleModule.OnLeaveBANQUET)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, PubroleModule.OnSetNpcDisable)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_STATE, PubroleModule.OnSetNpcState)
  ModuleBase.Init(self)
  self:LoadMapNpcCfg()
end
def.static("table").OnSRoleEnterView = function(p)
  local modelInfo = GetModelInfo(p.modelInfo)
  if modelInfo.id:eq(GetMyRoleID()) then
    return
  end
  local role = instance:GetRole(modelInfo.id)
  if role then
    if instance:CheckState(modelInfo.role_status_list, ROLE_SERVER_STATUS.STATUS_FLY) then
      role:FlyAt(p.curPos.x, p.curPos.y, nil)
    else
      role:SetPos(p.curPos.x, p.curPos.y)
    end
    return
  end
  local roleId = modelInfo.id:tostring()
  local targetpos = p.keyPointPath[#p.keyPointPath]
  local finalPos = targetpos
  if finalPos == nil then
    finalPos = p.curPos
  end
  local petdata = p.models[p.KEY_PET]
  local petModelInfo = petdata and GetModelInfo(petdata)
  local child_data = p.models[p.KEY_CHILDREN]
  local childInfo = child_data and GetModelInfo(child_data)
  instance.invisiblePlayers[roleId] = {
    modelInfo = modelInfo,
    pos = finalPos,
    dir = p.direction,
    petModelInfo = petModelInfo,
    childInfo = childInfo
  }
  if fightMgr.isInFight then
    if instance.enterViewRolesInFight == nil then
      instance.enterViewRolesInFight = {}
    end
    instance.enterViewRolesInFight[roleId] = modelInfo.id
    return
  end
  local count = table.nums(instance.visiblePlayers)
  if count >= instance.max_visible_players_num then
    return
  end
  local color = GetColorData(701300000)
  role = instance:AddRole(modelInfo.id, modelInfo, p.curPos.x, p.curPos.y, p.direction, color, RoleType.ROLE)
  instance.visiblePlayers[roleId] = role
  role:SetShowModel(instance:IsShowOtherPlayers())
  if role then
    if modelInfo[ModelInfo.HUSONG_FOLLOW_MONSTER_ID] then
      instance:CreateEscortUnit(modelInfo[ModelInfo.HUSONG_FOLLOW_MONSTER_ID], role)
    elseif modelInfo[ModelInfo.HUSONG_COUPLE_FLY_NPC_CFG_ID] then
      local function DoEscort()
        local gender = modelInfo[ModelInfo.GENDER]
        local passive = gender == GenderEnum.FEMALE
        instance:CreateEscortHugUnit(modelInfo[ModelInfo.HUSONG_COUPLE_FLY_NPC_CFG_ID], role, false, passive, targetpos)
      end
      if role:IsInLoading() then
        role:AddOnLoadCallback("HugEscort", DoEscort)
      else
        DoEscort()
      end
    elseif petModelInfo then
      instance:ShowOtherModel(role, petModelInfo)
    elseif childInfo then
      instance:ShowChildModel(role, childInfo)
    end
    if instance:CheckState(modelInfo.role_status_list, ROLE_SERVER_STATUS.STATUS_FLY) then
      if targetpos then
        role:FlyTo(targetpos.x, targetpos.y, nil)
      else
        role:FlyAt(p.curPos.x, p.curPos.y, nil)
      end
    else
      instance:RoleRunPath(role, p.keyPointPath)
    end
  end
end
def.method("table", "table").ShowOtherModel = function(self, role, petModelInfo)
  if role and petModelInfo and petModelInfo then
    local pos = role:GetPos()
    local dir = role:GetDir()
    local followPos = self:GetFollowerPos(pos.x, pos.y, dir)
    local pet = instance:CreatePetModel(petModelInfo.id, petModelInfo.model, petModelInfo.string_props[petModelInfo.NAME], followPos.x, followPos.y, role:GetDir(), role.runSpeed)
    if pet then
      local petcolor = GetModelColorCfg(petModelInfo.model.modelColorId)
      if petcolor then
        pet:SetColoration(petcolor)
      end
      role:AddPet(pet)
      pet.followSpeed = role.runSpeed
      instance:RoleFollow(pet, role)
      pet:SetShowModel(role.showModel)
    end
  end
end
def.method("table", "table").ShowChildModel = function(self, role, childModelInfo)
  if role and childModelInfo then
    local pos = role:GetPos()
    local dir = role:GetDir()
    local followPos = self:GetFollowerPos(pos.x, pos.y, dir)
    local modelCfgId = childModelInfo.model.extraMap[ModelInfo.CHILDREN_MODEL_ID]
    local child_name = childModelInfo.string_props[childModelInfo.NAME] or childModelInfo.model.name
    local child = require("Main.Children.Child").Create(modelCfgId)
    child:SetInstanceId(childModelInfo.id)
    child:LoadModel(child_name, GetColorData(701300007), followPos.x, followPos.y, dir, childModelInfo.model, nil)
    child = child:GetModel()
    if child then
      child:SetTouchable(false)
      role:AddPet(child)
      child.followSpeed = role.runSpeed
      instance:RoleFollow(child, role)
      child:SetShowModel(role.showModel)
    end
  end
end
def.method("number", "number", "number", "=>", "table").GetFollowerPos = function(self, x, y, dir)
  local angle = (270 - dir) / 180 * math.pi
  local pos = {}
  pos.x = x + PubroleModule.FOLLOW_APART * math.cos(angle)
  pos.y = y - PubroleModule.FOLLOW_APART * math.sin(angle)
  return pos
end
def.static("table").OnSResetRoleModel = function(p)
  local modelInfo = GetModelInfo(p.modelInfo)
  local role = instance:GetRole(modelInfo.id)
  if role == nil then
    Debug.LogWarning("[OnSResetRoleModel] target role is nil")
    return
  end
  local roleIdStr = modelInfo.id:tostring()
  local roledata = instance.invisiblePlayers[roleIdStr]
  if modelInfo.model.modelid == roledata.modelInfo.model.modelid then
    return
  end
  roledata.modelInfo = modelInfo
  local function LoadNewModel()
    role:ChangeModel(modelInfo.model.modelid)
    role:LoadModelInfo(modelInfo.model)
  end
  if role:IsInLoading() then
    role:AddOnLoadCallback("change_model", LoadNewModel)
  else
    LoadNewModel()
  end
end
def.static("table").OnSRoleLeaveView = function(p)
  local roleIdStr = p.roleId:tostring()
  if instance.enterViewRolesInFight then
    instance.enterViewRolesInFight[roleIdStr] = nil
  end
  instance:RemoveRole(p.roleId)
  instance.invisiblePlayers[roleIdStr] = nil
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.MAP_ROLE_LEAVE_VIEW, {
    roleId = p.roleId
  })
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  for _, v in pairs(instance.rolesMap) do
    v:ShowHudParts(false)
    v:ShowName(false)
    v.showPart = false
    local pet = v:GetPet()
    if pet then
      pet:ShowHudParts(false)
      pet:ShowName(false)
      pet.showPart = false
    end
  end
  for _, v in pairs(instance.npcMap) do
    v:ShowHudParts(false)
    v:ShowName(false)
    v.showPart = false
  end
  for _, v in pairs(instance.monsterMap) do
    v:ShowHudParts(false)
    v:ShowName(false)
    v.showPart = false
  end
  for _, v in pairs(instance.userNpcMap) do
    v:ShowHudParts(false)
    v:ShowName(false)
    v.showPart = false
  end
  for _, v in pairs(instance.itemMap) do
    v:ShowName(false)
    v.showPart = false
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if instance.enterViewRolesInFight then
    local count = table.nums(instance.visiblePlayers)
    for k, v in pairs(instance.enterViewRolesInFight) do
      if count < instance.max_visible_players_num then
        local role = instance.rolesMap[k]
        if role == nil then
          role = instance:CreateRoleModel(instance.invisiblePlayers[k])
          if role then
            count = count + 1
          end
        end
      end
      instance.enterViewRolesInFight[k] = nil
    end
  end
  if instance.enterViewTeamsInFight then
    for k, v in pairs(instance.enterViewTeamsInFight) do
      PubroleModule.OnSMapTeamEnterView(v)
      instance.enterViewTeamsInFight[k] = nil
    end
  end
  for k, v in pairs(instance.rolesMap) do
    if v.showModel then
      if not v.m_visible then
        v:SetVisible(true)
      else
        v:ShowHudParts(true)
        v:ShowName(true)
      end
      local pet = v:GetPet()
      if pet then
        if not pet.m_visible then
          pet:SetVisible(true)
        else
          pet:ShowHudParts(true)
          pet:ShowName(true)
        end
        pet.showPart = true
      end
    else
      v:ShowName(true)
      local pet = v:GetPet()
      if pet then
        pet:ShowName(true)
      end
    end
    v.showPart = true
  end
  for _, v in pairs(instance.npcMap) do
    if not v.m_visible then
      v:SetVisible(true)
    else
      v:ShowHudParts(true)
      v:ShowName(true)
    end
    v.showPart = true
  end
  for _, v in pairs(instance.monsterMap) do
    if not v.m_visible then
      v:SetVisible(true)
    else
      v:ShowHudParts(true)
      v:ShowName(true)
    end
    v.showPart = true
  end
  for _, v in pairs(instance.userNpcMap) do
    if not v.m_visible then
      v:SetVisible(true)
    else
      v:ShowHudParts(true)
      v:ShowName(true)
    end
    v.showPart = true
  end
  for _, v in pairs(instance.itemMap) do
    if not v.m_visible then
      v:SetVisible(true)
    else
      v:ShowName(true)
    end
    v.showPart = true
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local mapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  if mapModule:GetMapId() == 330000998 then
    instance.forcedPlayerNum = 1
  end
  local Setting_Module = gmodule.moduleMgr:GetModule(ModuleId.SYSTEM_SETTING)
  local setting = Setting_Module:GetSetting(SystemSettingModule.SystemSetting.CloseTouchListPanel)
  _G.show_touch_list = not setting.isEnabled
  instance:SetMaxVisibleNum()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance.isPlayingCG = false
  instance.isOnlyShowSpecificRoles = false
  instance.specificRoles = nil
  instance:OnReset()
  PubroleModule.SendTLog()
  require("GUI.CommonCountDown").End()
end
def.method("userdata", "=>", "table").GetRoleModelInfo = function(self, roleId)
  return _G.CloneModelInfo(self:_GetRoleModelInfo(roleId))
end
def.method("userdata", "=>", "table").GetRoleStatus = function(self, roleId)
  if roleId == nil then
    return nil
  end
  local roledata = self.invisiblePlayers[roleId:tostring()]
  if roledata then
    return roledata.modelInfo.role_status_list
  end
  return nil
end
def.method("userdata", "=>", "table")._GetRoleModelInfo = function(self, roleId)
  if roleId == nil then
    return nil
  end
  local roledata = self.invisiblePlayers[roleId:tostring()]
  if roledata then
    return roledata.modelInfo.model
  end
  return nil
end
def.method("userdata", "function").GetServerRoleModelInfo = function(self, roleId, callback)
  if roleId == nil then
    return
  end
  local modelInfo = self:GetRoleModelInfo(roleId)
  if modelInfo then
    callback(modelInfo)
    return
  end
  self:ReqRoleModelInfo(roleId, callback)
end
def.static("table", "table").OnPopChat = function(p1, p2)
  local roleId = p1.roleId
  local cnt = p1.content
  local role = instance.rolesMap[roleId:tostring()]
  if role and role.m_visible and role.showModel then
    if p1.bubbleName == nil then
      role:Talk(cnt, 0)
    else
      role:TalkWithCustomeBubble(cnt, 0, p1.bubbleName, p1.arrowName)
    end
  end
end
def.static("table").OnSSyncRoleMove = function(p)
  local roleId = p.roleId:tostring()
  local role = instance.rolesMap[roleId]
  if role == nil then
    local roledata = instance.invisiblePlayers[roleId]
    if roledata then
      local targetPos = p.keyPointPath[#p.keyPointPath]
      if targetPos then
        roledata.pos = targetPos
      end
    end
    return
  end
  if role:IsInState(RoleState.FLY) then
    instance:RoleFly(role, p.keyPointPath)
  else
    role:SetDir(p.direction)
    instance:RoleRunPath(role, p.keyPointPath)
  end
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.MAP_ROLE_MOVE, {
    roleId = p.roleId
  })
end
def.static("table").OnSSyncSelfPosChange = function(p)
  local mapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local myRole = heroMgr.myRole
  if myRole == nil then
    return
  end
  if heroMgr:IsPatroling() then
    heroMgr:StopPatroling()
  else
    heroMgr:Stop()
  end
  XunluTip.HideXunlu()
  local isSameMap = false
  local myId = myRole.roleId or heroMgr:GetMyRoleId()
  if mapModule.mapInstanceId ~= p.mapInstanceId then
    instance:RemoveAllMapRoles(false, {myId})
    mapModule.mapInstanceId = p.mapInstanceId
    Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_INSTANCE_CHANGED, {
      lastMapId = mapModule.currentMapId,
      mapId = p.mapid
    })
  else
    isSameMap = true
  end
  if p.mapid ~= mapModule.currentMapId then
    mapModule:LoadMap(p.mapid)
    if myRole.mECFabaoComponent then
      myRole.mECFabaoComponent:Reset()
    end
  else
    _G.IsMutilFrameLoadMap = false
  end
  Camera2D.SetFocus(p.pos.x, p.pos.y)
  ECGame.Instance():SetCameraFocus(p.pos.x, p.pos.y)
  if myRole ~= nil then
    if myRole:IsInState(RoleState.FLY) then
      myRole:FlyAt(p.pos.x, p.pos.y, nil)
    else
      myRole:SetPos(p.pos.x, p.pos.y)
    end
    ECGame.Instance():setMapPosInfo(p.pos.x, p.pos.y)
    local pet = myRole:GetPet()
    if pet then
      pet:SetPos(p.pos.x, p.pos.y)
      pet.movePath = nil
      pet:Stop()
      pet:SetDir(p.direction)
    end
    instance.changemap_target_pos = p.targetPos
  end
  if isSameMap then
    local myIdStr = myId:tostring()
    instance:RemoveOtherPlayers(p.pos, {
      [myIdStr] = true
    })
  end
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_TRANSPOS, nil)
end
def.method("table", "table").RemoveOtherPlayers = function(self, tpos, filter)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local isInAir = heroMgr.myRole:IsInState(RoleState.FLY)
  for k, v in pairs(instance.rolesMap) do
    if not filter[k] then
      local rpos = v:GetPos()
      if rpos and instance:CheckOutView(rpos, tpos, isInAir) then
        instance:RemoveRoleByString(k)
      end
    end
  end
  for k, v in pairs(instance.monsterMap) do
    local rpos = v:GetPos()
    if rpos and instance:CheckOutView(rpos, tpos, isInAir) then
      instance:RemoveMonster(k)
    end
  end
  for k, v in pairs(instance.itemMap) do
    local rpos = v:GetPos()
    if rpos and instance:CheckOutView(rpos, tpos, isInAir) then
      instance:RemoveItem(k)
    end
  end
  gmodule.moduleMgr:GetModule(ModuleId.MAP):RemoveOutViewMapEntities(tpos, isInAir)
end
def.static("table", "table").OnChangeMapFindPath = function(p1, p2)
  if not _G.CGPlay and not ECGame.Instance().m_ScreenDark then
    Application.set_targetFrameRate(_G.max_frame_rate)
  end
  local mapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local myRole = heroMgr.myRole
  if myRole == nil then
    return
  end
  if instance.weddingScene then
    instance:EndWedding()
  end
  local pos = myRole:GetPos()
  if instance.changemap_target_pos and (pos == nil or pos.x ~= instance.changemap_target_pos.x or pos.y ~= instance.changemap_target_pos.y) then
    do
      local mapId = mapModule.currentMapId
      local targetPos = instance.changemap_target_pos
      instance.changemap_target_pos = nil
      if not instance:IsInFollowState(heroMgr.roleId) then
        GameUtil.AddGlobalTimer(0.5, true, function()
          if mapId == mapModule.currentMapId and targetPos then
            heroMgr:ContinueFindPath(targetPos.x, targetPos.y)
          end
        end)
      end
    end
  end
end
def.static("table").OnSRoleDirectionChange = function(p)
  local role = instance.rolesMap[p.roleId:tostring()]
  if role == nil then
    return
  end
  role:SetDir(role.sprite, p.direction)
end
def.static("table").OnSSyncRoleModelChange = function(p)
  local roleId = p.roleId:tostring()
  local role = instance.rolesMap[roleId]
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local isMe = p.roleId:eq(heroModule.roleId)
  local roledata = instance.invisiblePlayers[roleId]
  if roledata and roledata.modelInfo then
    if p.intPropMap[p.ROLE_MODEL_ID] then
      roledata.modelInfo.model.modelid = p.intPropMap[p.ROLE_MODEL_ID]
    end
    if p.intPropMap[p.MOUNTS_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.MOUNTS_ID] = p.intPropMap[p.MOUNTS_ID]
    end
    if p.intPropMap[p.MOUNTS_COLOR_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.MOUNTS_COLOR_ID] = p.intPropMap[p.MOUNTS_COLOR_ID]
    end
    if p.intPropMap[p.MOUNTS_RANK] then
      roledata.modelInfo.model.extraMap[ModelInfo.MOUNTS_RANK] = p.intPropMap[p.MOUNTS_RANK]
    end
    if p.intPropMap[p.PET_MODEL_ID] then
      local newpetModelId = p.intPropMap[p.PET_MODEL_ID]
      if newpetModelId <= 0 then
        if roledata.petModelInfo then
          roledata.petModelInfo = nil
        end
      else
        local petdata = roledata.petModelInfo
        if petdata then
          petdata.id = p.longPropMap[p.PET_ID]
          petdata.model.modelid = newpetModelId
        end
      end
    end
    if p.intPropMap[p.PET_EXTERIOR_ID] then
      local petExtId = p.intPropMap[p.PET_EXTERIOR_ID]
      local petdata = roledata.petModelInfo
      if petdata then
        petdata.model.extraMap[ModelInfo.PET_EXTERIOR_ID] = petExtId
      end
    end
    if p.intPropMap[p.WEAPON_MODEL_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.WEAPON] = p.intPropMap[p.WEAPON_MODEL_ID]
    end
    if p.intPropMap[p.WUSHI_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.WUSHI_ID] = p.intPropMap[p.WUSHI_ID]
    end
    if p.intPropMap[p.WING_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.WING] = p.intPropMap[p.WING_ID]
    end
    if p.intPropMap[p.FABAO_MODEL_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.FABAO] = p.intPropMap[p.FABAO_MODEL_ID]
    end
    if p.intPropMap[p.FABAO_LINGQI_MODEL_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.FABAO_LINGQI] = p.intPropMap[p.FABAO_LINGQI_MODEL_ID]
    end
    if p.intPropMap[p.AIRCRAFT_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.AIRCRAFT] = p.intPropMap[p.AIRCRAFT_ID]
    end
    if p.intPropMap[p.TITLEID] then
      roledata.modelInfo.int_props[MapModelInfo.TITLEID] = p.intPropMap[p.TITLEID]
    end
    if p.intPropMap[p.APPELLATIONID] then
      roledata.modelInfo.int_props[MapModelInfo.APPELLATIONID] = p.intPropMap[p.APPELLATIONID]
    end
    if p.stringPropMap[p.APPELLATION] then
      roledata.modelInfo.string_props[MapModelInfo.APPELLATIONID] = p.stringPropMap[p.APPELLATION]
    end
    if p.intPropMap[p.QILING_LEVEL] then
      roledata.modelInfo.model.extraMap[ModelInfo.QILING_LEVEL] = p.intPropMap[p.QILING_LEVEL]
    end
    if p.intPropMap[p.WING_COLOR_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.WING_COLOR_ID] = p.intPropMap[p.WING_COLOR_ID]
    end
    if p.intPropMap[p.ROLE_HAIR_COLOR_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.HAIR_COLOR_ID] = p.intPropMap[p.ROLE_HAIR_COLOR_ID]
    end
    if p.intPropMap[p.ROLE_CLOTH_COLOR_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.CLOTH_COLOR_ID] = p.intPropMap[p.ROLE_CLOTH_COLOR_ID]
    end
    if p.intPropMap[p.FASHION_DRESS_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.FASHION_DRESS_ID] = p.intPropMap[p.FASHION_DRESS_ID]
    end
    if p.intPropMap[p.QILING_EFFECT_LEVEL] then
      roledata.modelInfo.model.extraMap[ModelInfo.QILING_EFFECT_LEVEL] = p.intPropMap[p.QILING_EFFECT_LEVEL]
    end
    if p.intPropMap[p.MAGIC_MARK] then
      roledata.modelInfo.model.extraMap[ModelInfo.MAGIC_MARK] = p.intPropMap[p.MAGIC_MARK]
    end
    if p.intPropMap[p.MORAL_VALUE] then
      roledata.modelInfo.model.extraMap[ModelInfo.MORAL_VALUE] = p.intPropMap[p.MORAL_VALUE]
    end
    if p.intPropMap[p.CHANGE_MODEL_CARD_CFGID] then
      roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID] = p.intPropMap[p.CHANGE_MODEL_CARD_CFGID]
    end
    if p.intPropMap[p.CHANGE_MODEL_CARD_LEVEL] then
      roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_LEVEL] = p.intPropMap[p.CHANGE_MODEL_CARD_LEVEL]
    end
    if p.intPropMap[p.CHANGE_MODEL_CARD_MINI] then
      roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_MINI] = p.intPropMap[p.CHANGE_MODEL_CARD_MINI]
    end
    if p.intPropMap[p.AIRCRAFT_COLOR_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.AIRCRAFT_COLOR_ID] = p.intPropMap[p.AIRCRAFT_COLOR_ID]
    end
    if p.intPropMap[p.PET_MARK_CFG_ID] then
      roledata.modelInfo.model.extraMap[ModelInfo.PET_MARK_CFG_ID] = p.intPropMap[p.PET_MARK_CFG_ID]
    end
  end
  local changeId = p.intPropMap[p.EXTERIOR_ID]
  if roledata and changeId and changeId ~= roledata.modelInfo.model.extraMap[ModelInfo.EXTERIOR_ID] then
    roledata.modelInfo.model.extraMap[ModelInfo.EXTERIOR_ID] = changeId
    if changeId > 0 then
      if role then
        instance:ChangeRoleModel(role, changeId, 0, 0)
      end
    else
      instance:RecoverRoleModel(p.roleId)
    end
  end
  if role == nil then
    return
  end
  local followTarget
  if p.intPropMap[p.ROLE_MODEL_ID] then
    role:ChangeModel(p.intPropMap[p.ROLE_MODEL_ID])
  end
  if p.intPropMap[p.ROLE_VELOCITY] then
    role.runSpeed = p.intPropMap[p.ROLE_VELOCITY]
    local isCaptain = false
    if role.teamId then
      local team = instance.teamMap[role.teamId:tostring()]
      isCaptain = team and team.memberIds and team.memberIds[1] and role.roleId:eq(team.memberIds[1])
    end
    if isCaptain then
      instance:SetTeamSpeed(role.teamId, role.runSpeed)
    end
    local newPath, runpathCallback
    local movePath = role.movePath
    if movePath ~= nil then
      newPath = {}
      local pathIdx = role.pathIdx
      for i = #movePath - pathIdx + 1, #movePath do
        table.insert(newPath, movePath[i])
      end
      runpathCallback = role.runpathCallback
    end
    if newPath and role:IsInState(RoleState.RUN) and not role:IsInState(RoleState.FLY) then
      if isCaptain then
        instance:TeamMove(role.teamId, newPath)
      else
        role:RunPath(newPath, role.runSpeed, runpathCallback)
      end
    end
  end
  if p.intPropMap[p.MOUNTS_ID] then
    local mountsId = p.intPropMap[p.MOUNTS_ID]
    local newPath, runpathCallback
    local movePath = role.movePath
    if movePath ~= nil then
      newPath = {}
      local pathIdx = role.pathIdx
      for i = #movePath - pathIdx + 1, #movePath do
        table.insert(newPath, movePath[i])
      end
      runpathCallback = role.runpathCallback
    end
    if not role:IsInState(RoleState.FLY) then
      role:Stop()
    end
    if mountsId == 0 then
      role:UnMount()
    else
      local level = p.intPropMap[p.MOUNTS_RANK] or 1
      local colorId = p.intPropMap[p.MOUNTS_COLOR_ID] or roledata and roledata.modelInfo.model.extraMap[ModelInfo.MOUNTS_COLOR_ID] or 0
      role:SetMount(mountsId, level, colorId)
    end
    if not role:IsInState(RoleState.FLY) and newPath then
      role:RunPath(newPath, role.runSpeed, runpathCallback)
    end
  else
    if p.intPropMap[p.MOUNTS_COLOR_ID] then
      local colorId = p.intPropMap[p.MOUNTS_COLOR_ID]
      role:SetMountColor(colorId)
    end
    if p.intPropMap[p.MOUNTS_RANK] then
      local level = p.intPropMap[p.MOUNTS_RANK]
      role:SetMountLevel(level)
    end
  end
  local petModelId = p.intPropMap[p.PET_EXTERIOR_ID] or p.intPropMap[p.PET_MODEL_ID]
  if petModelId then
    local followTarget
    local petId = p.longPropMap[p.PET_ID]
    if petModelId > 0 and role.teamId == nil then
      local pet = role:GetPet()
      local pos = role.m_node2d.localPosition
      local dir = role:GetDir()
      local followPos = instance:GetFollowerPos(pos.x, pos.y, dir)
      local speed = role.runSpeed
      local color = role.m_uNameColor
      local showOrnament = p.intPropMap[p.PET_SHIPIN] ~= nil and 0 < p.intPropMap[p.PET_SHIPIN]
      local pet_name = ""
      if pet and pet.m_node2d then
        if 0 < pet.followIdx then
          followTarget = instance.followList[pet.followIdx].t
          instance:RoleStopFollow(pet)
        end
        followPos = pet.m_node2d.localPosition
        dir = pet:GetDir()
        color = pet.m_uNameColor
        pet_name = pet:GetName()
        if petId == nil then
          petId = pet.roleId
        end
        if petId and petId:eq(pet.roleId) then
          showOrnament = pet.showOrnament
        end
      end
      local petName = p.stringPropMap[p.PET_NAME] or pet_name
      if pet then
        role:RemovePet()
      end
      local model_outlook_id = p.intPropMap[p.OUTLOOK_ID]
      local pet_model_info = {modelid = petModelId}
      if model_outlook_id and model_outlook_id > 0 then
        pet_model_info.extraMap = {}
        pet_model_info.extraMap[ModelInfo.OUTLOOK_ID] = model_outlook_id
      end
      local newpet = instance:CreatePetModel(petId, pet_model_info, petName, followPos.x, followPos.y, dir, speed)
      role:AddPet(newpet)
      if newpet and role then
        local colorId = p.intPropMap[p.PET_EXTERIOR_COLOR_ID] or p.intPropMap[p.PET_COLOR_ID] or 0
        local colorcfg = GetModelColorCfg(colorId)
        if colorcfg ~= nil then
          newpet:SetColoration(colorcfg)
        end
        newpet.followSpeed = role.runSpeed
        instance:RoleFollow(newpet, role)
        newpet:SetShowModel(role.showModel)
        newpet:SetOrnament(showOrnament)
        local petMarkId = roledata.modelInfo.model.extraMap[ModelInfo.PET_MARK_CFG_ID]
        if petMarkId and petMarkId > 0 then
          local markcfg = require("Main.Pet.PetMark.PetMarkUtils").GetPetMarkCfg(petMarkId)
          if markcfg then
            newpet:SetMagicMark(markcfg.modelId)
          end
        end
      end
    else
      local pet = role:GetPet()
      if pet and pet.m_roleType == RoleType.PET then
        instance:RoleStopFollow(pet)
        role:RemovePet()
      end
    end
  end
  if p.intPropMap[p.WEAPON_MODEL_ID] and (not role:IsInState(RoleState.TRANSFORM) or roledata == nil or instance:CheckModelChangePart(role, roledata.modelInfo.model, ModelInfo.WEAPON)) then
    local weaponId = p.intPropMap[p.WEAPON_MODEL_ID]
    local lightLevel = p.intPropMap[p.QILING_LEVEL] or roledata and roledata.modelInfo.model.extraMap[ModelInfo.QILING_LEVEL] or 0
    local wushi_id = roledata.modelInfo.model.extraMap[ModelInfo.WUSHI_ID]
    if weaponId == 0 or wushi_id == nil or wushi_id == 0 then
      role:SetWeapon(weaponId, lightLevel)
    end
  end
  if p.intPropMap[p.WING_ID] and (not role:IsInState(RoleState.TRANSFORM) or roledata == nil or instance:CheckModelChangePart(role, roledata.modelInfo.model, ModelInfo.WING)) then
    local wingId = p.intPropMap[p.WING_ID]
    local wingDyeId = p.intPropMap[p.WING_COLOR_ID] or roledata and roledata.modelInfo.model.extraMap[ModelInfo.WING_COLOR_ID] or 0
    role:SetWing(wingId, wingDyeId)
  end
  if p.intPropMap[p.WING_COLOR_ID] and (not role:IsInState(RoleState.TRANSFORM) or roledata == nil or instance:CheckModelChangePart(role, roledata.modelInfo.model, ModelInfo.WING)) then
    local wingDyeId = p.intPropMap[p.WING_COLOR_ID] or 0
    role:SetWingColor(wingDyeId)
  end
  if p.intPropMap[p.FABAO_MODEL_ID] and (not role:IsInState(RoleState.TRANSFORM) or roledata == nil or instance:CheckModelChangePart(role, roledata.modelInfo.model, ModelInfo.FABAO)) then
    local fabaoId = p.intPropMap[p.FABAO_MODEL_ID]
    if fabaoId == 0 then
      fabaoId = roledata and roledata.modelInfo.model.extraMap[ModelInfo.FABAO_LINGQI] or 0
    end
    role:SetFabao(fabaoId)
  end
  if p.intPropMap[p.FABAO_LINGQI_MODEL_ID] and (not role:IsInState(RoleState.TRANSFORM) or roledata == nil or instance:CheckModelChangePart(role, roledata.modelInfo.model, ModelInfo.FABAO)) then
    local fabaoId = p.intPropMap[p.FABAO_LINGQI_MODEL_ID]
    if fabaoId == 0 then
      fabaoId = roledata and roledata.modelInfo.model.extraMap[ModelInfo.FABAO] or 0
    end
    role:SetFabao(fabaoId)
  end
  if p.intPropMap[p.AIRCRAFT_ID] and (not role:IsInState(RoleState.TRANSFORM) or roledata == nil or instance:CheckModelChangePart(role, roledata.modelInfo.model, ModelInfo.AIRCRAFT)) then
    local feijianId = p.intPropMap[p.AIRCRAFT_ID]
    local feijian_color = roledata.modelInfo.model.extraMap[ModelInfo.AIRCRAFT_COLOR_ID] or 0
    role:SetFeijianId(feijianId, feijian_color)
  end
  if p.intPropMap[p.AIRCRAFT_COLOR_ID] and p.intPropMap[p.AIRCRAFT_ID] == nil then
    local feijian_color = p.intPropMap[p.AIRCRAFT_COLOR_ID]
    role:SetFeijianColorId(feijian_color)
  end
  if p.intPropMap[p.TITLEID] then
    local titleID = p.intPropMap[p.TITLEID]
    local cfg = TitleInterface.GetTitleCfg(titleID)
    if cfg ~= nil then
      role:SetTitleIcon(cfg.picId)
    else
      role:SetTitleIcon(0)
    end
  end
  local appellationID = p.intPropMap[p.APPELLATIONID]
  local appellationName = p.stringPropMap[p.APPELLATION]
  if appellationID then
    if appellationID > 0 then
      local cfg = TitleInterface.GetAppellationCfg(appellationID)
      if cfg ~= nil then
        local color = GetColorData(cfg.appellationColor)
        if appellationName == nil then
          appellationName = roledata.modelInfo.string_props[MapModelInfo.APPELLATIONID]
        end
        if color and appellationName then
          role:SetTitleWithColor(appellationName, color)
        end
      else
        warn("Change Role Appellation error, invalid id: ", appellationID)
      end
    else
      role:SetTitle("")
    end
  elseif appellationName then
    role:SetTitle(appellationName)
  end
  if p.intPropMap[p.class.QILING_LEVEL] and (not role:IsInState(RoleState.TRANSFORM) or roledata == nil or instance:CheckModelChangePart(role, roledata.modelInfo.model, ModelInfo.WEAPON)) then
    local lv = p.intPropMap[p.class.QILING_LEVEL]
    role:SetWeaponColor(lv)
  end
  if p.intPropMap[p.WUSHI_ID] then
    local wushi_id = p.intPropMap[p.WUSHI_ID]
    if wushi_id > 0 then
      local DecorationMgr = require("Main.GodWeapon.DecorationMgr")
      local occupation = roledata.modelInfo.model.extraMap[ModelInfo.OCCUPATION]
      local gender = roledata.modelInfo.model.extraMap[ModelInfo.GENDER]
      local wushi_info = DecorationMgr.GetWuShiModelInfo(wushi_id, role.mModelId)
      role:SetWeaponModel(wushi_info)
    else
      role:SetWeaponModel(nil)
    end
  end
  if p.intPropMap[p.HUSONG_FOLLOW_MONSTER_ID] then
    local monCfgId = p.intPropMap[p.HUSONG_FOLLOW_MONSTER_ID]
    if monCfgId > 0 then
      instance:CreateEscortUnit(monCfgId, role)
    elseif role:GetPet() then
      role:RemovePet()
    end
  end
  if p.intPropMap[p.HUSONG_COUPLE_FLY_NPC_CFG_ID] then
    local npcId = p.intPropMap[p.HUSONG_COUPLE_FLY_NPC_CFG_ID]
    if npcId > 0 then
      local gender = p.intPropMap[p.GENDER]
      local passive = gender == GenderEnum.FEMALE
      local targetPos = role.movePath and role.movePath[#role.movePath]
      instance:CreateEscortHugUnit(npcId, role, true, passive, targetPos)
    else
      instance:StopHugEscort(role)
    end
  end
  if p.intPropMap[p.QILING_EFFECT_LEVEL] then
    local qiling_level = p.intPropMap[p.QILING_EFFECT_LEVEL]
    _G.SetModelLightEffect(role, qiling_level)
  end
  if not role:IsInState(RoleState.TRANSFORM) or _G.IsModelInModelChangeCostume(role) then
    local hairColorId = p.intPropMap[p.ROLE_HAIR_COLOR_ID]
    local clothesColorId = p.intPropMap[p.ROLE_CLOTH_COLOR_ID]
    local costumeId = p.intPropMap[p.FASHION_DRESS_ID]
    if costumeId then
      SetCostume(role, costumeId, hairColorId, clothesColorId)
    else
      _G.SetModelColor(role, hairColorId, clothesColorId)
    end
  end
  if p.intPropMap[p.CHANGE_MODEL_CARD_CFGID] then
    local shapeShiftCardId = p.intPropMap[p.CHANGE_MODEL_CARD_CFGID]
    local noBuff = roledata.modelInfo.model.extraMap[ModelInfo.EXTERIOR_ID] == nil or 0 >= roledata.modelInfo.model.extraMap[ModelInfo.EXTERIOR_ID]
    local mini = roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_MINI] or 0
    if shapeShiftCardId > 0 then
      local card_level = roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_LEVEL]
      if mini <= 0 then
        SetShapeShiftCardMiniIcon(role, 0)
        if noBuff then
          local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
          local shapeShift_cfg = TurnedCardUtils.GetChangeModelCardCfg(shapeShiftCardId)
          if shapeShift_cfg and role then
            local shapeShift_level_cfg = TurnedCardUtils.GetCardLevelCfg(shapeShiftCardId)
            local level_info = shapeShift_level_cfg.cardLevels[card_level]
            instance:ChangeRoleModel(role, shapeShift_cfg.changeModelId, 0, 0)
            role:SetOrnament(true)
            if 0 < level_info.dyeId then
              role.colorId = level_info.dyeId
              local colorcfg = GetModelColorCfg(level_info.dyeId)
              role:SetColoration(colorcfg)
            end
          end
        end
      else
        SetShapeShiftCardMiniIcon(role, shapeShiftCardId)
      end
    else
      roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_MINI] = nil
      roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_LEVEL] = nil
      roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID] = nil
      if mini > 0 then
        SetShapeShiftCardMiniIcon(role, 0)
      elseif noBuff then
        instance:RecoverRoleModel(p.roleId)
      end
    end
  end
  if p.intPropMap[p.CHANGE_MODEL_CARD_LEVEL] and p.intPropMap[p.CHANGE_MODEL_CARD_CFGID] == nil and (roledata.modelInfo.model.extraMap[ModelInfo.EXTERIOR_ID] == nil or 0 >= roledata.modelInfo.model.extraMap[ModelInfo.EXTERIOR_ID]) then
    local card_level = p.intPropMap[p.CHANGE_MODEL_CARD_LEVEL]
    local shapeShiftCardId = roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID]
    local mini = roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_MINI] or 0
    if mini <= 0 and shapeShiftCardId > 0 then
      local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
      local shapeShift_cfg = TurnedCardUtils.GetChangeModelCardCfg(shapeShiftCardId)
      if shapeShift_cfg and role then
        local shapeShift_level_cfg = TurnedCardUtils.GetCardLevelCfg(shapeShiftCardId)
        local level_info = shapeShift_level_cfg.cardLevels[card_level]
        if 0 < level_info.dyeId then
          role.colorId = level_info.dyeId
          local colorcfg = GetModelColorCfg(level_info.dyeId)
          role:SetColoration(colorcfg)
        end
      end
    end
  end
  if p.intPropMap[p.CHANGE_MODEL_CARD_MINI] and p.intPropMap[p.CHANGE_MODEL_CARD_CFGID] == nil then
    local mini = p.intPropMap[p.CHANGE_MODEL_CARD_MINI]
    local noBuff = roledata.modelInfo.model.extraMap[ModelInfo.EXTERIOR_ID] == nil or 0 >= roledata.modelInfo.model.extraMap[ModelInfo.EXTERIOR_ID]
    if mini > 0 then
      local pseudo_modelInfo = CloneModelInfo(roledata.modelInfo.model)
      pseudo_modelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID] = nil
      _G.RecoverRoleModelWithModelInfo(role, pseudo_modelInfo)
      local shapeShiftCardId = roledata.modelInfo.model.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID]
      SetShapeShiftCardMiniIcon(role, shapeShiftCardId)
    elseif noBuff then
      instance:RecoverRoleModel(p.roleId)
    else
      SetShapeShiftCardMiniIcon(role, 0)
    end
  end
  if p.intPropMap[p.PET_SHIPIN] then
    local pet = role:GetPet()
    if pet then
      pet:SetOrnament(0 < p.intPropMap[p.PET_SHIPIN])
    end
  end
  if p.intPropMap[p.PET_STAGE_LEVEL] then
    do
      local pet = role:GetPet()
      if pet then
        do
          local stage_level = p.intPropMap[p.PET_STAGE_LEVEL]
          if pet:IsInLoading() then
            pet:AddOnLoadCallback("PET_LIGHT_EFFECT", function()
              _G.SetPetLightEffect(pet, stage_level)
            end)
          else
            _G.SetPetLightEffect(pet, stage_level)
          end
        end
      end
    end
  end
  local magicMarkType = p.intPropMap[p.MAGIC_MARK]
  if magicMarkType then
    if magicMarkType > 0 then
      local magicMarkCfg = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):GetMagicMarkTypeCfg(magicMarkType)
      if magicMarkCfg then
        role:SetMagicMark(magicMarkCfg.modelId)
      end
    else
      role:SetMagicMark(0)
    end
  end
  local petMarkId = p.intPropMap[p.PET_MARK_CFG_ID]
  if petMarkId and role and role.pet then
    if petMarkId > 0 then
      local markcfg = require("Main.Pet.PetMark.PetMarkUtils").GetPetMarkCfg(petMarkId)
      role.pet:SetMagicMark(markcfg.modelId)
    else
      role.pet:SetMagicMark(0)
    end
  end
  local child_cfgId = p.intPropMap[p.CHILDREN_MODEL_ID]
  local child_costume = p.intPropMap[p.CHILDREN_FASHION]
  local child_id = p.longPropMap[p.CHILDREN_ID]
  local child_name = p.stringPropMap[p.CHILDREN_NAME]
  local child_weapon = p.intPropMap[p.CHILDREN_WEAPON_ID]
  if child_id then
    if child_id:eq(0) then
      local child_model = role:GetPet()
      if child_model and child_model.m_roleType == RoleType.CHILD then
        role:RemovePet()
      end
    elseif child_cfgId then
      do
        local child_model = role:GetPet()
        if child_model and child_model.m_roleType == RoleType.CHILD then
          local child_cfg = require("Main.Children.ChildrenUtils").GetChildrenCfgById(child_cfgId)
          if child_name then
            child_model:SetName(child_name, nil)
          end
          if child_model.mModelId ~= child_cfg.modelId then
            local pos = child_model:GetPos()
            local dir = child_model:GetDir()
            child_model:Destroy()
            child_model:Init(child_cfg.modelId)
            child_model:LoadCurrentModel(pos.x, pos.y, dir)
          end
          if child_model:IsInLoading() then
            child_model:AddOnLoadCallback("set_child_costume", function()
              _G.SetChildWeapon(child_model, child_weapon, 0)
              _G.SetChildCostume(child_model, child_cfgId, child_costume or 0)
            end)
          else
            _G.SetChildWeapon(child_model, child_weapon, 0)
            _G.SetChildCostume(child_model, child_cfgId, child_costume or 0)
          end
        else
          local child = require("Main.Children.Child").CreateWithCostumeAndWeapon(child_cfgId, child_costume or 0, child_weapon or 0)
          child:SetInstanceId(child_id)
          local pos = role.m_node2d.localPosition
          local dir = role:GetDir()
          local followPos = instance:GetFollowerPos(pos.x, pos.y, dir)
          child:LoadModel(child_name, GetColorData(701300007), followPos.x, followPos.y, dir, nil, nil)
          role:RemovePet()
          local child_model = child:GetModel()
          child_model:SetTouchable(false)
          if child_model then
            role:AddPet(child_model)
            child_model.followSpeed = role.runSpeed
            instance:RoleFollow(child_model, role)
            child_model:SetShowModel(role.showModel)
          end
        end
      end
    end
  elseif child_name then
    local child = role:GetPet()
    if child then
      child:SetName(child_name, nil)
    end
  elseif child_costume then
    local child = role:GetPet()
    if child then
      _G.SetChildCostume(child, child_cfgId, child_costume)
    end
  elseif child_weapon then
    local child = role:GetPet()
    if child then
      if child_weapon > 0 then
        _G.SetChildWeapon(child, child_weapon, 0)
      else
        _G.SetChildWeapon(child, 0, 0)
      end
    end
  end
  if p.intPropMap[p.MORAL_VALUE] then
    local moral = p.intPropMap[p.MORAL_VALUE]
    local namecolor = _G.GetWantedNameColor(moral)
    if namecolor > 0 then
      role:SetName("", GetColorData(namecolor))
    else
      role:SetName("", GetColorData(701300000))
    end
  end
  if isMe then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MODEL_CHANGED, nil)
  end
  return
end
def.method("table", "table", "number", "=>", "boolean").CheckModelChangePart = function(self, model, modelInfo, part)
  if modelInfo == nil then
    return true
  end
  local modelChangeCfgId = modelInfo.extraMap[ModelInfo.EXTERIOR_ID]
  if modelChangeCfgId == nil then
    modelChangeCfgId = model.costumeInfo and model.costumeInfo.modelChangeCfgId
  end
  if modelChangeCfgId == nil then
    return true
  end
  local cfg = GetModelChangeCfg(modelChangeCfgId)
  if cfg == nil then
    return true
  end
  if part == ModelInfo.WEAPON then
    return cfg.showOriginalWeapon
  elseif part == ModelInfo.WING then
    return cfg.showOriginalWing
  elseif part == ModelInfo.FABAO then
    return cfg.showOriginalFabao
  elseif part == ModelInfo.AIRCRAFT then
    return cfg.showOriginalAirCraft
  end
  return true
end
def.method("table", "number", "number", "number").ChangeRoleModel = function(self, role, modelChangeCfgId, hairColor, clothColor)
  if role == nil or role:IsDestroyed() then
    return
  end
  local roleId = role:tryget("roleId")
  if roleId == nil then
    return
  end
  local roledata = instance.invisiblePlayers[roleId:tostring()]
  _G.ChangeRoleModelWithModelInfo(role, roledata.modelInfo.model, modelChangeCfgId, hairColor, clothColor)
end
def.method("userdata").RecoverRoleModel = function(self, roleId)
  if roleId == nil then
    return
  end
  local roleIdStr = roleId:tostring()
  local role = self.rolesMap[roleIdStr]
  local roledata = self.invisiblePlayers[roleIdStr]
  if role == nil or roledata == nil then
    return
  end
  _G.RecoverRoleModelWithModelInfo(role, roledata.modelInfo.model)
end
def.method("number", "userdata", "string").ChangeNpcModel = function(self, npcId, roleId, newName)
  if self.npcMapToRole == nil then
    self.npcMapToRole = {}
  end
  self:RemoveNpc(npcId)
  local modelInfo = self:_GetRoleModelInfo(roleId)
  if modelInfo then
    local mapModelInfo = {
      string_props = {
        [MapModelInfo.NAME] = newName
      },
      int_props = {},
      model = modelInfo,
      velocity = 0
    }
    self.npcMapToRole[npcId] = {
      id = npcId,
      roleId = roleId,
      model = mapModelInfo,
      src = PubroleModule.NPC_CHANGE_MAP_SRC.CLIENT
    }
  else
    self:GetServerRoleModelInfo(roleId, function(pubModelInfo)
      local mapModelInfo = {
        string_props = {
          [MapModelInfo.NAME] = newName
        },
        int_props = {},
        model = pubModelInfo,
        velocity = 0
      }
      self.npcMapToRole[npcId] = {
        id = npcId,
        roleId = roleId,
        model = mapModelInfo,
        src = PubroleModule.NPC_CHANGE_MAP_SRC.CLIENT
      }
    end)
  end
end
def.method("number", "number", "number").SetNpcModelInfo = function(self, npcId, modelId, appearanceId)
  if self.npcChangeModelMap == nil then
    self.npcChangeModelMap = {}
  end
  self.npcChangeModelMap[npcId] = {
    id = npcId,
    modelId = modelId,
    appearanceId = appearanceId
  }
  self:RemoveNpc(npcId)
end
def.method("number").RemoveNpcModelInfo = function(self, npcId)
  if self.npcChangeModelMap == nil then
    return
  end
  self.npcChangeModelMap[npcId] = nil
  self:RemoveNpc(npcId)
end
def.method("number", "table").CreateEscortUnit = function(self, monCfgId, role)
  local pos = role.m_node2d.localPosition
  local dir = role:GetDir()
  local color = role.m_uNameColor
  local pet = role:GetPet()
  if pet then
    role:RemovePet()
  end
  local monsterCfg = PetInterface.GetMonsterCfg(monCfgId)
  local followPos = instance:GetFollowerPos(pos.x, pos.y, dir)
  pet = self:CreatePetModel(Int64.new(monCfgId), {
    modelid = monsterCfg.monsterModelId
  }, monsterCfg.name, followPos.x, followPos.y, dir, role.runSpeed)
  if pet then
    pet.followSpeed = role.runSpeed
    role:AddPet(pet)
    self:RoleFollow(pet, role)
  end
end
def.method("number", "table", "boolean", "boolean", "table").CreateEscortHugUnit = function(self, npcId, role, needPrepare, passive, targetPos)
  if role == nil then
    return
  end
  if role:IsInState(RoleState.TRANSFORM) then
    local modelInfo = self:GetRoleModelInfo(role.roleId)
    modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = 0
    modelInfo.extraMap[ModelInfo.EXTERIOR_ID] = 0
    modelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID] = nil
    _G.RecoverRoleModelWithModelInfo(role, modelInfo)
    if role:IsInLoading() then
      role:AddOnLoadCallback("CreateEscortHugUnit", function()
        GameUtil.AddGlobalTimer(0, true, function()
          self:CreateEscortHugUnit(npcId, role, needPrepare, passive, targetPos)
        end)
      end)
      return
    end
  end
  local pos = role.m_node2d.localPosition
  local dir = role:GetDir()
  local color = role.m_uNameColor
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local isMe = role.roleId:eq(heroModule.roleId)
  local pet = role:GetPet()
  if pet then
    pet:SetVisible(false)
  end
  local npccfg = NPCInterface.GetNPCCfg(npcId)
  local followPos = instance:GetFollowerPos(pos.x, pos.y, dir)
  local modelId = npccfg.monsterModelTableId
  local escortTarget
  if passive then
    escortTarget = ECPlayer.new(nil, role.mModelId, "", nil, RoleType.ROLE)
    local modelPath, modelColor = GetModelPath(role.mModelId)
    escortTarget.colorId = modelColor
    escortTarget:SetTouchable(false)
    local modelInfo = self:GetRoleModelInfo(role.roleId)
    modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = 0
    modelInfo.extraMap[ModelInfo.EXTERIOR_ID] = 0
    modelInfo.extraMap[ModelInfo.MAGIC_MARK] = 0
    modelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID] = nil
    _G.LoadModel(escortTarget, modelInfo, followPos.x, followPos.y, dir, false, false)
    escortTarget:SetName(npccfg.npcName, nil)
    local mountBackUp = role.mount
    local pet = role:GetPet()
    role:AddPet(nil)
    role:Destroy()
    role:Init(modelId)
    role:AddPet(pet)
    if mountBackUp then
      role:SetMount(mountBackUp.rideId, mountBackUp.level, mountBackUp.dyeId)
    end
    role:LoadCurrentModel(pos.x, pos.y, dir)
  else
    escortTarget = ECModel.new(modelId)
    escortTarget:SetName(npccfg.npcName, nil)
    local modelPath, modelColor = GetModelPath(modelId)
    escortTarget.colorId = modelColor
    escortTarget:LoadModel(modelPath, followPos.x, followPos.y, dir)
  end
  role:AddEscortTarget(escortTarget)
  local function DoHug()
    if role:IsDestroyed() then
      return
    end
    if escortTarget.m_model == nil then
      return
    end
    local strategy = role:GetOrCreateFlyStrategy()
    if strategy then
      strategy:FlyEscort(escortTarget, heroModule.escortTargetPos)
      return
    end
  end
  local function GetReady()
    if escortTarget:IsInLoading() then
      escortTarget:AddOnLoadCallback("hug", DoHug)
    else
      DoHug()
    end
  end
  local function Prepare()
    if needPrepare then
      if isMe then
        heroModule:_DoFlyUp(GetReady)
        heroModule:LockMove(true)
      else
        role:FlyUp(GetReady)
      end
    else
      role:FlyAt(pos.x, pos.y, GetReady)
    end
  end
  if role:IsInLoading() then
    role:AddOnLoadCallback("HugEscort", Prepare)
  else
    Prepare()
  end
end
def.method("table").StopHugEscort = function(self, role)
  if role == nil or role.escortTarget == nil then
    return
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local isMe = role.roleId:eq(heroModule.roleId)
  role:RemoveState(RoleState.HUG)
  local isdone = false
  local x, y = -1, -1
  local function OnFlyDown()
    if isdone then
      return
    end
    local huggedRole = role:Detach("hug")
    if huggedRole then
      huggedRole:Destroy()
    end
    local roledata = instance.invisiblePlayers[role.roleId:tostring()]
    local pos = role:GetPos()
    if x < 0 or y < 0 then
      x = pos.x
      y = pos.y
    end
    local dir = role:GetDir()
    local mountBackUp = role.mount
    local pet = role:GetPet()
    role:AddPet(nil)
    role:Destroy()
    role:Init(roledata.modelInfo.model.modelid)
    _G.LoadModel(role, roledata.modelInfo.model, x, y, dir, true, false)
    self:SetRoleStatus(role, roledata.modelInfo.role_status_list)
    if mountBackUp then
      role:SetMount(mountBackUp.rideId, mountBackUp.level, mountBackUp.dyeId)
    end
    isdone = true
    heroModule:LockMove(false)
    if pet then
      pet:SetPos(pos.x, pos.y)
      pet:SetVisible(true)
      role:AddPet(pet)
    end
  end
  x, y = role:FlyDown(OnFlyDown)
  if isMe then
    local landPos = require("netio.protocol.mzm.gsp.map.Location").new()
    landPos.x = x
    landPos.y = y
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.map.CLand").new(landPos))
    heroModule:LockMove(true)
  end
  GameUtil.AddGlobalTimer(2, true, function()
    if isdone or role == nil or role:IsDestroyed() then
      return
    end
    role:SetToGround()
    OnFlyDown()
  end)
end
def.method(ECPlayer, "=>", ECPlayer).GetFollower = function(self, target)
  for _, v in pairs(self.followList) do
    if v.t == target then
      return v.r
    end
  end
  return nil
end
def.method("userdata", ECPlayer).SetTeamNewModel = function(self, teamId, target)
  if teamId == nil or target == nil then
    return
  end
  local team = self.teamMap[teamId:tostring()]
  if team == nil then
    return
  end
  for k, v in pairs(team.members) do
    if v.roleId:eq(target.roleId) then
      team.members[k] = target
      return
    end
  end
end
def.method("userdata", "number").SetTeamSpeed = function(self, teamId, speed)
  if teamId == nil then
    return
  end
  local team = self.teamMap[teamId:tostring()]
  if team == nil or team.members == nil or #team.members < 2 then
    return
  end
  for _, member in pairs(team.members) do
    member.followSpeed = speed
  end
end
def.static("table").OnSSyncRoleNameChange = function(p)
  local role
  local roleId = p.roleId:tostring()
  if p.nameType == p.TYPE_ROLE then
    role = instance:GetRole(p.roleId)
  elseif p.nameType == p.TYPE_PET then
    local master = instance:GetRole(p.roleId)
    if master then
      role = master:GetPet()
      if role == nil then
        return
      end
    end
  end
  if role then
    role:SetName(p.name, role.m_uNameColor)
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.ROLE_NAME_CHANGED, {
      id = p.roleId,
      name = p.name,
      roletype = p.nameType
    })
  elseif instance.invisiblePlayers[roleId] then
    local roledata = instance.invisiblePlayers[roleId]
    roledata.modelInfo.string_props[MapModelInfo.NAME] = p.name
  else
    warn("[rolename change] role is nil for id: ", p.roleId:tostring())
  end
end
def.static("table").OnSNPCEnterView = function(p)
  local npcinfo = instance.NpcMapCfg[p.npcId]
  if npcinfo then
    npcinfo.isVisible = true
  end
  if instance.npcMapToRole and instance.npcMapToRole[p.npcId] and instance.npcMapToRole[p.npcId].src == PubroleModule.NPC_CHANGE_MAP_SRC.SERVER then
    instance.npcMapToRole[p.npcId] = nil
    if instance.npcMap[p.npcId] then
      instance:RemoveNpc(p.npcId)
    end
  end
end
def.method("number", "boolean").SetNpcDisable = function(self, npcid, disable)
  if self.disabledNpcList == nil then
    self.disabledNpcList = {}
  end
  if disable then
    self.disabledNpcList[npcid] = npcid
    self:RemoveNpc(npcid)
  else
    self.disabledNpcList[npcid] = nil
  end
end
def.method("number", "=>", "boolean").IsNpcDisabled = function(self, npcid)
  return self.disabledNpcList ~= nil and self.disabledNpcList[npcid] ~= nil
end
def.static("table", "table").OnSetNpcDisable = function(p1, p2)
  local npcId = p1 and p1.npcid
  local isShow = p1 and p1.show
  instance:SetNpcDisable(npcId, not isShow)
end
def.static("table", "table").OnSetNpcState = function(p1, p2)
  local npcId = p1 and p1.npcid
  if npcId == nil then
    return
  end
  local state = p1 and p1.state
  if instance.npcStateMap == nil then
    instance.npcStateMap = {}
  end
  instance.npcStateMap[npcId] = state
  local npc = instance:GetNpc(npcId)
  if npc then
    if state then
      npc:SetStanceValue(state)
    else
      local npccfg = NPCInterface.GetNPCCfg(npcId)
      if npccfg then
        npc:SetStanceValue(npccfg.npcState)
      end
    end
  end
end
def.method("table").CreateNpc = function(self, npcdata)
  if self.npcMap[npcdata.npcId] then
    return
  end
  local npccfg = NPCInterface.GetNPCCfg(npcdata.npcId)
  if npccfg == nil then
    warn("npc cfg is nil for npc id: ", npcdata.npcId)
    return
  end
  local color = GetColorData(701300007)
  if self.npcMapToRole and self.npcMapToRole[npcdata.npcId] then
    local modelInfo = self.npcMapToRole[npcdata.npcId].model
    if modelInfo then
      if modelInfo.string_props[MapModelInfo.NAME] == nil or modelInfo.string_props[MapModelInfo.NAME] == "" then
        modelInfo.string_props[MapModelInfo.NAME] = npccfg.npcName
      end
      self:AddRole(Int64.new(npcdata.npcId), modelInfo, npcdata.x, npcdata.y, npcdata.dir, color, RoleType.NPC)
    else
      return
    end
  else
    local npcModelInfo = self.npcChangeModelMap and self.npcChangeModelMap[npcdata.npcId]
    local npcModelId = npcModelInfo and npcModelInfo.modelId or npccfg.monsterModelTableId
    local npcAppearanceId = npcModelInfo and npcModelInfo.appearanceId or npccfg.outlookid
    local npc = self:AddNpc(npcdata.npcId, npcModelId, npccfg.npcName, npcdata.x, npcdata.y, npcdata.dir, 180, color, RoleType.NPC, npcAppearanceId)
    if npcdata.mapId then
      npc.displayMapId = npcdata.mapId
    end
    if npcdata.name then
      npc:SetName(npcdata.name, nil)
    end
  end
  self:CheckNpcStatus(npcdata.npcId)
  local npc = self.npcMap[npcdata.npcId]
  if npc == nil then
    return
  end
  npc.m_cfgId = npcdata.npcId
  npc:SetStanceValue(self.npcStateMap and self.npcStateMap[npcdata.npcId] or npccfg.npcState)
  npc:SetAutoTalk(npccfg.autoTalkList)
  if npccfg.npcTitle ~= "" then
    npc:SetTitleWithColor(npccfg.npcTitle, npc.m_titleColor)
  end
  if npccfg.dyeMode > 0 then
    local colorcfg = GetModelColorCfg(npccfg.dyeMode)
    npc:SetColoration(colorcfg)
  end
  if npccfg.isInAir then
    npc:SetFlyMode()
  end
end
local _usernpc_instanceid = 0
def.method("table", "=>", "table").CreateUserNpc = function(self, npcdata)
  local npcId = npcdata.npcId
  local npccfg = NPCInterface.GetNPCCfg(npcId)
  if npccfg == nil then
    warn("npc cfg is nil for npc id: ", npcId)
    return nil
  end
  local namecolor = npcdata.namecolor or 701300007
  local color = GetColorData(701300007)
  local npcrecord = self.npcMap[npcId]
  local npc = self:AddNpc(npcId, npccfg.monsterModelTableId, npccfg.npcName, npcdata.x, npcdata.y, npcdata.dir, 180, color, RoleType.NPC, npccfg.outlookid)
  self.npcMap[npcId] = npcrecord
  if npc == nil then
    return nil
  end
  if npcdata.mapId then
    npc.displayMapId = npcdata.mapId
  end
  if npcdata.name then
    npc:SetName(npcdata.name, nil)
  end
  local iconID = NPCInterface.Instance():GetNPCTitleIcon(npcId)
  if iconID and iconID > 0 then
    npc:SetTitleIcon(iconID)
  end
  npc.m_cfgId = npcId
  npc:SetStanceValue(npccfg.npcState)
  npc:SetAutoTalk(npccfg.autoTalkList)
  if npccfg.npcTitle ~= "" then
    npc:SetTitle(npccfg.npcTitle)
  end
  if 0 < npccfg.dyeMode then
    local colorcfg = GetModelColorCfg(npccfg.dyeMode)
    npc:SetColoration(colorcfg)
  end
  if npccfg.isInAir then
    npc:SetFlyMode()
  end
  npc.extraInfo = npcdata.extraInfo
  self:AddToUserNpcGroup(npc)
  return npc
end
def.method("table", "=>", "number").AddToUserNpcGroup = function(self, npc)
  _usernpc_instanceid = _usernpc_instanceid + 1
  self.userNpcMap[_usernpc_instanceid] = npc
  return _usernpc_instanceid
end
def.method("number", "=>", "table").RemoveFromUserNpcGroup = function(self, instanceid)
  local npc = self.userNpcMap[instanceid]
  self.userNpcMap[instanceid] = nil
  return npc
end
def.static("table").OnSModelNPCEnterView = function(p)
  local npc = instance.npcMap[p.npcId]
  if npc then
    npc:Destroy()
  end
  local npccfg = NPCInterface.GetNPCCfg(p.npcId)
  if npccfg == nil then
    warn("npc cfg is nil for npc id: ", p.npcId)
    return
  end
  local modelInfo = _G.UnmarshalBean(require("netio.protocol.mzm.gsp.map.NPCModelInfo"), p.modelInfo)
  local color = GetColorData(701300007)
  npc = instance:AddRole(Int64.new(p.npcId), modelInfo, p.posinit.curx, p.posinit.cury, p.posinit.direction * 45, color, RoleType.NPC)
  if npc == nil then
    return
  end
  npc.initModelInfo = modelInfo.model
  instance:CheckNpcStatus(p.npcId)
  if npccfg.npcTitle ~= "" then
    npc:SetTitleWithColor(npccfg.npcTitle, npc.m_titleColor)
  end
  local npcinfo = instance.NpcMapCfg[p.npcId]
  if npcinfo then
    npcinfo.isVisible = true
  end
  if instance.npcMapToRole == nil then
    instance.npcMapToRole = {}
  end
  instance.npcMapToRole[p.npcId] = {
    id = p.npcId,
    model = modelInfo,
    src = PubroleModule.NPC_CHANGE_MAP_SRC.SERVER
  }
end
def.static("table").OnSNPCLeaveView = function(p)
  local npcinfo = instance.NpcMapCfg[p.npcId]
  if npcinfo then
    npcinfo.isVisible = npcinfo.defaultVisible
    if not npcinfo.isVisible then
      instance:RemoveNpc(p.npcId)
    end
  else
    instance:RemoveNpc(p.npcId)
  end
end
def.static("table").OnSMapNpcStartMove = function(p)
  local role = instance.npcMap[p.npcId]
  if role then
    instance:RoleMove(role, p.targetLoc.x, p.targetLoc.y)
  end
end
def.static("table").OnSMapNpcStopMove = function(p)
  local role = instance.npcMap[p.npcId]
  if role then
    role:Stop()
  end
end
def.static("table").OnSMapMonsterStartMove = function(p)
  local role = instance.monsterMap[p.instanceId]
  if role then
    instance:RoleMove(role, p.targetLoc.x, p.targetLoc.y)
  end
end
def.static("table").OnSMapMonsterStopMove = function(p)
  local role = instance.monsterMap[p.instanceId]
  if role then
    role:Stop()
  end
end
def.static("table").OnSMapMonsterFightStart = function(p)
  local mon = instance.monsterMap[p.instanceid]
  if mon then
    mon:SetState(RoleState.BATTLE)
    local monCfg = instance:GetMonsterCfg(mon.m_cfgId)
    if monCfg and monCfg.valishType == require("consts.mzm.gsp.monster.confbean.VanishType").CLICK_HIDE then
      mon:SetVisible(false)
    else
      mon:SetBattleIcon(RESPATH.MODEL_BATTLE_ICON)
    end
  end
end
def.static("table").OnSMapMonsterFightEnd = function(p)
  local mon = instance.monsterMap[p.instanceid]
  if mon then
    mon:SetBattleIcon("")
    mon:RemoveState(RoleState.BATTLE)
    if not mon.m_visible then
      mon:SetVisible(true)
    end
  end
end
local MONSTER_CFG_LIFETIME = 10
def.method("number", "=>", "table").GetMonsterCfg = function(self, monsterCfgId)
  local cfg = instance.monsterCfgCache[monsterCfgId]
  if cfg then
    cfg.lifetime = MONSTER_CFG_LIFETIME
    return cfg
  end
  cfg = PetInterface.GetExplicitMonsterCfg(monsterCfgId)
  if cfg then
    cfg.lifetime = MONSTER_CFG_LIFETIME
    instance.monsterCfgCache[monsterCfgId] = cfg
    return cfg
  end
  return require("Main.Dungeon.DungeonUtils").GetDungeonMonsterCfg(monsterCfgId)
end
def.method("number").UpdateMonsterCfgCache = function(self, tick)
  if self.monsterCfgCache == nil then
    return
  end
  for k, v in pairs(self.monsterCfgCache) do
    v.lifetime = v.lifetime - tick
    if v.lifetime <= 0 then
      self.monsterCfgCache[k] = nil
    end
  end
end
def.static("table").OnSMonsterEnterView = function(p)
  if instance.monsterMap[p.monsterInstanceId] then
    return
  end
  local monsterCfg = instance:GetMonsterCfg(p.monsterId)
  if monsterCfg == nil then
    warn("monster cfg is nil for id: ", p.monsterId)
    return
  end
  if monsterCfg.isInAir then
    if instance.MonstersInAir == nil then
      instance.MonstersInAir = {}
    end
    instance.MonstersInAir[p.monsterInstanceId] = p
    local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
    if myRole == nil or not myRole:IsInState(RoleState.FLY) then
      return
    end
  end
  local color
  if p.isActive == 0 then
    color = GetColorData(701300006)
  else
    color = GetColorData(701300005)
  end
  local name = p.monsterName
  if name == nil or name == "" then
    name = monsterCfg.name
  end
  local monster = instance:AddNpc(p.monsterInstanceId, monsterCfg.modelId, name, p.posinit.curx, p.posinit.cury, p.posinit.direction, 180, color, RoleType.MONSTER, monsterCfg.modelFigureId)
  monster.m_cfgId = p.monsterId
  if monsterCfg.title and monsterCfg.title ~= "" then
    monster:SetTitle(monsterCfg.title)
  end
  monster:SetAutoTalk(monsterCfg.autoTalkList)
  if monsterCfg.modelColorId and 0 < monsterCfg.modelColorId then
    local colorcfg = GetModelColorCfg(monsterCfg.modelColorId)
    monster:SetColoration(colorcfg)
  end
  if monsterCfg.isInAir then
    monster:SetFlyMode()
  end
  if p.is_fighting == 1 then
    monster:SetState(RoleState.BATTLE)
    monster:SetBattleIcon(RESPATH.MODEL_BATTLE_ICON)
  end
  if p.posinit.curx ~= p.posinit.targetx or p.posinit.cury ~= p.posinit.targety then
    instance:RoleMove(monster, p.posinit.targetx, p.posinit.targety)
  end
  if instance.isPlayingCG or fightMgr.isInFight or instance.isOnlyShowSpecificRoles then
    monster:SetVisible(false)
  end
end
def.static("table").OnSMonsterLeaveView = function(p)
  instance:RemoveMonster(p.monsterInstanceId)
  if instance.MonstersInAir then
    instance.MonstersInAir[p.monsterInstanceId] = nil
  end
end
def.static("table").OnSSyncMonsterNameChange = function(p)
  local mon = instance.monsterMap[p.monsterInstanceId]
  if mon then
    mon:SetName(p.newName, nil)
  end
end
def.method("userdata", "table", "number", "number", "number", "userdata", "number", "=>", "table").CreateRole = function(self, _roleid, mapModelInfo, posx, posy, dir, nameColor, roleType)
  if _roleid == nil or mapModelInfo == nil then
    return nil
  end
  self.invisiblePlayers[_roleid:tostring()] = {
    modelInfo = mapModelInfo,
    pos = {x = posx, y = posy},
    dir = dir
  }
  return self:AddRole(_roleid, mapModelInfo, posx, posy, dir, nameColor, roleType)
end
def.method("userdata", "table", "number", "number", "number", "userdata", "number", "=>", "table").AddRole = function(self, _roleid, mapModelInfo, posx, posy, dir, nameColor, roleType)
  local roleId = _roleid:tostring()
  local role = self.rolesMap[roleId]
  if role then
    role:Destroy()
    role = nil
  end
  local name = mapModelInfo.string_props[MapModelInfo.NAME]
  local modelId = mapModelInfo.model.modelid
  local moral = mapModelInfo.model.extraMap[ModelInfo.MORAL_VALUE]
  if moral then
    local wanted_name_color = _G.GetWantedNameColor(moral)
    if wanted_name_color > 0 then
      nameColor = GetColorData(wanted_name_color)
    end
  end
  if roleType == RoleType.NPC then
    role = NpcModel.new(0, modelId, name, nameColor, roleType)
    role.roleId = _roleid
  else
    role = ECPlayer.new(_roleid, modelId, name, nameColor, roleType)
    role:SetBackupModelInfo({modelid = modelId})
  end
  _G.LoadModel(role, mapModelInfo.model, posx, posy, dir, false, false)
  if mapModelInfo.int_props[MapModelInfo.TITLEID] ~= nil then
    local titleID = mapModelInfo.int_props[MapModelInfo.TITLEID]
    local cfg = TitleInterface.GetTitleCfg(titleID)
    if cfg ~= nil then
      role:SetTitleIcon(cfg.picId)
    else
      role:SetTitleIcon(0)
    end
  end
  local appellationID = mapModelInfo.int_props[MapModelInfo.APPELLATIONID]
  if appellationID and appellationID > 0 then
    local cfg = TitleInterface.GetAppellationCfg(appellationID)
    if cfg ~= nil then
      local color = GetColorData(cfg.appellationColor)
      local appellationName = mapModelInfo.string_props[MapModelInfo.APPELLATION]
      if color and appellationName then
        role:SetTitleWithColor(appellationName, color)
      end
    end
  end
  local rideId = mapModelInfo.model.extraMap[ModelInfo.MOUNTS_ID]
  local rideColorId = mapModelInfo.model.extraMap[ModelInfo.MOUNTS_COLOR_ID] or 0
  local rideLevel = mapModelInfo.model.extraMap[ModelInfo.MOUNTS_RANK] or 1
  if rideId and rideId > 0 then
    role:SetMount(rideId, rideLevel, rideColorId)
  end
  if roleType == RoleType.ROLE then
    role.runSpeed = mapModelInfo.velocity
    self.rolesMap[roleId] = role
  elseif roleType == RoleType.NPC then
    role.runSpeed = 0
    self.npcMap[tonumber(roleId)] = role
  end
  self:SetRoleStatus(role, mapModelInfo.role_status_list)
  if self.isPlayingCG or fightMgr.isInFight or not self:IsOneOfSpecificRoles(roleId) or self.weddingScene and (self.weddingScene.groomInfo.roleId:eq(_roleid) or self.weddingScene.brideInfo.roleId:eq(_roleid)) then
    role:SetVisible(false)
  end
  self:ProcessAdditionInfo(role, mapModelInfo.protocol_octets_map)
  return role
end
def.method("table", "table").ProcessAdditionInfo = function(self, role, octetsMap)
  if octetsMap == nil then
    return
  end
  for k, v in pairs(octetsMap) do
    local func = ProtocolManager.GetProtocolStub(k)
    if func then
      local protoClass, callback = func()
      local protoObj = protoClass.new()
      if protoObj then
        Octets.unmarshalBean(v, protoObj)
        for _, f in ipairs(callback) do
          f(role, protoObj)
        end
      end
    else
      print("*LUA* Protocol NOT Registered", k)
    end
  end
end
def.static("table").OnSRoleExtraUpdateBrd = function(p)
  local role = instance:GetRole(p.roleid)
  if role == nil then
    return
  end
  local func = ProtocolManager.GetProtocolStub(p.extra_type)
  if func then
    local protoClass, callback = func()
    local protoObj = protoClass.new()
    if protoObj then
      Octets.unmarshalBean(p.extra_content, protoObj)
      for _, f in ipairs(callback) do
        f(role, protoObj)
      end
    end
  else
    print("*LUA* Protocol NOT Registered", p.extra_type)
  end
end
def.static("table").OnSRoleExtraRemoveBrd = function(p)
  local role = instance:GetRole(p.roleid)
  if role == nil then
    return
  end
  local func = ProtocolManager.GetProtocolStub(p.extra_type)
  if func then
    local protoClass, callback = func()
    for _, f in ipairs(callback) do
      f(role, nil)
    end
  else
    print("*LUA* Protocol NOT Registered", p.extra_type)
  end
end
def.method("number", "number", "string", "number", "number", "number", "number", "userdata", "number", "number", "=>", NpcModel).AddNpc = function(self, npcId, modelId, name, posx, posy, dir, speed, nameColor, roleType, appearanceId)
  local npc
  if roleType == RoleType.NPC then
    npc = self.npcMap[npcId]
  elseif roleType == RoleType.MONSTER then
    npc = self.monsterMap[npcId]
  end
  if npc then
    if not npc.m_visible then
      npc:SetVisible(true)
    end
    if not npc.showModel then
      npc:SetShowModel(true)
    end
    return npc
  end
  npc = NpcModel.new(npcId, modelId, name, nameColor, roleType)
  local modelPath, modelColor = GetModelPath(modelId)
  npc.colorId = modelColor
  npc:LoadModel(modelPath, posx, posy, dir)
  npc.runSpeed = speed
  if appearanceId > 0 then
    local appearanceCfg = GetAppearanceCfg(appearanceId)
    if 0 < appearanceCfg.weaponId then
      npc:SetWeapon(appearanceCfg.weaponId, 0)
    end
    if 0 < appearanceCfg.wingId then
      npc:SetWing(appearanceCfg.wingId, 0)
    end
    if 0 < appearanceCfg.flyMountId then
      npc:SetFeijianId(appearanceCfg.flyMountId, 0)
    end
    npc:SetOrnament(appearanceCfg.isShowDecorateItem)
    if appearanceCfg.scaleRate and appearanceCfg.scaleRate ~= 1 then
      npc:SetModelScaleValue(appearanceCfg.scaleRate)
    end
  end
  if roleType == RoleType.NPC then
    self.npcMap[npcId] = npc
  elseif roleType == RoleType.MONSTER then
    self.monsterMap[npcId] = npc
  end
  if self.isPlayingCG or fightMgr.isInFight or self.isOnlyShowSpecificRoles then
    npc:SetVisible(false)
  end
  return npc
end
def.method("number", "number", "string", "number", "number", "userdata", "=>", ItemModel).AddItem = function(self, _insanceid, modelId, name, posx, posy, nameColor)
  local item = self.itemMap[_insanceid]
  if item then
    item:SetVisible(true)
    return item
  end
  item = ItemModel.new(_insanceid, modelId, name, nameColor)
  local modelPath, modelColor = GetModelPath(modelId)
  item.colorId = modelColor
  item:LoadModel(modelPath, posx, posy, -180)
  self.itemMap[_insanceid] = item
  return item
end
def.method("userdata", "table", "string", "number", "number", "number", "number", "=>", ECPlayer).CreatePetModel = function(self, _roleid, modelInfo, name, posx, posy, dir, speed)
  local color = GetColorData(701300003)
  local modelId = modelInfo.modelid
  if modelInfo.extraMap and modelInfo.extraMap[ModelInfo.PET_EXTERIOR_ID] then
    modelId = modelInfo.extraMap[ModelInfo.PET_EXTERIOR_ID]
  end
  local pet = ECPlayer.new(_roleid, modelId, name, color, RoleType.PET)
  pet:SetTouchable(false)
  local modelPath, modelColor = GetModelPath(modelId)
  pet.colorId = modelColor
  pet:LoadModel(modelPath, posx, posy, dir)
  pet.runSpeed = speed
  pet.followSpeed = speed
  pet:LoadModelInfo(modelInfo)
  if modelColor > 0 then
    local clrCfg = GetModelColorCfg(modelColor)
    if clrCfg ~= nil then
      pet:SetColoration(clrCfg)
    end
  end
  if self.isPlayingCG or fightMgr.isInFight or self.isOnlyShowSpecificRoles then
    pet:SetVisible(false)
  end
  return pet
end
def.final("table", "table").ShowNpcFlag = function(p)
  local npcid = p[1]
  local npc = instance.npcMap[npcid]
  if npc then
    npc:SetTitleIcon(p[2])
  end
end
def.method("number").CheckNpcStatus = function(self, npcid)
  local iconID = NPCInterface.Instance():GetNPCTitleIcon(npcid)
  if iconID and iconID > 0 then
    local npc = instance.npcMap[npcid]
    if npc then
      npc:SetTitleIcon(iconID)
    end
  end
end
def.method("number", "=>", "table").GetNpcPos = function(self, roleid)
  local role = self.npcMap[roleid]
  if role ~= nil then
    return role:GetPos()
  end
  return nil
end
def.method("number", "=>", "table").GetMapItemPos = function(self, roleid)
  local role = self.itemMap[roleid]
  if role ~= nil then
    return role:GetPos()
  end
  return nil
end
def.method("number", "=>", "table", "boolean").GetMonsterPos = function(self, roleid)
  local role = self.monsterMap[roleid]
  local isInAir = self.MonstersInAir ~= nil and self.MonstersInAir[roleid] ~= nil or false
  if role ~= nil then
    return role:GetPos(), isInAir
  else
    return nil, false
  end
end
def.method("userdata", "=>", "table").GetRole = function(self, roleId)
  if roleId == nil then
    return nil
  end
  local role = self.rolesMap[roleId:tostring()]
  return role
end
def.method("string", "=>", "table").GetRoleByStr = function(self, roleIdStr)
  local role = self.rolesMap[roleIdStr]
  return role
end
def.method("userdata", "=>", "table").GetRolesInRoleView = function(self, roleid)
  local role = self.rolesMap[roleid:tostring()]
  local roles = {}
  for k, v in pairs(self.rolesMap) do
    if self:IsInView(v, role) then
      roles[k] = v
    end
  end
  return roles
end
def.method("table", "table", "=>", "boolean").IsInView = function(self, srcRole, targetRole)
  if srcRole == nil or targetRole == nil then
    return false
  end
  if srcRole == targetRole then
    return true
  end
  local src_pos = srcRole:GetPos()
  local target_pos = targetRole:GetPos()
  if src_pos == nil or target_pos == nil then
    return false
  end
  return math.pow(src_pos.x - target_pos.x, 2) + math.pow(src_pos.y - target_pos.y, 2) <= math.pow(PubroleModule.VIEW_RADIUS, 2)
end
def.method("table", "=>", "table").GetRolesWithinPos = function(self, pos)
  local roles = {}
  for k, v in pairs(self.rolesMap) do
    local real_role = v
    if v:IsInState(RoleState.PASSENGER) then
      real_role = self:GetPassengerMaster(v)
    end
    if self:IsInPosView(real_role, pos) then
      roles[k] = v
    end
  end
  return roles
end
def.method("table", "=>", "table").GetPassengerMaster = function(self, passenger)
  if passenger == nil or passenger.teamId == nil then
    return nil
  end
  local teamIdStr = passenger.teamId:tostring()
  local team = self.teamMap[teamIdStr]
  if team == nil or team.memberIds == nil then
    return nil
  end
  local leaderId = team.memberIds[1]
  if leaderId == nil then
    return nil
  end
  return self.rolesMap[leaderId:tostring()]
end
def.method("table", "table", "=>", "boolean").IsInPosView = function(self, role, target_pos)
  if target_pos == nil or role == nil then
    return false
  end
  local role_pos = role:GetPos()
  if role_pos == nil then
    return false
  end
  return math.pow(role_pos.x - target_pos.x, 2) + math.pow(role_pos.y - target_pos.y, 2) <= math.pow(PubroleModule.VIEW_RADIUS, 2)
end
def.method("number", "=>", "table").GetNpc = function(self, roleid)
  local role = self.npcMap[roleid]
  return role
end
def.method("number", "=>", "table").GetMapItem = function(self, roleid)
  local role = self.itemMap[roleid]
  return role
end
def.method("number", "=>", "table").GetMonster = function(self, roleid)
  local role = self.monsterMap[roleid]
  return role
end
def.method("number", "=>", "table").SelectOneMonsterByCfgId = function(self, cfgId)
  for k, v in pairs(self.monsterMap) do
    if v.m_cfgId == cfgId then
      return v
    end
  end
  return nil
end
def.method("number", "=>", "number").GetMonsterCfgId = function(self, instanceId)
  local mon = self.monsterMap[instanceId]
  if mon ~= nil then
    return mon.m_cfgId
  end
end
def.method("string").DestroyRole = function(self, strRoleID)
  self:RemoveRoleByString(strRoleID)
  self.invisiblePlayers[strRoleID] = nil
end
def.method("userdata").RemoveRole = function(self, longRoleID)
  local str = longRoleID:tostring()
  self:RemoveRoleByString(str)
end
def.method("string").RemoveRoleByString = function(self, strRoleID)
  local role = self.rolesMap[strRoleID]
  if role ~= nil then
    local pet = role:GetPet()
    if pet then
      instance:RoleStopFollow(pet)
    end
    self.followList[role.followIdx] = nil
    role:Destroy()
    self.rolesMap[strRoleID] = nil
    self.visiblePlayers[strRoleID] = nil
  end
end
def.method("number").RemoveNpc = function(self, npcid)
  local npc = self.npcMap[npcid]
  if npc ~= nil then
    npc:Destroy()
    self.npcMap[npcid] = nil
  end
end
def.method("number").RemoveItem = function(self, insanceid)
  local item = self.itemMap[insanceid]
  if item ~= nil then
    item:Destroy()
    self.itemMap[insanceid] = nil
  end
end
def.method("number").RemoveMonster = function(self, monid)
  local role = self.monsterMap[monid]
  if role ~= nil then
    role:Destroy()
    self.monsterMap[monid] = nil
  end
end
def.method("table", "number", "number").RoleMove = function(self, role, targetX, targetY)
  if role == nil or role.m_node2d == nil then
    return
  end
  local x, y, z = role.m_node2d:GetPosXYZ()
  if x == targetX and y == targetY then
    return
  end
  if not map_scene then
    map_scene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
  end
  local findpath = MapScene.FindPath(map_scene, x, y, targetX, targetY, 0)
  if findpath == nil or #findpath == 0 then
    return
  end
  self:RoleRunPath(role, findpath)
end
def.method("table", "table").RoleRunPath = function(self, role, pathNodes)
  if role == nil or pathNodes == nil or #pathNodes <= 0 then
    return
  end
  role:RunPath(pathNodes, role.runSpeed, nil)
  local pet = role:GetPet()
  if pet then
    local followPathNodes = instance:GetFollowMovePathNodes(pet, role)
    if followPathNodes then
      local follower = instance.followList[pet.followIdx]
      if follower then
        instance:FollowStart(follower.r, follower.t, followPathNodes)
      end
    end
  end
end
def.method("table", "table").RoleFly = function(self, role, pathNodes)
  local myId = GetMyRoleID()
  if role.roleId == nil or myId == nil or role.roleId == myId then
    return
  end
  local tarPos = pathNodes[#pathNodes]
  if tarPos then
    role:FlyTo(tarPos.x, tarPos.y, nil)
  end
end
def.static("table").OnSMapItemEnterView = function(p)
  local color = GetColorData(701300007)
  local mapItemCfg = require("Main.Map.MapItemModule").GetMapItemInfo(p.mapItemCfgId)
  if nil == mapItemCfg then
    return
  end
  local item = instance:AddItem(p.instanceId, mapItemCfg.modelId, mapItemCfg.name, p.loc.x, p.loc.y, color)
  item.m_cfgInfo = mapItemCfg
end
def.static("table").OnSMapItemLeaveView = function(p)
  instance:RemoveItem(p.instanceId)
end
def.method("table", "table").RoleFollow = function(self, role, target)
  if role == nil or target == nil then
    return
  end
  if role:IsInState(RoleState.PASSENGER) then
    return
  end
  self:SetFollowListData(role, target)
  if role:IsLoaded() then
    role:Stop()
  end
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if target:IsInState(RoleState.FLY) then
  elseif target.movePath ~= nil and #target.movePath > 0 then
    local pathlen = #target.movePath
    local followPath = {}
    for i = pathlen - target.pathIdx + 1, pathlen do
      table.insert(followPath, target.movePath[i])
    end
    role:RunPath(followPath, role.followSpeed, nil)
  else
    local tpos = target:GetPos()
    local rpos = role:GetPos()
    if tpos and not self:IsClose(role, target) then
      self:RoleMove(role, tpos.x, tpos.y)
    end
  end
end
def.method("table", "table").SetFollowListData = function(self, role, target)
  if role == nil or target == nil then
    return
  end
  role:SetState(RoleState.FOLLOW)
  local follow_data = self.followList[role.followIdx]
  if follow_data then
    follow_data.r = role
    follow_data.t = target
  else
    follow_data = {r = role, t = target}
    role.followIdx = #self.followList + 1
    self.followList[role.followIdx] = follow_data
  end
end
def.method("table").RoleStopFollow = function(self, role)
  if role == nil then
    return
  end
  role:Stop()
  role:RemoveState(RoleState.FOLLOW)
  self.followList[role.followIdx] = nil
  role.followIdx = 0
end
def.method("table").ResetRole = function(self, role)
  if role == nil then
    return
  end
  if role:IsInState(RoleState.FLY) then
    local feijianId = role:GetFeijianId()
    if feijianId <= 0 then
      role:FlyDown(nil)
    end
  else
    local pos = role:GetPos()
    if MapScene.IsBarrierXY(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, pos.x, pos.y) then
      local pt = MapScene.FindAdjacentValidPoint(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, pos.x, pos.y)
      if pt then
        role:SetPos(pt:x(), pt:y())
      end
    end
  end
end
def.method("number").Update = function(self, dt)
  self:UpdateModels(dt)
  self:FollowUpdate(dt)
  self:UpdateWedding(dt)
end
def.method("number").FollowUpdate = function(self, dt)
  self.followTime = self.followTime + dt
  if self.followTime < 0.1 then
    return
  end
  self.followTime = self.followTime - 0.1
  for _, v in pairs(self.followList) do
    local isLoading = v.r:IsInLoading() or v.t:IsInLoading()
    if (v.r == nil or v.r.m_model == nil or v.t == nil or v.t.m_model == nil) and not isLoading then
    elseif not isLoading then
      self:UpdateFollowStatus(v.r, v.t)
    end
  end
end
def.method("table", "table", "table").FollowStart = function(self, r, t, newPath)
  if r == nil or t == nil or newPath == nil then
    return
  end
  if r:IsInState(RoleState.FLY) or t:IsInState(RoleState.FLY) then
    return
  end
  r:RunPath(newPath, r.followSpeed, nil)
end
def.method("table", "table").UpdateFollowStatus = function(self, r, t)
  if r.m_model == nil or t.m_model == nil then
    return
  end
  if r:IsInState(RoleState.FLY) or t:IsInState(RoleState.FLY) or r.flyState ~= 0 or t.flyState ~= 0 then
    if r.flyState ~= t.flyState then
      local tarpos = t.flyPoint or t:GetPos()
      r:FollowFly(tarpos.x, tarpos.y, t)
    elseif r.flyState == ECPlayer.FlyState.Flight and t.flyState == ECPlayer.FlyState.Flight then
      if r.flyPoint == nil and t.flyPoint == nil then
        local rPos = r:GetPos()
        local tPos = t:GetPos()
        if not self:IsCloseInSky(rPos, tPos) then
          r:FollowFly(tPos.x, tPos.y, t)
        end
      elseif r.flyPoint ~= nil and t.flyPoint ~= nil and r.flyPoint.x == t.flyPoint.x and r.flyPoint.y == t.flyPoint.y then
        return
      else
        local rPos = r:GetPos()
        local tPos = t:GetPos()
        local isclose = self:IsCloseInSky(rPos, tPos)
        if isclose then
          local rForward = r:GetForward()
          local tForward = t:GetForward()
          if rForward and tForward then
            local angle = tForward:Angle(rForward)
            if angle < 90 and angle > -90 then
              r:Stop()
            end
          end
        else
          local tarPos = t.flyPoint or t:GetPos()
          r:FollowFly(tarPos.x, tarPos.y, t)
        end
      end
    end
  else
    if r.movePath == nil then
      return
    end
    if r.movePath and r.pathIdx == #r.movePath and not r:IsInState(RoleState.RUN) then
      r:RunPath(r.movePath, r.followSpeed, nil)
      return
    end
    local curPos = r:GetPos()
    local targetPos = t:GetPos()
    local r3dPos = r:Get3DPos()
    local t3dPos = t:Get3DPos()
    local rforward = r:GetForward()
    local tforward = t:GetForward()
    if curPos and targetPos and r3dPos and t3dPos and rforward and tforward then
      local forward = r3dPos - t3dPos
      local angle = tforward:Angle(rforward)
      local isclose = self:IsClose(r, t)
      if angle < 90 and angle > -90 and (isclose or rforward:Angle(forward) < 45) then
        r:Pause(true)
        if isclose and t.movePath == nil then
          r:Stop()
        end
      else
        r:Pause(false)
      end
    end
  end
end
def.method(ECPlayer, "boolean").SetTeamIcon = function(self, player, v)
  if v then
    player:SetTeamIcon(RESPATH.MODEL_TEAM_FULL_ICON)
  else
    player:SetTeamIcon(RESPATH.MODEL_TEAM_NOT_FULL_ICON)
  end
end
def.method("userdata", "=>", "number").GetTeamSize = function(self, teamId)
  if teamId == nil then
    return 0
  end
  local team = self.teamMap[teamId:tostring()]
  if team == nil then
    return 0
  end
  return team.memNum
end
def.method("userdata").ResetTeamNum = function(self, teamId)
  if teamId == nil then
    return
  end
  local team = self.teamMap[teamId:tostring()]
  if team == nil then
    return
  end
  local leader = team.members[1] or self.rolesMap[team.memberIds[1]:tostring()]
  if leader then
    leader:SetTeamNum(team.memNum)
  end
end
def.static("table").OnSMapTeamInfo = function(p)
  _G.IsMutilFrameLoadMap = false
  local teamIdStr = p.teamId:tostring()
  local leadId = p.teamLeader:tostring()
  if fightMgr.isInFight and instance.enterViewTeamsInFight then
    local teamdata = instance.enterViewTeamsInFight[teamIdStr]
    if teamdata then
      teamdata.memNum = p.memNum
      table.insert(teamdata.memberInfo, 1, teamdata.leaderInfo)
      table.insert(p.followerIds, 1, p.teamLeader)
      local newMemberInfo = {}
      for _, v in ipairs(p.followerIds) do
        for _, tm in pairs(teamdata.memberInfo) do
          if tm.roleId:eq(v) then
            table.insert(newMemberInfo, tm)
          end
        end
      end
      teamdata.memberInfo = newMemberInfo
      return
    end
  end
  local team = instance.teamMap[teamIdStr]
  local oldleader = team and team.members and team.members[1]
  if oldleader then
    oldleader:DetachAllFromMount()
  end
  if team == nil then
    team = {}
    instance.teamMap[teamIdStr] = team
  end
  team.teamId = p.teamId
  if team.memberIds == nil then
    team.memberIds = {}
  end
  team.memNum = p.memNum
  team.memberIds[1] = p.teamLeader
  for i = 2, 5 do
    team.memberIds[i] = p.followerIds[i - 1]
  end
  if team.members == nil then
    team.members = {}
  end
  for i = 2, 5 do
    local memberId = team.memberIds[i]
    if memberId then
      team.members[i] = instance.rolesMap[memberId:tostring()]
    else
      team.members[i] = nil
    end
  end
  local mountSeatMap = {}
  for i = 2, #p.multiMountsRoleList do
    local rid = p.multiMountsRoleList[i]
    if rid and not rid:eq(-1) then
      mountSeatMap[i] = rid:tostring()
    end
  end
  team.mountSeatMap = mountSeatMap
  instance:UpdateMapTeam(team.teamId)
end
def.method("userdata").UpdateMapTeam = function(self, teamId)
  if teamId == nil then
    return
  end
  local team = instance.teamMap[teamId:tostring()]
  if team == nil then
    return
  end
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local isInMyTeam = false
  local myTeamId = TeamData.Instance().teamId
  local leaderId = team.memberIds[1]
  if leaderId == nil then
    return
  end
  local leaderIdStr = leaderId:tostring()
  if myTeamId then
    isInMyTeam = teamId:eq(myTeamId)
  elseif heroMgr.roleId then
    for _, member_id in pairs(team.memberIds) do
      if heroMgr.roleId:eq(member_id) then
        isInMyTeam = true
        break
      end
    end
  end
  local leader = instance.rolesMap[leaderIdStr]
  if leader == nil then
    if not isInMyTeam then
      local count = table.nums(instance.visiblePlayers)
      if count >= instance.max_visible_players_num then
        return
      end
    end
    if instance.invisiblePlayers[leaderIdStr] then
      leader = instance:CreateRoleModel(instance.invisiblePlayers[leaderIdStr])
      instance.visiblePlayers[leaderIdStr] = leader
    end
  end
  if leader == nil then
    return
  end
  local isFlying = not leader:IsOnGround()
  team.members[1] = leader
  for i = 2, 5 do
    team.members[i] = nil
  end
  if leader:GetPet() then
    instance:RoleStopFollow(leader:GetPet())
    leader:RemovePet()
  end
  if leader.followIdx > 0 then
    instance:RoleStopFollow(leader)
  end
  leader:SetTeamNum(team.memNum)
  leader:SetTeamId(team.teamId)
  if leaderId:eq(heroMgr:GetMyRoleId()) then
    instance:ResetRole(heroMgr.myRole)
  else
    instance:ResetRole(leader)
  end
  instance:SetTeamIcon(leader, team.memNum == 5)
  local target = leader
  if isInMyTeam then
    for i = 2, 5 do
      local member_id = team.memberIds[i]
      if member_id then
        if heroMgr.roleId and member_id:eq(heroMgr.roleId) then
          XunluTip.HideXunlu()
          if heroMgr:IsPatroling() then
            heroMgr:StopPatroling()
          end
          if not leader.showModel then
            leader:SetShowModel(true)
          end
        end
        local memberIdStr = member_id:tostring()
        local member = instance.rolesMap[memberIdStr]
        if member == nil then
          local roleData = instance.invisiblePlayers[memberIdStr]
          if roleData then
            local tarPos = target:GetPos()
            roleData.pos = instance:GetFollowerPos(tarPos.x, tarPos.y, target:GetDir())
            member = instance:CreateRoleModel(roleData)
            if member.showModel ~= leader.showModel then
              member:SetShowModel(leader.showModel)
            end
          end
        end
        table.insert(team.members, member)
        if member ~= nil then
          member:SetTeamId(team.teamId)
          member.followSpeed = leader.runSpeed
          member:SetTeamIcon("")
          local pet = member:GetPet()
          if pet then
            instance:RoleStopFollow(pet)
            member:RemovePet()
          end
          instance.visiblePlayers[memberIdStr] = member
          local index = table.keyof(team.mountSeatMap, memberIdStr)
          if index == nil or isFlying then
            instance:RoleFollow(member, target)
            target = member
          else
            instance:RoleStopFollow(member)
            leader:AttachToMount(member, index)
          end
        end
      end
    end
  else
    target = leader
    for i = 2, 5 do
      local memberId = team.memberIds[i]
      if memberId then
        local memberIdStr = memberId:tostring()
        if fightMgr.isInFight then
          if instance.enterViewRolesInFight then
            instance.enterViewRolesInFight[memberIdStr] = nil
          end
          instance:RemoveRoleByString(memberIdStr)
        else
          local index = table.keyof(team.mountSeatMap, memberIdStr)
          local member = instance.rolesMap[memberIdStr]
          if member == nil and index then
            local roleData = instance.invisiblePlayers[memberIdStr]
            if roleData then
              local tarPos = leader:GetPos()
              roleData.pos = tarPos
              member = instance:CreateRoleModel(roleData)
            end
          end
          if member then
            member:SetTeamId(team.teamId)
            member:SetTeamIcon("")
            member.followSpeed = leader.runSpeed
            team.members[i] = member
            instance.visiblePlayers[memberIdStr] = member
            if index == nil or isFlying then
              instance:RoleFollow(member, target)
              target = member
            else
              instance:RoleStopFollow(member)
              leader:AttachToMount(member, index)
            end
          end
        end
      end
    end
  end
end
def.method("userdata", "boolean").ResetTeamFollowList = function(self, teamId, isUp)
  if teamId == nil then
    return
  end
  local team = self.teamMap[teamId:tostring()]
  if team == nil then
    return
  end
  if isUp then
    local leader = team.members and team.members[1]
    if leader then
      leader:DetachAllFromMount()
    end
    local target = leader
    for i = 2, 5 do
      local memberId = team.memberIds[i]
      if memberId then
        local memberIdStr = memberId:tostring()
        local member = self.rolesMap[memberIdStr]
        if member then
          self:SetFollowListData(member, target)
          target = member
        end
      end
    end
  else
    local isOnGround = true
    for _, m in pairs(team.members) do
      if not m:IsOnGround() then
        isOnGround = false
        break
      end
    end
    if isOnGround then
      self:UpdateMapTeam(teamId)
    end
  end
end
def.static("table").OnSMapTeamEnterView = function(p)
  local teamId = p.teamId:tostring()
  local myTeamId = TeamData.Instance().teamId
  local isInMyTeam = false
  if myTeamId then
    isInMyTeam = p.teamId:eq(myTeamId)
  end
  if not isInMyTeam and fightMgr.isInFight then
    if instance.enterViewTeamsInFight == nil then
      instance.enterViewTeamsInFight = {}
    end
    instance.enterViewTeamsInFight[teamId] = p
    return
  end
  local finalPos = p.curPos
  if #p.keyPointPath > 0 then
    finalPos = p.keyPointPath[#p.keyPointPath]
  end
  local leaderIdStr = p.leaderInfo.roleId:tostring()
  local leaderModelInfo = GetModelInfo(p.leaderInfo.modelInfo)
  instance.invisiblePlayers[leaderIdStr] = {
    modelInfo = leaderModelInfo,
    pos = finalPos,
    dir = p.direction,
    teamId = p.teamId
  }
  for i = 1, #p.memberInfo do
    local memberModelInfo = GetModelInfo(p.memberInfo[i].modelInfo)
    instance.invisiblePlayers[p.memberInfo[i].roleId:tostring()] = {
      modelInfo = memberModelInfo,
      pos = finalPos,
      dir = p.direction,
      teamId = p.teamId
    }
  end
  local team = {}
  instance.teamMap[teamId] = team
  team.members = {}
  team.memberIds = {}
  team.teamId = p.teamId
  table.insert(team.memberIds, p.leaderInfo.roleId)
  for i = 1, #p.memberInfo do
    table.insert(team.memberIds, p.memberInfo[i].roleId)
  end
  team.memNum = p.memNum
  local mountSeatMap = {}
  for i = 2, #p.multiMountsRoleList do
    local rid = p.multiMountsRoleList[i]
    if rid and not rid:eq(-1) then
      mountSeatMap[i] = rid:tostring()
    end
  end
  team.mountSeatMap = mountSeatMap
  if not isInMyTeam then
    local count = table.nums(instance.visiblePlayers)
    if count >= instance.max_visible_players_num or fightMgr.isInFight then
      return
    end
  end
  local leader = instance.rolesMap[leaderIdStr]
  if leader == nil then
    local name = leaderModelInfo.string_props[MapModelInfo.NAME]
    local namecolor = GetColorData(701300000)
    if p.curPos then
      leader = instance:AddRole(p.leaderInfo.roleId, leaderModelInfo, p.curPos.x, p.curPos.y, p.direction, namecolor, RoleType.ROLE)
    end
  else
    local curpos = leader:GetPos()
    p.curPos.x = curpos.x
    p.curPos.y = curpos.y
  end
  if leader == nil then
    return
  end
  instance.visiblePlayers[leaderIdStr] = leader
  leader:SetShowModel(instance:IsShowOtherPlayers())
  leader:SetTeamId(p.teamId)
  team.members[1] = leader
  instance:SetTeamIcon(leader, p.memNum == 5)
  local isFlying = instance:CheckState(leaderModelInfo.role_status_list, ROLE_SERVER_STATUS.STATUS_FLY)
  if isFlying then
    leader:FlyAt(p.curPos.x, p.curPos.y, nil)
  elseif 1 < #p.multiMountsRoleList then
    for index, rid in pairs(mountSeatMap) do
      local member = instance.rolesMap[rid]
      if member == nil then
        local tarPos = leader:GetPos()
        local roledata = instance.invisiblePlayers[rid]
        if roledata then
          roledata.pos = instance:GetFollowerPos(tarPos.x, tarPos.y, leader:GetDir())
          member = instance:CreateRoleModel(roledata)
          if member.showModel ~= leader.showModel then
            member:SetShowModel(leader.showModel)
          end
          table.insert(team.members, member)
        end
      end
      if member then
        instance.visiblePlayers[rid] = member
        leader:AttachToMount(member, index)
      end
    end
  end
  if isInMyTeam then
    local i = 1
    local target = leader
    for i = 2, 5 do
      team.members[i] = nil
    end
    for i = 1, #p.memberInfo do
      local strMemberRoleID = p.memberInfo[i].roleId:tostring()
      local member = instance.rolesMap[strMemberRoleID]
      if member == nil then
        local tarPos = target:GetPos()
        local roledata = instance.invisiblePlayers[strMemberRoleID]
        if roledata then
          roledata.pos = instance:GetFollowerPos(tarPos.x, tarPos.y, target:GetDir())
          member = instance:CreateRoleModel(roledata)
        end
      end
      if member ~= nil then
        member:SetTeamId(p.teamId)
        member.followSpeed = leader.runSpeed
        member:SetTeamIcon("")
        if isFlying or not member:IsInState(RoleState.PASSENGER) then
          instance:RoleFollow(member, target)
          target = member
        end
        if member.showModel ~= leader.showModel then
          member:SetShowModel(leader.showModel)
        end
        instance.visiblePlayers[member.roleId:tostring()] = member.showModel and member or nil
      end
      table.insert(team.members, member)
    end
  end
  if p.keyPointPath and #p.keyPointPath > 0 then
    if leader:IsInLoading() then
      leader:AddOnLoadCallback("Team_EnterView_Move", function()
        instance:TeamMove(p.teamId, p.keyPointPath)
      end)
    else
      instance:TeamMove(p.teamId, p.keyPointPath)
    end
  end
end
def.method("table", "=>", "table").CreateRoleModel = function(self, roledata)
  if roledata == nil or roledata.modelInfo == nil then
    return nil
  end
  if roledata.pos == nil then
    roledata.pos = {x = 0, y = 0}
  end
  if roledata.dir == nil then
    roledata.dir = Default_Role_Dir
  end
  local color = GetColorData(701300000)
  local role = instance:AddRole(roledata.modelInfo.id, roledata.modelInfo, roledata.pos.x, roledata.pos.y, roledata.dir, color, RoleType.ROLE)
  if role and roledata.petModelInfo then
    self:ShowOtherModel(role, roledata.petModelInfo)
  end
  return role
end
def.static("table").OnSMapTeamTransferPos = function(p)
  local mapMgr = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local team = instance.teamMap[p.teamId:tostring()]
  if team then
    local isSameMap = false
    if mapMgr.mapInstanceId ~= p.mapInstanceId then
      instance:RemoveAllMapRoles(false, team.memberIds)
      mapMgr.mapInstanceId = p.mapInstanceId
      Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_INSTANCE_CHANGED, {
        lastMapId = mapMgr:GetMapId(),
        mapId = p.mapId
      })
    else
      isSameMap = true
    end
    _G.IsMutilFrameLoadMap = false
    if p.mapId ~= mapMgr:GetMapId() then
      mapMgr:LoadMap(p.mapId)
    end
    if heroMgr:IsPatroling() then
      heroMgr:StopPatroling()
    end
    if heroMgr.myRole.roleId:eq(team.memberIds[1]) then
      instance.changemap_target_pos = p.targetPos
    end
    if p.pos.x > mapMgr.map_w or p.pos.y > mapMgr.map_h or MapScene.IsBarrierXY(p.pos.x, p.pos.y) then
      Debug.LogWarning(string.format("[SMapTeamTransferPos]Invalid map pos: %d %d", p.pos.x, p.pos.y))
    end
    local fly = false
    if team.members == nil then
      team.members = {}
    end
    for i = 1, 5 do
      local memberId = team.memberIds[i]
      if memberId then
        local role = team.members[i]
        if role == nil then
          role = instance.rolesMap[memberId:tostring()]
          team.members[i] = role
        end
        if role then
          if i == 1 then
            fly = role:IsInState(RoleState.FLY)
          end
          role:Stop()
          if fly then
            role:FlyAt(p.pos.x, p.pos.y, nil)
          elseif not role:IsInState(RoleState.PASSENGER) then
            role:SetPos(p.pos.x, p.pos.y)
          end
        end
      end
    end
    XunluTip.HideXunlu()
    Camera2D.SetFocus(p.pos.x, p.pos.y)
    if isSameMap then
      local filter = {}
      local memberId
      for i = 1, #team.memberIds do
        memberId = team.memberIds[i]
        if memberId then
          filter[memberId:tostring()] = true
        end
      end
      instance:RemoveOtherPlayers(p.pos, filter)
    end
  else
    Debug.LogWarning("[SMapTeamTransferPos]team not found: " .. p.teamId:tostring())
  end
end
def.static("table").OnSMapTeamSyncPos = function(p)
  local teamIdStr = p.teamId:tostring()
  if fightMgr.isInFight and instance.enterViewTeamsInFight then
    local teamdata = instance.enterViewTeamsInFight[teamIdStr]
    if teamdata and #p.keyPointPath > 0 then
      teamdata.curPos = p.keyPointPath[#p.keyPointPath]
      teamdata.keyPointPath = {}
      return
    end
  end
  local mapMgr = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local myteamId = heroMgr.myRole and heroMgr.myRole.teamId
  if myteamId and p.teamId:eq(myteamId) then
    mapMgr.mapInstanceId = p.mapInstanceId
  end
  if p.mapId ~= mapMgr:GetMapId() then
    return
  end
  local team = instance.teamMap[teamIdStr]
  if team == nil then
    return
  end
  instance:TeamMove(p.teamId, p.keyPointPath)
end
def.method("userdata", "table").TeamMove = function(self, teamId, pathNodes)
  if teamId == nil then
    return
  end
  if pathNodes == nil or #pathNodes == 0 then
    return
  end
  local team = self.teamMap[teamId:tostring()]
  if team == nil or team.members == nil then
    return
  end
  local leader = team.members[1]
  if leader == nil then
    local leaderId = team.memberIds[1]
    if leaderId then
      local roledata = self.invisiblePlayers[leaderId:tostring()]
      if roledata then
        local finalpos = pathNodes[#pathNodes]
        if finalpos then
          if roledata.pos == nil then
            roledata.pos = {}
          end
          roledata.pos.x = finalpos.x
          roledata.pos.y = finalpos.y
        end
      end
    end
    return
  end
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if leader:IsInState(RoleState.FLY) then
    self:RoleFly(leader, pathNodes)
  else
    self:RoleRunPath(leader, pathNodes)
  end
  if leader.movePath == nil or leader:IsInState(RoleState.FLY) then
    return
  end
  for k, member in pairs(team.members) do
    if k > 1 then
      if heroMgr.roleId and member.roleId:eq(heroMgr.roleId) then
        XunluTip.HideXunlu()
        if heroMgr:IsPatroling() then
          heroMgr:StopPatroling()
        end
      end
      local followPathNodes = self:GetFollowMovePathNodes(member, leader)
      local follower = self.followList[member.followIdx]
      if follower then
        member:StopAnimAndCallback()
        self:FollowStart(follower.r, follower.t, followPathNodes)
      else
        member:CleanAnimCallback()
      end
    end
  end
end
def.method("userdata", "number", "number").TeamMoveToPos = function(self, teamId, x, y)
  if teamId == nil then
    return
  end
  local team = self.teamMap[teamId:tostring()]
  if team == nil then
    return
  end
  local leader = team.members[1]
  if leader == nil then
    return
  end
  self:RoleMove(leader, x, y)
  if leader.movePath == nil or leader:IsInState(RoleState.FLY) then
    return
  end
  for k, member in pairs(team.members) do
    if k > 1 then
      local followPathNodes = self:GetFollowMovePathNodes(member, leader)
      local follower = self.followList[member.followIdx]
      if follower then
        self:FollowStart(follower.r, follower.t, followPathNodes)
      end
    end
  end
end
def.static("table").OnSMapTeamLeaveView = function(p)
  local teamIdStr = p.teamId:tostring()
  local team = instance.teamMap[teamIdStr]
  if team then
    local leader = team.members and team.members[1]
    if leader then
      leader:DetachAllFromMount()
    end
    for _, memberId in pairs(team.memberIds) do
      instance:DestroyRole(memberId:tostring())
    end
  end
  instance.teamMap[teamIdStr] = nil
  if instance.enterViewTeamsInFight then
    instance.enterViewTeamsInFight[teamIdStr] = nil
  end
end
def.static("table").OnSMapLeaveTeam = function(p)
  if fightMgr.isInFight and instance.enterViewTeamsInFight then
    local teamdata = instance.enterViewTeamsInFight[teamId]
    if teamdata then
      local memberInfo
      if teamdata.leaderInfo.roleId:eq(p.roleid) then
        memberInfo = teamdata.leaderInfo
      else
        for _, v in pairs(teamdata.memberInfo) do
          if p.roleid:eq(v.roleId) then
            memberInfo = v
          end
        end
      end
      if memberInfo then
        local petdata = memberInfo.models[memberInfo.KEY_PET]
        local petModelInfo = petdata and GetModelInfo(petdata)
        instance.invisiblePlayers[memberInfo.roleId:tostring()] = {
          modelInfo = memberInfo.modelInfo,
          pos = teamdata.curPos,
          dir = teamdata.direction,
          petModelInfo = petModelInfo
        }
      end
      if fightMgr.isInFight and memberInfo then
        if instance.enterViewRolesInFight == nil then
          instance.enterViewRolesInFight = {}
        end
        instance.enterViewRolesInFight[roleId] = memberInfo.roleId
      end
      return
    end
  end
  local team = instance.teamMap[p.teamId:tostring()]
  if team and team.memberIds and p.roleid:eq(team.memberIds[1]) then
    local roleIdStr = p.roleid:tostring()
    local leader = instance.rolesMap[roleIdStr]
    if leader then
      leader:DetachAllFromMount()
    end
  end
  local idx = 0
  if team then
    if team.memberIds and #team.memberIds > 0 then
      for k, v in pairs(team.memberIds) do
        if v:eq(p.roleid) then
          idx = k
          break
        end
      end
      if idx > 0 then
        table.remove(team.memberIds, idx)
      end
    end
    idx = 0
    if team.members and 0 < #team.members then
      for k, v in pairs(team.members) do
        if v.roleId:eq(p.roleid) then
          idx = k
          break
        end
      end
      if idx > 0 then
        table.remove(team.members, idx)
      end
    end
  end
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local myId = heroMgr:GetMyRoleId()
  if myId and p.roleid:eq(myId) then
    instance:RoleStopFollow(heroMgr.myRole)
    heroMgr.myRole:SetTeamIcon("")
    heroMgr.myRole:SetTeamId(nil)
    XunluTip.HideXunlu()
    NPCInterface.Instance():SetTargetNPCID(0)
    if heroMgr:IsPatroling() then
      heroMgr:StopPatroling()
    end
    instance:ResetRole(heroMgr.myRole)
  else
    local roleIdStr = p.roleid:tostring()
    local roledata = instance.invisiblePlayers[roleIdStr]
    if roledata and roledata.teamId then
      if team and team.members and 0 < #team.members then
        local leader = team.members[1]
        roledata.pos = leader and leader:GetPos()
      end
      roledata.teamId = nil
    end
    local role = instance.rolesMap[roleIdStr]
    if role ~= nil or not roledata or fightMgr.isInFight then
    else
      local count = table.nums(instance.visiblePlayers)
      if count < instance.max_visible_players_num then
        role = instance:CreateRoleModel(roledata)
      end
    end
    if role then
      instance:RoleStopFollow(role)
      role:SetTeamIcon("")
      role:SetTeamId(nil)
      instance:ResetRole(role)
    end
  end
end
def.static("table").OnSMapTeamDismiss = function(p)
  require("ProxySDK.ECApollo").DestroyVoipGuidPanel()
  local teamIdStr = p.teamId:tostring()
  if instance.enterViewTeamsInFight then
    instance.enterViewTeamsInFight[teamIdStr] = nil
  end
  local team = instance.teamMap[teamIdStr]
  if team == nil then
    return
  end
  instance.teamMap[teamIdStr] = nil
  if team.members == nil then
    return
  end
  local leader = team.members[1] or instance.rolesMap[team.memberIds[1]:tostring()]
  if leader then
    leader:SetTeamId(nil)
    leader:SetTeamIcon("")
  end
  local teampos = leader and leader:GetPos()
  for i = 2, 5 do
    local memberId = team.memberIds[i]
    if memberId then
      local roledata = instance.invisiblePlayers[memberId:tostring()]
      if roledata then
        if teampos then
          roledata.pos = teampos
        end
        roledata.teamId = nil
      end
      local role = team.members[i] or instance.rolesMap[memberId:tostring()]
      if role then
        instance:RoleStopFollow(role)
        role:SetTeamId(nil)
        role:SetTeamIcon("")
      end
    end
  end
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroMgr.myRole then
    instance:ResetRole(heroMgr.myRole)
    if heroMgr.myRole:IsInState(RoleState.GANGBATTLE) or heroMgr.myRole:IsInState(RoleState.GANGCROSS_BATTLE) then
      instance:SetMaxPlayers()
    end
  end
end
def.static("table").OnSGetHeart = function(p)
  local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local myprop = require("Main.Hero.Interface").GetBasicHeroProp()
  local effId = constant.HeartConsts.BOY_GIRL_EFFECT_ID
  if myprop.gender == p.otherGender then
    if myprop.gender == GenderEnum.MALE then
      effId = constant.HeartConsts.BOY_BOY_EFFECT_ID
    elseif myprop.gender == GenderEnum.FEMALE then
      effId = constant.HeartConsts.GIRL_GIRL_EFFECT_ID
    end
  end
  local effRes = GetEffectRes(effId)
  if effRes then
    local name = tostring(constant.HeartConsts.HEART_MODEL_EFFECT_ID)
    require("Fx.GUIFxMan").Instance():Play(effRes.path, name, 0, 0, -1, false)
  end
  if not gmodule.moduleMgr:GetModule(ModuleId.FRIEND):IsFriend(p.otherRoleId) then
    require("Main.Pubrole.ui.DlgDestiny").ShowTip({
      id = p.otherRoleId,
      name = p.otherName,
      gender = p.otherGender
    })
  end
  effRes = GetEffectRes(constant.HeartConsts.HEART_MODEL_EFFECT_ID)
  if effRes == nil then
    return
  end
  local me = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if me then
    me:AddEffect(effRes.path, BODY_PART.BODY)
  end
  local other = instance:GetRole(p.otherRoleId)
  if other then
    other:AddEffect(effRes.path, BODY_PART.BODY)
  end
end
def.static("table").OnSNotifyPlayEffect = function(p)
  local effRes = GetEffectRes(p.effect_cfgid)
  if effRes then
    local name = tostring(p.effect_cfgid)
    require("Fx.GUIFxMan").Instance():Play(effRes.path, name, 0, 0, -1, false)
  end
end
def.method("table", "=>", "boolean").CheckWatchMoonTransform = function(self, p)
  if self.watchMoonMap1[p.groupid:tostring()] then
    return true
  else
    local roleId1 = p.leader
    if roleId1 then
      local playerInfo = instance.invisiblePlayers[roleId1:tostring()]
      if playerInfo and _G.IsModelChanged(playerInfo.modelInfo.model) then
        return true
      end
    end
    local roleId2 = p.other_members and p.other_members[1] or nil
    if roleId2 then
      local playerInfo = instance.invisiblePlayers[roleId2:tostring()]
      if playerInfo and _G.IsModelChanged(playerInfo.modelInfo.model) then
        return true
      end
    end
    if p.leader_info then
      local modelInfo = GetModelInfo(p.leader_info.model_info)
      if _G.IsModelChanged(modelInfo.model) then
        return true
      end
    end
    if p.other_member_infos then
      local modelInfo = GetModelInfo(p.other_member_infos[1] and p.other_member_infos[1].model_info or nil)
      if modelInfo and _G.IsModelChanged(modelInfo.model) then
        return true
      end
    end
    return false
  end
end
def.static("table").OnSMapGroupInfo = function(p)
  if p.group_type == MapGroupType.MGT_TEAM then
  elseif p.group_type == MapGroupType.MGT_COUPLE_FLY then
    PubroleModule.OnSMapCoupleFlyInfo(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_SIDE_BY_SIDE_FLY then
    PubroleModule.OnSMapWatchMoonInfo(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_XYXW_FLY then
    if PubroleModule.Instance():CheckWatchMoonTransform(p) then
      PubroleModule.OnSMapWatchMoonInfo(p)
    else
      PubroleModule.OnSMapWatchMoonCoupleFlyInfo(p)
    end
  elseif p.group_type == MapGroupType.MGT_MARRIAGE then
    PubroleModule.OnParadeInfo(p)
  elseif p.group_type == MapGroupType.MGT_GROUP_WEDDING then
    PubroleModule.OnSMapGroupWedingInfo(p)
  end
end
def.static("table").OnSMapGroupEnterView = function(p)
  if p.group_type == MapGroupType.MGT_TEAM then
  elseif p.group_type == MapGroupType.MGT_COUPLE_FLY then
    PubroleModule.OnSMapCoupleFlyEnterView(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_SIDE_BY_SIDE_FLY then
    PubroleModule.OnSMapWatchMoonEnterView(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_XYXW_FLY then
    if PubroleModule.Instance():CheckWatchMoonTransform(p) then
      PubroleModule.OnSMapWatchMoonEnterView(p)
    else
      PubroleModule.OnSMapWatchMoonCoupleFlyEnterView(p)
    end
  elseif p.group_type == MapGroupType.MGT_MARRIAGE then
    PubroleModule.OnParadeEnterView(p)
  elseif p.group_type == MapGroupType.MGT_GROUP_WEDDING then
    PubroleModule.OnSMapGroupWedingEnterView(p)
  end
end
def.static("table").OnSMapGroupSyncPos = function(p)
  if p.group_type == MapGroupType.MGT_TEAM then
  elseif p.group_type == MapGroupType.MGT_COUPLE_FLY then
    PubroleModule.OnSMapCoupleFlySyncPos(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_SIDE_BY_SIDE_FLY then
    PubroleModule.OnSMapWatchMoonSyncPos(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_XYXW_FLY then
    if PubroleModule.Instance():CheckWatchMoonTransform(p) then
      PubroleModule.OnSMapWatchMoonSyncPos(p)
    else
      PubroleModule.OnSMapWatchMoonCoupleFlySyncPos(p)
    end
  elseif p.group_type == MapGroupType.MGT_MARRIAGE then
    PubroleModule.OnParadeSyncPos(p)
  elseif p.group_type == MapGroupType.MGT_GROUP_WEDDING then
    PubroleModule.OnSMapGroupWedingSyncPos(p)
  end
end
def.static("table").OnSMapGroupTransferPos = function(p)
  if p.group_type == MapGroupType.MGT_TEAM then
  elseif p.group_type == MapGroupType.MGT_COUPLE_FLY then
    PubroleModule.OnSMapCoupleFlyTransferPos(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_SIDE_BY_SIDE_FLY then
    PubroleModule.OnSMapWatchMoonTransferPos(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_XYXW_FLY then
    if PubroleModule.Instance():CheckWatchMoonTransform(p) then
      PubroleModule.OnSMapWatchMoonTransferPos(p)
    else
      PubroleModule.OnSMapWatchMoonCoupleFlyTransferPos(p)
    end
  elseif p.group_type == MapGroupType.MGT_MARRIAGE then
    PubroleModule.OnParadeTransferPos(p)
  elseif p.group_type == MapGroupType.MGT_GROUP_WEDDING then
    PubroleModule.OnSMapGroupWedingTransferPos(p)
  end
end
def.static("table").OnSMapGroupLeaveView = function(p)
  if p.group_type == MapGroupType.MGT_TEAM then
  elseif p.group_type == MapGroupType.MGT_COUPLE_FLY then
    PubroleModule.OnSMapCoupleFlyLeaveView(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_SIDE_BY_SIDE_FLY then
    PubroleModule.OnSMapWatchMoonLeaveView(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_XYXW_FLY then
    if PubroleModule.Instance():CheckWatchMoonTransform(p) then
      PubroleModule.OnSMapWatchMoonLeaveView(p)
    else
      PubroleModule.OnSMapWatchMoonCoupleFlyLeaveView(p)
    end
  elseif p.group_type == MapGroupType.MGT_MARRIAGE then
    PubroleModule.OnParadeLeaveView(p)
  elseif p.group_type == MapGroupType.MGT_GROUP_WEDDING then
    PubroleModule.OnSMapGroupWedingLeaveView(p)
  end
end
def.static("table").OnSMapGroupDissole = function(p)
  if p.group_type == MapGroupType.MGT_TEAM then
  elseif p.group_type == MapGroupType.MGT_COUPLE_FLY then
    PubroleModule.OnSMapCoupleFlyDissole(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_SIDE_BY_SIDE_FLY then
    PubroleModule.OnSMapWatchMoonDissole(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_XYXW_FLY then
    if PubroleModule.Instance():CheckWatchMoonTransform(p) then
      PubroleModule.OnSMapWatchMoonDissole(p)
    else
      PubroleModule.OnSMapWatchMoonCoupleFlyDissole(p)
    end
  elseif p.group_type == MapGroupType.MGT_MARRIAGE then
    PubroleModule.OnParadeDismiss(p)
  elseif p.group_type == MapGroupType.MGT_GROUP_WEDDING then
    PubroleModule.OnSMapGroupWedingDissole(p)
  end
end
def.static("table").OnSSyncMapGroupExtraInfoChange = function(p)
  warn("OnSSyncMapGroupExtraInfoChange:", p.group_type)
  if p.group_type == MapGroupType.MGT_GROUP_WEDDING then
    PubroleModule.OnSMapGroupWedingExtraInfoChange(p)
  end
end
def.static("table").OnSMapGroupForceLand = function(p)
  if p.group_type == MapGroupType.MGT_TEAM then
  elseif p.group_type == MapGroupType.MGT_COUPLE_FLY then
    PubroleModule.OnSMapCoupleForceLand(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_SIDE_BY_SIDE_FLY then
    PubroleModule.OnSMapWatchMoonForceLand(p)
  elseif p.group_type == MapGroupType.MGT_WATCH_MOON_XYXW_FLY then
    if PubroleModule.Instance():CheckWatchMoonTransform(p) then
      PubroleModule.OnSMapWatchMoonForceLand(p)
    else
      PubroleModule.OnSMapWatchMoonCoupleForceLand(p)
    end
  elseif p.group_type == MapGroupType.MGT_MARRIAGE then
  end
end
def.static("table", "table").OnTouchRole = function(p1, p2)
  local roleId = p1 and p1[1]
  if roleId == nil then
    return
  end
  local sceneInfo = instance:GetParadeSceneInfo()
  if sceneInfo == nil then
    return
  end
  if roleId:eq(instance:GetParadeVehicleId()) and sceneInfo.isRobable then
    instance:ShowRobPanel()
  end
end
local parade_scene_info
local parade_vehicle_id = Int64.new(-1000)
local ROB_EFFECT_ID = 702020038
def.method("=>", "boolean").IsInWeddingParade = function(self)
  return parade_scene_info ~= nil and (parade_scene_info.start == true or parade_scene_info.isHost == true)
end
def.method("=>", "userdata").GetParadeVehicleId = function(self)
  return parade_vehicle_id
end
def.method("=>", "table").GetParadeGroom = function(self)
  return parade_scene_info and parade_scene_info.groom
end
def.method("=>", "table").GetParadeBride = function(self)
  return parade_scene_info and parade_scene_info.bride
end
def.method("=>", "table").GetParadeSceneInfo = function(self)
  return parade_scene_info
end
def.method("=>", "number").GetParadeMapId = function(self)
  return parade_scene_info and parade_scene_info.paradeCfg and parade_scene_info.paradeCfg.paradeMapid or 0
end
def.method().ShowRobPanel = function(self)
  if parade_scene_info == nil or parade_scene_info.isHost == true or parade_scene_info.vehicle == nil or not parade_scene_info.isRobable then
    return
  end
  require("Main.WeddingTour.ui.DlgRobWedding").Instance():ShowDlg()
end
def.method("userdata").StartWeddingParade = function(self, roleId)
  if roleId == nil or not roleId:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId) then
    return
  end
  if parade_scene_info == nil then
    parade_scene_info = {}
  end
  parade_scene_info.start = true
end
def.method("userdata").StopWeddingParade = function(self, roleId)
  if roleId == nil or not roleId:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId) then
    return
  end
  if parade_scene_info then
    parade_scene_info.start = false
    if parade_scene_info.isHost == false then
      parade_scene_info = nil
    end
  end
end
def.static("table").OnParadeInfo = function(p)
  if p.leader == nil or p.other_members == nil or #p.other_members < 1 then
    return
  end
  local paradeId = p.extra_infos[MapGroupExtraInfoType.MGEIT_MARRIAGE_CFG_ID]
  if paradeId == nil or paradeId <= 0 then
    Debug.LogWarning("invalide WeddingTour Id : ", paradeId)
    return
  end
  local paradeCfg = require("Main.WeddingTour.WeddingTourUtils").GetWeddingTourModeById(paradeId)
  if paradeCfg == nil then
    return
  end
  local function OnLoadEnd()
    instance:ShowParadeVehicle()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.marriage.CParadeRobStageReq").new())
  end
  if parade_scene_info == nil then
    parade_scene_info = {}
  end
  parade_scene_info.paradeCfg = paradeCfg
  parade_scene_info.prepareEndTime = p.extra_infos[MapGroupExtraInfoType.MGEIT_MARRIAGE_PREPARE_END_SEC]
  parade_scene_info.groom = instance:GetRole(p.leader)
  if parade_scene_info.groom == nil then
    return
  end
  parade_scene_info.groom.enableIdleAct = false
  parade_scene_info.groom.checkAlpha = false
  if parade_scene_info.groom:IsInLoading() then
    parade_scene_info.groom:AddOnLoadCallback("WeddingParade", OnLoadEnd)
  end
  parade_scene_info.bride = instance:GetRole(p.other_members[1])
  if parade_scene_info.bride == nil then
    local roleData = instance.invisiblePlayers[p.other_members[1]:tostring()]
    if roleData then
      roleData.pos.x = 0
      roleData.pos.y = 0
      roleData.dir = 0
      parade_scene_info.bride = instance:CreateRoleModel(roleData)
    end
  end
  if parade_scene_info.bride:IsInLoading() then
    parade_scene_info.bride:AddOnLoadCallback("WeddingParade", OnLoadEnd)
  end
  parade_scene_info.bride.enableIdleAct = false
  parade_scene_info.bride.checkAlpha = false
  if parade_scene_info.vehicle == nil then
    local vehicleName = string.format(textRes.WeddingTour[20], parade_scene_info.groom:GetName(), parade_scene_info.bride:GetName())
    local nameColor = GetColorData(701300300)
    parade_scene_info.vehicle = ECPlayer.new(parade_vehicle_id, paradeCfg.modelDisplayId, vehicleName, nameColor, RoleType.ROLE)
    parade_scene_info.vehicle.defaultLayer = ClientDef_Layer.NPC
    parade_scene_info.vehicle:SetTouchable(true)
    parade_scene_info.vehicle.runSpeed = p.group_velocity
    parade_scene_info.vehicle:AddOnLoadCallback("WeddingParade", OnLoadEnd)
  end
  local pos = parade_scene_info.groom:GetPos()
  parade_scene_info.vehicle:LoadCurrentModel(pos.x, pos.y, 225)
  parade_scene_info.vehicle:RunPath(p.key_point_path, p.group_velocity, function()
    instance:PlayParadeEffect()
  end)
end
def.static("table").OnParadeEnterView = function(p)
  if p.leader_info == nil or p.other_member_infos == nil or #p.other_member_infos < 1 then
    return
  end
  local paradeId = p.extra_infos[MapGroupExtraInfoType.MGEIT_MARRIAGE_CFG_ID]
  local paradeCfg = require("Main.WeddingTour.WeddingTourUtils").GetWeddingTourModeById(paradeId)
  if paradeCfg == nil then
    return
  end
  local function OnLoadEnd()
    instance:ShowParadeVehicle()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.marriage.CParadeRobStageReq").new())
  end
  if parade_scene_info == nil then
    parade_scene_info = {}
  end
  parade_scene_info.paradeCfg = paradeCfg
  parade_scene_info.prepareEndTime = p.extra_infos[MapGroupExtraInfoType.MGEIT_MARRIAGE_PREPARE_END_SEC]
  local leaderModelInfo = GetModelInfo(p.leader_info.model_info)
  parade_scene_info.groom = instance:CreateRole(p.leader_info.roleid, leaderModelInfo, p.cur_pos.x, p.cur_pos.y, p.direction, Color.green, RoleType.ROLE)
  parade_scene_info.groom.enableIdleAct = false
  parade_scene_info.groom.checkAlpha = false
  if parade_scene_info.groom:IsInLoading() then
    parade_scene_info.groom:AddOnLoadCallback("WeddingParade", OnLoadEnd)
  end
  local brideModelInfo = GetModelInfo(p.other_member_infos[1].model_info)
  parade_scene_info.bride = instance:CreateRole(p.other_member_infos[1].roleid, brideModelInfo, p.cur_pos.x, p.cur_pos.y, p.direction, Color.green, RoleType.ROLE)
  parade_scene_info.bride.enableIdleAct = false
  parade_scene_info.bride.checkAlpha = false
  if parade_scene_info.bride:IsInLoading() then
    parade_scene_info.bride:AddOnLoadCallback("WeddingParade", OnLoadEnd)
  end
  if parade_scene_info.vehicle == nil then
    local vehicleName = string.format(textRes.WeddingTour[20], leaderModelInfo.string_props[MapModelInfo.NAME], brideModelInfo.string_props[MapModelInfo.NAME])
    local nameColor = GetColorData(701300300)
    parade_scene_info.vehicle = ECPlayer.new(parade_vehicle_id, paradeCfg.modelDisplayId, vehicleName, nameColor, RoleType.ROLE)
    parade_scene_info.vehicle.defaultLayer = ClientDef_Layer.NPC
    parade_scene_info.vehicle.clickPriority = 0
    parade_scene_info.vehicle.runSpeed = p.group_velocity
    parade_scene_info.vehicle:AddOnLoadCallback("WeddingParade", OnLoadEnd)
    parade_scene_info.vehicle:LoadCurrentModel(p.cur_pos.x, p.cur_pos.y, p.direction)
  end
  parade_scene_info.vehicle:RunPath(p.key_point_path, p.group_velocity, function()
    instance:PlayParadeEffect()
  end)
end
def.method().ShowParadeVehicle = function(self)
  if parade_scene_info == nil then
    return
  end
  if parade_scene_info.vehicle == nil or parade_scene_info.vehicle.m_model == nil then
    return
  end
  if parade_scene_info.groom == nil or parade_scene_info.groom.m_model == nil then
    return
  end
  if parade_scene_info.bride == nil or parade_scene_info.bride.m_model == nil then
    return
  end
  parade_scene_info.groom:Stop()
  parade_scene_info.groom:Set3DPos(EC.Vector3.zero)
  parade_scene_info.groom:ShowName(false)
  parade_scene_info.bride:Stop()
  parade_scene_info.bride:Set3DPos(EC.Vector3.zero)
  parade_scene_info.bride:ShowName(false)
  parade_scene_info.vehicle:SetNameToDepth()
  parade_scene_info.groom:LeaveMount()
  parade_scene_info.bride:LeaveMount()
  parade_scene_info.vehicle:AttachModel("Groom", parade_scene_info.groom, "HH_Player01")
  parade_scene_info.vehicle:AttachModel("Bride", parade_scene_info.bride, "HH_Player02")
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId
  if parade_scene_info.groom.roleId:eq(myId) or parade_scene_info.bride.roleId:eq(myId) then
    ECGame.Instance().m_MainHostPlayer:SetToGround()
    ECGame.Instance().m_MainHostPlayer = parade_scene_info.vehicle
    parade_scene_info.isHost = true
    if parade_scene_info.prepareEndTime and parade_scene_info.prepareEndTime > 0 then
      local curTime = _G.GetServerTime()
      if curTime < parade_scene_info.prepareEndTime then
        require("GUI.CommonCountDown").Start(parade_scene_info.prepareEndTime - curTime)
      end
    end
  end
  parade_scene_info.isDone = false
end
def.static("table").OnParadeSyncPos = function(p)
  if parade_scene_info == nil or parade_scene_info.vehicle == nil then
    return
  end
  parade_scene_info.vehicle:RunPath(p.key_point_path, parade_scene_info.vehicle.runSpeed, function()
    parade_scene_info.isMoving = false
    instance:PlayParadeEffect()
    if parade_scene_info.isDone then
      instance:ParadeEnd(false)
    end
  end)
  parade_scene_info.isMoving = true
end
def.static("table").OnParadeTransferPos = function(p)
  if parade_scene_info == nil or parade_scene_info.vehicle == nil then
    return
  end
  local mapMgr = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  _G.IsMutilFrameLoadMap = false
  if mapMgr.mapInstanceId ~= p.map_instance_id then
    instance:RemoveAllMapRoles(false, {
      parade_scene_info.groom.roleId,
      parade_scene_info.bride.roleId
    })
    mapMgr.mapInstanceId = p.map_instance_id
    Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_INSTANCE_CHANGED, {
      lastMapId = mapMgr:GetMapId(),
      mapId = p.map_cfgid
    })
  end
  if p.map_cfgid ~= mapMgr:GetMapId() then
    mapMgr:LoadMap(p.map_cfgid)
  end
  parade_scene_info.vehicle:SetPos(p.pos.x, p.pos.y)
end
def.static("table").OnParadeLeaveView = function(p)
  instance:ParadeEnd(true)
end
def.static("table").OnParadeDismiss = function(p)
  if parade_scene_info == nil then
    return
  end
  if parade_scene_info.isMoving then
    parade_scene_info.isDone = true
  else
    instance:ParadeEnd(false)
  end
end
def.method().PlayParadeEffect = function()
  if parade_scene_info == nil or parade_scene_info.vehicle == nil or parade_scene_info.paradeCfg == nil then
    return
  end
  local curPos = parade_scene_info.vehicle:GetPos()
  local effCount = #parade_scene_info.paradeCfg.effects
  if effCount == 0 then
    return
  end
  local idx = 1
  if effCount > 1 then
    idx = math.floor(math.random(1, effCount + 1))
  end
  local effId = parade_scene_info.paradeCfg.effects[idx]
  local eff = GetEffectRes(effId)
  if eff then
    ECFxMan.Instance():PlayEffectAt2DPos(eff.path, curPos.x, world_height - curPos.y)
  end
end
def.method("boolean").ParadeEnd = function(self, destroy)
  if parade_scene_info == nil or parade_scene_info.vehicle == nil then
    return
  end
  if parade_scene_info.robEffectPath then
    parade_scene_info.vehicle:StopChildEffect(parade_scene_info.robEffectPath)
    parade_scene_info.robEffectPath = nil
  end
  local curPos = parade_scene_info.vehicle:GetPos()
  local parent = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  parade_scene_info.vehicle:Detach("Groom")
  parade_scene_info.groom:ShowName(true)
  parade_scene_info.bride:ShowName(true)
  parade_scene_info.vehicle:SetNameNoDepth()
  parade_scene_info.groom:SetParentNode(parent)
  parade_scene_info.groom:SetPos(curPos.x, curPos.y)
  parade_scene_info.groom.idleTime = -1
  parade_scene_info.groom.checkAlpha = true
  parade_scene_info.vehicle:Detach("Bride")
  parade_scene_info.bride:SetParentNode(parent)
  parade_scene_info.bride:SetPos(curPos.x, curPos.y)
  parade_scene_info.bride.idleTime = -1
  parade_scene_info.bride.checkAlpha = true
  parade_scene_info.groom:ReturnMount()
  parade_scene_info.bride:ReturnMount()
  parade_scene_info.vehicle:Destroy()
  parade_scene_info.vehicle = nil
  if destroy then
    PubroleModule.OnSRoleLeaveView(parade_scene_info.groom)
    PubroleModule.OnSRoleLeaveView(parade_scene_info.bride)
    parade_scene_info.start = false
  end
  parade_scene_info.groom = nil
  parade_scene_info.bride = nil
  if parade_scene_info.isHost then
    ECGame.Instance().m_MainHostPlayer = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  end
  parade_scene_info.isHost = false
  if parade_scene_info.start == false then
    parade_scene_info = nil
  end
end
def.static("table").OnSParadeRobStageRes = function(p)
  if p.result == p.YES then
    local vehicle = parade_scene_info and parade_scene_info.vehicle
    if vehicle then
      parade_scene_info.isRobable = true
      local effres = GetEffectRes(ROB_EFFECT_ID)
      if effres then
        parade_scene_info.robEffectPath = effres.path
        vehicle:AddChildEffect(effres.path, BODY_PART.HEAD, "", 2)
      end
    end
  end
end
def.static("table").OnSBrocastRobMarriageParadeEnd = function(p)
  local vehicle = parade_scene_info and parade_scene_info.vehicle
  if vehicle then
    parade_scene_info.isRobable = false
    if parade_scene_info.robEffectPath then
      parade_scene_info.vehicle:StopChildEffect(parade_scene_info.robEffectPath)
      parade_scene_info.robEffectPath = nil
    end
  end
  if p.result == p.NO then
    local groomInfo = p.role1Info
    local brideInfo = p.role2Info
    local announce = string.format(textRes.WeddingTour[17], groomInfo.roleName, brideInfo.roleName)
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(announce, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
  end
end
def.static("table").OnSSynMarrageParadeAttackRes = function(p)
  local attackInfo = parade_scene_info and parade_scene_info.attackInfo
  if attackInfo == nil then
    attackInfo = {}
    parade_scene_info.attackInfo = attackInfo
  end
  attackInfo[p.paradeRoleType] = p.attackedState
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.PARADE_ATTACK_STATE_CHANGED, nil)
end
def.static("table").OnSReportRoleRes = function(p)
  local msg = textRes.PubRole.ReportRoleRes[p.resultcode]
  if msg then
    Toast(msg)
  end
  if p.resultcode == 0 then
    require("Main.Pubrole.ui.ReportDlg").Instance():ClosePanel()
    if nil == FriendModule.Instance():GetFriendInfo(p.targetRoleId) then
      FriendModule.AddShield(p.targetRoleId, p.targetRoleName)
    end
  end
end
def.method("=>", "table").GetParadeAttackInfo = function(self)
  return parade_scene_info and parade_scene_info.attackInfo
end
def.method("boolean", "table").RemoveAllMapRoles = function(self, removeHero, filter)
  if self.weddingScene then
    self:EndWedding()
  end
  local removeMyrole = true
  self:ParadeEnd(true)
  local old_rolesMap = self.rolesMap
  local old_RolesData = self.invisiblePlayers
  local old_followList = self.followList
  local old_teamMap = self.teamMap
  self.visiblePlayers = {}
  self.rolesMap = {}
  self.invisiblePlayers = {}
  self.followList = {}
  self.teamMap = {}
  if filter and #filter > 0 then
    for i = 1, #filter do
      local key = filter[i]
      if type(key) ~= "string" then
        key = key:tostring()
      end
      local role = old_rolesMap[key]
      if role then
        if role == gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
          removeMyrole = false
        end
        self.rolesMap[key] = role
        self.visiblePlayers[key] = role
        old_rolesMap[key] = nil
        self.invisiblePlayers[key] = old_RolesData[key]
        old_RolesData[key] = nil
        if 0 < role.followIdx then
          self.followList[role.followIdx] = old_followList[role.followIdx]
          old_followList[role.followIdx] = nil
        end
        if role.teamId then
          local teamIdStr = role.teamId:tostring()
          self.teamMap[teamIdStr] = old_teamMap[teamIdStr]
        end
        local pet = role:GetPet()
        if pet then
          self.followList[pet.followIdx] = old_followList[pet.followIdx]
        end
      end
    end
  end
  if removeMyrole == true and removeHero == false then
    Debug.LogWarning("unexpected hero destroy: ")
    Debug.LogWarning(debug.traceback())
    local myrole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
    local key = myrole.roleId:tostring()
    self.rolesMap[key] = myRole
    self.visiblePlayers[key] = myrole
    self.invisiblePlayers[key] = old_RolesData[key]
  end
  self.watchMoonMap1 = {}
  self.watchMoonMap2 = {}
  for k, v in pairs(self.groupWeddingMap) do
    if v.npcA then
      v.npcA:Destroy()
      v.npcA = nil
    end
    if v.npcB then
      v.npcB:Destroy()
      v.npcB = nil
    end
  end
  self.groupWeddingMap = {}
  for k, v in pairs(self.coupleMap) do
    if self.rolesMap[v.aid] == nil or self.rolesMap[v.bid] == nil then
      self.coupleMap[k] = nil
    end
  end
  for k, v in pairs(old_rolesMap) do
    local role = old_rolesMap[k]
    role:RemovePet()
    role:Destroy()
  end
  for k, v in pairs(self.npcMap) do
    self:RemoveNpc(k)
  end
  for k, v in pairs(self.itemMap) do
    self:RemoveItem(k)
  end
  for k, v in pairs(self.monsterMap) do
    self:RemoveMonster(k)
  end
  gmodule.moduleMgr:GetModule(ModuleId.MAP):RemoveAllMapEntities()
  self.mapRoleLocs = nil
end
def.method("userdata", "=>", "boolean").IsInFollowState = function(self, roleid)
  if roleid then
    local role = self.rolesMap[roleid:tostring()]
    return role ~= nil and role:IsInState(RoleState.FOLLOW) and not role:IsInState(RoleState.BALL_ARENA)
  else
    return false
  end
end
def.method().SetFollowPath = function(self)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local teamId = heroMgr.myRole.teamId
  local pet = heroMgr.myRole:GetPet()
  if pet then
    local followPathNodes = self:GetFollowMovePathNodes(pet, heroMgr.myRole)
    local follower = self.followList[pet.followIdx]
    if follower then
      self:FollowStart(follower.r, follower.t, followPathNodes)
    end
  end
  if teamId == nil then
    return
  end
  local team = self.teamMap[teamId:tostring()]
  if team == nil or team.members == nil or heroMgr.myRole:IsInState(RoleState.FLY) then
    return
  end
  if team.members[1] == heroMgr.myRole then
    for k, member in pairs(team.members) do
      if k > 1 then
        local follower = self.followList[member.followIdx]
        if follower ~= nil then
          member:StopAnimAndCallback()
          if follower.r:IsDestroyed() or follower.t:IsDestroyed() then
            self.followList[member.followIdx] = nil
          else
            local followPathNodes = self:GetFollowMovePathNodes(follower.r, heroMgr.myRole)
            self:FollowStart(follower.r, follower.t, followPathNodes)
          end
        else
          member:CleanAnimCallback()
        end
      end
    end
    return
  end
end
def.method("number").UpdateModels = function(self, dt)
  for k, v in pairs(self.rolesMap) do
    if v:IsDestroyed() then
      self.rolesMap[k] = nil
    else
      v:Update(dt)
    end
  end
  for k, v in pairs(self.npcMap) do
    if v:IsDestroyed() then
      self.npcMap[k] = nil
    else
      v:Update(dt)
    end
  end
  for k, v in pairs(self.monsterMap) do
    if v:IsDestroyed() then
      self.monsterMap[k] = nil
    else
      v:Update(dt)
    end
  end
  for k, v in pairs(self.userNpcMap) do
    if not v:IsDestroyed() then
      v:Update(dt)
    else
      self.userNpcMap[k] = nil
    end
  end
end
def.method("string", "=>", "boolean", "string").IsOneOfCoupleFly = function(self, roleIdStr)
  for k, v in pairs(self.coupleMap) do
    if v.aid == roleIdStr or v.bid == roleIdStr then
      return true, k
    end
  end
  return false, ""
end
def.static("table").OnSMapCoupleFlyInfo = function(p)
  local coupleId = p.groupid:tostring()
  if p.leader == nil or #p.other_members ~= 1 then
    return
  end
  local coupleA = p.leader
  local coupleB = p.other_members[1]
  local aid = coupleA:tostring()
  local roleA = instance.rolesMap[aid]
  if roleA == nil then
    if instance.invisiblePlayers[aid] then
      roleA = instance:CreateRoleModel(instance.invisiblePlayers[aid])
      instance.visiblePlayers[aid] = roleA
    else
      return
    end
  else
  end
  local bid = coupleB:tostring()
  local roleB = instance.rolesMap[bid]
  if roleB == nil then
    if instance.invisiblePlayers[bid] then
      roleB = instance:CreateRoleModel(instance.invisiblePlayers[bid])
      instance.visiblePlayers[bid] = roleB
    else
      return
    end
  else
  end
  local couple = {}
  couple.aid = aid
  couple.bid = bid
  instance.coupleMap[coupleId] = couple
  local keyPath = p.key_point_path
  if #keyPath > 0 then
    local tarpos = keyPath[#keyPath]
    if tarpos then
      roleA:FlyTo(tarpos.x, tarpos.y, nil)
      roleA:Hug(roleB)
    else
      roleA:FlyAt(pos.x, pos.y, nil)
      roleA:Hug(roleB)
    end
  else
    do
      local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
      local myRoleId = heroModule.roleId:tostring()
      if myRoleId == aid or myRoleId == bid then
        heroModule:LockMove(true)
      end
      local readyA, readyB = false, false
      local function AllArrive()
        if readyA and readyB then
          roleA:Hug(roleB)
          heroModule:LockMove(false)
        end
      end
      local function AArrive()
        readyA = true
        AllArrive()
      end
      local function BArrive()
        readyB = true
        AllArrive()
      end
      local apos = roleA:GetPos()
      if roleA:IsInState(RoleState.FLY) then
        AArrive()
      else
        roleA:FlyUp(AArrive)
      end
      if roleB:IsInState(RoleState.FLY) then
        roleB:FlyTo(apos.x, apos.y, BArrive)
      else
        roleB:FlyUpTo(apos.x, apos.y, BArrive)
      end
    end
  end
end
def.static("table").OnSMapCoupleFlyEnterView = function(p)
  local coupleId = p.groupid:tostring()
  if p.leader_info == nil or p.other_member_infos == nil or #p.other_member_infos ~= 1 then
    return
  end
  local coupleA = p.leader_info
  local coupleB = p.other_member_infos[1]
  local pos = p.cur_pos
  local tarpos = p.key_point_path[#p.key_point_path]
  local aid = coupleA.roleid:tostring()
  local roleA = instance.rolesMap[aid]
  if roleA == nil then
    local modelInfo = GetModelInfo(coupleA.model_info)
    instance:CreateRole(coupleA.roleid, modelInfo, pos.x, pos.y, Default_Role_Dir, Color.green, RoleType.ROLE)
    roleA = instance.rolesMap[aid]
    instance.visiblePlayers[aid] = roleA
  else
  end
  local bid = coupleB.roleid:tostring()
  local roleB = instance.rolesMap[bid]
  if roleB == nil then
    local modelInfo = GetModelInfo(coupleB.model_info)
    instance:CreateRole(coupleB.roleid, modelInfo, pos.x, pos.y, Default_Role_Dir, Color.green, RoleType.ROLE)
    roleB = instance.rolesMap[bid]
    instance.visiblePlayers[bid] = roleB
  else
  end
  if roleA and roleB then
    local couple = {}
    couple.aid = aid
    couple.bid = bid
    instance.coupleMap[coupleId] = couple
    if tarpos then
      roleA:FlyTo(tarpos.x, tarpos.y, nil)
      roleA:Hug(roleB)
    else
      roleA:FlyAt(pos.x, pos.y, nil)
      roleA:Hug(roleB)
    end
  end
end
def.static("table").OnSMapCoupleFlySyncPos = function(p)
  local couple = instance.coupleMap[p.groupid:tostring()]
  if couple then
    do
      local coupleA = instance.rolesMap[couple.aid]
      if coupleA:IsInState(RoleState.HUG) then
        instance:RoleFly(coupleA, p.key_point_path)
      else
        coupleA:SetMoveAfter(function()
          instance:RoleFly(coupleA, p.key_point_path)
        end)
        warn("Bad couple, client do not has this couple or couple has not created!")
      end
    end
  end
end
def.static("table").OnSMapCoupleFlyTransferPos = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.coupleMap[coupleId]
  if couple then
    local mapMgr = gmodule.moduleMgr:GetModule(ModuleId.MAP)
    local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    local myRoleId = heroMgr:GetMyRoleId():tostring()
    if myRoleId == couple.aid or myRoleId == couple.bid then
      local roleA = instance.rolesMap[couple.aid]
      roleA:Stop()
      if p.map_cfgid ~= mapMgr:GetMapId() then
        instance:RemoveAllMapRoles(false, {
          couple.aid,
          couple.bid
        })
        mapMgr:LoadMap(p.map_cfgid)
      end
      mapMgr.mapInstanceId = p.map_instance_id
      roleA:FlyAt(p.pos.x, p.pos.y, nil)
      XunluTip.HideXunlu()
      Camera2D.SetFocus(p.pos.x, p.pos.y)
      instance.changemap_target_pos = p.target_pos
    end
  end
end
def.static("table").OnSMapCoupleFlyLeaveView = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.coupleMap[coupleId]
  if couple then
    local myRoleIdStr = GetMyRoleID():tostring()
    if couple.aid == myRoleIdStr or couple.bid == myRoleIdStr then
      return
    end
    instance:DestroyRole(couple.aid)
    instance:DestroyRole(couple.bid)
  end
  instance.coupleMap[coupleId] = nil
end
def.static("table").OnSMapCoupleFlyDissole = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.coupleMap[coupleId]
  if couple then
    local roleA = instance.rolesMap[couple.aid]
    local roledata = instance.invisiblePlayers[couple.aid]
    if roledata then
      roledata.pos = roleA:GetPos()
    end
    local roleB = instance.rolesMap[couple.bid]
    roledata = instance.invisiblePlayers[couple.bid]
    if roledata then
      roledata.pos = roleB:GetPos()
    end
    if roleA then
      roleA:UnHug()
    end
  end
  instance.coupleMap[coupleId] = nil
end
def.static("table").OnSMapWatchMoonInfo = function(p)
  local coupleId = p.groupid:tostring()
  if p.leader == nil or #p.other_members ~= 1 then
    return
  end
  local coupleA = p.leader
  local coupleB = p.other_members[1]
  local aid = coupleA:tostring()
  local roleA = instance.rolesMap[aid]
  if roleA == nil then
    if instance.invisiblePlayers[aid] then
      roleA = instance:CreateRoleModel(instance.invisiblePlayers[aid])
      instance.visiblePlayers[aid] = roleA
    else
      return
    end
  else
  end
  local bid = coupleB:tostring()
  local roleB = instance.rolesMap[bid]
  if roleB == nil then
    if instance.invisiblePlayers[bid] then
      roleB = instance:CreateRoleModel(instance.invisiblePlayers[bid])
      instance.visiblePlayers[bid] = roleB
    else
      return
    end
  else
  end
  local couple = {}
  couple.aid = aid
  couple.bid = bid
  instance.watchMoonMap1[coupleId] = couple
  local keyPath = p.key_point_path
  if coupleA == GetMyRoleID() or coupleB == GetMyRoleID() then
    instance:EnterOnlyShowSpecificRoles({
      coupleA:tostring(),
      coupleB:tostring()
    })
  end
  if #keyPath > 0 then
    if 0 >= roleA:GetFeijianId() then
      roleA:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
    end
    if 0 >= roleB:GetFeijianId() then
      roleB:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
    end
    if tarpos then
      roleA:FlyTo(tarpos.x, tarpos.y, nil)
      roleB:FlyTo(tarpos.x + fly_sidebyside_distance, tarpos.y, nil)
    else
      roleA:FlyAt(pos.x, pos.y, nil)
      roleB:FlyAt(tarpos.x + fly_sidebyside_distance, tarpos.y, nil)
    end
    roleA:SetReplaceFeijianId(0)
    roleB:SetReplaceFeijianId(0)
    local effectPath = GetEffectRes(constant.CWatchmoonConsts.FLYING_EFFECT)
    roleA:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
    roleB:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
  else
    do
      local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
      local myRoleId = heroModule.roleId:tostring()
      if myRoleId == aid or myRoleId == bid then
        heroModule:LockMove(true)
      end
      local readyA, readyB = false, false
      local function AllArrive()
        if readyA and readyB then
          heroModule:LockMove(false)
          local effectPath = GetEffectRes(constant.CWatchmoonConsts.FLYING_EFFECT)
          roleA:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
          roleB:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
        end
      end
      local function AArrive()
        readyA = true
        AllArrive()
      end
      local function BArrive()
        readyB = true
        AllArrive()
      end
      if 0 >= roleA:GetFeijianId() then
        roleA:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
      end
      if 0 >= roleB:GetFeijianId() then
        roleB:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
      end
      local apos = roleA:GetPos()
      if roleA:IsInState(RoleState.FLY) then
        AArrive()
      else
        roleA:FlyUp(AArrive)
      end
      local sideX = apos.x + fly_sidebyside_distance
      if roleB:IsInState(RoleState.FLY) then
        roleB:FlyTo(sideX, apos.y, BArrive)
      else
        roleB:FlyUpTo(sideX, apos.y, BArrive)
      end
      roleA:SetReplaceFeijianId(0)
      roleB:SetReplaceFeijianId(0)
    end
  end
end
def.static("table").OnSMapWatchMoonEnterView = function(p)
  local coupleId = p.groupid:tostring()
  if p.leader_info == nil or p.other_member_infos == nil or #p.other_member_infos ~= 1 then
    return
  end
  local coupleA = p.leader_info
  local coupleB = p.other_member_infos[1]
  local pos = p.cur_pos
  local tarpos = p.key_point_path[#p.key_point_path]
  local aid = coupleA.roleid:tostring()
  local roleA = instance.rolesMap[aid]
  if roleA == nil then
    local modelInfo = GetModelInfo(coupleA.model_info)
    instance:CreateRole(coupleA.roleid, modelInfo, pos.x, pos.y, Default_Role_Dir, Color.green, RoleType.ROLE)
    roleA = instance.rolesMap[aid]
    instance.visiblePlayers[aid] = roleA
  else
  end
  local bid = coupleB.roleid:tostring()
  local roleB = instance.rolesMap[bid]
  if roleB == nil then
    local modelInfo = GetModelInfo(coupleB.model_info)
    instance:CreateRole(coupleB.roleid, modelInfo, pos.x + fly_sidebyside_distance, pos.y, Default_Role_Dir, Color.green, RoleType.ROLE)
    roleB = instance.rolesMap[bid]
    instance.visiblePlayers[bid] = roleB
  else
  end
  if roleA and roleB then
    local couple = {}
    couple.aid = aid
    couple.bid = bid
    instance.watchMoonMap1[coupleId] = couple
    if roleA:GetFeijianId() <= 0 then
      roleA:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
    end
    if roleB:GetFeijianId() <= 0 then
      roleB:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
    end
    if tarpos then
      roleA:FlyTo(tarpos.x, tarpos.y, nil)
      roleB:FlyTo(tarpos.x + fly_sidebyside_distance, tarpos.y, nil)
    else
      roleA:FlyAt(pos.x, pos.y, nil)
      roleB:FlyAt(pos.x + fly_sidebyside_distance, pos.y, nil)
    end
    roleA:SetReplaceFeijianId(0)
    roleB:SetReplaceFeijianId(0)
    local effectPath = GetEffectRes(constant.CWatchmoonConsts.FLYING_EFFECT)
    roleA:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
    roleB:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
  end
end
def.static("table").OnSMapWatchMoonSyncPos = function(p)
  local couple = instance.watchMoonMap1[p.groupid:tostring()]
  if couple then
    local coupleA = instance.rolesMap[couple.aid]
    local coupleB = instance.rolesMap[couple.bid]
    local pathNodes = p.key_point_path
    local tarPos = pathNodes[#pathNodes]
    if tarPos then
      coupleA:FlyTo(tarPos.x, tarPos.y, nil)
      coupleB:FlyTo(tarPos.x + fly_sidebyside_distance, tarPos.y, nil)
    end
  end
end
def.static("table").OnSMapWatchMoonTransferPos = function(p)
  warn("can not transfer map when watch moon")
end
def.static("table").OnSMapWatchMoonLeaveView = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.watchMoonMap1[coupleId]
  if couple then
    local myRoleIdStr = GetMyRoleID():tostring()
    if couple.aid == myRoleIdStr or couple.bid == myRoleIdStr then
      return
    end
    instance:DestroyRole(couple.aid)
    instance:DestroyRole(couple.bid)
  end
  instance.watchMoonMap1[coupleId] = nil
end
def.static("table").OnSMapWatchMoonDissole = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.watchMoonMap1[coupleId]
  if couple then
    local roleA = instance.rolesMap[couple.aid]
    local roleB = instance.rolesMap[couple.bid]
    local effectPath = GetEffectRes(constant.CWatchmoonConsts.FLYING_EFFECT)
    if roleA then
      local roledata = instance.invisiblePlayers[couple.aid]
      if roledata then
        roledata.pos = roleA:GetPos()
      end
      instance:ResetRole(roleA)
      roleA:StopChildEffect(effectPath.path)
    end
    if roleB then
      local roledata = instance.invisiblePlayers[couple.bid]
      if roledata then
        roledata.pos = roleB:GetPos()
      end
      instance:ResetRole(roleB)
      roleB:StopChildEffect(effectPath.path)
    end
  end
  instance.watchMoonMap1[coupleId] = nil
  if couple then
    local myRoleIdStr = GetMyRoleID():tostring()
    if couple.aid == myRoleIdStr or couple.bid == myRoleIdStr then
      instance:QuitOnlyShowSpecificRoles()
    end
  end
end
def.static("table").OnSMapWatchMoonCoupleFlyInfo = function(p)
  local coupleId = p.groupid:tostring()
  if p.leader == nil or #p.other_members ~= 1 then
    return
  end
  local coupleA = p.leader
  local coupleB = p.other_members[1]
  local aid = coupleA:tostring()
  local roleA = instance.rolesMap[aid]
  if roleA == nil then
    if instance.invisiblePlayers[aid] then
      roleA = instance:CreateRoleModel(instance.invisiblePlayers[aid])
      instance.visiblePlayers[aid] = roleA
    else
      return
    end
  else
  end
  local bid = coupleB:tostring()
  local roleB = instance.rolesMap[bid]
  if roleB == nil then
    if instance.invisiblePlayers[bid] then
      roleB = instance:CreateRoleModel(instance.invisiblePlayers[bid])
      instance.visiblePlayers[bid] = roleB
    else
      return
    end
  else
  end
  local couple = {}
  couple.aid = aid
  couple.bid = bid
  instance.watchMoonMap2[coupleId] = couple
  if coupleA == GetMyRoleID() or coupleB == GetMyRoleID() then
    instance:EnterOnlyShowSpecificRoles({
      coupleA:tostring(),
      coupleB:tostring()
    })
  end
  local keyPath = p.key_point_path
  if #keyPath > 0 then
    if 0 >= roleA:GetFeijianId() then
      roleA:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
    end
    if 0 >= roleB:GetFeijianId() then
      roleB:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
    end
    if tarpos then
      roleA:FlyTo(tarpos.x, tarpos.y, nil)
      roleA:Hug(roleB)
    else
      roleA:FlyAt(pos.x, pos.y, nil)
      roleA:Hug(roleB)
    end
    roleA:SetReplaceFeijianId(0)
    roleB:SetReplaceFeijianId(0)
    local effectPath = GetEffectRes(constant.CWatchmoonConsts.FLYING_EFFECT)
    roleA:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
    roleB:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
  else
    do
      local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
      local myRoleId = heroModule.roleId:tostring()
      if myRoleId == aid or myRoleId == bid then
        heroModule:LockMove(true)
      end
      local readyA, readyB = false, false
      local function AllArrive()
        if readyA and readyB then
          roleA:Hug(roleB)
          heroModule:LockMove(false)
          local effectPath = GetEffectRes(constant.CWatchmoonConsts.FLYING_EFFECT)
          roleA:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
          roleB:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
        end
      end
      local function AArrive()
        readyA = true
        AllArrive()
      end
      local function BArrive()
        readyB = true
        AllArrive()
      end
      if 0 >= roleA:GetFeijianId() then
        roleA:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
      end
      if 0 >= roleB:GetFeijianId() then
        roleB:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
      end
      local apos = roleA:GetPos()
      if roleA:IsInState(RoleState.FLY) then
        AArrive()
      else
        roleA:FlyUp(AArrive)
      end
      if roleB:IsInState(RoleState.FLY) then
        roleB:FlyTo(apos.x, apos.y, BArrive)
      else
        roleB:FlyUpTo(apos.x, apos.y, BArrive)
      end
      roleA:SetReplaceFeijianId(0)
      roleB:SetReplaceFeijianId(0)
    end
  end
end
def.static("table").OnSMapWatchMoonCoupleFlyEnterView = function(p)
  local coupleId = p.groupid:tostring()
  if p.leader_info == nil or p.other_member_infos == nil or #p.other_member_infos ~= 1 then
    return
  end
  local coupleA = p.leader_info
  local coupleB = p.other_member_infos[1]
  local pos = p.cur_pos
  local tarpos = p.key_point_path[#p.key_point_path]
  local aid = coupleA.roleid:tostring()
  local roleA = instance.rolesMap[aid]
  if roleA == nil then
    local modelInfo = GetModelInfo(coupleA.model_info)
    instance:CreateRole(coupleA.roleid, modelInfo, pos.x, pos.y, Default_Role_Dir, Color.green, RoleType.ROLE)
    roleA = instance.rolesMap[aid]
    instance.visiblePlayers[aid] = roleA
  else
  end
  local bid = coupleB.roleid:tostring()
  local roleB = instance.rolesMap[bid]
  if roleB == nil then
    local modelInfo = GetModelInfo(coupleB.model_info)
    instance:CreateRole(coupleB.roleid, modelInfo, pos.x, pos.y, Default_Role_Dir, Color.green, RoleType.ROLE)
    roleB = instance.rolesMap[bid]
    instance.visiblePlayers[bid] = roleB
  else
  end
  if roleA and roleB then
    local couple = {}
    couple.aid = aid
    couple.bid = bid
    instance.watchMoonMap2[coupleId] = couple
    if roleA:GetFeijianId() <= 0 then
      roleA:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
    end
    if roleB:GetFeijianId() <= 0 then
      roleB:SetReplaceFeijianId(constant.CWatchmoonConsts.DEFAULT_FEIJIAN_CFG_ID)
    end
    if tarpos then
      roleA:FlyTo(tarpos.x, tarpos.y, nil)
      roleA:Hug(roleB)
    else
      roleA:FlyAt(pos.x, pos.y, nil)
      roleA:Hug(roleB)
    end
    roleA:SetReplaceFeijianId(0)
    roleB:SetReplaceFeijianId(0)
    local effectPath = GetEffectRes(constant.CWatchmoonConsts.FLYING_EFFECT)
    roleA:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
    roleB:AddChildEffect(effectPath.path, BODY_PART.NONE, "", 0)
  end
end
def.static("table").OnSMapWatchMoonCoupleFlySyncPos = function(p)
  local couple = instance.watchMoonMap2[p.groupid:tostring()]
  if couple then
    do
      local coupleA = instance.rolesMap[couple.aid]
      if coupleA then
        if coupleA:IsInState(RoleState.HUG) then
          local pathNodes = p.key_point_path
          local tarPos = pathNodes[#pathNodes]
          if tarPos then
            coupleA:FlyTo(tarPos.x, tarPos.y, nil)
          end
        else
          coupleA:SetMoveAfter(function()
            local pathNodes = p.key_point_path
            local tarPos = pathNodes[#pathNodes]
            if tarPos then
              coupleA:FlyTo(tarPos.x, tarPos.y, nil)
            end
          end)
          warn("Bad couple, client do not has this couple or couple has not created!")
        end
      end
    end
  end
end
def.static("table").OnSMapWatchMoonCoupleFlyTransferPos = function(p)
  warn("WatchMoon, can't transfer")
end
def.static("table").OnSMapWatchMoonCoupleFlyLeaveView = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.watchMoonMap2[coupleId]
  if couple then
    local myRoleIdStr = GetMyRoleID():tostring()
    if couple.aid == myRoleIdStr or couple.bid == myRoleIdStr then
      return
    end
    instance:DestroyRole(couple.aid)
    instance:DestroyRole(couple.bid)
  end
  instance.watchMoonMap2[coupleId] = nil
end
def.static("table").OnSMapWatchMoonCoupleFlyDissole = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.watchMoonMap2[coupleId]
  if couple then
    local roleA = instance.rolesMap[couple.aid]
    local roleB = instance.rolesMap[couple.bid]
    local effectPath = GetEffectRes(constant.CWatchmoonConsts.FLYING_EFFECT)
    if roleA then
      roleA:UnHug()
      local roledata = instance.invisiblePlayers[couple.aid]
      if roledata then
        roledata.pos = roleA:GetPos()
      end
      instance:ResetRole(roleA)
      roleA:StopChildEffect(effectPath.path)
    end
    if roleB then
      local roledata = instance.invisiblePlayers[couple.bid]
      if roledata then
        roledata.pos = roleB:GetPos()
      end
      instance:ResetRole(roleB)
      roleB:StopChildEffect(effectPath.path)
    end
  end
  instance.watchMoonMap2[coupleId] = nil
  if couple then
    local myRoleIdStr = GetMyRoleID():tostring()
    if couple.aid == myRoleIdStr or couple.bid == myRoleIdStr then
      instance:QuitOnlyShowSpecificRoles()
    end
  end
end
local weddingOffset = {x = -100, y = 50}
local weddingOffset2 = {x = 100, y = 50}
def.static("table").OnSMapGroupWedingInfo = function(p)
  local coupleId = p.groupid:tostring()
  if p.leader == nil or #p.other_members ~= 1 then
    return
  end
  local coupleA = p.leader
  local coupleB = p.other_members[1]
  local myRoleId = GetMyRoleID()
  if coupleA == myRoleId or coupleB == myRoleId then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):LockMove(true)
    instance.inGroupWedding = true
  end
  local aid = coupleA:tostring()
  local roleA = instance.rolesMap[aid]
  if roleA == nil then
    if instance.invisiblePlayers[aid] then
      roleA = instance:CreateRoleModel(instance.invisiblePlayers[aid])
      instance.visiblePlayers[aid] = roleA
    else
      return
    end
  else
  end
  local bid = coupleB:tostring()
  local roleB = instance.rolesMap[bid]
  if roleB == nil then
    if instance.invisiblePlayers[bid] then
      roleB = instance:CreateRoleModel(instance.invisiblePlayers[bid])
      instance.visiblePlayers[bid] = roleB
    else
      return
    end
  else
  end
  local couple = {}
  couple.aid = aid
  couple.bid = bid
  couple.speed = p.group_velocity
  instance.groupWeddingMap[coupleId] = couple
  local roleAPos = roleA:GetPos()
  local roleADir = roleA:GetDir()
  local fellowCfgId = p.extra_infos[MapGroupExtraInfoType.MASSWEDDING_GROOMSMAN]
  local fellowCfg = require("Main.Marriage.MarriageUtils").GetWeddingFellowCfg(fellowCfgId)
  if fellowCfg then
    local npcCfgA = NPCInterface.GetNPCCfg(fellowCfg.theBestMan)
    if npcCfgA then
      local npcA = ECPlayer.new(Int64.new(), npcCfgA.monsterModelTableId, npcCfgA.npcName, Color.green, RoleType.NPC)
      npcA.defaultLayer = ClientDef_Layer.NPC
      npcA:SetTouchable(false)
      npcA:LoadCurrentModel(roleAPos.x + weddingOffset2.x, roleAPos.y + weddingOffset2.y, roleADir)
      couple.npcA = npcA
    end
    local npcCfgB = NPCInterface.GetNPCCfg(fellowCfg.bridesMaid)
    if npcCfgB then
      local npcB = ECPlayer.new(Int64.new(), npcCfgB.monsterModelTableId, npcCfgB.npcName, Color.green, RoleType.NPC)
      npcB.defaultLayer = ClientDef_Layer.NPC
      npcB:SetTouchable(false)
      npcB:LoadCurrentModel(roleAPos.x + weddingOffset.x + weddingOffset2.x, roleAPos.y + weddingOffset.y + weddingOffset2.y, roleADir)
      couple.npcB = npcB
    end
  end
  roleA:Stop()
  roleB:Stop()
  roleB:SetPos(roleAPos.x + weddingOffset.x, roleAPos.y + weddingOffset.y)
  local keyPath = p.key_point_path
  if #keyPath > 0 then
    roleA:RunPath(keyPath, couple.speed, nil)
    roleA:RunByWalk(true)
    roleB:RunPath(OffsetPath(keyPath, weddingOffset.x, weddingOffset.y), couple.speed, nil)
    roleB:RunByWalk(true)
    if couple.npcA then
      couple.npcA:RunPath(OffsetPath(keyPath, weddingOffset2.x, weddingOffset2.y), couple.speed, nil)
      couple.npcA:RunByWalk(true)
    end
    if couple.npcB then
      couple.npcB:RunPath(OffsetPath(keyPath, weddingOffset.x + weddingOffset2.x, weddingOffset.y + weddingOffset2.y), couple.speed, nil)
      couple.npcB:RunByWalk(true)
    end
  end
end
def.static("table").OnSMapGroupWedingEnterView = function(p)
  local coupleId = p.groupid:tostring()
  if p.leader_info == nil or p.other_member_infos == nil or #p.other_member_infos ~= 1 then
    return
  end
  local coupleA = p.leader_info
  local coupleB = p.other_member_infos[1]
  local pos = p.cur_pos
  local path = p.key_point_path
  local aid = coupleA.roleid:tostring()
  local roleA = instance.rolesMap[aid]
  if roleA == nil then
    local modelInfo = GetModelInfo(coupleA.model_info)
    instance:CreateRole(coupleA.roleid, modelInfo, pos.x, pos.y, p.direction, Color.green, RoleType.ROLE)
    roleA = instance.rolesMap[aid]
    instance.visiblePlayers[aid] = roleA
  else
  end
  local bid = coupleB.roleid:tostring()
  local roleB = instance.rolesMap[bid]
  if roleB == nil then
    local modelInfo = GetModelInfo(coupleB.model_info)
    instance:CreateRole(coupleB.roleid, modelInfo, pos.x + weddingOffset.x, pos.y + weddingOffset.y, p.direction, Color.green, RoleType.ROLE)
    roleB = instance.rolesMap[bid]
    instance.visiblePlayers[bid] = roleB
  else
  end
  if roleA and roleB then
    local couple = {}
    couple.aid = aid
    couple.bid = bid
    couple.speed = p.group_velocity
    instance.groupWeddingMap[coupleId] = couple
    local roleADir = roleA:GetDir()
    local fellowCfgId = p.extra_infos[MapGroupExtraInfoType.MASSWEDDING_GROOMSMAN]
    local fellowCfg = require("Main.Marriage.MarriageUtils").GetWeddingFellowCfg(fellowCfgId)
    if fellowCfg then
      local npcCfgA = NPCInterface.GetNPCCfg(fellowCfg.theBestMan)
      if npcCfgA then
        local npcA = ECPlayer.new(Int64.new(), npcCfgA.monsterModelTableId, npcCfgA.npcName, Color.green, RoleType.NPC)
        npcA.defaultLayer = ClientDef_Layer.NPC
        npcA:SetTouchable(false)
        npcA:LoadCurrentModel(pos.x + weddingOffset2.x, pos.y + weddingOffset2.y, roleADir)
        couple.npcA = npcA
      end
      local npcCfgB = NPCInterface.GetNPCCfg(fellowCfg.bridesMaid)
      if npcCfgB then
        local npcB = ECPlayer.new(Int64.new(), npcCfgB.monsterModelTableId, npcCfgB.npcName, Color.green, RoleType.NPC)
        npcB.defaultLayer = ClientDef_Layer.NPC
        npcB:SetTouchable(false)
        npcB:LoadCurrentModel(pos.x + weddingOffset.x + weddingOffset2.x, pos.y + weddingOffset.y + weddingOffset2.y, roleADir)
        couple.npcB = npcB
      end
    end
    if #path > 0 then
      roleA:RunPath(path, couple.speed, nil)
      roleA:RunByWalk(true)
      roleB:RunPath(OffsetPath(path, weddingOffset.x, weddingOffset.y), couple.speed, nil)
      roleB:RunByWalk(true)
      if couple.npcA then
        couple.npcA:RunPath(OffsetPath(path, weddingOffset2.x, weddingOffset2.y), couple.speed, nil)
        couple.npcA:RunByWalk(true)
      end
      if couple.npcB then
        couple.npcB:RunPath(OffsetPath(path, weddingOffset.x + weddingOffset2.x, weddingOffset.y + weddingOffset2.y), couple.speed, nil)
        couple.npcB:RunByWalk(true)
      end
    else
      roleA:SetPos(pos.x, pos.y)
      roleB:SetPos(pos.x + weddingOffset.x, pos.y + weddingOffset.y)
      local action = p.extra_infos[MapGroupExtraInfoType.MASSWEDDING_TRIGGER_TYPE] or 0
      instance:WedingAction(couple, action)
    end
  end
end
def.static("table").OnSMapGroupWedingSyncPos = function(p)
  local couple = instance.groupWeddingMap[p.groupid:tostring()]
  if couple then
    local coupleA = instance.rolesMap[couple.aid]
    local coupleB = instance.rolesMap[couple.bid]
    local path = p.key_point_path
    if path then
      coupleA:RunPath(path, couple.speed, nil)
      coupleA:RunByWalk(true)
      coupleB:RunPath(OffsetPath(path, weddingOffset.x, weddingOffset.y), couple.speed, nil)
      coupleB:RunByWalk(true)
      if couple.npcA then
        couple.npcA:RunPath(OffsetPath(path, weddingOffset2.x, weddingOffset2.y), couple.speed, nil)
        couple.npcA:RunByWalk(true)
      end
      if couple.npcB then
        couple.npcB:RunPath(OffsetPath(path, weddingOffset.x + weddingOffset2.x, weddingOffset.y + weddingOffset2.y), couple.speed, nil)
        couple.npcB:RunByWalk(true)
      end
    end
  end
end
def.static("table").OnSMapGroupWedingTransferPos = function(p)
  warn("can not transfer map when watch moon")
end
def.static("table").OnSMapGroupWedingLeaveView = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.groupWeddingMap[coupleId]
  if couple then
    local myRoleIdStr = GetMyRoleID():tostring()
    if couple.aid == myRoleIdStr or couple.bid == myRoleIdStr then
      return
    end
    instance:DestroyRole(couple.aid)
    instance:DestroyRole(couple.bid)
    if couple.npcA then
      couple.npcA:Destroy()
      couple.npcA = nil
    end
    if couple.npcB then
      couple.npcB:Destroy()
      couple.npcB = nil
    end
  end
  instance.groupWeddingMap[coupleId] = nil
end
def.static("table").OnSMapGroupWedingDissole = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.groupWeddingMap[coupleId]
  if couple then
    local myRoleId = GetMyRoleID():tostring()
    if couple.aid == myRoleId or couple.bid == myRoleId then
      instance.inGroupWedding = false
    end
    local roleA = instance.rolesMap[couple.aid]
    local roleB = instance.rolesMap[couple.bid]
    if roleA then
      local roledata = instance.invisiblePlayers[couple.aid]
      if roledata then
        roledata.pos = roleA:GetPos()
      end
      instance:ResetRole(roleA)
      roleA:RunByWalk(false)
    end
    if roleB then
      local roledata = instance.invisiblePlayers[couple.bid]
      if roledata then
        roledata.pos = roleB:GetPos()
      end
      instance:ResetRole(roleB)
      roleB:RunByWalk(false)
    end
    if couple.npcA then
      couple.npcA:Destroy()
      couple.npcA = nil
    end
    if couple.npcB then
      couple.npcB:Destroy()
      couple.npcB = nil
    end
  end
  instance.groupWeddingMap[coupleId] = nil
end
def.static("table").OnSMapGroupWedingExtraInfoChange = function(p)
  warn("-----OnSMapGroupWedingExtraInfoChange:", p.groupid, p.extra_infos[MapGroupExtraInfoType.MASSWEDDING_TRIGGER_TYPE])
  local coupleId = p.groupid:tostring()
  local couple = instance.groupWeddingMap[coupleId]
  if couple then
    local action = p.extra_infos[MapGroupExtraInfoType.MASSWEDDING_TRIGGER_TYPE] or 0
    instance:WedingAction(couple, action)
  end
end
local actionToAnimation = {
  [2] = "FeiWen_c",
  [3] = "BaiTang_c",
  [4] = "FeiWen_c"
}
def.method("table", "number").WedingAction = function(self, couple, action)
  if actionToAnimation[action] and couple then
    do
      local roleA = instance.rolesMap[couple.aid]
      local roleB = instance.rolesMap[couple.bid]
      if roleA and roleB then
        roleA:Stop()
        roleB:Stop()
        if couple.npcA then
          couple.npcA:Stop()
        end
        if couple.npcB then
          couple.npcB:Stop()
        end
        do
          local ani = actionToAnimation[action]
          local doAction = function(ra, rb, ani)
            ra:LookAtTarget(rb)
            ra:Play(ani)
          end
          if roleA.m_model and not roleA.m_model.isnil then
            doAction(roleA, roleB, ani)
          elseif roleA.m_model == nil and roleA:IsInLoading() then
            roleA:AddOnLoadCallback("wedding", function()
              doAction(roleA, roleB, ani)
            end)
          end
          if roleB.m_model and not roleB.m_model.isnil then
            doAction(roleB, roleA, ani)
          elseif roleB.m_model == nil and roleB:IsInLoading() then
            roleB:AddOnLoadCallback("wedding", function()
              doAction(roleB, roleA, ani)
            end)
          end
        end
      end
    end
  end
end
def.method("userdata", "function").ReqRoleInfo = function(self, roleId, onResRoleInfo)
  local strRoleId = tostring(roleId)
  local alreadyReq = false
  local reqList = self.pendingRoleInfoReqList[strRoleId]
  if reqList then
    alreadyReq = true
    local alreadyAdded = false
    for i, callback in ipairs(reqList) do
      if callback == onResRoleInfo then
        alreadyAdded = true
        break
      end
    end
    if not alreadyAdded then
      table.insert(reqList, onResRoleInfo)
    end
    local curTime = _G.GetServerTime()
    local WAIT_SECONDS = 3
    if curTime > reqList.sendTime + WAIT_SECONDS then
      reqList.sendTime = curTime
      self:C2S_GetRoleInfoReq(roleId)
    end
  else
    self.pendingRoleInfoReqList[strRoleId] = {
      sendTime = _G.GetServerTime()
    }
    table.insert(self.pendingRoleInfoReqList[strRoleId], onResRoleInfo)
    self:C2S_GetRoleInfoReq(roleId)
  end
end
def.method("userdata").C2S_GetRoleInfoReq = function(self, roleId)
  local p = require("netio.protocol.mzm.gsp.role.CGetRoleInfoReq").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetRoleInfoRes = function(p)
  local reqList = instance.pendingRoleInfoReqList[tostring(p.roleInfo.roleId)]
  if reqList == nil then
    return
  end
  for i, callback in ipairs(reqList) do
    callback(p.roleInfo)
  end
  instance.pendingRoleInfoReqList[tostring(p.roleInfo.roleId)] = nil
end
def.method("userdata", "function").ReqRoleModelInfo = function(self, roleId, callback)
  local strRoleId = tostring(roleId)
  local alreadyReq = false
  if self.pendingRoleModelInfoCallbacks[strRoleId] then
    alreadyReq = true
    local alreadyAdded = false
    for i, cb in ipairs(self.pendingRoleModelInfoCallbacks) do
      if cb == callback then
        alreadyAdded = true
        break
      end
    end
    if not alreadyAdded then
      table.insert(self.pendingRoleModelInfoCallbacks[strRoleId], callback)
    end
  else
    self.pendingRoleModelInfoCallbacks[strRoleId] = {}
    table.insert(self.pendingRoleModelInfoCallbacks[strRoleId], callback)
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.role.CGetRoleModelInfo").new(roleId))
end
def.static("table").OnSSendRoleModelInfo = function(p)
  local strRoleId = tostring(p.targetRoleId)
  local reqList = instance.pendingRoleModelInfoCallbacks[strRoleId]
  if reqList == nil then
    return
  end
  for i, callback in ipairs(reqList) do
    callback(p.model)
  end
  instance.pendingRoleModelInfoCallbacks[strRoleId] = nil
end
def.method("userdata", "function").AsyncGetRoleName = function(self, roleId, callback)
  self.roleNameCache = self.roleNameCache or LRUCache.new("RoleNameCache", PubroleModule.ROLE_NAME_CACHE_LIMIT)
  local strRoleId = tostring(roleId)
  local cacheData = self.roleNameCache:Get(strRoleId)
  if cacheData == nil then
    self:ReqRoleName(roleId, function(retRoleId, roleName)
      cacheData = {roleName = roleName}
      self.roleNameCache:Set(strRoleId, cacheData)
      _G.SafeCallback(callback, retRoleId, roleName)
    end)
  else
    local roleName = cacheData.roleName
    _G.SafeCallback(callback, roleId, roleName)
  end
end
def.method("userdata", "function").ReqRoleName = function(self, roleId, onResRoleName)
  local strRoleId = tostring(roleId)
  self.pendingRoleNameReqs = self.pendingRoleNameReqs or {}
  local req = self.pendingRoleNameReqs[strRoleId]
  local curTime = _G.GetServerTime()
  if req == nil then
    req = {}
    req.callbackList = {onResRoleName}
    self.pendingRoleNameReqs[strRoleId] = req
  else
    local notAdded = true
    for i, callback in ipairs(req.callbackList) do
      if callback == onResRoleName then
        notAdded = false
        break
      end
    end
    if notAdded then
      table.insert(req.callbackList, onResRoleName)
    end
    if math.abs(curTime - req.sendTime) < 1 then
      return
    end
  end
  req.sendTime = curTime
  local p = require("netio.protocol.mzm.gsp.role.CGetRoleNameReq").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetRoleNameRep = function(p)
  local roleId = p.checkedRoleId
  local req = instance.pendingRoleNameReqs[tostring(roleId)]
  if req == nil then
    return
  end
  local roleName = _G.GetStringFromOcts(p.checkedRoleName)
  for i, callback in ipairs(req.callbackList) do
    callback(roleId, roleName)
  end
  instance.pendingRoleNameReqs[tostring(roleId)] = nil
  if table.nums(instance.pendingRoleNameReqs) == 0 then
    instance.pendingRoleNameReqs = nil
  end
end
def.static("table").OnSSyncLand = function(p)
  local roleId = p.roleid
  local tarX = p.pos.x
  local tarY = p.pos.y
  local role = instance.rolesMap[roleId:tostring()]
  if role == nil then
    return
  end
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if roleId == heroMgr:GetMyRoleId() then
  else
    role:FlyToDown(tarX, tarY, nil)
  end
end
def.static("table").OnSSyncMapFly = function(p)
  local roleId = p.roleId
  local tarX = p.targetPos.x
  local tarY = p.targetPos.y
  local role = instance.rolesMap[roleId:tostring()]
  if role == nil then
    return
  end
  local curX = role.m_node2d.localPosition.x
  local curY = role.m_node2d.localPosition.y
  local HeroModule = require("Main.Hero.HeroModule")
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if roleId == heroMgr:GetMyRoleId() then
  else
    role:FlyUpTo(tarX, tarY, nil)
  end
end
def.static("table").OnSSyncMapFlyError = function(p)
  local ret = p.ret
  local errStr = textRes.Hero.FlyError[ret]
  if errStr then
    Toast(errStr)
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule.myRole then
    heroModule.myRole:FlyDown(nil)
  end
end
def.static("table").OnSSyncLandError = function(p)
  local ret = p.ret
  local errStr = textRes.Hero.LandError[ret]
  if errStr then
    Toast(errStr)
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule.myRole then
    heroModule.myRole:FlyUp(nil)
  end
end
def.static("table").OnSForceLandRes = function(p)
  local roleId = p.roleid
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if roleId == heroModule.roleId then
    heroModule:FlyDown()
  else
    local role = instance.rolesMap[roleId:tostring()]
    if role and role:IsInState(RoleState.FLY) then
      role:FlyDown(nil)
    end
  end
end
def.static("table").OnSMapCoupleForceLand = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.coupleMap[coupleId]
  if couple then
    local roleA = instance.rolesMap[couple.aid]
    local roleB = instance.rolesMap[couple.bid]
    if roleA then
      roleA:UnHug()
      if roleA:IsInState(RoleState.FLY) then
        roleA:FlyDown(nil)
      end
    end
    if roleB then
      roleB:FlyDown(nil)
    end
  end
  instance.coupleMap[coupleId] = nil
end
def.static("table").OnSMapWatchMoonCoupleForceLand = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.watchMoonMap2[coupleId]
  if couple then
    local roleA = instance.rolesMap[couple.aid]
    local roleB = instance.rolesMap[couple.bid]
    if roleA then
      roleA:UnHug()
      if roleA:IsInState(RoleState.FLY) then
        roleA:FlyDown(nil)
      end
    end
    if roleB then
      roleB:FlyDown(nil)
    end
  end
  instance.watchMoonMap2[coupleId] = nil
end
def.static("table").OnSMapWatchMoonForceLand = function(p)
  local coupleId = p.groupid:tostring()
  local couple = instance.watchMoonMap1[coupleId]
  if couple then
    local roleA = instance.rolesMap[couple.aid]
    local roleB = instance.rolesMap[couple.bid]
    if roleA then
      roleA:FlyDown(nil)
    end
    if roleB then
      roleB:FlyDown(nil)
    end
  end
  instance.watchMoonMap1[coupleId] = nil
end
def.static("table").OnSTeamForceLandRes = function(p)
  instance:ForceTeamLand(p.teamid)
end
def.method("userdata").ForceTeamLand = function(self, teamId)
  if teamId == nil then
    return
  end
  local team = instance.teamMap[teamId:tostring()]
  if team == nil then
    return
  end
  for _, v in pairs(team.members) do
    if v:IsInState(RoleState.FLY) then
      v:FlyDown(nil)
    end
  end
end
def.static("table").OnSGetMonsterLocationRes = function(p)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.GET_MONSTER_POS, p.monsterList)
end
def.static("table").OnSSyncRoleStatusChange = function(p)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local role = instance:GetRole(p.roleId)
  local role_data = instance.invisiblePlayers[p.roleId:tostring()]
  if role_data == nil then
    return
  end
  local statusChanged = BitMap.new()
  for i = 1, #p.addList do
    local addStatus = p.addList[i]
    table.insert(role_data.modelInfo.role_status_list, addStatus)
    if addStatus == ROLE_SERVER_STATUS.STATUS_FIGHT then
      if role then
        role:SetState(RoleState.BATTLE)
        role:Pause(true)
        role:SetBattleIcon(RESPATH.MODEL_BATTLE_ICON)
      end
      statusChanged.Set(RoleState.BATTLE)
    elseif addStatus == ROLE_SERVER_STATUS.FLY then
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_ARENA then
      if role then
        role:SetState(RoleState.TXHW)
      end
      statusChanged.Set(RoleState.TXHW)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_MENPAI_PVP then
      if role then
        role:SetState(RoleState.SXZB)
      end
      statusChanged.Set(RoleState.SXZB)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_OBSERVE then
      if role then
        role:SetState(RoleState.WATCH)
        role:AddTop3DEffect(702017207, 0.6)
      end
      statusChanged.Set(RoleState.WATCH)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_PARASELENE then
      if role then
        role:SetState(RoleState.PHANTOMCAVE)
      end
      statusChanged.Set(RoleState.PHANTOMCAVE)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_COMPETE then
      if role then
        role:SetState(RoleState.GANGBATTLE)
      end
      statusChanged.Set(RoleState.GANGBATTLE)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_CROSS_COMPETE_ROAM then
      if role then
        role:SetState(RoleState.GANGCROSS_BATTLE)
      end
      statusChanged.Set(RoleState.GANGCROSS_BATTLE)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_COMPETE_PROTECTED then
      if role then
        role:SetState(RoleState.PROTECTED)
        if role:IsInState(RoleState.GANGBATTLE) then
          GangBattleMgr.Instance():SetProtectRoleName(role)
        elseif role:IsInState(RoleState.GANGCROSS_BATTLE) then
          GangCrossBattleMgr.Instance():SetProtectRoleName(role)
        end
      end
      statusChanged.Set(RoleState.PROTECTED)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_MARRIAGE_PARADE then
      instance:StartWeddingParade(p.roleId)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_QMHW then
      if role then
        role:SetState(RoleState.QMHW)
      end
      statusChanged.Set(RoleState.QMHW)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_PREGNANT then
      if role then
        role:AddTop3DEffect(702020100, 0.6)
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE then
      if role then
        role:SetState(RoleState.SINGLEBATTLE)
      end
      statusChanged.Set(RoleState.SINGLEBATTLE)
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_DEAD then
      if role then
        role:SetState(RoleState.SINGLEBATTLE_DEATH)
        role:Die()
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_REVIVE_PROTECT then
      if role then
        role:SetState(RoleState.SINGLEBATTLE_PROTECT)
        BattleFieldMgr.Instance():SetProtect(role)
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_GRABING then
      if role then
        role:Action()
        local iconId = BattleFieldMgr.Instance():GetGrabIconId(role.roleId)
        if iconId > 0 then
          role:SetTopButton(iconId, "capture")
        end
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_GATHERING then
      if role then
        local resourcePath, resourceType = GetIconPath(constant.SingleBattleConsts.gatherStateIcon)
        if resourcePath ~= "" and resourceType == 1 then
          role:AddChildEffect(resourcePath, BODY_PART.HEAD, "", 0.8)
        end
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_PK_ENABLED then
      if role then
        role:SetState(RoleState.PLAYER_PK_ON)
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_PK_PROTECTION then
      if role then
        role:SetState(RoleState.PLAYER_PK_PROTECTION)
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_PK_FORCE_PROTECTION then
      if role then
        role:SetState(RoleState.PLAYER_PK_FORCE_PROTECTION)
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_PK_PRISON then
      if role then
        role:SetState(RoleState.PRISON)
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_LIMIT_MOVEMENT then
      if role then
        role:SetState(RoleState.ROOTS)
        role:Stop()
      end
    elseif addStatus == ROLE_SERVER_STATUS.STATUS_BALL_BATTLE_IN_GAME_MAP and role then
      role:SetState(RoleState.BALL_ARENA)
    end
  end
  for i = 1, #p.removeList do
    local removeStatus = p.removeList[i]
    local rsl = role_data.modelInfo.role_status_list
    local st_idx
    for idx = 1, #rsl do
      if rsl[idx] == removeStatus then
        st_idx = idx
        break
      end
    end
    if st_idx and st_idx <= #rsl then
      table.remove(rsl, st_idx)
    end
    if removeStatus == ROLE_SERVER_STATUS.STATUS_FIGHT then
      if role then
        role:RemoveState(RoleState.BATTLE)
        role:SetBattleIcon("")
      end
      statusChanged.Set(RoleState.BATTLE)
    elseif removeStatus == ROLE_SERVER_STATUS.FLY then
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_ARENA then
      if role then
        role:RemoveState(RoleState.TXHW)
      end
      statusChanged.Set(RoleState.TXHW)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_MENPAI_PVP then
      if role then
        role:RemoveState(RoleState.SXZB)
      end
      statusChanged.Set(RoleState.SXZB)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_OBSERVE then
      if role then
        role:RemoveState(RoleState.WATCH)
        role:RemoveTop3DEffect(702017207)
      end
      statusChanged.Set(RoleState.WATCH)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_PARASELENE then
      if role then
        role:RemoveState(RoleState.PHANTOMCAVE)
      end
      statusChanged.Set(RoleState.PHANTOMCAVE)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_COMPETE then
      if role then
        role:RemoveState(RoleState.GANGBATTLE)
        GangBattleMgr.Instance():RecoverRoleName(role)
      end
      statusChanged.Set(RoleState.GANGBATTLE)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_CROSS_COMPETE_ROAM then
      if role then
        role:RemoveState(RoleState.GANGCROSS_BATTLE)
        GangCrossBattleMgr.Instance():RecoverRoleName(role)
      end
      statusChanged.Set(RoleState.GANGCROSS_BATTLE)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_COMPETE_PROTECTED then
      if role then
        role:RemoveState(RoleState.PROTECTED)
        if role:IsInState(RoleState.GANGBATTLE) then
          GangBattleMgr.Instance():SetNormalRoleName(role)
        elseif role:IsInState(RoleState.GANGCROSS_BATTLE) then
          GangCrossBattleMgr.Instance():SetNormalRoleName(role)
        else
          GangBattleMgr.Instance():RecoverRoleName(role)
        end
      end
      statusChanged.Set(RoleState.PROTECTED)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_MARRIAGE_PARADE then
      instance:StopWeddingParade(p.roleId)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_QMHW then
      if role then
        role:RemoveState(RoleState.QMHW)
      end
      statusChanged.Set(RoleState.QMHW)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_PREGNANT then
      if role then
        role:RemoveTop3DEffect(702020100)
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE then
      if role then
        role:RemoveState(RoleState.SINGLEBATTLE)
      end
      statusChanged.Set(RoleState.SINGLEBATTLE)
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_DEAD then
      if role then
        role:RemoveState(RoleState.SINGLEBATTLE_DEATH)
        role:Reborn()
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_REVIVE_PROTECT then
      if role then
        role:RemoveState(RoleState.SINGLEBATTLE_PROTECT)
        BattleFieldMgr.Instance():SetUnProtect(role)
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_GRABING then
      if role then
        role:CancelAction()
        role:DestroyTopButton("capture")
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_GATHERING then
      if role then
        local resourcePath, resourceType = GetIconPath(constant.SingleBattleConsts.gatherStateIcon)
        if resourcePath ~= "" then
          role:StopChildEffect(resourcePath)
        end
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_PK_ENABLED then
      if role then
        role:RemoveState(RoleState.PLAYER_PK_ON)
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_PK_PROTECTION then
      if role then
        role:RemoveState(RoleState.PLAYER_PK_PROTECTION)
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_PK_FORCE_PROTECTION then
      if role then
        role:RemoveState(RoleState.PLAYER_PK_FORCE_PROTECTION)
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_PK_PRISON then
      if role then
        role:RemoveState(RoleState.PRISON)
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_LIMIT_MOVEMENT then
      if role then
        role:RemoveState(RoleState.ROOTS)
      end
    elseif removeStatus == ROLE_SERVER_STATUS.STATUS_BALL_BATTLE_IN_GAME_MAP and role then
      role:RemoveState(RoleState.BALL_ARENA)
    end
  end
  if heroMgr.roleId and p.roleId:eq(heroMgr.roleId) then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, {statusChanged})
  end
end
def.static("table").OnSBroadcastPositionInScene = function(p)
  local self = instance
  self.mapRoleLocs = self.mapRoleLocs or {}
  self.mapRoleLocs[tostring(p.roleid)] = p.pos
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.MAP_ROLE_POS_UPDATE, {
    roleId = p.roleid,
    pos = p.pos
  })
end
def.override().OnReset = function(self)
  if self.weddingScene then
    self:EndWedding()
  end
  self:RemoveAllMapRoles(true, nil)
  self.pendingRoleInfoReqList = {}
  self.pendingRoleModelInfoCallbacks = {}
  self.pendingRoleNameReqs = nil
  self.roleNameCache = nil
  self.itemMap = {}
  self.npcMapToRole = nil
  self.enterViewRolesInFight = nil
  self.enterViewTeamsInFight = nil
  self.changemap_target_pos = nil
  self.MonstersInAir = nil
  self.forcedPlayerNum = -1
  self.npcChangeModelMap = nil
  self.inGroupWedding = false
  self.userNpcMap = {}
  self.disabledNpcList = nil
  self.npcStateMap = nil
  if self.MapNpcCfg then
    local curMapNpcs = self.MapNpcCfg[gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId]
    if curMapNpcs then
      for _, v in pairs(curMapNpcs) do
        v.isVisible = v.defaultVisible
      end
    end
  end
end
def.static("table", "table").OnStartDrama = function()
  instance.isPlayingCG = true
  for _, v in pairs(instance.rolesMap) do
    v:SetVisible(false)
    local pet = v:GetPet()
    if pet then
      pet:SetVisible(false)
    end
  end
  for _, v in pairs(instance.npcMap) do
    v:SetVisible(false)
  end
  for _, v in pairs(instance.monsterMap) do
    v:SetVisible(false)
  end
end
def.static("table", "table").OnEndDrama = function()
  instance.isPlayingCG = false
  instance:SetMaxPlayers()
  for _, v in pairs(instance.npcMap) do
    v:SetVisible(true)
  end
  for _, v in pairs(instance.monsterMap) do
    v:SetVisible(true)
  end
end
def.method("table").EnterOnlyShowSpecificRoles = function(self, roleIds)
  self.isOnlyShowSpecificRoles = true
  self.specificRoles = {}
  for _, v in ipairs(roleIds) do
    self.specificRoles[v] = true
  end
  for k, v in pairs(instance.rolesMap) do
    v:SetVisible(self:IsOneOfSpecificRoles(k))
    local pet = v:GetPet()
    if pet then
      pet:SetVisible(false)
    end
  end
  for _, v in pairs(instance.npcMap) do
    v:SetVisible(false)
  end
  for _, v in pairs(instance.monsterMap) do
    v:SetVisible(false)
  end
end
def.method().QuitOnlyShowSpecificRoles = function(self)
  self.isOnlyShowSpecificRoles = false
  self.specificRoles = nil
  self:SetMaxPlayers()
  for _, v in pairs(self.npcMap) do
    v:SetVisible(true)
  end
  for _, v in pairs(self.monsterMap) do
    v:SetVisible(true)
  end
end
def.method("string", "=>", "boolean").IsOneOfSpecificRoles = function(self, roleId)
  if self.isOnlyShowSpecificRoles then
    if self.specificRoles then
      return self.specificRoles[roleId] and true or false
    else
      return true
    end
  else
    return true
  end
end
def.method("string").AddPriorityVisiblePlayers = function(self, roleIdStr)
  table.insert(self.priorityVisiblePlayers, roleIdStr)
end
def.method("string").RemovePriorityVisiblePlayers = function(self, roleIdStr)
  local idx = 0
  for idx, v in pairs(self.priorityVisiblePlayers) do
    if v == roleIdStr then
      break
    end
  end
  table.remove(self.priorityVisiblePlayers, idx)
end
def.method("string", "=>", "boolean").IsPriorityVisiblePlayer = function(self, roleIdStr)
  for _, v in pairs(self.priorityVisiblePlayers) do
    if v == roleIdStr then
      return true
    end
  end
  return false
end
def.method().SetMaxPlayers = function(self)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local myId = heroMgr.roleId:tostring()
  local Setting_Module = gmodule.moduleMgr:GetModule(ModuleId.SYSTEM_SETTING)
  local setting = Setting_Module:GetSetting(SETTING_ID.LowRoleNumbers)
  local isShowModel = self:IsShowOtherPlayers()
  self.visiblePlayers = {}
  self:SetMaxVisibleNum()
  local count = 0
  self.visiblePlayers[myId] = heroMgr.myRole
  if heroMgr.myRole and heroMgr.myRole.interaction then
    self.visiblePlayers[heroMgr.myRole.interaction.roleId:tostring()] = heroMgr.myRole.interaction
  end
  if self:IsInWeddingParade() then
    local paradeSceneInfo = self:GetParadeSceneInfo()
    if paradeSceneInfo and paradeSceneInfo.groom and paradeSceneInfo.bride then
      self.visiblePlayers[paradeSceneInfo.groom.roleId:tostring()] = paradeSceneInfo.goom
      self.visiblePlayers[paradeSceneInfo.bride.roleId:tostring()] = paradeSceneInfo.bride
    end
  end
  for k, v in ipairs(self.groupWeddingMap) do
    local roleA = instance.rolesMap[couple.aid]
    self.visiblePlayers[v.aid] = roleA
    local roleB = instance.rolesMap[couple.bid]
    self.visiblePlayers[v.bid] = roleB
  end
  local ret, coupleId = self:IsOneOfCoupleFly(myId)
  if ret then
    local couple = instance.coupleMap[coupleId]
    if couple then
      local roleA = instance.rolesMap[couple.aid]
      local roleB = instance.rolesMap[couple.bid]
      self.visiblePlayers[couple.aid] = roleA
      self.visiblePlayers[couple.bid] = roleB
    end
  end
  if self.coupleMap then
    local showCoupleCount = math.floor((self.max_visible_players_num - table.nums(self.visiblePlayers)) / 3)
    local visibleCount = 0
    for k, v in pairs(self.coupleMap) do
      if showCoupleCount > visibleCount then
        self.visiblePlayers[v.aid] = instance.rolesMap[v.aid]
        self.visiblePlayers[v.bid] = instance.rolesMap[v.bid]
        visibleCount = visibleCount + 2
      end
    end
  end
  local myTeamId = require("Main.Team.TeamData").Instance().teamId
  myTeamId = myTeamId and myTeamId:tostring()
  if myTeamId then
    local myteam = self.teamMap[myTeamId]
    if myteam and myteam.members then
      for _, v in pairs(myteam.members) do
        self.visiblePlayers[v.roleId:tostring()] = v
      end
    end
  end
  local showTeamMountNumber = GetSysConstCfg("thresholdToShowMultiRoleMounts")
  local leftspace = self.max_visible_players_num - table.nums(self.visiblePlayers)
  if showTeamMountNumber < leftspace then
    for k, v in pairs(self.teamMap) do
      if showTeamMountNumber > 0 and (myTeamId == nil or k ~= myTeamId) then
        local leader = v.members and v.members[1]
        if leader and v.mountSeatMap then
          showTeamMountNumber = showTeamMountNumber - 1
          local leaderIdStr = leader.roleId:tostring()
          self.visiblePlayers[leaderIdStr] = leader
          for idx, rid in pairs(v.mountSeatMap) do
            if rid ~= leaderIdStr then
              local member = self.rolesMap[rid]
              if member then
                self.visiblePlayers[rid] = member
                leader:AttachToMount(member, idx)
                showTeamMountNumber = showTeamMountNumber - 1
              else
                local roledata = self.invisiblePlayers[rid]
                if roledata then
                  member = self:CreateRoleModel(roledata)
                  if member then
                    self.visiblePlayers[rid] = member
                    leader:AttachToMount(member, idx)
                    showTeamMountNumber = showTeamMountNumber - 1
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  local showTeamCount = math.floor((self.max_visible_players_num - table.nums(self.visiblePlayers)) / 2)
  local visibleCount = 0
  for k, v in pairs(self.teamMap) do
    if showTeamCount > visibleCount and (myTeamId == nil or k ~= myTeamId) and v.members and 0 < #v.members then
      local leaderIdStr = v.members[1].roleId:tostring()
      self.visiblePlayers[leaderIdStr] = v.members[1]
      visibleCount = visibleCount + 1
    end
  end
  if showTeamCount > visibleCount then
    for k, v in pairs(self.teamMap) do
      if showTeamCount > visibleCount and (myTeamId == nil or k ~= myTeamId) and v.members and #v.members == 0 then
        local memberId = v.memberIds[1]
        if memberId then
          local memberIdStr = memberId:tostring()
          local leader = self.rolesMap[memberIdStr]
          if leader == nil then
            local memberdata = self.invisiblePlayers[memberIdStr]
            if memberdata then
              leader = self:CreateRoleModel(memberdata)
            end
          end
          if leader then
            leader:SetTeamId(v.teamId)
            instance:SetTeamIcon(leader, v.memNum == 5)
            self.visiblePlayers[memberIdStr] = leader
            visibleCount = visibleCount + 1
          end
        end
      end
    end
  end
  count = table.nums(self.visiblePlayers)
  local diff = self.max_visible_players_num - count
  if diff > 0 then
    for k, v in pairs(self.invisiblePlayers) do
      if v.teamId == nil then
        if self.rolesMap[k] == nil then
          self:CreateRoleModel(v)
        end
        self.visiblePlayers[k] = self.rolesMap[k]
        diff = diff - 1
        if diff <= 0 then
          break
        end
      end
    end
  end
  for k, v in pairs(self.rolesMap) do
    if self.visiblePlayers[k] then
      if not v.m_visible then
        v:SetVisible(true)
        local pet = v:GetPet()
        if pet then
          pet:SetVisible(true)
        end
      end
      if k ~= myId then
        if heroMgr.myRole == nil then
        else
        end
        if v ~= heroMgr.myRole.interaction then
          if v.showModel ~= isShowModel then
            v:SetShowModel(isShowModel)
          end
        end
      elseif not v.showModel then
        v:SetShowModel(true)
      end
    else
      if v.teamId then
        local team = self.teamMap[v.teamId:tostring()]
        local leader = team.members and team.members[1]
        if leader then
          leader:DetachAllFromMount()
        end
      end
      self:RoleStopFollow(v)
      v:Destroy()
      self.rolesMap[k] = nil
    end
  end
end
def.method().SetShowPlayers = function(self)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local myId = heroMgr.roleId:tostring()
  local myTeamId = heroMgr.myRole.teamId
  local isShowModel = self:IsShowOtherPlayers()
  for k, v in pairs(self.visiblePlayers) do
    if k ~= myId and v.showModel ~= isShowModel and (isShowModel or not v:IsInState(RoleState.PASSENGER) and (v.teamId == nil or myTeamId == nil or not v.teamId:eq(myTeamId) or v:IsInState(RoleState.FOLLOW)) and v:GetInteractionRole() ~= heroMgr.myRole) then
      v:SetShowModel(isShowModel)
    end
  end
end
def.static("table", "table").OnSettingChanged = function(params)
  local id = params[1]
  if id == SETTING_ID.LowRoleNumbers then
    instance:SetMaxPlayers()
  elseif id == SETTING_ID.HideOtherPlayers then
    instance:SetShowPlayers()
  elseif id == SystemSettingModule.SystemSetting.FPS_HIGH then
    local setting = SystemSettingModule.Instance():GetSetting(id)
    if setting.isEnabled then
      ECGame.Instance():SetHighQualityFrame(3)
    end
  elseif id == SystemSettingModule.SystemSetting.FPS_MEDIUM then
    local setting = SystemSettingModule.Instance():GetSetting(id)
    if setting.isEnabled then
      ECGame.Instance():SetHighQualityFrame(2)
    end
  elseif id == SystemSettingModule.SystemSetting.FPS_LOW then
    local setting = SystemSettingModule.Instance():GetSetting(id)
    if setting.isEnabled then
      ECGame.Instance():SetHighQualityFrame(1)
    end
  elseif id == SystemSettingModule.SystemSetting.CloseTouchListPanel then
    local setting = SystemSettingModule.Instance():GetSetting(id)
    _G.show_touch_list = not setting.isEnabled
  end
end
def.static("table", "table").OnStatusDeleted = function(p1, p2)
  local roleId = p1[1]:tostring()
  local status = p1[2]
  local role = instance.rolesMap[roleId]
  if role then
    if status == ROLE_SERVER_STATUS.STATUS_FLY then
      if instance:IsInFollowState(Int64.new(roleId)) then
        return
      end
      local ret, coupleId = instance:IsOneOfCoupleFly(roleId)
      if ret then
        local couple = instance.coupleMap[coupleId]
        if couple then
          local roleA = instance.rolesMap[couple.aid]
          local roleB = instance.rolesMap[couple.bid]
          roleA:UnHug()
          role:FlyDown(nil)
          instance.coupleMap[coupleId] = nil
        end
      else
        role:FlyDown(nil)
      end
    elseif status == ROLE_SERVER_STATUS.STATUS_COUPLE_RIDE then
      local ret, coupleId = instance:IsOneOfCoupleFly(roleId)
      if ret then
        local couple = instance.coupleMap[coupleId]
        if couple then
          local roleA = instance.rolesMap[couple.aid]
          local roleB = instance.rolesMap[couple.bid]
          roleA:UnHug()
          instance.coupleMap[coupleId] = nil
        end
      end
    end
  else
  end
end
def.method("userdata", "=>", "boolean").isPvpEnable = function(self, roleId)
  local role = self.rolesMap[roleId:tostring()]
  if role == nil then
    return false
  end
  local x, y, z = role.m_node2d:GetPosXYZ()
  if not map_scene then
    map_scene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
  end
  return MapScene.IsPvp(map_scene, x, y)
end
def.method("userdata", "userdata", "=>", "boolean").IsTeamLeader = function(self, roleId, teamId)
  if roleId == nil or teamId == nil then
    return false
  end
  local teamIdStr = teamId:tostring()
  local team = self.teamMap[teamIdStr]
  if team == nil or team.memberIds == nil or #team.memberIds == 0 then
    return false
  end
  return roleId:eq(team.memberIds[1])
end
def.method("table", "table", "=>", "table").GetFollowMovePathNodes = function(self, role, target)
  if target == nil or target.movePath == nil then
    return nil
  end
  local pathNodes = {}
  pathNodes[0] = role:GetPos()
  local targetPos = target:GetPos()
  if pathNodes[0] and targetPos and (math.abs(pathNodes[0].x - targetPos.x) > 16 or 16 < math.abs(pathNodes[0].y - targetPos.y)) then
    pathNodes[1] = targetPos
  end
  local idx = #target.movePath - target.pathIdx + 1
  for i = idx, #target.movePath do
    table.insert(pathNodes, target.movePath[i])
  end
  return pathNodes
end
def.method("table", "table", "=>", "boolean").IsClose = function(self, r, t)
  if r == nil or t == nil then
    return false
  end
  local apart = t:GetModelLength() + 1
  local rpos = r:Get3DPos()
  local tpos = t:Get3DPos()
  if rpos == nil or tpos == nil then
    return false
  end
  local dist = rpos - tpos
  return apart > dist:get_Length()
end
def.method("table", "table", "=>", "boolean").IsCloseInSky = function(self, src, dest)
  if src == nil or dest == nil then
    return false
  end
  return math.pow(src.x - dest.x, 2) + math.pow(src.y - dest.y, 2) <= math.pow(PubroleModule.FOLLOW_APART * 2, 2)
end
def.method("table", "number", "=>", "boolean").CheckState = function(self, stateList, state)
  if stateList == nil then
    return false
  end
  for i = 1, #stateList do
    if stateList[i] == state then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").IsShowOtherPlayers = function(self)
  if not self.enableSingleMode then
    return true
  end
  local Setting_Module = gmodule.moduleMgr:GetModule(ModuleId.SYSTEM_SETTING)
  local setting = Setting_Module:GetSetting(SETTING_ID.HideOtherPlayers)
  return not setting.isEnabled
end
def.method("table", "table").SetRoleStatus = function(self, role, statusList)
  if statusList == nil or role == nil then
    return
  end
  for i = 1, #statusList do
    local s = statusList[i]
    if s == ROLE_SERVER_STATUS.STATUS_FIGHT then
      role:SetState(RoleState.BATTLE)
      role:SetBattleIcon(RESPATH.MODEL_BATTLE_ICON)
    elseif s == ROLE_SERVER_STATUS.STATUS_ARENA then
      role:SetState(RoleState.TXHW)
    elseif s == ROLE_SERVER_STATUS.STATUS_MENPAI_PVP then
      role:SetState(RoleState.SXZB)
    elseif s == ROLE_SERVER_STATUS.STATUS_OBSERVE then
      role:SetState(RoleState.WATCH)
      role:AddTop3DEffect(702017207, 0.6)
    elseif s == ROLE_SERVER_STATUS.STATUS_COMPETE then
      role:SetState(RoleState.GANGBATTLE)
    elseif s == ROLE_SERVER_STATUS.STATUS_PARASELENE then
      role:SetState(RoleState.PHANTOMCAVE)
    elseif s == ROLE_SERVER_STATUS.STATUS_COMPETE then
      role:SetState(RoleState.GANGBATTLE)
    elseif s == ROLE_SERVER_STATUS.STATUS_CROSS_COMPETE_ROAM then
      role:SetState(RoleState.GANGCROSS_BATTLE)
    elseif s == ROLE_SERVER_STATUS.STATUS_COMPETE_PROTECTED then
      role:SetState(RoleState.PROTECTED)
    elseif s == ROLE_SERVER_STATUS.STATUS_MARRIAGE_PARADE then
      self:StartWeddingParade(role.roleId)
    elseif s == ROLE_SERVER_STATUS.STATUS_QMHW then
      role:SetState(RoleState.QMHW)
    elseif s == ROLE_SERVER_STATUS.STATUS_FLY then
      local pos = role:GetPos()
      if pos then
        role:FlyAt(pos.x, pos.y, nil)
      end
    elseif s == ROLE_SERVER_STATUS.STATUS_PREGNANT then
      role:AddTop3DEffect(702020100, 0.6)
    elseif s == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE then
      role:SetState(RoleState.SINGLEBATTLE)
    elseif s == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_DEAD then
      role:SetState(RoleState.SINGLEBATTLE_DEATH)
      role:Dead()
    elseif s == ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_REVIVE_PROTECT then
      role:SetState(RoleState.SINGLEBATTLE_PROTECT)
    elseif s == ROLE_SERVER_STATUS.STATUS_PK_ENABLED then
      role:SetState(RoleState.PLAYER_PK_ON)
    elseif s == ROLE_SERVER_STATUS.STATUS_PK_PROTECTION then
      role:SetState(RoleState.PLAYER_PK_PROTECTION)
    elseif s == ROLE_SERVER_STATUS.STATUS_PK_FORCE_PROTECTION then
      role:SetState(RoleState.PLAYER_PK_FORCE_PROTECTION)
    elseif s == ROLE_SERVER_STATUS.STATUS_PK_PRISON then
      role:SetState(RoleState.PRISON)
    elseif s == ROLE_SERVER_STATUS.STATUS_LIMIT_MOVEMENT then
      role:SetState(RoleState.ROOTS)
    elseif s == ROLE_SERVER_STATUS.STATUS_BALL_BATTLE_IN_GAME_MAP then
      role:SetState(RoleState.BALL_ARENA)
    end
  end
end
def.method("userdata", "number", "=>", "userdata").GetRoleModelAdditionalInfo = function(self, roleid, k)
  local roledata = self.invisiblePlayers[roleid:tostring()]
  if roledata == nil then
    return nil
  end
  return roledata.modelInfo.protocol_octets_map[k]
end
local tmp_x, tmp_y, tmp_w, tmp_h
def.method("table", "table", "boolean", "=>", "boolean").CheckOutView = function(self, rpos, tpos, isInAir)
  local extend = 0
  local campos = ECGame.Instance().m_2DWorldCamObj.localPosition
  local cam_x = tpos and tpos.x or campos.x
  local cam_y = tpos and tpos.y or world_height - campos.y
  local tmp_h = ECGame.Instance().m_2DWorldCam.orthographicSize + extend
  local tmp_w = tmp_h * ECGame.Instance().m_2DWorldCam.aspect + extend
  return rpos.x < cam_x - tmp_w or rpos.x > cam_x + tmp_w or rpos.y < cam_y - tmp_h or rpos.y > cam_y + tmp_h
end
def.method().CheckRolesInView = function(self)
  if self.isPlayingCG or fightMgr.isInFight or self.isOnlyShowSpecificRoles then
    return
  end
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole == nil then
    return
  end
  local isInAir = myRole:IsInState(RoleState.FLY)
  for k, v in pairs(self.npcMap) do
    if not isInAir and v.flyMount ~= nil or self:CheckOutView(v:GetPos(), nil, isInAir) then
      self:RemoveNpc(k)
    end
  end
  if self.MapNpcCfg then
    local curMapNpcs = self.MapNpcCfg[gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId]
    if curMapNpcs == nil then
      return
    end
    for k, v in pairs(curMapNpcs) do
      if not self:IsNpcDisabled(k) and v.isVisible and (not v.isInAir or v.isInAir == isInAir) and not self.npcMap[k] and not self:CheckOutView(v, nil, isInAir) then
        self:CreateNpc(v)
      end
    end
  end
  if self.MonstersInAir then
    if isInAir then
      for _, v in pairs(self.MonstersInAir) do
        PubroleModule.OnSMonsterEnterView(v)
      end
    else
      for k, _ in pairs(self.MonstersInAir) do
        self:RemoveMonster(k)
      end
    end
  end
end
def.method().SetMaxVisibleNum = function(self)
  if self.forcedPlayerNum >= 0 then
    self.max_visible_players_num = self.forcedPlayerNum
    return
  end
  local Setting_Module = gmodule.moduleMgr:GetModule(ModuleId.SYSTEM_SETTING)
  local low_role_num_setting = Setting_Module:GetSetting(SETTING_ID.LowRoleNumbers)
  if low_role_num_setting.isEnabled then
    self.max_visible_players_num = math.ceil(max_show_players / 2)
  else
    self.max_visible_players_num = max_show_players
  end
  if self.max_visible_players_num < PubroleModule.DEFAULT_LOW_PLAYERS then
    self.max_visible_players_num = PubroleModule.DEFAULT_LOW_PLAYERS
  end
end
def.static("table", "table").OnChangeMap = function(p1, p2)
  local mapid = p1[1]
  local oldMapId = p1[2]
  if mapid and mapid == 330000998 then
    instance.forcedPlayerNum = 1
    instance:SetMaxPlayers()
  elseif oldMapId == 330000998 then
    instance.forcedPlayerNum = -1
  end
  if instance.MapNpcCfg then
    local curMapNpcs = instance.MapNpcCfg[oldMapId]
    if curMapNpcs then
      for _, v in pairs(curMapNpcs) do
        v.isVisible = v.defaultVisible
      end
    end
  end
  instance.MonstersInAir = nil
  instance:SetMaxVisibleNum()
end
def.method("number").SetForceVisibleNum = function(self, num)
  self.forcedPlayerNum = num
  self:SetMaxPlayers()
end
def.static("table", "table").OnEnterBANQUET = function(p1, p2)
  instance.forcedPlayerNum = 100
end
def.static("table", "table").OnLeaveBANQUET = function(p1, p2)
  instance.forcedPlayerNum = -1
end
local YUELAO_ID = 150100018
def.static("table").OnSBroadCastMarriage = function(p)
  local groom = instance:GetRole(p.roleidA)
  local bride = instance:GetRole(p.roleidB)
  if groom then
    groom:SetVisible(false)
  end
  if bride then
    bride:SetVisible(false)
  end
  if instance.weddingScene == nil then
    instance.weddingScene = {}
    instance.weddingScene.effs = {}
  end
  if instance.weddingScene.groomInfo == nil then
    instance.weddingScene.groomInfo = {}
    instance.weddingScene.groomInfo.roleId = p.roleidA
    instance.weddingScene.groomInfo.name = p.roleidAName
  end
  if instance.weddingScene.brideInfo == nil then
    instance.weddingScene.brideInfo = {}
    instance.weddingScene.brideInfo.roleId = p.roleidB
    instance.weddingScene.brideInfo.name = p.roleidBName
  end
  instance:PlayWeddingStep(p.level, p.stage)
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  local yuelao = instance:GetNpc(YUELAO_ID)
  if yuelao then
    yuelao:SetVisible(false)
  end
  if p.roleidA:eq(myId) then
    instance.weddingScene.host = instance.weddingScene.units[WeddingUnitType.Groom]
    _G.IsCamMoveMode = true
    ECGame.Instance().m_MainHostPlayer = instance.weddingScene.units[WeddingUnitType.Yuelao]
  elseif p.roleidB:eq(myId) then
    _G.IsCamMoveMode = true
    instance.weddingScene.host = instance.weddingScene.units[WeddingUnitType.Bride]
    ECGame.Instance().m_MainHostPlayer = instance.weddingScene.units[WeddingUnitType.Yuelao]
  end
end
def.method().EndWedding = function(self)
  for _, v in pairs(self.weddingScene.units) do
    v:Destroy()
  end
  for k, v in pairs(self.weddingScene.effs) do
    if v then
      MapEffect_ReleaseRes(v.eff)
    end
  end
  local groom = self:GetRole(self.weddingScene.groomInfo.roleId)
  if groom then
    groom:SetVisible(true)
  end
  local bride = self:GetRole(self.weddingScene.brideInfo.roleId)
  if bride then
    bride:SetVisible(true)
  end
  local yuelao = instance:GetNpc(YUELAO_ID)
  if yuelao then
    yuelao:SetVisible(true)
  end
  if instance.weddingScene.host then
    ECGame.Instance().m_MainHostPlayer = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
    _G.IsCamMoveMode = false
  end
  self.weddingScene.playcfg = nil
  self.weddingScene = nil
  weddingCfg = nil
end
def.method("userdata", "string", "userdata", "number", "number", "number", "number", "=>", "table").CreatePseudoRole = function(self, roleid, name, nameColor, modelId, x, y, dir)
  local role = ECPlayer.new(roleid, modelId, name, nameColor, RoleType.ROLE)
  local modelPath, modelColor = GetModelPath(modelId)
  if modelPath and modelPath ~= "" then
    role.colorId = modelColor
    role:LoadModel(modelPath, x, y, dir)
  end
  return role
end
def.method("number", "number").PlayWeddingStep = function(self, level, step)
  if self.weddingScene == nil or self.weddingScene.units == nil then
    if self.weddingScene == nil then
      self.weddingScene = {}
    end
    if self.weddingScene.units == nil then
      self.weddingScene.units = {}
    end
    local nameColor = GetColorData(701300007)
    local priest = self.weddingScene.units[WeddingUnitType.Yuelao]
    if priest == nil then
      local npccfg = NPCInterface.GetNPCCfg(YUELAO_ID)
      priest = self:CreatePseudoRole(Int64.new(YUELAO_ID), npccfg.npcName, nameColor, npccfg.monsterModelTableId, 0, 0, 150)
      priest.enableIdleAct = false
      self.weddingScene.units[WeddingUnitType.Yuelao] = priest
    end
    local bride = self.weddingScene.units[WeddingUnitType.Bride]
    if bride == nil then
      bride = self:CreatePseudoRole(self.weddingScene.brideInfo.roleId, self.weddingScene.brideInfo.name, nameColor, 700300130, 0, 0, -30)
      bride.enableIdleAct = false
      bride:SetTitle(textRes.PubRole[6])
      self.weddingScene.units[WeddingUnitType.Bride] = bride
    end
    local groom = self.weddingScene.units[WeddingUnitType.Groom]
    if groom == nil then
      groom = self:CreatePseudoRole(self.weddingScene.groomInfo.roleId, self.weddingScene.groomInfo.name, nameColor, 700300129, 0, 0, -30)
      groom.enableIdleAct = false
      groom:SetTitle(textRes.PubRole[5])
      self.weddingScene.units[WeddingUnitType.Groom] = groom
    end
  end
  local cfg = self:GetWeddingCfg(level)
  if cfg then
    local playcfg = cfg[step]
    if playcfg then
      if 0 < playcfg.musicId then
        local musicPath = require("Sound.SoundData").Instance():GetSoundPath(playcfg.musicId)
        if musicPath then
          require("Sound.ECSoundMan").Instance():Play2DSoundEx(musicPath, SOUND_TYPES.ENVIRONMENT, 10)
        end
      end
      local endtime
      if playcfg.endtime == nil then
        endtime = 0
      end
      for i = 1, #playcfg.actions do
        playcfg.actions[i].enable = true
        endtime = not endtime or endtime and math.max(endtime, playcfg.actions[i].unitEndTime) or playcfg.actions[i].unitEndTime
        local unit = self.weddingScene.units[playcfg.actions[i].unit]
        if unit and 0 < playcfg.actions[i].unitPosX and 0 < playcfg.actions[i].unitPosY then
          unit:SetPos(playcfg.actions[i].unitPosX, playcfg.actions[i].unitPosY)
        end
      end
      if playcfg.endtime == nil then
        playcfg.endtime = endtime
      end
      for i = 1, #playcfg.effs do
        playcfg.effs[i].enable = true
      end
      self.weddingScene.playcfg = playcfg
      self.weddingScene.maxStep = #cfg
      self.weddingScene.playcfg.time = -0.25
    end
  end
end
def.method("number").UpdateWedding = function(self, dt)
  if self.weddingScene == nil then
    return
  end
  if self.weddingScene.units then
    for _, v in pairs(self.weddingScene.units) do
      v:Update(dt)
    end
  end
  if self.weddingScene.playcfg == nil then
    return
  end
  self.weddingScene.playcfg.time = self.weddingScene.playcfg.time + dt
  for i = 1, #self.weddingScene.playcfg.actions do
    if self.weddingScene.playcfg.actions[i].enable and self.weddingScene.playcfg.actions[i].unitStartTime <= self.weddingScene.playcfg.time then
      do
        local unit = self.weddingScene.units[self.weddingScene.playcfg.actions[i].unit]
        if unit then
          if self.weddingScene.host then
            if unit == self.weddingScene.units[WeddingUnitType.Yuelao] then
              ECGame.Instance().m_MainHostPlayer = unit
            else
              ECGame.Instance().m_MainHostPlayer = self.weddingScene.host
            end
          end
          if self.weddingScene.playcfg.actions[i].unitPosX > 0 and 0 < self.weddingScene.playcfg.actions[i].unitPosY then
            unit:SetPos(self.weddingScene.playcfg.actions[i].unitPosX, self.weddingScene.playcfg.actions[i].unitPosY)
          end
          if self.weddingScene.playcfg.actions[i].unitActionType == WeddingActionType.Speak then
            local content = self.weddingScene.playcfg.actions[i].unitParam1
            local s = string.len(content)
            local t = 3
            if s > 20 then
              t = t + (s - 20) / 10
            end
            unit:Talk(content, t)
          elseif self.weddingScene.playcfg.actions[i].unitActionType == WeddingActionType.Act then
            unit:PlayAnim(self.weddingScene.playcfg.actions[i].unitParam1, function()
              unit:Play(ActionName.Stand)
            end)
          elseif self.weddingScene.playcfg.actions[i].unitActionType == WeddingActionType.Turn then
            local dir = tonumber(self.weddingScene.playcfg.actions[i].unitParam1)
            if dir ~= 0 then
              unit:SetDir(dir)
            end
          elseif self.weddingScene.playcfg.actions[i].unitActionType == WeddingActionType.Move then
            local posx = tonumber(self.weddingScene.playcfg.actions[i].unitParam1)
            local posy = tonumber(self.weddingScene.playcfg.actions[i].unitParam2)
            if posx and posy then
              local path = unit:MakeFlyPath(posx, posy)
              unit:RunPath(path, 60, function()
                unit:DestroyMovePathComp()
              end)
            else
              warn("[Wedding]Invalid target pos")
            end
          end
        end
        self.weddingScene.playcfg.actions[i].enable = false
      end
    end
  end
  for i = 1, #self.weddingScene.playcfg.effs do
    if self.weddingScene.playcfg.effs[i].enable and 0 < self.weddingScene.playcfg.effs[i].effectId then
      local eff = GetEffectRes(self.weddingScene.playcfg.effs[i].effectId)
      if eff then
        local effid = MapEffect_RequireRes(self.weddingScene.playcfg.effs[i].effectPosX, self.weddingScene.playcfg.effs[i].effectPosY, 1, {
          eff.path
        })
        table.insert(self.weddingScene.effs, {
          eff = effid,
          duration = self.weddingScene.playcfg.effs[i].effectDuration
        })
      end
      self.weddingScene.playcfg.effs[i].enable = false
    end
  end
  for k, v in pairs(self.weddingScene.effs) do
    if v then
      v.duration = v.duration - dt
      if 0 >= v.duration then
        MapEffect_ReleaseRes(v.eff)
        self.weddingScene.effs[k] = nil
      end
    end
  end
  if self.weddingScene.playcfg.time >= self.weddingScene.playcfg.endtime then
    if self.weddingScene.playcfg.stepId == self.weddingScene.maxStep then
      local groomId = self.weddingScene.groomInfo.roleId
      local brideId = self.weddingScene.brideInfo.roleId
      self:EndWedding()
      Event.DispatchEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.WeddingEnd, {groomId, brideId})
    else
      self.weddingScene.playcfg = nil
    end
  end
end
def.method("number", "=>", "table").GetWeddingCfg = function(self, level)
  if weddingCfg == nil then
    self:LoadWeddingCfg()
  end
  return weddingCfg[level]
end
def.method().LoadWeddingCfg = function(self)
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.marriage.confbean.CWeddingPlayCfg.bny")
  local size = DynamicDataTable.GetRecordsCount(entries)
  weddingCfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record == nil then
      return
    end
    local cfg = {}
    cfg.levelId = record:GetIntValue("levelId")
    cfg.stepId = record:GetIntValue("stepId")
    cfg.musicId = record:GetIntValue("musicId")
    cfg.effs = {}
    cfg.actions = {}
    local stepStruct = record:GetStructValue("stepStruct")
    local count = stepStruct:GetVectorSize("effectlist")
    local idx = 1
    for idx = 1, count do
      local eff = stepStruct:GetVectorValueByIdx("effectlist", idx - 1)
      local effinfo = {}
      effinfo.effectId = eff:GetIntValue("effectId")
      effinfo.effectPosX = eff:GetIntValue("effectPosX")
      effinfo.effectPosY = eff:GetIntValue("effectPosY")
      effinfo.effectDuration = eff:GetIntValue("effectDuration") / 1000
      table.insert(cfg.effs, effinfo)
    end
    count = stepStruct:GetVectorSize("actionlist")
    for idx = 1, count do
      local act = stepStruct:GetVectorValueByIdx("actionlist", idx - 1)
      if act then
        local actinfo = {}
        actinfo.unit = act:GetIntValue("unit")
        actinfo.unitActionType = act:GetIntValue("unitActionType")
        actinfo.unitDir = act:GetIntValue("unitDir")
        actinfo.unitPosX = act:GetIntValue("unitPosX")
        actinfo.unitPosY = act:GetIntValue("unitPosY")
        actinfo.unitStartTime = act:GetIntValue("unitStartTime") / 1000
        actinfo.unitEndTime = act:GetIntValue("unitEndTime") / 1000
        actinfo.unitParam1 = act:GetStringValue("unitParam1")
        actinfo.unitParam2 = act:GetStringValue("unitParam2")
        actinfo.unitParam3 = act:GetStringValue("unitParam3")
        table.insert(cfg.actions, actinfo)
      end
    end
    if weddingCfg[cfg.levelId] == nil then
      weddingCfg[cfg.levelId] = {}
    end
    weddingCfg[cfg.levelId][cfg.stepId] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "boolean").IsInWedding = function(self)
  return self.weddingScene ~= nil and self.weddingScene.host ~= nil or self.inGroupWedding
end
def.method("=>", "boolean").IsPlayingWedding = function(self)
  return self.weddingScene ~= nil
end
def.static("table").OnSUseFireWorksItemRes = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local roleId = p.roleid
  local x, y = p.x, p.y
  local fireItem = ItemUtils.GetFireWorkItemCfg(p.itemcfgid)
  local mapId = p.mapcfgid
  local role = instance.rolesMap[roleId:tostring()]
  if role and role.movePath == nil and role.mount == nil and not role:IsInState(RoleState.FLY) and not role:IsInState(RoleState.HUG) and not role:IsInState(RoleState.BEHUG) then
    role:PlayAnimationThenStand(ActionName.Magic)
  end
  if fireItem then
    local eff = GetEffectRes(fireItem.effectId)
    if eff then
      ECFxMan.Instance():PlayEffectAt2DWorldPos(eff.path, x, y)
    end
    local musicPath = require("Sound.SoundData").Instance():GetSoundPath(fireItem.soundId)
    if musicPath then
      require("Sound.ECSoundMan").Instance():Play2DSoundEx(musicPath, SOUND_TYPES.ENVIRONMENT, 10)
    end
  end
end
def.method().LoadMapNpcCfg = function(self)
  local entries = DynamicData.GetTable("data/cfg/npcconfig.bny")
  local size = DynamicDataTable.GetRecordsCount(entries)
  self.NpcMapCfg = {}
  self.MapNpcCfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record == nil then
      return
    end
    local npcinfo = {}
    npcinfo.npcId = record:GetIntValue("npcId")
    npcinfo.mapId = record:GetIntValue("mapId")
    npcinfo.dir = record:GetIntValue("dir") * 45
    npcinfo.pathType = record:GetIntValue("pathType")
    npcinfo.speed = record:GetIntValue("velocity")
    local ptStruct = record:GetStructValue("ptStruct")
    local count = ptStruct:GetVectorSize("ptlist")
    local idx = 1
    for idx = 1, count do
      local pt = ptStruct:GetVectorValueByIdx("ptlist", idx - 1)
      npcinfo.x = pt:GetIntValue("x")
      npcinfo.y = pt:GetIntValue("y")
    end
    local npcrec = DynamicData.GetRecord(CFG_PATH.DATA_NPC_CONFIG, npcinfo.npcId)
    if npcrec then
      npcinfo.isInAir = npcrec:GetCharValue("isInAir") ~= 0
      npcinfo.defaultVisible = npcrec:GetCharValue("isVisible") ~= 0
      npcinfo.isVisible = npcinfo.defaultVisible
    end
    self.NpcMapCfg[npcinfo.npcId] = npcinfo
    if self.MapNpcCfg[npcinfo.mapId] == nil then
      self.MapNpcCfg[npcinfo.mapId] = {}
    end
    self.MapNpcCfg[npcinfo.mapId][npcinfo.npcId] = npcinfo
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static().SendTLog = function()
  for k, v in pairs(SystemSettingModule.SystemSetting) do
    local setting = SystemSettingModule.Instance():GetSetting(v)
    local ECMSDK = require("ProxySDK.ECMSDK")
    if setting:tryget("isEnabled") ~= nil then
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.SYSTEMSETTINGSTATUS, {
        v,
        setting.isEnabled and 1 or 0
      })
    elseif setting:tryget("mute") ~= nil then
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.SYSTEMSETTINGSTATUS, {
        v,
        not setting.mute and 0 or 1
      })
    end
  end
end
def.static("table", "table").OnGangBattle = function(p1, p2)
  instance:SetMaxPlayers()
end
def.method("number", "number", "number").PlayEffectAtNpc = function(self, npcId, effectId, angle)
  local findNpc = self.npcMap[npcId]
  if findNpc then
    local dir = findNpc:GetDir() + angle
    local pos = findNpc:GetPos()
    local eff = GetEffectRes(effectId)
    if eff then
      ECFxMan.Instance():PlayEffectAt2DPosWithRotation(eff.path, pos.x, world_height - pos.y, dir)
    end
  end
end
def.method("userdata", "=>", "table").GetRolePos = function(self, roleId)
  if self.mapRoleLocs == nil then
    return nil
  end
  return self.mapRoleLocs[tostring(roleId)]
end
PubroleModule.Commit()
return PubroleModule
