local Lplus = require("Lplus")
local MountsMgr = Lplus.Class("MountsMgr")
local MountsData = require("Main.Mounts.data.MountsData")
local MountsConst = require("netio.protocol.mzm.gsp.mounts.MountsConst")
local MountsUtils = require("Main.Mounts.MountsUtils")
local ItemModule = require("Main.Item.ItemModule")
local MountsModule = Lplus.ForwardDeclare("MountsModule")
local MountsTypeEnum = require("consts.mzm.gsp.mounts.confbean.MountsTypeEnum")
local def = MountsMgr.define
def.const("table").mutexRoleState = {}
def.field("table").mutexConditionFunction = nil
local instance
def.static("=>", MountsMgr).Instance = function()
  if instance == nil then
    instance = MountsMgr()
    instance.mutexConditionFunction = {}
  end
  return instance
end
def.method("number", "function").RigisterRideMountsCondition = function(self, moduleId, fn)
  self.mutexConditionFunction = self.mutexConditionFunction or {}
  self.mutexConditionFunction[moduleId] = fn
end
def.method("table").SyncMountsInfo = function(self, p)
  local mountsData = MountsData.Instance()
  mountsData:SetCurHasMountsList(p.mounts_info_map)
  mountsData:SetBattleMountsMap(p.battle_mounts_info_map)
  mountsData:SetCurRideMountsId(p.current_ride_mounts)
end
def.method("userdata").UnlockMounts = function(self, uuid)
  local req = require("netio.protocol.mzm.gsp.mounts.CUnlockMounts").new(uuid)
  gmodule.network.sendProtocol(req)
end
def.method("number").ExtendMountsTime = function(self, itemId)
  local req = require("netio.protocol.mzm.gsp.mounts.CExtendMountsTime").new(itemId, 1)
  gmodule.network.sendProtocol(req)
end
def.method("userdata").RideMounts = function(self, mountsId)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role == nil then
    return
  end
  if MountsMgr.mutexRoleState ~= nil then
    for i = 1, #MountsMgr.mutexRoleState do
      if role:IsInState(MountsMgr.mutexRoleState[i]) then
        Toast(textRes.Mounts[97])
        return
      end
    end
  end
  if self.mutexConditionFunction ~= nil then
    for moduleId, fn in pairs(self.mutexConditionFunction) do
      if not fn() then
        Toast(textRes.Mounts[97])
        return
      end
    end
  end
  local req = require("netio.protocol.mzm.gsp.mounts.CRideMounts").new(mountsId)
  gmodule.network.sendProtocol(req)
end
def.method().UnRideMounts = function(self)
  local mountsData = MountsData.Instance()
  local curRide = mountsData:GetCurRideMountsId()
  if curRide ~= nil and not Int64.eq(curRide, MountsConst.NO_RIDE) then
    local req = require("netio.protocol.mzm.gsp.mounts.CUnRideMounts").new()
    gmodule.network.sendProtocol(req)
  end
end
def.method("userdata").MountsBattle = function(self, mountsId)
  local nextCell = self:GetNextCell()
  if nextCell <= 0 then
    Toast(textRes.Mounts[15])
  else
    local req = require("netio.protocol.mzm.gsp.mounts.CMountsBattle").new(nextCell, mountsId)
    gmodule.network.sendProtocol(req)
  end
end
def.method("number").MountsUnBattle = function(self, cell)
  if cell <= 0 then
    return
  else
    local req = require("netio.protocol.mzm.gsp.mounts.CMountsUnBattle").new(cell)
    gmodule.network.sendProtocol(req)
  end
end
def.method("number").SetMountsMainBattle = function(self, cell)
  if cell <= 0 then
    return
  else
    local req = require("netio.protocol.mzm.gsp.mounts.CMountsSetBattleState").new(cell, MountsConst.YES_CHIEF_BATTLE_MOUNTS)
    gmodule.network.sendProtocol(req)
  end
end
def.method("number").SetMountsSecondBattle = function(self, cell)
  if cell <= 0 then
    return
  else
    local req = require("netio.protocol.mzm.gsp.mounts.CMountsSetBattleState").new(cell, MountsConst.NO_CHIEF_BATTLE_MOUNTS)
    gmodule.network.sendProtocol(req)
  end
end
def.method("userdata", "number", "userdata").MountsProtectPet = function(self, mountsId, gridIdx, petId)
  local cell = self:GetBattleMountsCell(mountsId)
  if cell <= 0 then
    Toast(textRes.Mounts[22])
  else
    local petList = self:GetBattleMountsGuradPets(mountsId) or {}
    local oldPetId = petList[gridIdx + 1] or Int64.new(-1)
    if Int64.eq(oldPetId, -1) then
      local req = require("netio.protocol.mzm.gsp.mounts.CMountsProtectPet").new(cell, gridIdx, petId)
      gmodule.network.sendProtocol(req)
    else
      local req = require("netio.protocol.mzm.gsp.mounts.CMountsReplaceProtectPet").new(cell, gridIdx, oldPetId, petId)
      gmodule.network.sendProtocol(req)
    end
  end
end
def.method("userdata", "number", "userdata").MountsUnProtectPet = function(self, mountsId, gridIdx, petId)
  local cell = self:GetBattleMountsCell(mountsId)
  if cell <= 0 then
    Toast(textRes.Mounts[22])
  else
    local req = require("netio.protocol.mzm.gsp.mounts.CMountsUnProtectPet").new(cell, gridIdx, petId)
    gmodule.network.sendProtocol(req)
  end
end
def.method("userdata", "number", "boolean", "number").MountsRefreshPassiveSkill = function(self, mountsId, skillId, useYuanbao, needYuanbao)
  if mountsId == nil or skillId == 0 or needYuanbao < 0 then
    return
  end
  local op = 0
  if useYuanbao then
    op = 1
  end
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  local req = require("netio.protocol.mzm.gsp.mounts.CMountsRefreshPassiveSkill").new(mountsId, skillId, op, yuanBaoNum, needYuanbao)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "number").MountsReplacePassiveSkill = function(self, mountsId, skillId)
  if mountsId == nil or skillId == 0 then
    return
  end
  local req = require("netio.protocol.mzm.gsp.mounts.CMountsReplacePassiveSkill").new(mountsId, skillId)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "number", "boolean", "number").MountsDye = function(self, mountsId, colorId, useYuanbao, needYuanbao)
  if mountsId == nil then
    return
  end
  local op = 0
  if useYuanbao then
    op = 1
  end
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  local req = require("netio.protocol.mzm.gsp.mounts.CMountsDye").new(mountsId, colorId, op, yuanBaoNum, needYuanbao)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "boolean", "number").MountsActiveStarLife = function(self, mountsId, useYuanbao, needYuanbao)
  if mountsId == nil then
    return
  end
  local op = 0
  if useYuanbao then
    op = 1
  end
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  local req = require("netio.protocol.mzm.gsp.mounts.CMountsActiveStarLife").new(mountsId, op, yuanBaoNum, needYuanbao)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "userdata").CostMountsAddScore = function(self, mountsId, costMountsId)
  local req = require("netio.protocol.mzm.gsp.mounts.CCostMountsAddScore").new(costMountsId, mountsId)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "number", "number", "number").CostItemAddScore = function(self, mountsId, itemId, itemType, useAll)
  local req = require("netio.protocol.mzm.gsp.mounts.CCostItemAddScore").new(mountsId, itemId, itemType, useAll)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "boolean", "number").MountsCostItemRankUp = function(self, mountsId, useYuanbao, needYuanbao)
  if mountsId == nil then
    return
  end
  local op = 0
  if useYuanbao then
    op = 1
  end
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  local req = require("netio.protocol.mzm.gsp.mounts.CMountsCostItemRankUp").new(mountsId, op, yuanBaoNum, needYuanbao)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "number").MountsSelectOrnament = function(self, mountsId, ornamentRank)
  if mountsId == nil or ornamentRank <= 0 then
    return
  end
  local req = require("netio.protocol.mzm.gsp.mounts.CMountsSelectOrnament").new(mountsId, ornamentRank)
  gmodule.network.sendProtocol(req)
end
def.method("=>", "table").GetSortedMountsList = function(self)
  local mountsData = MountsData.Instance()
  local list = mountsData:GetCurHasMountsList()
  local data = {}
  if list ~= nil then
    for k, v in pairs(list) do
      table.insert(data, v)
    end
  end
  table.sort(data, function(mountsA, mountsB)
    if self:IsMountsBattle(mountsA.mounts_id) and not self:IsMountsBattle(mountsB.mounts_id) then
      return true
    elseif not self:IsMountsBattle(mountsA.mounts_id) and self:IsMountsBattle(mountsB.mounts_id) then
      return false
    elseif self:IsRideMounts(mountsA.mounts_id) then
      return true
    elseif self:IsRideMounts(mountsB.mounts_id) then
      return false
    elseif mountsA.mounts_rank == mountsB.mounts_rank then
      return mountsA.mounts_cfg_id < mountsB.mounts_cfg_id
    else
      return mountsA.mounts_rank > mountsB.mounts_rank
    end
  end)
  return data
end
def.method("userdata", "=>", "table").GetMountsById = function(self, mountsId)
  if mountsId == nil then
    return nil
  end
  local mountsData = MountsData.Instance()
  return mountsData:GetMountsById(mountsId)
end
def.method("userdata", "=>", "boolean").HasMounts = function(self, mountsId)
  return self:GetMountsById(mountsId) ~= nil
end
def.method("=>", "userdata").GetCurRideMountsId = function(self)
  local mountsData = MountsData.Instance()
  return mountsData:GetCurRideMountsId()
end
def.method("userdata").SetCurRideMountsId = function(self, mountsId)
  local mountsData = MountsData.Instance()
  mountsData:SetCurRideMountsId(mountsId)
end
def.method("=>", "boolean").HasRideMounts = function(self)
  local curRide = self:GetCurRideMountsId()
  return curRide ~= nil and not Int64.eq(curRide, MountsConst.NO_RIDE)
end
def.method("userdata", "=>", "boolean").IsRideMounts = function(self, mountsId)
  local curRide = self:GetCurRideMountsId()
  return curRide ~= nil and Int64.eq(curRide, mountsId)
end
def.method("userdata", "table").AddMounts = function(self, mountsId, mounts)
  local mountsData = MountsData.Instance()
  mounts.mounts_id = mountsId
  mountsData:AddNewMounts(mounts)
end
def.method("=>", "table").GetBattleMountsMap = function(self)
  local mountsData = MountsData.Instance()
  return mountsData:GetBattleMountsMap() or {}
end
def.method("userdata", "=>", "boolean").IsMountsBattle = function(self, mountsId)
  if mountsId == nil then
    return false
  end
  local mountsData = MountsData.Instance()
  local battleMap = mountsData:GetBattleMountsMap()
  if battleMap == nil then
    return false
  else
    for k, v in pairs(battleMap) do
      if Int64.eq(mountsId, v.mounts_id) then
        return true
      end
    end
  end
  return false
end
def.method("userdata", "=>", "boolean").MountsHasProtectedPet = function(self, mountsId)
  local protectedPets = self:GetBattleMountsGuradPets(mountsId) or {}
  for i = 1, #protectedPets do
    local petId = protectedPets[i]
    if petId ~= nil and Int64.gt(petId, 0) then
      return true
    end
  end
  return false
end
def.method("=>", "number").GetNextCell = function(self)
  local mountsData = MountsData.Instance()
  local battleMap = mountsData:GetBattleMountsMap()
  if battleMap == nil then
    return 1
  end
  for i = 1, constant.CMountsConsts.maxBattleMounts do
    if battleMap[i] == nil then
      return i
    end
  end
  return 0
end
def.method("userdata", "=>", "number").GetBattleMountsCell = function(self, mountsId)
  local mountsData = MountsData.Instance()
  local battleMap = mountsData:GetBattleMountsMap()
  if battleMap == nil then
    return 0
  end
  for i = 1, constant.CMountsConsts.maxBattleMounts do
    if battleMap[i] ~= nil and Int64.eq(battleMap[i].mounts_id, mountsId) then
      return i
    end
  end
  return 0
end
def.method("number", "userdata").AddBattleMounts = function(self, cell, mountsId)
  local battleMounts = require("netio.protocol.mzm.gsp.mounts.BattleMountsInfo").new(mountsId, false, {})
  local mountsData = MountsData.Instance()
  mountsData:AddNewBattleMounts(cell, battleMounts)
end
def.method("number").RemoveBattleMounts = function(self, cell)
  local mountsData = MountsData.Instance()
  mountsData:RemoveBattleMounts(cell)
end
def.method("number", "number", "table").SetBattleMountsInfo = function(self, cell, idx, battleMounts)
  local mountsData = MountsData.Instance()
  mountsData:RemoveBattleMounts(cell)
  mountsData:AddNewBattleMounts(cell, battleMounts)
end
def.method("number", "number").SetBattleMountsStatus = function(self, cell, status)
  local mountsData = MountsData.Instance()
  mountsData:SetBattleMountsStatus(cell, status)
end
def.method("table").SetBattleMountsMap = function(self, battleMap)
  local mountsData = MountsData.Instance()
  mountsData:SetBattleMountsMap(battleMap)
end
def.method("userdata", "=>", "boolean").HasSameTypeBattleMounts = function(self, mountsId)
  local mountsType = self:GetMountsType(mountsId)
  local mountsData = MountsData.Instance()
  local battleMap = mountsData:GetBattleMountsMap()
  if battleMap == nil then
    return false
  end
  for i = 1, constant.CMountsConsts.maxBattleMounts do
    if battleMap[i] ~= nil and mountsType == self:GetMountsType(battleMap[i].mounts_id) then
      return true
    end
  end
  return false
end
def.method("userdata", "=>", "number").GetMountsType = function(self, mountsId)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return -1
  end
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  if mountsCfg == nil then
    return -1
  end
  return mountsCfg.mountsType
end
def.method("userdata", "=>", "table").GetBattleMountsGuradPets = function(self, mountsId)
  local mountsData = MountsData.Instance()
  local battleMap = mountsData:GetBattleMountsMap()
  if battleMap == nil then
    return {}
  end
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return {}
  end
  for i = 1, constant.CMountsConsts.maxBattleMounts do
    if battleMap[i] ~= nil and Int64.eq(mountsId, battleMap[i].mounts_id) then
      local petList = {}
      for j = 1, mounts.protect_pet_expand_size + 1 do
        petList[j] = battleMap[i].protect_pet_id_list[j] or Int64.new(-1)
      end
      return petList
    end
  end
  return {}
end
def.method("number", "number", "userdata").BattleMountsProtectPet = function(self, cell, idx, petId)
  local mountsData = MountsData.Instance()
  mountsData:BattleMountsProtectPet(cell, idx + 1, petId)
end
def.method("number", "number", "userdata").BattleMountsUnProtectPet = function(self, cell, idx, petId)
  local mountsData = MountsData.Instance()
  mountsData:BattleMountsUnProtectPet(cell, idx + 1, petId)
end
def.method("userdata", "=>", "boolean", "userdata").IsPetProtected = function(self, petId)
  local mountsData = MountsData.Instance()
  local battleMap = mountsData:GetBattleMountsMap()
  if battleMap == nil then
    return false, Int64.new(0)
  end
  for i = 1, constant.CMountsConsts.maxBattleMounts do
    if battleMap[i] ~= nil then
      local pets = battleMap[i].protect_pet_id_list
      if pets ~= nil then
        for idx, protectPetId in pairs(pets) do
          if Int64.eq(protectPetId, petId) then
            return true, battleMap[i].mounts_id
          end
        end
      end
    end
  end
  return false, Int64.new(0)
end
def.method("userdata", "table").SetMountsRankUp = function(self, mountsId, mounts)
  local mountsData = MountsData.Instance()
  mounts.mounts_id = mountsId
  mountsData:RemoveHasMounts(mountsId)
  mountsData:AddNewMounts(mounts)
end
def.method("userdata", "=>", "boolean").IsMoutsReachMaxRank = function(self, mountsId)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return false
  end
  local mountsRankCfg = MountsUtils.GetMountsJinjieCfg(mounts.mounts_cfg_id)
  if mountsRankCfg == nil then
    return false
  end
  return mounts.mounts_rank >= mountsRankCfg.maxRank
end
def.method("userdata", "=>", "table").GetMountsPassiveSkillIds = function(self, mountsId)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return {}
  end
  local ret = {}
  for i = 1, #mounts.passive_skill_list do
    table.insert(ret, mounts.passive_skill_list[i].current_passive_skill_cfg_id)
  end
  return ret
end
def.method("userdata", "number", "=>", "table").GetMountsPassiveSkillInfo = function(self, mountsId, skillId)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return nil
  end
  for i = 1, #mounts.passive_skill_list do
    if mounts.passive_skill_list[i].current_passive_skill_cfg_id == skillId then
      return mounts.passive_skill_list[i]
    end
  end
  return nil
end
def.method("userdata", "number", "=>", "number").GetMountsPassiveSkillRankIndx = function(self, mountsId, skillId)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return -1
  end
  for i = 1, #mounts.passive_skill_list do
    if mounts.passive_skill_list[i].current_passive_skill_cfg_id == skillId then
      return i
    end
  end
  return -1
end
def.method("userdata", "number", "table").SetMountsPassiveSkill = function(self, mountsId, preSkillId, skillInfo)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil or skillInfo == nil then
    return
  end
  for idx, skill in ipairs(mounts.passive_skill_list) do
    if skill.current_passive_skill_cfg_id == preSkillId then
      mounts.passive_skill_list[idx] = skillInfo
      return
    end
  end
end
def.method("userdata", "number").SetMountsDyeColor = function(self, mountsId, colorId)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return
  end
  mounts.color_id = colorId
end
def.method("userdata", "number", "=>", "boolean").IsMountsStarActive = function(self, mountsId, starNum)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return false
  end
  if mounts.current_star_level <= 1 and starNum > mounts.current_max_active_star_num then
    return false
  end
  return true
end
def.method("userdata", "number", "=>", "boolean").CanMountsActiveOrUpStar = function(self, mountsId, starNum)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return false
  end
  if starNum - mounts.current_max_active_star_num ~= 1 then
    return false
  end
  return not self:IsReachMaxStarLevel(mountsId, starNum)
end
def.method("userdata", "number", "=>", "boolean").IsReachMaxStarLevel = function(self, mountsId, starNum)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return true
  end
  local mountsStarCfg = MountsUtils.GetMountsStartLifeCfgById(mounts.mounts_cfg_id)
  local curStarLevel = self:GetMountsStarLevel(mountsId, starNum)
  if mountsStarCfg == nil or mountsStarCfg[starNum] == nil or mountsStarCfg[starNum][curStarLevel + 1] == nil then
    return true
  end
  return false
end
def.method("userdata", "number", "=>", "boolean").IsStarReachMapLevel = function(self, mountsId, starNum)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return true
  end
  local starLevel = self:GetMountsStarLevel(mountsId, starNum)
  return starLevel >= mounts.current_star_level
end
def.method("userdata", "number", "=>", "number").GetMountsStarLevel = function(self, mountsId, starNum)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return 0
  end
  return self:GetStarLevelFromMountsData(mounts, starNum)
end
def.method("table", "number", "=>", "number").GetStarLevelFromMountsData = function(self, mounts, starNum)
  if mounts == nil then
    return 0
  end
  if starNum > mounts.current_max_active_star_num then
    return math.max(mounts.current_star_level - 1, 0)
  end
  return mounts.current_star_level
end
def.method("userdata", "number", "number").SetMountsStarNumAndLevel = function(self, mountsId, starNum, starLevel)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return
  end
  mounts.current_max_active_star_num = starNum
  mounts.current_star_level = starLevel
end
def.method("userdata").SetMountsExpired = function(self, mountsId)
  local mountsData = MountsData.Instance()
  mountsData:RemoveHasMounts(mountsId)
end
def.method("userdata", "=>", "number").GetMountsScore = function(self, mountsId)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return 0
  end
  local property = self:GetMountsProperty(mountsId)
  return MountsUtils.CalculateMountsPropertyScore(property)
end
def.method("userdata", "=>", "table").GetMountsProperty = function(self, mountsId)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return {}
  end
  return self:PacketMountsProperty(mounts)
end
def.method("table", "=>", "table").PacketMountsProperty = function(self, mounts)
  if mounts == nil then
    return {}
  end
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  if mountsCfg == nil then
    return {}
  end
  local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(mounts.mounts_cfg_id, mounts.mounts_rank)
  if mountsRankCfg == nil then
    return {}
  end
  local property = {}
  for k, v in pairs(mountsRankCfg.property) do
    property[k] = v
  end
  local mountsStartMapCfg = MountsUtils.GetMountsStartLifeMapCfg(mounts.mounts_cfg_id)
  local starCount = 0
  if mountsStartMapCfg ~= nil then
    starCount = #mountsStartMapCfg
  end
  local mountsStarCfg = MountsUtils.GetMountsStartLifeCfgById(mounts.mounts_cfg_id)
  if mountsStarCfg ~= nil then
    for i = 1, starCount do
      local starLevel = self:GetStarLevelFromMountsData(mounts, i)
      if mountsStarCfg[i] ~= nil and mountsStarCfg[i][starLevel] ~= nil then
        local propertyList = mountsStarCfg[i][starLevel].propertyList
        for j = 1, #propertyList do
          local originValue = property[propertyList[j].nameKey] or 0
          property[propertyList[j].nameKey] = originValue + propertyList[j].value
        end
      end
    end
  end
  return property
end
def.method("number", "=>", "boolean").CanExtendMountsTime = function(self, itemId)
  local unlockCfg = MountsUtils.GetUnlockMountsByItemId(itemId)
  if unlockCfg ~= nil then
    local mounts = MountsUtils.GetMountsCfgById(unlockCfg.mountsCfgId)
    if mounts ~= nil and mounts.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
      return self:HasMountsOfCfgId(unlockCfg.mountsCfgId)
    end
  end
  return false
end
def.method("number", "=>", "boolean").HasMountsOfCfgId = function(self, mountsCfgId)
  local mountsData = MountsData.Instance()
  local list = mountsData:GetCurHasMountsList()
  if list ~= nil then
    for k, v in pairs(list) do
      if v.mounts_cfg_id == mountsCfgId then
        return true
      end
    end
  end
  return false
end
def.method("userdata", "userdata").SetMountsRemainTime = function(self, mountsId, remainTime)
  local mountsData = MountsData.Instance()
  mountsData:SetMountsRemainTime(mountsId, remainTime)
end
def.method("userdata", "=>", "table").GetSameTypeMounts = function(self, mountsId)
  local mountsList = {}
  local mounts = self:GetMountsById(mountsId)
  if mounts ~= nil then
    local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
    if mountsCfg ~= nil then
      local needType = mountsCfg.mountsType
      local mountsData = MountsData.Instance()
      local list = mountsData:GetCurHasMountsList()
      if list ~= nil then
        for k, v in pairs(list) do
          local cfg = MountsUtils.GetMountsCfgById(v.mounts_cfg_id)
          if not Int64.eq(k, mountsId) and cfg ~= nil and cfg.mountsType == needType then
            table.insert(mountsList, v)
          end
        end
      end
    end
  end
  return mountsList
end
def.method("userdata", "number").SetMountsScore = function(self, mountsId, curSocre)
  local mounts = self:GetMountsById(mountsId)
  if mounts ~= nil then
    mounts.current_score = curSocre
  end
end
def.method("userdata").RemoveMounts = function(self, mountsId)
  local mountsData = MountsData.Instance()
  mountsData:RemoveHasMounts(mountsId)
end
def.method("userdata", "=>", "boolean").IsMountsRankUpScoreFull = function(self, mountsId)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return false
  end
  local mountsNextRankCfg = MountsUtils.GetMountsCfgOfRank(mounts.mounts_cfg_id, mounts.mounts_rank + 1)
  if mountsNextRankCfg == nil then
    return false
  end
  return mounts.current_score >= mountsNextRankCfg.rankUpNeedScoreNum
end
def.method("userdata", "number").SetMountsOrnament = function(self, mountsId, ornamentRank)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return
  end
  mounts.current_ornament_rank = ornamentRank
end
def.method("userdata", "number", "=>", "boolean").IsMountsProtectPetPosUnlock = function(self, mountsId, posIdx)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return false
  end
  local expandSize = mounts.protect_pet_expand_size or 0
  return expandSize > posIdx - 1
end
def.method("userdata", "boolean", "number").ExpandProtectPetSize = function(self, mountsId, useYuanbao, needYuanbao)
  if mountsId == nil then
    return
  end
  local use = useYuanbao and 1 or 0
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  local req = require("netio.protocol.mzm.gsp.mounts.CExpandProtectPetSize").new(mountsId, use, yuanBaoNum, needYuanbao)
  gmodule.network.sendProtocol(req)
  warn("CExpandProtectPetSize")
end
def.method("userdata", "number").SetMountsProtectPetSize = function(self, mountsId, size)
  local mounts = self:GetMountsById(mountsId)
  if mounts == nil then
    return
  end
  mounts.protect_pet_expand_size = size
end
def.method("=>", "number").GetMountsMaxMoveSpeed = function(self)
  local speed = 0
  local mountsData = MountsData.Instance()
  local list = mountsData:GetCurHasMountsList()
  if list ~= nil then
    for k, v in pairs(list) do
      local mountsCfg = MountsUtils.GetMountsCfgById(v.mounts_cfg_id)
      local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(v.mounts_cfg_id, v.mounts_rank)
      if mountsCfg ~= nil and mountsRankCfg ~= nil then
        speed = math.max(speed, mountsRankCfg.speed)
      end
    end
  end
  return speed
end
MountsMgr.Commit()
return MountsMgr
