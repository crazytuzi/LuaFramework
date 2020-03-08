local Lplus = require("Lplus")
local Formulation = Lplus.Class("Formulation")
local MathHelper = require("Common.MathHelper")
local def = Formulation.define
def.field("table").formulations = function()
  local func = {
    CommonSKillLVFormula = Formulation.CommonSKillLVFormula,
    CommonFighterLVFormula = Formulation.CommonFighterLVFormula,
    SkillLVEffectFormula = Formulation.SkillLVEffectFormula,
    SkillLVEffectMuple = Formulation.SkillLVEffectMuple
  }
  return func
end
local instance
def.static("=>", Formulation)._Instance = function()
  if instance == nil then
    instance = Formulation()
  end
  return instance
end
function Formulation.Calc(formulationName, ...)
  local formulation = Formulation._Instance().formulations[formulationName]
  local result = 0
  if formulation then
    result = formulation({
      ...
    })
  else
    warn("Missing formulation(" .. formulationName .. ") !")
  end
  return result
end
local function floor(v)
  return MathHelper.Floor(v, 0.001)
end
def.static("table", "=>", "number").CommonSKillLVFormula = function(params)
  local skillLevel = params[1]
  local result = skillLevel ^ 2 * params[2] + skillLevel * params[3] + params[4]
  return floor(result)
end
def.static("table", "=>", "number").CommonFighterLVFormula = function(params)
  local roleLevel = params[1]
  local result = roleLevel ^ 2 * params[2] + roleLevel * params[3] + params[4]
  return floor(result)
end
def.static("table", "=>", "number").SkillLVEffectFormula = function(params)
  local skillLevel = params[1]
  local result = skillLevel ^ 2 * params[2] + skillLevel * params[3] + params[4]
  return floor(result)
end
def.static("table", "=>", "number").SkillLVEffectMuple = function(params)
  local skillLevel = params[1]
  local result = skillLevel / params[2] * params[3] + params[4]
  return floor(result)
end
return Formulation.Commit()
