local SSyncGrcReceiveGiftList = class("SSyncGrcReceiveGiftList")
SSyncGrcReceiveGiftList.TYPEID = 12600335
function SSyncGrcReceiveGiftList:ctor(total_count, page_index, user_receive_gift_times_infos, receive_gift_infos)
  self.id = 12600335
  self.total_count = total_count or nil
  self.page_index = page_index or nil
  self.user_receive_gift_times_infos = user_receive_gift_times_infos or {}
  self.receive_gift_infos = receive_gift_infos or {}
end
function SSyncGrcReceiveGiftList:marshal(os)
  os:marshalInt32(self.total_count)
  os:marshalInt32(self.page_index)
  os:marshalCompactUInt32(table.getn(self.user_receive_gift_times_infos))
  for _, v in ipairs(self.user_receive_gift_times_infos) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.receive_gift_infos))
  for _, v in ipairs(self.receive_gift_infos) do
    v:marshal(os)
  end
end
function SSyncGrcReceiveGiftList:unmarshal(os)
  self.total_count = os:unmarshalInt32()
  self.page_index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.GrcUserReceiveGiftTimesInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.user_receive_gift_times_infos, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.GrcReceiveGiftInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.receive_gift_infos, v)
  end
end
function SSyncGrcReceiveGiftList:sizepolicy(size)
  return size <= 65535
end
return SSyncGrcReceiveGiftList
