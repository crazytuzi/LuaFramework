local CRomanticDanceSelect = class("CRomanticDanceSelect")
CRomanticDanceSelect.TYPEID = 12613141
function CRomanticDanceSelect:ctor(rank_num)
  self.id = 12613141
  self.rank_num = rank_num or nil
end
function CRomanticDanceSelect:marshal(os)
  os:marshalInt32(self.rank_num)
end
function CRomanticDanceSelect:unmarshal(os)
  self.rank_num = os:unmarshalInt32()
end
function CRomanticDanceSelect:sizepolicy(size)
  return size <= 65535
end
return CRomanticDanceSelect
