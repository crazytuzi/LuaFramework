local CEnterJiuXiaoRoomReq = class("CEnterJiuXiaoRoomReq")
CEnterJiuXiaoRoomReq.TYPEID = 12595460
function CEnterJiuXiaoRoomReq:ctor(activityid)
  self.id = 12595460
  self.activityid = activityid or nil
end
function CEnterJiuXiaoRoomReq:marshal(os)
  os:marshalInt32(self.activityid)
end
function CEnterJiuXiaoRoomReq:unmarshal(os)
  self.activityid = os:unmarshalInt32()
end
function CEnterJiuXiaoRoomReq:sizepolicy(size)
  return size <= 65535
end
return CEnterJiuXiaoRoomReq
