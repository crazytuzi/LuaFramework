local Lplus = require("Lplus")
local KejuUtils = Lplus.Class("KejuUtils")
local def = KejuUtils.define
def.static("number", "=>", "table").GetQuestion = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_QUESTION, id)
  if not record then
    warn("Keju Question id not found:" .. id)
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
local kejuCfg
def.static("=>", "table").GetKejuCfg = function()
  if kejuCfg ~= nil then
    return kejuCfg
  end
  kejuCfg = {}
  kejuCfg.acticityId = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "ACTIVITY_ID"):GetIntValue("value")
  kejuCfg.dianshiMap = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "DIANSHI_MAP_ID"):GetIntValue("value")
  kejuCfg.xiangshiNPC = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "XIANGSHI_NPC_ID"):GetIntValue("value")
  kejuCfg.huishiNPC = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "HUISHI_NPC_ID"):GetIntValue("value")
  kejuCfg.dianshiNPC = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "DIANSHI_NPC_ID"):GetIntValue("value")
  kejuCfg.dianshiEnterNPC = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "DIANSHI_ENTER_NPC_ID"):GetIntValue("value")
  kejuCfg.xiangShiNumber = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "XIANGSHI_QUESTION_NUM"):GetIntValue("value")
  kejuCfg.huiShiNumber = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "HUIGSHI_QUESTION_NUM"):GetIntValue("value")
  kejuCfg.dianShiNumber = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "DIANSHI_QUESTION_NUM"):GetIntValue("value")
  kejuCfg.xiangShiTime = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "XIANGSHI_PERSIST_MINUTE"):GetIntValue("value") * 60
  kejuCfg.huiShiTime = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "HUISHI_PERSIST_MINUTE"):GetIntValue("value") * 60
  kejuCfg.dianShiPrepareTime = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "HUISHI_REST_MINUTE"):GetIntValue("value") * 60
  kejuCfg.dianShiTime = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "DIANSHI_PERSIST_MINUTE"):GetIntValue("value") * 60
  kejuCfg.xiangshiTip = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "XIANGSHI_TIPS"):GetIntValue("value")
  kejuCfg.huishiTip = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "HUISHI_TIPS"):GetIntValue("value")
  kejuCfg.dianshiTip = DynamicData.GetRecord(CFG_PATH.DATA_KEJU_CONST, "DIANSHI_TIPS"):GetIntValue("value")
  return kejuCfg
end
KejuUtils.Commit()
return KejuUtils
