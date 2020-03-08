local Lplus = require("Lplus")
local ECDebugOption = Lplus.Class("ECDebugOption")
local l_instance
do
  local def = ECDebugOption.define
  def.static("=>", ECDebugOption).Instance = function()
    return l_instance
  end
  def.field("boolean").showitemid = false
  def.field("boolean").guidelog = false
  def.field("boolean").comingsoonlog = false
  def.field("number").raisevolfactor = 12
  def.field("boolean").showautomove = false
  def.field("boolean").showchat = false
  def.field("boolean").nationwarlog = false
  def.field("boolean").cullContent = false
  def.field("boolean").chatmsgPaging = true
  def.field("boolean").auctionSafeCheck = true
  def.field("boolean").showSSlog = true
  warn("raisevolfactor ok")
end
ECDebugOption.Commit()
l_instance = ECDebugOption()
return ECDebugOption
