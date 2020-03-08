local SShuffleLovesReq = class("SShuffleLovesReq")
SShuffleLovesReq.TYPEID = 12588034
function SShuffleLovesReq:ctor(partnerId, lovesToReplace)
  self.id = 12588034
  self.partnerId = partnerId or nil
  self.lovesToReplace = lovesToReplace or {}
end
function SShuffleLovesReq:marshal(os)
  os:marshalInt32(self.partnerId)
  os:marshalCompactUInt32(table.getn(self.lovesToReplace))
  for _, v in ipairs(self.lovesToReplace) do
    os:marshalInt32(v)
  end
end
function SShuffleLovesReq:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.lovesToReplace, v)
  end
end
function SShuffleLovesReq:sizepolicy(size)
  return size <= 65535
end
return SShuffleLovesReq
