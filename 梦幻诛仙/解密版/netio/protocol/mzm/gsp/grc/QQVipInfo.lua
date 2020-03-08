local OctetsStream = require("netio.OctetsStream")
local QQVipInfo = class("QQVipInfo")
function QQVipInfo:ctor(vip_flag, is_vip, is_year, is_luxury, level)
  self.vip_flag = vip_flag or nil
  self.is_vip = is_vip or nil
  self.is_year = is_year or nil
  self.is_luxury = is_luxury or nil
  self.level = level or nil
end
function QQVipInfo:marshal(os)
  os:marshalInt32(self.vip_flag)
  os:marshalUInt8(self.is_vip)
  os:marshalUInt8(self.is_year)
  os:marshalUInt8(self.is_luxury)
  os:marshalInt32(self.level)
end
function QQVipInfo:unmarshal(os)
  self.vip_flag = os:unmarshalInt32()
  self.is_vip = os:unmarshalUInt8()
  self.is_year = os:unmarshalUInt8()
  self.is_luxury = os:unmarshalUInt8()
  self.level = os:unmarshalInt32()
end
return QQVipInfo
