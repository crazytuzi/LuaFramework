local Lplus = require("Lplus")
local AuctionChange = Lplus.Class("AuctionChange")
AuctionChange.define.field("string").name = ""
AuctionChange.define.field("table").prtc = nil
AuctionChange.define.static("string", "table", "=>", AuctionChange).new = function(name, prtc)
  local obj = AuctionChange()
  obj.name = name
  obj.prtc = prtc
  return obj
end
return AuctionChange.Commit()
