local Lplus = require("Lplus")
local PetStorageMgr = Lplus.Class("PetStorageMgr")
local def = PetStorageMgr.define
local PetData = require("Main.Pet.data.PetData")
local ItemModule = require("Main.Item.ItemModule")
local instance, PET_NOT_SET
def.const("userdata").PET_NOT_SET = PET_NOT_SET
local CResult = {SUCCESS = 0, FORBIDDEN_IN_FIGHT = 1}
def.const("table").CResult = CResult
def.field("table").petList = nil
def.field("number").petNum = 0
def.field("number").storageCapacity = 0
def.static("=>", PetStorageMgr).Instance = function()
  if instance == nil then
    instance = PetStorageMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.petList = {}
end
def.method("table").SetPetList = function(self, petList)
  self.petList = {}
  self.petNum = 0
  for i, pet in ipairs(petList) do
    local petData = PetData()
    petData:RawSet(pet)
    petData:ReCalcYaoLi()
    self:AddPet(petData)
  end
end
def.method(PetData).AddPet = function(self, petData)
  self.petList[tostring(petData.id)] = petData
  self.petNum = self.petNum + 1
end
def.method("userdata").RemovePet = function(self, petId)
  self.petList[tostring(petId)] = nil
  self.petNum = self.petNum - 1
end
def.method("=>", "table").GetPetList = function(self)
  if self.petList == nil then
    return {}
  end
  return self.petList
end
def.method("=>", "table").GetPets = function(self)
  if self.petList == nil then
    return {}
  end
  return self.petList
end
def.method("userdata", "=>", PetData).GetPet = function(self, petId)
  return self.petList[tostring(petId)]
end
def.method("=>", "number").GetPetNum = function(self)
  return self.petNum
end
def.method("=>", "number").GetStorageCapacity = function(self)
  return self.storageCapacity
end
def.method("number").ExpandStorageCapacity = function(self, itemNum)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_ExpandStorageCapacity(itemNum, yuanBaoNum)
end
def.method("userdata", "number", "=>", "number").TransformPetPlace = function(self, petId, target)
  self:C2S_TransformPetPlace(petId, target)
  return CResult.SUCCESS
end
def.method("number", "userdata").C2S_ExpandStorageCapacity = function(self, itemNum, yuanBaoNum)
  local p = require("netio.protocol.mzm.gsp.pet.CExpandPetDepotReq").new(itemNum, yuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_TransformPetPlace = function(self, petId, target)
  local p = require("netio.protocol.mzm.gsp.pet.CTransfomPetPlaceReq").new(petId, target)
  gmodule.network.sendProtocol(p)
end
return PetStorageMgr.Commit()
