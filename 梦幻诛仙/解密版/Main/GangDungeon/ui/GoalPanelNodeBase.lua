local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GoalPanelNodeBase = Lplus.Extend(TabNode, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local def = GoalPanelNodeBase.define
def.field("number").nodeId = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.method("string").SetTitle = function(self, tittle)
  self.m_base:SetTitle(tittle)
end
def.method().ResetPosition = function(self)
  local Scrollview_List = self.m_node:FindDirect("Scrollview_List")
  local uiScrollView = Scrollview_List:GetComponent("UIScrollView")
  uiScrollView:ResetPosition()
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if uiScrollView.isnil then
        return
      end
      uiScrollView:ResetPosition()
    end)
  end)
end
def.method("table").FillList = function(self, viewdatas)
  local itemCount = #viewdatas
  local Target_List = self.m_node:FindDirect("Scrollview_List/Target_List")
  local uiList = Target_List:GetComponent("UIList")
  uiList.itemCount = itemCount
  uiList:Resize()
  local childGOs = uiList.children
  for i = 1, itemCount do
    local childGO = childGOs[i]
    local viewdata = viewdatas[i]
    self:OnSetListItem(i, childGO, viewdata)
  end
end
def.virtual("number", "userdata", "table").OnSetListItem = function(self, index, childGO, viewdata)
  local Label_Name = childGO:FindDirect("Label_" .. index)
  GUIUtils.SetText(Label_Name, viewdata.name)
  local Img_Info = childGO:FindDirect(string.format("Img_Info_%d", index))
  local Img_Finish = childGO:FindDirect(string.format("Img_Finish_%d", index))
  GUIUtils.SetActive(Img_Info, viewdata.hasFinished ~= true)
  GUIUtils.SetActive(Img_Finish, viewdata.hasFinished == true)
  if not viewdata.hasFinished then
    local Label_Progress = Img_Info:FindDirect(string.format("Label_%d", index))
    local cur = math.min(viewdata.cur, viewdata.total)
    local progressText = string.format("%d/%d", cur, viewdata.total)
    GUIUtils.SetText(Label_Progress, progressText)
  end
end
return GoalPanelNodeBase.Commit()
