local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChildrenBagPanel = Lplus.Extend(ECPanelBase, "ChildrenBagPanel")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local BabySubPanel = require("Main.Children.ui.BabySubPanel")
local TeenSubPanel = require("Main.Children.ui.TeenSubPanel")
local YouthSubPanel = require("Main.Children.ui.YouthSubPanel")
local GUIUtils = require("GUI.GUIUtils")
local def = ChildrenBagPanel.define
local instance
def.static("=>", ChildrenBagPanel).Instance = function()
  if instance == nil then
    instance = ChildrenBagPanel()
  end
  return instance
end
def.field("userdata").selection = nil
def.field(BabySubPanel).babyPanel = nil
def.field(TeenSubPanel).teenPanel = nil
def.field(YouthSubPanel).youthPanel = nil
def.field("table").childrenList = nil
def.static("userdata").ShowChildrenBag = function(select)
  local dlg = ChildrenBagPanel.Instance()
  dlg.selection = select
  if not dlg:IsShow() then
    dlg:CreatePanel(RESPATH.PREFAB_CHILDREN_BAG, 1)
    dlg:SetModal(true)
  else
    dlg:UpdateUI()
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, ChildrenBagPanel.OnNameChange, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Update, ChildrenBagPanel.OnChildUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Show_Update, ChildrenBagPanel.OnChildShowUpdate, self)
  self:InitSubPanel()
  self:SelectOne()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, ChildrenBagPanel.OnNameChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Update, ChildrenBagPanel.OnChildUpdate)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Show_Update, ChildrenBagPanel.OnChildShowUpdate)
  self.selection = nil
  self.babyPanel:Destroy()
  self.teenPanel:Destroy()
  self.youthPanel:Destroy()
  self.babyPanel = nil
  self.teenPanel = nil
  self.youthPanel = nil
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdateUI()
  else
    if self.babyPanel then
      self.babyPanel:Hide()
    end
    if self.teenPanel then
      self.teenPanel:Hide()
    end
    if self.youthPanel then
      self.youthPanel:Hide()
    end
  end
end
def.method("table").OnNameChange = function(self, param)
  self:UpdateList()
end
def.method("table").OnChildUpdate = function(self, param)
  self:SelectOne()
  self:UpdateUI()
end
def.method("table").OnChildShowUpdate = function(self, param)
  self:UpdateCommon()
end
def.method().SelectOne = function(self)
  if self.selection and not ChildrenDataMgr.Instance():IsInBag(self.selection) then
    self.selection = nil
  end
  if self.selection == nil then
    local childrenList = ChildrenDataMgr.Instance():GetChildrenInBagSort()
    if #childrenList > 0 then
      self.selection = childrenList[1]
    end
  end
end
def.method().InitSubPanel = function(self)
  self.babyPanel = BabySubPanel()
  self.teenPanel = TeenSubPanel()
  self.youthPanel = YouthSubPanel()
  self.babyPanel:Create(self.m_panel:FindDirect("Img_Bg0/Group_Right_YingEr"))
  self.teenPanel:Create(self.m_panel:FindDirect("Img_Bg0/Group_Right_TongNian"))
  self.youthPanel:Create(self.m_panel:FindDirect("Img_Bg0/Group_Right_ZhangCheng"))
end
def.method().UpdateUI = function(self)
  if self.selection == nil then
    self:ShowEmpty()
    self:UpdateContent()
    return
  else
    self:ShowContent()
  end
  self:UpdateList()
  self:UpdateContent()
  self:UpdateCommon()
end
def.method().ShowEmpty = function(self)
  local leftGroup = self.m_panel:FindDirect("Img_Bg0/Group_Left")
  local commonGroup = self.m_panel:FindDirect("Img_Bg0/Group_Common")
  local emtpyGroup = self.m_panel:FindDirect("Img_Bg0/Group_Empty")
  leftGroup:SetActive(false)
  commonGroup:SetActive(false)
  emtpyGroup:SetActive(true)
end
def.method().ShowContent = function(self)
  local leftGroup = self.m_panel:FindDirect("Img_Bg0/Group_Left")
  local commonGroup = self.m_panel:FindDirect("Img_Bg0/Group_Common")
  local emtpyGroup = self.m_panel:FindDirect("Img_Bg0/Group_Empty")
  leftGroup:SetActive(true)
  commonGroup:SetActive(true)
  emtpyGroup:SetActive(false)
end
def.method("userdata", "number", "table").FillChildItem = function(self, itemGo, idx, childData)
  local nameLbl = itemGo:FindDirect("Label_Name_" .. idx)
  nameLbl:GetComponent("UILabel"):set_text(childData:GetName())
  local periodLbl = itemGo:FindDirect("Label_Date_" .. idx)
  local periodName = textRes.Children.PeriodName[childData:GetStatus()] or ""
  periodLbl:GetComponent("UILabel"):set_text(periodName)
  local tex = itemGo:FindDirect(string.format("Img_BgIcon_%d/Img_Icon_%d", idx, idx)):GetComponent("UITexture")
  local icon = ChildrenUtils.GetChildHeadIcon(childData:GetCurModelId())
  GUIUtils.FillIcon(tex, icon)
end
def.method().UpdateList = function(self)
  self.childrenList = ChildrenDataMgr.Instance():GetChildrenInBagSort()
  local count = #self.childrenList
  local scroll = self.m_panel:FindDirect("Img_Bg0/Group_Left/ScrollView_ChildrenList")
  local list = scroll:FindDirect("List_ChildrenList")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not scroll.isnil then
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local childId = self.childrenList[i]
    local child = ChildrenDataMgr.Instance():GetChildById(childId)
    self:FillChildItem(uiGo, i, child)
    if self.selection == childId then
      uiGo:GetComponent("UIToggle").value = true
    else
      uiGo:GetComponent("UIToggle").value = false
    end
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method().UpdateContent = function(self)
  local childId = self.selection
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  if child then
    if child:IsBaby() then
      self.babyPanel:Show(child)
      self.teenPanel:Hide()
      self.youthPanel:Hide()
    elseif child:IsTeen() then
      self.babyPanel:Hide()
      self.teenPanel:Show(child)
      self.youthPanel:Hide()
    elseif child:IsYouth() then
      self.babyPanel:Hide()
      self.teenPanel:Hide()
      self.youthPanel:Show(child)
    else
      self.babyPanel:Hide()
      self.teenPanel:Hide()
      self.youthPanel:Hide()
    end
  else
    self.babyPanel:Hide()
    self.teenPanel:Hide()
    self.youthPanel:Hide()
  end
end
def.method().UpdateCommon = function(self)
  local showChildId = ChildrenDataMgr.Instance():GetShowChildId()
  local text
  if self.selection == showChildId then
    text = textRes.Children[2]
  else
    text = textRes.Children[1]
  end
  local btnLbl = self.m_panel:FindDirect("Img_Bg0/Group_Common/Btn_Follow/Label")
  btnLbl:GetComponent("UILabel"):set_text(text)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 10) == "Img_Child_" then
    local index = tonumber(string.sub(id, 11))
    local childId = self.childrenList[index]
    if childId and self.selection ~= childId then
      self.selection = childId
      self:UpdateUI()
    end
  elseif id == "Btn_GoHome" then
    if _G.CheckCrossServerAndToast() then
      return
    end
    require("Main.Children.ChildrenModule").Instance():PutDownChild(self.selection)
  elseif id == "Btn_Follow" then
    if _G.CheckCrossServerAndToast() then
      return
    end
    require("Main.Children.ui.SetFollowingChildPanel").Instance():ShowPanel(self.selection)
  elseif self.babyPanel:onClick(id) then
  elseif self.teenPanel:onClick(id) then
  elseif self.youthPanel:onClick(id) then
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if self.babyPanel:onToggle(id, active) then
  elseif self.teenPanel:onToggle(id, active) then
  elseif self.youthPanel:onToggle(id, active) then
  end
end
def.method("string").onDragStart = function(self, id)
  if self.babyPanel:onDragStart(id) then
  elseif self.teenPanel:onDragStart(id) then
  elseif self.youthPanel:onDragStart(id) then
  end
end
def.method("string").onDragEnd = function(self, id)
  if self.babyPanel:onDragEnd(id) then
  elseif self.teenPanel:onDragEnd(id) then
  elseif self.youthPanel:onDragEnd(id) then
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.babyPanel:onDrag(id, dx, dy) then
  elseif self.teenPanel:onDrag(id, dx, dy) then
  elseif self.youthPanel:onDrag(id, dx, dy) then
  end
end
return ChildrenBagPanel.Commit()
