local SRefreshTeamListRes = class("SRefreshTeamListRes")
SRefreshTeamListRes.TYPEID = 12591875
function SRefreshTeamListRes:ctor(leitaiTeamRoleList)
  self.id = 12591875
  self.leitaiTeamRoleList = leitaiTeamRoleList or {}
end
function SRefreshTeamListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.leitaiTeamRoleList))
  for _, v in ipairs(self.leitaiTeamRoleList) do
    v:marshal(os)
  end
end
function SRefreshTeamListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.leitai.LeiTaiTeamRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.leitaiTeamRoleList, v)
  end
end
function SRefreshTeamListRes:sizepolicy(size)
  return size <= 65535
end
return SRefreshTeamListRes
