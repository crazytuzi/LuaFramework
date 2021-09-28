DEF_TISHENG_RoleAttrPoint = 1
DEF_TISHENG_AddSkillExp = 2
DEF_TISHENG_AddEqpt = 3
DEF_TISHENG_UpdateEqpt = 4
DEF_TISHENG_LianhuaEqpt = 5
DEF_TISHENG_GetFreeFriend = 6
DEF_TISHENG_AddFriendToWar = 7
DEF_TISHENG_PetForWar = 10
DEF_TISHENG_PetAttrPoint = 11
DEF_TISHENG_PetAddNeidang = 12
DEF_TISHENG_GetZuoQi = 13
DEF_TISHENG_ZuoQiManagePet = 14
DEF_TISHENG_ZuoQiSkill = 15
DEF_TISHENG_FreeBiwu = 16
DEF_TISHENG_LevelGift = 17
DEF_TISHENG_LoginGift = 18
DEF_TISHENG_XiangShi = 19
DEF_TISHENG_ChuYaoAward = 20
DEF_TISHENG_ChangePet = 21
DEF_TISHENG_AddNeidangExp = 22
DEF_TISHENG_LiaoYao = 23
DEF_TISHENG_XiChong = 24
DEF_TISHENG_OnLineGift = 25
DEF_TISHENG_CreateSEqpt = 26
DEF_TISHENG_CreateXianqi = 27
DEF_TISHENG_QianghuaEqpt = 28
DEF_TISHENG_HuobanAttrPoint = 29
DEF_TISHENG_ChengZhangBD = 30
DEF_TISHENG_PetZhuangsheng = 31
DEF_TISHENG_ChiBangAddPoint = 32
DEF_TISHENG_ZuoqiAddSkill = 33
DEF_TISHENG_ZuoqiUpgradeLv = 34
DEF_TISHENG_DianhuaZuoqi = 35
DEF_TISHENG_XunyangPet = 36
DEF_TISHENG_GetLinWuSkill = 37
DEF_TISHENG_HuoLiMax = 38
DEF_TISHENG_BoxSuiPian = 39
function ShowTishengBoard()
  if g_CMainMenuHandler then
    g_CMainMenuHandler:ShowTishengBoard()
  end
end
function UpdateTishengBoard()
  print("UpdateTishengBoard--->")
  if g_CMainMenuHandler then
    g_CMainMenuHandler:UpdateTishengBoard()
  end
  if g_WarLoseResultIns then
    g_WarLoseResultIns:UpdateTishengBoard()
  end
end
function CloseTishengBoard()
  if g_CMainMenuHandler then
    g_CMainMenuHandler:CloseTishengBoard()
  end
end
function GetTishengList()
  local list = {}
  if g_CTiShengMgr then
    list = g_CTiShengMgr:GetTishengList()
  end
  return list
end
function GetWarTishengList()
  local list = {}
  if g_CTiShengMgr then
    list = g_CTiShengMgr:GetWarTishengList()
  end
  return list
end
function NeedToTiSheng(tsType)
  local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
  local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
  local tishengTableData = data_Tisheng[tsType]
  if tishengTableData == nil then
    return false
  end
  if data_judgeFuncOpen(zs, lv, tishengTableData.zs, tishengTableData.lv, tishengTableData.AlwaysJudgeLvFlag) == false then
    return false
  end
  if tsType == DEF_TISHENG_RoleAttrPoint then
    local ins = g_LocalPlayer:getMainHero()
    if ins ~= nil then
      local freeP = ins:getProperty(PROPERTY_FREEPOINT)
      if freeP > 0 then
        return true
      end
    end
  elseif tsType == DEF_TISHENG_ChengZhangBD then
    return true
  elseif tsType == DEF_TISHENG_PetZhuangsheng then
    local petList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
    for _, petId in pairs(petList) do
      local petIns = g_LocalPlayer:getObjById(petId)
      if petIns ~= nil then
        local heroZs = zs
        local petZs = petIns:getProperty(PROPERTY_ZHUANSHENG)
        local petLv = petIns:getProperty(PROPERTY_ROLELEVEL)
        local close = petIns:getProperty(PROPERTY_CLOSEVALUE)
        if petZs < 3 and heroZs > petZs and petLv >= data_getMaxPetLevel(petZs) and close >= data_getPetNeedClose(petZs + 1) then
          return true
        end
      end
    end
    return false
  elseif tsType == DEF_TISHENG_ChiBangAddPoint then
    local mainHero = g_LocalPlayer:getMainHero()
    if mainHero:CanChiBangAddPoint() then
      return true
    end
    return false
  elseif tsType == DEF_TISHENG_HuobanAttrPoint then
    return false
  elseif tsType == DEF_TISHENG_PetAttrPoint then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPet = tempHero:getProperty(PROPERTY_PETID)
      if tempPet ~= nil and tempPet ~= 0 then
        local ins = g_LocalPlayer:getObjById(tempPet)
        local freeP = ins:getProperty(PROPERTY_FREEPOINT)
        if freeP > 0 then
          return {tempPet}
        end
      end
    end
  elseif tsType == DEF_TISHENG_PetAddNeidang then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPetId = tempHero:getProperty(PROPERTY_PETID)
      if tempPetId ~= nil and tempPetId ~= 0 then
        local petObj = g_LocalPlayer:getObjById(tempPetId)
        if petObj ~= nil then
          local zs = petObj:getProperty(PROPERTY_ZHUANSHENG)
          local ndLimit = CalculatePetNeidanLimit(zs)
          local zbList = petObj:getZhuangBei()
          local ndNum = 0
          local ndItemId
          local itemIds = g_LocalPlayer:GetItemTypeList(ITEM_LARGE_TYPE_NEIDAN)
          for i, itemId in ipairs(itemIds) do
            if g_LocalPlayer:GetRoleIdFromItem(itemId) == nil then
              local ndObj = g_LocalPlayer:GetOneItem(itemId)
              if ndObj ~= nil and petObj:GetNeidanObj(ndObj:getTypeId()) == nil then
                ndItemId = itemId
                break
              end
            end
          end
          for itemId, _ in pairs(zbList) do
            local itemIns = g_LocalPlayer:GetOneItem(itemId)
            if itemIns and itemIns:getType() == ITEM_LARGE_TYPE_NEIDAN then
              ndNum = ndNum + 1
            end
          end
          if ndLimit > ndNum and ndItemId ~= nil then
            return {tempPetId, ndItemId}
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_AddNeidangExp then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPetId = tempHero:getProperty(PROPERTY_PETID)
      if tempPetId ~= nil and tempPetId ~= 0 then
        local petObj = g_LocalPlayer:getObjById(tempPetId)
        if petObj ~= nil then
          local zbList = petObj:getZhuangBei()
          for itemId, _ in pairs(zbList) do
            local itemIns = g_LocalPlayer:GetOneItem(itemId)
            local ndLv = itemIns:getProperty(ITEM_PRO_LV)
            local ndZs = itemIns:getProperty(ITEM_PRO_NEIDAN_ZS)
            if itemIns and itemIns:getType() == ITEM_LARGE_TYPE_NEIDAN then
              local roleExp = petObj:getProperty(PROPERTY_EXP)
              local zs = petObj:getProperty(PROPERTY_ZHUANSHENG)
              local lv = petObj:getProperty(PROPERTY_ROLELEVEL)
              local myCoin = g_LocalPlayer:getCoin()
              local temp = data_ndLvupCondtion[ndLv + 1]
              if temp ~= nil then
                local lvupcost = temp[string.format("rb%d", ndZs)]
                if lvupcost ~= nil then
                  lvupcost = math.floor(lvupcost)
                  if ndLv < CalculateNeidanLevelLimit(ndZs) and (ndZs < zs or ndZs == zs and ndLv < lv) and myCoin >= lvupcost then
                    return {tempPetId, itemId}
                  end
                end
              end
            end
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_LiaoYao then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPetId = tempHero:getProperty(PROPERTY_PETID)
      if tempPetId ~= nil and tempPetId ~= 0 then
        local petObj = g_LocalPlayer:getObjById(tempPetId)
        if petObj ~= nil then
          local zs = petObj:getProperty(PROPERTY_ZHUANSHENG)
          local maxTimes = CalculatePetLianYaoLimit(zs)
          local curTimes = petObj:getProperty(PROPERTY_LIANYAO_NUM)
          local hasLYS = false
          local itemIds = g_LocalPlayer:GetItemTypeList(ITEM_LARGE_TYPE_LIANYAOSHI)
          for i, itemId in ipairs(itemIds) do
            local itemIns = g_LocalPlayer:GetOneItem(itemId)
            if itemIns:getTypeId() ~= ITEM_DEF_STUFF_WLD then
              hasLYS = true
              break
            end
          end
          if maxTimes > curTimes and hasLYS then
            return {tempPetId}
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_XiChong then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPetId = tempHero:getProperty(PROPERTY_PETID)
      if tempPetId ~= nil and tempPetId ~= 0 then
        local petObj = g_LocalPlayer:getObjById(tempPetId)
        if petObj ~= nil then
          local gjjllNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_GJJLL)
          local lTypeId = petObj:getTypeId()
          local data = data_Pet[lTypeId] or {}
          local needNum = data.XICOST or 1
          if gjjllNum >= needNum then
            return {tempPetId}
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_GetZuoQi then
    local race = g_LocalPlayer:getMainHero():getProperty(PROPERTY_RACE)
    for _, zqId in ipairs({
      ZUOQITYPE_BAIMA,
      ZUOQITYPE_LUOTUO,
      ZUOQITYPE_BAILANG,
      ZUOQITYPE_TUONIAO,
      ZUOQITYPE_DAXIANG
    }) do
      local zqData = data_Zuoqi[zqId]
      if zqData then
        local zqNeedRace = zqData.zqNeedRace
        if zqNeedRace == ZUOQIRACE_ALL or zqNeedRace == race then
          local needZS, needLv = data_getZuoqiUnlockZsAndLevel(zqId)
          if zs > needZS or zs == needZS and lv >= needLv then
            local noGetFlag = true
            local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
            for _, id in pairs(myZuoqiList) do
              local zqIns = g_LocalPlayer:getObjById(id)
              if zqIns and zqIns:getTypeId() == zqId then
                noGetFlag = false
              end
            end
            if noGetFlag then
              return {zqId}
            end
          end
        end
      end
    end
    if Get6ZuoqiObj() == nil then
      local needZS, needLv = data_getZuoqiUnlockZsAndLevel(All_6_ZUOQI_List[1])
      if zs > needZS or zs == needZS and lv >= needLv then
        return {ZUOQITYPE_EMPTY6ZUOQI}
      end
    end
  elseif tsType == DEF_TISHENG_ZuoQiManagePet then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPetId = tempHero:getProperty(PROPERTY_PETID)
      if tempPetId ~= nil and tempPetId ~= 0 then
        local petObj = g_LocalPlayer:getObjById(tempPetId)
        if petObj ~= nil then
          local isManager = false
          local emptyZuoqiList = {}
          local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
          for _, tempZqId in pairs(myZuoqiList) do
            local zqIns = g_LocalPlayer:getObjById(tempZqId)
            if zqIns then
              local petList = zqIns:getProperty(PROPERTY_ZUOQI_PETLIST) or {}
              if petList == 0 then
                petList = {}
              end
              local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
              for _, tPetId in pairs(petList) do
                if tPetId == tempPetId then
                  isManager = true
                end
              end
              local manageLimit = CalculateZuoqiManageLimit(isDh)
              if manageLimit > #petList then
                emptyZuoqiList[#emptyZuoqiList + 1] = zqIns:getTypeId()
              end
            end
          end
          if not isManager and #emptyZuoqiList > 0 then
            function tempSort(a, b)
              if a == nil or b == nil then
                return false
              end
              return b < a
            end
            table.sort(emptyZuoqiList, tempSort)
            return {
              emptyZuoqiList[1]
            }
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_ZuoQiSkill then
    local myArch = g_LocalPlayer:getArch()
    local costArch = CalculateZuoqiSkillPValueCostArch()
    if myArch < costArch then
      return false
    end
    local jumpZuoqiList = {}
    local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
    for _, tempZqId in pairs(myZuoqiList) do
      local zqIns = g_LocalPlayer:getObjById(tempZqId)
      if zqIns then
        local petList = zqIns:getProperty(PROPERTY_ZUOQI_PETLIST) or {}
        if petList == 0 then
          petList = {}
        end
        local pValue = zqIns:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
        local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
        local pValueLimit = CalculateUpgradeZuoqiSkillPValueLimit(isDh)
        local lastUpgradeTime = zqIns:getProperty(PROPERTY_ZUOQI_CDTIME)
        local svrTime = g_DataMgr:getServerTime()
        if pValue < pValueLimit and #petList > 0 and svrTime > lastUpgradeTime + CalculateZuoqiUpgradeCDTime() then
          jumpZuoqiList[#jumpZuoqiList + 1] = zqIns:getTypeId()
        end
      end
    end
    if #jumpZuoqiList > 0 then
      function tempSort(a, b)
        if a == nil or b == nil then
          return false
        end
        return b < a
      end
      table.sort(jumpZuoqiList, tempSort)
      return {
        jumpZuoqiList[1]
      }
    end
  elseif tsType == DEF_TISHENG_PetForWar then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPet = tempHero:getProperty(PROPERTY_PETID)
      if tempPet == nil or tempPet == 0 then
        local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
        if #petIds > 0 then
          return {
            petIds[1]
          }
        end
      end
    end
  elseif tsType == DEF_TISHENG_GetFreeFriend then
    local gold = g_LocalPlayer:getGold()
    local coin = g_LocalPlayer:getCoin()
    for i = 1, MAX_JIUGUAN_FRIEND_HERO_NUM do
      local isOpen = false
      for _, temp in pairs(g_LocalPlayer:getJiuguanOpenList()) do
        if temp == i then
          isOpen = true
          break
        end
      end
      local needZs, needLv, alwaysJudgeLvFlag = data_getJiuguanNeedZsLvData(i)
      local lvEnough = data_judgeFuncOpen(zs, lv, needZs, needLv, alwaysJudgeLvFlag)
      if isOpen == false and coin >= data_getJiuguanCoin(i) and gold >= data_getJiuguanGold(i) and lvEnough then
        return true
      end
    end
  elseif tsType == DEF_TISHENG_FreeBiwu then
    if 0 < g_PvpMgr:getCanFightTimes() then
      return true
    end
  elseif tsType == DEF_TISHENG_LevelGift then
    if gift.levelup:CanGetLevelupReward() then
      return true
    end
  elseif tsType == DEF_TISHENG_LoginGift then
    if gift.checkin:CanTodayCheckIn() then
      return true
    end
  elseif tsType == DEF_TISHENG_XiangShi then
    if activity.keju:getStatus(KejuType_1) == 1 then
      local events = activity.event:getAllEvent()
      local proData = events[10013]
      if proData ~= nil and proData.state == activity.event.Status_CannotRecive then
        return true
      end
    end
  elseif tsType == DEF_TISHENG_ChuYaoAward then
    local cyjzNum = g_LocalPlayer:GetItemNum(ITEM_DEF_STUFF_CYJZ)
    if cyjzNum >= 5 and activity.dayanta:getExchangeTimes() < activity.dayanta:getMaxExchangeTimes() then
      return true
    end
  elseif tsType == DEF_TISHENG_ChangePet then
    local ssspNum = g_LocalPlayer:GetItemNum(ITEM_DEF_STUFF_SSSP)
    local lsspNum = g_LocalPlayer:GetItemNum(ITEM_DEF_STUFF_LSSP)
    local ssType, lsType
    local lTypeList_ls = {}
    local lTypeList_ss = {}
    for petTypeId, data in pairs(data_Pet) do
      if data_getPetTypeIsLingShou(petTypeId) then
        lTypeList_ls[#lTypeList_ls + 1] = petTypeId
      elseif data_getPetTypeIsShenShou(petTypeId) then
        lTypeList_ss[#lTypeList_ss + 1] = petTypeId
      end
    end
    table.sort(lTypeList_ls, _petTypeSortFunc)
    table.sort(lTypeList_ss, _petTypeSortFunc)
    for _, petId in pairs(lTypeList_ss) do
      local data = data_Pet[petId]
      if data and 0 < data.OPENSSP and ssspNum >= data.OPENSSP then
        ssType = petId
        break
      end
    end
    if ssType == nil then
      for _, petId in pairs(lTypeList_ls) do
        local data = data_Pet[petId]
        if data and 0 < data.OPENLSP and lsspNum >= data.OPENLSP then
          lsType = petId
          break
        end
      end
    end
    if ssType then
      return {ssType}
    elseif lsType then
      return {lsType}
    end
  elseif tsType == DEF_TISHENG_AddFriendToWar then
    local warsetting = DeepCopyTable(g_LocalPlayer:getWarSetting())
    local warNum = 0
    local warHIdList = {}
    for _, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      if warsetting[pos] ~= nil then
        warHIdList[#warHIdList + 1] = warsetting[pos]
        warNum = warNum + 1
      end
    end
    if warNum < data_getWarNumLimit(zs, lv) + 1 then
      local heroIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
      for _, hId in pairs(heroIds) do
        local noWarFlag = true
        for _, wHId in pairs(warHIdList) do
          if hId == wHId then
            noWarFlag = false
            break
          end
        end
        if noWarFlag then
          return {hId}
        end
      end
    end
  elseif tsType == DEF_TISHENG_AddSkillExp then
    local heroIns = g_LocalPlayer:getMainHero()
    local skillList = heroIns:getSkills()
    local pLimit = data_getSkillExpLimitByZsAndLv(zs, lv)
    if pLimit == nil then
      pLimit = CalculateSkillProficiency(zs)
      print("9999999999999999999:", pLimit, zs)
    end
    for skillId, skillP in pairs(skillList) do
      if skillP > 0 and skillP < pLimit then
        local needCoin = GetAddSkillExpNeedCoin(skillId, skillP)
        if needCoin <= g_LocalPlayer:getCoin() then
          return {skillId}
        end
      end
    end
  elseif tsType == DEF_TISHENG_AddEqpt then
    for _, largeType in ipairs({
      ITEM_LARGE_TYPE_XIANQI,
      ITEM_LARGE_TYPE_SENIOREQPT,
      ITEM_LARGE_TYPE_EQPT
    }) do
      local itemIds = g_LocalPlayer:GetItemTypeList(largeType)
      for i, itemId in ipairs(itemIds) do
        if g_LocalPlayer:GetRoleIdFromItem(itemId) == nil then
          local obj = g_LocalPlayer:GetOneItem(itemId)
          if obj then
            local eqptType = obj:getProperty(ITEM_PRO_EQPT_TYPE)
            local eqptPos = EPQT_TYPE_2_EQPT_POS[eqptType]
            local tempHero = g_LocalPlayer:getMainHero()
            local msg = tempHero:CanAddItem(itemId)
            local oldObj = tempHero:GetEqptByPos(eqptPos)
            if msg == true then
              if oldObj == nil then
                return {itemId}
              else
                local oldType = oldObj:getType()
                local oldLv = oldObj:getProperty(ITEM_PRO_LV)
                local newType = obj:getType()
                local newLv = obj:getProperty(ITEM_PRO_LV)
                if oldType < newType then
                  return {itemId}
                elseif newType == oldType and oldLv < newLv then
                  return {itemId}
                end
              end
            end
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_UpdateEqpt then
    local warsetting = g_LocalPlayer:getWarSetting()
    for index, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      local hId = warsetting[pos]
      local heroObj = g_LocalPlayer:getObjById(hId)
      if heroObj and g_LocalPlayer:getMainHero() == heroObj then
        for _, tempPos in ipairs({
          ITEM_DEF_EQPT_POS_WUQI,
          ITEM_DEF_EQPT_POS_TOUKUI,
          ITEM_DEF_EQPT_POS_YIFU,
          ITEM_DEF_EQPT_POS_XIEZI,
          ITEM_DEF_EQPT_POS_XIANGLIAN,
          ITEM_DEF_EQPT_POS_YAODAI,
          ITEM_DEF_EQPT_POS_GUANJIAN,
          ITEM_DEF_EQPT_POS_MIANJU,
          ITEM_DEF_EQPT_POS_PIFENG
        }) do
          local itemObj = heroObj:GetEqptByPos(tempPos)
          if itemObj then
            local lv = itemObj:getProperty(ITEM_PRO_LV)
            local largeType = itemObj:getType()
            local shape = itemObj:getTypeId()
            local nextShape = shape + 1
            local mainHero = g_LocalPlayer:getMainHero()
            local mainHeroType = mainHero:getTypeId()
            local needMoney = 0
            local jz
            local isNotMaxLvFlag = false
            if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
              if lv < ITEM_LARGE_TYPE_SENIOREQPT_MaxLv then
                isNotMaxLvFlag = true
                needMoney = data_getUpgradeItemMoney(shape, lv + 1, Eqpt_Upgrade_CreateType)
                jz = data_getUpgradeEquipNeedJZ(mainHeroType, lv + 1)
              end
            elseif largeType == ITEM_LARGE_TYPE_XIANQI and lv < ITEM_LARGE_TYPE_XIANQI_MaxLv then
              isNotMaxLvFlag = true
              needMoney = data_getUpgradeItemMoney(shape, lv + 1, Eqpt_Upgrade_CreateType)
              jz = data_getUpgradeXqNeedJZ(mainHeroType, lv + 1)
            end
            local moneyFlag = needMoney <= g_LocalPlayer:getCoin()
            local cailaiFlag = true
            if jz and 1 > g_LocalPlayer:GetItemNum(jz) then
              cailaiFlag = false
            end
            local tList = data_getUpgradeItemList(shape, lv + 1, Eqpt_Upgrade_CreateType)
            for tType, tNum in pairs(tList) do
              if tNum > g_LocalPlayer:GetItemNum(tType) then
                cailaiFlag = false
              end
            end
            local lvFlag = false
            local zs = heroObj:getProperty(PROPERTY_ZHUANSHENG)
            local lv = heroObj:getProperty(PROPERTY_ROLELEVEL)
            local nextLv = data_getItemLvLimit(nextShape)
            local nextZs = data_getItemZsLimit(nextShape)
            if zs > nextZs or nextZs == zs and lv >= nextLv then
              lvFlag = true
            end
            if isNotMaxLvFlag and moneyFlag and cailaiFlag and lvFlag then
              return {
                hId,
                itemObj:getObjId()
              }
            end
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_LianhuaEqpt then
    local warsetting = g_LocalPlayer:getWarSetting()
    for index, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      local hId = warsetting[pos]
      local heroObj = g_LocalPlayer:getObjById(hId)
      if heroObj then
        for _, tempPos in ipairs({
          ITEM_DEF_EQPT_POS_WUQI,
          ITEM_DEF_EQPT_POS_TOUKUI,
          ITEM_DEF_EQPT_POS_YIFU,
          ITEM_DEF_EQPT_POS_XIEZI,
          ITEM_DEF_EQPT_POS_XIANGLIAN,
          ITEM_DEF_EQPT_POS_YAODAI,
          ITEM_DEF_EQPT_POS_GUANJIAN,
          ITEM_DEF_EQPT_POS_CHIBANG,
          ITEM_DEF_EQPT_POS_MIANJU,
          ITEM_DEF_EQPT_POS_PIFENG
        }) do
          local itemObj = heroObj:GetEqptByPos(tempPos)
          if itemObj then
            local lv = itemObj:getProperty(ITEM_PRO_LV)
            local largeType = itemObj:getType()
            local shape = itemObj:getTypeId()
            local nextShape = shape + 1
            local mainHero = g_LocalPlayer:getMainHero()
            local mainHeroType = mainHero:getTypeId()
            local isNeedLianhua = false
            if largeType == ITEM_LARGE_TYPE_SENIOREQPT or largeType == ITEM_LARGE_TYPE_XIANQI or largeType == ITEM_LARGE_TYPE_EQPT then
              local noLianhua = true
              for _, para in ipairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
                local proName = para[1]
                local tempNum = itemObj:getProperty(proName)
                if tempNum ~= 0 then
                  noLianhua = false
                end
              end
              local lvlimit = itemObj:getProperty(ITEM_PRO_EQPT_LH_LVLIMIT)
              if lvlimit ~= 0 then
                noLianhua = false
              end
              local prolimit = itemObj:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)
              if prolimit ~= 0 then
                noLianhua = false
              end
              if noLianhua == true then
                isNeedLianhua = true
              end
            end
            local needMoney = data_getUpgradeItemMoney(shape, lv, Eqpt_Upgrade_LianhuaType)
            local moneyFlag = needMoney <= g_LocalPlayer:getCoin()
            local cailaiFlag = true
            local tList = data_getUpgradeItemList(shape, lv, Eqpt_Upgrade_LianhuaType)
            for tType, tNum in pairs(tList) do
              if tNum > g_LocalPlayer:GetItemNum(tType) then
                cailaiFlag = false
              end
            end
            if isNeedLianhua and moneyFlag and cailaiFlag then
              return {
                hId,
                itemObj:getObjId()
              }
            end
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_QianghuaEqpt then
    local warsetting = g_LocalPlayer:getWarSetting()
    for index, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      local hId = warsetting[pos]
      local heroObj = g_LocalPlayer:getObjById(hId)
      if heroObj and g_LocalPlayer:getMainHero() == heroObj then
        for _, tempPos in ipairs({
          ITEM_DEF_EQPT_POS_WUQI,
          ITEM_DEF_EQPT_POS_TOUKUI,
          ITEM_DEF_EQPT_POS_YIFU,
          ITEM_DEF_EQPT_POS_XIEZI,
          ITEM_DEF_EQPT_POS_XIANGLIAN,
          ITEM_DEF_EQPT_POS_YAODAI,
          ITEM_DEF_EQPT_POS_GUANJIAN,
          ITEM_DEF_EQPT_POS_CHIBANG,
          ITEM_DEF_EQPT_POS_MIANJU,
          ITEM_DEF_EQPT_POS_PIFENG
        }) do
          local itemObj = heroObj:GetEqptByPos(tempPos)
          if itemObj then
            local lv = itemObj:getProperty(ITEM_PRO_LV)
            local largeType = itemObj:getType()
            local shape = itemObj:getTypeId()
            local nextShape = shape + 1
            local mainHero = g_LocalPlayer:getMainHero()
            local mainHeroType = mainHero:getTypeId()
            local isNeedQianghua = false
            local holeNum = itemObj:getProperty(ITME_PRO_EQPT_HOLENUM)
            local bsNum = itemObj:getProperty(ITME_PRO_EQPT_BAOSHINUM)
            if holeNum ~= nil and bsNum ~= nil and holeNum > bsNum then
              isNeedQianghua = true
            end
            local needMoney = data_getInsertGemMoney(bsNum + 1)
            local moneyFlag = needMoney <= g_LocalPlayer:getCoin()
            local cailaiFlag = true
            local tType = data_getInsertGemType(bsNum + 1)
            local qhf = data_getEnhanceEquipNeedQHF(mainHeroType, tType)
            if qhf ~= nil and 1 > g_LocalPlayer:GetItemNum(qhf) then
              cailaiFlag = false
            end
            if 1 > g_LocalPlayer:GetItemNum(tType) then
              cailaiFlag = false
            end
            if isNeedQianghua and moneyFlag and cailaiFlag then
              return {
                hId,
                itemObj:getObjId()
              }
            end
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_CreateSEqpt then
    local mainHero = g_LocalPlayer:getMainHero()
    local mainHeroType = mainHero:getTypeId()
    local shape = 3100120
    local needMoney = data_getUpgradeItemMoney(shape, 1, Eqpt_Upgrade_CreateType)
    local moneyFlag = needMoney <= g_LocalPlayer:getCoin()
    local cailaiFlag = true
    local jz = data_getUpgradeEquipNeedJZ(mainHeroType, 1)
    if jz ~= nil and 1 > g_LocalPlayer:GetItemNum(jz) then
      cailaiFlag = false
    end
    local tList = data_getUpgradeItemList(shape, 1, Eqpt_Upgrade_CreateType)
    for tType, tNum in pairs(tList) do
      if tNum > g_LocalPlayer:GetItemNum(tType) then
        cailaiFlag = false
      end
    end
    if moneyFlag and cailaiFlag then
      return true
    end
  elseif tsType == DEF_TISHENG_CreateXianqi then
    local mainHero = g_LocalPlayer:getMainHero()
    local mainHeroType = mainHero:getTypeId()
    local shape = 5100130
    local needMoney = data_getUpgradeItemMoney(shape, 1, Eqpt_Upgrade_CreateType)
    local moneyFlag = needMoney <= g_LocalPlayer:getCoin()
    local cailaiFlag = true
    local jz = data_getUpgradeXqNeedJZ(mainHeroType, 1)
    if jz ~= nil and 1 > g_LocalPlayer:GetItemNum(jz) then
      cailaiFlag = false
    end
    local tList = data_getUpgradeItemList(shape, 1, Eqpt_Upgrade_CreateType)
    for tType, tNum in pairs(tList) do
      if tNum > g_LocalPlayer:GetItemNum(tType) then
        cailaiFlag = false
      end
    end
    if moneyFlag and cailaiFlag then
      return true
    end
  elseif tsType == DEF_TISHENG_OnLineGift then
    if data_GiftOfOnline[gift.online:getRewardId()] == nil then
      return false
    end
    local nextCmpTime = gift.online:getNextCmpTime()
    local svrTime = g_DataMgr:getServerTime()
    if nextCmpTime - svrTime < 0 or nextCmpTime < 0 or svrTime < 0 then
      return true
    end
  elseif tsType == DEF_TISHENG_XunyangPet then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPet = tempHero:getProperty(PROPERTY_PETID)
      if tempPet ~= nil and tempPet ~= 0 then
        local ins = g_LocalPlayer:getObjById(tempPet)
        local petClose = ins:getProperty(PROPERTY_CLOSEVALUE)
        local maxClose = data_PetClose[#data_PetClose].closeValue
        if petClose < maxClose and g_LocalPlayer:getArch() >= data_Variables.CostArcForPet then
          return {tempPet}
        end
      end
    end
  elseif tsType == DEF_TISHENG_GetLinWuSkill then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPet = tempHero:getProperty(PROPERTY_PETID)
      if tempPet ~= nil and tempPet ~= 0 then
        local petObj = g_LocalPlayer:getObjById(tempPet)
        local emptySkillFlag = false
        local normalPetSkills = petObj:getProperty(PROPERTY_PETSKILLS)
        if type(normalPetSkills) == "table" then
          for _, d in pairs(normalPetSkills) do
            if d == 0 then
              emptySkillFlag = true
              break
            end
          end
        end
        local skillBookId
        local itemIds = g_LocalPlayer:GetItemTypeList(ITEM_LARGE_TYPE_OTHERITEM)
        for _, tempId in pairs(itemIds) do
          local itemObj = g_LocalPlayer:GetOneItem(tempId)
          local itemTypeId = itemObj:getTypeId()
          if GetItemSubTypeByItemTypeId(itemTypeId) == ITEM_DEF_TYPE_SKILLBOOK then
            local bookType = GetPetSkillBookTypeByItemTypeId(itemTypeId)
            if bookType == ITEM_DEF_SKILLBOOK_NORMAL or bookType == ITEM_DEF_SKILLBOOK_SENIOR or bookType == ITEM_DEF_SKILLBOOK_SUPREME then
              skillBookId = tempId
              break
            end
          end
        end
        if emptySkillFlag and skillBookId ~= nil then
          return {tempPet, skillBookId}
        end
      end
    end
  elseif tsType == DEF_TISHENG_HuoLiMax then
    local lSkillId, _ = g_LocalPlayer:getBaseLifeSkill()
    if lSkillId ~= LIFESKILL_NO then
      local limit = data_Variables.Player_Max_Huoli_Value or 1000
      if limit <= g_LocalPlayer:getHuoli() then
        return true
      end
    end
  elseif tsType == DEF_TISHENG_ZuoqiUpgradeLv then
    local tempHero = g_LocalPlayer:getMainHero()
    local zuoqiId
    if tempHero then
      local tempPetId = tempHero:getProperty(PROPERTY_PETID)
      if tempPetId ~= nil and tempPetId ~= 0 then
        local petObj = g_LocalPlayer:getObjById(tempPetId)
        if petObj ~= nil then
          local emptyZuoqiList = {}
          local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
          for _, tempZqId in pairs(myZuoqiList) do
            local zqIns = g_LocalPlayer:getObjById(tempZqId)
            if zqIns then
              local petList = zqIns:getProperty(PROPERTY_ZUOQI_PETLIST) or {}
              if petList == 0 then
                petList = {}
              end
              local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
              for _, tPetId in pairs(petList) do
                if tPetId == tempPetId then
                  zuoqiId = zqIns:getObjId()
                  break
                end
              end
              if zuoqiId ~= nil then
                break
              end
            end
          end
        end
      end
    end
    if zuoqiId ~= nil then
      local zqIns = g_LocalPlayer:getObjById(zuoqiId)
      if zqIns ~= nil then
        local zqCurLevel = zqIns:getProperty(PROPERTY_ROLELEVEL)
        if zqCurLevel < CalculateZuoqiLevelLimit() then
          local curExp = zqIns:getProperty(PROPERTY_EXP)
          local nextExp = CalculateZuoqiLevelupExp(zqCurLevel + 1)
          if curExp <= nextExp then
            local needArch = math.floor((nextExp - curExp) * 3.5)
            if needArch ~= (nextExp - curExp) * 3.5 then
              needArch = needArch + 1
            end
            if needArch <= g_LocalPlayer:getArch() then
              return {
                zqIns:getProperty(PROPERTY_SHAPE)
              }
            end
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_ZuoqiAddSkill then
    local tempHero = g_LocalPlayer:getMainHero()
    local zuoqiId
    if g_LocalPlayer:getCoin() < (data_Variables.ZuoqiLearnSkillCostCoin or 200000) then
      return false
    end
    if tempHero then
      local tempPetId = tempHero:getProperty(PROPERTY_PETID)
      if tempPetId ~= nil and tempPetId ~= 0 then
        local petObj = g_LocalPlayer:getObjById(tempPetId)
        if petObj ~= nil then
          local emptyZuoqiList = {}
          local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
          for _, tempZqId in pairs(myZuoqiList) do
            local zqIns = g_LocalPlayer:getObjById(tempZqId)
            if zqIns then
              local petList = zqIns:getProperty(PROPERTY_ZUOQI_PETLIST) or {}
              if petList == 0 then
                petList = {}
              end
              local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
              for _, tPetId in pairs(petList) do
                if tPetId == tempPetId then
                  zuoqiId = zqIns:getObjId()
                  break
                end
              end
              if zuoqiId ~= nil then
                break
              end
            end
          end
        end
      end
    end
    if zuoqiId ~= nil then
      local zqIns = g_LocalPlayer:getObjById(zuoqiId)
      if zqIns ~= nil then
        local zqCurLevel = zqIns:getProperty(PROPERTY_ROLELEVEL)
        local skillNumLimit = CalculateZuoqiSkillNumLimit()
        local skillList = zqIns:getProperty(PROPERTY_ZUOQI_SKILLLIST)
        if skillList == 0 then
          skillList = {}
        end
        if skillNumLimit > #skillList then
          return {zuoqiId}
        end
      end
    end
  elseif tsType == DEF_TISHENG_DianhuaZuoqi then
    local tempHero = g_LocalPlayer:getMainHero()
    local zuoqiId
    if tempHero then
      local tempPetId = tempHero:getProperty(PROPERTY_PETID)
      if tempPetId ~= nil and tempPetId ~= 0 then
        local petObj = g_LocalPlayer:getObjById(tempPetId)
        if petObj ~= nil then
          local emptyZuoqiList = {}
          local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
          for _, tempZqId in pairs(myZuoqiList) do
            local zqIns = g_LocalPlayer:getObjById(tempZqId)
            if zqIns then
              local petList = zqIns:getProperty(PROPERTY_ZUOQI_PETLIST) or {}
              if petList == 0 then
                petList = {}
              end
              local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
              for _, tPetId in pairs(petList) do
                if tPetId == tempPetId then
                  zuoqiId = zqIns:getObjId()
                  break
                end
              end
              if zuoqiId ~= nil then
                break
              end
            end
          end
        end
      end
    end
    if zuoqiId ~= nil then
      local zqIns = g_LocalPlayer:getObjById(zuoqiId)
      if zqIns ~= nil then
        local dianhuaFlag = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
        if dianhuaFlag == 0 then
          local lv = zqIns:getProperty(PROPERTY_ROLELEVEL)
          local lvlimit = CalculateZuoqiLevelLimit()
          local pValue = zqIns:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
          local pValueLimit = CalculateZuoqiSkillPValueLimit()
          local ggbase = zqIns:getProperty(PROPERTY_ZUOQI_INIT_GenGu)
          local ggbaseMax = CalculateZuoqiBaseGGLimit(zqIns:getTypeId(), isDh)
          if lv >= lvlimit and pValue >= pValueLimit and ggbase >= ggbaseMax then
            return {zuoqiId}
          end
        end
      end
    end
  elseif tsType == DEF_TISHENG_BoxSuiPian then
    local bxspNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_BXSP)
    local needNum = data_BaoXiangVar.SilverBaoXiang_NeedPiece or 5
    if bxspNum >= needNum and activity.tjbx:getExchangeSilverBoxTimes() < activity.tjbx:getExchangeSilverBoxMaxTimes() then
      return true
    end
  else
    return false
  end
  return false
end
CTiShengMgr = class("CTiShengMgr")
function CTiShengMgr:ctor()
  self.m_CheckList = {
    DEF_TISHENG_RoleAttrPoint,
    DEF_TISHENG_HuobanAttrPoint,
    DEF_TISHENG_PetAttrPoint,
    DEF_TISHENG_AddSkillExp,
    DEF_TISHENG_AddFriendToWar,
    DEF_TISHENG_PetForWar,
    DEF_TISHENG_XiangShi,
    DEF_TISHENG_LevelGift,
    DEF_TISHENG_LoginGift,
    DEF_TISHENG_FreeBiwu,
    DEF_TISHENG_ChuYaoAward,
    DEF_TISHENG_LiaoYao,
    DEF_TISHENG_OnLineGift,
    DEF_TISHENG_PetAddNeidang,
    DEF_TISHENG_AddNeidangExp,
    DEF_TISHENG_GetFreeFriend,
    DEF_TISHENG_GetZuoQi,
    DEF_TISHENG_ZuoQiManagePet,
    DEF_TISHENG_ZuoQiSkill,
    DEF_TISHENG_ChangePet,
    DEF_TISHENG_AddEqpt,
    DEF_TISHENG_UpdateEqpt,
    DEF_TISHENG_LianhuaEqpt,
    DEF_TISHENG_QianghuaEqpt,
    DEF_TISHENG_CreateSEqpt,
    DEF_TISHENG_CreateXianqi,
    DEF_TISHENG_ChengZhangBD,
    DEF_TISHENG_PetZhuangsheng,
    DEF_TISHENG_ChiBangAddPoint,
    DEF_TISHENG_DianhuaZuoqi,
    DEF_TISHENG_ZuoqiAddSkill,
    DEF_TISHENG_ZuoqiUpgradeLv,
    DEF_TISHENG_XunyangPet,
    DEF_TISHENG_GetLinWuSkill,
    DEF_TISHENG_HuoLiMax,
    DEF_TISHENG_BoxSuiPian
  }
  self.m_NeedUpdateFlag = false
  function _sortFunc(a, b)
    if a == nil or b == nil then
      return false
    end
    local dataA = data_Tisheng[a] or {}
    local dataB = data_Tisheng[b] or {}
    local showNoA = dataA.showNo or 9999
    local showNoB = dataB.showNo or 9999
    if showNoA ~= showNoB then
      return showNoA < showNoB
    else
      return a < b
    end
  end
  table.sort(self.m_CheckList, _sortFunc)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_WarSetting)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_Gift)
  self:ListenMessage(MsgID_Keju)
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_DaYanTa)
  self:ListenMessage(MsgID_Pvp)
  self:ListenMessage(MsgID_Connect)
  self.m_ZuoqiCDTimer = nil
  self:SetZuoqiCDTimer()
  self.m_TishengUpdateTimer = nil
  self:SetTishengUpdateTimer()
end
function CTiShengMgr:GetTishengList()
  local list = {}
  for _, tsType in ipairs(self.m_CheckList) do
    if NeedToTiSheng(tsType) ~= false then
      list[#list + 1] = tsType
    end
  end
  return list
end
function CTiShengMgr:GetWarTishengList()
  local list = {}
  for _, tsType in ipairs(self.m_CheckList) do
    if data_Tisheng[tsType].showInLoseWar == 1 and NeedToTiSheng(tsType) ~= false then
      list[#list + 1] = tsType
    end
  end
  return list
end
function CTiShengMgr:OnMessage(msgSID, ...)
  local needFlag = false
  local arg = {
    ...
  }
  local fid = self:GetFIDWithSID(msgSID)
  if msgSID == MsgID_AddHero or msgSID == MsgID_DeleteHero then
    needFlag = true
  elseif msgSID == MsgID_HeroUpdate or msgSID == MsgID_PetUpdate then
    needFlag = true
  elseif msgSID == MsgID_HeroSkillExpChange then
    needFlag = true
  elseif msgSID == MsgID_WarSetting_Change then
    needFlag = true
  elseif msgSID == MsgID_MoneyUpdate then
    needFlag = true
  elseif msgSID == MsgID_ArchUpdate then
    needFlag = true
  elseif msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_DelItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    needFlag = true
  elseif msgSID == MsgID_ItemInfo_TakeEquip or msgSID == MsgID_ItemInfo_TakeDownEquip or msgSID == MsgID_ItemInfo_ItemUpdate then
    needFlag = true
  elseif msgSID == MsgID_Gift_CheckinRewardUpdate or msgSID == MsgID_Gift_LevelupRewardUpdate or msgSID == MsgID_Gift_OnlineRewardUpdate or msgSID == MsgID_Gift_OnlineRewardTimesUp or msgSID == MsgID_Gift_FestivalRewardUpdate or msgSID == MsgID_Gift_EventRemindUpdate or msgSID == MsgID_Gift_EventRemindUpdate then
    needFlag = true
  elseif msgSID == MsgID_Activity_Updated or msgSID == MsgID_Keju_StatusChanged then
    needFlag = true
  elseif msgSID == MsgID_DaYanTa_ExChangeTime then
    needFlag = true
  elseif msgSID == MsgID_JiuguanDataUpdate then
    needFlag = true
  elseif msgSID == MsgID_BoxDataUpdate then
    needFlag = true
  elseif msgSID == MsgID_Pvp_BaseInfo then
    needFlag = true
  elseif msgSID == MsgID_Connect_SendFinished then
    needFlag = true
  elseif msgSID == MsgID_NewZuoqi or msgSID == MsgID_ZuoqiUpdate then
    self:SetZuoqiCDTimer()
    needFlag = true
  elseif msgSID == MsgID_JiuguanOpenListUpdate then
    needFlag = true
  elseif msgSID == MsgID_LifeSkillUpdate then
    needFlag = true
  elseif msgSID == MsgID_HouliUpdate then
    needFlag = true
  end
  if needFlag and g_DataMgr:getIsSendFinished() == true then
    self.m_NeedUpdateFlag = true
  end
end
function CTiShengMgr:SetZuoqiCDTimer()
  if g_LocalPlayer == nil then
    return
  end
  if self.m_ZuoqiCDTimer ~= nil then
    scheduler.unscheduleGlobal(self.m_ZuoqiCDTimer)
    self.m_ZuoqiCDTimer = nil
  end
  local minRestTime
  local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
  for _, tempZqId in pairs(myZuoqiList) do
    local zqIns = g_LocalPlayer:getObjById(tempZqId)
    if zqIns then
      local pValue = zqIns:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
      local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
      local pValueLimit = CalculateUpgradeZuoqiSkillPValueLimit(isDh)
      local lastUpgradeTime = zqIns:getProperty(PROPERTY_ZUOQI_CDTIME)
      local svrTime = g_DataMgr:getServerTime()
      local restTime = lastUpgradeTime + CalculateZuoqiUpgradeCDTime() - svrTime
      if pValue < pValueLimit and restTime > 0 and (minRestTime == nil or minRestTime > restTime) then
        minRestTime = restTime
      end
    end
  end
  if minRestTime ~= nil and minRestTime > 0 then
    self.m_ZuoqiCDTimer = scheduler.scheduleGlobal(function()
      self.m_NeedUpdateFlag = true
      if self.SetZuoqiCDTimer then
        self:SetZuoqiCDTimer()
      end
    end, minRestTime)
  end
end
function CTiShengMgr:SetTishengUpdateTimer()
  if self.m_TishengUpdateTimer ~= nil then
    scheduler.unscheduleGlobal(self.m_TishengUpdateTimer)
    self.m_TishengUpdateTimer = nil
  end
  self.m_TishengUpdateTimer = scheduler.scheduleGlobal(function()
    if self.m_NeedUpdateFlag then
      UpdateTishengBoard()
    end
    self.m_NeedUpdateFlag = false
  end, 1)
end
function CTiShengMgr:ClearTimer()
  if self.m_ZuoqiCDTimer ~= nil then
    scheduler.unscheduleGlobal(self.m_ZuoqiCDTimer)
    self.m_ZuoqiCDTimer = nil
  end
  if self.m_TishengUpdateTimer ~= nil then
    scheduler.unscheduleGlobal(self.m_TishengUpdateTimer)
    self.m_TishengUpdateTimer = nil
  end
end
g_CTiShengMgr = CTiShengMgr.new()
gamereset.registerResetFunc(function()
  if g_CTiShengMgr then
    g_CTiShengMgr:ClearTimer()
    g_CTiShengMgr:RemoveAllMessageListener()
  end
  g_CTiShengMgr = CTiShengMgr.new()
end)
CTiShengBoard = class("CTiShengBoard", CcsSubView)
function CTiShengBoard:ctor(tishengList, clickPreFunc)
  CTiShengBoard.super.ctor(self, "views/tishengboard.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_list = self:getNode("list")
  self.m_TsTypeList = {}
  self.m_ClickPreFunc = clickPreFunc
  tishengList = tishengList or GetTishengList()
  self:SetTishengBtns(tishengList)
end
function CTiShengBoard:SetTishengBtns(tishengList)
  if #tishengList == 0 then
    CloseTishengBoard()
  end
  local needToReload = false
  if not isListEqual(self.m_TsTypeList, tishengList) then
    needToReload = true
  end
  if needToReload then
    self.m_TsTypeList = {}
    self.m_list:removeAllItems()
    for _, tishengType in ipairs(tishengList) do
      local item = CTiShengItem.new(tishengType, "views/tishengboard_item.json", self.m_ClickPreFunc)
      self.m_list:pushBackCustomItem(item:getUINode())
      self.m_TsTypeList[#self.m_TsTypeList + 1] = tishengType
    end
  end
  self.m_list:sizeChangedForShowMoreTips()
end
function CTiShengBoard:OnBtn_Close(obj, t)
  CloseTishengBoard()
end
function CTiShengBoard:Clear()
  self.m_ClickPreFunc = nil
end
CTiShengItem = class("CTiShengItem", CcsSubView)
function CTiShengItem:ctor(itemType, jsonPath, clickPreFunc)
  CTiShengItem.super.ctor(self, jsonPath)
  self.m_Type = itemType
  local btnBatchListener = {
    btn = {
      listener = handler(self, self.OnBtn_Click),
      variName = "btn",
      param = {0, 1}
    }
  }
  self.m_ClickPreFunc = clickPreFunc
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("txt"):setText(data_Tisheng[itemType].name or "未知提升")
end
function CTiShengItem:OnBtn_Click(obj, t)
  if self.m_ClickPreFunc ~= nil then
    self.m_ClickPreFunc()
  end
  local tsType = self.m_Type
  local jumpPara = NeedToTiSheng(tsType)
  if jumpPara == false then
    return
  end
  if tsType == DEF_TISHENG_RoleAttrPoint then
    local tempView = settingDlg.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:ShowSetPoint()
  elseif tsType == DEF_TISHENG_HuobanAttrPoint then
    local hId = jumpPara[1]
    local tempView = CHuobanShow.new({viewNum = HuobanShow_ShowHuobanView, huobanID = hId})
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView.m_ShowHuobanView:ChooseItemByHeroId(hId)
    tempView.m_ShowHuobanView:ScrollToRole(hId)
    tempView.m_ShowHuobanView:OnBtn_SetPoint()
  elseif tsType == DEF_TISHENG_PetAttrPoint then
    local pId = jumpPara[1]
    local tempView = CPetList.new(PetShow_InitShow_PropertyView, pId)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:ShowAddPoint()
  elseif tsType == DEF_TISHENG_PetAddNeidang then
    local pId = jumpPara[1]
    local ndId = jumpPara[2]
    local tempView = CPetList.new(PetShow_InitShow_NeidanView, pId)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    if tempView.m_PageItemList ~= nil then
      tempView.m_PageItemList.m_PackageFrame:JumpToItemPage(ndId)
    end
  elseif tsType == DEF_TISHENG_AddNeidangExp then
    local pId = jumpPara[1]
    local ndId = jumpPara[2]
    local tempView = CPetList.new(PetShow_InitShow_NeidanView, pId)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:OnBtn_NeiDan(ndId)
  elseif tsType == DEF_TISHENG_LiaoYao then
    local pId = jumpPara[1]
    local tempView = CPetList.new(PetShow_InitShow_LianYaoView, pId)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView.m_PageLianYaoList:OnBtn_SelectLYS()
  elseif tsType == DEF_TISHENG_XiChong then
    local pId = jumpPara[1]
    local tempView = CPetList.new(PetShow_InitShow_XiChongView, pId)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_GetZuoQi then
    local zqId = jumpPara[1]
    local tempView = CZuoqiShow.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:SelectZuoqi(zqId)
  elseif tsType == DEF_TISHENG_ZuoQiManagePet then
    local zqId = jumpPara[1]
    local tempView = CZuoqiShow.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:SelectZuoqi(zqId)
    tempView:OnBtn_ManageView()
    tempView:setGroupBtnSelected(tempView.btn_manage)
  elseif tsType == DEF_TISHENG_ZuoQiSkill then
    local zqId = jumpPara[1]
    local tempView = CZuoqiShow.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:SelectZuoqi(zqId)
    tempView:OnBtn_SkillView()
    tempView:setGroupBtnSelected(tempView.btn_skill)
  elseif tsType == DEF_TISHENG_PetForWar then
    local pId = jumpPara[1]
    local tempView = CPetList.new(PetShow_InitShow_PropertyView, pId)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_GetFreeFriend then
    getCurSceneView():addSubView({
      subView = CHuobanShow.new({viewNum = HuobanShow_GetHuobanView}),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_FreeBiwu then
    ShowBattlePvpDlg()
  elseif tsType == DEF_TISHENG_LevelGift then
    local tempView = CHuodongShow.new({InitHuodongShow = HuodongShow_GiftView})
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_LoginGift then
    local tempView = GiftRewardOfCheckin.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_XiangShi then
    activity.keju:GotoNpc()
  elseif tsType == DEF_TISHENG_ChuYaoAward then
    activity.dayanta:GotoNpc()
  elseif tsType == DEF_TISHENG_ChangePet then
    local pType = jumpPara[1]
    local tempView = CPetList.new(PetShow_InitShow_TuJianView, nil, nil, pType)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_AddFriendToWar then
    local hId = jumpPara[1]
    local tempView = CHuobanShow.new({viewNum = HuobanShow_ShowHuobanView, huobanID = hId})
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView.m_ShowHuobanView:ChooseItemByHeroId(hId)
    tempView.m_ShowHuobanView:ScrollToRole(hId)
  elseif tsType == DEF_TISHENG_AddSkillExp then
    local skillId = jumpPara[1]
    local tempView = CSkillShow.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    local roleIns = g_LocalPlayer:getMainHero()
    local skillTypeList = roleIns:getSkillTypeList()
    local skillAttr = data_getSkillAttrStyle(skillId)
    local shimenSkillView = tempView.m_ShimenView
    if shimenSkillView then
      if skillTypeList[1] == skillAttr then
        shimenSkillView:OnBtn_SkillType1()
      elseif skillTypeList[2] == skillAttr then
        shimenSkillView:OnBtn_SkillType2()
      elseif skillTypeList[3] == skillAttr then
        shimenSkillView:OnBtn_SkillType3()
      end
    end
  elseif tsType == DEF_TISHENG_AddEqpt then
    local itemId = jumpPara[1]
    local tempView = CMainRoleView.new({jumpToItemId = itemId})
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:ShowPackageDetail(itemId, false)
  elseif tsType == DEF_TISHENG_UpdateEqpt then
    local hId = jumpPara[1]
    local itemId = jumpPara[2]
    if hId == g_LocalPlayer:getMainHeroId() then
      local tempView = CMainRoleView.new()
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
    else
      local tempView = CHuobanShow.new({viewNum = HuobanShow_ShowHuobanView, huobanID = hId})
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
      tempView.m_ShowHuobanView:ChooseItemByHeroId(hId)
      tempView.m_ShowHuobanView:ScrollToRole(hId)
    end
    getCurSceneView():addSubView({
      subView = CZhuangbeiShow.new({
        InitItemId = itemId,
        InitRoleId = hId,
        InitUpgradeType = Eqpt_Upgrade_CreateType
      }),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_LianhuaEqpt then
    local hId = jumpPara[1]
    local itemId = jumpPara[2]
    if hId == g_LocalPlayer:getMainHeroId() then
      local tempView = CMainRoleView.new()
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
    else
      local tempView = CHuobanShow.new({viewNum = HuobanShow_ShowHuobanView, huobanID = hId})
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
      tempView.m_ShowHuobanView:ChooseItemByHeroId(hId)
      tempView.m_ShowHuobanView:ScrollToRole(hId)
    end
    getCurSceneView():addSubView({
      subView = CZhuangbeiShow.new({
        InitItemId = itemId,
        InitRoleId = hId,
        InitUpgradeType = Eqpt_Upgrade_LianhuaType
      }),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_QianghuaEqpt then
    local hId = jumpPara[1]
    local itemId = jumpPara[2]
    if hId == g_LocalPlayer:getMainHeroId() then
      local tempView = CMainRoleView.new()
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
    else
      local tempView = CHuobanShow.new({viewNum = HuobanShow_ShowHuobanView, huobanID = hId})
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
      tempView.m_ShowHuobanView:ChooseItemByHeroId(hId)
      tempView.m_ShowHuobanView:ScrollToRole(hId)
    end
    getCurSceneView():addSubView({
      subView = CZhuangbeiShow.new({
        InitItemId = itemId,
        InitRoleId = hId,
        InitUpgradeType = Eqpt_Upgrade_QianghuaType
      }),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_CreateSEqpt then
    getCurSceneView():addSubView({
      subView = CCreateZhuangbei.new({
        InitLargeType = ITEM_LARGE_TYPE_SENIOREQPT,
        forRoleId = g_LocalPlayer:getMainHeroId()
      }),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_CreateXianqi then
    getCurSceneView():addSubView({
      subView = CCreateZhuangbei.new({
        InitLargeType = ITEM_LARGE_TYPE_XIANQI,
        forRoleId = g_LocalPlayer:getMainHeroId()
      }),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_OnLineGift then
    local tempView = CHuodongShow.new({InitHuodongShow = HuodongShow_GiftView})
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_ChengZhangBD then
    getCurSceneView():addSubView({
      subView = ChengZhangBD.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_PetZhuangsheng then
    g_MapMgr:AutoRouteToNpc(NPC_LingShouXian_ID, function(isSucceed)
      if CMainUIScene.Ins and isSucceed then
        CMainUIScene.Ins:ShowNormalNpcViewById(NPC_LingShouXian_ID)
      end
    end)
  elseif tsType == DEF_TISHENG_ChiBangAddPoint then
    local tempView = CMainRoleView.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    getCurSceneView():addSubView({
      subView = CSetWingView.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif tsType == DEF_TISHENG_ZuoqiAddSkill then
    do
      local zqId = jumpPara[1]
      g_MapMgr:AutoRouteToNpc(NPC_XUNYANGSHI_ID, function(isSucceed)
        if isSucceed then
          ShowZuoqiSkillDlg(zqId)
        end
      end)
    end
  elseif tsType == DEF_TISHENG_DianhuaZuoqi then
    do
      local zqId = jumpPara[1]
      g_MapMgr:AutoRouteToNpc(NPC_XUNYANGSHI_ID, function(isSucceed)
        if isSucceed then
          ShowZuoqiDianHuaDlg(zqId)
        end
      end)
    end
  elseif tsType == DEF_TISHENG_ZuoqiUpgradeLv then
    local zqId = jumpPara[1]
    local tempView = CZuoqiShow.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:SelectZuoqi(zqId)
    tempView:OnBtn_UpgradeLv()
    tempView:setGroupBtnSelected(tempView.btn_uplv)
  elseif tsType == DEF_TISHENG_XunyangPet then
    local pId = jumpPara[1]
    local tempView = CPetList.new(PetShow_InitShow_PropertyView, pId)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:ShowAddClose()
  elseif tsType == DEF_TISHENG_GetLinWuSkill then
    local pId = jumpPara[1]
    local itemId = jumpPara[2]
    local tempView = CPetList.new(PetShow_InitShow_SkillLearnView, pId)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView.m_PageItemList.m_PackageFrame:JumpToItemPage(itemId, true)
  elseif tsType == DEF_TISHENG_HuoLiMax then
    openUseEnergyView()
  elseif tsType == DEF_TISHENG_BoxSuiPian then
    g_MapMgr:AutoRouteToNpc(NPC_CHENXIAOJIN_ID, function(isSucceed)
      if CMainUIScene.Ins and isSucceed then
        CMainUIScene.Ins:ShowNormalNpcViewById(NPC_CHENXIAOJIN_ID)
      end
    end)
  end
end
function CTiShengItem:Clear()
  self.m_ClickPreFunc = nil
end
