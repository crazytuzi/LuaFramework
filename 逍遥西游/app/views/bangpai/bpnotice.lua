CBpNotice = class("CBpNotice", CcsSubView)
function CBpNotice:ctor()
  CBpNotice.super.ctor(self, "views/bpnotice.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_edit = {
      listener = handler(self, self.OnBtn_Edit),
      variName = "btn_edit"
    },
    btn_publish = {
      listener = handler(self, self.OnBtn_Publish),
      variName = "btn_publish"
    },
    btn_complete = {
      listener = handler(self, self.OnBtn_Complete),
      variName = "btn_complete"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.list_content = self:getNode("list_content")
  self.m_NoticeItems = {}
  self.m_IsEditing = false
  self.m_IsEditEnabled = true
  self.m_MaxNoticeNum = 3
  self:setEditMode(false)
  self:ListenMessage(MsgID_BP)
  self.list_content:addTouchItemListenerListView(function(item, index, listObj)
    if self.m_IsEditing then
      local act1 = CCDelayTime:create(0.05)
      local act2 = CCCallFunc:create(function()
        if self.m_IsEditEnabled then
          local itemObj = item.m_UIViewParent
          local noticId = itemObj:getNoticeId()
          local noticeContent = itemObj:getNoticeContent()
          self:setDlgShow(false)
          CBpNoticeEdit.new(noticId, noticeContent, handler(self, self.editComplete), handler(self, self.editCancel), handler(self, self.OnBtn_Close))
        end
      end)
      self:runAction(transition.sequence({act1, act2}))
    end
  end)
  g_BpMgr:send_getAllBpNotice()
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CBpNotice:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_BpDlgIsInvalid then
    self:CloseSelf()
  elseif msgSID == MsgID_BP_Notice then
    local arg = {
      ...
    }
    local noticeList = arg[1]
    self:SetNoticeList(noticeList)
  elseif msgSID == MsgID_BP_DeleteNotice then
    local arg = {
      ...
    }
    local noticeId = arg[1]
    self:DeleteBpNotice(noticeId)
  end
end
function CBpNotice:SetNoticeList(noticeList)
  local _noticeSortFunc = function(a, b)
    if a == nil or b == nil then
      return false
    end
    if a.i_time ~= b.i_time then
      return a.i_time < b.i_time
    else
      return a.i_id < b.i_id
    end
  end
  table.sort(noticeList, _noticeSortFunc)
  for _, data in ipairs(noticeList) do
    local noticeId = data.i_id
    local oldItem = self.m_NoticeItems[noticeId]
    if oldItem ~= nil then
      if data.s_msg == nil then
        data.s_msg = oldItem:getNoticeContent()
      end
      self:DeleteBpNotice(noticeId)
    end
    local item = CBpNoticeItem.new(data, self)
    self.list_content:insertCustomItem(item.m_UINode, 0)
    self.m_NoticeItems[noticeId] = item
  end
  self.list_content:refreshView()
  self.list_content:jumpToTop()
  self:setEditMode(self.m_IsEditing)
end
function CBpNotice:DeleteBpNotice(noticeId)
  local cnt = self.list_content:getCount()
  for i = 0, cnt - 1 do
    local temp = self.list_content:getItem(i)
    local item = temp.m_UIViewParent
    if item:getNoticeId() == noticeId then
      self.list_content:removeItem(i)
      break
    end
  end
  self.m_NoticeItems[noticeId] = nil
end
function CBpNotice:OnBtn_Edit()
  local place = g_BpMgr:getLocalBpPlace()
  local bpData = data_Org_Auth[place]
  if bpData and bpData.AuthEditOrPublishNotify == 1 then
    local cnt = self.list_content:getCount()
    if cnt > 0 then
      self:setEditMode(true)
    else
      ShowNotifyTips("没有可编辑的公告")
    end
  else
    ShowNotifyTips("只有帮主和副帮主可以编辑公告")
  end
end
function CBpNotice:OnBtn_Publish()
  local place = g_BpMgr:getLocalBpPlace()
  local bpData = data_Org_Auth[place]
  if bpData and bpData.AuthEditOrPublishNotify == 1 then
    local cnt = self.list_content:getCount()
    if cnt >= self.m_MaxNoticeNum then
      ShowNotifyTips(string.format("最多只能发布%d条公告", self.m_MaxNoticeNum))
    else
      self:setDlgShow(false)
      CBpNoticeEdit.new(0, "", handler(self, self.editComplete), handler(self, self.editCancel), handler(self, self.OnBtn_Close))
    end
  else
    ShowNotifyTips("只有帮主和副帮主可以发布公告")
  end
end
function CBpNotice:OnBtn_Complete()
  self:setEditMode(false)
end
function CBpNotice:setEditMode(isEdit)
  self.m_IsEditing = isEdit
  self.btn_complete:setVisible(self.m_IsEditing)
  self.btn_complete:setTouchEnabled(self.m_IsEditing)
  self.btn_edit:setVisible(not self.m_IsEditing)
  self.btn_edit:setTouchEnabled(not self.m_IsEditing)
  self.btn_publish:setVisible(not self.m_IsEditing)
  self.btn_publish:setTouchEnabled(not self.m_IsEditing)
  for _, item in pairs(self.m_NoticeItems) do
    item:setEditMode(isEdit)
  end
end
function CBpNotice:OnBtn_Close()
  self:CloseSelf()
end
function CBpNotice:editComplete(noticeId, notice)
  local item = self.m_NoticeItems[noticeId]
  if item then
    item:setNoticeContent(notice)
  end
  self:setDlgShow(true)
  self:setEditMode(false)
end
function CBpNotice:editCancel()
  self:setDlgShow(true)
end
function CBpNotice:setIsEditEnabled(flag)
  self.m_IsEditEnabled = flag
end
function CBpNotice:setDlgShow(iShow)
  self:setEnabled(iShow)
  self._auto_create_opacity_bg_ins:setEnabled(iShow)
end
function CBpNotice:Clear()
end
CBpNoticeItem = class("CBpNoticeItem", CcsSubView)
function CBpNoticeItem:ctor(data, parentDlg)
  CBpNoticeItem.super.ctor(self, "views/bpnoticeitem.json")
  local btnBatchListener = {
    btn_delete = {
      listener = handler(self, self.OnBtn_Delete),
      variName = "btn_delete"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.bg = self:getNode("bg")
  self.txt_time = self:getNode("txt_time")
  self.txt_name = self:getNode("txt_name")
  self.txt_place = self:getNode("txt_place")
  self.poscontent = self:getNode("poscontent")
  self.btn_delete:setTouchEnabled(false)
  self.m_ParentDlg = parentDlg
  self.m_NoticeId = data.i_id
  self.m_InitSize = self.m_UINode:getSize()
  self.m_InitBgSize = self.bg:getSize()
  self.m_NoticeContent = ""
  self.m_NoticeTime = 0
  self.poscontent:setVisible(false)
  local parent = self.poscontent:getParent()
  local size = self.poscontent:getContentSize()
  self.m_NoticeBox = CRichText.new({
    width = size.width,
    color = ccc3(255, 255, 255),
    fontSize = 20
  })
  parent:addChild(self.m_NoticeBox)
  self:SetData(data)
end
function CBpNoticeItem:SetData(data)
  if data.i_time ~= nil then
    self.m_NoticeTime = data.i_time
    self.txt_time:setText(os.date("%Y-%m-%d", data.i_time))
  end
  if data.s_name ~= nil then
    self.txt_name:setText(data.s_name)
  end
  if data.i_jobid ~= nil then
    self.txt_place:setText(data_getBangpaiPlaceName(data.i_jobid))
  end
  if data.s_msg ~= nil then
    self:setNoticeContent(data.s_msg)
  end
  local x, y = self.txt_name:getPosition()
  local size = self.txt_name:getContentSize()
  self.txt_place:setPosition(ccp(x - size.width - 10, y))
end
function CBpNoticeItem:setNoticeContent(notice)
  self.m_NoticeContent = notice
  self.m_NoticeBox:clearAll()
  self.m_NoticeBox:addRichText(notice)
  local boxSize = self.m_NoticeBox:getRichTextSize()
  local posSize = self.poscontent:getContentSize()
  local x, y = self.poscontent:getPosition()
  if boxSize.height <= posSize.height then
    self.m_NoticeBox:setPosition(ccp(x, y + posSize.height - boxSize.height))
    self.bg:setSize(CCSize(self.m_InitBgSize.width, self.m_InitBgSize.height))
    self.m_UINode:ignoreContentAdaptWithSize(false)
    self.m_UINode:setSize(CCSize(self.m_InitSize.width, self.m_InitSize.height))
  else
    self.m_NoticeBox:setPosition(ccp(x, y))
    self.bg:setSize(CCSize(self.m_InitBgSize.width, self.m_InitBgSize.height + boxSize.height - posSize.height))
    self.m_UINode:ignoreContentAdaptWithSize(false)
    self.m_UINode:setSize(CCSize(self.m_InitSize.width, self.m_InitSize.height + boxSize.height - posSize.height))
  end
  local x, _ = self.btn_delete:getPosition()
  local size = self.m_UINode:getSize()
  self.btn_delete:setPosition(ccp(x, size.height * 0.5))
end
function CBpNoticeItem:setEditMode(isEdit)
  self.btn_delete:setTouchEnabled(isEdit)
  self.btn_delete:stopAllActions()
  if isEdit then
    local x, y = self.btn_delete:getPosition()
    self.btn_delete:runAction(CCMoveTo:create(0.15, ccp(30, y)))
  else
    local x, y = self.btn_delete:getPosition()
    self.btn_delete:runAction(CCMoveTo:create(0.1, ccp(-30, y)))
  end
end
function CBpNoticeItem:getNoticeId()
  return self.m_NoticeId
end
function CBpNoticeItem:getNoticeContent()
  return self.m_NoticeContent
end
function CBpNoticeItem:getNoticeTime()
  return self.m_NoticeTime
end
function CBpNoticeItem:OnBtn_Delete()
  local dlg = CPopWarning.new({
    title = "提示",
    text = "你确定要删除此公告吗?",
    confirmFunc = handler(self, self.deleteNotice),
    clearFunc = handler(self, self.clearPopWarning),
    cancelText = "取消",
    confirmText = "确定"
  })
  dlg:ShowCloseBtn(false)
  self.m_ParentDlg:setIsEditEnabled(false)
end
function CBpNoticeItem:deleteNotice()
  g_BpMgr:send_deleteBpNotice(self.m_NoticeId)
end
function CBpNoticeItem:clearPopWarning()
  self.m_ParentDlg:setIsEditEnabled(true)
end
function CBpNoticeItem:UpdateData(data)
  self:SetData(data)
end
function CBpNoticeItem:Clear()
  self.m_ParentDlg = nil
end
CBpEditBase = class("CBpEditBase", CcsSubView)
function CBpEditBase:ctor(initNotice, okListener, cancelListener, closeListener)
  CBpEditBase.super.ctor(self, "views/bpnoticeedit.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    },
    btn_publish = {
      listener = handler(self, self.OnBtn_Publish),
      variName = "btn_publish"
    },
    btn_emote = {
      listener = handler(self, self.OnBtn_Emote),
      variName = "btn_emote"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_OkListener = okListener
  self.m_CancelListener = cancelListener
  self.m_CloseListener = closeListener
  self.input_box = self:getNode("input_box")
  self.txt_cnt = self:getNode("txt_cnt")
  self.input_box:setTouchEnabled(false)
  self.m_MaxInputNum = 50
  local size = self.input_box:getContentSize()
  TextFieldEmoteExtend.extend(self.input_box, self.m_UINode, {
    width = size.width,
    align = CRichText_AlignType_Left
  })
  self.input_box:setMaxLengthEnabled(false)
  self.input_box:SetMaxInputLength(self.m_MaxInputNum)
  self.input_box:SetKeyBoardListener(handler(self, self.onKeyBoardListener))
  self.input_box:SetFieldText(initNotice)
  self.input_box:SetEnableMulti(true)
  self:caculateCharNum()
  self:ListenMessage(MsgID_BP)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CBpEditBase:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_BpDlgIsInvalid then
    self:OnBtn_Close()
  end
end
function CBpEditBase:onEnterEvent()
  local act1 = CCDelayTime:create(0.1)
  local act2 = CCCallFunc:create(function()
    self.input_box:openKeyBoard()
    self.input_box:setTouchEnabled(true)
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CBpEditBase:onKeyBoardListener(event)
  if event == TEXTFIELDEXTEND_EVENT_TEXT_CHANGE then
    self:caculateCharNum()
  end
end
function CBpEditBase:caculateCharNum()
  local textLen = self.input_box:GetInputLength()
  self.txt_cnt:setText(string.format("还可以输入%d个字", math.max(self.m_MaxInputNum - textLen, 0)))
end
function CBpEditBase:OnBtn_Publish()
end
function CBpEditBase:OnBtn_Cancel()
  if self.m_CancelListener then
    self.m_CancelListener()
    self:ClearListeners()
  end
  self:CloseSelf()
end
function CBpEditBase:OnBtn_Emote()
  local param = {showEmoteOnly = true}
  self.input_box:openInsertBoard(param)
end
function CBpEditBase:OnBtn_Close()
  if self.m_CloseListener then
    self.m_CloseListener()
    self:ClearListeners()
  end
  self:CloseSelf()
end
function CBpEditBase:ClearListeners()
  self.m_OkListener = nil
  self.m_CancelListener = nil
  self.m_CloseListener = nil
end
function CBpEditBase:Clear()
  if self.m_CloseListener then
    self.m_CloseListener()
  end
  self:ClearListeners()
  self.input_box:CloseTheKeyBoard()
  self.input_box:ClearTextFieldExtend()
end
CBpNoticeEdit = class("CBpNoticeEdit", CBpEditBase)
function CBpNoticeEdit:ctor(noticId, initNotice, okListener, cancelListener, closeListener)
  CBpNoticeEdit.super.ctor(self, initNotice, okListener, cancelListener, closeListener)
  self:getNode("txt_name"):setText("帮派公告")
  self.m_NoticId = noticId
end
function CBpNoticeEdit:OnBtn_Publish()
  local notice = self.input_box:GetFieldText()
  if string.len(notice) <= 0 then
    ShowNotifyTips("公告内容不能为空")
    return
  end
  if self.m_OkListener then
    self.m_OkListener(self.m_NoticId, notice)
    self:ClearListeners()
  end
  self:CloseSelf()
  g_BpMgr:send_publishBpNotice(self.m_NoticId, notice)
end
CBpTenetEdit = class("CBpTenetEdit", CBpEditBase)
function CBpTenetEdit:ctor(initNotice)
  CBpTenetEdit.super.ctor(self, initNotice, nil, nil, nil)
  self:getNode("txt_name"):setText("帮派宗旨")
end
function CBpTenetEdit:OnBtn_Publish()
  local notice = self.input_box:GetFieldText()
  if string.len(notice) <= 0 then
    ShowNotifyTips("宗旨内容不能为空")
    return
  end
  self:CloseSelf()
  g_BpMgr:send_editBpTenet(notice)
end
CDuelContentEdit = class("CDuelContentEdit", CBpEditBase)
function CDuelContentEdit:ctor(initContent, okListener)
  CDuelContentEdit.super.ctor(self, initContent, okListener)
  self:getNode("txt_name"):setText("战书内容")
  self:getNode("btn_publish"):setTitleText("确定")
  self.m_MaxInputNum = 26
  self.input_box:SetMaxInputLength(self.m_MaxInputNum)
  self.input_box:SetFiledPlaceHolder("")
  self:caculateCharNum()
end
function CDuelContentEdit:OnBtn_Publish()
  local text = self.input_box:GetFieldText()
  if string.len(text) <= 0 then
    ShowNotifyTips("战书内容不能为空")
    return
  end
  if self.m_OkListener then
    self.m_OkListener(text)
    self:ClearListeners()
  end
  self:CloseSelf()
end
