local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ComprehensivePowerMgr = Lplus.Class(CUR_CLASS_NAME)
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetStorageMgr = require("Main.Pet.mgr.PetStorageMgr")
local def = ComprehensivePowerMgr.define
def.const("number").INCLUDE_PET_MAX_NUM = 3
local instance
def.static("=>", ComprehensivePowerMgr).Instance = function()
  if instance == nil then
    instance = ComprehensivePowerMgr()
  end
  return instance
end
def.method("=>", "number").GetComprehensivePower = function(self)
  local fightValue = _G.GetHeroProp().fightValue
  local petList = {}
  local pets = PetMgr.Instance():GetPets()
  for k, v in pairs(pets) do
    petList[#petList + 1] = v
  end
  local pets = PetStorageMgr.Instance():GetPets()
  for k, v in pairs(pets) do
    petList[#petList + 1] = v
  end
  table.sort(petList, function(l, r)
    return l:GetYaoLi() > r:GetYaoLi()
  end)
  local yaoliSum = 0
  local num = math.min(ComprehensivePowerMgr.INCLUDE_PET_MAX_NUM, #petList)
  for i = 1, num do
    yaoliSum = yaoliSum + petList[i]:GetYaoLi()
  end
  local power = fightValue + yaoliSum
  return power
end
return ComprehensivePowerMgr.Commit()
