local Lplus = require("Lplus")
local BuffData = require("Main.Buff.data.BuffData")
local CustomBuffData = Lplus.Extend(BuffData, "CustomBuffData")
local def = CustomBuffData.define
return CustomBuffData.Commit()
