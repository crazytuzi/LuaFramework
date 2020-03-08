local SMemberOnlineStateChangeBrd = class("SMemberOnlineStateChangeBrd")
SMemberOnlineStateChangeBrd.TYPEID = 12605219
function SMemberOnlineStateChangeBrd:ctor(groupid, memberid, online_state, info_version)
  self.id = 12605219
  self.groupid = groupid or nil
  self.memberid = memberid or nil
  self.online_state = online_state or nil
  self.info_version = info_version or nil
end
function SMemberOnlineStateChangeBrd:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalInt64(self.memberid)
  os:marshalUInt8(self.online_state)
  os:marshalInt64(self.info_version)
end
function SMemberOnlineStateChangeBrd:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.memberid = os:unmarshalInt64()
  self.online_state = os:unmarshalUInt8()
  self.info_version = os:unmarshalInt64()
end
function SMemberOnlineStateChangeBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberOnlineStateChangeBrd
