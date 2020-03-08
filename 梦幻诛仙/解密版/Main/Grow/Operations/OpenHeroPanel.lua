local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenHeroPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local HeroPropPanel = require("Main.Hero.ui.HeroPropPanel")
local def = OpenHeroPanel.define
def.field("number").nodeId = HeroPropPanel.NodeId.Prop
def.override("table", "=>", "boolean").Operate = function(self, params)
  HeroPropPanel.Instance():OpenPanelToTab(self.nodeId)
  return false
end
return OpenHeroPanel.Commit()
