local SPrisonListRsp = class("SPrisonListRsp")
SPrisonListRsp.TYPEID = 12620037
function SPrisonListRsp:ctor(pageNo, pageTotal, prisonList)
  self.id = 12620037
  self.pageNo = pageNo or nil
  self.pageTotal = pageTotal or nil
  self.prisonList = prisonList or {}
end
function SPrisonListRsp:marshal(os)
  os:marshalInt32(self.pageNo)
  os:marshalInt32(self.pageTotal)
  os:marshalCompactUInt32(table.getn(self.prisonList))
  for _, v in ipairs(self.prisonList) do
    v:marshal(os)
  end
end
function SPrisonListRsp:unmarshal(os)
  self.pageNo = os:unmarshalInt32()
  self.pageTotal = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.prison.PrisonRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.prisonList, v)
  end
end
function SPrisonListRsp:sizepolicy(size)
  return size <= 65535
end
return SPrisonListRsp
