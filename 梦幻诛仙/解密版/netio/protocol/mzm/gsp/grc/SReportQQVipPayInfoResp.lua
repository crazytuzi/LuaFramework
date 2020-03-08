local SReportQQVipPayInfoResp = class("SReportQQVipPayInfoResp")
SReportQQVipPayInfoResp.TYPEID = 12600343
function SReportQQVipPayInfoResp:ctor(retcode, vip_flag, is_new)
  self.id = 12600343
  self.retcode = retcode or nil
  self.vip_flag = vip_flag or nil
  self.is_new = is_new or nil
end
function SReportQQVipPayInfoResp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.vip_flag)
  os:marshalUInt8(self.is_new)
end
function SReportQQVipPayInfoResp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.vip_flag = os:unmarshalInt32()
  self.is_new = os:unmarshalUInt8()
end
function SReportQQVipPayInfoResp:sizepolicy(size)
  return size <= 65535
end
return SReportQQVipPayInfoResp
