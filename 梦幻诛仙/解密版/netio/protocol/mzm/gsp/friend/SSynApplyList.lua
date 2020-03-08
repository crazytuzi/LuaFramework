local SSynApplyList = class("SSynApplyList")
SSynApplyList.TYPEID = 12587013
function SSynApplyList:ctor(applyList)
  self.id = 12587013
  self.applyList = applyList or {}
end
function SSynApplyList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.applyList))
  for _, v in ipairs(self.applyList) do
    v:marshal(os)
  end
end
function SSynApplyList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.friend.StrangerInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.applyList, v)
  end
end
function SSynApplyList:sizepolicy(size)
  return size <= 65535
end
return SSynApplyList
