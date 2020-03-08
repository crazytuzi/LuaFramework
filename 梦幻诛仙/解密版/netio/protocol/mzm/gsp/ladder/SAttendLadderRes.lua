local SAttendLadderRes = class("SAttendLadderRes")
SAttendLadderRes.TYPEID = 12607245
function SAttendLadderRes:ctor(roleLadderInfos)
  self.id = 12607245
  self.roleLadderInfos = roleLadderInfos or {}
end
function SAttendLadderRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleLadderInfos))
  for _, v in ipairs(self.roleLadderInfos) do
    v:marshal(os)
  end
end
function SAttendLadderRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ladder.RoleLadderInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.roleLadderInfos, v)
  end
end
function SAttendLadderRes:sizepolicy(size)
  return size <= 65535
end
return SAttendLadderRes
