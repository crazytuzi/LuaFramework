local OctetsStream = require("netio.OctetsStream")
local FaBaoConst = class("FaBaoConst")
FaBaoConst.EQUIPED = 1
FaBaoConst.UNEQUIPED = 2
function FaBaoConst:ctor()
end
function FaBaoConst:marshal(os)
end
function FaBaoConst:unmarshal(os)
end
return FaBaoConst
