local CGetMassExpTask = class("CGetMassExpTask")
CGetMassExpTask.TYPEID = 12608259
function CGetMassExpTask:ctor()
  self.id = 12608259
end
function CGetMassExpTask:marshal(os)
end
function CGetMassExpTask:unmarshal(os)
end
function CGetMassExpTask:sizepolicy(size)
  return size <= 65535
end
return CGetMassExpTask
