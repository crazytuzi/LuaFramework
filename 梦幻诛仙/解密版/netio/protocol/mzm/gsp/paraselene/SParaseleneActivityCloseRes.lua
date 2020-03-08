local SParaseleneActivityCloseRes = class("SParaseleneActivityCloseRes")
SParaseleneActivityCloseRes.TYPEID = 12598285
function SParaseleneActivityCloseRes:ctor(resttime)
  self.id = 12598285
  self.resttime = resttime or nil
end
function SParaseleneActivityCloseRes:marshal(os)
  os:marshalInt32(self.resttime)
end
function SParaseleneActivityCloseRes:unmarshal(os)
  self.resttime = os:unmarshalInt32()
end
function SParaseleneActivityCloseRes:sizepolicy(size)
  return size <= 65535
end
return SParaseleneActivityCloseRes
