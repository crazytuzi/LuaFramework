local CGetChestMakerName = class("CGetChestMakerName")
CGetChestMakerName.TYPEID = 12612879
function CGetChestMakerName:ctor(makerid)
  self.id = 12612879
  self.makerid = makerid or nil
end
function CGetChestMakerName:marshal(os)
  os:marshalInt64(self.makerid)
end
function CGetChestMakerName:unmarshal(os)
  self.makerid = os:unmarshalInt64()
end
function CGetChestMakerName:sizepolicy(size)
  return size <= 65535
end
return CGetChestMakerName
