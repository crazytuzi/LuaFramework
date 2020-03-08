local SGetChildGrowthDiaryInfo = class("SGetChildGrowthDiaryInfo")
SGetChildGrowthDiaryInfo.TYPEID = 12609391
function SGetChildGrowthDiaryInfo:ctor(child_id, give_birth_time, own_role_name, another_parent_name, child_hood_begin_time, adult_begin_time, growth_diary)
  self.id = 12609391
  self.child_id = child_id or nil
  self.give_birth_time = give_birth_time or nil
  self.own_role_name = own_role_name or nil
  self.another_parent_name = another_parent_name or nil
  self.child_hood_begin_time = child_hood_begin_time or nil
  self.adult_begin_time = adult_begin_time or nil
  self.growth_diary = growth_diary or {}
end
function SGetChildGrowthDiaryInfo:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalInt64(self.give_birth_time)
  os:marshalOctets(self.own_role_name)
  os:marshalOctets(self.another_parent_name)
  os:marshalInt64(self.child_hood_begin_time)
  os:marshalInt64(self.adult_begin_time)
  os:marshalCompactUInt32(table.getn(self.growth_diary))
  for _, v in ipairs(self.growth_diary) do
    v:marshal(os)
  end
end
function SGetChildGrowthDiaryInfo:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.give_birth_time = os:unmarshalInt64()
  self.own_role_name = os:unmarshalOctets()
  self.another_parent_name = os:unmarshalOctets()
  self.child_hood_begin_time = os:unmarshalInt64()
  self.adult_begin_time = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.children.GrowthInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.growth_diary, v)
  end
end
function SGetChildGrowthDiaryInfo:sizepolicy(size)
  return size <= 65535
end
return SGetChildGrowthDiaryInfo
