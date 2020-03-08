local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenAwardPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local AwardPanel = require("Main.Award.ui.AwardPanel")
local FuncType = require("consts.mzm.gsp.guide.confbean.FunType")
local GuideModule = Lplus.ForwardDeclare("GuideModule")
local def = OpenAwardPanel.define
def.field("number").nodeId = AwardPanel.NodeId.DailySignIn
def.override("table", "=>", "boolean").Operate = function(self, params)
  if not GuideModule.Instance():CheckFunction(FuncType.AWARD) then
    Toast(textRes.Award[20])
    return false
  end
  AwardPanel.Instance():ShowPanelEx(self.nodeId)
  return false
end
return OpenAwardPanel.Commit()
