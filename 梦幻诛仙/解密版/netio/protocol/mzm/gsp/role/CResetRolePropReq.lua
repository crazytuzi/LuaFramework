local CResetRolePropReq = class("CResetRolePropReq")
CResetRolePropReq.TYPEID = 12585996
CResetRolePropReq.PROP_SYS_1 = 0
CResetRolePropReq.PROP_SYS_2 = 1
CResetRolePropReq.PROP_SYS_3 = 2
function CResetRolePropReq:ctor(isUseYuanBao, propSys, yuanBao)
  self.id = 12585996
  self.isUseYuanBao = isUseYuanBao or nil
  self.propSys = propSys or nil
  self.yuanBao = yuanBao or nil
end
function CResetRolePropReq:marshal(os)
  os:marshalInt32(self.isUseYuanBao)
  os:marshalInt32(self.propSys)
  os:marshalInt64(self.yuanBao)
end
function CResetRolePropReq:unmarshal(os)
  self.isUseYuanBao = os:unmarshalInt32()
  self.propSys = os:unmarshalInt32()
  self.yuanBao = os:unmarshalInt64()
end
function CResetRolePropReq:sizepolicy(size)
  return size <= 65535
end
return CResetRolePropReq
