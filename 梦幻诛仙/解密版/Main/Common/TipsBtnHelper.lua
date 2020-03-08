local Lplus = require("Lplus")
local TipsBtnHelper = Lplus.Class("TipsBtnHelper")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local TipsHelper = require("Main.Common.TipsHelper")
local def = TipsBtnHelper.define
local TIPS_BTN_PREFIX = "^Btn_Tips_"
local _instance
def.static("=>", TipsBtnHelper).Instance = function()
  if _instance == nil then
    _instance = TipsBtnHelper()
  end
  return _instance
end
def.method().Init = function(self)
  ECPanelBase.AddEventHook("onClick", TipsBtnHelper.OnClickHandler)
  ECPanelBase.AddEventHook("onClickObj", function(panel, obj)
    local id = obj.name
    TipsBtnHelper.OnClickHandler(panel, id)
  end)
end
def.static("table", "string", "varlist", "=>", "boolean").OnClickHandler = function(sender, id)
  if string.find(id, TIPS_BTN_PREFIX) then
    local tipsCfgId = tonumber(string.sub(id, #TIPS_BTN_PREFIX, -1))
    if tipsCfgId then
      local tipContent = TipsHelper.GetHoverTip(tipsCfgId)
      if tipContent ~= "" then
        TipsHelper.ShowHoverTip(tipsCfgId, 0, 0)
        return true
      end
    end
  end
  return false
end
return TipsBtnHelper.Commit()
