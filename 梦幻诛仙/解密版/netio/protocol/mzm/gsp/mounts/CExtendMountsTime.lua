local CExtendMountsTime = class("CExtendMountsTime")
CExtendMountsTime.TYPEID = 12606238
function CExtendMountsTime:ctor(extend_time_item_id, extend_time_item_id_num)
  self.id = 12606238
  self.extend_time_item_id = extend_time_item_id or nil
  self.extend_time_item_id_num = extend_time_item_id_num or nil
end
function CExtendMountsTime:marshal(os)
  os:marshalInt32(self.extend_time_item_id)
  os:marshalInt32(self.extend_time_item_id_num)
end
function CExtendMountsTime:unmarshal(os)
  self.extend_time_item_id = os:unmarshalInt32()
  self.extend_time_item_id_num = os:unmarshalInt32()
end
function CExtendMountsTime:sizepolicy(size)
  return size <= 65535
end
return CExtendMountsTime
