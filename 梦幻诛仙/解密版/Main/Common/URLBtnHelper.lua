local Lplus = require("Lplus")
local URLBtnHelper = Lplus.Class("URLBtnHelper")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local def = URLBtnHelper.define
local URL_BTN_PREFIX = "Btn_URL_"
local _instance
def.static("=>", URLBtnHelper).Instance = function()
  if _instance == nil then
    _instance = URLBtnHelper()
  end
  return _instance
end
def.method().Init = function(self)
  ECPanelBase.AddEventHook("onClick", URLBtnHelper.OnClickHandler)
  ECPanelBase.AddEventHook("onClickObj", function(panel, obj)
    local id = obj.name
    URLBtnHelper.OnClickHandler(panel, id)
  end)
end
def.static("table", "string", "varlist", "=>", "boolean").OnClickHandler = function(sender, id)
  if string.find(id, URL_BTN_PREFIX) then
    local urlCfgId = tonumber(string.sub(id, #URL_BTN_PREFIX + 1, -1))
    if urlCfgId then
      local url = URLBtnHelper.GetURLByCfgId(urlCfgId)
      local ECGame = require("Main.ECGame")
      ECGame.Instance():OpenUrl(url)
      return true
    end
  end
  return false
end
def.static("number", "=>", "string").GetURLByCfgId = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BTN_LINK_CFG, id)
  if record == nil then
    warn("GetURLByCfgId(" .. id .. ") return empty string")
    return ""
  end
  local url = record:GetStringValue("url")
  return url
end
return URLBtnHelper.Commit()
