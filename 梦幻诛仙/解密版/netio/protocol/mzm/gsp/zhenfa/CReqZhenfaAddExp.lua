local CReqZhenfaAddExp = class("CReqZhenfaAddExp")
CReqZhenfaAddExp.TYPEID = 12593157
function CReqZhenfaAddExp:ctor(zhenfaId, needItemList)
  self.id = 12593157
  self.zhenfaId = zhenfaId or nil
  self.needItemList = needItemList or {}
end
function CReqZhenfaAddExp:marshal(os)
  os:marshalInt32(self.zhenfaId)
  os:marshalCompactUInt32(table.getn(self.needItemList))
  for _, v in ipairs(self.needItemList) do
    v:marshal(os)
  end
end
function CReqZhenfaAddExp:unmarshal(os)
  self.zhenfaId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.zhenfa.NeedItemBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.needItemList, v)
  end
end
function CReqZhenfaAddExp:sizepolicy(size)
  return size <= 65535
end
return CReqZhenfaAddExp
