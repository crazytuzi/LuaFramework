local CRestWingProperty = class("CRestWingProperty")
CRestWingProperty.TYPEID = 12596485
function CRestWingProperty:ctor(index, isUseYuanbao, clientYuanbaoNum, clientNeedYuanbaoNum)
  self.id = 12596485
  self.index = index or nil
  self.isUseYuanbao = isUseYuanbao or nil
  self.clientYuanbaoNum = clientYuanbaoNum or nil
  self.clientNeedYuanbaoNum = clientNeedYuanbaoNum or nil
end
function CRestWingProperty:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.isUseYuanbao)
  os:marshalInt64(self.clientYuanbaoNum)
  os:marshalInt32(self.clientNeedYuanbaoNum)
end
function CRestWingProperty:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.isUseYuanbao = os:unmarshalInt32()
  self.clientYuanbaoNum = os:unmarshalInt64()
  self.clientNeedYuanbaoNum = os:unmarshalInt32()
end
function CRestWingProperty:sizepolicy(size)
  return size <= 65535
end
return CRestWingProperty
