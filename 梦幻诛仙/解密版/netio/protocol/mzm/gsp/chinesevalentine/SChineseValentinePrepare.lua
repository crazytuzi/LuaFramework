local SChineseValentinePrepare = class("SChineseValentinePrepare")
SChineseValentinePrepare.TYPEID = 12622092
function SChineseValentinePrepare:ctor()
  self.id = 12622092
end
function SChineseValentinePrepare:marshal(os)
end
function SChineseValentinePrepare:unmarshal(os)
end
function SChineseValentinePrepare:sizepolicy(size)
  return size <= 65535
end
return SChineseValentinePrepare
