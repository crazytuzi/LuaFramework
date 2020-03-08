local CGetCrossBattleSelectionPanelInfo = class("CGetCrossBattleSelectionPanelInfo")
CGetCrossBattleSelectionPanelInfo.TYPEID = 12616998
function CGetCrossBattleSelectionPanelInfo:ctor(activity_cfg_id)
  self.id = 12616998
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetCrossBattleSelectionPanelInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetCrossBattleSelectionPanelInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetCrossBattleSelectionPanelInfo:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleSelectionPanelInfo
