local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local RankListUIMgr = Lplus.Class("RankListUIMgr")
local def = RankListUIMgr.define
local UISet = {
  RankListPanel = "RankListPanel"
}
def.const("table").UISet = UISet
def.field("string").modulePrefix = ""
local instance
def.static("=>", RankListUIMgr).Instance = function()
  if instance == nil then
    instance = RankListUIMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self:InitModulePrefix()
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RANKLIST_CLICK, RankListUIMgr.OnRankListButtonClick)
  Event.RegisterEvent(ModuleId.RANK_LIST, gmodule.notifyId.RankList.REQ_OPEN_RANKLIST_PANEL, RankListUIMgr.OnReqOpenRankListPanel)
end
def.method().InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self.modulePrefix .. ".ui." .. uiName)
end
def.static("table", "table").OnRankListButtonClick = function()
  local self = instance
  self:GetUI(UISet.RankListPanel).Instance():ShowPanel()
end
def.static("table", "table").OnReqOpenRankListPanel = function(params)
  local self = instance
  local chartType = params[1]
  self:GetUI(UISet.RankListPanel).Instance():ShowChartView(chartType)
end
return RankListUIMgr.Commit()
