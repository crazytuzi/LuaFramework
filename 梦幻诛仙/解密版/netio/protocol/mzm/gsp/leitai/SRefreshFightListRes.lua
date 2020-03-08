local SRefreshFightListRes = class("SRefreshFightListRes")
SRefreshFightListRes.TYPEID = 12591880
function SRefreshFightListRes:ctor(leitaiFightInfoList)
  self.id = 12591880
  self.leitaiFightInfoList = leitaiFightInfoList or {}
end
function SRefreshFightListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.leitaiFightInfoList))
  for _, v in ipairs(self.leitaiFightInfoList) do
    v:marshal(os)
  end
end
function SRefreshFightListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.leitai.LeiTaiFightInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.leitaiFightInfoList, v)
  end
end
function SRefreshFightListRes:sizepolicy(size)
  return size <= 65535
end
return SRefreshFightListRes
