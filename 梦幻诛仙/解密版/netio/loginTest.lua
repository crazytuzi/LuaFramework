local network = require("netio.Network")
local loginTest = {}
function loginTest.Init()
  network.registerProtocol("netio.protocol.mzm.gsp.SGetRoleList", loginTest.onSGetRoleList)
  network.registerProtocol("netio.protocol.mzm.gsp.SLoginRole", loginTest.onSLoginRole)
  network.registerProtocol("netio.protocol.mzm.gsp.SCreateRole", loginTest.onSCreateRole)
  network.registerProtocol("netio.protocol.mzm.gsp.map.SEnterWorld", loginTest.onSEnterWorld)
  network.registerProtocol("netio.protocol.mzm.gsp.online.SSendServerTime", loginTest.onSSendServerTime)
end
function loginTest.onSGetRoleList(p)
  print("onSGetRoleList")
end
function loginTest.onSLoginRole(p)
  print("onSLoginRole")
end
function loginTest.onSCreateRole(p)
  print("onSCreateRole")
end
function loginTest.onSEnterWorld(p)
  print("onSEnterWorld")
end
function loginTest.onSSendServerTime(p)
  print("onSSendServerTime")
end
return loginTest
