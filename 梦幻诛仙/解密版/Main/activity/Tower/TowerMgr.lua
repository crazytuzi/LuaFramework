local Lplus = require("Lplus")
local TowerMgr = Lplus.Class("TowerMgr")
local def = TowerMgr.define
local instance
def.static("=>", TowerMgr).Instance = function()
  if instance == nil then
    instance = TowerMgr()
  end
  return instance
end
def.field("table").relatedActivity = nil
def.field("table").relatedSwitch = nil
def.field("table").data = nil
def.field("table").historyData = nil
def.field("table").firstRequest = nil
def.field("table").fastRequest = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floor.SSynRoleActivtyInfo", TowerMgr.OnSSynRoleActivtyInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floor.SChallengeSuc", TowerMgr.OnSChallengeSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floor.SGetFirstBloodBro", TowerMgr.OnSGetFirstBloodBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floor.SFastKillBro", TowerMgr.OnSFastKillBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floor.SCheckFirstBloodRep", TowerMgr.OnSCheckFirstBloodRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floor.SCheckFastFightRep", TowerMgr.OnSCheckFastFightRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floor.SFloorNormalResult", TowerMgr.OnSFloorNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floor.SFloorHelpTip", TowerMgr.OnSFloorHelpTip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floor.SSweepFloorSuc", TowerMgr.OnSSweepFloorSuc)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, TowerMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, TowerMgr.OnActivityReset)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.FLOOR_ITEM_USE, TowerMgr.OnSweepItemUse)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TowerMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, TowerMgr.OnFeatureOpenInit)
  self:InitRelatedActivity()
end
def.method().Reset = function(self)
  self.data = nil
  self.historyData = nil
  self.firstRequest = nil
  self.fastRequest = nil
end
def.method("number", "=>", "table").GetActivityFloors = function(self, activity)
  local floors = {}
  local floorCfg = self:GetTowerFloorCfg(activity)
  for k, v in ipairs(floorCfg.floors) do
    local open = IsFeatureOpen(v.floorOpenId)
    if open then
      table.insert(floors, k)
    end
  end
  return floors
end
def.method("number", "number", "=>", "table").GetFloorData = function(self, activityId, floor)
  if self.data then
    if self.data[activityId] then
      if self.data[activityId][floor] then
        return self.data[activityId][floor]
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end
def.method("number", "number", "=>", "boolean").CanFight = function(self, activityId, floor)
  local floorCfg = self:GetTowerFloorCfg(activityId)
  for i = floor - 1, 1, -1 do
    local open = IsFeatureOpen(floorCfg.floors[i].floorOpenId)
    if open and (self.data == nil or self.data[activityId] == nil or self.data[activityId][i] == nil or self.data[activityId][i].usedTime == nil or self.data[activityId][i].usedTime < 0) then
      return false
    end
  end
  return true
end
def.method().InitRelatedActivity = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TOWER_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  self.relatedActivity = {}
  self.relatedSwitch = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityId = entry:GetIntValue("activityId")
    local openId = entry:GetIntValue("activityOpenId")
    self.relatedActivity[activityId] = openId
    self.relatedSwitch[openId] = activityId
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "=>", "table").GetTowerActivityCfg = function(self, actId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TOWER_ACTIVITY_CFG, actId)
  if record == nil then
    warn("GetTowerActivityCfg nil", actId)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.activityOpenId = record:GetIntValue("activityOpenId")
  cfg.tipsId = record:GetIntValue("tipsId")
  cfg.canSweep = record:GetCharValue("canSweep") ~= 0
  cfg.sweepSwithId = record:GetIntValue("sweepSwithId")
  cfg.sweepCostItemId = record:GetIntValue("sweepCostItemId")
  cfg.sweepSucEffectId = record:GetIntValue("sweepSucEffectId")
  return cfg
end
def.method("number", "=>", "table").GetTowerFloorCfg = function(self, actId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TOWER_FLOOR_CFG, actId)
  if record == nil then
    warn("GetTowerFloorCfg nil", actId)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.floors = {}
  local floorStruct = record:GetStructValue("floorStruct")
  local floorSize = floorStruct:GetVectorSize("floorList")
  for i = 0, floorSize - 1 do
    local rec = floorStruct:GetVectorValueByIdx("floorList", i)
    local floorInfo = {}
    floorInfo.floorName = rec:GetStringValue("floorName")
    floorInfo.joinLevel = rec:GetIntValue("joinLevel")
    floorInfo.headIconId = rec:GetIntValue("headIconId")
    floorInfo.describe = rec:GetStringValue("describe")
    floorInfo.floorOpenId = rec:GetIntValue("floorOpenId")
    floorInfo.awardItems = {}
    local awardStruct = rec:GetStructValue("awardItemStruct")
    local awardSize = awardStruct:GetVectorSize("awardItemList")
    for i = 0, awardSize - 1 do
      local r = awardStruct:GetVectorValueByIdx("awardItemList", i)
      local itemId = r:GetIntValue("itemId")
      table.insert(floorInfo.awardItems, itemId)
    end
    floorInfo.canSweep = rec:GetCharValue("canSweep") ~= 0
    floorInfo.sweepFightValue = rec:GetIntValue("sweepFightValue")
    floorInfo.sweepCostNum = rec:GetIntValue("sweepCostNum")
    table.insert(cfg.floors, floorInfo)
  end
  return cfg
end
def.method("number", "number", "function").RequestFirstBloodData = function(self, activityId, floor, cb)
  if self.data and self.data[activityId] and self.data[activityId][floor] and self.data[activityId][floor].firstBlood then
    cb(self.data[activityId][floor].firstBlood)
    return
  end
  if self.firstRequest == nil then
    self.firstRequest = {}
  end
  local uniqueKey = tostring(activityId) .. tostring(floor)
  if self.firstRequest[uniqueKey] == nil then
    self.firstRequest[uniqueKey] = {}
  end
  table.insert(self.firstRequest[uniqueKey], cb)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.floor.CCheckFirstBloodReq").new(activityId, floor))
end
def.method("number", "number", "function").RequestFastKillData = function(self, activityId, floor, cb)
  if self.data and self.data[activityId] and self.data[activityId][floor] and self.data[activityId][floor].fastKill then
    cb(self.data[activityId][floor].fastKill)
    return
  end
  if self.fastRequest == nil then
    self.fastRequest = {}
  end
  local uniqueKey = tostring(activityId) .. tostring(floor)
  if self.fastRequest[uniqueKey] == nil then
    self.fastRequest[uniqueKey] = {}
  end
  table.insert(self.fastRequest[uniqueKey], cb)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.floor.CCheckFastFightReq").new(activityId, floor))
end
def.method("number", "number").PlayFirstBloodFightRecord = function(self, activityId, floor)
  local switch = self.relatedActivity[activityId]
  if switch and not IsFeatureOpen(switch) then
    Toast(textRes.activity[907])
    return
  end
  if not self:IsFloorOpen(activityId, floor) then
    Toast(textRes.activity[906])
    return
  end
  local isOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LUN_HUI_XU_KONG__CHECK_RECORD)
  if isOpen then
    if require("Utility.DeviceUtility").IsNetStreamBufferBugFixed() then
      local p = require("netio.protocol.mzm.gsp.floor.CPlayFirstBloodReq").new(activityId, floor)
      gmodule.network.sendProtocol(p)
    else
      local CommonConfirm = require("GUI.CommonConfirmDlg")
      CommonConfirm.ShowCerternConfirm(textRes.Common[602], textRes.Common[601], "", nil, nil)
    end
  end
end
def.method("number", "number").PlayFastKillFightRecord = function(self, activityId, floor)
  local switch = self.relatedActivity[activityId]
  if switch and not IsFeatureOpen(switch) then
    Toast(textRes.activity[907])
    return
  end
  if not self:IsFloorOpen(activityId, floor) then
    Toast(textRes.activity[906])
    return
  end
  local isOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LUN_HUI_XU_KONG__CHECK_RECORD)
  if isOpen then
    if require("Utility.DeviceUtility").IsNetStreamBufferBugFixed() then
      local p = require("netio.protocol.mzm.gsp.floor.CPlayFastKillReq").new(activityId, floor)
      gmodule.network.sendProtocol(p)
    else
      local CommonConfirm = require("GUI.CommonConfirmDlg")
      CommonConfirm.ShowCerternConfirm(textRes.Common[602], textRes.Common[601], "", nil, nil)
    end
  end
end
def.method("number", "number").FightFloor = function(self, activityId, floor)
  if _G.PlayerIsInFight() then
    Toast(textRes.activity[379])
    return
  end
  local switch = self.relatedActivity[activityId]
  if switch and not IsFeatureOpen(switch) then
    Toast(textRes.activity[907])
    return
  end
  if not self:IsFloorOpen(activityId, floor) then
    Toast(textRes.activity[906])
    return
  end
  if not self:CheckActivityCondition(activityId, floor) then
    return
  end
  if not self:CanFight(activityId, floor) then
    Toast(textRes.activity[913])
    return
  end
  local p = require("netio.protocol.mzm.gsp.floor.CChallengeFloorReq").new(activityId, floor)
  gmodule.network.sendProtocol(p)
end
def.method("number", "number", "=>", "boolean").IsFloorOpen = function(self, activityId, floor)
  local floorCfg = self:GetTowerFloorCfg(activityId)
  local open = IsFeatureOpen(floorCfg.floors[floor].floorOpenId)
  return open
end
def.method("number", "number", "=>", "boolean").CheckActivityCondition = function(self, actId, floor)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local actCfg = ActivityInterface.GetActivityCfgById(actId)
  local floorCfg = self:GetTowerFloorCfg(actId)
  local fCfg = floorCfg.floors[floor]
  local TeamData = require("Main.Team.TeamData")
  if actCfg.personMin == 1 and actCfg.personMax == 1 and not cfg.couldBeSingleTeam and TeamData.Instance():HasTeam() then
    Toast(textRes.activity[937])
    return false
  end
  local members
  if TeamData.Instance():HasTeam() then
    if not actCfg.couldBeSingleTeam then
    else
    end
    if not TeamData.Instance():MeIsAFK() then
      members = TeamData.Instance():GetNormalMembers()
    end
  else
    local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    members = {
      {
        level = heroProp.level,
        name = heroProp.name
      }
    }
  end
  local membersCount = #members
  if membersCount < actCfg.personMin or membersCount > actCfg.personMax then
    if 1 >= actCfg.personMax then
      Toast(textRes.activity[937])
    elseif actCfg.personMin <= 1 then
      Toast(string.format(textRes.activity[938], actCfg.personMin, actCfg.personMax))
    else
      Toast(string.format(textRes.activity[908], actCfg.levelMin, actCfg.levelMax))
    end
    return
  end
  if TeamData.Instance():HasTeam() then
    if not actCfg.couldBeSingleTeam then
    else
    end
    if not TeamData.Instance():MeIsAFK() then
      if not TeamData.Instance():MeIsCaptain() then
        Toast(textRes.activity[921])
        return false
      end
      if TeamData.Instance():HasLeavingMember() then
        Toast(textRes.activity[920])
        return false
      end
    end
  end
  local names = {}
  local names2 = {}
  for k, v in ipairs(members) do
    if v.level < actCfg.levelMin or v.level > actCfg.levelMax then
      table.insert(names, v.name)
    end
    if v.level < fCfg.joinLevel then
      table.insert(names2, v.name)
    end
  end
  if #names > 0 then
    Toast(string.format(textRes.activity[910], actCfg.levelMin, actCfg.levelMax, table.concat(names, textRes.Common.Dunhao)))
    return false
  end
  if #names2 > 0 then
    Toast(string.format(textRes.activity[912], fCfg.joinLevel, table.concat(names2, textRes.Common.Dunhao)))
    return false
  end
  return true
end
def.method("number", "=>", "table").GetNoSweepFloor = function(self, activityId)
  local floors = {}
  local floorCfg = self:GetTowerFloorCfg(activityId)
  for k, v in ipairs(floorCfg.floors) do
    local open = IsFeatureOpen(v.floorOpenId)
    if open and not v.canSweep then
      table.insert(floors, k)
    end
  end
  return floors
end
def.method("number", "=>", "number", "number", "number").GetSweepData = function(self, activityId)
  local data = self.data and self.data[activityId] or nil
  local historyData = self.historyData and self.historyData[activityId] or nil
  local floorCfg = self:GetTowerFloorCfg(activityId)
  local highFloor = 0
  local startFloor = 0
  local endFloor = 0
  for k, v in ipairs(floorCfg.floors) do
    local open = IsFeatureOpen(v.floorOpenId)
    if open then
      if startFloor == 0 and (data == nil or data[k] == nil or data[k].usedTime == nil or 0 > data[k].usedTime) and v.canSweep then
        startFloor = k
      end
      if historyData and historyData[k] then
        highFloor = k
        if v.canSweep then
          endFloor = k
        end
      end
    end
  end
  return highFloor, startFloor, endFloor
end
def.method("number", "number", "number", "=>", "number").GetSweepCost = function(self, activityId, from, to)
  local data = self.data and self.data[activityId] or nil
  local historyData = self.historyData and self.historyData[activityId] or nil
  local floorCfg = self:GetTowerFloorCfg(activityId)
  local cost = 0
  for i = from, to do
    local cfg = floorCfg.floors[i]
    if cfg then
      local open = IsFeatureOpen(cfg.floorOpenId)
      if open and (data == nil or data[i] == nil or data[i].usedTime == nil or 0 > data[i].usedTime) and cfg.canSweep then
        cost = cost + cfg.sweepCostNum
      end
    end
  end
  return cost
end
def.method("number", "number", "number", "boolean", "number", "=>", "boolean").SweepFloor = function(self, activityId, from, to, useYuanBao, yuanbaoNum)
  local high, s, e = self:GetSweepData(activityId)
  if to < from then
    Toast(textRes.activity[932])
    return false
  end
  if to > high then
    Toast(textRes.activity[927])
    return false
  end
  local data = self.data and self.data[activityId] or nil
  local historyData = self.historyData and self.historyData[activityId] or nil
  local floorCfg = self:GetTowerFloorCfg(activityId)
  local haveSweepFloor = false
  for i = from, to do
    local cfg = floorCfg.floors[i]
    if cfg then
      local open = IsFeatureOpen(cfg.floorOpenId)
      if open and (data == nil or data[i] == nil or data[i].usedTime == nil or data[i].usedTime < 0) then
        haveSweepFloor = true
        break
      end
    end
  end
  if not haveSweepFloor then
    Toast(textRes.activity[939])
    return false
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local fightValue = heroProp and heroProp.fightValue or 0
  for i = from, to do
    local cfg = floorCfg.floors[i]
    if cfg then
      local open = IsFeatureOpen(cfg.floorOpenId)
      if open then
        if cfg.canSweep then
          if historyData == nil or historyData[i] == nil then
            Toast(string.format(textRes.activity[930], i))
            return false
          end
          if fightValue < cfg.sweepFightValue then
            Toast(string.format(textRes.activity[928], i, cfg.sweepFightValue))
            return false
          end
        else
          Toast(string.format(textRes.activity[929], i))
          return false
        end
      end
    end
  end
  local curYuanBao = require("Main.Item.ItemModule").Instance():GetAllYuanBao()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.floor.CSweepFloorReq").new(activityId, from, to, useYuanBao and 1 or 0, curYuanBao, Int64.new(yuanbaoNum)))
  return true
end
def.static("table").OnSSynRoleActivtyInfo = function(p)
  local self = TowerMgr.Instance()
  if self.data == nil then
    self.data = {}
  end
  if self.historyData == nil then
    self.historyData = {}
  end
  for k, v in pairs(p.activityInfos) do
    local activityId = k
    local towerInfo = {}
    for k1, v1 in pairs(v.finishFloor) do
      towerInfo[v1.floor] = {
        usedTime = v1.usedTime
      }
    end
    self.data[activityId] = towerInfo
    local historyInfo = {}
    for k1, v1 in pairs(v.historyFinishFloors) do
      historyInfo[v1] = v1
    end
    self.historyData[activityId] = historyInfo
  end
end
def.static("table").OnSChallengeSuc = function(p)
  local self = TowerMgr.Instance()
  local activity = p.activityId
  if self.data == nil then
    self.data = {}
  end
  if self.data[activity] == nil then
    self.data[activity] = {}
  end
  if self.data[activity][p.floor] == nil then
    self.data[activity][p.floor] = {}
  end
  self.data[activity][p.floor].usedTime = p.usedTime
  if self.historyData == nil then
    self.historyData = {}
  end
  if self.historyData[activity] == nil then
    self.historyData[activity] = {}
  end
  self.historyData[activity][p.floor] = p.floor
  require("Main.activity.Tower.ui.TowerPanel").UpdateContent()
  local floors = self:GetActivityFloors(activity)
  local nextFloor
  for k, v in ipairs(floors) do
    if v > p.floor then
      nextFloor = v
      break
    end
  end
  if nextFloor and (self.data[activity][nextFloor] == nil or self.data[activity][nextFloor].usedTime == nil or self.data[activity][nextFloor].usedTime < 0) then
    require("Main.activity.Tower.ui.TowerPanel").UpdateFloor(nextFloor)
  end
end
def.static("table").OnSGetFirstBloodBro = function(p)
  local self = TowerMgr.Instance()
  local activity = p.activityId
  if self.data == nil then
    self.data = {}
  end
  if self.data[activity] == nil then
    self.data[activity] = {}
  end
  if self.data[activity][p.floor] == nil then
    self.data[activity][p.floor] = {}
  end
  local firstBloodInfo = {}
  firstBloodInfo.names = {}
  firstBloodInfo.killTime = p.fightInfo.killTime
  firstBloodInfo.usedTime = p.fightInfo.usedTime
  for k, v in pairs(p.fightInfo.names) do
    table.insert(firstBloodInfo.names, GetStringFromOcts(v))
  end
  self.data[activity][p.floor].firstBlood = firstBloodInfo
  local AnnouncementTip = require("GUI.AnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local str = string.format(textRes.activity[922], table.concat(firstBloodInfo.names, textRes.Common.comma), p.floor)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  AnnouncementTip.Announce(str)
end
def.static("table").OnSFastKillBro = function(p)
  local self = TowerMgr.Instance()
  local activity = p.activityId
  if self.data == nil then
    self.data = {}
  end
  if self.data[activity] == nil then
    self.data[activity] = {}
  end
  if self.data[activity][p.floor] == nil then
    self.data[activity][p.floor] = {}
  end
  local fastKillInfo = {}
  fastKillInfo.names = {}
  fastKillInfo.killTime = p.fightInfo.killTime
  fastKillInfo.usedTime = p.fightInfo.usedTime
  for k, v in pairs(p.fightInfo.names) do
    table.insert(fastKillInfo.names, GetStringFromOcts(v))
  end
  self.data[activity][p.floor].fastKill = fastKillInfo
  local AnnouncementTip = require("GUI.AnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local min = math.floor(fastKillInfo.usedTime / 60)
  local sec = fastKillInfo.usedTime % 60
  local str = string.format(textRes.activity[923], table.concat(fastKillInfo.names, textRes.Common.comma), min, sec, p.floor)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  AnnouncementTip.Announce(str)
end
def.static("table").OnSCheckFirstBloodRep = function(p)
  if p.fightInfo.killTime <= 0 then
    return
  end
  local self = TowerMgr.Instance()
  local activity = p.activityId
  if self.data == nil then
    self.data = {}
  end
  if self.data[activity] == nil then
    self.data[activity] = {}
  end
  if self.data[activity][p.floor] == nil then
    self.data[activity][p.floor] = {}
  end
  local firstBloodInfo = {}
  firstBloodInfo.names = {}
  firstBloodInfo.killTime = p.fightInfo.killTime
  firstBloodInfo.usedTime = p.fightInfo.usedTime
  for k, v in pairs(p.fightInfo.names) do
    table.insert(firstBloodInfo.names, GetStringFromOcts(v))
  end
  self.data[activity][p.floor].firstBlood = firstBloodInfo
  local uniqueKey = tostring(p.activityId) .. tostring(p.floor)
  if self.firstRequest and self.firstRequest[uniqueKey] then
    local cbs = self.firstRequest[uniqueKey]
    self.firstRequest[uniqueKey] = nil
    for k, v in ipairs(cbs) do
      v(firstBloodInfo)
    end
  end
end
def.static("table").OnSCheckFastFightRep = function(p)
  if p.fightInfo.killTime <= 0 then
    return
  end
  local self = TowerMgr.Instance()
  local activity = p.activityId
  if self.data == nil then
    self.data = {}
  end
  if self.data[activity] == nil then
    self.data[activity] = {}
  end
  if self.data[activity][p.floor] == nil then
    self.data[activity][p.floor] = {}
  end
  local fastInfo = {}
  fastInfo.names = {}
  fastInfo.killTime = p.fightInfo.killTime
  fastInfo.usedTime = p.fightInfo.usedTime
  for k, v in pairs(p.fightInfo.names) do
    table.insert(fastInfo.names, GetStringFromOcts(v))
  end
  self.data[activity][p.floor].fastKill = fastInfo
  local uniqueKey = tostring(p.activityId) .. tostring(p.floor)
  if self.fastRequest and self.fastRequest[uniqueKey] then
    local cbs = self.fastRequest[uniqueKey]
    self.fastRequest[uniqueKey] = nil
    for k, v in ipairs(cbs) do
      v(fastInfo)
    end
  end
end
def.static("table").OnSFloorNormalResult = function(p)
  local tip = textRes.activity.TowerError[p.result]
  if tip then
    Toast(string.format(tip, unpack(p.args)))
  end
end
def.static("table").OnSFloorHelpTip = function(p)
  if p.leftHelpCount > 0 then
    Toast(string.format(textRes.activity[924], p.from, p.to, p.leftHelpCount))
  else
    Toast(string.format(textRes.activity[925], p.from, p.to))
  end
end
def.static("table").OnSSweepFloorSuc = function(p)
  local self = TowerMgr.Instance()
  local activity = p.activityId
  if self.data == nil then
    self.data = {}
  end
  if self.data[activity] == nil then
    self.data[activity] = {}
  end
  local sweeps = {}
  for k, v in pairs(p.floors) do
    if self.data[activity][v] == nil then
      self.data[activity][v] = {}
    end
    self.data[activity][v].usedTime = 0
    table.insert(sweeps, v)
  end
  table.sort(sweeps)
  Toast(string.format(textRes.activity[931], table.concat(sweeps, ",")))
  require("Main.activity.Tower.ui.TowerPanel").UpdateContent()
  local AwardUtils = require("Main.Award.AwardUtils")
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local htmlTexts = AwardUtils.GetHtmlTextsFromAwardBean(p.awardBean, textRes.activity[940])
  for i, v in ipairs(htmlTexts) do
    PersonalHelper.SendOut(v)
  end
  local cfg = TowerMgr.Instance():GetTowerActivityCfg(activity)
  local effectPath = GetEffectRes(cfg.sweepSucEffectId)
  if effectPath and effectPath.path then
    require("Fx.GUIFxMan").Instance():Play(effectPath.path, "sweepfloor", 0, 0, -1, false)
  end
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local self = TowerMgr.Instance()
  local activityId = p1 and p1[1]
  if activityId and self.relatedActivity[activityId] then
    require("Main.activity.Tower.ui.TowerPanel").ShowTowerPanel(activityId)
  end
end
def.static("number", "=>", "boolean").IsRelatedActivity = function(activityId)
  return instance.relatedActivity ~= nil and instance.relatedActivity[activityId] ~= nil
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  local activityId = p1[1]
  local self = TowerMgr.Instance()
  if self.relatedActivity[activityId] and self.data and self.data[activityId] then
    self.data[activityId] = nil
    require("Main.activity.Tower.ui.TowerPanel").UpdateContent()
  end
end
def.static("table", "table").OnSweepItemUse = function(p1, p2)
  local itemId = p1[1]
  if itemId then
    local self = TowerMgr.Instance()
    if self.relatedActivity then
      for k, v in pairs(self.relatedActivity) do
        local cfg = self:GetTowerActivityCfg(k)
        if cfg.sweepCostItemId == itemId then
          local open1 = IsFeatureOpen(cfg.activityOpenId)
          local open2 = IsFeatureOpen(cfg.sweepSwithId)
          if open1 and open2 then
            require("Main.activity.Tower.ui.TowerPanel").ShowTowerPanel(k)
          else
            Toast(textRes.activity[941])
          end
        end
      end
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local self = TowerMgr.Instance()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  for k, v in pairs(self.relatedSwitch) do
    local open = IsFeatureOpen(k)
    if open then
      ActivityInterface.Instance():removeCustomCloseActivity(v)
    else
      ActivityInterface.Instance():addCustomCloseActivity(v)
    end
  end
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  local self = TowerMgr.Instance()
  local feature = p1.feature
  if self.relatedSwitch[feature] then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    if p1.open then
      ActivityInterface.Instance():removeCustomCloseActivity(self.relatedSwitch[feature])
    else
      ActivityInterface.Instance():addCustomCloseActivity(self.relatedSwitch[feature])
    end
  end
end
return TowerMgr.Commit()
