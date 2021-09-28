function GetEquipShowValue(itemObj)
  local value = 0
  if itemObj ~= nil then
    local largeType = itemObj:getType()
    if largeType == ITEM_LARGE_TYPE_EQPT then
      value = value + data_EquipShowBaseValue[1].value or 0
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      value = value + data_EquipShowBaseValue[2].value or 0
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      value = value + data_EquipShowBaseValue[3].value or 0
    elseif largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      value = value + data_EquipShowBaseValue[4].value or 0
    end
    local bsNum = itemObj:getProperty(ITME_PRO_EQPT_BAOSHINUM)
    for _, data in pairs(data_EquipShowBaseProValue) do
      local key = data.key or ""
      local v = data.value or 0
      local proValue = math.abs(itemObj:getProperty(key))
      if bsNum > 0 and ZB_PRO_BASE_DICT[key] == true then
        proValue = proValue * (1 + 0.02 * bsNum)
      end
      local tempType = Pro_Value_NUM_TYPE
      for _, data in pairs(ITEM_PRO_SHOW_BASE_DICT) do
        if data[1] == key then
          tempType = data[3]
          break
        end
      end
      if key == "eqptSP" then
        local speed = itemObj:getProperty(ITEM_PRO_EQPT_SP)
        if speed > 0 then
          if bsNum > 0 then
            value = value + speed * (1 + 0.02 * bsNum) * v
          else
            value = value + speed * v
          end
        end
      elseif key == "eqptFSP" then
        local speed = itemObj:getProperty(ITEM_PRO_EQPT_SP)
        if speed < 0 then
          if bsNum > 0 then
            value = value + (0 - speed) * (1 + 0.02 * bsNum) * v
          else
            value = value + (0 - speed) * v
          end
        end
      elseif tempType == Pro_Value_NUM_TYPE then
        value = value + proValue * v
      elseif tempType == Pro_Value_PERCENT_TYPE then
        value = value + proValue * v * 100
      end
    end
    for _, data in pairs(data_EquipShowLianhuaProValue) do
      local key = data.key or ""
      local v = data.value or 0
      local proValue = math.abs(itemObj:getProperty(key))
      local tempType = Pro_Value_NUM_TYPE
      for _, data in pairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
        if data[1] == key then
          tempType = data[3]
          break
        end
      end
      if tempType == Pro_Value_NUM_TYPE then
        value = value + proValue * v
      elseif tempType == Pro_Value_PERCENT_TYPE then
        value = value + proValue * v * 100
      end
    end
  end
  return math.floor(value)
end
CItemDetailHead = class("CItemDetailHead", function()
  return Widget:create()
end)
function CItemDetailHead:ctor(param, isMarket)
  self.isMarket = isMarket
  self:setNodeEventEnabled(true)
  self.m_PlayerId = nil
  self.m_ItemObjId = nil
  self.m_ItemType = nil
  if param == nil then
    param = {}
  end
  self.m_DelH = param.deltaH or 10
  self.m_W = param.width or 300
  self.m_AllH = 0
  self.m_ItemImgW = 60
  self.m_NormalTextSize = param.normalTextSize or 18
  self.m_NameTextSize = param.nameTextSize or 22
  self.m_ShowName = param.showName
  self.m_ItemDetailTypeImg = nil
  self.m_ItemDetailItemImg = nil
  self.m_ItemDetailNameObj = nil
  self.m_ItemDetailNameExObj = nil
  self.m_ItemDetailIsBundleTxtObj = nil
end
function CItemDetailHead:GetItemObj()
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
function CItemDetailHead:ShowItemDetail(itemObjId, itemType, roleId, playerId, isCurrEquipShow, isHuobanFlag)
  printLog("CItemDetailHead", "ShowItemDetail")
  self.m_ItemObjId = itemObjId
  self.m_ItemType = itemType
  self.m_PlayerId = playerId
  self.m_RoleId = roleId
  self:ClearDetail()
  local itemObj = self:GetItemObj()
  self:SetImgAndName(itemObj, isCurrEquipShow, isHuobanFlag)
  self:SetAllPos()
end
function CItemDetailHead:SetImgAndName(itemObj, isCurrEquipShow, isHuobanFlag)
  local itemName, itemShapeId, path, iconPath, itemType
  local isBundleFlag = false
  if itemObj ~= nil then
    itemName = itemObj:getProperty(ITEM_PRO_NAME)
    itemShapeId = itemObj:getProperty(ITEM_PRO_SHAPE)
    path = data_getItemPathByShape(itemShapeId)
    iconPath = data_getItemPackageIconPath(itemObj:getTypeId())
    itemType = itemObj:getTypeId()
    local player
    if self.isMarket then
      player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
    else
      player = g_DataMgr:getPlayer(self.m_PlayerId)
    end
    local roleIns = player:getObjById(self.m_RoleId)
    if roleIns ~= nil and roleIns:getType() == LOGICTYPE_HERO and self.m_EqptRoleId ~= player:getMainHeroId() and isHuobanFlag then
      itemName = GetHuobanEqptName(itemObj)
      iconPath = string.format("views/packageui/package_icon%d.png", ITEM_PACKAGE_ICONTYPE_HUOBAN_EQPT)
      itemShapeId = GetHuobanEqptShape(itemObj, roleIns)
      path = data_getItemPathByShape(itemShapeId)
    end
    if itemObj:getProperty(ITME_PRO_BUNDLE_FLAG) == 1 then
      isBundleFlag = true
    end
  else
    itemName = data_getItemName(self.m_ItemType)
    itemShapeId = data_getItemShapeID(self.m_ItemType)
    path = data_getItemPathByShape(itemShapeId)
    iconPath = data_getItemPackageIconPath(self.m_ItemType)
    itemType = self.m_ItemType
  end
  if self.m_ShowName ~= nil then
    itemName = self.m_ShowName
  end
  self.m_ItemDetailNameObj = ui.newTTFLabel({
    text = itemName,
    font = KANG_TTF_FONT,
    size = self.m_NameTextSize,
    color = ccc3(255, 255, 0)
  })
  local itemPj = data_getItemPinjie(itemType)
  local color = NameColor_Item[itemPj] or NameColor_Item[0]
  self.m_ItemDetailNameObj:setColor(color)
  self.m_ItemDetailNameObj:setAnchorPoint(ccp(0, 0))
  self:addNode(self.m_ItemDetailNameObj)
  if isCurrEquipShow == true then
    self.m_ItemDetailNameExObj = ui.newTTFLabel({
      text = "(当前装备)",
      font = KANG_TTF_FONT,
      size = 18,
      color = VIEW_DEF_PGREEN_COLOR
    })
    self.m_ItemDetailNameExObj:setAnchorPoint(ccp(0, 0))
    self:addNode(self.m_ItemDetailNameExObj)
  end
  if isBundleFlag then
    self.m_ItemDetailIsBundleTxtObj = ui.newTTFLabel({
      text = "【绑定】",
      font = KANG_TTF_FONT,
      size = 16,
      color = ccc3(212, 36, 17)
    })
    self.m_ItemDetailIsBundleTxtObj:setAnchorPoint(ccp(0, 0))
    self:addNode(self.m_ItemDetailIsBundleTxtObj)
  end
  if itemObj ~= nil then
    local largeType = itemObj:getType()
    local showValue = self:GetObjShowValue(itemObj)
    if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_SENIOREQPT or largeType == ITEM_LARGE_TYPE_XIANQI or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      self.m_ItemShowValueObj = ui.newTTFLabel({
        text = string.format("评价%d", showValue),
        font = KANG_TTF_FONT,
        size = 20,
        color = color
      })
      self.m_ItemShowValueObj:setAnchorPoint(ccp(0, 0))
      self:addNode(self.m_ItemShowValueObj)
    end
  end
  if self.m_ItemDetailItemImg then
    self.m_ItemDetailItemImg:removeFromParent()
  end
  local tempImg = display.newSprite(path)
  tempImg:setAnchorPoint(ccp(0, 1))
  tempImg:setScale(self.m_ItemImgW / tempImg:getContentSize().width)
  self:addNode(tempImg)
  self.m_ItemDetailItemImg = tempImg
  if self.m_ItemDetailTypeImg then
    self.m_ItemDetailTypeImg:removeFromParent()
  end
  local tempImg = display.newSprite(iconPath)
  tempImg:setAnchorPoint(ccp(0, 1))
  self:addNode(tempImg)
  self.m_ItemDetailTypeImg = tempImg
end
function CItemDetailHead:GetObjShowValue(itemObj)
  local value = 0
  if itemObj ~= nil then
    local largeType = itemObj:getType()
    if largeType == ITEM_LARGE_TYPE_EQPT then
      value = value + data_EquipShowBaseValue[1].value or 0
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      value = value + data_EquipShowBaseValue[2].value or 0
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      value = value + data_EquipShowBaseValue[3].value or 0
    elseif largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      value = value + data_EquipShowBaseValue[4].value or 0
    end
    local bsNum = itemObj:getProperty(ITME_PRO_EQPT_BAOSHINUM)
    for _, data in pairs(data_EquipShowBaseProValue) do
      local key = data.key or ""
      local v = data.value or 0
      local proValue = math.abs(itemObj:getProperty(key))
      if bsNum > 0 and ZB_PRO_BASE_DICT[key] == true then
        proValue = proValue * (1 + 0.02 * bsNum)
      end
      local tempType = Pro_Value_NUM_TYPE
      for _, data in pairs(ITEM_PRO_SHOW_BASE_DICT) do
        if data[1] == key then
          tempType = data[3]
          break
        end
      end
      if tempType == Pro_Value_NUM_TYPE then
        value = value + proValue * v
      elseif tempType == Pro_Value_PERCENT_TYPE then
        value = value + proValue * v * 100
      end
    end
    for _, data in pairs(data_EquipShowLianhuaProValue) do
      local key = data.key or ""
      local v = data.value or 0
      local proValue = math.abs(itemObj:getProperty(key))
      local tempType = Pro_Value_NUM_TYPE
      for _, data in pairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
        if data[1] == key then
          tempType = data[3]
          break
        end
      end
      if tempType == Pro_Value_NUM_TYPE then
        value = value + proValue * v
      elseif tempType == Pro_Value_PERCENT_TYPE then
        value = value + proValue * v * 100
      end
    end
  end
  return math.floor(value)
end
function CItemDetailHead:SetAllPos()
  if self.m_ItemDetailTypeImg then
    self.m_AllH = self.m_AllH + math.max(self.m_ItemDetailTypeImg:getContentSize().height, 80) + self.m_DelH
  end
  local posH = 0
  local nameH = self.m_ItemImgW
  if self.m_ItemDetailTypeImg then
    nameH = math.max(nameH, self.m_ItemDetailTypeImg:getContentSize().height)
    local tempW = self.m_DelH
    self.m_ItemDetailTypeImg:setPosition(ccp(tempW, self.m_AllH / 2 + self.m_ItemDetailTypeImg:getContentSize().height / 2))
    tempW = tempW + self.m_ItemDetailTypeImg:getContentSize().width
    self.m_ItemDetailItemImg:setPosition(ccp(tempW, self.m_AllH / 2 + self.m_ItemImgW / 2))
    tempW = tempW + self.m_ItemImgW + self.m_DelH
    if self.m_ItemDetailIsBundleTxtObj or self.m_ItemShowValueObj then
      self.m_ItemDetailNameObj:setPosition(ccp(tempW, self.m_AllH / 2 + self.m_ItemImgW / 2 - self.m_ItemDetailNameObj:getContentSize().height))
    else
      self.m_ItemDetailNameObj:setPosition(ccp(tempW, self.m_AllH / 2 + self.m_ItemImgW / 2 - 1.5 * self.m_ItemDetailNameObj:getContentSize().height))
    end
    if self.m_ItemDetailNameExObj then
      local x, y = self.m_ItemDetailNameObj:getPosition()
      local size = self.m_ItemDetailNameObj:getContentSize()
      self.m_ItemDetailNameExObj:setPosition(ccp(x + size.width, y))
    end
    if self.m_ItemShowValueObj then
      local x, y = self.m_ItemDetailNameObj:getPosition()
      local size = self.m_ItemShowValueObj:getContentSize()
      self.m_ItemShowValueObj:setPosition(ccp(x, y - size.height))
    end
    if self.m_ItemDetailIsBundleTxtObj then
      if self.m_ItemShowValueObj then
        local x, y = self.m_ItemDetailNameObj:getPosition()
        local size = self.m_ItemShowValueObj:getContentSize()
        self.m_ItemDetailIsBundleTxtObj:setPosition(ccp(x + size.width, y - size.height))
      else
        local x, y = self.m_ItemDetailNameObj:getPosition()
        local size = self.m_ItemDetailIsBundleTxtObj:getContentSize()
        self.m_ItemDetailIsBundleTxtObj:setPosition(ccp(x, y - size.height))
      end
    end
  end
  posH = posH + nameH + self.m_DelH
  self:ignoreContentAdaptWithSize(false)
  local size = CCSize(self.m_W, self.m_AllH)
  self:setSize(size)
  self:setContentSize(size)
  self:setAnchorPoint(ccp(0, 1))
end
function CItemDetailHead:ClearDetail()
  for _, obj in pairs({
    self.m_ItemDetailTypeImg,
    self.m_ItemDetailItemImg,
    self.m_ItemDetailNameObj,
    self.m_ItemDetailNameExObj,
    self.m_ItemDetailIsBundleTxtObj
  }) do
    if obj then
      self:removeChild(obj, true)
    end
  end
  self.m_AllH = 0
  self.m_ItemDetailTypeImg = nil
  self.m_ItemDetailItemImg = nil
  self.m_ItemDetailNameObj = nil
  self.m_ItemDetailNameExObj = nil
  self.m_ItemDetailIsBundleTxtObj = nil
  self:SetAllPos()
end
function CItemDetailHead:onCleanup()
  self.m_ItemDetailTypeImg = nil
  self.m_ItemDetailItemImg = nil
  self.m_ItemDetailNameObj = nil
  self.m_ItemDetailNameExObj = nil
  self.m_ItemDetailIsBundleTxtObj = nil
  self.m_TextList = nil
end
