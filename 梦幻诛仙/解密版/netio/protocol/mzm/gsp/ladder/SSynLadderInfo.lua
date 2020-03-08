local SSynLadderInfo = class("SSynLadderInfo")
SSynLadderInfo.TYPEID = 12607247
function SSynLadderInfo:ctor(roleLadderLoginInfos)
  self.id = 12607247
  self.roleLadderLoginInfos = roleLadderLoginInfos or {}
end
function SSynLadderInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleLadderLoginInfos))
  for _, v in ipairs(self.roleLadderLoginInfos) do
    v:marshal(os)
  end
end
function SSynLadderInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ladder.RoleLadderLoginInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.roleLadderLoginInfos, v)
  end
end
function SSynLadderInfo:sizepolicy(size)
  return size <= 65535
end
return SSynLadderInfo
