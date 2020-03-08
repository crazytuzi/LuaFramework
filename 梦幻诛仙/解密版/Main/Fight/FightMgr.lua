local Lplus = require("Lplus")
local FightMgr = Lplus.Class("FightMgr")
local ECGame = Lplus.ForwardDeclare("ECGame")
require("Main.Fight.FightConst")
local ECFxMan = require("Fx.ECFxMan")
local def = FightMgr.define
local EC = require("Types.Vector")
local instance
local ACT_TYPE = require("consts.mzm.gsp.fight.confbean.OperateType")
local Fight = require("netio.protocol.mzm.gsp.fight.Fight")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local FightTeam = require("Main.Fight.FightTeam")
local FightUnit = require("Main.Fight.FightUnit")
local FightModel = require("Main.Fight.FightModel")
local FightSpectator = require("Main.Fight.FightSpectator")
local Octets = require("netio.Octets")
local DlgFight = require("Main.Fight.ui.DlgFight")
local PlayType = require("netio.protocol.mzm.gsp.fight.PlayType")
local ECSoundMan = require("Sound.ECSoundMan")
local TIP_INFO_TYPE = require("consts.mzm.gsp.fight.confbean.TipInfoType")
local FIGHT_TYPE = require("netio.protocol.mzm.gsp.fight.Fight")
local FightCategory = require("consts.mzm.gsp.fight.confbean.FightType")
local CostType = require("consts.mzm.gsp.skill.confbean.CostType")
local ConditionType = require("consts.mzm.gsp.skill.confbean.ConditionType")
local PetInterface = require("Main.Pet.Interface")
local CmdType = require("consts.mzm.gsp.fight.confbean.CommandType")
local LoadingMgr = require("Main.Common.LoadingMgr")
local LoginPreloadMgr = require("Main.Login.LoginPreloadMgr")
local AutoConst = require("netio.protocol.mzm.gsp.fight.FightConsts")
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
local OpSkill = require("netio.protocol.mzm.gsp.fight.OpSkill")
local OpCapture = require("netio.protocol.mzm.gsp.fight.OpCapture")
local OpItem = require("netio.protocol.mzm.gsp.fight.OpItem")
local OpProtect = require("netio.protocol.mzm.gsp.fight.OpProtect")
local OpSummonPet = require("netio.protocol.mzm.gsp.fight.OpSummonPet")
local OpSummonChild = require("netio.protocol.mzm.gsp.fight.OpSummonChild")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local TARGET_TEAM_TYPE = require("consts.mzm.gsp.skill.confbean.TargetTeamType")
local SoundData = require("Sound.SoundData")
local SkillUtility = require("Main.Skill.SkillUtility")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local FighterStatus = require("netio.protocol.mzm.gsp.fight.FighterStatus")
local AttackResultBean = require("netio.protocol.mzm.gsp.fight.AttackResultBean")
local SkillSpecialType = require("consts.mzm.gsp.skill.confbean.SkillSpecialType")
local FlyMount = require("Main.Fight.FlyMount")
local FlyModule = require("Main.Fly.FlyModule")
local GUIMan = require("GUI.ECGUIMan")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local NPCInterface = require("Main.npc.NPCInterface")
local FightUtils = require("Main.Fight.FightUtils")
local Replayer = require("Main.Fight.Replayer")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local mainCam, tipResume
def.field("number").fightType = 0
def.field("number").fightCfgId = 0
def.field("userdata").fightInstanceId = nil
def.field("table").rounds = nil
def.field("table").teams = nil
def.field("number").myTeam = 0
def.field("table").groups = nil
def.field("table").controllableUnits = nil
def.field("userdata").fightSceneNode = nil
def.field("userdata").fight_bg = nil
def.field("userdata").bgMask = nil
def.field("boolean").auto_fight_status = false
def.field("table").fightUnits = nil
def.field("boolean").isInFight = false
def.field("userdata").damageTemplate = nil
def.field("userdata").damageAnim = nil
def.field("userdata").selectTexture = nil
def.field("number").role_default_skill = 0
def.field("table").pet_default_skill = nil
def.field("number").role_shortcut_skill = 0
def.field("table").pet_shortcut_skill = nil
def.field("table").child_default_skill = nil
def.field("table").child_shortcut_skill = nil
def.field("table").waitForTargets = nil
def.field("table").nextAction = nil
def.field("table").fonts = nil
def.field("table").skillCfgCache = nil
def.field("function").nextPlay = nil
def.field(FightUnit).followTarget = nil
def.field("userdata").fightPlayerNodeRoot = nil
def.field("table").shakeParam = nil
def.field("number").deltaAngle = 0
def.field("number").summonPetTimes = 0
def.field("table").summonedList = nil
def.field("number").summonChildTimes = 0
def.field("table").summonedChildList = nil
def.field("number").useItemTimes = 0
def.field("table").cameraParam = nil
def.field("userdata").fight3DScene = nil
def.field("table").formationIcons = nil
def.field("table").itemList = nil
def.field("table").spectators = nil
def.field("table").pendingOnLoad = nil
def.field("number").adaptOffset = -1
def.field("boolean").isPerspective = false
def.field("boolean").isSpectator = false
def.field("table").requestList = nil
def.field("table").fxCacheList = nil
def.field("table").skillMap = nil
def.field("table").hasLoaded = nil
def.field("table").commandItems = nil
def.field("userdata").damageRoot = nil
def.field("table").sceneInfo = nil
def.field("table").actionMap = nil
def.field("boolean").is3dScene = false
def.field("table").cam3dParam = nil
def.field("boolean").playVoice = true
def.field("number").curRound = 0
def.field("number").curServerRound = 0
def.field("number").playingRound = 0
def.field("number").playTime = -1
def.field("number").loadModelTime = -1
def.field("table").fightLog = nil
def.field("boolean").isFlyBattle = false
def.field("boolean").isInUpdate = false
def.field("table").tobeAdded = nil
def.field("table").tobeDeleted = nil
def.field("table").proCache = nil
def.field("userdata").fightDamageCam = nil
def.field("table").fightEndPro = nil
def.field("table").preloadList = nil
def.field("number").preloadTick = -1
def.field("number").fightSoundTypeId = -1
def.field("number").cmdUnitId = 0
def.field("boolean").isCacheProcessing = false
def.field("table").commandDoneMap = nil
def.field("table").spectatorTeamMap = nil
def.field("boolean").soundEnable = true
def.field("table").playController = nil
def.field("table").roleSkillCache = nil
def.field("table").toBeSetAppearance = nil
def.field("number").join_timer_id = 0
def.field("table").fightPos = nil
def.const("number").MAX_OBSERVER_NUM = 6
def.const("number").FIGHT_SCENE_SCALE = 1
def.const("number").FightSoundTypeId_Min = 1
def.const("number").FightSoundTypeId_Max = 10
def.const("table").BattleFieldPos = EC.Vector3.new(-1000, 0, -1000)
def.const("table").BattleFieldCamPos = EC.Vector3.new(-1000, -1000, -100)
def.static("=>", FightMgr).Instance = function()
  if instance == nil then
    instance = FightMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SEnterFightBrd", FightMgr.OnSEnterFight)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SNextRoundBrd", FightMgr.OnSRoundStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSyncAutoState", FightMgr.SSyncAutoState)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SOperateRes", FightMgr.OnSOperateRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SRoundPlayBrd", FightMgr.PlayRound)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SFightEndBrd", FightMgr.OnSFightEnd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SChangeDefaultSkillRes", FightMgr.OnSChangeDefaultSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SFightNormalResult", FightMgr.OnSFightNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSelectOperateBrd", FightMgr.OnSSelectOperateBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SFighterOnlineBrd", FightMgr.OnSFighterOnlineBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSynRoleSkillInfo", FightMgr.OnSSynRoleSkillInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSynRolePetSkillInfo", FightMgr.OnSSynRolePetSkillInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSynRoleChildSkillInfo", FightMgr.OnSSynRoleChildSkillInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SEnterFightOperFighters", FightMgr.OnSEnterFightOperFighters)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSynAddObserver", FightMgr.OnSSynAddObserver)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSynObserveEnd", FightMgr.OnSSynObserveEnd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSynRoleObserveType", FightMgr.OnSSynRoleObserveType)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSynCommandRes", FightMgr.OnSSynCommandRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SCommandChangeRes", FightMgr.OnSCommandChangeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SynCommandInfos", FightMgr.OnSynCommandInfos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SDelCommandReq", FightMgr.OnSDelCommandReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fight.SSynRemCommandRes", FightMgr.OnSSynRemCommandRes)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SELECT_TARGET, FightMgr.OnSelectTarget)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_LOADED, FightMgr.OnModelLoaded)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, FightMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FightMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LONG_TOUCH_TARGET, FightMgr.OnLongTouchTarget)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_LOADING_START, FightMgr.OnLoadingStart)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PopChat, FightMgr.OnUnitTalk)
  Event.RegisterEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.SETTING_CHANGED, FightMgr.OnSettingChanged)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_PAUSE, FightMgr.OnPauseGame)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_RESUME, FightMgr.OnResumeGame)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, FightMgr.OnFeatureClose)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, FightMgr.OnFeatureClose)
  self.fxCacheList = {}
  self.proCache = {}
  self.skillMap = {}
  self.commandDoneMap = {}
  Replayer.Instance():Init()
end
def.method().Prepare = function(self)
  self:PreloadEffects()
  self:LoadFightCommandCfg()
  self:SetAdaptedPos()
  if self.fightSceneNode then
    return
  end
  self.fightPlayerNodeRoot = GameObject.GameObject("fightPlayerNodeRoot")
  self.fightPlayerNodeRoot.localPosition = FightMgr.BattleFieldPos
  self.damageRoot = GameObject.GameObject("FightDamageRoot")
  self.damageRoot:SetLayer(ClientDef_Layer.FIGHT_UI)
  local root = self.damageRoot:AddComponent("UIRoot")
  root.scalingStyle = 1
  root.manualHeight = ECGame.Instance().m_2DWorldCam.orthographicSize * 2
  local uipanel = self.damageRoot:AddComponent("UIPanel")
  uipanel.depth = -1
  self.fightSceneNode = GameObject.GameObject("fightSceneNode")
  self.fightSceneNode:SetLayer(ClientDef_Layer.Fight)
  self.fightSceneNode.localPosition = EC.Vector3.new(-1000, 0, -9600)
  self:PreLoadRes()
  self:LoadTemplate()
  self.pendingOnLoad = {}
  Timer:RegisterIrregularTimeListener(FightMgr.LoadEffectList, instance)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.NO_SKILL_VOICE)
  self.playVoice = not setting.isEnabled
  self.fightDamageCam = GameObject.GameObject("FightDamageCamera")
  local cam = self.fightDamageCam:AddComponent("Camera")
  cam:set_cullingMask(ui_fight_cull_mask)
  cam.clearFlags = CameraClearFlags.Depth
  cam.orthographic = true
  cam.orthographicSize = GUIMan.Instance().m_camera.orthographicSize * FightMgr.FIGHT_SCENE_SCALE
  cam.nearClipPlane = GUIMan.Instance().m_camera.nearClipPlane
  cam.farClipPlane = GUIMan.Instance().m_camera.farClipPlane
  cam.depth = CameraDepth.FIGHT_DAMAGE
  self.fightDamageCam:SetActive(false)
  self.playController = require("Main.Fight.PlayController").Create()
  Replayer.Instance():Prepare()
end
def.static("table", "table").OnLoadingStart = function(p1, p2)
  instance:Prepare()
end
def.static("table").OnSEnterFight = function(p)
  if gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isEnteredWorld == false and not instance.isCacheProcessing then
    table.insert(instance.proCache, {
      pro = p,
      func = FightMgr.OnSEnterFight
    })
    return
  end
  if instance.isInFight then
    if not instance.isCacheProcessing then
      table.insert(instance.proCache, {
        pro = p,
        func = FightMgr.OnSEnterFight
      })
    end
    FightMgr.OnFightEnd(instance.fightEndPro)
    return
  end
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
  instance.isInFight = true
  local isInRelaying = Replayer.Instance().isInFight
  if not isInRelaying then
    FxCacheMan.Instance.gameObject.localPosition = FightMgr.BattleFieldPos
    instance.damageRoot:SetActive(true)
  else
    instance.damageRoot:SetActive(false)
    Toast(textRes.Fight[65])
  end
  if not instance.playController:IsRunning() then
    instance.playController:Start()
  end
  instance.fightPos = FightConst.FightPos
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
  instance.summonedList = {}
  instance.summonedChildList = {}
  instance.hasLoaded = {}
  instance.isSpectator = false
  instance:LoadFightCommandCfg()
  local game = ECGame.Instance()
  game.m_isInFight = true
  instance:CheckIsSpectator(p)
  GameUtil.AddGlobalTimer(1, true, function()
    if instance.isInFight then
      GameUtil.AsyncLoad(RESPATH.FIGHT_3D_SCENE, function(obj)
        if obj and instance.isInFight then
          instance.fight3DScene = Object.Instantiate(obj, "GameObject")
          instance.fight3DScene.parent = instance.fightPlayerNodeRoot
          instance.fight3DScene:SetActive(false)
          instance.fight3DScene.transform.localPosition = EC.Vector3.zero
          instance.fight3DScene:SetLayer(ClientDef_Layer.FightPlayer)
        end
      end)
    end
  end)
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
  mainCam = game.m_Main3DCam
  mainCam.parent = instance.fightPlayerNodeRoot
  Timer:RegisterIrregularTimeListener(FightMgr.Update, instance)
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
  if instance.isFlyBattle then
    if not isInRelaying then
      instance:SetToSkyMode()
    end
  else
    if not isInRelaying then
      instance:SetToGroundMode()
    end
    bgId = instance:GetBgPic(instance.sceneInfo.bgIds)
    if bgId == 0 then
      bgId = gmodule.moduleMgr:GetModule(ModuleId.MAP).battleBg
    end
  end
  game.m_fightCam.localPosition = EC.Vector3.new(-1000, 0, -10000)
  instance.groups = {}
  instance.teams = {}
  instance.spectators = {}
  instance.summonPetTimes = constant.FightConst.SUMMON_TIMES
  instance.summonChildTimes = constant.CChildrenConsts.child_summon_max
  FightConst.ACTIVE_TEAM = FightConst.RIGHT_BOTTOM
  FightConst.PASSIVE_TEAM = FightConst.LEFT_TOP
  instance.myTeam = instance:CheckMyTeam(p.fight.passive_team)
  if instance.myTeam == FightConst.PASSIVE_TEAM then
    FightConst.ACTIVE_TEAM = FightConst.LEFT_TOP
    FightConst.PASSIVE_TEAM = FightConst.RIGHT_BOTTOM
    instance.myTeam = FightConst.PASSIVE_TEAM
  end
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
  instance:FilterSkills()
  local pos3d = EC.Vector3.zero
  mainCam.localPosition = pos3d - mainCam.forward * 15
  if worldBossCfg then
    instance:Load3DSceneLight()
    if game.m_fightCam then
      game.m_fightCam:SetActive(false)
    end
    guiMan.m_hudCamera.clearFlags = CameraClearFlags.Depth
  elseif bgId > 0 then
    instance:LoadFightBg(bgId, false)
    if game.m_fightCam and not isInRelaying then
      game.m_fightCam:SetActive(true)
    end
  elseif not instance.isFlyBattle then
    instance:LoadFightBgMask()
    if game.m_fightCam and not isInRelaying then
      game.m_fightCam:SetActive(true)
    end
  end
  local cam = game.m_Main3DCam:GetComponent("Camera")
  cam:set_cullingMask(get_cull_mask(ClientDef_Layer.FightPlayer))
  cam.orthographicSize = cam.orthographicSize * FightMgr.FIGHT_SCENE_SCALE
  if not isInRelaying then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, {
      isFlyBattle = instance.isFlyBattle
    })
    if instance.fightDamageCam then
      instance.fightDamageCam:SetActive(true)
    end
    guiMan.m_hudCameraGo.localPosition = FightMgr.BattleFieldCamPos
    guiMan.m_hudCameraGo2.localPosition = FightMgr.BattleFieldCamPos
  end
  instance.fightType = p.fight.fight_type
  instance.rounds = {}
  instance.curRound = p.fight.round
  instance.curServerRound = p.fight.round
  if 0 < p.fight.round then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.NEXT_ROUND, {
      p.fight.round
    })
  end
  Timer:RegisterListener(FightMgr.UpdateRoundTime, instance)
  for _, v in pairs(p.fight.observers) do
    local count = table.nums(instance.spectators)
    if count < FightMgr.MAX_OBSERVER_NUM then
      local posidx = count + 1
      local pos = FightConst.ObserverPos[posidx]
      local idx = math.floor((posidx + FightMgr.MAX_OBSERVER_NUM / 2 - 1) / FightMgr.MAX_OBSERVER_NUM) + 1
      local dir = FightConst.ObserverDir[idx]
      instance:CreateSpectator(v, pos.x, pos.y, dir, posidx)
    end
  end
  if worldBossCfg then
    instance:SetWorldBossInfo(worldBossCfg)
  end
  guiMan.m_hudCamera2.enabled = true
  guiMan.m_hudCameraGo2:SetActive(true)
  guiMan.m_camera.clearFlags = CameraClearFlags.Nothing
  if not instance.isSpectator and instance.sceneInfo and instance.sceneInfo.showAdditionalCost then
    local team = instance.teams[instance.myTeam]
    if team then
      local members = team:GetAllMembers()
      local partners = {}
      for _, member in pairs(members) do
        if member.fightUnitType == GameUnitType.FELLOW then
          table.insert(partners, member)
        end
      end
      if #partners > 2 then
        local assistsNum = 0
        local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
        for _, partner in pairs(partners) do
          local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, partner.roleId:ToNumber())
          if record then
            local menpai = record:GetIntValue("faction")
            local menpaiCfg = GetOccupationCfg(menpai, GenderEnum.FEMALE)
            if menpaiCfg and menpaiCfg.isAssist then
              assistsNum = assistsNum + 1
            end
          end
        end
        if assistsNum > 2 then
          Toast(textRes.Fight[45])
        end
      end
    end
  end
  local readyList = {}
  local cmdsDone = instance.commandDoneMap[p.fight.fight_uuid:tostring()]
  if cmdsDone then
    for k, v in pairs(cmdsDone) do
      local unit = instance:GetFightUnit(v)
      if unit then
        unit.in_turn = false
      end
      table.insert(readyList, v)
    end
  end
  DlgFight.Instance().time = 0
  DlgFight.Instance():ShowDlg()
  DlgFight.Instance():ShowFormation()
  local curTime = GetServerTime()
  local remainTime = p.fight.operEndTime and p.fight.operEndTime / 1000 - curTime
  local cmdTime = remainTime and remainTime:ToNumber() or 0
  if cmdTime > 0 then
    if not instance.auto_fight_status or cmdTime > constant.FightConst.WAIT_CMD_TIME - constant.FightConst.AUTO_WAIT_TIME then
      table.insert(instance.rounds, {
        round_num = p.fight.round,
        cmd_time = cmdTime,
        readyList = readyList
      })
      instance:DoRoundCommand()
    end
  elseif 0 < p.fight.round then
    tipResume = require("GUI.CommonUITipsDlg").ShowConstTip(textRes.Fight[43], {x = 0, y = 0})
    tipResume.textAlign = Alignment.Center
  end
  if instance.auto_fight_status and cmdTime <= constant.FightConst.WAIT_CMD_TIME - constant.FightConst.AUTO_WAIT_TIME then
    DlgFight.Instance():ShowAutoSkill()
  end
  require("Main.Map.MapUtility").EndLoading()
end
def.method().FilterSkills = function(self)
  local skillData = self.skillMap[self.fightInstanceId:tostring()]
  if skillData and skillData.roleSkills then
    local me = self:GetMyHero()
    if me == nil then
      return
    end
    local normalAttackSkillId = FightUtils.GetNormalAttackSkillId(me.menpai)
    skillData.roleSkills[constant.FightConst.ATTACK_SKILL] = nil
    skillData.roleSkills[normalAttackSkillId] = 1
    local shortcut_skillId = self.role_shortcut_skill
    if shortcut_skillId == 0 then
      shortcut_skillId = self.role_default_skill
    end
    if shortcut_skillId > 0 then
      local OracleData = require("Main.Oracle.data.OracleData")
      if skillData.roleSkills[shortcut_skillId] == nil then
        local originSkillId = OracleData.Instance():GetOriginSkillId(shortcut_skillId)
        if originSkillId == 0 then
          originSkillId = self.role_shortcut_skill
        end
        if originSkillId > 0 then
          self.role_shortcut_skill = OracleData.Instance():GetTalentSkillId(originSkillId)
        end
      end
    end
  end
end
def.method().LoadFightBgMask = function(self)
  if instance.bgMask then
    return
  end
  GameUtil.AsyncLoad(RESPATH.FIGHT_MASK, function(obj)
    if obj and self.isInFight then
      instance.bgMask = Object.Instantiate(obj, "GameObject")
      instance.bgMask.transform.parent = self.fightSceneNode.transform
      instance.bgMask.transform.localPosition = EC.Vector3.new(0, 0, 0)
      instance.bgMask.transform.localScale = EC.Vector3.new(0.7, 0.7, 1)
      instance.bgMask:SetLayer(ClientDef_Layer.Fight)
    end
  end)
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
local spri_asset
def.method("=>", "userdata").CreateSprite = function(self)
  if spri_asset == nil then
    local spri = GameUtil.SyncLoad(RESPATH.SPRITE_INST)
    if not spri then
      warn("...... spri is nil")
      return 0, 0
    end
    spri_asset = spri
  end
  local spr = Object.Instantiate(spri_asset, "GameObject")
  local cd = spr:GetComponent("BoxCollider")
  cd:GetComponent("BoxCollider").enabled = false
  spr.transform.parent = self.fightSceneNode.transform
  spr.localScale = EC.Vector3.one
  spr:SetLayer(ClientDef_Layer.Fight)
  return spr
end
def.static("table").OnSRoundStart = function(p)
  instance.curServerRound = p.round
  if not gmodule.moduleMgr:GetModule(ModuleId.LOGIN):IsInWorld() then
    if not instance.isInFight and not instance.isCacheProcessing then
      table.insert(instance.proCache, {
        pro = p,
        func = FightMgr.OnSRoundStart
      })
    end
    return
  end
  if instance.rounds == nil then
    return
  end
  if tipResume then
    tipResume:HideDlg()
    tipResume = nil
  end
  local round_data = instance:GetRoundData(instance.curServerRound)
  if round_data then
    round_data.cmd_time = constant.FightConst.WAIT_CMD_TIME
  else
    table.insert(instance.rounds, {
      round_num = p.round,
      cmd_time = constant.FightConst.WAIT_CMD_TIME
    })
  end
  local cur_round_data
  if instance.curRound == instance.curServerRound then
    cur_round_data = round_data
  else
    cur_round_data = instance:GetRoundData(instance.curRound)
  end
  if cur_round_data == nil or cur_round_data.playlist == nil then
    instance:DoRoundCommand()
  end
end
def.method("number", "=>", "table").GetRoundData = function(self, roundnum)
  if self.rounds == nil then
    return nil
  end
  for _, round in pairs(self.rounds) do
    if round.round_num == roundnum then
      return round
    end
  end
  return nil
end
def.method().DoRoundCommand = function(self)
  local i = 1
  if self.controllableUnits then
    for i = 1, #self.controllableUnits do
      self.controllableUnits[i]:ResetAction()
    end
  end
  if self.rounds and self.rounds[1] then
    self.curRound = self.rounds[1].round_num
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.NEXT_ROUND, {
      self.curRound
    })
  end
  for _, v in pairs(instance.fightUnits) do
    if v and v.model and (v.fightUnitType == GameUnitType.ROLE or v.fightUnitType == GameUnitType.PET or v.fightUnitType == GameUnitType.CHILDREN) then
      if self.rounds and self.rounds[1] and self.rounds[1].readyList and table.indexof(self.rounds[1].readyList, v.id) then
        v:SetReady(true)
      else
        v:SetReady(false)
      end
    end
  end
  self.itemList = nil
  instance:NextCommand()
end
def.method("number").UpdateRoundTime = function(self, tk)
  if self.rounds then
    for k, v in ipairs(self.rounds) do
      if v.cmd_time > 0 then
        v.cmd_time = v.cmd_time - 1
      end
    end
  end
end
def.method("number").SwitchSkills = function(self, seq)
  if self.roleSkillCache == nil then
    return
  end
  if self.skillMap == nil then
    self.skillMap = {}
  end
  local k = self.fightInstanceId:tostring()
  local skilldata = self.skillMap[k]
  if skilldata == nil then
    skilldata = {}
    self.skillMap[k] = skilldata
  end
  local roleSkills = self.roleSkillCache[seq]
  if roleSkills then
    skilldata.roleSkills = roleSkills
  else
    Debug.LogWarning(string.format("[FightError](SwitchSkills) skills is nil for seq: %d", seq))
  end
  self:FilterSkills()
end
def.static("table").OnSEnterFightOperFighters = function(p)
  instance.commandDoneMap[p.fight_uuid:tostring()] = p.operUuids
end
def.static("table").OnSSynRoleSkillInfo = function(p)
  if instance.isInFight and p.seq > 0 then
    if instance.roleSkillCache == nil then
      instance.roleSkillCache = {}
    end
    p.skillMap[constant.FightConst.ATTACK_SKILL] = 1
    p.skillMap[constant.FightConst.DEFENCE_SKILL] = 1
    instance.roleSkillCache[p.seq] = p.skillMap
    return
  end
  if instance.skillMap == nil then
    instance.skillMap = {}
  end
  local k = p.fight_uuid:tostring()
  local skilldata = instance.skillMap[k]
  if skilldata == nil then
    skilldata = {}
    instance.skillMap[k] = skilldata
  end
  p.skillMap[constant.FightConst.ATTACK_SKILL] = 1
  p.skillMap[constant.FightConst.DEFENCE_SKILL] = 1
  skilldata.roleSkills = p.skillMap
end
def.static("table").OnSSynRolePetSkillInfo = function(p)
  if instance.skillMap == nil then
    instance.skillMap = {}
  end
  local k = p.fight_uuid:tostring()
  local skilldata = instance.skillMap[k]
  if skilldata == nil then
    skilldata = {}
    instance.skillMap[k] = skilldata
  end
  p.skillMap[constant.FightConst.ATTACK_SKILL] = 1
  p.skillMap[constant.FightConst.DEFENCE_SKILL] = 1
  skilldata.petSkills = p.skillMap
end
def.static("table").OnSSynRoleChildSkillInfo = function(p)
  if instance.skillMap == nil then
    instance.skillMap = {}
  end
  local k = p.fight_uuid:tostring()
  local skilldata = instance.skillMap[k]
  if skilldata == nil then
    skilldata = {}
    instance.skillMap[k] = skilldata
  end
  p.skillMap[constant.FightConst.ATTACK_SKILL] = 1
  p.skillMap[constant.FightConst.DEFENCE_SKILL] = 1
  skilldata.childrenSkills = p.skillMap
end
def.static("table").OnSOperateRes = function(p)
  if not instance.isInFight and not instance.isCacheProcessing then
    table.insert(instance.proCache, {
      pro = p,
      func = FightMgr.OnSOperateRes
    })
    return
  end
  local unit = instance:GetFightUnit(p.fighterid)
  if instance.cmdUnitId == p.fighterid then
    instance.cmdUnitId = 0
  end
  if unit == nil then
    Debug.LogWarning(string.format("[Fight](OnSOperateRes)unit is nil for id: %d", p.fighterid))
    return
  end
  if unit.in_turn then
    instance:EndTurn(unit)
  else
    Debug.LogWarning(string.format("[Fight](OnSOperateRes)unit:%s(%d) is not in turn", unit.name, unit.id))
  end
end
def.static("table").SSyncAutoState = function(p)
  if instance.fightEndPro and not instance.isCacheProcessing then
    table.insert(instance.proCache, {
      pro = p,
      func = FightMgr.SSyncAutoState
    })
    return
  end
  instance.auto_fight_status = AutoConst.AUTO_STATE__AUTO == p.info.auto_state
  instance.role_default_skill = p.info.role_default_skill
  if instance.role_shortcut_skill == 0 then
    instance.role_shortcut_skill = instance.role_default_skill
  end
  instance.pet_default_skill = {}
  instance.pet_shortcut_skill = {}
  for k, v in pairs(p.info.pet_default_skills) do
    instance.pet_default_skill[k:tostring()] = v
    instance.pet_shortcut_skill[k:tostring()] = v
  end
  instance.child_default_skill = {}
  instance.child_shortcut_skill = {}
  for k, v in pairs(p.info.child_default_skills) do
    instance.child_default_skill[k:tostring()] = v
    instance.child_shortcut_skill[k:tostring()] = v
  end
  local dlgFight = DlgFight.Instance()
  local unit = instance:GetCurrentControllable()
  if dlgFight:IsShow() and not instance.isSpectator then
    dlgFight:ShowAutoSkill()
  end
  if instance.isInFight and not instance.auto_fight_status and unit == nil then
    Toast(textRes.Fight[7])
  end
end
def.static("table").OnSChangeDefaultSkillRes = function(p)
  if p.fighter_type == GameUnitType.ROLE then
    instance.role_default_skill = p.skill
  elseif p.fighter_type == GameUnitType.PET then
    instance.pet_default_skill[p.uuid:tostring()] = p.skill
  elseif p.fighter_type == GameUnitType.CHILDREN then
    instance.child_default_skill[p.uuid:tostring()] = p.skill
  end
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.DEFAULT_SKILL_CHANGED, nil)
end
def.static("table").PlayRound = function(p)
  if not instance.isInFight and not instance.isCacheProcessing then
    table.insert(instance.proCache, {
      pro = p,
      func = FightMgr.PlayRound
    })
    return
  end
  if instance.fightInstanceId == nil or not instance.fightInstanceId:eq(p.fight_uuid) then
    return
  end
  instance.cmdUnitId = 0
  if instance.rounds == nil then
    Debug.LogWarning(string.format("[FightError](PlayRound) rounds is nil"))
    return
  end
  local round = instance:GetRoundData(instance.curServerRound)
  if round then
    round.playlist = p.playlist
  else
    Debug.LogWarning(string.format("round data is nil, curServerRound: %d", instance.curServerRound))
    round = {
      round_num = instance.curServerRound,
      cmd_time = constant.FightConst.WAIT_CMD_TIME
    }
    round.playlist = p.playlist
    table.insert(instance.rounds, round)
  end
  if instance.curRound == instance.curServerRound then
    instance:PlayNextRound()
  end
end
def.method().PlayNextRound = function(self)
  local round = self.rounds and self.rounds[1]
  if round then
    self.curRound = round.round_num
  end
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.NEXT_ROUND, {
    self.curRound
  })
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, nil)
  DlgFight.Instance():StopCountDown()
  DlgFight.Instance():ShowCountDown(false)
  DlgFight.Instance():ShowAutoSkill()
  require("Main.Fight.ui.DlgSelectSkill").Instance():Hide()
  if tipResume then
    tipResume:HideDlg()
    tipResume = nil
  end
  if self.controllableUnits then
    local i = 1
    for i = 1, #self.controllableUnits do
      self.controllableUnits[i].in_turn = false
    end
  end
  for _, v in pairs(instance.fightUnits) do
    if v and v.model then
      v:SetReady(true)
    end
  end
  local cur_round = self:GetRoundData(self.curRound)
  if cur_round and cur_round.playlist then
    self.playingRound = cur_round.round_num
    self:PlayNext()
  else
    Debug.LogWarning(string.format("playlist not found in round(%d %s)", self.curRound, tostring(cur_round)))
  end
end
def.method().PlayNext = function(self)
  if self.hasLoaded and #self.hasLoaded < table.nums(self.fightUnits) then
    if self.loadModelTime < 0 then
      self.loadModelTime = 20
    elseif self.nextAction == nil and instance.fightEndPro and self.fightInstanceId:eq(instance.fightEndPro.fight_uuid) then
      self.loadModelTime = -1
      local pro = instance.fightEndPro
      instance.fightEndPro = nil
      FightMgr.OnFightEnd(pro)
      return
    end
    self.nextPlay = FightMgr.PlayNext
    return
  end
  self.hasLoaded = nil
  self.fightLog = nil
  if self.controllableUnits and self.controllableUnits[1] then
    self:ShowAllValidTargets(self.controllableUnits[1], false)
  end
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
  self.playTime = 2
  if action.actionType == PlayType.PLAY_CHANGE_FIGHT_MAP then
    self:LoadFightBg(action.mapSource, false)
    self.nextPlay = FightMgr.PlayNext
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
  local deathTime = 0
  local deltaTime = 0
  if action.actionType == PlayType.PLAY_FIGHTER_STATUS then
    for k, v in pairs(action.fightermap) do
      table.insert(self.waitForTargets, k)
    end
    local actModel
    for k, v in pairs(action.fightermap) do
      local unit = self:GetFightUnit(k)
      if unit then
        actModel = unit.masterModel or unit.model
        for _, status in pairs(v.statuses) do
          for _, stset in pairs(status.status_set) do
            if stset == FighterStatus.STATUS_FAKE_DEAD or stset == FighterStatus.STATUS_DEAD then
              local curdeathTime = actModel:GetAniDuration(ActionName.Death1) + FightConst.PLAY_TIME.CALLBACK_DELAY + FightConst.PLAY_TIME.DEATH_TIME
              if deathTime < curdeathTime then
                deltaTime = curdeathTime - deathTime
                deathTime = curdeathTime
                self.playTime = self.playTime + deltaTime
              end
            end
            if stset == FighterStatus.STATUS_RELIVE then
              self.playTime = self.playTime + actModel:GetAniDuration(ActionName.Revive) + FightConst.PLAY_TIME.REVIVE_DELAY
            end
          end
        end
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
    if tip and not self.isSpectator then
      local unit = self:GetFightUnit(action.fighterid)
      local showTip = tip.targetType == TIP_INFO_TYPE.ALL
      showTip = showTip or tip.targetType == TIP_INFO_TYPE.SELF and self:IsMyUnit(action.fighterid)
      showTip = not showTip and tip.targetType == TIP_INFO_TYPE.TEAM and unit and unit.team == self.myTeam
      if showTip then
        Toast(string.format(tip.tipStr, unpack(action.args)))
      end
    end
    self.nextPlay = FightMgr.PlayNext
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
    self.playTime = self.playTime + actModel:GetAniDuration(ActionName.Magic) + FightConst.PLAY_TIME.USE_ITEM
    unit:UseItem(action.releaserStatus, targets, action.targetStatus)
    return
  end
  self.playTime = self.playTime + self:CalcPlayTime(unit, action)
  if action.targets == nil or #action.targets == 0 then
    unit:Play(action, nil)
    return
  end
  local invalidTargets = {}
  deathTime = 0
  for i = 1, #action.targets do
    local target = self:GetFightUnit(action.targets[i])
    if target then
      target:Reset()
      local targetActModel = target.masterModel or target.model
      target.attack_result = action.status_map[target.id].attackResultBeans
      target.protect = action.protect_map[target.id]
      if target.protect then
        for _, protecter in pairs(target.protect.protecterids) do
          table.insert(self.waitForTargets, protecter)
          self.playTime = self.playTime + FightConst.PLAY_TIME.PROTECT_RUN * 2 + FightConst.PLAY_TIME.HITBACK_DEFAULT_DURATION
        end
      end
      target.additionalAttack = action.hitAgain_map[target.id]
      target.influences = action.influenceMap[target.id]
      if target.additionalAttack then
        for _, addtionalTarget in pairs(target.additionalAttack.targets) do
          table.insert(self.waitForTargets, addtionalTarget)
          self.playTime = self.playTime + actModel:GetAniDuration(ActionName.Attack1) + FightConst.PLAY_TIME.RETURN_POS * 2 + FightConst.PLAY_TIME.HITBACK_DEFAULT_DURATION * 2
          local addAtkResult = target.additionalAttack.status_map[addtionalTarget]
          if addAtkResult then
            for k, v in pairs(addAtkResult.attackResultBeans) do
              local addunit = self:GetFightUnit(addtionalTarget)
              if addunit == nil then
                Debug.LogWarning(string.format("[Fight error]addtionalTarget is nil for id: %d", addtionalTarget))
                self.playTime = self.playTime + 3
                break
              end
              local addunitActModel = addunit.masterModel or addunit.model
              for _, stset in pairs(v.targetStatus.status_set) do
                if stset == FighterStatus.STATUS_FAKE_DEAD or stset == FighterStatus.STATUS_DEAD then
                  local curdeathTime = addunitActModel:GetAniDuration(ActionName.Death1) + FightConst.PLAY_TIME.CALLBACK_DELAY + FightConst.PLAY_TIME.DEATH_TIME
                  self.playTime = self.playTime + curdeathTime
                end
              end
              if v.counterAttack and v.counterAttack.skill then
                self.playTime = self.playTime + addunitActModel:GetAniDuration(ActionName.Attack1) + FightConst.PLAY_TIME.CALLBACK_DELAY * 2
                for _, st in pairs(v.counterAttack.targetStatus.status_set) do
                  if st == FighterStatus.STATUS_FAKE_DEAD or st == FighterStatus.STATUS_DEAD then
                    local curdeathTime = actModel:GetAniDuration(ActionName.Death1) + FightConst.PLAY_TIME.CALLBACK_DELAY + FightConst.PLAY_TIME.DEATH_TIME
                    self.playTime = self.playTime + curdeathTime
                  end
                end
                for tarId, st in pairs(v.counterAttack.influences.otherMap) do
                  if tarId < 0 then
                    local infTarget = self:GetFightUnit(-tarId)
                    if infTarget then
                      local infTargetActModel = infTarget.masterModel or infTarget.model
                      local curdeathTime = infTargetActModel:GetAniDuration(ActionName.Death1) + FightConst.PLAY_TIME.CALLBACK_DELAY * 2 + FightConst.PLAY_TIME.DEATH_TIME
                      curdeathTime = curdeathTime + FightConst.PLAY_TIME.REVIVE_DELAY + infTargetActModel:GetAniDuration(ActionName.Revive) + FightConst.PLAY_TIME.CALLBACK_DELAY * 2
                      self.playTime = self.playTime + curdeathTime
                    end
                  end
                end
              end
            end
          end
        end
      end
      table.insert(targets, target)
      for _, attackResult in pairs(target.attack_result) do
        local play_time, death_time = self:CalcAttackResultTime(attackResult, actModel, targetActModel)
        self.playTime = self.playTime + play_time
        if deathTime < death_time then
          deathTime = death_time
        end
      end
    else
      Debug.LogWarning("[fatal error]target could not be found for id: ", action.targets[i])
      table.insert(invalidTargets, i)
    end
  end
  self.playTime = self.playTime + deathTime
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
def.method("table", "table", "table", "=>", "number", "number").CalcAttackResultTime = function(self, attackResult, actModel, targetActModel)
  if attackResult == nil then
    return 0, 0
  end
  local time = 0
  local deathTime = 0
  local shareTargetData = attackResult.shareDamageTargets
  if shareTargetData and #shareTargetData > 0 then
    for _, stdata in pairs(shareTargetData) do
      local shareReviveStatus = stdata.statusMap[AttackResultBean.TARGET_RELIVE]
      if shareReviveStatus then
        time = time + FightConst.PLAY_TIME.REVIVE_DELAY + targetActModel:GetAniDuration(ActionName.Revive)
      end
    end
  end
  local reviveStatus = attackResult.statusMap[AttackResultBean.TARGET_RELIVE] or attackResult.statusMap[AttackResultBean.RELEASER_RELIVE]
  if reviveStatus then
    time = time + FightConst.PLAY_TIME.REVIVE_DELAY + targetActModel:GetAniDuration(ActionName.Revive)
  end
  local reboundStatus = attackResult.statusMap[AttackResultBean.REBOUND]
  if reboundStatus then
    time = time + FightConst.PLAY_TIME.HITBACK_DEFAULT_DURATION * 2 + FightConst.PLAY_TIME.CALLBACK_DELAY
    for _, st in pairs(attackResult.targetStatus.status_set) do
      if st == FighterStatus.STATUS_FAKE_DEAD or st == FighterStatus.STATUS_DEAD then
        local curdeathTime = targetActModel:GetAniDuration(ActionName.Death1) + FightConst.PLAY_TIME.CALLBACK_DELAY + FightConst.PLAY_TIME.DEATH_TIME
        time = time + curdeathTime
      end
    end
  end
  for _, stset in pairs(attackResult.targetStatus.status_set) do
    if stset == FighterStatus.STATUS_COMBO_ATTACKED then
      time = time + targetActModel:GetAniDuration(ActionName.Attack1) + FightConst.PLAY_TIME.CALLBACK_DELAY * 2
    elseif stset == FighterStatus.STATUS_FAKE_DEAD or stset == FighterStatus.STATUS_DEAD then
      local curdeathTime = targetActModel:GetAniDuration(ActionName.Death1) + FightConst.PLAY_TIME.CALLBACK_DELAY + FightConst.PLAY_TIME.DEATH_TIME
      if deathTime < curdeathTime then
        deathTime = curdeathTime
      end
    end
  end
  if attackResult.counterAttack and attackResult.counterAttack.skill then
    local hitbackDuration = actModel:GetAniDuration(ActionName.BeHit)
    time = time + hitbackDuration * 2 + targetActModel:GetAniDuration(ActionName.Attack1) + FightConst.PLAY_TIME.CALLBACK_DELAY * 2
    for _, st in pairs(attackResult.counterAttack.targetStatus.status_set) do
      if st == FighterStatus.STATUS_FAKE_DEAD or st == FighterStatus.STATUS_DEAD then
        local curdeathTime = actModel:GetAniDuration(ActionName.Death1) + FightConst.PLAY_TIME.CALLBACK_DELAY + FightConst.PLAY_TIME.DEATH_TIME
        time = time + curdeathTime
      end
    end
    for tarId, st in pairs(attackResult.counterAttack.influences.otherMap) do
      if tarId < 0 then
        local infTarget = self:GetFightUnit(-tarId)
        if infTarget then
          local infTargetActModel = infTarget.masterModel or infTarget.model
          local curdeathTime = infTargetActModel:GetAniDuration(ActionName.Death1) + FightConst.PLAY_TIME.CALLBACK_DELAY * 2 + FightConst.PLAY_TIME.DEATH_TIME
          time = time + curdeathTime
          time = time + FightConst.PLAY_TIME.REVIVE_DELAY + infTargetActModel:GetAniDuration(ActionName.Revive) + FightConst.PLAY_TIME.CALLBACK_DELAY * 2
        end
      end
    end
  end
  return time, deathTime
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
    local play_time, death_time = self:CalcAttackResultTime(unit.next_target_data.attackInnerBean, actModel, targetActModel)
    self.playTime = self.playTime + play_time
    self.playTime = self.playTime + death_time
    unit.next_target_data = nil
  end
end
def.method("=>", "table").GetNextAction = function(self)
  local cur_round = self:GetRoundData(self.curRound)
  if cur_round == nil or cur_round.playlist == nil or #cur_round.playlist == 0 then
    self.nextAction = nil
    return nil
  end
  local play = cur_round.playlist[1]
  if play == nil then
    return nil
  end
  table.remove(cur_round.playlist, 1)
  return self:UnmarshalAction(play.play_type, play.content)
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
def.method("number", "userdata", "=>", "table").UnmarshalAction = function(self, actionType, octets)
  local action
  if actionType == PlayType.PLAY_SKILL then
    action = PlaySkill.new()
  elseif actionType == PlayType.PLAY_CAPTURE then
    action = PlayCapture.new()
  elseif actionType == PlayType.PLAY_SUMMON then
    action = PlaySummon.new()
  elseif actionType == PlayType.PLAY_ESCAPE then
    action = PlayEscape.new()
  elseif actionType == PlayType.PLAY_TALK then
    action = PlayTalk.new()
  elseif actionType == PlayType.PLAY_TIP then
    action = PlayTip.new()
  elseif actionType == PlayType.PLAY_USEITEM then
    action = PlayUseItem.new()
  elseif actionType == PlayType.PLAY_FIGHTER_STATUS then
    action = PlayFighterStatus.new()
  elseif actionType == PlayType.PLAY_CHANGE_FIGHT_MAP then
    action = PlayChangeFightMap.new()
  elseif actionType == PlayType.PLAY_CHANGE_FIGHTER then
    action = PlayChangeFighter.new()
  elseif actionType == PlayType.PLAY_CHANGE_MODEL then
    action = PlayChangeModel.new()
  elseif actionType == PlayType.PLAY_TEAM_JOIN then
    action = require("netio.protocol.mzm.gsp.fight.PlayTeamJoin").new()
  end
  if action == nil then
    return nil
  end
  Octets.unmarshalBean(octets, action)
  action.actionType = actionType
  return action
end
def.method().OnRoundEnd = function(self)
  if self.rounds then
    local roundnum = 0
    for i = 1, #self.rounds do
      if self.rounds[i].round_num <= self.playingRound then
        roundnum = roundnum + 1
      else
        break
      end
    end
    if roundnum > 0 then
      for i = 1, roundnum do
        table.remove(self.rounds, 1)
      end
    else
      Debug.LogWarning(string.format("[fight]OnRoundEnd(%d), but round data not found", self.playingRound))
    end
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CRoundEnd").new())
  if instance.fightEndPro and self.fightInstanceId:eq(instance.fightEndPro.fight_uuid) then
    local pro = instance.fightEndPro
    instance.fightEndPro = nil
    FightMgr.OnFightEnd(pro)
    return
  end
  for _, v in pairs(self.fightUnits) do
    if v and v.model then
      v:Reset()
    end
  end
  if #self.rounds > 0 then
    local round = self.rounds[1]
    if round.playlist then
      self:PlayNextRound()
    else
      self:DoRoundCommand()
    end
  end
end
def.static("table").OnSFightEnd = function(p)
  if not instance.isInFight then
    instance.proCache = {}
    return
  end
  if instance.fightInstanceId and instance.fightInstanceId:eq(p.fight_uuid) then
    if p.reason == p.END_REASON_TIME_LIMIT then
      local isWin = FightMgr.OnFightEnd(p)
      local tipstr = textRes.Fight[61]
      if not isWin then
        tipstr = textRes.Fight[62]
      end
      Toast(tipstr)
      require("Main.Chat.ChatModule").Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = tipstr})
    elseif p.reason == p.END_REASON_UNKNOWN_ERROR then
      FightMgr.OnFightEnd(p)
      Toast(textRes.Fight[63])
      require("Main.Chat.ChatModule").Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {
        str = textRes.Fight[63]
      })
    elseif instance.rounds == nil or #instance.rounds == 0 or instance.rounds[1].playlist == nil or instance.sceneInfo and instance.sceneInfo.endPlayImmediately and p.reason == p.END_REASON_FORCE_END then
      FightMgr.OnFightEnd(p)
    else
      instance.fightEndPro = p
    end
  end
end
def.method().EndFight = function(self)
  FightMgr.OnFightEnd(nil)
end
def.static("table", "=>", "boolean").OnFightEnd = function(p)
  local myrole = not instance.controllableUnits or instance.controllableUnits[1]
  local isWin = true
  if instance.isSpectator or myrole == nil then
    isWin = true
  else
    isWin = p and (p.result == p.RESULT_ACTIVE_WIN and myrole.team == FightConst.ACTIVE_TEAM or p.result == p.RESULT_ACTIVE_LOSE and myrole.team == FightConst.PASSIVE_TEAM)
  end
  if p and p.reason == p.END_REASON_MAX_ROUND then
    local tip
    if instance.fightType == FIGHT_TYPE.TYPE_PVP then
      if isWin then
        tip = textRes.Fight[17]
      else
        tip = textRes.Fight[18]
      end
    else
      tip = textRes.Fight[16]
    end
    if tip then
      Toast(tip)
    end
  end
  local fight_category = instance.sceneInfo and instance.sceneInfo.battleType or -1
  if require("Main.Login.CrossServerLoginMgr").Instance():IsCrossingServer() and fight_category == FightCategory.LADDER then
    return isWin
  end
  local isMyselfDead = not instance.isSpectator and myrole ~= nil and myrole.isDead > 0
  instance:Reset()
  if not Replayer.Instance().isInFight then
    GUIMan.Instance().m_hudCameraGo2:SetActive(false)
    FxCacheMan.Instance.gameObject.localPosition = EC.Vector3.zero
    Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.ENABLE_MUSIC, {true, false})
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, {
      FightType = instance.fightType,
      Result = isWin,
      IsDead = isMyselfDead,
      Fight_SubType = fight_category
    })
  end
  if instance.proCache and 0 < #instance.proCache then
    instance:ProcessProCache()
  end
  return isWin
end
def.method().Reset = function(self)
  instance.summonPetTimes = 0
  instance.summonChildTimes = 0
  instance.useItemTimes = 0
  instance.isInFight = false
  self.nextAction = nil
  self.waitForTargets = nil
  self.cameraParam = nil
  self.isInUpdate = false
  self.cmdUnitId = 0
  self.roleSkillCache = nil
  self:RemoveJoinTimer()
  if self.playController then
    self.playController:Reset()
  end
  if instance.fightInstanceId then
    local str = instance.fightInstanceId:tostring()
    instance.commandDoneMap[str] = nil
    instance.skillMap[str] = nil
    if instance.spectatorTeamMap then
      instance.spectatorTeamMap[str] = nil
    end
    instance.fightInstanceId = nil
  end
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
  self.shakeParam = nil
  self.itemList = nil
  self.fightLog = nil
  instance.summonedList = nil
  instance.summonedChildList = nil
  instance.actionMap = nil
  instance.sceneInfo = nil
  self.followTarget = nil
  self.groups = nil
  self.teams = nil
  self.controllableUnits = nil
  if instance.requestList then
    for _, v in pairs(instance.requestList) do
      ECFxMan.Instance():Stop(v)
    end
  end
  instance.requestList = nil
  self.playTime = -1
  if tipResume then
    tipResume:HideDlg()
    tipResume = nil
  end
  ECGame.Instance().m_isInFight = Replayer.Instance().isInFight
  ECGame.Instance().m_2DWorldCamObj:SetActive(true)
  if self.isFlyBattle then
    self:SetToGroundMode()
    self.isFlyBattle = false
  end
  Timer:RemoveListener(FightMgr.UpdateRoundTime)
  Timer:RemoveIrregularTimeListener(FightMgr.Update)
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, nil)
  if ECGame.Instance().m_fightCam then
    ECGame.Instance().m_fightCam:SetActive(false)
  end
  if self.formationIcons then
    for k, v in pairs(self.formationIcons) do
      v:Destroy()
      self.formationIcons[k] = nil
    end
    self.formationIcons = nil
  end
  local cam = ECGame.Instance().m_Main3DCam:GetComponent("Camera")
  cam:set_cullingMask(get_cull_mask(ClientDef_Layer.Player) + get_cull_mask(ClientDef_Layer.NPC))
  local worldCamHeight = ECGame.Instance().m_2DWorldCamObj:GetComponent("Camera").orthographicSize
  cam.orthographicSize = worldCamHeight * cam_2d_to_3d_scale
  if self.fightDamageCam and not Replayer.Instance().isInFight then
    self.fightDamageCam:SetActive(false)
  end
  if instance.bgMask then
    instance.bgMask:Destroy()
  end
  instance.bgMask = nil
  if instance.fight_bg then
    instance.fight_bg:Destroy()
  end
  instance.fight_bg = nil
  DlgFight.Instance():Hide()
  instance.fightEndPro = nil
  if instance.isPerspective then
    instance:StopPerspective()
  end
  mainCam.parent = instance.fightPlayerNodeRoot
  if self.fightUnits then
    for k, v in pairs(self.fightUnits) do
      if v and v.model then
        v:Destroy()
      end
      self.fightUnits[k] = nil
    end
    self.fightUnits = nil
  end
  if self.spectators then
    for k, v in pairs(self.spectators) do
      v:Destroy()
      self.spectators[k] = nil
    end
    self.spectators = nil
  end
  if instance.fight3DScene then
    instance.fight3DScene:Destroy()
    instance.fight3DScene = nil
  end
  instance.rounds = nil
  mainCam.parent = nil
  GUIMan.Instance().m_camera.clearFlags = CameraClearFlags.Depth
  GUIMan.Instance().m_hudCamera.clearFlags = CameraClearFlags.Nothing
  ECFxMan.Instance():ResetLODLevel()
  ECGame.Instance():SyncGC()
  ECGame.Instance():GCTLog("fight")
end
def.method("table", "=>", "number").CheckMyTeam = function(self, teamData)
  if self.isSpectator then
    return FightConst.SPECTATOR_TEAM
  else
    local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
    for i, g in pairs(teamData.groups) do
      if g.roleid:eq(myId) then
        return FightConst.PASSIVE_TEAM
      end
    end
  end
  return FightConst.ACTIVE_TEAM
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
  local formationCfg = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfoAtLevel(team.formation, team.formationLevel)
  if formationCfg then
    local resPath = GetIconPath(formationCfg.backIcon)
    if resPath then
      self:LoadFormationIcon(resPath, team.teamId)
    else
      Debug.LogWarning("fight formation get nil record for id: ", formationCfg.backIcon)
    end
  end
  team.formationLevel = teamData.zhenFaLevel
  local i = 1
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  for i, g in pairs(teamData.groups) do
    local group = {}
    group.isControllable = g.roleid:eq(myId)
    group.roleId = g.roleid
    self.groups[i] = group
    for k, v in pairs(g.fighters) do
      self:RemoveFightUnit(k)
      self:CreateFighter(k, v, team.teamId, i)
      if group.isControllable then
        local unit = self:GetFightUnit(k)
        Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, {
          type = unit.fightUnitType,
          hp = unit.hp,
          hpmax = unit.hpmax,
          mp = unit.mp,
          mpmax = unit.mpmax,
          rage = unit.rage,
          ragemax = unit.ragemax
        })
        unit:ResetAction()
      end
    end
    if group.isControllable then
      self.summonPetTimes = constant.FightConst.SUMMON_TIMES - g.summonPettimes
      self.summonChildTimes = constant.CChildrenConsts.child_summon_max - g.summonChldtimes
      self.useItemTimes = constant.FightConst.DRAG_USE_TIMES - g.useitemtimes
      for _, petid in pairs(g.fightedPets) do
        local petidstr = petid:tostring()
        if not table.indexof(self.summonedList, petidstr) then
          table.insert(self.summonedList, petidstr)
        end
      end
      for _, child_id in pairs(g.fightedChilds) do
        local child_id_str = child_id:tostring()
        if not table.indexof(self.summonedList, child_id_str) then
          table.insert(self.summonedList, child_id_str)
        end
      end
    end
  end
end
def.method("number", "table", "number", "number", "=>", FightUnit).CreateFighter = function(self, id, fighter, teamId, groupId)
  local group = self.groups[groupId]
  if group == nil then
    group = {}
    self.groups[groupId] = group
  end
  local unit = self:CreateFightUnit(id, fighter, teamId)
  local hpvisible = self.sceneInfo.enemyHp
  if self.isSpectator then
    local mySpecTeam = instance:GetSpectatorTeam(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId())
    hpvisible = self.sceneInfo.showHpInSpectating and (hpvisible or teamId == mySpecTeam)
  else
    hpvisible = hpvisible or teamId == self.myTeam
  end
  unit.model:SetHpVisible(hpvisible)
  self.teams[teamId]:AddFightUnit(unit)
  if group.isControllable then
    if self.controllableUnits == nil then
      self.controllableUnits = {}
    end
    if fighter.fighter_type == GameUnitType.ROLE then
      self.controllableUnits[1] = unit
    elseif fighter.fighter_type == GameUnitType.PET then
      self.controllableUnits[2] = unit
      local petid = unit.roleId:tostring()
      if not table.indexof(self.summonedList, petid) then
        table.insert(self.summonedList, petid)
      end
    elseif fighter.fighter_type == GameUnitType.CHILDREN then
      self.controllableUnits[2] = unit
      local child_id = unit.roleId:tostring()
      if not table.indexof(self.summonedChildList, child_id) then
        table.insert(self.summonedChildList, child_id)
      end
    end
  end
  if fighter.fighter_type == GameUnitType.ROLE then
    unit.roleId = group.roleId
    group.role = unit
  elseif fighter.fighter_type == GameUnitType.PET or fighter.fighter_type == GameUnitType.CHILDREN then
    unit.roleId = fighter.uuid
    unit.cfgId = fighter.cfgid
    group.pet = unit
    if group.isControllable then
      Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SUMMON_PET, {
        unit_type = fighter.fighter_type,
        unit_id = unit.roleId
      })
    end
  elseif fighter.fighter_type == GameUnitType.FELLOW then
    unit.roleId = fighter.uuid
  elseif fighter.fighter_type == GameUnitType.MONSTER then
    unit.cfgId = fighter.cfgid
  end
  group[unit.id] = unit
  unit.group = groupId
  if self.isFlyBattle then
    unit.flyMount = FlyMount.new()
    unit.flyMount.colorId = fighter.model.extraMap[ModelInfo.AIRCRAFT_COLOR_ID] or 0
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
    FightMgr.OnModelLoaded({
      id = fighterId,
      model = unit.model
    }, nil)
  end
  return unit
end
def.static("table", "table").OnSelectTarget = function(p1, p2)
  if instance:IsCommanderMode() then
    local buffdlg = require("Main.Fight.ui.DlgFightBuff").Instance()
    if buffdlg.unitId == unitId then
      return
    end
    buffdlg:ShowDlg(p1[1], instance)
    return
  end
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, nil)
  local unit = instance:GetCurrentControllable()
  if unit == nil then
    Debug.LogWarning("[Fight](OnSelectTarget)current controllable unit is nil")
    return
  end
  local id = p1[1]
  local target = instance:GetFightUnit(id)
  if target and (unit.actionType == ACT_TYPE.OP_SKILL or unit.actionType == ACT_TYPE.OP_ITEM or unit.actionType == ACT_TYPE.OP_PROTECT) then
    target.model:AddSelectEffect()
  end
  if not instance:IsValidTarget(unit, id) then
    if unit.actionType ~= ACT_TYPE.OP_SKILL or unit.skillId ~= constant.FightConst.ATTACK_SKILL then
      Toast(textRes.Fight[13])
    end
    return
  end
  local act
  if unit.actionType == ACT_TYPE.OP_SKILL then
    act = OpSkill.new(unit.skillId, id)
  elseif unit.actionType == ACT_TYPE.OP_CAPTURE then
    act = OpCapture.new(id)
  elseif unit.actionType == ACT_TYPE.OP_ITEM then
    local itemData = instance.itemList and instance.itemList[unit.skillId]
    if itemData then
      local itemId = itemData.id
      if itemId then
        act = OpItem.new(itemId, id)
      else
        Debug.LogWarning("use item: item id not found: ", unit.skillId)
      end
    end
  elseif unit.actionType == ACT_TYPE.OP_PROTECT then
    act = OpProtect.new(id)
  end
  if act == nil then
    warn("invalid fight action! action type: ", unit.actionType)
    return
  end
  instance:SendCommandProtocol(unit.id, unit.actionType, act)
  instance:ShowAllValidTargets(unit, false)
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
  if unit == nil or instance:IsSpectator(unit) then
    return
  end
  local model = p1 and p1[2]
  if unit.model ~= model then
    return
  end
  local buffdlg = require("Main.Fight.ui.DlgFightBuff").Instance()
  buffdlg:ShowDlg(unitId, instance)
end
def.method(FightUnit).EndTurn = function(self, unit)
  unit.in_turn = false
  DlgFight.Instance():StopCountDown()
  self:NextCommand()
end
def.method().NextCommand = function(self)
  local unit = self:GetCurrentControllable()
  if unit then
    if self.rounds and #self.rounds > 0 then
      DlgFight.Instance():StartCountDown(self.rounds[1].cmd_time)
    end
    self:ShowAllValidTargets(unit, true)
  else
    DlgFight.Instance():StopCountDown()
  end
  DlgFight.Instance():ShowAutoSkill()
end
def.method("table").OnActionEnd = function(self, p1)
  local unit_id = p1[1]
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
  self.playTime = -1
  self.fightLog = nil
  if self.nextAction == nil then
    self:OnRoundEnd()
    return
  end
  self.nextPlay = FightMgr.PlayNext
end
def.method("=>", FightUnit).GetCurrentControllable = function(self)
  if self.controllableUnits then
    for i = 1, #instance.controllableUnits do
      if instance.controllableUnits[i].in_turn then
        return instance.controllableUnits[i]
      end
    end
  end
  return nil
end
def.method("number").RemoveControllableUnit = function(self, id)
  if self.controllableUnits then
    for i = 1, #instance.controllableUnits do
      if instance.controllableUnits[i].id == id then
        instance.controllableUnits[i] = nil
        return
      end
    end
  end
end
def.method(FightUnit, "number", "=>", "boolean").IsValidTarget = function(self, attacker, targetId)
  if self:IsCommanderMode() then
    return true
  end
  if attacker == nil then
    return false
  end
  local oppoTeam = self:GetOpponentTeam(attacker.team)
  local selfTeam = self.teams[attacker.team]
  local target = self.fightUnits[targetId]
  if target == nil or target:IsReallyDead() then
    return false
  end
  if attacker.actionType == ACT_TYPE.OP_PROTECT then
    return selfTeam:IsInTeam(targetId) and not attacker.roleId:eq(target.roleId)
  end
  if attacker.actionType == ACT_TYPE.OP_CAPTURE then
    local isValid = oppoTeam:IsInTeam(targetId)
    if not isValid then
      return false
    end
    if target.fightUnitType ~= GameUnitType.MONSTER then
      return false
    end
    if target.cfgId == 0 then
      return false
    end
    local moncfg = PetInterface.GetMonsterCfg(target.cfgId)
    if moncfg == nil then
      return false
    end
    return moncfg.catchedMonsterId and 0 < moncfg.catchedMonsterId
  end
  local cond1, cond2 = -1, -1
  if attacker.actionType == ACT_TYPE.OP_ITEM then
    local itemData = self.itemList and self.itemList[attacker.skillId]
    if itemData then
      local itemCfg
      local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
      if itemData.type == ItemType.IN_FIGHT_DRUG or itemData.type == ItemType.SUPER_IN_FIGHT_DRUG_ITEM then
        itemCfg = LivingSkillUtility.GetInFightDrugItemInfo(itemData.id)
      elseif itemData.type == ItemType.DRUG_ITEM then
        itemCfg = LivingSkillUtility.GetYaoCaiInfo(itemData.id)
      end
      if itemCfg == nil then
        Debug.LogWarning(string.format("[Fight]get item cfg or caoyao cfg nil: %d", itemData.id))
        return true
      end
      cond1 = itemCfg.targettype1
      cond2 = itemCfg.targettype2
    else
      Debug.LogWarning(string.format("[Fight]no item found in itemlist for idx: %d", attacker.skillId))
    end
  else
    local skillcfg = self:GetSkillCfg(attacker.skillId)
    if skillcfg == nil then
      return true
    end
    if skillcfg.specialType == SkillSpecialType.MARRIAGE then
      local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
      return mateInfo ~= nil and mateInfo.mateId:eq(target.roleId)
    end
    cond1 = skillcfg.skilltargettype1
    cond2 = skillcfg.skilltargettype2
  end
  if cond1 < 0 or cond2 < 0 then
    return true
  end
  local isValid = false
  if 0 < bit.band(cond1, TARGET_TEAM_TYPE.FRIEND_EXCEPT_SELF) then
    isValid = selfTeam:IsInTeam(targetId) and targetId ~= attacker.id
  end
  if 0 < bit.band(cond1, TARGET_TEAM_TYPE.SELF) then
    isValid = isValid or targetId == attacker.id
  end
  if 0 < bit.band(cond1, TARGET_TEAM_TYPE.ENERMY) and not isValid then
    isValid = oppoTeam:IsInTeam(targetId)
  end
  if 0 < bit.band(cond1, TARGET_TEAM_TYPE.ROLE) then
    isValid = isValid or target == self:GetMyHero()
  end
  isValid = isValid and 0 < bit.band(cond2, target.fightUnitType)
  return isValid
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
    if self.controllableUnits then
      for i = 1, #self.controllableUnits do
        if self.controllableUnits[i] == unit then
          if unit.fightUnitType == GameUnitType.PET or unit.fightUnitType == GameUnitType.CHILDREN then
            Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.PET_REMOVED, {
              unit_type = unit.fightUnitType,
              unit_id = unit.roleId
            })
          end
          self.controllableUnits[i] = nil
          break
        end
      end
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
  if self.playTime > 0 then
    self.playTime = self.playTime - tick
    if self.playTime <= 0 then
      Debug.LogWarning("[Fight warning]attack end signal is overdue")
      self:FlushLog()
      if self.waitForTargets then
        for _, tarid in pairs(self.waitForTargets) do
          local target = self:GetFightUnit(tarid)
          if target then
            target:ResetPos()
            target:Reset()
          end
        end
        self.waitForTargets = {}
      end
      self:GoNext()
      if self.isInFight == false then
        return
      end
    end
  end
  if 0 < self.loadModelTime then
    self.loadModelTime = self.loadModelTime - tick
    if 0 >= self.loadModelTime then
      if self.hasLoaded and 0 < #self.hasLoaded then
        Debug.LogWarning("[Fight warning]Model loading is time up")
        for unit_id, unit in pairs(self.fightUnits) do
          local idx = table.indexof(instance.hasLoaded, unit_id)
          if not idx then
            Debug.LogWarning(string.format("unit is not loaded: %s(%d)", unit.name, unit_id))
          end
        end
      end
      self.hasLoaded = nil
      self.loadModelTime = -1
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
  if self.isInFight and self.nextPlay then
    local nextplay = self.nextPlay
    self.nextPlay = nil
    _G.SafeCall(nextplay, self)
  end
  for k, v in pairs(self.pendingOnLoad) do
    if v.obj:FindChild(v.key) and v.callback() then
      self.pendingOnLoad[k] = nil
    end
  end
end
def.static("table", "table").OnModelLoaded = function(p1, p2)
  if not instance.isInFight then
    return
  end
  local unit_id = p1 and p1.id
  if unit_id == nil or instance.fightUnits == nil then
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
  if unit.model and unit.model:IsLoaded() and unit.flyMount and not unit.flyMount:IsLoaded() and not unit.flyMount:IsInLoading() then
    local tw = unit.model.m_model:AddComponent("FlyFightTweener")
    tw:Init(math.random() * 2)
    unit.flyMount:SetParent(unit.model.m_model)
    local respath, isChangeModel
    if unit.fightUnitType == GameUnitType.ROLE then
      local flymountId = unit.model:GetFeijianId()
      if flymountId > 0 then
        local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(flymountId)
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
      local flymountId = group.role and group.role.model:GetFeijianId() or 0
      if flymountId > 0 then
        local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(flymountId)
        if feijianCfg then
          isChangeModel = FightUtils.IsChangeModelFlyMount(feijianCfg.feijianType)
          respath = feijianCfg.modelPath
          local model_info = group.role.model.initModelInfo
          unit.flyMount.colorId = model_info and model_info.extraMap[ModelInfo.AIRCRAFT_COLOR_ID] or 0
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
def.method().LoadFightCommandCfg = function(self)
  if self.commandItems then
    return
  end
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.fight.confbean.CFightCommandCfg.bny")
  local size = DynamicDataTable.GetRecordsCount(entries)
  self.commandItems = {}
  self.commandItems[CmdType.FRIEND] = {}
  self.commandItems[CmdType.ENERMY] = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record == nil then
      return
    end
    local cmd = {}
    cmd.id = record:GetIntValue("id")
    cmd.cmdType = record:GetIntValue("commandType")
    cmd.idx = record:GetIntValue("rank")
    cmd.name = record:GetStringValue("content")
    self.commandItems[cmd.cmdType][cmd.idx] = cmd
  end
  self.commandItems[CmdType.FRIEND].count = #self.commandItems[CmdType.FRIEND]
  self.commandItems[CmdType.ENERMY].count = #self.commandItems[CmdType.ENERMY]
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "number").SetAction = function(self, act, skill)
  local unit = self:GetCurrentControllable()
  if unit == nil then
    Debug.LogWarning("[Fight](SetAction)current controllable unit is nil")
    return
  end
  if act == FightConst.ACTION_COMMAND then
    unit.actionType = act
    unit.skillId = skill
    self:ShowAllValidTargets(unit, true)
    return
  end
  if self.cmdUnitId == unit.id then
    Toast(textRes.Fight[49])
  end
  if skill == constant.FightConst.DEFENCE_SKILL then
    self:SendCommandProtocol(unit.id, ACT_TYPE.OP_SKILL, OpSkill.new(skill, 0))
    return
  end
  if act == ACT_TYPE.OP_ESCAPE then
    self:SendCommandProtocol(unit.id, ACT_TYPE.OP_ESCAPE, OpSkill.new(0, 0))
  else
    unit.actionType = act
    unit.skillId = skill
    self:ShowAllValidTargets(unit, true)
  end
end
def.method("=>", "boolean").IsCommanderMode = function(self)
  local unit = self:GetCurrentControllable()
  if unit == nil then
    return false
  end
  return unit.actionType == FightConst.ACTION_COMMAND
end
def.method("number", "userdata").Summon = function(self, act, id)
  local unit = self:GetCurrentControllable()
  if unit == nil then
    return
  end
  local cmd
  if act == ACT_TYPE.OP_SUMMON_PET then
    cmd = OpSummonPet.new(id)
  elseif act == ACT_TYPE.OP_SUMMON_CHILD then
    cmd = OpSummonChild.new(id)
  end
  self:SendCommandProtocol(unit.id, act, cmd)
end
def.method(FightUnit, "boolean").ShowAllValidTargets = function(self, unit, isShow)
  if unit == nil then
    return
  end
  for k, v in pairs(self.fightUnits) do
    if v and v.model then
      if isShow and self:IsValidTarget(unit, v.id) then
        v:ShowSelect()
      else
        v:HideSelect()
      end
    end
  end
end
def.method("number", "number", "table").SendCommandProtocol = function(self, unitId, cmdType, cmd)
  local octets = Octets.rawFromBean(cmd)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.COperateReq").new(unitId, cmdType, octets))
  self.cmdUnitId = unitId
end
def.method().LoadTemplate = function(self)
  GameUtil.AsyncLoad(RESPATH.DAMAGELABEL, function(panel)
    self.damageTemplate = panel
  end)
  GameUtil.AsyncLoad(RESPATH.FIGHT_DAMAGE_ANIM, function(ani)
    self.damageAnim = ani
  end)
  GameUtil.AsyncLoad(RESPATH.FIGHT_SELECT_TEXTURE, function(tex)
    self.selectTexture = tex
  end)
end
def.method().PreLoadRes = function(self)
  local resList = {
    RESPATH.FONT_DIGITAL_RED,
    RESPATH.FONT_DIGITAL_GREEN,
    RESPATH.FONT_DIGITAL_YELLOW,
    RESPATH.FONT_DIGITAL_BLUE,
    RESPATH.FONT_DIGITAL_CRIT,
    RESPATH.FONT_DIGITAL_CRIT_CURE
  }
  AsyncLoadArray(resList, function(fonts)
    if self.fonts == nil then
      self.fonts = {}
    end
    self.fonts[FightConst.NUMBER_COLOR.RED] = fonts[1]:GetComponent("UIFont")
    self.fonts[FightConst.NUMBER_COLOR.GREEN] = fonts[2]:GetComponent("UIFont")
    self.fonts[FightConst.NUMBER_COLOR.YELLOW] = fonts[3]:GetComponent("UIFont")
    self.fonts[FightConst.NUMBER_COLOR.BLUE] = fonts[4]:GetComponent("UIFont")
    self.fonts[FightConst.NUMBER_COLOR.CRIT] = fonts[5]:GetComponent("UIFont")
    self.fonts[FightConst.NUMBER_COLOR.CRIT_CURE] = fonts[6]:GetComponent("UIFont")
  end)
  FightUtils.LoadSkillActionCfg()
  FightUtils.LoadEffectPlayCfg()
end
def.method("=>", "number").GetAutoSkill = function(self)
  if self.role_default_skill > 0 then
    return self.role_default_skill
  end
  return constant.FightConst.ATTACK_SKILL
end
def.method("userdata", "=>", "number").GetPetAutoSkill = function(self, petid)
  if self.pet_default_skill == nil or self.pet_default_skill[petid:tostring()] == nil then
    return constant.FightConst.ATTACK_SKILL
  end
  return self.pet_default_skill[petid:tostring()]
end
def.method("number").SetAutoSkill = function(self, skillId)
  local roleId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CChangeDefaultSkillReq").new(roleId, Int64.new(0), skillId, GameUnitType.ROLE))
end
def.method("userdata", "number").SetPetAutoSkill = function(self, petId, skillId)
  local roleId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CChangeDefaultSkillReq").new(roleId, petId, skillId, GameUnitType.PET))
end
def.method("userdata", "number").SetChildAutoSkill = function(self, childId, skillId)
  local roleId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CChangeDefaultSkillReq").new(roleId, childId, skillId, GameUnitType.CHILDREN))
end
def.method("boolean").SetAutoFightStatus = function(self, isAuto)
  local autoStatus = AutoConst.AUTO_STATE__OPERATE
  if isAuto then
    autoStatus = AutoConst.AUTO_STATE__AUTO
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CSetAutoStateReq").new(autoStatus))
end
def.method("number", "=>", "table").GetSkillCfg = function(self, id)
  if self.skillCfgCache and self.skillCfgCache[id] then
    return self.skillCfgCache[id]
  end
  local cfg = GetSkillCfg(id)
  if self.skillCfgCache == nil then
    self.skillCfgCache = {}
  end
  self.skillCfgCache[id] = cfg
  return cfg
end
def.static("table").OnSFightNormalResult = function(p)
  local tip
  if p.result == p.PLAYER_CAN_NOT_INFIGHT then
    tip = string.format(textRes.Fight[15], unpack(p.args))
  elseif p.result == p.PLAYER_FIGHT_END then
    tip = string.format(textRes.Fight[36])
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.WATCH_FAILED, nil)
  elseif p.result == p.PLAYER_IN_FIGHT then
    tip = string.format(textRes.Fight[37])
  elseif p.result == p.OBSERVER_TO_MAX then
    tip = string.format(textRes.Fight[38])
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.WATCH_FAILED, nil)
  elseif p.result == p.COMMAND_NANE_WRONG or p.result == p.COMMAND_NANE_SENSITIVE then
    tip = string.format(textRes.Fight[39])
  elseif p.result == p.OBERVER_FIGHT_FAIL_NOT_IN_SAME_WORLD then
    tip = string.format(textRes.Fight[40])
  elseif p.result == p.OBSERVE_FIGHT_NOT_EXIST then
    tip = string.format(textRes.Fight[52])
  end
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSSelectOperateBrd = function(p)
  if not gmodule.moduleMgr:GetModule(ModuleId.LOGIN):IsInWorld() then
    if not instance.isInFight and not instance.isCacheProcessing then
      table.insert(instance.proCache, {
        pro = p,
        func = FightMgr.OnSSelectOperateBrd
      })
    end
    return
  end
  local unit = instance:GetFightUnit(p.fighterid)
  if unit then
    if instance.rounds and #instance.rounds <= 1 then
      unit:SetReady(true)
    else
      local round = instance.rounds[2]
      if round.readyList == nil then
        round.readyList = {}
      end
      table.insert(round.readyList, p.fighterid)
    end
    instance:ShowCommandTip(unit, p.op_type, p.content, p.auto == 1)
  end
end
def.method(FightUnit, "number", "userdata", "boolean").ShowCommandTip = function(self, unit, cmd_type, content, isAuto)
  if self.sceneInfo == nil or not self.sceneInfo.isShowCmdTip then
    return
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_FIGHT_FRIEND_OPTION_TIP) then
    return
  end
  local msg = ""
  local unitname = unit.name
  if unit.fightUnitType == GameUnitType.PET then
    local group = self.groups[unit.group]
    local master = group.role
    unitname = string.format(textRes.Fight[72], master.name)
  elseif unit.fightUnitType == GameUnitType.CHILDREN then
    local group = self.groups[unit.group]
    local master = group.role
    unitname = string.format(textRes.Fight[73], master.name)
  end
  local function GetTargetName(targetId)
    local main_target = self:GetFightUnit(targetId)
    local targetname
    if main_target.team == self.myTeam then
      targetname = string.format(textRes.Fight[79], main_target.name)
    else
      targetname = string.format(textRes.Fight[78], main_target.name)
    end
    return targetname
  end
  if cmd_type == ACT_TYPE.OP_SKILL then
    local op = OpSkill.new()
    Octets.unmarshalBean(content, op)
    local skillCfg = self:GetSkillCfg(op.skill)
    if op.skill == constant.FightConst.DEFENCE_SKILL then
      local skill_name = string.format(textRes.Fight[69], skillCfg.name)
      msg = string.format(textRes.Fight[70], unitname, skill_name)
    else
      local skill_name = string.format(textRes.Fight[68], skillCfg.name)
      if isAuto then
        msg = string.format(textRes.Fight[70], unitname, skill_name)
      else
        local targetName = GetTargetName(op.main_target)
        msg = string.format(textRes.Fight[71], unitname, targetName, skill_name)
      end
    end
  elseif cmd_type == ACT_TYPE.OP_ITEM then
    local op = OpItem.new()
    Octets.unmarshalBean(content, op)
    local ItemUtils = require("Main.Item.ItemUtils")
    local itemBase = ItemUtils.GetItemBase2(op.item_cfgid)
    local targetName = GetTargetName(op.main_target)
    msg = string.format(textRes.Fight[74], unitname, targetName, itemBase.name)
  elseif cmd_type == ACT_TYPE.OP_SUMMON_PET then
    local op = OpSummonPet.new()
    Octets.unmarshalBean(content, op)
    msg = string.format(textRes.Fight[75], unitname, itemName)
  elseif cmd_type == ACT_TYPE.OP_SUMMON_CHILD then
    local op = OpSummonChild.new()
    Octets.unmarshalBean(content, op)
    msg = string.format(textRes.Fight[76], unitname, itemName)
  elseif cmd_type == ACT_TYPE.OP_PROTECT then
    local op = OpProtect.new()
    Octets.unmarshalBean(content, op)
    local targetName = GetTargetName(op.target)
    local cmd_name = string.format(textRes.Fight[69], textRes.Fight[21])
    msg = string.format(textRes.Fight[71], unitname, targetName, cmd_name)
  elseif cmd_type == ACT_TYPE.OP_CAPTURE then
    local op = OpCapture.new()
    Octets.unmarshalBean(content, op)
    local targetName = GetTargetName(op.target)
    local cmd_name = string.format(textRes.Fight[69], textRes.Fight[22])
    msg = string.format(textRes.Fight[71], unitname, targetName, cmd_name)
  elseif cmd_type == ACT_TYPE.OP_ESCAPE then
    local cmd_name = string.format(textRes.Fight[69], textRes.Fight[67])
    msg = string.format(textRes.Fight[70], unitname, cmd_name)
  end
  if isAuto then
    msg = textRes.Fight[77] .. msg
  end
  Toast(msg)
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
  if #srcList > 1 then
    idx = math.random(#srcList)
  end
  local bgId = srcList[idx]
  return bgId or 0
end
def.method("number").PlaySoundEffect = function(self, soundid)
  if self.soundEnable then
    self:DoPlaySoundEffect(soundid)
  end
end
def.method("number").DoPlaySoundEffect = function(self, soundid)
  local path = SoundData.Instance():GetSoundPath(soundid)
  if path then
    if self.fightSoundTypeId <= 0 then
      self.fightSoundTypeId = FightMgr.FightSoundTypeId_Min
    end
    local sound_type = SOUND_TYPES.FIGHT .. self.fightSoundTypeId
    self.fightSoundTypeId = self.fightSoundTypeId + 1
    if self.fightSoundTypeId > FightMgr.FightSoundTypeId_Max then
      self.fightSoundTypeId = FightMgr.FightSoundTypeId_Min
    end
    ECSoundMan.Instance():Play2DSoundEx(path, sound_type, 10)
  end
end
local init_2d_orthographicSize = 0
def.method("number", "number").SetShakeParam = function(self, id, delay)
  if init_2d_orthographicSize == 0 then
    init_2d_orthographicSize = ECGame.Instance().m_2DWorldCamObj:GetComponent("Camera").orthographicSize
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
    local fightCam = game.m_fightCam and game.m_fightCam:GetComponent("Camera")
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
  if cameraCfg.skillNameEff > 0 then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SHOW_UI_EFFECT, {
      cameraCfg.skillNameEff
    })
  end
  if cameraCfg.cameraAnimId and 0 < cameraCfg.cameraAnimId then
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
    local fightCam = ECGame.Instance().m_fightCam
    if fightCam then
      fightCam:SetActive(false)
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
  ECGame.Instance().m_2DWorldCamObj:SetActive(true)
  gmodule.moduleMgr:GetModule(ModuleId.MAP).mapNodeRoot:SetActive(true)
  local fightCam = ECGame.Instance().m_fightCam
  if fightCam then
    fightCam:SetActive(true)
  end
  self.isPerspective = false
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  instance:ProcessProCache()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  require("Main.Fight.ui.DlgPrelude").Instance():Hide()
  instance.proCache = {}
  instance.isCacheProcessing = false
  if instance.isInFight then
    instance:Reset()
  end
  instance.role_default_skill = 0
  instance.role_shortcut_skill = 0
  instance.pet_default_skill = nil
  instance.pet_shortcut_skill = nil
  instance.child_default_skill = nil
  instance.child_shortcut_skill = nil
  instance.commandItems = nil
  require("Main.Fight.ui.DlgFunctionBtns").Instance():Hide()
end
def.method().PreloadEffects = function(self)
  local cur_count = 0
  local i = 0
  if self.preloadList == nil then
    self.preloadList = {}
  end
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.util.confbean.CEffectPreload.bny")
  local size = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record == nil then
      return
    end
    local effId = record:GetIntValue("effectid")
    local effres = GetEffectRes(effId)
    if self.fxCacheList[effres.path] == nil then
      table.insert(self.preloadList, effres.path)
    else
      cur_count = cur_count + 1
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local effcount = #self.preloadList
  if effcount == 0 then
    LoadingMgr.Instance():UpdateTaskProgress(LoginPreloadMgr.PreloadResType.EFFECT, 1)
    return
  end
  if effcount > 0 then
    if cur_count > 0 then
      LoadingMgr.Instance():UpdateTaskProgress(LoginPreloadMgr.PreloadResType.EFFECT, cur_count / effcount)
    end
    do
      local function OnloadFinish(name, succ)
        cur_count = cur_count + 1
        LoadingMgr.Instance():UpdateTaskProgress(LoginPreloadMgr.PreloadResType.EFFECT, cur_count / effcount)
        if cur_count < effcount then
          FxCacheMan.RegLoadFinishFunc(OnloadFinish)
        end
      end
      FxCacheMan.RegLoadFinishFunc(OnloadFinish)
    end
  end
  self.preloadTick = 0
end
def.method("number").LoadEffectList = function(self, tick)
  if self.preloadTick < 0 then
    return
  end
  self.preloadTick = self.preloadTick - tick
  if self.preloadTick <= 0 then
    if self.preloadList == nil or #self.preloadList == 0 then
      Timer:RemoveListener(FightMgr.LoadEffectList)
      return
    end
    local res = self.preloadList[1]
    table.remove(self.preloadList, 1)
    self:LoadEffectCache(res)
    self.preloadTick = 0
  end
end
def.method("number", "=>", "boolean").IsMyUnit = function(self, fighterId)
  if self.controllableUnits then
    for _, v in pairs(self.controllableUnits) do
      if v.id == fighterId then
        return true
      end
    end
  end
  return false
end
def.method("number", "=>", "boolean").IsMyHero = function(self, fighterId)
  if self.controllableUnits == nil or self.controllableUnits[1] == nil then
    return false
  end
  return self.controllableUnits[1].id == fighterId
end
def.method("=>", FightUnit).GetMyHero = function(self)
  return self.controllableUnits and self.controllableUnits[1]
end
def.method("=>", FightUnit).GetMyPet = function(self)
  return self.controllableUnits and self.controllableUnits[2]
end
def.method("=>", "userdata").GetCurrentPetId = function(self)
  local pet = self:GetMyPet()
  if pet then
    return pet.roleId
  else
    return nil
  end
end
def.method("=>", "table").GetHpMpInfo = function(self)
  local result = {}
  if self.controllableUnits then
    for _, v in pairs(self.controllableUnits) do
      local info = {}
      info.type = v.fightUnitType
      info.hp = v.hp
      info.mp = v.mp
      info.hpmax = v.hpmax
      info.mpmax = v.mpmax
      info.rage = v.rage
      info.ragemax = v.ragemax
      table.insert(result, info)
    end
  end
  return result
end
def.method("=>", "boolean").IsObserverMode = function(self)
  return self.isSpectator
end
def.method(FightUnit, "=>", "boolean").IsSpectator = function(self, unit)
  if unit.roleId == nil then
    return false
  end
  return self.spectators[unit.roleId:tostring()] ~= nil
end
def.static("table").OnSSynRoleObserveType = function(p)
  if instance.spectatorTeamMap == nil then
    instance.spectatorTeamMap = {}
  end
  instance.spectatorTeamMap[p.fight_uuid:tostring()] = p.teamType
  if instance.isInFight and instance.fightInstanceId and instance.fightInstanceId:eq(p.fight_uuid) then
    instance:SetSpectatorView()
  end
end
def.method().SetSpectatorView = function(self)
  if instance.isSpectator and instance.fightType == FIGHT_TYPE.TYPE_PVP then
    local myteam = instance:GetSpectatorTeam(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId())
    for _, u in pairs(instance.fightUnits) do
      u.model:SetHpVisible(u.team == myteam)
    end
  end
end
def.method("table", "number", "number", "number", "number").CreateSpectator = function(self, info, posx, posy, dir, posnum)
  local name = info.name
  local modelId = info.model.modelid
  local nameColor = GetColorData(701300000)
  local role = FightSpectator.new(modelId, name, nameColor, 0)
  if role then
    role.defaultParentNode = self.fightPlayerNodeRoot
    role.pos = posnum
    local modelPath, modelColor = GetModelPath(modelId)
    role.roleId = info.observerid
    role.colorId = modelColor
    role:LoadModelInfo(info.model)
    _G.LoadModel(role, info.model, posx, posy, dir, false, true)
    role:SetHpVisible(false)
    role:SetShowModel(true)
    if self.isFlyBattle then
      role.flyMount = FlyMount.new()
      self:LoadSpectatorFlyMount(role)
    end
    self.spectators[info.observerid:tostring()] = role
  end
end
def.static("table").OnSSynAddObserver = function(p)
  if not instance.isInFight and not instance.isCacheProcessing then
    table.insert(instance.proCache, {
      pro = p,
      func = FightMgr.OnSSynAddObserver
    })
    return
  end
  if p.observer then
    if instance.spectators == nil then
      return
    end
    local obsvId = p.observer.observerid:tostring()
    if instance.spectators[obsvId] then
      return
    end
    local count = table.nums(instance.spectators)
    if count < FightMgr.MAX_OBSERVER_NUM then
      local posidx = instance:GetAvailablePos()
      if posidx <= 0 then
        return
      end
      local pos = FightConst.ObserverPos[posidx]
      local idx = math.floor((posidx + FightMgr.MAX_OBSERVER_NUM / 2 - 1) / FightMgr.MAX_OBSERVER_NUM) + 1
      local dir = FightConst.ObserverDir[idx]
      instance:CreateSpectator(p.observer, pos.x, pos.y, dir, posidx)
    end
  end
end
def.method("=>", "number").GetAvailablePos = function(self)
  local poses = {
    1,
    2,
    3,
    4,
    5,
    6
  }
  for _, v in pairs(self.spectators) do
    local idx = table.indexof(poses, v.pos)
    if idx then
      table.remove(poses, idx)
    end
  end
  return poses[1] or 0
end
def.static("table").OnSSynObserveEnd = function(p)
  if not instance.isInFight and not instance.isCacheProcessing then
    table.insert(instance.proCache, {
      pro = p,
      func = FightMgr.OnSSynObserveEnd
    })
    return
  end
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  myId = myId and myId:tostring()
  for _, id in pairs(p.roleids) do
    local k = id:tostring()
    if k == myId and instance.isSpectator then
      FightMgr.OnFightEnd(nil)
      return
    end
    local role = instance.spectators and instance.spectators[k]
    if role then
      role:Destroy()
      instance.spectators[k] = nil
    end
  end
end
def.method("=>", "boolean").IsLastRound = function(self)
  local ret = self.curRound == self.curServerRound
  if not ret then
    return ret
  end
  local round = self:GetRoundData(self.curRound)
  return round ~= nil and round.playlist ~= nil and #round.playlist <= 0
end
def.method().SetAdaptedPos = function(self)
  local game = ECGame.Instance()
  local w = game.m_2DWorldCam.orthographicSize * 2 * game.m_2DWorldCam.aspect
  local offset = (w - 960) / 2
  if offset <= 0 or 0 < self.adaptOffset then
    return
  end
  self.adaptOffset = offset
  local all_pos = {
    FightConst.FightPos,
    FightConst.PET_BATTLE_POS
  }
  for _, FightPos in pairs(all_pos) do
    for team = 1, 2 do
      local flag = math.pow(-1, team + 1)
      local tp = {}
      table.insert(tp, FightPos[team].Pos)
      table.insert(tp, FightPos[team].Attackpos_ahead)
      table.insert(tp, FightPos[team].Attackpos_front)
      table.insert(tp, FightPos[team].ProtectPos)
      table.insert(tp, FightPos[team].FarPos)
      for i = 1, #tp do
        local subtp = tp[i]
        for _, v in pairs(subtp) do
          v.x = v.x + self.adaptOffset * flag
        end
      end
      FightPos[team].Attack_center.x = FightPos[team].Attack_center.x + self.adaptOffset * flag
      FightPos[team].Left.x = FightPos[team].Left.x + self.adaptOffset * flag
      FightPos[team].Right.x = FightPos[team].Right.x + self.adaptOffset * flag
    end
  end
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
def.method("=>", "boolean").IsAutoFight = function(self)
  return self.auto_fight_status
end
def.method("string").LoadEffectRes = function(self, respath)
  if self.requestList and self.requestList[respath] ~= nil then
    return
  end
  if self.requestList == nil then
    self.requestList = {}
  end
  self.requestList[respath] = GameUtil.RequestFx(respath, 1)
end
local PrePlayPos = EC.Vector3.new(-10000, 0, -10000)
def.method("string").LoadEffectCache = function(self, respath)
  if self.fxCacheList[respath] then
    return
  end
  local fx = GameUtil.RequestFx(respath, 0)
  self.fxCacheList[respath] = {fx = fx}
  self:PlayEffect(respath, nil, PrePlayPos, Quaternion.identity)
end
def.method("string", "=>", "userdata").GetEffectFx = function(self, respath)
  local fx = self.requestList and self.requestList[respath]
  if fx == nil then
    self:LoadEffectRes(respath)
  end
  return self.requestList[respath]
end
def.method("string").RemoveEffectFxFromCache = function(self, respath)
  if self.requestList then
    self.requestList[respath] = nil
  end
end
def.static("table", "table").OnUnitTalk = function(p1, p2)
  local roleId = p1 and p1.roleId
  if roleId == nil then
    return
  end
  local unit = instance:GetFightUnitByRoleId(roleId)
  if unit then
    if p1.bubbleName == nil or p1.arrowName == nil then
      unit.model:Talk(p1.content, 0)
    else
      unit.model:TalkWithCustomeBubble(p1.content, 0, p1.bubbleName, p1.arrowName)
    end
  else
    local spectator = instance.spectators and instance.spectators[roleId:tostring()]
    if spectator then
      if p1.bubbleName == nil or p1.arrowName == nil then
        spectator:Talk(p1.content, 0)
      else
        spectator:TalkWithCustomeBubble(p1.content, 0, p1.bubbleName, p1.arrowName)
      end
    end
  end
end
def.method(FightUnit, "number", "number", "number", "=>", "boolean").CheckSkillRequirement = function(self, unit, skillId, skillLevel, count)
  local unitlevel = unit and unit.level or 1
  local costInfo = SkillUtility.GetSkillCostInfo(skillId, skillLevel, unitlevel)
  if costInfo == nil then
    return true
  end
  if count > 0 and self:IsMyHero(unit.id) then
    local usedData = unit.skillUsedData[skillId]
    local used = usedData and usedData.skillUseCount or 0
    if count <= used then
      return false
    end
  end
  local ret = true
  if costInfo.reqList then
    for k, v in pairs(costInfo.reqList) do
      if k == ConditionType.NONE then
        ret = ret and true
      elseif k == ConditionType.HP_PERCENT_BIG_THAN then
        ret = ret and unit.hp / unit.hpmax >= v / 10000
      elseif k == ConditionType.HP_PERCENT_SMALL_THAN then
        ret = ret and unit.hp / unit.hpmax <= v / 10000
      elseif k == ConditionType.MP_PERCENT_BIG_THAN then
        ret = ret and unit.mp / unit.mpmax >= v / 10000
      elseif k == ConditionType.MP_PERCENT_SMALL_THAN then
        ret = ret and unit.mp / unit.mpmax <= v / 10000
      end
      if not ret then
        return false
      end
    end
  end
  if costInfo.costList then
    for k, v in pairs(costInfo.costList) do
      if k == CostType.NONE then
        ret = ret and true
      elseif k == CostType.HP then
        ret = ret and v <= unit.hp
      elseif k == CostType.HPRATE then
        ret = ret and unit.hp / unit.hpmax >= v / 10000
      elseif k == CostType.MP then
        ret = ret and v <= unit.mp
      elseif k == CostType.MPRATE then
        ret = ret and unit.mp / unit.mpmax >= v / 10000
      elseif k == CostType.ANGER then
        ret = ret and v <= unit.rage
      elseif k == CostType.ANGERRATE then
        ret = ret and unit.rage / unit.ragemax >= v / 10000
      elseif k == CostType.HPFIX then
        ret = ret and v <= unit.hp
      end
      if not ret then
        return false
      end
    end
  end
  return ret
end
def.method("table").CheckIsSpectator = function(self, p)
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  for _, v in pairs(p.fight.observers) do
    if v.observerid:eq(myId) then
      self.isSpectator = true
      return
    end
  end
  local groups = p.fight.active_team.groups
  for _, v in pairs(groups) do
    if v.roleid:eq(myId) then
      self.isSpectator = false
      return
    end
  end
  groups = p.fight.passive_team.groups
  for _, v in pairs(groups) do
    if v.roleid:eq(myId) then
      self.isSpectator = false
      return
    end
  end
  self.isSpectator = true
  return
end
def.method(FightUnit, "number", "=>", "boolean").CheckCameraVisible = function(self, unit, vt)
  if self:IsObserverMode() then
    return true
  end
  local VT = require("consts.mzm.gsp.skill.confbean.RotateVisiableType")
  local myRole = self.controllableUnits and self.controllableUnits[1]
  if myRole == nil then
    return true
  end
  if vt == VT.ALL then
    return true
  elseif vt == VT.FRIEND then
    return unit.team == myRole.team
  elseif vt == VT.ENERMY then
    return unit.team ~= myRole.team
  elseif vt == VT.SELF then
    return unit.roleId:eq(myRole.roleId)
  end
end
def.method("=>", "table").GetRoleSkillList = function(self)
  if self.skillMap == nil then
    return nil
  end
  local k = self.fightInstanceId and self.fightInstanceId:tostring()
  if k == nil then
    return
  end
  local skillList = self.skillMap[k]
  local skills = skillList and skillList.roleSkills
  if skills == nil then
    Debug.LogWarning("[FightError]GetRoleSkillList return nil")
    return nil
  end
  local me = self:GetMyHero()
  if me == nil then
    return skills
  end
  local skills_state = FightUtils.GetSkillStateCfg(me.state_group)
  if skills_state == nil then
    return skills
  end
  local enable_skills = {}
  local OracleData = require("Main.Oracle.data.OracleData")
  local skillId = 0
  for k, v in pairs(skills) do
    skillId = OracleData.Instance():GetOriginSkillId(k)
    if skillId == 0 then
      skillId = k
    end
    if skills_state[skillId] == nil or table.indexof(skills_state[skillId], me.state) then
      enable_skills[k] = skills[k]
    end
  end
  return enable_skills
end
def.method("=>", "table").GetPetSkillList = function(self)
  if self.skillMap == nil then
    return nil
  end
  local k = self.fightInstanceId and self.fightInstanceId:tostring()
  if k == nil then
    return
  end
  local skillList = self.skillMap[k]
  return skillList and skillList.petSkills
end
def.method("=>", "table").GetChildSkillList = function(self)
  if self.skillMap == nil then
    return nil
  end
  local k = self.fightInstanceId and self.fightInstanceId:tostring()
  if k == nil then
    return
  end
  local skillList = self.skillMap[k]
  return skillList and skillList.childrenSkills
end
def.static("table").OnSSynCommandRes = function(p)
  local unit = instance:GetFightUnit(p.commandFighterid)
  local target = instance:GetFightUnit(p.beCommandedFighterid)
  if unit and target then
    local str = string.format(textRes.Fight[44], unit.name, target.name, p.commandName)
    gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendSystemMsg(ChatMsgData.System.FIGHT, HtmlHelper.Style.Fight, {content = str})
    target:SetCommand(p.commandName)
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.UPDATE_COMMAND, nil)
  end
end
def.static("table").OnSSynRemCommandRes = function(p)
  local unit = instance:GetFightUnit(p.fighterid)
  if unit then
    unit:RemoveCommand()
  end
end
def.static("table").OnSCommandChangeRes = function(p)
  local cmds = instance.commandItems[p.commandType]
  local cmd = cmds[p.commandIndex + 1 + cmds.count]
  if cmd == nil then
    cmd = {}
    cmd.cmdType = p.commandType
    cmd.idx = p.commandIndex + 1 + cmds.count
    cmds[cmd.idx] = cmd
  end
  cmd.name = p.commandName
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.UPDATE_COMMAND, nil)
end
def.static("table").OnSynCommandInfos = function(p)
  if instance.commandItems == nil then
    instance:LoadFightCommandCfg()
  end
  local cmds = instance.commandItems[CmdType.FRIEND]
  local num = #p.commandFriendInfos
  for i = 1, 3 do
    if i <= num then
      local cmd = {}
      cmd.cmdType = CmdType.FRIEND
      cmd.idx = cmds.count + i
      cmd.name = p.commandFriendInfos[i]
      cmds[cmd.idx] = cmd
    else
      cmds[cmds.count + i] = nil
    end
  end
  cmds = instance.commandItems[CmdType.ENERMY]
  num = #p.commandEnermyInfos
  for i = 1, 3 do
    if i <= num then
      local cmd = {}
      cmd.cmdType = CmdType.ENERMY
      cmd.idx = cmds.count + i
      cmd.name = p.commandEnermyInfos[i]
      cmds[cmd.idx] = cmd
    else
      cmds[cmds.count + i] = nil
    end
  end
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.UPDATE_COMMAND, nil)
end
def.static("table").OnSDelCommandReq = function(p)
  local cmds = instance.commandItems[p.commandType]
  cmds[p.commandIndex + 1 + cmds.count] = nil
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.UPDATE_COMMAND, nil)
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
def.static("table", "table").OnSettingChanged = function(params)
  local id = params[1]
  if id == SystemSettingModule.SystemSetting.NO_SKILL_VOICE then
    local setting = SystemSettingModule.Instance():GetSetting(id)
    instance.playVoice = not setting.isEnabled
  end
end
def.method("string").AddLog = function(self, content)
  if self.fightLog == nil then
    self.fightLog = {}
  end
  self.fightLog[#self.fightLog + 1] = content
end
def.method().FlushLog = function(self)
  if self.fightLog == nil then
    return
  end
  Debug.LogWarning("flush fight log: ", #self.fightLog)
  for i = 1, #self.fightLog do
    Debug.LogWarning(self.fightLog[i])
  end
  Debug.LogWarning("flush fight log end")
  self.fightLog = nil
end
def.method(FightUnit, "table", "=>", "number").CalcPlayTime = function(self, unit, action)
  local time = 0
  local actModel = unit.masterModel or unit.model
  if action.actionType == PlayType.PLAY_SKILL then
    if action.skillplayType == action.LIAN_XIE_JI then
      time = time + FightConst.PLAY_TIME.LIAN_XIE_JI
    end
    time = time + self:CalcSkillTime(unit, action.skill)
  elseif action.actionType == PlayType.PLAY_CAPTURE then
    time = time + actModel:GetAniDuration(ActionName.Magic) + (FightConst.PLAY_TIME.RETURN_POS + FightConst.PLAY_TIME.CALLBACK_DELAY) * 2
  elseif action.actionType == PlayType.PLAY_SUMMON or action.actionType == PlayType.PLAY_CHANGE_FIGHTER or action.actionType == PlayType.PLAY_CHANGE_MODEL then
    time = time + actModel:GetAniDuration(ActionName.Magic)
  elseif action.actionType == PlayType.PLAY_ESCAPE then
    local success = action.suc == require("netio.protocol.mzm.gsp.fight.PlayEscape").SUCCESS
    local escapeDuration = constant.FightConst.ESCAPE_ACTION_TIME / 1000
    time = time + escapeDuration
    if success then
      time = time + escapeDuration + FightConst.PLAY_TIME.CALLBACK_DELAY
    end
  elseif action.actionType == PlayType.PLAY_TALK then
    local duration = constant.FightConst.WORDS_DURATION / 1000
    local endDelay = constant.FightConst.WORDS_ROUND_TIME / 1000
    time = time + duration + endDelay
  end
  return time
end
def.method(FightUnit, "number", "=>", "number").CalcSkillTime = function(self, unit, skillId)
  local time = 0
  local actModel = unit.masterModel or unit.model
  local skillcfg = self:GetSkillCfg(skillId)
  if skillcfg == nil then
    return time
  end
  local playcfg = FightUtils.GetSkillPlayCfg(skillcfg.skillPlayid)
  if playcfg == nil then
    return time
  end
  if skillId == constant.FightConst.DEFENCE_SKILL then
    return time
  end
  for i = 1, #playcfg.phases do
    local phase = playcfg.phases[i]
    if phase then
      if 0 < phase[2] then
        local actionPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phase[2])
        if actionPhaseCfg == nil then
          return time
        end
        local effduration = 0
        if actionPhaseCfg.effects then
          for j = 1, #actionPhaseCfg.effects do
            local v = actionPhaseCfg.effects[j]
            if 0 > v.delay then
              v.delay = actionCfg.effectDelays and actionCfg.effectDelays[j] or 0
            end
            local effPlay = FightUtils.GetEffectPlayCfg(unit.modelId, v.effectId)
            if effPlay then
              local duration = effPlay.duration
              if 0 < v.delay then
                duration = duration + v.delay
              end
              if effduration < duration then
                effduration = duration
              end
            end
          end
        end
        local actionCfg = FightUtils.GetSkillActionCfg(unit.modelId, actionPhaseCfg.action)
        if actionCfg then
          local actionTime = actModel:GetAniDuration(actionCfg.actionName)
          if effduration < actionTime then
            effduration = actionTime
          end
        end
        time = time + effduration + FightConst.PLAY_TIME.CALLBACK_DELAY
      end
      if 0 < phase[1] then
        local movePhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phase[1])
        if movePhaseCfg then
          local moveAction = FightUtils.GetMoveActionCfg(movePhaseCfg.action)
          if moveAction then
            time = time + moveAction.duration
          end
        end
      end
    end
  end
  if playcfg.returnStage and 0 < playcfg.returnStage then
    local returnPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(playcfg.returnStage)
    if returnPhaseCfg then
      local moveAction = FightUtils.GetMoveActionCfg(returnPhaseCfg.action)
      if moveAction then
        time = time + moveAction.duration
      end
    end
  end
  return time
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
  game.m_Main3DCamComponent.orthographicSize = game.m_scale3d
  if game.m_cloudCam then
    local cam = game.m_cloudCam:GetComponent("Camera")
    cam.depth = CameraDepth.CLOUD_DOWN
  end
  local x, y
  local w = game.m_2DWorldCam.orthographicSize * game.m_2DWorldCam.aspect
  if w > game.m_2DWorldCamObj.localPosition.x then
    x = w
  elseif game.m_2DWorldCamObj.localPosition.x > world_width - w then
    x = world_width - w
  end
  if game.m_2DWorldCamObj.localPosition.y < game.m_2DWorldCam.orthographicSize then
    y = game.m_2DWorldCam.orthographicSize
  elseif game.m_2DWorldCamObj.localPosition.y > world_height - game.m_2DWorldCam.orthographicSize then
    y = world_height - game.m_2DWorldCam.orthographicSize
  end
  if x or y then
    if x == nil then
      x = game.m_2DWorldCamObj.localPosition.x
    end
    if y == nil then
      y = game.m_2DWorldCamObj.localPosition.y
    end
    game.m_2DWorldCamObj.localPosition = EC.Vector3.new(x, y, game.m_2DWorldCamObj.localPosition.z)
  end
  FlyModule.Instance():FlowCloud(0, "fight")
  gmodule.moduleMgr:GetModule(ModuleId.MAP):SetMapExtend(512)
  if game.m_fightCam then
    local cam = game.m_fightCam:GetComponent("Camera")
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
  if game.m_fightCam then
    local cam = game.m_fightCam:GetComponent("Camera")
    cam.depth = CameraDepth.BATTLEMAP
  end
  gmodule.moduleMgr:GetModule(ModuleId.MAP):SetMapExtend(128)
  FlyModule.Instance():StopCloud("fight")
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
def.method("userdata", "=>", "number").GetSpectatorTeam = function(self, roleid)
  if roleid == nil or instance.spectatorTeamMap == nil or instance.fightInstanceId == nil then
    return 0
  end
  local team = instance.spectatorTeamMap[instance.fightInstanceId:tostring()]
  local fight_team = FightConst.ACTIVE_TEAM
  local OBSERVER = require("netio.protocol.mzm.gsp.fight.Observer")
  if team == OBSERVER.TYPE_PASIVE then
    fight_team = FightConst.PASSIVE_TEAM
  else
    fight_team = FightConst.ACTIVE_TEAM
  end
  local role = self.spectators and self.spectators[roleid:tostring()]
  if role then
    role.team = fight_team
  end
  return fight_team
end
def.method("string", "userdata", "table", "userdata", "=>", "userdata").PlayEffect = function(self, resName, parent, localpos, localrot)
  if parent == nil then
    localpos = localpos + FightMgr.BattleFieldPos - FxCacheMan.Instance.gameObject.localPosition
  end
  return self:DoPlayEffect(resName, parent, localpos, localrot)
end
def.method("string", "userdata", "table", "userdata", "=>", "userdata").DoPlayEffect = function(self, resName, parent, localpos, localrot)
  local fx
  local lifeTime = -1
  local fxTbl = self.fxCacheList[resName]
  if fxTbl then
    if fxTbl.fx then
      ECFxMan.Instance():Stop(fxTbl.fx)
    end
    fx = GameUtil.RequestFx(resName, 0)
    fxTbl.fx = fx
    lifeTime = 10000000
  end
  if fx == nil then
    fx = self:GetEffectFx(resName)
    self:RemoveEffectFxFromCache(resName)
  end
  if fx and not fx.isnil then
    if parent then
      fx.parent = parent
    end
    fx.localPosition = localpos
    fx.localRotation = localrot
    fx.localScale = EC.Vector3.one
    local fxone = fx:GetComponent("FxOne")
    fxone:Play2(lifeTime, false)
    fx:SetLayer(ClientDef_Layer.FightPlayer)
    return fx
  end
  return nil
end
def.method("string", "table", "dynamic", "function", "number", "number", "number").PlayMovingEffect = function(self, resName, pos, dest, cb, speed, duration, tolerance)
  pos = pos + FightMgr.BattleFieldPos
  dest = dest + FightMgr.BattleFieldPos
  self:DoPlayMovingEffect(resName, pos, dest, cb, speed, duration, tolerance)
end
def.method("string", "table", "dynamic", "function", "number", "number", "number").DoPlayMovingEffect = function(self, resName, pos, dest, cb, speed, duration, tolerance)
  if type(dest) ~= "userdata" and type(dest) ~= "table" then
    return
  end
  local fx = self:GetEffectFx(resName)
  self:RemoveEffectFxFromCache(resName)
  if fx then
    fx.localPosition = pos
    fx.localRotation = Quaternion.identity
    fx.localScale = EC.Vector3.one
    local fxone = fx:GetComponent("FxOne")
    fxone:Play2(100, false)
    fx:SetLayer(ClientDef_Layer.FightPlayer)
  end
  local go, fly
  local flyroot = ECFxMan.Instance().mFlyUnusedRoot
  if flyroot.childCount > 0 then
    go = flyroot:GetChild(0)
    go:SetActive(true)
    fly = go:GetComponent("LinearMotor")
  else
    go = GameObject.GameObject("fly")
    fly = go:AddComponent("LinearMotor")
  end
  go.parent = ECFxMan.Instance().mFlyRoot
  go.position = pos
  go.localRotation = Quaternion.identity
  go.localScale = EC.Vector3.one
  fx.parent = go
  fx.localPosition = EC.Vector3.zero
  fx.localScale = EC.Vector3.one
  fly:Fly(pos, dest, speed, duration, tolerance, function(go, timeout)
    if cb then
      cb(go, dest, resName)
    end
    go.parent = flyroot
    go:SetActive(false)
  end)
end
def.method().ProcessProCache = function(self)
  self.isCacheProcessing = true
  while #self.proCache > 0 do
    local func = self.proCache[1].func
    local pro = self.proCache[1].pro
    table.remove(self.proCache, 1)
    if pro and func then
      _G.SafeCall(func, pro)
    end
  end
  self.isCacheProcessing = false
  self.proCache = {}
end
def.static("table", "table").OnFeatureClose = function(p1, p2)
  if not instance.isInFight then
    return
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_CLASS_RESTRICTION)
  if not isOpen and instance.fightUnits then
    for k, v in pairs(instance.fightUnits) do
      v:HideClassOvercome()
    end
  end
end
def.method("=>", "userdata").GetDamageTemplate = function(self)
  return self.damageTemplate
end
def.method("=>", "table").GetFonts = function(self)
  return self.fonts
end
def.method("=>", "boolean").IsNeedShowDlgPrelude = function(self)
  if Replayer.Instance().isInFight then
    return false
  end
  return self.isInFight
end
def.method().ResetFightView = function(self)
  DlgFight.Instance():SetVisible(true)
  FxCacheMan.Instance.gameObject.localPosition = FightMgr.BattleFieldPos
  self.damageRoot:SetActive(true)
  local musics = self.sceneInfo and self.sceneInfo.musics
  if musics then
    ECSoundMan.Instance():PlayBackgroundMusic(self:GetBgMusic(musics), true)
  end
  if self.isFlyBattle then
    ECGame.Instance().m_fightCam:SetActive(false)
    self:SetToSkyMode()
  else
    ECGame.Instance().m_fightCam:SetActive(true)
    self:SetToGroundMode()
  end
  GUIMan.Instance().m_hudCameraGo.localPosition = FightMgr.BattleFieldCamPos
  GUIMan.Instance().m_hudCameraGo2.localPosition = FightMgr.BattleFieldCamPos
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
def.method().RemoveJoinTimer = function(self)
  if self.join_timer_id > 0 then
    GameUtil.RemoveGlobalTimer(self.join_timer_id)
    self.join_timer_id = 0
  end
end
FightMgr.Commit()
return FightMgr
