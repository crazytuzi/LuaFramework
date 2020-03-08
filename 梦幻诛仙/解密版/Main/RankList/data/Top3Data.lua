local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Top3Data = Lplus.Class(CUR_CLASS_NAME)
local def = Top3Data.define
def.field("number").type = 0
def.field("table").list = nil
return Top3Data.Commit()
