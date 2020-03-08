local Lplus = require("Lplus")
local ECObject = Lplus.Class("ECObject")
local def = ECObject.define
def.field("number").clickPriority = 1
ECObject.Commit()
return ECObject
