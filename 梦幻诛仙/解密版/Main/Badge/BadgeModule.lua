local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local BadgeModule = Lplus.Extend(ModuleBase, "BadgeModule")
require("Main.module.ModuleId")
local def = BadgeModule.define
local instance
def.static("=>", BadgeModule).Instance = function()
  if instance == nil then
    instance = BadgeModule()
    instance.m_moduleId = ModuleId.ANNOUNCEMENT
  end
  return instance
end
def.field("table").badges = nil
def.override().Init = function(self)
  self.badges = {}
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.badge.SSynRoleBadgesInfo", BadgeModule.onSynBadge)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.badge.SRoleGetNewBadge", BadgeModule.onAddBadge)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.badge.SRoleRemoveBadge", BadgeModule.onRemoveBadge)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, BadgeModule.onLeaveWorld)
  ModuleBase.Init(self)
end
def.static("table").onSynBadge = function(p)
  for k, v in pairs(p.badgesInfo) do
    table.insert(instance.badges, {
      badgeId = v.badgeId,
      limitTime = v.timeLimit
    })
  end
  instance:SortBadge()
end
def.static("table").onAddBadge = function(p)
  table.insert(instance.badges, {
    badgeId = p.badgeId,
    limitTime = p.timeLimit
  })
  instance:SortBadge()
  Event.DispatchEvent(ModuleId.BADGE, gmodule.notifyId.Badge.BadgeChanged, nil)
end
def.static("table").onRemoveBadge = function(p)
  for k, v in ipairs(instance.badges) do
    if v.badgeId == p.badgeId then
      table.remove(instance.badges, k)
      break
    end
  end
  instance:SortBadge()
  Event.DispatchEvent(ModuleId.BADGE, gmodule.notifyId.Badge.BadgeChanged, nil)
end
def.method().SortBadge = function(self)
  table.sort(self.badges, function(a, b)
    return a.badgeId < b.badgeId
  end)
end
def.static("table", "table").onLeaveWorld = function()
  instance.badges = {}
end
def.method("=>", "table").GetMyBadges = function(self)
  return self.badges
end
def.method("number", "=>", "table").GetBadgeInfo = function(self, badgeId)
  local badgeInfo = {}
  local badgeRecord = DynamicData.GetRecord(CFG_PATH.DATA_BADGE_CFG, badgeId)
  if badgeRecord == nil then
    return nil
  end
  badgeInfo.id = badgeId
  badgeInfo.name = badgeRecord:GetStringValue("name")
  badgeInfo.iconId = badgeRecord:GetIntValue("iconId")
  badgeInfo.desc = badgeRecord:GetStringValue("description")
  badgeInfo.spriteName = badgeRecord:GetStringValue("spriteName")
  for k, v in ipairs(self.badges) do
    if v.badgeId == badgeId then
      badgeInfo.limitTime = v.limitTime
      break
    end
  end
  return badgeInfo
end
BadgeModule.Commit()
return BadgeModule
