g_CPHBViewDlg = nil
CPHBView = class("CPHBView", CcsSubView)
function CPHBView:ctor()
  CPHBView.super.ctor(self, "views/paihangbang.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_allser = {
      listener = handler(self, self.OnBtn_AllSer),
      variName = "btn_allser"
    },
    btn_allfriend = {
      listener = handler(self, self.OnBtn_AllFriend),
      variName = "btn_allfriend"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_allser,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_allfriend,
      nil,
      ccc3(251, 248, 145)
    }
  })
  local size = self.btn_allser:getContentSize()
  self:adjustClickSize(self.btn_allser, size.width + 110, size.height + 80, true)
  local size = self.btn_allfriend:getContentSize()
  self:adjustClickSize(self.btn_allfriend, size.width + 110, size.height + 80, true)
  self:getNode("txt_detail3"):setVisible(false)
  self:getNode("layerCover"):setEnabled(false)
  self.list_type = self:getNode("list_type")
  self.pic_selected = self:getNode("pic_selected")
  self.list_type:addTouchItemListenerListView(handler(self, self.ChooseTypeItem), handler(self, self.ListEventListener))
  self.m_CurrMainType = nil
  self.m_CurrSubType = nil
  self.m_CurrRangeType = nil
  self.m_CurrListNumber = nil
  self.m_DetailList = self:getNode("list_item")
  self.m_DetailList:addTouchItemListenerListView(handler(self, self.OnClickItem), handler(self, self.DetailListEventListener))
  self.m_DetailList:addLoadMoreListenerScrollView(function()
    self:LoadMoreRankInfo()
  end)
  self.m_DetailList:setCanLoadMore(false)
  for index = 1, 6 do
    local obj = self:getNode(string.format("title_txt_1%d", index))
    local x, y = obj:getPosition()
    obj.__initPos = ccp(x, y)
  end
  self:InitPHBType()
  self:ListenMessage(MsgID_PHB)
  if g_CPHBViewDlg and g_CPHBViewDlg ~= self then
    g_CPHBViewDlg:CloseSelf()
  end
  g_CPHBViewDlg = self
end
function CPHBView:ShowPHBInfo(mType, subType)
  local number = self:GetNumber(mType, subType)
  if number == self.m_CurrListNumber then
    return
  end
  self:ClearRankList()
  self.m_CurrListNumber = number
  self.m_CurrMainType = mType
  self.m_CurrSubType = number - mType * 100
  self:ShowDetailList()
  self:SetTimeTip()
end
function CPHBView:ShowDetailList()
  self.m_CurrMainType = self.m_CurrMainType or PHB_DEF_ZhuangBei
  self.m_CurrSubType = self.m_CurrSubType or PHB_DEF_ZhuangBei_ZB
  self.m_CurrRangeType = self.m_CurrRangeType or PHB_DEF_RANGE_ALL
  print("ShowDetailList", self.m_CurrMainType, self.m_CurrSubType, self.m_CurrRangeType)
  local idx = 1
  for index, str in pairs(PHB_DEF_Title_Data[self.m_CurrMainType][self.m_CurrSubType]) do
    local obj = self:getNode(string.format("title_txt_1%d", index))
    obj:setText(str)
    obj:setVisible(true)
    if self.m_CurrSubType == PHB_DEF_BiWu_XZ then
      if index == 3 then
        obj:setPosition(ccp(obj.__initPos.x + 45, obj.__initPos.y))
      elseif index == 4 then
        obj:setPosition(ccp(obj.__initPos.x + 20, obj.__initPos.y))
      else
        obj:setPosition(obj.__initPos)
      end
    else
      obj:setPosition(obj.__initPos)
    end
    idx = index
  end
  for i = idx + 1, 6 do
    local obj = self:getNode(string.format("title_txt_1%d", i))
    obj:setVisible(false)
  end
  self:LoadMoreRankInfo()
end
function CPHBView:SetTimeTip()
  if self.m_CurrSubType == PHB_DEF_BiWu_XZ then
    self:getNode("txt_detail3"):setText("下次活动开启时刷新")
  else
    self:getNode("txt_detail3"):setText("每天刷新时间:5点,17点")
  end
  self:getNode("txt_detail3"):setVisible(true)
end
function CPHBView:InitPHBType()
  self.m_PHBType = {}
  local temp = {}
  for _, itemData in pairs(PHB_DEF_Data) do
    local mType = itemData[1]
    local sType = itemData[3]
    local sTypeList = self.m_PHBType[mType]
    if sTypeList == nil then
      sTypeList = {}
      self.m_PHBType[mType] = sTypeList
      temp[#temp + 1] = {
        mType,
        itemData[2]
      }
    end
    if sTypeList[sType] == nil then
      sTypeList[sType] = itemData[4]
    end
  end
  for index, d in pairs(temp) do
    local mainTypeItem = CMainTypeListItem.new(d[1], d[2], "views/paihangbang/phb_btn_kind1.png", 26, ccc3(255, 245, 121), 0)
    self.list_type:pushBackCustomItem(mainTypeItem)
  end
  if #temp > 0 then
    local firstMainType = temp[1][1]
    local subTypes = self.m_PHBType[firstMainType]
    local tempList = {}
    for subType, _ in pairs(subTypes) do
      tempList[#tempList + 1] = subType
    end
    local _sortFuncSub = function(a, b)
      if a == nil or b == nil then
        return false
      end
      return a < b
    end
    if #tempList > 0 then
      table.sort(tempList, _sortFuncSub)
      local firstSubType = tempList[1]
      self:ShowPHBInfo(firstMainType, firstSubType)
      self:ShowPHBSubType(0, 1)
    end
  end
end
function CPHBView:ShowPHBSubType(index, mainType)
  local subTypes = self.m_PHBType[mainType]
  if subTypes == nil then
    return
  end
  local temp = {}
  for subType, subTypeName in pairs(subTypes) do
    temp[#temp + 1] = {subType, subTypeName}
  end
  local _sortFunc = function(a, b)
    if a == nil or b == nil then
      return false
    end
    return a[1] > b[1]
  end
  table.sort(temp, _sortFunc)
  local firstSubType, firstSubTypeItem
  for _, d in pairs(temp) do
    local subTypeItem = CSubTypeListItem.new(mainType, d[1], d[2], "views/paihangbang/phb_btn_kind2.png", "views/paihangbang/phb_btn_kind2_sel.png", 0)
    self.list_type:insertCustomItem(subTypeItem, index + 1)
    if self:GetNumber(mainType, d[1]) == self.m_CurrListNumber then
      subTypeItem:setItemChoosed(true)
    end
    firstSubType = d[1]
    firstSubTypeItem = subTypeItem
  end
  self.list_type:ListViewScrollToIndex_Vertical(index + 1, 0.3)
  self.m_SubTypeIsShow = true
  return firstSubType, firstSubTypeItem
end
function CPHBView:GetNumber(mainType, subType)
  return mainType * 100 + subType
end
function CPHBView:HideAllSubType()
  for index = self.list_type:getCount() - 1, 0, -1 do
    local item = self.list_type:getItem(index)
    if iskindof(item, "CSubTypeListItem") then
      self.list_type:removeItem(index)
    end
  end
  self.m_SubTypeIsShow = false
end
function CPHBView:ChooseTypeItem(item, index)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  if iskindof(item, "CMainTypeListItem") then
    local mainType = item:getMainType()
    if self.m_CurrMainType == mainType then
      if self.m_SubTypeIsShow then
        self:HideAllSubType()
      else
        self:ShowPHBSubType(index, mainType)
      end
    else
      self:HideAllSubType()
      local insertIndex
      for i = 0, self.list_type:getCount() - 1 do
        local tempItem = self.list_type:getItem(i)
        if iskindof(tempItem, "CMainTypeListItem") and tempItem:getMainType() == mainType then
          insertIndex = i
          break
        end
      end
      if insertIndex ~= nil then
        local firstSubType, firstSubTypeItem = self:ShowPHBSubType(insertIndex, mainType)
        self.m_CurrMainType = mainType
        if firstSubType ~= nil then
          firstSubTypeItem:setItemChoosed(true)
          self:ShowPHBInfo(mainType, firstSubType)
        end
      end
    end
  elseif iskindof(item, "CSubTypeListItem") then
    for index = self.list_type:getCount() - 1, 0, -1 do
      local tempItem = self.list_type:getItem(index)
      if iskindof(tempItem, "CSubTypeListItem") then
        if tempItem ~= item then
          tempItem:setItemChoosed(false)
        else
          tempItem:setItemChoosed(true)
        end
      end
    end
    local mainType = item:getMainType()
    local subType = item:getSubType()
    self:ShowPHBInfo(mainType, subType)
  end
end
function CPHBView:ListEventListener(item, index, listObj, status)
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
function CPHBView:OnClickItem(item, index)
  item = item.m_UIViewParent
  if item.OnClicked then
    item:OnClicked()
  end
end
function CPHBView:DetailListEventListener(item, index, listObj, status)
  item = item.m_UIViewParent
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if item then
      item:setTouchStatus(true)
      self.m_TouchStartDetailItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartDetailItem then
      self.m_TouchStartDetailItem:setTouchStatus(false)
      self.m_TouchStartDetailItem = nil
    end
    if item then
      item:setTouchStatus(false)
    end
  end
end
function CPHBView:LoadMoreRankInfo()
  if self.m_CurrSubType == nil or self.m_CurrRangeType == nil then
    return
  end
  self:SetBtnsCanOperation(false)
  local index = self.m_DetailList:getCount()
  print("CPHBView:LoadMoreRankInfo", index)
  local infoList, canOpFlag, isloading = g_PHBMgr:getPHBRankInfo(self.m_CurrSubType, self.m_CurrRangeType, index)
  if infoList ~= nil then
    self:LoadRankInfo(self.m_CurrSubType, self.m_CurrRangeType, infoList)
  end
  if not isloading then
    self:SetBtnsCanOperation(true)
  else
    self:SetBtnsCanOperation(false)
  end
  if index <= 0 then
    self:RequestSelfData()
  end
end
function CPHBView:LoadRankInfo(subType, range, infoList)
  if self.m_CurrSubType ~= subType or self.m_CurrRangeType ~= range then
    return
  end
  if infoList == nil then
    return
  end
  if self.m_IsLoading then
    return
  end
  self.m_IsLoading = true
  for _, info in ipairs(infoList) do
    local item = CPHBViewItem.new(info, self.m_CurrSubType)
    self.m_DetailList:pushBackCustomItem(item:getUINode())
  end
  self.m_DetailList:refreshView()
  if #infoList > 0 then
    self.m_DetailList:setCanLoadMore(true)
  end
  self.m_IsLoading = false
end
function CPHBView:SetSelfData(bType, num, index)
  print("CPHBView:SetSelfData", bType, num, index)
  if bType ~= self.m_CurrSubType then
    return
  end
  if num == nil or num == 0 then
    self:getNode("txt_detail1"):setEnabled(false)
    self:getNode("txt_detail2"):setEnabled(true)
    self:getNode("txt_detail2"):setText("你目前排行:暂时未能上榜,请继续加油!")
  else
    self:getNode("txt_detail1"):setEnabled(true)
    self:getNode("txt_detail2"):setEnabled(true)
    local t = math.floor(bType / 10)
    if t == PHB_DEF_ZhuangBei then
      self:getNode("txt_detail1"):setText(string.format("身穿装备评价:%d", num))
    elseif t == PHB_DEF_BingQi then
      self:getNode("txt_detail1"):setText(string.format("身穿装备评价:%d", num))
    elseif bType == PHB_DEF_CaiFu_YB then
      self:getNode("txt_detail1"):setText(string.format("银币:%d", num))
    elseif bType == PHB_DEF_CaiFu_TQ then
      self:getNode("txt_detail1"):setText(string.format("铜钱:%d", num))
    else
      self:getNode("txt_detail1"):setEnabled(false)
    end
    if index == nil then
      self:getNode("txt_detail2"):setText("你目前排行:暂时未能上榜,请继续加油!")
    else
      self:getNode("txt_detail2"):setText(string.format("你目前排行:%d", index))
    end
  end
  local rType = g_LocalPlayer:getObjProperty(1, PROPERTY_SHAPE)
  local race = data_getRoleRace(rType)
  if race == RACE_REN then
    if bType == PHB_DEF_ZhuangBei_MZ or bType == PHB_DEF_ZhuangBei_XZ or bType == PHB_DEF_ZhuangBei_GZ then
      self:getNode("txt_detail2"):setEnabled(false)
    end
  elseif race == RACE_MO then
    if bType == PHB_DEF_ZhuangBei_RZ or bType == PHB_DEF_ZhuangBei_XZ or bType == PHB_DEF_ZhuangBei_GZ then
      self:getNode("txt_detail2"):setEnabled(false)
    end
  elseif race == RACE_XIAN then
    if bType == PHB_DEF_ZhuangBei_MZ or bType == PHB_DEF_ZhuangBei_RZ or bType == PHB_DEF_ZhuangBei_GZ then
      self:getNode("txt_detail2"):setEnabled(false)
    end
  elseif race == RACE_GUI and (bType == PHB_DEF_ZhuangBei_MZ or bType == PHB_DEF_ZhuangBei_RZ or bType == PHB_DEF_ZhuangBei_XZ) then
    self:getNode("txt_detail2"):setEnabled(false)
  end
end
function CPHBView:RequestSelfData()
  print("CPHBView:RequestSelfData", self.m_CurrSubType)
  self:getNode("txt_detail1"):setEnabled(false)
  self:getNode("txt_detail2"):setEnabled(false)
  if self.m_CurrSubType ~= nil then
    g_PHBMgr:send_requestPHBSelfData(self.m_CurrSubType)
  end
end
function CPHBView:ClearRankList()
  self.m_DetailList:removeAllItems()
  self.m_DetailList:setInnerContainerSize(CCSize(0, 0))
end
function CPHBView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_PHB_NewRankInfo then
    local subType = arg[1]
    local range = arg[2]
    local infoList = arg[3]
    self:LoadRankInfo(subType, range, infoList)
    self:SetBtnsCanOperation(true)
  elseif msgSID == MsgID_PHB_ClearRankList then
    self:ClearRankList()
    self:SetBtnsCanOperation(true)
  elseif msgSID == MsgID_PHB_RankIsOk then
    self:SetBtnsCanOperation(true)
  elseif msgSID == MsgID_PHB_RankIsFinished then
    self:SetBtnsCanOperation(true)
  elseif msgSID == MsgID_PHB_UpdateSelfData then
    local selfData = arg[1]
    self:SetSelfData(selfData.bType, selfData.num, selfData.index)
  end
end
function CPHBView:SetBtnsCanOperation(flag)
  print("SetBtnsCanOperation", flag)
  self:getNode("layerCover"):setEnabled(not flag)
  self.btn_allser:setTouchEnabled(flag)
  self.btn_allfriend:setTouchEnabled(flag)
  if flag then
    if self.m_LoadingImg then
      self.m_LoadingImg:removeFromParent()
      self.m_LoadingImg = nil
    end
  elseif self.m_LoadingImg == nil then
    self.m_LoadingImg = CreateALoadingSprite()
    self:addNode(self.m_LoadingImg, 999)
    local x, y = self.m_DetailList:getPosition()
    local size = self.m_DetailList:getContentSize()
    self.m_LoadingImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  end
end
function CPHBView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CPHBView:OnBtn_AllSer(btnObj, touchType)
  self.m_CurrRangeType = PHB_DEF_RANGE_ALL
  local x, _ = self.btn_allser:getPosition()
  local _, y = self.pic_selected:getPosition()
  self.pic_selected:setPosition(ccp(x, y))
  self:ClearRankList()
  self:ShowDetailList()
end
function CPHBView:OnBtn_AllFriend(btnObj, touchType)
  ShowNotifyTips("功能尚未开放，敬请期待")
  self:setGroupBtnSelected(self.btn_allser)
  do return end
  self.m_CurrRangeType = PHB_DEF_RANGE_FRIEND
  local x, _ = self.btn_allfriend:getPosition()
  local _, y = self.pic_selected:getPosition()
  self.pic_selected:setPosition(ccp(x, y))
  self:ClearRankList()
  self:ShowDetailList()
end
function CPHBView:setCheckDetailDlg(dlg)
  if dlg == nil then
    return
  end
  local nameTitle = self:getNode("title_txt_13")
  local x, y = nameTitle:getPosition()
  local p = nameTitle:getParent()
  local wPos = p:convertToWorldSpace(ccp(x - 80, y))
  local pos = dlg:getParent():convertToNodeSpace(ccp(wPos.x, display.height / 2))
  local size = dlg:getContentSize()
  dlg:setPosition(ccp(pos.x - size.width, pos.y - size.height / 2))
end
function CPHBView:Clear()
  if g_CPHBViewDlg == self then
    g_CPHBViewDlg = nil
  end
end
CPHBViewItem = class("CPHBViewItem", CcsSubView)
function CPHBViewItem:ctor(infoPara, curType)
  self.m_Type = curType
  self.m_Index = infoPara.index
  self.m_Name = infoPara.name or ""
  self.m_BPName = infoPara.bp or ""
  self.m_Shape = infoPara.shape or 0
  self.m_Zs = infoPara.zs or 0
  self.m_Lv = infoPara.lv or 0
  self.m_Score = infoPara.s or 0
  self.m_ZBShape = infoPara.zbs or 0
  self.m_PlayerId = infoPara.pid
  self.m_ZBId = infoPara.zbid
  CPHBViewItem.super.ctor(self, "views/paihangbang_item.json")
  self:getNode("txt_11"):setText(string.format("%d", self.m_Index))
  if self.m_Type == PHB_DEF_BangPai_BP then
    self:getNode("txt_12"):setText(string.format("%s", self.m_BPName))
    local x, y = self:getNode("txt_12"):getPosition()
    self:getNode("txt_12"):setPosition(ccp(x - 13, y))
  else
    self:getNode("txt_12"):setText(string.format("%s", self.m_Name))
  end
  if math.floor(self.m_Type / 10) == PHB_DEF_BingQi then
    local zbName = data_getItemName(self.m_ZBShape)
    self:getNode("txt_13"):setText(string.format("%s", zbName))
  elseif self.m_Type == PHB_DEF_ZhuangBei_ZB or self.m_Type == PHB_DEF_ChongJi_CJ or self.m_Type == PHB_DEF_BiWu_BW or self.m_Type == PHB_DEF_BiWu_XZ then
    local gender = data_getRoleGender(self.m_Shape)
    local sexStr = Def_Gender_Name[gender]
    local race = data_getRoleRace(self.m_Shape)
    local raceStr = Def_Role_Name[race]
    self:getNode("txt_13"):setText(string.format("%s%s", sexStr, raceStr))
  elseif self.m_Zs == 0 then
    self:getNode("txt_13"):setText(string.format("%d级", self.m_Lv))
  else
    self:getNode("txt_13"):setText(string.format("%d转%d级", self.m_Zs, self.m_Lv))
  end
  if self.m_Type == PHB_DEF_ChongJi_CJ or self.m_Type == PHB_DEF_BiWu_BW or self.m_Type == PHB_DEF_BiWu_XZ then
    if self.m_Zs == 0 then
      self:getNode("txt_15"):setText(string.format("%d级", self.m_Lv))
    else
      self:getNode("txt_15"):setText(string.format("%d转%d级", self.m_Zs, self.m_Lv))
    end
  else
    self:getNode("txt_15"):setText(string.format("%d", self.m_Score))
  end
  if self.m_Type == PHB_DEF_BangPai_BP then
    self:getNode("txt_14"):setText(string.format("%s", self.m_Name))
    self:getNode("txt_15"):setText(string.format("%d", self.m_Score))
  else
    self:getNode("txt_14"):setText(string.format("%s", self.m_BPName))
  end
  self.m_Bg = self:getNode("bg")
  if self.m_Index % 2 == 0 then
    self.m_Bg:setVisible(false)
  end
  if self.m_Index <= 3 then
    self:getNode("txt_11"):setVisible(false)
    local x, y = self:getNode("txt_11"):getPosition()
    local numImg = display.newSprite(string.format("views/paihangbang/phb_pic_rank%d.png", self.m_Index))
    numImg:setPosition(ccp(x, y))
    self:addNode(numImg)
    for i = 1, 6 do
      self:getNode(string.format("txt_1%d", i)):setColor(ccc3(255, 245, 121))
    end
  end
  self:getNode("headpos"):setVisible(false)
  if self.m_Type == PHB_DEF_BangPai_BP then
  else
    local shapeID = self.m_Shape
    local x, y = self:getNode("headpos"):getPosition()
    local size = self:getNode("headpos"):getContentSize()
    local head = createWidgetFrameHeadIconByRoleTypeID(shapeID, size, false, {x = 0, y = -5})
    self:addChild(head, 1)
    head:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  end
  if self.m_Type == PHB_DEF_BiWu_XZ then
    self:getNode("txt_16"):setVisible(true)
    self:getNode("txt_16"):setText(tostring(self.m_Score))
    for i = 3, 4 do
      local obj = self:getNode(string.format("txt_1%d", i))
      local x, y = obj:getPosition()
      if i == 3 then
        obj:setPosition(ccp(x + 45, y))
      elseif i == 4 then
        obj:setPosition(ccp(x + 20, y))
      end
    end
    AutoLimitObjSize(self:getNode("txt_12"), 100)
  else
    self:getNode("txt_16"):setVisible(false)
  end
end
function CPHBViewItem:OnClicked()
  if math.floor(self.m_Type / 10) == PHB_DEF_BingQi and self.m_PlayerId ~= nil and self.m_ZBId ~= nil then
    ShowChatDetail_Item(self.m_PlayerId, self.m_ZBId, self.m_ZBShape)
  end
end
function CPHBViewItem:setTouchStatus(flag)
  if math.floor(self.m_Type / 10) ~= PHB_DEF_BingQi then
    return
  end
  local children = self.m_UINode:getChildren()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      if node and node ~= self.m_Bg and node.setScale then
        if flag then
          node:setScale(0.9)
        else
          node:setScale(1)
        end
      end
    end
  end
  local children = self.m_UINode:getNodes()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      if node and node ~= self.m_Bg and node.setScale then
        if flag then
          node:setScale(0.9)
        else
          node:setScale(1)
        end
      end
    end
  end
end
function CPHBViewItem:Clear()
end
