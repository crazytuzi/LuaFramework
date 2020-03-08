local MountsInfo = require("netio.protocol.mzm.gsp.mounts.MountsInfo")
local SMountsCostItemRankUpSuccess = class("SMountsCostItemRankUpSuccess")
SMountsCostItemRankUpSuccess.TYPEID = 12606243
function SMountsCostItemRankUpSuccess:ctor(mounts_id, rank_up_mounts_info)
  self.id = 12606243
  self.mounts_id = mounts_id or nil
  self.rank_up_mounts_info = rank_up_mounts_info or MountsInfo.new()
end
function SMountsCostItemRankUpSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
  self.rank_up_mounts_info:marshal(os)
end
function SMountsCostItemRankUpSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.rank_up_mounts_info = MountsInfo.new()
  self.rank_up_mounts_info:unmarshal(os)
end
function SMountsCostItemRankUpSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsCostItemRankUpSuccess
