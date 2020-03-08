local CChartReq = class("CChartReq")
CChartReq.TYPEID = 12596233
function CChartReq:ctor(menpai, page)
  self.id = 12596233
  self.menpai = menpai or nil
  self.page = page or nil
end
function CChartReq:marshal(os)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.page)
end
function CChartReq:unmarshal(os)
  self.menpai = os:unmarshalInt32()
  self.page = os:unmarshalInt32()
end
function CChartReq:sizepolicy(size)
  return size <= 65535
end
return CChartReq
