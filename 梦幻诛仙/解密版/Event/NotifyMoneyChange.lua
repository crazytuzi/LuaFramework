local Lplus = require("Lplus")
local NotifyMoneyChange = Lplus.Class("NotifyMoneyChange")
local def = NotifyMoneyChange.define
def.field("boolean").add = false
def.field("number").inc_type = 0
def.field("number").money_type = 0
def.field("number").location = 0
def.field("string").inc = ZeroUInt64
def.field("string").money = ZeroUInt64
NotifyMoneyChange.Commit()
return NotifyMoneyChange
