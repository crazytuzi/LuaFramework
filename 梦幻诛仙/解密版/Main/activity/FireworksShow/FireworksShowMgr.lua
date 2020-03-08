local MODULE_NAME = (...)
local Lplus = require("Lplus")
local FireworksShowMgr = Lplus.Class(MODULE_NAME)
local def = FireworksShowMgr.define
local FireworksShowUtils = require("Main.activity.FireworksShow.FireworksShowUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local MapUtility = require("Main.Map.MapUtility")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local SoundData = require("Sound.SoundData")
local ECSoundMan = require("Sound.ECSoundMan")
local instance
def.static("=>", FireworksShowMgr).Instance = function()
  if instance == nil then
    instance = FireworksShowMgr()
  end
  return instance
end
local FireWorkStageInfo = require("netio.protocol.mzm.gsp.firework.FireWorkStageInfo")
local Stage = FireWorkStageInfo
def.field("table").m_feature2ActivityId = nil
def.field("boolean").m_fireworksPlaying = false
def.field("userdata").m_fireworksFxGO = nil
def.field("userdata").m_countDownFxGO = nil
def.field("number").m_countDownFxOneId = 0
def.field("table").m_activityInfos = nil
def.field("dynamic").m_removeFxTimerId = nil
def.field("boolean").m_findAllFireworks = false
def.field("userdata").m_fireworksSoundOne = nil
def.field("number").m_fireworksBrodcastTimerId = 0
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.firework.SSynAllFireworkShowStage", FireworksShowMgr.OnSSynAllFireworkShowStage)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.firework.SSynFireworkShowStage", FireworksShowMgr.OnSSynFireworkShowStage)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.firework.SFindFireworkSuc", FireworksShowMgr.OnSFindFireworkSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.firework.SGetFireworkAward", FireworksShowMgr.OnSGetFireworkAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.firework.SFireworkGainPreciousItemBrd", FireworksShowMgr.OnSFireworkGainPreciousItemBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.firework.SPlayFindFireworkSucEffectBro", FireworksShowMgr.OnSPlayFindFireworkSucEffectBro)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, FireworksShowMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, FireworksShowMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, FireworksShowMgr.OnFlyChange)
  Event.RegisterEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Double_Fly_Change, FireworksShowMgr.OnFlyChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, FireworksShowMgr.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, FireworksShowMgr.OnLeaveFight)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FireworksShowMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, FireworksShowMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, FireworksShowMgr.OnChangeMap)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, FireworksShowMgr.OnDramaStart)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, FireworksShowMgr.OnDramaEnd)
end
def.method("=>", "boolean").IsFireworksShowBegin = function(self)
end
def.method("number").CCollectFireworkReq = function(self, instanceId)
  local activityId = self:GetCurMapLastActivityId()
  if ActivityInterface.CheckActivityConditionLevel(activityId, true) == false then
    return
  end
  local p = require("netio.protocol.mzm.gsp.firework.CCollectFireworkReq").new(instanceId)
  gmodule.network.sendProtocol(p)
end
def.method().CheckFireworksStage = function(self)
  if self.m_activityInfos == nil or table.nums(self.m_activityInfos) == 0 then
    return
  end
  local activityId = self:GetCurMapLastActivityId()
  print("CheckFireworksStage: activityId=" .. activityId)
  if activityId == 0 then
    self:ClearFireworksShow()
    return
  end
  if not self:IsActivityFeatureOpen(activityId) then
    print(string.format("CheckFireworksStage activityId=%d, feature not open", activityId))
    return
  end
  if _G.PlayerIsInFight() then
    return
  end
  if _G.CGPlay then
    return
  end
  local fireworksActInfo = self:GetFireworksActivityInfo(activityId)
  local stage = fireworksActInfo.stage
  print("CheckFireworksStage: stage=" .. stage)
  if stage == Stage.STAGE_FIND then
  elseif stage == Stage.STAGE_COUNT_DOWN then
    self:Check2ShowCountDown(activityId)
  elseif stage == Stage.STAGE_SHOW then
    self:Check2ShowFireworks(activityId)
  end
end
def.method("number").Check2ShowCountDown = function(self, activityId)
  if not _G.IsNil(self.m_countDownFxGO) then
    local fxone = self.m_countDownFxGO:GetComponent("FxOne")
    local fxoneId = fxone:get_id()
    if self.m_countDownFxOneId ~= 0 and fxoneId == self.m_countDownFxOneId then
      print("Check2ShowCountDown already show countDown")
      return
    end
  end
  local fireworksActInfo = self:GetFireworksActivityInfo(activityId)
  local fireworksCfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
  local endTime = fireworksActInfo.stageStartTime + fireworksCfg.countDown
  local curTime = _G.GetServerTime()
  if endTime < curTime then
    print(string.format("Check2ShowCountDown: curTime(%d) > endTime(%d)", curTime, endTime))
    return
  end
  local lifetime = endTime - curTime
  local fxId = fireworksCfg.countDownEffectId
  print("Check2ShowCountDown fxId=" .. tostring(fxId))
  if fxId and fxId > 0 then
    local effRes = GetEffectRes(fxId)
    if effRes then
      local fxIndex = require("Common.MathHelper").Clamp(lifetime, 0, 9)
      local effectPath = effRes.path
      local strs = effectPath:split("_")
      strs[#strs] = string.format("%d.prefab.u3dext", fxIndex)
      effectPath = table.concat(strs, "_")
      local name = tostring(fxId)
      local guiFxMan = require("Fx.GUIFxMan").Instance()
      print(string.format("Check2ShowCountDown: playing fxs: fxPath=%s, lifetime=%d", effectPath, lifetime))
      self:StopShowCountDown()
      self.m_countDownFxGO = guiFxMan:Play(effectPath, tostring(fxId), 0, 0, -1, false)
      local fxone = self.m_countDownFxGO:GetComponent("FxOne")
      self.m_countDownFxOneId = fxone:get_id()
    end
  end
end
def.method("number").Check2ShowFireworks = function(self, activityId)
  self:Check2ShowFireworksBrodcast(activityId, 0)
  if self.m_fireworksPlaying then
    print("already show fireworks")
    return
  end
  if not self:IsSelfFlying() then
    print("Check2ShowFireworks: not flying")
    return
  end
  local cfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
  local fireworksActInfo = self:GetFireworksActivityInfo(activityId)
  local fxDuration = cfg.fireworkEffectDuration
  local endTime = fireworksActInfo.stageStartTime + fxDuration
  local curTime = _G.GetServerTime()
  if endTime < curTime then
    print(string.format("Check2ShowFireworks: curTime(%d) > endTime(%d)", curTime, endTime))
    return
  end
  self.m_fireworksPlaying = true
  local fxId = cfg.fireworkEffectId
  print("Check2ShowFireworks fxId=" .. tostring(fxId))
  if fxId and fxId > 0 then
    local effRes = GetEffectRes(fxId)
    if effRes then
      local name = tostring(fxId)
      local guiFxMan = require("Fx.GUIFxMan").Instance()
      local lifetime = endTime - curTime
      print(string.format("Check2ShowFireworks: playing fxs: fxPath=%s, lifetime=%d", effRes.path, lifetime))
      guiFxMan:PlayAsChildLayerWithCallback(guiFxMan.fxroot, effRes.path, name, 0, 0, 1, 1, -1, false, function(partical)
        if _G.IsEnteredWorld() and self.m_fireworksPlaying then
          self.m_fireworksFxGO = partical
        elseif not _G.IsNil(partical) then
          Object.Destroy(partical)
        end
      end)
      self:RemoveFxTimer()
      self.m_removeFxTimerId = AbsoluteTimer.AddListener(lifetime, 0, function()
        self:StopShowFireworks()
        self:StopFireworksBrodcastTimer()
      end, nil, 0)
    end
  end
  local soundId = cfg.fireworkMusicId
  local path = SoundData.Instance():GetSoundPath(soundId)
  if path ~= nil then
    self:StopFireworksSound()
    self.m_fireworksSoundOne = ECSoundMan.Instance():Play2DSoundWithExParams(path, SOUND_TYPES.ENVIRONMENT, 10, {loop = true})
  end
end
def.method("number", "number", "=>", "boolean").Check2ShowFireworksBrodcast = function(self, activityId, no)
  if self.m_fireworksBrodcastTimerId ~= 0 then
    return false
  end
  local cfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
  if cfg == nil then
    return false
  end
  if cfg.showStartBroCount == 0 then
    return false
  end
  local fireworksActInfo = self:GetFireworksActivityInfo(activityId)
  local fxDuration = cfg.fireworkEffectDuration
  local curTime = _G.GetServerTime()
  local diffTime = math.max(0.001, curTime - fireworksActInfo.stageStartTime)
  if fxDuration < diffTime then
    return false
  end
  if no >= cfg.showStartBroCount - 1 then
    return false
  end
  local nextNo = math.ceil(diffTime / cfg.showStartBroInterval)
  local nextBrodcastLeftSeconds = nextNo * cfg.showStartBroInterval - diffTime
  self.m_fireworksBrodcastTimerId = AbsoluteTimer.AddListener(nextBrodcastLeftSeconds, 0, function()
    self.m_fireworksBrodcastTimerId = 0
    if nextNo ~= no then
      self:ShowFireworksBeganWorldMsg(activityId)
    end
    self:Check2ShowFireworksBrodcast(activityId, nextNo)
  end, nil, 0)
  return true
end
def.method().StopFireworksBrodcastTimer = function(self)
  if self.m_fireworksBrodcastTimerId ~= 0 then
    AbsoluteTimer.RemoveListener(self.m_fireworksBrodcastTimerId)
    self.m_fireworksBrodcastTimerId = 0
  end
end
def.method("=>", "number").GetCurMapLastActivityId = function(self)
  if self.m_activityInfos == nil then
    return 0
  end
  local curMapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  local lastActivityId = 0
  local lastStageStartTime
  for activityId, v in pairs(self.m_activityInfos) do
    local showCfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
    if showCfg then
      local showMapId = showCfg.showMapId
      if showMapId == curMapId and (lastStageStartTime == nil or lastStageStartTime < v.stageStartTime) then
        lastActivityId = activityId
        lastStageStartTime = v.stageStartTime
      end
    end
  end
  return lastActivityId
end
def.method("number", "=>", "table").GetFireworksActivityInfo = function(self, activityId)
  if self.m_activityInfos == nil then
    return nil
  end
  return self.m_activityInfos[activityId]
end
def.method().StopShowCountDown = function(self)
  require("Fx.GUIFxMan").Instance():RemoveFx(self.m_countDownFxGO)
  self.m_countDownFxGO = nil
  self.m_countDownFxOneId = 0
end
def.method().StopShowFireworks = function(self)
  if not _G.IsNil(self.m_fireworksFxGO) then
    Object.Destroy(self.m_fireworksFxGO)
  end
  self.m_fireworksFxGO = nil
  self:StopFireworksSound()
  self:RemoveFxTimer()
  self.m_fireworksPlaying = false
end
def.method().StopFireworksSound = function(self)
  if not _G.IsNil(self.m_fireworksSoundOne) then
    self.m_fireworksSoundOne:Stop(1)
  end
  self.m_fireworksSoundOne = nil
end
def.method().RemoveFxTimer = function(self)
  if self.m_removeFxTimerId then
    AbsoluteTimer.RemoveListener(self.m_removeFxTimerId)
    self.m_removeFxTimerId = nil
  end
end
def.method("number").OnActivityFeatureOpen = function(self, activityId)
  activityInterface:removeCustomCloseActivity(activityId)
  self:CheckFireworksStage()
end
def.method("number").OnActivityFeatureClose = function(self, activityId)
  activityInterface:addCustomCloseActivity(activityId)
  self:ClearFireworksShow()
end
def.method("number").GotoParticipateActivity = function(self, activityId)
  local cfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
  if cfg == nil then
    return
  end
  if not _G.IsFeatureOpen(cfg.switchId) then
    Toast(textRes.activity[51])
    warn(string.format("FireworksShow: feature(%d) not open", cfg.switchId))
    return
  end
  local mapCfg = MapUtility.GetMapCfg(cfg.showMapId)
  local mapName = mapCfg and mapCfg.mapName or "$mapName"
  local text = textRes.FireworksShow[1]
  Toast(text:format(mapName))
end
def.method("number").OnStartFindFireworks = function(self, activityId)
  local cfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
  if cfg == nil then
    return
  end
  local mapCfg = MapUtility.GetMapCfg(cfg.showMapId)
  local mapName = mapCfg and mapCfg.mapName or "$mapName"
  local text = textRes.FireworksShow[2]:format(mapName, cfg.totalCount)
  self:ShowTopNotice(text)
end
def.method("=>", "boolean").IsSelfFlying = function(self)
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole and myRole:IsInState(RoleState.FLY) then
    return true
  else
    return false
  end
end
def.method("string").ShowTopNotice = function(self, text)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = text})
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(text, 0, "Group_2")
end
def.method("string").ShowBottomNotice = function(self, text)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = text})
  local AnnouncementTip = require("GUI.AnnouncementTip")
  AnnouncementTip.Announce(text)
end
def.method("number").ShowFireworksBeganWorldMsg = function(self, activityId)
  if not self:IsActivityFeatureOpen(activityId) then
    return
  end
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  local fireworksCfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
  if fireworksCfg == nil then
    return
  end
  local mapName = self:GetMapName(fireworksCfg.showMapId)
  local content = textRes.FireworksShow[10]:formatEx(mapName)
  ChatModule.Instance():SendNoteMsg(content, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.method("number", "=>", "string").GetMapName = function(self, mapId)
  local mapCfg = MapUtility.GetMapCfg(mapId)
  local mapName = mapCfg and mapCfg.mapName or "$mapName"
  return mapName
end
def.method("number", "=>", "number").GetActivityMinJoinLevel = function(self, activityId)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  return activityCfg and activityCfg.levelMin or -1
end
def.method("number", "=>", "boolean").IsActivityFeatureOpen = function(self, activityId)
  if self.m_feature2ActivityId == nil then
    return false
  end
  local switchId
  for _switchId, _activityId in pairs(self.m_feature2ActivityId) do
    if _activityId == activityId then
      switchId = _switchId
      break
    end
  end
  if switchId == nil then
    return false
  end
  local isOpen = _G.IsFeatureOpen(switchId)
  return isOpen
end
def.method().ClearFireworksShow = function(self)
  if self.m_activityInfos == nil or table.nums(self.m_activityInfos) == 0 then
    return
  end
  self:StopShowCountDown()
  self:StopShowFireworks()
end
def.method().Clear = function(self)
  self:ClearFireworksShow()
  self:StopFireworksBrodcastTimer()
  self.m_activityInfos = nil
end
def.static("table", "table").OnFeatureOpenInit = function(params, context)
  local self = instance
  local cfgs = FireworksShowUtils.GetAllFireworksShowCfgs()
  self.m_feature2ActivityId = {}
  for i, v in ipairs(cfgs) do
    if IsFeatureOpen(v.switchId) then
      self:OnActivityFeatureOpen(v.activityId)
    else
      self:OnActivityFeatureClose(v.activityId)
    end
    self.m_feature2ActivityId[v.switchId] = v.activityId
  end
  self:CheckFireworksStage()
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local self = instance
  if self.m_feature2ActivityId == nil then
    return
  end
  local switchId = params.feature
  local activityId = self.m_feature2ActivityId[switchId]
  if activityId == nil then
    return
  end
  if _G.IsFeatureOpen(switchId) then
    self:OnActivityFeatureOpen(activityId)
  else
    self:OnActivityFeatureClose(activityId)
  end
end
def.static("table", "table").OnFlyChange = function(params, context)
  if instance.m_activityInfos == nil or table.nums(instance.m_activityInfos) == 0 then
    return
  end
  if instance:IsSelfFlying() then
    instance:CheckFireworksStage()
  else
    instance:StopShowFireworks()
  end
end
def.static("table", "table").OnEnterFight = function(params, context)
  instance:ClearFireworksShow()
end
def.static("table", "table").OnLeaveFight = function(params, context)
  instance:CheckFireworksStage()
end
def.static("table", "table").OnEnterWorld = function(params, context)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  instance:Clear()
end
def.static("table", "table").OnActivityTodo = function(params, context)
  local todoActivityId = params[1]
  local self = instance
  if self.m_feature2ActivityId == nil then
    return
  end
  for switchId, activityId in pairs(self.m_feature2ActivityId) do
    if todoActivityId == activityId then
      self:GotoParticipateActivity(activityId)
      return
    end
  end
end
def.static("table", "table").OnChangeMap = function(params, context)
  local self = instance
  self:CheckFireworksStage()
end
def.static("table", "table").OnDramaStart = function(params, context)
  local self = instance
  self:ClearFireworksShow()
end
def.static("table", "table").OnDramaEnd = function(params, context)
  local self = instance
  self:CheckFireworksStage()
end
def.static("table").OnSPlayFindFireworkSucEffectBro = function(p)
  local self = instance
  local curMapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  if curMapId ~= p.mapId then
    return
  end
  local activityId = self:GetCurMapLastActivityId()
  if activityId == 0 then
    warn("[error] Last activityId of current map is 0.")
    return
  end
  local cfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
  if cfg == nil then
    return
  end
  local fxId = cfg.collectSucEffectId
  local location = p.location
  if fxId and fxId > 0 then
    local effRes = GetEffectRes(fxId)
    if effRes then
      do
        local lifetime = 10
        local mapeffid = _G.MapEffect_RequireRes(location.x, world_height - location.y, 1, {
          effRes.path
        })
        GameUtil.AddGlobalTimer(lifetime, true, function()
          MapEffect_ReleaseRes(mapeffid)
        end)
      end
    end
  end
  local soundId = cfg.collectSucMusicId
  local path = SoundData.Instance():GetSoundPath(soundId)
  if path ~= nil then
    ECSoundMan.Instance():Play2DSoundWithExParams(path, SOUND_TYPES.ENVIRONMENT, 10, nil)
  end
end
def.static("table").OnSFireworkGainPreciousItemBrd = function(p)
  local self = instance
  local AnnouncementTip = require("GUI.AnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local roleName = _G.GetStringFromOcts(p.name)
  local awardStr = PersonalHelper.ToString(PersonalHelper.Type.ItemMap, p.items)
  local str = textRes.FireworksShow[7]:format(roleName, awardStr)
  self:ShowTopNotice(str)
end
def.static("table").OnSGetFireworkAward = function(p)
  local self = instance
  local AwardUtils = require("Main.Award.AwardUtils")
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local awardStr = table.concat(AwardUtils.GetHtmlTextsFromAwardBean(p.awardBean, ""), "<br/>")
  local text = textRes.FireworksShow[6]:format(awardStr)
  PersonalHelper.SendOut(text)
  local cfg = FireworksShowUtils.GetFireworksShowCfg(p.activityId)
  local curHit = tostring(p.hitCount)
  local maxHit = cfg and tostring(cfg.hitAwardCountMax)
  local numLimitText = textRes.FireworksShow[8]:format(curHit, maxHit)
  PersonalHelper.SendOut(numLimitText)
end
def.static("table").OnSFindFireworkSuc = function(p)
  local self = instance
  local activityId = p.activityId
  local name = _G.GetStringFromOcts(p.name)
  local num = p.num
  local cfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
  local text
  if num < cfg.needCount then
    local leftNum = cfg.needCount - num
    text = textRes.FireworksShow[3]:format(name, num, leftNum)
    self.m_findAllFireworks = false
    self:ShowBottomNotice(text)
  else
    local minJoinLevel = self:GetActivityMinJoinLevel(activityId)
    local mapCfg = MapUtility.GetMapCfg(cfg.showMapId)
    local mapName = mapCfg and mapCfg.mapName or "$mapName"
    local beginPromptText = textRes.FireworksShow[5]:format(mapName, minJoinLevel)
    text = textRes.FireworksShow[4]:format(name, beginPromptText)
    self.m_findAllFireworks = true
    self:ShowBottomNotice(text)
  end
end
def.static("table").OnSSynFireworkShowStage = function(p)
  local self = instance
  local activityInfo = p.stageInfo
  local activityId = p.activityId
  self.m_activityInfos = self.m_activityInfos or {}
  activityInfo.stageStartTime = activityInfo.stageStartTime:ToNumber()
  self.m_activityInfos[activityId] = activityInfo
  if not self:IsActivityFeatureOpen(activityId) then
    return
  end
  local showCfg = FireworksShowUtils.GetFireworksShowCfg(activityId)
  local mapCfg = MapUtility.GetMapCfg(showCfg.showMapId)
  local mapName = mapCfg and mapCfg.mapName or "$mapName"
  if activityInfo.stage == Stage.STAGE_FIND then
    self:OnStartFindFireworks(activityId)
  elseif activityInfo.stage == Stage.STAGE_COUNT_DOWN then
    if not self.m_findAllFireworks then
      local minJoinLevel = self:GetActivityMinJoinLevel(activityId)
      self:ShowBottomNotice(textRes.FireworksShow[5]:format(mapName, minJoinLevel))
    end
    self.m_findAllFireworks = false
  elseif activityInfo.stage == Stage.STAGE_SHOW then
    local minJoinLevel = self:GetActivityMinJoinLevel(activityId)
    self:ShowTopNotice(textRes.FireworksShow[9]:format(mapName, minJoinLevel))
    self:ShowFireworksBeganWorldMsg(activityId)
    self:Check2ShowFireworksBrodcast(activityId, 0)
  end
  self:CheckFireworksStage()
end
def.static("table").OnSSynAllFireworkShowStage = function(p)
  local self = instance
  self.m_activityInfos = p.activityInfos
  for k, v in pairs(self.m_activityInfos) do
    v.stageStartTime = v.stageStartTime:ToNumber()
  end
end
return FireworksShowMgr.Commit()
