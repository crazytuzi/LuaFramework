local OctetsStream = require("netio.OctetsStream")
local ItemSourceEnum = class("ItemSourceEnum")
ItemSourceEnum.SHANGHUI = 0
function ItemSourceEnum:ctor()
end
function ItemSourceEnum:marshal(os)
end
function ItemSourceEnum:unmarshal(os)
end
return ItemSourceEnum
