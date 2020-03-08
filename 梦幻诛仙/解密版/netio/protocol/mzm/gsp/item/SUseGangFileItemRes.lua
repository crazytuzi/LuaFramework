local SUseGangFileItemRes = class("SUseGangFileItemRes")
SUseGangFileItemRes.TYPEID = 12584737
function SUseGangFileItemRes:ctor(roleid, itemid, itemNum, gangMoneyNum)
  self.id = 12584737
  self.roleid = roleid or nil
  self.itemid = itemid or nil
  self.itemNum = itemNum or nil
  self.gangMoneyNum = gangMoneyNum or nil
end
function SUseGangFileItemRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemNum)
  os:marshalInt32(self.gangMoneyNum)
end
function SUseGangFileItemRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.itemid = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
  self.gangMoneyNum = os:unmarshalInt32()
end
function SUseGangFileItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseGangFileItemRes
