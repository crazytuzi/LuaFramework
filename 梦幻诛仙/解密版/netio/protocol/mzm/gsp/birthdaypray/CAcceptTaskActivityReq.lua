local CAcceptTaskActivityReq = class("CAcceptTaskActivityReq")
CAcceptTaskActivityReq.TYPEID = 12623110
function CAcceptTaskActivityReq:ctor(activity_cfg_id)
  self.id = 12623110
  self.activity_cfg_id = activity_cfg_id or nil
end
function CAcceptTaskActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CAcceptTaskActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CAcceptTaskActivityReq:sizepolicy(size)
  return size <= 65535
end
return CAcceptTaskActivityReq
