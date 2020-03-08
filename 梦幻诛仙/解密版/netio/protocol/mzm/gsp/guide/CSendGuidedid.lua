local CSendGuidedid = class("CSendGuidedid")
CSendGuidedid.TYPEID = 12594949
function CSendGuidedid:ctor(guideid, param)
  self.id = 12594949
  self.guideid = guideid or nil
  self.param = param or nil
end
function CSendGuidedid:marshal(os)
  os:marshalInt32(self.guideid)
  os:marshalInt32(self.param)
end
function CSendGuidedid:unmarshal(os)
  self.guideid = os:unmarshalInt32()
  self.param = os:unmarshalInt32()
end
function CSendGuidedid:sizepolicy(size)
  return size <= 65535
end
return CSendGuidedid
