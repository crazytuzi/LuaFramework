local CUnlockAxeActivityReq = class("CUnlockAxeActivityReq")
CUnlockAxeActivityReq.TYPEID = 12614919
function CUnlockAxeActivityReq:ctor(activity_cfg_id)
  self.id = 12614919
  self.activity_cfg_id = activity_cfg_id or nil
end
function CUnlockAxeActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CUnlockAxeActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CUnlockAxeActivityReq:sizepolicy(size)
  return size <= 65535
end
return CUnlockAxeActivityReq
