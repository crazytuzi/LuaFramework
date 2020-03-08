local SGetClassMateApprenticeInfo = class("SGetClassMateApprenticeInfo")
SGetClassMateApprenticeInfo.TYPEID = 12601625
function SGetClassMateApprenticeInfo:ctor(chuShiClassMateListInfo, nowClassMateListInfo, classMateSize)
  self.id = 12601625
  self.chuShiClassMateListInfo = chuShiClassMateListInfo or {}
  self.nowClassMateListInfo = nowClassMateListInfo or {}
  self.classMateSize = classMateSize or nil
end
function SGetClassMateApprenticeInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.chuShiClassMateListInfo))
  for _, v in ipairs(self.chuShiClassMateListInfo) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.nowClassMateListInfo))
  for _, v in ipairs(self.nowClassMateListInfo) do
    v:marshal(os)
  end
  os:marshalInt32(self.classMateSize)
end
function SGetClassMateApprenticeInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.chuShiClassMateListInfo, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.nowClassMateListInfo, v)
  end
  self.classMateSize = os:unmarshalInt32()
end
function SGetClassMateApprenticeInfo:sizepolicy(size)
  return size <= 65535
end
return SGetClassMateApprenticeInfo
