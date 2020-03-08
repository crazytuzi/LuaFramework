local SGetIndianaAwardInfoSuccess = class("SGetIndianaAwardInfoSuccess")
SGetIndianaAwardInfoSuccess.TYPEID = 12629004
function SGetIndianaAwardInfoSuccess:ctor(activity_cfg_id, turn, sortid, award_infos)
  self.id = 12629004
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
  self.sortid = sortid or nil
  self.award_infos = award_infos or {}
end
function SGetIndianaAwardInfoSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.sortid)
  os:marshalCompactUInt32(table.getn(self.award_infos))
  for _, v in ipairs(self.award_infos) do
    v:marshal(os)
  end
end
function SGetIndianaAwardInfoSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.indiana.IndianaAwardInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.award_infos, v)
  end
end
function SGetIndianaAwardInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetIndianaAwardInfoSuccess
