local FreePassInfo = require("netio.protocol.mzm.gsp.drawcarnival.FreePassInfo")
local SDrawError = class("SDrawError")
SDrawError.TYPEID = 12630019
SDrawError.CUT_YUAN_BAO_FAIL = 1
SDrawError.HAS_MORE_FREE_PASS = 2
SDrawError.REMOVE_ITEM_FAIL = 3
SDrawError.LAST_AWARD_NOT_RECEIVED = 4
function SDrawError:ctor(code, pass_type_id, pass_count, is_use_yuan_bao, free_pass_info)
  self.id = 12630019
  self.code = code or nil
  self.pass_type_id = pass_type_id or nil
  self.pass_count = pass_count or nil
  self.is_use_yuan_bao = is_use_yuan_bao or nil
  self.free_pass_info = free_pass_info or FreePassInfo.new()
end
function SDrawError:marshal(os)
  os:marshalInt32(self.code)
  os:marshalInt32(self.pass_type_id)
  os:marshalInt32(self.pass_count)
  os:marshalUInt8(self.is_use_yuan_bao)
  self.free_pass_info:marshal(os)
end
function SDrawError:unmarshal(os)
  self.code = os:unmarshalInt32()
  self.pass_type_id = os:unmarshalInt32()
  self.pass_count = os:unmarshalInt32()
  self.is_use_yuan_bao = os:unmarshalUInt8()
  self.free_pass_info = FreePassInfo.new()
  self.free_pass_info:unmarshal(os)
end
function SDrawError:sizepolicy(size)
  return size <= 65535
end
return SDrawError
