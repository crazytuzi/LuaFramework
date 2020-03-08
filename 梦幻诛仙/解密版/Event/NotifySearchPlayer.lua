local Lplus = require("Lplus")
local NotifySearchPlayer = Lplus.Class("NotifySearchPlayer")
NotifySearchPlayer.define.field("table").result = nil
NotifySearchPlayer.define.static("table", "=>", NotifySearchPlayer).new = function(result)
  local obj = NotifySearchPlayer()
  obj.result = result
  return obj
end
NotifySearchPlayer.Commit()
return NotifySearchPlayer
