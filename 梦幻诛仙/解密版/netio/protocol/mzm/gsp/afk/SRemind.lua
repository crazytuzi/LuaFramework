local SRemind = class("SRemind")
SRemind.TYPEID = 12622337
function SRemind:ctor(afk_detect_cfg_id, confirm_timestamp)
  self.id = 12622337
  self.afk_detect_cfg_id = afk_detect_cfg_id or nil
  self.confirm_timestamp = confirm_timestamp or nil
end
function SRemind:marshal(os)
  os:marshalInt32(self.afk_detect_cfg_id)
  os:marshalInt32(self.confirm_timestamp)
end
function SRemind:unmarshal(os)
  self.afk_detect_cfg_id = os:unmarshalInt32()
  self.confirm_timestamp = os:unmarshalInt32()
end
function SRemind:sizepolicy(size)
  return size <= 65535
end
return SRemind
