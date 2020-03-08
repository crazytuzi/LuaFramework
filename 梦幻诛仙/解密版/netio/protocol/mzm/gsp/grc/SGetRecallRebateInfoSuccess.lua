local RebateInfo = require("netio.protocol.mzm.gsp.grc.RebateInfo")
local SGetRecallRebateInfoSuccess = class("SGetRecallRebateInfoSuccess")
SGetRecallRebateInfoSuccess.TYPEID = 12600382
function SGetRecallRebateInfoSuccess:ctor(rebate_info)
  self.id = 12600382
  self.rebate_info = rebate_info or RebateInfo.new()
end
function SGetRecallRebateInfoSuccess:marshal(os)
  self.rebate_info:marshal(os)
end
function SGetRecallRebateInfoSuccess:unmarshal(os)
  self.rebate_info = RebateInfo.new()
  self.rebate_info:unmarshal(os)
end
function SGetRecallRebateInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRecallRebateInfoSuccess
