local Lplus = require("Lplus")
local QYXTUtils = Lplus.Class("QYXTUtils")
local def = QYXTUtils.define
def.static("number", "=>", "table").GetQuestion = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_QYXTQUESTION_CFG, id)
  if not record then
    warn("QYXT Question id not found:" .. id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.question = record:GetStringValue("question")
  cfg.answers = {}
  local answersStruct = record:GetStructValue("answersStruct")
  local size = answersStruct:GetVectorSize("answersList")
  for i = 0, size - 1 do
    local rec = answersStruct:GetVectorValueByIdx("answersList", i)
    local answer = rec:GetStringValue("answer")
    if answer ~= "" then
      table.insert(cfg.answers, {id = i, text = answer})
    end
  end
  return cfg
end
QYXTUtils.Commit()
return QYXTUtils
