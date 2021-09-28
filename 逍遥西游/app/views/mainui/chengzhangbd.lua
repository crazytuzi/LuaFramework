ChengZhangBD = class("ChengZhangBD", CcsSubView)
function ChengZhangBD:ctor()
  ChengZhangBD.super.ctor(self, "views/chengzhangbd.csb", {isAutoCenter = true, opacityBg = 100})
  local mainRole = g_LocalPlayer:getMainHero()
  if mainRole == nil then
    printLog("ERROR", "找不到主英雄2")
    return
  end
  self.zsNum = mainRole:getProperty(PROPERTY_ZHUANSHENG)
  self.lvNum = mainRole:getProperty(PROPERTY_ROLELEVEL)
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Closed),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  JumpExtend.extend(self)
  self:initSecondPage()
  self:initFirstList()
  self:ListenMessage(MsgID_MapScene)
  self.curInform = {}
end
function ChengZhangBD:ChooseTypeItem(item, index)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  print(" =======>... ChooseTypeItem  index = ", index, self.m_LastSecected)
  if iskindof(item, "CMainTypeListItem") then
    if self.m_OpenMainMenu ~= true then
      self:addSecondMenu(item.TypeIndex)
    elseif self.m_LastSecected ~= index + 1 then
      self:addSecondMenu(item.TypeIndex)
    else
      self:ClearSecondMenu()
    end
  elseif iskindof(item, "CSubTypeListItem") then
    print("ChooseTypeItem  select CSubTypeListItem  i = ", index)
    self:resetChooseState(index)
  end
end
function ChengZhangBD:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if item then
      item:setTouchStatus(true)
      self.m_TouchStartItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartItem then
      self.m_TouchStartItem:setTouchStatus(false)
      self.m_TouchStartItem = nil
    end
    if item then
      item:setTouchStatus(false)
    end
  end
end
function ChengZhangBD:initFirstList()
  self.firstList = self:getNode("menulist")
  self.firstList:addTouchItemListenerListView(handler(self, self.ChooseTypeItem), handler(self, self.ListEventListener))
  self.m_LargeItemList = {}
  self:setFirstMenu()
  if self.m_FirstList == nil then
    self.m_FirstList = {}
  end
  for k, index in ipairs(self.m_FirstList) do
    local tempItem = CMainTypeListItem.new(k, index.name)
    tempItem.TypeIndex = index.TypeIndex
    self.m_LargeItemList[#self.m_LargeItemList + 1] = tempItem
    self.firstList:pushBackCustomItem(tempItem)
  end
  self:addSecondMenu(1)
  self.m_LastSecected = 1
end
function ChengZhangBD:initSecondPage()
  self.secondPage = self:getNode("subitemlist")
end
function ChengZhangBD:setFirstMenu()
  print("========================================= data_Chengzhangbd", data_Chengzhangbd[1].name)
  self.m_FirstList = nil
  self.m_FirstList = {}
  for index = 1, 9 do
    local proitem = data_Chengzhangbd[index]
    if proitem ~= nil and data_judgeFuncOpen(self.zsNum, self.lvNum, proitem.level[1], proitem.level[2], proitem.AlwaysJudgeLvFlag) then
      proitem.TypeIndex = index
      self.m_FirstList[#self.m_FirstList + 1] = proitem
    end
  end
end
function ChengZhangBD:setSecondMenu(pindex)
  self.m_SecondList = nil
  self.m_SecondList = {}
  for index = 1, 9 do
    local proitem = data_Chengzhangbd[pindex * 10 + index]
    if proitem ~= nil and data_judgeFuncOpen(self.zsNum, self.lvNum, proitem.level[1], proitem.level[2], proitem.AlwaysJudgeLvFlag) then
      proitem.TypeIndex = pindex * 10 + index
      self.m_SecondList[#self.m_SecondList + 1] = proitem
    end
    local proitemExtend
    if index == 9 then
      for key = 1, 9 do
        proitemExtend = data_Chengzhangbd[pindex * 100 + index * 10 + key]
        if proitemExtend ~= nil and data_judgeFuncOpen(self.zsNum, self.lvNum, proitemExtend.level[1], proitemExtend.level[2], proitemExtend.AlwaysJudgeLvFlag) then
          proitemExtend.TypeIndex = pindex * 100 + index * 10 + key
          self.m_SecondList[#self.m_SecondList + 1] = proitemExtend
        end
      end
    end
  end
end
function ChengZhangBD:setThirdMenu(findex, sindex)
  self.m_ThirdList = nil
  self.m_ThirdList = {}
  local seconIdex = findex * 10 + sindex
  local mainHero = g_LocalPlayer:getMainHero()
  local typeID = mainHero:getTypeId()
  local race = data_getRoleRace(typeID)
  local gender = data_getRoleGender(typeID)
  if seconIdex == 14 then
    for index = 1, 20 do
      local itemIdex = findex * 1000 + sindex * 100 + index
      local jump_item = data_Chengzhangbd[itemIdex]
      if jump_item == nil then
        return
      end
      local proitem
      if race == RACE_REN and gender == HERO_MALE and (jump_item.clickID == CZBD_ITEM_1401 or jump_item.clickID == CZBD_ITEM_1402) then
        proitem = data_Chengzhangbd[itemIdex]
      end
      if race == RACE_REN and gender == HERO_FEMALE and (jump_item.clickID == CZBD_ITEM_1403 or jump_item.clickID == CZBD_ITEM_1404) then
        proitem = data_Chengzhangbd[itemIdex]
      end
      if race == RACE_MO and gender == HERO_MALE and (jump_item.clickID == CZBD_ITEM_1409 or jump_item.clickID == CZBD_ITEM_1410) then
        proitem = data_Chengzhangbd[itemIdex]
      end
      if race == RACE_MO and gender == HERO_FEMALE and (jump_item.clickID == CZBD_ITEM_1411 or jump_item.clickID == CZBD_ITEM_1412) then
        proitem = data_Chengzhangbd[itemIdex]
      end
      if race == RACE_XIAN and gender == HERO_MALE and (jump_item.clickID == CZBD_ITEM_1405 or jump_item.clickID == CZBD_ITEM_1406) then
        proitem = data_Chengzhangbd[itemIdex]
      end
      if race == RACE_XIAN and gender == HERO_FEMALE and (jump_item.clickID == CZBD_ITEM_1407 or jump_item.clickID == CZBD_ITEM_1408) then
        proitem = data_Chengzhangbd[itemIdex]
      end
      if race == RACE_GUI and gender == HERO_MALE and (jump_item.clickID == CZBD_ITEM_1413 or jump_item.clickID == CZBD_ITEM_1414) then
        proitem = data_Chengzhangbd[itemIdex]
      end
      if race == RACE_GUI and gender == HERO_FEMALE and (jump_item.clickID == CZBD_ITEM_1415 or jump_item.clickID == CZBD_ITEM_1416) then
        proitem = data_Chengzhangbd[itemIdex]
      end
      if proitem ~= nil and data_judgeFuncOpen(self.zsNum, self.lvNum, proitem.level[1], proitem.level[2], proitem.AlwaysJudgeLvFlag) then
        proitem.TypeIndex = findex * 1000 + sindex * 100 + index
        self.m_ThirdList[#self.m_ThirdList + 1] = proitem
      end
    end
  else
    for index = 1, 20 do
      local itemID = findex * 1000 + sindex * 100 + index
      local proitem = data_Chengzhangbd[itemID]
      if proitem ~= nil and data_judgeFuncOpen(self.zsNum, self.lvNum, proitem.level[1], proitem.level[2], proitem.AlwaysJudgeLvFlag) then
        if proitem.clickID == CZBD_ITEM_4006 or proitem.clickID == CZBD_ITEM_5004 then
          if CDaTingCangBaoTu.cnt < DaTingCangBaoTu_MaxCircle then
            proitem.TypeIndex = itemID
            self.m_ThirdList[#self.m_ThirdList + 1] = proitem
          end
        else
          proitem.TypeIndex = itemID
          self.m_ThirdList[#self.m_ThirdList + 1] = proitem
        end
      end
    end
  end
end
function ChengZhangBD:ClearSecondMenu()
  if not self.m_OpenMainMenu then
    return
  end
  for index = self.firstList:getCount() - 1, 0, -1 do
    local item = self.firstList:getItem(index)
    if iskindof(item, "CSubTypeListItem") then
      self.firstList:removeItem(index)
    end
  end
  self.m_OpenMainMenu = false
end
function ChengZhangBD:addSecondMenu(findex)
  print(" ============== addSecondMenu  findex = ", findex)
  if self.m_OpenMainMenu == true and findex == self.m_LastSecected then
    return
  end
  self:ClearSecondMenu()
  local mindex = findex
  for k, v in pairs(self.m_FirstList) do
    if v.TypeIndex == findex then
      mindex = k
      break
    end
  end
  self:setSecondMenu(findex)
  if self.m_SecondList ~= nil and #self.m_SecondList > 0 then
    local minIndexItem
    for index = #self.m_SecondList, 1, -1 do
      local proitem = CSubTypeListItem.new(nil, index, self.m_SecondList[index].name)
      proitem.TypeIndex = self.m_SecondList[index].TypeIndex
      if minIndexItem == nil or minIndexItem.TypeIndex > proitem.TypeIndex then
        minIndexItem = proitem
      else
      end
      proitem:setItemChoosed(false)
      self.firstList:insertCustomItem(proitem, mindex)
    end
    if minIndexItem then
      minIndexItem:setItemChoosed(true)
      self:addSecondPage(findex, minIndexItem.TypeIndex % 10)
    end
    self.m_OpenMainMenu = true
    self.m_LastSecected = findex
  else
    self:addSecondPage(findex, 0)
  end
  self.firstList:ListViewScrollToIndex_Vertical(mindex, 0.3)
end
function ChengZhangBD:resetChooseState(curselect)
  if not self.m_OpenMainMenu or not (curselect <= self.firstList:getCount() - 1) or not (curselect >= 1) then
    return
  end
  for index = self.firstList:getCount() - 1, 0, -1 do
    local item = self.firstList:getItem(index)
    if iskindof(item, "CSubTypeListItem") and index ~= curselect then
      item:setItemChoosed(false)
    end
  end
  item = self.firstList:getItem(curselect)
  if item then
    item:setItemChoosed(true)
    local si = item.TypeIndex % 10
    local fi = (item.TypeIndex - si) / 10
    print(" =========>... item.TypeIndex = ", fi, si)
    self:addSecondPage(fi, si)
  end
end
function ChengZhangBD:ClearSecondPage()
  for index = self.secondPage:getCount() - 1, 0, -1 do
    local item = self.firstList:getItem(index)
    if item then
      self.secondPage:removeItem(index)
    end
  end
end
function ChengZhangBD:addSecondPage(findex, sindex)
  self:ClearSecondPage()
  self:setThirdMenu(findex, sindex)
  if self.m_ThirdList then
    for index = 1, #self.m_ThirdList do
      do
        local tempItem = ChengZhangBD_Item.new(index, self.m_ThirdList[index].name, function()
          self:onBtnJump(self.m_ThirdList[index].TypeIndex)
        end, function()
          local title = self.m_ThirdList[index].name
          local dec = self.m_ThirdList[index].dec
          local lvdata = self.m_ThirdList[index].level
          local level = "未知"
          if lvdata ~= nil then
            level = string.format("%d转%d级", lvdata[1], lvdata[2])
          end
          if self.curInform then
            for k, v in pairs(self.curInform) do
              if v then
                v:onClose()
                self.curInform[k] = nil
              end
            end
          end
          self.curInform[#self.curInform + 1] = getCurSceneView():ShowInformView(title, {
            {
              "等级要求:",
              level
            },
            {
              "帮助说明:",
              dec
            }
          }, function(obj)
            for k, v in pairs(self.curInform) do
              if obj == v then
                self.curInform[k] = nil
              end
            end
          end, "xiyou/head/head20034_big.png")
        end)
        tempItem.TypeIndex = self.m_ThirdList[index].TypeIndex
        self.secondPage:pushBackCustomItem(tempItem)
      end
    end
  end
end
function ChengZhangBD:onBtnJump(id)
  print(" =========>.. onBtnJump id = ", id)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  local jump_item = data_Chengzhangbd[id] or {}
  local jump_id = jump_item.clickID
  if jump_id ~= nil then
    self:StartJump(jump_id)
  else
    print(" 成长宝典数据错误 **********  ")
  end
end
function ChengZhangBD:Btn_Closed(obj, objType)
  self:CloseSelf()
end
function ChengZhangBD:OnMessage(msgSID, ...)
  if msgSID == MsgID_MapScene_AutoRoute and g_LocalPlayer:getNormalTeamer() ~= true then
    self:CloseSelf()
  end
end
function ChengZhangBD:SetShow(iShow)
  if self.m_UINode ~= nil then
    self:setEnabled(iShow)
    if self._auto_create_opacity_bg_ins then
      self._auto_create_opacity_bg_ins:setEnabled(iShow)
    end
  end
end
function ChengZhangBD:Clear()
  if self.curInform then
    for k, v in pairs(self.curInform) do
      self.curInform[k] = nil
    end
    self.curInform = nil
  end
  if self.m_FirstList then
    for k, v in pairs(self.m_FirstList) do
      self.m_FirstList[k] = nil
    end
  end
  if self.m_SecondList then
    for k, v in pairs(self.m_SecondList) do
      self.m_SecondList[k] = nil
    end
  end
  if self.m_ThirdList then
    for k, v in pairs(self.m_ThirdList) do
      self.m_ThirdList[k] = nil
    end
  end
end
