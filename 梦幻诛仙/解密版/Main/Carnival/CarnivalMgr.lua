local Lplus = require("Lplus")
local CarnivalData = require("Main.Carnival.data.CarnivalData")
local CarnivalMgr = Lplus.Class("CarnivalMgr")
local def = CarnivalMgr.define
local instance
def.static("=>", CarnivalMgr).Instance = function()
  if instance == nil then
    instance = CarnivalMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CARNIVAL_CLICK, CarnivalMgr.OnMainUIBtnClick)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CarnivalMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, CarnivalMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CarnivalMgr.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, CarnivalMgr.OnActivityChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, CarnivalMgr.OnActivityChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, CarnivalMgr.OnActivityChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, CarnivalMgr.OnActivityChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Special_Activity_Change, CarnivalMgr.OnActivityChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, CarnivalMgr.OnActivityChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, CarnivalMgr.OnActivityChange)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, CarnivalMgr.OnClickMapFindpath)
end
def.static("table", "table").OnMainUIBtnClick = function(p, c)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not require("Main.Carnival.CarnivalModule").Instance():IsOpen(true) then
    return
  end
  require("Main.Carnival.ui.CarnivalPanel").ShowPanel()
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local switchId = CarnivalData.Instance():GetCarnivalIDIP(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
  if param.feature == switchId then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  end
end
def.static("table", "table").OnLeaveWorld = function(param, context)
  CarnivalData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  if require("Main.Carnival.CarnivalModule").Instance():IsOpen(false) then
    Event.DispatchEvent(ModuleId.CARNIVAL, gmodule.notifyId.CARNIVAL.CARNIVAL_REDDOT_UPDATE, nil)
  end
end
def.static("table", "table").OnActivityChange = function(param, context)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
CarnivalMgr.Commit()
return CarnivalMgr
