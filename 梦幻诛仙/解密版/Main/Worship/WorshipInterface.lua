local Lplus = require("Lplus")
local WorshipInterface = Lplus.Class("WorshipInterface")
local def = WorshipInterface.define
local instance
def.field("table").worshipId2num = nil
def.field("number").myWorshipId = 0
def.field("number").lastCycleNum = 0
def.field("number").curCycleNum = 0
def.field("number").canGetSalary = 0
def.field("number").nextCanGetSalary = 0
def.field("table").worshipRecord = nil
def.static("=>", WorshipInterface).Instance = function()
  if instance == nil then
    instance = WorshipInterface()
  end
  return instance
end
def.method().Reset = function(self)
  self.worshipId2num = {}
  self.worshipRecord = {}
  self.canGetSalary = 0
  self.myWorshipId = 0
end
def.static("number", "=>", "table").GetWorshipCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WORSHIP_CFG, id)
  if record == nil then
    warn("********************** GetWorshipCfg return nil ID =", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.actionName = record:GetStringValue("actionName")
  cfg.index = record:GetIntValue("index")
  cfg.contentList = {}
  local rec2 = record:GetStructValue("contentStruct")
  local count = rec2:GetVectorSize("contentList")
  for i = 1, count do
    local rec3 = DynamicRecord.GetVectorValueByIdx(rec2, "contentList", i - 1)
    local content = rec3:GetStringValue("content")
    if content then
      table.insert(cfg.contentList, content)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetWorshipCfgByIndex = function(index)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WORSHIP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local id = 0
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local idx = entry:GetIntValue("index")
    if idx == index then
      id = entry:GetIntValue("id")
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if id > 0 then
    return WorshipInterface.GetWorshipCfg(id)
  end
  return nil
end
def.method("number", "number").addWorshipNum = function(self, worshipId, num)
  if self.worshipId2num == nil then
    self.worshipId2num = {}
  end
  local curNum = self.worshipId2num[worshipId] or 0
  self.worshipId2num[worshipId] = curNum + num
end
def.method("number", "=>", "number").getWorshipNumById = function(self, id)
  if self.worshipId2num then
    return self.worshipId2num[id] or 0
  end
  return 0
end
def.method("table").addWorshipRecord = function(self, info)
  if self.worshipRecord == nil then
    self.worshipRecord = {}
  end
  if #self.worshipRecord >= constant.CWorShipConst.recordMax then
    table.remove(self.worshipRecord, 1)
  end
  table.insert(self.worshipRecord, info)
end
def.method("=>", "string").getWorshipRecordStr = function(self)
  local str = ""
  if self.worshipRecord then
    local GangData = require("Main.Gang.data.GangData").Instance()
    local num = #self.worshipRecord
    for i = num, 1, -1 do
      local info = self.worshipRecord[i]
      local cfg = WorshipInterface.GetWorshipCfg(info.worshipId)
      local memberInfo = GangData:GetMemberInfoByRoleId(info.roleId)
      local GangInfo = GangData:GetGangBasicInfo()
      if cfg and cfg.contentList[info.contentIndex] and memberInfo then
        local roleName = "[00ff00]" .. memberInfo.name .. "[-]"
        local bangZhuName = "[ffff00]" .. GangInfo.bangZhu .. "[-]"
        str = str .. string.format(cfg.contentList[info.contentIndex], roleName, bangZhuName) .. "\n"
      end
    end
  end
  return str
end
def.method("=>", "boolean").canWorship = function(self)
  local GangModule = require("Main.Gang.GangModule")
  local bHasGang = GangModule.Instance():HasGang()
  if bHasGang then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local activityInterface = ActivityInterface.Instance()
    if activityInterface:isAchieveActivityLevel(constant.CWorShipConst.activityId) and IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_WORSHIP_FACTION_MASTER) then
      return self.myWorshipId == 0
    end
  end
  return false
end
def.method().setWorshipRedPoint = function(self)
  local gangUtility = require("Main.Gang.GangUtility").Instance()
  local isShow = self:canWorship()
  if isShow then
    gangUtility:AddGangActivityRedPoint(constant.CWorShipConst.activityId)
  else
    gangUtility:RemoveGangActivityRedPoint(constant.CWorShipConst.activityId)
  end
end
return WorshipInterface.Commit()
