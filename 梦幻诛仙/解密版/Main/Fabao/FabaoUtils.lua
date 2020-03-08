local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local SkillUtils = require("Main.Skill.SkillUtility")
local FabaoUtils = Lplus.Class("FabaoUtils")
local def = FabaoUtils.define
def.const("table").Animation = {STAND = "Stand_c"}
def.static("string", "=>", "number").GetFabaoConstValue = function(constName)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_CONSTANTS, constName)
  if nil == record then
    return 0
  end
  return record:GetIntValue("value")
end
def.static("number", "number", "=>", "table").GetAllFabaoInCfgOnTypeAndRank = function(targetType, rank)
  local allFabao = FabaoUtils.GetAllFabaoInCfg(targetType)
  local fabaoInCfg = {}
  if allFabao and #allFabao > 0 then
    for k, v in pairs(allFabao) do
      if v then
        if 0 == rank then
          table.insert(fabaoInCfg, v)
        elseif v.rank == rank then
          table.insert(fabaoInCfg, v)
        end
      end
    end
    return fabaoInCfg
  else
    return fabaoInCfg
  end
end
def.static("number", "=>", "table").GetAllFabaoInCfg = function(targetType)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAO_ITEM)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local allFabao = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local fabao = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local id = record:GetIntValue("id")
    fabao.id = id
    fabao.classId = record:GetIntValue("classId")
    fabao.rank = record:GetIntValue("rank")
    fabao.fabaoType = record:GetIntValue("fabaoType")
    fabao.canCompose = record:GetCharValue("canCompose") ~= 0
    fabao.randId = record:GetIntValue("rankId")
    local itemBase = ItemUtils.GetItemBase(fabao.id)
    fabao.iconId = itemBase.icon
    fabao.namecolor = itemBase.namecolor
    fabao.name = itemBase.name
    fabao.useLevel = itemBase.useLevel
    if 0 == targetType then
      table.insert(allFabao, fabao)
    elseif targetType == fabao.fabaoType then
      table.insert(allFabao, fabao)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  table.sort(allFabao, function(a, b)
    if a.rank < b.rank then
      return true
    elseif a.rank > b.rank then
      return false
    elseif a.id < b.id then
      return true
    else
      return false
    end
  end)
  return allFabao
end
def.static("=>", "number").GetFabaoMaxRank = function()
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAO_ITEM)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local maxRank = 1
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local fabao = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local curRank = record:GetIntValue("rank") or 1
    if maxRank < curRank then
      maxRank = curRank
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return maxRank
end
def.static("number", "number", "=>", "table").GetLongJingByAttrIdAndLevel = function(mainAttrId, mainLevel)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LONGJING_ITEM)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local longjings = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = record:GetIntValue("id")
    local itemBase = ItemUtils.GetItemBase(id)
    local longjingBase = ItemUtils.GetLongJingItem(id)
    local level = longjingBase.lv
    local attrId = longjingBase.attrIds[1]
    if level == mainLevel and attrId ~= mainAttrId then
      local longjing = {}
      longjing.id = id
      longjing.name = itemBase.name
      longjing.iconId = itemBase.icon
      longjing.attrId = attrId
      longjing.attrName = FabaoUtils.GetFabaoProName(longjing.attrId)
      longjing.attrValue = longjingBase.attrValues[1]
      longjing.level = level
      table.insert(longjings, longjing)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(longjings, function(a, b)
    return a.id < b.id
  end)
  return longjings
end
def.static("number", "=>", "table").GetSpecialTypeLongjingTypeName = function(fabaoType)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LONGJING_ITEM)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  local cfgName = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = record:GetIntValue("id")
    local longjingType = record:GetIntValue("longjingType")
    if fabaoType == longjingType then
      local itemBase = ItemUtils.GetItemBase(id)
      local typeName = itemBase.itemTypeName
      if not cfgs[typeName] then
        cfgs[typeName] = true
        table.insert(cfgName, typeName)
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgName
end
def.static("string", "=>", "table").GetLongjingIdByTypeName = function(typeName)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LONGJING_ITEM)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = record:GetIntValue("id")
    local lv = record:GetIntValue("lv")
    local itemBase = require("Main.Item.ItemUtils").GetItemBase(id)
    local itemTypeName = itemBase.itemTypeName
    if itemTypeName == typeName then
      local data = {}
      data.id = id
      data.level = lv
      table.insert(cfgs, data)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(a, b)
    return a.level < b.level
  end)
  return cfgs
end
def.static("=>", "table").GetAllLongJingItems = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LONGJING_ITEM)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local index = 0
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = record:GetIntValue("id")
    local lv = record:GetIntValue("lv")
    if lv == 1 then
      index = index + 1
      cfgs[index] = id
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "number", "=>", "table").GetFabaoAttrTypeAndValue = function(attrId, fabaoLevel)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAOATTRIBUTE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local proClassId = record:GetIntValue("proClassid")
    local level = record:GetIntValue("lv")
    local color = record:GetIntValue("color")
    if level == fabaoLevel and attrId == proClassId then
      local proStruct = record:GetStructValue("proStruct")
      local proVectorCount = DynamicRecord.GetVectorSize(proStruct, "proList")
      local proCfg = {}
      for j = 0, proVectorCount - 1 do
        local proRecord = DynamicRecord.GetVectorValueByIdx(proStruct, "proList", j)
        local proType = proRecord:GetIntValue("proType")
        local proValue = proRecord:GetIntValue("proValue")
        local proSubCfg = {}
        proSubCfg.proType = proType
        proSubCfg.proValue = proValue
        proSubCfg.proColor = color
        table.insert(proCfg, proSubCfg)
      end
      return proCfg
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return {}
end
def.static("number", "=>", "table").GetAllFabaoSkill = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_SKILL_CFG, id)
  if nil == record then
    return nil
  end
  local skillCfg = {}
  local skillStruct = record:GetStructValue("skillStruct")
  local skillVectorSize = DynamicRecord.GetVectorSize(skillStruct, "skillVector")
  for i = 0, skillVectorSize - 1 do
    local skillRecord = DynamicRecord.GetVectorValueByIdx(skillStruct, "skillVector", i)
    local skillId = skillRecord:GetIntValue("skillId")
    table.insert(skillCfg, skillId)
  end
  return skillCfg
end
def.static("number", "=>", "string").GetFabaoProName = function(proType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, proType)
  if nil == record then
    return " "
  end
  return record:GetStringValue("propName") or " "
end
def.static("number", "=>", "number", "number").GetFabaoSkillLidId = function(rankId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAORANK_CFG, rankId)
  if nil == record then
    return 0, 0
  end
  local rankSkillLibId = record:GetIntValue("skillLibId")
  local randomSkillLibId = record:GetIntValue("randomLibId")
  return rankSkillLibId, randomSkillLibId
end
def.static("number", "number", "number", "=>", "number").GetFabaoScore = function(attrId, fabaoLevel, skillId)
  local attrCfg = FabaoUtils.GetFabaoAttrTypeAndValue(attrId, fabaoLevel)
  local score = 0
  if nil ~= attrCfg then
    for k, v in pairs(attrCfg) do
      local proType = v.proType
      local proValue = v.proValue
      local factor = EquipUtils.GetPropertyFactor(proType)
      score = score + proValue * factor
    end
  end
  if skillId then
    score = score + SkillUtils.GetRoleSpecialSkillScore(skillId)
  end
  return math.floor(score)
end
def.static("number", "=>", "number").GetNextLevelUpHeroLevel = function(targetClassId)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAOLEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local preLevel = 1
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local classId = record:GetIntValue("classId")
    local roleLv = record:GetIntValue("roleLv")
    if classId == targetClassId then
      if heroLevel < roleLv then
        local fabaoLevel = record:GetIntValue("lv")
        if fabaoLevel == preLevel + 1 then
          return roleLv
        end
      else
        preLevel = record:GetIntValue("lv")
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return heroLevel + 1
end
def.static("number", "=>", "number").GetFabaoLevelLimitByRoleLevel = function(targetClassId)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAOLEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local limitLevel = 1
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local classId = record:GetIntValue("classId")
    if classId == targetClassId then
      local roleLv = record:GetIntValue("roleLv")
      local fabaoLevel = record:GetIntValue("lv")
      if heroLevel < roleLv then
        return fabaoLevel
      elseif limitLevel < fabaoLevel then
        limitLevel = fabaoLevel
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return limitLevel
end
def.static("number", "=>", "number", "number", "number").GetFabaoLevelUpNeedExpById = function(rankId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAORANK_CFG, rankId)
  if record == nil then
    warn("GetFabaoLevelUpNeedExpById nil ", rankId)
    return 0, 0, 0
  end
  local needExp = record:GetIntValue("needRankExp") or 0
  local needStone = record:GetIntValue("needItemId") or 0
  local needNum = record:GetIntValue("needItemCount") or 0
  return needExp, needStone, needNum
end
def.static("number", "number", "=>", "number").GetFabaoLevelUpNeedExp = function(targetClassId, fabaoLevel)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAOLEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local classId = record:GetIntValue("classId")
    local level = record:GetIntValue("lv")
    if level == fabaoLevel and classId == targetClassId then
      return record:GetIntValue("needExp") or 0
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0
end
def.static("number", "number", "=>", "number").GetNeedRoleLevelUpToFabaoLevel = function(taretClassId, targetFabaoLevel)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAOLEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local classId = record:GetIntValue("classId")
    local level = record:GetIntValue("lv")
    if level == fabaoLevel and classId == targetClassId then
      return record:GetIntValue("roleLv") or 0
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0
end
def.static("number", "=>", "number").GetMaxFabaoLevelByClassId = function(targetClassId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAOLEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local maxLevel = 1
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local classId = record:GetIntValue("classId")
    local level = record:GetIntValue("lv")
    if classId == targetClassId and maxLevel < level then
      maxLevel = level
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return maxLevel
end
def.static("number", "number", "=>", "boolean").IsMaxFabaoLevel = function(targetClassId, curLevel)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAOLEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local classId = record:GetIntValue("classId")
    local level = record:GetIntValue("lv")
    if level == curLevel + 1 and classId == targetClassId then
      return false
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return true
end
def.static("number", "=>", "number", "number").GetFabaoRankUpNeedItemInfo = function(rankId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAORANK_CFG, rankId)
  if nil == record then
    return 0, 0
  end
  local rankNeedItemId = record:GetIntValue("needItemId")
  local rankNeedItemNum = record:GetIntValue("needItemCount")
  return rankNeedItemId, rankNeedItemNum
end
def.static("number", "=>", "number", "number").GetFabaoWashSkillNeedItemInfo = function(rankId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAORANK_CFG, rankId)
  if nil == record then
    return 0, 0
  end
  local washNeedItemId = record:GetIntValue("washNeedItemId")
  local washNeedItemNum = record:GetIntValue("washNeedItemCount")
  return washNeedItemId, washNeedItemNum
end
def.static("number", "=>", "number").GetRankNeedScore = function(rankId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAORANK_CFG, rankId)
  if nil == record then
    return 0
  end
  return record:GetIntValue("needRankExp") or 0
end
def.static("number", "=>", "number").GetNextRankFabaoId = function(curFabaoId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_NEXTRANKID_CFG, curFabaoId)
  if nil == record then
    warn("next rank is nil ~~~~~~~~")
    return 0
  end
  return record:GetIntValue("nextRankFabaoId")
end
def.static("number", "=>", "boolean").IsMaxRankFabao = function(fabaoId)
  return FabaoUtils.GetNextRankFabaoId(fabaoId) == 0
end
def.static("number", "=>", "number").GetPreLongJingItemId = function(curLongjingId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_PRELONGJINGID_CFG, curLongjingId)
  if nil == record then
    warn("pre longjing is nil ~~~")
    return 0
  end
  return record:GetIntValue("beforeLongjingId")
end
def.static("number", "=>", "userdata").GetFabaoModelColor = function(fabaoId)
  if 0 == fabaoId then
    return nil
  end
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoId)
  if nil == fabaoBase then
    return nil
  end
  local modelColorId = fabaoBase.modelColorId
  local colorCfg = GetModelColorCfg(modelColorId)
  local r = colorCfg.part2_r
  local g = colorCfg.part2_g
  local b = colorCfg.part2_b
  local a = colorCfg.part2_a
  return Color.Color(r / 255, g / 255, b / 255, a / 255)
end
def.static("number", "number", "=>", "table").GetFabaoExtraEffect = function(heroLevel, fabaoLevel)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAO_EXTRAEFFECT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local effectCfg = {}
  local ProValueType = require("consts.mzm.gsp.common.confbean.ProValueType")
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local roleLv = record:GetIntValue("roleLv")
    local fabaoMinLv = record:GetIntValue("fabaoMinLv")
    if heroLevel == roleLv and fabaoLevel == fabaoMinLv then
      local effectStruct = record:GetStructValue("effectStruct")
      local typeVectorSize = DynamicRecord.GetVectorSize(effectStruct, "typeVector")
      for j = 0, typeVectorSize - 1 do
        local typeRecord = DynamicRecord.GetVectorValueByIdx(effectStruct, "typeVector", j)
        local valueRecord = DynamicRecord.GetVectorValueByIdx(effectStruct, "valueVector", j)
        local proType = typeRecord:GetIntValue("proType")
        if 0 ~= proType then
          local proValue = valueRecord:GetIntValue("proValue")
          local proName = FabaoUtils.GetFabaoProName(proType)
          local proTypeCfg = GetCommonPropNameCfg(proType)
          local proValueType = proTypeCfg.valueType
          local effectStr = string.format("%s +%d", proName, proValue)
          if proValueType == ProValueType.TEN_THOUSAND_RATE then
            effectStr = string.format("%s +%3.1f%%", proName, proValue / 10000 * 100)
          end
          effectStr = effectStr .. "\n"
          table.insert(effectCfg, effectStr)
        end
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return effectCfg
end
def.static("number", "=>", "number", "boolean").GetNextEffectFabaoLevel = function(fabaoRankLevel)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAO_EXTRAEFFECT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local maxRankLevel = 1
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local roleLv = record:GetIntValue("roleLv")
    local fabaoMinLv = record:GetIntValue("fabaoMinLv")
    if heroLevel == roleLv then
      if maxRankLevel < fabaoMinLv then
        maxRankLevel = fabaoMinLv
      end
      if fabaoMinLv == fabaoRankLevel + 1 then
        return fabaoMinLv, false
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return maxRankLevel, true
end
def.static("=>", "number").GetMinEffectFabaoLevel = function()
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAO_EXTRAEFFECT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local minLevel = 10
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local roleLv = record:GetIntValue("roleLv")
    local fabaoMinLv = record:GetIntValue("fabaoMinLv")
    if heroLevel == roleLv and minLevel > fabaoMinLv then
      minLevel = fabaoMinLv
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return minLevel
end
def.static("number", "boolean", "number", "number").ShowFabaoEffectTip = function(fabaoRankLevel, isCanUse, posX, posY)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local effectStr = FabaoUtils.GetFabaoExtraEffect(heroLevel, fabaoRankLevel)
  local mainDesc = table.concat(effectStr)
  local title = string.format(textRes.Fabao[115], fabaoRankLevel)
  local desc1 = ""
  if isCanUse then
    desc1 = textRes.Fabao[116]
  else
    desc1 = textRes.Fabao[117]
  end
  local desc2 = string.format(textRes.Fabao[118], fabaoRankLevel)
  require("Main.Item.ui.TextTips").ShowTextTip(title, desc1, desc2, mainDesc, posX, posY)
end
def.static("=>", "number").GetFabaoEffectHoverTipId = function()
  return 701606000
end
def.static("=>", "number").GetFabaoRankUpHoverTipId = function()
  return 701606001
end
def.static("=>", "number").GetFabaoWashHoverTipId = function()
  return 701606002
end
local FabaoModelOffset = {
  [0] = {offsetX = 0, offsetY = 0},
  [700303001] = {offsetX = 0, offsetY = 0.25},
  [700303002] = {offsetX = 0, offsetY = 0.55},
  [700303003] = {offsetX = 0, offsetY = 0},
  [700303004] = {offsetX = 0, offsetY = 0.1},
  [700303005] = {offsetX = 0, offsetY = 0.9},
  [700303006] = {offsetX = 0, offsetY = 0.1},
  [700303007] = {offsetX = 0, offsetY = 0},
  [700303008] = {offsetX = 0, offsetY = 0},
  [700303009] = {offsetX = 0, offsetY = 0.1},
  [700303010] = {offsetX = 0, offsetY = 0.2},
  [700303011] = {offsetX = 0, offsetY = 0.1},
  [700303012] = {offsetX = 0, offsetY = 0.1},
  [700303013] = {offsetX = 0, offsetY = 0}
}
def.static("number", "=>", "table").GetFabaoModelOffset = function(modelId)
  local offsetCfg = FabaoModelOffset[modelId]
  return offsetCfg or FabaoModelOffset[0]
end
def.static("number", "=>", "number").GetFabaoNextRankSkillId = function(skillId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_NEXT_RANK_SKILL_CFG, skillId)
  warn("GetFabaoNextRankSkillId ~~~~~~~~~~~ ", record, skillId)
  if nil == record then
    return 0
  end
  local nextRankSkillId = record:GetIntValue("nextRankSkillId")
  return nextRankSkillId or 0
end
def.static("number", "=>", "number").GetFabaoFragmentComposeFabaoId = function(fabaoFragmentId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_EQUIPMAKE_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local composeFabaoId = 0
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local needItemStruct = record:GetStructValue("NeedItemStruct")
    local vecRecord = needItemStruct:GetVectorValueByIdx("NeedItemVector", 0)
    if vecRecord then
      local needItemId = vecRecord:GetIntValue("itemId") or 0
      if needItemId == fabaoFragmentId then
        local desItemStruct = record:GetStructValue("desItemStruct")
        local desVecRedcord = desItemStruct:GetVectorValueByIdx("desItemVector", 0)
        composeFabaoId = desVecRedcord:GetIntValue("itemId") or 0
        break
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return composeFabaoId
end
def.static("=>", "number", "number").GetLJTranformNpcIdAndServiceId = function()
  local npcId = 0
  local serveiceId = 0
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_CONSTANTS, "LONG_JING_TRANSFER_NPC")
  npcId = record and record:GetIntValue("value") or 0
  record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_CONSTANTS, "LONG_JING_TRANSFER_NPC_SERVICE")
  serveiceId = record and record:GetIntValue("value") or 0
  return npcId, serveiceId
end
def.static("=>", "number").GetLJTransformTipId = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_CONSTANTS, "LONG_JING_TRANSFER_DESC")
  return record and record:GetIntValue("value") or 701600000
end
def.static("=>", "number").GetLJTransformNeedLevel = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_CONSTANTS, "MIN_LEVEL_FOR_TRANSFER")
  return record and record:GetIntValue("value") or 1
end
FabaoUtils.Commit()
return FabaoUtils
