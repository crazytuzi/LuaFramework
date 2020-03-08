local SSyncMapTransferState = class("SSyncMapTransferState")
SSyncMapTransferState.TYPEID = 12590864
SSyncMapTransferState.STATE_OPEN = 0
SSyncMapTransferState.STATE_CLOSE = 1
function SSyncMapTransferState:ctor(state)
  self.id = 12590864
  self.state = state or nil
end
function SSyncMapTransferState:marshal(os)
  os:marshalInt32(self.state)
end
function SSyncMapTransferState:unmarshal(os)
  self.state = os:unmarshalInt32()
end
function SSyncMapTransferState:sizepolicy(size)
  return size <= 65535
end
return SSyncMapTransferState
