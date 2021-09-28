g_LianhuaZhuangbeiView = nil
function ShowLianhuaZhuangBeiView(param)
  getCurSceneView():addSubView({
    subView = CLianhuaZhuangbeiShow.new(param),
    zOrder = MainUISceneZOrder.menuView
  })
end
CLianhuaZhuangbeiShow = class("CLianhuaZhuangbeiShow", CcsSubView)
function CLianhuaZhuangbeiShow:ctor(para)
  CLianhuaZhuangbeiShow.super.ctor(self, "views/lianhua_zb.json", {isAutoCenter = true, opacityBg = 100})
  clickArea_check.extend(self)
  para = para or {}
  self.m_ItemId = para.itemId
  self.m_RoleId = para.roleId
  self.lock_posts = {
    0,
    0,
    0,
    0,
    0
  }
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_lianhua = {
      listener = handler(self, self.OnBtn_Lianhua),
      variName = "btn_lianhua"
    },
    lock_1 = {
      listener = handler(self, self.OnBtn_Lock1),
      variName = "lock_1"
    },
    lock_2 = {
      listener = handler(self, self.OnBtn_Lock2),
      variName = "lock_2"
    },
    lock_3 = {
      listener = handler(self, self.OnBtn_Lock3),
      variName = "lock_3"
    },
    lock_4 = {
      listener = handler(self, self.OnBtn_Lock4),
      variName = "lock_4"
    },
    lock_5 = {
      listener = handler(self, self.OnBtn_Lock5),
      variName = "lock_5"
    },
    lock_11 = {
      listener = handler(self, self.OnBtn_Lock1),
      variName = "lock_11"
    },
    lock_21 = {
      listener = handler(self, self.OnBtn_Lock2),
      variName = "lock_21"
    },
    lock_31 = {
      listener = handler(self, self.OnBtn_Lock3),
      variName = "lock_31"
    },
    lock_41 = {
      listener = handler(self, self.OnBtn_Lock4),
      variName = "lock_41"
    },
    lock_51 = {
      listener = handler(self, self.OnBtn_Lock5),
      variName = "lock_51"
    },
    btn_use = {
      listener = handler(self, self.OnBtn_Use),
      variName = "btn_use"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_IconList = {}
  self.m_UpgradeDetailView = nil
  self.m_PopStuffDetail = nil
  self.m_MoneyIcon = nil
  self.m_NeedLingZhu = 0
  self.m_NeedJT = 0
  self.m_NeedLockItem = 0
  self.m_LockItem = 93049
  self:SetLianhuaItemTips()
  self:SetUpgradeItemImg()
  self:SetUpgradeCost()
  self:SetOldLianhuaPros()
  self:SetNewLianhuaPros()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_MoveScene)
  if g_LianhuaZhuangbeiView then
    g_LianhuaZhuangbeiView:CloseSelf()
    g_LianhuaZhuangbeiView = nil
  end
  g_LianhuaZhuangbeiView = self
end
function CLianhuaZhuangbeiShow:SetLianhuaItemTips()
  self:getNode("pos_tips"):setVisible(false)
  local x, y = self:getNode("pos_tips"):getPosition()
  local size = self:getNode("pos_tips"):getContentSize()
  local parent = self:getNode("pos_tips"):getParent()
  if self.m_Tips == nil then
    self.m_Tips = CRichText.new({
      width = size.width,
      fontSize = 18,
      color = ccc3(78, 47, 20),
      align = CRichText_AlignType_Left
    })
    parent:addChild(self.m_Tips)
  else
    self.m_Tips:clearAll()
  end
  local txtStr = "#<IRP>#提示炼化可赋予装备新的属性绿字显示，每件装备最多可炼化出5个属性。\n\n必须选择#<R>使用新属性#才会被替换。"
  if g_BanShuFlag then
    txtStr = "#<IRP>#提示:炼化可赋予装备新的属性(绿字显示)，每件装备最多可炼化出5个属性。\n每件装备每天只能炼化10次。\n必须选择#<R>使用新属性#才会被替换。"
  end
  self.m_Tips:addRichText(txtStr)
  local h = self.m_Tips:getContentSize().height
  self.m_Tips:setPosition(ccp(x, y + size.height - h))
end
function CLianhuaZhuangbeiShow:SetUpgradeItemImg()
  if self.m_IconList == nil then
    self.m_IconList = {}
  end
  if self.m_ItemId == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local mainHeroType = mainHero:getTypeId()
  local itemTypeId = itemIns:getTypeId()
  local lv = itemIns:getProperty(ITEM_PRO_LV)
  for i = 1, 4 do
    local tempPos = self:getNode(string.format("itempos%d", i))
    if tempPos then
      tempPos:setVisible(false)
      if tempPos._posNum ~= nil then
        tempPos._posNum:removeFromParent()
        tempPos._posNum = nil
      end
    end
  end
  for _, icon in pairs(self.m_IconList) do
    icon:removeFromParent()
  end
  self.m_IconList = {}
  local tempDict = {
    {
      itemIns:getTypeId(),
      1
    }
  }
  local tList = data_getUpgradeItemList(itemTypeId, lv, Eqpt_Upgrade_LianhuaType)
  for tType, tNum in pairs(tList) do
    tempDict[#tempDict + 1] = {tType, tNum}
  end
  for index, data in ipairs(tempDict) do
    local itemTypeId = data[1]
    local itemNeedNum = data[2]
    local pos = self:getNode(string.format("itempos%d", index))
    local icon = self:AddOneStuffIcon(index, pos, itemTypeId, itemNeedNum)
    if itemTypeId == ITEM_DEF_STUFF_LZ then
      self.m_NeedLingZhu = itemNeedNum
    elseif itemTypeId == ITEM_DEF_STUFF_JINGTIE then
      self.m_NeedJT = itemNeedNum
    end
    self.m_IconList[#self.m_IconList + 1] = icon
  end
  local itemName = data_getItemName(itemTypeId)
  local itemPj = data_getItemPinjie(itemTypeId)
  local textColor = NameColor_Item[itemPj] or NameColor_Item[0]
  self:getNode("itemname"):setText(itemName)
  self:getNode("itemname"):setColor(textColor)
end
function CLianhuaZhuangbeiShow:AddOneStuffIcon(index, pos, itemTypeId, itemNeedNum)
  local s = pos:getContentSize()
  local clickListener = handler(self, self.ShowStuffDetail)
  if index == 1 then
    function clickListener()
    end
  end
  icon = createClickItem({
    itemID = itemTypeId,
    autoSize = nil,
    num = 0,
    LongPressTime = 0,
    clickListener = clickListener,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = true
  })
  local size = icon:getContentSize()
  icon:setPosition(ccp(-size.width / 2, -size.height / 2))
  pos:addChild(icon)
  icon.eqptupgradeItemTypePara = itemTypeId
  icon.eqptupgradeItemNeedNumPara = itemNeedNum or 1
  icon.eqptupgradeItemPosPara = index
  pos:setVisible(true)
  if index ~= 1 then
    local curNum = g_LocalPlayer:GetItemNum(itemTypeId)
    local numLabel = CCLabelTTF:create(string.format("%s/%s", curNum, itemNeedNum), ITEM_NUM_FONT, 22)
    local size = icon:getContentSize()
    numLabel:setAnchorPoint(ccp(1, 0))
    numLabel:setPosition(ccp(s.width / 2 - 5, -s.height / 2 + 5))
    if itemNeedNum <= curNum then
      numLabel:setColor(VIEW_DEF_PGREEN_COLOR)
    else
      numLabel:setColor(VIEW_DEF_WARNING_COLOR)
    end
    pos:addNode(numLabel)
    AutoLimitObjSize(numLabel, 70)
    pos._posNum = numLabel
  end
  return icon
end
function CLianhuaZhuangbeiShow:ShowStuffDetail(obj, t)
  self.m_PopStuffDetail = CEquipDetail.new(nil, {
    closeListener = handler(self, self.CloseStuffDetail),
    itemType = obj.eqptupgradeItemTypePara
  })
  self:addSubView({
    subView = self.m_PopStuffDetail,
    zOrder = 9999
  })
  self:SelectStuffItem(obj.eqptupgradeItemPosPara)
  local x, y = self:getNode("bg_split"):getPosition()
  local iSize = self:getNode("bg_split"):getContentSize()
  local bSize = self.m_PopStuffDetail:getBoxSize()
  self.m_PopStuffDetail:setPosition(ccp(x - bSize.width, y - bSize.height / 2))
  self.m_PopStuffDetail:ShowCloseBtn()
end
function CLianhuaZhuangbeiShow:SetCanLianHua(flag)
  if flag == true then
    self.btn_lianhua:setTouchEnabled(true)
    self.btn_use:setTouchEnabled(true)
    if self.m_LoadingImg ~= nil then
      self.m_LoadingImg:removeFromParent()
      self.m_LoadingImg = nil
    end
  else
    self.btn_lianhua:setTouchEnabled(false)
    self.btn_use:setTouchEnabled(false)
  end
end
function CLianhuaZhuangbeiShow:SetUpgradeCost()
  if self.m_ItemId == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return
  end
  if self.m_MoneyIcon == nil then
    local x, y = self:getNode("box_coin"):getPosition()
    local z = self:getNode("box_coin"):getZOrder()
    local size = self:getNode("box_coin"):getSize()
    self:getNode("box_coin"):setTouchEnabled(false)
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_MoneyIcon = tempImg
  end
  local itemTypeId = itemIns:getTypeId()
  local lv = itemIns:getProperty(ITEM_PRO_LV)
  local needMoney = data_getUpgradeItemMoney(itemTypeId, lv, Eqpt_Upgrade_LianhuaType)
  self:getNode("txt_coin"):setText(string.format("%d", needMoney))
  if needMoney > g_LocalPlayer:getCoin() then
    self:getNode("txt_coin"):setColor(VIEW_DEF_WARNING_COLOR)
  else
    self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  end
  self:getNode("txt_coin"):setEnabled(true)
  self:getNode("coinBg"):setEnabled(true)
  self:getNode("txt2"):setVisible(true)
  self:getNode("coinBg"):setVisible(true)
  self:getNode("txt_coin"):setVisible(true)
  if self.m_MoneyIcon then
    self.m_MoneyIcon:setVisible(true)
  end
end
function CLianhuaZhuangbeiShow:SetOldLianhuaPros()
  for i = 1, 5 do
    self:getNode(string.format("old_name_%d", i)):setColor(ccc3(78, 47, 20))
    self:getNode(string.format("old_name_%d", i)):setVisible(false)
    self:getNode(string.format("old_value_%d", i)):setVisible(false)
    self:getNode(string.format("old_pro_%d", i)):setVisible(false)
    self:getNode(string.format("old_bg_%d", i)):setVisible(false)
  end
  if self.m_ItemId == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return
  end
  local proValueDict = {}
  for _, para in ipairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
    local proName = para[1]
    local str = para[2]
    local tempType = para[3]
    local tempNum = itemIns:getProperty(proName)
    proValueDict[#proValueDict + 1] = {
      proName,
      str,
      tempType,
      tempNum
    }
  end
  proValueDict[#proValueDict + 1] = {
    ITEM_PRO_EQPT_LH_LVLIMIT,
    nil,
    nil,
    itemIns:getProperty(ITEM_PRO_EQPT_LH_LVLIMIT)
  }
  proValueDict[#proValueDict + 1] = {
    ITEM_PRO_EQPT_LH_PROLIMIT,
    nil,
    nil,
    itemIns:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)
  }
  local showDict = self:GetShowProDict(proValueDict)
  for i, data in ipairs(showDict) do
    if i <= 5 then
      self:getNode(string.format("old_name_%d", i)):setVisible(true)
      self:getNode(string.format("old_value_%d", i)):setVisible(true)
      self:getNode(string.format("old_pro_%d", i)):setVisible(true)
      self:getNode(string.format("old_bg_%d", i)):setVisible(true)
      self:getNode(string.format("old_name_%d", i)):setText(data[1])
      self:getNode(string.format("old_value_%d", i)):setText(data[2])
      self:getNode(string.format("old_pro_%d", i)):setPercent(data[3])
      AutoLimitObjSize(self:getNode(string.format("old_name_%d", i)), 150)
      local nameObj = self:getNode(string.format("old_name_%d", i))
      local txtObj = self:getNode(string.format("old_value_%d", i))
      local attrTipName = ITEM_PRO_SHOW_LIANHUA_2_AttrTips_DICT[data[4]]
      self:attrclick_check_withWidgetObj(nameObj, attrTipName)
      self:attrclick_check_withWidgetObj(txtObj, attrTipName, nameObj)
    end
  end
end
function CLianhuaZhuangbeiShow:SetNewLianhuaPros()
  self.lock_posts = {
    0,
    0,
    0,
    0,
    0
  }
  self.m_NeedLockItem = 0
  for i = 1, 5 do
    self:getNode(string.format("new_name_%d", i)):setColor(ccc3(78, 47, 20))
    self:getNode(string.format("new_name_%d", i)):setVisible(false)
    self:getNode(string.format("new_value_%d", i)):setVisible(false)
    self:getNode(string.format("new_pro_%d", i)):setVisible(false)
    self:getNode(string.format("new_bg_%d", i)):setVisible(false)
    self:getNode(string.format("lock_%d", i)):setVisible(false)
    self:getNode(string.format("lock_%d", i)):setTouchEnabled(false)
    self:getNode(string.format("lock_%d1", i)):setVisible(false)
    self:getNode(string.format("lock_%d1", i)):setTouchEnabled(false)
  end
  if self.m_ItemId == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return
  end
  local newLHDict = itemIns:getProperty(ITEM_PRO_TEMPLH_Dict)
  if newLHDict == nil or newLHDict == 0 or type(newLHDict) ~= "table" then
    return
  end
  local proValueDict = {}
  for i, value in ipairs(newLHDict) do
    local strings = string.split(value, ";")
    for _, para in ipairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
      local proName = para[1]
      local str = para[2]
      local tempType = para[3]
      local serKey = ITEM_LHPROPERTIES_SVRKEY[proName]
      if serKey == strings[1] then
        local tempNum = tonumber(strings[2]) or 0
        proValueDict[#proValueDict + 1] = {
          proName,
          str,
          tempType,
          tempNum
        }
        break
      end
    end
  end
  proValueDict[#proValueDict + 1] = {
    ITEM_PRO_EQPT_LH_LVLIMIT,
    nil,
    nil,
    newLHDict.i_ldlv or 0
  }
  proValueDict[#proValueDict + 1] = {
    ITEM_PRO_EQPT_LH_PROLIMIT,
    nil,
    nil,
    newLHDict.i_ldp or 0
  }
  local showDict = self:GetShowProDict(proValueDict)
  for i, data in ipairs(showDict) do
    if i <= 5 then
      self:getNode(string.format("new_name_%d", i)):setVisible(true)
      self:getNode(string.format("new_value_%d", i)):setVisible(true)
      self:getNode(string.format("new_pro_%d", i)):setVisible(true)
      self:getNode(string.format("new_bg_%d", i)):setVisible(true)
      self:getNode(string.format("new_name_%d", i)):setText(data[1])
      self:getNode(string.format("new_value_%d", i)):setText(data[2])
      self:getNode(string.format("new_pro_%d", i)):setPercent(data[3])
      self:getNode(string.format("lock_%d", i)):setVisible(true)
      self:getNode(string.format("lock_%d", i)):setTouchEnabled(true)
      self:getNode(string.format("lock_%d1", i)):setVisible(true)
      self:getNode(string.format("lock_%d1", i)):setTouchEnabled(true)
      AutoLimitObjSize(self:getNode(string.format("new_name_%d", i)), 150)
      local nameObj = self:getNode(string.format("new_name_%d", i))
      local txtObj = self:getNode(string.format("new_value_%d", i))
      local attrTipName = ITEM_PRO_SHOW_LIANHUA_2_AttrTips_DICT[data[4]]
      self:attrclick_check_withWidgetObj(nameObj, attrTipName)
      self:attrclick_check_withWidgetObj(txtObj, attrTipName, nameObj)
    end
  end
end
function string.split(input, delimiter)
  input = tostring(input)
  delimiter = tostring(delimiter)
  if delimiter == "" then
    return false
  end
  local pos, arr = 0, {}
  for st, sp in function()
    return string.find(input, delimiter, pos, true)
  end, nil, nil do
    table.insert(arr, string.sub(input, pos, st - 1))
    pos = sp + 1
  end
  table.insert(arr, string.sub(input, pos))
  return arr
end
function printTable(_t)
  local szRet = "{"
  function doT2S(_i, _v)
    if "number" == type(_i) then
      szRet = szRet .. "[" .. _i .. "] = "
      if "number" == type(_v) then
        szRet = szRet .. _v .. ","
      elseif "string" == type(_v) then
        szRet = szRet .. "\"" .. _v .. "\"" .. ","
      elseif "table" == type(_v) then
        szRet = szRet .. sz_T2S(_v) .. ","
      else
        szRet = szRet .. "nil,"
      end
    elseif "string" == type(_i) then
      szRet = szRet .. "[\"" .. _i .. "\"] = "
      if "number" == type(_v) then
        szRet = szRet .. _v .. ","
      elseif "string" == type(_v) then
        szRet = szRet .. "\"" .. _v .. "\"" .. ","
      elseif "table" == type(_v) then
        szRet = szRet .. sz_T2S(_v) .. ","
      else
        szRet = szRet .. "nil,"
      end
    end
  end
  table.foreach(_t, doT2S)
  szRet = szRet .. "}"
  return szRet
end
function CLianhuaZhuangbeiShow:GetShowProDict(proValueDict)
  local showDict = {}
  if self.m_ItemId == nil then
    return showDict
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return showDict
  end
  local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
  local eqptPos = EPQT_TYPE_2_EQPT_POS[eqptType]
  local largeType = itemIns:getType()
  local levelType = 1
  if largeType == ITEM_LARGE_TYPE_EQPT then
    levelType = 1
  else
    levelType = 2
  end
  for _, para in ipairs(proValueDict) do
    local proName = para[1]
    local str = para[2]
    local tempType = para[3]
    local tempNum = para[4]
    local addFlag = "+"
    if tempNum ~= 0 then
      if tempNum < 0 then
        addFlag = "-"
      end
      local percent = 100
      if proName == ITEM_PRO_EQPT_LH_LVLIMIT then
        local valueStr = string.format("-%d", math.abs(tempNum))
        showDict[#showDict + 1] = {
          "装备等级需求",
          valueStr,
          100,
          proName
        }
      elseif proName == ITEM_PRO_EQPT_LH_PROLIMIT then
        local valueStr = string.format("-%d%%", math.abs(tempNum) * 100)
        showDict[#showDict + 1] = {
          "装备属性需求",
          valueStr,
          100,
          proName
        }
      elseif tempType == Pro_Value_NUM_TYPE then
        local valueStr = string.format("%s%d", addFlag, math.floor(math.abs(tempNum)))
        local minValue, maxValue = data_getLianhuaValueMinValueAndMaxValue(eqptPos, levelType, proName)
        if minValue < maxValue and tempNum < maxValue and tempNum >= minValue then
          percent = math.max(math.min((tempNum - minValue) / (maxValue - minValue) * 100, 100), 0)
        end
        showDict[#showDict + 1] = {
          str,
          valueStr,
          percent,
          proName
        }
      elseif tempType == Pro_Value_PERCENT_TYPE then
        local valueStr = string.format("%s%s%%", addFlag, Value2Str(math.abs(tempNum) * 100, 1))
        local minValue, maxValue = data_getLianhuaValueMinValueAndMaxValue(eqptPos, levelType, proName)
        if minValue < maxValue and tempNum < maxValue and tempNum >= minValue then
          percent = math.max(math.min((tempNum - minValue) / (maxValue - minValue) * 100, 100), 0)
        end
        showDict[#showDict + 1] = {
          str,
          valueStr,
          percent,
          proName
        }
      end
    end
  end
  return showDict
end
function CLianhuaZhuangbeiShow:SelectStuffItem(index)
  local selectImgTag = 9999
  for i = 1, 4 do
    local obj = self:getNode(string.format("itempos%d", i))
    if obj ~= nil then
      local oldImg = obj:getVirtualRenderer():getChildByTag(selectImgTag)
      if i == index then
        if oldImg == nil then
          local img = display.newSprite("xiyou/item/selecteditem.png")
          obj:getVirtualRenderer():addChild(img, 10, selectImgTag)
          local size = obj:getContentSize()
          img:setPosition(ccp(size.width / 2, size.height / 2))
        end
      elseif oldImg ~= nil then
        obj:getVirtualRenderer():removeChild(oldImg)
      end
    end
  end
end
function CLianhuaZhuangbeiShow:CloseStuffDetail()
  if self.m_PopStuffDetail then
    self:SelectStuffItem()
    local tempObj = self.m_PopStuffDetail
    self.m_PopStuffDetail = nil
    tempObj:CloseSelf()
  end
end
function CLianhuaZhuangbeiShow:CloseUpgradeDetail()
  if self.m_UpgradeDetailView then
    local tempObj = self.m_UpgradeDetailView
    self.m_UpgradeDetailView = nil
    tempObj:CloseSelf()
  end
end
function CLianhuaZhuangbeiShow:OnBtn_Lianhua(btnObj, touchType)
  if self.m_LoadingImg == nil then
    self.m_LoadingImg = CreateALoadingSprite()
    self:addNode(self.m_LoadingImg, 999)
    local x, y = self:getNode("bg3"):getPosition()
    self.m_LoadingImg:setPosition(ccp(x, y))
  end
  self:SetCanLianHua(false)
  netsend.netitem.requestLianhuaItem(self.m_ItemId, self.m_RoleId, self.lock_posts)
end
function CLianhuaZhuangbeiShow:OnBtn_Use(btnObj, touchType)
  if self.m_ItemId == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return
  end
  local newLHDict = itemIns:getProperty(ITEM_PRO_TEMPLH_Dict)
  if newLHDict == nil or newLHDict == 0 or type(newLHDict) ~= "table" then
    return
  end
  local hasNewValue = false
  for i, value in ipairs(newLHDict) do
    local strings = string.split(value, ";")
    for _, para in ipairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
      local proName = para[1]
      local str = para[2]
      local tempType = para[3]
      local serKey = ITEM_LHPROPERTIES_SVRKEY[proName]
      if serKey == strings[1] then
        local tempNum = tonumber(strings[2]) or 0
        if tempNum ~= 0 then
          hasNewValue = true
          break
        end
      end
    end
  end
  if newLHDict.i_ldlv then
    hasNewValue = true
  end
  if newLHDict.i_ldp then
    hasNewValue = true
  end
  if hasNewValue ~= true then
    ShowNotifyTips("请先炼化新属性")
    return
  end
  if self.m_LoadingImg == nil then
    self.m_LoadingImg = CreateALoadingSprite()
    self:addNode(self.m_LoadingImg, 999)
    local x, y = self:getNode("bg2"):getPosition()
    self.m_LoadingImg:setPosition(ccp(x, y))
  end
  self:SetCanLianHua(false)
  netsend.netitem.UseNewLianHuaPro(self.m_ItemId, self.m_RoleId)
  self.m_NeedLockItem = 0
end
function CLianhuaZhuangbeiShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
  if self.m_RoleId then
    ShowZhuangBeiView({
      InitItemId = self.m_ItemId,
      InitRoleId = self.m_RoleId,
      InitUpgradeType = Eqpt_Upgrade_LianhuaType
    })
  end
end
function CLianhuaZhuangbeiShow:OnBtn_Lock1(btnObj, touchType)
  if self.lock_posts[1] == 0 then
    self.lock_posts[1] = 1
    self.lock_1:setVisible(false)
    self.lock_1:setTouchEnabled(false)
    self.m_NeedLockItem = self.m_NeedLockItem + 1
    self:setlockIcon(self.m_NeedLockItem)
  else
    self.lock_posts[1] = 0
    self.lock_1:setVisible(true)
    self.lock_1:setTouchEnabled(true)
    self.m_NeedLockItem = self.m_NeedLockItem - 1
    self:setlockIcon(self.m_NeedLockItem)
  end
end
function CLianhuaZhuangbeiShow:setlockIcon(num)
  local pos = self:getNode(string.format("itempos%d", #self.m_IconList + 1))
  if pos then
    pos:setVisible(false)
    if pos._posNum ~= nil then
      pos._posNum:removeFromParent()
      pos._posNum = nil
    end
  end
  if num > 0 then
    local icon = self:AddOneStuffIcon(index, pos, self.m_LockItem, num)
    local itemName = data_getItemName(self.m_LockItem)
    local itemPj = data_getItemPinjie(self.m_LockItem)
    local textColor = NameColor_Item[itemPj] or NameColor_Item[0]
    self:getNode("itemname"):setText(itemName)
    self:getNode("itemname"):setColor(textColor)
  end
end
function CLianhuaZhuangbeiShow:OnBtn_Lock2(btnObj, touchType)
  if self.lock_posts[2] == 0 then
    self.lock_posts[2] = 1
    self.lock_2:setVisible(false)
    self.lock_2:setTouchEnabled(false)
    self.m_NeedLockItem = self.m_NeedLockItem + 1
    self:setlockIcon(self.m_NeedLockItem)
  else
    self.lock_posts[2] = 0
    self.lock_2:setVisible(true)
    self.lock_2:setTouchEnabled(true)
    self.m_NeedLockItem = self.m_NeedLockItem - 1
    self:setlockIcon(self.m_NeedLockItem)
  end
end
function CLianhuaZhuangbeiShow:OnBtn_Lock3(btnObj, touchType)
  if self.lock_posts[3] == 0 then
    self.lock_posts[3] = 1
    self.lock_3:setVisible(false)
    self.lock_3:setTouchEnabled(false)
    self.m_NeedLockItem = self.m_NeedLockItem + 1
    self:setlockIcon(self.m_NeedLockItem)
  else
    self.lock_posts[3] = 0
    self.lock_3:setVisible(true)
    self.lock_3:setTouchEnabled(true)
    self.m_NeedLockItem = self.m_NeedLockItem - 1
    self:setlockIcon(self.m_NeedLockItem)
  end
end
function CLianhuaZhuangbeiShow:OnBtn_Lock4(btnObj, touchType)
  if self.lock_posts[4] == 0 then
    self.lock_posts[4] = 1
    self.lock_4:setVisible(false)
    self.lock_4:setTouchEnabled(false)
    self.m_NeedLockItem = self.m_NeedLockItem + 1
    self:setlockIcon(self.m_NeedLockItem)
  else
    self.lock_posts[4] = 0
    self.lock_4:setVisible(true)
    self.lock_4:setTouchEnabled(true)
    self.m_NeedLockItem = self.m_NeedLockItem - 1
    self:setlockIcon(self.m_NeedLockItem)
  end
end
function CLianhuaZhuangbeiShow:OnBtn_Lock5(btnObj, touchType)
  if self.lock_posts[5] == 0 then
    self.lock_posts[5] = 1
    self.lock_5:setVisible(false)
    self.lock_5:setTouchEnabled(false)
    self.m_NeedLockItem = self.m_NeedLockItem + 1
    self:setlockIcon(self.m_NeedLockItem)
  else
    self.lock_posts[5] = 0
    self.lock_5:setVisible(true)
    self.lock_5:setTouchEnabled(true)
    self.m_NeedLockItem = self.m_NeedLockItem - 1
    self:setlockIcon(self.m_NeedLockItem)
  end
end
function CLianhuaZhuangbeiShow:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:SetUpgradeCost()
  elseif msgSID == MsgID_ItemInfo_AddItem then
    self:SetUpgradeItemImg()
  elseif msgSID == MsgID_ItemInfo_DelItem then
    self:SetUpgradeItemImg()
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum then
    self:SetUpgradeItemImg()
  elseif msgSID == MsgID_ItemInfo_ItemUpdate then
    local para = arg[1]
    local objId = para.itemId
    if objId == self.m_ItemId then
      self:SetOldLianhuaPros()
      self:SetNewLianhuaPros()
      self:SetCanLianHua(true)
    end
  elseif msgSID == MsgID_ItemSource_Jump then
    self:CloseStuffDetail()
    self:CloseUpgradeDetail()
    local d = arg[1][1]
    for _, t in pairs(Item_Source_MoveMapList) do
      if d == t then
        self:CloseSelf()
        break
      end
    end
  end
end
function CLianhuaZhuangbeiShow:Clear()
  self:CloseStuffDetail()
  self:CloseUpgradeDetail()
  if g_LianhuaZhuangbeiView == self then
    g_LianhuaZhuangbeiView = nil
  end
end
