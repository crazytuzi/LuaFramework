local SNotifyExpressionPlayByUseItem = class("SNotifyExpressionPlayByUseItem")
SNotifyExpressionPlayByUseItem.TYPEID = 12590954
function SNotifyExpressionPlayByUseItem:ctor(roleid, rolename, x, y, item_cfgid)
  self.id = 12590954
  self.roleid = roleid or nil
  self.rolename = rolename or nil
  self.x = x or nil
  self.y = y or nil
  self.item_cfgid = item_cfgid or nil
end
function SNotifyExpressionPlayByUseItem:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.rolename)
  os:marshalInt32(self.x)
  os:marshalInt32(self.y)
  os:marshalInt32(self.item_cfgid)
end
function SNotifyExpressionPlayByUseItem:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.rolename = os:unmarshalString()
  self.x = os:unmarshalInt32()
  self.y = os:unmarshalInt32()
  self.item_cfgid = os:unmarshalInt32()
end
function SNotifyExpressionPlayByUseItem:sizepolicy(size)
  return size <= 65535
end
return SNotifyExpressionPlayByUseItem
