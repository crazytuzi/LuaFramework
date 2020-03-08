local Lplus = require("Lplus")
local PlayerListInfoEvt = Lplus.Class("PlayerListInfoEvt")
PlayerListInfoEvt.define.field("table").msg = nil
PlayerListInfoEvt.define.static("=>", PlayerListInfoEvt).new = function()
  local obj = PlayerListInfoEvt()
  return obj
end
PlayerListInfoEvt.define.method("=>", "boolean").HasData = function(self)
  if not self.msg then
    return false
  end
  return self.msg.new_id and #self.msg.new_id > 0
end
return PlayerListInfoEvt.Commit()
