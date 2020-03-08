local SLadderUnMatchErrorRes = class("SLadderUnMatchErrorRes")
SLadderUnMatchErrorRes.TYPEID = 12607243
SLadderUnMatchErrorRes.IN_CROSS_SERVER_NOW = 1
SLadderUnMatchErrorRes.UNKNOWN_ERROR = 2
SLadderUnMatchErrorRes.IN_CANCEL_MATCH_STAGE = 3
function SLadderUnMatchErrorRes:ctor(ret, args)
  self.id = 12607243
  self.ret = ret or nil
  self.args = args or {}
end
function SLadderUnMatchErrorRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SLadderUnMatchErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SLadderUnMatchErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLadderUnMatchErrorRes
