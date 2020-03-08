local SRunningInfoRes = class("SRunningInfoRes")
SRunningInfoRes.TYPEID = 12602123
function SRunningInfoRes:ctor(runningInfos, beginTime, ranks)
  self.id = 12602123
  self.runningInfos = runningInfos or {}
  self.beginTime = beginTime or nil
  self.ranks = ranks or {}
end
function SRunningInfoRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.runningInfos))
  for _, v in ipairs(self.runningInfos) do
    v:marshal(os)
  end
  os:marshalInt32(self.beginTime)
  local _size_ = 0
  for _, _ in pairs(self.ranks) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.ranks) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SRunningInfoRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gangrace.RunningInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.runningInfos, v)
  end
  self.beginTime = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.ranks[k] = v
  end
end
function SRunningInfoRes:sizepolicy(size)
  return size <= 65535
end
return SRunningInfoRes
