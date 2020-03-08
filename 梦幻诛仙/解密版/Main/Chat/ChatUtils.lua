local Lplus = require("Lplus")
local ChatUtils = Lplus.Class("ChatUtils")
local AtUtils = require("Main.Chat.At.AtUtils")
local def = ChatUtils.define
def.const("table")._linkFormats = {
  item = "{i:.-,%d+,%d+,.-,.-}",
  fabao = "{fb:.-,%d+,%d+,.-,.-}",
  wing = "{w:.-,%d+,%d+,.-}",
  aircraft = "{a:.-,%d+,%d+,.-}",
  pet = "{p:.-,.-,.-,.-,.-}",
  task = "{t:.-,%d+}",
  chengwei = "{chengwei:.-,%d+}",
  touxian = "{touxian:.-,%d+}",
  fashion = "{f:.-,%d+}",
  mount = "{mounts:.-,.-,.-}",
  child = "{child:.-,.-}",
  role = "{" .. AtUtils.AT_PREFIX .. ":%d+,.-,.-,.-}"
}
def.static("number", "=>", "number").GetIconIdByModelId = function(modelId)
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  local iconId = modelRecord:GetIntValue("halfBodyIconId")
  return iconId
end
def.static("number", "=>", "string").GetOccupationSpriteName = function(id)
  return string.format("%d-8", id)
end
def.static("number", "number", "=>", "string").GetHeadSpriteName = function(Occupation, gender)
  return string.format("%d-%d", Occupation, gender)
end
def.static("string", "=>", "string").ChatContentTrim = function(str)
  local i = -1
  while true do
    local var = str:sub(i, i)
    if var == " " then
      i = i - 1
    else
      break
    end
  end
  return str:sub(1, i)
end
def.static("=>", "table").GetChatPreset = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHAT_PRESET)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local ret = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    ret[i + 1] = DynamicRecord.GetStringValue(entry, "content")
  end
  return ret
end
def.static("=>", "number").GetHelpTipsInterval = function()
  return DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "helpHintTimeLag"):GetIntValue("value")
end
def.static("string", "=>", "string").FilterHtmlTag = function(src)
  do return src end
  local pattern = "%b<>"
  local dst = string.gsub(src, pattern, "")
  return dst
end
def.static("string", "=>", "boolean").IsStringEmoji = function(str)
  return str and string.find(str, "{e:%w+}") ~= nil
end
def.static("string", "=>", "number").GetChatLinkCount = function(cnt)
  local result = 0
  if cnt then
    for key, format in pairs(ChatUtils._linkFormats) do
      for str in string.gmatch(cnt, format) do
        result = result + 1
      end
    end
  end
  return result
end
def.static("userdata", "=>", "number").GetTimeInSecFromStamp = function(timeStamp)
  local result = 0
  if timeStamp then
    result = Int64.ToNumber(timeStamp / 1000)
  else
    result = GetServerTime()
  end
  return result
end
ChatUtils.Commit()
return ChatUtils
