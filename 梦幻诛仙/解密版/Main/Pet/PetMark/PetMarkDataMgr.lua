local Lplus = require("Lplus")
local PetMarkDataMgr = Lplus.Class("PetMarkDataMgr")
local def = PetMarkDataMgr.define
local PetMarkInfo = require("Main.Pet.PetMark.data.PetMarkInfo")
local instance
def.field("table").petMarkMap = nil
def.field("table").petMarkEquipMap = nil
def.static("=>", PetMarkDataMgr).Instance = function()
  if instance == nil then
    instance = PetMarkDataMgr()
  end
  return instance
end
def.method("table").SetPetMarkMap = function(self, map)
  self.petMarkMap = {}
  for k, v in pairs(map) do
    local markInfo = PetMarkInfo()
    markInfo:RawSet(k, v)
    self.petMarkMap[k:tostring()] = markInfo
  end
end
def.method("userdata", "table").SetPetMarkInfo = function(self, markId, info)
  if self.petMarkMap == nil then
    self.petMarkMap = {}
  end
  if info ~= nil then
    local markInfo = PetMarkInfo()
    markInfo:RawSet(markId, info)
    self.petMarkMap[markId:tostring()] = markInfo
  else
    self.petMarkMap[markId:tostring()] = nil
  end
end
def.method("userdata", "=>", "table").GetPetMarkInfo = function(self, markId)
  if markId == nil then
    return nil
  end
  if self.petMarkMap == nil then
    return nil
  end
  return self.petMarkMap[markId:tostring()]
end
def.method("userdata", "userdata").SetMarkEquipPet = function(self, markId, petId)
  if markId == nil then
    return nil
  end
  if self.petMarkMap ~= nil and self.petMarkMap[markId:tostring()] ~= nil then
    if petId ~= nil then
      self.petMarkMap[markId:tostring()]:SetPetId(petId)
    else
      self.petMarkMap[markId:tostring()]:SetPetId(Int64.new(0))
    end
  end
  if self.petMarkEquipMap ~= nil then
    if petId ~= nil then
      self.petMarkEquipMap[petId:tostring()] = markId
    else
      for k, v in pairs(self.petMarkEquipMap) do
        if Int64.eq(v, markId) then
          self.petMarkEquipMap[k] = nil
          break
        end
      end
    end
  end
end
def.method("table").SetPetMarkEquipMap = function(self, map)
  self.petMarkEquipMap = {}
  for k, v in pairs(map) do
    self.petMarkEquipMap[k:tostring()] = v
  end
end
def.method("=>", "table").GetSortedPetMarkList = function(self)
  local ret = {}
  for k, v in pairs(self.petMarkMap or {}) do
    table.insert(ret, v)
  end
  table.sort(ret, function(a, b)
    if a:HasEquipPet() and not b:HasEquipPet() then
      return true
    elseif not a:HasEquipPet() and b:HasEquipPet() then
      return false
    elseif a:GetLevel() > b:GetLevel() then
      return true
    elseif a:GetLevel() < b:GetLevel() then
      return false
    else
      return a:GetPetMarkCfgId() > b:GetPetMarkCfgId()
    end
  end)
  return ret
end
def.method("userdata", "=>", "boolean").IsPetEquipMark = function(self, petId)
  if petId == nil then
    return false
  end
  if self.petMarkEquipMap == nil then
    return false
  end
  if self.petMarkEquipMap[petId:tostring()] == nil then
    return false
  end
  if Int64.eq(self.petMarkEquipMap[petId:tostring()], 0) then
    return false
  end
  return true
end
def.method("userdata", "=>", "userdata").GetPetEquipMarkId = function(self, petId)
  if petId == nil then
    return nil
  end
  if self.petMarkEquipMap == nil then
    return nil
  end
  if self.petMarkEquipMap[petId:tostring()] == nil then
    return nil
  end
  if Int64.eq(self.petMarkEquipMap[petId:tostring()], 0) then
    return nil
  end
  return self.petMarkEquipMap[petId:tostring()]
end
def.method("=>", "number").GetCurrentPetMarkCount = function(self)
  local count = 0
  for k, v in pairs(self.petMarkMap or {}) do
    count = count + 1
  end
  return count
end
PetMarkDataMgr.Commit()
return PetMarkDataMgr
