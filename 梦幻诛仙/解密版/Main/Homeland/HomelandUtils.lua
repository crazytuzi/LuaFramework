local MODULE_NAME = (...)
local Lplus = require("Lplus")
local LuaUserDataIO = require("Main.Common.LuaUserDataIO")
local HomelandUtils = Lplus.Class(MODULE_NAME)
local def = HomelandUtils.define
def.const("string").STORE_FILE_ISSHOWNITEM = "FurnitureShown/ShownFurnitureItemData_%s.lua"
local instance
def.static("=>", HomelandUtils).Instance = function()
  if instance == nil then
    instance = HomelandUtils()
  end
  return instance
end
def.static("number", "=>", "string").GetResPath = function(resId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_RES_CFG, resId)
  if record == nil then
    warn(string.format("HomelandUtils.GetResPath(%d) return \"\"", resId))
    return ""
  end
  return record:GetStringValue("path")
end
def.static("=>", "table").GetAllHouseCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_HOMELAND_HOUSE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local cfg = HomelandUtils._GetHouseCfg(record)
    cfgs[#cfgs + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("=>", "number").GetHouseCfgNums = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_HOMELAND_HOUSE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  return count
end
def.static("number", "=>", "table").GetHouseCfg = function(houseLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_HOUSE_CFG, houseLevel)
  if record == nil then
    warn("GetHouseCfg(" .. houseLevel .. ") return nil")
    return nil
  end
  return HomelandUtils._GetHouseCfg(record)
end
def.static("userdata", "=>", "table")._GetHouseCfg = function(record)
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.costMoneyType = record:GetIntValue("moneyType")
  cfg.costMoneyNum = record:GetIntValue("moneyNum")
  cfg.costItemId = record:GetIntValue("itemId")
  cfg.costItemNum = record:GetIntValue("itemNum")
  cfg.mapId = record:GetIntValue("mapId")
  cfg.picId = record:GetIntValue("picId")
  cfg.resourceId = record:GetIntValue("resourceId")
  cfg.maxPetRoomLevel = record:GetIntValue("maxPetRoomLevel")
  cfg.maxBedRoomLevel = record:GetIntValue("maxBedRoomLevel")
  cfg.maxDrugRoomLevel = record:GetIntValue("maxDrugRoomLevel")
  cfg.maxKitchenLevel = record:GetIntValue("maxKitchenLevel")
  cfg.maxMaidRoomLevel = record:GetIntValue("maxMaidRoomLevel")
  cfg.dayCutCleanliness = record:GetIntValue("dayCutCleanliness")
  cfg.maxCleanliness = record:GetIntValue("maxCleanliness")
  cfg.maxFengShui = record:GetIntValue("maxFengShui")
  cfg.showName = record:GetStringValue("showName")
  cfg.offSetX = record:GetIntValue("offSetX")
  cfg.offSetY = record:GetIntValue("offSetY")
  cfg.maidX = record:GetIntValue("maidX")
  cfg.maidY = record:GetIntValue("maidY")
  cfg.maidDir = record:GetIntValue("maidDir")
  return cfg
end
def.static("=>", "table").GetAllFurnitureBagCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_HOMELAND_FURNITURE_BAG_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.showName = record:GetStringValue("showName")
    cfg.sort = record:GetIntValue("sort")
    cfg.iconId = record:GetIntValue("iconId")
    cfg.subTypes = {}
    local subtypesStruct = record:GetStructValue("subtypesStruct")
    local size = subtypesStruct:GetVectorSize("subtypes")
    for i = 0, size - 1 do
      local vectorRow = subtypesStruct:GetVectorValueByIdx("subtypes", i)
      cfg.subTypes[#cfg.subTypes + 1] = vectorRow:GetIntValue("subtype")
    end
    cfgs[#cfgs + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.sort < r.sort
  end)
  return cfgs
end
def.static("=>", "table").GetAllFurnitureStyleCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_HOMELAND_FURNITURE_STYLE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.showName = record:GetStringValue("showName")
    cfg.sort = record:GetIntValue("sort")
    cfgs[#cfgs + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.sort < r.sort
  end)
  return cfgs
end
def.static("number", "=>", "table").GetPetRoomCfg = function(roomLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_PET_ROOM_CFG, roomLevel)
  if record == nil then
    warn("GetPetRoomCfg(" .. roomLevel .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.costMoneyType = record:GetIntValue("moneyType")
  cfg.costMoneyNum = record:GetIntValue("moneyNum")
  cfg.dayCutCleanliness = record:GetIntValue("dayCutCleanliness")
  cfg.dayTrainCount = record:GetIntValue("dayTrainCount")
  cfg.addExpNum = record:GetIntValue("addExpNum")
  return cfg
end
def.static("number", "=>", "table").GetBedroomCfg = function(roomLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_BEDROOM_CFG, roomLevel)
  if record == nil then
    warn("GetBedroomCfg(" .. roomLevel .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.costMoneyType = record:GetIntValue("moneyType")
  cfg.costMoneyNum = record:GetIntValue("moneyNum")
  cfg.dayCutCleanliness = record:GetIntValue("dayCutCleanliness")
  cfg.dayRestoreVigorCount = record:GetIntValue("dayRestoreVigorCount")
  cfg.addVigorNum = record:GetIntValue("addVigorNum")
  cfg.dayRestoreSatiationCount = record:GetIntValue("dayRestoreSatiationCount")
  cfg.addSatiationNum = record:GetIntValue("addSatiationNum")
  return cfg
end
def.static("number", "=>", "table").GetMakeDrugRoomCfg = function(roomLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_DRUG_ROOM_CFG, roomLevel)
  if record == nil then
    warn("GetMakeDrugRoomCfg(" .. roomLevel .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.costMoneyType = record:GetIntValue("moneyType")
  cfg.costMoneyNum = record:GetIntValue("moneyNum")
  cfg.dayCutCleanliness = record:GetIntValue("dayCutCleanliness")
  cfg.cutVigor = record:GetIntValue("cutVigor")
  cfg.doubleRate = record:GetIntValue("doubleRate")
  return cfg
end
def.static("number", "=>", "table").GetKitchenCfg = function(roomLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_KITCHEN_CFG, roomLevel)
  if record == nil then
    warn("GetKitchenCfg(" .. roomLevel .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.costMoneyType = record:GetIntValue("moneyType")
  cfg.costMoneyNum = record:GetIntValue("moneyNum")
  cfg.dayCutCleanliness = record:GetIntValue("dayCutCleanliness")
  cfg.cutVigor = record:GetIntValue("cutVigor")
  cfg.doubleRate = record:GetIntValue("doubleRate")
  return cfg
end
def.static("number", "=>", "table").GetServantRoomCfg = function(roomLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_SERVANT_ROOM_CFG, roomLevel)
  if record == nil then
    warn("GetServantRoomCfg(" .. roomLevel .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.costMoneyType = record:GetIntValue("moneyType")
  cfg.costMoneyNum = record:GetIntValue("moneyNum")
  cfg.dayCutCleanliness = record:GetIntValue("dayCutCleanliness")
  cfg.dayCleanCount = record:GetIntValue("dayCleanCount")
  cfg.maidIds = {}
  local maidIdsStruct = record:GetStructValue("maidIdsStruct")
  local size = maidIdsStruct:GetVectorSize("maidIds")
  for i = 0, size - 1 do
    local vectorRow = maidIdsStruct:GetVectorValueByIdx("maidIds", i)
    cfg.maidIds[#cfg.maidIds + 1] = vectorRow:GetIntValue("maidId")
  end
  return cfg
end
def.static("number", "=>", "table").GetServantCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_SERVANT_CFG, id)
  if record == nil then
    warn("GetServantCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.costMoneyType = record:GetIntValue("moneyType")
  cfg.costMoneyNum = record:GetIntValue("moneyNum")
  cfg.effectId = record:GetIntValue("maidNpc")
  cfg.addCleanliness = record:GetIntValue("addCleanliness")
  cfg.npcId = record:GetIntValue("maidNpc")
  cfg.cleanMoneyType = record:GetIntValue("cleanMoneyType")
  cfg.cleanMoneyNum = record:GetIntValue("cleanMoneyNum")
  return cfg
end
local _fengshui_level_cache
def.static("number", "=>", "table").GetHouseFengShuiCfg = function(value)
  if _fengshui_level_cache == nil then
    _fengshui_level_cache = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_HOMELAND_GEOMANCY_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    local cfgs = _fengshui_level_cache
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 1, count do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
      local cfg = {}
      cfg.minValue = record:GetIntValue("minFengShuiValue")
      cfg.id = record:GetIntValue("id")
      cfgs[#cfgs + 1] = cfg
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    table.sort(cfgs, function(l, r)
      return l.minValue > r.minValue
    end)
  end
  if value < 0 then
    warn(string.format("Attempt to GetHouseFengShuiCfg with a invalid value: %d", value))
    value = 0
  end
  for i, v in ipairs(_fengshui_level_cache) do
    if value >= v.minValue then
      return HomelandUtils.GetHouseFengShuiCfgById(v.id)
    end
  end
  return nil
end
def.static("number", "=>", "table").GetHouseFengShuiCfgById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_GEOMANCY_CFG, id)
  if record == nil then
    warn("GetHouseFengShuiCfgById(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.minFengShuiValue = record:GetIntValue("minFengShuiValue")
  cfg.addEffectId = record:GetIntValue("addEffectId")
  cfg.decEffectId = record:GetIntValue("decEffectId")
  cfg.showName = record:GetStringValue("showName")
  return cfg
end
local _cleanliness_level_cache
def.static("number", "=>", "table").GetHouseCleanlinessCfg = function(value)
  if _cleanliness_level_cache == nil then
    _cleanliness_level_cache = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_HOMELAND_CLEANNESS_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    local cfgs = _cleanliness_level_cache
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 1, count do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
      local cfg = {}
      cfg.minValue = record:GetIntValue("minCleanlinessValue")
      cfg.id = record:GetIntValue("id")
      cfgs[#cfgs + 1] = cfg
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    table.sort(cfgs, function(l, r)
      return l.minValue > r.minValue
    end)
  end
  if value < 0 then
    warn(string.format("Attempt to GetHouseCleanlinessCfg with a invalid value: %d", value))
    value = 0
  end
  for i, v in ipairs(_cleanliness_level_cache) do
    if value >= v.minValue then
      return HomelandUtils.GetHouseCleanlinessCfgById(v.id)
    end
  end
  return nil
end
def.static("number", "=>", "table").GetHouseCleanlinessCfgById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_CLEANNESS_CFG, id)
  if record == nil then
    warn("GetHouseCleanlinessCfgById(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.minCleanlinessValue = record:GetIntValue("minCleanlinessValue")
  cfg.effectId = record:GetIntValue("effectId")
  cfg.decVigorUseCount = record:GetIntValue("decVigorUseCount")
  cfg.decPetRoomUseCount = record:GetIntValue("decPetRoomUseCount")
  cfg.decSatiationUseCount = record:GetIntValue("decSatiationUseCount")
  cfg.decDrugDoubleRate = record:GetIntValue("decDrugDoubleRate")
  cfg.decKitchenDoubleRate = record:GetIntValue("decKitchenDoubleRate")
  cfg.showName = record:GetStringValue("showName")
  return cfg
end
def.static("number", "=>", "table").GetFurnitureBuyCountCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_FURNITURE_BUY_COUNT_CFG, itemId)
  if record == nil then
    warn("GetFurnitureBuyCountCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.itemId = itemId
  cfg.maxBuyNum = record:GetIntValue("maxBuyNum")
  cfg.buyMoneyType = record:GetIntValue("buyMoneyType")
  cfg.buyMoneyNum = record:GetIntValue("buyMoneyNum")
  cfg.sellMoneyType = record:GetIntValue("sellMoneyType")
  cfg.sellMoneyNum = record:GetIntValue("sellMoneyNum")
  return cfg
end
def.static("=>", "table").GetAllCourtyardCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_HOMELAND_COURTYARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local cfg = HomelandUtils._GetCourtyardCfg(record)
    cfgs[#cfgs + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetCourtyardCfg = function(courtyardLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_COURTYARD_CFG, courtyardLevel)
  if record == nil then
    warn("GetCourtyardCfg(" .. courtyardLevel .. ") return nil")
    return nil
  end
  return HomelandUtils._GetCourtyardCfg(record)
end
def.static("userdata", "=>", "table")._GetCourtyardCfg = function(record)
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.costMoneyType = record:GetIntValue("moneyType")
  cfg.costMoneyNum = record:GetIntValue("moneyNum")
  cfg.mapId = record:GetIntValue("mapId")
  cfg.picId = record:GetIntValue("picId")
  cfg.resourceId = record:GetIntValue("resourceId")
  cfg.showName = record:GetStringValue("showName")
  cfg.offSetX = record:GetIntValue("offSetX")
  cfg.offSetY = record:GetIntValue("offSetY")
  cfg.npcX = record:GetIntValue("npcX")
  cfg.npcY = record:GetIntValue("npcY")
  cfg.npcDir = record:GetIntValue("npcDir")
  cfg.dayCutCleanness = record:GetIntValue("day_cut_cleanliness")
  cfg.maxCleanness = record:GetIntValue("max_cleanliness")
  cfg.maxBeauty = record:GetIntValue("max_beautifual")
  cfg.cleanAddCleanness = record:GetIntValue("add_cleanliness")
  cfg.cleanCostMoneyType = record:GetIntValue("clean_money_type")
  cfg.cleanCostPerCleanness = record:GetIntValue("clean_need_money_num_every_cleanliness")
  cfg.cleanTimesPerDay = record:GetIntValue("day_clean_max_count")
  return cfg
end
def.static("=>", "number").GetCourtyardCfgNums = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_HOMELAND_COURTYARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  return count
end
def.static("=>", "table").GetAlltCourtyardFurnitureBagCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_COURTYARD_FURNITURE_BAG_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.showName = record:GetStringValue("showName")
    cfg.sort = record:GetIntValue("sort")
    cfg.iconId = record:GetIntValue("iconId")
    cfg.subTypes = {}
    local subtypesStruct = record:GetStructValue("subtypesStruct")
    local size = subtypesStruct:GetVectorSize("subtypes")
    for i = 0, size - 1 do
      local vectorRow = subtypesStruct:GetVectorValueByIdx("subtypes", i)
      cfg.subTypes[#cfg.subTypes + 1] = vectorRow:GetIntValue("subtype")
    end
    cfgs[#cfgs + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.sort < r.sort
  end)
  return cfgs
end
local _beauty_level_cache
def.static("number", "=>", "table").GetCourtyardBeautyCfg = function(value)
  if _beauty_level_cache == nil then
    _beauty_level_cache = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_COURTYARD_BEAUTY_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    local cfgs = _beauty_level_cache
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 1, count do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
      local cfg = {}
      cfg.minValue = record:GetIntValue("min_beautiful_value")
      cfg.id = cfg.minValue
      cfgs[#cfgs + 1] = cfg
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    table.sort(cfgs, function(l, r)
      return l.minValue > r.minValue
    end)
  end
  if value < 0 then
    warn(string.format("Attempt to GetCourtyardBeautyCfg with a invalid value: %d", value))
    value = 0
  end
  for i, v in ipairs(_beauty_level_cache) do
    if value >= v.minValue then
      return HomelandUtils.GetCourtyardBeautyCfgById(v.id)
    end
  end
  warn("no beauty level found for " .. value)
  return nil
end
def.static("number", "=>", "table").GetCourtyardBeautyCfgById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COURTYARD_BEAUTY_CFG, id)
  if record == nil then
    warn("GetCourtyardBeautyCfgById(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.minBeautyValue = record:GetIntValue("min_beautiful_value")
  cfg.addEffectId = record:GetIntValue("beautiful_add_effect_id")
  cfg.decEffectId = record:GetIntValue("beautiful_dec_effect_id")
  cfg.feedAnimalNum = record:GetIntValue("every_people_feed_small_animals")
  cfg.showName = record:GetStringValue("show_name")
  return cfg
end
local _courtyard_cleanliness_level_cache
def.static("number", "=>", "table").GetCourtyardCleanlinessCfg = function(value)
  if _courtyard_cleanliness_level_cache == nil then
    _courtyard_cleanliness_level_cache = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_COURTYARD_CLEANNESS_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    local cfgs = _courtyard_cleanliness_level_cache
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 1, count do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
      local cfg = {}
      cfg.minValue = record:GetIntValue("min_cleanliness_value")
      cfg.id = cfg.minValue
      cfgs[#cfgs + 1] = cfg
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    table.sort(cfgs, function(l, r)
      return l.minValue > r.minValue
    end)
  end
  if value < 0 then
    warn(string.format("Attempt to GetCourtyardCleanlinessCfg with a invalid value: %d", value))
    value = 0
  end
  for i, v in ipairs(_courtyard_cleanliness_level_cache) do
    if value >= v.minValue then
      return HomelandUtils.GetCourtyardCleanlinessCfgById(v.id)
    end
  end
  return nil
end
def.static("number", "=>", "table").GetCourtyardCleanlinessCfgById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COURTYARD_CLEANNESS_CFG, id)
  if record == nil then
    warn("GetCourtyardCleanlinessCfgById(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.minCleanlinessValue = record:GetIntValue("min_cleanliness_value")
  cfg.effectId = record:GetIntValue("effect_id")
  cfg.showName = record:GetStringValue("show_name")
  return cfg
end
def.static("=>", "table").GetAllCourtyardFurnitureStyleCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_COURTYARD_FURNITURE_STYLE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.showName = record:GetStringValue("showName")
    cfg.sort = record:GetIntValue("sort")
    cfgs[#cfgs + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.sort < r.sort
  end)
  return cfgs
end
def.static("number", "=>", "table").GetCourtyardFenceResCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COURTYARD_FENCE_CFG, itemId)
  if record == nil then
    warn("GetCourtyardFenceResCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.resourceId = record:GetIntValue("resourceId")
  return cfg
end
def.static("number", "=>", "table").GetCourtyardGroundResCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COURTYARD_GROUND_CFG, itemId)
  if record == nil then
    warn("GetCourtyardGroundResCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.resourceId1 = record:GetIntValue("resourceId1")
  cfg.resourceId2 = record:GetIntValue("resourceId2")
  return cfg
end
def.static("number", "=>", "table").GetCourtyardRoadResCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COURTYARD_ROAD_CFG, itemId)
  if record == nil then
    warn("GetCourtyardRoadResCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.resourceId = record:GetIntValue("resourceId")
  return cfg
end
def.static("number", "=>", "table").GetGroundResCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_GROUND_RES_CFG, itemId)
  if record == nil then
    warn("GetGroundResCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.resourceId1 = record:GetIntValue("resourceId1")
  cfg.resourceId2 = record:GetIntValue("resourceId2")
  return cfg
end
def.static("number", "=>", "table").GetWallResCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOMELAND_WALL_RES_CFG, itemId)
  if record == nil then
    warn("GetWallResCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.resourceId = record:GetIntValue("resourceId")
  return cfg
end
def.static("number", "number").CheckGeomancyChange = function(lastGeomancy, currentGeomancy)
  local lastfFengshuiCfg = HomelandUtils.GetHouseFengShuiCfg(lastGeomancy)
  local curFengshuiCfg = HomelandUtils.GetHouseFengShuiCfg(currentGeomancy)
  if lastfFengshuiCfg.id ~= curFengshuiCfg.id then
    local effectId = 0
    if lastGeomancy < currentGeomancy then
      effectId = lastfFengshuiCfg.addEffectId
    else
      effectId = curFengshuiCfg.decEffectId
    end
    local effectCfg = _G.GetEffectRes(effectId)
    if effectCfg then
      local resPath = effectCfg.path
      require("Fx.GUIFxMan").Instance():Play(resPath, "Geomancy_Change", 0, 0, -1, false)
    end
  end
end
def.static("number", "number").CheckBeautyChange = function(lastBeauty, currentBeauty)
  local lastBeautyCfg = HomelandUtils.GetCourtyardBeautyCfg(lastBeauty)
  local curBeautyCfg = HomelandUtils.GetCourtyardBeautyCfg(currentBeauty)
  if lastBeautyCfg.id ~= curBeautyCfg.id then
    local effectId = 0
    if lastBeauty < currentBeauty then
      effectId = lastBeautyCfg.addEffectId
    else
      effectId = curBeautyCfg.decEffectId
    end
    local effectCfg = _G.GetEffectRes(effectId)
    if effectCfg then
      local resPath = effectCfg.path
      require("Fx.GUIFxMan").Instance():Play(resPath, "Beauty_Change", 0, 0, -1, false)
    end
  end
end
def.static("number", "=>", "boolean").IsEditableFurniture = function(furnitureId)
  local FurniturePosEnum = require("consts.mzm.gsp.item.confbean.FurniturePosEnum")
  local ItemUtils = require("Main.Item.ItemUtils")
  local furnitureCfg = ItemUtils.GetFurnitureCfg(furnitureId)
  if furnitureCfg == nil then
    return false
  end
  local layer = furnitureCfg.layer
  if layer == FurniturePosEnum.WALL or layer == FurniturePosEnum.FLOOR_TILE or layer == FurniturePosEnum.COURT_YARD_FENCE or layer == FurniturePosEnum.COURT_YARD_TERRAIN or layer == FurniturePosEnum.COURT_YARD_ROAD then
    return false
  end
  return true
end
def.static("number").SetWallpaperById = function(furnitureId)
  local wallResCfg = HomelandUtils.GetWallResCfg(furnitureId)
  if wallResCfg == nil then
    return
  end
  local resPath = HomelandUtils.GetResPath(wallResCfg.resourceId)
  if resPath == "" then
    return
  end
  local resInfo = {}
  resInfo.materialPath = resPath
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):SetWallpaper(resInfo)
end
def.static("number").SetFloorTitleById = function(furnitureId)
  local groundRes = HomelandUtils.GetGroundResCfg(furnitureId)
  if groundRes == nil then
    return
  end
  local resPath1 = HomelandUtils.GetResPath(groundRes.resourceId1)
  if resPath1 == "" then
    return
  end
  local resPath2 = HomelandUtils.GetResPath(groundRes.resourceId2)
  if resPath2 == "" then
    return
  end
  local resInfo = {}
  resInfo.groundPath = resPath1
  resInfo.sidePath = resPath2
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):SetFloorTitle(resInfo)
end
def.static("number").SetCourtyardFenceById = function(furnitureId)
  local fenceRes = HomelandUtils.GetCourtyardFenceResCfg(furnitureId)
  if fenceRes == nil then
    return
  end
  local resPath = HomelandUtils.GetResPath(fenceRes.resourceId)
  if resPath == "" then
    return
  end
  local resInfo = {}
  resInfo.materialPath = resPath
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):SetCourtyardFence(resInfo)
end
def.static("number").SetCourtyardGroundById = function(furnitureId)
  local groundRes = HomelandUtils.GetCourtyardGroundResCfg(furnitureId)
  if groundRes == nil then
    return
  end
  local resPath1 = HomelandUtils.GetResPath(groundRes.resourceId1)
  if resPath1 == "" then
    return
  end
  local resPath2 = HomelandUtils.GetResPath(groundRes.resourceId2)
  if resPath2 == "" then
    return
  end
  local resInfo = {}
  resInfo.groundPath = resPath1
  resInfo.groundDecoPath = resPath2
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):SetCourtyardGround(resInfo)
end
def.static("number").SetCourtyardRoadById = function(furnitureId)
  local roadRes = HomelandUtils.GetCourtyardRoadResCfg(furnitureId)
  if roadRes == nil then
    return
  end
  local resPath = HomelandUtils.GetResPath(roadRes.resourceId)
  if resPath == "" then
    return
  end
  local resInfo = {}
  resInfo.materialPath = resPath
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):SetCourtyardRoad(resInfo)
end
def.static("=>", "number").GetMyCourtyardMapId = function()
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  if not homelandModule:HaveHome() then
    print("you do not have homeland!")
    return 0
  end
  local courtyard = homelandModule:GetMyCourtyard()
  local courtyardLevel = courtyard:GetLevel()
  local courtyardCfg = HomelandUtils.GetCourtyardCfg(courtyardLevel)
  if courtyardCfg == nil then
    return 0
  end
  return courtyardCfg.mapId
end
def.static("=>", "number").GetMyHouseMapId = function()
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  if not homelandModule:HaveHome() then
    print("you do not have homeland!")
    return 0
  end
  local house = homelandModule:GetMyHouse()
  local houseLevel = house:GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  if houseCfg == nil then
    return 0
  end
  return houseCfg.mapId
end
def.static("table").SaveItemInfo = function(info)
  local myselfID = require("Main.Hero.HeroModule").Instance():GetHeroProp().id
  local filePath = HomelandUtils.STORE_FILE_ISSHOWNITEM:format(tostring(myselfID))
  LuaUserDataIO.WriteUserData(filePath, "ShownItemInfo", info)
end
def.static("=>", "table").ReadItemTable = function()
  local myselfID = require("Main.Hero.HeroModule").Instance():GetHeroProp().id
  local filePath = HomelandUtils.STORE_FILE_ISSHOWNITEM:format(tostring(myselfID))
  if not LuaUserDataIO.IsUserDataExist(filePath) then
    return {}
  end
  local info = LuaUserDataIO.ReadUserData(filePath)
  if info == nil then
    return {}
  end
  return info
end
def.static("number", "=>", "boolean").CheckItemInfo = function(id)
  local myselfID = require("Main.Hero.HeroModule").Instance():GetHeroProp().id
  local filePath = HomelandUtils.STORE_FILE_ISSHOWNITEM:format(tostring(myselfID))
  if not LuaUserDataIO.IsUserDataExist(filePath) then
    return true
  end
  local info = LuaUserDataIO.ReadUserData(filePath)
  if info[id] == nil then
    return true
  end
  return false
end
return HomelandUtils.Commit()
