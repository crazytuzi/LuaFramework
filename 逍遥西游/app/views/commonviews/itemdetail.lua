g_Click_Item_View = nil
CItemDetailView = class("CItemDetailView", CcsSubView)
function CItemDetailView:ctor(itemId, autoDel, itemName, posPara)
  CItemDetailView.super.ctor(self, "views/itemdetail.json")
  print("CItemDetailView---create")
  self.m_AutoDel = autoDel
  self.m_Bg = self:getNode("bg")
  local bgPath = "xiyou/item/itembg.png"
  local bgImg = display.newSprite(bgPath)
  local itemShapeId = data_getItemShapeID(itemId)
  local path = data_getItemPathByShape(itemShapeId)
  local tempImg = display.newSprite(path)
  local x, y = self:getNode("Img"):getPosition()
  local z = self:getNode("Img"):getZOrder()
  local size = self:getNode("Img"):getSize()
  local mSize = bgImg:getContentSize()
  bgImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  bgImg:setScale(size.width / mSize.width)
  bgImg:addChild(tempImg)
  tempImg:setAnchorPoint(ccp(0, 0))
  tempImg:setPosition(ccp(0, 6))
  self.m_Bg:addNode(bgImg, z)
  local iconPath = data_getItemPackageIconPath(itemId)
  local iconImg = display.newSprite(iconPath)
  local x, y = self:getNode("Icon"):getPosition()
  local z = self:getNode("Icon"):getZOrder()
  local size = self:getNode("Icon"):getSize()
  iconImg:setAnchorPoint(ccp(0, 1))
  iconImg:setPosition(ccp(x, y + size.height))
  self.m_Bg:addNode(iconImg, z)
  local x, y = self:getNode("Desc"):getPosition()
  local descSize = self:getNode("Desc"):getSize()
  local tempDesc = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 23,
    color = ccc3(255, 255, 255)
  })
  self.m_Bg:addChild(tempDesc)
  local name = data_getItemName(itemId)
  if itemName ~= nil then
    name = itemName
  end
  tempDesc:addRichText(string.format("#<CI:%d>%s#", itemId, name))
  tempDesc:newLine()
  local des = data_getItemDes(itemId)
  local itemType = GetItemTypeByItemTypeId(itemId)
  if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_SHENBING or itemType == ITEM_LARGE_TYPE_XIANQI or itemType == ITEM_LARGE_TYPE_HUOBANEQPT then
    local itemObj = CEqptData.new(nil, nil, itemId, nil)
    local nZs = itemObj:getProperty(ITEM_PRO_EQPT_ZSLIMIT)
    local nLv = itemObj:getProperty(ITEM_PRO_EQPT_LVLIMIT)
    if nZs == 0 and nLv == 0 then
    elseif itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_XIANQI or itemType == ITEM_LARGE_TYPE_HUOBANEQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT then
      if nZs == 0 then
        des = string.format("#<Y>等级需求 %d级#\n", nLv) .. des
      elseif nLv == 0 then
        des = string.format("#<Y>等级需求 %d转#\n", nZs) .. des
      else
        des = string.format("#<Y>等级需求 %d转%d级#\n", nZs, nLv) .. des
      end
    elseif itemType == ITEM_LARGE_TYPE_SHENBING then
    end
  end
  tempDesc:addRichText(string.format("%s", des))
  if itemType == ITEM_LARGE_TYPE_LIANYAOSHI and itemId ~= ITEM_DEF_STUFF_WLD then
    local itemObj = CLianYaoShiData.new(nil, nil, itemId, nil)
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
    tempDesc:newLine()
    tempDesc:addRichText(string.format("#<Y>%s#\n", kangxingStr))
  end
  local realDescSize = tempDesc:getContentSize()
  tempDesc:setPosition(ccp(x, y + descSize.height - realDescSize.height))
  local bgSize = self.m_Bg:getSize()
  local w = bgSize.width
  local h = bgSize.height
  if realDescSize.height > descSize.height then
    self.m_Bg:ignoreContentAdaptWithSize(false)
    self.m_Bg:setSize(CCSize(w, h + realDescSize.height - descSize.height))
    self.m_Bg:setPosition(ccp(0, h + realDescSize.height - descSize.height))
  end
  if self.m_AutoDel == true then
    self:AutoDelSelf()
  end
  tipsviewExtend.extend(self)
  tipssetposExtend.extend(self, posPara)
end
function CItemDetailView:AutoDelSelf()
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  self.m_DelSelfHandler = scheduler.scheduleGlobal(function()
    print("CItemDetailView---removeself")
    self:removeFromParent()
  end, 3)
end
function CItemDetailView:getViewSize()
  return self.m_Bg:getSize()
end
function CItemDetailView:Clear()
  print("CItemDetailView---del")
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  g_Click_Item_View = nil
end
