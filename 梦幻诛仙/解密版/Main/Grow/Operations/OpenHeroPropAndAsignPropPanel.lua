local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenHeroPropAndAsignPropPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local HeroPropPanel = require("Main.Hero.ui.HeroPropPanel")
local def = OpenHeroPropAndAsignPropPanel.define
def.field("number").nodeId = HeroPropPanel.NodeId.Prop
def.override("table", "=>", "boolean").Operate = function(self, params)
  HeroPropPanel.Instance():OpenPanelToTab(self.nodeId)
  require("Main.Hero.ui.HeroAssignPropPanel").Instance():ShowPanel()
  return false
end
return OpenHeroPropAndAsignPropPanel.Commit()
