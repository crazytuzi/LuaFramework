local SSyncLuckyStarInfo = class("SSyncLuckyStarInfo")
SSyncLuckyStarInfo.TYPEID = 12608515
function SSyncLuckyStarInfo:ctor(activity_cfg_id, award_info)
  self.id = 12608515
  self.activity_cfg_id = activity_cfg_id or nil
  self.award_info = award_info or {}
end
function SSyncLuckyStarInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalCompactUInt32(table.getn(self.award_info))
  for _, v in ipairs(self.award_info) do
    v:marshal(os)
  end
end
function SSyncLuckyStarInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.luckystar.LuckyStarAwardInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.award_info, v)
  end
end
function SSyncLuckyStarInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncLuckyStarInfo
