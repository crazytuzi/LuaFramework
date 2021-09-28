CSelectLYSList = class("CSelectLYSList", CcsSubView)
function CSelectLYSList:ctor(para)
  CSelectLYSList.super.ctor(self, "views/select_lys.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CloseListener = para.closeListener
  self.m_SelectFunc = para.selectFunc
  if para.enableTouchDetect ~= false then
    self:enableCloseWhenTouchOutside(self:getNode("boxbg"), true)
  end
  self.lyslist = self:getNode("lyslist")
  local itemIds = g_LocalPlayer:GetItemTypeList(ITEM_LARGE_TYPE_LIANYAOSHI)
  table.sort(itemIds, _itemSortFunc)
  for i, itemId in ipairs(itemIds) do
    local item = CSelectOneLYSItem.new(itemId, self)
    self.lyslist:pushBackCustomItem(item:getUINode())
  end
  self.lyslist:addTouchItemListenerListView(handler(self, self.onSelected))
end
function CSelectLYSList:OnBtn_Close(btnObj, touchType)
  if self.m_CloseListener then
    self.m_CloseListener()
  end
end
function CSelectLYSList:getBoxSize()
  return self:getNode("boxbg"):getContentSize()
end
function CSelectLYSList:onSelected(item, index, listObj)
  local tempDrugItem = item.m_UIViewParent
  local tempId = tempDrugItem:getLYSItemId()
  if self.m_SelectFunc then
    self.m_SelectFunc(tempId)
  end
end
function CSelectLYSList:setEffectClickArea(areaRect)
  self:enableCloseWhenTouchOutsideBySize(areaRect)
end
function CSelectLYSList:SetUsedLYS(itemId, num)
  local cnt = self.lyslist:getCount()
  for i = 0, cnt - 1 do
    local item = self.lyslist:getItem(i)
    local itemObj = item.m_UIViewParent
    if itemObj:getLYSItemId() == itemId then
      itemObj:SetUsedNum(num)
    else
      itemObj:SetOriNum()
    end
  end
end
function CSelectLYSList:Clear()
  if self.m_CloseListener ~= nil then
    self.m_CloseListener()
  end
  self.m_CloseListener = nil
  self.m_SelectFunc = nil
end
CSelectOneLYSItem = class("CSelectOneLYSItem", CcsSubView)
function CSelectOneLYSItem:ctor(itemId, listObj)
  CSelectOneLYSItem.super.ctor(self, "views/select_lys_item.json")
  self.m_ItemId = itemId
  self.m_ListObj = listObj
  local itemIns = g_LocalPlayer:GetOneItem(itemId)
  local itemType = itemIns:getTypeId()
  local name = itemIns:getProperty(ITEM_PRO_NAME)
  self:getNode("name"):setText(name)
  local itemPj = data_getItemPinjie(itemIns:getTypeId())
  local color = NameColor_Item[itemPj] or NameColor_Item[0]
  self:getNode("name"):setColor(color)
  local kangxingStr = ""
  if itemType == ITEM_DEF_STUFF_WLD then
    kangxingStr = "重置炼妖效果"
  else
    local kangxingList = itemIns:getProperty(ITEM_PRO_LIANYAOSHI_KX)
    local kangxingValueList = itemIns:getProperty(ITEM_PRO_LIANYAOSHI_KXV)
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
  end
  local desSize = self:getNode("despos"):getContentSize()
  local richText = CRichText.new({
    width = desSize.width,
    color = ccc3(255, 255, 255),
    fontSize = 20
  })
  richText:addRichText(kangxingStr)
  local x, y = self:getNode("despos"):getPosition()
  self:addChild(richText)
  local richTextSize = richText:getContentSize()
  richText:setPosition(ccp(x, y + (desSize.height - richTextSize.height) / 2))
  self.m_ItemNum = itemIns:getProperty(ITEM_PRO_NUM)
  local pos = self:getNode("itempos")
  local s = pos:getContentSize()
  self.m_Icon = createClickItem({
    itemID = itemType,
    autoSize = nil,
    num = self.m_ItemNum,
    LongPressTime = 0.01,
    clickListener = handler(self, self.clickItem),
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = false
  })
  pos:addChild(self.m_Icon)
end
function CSelectOneLYSItem:getLYSItemId()
  return self.m_ItemId
end
function CSelectOneLYSItem:clickItem()
end
function CSelectOneLYSItem:SetUsedNum(usedNum)
  local num = self.m_ItemNum - usedNum
  self.m_Icon._numLabel:setString(tostring(num))
end
function CSelectOneLYSItem:SetOriNum(usedNum)
  self.m_Icon._numLabel:setString(tostring(self.m_ItemNum))
end
function CSelectOneLYSItem:Clear()
  self.m_ListObj = nil
end
