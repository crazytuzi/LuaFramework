local CAwardFinish = class("CAwardFinish")
CAwardFinish.TYPEID = 12607493
function CAwardFinish:ctor(map_item_cfgid)
  self.id = 12607493
  self.map_item_cfgid = map_item_cfgid or nil
end
function CAwardFinish:marshal(os)
  os:marshalInt32(self.map_item_cfgid)
end
function CAwardFinish:unmarshal(os)
  self.map_item_cfgid = os:unmarshalInt32()
end
function CAwardFinish:sizepolicy(size)
  return size <= 65535
end
return CAwardFinish
