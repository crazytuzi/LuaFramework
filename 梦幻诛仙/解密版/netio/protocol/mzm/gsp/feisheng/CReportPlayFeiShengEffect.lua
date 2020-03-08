local CReportPlayFeiShengEffect = class("CReportPlayFeiShengEffect")
CReportPlayFeiShengEffect.TYPEID = 12614180
function CReportPlayFeiShengEffect:ctor(activity_cfg_id)
  self.id = 12614180
  self.activity_cfg_id = activity_cfg_id or nil
end
function CReportPlayFeiShengEffect:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CReportPlayFeiShengEffect:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CReportPlayFeiShengEffect:sizepolicy(size)
  return size <= 65535
end
return CReportPlayFeiShengEffect
