local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local ExchangeBanggongNodeBase = Lplus.Extend(TabNode, "ExchangeBanggongNodeBase")
local def = ExchangeBanggongNodeBase.define
local GUIUtils = require("GUI.GUIUtils")
def.virtual("=>", "boolean").IsOpen = function(self)
  return true
end
def.virtual("table", "table").OnExchangeBanggongChanged = function(params, tbl)
end
return ExchangeBanggongNodeBase.Commit()
