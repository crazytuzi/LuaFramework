if not ZhuangBeiData then
  ZhuangBeiData = {}
end
function ZhuangBeiData.extend(object)
  object.zhuangbei = {}
  function object:addZhuangBei(zhuangbeiId)
    object.zhuangbei[zhuangbeiId] = false
    if WAR_CODE_IS_SERVER ~= true then
      object:CalculateProperty()
    else
    end
  end
  function object:delZhuangBei(zhuangbeiId)
    if object.zhuangbei[zhuangbeiId] ~= nil then
      object.zhuangbei[zhuangbeiId] = nil
    else
      printLogDebug("zhuangbei", "没有装备:%d，还要减少装备", zhuangbeiId)
      object.zhuangbei[zhuangbeiId] = nil
    end
    object:CalculateProperty()
  end
  function object:getZhuangBei()
    return object.zhuangbei
  end
  function object:CheckZhuangBeiCanUse()
    local newD = {}
    local playerId = object:getPlayerId()
    local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
    if object:getType() == LOGICTYPE_HERO and object == player:getMainHero() then
      local needCheckItemList = {}
      local changeFlag = true
      local checkNum = 0
      for itemId, _ in pairs(object.zhuangbei) do
        object.zhuangbei[itemId] = false
        needCheckItemList[itemId] = true
        checkNum = checkNum + 1
      end
      local pairs = pairs
      while true do
        if checkNum <= 0 or changeFlag == false then
          break
        end
        changeFlag = false
        for itemId, _ in pairs(object.zhuangbei) do
          if object.zhuangbei[itemId] == false and needCheckItemList[itemId] ~= nil and object:CanAddItem(itemId) == true then
            needCheckItemList[itemId] = nil
            object.zhuangbei[itemId] = true
            checkNum = checkNum - 1
            changeFlag = true
          end
        end
      end
    end
    for itemId, _ in pairs(object.zhuangbei) do
      local msg
      if object:getType() == LOGICTYPE_HERO and object ~= player:getMainHero() then
        msg = true
      else
        msg = object:CanAddItem(itemId)
      end
      local flag = true
      if msg ~= true then
        flag = false
      end
      newD[itemId] = flag
    end
    object.zhuangbei = {}
    for itemId, newFlag in pairs(newD) do
      object.zhuangbei[itemId] = newFlag
    end
  end
  function object:GetZhuangBeiAddNum(proName)
    local playerId = object:getPlayerId()
    local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
    local tempList = ZB_ADDPRO_DICT[proName]
    local num = 0
    if tempList ~= nil then
      local pairs = pairs
      for itemId, canUseflag in pairs(object.zhuangbei) do
        if canUseflag == true then
          local itemIns = player:GetOneItem(itemId)
          for _, itemPro in pairs(tempList) do
            local value = itemIns:getProperty(itemPro)
            local bsNum = itemIns:getProperty(ITME_PRO_EQPT_BAOSHINUM)
            if bsNum > 0 and ZB_PRO_BASE_DICT[itemPro] == true then
              value = value * (1 + 0.02 * bsNum)
            end
            num = num + value
          end
        end
      end
    end
    return num
  end
  function object:GetNeidanObj(neidanId)
    local playerId = object:getPlayerId()
    local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
    for itemId, canUseflag in pairs(object.zhuangbei) do
      if canUseflag == true then
        local itemIns = player:GetOneItem(itemId)
        if itemIns and itemIns:getTypeId() == neidanId then
          return itemIns
        end
      end
    end
    return nil
  end
  function object:HasNeidanObj()
    local hasND = 0
    if GetRoleObjType(object:getTypeId()) == LOGICTYPE_PET then
      for ndItemId, _ in pairs(NEIDAN_ITEM_TO_SKILL_TABLE) do
        if object:GetNeidanObj(ndItemId) ~= nil then
          hasND = 1
          break
        end
      end
    end
    return hasND
  end
  function object:GetEqptByPos(posId)
    local playerId = object:getPlayerId()
    local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
    for itemId, _ in pairs(object.zhuangbei) do
      local itemIns = player:GetOneItem(itemId)
      local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
      if EPQT_TYPE_2_EQPT_POS[eqptType] == posId then
        return itemIns
      end
    end
    return nil
  end
  function object:CanAddItemForHuoban(zhuangbeiId)
    local playerId = object:getPlayerId()
    local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
    local itemIns = player:GetOneItem(zhuangbeiId)
    return object:CanAddItemForHuobanWithItemIns(itemIns)
  end
  function object:CanAddItemForHuobanWithItemIns(itemIns)
    return "伙伴不能穿装备"
  end
  function object:CanAddItem(zhuangbeiId)
    local playerId = object:getPlayerId()
    local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
    local itemIns = player:GetOneItem(zhuangbeiId)
    return object:CanAddItemWithItemIns(itemIns)
  end
  function object:CanZhuangbeiZhuanHuan(itemIns)
    if itemIns == nil then
      print("物品为空")
      return false
    end
    local itemLType = itemIns:getType()
    if not CAN_ADD_ITEM_DICT[itemLType] then
      print("类型不是可以装备的物品")
      return false
    end
    local hkind = itemIns:getProperty(ITEM_PRO_EQPT_HKIND)
    if hkind == 0 or hkind == nil then
      hkind = {0}
    end
    local sex = itemIns:getProperty(ITEM_PRO_EQPT_SEX)
    local logicType = object:getType()
    local objType = object:getTypeId()
    local gender = object:getProperty(PROPERTY_GENDER)
    local typeFlag = false
    if object:getType() == LOGICTYPE_PET then
      return false
    elseif object:getType() == LOGICTYPE_HERO then
      if #hkind == 1 and (hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN) then
        if hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET then
          typeFlag = true
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI then
          if object:getProperty(PROPERTY_RACE) == RACE_GUI then
            typeFlag = true
          end
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO then
          if object:getProperty(PROPERTY_RACE) == RACE_MO then
            typeFlag = true
          end
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN then
          if object:getProperty(PROPERTY_RACE) == RACE_XIAN then
            typeFlag = true
          end
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN and object:getProperty(PROPERTY_RACE) == RACE_REN then
          typeFlag = true
        end
      elseif type(hkind) == "table" then
        typeFlag = false
        for _, tempTypeid in pairs(hkind) do
          if tempTypeid == objType then
            typeFlag = true
            break
          end
        end
      end
      local sexFlag = false
      if sex == ITEM_DEF_EQPT_SEX_ALL then
        sexFlag = true
      elseif sex == ITEM_DEF_EQPT_SEX_MALE then
        sexFlag = gender == HERO_MALE
      elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
        sexFlag = gender == HERO_FEMALE
      end
      if sexFlag and typeFlag then
        return true
      else
        return false
      end
    else
      print("角色不是英雄也不是召唤兽，不能装备物品")
      return false
    end
  end
  function object:CanZhuangbeiHuiLu(itemIns)
    if itemIns == nil then
      return false
    end
    local itemLType = itemIns:getType()
    if not CAN_ADD_ITEM_DICT[itemLType] then
      return false
    end
    local hkind = itemIns:getProperty(ITEM_PRO_EQPT_HKIND)
    if hkind == 0 or hkind == nil then
      hkind = {0}
    end
    local sex = itemIns:getProperty(ITEM_PRO_EQPT_SEX)
    local logicType = object:getType()
    local objType = object:getTypeId()
    local gender = object:getProperty(PROPERTY_GENDER)
    if object:getType() == LOGICTYPE_PET then
      return false
    elseif object:getType() == LOGICTYPE_HERO then
      local typeFlag = false
      if #hkind == 1 and (hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN) then
        if hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET then
          typeFlag = true
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI then
          if object:getProperty(PROPERTY_RACE) == RACE_GUI then
            typeFlag = true
          end
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO then
          if object:getProperty(PROPERTY_RACE) == RACE_MO then
            typeFlag = true
          end
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN then
          if object:getProperty(PROPERTY_RACE) == RACE_XIAN then
            typeFlag = true
          end
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN and object:getProperty(PROPERTY_RACE) == RACE_REN then
          typeFlag = true
        end
      elseif type(hkind) == "table" then
        typeFlag = false
        for _, tempTypeid in pairs(hkind) do
          if tempTypeid == objType then
            typeFlag = true
            break
          end
        end
      end
      if not typeFlag then
        return true
      end
      local sexFlag = false
      if sex == ITEM_DEF_EQPT_SEX_ALL then
        sexFlag = true
      elseif sex == ITEM_DEF_EQPT_SEX_MALE then
        sexFlag = gender == HERO_MALE
      elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
        sexFlag = gender == HERO_FEMALE
      end
      if not sexFlag then
        return true
      end
    else
      return false
    end
    return false
  end
  function object:CanAddItemWithItemIns(itemIns)
    if itemIns == nil then
      print("物品为空")
      return "物品为空"
    end
    local itemLType = itemIns:getType()
    if not CAN_ADD_ITEM_DICT[itemLType] then
      print("类型不是可以装备的物品")
      return "类型不是可以装备的物品"
    end
    local hkind = itemIns:getProperty(ITEM_PRO_EQPT_HKIND)
    if hkind == 0 or hkind == nil then
      hkind = {0}
    end
    local sex = itemIns:getProperty(ITEM_PRO_EQPT_SEX)
    local logicType = object:getType()
    local objType = object:getTypeId()
    local gender = object:getProperty(PROPERTY_GENDER)
    if object:getType() == LOGICTYPE_PET then
      local typeFlag = false
      if #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET then
        typeFlag = true
      elseif type(hkind) == "table" then
        typeFlag = false
        for _, tempTypeid in pairs(hkind) do
          if tempTypeid == objType then
            typeFlag = true
            break
          end
        end
      end
      if not typeFlag then
        print("召唤兽类型不对")
        return "召唤兽类型不对"
      end
    elseif object:getType() == LOGICTYPE_HERO then
      local typeFlag = false
      if #hkind == 1 and (hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN) then
        if hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET then
          typeFlag = true
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI then
          if object:getProperty(PROPERTY_RACE) == RACE_GUI then
            typeFlag = true
          end
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO then
          if object:getProperty(PROPERTY_RACE) == RACE_MO then
            typeFlag = true
          end
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN then
          if object:getProperty(PROPERTY_RACE) == RACE_XIAN then
            typeFlag = true
          end
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN and object:getProperty(PROPERTY_RACE) == RACE_REN then
          typeFlag = true
        end
      elseif type(hkind) == "table" then
        typeFlag = false
        for _, tempTypeid in pairs(hkind) do
          if tempTypeid == objType then
            typeFlag = true
            break
          end
        end
      end
      if not typeFlag then
        print("英雄类型不对")
        return "英雄类型不对"
      end
      local sexFlag = false
      if sex == ITEM_DEF_EQPT_SEX_ALL then
        sexFlag = true
      elseif sex == ITEM_DEF_EQPT_SEX_MALE then
        sexFlag = gender == HERO_MALE
      elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
        sexFlag = gender == HERO_FEMALE
      end
      if not sexFlag then
        print("英雄性别不对")
        return "英雄性别不对"
      end
    else
      print("角色不是英雄也不是召唤兽，不能装备物品")
      return "角色不是英雄也不是召唤兽，不能装备物品"
    end
    if object:getProperty(PROPERTY_OGenGu) + object:GetZhuangBeiAddNum(PROPERTY_GenGu) + object:getProperty(PROPERTY_Wing_GenGu) < itemIns:getProperty(ITEM_PRO_EQPT_NEEDGG) * (1 - itemIns:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)) then
      return "根骨不足"
    end
    if object:getProperty(PROPERTY_OLingxing) + object:GetZhuangBeiAddNum(PROPERTY_Lingxing) + object:getProperty(PROPERTY_Wing_Lingxing) < itemIns:getProperty(ITEM_PRO_EQPT_NEEDLX) * (1 - itemIns:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)) then
      return "灵性不足"
    end
    if object:getProperty(PROPERTY_OLiLiang) + object:GetZhuangBeiAddNum(PROPERTY_LiLiang) + object:getProperty(PROPERTY_Wing_LiLiang) < itemIns:getProperty(ITEM_PRO_EQPT_NEEDLL) * (1 - itemIns:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)) then
      return "力量不足"
    end
    if object:getProperty(PROPERTY_OMinJie) + object:GetZhuangBeiAddNum(PROPERTY_MinJie) + object:getProperty(PROPERTY_Wing_MinJie) < itemIns:getProperty(ITEM_PRO_EQPT_NEEDMJ) * (1 - itemIns:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)) then
      return "敏捷不足"
    end
    if itemLType == ITEM_LARGE_TYPE_EQPT or itemLType == ITEM_LARGE_TYPE_XIANQI or itemLType == ITEM_LARGE_TYPE_SENIOREQPT then
      if object:getProperty(PROPERTY_ZHUANSHENG) < itemIns:getProperty(ITEM_PRO_EQPT_ZSLIMIT) then
        print("转生要求不足")
        return "转生要求不足"
      elseif object:getProperty(PROPERTY_ZHUANSHENG) == itemIns:getProperty(ITEM_PRO_EQPT_ZSLIMIT) and object:getProperty(PROPERTY_ROLELEVEL) < itemIns:getProperty(ITEM_PRO_EQPT_LVLIMIT) - itemIns:getProperty(ITEM_PRO_EQPT_LH_LVLIMIT) then
        print("等级要求不足")
        return "等级要求不足"
      end
    elseif itemLType == ITEM_LARGE_TYPE_NEIDAN then
    end
    return true
  end
  function object:CanUpgradeItem(zhuangbeiId)
    local playerId = object:getPlayerId()
    local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
    local itemIns = player:GetOneItem(zhuangbeiId)
    if itemIns == nil then
      return false
    end
    local itemLType = itemIns:getType()
    if itemLType == ITEM_LARGE_TYPE_EQPT or itemLType == ITEM_LARGE_TYPE_XIANQI or itemLType == ITEM_LARGE_TYPE_SENIOREQPT then
      local curItemLv = itemIns:getProperty(ITEM_PRO_LV)
      if itemLType == ITEM_LARGE_TYPE_EQPT then
        return false
      end
      if itemLType == ITEM_LARGE_TYPE_XIANQI and curItemLv >= ITEM_LARGE_TYPE_XIANQI_MaxLv then
        return false
      end
      if itemLType == ITEM_LARGE_TYPE_SENIOREQPT and curItemLv >= ITEM_LARGE_TYPE_SENIOREQPT_MaxLv then
        return false
      end
      local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
      if eqptType == ITEM_DEF_EQPT_WEAPON_CHIBANG then
        return false
      end
      local shape = itemIns:getTypeId()
      local nextShape = shape + 1
      local zs = object:getProperty(PROPERTY_ZHUANSHENG)
      local lv = object:getProperty(PROPERTY_ROLELEVEL)
      local nextLv = data_getItemLvLimit(nextShape)
      local nextZs = data_getItemZsLimit(nextShape)
      if zs < nextZs or nextZs == zs and lv < nextLv then
        return false
      else
        return true
      end
    end
    return false
  end
  function object:CanChiBangAddPoint()
    local playerId = object:getPlayerId()
    local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
    local itemIns = object:GetEqptByPos(ITEM_DEF_EQPT_POS_CHIBANG)
    if itemIns == nil then
      return false
    end
    local addFlag = false
    for _, proName in pairs({
      PROPERTY_Wing_GenGu,
      PROPERTY_Wing_Lingxing,
      PROPERTY_Wing_LiLiang,
      PROPERTY_Wing_MinJie
    }) do
      if object:getProperty(proName) ~= 0 and object:getProperty(proName) ~= nil then
        addFlag = true
        break
      end
    end
    if addFlag then
      return false
    else
      return true
    end
  end
  function object:getZhuangBeiSerialization()
    local cloneZhuangBei = {}
    for k, v in pairs(object.zhuangbei) do
      cloneZhuangBei[k] = v
    end
    return cloneZhuangBei
  end
  function object:setZhuangBeiSerialization(proSerialization, calculateFlag)
    if calculateFlag == nil then
      calculateFlag = true
    end
    object.zhuangbei = {}
    if proSerialization then
      for zhuangbeiId, canUseFlag in pairs(proSerialization) do
        object.zhuangbei[zhuangbeiId] = canUseFlag
      end
      if calculateFlag then
        object:CalculateProperty()
      end
    end
  end
end
