local CStartBandstandReq = class("CStartBandstandReq")
CStartBandstandReq.TYPEID = 12627971
function CStartBandstandReq:ctor(activity_id)
  self.id = 12627971
  self.activity_id = activity_id or nil
end
function CStartBandstandReq:marshal(os)
  os:marshalInt32(self.activity_id)
end
function CStartBandstandReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
end
function CStartBandstandReq:sizepolicy(size)
  return size <= 65535
end
return CStartBandstandReq
