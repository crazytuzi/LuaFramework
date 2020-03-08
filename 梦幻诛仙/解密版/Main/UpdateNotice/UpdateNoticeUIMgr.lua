local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local UpdateNoticeUIMgr = Lplus.Class("UpdateNoticeUIMgr")
local UpdateNoticeModule = Lplus.ForwardDeclare("UpdateNoticeModule")
local def = UpdateNoticeUIMgr.define
local UISet = {
  UpdateNoticePanel = "UpdateNoticePanel",
  GameNoticePanel = "GameNoticePanel"
}
def.const("table").UISet = UISet
def.field("string").modulePrefix = ""
local instance
def.static("=>", UpdateNoticeUIMgr).Instance = function()
  if instance == nil then
    instance = UpdateNoticeUIMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self:InitModulePrefix()
end
def.method().InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self.modulePrefix .. ".ui." .. uiName)
end
def.static("function").OpenNoticePanel = function(onClose)
  local self = instance
  local notice = UpdateNoticeModule.Instance():GetNotice()
  self:GetUI(UISet.UpdateNoticePanel).Instance():ShowPanelEx(notice.title, notice.content, notice.url or "", onClose)
end
def.static("string", "string", "string", "function").OpenNoticePanelEx = function(title, content, url, onClose)
  local self = instance
  local content = UpdateNoticeModule.HtmlToNGUIHtml(content)
  self:GetUI(UISet.UpdateNoticePanel).Instance():ShowPanelEx(title, content, url, onClose)
end
def.static("table", "function").OpenGameNoticePanel = function(notices, onClose)
  local self = instance
  self:GetUI(UISet.GameNoticePanel).Instance():ShowPanelEx(notices, onClose)
end
return UpdateNoticeUIMgr.Commit()
