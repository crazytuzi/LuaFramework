local SSearchAdvertsFailed = class("SSearchAdvertsFailed")
SSearchAdvertsFailed.TYPEID = 12603660
function SSearchAdvertsFailed:ctor(advertType, page, retcode)
  self.id = 12603660
  self.advertType = advertType or nil
  self.page = page or nil
  self.retcode = retcode or nil
end
function SSearchAdvertsFailed:marshal(os)
  os:marshalInt32(self.advertType)
  os:marshalInt32(self.page)
  os:marshalInt32(self.retcode)
end
function SSearchAdvertsFailed:unmarshal(os)
  self.advertType = os:unmarshalInt32()
  self.page = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SSearchAdvertsFailed:sizepolicy(size)
  return size <= 65535
end
return SSearchAdvertsFailed
