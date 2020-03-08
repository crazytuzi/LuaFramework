local SGetAuthKeyRsp = class("SGetAuthKeyRsp")
SGetAuthKeyRsp.TYPEID = 12602640
function SGetAuthKeyRsp:ctor(retcode, main_svr_id, main_svr_urls, slave_svr_id, slave_svr_urls, auth_key, expire_in)
  self.id = 12602640
  self.retcode = retcode or nil
  self.main_svr_id = main_svr_id or nil
  self.main_svr_urls = main_svr_urls or {}
  self.slave_svr_id = slave_svr_id or nil
  self.slave_svr_urls = slave_svr_urls or {}
  self.auth_key = auth_key or nil
  self.expire_in = expire_in or nil
end
function SGetAuthKeyRsp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt64(self.main_svr_id)
  os:marshalCompactUInt32(table.getn(self.main_svr_urls))
  for _, v in ipairs(self.main_svr_urls) do
    v:marshal(os)
  end
  os:marshalInt64(self.slave_svr_id)
  os:marshalCompactUInt32(table.getn(self.slave_svr_urls))
  for _, v in ipairs(self.slave_svr_urls) do
    v:marshal(os)
  end
  os:marshalOctets(self.auth_key)
  os:marshalInt32(self.expire_in)
end
function SGetAuthKeyRsp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.main_svr_id = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.apollo.ServerUrlInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.main_svr_urls, v)
  end
  self.slave_svr_id = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.apollo.ServerUrlInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.slave_svr_urls, v)
  end
  self.auth_key = os:unmarshalOctets()
  self.expire_in = os:unmarshalInt32()
end
function SGetAuthKeyRsp:sizepolicy(size)
  return size <= 65535
end
return SGetAuthKeyRsp
