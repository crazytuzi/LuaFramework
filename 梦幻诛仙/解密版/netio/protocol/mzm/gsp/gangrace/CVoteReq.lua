local CVoteReq = class("CVoteReq")
CVoteReq.TYPEID = 12602119
function CVoteReq:ctor(playerIdx, voteCount)
  self.id = 12602119
  self.playerIdx = playerIdx or nil
  self.voteCount = voteCount or nil
end
function CVoteReq:marshal(os)
  os:marshalInt32(self.playerIdx)
  os:marshalInt32(self.voteCount)
end
function CVoteReq:unmarshal(os)
  self.playerIdx = os:unmarshalInt32()
  self.voteCount = os:unmarshalInt32()
end
function CVoteReq:sizepolicy(size)
  return size <= 65535
end
return CVoteReq
