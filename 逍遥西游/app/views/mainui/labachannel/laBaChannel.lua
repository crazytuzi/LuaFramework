laBaChannel = class("laBaChannel", CcsSubView)
function laBaChannel:ctor()
  laBaChannel.super.ctor(self, "views/labachannel.csb", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = true
  })
  self.m_sendCD = 0
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_sendmsg = {
      listener = handler(self, self.OnBtn_Send),
      variName = "btn_sendmsg"
    },
    btn_emo = {
      listener = handler(self, self.OnBtn_Emo),
      variName = "btn_emo"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local img_bg_need = self:getNode("img_bg_spend")
  self.txt_neednum = self:getNode("txt_neednum")
  self.txt_releasnum = self:getNode("txt_releasnum")
  local tempImg = display.newSprite("xiyou/pic/pic_laba.png")
  local ssize = tempImg:getContentSize()
  local bgsize = img_bg_need:getContentSize()
  local bgh = bgsize.height * 0.8
  local percent = bgh / ssize.height
  tempImg:setScale(percent)
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  img_bg_need:addNode(tempImg)
  local needcount = g_LBMgr:getCurrontCount()
  local allcount = 0
  allcount = g_LocalPlayer and (g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_LABA) or 0)
  self.txt_neednum:setText(tostring(needcount))
  self.txt_releasnum:setText(string.format("剩余 %d", allcount))
  self.m_MaxInputNum = 36
  self.input_box = self:getNode("edtxt_content")
  local msize = self.input_box:getSize()
  TextFieldEmoteExtend.extend(self.input_box, self.m_UINode, {
    width = msize.width,
    align = CRichText_AlignType_Left
  })
  self.input_box:setMaxLengthEnabled(false)
  self.input_box:SetMaxInputLength(self.m_MaxInputNum)
  self.input_box:SetKeyBoardListener(handler(self, self.onKeyBoardListener))
  self.input_box:SetFieldText(initNotice)
  self.input_box:SetEnableMulti(true)
  self.input_box:SetFiledPlaceHolder("请输入要发言的内容。（最多输入36个汉字）", {
    fontSize = 22,
    color = ccc3(78, 47, 20)
  })
  self.m_sendcdHandler = scheduler.scheduleGlobal(handler(self, self.cdCounter), 1)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_ItemInfo)
end
function laBaChannel:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_DelItem or msgSID == MsgID_ItemInfo_ChangeItemNum or msgSID == MsgID_ItemInfo_DelItem then
    self:flushTips()
  end
end
function laBaChannel:OnBtn_Close()
  self:CloseSelf()
end
function laBaChannel:OnBtn_Emo()
  self.input_box:openInsertBoard()
end
function laBaChannel:OnBtn_Send()
  if self.m_sendCD and self.m_sendCD > 0 then
    local msg = string.format("请在%d秒后继续发言", self.m_sendCD)
    ShowNotifyTips(msg)
    return
  end
  if self.input_box then
    local sendMsg = self.input_box:GetFieldText()
    if 0 < GetMyUTF8Len(sendMsg) then
      netsend.netmessage.sendLaBaMessage(sendMsg, nil)
      g_LocalPlayer:recordRecentChat(sendMsg)
      SendMessage(MsgID_Message_NewSendMsg, sendMsg)
    else
      ShowNotifyTips("发送内容不能为空")
    end
    print("SendMsg =====>>>> ", sendMsg)
  end
end
function laBaChannel:onKeyBoardListener(event, param)
  if event == TEXTFIELDEXTEND_EVENT_TEXT_CHANGE then
  elseif event == TEXTFIELDEXTEND_EVENT_SEND_TEXT then
    local chatText = param
    if string.len(chatText) > 0 then
      if self.m_sendCD and 0 < self.m_sendCD then
        local msg = string.format("请在%d秒后继续发言", self.m_sendCD)
        ShowNotifyTips(msg)
        return
      else
        netsend.netmessage.sendLaBaMessage(param, nil)
        g_LocalPlayer:recordRecentChat(param)
        SendMessage(MsgID_Message_NewSendMsg, param)
        self:CloseSelf()
      end
    end
  end
end
function laBaChannel:flushCD(lefttime)
  if self.input_box then
    self.input_box:SetFieldText("")
  end
  if type(lefttime) == "number" then
    self.m_sendCD = lefttime
  end
  if self.m_sendCD == nil or self.m_sendCD < 0 then
    self.m_sendCD = 0
  end
  if self.m_sendCD > 0 and self.btn_sendmsg then
    self.btn_sendmsg:setTitleText(string.format("%ds", self.m_sendCD))
  elseif self.btn_sendmsg then
    self.btn_sendmsg:setTitleText("发送")
  end
end
function laBaChannel:cdCounter()
  if self.m_sendCD == nil or self.m_sendCD < 0 then
    self.m_sendCD = 0
  else
    self.m_sendCD = self.m_sendCD - 1
  end
  if self.m_sendCD > 0 and self.btn_sendmsg then
    self.btn_sendmsg:setTitleText(string.format("%ds", self.m_sendCD))
  elseif self.btn_sendmsg then
    self.btn_sendmsg:setTitleText("发送")
  end
end
function laBaChannel:flushTips()
  if self.txt_neednum == nil or self.txt_releasnum == nil then
    self.txt_neednum = self:getNode("txt_neednum")
    self.txt_releasnum = self:getNode("txt_releasnum")
  end
  local needcount = g_LBMgr:getCurrontCount()
  local allcount = 0
  allcount = g_LocalPlayer and (g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_LABA) or 0)
  self.txt_neednum:setText(tostring(needcount))
  self.txt_releasnum:setText(string.format("剩余 %d", allcount))
end
function laBaChannel:Clear()
  self.m_sendCD = 0
  if self.m_sendcdHandler then
    scheduler.unscheduleGlobal(self.m_sendcdHandler)
    self.m_sendcdHandler = nil
  end
  if g_labaview and g_labaview == self then
    g_labaview = nil
  end
  print("Clear ======>>>>  ", self.input_box == nil)
  if self.input_box then
    self.input_box:CloseTheKeyBoard()
    print("========== 11111 ")
    self.input_box:ClearTextFieldExtend()
    print("========== 22222222 ")
  end
end
