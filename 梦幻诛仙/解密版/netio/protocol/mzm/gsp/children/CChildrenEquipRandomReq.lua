local CChildrenEquipRandomReq = class("CChildrenEquipRandomReq")
CChildrenEquipRandomReq.TYPEID = 12609427
CChildrenEquipRandomReq.USE = 1
CChildrenEquipRandomReq.UNUSE = 2
function CChildrenEquipRandomReq:ctor(childrenid, pos, useYuanBao, useYuanBaoNum, totalYuanBaoNum)
  self.id = 12609427
  self.childrenid = childrenid or nil
  self.pos = pos or nil
  self.useYuanBao = useYuanBao or nil
  self.useYuanBaoNum = useYuanBaoNum or nil
  self.totalYuanBaoNum = totalYuanBaoNum or nil
end
function CChildrenEquipRandomReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.useYuanBao)
  os:marshalInt32(self.useYuanBaoNum)
  os:marshalInt64(self.totalYuanBaoNum)
end
function CChildrenEquipRandomReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.useYuanBao = os:unmarshalInt32()
  self.useYuanBaoNum = os:unmarshalInt32()
  self.totalYuanBaoNum = os:unmarshalInt64()
end
function CChildrenEquipRandomReq:sizepolicy(size)
  return size <= 65535
end
return CChildrenEquipRandomReq
