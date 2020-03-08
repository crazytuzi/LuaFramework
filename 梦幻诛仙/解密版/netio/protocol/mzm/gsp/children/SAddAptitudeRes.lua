local SAddAptitudeRes = class("SAddAptitudeRes")
SAddAptitudeRes.TYPEID = 12609369
function SAddAptitudeRes:ctor(childrenid, aptType, aptValue, useItemCount)
  self.id = 12609369
  self.childrenid = childrenid or nil
  self.aptType = aptType or nil
  self.aptValue = aptValue or nil
  self.useItemCount = useItemCount or nil
end
function SAddAptitudeRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.aptType)
  os:marshalInt32(self.aptValue)
  os:marshalInt32(self.useItemCount)
end
function SAddAptitudeRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.aptType = os:unmarshalInt32()
  self.aptValue = os:unmarshalInt32()
  self.useItemCount = os:unmarshalInt32()
end
function SAddAptitudeRes:sizepolicy(size)
  return size <= 65535
end
return SAddAptitudeRes
