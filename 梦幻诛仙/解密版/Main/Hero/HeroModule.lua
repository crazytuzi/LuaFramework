local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local HeroModule = Lplus.Extend(ModuleBase, "HeroModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local HeroUIMgr = require("Main.Hero.HeroUIMgr")
local HeroUtility = require("Main.Hero.HeroUtility")
local Vector = require("Types.Vector")
local ECPlayer = require("Model.ECPlayer")
local MathHelper = require("Common.MathHelper")
local ECFxMan = require("Fx.ECFxMan")
local FlyModule = require("Main.Fly.FlyModule")
local CMapFlyReq = require("netio.protocol.mzm.gsp.map.CMapFlyReq")
local CLand = require("netio.protocol.mzm.gsp.map.CLand")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local def = HeroModule.define
local instance
local XunluTip = require("Main.Hero.ui.XunluTip")
local MapInterface = require("Main.Map.Interface")
local MapModule = require("Main.Map.MapModule")
local FightMgr = require("Main.Fight.FightMgr")
local ROLE_SERVER_STATUS = require("netio.protocol.mzm.gsp.status.StatusEnum")
local Location = require("netio.protocol.mzm.gsp.map.Location")
local Space = require("consts.mzm.gsp.map.confbean.Space")
local CSyncRoleMove = require("netio.protocol.mzm.gsp.map.CSyncRoleMove")
local PathFinder = require("Main.Homeland.path.PathFinder")
local LogicMap = require("Main.Homeland.data.LogicMap")
def.const("number").HERO_LEVEL_UP_AUDIO_ID = 720060006
def.field("userdata").roleId = nil
def.field("table").myRole = nil
def.field("table").prop = nil
def.field("table").heroFightProp = nil
def.field("boolean").needShowAutoEffect = false
def.field("boolean").needShowLevelUpEffect = false
def.field("number").curMoveDistance = 0
def.field("number").curMoveSpace = 0
def.field("number").curMoveType = MoveType.AUTO
def.field("boolean").hasNextPatrol = false
def.field("userdata").selectEffect = nil
def.field("number").selectEffectTime = 0
def.field("table").pendingStates = nil
def.field("boolean").moveLock = false
def.field("function").moveCallback = nil
def.field("number").escortTimerId = -1
def.field("function").battleEndCallback = nil
def.field("table").resumePos = nil
def.field("boolean").isTaskCircle = false
def.field("table").escortTargetPos = nil
def.field("boolean").isInHomeland = false
def.static("=>", HeroModule).Instance = function()
  if instance == nil then
    instance = HeroModule()
    instance.m_moduleId = ModuleId.HERO
  end
  return instance
end
def.override().Init = function(self)
  HeroUIMgr.Instance():Init()
  require("Main.Hero.HeroStatusMgr").Instance():Init()
  Timer:RegisterIrregularTimeListener(self.Update, self)
  Timer:RegisterListener(self.UpdatePvp, self)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_ROLE_PROP_CLICK, HeroModule.OnClickRoleHead)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, HeroModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, HeroModule.OnLeaveFight)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, HeroModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_SECOND_PROP_CHANGED, HeroModule.OnHeroSecondPropChanged)
  Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveTitleChanged, HeroModule.OnActiveTitleChanged)
  Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.InfoChanged, HeroModule.OnTitleInfoChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSyncHeroProp", HeroModule.OnSSyncHeroProp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSyncRoleFightProp", HeroModule.OnSSyncRoleFightProp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SCommonResultRes", HeroModule.OnSCommonResultRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSetAutoAssignFuncRes", HeroModule.OnSSetAutoAssignFuncRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SAutoAssignPrefRes", HeroModule.OnSAutoAssignPrefRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSwitchPropSysRes", HeroModule.OnSSwitchPropSysRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSyncRoleAddExp", HeroModule.OnSSyncRoleAddExp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSyncVigorChange", HeroModule.OnSSyncVigorChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSyncVigorList", HeroModule.OnSSyncVigorList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SUseVigorItemRes", HeroModule.OnSUseVigorItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSyncExpConvertXiuLian", HeroModule.OnSSyncExpConvertXiuLian)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncStartHuSong", HeroModule.OnSSyncStartHuSong)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HeroModule.OnLeaveWorld)
  GameUtil.AddGlobalTimer(0.25, false, HeroModule.SyncMapPos)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, HeroModule.OnChangeMap)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, HeroModule.OnStatusChanged)
  ModuleBase.Init(self)
end
def.method("=>", "table").GetHeroProp = function(self)
  return HeroPropMgr.Instance():GetHeroProp()
end
def.method("=>", "table").GetHeroFightProp = function(self)
  return self.heroFightProp
end
def.method("=>", "boolean").CanAssignProp = function(self)
  return HeroPropMgr.Instance():CanAssignProp()
end
def.method("=>", "boolean").NeedAssignProp = function(self)
  return HeroPropMgr.Instance():NeedAssignProp()
end
def.static("table").OnSSyncHeroProp = function(p)
  HeroPropMgr.Instance():SetHeroProp(p)
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_PROP, nil)
  HeroPropMgr.Instance():QueryPropChangeEvent()
end
def.static("table").OnSSyncRoleFightProp = function(p)
  instance.heroFightProp = p.info
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_FIGHT_PROP, nil)
end
def.static("table").OnSCommonResultRes = function(p)
  local showInPersonal = {
    [2] = true,
    [6] = true,
    [7] = true
  }
  if p.result == p.class.RENAME_SUCCESS then
    Toast(textRes.Hero.SCommonResultRes[p.result])
    HeroPropMgr.Instance():UpdateHeroName("")
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_RENAME_SUCCESS, nil)
    instance.myRole:SetName(HeroPropMgr.Instance():GetHeroProp().name, instance.myRole.m_uNameColor)
  elseif p.result == p.CHECK_ROLE_INFO__NOT_EXIST or p.result == p.CHECK_ROLE_INFO__DIFF_SERVER then
    require("Main.friend.FriendCommonDlgManager").Clear()
    Toast(textRes.Hero.SCommonResultRes[p.result])
  else
    local resText = textRes.Hero.SCommonResultRes[p.result]
    if resText == nil then
      return
    end
    if showInPersonal[p.result] then
      local PersonalHelper = require("Main.Chat.PersonalHelper")
      PersonalHelper.CommonTableMsg({
        {
          PersonalHelper.Type.Text,
          resText
        }
      })
    else
      Toast(resText)
    end
  end
end
def.static("table").OnSSetAutoAssignFuncRes = function(p)
  local isAuto = p.autoAssignOpenFlag == 1
  require("Main.Hero.mgr.HeroAssignPointMgr").Instance():OnSSetAutoAssignFuncRes(isAuto)
end
def.static("table").OnSAutoAssignPrefRes = function(p)
  require("Main.Hero.mgr.HeroAssignPointMgr").Instance():OnSAutoAssignPrefRes(p.propSys, p.assignPropMap)
end
def.static("table").OnSSwitchPropSysRes = function(p)
  require("Main.Hero.mgr.HeroAssignPointMgr").Instance():OnSSwitchPropSysRes(p.propSys)
end
def.static("table").OnSSyncRoleAddExp = function(p)
end
def.static("table").OnSSyncVigorChange = function(p)
  HeroPropMgr.Instance():SetHeroEnergy(p.vigor)
end
def.static("table").OnSSyncVigorList = function(p)
  local HeroEnergyMgr = require("Main.Hero.mgr.HeroEnergyMgr")
  HeroEnergyMgr.Instance():SetAwardEnergyActivityMap(p.vigorMap)
end
def.static("table").OnSUseVigorItemRes = function(p)
  Toast(string.format(textRes.Hero[32], p.addVigor))
end
def.static("table").OnSSyncExpConvertXiuLian = function(p)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local expText = PersonalHelper.ToString(PersonalHelper.Type.RoleExp, p.roleExp)
  local xiulianExpText = PersonalHelper.ToString(PersonalHelper.Type.XiuLianExp, p.xiuLianExp)
  local SkillModule = require("Main.Skill.SkillModule")
  local skill = SkillModule.Instance():GetDefaultExerciseSkill()
  local skillName = ""
  if skill then
    skillName = skill:GetCfgData().skillCfg.name
  end
  local text = string.format(textRes.Hero[38], expText, skillName, xiulianExpText)
  PersonalHelper.CommonTableMsg({
    {
      PersonalHelper.Type.Text,
      text
    }
  })
end
def.method("=>", "userdata").GetMyRoleId = function(self)
  return self.roleId
end
def.method("=>", "number").GetMyModelId = function(self)
  if self.roleId then
    local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(self.roleId)
    if modelInfo then
      return modelInfo.modelid
    end
  end
  return 0
end
def.method("userdata").SetMyRoleId = function(self, _roleid)
  self.roleId = _roleid
end
def.method("userdata", "table", "number", "number", "number").CreateHeroModel = function(self, _roleid, mapModelInfo, posx, posy, dir)
  if self.myRole and self.myRole.roleId:eq(_roleid) then
    return
  end
  local roleIdStr = _roleid:tostring()
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local namecolor = GetColorData(701300000)
  self.myRole = pubMgr:AddRole(_roleid, mapModelInfo, posx, posy, dir, namecolor, RoleType.ROLE)
  if self.pendingStates then
    for k, state in pairs(self.pendingStates) do
      self.myRole:SetState(state)
    end
  end
  self.pendingStates = nil
  pubMgr.visiblePlayers[roleIdStr] = self.myRole
  self.myRole:SetTouchable(false)
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, {
    self.myRole:GetState()
  })
  ECGame.Instance().m_MainHostPlayer = self.myRole
end
def.method("number").SetState = function(self, state)
  if self.myRole then
    self.myRole:SetState(state)
  else
    if self.pendingStates == nil then
      self.pendingStates = {}
    end
    self.pendingStates[state] = state
  end
end
def.method("number").RemoveState = function(self, state)
  if self.myRole then
    self.myRole:RemoveState(state)
  elseif self.pendingStates then
    self.pendingStates[state] = nil
  end
end
def.method("=>", "table").GetPos = function(self)
  if self.myRole then
    return self.myRole:GetPos()
  end
  return nil
end
def.method("boolean").LockMove = function(self, lock)
  self.moveLock = lock
  if lock then
    GameUtil.AddGlobalTimer(2, true, function()
      self.moveLock = false
    end)
  end
end
def.method("number", "number", "number", "number", "number", "number", "function").MoveTo = function(self, mapId, x, y, targetSpace, distance, moveType, cb)
  if self.myRole == nil or self.myRole.m_node2d == nil or self.moveLock then
    return
  end
  if self:IsInEscort() then
    return
  end
  if self.myRole:IsInState(RoleState.SINGLEBATTLE_DEATH) then
    return
  end
  if self.myRole:IsInState(RoleState.ROOTS) then
    Toast(textRes.Hero[65])
    return
  end
  if self.myRole:IsInState(RoleState.PASSENGER) then
    Toast(textRes.Hero[63])
    return
  end
  if self.myRole:IsInState(RoleState.BEHUG) then
    local mainPanel = require("Main.MainUI.ui.MainUIPanel").Instance()
    mainPanel:addTongChenEffect()
    Toast(textRes.Hero[52])
    return
  end
  if targetSpace < 0 then
    targetSpace = self.myRole:IsInState(RoleState.FLY) and Space.SKY or Space.GROUND
  end
  if self.myRole:IsInState(RoleState.HUG) and targetSpace == Space.GROUND then
    Toast(textRes.Hero[54])
    return
  end
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubMgr:IsInFollowState(self.roleId) == true then
    Toast(textRes.Hero[46])
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE_IN_TEAM_FOLLOW, nil)
    return
  end
  if pubMgr:IsInWedding() then
    Toast(textRes.Hero[55])
    return
  end
  if pubMgr:IsInWeddingParade() then
    Toast(textRes.Hero[61])
    return
  end
  local curmapId = gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId
  if mapId <= 0 then
    mapId = curmapId
  end
  if moveType == MoveType.AUTO then
    if curmapId ~= mapId then
      moveType = MoveType.AUTO
    else
      local isFly = self.myRole:IsInState(RoleState.FLY)
      local hasAirCraft = FlyModule.Instance():HasAirCraft()
      if hasAirCraft then
        local autoFly = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.FlyingTrace).isEnabled
        local curx = self.myRole.m_node2d.localPosition.x
        local cury = self.myRole.m_node2d.localPosition.y
        local distanceEnough = FlyModule.Instance():DistanceEnough(curx, cury, x, y, self.myRole.runSpeed)
        if targetSpace == Space.SKY or autoFly and distanceEnough then
          isFly = true
        end
      elseif isFly then
        Toast(textRes.Hero[33])
        self:FlyDown()
        return
      elseif targetSpace == Space.SKY then
        Toast(textRes.Hero[33])
        return
      end
      moveType = isFly and MoveType.FLY or MoveType.RUN
    end
  end
  local mapCfg = MapInterface.GetMapCfg(mapId)
  if not mapCfg.canFly then
    moveType = MoveType.RUN
  end
  self:StopPatroling()
  self:MoveToPos(mapId, x, y, targetSpace, distance, moveType, cb)
end
def.method().FlyUp = function(self)
  if gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsInWedding() then
    Toast(textRes.Hero[55])
    return
  end
  if gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsInWeddingParade() then
    Toast(textRes.Hero[61])
    return
  end
  local mapId = MapModule.Instance():GetMapId()
  local mapCfg = MapInterface.GetMapCfg(mapId)
  if mapCfg then
    if not mapCfg.canFly then
      Toast(textRes.Hero[51])
      return
    end
  else
    return
  end
  if self.moveLock then
    return
  end
  if self.myRole == nil then
    return
  end
  if self:IsInEscort() then
    Toast(textRes.Hero[58])
    return
  end
  if self.myRole:IsInState(RoleState.BEHUG) or self.myRole:IsInState(RoleState.PASSENGER) then
    Toast(textRes.Hero[52])
    return
  end
  if self.myRole:IsInState(RoleState.FLY) then
    return
  end
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubMgr:IsInFollowState(self.roleId) == true then
    Toast(textRes.Hero[46])
    return
  end
  self:StopPatroling()
  local curx = self.myRole.m_node2d.localPosition.x
  local cury = self.myRole.m_node2d.localPosition.y
  if self.isTaskCircle then
    self:Stop()
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, {x = curx, y = cury})
  end
  self:_DoFlyUp(nil)
end
def.method("function")._DoFlyUp = function(self, cb)
  local x, y = -1, -1
  if self.myRole.movePath and #self.myRole.movePath > 0 then
    local lastPoint = self.myRole.movePath[#self.myRole.movePath]
    x, y = lastPoint.x, lastPoint.y
    self:MoveToPos(0, x, y, 0, 0, MoveType.FLY, self.moveCallback)
  else
    x, y = self.myRole:FlyUp(cb)
    XunluTip.HideXunlu()
    if x < 0 or y < 0 then
      warn("Fly Up Fail")
    else
      local flyPos = Location.new()
      flyPos.x = x
      flyPos.y = y
      gmodule.network.sendProtocol(CMapFlyReq.new(flyPos))
    end
  end
end
def.method().FlyDown = function(self)
  if gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsInWedding() then
    Toast(textRes.Hero[55])
    return
  end
  if self.moveLock then
    return
  end
  if self.myRole == nil then
    return
  end
  if self:IsInEscort() then
    return
  end
  if self.myRole:IsInState(RoleState.BEHUG) or self.myRole:IsInState(RoleState.PASSENGER) then
    Toast(textRes.Hero[52])
    return
  end
  if not self.myRole:IsInState(RoleState.FLY) then
    return
  end
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubMgr:IsInFollowState(self.roleId) == true then
    Toast(textRes.Hero[46])
    return
  end
  self:StopPatroling()
  self:_DoFlyDown(nil)
end
def.method("function")._DoFlyDown = function(self, cb)
  local curx = self.myRole.m_node2d.localPosition.x
  local cury = self.myRole.m_node2d.localPosition.y
  local tarX, tarY = -1, -1
  if self.myRole.flyPoint then
    tarX = self.myRole.flyPoint.x
    tarY = self.myRole.flyPoint.y
  end
  if MapScene.IsBarrierXY(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, curx, cury) then
    local pt = MapScene.FindAdjacentValidPoint(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, curx, cury)
    local downX = pt:x()
    local downY = pt:y()
    self.myRole:FlyTo(downX, downY, function()
      local x, y = self.myRole:FlyDown(function()
        if cb then
          cb()
        end
        if tarX > 0 and tarY > 0 then
          self:MoveToPos(0, tarX, tarY, 0, 0, MoveType.RUN, self.moveCallback)
        else
          XunluTip.HideXunlu()
        end
      end)
      local landPos = Location.new()
      landPos.x = x
      landPos.y = y
      gmodule.network.sendProtocol(CLand.new(landPos))
    end)
    local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId
    local movePoints = {}
    movePoints[1] = Location.new(downX, downY)
    gmodule.network.sendProtocol(CSyncRoleMove.new(movePoints, mapId))
  else
    local x, y = self.myRole:FlyDown(function()
      if cb then
        cb()
      end
      if tarX > 0 and tarY > 0 then
        self:MoveToPos(0, tarX, tarY, 0, 0, MoveType.RUN, self.moveCallback)
      else
        XunluTip.HideXunlu()
      end
    end)
    if x < 0 or y < 0 then
      warn("Fly Down Fail")
    else
      local landPos = Location.new()
      landPos.x = x
      landPos.y = y
      gmodule.network.sendProtocol(CLand.new(landPos))
    end
  end
end
def.method("number", "number").ContinueMove = function(self, x, y)
  local distance = self.curMoveDistance
  self.curMoveDistance = 0
  local space = self.curMoveSpace
  self.curMoveSpace = 0
  self:MoveToPos(0, x, y, space, distance, self.curMoveType, self.moveCallback)
  self.curMoveType = MoveType.AUTO
end
def.method("number", "number").ContinueFindPath = function(self, x, y)
  if self.myRole == nil then
    return
  end
  if self:IsInEscort() then
    self:ContinueMove(x, y)
    return
  end
  local distance = self.curMoveDistance
  self.curMoveDistance = 0
  local space = self.curMoveSpace
  self.curMoveSpace = 0
  if self.curMoveType == MoveType.AUTO then
    self:MoveTo(0, x, y, space, distance, MoveType.AUTO, self.moveCallback)
  else
    self:MoveToPos(0, x, y, space, distance, self.curMoveType, self.moveCallback)
  end
  self.curMoveType = MoveType.AUTO
end
def.method("number", "number", "number", "number", "number", "number", "function").MoveToPos = function(self, mapId, x, y, space, distance, moveType, cb)
  if self.myRole == nil or self.moveLock then
    return
  end
  if self.myRole:IsInLoading() then
    self.myRole:AddOnLoadCallback("movetopos", function()
      self:MoveToPos(mapId, x, y, space, distance, moveType, cb)
    end)
    return
  end
  if self.myRole.m_node2d == nil or self.myRole.m_model == nil or self.myRole:IsInState(RoleState.BEHUG) or self.myRole:IsInState(RoleState.SINGLEBATTLE_DEATH) or self.myRole:IsInState(RoleState.PASSENGER) then
    return
  end
  if self.myRole:IsInState(RoleState.HUG) and space == Space.GROUND then
    Toast(textRes.Hero[54])
    return
  end
  if FightMgr.Instance().isInFight or self.myRole:IsInState(RoleState.BATTLE) then
    function instance.battleEndCallback()
      self:MoveToPos(mapId, x, y, space, distance, moveType, cb)
    end
    return
  end
  x = math.floor(x)
  y = math.floor(y)
  if space == Space.SKY and y < fly_y_min then
    y = fly_y_min or y
  end
  local mapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local curScene = mapModule.scene
  if curScene == nil then
    return
  end
  local currentPos = Location.new()
  currentPos.x = self.myRole.m_node2d.localPosition.x
  currentPos.y = self.myRole.m_node2d.localPosition.y
  local targetPos = Location.new()
  targetPos.x = x
  targetPos.y = y
  local curmapId = mapModule.currentMapId
  if mapId <= 0 then
    mapId = curmapId
  end
  if curmapId ~= mapId then
    self.moveCallback = cb
    self.curMoveDistance = distance
    self.curMoveSpace = space
    self.curMoveType = moveType
    self:EnterMap(mapId, targetPos)
    return
  end
  local isFly = false
  if self.myRole:IsInState(RoleState.FLY) or space == Space.SKY or moveType == MoveType.FLY then
    if moveType == MoveType.FLY then
      local finalX, finalY = MathHelper.CalcCoordByTwoPointAndDistance2(currentPos.x, currentPos.y, targetPos.x, targetPos.y, distance * 16)
      if self.myRole:IsInState(RoleState.FLY) and space == Space.SKY then
        local movePoints = {}
        movePoints[1] = Location.new(currentPos.x, currentPos.y)
        movePoints[2] = Location.new(finalX, finalY)
        self.moveCallback = cb
        self.myRole:FlyTo(finalX, finalY, HeroModule.OnArrive)
        gmodule.network.sendProtocol(CSyncRoleMove.new(movePoints, mapId))
      elseif self.myRole:IsInState(RoleState.FLY) and space == Space.GROUND then
        if MapScene.IsBarrierXY(mapModule.scene, finalX, finalY) then
          local pt = MapScene.FindAdjacentValidPoint(mapModule.scene, finalX, finalY)
          finalX = pt:x()
          finalY = pt:y()
        end
        self.myRole:FlyTo(finalX, finalY, function()
          self.moveCallback = cb
          local landx, landy = self.myRole:FlyDown(HeroModule.OnArrive)
          if x < 0 or y < 0 then
            Debug.LogWarning("Fly Down Fail")
          else
            local landPos = Location.new()
            landPos.x = landx
            landPos.y = landy
            gmodule.network.sendProtocol(CLand.new(landPos))
          end
        end)
        local movePoints = {}
        movePoints[1] = Location.new(currentPos.x, currentPos.y)
        movePoints[2] = Location.new(finalX, finalY)
        gmodule.network.sendProtocol(CSyncRoleMove.new(movePoints, mapId))
      elseif not self.myRole:IsInState(RoleState.FLY) and space == Space.SKY then
        self.moveCallback = cb
        self.myRole:FlyUpTo(finalX, finalY, HeroModule.OnArrive)
        local flyPos = Location.new(finalX, finalY)
        gmodule.network.sendProtocol(CMapFlyReq.new(flyPos))
      elseif not self.myRole:IsInState(RoleState.FLY) and space == Space.GROUND then
        self.myRole:FlyUpTo(finalX, finalY, function()
          self.moveCallback = cb
          local landx, landy = self.myRole:FlyDown(HeroModule.OnArrive)
          if x < 0 or y < 0 then
            Debug.LogWarning("Fly Down Fail")
          else
            local landPos = Location.new()
            landPos.x = landx
            landPos.y = landy
            gmodule.network.sendProtocol(CLand.new(landPos))
          end
        end)
        local flyPos = Location.new(finalX, finalY)
        gmodule.network.sendProtocol(CMapFlyReq.new(flyPos))
      end
      isFly = true
    elseif space == Space.SKY then
      Debug.LogWarning("Bad Fly Call, space is SKY but movetype is RUN ", debug.traceback())
      isFly = false
    else
      local landx, landy = self.myRole:FlyDown(function()
        self.moveCallback = cb
        self:MoveToPos(mapId, x, y, 0, distance, MoveType.RUN, HeroModule.OnArrive)
      end)
      if x < 0 or y < 0 then
        Debug.LogWarning("Fly Down Fail")
      else
        local landPos = Location.new()
        landPos.x = landx
        landPos.y = landy
        gmodule.network.sendProtocol(CLand.new(landPos))
      end
    end
  end
  if not isFly then
    local findpath = mapModule:FindPath(self.myRole.m_node2d.localPosition.x, self.myRole.m_node2d.localPosition.y, x, y, distance)
    if findpath == nil then
      local hasNextPatrol = self:IsPatroling()
      Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.FIND_PATH_FAILED, nil)
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, {
        x = self.myRole.m_node2d.localPosition.x,
        y = self.myRole.m_node2d.localPosition.y
      })
      if cb then
        cb()
      end
      local p = Map2DPosTo3D(x, world_height - y)
      local pos3d = self.myRole:Get3DPos()
      if pos3d then
        local dir = p - pos3d
        dir:Normalize()
        self.myRole:SetForward(dir)
      end
      if hasNextPatrol then
        self.myRole:SetState(RoleState.PATROL)
        self.hasNextPatrol = true
      end
      return
    end
    local movePoints = {}
    for i = 0, #findpath do
      local lp = Location.new()
      lp.x = findpath[i].x
      lp.y = findpath[i].y
      table.insert(movePoints, lp)
    end
    local lastpoint = findpath[#findpath]
    gmodule.network.sendProtocol(CSyncRoleMove.new(movePoints, mapId))
    self.myRole:RunPath(findpath, self.myRole.runSpeed, HeroModule.OnArrive)
    self.moveCallback = cb
  end
  if self.needShowAutoEffect then
    XunluTip.ShowXunlu()
  else
    XunluTip.HideXunlu()
  end
  gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):SetFollowPath()
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE, {x, y})
end
def.method("number", "table", "=>", "boolean").EnterMap = function(self, mapId, targetPos)
  if PlayerIsInFight() then
    return false
  end
  if self.myRole:IsInState(RoleState.ROOTS) then
    Toast(textRes.Hero[65])
    return false
  end
  if self.myRole:IsInState(RoleState.UNTRANPORTABLE) then
    Toast(textRes.Hero[50])
    return false
  end
  if self.myRole:IsInState(RoleState.BEHUG) or self.myRole:IsInState(RoleState.PASSENGER) then
    Toast(textRes.Hero[52])
    return false
  end
  if gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsInWedding() then
    Toast(textRes.Hero[55])
    return false
  end
  if gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsInWeddingParade() then
    Toast(textRes.Hero[61])
    return false
  end
  local mapCfg = MapInterface.GetMapCfg(mapId)
  if self.myRole:IsInState(RoleState.HUG) then
    if mapCfg then
      if not mapCfg.canFly then
        Toast(string.format(textRes.Hero[53], mapCfg.mapName))
        return false
      end
    else
      return false
    end
  end
  if not mapCfg.canDirectTransfer then
    Toast(textRes.Map[20])
    return false
  end
  local function DoEnterMap()
    if self:IsPatroling() then
      self:StopPatroling()
    else
      self:Stop()
    end
    if targetPos == nil then
      targetPos = require("netio.protocol.mzm.gsp.map.Location").new()
      targetPos.x = -1
      targetPos.y = -1
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.map.CTransferMapReq").new(mapId, targetPos))
  end
  if self.myRole:IsInState(RoleState.BATTLE) then
    instance.battleEndCallback = DoEnterMap
  else
    DoEnterMap()
  end
  return true
end
def.method().Land = function(self)
  local MathHelper = require("Common.MathHelper")
  local curX = self.myRole.m_node2d.localPosition.x
  local curY = self.myRole.m_node2d.localPosition.y
  local path = self.myRole.movePath
  local tarPos = path[#path]
  local tarX, tarY = tarPos.x, tarPos.y
  local jumpTargetDis = self.myRole.runSpeed * 0.4
  local landX, landY = MathHelper.CalcCoordByTwoPointAndDistance1(curX, curY, tarX, tarY, jumpTargetDis)
  if MapScene.IsBarrierXY(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, landX, landY) then
    Toast(textRes.Map[14])
    return
  end
  local location = require("netio.protocol.mzm.gsp.map.Location").new(landX, landY)
  local landReq = require("netio.protocol.mzm.gsp.map.CLand").new(location)
  gmodule.network.sendProtocol(landReq)
end
def.method().ContinueFly = function(self)
  if FightMgr.Instance().isInFight then
    return
  end
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubMgr:IsInFollowState(self.roleId) == true then
    return
  end
  if self.myRole == nil or self.myRole:IsInState(RoleState.FLY) then
    return
  end
  if self.myRole.movePath and #self.myRole.movePath > 0 then
    local lastPoint = self.myRole.movePath[#self.myRole.movePath]
    local x, y = lastPoint.x, lastPoint.y
    self:FlyTo(x, y, 0)
  end
end
def.method("number", "number", "number").FlyTo = function(self, x, y, distance)
  local curX = self.myRole.m_node2d.localPosition.x
  local curY = self.myRole.m_node2d.localPosition.y
  local curScene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
  local tarX, tarY
  if distance == 0 then
    tarX = x
    tarY = y
  else
    local findpath = MapScene.FindPath(curScene, curX, curY, x, y, distance)
    local lastpoint = findpath[#findpath]
    tarX = lastpoint.x
    tarY = lastpoint.y
  end
  local location = require("netio.protocol.mzm.gsp.map.Location").new(tarX, tarY)
  local flyReq = require("netio.protocol.mzm.gsp.map.CMapFlyReq").new(location)
  gmodule.network.sendProtocol(flyReq)
end
def.static().OnArrive = function()
  if instance:IsPatroling() then
    instance.hasNextPatrol = true
    return
  end
  XunluTip.HideXunlu()
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, {
    x = instance.myRole.m_node2d.localPosition.x,
    y = instance.myRole.m_node2d.localPosition.y
  })
  if instance.moveCallback then
    instance.moveCallback()
    instance.moveCallback = nil
  end
end
def.method().Stop = function(self)
  if self.myRole == nil then
    return
  end
  self.myRole:Stop()
  XunluTip.HideXunlu()
  self.battleEndCallback = nil
end
def.method().Arrive = function(self)
end
def.method("number").Update = function(self, tk)
  if self.hasNextPatrol then
    self.hasNextPatrol = false
    self:NextPatrol()
  end
  if self.selectEffectTime <= 0 then
    return
  end
  self.selectEffectTime = self.selectEffectTime - tk
  if self.selectEffectTime <= 0 and self.selectEffect then
    ECFxMan.Instance():Stop(self.selectEffect)
  end
end
def.method("number").UpdatePvp = function(self, dt)
  if self.myRole == nil or self.myRole.m_node2d == nil then
    return
  end
  local x, y, z = self.myRole.m_node2d:GetPosXYZ()
  if not self.myRole:IsInState(RoleState.PVP) and MapScene.IsPvp(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, x, y) then
    self.myRole:SetState(RoleState.PVP)
    Toast(textRes.Hero[30])
  elseif not MapScene.IsPvp(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, x, y) and self.myRole:IsInState(RoleState.PVP) then
    self.myRole:RemoveState(RoleState.PVP)
    Toast(textRes.Hero[31])
  end
end
local syncMapPosData = {}
def.static().SyncMapPos = function()
  if instance.myRole == nil or instance.myRole.m_node2d == nil then
    return
  end
  local x, y, z = instance.myRole.m_node2d:GetPosXYZ()
  syncMapPosData.x = x
  syncMapPosData.y = y
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_MAP_POS, syncMapPosData)
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if instance.myRole == nil then
    return
  end
  FlyModule.Instance():StopCloud("fly")
  instance.myRole:Pause(true)
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if instance.myRole == nil then
    return
  end
  if gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsInFollowState(instance.roleId) == true then
    return
  end
  if instance.battleEndCallback then
    local cb = instance.battleEndCallback
    instance.battleEndCallback = nil
    cb()
    return
  end
  local function OnBattleEnd()
    if instance:IsPatroling() then
      instance.hasNextPatrol = p1.Result
      if not instance.hasNextPatrol then
        instance:StopPatroling()
      end
      return
    end
    if instance.myRole.movePath then
      local pathIdx = instance.myRole.pathIdx
      local leftPath = {}
      local curPos = instance.myRole:GetPos()
      local curpt = Location.new()
      curpt.x = curPos.x
      curpt.y = curPos.y
      leftPath[1] = curpt
      local pathlen = #instance.myRole.movePath
      for i = pathlen - pathIdx + 1, pathlen do
        local pt = Location.new()
        pt.x = instance.myRole.movePath[i].x
        pt.y = instance.myRole.movePath[i].y
        table.insert(leftPath, pt)
      end
      instance.myRole:Pause(false)
      if #leftPath > 1 then
        gmodule.network.sendProtocol(CSyncRoleMove.new(leftPath, gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId))
      else
        instance:ContinueEscort()
      end
    else
      instance:ContinueEscort()
    end
  end
  if instance.myRole:IsInState(RoleState.BATTLE) then
    instance.battleEndCallback = OnBattleEnd
  else
    OnBattleEnd()
  end
end
def.static("table", "table").OnChangeMap = function(p1, p2)
  if instance.escortTimerId > 0 then
    local timerId = instance.escortTimerId
    instance.escortTimerId = -1
    GameUtil.RemoveGlobalTimer(timerId)
  end
end
def.method().ContinueEscort = function(self)
  if self.myRole and self.myRole:IsInState(RoleState.ESCORT) then
    if self.escortTimerId > 0 then
      GameUtil.ResetGlobalTimer(self.escortTimerId)
    else
      self.escortTimerId = GameUtil.AddGlobalTimer(1, false, function()
        if self.myRole == nil then
          return
        end
        if not self.myRole:IsInState(RoleState.ESCORT) then
          HeroModule.OnChangeMap(nil, nil)
        else
          local curPos = self.myRole:GetPos()
          self:DirectMoveTo(curPos.x + 1, curPos.y + 1)
        end
      end)
    end
  end
end
def.method("number", "number").DirectMoveTo = function(self, x, y)
  local movePoints = {}
  local lp = Location.new()
  lp.x = x
  lp.y = y
  table.insert(movePoints, lp)
  gmodule.network.sendProtocol(CSyncRoleMove.new(movePoints, gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId))
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  require("Main.Common.OutFightDo").Instance():Do(function()
    instance:ShowLevelUpEffect()
    SafeLuckDog(function()
      return p1.level % 10 == 0 and p1.level >= 30
    end)
  end, nil)
end
def.method().ShowLevelUpEffect = function(self)
  self.needShowLevelUpEffect = false
  if self.myRole == nil then
    return
  end
  local resPath = HeroUtility.GetLvlUpEffectResPath()
  self:AddChildEffect(resPath, BODY_PART.FEET)
  GameUtil.AddGlobalTimer(0, true, function()
    local resPath = HeroUtility.GetLvlUpTextEffectResPath()
    require("Fx.GUIFxMan").Instance():Play(resPath, "levelup", 0, 100, -1, false)
  end)
  require("Sound.ECSoundMan").Instance():Play2DInterruptSoundByID(HeroModule.HERO_LEVEL_UP_AUDIO_ID)
end
def.method("string", "number", "=>", "userdata").AddChildEffect = function(self, effectPath, part)
  local pos = Vector.Vector3.new(0, 0, 0)
  local fx = ECFxMan.Instance():PlayAsChild(effectPath, self.myRole.m_model, pos, Quaternion.identity, -1, false, -1)
  if fx == nil then
    warn("can not request effect: " .. effectPath)
    return nil
  end
  fx:SetLayer(ClientDef_Layer.Player)
  return fx
end
def.static("table", "table").OnHeroSecondPropChanged = function(params, context)
  local HeroPropChangeMgr = require("Main.Hero.mgr.HeroPropChangeMgr")
  HeroPropChangeMgr.Instance():OnHeroSecondPropChanged(params)
end
def.static("table", "table").OnClickRoleHead = function()
  local propPanel = require("Main.Hero.ui.HeroPropPanel").Instance()
  if propPanel:IsShow() then
    propPanel:HidePanel()
  else
    propPanel:ShowPanel()
  end
end
def.static("table", "table").OnTitleInfoChanged = function(p1, p2)
  HeroModule.OnActiveTitleChanged(nil, nil)
  HeroModule.OnActiveAppellationChanged(nil, nil)
end
def.static("table", "table").OnActiveTitleChanged = function(p1, p2)
  if instance.myRole == nil then
    return
  end
  local TitleInterface = require("Main.title.TitleInterface")
  local titleInterface = TitleInterface.Instance()
  local TitleID = titleInterface:GetActiveTitle()
  local cfg = TitleInterface.GetTitleCfg(TitleID)
  if cfg ~= nil then
    instance.myRole:SetTitleIcon(cfg.picId)
  else
    instance.myRole:SetTitleIcon(0)
  end
end
def.static("table", "table").OnActiveAppellationChanged = function(p1, p2)
  if instance.myRole == nil then
    return
  end
  local TitleInterface = require("Main.title.TitleInterface")
  local titleInterface = TitleInterface.Instance()
  local appellationID = titleInterface:GetActiveAppellation()
  local cfg
  if appellationID ~= 0 then
    cfg = TitleInterface.GetAppellationCfg(appellationID)
  end
  if cfg ~= nil then
    local color = GetColorData(cfg.appellationColor)
    local appellation = cfg.appellationName
    local appArgs = titleInterface:GetAppellationArgs(appellationID)
    if appArgs ~= nil then
      table.insert(appArgs, "")
      table.insert(appArgs, "")
      table.insert(appArgs, "")
      appellation = string.format(cfg.appellationName, unpack(appArgs))
    end
    instance.myRole:SetTitleWithColor(appellation, color)
  else
    instance.myRole:SetTitle("")
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance:StopPatroling()
  instance:StopSpecialEscortTimerId()
  instance.curMoveDistance = 0
  instance.curMoveSpace = 0
  instance.curMoveType = MoveType.AUTO
  if instance.myRole then
    instance.myRole:Destroy()
  end
  instance.myRole = nil
  instance.prop = nil
  instance.heroFightProp = nil
  instance.prop = nil
  instance.hasNextPatrol = false
  instance.isTaskCircle = false
  instance.needShowAutoEffect = false
  instance.needShowLevelUpEffect = false
  instance.pendingStates = nil
  instance.battleEndCallback = nil
  if _G.leaveWorldReason ~= _G.LeaveWorldReason.RECONNECT then
    instance.roleId = nil
  end
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MODULE_RESET, nil)
end
def.method().Patrol = function(self)
  if _G.IsCrossingServer() then
    _G.ToastCrossingServerForbiden()
    self.hasNextPatrol = false
    return
  end
  if FightMgr.Instance().isInFight or self.myRole:IsInState(RoleState.HUG) or self.myRole:IsInState(RoleState.BEHUG) or self.myRole:IsInState(RoleState.PASSENGER) then
    return
  end
  local function doPatrol()
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_CANCELED, nil)
    local pt = MapScene.FindRandomValidPoint(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene)
    if pt == nil then
      warn("patrol point is nil")
      return
    end
    self:SetPatroling(true)
    self.needShowAutoEffect = false
    self:MoveToPos(0, pt:x(), pt:y(), 0, 0, MoveType.RUN, nil)
    XunluTip.ShowXunluo()
  end
  if self.myRole:IsInState(RoleState.FLY) then
    local x, y = self.myRole:FlyDown(doPatrol)
    local landPos = Location.new()
    landPos.x = x
    landPos.y = y
    gmodule.network.sendProtocol(CLand.new(landPos))
  else
    doPatrol()
  end
end
def.method("=>", "boolean").IsPatroling = function(self)
  return self.myRole ~= nil and self.myRole:IsInState(RoleState.PATROL)
end
def.method("=>", "boolean").IsInEscort = function(self)
  return self.myRole ~= nil and self.myRole:IsInState(RoleState.ESCORT)
end
def.method().NextPatrol = function(self)
  local pt = MapScene.FindRandomValidPoint(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene)
  if pt == nil then
    return
  end
  local x = pt:x()
  local y = pt:y()
  self:ContinueMove(x, y)
end
def.method().StopPatroling = function(self)
  if self.myRole and self.myRole:IsInState(RoleState.PATROL) then
    self:SetPatroling(false)
    local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    if pubMgr:IsInFollowState(self.roleId) == true then
      return
    end
    self:Stop()
    XunluTip.HideXunluo()
  end
end
def.static("table", "table").OnStatusChanged = function(p1, p2)
  local statusChanged = p1 and p1[1]
  if statusChanged == nil then
    return
  end
  if statusChanged.Check(RoleState.BATTLE) and not instance.myRole:IsInState(RoleState.BATTLE) and instance.battleEndCallback and not FightMgr.Instance().isInFight then
    local cb = instance.battleEndCallback
    instance.battleEndCallback = nil
    cb()
  end
end
def.static("table").OnSForceLand = function(p)
  if instance.myRole:IsInState(RoleState.FLY) then
    instance.myRole:FlyDown(nil)
  end
end
def.method("boolean").SetPatroling = function(self, v)
  if self.myRole == nil then
    return
  end
  if v then
    self.myRole.enableIdleAct = false
    self.myRole:SetState(RoleState.PATROL)
  else
    self.myRole:RemoveState(RoleState.PATROL)
    self.myRole.enableIdleAct = true
  end
  local pro = require("netio.protocol.mzm.gsp.map.CSetXunLuoStateReq")
  local status = v and pro.SET or pro.UN_SET
  gmodule.network.sendProtocol(pro.new(status))
end
local special_escort_timer_id
def.static("table").OnSSyncStartHuSong = function(p)
  if instance.myRole == nil then
    return
  end
  if p.is_special == 1 then
    instance.needShowAutoEffect = false
    instance.escortTargetPos = p.targetPos
    special_escort_timer_id = GameUtil.AddGlobalTimer(3, false, function()
      instance:DirectMoveTo(p.targetPos.x, p.targetPos.y)
    end)
    return
  end
  local function DoEscort()
    instance.myRole:SetState(RoleState.ESCORT)
    if instance.myRole:IsInState(RoleState.BATTLE) then
      instance.myRole.movePath = {
        p.targetPos
      }
      function instance.battleEndCallback()
        instance.needShowAutoEffect = false
        instance:ContinueMove(p.targetPos.x, p.targetPos.y)
      end
    else
      instance.needShowAutoEffect = false
      instance:ContinueMove(p.targetPos.x, p.targetPos.y)
    end
  end
  if instance.myRole:IsInLoading() then
    instance.myRole:AddOnLoadCallback("husong", DoEscort)
  else
    DoEscort()
  end
end
def.method().StopSpecialEscortTimerId = function(self)
  if special_escort_timer_id then
    GameUtil.RemoveGlobalTimer(special_escort_timer_id)
    special_escort_timer_id = nil
  end
end
def.method().StopEscort = function(self)
  self:StopSpecialEscortTimerId()
  if self.myRole == nil then
    return
  end
  self.myRole:RemoveState(RoleState.ESCORT)
  self:Stop()
  self.myRole.movePath = nil
end
def.method("number", "=>", "boolean").IsInState = function(self, s)
  if self.myRole == nil then
    return false
  end
  return self.myRole:IsInState(s)
end
HeroModule.Commit()
return HeroModule
