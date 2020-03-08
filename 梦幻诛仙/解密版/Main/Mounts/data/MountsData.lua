local Lplus = require("Lplus")
local MountsData = Lplus.Class("MountsData")
local MountsConst = require("netio.protocol.mzm.gsp.mounts.MountsConst")
local def = MountsData.define
local instance
def.field("table").curHasMountsList = nil
def.field("table").curBattleMountsMap = nil
def.field("userdata").curRideMountsId = nil
def.static("=>", MountsData).Instance = function()
  if instance == nil then
    instance = MountsData()
  end
  return instance
end
def.method("table").SetCurHasMountsList = function(self, list)
  self.curHasMountsList = list or {}
  for k, v in pairs(self.curHasMountsList) do
    v.mounts_id = k
    self:ConvertMountsRemainTime(v)
  end
end
def.method("=>", "table").GetCurHasMountsList = function(self)
  return self.curHasMountsList
end
def.method("table").AddNewMounts = function(self, mounts)
  if mounts == nil then
    return
  end
  if self.curHasMountsList == nil then
    self.curHasMountsList = {}
  end
  self:ConvertMountsRemainTime(mounts)
  self.curHasMountsList[mounts.mounts_id] = mounts
end
def.method("userdata", "userdata").SetMountsRemainTime = function(self, id, remainTime)
  local mounts = self:GetMountsById(id)
  if mounts ~= nil then
    mounts.remain_time = remainTime
    self:ConvertMountsRemainTime(mounts)
  end
end
def.method("userdata").RemoveHasMounts = function(self, id)
  if self.curHasMountsList == nil then
    return
  end
  for k, v in pairs(self.curHasMountsList) do
    if k == id then
      self.curHasMountsList[k] = nil
    end
  end
end
def.method("userdata", "=>", "table").GetMountsById = function(self, id)
  if self.curHasMountsList == nil then
    return nil
  end
  for k, v in pairs(self.curHasMountsList) do
    if k == id then
      return self.curHasMountsList[k]
    end
  end
  return nil
end
def.method("table").ConvertMountsRemainTime = function(self, mounts)
  if mounts ~= nil and not Int64.eq(mounts.remain_time, MountsConst.TIME_FOREVER) then
    mounts.remain_time = GetServerTime() + mounts.remain_time
  end
end
def.method("table").SetBattleMountsMap = function(self, list)
  self.curBattleMountsMap = list or {}
end
def.method("number", "table").AddNewBattleMounts = function(self, cell, mounts)
  if mounts == nil then
    return
  end
  if self.curBattleMountsMap == nil then
    self.curBattleMountsMap = {}
  end
  self.curBattleMountsMap[cell] = mounts
end
def.method("number").RemoveBattleMounts = function(self, cell)
  if self.curBattleMountsMap == nil then
    return
  end
  self.curBattleMountsMap[cell] = nil
end
def.method("=>", "table").GetBattleMountsMap = function(self)
  return self.curBattleMountsMap
end
def.method("number", "number").SetBattleMountsStatus = function(self, cell, status)
  if self.curBattleMountsMap == nil then
    return
  end
  if self.curBattleMountsMap[cell] ~= nil then
    if isMain then
      for k, v in pairs(self.curBattleMountsMap) do
        v.is_chief_battle_mounts = MountsConst.NO_CHIEF_BATTLE_MOUNTS
      end
    end
    self.curBattleMountsMap[cell].is_chief_battle_mounts = status
  end
end
def.method("number", "number", "userdata").BattleMountsProtectPet = function(self, cell, idx, petId)
  if self.curBattleMountsMap == nil then
    return
  end
  if self.curBattleMountsMap[cell] ~= nil then
    self.curBattleMountsMap[cell].protect_pet_id_list[idx] = petId
  end
end
def.method("number", "number", "userdata").BattleMountsUnProtectPet = function(self, cell, idx, petId)
  if self.curBattleMountsMap == nil then
    return
  end
  if self.curBattleMountsMap[cell] ~= nil then
    local oldPetId = self.curBattleMountsMap[cell].protect_pet_id_list[idx] or Int64.new(-1)
    if Int64.eq(oldPetId, petId) then
      self.curBattleMountsMap[cell].protect_pet_id_list[idx] = Int64.new(-1)
    end
  end
end
def.method("userdata").SetCurRideMountsId = function(self, id)
  self.curRideMountsId = id
end
def.method("=>", "userdata").GetCurRideMountsId = function(self)
  return self.curRideMountsId
end
MountsData.Commit()
return MountsData
