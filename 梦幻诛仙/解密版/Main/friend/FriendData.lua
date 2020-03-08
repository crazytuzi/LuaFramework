local Lplus = require("Lplus")
local FriendData = Lplus.Class("FriendData")
local ChatModule = require("Main.Chat.ChatModule")
local FriendUtils = require("Main.friend.FriendUtils")
local MailContent = require("netio.protocol.mzm.gsp.mail.MailContent")
local def = FriendData.define
local instance
def.field("table")._friends = nil
def.field("table")._friendMap = nil
def.field("table")._friendsWithChat = nil
def.field("table")._friendsWithoutChat = nil
def.field("table")._applicants = nil
def.field("table")._shields = nil
def.field("table")._allFriends = nil
def.field("table")._mails = nil
def.field("number")._unReadMailsNum = 0
def.field("number")._applyCountMax = 0
def.field("number")._applyTimeMax = 0
def.field("number")._friendCountMax = 0
def.field("number")._maxBattlePerDay = 0
def.field("number")._maxQinMiDu = 0
def.field("number")._valuePerbattle = 0
def.field("boolean")._bHaveSpecial = false
def.field("table").friendRoleIdToUIIndex = nil
local mailConsts = require("netio.protocol.mzm.gsp.mail.MailConsts")
local MailContent = require("netio.protocol.mzm.gsp.mail.MailContent")
def.static("=>", FriendData).Instance = function()
  if nil == instance then
    instance = FriendData()
    instance._friends = {}
    instance._friendMap = {}
    instance._friendsWithChat = {}
    instance._friendsWithoutChat = {}
    instance._applicants = {}
    instance._shields = {}
    instance._mails = {}
    instance.friendRoleIdToUIIndex = {}
  end
  return instance
end
def.method().SetAllNull = function(self)
  self._friends = {}
  self._friendMap = {}
  self._friendsWithChat = {}
  self._friendsWithoutChat = {}
  self._applicants = {}
  self._shields = {}
  self._mails = {}
  self._allFriends = nil
  self._unReadMailsNum = 0
  self._bHaveSpecial = false
  self.friendRoleIdToUIIndex = {}
end
def.method("userdata", "=>", "table").GetShieldInfo = function(self, id)
  local i = 1
  for i = 1, #self._shields do
    if self._shields[i].roleId == id then
      return self._shields[i]
    end
  end
  return nil
end
def.method("string", "=>", "table").GetShieldInfoByName = function(self, name)
  local i = 1
  for i = 1, #self._shields do
    if self._shields[i].roleName == name then
      return self._shields[i]
    end
  end
  return nil
end
def.method("=>", "table").GetShieldList = function(self)
  return self._shields
end
def.method("table").AddShield = function(self, p)
  table.insert(self._shields, p)
end
def.method("userdata").RemoveShieldById = function(self, roleId)
  local i = 1
  for i = 1, #self._shields do
    if self._shields[i].roleId == roleId then
      table.remove(self._shields, i)
      return
    end
  end
end
def.method("string").RemoveShieldByName = function(self, name)
  local i = 1
  for i = 1, #self._shields do
    if self._shields[i].roleName == name then
      table.remove(self._shields, i)
      return
    end
  end
end
def.method("userdata", "=>", "table").GetApplyFriendInfo = function(self, roleId)
  local curApplyList = self._applicants
  if curApplyList == nil or #curApplyList == 0 then
    return nil
  end
  for k, v in pairs(curApplyList) do
    if roleId:eq(v.roleId) then
      return v
    end
  end
  return nil
end
def.method("userdata", "=>", "table").GetFriendInfo = function(self, id)
  if id == nil then
    return nil
  end
  local friendInfo = self._friendMap[id:tostring()]
  if friendInfo then
    return friendInfo
  end
  local i = 1
  for i = 1, #self._friends do
    if self._friends[i].roleId:eq(id) then
      return self._friends[i]
    end
  end
  return nil
end
def.method("string", "=>", "userdata").GetFriendIdByName = function(self, name)
  local i = 1
  for i = 1, #self._friends do
    if self._friends[i].roleName == name then
      return self._friends[i].roleId
    end
  end
  return nil
end
def.method("=>", "table").GetFriendList = function(self)
  return self._friends
end
def.method("=>", "table").GetFriendWithChatList = function(self)
  return self._friendsWithChat
end
def.method("=>", "table").GetFriendWithoutChatList = function(self)
  return self._friendsWithoutChat
end
def.method("userdata").RemoveFirst = function(self, roleId)
  if self._bHaveSpecial then
    local friendInfo = table.remove(self._friends, 1)
    if friendInfo then
      self._friendMap[friendInfo.roleId:tostring()] = nil
    end
    self._bHaveSpecial = false
  end
end
def.method().SetFriendRoleIdToUIIndexNull = function(self)
  self.friendRoleIdToUIIndex = {}
end
def.method("userdata", "number").AddToFriendRoleIdToUIIndex = function(self, roleId, uiIndex)
  self.friendRoleIdToUIIndex[roleId:tostring()] = uiIndex
end
def.method("=>", "table").GetFriendRoleIdToUIIndex = function(self)
  return self.friendRoleIdToUIIndex
end
def.method("table").AddFirst = function(self, p)
  if false == self._bHaveSpecial then
    table.insert(self._friends, 1, p)
    self._bHaveSpecial = true
  end
end
def.method("=>", "boolean").GetIsHaveSpecial = function(self)
  return self._bHaveSpecial
end
def.method("table").AddFriend = function(self, p)
  table.insert(self._friends, p)
  self._friendMap[p.roleId:tostring()] = p
end
def.method().RefreshFriendGroup = function(self)
  self._friendsWithChat = {}
  self._friendsWithoutChat = {}
  for k, v in pairs(self._friends) do
    local chatInfo = ChatModule.Instance():GetFriendNewOne(v.roleId)
    local chatContent = ""
    if nil == chatInfo then
      chatContent = ""
    else
      chatContent = chatInfo.plainHtml
      if chatContent ~= nil then
        chatContent = require("Main.Chat.HtmlHelper").ConvertFriendChat(chatContent)
      end
    end
    if nil ~= chatInfo and nil ~= chatContent then
      table.insert(self._friendsWithChat, v)
    else
      table.insert(self._friendsWithoutChat, v)
    end
  end
end
def.method("userdata").MoveFriendFromWithToWithout = function(self, roleId)
  local roleInfo
  local index = 1
  for i = index, #self._friendsWithChat do
    if self._friendsWithChat[i].roleId == roleId then
      roleInfo = self._friendsWithChat[i]
      index = i
      break
    end
  end
  if nil == roleInfo then
    return
  end
  table.remove(self._friendsWithChat, index)
  table.insert(self._friendsWithoutChat, roleInfo)
end
def.method("userdata").MoveFriendFromWithoutToWith = function(self, roleId)
  local roleInfo
  local index = 1
  for i = index, #self._friendsWithoutChat do
    if self._friendsWithoutChat[i].roleId == roleId then
      roleInfo = self._friendsWithoutChat[i]
      index = i
      break
    end
  end
  if nil == roleInfo then
    return
  end
  table.remove(self._friendsWithoutChat, index)
  table.insert(self._friendsWithChat, roleInfo)
end
def.method("userdata").RemoveFriend = function(self, roleId)
  local i = 1
  self._friendMap[roleId:tostring()] = nil
  for i = 1, #self._friends do
    if self._friends[i].roleId == roleId then
      table.remove(self._friends, i)
      break
    end
  end
  for i = 1, #self._friendsWithChat do
    if self._friendsWithChat[i].roleId == roleId then
      table.remove(self._friendsWithChat, i)
      break
    end
  end
  for i = 1, #self._friendsWithoutChat do
    if self._friendsWithoutChat[i].roleId == roleId then
      table.remove(self._friendsWithoutChat, i)
      break
    end
  end
end
def.method("table").AddApplicant = function(self, p)
  if nil ~= p.roleName and nil == self:GetShieldInfo(p.roleId) then
    table.insert(self._applicants, p)
  end
end
def.method("=>", "table").GetApplicantList = function(self)
  return self._applicants
end
def.method("string", "=>", "userdata").GetApplicantIdByName = function(self, name)
  local i = 1
  for i = 1, #self._applicants do
    if self._applicants[i].roleName == name then
      return self._applicants[i].roleId
    end
  end
  return nil
end
def.method("userdata", "=>", "string").GetApplicantNameById = function(self, applicantId)
  if nil == applicantId then
    return ""
  end
  if nil == self._applicants then
    return ""
  end
  for k, v in pairs(self._applicants) do
    if applicantId == v.roleId then
      return v.roleName
    end
  end
  return ""
end
def.method("string", "=>", "number").GetApplicantTimeByName = function(self, name)
  local i = 1
  for i = 1, #self._applicants do
    if self._applicants[i].roleName == name then
      return self._applicants[i].applyTime
    end
  end
  return nil
end
def.method("table").SetFriendName = function(self, p)
  local i = 1
  for i = 1, #self._friends do
    if self._friends[i].roleId == p.friendId then
      self._friends[i].roleName = p.name
      break
    end
  end
  for i = 1, #self._friendsWithChat do
    if self._friendsWithChat[i].roleId == p.friendId then
      self._friendsWithChat[i].roleName = p.name
      break
    end
  end
  for i = 1, #self._friendsWithoutChat do
    if self._friendsWithoutChat[i].roleId == p.friendId then
      self._friendsWithoutChat[i].roleName = p.name
      break
    end
  end
end
def.method("userdata", "string").SetFriendRemarkName = function(self, friendId, remark)
  for i = 1, #self._friends do
    if self._friends[i].roleId == friendId then
      self._friends[i].remarkName = remark
      break
    end
  end
end
def.method("userdata").RemoveApplicant = function(self, roleId)
  local i = 1
  for i = 1, #self._applicants do
    if self._applicants[i].roleId == roleId then
      table.remove(self._applicants, i)
      return
    end
  end
end
def.method("table").AddMail = function(self, mail)
  local mailInfo = {}
  mailInfo.mailIndex = mail.mailIndex
  mailInfo.readState = mail.readState
  mailInfo.createTime = mail.createTime
  mailInfo.hasThing = mail.hasThing
  mailInfo.mailContent = mail.mailContent
  mailInfo.extraparam = mail.extraparam
  mailInfo.contentType, mailInfo.title, mailInfo.content, mailInfo.mailType, mailInfo.itemList, mailInfo.notItemList = self:GetMailInfoByType(mail.mailContent, mail.hasThing)
  if self:IsPlayerInZeroProfit(mailInfo) then
    self:AddZeroProfitTag(mailInfo)
  end
  table.insert(self._mails, mailInfo)
  table.sort(self._mails, function(a, b)
    return a.createTime > b.createTime
  end)
  if mailInfo.readState == mailConsts.MAIL_DATA_STATE_NOT_READ then
    self._unReadMailsNum = self._unReadMailsNum + 1
  end
end
def.method("table", "number", "=>", "number", "string", "string", "number", "table", "table").GetMailInfoByType = function(self, mailContent, hasThing)
  local mailContentType = mailContent.mailContentType
  local title = ""
  local content = ""
  local mailType = 0
  local itemList = {}
  local notItemList = {}
  local ThingBean = require("netio.protocol.mzm.gsp.mail.ThingBean")
  if mailContentType == MailContent.TYPE_MAIL_FULL_CFG then
    local id = tonumber(mailContent.contentMap[MailContent.CONTENT_MAIL_CFG_ID])
    local mailInfo = FriendUtils.GetMailInfoById(id)
    if mailInfo ~= nil then
      local titleArgs = mailContent.formatArgsMap[MailContent.FORMAT_STRING_TITLE]
      if titleArgs ~= nil then
        title = string.format(mailInfo.title, unpack(titleArgs.args))
      else
        title = mailInfo.title
      end
      local contentArgs = mailContent.formatArgsMap[MailContent.FORMAT_STRING_CONTENT]
      if contentArgs ~= nil then
        content = string.format(mailInfo.content, unpack(contentArgs.args))
      else
        content = mailInfo.content
      end
      mailType = mailInfo.mailType
      if hasThing == mailConsts.MAIL_DATA_NO_THING then
        return mailContentType, title, content, mailType, itemList, notItemList
      end
      for k, v in pairs(mailInfo.tokenList) do
        local thing = {}
        thing.id = v.tokenType
        thing.count = v.tokeCount
        thing.thingType = ThingBean.MAIL_ATTACHMENT_TOKEN
        table.insert(notItemList, thing)
      end
      for k, v in pairs(mailInfo.itemList) do
        local ItemUtils = require("Main.Item.ItemUtils")
        local itemBase = ItemUtils.GetItemBase(v.itemId)
        if itemBase ~= nil then
          local num = v.itemNum / itemBase.pilemax
          local left = v.itemNum % itemBase.pilemax
          if left > 0 then
            local item = {}
            item.id = v.itemId
            item.number = left
            table.insert(itemList, item)
          end
          for i = 1, num do
            local item = {}
            item.id = v.itemId
            item.number = itemBase.pilemax
            table.insert(itemList, item)
          end
        end
      end
      local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
      if 0 < mailInfo.yuanbao then
        local thing = {}
        thing.id = MoneyType.YUANBAO
        thing.count = mailInfo.yuanbao
        thing.thingType = ThingBean.MAIL_ATTACHMENT_MONEY
        table.insert(notItemList, thing)
      end
      if 0 < mailInfo.gold then
        local thing = {}
        thing.id = MoneyType.GOLD
        thing.count = mailInfo.gold
        thing.thingType = ThingBean.MAIL_ATTACHMENT_MONEY
        table.insert(notItemList, thing)
      end
      if 0 < mailInfo.silver then
        local thing = {}
        thing.id = MoneyType.SILVER
        thing.count = mailInfo.silver
        thing.thingType = ThingBean.MAIL_ATTACHMENT_MONEY
        table.insert(notItemList, thing)
      end
      if 0 < mailInfo.goldIngot then
        local thing = {}
        thing.id = MoneyType.GOLD_INGOT
        thing.count = mailInfo.goldIngot
        thing.thingType = ThingBean.MAIL_ATTACHMENT_MONEY
        table.insert(notItemList, thing)
      end
    end
  elseif mailContentType == MailContent.TYPE_MAIL_AUTO then
    title = mailContent.contentMap[MailContent.CONTENT_MAIL_TITLE]
    content = mailContent.contentMap[MailContent.CONTENT_MAIL_CONTENT]
    mailType = mailContent.contentMap[MailContent.CONTENT_MAIL_TYPE]
  elseif mailContentType == MailContent.TYPE_MAIL_CFG then
    local id = tonumber(mailContent.contentMap[MailContent.CONTENT_MAIL_CFG_ID])
    local mailInfo = FriendUtils.GetMailInfoById(id)
    if mailInfo ~= nil then
      local titleArgs = mailContent.formatArgsMap[MailContent.FORMAT_STRING_TITLE]
      if titleArgs ~= nil then
        title = string.format(mailInfo.title, unpack(titleArgs.args))
      else
        title = mailInfo.title
      end
      local contentArgs = mailContent.formatArgsMap[MailContent.FORMAT_STRING_CONTENT]
      if contentArgs ~= nil then
        content = string.format(mailInfo.content, unpack(contentArgs.args))
      else
        content = mailInfo.content
      end
      mailType = mailInfo.mailType
    end
  end
  return mailContentType, title, content, tonumber(mailType), itemList, notItemList
end
def.method("table", "=>", "boolean").IsPlayerInZeroProfit = function(self, mailInfo)
  local MailData = require("netio.protocol.mzm.gsp.mail.MailData")
  return mailInfo ~= nil and mailInfo.extraparam[MailData.EXTRA_KEY_ZERO_PROFIT] ~= nil
end
def.method("table").AddZeroProfitTag = function(self, mailInfo)
  mailInfo.content = textRes.Mail[2] .. mailInfo.content
  mailInfo.title = mailInfo.title .. textRes.Mail[3]
end
def.method("number", "=>", "number").GetMailIndexByOnly = function(self, mailIndex)
  for k, v in pairs(self._mails) do
    if v.mailIndex == mailIndex then
      return k
    end
  end
  return 0
end
def.method("=>", "table").GetMailCatalog = function(self)
  return self._mails
end
def.method("number").SetUnReadMailsNum = function(self, num)
  self._unReadMailsNum = num
end
def.method("number").UnReadMailsAddNum = function(self, addNum)
  self._unReadMailsNum = self._unReadMailsNum + addNum
end
def.method("=>", "number").GetUnReadMailsNum = function(self)
  return self._unReadMailsNum
end
def.method("=>", "boolean").HasNewMail = function(self)
  local i = 1
  for i = 1, #self._mails do
    if self._mails[i].readState == mailConsts.MAIL_DATA_STATE_NOT_READ then
      return true
    end
  end
  return false
end
def.method("number", "=>", "table").GetMail = function(self, idx)
  local i = 1
  for i = 1, #self._mails do
    if self._mails[i].mailIndex == idx then
      return self._mails[i]
    end
  end
  return nil
end
def.method("number", "=>", "table").RemoveMail = function(self, idx)
  local index = 1
  for i = index, #self._mails do
    if self._mails[i].mailIndex == idx then
      if self._mails[i].readState == mailConsts.MAIL_DATA_STATE_NOT_READ then
        self._unReadMailsNum = self._unReadMailsNum - 1
      end
      table.remove(self._mails, i)
      index = i
      break
    end
  end
  return self._mails[index]
end
def.method("number").SetRead = function(self, idx)
  local i = 1
  for i = 1, #self._mails do
    if self._mails[i].mailIndex == idx then
      self._mails[i].readState = mailConsts.MAIL_DATA_STATE_READED
      break
    end
  end
end
def.method("number").AttachmentClaimed = function(self, idx)
  local i = 1
  for i = 1, #self._mails do
    if self._mails[i].mailIndex == idx then
      self._mails[i].itemList = {}
      self._mails[i].notItemList = {}
      self._mails[i].hasThing = mailConsts.MAIL_DATA_NO_THING
      break
    end
  end
end
def.method("number", "table", "table").SetAttachments = function(self, idx, itemList, notItemList)
  local i = 1
  for i = 1, #self._mails do
    if self._mails[i].mailIndex == idx then
      self._mails[i].itemList = {}
      self._mails[i].itemList = itemList
      self._mails[i].notItemList = {}
      self._mails[i].notItemList = notItemList
      break
    end
  end
end
def.method("table").AutoAttachmentClaimed = function(self, idxs)
  local i = 1
  for i = 1, #idxs do
    self:AttachmentClaimed(idxs[i])
    self:SetRead(idxs[i])
  end
end
def.method("table").DeleteAllMails = function(self, idxs)
  local i = 1
  for i = 1, #idxs do
    self:RemoveMail(idxs[i])
  end
end
def.method().SortMailsByTime = function(self)
  table.sort(self._mails, function(a, b)
    return a.createTime > b.createTime
  end)
end
def.method().SetAllFriendsNull = function(self)
  self._allFriends = {}
end
def.method("table").AddToAllFriends = function(self, friend)
  table.insert(self._allFriends, friend)
end
def.method("=>", "table").GetAllFriends = function(self)
  return self._allFriends
end
def.method().ReSortFriendShowList = function(self)
  self:RefreshFriendGroup()
  self:SetAllFriendsNull()
  self:SetFriendRoleIdToUIIndexNull()
  local firstTbl = {}
  if self:GetIsHaveSpecial() then
    local friends = self:GetFriendList()
    table.insert(firstTbl, friends[1])
  end
  local chatList = {}
  local friendsWithChat = self:GetFriendWithChatList()
  local strangerList = ChatModule.Instance():GetStrangerChat()
  for k, v in pairs(friendsWithChat) do
    table.insert(chatList, v)
  end
  for k, v in pairs(strangerList) do
    table.insert(chatList, v)
  end
  table.sort(chatList, function(a, b)
    local aChatInfo = ChatModule.Instance():GetFriendNewOne(a.roleId)
    local bChatInfo = ChatModule.Instance():GetFriendNewOne(b.roleId)
    local aTime = aChatInfo and aChatInfo.time or 0
    local bTime = bChatInfo and bChatInfo.time or 0
    return aTime > bTime
  end)
  local friendsWithoutChat = self:GetFriendWithoutChatList()
  local friendsWithoutChatOnline = {}
  local friendsWithoutChatOffline = {}
  for k, v in pairs(friendsWithoutChat) do
    local pinyinName = GameUtil.ConvertStringToPY(v.roleName)
    v.pinyinName = pinyinName
    if require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE == v.onlineStatus then
      table.insert(friendsWithoutChatOnline, v)
    elseif require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_OFFLINE == v.onlineStatus then
      table.insert(friendsWithoutChatOffline, v)
    end
  end
  table.sort(friendsWithoutChatOnline, function(a, b)
    return a.pinyinName < b.pinyinName
  end)
  table.sort(friendsWithoutChatOffline, function(a, b)
    return a.pinyinName < b.pinyinName
  end)
  if #firstTbl > 0 then
    self:AddToAllFriends(firstTbl[1])
    self:AddToFriendRoleIdToUIIndex(firstTbl[1].roleId, 1)
  end
  for k, v in pairs(chatList) do
    self:AddToAllFriends(v)
    self:AddToFriendRoleIdToUIIndex(v.roleId, k)
  end
  for k, v in pairs(friendsWithoutChatOnline) do
    self:AddToAllFriends(v)
    self:AddToFriendRoleIdToUIIndex(v.roleId, k)
  end
  for k, v in pairs(friendsWithoutChatOffline) do
    self:AddToAllFriends(v)
    self:AddToFriendRoleIdToUIIndex(v.roleId, k)
  end
end
FriendData.Commit()
return FriendData
