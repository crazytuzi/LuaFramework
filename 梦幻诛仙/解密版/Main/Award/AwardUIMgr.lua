local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AwardUIMgr = Lplus.Class("AwardUIMgr")
local def = AwardUIMgr.define
local UISet = {
  AwardPanel = "AwardPanel",
  FlipCardAward = "FlipCardAwardPanel"
}
def.const("table").UISet = UISet
def.field("string").modulePrefix = ""
local instance
def.static("=>", AwardUIMgr).Instance = function()
  if instance == nil then
    instance = AwardUIMgr()
  end
  return instance
end
def.method().Init = function(self)
  self:InitModulePrefix()
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_AWARD_CLICK, AwardUIMgr.OnOpenAwardPanel)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.OPEN_AWARD_PANEL_REQ, AwardUIMgr.OnOpenAwardPanel)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DRAW_AWARD_MESSAGE, AwardUIMgr.OnNoticeAwardItems)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECV_MULTI_ROLE_AWARD, AwardUIMgr.OnRecvMultiRoleAward)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.GET_FIRST_RECHARGE_AWARD_SUCCESS, AwardUIMgr.OnRecvFirstRechargeAward)
end
def.method().InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self.modulePrefix .. ".ui." .. uiName)
end
def.method("table").ShowOfflineAward = function(self, offlineAward)
  if offlineAward == nil then
    return
  end
  local min, exp = tostring(offlineAward.offlineMinute), offlineAward.rewardExp
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local expStr = PersonalHelper.ToString(PersonalHelper.Type.OfflineExp, exp)
  local text = string.format(textRes.Award[8], min, expStr)
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, text)
end
def.static("table", "table").OnOpenAwardPanel = function(...)
  instance:GetUI(UISet.AwardPanel).Instance():ShowPanel()
end
def.static("table", "table").OnNoticeAwardItems = function(params)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local awards = params
  for i, v in ipairs(awards.items) do
    PersonalHelper.GetItemMsg(v.itemId, v.num)
  end
end
def.static("table", "table").OnRecvMultiRoleAward = function(params)
  instance:GetUI(UISet.FlipCardAward).Instance():ShowPanel()
end
def.static("table", "table").OnRecvFirstRechargeAward = function(params)
end
return AwardUIMgr.Commit()
