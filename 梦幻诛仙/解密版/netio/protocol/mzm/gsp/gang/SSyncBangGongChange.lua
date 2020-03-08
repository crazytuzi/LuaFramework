local SSyncBangGongChange = class("SSyncBangGongChange")
SSyncBangGongChange.TYPEID = 12589866
function SSyncBangGongChange:ctor(roleId, bangGong, HistoryBangGong, weekBangGong, add_banggong_time, weekitem_banggong_count, item_banggong_time)
  self.id = 12589866
  self.roleId = roleId or nil
  self.bangGong = bangGong or nil
  self.HistoryBangGong = HistoryBangGong or nil
  self.weekBangGong = weekBangGong or nil
  self.add_banggong_time = add_banggong_time or nil
  self.weekitem_banggong_count = weekitem_banggong_count or nil
  self.item_banggong_time = item_banggong_time or nil
end
function SSyncBangGongChange:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.bangGong)
  os:marshalInt32(self.HistoryBangGong)
  os:marshalInt32(self.weekBangGong)
  os:marshalInt64(self.add_banggong_time)
  os:marshalInt32(self.weekitem_banggong_count)
  os:marshalInt64(self.item_banggong_time)
end
function SSyncBangGongChange:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.bangGong = os:unmarshalInt32()
  self.HistoryBangGong = os:unmarshalInt32()
  self.weekBangGong = os:unmarshalInt32()
  self.add_banggong_time = os:unmarshalInt64()
  self.weekitem_banggong_count = os:unmarshalInt32()
  self.item_banggong_time = os:unmarshalInt64()
end
function SSyncBangGongChange:sizepolicy(size)
  return size <= 65535
end
return SSyncBangGongChange
