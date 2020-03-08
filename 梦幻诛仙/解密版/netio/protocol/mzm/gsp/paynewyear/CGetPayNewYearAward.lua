local CGetPayNewYearAward = class("CGetPayNewYearAward")
CGetPayNewYearAward.TYPEID = 12609025
function CGetPayNewYearAward:ctor()
  self.id = 12609025
end
function CGetPayNewYearAward:marshal(os)
end
function CGetPayNewYearAward:unmarshal(os)
end
function CGetPayNewYearAward:sizepolicy(size)
  return size <= 65535
end
return CGetPayNewYearAward
