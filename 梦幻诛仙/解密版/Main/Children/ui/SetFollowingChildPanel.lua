local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SetFollowingChildPanel = Lplus.Extend(ECPanelBase, "SetFollowingChildPanel")
local GUIUtils = require("GUI.GUIUtils")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
local Child = require("Main.Children.Child")
local ChildrenModule = require("Main.Children.ChildrenModule")
local def = SetFollowingChildPanel.define
local instance
def.static("=>", SetFollowingChildPanel).Instance = function()
  if instance == nil then
    instance = SetFollowingChildPanel()
  end
  return instance
end
local phasesOrder = {
  ChildPhase.INFANT,
  ChildPhase.CHILD,
  ChildPhase.YOUTH
}
def.const("number").MAX_MODEL_NUM = 3
def.field("table").m_uiObjs = nil
def.field("userdata").m_cid = nil
def.field("table").m_childObjs = nil
def.field("table").m_childData = nil
def.field("number").m_selIndex = 0
def.field("string").m_dragObjId = ""
def.method("userdata").ShowPanel = function(self, cid)
  if self.m_panel ~= nil then
    self:DestroyPanel()
  end
  self.m_cid = cid
  self:CreatePanel(RESPATH.PREFAB_CHILDREN_FOLLOW_SETTING, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  if self:InitData() == false then
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_uiObjs = nil
  self:DestroyModels()
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:ResumeModels()
  end
end
def.method("=>", "boolean").InitData = function(self)
  self.m_childData = self:GetChild(self.m_cid)
  if self.m_childData == nil then
    warn(string.format([[
No child found for cid = %s
%s]], tostring(self.m_cid), debug.traceback()))
    return false
  end
  return true
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  self.m_uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_uiObjs.Group_Child = self.m_uiObjs.Img_Bg0:FindDirect("Group_Child")
  self.m_uiObjs.Btn_Confirm = self.m_uiObjs.Img_Bg0:FindDirect("Btn_Confirm")
  self.m_uiObjs.Btn_Change = self.m_uiObjs.Img_Bg0:FindDirect("Btn_Change")
  self.m_uiObjs.Btn_Back = self.m_uiObjs.Img_Bg0:FindDirect("Btn_Back")
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.find(id, "Img_BgChild") then
    self:OnModelClicked(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Change" then
    self:OnChangeBtnClick()
  elseif id == "Btn_Confirm" then
    self:OnConfirmBtnClick()
  elseif id == "Btn_Back" then
    self:OnBackBtnClick()
  end
end
def.method().UpdateUI = function(self)
  self:UpdateModels()
end
def.method().UpdateModels = function(self)
  local modelInfos = self:GetModelInfos(self.m_childData)
  self.m_childObjs = self.m_childObjs or {}
  for i = 1, SetFollowingChildPanel.MAX_MODEL_NUM do
    local childGO = self.m_uiObjs.Group_Child:FindDirect("Img_BgChild0" .. i)
    local modelInfo = modelInfos[i]
    if self.m_childObjs[i] then
      self.m_childObjs[i]:DestroyModel()
    end
    local childObj = self:SetModelInfo(childGO, modelInfo)
    self.m_childObjs[i] = childObj
    if modelInfo and modelInfo.default then
      GUIUtils.Toggle(childGO, true)
      self.m_selIndex = i
    end
  end
  self:UpdateOperateBtns()
end
def.method("userdata", "table", "=>", "table").SetModelInfo = function(self, childGO, modelInfo)
  if childGO == nil then
    return
  end
  if modelInfo == nil then
    childGO:SetActive(false)
    return nil
  end
  childGO:SetActive(true)
  local Model = childGO:FindDirect("Model")
  local childObj
  if modelInfo.weaponId > 0 then
    childObj = Child.CreateWithFashionAndWeapon(modelInfo.modelCfgId, modelInfo.fashionId, modelInfo.weaponId)
  else
    childObj = Child.CreateWithFashion(modelInfo.modelCfgId, modelInfo.fashionId)
  end
  childObj:LoadUIModel(nil, function()
    if Model.isnil then
      return
    end
    local ecmodel = childObj:GetModel()
    if ecmodel == nil or ecmodel.m_model == nil then
      return
    end
    local uiModel = Model:GetComponent("UIModel")
    uiModel.modelGameObject = ecmodel.m_model
  end)
  return childObj
end
def.method().ResumeModels = function(self)
  if self.m_childObjs == nil then
    return
  end
  for i, v in ipairs(self.m_childObjs) do
    local ecmodel = v:GetModel()
    ecmodel:Play(ecmodel.curAniName)
  end
end
def.method("userdata", "=>", "table").GetChild = function(self, cid)
  return ChildrenDataMgr.Instance():GetChildById(cid)
end
def.method("table", "=>", "table").GetModelInfos = function(self, child)
  local modelInfos = {}
  local phase = child:GetStatus()
  for i, v in ipairs(phasesOrder) do
    local modelInfo = {phase = v}
    modelInfos[#modelInfos + 1] = modelInfo
    if phase == v then
      break
    end
  end
  local lastModelInfo = modelInfos[#modelInfos]
  if lastModelInfo then
    lastModelInfo.default = true
  end
  local gender = child:GetGender()
  for i, v in ipairs(modelInfos) do
    v.gender = gender
    local fashion = child:GetFashionByPhase(v.phase)
    v.fashionId = fashion and fashion.fashionId or 0
    v.modelCfgId = child:GetModelIdByPhase(v.phase)
    if v.phase == ChildPhase.YOUTH then
      v.weaponId = child:GetWeaponId()
    else
      v.weaponId = 0
    end
  end
  return modelInfos
end
def.method().DestroyModels = function(self)
  if self.m_childObjs == nil then
    return
  end
  for i, v in ipairs(self.m_childObjs) do
    v:DestroyModel()
  end
end
def.method("userdata").OnModelClicked = function(self, obj)
  local parent = obj
  local index = tonumber(string.sub(parent.name, #"Img_BgChild0" + 1, -1))
  self.m_selIndex = index
end
def.method().UpdateOperateBtns = function(self)
  local childId, childPahse = ChildrenDataMgr.Instance():GetShowChildId()
  local cphase = self.m_childData:GetStatus()
  local bShowChangeBtn = childId == self.m_cid
  local bShowConfirmBtn = childId ~= self.m_cid
  local bShowBackBtn = childId == self.m_cid
  GUIUtils.SetActive(self.m_uiObjs.Btn_Change, bShowChangeBtn)
  GUIUtils.SetActive(self.m_uiObjs.Btn_Confirm, bShowConfirmBtn)
  GUIUtils.SetActive(self.m_uiObjs.Btn_Back, bShowBackBtn)
end
def.method("=>", "number").GetSelPhase = function(self)
  local phase = phasesOrder[self.m_selIndex]
  return phase
end
def.method().OnChangeBtnClick = function(self)
  local phase = self:GetSelPhase()
  ChildrenModule.Instance():ShowChild(self.m_cid, phase)
  self:DestroyPanel()
end
def.method().OnConfirmBtnClick = function(self)
  local phase = self:GetSelPhase()
  ChildrenModule.Instance():ShowChild(self.m_cid, phase)
  self:DestroyPanel()
end
def.method().OnBackBtnClick = function(self)
  ChildrenModule.Instance():HideChild()
  self:DestroyPanel()
end
def.method("string").onDragStart = function(self, id)
  self.m_dragObjId = id
end
def.method("string").onDragEnd = function(self, id)
  self.m_dragObjId = ""
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if id ~= self.m_dragObjId then
    return
  end
  local index = tonumber(string.sub(id, #"Img_BgChild0" + 1, -1))
  if index == nil then
    return
  end
  if self.m_childObjs[index] then
    local ecmodel = self.m_childObjs[index]:GetModel()
    ecmodel:SetDir(ecmodel.m_ang - dx / 2)
  end
end
return SetFollowingChildPanel.Commit()
