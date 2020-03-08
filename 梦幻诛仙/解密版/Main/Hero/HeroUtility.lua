local Lplus = require("Lplus")
local HeroUtility = Lplus.Class("HeroUtility")
local def = HeroUtility.define
def.field("table").commonConsts = nil
local instance
def.static("=>", HeroUtility).Instance = function()
  if instance == nil then
    instance = HeroUtility()
  end
  return instance
end
def.method("userdata", "=>", "userdata").RoleIDToDisplayID = function(self, roleId)
  local base = 1000000
  local step = 4096
  local roleIndex = roleId / step
  local serverIndex = roleId % step
  local lowIndex = roleIndex % base
  local highIndex = serverIndex + roleIndex / base * step
  local displayId = highIndex * base + lowIndex
  return displayId
end
def.method("userdata", "=>", "userdata").DisplayIDToRoleID = function(self, displayId)
  local base = 1000000
  local step = 4096
  local lowIndex = displayId % base
  local highIndex = displayId / base
  local serverIndex = highIndex % step
  local roleIndex = lowIndex + highIndex / step * base
  local roleId = roleIndex * step + serverIndex
  return roleId
end
def.method("string", "=>", "number").GetRoleCommonConsts = function(self, key)
  if self.commonConsts and self.commonConsts[key] then
    return self.commonConsts[key]
  end
  self.commonConsts = self.commonConsts or {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ROLE_COMMON_CONSTS, key)
  if record == nil then
    warn("GetRoleCommonConsts(" .. key .. ") return nil")
    return nil
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  self.commonConsts[key] = value
  return value
end
def.static("number", "=>", "table").GetRoleRecommandAssignPropCfg = function(occupation)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ROLE_RECOMMAND_ASSIGN_PROP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgList = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local occupationId = DynamicRecord.GetIntValue(entry, "occupationId")
    if occupationId == occupation then
      local cfg = {}
      cfg.con = DynamicRecord.GetIntValue(entry, "CON")
      cfg.dex = DynamicRecord.GetIntValue(entry, "DEX")
      cfg.spi = DynamicRecord.GetIntValue(entry, "SPR")
      cfg.sta = DynamicRecord.GetIntValue(entry, "STA")
      cfg.str = DynamicRecord.GetIntValue(entry, "STR")
      cfg.desc = DynamicRecord.GetStringValue(entry, "desc")
      table.insert(cfgList, cfg)
    end
  end
  return cfgList
end
def.static("number", "=>", "table").GetDefaultAssignPropScheme = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DEFAULT_ASSIGN_PROP_SCHEME, id)
  if record == nil then
    warn("GetDefaultAssignPropScheme(" .. id .. ") failed.")
    return nil
  end
  local scheme = {}
  scheme.con = record:GetIntValue("CON")
  scheme.dex = record:GetIntValue("DEX")
  scheme.spi = record:GetIntValue("SPR")
  scheme.sta = record:GetIntValue("STA")
  scheme.str = record:GetIntValue("STR")
  return scheme
end
def.static("number", "number", "=>", "number").GetAwardVigor = function(awardType, level)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AWARD_VIGOR_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  local awardVigor
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    cfg.awardType = entry:GetIntValue("awardType")
    cfg.levelMin = entry:GetIntValue("levelMin")
    cfg.levelMax = entry:GetIntValue("levelMax")
    if cfg.awardType == awardType and level >= cfg.levelMin and level <= cfg.levelMax then
      awardVigor = entry:GetIntValue("awardVigor")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if awardVigor == nil then
    awardVigor = 0
  end
  return awardVigor
end
def.static("=>", "table").GetAllVigorDescCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_VIGOR_DESC_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = HeroUtility._GetVigorDescCfgs(entry)
    cfgs[cfg.awardType] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetVigorDescCfgs = function(awardType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_VIGOR_DESC_CFG, awardType)
  if record == nil then
    warn("GetVigorDescCfgs(" .. awardType .. ") failed.")
    return nil
  end
  return HeroUtility._GetVigorDescCfgs(record)
end
def.static("userdata", "=>", "table")._GetVigorDescCfgs = function(record)
  local cfg = {}
  cfg.awardType = record:GetIntValue("awardType")
  cfg.param = record:GetIntValue("param")
  cfg.paramType = record:GetIntValue("paramType")
  cfg.count = record:GetIntValue("count")
  cfg.desc = record:GetStringValue("desc")
  return cfg
end
def.static("=>", "string").GetEnergyTipText = function(self)
  local keyBase = "VIGOR_TIPS"
  local tipCount = 3
  local texts = {}
  local TipsHelper = require("Main.Common.TipsHelper")
  for i = 1, tipCount do
    local key = keyBase .. i
    local value = HeroUtility.Instance():GetRoleCommonConsts(key)
    local text = TipsHelper.GetTip(value)
    local text = string.format(textRes.Common[28], text)
    table.insert(texts, text)
  end
  return table.concat(texts, "\n")
end
def.static("number", "number", "=>", "table").GetRoleInitEquipmentCfg = function(occupationId, gender)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ROLE_INIT_EQUIPMENT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    cfg.occupationId = entry:GetIntValue("occupationId")
    cfg.gender = entry:GetIntValue("gender")
    if cfg.occupationId == occupationId and cfg.gender == gender then
      cfg.weaponId = entry:GetIntValue("weaponId")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if cfg.weaponId == nil then
    warn("GetRoleInitEquipmentCfg(" .. occupationId .. "," .. gender .. ") failed!")
  end
  return cfg
end
def.method().Rename = function(self)
  local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
  CommonRenamePanel:ShowPanel(textRes.Hero[13], true, HeroUtility.OnRenameButtonClick, self)
end
def.method("string", "=>", "boolean").ValidEnteredName = function(self, enteredName)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Login[15])
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Login[14])
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Login[25])
    end
    return false
  end
end
def.static("string", "table", "=>", "boolean").OnRenameButtonClick = function(name, self)
  local isValid = self:ValidEnteredName(name)
  if not isValid then
    return true
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(name) then
    Toast(textRes.Login[3])
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name, "Name") then
    Toast(textRes.Login[24])
    return true
  end
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
  local itemId = HeroUtility.Instance():GetRoleCommonConsts("RENAME_ITEM_TYPE_ID")
  local ItemModule = require("Main.Item.ItemModule")
  local renameItemNum = ItemModule.Instance():GetItemCountById(itemId)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local USE_ITEM_NUM = 1
  local desc = string.format(textRes.Hero[9], name)
  local title, extendItemId, itemNeed = textRes.Hero[8], itemId, USE_ITEM_NUM
  local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
  ItemConsumeHelper.Instance():ShowItemConsume(title, desc, extendItemId, itemNeed, function(select)
    local function Rename(extraParams)
      HeroPropMgr.Instance():Rename(name, extraParams)
    end
    if select < 0 then
    elseif select == 0 then
      Rename({isYuanBaoBuZu = false})
    else
      Rename({isYuanBaoBuZu = true})
    end
  end)
  return true
end
local resPath
def.static("=>", "string").GetLvlUpEffectResPath = function()
  if resPath then
    return resPath
  end
  local effectId = HeroUtility.Instance():GetRoleCommonConsts("LEVEL_UP_EFFECT")
  local effectCfg = _G.GetEffectRes(effectId)
  resPath = effectCfg.path
  return resPath
end
local resPath
def.static("=>", "string").GetLvlUpTextEffectResPath = function()
  if resPath then
    return resPath
  end
  local effectId = HeroUtility.Instance():GetRoleCommonConsts("LEVEL_UP_FONT_EFFECT")
  local effectCfg = _G.GetEffectRes(effectId)
  resPath = effectCfg.path
  return resPath
end
HeroUtility.Commit()
return HeroUtility
