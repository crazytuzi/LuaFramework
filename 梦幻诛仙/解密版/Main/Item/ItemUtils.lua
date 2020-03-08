local Lplus = require("Lplus")
local ItemUtils = Lplus.Class("ItemUtils")
local def = ItemUtils.define
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local AllMoneyType = require("consts.mzm.gsp.item.confbean.AllMoneyType")
local MathHelper = require("Common.MathHelper")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local BreakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData")
def.static("number", "userdata").FillIcon = function(iconId, uiSprite)
  local atlas = ItemUtils.GetAtlasName(iconId)
  GameUtil.AsyncLoad("Arts/Resources/Atlas/" .. atlas, function(obj)
    local atlas = obj:GetComponent("UIAtlas")
    uiSprite:set_atlas(atlas)
    local spriteName = ItemUtils.GetSpriteName(iconId)
    uiSprite:set_spriteName(spriteName)
  end)
end
def.static("number", "=>", "string").GetAtlasName = function(iconId)
  local atlasId = math.ceil(iconId / 256)
  local atlasName = "IconAtlas" .. atlasId .. ".prefab.u3dext"
  return atlasName
end
def.static("number", "=>", "string").GetSpriteName = function(iconId)
  return iconId .. ".pic"
end
local _itemBaseData, _itemType2idsMap
def.static().CacheItemBaseData = function()
  if _itemBaseData then
    return
  end
  _itemBaseData = {}
  _itemType2idsMap = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ITEMCFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local record = entry
    local itemid = record:GetIntValue("itemid")
    local itemType = record:GetIntValue("type")
    _itemType2idsMap[itemType] = _itemType2idsMap[itemType] or {}
    table.insert(_itemType2idsMap[itemType], itemid)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
local _get_item_cfg = function(itemid)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEMCFG, itemid)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.itemid = itemid
  cfg.itemType = record:GetIntValue("type")
  cfg.itemTypeName = record:GetStringValue("itemTypeName")
  cfg.name = record:GetStringValue("name")
  cfg.namecolor = record:GetIntValue("namecolor")
  cfg.desc = record:GetStringValue("desc")
  cfg.carrymax = record:GetIntValue("carrymax")
  cfg.pilemax = record:GetIntValue("pilemax")
  cfg.useLevel = record:GetIntValue("useLevel")
  cfg.sellSilver = record:GetIntValue("sellSilver")
  cfg.isProprietary = record:GetCharValue("isProprietary") ~= 0
  cfg.canSellAndThrow = record:GetCharValue("canSellAndThrow") ~= 0
  cfg.awardRoleLevelMin = record:GetIntValue("awardRoleLevelMin")
  cfg.awardRoleLevelMax = record:GetIntValue("awardRoleLevelMax")
  cfg.icon = record:GetIntValue("icon")
  cfg.sellType = record:GetIntValue("sellType")
  cfg.sort = record:GetIntValue("sort")
  return cfg
end
def.static("number", "boolean", "=>", "table")._GetItemBase = function(id, is_warn)
  if _itemBaseData == nil then
    ItemUtils.CacheItemBaseData()
  end
  if _itemBaseData[id] then
    return _itemBaseData[id]
  else
    local cfg = _get_item_cfg(id)
    if cfg then
      _itemBaseData[id] = cfg
      return cfg
    end
    if is_warn then
      warn("Get Item Base By Id " .. id .. " fail!!!")
    end
    return nil
  end
end
def.static("number", "=>", "table").GetItemBase = function(id)
  return ItemUtils._GetItemBase(id, true)
end
def.static("number", "=>", "table").GetItemBase2 = function(id)
  return ItemUtils._GetItemBase(id, false)
end
def.static("number", "=>", "table").GetItemTypeRefIdList = function(itemType)
  return _itemType2idsMap[itemType]
end
def.static("number", "=>", "table").GetNotProprietaryItemIdsByType = function(itemType)
  local idList = ItemUtils.GetItemTypeRefIdList(itemType)
  local itemIdList = {}
  for i, id in ipairs(idList) do
    local itemBase = ItemUtils.GetItemBase(id)
    if not itemBase.isProprietary then
      table.insert(itemIdList, id)
    end
  end
  return itemIdList
end
def.static("number", "=>", "table").GetItemTypeCfg = function(itemType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEMTYPECFG, itemType)
  if record == nil then
    print("record == nil (", itemType, ")")
    return nil
  end
  local cfg = {}
  cfg.itemType = record:GetIntValue("itemType")
  cfg.useInFight = record:GetCharValue("useInFight") ~= 0
  cfg.itemTypeName = record:GetStringValue("itemTypeName")
  cfg.canGive = record:GetCharValue("canGive") ~= 0
  return cfg
end
def.static("number", "=>", "number").GetMoneyIcon = function(moneyType)
  local SSyncMoneyChange = require("netio.protocol.mzm.gsp.role.SSyncMoneyChange")
  if moneyType == SSyncMoneyChange.MONEY_TYPE_GOLD then
    return 7007
  elseif moneyType == SSyncMoneyChange.MONEY_TYPE_SILVER then
    return 7008
  elseif moneyType == SSyncMoneyChange.MONEY_TYPE_GOLD_INGOT then
    return 641
  else
    return 7006
  end
end
def.static("number", "=>", "table").GetEquipBase = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.menpai = record:GetIntValue("menpai")
  cfg.sex = record:GetIntValue("sex")
  cfg.equipmodel = record:GetIntValue("equipmodel")
  cfg.equipspecileffect = record:GetIntValue("equipspecileffect")
  cfg.wearpos = record:GetIntValue("wearpos")
  cfg.attrA = record:GetIntValue("attrA")
  cfg.attrAvaluemin = record:GetIntValue("attrAvaluemin")
  cfg.attrAvaluemax = record:GetIntValue("attrAvaluemax")
  cfg.attrB = record:GetIntValue("attrB")
  cfg.attrBvaluemin = record:GetIntValue("attrBvaluemin")
  cfg.attrBvaluemax = record:GetIntValue("attrBvaluemax")
  cfg.exattrprobId = record:GetIntValue("exattrprobId")
  cfg.qilinTypeid = record:GetIntValue("qilinTypeid")
  local itemBase = ItemUtils.GetItemBase(id)
  cfg.itemBase = itemBase
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local useLevel = itemBase.useLevel
  cfg.usePoint = 0
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local equipmentLevel = DynamicRecord.GetIntValue(entry, "equipmentLevel")
    if equipmentLevel == useLevel then
      cfg.usePoint = DynamicRecord.GetIntValue(entry, "usePoint")
      break
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetFabaoFragmentItem = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAOFRAGMENT_ITEM, id)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.rankExp = record:GetIntValue("rankExp")
  cfg.fabaoType = record:GetIntValue("fabaoType")
  return cfg
end
def.static("number", "=>", "table").GetFabaoExpItem = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_EXP_ITEM, id)
  if not record then
    warn("DATA_FABAO_ITEM_CFG(" .. id .. ") return nil")
    return {}
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.exp = record:GetIntValue("exp")
  cfg.isShowUpDlg = record:GetCharValue("isShowUpDlg") ~= 0
  return cfg
end
def.static("number", "=>", "table").GetLongJingItem = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LONGJING_ITEM, id)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.attrId = record:GetIntValue("attrId")
  cfg.attrValue = record:GetIntValue("attrValue")
  cfg.lv = record:GetIntValue("lv")
  cfg.nextId = record:GetIntValue("nextId")
  cfg.longjingType = record:GetIntValue("longjingType")
  cfg.complexNextCount = record:GetIntValue("complexNextCount")
  cfg.attrIds = {}
  cfg.attrValues = {}
  local attrStruct = record:GetStructValue("attrStruct")
  local attrVectorSize = DynamicRecord.GetVectorSize(attrStruct, "attrIdVector")
  for i = 0, attrVectorSize - 1 do
    local attrIdRecord = DynamicRecord.GetVectorValueByIdx(attrStruct, "attrIdVector", i)
    local attrValueRecord = DynamicRecord.GetVectorValueByIdx(attrStruct, "attrValueVector", i)
    local attrId = attrIdRecord:GetIntValue("attrId")
    local attrValue = 0
    if attrValueRecord then
      attrValue = attrValueRecord:GetIntValue("attrValue")
    end
    table.insert(cfg.attrIds, attrId)
    table.insert(cfg.attrValues, attrValue)
  end
  return cfg
end
def.static("number", "=>", "table").GetFabaoItem = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_ITEM, id)
  if not record then
    warn("GetFabaoItem empty", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.classId = record:GetIntValue("classId")
  cfg.fabaoType = record:GetIntValue("fabaoType")
  cfg.canCompose = record:GetCharValue("canCompose") ~= 0
  cfg.rank = record:GetIntValue("rank")
  cfg.attrId = record:GetIntValue("attrId")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.fragmentId = record:GetIntValue("fragmentId")
  cfg.fragmentCount = record:GetIntValue("fragmentCount")
  cfg.normalAction = record:GetStringValue("normalAction")
  cfg.waitAction = record:GetStringValue("waitAction")
  cfg.specialAction = record:GetStringValue("specialAction")
  cfg.magicEffectId = record:GetIntValue("magicEffectId")
  cfg.tuoweiEffectId = record:GetIntValue("tuoweiEffectId")
  cfg.boneEffectId = record:GetIntValue("boneEffectId")
  cfg.aircraftId = record:GetIntValue("aircraftId")
  cfg.rankId = record:GetIntValue("rankId")
  cfg.modelColorId = record:GetIntValue("modelColorId")
  cfg.canUseYuanBao = record:GetCharValue("canUseYuanBao") ~= 0
  cfg.proInstruction = record:GetStringValue("proInstruction")
  return cfg
end
def.static("number", "=>", "table").GetFeijianItem = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FEIJIAN_ITEM_CFG, id)
  if not record then
    warn("Feijian Item is nil, id = ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.aircraftId = record:GetIntValue("aircraftid")
  return cfg
end
local low_level_cache = -1
def.static("=>", "number").GetLowestFeijianLv = function()
  if low_level_cache >= 0 then
    return low_level_cache
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FEIJIAN_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local ret = math.huge
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = entry:GetIntValue("id")
    local itemBase = ItemUtils.GetItemBase(id)
    if ret > itemBase.useLevel then
      ret = itemBase.useLevel
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  low_level_cache = ret
  return ret
end
def.static("number", "=>", "table").GetWingItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WING_ITEM_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.attrA = record:GetIntValue("attrA")
  cfg.attrAMin = record:GetIntValue("attrAMin")
  cfg.attrAMax = record:GetIntValue("attrAMax")
  cfg.attrB = record:GetIntValue("attrB")
  cfg.attrBMin = record:GetIntValue("attrBMin")
  cfg.attrBMax = record:GetIntValue("attrBMax")
  cfg.effectId = record:GetIntValue("effectId")
  cfg.dieEffectId = record:GetIntValue("dieEffectId")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.skillId = record:GetIntValue("skillId")
  return cfg
end
def.static("number", "=>", "table").GetZhenFaShuItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FORMATIONBOOK_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.formationId = record:GetIntValue("formationId")
  return cfg
end
def.static("number", "=>", "table").GetPetBagCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_BAG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.petId = record:GetIntValue("petId")
  return cfg
end
def.static("number", "=>", "table").GetStorageCfg = function(storageId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_STORAGE_CFG, storageId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.moneyType = record:GetIntValue("moneytype")
  cfg.num = record:GetIntValue("num")
  return cfg
end
def.static("=>", "table").GetAllStorageId = function(storageId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_STORAGE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = entry:GetIntValue("id")
    table.insert(list, id)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "=>", "table").GetFlowerItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FLOWER_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.addIntimacyNum = record:GetIntValue("addIntimacyNum")
  cfg.rankPoint = record:GetIntValue("rankPoint")
  cfg.effectid = record:GetIntValue("effectid")
  cfg.isbulletin = record:GetCharValue("isbulletin") ~= 0
  cfg.isservereffect = record:GetCharValue("isservereffect") ~= 0
  return cfg
end
def.static("number", "=>", "table").GetXiuLianExpCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_XIULIAN_EXP_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.addExpNum = record:GetIntValue("addExpNum")
  return cfg
end
def.static("number", "=>", "table").GetItemFilterCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SAME_PRICE_ITEM_SIFT_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.icon = record:GetIntValue("icon")
  cfg.level = record:GetIntValue("level")
  cfg.name = record:GetStringValue("name")
  cfg.desc = record:GetStringValue("desc")
  cfg.type = record:GetStringValue("type")
  cfg.effect = record:GetStringValue("effect")
  cfg.siftCfgs = {}
  local rec2 = record:GetStructValue("idTypeValueBeansStruct")
  local size = rec2:GetVectorSize("idTypeValueBeans")
  for i = 0, size - 1 do
    local rec3 = rec2:GetVectorValueByIdx("idTypeValueBeans", i)
    local siftCfg = {}
    siftCfg.idtype = rec3:GetIntValue("idtype")
    siftCfg.idvalue = rec3:GetIntValue("idvalue")
    if 0 < siftCfg.idvalue then
      table.insert(cfg.siftCfgs, siftCfg)
    end
  end
  return cfg
end
def.static("table", "=>", "boolean").IsItemBind = function(item)
  return MathHelper.BitAnd(item.flag, ItemInfo.BIND) ~= 0
end
def.static("number", "=>", "table").GetItemCompounCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEM_COMPOUND_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.itemId = record:GetIntValue("itemId")
  cfg.makeCfgId = record:GetIntValue("makeCfgId")
  cfg.showname = record:GetStringValue("showname")
  cfg.canCompoundAll = record:GetCharValue("canCompoundAll") == 1
  return cfg
end
def.static("number", "=>", "table").GetMoneyCfg = function(type)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MONEY_CFG, type)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.icon = record:GetStringValue("tipIconId")
  cfg.iconTex = record:GetIntValue("icon")
  cfg.name = record:GetStringValue("name")
  cfg.desitemid = record:GetIntValue("desitemid")
  return cfg
end
def.static("number", "=>", "table").GetTokenCfg = function(type)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TOKEN_TYPE, type)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.icon = record:GetStringValue("tipIconId")
  cfg.iconTex = record:GetIntValue("icon")
  cfg.name = record:GetStringValue("name")
  cfg.showItemId = record:GetIntValue("showItemId")
  return cfg
end
def.static("number", "=>", "table").GetExpCfg = function(type)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXP_CFG, type)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.iconTex = record:GetIntValue("icon")
  cfg.name = record:GetStringValue("name")
  cfg.desitemid = record:GetIntValue("desitemid")
  return cfg
end
def.static("number", "=>", "table").GetGiftBasicCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GIFT_BAG_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.maxUseLevel = record:GetIntValue("maxUseLevel")
  cfg.giftbagtype = record:GetIntValue("giftbagtype")
  cfg.moneyType = record:GetIntValue("moneyType")
  cfg.moneyNum = record:GetIntValue("moneyNum")
  cfg.endDate = record:GetIntValue("endDate")
  cfg.awardId = record:GetIntValue("awardId")
  return cfg
end
def.static("number", "=>", "table").GetAwardItems = function(awardId)
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(awardId)
  if awardCfg then
    local itemList = ItemUtils.GetAwardItemsFromAwardCfg(awardCfg)
    return itemList
  else
    return nil
  end
end
def.static("number", "=>", "table").GetGiftAwardCfgByAwardId = function(awardId)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return nil
  end
  local mySchool = heroProp.occupation
  local myGender = heroProp.gender
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local awardOcupSexKey = string.format("%d_%d_%d", awardId, mySchool, myGender)
  local awardAllAllKey = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
  local awardOcpAllKey = string.format("%d_%d_%d", awardId, mySchool, gender.ALL)
  local awardAllSexKey = string.format("%d_%d_%d", awardId, occupation.ALL, myGender)
  local awardCfg = ItemUtils.GetGiftAwardCfg(awardOcupSexKey)
  if awardCfg == nil then
    awardCfg = ItemUtils.GetGiftAwardCfg(awardAllAllKey)
    if awardCfg == nil then
      awardCfg = ItemUtils.GetGiftAwardCfg(awardOcpAllKey)
      if awardCfg == nil then
        awardCfg = ItemUtils.GetGiftAwardCfg(awardAllSexKey)
      end
    end
  end
  return awardCfg
end
def.static("string", "=>", "table").GetGiftAwardCfg = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AWARD_TABLE_CFG, key)
  if record == nil then
    warn("[GetGiftAwardCfg]Gift Award cfg is nil for id: ", key)
    return nil
  end
  local cfg = {}
  cfg.key = record:GetStringValue("key")
  cfg.awardId = record:GetIntValue("awardId")
  cfg.occupationType = record:GetIntValue("occupationType")
  cfg.sexType = record:GetIntValue("sexType")
  cfg.appellationId = record:GetIntValue("appellationId")
  cfg.titleId = record:GetIntValue("titleId")
  cfg.moneyList = {}
  cfg.expList = {}
  cfg.itemList = {}
  local moneyStruct = record:GetStructValue("moneyStruct")
  local moneySize = moneyStruct:GetVectorSize("moneyValue")
  for i = 0, moneySize - 1 do
    local rec = moneyStruct:GetVectorValueByIdx("moneyValue", i)
    local moneyInfo = {}
    moneyInfo.bigType = rec:GetIntValue("bigType")
    moneyInfo.littleType = rec:GetIntValue("littleType")
    moneyInfo.num = rec:GetIntValue("num")
    table.insert(cfg.moneyList, moneyInfo)
  end
  local expStruct = record:GetStructValue("expStruct")
  local expSize = expStruct:GetVectorSize("expValue")
  for i = 0, expSize - 1 do
    local rec = expStruct:GetVectorValueByIdx("expValue", i)
    local expInfo = {}
    expInfo.expType = rec:GetIntValue("expType")
    expInfo.num = rec:GetIntValue("num")
    table.insert(cfg.expList, expInfo)
  end
  local itemStruct = record:GetStructValue("itemStruct")
  local itemSize = itemStruct:GetVectorSize("itemValue")
  for i = 0, itemSize - 1 do
    local rec = itemStruct:GetVectorValueByIdx("itemValue", i)
    local itemInfo = {}
    itemInfo.itemId = rec:GetIntValue("itemid")
    itemInfo.num = rec:GetIntValue("num")
    table.insert(cfg.itemList, itemInfo)
  end
  return cfg
end
def.static("table", "=>", "string").AwardCfg2String = function(awardCfg)
  if awardCfg == nil then
    return ""
  end
  local strTbl = {}
  for k, v in ipairs(awardCfg.moneyList) do
    local bigType = v.bigType
    local littleType = v.littleType
    if bigType == AllMoneyType.TYPE_MONEY then
      local cfg = ItemUtils.GetMoneyCfg(littleType)
      local str = string.format("%s x %d", cfg.name, v.num)
      table.insert(strTbl, str)
    elseif bigType == AllMoneyType.TYPE_TOKEN then
      local cfg = ItemUtils.GetTokenCfg(littleType)
      local str = string.format("%s x %d", cfg.name, v.num)
      table.insert(strTbl, str)
    end
  end
  for k, v in ipairs(awardCfg.expList) do
    local cfg = ItemUtils.GetExpCfg(v.expType)
    local str = string.format("%s x %d", cfg.name, v.num)
    table.insert(strTbl, str)
  end
  for k, v in ipairs(awardCfg.itemList) do
    local id, num = v.itemId, v.num
    local itemBase = ItemUtils.GetItemBase(id)
    local str = string.format("%s x %d", itemBase.name, num)
    table.insert(strTbl, str)
  end
  return table.concat(strTbl, "\n")
end
def.static("table", "=>", "table").GetAwardItemsFromAwardCfg = function(awardCfg)
  if awardCfg == nil then
    return nil
  end
  local itemList = {}
  awardCfg.itemList = awardCfg.itemList or {}
  for i, v in pairs(awardCfg.itemList) do
    local id, num = v.itemId, v.num
    local itemBase = ItemUtils.GetItemBase(id)
    local iconId = itemBase.icon
    table.insert(itemList, {
      iconId = iconId,
      num = num,
      itemId = id
    })
  end
  awardCfg.moneyList = awardCfg.moneyList or {}
  for i, moneyBean in ipairs(awardCfg.moneyList) do
    local bigType = moneyBean.bigType
    local littleType = moneyBean.littleType
    local num = moneyBean.num
    if bigType == AllMoneyType.TYPE_MONEY then
      local cfg = ItemUtils.GetMoneyCfg(littleType)
      table.insert(itemList, {
        iconId = cfg.iconTex,
        num = num,
        itemId = cfg.desitemid or 0
      })
    elseif bigType == AllMoneyType.TYPE_TOKEN then
      local cfg = ItemUtils.GetTokenCfg(littleType)
      table.insert(itemList, {
        iconId = cfg.iconTex,
        num = num,
        itemId = cfg.showItemId or 0
      })
    else
      warn(string.format("Unhandled money type(%d) in %s", bigType, debug.traceback()))
    end
  end
  awardCfg.expList = awardCfg.expList or {}
  for i, expBean in ipairs(awardCfg.expList) do
    local cfg = ItemUtils.GetExpCfg(expBean.expType)
    local num = expBean.num
    table.insert(itemList, {
      iconId = cfg.iconTex,
      num = num,
      itemId = cfg.desitemid or 0
    })
  end
  return itemList
end
def.static("table", "=>", "table").GetAwardItemsFromAwardBean = function(awardBean)
  if awardBean == nil then
    return nil
  end
  local awardBean = clone(awardBean)
  awardBean.itemmap = awardBean.itemmap or {}
  awardBean.itemList = {}
  for id, num in pairs(awardBean.itemmap) do
    table.insert(awardBean.itemList, {num = num, itemId = id})
  end
  awardBean.moneyList = awardBean.moneyBeans
  awardBean.expList = awardBean.expBeans
  local awardCfg = awardBean
  return ItemUtils.GetAwardItemsFromAwardCfg(awardCfg)
end
def.static("string", "=>", "number").GetTitleConst = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TITLE_CONST_CFG, name)
  return DynamicRecord.GetIntValue(record, "value")
end
def.static("number", "=>", "table").GetExchangeItemCfg = function(itemID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXCHANGE_ITEM_CFG, itemID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.itemId = record:GetIntValue("itemId")
  cfg.itemNum = record:GetIntValue("itemNum")
  cfg.timeLimitCfgId = record:GetIntValue("timeLimitCfgId")
  cfg.exchangeTimesLimit = record:GetIntValue("exchangeTimesLimit")
  cfg.dailyExchangeTimesLimit = record:GetIntValue("dailyExchangeTimesLimit")
  cfg.needItemList = {}
  local rec2 = record:GetStructValue("needItemListStruct")
  local count = rec2:GetVectorSize("needItemList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("needItemList", i - 1)
    local t = {}
    t.itemId = rec3:GetIntValue("itemId")
    t.itemNum = rec3:GetIntValue("itemNum")
    table.insert(cfg.needItemList, t)
  end
  return cfg
end
def.static("number", "=>", "table").GetFivePreciousItemCfg = function(itemID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FIVE_PRECIOUS_ITEM_CFG, itemID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.npcid = record:GetIntValue("npcid")
  cfg.exchangeid = record:GetIntValue("exchangeid")
  cfg.npcservice = record:GetIntValue("npcservice")
  cfg.isuseyuanbao = record:GetCharValue("isuseyuanbao") ~= 0
  return cfg
end
def.static("number", "=>", "table").GetSelectableGiftItemCfg = function(itemID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SELECTABLE_GIFT_ITEM_CFG, itemID)
  if record == nil then
    warn("GetSelectableGiftItemCfg(" .. itemID .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.items = {}
  local itemsStruct = record:GetStructValue("itemsStruct")
  local count = itemsStruct:GetVectorSize("itemlist")
  for i = 1, count do
    local rec = itemsStruct:GetVectorValueByIdx("itemlist", i - 1)
    local t = {}
    t.itemId = rec:GetIntValue("itemid")
    t.itemNum = rec:GetIntValue("num")
    table.insert(cfg.items, t)
  end
  return cfg
end
def.static("number", "=>", "table").GetLotteryItemCfg = function(itemID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LOTTERY_ITEM_CFG, itemID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.Id = record:GetIntValue("id")
  cfg.typeId = record:GetIntValue("typeId")
  cfg.templateId = record:GetIntValue("templateId")
  return cfg
end
def.static("number", "=>", "table").GetLotteryViewRandomCfg = function(itemID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LOTTERY_VIEW_RANDOM_CFG, itemID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.Id = record:GetIntValue("id")
  local itemIdsStruct = record:GetStructValue("itemIdsStruct")
  local itemIdsSize = itemIdsStruct:GetVectorSize("itemIds")
  local itemIds = {}
  for i = 0, itemIdsSize - 1 do
    local rec = itemIdsStruct:GetVectorValueByIdx("itemIds", i)
    local itemId = rec:GetIntValue("itemId")
    table.insert(itemIds, itemId)
  end
  cfg.itemIds = itemIds
  return cfg
end
def.static("=>", "table").GetLotteryConst = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEM_CONSTS_CFG, "SECONDS_FOR_LOTTERY_SLOW_DOWN")
  if record == nil then
    return nil
  end
  local consts = {}
  consts.totalRotTime = record:GetIntValue("value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_ITEM_CONSTS_CFG, "SECONDS_FOR_STOP")
  if record == nil then
    return nil
  end
  consts.stopTime = record:GetIntValue("value")
  return consts
end
def.static("string", "=>", "table").GetGoldSilverPriceData = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BUY_GOLD_SILVER_CFG, key)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.yuanbaoNum = record:GetIntValue("yuanbaoNum")
  cfg.moneyNum = record:GetIntValue("moneyNum")
  cfg.iconId = record:GetIntValue("iconId")
  return cfg
end
def.static("number", "number", "=>", "table").GetYuanbaoNumRangeCFG = function(serverLevel, moneyType)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local record = DynamicData.GetRecord(CFG_PATH.DATA_YUANBAO_NUM_RANGE_CFG, serverLevel)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.Id = record:GetIntValue("id")
  local vectorName
  if moneyType == MoneyType.GOLD then
    vectorName = "goldYuanbaoNumList"
  elseif moneyType == MoneyType.SILVER then
    vectorName = "silverYuanbaoNumList"
  elseif moneyType == MoneyType.GOLD_INGOT then
    vectorName = "gotYuanbaoNumList"
  end
  local struct = record:GetStructValue("yuanbaoNumStruct")
  local vectorSz = struct:GetVectorSize(vectorName)
  local numList = {}
  for i = 0, vectorSz - 1 do
    local rec = struct:GetVectorValueByIdx(vectorName, i)
    local num = rec:GetIntValue("yuanbaoNum")
    table.insert(numList, num)
  end
  cfg.yuanbaoNumList = numList
  return cfg
end
def.static("string", "=>", "table").DebugSearchItem = function(target)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ITEMCFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local record = entry
    local cfg = {}
    cfg.name = record:GetStringValue("name")
    cfg.desc = record:GetStringValue("desc")
    if string.find(cfg.name, target) or string.find(cfg.desc, target) then
      cfg.itemid = record:GetIntValue("itemid")
      table.insert(list, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("string", "=>", "table").DebugFindItem = function(target)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ITEMCFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local record = entry
    local cfg = {}
    cfg.name = record:GetStringValue("name")
    if cfg.name == target then
      cfg.itemid = record:GetIntValue("itemid")
      table.insert(list, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "number", "=>", "boolean").FiltrateAItemByID = function(itemID, siftID)
  local itembase = ItemUtils.GetItemBase(itemID)
  local itemSiftCfg = ItemUtils.GetItemFilterCfg(siftID)
  return ItemUtils.FiltrateAItem(itembase, itemSiftCfg)
end
def.static("table", "table", "=>", "boolean").FiltrateAItem = function(itemBase, itemSiftCfg)
  for k, v in pairs(itemSiftCfg.siftCfgs) do
    if v.idtype == 1 then
      if itemBase.itemid == v.idvalue then
        return true
      end
    elseif v.idtype == 2 and ItemUtils.FiltrateAItemBySiftCon(itemBase, v.idvalue) == true then
      return true
    end
  end
  return false
end
def.static("table", "number", "=>", "boolean").FiltrateAItemBySiftCon = function(itemBase, itemSiftConID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEM_SIFT_CON_CFG, itemSiftConID)
  local itemType = record:GetIntValue("itemType")
  local fnTable = {}
  fnTable[2] = ItemUtils.FiltrateAItemByEquipSiftCon
  fnTable[4] = ItemUtils.FiltrateAItemByPetSkillBookSiftCon
  fnTable[5] = ItemUtils.FiltrateAItemByDrugInFightSiftCon
  local fn = fnTable[itemType]
  if fn == nil then
    error("************** FiltrateAItemBySiftCon itemType ==" .. tostring(itemType))
    return false
  end
  return fn(itemBase, itemSiftConID)
end
def.static("table", "number", "=>", "boolean").FiltrateAItemByEquipSiftCon = function(itemBase, itemSiftConID)
  local equipRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, itemBase.itemid)
  if equipRecord == nil then
    return false
  end
  local equipCfg = {}
  equipCfg.id = equipRecord:GetIntValue("id")
  equipCfg.menpai = equipRecord:GetIntValue("menpai")
  equipCfg.sex = equipRecord:GetIntValue("sex")
  equipCfg.wearpos = equipRecord:GetIntValue("wearpos")
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_SIFT_CONCFG, itemSiftConID)
  local id = record:GetIntValue("id")
  local color = record:GetIntValue("color")
  local isProprietary = record:GetIntValue("isProprietary")
  local maxUseLevel = record:GetIntValue("maxUseLevel")
  local menPai = record:GetIntValue("menPai")
  local minUseLevel = record:GetIntValue("minUseLevel")
  local sex = record:GetIntValue("sex")
  local wearPos = record:GetIntValue("wearPos")
  if color ~= 0 and itemBase.namecolor ~= color then
    return false
  end
  if isProprietary ~= 0 and (itemBase.isProprietary == true and isProprietary ~= 1 or itemBase.isProprietary == false and isProprietary ~= 2) then
    return false
  end
  if maxUseLevel ~= 0 and maxUseLevel < itemBase.useLevel or minUseLevel ~= 0 and minUseLevel > itemBase.useLevel then
    return false
  end
  if menPai ~= 0 and menPai ~= equipCfg.menpai then
    return false
  end
  if sex ~= 0 and sex ~= equipCfg.sex then
    return false
  end
  if wearPos ~= equipCfg.wearpos then
    return false
  end
  return true
end
def.static("table", "number", "=>", "boolean").FiltrateAItemByPetSkillBookSiftCon = function(itemBase, itemSiftConID)
  local PetSkillBookRecord = DynamicData.GetRecord(CFG_PATH.DATA_PET_SKILL_BOOK_ITEM_CFG, itemBase.itemid)
  if PetSkillBookRecord == nil then
    return false
  end
  local cfg = {}
  cfg.id = PetSkillBookRecord:GetIntValue("id")
  cfg.skillId = PetSkillBookRecord:GetIntValue("skillId")
  cfg.itemPhase = PetSkillBookRecord:GetIntValue("itemPhase")
  cfg.skillPhase = PetSkillBookRecord:GetIntValue("skillPhase")
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SKILL_BOOK_SIFT_CONCFG, itemSiftConID)
  local isProprietary = record:GetIntValue("isProprietary")
  local itemPhase = record:GetIntValue("itemPhase")
  local skillPhase = record:GetIntValue("skillPhase")
  if isProprietary ~= 0 and (itemBase.isProprietary == true and isProprietary ~= 1 or itemBase.isProprietary == false and isProprietary ~= 2) then
    return false
  end
  if itemPhase ~= 0 and cfg.itemPhase ~= itemPhase then
    return false
  end
  if skillPhase ~= 0 and cfg.skillPhase ~= skillPhase then
    return false
  end
  return true
end
def.static("table", "number", "=>", "boolean").FiltrateAItemByDrugInFightSiftCon = function(itemBase, itemSiftConID)
  local drugInFightRecord = DynamicData.GetRecord(CFG_PATH.DATA_DRUG_IN_FIGHT_CFG, itemId)
  if drugInFightRecord == nil then
    return false
  end
  local skillCfg = {}
  skillCfg.fun = drugInFightRecord:GetIntValue("fun")
  skillCfg.drugPro = drugInFightRecord:GetIntValue("drugPro")
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRUG_IN_FIGHT_SIFT_CONCFG, itemSiftConID)
  local fun = record:GetIntValue("fun")
  local isProprietary = record:GetIntValue("isProprietary")
  local maxDrugPro = record:GetIntValue("maxDrugPro")
  local minDrugPro = record:GetIntValue("minDrugPro")
  if isProprietary ~= 0 and (itemBase.isProprietary == true and isProprietary ~= 1 or itemBase.isProprietary == false and isProprietary ~= 2) then
    return false
  end
  if maxDrugPro ~= 0 and maxDrugPro < skillCfg.drugPro or minDrugPro ~= 0 and minDrugPro > skillCfg.drugPro then
    return false
  end
  return true
end
def.static("number", "=>", "table").GetEquipSiftCondCfg = function(itemSiftConID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_SIFT_CONCFG, itemSiftConID)
  if record == nil then
    warn("GetEquipSiftCondCfg(" .. itemSiftConID .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.color = record:GetIntValue("color")
  cfg.isProprietary = record:GetIntValue("isProprietary")
  cfg.maxUseLevel = record:GetIntValue("maxUseLevel")
  cfg.menPai = record:GetIntValue("menPai")
  cfg.minUseLevel = record:GetIntValue("minUseLevel")
  cfg.sex = record:GetIntValue("sex")
  cfg.wearPos = record:GetIntValue("wearPos")
  return cfg
end
def.static("number", "=>", "table").GetPetLifeCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_LIFE_ITEM_CFG, itemId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.petMinLifeLimit = record:GetIntValue("petMinLifeLimit")
  cfg.petMaxLifeLimit = record:GetIntValue("petMaxLifeLimit")
  cfg.drugPro = record:GetIntValue("drugPro")
  cfg.itemdesc = record:GetStringValue("itemdesc")
  return cfg
end
def.static("number", "=>", "boolean").CallSellAll = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SELL_ALL_CFG, itemId)
  return record ~= nil
end
def.static("number", "=>", "boolean").IsShowViewItem = function(itemtype)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEMTYPECFG, itemtype)
  if record == nil then
    warn("record is nil...", itemtype)
    return false
  end
  local TypeGroup = require("consts.mzm.gsp.item.confbean.TypeGroup")
  local typegroup = record:GetIntValue("typegroup")
  return typegroup == TypeGroup.VIEW
end
def.static("number", "number", "number", "=>", "boolean").CanOpenFitRoom = function(itemtype, gender, occaputation)
  return true
end
def.static("number", "=>", "number", "number").MapItemId2WingViewId = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WING_VIEW_ITEM, itemId)
  if record == nil then
    warn("MapItemId2WingViewId..getRecordFailed  ", itemId)
    return -1, -1
  end
  local wingId = record:GetIntValue("wingId")
  if wingId then
    local WingUtils = require("Main.Wing.WingUtils")
    local cfg = WingUtils.GetWingOutlookCfgByWingId(wingId)
    return cfg.id, cfg.dyeId
  end
  return -1, -1
end
def.static("number", "=>", "number").MapItemId2RidderId = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_RIDDER_ITEM, itemId)
  if record == nil then
    warn("MapItemId2RidderId getRecordFailed..", itemId)
    return -1
  end
  local ridderId = record:GetIntValue("ridderid")
  local ridderRecord = DynamicData.GetRecord(CFG_PATH.DATA_RIDE_CFG, ridderId)
  if ridderRecord == nil then
    warn("get ridderRecord failed.. ", ridderId)
    return -1
  end
  return ridderRecord:GetIntValue("modelId")
end
def.static("number", "=>", "table").GetFireWorkItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FIRE_WORK_ITEM, itemId)
  if record == nil then
    warn("GetFireWorkItemCfg Fail,", itemId)
    return nil
  end
  local cfg = {}
  cfg.id = itemId
  cfg.effectId = record:GetIntValue("effectId")
  cfg.soundId = record:GetIntValue("soundId")
  return cfg
end
def.static("table", "=>", "boolean").CheckItemUseCondition = function(itemBase)
  if itemBase == nil then
    Toast(textRes.Item[201])
    return false
  end
  local HeroInterface = require("Main.Hero.Interface")
  local heroProp = HeroInterface.GetHeroProp()
  if heroProp == nil then
    return false
  end
  if heroProp.level < itemBase.useLevel then
    Toast(string.format(textRes.Item[202], itemBase.useLevel))
    return false
  end
  return true
end
def.static("number", "=>", "number").GetItemRecycleGold = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GOLD_RECYCLE_CFG, itemId)
  if nil ~= record then
    local goldnum = DynamicRecord.GetIntValue(record, "goldnum")
    if goldnum then
      return goldnum
    end
  end
  return -1
end
local _rarityItemIdCache = {}
def.static("number", "=>", "boolean").IsRarity = function(itemId)
  if _rarityItemIdCache[itemId] ~= nil then
    return _rarityItemIdCache[itemId]
  end
  local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
  if TradingArcadeUtils.GetMarketItemCfg(itemId) then
    _rarityItemIdCache[itemId] = true
  else
    _rarityItemIdCache[itemId] = false
  end
  return _rarityItemIdCache[itemId]
end
def.static("table", "number", "number", "=>", "userdata").GetRoleIdByItem = function(item, xstoreTypeL, xstoreTypeH)
  if item == nil then
    return nil
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local roleId_L = item.extraMap[xstoreTypeL]
  local roleId_H = item.extraMap[xstoreTypeH]
  if roleId_L == nil or roleId_H == nil then
    return nil
  end
  local roleId = Int64.new("4294967296") * Int64.new(string.format("0x%x", roleId_H)) + Int64.new(string.format("0x%x", roleId_L))
  return roleId
end
def.static("number", "=>", "number").GetItemBulletinType = function(itemId)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEM_BULLETIN_CFG, itemId)
  if record ~= nil then
    local bulletType = record:GetIntValue("bulletType")
    if bulletType ~= nil then
      return bulletType
    end
  end
  return BulletinType.NORMAL
end
def.static("table", "=>", "number").GetAwardBulletinType = function(awardMap)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  for itemId, count in pairs(awardMap) do
    if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
      return BulletinType.UNUSUAL
    end
  end
  return BulletinType.NORMAL
end
def.static("number", "=>", "table").GetFurnitureCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FURNITURE_ITEM_CFG, itemId)
  if record == nil then
    warn("GetFurnitureCfg(" .. itemId .. ") return nil")
    return nil
  end
  return ItemUtils.ExtractFurnitureCfg(record)
end
def.static("=>", "table").GetAllFurnitures = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FURNITURE_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local cfg = ItemUtils.ExtractFurnitureCfg(record)
    cfgs[#cfgs + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("userdata", "=>", "table").ExtractFurnitureCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.picId = record:GetIntValue("picId")
  cfg.level = record:GetIntValue("level")
  cfg.addFengShuiValue = record:GetIntValue("addFengShuiValue")
  cfg.styleId = record:GetIntValue("styleId")
  cfg.furnitureType = record:GetIntValue("furnitureType")
  cfg.sameFurnitureCfgId = record:GetIntValue("sameFurnitureCfgId")
  cfg.isNewProduct = record:GetCharValue("is_new_product") ~= 0
  cfg.layer = record:GetIntValue("pos") or 3
  cfg.area = record:GetIntValue("area")
  cfg.addBeautifulValue = record:GetIntValue("addBeautifulValue")
  cfg.isShowInFurnitureBag = record:GetCharValue("isShowInFurnitureBag") ~= 0
  return cfg
end
def.static("number", "=>", "table").GetPetHuiZhiItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_HUIZHI_ITEM_CFG, itemId)
  if record == nil then
    warn("pet huizhi item not exist:" .. itemId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.colorId = record:GetIntValue("colorId")
  cfg.cannotUsePet = {}
  local cannotUseListStruct = record:GetStructValue("cannotUseListStruct")
  local cannotUseVectorSize = DynamicRecord.GetVectorSize(cannotUseListStruct, "cannotUseList")
  for i = 0, cannotUseVectorSize - 1 do
    local cannotUsePetRecord = DynamicRecord.GetVectorValueByIdx(cannotUseListStruct, "cannotUseList", i)
    local cannotUsePetId = cannotUsePetRecord:GetIntValue("cannotUseId")
    table.insert(cfg.cannotUsePet, cannotUsePetId)
  end
  return cfg
end
def.static("number", "=>", "table").GetUseAllItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_USE_ALL_ITEM_CFG, itemId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.itemId = itemId
  return cfg
end
def.static("number", "=>", "table").GetDoubleItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUBLE_ITEM_CFG, itemId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.totalTimes = record:GetIntValue("total_times")
  return cfg
end
def.static("number", "=>", "table").GetTimeEffectItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TIME_EFFECT_ITEM_CFG, itemId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.itemId = record:GetIntValue("item_id")
  cfg.itemTimeType = record:GetIntValue("item_time_type")
  cfg.beginEffectTime = record:GetIntValue("begin_effect_time")
  cfg.endEffectTime = record:GetIntValue("end_effect_time")
  cfg.effectTimeSeconds = record:GetIntValue("effect_time_seconds")
  return cfg
end
def.static("number", "=>", "boolean").IsTimeEffectItem = function(itemId)
  return ItemUtils.GetTimeEffectItemCfg(itemId) ~= nil
end
def.static("table", "=>", "boolean").IsItemOutOfTime = function(item)
  if item == nil then
    return true
  end
  local itemId = item.id
  local timeEffectCfg = ItemUtils.GetTimeEffectItemCfg(itemId)
  if timeEffectCfg == nil then
    return false
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local ItemTimeType = require("consts.mzm.gsp.item.confbean.ItemTimeType")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  if timeEffectCfg.itemTimeType == ItemTimeType.FIX_LIMIT_TIME then
    local endTimePointCfg = TimeCfgUtils.GetCommonTimePointCfg(timeEffectCfg.endEffectTime)
    if endTimePointCfg == nil then
      return false
    else
      local curTime = _G.GetServerTime()
      local endTime = AbsoluteTimer.GetServerTimeByDate(endTimePointCfg.year, endTimePointCfg.month, endTimePointCfg.day, endTimePointCfg.hour, endTimePointCfg.min, endTimePointCfg.sec)
      return curTime >= endTime
    end
  elseif timeEffectCfg.itemTimeType == ItemTimeType.GET_EFFECT_TIME then
    local endSec = item.extraMap[ItemXStoreType.TIME_ITEM_END_TIME]
    local curTime = _G.GetServerTime()
    return endSec <= curTime
  elseif timeEffectCfg.itemTimeType == ItemTimeType.USER_DEFINED_END_TIME then
    local endSec = item.extraMap[ItemXStoreType.TIME_ITEM_END_TIME]
    if endSec == nil then
      return false
    end
    local curTime = _G.GetServerTime()
    return endSec <= curTime
  end
  return false
end
def.static("table", "=>", "boolean").IsItemReachUseTime = function(item)
  if item == nil then
    return false
  end
  local itemId = item.id
  local timeEffectCfg = ItemUtils.GetTimeEffectItemCfg(itemId)
  if timeEffectCfg == nil then
    return true
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local ItemTimeType = require("consts.mzm.gsp.item.confbean.ItemTimeType")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  if timeEffectCfg.itemTimeType == ItemTimeType.FIX_LIMIT_TIME then
    local startTimePointCfg = TimeCfgUtils.GetCommonTimePointCfg(timeEffectCfg.beginEffectTime)
    if startTimePointCfg == nil then
      return true
    else
      local curTime = _G.GetServerTime()
      local startTime = AbsoluteTimer.GetServerTimeByDate(startTimePointCfg.year, startTimePointCfg.month, startTimePointCfg.day, startTimePointCfg.hour, startTimePointCfg.min, startTimePointCfg.sec)
      return curTime >= startTime
    end
  elseif timeEffectCfg.itemTimeType == ItemTimeType.GET_EFFECT_TIME or timeEffectCfg.itemTimeType == ItemTimeType.USER_DEFINED_END_TIME then
    return true
  end
  return true
end
def.static("table", "=>", "boolean").IsItemDuringEffectTime = function(item)
  return ItemUtils.IsItemReachUseTime(item) and not ItemUtils.IsItemOutOfTime(item)
end
def.static("number", "=>", "boolean").IsGiveLimitItem = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GIVE_LIMIE_ITEM_CFG, itemId)
  if record == nil then
    return false
  end
  return true
end
def.static("number", "=>", "table").GetDrawCardItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CFlopLotteryItemCfg, id)
  if record == nil then
    warn("GetDrawCardItemCfg nil", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.flopLotteryMainCfgId = record:GetIntValue("flopLotteryMainCfgId")
  return cfg
end
def.static("table", "table", "=>", "string").GetItemFrame = function(itemInfo, itemBase)
  local result = ""
  if itemInfo then
    local godWeaponStage = itemInfo.extraMap and itemInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
    if not godWeaponStage or not godWeaponStage then
      godWeaponStage = 0
    end
    result = ItemUtils.GetItemFrameByGodWeaponStage(godWeaponStage, itemInfo.id, itemBase)
  else
    warn("[ERROR][ItemUtils:GetItemFrame] itemInfo nil!")
    result = ""
  end
  return result
end
def.static("number", "number", "table", "=>", "string").GetItemFrameByGodWeaponStage = function(godWeaponStage, itemId, itemBase)
  local result = ""
  if godWeaponStage > 0 then
    result = BreakOutData.Instance():GetEquipStageFrame(godWeaponStage)
  else
    if nil == itemBase then
      itemBase = ItemUtils.GetItemBase(itemId)
    end
    if itemBase then
      result = string.format("Cell_%02d", itemBase.namecolor)
    else
      warn("[ERROR][ItemUtils:GetItemFrameByStage] itemBase nil for itemid:", itemId)
      result = ""
    end
  end
  return result
end
def.static("table", "table", "=>", "string").GetItemName = function(itemInfo, itemBase)
  local result = ""
  if nil == itemBase then
    itemBase = itemInfo and ItemUtils.GetItemBase(itemInfo.id) or nil
  end
  if itemBase then
    result = itemBase.name
    if itemInfo then
      local godWeaponStage = itemInfo.extraMap and itemInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
      if godWeaponStage and godWeaponStage > 0 then
        local stageCfg = BreakOutData.Instance():GetStageCfg(godWeaponStage)
        result = not stageCfg or not stageCfg.namePrefix or not stageCfg.namePrefix or stageCfg.namePrefix .. result or result
      end
    end
  else
    warn("[ERROR][ItemUtils:GetItemName] itemBase nil for itemid:", itemInfo and itemInfo.id)
  end
  return result
end
def.static("number", "=>", "number").GetBagIdByItemType = function(itemType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEMTYPE2BAGID_CFG, itemType)
  if record == nil then
    return 0
  end
  local bagId = record:GetIntValue("bagId")
  return bagId
end
def.static("number", "=>", "table").GetChainGiftBagCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHAIN_GIFT_ITEM_CFG, itemId)
  if record == nil then
    warn("GetChainGiftItemCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.giftBagItemId = record:GetIntValue("giftBagItemId")
  cfg.chain = record:GetIntValue("chain")
  cfg.sn = record:GetIntValue("sn")
  cfg.countDown = record:GetIntValue("countDown")
  cfg.chainGifts = {}
  local chainRecord = DynamicData.GetRecord(CFG_PATH.DATA_CHAIN_GIFT_CHAIN_CFG, cfg.chain)
  if chainRecord == nil then
    warn("GetChainGiftItemCfg Chain(" .. itemId .. ") return nil, chain is(" .. cfg.chain .. ")")
    return nil
  end
  local giftStruct = chainRecord:GetStructValue("giftStruct")
  local count = giftStruct:GetVectorSize("giftList")
  for i = 1, count do
    local rec = giftStruct:GetVectorValueByIdx("giftList", i - 1)
    local giftId = rec:GetIntValue("giftId")
    table.insert(cfg.chainGifts, giftId)
  end
  return cfg
end
def.static("number", "=>", "table").GetNextGiftInChainGiftBag = function(itemId)
  local cfg = ItemUtils.GetChainGiftBagCfg(itemId)
  if cfg == nil then
    return nil
  end
  local item
  local nextGiftId = cfg.chainGifts[cfg.sn + 1]
  if nextGiftId ~= nil then
    item = {}
    item.itemId = nextGiftId
    item.itemNum = 1
  end
  return item
end
def.static("number", "=>", "table").GetItemsInChainGiftBag = function(itemId)
  local cfg = ItemUtils.GetChainGiftBagCfg(itemId)
  if cfg == nil then
    return {}
  end
  local items = {}
  local nextGift = ItemUtils.GetNextGiftInChainGiftBag(itemId)
  if nextGift ~= nil then
    local item = {}
    item.itemId = nextGift.itemId
    item.itemNum = nextGift.itemNum
    table.insert(items, item)
  end
  local giftCfg = ItemUtils.GetGiftBasicCfg(itemId)
  if giftCfg ~= nil then
    local awardId = giftCfg.awardId
    local awardItems = ItemUtils.GetAwardItems(awardId)
    if awardItems ~= nil then
      for i = 1, #awardItems do
        local item = {}
        item.itemId = awardItems[i].itemId
        item.itemNum = awardItems[i].num
        table.insert(items, item)
      end
    else
      warn("fix award is nil, " .. awardId)
    end
  else
    warn("gift bag item is nil," .. itemId)
  end
  return items
end
def.static("number", "=>", "table").GetItemSplitCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEM_SPLIT_CFG, itemId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.itemId = record:GetIntValue("itemId")
  cfg.requiredSilver = record:GetIntValue("requiredSilver")
  cfg.requiredGold = record:GetIntValue("requiredGold")
  cfg.requiredVigor = record:GetIntValue("requiredVigor")
  cfg.description = record:GetStringValue("description")
  cfg.canSplitAll = record:GetCharValue("canSplitAll") ~= 0
  cfg.canSplitBind = record:GetCharValue("canSplitBind") ~= 0
  return cfg
end
def.static("number", "=>", "table").GetEquipBlessItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_BLESS_ITEM_CFG, itemId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.itemId = record:GetIntValue("id")
  cfg.minBlessValue = record:GetIntValue("minBlessValue")
  cfg.maxBlessValue = record:GetIntValue("maxBlessValue")
  return cfg
end
def.static("number", "=>", "table").GetShapeShiftItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SHAPE_SHIFT_ITEM_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.useLevelMax = record:GetIntValue("useLevelMax")
  cfg.awardType = record:GetIntValue("awardType")
  return cfg
end
ItemUtils.Commit()
return ItemUtils
