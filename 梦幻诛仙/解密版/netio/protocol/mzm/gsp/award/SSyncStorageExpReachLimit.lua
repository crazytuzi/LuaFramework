local SSyncStorageExpReachLimit = class("SSyncStorageExpReachLimit")
SSyncStorageExpReachLimit.TYPEID = 12583431
function SSyncStorageExpReachLimit:ctor()
  self.id = 12583431
end
function SSyncStorageExpReachLimit:marshal(os)
end
function SSyncStorageExpReachLimit:unmarshal(os)
end
function SSyncStorageExpReachLimit:sizepolicy(size)
  return size <= 65535
end
return SSyncStorageExpReachLimit
