local SDoubleItemGetNotify = class("SDoubleItemGetNotify")
SDoubleItemGetNotify.TYPEID = 12584865
function SDoubleItemGetNotify:ctor(item_trigger_list, today_trigger_times)
  self.id = 12584865
  self.item_trigger_list = item_trigger_list or {}
  self.today_trigger_times = today_trigger_times or nil
end
function SDoubleItemGetNotify:marshal(os)
  os:marshalCompactUInt32(table.getn(self.item_trigger_list))
  for _, v in ipairs(self.item_trigger_list) do
    v:marshal(os)
  end
  os:marshalInt32(self.today_trigger_times)
end
function SDoubleItemGetNotify:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.DouobleItemBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.item_trigger_list, v)
  end
  self.today_trigger_times = os:unmarshalInt32()
end
function SDoubleItemGetNotify:sizepolicy(size)
  return size <= 65535
end
return SDoubleItemGetNotify
