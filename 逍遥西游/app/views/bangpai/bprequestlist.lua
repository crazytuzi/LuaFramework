g_BpRequestList = nil
CBpRequestList = class("CBpRequestList", CcsSubView)
function CBpRequestList:ctor(pInfo)
  CBpRequestList.super.ctor(self, "views/bprequestlist.json", {isAutoCenter = true, opacityBg = 100})
  self.m_PlayerInfo = pInfo
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_clear = {
      listener = handler(self, self.OnBtn_Clear),
      variName = "btn_clear"
    },
    btn_update = {
      listener = handler(self, self.OnBtn_Update),
      variName = "btn_update"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.list_content = self:getNode("list_content")
  self.list_content:addLoadMoreListenerScrollView(function()
    self:ShowNextListPart()
  end)
  self.list_content:addTouchItemListenerListView(function(item, index, listObj)
    self:OnClickRequestListItem(item.m_UIViewParent)
  end)
  self:InitRequestList()
  self:ListenMessage(MsgID_BP)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
  if g_BpRequestList ~= nil then
    g_BpRequestList:CloseSelf()
    g_BpRequestList = nil
  end
  g_BpRequestList = self
  g_BpMgr:NewBpJoinRequest(false)
end
function CBpRequestList:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_BP_RequestList then
    local requestList = arg[1]
    self:SetRequestList(requestList)
  elseif msgSID == MsgID_BP_DeleteRequest then
    local pid = arg[1]
    if pid == 0 then
      self.list_content:removeAllItems()
      self.m_RequestDict = {}
      self.m_LastListIndex = 0
    else
      local cnt = self.list_content:getCount()
      for i = 0, cnt - 1 do
        local tempItem = self.list_content:getItem(i)
        local listItem = tempItem.m_UIViewParent
        if listItem:getPlayerId() == pid then
          self.list_content:removeItem(i)
          if self.m_LastClickItem == listItem then
            self.m_LastClickItem = nil
          end
          self.m_RequestDict[pid] = nil
          break
        end
      end
    end
  elseif msgSID == MsgID_BP_BpDlgIsInvalid then
    self:CloseSelf()
  end
end
function CBpRequestList:InitRequestList()
  self.m_LastListIndex = 0
  self.m_RequestDict = {}
  self:ShowNextListPart()
end
function CBpRequestList:ShowNextListPart()
  g_BpMgr:send_getBpRequestListInfo(self.m_LastListIndex)
end
function CBpRequestList:SetRequestList(requestList)
  local cnt = self.list_content:getCount()
  for index, playerData in pairs(requestList) do
    if self.m_RequestDict[playerData.i_pid] == nil then
      local item = CBpRequestListItem.new(playerData, cnt + index)
      self.list_content:pushBackCustomItem(item.m_UINode)
      self.m_LastListIndex = playerData.i_index
      self.m_RequestDict[playerData.i_pid] = true
    end
  end
  self.list_content:refreshView()
  if #requestList > 0 then
    self.list_content:setCanLoadMore(true)
  end
end
function CBpRequestList:OnClickRequestListItem(listItem)
  if self.m_LastClickItem then
    self.m_LastClickItem:setSelected(false)
  end
  self.m_LastClickItem = listItem
  self.m_LastClickItem:setSelected(true)
end
function CBpRequestList:OnBtn_Update()
  self.list_content:removeAllItems()
  self.m_LastListIndex = 0
  self.m_RequestDict = {}
  self:ShowNextListPart()
end
function CBpRequestList:OnBtn_Clear()
  local placeId = g_BpMgr:getLocalBpPlace()
  local bpData = data_Org_Auth[placeId]
  if bpData then
    if bpData.AuthAdd ~= 0 then
      g_BpMgr:send_clearBpRequest()
    else
      ShowNotifyTips("清空列表要求职位在香主以上，你没有权限接收哟")
    end
  else
    ShowNotifyTips("清空列表要求职位在香主以上，你没有权限接收哟")
  end
end
function CBpRequestList:OnBtn_Close()
  self:CloseSelf()
end
function CBpRequestList:Clear()
  self.m_LastClickItem = nil
  g_BpMgr:send_getBpRequestAmount()
  if g_BpRequestList == self then
    g_BpRequestList = nil
  end
end
CBpRequestListItem = class("CBpRequestListItem", CcsSubView)
function CBpRequestListItem:ctor(playerData, index)
  CBpRequestListItem.super.ctor(self, "views/bprequestlistitem.json")
  self.m_PlayerInfo = playerData
  self.m_Index = playerData.i_index
  local btnBatchListener = {
    btn_accept = {
      listener = handler(self, self.OnBtn_Accept),
      variName = "btn_accept"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local bgPath
  if index % 2 == 0 then
    bgPath = "views/common/bg/bg1062.png"
  else
    bgPath = "views/common/bg/bg1063.png"
  end
  local bg = display.newScale9Sprite(bgPath, 4, 4, CCSize(10, 10))
  bg:setAnchorPoint(ccp(0, 0))
  local size = self:getContentSize()
  bg:setContentSize(CCSize(size.width, size.height))
  self:addNode(bg, 0)
  local lTypeId = playerData.i_typeid
  local head = createWidgetFrameHeadIconByRoleTypeID(lTypeId)
  self:addChild(head, 1)
  head:setScale(0.35)
  head:setPosition(ccp(30, 22))
  self:getNode("txt_id"):setText(tostring(playerData.i_pid))
  AutoLimitObjSize(self:getNode("txt_id"), 95)
  self:getNode("txt_name"):setText(playerData.s_pname)
  local nameColor = NameColor_MainHero[playerData.i_zs] or ccc3(255, 255, 255)
  self:getNode("txt_name"):setColor(nameColor)
  AutoLimitObjSize(self:getNode("txt_name"), 110)
  self:getNode("txt_level"):setText(string.format("%d转%d级", playerData.i_zs, playerData.i_lv))
  local race = data_getRoleRace(playerData.i_typeid)
  self:getNode("txt_race"):setText(RACENAME_DICT[race] or "")
end
function CBpRequestListItem:getPlayerId()
  return self.m_PlayerInfo.i_pid
end
function CBpRequestListItem:getIndex()
  return self.m_Index
end
function CBpRequestListItem:setSelected(iSel)
  if iSel then
    if self.m_SelectedBg == nil then
      self.m_SelectedBg = display.newScale9Sprite("views/common/bg/bg1064.png", 4, 4, CCSize(10, 10))
      self.m_SelectedBg:setAnchorPoint(ccp(0, 0))
      local size = self:getContentSize()
      self.m_SelectedBg:setContentSize(CCSize(size.width, size.height))
      self:addNode(self.m_SelectedBg, 0)
    end
    self.m_SelectedBg:setVisible(true)
    self:setAllTextColor(255, 245, 121)
  else
    if self.m_SelectedBg then
      self.m_SelectedBg:setVisible(false)
    end
    self:setAllTextColor(221, 139, 29)
  end
end
function CBpRequestListItem:setAllTextColor(r, g, b)
  self:getNode("txt_id"):setColor(ccc3(r, g, b))
  self:getNode("txt_level"):setColor(ccc3(r, g, b))
  self:getNode("txt_race"):setColor(ccc3(r, g, b))
end
function CBpRequestListItem:OnBtn_Accept()
  g_BpMgr:send_agreeBpJoinRequest(self.m_PlayerInfo.i_pid)
end
function CBpRequestListItem:Clear()
end
