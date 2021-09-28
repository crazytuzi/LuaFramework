function CheckEquipAddAttr(itemId, showBaseValue, showLHValue)
  local itemObj = g_LocalPlayer:GetOneItem(itemId)
  if itemObj == nil then
    return
  end
  local attrList = {}
  local itemType = itemObj:getType()
  if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_SHENBING or itemType == ITEM_LARGE_TYPE_XIANQI or itemType == ITEM_LARGE_TYPE_HUOBANEQPT then
    local bsNum = itemObj:getProperty(ITME_PRO_EQPT_BAOSHINUM)
    if showBaseValue ~= false then
      for _, para in ipairs(ITEM_PRO_SHOW_BASE_DICT) do
        local proName = para[1]
        local str = para[2]
        local tempType = para[3]
        local tempNum = itemObj:getProperty(proName)
        if bsNum > 0 and ZB_PRO_BASE_DICT[proName] == true then
          tempNum = tempNum * (1 + 0.02 * bsNum)
        end
        local color = "CBA"
        local addFlag = "+"
        if tempNum ~= 0 then
          if tempNum < 0 then
            addFlag = "-"
          end
          if tempType == Pro_Value_NUM_TYPE then
            attrList[#attrList + 1] = string.format("#<%s>%s %s%d#", color, str, addFlag, math.floor(math.abs(tempNum)))
          elseif tempType == Pro_Value_PERCENT_TYPE then
            attrList[#attrList + 1] = string.format("#<%s>%s %s%s%%#", color, str, addFlag, Value2Str(math.abs(tempNum) * 100, 1))
          end
        end
      end
    end
    if showLHValue ~= false then
      local color = "CLH"
      for _, para in ipairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
        local proName = para[1]
        local str = para[2]
        local tempType = para[3]
        local tempNum = itemObj:getProperty(proName)
        local addFlag = "+"
        if tempNum ~= 0 then
          if tempNum < 0 then
            addFlag = "-"
          end
          if tempType == Pro_Value_NUM_TYPE then
            attrList[#attrList + 1] = string.format("#<%s>%s %s%d#", color, str, addFlag, math.floor(math.abs(tempNum)))
          elseif tempType == Pro_Value_PERCENT_TYPE then
            attrList[#attrList + 1] = string.format("#<%s>%s %s%s%%#", color, str, addFlag, Value2Str(math.abs(tempNum) * 100, 1))
          end
        end
      end
      local lvlimit = itemObj:getProperty(ITEM_PRO_EQPT_LH_LVLIMIT)
      if lvlimit ~= 0 then
        attrList[#attrList + 1] = string.format("#<%s>装备等级需求 -%d#\n", color, math.abs(lvlimit))
      end
      local prolimit = itemObj:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)
      if prolimit ~= 0 then
        attrList[#attrList + 1] = string.format("#<%s>装备属性需求 -%d%%#\n", color, math.abs(prolimit) * 100)
      end
    end
  end
  if JudgeIsInWar() then
  elseif g_DataMgr:getIsSendFinished() == false then
  else
    for _, msg in pairs(attrList) do
      ShowNotifyTips(msg)
    end
  end
end
function RequestToAddItemToRole(itemId, roleId)
  netsend.netitem.requestAddItemToRole(itemId, roleId)
  g_LocalPlayer:setLastRequestItemIdAndRoleId(itemId, roleId)
end
PackageExtend = {}
function PackageExtend.extend(object)
  object.m_ItemCreateClasses = {
    [tostring(ITEM_LARGE_TYPE_DRUG)] = CDrugData,
    [tostring(ITEM_LARGE_TYPE_TASK)] = CTaskItemData,
    [tostring(ITEM_LARGE_TYPE_GIFT)] = CGiftItemData,
    [tostring(ITEM_LARGE_TYPE_NEIDAN)] = CNeidanData,
    [tostring(ITEM_LARGE_TYPE_STUFF)] = CStuffData,
    [tostring(ITEM_LARGE_TYPE_LIANYAOSHI)] = CLianYaoShiData,
    [tostring(ITEM_LARGE_TYPE_OTHERITEM)] = COtherItemData,
    [tostring(ITEM_LARGE_TYPE_EQPT)] = CEqptData,
    [tostring(ITEM_LARGE_TYPE_SENIOREQPT)] = CEqptData,
    [tostring(ITEM_LARGE_TYPE_LIFEITEM)] = CLifeItemData,
    [tostring(ITEM_LARGE_TYPE_XIANQI)] = CEqptData,
    [tostring(ITEM_LARGE_TYPE_HUOBANEQPT)] = CEqptData
  }
  object.m_PackagePosDict = {}
  object.m_PackageDict = {}
  object.m_PackageTypeDict = {}
  object.m_PackageItemToRoleDict = {}
  object.m_CangkuPosDict = {}
  object.m_CangkuDict = {}
  object.m_LastRequestAddItemId = nil
  object.m_LastRequestAddRoleId = nil
  function object:ClearPosData(itemObjID, pos)
    if pos ~= 0 and object.m_PackagePosDict[pos] == itemObjID then
      object.m_PackagePosDict[pos] = nil
      if object == g_LocalPlayer then
        SendMessage(MsgID_ItemInfo_PosClear, pos)
      end
    end
    local itemIns = object.m_PackageDict[itemObjID]
    if itemIns ~= nil and itemIns:getProperty(ITME_PRO_PACKAGE_POS) == pos then
      object:SetSvrProToItem(itemIns, {i_pos = 0})
    end
  end
  function object:SetPosData(itemObjID, pos)
    if pos ~= 0 then
      object.m_PackagePosDict[pos] = itemObjID
    end
    local itemIns = object.m_PackageDict[itemObjID]
    if itemIns ~= nil then
      object:SetSvrProToItem(itemIns, {i_pos = pos})
    end
  end
  function object:newItemObject(objId, lTypeId, copyProperties)
    local clsKey = GetItemTypeByItemTypeId(lTypeId)
    local cls = object.m_ItemCreateClasses[tostring(clsKey)]
    if cls == nil then
      printLog("PackageExtend", "创建类型[%s]的对象出错：找不到该类型的类", tostring(clsKey))
      return nil
    end
    local playerId = object.m_RoleId
    local obj = cls.new(playerId, objId, lTypeId, copyProperties)
    obj:setPropertyChanagedListener(handler(object, object.ObjectItemPropertyChanged))
    return obj
  end
  function object:SetOneItem(itemId, lTypeId, svrPro, popQuickUse)
    if popQuickUse == nil then
      popQuickUse = true
    end
    local itemIns = object.m_PackageDict[itemId]
    local newFlag = false
    if itemIns == nil then
      newFlag = true
      itemIns = object:newItemObject(itemId, lTypeId)
      if itemIns == nil then
        return
      end
      object.m_PackageDict[itemId] = itemIns
      local lType = itemIns:getType()
      local lTypeList = object.m_PackageTypeDict[lType]
      if lTypeList == nil then
        object.m_PackageTypeDict[lType] = {}
        lTypeList = object.m_PackageTypeDict[lType]
      end
      lTypeList[#lTypeList + 1] = itemId
    end
    local oldPos = itemIns:getProperty(ITME_PRO_PACKAGE_POS)
    object:SetSvrProToItem(itemIns, svrPro, popQuickUse)
    local newPos = itemIns:getProperty(ITME_PRO_PACKAGE_POS)
    if newPos ~= oldPos then
      object:ClearPosData(itemId, oldPos)
      object:SetPosData(itemId, newPos)
    end
    if lTypeId == nil then
      lTypeId = itemIns:getTypeId()
    end
    if object == g_LocalPlayer then
      local num = itemIns:getProperty(ITEM_PRO_NUM)
      if newFlag then
        SendMessage(MsgID_ItemInfo_AddItem, itemId, num, lTypeId, popQuickUse)
      else
        SendMessage(MsgID_ItemInfo_ChangeItemNum, itemId, num, lTypeId)
      end
    end
  end
  function object:DelOneItem(itemId)
    local itemIns = object.m_PackageDict[itemId]
    if itemIns == nil then
      printLog("PackageExtend", "error ~~~~异常1删除本地没有的物品ItemId%d", itemId)
    else
      local lType = itemIns:getType()
      local lTypeList = object.m_PackageTypeDict[lType]
      if lTypeList then
        for index, tempId in pairs(lTypeList) do
          if tempId == itemId then
            table.remove(lTypeList, index)
            break
          end
        end
      end
      local tempRole = object.m_PackageItemToRoleDict[itemId]
      if tempRole then
        object:DelItemFromRole(itemId, tempRole)
      end
      local oldPos = itemIns:getProperty(ITME_PRO_PACKAGE_POS)
      object:ClearPosData(itemId, oldPos)
      object.m_PackageDict[itemId] = nil
      local lTypeId = itemIns:getTypeId()
      if object == g_LocalPlayer then
        SendMessage(MsgID_ItemInfo_DelItem, itemId, lTypeId, oldPos)
      end
    end
  end
  function object:GetItemIdByPos(pos)
    return object.m_PackagePosDict[pos]
  end
  function object:GetOneItem(itemId)
    local itemIns = object.m_PackageDict[itemId]
    if itemIns == nil then
      if itemId == nil then
        printLog("PackageExtend", "~~~~异常2获取没有的物品ItemId为nil")
      else
        printLog("PackageExtend", "error ~~~~异常2获取没有的物品ItemId%d", itemId)
      end
    end
    return itemIns
  end
  function object:GetAllItemIdListExceptHuoBanAndTask()
    local itemIdList = {}
    for itemId, itemIns in pairs(object.m_PackageDict) do
      local okFlag = true
      if itemIns:getType() == ITEM_LARGE_TYPE_TASK then
        okFlag = false
      else
        local roleId = object.m_PackageItemToRoleDict[itemId]
        if roleId ~= nil then
          local roleIns = g_LocalPlayer:getObjById(roleId)
          if roleIns and roleIns:getType() == LOGICTYPE_HERO and roleIns:getObjId() ~= g_LocalPlayer:getMainHeroId() then
            okFlag = false
          end
        end
      end
      if okFlag then
        local itemTypeId = itemIns:getTypeId()
        local temp = GetItemDataByItemTypeId(itemTypeId)
        if temp and temp[itemTypeId] ~= nil then
          itemIdList[#itemIdList + 1] = itemId
        end
      end
    end
    return itemIdList
  end
  function object:GetItemTypeList(lType)
    if object.m_PackageTypeDict[lType] == nil then
      return {}
    end
    local returnList = {}
    for _, itemId in pairs(object.m_PackageTypeDict[lType]) do
      if object.m_PackageItemToRoleDict[itemId] == nil then
        returnList[#returnList + 1] = itemId
      end
    end
    return returnList
  end
  function object:GetItemTypeListIncludeRole(lType)
    if object.m_PackageTypeDict[lType] == nil then
      return {}
    end
    local returnList = {}
    for _, itemId in pairs(object.m_PackageTypeDict[lType]) do
      returnList[#returnList + 1] = itemId
    end
    return returnList
  end
  function object:GetItemNum(itemType)
    local returnNum = 0
    local lType = GetItemTypeByItemTypeId(itemType)
    if object.m_PackageTypeDict[lType] == nil then
      return 0
    end
    for _, itemId in pairs(object.m_PackageTypeDict[lType]) do
      local itemIns = object.m_PackageDict[itemId]
      if itemIns ~= nil and itemIns:getTypeId() == itemType then
        returnNum = returnNum + itemIns:getProperty(ITEM_PRO_NUM)
      end
    end
    return returnNum
  end
  function object:GetItemNumNotIncludeRole(itemType)
    local returnNum = 0
    local lType = GetItemTypeByItemTypeId(itemType)
    if object.m_PackageTypeDict[lType] == nil then
      return 0
    end
    for _, itemId in pairs(object.m_PackageTypeDict[lType]) do
      local itemIns = object.m_PackageDict[itemId]
      if itemIns ~= nil and itemIns:getTypeId() == itemType and object.m_PackageItemToRoleDict[itemId] == nil then
        returnNum = returnNum + itemIns:getProperty(ITEM_PRO_NUM)
      end
    end
    return returnNum
  end
  function object:GetOneItemIdByType(itemType)
    local returnNum = 0
    local lType = GetItemTypeByItemTypeId(itemType)
    if object.m_PackageTypeDict[lType] == nil then
      return 0
    end
    for _, itemId in pairs(object.m_PackageTypeDict[lType]) do
      local itemIns = object.m_PackageDict[itemId]
      if itemIns ~= nil and itemIns:getTypeId() == itemType then
        return itemId
      end
    end
    return 0
  end
  function object:getHasHoleItem()
    local items = g_LocalPlayer:GetAllItemIdListExceptHuoBanAndTask()
    dump(items, "233333333 ")
    for k, v in pairs(items) do
      local itemIns = g_LocalPlayer:GetOneItem(v)
      if itemIns and object.m_PackageItemToRoleDict[itemIns:getObjId()] ~= nil then
        local holeNum = itemIns:getProperty(ITME_PRO_EQPT_HOLENUM)
        local bsNum = itemIns:getProperty(ITME_PRO_EQPT_BAOSHINUM)
        print(bsNum, " ********  ", holeNum)
        if holeNum > bsNum then
          return true
        end
      end
    end
    return false
  end
  function object:AddItemToRole(itemId, roleId)
    local itemIns = object.m_PackageDict[itemId]
    if itemIns == nil then
      printLog("PackageExtend", "error ~~~~异常3本地没有的物品ItemId%d", itemId)
      return
    end
    local roleIns = object:getObjById(roleId)
    if roleIns == nil then
      printLog("PackageExtend", "error ~~~~异常4本地没有的对象roleId%d", roleId)
      return
    end
    roleIns:addZhuangBei(itemId)
    object.m_PackageItemToRoleDict[itemId] = roleId
    local oldPos = itemIns:getProperty(ITME_PRO_PACKAGE_POS)
    object:ClearPosData(itemId, oldPos)
    if object == g_LocalPlayer then
      SendMessage(MsgID_ItemInfo_TakeEquip, roleId, itemId)
    end
    if g_DataMgr:getIsSendFinished() and itemIns:getType() ~= ITEM_LARGE_TYPE_HUOBANEQPT and object.m_LastRequestAddItemId == itemId and object.m_LastRequestAddRoleId == roleId then
      CheckEquipAddAttr(itemId)
    end
    object.m_LastRequestAddItemId = nil
    object.m_LastRequestAddRoleId = nil
  end
  function object:setLastRequestItemIdAndRoleId(itemId, roleId)
    object.m_LastRequestAddItemId = itemId
    object.m_LastRequestAddRoleId = roleId
  end
  function object:DelItemFromRole(itemId, roleId)
    local itemIns = object.m_PackageDict[itemId]
    if itemIns == nil then
      printLog("PackageExtend", "error ~~~~异常5本地没有的物品ItemId%d", itemId)
      return
    end
    local roleIns = object:getObjById(roleId)
    if roleIns == nil then
      printLog("PackageExtend", "error ~~~~异常6本地没有的对象roleId%d", roleId or 0)
      return
    end
    roleIns:delZhuangBei(itemId)
    object.m_PackageItemToRoleDict[itemId] = nil
    if object == g_LocalPlayer then
      SendMessage(MsgID_ItemInfo_TakeDownEquip, roleId, itemId)
    end
  end
  function object:SetSvrProToItem(itemIns, svrPro, popQuickUse)
    if popQuickUse == nil then
      popQuickUse = true
    end
    local proTable = {}
    local oldProTable = {}
    for k, v in pairs(svrPro) do
      local pro = ITEM_SVRKEY_PROPERTIES[k]
      if pro then
        local oldV = itemIns:getProperty(pro)
        if oldV ~= v then
          itemIns:setProperty(pro, v)
          proTable[pro] = v
          oldProTable[pro] = oldV
        end
      end
      if k == "t_tmplh" then
        local pro = ITEM_PRO_TEMPLH_Dict
        local oldV = itemIns:getProperty(pro)
        itemIns:setProperty(pro, v)
        proTable[pro] = v
        oldProTable[pro] = oldV
      end
    end
    if table_is_empty(proTable) == false then
      if object.m_PackageItemToRoleDict[itemIns:getObjId()] ~= nil then
        local roleId = object.m_PackageItemToRoleDict[itemIns:getObjId()]
        local roleIns = object:getObjById(roleId)
        roleIns:CalculateProperty()
      end
      if object == g_LocalPlayer then
        SendMessage(MsgID_ItemInfo_ItemUpdate, {
          itemType = itemIns:getTypeId(),
          itemId = itemIns:getObjId(),
          pro = proTable,
          oldPro = oldProTable,
          popQuickUse = popQuickUse
        })
      end
    end
    if svrPro.i_pos and object == g_LocalPlayer then
      SendMessage(MsgID_ItemInfo_ItemPackagePosUpdate, {
        itemId = itemIns:getObjId(),
        pos = svrPro.i_pos
      })
    end
  end
  function object:GetPackageEmpty()
    local hasExpandGrid = g_LocalPlayer:GetExpandPackageGird() or 0
    local notExpandPackageGrid = CanExpandMaxGridNum - hasExpandGrid
    local num = PackageAllPosNum - notExpandPackageGrid
    for itemObjId, itemIns in pairs(object.m_PackageDict) do
      if object.m_PackageItemToRoleDict[itemObjId] == nil and itemIns:getType() ~= ITEM_LARGE_TYPE_TASK then
        num = num - 1
      end
    end
    if num < 0 then
      num = 0
    end
    return num
  end
  function object:ItemIsOnRole(itemObjId, roleId)
    if itemObjId == nil or roleId == nil then
      return false
    end
    return object.m_PackageItemToRoleDict[itemObjId] == roleId
  end
  function object:GetRoleIdFromItem(itemObjId)
    return object.m_PackageItemToRoleDict[itemObjId]
  end
  function object:GetItemBaseProValueIsMax(itemId, proName)
    local itemIns = object:GetOneItem(itemId)
    if itemIns == nil then
      return false
    end
    local largeType = itemIns:getType()
    if largeType ~= ITEM_LARGE_TYPE_SENIOREQPT then
      return false
    end
    local value = itemIns:getProperty(proName)
    if value == 0 then
      return false
    end
    local typeId = itemIns:getTypeId()
    local mData = GetItemDataByItemTypeId(typeId)
    local eData = mData[typeId]
    if eData == nil then
      return false
    end
    local tempDict = {
      [ITEM_PRO_EQPT_LX] = {
        {
          "addProNum",
          "addProNumRandom"
        }
      },
      [ITEM_PRO_EQPT_LL] = {
        {
          "addProNum",
          "addProNumRandom"
        }
      },
      [ITEM_PRO_EQPT_GG] = {
        {
          "addProNum",
          "addProNumRandom"
        }
      },
      [ITEM_PRO_EQPT_MJ] = {
        {
          "addProNum",
          "addProNumRandom"
        }
      },
      [ITEM_PRO_EQPT_SP] = {
        {
          "addSpeedNum",
          "addSpeedRandom"
        }
      },
      [ITEM_PRO_EQPT_KZHONGDU] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangRenNum",
          "addKangRenNumRandom"
        },
        {
          "addKangRenExNum",
          "addKangRenExNumRandom"
        }
      },
      [ITEM_PRO_EQPT_KHUNSHUI] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangRenNum",
          "addKangRenNumRandom"
        },
        {
          "addKangRenExNum",
          "addKangRenExNumRandom"
        }
      },
      [ITEM_PRO_EQPT_KHUNLUAN] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangRenNum",
          "addKangRenNumRandom"
        },
        {
          "addKangRenExNum",
          "addKangRenExNumRandom"
        }
      },
      [ITEM_PRO_EQPT_KFENGYIN] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangRenNum",
          "addKangRenNumRandom"
        },
        {
          "addKangRenExNum",
          "addKangRenExNumRandom"
        }
      },
      [ITEM_PRO_EQPT_KHUO] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangXianNum",
          "addKangXianNumRandom"
        }
      },
      [ITEM_PRO_EQPT_KFENG] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangXianNum",
          "addKangXianNumRandom"
        }
      },
      [ITEM_PRO_EQPT_KLEI] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangXianNum",
          "addKangXianNumRandom"
        }
      },
      [ITEM_PRO_EQPT_KSHUI] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangXianNum",
          "addKangXianNumRandom"
        }
      },
      [ITEM_PRO_EQPT_ABSORDEF] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "absorbdef",
          "absorbdefRandom"
        },
        {
          "addKangRenExNum",
          "addKangRenExNumRandom"
        }
      },
      [ITEM_PRO_EQPT_HP] = {
        {
          "eqptHP",
          "eqptHPrandom"
        }
      },
      [ITEM_PRO_EQPT_MP] = {
        {
          "eqptMP",
          "eqptMPrandom"
        }
      },
      [ITEM_PRO_EQPT_AP] = {
        {
          "attack",
          "attackrandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_DU_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_DU] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_HUNSHUI_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_HUNSHUI] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_HUNLUAN_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_HUNLUAN] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_FENGYIN_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_FENGYIN] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_HUO_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_HUO] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_FENG_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_FENG] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_LEI_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_LEI] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_SHUI_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_SHUI] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_FANG_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_FANG] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_GONG_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_GONG] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_SU_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_SU] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_ZHEN_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_ZHEN] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        }
      },
      [ITEM_PRO_EQPT_HITRATE] = {
        {
          "addPhysicalProNum",
          "addPhysicalProNumRandom"
        }
      },
      [ITEM_PRO_EQPT_CRITRATE] = {
        {
          "addPhysicalProNum",
          "addPhysicalProNumRandom"
        }
      },
      [ITEM_PRO_EQPT_KUANGBAORATE] = {
        {
          "addPhysicalProNum",
          "addPhysicalProNumRandom"
        }
      },
      [ITEM_PRO_EQPT_LJRATE] = {
        {
          "addPhysicalProNum",
          "addPhysicalProNumRandom"
        }
      },
      [ITEM_PRO_EQPT_FJRATE] = {
        {
          "addPhysicalProNum",
          "addPhysicalProNumRandom"
        }
      },
      [ITEM_PRO_EQPT_PASSIVE_PHYSICAL_RATE] = {
        {
          "item_passive_physical_rate",
          "item_passive_physical_rate_Random"
        }
      },
      [ITEM_PRO_EQPT_PASSIVE_PHYSICAL] = {
        {
          "item_passive_physical",
          "item_passive_physical_Random"
        }
      },
      [ITEM_PRO_EQPT_FKHUNSHUI] = {
        {
          "addFKangNum",
          "addFKangNumRandom"
        }
      },
      [ITEM_PRO_EQPT_FKHUNLUAN] = {
        {
          "addFKangNum",
          "addFKangNumRandom"
        }
      },
      [ITEM_PRO_EQPT_FKFENGYIN] = {
        {
          "addFKangNum",
          "addFKangNumRandom"
        }
      },
      [ITEM_PRO_EQPT_FKHUO] = {
        {
          "addFKangNum",
          "addFKangNumRandom"
        }
      },
      [ITEM_PRO_EQPT_FKFENG] = {
        {
          "addFKangNum",
          "addFKangNumRandom"
        }
      },
      [ITEM_PRO_EQPT_FKLEI] = {
        {
          "addFKangNum",
          "addFKangNumRandom"
        }
      },
      [ITEM_PRO_EQPT_FKSHUI] = {
        {
          "addFKangNum",
          "addFKangNumRandom"
        }
      },
      [ITEM_PRO_EQPT_FKZHONGDU] = {
        {
          "item_add_magic_du_rate",
          "item_add_magic_du_rate_Random"
        }
      },
      [ITEM_PRO_EQPT_BASEDEF] = {
        {
          "baseDef",
          "baseDefRandom"
        }
      },
      [ITEM_PRO_EQPT_DEL_DU] = {
        {
          "addKangDuXiXueNum",
          "addKangDuXiXueNum_Random"
        }
      },
      [ITEM_PRO_EQPT_KXIXUE] = {
        {
          "addKangDuXiXueNum",
          "addKangDuXiXueNum_Random"
        }
      },
      [ITEM_PRO_EQPT_KAIHAO] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangXianNum",
          "addKangXianNumRandom"
        }
      },
      [ITEM_PRO_EQPT_KYIWANG] = {
        {
          "addKangNum",
          "addKangNumRandom"
        },
        {
          "addKangRenNum",
          "addKangRenNumRandom"
        },
        {
          "addKangRenExNum",
          "addKangRenExNumRandom"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_SHUAIRUO] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        },
        {
          "item_add_magic_shuairuo",
          "item_add_magic_shuairuo_Random"
        },
        {
          "r_magic_shuairuo",
          "r_magic_shuairuo_Random"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_YIWANG_RATE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        },
        {
          "item_add_magic_yiwang_rate",
          "item_add_magic_yiwang_rate_Random"
        },
        {
          "r_magic_shuairuo",
          "r_magic_shuairuo_Random"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_AIHAO] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        },
        {
          "item_add_magic_aihao",
          "item_add_magic_aihao_Random"
        },
        {
          "r_magic_aihao",
          "r_magic_aihao_Random"
        }
      },
      [ITEM_PRO_EQPT_STRENGTHEN_MAGIC_XIXUE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        },
        {
          "item_add_magic_xixue",
          "item_add_magic_xixue_Random"
        },
        {
          "r_magic_xixue",
          "r_magic_xixue_Random"
        }
      },
      [ITEM_PRO_EQPT_ADDXIXUEHUIXUE] = {
        {
          "addSkillNum",
          "addSkillNumRandom"
        },
        {
          "addxixuehuixue",
          "addxixuehuixue_Random"
        },
        {
          "r_addxixuehuixue",
          "r_addxixuehuixue_Random"
        }
      },
      [ITEM_PRO_EQPT_FKYIWANG] = {
        {
          "nokangyiwang",
          "nokangyiwang_Random"
        },
        {
          "r_nokangyiwang",
          "r_nokangyiwang_Random"
        }
      }
    }
    if tempDict[proName] == nil then
      return false
    end
    for _, tempStrList in pairs(tempDict[proName]) do
      if eData[tempStrList[1]] and eData[tempStrList[2]] and eData[tempStrList[1]] ~= 0 then
        local maxValue = eData[tempStrList[1]] * eData[tempStrList[2]][2]
        local showType
        for _, data in pairs(ITEM_PRO_SHOW_BASE_DICT) do
          if data[1] == proName then
            showType = data[3]
            break
          end
        end
        if showType ~= Pro_Value_PERCENT_TYPE then
          maxValue = math.floor(maxValue)
        end
        if value >= maxValue then
          return true
        end
      end
    end
    return false
  end
  function object:ClearCangkuPosData(itemObjID, pos)
    print("ClearCangkuPosData", itemObjID, pos)
    if pos ~= 0 and object.m_CangkuPosDict[pos] == itemObjID then
      object.m_CangkuPosDict[pos] = nil
      if object == g_LocalPlayer then
        SendMessage(MsgID_ItemInfo_CangkuPosClear, pos)
      end
    end
    local itemIns = object.m_CangkuDict[itemObjID]
    if itemIns ~= nil and itemIns:getProperty(ITME_PRO_PACKAGE_POS) == pos then
      object:SetSvrProToCangkuItem(itemIns, {i_pos = 0})
    end
  end
  function object:SetCangkuPosData(itemObjID, pos)
    if pos ~= 0 then
      object.m_CangkuPosDict[pos] = itemObjID
    end
    local itemIns = object.m_CangkuDict[itemObjID]
    if itemIns ~= nil then
      object:SetSvrProToCangkuItem(itemIns, {i_pos = pos})
    end
  end
  function object:SetOneCangkuItem(itemId, lTypeId, svrPro)
    local itemIns = object.m_CangkuDict[itemId]
    print("SetOneCangkuItem", itemId, "###111")
    local newFlag = false
    if itemIns == nil then
      newFlag = true
      itemIns = object:newItemObject(itemId, lTypeId)
      if itemIns == nil then
        print("SetOneCangkuItem", itemId, "###2222")
        return
      end
      object.m_CangkuDict[itemId] = itemIns
    end
    local oldPos = itemIns:getProperty(ITME_PRO_PACKAGE_POS)
    object:SetSvrProToCangkuItem(itemIns, svrPro)
    local newPos = itemIns:getProperty(ITME_PRO_PACKAGE_POS)
    if newPos ~= oldPos then
      object:ClearCangkuPosData(itemId, oldPos)
      object:SetCangkuPosData(itemId, newPos)
    end
    if lTypeId == nil then
      lTypeId = itemIns:getTypeId()
    end
    if object == g_LocalPlayer then
      local num = itemIns:getProperty(ITEM_PRO_NUM)
      if newFlag then
        SendMessage(MsgID_ItemInfo_AddCangkuItem, itemId, num, lTypeId)
      else
        SendMessage(MsgID_ItemInfo_ChangeCangkuItemNum, itemId, num, lTypeId)
      end
    end
  end
  function object:SetSvrProToCangkuItem(itemIns, svrPro)
    local proTable = {}
    local oldProTable = {}
    for k, v in pairs(svrPro) do
      local pro = ITEM_SVRKEY_PROPERTIES[k]
      if pro then
        local oldV = itemIns:getProperty(pro)
        if oldV ~= v then
          itemIns:setProperty(pro, v)
          proTable[pro] = v
          oldProTable[pro] = oldV
        end
      end
    end
    if table_is_empty(proTable) == false and object == g_LocalPlayer then
      SendMessage(MsgID_ItemInfo_CangkuItemUpdate, {
        itemType = itemIns:getTypeId(),
        itemId = itemIns:getObjId(),
        pro = proTable,
        oldPro = oldProTable
      })
    end
    if svrPro.i_pos then
      SendMessage(MsgID_ItemInfo_ItemCangkuPosUpdate, {
        itemId = itemIns:getObjId(),
        pos = svrPro.i_pos
      })
    end
  end
  function object:DelOneCangkuItem(itemId)
    local itemIns = object.m_CangkuDict[itemId]
    if itemIns == nil then
      printLog("PackageExtend222", "error ~~~~异常1删除本地没有的物品ItemId%d", itemId)
    else
      local oldPos = itemIns:getProperty(ITME_PRO_PACKAGE_POS)
      object:ClearCangkuPosData(itemId, oldPos)
      object.m_CangkuDict[itemId] = nil
      local lTypeId = itemIns:getTypeId()
      if object == g_LocalPlayer then
        SendMessage(MsgID_ItemInfo_DelCangkuItem, itemId, lTypeId, oldPos)
      end
    end
  end
  function object:GetCangkuItemIdByCangkuPos(pos)
    return object.m_CangkuPosDict[pos]
  end
  function object:GetOneCangkuItem(itemId)
    local itemIns = object.m_CangkuDict[itemId]
    if itemIns == nil then
      if itemId == nil then
        printLog("PackageExtend222", "~~~~异常获取没有的物品ItemId为nil")
      else
        printLog("PackageExtend222", "error ~~~~异常2获取没有的物品ItemId%d", itemId)
      end
    end
    return itemIns
  end
  function object:ObjectItemPropertyChanged(obj, propertyType, changedType, value_new, value_old)
  end
end
return PackageExtend
