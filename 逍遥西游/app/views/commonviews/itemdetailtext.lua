function getSourceItemDataByOrder(od, tb)
  if tb == nil or od == nil then
    return nil
  end
  for k, v in pairs(tb) do
    if v ~= nil and type(v) == "table" and v.taskJumpNum == od then
      return v
    end
  end
  return nil
end
function JumpToItemSourceFromTask(itemId, tonpc, mid)
  print("跳转到物品的来源去", itemId, tonpc, mid)
  local tempData = data_ItemSource[itemId]
  if tempData == nil then
    return
  end
  local orderBy = 6
  for index = 1, orderBy do
    local dataTb = getSourceItemDataByOrder(index, tempData)
    dump(dataTb, " 找到 的物品 ")
    if dataTb ~= nil and dataTb.para ~= nil then
      if dataTb.para[1] == Item_Source_JumpTo_Market then
        local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Market)
        if openFlag == true then
          JumpToItemSource(itemId, dataTb.para, tonpc, mid)
          return
        end
      else
        JumpToItemSource(itemId, dataTb.para, tonpc, mid)
        return
      end
    end
  end
  print(" 按照优先级并没找到 相关物品对应的数据 ")
end
function JumpToItemSource(itemId, para, tonpc, mid)
  print("  任务 物品来源跳转 ====》》》  ", itemId, para, tonpc, mid)
  local openType = para[1]
  SendMessage(MsgID_ItemSource_Jump, para)
  if openType == Item_Source_JumpTo_Shop_Daoju or openType == Item_Source_JumpTo_Shop_Smsd or openType == Item_Source_JumpTo_Shop_Drug then
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shangcheng)
    if openFlag == false then
      ShowNotifyTips(tips)
    else
      local tempView = CStoreShow.new({InitStoreShow = StoreShow_ShopView, itmeTypeId = itemId})
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
      if openType == Item_Source_JumpTo_Shop_Daoju then
        tempView:SetShopBtnClick(Shop_Daoju_Page)
      elseif openType == Item_Source_JumpTo_Shop_Smsd then
        tempView:SetShopBtnClick(Shop_Smsd_Page)
      elseif openType == Item_Source_JumpTo_Shop_Drug then
        tempView:SetShopBtnClick(Shop_Drug_Page)
      end
    end
  elseif openType == Item_Source_JumpTo_PvpShop_Neidan or openType == Item_Source_JumpTo_PvpShop_Daoju then
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Biwu)
    if openFlag == false then
      ShowNotifyTips(tips)
    else
      local tempView = PvpShopView.new()
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
      if openType == Item_Source_JumpTo_PvpShop_Neidan then
        tempView:SetShopBtnClick(Shop_Honour_Nd_Page)
      elseif openType == Item_Source_JumpTo_PvpShop_Daoju then
        tempView:SetShopBtnClick(Shop_Honour_Tool_Page)
      end
    end
  elseif openType == Item_Source_JumpTo_Dayanta then
    local tips = g_LocalPlayer:getPlayerCanJumpToNpc()
    if tips ~= true then
      ShowNotifyTips(tips)
      return
    end
    local openFlag = g_LocalPlayer:isNpcOptionUnlock(1026)
    if openFlag == false then
      ShowNotifyTips(string.format("%d级开启大雁塔", data_NpcTypeInfo[1026].lv))
    else
      g_MapMgr:AutoRouteToNpc(activity.dayanta.StartNpcId, function(isSucceed)
        if isSucceed then
          g_CurSceneView:addSubView({
            subView = DayataEntrance.new(para[2]),
            zOrder = MainUISceneZOrder.menuView
          })
        end
      end)
    end
  elseif openType == Item_Source_JumpTo_Market then
    if tonpc == true then
      g_MapMgr:AutoRouteToNpc(90024, function(isSucceed)
        if isSucceed and CMainUIScene.Ins and isSucceed then
          enterMarket({initItemType = itemId, m_mid = mid})
        end
      end)
    else
      enterMarket({initItemType = itemId})
    end
  elseif openType == Item_Source_JumpTo_Shop_NPC then
    local tips = g_LocalPlayer:getPlayerCanJumpToNpc()
    if tips ~= true then
      ShowNotifyTips(tips)
      return
    end
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shangcheng)
    if openFlag == false then
      ShowNotifyTips(tips)
    else
      do
        local npcId
        local tempDict = {
          [90910] = {data_Shop_NPC_Yaopin},
          [90908] = {data_Shop_NPC_Zawu},
          [90003] = {
            data_Shop_NPC_Yifu,
            data_Shop_NPC_Maozi,
            data_Shop_NPC_XieziXianglian
          },
          [90002] = {data_Shop_NPC_Wuqi}
        }
        for tempNpcId, dataList in pairs(tempDict) do
          for index, data in ipairs(dataList) do
            if data[itemId] ~= nil then
              npcId = tempNpcId
              break
            end
          end
          if npcId ~= nil then
            break
          end
        end
        if npcId ~= nil then
          g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
            if isSucceed then
              local tempView = ShopNPCView.new(npcId, itemId, mid)
              getCurSceneView():addSubView({
                subView = tempView,
                zOrder = MainUISceneZOrder.menuView
              })
            end
          end)
        end
      end
    end
  elseif openType == Item_Source_JumpTo_GuajiMap then
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_DoubleExp)
    if openFlag == false then
      ShowNotifyTips(tips)
    else
      ShowGuajiMenu()
    end
  elseif openType == Item_Source_JumpTo_Baitan then
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Market)
    if openFlag == false then
      ShowNotifyTips(tips)
    else
      do
        local initPara = {
          initViewType = MarketShow_InitShow_CoinView,
          initBaitanType = BaitanShow_InitShow_ShoppingView,
          initBaitanMainType = data_getBaitanItemMainType(itemId),
          initBaitanSubType = data_getBaitanItemSubType(itemId),
          initItemType = itemId,
          itemID = itemId,
          m_mid = mid
        }
        if tonpc == true then
          g_MapMgr:AutoRouteToNpc(90024, function(isSucceed)
            if isSucceed and CMainUIScene.Ins and isSucceed then
              enterMarket(initPara)
            end
          end)
        else
          enterMarket(initPara)
        end
      end
    end
  elseif openType == Item_Source_JumpTo_TTHJ then
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_TTHJ)
    if openFlag == false then
      ShowNotifyTips(tips)
    else
      g_MapMgr:AutoRouteToNpc(NPC_HuangChengShouJiang_ID, function(isSucceed)
        if isSucceed then
          ShowTTHJView()
        end
      end)
    end
  elseif openType == Item_Source_JumpTo_CangBaoTu then
    local itemId = g_LocalPlayer:GetOneItemIdByType(ITEM_DEF_OTHER_ZBT)
    if itemId ~= 0 and itemId ~= nil then
      local tempView = CMainRoleView.new({jumpToItemId = itemId})
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
      tempView:ShowPackageDetail(itemId, false)
      return
    else
      g_MapMgr:AutoRouteToNpc(NPC_JIUGUANLAOBAN_ID, function(isSucceed)
        if isSucceed and CMainUIScene.Ins and isSucceed then
          CMainUIScene.Ins:ShowNormalNpcViewById(NPC_JIUGUANLAOBAN_ID)
        end
      end)
      return
    end
  elseif openType == Item_Source_JumpTo_HuoLiView then
    openUseEnergyView()
    return
  elseif openType == Item_Source_JumpTo_TianDiQiShu then
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_TianDiQiShu)
    if openFlag == false then
      ShowNotifyTips(tips)
    else
      g_MapMgr:AutoRouteToNpc(NPC_TianShuLaoRen_ID, function(isSucceed)
        if isSucceed and CMainUIScene.Ins and isSucceed then
          CMainUIScene.Ins:ShowNormalNpcViewById(NPC_TianShuLaoRen_ID)
        end
      end)
    end
    return
  end
end
CItemDetailText = class("CItemDetailText", CRichText)
function CItemDetailText:ctor(itemObjId, richTextPara, itemType, eqptRoleId, playerId, showSource, sizeChangeListener, isMarket)
  self.isMarket = isMarket
  richTextPara = richTextPara or {
    width = 150,
    verticalSpace = 0,
    emptyLineH = 20,
    clickTextHandler = nil,
    font = KANG_TTF_FONT
  }
  richTextPara.font = KANG_TTF_FONT
  CItemDetailText.super.ctor(self, richTextPara)
  self.m_ItemObjId = itemObjId
  self.m_ItemType = itemType
  self.m_PlayerId = playerId
  self.m_EqptRoleId = eqptRoleId
  self.m_ShowSource = showSource
  self.m_SizeChangeListener = sizeChangeListener
  if self.m_ShowSource == nil then
    self.m_ShowSource = true
  end
  self:setItemDetialText()
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_ItemInfo)
end
function CItemDetailText:GetItemObj()
  local player
  if self.isMarket then
    player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
  else
    player = g_DataMgr:getPlayer(self.m_PlayerId)
  end
  local itemObj
  if self.m_ItemObjId ~= nil then
    itemObj = player:GetOneItem(self.m_ItemObjId)
  end
  return itemObj
end
function CItemDetailText:setItemDetialText()
  local itemObj = self:GetItemObj()
  if itemObj == nil then
    local tempClassDict = {
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
    local clsKey = GetItemTypeByItemTypeId(self.m_ItemType)
    local tempClass = tempClassDict[tostring(clsKey)] or CEqptData
    local tempItemIns = tempClass.new(nil, nil, self.m_ItemType)
    local itemType = tempItemIns:getType()
    if self.m_ItemType == ITEM_FIRST_LV_CHIBANG then
      self:addEqptLevel(tempItemIns)
      self:addEqptPos(tempItemIns)
      self:addItemTips(tempItemIns)
      self:addItemDes(tempItemIns)
      self:addItemWingTips(nil)
    elseif itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_SHENBING or itemType == ITEM_LARGE_TYPE_XIANQI or itemType == ITEM_LARGE_TYPE_HUOBANEQPT then
      if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_HUOBANEQPT then
      else
        self:addEqptLevel(tempItemIns)
      end
      self:addEqptPos(tempItemIns)
      self:addEqptRole(tempItemIns)
      self:addEqptNeedLv(tempItemIns)
      self:addEqptNeedPro(tempItemIns)
      self:addItemTips(tempItemIns)
      self:addItemDes(tempItemIns)
    elseif itemType == ITEM_LARGE_TYPE_LIANYAOSHI then
      self:addLianyaoshiEffect(tempItemIns)
      self:addItemTips(tempItemIns)
      self:addItemDes(tempItemIns)
      self:addSource(tempItemIns)
    elseif itemType == ITEM_LARGE_TYPE_LIFEITEM then
      self:addItemTips(tempItemIns)
      self:addSource(tempItemIns)
    else
      self:addItemTips(tempItemIns)
      self:addItemDes(tempItemIns)
      self:addSource(tempItemIns)
    end
    return
  end
  local itemType = itemObj:getType()
  local itemTypeId = itemObj:getTypeId()
  if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_SHENBING or itemType == ITEM_LARGE_TYPE_XIANQI or itemType == ITEM_LARGE_TYPE_HUOBANEQPT then
    local eqptType = itemObj:getProperty(ITEM_PRO_EQPT_TYPE)
    if eqptType == ITEM_DEF_EQPT_WEAPON_CHIBANG then
      self:addEqptLevel(itemObj)
      self:addEqptPos(itemObj)
      self:addItemWingBasePro(itemObj)
      self:addEqptLianhuaPro(itemObj)
      self:addItemTips(itemObj)
      self:addItemDes(itemObj)
      self:addItemWingTips(itemObj)
    else
      if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_HUOBANEQPT then
      else
        self:addEqptLevel(itemObj)
      end
      self:addEqptPos(itemObj)
      self:addEqptRole(itemObj)
      self:addEqptNeedLv(itemObj)
      self:addEqptNeedPro(itemObj)
      self:addEqptBasePro(itemObj)
      self:addEqptQianghuaPro(itemObj)
      self:addEqptLianhuaPro(itemObj)
      self:addItemTips(itemObj)
      self:addItemDes(itemObj)
    end
  elseif itemType == ITEM_LARGE_TYPE_LIANYAOSHI then
    self:addLianyaoshiEffect(itemObj)
    self:addItemTips(itemObj)
    self:addItemDes(itemObj)
  elseif itemType == ITEM_LARGE_TYPE_NEIDAN then
    self:addNeidanSkill(itemObj)
    self:addItemTips(itemObj)
    local player
    if self.isMarket then
      player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
    else
      player = g_DataMgr:getPlayer(self.m_PlayerId)
    end
    local roleIns = player:getObjById(self.m_EqptRoleId)
    local isOnRole = player:ItemIsOnRole(self.m_ItemObjId, self.m_EqptRoleId)
    if roleIns == nil or not isOnRole then
      self:addItemDes(itemObj)
    end
    self:addNeidanLevelInfo(itemObj)
  elseif itemType == ITEM_LARGE_TYPE_DRUG then
    self:addItemTips(itemObj)
    self:addItemDes(itemObj)
    self:addSource(itemObj)
  elseif itemType == ITEM_LARGE_TYPE_LIFEITEM then
    self:addItemLifeDes(itemObj)
    self:addItemDes(itemObj)
    self:addSource(itemObj)
  elseif itemType == ITEM_LARGE_TYPE_STUFF then
    self:addItemTips(itemObj)
    self:addItemDes(itemObj)
    self:addSource(itemObj)
  elseif itemTypeId == ITEM_DEF_OTHER_ZBT or itemTypeId == ITEM_DEF_OTHER_GJZBT then
    self:addItemTips(itemObj)
    self:addItemDes(itemObj)
    self:addSource(itemObj)
  elseif itemType == ITEM_LARGE_TYPE_OTHERITEM and GetItemSubTypeByItemTypeId(itemTypeId) == ITEM_DEF_TYPE_SKILLBOOK then
    self:addItemSkillBookNeedPro(itemObj)
    self:addItemSkillBookNeedWuXing(itemObj)
    self:addItemTips(itemObj)
    self:addItemDes(itemObj)
    self:addSource(itemObj)
  else
    self:addItemTips(itemObj)
    self:addItemDes(itemObj)
    self:addSource(itemObj)
  end
end
function CItemDetailText:addEqptLevel(itemObj)
  local lv = itemObj:getProperty(ITEM_PRO_LV)
  if lv <= 0 then
    return
  end
  local lvStr = string.format("【等级】%d级\n", lv)
  self:addRichText(lvStr)
end
function CItemDetailText:addEqptPos(itemObj)
  local eqptType = itemObj:getProperty(ITEM_PRO_EQPT_TYPE)
  self:addRichText(string.format("【装备部位】%s\n", EPQT_POS_2_EQPT_POSNAME[EPQT_TYPE_2_EQPT_POS[eqptType]]))
end
function CItemDetailText:addEqptRole(itemObj)
  local player
  if self.isMarket then
    player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
  else
    player = g_DataMgr:getPlayer(self.m_PlayerId)
  end
  local roleIns = player:getObjById(self.m_EqptRoleId)
  if roleIns ~= nil and roleIns:getType() == LOGICTYPE_HERO and self.m_EqptRoleId ~= player:getMainHeroId() then
    return
  end
  local hkind = itemObj:getProperty(ITEM_PRO_EQPT_HKIND)
  if hkind == 0 or hkind == nil then
    hkind = {0}
  end
  local sex = itemObj:getProperty(ITEM_PRO_EQPT_SEX)
  if #hkind == 1 and (hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN) then
    if hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET then
      if sex == ITEM_DEF_EQPT_SEX_MALE then
        if roleIns ~= nil and roleIns:getProperty(PROPERTY_GENDER) ~= sex then
          self:addRichText("#<CWA>【装备角色】男性角色##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】男性角色\n")
        end
      elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
        if roleIns ~= nil and roleIns:getProperty(PROPERTY_GENDER) ~= sex then
          self:addRichText("#<CWA>【装备角色】女性角色##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】女性角色\n")
        end
      end
    elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI then
      if sex == ITEM_DEF_EQPT_SEX_MALE then
        if roleIns ~= nil and (roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_GUI) then
          self:addRichText("#<CWA>【装备角色】男性鬼族##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】男性鬼族\n")
        end
      elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
        if roleIns ~= nil and (roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_GUI) then
          self:addRichText("#<CWA>【装备角色】女性鬼族##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】女性鬼族\n")
        end
      elseif roleIns ~= nil and roleIns:getProperty(PROPERTY_RACE) ~= RACE_GUI then
        self:addRichText("#<CWA>【装备角色】鬼族##<CWA,F:19>(条件不足)#\n")
      else
        self:addRichText("【装备角色】鬼族\n")
      end
    elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO then
      if sex == ITEM_DEF_EQPT_SEX_MALE then
        if roleIns ~= nil and (roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_MO) then
          self:addRichText("#<CWA>【装备角色】男性魔族##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】男性魔族\n")
        end
      elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
        if roleIns ~= nil and (roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_MO) then
          self:addRichText("#<CWA>【装备角色】女性魔族##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】女性魔族\n")
        end
      elseif roleIns ~= nil and roleIns:getProperty(PROPERTY_RACE) ~= RACE_MO then
        self:addRichText("#<CWA>【装备角色】魔族##<CWA,F:19>(条件不足)#\n")
      else
        self:addRichText("【装备角色】魔族\n")
      end
    elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN then
      if sex == ITEM_DEF_EQPT_SEX_MALE then
        if roleIns ~= nil and (roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_XIAN) then
          self:addRichText("#<CWA>【装备角色】男性仙族##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】男性仙族\n")
        end
      elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
        if roleIns ~= nil and (roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_XIAN) then
          self:addRichText("#<CWA>【装备角色】女性仙族##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】女性仙族\n")
        end
      elseif roleIns ~= nil and roleIns:getProperty(PROPERTY_RACE) ~= RACE_XIAN then
        self:addRichText("#<CWA>【装备角色】仙族##<CWA,F:19>(条件不足)#\n")
      else
        self:addRichText("【装备角色】仙族\n")
      end
    elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN then
      if sex == ITEM_DEF_EQPT_SEX_MALE then
        if roleIns ~= nil and (roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_REN) then
          self:addRichText("#<CWA>【装备角色】男性人族##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】男性人族\n")
        end
      elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
        if roleIns ~= nil and (roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_REN) then
          self:addRichText("#<CWA>【装备角色】女性人族##<CWA,F:19>(条件不足)#\n")
        else
          self:addRichText("【装备角色】女性人族\n")
        end
      elseif roleIns ~= nil and roleIns:getProperty(PROPERTY_RACE) ~= RACE_REN then
        self:addRichText("#<CWA>【装备角色】人族##<CWA,F:19>(条件不足)#\n")
      else
        self:addRichText("【装备角色】人族\n")
      end
    end
  elseif #hkind > 0 then
    local canUse = false
    if roleIns ~= nil then
      local roleType = roleIns:getTypeId()
      for _, tempTypeid in pairs(hkind) do
        if tempTypeid == roleType then
          canUse = true
          break
        end
      end
    else
      canUse = true
    end
    local text = ""
    for i, roleTypeID in pairs(hkind) do
      local name = data_Hero[roleTypeID].NAME
      if i == 1 then
        text = text .. string.format("【装备角色】%s", name)
      else
        text = text .. string.format("、%s", name)
      end
    end
    if canUse then
      self:addRichText(text)
    else
      self:addRichText(string.format("#<CWA>%s##<CWA,F:19>(条件不足)#", text))
    end
    self:newLine()
  end
end
function CItemDetailText:addEqptNeedLv(itemObj)
  local itemType = itemObj:getType()
  local nZs = itemObj:getProperty(ITEM_PRO_EQPT_ZSLIMIT)
  local nLv = itemObj:getProperty(ITEM_PRO_EQPT_LVLIMIT)
  if nZs == 0 and nLv == 0 then
    return
  end
  if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_XIANQI or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_HUOBANEQPT then
    local player
    if self.isMarket then
      player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
    else
      player = g_DataMgr:getPlayer(self.m_PlayerId)
    end
    local roleIns = player:getObjById(self.m_EqptRoleId)
    local canUse = true
    if roleIns then
      if nZs > roleIns:getProperty(PROPERTY_ZHUANSHENG) then
        canUse = false
      elseif roleIns:getProperty(PROPERTY_ZHUANSHENG) == nZs and roleIns:getProperty(PROPERTY_ROLELEVEL) < nLv - itemObj:getProperty(ITEM_PRO_EQPT_LH_LVLIMIT) then
        canUse = false
      end
    end
    if nZs == 0 then
      if canUse then
        self:addRichText(string.format("#<CBA>等级需求 %d级#\n", nLv))
      else
        self:addRichText(string.format("#<CWA>等级需求 %d级##<CWA,F:19>(条件不足)#\n", nLv))
      end
    elseif nLv == 0 then
      if canUse then
        self:addRichText(string.format("#<CBA>等级需求 %d转#\n", nZs))
      else
        self:addRichText(string.format("#<CWA>等级需求 %d转##<CWA,F:19>(条件不足)#\n", nZs))
      end
    elseif canUse then
      self:addRichText(string.format("#<CBA>等级需求 %d转%d级#\n", nZs, nLv))
    else
      self:addRichText(string.format("#<CWA>等级需求 %d转%d级##<CWA,F:19>(条件不足)#\n", nZs, nLv))
    end
  elseif itemType == ITEM_LARGE_TYPE_SHENBING then
  end
end
function CItemDetailText:addEqptNeedPro(itemObj)
  local player
  if self.isMarket then
    player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
  else
    player = g_DataMgr:getPlayer(self.m_PlayerId)
  end
  local roleIns = player:getObjById(self.m_EqptRoleId)
  local tempRoleProNameList = {
    [ITEM_PRO_EQPT_NEEDLL] = {
      PROPERTY_OLiLiang,
      PROPERTY_LiLiang,
      PROPERTY_Wing_LiLiang
    },
    [ITEM_PRO_EQPT_NEEDMJ] = {
      PROPERTY_OMinJie,
      PROPERTY_MinJie,
      PROPERTY_Wing_MinJie
    },
    [ITEM_PRO_EQPT_NEEDLX] = {
      PROPERTY_OLingxing,
      PROPERTY_Lingxing,
      PROPERTY_Wing_Lingxing
    },
    [ITEM_PRO_EQPT_NEEDGG] = {
      PROPERTY_OGenGu,
      PROPERTY_GenGu,
      PROPERTY_Wing_GenGu
    }
  }
  for proName, str in pairs({
    [ITEM_PRO_EQPT_NEEDLL] = "力量要求",
    [ITEM_PRO_EQPT_NEEDMJ] = "敏捷要求",
    [ITEM_PRO_EQPT_NEEDLX] = "灵性要求",
    [ITEM_PRO_EQPT_NEEDGG] = "根骨要求"
  }) do
    local tempNum = itemObj:getProperty(proName)
    if tempNum > 0 then
      if roleIns ~= nil then
        if roleIns:getProperty(tempRoleProNameList[proName][1]) + roleIns:GetZhuangBeiAddNum(tempRoleProNameList[proName][2]) + roleIns:getProperty(tempRoleProNameList[proName][3]) < itemObj:getProperty(proName) * (1 - itemObj:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)) then
          self:addRichText(string.format("#<CWA>%s %d##<CWA,F:19>(条件不足)#\n", str, tempNum))
        else
          self:addRichText(string.format("#<CBA>%s %d#\n", str, tempNum))
        end
      else
        self:addRichText(string.format("#<CBA>%s %d#\n", str, tempNum))
      end
    end
  end
end
function CItemDetailText:addEqptBasePro(itemObj)
  local bsNum = itemObj:getProperty(ITME_PRO_EQPT_BAOSHINUM)
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
        self:addRichText(string.format("#<%s>%s %s%d#\n", color, str, addFlag, math.floor(math.abs(tempNum))))
      elseif tempType == Pro_Value_PERCENT_TYPE then
        self:addRichText(string.format("#<%s>%s %s%s%%#\n", color, str, addFlag, Value2Str(math.abs(tempNum) * 100, 1)))
      end
    end
  end
end
function CItemDetailText:addEqptQianghuaPro(itemObj)
  local holeNum = itemObj:getProperty(ITME_PRO_EQPT_HOLENUM)
  local bsNum = itemObj:getProperty(ITME_PRO_EQPT_BAOSHINUM)
  if holeNum < bsNum then
    bsNum = holeNum
  end
  if holeNum <= 0 then
    return
  else
    local dict = {}
    dict[#dict + 1] = "#<CQH>强化#"
    for i = 1, math.min(bsNum, 5) do
      dict[#dict + 1] = "#<IBSB>#"
    end
    for i = 1, math.min(bsNum - 5, 5) do
      dict[#dict + 1] = "#<IBSG>#"
    end
    for i = 1, math.min(bsNum - 10, 5) do
      dict[#dict + 1] = "#<IBSY>#"
    end
    for i = 1, math.min(bsNum - 15, 5) do
      dict[#dict + 1] = "#<IBSR>#"
    end
    for i = 1, math.min(bsNum - 20, 5) do
      dict[#dict + 1] = "#<IBSP>#"
    end
    for i = 1, holeNum - bsNum do
      dict[#dict + 1] = "#<IH>#"
    end
    dict[#dict + 1] = "\n"
    local text = table.concat(dict)
    self:addRichText(text)
  end
end
function CItemDetailText:addEqptLianhuaPro(itemObj)
  local itemType = itemObj:getType()
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
        self:addRichText(string.format("#<%s>%s %s%d#\n", color, str, addFlag, math.floor(math.abs(tempNum))))
      elseif tempType == Pro_Value_PERCENT_TYPE then
        self:addRichText(string.format("#<%s>%s %s%s%%#\n", color, str, addFlag, Value2Str(math.abs(tempNum) * 100, 1)))
      end
    end
  end
  local lvlimit = itemObj:getProperty(ITEM_PRO_EQPT_LH_LVLIMIT)
  if lvlimit ~= 0 then
    self:addRichText(string.format("#<%s>装备等级需求 -%d#\n", color, math.abs(lvlimit)))
  end
  local prolimit = itemObj:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)
  if prolimit ~= 0 then
    self:addRichText(string.format("#<%s>装备属性需求 -%d%%#\n", color, math.abs(prolimit) * 100))
  end
end
function CItemDetailText:addLianyaoTimes()
  if self.m_EqptRoleId == nil then
    return
  end
  local player
  if self.isMarket then
    player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
  else
    player = g_DataMgr:getPlayer(self.m_PlayerId)
  end
  local roleObj = player:getObjById(self.m_EqptRoleId)
  if roleObj then
    local zs = roleObj:getProperty(PROPERTY_ZHUANSHENG)
    local maxTimes = CalculatePetLianYaoLimit(zs)
    local curTimes = roleObj:getProperty(PROPERTY_LIANYAO_NUM)
    self:addRichText(string.format("炼妖次数:%d/%d\n", curTimes, maxTimes))
  end
end
function CItemDetailText:addLianyaoshiEffect(itemObj)
  local itemType = itemObj:getTypeId()
  if itemType == ITEM_DEF_STUFF_WLD then
    return
  end
  local kangxingList = itemObj:getProperty(ITEM_PRO_LIANYAOSHI_KX)
  local kangxingValueList = itemObj:getProperty(ITEM_PRO_LIANYAOSHI_KXV)
  local kangxingStr = ""
  for i, kx in pairs(kangxingList) do
    if i ~= 1 then
      kangxingStr = kangxingStr .. ","
    end
    local kxName = LIANYAOSHI_KANGNAME[kx]
    local kxValue = kangxingValueList[i] or 0
    if kx == LIANYAOSHI_KANGXIXUE_NUMBER then
      kangxingStr = kangxingStr .. string.format("%s+%d", kxName, kxValue)
    else
      kangxingStr = kangxingStr .. string.format("%s+%s%%", kxName, Value2Str(kxValue, 1))
    end
  end
  self:addRichText(string.format("#<CBA>%s#\n", kangxingStr))
end
function CItemDetailText:addNeidanSkill(itemObj)
  local skillId = itemObj:getTypeId()
  local skillName = data_getSkillName(skillId)
  local skillDes = data_getSkillDesc(skillId)
  local skillZS = itemObj:getProperty(ITEM_PRO_NEIDAN_ZS)
  local skillLV = itemObj:getProperty(ITEM_PRO_LV)
  local player
  if self.isMarket then
    player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
  else
    player = g_DataMgr:getPlayer(self.m_PlayerId)
  end
  local roleIns = player:getObjById(self.m_EqptRoleId)
  local isOnRole = player:ItemIsOnRole(self.m_ItemObjId, self.m_EqptRoleId)
  if roleIns ~= nil then
    if skillZS > roleIns:getProperty(PROPERTY_ZHUANSHENG) or roleIns:getProperty(PROPERTY_ZHUANSHENG) == skillZS and skillLV > roleIns:getProperty(PROPERTY_ROLELEVEL) then
      self:addRichText(string.format("#<CWA>技能等级:%d转%d级##<CWA,F:19>#\n", skillZS, skillLV))
    else
      self:addRichText(string.format("#<CBA>技能等级:##<G>%d##<CBA>转##<G>%d##<CBA>级#\n", skillZS, skillLV))
    end
  end
  if roleIns ~= nil and isOnRole then
    local skillId = itemObj:getTypeId()
    local des = skillDes
    if skillId == ITEM_DEF_NEIDAN_TMJT then
      local rate1, rate2 = _getNeiDanDamage_TianMoJieTi_DisPlay(roleIns)
      des = string.gsub(des, "#<PM>#", string.format("#<CBA>%s%%%%#", math.floor(rate1 * 10000) / 100))
      des = string.gsub(des, "#<PN>#", string.format("#<CBA>%s%%%%#", math.floor(rate2 * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_FGHY then
      local rate1, rate2 = _getNeiDanDamage_FenGuangHuaYing_DisPlay(roleIns)
      des = string.gsub(des, "#<PO>#", string.format("#<CBA>%s%%%%#", math.floor(rate1 * 10000) / 100))
      des = string.gsub(des, "#<PP>#", string.format("#<CBA>%s%%%%#", math.floor(rate2 * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_QMLY then
      local rate1, rate2 = _getNeiDanDamage_QingMianLiaoYa_DisPlay(roleIns)
      des = string.gsub(des, "#<PQ>#", string.format("#<CBA>%s%%%%#", math.floor(rate1 * 10000) / 100))
      des = string.gsub(des, "#<PR>#", string.format("#<CBA>%s%%%%#", math.floor(rate2 * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_XLYK then
      local rate1, rate2 = _getNeiDanDamage_XiaoLouYeKu_DisPlay(roleIns)
      des = string.gsub(des, "#<PS>#", string.format("#<CBA>%s%%%%#", math.floor(rate1 * 10000) / 100))
      des = string.gsub(des, "#<PT>#", string.format("#<CBA>%s%%%%#", math.floor(rate2 * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_CFPL then
      des = string.gsub(des, "#<PU>#", string.format("#<CBA>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_ChengFengPoLang(roleIns) * 10000) / 100))
      des = string.gsub(des, "#<PAM>#", string.format("#<CBA>%s#", _getNeiDanDamage_ChengFengPoLang(roleIns, 0, 0, true)))
    elseif skillId == ITEM_DEF_NEIDAN_PLLX then
      des = string.gsub(des, "#<PV>#", string.format("#<CBA>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_PiLiLiuXing(roleIns) * 10000) / 100))
      des = string.gsub(des, "#<PAN>#", string.format("#<CBA>%s#", _getNeiDanDamage_PiLiLiuXing(roleIns, 0, 0, true)))
    elseif skillId == ITEM_DEF_NEIDAN_DHWL then
      des = string.gsub(des, "#<PW>#", string.format("#<CBA>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_DaHaiWuLiang(roleIns) * 10000) / 100))
      des = string.gsub(des, "#<PAO>#", string.format("#<CBA>%s#", _getNeiDanDamage_DaHaiWuLiang(roleIns, 0, 0, true)))
    elseif skillId == ITEM_DEF_NEIDAN_ZRQH then
      des = string.gsub(des, "#<PX>#", string.format("#<CBA>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_ZhuRongQuHuo(roleIns) * 10000) / 100))
      des = string.gsub(des, "#<PAP>#", string.format("#<CBA>%s#", _getNeiDanDamage_ZhuRongQuHuo(roleIns, 0, 0, true)))
    elseif skillId == ITEM_DEF_NEIDAN_HYBF then
      local rate, effect = g_NeiDanSkill.getNeiDanPro_HongYanBaiFa(roleIns)
      des = string.gsub(des, "#<PY>#", string.format("#<CBA>%s%%%%#", math.floor(rate * 10000) / 100))
      des = string.gsub(des, "#<PZ>#", string.format("#<CBA>%s%%%%#", math.floor(effect * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_MHSN then
      local rate, effect = g_NeiDanSkill.getNeiDanPro_MeiHuaSanNong(roleIns)
      des = string.gsub(des, "#<PAA>#", string.format("#<CBA>%s%%%%#", math.floor(rate * 10000) / 100))
      des = string.gsub(des, "#<PAB>#", string.format("#<CBA>%s#", effect))
    elseif skillId == ITEM_DEF_NEIDAN_KTPD then
      local rate, effect = g_NeiDanSkill.getNeiDanPro_KaiTianPiDi(roleIns)
      des = string.gsub(des, "#<PAC>#", string.format("#<CBA>%s%%%%#", math.floor(rate * 10000) / 100))
      des = string.gsub(des, "#<PAD>#", string.format("#<CBA>%s%%%%#", math.floor(effect * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_WFCZ then
      local rate, effect = g_NeiDanSkill.getNeiDanPro_WanFoChaoZong(roleIns)
      des = string.gsub(des, "#<PAE>#", string.format("#<CBA>%s%%%%#", math.floor(rate * 10000) / 100))
      des = string.gsub(des, "#<PAF>#", string.format("#<CBA>%s%%%%#", math.floor(effect * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_HRZQ then
      local rate, effect = g_NeiDanSkill.getNeiDanPro_HaoRanZhengQi(roleIns)
      des = string.gsub(des, "#<PAG>#", string.format("#<CBA>%s%%%%#", math.floor(rate * 10000) / 100))
      des = string.gsub(des, "#<PAR>#", string.format("#<CBA>%s%%%%#", math.floor(effect * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_ADCC then
      local rate, _ = g_NeiDanSkill.getNeiDanPro_AnDuChenCang(roleIns)
      des = string.gsub(des, "#<PAH>#", string.format("#<CBA>%s%%%%#", math.floor(rate * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_JLDL then
      local rate, effect = g_NeiDanSkill.getNeiDanPro_JieLiDaLi(roleIns)
      des = string.gsub(des, "#<PAI>#", string.format("#<CBA>%s%%%%#", math.floor(rate * 10000) / 100))
      des = string.gsub(des, "#<PAQ>#", string.format("#<CBA>%s#", effect))
    elseif skillId == ITEM_DEF_NEIDAN_LBWB then
      des = string.gsub(des, "#<PAJ>#", string.format("#<CBA>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_LingBoWeiBu(roleIns) * 10000) / 100))
    elseif skillId == ITEM_DEF_NEIDAN_GSDN then
      local rate, effect = g_NeiDanSkill.getNeiDanPro_GeShanDaNiu(roleIns)
      des = string.gsub(des, "#<PAK>#", string.format("#<CBA>%s%%%%#", math.floor(rate * 10000) / 100))
      des = string.gsub(des, "#<PAL>#", string.format("#<CBA>%s%%%%#", math.floor(effect * 10000) / 100))
    end
    self:addRichText(string.format("#<CBA>%s:#%s\n", skillName, des))
  end
end
function CItemDetailText:addNeidanLevelInfo(itemObj)
  local skillId = itemObj:getTypeId()
  local skillName = data_getSkillName(skillId)
  local skillDes = data_getSkillDesc(skillId)
  local skillZS = itemObj:getProperty(ITEM_PRO_NEIDAN_ZS)
  local skillLV = itemObj:getProperty(ITEM_PRO_LV)
  local player
  if self.isMarket then
    player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
  else
    player = g_DataMgr:getPlayer(self.m_PlayerId)
  end
  local roleIns = player:getObjById(self.m_EqptRoleId)
  local lvLimit = CalculateNeidanLevelLimit(skillZS)
  local petObj = g_LocalPlayer:getObjById(self.m_EqptRoleId)
  if roleIns ~= nil and petObj ~= nil and player:ItemIsOnRole(self.m_ItemObjId, self.m_EqptRoleId) then
    self:newLine()
    self:newLine()
    self:addRichText("#<r:255,g:182,b:101>等级#")
    do
      local petZs = petObj:getProperty(PROPERTY_ZHUANSHENG)
      local petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
      local lvMax = petLv
      if skillZS < petZs then
        lvMax = lvLimit
      end
      local expBar = ProgressClip.new("views/zuoqi/pic_bar.png", "views/zuoqi/pic_barbg.png", skillLV, lvMax, true)
      expBar:showLabel(17, ccc3(255, 255, 255), string.format("%d/%d", skillLV, lvMax))
      self:addOneNode({obj = expBar, isWidget = true})
      self:addRichText(" ")
      local addBtn = createClickButton("views/common/btn/btn_add.png", nil, function()
        if skillZS > petZs then
          ShowNotifyTips("召唤兽转生次数小于魂石转生次数时不能升级")
        elseif skillZS == petZs and skillLV >= petLv then
          ShowNotifyTips("魂石等级不能高于召唤兽等级")
        else
          netsend.netitem.requestNeiDanExpFromPet(itemObj:getObjId(), self.m_EqptRoleId)
          ShowWarningInWar()
        end
      end, nil, nil, true)
      self:addOneNode({
        obj = addBtn,
        isWidget = true,
        anchorPoint = ccp(0, 0),
        offXY = ccp(0, -12)
      })
      if skillLV < lvLimit then
        self:newLine()
        self:newLine()
        local temp = data_ndLvupCondtion[skillLV + 1]
        if temp ~= nil then
          local lvupcost = temp[string.format("rb%d", skillZS)]
          if lvupcost ~= nil then
            lvupcost = math.floor(lvupcost)
            local myCoin = g_LocalPlayer:getCoin()
            if lvupcost <= myCoin then
              self:addRichText(string.format("#<r:94,g:211,b:207>升级花费 ##<IR1,r:255,g:255,b:255>%d #", lvupcost))
            else
              self:addRichText(string.format("#<r:94,g:211,b:207>升级花费 ##<IR1,r:255,g:0,b:0>%d #", lvupcost))
            end
          end
        end
      else
        addBtn:setVisible(false)
        addBtn:setTouchEnabled(false)
      end
      if skillZS > petZs and skillLV > petLv then
        self:newLine()
        self:newLine()
        self:addRichText(string.format("#<IRP,r:94,g:211,b:207,F:18> 提示:魂石转生或等级超过召唤兽转生或等级,只能发挥##<R,F:18>%d转%d级##<r:94,g:211,b:207,F:18>的威力#", petZs, petLv))
      elseif skillZS > petZs and skillLV <= petLv then
        self:newLine()
        self:newLine()
        self:addRichText(string.format("#<IRP,r:94,g:211,b:207,F:18> 提示:魂石转生或等级超过召唤兽转生或等级,只能发挥##<R,F:18>%d转%d级##<r:94,g:211,b:207,F:18>的威力#", petZs, skillLV))
      elseif skillZS <= petZs and skillLV > petLv then
        self:newLine()
        self:newLine()
        self:addRichText(string.format("#<IRP,r:94,g:211,b:207,F:18> 提示:魂石转生或等级超过召唤兽转生或等级,只能发挥##<R,F:18>%d转%d级##<r:94,g:211,b:207,F:18>的威力#", skillZS, petLv))
      end
    end
  else
    self:addSource(itemObj)
  end
end
function CItemDetailText:addDrugEffect(itemObj)
  self:addRichText("【功效】\n")
  local hpV = itemObj:getProperty(ITEM_PRO_DRUG_ADDHPValue)
  local hpP = itemObj:getProperty(ITEM_PRO_DRUG_ADDHPPercent)
  local mpV = itemObj:getProperty(ITEM_PRO_DRUG_ADDMPValue)
  local mpP = itemObj:getProperty(ITEM_PRO_DRUG_ADDMPPercent)
  if hpV ~= 0 then
    self:addRichText(string.format("+HP%d\n", hpV))
  end
  if hpP ~= 0 then
    self:addRichText(string.format("+HP%d%%\n", hpP))
  end
  if mpV ~= 0 then
    self:addRichText(string.format("+MP%d\n", mpV))
  end
  if mpP ~= 0 then
    self:addRichText(string.format("+MP%d%%\n", mpP))
  end
end
function CItemDetailText:addItemTips(itemObj)
  self:newLine()
  local tips, itemTypeId
  if itemObj ~= nil then
    tips = itemObj:getProperty(ITEM_PRO_TIPS)
    itemTypeId = itemObj:getTypeId()
  else
    tips = data_getItemTips(self.m_ItemType)
    itemTypeId = self.m_ItemType
  end
  local zjSkillFlag = false
  if itemTypeId and GetItemTypeByItemTypeId(itemTypeId) == ITEM_LARGE_TYPE_OTHERITEM and GetItemSubTypeByItemTypeId(itemTypeId) == ITEM_DEF_TYPE_SKILLBOOK and GetPetSkillBookTypeByItemTypeId(itemTypeId) == ITEM_DEF_SKILLBOOK_SUPREME then
    zjSkillFlag = true
  end
  if zjSkillFlag then
    local skillId = data_OtherItem[itemTypeId].value
    local needXLD = data_getSkillNeedXiuLianDu(skillId)
    if tips and tips ~= "" and tips ~= 0 then
      self:addRichText("【提示】")
      self:addRichText(string.format("#<CTP>修炼度满%d点后可领悟,%s\n#", needXLD, tips))
    else
      self:addRichText("【提示】")
      self:addRichText(string.format("#<CTP>修炼度满%d点后可领悟\n#", needXLD))
    end
  elseif tips and tips ~= "" and tips ~= 0 then
    self:addRichText("【提示】")
    self:addRichText(string.format([[
#<CTP>%s
#]], tips))
  end
end
function CItemDetailText:addItemLifeDes(itemObj)
  self:newLine()
  local des
  local itemType = itemObj:getTypeId()
  local lsType = data_getLifeSkillType(itemType)
  if lsType == IETM_DEF_LIFESKILL_FUWEN then
    des = data_getLifeItemFuwenEff(itemType)
  elseif lsType == IETM_DEF_LIFESKILL_FOOD then
    des = data_getLifeItemFoodEff(itemType)
  elseif lsType == IETM_DEF_LIFESKILL_DRUG then
    des = data_getLifeItemDrugEff(itemType)
  elseif lsType == IETM_DEF_LIFESKILL_WINE then
    des = data_getLifeItemWineEff(itemType)
  end
  if des and des ~= "" and des ~= 0 then
    self:addRichText(string.format([[
#<Y>%s
#]], des))
  end
end
function CItemDetailText:addItemSkillBookNeedPro(itemObj)
  local skillId
  if itemObj ~= nil then
    skillId = data_OtherItem[itemObj:getTypeId()].value
  else
    skillId = data_OtherItem[self.m_ItemType].value
  end
  local txt = ""
  local needPro = GetPetSkillNeedPro(skillId)
  for name, value in pairs(needPro) do
    if name == "ll" then
      txt = txt .. string.format("力量≥%d", value)
    elseif name == "lx" then
      txt = txt .. string.format("灵性≥%d", value)
    elseif name == "gg" then
      txt = txt .. string.format("根骨≥%d", value)
    elseif name == "mj" then
      txt = txt .. string.format("敏捷≥%d", value)
    end
  end
  if txt ~= "" then
    self:addRichText("【属性要求】")
    self:addRichText(string.format("%s", txt))
  end
end
function CItemDetailText:addItemSkillBookNeedWuXing(itemObj)
  local skillId
  if itemObj ~= nil then
    skillId = data_OtherItem[itemObj:getTypeId()].value
  else
    skillId = data_OtherItem[self.m_ItemType].value
  end
  local txt = ""
  local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
  for _, d in ipairs({
    {"金", jin},
    {"木", mu},
    {"水", shui},
    {"火", huo},
    {"土", tu}
  }) do
    local name = d[1]
    local value = d[2]
    if value > 0 then
      txt = txt .. string.format("%s≥%d", name, value * 100)
    end
  end
  if txt ~= "" then
    self:addRichText("【五行要求】")
    self:addRichText(string.format("%s", txt))
  end
end
function CItemDetailText:addItemDes(itemObj)
  local des
  if itemObj ~= nil then
    des = itemObj:getProperty(ITEM_PRO_DES)
  else
    des = data_getItemDes(self.m_ItemType)
  end
  if des and des ~= "" and des ~= 0 then
    self:addRichText(string.format("%s", des))
  end
end
function CItemDetailText:addItemDesForZBT(itemObj)
  self:addRichText("记载宝物藏身之所的图纸，在其记录点附近使用后有可能会获得意外的宝物。")
  self:newLine()
end
function CItemDetailText:addSource(itemObj)
  if self.m_ShowSource == false then
    return
  end
  local itemTypeId
  if itemObj ~= nil then
    itemTypeId = itemObj:getTypeId()
  else
    itemTypeId = self.m_ItemType
  end
  local tempData = data_ItemSource[itemTypeId]
  if tempData == nil then
    return
  end
  self:addRichText("\n#<CBA>获得途径:\n#")
  local maxIndex = 1
  for index, _ in pairs(tempData) do
    if index > maxIndex then
      maxIndex = index
    end
  end
  for i = 1, maxIndex do
    desData = tempData[i]
    if desData ~= nil then
      local tempItem = CItemSource.new(self.m_RichTextW, itemTypeId, desData.des, desData.clickDes, desData.para)
      self:addOneNode({
        obj = tempItem.m_UINode,
        isWidget = true,
        ignoreSizeFlag = true
      })
      self:newLine()
    end
  end
end
function CItemDetailText:addItemWingTips(itemObj)
  self:newLine()
  local nextLv
  if itemObj == nil then
    nextLv = 1
  else
    local lv = itemObj:getProperty(ITEM_PRO_LV)
    nextLv = lv + 1
  end
  if nextLv > ITEM_CHIBANG_MaxLv then
    self:addRichText("#<CTP,IRP>提示:已达到最大等级\n#")
  else
    local nextData = data_SeniorWing[ITEM_FIRST_LV_CHIBANG + nextLv - 1] or {}
    local needLv = nextData.lvlimit or 0
    local needZs = nextData.zslimit or 0
    local needBsNum = nextData.needQHValue or 0
    local addProNum = nextData.addProPoint or 0
    if needZs == 0 then
      self:addRichText(string.format("#<CTP,IRP>等级达到%d级并且强化值达到%d后自动获得%d级翅膀,增加属性点%d点\n#", needLv, needBsNum, nextLv, addProNum))
    else
      self:addRichText(string.format("#<CTP,IRP>等级达到%d转%d级并且强化值达到%d后自动获得%d级翅膀,增加属性点%d点\n#", needZs, needLv, needBsNum, nextLv, addProNum))
    end
  end
  local player
  if self.isMarket then
    player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
  else
    player = g_DataMgr:getPlayer(self.m_PlayerId)
  end
  local bsNum = 0
  local mainHero = g_LocalPlayer:getMainHero()
  for _, tPos in pairs({
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
    local itemIns = player:getMainHero():GetEqptByPos(tPos)
    if itemIns ~= nil then
      bsNum = bsNum + itemIns:getProperty(ITME_PRO_EQPT_BAOSHINUM)
    end
  end
  self:addRichText(string.format("(总强化值:%d)", bsNum))
end
function CItemDetailText:addItemWingBasePro(itemObj)
  if g_LocalPlayer then
    local mainHero = g_LocalPlayer:getMainHero()
    if mainHero then
      local gg = mainHero:getProperty(PROPERTY_Wing_GenGu)
      local lx = mainHero:getProperty(PROPERTY_Wing_Lingxing)
      local ll = mainHero:getProperty(PROPERTY_Wing_LiLiang)
      local mj = mainHero:getProperty(PROPERTY_Wing_MinJie)
      if gg ~= 0 then
        self:addRichText(string.format("#<CBA>根骨+%d#", gg))
      elseif lx ~= 0 then
        self:addRichText(string.format("#<CBA>灵性+%d#", lx))
      elseif ll ~= 0 then
        self:addRichText(string.format("#<CBA>力量+%d#", ll))
      elseif mj ~= 0 then
        self:addRichText(string.format("#<CBA>敏捷+%d#", mj))
      end
      self:newLine()
    end
  end
end
function CItemDetailText:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  local para = arg[1]
  if msgSID == MsgID_ItemInfo_ItemUpdate and para.itemId == self.m_ItemObjId then
    self:clearAll()
    self:setItemDetialText()
    if self.m_SizeChangeListener then
      self.m_SizeChangeListener()
    end
  end
end
function CItemDetailText:onCleanup()
  CItemDetailText.super.onCleanup(self)
  self:RemoveAllMessageListener()
  self.m_SizeChangeListener = nil
end
CItemSource = class("CItemSource", CcsSubView)
function CItemSource:ctor(width, itemTypeId, des, clickDes, jumpPara)
  CItemSource.super.ctor(self, "views/item_source.json")
  self.m_width = width
  self.m_ItemTypeId = itemTypeId
  self.m_Des = des
  self.m_ClickDes = clickDes
  self.m_JumpPara = jumpPara
  local btnBatchListener = {
    btn_bg = {
      listener = handler(self, self.ClickSource),
      variName = "m_ClickBg",
      param = {0, 1}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetData()
  return self
end
function CItemSource:SetData()
  self:getNode("des"):setText(self.m_Des)
  self:getNode("clickDes"):setText(self.m_ClickDes)
  if self.m_width == nil then
    return
  end
  local size = self:getContentSize()
  self.m_ClickBg:setScaleX(self.m_width / size.width)
  local x, y = self:getNode("clickDes"):getPosition()
  self.m_ClickBg:setPosition(ccp(self.m_width / 2, y))
  local x, y = self:getNode("clickDes"):getPosition()
  self:getNode("clickDes"):setPosition(ccp(x + self.m_width - size.width, y))
end
function CItemSource:ClickSource(obj, t)
  print("CItemSource:ClickSource", self.m_Des, self.m_ClickDes)
  JumpToItemSource(self.m_ItemTypeId, self.m_JumpPara)
end
function CItemSource:Clear()
end
