local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AnniversaryData = require("Main.activity.Anniversary.data.AnniversaryData")
local AnniversaryModule = Lplus.Extend(ModuleBase, "AnniversaryModule")
local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local AnniversaryUtils = require("Main.activity.Anniversary.AnniversaryUtils")
local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
local ChatModule = require("Main.Chat.ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local NoticeType = require("consts.mzm.gsp.function.confbean.NoticeType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local instance
local def = AnniversaryModule.define
local ANNIVERSARY_PARADE = "ANNIVERSARY_PARADE"
def.field("number").make_up_timerId = 0
def.field("number").curQuestionId = 0
def.field("boolean").goToMakeUp = false
def.field("number").prepare_timerId = 0
def.field("number").prepare_time = 0
def.field("table").makeup_cfg = nil
def.field("userdata").makeup_range_fx = nil
def.field("userdata").makeup_round_fx = nil
def.field("userdata").flower_fx = nil
def.static("=>", AnniversaryModule).Instance = function()
  if instance == nil then
    instance = AnniversaryModule()
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  AnniversaryData.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SFlowerParadeCounddown", AnniversaryModule.OnSFlowerParadeCounddown)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SFlowerParadeEnd", AnniversaryModule.OnSFlowerParadeEnd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SFlowerParadeDoDance", AnniversaryModule.OnSFlowerParadeDoDance)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SFlowerParadeDoSing", AnniversaryModule.OnSFlowerParadeDoSing)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SFlowerParadeJoinFailedRep", AnniversaryModule.OnSFlowerParadeJoinFailedRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SFlowerParadeDanceSuccessRep", AnniversaryModule.OnSFlowerParadeDanceSuccessRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SFlowerParadeDoSingFailed", AnniversaryModule.OnSFlowerParadeDoSingFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SFlowerParadeRoleDoneFollow", AnniversaryModule.OnSFlowerParadeRoleDoneFollow)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SFlowerParadeDanceFailedRep", AnniversaryModule.OnSFlowerParadeDanceFailedRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.flowerparade.SSynFlowerParadeAward", AnniversaryModule.OnSSynFlowerParadeAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.makeup.SStartMakeUpQuestion", AnniversaryModule.OnSStartMakeUpQuestion)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.makeup.SAnswerMakeUpRep", AnniversaryModule.OnSAnswerMakeUpRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.makeup.SSynMakeupInfo", AnniversaryModule.OnSSynMakeupInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.makeup.SMakeUpTurnOver", AnniversaryModule.OnSMakeUpTurnOver)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.makeup.SMakeUpNormalInfo", AnniversaryModule.OnSMakeUpNormalInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, AnniversaryModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AnniversaryModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, AnniversaryModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AnniversaryModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, AnniversaryModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, AnniversaryModule.OnClickChatBtn)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, AnniversaryModule.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, AnniversaryModule.OnActivityEnd)
end
def.method().GotoParade = function(self)
  if _G.IsCrossingServer() then
    return false
  end
  local entities = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_FLOAT_PARADE)
  if entities then
    local k, float = next(entities)
    if float and float.vehicle then
      local vehicle_pos = float.vehicle:GetPos()
      local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
      heroModule:MoveTo(0, vehicle_pos.x, vehicle_pos.y, 0, 0, MoveType.AUTO, nil)
      return
    end
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.flowerparade.CFlowerParadeJoinReq").new(constant.FlowerParadeConstCfg.activityId))
end
def.method("=>", "table").GetMakeUpCfg = function(self)
  if self.makeup_cfg == nil then
    self.makeup_cfg = AnniversaryUtils.GetMakeUpCfg(constant.CMakeUpConsts.ACTIVITY_ID)
  end
  return self.makeup_cfg
end
def.method().ShowQuestion = function(self)
  local questionInfo = AnniversaryData.Instance():GetQuestion()
  if questionInfo == nil or questionInfo.questionId <= 0 then
    return
  end
  if not self:IsInGangMap() then
    self:LeaveMakeUp()
    return
  end
  if not ActivityInterface.CheckActivityConditionLevel(constant.CMakeUpConsts.ACTIVITY_ID, false) then
    return
  end
  self:ShowMakeUpEffect()
  local cfg = self:GetMakeUpCfg()
  local time = cfg.roundTime + questionInfo.startTime - _G.GetServerTime()
  time = time:ToNumber()
  local min = math.floor(time / 60)
  local sec = time % 60
  local timestr = string.format("%02d:%02d", min, sec)
  local cosplayTip = require("Main.activity.Anniversary.ui.CosplayTip").Instance()
  if 0 >= AnniversaryData.Instance():GetAnswer(questionInfo.curTurn) then
    local tip
    if self.curQuestionId ~= questionInfo.questionId then
      local question_cfg = AnniversaryUtils.GetMakeUpQuestionCfg(questionInfo.questionId)
      local tipIdx = math.floor(math.random() * #question_cfg) + 1
      tip = string.format("%s %s(%s)", textRes.activity.Anniversary[27], question_cfg[tipIdx], timestr)
      require("Main.activity.Anniversary.ui.PanelCosplay").ShowPanel(questionInfo.optionIds)
      self.curQuestionId = questionInfo.questionId
      cosplayTip:ShowPanel(tip)
    else
      tip = cosplayTip:GetContent()
      local tipstr = string.gsub(tip, "%(%d+:%d+", "(" .. timestr)
      cosplayTip:ShowPanel(tipstr)
    end
  else
    local tipstr
    if cfg.rounds <= questionInfo.curTurn + 1 then
      tipstr = string.format(textRes.activity.Anniversary[21], timestr)
    else
      tipstr = string.format(textRes.activity.Anniversary[17], tostring(questionInfo.curTurn + 2), timestr)
    end
    cosplayTip:ShowPanel(tipstr)
  end
end
def.method("=>", "boolean").IsInGangMap = function(self)
  local mapInstanceId = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapInstanceId
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId
  local gangData = require("Main.Gang.data.GangData").Instance()
  local gangMapInstanceId = gangData:GetGangMapInstanceId()
  local gangMapId = require("Main.Gang.GangUtility").GetGangConsts("GANG_MAP")
  return mapId == gangMapId and mapInstanceId == gangMapInstanceId
end
def.method().GotoGangMap = function(self)
  if self:IsInGangMap() then
    self:GotoCosplay()
  else
    self:TransportToMakeUp()
  end
end
def.method().ReqToGangMap = function(self)
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole:IsInState(RoleState.UNTRANPORTABLE) then
    Toast(textRes.Gang[242])
    return
  end
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubMgr:IsInFollowState(myRole.roleId) == true then
    Toast(textRes.Hero[46])
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
  gmodule.moduleMgr:GetModule(ModuleId.GANG):GotoGangMap()
end
def.method().GotoCosplay = function(self)
  if self:CheckMakeUpOutOfRange() then
    local x, y = self:GetRandomPos()
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    heroModule:MoveTo(0, x, y, 0, 0, MoveType.RUN, nil)
  end
end
def.method("=>", "boolean").CheckMakeUpOutOfRange = function(self)
  local cfg = self:GetMakeUpCfg()
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local pos = heroModule.myRole:GetPos()
  local dist = math.sqrt(math.pow(pos.x - cfg.positionX, 2) + math.pow(pos.y - cfg.positionY, 2))
  return dist > cfg.radius
end
def.method("=>", "number", "number").GetRandomPos = function(self)
  local cfg = self:GetMakeUpCfg()
  local r = math.random() * cfg.radius
  local angle = math.pi * 2 * math.random()
  local x = r * math.cos(angle)
  local y = r * math.sin(angle)
  return cfg.positionX + x, cfg.positionY + y
end
def.method().MakeUpDance = function(self)
  if self.curQuestionId == 0 then
    return
  end
  local dlgAction = require("Main.Chat.ui.DlgAction").Instance()
  local ActionType = require("consts.mzm.gsp.map.confbean.ExpressionActionType")
  local me = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if me and not me:IsMoving() and not me:IsInState(RoleState.HUG) and not me:IsInState(RoleState.BEHUG) then
    if dlgAction:HasAction(me, ActionType.HYUN_DANCE) then
      dlgAction:PlayAction(ActionType.HYUN_DANCE)
    else
      dlgAction:PlayAction(ActionType.ATTACK)
    end
  end
end
def.method().EndMakeUp = function(self)
  if instance.prepare_timerId > 0 then
    GameUtil.RemoveGlobalTimer(instance.prepare_timerId)
    instance.prepare_timerId = 0
  end
  if 0 < self.make_up_timerId then
    GameUtil.RemoveGlobalTimer(self.make_up_timerId)
    self.make_up_timerId = 0
  end
  self.curQuestionId = 0
  AnniversaryData.Instance():ClearMakeUpData()
  self:LeaveMakeUp()
  Event.UnregisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, AnniversaryModule.OnChangeMap)
end
def.method().LeaveMakeUp = function(self)
  require("Main.activity.Anniversary.ui.CosplayTip").Instance():DestroyPanel()
  require("Main.activity.Anniversary.ui.PanelCosplay").Instance():DestroyPanel()
  if self.makeup_range_fx then
    require("Fx.ECFxMan").Instance():Stop(self.makeup_range_fx)
    self.makeup_range_fx = nil
  end
  self.curQuestionId = 0
end
def.method().CheckPrepare = function(self)
  if not ActivityInterface.CheckActivityConditionLevel(constant.CMakeUpConsts.ACTIVITY_ID, false) then
    return
  end
  local begin_time = ActivityInterface.GetActivityBeginningTime(constant.CMakeUpConsts.ACTIVITY_ID)
  local cur_time = _G.GetServerTime()
  local parade_cfg = self:GetMakeUpCfg()
  instance.prepare_time = begin_time + parade_cfg.prepareTime - cur_time
  if instance.prepare_time > 0 then
    instance:ShowMakeUpEffect()
    Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, AnniversaryModule.OnChangeMap)
    if instance.prepare_timerId == 0 then
      instance.prepare_timerId = GameUtil.AddGlobalTimer(1, false, function()
        instance.prepare_time = instance.prepare_time - 1
        if instance.prepare_time < 0 then
          instance.prepare_time = 0
        end
        if instance:IsInGangMap() then
          local min = math.floor(instance.prepare_time / 60)
          local sec = instance.prepare_time % 60
          local tipstr = string.format(textRes.activity.Anniversary[20], min, sec)
          require("Main.activity.Anniversary.ui.CosplayTip").Instance():ShowPanel(tipstr)
        else
          require("Main.activity.Anniversary.ui.CosplayTip").Instance():DestroyPanel()
        end
      end)
    end
  end
end
def.method("number", "number", "number").PlayEffect = function(self, effId, x, y)
  local ECFxMan = require("Fx.ECFxMan")
  local eff = GetEffectRes(effId)
  if eff then
    ECFxMan.Instance():PlayEffectAt2DPos(eff.path, x, world_height - y)
    if eff.sound > 0 then
      require("Sound.ECSoundMan").Instance():Play2DSoundByID(eff.sound)
    end
  end
end
def.method().PlayCountDown = function(self)
  local start_time = AnniversaryData.Instance():GetStartTime()
  if start_time == nil then
    return
  end
  local delay = start_time - _G.GetServerTime()
  delay = delay:ToNumber()
  if delay > 0 then
    require("GUI.CommonCountDown").Start(delay)
    local parade_cfg = AnniversaryUtils.GetAnniversaryParadeCfg(constant.FlowerParadeConstCfg.activityId)
    self:PlayEffectWithDuration(parade_cfg.prepareEffectId, 4.72)
  end
end
def.method().StopMakeupRoundEffect = function(self)
  if self.makeup_round_fx then
    require("Fx.GUIFxMan").Instance():RemoveFx(self.makeup_round_fx)
    self.makeup_round_fx = nil
  end
end
def.method().ShowMakeUpEffect = function(self)
  if self.makeup_range_fx == nil then
    local cfg = instance:GetMakeUpCfg()
    local effcfg = GetEffectRes(cfg.regionEffectId)
    self.makeup_range_fx = require("Fx.ECFxMan").Instance():PlayEffectAt2DPos(effcfg.path, cfg.positionX, world_height - cfg.positionY)
    if self.makeup_range_fx then
      local Vector = require("Types.Vector")
      self.makeup_range_fx.localScale = Vector.Vector3.one * (cfg.radius * 2 * cam_2d_to_3d_scale / 0.95)
      self.makeup_range_fx.localRotation = Quaternion.Euler(Vector.Vector3.new(-cam_3d_degree, 0, 0))
    end
  end
end
def.method("number", "number").PlayEffectWithDuration = function(self, effid, duration)
  local effdata = _G.GetEffectRes(effid)
  if self.flower_fx then
    require("Fx.GUIFxMan").Instance():RemoveFx(self.flower_fx)
    self.flower_fx = nil
  end
  self.flower_fx = require("Fx.GUIFxMan").Instance():Play(effdata.path, "", 0, 0, -1, false)
  if 0 < effdata.sound then
    require("Sound.ECSoundMan").Instance():Play2DSoundByID(effdata.sound)
  end
  GameUtil.AddGlobalTimer(duration, true, function()
    if self.flower_fx then
      require("Fx.GUIFxMan").Instance():RemoveFx(self.flower_fx)
      self.flower_fx = nil
    end
  end)
end
def.method().TransportToMakeUp = function(self)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, AnniversaryModule.OnChangeMap)
  self.goToMakeUp = true
  self:ReqToGangMap()
end
def.static("table").OnSFlowerParadeCounddown = function(p)
  AnniversaryData.Instance():SetOccupation(p.ocp)
  AnniversaryData.Instance():SetStartTime(p.startTime)
  local NPCInterface = require("Main.npc.NPCInterface")
  if p.roleList[1].roleId:eq(0) then
    local npccfg = NPCInterface.GetNPCCfg(constant.FlowerParadeConstCfg.maleId)
    p.roleList[1].roleName = npccfg.npcName
  end
  if p.roleList[2].roleId:eq(0) then
    local npccfg = NPCInterface.GetNPCCfg(constant.FlowerParadeConstCfg.femaleId)
    p.roleList[2].roleName = npccfg.npcName
  end
  AnniversaryData.Instance():SetRoles(p.roleList)
  local occupation_name = _G.GetOccupationName(p.ocp)
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(p.map)
  if mapCfg == nil then
    return
  end
  local msg = string.format(textRes.activity.Anniversary[1], occupation_name, mapCfg.mapName, p.roleList[1].roleName, p.roleList[2].roleName)
  local announce = msg .. textRes.activity.Anniversary[2]
  require("GUI.InteractiveAnnouncementTip").AnnounceWithModuleIdAndDuration(announce, NoticeType.YOU_JIE, 5)
  local world_msg = string.format("%1$s <a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", msg, ANNIVERSARY_PARADE, ANNIVERSARY_PARADE, link_defalut_color, textRes.activity.Anniversary[2])
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(world_msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.static("table").OnSFlowerParadeEnd = function(p)
  local announce = textRes.activity.Anniversary[3]
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(announce, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
  require("GUI.InteractiveAnnouncementTip").AnnounceWithModuleIdAndDuration(announce, NoticeType.YOU_JIE, 5)
  AnniversaryData.Instance():ClearParadeData()
  if not _G.PlayerIsInFight() then
    local entities = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_FLOAT_PARADE)
    if entities then
      local parade_cfg = AnniversaryUtils.GetAnniversaryParadeCfg(constant.FlowerParadeConstCfg.activityId)
      instance:PlayEffectWithDuration(parade_cfg.endEffectId, 4.72)
    end
  end
end
def.static("table").OnSFlowerParadeDoDance = function(p)
  local roles = AnniversaryData.Instance():GetRoles()
  if roles == nil then
    return
  end
  local host = roles[1]
  local msg = string.format(textRes.activity.Anniversary[5], host.roleName)
  Toast(msg)
  local parade_cfg = AnniversaryUtils.GetAnniversaryParadeCfg(constant.FlowerParadeConstCfg.activityId)
  local entities = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_FLOAT_PARADE)
  if entities then
    local k, float = next(entities)
    if float then
      local dance_cfg = AnniversaryUtils.GetParadeDanceCfg(parade_cfg.danceGroupId)
      local action = dance_cfg[p.actionIndex]
      if float.host then
        float.host:Talk(action.tip, 10)
      end
      local channel_str
      if host.roleId:eq(0) then
        channel_str = string.format(textRes.activity.Anniversary[22], action.tip)
      else
        channel_str = string.format(textRes.activity.Anniversary[23], host.roleName, action.tip)
      end
      require("GUI.InteractiveAnnouncementTip").AnnounceWithModuleIdAndDuration(channel_str, NoticeType.YOU_JIE, 10)
      gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(channel_str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
    end
  end
  instance:PlayEffectWithDuration(parade_cfg.fireworksEffectId, 2.36)
end
def.static("table").OnSFlowerParadeDoSing = function(p)
  local roles = AnniversaryData.Instance():GetRoles()
  if roles == nil then
    return
  end
  local hostess = roles[2]
  local msg = string.format(textRes.activity.Anniversary[6], hostess.roleName)
  Toast(msg)
  local parade_cfg = AnniversaryUtils.GetAnniversaryParadeCfg(constant.FlowerParadeConstCfg.activityId)
  local entities = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_FLOAT_PARADE)
  if entities then
    local k, float = next(entities)
    if float then
      local redbag_cfg = AnniversaryUtils.GetParadeRedbagCfg(parade_cfg.redbagGroupId)
      local tip = redbag_cfg[p.actionIndex]
      if float.hostess then
        float.hostess:Talk(tip, 5)
      end
    end
  end
  instance:PlayEffectWithDuration(parade_cfg.fireworksEffectId, 2.36)
end
def.static("table").OnSFlowerParadeJoinFailedRep = function(p)
  local msg = textRes.activity.Anniversary.JOIN_FAIL[p.code]
  if msg then
    Toast(msg)
  else
    msg = textRes.activity.Anniversary.ERROR[0]
    Toast(string.format(msg, "SFlowerParadeJoinFailedRep", p.code))
  end
end
def.static("table").OnSFlowerParadeDanceSuccessRep = function(p)
  Toast(string.format(textRes.activity.Anniversary[4], p.doneTime, p.maxTime))
end
def.static("table").OnSFlowerParadeDoSingFailed = function(p)
  if p.code == p.MAX_COUNT then
    Toast(textRes.activity.Anniversary[18])
  end
end
def.static("table").OnSFlowerParadeRoleDoneFollow = function(p)
  local parade_cfg = AnniversaryUtils.GetAnniversaryParadeCfg(constant.FlowerParadeConstCfg.activityId)
  Toast(string.format(textRes.activity.Anniversary[19], p.doneTime, parade_cfg.followAwardCount))
end
def.static("table").OnSFlowerParadeDanceFailedRep = function(p)
  local msg = textRes.activity.Anniversary.DANCE_FAIL[p.code]
  if msg then
    Toast(msg)
  else
    msg = textRes.activity.Anniversary.ERROR[0]
    Toast(string.format(msg, "SFlowerParadeDanceFailedRep", p.code))
  end
end
def.static("table").OnSSynFlowerParadeAward = function(p)
  local str = textRes.activity.Anniversary[24]
  if p.TYPE_FOLLOW == p.awardType then
    str = textRes.activity.Anniversary[25]
  end
  local awardInfo = require("Main.Award.AwardUtils").GetHtmlTextsFromAwardBean(p.award, str)
  for _, v in ipairs(awardInfo) do
    require("Main.Chat.PersonalHelper").SendOut(v)
  end
end
def.static("table").OnSStartMakeUpQuestion = function(p)
  AnniversaryData.Instance():SetQuestion(p.makeupInfo)
  if instance.prepare_timerId > 0 then
    GameUtil.RemoveGlobalTimer(instance.prepare_timerId)
    instance.prepare_timerId = 0
  end
  if instance:IsInGangMap() then
    instance:ShowQuestion()
    Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, AnniversaryModule.OnChangeMap)
  end
  if instance.make_up_timerId == 0 then
    instance.make_up_timerId = GameUtil.AddGlobalTimer(1, false, function()
      instance:ShowQuestion()
    end)
  end
end
def.static("table").OnSAnswerMakeUpRep = function(p)
  AnniversaryData.Instance():SetAnswer(p.optionId)
  if p.res == p.ANSWER_RIGHT then
    Toast(textRes.activity.Anniversary[10])
  else
    Toast(textRes.activity.Anniversary[11])
  end
  local ActionType = require("consts.mzm.gsp.map.confbean.ExpressionActionType")
  require("Main.Chat.ui.DlgAction").Instance():PlayAction(ActionType.ATTACK)
  GameUtil.AddGlobalTimer(1, true, function()
    instance:MakeUpDance()
  end)
end
def.static("table").OnSSynMakeupInfo = function(p)
  if p.factionMakeupInfo.questionId <= 0 then
    require("Main.activity.Anniversary.ui.CosplayTip").Instance():DestroyPanel()
  end
  AnniversaryData.Instance():SetQuestion(p.factionMakeupInfo)
  AnniversaryData.Instance():SetAnswers(p.roleMakeupInfo.record)
  if instance:IsInGangMap() then
    instance:CheckPrepare()
    instance:ShowQuestion()
  end
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, AnniversaryModule.OnChangeMap)
  if instance.make_up_timerId == 0 then
    instance.make_up_timerId = GameUtil.AddGlobalTimer(1, false, function()
      instance:ShowQuestion()
    end)
  end
end
def.static("table").OnSMakeUpTurnOver = function(p)
  local answer = AnniversaryData.Instance():GetAnswer(p.turn)
  local cfg = instance:GetMakeUpCfg()
  if answer > 0 then
    if p.rightNum < cfg.specialAwardNeedNum then
      Toast(string.format(textRes.activity.Anniversary[12], cfg.specialAwardNeedNum))
    else
      Toast(string.format(textRes.activity.Anniversary[13], p.rightNum))
    end
    local effdata = _G.GetEffectRes(cfg.finishEffectId)
    instance:StopMakeupRoundEffect()
    instance.makeup_round_fx = require("Fx.GUIFxMan").Instance():Play(effdata.path, "", 0, 0, -1, false)
    GameUtil.AddGlobalTimer(2.36, true, function()
      instance:StopMakeupRoundEffect()
    end)
  end
  if p.turn >= cfg.rounds - 1 then
    Toast(textRes.activity.Anniversary[14])
    instance:EndMakeUp()
    ChatModule.Instance():SendNoteMsg(textRes.activity.Anniversary[26], ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
end
def.static("table").OnSMakeUpNormalInfo = function(p)
  local msg = textRes.activity.Anniversary.MAKEUP_FAIL[p.code]
  if msg then
    Toast(msg)
  else
    msg = textRes.activity.Anniversary.ERROR[0]
    Toast(string.format(msg, "SMakeUpNormalInfo", p.code))
  end
end
def.static("table", "table").OnLeaveWorld = function()
  instance:EndMakeUp()
  instance:StopMakeupRoundEffect()
  AnniversaryData.Instance():Reset()
  if instance.prepare_timerId > 0 then
    GameUtil.RemoveGlobalTimer(instance.prepare_timerId)
    instance.prepare_timerId = 0
  end
  if instance.flower_fx then
    require("Fx.GUIFxMan").Instance():RemoveFx(instance.flower_fx)
    instance.flower_fx = nil
  end
  instance.curQuestionId = 0
end
def.static("table", "table").OnEnterWorld = function()
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_FLOWER_PARADE)
  if isOpen then
  end
  local isopen = ActivityInterface.Instance():isActivityOpend2(constant.CMakeUpConsts.ACTIVITY_ID)
  if isopen then
    if instance:IsInGangMap() then
      instance:CheckPrepare()
      instance:ShowQuestion()
    else
      Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, AnniversaryModule.OnChangeMap)
    end
  end
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1 and p1[1]
  if activityId == constant.FlowerParadeConstCfg.activityId then
    instance:GotoParade()
  elseif activityId == constant.CMakeUpConsts.ACTIVITY_ID then
    instance:GotoGangMap()
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1 == nil then
    return
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = ActivityInterface.Instance()
  if p1.feature == Feature.TYPE_FLOWER_PARADE then
    local isOpen = _G.IsFeatureOpen(Feature.TYPE_FLOWER_PARADE)
    if isOpen then
      activityInterface:removeCustomCloseActivity(constant.FlowerParadeConstCfg.activityId)
    else
      activityInterface:addCustomCloseActivity(constant.FlowerParadeConstCfg.activityId)
      local entities = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_FLOAT_PARADE)
      if entities then
        local k, float = next(entities)
        if float then
          gmodule.moduleMgr:GetModule(ModuleId.MAP):RemoveMapEntity(MapEntityType.MET_FLOAT_PARADE, float.instanceid)
        end
      end
    end
  elseif p1.feature == Feature.TYPE_MAKE_UP_NEW_YEARS_DAY then
    local isOpen = _G.IsFeatureOpen(Feature.TYPE_MAKE_UP_NEW_YEARS_DAY)
    if isOpen then
      activityInterface:removeCustomCloseActivity(constant.CMakeUpConsts.ACTIVITY_ID)
    else
      activityInterface:addCustomCloseActivity(constant.CMakeUpConsts.ACTIVITY_ID)
      instance:EndMakeUp()
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = ActivityInterface.Instance()
  local features = {
    {
      idip = Feature.TYPE_FLOWER_PARADE,
      activityId = constant.FlowerParadeConstCfg.activityId
    },
    {
      idip = Feature.TYPE_MAKE_UP_NEW_YEARS_DAY,
      activityId = constant.CMakeUpConsts.ACTIVITY_ID
    }
  }
  for _, v in pairs(features) do
    local isOpen = _G.IsFeatureOpen(v.idip)
    if isOpen then
      activityInterface:removeCustomCloseActivity(v.activityId)
    else
      activityInterface:addCustomCloseActivity(v.activityId)
    end
  end
end
def.static("table", "table").OnChangeMap = function(p1, p2)
  if instance:IsInGangMap() then
    instance:CheckPrepare()
    if instance.goToMakeUp then
      GameUtil.AddGlobalTimer(0, true, function()
        instance:GotoCosplay()
      end)
      instance.goToMakeUp = false
    end
    instance:ShowQuestion()
  else
    instance:LeaveMakeUp()
    instance:StopMakeupRoundEffect()
  end
end
def.static("table", "table").OnClickChatBtn = function(p1, p2)
  local tag = p1.id
  if tag == ANNIVERSARY_PARADE then
    instance:GotoParade()
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CMakeUpConsts.ACTIVITY_ID then
    Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, AnniversaryModule.OnChangeMap)
    if instance:IsInGangMap() then
      instance:CheckPrepare()
    end
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CMakeUpConsts.ACTIVITY_ID then
    instance:EndMakeUp()
  end
end
return AnniversaryModule.Commit()
