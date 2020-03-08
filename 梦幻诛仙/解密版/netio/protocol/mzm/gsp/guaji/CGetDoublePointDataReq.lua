local CGetDoublePointDataReq = class("CGetDoublePointDataReq")
CGetDoublePointDataReq.TYPEID = 12591110
function CGetDoublePointDataReq:ctor()
  self.id = 12591110
end
function CGetDoublePointDataReq:marshal(os)
end
function CGetDoublePointDataReq:unmarshal(os)
end
function CGetDoublePointDataReq:sizepolicy(size)
  return size <= 32
end
return CGetDoublePointDataReq
