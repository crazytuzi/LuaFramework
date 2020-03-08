local OctetsStream = require("netio.OctetsStream")
local FashionDressConst = class("FashionDressConst")
FashionDressConst.FOREVER = -1
FashionDressConst.NO_FASHION_DRESS = -1
function FashionDressConst:ctor()
end
function FashionDressConst:marshal(os)
end
function FashionDressConst:unmarshal(os)
end
return FashionDressConst
