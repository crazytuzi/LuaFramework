local SRoleGetIndianaAwardBrd = class("SRoleGetIndianaAwardBrd")
SRoleGetIndianaAwardBrd.TYPEID = 12628999
function SRoleGetIndianaAwardBrd:ctor(activity_cfg_id, turn, sortid, roleid, role_name)
  self.id = 12628999
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
  self.sortid = sortid or nil
  self.roleid = roleid or nil
  self.role_name = role_name or nil
end
function SRoleGetIndianaAwardBrd:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.sortid)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.role_name)
end
function SRoleGetIndianaAwardBrd:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
end
function SRoleGetIndianaAwardBrd:sizepolicy(size)
  return size <= 65535
end
return SRoleGetIndianaAwardBrd
