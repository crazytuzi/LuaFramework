local SSynCrossFieldMatchInfo = class("SSynCrossFieldMatchInfo")
SSynCrossFieldMatchInfo.TYPEID = 12619525
function SSynCrossFieldMatchInfo:ctor(activity_cfg_id, process)
  self.id = 12619525
  self.activity_cfg_id = activity_cfg_id or nil
  self.process = process or nil
end
function SSynCrossFieldMatchInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalUInt8(self.process)
end
function SSynCrossFieldMatchInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.process = os:unmarshalUInt8()
end
function SSynCrossFieldMatchInfo:sizepolicy(size)
  return size <= 65535
end
return SSynCrossFieldMatchInfo
