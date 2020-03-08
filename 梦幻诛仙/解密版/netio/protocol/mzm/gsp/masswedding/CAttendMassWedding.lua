local CAttendMassWedding = class("CAttendMassWedding")
CAttendMassWedding.TYPEID = 12604949
function CAttendMassWedding:ctor()
  self.id = 12604949
end
function CAttendMassWedding:marshal(os)
end
function CAttendMassWedding:unmarshal(os)
end
function CAttendMassWedding:sizepolicy(size)
  return size <= 65535
end
return CAttendMassWedding
