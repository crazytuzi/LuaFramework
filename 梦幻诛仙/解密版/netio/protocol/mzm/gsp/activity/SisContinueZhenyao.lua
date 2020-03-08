local SisContinueZhenyao = class("SisContinueZhenyao")
SisContinueZhenyao.TYPEID = 12587524
function SisContinueZhenyao:ctor()
  self.id = 12587524
end
function SisContinueZhenyao:marshal(os)
end
function SisContinueZhenyao:unmarshal(os)
end
function SisContinueZhenyao:sizepolicy(size)
  return size <= 65535
end
return SisContinueZhenyao
