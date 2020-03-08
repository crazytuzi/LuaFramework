local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local CarnivalData = require("Main.Carnival.data.CarnivalData")
local CarnivalModule = Lplus.Extend(ModuleBase, "CarnivalModule")
local instance
local def = CarnivalModule.define
def.static("=>", CarnivalModule).Instance = function()
  if instance == nil then
    instance = CarnivalModule()
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.Carnival.CarnivalMgr").Instance():Init()
  CarnivalData.Instance():Init()
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == self:IsFeatrueOpen(bToast) then
    result = false
  elseif false == self:IsActivityOpen(bToast) then
    result = false
  elseif false == self:IsAnyActivityOpen(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueOpen = function(self, bToast)
  local switchId = CarnivalData.Instance():GetCarnivalIDIP(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
  local result = _G.IsFeatureOpen(switchId)
  if false == result and bToast then
    Toast(textRes.Carnival.FEATRUE_IDIP_NOT_OPEN)
  end
  return result
end
def.method("boolean", "=>", "boolean").IsActivityOpen = function(self, bToast)
  local CarnivalUtils = require("Main.Carnival.CarnivalUtils")
  local result = CarnivalUtils.CanAttendActivity(constant.ActivitiesGuidelineConsts.ACTIVITY_ID, nil, bToast)
  if false == result and bToast then
    Toast(textRes.Carnival.ACTIVITY_CLOSED)
  end
  return result
end
def.method("boolean", "=>", "boolean").IsAnyActivityOpen = function(self, bToast)
  local result = CarnivalData.Instance():IsAnyActivityOpen(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  return CarnivalData.Instance():CanCarnivalExchange(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
end
return CarnivalModule.Commit()
