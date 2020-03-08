local Lplus = require("Lplus")
local ChatBubbleUtils = Lplus.Class("ChatBubbleUtils")
local def = ChatBubbleUtils.define
local ShowType = require("consts.mzm.gsp.chatbubble.confbean.ShowType")
def.static("userdata", "=>", "table")._getBubbleCfgValues = function(record)
  if record == nil then
    return nil
  end
  local retData = {}
  retData.cfgId = record:GetIntValue("id")
  retData.name = record:GetStringValue("name")
  retData.gender = record:GetIntValue("gender")
  retData.menpai = record:GetIntValue("menpai")
  retData.icon = record:GetIntValue("icon")
  retData.desc = record:GetStringValue("description")
  retData.duration = record:GetIntValue("duration")
  retData.index = record:GetIntValue("index")
  retData.bShow = record:GetIntValue("showType") == ShowType.SHOW
  retData.myUIReource = record:GetStringValue("myUiResourceName")
  retData.uiResource = record:GetStringValue("uiResourceName")
  local R = record:GetIntValue("uiFontColorR")
  local G = record:GetIntValue("uiFontColorG")
  local B = record:GetIntValue("uiFontColorB")
  local divor = 0.00392156862745098
  retData.uiFontColor = {
    R = R,
    G = G,
    B = B
  }
  retData.sceneResource = record:GetStringValue("sceneResourceName")
  R = record:GetIntValue("sceneFontColorR")
  G = record:GetIntValue("sceneFontColorG")
  B = record:GetIntValue("sceneFontColorB")
  retData.sceneFontColor = {
    R = R,
    G = G,
    B = B
  }
  retData.arrowResource = record:GetStringValue("arrowResourceName")
  return retData
end
local cacheCfg = {}
local cacheNum = 0
def.static("number", "=>", "table").GetBubbleCfgById = function(cfgId)
  local retData = cacheCfg[cfgId]
  if retData ~= nil then
    return retData
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ChatBubbleCfg, cfgId)
  if record == nil then
    warn("Load DATA_ChatBubbleCfg error cfgId", cfgId)
    return retData
  end
  retData = {}
  retData = ChatBubbleUtils._getBubbleCfgValues(record)
  if cacheNum > 10 then
    for k, v in pairs(cacheCfg) do
      cacheCfg[k] = nil
      cacheNum = cacheNum - 1
      break
    end
  end
  cacheCfg[cfgId] = retData
  cacheNum = cacheNum + 1
  return retData
end
def.static("=>", "table").LoadAllBubleCfgs = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ChatBubbleCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local data = ChatBubbleUtils._getBubbleCfgValues(record)
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "number", "=>", "table").GetBubbleCfgsByOccupAndSex = function(occup, gender)
  local allBubbles = ChatBubbleUtils.LoadAllBubleCfgs() or {}
  local retData = {}
  for i = 1, #allBubbles do
    local bubbleCfg = allBubbles[i]
    if (bubbleCfg.menpai == 0 or bubbleCfg.menpai == occup) and (bubbleCfg.gender == 0 or bubbleCfg.gender == gender) then
      table.insert(retData, bubbleCfg)
    end
  end
  return retData
end
def.static("number", "=>", "number").GetCfgIdByItemId = function(itemId)
  local retData = 0
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ChatBubbleItemId2CfgId, itemId)
  if record == nil then
    warn("Load DATA_ChatBubbleItemId2CfgId error itemId", itemId)
    return retData
  end
  retData = record:GetIntValue("chatBubbleCfgId")
  return retData
end
def.static("number", "=>", "table").GetItemIdsByCfgId = function(cfgId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ChatBubbleCfgId2ItemIds, cfgId)
  if record == nil then
    warn("Load DATA_ChatBubbleCfgId2ItemIds error cfgId", cfgId)
    return retData
  end
  retData = {}
  local itemStruct = record:GetStructValue("chatBubbleItemCfgIdsStruct")
  local vecSize = itemStruct:GetVectorSize("chatBubbleItemCfgIds")
  for i = 1, vecSize do
    local record = itemStruct:GetVectorValueByIdx("chatBubbleItemCfgIds", i - 1)
    local itemId = record:GetIntValue("itemId")
    table.insert(retData, itemId)
  end
  return retData
end
def.static("userdata", "string").SetSprite = function(uiObj, spriteName)
  if _G.IsNil(uiObj) then
    warn("[ERROR:param uiObj is nil]")
    return
  end
  local comSprite = uiObj:GetComponent("UISprite")
  if comSprite == nil then
    warn("[ERROR:uiObj UISprite component is not exist")
    return
  end
  _G.GameUtil.AsyncLoad(RESPATH.CHAT_BUBBLE_ATLAS, function(obj)
    if _G.IsNil(obj) or _G.IsNil(comSprite) then
      return
    end
    local atlas = obj:GetComponent("UIAtlas")
    comSprite:set_atlas(atlas)
    comSprite:set_spriteName(spriteName)
  end)
  comSprite:set_spriteName(spriteName)
end
return ChatBubbleUtils.Commit()
