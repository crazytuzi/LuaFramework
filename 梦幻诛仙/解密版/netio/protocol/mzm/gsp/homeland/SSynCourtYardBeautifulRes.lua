local SSynCourtYardBeautifulRes = class("SSynCourtYardBeautifulRes")
SSynCourtYardBeautifulRes.TYPEID = 12605516
function SSynCourtYardBeautifulRes:ctor(beautiful)
  self.id = 12605516
  self.beautiful = beautiful or nil
end
function SSynCourtYardBeautifulRes:marshal(os)
  os:marshalInt32(self.beautiful)
end
function SSynCourtYardBeautifulRes:unmarshal(os)
  self.beautiful = os:unmarshalInt32()
end
function SSynCourtYardBeautifulRes:sizepolicy(size)
  return size <= 65535
end
return SSynCourtYardBeautifulRes
