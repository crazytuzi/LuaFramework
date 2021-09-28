g_CBpJoinCreateHandler = nil
CBpJoinCreate = class("CBpJoinCreate", CcsSubView)
function CBpJoinCreate:ctor()
  CBpJoinCreate.super.ctor(self, "views/bpcreatejoin.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_onekey = {
      listener = handler(self, self.OnBtn_OneKey),
      variName = "btn_onekey"
    },
    btn_createbp = {
      listener = handler(self, self.OnBtn_CreateBangPai),
      variName = "btn_createbp"
    },
    btn_emote = {
      listener = handler(self, self.OnBtn_Emote),
      variName = "btn_emote"
    },
    btn_join = {
      listener = handler(self, self.On_JoinPage),
      variName = "btn_join"
    },
    btn_create = {
      listener = handler(self, self.OnBtn_CreatePage),
      variName = "btn_create"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_join:setTitleText("加\n入\n帮\n派")
  self.btn_create:setTitleText("创\n建\n帮\n派")
  local size = self.btn_join:getContentSize()
  self:adjustClickSize(self.btn_join, size.width + 30, size.height, true)
  local size = self.btn_create:getContentSize()
  self:adjustClickSize(self.btn_create, size.width + 30, size.height, true)
  self:addBtnSigleSelectGroup({
    {
      self.btn_join,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_create,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    }
  })
  self.layer_join = self:getNode("layer_join")
  self.layer_create = self:getNode("layer_create")
  self.list_bp = self:getNode("list_bp")
  self.list_tenet = self:getNode("list_tenet")
  self.tt_tip = self:getNode("tt_tip")
  self.txt_cnt = self:getNode("txt_cnt")
  self.list_bp:addLoadMoreListenerScrollView(function()
    self:ShowNextListPart()
  end)
  self.list_bp:addTouchItemListenerListView(function(item, index, listObj)
    self:OnClickBpListItem(item.m_UIViewParent)
  end)
  self.layer_join:setVisible(true)
  self.layer_create:setVisible(true)
  self.m_NameInput = self:getNode("input_name")
  local size = self.m_NameInput:getContentSize()
  TextFieldEmoteExtend.extend(self.m_NameInput, self.m_UINode, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
  self.m_NameInput:SetFieldText("")
  self.m_NameInput:SetFiledPlaceHolder("请输入帮派名称", {
    color = ccc3(206, 187, 151)
  })
  self.m_NameCharNumMaxLimit = 5
  self.m_NameInput:setMaxLengthEnabled(true)
  self.m_NameInput:setMaxLength(self.m_NameCharNumMaxLimit)
  self.m_TenetInput = self:getNode("input_tenet")
  local size = self.m_TenetInput:getContentSize()
  TextFieldEmoteExtend.extend(self.m_TenetInput, self.m_UINode, {
    width = size.width,
    align = CRichText_AlignType_Left
  })
  self.m_TenetInput:SetFieldText("")
  self.m_TenetInput:SetFiledPlaceHolder("请输入帮派宗旨", {
    color = ccc3(206, 187, 151)
  })
  self.m_TenetCharNumMaxLimit = 50
  self.m_TenetInput:setMaxLengthEnabled(false)
  self.m_TenetInput:SetMaxInputLength(self.m_TenetCharNumMaxLimit)
  self.m_TenetInput:SetEnableMulti(true)
  self.m_TenetInput:SetKeyBoardListener(handler(self, self.onKeyBoardListener))
  self.iconcost = self:getNode("iconcost")
  self.iconcost:setVisible(false)
  self.iconcost:setTouchEnabled(false)
  local x, y = self.iconcost:getPosition()
  local size = self.iconcost:getContentSize()
  local z = self.iconcost:getZOrder()
  local p = self.iconcost:getParent()
  local resIcon = display.newSprite(data_getResPathByResID(RESTYPE_GOLD))
  resIcon:setAnchorPoint(ccp(0.5, 0.5))
  resIcon:setScale(size.width / resIcon:getContentSize().width)
  resIcon:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  p:addNode(resIcon, z)
  self.m_CreateCost = data_Variables.BE_createbp
  self.tt_cost = self:getNode("tt_cost")
  self.tt_cost:setText(tostring(math.floor(self.m_CreateCost)))
  self.m_SelectedBp = nil
  self.m_BpTenetData = {}
  self.m_BpNum = -1
  self:InitBpList()
  self:caculateCharNum()
  self:On_JoinPage()
  self:SetAttrTips()
  self:ListenMessage(MsgID_BP)
  if g_CBpJoinCreateHandler then
    g_CBpJoinCreateHandler:CloseSelf()
    g_CBpJoinCreateHandler = nil
  end
  g_CBpJoinCreateHandler = self
end
function CBpJoinCreate:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("costbg"), "resgold")
end
function CBpJoinCreate:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_BP_BpList then
    local bpList = arg[1]
    self:SetBangPaiList(bpList)
  elseif msgSID == MsgID_BP_Tenet then
    local bpId = arg[1]
    local tenet = arg[2]
    self.m_BpTenetData[bpId] = tenet
    if self.m_SelectedBp and self.m_SelectedBp:getBpId() == bpId then
      self:SetBangPaiTenet(tenet)
    end
  elseif msgSID == MsgID_BP_Num then
    self.m_BpNum = arg[1]
    self.tt_tip:setVisible(self.m_BpNum >= 50)
  elseif msgSID == MsgID_BP_LocalInfo and g_BpMgr:localPlayerHasBangPai() then
    self:OnBtn_Close()
    ShowBangPaiDlg()
  end
end
function CBpJoinCreate:onKeyBoardListener(event)
  if event == TEXTFIELDEXTEND_EVENT_TEXT_CHANGE then
    self:caculateCharNum()
  end
end
function CBpJoinCreate:caculateCharNum()
  local textLen = self.m_TenetInput:GetInputLength()
  self.txt_cnt:setText(string.format("还可以输入%d个字", math.max(self.m_TenetCharNumMaxLimit - textLen, 0)))
end
function CBpJoinCreate:TempHide()
  self:setVisible(false)
  local x, y = self:getPosition()
  self.__InitPos = ccp(x, y)
  self:setPosition(ccp(-999999, -999999))
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
    self._auto_create_opacity_bg_ins:setTouchEnabled(false)
  end
  self.__IsHide = true
end
function CBpJoinCreate:ShowAgain()
  if self.__IsHide == true then
    self:setVisible(true)
    local pos = self.__InitPos or ccp(0, 0)
    self:setPosition(pos)
    if self._auto_create_opacity_bg_ins then
      self._auto_create_opacity_bg_ins:setVisible(true)
      self._auto_create_opacity_bg_ins:setTouchEnabled(true)
    end
    self.__IsHide = false
  end
end
function CBpJoinCreate:InitBpList()
  self.m_LastListBpId = 0
  self.m_DataDict = {}
  self:ShowNextListPart()
end
function CBpJoinCreate:ShowNextListPart()
  g_BpMgr:send_getTotalBpListInfo(self.m_LastListBpId)
end
function CBpJoinCreate:SetBangPaiList(bpList)
  if self.__IsHide == true then
    self:ShowAgain()
    if #bpList <= 0 then
      self:OnBtn_CreatePage()
      return
    end
  end
  local cnt = self.list_bp:getCount()
  for index, bpData in pairs(bpList) do
    if self.m_DataDict[bpData.i_bpid] == nil then
      local item = CBpJoinListItem.new(bpData, cnt + index)
      self.list_bp:pushBackCustomItem(item.m_UINode)
      self.m_DataDict[bpData.i_bpid] = true
      self.m_LastListBpId = bpData.i_bpid
    end
  end
  self.list_bp:refreshView()
  self.list_bp:setCanLoadMore(true)
end
function CBpJoinCreate:SetBangPaiTenet(tenet)
  self.list_tenet:removeAllItems()
  local size = self.list_tenet:getContentSize()
  local content = CRichText.new({
    width = size.width,
    color = ccc3(255, 255, 255),
    fontSize = 20
  })
  content:addRichText(tenet)
  self.list_tenet:pushBackCustomItem(content)
end
function CBpJoinCreate:OnClickBpListItem(listItem)
  if self.m_SelectedBp then
    self.m_SelectedBp:setSelected(false)
  end
  self.m_SelectedBp = listItem
  self.m_SelectedBp:setSelected(true)
  local bpId = self.m_SelectedBp:getBpId()
  local tenet = self.m_BpTenetData[bpId]
  if tenet ~= nil then
    self:SetBangPaiTenet(tenet)
  else
    self.list_tenet:removeAllItems()
    g_BpMgr:send_getBpTenet(bpId)
  end
end
function CBpJoinCreate:OnBtn_Close()
  self:CloseSelf()
end
function CBpJoinCreate:OnBtn_OneKey()
  g_BpMgr:send_requestJoinAllBp()
end
function CBpJoinCreate:On_JoinPage()
  self.layer_join:setEnabled(true)
  self.layer_create:setEnabled(false)
  self:setGroupBtnSelected(self.btn_join)
end
function CBpJoinCreate:OnBtn_CreatePage()
  self.layer_join:setEnabled(false)
  self.layer_create:setEnabled(true)
  if self.m_BpNum < 0 then
    g_BpMgr:send_requestTotalBpAmount()
  end
  self.tt_tip:setVisible(self.m_BpNum >= 50)
  self:setGroupBtnSelected(self.btn_create)
end
function CBpJoinCreate:OnBtn_CreateBangPai()
  local bpName = self.m_NameInput:GetFieldText()
  if GetMyUTF8Len(bpName) <= 0 then
    ShowNotifyTips("请输入帮派名称")
    return
  end
  local bpTenet = self.m_TenetInput:GetFieldText()
  if GetMyUTF8Len(bpTenet) <= 0 then
    ShowNotifyTips("请输入帮派宗旨")
    return
  end
  if string.find(bpName, " ") ~= nil then
    ShowNotifyTips("帮派名字不能包含空格")
    return
  end
  if not checkText_DFAFilter(bpName) then
    ShowNotifyTips("帮派名字不合法")
    return
  end
  if not checkText_DFAFilter(bpTenet) then
    ShowNotifyTips("帮派宗旨内容包含敏感字符")
    return
  end
  g_BpMgr:send_createNewBp(bpName, bpTenet)
end
function CBpJoinCreate:OnBtn_Emote()
  local param = {showEmoteOnly = true}
  self.m_TenetInput:openInsertBoard(param)
end
function CBpJoinCreate:Clear()
  self.m_NameInput:CloseTheKeyBoard()
  self.m_TenetInput:CloseTheKeyBoard()
  self.m_NameInput:ClearTextFieldExtend()
  self.m_TenetInput:ClearTextFieldExtend()
  if g_CBpJoinCreateHandler == self then
    g_CBpJoinCreateHandler = nil
  end
  self.m_SelectedBp = nil
end
CBpJoinListItem = class("CBpJoinListItem", CcsSubView)
function CBpJoinListItem:ctor(bpData, index)
  CBpJoinListItem.super.ctor(self, "views/bpjoinlistitem.json")
  local btnBatchListener = {
    btn_join = {
      listener = handler(self, self.OnBtn_Join),
      variName = "btn_join"
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
  bg:setPosition(ccp(0, 0))
  self.m_BpId = bpData.i_bpid
  self:getNode("txt_id"):setText(tostring(self.m_BpId))
  self:getNode("txt_bpname"):setText(bpData.s_bpname)
  self:getNode("txt_leadername"):setText(bpData.s_leader)
  self.m_Num = bpData.i_num
  local bplevel = bpData.i_bplevel
  self.m_MaxNum = data_getBangpaiMemberMaxNum(bplevel)
  self:getNode("txt_num"):setText(string.format("%d/%d", self.m_Num, self.m_MaxNum))
  self:getNode("txt_level"):setText(tostring(bplevel))
end
function CBpJoinListItem:getBpId()
  return self.m_BpId
end
function CBpJoinListItem:OnBtn_Join()
  if self.m_Num >= self.m_MaxNum then
    ShowNotifyTips("该帮派人数已满，请申请加入其它的帮派")
    return
  end
  g_BpMgr:send_requestJoinBp(self.m_BpId)
end
function CBpJoinListItem:OnTouchJoin(check)
  if check then
    self.txt_join:setScale(1.1)
  else
    self.txt_join:setScale(1)
  end
end
function CBpJoinListItem:setSelected(iSel)
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
function CBpJoinListItem:setAllTextColor(r, g, b)
  self:getNode("txt_id"):setColor(ccc3(r, g, b))
  self:getNode("txt_bpname"):setColor(ccc3(r, g, b))
  self:getNode("txt_leadername"):setColor(ccc3(r, g, b))
  self:getNode("txt_num"):setColor(ccc3(r, g, b))
  self:getNode("txt_level"):setColor(ccc3(r, g, b))
end
function CBpJoinListItem:Clear()
end
