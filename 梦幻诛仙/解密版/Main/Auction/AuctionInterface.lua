local Lplus = require("Lplus")
local AuctionInterface = Lplus.Class("AuctionInterface")
local def = AuctionInterface.define
def.static().OpenAuctionPanel = function()
  if require("Main.Auction.AuctionModule").Instance():IsOpen(true) then
    local CommercePitchPanel = require("Main.CommerceAndPitch.ui.CommercePitchPanel")
    CommercePitchPanel.ShowNodeByState(CommercePitchPanel.StateConst.Auction)
  end
end
AuctionInterface.Commit()
return AuctionInterface
