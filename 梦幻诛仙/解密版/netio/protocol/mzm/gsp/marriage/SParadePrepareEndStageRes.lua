local SParadePrepareEndStageRes = class("SParadePrepareEndStageRes")
SParadePrepareEndStageRes.TYPEID = 12599859
SParadePrepareEndStageRes.SUCCESS = 1
SParadePrepareEndStageRes.OPERATOR_ERROR = 2
function SParadePrepareEndStageRes:ctor(result)
  self.id = 12599859
  self.result = result or nil
end
function SParadePrepareEndStageRes:marshal(os)
  os:marshalInt32(self.result)
end
function SParadePrepareEndStageRes:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SParadePrepareEndStageRes:sizepolicy(size)
  return size <= 65535
end
return SParadePrepareEndStageRes
