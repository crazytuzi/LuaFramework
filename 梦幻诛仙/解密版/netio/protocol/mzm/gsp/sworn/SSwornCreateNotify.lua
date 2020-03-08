local SSwornCreateNotify = class("SSwornCreateNotify")
SSwornCreateNotify.TYPEID = 12597818
function SSwornCreateNotify:ctor(membercount, name1, name2, names)
  self.id = 12597818
  self.membercount = membercount or nil
  self.name1 = name1 or nil
  self.name2 = name2 or nil
  self.names = names or {}
end
function SSwornCreateNotify:marshal(os)
  os:marshalInt32(self.membercount)
  os:marshalString(self.name1)
  os:marshalString(self.name2)
  os:marshalCompactUInt32(table.getn(self.names))
  for _, v in ipairs(self.names) do
    os:marshalString(v)
  end
end
function SSwornCreateNotify:unmarshal(os)
  self.membercount = os:unmarshalInt32()
  self.name1 = os:unmarshalString()
  self.name2 = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.names, v)
  end
end
function SSwornCreateNotify:sizepolicy(size)
  return size <= 65535
end
return SSwornCreateNotify
