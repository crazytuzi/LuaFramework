local SWantedRoleError = class("SWantedRoleError")
SWantedRoleError.TYPEID = 12620299
SWantedRoleError.ROLE_IN_MAP = 1
SWantedRoleError.ROLE_IN_FIGHT = 2
SWantedRoleError.MONEY_NOT_ENOUGH = 3
SWantedRoleError.WANTED_COUNT_MAX = 4
SWantedRoleError.ROLE_OFFLINE = 5
SWantedRoleError.ROLE_CAN_NOT_BE_WANTED = 6
SWantedRoleError.ROLE_IS_HONGMING = 7
SWantedRoleError.ROLE_LEVEL_LOW = 8
SWantedRoleError.ROLE_STATUS_CAN_NOT_BE_WANTED = 9
function SWantedRoleError:ctor(errorCode, roleName, params)
  self.id = 12620299
  self.errorCode = errorCode or nil
  self.roleName = roleName or nil
  self.params = params or {}
end
function SWantedRoleError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalOctets(self.roleName)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalOctets(v)
  end
end
function SWantedRoleError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.roleName = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.params, v)
  end
end
function SWantedRoleError:sizepolicy(size)
  return size <= 65535
end
return SWantedRoleError
