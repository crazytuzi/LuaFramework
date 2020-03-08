local Lplus = require("Lplus")
local AircraftUtils = require("Main.Aircraft.AircraftUtils")
local AircraftInfo = require("Main.Aircraft.data.AircraftInfo")
local AircraftData = Lplus.Class("AircraftData")
local def = AircraftData.define
local _instance
def.static("=>", AircraftData).Instance = function()
  if _instance == nil then
    _instance = AircraftData()
  end
  return _instance
end
def.field("number")._curAircraftId = 0
def.field("table")._aircraftInfoMap = nil
def.field("table")._aircraftCfg = nil
def.field("table")._itemCfg = nil
def.field("table")._dyeCfg = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._curAircraftId = 0
  self._aircraftInfoMap = nil
  self._itemCfg = nil
  self._aircraftCfg = nil
  self._dyeCfg = nil
end
def.method()._LoadAircraftCfg = function(self)
  warn("[AircraftData:_LoadAircraftCfg] start Load AircraftCfg!")
  self._aircraftCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AIRCRAFT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local aircraftCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    aircraftCfg.id = DynamicRecord.GetIntValue(entry, "id")
    aircraftCfg.name = DynamicRecord.GetStringValue(entry, "name")
    aircraftCfg.feijianType = DynamicRecord.GetIntValue(entry, "feiJianType")
    aircraftCfg.modelId = DynamicRecord.GetIntValue(entry, "modelId")
    aircraftCfg.modelPath = GetModelPath(aircraftCfg.modelId)
    aircraftCfg.velocity = DynamicRecord.GetIntValue(entry, "velocity")
    aircraftCfg.effectId = DynamicRecord.GetIntValue(entry, "effectId")
    local effectCfg = GetEffectRes(aircraftCfg.effectId)
    aircraftCfg.effectPath = effectCfg and effectCfg.path or nil
    aircraftCfg.index = DynamicRecord.GetIntValue(entry, "index")
    aircraftCfg.sourceTipId = DynamicRecord.GetIntValue(entry, "feiJianApproachOfAchieving")
    aircraftCfg.uiShowDelay = DynamicRecord.GetIntValue(entry, "delayShowTime")
    aircraftCfg.slantValue = DynamicRecord.GetIntValue(entry, "slantValue")
    aircraftCfg.props = {}
    local proStruct = entry:GetStructValue("proStruct")
    local count = proStruct:GetVectorSize("proList")
    for i = 1, count do
      local record = proStruct:GetVectorValueByIdx("proList", i - 1)
      local prop = {}
      prop.propType = record:GetIntValue("protype")
      prop.propValue = record:GetIntValue("provalue")
      table.insert(aircraftCfg.props, prop)
    end
    self._aircraftCfg[aircraftCfg.id] = aircraftCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  self:_LoadItemCfg()
end
def.method("=>", "table")._GetAircraftCfgs = function(self)
  if nil == self._aircraftCfg then
    self:_LoadAircraftCfg()
  end
  return self._aircraftCfg
end
def.method("number", "=>", "table").GetAircraftCfg = function(self, id)
  return self:_GetAircraftCfgs()[id]
end
def.method()._LoadItemCfg = function(self)
  warn("[AircraftData:_LoadItemCfg] start Load AircraftItemCfg!")
  self._itemCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FEIJIAN_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local itemCfg = {}
    itemCfg.itemId = DynamicRecord.GetIntValue(entry, "id")
    itemCfg.aircraftId = DynamicRecord.GetIntValue(entry, "aircraftid")
    local aircraftCfg = self:GetAircraftCfg(itemCfg.aircraftId)
    if aircraftCfg then
      aircraftCfg.itemId = itemCfg.itemId
    end
    self._itemCfg[itemCfg.itemId] = itemCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetItemCfgs = function(self)
  if nil == self._itemCfg then
    self:_LoadAircraftCfg()
  end
  return self._itemCfg
end
def.method("number", "=>", "table").GetAircraftItemCfg = function(self, id)
  return self:_GetItemCfgs()[id]
end
def.method("=>", "table").GetSortedAircraftCfgs = function(self)
  local result = {}
  local aircraftCfgMap = self:_GetAircraftCfgs()
  local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
  local IDIPInterface = require("Main.IDIP.IDIPInterface")
  for id, cfg in pairs(aircraftCfgMap) do
    if IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.AIRCRAFT, id) then
      table.insert(result, cfg)
    else
      warn("[AircraftData:GetSortedAircraftCfgs] Aircraft idip not open:", id)
    end
  end
  if result and #result > 0 then
    table.sort(result, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      else
        local bHaveA = self:HaveAircraft(a.id)
        local bHaveB = self:HaveAircraft(b.id)
        if bHaveA ~= bHaveB then
          return bHaveA
        elseif a.index ~= b.index then
          return a.index < b.index
        else
          return a.id < b.id
        end
      end
    end)
  end
  return result
end
def.method()._LoadDyeCfg = function(self)
  warn("[AircraftData:_LoadDyeCfg] start Load DyeCfg!")
  self._dyeCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AIRCRAFT_DYE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local dyeCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    dyeCfg.id = DynamicRecord.GetIntValue(entry, "id")
    dyeCfg.aircraftId = DynamicRecord.GetIntValue(entry, "fei_jian_cfg_id")
    dyeCfg.colorId = DynamicRecord.GetIntValue(entry, "color_cfg_Id")
    dyeCfg.index = DynamicRecord.GetIntValue(entry, "index")
    dyeCfg.itemId = DynamicRecord.GetIntValue(entry, "item_id")
    dyeCfg.costItemType = DynamicRecord.GetIntValue(entry, "cost_item_type")
    dyeCfg.itemCount = DynamicRecord.GetIntValue(entry, "item_count")
    self._dyeCfg[dyeCfg.id] = dyeCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetDyeCfgs = function(self)
  if nil == self._dyeCfg then
    self:_LoadDyeCfg()
  end
  return self._dyeCfg
end
def.method("number", "number", "=>", "table").GetDyeCfg = function(self, aircraftId, colorId)
  local result
  for id, cfg in pairs(dyeCfgMap) do
    if colorId == cfg.colorId and (aircraftId == cfg.aircraftId or cfg.aircraftId == 0) then
      result = cfg
      break
    end
  end
  return result
end
def.method("number", "=>", "table").GetSortedDyeCfgs = function(self, aircraftId)
  local result = {}
  local dyeCfgMap = self:_GetDyeCfgs()
  for id, cfg in pairs(dyeCfgMap) do
    if aircraftId == cfg.aircraftId or cfg.aircraftId == 0 then
      table.insert(result, cfg)
    end
  end
  if result and #result > 0 then
    table.sort(result, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      elseif a.index ~= b.index then
        return a.index < b.index
      elseif a.aircraftId ~= b.aircraftId then
        return a.aircraftId < b.aircraftId
      else
        return a.id < b.id
      end
    end)
  end
  return result
end
def.method("number", "number", "boolean").AddAircraft = function(self, aircraftId, colorId, bEvent)
  if nil == self._aircraftInfoMap then
    self._aircraftInfoMap = {}
  end
  local aircraftInfo = AircraftInfo.New(aircraftId, colorId)
  self._aircraftInfoMap[aircraftId] = aircraftInfo
  if bEvent then
    Event.DispatchEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_INFO_CHANGE, nil)
  end
end
def.method("number", "=>", "table").GetAircraftInfo = function(self, aircraftId)
  local result
  if aircraftId > 0 then
    result = self._aircraftInfoMap and self._aircraftInfoMap[aircraftId]
  end
  return result
end
def.method("number", "=>", "number").GetAircraftColor = function(self, aircraftId)
  local aircraftInfo = self:GetAircraftInfo(aircraftId)
  local colorId = aircraftInfo and aircraftInfo.colorId or 0
  return colorId
end
def.method("number", "boolean").SetCurrentAircraft = function(self, aircraftId, bEvent)
  self._curAircraftId = aircraftId
  Event.DispatchEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_MOUNT_CHANGE, {aircraftId = aircraftId})
  if bEvent then
    Event.DispatchEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_INFO_CHANGE, nil)
  end
end
def.method("=>", "number").GetCurrentAircraftId = function(self)
  return self._curAircraftId
end
def.method("=>", "table").GetCurrentAircraftInfo = function(self)
  return self:GetAircraftInfo(self._curAircraftId)
end
def.method("number", "=>", "boolean").IsCurrentAircraft = function(self, aircraftId)
  return aircraftId == self._curAircraftId
end
def.method("number", "=>", "boolean").HaveAircraft = function(self, aircraftId)
  return self:GetAircraftInfo(aircraftId) ~= nil
end
def.method("number", "number").DyeAircraft = function(self, aircraftId, colorId)
  warn("[AircraftData:DyeAircraft] DyeAircraft:", aircraftId, colorId)
  if nil == self._aircraftInfoMap then
    self._aircraftInfoMap = {}
  end
  local aircraftInfo = self:GetAircraftInfo(aircraftId)
  if aircraftInfo then
    aircraftInfo:Dye(colorId)
  else
    aircraftInfo = AircraftInfo.New(aircraftId, colorId)
    self._aircraftInfoMap[aircraftId] = aircraftInfo
  end
  Event.DispatchEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_DYE_CHANGE, {aircraftId = aircraftId})
  Event.DispatchEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_INFO_CHANGE, nil)
end
def.method("=>", "table").GetOwnAircraftProps = function(self)
  local props = {}
  if self._aircraftInfoMap then
    for id, info in pairs(self._aircraftInfoMap) do
      local aircraftCfg = self:GetAircraftCfg(id)
      if aircraftCfg then
        if aircraftCfg.props and #aircraftCfg.props > 0 then
          for _, prop in pairs(aircraftCfg.props) do
            if props[prop.propType] then
              props[prop.propType] = props[prop.propType] + prop.propValue
            else
              props[prop.propType] = prop.propValue
            end
          end
        end
      else
        warn("[ERROR][AircraftData:GetOwnAircraftProps] aircraftCfg nil for id:", id)
      end
    end
  end
  return props
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
AircraftData.Commit()
return AircraftData
