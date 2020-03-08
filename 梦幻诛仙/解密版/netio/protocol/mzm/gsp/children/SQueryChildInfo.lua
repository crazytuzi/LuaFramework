local ChildBean = require("netio.protocol.mzm.gsp.children.ChildBean")
local SQueryChildInfo = class("SQueryChildInfo")
SQueryChildInfo.TYPEID = 12609395
function SQueryChildInfo:ctor(child_id, child_give_birth_time, parents_name_list, child_bean)
  self.id = 12609395
  self.child_id = child_id or nil
  self.child_give_birth_time = child_give_birth_time or nil
  self.parents_name_list = parents_name_list or {}
  self.child_bean = child_bean or ChildBean.new()
end
function SQueryChildInfo:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalInt32(self.child_give_birth_time)
  os:marshalCompactUInt32(table.getn(self.parents_name_list))
  for _, v in ipairs(self.parents_name_list) do
    os:marshalOctets(v)
  end
  self.child_bean:marshal(os)
end
function SQueryChildInfo:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.child_give_birth_time = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.parents_name_list, v)
  end
  self.child_bean = ChildBean.new()
  self.child_bean:unmarshal(os)
end
function SQueryChildInfo:sizepolicy(size)
  return size <= 65535
end
return SQueryChildInfo
