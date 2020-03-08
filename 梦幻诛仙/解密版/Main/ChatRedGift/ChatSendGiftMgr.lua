local Lplus = require("Lplus")
local ChatSendGiftMgr = Lplus.Class("ChatSendGiftMgr")
local ChatRedGiftUtility = require("Main.ChatRedGift.ChatRedGiftUtility")
local def = ChatSendGiftMgr.define
local instance
def.static("=>", ChatSendGiftMgr).Instance = function()
  if instance == nil then
    instance = ChatSendGiftMgr()
  end
  return instance
end
def.field("table").SSynGiftInvitationToRoleMsg = nil
def.field("table").SSynGiftInvitationToSelfMsg = nil
def.field("table").SGiveGiftToRoleRes = nil
def.field("table").SSynRoleReceiveGiftRes = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gift.SSynGiftInvitationToRoleMsg", ChatSendGiftMgr.OnReceiveGiftMsg)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gift.SSynGiftInvitationToSelfMsg", ChatSendGiftMgr.OnSendGiftMsg)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gift.SGiveGiftToRoleErrorRes", ChatSendGiftMgr.OnSendGiftError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gift.SGiveGiftToRoleRes", ChatSendGiftMgr.OnSendGiftSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gift.SSynRoleReceiveGiftRes", ChatSendGiftMgr.OnReceiveSendMsg)
  Event.RegisterEventWithContext(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, ChatSendGiftMgr.onMainUIReady, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, ChatSendGiftMgr.OnClickSendBtn, self)
end
def.method().Reset = function(self)
  self.SSynGiftInvitationToRoleMsg = nil
  self.SSynGiftInvitationToSelfMsg = nil
  self.SGiveGiftToRoleRes = nil
  self.SSynRoleReceiveGiftRes = nil
end
def.static("table").OnReceiveGiftMsg = function(p)
  if textRes.ChatRedGift.SendGiftText[p.giftType] == nil then
    return
  end
  local self = instance
  if not IsEnteredWorld() then
    if self.SSynGiftInvitationToRoleMsg == nil then
      self.SSynGiftInvitationToRoleMsg = {}
    end
    table.insert(self.SSynGiftInvitationToRoleMsg, p)
    return
  end
  local senderId = p.roleInfo.roleId
  local receiverId = GetMyRoleID()
  local roleName = p.roleInfo.roleName
  local gender = p.roleInfo.gender
  local occupationId = p.roleInfo.occupationId
  local avatarId = p.roleInfo.avatarid
  local avatarFrameId = p.roleInfo.avatar_frame_id
  local level = p.roleInfo.level
  local vipLevel = 0
  local modelId = 0
  local badge = {}
  local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
  local formatArgs = p.msgArgs
  table.insert(formatArgs, p.invitationUuid:tostring())
  table.insert(formatArgs, p.invitationUuid:tostring())
  table.insert(formatArgs, senderId:tostring())
  table.insert(formatArgs, p.giftType)
  local str = string.format(textRes.ChatRedGift.SendGiftText[p.giftType].Request, unpack(formatArgs))
  local content = require("netio.Octets").rawFromString(str)
  ChatSendGiftMgr.Instance():SendFakeFriendMsg(senderId, receiverId, senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, p.inviteSecs, avatarId, avatarFrameId)
end
def.static("table").OnSendGiftMsg = function(p)
  if textRes.ChatRedGift.SendGiftText[p.giftType] == nil then
    return
  end
  local self = instance
  if not IsEnteredWorld() then
    if self.SSynGiftInvitationToSelfMsg == nil then
      self.SSynGiftInvitationToSelfMsg = {}
    end
    table.insert(self.SSynGiftInvitationToSelfMsg, p)
    return
  end
  require("Main.Chat.ChatModule").Instance():SetChatRoleCache2(p.roleInfo.roleId, p.roleInfo.roleName, p.roleInfo.level, p.roleInfo.occupationId, p.roleInfo.gender, p.roleInfo.avatarid, p.roleInfo.avatar_frame_id)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local senderId = heroProp.id
  local receiverId = p.roleInfo.roleId
  local roleName = heroProp.name
  local gender = heroProp.gender
  local occupationId = heroProp.occupation
  local avatarId = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarId()
  local avatarFrameId = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarFrameId()
  local level = heroProp.level
  local vipLevel = 0
  local modelId = 0
  local badge = {}
  local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
  local formatArgs = p.msgArgs
  table.insert(formatArgs, p.invitationUuid:tostring())
  table.insert(formatArgs, p.invitationUuid:tostring())
  table.insert(formatArgs, senderId:tostring())
  table.insert(formatArgs, p.giftType)
  local str = string.format(textRes.ChatRedGift.SendGiftText[p.giftType].Request, unpack(formatArgs))
  local content = require("netio.Octets").rawFromString(str)
  ChatSendGiftMgr.Instance():SendFakeFriendMsg(senderId, receiverId, senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, p.inviteSecs, avatarId, avatarFrameId)
end
def.static("table").OnSendGiftError = function(p)
  local tipStr = textRes.ChatRedGift.SendGiftError[p.ret]
  if tipStr then
    Toast(tipStr)
  end
end
def.static("table").OnSendGiftSuccess = function(p)
  local sendGiftCfg = ChatRedGiftUtility.GetSendGiftCfg(p.giftCfgid)
  if sendGiftCfg == nil then
    return
  end
  if textRes.ChatRedGift.SendGiftText[sendGiftCfg.type] == nil then
    return
  end
  local self = instance
  if not IsEnteredWorld() then
    if self.SGiveGiftToRoleRes == nil then
      self.SGiveGiftToRoleRes = {}
    end
    table.insert(self.SGiveGiftToRoleRes, p)
    return
  end
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local senderId = heroProp.id
  local receiverId = p.roleid
  local roleName = heroProp.name
  local gender = heroProp.gender
  local occupationId = heroProp.occupation
  local avatarId = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarId()
  local avatarFrameId = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarFrameId()
  local level = heroProp.level
  local vipLevel = 0
  local modelId = 0
  local badge = {}
  local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
  local str = string.format(textRes.ChatRedGift.SendGiftText[sendGiftCfg.type].Response, tostring(sendGiftCfg.moneyNum), textRes.Item.MoneyName[sendGiftCfg.moneyType], sendGiftCfg.name)
  local content = require("netio.Octets").rawFromString(str)
  ChatSendGiftMgr.Instance():SendFakeFriendMsg(senderId, receiverId, senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, GetServerTime(), avatarId, avatarFrameId)
end
def.static("table").OnReceiveSendMsg = function(p)
  local sendGiftCfg = ChatRedGiftUtility.GetSendGiftCfg(p.giftCfgid)
  if sendGiftCfg == nil then
    return
  end
  if textRes.ChatRedGift.SendGiftText[sendGiftCfg.type] == nil then
    return
  end
  local self = instance
  if not IsEnteredWorld() then
    if self.SSynRoleReceiveGiftRes == nil then
      self.SSynRoleReceiveGiftRes = {}
    end
    table.insert(self.SSynRoleReceiveGiftRes, p)
    return
  end
  local senderId = p.roleInfo.roleId
  local receiverId = GetMyRoleID()
  local roleName = p.roleInfo.roleName
  local gender = p.roleInfo.gender
  local occupationId = p.roleInfo.occupationId
  local avatarId = p.roleInfo.avatarid
  local avatarFrameId = p.roleInfo.avatar_frame_id
  local level = p.roleInfo.level
  local vipLevel = 0
  local modelId = 0
  local badge = {}
  local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
  local sendGiftCfg = ChatRedGiftUtility.GetSendGiftCfg(p.giftCfgid)
  local str = string.format(textRes.ChatRedGift.SendGiftText[sendGiftCfg.type].Response, tostring(sendGiftCfg.moneyNum), textRes.Item.MoneyName[sendGiftCfg.moneyType], sendGiftCfg.name)
  local content = require("netio.Octets").rawFromString(str)
  ChatSendGiftMgr.Instance():SendFakeFriendMsg(senderId, receiverId, senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, p.receiveSecs, avatarId, avatarFrameId)
  local tip = string.format(textRes.ChatRedGift[102], roleName, tostring(sendGiftCfg.moneyNum), textRes.Item.MoneyName[sendGiftCfg.moneyType], sendGiftCfg.name)
  Toast(tip)
end
def.method("table").onMainUIReady = function(self, param)
  if self.SSynGiftInvitationToRoleMsg then
    for k, v in ipairs(self.SSynGiftInvitationToRoleMsg) do
      ChatSendGiftMgr.OnReceiveGiftMsg(v)
    end
    self.SSynGiftInvitationToRoleMsg = nil
  end
  if self.SSynGiftInvitationToSelfMsg then
    for k, v in ipairs(self.SSynGiftInvitationToSelfMsg) do
      ChatSendGiftMgr.OnSendGiftMsg(v)
    end
    self.SSynGiftInvitationToSelfMsg = nil
  end
  if self.SGiveGiftToRoleRes then
    for k, v in ipairs(self.SGiveGiftToRoleRes) do
      ChatSendGiftMgr.OnSendGiftSuccess(v)
    end
    self.SGiveGiftToRoleRes = nil
  end
  if self.SSynRoleReceiveGiftRes then
    for k, v in ipairs(self.SSynRoleReceiveGiftRes) do
      ChatSendGiftMgr.OnReceiveSendMsg(v)
    end
    self.SSynRoleReceiveGiftRes = nil
  end
end
def.method("table").OnClickSendBtn = function(self, param)
  local id = param.id
  if string.sub(id, 1, 9) == "sendgift_" then
    do
      local strs = string.split(id, "_")
      local uuid = Int64.new(strs[2])
      local roleId = Int64.new(strs[3])
      if roleId == GetMyRoleID() then
        Toast(textRes.ChatRedGift[103])
        return
      end
      local giftType = tonumber(strs[4])
      local gifts = ChatRedGiftUtility.GetSendGiftByType(giftType)
      require("Main.ChatRedGift.ui.SendGiftDlg").ShowSendGift(gifts, function(sel)
        local gift = gifts[sel]
        if gift then
          self:ConfirmSendGift(roleId, uuid, gift.id)
        end
      end)
    end
  end
end
def.method("userdata", "userdata", "userdata", "string", "number", "number", "number", "number", "number", "table", "number", "userdata", "number", "number", "number").SendFakeFriendMsg = function(self, senderId, receiverId, roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, time, avatarId, avatarFrameId)
  local SChatToSomeOne = require("netio.protocol.mzm.gsp.chat.SChatToSomeOne")
  local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
  local myRoleId = GetMyRoleID()
  local chatCnt = ChatContent.new(roleId, roleName, gender, occupationId, avatarId, avatarFrameId, level, vipLevel, modelId, badge, contentType, content, 0, Int64.new(time) * 1000)
  local chatPrivate = SChatToSomeOne.new(chatCnt, senderId, receiverId)
  require("Main.Chat.ChatModule").OnPrivateChat(chatPrivate)
end
def.method("userdata", "userdata", "number").ConfirmSendGift = function(self, roleId, uuid, giftId)
  local sendGiftCfg = ChatRedGiftUtility.GetSendGiftCfg(giftId)
  local str = string.format(textRes.ChatRedGift[101], tostring(sendGiftCfg.moneyNum), textRes.Item.MoneyName[sendGiftCfg.moneyType], sendGiftCfg.name)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Marriage[46], str, function(select)
    if select == 1 then
      self:SendGift(roleId, uuid, giftId)
    end
  end, nil)
end
def.method("userdata", "userdata", "number").SendGift = function(self, roleId, uuid, giftId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gift.CGiveGiftToRoleReq").new(roleId, uuid, giftId))
end
ChatSendGiftMgr.Commit()
return ChatSendGiftMgr
