local AddictionControl = class("AddictionControl")
AddictionControl.TYPEID = 556
function AddictionControl:ctor(zoneid, userid, rate, msg, data)
  self.id = 556
  self.zoneid = zoneid or nil
  self.userid = userid or nil
  self.rate = rate or nil
  self.msg = msg or nil
  self.data = data or {}
end
function AddictionControl:marshal(os)
  os:marshalInt32(self.zoneid)
  os:marshalOctets(self.userid)
  os:marshalInt32(self.rate)
  os:marshalInt32(self.msg)
  os:marshalCompactUInt32(table.getn(self.data))
  for _, v in ipairs(self.data) do
    v:marshal(os)
  end
end
function AddictionControl:unmarshal(os)
  self.zoneid = os:unmarshalInt32()
  self.userid = os:unmarshalOctets()
  self.rate = os:unmarshalInt32()
  self.msg = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.gnet.GPair")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.data, v)
  end
end
function AddictionControl:sizepolicy(size)
  return size <= 65535
end
return AddictionControl
