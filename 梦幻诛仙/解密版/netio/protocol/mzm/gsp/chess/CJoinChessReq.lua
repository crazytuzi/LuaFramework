local CJoinChessReq = class("CJoinChessReq")
CJoinChessReq.TYPEID = 12619035
function CJoinChessReq:ctor(activity_id)
  self.id = 12619035
  self.activity_id = activity_id or nil
end
function CJoinChessReq:marshal(os)
  os:marshalInt32(self.activity_id)
end
function CJoinChessReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
end
function CJoinChessReq:sizepolicy(size)
  return size <= 65535
end
return CJoinChessReq
