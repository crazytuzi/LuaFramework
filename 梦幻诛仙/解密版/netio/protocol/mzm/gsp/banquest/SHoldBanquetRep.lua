local SHoldBanquetRep = class("SHoldBanquetRep")
SHoldBanquetRep.TYPEID = 12605957
function SHoldBanquetRep:ctor()
  self.id = 12605957
end
function SHoldBanquetRep:marshal(os)
end
function SHoldBanquetRep:unmarshal(os)
end
function SHoldBanquetRep:sizepolicy(size)
  return size <= 65535
end
return SHoldBanquetRep
