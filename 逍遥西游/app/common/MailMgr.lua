MAIL_ITEMTYPE_RES = 1
MAIL_ITEMTYPE_ITEM = 2
MAIL_ITEMTYPE_PET = 3
local MailMgr = class("MailMgr")
function MailMgr:ctor()
  self.m_Mails = {}
  self.m_InitHasNewFlag = false
  self.m_MailResSeq = RESTYPELIST
  self.m_MailResSeqObj = {}
  for k, v in pairs(self.m_MailResSeq) do
    self.m_MailResSeqObj[v] = 1
  end
end
function MailMgr:getMailInfo(mailId)
  return self.m_Mails[mailId]
end
function MailMgr:getMails()
  return self.m_Mails
end
function MailMgr:reqGetAllMails()
  netsend.netmail.getall()
end
function MailMgr:reqReadedMail(mailId)
  netsend.netmail.read(mailId)
end
function MailMgr:reqAccept(mailId)
  netsend.netmail.accept(mailId)
end
function MailMgr:recvMailData(data, isUpdate)
  if data == nil then
    return
  end
  local mid = data.i_mid
  if mid == nil then
    return
  end
  local mailData = self.m_Mails[mid]
  if mailData == nil then
    mailData = {}
    self.m_Mails[mid] = mailData
  end
  local i_tm = data.i_tm or mailData.i_tm
  local i_tl = data.i_tl or mailData.i_tl
  local i_frname = data.i_frname or mailData.i_frname
  local i_c = data.i_c or mailData.i_c
  local t_res = data.t_res or mailData.t_res
  local t_items = data.t_items or mailData.t_items
  local t_pets = data.t_pets or mailData.t_pets
  local i_r = data.i_r or mailData.i_r
  mailData.i_tm = i_tm
  mailData.i_tl = i_tl
  mailData.i_frname = i_frname
  mailData.i_c = i_c
  mailData.t_res = t_res
  mailData.t_items = t_items
  mailData.t_pets = t_pets
  mailData.i_r = i_r
  if i_tl ~= nil then
    mailData.title = i_tl
  end
  if i_frname then
    mailData.sender = i_frname
  end
  if i_c then
    mailData.des = i_c
  end
  if i_tm then
    mailData.time = i_tm
  end
  mailData.isread = i_r == 1
  local objctList
  if t_res ~= nil or t_items ~= nil or t_pets ~= nil then
    t_res = t_res or {}
    t_items = t_items or {}
    t_pets = t_pets or {}
    objctList = {}
    for i, k in ipairs(self.m_MailResSeq) do
      local num = t_res[k]
      if num == nil then
        num = t_res[tostring(k)]
      end
      if num then
        objctList[#objctList + 1] = {
          tonumber(k),
          num,
          MAIL_ITEMTYPE_RES
        }
      end
    end
    for k, v in pairs(t_res) do
      if self.m_MailResSeqObj[k] ~= 1 and self.m_MailResSeqObj[checkint(k)] ~= 1 then
        objctList[#objctList + 1] = {
          tonumber(k),
          v,
          MAIL_ITEMTYPE_RES
        }
      end
    end
    for k, v in pairs(t_items) do
      if self.m_MailResSeqObj[k] ~= 1 and self.m_MailResSeqObj[checkint(k)] ~= 1 then
        objctList[#objctList + 1] = {
          tonumber(k),
          v,
          MAIL_ITEMTYPE_ITEM
        }
      end
    end
    for _, data in pairs(t_pets) do
      local k, v = data[1], data[2]
      if self.m_MailResSeqObj[k] ~= 1 and self.m_MailResSeqObj[checkint(k)] ~= 1 then
        objctList[#objctList + 1] = {
          tonumber(k),
          v,
          MAIL_ITEMTYPE_PET
        }
      end
    end
  end
  if objctList ~= nil then
    mailData.objLists = objctList
  elseif mailData.objLists == nil then
    mailData.objLists = {}
  end
  if isUpdate then
    SendMessage(MsgID_Mail_MailUpdated, mid)
  end
end
function MailMgr:recvAllMailFinished()
  self.m_InitHasNewFlag = false
  SendMessage(MsgID_Mail_AllMailLoaded)
end
function MailMgr:delMail(mailId)
  if mailId then
    self.m_Mails[mailId] = nil
    SendMessage(MsgID_Mail_MailDeleteed, mailId)
  end
end
function MailMgr:hasNewMail()
  self.m_InitHasNewFlag = true
  SendMessage(MsgID_Mail_MailHasNewMail)
end
function MailMgr:getIsHasNewMail()
  if self.m_InitHasNewFlag == true then
    return true
  end
  local hasNoReadMail = false
  for mid, mData in pairs(self.m_Mails) do
    if mData.isread == false then
      hasNoReadMail = true
      break
    end
  end
  return hasNoReadMail
end
function MailMgr:Clear()
end
g_MailMgr = MailMgr.new()
gamereset.registerResetFunc(function()
  if g_MailMgr then
    g_MailMgr:Clear()
    g_MailMgr = nil
  end
  g_MailMgr = MailMgr.new()
end)
