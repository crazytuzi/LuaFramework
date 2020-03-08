local CQueryBaitanItemReq = class("CQueryBaitanItemReq")
CQueryBaitanItemReq.TYPEID = 12584991
function CQueryBaitanItemReq:ctor(pageindex, param, subtype)
  self.id = 12584991
  self.pageindex = pageindex or nil
  self.param = param or nil
  self.subtype = subtype or nil
end
function CQueryBaitanItemReq:marshal(os)
  os:marshalInt32(self.pageindex)
  os:marshalInt32(self.param)
  os:marshalInt32(self.subtype)
end
function CQueryBaitanItemReq:unmarshal(os)
  self.pageindex = os:unmarshalInt32()
  self.param = os:unmarshalInt32()
  self.subtype = os:unmarshalInt32()
end
function CQueryBaitanItemReq:sizepolicy(size)
  return size <= 65535
end
return CQueryBaitanItemReq
