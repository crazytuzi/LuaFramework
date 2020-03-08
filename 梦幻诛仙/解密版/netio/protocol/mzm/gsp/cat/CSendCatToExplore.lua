local CSendCatToExplore = class("CSendCatToExplore")
CSendCatToExplore.TYPEID = 12605708
function CSendCatToExplore:ctor()
  self.id = 12605708
end
function CSendCatToExplore:marshal(os)
end
function CSendCatToExplore:unmarshal(os)
end
function CSendCatToExplore:sizepolicy(size)
  return size <= 65535
end
return CSendCatToExplore
