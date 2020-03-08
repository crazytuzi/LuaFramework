local SynCommandInfos = class("SynCommandInfos")
SynCommandInfos.TYPEID = 12594201
function SynCommandInfos:ctor(commandFriendInfos, commandEnermyInfos)
  self.id = 12594201
  self.commandFriendInfos = commandFriendInfos or {}
  self.commandEnermyInfos = commandEnermyInfos or {}
end
function SynCommandInfos:marshal(os)
  os:marshalCompactUInt32(table.getn(self.commandFriendInfos))
  for _, v in ipairs(self.commandFriendInfos) do
    os:marshalString(v)
  end
  os:marshalCompactUInt32(table.getn(self.commandEnermyInfos))
  for _, v in ipairs(self.commandEnermyInfos) do
    os:marshalString(v)
  end
end
function SynCommandInfos:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.commandFriendInfos, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.commandEnermyInfos, v)
  end
end
function SynCommandInfos:sizepolicy(size)
  return size <= 65535
end
return SynCommandInfos
