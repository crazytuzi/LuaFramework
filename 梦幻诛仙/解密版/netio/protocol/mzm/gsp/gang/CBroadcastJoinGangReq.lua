local CBroadcastJoinGangReq = class("CBroadcastJoinGangReq")
CBroadcastJoinGangReq.TYPEID = 12589847
function CBroadcastJoinGangReq:ctor()
  self.id = 12589847
end
function CBroadcastJoinGangReq:marshal(os)
end
function CBroadcastJoinGangReq:unmarshal(os)
end
function CBroadcastJoinGangReq:sizepolicy(size)
  return size <= 65535
end
return CBroadcastJoinGangReq
