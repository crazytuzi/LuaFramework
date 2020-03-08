local Lplus = require("Lplus")
local TeenData = require("Main.Children.data.TeenData")
local TeenSubPanel = require("Main.Children.ui.TeenSubPanel")
local ChatTeenSubPanel = Lplus.Extend(TeenSubPanel, "ChatTeenSubPanel")
local def = ChatTeenSubPanel.define
def.override(TeenData).SetCourse = function(self, data)
  local courseGroup = self.m_node:FindDirect("Img_Operate")
  courseGroup:SetActive(false)
end
ChatTeenSubPanel.Commit()
return ChatTeenSubPanel
