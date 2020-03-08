local SAcceptTaskActivitySuccess = class("SAcceptTaskActivitySuccess")
SAcceptTaskActivitySuccess.TYPEID = 12623109
function SAcceptTaskActivitySuccess:ctor(activity_cfg_id)
  self.id = 12623109
  self.activity_cfg_id = activity_cfg_id or nil
end
function SAcceptTaskActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SAcceptTaskActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SAcceptTaskActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SAcceptTaskActivitySuccess
