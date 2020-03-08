local MountsInfo = require("netio.protocol.mzm.gsp.mounts.MountsInfo")
local SUnlockMountsSuccess = class("SUnlockMountsSuccess")
SUnlockMountsSuccess.TYPEID = 12606216
function SUnlockMountsSuccess:ctor(mounts_id, unlock_mounts_info)
  self.id = 12606216
  self.mounts_id = mounts_id or nil
  self.unlock_mounts_info = unlock_mounts_info or MountsInfo.new()
end
function SUnlockMountsSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
  self.unlock_mounts_info:marshal(os)
end
function SUnlockMountsSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.unlock_mounts_info = MountsInfo.new()
  self.unlock_mounts_info:unmarshal(os)
end
function SUnlockMountsSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnlockMountsSuccess
