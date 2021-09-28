MailDetailView = class("MailDetailView", CcsSubView)
function MailDetailView:ctor(mailId, mailInfo)
  MailDetailView.super.ctor(self, "views/mail_detail.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_accept = {
      listener = handler(self, self.OnBtn_Accept),
      variName = "btn_accept"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_mailInfo = mailInfo
  self.m_MailId = mailId
  self.list_obj = self:getNode("list_obj")
  local listSize = self.list_obj:getInnerContainerSize()
  local listW = listSize.width
  self:getNode("txt_lianhua_2"):setVisible(false)
  local txt_title = CRichText.new({
    width = listW - 30,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 24,
    color = ccc3(255, 196, 98),
    align = CRichText_AlignType_Center,
    maxLineNum = 3
  })
  txt_title:addRichText(mailInfo.title or "")
  local p = self.list_obj:getParent()
  local _, y = self:getNode("txt_lianhua_2"):getPosition()
  local x, _ = self.list_obj:getPosition()
  local titleTxtSize = txt_title:getRichTextSize()
  txt_title:setPosition(ccp(x + 10, y - titleTxtSize.height / 2))
  p:addChild(txt_title)
  local totalH = 0
  local txt_des = CRichText.new({
    width = listW - 4,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255),
    align = CRichText_AlignType_Left
  })
  self.list_obj:addChild(txt_des)
  txt_des:addRichText(mailInfo.des or "")
  local desTxtSize = txt_des:getRichTextSize()
  totalH = totalH + desTxtSize.height
  totalH = totalH + 50
  local objs = mailInfo.objLists or {}
  local items = {}
  local itemDy = 5
  local s = CCSize(60, 60)
  if self.m_MailId == 0 then
    self.btn_accept:setEnabled(true)
    self.btn_accept:setTitleText("确定")
  elseif #objs == 0 then
    self.btn_accept:setEnabled(false)
  else
    self.btn_accept:setEnabled(true)
    self.btn_accept:setTitleText("收取")
  end
  for i, info in ipairs(objs) do
    local t, num, itemType = info[1], info[2], info[3]
    print("==> t, num:", t, num)
    if num > 0 then
      local item
      if itemType == MAIL_ITEMTYPE_RES then
        item = createClickResItem({
          resID = t,
          num = 0,
          autoSize = s,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      elseif itemType == MAIL_ITEMTYPE_PET then
        item = createClickPetHead({
          roleTypeId = t,
          autoSize = s,
          clickListener = nil,
          noBgFlag = nil,
          offx = nil,
          offy = nil,
          clickDel = nil,
          LongPressTime = 0.01,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      else
        item = createClickItem({
          itemID = t,
          autoSize = s,
          num = 0,
          LongPressTime = 0.2,
          clickListener = nil,
          LongPressListener = nil,
          LongPressEndListner = nil,
          clickDel = nil,
          noBgFlag = nil
        })
      end
      print("item:", item)
      if item == nil then
        return false
      end
      if item then
        local itemSize = item:getSize()
        totalH = totalH + itemSize.height + itemDy
        self.list_obj:addChild(item)
        items[#items + 1] = {
          item,
          itemSize.height
        }
        local txtNum = CRichText.new({
          width = listW,
          verticalSpace = 1,
          font = KANG_TTF_FONT,
          fontSize = 22,
          color = ccc3(255, 255, 255),
          align = CRichText_AlignType_Left
        })
        txtNum:addRichText(string.format("x%d", num))
        item:addChild(txtNum)
        local s_ = txtNum:getRichTextSize()
        txtNum:setPosition(ccp(itemSize.width + 8, itemSize.height / 2 - s_.height / 2))
      end
    end
  end
  local bottomH = 20
  totalH = totalH + bottomH
  if totalH < listSize.height then
    totalH = listSize.height
  end
  self.list_obj:setInnerContainerSize(CCSize(listW, totalH))
  txt_des:setPosition(ccp(2, totalH - desTxtSize.height - 10))
  local y = bottomH
  for i = #items, 1, -1 do
    local d = items[i]
    local item, h = d[1], d[2]
    item:setPosition(ccp(2, y))
    y = y + h + itemDy
  end
  g_MailMgr:reqReadedMail(self.m_MailId)
  if g_SocialityDlg then
    g_SocialityDlg:setCheckDetailDlg(self)
  end
  self:enableCloseWhenTouchOutside(self:getNode("pic_detail"), true)
end
function MailDetailView:Clear()
end
function MailDetailView:getMailInfo()
  return self.m_mailInfo
end
function MailDetailView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function MailDetailView:OnBtn_Accept(btnObj, touchType)
  print("==>>MailDetailView:OnBtn_Accept")
  if self.m_MailId == 0 then
    self:CloseSelf()
    return
  end
  g_MailMgr:reqAccept(self.m_MailId)
  self:CloseSelf()
end
