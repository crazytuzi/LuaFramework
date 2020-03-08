local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local ECUIModel = require("Model.ECUIModel")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local WingsMgr = require("Main.Wings.data.WingsDataMgr")
local WingsSkillSubNode = require("Main.Wings.ui.WingsSkillSubNode")
local WingsPropSubNode = require("Main.Wings.ui.WingsPropSubNode")
local WingsViewPanel = require("Main.Wings.ui.WingsViewPanel")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local HeroPropPanelNodeBase = require("Main.Hero.ui.HeroPropPanelNodeBase")
local WingsNode = Lplus.Extend(HeroPropPanelNodeBase, "WingsNode")
local def = WingsNode.define
def.field("boolean").isDraggingModel = false
def.field("number").curState = 1
def.field("table").nodes = nil
def.field("table").tabs = nil
def.field("table").model = nil
def.field("number").schemaCount = 0
def.field("number").curSchemaIdx = 0
def.field("boolean").isSchemaListShow = false
def.field("number").waitToOpenNode = 0
def.const("table").StateId = {
  INVALID = 0,
  PROP = 1,
  SKILL = 2
}
local instance
def.static("=>", WingsNode).Instance = function()
  if instance == nil then
    instance = WingsNode()
  end
  return instance
end
def.override("=>", "boolean").IsUnlock = function(self)
  return WingsDataMgr.Instance():IsWingsFuncUnlocked()
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.curState = WingsNode.StateId.PROP
  if self.waitToOpenNode ~= 0 then
    self.curState = self.waitToOpenNode
  end
  self.nodes = {}
  local propNodeRoot = self.m_node:FindDirect("Group_Right/Group_Attribute")
  self.nodes[WingsNode.StateId.PROP] = WingsPropSubNode.Instance()
  self.nodes[WingsNode.StateId.PROP]:Init(base, propNodeRoot)
  local skillNodeRoot = self.m_node:FindDirect("Group_Right/Group_Skill")
  self.nodes[WingsNode.StateId.SKILL] = WingsSkillSubNode.Instance()
  self.nodes[WingsNode.StateId.SKILL]:Init(base, skillNodeRoot)
  self.tabs = {}
  local tabAttribute = self.m_node:FindDirect("Group_Right/Tab_Attribute")
  self.tabs[WingsNode.StateId.PROP] = tabAttribute
  local tabSkill = self.m_node:FindDirect("Group_Right/Tab_Skill")
  self.tabs[WingsNode.StateId.SKILL] = tabSkill
end
def.override().OnShow = function(self)
  self:Fill()
  self:SwitchToNode(self.curState)
  GameUtil.AddGlobalTimer(0, true, function()
    if self.m_node and not self.m_node.isnil then
      self.tabs[self.curState]:GetComponent("UIToggle"):set_value(true)
    end
  end)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SYNC_INFO, WingsNode.OnSyncWingsInfo)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SCHEMA_CHANGED, WingsNode.OnWingsSchemaChanged)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_ACTIVE_SCHEMA_CHANGED, WingsNode.OnActiveSchemaChanged)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASE_UP, WingsNode.OnWingsPhaseUp)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_LEVEL_UP, WingsNode.OnWingsLevelUp)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SYNC_INFO, WingsNode.OnSyncWingsInfo)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SCHEMA_CHANGED, WingsNode.OnWingsSchemaChanged)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_ACTIVE_SCHEMA_CHANGED, WingsNode.OnActiveSchemaChanged)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASE_UP, WingsNode.OnWingsPhaseUp)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_LEVEL_UP, WingsNode.OnWingsLevelUp)
  self:ClearUp()
  self:DestroyModel()
end
def.method().ClearUp = function(self)
  self.schemaCount = 0
  self.curSchemaIdx = 0
  self.isSchemaListShow = false
  self.waitToOpenNode = 0
end
def.method().Fill = function(self)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  self:UpdateModelInfo()
  self:UpdateSchemaInfo()
  self:UpdatePhaseUpNotice()
end
def.method().UpdateModelInfo = function(self)
  self:UpdateModelUI()
  self:UpdateModel()
end
def.method().UpdateSchemaInfo = function(self)
  self.schemaCount = WingsDataMgr.Instance().schemaCount
  self.curSchemaIdx = WingsDataMgr.Instance().curSchemaIdx
  local btnSelectPlan = self.m_node:FindDirect("Group_Left/Btn_SelectPlan")
  local uilabelSelected = btnSelectPlan:FindDirect("Label"):GetComponent("UILabel")
  uilabelSelected:set_text(textRes.Wings[5] .. self.curSchemaIdx)
  self:ToggleEnableButton(WingsDataMgr.Instance():IsCurrentSchemaOn())
  self:UpdateSchemaList(false)
end
def.method("boolean").UpdateSchemaList = function(self, isShow)
  local btns = self.m_node:FindDirect("Group_Left/Table_TeamBtn")
  local upArrow = self.m_node:FindDirect("Group_Left/Btn_SelectPlan/Img_Up")
  local downArrow = self.m_node:FindDirect("Group_Left/Btn_SelectPlan/Img_Down")
  local template = btns:FindDirect("DungeonBtn")
  if isShow then
    upArrow:SetActive(true)
    downArrow:SetActive(false)
    btns:SetActive(true)
    template:SetActive(false)
    while btns:get_childCount() > 2 do
      local toBeDelete = btns:GetChild(btns:get_childCount() - 1)
      if toBeDelete.name ~= template.name and toBeDelete.name ~= "spaceHolder" then
        Object.DestroyImmediate(toBeDelete)
      end
    end
    local activeIdx = WingsDataMgr.Instance():GetActiveSchemaIdx()
    for i = 1, WingsDataMgr.MAX_SCHEMA_NUM do
      local newBtn = Object.Instantiate(template)
      newBtn:SetActive(true)
      newBtn.parent = btns
      newBtn.name = string.format("SchemaItem%d", i)
      newBtn:set_localScale(EC.Vector3.one)
      local uilblName = newBtn:FindDirect("Label_1"):GetComponent("UILabel")
      uilblName:set_text(string.format(textRes.Wings[6], i))
      local imgLock = newBtn:FindDirect("Img_Lock")
      local lblOpenMoney = newBtn:FindDirect("Label_2")
      local imgReset = newBtn:FindDirect("Img_Reset")
      imgReset.name = string.format("SchemaResetBtn%d", i)
      local imgOnwork = newBtn:FindDirect("Img_OnWork")
      imgOnwork:SetActive(false)
      if i <= self.schemaCount then
        imgLock:SetActive(false)
        imgReset:SetActive(true)
        lblOpenMoney:SetActive(false)
        if i == activeIdx then
          imgOnwork:SetActive(true)
        end
      else
        imgLock:SetActive(true)
        lblOpenMoney:SetActive(true)
        local yuanbaoNeed = 0
        if i == 2 then
          yuanbaoNeed = WingsDataMgr.SCHEMA2_NEED_YUANBAO
        elseif i == 3 then
          yuanbaoNeed = WingsDataMgr.SCHEMA3_NEED_YUANBAO
        end
        lblOpenMoney:GetComponent("UILabel"):set_text(string.format(textRes.Wings[11], yuanbaoNeed))
        imgReset:SetActive(false)
      end
      self.m_base.m_msgHandler:Touch(newBtn)
    end
    btns:GetComponent("UITableResizeBackground"):Reposition()
    self.isSchemaListShow = true
  else
    upArrow:SetActive(false)
    downArrow:SetActive(true)
    btns:SetActive(false)
    self.isSchemaListShow = false
  end
end
def.method().UpdatePhaseUpNotice = function(self)
  local imgRed = self.tabs[WingsNode.StateId.SKILL]:FindDirect("Img_Red")
  local isReadyToPhaseUp = WingsDataMgr.Instance():CheckCanPhaseUp()
  imgRed:SetActive(isReadyToPhaseUp)
end
def.method("boolean").ToggleEnableButton = function(self, isOn)
  local cancel = self.m_node:FindDirect("Group_Left/Btn_Open"):SetActive(not isOn)
  local open = self.m_node:FindDirect("Group_Left/Btn_Cancel"):SetActive(isOn)
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.override("table", "table").OnSyncHeroProp = function(self, params, context)
end
def.method("number").SwitchToNode = function(self, nodeId)
  for k, v in pairs(self.nodes) do
    if nodeId == k then
      self.curState = nodeId
      v:Show()
    else
      v:Hide()
    end
  end
end
def.method("number").OnOpenNewSchema = function(self, idx)
  local yuanbaoNeed
  if idx == 2 then
    yuanbaoNeed = WingsDataMgr.SCHEMA2_NEED_YUANBAO
  elseif idx == 3 then
    yuanbaoNeed = WingsDataMgr.SCHEMA3_NEED_YUANBAO
  else
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Wings[7], string.format(textRes.Wings[8], yuanbaoNeed), function(id, tag)
    if id == 1 then
      self:SendOpenNewSchemaReq()
    end
  end, nil)
end
def.method().SendOpenNewSchemaReq = function(self)
  local p = require("netio.protocol.mzm.gsp.wing.COpenNewWing").new()
  gmodule.network.sendProtocol(p)
end
def.method("number").SwitchToWingSchema = function(self, newIdx)
  WingsDataMgr.Instance():SwitchSchema(newIdx)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SCHEMA_CHANGED, nil)
  self:ToggleEnableButton(WingsDataMgr.Instance():IsCurrentSchemaOn())
end
def.override("string").onClick = function(self, id)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  if id ~= "Btn_SelectPlan" and self.isSchemaListShow then
    self:UpdateSchemaList(false)
  end
  if id == "Tab_Attribute" then
    self:SwitchToNode(WingsNode.StateId.PROP)
  elseif id == "Tab_Skill" then
    self:SwitchToNode(WingsNode.StateId.SKILL)
  elseif id == "Btn_Change" then
    self:OnChangeViewClicked()
  elseif id == "Btn_SelectPlan" then
    self:OnSelectSchemaBtnClicked()
  elseif id == "Btn_Open" then
    self:OnEnableSchemaClicked()
  elseif id == "Btn_Cancel" then
    self:OnCancelSchemaClicked()
  elseif string.find(id, "SchemaItem") then
    local index = tonumber(string.sub(id, 11))
    self:OnSchemaSelected(index)
  elseif string.find(id, "SchemaResetBtn") then
    local index = tonumber(string.sub(id, 15))
    self:OnBtnResetSchemaClicked(index)
  else
    self.nodes[self.curState]:onClick(id)
  end
end
def.method().OnEnableSchemaClicked = function(self)
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  local p = require("netio.protocol.mzm.gsp.wing.CEnableWing").new(idx)
  gmodule.network.sendProtocol(p)
end
def.method().OnCancelSchemaClicked = function(self)
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  local p = require("netio.protocol.mzm.gsp.wing.CCancelWing").new(idx)
  gmodule.network.sendProtocol(p)
end
def.method("number").OnBtnResetSchemaClicked = function(self, index)
  local yuanbaoNeed = WingsDataMgr.RESET_WING_YUANBAO_NUM
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Wings[9], string.format(textRes.Wings[10], yuanbaoNeed), function(id, tag)
    if id == 1 then
      self:SendResetSchemaReq(index)
    end
  end, nil)
end
def.method("number").SendResetSchemaReq = function(self, index)
  local p = require("netio.protocol.mzm.gsp.wing.CResetWing").new(index)
  gmodule.network.sendProtocol(p)
end
def.method().OnSelectSchemaBtnClicked = function(self)
  if self.isSchemaListShow then
    self:UpdateSchemaList(false)
  else
    self:UpdateSchemaList(true)
  end
end
def.method("number").OnSchemaSelected = function(self, index)
  if index == self.curSchemaIdx then
    return
  end
  if index == self.schemaCount + 1 then
    self:OnOpenNewSchema(index)
  elseif index <= self.schemaCount then
    self:SwitchToWingSchema(index)
  else
    Toast(string.format(textRes.Wings[4], self.schemaCount + 1))
  end
  WingsDataMgr.Instance():ClearResetPropData()
  WingsDataMgr.Instance():ClearRandomSkillData()
end
def.method().OnChangeViewClicked = function(self)
  local curIndex = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_OPEN_WINGS_VIEW_PANEL_REQ, {index = curIndex})
end
def.override("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDraggingModel = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.isDraggingModel = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDraggingModel == true then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
def.method().UpdateModelUI = function(self)
  local lblModelName = self.m_node:FindDirect("Group_Left/Img_NameBg/Label")
  if not WingsDataMgr.Instance():IsCurrentSchemaOn() or WingsDataMgr.Instance():GetIsWingsShowing() == 0 then
    lblModelName:GetComponent("UILabel"):set_text("\230\151\160")
    return
  end
  local nameString = WingsDataMgr.Instance():GetCurrentModelName()
  lblModelName:GetComponent("UILabel"):set_text(nameString)
end
def.method().UpdateModel = function(self)
  local uiModel = self.m_node:FindDirect("Group_Left/Model"):GetComponent("UIModel")
  if uiModel.mCanOverflow ~= nil then
    uiModel.mCanOverflow = true
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
  local modelPath = GetModelPath(modelId)
  if modelPath == nil then
    return
  end
  local function modelLoadCB()
    self.model:SetDir(180)
    self.model:Play("Stand_c")
    self.model:SetScale(1)
    self.model:SetPos(0, 0)
    self:UpdateModelExtra()
    uiModel.modelGameObject = self.model.m_model
  end
  if not self.model then
    self.model = ECUIModel.new(modelId)
    self.model.m_bUncache = true
    self.model:LoadUIModel(modelPath, function(ret)
      if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil or uiModel == nil or uiModel.isnil then
        return
      end
      modelLoadCB()
    end)
  else
    modelLoadCB()
  end
end
def.method().UpdateModelExtra = function(self)
  local DyeingMgr = require("Main.Dyeing.DyeingMgr")
  local dyeData = DyeingMgr.GetCurClothData()
  if dyeData then
    if dyeData.hairid then
      local hairColor = DyeingMgr.GetColorFormula(dyeData.hairid)
      DyeingMgr.ChangeModelColor(DyeingMgr.PARTINDEX.HAIR, self.model, hairColor)
    end
    if dyeData.clothid then
      local clothColor = DyeingMgr.GetColorFormula(dyeData.clothid)
      DyeingMgr.ChangeModelColor(DyeingMgr.PARTINDEX.CLOTH, self.model, clothColor)
    end
  end
  local position = require("consts.mzm.gsp.item.confbean.WearPos")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local weapon = ItemModule.Instance():GetHeroEquipmentCfg(position.WEAPON)
  local strenLevel = weapon and weapon.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
  self.model:SetWeapon(weapon and weapon.id or 0, strenLevel or 0)
  local fabao = ItemModule.Instance():GetHeroEquipmentCfg(position.FABAO)
  self.model:SetFabao(fabao and fabao.id or 0)
  self:UpdateModelWings()
end
def.method().UpdateModelWings = function(self)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    return
  end
  if not self.model then
    return
  end
  if not WingsDataMgr.Instance():IsCurrentSchemaOn() or WingsDataMgr.Instance():GetIsWingsShowing() == 0 then
    self.model:SetWing(0, 0)
    return
  end
  local curView = WingsDataMgr.Instance():GetCurrentViewOfCurrentSchema()
  if not curView then
    return
  end
  self.model:SetWing(curView.modelId, curView.dyeId)
end
def.static("table", "table").OnWingsSchemaChanged = function(params, context)
  instance:UpdateSchemaInfo()
  instance:UpdateModelUI()
  instance:UpdateModelWings()
  instance:UpdatePhaseUpNotice()
  instance.nodes[instance.curState]:OnWingsSchemaChanged()
end
def.static("table", "table").OnSyncWingsInfo = function(params, context)
  instance:Fill()
  instance.nodes[instance.curState]:OnSyncWingsInfo(params, context)
end
def.static("table", "table").OnActiveSchemaChanged = function(params, context)
  instance:ToggleEnableButton(WingsDataMgr.Instance():IsCurrentSchemaOn())
  instance:UpdateModelWings()
  instance:UpdateModelUI()
end
def.static("table", "table").OnWingsPhaseUp = function(params, context)
  instance:UpdateModelWings()
  instance:UpdatePhaseUpNotice()
end
def.static("table", "table").OnWingsLevelUp = function(params, context)
  instance:UpdatePhaseUpNotice()
end
return WingsNode.Commit()
