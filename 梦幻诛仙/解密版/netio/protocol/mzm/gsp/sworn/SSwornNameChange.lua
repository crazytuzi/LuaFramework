local SSwornNameChange = class("SSwornNameChange")
SSwornNameChange.TYPEID = 12597799
function SSwornNameChange:ctor(swornid, name1, name2)
  self.id = 12597799
  self.swornid = swornid or nil
  self.name1 = name1 or nil
  self.name2 = name2 or nil
end
function SSwornNameChange:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalString(self.name1)
  os:marshalString(self.name2)
end
function SSwornNameChange:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.name1 = os:unmarshalString()
  self.name2 = os:unmarshalString()
end
function SSwornNameChange:sizepolicy(size)
  return size <= 65535
end
return SSwornNameChange
