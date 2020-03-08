local SWantedListRsp = class("SWantedListRsp")
SWantedListRsp.TYPEID = 12620294
function SWantedListRsp:ctor(pageNo, pageTotal, wantedList)
  self.id = 12620294
  self.pageNo = pageNo or nil
  self.pageTotal = pageTotal or nil
  self.wantedList = wantedList or {}
end
function SWantedListRsp:marshal(os)
  os:marshalInt32(self.pageNo)
  os:marshalInt32(self.pageTotal)
  os:marshalCompactUInt32(table.getn(self.wantedList))
  for _, v in ipairs(self.wantedList) do
    v:marshal(os)
  end
end
function SWantedListRsp:unmarshal(os)
  self.pageNo = os:unmarshalInt32()
  self.pageTotal = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wanted.WantedRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.wantedList, v)
  end
end
function SWantedListRsp:sizepolicy(size)
  return size <= 65535
end
return SWantedListRsp
