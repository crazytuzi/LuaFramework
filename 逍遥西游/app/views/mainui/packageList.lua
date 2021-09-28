CPackageList = class("CPackageList", function()
  return Widget:create()
end)
function CPackageList:ctor(listType, packageView, listParam)
  self:setNodeEventEnabled(true)
  self.m_ListType = listType
  self.m_PackageView = packageView
  if listParam == nil then
    listParam = {}
  end
  self:SetItemList(listType, listParam)
end
function CPackageList:SetItemList(listType, listParam)
  local player = g_DataMgr:getPlayer()
  local typeList = {}
  self.m_ObjIdList = {}
  self.m_ObjViewList = {}
  local typeList = PACKAGE_NAME_TYPELIST_DICT[listType]
  for _, typeName in pairs(typeList) do
    local tempItemList = player:GetItemTypeList(typeName)
    for _, itemId in pairs(tempItemList) do
      self.m_ObjIdList[#self.m_ObjIdList + 1] = itemId
    end
  end
  table.sort(self.m_ObjIdList)
  self.m_ItemNum = #self.m_ObjIdList
  local delW = listParam.delW or 5
  local delH = listParam.delH or 0
  local oneLineW = listParam.oneLineW or 100
  local oneLineH = listParam.oneLineH or 94
  local oneLineNum = listParam.oneLineNum or 5
  local onePageNum = listParam.onePageNum or 20
  local w = listParam.width or 500
  local h = oneLineH * math.floor((self.m_ItemNum + oneLineNum - 1) / oneLineNum)
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(w, h))
  self:setContentSize(CCSize(w, h))
  self:setAnchorPoint(ccp(0, 1))
  for number, itemId in pairs(self.m_ObjIdList) do
    local itemObj = CPackageListItem.new(itemId, handler(self, self.ClickPackageItem))
    self.m_ObjViewList[#self.m_ObjViewList + 1] = itemObj
    local itemView = itemObj:getItemView()
    itemView:setPosition(ccp(delW + (number - 1) % oneLineNum * oneLineW, h - oneLineH - (math.ceil(number / oneLineNum) - 1) * oneLineH - delH))
    self:addChild(itemView)
  end
  if onePageNum > 0 then
    local addNum = 0
    if onePageNum > self.m_ItemNum then
      addNum = onePageNum - self.m_ItemNum
    elseif self.m_ItemNum % oneLineNum ~= 0 then
      addNum = oneLineNum - self.m_ItemNum % oneLineNum
    end
    for i = 1, addNum do
      local itemBg = display.newSprite("xiyou/item/itembg.png")
      local number = self.m_ItemNum + i
      itemBg:setPosition(ccp(delW + (number - 1) % oneLineNum * oneLineW, h - oneLineH - (math.ceil(number / oneLineNum) - 1) * oneLineH - delH))
      itemBg:setAnchorPoint(ccp(0, 0))
      self:addNode(itemBg)
    end
  end
end
function CPackageList:ClickPackageItem(itemObjId)
  self.m_PackageView:ShowPackageDetail(itemObjId)
end
function CPackageList:onCleanup()
  self.m_PackageView = nil
  self.m_ObjViewList = {}
end
CPackageListItem = class(".CPackageListItem")
function CPackageListItem:ctor(itemObjId, clickHandler)
  local player = g_DataMgr:getPlayer()
  local itemObj = player:GetOneItem(itemObjId)
  local itemView = createClickItem({
    itemID = itemObj:getTypeId(),
    autoSize = nil,
    num = itemObj:getProperty(ITEM_PRO_NUM),
    LongPressTime = 0,
    clickListener = function(...)
      clickHandler(itemObjId)
    end,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = 0,
    noBgFlag = nil
  })
  self.m_ItemView = itemView
end
function CPackageListItem:getItemView()
  return self.m_ItemView
end
