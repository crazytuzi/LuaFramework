local SStartBandstandSuccess = class("SStartBandstandSuccess")
SStartBandstandSuccess.TYPEID = 12627979
function SStartBandstandSuccess:ctor(activity_id, music_id, start_fragment_index, fragment_info_map, start_time)
  self.id = 12627979
  self.activity_id = activity_id or nil
  self.music_id = music_id or nil
  self.start_fragment_index = start_fragment_index or nil
  self.fragment_info_map = fragment_info_map or {}
  self.start_time = start_time or nil
end
function SStartBandstandSuccess:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.music_id)
  os:marshalInt32(self.start_fragment_index)
  do
    local _size_ = 0
    for _, _ in pairs(self.fragment_info_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.fragment_info_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.start_time)
end
function SStartBandstandSuccess:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.music_id = os:unmarshalInt32()
  self.start_fragment_index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.bandstand.FragmentInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.fragment_info_map[k] = v
  end
  self.start_time = os:unmarshalInt32()
end
function SStartBandstandSuccess:sizepolicy(size)
  return size <= 65535
end
return SStartBandstandSuccess
