local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenStrongerLevelUpPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local GrowGuidePanel = require("Main.Grow.ui.GrowGuidePanel")
local def = OpenStrongerLevelUpPanel.define
def.field("number").nodeId = GrowGuidePanel.NodeId.AdvanceGuide
def.override("table", "=>", "boolean").Operate = function(self, params)
  local StrongerType = require("consts.mzm.gsp.grow.confbean.StrongerType")
  require("Main.Grow.GrowUIMgr").OpenBianqiangPanel(StrongerType.MAJOR_GROW)
  return false
end
return OpenStrongerLevelUpPanel.Commit()
