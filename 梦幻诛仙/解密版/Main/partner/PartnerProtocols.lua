local Lplus = require("Lplus")
local PartnerProtocols = Lplus.Class("PartnerProtocols")
local def = PartnerProtocols.define
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
local ProtocolsCache = require("Main.Common.ProtocolsCache")
local protocolsCache = ProtocolsCache.Instance()
def.static("table").OnSPartnerLogginInfo = function(p)
  local rolePartnerInfo = partnerInterface:GetPartnerInfos()
  rolePartnerInfo.defaultLineUpNum = p.rolePartnerInfo.defaultLineUpNum
  if p.rolePartnerInfo.defaultLineUpNum < 0 then
    rolePartnerInfo.defaultLineUpNum = 0
  end
  rolePartnerInfo.partner2Property = p.rolePartnerInfo.partner2Property
  rolePartnerInfo.ownPartners = {}
  for k, v in pairs(p.rolePartnerInfo.ownPartners) do
    rolePartnerInfo.ownPartners[v] = v
  end
  for k, v in pairs(p.rolePartnerInfo.lineUps) do
    local lineUp = rolePartnerInfo.lineUps[k]
    for k2, v2 in pairs(v.positions) do
      lineUp.positions[k2] = v2
    end
    lineUp.zhenFaId = v.zhenFaId
  end
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_InfoChanged, nil)
end
def.static("table").OnSActivePartnerRep = function(p)
  local cacheInFight = false
  local cacheOnNpcTalk = true
  local cacheOnCGPlay = true
  if protocolsCache:CacheProtocol2(PartnerProtocols.OnSActivePartnerRep, p, cacheInFight, cacheOnNpcTalk, cacheOnCGPlay) == true then
    return
  end
  partnerInterface:_AddOwnPartner(p.partnerId, p.property)
  partnerInterface:SortPartnerList()
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_OwnListChanged, nil)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_InfoChanged, nil)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, p.partnerId)
  local name = record:GetStringValue("name")
  Toast(string.format(textRes.Partner[40], name))
  require("Main.partner.ui.PartnerNew").Instance():ShowDlg(p.partnerId)
end
def.static("table").OnSChangeDefaultLinupReq = function(p)
  partnerInterface:_SetDefaultLineUpNum(p.lineUpNum)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupCurrChanged, {
    p.lineUpNum
  })
end
def.static("table").OnSChangeZhanWeiRep = function(p)
  local rolePartnerInfo = partnerInterface:GetPartnerInfos()
  local lineUp = rolePartnerInfo.lineUps[p.lineUpNum]
  for k2, v2 in pairs(p.lineUp.positions) do
    lineUp.positions[k2] = v2
  end
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupChanged, {
    p.lineUpNum
  })
end
def.static("table").OnSNewGetSkill = function(p)
  local rolePartnerInfo = partnerInterface:GetPartnerInfos()
  for partnerID, Skills in pairs(p.partner2Skills) do
    local property = rolePartnerInfo.partner2Property[partnerID]
    if property == nil then
      property = require("netio.protocol.mzm.gsp.partner.Property").new()
      rolePartnerInfo.partner2Property[partnerID] = property
    end
    for k, v in pairs(Skills) do
      table.insert(property.skills, v)
    end
    local setSkills = {}
    for k, v in pairs(property.skills) do
      setSkills[v] = v
    end
    property.setSkills = setSkills
  end
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_SkillChanged, nil)
end
def.static("table").OnSChangeZhenFaReq = function(p)
  partnerInterface:_SetLineupZhanfaID(p.lineUpNum, p.zhenFaId)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupZhenfaChanged, {
    p.lineUpNum,
    p.zhenFaId
  })
end
def.static("table").OnSPartnerNormalResult = function(p)
end
def.static("table").OnSShuffleLovesReq = function(p)
  partnerInterface:_SetReadyLovesToReplace(p.partnerId, p.lovesToReplace)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_ReadyLovesDataChanged, {
    p.partnerId
  })
  Toast(textRes.Partner[41])
end
def.static("table").OnSReplaceLovesReq = function(p)
  partnerInterface:_SetReadyLovesToReplace(p.partnerId, {})
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_ReadyLovesDataChanged, {
    p.partnerId
  })
  partnerInterface:_SetPartnerLoveInfos(p.partnerId, p.lovesToReplace)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LovesDataChanged, {
    p.partnerId
  })
  Toast(textRes.Partner[42])
end
def.static("table").OnSSyncPartnerRep = function(p)
  warn("*******************  OnSSyncPartnerRep ")
  for partnerId, property in pairs(p.partnerId2property) do
    partnerInterface:_SetPartnerProperty(partnerId, property)
  end
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_PropertyChanged, nil)
end
def.static("table").OnSSynPartnerYuanShen = function(p)
  warn("--------OnSSynPartnerYuanShen:", p.partnerId, p.yuanLv, #p.levels)
  partnerInterface:setYuanshenInfo(p.partnerId, p.yuanLv, p.levels)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_YuanshenInfoChange, {
    p.partnerId
  })
end
def.static("table").OnSSyncSinglePartnerPro = function(p)
  local lastSkillInfos = partnerInterface:GetPartnerSkillInfos(p.partnerId)
  local unlockSkills = {}
  local levelUpSkills = {}
  local curYuanshenLv = partnerInterface:getYuanshenLevel(p.partnerId)
  for i, v in pairs(p.property.skillInfos) do
    local lastSkillLv = lastSkillInfos[i] or 0
    local partnerSkillCfg = PartnerInterface.GetPartnerSkillCfg(i)
    local unlockLv = partnerSkillCfg.unLockYuanLevel
    if curYuanshenLv < unlockLv and unlockLv <= p.property.yuanLv then
      table.insert(unlockSkills, i)
    elseif curYuanshenLv >= unlockLv and v > lastSkillLv then
      table.insert(levelUpSkills, i)
    end
  end
  local skillUpInfos = {unlock = unlockSkills, levelUp = levelUpSkills}
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_SkillChanged, {skillUpInfos})
  local isChouli = false
  local subYuanLevelUp = {}
  for i, v in pairs(p.property.levels) do
    local subYuanshenLv = partnerInterface:getSubYuanshenLevel(p.partnerId, i)
    if v > subYuanshenLv then
      subYuanLevelUp[i] = v
    elseif v < subYuanshenLv and not isChouli then
      isChouli = true
    end
  end
  if isChouli then
    Toast(textRes.Partner[23])
  end
  partnerInterface:_SetPartnerProperty(p.partnerId, p.property)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_YuanshenInfoChange, {
    partnerId = p.partnerId,
    isLevelUp = curYuanshenLv < p.property.yuanLv,
    subYuanLevelup = subYuanLevelUp
  })
end
def.static("table").OnSSynPartnerSkills = function(p)
end
def.static("table").OnSImproveYuanShenRep = function(p)
  warn("--------OnSSynPartnerSkills:", p.partnerId, p.index)
  partnerInterface:setYuanshenLevelUp(p.partnerId, p.index)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_YuanshenLevelChange, {
    p.partnerId,
    p.index
  })
end
PartnerProtocols.Commit()
return PartnerProtocols
