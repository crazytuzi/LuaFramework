local SSynLevelGuideInfo = class("SSynLevelGuideInfo")
SSynLevelGuideInfo.TYPEID = 12596996
function SSynLevelGuideInfo:ctor(targets, notAwardTargets, handUpTargets)
  self.id = 12596996
  self.targets = targets or {}
  self.notAwardTargets = notAwardTargets or {}
  self.handUpTargets = handUpTargets or {}
end
function SSynLevelGuideInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.targets) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.targets) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalCompactUInt32(table.getn(self.notAwardTargets))
  for _, v in ipairs(self.notAwardTargets) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.handUpTargets))
  for _, v in ipairs(self.handUpTargets) do
    os:marshalInt32(v)
  end
end
function SSynLevelGuideInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.grow.LevelGuideInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.targets[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.notAwardTargets, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.handUpTargets, v)
  end
end
function SSynLevelGuideInfo:sizepolicy(size)
  return size <= 65535
end
return SSynLevelGuideInfo
