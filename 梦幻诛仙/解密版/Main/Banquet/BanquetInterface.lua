local Lplus = require("Lplus")
local BanquetInterface = Lplus.Class("BanquestInterface")
local def = BanquetInterface.define
local instance
def.field("number").startTime = 0
def.field("number").playerNum = 0
def.field("userdata").masterId = nil
def.field("number").banquetRank = 1
def.field("boolean").isBanqueting = false
def.static("=>", BanquetInterface).Instance = function()
  if instance == nil then
    instance = BanquetInterface()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().Reset = function(self)
  self.playerNum = 0
  self.startTime = 0
  self.masterId = nil
  self.banquetRank = 1
  self.isBanqueting = false
end
def.static("number", "=>", "number").GetBanquetRankByScore = function(score)
  local rank = 1
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BANQUET_RANK_CALC_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local scoreLow = record:GetIntValue("scoreLow")
    local scoreHigh = record:GetIntValue("scoreHigh")
    if score >= scoreLow and score <= scoreHigh then
      rank = record:GetIntValue("rank")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return rank
end
def.method("=>", "number").getPlayerNum = function(self)
  return self.playerNum
end
def.method().calcBanquetRank = function(self)
  local homeInfo = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetCurHomelandInfo()
  local oldRank = self.banquetRank
  if homeInfo then
    local fengshui = homeInfo.geomancy
    local value = fengshui + self.playerNum
    self.banquetRank = BanquetInterface.GetBanquetRankByScore(value)
  end
  if oldRank ~= self.banquetRank then
    Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_LEVEL_CHANGE, {
      oldRank,
      self.banquetRank
    })
  end
end
def.method("=>", "number").getBanquetRank = function(self)
  return self.banquetRank
end
def.method("=>", "number").getCurBanquetStartTime = function(self)
  return self.startTime
end
def.method("=>", "number").getCurBanquetEndTime = function(self)
  return self.startTime + constant.CBanquetConsts.DISHES_COUNT_MAX * constant.CBanquetConsts.DISHES_INTERVAL_TIME
end
def.method("=>", "number").getNextAwardTime = function(self)
  local curTime = GetServerTime()
  local endTime = self:getCurBanquetEndTime()
  if curTime > endTime then
    return -1
  end
  local intervalTime = constant.CBanquetConsts.DISHES_INTERVAL_TIME
  local openTimes = math.floor((curTime - self.startTime) / intervalTime)
  return self.startTime + (openTimes + 1) * intervalTime
end
return BanquetInterface.Commit()
