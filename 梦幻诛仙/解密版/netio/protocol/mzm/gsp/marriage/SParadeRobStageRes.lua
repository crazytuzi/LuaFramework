local SParadeRobStageRes = class("SParadeRobStageRes")
SParadeRobStageRes.TYPEID = 12599855
SParadeRobStageRes.YES = 1
SParadeRobStageRes.NO = 2
function SParadeRobStageRes:ctor(result)
  self.id = 12599855
  self.result = result or nil
end
function SParadeRobStageRes:marshal(os)
  os:marshalInt32(self.result)
end
function SParadeRobStageRes:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SParadeRobStageRes:sizepolicy(size)
  return size <= 65535
end
return SParadeRobStageRes
