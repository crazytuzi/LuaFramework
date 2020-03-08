local CWinTimesAwardReq = class("CWinTimesAwardReq")
CWinTimesAwardReq.TYPEID = 12596749
function CWinTimesAwardReq:ctor(index)
  self.id = 12596749
  self.index = index or nil
end
function CWinTimesAwardReq:marshal(os)
  os:marshalInt32(self.index)
end
function CWinTimesAwardReq:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CWinTimesAwardReq:sizepolicy(size)
  return size <= 65535
end
return CWinTimesAwardReq
