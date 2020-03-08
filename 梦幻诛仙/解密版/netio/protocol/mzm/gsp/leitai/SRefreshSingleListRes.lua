local SRefreshSingleListRes = class("SRefreshSingleListRes")
SRefreshSingleListRes.TYPEID = 12591877
function SRefreshSingleListRes:ctor(leitaiRoleList)
  self.id = 12591877
  self.leitaiRoleList = leitaiRoleList or {}
end
function SRefreshSingleListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.leitaiRoleList))
  for _, v in ipairs(self.leitaiRoleList) do
    v:marshal(os)
  end
end
function SRefreshSingleListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.leitai.LeiTaiRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.leitaiRoleList, v)
  end
end
function SRefreshSingleListRes:sizepolicy(size)
  return size <= 65535
end
return SRefreshSingleListRes
