local Lplus = require("Lplus")
local Replayer = Lplus.Class("Replayer")
local ECGame = Lplus.ForwardDeclare("ECGame")
require("Main.Fight.FightConst")
local ECFxMan = require("Fx.ECFxMan")
local def = Replayer.define
local EC = require("Types.Vector")
local instance
local Fight = require("netio.protocol.mzm.gsp.fight.Fight")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local FightTeam = require("Main.Fight.FightTeam")
local FightUnit = require("Main.Fight.FightUnit")
local FightModel = require("Main.Fight.FightModel")
local Octets = require("netio.Octets")
local DlgFight = require("Main.Fight.ui.DlgFight")
local PlayType = require("netio.protocol.mzm.gsp.fight.PlayType")
local ECSoundMan = require("Sound.ECSoundMan")
local TIP_INFO_TYPE = require("consts.mzm.gsp.fight.confbean.TipInfoType")
local FIGHT_TYPE = require("netio.protocol.mzm.gsp.fight.Fight")
local PetInterface = require("Main.Pet.Interface")
local PlaySkill = require("netio.protocol.mzm.gsp.fight.PlaySkill")
local PlayCapture = require("netio.protocol.mzm.gsp.fight.PlayCapture")
local PlaySummon = require("netio.protocol.mzm.gsp.fight.PlaySummon")
local PlayEscape = require("netio.protocol.mzm.gsp.fight.PlayEscape")
local PlayTalk = require("netio.protocol.mzm.gsp.fight.PlayTalk")
local PlayTip = require("netio.protocol.mzm.gsp.fight.PlayTip")
local PlayUseItem = require("netio.protocol.mzm.gsp.fight.PlayUseItem")
local PlayFighterStatus = require("netio.protocol.mzm.gsp.fight.PlayFighterStatus")
local PlayChangeFightMap = require("netio.protocol.mzm.gsp.fight.PlayChangeFightMap")
local PlayChangeFighter = require("netio.protocol.mzm.gsp.fight.PlayChangeFighter")
local PlayChangeModel = require("netio.protocol.mzm.gsp.fight.PlayChangeModel")
local SoundData = require("Sound.SoundData")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local FighterStatus = require("netio.protocol.mzm.gsp.fight.FighterStatus")
local AttackResultBean = require("netio.protocol.mzm.gsp.fight.AttackResultBean")
local FlyMount = require("Main.Fight.FlyMount")
local FlyModule = require("Main.Fly.FlyModule")
local GUIMan = require("GUI.ECGUIMan")
local NPCInterface = require("Main.npc.NPCInterface")
local FightUtils = require("Main.Fight.FightUtils")
local FightMgr = Lplus.ForwardDeclare("FightMgr")
local mainCam, tipResume
def.field("number").replayId = 1
def.field("number").fightType = 0
def.field("number").fightCfgId = 0
def.field("userdata").fightInstanceId = nil
def.field("table").rounds = nil
def.field("table").teams = nil
def.field("table").groups = nil
def.field("userdata").fightSceneNode = nil
def.field("userdata").fight_bg = nil
def.field("userdata").bgMask = nil
def.field("table").fightUnits = nil
def.field("boolean").isInFight = false
def.field("table").waitForTargets = nil
def.field("table").nextAction = nil
def.field("function").nextPlay = nil
def.field(FightUnit).followTarget = nil
def.field("userdata").fightPlayerNodeRoot = nil
def.field("table").shakeParam = nil
def.field("number").deltaAngle = 0
def.field("table").cameraParam = nil
def.field("userdata").fight3DScene = nil
def.field("table").formationIcons = nil
def.field("boolean").isPerspective = false
def.field("table").hasLoaded = nil
def.field("userdata").damageRoot = nil
def.field("table").sceneInfo = nil
def.field("table").actionMap = nil
def.field("boolean").is3dScene = false
def.field("table").cam3dParam = nil
def.field("boolean").playVoice = true
def.field("number").curRound = 0
def.field("number").loadModelTime = -1
def.field("boolean").isFlyBattle = false
def.field("boolean").isInUpdate = false
def.field("table").tobeAdded = nil
def.field("table").tobeDeleted = nil
def.field("userdata").fightDamageCam = nil
def.field("userdata").fightCam = nil
def.field("table").playController = nil
def.field("number").countDown = -1
def.field("table").record = nil
def.field("boolean").paused = false
def.field("number").playlist_num = 1
def.field("boolean").showLog = false
def.field("number").realPlayedRound = 0
def.field("table").toBeSetAppearance = nil
def.field("table").ui = nil
def.field("number").myTeam = -1
def.field("userdata").fightPetRecordId = nil
def.field("number").join_timer_id = 0
def.field("boolean").isEnding = false
def.field("table").petFightCells = nil
def.field("userdata").petCellCam = nil
def.field("table").fightPos = nil
def.static("=>", Replayer).Instance = function()
  if instance == nil then
    instance = Replayer()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSyncRecordEnterFight", Replayer.OnSSyncRecordEnterFight)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSyncRecordRoundPlay", Replayer.OnSSyncRecordRoundPlay)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSyncRecordFightEnd", Replayer.OnSSyncRecordFightEnd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSyncRealtimeRecordEnterFight", Replayer.OnSSyncRealtimeRecordEnterFight)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSyncRealtimeRecordRoundPlay", Replayer.OnSSyncRealtimeRecordRoundPlay)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSyncRealtimeRecordFightEnd", Replayer.OnSSyncRealtimeRecordFightEnd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSyncRealtimeRecordRoundInfo", Replayer.OnSSyncRealtimeRecordRoundInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SPetFightCVCStart", Replayer.OnSPetFightCVCStart)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_LOADED, Replayer.OnModelLoaded)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, Replayer.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LONG_TOUCH_TARGET, Replayer.OnLongTouchTarget)
end
local BattleFieldPos = EC.Vector3.new(-5000, 0, 0)
local BattleFieldCamPos = EC.Vector3.new(-1000, -1000, -100)
def.method().Prepare = function(self)
  if self.fightSceneNode then
    return
  end
  self.fightPlayerNodeRoot = GameObject.GameObject("fightPlayerNodeRoot_" .. self.replayId)
  self.fightPlayerNodeRoot.localPosition = BattleFieldPos
  self.damageRoot = GameObject.GameObject("FightDamageRoot_" .. self.replayId)
  self.damageRoot:SetLayer(ClientDef_Layer.FIGHT_UI)
  self.damageRoot:SetActive(false)
  local root = self.damageRoot:AddComponent("UIRoot")
  root.scalingStyle = 1
  root.manualHeight = ECGame.Instance().m_2DWorldCam.orthographicSize * 2
  local uipanel = self.damageRoot:AddComponent("UIPanel")
  uipanel.depth = -1
  self.fightSceneNode = GameObject.GameObject("fightSceneNode_" .. self.replayId)
  self.fightSceneNode:SetLayer(ClientDef_Layer.Fight)
  self.fightSceneNode.localPosition = EC.Vector3.new(-5000, 0, -9600)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.NO_SKILL_VOICE)
  self.playVoice = not setting.isEnabled
  self.fightDamageCam = FightMgr.Instance().fightDamageCam
  self.playController = require("Main.Fight.PlayController").Create()
end
def.static("table").OnSPetFightCVCStart = function(p)
  instance.fightPetRecordId = p.recordid
end
def.method("=>", "boolean").IsPetFightCVC = function(self)
  if self.record == nil then
    return false
  end
  return self.record.isPetFightCVC == true
end
def.method().StartPlay = function(self)
  local p = self.record and self.record.startpro
  if p then
    Replayer.OnSEnterFight(p, true)
  end
end
def.static("table").OnSSyncRecordEnterFight = function(p)
  instance.record = {}
  instance.record.id = p.recordid
  instance.curRound = 0
  local startpro = require("netio.protocol.mzm.gsp.fight.SEnterFightBrd").new()
  Octets.unmarshalBean(p.enter_fight_content, startpro)
  instance.record.startpro = startpro
  instance.paused = false
end
def.static("table").OnSSyncRecordRoundPlay = function(p)
  if instance.record == nil or instance.record.id == nil then
    return
  end
  if not instance.record.id:eq(p.recordid) then
    return
  end
  local rounds = instance.record.rounds
  if rounds == nil then
    rounds = {}
    instance.record.rounds = rounds
  end
  local round_play = require("netio.protocol.mzm.gsp.fight.SRoundPlayBrd").new()
  Octets.unmarshalBean(p.round_play_content, round_play)
  round_play.round_num = p.round
  rounds[p.round] = round_play
end
def.static("table").OnSSyncRecordFightEnd = function(p)
  if instance.record == nil or instance.record.id == nil then
    return
  end
  if not instance.record.id:eq(p.recordid) then
    return
  end
  local endpro = require("netio.protocol.mzm.gsp.fight.SFightEndBrd").new()
  Octets.unmarshalBean(p.fight_end_content, endpro)
  instance.record.endpro = endpro
  instance.record.isPetFightCVC = instance.fightPetRecordId ~= nil and instance.fightPetRecordId:eq(instance.record.id)
  instance.fightPetRecordId = nil
  instance:StartPlay()
end
def.static("table").OnSSyncRealtimeRecordEnterFight = function(p)
  instance.record = {}
  instance.record.id = p.recordid
  local startpro = require("netio.protocol.mzm.gsp.fight.SEnterFightBrd").new()
  Octets.unmarshalBean(p.enter_fight_content, startpro)
  instance.record.startpro = startpro
  instance.record.is_realtime = p.is_realtime == 1
  if instance.record.is_realtime then
    instance.curRound = p.rounds
    instance.realPlayedRound = p.rounds
  else
    instance.curRound = 0
    instance.realPlayedRound = 0
  end
  instance.paused = false
  if instance.curRound == 0 then
    instance:StartPlay()
  end
end
def.static("table").OnSSyncRealtimeRecordRoundPlay = function(p)
  if instance.record == nil or instance.record.id == nil then
    return
  end
  if not instance.record.id:eq(p.recordid) then
    return
  end
  local rounds = instance.record.rounds
  if rounds == nil then
    rounds = {}
    instance.record.rounds = rounds
  end
  local round_play = require("netio.protocol.mzm.gsp.fight.SRoundPlayBrd").new()
  Octets.unmarshalBean(p.round_play_content, round_play)
  round_play.round_num = p.round
  rounds[p.round] = round_play
  if instance.realPlayedRound > 0 and p.round == instance.realPlayedRound then
    instance.realPlayedRound = 0
    instance:SkipToRoundEnd(p.round)
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, {
      isFlyBattle = instance.isFlyBattle
    })
  end
end
def.static("table").OnSSyncRealtimeRecordFightEnd = function(p)
  if instance.record == nil or instance.record.id == nil then
    return
  end
  if not instance.record.id:eq(p.recordid) then
    return
  end
  local endpro = require("netio.protocol.mzm.gsp.fight.SFightEndBrd").new()
  Octets.unmarshalBean(p.fight_end_content, endpro.new())
  instance.record.endpro = endpro
  if instance.countDown >= 0 and (instance.record.rounds == nil or instance.curRound > #instance.record.rounds) then
    Replayer.OnFightEnd(endpro)
  end
end
def.static("table").OnSSyncRealtimeRecordRoundInfo = function(p)
  if instance.record == nil or instance.record.id == nil then
    return
  end
  if instance.record.id:eq(p.recordid) then
    local tipstr = string.format(textRes.Fight[66], p.round)
    if tipResume == nil then
      tipResume = require("GUI.CommonUITipsDlg").ShowConstTipWithAlign(tipstr, {x = 0, y = 0}, Alignment.Center)
    else
      tipResume:ShowConstDlg(tipstr, {x = 0, y = 0})
    end
  end
end
def.static("table", "boolean").OnSEnterFight = function(p, autoNext)
  if instance.isInFight then
    instance:Reset()
  end
  instance.isInFight = true
  local oldTimeLimit = 0.015
  GameUtil.SetLoadTimeLimit(0)
  Application.set_targetFrameRate(60)
  GameUtil.AddGlobalTimer(4, true, function()
    GameUtil.SetLoadTimeLimit(0.015)
    local cur_rate = Application.get_targetFrameRate()
    if cur_rate == 60 then
      Application.set_targetFrameRate(_G.max_frame_rate)
    end
  end)
  FxCacheMan.Instance.gameObject.localPosition = BattleFieldPos
  if p.fight.fight_type == FIGHT_TYPE.TYPE_PETCVC then
    instance.fightPos = _G.FightConst.PET_BATTLE_POS
  else
    instance.fightPos = _G.FightConst.FightPos
  end
  if not instance.playController:IsRunning() then
    instance.playController:Start()
  end
  instance.fightInstanceId = p.fight.fight_uuid
  instance.fightCfgId = p.fight.fight_cfg_id
  if instance.fightUnits then
    for k, v in pairs(instance.fightUnits) do
      if v and v.model then
        v:Destroy()
      end
      instance.fightUnits[k] = nil
    end
  end
  instance.fightUnits = {}
  instance.hasLoaded = {}
  local game = ECGame.Instance()
  game.m_isInFight = true
  if instance.fight3DScene == nil then
    GameUtil.AddGlobalTimer(1, true, function()
      if instance.isInFight and instance.fight3DScene == nil then
        GameUtil.AsyncLoad(RESPATH.FIGHT_3D_SCENE, function(obj)
          if obj and instance.isInFight and instance.fight3DScene == nil then
            instance.fight3DScene = Object.Instantiate(obj, "GameObject")
            instance.fight3DScene.parent = instance.fightPlayerNodeRoot
            instance.fight3DScene:SetActive(false)
            instance.fight3DScene.transform.localPosition = EC.Vector3.zero
            instance.fight3DScene:SetLayer(ClientDef_Layer.FightPlayer)
          end
        end)
      end
    end)
  end
  local worldBossCfg
  if p.fight.fight_type == FIGHT_TYPE.TYPE_PVIMonster and 0 < p.fight.fight_cfg_id then
    worldBossCfg = FightUtils.GetWorldBossActionCfg(p.fight.fight_cfg_id)
  end
  instance.isFlyBattle = false
  if 0 < p.fight.fight_cfg_id then
    local fightCfg = FightUtils.GetFightCfg(p.fight.fight_cfg_id)
    if fightCfg then
      instance.isFlyBattle = fightCfg.isFlyBattle
    end
  end
  if instance.isFlyBattle then
    instance:SetToSkyMode()
  else
    instance:SetToGroundMode()
  end
  Timer:RegisterIrregularTimeListener(Replayer.Update, instance)
  mainCam = Object.Instantiate(game.m_Main3DCam, "GameObject")
  game.m_Main3DCam:SetActive(false)
  mainCam:SetActive(true)
  game.m_cloudCam:SetActive(false)
  local cam = mainCam:GetComponent("Camera")
  CommonCamera.game3DCamera = cam
  cam:set_cullingMask(get_cull_mask(ClientDef_Layer.FightPlayer))
  cam.orthographicSize = cam.orthographicSize * FightMgr.FIGHT_SCENE_SCALE
  HUDFollowTarget.gameCamera = cam
  ECPateTextComponent.gameCamera = cam
  mainCam.parent = instance.fightPlayerNodeRoot
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.ENABLE_MUSIC, {false, false})
  instance.sceneInfo = FightUtils.GetFightTypeCfg(p.fight.fight_dis_type)
  if instance.sceneInfo then
    ECSoundMan.Instance():PlayBackgroundMusic(instance:GetBgMusic(instance.sceneInfo.musics), true)
  end
  local guiMan = GUIMan.Instance()
  local bgId = 0
  if game.m_fightCam == nil then
    game:SetFightCamera()
  end
  game.m_fightCam:SetActive(false)
  if instance.fightCam == nil then
    instance.fightCam = Object.Instantiate(game.m_fightCam, "GameObject")
  else
    instance.fightCam:SetActive(true)
  end
  bgId = instance:GetBgPic(instance.sceneInfo.bgIds)
  if bgId == 0 then
    bgId = gmodule.moduleMgr:GetModule(ModuleId.MAP).battleBg
  end
  if not FightMgr.Instance().isInFight and autoNext then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, {
      isFlyBattle = instance.isFlyBattle
    })
  end
  instance.groups = {}
  instance.teams = {}
  FightConst.ACTIVE_TEAM = FightConst.RIGHT_BOTTOM
  FightConst.PASSIVE_TEAM = FightConst.LEFT_TOP
  instance:CreateFightTeam(p.fight.active_team, FightConst.ACTIVE_TEAM)
  instance:CreateFightTeam(p.fight.passive_team, FightConst.PASSIVE_TEAM)
  if instance.toBeSetAppearance then
    for k, v in pairs(instance.toBeSetAppearance) do
      local unit = instance:GetFightUnit(k)
      if unit then
        unit:SetAppearance(v)
      end
    end
    instance.toBeSetAppearance = nil
  end
  guiMan.m_hudCameraGo.localPosition = BattleFieldCamPos
  guiMan.m_hudCameraGo2.localPosition = BattleFieldCamPos
  local pos3d = EC.Vector3.zero
  mainCam.localPosition = pos3d - mainCam.forward * 15
  if worldBossCfg then
    instance:Load3DSceneLight()
    if instance.fightCam then
      instance.fightCam:SetActive(false)
    end
    guiMan.m_hudCamera.clearFlags = CameraClearFlags.Depth
  elseif bgId > 0 then
    instance:LoadFightBg(bgId, false)
    if instance.fightCam then
      instance.fightCam:SetActive(true)
    end
  elseif not instance.isFlyBattle then
    instance:LoadFightBgMask()
    if instance.fightCam then
      instance.fightCam:SetActive(true)
    end
  end
  instance.fightCam.localPosition = EC.Vector3.new(-5000, 0, -10000)
  instance.fightType = p.fight.fight_type
  if instance.fightType == FIGHT_TYPE.TYPE_PETCVC then
    if autoNext then
      instance:DestroyPetFightCells()
      if instance.petFightCells == nil then
        instance.petFightCells = {}
      end
      instance:CreateCell(FightConst.ACTIVE_TEAM, constant.CPetBattleConsts.blueGrid, constant.CPetBattleConsts.blueGridNoPet)
      instance:CreateCell(FightConst.PASSIVE_TEAM, constant.CPetBattleConsts.redGrid, constant.CPetBattleConsts.redGridNoPet)
      if instance.petCellCam == nil then
        instance.petCellCam = Object.Instantiate(mainCam, "GameObject")
        instance.petCellCam.parent = instance.fightPlayerNodeRoot
        instance.petCellCam.localPosition = mainCam.localPosition
        local cam_component = instance.petCellCam:GetComponent("Camera")
        cam_component:set_cullingMask(get_cull_mask(ClientDef_Layer.Fight))
        cam_component.clearFlags = CameraClearFlags.Depth
        cam_component.depth = CameraDepth.UP_BATTLEMAP
      end
      Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_PET_BATTLE, nil)
      local effdata = _G.GetEffectRes(constant.CPetBattleConsts.effectStart)
      require("Fx.GUIFxMan").Instance():Play(effdata.path, "", 0, 0, 2, false)
      instance.ui = require("Main.Fight.ui.DlgPetFight").Instance()
      instance.ui:ShowDlg()
    end
    if 0 > instance.myTeam and instance:IsPetFightCVC() then
      instance.myTeam = FightConst.ACTIVE_TEAM
    end
  else
    instance:DestroyPetFightCells()
    instance.ui = require("Main.Fight.ui.DlgReplay").Instance()
    instance.ui:ShowDlg()
  end
  instance.rounds = {}
  FightMgr.Instance().soundEnable = false
  DlgFight.Instance():SetVisible(false)
  if worldBossCfg then
    instance:SetWorldBossInfo(worldBossCfg)
  end
  guiMan.m_hudCamera2.enabled = true
  guiMan.m_hudCameraGo2:SetActive(true)
  guiMan.m_camera.clearFlags = CameraClearFlags.Nothing
  if instance.fightDamageCam then
    instance.fightDamageCam:SetActive(true)
  end
  instance.damageRoot:SetActive(true)
  FightMgr.Instance().damageRoot:SetActive(false)
  if autoNext then
    instance:GotoNextRound()
  end
end
def.method("number", "number", "number").CreateCell = function(self, teamId, modelId, defaultModelId)
  local ECModel = require("Model.ECModel")
  local team = self.teams[teamId]
  if team == nil then
    return
  end
  local formationCfg = require("Main.PetTeam.PetTeamInterface").GetFormationCfg(team.formation)
  local posmap = {}
  local modelpath = GetModelPath(modelId)
  local defaultModelPath = GetModelPath(defaultModelId)
  if formationCfg then
    for _, v in pairs(formationCfg.pos2IdxMap) do
      local pos = FightUtils.GetFightPosByPetFormationPos(v)
      if pos > 0 then
        posmap[pos] = modelpath
      end
    end
  end
  for i = 1, 15 do
    if 1 < i % 5 and i % 5 < 5 then
      do
        local idx = bit.lshift(teamId, 16) + i
        local cell = instance.petFightCells[idx]
        if cell then
          cell:Destroy()
          instance.petFightCells[idx] = nil
        end
        cell = ECModel.new(modelId)
        cell.defaultLayer = ClientDef_Layer.Fight
        cell:SetParentNode(self.fightPlayerNodeRoot)
        local pos = self.fightPos[teamId].Pos[i]
        local respath = posmap[i] or defaultModelPath
        cell:Load2(respath, function(m)
          if m == nil then
            return
          end
          m.m_model.localPosition = Map2DPosTo3D(pos.x, pos.y)
          m:SetScale(20)
        end, false)
        instance.petFightCells[idx] = cell
      end
    end
  end
end
local fightBgRotation = Quaternion.Euler(EC.Vector3.new(0, 180, 0))
def.method("number", "boolean").LoadFightBg = function(self, bgId, showMask)
  local respath = GetIconPath(bgId)
  if respath == nil or respath == "" then
    Debug.LogWarning("fight bg path is nil or empty for id: ", bgId)
    return
  end
  GameUtil.AsyncLoad(respath, function(obj)
    if not self.isInFight then
      return
    end
    if self.fight_bg == nil then
      self.fight_bg = Object.Instantiate(obj, "GameObject")
      self.fight_bg:SetLayer(ClientDef_Layer.Fight)
      self.fight_bg.name = "Sprite_FightSceneBg"
      self.fight_bg.transform.parent = self.fightSceneNode.transform
      self.fight_bg.localPosition = EC.Vector3.zero
      local orthographicSize = ECGame.Instance().m_fightCam:GetComponent("Camera").orthographicSize
      self.fight_bg.localScale = EC.Vector3.one * orthographicSize * 4
      self.fight_bg.localRotation = fightBgRotation
    end
    if not showMask and self.bgMask then
      self.bgMask:Destroy()
      self.bgMask = nil
    end
    ECGame.Instance().m_2DWorldCamObj:SetActive(false)
  end, true, true, true)
end
def.method().Load3DSceneLight = function(self)
  GameUtil.AsyncLoad(RESPATH.LIGHT_MAP, function(obj)
    if not self.isInFight then
      return
    end
    if not obj then
      warn("[Fight]scene is not found: ", respath)
      return
    end
    ECGame.Instance().m_2DWorldCamObj:SetActive(false)
    GameUtil.SetLightmaps({obj})
  end)
end
local formationRotationVector = {
  EC.Vector3.new(0, 180, 0),
  EC.Vector3.new(0, 180, 180)
}
def.method("string", "number").LoadFormationIcon = function(self, respath, team)
  GameUtil.AsyncLoad(respath, function(obj)
    if not self.isInFight then
      return
    end
    if not obj then
      Debug.LogWarning("[Fight]FormationIcon is not found: ", respath)
      return
    end
    if self.formationIcons == nil then
      self.formationIcons = {}
    end
    local icon = self.formationIcons[team]
    if icon == nil then
      icon = Object.Instantiate(obj, "GameObject")
      icon:SetLayer(ClientDef_Layer.Fight)
      local pos = self.fightPos[team].Attack_center
      icon.transform.parent = self.fightSceneNode.transform
      icon.localPosition = EC.Vector3.new(pos.x, pos.y, -100)
      local orthographicSize = ECGame.Instance().m_fightCam:GetComponent("Camera").orthographicSize
      icon.localScale = EC.Vector3.one * orthographicSize * 2
      icon.localRotation = Quaternion.Euler(formationRotationVector[team])
      self.formationIcons[team] = icon
    end
  end)
end
def.method("number", "=>", "table").GetRoundData = function(self, roundnum)
  if self.record == nil or self.record.rounds == nil then
    return nil
  end
  return self.record.rounds[roundnum]
end
def.method().GotoNextRound = function(self)
  self.curRound = self.curRound + 1
  self.ui:NextRound()
  local p = self.record.rounds and self.record.rounds[self.curRound]
  if p then
    if self.fightInstanceId == nil or not self.fightInstanceId:eq(p.fight_uuid) then
      return
    end
    Debug.LogWarning(string.format("play round: %d", self.curRound))
    local round = {
      round_num = self.curRound,
      cmd_time = constant.FightConst.WAIT_CMD_TIME
    }
    round.playlist = p.playlist
    table.insert(instance.rounds, round)
  elseif self.record.is_realtime then
    tipResume = require("GUI.CommonUITipsDlg").ShowConstTipWithAlign(textRes.Fight[64], {x = 0, y = 0}, Alignment.Center)
  end
  self.countDown = 3
end
def.method("=>", "boolean").PlayNextRound = function(self)
  local cur_round = self:GetRoundData(self.curRound)
  if cur_round == nil then
    return false
  end
  if tipResume then
    tipResume:HideDlg()
    tipResume = nil
  end
  self.ui:StopCountDown()
  for _, v in pairs(instance.fightUnits) do
    if v and v.model then
      v:SetReady(true)
    end
  end
  if cur_round.playlist then
    self.playlist_num = 1
    self:PlayNext()
  else
    Debug.LogWarning(string.format("playlist not found in round(%d %s)", self.curRound, tostring(cur_round)))
  end
  return true
end
def.method().PlayNext = function(self)
  if self.hasLoaded and #self.hasLoaded < table.nums(self.fightUnits) then
    self.nextPlay = Replayer.PlayNext
    if self.loadModelTime < 0 then
      self.loadModelTime = 3
    end
    return
  end
  self.hasLoaded = nil
  self.waitForTargets = {}
  local action = self.nextAction
  self.nextAction = self:GetNextAction()
  if action == nil then
    action = self.nextAction
    self.nextAction = self:GetNextAction()
  end
  if action == nil then
    Debug.LogWarning("[Fight]next action is nil")
    return
  end
  if action.actionType == PlayType.PLAY_CHANGE_FIGHT_MAP then
    self:LoadFightBg(action.mapSource, false)
    self.nextPlay = Replayer.PlayNext
    return
  end
  if action.actionType == PlayType.PLAY_TEAM_JOIN then
    self.playTime = 20
    self:WaitForNewCreatedUnits()
    do
      local teamId = FightConst.ACTIVE_TEAM
      if action.camp == action.PASSIVE_TEAM then
        teamId = FightConst.PASSIVE_TEAM
      end
      self:CreateFightTeam(action.team, teamId)
      local members = self.teams[teamId]:GetAllMembers()
      for mid, m in pairs(members) do
        m:PrepareToJoin()
        table.insert(self.waitForTargets, mid)
      end
      self.join_timer_id = GameUtil.AddGlobalTimer(0.1, false, function()
        if not self.isInFight then
          self:RemoveJoinTimer()
          return
        end
        if self.hasLoaded == nil then
          return
        end
        if #self.hasLoaded == table.nums(self.fightUnits) then
          for _, m in pairs(members) do
            m:Join()
          end
          self.hasLoaded = nil
        end
      end)
      return
    end
  end
  local i = 1
  local deltaTime = 0
  if action.actionType == PlayType.PLAY_FIGHTER_STATUS then
    for k, v in pairs(action.fightermap) do
      table.insert(self.waitForTargets, k)
    end
    for k, v in pairs(action.fightermap) do
      local unit = self:GetFightUnit(k)
      if unit then
        unit:ShowStatusChange(v.statuses)
      else
        Debug.LogWarning("[Fight]unit not found when PLAY_FIGHTER_STATUS: ", k)
        local idx = table.indexof(self.waitForTargets, k)
        table.remove(self.waitForTargets, idx)
      end
    end
    return
  end
  if action.actionType == PlayType.PLAY_TIP then
    local tip = FightUtils.GetFightTipCfg(action.ret)
    if tip then
      local unit = self:GetFightUnit(action.fighterid)
      local showTip = tip.targetType == TIP_INFO_TYPE.ALL
      if showTip then
        Toast(string.format(tip.tipStr, unpack(action.args)))
      end
    end
    self.nextPlay = Replayer.PlayNext
    return
  end
  local unit = self:GetFightUnit(action.fighterid)
  if unit == nil then
    Debug.LogWarning("[Fight](playnext)action unit not found: ", action.fighterid)
    return
  end
  unit:Reset()
  local actModel = unit.masterModel or unit.model
  table.insert(self.waitForTargets, unit.id)
  local targets = {}
  if action.actionType == PlayType.PLAY_USEITEM then
    for k, v in pairs(action.targetStatus) do
      table.insert(self.waitForTargets, k)
      local target = self:GetFightUnit(k)
      table.insert(targets, target)
    end
    unit:UseItem(action.releaserStatus, targets, action.targetStatus)
    return
  end
  if action.targets == nil or #action.targets == 0 then
    unit:Play(action, nil)
    return
  end
  local invalidTargets = {}
  for i = 1, #action.targets do
    local target = self:GetFightUnit(action.targets[i])
    if target then
      target:Reset()
      local targetActModel = target.masterModel or target.model
      target.attack_result = action.status_map[target.id].attackResultBeans
      target.protect = action.protect_map[target.id]
      target.additionalAttack = action.hitAgain_map[target.id]
      target.influences = action.influenceMap[target.id]
      table.insert(targets, target)
    else
      Debug.LogWarning("[fatal error]target could not be found for id: ", action.targets[i])
      table.insert(invalidTargets, i)
    end
  end
  for i = 1, #invalidTargets do
    table.remove(action.targets, invalidTargets[i])
  end
  if self.nextAction and self.nextAction.actionType == PlayType.PLAY_SKILL then
    local unitsInNextAction = self:GetUnitIdsInNextAction()
    for i = 1, #action.targets do
      if action.targets[i] == unit.id or unitsInNextAction == nil or unitsInNextAction[action.targets[i]] ~= nil then
        table.insert(self.waitForTargets, action.targets[i])
      end
    end
  else
    for i = 1, #action.targets do
      table.insert(self.waitForTargets, action.targets[i])
    end
  end
  self:AddLog(string.format("[FightLog]%s(%d) play action %d, wait for targets: %s", unit.name, unit.id, action.actionType, table.concat(self.waitForTargets, " ")))
  unit:Play(action, targets)
end
def.method("table").SetConsecutiveAttack = function(self, unit)
  if unit == nil or unit.next_target_data == nil then
    return
  end
  local target = self:GetFightUnit(unit.next_target_data.targetid)
  local actModel = unit.masterModel or unit.model
  if target then
    local targetActModel = target.masterModel or target.model
    if target.attack_result == nil then
      target.attack_result = {}
    end
    table.insert(target.attack_result, unit.next_target_data.attackInnerBean)
    table.insert(unit.targets, target)
    unit.curAttackTargets = {target}
    unit.next_target_data = nil
  end
end
def.method("=>", "table").GetNextAction = function(self)
  local cur_round = self:GetRoundData(self.curRound)
  if cur_round == nil or cur_round.playlist == nil or #cur_round.playlist < self.playlist_num then
    self.nextAction = nil
    return nil
  end
  local play = cur_round.playlist[self.playlist_num]
  if play == nil then
    return nil
  end
  self.playlist_num = self.playlist_num + 1
  return FightMgr.Instance():UnmarshalAction(play.play_type, play.content)
end
def.method("=>", "table").GetUnitIdsInNextAction = function(self)
  if self.nextAction == nil or self.nextAction.targets == nil or self.nextAction.actionType ~= PlayType.PLAY_SKILL then
    return nil
  end
  local result = {}
  result[self.nextAction.fighterid] = 0
  for k, v in pairs(self.nextAction.targets) do
    result[v] = k
  end
  return result
end
def.method().OnRoundEnd = function(self)
  if self.record.rounds == nil or #self.record.rounds == self.curRound then
    local pro = self.record.endpro
    if pro then
      Replayer.OnFightEnd(pro)
      return
    end
  end
  for _, v in pairs(self.fightUnits) do
    if v and v.model then
      v:Reset()
    end
  end
  self:GotoNextRound()
end
def.method().CheckResult = function(self)
  if self.isEnding then
    return
  end
  local p = self.record and self.record.endpro
  if p == nil then
    return
  end
  local isWin = p.result == p.RESULT_ACTIVE_WIN
  local effId = constant.CPetBattleConsts.effectWin
  if isWin then
    if instance:IsPetFightCVC() then
      local team = instance.teams[FightConst.ACTIVE_TEAM]
      for k, v in pairs(team.fighters) do
        v:Reset()
        do
          local m = v
          if m.model then
            do
              local function OnPlayEnd()
                if m.model == nil then
                  return
                end
                m.model:PlayAnim(ActionName.Magic, OnPlayEnd)
              end
              OnPlayEnd()
            end
          end
        end
      end
      team = instance.teams[FightConst.PASSIVE_TEAM]
      for k, v in pairs(team.fighters) do
        v:Reset()
        v.model:PlayAnim(ActionName.Death1, nil)
      end
    end
  else
    local team = instance.teams[FightConst.PASSIVE_TEAM]
    for k, v in pairs(team.fighters) do
      v:Reset()
      do
        local m = v
        if m.model then
          do
            local function OnPlayEnd()
              if m.model == nil then
                return
              end
              m.model:PlayAnim(ActionName.Magic, OnPlayEnd)
            end
            OnPlayEnd()
          end
        end
      end
    end
    team = instance.teams[FightConst.ACTIVE_TEAM]
    for k, v in pairs(team.fighters) do
      v:Reset()
      v.model:PlayAnim(ActionName.Death1, nil)
    end
    effId = constant.CPetBattleConsts.effectFail
  end
  local effdata = _G.GetEffectRes(effId)
  require("Fx.GUIFxMan").Instance():Play(effdata.path, "", 0, 0, 2, false)
  self.isEnding = true
  GameUtil.AddGlobalTimer(constant.CPetBattleConsts.effectEndCostTime / 1000, true, function()
    Replayer.DoFightEnd(p)
  end)
end
def.static("table").OnFightEnd = function(p)
  local end_pro = p
  if end_pro and instance.fightType == FIGHT_TYPE.TYPE_PETCVC then
    instance:CheckResult()
  else
    Replayer.DoFightEnd(end_pro)
  end
end
def.static("table").DoFightEnd = function(p)
  if instance.fightInstanceId == nil or p and p.fight_uuid and not instance.fightInstanceId:eq(p.fight_uuid) then
    return
  end
  local fight_sub_type = instance.sceneInfo and instance.sceneInfo.battleType or -1
  instance:Reset()
  instance:DestroyPetFightCells()
  instance.ui:Hide()
  if instance.fightCam then
    instance.fightCam:SetActive(false)
  end
  if instance.isFlyBattle then
    instance:SetToGroundMode()
    instance.isFlyBattle = false
  end
  local game = ECGame.Instance()
  mainCam = game.m_Main3DCam
  game.m_2DWorldCamObj:SetActive(true)
  mainCam:SetActive(true)
  instance.damageRoot:SetActive(false)
  ECSoundMan.Instance():StopBackgroundMusic(1)
  local cam = mainCam:GetComponent("Camera")
  CommonCamera.game3DCamera = cam
  game.m_isInFight = FightMgr.Instance().isInFight
  instance.record = nil
  if instance.fightType == FIGHT_TYPE.TYPE_PETCVC then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_PET_BATTLE, nil)
  end
  if not FightMgr.Instance().isInFight then
    FxCacheMan.Instance.gameObject.localPosition = EC.Vector3.zero
    cam:set_cullingMask(get_cull_mask(ClientDef_Layer.Player) + get_cull_mask(ClientDef_Layer.NPC))
    local worldCamHeight = game.m_2DWorldCamObj:GetComponent("Camera").orthographicSize
    cam.orthographicSize = worldCamHeight * cam_2d_to_3d_scale
    GUIMan.Instance().m_hudCameraGo2:SetActive(false)
    GUIMan.Instance().m_camera.clearFlags = CameraClearFlags.Depth
    GUIMan.Instance().m_hudCamera.clearFlags = CameraClearFlags.Nothing
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, {
      FightType = instance.fightType,
      Result = true,
      IsDead = false,
      Fight_SubType = fight_sub_type
    })
    Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.ENABLE_MUSIC, {true, false})
    if instance.fightDamageCam then
      instance.fightDamageCam:SetActive(false)
    end
  else
    FightMgr.Instance():ResetFightView()
  end
  game:SyncGC()
end
def.method().Reset = function(self)
  self.isInFight = false
  self.isEnding = false
  require("Main.Fight.ui.DlgPrelude").Instance():Hide()
  self.nextAction = nil
  self.waitForTargets = nil
  self.cameraParam = nil
  self.isInUpdate = false
  self.countDown = -1
  self.myTeam = -1
  self:RemoveJoinTimer()
  if tipResume then
    tipResume:HideDlg()
    tipResume = nil
  end
  if self.playController then
    self.playController:Reset()
  end
  Timer:RemoveIrregularTimeListener(Replayer.Update)
  FightMgr.Instance().soundEnable = true
  self.shakeParam = nil
  instance.actionMap = nil
  instance.sceneInfo = nil
  self.followTarget = nil
  if instance.isPerspective then
    instance:StopPerspective()
  end
  mainCam.parent = instance.fightPlayerNodeRoot
  self:RemoveAllUnits()
  if self.formationIcons then
    for k, v in pairs(self.formationIcons) do
      v:Destroy()
      self.formationIcons[k] = nil
    end
    self.formationIcons = nil
  end
  if instance.bgMask then
    instance.bgMask:Destroy()
  end
  instance.bgMask = nil
  if instance.fight_bg then
    instance.fight_bg:Destroy()
  end
  instance.fight_bg = nil
  if instance.fight3DScene then
    instance.fight3DScene:Destroy()
    instance.fight3DScene = nil
  end
  instance.curRound = 0
  instance.rounds = nil
  instance.fightInstanceId = nil
  ECFxMan.Instance():ResetLODLevel()
  HUDFollowTarget.gameCamera = ECGame.Instance().m_Main3DCamComponent
  ECPateTextComponent.gameCamera = ECGame.Instance().m_Main3DCamComponent
  mainCam:Destroy()
end
def.method().DestroyPetFightCells = function(self)
  if self.petFightCells then
    for _, v in pairs(self.petFightCells) do
      v:Destroy()
    end
    self.petFightCells = nil
  end
  if self.petCellCam then
    self.petCellCam:Destroy()
    self.petCellCam = nil
  end
end
def.method().RemoveAllUnits = function(self)
  if self.tobeAdded then
    for k, v in pairs(self.tobeAdded) do
      v:Destroy()
    end
    self.tobeAdded = nil
  end
  if self.tobeDeleted then
    for k, v in pairs(self.tobeDeleted) do
      self.fightUnits[k] = nil
    end
    self.tobeDeleted = nil
  end
  if self.fightUnits then
    for k, v in pairs(self.fightUnits) do
      if v and v.model then
        v:Destroy()
      end
      self.fightUnits[k] = nil
    end
    self.fightUnits = nil
  end
  self.groups = nil
  self.teams = nil
end
def.method("table", "number").CreateFightTeam = function(self, teamData, teamid)
  local team = self.teams[teamid]
  if team == nil then
    team = FightTeam.new()
    team.teamId = teamid
    self.teams[teamid] = team
  end
  team.formation = teamData.zhenFaid
  team.formationLevel = teamData.zhenFaLevel
  if self.fightType ~= FIGHT_TYPE.TYPE_PETCVC then
    local formationCfg = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfoAtLevel(team.formation, team.formationLevel)
    if formationCfg then
      local resPath = GetIconPath(formationCfg.backIcon)
      if resPath then
        self:LoadFormationIcon(resPath, team.teamId)
      else
        Debug.LogWarning("fight formation get nil record for id: ", formationCfg.backIcon)
      end
    end
  end
  local i = 1
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  for i, g in pairs(teamData.groups) do
    local group = {}
    group.roleId = g.roleid
    if self.fightType == FIGHT_TYPE.TYPE_PETCVC and g.roleid:eq(myId) then
      self.myTeam = teamid
    end
    self.groups[i] = group
    for k, v in pairs(g.fighters) do
      self:RemoveFightUnit(k)
      self:CreateFighter(k, v, team.teamId, i)
    end
  end
end
def.method("number", "table", "number", "number", "=>", FightUnit).CreateFighter = function(self, id, fighter, teamId, groupId)
  local teamPos = self.fightPos[teamId].Pos
  local group = self.groups[groupId]
  if group == nil then
    group = {}
    self.groups[groupId] = group
  end
  local unit = self:CreateFightUnit(id, fighter, teamId)
  unit.model:SetHpVisible(true)
  self.teams[teamId]:AddFightUnit(unit)
  if fighter.fighter_type == GameUnitType.ROLE then
    unit.roleId = group.roleId
    group.role = unit
  elseif fighter.fighter_type == GameUnitType.PET or fighter.fighter_type == GameUnitType.CHILDREN then
    unit.roleId = fighter.uuid
    unit.cfgId = fighter.cfgid
    group.pet = unit
  elseif fighter.fighter_type == GameUnitType.FELLOW then
    unit.roleId = fighter.uuid
  elseif fighter.fighter_type == GameUnitType.MONSTER then
    unit.cfgId = fighter.cfgid
  end
  group[unit.id] = unit
  unit.group = groupId
  if self.isFlyBattle then
    unit.flyMount = FlyMount.new()
    if unit.model.m_model then
      self:LoadUnitFlyMount(unit)
    end
  end
  return unit
end
def.method("number", "table", "number", "=>", FightUnit).CreateFightUnit = function(self, fighterId, fighterInfo, team)
  local color
  if fighterInfo.fighter_type == GameUnitType.ROLE then
    color = GetColorData(701300000)
  elseif fighterInfo.fighter_type == GameUnitType.PET then
    color = GetColorData(701300002)
  elseif fighterInfo.fighter_type == GameUnitType.CHILDREN then
    color = GetColorData(701300002)
    local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
    local child_model_cfg = require("Main.Children.ChildrenUtils").GetChildrenCfgById(fighterInfo.model.extraMap[ModelInfo.CHILDREN_MODEL_ID])
    fighterInfo.model.modelid = child_model_cfg.modelId
  elseif fighterInfo.fighter_type == GameUnitType.FELLOW then
    color = GetColorData(701300011)
  else
    color = GetColorData(701300004)
  end
  local unit = FightUnit.Create(fighterId, team, fighterInfo.pos + 1, fighterInfo.model, fighterInfo.name, color, fighterInfo.fighter_type, self)
  unit.level = fighterInfo.level
  unit.menpai = fighterInfo.occupation
  unit.initMenpai = fighterInfo.occupation
  unit.status = fighterInfo.status
  unit.roleId = fighterInfo.uuid
  unit:SetHp(fighterInfo.status.curHp, fighterInfo.status.hpMax)
  unit:SetMp(fighterInfo.status.curMp, fighterInfo.status.mpMax)
  unit:SetRage(fighterInfo.status.curAnger, fighterInfo.status.angerMax)
  unit.gender = fighterInfo.gender
  unit.initGender = fighterInfo.gender
  unit.skillUsedData = fighterInfo.skillDatas
  local isDead = unit:CheckFightStatus(FighterStatus.STATUS_FAKE_DEAD)
  if isDead then
    unit:SetFakeDeath()
  end
  unit.model:SetStance()
  if self.isInUpdate then
    if self.tobeAdded == nil then
      self.tobeAdded = {}
    end
    self.tobeAdded[fighterId] = unit
  else
    self.fightUnits[fighterId] = unit
  end
  if unit.model:IsLoaded() then
    Replayer.OnModelLoaded({
      id = fighterId,
      model = unit.model
    }, nil)
  end
  return unit
end
def.static("table", "table").OnLongTouchTarget = function(p1, p2)
  if p1 == nil then
    return
  end
  local unitId = p1[1]
  if unitId == nil then
    return
  end
  local unit = instance:GetFightUnit(unitId)
  if unit == nil then
    return
  end
  local model = p1 and p1[2]
  if unit.model ~= model then
    return
  end
  local buffdlg = require("Main.Fight.ui.DlgFightBuff").Instance()
  if buffdlg.unitId == unitId then
    return
  end
  buffdlg:ShowDlg(p1[1], instance)
end
def.method("table").OnActionEnd = function(self, p1)
  local unit_id = p1[1]
  local unit = instance:GetFightUnit(unit_id)
  local unit = instance:GetFightUnit(unit_id)
  local islast = p1 and p1[2]
  if unit and unit.model and islast then
    unit:ClearFightData()
  end
  if instance.waitForTargets and #instance.waitForTargets > 0 then
    if unit then
      instance:AddLog(string.format("[FightLog]%s(%d) has finished action", unit.name, unit.id))
    end
    local idx = table.indexof(instance.waitForTargets, unit_id)
    if not idx then
      return
    end
    table.remove(instance.waitForTargets, idx)
    instance:AddLog(string.format("[FightLog]wait targets left: %d", #instance.waitForTargets))
    if #instance.waitForTargets > 0 then
      return
    end
    instance:GoNext()
  end
end
def.method().GoNext = function(self)
  if self.nextAction == nil then
    self:OnRoundEnd()
    return
  end
  self.nextPlay = Replayer.PlayNext
end
def.method("=>", FightUnit).GetCurrentControllable = function(self)
  return nil
end
def.method("number").RemoveControllableUnit = function(self, id)
end
def.method("number", "=>", "table").GetOpponentTeam = function(self, teamId)
  for k, v in pairs(self.teams) do
    if k ~= teamId then
      return v
    end
  end
  return nil
end
def.method("number", "=>", "table").GetTeam = function(self, teamId)
  return self.teams[teamId]
end
def.method("number", "=>", FightUnit).GetFightUnit = function(self, id)
  local unit = self.fightUnits and self.fightUnits[id]
  if unit == nil or unit.model == nil then
    return nil
  end
  return unit
end
def.method("number").RemoveFightUnit = function(self, id)
  if self.fightUnits == nil then
    return
  end
  local unit = self.fightUnits[id]
  if unit then
    local team = self:GetTeam(unit.team)
    team:RemoveMember(unit.id)
    local group = self.groups[unit.group]
    if group then
      if group.role == unit then
        group.role = nil
      end
      if group.pet == unit then
        group.pet = nil
      end
      group[unit.id] = nil
    end
    unit:Destroy()
    if self.isInUpdate then
      if self.tobeDeleted == nil then
        self.tobeDeleted = {}
      end
      self.tobeDeleted[id] = unit
    else
      self.fightUnits[id] = nil
    end
  end
end
def.method("number").Update = function(self, tick)
  tick = tick * Time.timeScale
  if self.isInFight == false then
    return
  end
  self:UpdateCamera(tick)
  self:UpdateShake(tick)
  if self.playController then
    self.playController:Update(tick)
  end
  if self.loadModelTime > 0 then
    self.loadModelTime = self.loadModelTime - tick
    if self.loadModelTime <= 0 then
      if self.hasLoaded and 0 < #self.hasLoaded then
        Debug.LogWarning("[Fight warning]Model loading is time up")
        for unit_id, _ in pairs(self.fightUnits) do
          local idx = table.indexof(instance.hasLoaded, unit_id)
          if not idx then
            Debug.LogWarning("unit is not loaded: ", unit_id)
          end
        end
      end
      self.hasLoaded = nil
      self.loadModelTime = -1
    end
  end
  if 0 <= self.countDown and not self.paused then
    self.countDown = self.countDown - tick
    if 0 >= self.countDown then
      if self:PlayNextRound() then
        self.countDown = -1
      else
        self.countDown = 0
      end
    end
  end
  self.isInUpdate = true
  for k, v in pairs(self.fightUnits) do
    if v and v.model then
      v:Update(tick)
    end
  end
  self.isInUpdate = false
  if self.tobeAdded then
    for k, v in pairs(self.tobeAdded) do
      self.fightUnits[k] = v
    end
    self.tobeAdded = nil
  end
  if self.tobeDeleted then
    for k, v in pairs(self.tobeDeleted) do
      self.fightUnits[k] = nil
      self.tobeDeleted[k] = nil
    end
  end
  if self.isInFight and self.nextPlay and not self.paused then
    local nextplay = self.nextPlay
    self.nextPlay = nil
    nextplay(self)
  end
end
def.static("table", "table").OnModelLoaded = function(p1, p2)
  if not instance.isInFight then
    return
  end
  local unit_id = p1 and p1.id
  if unit_id == nil then
    return
  end
  local unit = not instance.fightUnits[unit_id] and instance.tobeAdded and instance.tobeAdded[unit_id]
  if unit == nil then
    return
  end
  local model = p1 and p1.model
  if model ~= unit.model then
    return
  end
  if instance.hasLoaded then
    local idx = table.indexof(instance.hasLoaded, unit_id)
    if not idx then
      table.insert(instance.hasLoaded, unit_id)
    end
  end
  unit:ShowStatus(unit.status)
  unit:CheckAbnormalStatus()
  if unit.showSelect then
    unit:ShowSelect()
  else
    unit:HideSelect()
  end
  instance:LoadUnitFlyMount(unit)
end
def.method(FightUnit).LoadUnitFlyMount = function(self, unit)
  if unit.flyMount and not unit.flyMount:IsLoaded() and not unit.flyMount:IsInLoading() then
    local tw = unit.model.m_model:AddComponent("FlyFightTweener")
    tw:Init(math.random() * 2)
    unit.flyMount:SetParent(unit.model.m_model)
    local respath, isChangeModel
    if unit.fightUnitType == GameUnitType.ROLE then
      local flymountItemId = unit.model:GetFeijianId()
      if flymountItemId > 0 then
        local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(flymountItemId)
        if feijianCfg then
          isChangeModel = FightUtils.IsChangeModelFlyMount(feijianCfg.feijianType)
          respath = feijianCfg.modelPath
          if feijianCfg.effectPath then
            unit.flyMount:AddEffect(feijianCfg.effectPath)
          end
        end
      end
    elseif unit.fightUnitType == GameUnitType.PET or unit.fightUnitType == GameUnitType.CHILDREN then
      respath, isChangeModel = FightUtils.GetFlyMountModelPath(constant.FightConst.PET_FLYER_ID)
    elseif unit.fightUnitType == GameUnitType.FELLOW then
      local group = self.groups[unit.group]
      local flymountItemId = group.role and group.role.model:GetFeijianId() or 0
      if flymountItemId > 0 then
        local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(flymountItemId)
        if feijianCfg then
          isChangeModel = FightUtils.IsChangeModelFlyMount(feijianCfg.feijianType)
          respath = feijianCfg.modelPath
          if feijianCfg.effectPath then
            unit.flyMount:AddEffect(feijianCfg.effectPath)
          end
        end
      end
    else
      local moncfg = PetInterface.GetMonsterCfg(unit.cfgId)
      if moncfg then
        local appearance = NPCInterface.GetNpcFigureCfg(moncfg.modelFigureId)
        if appearance then
          respath, isChangeModel = FightUtils.GetFlyMountModelPath(appearance.flyMountId)
        end
      end
    end
    if respath == nil or respath == "" or isChangeModel then
      respath = GetModelPath(700305100)
    end
    unit.flyMount:Load(respath)
  end
end
def.method().WaitForNewCreatedUnits = function(self)
  self.hasLoaded = {}
  for k, v in pairs(self.fightUnits) do
    if v and v.model then
      table.insert(self.hasLoaded, k)
    end
  end
end
def.method("number").RemoveWaitUnit = function(self, unitid)
  if self.hasLoaded then
    local idx = table.indexof(self.hasLoaded, unitid)
    if idx then
      table.remove(self.hasLoaded, idx)
    end
  end
end
def.method("number").AddTargetToBeWaited = function(self, unitid)
  if self.waitForTargets == nil then
    self.waitForTargets = {}
  end
  table.insert(self.waitForTargets, unitid)
end
def.method("number", "=>", "boolean").CheckTargetIsWaited = function(self, unitid)
  if self.waitForTargets == nil then
    return false
  end
  for i = 1, #self.waitForTargets do
    if unitid == self.waitForTargets[i] then
      return true
    end
  end
  return false
end
def.method("string").AddLog = function(self, content)
  if self.showLog then
    Debug.LogWarning(content)
  end
end
def.static("table").OnSFighterOnlineBrd = function(p)
  local unit = instance:GetFightUnit(p.fighterid)
  if unit then
    if p.status == p.class.OFFLINE then
      unit.online = false
    elseif p.status == p.class.ONLINE then
      unit.online = true
    end
    unit:RemoveTitleIcon()
  end
end
def.method("table", "=>", "string").GetBgMusic = function(self, bgMusicList)
  if bgMusicList == nil or #bgMusicList == 0 then
    return ""
  end
  local idx = 1
  if #bgMusicList > 1 then
    idx = math.random(#bgMusicList)
  end
  return SoundData.Instance():GetSoundPath(bgMusicList[idx])
end
def.method("table", "=>", "number").GetBgPic = function(self, srcList)
  if srcList == nil or #srcList == 0 then
    return 0
  end
  local idx = 1
  if #srcList > 1 and self.fightInstanceId then
    local randomer = require("Common.ServerRandomGenerator").make_srg(self.fightInstanceId:ToNumber())
    idx = randomer("int", #srcList)
  end
  local bgId = srcList[idx]
  return bgId or 0
end
local init_2d_orthographicSize = 0
def.method("number", "number").SetShakeParam = function(self, id, delay)
  if init_2d_orthographicSize == 0 then
    init_2d_orthographicSize = self.fightCam and self.fightCam:GetComponent("Camera").orthographicSize
  end
  self.shakeParam = FightUtils.GetShakeCfg(id)
  if self.shakeParam then
    self.shakeParam.init_2d_orthographicSize = init_2d_orthographicSize
    self.shakeParam.delay = delay
  end
end
local shake_rect = require("Types.Rect").Rect.new(0, 0, 1, 1)
def.method("number").UpdateShake = function(self, tick)
  if self.shakeParam == nil then
    return
  end
  if self.shakeParam.delay and self.shakeParam.delay > 0 then
    self.shakeParam.delay = self.shakeParam.delay - tick
    return
  end
  if 0 < self.shakeParam.duration then
    self.shakeParam.duration = self.shakeParam.duration - tick
    local game = ECGame.Instance()
    local h = game.m_2DWorldCam.orthographicSize
    local w = h * 2 * game.m_2DWorldCam.aspect
    local cam = mainCam:GetComponent("Camera")
    local a = self.shakeParam.amplitude * (2 - math.random(3)) * 0.5
    shake_rect.x = a
    shake_rect.y = a
    cam.rect = shake_rect
    local random_size = math.random(8) - 8
    local map2dcam = game.m_2DWorldCamObj:GetComponent("Camera")
    map2dcam.orthographicSize = self.shakeParam.init_2d_orthographicSize + random_size
    local fightCam = self.fightCam and self.fightCam:GetComponent("Camera")
    if fightCam then
      fightCam.orthographicSize = self.shakeParam.init_2d_orthographicSize + random_size
    end
    if 0 >= self.shakeParam.duration then
      map2dcam.orthographicSize = self.shakeParam.init_2d_orthographicSize
      if fightCam then
        fightCam.orthographicSize = self.shakeParam.init_2d_orthographicSize
      end
      shake_rect.x = 0
      shake_rect.y = 0
      cam.rect = shake_rect
      self.shakeParam = nil
    end
  end
end
local tempRotation = EC.Vector3.new(0, 0, 0)
local tempPos = EC.Vector3.new(0, 0, 0)
def.method(FightUnit, "number").CameraCloseUpToTarget = function(self, unit, cfgid)
  local model = unit.model.m_model
  if model == nil then
    return
  end
  if self.isPerspective then
    return
  end
  local cameraCfg = FightUtils.GetCameraCfg(cfgid)
  if cameraCfg == nil then
    return
  end
  if not self:CheckCameraVisible(unit, cameraCfg.visiableType) then
    return
  end
  self.isPerspective = true
  if cameraCfg.cameraAnimId and cameraCfg.cameraAnimId > 0 then
    local aniPath = GetModelPath(cameraCfg.cameraAnimId)
    if aniPath == nil or aniPath == "" then
      return
    end
    local function SetCameraAnim(anim)
      if anim == nil then
        return
      end
      if not self.isPerspective then
        return
      end
      local ani = mainCam:AddComponent("Animation")
      local clip = Object.Instantiate(anim, "GameObject")
      ani:AddClip(clip, "skill")
      ani.clip = clip
      ani:Play_3("skill", PlayMode.StopSameLayer)
      mainCam.parent = unit.model.m_model
      local state = ani:State("skill")
      local duration = state and state.length
      if duration then
        GameUtil.AddGlobalTimer(duration, true, function()
          self:StopCloseUpCamera()
        end)
      end
    end
    GameUtil.AsyncLoad(aniPath, SetCameraAnim)
  else
    self.followTarget = unit
    if 0 < cameraCfg.skillNameEff then
      Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SHOW_UI_EFFECT, {
        cameraCfg.skillNameEff
      })
    end
    self.cameraParam = {}
    self.cameraParam.height = cameraCfg.initHeight
    self.cameraParam.distance = cameraCfg.initDistance
    self.cameraParam.Y_angle = cameraCfg.initYangle
    self.cameraParam.X_angle = model.transform.eulerAngles.y + cameraCfg.initXangle
    self.cameraParam.time = 0
    self.cameraParam.phases = cameraCfg.phases
    tempRotation.x = self.cameraParam.Y_angle
    tempRotation.y = 180 + self.cameraParam.X_angle
    mainCam.transform.rotation = Quaternion.Euler(tempRotation)
    tempPos.x = self.cameraParam.distance * math.sin(math.pi * self.cameraParam.X_angle / 180)
    tempPos.y = self.cameraParam.height
    tempPos.z = self.cameraParam.distance * math.cos(math.pi * self.cameraParam.X_angle / 180)
    mainCam.transform.position = model.transform.position + tempPos
  end
  if not self.is3dScene and self.fight3DScene then
    self.fight3DScene:SetActive(true)
    local cam = mainCam:GetComponent("Camera")
    cam:set_orthographic(false)
    cam.nearClipPlane = 0.01
    if self.fightCam then
      self.fightCam:SetActive(false)
    end
    ECGame.Instance().m_2DWorldCamObj:SetActive(false)
    gmodule.moduleMgr:GetModule(ModuleId.MAP).mapNodeRoot:SetActive(false)
  else
    self.isPerspective = false
  end
end
def.method("number").UpdateCamera = function(self, tick)
  if self.cameraParam == nil then
    return
  end
  if self.followTarget == nil then
    return
  end
  local model = self.followTarget.model.m_model
  if model == nil then
    return
  end
  local phase = self.cameraParam.phases[1]
  if phase then
    self.cameraParam.time = self.cameraParam.time + tick
    if self.cameraParam.time > phase.duration then
      self.cameraParam.time = phase.duration
    end
    local x_angle = self.cameraParam.X_angle + self.cameraParam.time * phase.XangleDelta / phase.duration
    local y_angle = self.cameraParam.Y_angle + self.cameraParam.time * phase.YangleDelta / phase.duration
    local dist = self.cameraParam.distance + self.cameraParam.time * phase.deltaX / phase.duration
    local height = self.cameraParam.height + self.cameraParam.time * phase.deltaY / phase.duration
    tempRotation.x = y_angle
    tempRotation.y = 180 + x_angle
    mainCam.transform.rotation = Quaternion.Euler(tempRotation)
    tempPos.x = dist * math.sin(math.pi * x_angle / 180)
    tempPos.y = height
    tempPos.z = dist * math.cos(math.pi * x_angle / 180)
    mainCam.transform.position = model.transform.position + tempPos
    if self.cameraParam.time >= phase.duration then
      self.cameraParam.distance = dist
      self.cameraParam.height = height
      self.cameraParam.X_angle = x_angle
      self.cameraParam.Y_angle = y_angle
      self.cameraParam.time = 0
      table.remove(self.cameraParam.phases, 1)
    end
  else
    self:StopCloseUpCamera()
  end
end
def.method().StopCloseUpCamera = function(self)
  if self.isPerspective == false then
    return
  end
  self.cameraParam = nil
  self.followTarget = nil
  if self.fight3DScene then
    self.fight3DScene:SetActive(false)
  end
  mainCam.parent = instance.fightPlayerNodeRoot
  if self.is3dScene then
    mainCam.localPosition = self.cam3dParam.pos
    mainCam.localRotation = self.cam3dParam.dir
  else
    self:StopPerspective()
  end
end
def.method().StopPerspective = function(self)
  local ani = mainCam:GetComponent("Animation")
  Object.Destroy(ani)
  mainCam.rotation = Quaternion.Euler(EC.Vector3.new(cam_3d_degree, 0, 0))
  local pos3d = Map2DPosTo3D(0, 0)
  mainCam.localPosition = pos3d - mainCam.forward * 15
  local cam = mainCam:GetComponent("Camera")
  cam:set_orthographic(true)
  cam.nearClipPlane = -200
  if not FightMgr.Instance().isPerspective then
    ECGame.Instance().m_2DWorldCamObj:SetActive(true)
    gmodule.moduleMgr:GetModule(ModuleId.MAP).mapNodeRoot:SetActive(true)
  end
  if self.fightCam then
    self.fightCam:SetActive(true)
  end
  self.isPerspective = false
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  if instance.isInFight then
    instance:DestroyPetFightCells()
    instance:Reset()
    local game = ECGame.Instance()
    game.m_isInFight = false
    instance.ui:Hide()
    if instance.fightCam then
      instance.fightCam:SetActive(false)
    end
    if instance.isFlyBattle then
      instance:SetToGroundMode()
    end
    instance.isFlyBattle = false
    mainCam = game.m_Main3DCam
    game.m_2DWorldCamObj:SetActive(true)
    mainCam:SetActive(true)
    local cam = mainCam:GetComponent("Camera")
    CommonCamera.game3DCamera = cam
    FxCacheMan.Instance.gameObject.localPosition = EC.Vector3.zero
    cam:set_cullingMask(get_cull_mask(ClientDef_Layer.Player) + get_cull_mask(ClientDef_Layer.NPC))
    local worldCamHeight = game.m_2DWorldCamObj:GetComponent("Camera").orthographicSize
    cam.orthographicSize = worldCamHeight * cam_2d_to_3d_scale
    GUIMan.Instance().m_hudCameraGo2:SetActive(false)
    GUIMan.Instance().m_camera.clearFlags = CameraClearFlags.Depth
    GUIMan.Instance().m_hudCamera.clearFlags = CameraClearFlags.Nothing
    game:SyncGC()
  end
  instance.record = nil
end
def.method("number", "=>", "boolean").IsMyUnit = function(self, fighterId)
  return false
end
def.method("number", "=>", "boolean").IsMyHero = function(self, fighterId)
  return false
end
def.method("=>", "boolean").IsObserverMode = function(self)
  return true
end
def.method(FightUnit, "=>", "boolean").IsSpectator = function(self, unit)
  return false
end
def.method("=>", "boolean").IsLastRound = function(self)
  local ret = self.record.rounds ~= nil and self.curRound == #self.record.rounds
  if not ret then
    return ret
  end
  local round = self:GetRoundData(self.curRound)
  return round ~= nil and round.playlist ~= nil and #round.playlist <= self.playlist_num
end
def.method("number", "number", "=>", "number", "number", "number").GetFightUnitByPos = function(self, team, pos)
  local unit
  for k, v in pairs(self.fightUnits) do
    if v and v.model and v.pos == pos and v.team == team then
      unit = v
      break
    end
  end
  if unit == nil then
    return -1, 0, 0
  end
  local pos = self.fightPos[unit.team].Pos[unit.pos]
  return unit.id, pos.x / FightMgr.FIGHT_SCENE_SCALE, pos.y / FightMgr.FIGHT_SCENE_SCALE
end
def.method("userdata", "=>", FightUnit).GetFightUnitByRoleId = function(self, roleId)
  local unit
  if self.fightUnits then
    for k, v in pairs(self.fightUnits) do
      if v and v.model and v.roleId and v.roleId:eq(roleId) then
        unit = v
        break
      end
    end
  end
  return unit
end
def.method("=>", "number").GetCurrentRoundNum = function(self)
  return self.curRound
end
def.method(FightUnit, "number", "=>", "boolean").CheckCameraVisible = function(self, unit, vt)
  return true
end
def.method("table").SetWorldBossInfo = function(self, info)
  local unitmap = {}
  self.actionMap = {}
  for _, v in pairs(info.actionRefs) do
    unitmap[v.pos] = v.refPos
    local content = self.actionMap[v.pos]
    if content == nil then
      content = {}
      self.actionMap[v.pos] = content
      content.pos = v.refPos
    end
    content[v.actionName] = v.refActionName
  end
  for k, v in pairs(unitmap) do
    local unitId = self:GetFightUnitByPos(FightConst.LEFT_TOP, k)
    local unit = self:GetFightUnit(unitId)
    if unit then
      local masterId = self:GetFightUnitByPos(FightConst.LEFT_TOP, v)
      local master = self:GetFightUnit(masterId)
      if master then
        unit.masterModel = master.model
        master.isHugeUnit = true
      else
        Debug.LogWarning(string.format("[Fight](set world boss mapping) master is nil for unitId(%d), fight_pos(%d)", masterId, v))
      end
    else
      Debug.LogWarning(string.format("[Fight](set world boss mapping) unit is nil for unitId(%d), fight_pos(%d)", unitId, k))
    end
  end
end
def.method("number", "string", "=>", "string").GetMasterActionName = function(self, pos, actionName)
  if self.actionMap == nil then
    return ""
  end
  local content = self.actionMap[pos]
  local masterActionName
  if content then
    masterActionName = content[actionName]
  end
  if masterActionName == nil then
    Debug.LogWarning(string.format("[Fight]master ActionName is nil: (%d %s)", pos, actionName))
    masterActionName = actionName
  end
  return masterActionName
end
def.static("table", "table").OnPauseGame = function()
  warn("game paused")
end
def.static("table", "table").OnResumeGame = function()
  warn("game resumed")
end
def.method().SetToSkyMode = function(self)
  local game = ECGame.Instance()
  game:_ResetSkyLayer()
  mainCam:GetComponent("Camera").orthographicSize = game.m_scale3d
  if game.m_cloudCam then
    local cam = game.m_cloudCam:GetComponent("Camera")
    cam.depth = CameraDepth.CLOUD_DOWN
  end
  FlyModule.Instance():FlowCloud(0, "fight")
  if instance.fightCam then
    local cam = instance.fightCam:GetComponent("Camera")
    cam.depth = CameraDepth.SKY_BATTLE_MAP
  end
  GUIMan.Instance().m_hudCamera.clearFlags = CameraClearFlags.Depth
end
def.method().SetToGroundMode = function(self)
  local game = ECGame.Instance()
  game:_ResetGroundLayer()
  if game.m_cloudCam then
    local cam = game.m_cloudCam:GetComponent("Camera")
    cam.depth = CameraDepth.CLOUD_UP
  end
  FlyModule.Instance():StopCloud("fight")
  if instance.fightCam then
    local cam = instance.fightCam:GetComponent("Camera")
    cam.depth = CameraDepth.BATTLEMAP
  end
end
def.method(FightModel).LoadSpectatorFlyMount = function(self, spectator)
  local function LoadFlyMount()
    local tw = spectator.m_model:AddComponent("FlyFightTweener")
    tw:Init(math.random() * 2)
    spectator.flyMount:SetParent(spectator.m_model)
    local respath
    local flymountId = spectator:GetFeijianId()
    if flymountId > 0 then
      respath = FightUtils.GetFlyMountModelPath(flymountId)
    end
    if respath == nil or respath == "" then
      respath = GetModelPath(700305100)
    end
    spectator.flyMount:Load(respath)
  end
  if spectator:IsInLoading() then
    spectator:AddOnLoadCallback("FightFlyMount", LoadFlyMount)
  else
    LoadFlyMount()
  end
end
def.method("number", "=>", "table").GetSkillCfg = function(self, id)
  return FightMgr.Instance():GetSkillCfg(id)
end
def.method("string", "userdata", "table", "userdata", "=>", "userdata").PlayEffect = function(self, resName, parent, localpos, localrot)
  if parent == nil then
    localpos = localpos + BattleFieldPos - FxCacheMan.Instance.gameObject.localPosition
  end
  return FightMgr.Instance():DoPlayEffect(resName, parent, localpos, localrot)
end
def.method("string", "table", "dynamic", "function", "number", "number", "number").PlayMovingEffect = function(self, resName, pos, dest, cb, speed, duration, tolerance)
  pos = pos + BattleFieldPos
  dest = dest + BattleFieldPos
  FightMgr.Instance():DoPlayMovingEffect(resName, pos, dest, cb, speed, duration, tolerance)
end
def.method("=>", FightUnit).GetMyHero = function(self)
  return nil
end
def.method("=>", "table").GetMyPet = function(self)
  return {}
end
def.method("=>", "userdata").GetDamageTemplate = function(self)
  return FightMgr.Instance().damageTemplate
end
def.method("=>", "table").GetFonts = function(self)
  return FightMgr.Instance():GetFonts()
end
def.method("number").PlaySoundEffect = function(self, soundid)
  FightMgr.Instance():DoPlaySoundEffect(soundid)
end
def.method("string").LoadEffectRes = function(self, respath)
  FightMgr.Instance():LoadEffectRes(respath)
end
def.method().SkipToNextRound = function(self)
  if self.record == nil or self.record.rounds == nil then
    return
  end
  if self.curRound == #self.record.rounds then
    Toast(textRes.Fight[81])
    return
  end
  self:SkipToRound(self.curRound + 1)
end
def.method().SkipToPrevRound = function(self)
  if self.record == nil or self.record.rounds == nil then
    return
  end
  if self.curRound == 1 then
    Toast(textRes.Fight[80])
    return
  end
  self:SkipToRound(self.curRound - 1)
end
def.method("number", "=>", "boolean").SkipToRound = function(self, num)
  if not self:_SkipToRoundEnd(num - 1) then
    return false
  end
  self.curRound = num
  self.ui:NextRound()
  local p = self.record.rounds[self.curRound]
  if p then
    if self.fightInstanceId == nil or not self.fightInstanceId:eq(p.fight_uuid) then
      return false
    end
    local round = {
      round_num = self.curRound,
      cmd_time = constant.FightConst.WAIT_CMD_TIME
    }
    round.playlist = p.playlist
    table.insert(instance.rounds, round)
  end
  self.nextAction = nil
  self.countDown = 3
  return true
end
def.method("number", "=>", "boolean").SkipToRoundEnd = function(self, num)
  if not self:_SkipToRoundEnd(num) then
    return false
  end
  self.curRound = num + 1
  self.ui:NextRound()
  self.nextAction = nil
  self.countDown = 3
  return true
end
def.method("number", "=>", "boolean")._SkipToRoundEnd = function(self, num)
  if self.record == nil or self.record.rounds == nil then
    return false
  end
  if num < 0 or num > #self.record.rounds then
    return false
  end
  local fightdata = self.record.startpro.fight
  if fightdata then
    if self.isInFight then
      self:Reset()
    end
    Replayer.OnSEnterFight(self.record.startpro, false)
  end
  if num >= 1 then
    local last_play_status
    for i = 1, num do
      last_play_status = nil
      local rounddata = self.record.rounds[i]
      for _, play in pairs(rounddata.playlist) do
        local action = FightMgr.Instance():UnmarshalAction(play.play_type, play.content)
        if play.play_type == PlayType.PLAY_SUMMON then
          self:SummonUnits(action)
        elseif play.play_type == PlayType.PLAY_CHANGE_FIGHTER then
          self:ChangeFighter(action)
        elseif play.play_type == PlayType.PLAY_CHANGE_MODEL then
          self:ChangeUnitModel(action)
        elseif play.play_type == PlayType.PLAY_CHANGE_FIGHT_MAP then
          self:LoadFightBg(action.mapSource, false)
        elseif play.play_type == PlayType.PLAY_FIGHTER_STATUS then
          last_play_status = action
        elseif play.play_type == PlayType.PLAY_TEAM_JOIN then
          local teamId = FightConst.ACTIVE_TEAM
          if action.camp == action.PASSIVE_TEAM then
            teamId = FightConst.PASSIVE_TEAM
          end
          self:CreateFightTeam(action.team, teamId)
        end
      end
      if i == num and last_play_status then
        local action = last_play_status
        for k, v in pairs(self.fightUnits) do
          local status_list = action.fightermap[k]
          if status_list then
            local status = status_list.statuses[#status_list.statuses]
            if status then
              v:SetStatus(status)
              if v:IsReallyDead() then
                self:RemoveFightUnit(k)
                Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SKIP_ROUND_REMOVE_UNIT, {k})
              end
            end
          else
            self:RemoveFightUnit(k)
            Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SKIP_ROUND_REMOVE_UNIT, {k})
          end
        end
      end
    end
  end
  return true
end
def.method("userdata").PlayRecord = function(self, recordid)
  if recordid == nil then
    Debug.LogWarning("[Replayer]record id is nil!")
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CGetRecordReq").new(recordid))
end
def.method("userdata").PlayRealtimeBattle = function(self, recordid)
  if recordid == nil then
    Debug.LogWarning("[PlayRealtimeBattle]record id is nil!")
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CGetRealtimeRecordReq").new(recordid))
end
def.method("table").SummonUnits = function(self, action)
  if action == nil then
    return
  end
  local unit = self:GetFightUnit(action.fighterid)
  local teamId = FightConst.ACTIVE_TEAM
  if action.team == action.PASSIVE_TEAM then
    teamId = FightConst.PASSIVE_TEAM
  end
  local teamPos = self.fightPos[teamId].Pos
  if action.result == action.SUMMON then
    local pet = self.groups[unit.group].pet
    if pet then
      self:RemoveFightUnit(pet.id)
      self.groups[unit.group].pet = nil
    end
    for k, v in pairs(action.fighters) do
      local unit = self:CreateFighter(k, v, teamId, action.groupid)
    end
  elseif action.result == action.SUMMON_BACK then
    for k, _ in pairs(action.fighters) do
      self:RemoveFightUnit(k)
    end
  end
end
def.method("table").ChangeFighter = function(self, action)
  if action == nil then
    return
  end
  local unit = self:GetFightUnit(action.fighterid)
  local team = unit.team
  local group = unit.group
  self:RemoveFightUnit(action.fighterid)
  self:CreateFighter(action.changeFighterid, action.fighter, team, group)
end
def.method("table").ChangeUnitModel = function(self, action)
  if action == nil then
    return
  end
  local unit = self:GetFightUnit(action.fighterid)
  local nameColor = unit.model.m_uNameColor
  local targetpos = unit.model:GetPos()
  local dir = unit.model.m_ang
  if self.isFlyBattle and unit.flyMount then
    unit.model.flyMountModel = unit.flyMount.m_model
    unit.model:DetachFlyMount()
    unit.model.flyMountModel = nil
  end
  unit:RemoveChildEffects()
  unit.model:Destroy()
  self:RemoveWaitUnit(unit.id)
  unit.model = FightModel.new(action.model.modelid, unit.name, nameColor, unit.fightUnitType)
  unit.model.fighterId = unit.id
  unit.model.parentNode = self.fightPlayerNodeRoot
  unit.modelId = action.model.modelid
  local modelpath, modelColor = GetModelPath(unit.modelId)
  unit.model.colorId = modelColor
  local function OnNewModelLoaded()
    if unit.model == nil then
      return
    end
    unit:SetHp(unit.hp, unit.hpmax)
    unit:SetMp(unit.mp, unit.mpmax)
    if self.isFlyBattle and unit.flyMount then
      unit.model.flyMountModel = unit.flyMount.m_model
      if unit.model:AttachFlyMount() then
        unit.flyMount.isDetached = false
      end
    end
  end
  unit.model:AddOnLoadCallback("FightChangeModel", OnNewModelLoaded)
  unit.model:LoadModel2(modelpath, targetpos.x, targetpos.y, dir, true)
  unit.model:LoadModelInfo(action.model)
end
def.method("boolean").Pause = function(self, pause)
  self.paused = pause
end
def.method().EndFight = function(self)
  Replayer.OnFightEnd(nil)
end
def.method("=>", "boolean").IsRealtime = function(self)
  return instance.record ~= nil and instance.record.is_realtime == true
end
def.method("=>", "boolean").IsNeedShowDlgPrelude = function(self)
  return self.isInFight
end
def.method("number").SwitchSkills = function(self, seq)
end
def.method().FilterSkills = function(self)
end
def.method("=>", "userdata").GetMainCam = function(self)
  return mainCam
end
def.method("number", "number").AddToBeSetAppearance = function(self, unitId, appUnitId)
  if self.toBeSetAppearance == nil then
    self.toBeSetAppearance = {}
  end
  self.toBeSetAppearance[unitId] = appUnitId
end
def.method("table", "number").SetUnitHp = function(self, unit, hp)
  if self.fightType == FIGHT_TYPE.TYPE_PETCVC and unit.team == self.myTeam then
    self.ui:SetPetHp(unit, hp)
  end
end
def.method("table", "number").SetUnitMp = function(self, unit, mp)
  if self.fightType == FIGHT_TYPE.TYPE_PETCVC and unit.team == self.myTeam then
    self.ui:SetPetMp(unit, mp)
  end
end
def.method().RemoveJoinTimer = function(self)
  if self.join_timer_id > 0 then
    GameUtil.RemoveGlobalTimer(self.join_timer_id)
    self.join_timer_id = 0
  end
end
Replayer.Commit()
return Replayer
