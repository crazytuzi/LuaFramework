local Lplus = require("Lplus")
local ChatViewCtrl = require("Main.Chat.ui.ChatViewCtrl")
local GroupChatViewCtrl = Lplus.Extend(ChatViewCtrl, "GroupChatViewCtrl")
local def = GroupChatViewCtrl.define
local ECPanelBase = require("GUI.ECPanelBase")
local ChatRedGiftData = require("Main.ChatRedGift.ChatRedGiftData")
local Vector = require("Types.Vector")
def.field("number").lastTime = 0
def.const("number").LONGTIMEINTERVAL = 128
def.override(ECPanelBase, "userdata", "number", "function").Init = function(self, base, node, page, delegate)
  ChatViewCtrl.Init(self, base, node, page, delegate)
  self.lastTime = 0
end
def.override("table").AddMsg = function(self, msg)
  if msg.time - self.lastTime > GroupChatViewCtrl.LONGTIMEINTERVAL then
    self:InsertTime(msg.time, false)
  end
  self.lastTime = msg.time
  ChatViewCtrl.AddMsg(self, msg)
end
def.override("table", "boolean").AddMsgBatch = function(self, msgs, inverse)
  if inverse then
    for i = 1, #msgs do
      local msg = msgs[i]
      if not msg.delete then
        local obj = self:_addOneMsg(msg, inverse)
        local formerTime = msgs[i + 1] and msgs[i + 1].time or 0
        if msg.time - formerTime > GroupChatViewCtrl.LONGTIMEINTERVAL then
          local time = self:InsertTime(msg.time, inverse)
        end
      end
    end
  else
    for i = #msgs, 1, -1 do
      local msg = msgs[i]
      if not msg.delete then
        if msg.time - self.lastTime > GroupChatViewCtrl.LONGTIMEINTERVAL then
          self:InsertTime(msg.time, inverse)
        end
        self.lastTime = msg.time
        local obj = self:_addOneMsg(msg, inverse)
      end
    end
  end
end
def.override().UpdateRedGiftTip = function(self)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local _redGiftInfo = ChatRedGiftData.Instance():GetNewChatRedGiftByChannelType(ChatMsgData.MsgType.GROUP, ChatMsgData.Channel.GROUP)
  if _redGiftInfo then
    warn("Has New RedBag")
    if self.redGiftTip then
      warn("Has redGiftTip")
      self.redGiftTip:SetActive(true)
      local label_redgift = self.redGiftTip:FindDirect("Label_New"):GetComponent("UILabel")
      label_redgift:set_text(string.format(textRes.ChatRedGift[20], _redGiftInfo.roleInfo.name))
      if self.announceMent.activeSelf or self.newMsgBtn.activeSelf then
        local _pos = self.announceMent.localPosition
        self.redGiftTip.localPosition = Vector.Vector3.new(_pos.x, _pos.y - 50, _pos.z)
      else
        self.redGiftTip.localPosition = self.announceMent.localPosition
      end
    end
  else
    warn("Has New RedBag")
    if self.redGiftTip then
      warn("Has redGiftTip")
      self.redGiftTip:SetActive(false)
    end
  end
end
def.override("boolean").ClickRedGfitTip = function(self, isCloseClick)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local _redGiftInfo = ChatRedGiftData.Instance():GetNewChatRedGiftByChannelType(ChatMsgData.MsgType.GROUP, ChatMsgData.Channel.GROUP)
  if isCloseClick then
    if _redGiftInfo then
      ChatRedGiftData.Instance():OpenChatRedGift(_redGiftInfo)
    end
  elseif _redGiftInfo then
    Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Get_ChatRedGiftProtocol, {
      redGiftId = _redGiftInfo.redGiftId,
      channelType = ChatMsgData.MsgType.GROUP,
      channelSubType = ChatMsgData.Channel.GROUP
    })
    ChatRedGiftData.Instance():OpenChatRedGift(_redGiftInfo)
  end
  self:UpdateRedGiftTip()
end
local pageCount = 6
def.override("=>", "number").GetClipMsgCount = function(self)
  return math.floor(pageCount / 2)
end
def.override("=>", "number").GetHalfClipMsgCount = function(self)
  return math.floor(pageCount / 4 - 1)
end
GroupChatViewCtrl.Commit()
return GroupChatViewCtrl
