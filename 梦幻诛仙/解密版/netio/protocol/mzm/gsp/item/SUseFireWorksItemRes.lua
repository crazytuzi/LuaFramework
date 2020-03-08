local SUseFireWorksItemRes = class("SUseFireWorksItemRes")
SUseFireWorksItemRes.TYPEID = 12584823
function SUseFireWorksItemRes:ctor(roleid, mapcfgid, x, y, itemcfgid)
  self.id = 12584823
  self.roleid = roleid or nil
  self.mapcfgid = mapcfgid or nil
  self.x = x or nil
  self.y = y or nil
  self.itemcfgid = itemcfgid or nil
end
function SUseFireWorksItemRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.mapcfgid)
  os:marshalInt32(self.x)
  os:marshalInt32(self.y)
  os:marshalInt32(self.itemcfgid)
end
function SUseFireWorksItemRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.mapcfgid = os:unmarshalInt32()
  self.x = os:unmarshalInt32()
  self.y = os:unmarshalInt32()
  self.itemcfgid = os:unmarshalInt32()
end
function SUseFireWorksItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseFireWorksItemRes
