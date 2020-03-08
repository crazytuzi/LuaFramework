local SApolloEnterLargeRoomRsp = class("SApolloEnterLargeRoomRsp")
SApolloEnterLargeRoomRsp.TYPEID = 12602626
function SApolloEnterLargeRoomRsp:ctor(retcode, rsp_infos)
  self.id = 12602626
  self.retcode = retcode or nil
  self.rsp_infos = rsp_infos or {}
end
function SApolloEnterLargeRoomRsp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalCompactUInt32(table.getn(self.rsp_infos))
  for _, v in ipairs(self.rsp_infos) do
    v:marshal(os)
  end
end
function SApolloEnterLargeRoomRsp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.apollo.LargeRoomEnterRspInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rsp_infos, v)
  end
end
function SApolloEnterLargeRoomRsp:sizepolicy(size)
  return size <= 65535
end
return SApolloEnterLargeRoomRsp
