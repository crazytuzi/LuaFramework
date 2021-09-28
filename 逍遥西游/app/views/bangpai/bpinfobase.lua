CBpInfoPageBase = class("CBpInfoPageBase", CcsSubView)
function CBpInfoPageBase:ctor()
  CBpInfoPageBase.super.ctor(self, "views/bangpai_base.json")
  clickArea_check.extend(self)
  local btnBatchListener = {
    btn_quit = {
      listener = handler(self, self.OnBtn_Quit),
      variName = "btn_quit"
    },
    btn_tenet = {
      listener = handler(self, self.OnBtn_Notice),
      variName = "btn_tenet"
    },
    btn_contribute = {
      listener = handler(self, self.OnBtn_Contribute),
      variName = "btn_contribute"
    },
    btn_requestlist = {
      listener = handler(self, self.OnBtn_RequestList),
      variName = "btn_requestlist"
    },
    btn_rename = {
      listener = handler(self, self.OnBtn_ReName),
      variName = "btn_rename"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.list_member = self:getNode("list_member")
  self.list_tenet = self:getNode("list_tenet")
  self.pic_requestnum = self:getNode("pic_requestnum")
  self.requestnum = self:getNode("requestnum")
  self.m_Tenet = ""
  self.list_member:addTouchItemListenerListView(function(item, index, listObj)
    self:OnClickMemberListItem(item.m_UIViewParent)
  end)
  self.list_member:addLoadMoreListenerScrollView(handler(self, self.ShowNextListPart))
  self.list_member:setCanLoadMore(false)
  self.list_tenet:addTouchItemListenerListView(function(item, index, listObj)
    self:OnClickTenet()
  end)
  self.m_BpId = nil
  self.m_BpLevel = 1
  self.m_LoadNumEachTime = 15
  self.m_LastClickItem = nil
  self.m_LastClickItemCnt = 0
  for _, name in pairs({
    "txt_bpname",
    "txt_id",
    "txt_level",
    "txt_construct",
    "txt_leader",
    "txt_bpmoney",
    "txt_dailycost",
    "txt_num"
  }) do
    local obj = self:getNode(name)
    obj:setVisible(false)
    self[name] = obj
  end
  self.m_SortRecord = {}
  for index = 10, 14 do
    do
      local titleClickObj = self:getNode(string.format("titleclick_%d", index))
      if titleClickObj then
        self:click_check_withObj(titleClickObj, function()
          self:OnClickTitle(index)
        end, function(touchInside)
          self:OnTouchTitle(index, touchInside)
        end)
        self.m_SortRecord[index] = false
      end
    end
  end
  self:setRequestNum(0, true)
  self:InitMemberList()
  self:SetAttrTips()
  self:ListenMessage(MsgID_BP)
end
function CBpInfoPageBase:OnClickTitle(index)
  local d = self.m_SortRecord[index]
  if d == nil then
    return
  end
  local sortType = 0
  if index == 10 then
    sortType = 2
  elseif index == 11 then
    sortType = 1
  elseif index == 12 then
    sortType = 3
  else
    sortType = 0
  end
  local st, rflag = g_BpMgr:getBpMemberSortType()
  if st == sortType then
    d = not rflag
  end
  self.m_SortRecord[index] = d
  g_BpMgr:setBpMemerSortType(sortType, d)
  self:reloadMemberList()
end
function CBpInfoPageBase:reloadMemberList()
  self.list_member:removeAllItems()
  self:ShowNextListPart()
end
function CBpInfoPageBase:OnTouchTitle(index, touchInside)
  local titleObj = self:getNode(string.format("title_%d", index))
  if titleObj then
    if touchInside then
      titleObj:setScale(1.1)
    else
      titleObj:setScale(1)
    end
  end
end
function CBpInfoPageBase:SetAttrTips()
  for index = 0, 7 do
    local title = self:getNode(string.format("title_%d", index))
    local titlebg = self:getNode(string.format("infobg_%d", index))
    local descKey = string.format("bpdesc_%d", index)
    self:attrclick_check_withWidgetObj(title, descKey)
    self:attrclick_check_withWidgetObj(titlebg, descKey, title)
  end
end
function CBpInfoPageBase:OnMessage(msgSID, ...)
  if self.m_UINode == nil then
    return
  end
  local arg = {
    ...
  }
  if msgSID == MsgID_BP_Detail then
    local info = arg[1]
    self:SetBpBaseInfo(info)
  elseif msgSID == MsgID_BP_LocalInfo then
    if g_BpMgr then
      local bpName = g_BpMgr:getLocalBpName()
      self.txt_bpname:setText(bpName)
    end
  elseif msgSID == MsgID_BP_MemberList then
    self:ClearMemberList()
    self:ShowNextListPart()
  elseif msgSID == MsgID_BP_DeleteBpMember then
    self:DeleteBpMember(arg[1], true)
  elseif msgSID == MsgID_BP_RquestNum then
    self:setRequestNum(arg[1])
  elseif msgSID == MsgID_BP_AddNewMemberInfo then
    self:addBpMember(arg[1], arg[2], arg[3])
  elseif msgSID == MsgID_BP_ClearMemberList then
    self:ClearMemberList()
  elseif msgSID == MsgID_BP_ChangeMemberPos then
    self:ChangeMemberPos(arg[1], arg[2], arg[3], arg[4])
  elseif msgSID == MsgID_BP_NewBpJoinRequest then
    local newBpJoinFlag = g_BpMgr:getNewBpJoinRequest()
    if newBpJoinFlag then
      g_BpMgr:send_getBpRequestAmount()
    end
  end
end
function CBpInfoPageBase:resetDlg()
  for _, name in pairs({
    "txt_bpname",
    "txt_id",
    "txt_level",
    "txt_construct",
    "txt_leader",
    "txt_bpmoney",
    "txt_dailycost",
    "txt_num"
  }) do
    local obj = self[name]
    obj:setVisible(false)
  end
  self.list_member:removeAllItems()
  self.list_tenet:removeAllItems()
  self.m_Tenet = ""
end
function CBpInfoPageBase:SetBpBaseInfo(info)
  local bpId = info.i_bpid
  if bpId == nil then
    return
  end
  if self.m_BpId ~= nil and self.m_BpId ~= bpId then
    self:resetDlg()
  end
  self.m_BpId = bpId
  self.txt_id:setText(tostring(self.m_BpId))
  self.txt_id:setVisible(true)
  if info.s_bpname ~= nil then
    self.txt_bpname:setText(info.s_bpname)
    self.txt_bpname:setVisible(true)
  end
  if info.s_leader ~= nil then
    self.txt_leader:setText(info.s_leader)
    self.txt_leader:setVisible(true)
  end
  if info.i_bplevel ~= nil then
    self.m_BpLevel = info.i_bplevel
    self.txt_level:setText(tostring(self.m_BpLevel))
    self.txt_level:setVisible(true)
  end
  if info.i_construct ~= nil then
    local maxConstruct = data_getBangpaiConstructMaxNum(self.m_BpLevel)
    self.txt_construct:setText(string.format("%d/%d", info.i_construct, maxConstruct))
    self.txt_construct:setVisible(true)
    AutoLimitObjSize(self.txt_construct, 135)
  end
  if info.i_money ~= nil then
    self.txt_bpmoney:setText(tostring(info.i_money))
    self.txt_bpmoney:setVisible(true)
    AutoLimitObjSize(self.txt_bpmoney, 135)
  end
  if info.i_cost ~= nil then
    self.txt_dailycost:setText(string.format("%d/小时", info.i_cost))
    self.txt_dailycost:setVisible(true)
  end
  if info.i_num ~= nil then
    local maxNum = data_getBangpaiMemberMaxNum(self.m_BpLevel)
    self.txt_num:setText(string.format("%d/%d", info.i_num, maxNum))
    self.txt_num:setVisible(true)
  end
  if info.s_tenet ~= nil then
    self:setBpTenet(info.s_tenet)
  end
  if info.i_request ~= nil then
    self:setRequestNum(info.i_request)
  end
end
function CBpInfoPageBase:setBpTenet(tenet)
  self.m_Tenet = tenet
  self.list_tenet:removeAllItems()
  local size = self.list_tenet:getContentSize()
  local content = CRichText.new({
    width = size.width,
    color = ccc3(255, 255, 255),
    fontSize = 20
  })
  content:addRichText(tenet)
  local conSize = content:getRichTextSize()
  if conSize.height < size.height then
    local offy = size.height - conSize.height
    for lineNum, lineData in pairs(content.m_ObjList) do
      local lineObjList = lineData.objs or {}
      for _, obj in pairs(lineObjList) do
        local x, y = obj:getPosition()
        obj:setPosition(ccp(x, y + offy))
      end
    end
    content:ignoreContentAdaptWithSize(false)
    content:setSize(CCSize(conSize.width, size.height))
  end
  content:setTouchEnabled(true)
  self.list_tenet:pushBackCustomItem(content)
end
function CBpInfoPageBase:setRequestNum(num, init)
  self.requestnum:setText(tostring(num))
  self.pic_requestnum:setVisible(num > 0)
  if init ~= true and num <= 0 then
    g_BpMgr:NewBpJoinRequest(false)
  end
end
function CBpInfoPageBase:InitMemberList()
  if g_BpMgr:getHasBpListCache() then
    print("---->>>本地有帮派成员缓存时直接显示")
    self:ShowNextListPart()
  else
    print("---->>>本地没有帮派成员缓存时从服务器获取数据")
    g_BpMgr:send_getBpMemberInfo()
  end
end
function CBpInfoPageBase:ShowNextListPart()
  print("---->>>加载后一段数据")
  local cnt = 0
  local anyNew = false
  local n = self.list_member:getCount()
  if n > 0 then
    local tempItem = self.list_member:getItem(n - 1)
    tempItem = tempItem.m_UIViewParent
    cnt = tempItem:getIndex()
  end
  local memberList = g_BpMgr:getBpMemberList()
  for index = cnt + 1, cnt + self.m_LoadNumEachTime do
    local memberData = memberList[index]
    if memberData then
      local item = CBpMemberListItem.new(memberData, index, self)
      self.list_member:pushBackCustomItem(item.m_UINode)
      anyNew = true
    else
      break
    end
  end
  if not anyNew then
    self.list_member:setCanLoadMore(true)
    return
  end
  self.list_member:refreshView()
  self.list_member:setCanLoadMore(true)
end
function CBpInfoPageBase:DeleteBpMember(pid, reset)
  local cnt = self.list_member:getCount()
  for i = 0, cnt - 1 do
    local temp = self.list_member:getItem(i)
    local item = temp.m_UIViewParent
    if item:getPlayerId() == pid then
      self.list_member:removeItem(i)
      if reset ~= false then
        self:resetItemsFromIndex(i)
      end
      break
    end
  end
end
function CBpInfoPageBase:addBpMember(pid, info, index)
  local cnt = self.list_member:getCount()
  if index <= cnt then
    local item = CBpMemberListItem.new(info, index, self)
    self.list_member:insertCustomItem(item.m_UINode, index - 1)
    self:resetItemsFromIndex(index - 1)
  else
    if index == cnt + 1 then
      local item = CBpMemberListItem.new(info, index, self)
      self.list_member:pushBackCustomItem(item.m_UINode)
    else
    end
  end
end
function CBpInfoPageBase:ClearMemberList()
  self.list_member:removeAllItems()
end
function CBpInfoPageBase:ChangeMemberPos(pid, info, oldIdx, newIdx)
  print("---->>>ChangeMemberPos:", pid, info, oldIdx, newIdx)
  self:DeleteBpMember(pid, false)
  self:addBpMember(pid, info, newIdx)
  self:resetItemsFromIndex(0)
end
function CBpInfoPageBase:resetItemsFromIndex(index)
  if index < 0 then
    index = 0
  end
  local cnt = self.list_member:getCount()
  for i = index, cnt - 1 do
    local temp = self.list_member:getItem(i)
    local item = temp.m_UIViewParent
    item:setBgIndex(i + 1)
  end
end
function CBpInfoPageBase:OnClickMemberListItem(listItem)
  if self.m_LastClickItem ~= listItem then
    if self.m_LastClickItem then
      self.m_LastClickItem:setSelected(false)
    end
    self.m_LastClickItem = listItem
    self.m_LastClickItemCnt = 0
    self.m_LastClickItem:setSelected(true)
  end
  local pInfo = listItem:getPlayerInfo()
  if pInfo.pid == g_LocalPlayer:getPlayerId() then
    return
  end
  self.m_LastClickItemCnt = self.m_LastClickItemCnt + 1
  if self.m_LastClickItemCnt % 2 == 0 then
    return
  end
  local menu = CBpMemberMenu.new(pInfo)
  local wPos = listItem:getNameRightPos()
  local parent = menu:getParent()
  local pos = parent:convertToNodeSpace(ccp(wPos.x, wPos.y))
  local size = menu:getContentSize()
  menu:setPosition(ccp(pos.x + 20, pos.y - size.height / 2))
end
function CBpInfoPageBase:OnClickTenet()
  local bpPlace = g_BpMgr:getLocalBpPlace()
  local bpData = data_Org_Auth[bpPlace]
  if bpData and bpData.AuthEditOrPublishNotify == 1 then
    CBpTenetEdit.new(self.m_Tenet)
  end
end
function CBpInfoPageBase:OnBtn_Quit()
  if g_BpMgr:getLocalPlayerIsLeader() then
    local memberList = g_BpMgr:getBpMemberList()
    if memberList ~= nil and #memberList >= 2 then
      ShowNotifyTips("你贵为帮主不能随意脱离帮派,如你想移交帮主请到长安城帮派管理员处")
    else
      g_BpMgr:send_quitBangPai()
    end
  else
    local dlg = CPopWarning.new({
      title = "提示",
      text = "你确定要退出本帮派吗?",
      confirmFunc = function()
        g_BpMgr:send_quitBangPai()
      end,
      cancelText = "取消",
      confirmText = "确定"
    })
    dlg:ShowCloseBtn(false)
  end
end
function CBpInfoPageBase:OnBtn_Notice()
  CBpNotice.new()
end
function CBpInfoPageBase:OnBtn_Contribute()
  CBpContribute.new()
end
function CBpInfoPageBase:OnBtn_RequestList()
  CBpRequestList.new()
end
function CBpInfoPageBase:OnBtn_ReName()
  if g_BpMgr and g_BpMgr:getLocalPlayerIsLeader() then
    getCurSceneView():addSubView({
      subView = CBpReName.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    ShowNotifyTips("只有帮主才可以修改帮派名称")
  end
end
function CBpInfoPageBase:ClearSeleted()
  if self.m_LastClickItem then
    self.m_LastClickItem:setSelected(false)
    self.m_LastClickItem = nil
  end
end
function CBpInfoPageBase:OnItemRemoved(item)
  if self.m_LastClickItem and self.m_LastClickItem == item then
    self.m_LastClickItem = nil
  end
end
function CBpInfoPageBase:Clear()
  self.m_LastClickItem = nil
  g_BpMgr:setBpMemerSortType(0, false)
end
CBpMemberListItem = class("CBpMemberListItem", CcsSubView)
function CBpMemberListItem:ctor(memberData, index, bpDlg)
  CBpMemberListItem.super.ctor(self, "views/bpmemberitem.json")
  if g_LocalPlayer and memberData.pid == g_LocalPlayer:getPlayerId() then
    local mainHero = g_LocalPlayer:getMainHero()
    memberData.sid = mainHero:getTypeId()
    memberData.name = mainHero:getProperty(PROPERTY_NAME)
    memberData.zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
    memberData.lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
    memberData.jid = g_BpMgr:getLocalBpPlace()
    memberData.c = g_BpMgr:getLocalBpConstruct()
    memberData.tc = g_BpMgr:getLocalBpTotalConstruct()
    memberData.st = -1
  end
  self.m_PlayerInfo = memberData
  self.m_BpDlg = bpDlg
  local size = self:getContentSize()
  self.m_Bg_Even = display.newScale9Sprite("views/common/bg/bg1062.png", 4, 4, CCSize(10, 10))
  self.m_Bg_Even:setAnchorPoint(ccp(0, 0))
  self.m_Bg_Even:setContentSize(CCSize(size.width, size.height))
  self:addNode(self.m_Bg_Even, 0)
  self.m_Bg_Even:setPosition(ccp(0, 0))
  self.m_Bg_Odd = display.newScale9Sprite("views/common/bg/bg1063.png", 4, 4, CCSize(10, 10))
  self.m_Bg_Odd:setAnchorPoint(ccp(0, 0))
  self.m_Bg_Odd:setContentSize(CCSize(size.width, size.height))
  self:addNode(self.m_Bg_Odd, 0)
  self.m_Bg_Odd:setPosition(ccp(0, 0))
  self.m_Index = index
  self:setBgIndex(index)
  local lTypeId = memberData.sid
  self:createHead(lTypeId)
  self:getNode("txt_name"):setText(memberData.name)
  AutoLimitObjSize(self:getNode("txt_name"), 108)
  memberData.zs = memberData.zs or 0
  memberData.lv = memberData.lv or 0
  self:getNode("txt_level"):setText(string.format("%d转%d级", memberData.zs, memberData.lv))
  local place = memberData.jid
  self:getNode("txt_place"):setText(data_getBangpaiPlaceName(place))
  self:setPvpRank(memberData.c, memberData.tc)
  self:SetStatus(memberData.st)
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_Friends)
  self:ListenMessage(MsgID_MapScene)
end
function CBpMemberListItem:createHead(lTypeId)
  if self.m_Head ~= nil then
    if self.m_Head._lTypeId == lTypeId then
      return
    else
      self.m_Head:removeFromParent()
      self.m_Head = nil
    end
  end
  local head = createWidgetFrameHeadIconByRoleTypeID(lTypeId)
  self:addChild(head, 1)
  head:setScale(0.35)
  head:setPosition(ccp(30, 22))
  self.m_Head = head
  self.m_Head._lTypeId = lTypeId
end
function CBpMemberListItem:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_BP_UpdateMemberInfo then
    local pid = arg[1]
    if pid == self.m_PlayerInfo.pid then
      local info = arg[2]
      if info.jid ~= nil then
        self.m_PlayerInfo.jid = info.jid
        self:getNode("txt_place"):setText(data_getBangpaiPlaceName(info.jid))
      end
      if info.st ~= nil then
        self.m_PlayerInfo.st = info.st
        self:SetStatus(info.st)
      end
      if info.name ~= nil then
        self:getNode("txt_name"):setText(info.name)
      end
      if info.c ~= nil or info.tc ~= nil then
        self:setPvpRank(info.c, info.tc)
      end
      if info.sid ~= nil then
        self:createHead(info.sid)
      end
      if info.lv ~= nil or info.zs ~= nil then
        if info.lv ~= nil then
          self.m_PlayerInfo.lv = info.lv
        end
        if info.zs ~= nil then
          self.m_PlayerInfo.zs = info.zs
        end
        self:getNode("txt_level"):setText(string.format("%d转%d级", self.m_PlayerInfo.zs, self.m_PlayerInfo.lv))
      end
    end
  elseif msgSID == MsgID_BP_LocalInfo and self.m_PlayerInfo.pid == g_LocalPlayer:getPlayerId() then
    local info = arg[1]
    if info.i_place ~= nil then
      self.m_PlayerInfo.jid = info.i_place
      self:getNode("txt_place"):setText(data_getBangpaiPlaceName(info.i_place))
    end
    if info.c ~= nil or info.tc ~= nil then
      self:setPvpRank(info.c, info.tc)
    end
  end
end
function CBpMemberListItem:getIndex()
  return self.m_Index
end
function CBpMemberListItem:setBgIndex(index)
  self.m_Index = index
  local temp = index % 2 == 0
  self.m_Bg_Even:setVisible(temp)
  self.m_Bg_Odd:setVisible(not temp)
end
function CBpMemberListItem:SetStatus(st)
  local txt_status = self:getNode("txt_status")
  if st < 0 then
    txt_status:setText("在线")
    txt_status:setColor(ccc3(136, 77, 1))
  else
    local curTime = g_DataMgr:getServerTime()
    local offTime = math.floor(curTime - st)
    if offTime < 1800 then
      txt_status:setText("离线<30分钟")
    elseif offTime < 3600 then
      txt_status:setText("离线<1小时")
    elseif offTime < 86400 then
      local h = math.floor(offTime / 3600)
      txt_status:setText(string.format("离线%d小时", h))
    elseif offTime < 2678400 then
      local d = math.floor(offTime / 86400)
      txt_status:setText(string.format("离线%d天", d))
    else
      txt_status:setText("离线>30天")
    end
    txt_status:setColor(ccc3(225, 224, 224))
  end
end
function CBpMemberListItem:getPlayerId()
  return self.m_PlayerInfo.pid
end
function CBpMemberListItem:getPlayerInfo()
  return self.m_PlayerInfo
end
function CBpMemberListItem:setPvpRank(c, tc)
  if c ~= nil then
    self.m_PlayerInfo.c = c
  end
  if tc ~= nil then
    self.m_PlayerInfo.tc = tc
  end
  self:getNode("txt_pvp"):setText(string.format("%d/%d", self.m_PlayerInfo.c, self.m_PlayerInfo.tc))
  AutoLimitObjSize(self:getNode("txt_pvp"), 65)
end
function CBpMemberListItem:getNameRightPos()
  local obj = self:getNode("txt_name")
  local parent = obj:getParent()
  local x, y = obj:getPosition()
  local size = obj:getContentSize()
  return parent:convertToWorldSpace(ccp(x + size.width / 2, y))
end
function CBpMemberListItem:setSelected(iSel)
  if iSel then
    if self.m_SelectedBg == nil then
      self.m_SelectedBg = display.newScale9Sprite("views/common/bg/bg1064.png", 4, 4, CCSize(10, 10))
      self.m_SelectedBg:setAnchorPoint(ccp(0, 0))
      local size = self:getContentSize()
      self.m_SelectedBg:setContentSize(CCSize(size.width, size.height))
      self:addNode(self.m_SelectedBg, 0)
      self.m_SelectedBg:setPosition(ccp(0, 0))
    end
    self.m_SelectedBg:setVisible(true)
    self:setAllTextColor(255, 245, 121)
  else
    if self.m_SelectedBg then
      self.m_SelectedBg:setVisible(false)
    end
    self:setAllTextColor(136, 77, 1)
  end
end
function CBpMemberListItem:setAllTextColor(r, g, b)
  self:getNode("txt_name"):setColor(ccc3(r, g, b))
  self:getNode("txt_level"):setColor(ccc3(r, g, b))
  self:getNode("txt_place"):setColor(ccc3(r, g, b))
  self:getNode("txt_pvp"):setColor(ccc3(r, g, b))
  if self.m_PlayerInfo.st == 1 then
    self:getNode("txt_status"):setColor(ccc3(r, g, b))
  end
end
function CBpMemberListItem:Clear()
  if self.m_BpDlg then
    self.m_BpDlg:OnItemRemoved(self)
    self.m_BpDlg = nil
  end
end
CBpReName = class("CBpReName", CcsSubView)
function CBpReName:ctor()
  CBpReName.super.ctor(self, "views/bangpai_rename.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_NameInput = self:getNode("input_box")
  local size = self.m_NameInput:getContentSize()
  TextFieldEmoteExtend.extend(self.m_NameInput, nil, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
  self.m_NameInput:SetFieldText("")
  self.m_CharNumMinLimit = MinLengthOfName
  self.m_CharNumMaxLimit = MaxLengthOfName
  self.m_NameInput:setMaxLength(self.m_CharNumMaxLimit)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CBpReName:OnMessage(msgSID, ...)
  if msgSID == MsgID_HeroUpdate then
    local arg = {
      ...
    }
    local d = arg[1]
    if d.pid == g_LocalPlayer:getPlayerId() and d.pro ~= nil and d.pro[PROPERTY_BPNAME] ~= nil then
      self:CloseSelf()
    end
  end
end
function CBpReName:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CBpReName:OnBtn_Cancel(obj, t)
  self:CloseSelf()
end
function CBpReName:OnBtn_Confirm(obj, t)
  local text = self.m_NameInput:GetFieldText()
  if string.len(text) < self.m_CharNumMinLimit then
    ShowNotifyTips(string.format("名字不能少于%d个字", self.m_CharNumMinLimit))
  else
    if string.find(text, " ") ~= nil then
      ShowNotifyTips("名字不能包含空格")
      return
    end
    if string.find(text, "#") ~= nil then
      ShowNotifyTips("名字不能包含#")
      return
    end
    if checkText_DFAFilter(text) then
      local mainHeroId = g_LocalPlayer:getMainHeroId()
      if mainHeroId ~= nil then
        netsend.netbangpai.changeBpName(text)
      else
        print("改名时主英雄不存在?!")
        self:CloseSelf()
      end
    else
      ShowNotifyTips("名字不合法")
    end
  end
end
function CBpReName:Clear()
  self.m_NameInput:CloseTheKeyBoard()
  self.m_NameInput:ClearTextFieldExtend()
end
