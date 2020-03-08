local CChildhoodToAdult = class("CChildhoodToAdult")
CChildhoodToAdult.TYPEID = 12609345
function CChildhoodToAdult:ctor(childid, children_cfgid)
  self.id = 12609345
  self.childid = childid or nil
  self.children_cfgid = children_cfgid or nil
end
function CChildhoodToAdult:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.children_cfgid)
end
function CChildhoodToAdult:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.children_cfgid = os:unmarshalInt32()
end
function CChildhoodToAdult:sizepolicy(size)
  return size <= 65535
end
return CChildhoodToAdult
