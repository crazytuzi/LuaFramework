local SItemClickRemoveSuccess = class("SItemClickRemoveSuccess")
SItemClickRemoveSuccess.TYPEID = 12584862
function SItemClickRemoveSuccess:ctor(item_cfg_id)
  self.id = 12584862
  self.item_cfg_id = item_cfg_id or nil
end
function SItemClickRemoveSuccess:marshal(os)
  os:marshalInt32(self.item_cfg_id)
end
function SItemClickRemoveSuccess:unmarshal(os)
  self.item_cfg_id = os:unmarshalInt32()
end
function SItemClickRemoveSuccess:sizepolicy(size)
  return size <= 65535
end
return SItemClickRemoveSuccess
