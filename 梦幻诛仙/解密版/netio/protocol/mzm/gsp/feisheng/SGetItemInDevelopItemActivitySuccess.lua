local SGetItemInDevelopItemActivitySuccess = class("SGetItemInDevelopItemActivitySuccess")
SGetItemInDevelopItemActivitySuccess.TYPEID = 12614150
function SGetItemInDevelopItemActivitySuccess:ctor(activity_cfg_id)
  self.id = 12614150
  self.activity_cfg_id = activity_cfg_id or nil
end
function SGetItemInDevelopItemActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SGetItemInDevelopItemActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SGetItemInDevelopItemActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SGetItemInDevelopItemActivitySuccess
