local Lplus = require("Lplus")
local DouDouClearUtils = Lplus.Class("DouDouClearUtils")
local ServerRandomGenerator = require("Common.ServerRandomGenerator")
local def = DouDouClearUtils.define
local doudouCfgCache
def.static("number", "=>", "table").GetDouDouCfg = function(cfgId)
  if doudouCfgCache then
    return doudouCfgCache[cfgId]
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUDOU_CFG, cfgId)
  if not record then
    warn("GetDouDouCfg nil:", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.dyeId = record:GetIntValue("dyeId")
  cfg.weight = record:GetIntValue("weight")
  cfg.headIcon = record:GetIntValue("iconId")
  cfg.talk = record:GetStringValue("talktext")
  cfg.canDelete = record:GetCharValue("canDelete") ~= 0
  return cfg
end
def.static("=>", "table").GetAllDouDouCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DOUDOU_CFG)
  if not entries then
    return nil
  end
  doudouCfgCache = {}
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.name = record:GetStringValue("name")
    cfg.modelId = record:GetIntValue("modelId")
    cfg.dyeId = record:GetIntValue("dyeId")
    cfg.weight = record:GetIntValue("weight")
    cfg.headIcon = record:GetIntValue("iconId")
    cfg.talk = record:GetStringValue("talktext")
    cfg.canDelete = record:GetCharValue("canDelete") ~= 0
    doudouCfgCache[cfg.id] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return doudouCfgCache
end
def.static().ClearCfgCache = function()
  doudouCfgCache = nil
end
local all_path
def.static("=>", "table").GetAllPos = function()
  if all_path == nil then
    local entries = DynamicData.GetTable(CFG_PATH.DATA_DOUDOU_PATH_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    all_path = {}
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local cfg = {}
      cfg.index = entry:GetIntValue("seq")
      cfg.x = entry:GetIntValue("x")
      cfg.y = entry:GetIntValue("y")
      table.insert(all_path, cfg)
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    table.sort(all_path, function(a, b)
      return a.index < b.index
    end)
  end
  return all_path
end
local all_doudou
def.static().InitAllDouDou = function()
  if all_doudou == nil then
    local entries = DynamicData.GetTable(CFG_PATH.DATA_DOUDOU_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    all_doudou = {}
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local id = entry:GetIntValue("id")
      local weight = entry:GetIntValue("weight")
      table.insert(all_doudou, {id = id, weight = weight})
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    table.sort(all_doudou, function(a, b)
      return a.id < b.id
    end)
  end
end
local _filter_table_by_id = {}
setmetatable(_filter_table_by_id, {__mode = "v"})
local function filter_table_by_id(tbl, id1, id2)
  if id1 > 0 and id2 > 0 and id1 == id2 then
    if _filter_table_by_id[id1] then
      return _filter_table_by_id[id1]
    end
    local filter_tbl = clone(tbl)
    for i = #filter_tbl, 1, -1 do
      if filter_tbl[i].id == id1 then
        table.remove(filter_tbl, i)
        break
      end
    end
    _filter_table_by_id[id1] = filter_tbl
    return filter_tbl
  else
    return clone(tbl)
  end
end
local _count_weight = {}
setmetatable(_count_weight, {__mode = "k"})
local function count_weight(tbl)
  if _count_weight[tbl] then
    return _count_weight[tbl]
  end
  local ret = 0
  for k, v in ipairs(tbl) do
    ret = ret + v.weight
  end
  _count_weight[tbl] = ret
  return ret
end
local select_by_weight = function(tbl, w)
  if #tbl <= 0 then
    return 0
  end
  local high = 0
  for k, v in ipairs(tbl) do
    high = high + v.weight
    if w < high then
      return v.id
    end
  end
  return 0
end
def.static("number", "number", "number", "number", "=>", "table").GenDoudou = function(seed, count, last1, last2)
  if all_doudou == nil then
    DouDouClearUtils.InitAllDouDou()
  end
  warn("Seed", seed, last1, last2)
  local randomer = ServerRandomGenerator.make_srg(seed)
  local last1 = last1
  local last2 = last2
  local ret = {}
  for i = 1, count do
    local filter_doudou = filter_table_by_id(all_doudou, last1, last2)
    local all_weight = count_weight(filter_doudou)
    local r = randomer("int", all_weight)
    local doudouId = select_by_weight(filter_doudou, r)
    if doudouId > 0 then
      table.insert(ret, doudouId)
      last2 = last1
      last1 = doudouId
    else
      error("bad random")
    end
  end
  return ret
end
return DouDouClearUtils.Commit()
