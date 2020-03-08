local SMakeChestSuccess = class("SMakeChestSuccess")
SMakeChestSuccess.TYPEID = 12612867
function SMakeChestSuccess:ctor(buff_cfg_id)
  self.id = 12612867
  self.buff_cfg_id = buff_cfg_id or nil
end
function SMakeChestSuccess:marshal(os)
  os:marshalInt32(self.buff_cfg_id)
end
function SMakeChestSuccess:unmarshal(os)
  self.buff_cfg_id = os:unmarshalInt32()
end
function SMakeChestSuccess:sizepolicy(size)
  return size <= 65535
end
return SMakeChestSuccess
