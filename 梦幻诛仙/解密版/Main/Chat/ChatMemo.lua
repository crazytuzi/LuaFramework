local Lplus = require("Lplus")
local ChatMemo = Lplus.Class("ChatMemo")
local def = ChatMemo.define
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local instance
def.static("=>", ChatMemo).Instance = function()
  if instance == nil then
    instance = ChatMemo()
    instance.memo = {}
  end
  return instance
end
def.field("table").memo = nil
def.field("string").clipBoard = ""
def.field("number").volume = 20
def.method().Clear = function(self)
  self.memo = {}
  self.clipBoard = ""
end
def.method("string").AddMemo = function(self, content)
  table.insert(self.memo, 1, content)
  if #self.memo > self.volume then
    table.remove(self.memo, #self.memo)
  end
end
def.method("=>", "table").GetMemos = function(self)
  return self.memo
end
def.method("number", "=>", "string").GetMemo = function(self, index)
  local cnt = self.memo[index]
  return cnt or ""
end
def.method("string").SetClipBoard = function(self, content)
  self.clipBoard = content
end
def.method("=>", "string").GetClipBoard = function(self)
  return self.clipBoard
end
def.method("number").CopyOneByUniqueId = function(self, unique)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local data = ChatMsgData.Instance()
  local msg = data:GetUniqueMsg(unique)
  local text
  if msg.contentType == ChatConsts.CONTENT_YY then
    text = msg.text
  elseif msg.contentType == ChatConsts.CONTENT_NORMAL then
    text = msg.content
  end
  if text then
    self:SetClipBoard(text)
  else
    warn("ChatMemo.CopyOneByUniqueId text is nil")
  end
end
ChatMemo.Commit()
return ChatMemo
