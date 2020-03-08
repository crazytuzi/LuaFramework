local SSignInRes = class("SSignInRes")
SSignInRes.TYPEID = 12593414
function SSignInRes:ctor(signday, signcount, fillincount, issignedtoday, currentdate, item2num, current_precious_cell_num, current_precious_cell_buff_id, is_first_box_aleardy_get)
  self.id = 12593414
  self.signday = signday or nil
  self.signcount = signcount or nil
  self.fillincount = fillincount or nil
  self.issignedtoday = issignedtoday or nil
  self.currentdate = currentdate or nil
  self.item2num = item2num or {}
  self.current_precious_cell_num = current_precious_cell_num or nil
  self.current_precious_cell_buff_id = current_precious_cell_buff_id or nil
  self.is_first_box_aleardy_get = is_first_box_aleardy_get or nil
end
function SSignInRes:marshal(os)
  os:marshalInt32(self.signday)
  os:marshalInt32(self.signcount)
  os:marshalInt32(self.fillincount)
  os:marshalInt32(self.issignedtoday)
  os:marshalInt32(self.currentdate)
  do
    local _size_ = 0
    for _, _ in pairs(self.item2num) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.item2num) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.current_precious_cell_num)
  os:marshalInt32(self.current_precious_cell_buff_id)
  os:marshalInt32(self.is_first_box_aleardy_get)
end
function SSignInRes:unmarshal(os)
  self.signday = os:unmarshalInt32()
  self.signcount = os:unmarshalInt32()
  self.fillincount = os:unmarshalInt32()
  self.issignedtoday = os:unmarshalInt32()
  self.currentdate = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item2num[k] = v
  end
  self.current_precious_cell_num = os:unmarshalInt32()
  self.current_precious_cell_buff_id = os:unmarshalInt32()
  self.is_first_box_aleardy_get = os:unmarshalInt32()
end
function SSignInRes:sizepolicy(size)
  return size <= 65535
end
return SSignInRes
