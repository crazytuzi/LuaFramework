local Location = require("netio.protocol.mzm.gsp.map.Location")
local SRoleEnterView = class("SRoleEnterView")
SRoleEnterView.TYPEID = 12590855
SRoleEnterView.KEY_PET = 1
SRoleEnterView.KEY_CHILDREN = 2
function SRoleEnterView:ctor(modelInfo, keyPointPath, direction, curPos, models, level, menPai, gender)
  self.id = 12590855
  self.modelInfo = modelInfo or nil
  self.keyPointPath = keyPointPath or {}
  self.direction = direction or nil
  self.curPos = curPos or Location.new()
  self.models = models or {}
  self.level = level or nil
  self.menPai = menPai or nil
  self.gender = gender or nil
end
function SRoleEnterView:marshal(os)
  os:marshalOctets(self.modelInfo)
  os:marshalCompactUInt32(table.getn(self.keyPointPath))
  for _, v in ipairs(self.keyPointPath) do
    v:marshal(os)
  end
  os:marshalInt32(self.direction)
  self.curPos:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.models) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.models) do
      os:marshalInt32(k)
      os:marshalOctets(v)
    end
  end
  os:marshalInt32(self.level)
  os:marshalInt32(self.menPai)
  os:marshalInt32(self.gender)
end
function SRoleEnterView:unmarshal(os)
  self.modelInfo = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.keyPointPath, v)
  end
  self.direction = os:unmarshalInt32()
  self.curPos = Location.new()
  self.curPos:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalOctets()
    self.models[k] = v
  end
  self.level = os:unmarshalInt32()
  self.menPai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
end
function SRoleEnterView:sizepolicy(size)
  return size <= 65535
end
return SRoleEnterView
