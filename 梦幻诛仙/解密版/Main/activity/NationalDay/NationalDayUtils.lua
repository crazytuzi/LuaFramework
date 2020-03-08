local Lplus = require("Lplus")
local NationalDayUtils = Lplus.Class("NationalDayUtils")
local def = NationalDayUtils.define
def.static("number", "=>", "table").GetBirthPrayCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BIRTH_PRAY_CFG, id)
  if record == nil then
    warn("[GetBirthPrayCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.idip = record:GetIntValue("idip")
  cfg.tipsId = record:GetIntValue("tipsId")
  local taskIdStruct = record:GetStructValue("taskIdStruct")
  local count = taskIdStruct:GetVectorSize("taskIdList")
  cfg.taskIds = {}
  cfg.graphIds = {}
  for i = 1, count do
    local rec = taskIdStruct:GetVectorValueByIdx("taskIdList", i - 1)
    local taskId = rec:GetIntValue("taskId")
    if taskId > 0 then
      table.insert(cfg.taskIds, taskId)
    end
    rec = taskIdStruct:GetVectorValueByIdx("graphIdList", i - 1)
    local graphId = rec:GetIntValue("graphId")
    if graphId > 0 then
      table.insert(cfg.graphIds, graphId)
    end
  end
  return cfg
end
def.static("=>", "table").GetBirthPrayRewardCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BIRTH_PRAY_REWARD_CFG)
  local size = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, size do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local activityId = record:GetIntValue("activityId")
    if activityId == constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID then
      local task = {}
      task.id = record:GetIntValue("taskId")
      local stageStruct = record:GetStructValue("stageStruct")
      local count = stageStruct:GetVectorSize("stageList")
      task.stages = {}
      for j = 1, count do
        local rec = stageStruct:GetVectorValueByIdx("stageList", j - 1)
        local stage = rec:GetIntValue("stage")
        if stage > 0 then
          table.insert(task.stages, stage)
        end
      end
      local rewardStruct = record:GetStructValue("rewardStruct")
      local count = rewardStruct:GetVectorSize("rewardList")
      task.rewards = {}
      for j = 1, count do
        local rec = rewardStruct:GetVectorValueByIdx("rewardList", j - 1)
        local reward = rec:GetIntValue("reward")
        if reward > 0 then
          table.insert(task.rewards, reward)
        end
      end
      table.insert(cfg, task)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "=>", "table").GetBreakEggCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BREAK_EGG_CFG, id)
  if record == nil then
    warn("[GetBreakEggCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.idip = record:GetIntValue("idip")
  cfg.inviteType = record:GetIntValue("inviteType")
  cfg.totalEggNum = record:GetIntValue("totalEggNum")
  cfg.inviteeRewardTimes = record:GetIntValue("inviteeRewardTimes")
  cfg.breakCountdownTime = record:GetIntValue("breakCountdownTime")
  cfg.beginEffectId = record:GetIntValue("beginEffectId")
  cfg.breakEffectId = record:GetIntValue("breakEffectId")
  cfg.tipsId = record:GetIntValue("tipsId")
  return cfg
end
def.static("number", "=>", "table").GetInviteConfirmCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_INVITE_CONFIRM_CFG, id)
  if record == nil then
    warn("[GetInviteConfirmCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.inviteType = record:GetIntValue("inviteType")
  cfg.channelType = record:GetIntValue("channelType")
  cfg.inviteRoleNum = record:GetIntValue("inviteRoleNum")
  cfg.countdownTime = record:GetIntValue("countdownTime")
  cfg.inviteDes = record:GetStringValue("inviteDes")
  return cfg
end
def.static("number", "=>", "table").GetMooncakeIngredientCfg = function(groupId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COOK_MOONCAKE_CFG, groupId)
  if record == nil then
    warn("[GetMooncakeIngredientCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.groupId = record:GetIntValue("composeGroupId")
  cfg.idip = record:GetIntValue("idip")
  cfg.tipsId = record:GetIntValue("tipsId")
  local ingredientStruct = record:GetStructValue("ingredientStruct")
  local count = ingredientStruct:GetVectorSize("mustList")
  cfg.requisite = {}
  for i = 1, count do
    local rec = ingredientStruct:GetVectorValueByIdx("mustList", i - 1)
    local itemId = rec:GetIntValue("itemId")
    if itemId > 0 then
      table.insert(cfg.requisite, itemId)
    end
  end
  count = ingredientStruct:GetVectorSize("optionList")
  cfg.options = {}
  for i = 1, count do
    local rec = ingredientStruct:GetVectorValueByIdx("optionList", i - 1)
    local itemId = rec:GetIntValue("itemId")
    if itemId > 0 then
      table.insert(cfg.options, itemId)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetMooncakeComposeCfg = function(groupId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MOONCAKE_COMPOSE_CFG, groupId)
  if record == nil then
    warn("[GetMooncakeComposeCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.groupId = record:GetIntValue("groupId")
  local groupStruct = record:GetStructValue("groupStruct")
  local product_num = groupStruct:GetVectorSize("composeList")
  cfg.products = {}
  for idx = 1, product_num do
    local subrec = groupStruct:GetVectorValueByIdx("composeList", idx - 1)
    local product = {}
    cfg.products[idx] = product
    product.createItemId = subrec:GetIntValue("createItemId")
    product.createItemNum = subrec:GetIntValue("createItemNum")
    local composeStruct = subrec:GetStructValue("composeStruct")
    local count = composeStruct:GetVectorSize("costItemIdList")
    product.itemIds = {}
    product.itemNums = {}
    for i = 1, count do
      local rec = composeStruct:GetVectorValueByIdx("costItemIdList", i - 1)
      local itemId = rec:GetIntValue("itemId")
      if itemId > 0 then
        table.insert(product.itemIds, itemId)
      end
      rec = composeStruct:GetVectorValueByIdx("costItemNumList", i - 1)
      local itemNum = rec:GetIntValue("itemNum")
      if itemNum > 0 then
        table.insert(product.itemNums, itemNum)
      end
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetSkyLanternCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SKY_LANTERN_CFG, id)
  if record == nil then
    warn("[GetSkyLanternCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.idip = record:GetIntValue("openId")
  cfg.mapCfgId = record:GetIntValue("mapCfgId")
  cfg.mapTransferX = record:GetIntValue("mapTransferX")
  cfg.mapTransferY = record:GetIntValue("mapTransferY")
  cfg.cardItemCfgId = record:GetIntValue("cardItemCfgId")
  cfg.maxLanternNum = record:GetIntValue("maxLanternNum")
  cfg.selfEffectId = record:GetIntValue("selfEffectId")
  cfg.otherEffectId = record:GetIntValue("otherEffectId")
  return cfg
end
NationalDayUtils.Commit()
return NationalDayUtils
