local SReadMailRes = class("SReadMailRes")
SReadMailRes.TYPEID = 12592898
function SReadMailRes:ctor(mailIndex, itemList, notItemList)
  self.id = 12592898
  self.mailIndex = mailIndex or nil
  self.itemList = itemList or {}
  self.notItemList = notItemList or {}
end
function SReadMailRes:marshal(os)
  os:marshalInt32(self.mailIndex)
  os:marshalCompactUInt32(table.getn(self.itemList))
  for _, v in ipairs(self.itemList) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.notItemList))
  for _, v in ipairs(self.notItemList) do
    v:marshal(os)
  end
end
function SReadMailRes:unmarshal(os)
  self.mailIndex = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.itemList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.mail.ThingBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.notItemList, v)
  end
end
function SReadMailRes:sizepolicy(size)
  return size <= 65535
end
return SReadMailRes
