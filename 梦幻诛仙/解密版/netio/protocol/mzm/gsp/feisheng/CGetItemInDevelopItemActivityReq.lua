local CGetItemInDevelopItemActivityReq = class("CGetItemInDevelopItemActivityReq")
CGetItemInDevelopItemActivityReq.TYPEID = 12614160
function CGetItemInDevelopItemActivityReq:ctor(activity_cfg_id)
  self.id = 12614160
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetItemInDevelopItemActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetItemInDevelopItemActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetItemInDevelopItemActivityReq:sizepolicy(size)
  return size <= 65535
end
return CGetItemInDevelopItemActivityReq
