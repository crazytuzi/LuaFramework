local Lplus = require("Lplus")
local TipsHelper = Lplus.Class("TipsHelper")
local def = TipsHelper.define
local _instance
def.static("=>", TipsHelper).Instance = function()
  if _instance == nil then
    _instance = TipsHelper()
  end
  return _instance
end
def.field("table").allTips = nil
def.field("table").levelTips = nil
def.field("number").level = 1
def.method().Init = function(self)
  print("TipsHelper init")
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TIP_LIB_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  self.allTips = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    local minlv = DynamicRecord.GetIntValue(entry, "minLevel")
    local maxlv = DynamicRecord.GetIntValue(entry, "maxLevel")
    table.insert(self.allTips, {
      id = id,
      minlv = minlv,
      maxlv = maxlv
    })
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "=>", "string").GetRandomTip = function(self, level)
  if self.allTips == nil then
    self:Init()
  end
  print("GetRandomTip in TipsHelper")
  if level == 0 then
    local count = #self.allTips
    if count <= 0 then
      return ""
    end
    local index = math.random(count)
    local id = self.allTips[index].id
    local record = DynamicData.GetRecord(CFG_PATH.DATA_TIP_LIB_CFG, id)
    local tip = record:GetStringValue("tipcontent")
    return tip
  end
  if self.levelTips == nil or self.level ~= level then
    self:GenerateLevelTips(level)
  end
  local count = #self.levelTips
  if count > 0 then
    local index = math.random(count)
    local id = self.levelTips[index]
    local record = DynamicData.GetRecord(CFG_PATH.DATA_TIP_LIB_CFG, id)
    local tip = record:GetStringValue("tipcontent")
    print("Random help", index)
    return tip
  else
    return ""
  end
end
def.method("number").GenerateLevelTips = function(self, level)
  self.levelTips = {}
  for k, v in ipairs(self.allTips) do
    if level >= v.minlv and level <= v.maxlv then
      table.insert(self.levelTips, v.id)
    end
  end
end
def.static("number", "=>", "string").GetTip = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TIP_LIB_CFG, id)
  if record == nil then
    warn("GetTip(" .. id .. ") return nil")
    return ""
  end
  local tip = record:GetStringValue("tipcontent")
  return tip
end
def.static("number", "=>", "string").GetHoverTip = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HOVER_TIP_CFG, id)
  if record == nil then
    warn("GetHoverTip(" .. id .. ") return nil")
    return ""
  end
  local tip = record:GetStringValue("tipcontent")
  local tip = string.gsub(tip, "\\n", "\n")
  local tip = string.gsub(tip, "/n", "\n")
  return tip
end
def.static("number", "number", "number").ShowHoverTip = function(id, x, y)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = TipsHelper.GetHoverTip(id)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = x, y = y})
end
TipsHelper.Commit()
return TipsHelper
