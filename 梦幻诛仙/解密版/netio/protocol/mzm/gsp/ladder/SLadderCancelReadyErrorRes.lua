local SLadderCancelReadyErrorRes = class("SLadderCancelReadyErrorRes")
SLadderCancelReadyErrorRes.TYPEID = 12607257
SLadderCancelReadyErrorRes.UNKNOWN_ERROR = 1
SLadderCancelReadyErrorRes.IN_CANCEL_MATCH_STAGE = 2
function SLadderCancelReadyErrorRes:ctor(error, args)
  self.id = 12607257
  self.error = error or nil
  self.args = args or {}
end
function SLadderCancelReadyErrorRes:marshal(os)
  os:marshalInt32(self.error)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SLadderCancelReadyErrorRes:unmarshal(os)
  self.error = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SLadderCancelReadyErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLadderCancelReadyErrorRes
