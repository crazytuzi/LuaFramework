local CReportQQVipPayInfo = class("CReportQQVipPayInfo")
CReportQQVipPayInfo.TYPEID = 12600344
function CReportQQVipPayInfo:ctor(vip_flag, is_new)
  self.id = 12600344
  self.vip_flag = vip_flag or nil
  self.is_new = is_new or nil
end
function CReportQQVipPayInfo:marshal(os)
  os:marshalInt32(self.vip_flag)
  os:marshalUInt8(self.is_new)
end
function CReportQQVipPayInfo:unmarshal(os)
  self.vip_flag = os:unmarshalInt32()
  self.is_new = os:unmarshalUInt8()
end
function CReportQQVipPayInfo:sizepolicy(size)
  return size <= 65535
end
return CReportQQVipPayInfo
