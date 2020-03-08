local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenGangPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local GangModule = require("Main.Gang.GangModule")
local HaveGangPanel = require("Main.Gang.ui.HaveGangPanel")
local def = OpenGangPanel.define
def.const("table").StateConst = {
  Members = HaveGangPanel.NodeId.MEMBERS,
  Affairs = HaveGangPanel.NodeId.AFFAIRS,
  Welfare = HaveGangPanel.NodeId.WELFARE,
  Activity = HaveGangPanel.NodeId.ACTIVITY,
  Chat = 100
}
def.field("number").state = function()
  return OpenGangPanel.StateConst.Members
end
def.override("table", "=>", "boolean").Operate = function(self, params)
  local GangUtility = require("Main.Gang.GangUtility")
  local unlockLevel = GangUtility.GetGangConsts("OPEN_LEVEL")
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if unlockLevel > heroProp.level then
    Toast(string.format(textRes.Skill[7], unlockLevel))
    return false
  end
  local data = GangModule.Instance().data
  local gangId = data:GetGangId()
  if gangId == nil then
    require("Main.Gang.ui.NoGangPanel").Instance():ShowPanel()
    local GUIUtils = require("GUI.GUIUtils")
    GUIUtils.AddLightEffectToPanel("panel_gang1/Img_Bg0/Group_Right/Btn_Quick", GUIUtils.Light.Square)
  else
    if self.state == OpenGangPanel.StateConst.Chat then
      require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(2, 2)
      return true
    end
    require("Main.Gang.ui.HaveGangPanel").Instance():ShowPanelToTab(self.state)
  end
  return false
end
return OpenGangPanel.Commit()
