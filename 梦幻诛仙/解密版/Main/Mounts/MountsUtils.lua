local Lplus = require("Lplus")
local MountsUtils = Lplus.Class("MountsUtils")
local OrnamentOpenEnum = require("consts.mzm.gsp.mounts.confbean.OrnamentOpenEnum")
local MountsTypeEnum = require("consts.mzm.gsp.mounts.confbean.MountsTypeEnum")
local EquipUtils = require("Main.Equip.EquipUtils")
local def = MountsUtils.define
local mountsCfg
def.static("=>", "table").GetAllMountsCfg = function()
  if mountsCfg ~= nil then
    return mountsCfg
  end
  mountsCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local mounts = {}
    mounts.id = record:GetIntValue("id")
    mounts.mountsName = record:GetStringValue("mountsName")
    mounts.mountsType = record:GetIntValue("mountsType")
    mounts.mountsModelId = record:GetIntValue("mountsModelId")
    mounts.mountsIconId = record:GetIntValue("mountsIconId")
    mounts.maxMountRoleNum = record:GetIntValue("maxMountRoleNum")
    mounts.displayOrder = record:GetIntValue("displayOrder")
    mounts.defaultDyeColorId = record:GetIntValue("defaultDyeColorId")
    mounts.starLifePictureId = record:GetIntValue("starLifePictureId")
    mounts.starLifePictureName = record:GetStringValue("starLifePictureName")
    mounts.mountsApproachOfAchieving = record:GetIntValue("mountsApproachOfAchieving")
    mounts.ornamentList = {}
    local ornamentListStruct = record:GetStructValue("ornamentListStruct")
    local size = ornamentListStruct:GetVectorSize("ornamentList")
    for i = 0, size - 1 do
      local ornament = ornamentListStruct:GetVectorValueByIdx("ornamentList", i)
      local ornamentName = ornament:GetStringValue("ornament")
      if ornamentName ~= nil then
        table.insert(mounts.ornamentList, ornamentName)
      end
    end
    mounts.actionList = {}
    local actionStruct = record:GetStructValue("actionStruct")
    local size = actionStruct:GetVectorSize("actionList")
    for i = 0, size - 1 do
      local rec = actionStruct:GetVectorValueByIdx("actionList", i)
      local action = rec:GetIntValue("action")
      table.insert(mounts.actionList, action)
    end
    mountsCfg[mounts.id] = mounts
  end
  return mountsCfg
end
def.static("number", "=>", "table").GetMountsCfgById = function(id)
  local mountsCfg = MountsUtils.GetAllMountsCfg()
  if mountsCfg == nil then
    return nil
  elseif mountsCfg[id] then
    return mountsCfg[id]
  else
    warn("GetMountsCfgById", id)
    return nil
  end
end
local mountsJinjieCfg
def.static("=>", "table").GetAllMountsJinjieCfg = function()
  if mountsJinjieCfg ~= nil then
    return mountsJinjieCfg
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_RANK_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  mountsJinjieCfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.mountsCfgId = DynamicRecord.GetIntValue(entry, "mountsCfgId")
    cfg.mountsRank = DynamicRecord.GetIntValue(entry, "mountsRank")
    cfg.rankUpCostMountsNum = DynamicRecord.GetIntValue(entry, "rankUpCostMountsNum")
    cfg.activeSkillCfgId = DynamicRecord.GetIntValue(entry, "activeSkillCfgId")
    cfg.activeSkillLevel = DynamicRecord.GetIntValue(entry, "activeSkillLevel")
    cfg.activeSkillIconColor = DynamicRecord.GetIntValue(entry, "activeSkillIconColor")
    cfg.needRoleLevel = DynamicRecord.GetIntValue(entry, "needRoleLevel")
    cfg.unlockItemId = DynamicRecord.GetIntValue(entry, "unlockItemId")
    cfg.unlockItemIdNum = DynamicRecord.GetIntValue(entry, "unlockItemIdNum")
    cfg.speed = DynamicRecord.GetIntValue(entry, "speed")
    cfg.rankUpcostItemType = DynamicRecord.GetIntValue(entry, "rankUpcostItemType")
    cfg.rankUpCostItemIdNum = DynamicRecord.GetIntValue(entry, "rankUpCostItemIdNum")
    cfg.rankUpNeedScoreNum = DynamicRecord.GetIntValue(entry, "rankUpNeedScoreNum")
    cfg.rankUpConvertScore = DynamicRecord.GetIntValue(entry, "rankUpConvertScore")
    cfg.property = {}
    for i = 1, 5 do
      local propType = DynamicRecord.GetIntValue(entry, string.format("propertyType%d", i))
      local propValue = DynamicRecord.GetIntValue(entry, string.format("propertyType%dValue", i))
      if propType ~= 0 then
        cfg.property[propType] = propValue
      end
    end
    cfg.ornamentOpenStateList = {}
    local ornamenOpenStatetListStruct = entry:GetStructValue("ornamenOpenStatetListStruct")
    local size = ornamenOpenStatetListStruct:GetVectorSize("ornamenOpenStatetList")
    for i = 0, size - 1 do
      local ornamentOpenStateData = ornamenOpenStatetListStruct:GetVectorValueByIdx("ornamenOpenStatetList", i)
      local ornamentOpenState = ornamentOpenStateData:GetIntValue("ornamenOpenState")
      if ornamentOpenState ~= nil then
        table.insert(cfg.ornamentOpenStateList, ornamentOpenState)
      end
    end
    cfg.boneEffectCfgList = {}
    local boneEffectCfgListStruct = entry:GetStructValue("boneEffectCfgListStruct")
    local size = boneEffectCfgListStruct:GetVectorSize("boneEffectCfgList")
    for i = 0, size - 1 do
      local boneEffectData = boneEffectCfgListStruct:GetVectorValueByIdx("boneEffectCfgList", i)
      local boneEffect = boneEffectData:GetIntValue("boneEffect")
      if boneEffect ~= nil then
        table.insert(cfg.boneEffectCfgList, boneEffect)
      end
    end
    mountsJinjieCfg[cfg.mountsCfgId] = mountsJinjieCfg[cfg.mountsCfgId] or {}
    mountsJinjieCfg[cfg.mountsCfgId][cfg.mountsRank] = cfg
    local lastMaxRank = mountsJinjieCfg[cfg.mountsCfgId].maxRank or 0
    if lastMaxRank < cfg.mountsRank then
      mountsJinjieCfg[cfg.mountsCfgId].maxRank = cfg.mountsRank
    end
  end
  return mountsJinjieCfg
end
def.static("number", "=>", "table").GetMountsJinjieCfg = function(id)
  local allMountsJinjieCfg = MountsUtils.GetAllMountsJinjieCfg()
  if allMountsJinjieCfg ~= nil then
    return mountsJinjieCfg[id]
  end
  return nil
end
def.static("number", "number", "=>", "table").GetMountsCfgOfRank = function(mountsId, rank)
  local jinjieCfg = MountsUtils.GetMountsJinjieCfg(mountsId)
  if jinjieCfg == nil then
    return nil
  end
  return jinjieCfg[rank]
end
local unlockMountsCfg
def.static("number", "=>", "table").GetUnlockMountsByItemId = function(itemId)
  if unlockMountsCfg ~= nil then
    return unlockMountsCfg[itemId]
  end
  unlockMountsCfg = {}
  local allMountsJinjieCfg = MountsUtils.GetAllMountsJinjieCfg()
  if allMountsJinjieCfg ~= nil then
    for mountsId, mountsJinjieCfg in pairs(allMountsJinjieCfg) do
      for k, jinjieCfg in pairs(mountsJinjieCfg) do
        if k ~= "maxRank" then
          local mountsCfg = MountsUtils.GetMountsCfgById(jinjieCfg.mountsCfgId)
          if mountsCfg ~= nil then
            if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
              local category = jinjieCfg.unlockItemId
              local categoryCfg = MountsUtils.GetAppearenceMountsUnlockCfgByCategory(category)
              if categoryCfg ~= nil then
                for i = 1, #categoryCfg do
                  unlockMountsCfg[categoryCfg[i].itemId] = jinjieCfg
                end
              end
            else
              unlockMountsCfg[jinjieCfg.unlockItemId] = jinjieCfg
            end
          end
        end
      end
    end
  end
  return unlockMountsCfg[itemId]
end
local apprenceMountsUnlockCfg
def.static("number", "=>", "table").GetAppearenceMountsUnlockCfgByCategory = function(category)
  if apprenceMountsUnlockCfg ~= nil then
    return apprenceMountsUnlockCfg[category]
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_APPEARENCE_UNLOCK_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  apprenceMountsUnlockCfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.itemId = DynamicRecord.GetIntValue(entry, "itemId")
    cfg.itemCategory = DynamicRecord.GetIntValue(entry, "itemCategory")
    cfg.lastTime = DynamicRecord.GetIntValue(entry, "lastTime")
    apprenceMountsUnlockCfg[cfg.itemCategory] = apprenceMountsUnlockCfg[cfg.itemCategory] or {}
    table.insert(apprenceMountsUnlockCfg[cfg.itemCategory], cfg)
  end
  return apprenceMountsUnlockCfg[category]
end
def.static("number", "=>", "table").GetMountsActiveSkillRankChange = function(mountsId)
  local jinjieCfg = MountsUtils.GetMountsJinjieCfg(mountsId)
  if jinjieCfg == nil then
    return nil
  end
  local skillChange = {}
  for i = constant.CMountsConsts.maxMountsRank, 1, -1 do
    if jinjieCfg[i] ~= nil then
      skillChange[i] = {}
      skillChange[i].skillId = jinjieCfg[i].activeSkillCfgId
      skillChange[i].skillLevel = jinjieCfg[i].activeSkillLevel
      if i == constant.CMountsConsts.maxMountsRank or skillChange[i + 1] == nil then
        skillChange[i].nextSkillRank = -1
      elseif skillChange[i + 1].skillId ~= jinjieCfg[i].activeSkillCfgId then
        skillChange[i].nextSkillRank = i + 1
      else
        skillChange[i].nextSkillRank = skillChange[i + 1].nextSkillRank
      end
    end
  end
  return skillChange
end
local mountsPassiveSkillCfg
def.static("number", "=>", "table").GetMountsPassiveSkillCfg = function(id)
  if mountsPassiveSkillCfg ~= nil then
    return mountsPassiveSkillCfg[id]
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_SKILL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  mountsPassiveSkillCfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.mountsCfgId = DynamicRecord.GetIntValue(entry, "mountsCfgId")
    cfg.passiveSkillRank = DynamicRecord.GetIntValue(entry, "passiveSkillRank")
    cfg.passiveSkillCfgId = DynamicRecord.GetIntValue(entry, "passiveSkillCfgId")
    cfg.passiveSkillIconColor = DynamicRecord.GetIntValue(entry, "passiveSkillIconColor")
    mountsPassiveSkillCfg[cfg.mountsCfgId] = mountsPassiveSkillCfg[cfg.mountsCfgId] or {}
    mountsPassiveSkillCfg[cfg.mountsCfgId][cfg.passiveSkillRank] = mountsPassiveSkillCfg[cfg.mountsCfgId][cfg.passiveSkillRank] or {}
    table.insert(mountsPassiveSkillCfg[cfg.mountsCfgId][cfg.passiveSkillRank], cfg)
  end
  return mountsPassiveSkillCfg[id]
end
def.static("=>", "table").GetAllMountsPassiveSkillCfg = function()
  if mountsPassiveSkillCfg ~= nil then
    return mountsPassiveSkillCfg
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_SKILL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  mountsPassiveSkillCfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.mountsCfgId = DynamicRecord.GetIntValue(entry, "mountsCfgId")
    cfg.passiveSkillRank = DynamicRecord.GetIntValue(entry, "passiveSkillRank")
    cfg.passiveSkillCfgId = DynamicRecord.GetIntValue(entry, "passiveSkillCfgId")
    cfg.passiveSkillIconColor = DynamicRecord.GetIntValue(entry, "passiveSkillIconColor")
    mountsPassiveSkillCfg[cfg.mountsCfgId] = mountsPassiveSkillCfg[cfg.mountsCfgId] or {}
    mountsPassiveSkillCfg[cfg.mountsCfgId][cfg.passiveSkillRank] = mountsPassiveSkillCfg[cfg.mountsCfgId][cfg.passiveSkillRank] or {}
    table.insert(mountsPassiveSkillCfg[cfg.mountsCfgId][cfg.passiveSkillRank], cfg)
  end
  return mountsPassiveSkillCfg
end
def.static("number", "=>", "table").GetMountsSortedUnlockPassiveSkillRank = function(mountsId)
  local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfg(mountsId)
  local unlockSkillRank = {}
  if passiveSkillCfg ~= nil then
    for k, v in pairs(passiveSkillCfg) do
      table.insert(unlockSkillRank, k)
    end
  end
  table.sort(unlockSkillRank, function(a, b)
    return a < b
  end)
  return unlockSkillRank
end
def.static("number", "number", "=>", "table").GetMountsRankPassiveSkillCfg = function(mountsId, rank)
  local skillRanks = MountsUtils.GetMountsSortedUnlockPassiveSkillRank(mountsId)
  local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfg(mountsId)
  if skillRanks == nil or passiveSkillCfg == nil then
    return nil
  end
  for i = #skillRanks, 1, -1 do
    if rank >= skillRanks[i] then
      return passiveSkillCfg[skillRanks[i]]
    end
  end
  return nil
end
local allMountsSkillCfgs
def.static("number", "=>", "table").GetMountsPassiveSkillCfgBySkillId = function(skillId)
  if allMountsSkillCfgs and allMountsSkillCfgs[skillId] then
    return allMountsSkillCfgs[skillId]
  end
  local passiveSkillCfgs = MountsUtils.GetAllMountsPassiveSkillCfg()
  if passiveSkillCfgs == nil then
    return nil
  end
  for k, v in pairs(passiveSkillCfgs) do
    for k1, v1 in pairs(v) do
      if v1 ~= nil then
        for idx, skill in pairs(v1) do
          if skill.passiveSkillCfgId == skillId then
            if allMountsSkillCfgs == nil then
              allMountsSkillCfgs = {}
            end
            allMountsSkillCfgs[skillId] = skill
            return skill
          end
        end
      end
    end
  end
  return nil
end
def.static("number", "number", "=>", "table").GetMountsPassiveSkillCfgByMountsIdAndSkillId = function(mountsId, skillId)
  local skillRanks = MountsUtils.GetMountsSortedUnlockPassiveSkillRank(mountsId)
  local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfg(mountsId)
  if skillRanks == nil or passiveSkillCfg == nil then
    warn("not mounts passive skill")
    return nil
  end
  for i = #skillRanks, 1, -1 do
    local skills = passiveSkillCfg[skillRanks[i]]
    if skills ~= nil then
      for idx, skill in pairs(skills) do
        if skill.passiveSkillCfgId == skillId then
          return skill
        end
      end
    end
  end
  warn("not mounts passive skill")
  return nil
end
def.static("number", "=>", "number").GetCellUnlockLevel = function(cell)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MOUNTS_BATTLE_CELL_CFG, cell)
  if record == nil then
    warn("no battle mounts cell:" .. cell)
    return 0
  end
  return record:GetIntValue("unLockRoleLevel")
end
local mountsPassiveSkillRefreshCfg
def.static("number", "=>", "table").GetMountsPassiveSkillRefreshCfg = function(id)
  if mountsPassiveSkillRefreshCfg ~= nil then
    return mountsPassiveSkillRefreshCfg[id]
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_SKILL_REFRESH_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  mountsPassiveSkillRefreshCfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.mountsCfgId = DynamicRecord.GetIntValue(entry, "mountsCfgId")
    cfg.passiveSkillRank = DynamicRecord.GetIntValue(entry, "passiveSkillRank")
    cfg.refreshCostItemId = DynamicRecord.GetIntValue(entry, "refreshCostItemId")
    cfg.refreshCostItemType = DynamicRecord.GetIntValue(entry, "refreshCostItemType")
    cfg.refreshCostItemNum = DynamicRecord.GetIntValue(entry, "refreshCostItemNum")
    mountsPassiveSkillRefreshCfg[cfg.mountsCfgId] = mountsPassiveSkillRefreshCfg[cfg.mountsCfgId] or {}
    mountsPassiveSkillRefreshCfg[cfg.mountsCfgId][cfg.passiveSkillRank] = cfg
  end
  return mountsPassiveSkillRefreshCfg[id]
end
def.static("number", "number", "=>", "table").GetMountsPassiveSkillRefreshCfgOfRank = function(mountsId, rank)
  local refreshCfg = MountsUtils.GetMountsPassiveSkillRefreshCfg(mountsId)
  if refreshCfg == nil then
    return nil
  end
  return refreshCfg[rank]
end
def.static("number", "=>", "number").GetMountsReplacePrice = function(itemId)
  local mallType = require("consts.mzm.gsp.mall.confbean.MallType")
  local mallUitls = require("Main.Mall.MallUtility")
  return mallUitls.GetPriceByItemId(itemId)
end
local mountsDyeColorCfg
def.static("number", "=>", "table").GetMountsDyeColorCfg = function(id)
  if mountsDyeColorCfg ~= nil then
    return mountsDyeColorCfg[id]
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_DYE_COLOR_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  mountsDyeColorCfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.mountsCfgId = DynamicRecord.GetIntValue(entry, "mountsCfgId")
    cfg.modelColorId = DynamicRecord.GetIntValue(entry, "colorId")
    cfg.index = DynamicRecord.GetIntValue(entry, "index")
    cfg.itemId = DynamicRecord.GetIntValue(entry, "itemid")
    cfg.costItemType = DynamicRecord.GetIntValue(entry, "costItemType")
    cfg.itemCount = DynamicRecord.GetIntValue(entry, "itemcount")
    mountsDyeColorCfg[cfg.mountsCfgId] = mountsDyeColorCfg[cfg.mountsCfgId] or {}
    table.insert(mountsDyeColorCfg[cfg.mountsCfgId], cfg)
  end
  return mountsDyeColorCfg[id]
end
def.static("number", "number", "=>", "table").GetMountsDyeColrByColorId = function(mountsId, colorId)
  local colorCfg = MountsUtils.GetMountsDyeColorCfg(mountsId)
  if colorCfg == nil then
    return nil
  end
  for idx, color in pairs(colorCfg) do
    if color.id == colorId then
      return color
    end
  end
  return nil
end
def.static("userdata", "number", "number", "number", "function", "=>", "table").LoadMountsModel = function(model, mountsCfgId, rank, colorId, callback)
  local MountsUIModel = require("Main.Mounts.MountsUIModel")
  local uiModel = MountsUIModel.new(mountsCfgId, model)
  uiModel:LoadDefault(function()
    uiModel:SetMountsColor(colorId)
    uiModel:SetMountsRank(rank)
    if callback ~= nil then
      callback()
    end
  end)
  uiModel:SetCanExceedBound(true)
  return uiModel
end
def.static("number", "number", "number", "=>", "table").GetMountsDetailInfo = function(mountsId, rank, colorId)
  local mountsCfg = MountsUtils.GetMountsCfgById(mountsId)
  if mountsCfg == nil then
    return nil
  end
  local mountsDetail = {}
  mountsDetail.mountsModelId = mountsCfg.mountsModelId
  mountsDetail.ornament = MountsUtils.GetMountsRankOrnamentCfg(mountsId, rank) or {}
  mountsDetail.boneEffects = MountsUtils.GetMountsRankBoneEffectsCfg(mountsId, rank) or {}
  local colorCfg = MountsUtils.GetMountsDyeColrByColorId(mountsId, colorId)
  if colorCfg == nil then
    colorCfg = MountsUtils.GetMountsDyeColrByColorId(mountsId, mountsCfg.defaultDyeColorId)
  end
  if colorCfg then
    mountsDetail.colorId = colorCfg.modelColorId
  else
    mountsDetail.colorId = 0
  end
  mountsDetail.actionList = clone(mountsCfg.actionList)
  return mountsDetail
end
def.static("number", "number", "=>", "table").GetMountsRankOrnamentCfg = function(mountsId, rank)
  local mountsCfg = MountsUtils.GetMountsCfgById(mountsId)
  local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(mountsId, rank)
  if mountsCfg == nil or mountsRankCfg == nil then
    return nil
  end
  local ornament = {}
  for i = 1, #mountsCfg.ornamentList do
    if mountsRankCfg.ornamentOpenStateList[i] ~= nil then
      local ornamentName = mountsCfg.ornamentList[i]
      local state = mountsRankCfg.ornamentOpenStateList[i] == OrnamentOpenEnum.YES_OPEN
      ornament[ornamentName] = state
    end
  end
  return ornament
end
def.static("number", "number", "=>", "table").GetMountsRankBoneEffectsCfg = function(mountsId, rank)
  local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(mountsId, rank)
  if mountsRankCfg == nil then
    return nil
  end
  return mountsRankCfg.boneEffectCfgList
end
local mountsStarLifeMapCfg
def.static("number", "=>", "table").GetMountsStartLifeMapCfg = function(id)
  if mountsStarLifeMapCfg ~= nil then
    return mountsStarLifeMapCfg[id]
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_STAR_MAP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  mountsStarLifeMapCfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.mountsCfgId = DynamicRecord.GetIntValue(entry, "mountsCfgId")
    cfg.starNum = DynamicRecord.GetIntValue(entry, "starNum")
    cfg.coordinateX = DynamicRecord.GetIntValue(entry, "coordinateX")
    cfg.coordinateY = DynamicRecord.GetIntValue(entry, "coordinateY")
    mountsStarLifeMapCfg[cfg.mountsCfgId] = mountsStarLifeMapCfg[cfg.mountsCfgId] or {}
    table.insert(mountsStarLifeMapCfg[cfg.mountsCfgId], cfg)
  end
  for k, v in pairs(mountsStarLifeMapCfg) do
    table.sort(v, function(a, b)
      return a.starNum < b.starNum
    end)
  end
  return mountsStarLifeMapCfg[id]
end
local mountsStarLifeCfg
def.static("number", "=>", "table").GetMountsStartLifeCfgById = function(id)
  if mountsStarLifeCfg ~= nil then
    return mountsStarLifeCfg[id]
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_STAR_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  mountsStarLifeCfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.mountsCfgId = DynamicRecord.GetIntValue(entry, "mountsCfgId")
    cfg.starLevel = DynamicRecord.GetIntValue(entry, "starLevel")
    cfg.starNum = DynamicRecord.GetIntValue(entry, "starNum")
    cfg.unLockRank = DynamicRecord.GetIntValue(entry, "unLockRank")
    cfg.costItemId = DynamicRecord.GetIntValue(entry, "costItemId")
    cfg.costItemType = DynamicRecord.GetIntValue(entry, "costItemType")
    cfg.costItemNum = DynamicRecord.GetIntValue(entry, "costItemNum")
    local proList = {}
    local proListStruct = entry:GetStructValue("proListStruct")
    local size = proListStruct:GetVectorSize("proList")
    for i = 0, size - 1 do
      local proData = proListStruct:GetVectorValueByIdx("proList", i)
      local property = proData:GetIntValue("propertyType")
      if property ~= nil then
        table.insert(proList, property)
      end
    end
    local proValueList = {}
    local proValueListStruct = entry:GetStructValue("proValueListStruct")
    local size = proValueListStruct:GetVectorSize("proValueList")
    for i = 0, size - 1 do
      local proValueData = proValueListStruct:GetVectorValueByIdx("proValueList", i)
      local propertyValue = proValueData:GetIntValue("propertyValue")
      if propertyValue ~= nil then
        table.insert(proValueList, propertyValue)
      end
    end
    cfg.propertyList = {}
    for i = 1, #proList do
      if proValueList[i] ~= nil then
        local property = {}
        property.nameKey = proList[i]
        property.value = proValueList[i]
        table.insert(cfg.propertyList, property)
      end
    end
    mountsStarLifeCfg[cfg.mountsCfgId] = mountsStarLifeCfg[cfg.mountsCfgId] or {}
    mountsStarLifeCfg[cfg.mountsCfgId][cfg.starNum] = mountsStarLifeCfg[cfg.mountsCfgId][cfg.starNum] or {}
    mountsStarLifeCfg[cfg.mountsCfgId][cfg.starNum][cfg.starLevel] = cfg
  end
  return mountsStarLifeCfg[id]
end
def.static("number", "=>", "table").GetMountsRankUpItemMaterialIds = function(needType)
  local materials = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    local mountsType = DynamicRecord.GetIntValue(entry, "mountsType")
    if needType == mountsType then
      table.insert(materials, id)
    end
  end
  return materials
end
def.static("number", "=>", "table").GetMountsRankUpItemChipMaterialIds = function(needType)
  local materials = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_CHIP_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    local mountsType = DynamicRecord.GetIntValue(entry, "mountsType")
    if needType == mountsType then
      table.insert(materials, id)
    end
  end
  return materials
end
def.static("number", "=>", "number").GetMountsRankUpItemMaterialScore = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MOUNTS_ITEM_CFG, itemId)
  if record ~= nil then
    return record:GetIntValue("addMountsScore")
  end
  record = DynamicData.GetRecord(CFG_PATH.DATA_MOUNTS_CHIP_ITEM_CFG, itemId)
  if record ~= nil then
    return record:GetIntValue("addMountsScore")
  end
  warn("no mounts related item:" .. itemId)
  return 0
end
def.static("number", "=>", "number").GetMountsSkillColor = function(colorId)
  local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
  local skillColor = {
    ItemColor.ORANGE,
    ItemColor.PURPLE,
    ItemColor.BLUE
  }
  return skillColor[colorId] or ItemColor.BLUE
end
def.static("number", "=>", "table").GetMountsAvailableRank = function(mountsId)
  local availableRank = {}
  for i = 1, constant.CMountsConsts.maxMountsRank do
    local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(mountsId, i)
    if mountsRankCfg ~= nil then
      table.insert(availableRank, i)
    end
  end
  return availableRank
end
def.static("table", "=>", "number").CalculateMountsPropertyScore = function(property)
  local score = 0
  if property ~= nil then
    for k, v in pairs(property) do
      local factor = EquipUtils.GetPropertyFactor(k)
      score = score + v * factor
    end
  end
  return math.floor(score)
end
def.static("=>", "table").GetMountsProtectPetsUnlockCfg = function()
  local unlockList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOUNTS_PROTECTED_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.protectIndex = DynamicRecord.GetIntValue(entry, "protectIndex")
    cfg.openLevel = DynamicRecord.GetIntValue(entry, "openLevel")
    cfg.minMountsRank = DynamicRecord.GetIntValue(entry, "minMountsRank")
    cfg.costItemId = DynamicRecord.GetIntValue(entry, "costItemId")
    cfg.costItemType = DynamicRecord.GetIntValue(entry, "costItemType")
    cfg.costItemNum = DynamicRecord.GetIntValue(entry, "costItemNum")
    table.insert(unlockList, cfg)
  end
  table.sort(unlockList, function(a, b)
    return a.protectIndex < b.protectIndex
  end)
  return unlockList
end
def.static("number", "=>", "boolean").IsMountsProtectPetsUnlockItemType = function(itemType)
  local unlockList = MountsUtils.GetMountsProtectPetsUnlockCfg()
  for i = 1, #unlockList do
    if unlockList[i].costItemType == itemType then
      return true
    end
  end
  return false
end
MountsUtils.Commit()
return MountsUtils
