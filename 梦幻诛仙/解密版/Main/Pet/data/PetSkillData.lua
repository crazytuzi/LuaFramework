local Lplus = require("Lplus")
local PetSkillData = Lplus.Class("PetSkillData")
local def = PetSkillData.define
local NOT_SET = -1
def.field("number").id = NOT_SET
def.field("number").level = 0
def.field("boolean").isBasicSkill = false
def.field("boolean").isAmuletSkill = false
def.field("boolean").isPassiveSkill = false
return PetSkillData.Commit()
