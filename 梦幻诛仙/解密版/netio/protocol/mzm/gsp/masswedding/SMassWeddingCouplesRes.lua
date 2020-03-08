local SMassWeddingCouplesRes = class("SMassWeddingCouplesRes")
SMassWeddingCouplesRes.TYPEID = 12604936
function SMassWeddingCouplesRes:ctor(blessCouples)
  self.id = 12604936
  self.blessCouples = blessCouples or {}
end
function SMassWeddingCouplesRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.blessCouples))
  for _, v in ipairs(self.blessCouples) do
    v:marshal(os)
  end
end
function SMassWeddingCouplesRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.masswedding.CoupleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.blessCouples, v)
  end
end
function SMassWeddingCouplesRes:sizepolicy(size)
  return size <= 65535
end
return SMassWeddingCouplesRes
