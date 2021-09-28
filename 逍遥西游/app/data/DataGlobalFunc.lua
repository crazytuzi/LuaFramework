Define_Tobody_GroupFront = -1
Define_Tobody_GroupMiddle = -2
Define_Tobody_GroupMiddle_Bottom = -3
Define_Tobody_BattleMiddle = -4
Define_Tobody_BattleMiddle_Bottom = -5
Define_Tobody_Top = 1
Define_Tobody_Mid = 2
Define_Tobody_Bottom = 3
Define_Tobody_sole = 4
SHAPEID_SHENLONG = 20058
SHAPEID_JIUTIANXUANNV = 20066
SHAPEID_YANRUYU = 20068
SHAPEID_DASHU = 20069
SHAPEID_LEIZHENZI = 20071
SHAPEID_SHENGDANXIONGMAO = 19001
SHAPEID_SHENGDANSHU = 30019
SHAPEID_BINGFENGHUANG = 20072
SHAPEID_HUOFENGHUANG = 20073
SHAPEID_CAONIMA = 20074
SHAPEID_SHENLONG_BLACK = 20083
SHAPEID_WSJ_XiaoNanGua = 30021
SHAPEID_FuHuoJieDan = 30022
SHAPEID_2017_YRJ_BingXueGuai = 31004
SHAPEID_2017_YRJ_ChiYanGuai = 31005
SHAPEID_2017_YRJ_CongCongCong = 31010
SHAPEID_2017_YRJ_ShenLing = 31014
SHAPEID_2017_YRJ_MingLingFeiZi = 31032
SHAPEID_2017_YRJ_ErLangShen = 31039
SHAPEID_2017_YRJ_NaZa = 31059
SHAPEID_2017_YRJ_ShuJing = 31070
SHAPEID_2017_YRJ_LengZhenZi = 31071
SHAPEID_2017_YRJ_BingFengHuang = 31072
SHAPEID_2017_YRJ_HuoFengHuang = 31073
SHAPE_CHANGE_WALK_IN_MAP_USEWAR_DICT = {
  [SHAPEID_2017_YRJ_BingXueGuai] = true,
  [SHAPEID_2017_YRJ_ChiYanGuai] = true,
  [SHAPEID_2017_YRJ_CongCongCong] = true,
  [SHAPEID_2017_YRJ_ShenLing] = true,
  [SHAPEID_2017_YRJ_MingLingFeiZi] = true,
  [SHAPEID_2017_YRJ_ErLangShen] = true,
  [SHAPEID_2017_YRJ_NaZa] = true,
  [SHAPEID_2017_YRJ_ShuJing] = true,
  [SHAPEID_2017_YRJ_LengZhenZi] = true,
  [SHAPEID_2017_YRJ_BingFengHuang] = true,
  [SHAPEID_2017_YRJ_HuoFengHuang] = true
}
SHAPE_BS_WALK_IN_MAP_DICT = {
  [SHAPEID_2017_YRJ_BingXueGuai] = true,
  [SHAPEID_2017_YRJ_ChiYanGuai] = true,
  [SHAPEID_2017_YRJ_CongCongCong] = true,
  [SHAPEID_2017_YRJ_ShenLing] = true,
  [SHAPEID_2017_YRJ_MingLingFeiZi] = true,
  [SHAPEID_2017_YRJ_ErLangShen] = true,
  [SHAPEID_2017_YRJ_NaZa] = true,
  [SHAPEID_2017_YRJ_ShuJing] = true,
  [SHAPEID_2017_YRJ_LengZhenZi] = true,
  [SHAPEID_2017_YRJ_BingFengHuang] = true,
  [SHAPEID_2017_YRJ_HuoFengHuang] = true,
  [SHAPEID_WSJ_XiaoNanGua] = true
}
SHAPE_BS_WALK_IN_WAR_DICT = {
  [SHAPEID_2017_YRJ_BingXueGuai] = 20014,
  [SHAPEID_2017_YRJ_ChiYanGuai] = 20015,
  [SHAPEID_2017_YRJ_CongCongCong] = 20008,
  [SHAPEID_2017_YRJ_ShenLing] = 90030,
  [SHAPEID_2017_YRJ_MingLingFeiZi] = 20027,
  [SHAPEID_2017_YRJ_ErLangShen] = 20025,
  [SHAPEID_2017_YRJ_NaZa] = 20033,
  [SHAPEID_2017_YRJ_ShuJing] = 20043,
  [SHAPEID_2017_YRJ_LengZhenZi] = 20038,
  [SHAPEID_2017_YRJ_BingFengHuang] = 20036,
  [SHAPEID_2017_YRJ_HuoFengHuang] = 20037,
  [SHAPEID_WSJ_XiaoNanGua] = nil
}
function GetRoleObjType(lTypeId)
  if lTypeId == nil then
    printLogDebug("ERROR", "GetRoleObjType lTypeId == nil")
    return 0
  end
  local rNum = math.floor(lTypeId / 10000)
  if rNum == 6 then
    return 5
  else
    return rNum
  end
end
function GetObjType(lTypeId)
  if lTypeId == nil then
    printLogDebug("ERROR", "GetObjType lTypeId == nil")
    return 0
  end
  return math.floor(lTypeId / 10000)
end
function data_getHeroIdsByRaceNZSheng(race, zhuangsheng)
  local ids = {}
  for heroId, heroData in pairs(data_Hero) do
    local ct = heroData.CHOOSETYPE
    if ct >= 0 and zhuangsheng >= ct and heroData.RACE == race then
      ids[#ids + 1] = heroId
    end
  end
  return ids
end
function data_getMainHeroIdsByRaceNZSheng(race, zhuangsheng)
  local ids = {}
  for heroId, heroData in pairs(data_Hero) do
    local nzs = heroData.NEEDZSNUM
    if nzs >= 0 and nzs == zhuangsheng and heroData.RACE == race then
      ids[#ids + 1] = heroId
    end
  end
  return ids
end
function data_getAllMainHeroTypeId()
  local typeList = {}
  for heroId, heroData in pairs(data_Hero) do
    local nzs = heroData.NEEDZSNUM
    if nzs >= 0 and nzs <= 3 then
      typeList[#typeList + 1] = heroId
    end
  end
  return typeList
end
function data_getRoleData(lTypeId)
  local roleType = GetRoleObjType(lTypeId)
  local roleData = {}
  if roleType == LOGICTYPE_HERO then
    roleData = data_Hero[lTypeId] or {}
  elseif roleType == LOGICTYPE_PET then
    roleData = data_Pet[lTypeId] or {}
  elseif roleType == LOGICTYPE_MONSTER then
    roleData = data_Monster[lTypeId] or {}
  elseif roleType == LOGICTYPE_ZUOQI then
    roleData = data_Zuoqi[lTypeId] or {}
  end
  return roleData
end
function data_getRoleProFromData(lTypeId, proName)
  local tempData = data_getRoleData(lTypeId)
  return tempData[proName] or 0
end
function data_getRoleShape(lTypeId)
  local roleType = GetRoleObjType(lTypeId)
  local roleData = {}
  if roleType == LOGICTYPE_HERO then
    roleData = data_Hero[lTypeId] or {}
  elseif roleType == LOGICTYPE_PET then
    roleData = data_Pet[lTypeId] or {}
  elseif roleType == LOGICTYPE_MONSTER then
    roleData = data_Monster[lTypeId] or {}
  elseif roleType == LOGICTYPE_NPC then
    roleData = data_NpcInfo[lTypeId] or {}
    return roleData.shape or 11001
  elseif roleType == LOGICTYPE_ZUOQI then
    roleData = data_Zuoqi[lTypeId] or {}
  end
  local shapeID = roleData.SHAPE
  if shapeID == nil then
    shapeID = 11001
  end
  return shapeID
end
function data_getShapeData(shapeId)
  if shapeId == SpecialShapeId_LocalPlayer and g_LocalPlayer then
    local mainHero = g_LocalPlayer:getMainHero()
    local rolId = mainHero:getTypeId()
    local nShapeId, nOrgShapeId, nIsSpecial = data_getRoleShape(rolId)
    return data_Shape[nShapeId]
  end
  return data_Shape[shapeId]
end
function data_getPetIdByShape(petShape)
  for petId, info in pairs(data_Pet) do
    if petShape == info.SHAPE then
      return petId
    end
  end
  return nil
end
function data_getRoleDes(lTypeId)
  local roleType = GetRoleObjType(lTypeId)
  local roleData = {}
  if roleType == LOGICTYPE_HERO then
    roleData = data_Hero[lTypeId] or {}
  elseif roleType == LOGICTYPE_PET then
    roleData = data_Pet[lTypeId] or {}
  elseif roleType == LOGICTYPE_MONSTER then
    roleData = data_Monster[lTypeId] or {}
  end
  local des = roleData.des
  if des == nil then
    des = ""
  end
  return des
end
function data_getRole_MonsterDes(mshape)
  for _, data in pairs(data_Pet) do
    if data.SHAPE == mshape then
      return data.mdes
    end
  end
  return ""
end
function data_getRoleShapeAndName(lTypeId)
  local roleType = GetRoleObjType(lTypeId)
  local roleData = {}
  if roleType == LOGICTYPE_HERO then
    roleData = data_Hero[lTypeId] or {}
  elseif roleType == LOGICTYPE_PET then
    roleData = data_Pet[lTypeId] or {}
  elseif roleType == LOGICTYPE_MONSTER then
    roleData = data_Monster[lTypeId] or {}
  elseif roleType == LOGICTYPE_NPC then
    roleData = data_NpcInfo[lTypeId] or {}
    local shapeId = roleData.shape or 11001
    local name = roleData.name or "NPC"
    return shapeId, name
  end
  local shapeID = roleData.SHAPE
  if shapeID == nil then
    shapeID = 11001
  end
  local name = roleData.NAME
  if name == nil then
    name = roleData.des or ""
  end
  return shapeID, name
end
function data_getRoleRace(lTypeId)
  local roleData = data_getRoleData(lTypeId)
  return roleData.RACE or RACE_REN
end
function data_getRoleSkillAttrList(lTypeId)
  local roleData = data_getRoleData(lTypeId)
  return roleData.HBSKILLATTR or {}
end
function data_getRoleSkillDes(lTypeId)
  local roleData = data_getRoleData(lTypeId)
  return roleData.HBSKILLDES or ""
end
function data_getRoleWeapon(lTypeId)
  local roleData = data_getRoleData(lTypeId)
  local race = roleData.RACE or RACE_REN
  local gender = roleData.GENDER or HERO_MALE
  if gender == HERO_MALE then
    if race == RACE_REN then
      return "剑"
    elseif race == RACE_MO then
      return "斧"
    elseif race == RACE_XIAN then
      return "枪"
    elseif race == RACE_GUI then
      return "幡"
    end
  elseif gender == HERO_FEMALE then
    if race == RACE_REN then
      return "刀"
    elseif race == RACE_MO then
      return "爪"
    elseif race == RACE_XIAN then
      return "丝带"
    elseif race == RACE_GUI then
      return "双手环"
    end
  end
  return "剑"
end
function data_getRoleCareer(lTypeId)
  local roleData = data_getRoleData(lTypeId)
  local race = roleData.RACE or RACE_REN
  local gender = roleData.GENDER or HERO_MALE
  if gender == HERO_MALE then
    if race == RACE_REN then
      return "男人"
    elseif race == RACE_MO then
      return "男魔"
    elseif race == RACE_XIAN then
      return "男仙"
    elseif race == RACE_GUI then
      return "男鬼"
    end
  elseif gender == HERO_FEMALE then
    if race == RACE_REN then
      return "女人"
    elseif race == RACE_MO then
      return "女魔"
    elseif race == RACE_XIAN then
      return "女仙"
    elseif race == RACE_GUI then
      return "女鬼"
    end
  end
  return ""
end
function data_getRoleGender(lTypeId)
  local roleData = data_getRoleData(lTypeId)
  return roleData.GENDER or HERO_MALE
end
function data_getPetCatchMap(lTypeId)
  local roleData = data_getRoleData(lTypeId)
  return roleData.CATCHMAP or 0
end
function data_getRoleShapOp(lTypeId)
  local roleData = data_getRoleData(lTypeId)
  return roleData.SHAPEOPA or 0
end
function GetItemTypeByItemTypeId(iTypeId)
  if iTypeId == nil then
    return nil
  end
  local num = math.floor(iTypeId / 10000)
  if num > 100 then
    return math.floor(num / 100) * 100
  elseif num > 10 then
    return math.floor(num / 10) * 10
  else
    return num
  end
end
function GetItemTypeNameByItemTypeId(iTypeId)
  local typeNum = GetItemTypeByItemTypeId(iTypeId)
  if typeNum == ITEM_LARGE_TYPE_DRUG then
    return "药品"
  elseif typeNum == ITEM_LARGE_TYPE_TASK then
    return "任务物品"
  elseif typeNum == ITEM_LARGE_TYPE_GIFT then
    return "礼包"
  elseif typeNum == ITEM_LARGE_TYPE_NEIDAN then
    return "魂石"
  elseif typeNum == ITEM_LARGE_TYPE_STUFF then
    return "材料"
  elseif typeNum == ITEM_LARGE_TYPE_LIANYAOSHI then
    return "炼妖石"
  elseif typeNum == ITEM_LARGE_TYPE_OTHERITEM then
    return "其他物品"
  elseif typeNum == ITEM_LARGE_TYPE_EQPT then
    return "初级装备"
  elseif typeNum == ITEM_LARGE_TYPE_SENIOREQPT then
    return "高级装备"
  elseif typeNum == ITEM_LARGE_TYPE_SHENBING then
    return "神兵"
  elseif typeNum == ITEM_LARGE_TYPE_XIANQI then
    return "仙器"
  elseif typeNum == ITEM_LARGE_TYPE_HUOBANEQPT then
    return "伙伴装备"
  elseif typeNum == ITEM_LARGE_TYPE_LIFEITEM then
    return "生活物品"
  elseif typeNum == ITEM_LARGE_TYPE_BANGPAI then
    return "帮派宝箱"
  end
  return "无分类物品"
end
function GetItemSubTypeByItemTypeId(iTypeId)
  if iTypeId == nil then
    return nil
  end
  iTypeId = iTypeId % 10000
  local num = math.floor(iTypeId / 1000)
  return num
end
function GetPetSkillBookTypeByItemTypeId(iTypeId)
  if iTypeId == nil then
    return nil
  end
  iTypeId = iTypeId % 1000
  local bookType = math.floor(iTypeId / 100)
  return bookType
end
function GetPetSkillNeedPro(petSkill)
  local petData = _getSkillData(petSkill)
  local needPro = {}
  if petData ~= nil then
    if petData.ll ~= 0 then
      needPro.ll = petData.ll
    end
    if petData.gg ~= 0 then
      needPro.gg = petData.gg
    end
    if petData.lx ~= 0 then
      needPro.lx = petData.lx
    end
    if petData.mj ~= 0 then
      needPro.mj = petData.mj
    end
  end
  return needPro
end
function GetItemDataByItemTypeId(iTypeId)
  local typeNum = GetItemTypeByItemTypeId(iTypeId)
  if typeNum == ITEM_LARGE_TYPE_DRUG then
    return data_Drug
  elseif typeNum == ITEM_LARGE_TYPE_TASK then
    return data_TaskItem
  elseif typeNum == ITEM_LARGE_TYPE_GIFT then
    return data_GiftItem
  elseif typeNum == ITEM_LARGE_TYPE_NEIDAN then
    return data_Neidan
  elseif typeNum == ITEM_LARGE_TYPE_STUFF then
    return data_Stuff
  elseif typeNum == ITEM_LARGE_TYPE_LIANYAOSHI then
    return data_Lianyaoshi
  elseif typeNum == ITEM_LARGE_TYPE_OTHERITEM then
    return data_OtherItem
  elseif typeNum == ITEM_LARGE_TYPE_LIFEITEM then
    local tempNum = math.floor(iTypeId / 1000)
    if tempNum == 700 then
      return data_LifeSkill_Drug
    elseif tempNum == 702 then
      return data_LifeSkill_Food
    elseif tempNum == 701 then
      return data_LifeSkill_Rune
    end
    return nil
  elseif typeNum == ITEM_LARGE_TYPE_EQPT then
    local tempNum = math.floor(iTypeId / 100000)
    if tempNum == 21 then
      return data_Weapon
    elseif tempNum == 22 then
      return data_Hat
    elseif tempNum == 23 then
      return data_Cloth
    elseif tempNum == 24 then
      return data_Shoes
    elseif tempNum == 25 then
      return data_Necklace
    end
    return nil
  elseif typeNum == ITEM_LARGE_TYPE_SENIOREQPT then
    local tempNum = math.floor(iTypeId / 100000)
    if tempNum == 31 then
      return data_SeniorWeapon
    elseif tempNum == 32 then
      return data_SeniorHat
    elseif tempNum == 33 then
      return data_SeniorCloth
    elseif tempNum == 34 then
      return data_SeniorShoes
    elseif tempNum == 35 then
      return data_SeniorNecklace
    elseif tempNum == 36 then
      return data_SeniorDecoration
    elseif tempNum == 37 then
      return data_SeniorDecoration
    elseif tempNum == 38 then
      return data_SeniorWing
    elseif tempNum == 39 then
      return data_SeniorDecoration
    elseif tempNum == 30 then
      return data_SeniorDecoration
    end
    return nil
  elseif typeNum == ITEM_LARGE_TYPE_SHENBING then
    return data_ShenBing
  elseif typeNum == ITEM_LARGE_TYPE_XIANQI then
    local tempNum = math.floor(iTypeId / 100000)
    if tempNum == 51 then
      return data_XqWeapon
    elseif tempNum == 52 then
      return data_XqHat
    elseif tempNum == 53 then
      return data_XqCloth
    elseif tempNum == 54 then
      return data_XqShoes
    elseif tempNum == 55 then
      return data_XqNecklace
    end
    return nil
  elseif typeNum == ITEM_LARGE_TYPE_HUOBANEQPT then
    local tempNum = math.floor(iTypeId / 100000)
    if tempNum == 61 then
      return data_HbWeapon
    elseif tempNum == 62 then
      return data_HbHat
    elseif tempNum == 63 then
      return data_HbCloth
    elseif tempNum == 64 then
      return data_HbShoes
    elseif tempNum == 65 then
      return data_HbNecklace
    else
      return data_HbDecoration
    end
    return nil
  elseif typeNum == ITEM_LARGE_TYPE_BANGPAI then
    return data_OrgWar_BoxItem
  end
  return nil
end
function GetLifeSkillItemType(objTypeId)
  local tempNum = math.floor(objTypeId / 1000)
  if tempNum == 700 then
    return LIFESKILL_PRODUCE_DRUG
  elseif tempNum == 702 then
    return LIFESKILL_PRODUCE_FOOD
  elseif tempNum == 701 then
    return LIFESKILL_PRODUCE_RUNE
  end
end
function data_getItemName(itemId)
  local itemType = GetItemTypeByItemTypeId(itemId)
  local typeName = GetItemTypeNameByItemTypeId(itemId)
  local tempData = GetItemDataByItemTypeId(itemId)
  if tempData == nil then
    return "未知" .. typeName
  elseif tempData[itemId] == nil then
    return "未知" .. typeName
  elseif tempData[itemId].name == nil then
    return "未知" .. typeName
  else
    return tempData[itemId].name
  end
end
function data_getItemPinjie(itemId)
  local tempData = GetItemDataByItemTypeId(itemId)
  if tempData == nil then
    return 0
  elseif tempData[itemId] == nil then
    return 0
  end
  return tempData[itemId].itemPJ or 0
end
function data_getItemValueCoeff(itemId)
  local tempData = GetItemDataByItemTypeId(itemId)
  if tempData == nil then
    return 0
  elseif tempData[itemId] == nil then
    return 0
  end
  return tempData[itemId].value or 0
end
function data_getItemShapeID(itemId)
  local itemType = GetItemTypeByItemTypeId(itemId)
  local tempData = GetItemDataByItemTypeId(itemId)
  if tempData == nil then
    return 10001
  elseif tempData[itemId] == nil then
    return 10001
  elseif tempData[itemId].itemShape == nil or tempData[itemId].itemShape == 0 then
    return 10001
  else
    return tempData[itemId].itemShape
  end
end
function data_getItemTips(itemId)
  local itemType = GetItemTypeByItemTypeId(itemId)
  local tempData = GetItemDataByItemTypeId(itemId)
  if tempData == nil then
    return ""
  elseif tempData[itemId] == nil then
    return ""
  elseif tempData[itemId].tips == nil or tempData[itemId].tips == 0 then
    return ""
  else
    return tempData[itemId].tips
  end
end
function data_getItemDes(itemId)
  local itemType = GetItemTypeByItemTypeId(itemId)
  local tempData = GetItemDataByItemTypeId(itemId)
  if tempData == nil then
    return ""
  elseif tempData[itemId] == nil then
    return ""
  elseif tempData[itemId].des == nil or tempData[itemId].des == 0 then
    return ""
  else
    return tempData[itemId].des
  end
end
function data_getItemPathByShape(shapeID)
  if shapeID == nil or shapeID == 0 then
    shapeID = 10001
  end
  local iconPath = string.format("xiyou/item/item%d.png", shapeID)
  local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(iconPath)
  if os.exists(fullPath) then
    return iconPath
  else
    return "xiyou/item/item10001.png"
  end
end
function data_getItemPathByShape_ForMap(shapeID)
  if shapeID == nil or shapeID == 0 then
    shapeID = 10001
  end
  local iconPath_ForMap = string.format("xiyou/item/item%d_map.png", shapeID)
  local fullPath_ForMap = CCFileUtils:sharedFileUtils():fullPathForFilename(iconPath_ForMap)
  if os.exists(fullPath_ForMap) then
    return iconPath_ForMap
  end
  local iconPath = string.format("xiyou/item/item%d.png", shapeID)
  local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(iconPath)
  if os.exists(fullPath) then
    return iconPath
  else
    return "xiyou/item/item10001.png"
  end
end
function data_getItemPackageIconPath(itemId)
  local itemType = GetItemTypeByItemTypeId(itemId)
  if itemType == ITEM_LARGE_TYPE_LIFEITEM then
    if data_getLifeSkillType(itemId) == IETM_DEF_LIFESKILL_DRUG then
      return string.format("views/packageui/package_icon%d.png", ITEM_PACKAGE_ICONTYPE_DRUG)
    else
      return string.format("views/packageui/package_icon%d.png", ITEM_PACKAGE_ICONTYPE_PROP)
    end
  elseif itemType == ITEM_LARGE_TYPE_OTHERITEM and GetItemSubTypeByItemTypeId(itemId) == ITEM_DEF_TYPE_SKILLBOOK then
    local bookType = GetPetSkillBookTypeByItemTypeId(itemId)
    if bookType == ITEM_DEF_SKILLBOOK_NORMAL then
      return "views/packageui/package_icon10.png"
    elseif bookType == ITEM_DEF_SKILLBOOK_SENIOR then
      return "views/packageui/package_icon11.png"
    elseif bookType == ITEM_DEF_SKILLBOOK_SUPREME then
      return "views/packageui/package_icon12.png"
    elseif bookType == ITEM_DEF_SKILLBOOK_SPECIAL then
      return "views/packageui/package_icon13.png"
    else
      return "views/packageui/package_icon10.png"
    end
  end
  local iconType = PACKAGE_ICON_TYPELIST_DICT[itemType]
  if iconType == nil then
    iconType = 1
  end
  return string.format("views/packageui/package_icon%d.png", iconType)
end
function data_getItemLvLimit(itemId)
  local tempData = GetItemDataByItemTypeId(itemId)
  if tempData == nil then
    return 0
  end
  if tempData[itemId] == nil then
    return 0
  end
  return tempData[itemId].lvlimit or 0
end
function data_getItemZsLimit(itemId)
  local tempData = GetItemDataByItemTypeId(itemId)
  if tempData == nil then
    return 0
  end
  if tempData[itemId] == nil then
    return 0
  end
  return tempData[itemId].zslimit or 0
end
function data_getItemCanUseJudgeLevel(itemId, zs, lv)
  local itemType = GetItemTypeByItemTypeId(itemId)
  if itemType == ITEM_LARGE_TYPE_OTHERITEM then
    local itemData = data_OtherItem[itemId]
    if itemData ~= nil then
      local needZs = itemData.needzs or 0
      local needLv = itemData.needlv or 0
      local alwaysJudgeLvFlag = itemData.AlwaysJudgeLvFlag or 0
      return data_judgeFuncOpen(zs, lv, needZs, needLv, alwaysJudgeLvFlag)
    end
  end
  return true
end
function data_getPetLevelType(petId)
  local levelType = Pet_LevelType_Normal
  if data_Pet[petId] ~= nil then
    levelType = data_Pet[petId].LEVELTYPE
  end
  return levelType
end
function data_getCatchPetHuoLi_Succeed(petId)
  local petData = data_Pet[petId]
  if petData == nil then
    return 0
  else
    return petData.CatchSuccCostHuoli
  end
end
function data_getCatchPetHuoLi_Failed(petId)
  local petData = data_Pet[petId]
  if petData == nil then
    return 0
  else
    return petData.CatchFailCostHuoli
  end
end
function data_getPetName(petId)
  local name = "召唤兽"
  if data_Pet[petId] ~= nil then
    name = data_Pet[petId].NAME
  end
  return name
end
function data_getPetIconPath(petId)
  local iconType = data_getPetLevelType(petId)
  return string.format("views/peticon/pet_icon%d.png", iconType)
end
function data_getWingColor(wingId)
  local lv = 1
  local data = data_SeniorWing[wingId]
  if data then
    lv = data.lv
  end
  if lv == 2 then
    return ccc3(240, 240, 140)
  elseif lv == 3 then
    return ccc3(130, 130, 240)
  elseif lv == 4 then
    return ccc3(130, 240, 130)
  elseif lv >= 5 then
    return ccc3(155, 0, 155)
  else
    return ccc3(255, 255, 255)
  end
end
function data_getWingShapeId(wingId)
  local lv = 1
  local data = data_SeniorWing[wingId]
  if data then
    lv = data.lv
  end
  if lv == 2 then
    return 5010
  elseif lv == 3 then
    return 5012
  elseif lv == 4 then
    return 5014
  elseif lv >= 5 then
    return 5015
  else
    return 5004
  end
end
function _getSkillData(skillID)
  local logicType = GetObjType(skillID)
  if logicType == LOGICTYPE_SKILL or logicType == LOGICTYPE_NEIDANSKILL then
    return data_Skill[skillID]
  elseif logicType == LOGICTYPE_MARRYSKILL then
    return data_MarrySkill[skillID]
  elseif logicType == LOGICTYPE_PETSKILL then
    local subType = _getPetSkillSubType(skillID)
    if subType == PETSKILL_SUBTYPE_NORMAL then
      return data_NormalPetSkill[skillID]
    elseif subType == PETSKILL_SUBTYPE_SENIOR then
      return data_SeniorPetSkill[skillID]
    elseif subType == PETSKILL_SUBTYPE_SUPREME then
      return data_SupremePetSkill[skillID]
    elseif subType == PETSKILL_SUBTYPE_SPECIAL then
      return data_SpecialPetSkill[skillID]
    end
  end
  return nil
end
function data_getSkillName(skillId)
  if skillId == SKILLTYPE_BABYMONSTER or skillId == SKILLTYPE_BABYPET then
    return "召唤"
  elseif skillId == SKILLTYPE_CATCHPET then
    return "抓捕"
  end
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    return "未知技能"
  elseif skillData.name == nil then
    return "未知技能"
  else
    return skillData.name
  end
end
function data_getSkillDesc(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    return "未知技能描述"
  elseif skillData.desc == nil then
    return "未知技能描述"
  else
    return skillData.desc
  end
end
function data_getPetSkillWbDesc(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    return ""
  elseif skillData.wbdesc == nil then
    return ""
  else
    return skillData.wbdesc
  end
end
function data_getSkillListByAttr(attr)
  local skillList = {}
  for skillId, skillData in pairs(data_Skill) do
    if skillData.attr == attr then
      skillList[skillData.step] = skillId
    end
  end
  return skillList
end
function data_getSkillAttrStyle(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    print("data error 找不到技能数据，无法判断技能的系别:", skillId)
    return SKILLATTR_UNKNOW
  end
  return skillData.attr
end
function data_getSkillStep(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    print("data error 找不到技能数据，无法判断技能的阶数:", skillId)
    return 0
  end
  return skillData.step
end
function data_getSkillNeedXiuLianDu(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    print("data error 找不到技能数据，无法判断技能的修炼度:", skillId)
    return 0
  end
  return skillData.xiuliandu or 0
end
function data_getSkillTargetType(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    print("data error 找不到技能数据，无法判断技能的目标类型:", skillId)
    return TARGETTYPE_ENEMYSIDE
  end
  return skillData.targetType
end
function data_getSkillCategoryId(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    print("data error 找不到技能数据，无法判断技能的类型:", skillId)
    return 0
  end
  return skillData.categoryId or 0
end
function data_getGGLXMJLL(skillId)
  local skillData = _getSkillData(skillId) or {}
  local gg = skillData.gg or 0
  local lx = skillData.lx or 0
  local mj = skillData.mj or 0
  local ll = skillData.ll or 0
  return gg, lx, mj, ll
end
function data_getSkillWuXingRequire(skillId)
  local skillData = _getSkillData(skillId) or {}
  local jin = skillData.jin or 0
  local mu = skillData.mu or 0
  local shui = skillData.shui or 0
  local huo = skillData.huo or 0
  local tu = skillData.tu or 0
  return jin, mu, shui, huo, tu
end
function data_getMonterCanUseSkill(skillId)
  local skillData = _getSkillData(skillId) or {}
  return skillData.monsteruse or 0
end
function data_getDelPetSkillCost(skillId)
  local subType = _getPetSkillSubType(skillId)
  local lvType = 1
  if subType == PETSKILL_SUBTYPE_NORMAL then
    lvType = 1
  elseif subType == PETSKILL_SUBTYPE_SENIOR then
    lvType = 2
  elseif subType == PETSKILL_SUBTYPE_SUPREME then
    lvType = 3
  elseif subType == PETSKILL_SUBTYPE_SPECIAL then
    lvType = 4
  end
  local data = data_DelPetSkillCost[lvType]
  if data then
    if data.Coin > 0 then
      return data.Coin, RESTYPE_COIN
    else
      return data.Silver, RESTYPE_SILVER
    end
  else
    return 0, RESTYPE_COIN
  end
end
function data_getSkillPinJieIconPath(skillId)
  local subType = _getPetSkillSubType(skillId)
  if subType == PETSKILL_SUBTYPE_NORMAL then
    return "views/packageui/package_icon10.png"
  elseif subType == PETSKILL_SUBTYPE_SENIOR then
    return "views/packageui/package_icon11.png"
  elseif subType == PETSKILL_SUBTYPE_SUPREME then
    return "views/packageui/package_icon12.png"
  elseif subType == PETSKILL_SUBTYPE_SPECIAL then
    return "views/packageui/package_icon13.png"
  else
    return "views/packageui/package_icon10.png"
  end
end
function data_getSkillShapePath(skillId)
  local iconID
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    iconID = nil
  else
    iconID = skillData.icon
  end
  if iconID == "0" or iconID == nil then
    return "xiyou/skill/skill10001.png"
  else
    return string.format("xiyou/skill/skill%s.png", iconID)
  end
end
function data_getSkillAniPathByAniID(aniID)
  local aniData = data_SkillAni[aniID]
  if aniData == nil then
    return nil
  end
  local aniPath = aniData.aniPath
  if aniPath == "0" or aniPath == nil then
    return nil
  end
  return {
    aniPath = "xiyou/ani/" .. aniPath,
    playtimes = aniData.playtimes,
    offx = aniData.offx,
    offy = aniData.offy,
    tobody = aniData.tobody,
    addtime = aniData.addtime,
    delaytime = aniData.delaytime,
    flip = aniData.flip,
    loopspace = aniData.loopspace,
    scale = aniData.scale,
    sound = aniData.sound
  }
end
function data_getSkillAniPathByAniIDList(aniID)
  local resultList = {}
  if type(aniID) == "table" then
    for _, id in pairs(aniID) do
      local temp = data_getSkillAniPathByAniID(id)
      if temp ~= nil then
        resultList[#resultList + 1] = temp
      end
    end
  elseif type(aniID) == "number" then
    local temp = data_getSkillAniPathByAniID(aniID)
    if temp ~= nil then
      resultList[#resultList + 1] = temp
    end
  end
  return resultList
end
function data_getSkillObjAniPath(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    return nil
  end
  local aniID = skillData.objAni
  return data_getSkillAniPathByAniIDList(aniID)
end
function data_getSkillDaZhaoAniPath(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    return {}
  end
  local aniID = skillData.dzAni
  return data_getSkillAniPathByAniIDList(aniID)
end
function data_getSkillAniTime(aniID)
  if type(aniID) == "table" then
    aniID = aniID[1]
  end
  local aniData = data_SkillAni[aniID]
  if aniData == nil then
    return nil, nil
  end
  local dt = aniData.delaytime
  return aniData.keeptime + dt, aniData.damagetime + dt
end
function data_getSkillAniKeepTime(skillId)
  local defaultSkillTime = 0.7
  local defaultDamageTime = 0.35
  if skillId == nil or skillId == SKILLTYPE_NORMALATTACK then
    return defaultSkillTime, defaultDamageTime, false
  else
    local skillData = _getSkillData(skillId)
    if skillData == nil then
      return defaultSkillTime, defaultDamageTime, false
    end
    local objAniID = skillData.objAni
    local objAniKeepTime, objAniDamageTime = data_getSkillAniTime(objAniID)
    local dzAniID = skillData.dzAni
    local dzAniKeepTime, dzAniDamageTime = data_getSkillAniTime(dzAniID)
    if objAniKeepTime ~= nil and dzAniKeepTime ~= nil then
      return math.max(objAniKeepTime, dzAniKeepTime), objAniDamageTime, true
    elseif objAniKeepTime ~= nil then
      return objAniKeepTime, objAniDamageTime, true
    elseif dzAniKeepTime ~= nil then
      return dzAniKeepTime, dzAniDamageTime, false
    elseif skillId == PETSKILL_HUIGEHUIRI then
      return 1.3, 0.4, true
    elseif skillId == PETSKILL_FEIYANHUIXIANG then
      return 1.3, 0.4, true
    elseif skillId == PETSKILL_BUBUSHENGLIAN then
      return 1.3, 0.4, true
    elseif skillId == PETSKILL_JUEJINGFENGSHENG then
      return 1.9, 0.4, true
    elseif skillId == PETSKILL_TIESHUKAIHUA then
      return 1.9, 0.4, true
    elseif skillId == MARRYSKILL_QINMIWUJIAN then
      return 1.3, 0.4, true
    else
      return defaultSkillTime, defaultDamageTime, false
    end
  end
end
function data_getObjSkillAniKeepTime(skillId, defaultDelay)
  local defaultSkillTime = 0
  local defaultDamageTime = 0
  if defaultDelay ~= false then
    defaultSkillTime = 0.7
    defaultDamageTime = 0.35
  end
  if skillId == nil or skillId == SKILLTYPE_NORMALATTACK then
    return defaultSkillTime, defaultDamageTime
  else
    local skillData = _getSkillData(skillId)
    if skillData == nil then
      return defaultSkillTime, defaultDamageTime
    end
    local objAniID = skillData.objAni
    local objAniKeepTime, objAniDamageTime = data_getSkillAniTime(objAniID)
    if objAniKeepTime ~= nil then
      return objAniKeepTime, objAniDamageTime
    else
      return defaultSkillTime, defaultDamageTime
    end
  end
end
function data_getShapeHitAniInfo(lTypeId, dir)
  local shapeId = data_getRoleShape(lTypeId)
  return data_getShapeHitAniInfoByShape(shapeId, dir)
end
function data_getShapeHitAniInfoByShape(shapeId, dir)
  local data = data_Shape[shapeId]
  local posType = 0
  if data == nil then
    return nil, nil, nil, nil, nil
  end
  if shapeId == SHAPEID_SHENLONG then
    posType = 1
  end
  if dir == DIRECTIOIN_LEFTUP and data.hitAni ~= nil and data.hitAni ~= "0" then
    return string.format("xiyou/ani/%s.plist", data.hitAni), data.hitAniDelay or 0, data.hitAniOff or {0, 0}, data.hitAniScale or 1, posType
  elseif dir == DIRECTIOIN_RIGHTDOWN and data.hitAni_e ~= nil and data.hitAni ~= "0" then
    return string.format("xiyou/ani/%s.plist", data.hitAni_e), data.hitAniDelay or 0, data.hitAniOff_e or {0, 0}, data.hitAniScale or 1, posType
  else
    return nil, nil, nil, nil, nil
  end
end
function data_getSkillShakeInfo(skillId)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    return 0, 0
  end
  local aniID = skillData.dzAni
  if aniID == 0 then
    return 0, 0
  end
  local aniData = data_SkillAni[aniID]
  if aniData == nil then
    return 0, 0
  else
    return aniData.shake, aniData.shaketime
  end
end
function data_getSkillPerformType(skillId)
  if skillId == nil or skillId == SKILLTYPE_NORMALATTACK then
    pType = PERFORMETYPE_MOVE
  else
    local skillData = _getSkillData(skillId) or {}
    pType = skillData.performType or PERFORMETYPE_STAND
  end
  return pType
end
function data_getSkillAttr(skillId)
  local skillData = _getSkillData(skillId) or {}
  if skillData then
    return skillData.attr
  else
    return nil
  end
end
function data_getUpdateEffectTime(effectID)
  if effectID == nil then
    return 0
  end
  local effectData = data_Effect[effectID] or {}
  if effectData then
    return effectData.effectTime or 0
  else
    return 0
  end
end
function data_getEffectAniID(effectID)
  if effectID == nil then
    return nil
  end
  local effectData = data_Effect[effectID] or {}
  if effectData then
    return effectData.aniPath
  else
    return nil
  end
end
function data_getHeadPathByShape(shapeID)
  local shapeData = data_Shape[shapeID]
  if shapeData then
    local headID = shapeData.headID
    local filePath = string.format("xiyou/head/head%d.png", headID)
    local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(filePath)
    if os.exists(fullPath) then
      return filePath
    end
  end
  return "xiyou/head/head11001.png"
end
function data_getBigHeadPathByShape(shapeID)
  local shapeData = data_Shape[shapeID]
  if shapeData then
    local headID = shapeData.headID
    local filePath = string.format("xiyou/head/head%d_big.png", headID)
    local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(filePath)
    if os.exists(fullPath) then
      return filePath
    end
  end
  return "xiyou/head/head11001_big.png"
end
function data_getBodyPathByShape(shapeID, compatible)
  if compatible ~= false then
    if shapeID == 11002 then
      shapeID = 11001
    elseif shapeID == 11008 then
      shapeID = 11006
    elseif shapeID == 12004 then
      shapeID = 12001
    elseif shapeID == 12009 then
      shapeID = 12006
    elseif shapeID == 13003 then
      shapeID = 13001
    elseif shapeID == 13006 then
      shapeID = 13008
    end
  end
  local shapeData = data_Shape[shapeID]
  if shapeData then
    local bodyID = shapeData.bodyID
    local offx = shapeData.body_offx
    local offy = shapeData.body_offy
    local color = shapeData.color
    return string.format("xiyou/shape/shape%d.plist", bodyID), offx, offy, color
  else
    return data_getBodyPathByShape(11001, compatible)
  end
end
function data_getBodyPathByZqShape(shapeID, compatible, direction)
  if SHAPE_CHANGE_WALK_IN_MAP_USEWAR_DICT[shapeID] == true then
    return data_getWarBodyPathByShape(shapeID, direction)
  end
  local shapeData = data_Shape[shapeID]
  if shapeData then
    local bodyID = shapeData.bodyID
    local offx = shapeData.body_offx
    local offy = shapeData.body_offy
    local color = shapeData.color
    return string.format("xiyou/shape/shapezq%d.plist", bodyID), 0, 0, color
  else
    return data_getBodyPathByZqShape(11001, compatible)
  end
end
function data_getBodyPathByShapeForDlg(shapeID)
  local shapeData = data_Shape[shapeID]
  if shapeData then
    local bodyID = shapeData.bodyID
    local offx = shapeData.body_offx
    local offy = shapeData.body_offy
    local color = shapeData.color
    return string.format("xiyou/shape/shape%d_dlg.plist", bodyID), offx, offy, color
  else
    return data_getBodyPathByShape(11001)
  end
end
function data_getWarBodyPathByShape(shapeID, direction)
  local shapeData = data_Shape[shapeID]
  if shapeData then
    local bodyID = shapeData.bodyID
    local extraOff, path
    if direction == DIRECTIOIN_LEFTUP then
      extraOff = shapeData.warbody_L_off
      path = string.format("xiyou/shape/shape%d_war.plist", bodyID)
    else
      extraOff = shapeData.warbody_R_off
      path = string.format("xiyou/shape/shape%d_war_e.plist", bodyID)
    end
    local offx = shapeData.body_offx + extraOff[1]
    local offy = shapeData.body_offy + extraOff[2]
    local color = shapeData.color
    return path, offx, offy, color
  else
    return data_getWarBodyPathByShape(11001, direction)
  end
end
function data_getWarBodyPngPathByShape(shapeID, direction)
  local shapeData = data_Shape[shapeID]
  if shapeData then
    local bodyID = shapeData.bodyID
    if direction == DIRECTIOIN_LEFTUP then
      return string.format("xiyou/shape/shape%d_war.png", bodyID)
    else
      return string.format("xiyou/shape/shape%d_war_e.png", bodyID)
    end
  else
    return data_getWarBodyPngPathByShape(11001, direction)
  end
end
function data_getBodyHeightByTypeID(lTypeId)
  local shapeID = data_getRoleShape(lTypeId)
  return data_getBodyHeightByShape(shapeID)
end
function data_getBodyHeightByShape(shapeID)
  local shapeData = data_Shape[shapeID]
  if shapeData then
    return shapeData.bodyHeight
  else
    return 0
  end
end
function data_getBodySizeByShape(shapeID)
  local shapeData = data_Shape[shapeID]
  if shapeData then
    return CCSize(shapeData.bodyWidth, shapeData.bodyHeight)
  else
    return CCSize(0, 0)
  end
end
function data_getBodyNormalAttackAniByShape(shapeID, direction)
  local aniInfo = {}
  local shapeData = data_Shape[shapeID]
  if shapeData then
    aniInfo.attSound = shapeData.attSound
    aniInfo.attSoundDelay = shapeData.attSoundDelay
    local attAni = shapeData.attAni
    if attAni and attAni ~= "0" then
      aniInfo.attAni = string.format("xiyou/ani/%s_%d.plist", attAni, direction)
      if direction == DIRECTIOIN_LEFTUP then
        aniInfo.attAni_offx = shapeData.attAni_L_offx
        aniInfo.attAni_offy = shapeData.attAni_L_offy
        aniInfo.attAni_Flip = shapeData.attAni_L_Flip
        aniInfo.attAniDelay = shapeData.attAniDelay
      elseif direction == DIRECTIOIN_RIGHTDOWN then
        aniInfo.attAni_offx = shapeData.attAni_R_offx
        aniInfo.attAni_offy = shapeData.attAni_R_offy
        aniInfo.attAni_Flip = shapeData.attAni_R_Flip
        aniInfo.attAniDelay = shapeData.attAniDelay
      end
    end
    if direction == DIRECTIOIN_LEFTUP then
      aniInfo.magicAni_offx = shapeData.magicAni_L_offx
      aniInfo.magicAni_offy = shapeData.magicAni_L_offy
    elseif direction == DIRECTIOIN_RIGHTDOWN then
      aniInfo.magicAni_offx = shapeData.magicAni_R_offx
      aniInfo.magicAni_offy = shapeData.magicAni_R_offy
    end
    local hurtAni = shapeData.hurtAni
    if hurtAni and hurtAni ~= "0" then
      aniInfo.hurtAni = string.format("xiyou/ani/%s_%d.plist", hurtAni, direction)
      if direction == DIRECTIOIN_LEFTUP then
        aniInfo.hurtAni_offx = shapeData.hurtAni_L_offx
        aniInfo.hurtAni_offy = shapeData.hurtAni_L_offy
      elseif direction == DIRECTIOIN_RIGHTDOWN then
        aniInfo.hurtAni_offx = shapeData.hurtAni_R_offx
        aniInfo.hurtAni_offy = shapeData.hurtAni_R_offy
      end
    end
  end
  return aniInfo
end
function data_getBodyNormalAttackAniByTypeID(lTypeId, direction)
  local shapeID = data_getRoleShape(lTypeId)
  return data_getBodyNormalAttackAniByShape(shapeID, direction)
end
function data_getBodySleepBuffOffByTypeID(lTypeId, direction)
  local shapeID = data_getRoleShape(lTypeId)
  local data = data_Shape[shapeID]
  if data ~= nil then
    if direction == DIRECTIOIN_LEFTUP then
      return data.sleep_L_off
    elseif direction == DIRECTIOIN_RIGHTDOWN then
      return data.sleep_R_off
    end
  end
  return {0, 0}
end
function data_getBodyDlgSoundPath(shapeID)
  local data = data_Shape[shapeID]
  if data ~= nil then
    if data.soundDlg ~= "0" then
      return string.format("xiyou/sound/%s", data.soundDlg)
    else
      return nil
    end
  else
    return nil
  end
end
function data_getChiBangOffInfo(shapeID, aniName)
  if shapeID == 11002 then
    shapeID = 11001
  elseif shapeID == 11008 then
    shapeID = 11006
  elseif shapeID == 12004 then
    shapeID = 12001
  elseif shapeID == 12009 then
    shapeID = 12006
  elseif shapeID == 13003 then
    shapeID = 13001
  elseif shapeID == 13006 then
    shapeID = 13008
  end
  local data = data_ChiBang[shapeID]
  if data ~= nil then
    return data[aniName] or {0, 0}
  end
  return {0, 0}
end
function date_getMaxFubenMapID()
  local maxId = 0
  for id, _ in ipairs(data_Catch) do
    maxId = id
  end
  return maxId
end
function date_getMaxFubenCatchID(fbID)
  local fbData = data_Catch[fbID]
  if fbData == nil then
    return 1
  end
  local maxId = 1
  for id, _ in ipairs(fbData.catchID) do
    maxId = id
  end
  return maxId
end
function data_getCatchDataList(fbID)
  local fbData = data_Catch[fbID]
  if fbData == nil then
    print("副本数据错误1，找不到对应的副本导表数据", fbID)
    return nil
  end
  return DeepCopyTable(fbData.catchID)
end
function data_getCatchData(fbID, catchID)
  local fbData = data_Catch[fbID]
  if fbData == nil then
    print("副本数据错误2，找不到对应的副本导表数据", fbID)
    return nil
  end
  local catchData = fbData.catchID[catchID]
  if catchData == nil then
    print("副本数据错误2，找不到对应的副本npc点导表数据", fbID, catchID)
    return nil
  end
  return DeepCopyTable(catchData)
end
function data_getCatchUnlockMapNeedZhuanAndLevel(fbID, iSuper)
  return data_getCatchUnlockCatchNeedZhuanAndLevel(fbID, 1, iSuper)
end
function data_getCatchUnlockCatchNeedZhuanAndLevel(fbID, catchID, iSuper)
  local catchData = data_getCatchData(fbID, catchID)
  if catchData == nil then
    return 0, 0
  end
  if iSuper == true or iSuper == 1 then
    return 0, 0
  else
    return catchData.nZhuanNeed, catchData.nLevelNeed
  end
end
function data_getCatchWarID(fbID, catchID, iSuper)
  local fbData = data_Catch[fbID]
  if fbData == nil then
    print("副本数据错误4，找不到对应的副本导表数据", fbID)
    return nil
  end
  local catchData = fbData.catchID[catchID]
  if catchData == nil then
    print("副本数据错误4，找不到对应的副本npc点导表数据", fbID, catchID)
    return nil
  end
  if iSuper == true or iSuper == 1 then
    return nil
  else
    return catchData.nWarTypeID
  end
end
function data_getFubenName(fbID)
  local fbData = data_Catch[fbID]
  if fbData == nil then
    print("副本数据错误3，找不到对应的副本导表数据", fbID)
    return ""
  end
  return fbData.mapName
end
function data_getCatchName(fbID, catchID)
  local data = data_getCatchData(fbID, catchID)
  if data == nil then
    return ""
  else
    return data.catchName or ""
  end
end
function data_getCatchIsDouble(fbID, catchID)
  local catchData = data_getCatchData(fbID, catchID)
  if catchData == nil then
    return false
  end
  return catchData.isDouble ~= 0
end
function data_getFirstDoubleCatchID(fbID)
  local mapData = data_getCatchDataList(fbID)
  local catchId = 1
  while true do
    local catchData = mapData[catchId]
    if catchData == nil or catchData.isDouble ~= 0 then
      break
    end
    catchId = catchId + 1
  end
  return catchId
end
function data_getCatchUnlockInfo(fbID, catchID, iSuper)
  local catchData = data_getCatchData(fbID, catchID)
  if catchData == nil then
    return 0, 0
  end
  if iSuper == true or iSuper == 1 then
    return 0, 0
  else
    return catchData.nZhuanNeed, catchData.nLevelNeed
  end
end
function data_getCatchWarMap(fbID, catchID)
  local data = data_getCatchData(fbID, catchID)
  if data == nil then
    return 0
  end
  return data.warmap
end
function data_getIsNpcBoss(npcId)
  local npcData = data_Monster[npcId]
  if npcData == nil then
    return false
  end
  return npcData.ISBOSS == 1
end
function data_getNpcRunawayData(npcId)
  local npcData = data_Monster[npcId]
  if npcData == nil then
    return 0, 0
  end
  return npcData.ESCAPEROUND, npcData.ESCAPERATIO
end
function data_getNpcConfusedRunawayData(npcId)
  local npcData = data_Monster[npcId]
  if npcData == nil then
    return 0
  end
  return npcData.CESCAPERATIO or 0
end
function data_getNpcCatchData(npcId)
  local petId = data_getPetIdByShape(data_getRoleShape(npcId))
  local petData = data_Pet[petId]
  if petData == nil then
    return 0, 0
  end
  return petData.CatchRatio, petData.CatchCostMp
end
function data_getWarPosList(warID)
  local tempWar = data_WarRole[warID] or {}
  local posList = tempWar.posList
  if posList ~= nil then
    return DeepCopyTable(posList)
  else
    print("战斗ID数据错误，找不到对应的野怪的列表", warID)
    return {}
  end
end
function data_getBossForWar(warId)
  local warData = data_WarRole[warId]
  local roleTypeId, name
  local isGetBoss = 0
  if warData ~= nil then
    local posList = warData.posList or {}
    local maxLv = -1
    for pos, typeId in pairs(posList) do
      local monsterData = data_Monster[typeId]
      if monsterData and isGetBoss <= monsterData.ISBOSS then
        local lv = monsterData.MONSTERLEVEL
        if isGetBoss > monsterData.ISBOSS or lv and maxLv <= lv then
          maxLv = lv
          roleTypeId = typeId
          name = monsterData.NAME
        end
        isGetBoss = monsterData.ISBOSS
      end
    end
  end
  return roleTypeId, name
end
function data_getRoleRebornValue(zs, valueIndex)
  local data = data_RbAdden[valueIndex]
  if data == nil then
    return 0
  end
  local value = data[string.format("rb%d", zs + 1)] or 0
  return value
end
function data_getMaxPetLevel(zs)
  local data = data_RbPetAttr[zs + 1]
  if data == nil then
    data = data_RbPetAttr[4]
  end
  local maxLV = data.lvlimit
  return maxLV
end
function data_getPetNeedClose(zs)
  local data = data_RbPetAttr[zs + 1]
  if data == nil then
    data = data_RbPetAttr[4]
  end
  local needClose = data.rclose
  return needClose
end
function data_getPetExLianyaoNum(zs)
  local data = data_RbPetAttr[zs + 2]
  if data == nil then
    data = data_RbPetAttr[4]
  end
  local lyNum = data.exnum
  return lyNum
end
function data_getPetRBNewLv(zs)
  local data = data_RbPetAttr[zs + 2]
  if data == nil then
    data = data_RbPetAttr[4]
  end
  local newLv = data.initlv
  return newLv
end
function data_getPetRBinitPro(zs)
  local data = data_RbPetAttr[zs + 2]
  if data == nil then
    data = data_RbPetAttr[4]
  end
  local initPro = data.initlv
  return initPro
end
function data_getMaxHeroLevel(zs)
  local k = zs + 1
  local data = data_RbAttr[k]
  if data == nil then
    return 1
  else
    return data.lvlimit
  end
end
function data_getMaxPetNum(zs)
  local k = zs + 1
  local data = data_RbAttr[k]
  if data == nil then
    return 0
  else
    return data.petnum
  end
end
function data_getMaxSkillExp(zs)
  local k = zs + 1
  local data = data_RbAttr[k]
  if data == nil then
    return data_RbAttr[0]
  else
    return data.maxskillexp
  end
end
function data_getNpcByMapId(mapId)
  return data_MapOfNpcs[mapId] or {}
end
function data_getZuoqiName(zqId)
  local data = data_Zuoqi[zqId]
  if data == nil then
    return ""
  end
  return data.name
end
function data_getZuoqiUnlockZsAndLevel(zqId)
  local data = data_Zuoqi[zqId]
  if data == nil then
    return 0, 0
  end
  return data.zqNeedZS, data.zqNeedLevel
end
function data_getZuoqiBasePros(zqId)
  local data = data_Zuoqi[zqId]
  if data == nil then
    return 0, 0, 0
  end
  return data.zqBaseLX, data.zqBaseLL, data.zqBaseGG
end
function data_getZuoqiSkillName(skillId)
  local skillData = data_ZuoqiSkill[skillId]
  if skillData then
    return skillData.name
  else
    return ""
  end
end
function data_getResPathByResID(resID)
  local path = "xiyou/res/res_coin.png"
  if resID == RESTYPE_COIN then
    path = "xiyou/res/res_coin.png"
  elseif resID == RESTYPE_GOLD then
    path = "xiyou/res/res_gold.png"
  elseif resID == RESTYPE_EXP then
    path = "xiyou/res/res_exp.png"
  elseif resID == RESTYPE_CHENGJIU then
    path = "xiyou/res/res_chengjiu.png"
  elseif resID == RESTYPE_TILI then
    path = "xiyou/res/res_tili.png"
  elseif resID == RESTYPE_Honour then
    path = "xiyou/res/res_honour.png"
  elseif resID == RESTYPE_SILVER then
    path = "xiyou/res/res_silver.png"
  elseif resID == RESTYPE_BPCONSTRUCT then
    path = "xiyou/res/res_construct.png"
  elseif resID == RESTYPE_HUOLI then
    path = "xiyou/res/res_huoli.png"
  elseif resID == RESTYPE_BAOSHIDU then
    path = "views/lifeskill/lifeskill_bsd.png"
  elseif resID == RESTYPE_XIAYI then
    path = "xiyou/res/res_xiyi.png"
  end
  return path
end
function data_getResPathByResIDForRichText(resID)
  local path = "xiyou/res/res_coin.png"
  if resID == RESTYPE_COIN then
    path = "xiyou/res/res_coin.png"
  elseif resID == RESTYPE_GOLD then
    path = "xiyou/res/res_gold.png"
  elseif resID == RESTYPE_EXP then
    path = "xiyou/res/res_exp2.png"
  elseif resID == RESTYPE_CHENGJIU then
    path = "xiyou/res/res_chengjiu.png"
  elseif resID == RESTYPE_TILI then
    path = "xiyou/res/res_tili.png"
  elseif resID == RESTYPE_Honour then
    path = "xiyou/res/res_honour.png"
  elseif resID == RESTYPE_SILVER then
    path = "xiyou/res/res_silver.png"
  elseif resID == RESTYPE_BPCONSTRUCT then
    path = "xiyou/res/res_construct.png"
  elseif resID == RESTYPE_HUOLI then
    path = "xiyou/res/res_huoli.png"
  elseif resID == RESTYPE_XIAYI then
    path = "xiyou/res/res_xiyi.png"
  end
  return path
end
function data_getResNameByResID(resID)
  local name = "未知资源"
  if resID == RESTYPE_COIN then
    name = "铜钱"
  elseif resID == RESTYPE_GOLD then
    name = "元宝"
  elseif resID == RESTYPE_EXP then
    name = "经验"
  elseif resID == RESTYPE_CHENGJIU then
    name = "成就"
  elseif resID == RESTYPE_SILVER then
    name = "银币"
  end
  return name
end
function data_getRewardDataByGiftId(giftId)
  local d = checkint(giftId / 1000)
  if d == 1 then
    local data = data_GiftOfOnline[giftId]
    if data then
      return data.reward
    end
  elseif d == 2 then
    local data = data_GiftOfLevelUp[giftId]
    if data then
      return data.reward
    end
  elseif d == 3 then
    local data = data_GiftOfCheckIn[giftId]
    if data and data.reward then
      return {
        data.reward
      }
    end
  end
  return nil
end
function data_getPromulgateInfo(targetId)
  local d = data_Promulgate[targetId]
  return d
end
function data_getPromulgateDesc(targetId)
  local d = data_Promulgate[targetId]
  if d == nil then
    return ""
  else
    return d.desc
  end
end
function data_getBuyTiliPrice(buyTiliNum)
  local price = data_VIPBuyTili[#data_VIPBuyTili].price
  if data_VIPBuyTili[buyTiliNum] and data_VIPBuyTili[buyTiliNum].price then
    price = data_VIPBuyTili[buyTiliNum].price
  end
  return price
end
function data_getCurBuyTiliNumByVIP(vipIndex)
  local maxVIP = data_getMaxVIPLv()
  if vipIndex > maxVIP then
    vipIndex = maxVIP
  end
  local tempData = data_VIPData[vipIndex + 1]
  if tempData == nil then
    return 0
  else
    return tempData.BuyTiliNum
  end
end
function data_getMaxBuyTiliNum()
  local maxVIPLv = data_getMaxVIPLv()
  return data_VIPData[maxVIPLv + 1].BuyTiliNum
end
function data_getMaxVIPLv()
  local index = 0
  for _, _ in pairs(data_VIPData) do
    index = index + 1
  end
  return index - 1
end
function data_getCanUseSBDNum(vipLv)
  local maxVIP = data_getMaxVIPLv()
  if vipLv > maxVIP then
    vipLv = maxVIP
  end
  local tempData = data_VIPData[vipLv + 1]
  if tempData == nil then
    return 0
  else
    return tempData.UseSBDNum
  end
end
function data_getSceneMusicPath(sceneId)
  local data = data_MapInfo[sceneId]
  return data.music
end
function data_getHeroStarNum(starPoint)
  local starNum = 0
  for num, data in ipairs(data_HeroStarData) do
    if starPoint < data.needP then
      return starNum
    end
    starNum = num
  end
  return starNum
end
function data_getNeedStarPoint(starNum)
  if data_HeroStarData[starNum] ~= nil then
    return data_HeroStarData[starNum].needP
  elseif data_HeroStarData[starNum - 1] ~= nil then
    return data_HeroStarData[starNum - 1].needP
  else
    print("星星个数，错误", starNum)
    return 0
  end
end
function data_getAddStarPoint(starNum, color)
  local num = 0
  num = num + (data_HeroStarData[starNum].addP or 0)
  num = num + (data_HeroStarColorData[color].addP or 0)
  return num
end
function data_getStarSkillValue(starNum)
  if data_HeroStarData[starNum] ~= nil then
    return data_HeroStarData[starNum].proP
  else
    print("data_getPoint星星个数，错误", starNum)
    return 0.75
  end
end
function data_getSceneWarMap(mapId)
  local mapData = data_MapInfo[mapId]
  if mapData == nil then
    return 1
  end
  return mapData.warmap
end
function data_getSceneMapName(mapId)
  local mapData = data_MapInfo[mapId]
  if mapData == nil then
    return ""
  end
  return mapData.name
end
function data_getWarNumLimit(zs, lv)
  if zs > 0 then
    return 4
  elseif lv >= 60 then
    return 4
  elseif lv >= 40 then
    return 3
  elseif lv >= 20 then
    return 2
  else
    return 1
  end
end
function data_getNextAddWarNumLimit(zs, lv)
  if zs > 0 then
    return nil
  elseif lv >= 60 then
    return nil
  elseif lv >= 40 then
    return 60
  elseif lv >= 20 then
    return 40
  else
    return 20
  end
end
function data_getShopItemSortNum(itemId, dataList)
  local sortNum = 9999
  for _, data in pairs(dataList) do
    if data[itemId] ~= nil then
      return data[itemId].sortNo
    end
  end
  return sortNum
end
function data_getPvpShopItemSortNum(itemId)
  local sortNum = 9999
  if data_ShopHonour2[itemId] ~= nil then
    return data_ShopHonour2[itemId].sortNo
  elseif data_ShopHonour[itemId] ~= nil then
    return data_ShopHonour[itemId].sortNo
  end
  return sortNum
end
function data_getJiuguanCoin(index)
  if data_JiuguanPrice[index] == nil then
    return 0
  else
    return data_JiuguanPrice[index].needCoin or 0
  end
end
function data_getJiuguanGold(index)
  if data_JiuguanPrice[index] == nil then
    return 0
  else
    return data_JiuguanPrice[index].needGold or 0
  end
end
function data_getJiuguanIndexByShowNo(showNo)
  for dataIndex, data in pairs(data_JiuguanPrice) do
    if data.showNo == showNo then
      return dataIndex
    end
  end
  return showNo
end
function data_getJiuguanNeedZsLvData(index)
  if data_JiuguanPrice[index] == nil then
    return 0, 0, 0
  else
    local zs = data_JiuguanPrice[index].needZs or 0
    local lv = data_JiuguanPrice[index].needLv or 0
    local alwaysJudgeLvFlag = data_JiuguanPrice[index].AlwaysJudgeLvFlag or 0
    return zs, lv, alwaysJudgeLvFlag
  end
end
function data_getJiuguanRole(mainHeroType, index)
  local roleData = data_getRoleData(mainHeroType)
  local race = roleData.RACE or RACE_REN
  local gender = roleData.GENDER or HERO_MALE
  if gender == HERO_MALE then
    if race == RACE_REN then
      return data_JiuguanRole[1][string.format("r%d", index)] or 0
    elseif race == RACE_MO then
      return data_JiuguanRole[3][string.format("r%d", index)] or 0
    elseif race == RACE_XIAN then
      return data_JiuguanRole[5][string.format("r%d", index)] or 0
    elseif race == RACE_GUI then
      return data_JiuguanRole[7][string.format("r%d", index)] or 0
    end
  elseif gender == HERO_FEMALE then
    if race == RACE_REN then
      return data_JiuguanRole[2][string.format("r%d", index)] or 0
    elseif race == RACE_MO then
      return data_JiuguanRole[4][string.format("r%d", index)] or 0
    elseif race == RACE_XIAN then
      return data_JiuguanRole[6][string.format("r%d", index)] or 0
    elseif race == RACE_GUI then
      return data_JiuguanRole[8][string.format("r%d", index)] or 0
    end
  end
  return 0
end
function data_getAllJiuguanRole(mainHeroType)
  local roleData = data_getRoleData(mainHeroType)
  local race = roleData.RACE or RACE_REN
  local gender = roleData.GENDER or HERO_MALE
  local index = 1
  if gender == HERO_MALE then
    if race == RACE_REN then
      index = 1
    elseif race == RACE_MO then
      index = 3
    elseif race == RACE_XIAN then
      index = 5
    elseif race == RACE_GUI then
      index = 7
    end
  elseif gender == HERO_FEMALE then
    if race == RACE_REN then
      index = 2
    elseif race == RACE_MO then
      index = 4
    elseif race == RACE_XIAN then
      index = 6
    elseif race == RACE_GUI then
      index = 8
    end
  end
  local tList = {}
  for i = 1, 13 do
    tList[#tList + 1] = data_JiuguanRole[index][string.format("r%d", i)] or 0
  end
  return tList
end
function data_getInsertGemType(num)
  if data_InsertGem[num] then
    return data_InsertGem[num].bsType
  else
    return nil
  end
end
function data_getInsertGemRate(num)
  if data_InsertGem[num] then
    return data_InsertGem[num].rate
  else
    return nil
  end
end
function data_getInsertGemMoney(num)
  if data_InsertGem[num] then
    return data_InsertGem[num].money or 0
  else
    return 0
  end
end
function data_getUpgradeItemMoney(itemTypeId, lv, upgradeType)
  local largeType = GetItemTypeByItemTypeId(itemTypeId)
  local isZhuangshi = false
  local tempData = GetItemDataByItemTypeId(itemTypeId)
  if tempData ~= nil and tempData[itemTypeId] ~= nil then
    local weaponType = tempData[itemTypeId].weaponType or 0
    if weaponType == ITEM_DEF_EQPT_WEAPON_YAODAI or weaponType == ITEM_DEF_EQPT_WEAPON_GUANJIAN or weaponType == ITEM_DEF_EQPT_WEAPON_MIANJU or weaponType == ITEM_DEF_EQPT_WEAPON_PIFENG or weaponType == ITEM_DEF_EQPT_WEAPON_CHIBANG then
      isZhuangshi = true
    end
  end
  if upgradeType == Eqpt_Upgrade_CreateType then
    if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      if isZhuangshi == true then
        if lv == 1 then
          return data_FuncEquipCtrl[411].money
        elseif lv == 2 then
          return data_FuncEquipCtrl[421].money
        end
      elseif lv == 1 then
        return data_FuncEquipCtrl[211].money
      elseif lv == 2 then
        return data_FuncEquipCtrl[221].money
      end
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      if lv == 1 then
        return data_FuncEquipCtrl[311].money
      elseif lv == 2 then
        return data_FuncEquipCtrl[321].money
      end
    end
  elseif upgradeType == Eqpt_Upgrade_LianhuaType then
    if largeType == ITEM_LARGE_TYPE_EQPT then
      return data_FuncEquipCtrl[102].money
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      if isZhuangshi == true then
        if lv == 1 then
          return data_FuncEquipCtrl[412].money
        elseif lv == 2 then
          return data_FuncEquipCtrl[422].money
        elseif lv == 3 then
          return data_FuncEquipCtrl[432].money
        elseif lv == 4 then
          return data_FuncEquipCtrl[442].money
        elseif lv == 5 then
          return data_FuncEquipCtrl[452].money
        end
      elseif lv == 1 then
        return data_FuncEquipCtrl[212].money
      elseif lv == 2 then
        return data_FuncEquipCtrl[222].money
      end
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      if lv == 1 then
        return data_FuncEquipCtrl[312].money
      elseif lv == 2 then
        return data_FuncEquipCtrl[322].money
      end
    elseif largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      return data_FuncEquipCtrl[602].money
    end
  elseif upgradeType == Eqpt_Upgrade_ChonglianType then
    if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      if isZhuangshi == true then
        if lv == 1 then
          return data_FuncEquipCtrl[413].money
        elseif lv == 2 then
          return data_FuncEquipCtrl[423].money
        end
      elseif lv == 1 then
        return data_FuncEquipCtrl[213].money
      elseif lv == 2 then
        return data_FuncEquipCtrl[223].money
      end
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      if lv == 1 then
        return data_FuncEquipCtrl[313].money
      elseif lv == 2 then
        return data_FuncEquipCtrl[323].money
      end
    elseif largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      return data_FuncEquipCtrl[603].money
    end
  end
  return 0
end
function data_getUpgradeItemList(itemTypeId, lv, upgradeType)
  local largeType = GetItemTypeByItemTypeId(itemTypeId)
  local isZhuangshi = false
  local tempData = GetItemDataByItemTypeId(itemTypeId)
  if tempData ~= nil and tempData[itemTypeId] ~= nil then
    local weaponType = tempData[itemTypeId].weaponType or 0
    if weaponType == ITEM_DEF_EQPT_WEAPON_YAODAI or weaponType == ITEM_DEF_EQPT_WEAPON_GUANJIAN or weaponType == ITEM_DEF_EQPT_WEAPON_MIANJU or weaponType == ITEM_DEF_EQPT_WEAPON_PIFENG or weaponType == ITEM_DEF_EQPT_WEAPON_CHIBANG then
      isZhuangshi = true
    end
  end
  if upgradeType == Eqpt_Upgrade_CreateType then
    if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      if isZhuangshi == true then
        if lv == 1 then
          return data_FuncEquipCtrl[411].items
        elseif lv == 2 then
          return data_FuncEquipCtrl[421].items
        end
      elseif lv == 1 then
        return data_FuncEquipCtrl[211].items
      elseif lv == 2 then
        return data_FuncEquipCtrl[221].items
      end
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      if lv == 1 then
        return data_FuncEquipCtrl[311].items
      elseif lv == 2 then
        return data_FuncEquipCtrl[321].items
      elseif lv == 3 then
        return data_FuncEquipCtrl[331].items
      elseif lv == 4 then
        return data_FuncEquipCtrl[341].items
      end
    end
  elseif upgradeType == Eqpt_Upgrade_LianhuaType then
    if largeType == ITEM_LARGE_TYPE_EQPT then
      return data_FuncEquipCtrl[102].items
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      if isZhuangshi == true then
        if lv == 1 then
          return data_FuncEquipCtrl[412].items
        elseif lv == 2 then
          return data_FuncEquipCtrl[422].items
        elseif lv == 3 then
          return data_FuncEquipCtrl[432].items
        elseif lv == 4 then
          return data_FuncEquipCtrl[442].items
        elseif lv == 5 then
          return data_FuncEquipCtrl[452].items
        end
      elseif lv == 1 then
        return data_FuncEquipCtrl[212].items
      elseif lv == 2 then
        return data_FuncEquipCtrl[222].items
      end
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      if lv == 1 then
        return data_FuncEquipCtrl[312].items
      elseif lv == 2 then
        return data_FuncEquipCtrl[322].items
      end
    elseif largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      return data_FuncEquipCtrl[602].items
    end
  elseif upgradeType == Eqpt_Upgrade_ChonglianType then
    if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      if isZhuangshi == true then
        if lv == 1 then
          return data_FuncEquipCtrl[413].items
        elseif lv == 2 then
          return data_FuncEquipCtrl[423].items
        end
      elseif lv == 1 then
        return data_FuncEquipCtrl[213].items
      elseif lv == 2 then
        return data_FuncEquipCtrl[223].items
      end
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      if lv == 1 then
        return data_FuncEquipCtrl[313].items
      elseif lv == 2 then
        return data_FuncEquipCtrl[323].items
      end
    elseif largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      return data_FuncEquipCtrl[603].items
    end
  end
  return {}
end
function data_getHuiLuItemMoney(itemTypeId)
  local largeType = GetItemTypeByItemTypeId(itemTypeId)
  if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
    return data_FuncEquipCtrl[701].money
  elseif largeType == ITEM_LARGE_TYPE_XIANQI then
    return data_FuncEquipCtrl[702].money
  end
  return 0
end
function data_getHuiLuItemList(itemTypeId)
  local largeType = GetItemTypeByItemTypeId(itemTypeId)
  if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
    return data_FuncEquipCtrl[701].items
  elseif largeType == ITEM_LARGE_TYPE_XIANQI then
    return data_FuncEquipCtrl[702].items
  end
  return {}
end
function data_getZhuanHuanMoney(itemTypeId)
  local largeType = GetItemTypeByItemTypeId(itemTypeId)
  if largeType == ITEM_LARGE_TYPE_XIANQI then
    return data_FuncEquipCtrl[703].money
  end
  return 0
end
function data_getZhuanHuanItemList(itemTypeId)
  local largeType = GetItemTypeByItemTypeId(itemTypeId)
  if largeType == ITEM_LARGE_TYPE_XIANQI then
    return data_FuncEquipCtrl[703].items
  end
  return {}
end
function data_getEnhanceEquipNeedQHF(mainHeroType, bsType)
  if bsType == nil then
    return nil
  end
  local roleData = data_getRoleData(mainHeroType)
  local race = roleData.RACE or RACE_REN
  local gender = roleData.GENDER or HERO_MALE
  if data_EnhanceEquipNeedQHF[race] and data_EnhanceEquipNeedQHF[race].render[gender] and data_EnhanceEquipNeedQHF[race].render[gender].color[bsType % 10] then
    return data_EnhanceEquipNeedQHF[race].render[gender].color[bsType % 10].itemid
  end
  return nil
end
function data_getQHFColor(itemID)
  local pairs = pairs
  for _, data1 in pairs(data_EnhanceEquipNeedQHF) do
    for _, data2 in pairs(data1.render) do
      for color, data3 in pairs(data2.color) do
        if data3.itemid == itemID then
          return color
        end
      end
    end
  end
  return nil
end
function data_getLianhuaText(posType, levelType)
  local text = ""
  for _, data in ipairs(data_UpgradeAndRefinery) do
    if posType == data.no and levelType == data.type then
      local max = data.max
      local proList = data.proList or {}
      local firstPro = proList[1] or ""
      local tempType = Pro_Value_NUM_TYPE
      for _, data in pairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
        if data[1] == firstPro then
          tempType = data[3]
          break
        end
      end
      local minStr = ""
      if firstPro == ITEM_PRO_EQPT_LH_LVLIMIT then
        tempType = Pro_Value_NUM_TYPE
        minStr = "-"
      elseif firstPro == ITEM_PRO_EQPT_LH_PROLIMIT then
        tempType = Pro_Value_PERCENT_TYPE
        minStr = "-"
      end
      if tempType == Pro_Value_NUM_TYPE then
        if max ~= 0 then
          text = string.format("%s%s %d-%d\n", text, data.proName or "", data.min or 0, data.max or 0)
        else
          text = string.format("%s%s %s%d\n", text, data.proName or "", minStr, data.min or 0)
        end
      elseif tempType == Pro_Value_PERCENT_TYPE then
        if max ~= 0 then
          text = string.format("%s%s %s%%-%s%%\n", text, data.proName or "", (data.min or 0) * 100, (data.max or 0) * 100)
        else
          text = string.format("%s%s %s%s%%\n", text, data.proName or "", minStr, (data.min or 0) * 100)
        end
      end
    end
  end
  return text
end
function data_getLianhuaValueMinValueAndMaxValue(posType, levelType, proName)
  local minDef = 0
  local maxDef = 1
  local text = ""
  for _, data in ipairs(data_UpgradeAndRefinery) do
    if posType == data.no and levelType == data.type then
      local proList = data.proList or {}
      for _, tempProName in pairs(proList) do
        if proName == tempProName then
          local max = data.max
          if max == 0 then
            return minDef, maxDef
          end
          minDef = data.min or 0
          maxDef = data.max or 1
          return minDef, maxDef
        end
      end
    end
  end
  return minDef, maxDef
end
function data_getUpgradeEquipNeedJZ(mainHeroType, lv)
  local roleData = data_getRoleData(mainHeroType)
  local race = roleData.RACE or RACE_REN
  local gender = roleData.GENDER or HERO_MALE
  if data_UpgradeEquipNeedJZ[race] and data_UpgradeEquipNeedJZ[race].render[gender] and data_UpgradeEquipNeedJZ[race].render[gender].elv[lv] then
    return data_UpgradeEquipNeedJZ[race].render[gender].elv[lv].itemid
  end
  return nil
end
function data_getUpgradeXqNeedJZ(mainHeroType, lv)
  local roleData = data_getRoleData(mainHeroType)
  local race = roleData.RACE or RACE_REN
  local gender = roleData.GENDER or HERO_MALE
  if data_UpgradeXqNeedJZ[race] and data_UpgradeXqNeedJZ[race].render[gender] and data_UpgradeXqNeedJZ[race].render[gender].elv[lv] then
    return data_UpgradeXqNeedJZ[race].render[gender].elv[lv].itemid
  end
  return nil
end
function data_getIsXianQiJZ(itemId)
  for _, t in pairs(XIANQI_ZB_JZ_List) do
    if itemId == t then
      return true
    end
  end
  return false
end
function data_getIsGaoJiZBJZ(itemId)
  for _, t in pairs(GAOJI_ZB_JZ_List) do
    if itemId == t then
      return true
    end
  end
  return false
end
function data_getIsQHF(itemId)
  for _, t in pairs(QIANGHUAFU_List) do
    if itemId == t then
      return true
    end
  end
  return false
end
function data_getCZBD_ItemCanJumpInWar(itemId)
  local flag = false
  if data_Chengzhangbd[itemId] ~= nil then
    flag = data_Chengzhangbd[itemId].canJumpInWar == 0
  end
  return flag
end
function data_getCZBD_ItemCanJumpAsTeamer(itemId)
  local flag = false
  if data_Chengzhangbd[itemId] ~= nil then
    flag = data_Chengzhangbd[itemId].canJumpAsTeamer == 0
  end
  return flag
end
function data_getBangpaiMemberMaxNum(bplv)
  local bpData = data_Org_Upgrade[bplv]
  if bpData == nil then
    return 0
  else
    return bpData.Limit
  end
end
function data_getBangpaiConstructMaxNum(bplv)
  if bplv > 5 then
    bplv = 5
  end
  local bpData = data_Org_Upgrade[bplv]
  if bpData == nil then
    return 0
  else
    return bpData.UpgradeCostOrgExp
  end
end
function data_getBangpaiPlaceName(place)
  local bpData = data_Org_Auth[place]
  if bpData == nil then
    return "帮众"
  else
    return bpData.Name
  end
end
function data_getBangpaiPlaceNumLimit(place)
  local bpData = data_Org_Auth[place]
  if bpData == nil then
    return 0
  else
    return bpData.Limit
  end
end
function data_getBangPaiPlaceDesc(place)
  local bpData = data_Org_Auth[place]
  if bpData == nil then
    return ""
  else
    return bpData.PlaceDesc
  end
end
function data_getTotemName(totemId)
  local totemData = data_Org_TotemTask[totemId]
  if totemData == nil then
    return ""
  else
    return totemData.totemName
  end
end
function data_getTotemMonsterNameAndPos(totemId)
  local totemData = data_Org_TotemTask[totemId]
  if totemData == nil then
    return ""
  else
    return totemData.Name
  end
end
function data_getHuodongName(huodongId)
  local huodongData = data_Org_Huodong[huodongId]
  if huodongData == nil then
    return ""
  else
    return huodongData.Name
  end
end
function data_getHuodongDesc(huodongId)
  local huodongData = data_Org_Huodong[huodongId]
  if huodongData == nil then
    return ""
  else
    return huodongData.Desc
  end
end
function data_getHuodongJumpNpc(huodongId)
  local huodongData = data_Org_Huodong[huodongId]
  if huodongData == nil then
    return nil
  else
    return huodongData.JumpNpc
  end
end
function data_getFuliName(fuliId)
  local fuliData = data_Org_Fuli[fuliId]
  if fuliData == nil then
    return ""
  else
    return fuliData.Name
  end
end
function data_getFuliDesc(fuliId)
  local fuliData = data_Org_Fuli[fuliId]
  if fuliData == nil then
    return ""
  else
    return fuliData.Desc
  end
end
function data_getVIPNeedGold(vipIndex)
  local maxVIP = data_getMaxVIPLv()
  if vipIndex > maxVIP then
    vipIndex = maxVIP
  end
  local tempData = data_VIPData[vipIndex + 1]
  if tempData == nil then
    return 0
  else
    return tempData.NeedGoldNum
  end
end
function data_getVIPDes(vipIndex)
  local maxVIP = data_getMaxVIPLv()
  if vipIndex > maxVIP then
    vipIndex = maxVIP
  end
  local tempData = data_VIPData[vipIndex + 1]
  if tempData == nil then
    return ""
  else
    return tempData.Des
  end
end
function data_getMaxBuyBWCNum()
  local maxVIPLv = data_getMaxVIPLv()
  return data_VIPData[maxVIPLv + 1].BuyBWCNum
end
function data_getCurBuyBWCNumByVIP(vipIndex)
  local maxVIP = data_getMaxVIPLv()
  if vipIndex > maxVIP then
    vipIndex = maxVIP
  end
  local tempData = data_VIPData[vipIndex + 1]
  if tempData == nil then
    return 0
  else
    return tempData.BuyBWCNum
  end
end
function data_getBuyBWCPrice(buyBWCNum)
  local price = data_VIPBuyBWC[#data_VIPBuyBWC].price
  if data_VIPBuyBWC[buyBWCNum] and data_VIPBuyBWC[buyBWCNum].price then
    price = data_VIPBuyBWC[buyBWCNum].price
  end
  return price
end
function data_getCanBuyBWCNumVipLv()
  local maxVIP = data_getMaxVIPLv()
  for i = 0, maxVIP do
    if 0 < data_getCurBuyBWCNumByVIP(i) then
      return i
    end
  end
  return maxVIP
end
function data_getCanResetCatchVipLv()
  local minVip = 999
  for _, data in pairs(data_VIPData) do
    if data.CanResetCatch > 0 and minVip > data.VIPLV then
      minVip = data.VIPLV
    end
  end
  return minVip
end
function data_getNeedRanLiaoNum(pos, color)
  local tempData = data_ChangeColor[pos]
  if tempData then
    return tempData[string.format("color%d", color)] or 0
  end
  return 0
end
function data_getRGBRanColor(shapeId, pos, color)
  local index = shapeId * 10 + pos
  local tempData = data_RolePosColorData[index]
  if tempData then
    if not tempData[string.format("color%d", color)] then
      local cData = {
        255,
        255,
        255,
        255
      }
    else
      cData = tempData[string.format("color%d", color)]
    end
    return cData[1], cData[2], cData[3], cData[4]
  end
  return 255, 255, 255, 255
end
function data_getGiftOfIdentifyName(giftTypeId)
  if data_GiftOfIdentify[giftTypeId] then
    return data_GiftOfIdentify[giftTypeId].des
  else
    return "未知礼包"
  end
end
function data_getGiftOfIdentifyReward(giftTypeId)
  if data_GiftOfIdentify[giftTypeId] then
    return data_GiftOfIdentify[giftTypeId].reward
  else
    return {}
  end
end
function data_getGuajiMapIdByFightId(warId)
  local pairs = pairs
  for mapId, info in pairs(data_GuaJi_Map) do
    if info ~= nil then
      local warIndexId = info.warDataId
      local warData = _G[string.format("data_GuaJi_War%d", warIndexId)]
      if warData ~= nil then
        for wId, _ in pairs(warData) do
          if wId == warId then
            return mapId
          end
        end
      end
    end
  end
  return nil
end
function data_getGuajiMapMinRateWarId(mapId)
  local warIndexId = data_GuaJi_Map[mapId].warDataId
  local warData = _G[string.format("data_GuaJi_War%d", warIndexId)]
  if warData == nil then
    return nil
  end
  local minRate = 9999
  local warId
  for wId, info in pairs(warData) do
    if minRate > info.Ratio then
      minRate = info.Ratio
      warId = wId
    end
  end
  return warId
end
function data_getGuajiMapMonsterList(mapId)
  local warIndexId = data_GuaJi_Map[mapId].warDataId
  local warData = _G[string.format("data_GuaJi_War%d", warIndexId)]
  if warData == nil then
    return {}, {}
  end
  local normalList = {}
  local bossList = {}
  local normalFlag = {}
  local bossFlag = {}
  local pairs = pairs
  for wId, _ in pairs(warData) do
    local posList = data_getWarPosList(wId)
    for _, npcId in pairs(posList) do
      if data_getIsNpcBoss(npcId) then
        if bossFlag[npcId] ~= true then
          bossList[#bossList + 1] = npcId
          bossFlag[npcId] = true
        end
      elseif normalFlag[npcId] ~= true then
        normalList[#normalList + 1] = npcId
        normalFlag[npcId] = true
      end
    end
  end
  table.sort(normalList)
  table.sort(bossList)
  return normalList, bossList
end
function data_getIsGuajiMap(mapId)
  for mId, info in pairs(data_GuaJi_Map) do
    if mapId == mId then
      return true
    end
  end
  return false
end
function data_getUnFengYinSkillPosCost(index)
  local num = data_PetSkillPos.UnFenyin[index] or {}
  return num
end
function data_getUnLockSkillPosCost(index)
  local num = data_PetSkillPos.Unlock[index] or {}
  return num
end
function data_getUnFengYinSSSkillPosCost(index)
  return data_getUnFengYinSkillPosCost(index + 6)
end
function data_getUnLockSSSkillPosCost(index)
  return data_getUnLockSkillPosCost(index + 6)
end
function data_getLifeSkillName(sID)
  if data_LifeSkill[sID] ~= nil then
    return data_LifeSkill[sID].Name
  else
    return "未知生活技能"
  end
end
function data_getLifeSkillDesc(sID)
  if data_LifeSkill[sID] ~= nil then
    return data_LifeSkill[sID].Desc
  else
    return "未知生活技能描述"
  end
end
function data_getLifeSkillUpgradeDesc(sID)
  if data_LifeSkill[sID] ~= nil then
    return data_LifeSkill[sID].upgradeDesc
  else
    return "未知生活技能升级描述"
  end
end
function data_getLifeSkillIconPath(sID)
  if data_LifeSkill[sID] ~= nil then
    return string.format("views/lifeskill/lifeskill_icon%d.png", sID)
  else
    return "views/lifeskill/lifeskill_icon1.png"
  end
end
function data_getLifeSkillUpgradeNeedCoin(lv)
  if data_LifeSkill_Upgrade[lv] ~= nil then
    return data_LifeSkill_Upgrade[lv].Coin
  else
    return data_LifeSkill_Upgrade[180].Coin
  end
end
function data_getLifeSkillUpgradeNeedArch(lv)
  if data_LifeSkill_Upgrade[lv] ~= nil then
    return data_LifeSkill_Upgrade[lv].OrgAchievePoint
  else
    return data_LifeSkill_Upgrade[180].OrgAchievePoint
  end
end
function data_getLifeSkillType(iTypeId)
  local typeNum = GetItemTypeByItemTypeId(iTypeId)
  if typeNum == ITEM_LARGE_TYPE_LIFEITEM then
    local tempNum = math.floor(iTypeId / 1000)
    if tempNum == 700 then
      return IETM_DEF_LIFESKILL_DRUG
    elseif tempNum == 702 then
      if data_LifeSkill_Food[iTypeId] == nil then
        return IETM_DEF_LIFESKILL_FOOD
      elseif data_LifeSkill_Food[iTypeId].MainCategoryId == 1 then
        return IETM_DEF_LIFESKILL_FOOD
      else
        return IETM_DEF_LIFESKILL_WINE
      end
    elseif tempNum == 701 then
      return IETM_DEF_LIFESKILL_FUWEN
    end
  else
    return nil
  end
end
function data_getBSDChangeCoin(playerLV, bsd)
  local num = 0
  if data_BaoShiDu_CostCoin[playerLV] == nil then
    num = data_BaoShiDu_CostCoin[LIFESKILL_MAX_BSD].CostCoinPerPoint * bsd
  end
  num = data_BaoShiDu_CostCoin[playerLV].CostCoinPerPoint * bsd
  return math.max(num, 0)
end
function data_getStuffsForLifeItem(itemId)
  local data = GetItemDataByItemTypeId(itemId)
  if data[itemId] ~= nil then
    return data[itemId].NeedItem or {}
  else
    return {}
  end
end
function data_getHuoliForLifeItem(itemId, lifeSkillLV)
  local data = GetItemDataByItemTypeId(itemId)
  if data[itemId] ~= nil then
    local needHL = data[itemId].CostHL or 0
    local needLV = data[itemId].NeedLv or 0
    if lifeSkillLV <= needLV then
      return needHL
    else
      return math.floor(needHL * (100 - (lifeSkillLV - needLV) ^ 0.75) / 100)
    end
  else
    return 0
  end
end
function data_getLifeSkillLvForLifeItem(itemId)
  local data = GetItemDataByItemTypeId(itemId)
  if data[itemId] ~= nil then
    return data[itemId].NeedLv or 0
  else
    return 0
  end
end
function data_getLifeItemWineEff(itemId)
  if itemId == ITEM_DEF_OTHER_JUHUAJIU then
    return "仙法全抗+5%"
  end
  if itemId == ITEM_DEF_OTHER_CHONGYANGGAO then
    return "人法全抗+7%"
  end
  if data_getLifeSkillType(itemId) == IETM_DEF_LIFESKILL_WINE then
    local tDict = {}
    tDict = data_LifeSkill_Food[itemId] and (data_LifeSkill_Food[itemId].AddKX or {})
    local txt = ""
    for k, v in pairs(tDict) do
      if LIFEITEM_WINEADDKANGNAME[k] ~= nil then
        if k == LIFEITEM_WINE_ADDKANGXIXUE_NUMBER then
          txt = string.format("%s%s+%d", txt, LIFEITEM_WINEADDKANGNAME[k], v)
        else
          txt = string.format("%s%s+%d%%", txt, LIFEITEM_WINEADDKANGNAME[k], v)
        end
      end
    end
    return txt
  else
    return "无"
  end
end
function data_getLifeItemFuwenEff(itemId)
  if data_getLifeSkillType(itemId) == IETM_DEF_LIFESKILL_FUWEN then
    local tDict = {}
    tDict = data_LifeSkill_Rune[itemId] and (data_LifeSkill_Rune[itemId].AddFS or {})
    local txt = ""
    for k, v in pairs(tDict) do
      if LIFEITEM_FUWENADDFSNAME[k] ~= nil then
        if k == LIFEITEM_FUWEN_ADDKANGXIXUE_NUMBER then
          txt = string.format("%s%s+%d", txt, LIFEITEM_FUWENADDFSNAME[k], v)
        else
          txt = string.format("%s%s+%d%%", txt, LIFEITEM_FUWENADDFSNAME[k], v)
        end
      end
    end
    return txt
  else
    return "无"
  end
end
function data_getLifeItemFoodEff(itemId)
  if data_getLifeSkillType(itemId) == IETM_DEF_LIFESKILL_FOOD then
    local bsd = 0
    bsd = data_LifeSkill_Food[itemId] and (data_LifeSkill_Food[itemId].AddWarCnt or 0)
    return string.format("饱食度+%d", bsd)
  else
    return "无"
  end
end
function data_getLifeItemDrugEff(itemId)
  if data_getLifeSkillType(itemId) == IETM_DEF_LIFESKILL_DRUG then
    local hp = 0
    local mp = 0
    if data_LifeSkill_Drug[itemId] then
      hp = data_LifeSkill_Drug[itemId].AddHp or 0
      mp = data_LifeSkill_Drug[itemId].AddMp or 0
    end
    local txt = ""
    if hp ~= 0 then
      txt = txt .. string.format("气血+%d ", hp)
    end
    if mp ~= 0 then
      txt = txt .. string.format("法力+%d", mp)
    end
    if txt == "" then
      return "无"
    end
    return txt
  else
    return "无"
  end
end
function data_getLifeItemFuwenEffDict(itemId)
  if data_getLifeSkillType(itemId) == IETM_DEF_LIFESKILL_FUWEN then
    local tDict = {}
    tDict = data_LifeSkill_Rune[itemId] and (data_LifeSkill_Rune[itemId].AddFS or {})
    local returnDict = {}
    for k, v in pairs(tDict) do
      if LIFEITEM_FUWENADDFSNAME_PRO_DICT[k] ~= nil then
        local tempProDict = LIFEITEM_FUWENADDFSNAME_PRO_DICT[k]
        for _, proName in pairs(tempProDict) do
          if k == LIFEITEM_FUWEN_ADDKANGXIXUE_NUMBER then
            returnDict[proName] = v
          else
            returnDict[proName] = v / 100
          end
        end
      end
    end
    return returnDict
  else
    return {}
  end
end
function data_getLifeItemWineEffDict(itemId)
  if itemId == ITEM_DEF_OTHER_JUHUAJIU then
    return {
      [PROPERTY_KFENG] = 0.05,
      [PROPERTY_KHUO] = 0.05,
      [PROPERTY_KSHUI] = 0.05,
      [PROPERTY_KLEI] = 0.05
    }
  end
  if itemId == ITEM_DEF_OTHER_CHONGYANGGAO then
    return {
      [PROPERTY_KHUNLUAN] = 0.07,
      [PROPERTY_KFENGYIN] = 0.07,
      [PROPERTY_KHUNSHUI] = 0.07,
      [PROPERTY_KZHONGDU] = 0.07
    }
  end
  if data_getLifeSkillType(itemId) == IETM_DEF_LIFESKILL_WINE then
    local tDict = {}
    tDict = data_LifeSkill_Food[itemId] and (data_LifeSkill_Food[itemId].AddKX or {})
    local returnDict = {}
    for k, v in pairs(tDict) do
      if LIFEITEM_WINEADDKANGNAME_PRO_DICT[k] ~= nil then
        local tempProDict = LIFEITEM_WINEADDKANGNAME_PRO_DICT[k]
        for _, proName in pairs(tempProDict) do
          if k == LIFEITEM_WINE_ADDKANGXIXUE_NUMBER then
            returnDict[proName] = v
          else
            returnDict[proName] = v / 100
          end
        end
      end
    end
    return returnDict
  else
    return {}
  end
end
function data_getUpgradeLifeSkillNeedArch(fromLv, toLv)
  if toLv <= fromLv then
    return 0
  end
  local sum = 0
  for lv = fromLv + 1, toLv do
    if data_LifeSkill_Upgrade[lv] then
      sum = sum + (data_LifeSkill_Upgrade[lv].OrgAchievePoint or 0)
    end
  end
  return sum
end
function data_getStuffItemShowCanUseBtn(itemId)
  if data_Stuff[itemId] then
    return data_Stuff[itemId].showuseitem or 0
  else
    return 0
  end
end
function data_getBaitanItemMainType(itemId)
  local tempData = data_Stall[itemId] or 0
  return tempData.MainCategory or 1
end
function data_getBaitanItemSubType(itemId)
  local tempData = data_Stall[itemId] or 0
  return tempData.MinorCategory or 1
end
function data_getHuodongOpenTypeName(hdId)
  local data = data_HuodongOpenType[hdId]
  if data == nil then
    return ""
  else
    return data.Name
  end
end
function data_getHuodongOpenTypeScheduleName(hdId)
  local data = data_HuodongOpenType[hdId]
  if data == nil then
    return ""
  else
    return data.sName
  end
end
function data_getHuodongOpenTypeDesc(hdId)
  local data = data_HuodongOpenType[hdId]
  if data == nil then
    return ""
  else
    return data.Desc
  end
end
function data_getStallMenuData()
  local resultTable = {}
  for GoodId, v in pairs(data_Stall) do
    if v ~= nil and type(v) == "table" then
      if resultTable[v.MainCategory] == nil and v.MainCategoryName ~= nil then
        resultTable[v.MainCategory] = {}
        resultTable[v.MainCategory].MainCategoryName = v.MainCategoryName
        resultTable[v.MainCategory].secondList = {}
        resultTable[v.MainCategory].secondList[v.MinorCategory] = {
          MinorCategoryName = v.MinorCategoryName
        }
        resultTable[v.MainCategory].secondList[v.MinorCategory].MinorCategoryID = v.MinorCategory
        resultTable[v.MainCategory].secondList[v.MinorCategory].GoodId = GoodId
      elseif resultTable[v.MainCategory] ~= nil and v.MainCategoryName ~= nil then
        if resultTable[v.MainCategory].MainCategoryName == nil then
          resultTable[v.MainCategory].MainCategoryName = v.MainCategoryName
        end
        if resultTable[v.MainCategory].secondList == nil then
          resultTable[v.MainCategory].secondList = {}
        end
        if resultTable[v.MainCategory].secondList[v.MinorCategory] == nil then
          resultTable[v.MainCategory].secondList[v.MinorCategory] = {
            MinorCategoryName = v.MinorCategoryName
          }
          resultTable[v.MainCategory].secondList[v.MinorCategory].MinorCategoryID = v.MinorCategory
          resultTable[v.MainCategory].secondList[v.MinorCategory].GoodId = GoodId
        end
      end
    end
  end
  function sortFun(data1, data2)
    if data1 == nil or data2 == nil then
      return false
    end
    local goodId_1 = data1.GoodId
    local goodId_2 = data2.GoodId
    if goodId_1 == nil or goodId_2 == nil then
      return false
    end
    if goodId_1 < goodId_2 then
      return true
    else
      return false
    end
  end
  for _, tempData in pairs(resultTable) do
    local sortTable = tempData.secondList
    if sortTable ~= nil then
      table.sort(sortTable, sortFun)
    end
  end
  print("FFFFFFFFFFFFFFFFFFFfff")
  print_lua_table(resultTable)
  return resultTable
end
function data_getSkillExpLimitByZsAndLv(zs, lv)
  if data_SkillExpLimit[zs] and data_SkillExpLimit[zs].level and data_SkillExpLimit[zs].level[lv] then
    return data_SkillExpLimit[zs].level[lv].valueLimit
  end
  return nil
end
function data_getSkill_OpenNextSkillValue(step)
  if step == 4 then
    return data_Variables.Hero4StepSkillOpenExp
  elseif step == 5 then
    return data_Variables.Hero5StepSkillOpenExp
  else
    return 0
  end
end
function data_getCatchMonsterType(mapId, catchId)
  if data_Catch[mapId] == nil then
    return nil
  end
  if data_Catch[mapId].catchID[catchId] == nil then
    return nil
  end
  local warId = data_Catch[mapId].catchID[catchId].nWarTypeID
  local typeId, name = data_getBossForWar(warId)
  return typeId
end
function data_getCatchMonsterPos(mapId, catchId)
  if data_Catch[mapId] == nil then
    return {}
  end
  if data_Catch[mapId].catchID[catchId] == nil then
    return {}
  end
  return data_Catch[mapId].catchID[catchId].npcPos
end
function data_getCatchGotoMonsterPos(mapId, catchId)
  if data_Catch[mapId] == nil then
    return {}
  end
  if data_Catch[mapId].catchID[catchId] == nil then
    return {}
  end
  return data_Catch[mapId].catchID[catchId].fromPos
end
function data_getCatchGotoMapId(mapId, catchId)
  if data_Catch[mapId] == nil then
    return nil
  end
  if data_Catch[mapId].catchID[catchId] == nil then
    return nil
  end
  return data_Catch[mapId].catchID[catchId].fromPos[1]
end
function data_getCatchNeedTeamFlag(mapId, catchId)
  if data_Catch[mapId] == nil then
    return false
  end
  if data_Catch[mapId].catchID[catchId] == nil then
    return false
  end
  return data_Catch[mapId].catchID[catchId].teamFlag == 1
end
function data_getAnZhanLimit()
  if data_Variables.AnZhanCircleLimit == nil then
    return 10
  end
  return data_Variables.AnZhanCircleLimit
end
function data_getChongZhiExtraAward(tId)
  return data_ChongZhiExtraAward[tId] or {}
end
function data_getTBSJNPCNameByCircle(cNum)
  local data = data_TianBinShenJiangNpc[cNum] or {}
  return data.NpcId, data.Name
end
function data_getTBSJMapNameByCircle(cNum)
  local data = data_TianBinShenJiangNpc[cNum] or {}
  return data.SceneId, data.SceneName
end
function data_judgeFuncOpen(curZs, curLv, needZs, needLv, alwaysJudgeLvFlag)
  if alwaysJudgeLvFlag == 1 then
    if needZs <= curZs then
      if needLv <= curLv then
        return true
      else
        return false
      end
    else
      return false
    end
  elseif needZs < curZs then
    return true
  elseif curZs == needZs then
    if needLv <= curLv then
      return true
    else
      return false
    end
  else
    return false
  end
end
function data_getMainMissionName(taskId)
  local taskData = data_Mission_Main[taskId]
  if taskData == nil then
    taskData = data_Mission_Guide[taskId]
    if taskData == nil then
      return ""
    else
      return taskData.mnName or ""
    end
  else
    return taskData.mnName or ""
  end
end
function data_getNpcLabelPath(label)
  if label == 0 or label == nil then
    return nil
  end
  local labelPath = string.format("views/npc/npclabel_%d.png", label)
  local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(labelPath)
  if os.exists(fullPath) then
    return labelPath
  else
    return nil
  end
end
function data_getRbChangeCost(zs, num)
  local data = data_RbChangeCost[zs]
  if data == nil then
    return 0
  end
  local maxNum = data.max_num or 0
  local base_money = data.base_money or 0
  if num >= maxNum then
    return maxNum * base_money
  else
    return num * base_money
  end
end
function data_getKeZhiXiuZhengCoeff(attType)
  local data = data_WuxingWarData[attType]
  if data == nil then
    return 0, 0
  end
  local kzCoeff = data.xzValue or 0
  local qkzCoeff = data.qkxzValue or 0
  return kzCoeff, qkzCoeff
end
function data_getMonsterKeZhiXiuZhengCoeff(tarType)
  if tarType == LOGICTYPE_MONSTER then
    return data_WuxingOtherWarData[1].value, data_WuxingOtherWarData[2].value
  else
    return 1, 1
  end
end
function data_getTuijianAddPointData(index)
  local tempDict = {}
  for num, data in pairs(data_TuijianAddPoint) do
    if data.heroType == index then
      tempDict[num] = data
    end
  end
  return tempDict
end
function data_getPetTypeIsNormalShou(petType)
  if data_getPetLevelType(petType) == Pet_LevelType_Normal then
    return true
  end
  return false
end
function data_getPetTypeIsLingShou(petType)
  if data_getPetLevelType(petType) == Pet_LevelType_Senior then
    return true
  end
  return false
end
function data_getPetTypeIsShenShou(petType)
  if data_getPetLevelType(petType) == Pet_LevelType_SS then
    return true
  end
  return false
end
function data_getPetTypeIsGaoJiShouHu(petType)
  if data_getPetLevelType(petType) == Pet_LevelType_GJSH then
    return true
  end
  return false
end
function data_getPetTypeIsTeShuShenShou(petType)
  if data_getPetLevelType(petType) == Pet_LevelType_TSSS then
    return true
  end
  return false
end
function data_getPetTypeIsHasShenShouSkill(petType)
  if data_getPetLevelType(petType) == Pet_LevelType_TSSS then
    return true
  elseif data_getPetLevelType(petType) == Pet_LevelType_SS then
    return true
  end
  return false
end
function data_getPetTypeIsCanHuaJing(petType)
  if data_getPetLevelType(petType) == Pet_LevelType_TSSS then
    return true
  elseif data_getPetLevelType(petType) == Pet_LevelType_SS then
    return true
  end
  return false
end
function data_getPetTypeIsCanHuaLing(petType)
  if data_getPetLevelType(petType) == Pet_LevelType_Senior then
    return true
  end
  return false
end
