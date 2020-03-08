local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CrossBattlefieldUtils = Lplus.Class(MODULE_NAME)
local MathHelper = require("Common.MathHelper")
local def = CrossBattlefieldUtils.define
def.static("=>", "table").GetAllCrossBattlefieldCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_BATTLEFIELD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = CrossBattlefieldUtils._GetCrossBattlefieldCfg(entry)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetCrossBattlefieldCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLEFIELD_CFG, id)
  if record == nil then
    warn("GetCrossBattlefieldCfg(" .. id .. ") return nil")
    return nil
  end
  return CrossBattlefieldUtils._GetCrossBattlefieldCfg(record)
end
def.static("userdata", "=>", "table")._GetCrossBattlefieldCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("activity_cfg_id")
  cfg.single_battle_cfg_id = record:GetIntValue("single_battle_cfg_id")
  cfg.icon_id = record:GetIntValue("icon_id")
  cfg.moduleid = record:GetIntValue("moduleid")
  cfg.role_num = record:GetIntValue("role_num")
  cfg.tips_id = record:GetIntValue("tips_id")
  cfg.field_name = record:GetStringValue("field_name")
  cfg.field_desc = record:GetStringValue("field_desc")
  cfg.img_name = record:GetStringValue("img_name")
  return cfg
end
local _star_num_lookup_table
def.static("number", "=>", "table").GetDuanweiCfgByStarNum = function(starNum)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_BATTLEFIELD_GRADE_CFG)
  if _star_num_lookup_table == nil then
    _star_num_lookup_table = {}
    local count = DynamicDataTable.GetRecordsCount(entries)
    local cfgs = {}
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local star_num_lower_limit = entry:GetIntValue("star_num_lower_limit")
      table.insert(_star_num_lookup_table, {starNum = star_num_lower_limit, idx = i})
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    table.sort(_star_num_lookup_table, function(l, r)
      return l.starNum > r.starNum
    end)
  end
  local index = MathHelper.lower_bound(_star_num_lookup_table, {starNum = starNum}, function(left, right)
    return left.starNum > right.starNum
  end)
  local rs = _star_num_lookup_table[index]
  if rs == nil then
    error(string.format("Cann't find a Duanwei for starNum = %d", starNum))
  end
  local dataIdx = rs.idx
  local record = DynamicDataTable.GetRecordByIdx(entries, dataIdx)
  return CrossBattlefieldUtils._GetDuanweiCfg(record)
end
def.static("=>", "table").GetAllDuanweiCfgs = function()
  local cfgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_BATTLEFIELD_GRADE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = CrossBattlefieldUtils._GetDuanweiCfg(entry)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("userdata", "=>", "table")._GetDuanweiCfg = function(record)
  local cfg = {}
  cfg.star_num_lower_limit = record:GetIntValue("star_num_lower_limit")
  cfg.desc = record:GetStringValue("desc")
  cfg.sort_id = record:GetIntValue("sort_id")
  cfg.icon_id = record:GetIntValue("icon_id")
  cfg.fix_award_id = record:GetIntValue("fix_award_id")
  return cfg
end
def.static("=>", "table").GetDuanweiAwardGroups = function()
  local allCfgs = CrossBattlefieldUtils.GetAllDuanweiCfgs()
  local awardGroups = {}
  local awardMap = {}
  for i, v in ipairs(allCfgs) do
    local starNum = v.star_num_lower_limit
    local awardId = v.fix_award_id or 0
    if awardId > 0 then
      if awardMap[awardId] == nil then
        awardMap[awardId] = {
          minStarNum = starNum,
          maxStarNum = starNum,
          awardId = awardId
        }
        table.insert(awardGroups, awardMap[awardId])
      else
        awardMap[awardId].maxStarNum = starNum
      end
    end
  end
  return awardGroups
end
def.static("=>", "table").GetAllCrossBattlefieldSeasonCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_BATTLEFIELD_SEASON_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = CrossBattlefieldUtils._GetCrossBattlefieldSeasonCfg(entry)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.season < r.season
  end)
  return cfgs
end
def.static("number", "=>", "table").GetCrossBattlefieldSeasonCfg = function(season)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLEFIELD_SEASON_CFG, season)
  if record == nil then
    warn("GetCrossBattlefieldSeasonCfg(" .. season .. ") return nil")
    return nil
  end
  return CrossBattlefieldUtils._GetCrossBattlefieldSeasonCfg(record)
end
def.static("userdata", "=>", "table")._GetCrossBattlefieldSeasonCfg = function(record)
  local cfg = {}
  cfg.season = record:GetIntValue("sort_id")
  cfg.desc = record:GetStringValue("desc")
  cfg.year = record:GetIntValue("year")
  cfg.month = record:GetIntValue("month")
  cfg.day = record:GetIntValue("day")
  cfg.hour = record:GetIntValue("hour")
  cfg.minute = record:GetIntValue("minute")
  return cfg
end
def.static("=>", "table", "table").GetRecentlySeasonInfo = function()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local allSeasonCfgs = CrossBattlefieldUtils.GetAllCrossBattlefieldSeasonCfgs()
  local curTime = _G.GetServerTime()
  local curSeasonInfo, nextSeasonInfo
  for i, v in ipairs(allSeasonCfgs) do
    local timestamp = AbsoluteTimer.GetServerTimeByDate(v.year, v.month, v.day, v.hour, v.minute, 0)
    if curTime < timestamp then
      nextSeasonInfo = v
      break
    else
      curSeasonInfo = v
    end
  end
  return curSeasonInfo, nextSeasonInfo
end
def.static("=>", "table").GetAllSeasonAwardDisplayCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_BATTLEFIELD_AWARD_DISPLAY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = CrossBattlefieldUtils._GetSeasonAwardDisplayCfg(entry)
    local rankCfgs = cfgs[cfg.rank_type] or {}
    table.insert(rankCfgs, cfg)
    cfgs[cfg.rank_type] = rankCfgs
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  for rank_type, v in pairs(cfgs) do
    table.sort(v, function(l, r)
      return l.rank < r.rank
    end)
  end
  return cfgs
end
def.static("userdata", "=>", "table")._GetSeasonAwardDisplayCfg = function(record)
  local cfg = {}
  cfg.rank_type = record:GetIntValue("rank_type")
  cfg.rank = record:GetIntValue("rank")
  cfg.desc = record:GetStringValue("desc")
  cfg.items = {}
  for i = 1, 3 do
    local itemId = record:GetIntValue(string.format("item_%d_cfg_id", i))
    local itemNum = record:GetIntValue(string.format("item_%d_num", i))
    table.insert(cfg.items, {itemId = itemId, itemNum = itemNum})
  end
  return cfg
end
return CrossBattlefieldUtils.Commit()
