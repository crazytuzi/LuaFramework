function ShowPetListZhiYuanDlg(lst)
  if g_PetListZhiYuanDlg ~= nil then
    return
  end
  if g_PetListDlg then
    g_PetListDlg:SetShow(false)
  end
  getCurSceneView():addSubView({
    subView = CPetList_ZhiYuan.new(lst),
    zOrder = MainUISceneZOrder.menuView
  })
end
g_PetListZhiYuanDlg = nil
CPetList_ZhiYuan = class(".CPetList_ZhiYuan", CcsSubView)
function CPetList_ZhiYuan:ctor(lst)
  CPetList_ZhiYuan.super.ctor(self, "views/pet_list_zhiyuan.json", {isAutoCenter = true, opacityBg = 100})
  clickArea_check.extend(self)
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.list_pet = self:getNode("list_pet")
  self.list_war = self:getNode("list_war")
  self.list_pet:addTouchItemListenerListView(function(item, index, listObj)
    self:OnClickPetItem(index)
  end)
  self.list_war:addTouchItemListenerListView(function(item, index, listObj)
    self:OnClickWarItem(index)
  end)
  self:SetPetList(lst)
  if g_PetListZhiYuanDlg ~= nil then
    g_PetListZhiYuanDlg:CloseSelf()
  end
  g_PetListZhiYuanDlg = self
end
function CPetList_ZhiYuan:SetPetList(lst)
  lst = lst or {}
  local tempDict = {}
  for index, pId in ipairs(lst) do
    local petObj = g_LocalPlayer:getObjById(pId)
    if petObj then
      local item = CPetList_ZhiYuan_Item.new(pId, index)
      self.list_war:pushBackCustomItem(item.m_UINode)
      tempDict[pId] = true
    end
  end
  self.list_war:sizeChangedForShowMoreTips_Horizontal()
  local petIdList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  table.sort(petIdList, handler(self, self.sortFunc))
  self.list_pet:removeAllItems()
  for _, pId in ipairs(petIdList) do
    local petObj = g_LocalPlayer:getObjById(pId)
    if petObj and tempDict[pId] == nil and (petObj:petSkillIsActing(PETSKILL_GAOJIJISHIYU) or petObj:petSkillIsActing(PETSKILL_JISHIYU)) then
      local item = CPetList_ZhiYuan_Item.new(pId, nil)
      self.list_pet:pushBackCustomItem(item.m_UINode)
    end
  end
  self.list_pet:sizeChangedForShowMoreTips_Horizontal()
end
function CPetList_ZhiYuan:sortFunc(id_a, id_b)
  if id_a == nil or id_b == nil then
    if id_a ~= nil then
      return true
    else
      return false
    end
  end
  local petObj_a = g_LocalPlayer:getObjById(id_a)
  local petObj_b = g_LocalPlayer:getObjById(id_b)
  local zs_a = petObj_a:getProperty(PROPERTY_ZHUANSHENG)
  local zs_b = petObj_b:getProperty(PROPERTY_ZHUANSHENG)
  local lv_a = petObj_a:getProperty(PROPERTY_ROLELEVEL)
  local lv_b = petObj_b:getProperty(PROPERTY_ROLELEVEL)
  if zs_a ~= zs_b then
    return zs_a > zs_b
  elseif lv_a ~= lv_b then
    return lv_a > lv_b
  else
    return id_a < id_b
  end
end
function CPetList_ZhiYuan:OnClickPetItem(index)
  local doubleClickIndex, doubleClickItem
  local cnt = self.list_pet:getCount()
  for i = 0, cnt - 1 do
    local item = self.list_pet:getItem(i)
    item = item.m_UIViewParent
    if item then
      if i == index then
        if item:setSelected() then
          doubleClickIndex = i
          doubleClickItem = item
        end
      else
        item:setUnSelected()
      end
    end
  end
  local cnt_2 = self.list_war:getCount()
  for i = 0, cnt_2 - 1 do
    local item = self.list_war:getItem(i)
    item = item.m_UIViewParent
    if item then
      item:setUnSelected()
    end
  end
  if doubleClickItem ~= nil and doubleClickIndex ~= nil then
    self.list_pet:removeItem(doubleClickIndex)
    self.list_pet:sizeChangedForShowMoreTips_Horizontal()
    local petId = doubleClickItem:getPetId()
    self:setItemToWar(petId)
  end
end
function CPetList_ZhiYuan:setItemToPet(petId)
  local cnt = self.list_pet:getCount()
  for i = 0, cnt - 1 do
    local item = self.list_pet:getItem(i)
    item = item.m_UIViewParent
    if item and item:getPetId() == petId then
      return
    end
  end
  for i = 0, cnt - 1 do
    local item = self.list_pet:getItem(i)
    item = item.m_UIViewParent
    if item then
      local pId = item:getPetId()
      if self:sortFunc(petId, pId) then
        local item = CPetList_ZhiYuan_Item.new(petId, nil)
        self.list_pet:insertCustomItem(item.m_UINode, i)
        self.list_pet:sizeChangedForShowMoreTips_Horizontal()
        return
      end
    end
  end
  local item = CPetList_ZhiYuan_Item.new(petId, nil)
  self.list_pet:pushBackCustomItem(item.m_UINode)
  self.list_pet:sizeChangedForShowMoreTips_Horizontal()
end
function CPetList_ZhiYuan:OnClickWarItem(index)
  local doubleClickIndex, doubleClickItem
  local cnt = self.list_war:getCount()
  for i = 0, cnt - 1 do
    local item = self.list_war:getItem(i)
    item = item.m_UIViewParent
    if item then
      if i == index then
        if item:setSelected() then
          doubleClickIndex = i
          doubleClickItem = item
        end
      else
        item:setUnSelected()
      end
    end
  end
  local cnt_2 = self.list_pet:getCount()
  for i = 0, cnt_2 - 1 do
    local item = self.list_pet:getItem(i)
    item = item.m_UIViewParent
    if item then
      item:setUnSelected()
    end
  end
  if doubleClickItem ~= nil and doubleClickIndex ~= nil then
    self.list_war:removeItem(doubleClickIndex)
    self.list_war:sizeChangedForShowMoreTips_Horizontal()
    self:adjustWarIndex()
    local petId = doubleClickItem:getPetId()
    self:setItemToPet(petId)
  end
end
function CPetList_ZhiYuan:setItemToWar(petId)
  local cnt = self.list_war:getCount()
  for i = 0, cnt - 1 do
    local item = self.list_war:getItem(i)
    item = item.m_UIViewParent
    if item and item:getPetId() == petId then
      return
    end
  end
  local item = CPetList_ZhiYuan_Item.new(petId, cnt + 1)
  self.list_war:pushBackCustomItem(item.m_UINode)
  self.list_war:sizeChangedForShowMoreTips_Horizontal()
end
function CPetList_ZhiYuan:adjustWarIndex()
  local cnt = self.list_war:getCount()
  for i = 0, cnt - 1 do
    local item = self.list_war:getItem(i)
    item = item.m_UIViewParent
    if item then
      item:setIndex(i + 1)
    end
  end
end
function CPetList_ZhiYuan:OnBtn_Close(btnObj, touchType)
  local lst = {}
  local cnt = self.list_war:getCount()
  for i = 0, cnt - 1 do
    local item = self.list_war:getItem(i)
    item = item.m_UIViewParent
    if item then
      local pId = item:getPetId()
      lst[#lst + 1] = pId
    end
  end
  netsend.netteamwar.saveToServerShanXianList(lst)
  self:CloseSelf()
end
function CPetList_ZhiYuan:Clear()
  print("CPetList_ZhiYuan Clear")
  if g_PetListZhiYuanDlg == self then
    g_PetListZhiYuanDlg = nil
  end
  if g_PetListDlg and (not g_PetListDisplayDlg or not g_PetListDisplayDlg.m_UINode or not g_PetListDisplayDlg:isEnabled()) then
    g_PetListDlg:SetShow(true)
  end
end
CPetList_ZhiYuan_Item = class(".CPetList_ZhiYuan_Item", CcsSubView)
function CPetList_ZhiYuan_Item:ctor(petId, index)
  CPetList_ZhiYuan_Item.super.ctor(self, "views/pet_list_zhiyuan_item.json")
  self.m_PetId = petId
  local petObj = g_LocalPlayer:getObjById(petId)
  local ltype = petObj:getTypeId()
  local pname = petObj:getProperty(PROPERTY_NAME)
  local zs = petObj:getProperty(PROPERTY_ZHUANSHENG)
  local lv = petObj:getProperty(PROPERTY_ROLELEVEL)
  self.imgbox = self:getNode("imgbox")
  local parent = self.imgbox:getParent()
  local x, y = self.imgbox:getPosition()
  local headIcon = createHeadIconByRoleTypeID(ltype)
  parent:addNode(headIcon, 10)
  headIcon:setPosition(ccp(x, y + 7))
  self.name = self:getNode("name")
  self.name:setText(pname)
  AutoLimitObjSize(self.name, 104)
  color = NameColor_MainHero[zs]
  if color ~= nil then
    self.name:setColor(color)
  end
  self.level = self:getNode("level")
  self.level:setText(string.format("%d转%d级", zs, lv))
  self.m_Index = self:getNode("index")
  self:setIndex(index)
  self.m_IsSelected = nil
  self:setUnSelected(false)
  self.bg = self:getNode("bg")
  self.bg:setTouchEnabled(true)
  self.bg:addTouchEventListener(handler(self, self.TouchBg))
end
function CPetList_ZhiYuan_Item:getPetId()
  return self.m_PetId
end
function CPetList_ZhiYuan_Item:setIndex(index)
  if index ~= nil then
    self.m_Index:setText(tostring(index))
    self.m_Index:setVisible(true)
  else
    self.m_Index:setVisible(false)
  end
end
function CPetList_ZhiYuan_Item:setSelected()
  if self.m_IsSelected == true then
    return true
  end
  self.m_IsSelected = true
  self:showCorners(true)
  return false
end
function CPetList_ZhiYuan_Item:setUnSelected()
  if self.m_IsSelected == false then
    return
  end
  self.m_IsSelected = false
  self:showCorners(false)
end
function CPetList_ZhiYuan_Item:showCorners(iShow)
  for i = 1, 4 do
    local obj = self:getNode(string.format("corner_%d", i))
    if obj then
      obj:setVisible(iShow)
    end
  end
end
function CPetList_ZhiYuan_Item:TouchBg(touchObj, t)
  if t == TOUCH_EVENT_BEGAN then
    self:setTouchStatus(true)
  elseif t == TOUCH_EVENT_ENDED then
    self:setTouchStatus(false)
  elseif t == TOUCH_EVENT_CANCELED then
    self:setTouchStatus(false)
  end
end
function CPetList_ZhiYuan_Item:setTouchStatus(isTouch)
  if self.bg then
    self.bg:stopAllActions()
    if isTouch then
      self.bg:setScaleX(0.95)
      self.bg:setScaleY(0.95)
    else
      self.bg:setScaleX(1)
      self.bg:setScaleY(1)
      self.bg:runAction(transition.sequence({
        CCScaleTo:create(0.1, 1.05, 1.05),
        CCScaleTo:create(0.1, 1, 1)
      }))
    end
  end
end
