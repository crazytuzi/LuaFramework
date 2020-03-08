local Observer = require("netio.protocol.mzm.gsp.fight.Observer")
local SSynAddObserver = class("SSynAddObserver")
SSynAddObserver.TYPEID = 12594186
function SSynAddObserver:ctor(observer)
  self.id = 12594186
  self.observer = observer or Observer.new()
end
function SSynAddObserver:marshal(os)
  self.observer:marshal(os)
end
function SSynAddObserver:unmarshal(os)
  self.observer = Observer.new()
  self.observer:unmarshal(os)
end
function SSynAddObserver:sizepolicy(size)
  return size <= 65535
end
return SSynAddObserver
