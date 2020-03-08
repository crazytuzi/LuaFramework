local Lplus = require("Lplus")
local FestivalUtility = Lplus.Class("FestivalUtility")
local def = FestivalUtility.define
def.static("number", "=>", "table").GetFestivalCfgById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FESTIVAL_AWARD_CFG, id)
  if not record then
    warn("fail to read festival award cfg", id)
    return nil
  end
  local cfg = {}
  cfg.festivalName = record:GetStringValue("festivalName")
  cfg.festivalDesc = record:GetStringValue("festivalTip")
  cfg.limitTime = record:GetIntValue("limitTime")
  cfg.giftid = record:GetIntValue("giftid")
  cfg.mailid = record:GetIntValue("notifyMailid")
  cfg.minLevel = record:GetIntValue("minLevel")
  return cfg
end
def.static("string", "=>", "number").GetFestivalConstByName = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FESTIVAL_AWARD_CONSTS, name)
  if not record then
    warn("fail to get festival const", name)
    return -1
  end
  return record:GetIntValue("value")
end
def.static("string", "number").FillNPCDialogContent = function(text, npcId)
  local contents = {}
  local content = {}
  content.npcid = npcId
  content.txt = text
  table.insert(contents, content)
  local param, fnCallback
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  taskModule:ShowTaskTalkCustom(contents, param, fnCallback)
end
return FestivalUtility.Commit()
