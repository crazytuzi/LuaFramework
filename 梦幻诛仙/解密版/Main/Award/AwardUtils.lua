local Lplus = require("Lplus")
local AwardUtils = Lplus.Class("AwardUtils")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local def = AwardUtils.define
def.static("string", "=>", "dynamic").GetCommonAwardConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_AWARD_CONSTS_CFG, key)
  if record == nil then
    warn("GetCommonAwardConsts(" .. key .. ") return nil")
    return nil
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  return value
end
def.static("string", "=>", "number").GetAwardConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AWARD_CONSTS_CFG, key)
  if record == nil then
    warn("GetAwardConsts(" .. key .. ") return nil")
    return 0
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  return value
end
def.static("=>", "table").GetAwardOrderCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AWARD_BAG_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.awardType = record:GetIntValue("gifttype")
    cfg.sortOrder = record:GetIntValue("sort")
    cfgs[cfg.awardType] = cfg.sortOrder
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetDailySignInAwardCfg = function(date)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AWARD_DAILY_SIGNIN_CFG, date)
  if record == nil then
    warn("GetDailySignInAwardCfg(" .. date .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.date = date
  cfg.awardType = record:GetIntValue("gifttype")
  cfg.itemId = record:GetIntValue("itemid")
  cfg.itemCount = record:GetIntValue("itemcount")
  return cfg
end
def.static("number", "=>", "table").GetWholeMonthDailySignInAwardCfgs = function(date)
  local yearMonth = date - date % 100
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AWARD_DAILY_SIGNIN_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.date = record:GetIntValue("key")
    local cfgYearMonth = cfg.date - cfg.date % 100
    if yearMonth == cfgYearMonth then
      cfg.awardType = record:GetIntValue("gifttype")
      cfg.itemId = record:GetIntValue("itemid")
      cfg.itemCount = record:GetIntValue("itemcount")
      cfgs[cfg.date] = cfg
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("=>", "table").GetOverallLoginAwardCfgList = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AWARD_ACCUMULATIVE_LOGININ_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.loginCount = record:GetIntValue("logincount")
    cfg.awardType = record:GetIntValue("gifttype")
    cfg.desc = record:GetStringValue("desc") or ""
    cfg.items = {}
    local itemsStruct = record:GetStructValue("itemsStruct")
    local size = itemsStruct:GetVectorSize("itemsVector")
    for i = 0, size - 1 do
      local vectorRow = itemsStruct:GetVectorValueByIdx("itemsVector", i)
      local row = {}
      row.itemId = vectorRow:GetIntValue("itemid")
      row.itemCount = vectorRow:GetIntValue("itemcount")
      table.insert(cfg.items, row)
    end
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
local cache = {key = nil, data = nil}
def.static("number", "number", "=>", "table").GetOverallLevelUpAwardCfgList = function(occupation, gender)
  local genKey = function(occupation, gender)
    return occupation * 100 + gender
  end
  local key = genKey(occupation, gender)
  if key == cache.key then
    return cache.data
  end
  local cfgs = AwardUtils._LoadOverallLevelUpAwardCfgList(occupation, gender)
  cache.key = key
  cache.data = cfgs
  return cfgs
end
def.static("=>", "table").GetOverallOnlineAwardCfgList = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AWARD_ONLINE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.time = record:GetIntValue("time") * 60
    cfg.sortId = record:GetIntValue("sortId")
    cfg.items = {}
    local itemsStruct = record:GetStructValue("itemsStruct")
    local size = itemsStruct:GetVectorSize("itemsVector")
    for i = 0, size - 1 do
      local vectorRow = itemsStruct:GetVectorValueByIdx("itemsVector", i)
      local row = {}
      row.itemId = vectorRow:GetIntValue("itemid")
      row.itemCount = vectorRow:GetIntValue("itemcount")
      table.insert(cfg.items, row)
    end
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "number", "=>", "table")._LoadOverallLevelUpAwardCfgList = function(occupation, gender)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AWARD_LEVEL_UP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.key = record:GetStringValue("key")
    local keyTable = string.split(cfg.key, "_")
    cfg.level, cfg.occupation, cfg.gender = unpack(keyTable)
    cfg.level = tonumber(cfg.level)
    cfg.occupation = tonumber(cfg.occupation)
    cfg.gender = tonumber(cfg.gender)
    if cfg.occupation == occupation and cfg.gender == gender then
      cfg.gifttype = record:GetIntValue("gifttype")
      cfg.giftbagname = record:GetStringValue("giftbagname")
      cfg.items = {}
      local itemsStruct = record:GetStructValue("itemsStruct")
      local size = itemsStruct:GetVectorSize("itemsVector")
      for i = 0, size - 1 do
        local vectorRow = itemsStruct:GetVectorValueByIdx("itemsVector", i)
        local row = {}
        row.itemId = vectorRow:GetIntValue("itemid")
        row.itemCount = vectorRow:GetIntValue("itemcount")
        table.insert(cfg.items, row)
      end
      table.insert(cfgs, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("string", "=>", "number").GetStorageExpConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_STORAGE_EXP_CONSTS, key)
  if record == nil then
    warn("GetStorageExpConsts(" .. key .. ") return nil")
    return 0
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  return value
end
def.static("table", "=>", "boolean").Check2NoticeAward = function(item2num)
  if item2num then
    local awards = {
      items = {}
    }
    for itemId, num in pairs(item2num) do
      local award = {itemId = itemId, num = num}
      table.insert(awards.items, award)
    end
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DRAW_AWARD_MESSAGE, awards)
    return true
  else
    return false
  end
end
def.static("table", "string", "=>", "table").GetHtmlTextsFromAwardBean = function(awardInfo, customPrefix)
  local function unpackCommonTableMsg(msgs)
    return unpack(PersonalHelper.DecompCommonTableMsg(msgs))
  end
  local htmlTexts = {}
  local personAward = {}
  table.insert(personAward, {
    PersonalHelper.Type.Text,
    customPrefix
  })
  if awardInfo.yuanbao and awardInfo.yuanbao:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Yuanbao,
      awardInfo.yuanbao
    })
  end
  if 0 < awardInfo.roleExp then
    table.insert(personAward, {
      PersonalHelper.Type.RoleExp,
      awardInfo.roleExp
    })
    if awardInfo.awardAddMap then
      local expadd = awardInfo.awardAddMap[awardInfo.AWARD_TYPE__ROLE_EXP]
      expadd = expadd and expadd.addValues
      if expadd and next(expadd) and (expadd[awardInfo.AWARD_ADD_TYPE__LEADER] or expadd[awardInfo.AWARD_ADD_TYPE__TEAM] or expadd[awardInfo.AWARD_ADD_TYPE__STABLE_TEAM] or expadd[awardInfo.AWARD_MOD_TYPE__SERVER] or expadd[awardInfo.AWARD_MOD_TYPE__QQ_N_VIP] or expadd[awardInfo.AWARD_MOD_TYPE__QQ_S_VIP] or expadd[awardInfo.AWARD_MOD_TYPE__QQ_GAME_CENTER] or expadd[awardInfo.AWARD_MOD_TYPE__WECAHT_GAME_CENTER] or expadd[awardInfo.AWARD_MOD_TYPE__APP_GAME_CENTER]) then
        table.insert(personAward, {
          PersonalHelper.Type.Text,
          "(" .. textRes.AnnounceMent[51]
        })
        local first = true
        local add = expadd[awardInfo.AWARD_ADD_TYPE__LEADER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[48] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[48] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_ADD_TYPE__TEAM]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[49] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[49] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_ADD_TYPE__STABLE_TEAM]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[50] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[50] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__SERVER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[68] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[68] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__QQ_N_VIP]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[77] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[77] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__QQ_S_VIP]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[78] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[78] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__QQ_GAME_CENTER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[79] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[79] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__WECAHT_GAME_CENTER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[80] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[80] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__APP_GAME_CENTER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[81] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[81] .. add
            })
          end
        end
        table.insert(personAward, {
          PersonalHelper.Type.Text,
          ")"
        })
      end
    end
  end
  if awardInfo.gold and awardInfo.gold:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Gold,
      awardInfo.gold
    })
  end
  if awardInfo.goldIngot and 0 < awardInfo.goldIngot then
    table.insert(personAward, {
      PersonalHelper.Type.JinDing,
      awardInfo.goldIngot
    })
  end
  if awardInfo.silver and awardInfo.silver:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Silver,
      awardInfo.silver
    })
    if awardInfo.awardAddMap then
      local expadd = awardInfo.awardAddMap[awardInfo.AWARD_TYPE__SILVER]
      expadd = expadd and expadd.addValues
      if expadd and next(expadd) and (expadd[awardInfo.AWARD_ADD_TYPE__LEADER] or expadd[awardInfo.AWARD_ADD_TYPE__TEAM] or expadd[awardInfo.AWARD_ADD_TYPE__STABLE_TEAM] or expadd[awardInfo.AWARD_MOD_TYPE__SERVER] or expadd[awardInfo.AWARD_MOD_TYPE__QQ_N_VIP] or expadd[awardInfo.AWARD_MOD_TYPE__QQ_S_VIP] or expadd[awardInfo.AWARD_MOD_TYPE__QQ_GAME_CENTER] or expadd[awardInfo.AWARD_MOD_TYPE__WECAHT_GAME_CENTER] or expadd[awardInfo.AWARD_MOD_TYPE__APP_GAME_CENTER]) then
        table.insert(personAward, {
          PersonalHelper.Type.Text,
          "(" .. textRes.AnnounceMent[51]
        })
        local first = true
        local add = expadd[awardInfo.AWARD_ADD_TYPE__LEADER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[48] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[48] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_ADD_TYPE__TEAM]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[49] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[49] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_ADD_TYPE__STABLE_TEAM]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[50] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[50] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__SERVER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[68] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[68] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__QQ_N_VIP]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[77] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[77] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__QQ_S_VIP]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[78] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[78] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__QQ_GAME_CENTER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[79] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[79] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__WECAHT_GAME_CENTER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[80] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[80] .. add
            })
          end
        end
        add = expadd[awardInfo.AWARD_MOD_TYPE__APP_GAME_CENTER]
        if add and add > 0 then
          if first then
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[81] .. add
            })
            first = false
          else
            table.insert(personAward, {
              PersonalHelper.Type.Text,
              textRes.AnnounceMent[52] .. textRes.AnnounceMent[81] .. add
            })
          end
        end
        table.insert(personAward, {
          PersonalHelper.Type.Text,
          ")"
        })
      end
    end
  end
  if awardInfo.gang and 0 < awardInfo.gang then
    table.insert(personAward, {
      PersonalHelper.Type.Gang,
      awardInfo.gang
    })
  end
  local storageExp = awardInfo.storageExp
  if storageExp and storageExp > 0 then
    table.insert(personAward, {
      PersonalHelper.Type.StorageExp,
      storageExp
    })
  end
  if #personAward > 1 then
    local htmlText = PersonalHelper.ToString(unpackCommonTableMsg(personAward))
    table.insert(htmlTexts, htmlText)
  end
  if not awardInfo.xiulianExp or 0 < awardInfo.xiulianExp then
  end
  if awardInfo.tokenMap then
    local tokenMap = awardInfo.tokenMap
    local tokenAward = {}
    table.insert(tokenAward, {
      PersonalHelper.Type.Text,
      customPrefix
    })
    if tokenMap[TokenType.XIAYI_VALUE] and 0 < tokenMap[TokenType.XIAYI_VALUE] then
      table.insert(tokenAward, {
        PersonalHelper.Type.Xiayi,
        tokenMap[TokenType.XIAYI_VALUE]
      })
    end
    if tokenMap[TokenType.JINGJICHANG_JIFEN] and 0 < tokenMap[TokenType.JINGJICHANG_JIFEN] then
      table.insert(tokenAward, {
        PersonalHelper.Type.JJC,
        tokenMap[TokenType.JINGJICHANG_JIFEN]
      })
    end
    if tokenMap[TokenType.SHIMEN_VALUE] and 0 < tokenMap[TokenType.SHIMEN_VALUE] then
      table.insert(tokenAward, {
        PersonalHelper.Type.Shimen,
        tokenMap[TokenType.SHIMEN_VALUE]
      })
    end
    if tokenMap[TokenType.REPUTATION_VALUE] and 0 < tokenMap[TokenType.REPUTATION_VALUE] then
      table.insert(tokenAward, {
        PersonalHelper.Type.Shengwang,
        tokenMap[TokenType.REPUTATION_VALUE]
      })
    end
    if tokenMap[TokenType.MORAL_VALUE] and 0 < tokenMap[TokenType.MORAL_VALUE] then
      table.insert(tokenAward, {
        PersonalHelper.Type.Merit,
        tokenMap[TokenType.MORAL_VALUE]
      })
    end
    if tokenMap[TokenType.CHANGE_MODEL_CARD_ESSENCE] and 0 < tokenMap[TokenType.CHANGE_MODEL_CARD_ESSENCE] then
      table.insert(tokenAward, {
        PersonalHelper.Type.TurnedCardEssence,
        tokenMap[TokenType.CHANGE_MODEL_CARD_ESSENCE]
      })
    end
    if tokenMap[TokenType.CHANGE_MODEL_CARD_SCORE] and 0 < tokenMap[TokenType.CHANGE_MODEL_CARD_SCORE] then
      table.insert(tokenAward, {
        PersonalHelper.Type.TurnedCardScore,
        tokenMap[TokenType.CHANGE_MODEL_CARD_SCORE]
      })
    end
    if tokenMap[TokenType.PET_MARK_SCORE1] and 0 < tokenMap[TokenType.PET_MARK_SCORE1] then
      table.insert(tokenAward, {
        PersonalHelper.Type.PET_MARK_SCORE1,
        tokenMap[TokenType.PET_MARK_SCORE1]
      })
    end
    if tokenMap[TokenType.PET_MARK_SCORE2] and 0 < tokenMap[TokenType.PET_MARK_SCORE2] then
      table.insert(tokenAward, {
        PersonalHelper.Type.PET_MARK_SCORE2,
        tokenMap[TokenType.PET_MARK_SCORE2]
      })
    end
    if tokenMap[TokenType.MEMORY_PIECE] and 0 < tokenMap[TokenType.MEMORY_PIECE] then
      table.insert(tokenAward, {
        PersonalHelper.Type.MEMORY_PIECE,
        tokenMap[TokenType.MEMORY_PIECE]
      })
    end
    if #tokenAward > 1 then
      local htmlText = PersonalHelper.ToString(unpackCommonTableMsg(tokenAward))
      table.insert(htmlTexts, htmlText)
    end
  end
  if awardInfo.itemMap and next(awardInfo.itemMap) then
    local htmlText = PersonalHelper.ToString(PersonalHelper.Type.Text, customPrefix, PersonalHelper.Type.ItemMap, awardInfo.itemMap)
    table.insert(htmlTexts, htmlText)
  end
  if awardInfo.petExp and 0 < awardInfo.petExp then
    local petExpMap = {}
    local curPet = require("Main.Pet.Interface").GetFightingPet()
    if curPet then
      petExpMap[curPet.id] = awardInfo.petExp
      local htmlText = PersonalHelper.ToString(PersonalHelper.Type.Text, textRes.AnnounceMent[9], PersonalHelper.Type.PetExpMap, petExpMap)
      table.insert(htmlTexts, htmlText)
    end
  end
  return htmlTexts
end
def.static("number", "number", "=>", "table").GetDailyGiftItemsOfDay = function(activityId, serverOpenDay)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_RMG_GIFT_AWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local items = {}
  local maxDay = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityCfgId = record:GetIntValue("activity_cfg_id")
    if activityCfgId == activityId then
      local day = record:GetIntValue("day")
      local item = {}
      item.id = record:GetIntValue("id")
      item.name = record:GetStringValue("name")
      item.tier = record:GetIntValue("tier")
      item.maxBuyTimes = record:GetIntValue("buy_max_times")
      item.title = record:GetStringValue("title")
      item.desc = record:GetStringValue("desc")
      item.awardCfgId = record:GetIntValue("award_cfg_id")
      item.productServiceId = record:GetIntValue("product_service_id")
      item.icon = record:GetIntValue("icon")
      item.frame = record:GetIntValue("frame")
      if items[day] == nil then
        items[day] = {}
      end
      table.insert(items[day], item)
      if maxDay < day then
        maxDay = day
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local needDay = (serverOpenDay + maxDay - 1) % maxDay + 1
  return items[needDay]
end
def.static("=>", "table").GetAllAxeActs = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AXEModuleCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local data = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    data.moduleId = record:GetIntValue("moduleid")
    data.actId = record:GetIntValue("activity_cfg_id")
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "table").GetAxeActCfgByModuleId = function(moduleId)
  local retData = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AXEModuleCfg, moduleId)
  if record == nil then
    warn(">>>>load DATA_AXEModuleCfg error, moduleId = " .. moduleId .. "<<<<")
  else
    retData.actId = record:GetIntValue("activity_cfg_id")
    retData.moduleId = record:GetIntValue("moduleid")
  end
  return retData
end
def.static("number", "=>", "table").GetAxeSectionInfoByActId = function(actId)
  local retData = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AxeActCfg, actId)
  if record == nil then
    warn(">>>>load DATA_AxeActCfg error actId = " .. actId .. "<<<<")
  else
    retData.lockTimeInDay = record:GetIntValue("lock_trigger_interval_in_day")
    retData.unlock_cost_type = record:GetIntValue("unlock_cost_type")
    retData.unlock_cost_num = record:GetIntValue("unlock_cost_num")
    local sectInfoVecStruct = record:GetStructValue("section_infosStruct")
    local sectVecSize = sectInfoVecStruct:GetVectorSize("section_infos")
    for i = 1, sectVecSize do
      local secCfgData = {}
      local oneSecRecord = sectInfoVecStruct:GetVectorValueByIdx("section_infos", i - 1)
      secCfgData.section_id = oneSecRecord:GetIntValue("section_id")
      secCfgData.cost_type = oneSecRecord:GetIntValue("cost_type")
      secCfgData.cost_num = oneSecRecord:GetIntValue("cost_num")
      secCfgData.results = {}
      local results = secCfgData.results
      local resultsStruct = oneSecRecord:GetStructValue("resultsStruct")
      local resultsVecSize = resultsStruct:GetVectorSize("results")
      for j = 1, resultsVecSize do
        local oneResData = {}
        local resultsRecord = resultsStruct:GetVectorValueByIdx("results", j - 1)
        oneResData.sort_id = resultsRecord:GetIntValue("sort_id")
        oneResData.display_probability = resultsRecord:GetIntValue("display_probability")
        oneResData.axe_num = resultsRecord:GetIntValue("axe_num")
        oneResData.axe_item_cfg_id = resultsRecord:GetIntValue("axe_item_cfg_id")
        table.insert(results, oneResData)
      end
      table.insert(retData, secCfgData)
    end
  end
  return retData
end
def.static("number", "=>", "table").GetActBasicInfoByActId = function(actId)
  local retData = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AxeActCfg, actId)
  if record == nil then
    return nil
  end
  retData.lockTimeInDay = record:GetIntValue("lock_trigger_interval_in_day")
  retData.unlock_cost_type = record:GetIntValue("unlock_cost_type")
  retData.unlock_cost_num = record:GetIntValue("unlock_cost_num")
  return retData
end
def.static("number", "number", "=>", "table").GetAxeSectioInfoByActIdandSecIdx = function(actId, idx)
  local cfgData = AwardUtils.GetAxeSectionInfoByActId(actId)
  return cfgData[idx]
end
def.static("number", "=>", "table").GetFixAwardIdByItemId = function(itemId)
  local retData = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AxeItemCfg, itemId)
  if record == nil then
    warn("Load axe item cfg error")
    return
  end
  retData.itemId = record:GetIntValue("id")
  retData.fixAwardId = record:GetIntValue("fix_award_id")
  return retData
end
def.static("number", "=>", "table").GetAwardNoticeCfg = function(noticeType)
  local cfg = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AWARD_NOTICE_CFG, noticeType)
  if record == nil then
    warn("GetAwardNoticeCfg return nil ," .. noticeType)
    return
  end
  cfg.noticeType = record:GetIntValue("recordType")
  cfg.desc = record:GetStringValue("desc")
  return cfg
end
return AwardUtils.Commit()
