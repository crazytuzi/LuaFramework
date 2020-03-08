local Lplus = require("Lplus")
local NationShutupInfoEvt = Lplus.Class("NationShutupInfoEvt")
NationShutupInfoEvt.define.field("table").shutupinfo = nil
NationShutupInfoEvt.define.field("boolean").isreply = false
NationShutupInfoEvt.define.static("table", "boolean", "=>", NationShutupInfoEvt).new = function(shutupinfo, reply)
  local obj = NationShutupInfoEvt()
  obj.shutupinfo = shutupinfo
  obj.isreply = reply
  return obj
end
return NationShutupInfoEvt.Commit()
