local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetTeamInfo = Lplus.Class(CUR_CLASS_NAME)
local def = PetTeamInfo.define
def.field("number").teamIdx = 0
def.field("number").formationId = 0
def.field("table").pos2PetMap = nil
def.final("number", "number", "table", "=>", PetTeamInfo).New = function(teamIdx, formationId, pos2PetMap)
  local petTeamInfo = PetTeamInfo()
  petTeamInfo.teamIdx = teamIdx
  petTeamInfo.formationId = formationId
  petTeamInfo.pos2PetMap = pos2PetMap
  return petTeamInfo
end
def.method("=>", PetTeamInfo).Clone = function(self)
  local posMap = {}
  if self.pos2PetMap then
    for pos, posPetId in pairs(self.pos2PetMap) do
      posMap[pos] = posPetId
    end
  end
  return PetTeamInfo.New(self.teamIdx, self.formationId, posMap)
end
def.method(PetTeamInfo).Copy = function(self, petTeamInfo)
  if petTeamInfo then
    self.teamIdx = petTeamInfo.teamIdx
    self.formationId = petTeamInfo.formationId
    self.pos2PetMap = {}
    if petTeamInfo.pos2PetMap then
      for pos, petId in pairs(petTeamInfo.pos2PetMap) do
        self.pos2PetMap[pos] = petId
      end
    end
  else
    self.teamIdx = 0
    self.formationId = 0
    self.pos2PetMap = nil
  end
end
def.method("table").UpdateTeamPos = function(self, pos2PetMap)
  self.pos2PetMap = pos2PetMap
end
def.method("number", "userdata").SetPosPet = function(self, pos, petId)
  if nil == self.pos2PetMap then
    self.pos2PetMap = {}
  end
  local destPetId = self.pos2PetMap[pos]
  local originPos = self:GetPetPos(petId)
  if originPos > 0 then
    self.pos2PetMap[originPos] = destPetId
  end
  self.pos2PetMap[pos] = petId
end
def.method("number", "=>", "userdata").GetPosPet = function(self, pos)
  return self.pos2PetMap and self.pos2PetMap[pos]
end
def.method("userdata", "=>", "number").GetPetPos = function(self, petId)
  local resultPos = 0
  if self.pos2PetMap and petId then
    for pos, posPetId in pairs(self.pos2PetMap) do
      if Int64.eq(petId, posPetId) then
        resultPos = pos
        break
      end
    end
  end
  return resultPos
end
def.method("number").SetFormation = function(self, formationId)
  self.formationId = formationId
end
def.method("=>", "number").GetPetCount = function(self)
  local result = 0
  if self.pos2PetMap then
    for pos, posPetId in pairs(self.pos2PetMap) do
      if posPetId then
        result = result + 1
      end
    end
  end
  return result
end
def.method("number", "=>", "boolean").CanPetOff = function(self, pos)
  local petId = self:GetPosPet(pos)
  if petId then
    if self.teamIdx == require("Main.PetTeam.data.PetTeamData").Instance():GetDefTeamIdx() then
      return self:GetPetCount() > 1
    else
      return true
    end
  else
    return false
  end
end
def.method("=>", "number").GetPetScore = function(self)
  local result = 0
  if self.pos2PetMap then
    for pos, posPetId in pairs(self.pos2PetMap) do
      local petInfo = PetMgr.Instance():GetPet(posPetId)
      if petInfo then
        result = result + petInfo:GetYaoLi()
      end
    end
  end
  return result
end
return PetTeamInfo.Commit()
