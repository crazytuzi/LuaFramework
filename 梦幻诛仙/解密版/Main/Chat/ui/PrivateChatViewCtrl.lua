local Lplus = require("Lplus")
local ChatViewCtrl = require("Main.Chat.ui.ChatViewCtrl")
local PrivateChatViewCtrl = Lplus.Extend(ChatViewCtrl, "PrivateChatViewCtrl")
local GUIUtils = require("GUI.GUIUtils")
local def = PrivateChatViewCtrl.define
local ECPanelBase = require("GUI.ECPanelBase")
def.field("number").lastTime = 0
def.const("number").LONGTIMEINTERVAL = 128
def.override(ECPanelBase, "userdata", "number", "function").Init = function(self, base, node, page, delegate)
  ChatViewCtrl.Init(self, base, node, page, delegate)
  self.lastTime = 0
end
def.override("table").AddMsg = function(self, msg)
  if msg.time - self.lastTime > PrivateChatViewCtrl.LONGTIMEINTERVAL then
    self:InsertTime(msg.time, false)
  end
  self.lastTime = msg.time
  ChatViewCtrl.AddMsg(self, msg)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  if msg.type == ChatMsgData.MsgType.FRIEND then
    self:UpdateChatRoleInfo(msg)
  end
end
def.override("table", "boolean").AddMsgBatch = function(self, msgs, inverse)
  if inverse then
    for i = 1, #msgs do
      local msg = msgs[i]
      if not msg.delete then
        local obj = self:_addOneMsg(msg, inverse)
        local formerTime = msgs[i + 1] and msgs[i + 1].time or 0
        if msg.time - formerTime > PrivateChatViewCtrl.LONGTIMEINTERVAL then
          local time = self:InsertTime(msg.time, inverse)
        end
      end
    end
  else
    for i = #msgs, 1, -1 do
      local msg = msgs[i]
      if not msg.delete then
        if msg.time - self.lastTime > PrivateChatViewCtrl.LONGTIMEINTERVAL then
          self:InsertTime(msg.time, inverse)
        end
        self.lastTime = msg.time
        local obj = self:_addOneMsg(msg, inverse)
      end
    end
  end
end
def.method("table").UpdateChatRoleInfo = function(self, msg)
  if self.chatContent and not self.chatContent.isnil then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local myRoleId = heroProp.id
    local childCount = self.chatContent:get_childCount()
    for i = 0, childCount - 1 do
      do
        local childItem = self.chatContent:GetChild(i)
        local childName = childItem.name
        local function updateLevel()
          local headImg = childItem:FindChildByPrefix("Img_Head_")
          if headImg and not headImg.isnil then
            local levelLabel = headImg:FindDirect("Label_Lv"):GetComponent("UILabel")
            levelLabel:set_text(msg.level)
            local avatarId = msg.avatarId
            if avatarId then
              SetAvatarIcon(headImg, avatarId)
            else
              avatarId = require("Main.Avatar.AvatarInterface").Instance():getDefaultAvatarId(msg.occupationId, msg.gender)
              SetAvatarIcon(headImg, avatarId)
            end
          end
        end
        if myRoleId == msg.roleId then
          if "R_Unique_" == string.sub(childName, 1, 9) then
            updateLevel()
          end
        elseif "L_Unique_" == string.sub(childName, 1, 9) then
          updateLevel()
        end
      end
    end
  end
end
PrivateChatViewCtrl.Commit()
return PrivateChatViewCtrl
