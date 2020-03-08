local SNotifyRoleGetIndianaAward = class("SNotifyRoleGetIndianaAward")
SNotifyRoleGetIndianaAward.TYPEID = 12629006
function SNotifyRoleGetIndianaAward:ctor(activity_cfg_id, turn, sortid)
  self.id = 12629006
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
  self.sortid = sortid or nil
end
function SNotifyRoleGetIndianaAward:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.sortid)
end
function SNotifyRoleGetIndianaAward:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function SNotifyRoleGetIndianaAward:sizepolicy(size)
  return size <= 65535
end
return SNotifyRoleGetIndianaAward
