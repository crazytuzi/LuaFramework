local CGetCrossBattleFinalPanelInfo = class("CGetCrossBattleFinalPanelInfo")
CGetCrossBattleFinalPanelInfo.TYPEID = 12617063
function CGetCrossBattleFinalPanelInfo:ctor(activity_cfg_id)
  self.id = 12617063
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetCrossBattleFinalPanelInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetCrossBattleFinalPanelInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetCrossBattleFinalPanelInfo:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleFinalPanelInfo
