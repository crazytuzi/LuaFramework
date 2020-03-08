local RebateInfo = require("netio.protocol.mzm.gsp.grc.RebateInfo")
local SGetRecallRebateSuccess = class("SGetRecallRebateSuccess")
SGetRecallRebateSuccess.TYPEID = 12600386
function SGetRecallRebateSuccess:ctor(num, rebate_info)
  self.id = 12600386
  self.num = num or nil
  self.rebate_info = rebate_info or RebateInfo.new()
end
function SGetRecallRebateSuccess:marshal(os)
  os:marshalInt32(self.num)
  self.rebate_info:marshal(os)
end
function SGetRecallRebateSuccess:unmarshal(os)
  self.num = os:unmarshalInt32()
  self.rebate_info = RebateInfo.new()
  self.rebate_info:unmarshal(os)
end
function SGetRecallRebateSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRecallRebateSuccess
