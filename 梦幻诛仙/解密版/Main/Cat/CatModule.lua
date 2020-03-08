local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local Octets = require("netio.Octets")
local AwardUtils = require("Main.Award.AwardUtils")
local TIP_ID = constant.CCatCfgConsts.TIP_ID
local CAT_ITEM_CFG_ID = constant.CCatCfgConsts.CAT_ITEM_CFG_ID
local MODULE_NAME = (...)
local CatModule = Lplus.Extend(ModuleBase, MODULE_NAME)
local def = CatModule.define
local instance
local warn = function(...)
end
local GetTimeStr = function(content, diff)
  local h = math.floor(diff / 3600)
  local m = math.floor(diff % 3600 / 60)
  local s = math.floor(diff % 60)
  return string.format(content, h, m, s)
end
local ExploreAniList = {
  ActionName.Idle2
}
local IdleAniList = {
  ActionName.Attack1,
  ActionName.Idle1
}
def.static("=>", CatModule).Instance = function()
  if instance == nil then
    instance = CatModule()
    instance.m_moduleId = ModuleId.CAT
  end
  return instance
end
def.field("table").m_catCfgsCache = nil
def.field("table").m_partnerCfgsCache = nil
def.field("table").m_levelCfgs = nil
def.field("table").m_feedRecord = nil
def.field("userdata").m_target_roleid = nil
def.field("table").m_cat_info = nil
def.field("number").m_feed_num = 0
def.override().Init = function(self)
  self:_InitLevelCfgs()
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, CatModule.OnNPCService)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SQueryCatsSuccess", CatModule.OnSQueryCatsSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SQueryCatsFailed", CatModule.OnSQueryCatsFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SFeedCatSuccess", CatModule.OnSFeedCatSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SFeedCatFailed", CatModule.OnSFeedCatFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SChangePartnerSuccess", CatModule.OnSChangePartnerSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SChangePartnerFailed", CatModule.OnSChangePartnerFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SSendCatToExploreSuccess", CatModule.OnSSendCatToExploreSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SSendCatToExploreFailed", CatModule.OnSSendCatToExploreFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SGetAwardSuccess", CatModule.OnSGetAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SGetAwardFailed", CatModule.OnSGetAwardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SRecoveryCatToItemSuccess", CatModule.OnSRecoveryCatToItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SCatRecoveryToItemFailed", CatModule.OnSCatRecoveryToItemFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SCatRenameSuccess", CatModule.OnSCatRenameSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SCatRenameFailed", CatModule.OnSCatRenameFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SQueryFeedCatsSuccess", CatModule.OnSQueryFeedCatsSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SQueryFeedCatsFailed", CatModule.OnSQueryFeedCatsFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cat.SBrocastExploreItem", CatModule.OnSBrocastExploreItem)
end
def.method("=>", "number").GetFeatureType = function(self)
  return Feature.TYPE_CAT
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local bOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(self:GetFeatureType())
  return bOpen
end
def.method("=>", "userdata").GetTargetRoleId = function(self)
  return self.m_target_roleid and self.m_target_roleid or 0
end
def.method("=>", "number").GetState = function(self)
  return self.m_cat_info and self.m_cat_info.state or 0
end
def.method("=>", "number").GetFeedNum = function(self)
  return self.m_feed_num and self.m_feed_num or 0
end
def.method("=>", "table").GetFeedRecord = function(self)
  return self.m_feedRecord
end
def.method("=>", "string").GetName = function(self)
  local name = ""
  if self.m_cat_info and self.m_cat_info.name then
    local octets = Octets.new(self.m_cat_info.name)
    name = octets:toString()
  else
    local tid = self.m_cat_info and self.m_cat_info.tid or 0
    local cfg = self:GetCatCfg(tid)
    if cfg and cfg.catName then
      name = cfg.catName
    end
  end
  return name
end
def.method("string", "=>", "string").GetTitle = function(self, rolename)
  local titletid = constant.CCatCfgConsts.CAT_TITLE_ID
  local TitleInterface = require("Main.title.TitleInterface")
  local cfg = TitleInterface.GetAppellationCfg(titletid)
  if cfg.appellationName then
    return string.format(cfg.appellationName, rolename)
  end
  return rolename
end
def.method("=>", "string").GetDesc = function(self)
  local desc = ""
  local tid = self.m_cat_info and self.m_cat_info.tid or 0
  local cfg = self:GetCatCfg(tid)
  if cfg and cfg.catDesc then
    desc = cfg.catDesc
  end
  return desc
end
def.method("=>", "number").GetTipId = function(self)
  return TIP_ID
end
def.method("=>", "number").GetModelId = function(self)
  local moduleid = 0
  local tid = self.m_cat_info and self.m_cat_info.tid or 0
  local cfg = self:GetCatCfg(tid)
  if cfg and cfg.moduleid then
    moduleid = cfg.moduleid
  end
  return moduleid
end
def.method("=>", "number").GetPartnerTid = function(self)
  return self.m_cat_info and self.m_cat_info.partner_cfgid or 0
end
def.method("=>", "string").GetPartnerName = function(self)
  local name = ""
  local tid = self:GetPartnerTid()
  local cfg = self:GetPartnerCfg(tid)
  if cfg and cfg.name then
    name = cfg.name
  end
  return name
end
def.method("=>", "number").GetPartnerIconId = function(self)
  local iconid = 0
  local tid = self:GetPartnerTid()
  local cfg = self:GetPartnerCfg(tid)
  if cfg and cfg.iconid then
    iconid = cfg.iconid
  end
  return iconid
end
def.method("=>", "number").GetChangePartnerCost = function(self)
  return constant.CCatCfgConsts.RESET_PARTNER_COST
end
def.method("=>", "number").GetVitality = function(self)
  return self.m_cat_info and self.m_cat_info.vigor or 0
end
def.method("=>", "number").GetVitalityMax = function(self)
  local max = 0
  local lv = self:GetLevel()
  local lvCfg = self.m_levelCfgs[lv]
  if lvCfg then
    max = lvCfg.vigorMax
  end
  return max
end
def.method("=>", "number").GetLevel = function(self)
  return self.m_cat_info and self.m_cat_info.level or 0
end
def.method("=>", "number").GetTimes = function(self)
  return self.m_cat_info and self.m_cat_info.prgs or 0
end
def.method("=>", "number").GetExploreMaxTimes = function(self)
  local times = 0
  local lv = self:GetLevel()
  local lvCfg = self.m_levelCfgs[lv]
  if lvCfg then
    times = lvCfg.exploreMax
  end
  return times
end
def.method("=>", "number").GetExploreTimes = function(self)
  local times = 0
  if self.m_cat_info and self.m_cat_info.explore_num then
    times = self.m_cat_info.explore_num
  end
  return times
end
def.method("=>", "number").GetTimesMax = function(self)
  local max = 0
  local lv = self:GetLevel()
  local lvCfg = self.m_levelCfgs[lv]
  if lvCfg then
    max = lvCfg.levelUpNeededNum
  end
  return max
end
def.method("=>", "boolean").IsCanExplore = function(self)
  return self:GetExploreTimes() < self:GetExploreMaxTimes() and self:GetVitalityMax() <= self:GetVitality()
end
def.method("=>", "boolean").IsCanGetaward = function(self)
  return self.m_cat_info and self.m_cat_info.is_award > 0 or false
end
def.method("=>", "string").RandomExploreAni = function(self)
  local idx = math.random(#ExploreAniList)
  return ExploreAniList[idx]
end
def.method("=>", "string").RandomIdleAni = function(self)
  local idx = math.random(#IdleAniList)
  return IdleAniList[idx]
end
def.method("=>", "string").GetExploreEndTime = function(self)
  local timeStr = ""
  local serverTime = GetServerTime()
  local endTime = self.m_cat_info and self.m_cat_info.explore_end_timestamp or 0
  local diff = self.m_cat_info.explore_end_timestamp - serverTime
  if diff > 0 then
    local idx = self:GetTargetRoleId() == GetMyRoleID() and 2 or 11
    timeStr = GetTimeStr(textRes.Cat[idx], diff)
  end
  return timeStr
end
def.method("=>", "string").GetCooldownTime = function(self)
  local timeStr = ""
  local CatInfo = require("netio.protocol.mzm.gsp.cat.CatInfo")
  if self:GetState() == CatInfo.STATE_RESET then
    local serverTime = GetServerTime()
    local endTime = 0
    local lv = self:GetLevel()
    local lvCfg = self.m_levelCfgs[lv]
    if lvCfg then
      local explore_end_timestamp = self.m_cat_info and self.m_cat_info.explore_end_timestamp or 0
      endTime = explore_end_timestamp + lvCfg.restTime * 60
    end
    local diff = endTime - serverTime
    if diff > 0 then
      timeStr = GetTimeStr(textRes.Cat[3], diff)
    end
  end
  return timeStr
end
def.method("number", "=>", "table").GetCatCfg = function(self, tid)
  local cfg = {}
  if not self.m_catCfgsCache then
    self.m_catCfgsCache = {}
  end
  if self.m_catCfgsCache[tid] then
    cfg = self.m_catCfgsCache[tid]
  else
    local entries = DynamicData.GetTable(CFG_PATH.DATA_HOME_CAT_CFG)
    if entries == nil then
      warn("----CatModule GetCatCfg error : ", CFG_PATH.DATA_HOME_CAT_CFG)
    else
      DynamicDataTable.FastGetRecordBegin(entries)
      local recordCount = DynamicDataTable.GetRecordsCount(entries)
      for i = 1, recordCount do
        local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
        if record then
          local id = record:GetIntValue("id")
          if tid == id then
            cfg.id = id
            cfg.catName = record:GetStringValue("catName")
            cfg.catDesc = record:GetStringValue("catDesc")
            cfg.moduleid = record:GetIntValue("moduleid")
            cfg.level = record:GetIntValue("level")
            cfg.npcid = record:GetIntValue("npcid")
            cfg.explore_npcid = record:GetIntValue("explore_npcid")
            self.m_catCfgsCache[id] = cfg
          end
        end
      end
      DynamicDataTable.FastGetRecordEnd(entries)
    end
  end
  return cfg
end
def.method("number", "=>", "table").GetPartnerCfg = function(self, tid)
  local cfg = {}
  if not self.m_partnerCfgsCache then
    self.m_partnerCfgsCache = {}
  end
  if self.m_partnerCfgsCache and self.m_partnerCfgsCache[tid] then
    cfg = self.m_partnerCfgsCache[tid]
  else
    local entries = DynamicData.GetTable(CFG_PATH.DATA_CAT_PARTNER_CFG)
    if entries == nil then
      warn("----CatModule GetPartnerCfg error : ", CFG_PATH.DATA_CAT_PARTNER_CFG)
    else
      DynamicDataTable.FastGetRecordBegin(entries)
      local recordCount = DynamicDataTable.GetRecordsCount(entries)
      for i = 1, recordCount do
        local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
        if record then
          local id = record:GetIntValue("id")
          if tid == id then
            cfg.id = id
            cfg.name = record:GetStringValue("partnerName")
            cfg.iconid = record:GetIntValue("iconid")
            self.m_partnerCfgsCache[id] = cfg
          end
        end
      end
      DynamicDataTable.FastGetRecordEnd(entries)
    end
  end
  return cfg
end
def.method("number", "=>", "number").GetCatTid = function(self, cat_item_tid)
  local tid = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CAT_ITEM_CFG)
  if entries == nil then
    warn("----CatModule GetCatTid error : ", CFG_PATH.DATA_CAT_ITEM_CFG)
  else
    DynamicDataTable.FastGetRecordBegin(entries)
    local recordCount = DynamicDataTable.GetRecordsCount(entries)
    for i = 1, recordCount do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
      if record then
        local id = record:GetIntValue("id")
        if cat_item_tid == id then
          tid = record:GetIntValue("homelandCatCfgid")
        end
      end
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  return tid
end
def.static("string", "table", "=>", "boolean")._RenamePanelCallback = function(name, self)
  if not self:_ValidEnteredName(name) then
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name) then
    Toast(textRes.Pet[18])
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name, "Name") then
    Toast(textRes.Pet[44])
    return true
  elseif name == "" then
    Toast(textRes.Pet[17])
    return true
  else
    CatModule.CCatRename(name)
    return false
  end
end
def.method("string", "=>", "boolean")._ValidEnteredName = function(self, enteredName)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Login[15])
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Login[14])
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Pet[46])
    end
    return false
  end
end
def.method()._InitLevelCfgs = function(self)
  self.m_levelCfgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CAT_LEVEL_CFG)
  if entries == nil then
    warn("----CatModule GetLevelCfg error : ", CFG_PATH.DATA_CAT_LEVEL_CFG)
  else
    DynamicDataTable.FastGetRecordBegin(entries)
    local recordCount = DynamicDataTable.GetRecordsCount(entries)
    for i = 1, recordCount do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
      if record then
        local cfg = {}
        cfg.id = record:GetIntValue("id")
        cfg.level = record:GetIntValue("level")
        cfg.exploreMax = record:GetIntValue("exploreMax")
        cfg.vigor = record:GetIntValue("vigor")
        cfg.vigorMax = record:GetIntValue("vigorMax")
        cfg.exploreTimeMax = record:GetIntValue("exploreTimeMax")
        cfg.exploreTimeMin = record:GetIntValue("exploreTimeMin")
        cfg.restTime = record:GetIntValue("restTime")
        cfg.levelUpNeededNum = record:GetIntValue("levelUpNeededNum")
        self.m_levelCfgs[cfg.level] = cfg
      end
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
end
def.method()._CalcLevel = function(self)
  local level = 0
  local prgs = 0
  local tid = self.m_cat_info and self.m_cat_info.tid or 0
  local num = self.m_cat_info and self.m_cat_info.total_explore_num or 0
  local catCfg = self:GetCatCfg(tid)
  local initLevel = catCfg.level
  for i = initLevel, #self.m_levelCfgs do
    level = i
    local max = self.m_levelCfgs[i].levelUpNeededNum
    if num < max then
      prgs = num
      break
    else
      num = num - max
    end
  end
  if self.m_cat_info then
    self.m_cat_info.prgs = prgs
    self.m_cat_info.level = level
  end
end
def.method()._CalcState = function(self)
  if self.m_cat_info then
    local CatInfo = require("netio.protocol.mzm.gsp.cat.CatInfo")
    local state = self.m_cat_info.state
    if state == CatInfo.STATE_EXPLORE then
      local serverTime = GetServerTime()
      local endTime = self.m_cat_info and self.m_cat_info.explore_end_timestamp or 0
      local diff = self.m_cat_info.explore_end_timestamp - serverTime
      if diff <= 0 then
        self:_SetIsAward(1)
      end
    elseif state == CatInfo.STATE_RESET then
      local serverTime = GetServerTime()
      local endTime = 0
      local lv = self:GetLevel()
      local lvCfg = self.m_levelCfgs[lv]
      if lvCfg then
        local explore_end_timestamp = self.m_cat_info and self.m_cat_info.explore_end_timestamp or 0
        endTime = explore_end_timestamp + lvCfg.restTime * 60
      end
      local diff = endTime - serverTime
      if diff <= 0 then
        self:_SetState(CatInfo.STATE_NORMAL)
      end
    end
  end
end
def.method()._SetTid = function(self)
  if self.m_cat_info then
    self.m_cat_info.tid = self:GetCatTid(self.m_cat_info.item_cfgid)
  end
end
def.method()._AddExploreNum = function(self)
  if self.m_cat_info then
    local max = constant.CCatCfgConsts.MAX_CAT_LEVEL
    if max <= self:GetLevel() and self:GetTimes() >= self:GetTimesMax() then
      return
    end
    self.m_cat_info.total_explore_num = self.m_cat_info.total_explore_num + 1
  end
end
def.method()._AddFeedNum = function(self)
  if self.m_feed_num then
    self.m_feed_num = self.m_feed_num + 1
  end
end
def.method()._AddVitality = function(self)
  if self.m_cat_info then
    local curr = self.m_cat_info.vigor
    local max = self:GetVitalityMax()
    curr = curr + 1
    if max < curr then
      curr = max
    end
    self.m_cat_info.vigor = curr
  end
end
def.method("number")._SetPartnerTid = function(self, tid)
  if self.m_cat_info then
    self.m_cat_info.partner_cfgid = tid
  end
end
def.method("number")._SetExploreEndTime = function(self, timestamp)
  if self.m_cat_info then
    self.m_cat_info.explore_end_timestamp = timestamp
  end
end
def.method("number")._SetState = function(self, state)
  if self.m_cat_info then
    self.m_cat_info.state = state
  end
end
def.method("number")._SetIsAward = function(self, num)
  if self.m_cat_info then
    self.m_cat_info.is_award = num
  end
end
def.method("userdata")._SetName = function(self, name)
  if self.m_cat_info then
    self.m_cat_info.name = name
  end
end
def.method().DoFeed = function(self)
  if self.m_cat_info then
    CatModule.CFeedCat(self.m_target_roleid, self.m_cat_info.id)
  end
end
def.method().DoGetFeedRecord = function(self)
  if self.m_cat_info then
    CatModule.CQueryFeedCats(self.m_target_roleid, self.m_cat_info.id)
  end
end
def.method().DoTakeBack = function(self)
  CatModule.CRecoveryCatToItem()
end
def.method().DoExplore = function(self)
  CatModule.CSendCatToExplore()
end
def.method().DoChangeName = function(self)
  local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
  CommonRenamePanel:ShowPanel(textRes.Cat[1], true, CatModule._RenamePanelCallback, self)
end
def.method().DoChangePartner = function(self)
  CatModule.CChangePartner()
end
def.method().DoGetAward = function(self)
  CatModule.CGetAward()
end
def.static("userdata", "userdata").CQueryCats = function(target_roleid, catid)
  warn("----CatModule CQueryCats : target_roleid, catid", target_roleid, catid)
  local p = require("netio.protocol.mzm.gsp.cat.CQueryCats").new(target_roleid, catid)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "userdata").CFeedCat = function(roleId, catId)
  warn("----CatModule CFeedCat : roleId, catId", roleId, catId)
  local p = require("netio.protocol.mzm.gsp.cat.CFeedCat").new(roleId, catId)
  gmodule.network.sendProtocol(p)
end
def.static().CChangePartner = function()
  warn("----CatModule CChangePartner")
  local p = require("netio.protocol.mzm.gsp.cat.CChangePartner").new()
  gmodule.network.sendProtocol(p)
end
def.static().CSendCatToExplore = function()
  warn("----CatModule CSendCatToExplore")
  local p = require("netio.protocol.mzm.gsp.cat.CSendCatToExplore").new()
  gmodule.network.sendProtocol(p)
end
def.static().CGetAward = function()
  warn("----CatModule CGetAward")
  local p = require("netio.protocol.mzm.gsp.cat.CGetAward").new()
  gmodule.network.sendProtocol(p)
end
def.static().CRecoveryCatToItem = function()
  warn("----CatModule CRecoveryCatToItem")
  local p = require("netio.protocol.mzm.gsp.cat.CRecoveryCatToItem").new()
  gmodule.network.sendProtocol(p)
end
def.static("string").CCatRename = function(name)
  warn("----CatModule CCatRename : name", name)
  local p = require("netio.protocol.mzm.gsp.cat.CCatRename").new(Octets.rawFromString(name))
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "userdata").CQueryFeedCats = function(roleId, catId)
  warn("----CatModule CQueryFeedCats : roleId, catId", roleId, catId)
  local p = require("netio.protocol.mzm.gsp.cat.CQueryFeedCats").new(roleId, catId)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnNPCService = function(tbl, p2)
  if not instance then
    return
  end
  if not instance:IsFeatureOpen() then
    return
  end
  local serviceId = tbl[1]
  if serviceId == NPCServiceConst.HomeCat then
    local extraInfo = tbl[3]
    if extraInfo.npc then
      extraInfo = extraInfo.npc.extraInfo
    end
    local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
    if extraInfo and extraInfo.entityType == MapEntityType.MGT_EXPLORE_CAT then
      local target_roleid = extraInfo.ownerId
      local catid = extraInfo.instanceid
      CatModule.CQueryCats(target_roleid, catid)
    end
  elseif serviceId == NPCServiceConst.GetHomeCat then
    local itemId = CAT_ITEM_CFG_ID
    local CommerceData = require("Main.CommerceAndPitch.data.CommerceData")
    local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
    local bigIndex, smallIndex = CommerceData.Instance():GetGroupInfoByItemId(itemId)
    CommercePitchModule.Instance():ComemrceBuyItemByBigSmallIndex(bigIndex, smallIndex, itemId)
  end
end
def.static("table").OnSQueryCatsSuccess = function(p)
  warn("----CatModule OnSQueryCatsSuccess : state, total_explore_num, is_award", p.cat_info.state, p.cat_info.total_explore_num, p.cat_info.is_award)
  if not instance then
    return
  end
  instance.m_target_roleid = p.target_roleid
  instance.m_cat_info = p.cat_info
  instance.m_feed_num = p.feed_num
  instance:_SetTid()
  instance:_CalcLevel()
  local CatInfo = require("netio.protocol.mzm.gsp.cat.CatInfo")
  if p.cat_info.state == CatInfo.STATE_EXPLORE then
    Toast(instance:GetExploreEndTime())
  else
    local CatPanel = require("Main.Cat.ui.CatPanel")
    CatPanel.Instance():ShowPanel()
  end
end
def.static("table").OnSQueryCatsFailed = function(p)
  local retcode = p.retcode
  local text = textRes.Cat.SQueryCatsFailed[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("CatModule OnSQueryCatsFailed not handle retcode=%d", retcode))
  end
end
def.static("table").OnSFeedCatSuccess = function(p)
  warn("----CatModule OnSFeedCatSuccess : ", p)
  if not instance then
    return
  end
  if instance.m_target_roleid == p.target_roleid and instance.m_cat_info.id == p.catid then
    instance:_AddVitality()
    instance:_AddFeedNum()
    Event.DispatchEvent(ModuleId.CAT, gmodule.notifyId.Cat.FEED, {})
  end
end
def.static("table").OnSFeedCatFailed = function(p)
  local retcode = p.retcode
  local text = textRes.Cat.SFeedCatFailed[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("CatModule OnSFeedCatFailed not handle retcode=%d", retcode))
  end
end
def.static("table").OnSChangePartnerSuccess = function(p)
  warn("----CatModule OnSChangePartnerSuccess partner_cfgid : ", p.partner_cfgid)
  if not instance then
    return
  end
  instance:_SetPartnerTid(p.partner_cfgid)
  Event.DispatchEvent(ModuleId.CAT, gmodule.notifyId.Cat.CHANGE_PARTNER, {})
end
def.static("table").OnSChangePartnerFailed = function(p)
  warn("----CatModule OnSChangePartnerFailed : ", p)
  local retcode = p.retcode
  local text = textRes.Cat.SChangePartnerFailed[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("CatModule OnSChangePartnerFailed not handle retcode=%d", retcode))
  end
end
def.static("table").OnSSendCatToExploreSuccess = function(p)
  warn("----CatModule OnSSendCatToExploreSuccess : ", p)
  if not instance then
    return
  end
  instance:_SetState(require("netio.protocol.mzm.gsp.cat.CatInfo").STATE_EXPLORE)
  instance:_SetExploreEndTime(p.explore_end_timestamp)
  instance:_AddExploreNum()
  instance:_CalcLevel()
  if p.is_best_partner > 0 then
    local CatPanel = require("Main.Cat.ui.CatPanel")
    CatPanel.Instance():Hide()
    local BestPartnerPanel = require("Main.Cat.ui.BestPartnerPanel")
    BestPartnerPanel.Instance():ShowPanel(instance:GetPartnerTid())
  end
  Event.DispatchEvent(ModuleId.CAT, gmodule.notifyId.Cat.EXPLORE, {})
end
def.static("table").OnSSendCatToExploreFailed = function(p)
  warn("----CatModule OnSSendCatToExploreFailed : ", p)
  local retcode = p.retcode
  local text = textRes.Cat.SSendCatToExploreFailed[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("CatModule OnSSendCatToExploreFailed not handle retcode=%d", retcode))
  end
end
def.static("table").OnSGetAwardSuccess = function(p)
  warn("----CatModule OnSGetAwardSuccess : ", p)
  if not instance then
    return
  end
  instance:_SetIsAward(0)
  if p.item2num then
    AwardUtils.Check2NoticeAward(p.item2num)
  end
  Event.DispatchEvent(ModuleId.CAT, gmodule.notifyId.Cat.GET_AWARD, {})
end
def.static("table").OnSGetAwardFailed = function(p)
  warn("----CatModule OnSGetAwardFailed : ", p)
  local retcode = p.retcode
  local text = textRes.Cat.SGetAwardFailed[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("CatModule OnSGetAwardFailed not handle retcode=%d", retcode))
  end
end
def.static("table").OnSRecoveryCatToItemSuccess = function(p)
  warn("----CatModule OnSRecoveryCatToItemSuccess : ", p)
  Event.DispatchEvent(ModuleId.CAT, gmodule.notifyId.Cat.RECOVERY, {})
end
def.static("table").OnSCatRecoveryToItemFailed = function(p)
  warn("----CatModule OnSCatRecoveryToItemFailed : ", p)
  local retcode = p.retcode
  local text = textRes.Cat.SCatRecoveryToItemFailed[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("CatModule OnSCatRecoveryToItemFailed not handle retcode=%d", retcode))
  end
end
def.static("table").OnSCatRenameSuccess = function(p)
  warn("----CatModule OnSCatRenameSuccess : ", p.cat_name)
  if not instance then
    return
  end
  instance:_SetName(p.cat_name)
  Event.DispatchEvent(ModuleId.CAT, gmodule.notifyId.Cat.CHANGE_NAME, {})
end
def.static("table").OnSCatRenameFailed = function(p)
  warn("----CatModule OnSCatRenameFailed : ", p)
  local retcode = p.retcode
  local text = textRes.Cat.SCatRenameFailed[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("CatModule OnSCatRenameFailed not handle retcode=%d", retcode))
  end
end
def.static("table").OnSQueryFeedCatsSuccess = function(p)
  warn("----CatModule OnSQueryFeedCatsSuccess : ")
  if not instance then
    return
  end
  if instance.m_target_roleid == p.target_roleid and instance.m_cat_info.id == p.catid then
    instance.m_feedRecord = p.feeds
    Event.DispatchEvent(ModuleId.CAT, gmodule.notifyId.Cat.FEED_RECORD, {})
  end
end
def.static("table").OnSQueryFeedCatsFailed = function(p)
  warn("----CatModule OnSQueryFeedCatsFailed : ", p)
  local retcode = p.retcode
  local text = textRes.Cat.SQueryFeedCatsFailed[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("CatModule OnSQueryFeedCatsFailed not handle retcode=%d", retcode))
  end
end
def.static("table").OnSBrocastExploreItem = function(p)
  warn("----CatModule OnSBrocastExploreItem : ")
  local octets = Octets.new(p.role_name)
  for k, v in pairs(p.items) do
    local itemId = k
    local itemNum = v
    local ItemUtils = require("Main.Item.ItemUtils")
    local itemBase = ItemUtils.GetItemBase(itemId)
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    local color = HtmlHelper.NameColor[itemBase.namecolor]
    local str = string.format(textRes.AnnounceMent[85], octets:toString(), color, itemBase.name, itemNum)
    local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
    if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
      local RareItemAnnouncementTip = require("GUI.RareItemAnnouncementTip")
      RareItemAnnouncementTip.AnnounceRareItem(str)
    else
      local AnnouncementTip = require("GUI.AnnouncementTip")
      AnnouncementTip.Announce(str)
    end
    local ChatModule = require("Main.Chat.ChatModule")
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  end
end
return CatModule.Commit()
