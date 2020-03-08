local SPayNewYearSuccess = class("SPayNewYearSuccess")
SPayNewYearSuccess.TYPEID = 12609029
function SPayNewYearSuccess:ctor(role_name, aleardy_pay_new_year_times, award_item_map)
  self.id = 12609029
  self.role_name = role_name or nil
  self.aleardy_pay_new_year_times = aleardy_pay_new_year_times or nil
  self.award_item_map = award_item_map or {}
end
function SPayNewYearSuccess:marshal(os)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.aleardy_pay_new_year_times)
  local _size_ = 0
  for _, _ in pairs(self.award_item_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.award_item_map) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SPayNewYearSuccess:unmarshal(os)
  self.role_name = os:unmarshalOctets()
  self.aleardy_pay_new_year_times = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.award_item_map[k] = v
  end
end
function SPayNewYearSuccess:sizepolicy(size)
  return size <= 65535
end
return SPayNewYearSuccess
