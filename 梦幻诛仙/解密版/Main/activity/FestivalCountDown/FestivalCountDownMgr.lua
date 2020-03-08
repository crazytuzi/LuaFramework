local Lplus = require("Lplus")
local MathHelper = require("Common.MathHelper")
local GUIFxMan = require("Fx.GUIFxMan")
local NpcSendMoney = require("Main.Marriage.ui.NpcSendMoney")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FestivalCountDownUtils = require("Main.activity.FestivalCountDown.FestivalCountDownUtils")
local FestivalCountDownMgr = Lplus.Class("FestivalCountDownMgr")
local def = FestivalCountDownMgr.define
def.field("table").m_FestivalCfgList = nil
def.field("table").m_FestivalTimerList = nil
def.field("table").m_RedPacketTimerList = nil
def.field("table").m_FxList = nil
def.field("table").m_MapEffectCfg = nil
def.field("table").m_MapFxTimerList = nil
def.field("table").m_NotGetRedPacketCfgIds = nil
def.field("table").m_ValidNotGetRedPacketCfgIds = nil
def.field("table").m_NotGetRedPacketTimerList = nil
local instance
def.static("=>", FestivalCountDownMgr).Instance = function()
  if nil == instance then
    instance = FestivalCountDownMgr()
    instance.m_FestivalCfgList = nil
    instance.m_FestivalTimerList = nil
    instance.m_RedPacketTimerList = nil
    instance.m_FxList = nil
    instance.m_MapEffectCfg = nil
    instance.m_MapFxTimerList = nil
    instance.m_NotGetRedPacketCfgIds = nil
    instance.m_ValidNotGetRedPacketCfgIds = nil
    instance.m_NotGetRedPacketTimerList = nil
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.countdown.SGetCountDownRedPacketSuccess", FestivalCountDownMgr.OnSGetCountDownRedPacketSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.countdown.SGetCountDownRedPacketFail", FestivalCountDownMgr.OnSGetCountDownRedPacketFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.countdown.SSynCountDownInfo", FestivalCountDownMgr.OnSSynCountDownInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, FestivalCountDownMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FestivalCountDownMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.CHANGE_MAP_LOADING_FINISHED, FestivalCountDownMgr.OnMapChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, FestivalCountDownMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, FestivalCountDownMgr.OnMainUIShow)
end
def.method().StartUp = function(self)
  if not _G.IsFeatureOpen(Feature.TYPE_COUNT_DOWN) then
    return
  end
  self.m_FestivalCfgList, self.m_MapEffectCfg = FestivalCountDownUtils.GetAllValidCfg()
  if nil == self.m_FestivalCfgList or 0 == MathHelper.CountTable(self.m_FestivalCfgList) then
    self:UpdateFestivalMapEffect()
    return
  end
  self.m_FestivalTimerList = {}
  self.m_RedPacketTimerList = {}
  self.m_FxList = {}
  local curTime = _G.GetServerTime()
  for k, v in pairs(self.m_FestivalCfgList) do
    self.m_FestivalTimerList[k] = {}
    do
      local timerCache = self.m_FestivalTimerList[k]
      local bulletinLeftTime = v.bulletinBeginTime - curTime
      local countdownLeftTime = v.countdownEffectBeginTime - curTime
      local festivalLeftTime = v.festivalBeginTime - curTime
      local festivalEffectPlayTime = v.festivalEffectPlayTime
      local mapEffectLeftTime = v.mapEffectBeginTime - curTime
      local festivalSoundId = v.festivalSoundId
      local countdownEffectId = v.countdownEffectId
      local festivalEffectId = v.festivalEffectId
      local redPacketIconId = v.redPacketIconId
      local redPacketDesc = v.redPacketDesc
      self:SetUpAnnounceMentTimer(k, v.bulletinBeginTime, v.bulletinInterval, v.countdownEffectBeginTime, v.cfgDesc)
      if countdownLeftTime > 0 then
        timerCache.countdownTimer = 0
        timerCache.countdownTimer = AbsoluteTimer.AddListener(countdownLeftTime, 0, function()
          self:PlayFestivalCountDownEffect(k, countdownEffectId)
          timerCache.countdownTimer = 0
        end, nil, 0)
      end
      if festivalLeftTime > 0 then
        timerCache.festivalTimer = 0
        timerCache.festivalTimer = AbsoluteTimer.AddListener(festivalLeftTime, 0, function()
          self:PlayFestivalEffect(k, festivalEffectId, festivalEffectPlayTime, redPacketIconId, redPacketDesc)
          self:PlayFestivalSound(k, festivalSoundId)
          timerCache.festivalTimer = 0
        end, nil, 0)
      end
      if mapEffectLeftTime > 0 then
        timerCache.mapEffectTimer = 0
        timerCache.mapEffectTimer = AbsoluteTimer.AddListener(mapEffectLeftTime, 0, function()
          warn("********** start to play festival map effect ***********")
          self:UpdateFestivalMapEffect()
          timerCache.mapEffectTimer = 0
        end, nil, 2)
      end
    end
  end
  self:UpdateFestivalMapEffect()
end
def.method("number", "number", "number", "number", "string").SetUpAnnounceMentTimer = function(self, cfgId, announceBeginTime, announceInterval, announceEndTime, announceMent)
  local curTime = _G.GetServerTime()
  if announceEndTime <= curTime then
    return
  end
  local allTime = announceEndTime - announceBeginTime
  local count = math.floor(allTime / announceInterval)
  local index = -1
  for i = 0, count do
    if curTime < announceBeginTime + i * announceInterval then
      index = i
      break
    end
  end
  warn("~~~~~~~~~~SetUpAnnounceMentTimer~~~~~~~~~", index, count)
  if -1 ~= index then
    self.m_FestivalTimerList[cfgId].bulletinTimers = {}
    do
      local cache = self.m_FestivalTimerList[cfgId].bulletinTimers
      for i = 1, count - index + 1 do
        do
          local leftTime = (index + i - 1) * announceInterval + announceBeginTime - _G.GetServerTime()
          cache[i] = AbsoluteTimer.AddListener(leftTime, 0, function()
            self:FestivalAnnounce(announceMent)
            cache[i] = 0
          end, nil, 0)
        end
      end
    end
  end
end
def.method("string").FestivalAnnounce = function(self, announceDesc)
  warn("~~~~~~~~~ FestivalAnnounce ~~~~~~~~~~", announceDesc)
  require("Main.Announcement.AnnouncementModule").AnnounceFestivalCountDown(announceDesc)
end
def.method("number", "number").PlayFestivalSound = function(self, cfgId, soundId)
  warn("~~~~~~~~~ PlayFestivalSound ~~~~~~~~~", cfgId, " ", soundId)
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():Play2DSoundByID(soundId)
end
def.method("number", "number").PlayFestivalCountDownEffect = function(self, cfgId, countdownEffectId)
  warn("~~~~~~~~~~~~PlayFestivalCountDownEffect~~~~~~~~~~~~~~", cfgId, " ", countdownEffectId)
  local effectCfg = GetEffectRes(countdownEffectId)
  if nil == effectCfg then
    warn("festival count down effet cfg is nil ~~~~~~~~~~~~ ")
    return
  end
  local fx = GUIFxMan.Instance():Play(effectCfg.path, "countdowneffect", 0, 0, 10, false)
  if nil == self.m_FxList then
    self.m_FxList = {}
  end
  if nil == self.m_FxList[cfgId] then
    self.m_FxList[cfgId] = {}
  end
  self.m_FxList[cfgId].countdownFx = fx
end
def.method("number", "number", "number", "number", "string").PlayFestivalEffect = function(self, cfgId, festivalEffectId, effctPlayTime, redPacketIconId, redPacketDesc)
  warn("~~~~~~~~~PlayFestivalEffect~~~~~~~~~~~", cfgId, festivalEffectId, effctPlayTime, redPacketIconId, redPacketDesc)
  local effectCfg = GetEffectRes(festivalEffectId)
  if nil == effectCfg then
    warn("festicval effect cfg is nil ~~~~~~~~~~~~ ")
    return
  end
  local fx = GUIFxMan.Instance():Play(effectCfg.path, "festivaleffect", 0, 0, effctPlayTime, false)
  if nil == self.m_FxList then
    self.m_FxList = {}
  end
  if nil == self.m_FxList[cfgId] then
    self.m_FxList[cfgId] = {}
  end
  self.m_FxList[cfgId].festivalFx = fx
  if nil == self.m_RedPacketTimerList then
    self.m_RedPacketTimerList = {}
  end
  self.m_RedPacketTimerList[cfgId] = 0
  local randomDelayTime = math.random(0, 2)
  self.m_RedPacketTimerList[cfgId] = AbsoluteTimer.AddListener(effctPlayTime + randomDelayTime, 0, function()
    self:ShowRedPacket(cfgId, redPacketIconId, redPacketDesc)
    self.m_RedPacketTimerList[cfgId] = 0
  end, nil, 0)
end
def.method().RePlayFestivalEffectAndGiveRedPacket = function(self)
  if not _G.IsFeatureOpen(Feature.TYPE_COUNT_DOWN) then
    return
  end
  if nil == self.m_NotGetRedPacketCfgIds or 0 == MathHelper.CountTable(self.m_NotGetRedPacketCfgIds) then
    return
  end
  self.m_ValidNotGetRedPacketCfgIds = FestivalCountDownUtils.CheckValidNotGetRedPacketCfgId(self.m_NotGetRedPacketCfgIds)
  if nil == self.m_ValidNotGetRedPacketCfgIds or 0 == MathHelper.CountTable(self.m_ValidNotGetRedPacketCfgIds) then
    return
  end
  local index = 1
  local deltaTime = 3
  local allNeedTime = deltaTime
  for k, v in pairs(self.m_ValidNotGetRedPacketCfgIds) do
    if nil == self.m_NotGetRedPacketTimerList then
      self.m_NotGetRedPacketTimerList = {}
    end
    self.m_NotGetRedPacketTimerList[k] = 0
    self.m_NotGetRedPacketTimerList[k] = AbsoluteTimer.AddListener(allNeedTime, 0, function()
      self:PlayFestivalSound(k, v.festivalSoundId)
      self:PlayFestivalEffect(k, v.festivalEffectId, v.festivalEffectPlayTime, v.redPacketIconId, v.redPacketDesc)
      self.m_NotGetRedPacketTimerList[k] = 0
    end, nil, 0)
    allNeedTime = allNeedTime + v.festivalEffectPlayTime + 5 + deltaTime
  end
end
def.method("number", "number", "string").ShowRedPacket = function(self, cfgId, redPacketIconId, redPacketDesc)
  local function callback()
    local p = require("netio.protocol.mzm.gsp.countdown.CGetCountDownRedPacketReq").new(cfgId)
    gmodule.network.sendProtocol(p)
  end
  NpcSendMoney.ShowNpcSendMoney(redPacketIconId, 5, redPacketDesc, callback)
end
def.method().StopAndClear = function(self)
  self:StopTimer()
  self:RemoveAllFxs()
  self:Clear()
end
def.method().StopTimer = function(self)
  if self.m_FestivalTimerList then
    for k, v in pairs(self.m_FestivalTimerList) do
      if nil ~= v.bulletinTimers then
        for k1, v1 in pairs(v.bulletinTimers) do
          if 0 ~= v1 then
            AbsoluteTimer.RemoveListener(v1)
            v.bulletinTimers[k1] = 0
          end
        end
      end
      if v.countdownTimer and 0 ~= v.countdownTimer then
        AbsoluteTimer.RemoveListener(v.countdownTimer)
        v.countdownTimer = 0
      end
      if v.festivalTimer and 0 ~= v.festivalTimer then
        AbsoluteTimer.RemoveListener(v.festivalTimer)
        v.festivalTimer = 0
      end
      if v.mapEffectTimer and 0 ~= v.mapEffectTimer then
        AbsoluteTimer.RemoveListener(v.mapEffectTimer)
        v.mapEffectTimer = 0
      end
    end
  end
  if self.m_RedPacketTimerList then
    for k, v in pairs(self.m_RedPacketTimerList) do
      if 0 ~= v then
        AbsoluteTimer.RemoveListener(v)
        self.m_RedPacketTimerList[k] = 0
      end
    end
  end
  if self.m_MapFxTimerList then
    for k, v in pairs(self.m_MapFxTimerList) do
      if 0 ~= v then
        AbsoluteTimer.RemoveListener(v)
        self.m_MapFxTimerList[k] = 0
      end
    end
  end
  if self.m_NotGetRedPacketTimerList then
    for k, v in pairs(self.m_NotGetRedPacketTimerList) do
      if 0 ~= v then
        AbsoluteTimer.RemoveListener(v)
        self.m_NotGetRedPacketTimerList[k] = 0
      end
    end
  end
end
def.method().RemoveAllFxs = function(self)
  if self.m_FxList then
    for k, v in pairs(self.m_FxList) do
      if v.countdownFx and not v.countdownFx.isnil then
        GUIFxMan.Instance():RemoveFx(v.countdownFx)
        v.countdownFx = nil
      end
      if v.festivalFx and not v.festivalFx.isnil then
        GUIFxMan.Instance():RemoveFx(v.festivalFx)
        v.festivalFx = nil
      end
      if v.mapFx and not v.mapFx.isnil then
        GUIFxMan.Instance():RemoveFx(v.mapFx)
        v.mapFx = nil
      end
    end
    self.m_FxList = nil
  end
end
def.method("number").RemoveMapEffectFx = function(self, cfgId)
  if self.m_FxList and self.m_FxList[cfgId] and self.m_FxList[cfgId].mapFx and not self.m_FxList[cfgId].mapFx.isnil then
    GUIFxMan.Instance():RemoveFx(self.m_FxList[cfgId].mapFx)
    self.m_FxList[cfgId].mapFx = nil
  end
end
def.method().Clear = function(self)
  self.m_FestivalCfgList = nil
  self.m_MapEffectCfg = nil
  self.m_FestivalTimerList = nil
  self.m_RedPacketTimerList = nil
  self.m_FxList = nil
  self.m_MapFxTimerList = nil
  self.m_NotGetRedPacketTimerList = nil
  self.m_NotGetRedPacketCfgIds = nil
  self.m_ValidNotGetRedPacketCfgIds = nil
end
def.method().UpdateFestivalMapEffect = function(self)
  if not _G.IsFeatureOpen(Feature.TYPE_COUNT_DOWN) then
    return
  end
  if nil == self.m_MapEffectCfg or 0 == MathHelper.CountTable(self.m_MapEffectCfg) then
    return
  end
  if nil == self.m_MapFxTimerList then
    self.m_MapFxTimerList = {}
  end
  if nil == self.m_FxList then
    self.m_FxList = {}
  end
  local curTime = _G.GetServerTime()
  local function IsShouldPlayMapEffect(beginTime, endTime, maps)
    if beginTime <= curTime and endTime > curTime then
      if nil == maps then
        return false
      end
      local curMapId = gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId
      local isRightMap = false
      for k, v in pairs(maps) do
        if v == curMapId then
          isRightMap = true
          break
        end
      end
      return isRightMap
    else
      return false
    end
  end
  for k, v in pairs(self.m_MapEffectCfg) do
    do
      local mapEffectBeginTime = v.mapEffectBeginTime
      local mapEffectEndTime = v.mapEffectEndTime
      local effectMaps = v.effectMaps
      self:RemoveMapFxAndTimer(k)
      if IsShouldPlayMapEffect(mapEffectBeginTime, mapEffectEndTime, effectMaps) then
        local effectCfg = GetEffectRes(v.mapEffectId)
        if nil == effectCfg then
          warn("map effect is nil ~~~~~~~~~~ ")
          return
        end
        if nil == self.m_FxList[k] then
          self.m_FxList[k] = {}
        end
        self.m_FxList[k].mapFx = GUIFxMan.Instance():Play(effectCfg.path, "festivalMapEffect", 0, 0, -1, false)
        self.m_MapFxTimerList[k] = 0
        self.m_MapFxTimerList[k] = AbsoluteTimer.AddListener(mapEffectEndTime - curTime, 0, function()
          self:RemoveMapFxAndTimer(k)
        end, nil, 0)
      end
    end
  end
end
def.method("number").RemoveMapFxAndTimer = function(self, cfgId)
  if self.m_FxList and self.m_FxList[cfgId] and self.m_FxList[cfgId].mapFx and not self.m_FxList[cfgId].mapFx.isnil then
    GUIFxMan.Instance():RemoveFx(self.m_FxList[cfgId].mapFx)
    self.m_FxList[cfgId].mapFx = nil
  end
  if self.m_MapFxTimerList and self.m_MapFxTimerList[cfgId] and 0 ~= self.m_MapFxTimerList[cfgId] then
    AbsoluteTimer.RemoveListener(self.m_MapFxTimerList[cfgId])
    self.m_MapFxTimerList[cfgId] = 0
  end
end
def.method().printCfgInfo = function(self)
  warn("!!!!!!!! printCfgInfo !!!!!!!!!!")
  if self.m_FestivalCfgList then
    for k, v in pairs(self.m_FestivalCfgList) do
      warn("!!!!!!!!!m_FestivalCfgList!!!!!!!!!", k, " ", v)
    end
  end
  if self.m_MapEffectCfg then
    for k, v in pairs(self.m_MapEffectCfg) do
      warn("!!!!!!!!!!!m_MapEffectCfg!!!!!!!!!!!!!", k, "  ", v)
    end
  end
end
def.method().printListInfo = function(self)
  warn("************ printListInfo *************")
  if self.m_FxList then
    for k, v in pairs(self.m_FxList) do
      warn("********** FxList ************", k, " ", v)
      for k1, v1 in pairs(v) do
        warn("**********FxList Detail ***********", k1, " ", v1)
      end
    end
  end
  if self.m_FestivalTimerList then
    for k, v in pairs(self.m_FestivalTimerList) do
      warn("***********m_FestivalTimerList**********", k, " ", v)
      for k1, v1 in pairs(v) do
        warn("*********m_FestivalTimerList Detail**********", k1, " ", v1)
        if k1 == "bulletinTimers" then
          for k2, v2 in pairs(v1) do
            warn("****************bulletinTimers Details****************", k2, " ", v2)
          end
        end
      end
    end
  end
  if self.m_MapFxTimerList then
    for k, v in pairs(self.m_MapFxTimerList) do
      warn("*********m_MapFxTimerList**********", k, " ", v)
    end
  end
end
def.method().printNotGetRedPacketList = function(self)
  if self.m_NotGetRedPacketCfgIds then
    for k, v in pairs(self.m_NotGetRedPacketCfgIds) do
      warn("**********m_NotGetRedPacketCfgIds* ", v)
    end
  end
  if self.m_ValidNotGetRedPacketCfgIds then
    for k, v in pairs(self.m_ValidNotGetRedPacketCfgIds) do
      warn("***********m_ValidNotGetRedPacketCfgIds* ", k, " ", v)
    end
  end
  if self.m_NotGetRedPacketTimerList then
    for k, v in pairs(self.m_NotGetRedPacketTimerList) do
      warn("**********m_NotGetRedPacketTimerList* ", k, " ", v)
    end
  end
end
def.static("table", "table").OnMapChange = function(p1, p2)
  local self = FestivalCountDownMgr.Instance()
  self:UpdateFestivalMapEffect()
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local self = FestivalCountDownMgr.Instance()
  self:StartUp()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = FestivalCountDownMgr.Instance()
  self:StopAndClear()
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  local featureType = p1.feature
  local isOpen = p1.open
  if featureType == Feature.TYPE_COUNT_DOWN then
    local self = FestivalCountDownMgr.Instance()
    if isOpen then
      self:StartUp()
      self:RePlayFestivalEffectAndGiveRedPacket()
    else
      self:StopAndClear()
    end
  end
end
def.static("table", "table").OnMainUIShow = function(p1, p2)
  local self = FestivalCountDownMgr.Instance()
  self:RePlayFestivalEffectAndGiveRedPacket()
end
def.static("table").OnSGetCountDownRedPacketSuc = function(p)
  warn("~~~~~~~OnSGetCountDownRedPacketSuc~~~~~~~~~", p)
  Toast(textRes.activity.festivalCountDown[1])
end
def.static("table").OnSGetCountDownRedPacketFail = function(p)
  warn("~~~~~~~~OnSGetCountDownRedPacketFail~~~~~~~", p, p.res)
  local errMsg = textRes.activity.festivalCountDown.RedPacketError[p.res]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSSynCountDownInfo = function(p)
  warn("~~~~~~~~~OnSSynCountDownInfo~~~~~~~~~~", p, p.not_get_red_packet_cfg_ids)
  local self = FestivalCountDownMgr.Instance()
  self.m_NotGetRedPacketCfgIds = p.not_get_red_packet_cfg_ids
end
FestivalCountDownMgr.Commit()
return FestivalCountDownMgr
