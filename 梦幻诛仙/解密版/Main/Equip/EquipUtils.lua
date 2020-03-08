local Lplus = require("Lplus")
local EquipUtils = Lplus.Class("EquipUtils")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local CommonDescDlg = require("GUI.CommonUITipsDlg")
local EquipInfoShowDlg = require("Main.Equip.ui.EquipInfoShowDlg")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local QiLinMode = require("netio/protocol/mzm/gsp/item/QiLinMode")
local def = EquipUtils.define
def.static("=>", "number").GetEquipStrenAnounceLevel = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "EQUIP_ANNOUNCE_MIN_LIN_LEVEL")
  local equipAnounceLev = DynamicRecord.GetIntValue(record, "value")
  return equipAnounceLev
end
def.static("=>", "number").GetEquipMakeDelta = function()
  local record1 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MAX_DELTA_OF_EQUIP_LEVEL_TO_ROLE_LEVEL")
  local levelIncrease = DynamicRecord.GetIntValue(record1, "value")
  return levelIncrease
end
def.static("=>", "number").GetEquipStrenMaxLevel = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "EQUIP_QILIN_MAX_LIN_LEVEL")
  local equipStrenMaxLev = DynamicRecord.GetIntValue(record0, "value")
  return equipStrenMaxLev
end
def.static("=>", "number").GetEquipOpenMinLevel = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "EQUIP_MAKE_MIN_LEVEL")
  local equipOpenMinLev = DynamicRecord.GetIntValue(record0, "value")
  return equipOpenMinLev
end
def.static("=>", "number").GetEquipStrenSucMinLevel = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "QILIN_SUC_MIN_LIN_LEVEL")
  local strenSucMinLev = DynamicRecord.GetIntValue(record0, "value")
  return strenSucMinLev
end
def.static("=>", "number").GetEquipStrenNeedItemId = function()
  local record1 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "QILIN_NEED_ITEM_ID")
  local strenItemId1 = DynamicRecord.GetIntValue(record1, "value")
  return strenItemId1
end
def.static("=>", "number").GetEquipStrenZhenlingfuItemId = function()
  local record1 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "ZHENLIN_STONE_ITEM_ID")
  local strenItemId1 = DynamicRecord.GetIntValue(record1, "value")
  return strenItemId1
end
def.static("string", "=>", "number").GetEquipFunctionNeedLevel = function(funcName)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, funcName)
  local needLevel = 0
  if record ~= nil then
    needLevel = record:GetIntValue("value")
  end
  return needLevel
end
def.static("=>", "number").GetLuckStoneItemId = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "LUCKY_ITEM_ID")
  if record == nil then
    return -1
  end
  local luckStoneItemId = record:GetIntValue("value")
  return luckStoneItemId
end
def.static("=>", "number").GetZhenLingStoneItemId = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "ZHENLIN_STONE_ITEM_ID")
  if record == nil then
    return -1
  end
  local zhenStoneItemId = record:GetIntValue("value")
  return zhenStoneItemId
end
def.static("=>", "number").GetZhenLingStrenLevel = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "EQUIP_QILIN_USE_ZHENLINGSHI_LEVEL")
  if record == nil then
    return 3
  end
  local zhenStoneItemId = record:GetIntValue("value")
  return zhenStoneItemId or 3
end
def.static("number", "=>", "number", "number").GetXiHunStoneItemId = function(equipLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG, equipLevel)
  if record == nil then
    return -1
  end
  local xiHunItemId = record:GetIntValue("refreshItemId")
  local xiHUnItemNum = record:GetIntValue("refreshItemNum")
  return xiHunItemId, xiHUnItemNum
end
def.static("number", "=>", "number").GetQiLingMaxLevel = function(equipLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG, equipLevel)
  if record == nil then
    warn("GetQiLingMaxLevel  failed~~~~~")
    return -1
  end
  local qilingMax = record:GetIntValue("qilingMaxLevel")
  return qilingMax
end
def.static("number", "=>", "table").GetSuoHunItemIdAndNum = function(equipLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG, equipLevel)
  if record == nil then
    warn("GetSuoHunItemIdAndNum~~~~get record faild~")
    return 0, 0
  end
  local struct = record:GetStructValue("lockHunNeedItemStruct")
  local size = struct:GetVectorSize("lockHunNeedItemVector")
  local cfg = {}
  for i = 1, size do
    local vectorRecord = struct:GetVectorValueByIdx("lockHunNeedItemVector", i - 1)
    local itemId = vectorRecord:GetIntValue("itemId")
    local itemNum = vectorRecord:GetIntValue("itemNum")
    local subcfg = {}
    subcfg.itemId = itemId
    subcfg.itemNum = itemNum
    table.insert(cfg, subcfg)
  end
  return cfg
end
def.static("string", "=>", "dynamic").GetConstant = function(key)
  return constant.EquipItemCfgConsts[key]
end
def.static("=>", "number").GetEquipTransNeedItemId = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "FUHUN_NEED_ITEM_ID")
  local transItemId = DynamicRecord.GetIntValue(record0, "value")
  return transItemId
end
def.static("=>", "number").GetJiGaoMax = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MAX_JIGAO")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetJiGaoMin = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MIN_JIGAO")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetJiaoGaoMax = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MAX_JIAOGAO")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetJiaoGaoMin = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MIN_JIAOGAO")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetYiBanMax = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MAX_YIBAN")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetYiBanMin = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MIN_YIBAN")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetJiaoDiMax = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MAX_JIAODI")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetJiaoDiMin = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MIN_JIAODI")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetJiDiMax = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MAX_JIDI")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetJiDiMin = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MIN_JIDI")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("=>", "number").GetQiLingMinLv = function()
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_CONSTS_CFG, "MIN_LEVEL_FOR_QILIN")
  local val = DynamicRecord.GetIntValue(record0, "value")
  return val
end
def.static("number", "=>", "number", "string").GetItemInfo = function(id)
  local name = ""
  local icon = 0
  local recItemNeed = require("Main.Item.ItemUtils").GetItemBase(id)
  if nil ~= recItemNeed then
    name = recItemNeed.name
    icon = recItemNeed.icon
  end
  return icon, name
end
def.static("number", "=>", "number").GetAttrAById = function(id)
  local attrA = 0
  local equipRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, id)
  if nil ~= equipRecord then
    attrA = equipRecord:GetIntValue("attrA")
  end
  return attrA
end
def.static("number", "=>", "number").GetAttrBById = function(id)
  local attrB = 0
  local equipRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, id)
  if nil ~= equipRecord then
    attrB = equipRecord:GetIntValue("attrB")
  end
  return attrB
end
def.static("table", "=>", "table").FillSelectedEquipMakeInfo = function(equip)
  local makeCfgRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQUIPMAKE_ITEM_CFG, equip.makeCfgId)
  equip.goldNum = makeCfgRecord:GetIntValue("goldNum")
  equip.silverNum = makeCfgRecord:GetIntValue("silverNum")
  equip.vigorNum = makeCfgRecord:GetIntValue("vigorNum")
  equip.makeNeedItem = {}
  local recNeed = makeCfgRecord:GetStructValue("NeedItemStruct")
  local size = recNeed:GetVectorSize("NeedItemVector")
  for i = 0, size - 1 do
    local recNeed2 = recNeed:GetVectorValueByIdx("NeedItemVector", i)
    local kv = {}
    kv.itemId = recNeed2:GetIntValue("itemId")
    kv.itemNum = recNeed2:GetIntValue("itemNum")
    if 0 == kv.itemId then
      break
    end
    local recItemNeed = require("Main.Item.ItemUtils").GetItemBase(kv.itemId)
    if nil == recItemNeed then
      break
    end
    kv.name = recItemNeed.name
    kv.icon = recItemNeed.icon
    table.insert(equip.makeNeedItem, i, kv)
  end
  equip.proRandom = EquipUtils.GetEquipPreviewProRandomTbl(equip.equipInfo.propertydesc)
  equip.proRandomNum = EquipUtils.GetEquipMaxHunNum(equip.eqpId)
  return equip
end
def.static("number", "=>", "table").GetMakeItemTable = function(makeId)
  local equip = {}
  local makeCfgRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQUIPMAKE_ITEM_CFG, makeId)
  if makeCfgRecord == nil then
    return nil
  end
  equip.goldNum = makeCfgRecord:GetIntValue("goldNum")
  equip.silverNum = makeCfgRecord:GetIntValue("silverNum")
  equip.vigorNum = makeCfgRecord:GetIntValue("vigorNum")
  equip.makeNeedItem = {}
  local recNeed = makeCfgRecord:GetStructValue("NeedItemStruct")
  local size = recNeed:GetVectorSize("NeedItemVector")
  for i = 0, size - 1 do
    local recNeed2 = recNeed:GetVectorValueByIdx("NeedItemVector", i)
    local kv = {}
    kv.itemId = recNeed2:GetIntValue("itemId")
    kv.itemNum = recNeed2:GetIntValue("itemNum")
    local recItemNeed = require("Main.Item.ItemUtils").GetItemBase(kv.itemId)
    if nil == recItemNeed then
      break
    end
    kv.name = recItemNeed.name
    kv.icon = recItemNeed.icon
    kv.color = recItemNeed.namecolor
    table.insert(equip.makeNeedItem, kv)
  end
  return equip
end
def.static("number", "=>", "table").GetEquipComponentsCfg = function(equipId)
  local equip = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_ITEMID_2_NEEDITEMS_CFG, equipId)
  if record == nil then
    return nil
  end
  equip.components = {}
  local recNeed = record:GetStructValue("NeedItemStruct")
  local size = recNeed:GetVectorSize("NeedItemVector")
  for i = 0, size - 1 do
    local recNeed2 = recNeed:GetVectorValueByIdx("NeedItemVector", i)
    local kv = {}
    kv.itemId = recNeed2:GetIntValue("itemId")
    kv.itemNum = recNeed2:GetIntValue("itemNum")
    table.insert(equip.components, kv)
  end
  return equip
end
def.static("number", "=>", "number").GetEquipPreviewProRandomNum = function(level)
  local extraHunMaxNum = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local equipmentLevel = DynamicRecord.GetIntValue(entry, "equipmentLevel")
    if equipmentLevel == level then
      extraHunMaxNum = DynamicRecord.GetIntValue(entry, "extraHunMaxNum")
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return extraHunMaxNum
end
def.static("number", "=>", "table").GetEquipPreviewProRandomTbl = function(exattrprobId)
  local proRandom = {}
  local recProRandomCount = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_PRO_RANDOM_COUNT_CFG, exattrprobId)
  if nil ~= recProRandomCount then
    local recProRandomCount2 = recProRandomCount:GetStructValue("ProRandomCountCfgStruct")
    local size1 = recProRandomCount2:GetVectorSize("ProRandomCountCfgVector")
    for i = 0, size1 - 1 do
      local recProRandomCount3 = recProRandomCount2:GetVectorValueByIdx("ProRandomCountCfgVector", i)
      local kv1 = {}
      kv1.proRate = recProRandomCount3:GetIntValue("proRate")
      kv1.proCfgId = recProRandomCount3:GetIntValue("proCfgId")
      if nil ~= kv1.proCfgId then
        local recProRandom = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_PRO_RANDOM_VALUE_CFG, kv1.proCfgId)
        if nil ~= recProRandom then
          local exaProCfgId = recProRandom:GetIntValue("exaProCfgId")
          if nil == proRandom[exaProCfgId] then
            proRandom[exaProCfgId] = {}
            proRandom[exaProCfgId].min = EquipModule.GetProValStr(exaProCfgId, recProRandom:GetIntValue("extraProMin"))
            proRandom[exaProCfgId].max = EquipModule.GetProValStr(exaProCfgId, recProRandom:GetIntValue("extraProMax"))
            proRandom[exaProCfgId].isRecommend = recProRandom:GetCharValue("isRecommend") ~= 0
            proRandom[exaProCfgId].proType = kv1.proCfgId
          end
        end
      end
    end
  end
  return proRandom
end
def.static("number", "=>", "table").GetEquipMakeMaterialInfo = function(itemId)
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_MAKE_MATERIAL_CFG, itemId)
  local tbl
  if record0 ~= nil then
    tbl = {}
    tbl.menpai = record0:GetIntValue("menpai")
    tbl.sex = record0:GetIntValue("sex")
    tbl.materialType = record0:GetIntValue("materialType")
    tbl.materialLevel = record0:GetIntValue("level")
    tbl.materialWearPos = record0:GetIntValue("wearpos")
    tbl.equipmakeshowname = record0:GetStringValue("equipmakeshowname")
  end
  return tbl
end
def.static("number", "=>", "string").GetProColor = function(rate)
  local color = EquipUtils.GetColor(rate)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  if 0 == color then
    return HtmlHelper.NameColor[1]
  else
    return HtmlHelper.NameColor[color]
  end
end
def.static("table", "=>", "number").GetEmptyHumCount = function(exproList)
  if nil == exproList then
    return 0
  end
  local emptyCount = 0
  for k, v in pairs(exproList) do
    if 0 == v.proType or 0 == v.proValue then
      emptyCount = emptyCount + 1
    end
  end
  return emptyCount
end
def.static("number", "table", "table", "=>", "boolean").HasRecommendPurpleOrOrangeHun = function(equipId, equipInfo, exproList)
  if nil == exproList then
    return false
  end
  local curExproList = equipInfo.exproList
  for k, v in pairs(exproList) do
    local pro = EquipModule.GetProTypeID(v.proType)
    local val, realVal, floatValue = EquipModule.GetProRealValue(v.proType, v.proValue)
    local isSpecailHun = EquipUtils.IsPurpleOrOrangeHun(equipId, pro, floatValue, v.proValue)
    local isRecommend = EquipUtils.IsRecommendProType(v.proType, equipId)
    if isSpecailHun and isRecommend then
      local isLockedHun = false
      local curPro = curExproList[k]
      if curPro and 1 == curPro.islock then
        isLockedHun = true
      end
      if not isLockedHun then
        return true
      end
    end
  end
  return false
end
def.static("number", "number", "number", "number", "=>", "boolean").IsPurpleOrOrangeHun = function(itemId, pro, floatVal, proValue)
  local color = EquipUtils.GetHunColor(itemId, pro, floatVal)
  if color <= 0 then
    color = EquipUtils.GetColor(proValue)
  end
  if color >= 4 then
    return true
  else
    return false
  end
end
def.static("number", "number", "number", "number", "=>", "string").GetProColorEx = function(itemId, pro, floatVal, proValue)
  local color = EquipUtils.GetHunColor(itemId, pro, floatVal)
  if color <= 0 then
    warn("Get RealColor failed !!!!!! ")
    color = EquipUtils.GetColor(proValue)
  end
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  if 0 == color then
    return HtmlHelper.NameColor[1]
  else
    return HtmlHelper.NameColor[color]
  end
end
local equipColorCache
def.static("number", "=>", "number").GetColor = function(rate)
  if equipColorCache == nil then
    equipColorCache = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_SOLE_COLOR_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local color = DynamicRecord.GetIntValue(entry, "color")
      local minRate = DynamicRecord.GetIntValue(entry, "minRate")
      local maxRate = DynamicRecord.GetIntValue(entry, "maxRate")
      table.insert(equipColorCache, {
        color = color,
        min = minRate,
        max = maxRate
      })
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  for k, v in ipairs(equipColorCache) do
    if rate >= v.min and rate <= v.max then
      return v.color
    end
  end
  return 1
end
def.static("number", "number", "number", "=>", "number").GetHunColor = function(itemId, propType, value)
  local record = DynamicData.GetRecord(CFG_PATH.EQUIP_HUN_COLOR_CFG, itemId)
  if record == nil then
    print("itemId:", itemId, "is not in EQUIP_HUN_COLOR_CFG")
    return -1
  end
  local entry = record:GetStructValue("hunColorStruct")
  local size = entry:GetVectorSize("hunColorVector")
  for i = 0, size - 1 do
    local rec = entry:GetVectorValueByIdx("hunColorVector", i)
    local property = rec:GetIntValue("property")
    if property == propType then
      local min = rec:GetIntValue("min")
      local max = rec:GetIntValue("max")
      local calcValue = value > min and value - min or 0
      local rate = min >= max and 10000 or calcValue / (max - min) * 10000
      return EquipUtils.GetColor(rate)
    end
  end
  print("propType:", propType, "is not in", itemId, "'s EQUIP_HUN_COLOR_CFG")
  return -1
end
def.static("number", "=>", "number").GetSellSilver = function(itemId)
  local record = require("Main.Item.ItemUtils").GetItemBase(itemId)
  local sellSilver = record.sellSilver
  return sellSilver
end
def.static("number", "number", "=>", "number").GetSuccessRate = function(itemId, strenLv)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_STREN_ITEM_CFG, itemId)
  local rate = 0
  if record then
    local recNeed = record:GetStructValue("rateStruct")
    local size = recNeed:GetVectorSize("rateList")
    strenLv = strenLv + 1
    for i = size - 1, 0, -1 do
      local recNeed2 = recNeed:GetVectorValueByIdx("rateList", i)
      local strengthLevel = recNeed2:GetIntValue("strengthLevel")
      if strenLv >= strengthLevel then
        rate = recNeed2:GetIntValue("sucRate")
        break
      end
    end
  end
  return rate
end
def.static("number", "table", "table", "number", "=>", "table", "string", "string", "string", "string", "string").FillEquipMakeSuccessInfo = function(eqpId, exproList, extraMap, wearPos)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local attriA = EquipUtils.GetAttrAById(eqpId)
  local attriB = EquipUtils.GetAttrBById(eqpId)
  local tbl = {attriA, attriB}
  local tblT = {
    ItemXStoreType.ATTRI_A,
    ItemXStoreType.ATTRI_B
  }
  local strenNameContent = ""
  local strenValContent = ""
  local transNameContent = ""
  local transValContent = ""
  local randomContent = ""
  local comparekey, itemCompare = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, wearPos)
  for k, v in pairs(tbl) do
    local str = EquipModule.GetAttriName(v)
    local val = EquipModule.GetAttriValue(eqpId, tblT[k], extraMap[tblT[k]])
    strenNameContent = strenNameContent .. str .. ":\n"
    strenValContent = strenValContent .. val
    if -1 ~= comparekey and nil ~= itemCompare then
      local srcAttri = EquipModule.GetAttriValue(itemCompare.id, tblT[k], itemCompare.extraMap[tblT[k]])
      local dAttri = val - srcAttri
      if dAttri > 0 then
        strenValContent = strenValContent .. textRes.Item[8013] .. "\n"
      elseif 0 == dAttri then
        strenValContent = strenValContent .. textRes.Item[8015] .. "\n"
      elseif dAttri < 0 then
        strenValContent = strenValContent .. textRes.Item[8014] .. "\n"
      else
        strenValContent = strenValContent .. "\n"
      end
    end
  end
  if strenNameContent ~= "" then
    strenNameContent = string.sub(strenNameContent, 1, string.len(strenNameContent) - 1)
  end
  if strenValContent ~= "" then
    strenValContent = string.sub(strenValContent, 1, string.len(strenValContent) - 1)
  end
  for k, v in pairs(exproList) do
    local str = EquipModule.GetProRandomName(v.proType)
    local val, realVal = EquipModule.GetProRealValue(v.proType, v.proValue)
    transNameContent = transNameContent .. str .. ":\n"
    transValContent = transValContent .. val .. "\n"
  end
  if transNameContent ~= "" then
    transNameContent = string.sub(transNameContent, 1, string.len(transNameContent) - 1)
  end
  if transValContent ~= "" then
    transValContent = string.sub(transValContent, 1, string.len(transValContent) - 1)
  end
  local equip = {}
  local itemRecord = require("Main.Item.ItemUtils").GetItemBase(eqpId)
  if nil ~= itemRecord then
    equip.typeName = itemRecord.itemTypeName
    equip.name = itemRecord.name
    equip.iconId = itemRecord.icon
    equip.useLevel = itemRecord.useLevel
  end
  return equip, strenNameContent, strenValContent, transNameContent, transValContent, randomContent
end
def.static("table", "=>", "string", "string", "string", "string", "string").GetEquipMakePreviewContent = function(equip)
  local strenNameContent = ""
  local strenValContent = ""
  local transNameContent = ""
  local transValContent = ""
  local randomContent = ""
  local strAttrA = EquipModule.GetAttriName(equip.equipInfo.attrA)
  strenNameContent = strenNameContent .. strAttrA .. ":\n"
  local attrARange = "+" .. equip.equipInfo.attrAvaluemin .. "~" .. equip.equipInfo.attrAvaluemax
  strenValContent = strenValContent .. attrARange .. "\n"
  local strAttrB = EquipModule.GetAttriName(equip.equipInfo.attrB)
  strenNameContent = strenNameContent .. strAttrB .. ":"
  local attrBRange = "+" .. equip.equipInfo.attrBvaluemin .. "~" .. equip.equipInfo.attrBvaluemax
  strenValContent = strenValContent .. attrBRange
  local tmpTbl = {}
  for k, v in pairs(equip.proRandom) do
    local tmp = v
    tmp.k = k
    table.insert(tmpTbl, tmp)
  end
  table.sort(tmpTbl, function(a, b)
    local recordA = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, a.k)
    local sortIdA = DynamicRecord.GetIntValue(recordA, "sort")
    local recordB = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, b.k)
    local sortIdB = DynamicRecord.GetIntValue(recordB, "sort")
    return sortIdA < sortIdB
  end)
  for k, v in pairs(tmpTbl) do
    local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, v.k)
    local sortId = DynamicRecord.GetIntValue(record, "sort")
    if nil ~= record then
      local propName = DynamicRecord.GetStringValue(record, "propName")
      transNameContent = transNameContent .. propName .. ":\n"
      transValContent = transValContent .. "+" .. v.min .. "~" .. v.max .. "\n"
    end
  end
  if transNameContent ~= "" then
    transNameContent = string.sub(transNameContent, 1, string.len(transNameContent) - 1)
  end
  if transValContent ~= "" then
    transValContent = string.sub(transValContent, 1, string.len(transValContent) - 1)
  end
  randomContent = tostring(equip.proRandomNum)
  return strenNameContent, strenValContent, transNameContent, transValContent, randomContent
end
def.static("table", "=>", "string", "string").GetStrenPreContentByEquip = function(equip)
  local strenNameContent = ""
  local strenValContent = ""
  if 0 ~= equip.equipInfo.attrA then
    local strAttrA = EquipModule.GetAttriName(equip.equipInfo.attrA)
    strenNameContent = strenNameContent .. strAttrA .. ":\n"
    local attrARange = "+" .. equip.equipInfo.attrAvaluemin .. "~" .. equip.equipInfo.attrAvaluemax
    strenValContent = strenValContent .. attrARange .. "\n"
  end
  if 0 ~= equip.equipInfo.attrB then
    local strAttrB = EquipModule.GetAttriName(equip.equipInfo.attrB)
    strenNameContent = strenNameContent .. strAttrB .. ":"
    local attrBRange = "+" .. equip.equipInfo.attrBvaluemin .. "~" .. equip.equipInfo.attrBvaluemax
    strenValContent = strenValContent .. attrBRange
  end
  return strenNameContent, strenValContent
end
local hunCfgCache = {}
def.static("table", "=>", "table").GetTransNameAndValueCfg = function(equip)
  if hunCfgCache[equip.eqpId] ~= nil then
    return hunCfgCache[equip.eqpId]
  end
  local tmpTbl = {}
  for k, v in pairs(equip.proRandom) do
    local tmp = v
    tmp.k = k
    table.insert(tmpTbl, tmp)
  end
  table.sort(tmpTbl, function(a, b)
    local recordA = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, a.k)
    local sortIdA = DynamicRecord.GetIntValue(recordA, "sort")
    local recordB = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, b.k)
    local sortIdB = DynamicRecord.GetIntValue(recordB, "sort")
    return sortIdA < sortIdB
  end)
  local hunCfg = {}
  for k, v in pairs(tmpTbl) do
    local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, v.k)
    if record ~= nil then
      local hunTb = {}
      local hunName = record:GetStringValue("propName")
      local hunValue = "+" .. v.min .. "~" .. v.max
      local hunIsRecommend = v.isRecommend
      hunTb.hunName = hunName
      hunTb.hunValue = hunValue
      hunTb.IsRecommend = hunIsRecommend
      if hunTb.IsRecommend then
        hunTb.IsRecommend = EquipUtils.IsRecommendProType(v.proType, equip.eqpId)
      end
      table.insert(hunCfg, hunTb)
    end
  end
  hunCfgCache[equip.eqpId] = hunCfg
  return hunCfg
end
local EquipBasicInfoCache = {}
def.static("number", "=>", "table").GetEquipBasicInfo = function(eqpId)
  local cache = EquipBasicInfoCache[eqpId]
  if cache then
    return cache
  end
  local equipRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, eqpId)
  if equipRecord == nil then
    warn("CEquipCfg got nil record for id: ", eqpId)
    return nil
  end
  local equip = {}
  equip.menpai = equipRecord:GetIntValue("menpai")
  equip.sex = equipRecord:GetIntValue("sex")
  equip.equipmodel = equipRecord:GetIntValue("equipmodel")
  equip.equipspecileffect = equipRecord:GetIntValue("equipspecileffect")
  equip.wearpos = equipRecord:GetIntValue("wearpos")
  equip.attrA = equipRecord:GetIntValue("attrA")
  equip.attrAvaluemin = equipRecord:GetIntValue("attrAvaluemin")
  equip.attrAvaluemax = equipRecord:GetIntValue("attrAvaluemax")
  equip.attrB = equipRecord:GetIntValue("attrB")
  equip.attrBvaluemin = equipRecord:GetIntValue("attrBvaluemin")
  equip.attrBvaluemax = equipRecord:GetIntValue("attrBvaluemax")
  equip.exattrprobId = equipRecord:GetIntValue("exattrprobId")
  equip.weaponType = equipRecord:GetIntValue("weaponType")
  equip.lightEffectId = equipRecord:GetIntValue("lightEffectId")
  local itemRecord = require("Main.Item.ItemUtils").GetItemBase(eqpId)
  local level = itemRecord.useLevel
  local key = string.format("%d_%d_%d", level, equip.wearpos, equip.menpai)
  local exaRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_EXA_RANDOM_VALUE_CFG, key)
  if exaRecord ~= nil then
    equip.attrAvaluemin = exaRecord:GetIntValue("attrAvaluemin")
    equip.attrAvaluemax = exaRecord:GetIntValue("attrAvaluemax")
    equip.attrBvaluemin = exaRecord:GetIntValue("attrBvaluemin")
    equip.attrBvaluemax = exaRecord:GetIntValue("attrBvaluemax")
    equip.propertydesc = exaRecord:GetIntValue("propertydesc")
  end
  EquipBasicInfoCache[eqpId] = equip
  return equip
end
def.static("number", "=>", "table").GetEquipDetailsInfo = function(eqpId)
  local equip = {}
  equip.eqpId = eqpId
  equip.equipInfo = EquipUtils.GetEquipBasicInfo(eqpId)
  local itemRecord = require("Main.Item.ItemUtils").GetItemBase(eqpId)
  equip.equipInfo.useLevel = itemRecord.useLevel
  equip.equipInfo.name = itemRecord.name
  equip.equipInfo.iconId = itemRecord.icon
  equip.equipInfo.typeName = itemRecord.itemTypeName
  equip.proRandomNum = EquipUtils.GetEquipMaxHunNum(eqpId)
  equip.proRandom = EquipUtils.GetEquipPreviewProRandomTbl(equip.equipInfo.propertydesc)
  return equip
end
def.static("number", "=>", "number").GetEquipMaxHunNum = function(equipId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, equipId)
  if record == nil then
    return 0
  end
  local maxhunNum = record:GetIntValue("extraHunMaxNum")
  return maxhunNum
end
def.static("number", "number", "number", "number", "number").ShowEquipDetailsDlg = function(eqpId, x, y, width, height)
  local equip = EquipUtils.GetEquipDetailsInfo(eqpId)
  local title = textRes.Equip[28]
  local strenNameContent, strenValContent = EquipUtils.GetStrenPreContentByEquip(equip)
  local transHunCfg = EquipUtils.GetTransNameAndValueCfg(equip)
  local hunMaxNum = EquipUtils.GetEquipMaxHunNum(equip.eqpId)
  local position = {}
  position.sourceX = x
  position.sourceY = y
  position.sourceW = width
  position.sourceH = height
  position.auto = true
  EquipInfoShowDlg.ShowEquipInfo(title, eqpId, equip.equipInfo, nil, strenNameContent, strenValContent, position, tostring(hunMaxNum), 0, transHunCfg)
end
def.static("table", "table", "boolean", "=>", "string", "string", "string", "string", "string", "number").GetEquipInheritPreviewContent = function(equipInheritConsume, equipInheritSelected, bIsSaveConsume)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local consumeEquipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(equipInheritConsume.bagId, equipInheritConsume.key)
  local consumeStrenLevel = 0
  if nil ~= consumeEquipItem then
    consumeStrenLevel = consumeEquipItem.extraMap[ItemXStoreType.STRENGTH_LEVEL]
    if nil == consumeStrenLevel then
      consumeStrenLevel = 0
    end
  end
  local strenIncrement = consumeStrenLevel
  if equipInheritSelected.useLevel == equipInheritConsume.useLevel then
    strenIncrement = consumeStrenLevel - 1
  end
  local str1Id = EquipUtils.GetAttrAById(equipInheritSelected.id)
  local str2Id = EquipUtils.GetAttrBById(equipInheritSelected.id)
  local str1 = EquipModule.GetAttriName(str1Id)
  local str2 = EquipModule.GetAttriName(str2Id)
  local strenNameContent = ""
  local strenValContent = ""
  local transNameContent = ""
  local transValContent = ""
  local randomContent = ""
  strenNameContent = strenNameContent .. str1 .. ":\n"
  strenNameContent = strenNameContent .. str2 .. ":"
  local mainEquipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(equipInheritSelected.bagId, equipInheritSelected.key)
  local valAttriA = EquipModule.GetAttriValue(mainEquipItem.id, ItemXStoreType.ATTRI_A, mainEquipItem.extraMap[ItemXStoreType.ATTRI_A])
  strenValContent = strenValContent .. valAttriA .. "\n"
  local valAttriB = EquipModule.GetAttriValue(mainEquipItem.id, ItemXStoreType.ATTRI_B, mainEquipItem.extraMap[ItemXStoreType.ATTRI_B])
  strenValContent = strenValContent .. valAttriB
  if bIsSaveConsume then
    local count = 0
    local consumeExproCount = #consumeEquipItem.exproList
    if consumeExproCount > 0 then
      for i = 1, #consumeEquipItem.exproList do
        if nil ~= mainEquipItem.exproList[i] then
          local str = EquipModule.GetProRandomName(consumeEquipItem.exproList[i].proType)
          local val, realVal = EquipModule.GetProRealValue(consumeEquipItem.exproList[i].proType, consumeEquipItem.exproList[i].proValue)
          transNameContent = transNameContent .. str .. ":\n"
          transValContent = transValContent .. val .. "\n"
        else
          break
        end
        count = i
      end
    end
    local j = count + 1
    if 0 == consumeExproCount then
      j = count
    end
    for i = j, #mainEquipItem.exproList do
      if nil ~= mainEquipItem.exproList[i] then
        local str = EquipModule.GetProRandomName(mainEquipItem.exproList[i].proType)
        local val, realVal = EquipModule.GetProRealValue(mainEquipItem.exproList[i].proType, mainEquipItem.exproList[i].proValue)
        transNameContent = transNameContent .. str .. ":\n"
        transValContent = transValContent .. val .. "\n"
      else
        break
      end
    end
  else
    local tbl = {}
    local consumeExproCount = #consumeEquipItem.exproList
    if consumeExproCount > 0 then
      for i = 1, consumeExproCount do
        local str = EquipModule.GetProRandomName(consumeEquipItem.exproList[i].proType)
        local val, realVal = EquipModule.GetProRealValue(consumeEquipItem.exproList[i].proType, consumeEquipItem.exproList[i].proValue)
        table.insert(tbl, {name = str, value = val})
      end
    end
    local mainExproCount = #mainEquipItem.exproList
    if mainExproCount > 0 then
      for i = 1, #mainEquipItem.exproList do
        local str = EquipModule.GetProRandomName(mainEquipItem.exproList[j].proType)
        local val, realVal = EquipModule.GetProRealValue(mainEquipItem.exproList[i].proType, mainEquipItem.exproList[i].proValue)
        table.insert(tbl, {name = str, value = val})
      end
    end
    local allSoleNum = #tbl
    randomContent = textRes.Equip[2] .. mainExproCount .. textRes.Equip[3] .. "\n"
    for i = 1, #tbl do
      transNameContent = transNameContent .. tbl[i].name .. ":\n"
      transValContent = transValContent .. tbl[i].value .. "\n"
    end
  end
  if transNameContent ~= "" then
    transNameContent = string.sub(transNameContent, 1, string.len(transNameContent) - 1)
  end
  if transValContent ~= "" then
    transValContent = string.sub(transValContent, 1, string.len(transValContent) - 1)
  end
  return strenNameContent, strenValContent, transNameContent, transValContent, randomContent, strenIncrement
end
def.static("number", "number", "=>", "number").GetEquipStrenLevel = function(bagId, key)
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, key)
  local strenLevel = 0
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  if nil ~= equipItem then
    strenLevel = equipItem.extraMap[ItemXStoreType.STRENGTH_LEVEL]
    if nil == strenLevel then
      strenLevel = 0
    end
  end
  return strenLevel
end
def.static("number", "number", "number", "=>", "number").GetStrenScore2Rate = function(qilinTypeid, strenLevel, score)
  local key = qilinTypeid .. "_" .. strenLevel
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_STREN_CFG, key)
  if nil == record then
    return 0
  end
  local score2rate = record:GetIntValue("score2rate") or 0
  return score2rate * score
end
def.static("number", "number", "=>", "number", "number").GetEquipStrenIncrease = function(qilinTypeid, strenLevel)
  local strengthAttrA = 0
  local strengthAttrB = 0
  local eqpStrenLev = strenLevel
  local key = qilinTypeid .. "_" .. eqpStrenLev
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_STREN_CFG, key)
  if nil ~= record0 then
    strengthAttrA = record0:GetIntValue("strengthAttrA")
    strengthAttrB = record0:GetIntValue("strengthAttrB")
  end
  return strengthAttrA, strengthAttrB
end
def.static("number", "number", "number", "number", "=>", "table").GetEquipStrenPreviewInfo = function(qilinTypeid, strenLevel, attri1, attri2)
  local strengthAttrA = 0
  local strengthAttrB = 0
  local strengthNextAttrA = 0
  local strengthNextAttrB = 0
  local eqpStrenLev = strenLevel
  local eqpNextStrenLev = strenLevel + 1
  local key = qilinTypeid .. "_" .. eqpStrenLev
  local nextKey = qilinTypeid .. "_" .. eqpNextStrenLev
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_STREN_CFG, key)
  if nil ~= record0 then
    strengthAttrA = record0:GetIntValue("strengthAttrA")
    strengthAttrB = record0:GetIntValue("strengthAttrB")
  end
  local record1 = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_STREN_CFG, nextKey)
  if nil ~= record1 then
    strengthNextAttrA = record1:GetIntValue("strengthAttrA")
    strengthNextAttrB = record1:GetIntValue("strengthAttrB")
  end
  local strAttri1 = attri1
  local strAttri2 = attri2
  if 0 ~= strenLevel then
    strAttri1 = strAttri1 .. "+" .. strengthAttrA
    strAttri2 = strAttri2 .. "+" .. strengthAttrB
  end
  local strNextAttri1 = attri1 .. "+" .. strengthNextAttrA
  local strNextAttri2 = attri2 .. "+" .. strengthNextAttrB
  local strDValue1 = strengthNextAttrA - strengthAttrA
  local strDValue2 = strengthNextAttrB - strengthAttrB
  local tbl = {}
  table.insert(tbl, {
    attri1 = strAttri1,
    attri2 = strAttri2,
    nextAttri1 = strNextAttri1,
    nextAttri2 = strNextAttri2,
    dValue1 = strDValue1,
    dValue2 = strDValue2
  })
  return tbl
end
def.static("number", "number", "=>", "number", "number", "number", "number", "boolean").GetEquipStrenNeedItemInfoAfterSuccess = function(qilinTypeid, strenLevel)
  local strengthItemNum = 0
  local strengthMoney = 0
  local zhenLinStonNum = 0
  local eqpStrenLev = strenLevel
  local sucRate = 0
  local canUseLockStone = false
  local key = qilinTypeid .. "_" .. eqpStrenLev
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_STREN_CFG, key)
  if nil ~= record then
    strengthItemNum = record:GetIntValue("strengthItemNum")
    strengthMoney = record:GetIntValue("strengthSilverNum")
    zhenLinStonNum = record:GetIntValue("zhenLinStonNum")
    sucRate = record:GetIntValue("sucRate")
    canUseLockStone = record:GetCharValue("canUseLuckStone") ~= 0
  end
  return strengthItemNum, zhenLinStonNum, strengthMoney, sucRate, canUseLockStone
end
def.static("number", "number", "=>", "table").GetStrenInfoCfg = function(strenType, strenLevel)
  local strenInfoCfg = {}
  local key = strenType .. "_" .. strenLevel
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_STREN_CFG, key)
  if record == nil then
    return strenInfoCfg
  end
  local strenNeedSilverNum = record:GetIntValue("strengthSilverNum")
  local strenNeedItemNum = record:GetIntValue("strengthItemNum")
  strenInfoCfg.needSilverNum = strenNeedSilverNum
  strenInfoCfg.needItemNum = strenNeedItemNum
  return strenInfoCfg
end
def.static("number", "=>", "number", "number").GetEquipTransNeedItemInfo = function(level)
  local transItemNum = 0
  local transNeedSilver = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local equipmentLevel = DynamicRecord.GetIntValue(entry, "equipmentLevel")
    if equipmentLevel == level then
      transItemNum = DynamicRecord.GetIntValue(entry, "transferHunNeedItemNum")
      transNeedSilver = DynamicRecord.GetIntValue(entry, "transferHunNeedSilver")
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return transItemNum, transNeedSilver
end
def.static("number", "=>", "number").GetEquipInheritNeedItemInfo = function(level)
  local inheritNeedSilver = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local equipmentLevel = DynamicRecord.GetIntValue(entry, "equipmentLevel")
    if equipmentLevel == level then
      inheritNeedSilver = DynamicRecord.GetIntValue(entry, "inheritNeedSilver")
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return inheritNeedSilver
end
def.static("number", "number", "=>", "number", "number").GetLockSoleCost = function(lv, index)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG, lv)
  local cost = 0
  local moneyType = 0
  if record then
    local recNeed = record:GetStructValue("moneytypeStruct")
    local recNeed2 = recNeed:GetVectorValueByIdx("moneytypeVector", index)
    if recNeed2 then
      cost = recNeed2:GetIntValue("needNum")
      moneyType = recNeed2:GetIntValue("moneyType")
    end
  end
  return cost, moneyType
end
def.static().ShowInheritInfoDlg = function()
  local desc = textRes.Equip[39]
  local tmpPosition = {x = 0, y = 0}
  CommonDescDlg.ShowCommonTip(desc, tmpPosition)
end
def.static().ShowTransInfoDlg = function()
  local desc = textRes.Equip[40]
  local tmpPosition = {x = 0, y = 0}
  CommonDescDlg.ShowCommonTip(desc, tmpPosition)
end
def.static("number", "number", "=>", "boolean").GetIsEquipCanMake = function(makeCfgId, equipMakeItemNum)
  local makeCfgRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQUIPMAKE_ITEM_CFG, makeCfgId)
  local makeNeedItem = {}
  local recNeed = makeCfgRecord:GetStructValue("NeedItemStruct")
  local size = recNeed:GetVectorSize("NeedItemVector")
  for i = 0, size - 1 do
    local recNeed2 = recNeed:GetVectorValueByIdx("NeedItemVector", i)
    local kv = {}
    kv.itemId = recNeed2:GetIntValue("itemId")
    kv.itemNum = recNeed2:GetIntValue("itemNum")
    table.insert(makeNeedItem, i, kv)
  end
  local bIsEnough = true
  for i = 0, equipMakeItemNum - 1 do
    local itemInfo = makeNeedItem[i]
    if nil == itemInfo then
      break
    end
    local have = ItemModule.Instance():GetItemCountById(itemInfo.itemId)
    if have < itemInfo.itemNum then
      bIsEnough = false
    end
  end
  return bIsEnough
end
def.static("table", "table", "table", "=>", "number").GetEquipTotalScore = function(item, itemBase, equipBase)
  local score = 0
  score = score + EquipUtils.CalcEpuipBaseAttrScore(item, itemBase, equipBase)
  score = score + EquipUtils.GetQiLingScore(item)
  score = score + EquipUtils.CalcGodWeaponBreakOutScore(item, equipBase)
  score = score + EquipUtils.CalcEpuipXihunScore(item)
  score = score + EquipUtils.CalcEpuipSkillScore(item)
  score = score + EquipUtils.CalcGodWeaponJewelScore(item)
  return score
end
def.static("table", "table", "table", "=>", "number").CalcEpuipBaseAttrScore = function(item, itemBase, equipBase)
  local score = 0
  if item == nil then
    return score
  end
  if nil == equipBase then
    equipBase = ItemUtils.GetEquipBase(item.id)
  end
  if nil == itemBase then
    itemBase = ItemUtils.GetItemBase(item.id)
  end
  if nil == equipBase or nil == itemBase then
    return score
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local equipModule = require("Main.Equip.EquipModule")
  local attriAValue = equipModule.GetAttriValue(itemBase.itemid, ItemXStoreType.ATTRI_A, item.extraMap[ItemXStoreType.ATTRI_A])
  local attriBValue = equipModule.GetAttriValue(itemBase.itemid, ItemXStoreType.ATTRI_B, item.extraMap[ItemXStoreType.ATTRI_B])
  local MathHelper = require("Common.MathHelper")
  local curBlessLevel = item.extraMap[ItemXStoreType.EQUIPMENT_BLESS_LEVEL]
  local attrBless = 0
  if curBlessLevel then
    local EquipUtils = require("Main.Equip.EquipUtils")
    local curBlessCfg = EquipUtils.GetEquipBlessCfgByLevelAndPos(equipBase.wearpos, curBlessLevel)
    if curBlessCfg then
      attrBless = curBlessCfg.propertyBuff
    end
  end
  attriAValue = attriAValue + MathHelper.Round(attriAValue * attrBless)
  attriBValue = attriBValue + MathHelper.Round(attriBValue * attrBless)
  local score = attriAValue * EquipUtils.GetPropertyFactor(equipBase.attrA) + attriBValue * EquipUtils.GetPropertyFactor(equipBase.attrB)
  return score
end
def.static("table", "=>", "number").GetQiLingScore = function(item)
  if nil == item then
    return 0
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local equipModule = require("Main.Equip.EquipModule")
  local qilinLevel = item.extraMap[ItemXStoreType.STRENGTH_LEVEL]
  if nil == qilinLevel then
    return 0
  end
  local equipBase = ItemUtils.GetEquipBase(item.id)
  local itemBase = ItemUtils.GetItemBase(item.id)
  if nil == equipBase or nil == itemBase then
    return 0
  end
  local strenAValue, strenBValue = EquipUtils.GetEquipStrenIncrease(equipBase.qilinTypeid, qilinLevel)
  local factorA = EquipUtils.GetPropertyFactor(equipBase.attrA)
  local factorB = EquipUtils.GetPropertyFactor(equipBase.attrB)
  if nil == factorA or nil == factorB then
    return 0
  end
  local score = strenAValue * factorA + strenBValue * factorB
  return score
end
def.static("table", "table", "=>", "number").CalcGodWeaponBreakOutScore = function(item, equipBase)
  local score = 0
  if item == nil then
    return score
  end
  if nil == equipBase then
    equipBase = ItemUtils.GetEquipBase(item.id)
  end
  if nil == equipBase then
    return score
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local equipModule = require("Main.Equip.EquipModule")
  local BreakOutUtils = require("Main.GodWeapon.BreakOut.BreakOutUtils")
  local attriAValue = BreakOutUtils.GetGodWeaponAttr(item, equipBase.attrA, equipBase)
  local attriBValue = BreakOutUtils.GetGodWeaponAttr(item, equipBase.attrB, equipBase)
  local score = attriAValue * EquipUtils.GetPropertyFactor(equipBase.attrA) + attriBValue * EquipUtils.GetPropertyFactor(equipBase.attrB)
  return score
end
def.static("table", "=>", "number").CalcEpuipXihunScore = function(item)
  local score = 0
  if item and item.exproList and 0 < #item.exproList then
    local exproCount = #item.exproList
    for i = 1, exproCount do
      if 0 ~= item.exproList[i].proType and 0 ~= item.exproList[i].proValue then
        local exproValue, realVal = EquipModule.GetProRealValue(item.exproList[i].proType, item.exproList[i].proValue)
        local enumType = EquipModule.GetProTypeID(item.exproList[i].proType)
        score = score + exproValue * EquipUtils.GetPropertyFactor(enumType)
      end
    end
  end
  return score
end
def.static("table", "=>", "number").CalcEpuipSkillScore = function(item)
  local score = 0
  local equipSkillId = item and item.extraMap[ItemXStoreType.EQUIP_SKILL] or nil
  if equipSkillId then
    local SkillUtility = require("Main.Skill.SkillUtility")
    score = SkillUtility.GetRoleSpecialSkillScore(equipSkillId)
  end
  return score
end
def.static("table", "=>", "number").CalcGodWeaponJewelScore = function(item)
  local score = 0
  local jewelMap = item and item.jewelMap or nil
  if jewelMap ~= nil then
    local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
    local arrJewels = {}
    for slot, jewelInfo in pairs(jewelMap) do
      local jewelItemId = jewelInfo.jewelCfgId
      local jewelBasic = JewelUtils.GetJewelItemByItemId(jewelItemId, false)
      local itemBase = ItemUtils.GetItemBase(jewelItemId)
      local prop = jewelBasic.arrProps[1]
      score = score + prop.propVal * EquipUtils.GetPropertyFactor(prop.propType)
    end
  end
  return score
end
def.static("number", "=>", "number").GetPropertyFactor = function(ptype)
  local occupation = require("Main.Hero.Interface").GetHeroProp().occupation
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_PROPERTY_SCORE)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local occupationId = record:GetIntValue("occupationType")
    local propertyType = record:GetIntValue("propertyType")
    if occupation == occupationId and ptype == propertyType then
      local factor = record:GetFloatValue("factor")
      return factor or 0
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0
end
def.static("table", "table", "table", "=>", "number").CalcEpuipScore = function(item, itemBase, equipBase)
  local EquipModule = require("Main.Equip.EquipModule")
  local score = 0
  if item == nil or itemBase == nil then
    return score
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local equipModule = require("Main.Equip.EquipModule")
  local strenLevel = item.extraMap[ItemXStoreType.STRENGTH_LEVEL]
  local strenAValue, strenBValue = EquipUtils.GetEquipStrenIncrease(equipBase.qilinTypeid, strenLevel)
  local attriAValue = equipModule.GetAttriValue(itemBase.itemid, ItemXStoreType.ATTRI_A, item.extraMap[ItemXStoreType.ATTRI_A])
  local attriBValue = equipModule.GetAttriValue(itemBase.itemid, ItemXStoreType.ATTRI_B, item.extraMap[ItemXStoreType.ATTRI_B])
  score = score + (strenAValue + attriAValue) * EquipUtils.GetPropertyFactor(equipBase.attrA) + (strenBValue + attriBValue) * EquipUtils.GetPropertyFactor(equipBase.attrB)
  local exproCount = #item.exproList
  if exproCount > 0 then
    for i = 1, exproCount do
      if 0 ~= item.exproList[i].proType and 0 ~= item.exproList[i].proValue then
        local exproValue, realVal = equipModule.GetProRealValue(item.exproList[i].proType, item.exproList[i].proValue)
        local enumType = EquipModule.GetProTypeID(item.exproList[i].proType)
        score = score + exproValue * EquipUtils.GetPropertyFactor(enumType)
      end
    end
  end
  local equipSkillId = item.extraMap[ItemXStoreType.EQUIP_SKILL]
  if equipSkillId then
    local SkillUtility = require("Main.Skill.SkillUtility")
    local skillScore = SkillUtility.GetRoleSpecialSkillScore(equipSkillId)
    score = score + skillScore
  end
  return score
end
def.static("table", "table", "=>", "number").CalcEpuipScoreUtilEx = function(item, extraProps)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local equipModule = require("Main.Equip.EquipModule")
  local itemBase = ItemUtils.GetItemBase(item.id)
  local equipBase = ItemUtils.GetEquipBase(item.id)
  local score = 0
  local strenLevel = item.extraMap[ItemXStoreType.STRENGTH_LEVEL]
  local strenAValue, strenBValue = EquipUtils.GetEquipStrenIncrease(equipBase.qilinTypeid, strenLevel)
  local attriAValue = equipModule.GetAttriValue(itemBase.itemid, ItemXStoreType.ATTRI_A, item.extraMap[ItemXStoreType.ATTRI_A])
  local attriBValue = equipModule.GetAttriValue(itemBase.itemid, ItemXStoreType.ATTRI_B, item.extraMap[ItemXStoreType.ATTRI_B])
  score = score + (strenAValue + attriAValue) * EquipUtils.GetPropertyFactor(equipBase.attrA) + (strenBValue + attriBValue) * EquipUtils.GetPropertyFactor(equipBase.attrB)
  local exproCount = #item.exproList
  if exproCount > 0 then
    for i = 1, exproCount do
      if extraProps[i] ~= nil then
        if 0 ~= extraProps[i].proType and 0 ~= extraProps[i].proValue then
          local exproValue, realVal = equipModule.GetProRealValue(extraProps[i].proType, extraProps[i].proValue)
          local enumType = EquipModule.GetProTypeID(extraProps[i].proType)
          score = score + exproValue * EquipUtils.GetPropertyFactor(enumType)
        end
      elseif 0 ~= item.exproList[i].proType and 0 ~= item.exproList[i].proValue then
        local exproValue, realVal = equipModule.GetProRealValue(item.exproList[i].proType, item.exproList[i].proValue)
        local enumType = EquipModule.GetProTypeID(item.exproList[i].proType)
        score = score + exproValue * EquipUtils.GetPropertyFactor(enumType)
      end
    end
  end
  local equipSkillId = item.extraMap[ItemXStoreType.EQUIP_SKILL]
  if equipSkillId then
    local SkillUtility = require("Main.Skill.SkillUtility")
    local skillScore = SkillUtility.GetRoleSpecialSkillScore(equipSkillId)
    score = score + skillScore
  end
  return score
end
def.static("table", "=>", "number").CalcEpuipScoreUtil = function(item)
  if item == nil then
    return 0
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local equipModule = require("Main.Equip.EquipModule")
  local itemBase = ItemUtils.GetItemBase(item.id)
  local equipBase = ItemUtils.GetEquipBase(item.id)
  return EquipUtils.CalcEpuipScore(item, itemBase, equipBase)
end
def.static("string", "userdata").FillNumIcon = function(iconId, uiSprite)
  local atlas = RESPATH.FUNCTION1_ATLAS
  GameUtil.AsyncLoad(atlas, function(obj)
    local atlas = obj:GetComponent("UIAtlas")
    uiSprite:set_atlas(atlas)
    uiSprite:set_spriteName(iconId)
  end)
end
local equipDynamicColorAnalysis
def.static("table", "table", "table", "=>", "number").GetEquipDynamicColor = function(equip, equipBase, itemBase)
  if itemBase == nil then
    itemBase = ItemUtils.GetItemBase(equip.id)
  end
  if itemBase then
    return itemBase.namecolor
  else
    return 1
  end
  if equipDynamicColorAnalysis == nil then
    equipDynamicColorAnalysis = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_EXA_RANDOM_VALUE_CFG)
    if entries == nil then
      warn("Table Read Failed:", CFG_PATH.DATA_EQUIP_EXA_RANDOM_VALUE_CFG)
      return
    end
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local lv = entry:GetIntValue("equipLevel")
      local type = entry:GetIntValue("equipType")
      local menpai = entry:GetIntValue("equipMenpai")
      local lv1 = entry:GetIntValue("lv1")
      local lv2 = entry:GetIntValue("lv2")
      local lv3 = entry:GetIntValue("lv3")
      local lv4 = entry:GetIntValue("lv4")
      local key = string.format("%d_%d_%d", menpai, type, lv)
      local value = {
        0,
        lv1,
        lv2,
        lv3,
        lv4
      }
      equipDynamicColorAnalysis[key] = value
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  if equip == nil then
    if itemBase ~= nil then
      return itemBase.namecolor
    else
      return 1
    end
  end
  if itemBase == nil then
    itemBase = ItemUtils.GetItemBase(equip.id)
  end
  if itemBase.itemType ~= ItemType.EQUIP then
    return itemBase.namecolor
  end
  local equipLv = itemBase.useLevel
  if equipBase == nil then
    equipBase = ItemUtils.GetEquipBase(equip.id)
  end
  local equipPos = equipBase.wearpos
  local equipMenpai = equipBase.menpai
  local key = string.format("%d_%d_%d", equipMenpai, equipPos, equipLv)
  local value = equipDynamicColorAnalysis[key]
  local score = EquipUtils.CalcEpuipScore(equip, itemBase, equipBase)
  if value ~= nil then
    for i = 5, 1, -1 do
      if score >= value[i] then
        return i
      end
    end
    return 1
  else
    return 1
  end
end
local WeaponColorCfg
def.static().CacheAllWeaponColor = function()
  if WeaponColorCfg then
    return
  end
  WeaponColorCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WEAPON_COLOR_CFG)
  local size = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record then
      local cfg = {}
      cfg.level = record:GetIntValue("level")
      cfg.weaponId = record:GetIntValue("weaponId")
      local r = record:GetIntValue("r1")
      local g = record:GetIntValue("g1")
      local b = record:GetIntValue("b1")
      local a = record:GetIntValue("a1")
      cfg.color1 = Color32RGBA(r, g, b, a)
      r = record:GetIntValue("r2")
      g = record:GetIntValue("g2")
      b = record:GetIntValue("b2")
      a = record:GetIntValue("a2")
      cfg.color2 = Color32RGBA(r, g, b, a)
      local k = bit.lshift(cfg.weaponId, 8) + cfg.level
      WeaponColorCfg[k] = cfg
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static("number", "number", "=>", "table").GetWeaponColor = function(weaponId, level)
  if WeaponColorCfg == nil then
    EquipUtils.CacheAllWeaponColor()
  end
  local k = bit.lshift(weaponId, 8) + level
  return WeaponColorCfg[k]
end
def.static("table", "=>", "number").GetSuoHunNum = function(exproList)
  local suoNum = 0
  if exproList == nil then
    return suoNum
  end
  for k, v in pairs(exproList) do
    if v.islock == 1 then
      suoNum = suoNum + 1
    end
  end
  return suoNum
end
def.static("=>", "number").GetLuckStonePrice = function()
  local mallType = require("consts.mzm.gsp.mall.confbean.MallType")
  local mallUitls = require("Main.Mall.MallUtility")
  local itemId = EquipUtils.GetLuckStoneItemId()
  local key = string.format("%d_%d", itemId, mallType.FUNCTION_MALL)
  return mallUitls.GetItemPrice(key)
end
def.static("=>", "boolean").hasEquipCanStren = function()
  local eqpBagId = require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG
  local equipBagInfo = ItemModule.Instance():GetItemsByBagId(eqpBagId)
  local strenItemId = EquipUtils.GetEquipStrenNeedItemId()
  local haveItemNum = ItemModule.Instance():GetItemCountById(strenItemId)
  local haveSilverNum = Int64.ToNumber(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER))
  local strenMinLv = EquipUtils.GetQiLingMinLv()
  local curQilinMode = EquipModule.Instance().curQiLinMode
  for key, bagInfo in pairs(equipBagInfo) do
    local itemId = bagInfo.id
    local itemBase = ItemUtils.GetItemBase(itemId)
    if itemBase ~= nil and itemBase.itemType == ItemType.EQUIP then
      local itemUseLevel = itemBase.useLevel
      local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
      local strenType = equipBase.qilinTypeid
      if strenMinLv <= itemUseLevel then
        local curStrenLevel = EquipUtils.GetEquipStrenLevel(eqpBagId, key)
        local maxStrenLevel = EquipUtils.GetQiLingMaxLevel(itemUseLevel)
        if curStrenLevel < maxStrenLevel then
          if curQilinMode == QiLinMode.ACCUMULATION_MODE then
            local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(curStrenLevel + 1)
            if qilingCfg then
              for i, v in pairs(qilingCfg.qilingItems) do
                local useNum = EquipUtils.GetAccumulateQiLinItemUseNum(eqpBagId, key, v.itemId)
                if useNum < v.itemNum then
                  local haveItemNum = ItemModule.Instance():GetItemCountById(v.itemId)
                  if haveItemNum > 0 then
                    return true
                  end
                end
              end
            end
          else
            local needItemNum = EquipUtils.GetStrenInfoCfg(strenType, curStrenLevel + 1).needItemNum
            local needSilverNum = EquipUtils.GetStrenInfoCfg(strenType, curStrenLevel + 1).needSilverNum
            if haveItemNum >= needItemNum and haveSilverNum >= needSilverNum then
              return true
            end
          end
        end
      end
    end
  end
  return false
end
def.static("table", "=>", "boolean").canStren = function(equipInfo)
  if equipInfo == nil then
    return false
  end
  local strenMinLv = EquipUtils.GetQiLingMinLv()
  local strenItemId = EquipUtils.GetEquipStrenNeedItemId()
  local haveItemNum = ItemModule.Instance():GetItemCountById(strenItemId)
  local haveSilverNum = Int64.ToNumber(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER))
  local useLevel = equipInfo.useLevel
  local bagId = equipInfo.bagId
  local bagKey = equipInfo.key
  local strenType = equipInfo.qilinTypeid
  if useLevel == nil or bagId == nil or bagKey == nil or strenType == nil then
    return false
  end
  local eqpBagId = require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG
  if bagId ~= eqpBagId then
    return false
  end
  if strenMinLv > useLevel then
    return false
  end
  local curStrenLevel = EquipUtils.GetEquipStrenLevel(bagId, bagKey)
  local maxStrenLevel = EquipUtils.GetQiLingMaxLevel(useLevel)
  if curStrenLevel >= maxStrenLevel then
    return false
  end
  if EquipModule.Instance().curQiLinMode == QiLinMode.ACCUMULATION_MODE then
    local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(curStrenLevel + 1)
    if qilingCfg then
      for i, v in pairs(qilingCfg.qilingItems) do
        local useNum = EquipUtils.GetAccumulateQiLinItemUseNum(bagId, bagKey, v.itemId)
        if useNum < v.itemNum then
          local haveItemNum = ItemModule.Instance():GetItemCountById(v.itemId)
          if haveItemNum > 0 then
            return true
          end
        end
      end
    end
    return false
  end
  local needInfo = EquipUtils.GetStrenInfoCfg(strenType, curStrenLevel + 1)
  local needItemNum = needInfo.needItemNum
  local needSilverNum = needInfo.needSilverNum
  if haveItemNum < needItemNum or haveSilverNum < needSilverNum then
    return false
  end
  return true
end
def.static("number", "=>", "table").GetHunNumList = function(equipId)
  local refItemBase = ItemUtils.GetItemBase(equipId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, equipId)
  local useLevel = refItemBase.useLevel
  local menpai = record:GetIntValue("menpai")
  local wearpos = record:GetIntValue("wearpos")
  local heroSex = record:GetIntValue("sex")
  local hunNumList = {
    0,
    0,
    0,
    0,
    0
  }
  local similarRecord = DynamicData.GetRecord(CFG_PATH.DATA_SIMILAR_EQUIP, string.format("%d_%d_%d_%d", useLevel, menpai, heroSex, wearpos))
  if similarRecord then
    local equipStruct = similarRecord:GetStructValue("equipStruct")
    local size = equipStruct:GetVectorSize("equips")
    for i = 0, size - 1 do
      local equip = equipStruct:GetVectorValueByIdx("equips", i)
      local equipId = equip:GetIntValue("equipId")
      warn("GetHunNumList", equipId)
      local hunNum = EquipUtils.GetEquipHunNum(equipId)
      if hunNum > 0 then
        local itemBase = ItemUtils.GetItemBase(equipId)
        local namecolor = itemBase and itemBase.namecolor or 1
        if hunNumList[namecolor] and hunNum > hunNumList[namecolor] then
          hunNumList[namecolor] = hunNum
        end
      end
    end
  end
  return hunNumList
end
def.static("number", "=>", "number").GetEquipHunNum = function(equipId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, equipId)
  if record == nil then
    return 0
  end
  local hunRateStruct = record:GetStructValue("hunRateStruct")
  local size = hunRateStruct:GetVectorSize("hunRateVector")
  local hunMaxNum = 0
  for i = 0, size - 1 do
    local hunRateVector = hunRateStruct:GetVectorValueByIdx("hunRateVector", i)
    local hunRate = hunRateVector:GetIntValue("hunRate")
    if hunRate > 0 then
      hunMaxNum = i
    end
  end
  return hunMaxNum
end
def.static("number", "number", "=>", "boolean").IsRecommendProType = function(proType, equipId)
  local proRandomRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_PRO_RANDOM_VALUE_CFG, proType)
  if proRandomRecord == nil then
    return false
  end
  local isRecommend = proRandomRecord:GetCharValue("isRecommend") ~= 0
  if false == isRecommend then
    return false
  end
  isRecommend = false
  local heroOccupation = require("Main.Hero.Interface").GetHeroProp().occupation
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, equipId)
  if record == nil then
    return false
  end
  local MenPaiEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local occupationStruct = proRandomRecord:GetStructValue("occupationStruct")
  local size = occupationStruct:GetVectorSize("occupationVector")
  for i = 0, size - 1 do
    local recommendOccupationVector = occupationStruct:GetVectorValueByIdx("occupationVector", i)
    if recommendOccupationVector then
      local recommendOccupation = recommendOccupationVector:GetIntValue("occupation")
      if recommendOccupation == MenPaiEnum.ALL or recommendOccupation == heroOccupation then
        isRecommend = true
        break
      end
    end
  end
  return isRecommend
end
def.static("number", "number", "=>", "boolean").HasLockedHun = function(equipBagId, equipKey)
  local equip = ItemModule.Instance():GetItemByBagIdAndItemKey(equipBagId, equipKey)
  if not equip then
    return false
  end
  local exproList = equip.exproList
  if exproList and #exproList > 0 then
    for k, v in pairs(exproList) do
      if 1 == v.islock then
        return true
      end
    end
  end
  return false
end
def.static("=>", "table").GetAllEquipSkillCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_SKILL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = EquipUtils._GetEquipSkillCfg(entry)
    cfgs[i + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("userdata", "=>", "table")._GetEquipSkillCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.wearpos = record:GetIntValue("wearpos")
  cfg.level = record:GetIntValue("level")
  cfg.skills = {}
  local skillsStruct = record:GetStructValue("skillsStruct")
  local size = skillsStruct:GetVectorSize("skillsVector")
  for i = 0, size - 1 do
    local rowRecord = skillsStruct:GetVectorValueByIdx("skillsVector", i)
    cfg.skills[i + 1] = rowRecord:GetIntValue("id")
  end
  return cfg
end
def.static("=>", "table").GetAllQilingList = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ALLQILING_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local level = entry:GetIntValue("linlevel")
    table.insert(cfgs, level)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs)
  return cfgs
end
def.static("number", "=>", "table", "string").GetAllQilingCfgByLevel = function(level)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ALLQILING_CFG, level)
  if record == nil then
    warn("GetAllQilingCfgByLevel nil:", level)
    return nil
  end
  local desc = record:GetStringValue("desc")
  local cfg = {}
  local struct = record:GetStructValue("propStruct")
  local size = struct:GetVectorSize("propList")
  for i = 0, size - 1 do
    local rec = struct:GetVectorValueByIdx("propList", i)
    local propType = rec:GetIntValue("propType")
    local propParam = rec:GetIntValue("param")
    if propType > 0 then
      table.insert(cfg, {prop = propType, value = propParam})
    end
  end
  return cfg, desc
end
def.static("number", "=>", "number").GetMostQiLingLevelByLevel = function(roleLevel)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local mostLevel = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local equipLevel = entry:GetIntValue("equipmentLevel")
    if roleLevel > equipLevel then
      local qilingLevel = entry:GetIntValue("qilingMaxLevel")
      if mostLevel < qilingLevel then
        mostLevel = qilingLevel
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return mostLevel
end
def.static("number", "number", "number").ShowAllQiLingTip = function(allQilingLv, x, y)
  local equipments = ItemModule.Instance():GetHeroEquipments()
  EquipUtils.ShowAllQiLingTipEx(equipments, allQilingLv, x, y)
end
def.static("table", "number", "number", "number").ShowAllQiLingTipEx = function(equipments, allQilingLv, x, y)
  local title = string.format(textRes.Equip[120], allQilingLv)
  local lowestEquipLevel = math.huge
  local reachCount = 0
  for i = 0, 5 do
    local equip = equipments[i]
    local qilingLv = -1
    if equip then
      local strenLevel = equip.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
      qilingLv = strenLevel
      local itemBase = ItemUtils.GetItemBase(equip.id)
      if lowestEquipLevel > itemBase.useLevel then
        lowestEquipLevel = itemBase.useLevel
      end
    else
      lowestEquipLevel = 0
    end
    if allQilingLv <= qilingLv then
      reachCount = reachCount + 1
    end
  end
  local desc1 = ""
  if reachCount >= 6 then
    desc1 = textRes.Equip[121]
  else
    desc1 = string.format(textRes.Equip[122], reachCount)
  end
  local desc2 = string.format(textRes.Equip[123], allQilingLv)
  local desc3 = ""
  local allQlCfg, extradesc = EquipUtils.GetAllQilingCfgByLevel(allQilingLv)
  if allQlCfg then
    local strTbl = {}
    if extradesc and extradesc ~= "" then
      table.insert(strTbl, extradesc)
    end
    local ProValueType = require("consts.mzm.gsp.common.confbean.ProValueType")
    for k, v in ipairs(allQlCfg) do
      local propType = v.prop
      local propValue = v.value
      local propCfg = GetCommonPropNameCfg(propType)
      local propName = propCfg.propName
      local propValueType = propCfg.valueType
      local str = ""
      if propValueType == ProValueType.TEN_THOUSAND_RATE then
        str = string.format(textRes.Equip[125], propName, propValue / 10000 * 100, lowestEquipLevel)
      else
        str = string.format(textRes.Equip[124], propName, propValue, lowestEquipLevel)
      end
      table.insert(strTbl, str)
    end
    desc3 = table.concat(strTbl, "\n")
  else
    return
  end
  require("Main.Item.ui.TextTips").ShowTextTip(title, desc1, desc2, desc3, x, y)
end
def.static("=>", "boolean", "boolean", "number", "number").GetAllQiLinInfo = function()
  local allEquip = ItemModule.Instance():GetHeroEquipments()
  return EquipUtils.GetAllQiLinInfoEx(allEquip)
end
def.static("table", "=>", "boolean", "boolean", "number", "number").GetAllQiLinInfoEx = function(allEquip)
  local ItemModule = require("Main.Item.ItemModule")
  local equipCount = 0
  local minStrenLevel = 50
  for i = 0, 5 do
    local equipInfo = allEquip[i]
    if equipInfo then
      equipCount = equipCount + 1
      local strenLevel = equipInfo.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
      if minStrenLevel > strenLevel then
        minStrenLevel = strenLevel
      end
    end
  end
  local minLevel, maxLevel = EquipUtils.GetAllQiLinMaxAndMinLevel()
  if equipCount < 6 then
    return true, false, minLevel, 0
  elseif minStrenLevel >= maxLevel then
    return false, true, 0, maxLevel
  elseif minStrenLevel < minLevel then
    return true, false, minLevel, 0
  else
    local curLevel, nextLevel = EquipUtils.GetCurAndNextAllQiLinLevel(minStrenLevel)
    return false, false, curLevel, nextLevel
  end
end
def.static("=>", "number", "number").GetAllQiLinMaxAndMinLevel = function()
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_ALLQILING_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local minStrenLevel = 50
  local maxStrenLevel = 0
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local level = record:GetIntValue("linlevel")
    if minStrenLevel > level then
      minStrenLevel = level
    end
    if maxStrenLevel < level then
      maxStrenLevel = level
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return minStrenLevel, maxStrenLevel
end
def.static("number", "=>", "number", "number").GetCurAndNextAllQiLinLevel = function(strenLevel)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_ALLQILING_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local curStrenLevel = 0
  local nextStrenLevel = 0
  local strenLevelTb = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local level = record:GetIntValue("linlevel")
    table.insert(strenLevelTb, level)
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  table.sort(strenLevelTb, function(a, b)
    return a < b
  end)
  for i = 1, #strenLevelTb do
    if strenLevel >= strenLevelTb[i] then
      curStrenLevel = strenLevelTb[i]
    else
      nextStrenLevel = strenLevelTb[i]
      break
    end
  end
  return curStrenLevel, nextStrenLevel
end
def.static("table", "=>", "number").CalcQiLingEffectLevel = function(equipments)
  if equipments == nil then
    return -1
  end
  local effectLevel = -1
  for i = 0, 5 do
    local equip = equipments[i]
    if equip then
      local strenLevel = equip.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
      if effectLevel == -1 then
        effectLevel = strenLevel
      else
        effectLevel = math.min(effectLevel, strenLevel)
      end
    else
      effectLevel = -1
      break
    end
  end
  return effectLevel
end
def.static("number", "=>", "table").GetQiLinAccumulateModeCfg = function(strenLv)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_QILING_ACCUMULATE_MODE_CFG, strenLv)
  if record == nil then
    warn("!!!!!GetQiLinAccumulateModeCfg nil:", strenLv)
    return nil
  end
  local cfg = {}
  cfg.strengthLevel = record:GetIntValue("strengthLevel")
  cfg.initScore = record:GetIntValue("initScore")
  cfg.needScore = record:GetIntValue("needScore")
  cfg.qilingItems = {}
  local struct = record:GetStructValue("qilinItemsStruct")
  local size = struct:GetVectorSize("qilingItems")
  for i = 0, size - 1 do
    local rec = struct:GetVectorValueByIdx("qilingItems", i)
    local itemId = rec:GetIntValue("itemid")
    local itemNum = rec:GetIntValue("itemnum")
    if itemId > 0 and itemNum > 0 then
      local t = {}
      t.itemId = itemId
      t.itemNum = itemNum
      t.itemAddScore = rec:GetIntValue("itemAddScore")
      table.insert(cfg.qilingItems, t)
    end
  end
  return cfg
end
def.static("number", "number", "=>", "number").GetAccumulateQilinEquipScore = function(bagId, key)
  local strenLevel = EquipUtils.GetEquipStrenLevel(bagId, key)
  local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(strenLevel + 1)
  if qilingCfg == nil then
    return
  end
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, key)
  local curScore = equipItem.extraMap[ItemXStoreType.ACCUMULATION_QILIN_SCORE] or 0
  if equipItem.extraMap[ItemXStoreType.CAN_ADD_INIT_QILIN_SCORE] == nil then
    curScore = curScore + qilingCfg.initScore
  end
  for i, v in pairs(qilingCfg.qilingItems) do
    local useNum = EquipUtils.GetAccumulateQiLinItemUseNum(bagId, key, v.itemId)
    curScore = curScore + v.itemAddScore * useNum
  end
  return curScore
end
def.static("number", "number", "number", "=>", "number").GetAccumulateQiLinItemUseNum = function(bagId, key, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local useNum = 0
  if itemBase then
    local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, key)
    if itemBase.itemType == ItemType.EQUIP_QILIN then
      useNum = equipItem.extraMap[ItemXStoreType.QILINZHU_USE_COUNT] or 0
    elseif itemBase.itemType == ItemType.EQUIP_QILIN_SUC then
      useNum = equipItem.extraMap[ItemXStoreType.ZHENGLINSHI_USE_COUNT] or 0
    elseif itemBase.itemType == ItemType.EQUIP_QILIN_LUCKY then
      useNum = equipItem.extraMap[ItemXStoreType.XINGYUNSHI_USE_COUNT] or 0
    end
  end
  return useNum
end
def.static("number", "=>", "table").GetEquipSkillRefreshCfg = function(level)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_SKILL_REFRESH, level)
  if record == nil then
    warn("!!!!!GetEquipSkillRefreshCfg nil:", level)
    return nil
  end
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.needMainItemId = record:GetIntValue("needMainItemId")
  cfg.needViceItemId = record:GetIntValue("needViceItemId")
  cfg.needItemNum = record:GetIntValue("needItemNum")
  cfg.moneyType = record:GetIntValue("moneyType")
  cfg.needMoneyNum = record:GetIntValue("needMoneyNum")
  return cfg
end
def.static("number", "number", "=>", "table").GetEquipBlessCfgByLevelAndPos = function(pos, level)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_BLESS_CFG, level)
  if record == nil then
    warn("GetEquipBlessCfgByLevelAndPos nil, level:", level)
    return nil
  end
  local struct = record:GetStructValue("conditionStruct")
  local size = struct:GetVectorSize("conditiontList")
  if pos >= size then
    warn("GetEquipBlessCfgByLevelAndPos nil, wearpos:", pos)
    return nil
  end
  local rec = struct:GetVectorValueByIdx("conditiontList", pos)
  local cfg = {}
  cfg.propertyBuff = rec:GetIntValue("propertyBuff") / 10000
  cfg.requiredSuperEquipmentStage = rec:GetIntValue("requiredSuperEquipmentStage")
  cfg.requiredExp = rec:GetIntValue("requiredExp")
  return cfg
end
def.static("number", "number", "=>", "boolean").IsEquipBlessMaxLevel = function(pos, level)
  if level >= constant.CEquipmentBlessConsts.MAX_BLESS_LEVEL then
    return true
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_BLESS_CFG, level + 1)
  if record == nil then
    return true
  end
  return false
end
def.static("number", "=>", "table").GetEquipBlessItemsByWearpos = function(pos)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_BLESS_EXP_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local items = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local blessItemId = record:GetIntValue("blessItemId")
    local struct = record:GetStructValue("wearposStruct")
    local size = struct:GetVectorSize("wearposList")
    for j = 0, size - 1 do
      local rec = struct:GetVectorValueByIdx("wearposList", j)
      local wearpos = rec:GetIntValue("wearpos")
      if wearpos == pos then
        table.insert(items, blessItemId)
        break
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  table.sort(items, function(a, b)
    return a < b
  end)
  return items
end
EquipUtils.Commit()
return EquipUtils
