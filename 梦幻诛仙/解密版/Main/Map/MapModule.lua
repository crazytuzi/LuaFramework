local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local MapModule = Lplus.Extend(ModuleBase, "MapModule")
require("Main.module.ModuleId")
local ECSoundMan = require("Sound.ECSoundMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local MapUtility = require("Main.Map.MapUtility")
local ColorType = require("consts.mzm.gsp.map.confbean.ColorType")
local MapEntityFactory = require("Main.Map.entity.MapEntityFactory")
local LogicMap = require("Main.Homeland.data.LogicMap")
local PathFinder = require("Main.Homeland.path.PathFinder")
local EC = require("Types.Vector3")
local ECFxMan = require("Fx.ECFxMan")
local def = MapModule.define
_G.mapAlpha = 1
def.field("userdata").scene = nil
def.field("number").currentMapId = 0
def.field("number").worldId = 0
def.field("userdata").mapNodeRoot = nil
def.field("userdata").mapEffectNodeRoot = nil
def.field("userdata").mapPlayerNodeRoot = nil
def.field("userdata").mLight = nil
def.field("table").mTransportEffect = nil
def.field("table").musicInfo = nil
def.field("boolean").canTransfer = true
def.field("number").map_w = 0
def.field("number").map_h = 0
def.field("number").battleBg = 0
def.field("number").mapInstanceId = 0
def.field("table").mMapEntities = nil
def.field("table").MapPolygonsCfg = nil
def.field("boolean").enablePolygon = false
def.field("boolean").enableMusic = true
def.const("table").TRANSPORT_EFFECT_LIST = {
  [ColorType.BLUE] = RESPATH.TRANSPORT_EFFECT_BULE,
  [ColorType.RED] = RESPATH.TRANSPORT_EFFECT_RED,
  [ColorType.GREEN] = RESPATH.TRANSPORT_EFFECT_GREEN
}
local instance
def.static("=>", MapModule).Instance = function()
  if instance == nil then
    instance = MapModule()
    instance.m_moduleId = ModuleId.MAP
    instance.mTransportEffect = {}
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SEnterWorld", MapModule.OnSEnterWorld)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.STransforPosEnterView", MapModule.OnTransferEnterView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.STransforPosLeaveView", MapModule.OnTransferLeaveView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapEntityEnterView", MapModule.OnSMapEntityEnterView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapEntityLeaveView", MapModule.OnSMapEntityLeaveView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncMapEntityExtraInfoChange", MapModule.OnSSyncMapEntityExtraInfoChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncMapEntityInfo", MapModule.OnSSyncMapEntityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncMapEntityMove", MapModule.OnSSyncMapEntityMove)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_WORLD_MAP_CLICK, MapModule.OnWorldMapButtonClick)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_MINI_MAP_CLICK, MapModule.OnMiniMapButtonClick)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE, MapModule.OnHeroMove)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, MapModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, MapModule.OnLeaveFight)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, MapModule.reset)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, MapModule.OnStartDrama)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, MapModule.OnEndDrama)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, MapModule.OnCEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, MapModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.ENABLE_MUSIC, MapModule.OnEnableMusic)
  ModuleBase.Init(self)
  self.mapNodeRoot = GameObject.GameObject("mapNodeRoot")
  self.mapNodeRoot.localPosition = EC.Vector3.zero
  self.mapEffectNodeRoot = GameObject.GameObject("mapEffectNodeRoot")
  self.mapPlayerNodeRoot = GameObject.GameObject("mapPlayerNodeRoot")
  GameUtil.AsyncLoad(RESPATH.SCENE_LIGHT, function(go)
    local m = Object.Instantiate(go, "GameObject")
    m:SetActive(true)
    self.mLight = m
  end)
  require("Main.Map.MiniMapMgr").Instance():Init()
  Timer:RegisterIrregularTimeListener(self.Update, self)
  self:LoadMapPolygonsCfg()
end
def.static("table", "table").reset = function(param1, param2)
  instance:DelayHide()
end
def.method().DelayHide = function(self)
  if gmodule.moduleMgr:GetModule(ModuleId.LOGIN):IsInWorld() then
    return
  end
end
def.method().HideMap = function(self)
  if self.mapNodeRoot and not self.mapNodeRoot.isnil then
    self.mapNodeRoot:SetActive(false)
  end
end
def.method().EnterWorld = function(p)
  if ECGame.Instance():GetGameState() < _G.GameState.GameWorld then
    ECGame.Instance():SetGameState(_G.GameState.LoadingGameWorld)
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.map.CEnterWorld").new())
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.TssSdkSetUserInfoEx()
    ECMSDK.TssSendData()
  end
end
def.method().ClearTransfer = function(self)
  for k, v in pairs(instance.mTransportEffect) do
    if v then
      ECFxMan.Instance():Stop(v)
    end
  end
  instance.mTransportEffect = {}
end
def.static("table").OnTransferEnterView = function(p)
  local id = p.instanceId
  local pos = p.pos
  local tarMapId = p.targetMapId
  local effect = instance.mTransportEffect[id]
  if effect then
    ECFxMan.Instance():Stop(effect)
    instance.mTransportEffect[id] = nil
  end
  if not gmodule.moduleMgr:GetModule(ModuleId.LOGIN):IsInWorld() and not gmodule.moduleMgr:GetModule(ModuleId.LOGIN):IsLoadingWorld() then
    warn("not enter world")
    return
  end
  local position = Map2DPosTo3D(pos.x, world_height - pos.y)
  local mapTranspointCfg = MapUtility.GetMapTransportCfg(tarMapId)
  if mapTranspointCfg then
    local transResPath = MapModule.TRANSPORT_EFFECT_LIST[mapTranspointCfg.color]
    if transResPath then
      local fx = ECFxMan.Instance():Play(transResPath, position, Quaternion.identity, -1, false, -1)
      fx:GetComponent("FxOne"):set_Stable(true)
      instance.mTransportEffect[id] = fx
    end
  else
    local fx = ECFxMan.Instance():Play(MapModule.TRANSPORT_EFFECT_LIST[ColorType.BLUE], position, Quaternion.identity, -1, false, -1)
    fx:GetComponent("FxOne"):set_Stable(true)
    instance.mTransportEffect[id] = fx
  end
end
def.static("table").OnTransferLeaveView = function(p)
  local effect = instance.mTransportEffect[p.instanceId]
  if effect then
    ECFxMan.Instance():Stop(effect)
  end
  instance.mTransportEffect[p.instanceId] = nil
end
def.static("table").OnSMapEntityEnterView = function(p)
  print("OnSMapEntityEnterView", p.entity_type, tostring(p.instanceid))
  if p.loc then
    p.locs = {
      p.loc
    }
  end
  local entity = instance:GetMapEntity(p.entity_type, p.instanceid)
  if entity == nil then
    if type(p.cfgid) == "userdata" then
      p.cfgid = Int64.ToNumber(p.cfgid)
    end
    entity = MapEntityFactory.Create(p.entity_type, p.instanceid, p.cfgid, p.locs, p.extra_info)
  end
  instance:AddMapEntity(entity)
  entity:EnterView()
end
def.static("table").OnSMapEntityLeaveView = function(p)
  print("OnSMapEntityLeaveView", p.entity_type, tostring(p.instanceid))
  local entity = instance:GetMapEntity(p.entity_type, p.instanceid)
  if entity == nil then
    return
  end
  entity:OnLeaveView()
  instance:RemoveMapEntity(p.entity_type, p.instanceid)
end
def.static("table").OnSSyncMapEntityExtraInfoChange = function(p)
  print("OnSSyncMapEntityExtraInfoChange", p.entity_type, tostring(p.instanceid))
  local entity = instance:GetMapEntity(p.entity_type, p.instanceid)
  if entity == nil then
    warn(string.format("Map entity not found exception: OnSSyncMapEntityExtraInfoChange(entity_type=%d, instanceid=%s)", p.entity_type, tostring(p.instanceid)))
    return
  end
  entity:OnExtraInfoChange(p.extra_info, p.remove_extra_info_keys)
end
def.static("table").OnSSyncMapEntityInfo = function(p)
  print("OnSSyncMapEntityInfo", p.entity_type, tostring(p.instanceid))
  if p.loc then
    p.locs = {
      p.loc
    }
  end
  local entity = instance:GetMapEntity(p.entity_type, p.instanceid)
  if entity == nil then
    warn(string.format("Map entity not found exception: OnSSyncMapEntityInfo(entity_type=%d, instanceid=%s)", p.entity_type, tostring(p.instanceid)))
    return
  end
  entity:InfoChange(p.cfgid, p.locs, p.extra_info)
end
def.static("table").OnSSyncMapEntityMove = function(p)
  print("OnSSyncMapEntityMove", p.entity_type, tostring(p.instanceid))
  local entity = instance:GetMapEntity(p.entity_type, p.instanceid)
  if entity == nil then
    warn(string.format("Map entity not found exception: OnSSyncMapEntityMove(entity_type=%d, instanceid=%s)", p.entity_type, tostring(p.instanceid)))
    return
  end
  entity:SyncMove(p.keyPointPath)
end
def.method("number", "userdata", "=>", "table").GetMapEntity = function(self, entityType, instanceid)
  if self.mMapEntities == nil then
    return nil
  end
  if self.mMapEntities[entityType] == nil then
    return nil
  end
  return self.mMapEntities[entityType][tostring(instanceid)]
end
def.method("table").AddMapEntity = function(self, entity)
  self.mMapEntities = self.mMapEntities or {}
  self.mMapEntities[entity.type] = self.mMapEntities[entity.type] or {}
  self.mMapEntities[entity.type][tostring(entity.instanceid)] = entity
end
def.method("number", "userdata").RemoveMapEntity = function(self, entityType, instanceid)
  if self.mMapEntities == nil then
    return
  end
  if self.mMapEntities[entityType] == nil then
    return
  end
  self.mMapEntities[entityType][tostring(instanceid)] = nil
end
def.method("number", "=>", "table").GetMapEntitiesByType = function(self, entityType)
  if self.mMapEntities == nil then
    return nil
  end
  return self.mMapEntities[entityType]
end
def.method("number").UpdateMapEntities = function(self, dt)
  if self.mMapEntities then
    for _, v in pairs(self.mMapEntities) do
      for k, entity in pairs(v) do
        if entity:IsEmptyUpdate() then
          break
        end
        if entity:IsDestroyed() then
          v[k] = nil
        else
          entity:Update(dt)
        end
      end
    end
  end
end
def.static("table").OnSEnterWorld = function(p)
  instance.mapNodeRoot:SetActive(true)
  instance:LoadMap(p.mapid)
  instance.mapInstanceId = p.mapInstanceId
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local modelInfo = GetModelInfo(p.modelinfo)
  local pubroleMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  heroModule:CreateHeroModel(modelInfo.id, modelInfo, p.pos.x, p.pos.y, p.direction)
  local petdata = p.othermodel[p.TYPE_PET]
  local petModelInfo = petdata and GetModelInfo(petdata)
  local child_data = p.othermodel[p.TYPE_CHILDREN]
  local childInfo = child_data and GetModelInfo(child_data)
  pubroleMgr.invisiblePlayers[modelInfo.id:tostring()] = {
    modelInfo = modelInfo,
    pos = p.pos,
    dir = p.direction,
    petModelInfo = petModelInfo,
    childInfo = childInfo
  }
  ECGame.Instance():setMapInfo(p.mapid, p.pos.x, p.pos.y)
  if petModelInfo then
    pubroleMgr:ShowOtherModel(heroModule.myRole, petModelInfo)
  elseif childInfo then
    pubroleMgr:ShowChildModel(heroModule.myRole, childInfo)
  end
  Camera2D.SetFocus(p.pos.x, p.pos.y)
  ECGame.Instance():SetCameraFocus(p.pos.x, p.pos.y)
  local LoadingMgr = require("Main.Common.LoadingMgr")
  local LoginPreloadMgr = require("Main.Login.LoginPreloadMgr")
  local PreloadResType = LoginPreloadMgr.PreloadResType
  LoginPreloadMgr.Instance():IncProtocolFinishCount(1)
  if gmodule.moduleMgr:GetModule(ModuleId.LOGIN):IsInWorld() then
    LoginPreloadMgr.OnLoadingFinished(true, nil)
  end
end
def.method("=>", "number").GetMapId = function(self)
  return self.currentMapId
end
def.method("=>", "table").GetMapBgMusic = function(self)
  if self.scene == nil then
    return nil
  end
  return self.musicInfo
end
def.method("number").SetTransportEffect = function(self, mapid)
  if nil ~= self.mTransportEffect then
    for i, effect in ipairs(self.mTransportEffect) do
      ECFxMan.Instance():Stop(effect)
    end
    self.mTransportEffect = nil
  end
  self.mTransportEffect = {}
  local transfer = MapUtility.GetMapTransfers(mapid)
  if transfer == nil then
    return
  end
  for i, transferPoint in ipairs(transfer) do
    local mapCfg = MapUtility.GetMapCfg(transferPoint.default_target_map_id)
    local position = Map2DPosTo3D(transferPoint.center_x, world_height - transferPoint.center_y)
    local mapTranspointCfg = MapUtility.GetMapTransportCfg(transferPoint.default_target_map_id)
    if mapTranspointCfg then
      local fx = ECFxMan.Instance():Play(MapModule.TRANSPORT_EFFECT_LIST[mapTranspointCfg.color], position, Quaternion.identity, -1, false, -1)
      table.insert(self.mTransportEffect, fx)
    end
  end
end
def.method("number", "=>", "boolean").LoadMap = function(self, mapid)
  if not ECGame.Instance().m_ScreenDark then
    Application.set_targetFrameRate(60)
  end
  _G.IsLoadMap = true
  _G.MapNodeCount = 0
  _G.MapNodeMax = 0
  MapUtility.StartLoading()
  if self.scene == nil then
    self.scene = MapScene.Create()
  end
  if self.musicInfo == nil then
    self.musicInfo = {}
  end
  _G.IsMutilFrameLoadMap = true
  _G.terrain_tile_max_per_frame = 2
  GameUtil.AddGlobalTimer(2, true, function()
    _G.terrain_tile_max_per_frame = 1
  end)
  SpriteEffect_Release_all()
  local mapcfg = MapUtility.GetMapCfg(mapid)
  if mapcfg ~= nil then
    if _G.log_file_flag then
      utility.AFileSetLogOutput(false)
    end
    do
      local mapPath = mapcfg.mapResPath
      local path = "map/" .. mapPath .. "/" .. mapPath .. ".map"
      MapScene.LoadMap(self.scene, path)
      local myRole = require("Main.Hero.HeroModule").Instance().myRole
      if myRole and myRole:IsInState(RoleState.FLY) then
        self:SetMapExtend(768)
      else
        self:SetMapExtend(256)
      end
      self.battleBg = mapcfg.battleBgId
      local oldMapId = self.currentMapId
      self.currentMapId = mapid
      Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, {
        mapid,
        oldMapId,
        mapPath = mapPath
      })
      local mapsize = MapScene.GetMapSize(self.scene)
      self.map_w = mapsize:width()
      self.map_h = mapsize:height()
      if oldMapId > 0 then
        self:RemovePolygon(oldMapId)
      end
      self:SetPolygonEnable(self.enablePolygon)
      if oldMapId ~= mapid then
        self:ClearTransfer()
      end
      GameUtil.AddGlobalTimer(0, true, function()
        if not mapcfg.canFly and myRole and myRole:IsInState(RoleState.FLY) then
          Toast(textRes.Hero[51])
          if myRole.teamId then
            gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ForceTeamLand(myRole.teamId)
          else
            myRole:FlyDown(nil)
          end
        end
      end)
      ECGame.Instance():SyncGC()
      ECGame.Instance():GCTLog("map")
      if self.enableMusic then
        self.musicInfo.bgMusicIds = mapcfg.bgMusicIds
        self.musicInfo.effMusicId = mapcfg.effMusicId
        self:PlayMapMusic(true)
      end
      _G.IsMutilFrameLoadMap = false
      if _G.log_file_flag then
        utility.AFileSetLogOutput(true)
      end
      return true
    end
  else
    _G.IsLoadMap = false
    printInfo("mapid [%d]", mapid)
    return false
  end
end
def.static().PlayBgMusic = function()
  if not instance.enableMusic then
    return
  end
  if instance.musicInfo and instance.musicInfo.bgMusicIds then
    local idx = math.random(1, #instance.musicInfo.bgMusicIds)
    local music_id = instance.musicInfo.bgMusicIds[idx]
    local musicPath = require("Sound.SoundData").Instance():GetSoundPath(music_id)
    if musicPath and musicPath ~= "" then
      ECSoundMan.Instance():PlayBackgroundMusicWithCallback(musicPath, false, function(isover)
        if isover then
          GameUtil.AddGlobalTimer(0, true, function()
            MapModule.PlayBgMusic()
          end)
        end
      end)
    end
  end
end
def.method("boolean").PlayMapMusic = function(self, playEffMusic)
  MapModule.PlayBgMusic()
  if playEffMusic and self.musicInfo.effMusicId > 0 then
    local effMusicPath = require("Sound.SoundData").Instance():GetSoundPath(self.musicInfo.effMusicId)
    if effMusicPath and effMusicPath ~= self.musicInfo.effMusicPath then
      ECSoundMan.Instance():Play2DSoundEx(effMusicPath, SOUND_TYPES.ENVIRONMENT, 10)
      self.musicInfo.effMusicPath = effMusicPath
    end
  end
end
def.static("table", "table").OnWorldMapButtonClick = function()
  if not instance:IsAllowOpenWorldMap() then
    return
  end
  local worldMapPanel = require("Main.Map.ui.WorldMapPanel").Instance()
  if worldMapPanel:IsShow() then
    worldMapPanel:HidePanel()
  else
    worldMapPanel:ShowPanel()
  end
end
def.method("=>", "boolean").IsAllowOpenWorldMap = function(self)
  local isAllow, errorMsg = _G.IsAllowTo("WorldMapTransfer")
  if not isAllow then
    Toast(errorMsg)
    return false
  end
  return true
end
def.static("table", "table").OnMiniMapButtonClick = function()
  if not instance:IsAllowOpenMiniMap() then
    return
  end
  local miniMapPanel = require("Main.Map.ui.MiniMapPanel").Instance()
  if miniMapPanel:IsShow() then
    miniMapPanel:HidePanel()
  else
    miniMapPanel:ShowPanel()
  end
end
def.method("=>", "boolean").IsAllowOpenMiniMap = function(self)
  local isAllow, errorMsg = _G.IsAllowTo("OpenMiniMap")
  if not isAllow then
    Toast(errorMsg)
    return false
  end
  return true
end
def.method().GotoMenPaiMap = function(self)
  local isFly = require("Main.Hero.HeroModule").Instance().myRole:IsInState(RoleState.FLY)
  if isFly then
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local mapId = MapUtility.GetOccupationMapId(heroProp.occupation)
  self:TransportToMap(mapId)
end
def.method("number").TransportToMap = function(self, mapId)
  local mapCfg = MapUtility.GetMapCfg(mapId)
  MapUtility.TransportToMap(mapId, mapCfg.defaultTransposX, mapCfg.defaultTransposY)
end
def.static("table", "table").OnHeroMove = function(pos, p2)
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if instance.mapNodeRoot and p1 and p1.isFlyBattle then
    instance:SetMapAlpha(0.618)
  end
  instance.mapEffectNodeRoot:SetActive(false)
end
def.static("table", "table").OnLeaveFight = function()
  instance.mapEffectNodeRoot:SetActive(true)
  if mapAlpha ~= 1 then
    instance:SetMapAlpha(1)
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local FlyModule = require("Main.Fly.FlyModule")
  if heroModule.myRole and heroModule.myRole:IsInState(RoleState.FLY) then
    FlyModule.Instance():FlowCloud(0.001, "fly")
    ECGame.Instance():ResetSkyLayer()
  else
    FlyModule.Instance():StopCloud("fly")
    ECGame.Instance():ResetGroundLayer()
  end
end
def.method("number").SetMapAlpha = function(self, a)
  mapAlpha = a
  local renders = instance.mapNodeRoot:GetRenderersInChildren()
  if renders then
    for i = 1, #renders do
      local r = renders[i]
      if r ~= nil and not r.isnil then
        local srcMat = r.material
        if srcMat then
          srcMat:SetFloat("_Lighten", a)
        end
      end
    end
  end
end
def.method().RemoveAllMapEntities = function(self)
  if self.mMapEntities then
    for _, v in pairs(self.mMapEntities) do
      for _, entity in pairs(v) do
        entity:Destroy()
      end
    end
    self.mMapEntities = nil
  end
end
def.method("table", "boolean").RemoveOutViewMapEntities = function(self, tpos, isInAir)
  if not self.mMapEntities then
    return
  end
  local pubRoleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if not pubRoleModule then
    return
  end
  for k, v in pairs(self.mMapEntities) do
    if not MapEntityFactory.NOT_OWN_VIEW_MAP_ENTITY_TYPES[k] then
      for instid, entity in pairs(v) do
        local rpos = entity:GetPos()
        if rpos and pubRoleModule:CheckOutView(rpos, tpos, isInAir) then
          entity:Destroy()
          v[instid] = nil
        end
      end
    end
  end
end
def.static("table", "table").OnStartDrama = function()
  ECSoundMan.Instance():StopBackgroundMusic(1)
end
def.static("table", "table").OnEndDrama = function()
  if not require("Main.Fight.FightMgr").Instance().isInFight then
    instance:PlayMapMusic(false)
  end
  local hero = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if hero then
    local pos = hero:GetPos()
    pos.y = world_height - pos.y
    local campos = EC.Vector3.new(pos.x, pos.y, -100)
    ECGame.Instance().m_2DWorldCamObj.localPosition = campos
  end
end
def.static("table", "table").OnCEnterWorld = function(p)
  ECGame.Instance().m_2DWorldCamObj:SetActive(true)
  ECGame.Instance().m_Main3DCam:SetActive(true)
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance.musicInfo = nil
  instance:ClearTransfer()
  if instance.mapNodeRoot and not instance.mapNodeRoot.isnil and not gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsTerrainRetain() then
    instance.mapNodeRoot:SetActive(true)
  end
  if mapAlpha ~= 1 then
    instance:SetMapAlpha(1)
  end
  instance:RemoveAllMapEntities()
  instance:RemovePolygon(instance.currentMapId)
  instance.enableMusic = true
end
def.static("table", "table").OnEnableMusic = function(p1, p2)
  instance.enableMusic = p1 ~= nil and p1[1] ~= nil
  if instance.enableMusic then
    local playEffMusic = p1 ~= nil and p1[2] ~= nil
    instance:PlayMapMusic(playEffMusic)
  else
    ECSoundMan.Instance():StopBackgroundMusic(1)
  end
end
def.method("number").SetMapExtend = function(self, size)
  if self.scene then
    MapScene.SetMapExtendSize(self.scene, size * Screen.width / Screen.height, size * 1.5)
  end
end
def.method("number").Update = function(self, dt)
  self:UpdateMapEntities(dt)
end
def.method("number", "number", "number", "number", "number", "=>", "table").FindPath = function(self, start_x, start_y, target_x, target_y, distance)
  local findpath
  if LogicMap.Instance():IsLoaded() then
    findpath = PathFinder.Instance():FindPath(start_x, start_y, target_x, target_y, distance)
    if findpath == nil and self.scene then
      findpath = MapScene.FindPath(self.scene, start_x, start_y, target_x, target_y, distance)
    end
  elseif MapScene.IsBarrierXY(self.scene, start_x, start_y) then
    local valid_pt = MapScene.FindAdjacentValidPoint(self.scene, start_x, start_y)
    if valid_pt then
      findpath = {
        [0] = {x = start_x, y = start_y},
        [1] = {
          x = valid_pt:x(),
          y = valid_pt:y()
        }
      }
    end
  else
    findpath = MapScene.FindPath(self.scene, start_x, start_y, target_x, target_y, distance)
  end
  if findpath and self.enablePolygon then
    local polygon
    for k, v in pairs(self.MapPolygonsCfg) do
      if v.mapId == self.currentMapId then
        if self:PolygonContains(v, {x = start_x, y = start_y}) then
          polygon = v
          break
        end
      end
    end
    if polygon then
      for i = 1, #findpath do
        if not self:PolygonContains(polygon, findpath[i]) then
          Toast(textRes.Map[19])
          return nil
        end
      end
    end
  end
  return findpath
end
def.method("table", "table", "table", "=>", "number").Cross = function(self, p1, p2, p0)
  return (p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y)
end
def.method("table", "table", "=>", "boolean").PolygonContains = function(self, polygon, pt)
  local flag = 1
  local n = #polygon.vertices
  if self:Cross(polygon.vertices[n], polygon.vertices[2], polygon.vertices[1]) > 0 then
    flag = -1
  end
  if self:Cross(pt, polygon.vertices[2], polygon.vertices[1]) * flag > 0 or self:Cross(pt, polygon.vertices[n], polygon.vertices[1]) * flag < 0 then
    return false
  end
  local i, j = 2, n
  local line = -1
  while i <= j do
    local mid = math.floor((i + j) / 2)
    if self:Cross(pt, polygon.vertices[mid], polygon.vertices[1]) * flag > 0 then
      line = mid
      j = mid - 1
    else
      i = mid + 1
    end
  end
  return self:Cross(polygon.vertices[line], pt, polygon.vertices[line - 1]) * flag > 0
end
def.method().LoadMapPolygonsCfg = function(self)
  local entries = DynamicData.GetTable("data/cfg/polygons.bny")
  local size = DynamicDataTable.GetRecordsCount(entries)
  self.MapPolygonsCfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record == nil then
      return
    end
    local polygon = {}
    local mapId = record:GetIntValue("mapId")
    polygon.id = record:GetIntValue("id")
    polygon.mapId = mapId
    polygon.tag = record:GetIntValue("tag")
    local count = record:GetVectorSize("vtxList")
    local idx = 1
    polygon.vertices = {}
    for idx = 1, count do
      local vtx = record:GetVectorValueByIdx("vtxList", idx - 1)
      local vetex = {}
      vetex.x = vtx:GetIntValue("x")
      vetex.y = vtx:GetIntValue("y")
      table.insert(polygon.vertices, vetex)
    end
    self.MapPolygonsCfg[polygon.id] = polygon
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("table").ShowPolygon = function(self, polygon)
  if polygon == nil or polygon.vertices == nil then
    return
  end
  local effres = _G.GetEffectRes(702034042)
  local n = #polygon.vertices
  for i = 1, n do
    local start_pt = polygon.vertices[i]
    local end_pt = polygon.vertices[i + 1]
    if i == n then
      end_pt = polygon.vertices[1]
    end
    local start_3d = Map2DPosTo3D(start_pt.x, world_height - start_pt.y)
    local end_3d = Map2DPosTo3D(end_pt.x, world_height - end_pt.y)
    local eff_pos = Map2DPosTo3D((start_pt.x + end_pt.x) / 2, world_height - (start_pt.y + end_pt.y) / 2)
    local sideObj = polygon.vertices[i].sideObj
    if sideObj then
      ECFxMan.Instance():Stop(sideObj)
    end
    local diff = end_3d - start_3d
    sideObj = ECFxMan.Instance():Play(effres.path, eff_pos, Quaternion.identity, -1, false, -1)
    polygon.vertices[i].sideObj = sideObj
    sideObj.localScale = EC.Vector3.new(diff:get_Length() / 2, 1, 1)
    sideObj.forward = diff
    local angle = sideObj.transform.eulerAngles.y
    sideObj.localRotation = Quaternion.Euler(EC.Vector3.new(0, angle + 90, 0))
  end
end
def.method("boolean").SetPolygonEnable = function(self, enable)
  self.enablePolygon = enable
  if enable then
    for k, v in pairs(self.MapPolygonsCfg) do
      if v.mapId == self.currentMapId then
        self:ShowPolygon(v)
      end
    end
  else
    self:RemovePolygon(self.currentMapId)
  end
end
def.method("number").RemovePolygon = function(self, mapId)
  for k, v in pairs(self.MapPolygonsCfg) do
    if v.mapId == mapId then
      local n = #v.vertices
      for i = 1, n do
        local sideObj = v.vertices[i].sideObj
        if sideObj then
          ECFxMan.Instance():Stop(sideObj)
          v.vertices[i].sideObj = nil
        end
      end
    end
  end
end
MapModule.Commit()
return MapModule
