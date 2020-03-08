local SSetSwornNameError = class("SSetSwornNameError")
SSetSwornNameError.TYPEID = 12597771
SSetSwornNameError.ERROR_UNKNOWN = 1
SSetSwornNameError.ERROR_NO_CAPTAIN = 2
SSetSwornNameError.ERROR_PREF_NAME = 3
SSetSwornNameError.ERROR_SUFF_NAME = 4
SSetSwornNameError.ERROR_NAME_OVERLAP = 5
function SSetSwornNameError:ctor(resultcode)
  self.id = 12597771
  self.resultcode = resultcode or nil
end
function SSetSwornNameError:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SSetSwornNameError:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SSetSwornNameError:sizepolicy(size)
  return size <= 65535
end
return SSetSwornNameError
