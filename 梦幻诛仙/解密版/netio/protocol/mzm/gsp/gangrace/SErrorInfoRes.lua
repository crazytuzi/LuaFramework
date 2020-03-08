local SErrorInfoRes = class("SErrorInfoRes")
SErrorInfoRes.TYPEID = 12602114
SErrorInfoRes.ERROR_UNKNOWN = 0
SErrorInfoRes.ERROR_GANGID = 1
SErrorInfoRes.ERROR_VOTE_STATUS = 2
SErrorInfoRes.ERROR_VOTE_INDEXID = 3
SErrorInfoRes.ERROR_ROLE_LV = 4
SErrorInfoRes.ERROR_VOTE_COUNT = 5
SErrorInfoRes.ERROR_MONEY = 6
SErrorInfoRes.ERROR_VOTE_OVER = 7
SErrorInfoRes.ERROR_NOT_ACTIVITY = 8
function SErrorInfoRes:ctor(resultcode)
  self.id = 12602114
  self.resultcode = resultcode or nil
end
function SErrorInfoRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SErrorInfoRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SErrorInfoRes:sizepolicy(size)
  return size <= 65535
end
return SErrorInfoRes
