local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BackToHomePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local HouseMgr = require("Main.Homeland.HouseMgr")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local MarriageInterface = require("Main.Marriage.MarriageInterface")
local def = BackToHomePanel.define
def.field("table").m_UIGOs = nil
def.field("table").m_children = nil
def.field("userdata").m_selChildId = nil
def.field("userdata").m_lastToggle = nil
local instance
def.static("=>", BackToHomePanel).Instance = function()
  if instance == nil then
    instance = BackToHomePanel()
    instance:Init()
  end
  return instance
end
def.static().ShowPanel = function()
  local self = BackToHomePanel()
  self:Init()
  self:CreatePanel(RESPATH.PREFAB_BACK_TO_HOMELAND_PANEL, 1)
end
def.method().Init = function(self)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):HaveHome() then
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Featur_Openchange, BackToHomePanel.OnFeatureOpenChange, self)
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_children = nil
  self.m_selChildId = nil
  self.m_lastToggle = nil
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Featur_Openchange, BackToHomePanel.OnFeatureOpenChange)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_Shuxing = self.m_UIGOs.Img_Bg:FindDirect("Group_Shuxing")
  self.m_UIGOs.Texture = self.m_UIGOs.Img_Bg:FindDirect("Texture")
  self.m_UIGOs.Btn_Children = self.m_UIGOs.Img_Bg:FindDirect("Btn_Children")
  self.m_UIGOs.Group_MyChildren = self.m_UIGOs.Img_Bg:FindDirect("Group_MyChildren")
  self.m_UIGOs.Group_MateChildren = self.m_UIGOs.Img_Bg:FindDirect("Group_MateChildren")
  self.m_UIGOs.Group_ChildInfo = self.m_UIGOs.Img_Bg:FindDirect("Group_ChildInfo")
  self.m_UIGOs.Btn_Help = self.m_UIGOs.Img_Bg:FindDirect("Btn_Help")
  self.m_UIGOs.Img_MakeRed = self.m_UIGOs.Img_Bg:FindDirect("Btn_Back/Img_MakeRed")
  local Sprite = self.m_UIGOs.Group_ChildInfo:FindDirect("Sprite")
  if Sprite then
    local uiWidget = Sprite:GetComponent("UIWidget")
    uiWidget.depth = uiWidget.depth - 1
  end
end
def.method().UpdateUI = function(self)
  self:UpdateChilds()
  local house = HouseMgr.Instance():GetMyHouse()
  local houseLevel = house:GetLevel()
  local levelInfo = HouseMgr.Instance():GetHouseLevelInfo(houseLevel)
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  local fengShuiValue = house:GetGeomancy()
  local cleanliness = house:GetCleanness()
  local maxFengShui = houseCfg.maxFengShui
  local maxCleanliness = houseCfg.maxCleanliness
  local fengShuiCfg = HomelandUtils.GetHouseFengShuiCfg(fengShuiValue)
  local cleanlinessCfg = HomelandUtils.GetHouseCleanlinessCfg(cleanliness)
  GUIUtils.SetTexture(self.m_UIGOs.Texture, levelInfo.icon)
  local Group_Shuxing = self.m_UIGOs.Img_Bg:FindDirect("Group_Shuxing")
  local Label_LevelNumber = Group_Shuxing:FindDirect("Label_LevelNumber")
  local Label_FengshuiStatus = Group_Shuxing:FindDirect("Label_FengshuiStatus")
  local Label_FengshuiNumber = Group_Shuxing:FindDirect("Label_FengshuiNumber")
  local Label_Clean = Group_Shuxing:FindDirect("Label_Clean")
  GUIUtils.SetText(Label_LevelNumber, levelInfo.name)
  GUIUtils.SetText(Label_FengshuiStatus, fengShuiCfg.showName)
  local text = string.format("%d/%d", fengShuiValue, maxFengShui)
  GUIUtils.SetText(Label_FengshuiNumber, text)
  GUIUtils.SetText(Label_Clean, cleanlinessCfg.showName)
  local PokemonModule = require("Main.Pokemon.PokemonModule")
  local bNeedRedDot = PokemonModule.Instance():NeedReddot()
  local bMysteryVisitorActive = require("Main.Homeland.homeVisitor.HomeVisitorMgr").IsActActive()
  local bCanCourtyardBeCleand = require("Main.Homeland.CourtyardMgr").Instance():CanCourtyardBeCleand()
  if bNeedRedDot or bMysteryVisitorActive or bCanCourtyardBeCleand then
    self.m_UIGOs.Img_MakeRed:SetActive(true)
  else
    self.m_UIGOs.Img_MakeRed:SetActive(false)
  end
end
def.method("=>", "boolean").IsChildrenFunctionOpen = function(self)
  return require("Main.Children.ChildrenInterface").IsFunctionOpen()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Back" then
    self:OnBackBtnClick()
  elseif id == "Sprite" then
    self:OnTipsBtnClick()
  elseif id == "Btn_Help" then
    self:OnChildTipsBtnClick()
  elseif id == "Btn_Children" then
    self:DestroyPanel()
    require("Main.Children.ChildrenInterface").OpenChildrenBag(nil)
  elseif id:find("Img_Icon_") then
    self:OnClickImgIcon(obj)
  end
end
def.method().OnBackBtnClick = function(self)
  self:DestroyPanel()
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):ReturnHome()
end
def.method().OnTipsBtnClick = function(self)
  local tipId = 701605013
  require("Main.Common.TipsHelper").ShowHoverTip(tipId, 0, 0)
end
def.method().OnChildTipsBtnClick = function(self)
  local tipId = 701605123
  require("Main.Common.TipsHelper").ShowHoverTip(tipId, 0, 0)
end
def.method("userdata").OnClickImgIcon = function(self, go)
  local strs = go.name:split("_")
  local childId = Int64.ParseString(strs[#strs])
  if childId == nil then
    print("childId is nil")
    return
  end
  local child = self.m_children[childId:tostring()]
  if child == nil then
    print("child not found " .. childId:tostring())
    if self.m_lastToggle then
      GUIUtils.Toggle(self.m_lastToggle, true)
    else
      GUIUtils.Toggle(go, false)
    end
    return
  end
  self:SetChildInfo(child)
  GUIUtils.Toggle(go, true)
  self.m_lastToggle = go
end
def.method("table").OnFeatureOpenChange = function(self, params)
  local open = params.open
  if not open then
    Toast(textRes.Children[1042])
  end
  self:UpdateUI()
end
def.method().UpdateChilds = function(self)
  local isChildrenOpen = self:IsChildrenFunctionOpen()
  GUIUtils.SetActive(self.m_UIGOs.Group_MyChildren, isChildrenOpen)
  GUIUtils.SetActive(self.m_UIGOs.Group_MateChildren, isChildrenOpen)
  GUIUtils.SetActive(self.m_UIGOs.Group_ChildInfo, isChildrenOpen)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Children, isChildrenOpen)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Help, isChildrenOpen)
  if not isChildrenOpen then
    return
  end
  self.m_children = {}
  local allChild = ChildrenDataMgr.Instance():GetAllChildren() or {}
  for k, v in pairs(allChild) do
    self.m_children[k] = v
  end
  self:UpdateMyChilds()
  self:UpdateMateChilds()
  self:UpdateSelectedChildInfo()
end
def.method().UpdateMyChilds = function(self)
  local children = self.m_children
  local myChildren = {}
  for k, v in pairs(children) do
    if v:IsMine() then
      table.insert(myChildren, v)
    end
  end
  local baseGO = self.m_UIGOs.Group_MyChildren
  local childCount = baseGO.childCount
  local index = 0
  for i = 1, childCount do
    local Img_BgIcon = baseGO:GetChild(i - 1)
    if Img_BgIcon.name:find("Img_BgIcon") then
      index = index + 1
      local child = myChildren[index]
      self:SetChildIcon(Img_BgIcon, child)
    end
  end
end
def.method().UpdateMateChilds = function(self)
  local baseGO = self.m_UIGOs.Group_MateChildren
  local mateInfo = MarriageInterface.GetMateInfo()
  if mateInfo == nil or mateInfo.mateId == nil then
    baseGO:SetActive(false)
    return
  end
  baseGO:SetActive(true)
  local children = self.m_children
  local mateChildren = {}
  for k, v in pairs(children) do
    if not v:IsMine() then
      table.insert(mateChildren, v)
    end
  end
  local childCount = baseGO.childCount
  local index = 0
  for i = 1, childCount do
    local Img_BgIcon = baseGO:GetChild(i - 1)
    if Img_BgIcon.name:find("Img_BgIcon") then
      index = index + 1
      local child = mateChildren[index]
      self:SetChildIcon(Img_BgIcon, child)
    end
  end
end
def.method("userdata", "table").SetChildIcon = function(self, Img_BgIcon, child)
  local Img_Icon = Img_BgIcon:FindChildByPrefix("Img_Icon", false)
  local icon
  if child then
    icon = ChildrenUtils.GetChildHeadIcon(child:GetCurModelId())
    Img_BgIcon.name = "Img_Icon_" .. tostring(child:GetId())
  else
    icon = 0
    Img_BgIcon.name = "Img_Icon_0"
  end
  GUIUtils.SetTexture(Img_Icon, icon)
  GUIUtils.Toggle(Img_BgIcon, false)
  local uiToggle = Img_BgIcon:GetComponent("UIToggle")
  if uiToggle then
    uiToggle.optionCanBeNone = true
  end
end
def.method().UpdateSelectedChildInfo = function(self)
  local child
  if self.m_selChildId then
    child = self.m_children[self.m_selChildId:tostring()]
  end
  self:SetChildInfo(child)
end
def.method("table").SetChildInfo = function(self, child)
  local Group_ChildInfo = self.m_UIGOs.Group_ChildInfo
  if child == nil then
    Group_ChildInfo:SetActive(false)
    return
  end
  Group_ChildInfo:SetActive(true)
  local Label_Belong = Group_ChildInfo:FindDirect("Label_Belong")
  local Label_Name = Group_ChildInfo:FindDirect("Label_Name")
  local Label_Term = Group_ChildInfo:FindDirect("Label_Term")
  local Label_Place = Group_ChildInfo:FindDirect("Label_Place")
  local ownerName
  if child:IsMine() then
    ownerName = GetHeroProp().name
  else
    local mateInfo = MarriageInterface.GetMateInfo()
    ownerName = mateInfo and mateInfo.mateName or "$mateName"
  end
  local periodName = textRes.Children.PeriodName[child:GetStatus()] or "$periodName"
  local childName = child:GetName()
  local term = string.format(textRes.Children[4102], periodName, childName)
  local locationText = textRes.Children[4103]
  GUIUtils.SetText(Label_Name, ownerName)
  GUIUtils.SetText(Label_Term, term)
  GUIUtils.SetText(Label_Place, locationText)
  self.m_selChildId = child:GetId()
  gmodule.moduleMgr:GetModule(ModuleId.CHILDREN):QueryChildLocation(self.m_selChildId, function(p)
    if Label_Place == nil or Label_Place.isnil then
      return
    end
    if p.child_id ~= self.m_selChildId then
      return
    end
    locationText = ChildrenUtils.GetChildLocationText(p.location)
    GUIUtils.SetText(Label_Place, locationText)
  end)
end
return BackToHomePanel.Commit()
