local SSynMournInfo = class("SSynMournInfo")
SSynMournInfo.TYPEID = 12613383
function SSynMournInfo:ctor(mournInfos, questionTaskState, sort)
  self.id = 12613383
  self.mournInfos = mournInfos or {}
  self.questionTaskState = questionTaskState or nil
  self.sort = sort or {}
end
function SSynMournInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.mournInfos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.mournInfos) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.questionTaskState)
  os:marshalCompactUInt32(table.getn(self.sort))
  for _, v in ipairs(self.sort) do
    os:marshalInt32(v)
  end
end
function SSynMournInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.mourn.MTaskInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.mournInfos[k] = v
  end
  self.questionTaskState = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.sort, v)
  end
end
function SSynMournInfo:sizepolicy(size)
  return size <= 65535
end
return SSynMournInfo
