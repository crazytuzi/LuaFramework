local CGetFightData = class("CGetFightData")
CGetFightData.TYPEID = 12628250
function CGetFightData:ctor(recordid)
  self.id = 12628250
  self.recordid = recordid or nil
end
function CGetFightData:marshal(os)
  os:marshalInt64(self.recordid)
end
function CGetFightData:unmarshal(os)
  self.recordid = os:unmarshalInt64()
end
function CGetFightData:sizepolicy(size)
  return size <= 65535
end
return CGetFightData
