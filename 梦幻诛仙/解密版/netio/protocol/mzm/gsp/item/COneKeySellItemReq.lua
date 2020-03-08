local COneKeySellItemReq = class("COneKeySellItemReq")
COneKeySellItemReq.TYPEID = 12584813
function COneKeySellItemReq:ctor(bagid, uuid2nums)
  self.id = 12584813
  self.bagid = bagid or nil
  self.uuid2nums = uuid2nums or {}
end
function COneKeySellItemReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalCompactUInt32(table.getn(self.uuid2nums))
  for _, v in ipairs(self.uuid2nums) do
    v:marshal(os)
  end
end
function COneKeySellItemReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.Uuid2num")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.uuid2nums, v)
  end
end
function COneKeySellItemReq:sizepolicy(size)
  return size <= 65535
end
return COneKeySellItemReq
