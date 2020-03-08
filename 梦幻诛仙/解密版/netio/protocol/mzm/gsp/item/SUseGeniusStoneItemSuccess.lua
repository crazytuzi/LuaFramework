local SUseGeniusStoneItemSuccess = class("SUseGeniusStoneItemSuccess")
SUseGeniusStoneItemSuccess.TYPEID = 12584869
function SUseGeniusStoneItemSuccess:ctor(item_cfgid, used_num)
  self.id = 12584869
  self.item_cfgid = item_cfgid or nil
  self.used_num = used_num or nil
end
function SUseGeniusStoneItemSuccess:marshal(os)
  os:marshalInt32(self.item_cfgid)
  os:marshalInt32(self.used_num)
end
function SUseGeniusStoneItemSuccess:unmarshal(os)
  self.item_cfgid = os:unmarshalInt32()
  self.used_num = os:unmarshalInt32()
end
function SUseGeniusStoneItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseGeniusStoneItemSuccess
