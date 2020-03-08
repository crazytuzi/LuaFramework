local Lplus = require("Lplus")
local CorpsUtils = Lplus.Class("CorpsUtils")
local def = CorpsUtils.define
def.static("=>", "table").GetAllCorpsBadgeCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CORPS_BADGE)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = entry:GetIntValue("id")
    cfg.iconId = entry:GetIntValue("iconId")
    table.insert(list, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "=>", "table").GetCorpsBadgeCfg = function(badgeId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CORPS_BADGE, badgeId)
  if record == nil then
    warn("GetCorpsBadgeCfg nil", badgeId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.iconId = record:GetIntValue("iconId")
  return cfg
end
def.static("string", "=>", "boolean").IsNameValid = function(name)
  if name == "" then
    Toast(textRes.Corps[5])
    return false
  end
  local CorpsNameValidator = require("Main.Corps.CorpsNameValidator")
  local isValid, reason, _ = CorpsNameValidator.Instance():IsValid(name)
  if not isValid then
    if reason == CorpsNameValidator.InvalidReason.TooShort then
      Toast(string.format(textRes.Corps[6], constant.CorpsConsts.CORPS_NAME_MIN_LENGTH, constant.CorpsConsts.CORPS_NAME_MAX_LENGTH, constant.CorpsConsts.CORPS_NAME_MIN_LENGTH, constant.CorpsConsts.CORPS_NAME_MAX_LENGTH * 2))
    elseif reason == CorpsNameValidator.InvalidReason.TooLong then
      Toast(string.format(textRes.Corps[6], constant.CorpsConsts.CORPS_NAME_MIN_LENGTH, constant.CorpsConsts.CORPS_NAME_MAX_LENGTH, constant.CorpsConsts.CORPS_NAME_MIN_LENGTH, constant.CorpsConsts.CORPS_NAME_MAX_LENGTH * 2))
    elseif reason == CorpsNameValidator.InvalidReason.NotInSection then
      Toast(textRes.Corps[7])
    end
    return false
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(name) then
    Toast(textRes.Corps[8])
    return false
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name, "Name") then
    Toast(textRes.Corps[9])
    return false
  end
  return true
end
def.static("string", "=>", "boolean").IsDeclareValid = function(declare)
  if declare == "" then
    Toast(textRes.Corps[12])
    return false
  end
  local len, clen, hlen = Strlen(declare)
  local showLen = clen / 2 + hlen
  if showLen > constant.CorpsConsts.CORPS_DECLARATION_MAX_LENGTH or showLen < constant.CorpsConsts.CORPS_DECLARATION_MIN_LENGTH * 0.5 then
    Toast(string.format(textRes.Corps[10], constant.CorpsConsts.CORPS_DECLARATION_MIN_LENGTH, constant.CorpsConsts.CORPS_DECLARATION_MAX_LENGTH, constant.CorpsConsts.CORPS_DECLARATION_MIN_LENGTH, constant.CorpsConsts.CORPS_DECLARATION_MAX_LENGTH * 2))
    return false
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(declare) then
    Toast(textRes.Corps[11])
    return false
  end
  return true
end
def.static("number", "=>", "string").GetHistroyStr = function(type)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CORPS_HISTORY, type)
  if record == nil then
    warn("GetHistroyStr nil", badgeId)
    return nil
  end
  local str = record:GetStringValue("historyDescribe")
  return str
end
return CorpsUtils.Commit()
