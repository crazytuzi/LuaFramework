local SIdipAddZeroProfit = class("SIdipAddZeroProfit")
SIdipAddZeroProfit.TYPEID = 12601091
function SIdipAddZeroProfit:ctor(unbanTime, reason)
  self.id = 12601091
  self.unbanTime = unbanTime or nil
  self.reason = reason or nil
end
function SIdipAddZeroProfit:marshal(os)
  os:marshalInt64(self.unbanTime)
  os:marshalOctets(self.reason)
end
function SIdipAddZeroProfit:unmarshal(os)
  self.unbanTime = os:unmarshalInt64()
  self.reason = os:unmarshalOctets()
end
function SIdipAddZeroProfit:sizepolicy(size)
  return size <= 65535
end
return SIdipAddZeroProfit
