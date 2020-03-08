local SRomanticDanceSelect = class("SRomanticDanceSelect")
SRomanticDanceSelect.TYPEID = 12613145
function SRomanticDanceSelect:ctor(rank_num)
  self.id = 12613145
  self.rank_num = rank_num or nil
end
function SRomanticDanceSelect:marshal(os)
  os:marshalInt32(self.rank_num)
end
function SRomanticDanceSelect:unmarshal(os)
  self.rank_num = os:unmarshalInt32()
end
function SRomanticDanceSelect:sizepolicy(size)
  return size <= 65535
end
return SRomanticDanceSelect
