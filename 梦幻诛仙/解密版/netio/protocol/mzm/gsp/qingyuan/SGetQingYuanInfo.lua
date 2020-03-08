local SGetQingYuanInfo = class("SGetQingYuanInfo")
SGetQingYuanInfo.TYPEID = 12602881
function SGetQingYuanInfo:ctor(qing_yuan_role_list_info)
  self.id = 12602881
  self.qing_yuan_role_list_info = qing_yuan_role_list_info or {}
end
function SGetQingYuanInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.qing_yuan_role_list_info))
  for _, v in ipairs(self.qing_yuan_role_list_info) do
    v:marshal(os)
  end
end
function SGetQingYuanInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.qingyuan.QingYuanRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.qing_yuan_role_list_info, v)
  end
end
function SGetQingYuanInfo:sizepolicy(size)
  return size <= 65535
end
return SGetQingYuanInfo
