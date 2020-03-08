local SGetGeninusSeriesSuccess = class("SGetGeninusSeriesSuccess")
SGetGeninusSeriesSuccess.TYPEID = 12613889
function SGetGeninusSeriesSuccess:ctor(series, cur_series)
  self.id = 12613889
  self.series = series or {}
  self.cur_series = cur_series or nil
end
function SGetGeninusSeriesSuccess:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.series) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.series) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.cur_series)
end
function SGetGeninusSeriesSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.genius.GeniusSeriesInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.series[k] = v
  end
  self.cur_series = os:unmarshalInt32()
end
function SGetGeninusSeriesSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetGeninusSeriesSuccess
