local CSetSelfConstellationReq = class("CSetSelfConstellationReq")
CSetSelfConstellationReq.TYPEID = 12612101
function CSetSelfConstellationReq:ctor(constellation, set_times)
  self.id = 12612101
  self.constellation = constellation or nil
  self.set_times = set_times or nil
end
function CSetSelfConstellationReq:marshal(os)
  os:marshalInt32(self.constellation)
  os:marshalInt32(self.set_times)
end
function CSetSelfConstellationReq:unmarshal(os)
  self.constellation = os:unmarshalInt32()
  self.set_times = os:unmarshalInt32()
end
function CSetSelfConstellationReq:sizepolicy(size)
  return size <= 65535
end
return CSetSelfConstellationReq
