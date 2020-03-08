local CReplacePetSkillReq = class("CReplacePetSkillReq")
CReplacePetSkillReq.TYPEID = 12590657
function CReplacePetSkillReq:ctor(petId, isCostYuanBao, curYuanBao, costYuanBao)
  self.id = 12590657
  self.petId = petId or nil
  self.isCostYuanBao = isCostYuanBao or nil
  self.curYuanBao = curYuanBao or nil
  self.costYuanBao = costYuanBao or nil
end
function CReplacePetSkillReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.isCostYuanBao)
  os:marshalInt64(self.curYuanBao)
  os:marshalInt32(self.costYuanBao)
end
function CReplacePetSkillReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.isCostYuanBao = os:unmarshalInt32()
  self.curYuanBao = os:unmarshalInt64()
  self.costYuanBao = os:unmarshalInt32()
end
function CReplacePetSkillReq:sizepolicy(size)
  return size <= 65535
end
return CReplacePetSkillReq
