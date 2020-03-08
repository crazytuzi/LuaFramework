local Lplus = require("Lplus")
local ChatMsgData = Lplus.Class("ChatMsgData")
local def = ChatMsgData.define
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local CircleQueue = require("Main.Chat.CircleQueue")
def.const("number").MSGLIMIT = 128
def.const("table").MsgType = {
  FRIEND = 1,
  CHANNEL = 2,
  SYSTEM = 3,
  GROUP = 4
}
def.const("table").Channel = {
  NEWER = 1,
  FACTION = 2,
  TEAM = 3,
  CURRENT = 4,
  WORLD = 5,
  ACTIVITY = 6,
  LIVE = 8,
  CITY = 9,
  GROUP = 10,
  TRUMPET = 12,
  BATTLEFIELD = 13,
  FRIEND = 14
}
def.const("table").System = {
  ALL = 1,
  SYS = 2,
  HELP = 3,
  PERSONAL = 4,
  FIGHT = 5
}
def.field("table").msgData = nil
def.field("table").uniqueData = nil
local _instance
def.static("=>", ChatMsgData).Instance = function()
  if _instance == nil then
    _instance = ChatMsgData()
    _instance:Init()
  end
  return _instance
end
def.method().Init = function(self)
  self.msgData = {
    [ChatMsgData.MsgType.FRIEND] = {},
    [ChatMsgData.MsgType.CHANNEL] = {
      [ChatMsgData.Channel.NEWER] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.FACTION] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.TEAM] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.CURRENT] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.WORLD] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.ACTIVITY] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.LIVE] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.CITY] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.TRUMPET] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.BATTLEFIELD] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.Channel.FRIEND] = CircleQueue.new(ChatMsgData.MSGLIMIT)
    },
    [ChatMsgData.MsgType.SYSTEM] = {
      [ChatMsgData.System.ALL] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.System.SYS] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.System.HELP] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.System.PERSONAL] = CircleQueue.new(ChatMsgData.MSGLIMIT),
      [ChatMsgData.System.FIGHT] = CircleQueue.new(ChatMsgData.MSGLIMIT)
    },
    [ChatMsgData.MsgType.GROUP] = {}
  }
  self.uniqueData = {}
  setmetatable(self.uniqueData, {__mode = "v"})
end
def.method().Clear = function(self)
  for k, v in pairs(self.msgData[ChatMsgData.MsgType.FRIEND]) do
    for i, msg in v:Traverse() do
      if msg.unique then
        self.uniqueData[msg.unique] = nil
      end
    end
  end
  self.msgData[ChatMsgData.MsgType.FRIEND] = {}
  for k, v in pairs(self.msgData[ChatMsgData.MsgType.GROUP]) do
    for i, msg in v:Traverse() do
      if msg.unique then
        self.uniqueData[msg.unique] = nil
      end
    end
  end
  self.msgData[ChatMsgData.MsgType.GROUP] = {}
end
def.method("number", "number").InitMsg = function(self, type, id)
  if self.msgData[type][id] == nil then
    self.msgData[type][id] = CircleQueue.new(ChatMsgData.MSGLIMIT)
  end
end
def.method("number", "userdata").InitMsg64 = function(self, type, id)
  if self.msgData[type][id:tostring()] == nil then
    self.msgData[type][id:tostring()] = CircleQueue.new(ChatMsgData.MSGLIMIT)
  end
end
def.method("table").AddMsg = function(self, msg)
  if self.msgData[msg.type][msg.id] == nil then
    self.msgData[msg.type][msg.id] = CircleQueue.new(ChatMsgData.MSGLIMIT)
  end
  self.msgData[msg.type][msg.id]:In(msg)
  if msg.type == ChatMsgData.MsgType.SYSTEM then
    self.msgData[ChatMsgData.MsgType.SYSTEM][ChatMsgData.System.ALL]:In(msg)
  end
  self.uniqueData[msg.unique] = msg
end
def.method("table").AddMsg64 = function(self, msg)
  if self.msgData[msg.type][msg.id:tostring()] == nil then
    self.msgData[msg.type][msg.id:tostring()] = CircleQueue.new(ChatMsgData.MSGLIMIT)
  end
  self.msgData[msg.type][msg.id:tostring()]:In(msg)
  self.uniqueData[msg.unique] = msg
end
def.method("number", "userdata", "number", "=>", "table").GetMsg64 = function(self, type, id, count)
  if self.msgData[type][id:tostring()] == nil then
    self.msgData[type][id:tostring()] = CircleQueue.new(ChatMsgData.MSGLIMIT)
  end
  return self.msgData[type][id:tostring()]:GetList(count)
end
def.method("number", "number", "number", "=>", "table").GetMsg = function(self, type, id, count)
  if self.msgData[type][id] == nil then
    self.msgData[type][id] = CircleQueue.new(ChatMsgData.MSGLIMIT)
  end
  return self.msgData[type][id]:GetList(count)
end
def.method("number", "userdata", "number", "number", "=>", "table").GetOldMsg64 = function(self, type, id, unique, count)
  if self.msgData[type][id:tostring()] == nil then
    self.msgData[type][id:tostring()] = CircleQueue.new(ChatMsgData.MSGLIMIT)
    return {}
  end
  local msg, index = self.msgData[type][id:tostring()]:SearchOne(function(m)
    return m.unique == unique
  end)
  if msg then
    return self.msgData[type][id:tostring()]:GetBackward(index, count)
  else
    return self.msgData[type][id:tostring()]:GetList(count)
  end
end
def.method("number", "number", "number", "number", "=>", "table").GetOldMsg = function(self, type, id, unique, count)
  print("GetBackwardMsg")
  if self.msgData[type][id] == nil then
    self.msgData[type][id] = CircleQueue.new(ChatMsgData.MSGLIMIT)
    return {}
  end
  local msg, index = self.msgData[type][id]:SearchOne(function(m)
    return m.unique == unique
  end)
  if msg then
    return self.msgData[type][id]:GetBackward(index, count)
  else
    return self.msgData[type][id]:GetList(count)
  end
end
def.method("number", "number", "=>", "table").GetOneNewMsg = function(self, type, id)
  if self.msgData[type][id] == nil then
    self.msgData[type][id] = CircleQueue.new(ChatMsgData.MSGLIMIT)
  end
  return self.msgData[type][id]:GetNewOne()
end
def.method("number", "userdata", "=>", "table").GetOneNewMsg64 = function(self, type, id)
  if self.msgData[type][id:tostring()] == nil then
    self.msgData[type][id:tostring()] = CircleQueue.new(ChatMsgData.MSGLIMIT)
  end
  return self.msgData[type][id:tostring()]:GetNewOne()
end
def.method("userdata").DeleteFriendMsg64 = function(self, id)
  self.msgData[ChatMsgData.MsgType.FRIEND][id:tostring()] = nil
end
def.method("number", "userdata").ClearMsg64 = function(self, type, id)
  self.msgData[type][id:tostring()] = CircleQueue.new(ChatMsgData.MSGLIMIT)
  if ChatMsgData.MsgType.GROUP == type then
    require("Main.Chat.At.data.AtData").Instance():RemoveGroupAtMsg(id)
  end
end
def.method("number", "number").ClearMsg = function(self, type, id)
  self.msgData[type][id] = CircleQueue.new(ChatMsgData.MSGLIMIT)
end
def.method("number", "=>", "table").GetUniqueMsg = function(self, unique)
  return self.uniqueData[unique]
end
def.method("number").DeleteUniqueMsg = function(self, unique)
  if self.uniqueData[unique] then
    self.uniqueData[unique].delete = true
  end
end
def.method("userdata", "=>", "table").DeleteAllMsgFromRole = function(self, roleId)
  local uniques = {}
  for k, v in pairs(self.uniqueData) do
    if v.roleId == roleId then
      v.delete = true
      table.insert(uniques, k)
    end
  end
  return uniques
end
def.method("userdata", "=>", "table").GetRoleChatRecord = function(self, roleId)
  local msgs = {}
  for k, v in pairs(self.uniqueData) do
    if v.roleId == roleId and v.time then
      table.insert(msgs, v)
    end
  end
  table.sort(msgs, function(a, b)
    return a.time > b.time
  end)
  return msgs
end
ChatMsgData.Commit()
return ChatMsgData
