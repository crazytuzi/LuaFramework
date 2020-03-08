local SSyncNotices = class("SSyncNotices")
SSyncNotices.TYPEID = 12601102
function SSyncNotices:ctor(notices)
  self.id = 12601102
  self.notices = notices or {}
end
function SSyncNotices:marshal(os)
  os:marshalCompactUInt32(table.getn(self.notices))
  for _, v in ipairs(self.notices) do
    v:marshal(os)
  end
end
function SSyncNotices:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.idip.NoticeInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.notices, v)
  end
end
function SSyncNotices:sizepolicy(size)
  return size <= 65535
end
return SSyncNotices
