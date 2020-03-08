local SJigsawStateRes = class("SJigsawStateRes")
SJigsawStateRes.TYPEID = 12598292
SJigsawStateRes.SUCCESS = 1
SJigsawStateRes.TIME_OUT = 2
SJigsawStateRes.STATE_ERROR = 3
SJigsawStateRes.FAIL = 4
SJigsawStateRes.DOING = 5
function SJigsawStateRes:ctor(rescode)
  self.id = 12598292
  self.rescode = rescode or nil
end
function SJigsawStateRes:marshal(os)
  os:marshalInt32(self.rescode)
end
function SJigsawStateRes:unmarshal(os)
  self.rescode = os:unmarshalInt32()
end
function SJigsawStateRes:sizepolicy(size)
  return size <= 65535
end
return SJigsawStateRes
