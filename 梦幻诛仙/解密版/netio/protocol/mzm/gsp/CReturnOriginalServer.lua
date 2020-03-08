local CReturnOriginalServer = class("CReturnOriginalServer")
CReturnOriginalServer.TYPEID = 12590104
function CReturnOriginalServer:ctor()
  self.id = 12590104
end
function CReturnOriginalServer:marshal(os)
end
function CReturnOriginalServer:unmarshal(os)
end
function CReturnOriginalServer:sizepolicy(size)
  return size <= 65535
end
return CReturnOriginalServer
