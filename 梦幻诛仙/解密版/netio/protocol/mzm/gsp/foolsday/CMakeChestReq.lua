local CMakeChestReq = class("CMakeChestReq")
CMakeChestReq.TYPEID = 12612878
function CMakeChestReq:ctor(buff_cfg_id)
  self.id = 12612878
  self.buff_cfg_id = buff_cfg_id or nil
end
function CMakeChestReq:marshal(os)
  os:marshalInt32(self.buff_cfg_id)
end
function CMakeChestReq:unmarshal(os)
  self.buff_cfg_id = os:unmarshalInt32()
end
function CMakeChestReq:sizepolicy(size)
  return size <= 65535
end
return CMakeChestReq
