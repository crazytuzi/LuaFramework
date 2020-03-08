local OctetsStream = require("netio.OctetsStream")
local sworninfo = class("sworninfo")
function sworninfo:ctor(swornid, name1, name2, members)
  self.swornid = swornid or nil
  self.name1 = name1 or nil
  self.name2 = name2 or nil
  self.members = members or {}
end
function sworninfo:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalString(self.name1)
  os:marshalString(self.name2)
  os:marshalCompactUInt32(table.getn(self.members))
  for _, v in ipairs(self.members) do
    v:marshal(os)
  end
end
function sworninfo:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.name1 = os:unmarshalString()
  self.name2 = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.sworn.memberinfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.members, v)
  end
end
return sworninfo
