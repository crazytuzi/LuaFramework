local CGetGeninusSeries = class("CGetGeninusSeries")
CGetGeninusSeries.TYPEID = 12613898
function CGetGeninusSeries:ctor()
  self.id = 12613898
end
function CGetGeninusSeries:marshal(os)
end
function CGetGeninusSeries:unmarshal(os)
end
function CGetGeninusSeries:sizepolicy(size)
  return size <= 65535
end
return CGetGeninusSeries
