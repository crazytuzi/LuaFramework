socialityDlgExtend_Mail = {}
function socialityDlgExtend_Mail.extend(object)
  function object:InitMail()
    object.list_mail = object:getNode("list_mail")
    object:resizeList(object.list_mail)
    object.list_mail:addTouchItemListenerListView(handler(object, object.ChooseMailItem), handler(object, object.MailListEventListener))
    object.pic_newtip = object:getNode("pic_newtip")
    object.txt_loading = object:getNode("txt_loading")
    object.txt_loading:setText("加载中")
    local txt = {
      "加载中.",
      "加载中..",
      "加载中..."
    }
    local idx = -1
    object.txt_loading:runAction(CCRepeatForever:create(transition.sequence({
      CCDelayTime:create(0.8),
      CCCallFunc:create(function()
        idx = (idx + 1) % 3
        object.txt_loading:setText(txt[idx + 1])
      end)
    })))
    object.m_MailShow = nil
    object.m_MailItems = {}
    object:checkNewMailTip()
    object:ListenMessage(MsgID_Mail)
  end
  function object:ShowMailPage(iShow)
    if object.m_MailShow == iShow then
      return
    end
    if iShow then
      if not object.layermail:isVisible() then
        return
      end
      object.txt_loading:setVisible(true)
      object.m_MailItems = {}
      object.list_mail:removeAllItems()
      g_MailMgr:reqGetAllMails()
    else
      object.m_MailItems = {}
      object.list_mail:removeAllItems()
    end
    object.m_MailShow = iShow
  end
  function object:onReceiveMail_AllMailLoaded()
    object:checkNewMailTip()
    object.txt_loading:setVisible(false)
    local mails = g_MailMgr:getMails()
    local sortMails = {}
    for k, v in pairs(mails) do
      local d = {}
      for k1, v1 in pairs(v) do
        d[k1] = v1
      end
      d.mailid = k
      sortMails[#sortMails + 1] = d
    end
    if #sortMails > 0 then
      table.sort(sortMails, function(d1, d2)
        if d1 == nil or d2 == nil then
          return false
        end
        if d1.mailid == 0 and d2.mailid ~= 0 then
          return true
        elseif d1.mailid ~= 0 and d2.mailid == 0 then
          return false
        end
        if d1.time and d2.time and d1.time > d2.time then
          return true
        end
        return false
      end)
      object.m_MailItems = {}
      local idx = 0
      for i, mailInfo in ipairs(sortMails) do
        local item = MainViewItem.new(mailInfo.mailid)
        if item:Init() == true then
          object.list_mail:pushBackCustomItem(item:getUINode())
          object.m_MailItems[idx + 1] = item
          idx = idx + 1
        end
      end
    end
    object:UpdateEmptyTxt()
  end
  function object:onReceiveMail_MailUpdated(mailId)
    object:checkNewMailTip()
    if mailId then
      for idx, mailItem in pairs(object.m_MailItems) do
        if mailItem:getMailId() == mailId then
          mailItem:reflush()
          break
        end
      end
    end
  end
  function object:onReceiveMail_MailDeleteed(mailId)
    object:checkNewMailTip()
    if mailId then
      local delIdx = -1
      for idx, mailItem in pairs(object.m_MailItems) do
        if mailItem:getMailId() == mailId then
          delIdx = idx
          break
        end
      end
      if delIdx >= 0 then
        object.list_mail:removeItem(object.list_mail:getIndex(object.m_MailItems[delIdx]:getUINode()))
        table.remove(object.m_MailItems, delIdx)
      end
    end
    object:UpdateEmptyTxt()
  end
  function object:onReceiveMail_MailHasNewMail()
    object:checkNewMailTip()
  end
  function object:UpdateEmptyTxt()
    local flag = true
    local mails = g_MailMgr:getMails()
    for k, v in pairs(mails) do
      flag = false
      break
    end
    if flag then
      if object.m_EmptyTxt == nil then
        object.m_EmptyTxt = ui.newTTFLabel({
          text = "(你的邮箱空空如也哟)",
          font = KANG_TTF_FONT,
          size = 24,
          color = ccc3(77, 48, 14)
        })
        object.txt_loading:getParent():addNode(object.m_EmptyTxt, object.txt_loading:getZOrder())
        local x, y = object.txt_loading:getPosition()
        object.m_EmptyTxt:setPosition(ccp(x, y))
      else
        object.m_EmptyTxt:setVisible(true)
      end
    elseif object.m_EmptyTxt ~= nil then
      object.m_EmptyTxt:setVisible(false)
    end
  end
  function object:ChooseMailItem(item, index, listObj)
    item = object.m_MailItems[index + 1]
    if item == nil then
      return
    end
    print("==>object:ChooseMailItem:", item:getMailId())
    local mailId = item:getMailId()
    local mailInfo = item:getMailInfo()
    getCurSceneView():addSubView({
      subView = MailDetailView.new(mailId, mailInfo),
      zOrder = MainUISceneZOrder.menuView
    })
  end
  function object:MailListEventListener(item, index, listObj, status)
    item = object.m_MailItems[index + 1]
    print("MailListEventListener:", status, item)
    if item == nil then
      return
    end
    if status == LISTVIEW_ONSELECTEDITEM_START then
      if item then
        item:setTouchStatus(true)
        object.m_TouchStartItem = item
      end
    elseif status == LISTVIEW_ONSELECTEDITEM_END then
      if object.m_TouchStartItem then
        object.m_TouchStartItem:setTouchStatus(false)
        object.m_TouchStartItem = nil
      end
      if item then
        item:setTouchStatus(false)
      end
    end
  end
  function object:checkNewMailTip()
    local newMailFlag = g_MailMgr:getIsHasNewMail()
    object.pic_newtip:setVisible(newMailFlag)
  end
  function object:Clear_MailExtend()
    object.m_TouchStartItem = nil
  end
  object:InitMail()
end
