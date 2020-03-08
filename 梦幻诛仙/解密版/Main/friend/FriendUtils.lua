local Lplus = require("Lplus")
local FriendUtils = Lplus.Class("FriendUtils")
local FriendData = Lplus.ForwardDeclare("FriendData")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ChatMsgData = Lplus.ForwardDeclare("ChatMsgData")
local Vector = require("Types.Vector")
local FriendLimitType = require("consts.mzm.gsp.friend.confbean.FriendLimitType")
local MailContent = require("netio.protocol.mzm.gsp.mail.MailContent")
local def = FriendUtils.define
local instance
def.field("table").constTbl = nil
def.static("=>", FriendUtils).Instance = function()
  if nil == instance then
    instance = FriendUtils()
    instance.constTbl = {}
    instance:InitConstTbl()
  end
  return instance
end
def.method().InitConstTbl = function(self)
  local record
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "friendCountMax")
  self.constTbl.friendCountMax = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "applyCountMax")
  self.constTbl.applyCountMax = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "applyTimeMax")
  self.constTbl.applyTimeMax = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_LIMIT_CFG, FriendLimitType.Fight)
  self.constTbl.maxBattlePerDay = DynamicRecord.GetIntValue(record, "dayLimit")
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "maxQinMiDu")
  self.constTbl.maxQinMiDu = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "valuePerbattle")
  self.constTbl.valuePerbattle = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "validateWordsMax")
  self.constTbl.validateWordsMax = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "addFriendLvSet")
  self.constTbl.addFriendLvSet = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "addFriendMaxLvDiffWithServer")
  self.constTbl.addFriendLvLimit = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_LIMIT_CFG, FriendLimitType.Flower)
  self.constTbl.maxAddQinMiDuByFlower = DynamicRecord.GetIntValue(record, "totalLimit")
  record = DynamicData.GetRecord(CFG_PATH.DATA_MAIL_CONST_CFG, "STORE_MAX")
  self.constTbl.storeMax = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_MAIL_CONST_CFG, "THING_MAX")
  self.constTbl.thingMax = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_MAIL_CONST_CFG, "SYS_MAIL_STORE_H")
  self.constTbl.hour = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_MAIL_CONST_CFG, "BAG_FULL_STORE_H")
  self.constTbl.bagFullStore = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_MAIL_CONST_CFG, "PLAYER_SEND")
  self.constTbl.playerSend = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_MAIL_CONST_CFG, "FACTION_STORE_H")
  self.constTbl.factionStore = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_MAIL_CONST_CFG, "PET_ARENA_DAILY_RANK_AWARD_STORE_H")
  self.constTbl.petArenaStore = DynamicRecord.GetIntValue(record, "value")
end
def.static("=>", "number", "number", "number", "number").GetFriendValueLimit = function()
  local DayLimitFight, DayLimitFlower = 100, 100
  local TotalLimitFight, TotalLimitFlower = 9999, 9999
  local LimitTypeEnum = require("consts.mzm.gsp.friend.confbean.FriendLimitType")
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_LIMIT_CFG, LimitTypeEnum.Fight)
  if nil ~= record then
    DayLimitFight = record:GetIntValue("dayLimit")
    TotalLimitFight = record:GetIntValue("totalLimit")
  end
  record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_LIMIT_CFG, LimitTypeEnum.Flower)
  if nil ~= record then
    DayLimitFlower = record:GetIntValue("dayLimit")
    TotalLimitFlower = record:GetIntValue("totalLimit")
  end
  return DayLimitFight, TotalLimitFight, DayLimitFlower, TotalLimitFlower
end
def.static("string", "userdata", "number").FillIcon = function(iconId, uiSprite, num)
  local atlas = FriendUtils.GetAtlasName(num)
  GameUtil.AsyncLoad(atlas, function(obj)
    if obj ~= nil and obj.isnil == false and uiSprite ~= nil and uiSprite.isnil == false then
      local atlas = obj:GetComponent("UIAtlas")
      if atlas ~= nil then
        uiSprite:set_atlas(atlas)
        uiSprite:set_spriteName(iconId)
      end
    end
  end)
end
def.static("number", "=>", "string").GetAtlasName = function(num)
  if 1 == num then
    return RESPATH.HEADATLAS
  elseif 3 == num then
    return RESPATH.COMMONATLAS
  end
end
def.static("table", "=>", "number", "string").ComputeMailRemainTime = function(mailinfo)
  local creatTime = mailinfo.createTime
  local totLife = 0
  local delTime = FriendUtils.GetMailDelTime(mailinfo)
  if delTime > 0 then
    totLife = (delTime - mailinfo.createTime) / 3600
  else
    totLife = FriendUtils.GetStoreHourByType(mailinfo.mailType)
  end
  return FriendUtils.ComputeRemainTime(totLife, creatTime)
end
def.static("number", "number", "=>", "number", "string").ComputeRemainTime = function(maxTime, applyTime)
  local ostime = GetServerTime()
  local remainTime = 0
  local str = ""
  local remainDay = (maxTime - (ostime - applyTime) / 3600) / 24
  if remainDay >= 1 then
    remainTime = remainDay
    str = textRes.Friend[27]
  elseif remainDay >= 0 then
    local remainhour = remainDay * 24
    if remainhour >= 1 then
      remainTime = remainhour
      str = textRes.Friend[24]
    elseif remainhour >= 0 then
      local remainMinute = remainhour * 60
      if remainMinute >= 1 then
        remainTime = remainMinute
        str = textRes.Friend[25]
      elseif remainMinute >= 0 then
        remainTime = remainMinute * 60
        str = textRes.Friend[26]
      else
        remainTime = -1
      end
    end
  else
    remainTime = -1
  end
  remainTime = math.modf(remainTime * 1)
  return remainTime, str
end
def.static("number", "=>", "string").GetOccupationIconId = function(occupationId)
  local occupationIcon = occupationId .. "-" .. 8
  return occupationIcon
end
def.static("number", "number", "=>", "string").GetFriendIconId = function(sex, occupationId)
  local tmpSex = sex + 5
  local friendIcon = occupationId .. "-" .. tmpSex
  return friendIcon
end
def.static("number", "number", "=>", "string").GetFriendCommonIconId = function(sex, occupationId)
  local tmpSex = sex
  local friendIcon = occupationId .. "-" .. tmpSex
  return friendIcon
end
def.static("userdata", "number").ClearList = function(gridTemplate, allNum)
  local allNum = gridTemplate:get_childCount()
  if allNum >= 1 then
    gridTemplate:GetChild(0):SetActive(false)
  else
    return
  end
  for i = 2, allNum do
    local template = gridTemplate:GetChild(i - 1)
    Object.Destroy(template)
  end
end
def.static("userdata", "table", "table", "boolean").FillBasicInfo = function(groupNew, tbl, info, bOnline)
  local icon = groupNew:FindDirect(tbl.icon)
  icon:FindDirect(tbl.level):GetComponent("UILabel"):set_text(info.roleLevel)
  groupNew:FindDirect(tbl.name):GetComponent("UILabel"):set_text(info.roleName)
  local iconId = FriendUtils.GetFriendIconId(info.sex, info.occupationId)
  local iconSprite = icon:GetComponent("UISprite")
  FriendUtils.FillIcon(iconId, iconSprite, 1)
  local occupationIconId = FriendUtils.GetOccupationIconId(info.occupationId)
  local occupationSprite = groupNew:FindDirect(tbl.occupation):GetComponent("UISprite")
  FriendUtils.FillIcon(occupationIconId, occupationSprite, 3)
  if bOnline then
    if tbl.offlineIcon ~= nil and groupNew:FindDirect(tbl.offlineIcon) ~= nil then
      groupNew:FindDirect(tbl.offlineIcon):SetActive(false)
    end
    groupNew:FindDirect(tbl.cover):SetActive(false)
  else
    if tbl.offlineIcon ~= nil and groupNew:FindDirect(tbl.offlineIcon) ~= nil then
      groupNew:FindDirect(tbl.offlineIcon):SetActive(true)
    end
    groupNew:FindDirect(tbl.cover):SetActive(true)
  end
end
def.static("userdata", "string", "=>", "userdata", "string").GetRoleIdNameByObj = function(obj, labelName)
  local targetLabel = obj:FindDirect(labelName)
  if targetLabel == nil then
    return nil, ""
  end
  local roleName = targetLabel:GetComponent("UILabel"):get_text()
  local roleId = FriendData.Instance():GetFriendIdByName(roleName)
  if roleId == nil then
    roleId = require("Main.Chat.ChatModule").Instance():SearchRoleIdByNameFromCache(roleName)
  end
  return roleId, roleName
end
def.static("userdata", "string").OnFriendClearNewMsgClick = function(obj, labelName)
  local roleId, roleName = FriendUtils.GetRoleIdNameByObj(obj, labelName)
  if roleId == nil then
    return
  end
  ChatModule.Instance():ClearFriendNewCount(roleId)
  ChatModule.Instance():StartPrivateChat(roleId, roleName, -1, -1, -1)
end
def.static("userdata", "table").OnFriendClearAllMsgClick = function(obj, tbl)
  local roleId, _ = FriendUtils.GetRoleIdNameByObj(obj, tbl.labelName)
  if roleId == nil then
    return
  end
  ChatModule.Instance():ClearFriendNewCount(roleId)
  obj:FindDirect(tbl.pointImgName):FindDirect(tbl.pointLblName):GetComponent("UILabel"):set_text(0)
  obj:FindDirect(tbl.pointImgName):SetActive(false)
  ChatMsgData.Instance():ClearMsg64(ChatMsgData.MsgType.FRIEND, roleId)
  FriendData.Instance():MoveFriendFromWithToWithout(roleId)
end
def.static("number", "string", "userdata").DeleteLastGroup = function(listNum, groupName, gridTemplate)
  if 1 == listNum then
    gridTemplate:FindDirect(groupName):SetActive(false)
  elseif listNum > 1 then
    local haveCount = gridTemplate:get_childCount()
    if listNum <= haveCount then
      local template = gridTemplate:GetChild(listNum - 1)
      Object.Destroy(template)
    end
  end
end
def.static("number", "string", "userdata", "userdata").AddLastGroup = function(listNum, groupName, gridTemplate, groupTemplate)
  if 1 == listNum then
    groupTemplate:SetActive(true)
    return
  end
  local groupNew = Object.Instantiate(groupTemplate)
  FriendUtils.CreateNewGroup(groupNew, gridTemplate, listNum, groupName)
  groupNew:SetActive(true)
end
def.static("userdata", "userdata", "number", "string").CreateNewGroup = function(groupNew, gridTemplate, count, name)
  groupNew:set_name(string.format(name, count))
  groupNew.parent = gridTemplate
  groupNew:set_localScale(Vector.Vector3.one)
  groupNew:SetActive(true)
end
def.static("=>", "number").GetStoreMax = function()
  local self = FriendUtils.Instance()
  return self.constTbl.storeMax
end
def.static("=>", "number").GetThingMax = function()
  local self = FriendUtils.Instance()
  return self.constTbl.thingMax
end
def.static("=>", "number").GetSysMailStoreHour = function()
  local self = FriendUtils.Instance()
  return self.constTbl.hour
end
def.static("=>", "number").GetBagFullStoreHour = function()
  local self = FriendUtils.Instance()
  return self.constTbl.bagFullStore
end
def.static("=>", "number").GetPlayerSendStoreHour = function()
  local self = FriendUtils.Instance()
  return self.constTbl.playerSend
end
def.static("=>", "number").GetFactionStoreHour = function()
  local self = FriendUtils.Instance()
  return self.constTbl.factionStore
end
def.static("=>", "number").GetPetArenaStoreHour = function()
  local self = FriendUtils.Instance()
  return self.constTbl.petArenaStore
end
def.static("=>", "number").GetAddFriendLevel = function()
  local self = FriendUtils.Instance()
  return self.constTbl.addFriendLvSet
end
def.static("=>", "number").GetAddFriendLevelLimit = function()
  local self = FriendUtils.Instance()
  return self.constTbl.addFriendLvLimit
end
def.static("number", "=>", "number").GetStoreHourByType = function(type)
  if type == require("consts.mzm.gsp.mail.confbean.MailType").SYSTEM then
    return FriendUtils.GetSysMailStoreHour()
  elseif type == require("consts.mzm.gsp.mail.confbean.MailType").BAG_FULL then
    return FriendUtils.GetBagFullStoreHour()
  elseif type == require("consts.mzm.gsp.mail.confbean.MailType").PLAYER then
    return FriendUtils.GetPlayerSendStoreHour()
  elseif type == require("consts.mzm.gsp.mail.confbean.MailType").FACTION then
    return FriendUtils.GetFactionStoreHour()
  elseif type == require("consts.mzm.gsp.mail.confbean.MailType").PET_ARENA_DAILY_RANK_AWARD then
    return FriendUtils.GetPetArenaStoreHour()
  else
    print("error type")
    return 0
  end
end
def.static("table", "=>", "number").GetMailDelTime = function(mail)
  local MailData = require("netio.protocol.mzm.gsp.mail.MailData")
  if not mail.extraparam then
    return 0
  end
  local delTime = mail.extraparam[MailData.EXTRA_KEY_MAIL_DEL_TIME_SEC]
  if not delTime then
    return 0
  end
  return delTime
end
def.static("=>", "number").GetMaxFriendNum = function()
  local self = FriendUtils.Instance()
  return self.constTbl.friendCountMax
end
def.static("=>", "number").GetApplyCountMax = function()
  local self = FriendUtils.Instance()
  return self.constTbl.applyCountMax
end
def.static("=>", "number").GetApplyTimeMax = function()
  local self = FriendUtils.Instance()
  return self.constTbl.applyTimeMax
end
def.static("=>", "number").GetMaxBattlePerDay = function()
  local self = FriendUtils.Instance()
  return self.constTbl.maxBattlePerDay
end
def.static("=>", "number").GetMaxAddQinMiDuByFlower = function()
  local self = FriendUtils.Instance()
  return self.constTbl.maxAddQinMiDuByFlower
end
def.static("=>", "number").GetMaxQinMiDu = function()
  local self = FriendUtils.Instance()
  return self.constTbl.maxQinMiDu
end
def.static("=>", "number").GetValuePerbattle = function()
  local self = FriendUtils.Instance()
  return self.constTbl.valuePerbattle
end
def.static("=>", "number").GetValidateWordsMax = function()
  local self = FriendUtils.Instance()
  return self.constTbl.validateWordsMax
end
def.static("=>", "number").GetShieldListMax = function()
  return DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "blackMax"):GetIntValue("value")
end
def.static("number", "=>", "table").GetMailInfoById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MAIL_CFG, id)
  local tbl
  if nil ~= record then
    tbl = {}
    tbl.id = record:GetIntValue("id")
    tbl.mailType = record:GetIntValue("mailType")
    tbl.title = record:GetStringValue("title")
    tbl.content = record:GetStringValue("content")
    tbl.yuanbao = record:GetIntValue("yuanbao")
    tbl.gold = record:GetIntValue("gold")
    tbl.silver = record:GetIntValue("silver")
    tbl.goldIngot = record:GetIntValue("goldIngot")
    tbl.tokenList = {}
    tbl.itemList = {}
    local tokensStruct = record:GetStructValue("tokensStruct")
    local tokenSize = tokensStruct:GetVectorSize("tokens")
    for i = 0, tokenSize - 1 do
      local rec = tokensStruct:GetVectorValueByIdx("tokens", i)
      local tokenInfo = {}
      tokenInfo.tokenType = rec:GetIntValue("tokenType")
      tokenInfo.tokeCount = rec:GetIntValue("tokeCount")
      table.insert(tbl.tokenList, tokenInfo)
    end
    local itemsStruct = record:GetStructValue("itemsStruct")
    local itemSize = itemsStruct:GetVectorSize("items")
    for i = 0, itemSize - 1 do
      local rec = itemsStruct:GetVectorValueByIdx("items", i)
      local itemInfo = {}
      itemInfo.itemId = rec:GetIntValue("itemid")
      itemInfo.itemNum = rec:GetIntValue("itemNum")
      table.insert(tbl.itemList, itemInfo)
    end
  end
  return tbl
end
def.static("string", "=>", "boolean").ValidEnteredName = function(enteredName)
  if SensitiveWordsFilter.ContainsSensitiveWord(enteredName) then
    Toast(textRes.Friend[52])
    return false
  end
  local FriendTestValidator = require("Main.friend.FriendTestValidator")
  local isValid, reason, _ = FriendTestValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == FriendTestValidator.InvalidReason.TooShort then
      local str = string.format(textRes.Friend[40], 0)
      Toast(str)
    elseif reason == FriendTestValidator.InvalidReason.TooLong then
      local max = FriendUtils.GetValidateWordsMax()
      local str = string.format(textRes.Friend[39], max)
      Toast(str)
    elseif reason == FriendTestValidator.InvalidReason.NotInSection then
      Toast(textRes.Friend[41])
    end
    return false
  end
end
def.static("table", "=>", "boolean").IsSpecialCfgMail = function(mail)
  local id = tonumber(mail.mailContent.contentMap[MailContent.CONTENT_MAIL_CFG_ID])
  local swornMgr = require("Main.Sworn.SwornMgr")
  if id and swornMgr.GetSwornVoteMail(id, mail.mailIndex) then
    return true
  end
  return false
end
FriendUtils.Commit()
return FriendUtils
