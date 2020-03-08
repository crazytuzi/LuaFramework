local Lplus = require("Lplus")
local PersonalInfo = require("Main.PersonalInfo.PersonalInfo")
local PersonalInfoInterface = Lplus.Class("PersonalInfoInterface")
local def = PersonalInfoInterface.define
local instance
def.const("number").SaveInfoMaxTime = 300
def.field("table").personalInfoMap = nil
def.field("table").headImgUrlList = nil
def.static("=>", PersonalInfoInterface).Instance = function()
  if instance == nil then
    instance = PersonalInfoInterface()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self:Reset()
end
def.method().Reset = function(self)
  self.personalInfoMap = {}
  self.headImgUrlList = {}
end
def.static("number", "=>", "table").GetPersonalCfg = function(operationType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PERSONAL_CFG, operationType)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.valueType = record:GetIntValue("valueType")
  cfg.textValue = record:GetStringValue("textValue")
  cfg.textMaxLen = record:GetIntValue("textMaxLen")
  cfg.optionId = record:GetIntValue("optionId")
  return cfg
end
def.static("number", "=>", "table").GetPersonalOptionCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PERSONAL_OPTION_CFG, id)
  if record == nil then
    warn("!!!!!!!!error PersonalOpetionCfg id:", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.content = record:GetStringValue("content")
  cfg.optionId = record:GetIntValue("optionId")
  cfg.linkOptionId = record:GetIntValue("linkOptionId")
  return cfg
end
def.static("number", "=>", "table").GetPersonalLocationCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LOCATION_CFG, id)
  if record == nil then
    warn("!!!!!!!!error PersonalOpetionCfg id:", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.content = record:GetStringValue("content")
  return cfg
end
def.static("number", "=>", "table").GetPersonalLocationList = function(optionId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LOCATION_CFG)
  if entries == nil then
    return nil
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local cfgList = {}
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    if record:GetIntValue("optionId") == optionId then
      local r = {}
      r.id = record:GetIntValue("id")
      r.content = record:GetStringValue("content")
      table.insert(cfgList, r)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgList
end
def.static("number", "=>", "table").GetFieldPrecentCfg = function(fieldType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PERSONALFIELD_PRECENT_CFG, fieldType)
  if record == nil then
    warn("!!!!!!!!error FieldPrecentCfg id:", fieldType)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.fieldType = record:GetIntValue("fieldType")
  cfg.precent = record:GetIntValue("precent")
  return cfg
end
def.static("number", "=>", "table").GetOperationList = function(optionId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PERSONAL_OPTION_CFG)
  if entries == nil then
    return nil
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local cfgList = {}
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    if record:GetIntValue("optionId") == optionId then
      local r = {}
      r.id = record:GetIntValue("id")
      r.content = record:GetStringValue("content")
      table.insert(cfgList, r)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgList
end
def.static("number", "=>", "table").GetPersonalHeadImageCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PERSONALHEADIMAGE_CFG, id)
  if record == nil then
    warn("!!!!!!!!error PersonalHeadImageCfg id:", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.imageId = record:GetIntValue("imageId")
  return cfg
end
def.static("=>", "table").GetHeadImgCfgList = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PERSONALHEADIMAGE_CFG)
  if entries == nil then
    return nil
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local cfgList = {}
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    local id = record:GetIntValue("id")
    local cfg = PersonalInfoInterface.GetPersonalHeadImageCfg(id)
    if cfg then
      table.insert(cfgList, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgList
end
def.static("=>", "table").GetShareCfgList = function()
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local cfgList = {}
  table.insert(cfgList, {
    id = ChatMsgData.Channel.FACTION,
    content = textRes.Personal[8]
  })
  table.insert(cfgList, {
    id = ChatMsgData.Channel.TEAM,
    content = textRes.Personal[9]
  })
  table.insert(cfgList, {
    id = ChatMsgData.Channel.CURRENT,
    content = textRes.Personal[10]
  })
  table.insert(cfgList, {
    id = ChatMsgData.Channel.WORLD,
    content = textRes.Personal[11]
  })
  return cfgList
end
def.static("=>", "table").GetSNSTypeCfgList = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SNS_MAINTYPE_CFG)
  if entries == nil then
    warn("SNSType table is nil")
    return nil
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local cfgList = {}
  for i = 1, recordCount do
    local cfg = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    cfg.id = record:GetIntValue("id")
    cfg.mainTypeName = record:GetStringValue("mainTypeName")
    cfg.sortId = record:GetIntValue("sortId")
    cfg.subTypeList = {}
    local subTypeCfgIdListStruct = record:GetStructValue("subTypeCfgIdListStruct")
    local size = subTypeCfgIdListStruct:GetVectorSize("subTypeCfgIdList")
    for i = 0, size - 1 do
      local subType = subTypeCfgIdListStruct:GetVectorValueByIdx("subTypeCfgIdList", i)
      local subTypeId = subType:GetIntValue("subTypeCfgId")
      local subTypeCfg = PersonalInfoInterface.GetSNSSubTypeCfgById(subTypeId)
      if subTypeCfg ~= nil then
        table.insert(cfg.subTypeList, subTypeCfg)
      end
    end
    table.insert(cfgList, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgList
end
def.static("number", "=>", "table").GetSNSSubTypeCfgById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SNS_SUBTYPE_CFG, id)
  if record == nil then
    warn("SNSSubType not exsit:" .. id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.subTypeName = record:GetStringValue("subTypeName")
  cfg.typeName = record:GetStringValue("typeName")
  cfg.npcId = record:GetIntValue("npcId")
  cfg.icon = record:GetStringValue("icon")
  cfg.npcServiceId = record:GetIntValue("npcServiceId")
  cfg.defaultContents = {}
  local defaultContentStruct = record:GetStructValue("defaultContentStruct")
  local size = defaultContentStruct:GetVectorSize("defaultContentList")
  for i = 0, size - 1 do
    local field = defaultContentStruct:GetVectorValueByIdx("defaultContentList", i)
    local defaultContent = field:GetStringValue("defaultContent")
    if defaultContent ~= nil then
      table.insert(cfg.defaultContents, defaultContent)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetSNSSubTypeByNPCService = function(serviceId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SNS_MAINTYPE_CFG)
  if entries == nil then
    warn("SNSType table is nil")
    return nil
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local cfgList = {}
  for i = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local subTypeCfgIdListStruct = record:GetStructValue("subTypeCfgIdListStruct")
    local size = subTypeCfgIdListStruct:GetVectorSize("subTypeCfgIdList")
    for i = 0, size - 1 do
      local subType = subTypeCfgIdListStruct:GetVectorValueByIdx("subTypeCfgIdList", i)
      local subTypeId = subType:GetIntValue("subTypeCfgId")
      local subTypeCfg = PersonalInfoInterface.GetSNSSubTypeCfgById(subTypeId)
      if subTypeCfg ~= nil and subTypeCfg.npcServiceId == serviceId then
        DynamicDataTable.FastGetRecordEnd(entries)
        return subTypeCfg
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return nil
end
def.method("userdata", "string").CheckPersonalInfo = function(self, roleId, imgUrl)
  if IsCrossingServer() then
    Toast(textRes.Personal[24])
  else
    local personalInfo = self:getPersonalInfo(roleId)
    self.headImgUrlList[roleId:ToNumber()] = imgUrl
    if personalInfo and personalInfo.infoTime + PersonalInfoInterface.SaveInfoMaxTime > GetServerTime() then
      require("Main.PersonalInfo.PersonalInfoModule").ShowPlayerInfoPanel(roleId)
    else
      self.personalInfoMap[roleId:ToNumber()] = nil
      local req = require("netio.protocol.mzm.gsp.personal.CQueryPersonalInfo").new(roleId)
      gmodule.network.sendProtocol(req)
    end
  end
end
def.method("userdata", "table").setPersonalInfo = function(self, roleId, infos)
  local personal = PersonalInfo.New(roleId, infos)
  warn("---------setPersonalInfo:", roleId:ToNumber())
  self.personalInfoMap[roleId:ToNumber()] = personal
end
def.method("userdata", "table").setPersonalEditInfo = function(self, roleId, info)
  warn("------setPersonalEditInfo:", roleId, self.personalInfoMap[roleId:ToNumber()])
  local curInfo = self.personalInfoMap[roleId:ToNumber()].info
  for i, v in pairs(info) do
    curInfo[i] = v
  end
end
def.method("userdata", "=>", "table").getQQOrWechatInfo = function(self, roleId)
  local myHero = require("Main.Hero.HeroModule").Instance()
  local heroProp = myHero:GetHeroProp()
  local myRoleId = heroProp.id
  if roleId == myRoleId then
    local ECMSDK = require("ProxySDK.ECMSDK")
    local info = ECMSDK.GetMyInfo()
    return info
  else
  end
  return nil
end
def.method("userdata", "=>", "string").getHeadImgUrl = function(self, roleId)
  local personalInfo = self:getPersonalInfo(roleId)
  local figure_url = personalInfo:getFigureUrl()
  local urlStr = GetStringFromOcts(figure_url)
  if urlStr == nil or urlStr == "" then
    return ""
  end
  local url = require("Main.RelationShipChain.RelationShipChainMgr").ProcessHeadImgURL(figure_url)
  if url then
    return url
  end
  return ""
end
def.method("userdata", "=>", PersonalInfo).getPersonalInfo = function(self, roleId)
  return self.personalInfoMap[roleId:ToNumber()]
end
def.method("table", "=>", "string").getLocaltionText = function(self, location)
  if location == nil or location.province <= 0 then
    return textRes.Common[81]
  else
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(location.province)
    local str = optionCfg and optionCfg.content or ""
    if 0 < location.city then
      local locationCfg = PersonalInfoInterface.GetPersonalLocationCfg(location.city)
      return str .. " " .. (locationCfg and locationCfg.content or "")
    else
      return str
    end
  end
end
return PersonalInfoInterface.Commit()
