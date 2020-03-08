local SBrdAllLottoResult = class("SBrdAllLottoResult")
SBrdAllLottoResult.TYPEID = 12626950
function SBrdAllLottoResult:ctor(activity_cfg_id, turn, award_role_infos)
  self.id = 12626950
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
  self.award_role_infos = award_role_infos or {}
end
function SBrdAllLottoResult:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
  os:marshalCompactUInt32(table.getn(self.award_role_infos))
  for _, v in ipairs(self.award_role_infos) do
    v:marshal(os)
  end
end
function SBrdAllLottoResult:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.alllotto.RoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.award_role_infos, v)
  end
end
function SBrdAllLottoResult:sizepolicy(size)
  return size <= 65535
end
return SBrdAllLottoResult
