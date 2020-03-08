local CGetCorpsHistoryReq = class("CGetCorpsHistoryReq")
CGetCorpsHistoryReq.TYPEID = 12617518
function CGetCorpsHistoryReq:ctor(corpsId, start, step)
  self.id = 12617518
  self.corpsId = corpsId or nil
  self.start = start or nil
  self.step = step or nil
end
function CGetCorpsHistoryReq:marshal(os)
  os:marshalInt64(self.corpsId)
  os:marshalInt32(self.start)
  os:marshalInt32(self.step)
end
function CGetCorpsHistoryReq:unmarshal(os)
  self.corpsId = os:unmarshalInt64()
  self.start = os:unmarshalInt32()
  self.step = os:unmarshalInt32()
end
function CGetCorpsHistoryReq:sizepolicy(size)
  return size <= 65535
end
return CGetCorpsHistoryReq
