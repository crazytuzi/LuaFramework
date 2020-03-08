local CGetAllWingViewReq = class("CGetAllWingViewReq")
CGetAllWingViewReq.TYPEID = 12596503
function CGetAllWingViewReq:ctor(index)
  self.id = 12596503
  self.index = index or nil
end
function CGetAllWingViewReq:marshal(os)
  os:marshalInt32(self.index)
end
function CGetAllWingViewReq:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CGetAllWingViewReq:sizepolicy(size)
  return size <= 65535
end
return CGetAllWingViewReq
