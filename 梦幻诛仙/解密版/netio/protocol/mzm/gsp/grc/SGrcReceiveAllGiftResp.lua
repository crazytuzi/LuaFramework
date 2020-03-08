local SGrcReceiveAllGiftResp = class("SGrcReceiveAllGiftResp")
SGrcReceiveAllGiftResp.TYPEID = 12600331
function SGrcReceiveAllGiftResp:ctor(retcode, receive_gifts)
  self.id = 12600331
  self.retcode = retcode or nil
  self.receive_gifts = receive_gifts or {}
end
function SGrcReceiveAllGiftResp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalCompactUInt32(table.getn(self.receive_gifts))
  for _, v in ipairs(self.receive_gifts) do
    v:marshal(os)
  end
end
function SGrcReceiveAllGiftResp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.GrcReceivedGiftInfos")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.receive_gifts, v)
  end
end
function SGrcReceiveAllGiftResp:sizepolicy(size)
  return size <= 65535
end
return SGrcReceiveAllGiftResp
