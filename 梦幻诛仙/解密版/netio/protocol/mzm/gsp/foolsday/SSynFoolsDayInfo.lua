local SSynFoolsDayInfo = class("SSynFoolsDayInfo")
SSynFoolsDayInfo.TYPEID = 12612872
function SSynFoolsDayInfo:ctor(make_chest_num, alternative_buff_cfg_ids, refresh_time, point, has_get_title_award)
  self.id = 12612872
  self.make_chest_num = make_chest_num or nil
  self.alternative_buff_cfg_ids = alternative_buff_cfg_ids or {}
  self.refresh_time = refresh_time or nil
  self.point = point or nil
  self.has_get_title_award = has_get_title_award or nil
end
function SSynFoolsDayInfo:marshal(os)
  os:marshalInt32(self.make_chest_num)
  os:marshalCompactUInt32(table.getn(self.alternative_buff_cfg_ids))
  for _, v in ipairs(self.alternative_buff_cfg_ids) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.refresh_time)
  os:marshalInt32(self.point)
  os:marshalInt32(self.has_get_title_award)
end
function SSynFoolsDayInfo:unmarshal(os)
  self.make_chest_num = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.alternative_buff_cfg_ids, v)
  end
  self.refresh_time = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
  self.has_get_title_award = os:unmarshalInt32()
end
function SSynFoolsDayInfo:sizepolicy(size)
  return size <= 65535
end
return SSynFoolsDayInfo
