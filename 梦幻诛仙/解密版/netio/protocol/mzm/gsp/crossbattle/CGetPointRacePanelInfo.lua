local CGetPointRacePanelInfo = class("CGetPointRacePanelInfo")
CGetPointRacePanelInfo.TYPEID = 12617048
function CGetPointRacePanelInfo:ctor(activity_cfg_id, index)
  self.id = 12617048
  self.activity_cfg_id = activity_cfg_id or nil
  self.index = index or nil
end
function CGetPointRacePanelInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.index)
end
function CGetPointRacePanelInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function CGetPointRacePanelInfo:sizepolicy(size)
  return size <= 65535
end
return CGetPointRacePanelInfo
