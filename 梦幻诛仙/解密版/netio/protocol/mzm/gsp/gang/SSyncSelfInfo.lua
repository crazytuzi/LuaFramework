local SSyncSelfInfo = class("SSyncSelfInfo")
SSyncSelfInfo.TYPEID = 12589979
function SSyncSelfInfo:ctor(read_announcement_timestamp, redeemBangGong, get_fuli_timestamp, have_mifang_timestamp, sign_timestamp, signStr, yuan_bao_redeem_bang_gong)
  self.id = 12589979
  self.read_announcement_timestamp = read_announcement_timestamp or nil
  self.redeemBangGong = redeemBangGong or nil
  self.get_fuli_timestamp = get_fuli_timestamp or nil
  self.have_mifang_timestamp = have_mifang_timestamp or nil
  self.sign_timestamp = sign_timestamp or nil
  self.signStr = signStr or nil
  self.yuan_bao_redeem_bang_gong = yuan_bao_redeem_bang_gong or nil
end
function SSyncSelfInfo:marshal(os)
  os:marshalInt64(self.read_announcement_timestamp)
  os:marshalInt32(self.redeemBangGong)
  os:marshalInt64(self.get_fuli_timestamp)
  os:marshalInt64(self.have_mifang_timestamp)
  os:marshalInt64(self.sign_timestamp)
  os:marshalString(self.signStr)
  os:marshalInt32(self.yuan_bao_redeem_bang_gong)
end
function SSyncSelfInfo:unmarshal(os)
  self.read_announcement_timestamp = os:unmarshalInt64()
  self.redeemBangGong = os:unmarshalInt32()
  self.get_fuli_timestamp = os:unmarshalInt64()
  self.have_mifang_timestamp = os:unmarshalInt64()
  self.sign_timestamp = os:unmarshalInt64()
  self.signStr = os:unmarshalString()
  self.yuan_bao_redeem_bang_gong = os:unmarshalInt32()
end
function SSyncSelfInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncSelfInfo
