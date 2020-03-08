local Lplus = require("Lplus")
local BandstandMgr = Lplus.Class("BandstandMgr")
local NPCInterface = require("Main.npc.NPCInterface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = BandstandMgr.define
local instance
def.field("number").curMusicId = 0
def.field("number").curFragmentIdx = 0
def.field("table").curAnswerSequence = nil
def.field("table").fragmentInfoMap = nil
def.field("number").startTime = 0
def.static("=>", BandstandMgr).Instance = function()
  if instance == nil then
    instance = BandstandMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bandstand.SStartBandstandSuccess", BandstandMgr.OnSStartBandstandSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bandstand.SStartBandstandFail", BandstandMgr.OnSStartBandstandFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bandstand.SBandstandAnswerSuccess", BandstandMgr.OnSBandstandAnswerSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bandstand.SBandstandAnswerFail", BandstandMgr.OnSBandstandAnswerFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bandstand.SEndBandstandSuccess", BandstandMgr.OnSEndBandstandSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bandstand.SEndBandstandFail", BandstandMgr.OnSEndBandstandFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bandstand.SNotifyBandstandEnd", BandstandMgr.OnSNotifyBandstandEnd)
  self:registerNpcServiceCondition()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, BandstandMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, BandstandMgr.OnNpcNomalServer)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, BandstandMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, BandstandMgr.OnFeatureOpenInit)
end
def.method().registerNpcServiceCondition = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BANDSTAND_ACTIVITY_CFG)
  if entries == nil then
    return
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local npcInterface = NPCInterface.Instance()
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local serviceId = record:GetIntValue("serviceId")
    npcInterface:RegisterNPCServiceCustomCondition(serviceId, BandstandMgr.OnNPCService_GetBandstandCondition)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static("number", "=>", "boolean").OnNPCService_GetBandstandCondition = function(serviceId)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_BANDSTAND) then
    return false
  end
  local activityId = BandstandMgr.GetBandstandServiceId2ActivityId(serviceId)
  local activityInterface = ActivityInterface.Instance()
  if activityInterface:isAchieveActivityLevel(activityId) and activityInterface:isActivityOpend2(activityId) then
    return true
  end
  return false
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  local bandstandCfg = BandstandMgr.GetBandstandActivityCfg(activityId)
  if bandstandCfg then
    warn("----->>>>>>bandstandCfg OnActivityTodo:", activityId, bandstandCfg.npcId)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      bandstandCfg.npcId
    })
  end
end
def.static("table", "table").OnNpcNomalServer = function(p1, p2)
  local serviceId = p1[1]
  local activityId = BandstandMgr.GetBandstandServiceId2ActivityId(serviceId)
  if activityId and activityId > 0 then
    local BandstandPanel = require("Main.activity.Bandstand.ui.BandstandPanel")
    BandstandPanel.Instance():ShowPanel(activityId)
  end
end
def.static("table").OnSStartBandstandSuccess = function(p)
  warn("--------->>OnSStartBandstandSuccess:", p.activity_id, p.start_fragment_index, p.start_time)
  instance.curMusicId = p.music_id
  instance.curFragmentIdx = p.start_fragment_index
  instance.fragmentInfoMap = p.fragment_info_map
  instance.startTime = p.start_time
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Bandstand_Muisc_Start, nil)
end
def.static("table").OnSStartBandstandFail = function(p)
  warn("----OnSStartBandstandFail:", p.error_code)
  local str = textRes.activity.StartBandstandFail[p.error_code]
  if str then
    Toast(str)
  end
  local BandstandPanel = require("Main.activity.Bandstand.ui.BandstandPanel")
  local bandstandPanel = BandstandPanel.Instance()
  if bandstandPanel:IsShow() then
    bandstandPanel:Hide()
  end
end
def.static("table").OnSBandstandAnswerSuccess = function(p)
  warn("-----OnSBandstandAnswerSuccess:", p.result)
  if p.result == 1 and p.get_reward == 0 then
    Toast(textRes.activity.Bandstand[2])
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Bandstand_Answer_Result, {
    result = p.result,
    idx = p.answer_index
  })
end
def.static("table").OnSBandstandAnswerFail = function(p)
  warn("!!!!!!OnSBandstandAnswerFail:", p.error_code)
end
def.static("table").OnSEndBandstandSuccess = function(p)
  warn("------OnSEndBandstandSuccess")
end
def.static("table").OnSEndBandstandFail = function(p)
  warn("!!!!!!!OnSEndBandstandFail:", p.error_code)
end
def.static("table").OnSNotifyBandstandEnd = function(p)
  warn("-----OnSNotifyBandstandEnd")
  local BandstandPanel = require("Main.activity.Bandstand.ui.BandstandPanel")
  local bandstandPanel = BandstandPanel.Instance()
  if bandstandPanel:IsShow() then
    bandstandPanel:Hide()
  end
end
def.static("number", "=>", "table").GetBandstandActivityCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BANDSTAND_ACTIVITY_CFG, activityId)
  if record == nil then
    warn("!!!!!GetBandstandActivityCfg(" .. activityId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.activityId = activityId
  cfg.npcId = record:GetIntValue("npcId")
  cfg.serviceId = record:GetIntValue("serviceId")
  cfg.awardId = record:GetIntValue("awardId")
  cfg.dailyAwardCount = record:GetIntValue("dailyAwardCount")
  cfg.halfBodyIconId = record:GetIntValue("halfBodyIconId")
  cfg.musicIds = {}
  local musicIdStruct = record:GetStructValue("musicIdStruct")
  local size = musicIdStruct:GetVectorSize("musicIds")
  for i = 0, size - 1 do
    local rec = musicIdStruct:GetVectorValueByIdx("musicIds", i)
    local musicId = rec:GetIntValue("musicId")
    table.insert(cfg.musicIds, musicId)
  end
  return cfg
end
def.static("number", "=>", "number").GetBandstandServiceId2ActivityId = function(serviceId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BNADSTAND_SERVICEID_2_ACTIVITYID_CFG, serviceId)
  if record == nil then
    warn("!!!!!GetBandstandServiceId2ActivityId(" .. serviceId .. ") return nil")
    return 0
  end
  return record:GetIntValue("activityId")
end
def.static("number", "=>", "table").GetBandstandMusicCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BANDSTAND_MUSIC_CFG, id)
  if record == nil then
    warn("!!!!!GetBandstandServiceId2ActivityId(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.musicName = record:GetStringValue("musicName")
  cfg.singerName = record:GetStringValue("singerName")
  cfg.albumName = record:GetStringValue("albumName")
  cfg.fragments = {}
  local fragmentStruct = record:GetStructValue("fragmentStruct")
  local size = fragmentStruct:GetVectorSize("fragments")
  cfg.fragmentNum = size
  for i = 0, size - 1 do
    local rec = fragmentStruct:GetVectorValueByIdx("fragments", i)
    local t = {}
    t.index = rec:GetIntValue("index")
    t.fragmentType = rec:GetIntValue("fragmentType")
    t.musicCfgId = rec:GetIntValue("musicCfgId")
    t.musicTime = rec:GetIntValue("musicTime")
    t.lyric = rec:GetStringValue("lyric")
    t.answers = {}
    local answerStruct = rec:GetStructValue("answerStruct")
    local num = answerStruct:GetVectorSize("answers")
    for n = 0, num - 1 do
      local rec1 = answerStruct:GetVectorValueByIdx("answers", n)
      local answer = rec1:GetStringValue("answer")
      table.insert(t.answers, answer)
    end
    cfg.fragments[t.index] = t
  end
  return cfg
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  BandstandMgr.SetBandstandActivityOpend()
end
def.static().SetBandstandActivityOpend = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BANDSTAND_ACTIVITY_CFG)
  if entries == nil then
    return
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local npcInterface = NPCInterface.Instance()
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = ActivityInterface.Instance()
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityId = record:GetIntValue("activityId")
    if _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BANDSTAND) then
      activityInterface:removeCustomCloseActivity(activityId)
    else
      activityInterface:addCustomCloseActivity(activityId)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local openId = ModuleFunSwitchInfo.TYPE_BANDSTAND
  if p1.feature == openId then
    BandstandMgr.SetBandstandActivityOpend()
  end
end
def.method("number", "=>", "table").getAnswerList = function(self, fragmentIdx)
  if self.fragmentInfoMap then
    local info = self.fragmentInfoMap[fragmentIdx]
    if info then
      return info.answer_sequence
    end
  end
  return nil
end
return BandstandMgr.Commit()
