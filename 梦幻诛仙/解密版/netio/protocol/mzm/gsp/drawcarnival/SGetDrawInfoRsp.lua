local AwardWinnerInfo = require("netio.protocol.mzm.gsp.drawcarnival.AwardWinnerInfo")
local SGetDrawInfoRsp = class("SGetDrawInfoRsp")
SGetDrawInfoRsp.TYPEID = 12630025
function SGetDrawInfoRsp:ctor(award_pool_yuan_bao_count, pass_type_id2info, last_winner_info)
  self.id = 12630025
  self.award_pool_yuan_bao_count = award_pool_yuan_bao_count or nil
  self.pass_type_id2info = pass_type_id2info or {}
  self.last_winner_info = last_winner_info or AwardWinnerInfo.new()
end
function SGetDrawInfoRsp:marshal(os)
  os:marshalInt64(self.award_pool_yuan_bao_count)
  do
    local _size_ = 0
    for _, _ in pairs(self.pass_type_id2info) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.pass_type_id2info) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  self.last_winner_info:marshal(os)
end
function SGetDrawInfoRsp:unmarshal(os)
  self.award_pool_yuan_bao_count = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.drawcarnival.FreePassInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.pass_type_id2info[k] = v
  end
  self.last_winner_info = AwardWinnerInfo.new()
  self.last_winner_info:unmarshal(os)
end
function SGetDrawInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SGetDrawInfoRsp
