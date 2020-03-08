local SLadderCrossMatchFailRes = class("SLadderCrossMatchFailRes")
SLadderCrossMatchFailRes.TYPEID = 12607254
SLadderCrossMatchFailRes.UNKONWN_ERROR = 0
SLadderCrossMatchFailRes.GEN_TOKEN_FAIL = 1
SLadderCrossMatchFailRes.DATA_TRANSFOR_FAIL = 2
function SLadderCrossMatchFailRes:ctor(ret)
  self.id = 12607254
  self.ret = ret or nil
end
function SLadderCrossMatchFailRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SLadderCrossMatchFailRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SLadderCrossMatchFailRes:sizepolicy(size)
  return size <= 65535
end
return SLadderCrossMatchFailRes
