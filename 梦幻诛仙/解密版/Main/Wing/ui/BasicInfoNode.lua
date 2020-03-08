local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local BasicInfoNode = Lplus.Extend(TabNode, "BasicInfoNode")
local WingModule = require("Main.Wing.WingModule")
local GUIUtils = require("GUI.GUIUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local WingUtils = require("Main.Wing.WingUtils")
local RoleAndWingModel = require("Main.Wing.ui.RoleAndWingModel")
local WingInterface = require("Main.Wing.WingInterface")
local def = BasicInfoNode.define
def.const("number").MAXSKILLNUM = 15
def.field("table").modelAndWing = nil
def.field("boolean").isDrag = false
def.field("table").skills = nil
def.field("table").occPlans = nil
def.field("boolean").isClearRedPoint = false
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.WING, gmodule.notifyId.Wing.WINGS_CHANGE, BasicInfoNode.OnWingChange, self)
  Event.RegisterEventWithContext(ModuleId.WING, gmodule.notifyId.Wing.WINGS_EXP_CHANGE, BasicInfoNode.OnInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.WING, gmodule.notifyId.Wing.WINGS_PHASE_CHANGE, BasicInfoNode.OnInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.WING, gmodule.notifyId.Wing.WINGS_CHANGE_PLAN_SUCCESS, BasicInfoNode.OnChangePlanSuccess, self)
  Event.RegisterEventWithContext(ModuleId.WING, gmodule.notifyId.Wing.WING_PLAN_NAME_CHANGE, BasicInfoNode.OnCurOccNameChange, self)
  self:InitSelectList()
  self:UpdateProps()
  self:UpdateSkills()
  self:UpdateBasicInfo()
  self:CreateModel()
  self.isClearRedPoint = true
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_CHANGE, BasicInfoNode.OnWingChange)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_EXP_CHANGE, BasicInfoNode.OnInfoChange)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_PHASE_CHANGE, BasicInfoNode.OnInfoChange)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_CHANGE_PLAN_SUCCESS, BasicInfoNode.OnChangePlanSuccess)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WING_PLAN_NAME_CHANGE, BasicInfoNode.OnCurOccNameChange)
  if self.modelAndWing then
    self.modelAndWing:Destroy()
    self.modelAndWing = nil
  end
  self:clearRedPoint()
end
def.method().clearRedPoint = function(self)
  if self.isClearRedPoint and WingInterface.HasWingNotify() then
    local wingData = WingModule.Instance():GetWingData()
    wingData:clearRedPointInfo()
    local p = require("netio.protocol.mzm.gsp.wing.CRemoveNewOccPlanTipReq").new()
    gmodule.network.sendProtocol(p)
    Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_RED_POINT_REFRESH, nil)
    self.isClearRedPoint = false
    if _G.IsNil(self.m_node) then
      return
    end
    local Group_Select = self.m_node:FindDirect("Group_Right/Group_Attribute/Group_Select")
    local Group_Btn = Group_Select:FindDirect("Group_Btn")
    local Label_Name = Group_Btn:FindDirect("Label_Name")
    local Img_ProvinceBg = Group_Btn:FindDirect("Img_ProvinceBg")
    GUIUtils.SetLightEffect(Img_ProvinceBg, GUIUtils.Light.None)
  end
end
def.method("table").OnWingChange = function(self, params)
  self:UpdateBasicInfo()
  self:UpdateSkills()
  self:CreateModel()
end
def.method("table").OnInfoChange = function(self, params)
  self:UpdateBasicInfo()
  self:UpdateProps()
end
def.method("table").OnChangePlanSuccess = function(self, params)
  self:UpdateProps()
  self:UpdateSkills()
  self:UpdateBasicInfo()
end
def.method("table").OnCurOccNameChange = function(self, params)
  self:setCurOccName()
end
def.method().CreateModel = function(self)
  local uiModel = self.m_node:FindDirect("Group_Left/Model")
  local uiModelCmp = uiModel:GetComponent("UIModel")
  if self.modelAndWing == nil then
    self.modelAndWing = RoleAndWingModel()
  else
    self.modelAndWing:Destroy()
    self.modelAndWing = RoleAndWingModel()
  end
  local outlookId = 0
  local wingDyeId = 0
  local wingData = WingModule.Instance():GetWingData()
  local curWing = wingData:GetCurWing()
  if curWing then
    local wingCfg = WingUtils.GetWingCfg(curWing.id)
    outlookId = wingCfg.outlook
    wingDyeId = curWing.colorId
  end
  self.modelAndWing:Create(outlookId, wingDyeId, function()
    if uiModelCmp.isnil then
      return
    end
    uiModelCmp.mCanOverflow = true
    uiModelCmp.modelGameObject = self.modelAndWing:GetModelGameObject()
    local camera = uiModelCmp:get_modelCamera()
    camera:set_orthographic(true)
  end)
end
def.method().UpdateProps = function(self)
  local propUI = self.m_node:FindDirect("Group_Right/Group_Attribute/Img_Bg")
  local prop1 = propUI:FindDirect("Attribute_1/Label2")
  local prop2 = propUI:FindDirect("Attribute_2/Label2")
  local prop3 = propUI:FindDirect("Attribute_3/Label2")
  local prop4 = propUI:FindDirect("Attribute_4/Label2")
  local prop5 = propUI:FindDirect("Attribute_5/Label2")
  local prop6 = propUI:FindDirect("Attribute_6/Label2")
  local prop7 = propUI:FindDirect("Attribute_7/Label2")
  local prop8 = propUI:FindDirect("Attribute_8/Label2")
  local prop9 = propUI:FindDirect("Attribute_9/Label2")
  local prop10 = propUI:FindDirect("Attribute_10/Label2")
  local prop11 = propUI:FindDirect("Attribute_11/Label2")
  local prop12 = propUI:FindDirect("Attribute_12/Label2")
  local wingData = WingModule.Instance():GetWingData()
  local props = wingData:GetProperty()
  prop1:GetComponent("UILabel"):set_text(tostring(props.PHYATK))
  prop2:GetComponent("UILabel"):set_text(tostring(props.PHYDEF))
  prop3:GetComponent("UILabel"):set_text(tostring(props.MAGATK))
  prop4:GetComponent("UILabel"):set_text(tostring(props.MAGDEF))
  prop5:GetComponent("UILabel"):set_text(tostring(props.MAX_HP))
  prop6:GetComponent("UILabel"):set_text(tostring(props.SPEED))
  prop7:GetComponent("UILabel"):set_text(tostring(props.PHY_CRIT_LEVEL))
  prop8:GetComponent("UILabel"):set_text(tostring(props.PHY_CRT_DEF_LEVEL))
  prop9:GetComponent("UILabel"):set_text(tostring(props.MAG_CRT_LEVEL))
  prop10:GetComponent("UILabel"):set_text(tostring(props.MAG_CRT_DEF_LEVEL))
  prop11:GetComponent("UILabel"):set_text(tostring(props.SEAL_HIT))
  prop12:GetComponent("UILabel"):set_text(tostring(props.SEAL_RESIST))
end
def.method().UpdateSkills = function(self)
  local wingData = WingModule.Instance():GetWingData()
  local skills = wingData:GetSkills()
  local scroll = self.m_node:FindDirect("Group_Right/Group_Skill/Scroll View")
  local list = scroll:FindDirect("List_Skill")
  local uiNum = #skills <= BasicInfoNode.MAXSKILLNUM and BasicInfoNode.MAXSKILLNUM or math.ceil(#skills / 5) * 5
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(uiNum)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
    if not scroll.isnil then
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local skillId = skills[i]
    self:FillSkillIcon(uiGo, skillId and skillId or 0)
  end
  self.skills = skills
end
def.method("userdata", "number").FillSkillIcon = function(self, uiGo, skillId)
  local tex = uiGo:FindDirect("Texture")
  local skillCfg = skillId > 0 and SkillUtility.GetSkillCfg(skillId) or nil
  if skillCfg then
    tex:SetActive(true)
    local texCmp = tex:GetComponent("UITexture")
    GUIUtils.FillIcon(texCmp, skillCfg.iconId)
  else
    tex:SetActive(false)
  end
end
def.method().UpdateBasicInfo = function(self)
  local wingData = WingModule.Instance():GetWingData()
  local levelLabel = self.m_node:FindDirect("Group_Right/Group_Attribute/Label_Level")
  levelLabel:GetComponent("UILabel"):set_text(string.format(textRes.Wing[1], wingData:GetLevel()))
  local levelLabel = self.m_node:FindDirect("Group_Right/Group_Attribute/Labe_PinjieLevel")
  levelLabel:GetComponent("UILabel"):set_text(string.format(textRes.Wing[2], wingData:GetPhase()))
  local expSlider = self.m_node:FindDirect("Group_Right/Group_Attribute/Slider_Exp")
  local expLabel = self.m_node:FindDirect("Group_Right/Group_Attribute/Slider_Exp/Label_SX_SliderActive")
  local exp = wingData:GetExp()
  local fullExp = exp
  local levelCfg = WingUtils.GetUpgradeCfgByLevel(wingData:GetLevel())
  if levelCfg then
    fullExp = levelCfg.needExp
  end
  expSlider:GetComponent("UISlider"):set_sliderValue(exp / fullExp)
  expLabel:GetComponent("UILabel"):set_text(string.format("%d/%d", exp, fullExp))
  local curPhase = wingData:GetPhase()
  local maxPahse = WingUtils.GetMaxPhase()
  local list = self.m_node:FindDirect("Group_Right/Group_Attribute/List_PinJie")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(curPhase)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local spr = uiGo:GetComponent("UISprite")
    if i > curPhase then
      spr:set_spriteName("Img_Ling")
    else
      spr:set_spriteName("Img_Ling01")
    end
  end
  local levelBtn = self.m_node:FindDirect("Group_Right/Group_Attribute/Btn_Add")
  local phaseBtn = self.m_node:FindDirect("Group_Right/Group_Attribute/Btn_UpLevel")
  if levelCfg then
    local needPhase = levelCfg.needrank
    if curPhase < needPhase then
      levelBtn:SetActive(false)
      phaseBtn:SetActive(true)
    else
      levelBtn:SetActive(true)
      phaseBtn:SetActive(false)
    end
  else
    levelBtn:SetActive(false)
    phaseBtn:SetActive(false)
  end
  local nameLabel = self.m_node:FindDirect("Group_Left/Img_NameBg/Label")
  local name = textRes.Wing[3]
  local curWingId = wingData:GetCurWingId()
  local fakeItem = WingUtils.GetWingFakeItemByWingId(curWingId)
  if fakeItem then
    name = fakeItem.name
  end
  nameLabel:GetComponent("UILabel"):set_text(name)
  self:setCurOccName()
end
def.method().setCurOccName = function(self)
  local Group_Select = self.m_node:FindDirect("Group_Right/Group_Attribute/Group_Select")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_WING_OCC_PLAN) then
    Group_Select:SetActive(false)
    self.m_node:FindDirect("Group_Right/Group_Attribute/Btn_ChangerName"):SetActive(false)
    return
  end
  local wingData = WingModule.Instance():GetWingData()
  local Group_Btn = Group_Select:FindDirect("Group_Btn")
  local Label_Name = Group_Btn:FindDirect("Label_Name")
  local Img_ProvinceBg = Group_Btn:FindDirect("Img_ProvinceBg")
  Label_Name:GetComponent("UILabel"):set_text(wingData:GetOccNameById(wingData:GetCurOccupationId()))
  if WingInterface.HasWingNotify() then
    GUIUtils.SetLightEffect(Img_ProvinceBg, GUIUtils.Light.Square)
  else
    GUIUtils.SetLightEffect(Img_ProvinceBg, GUIUtils.Light.None)
  end
end
def.override("string").onClick = function(self, id)
  local strs = string.split(id, "_")
  if id == "Btn_Tip" then
    WingUtils.ShowQA(constant.WingConsts.WING_DESC_TIP_ID)
  elseif id == "Btn_UpLevel" then
    WingModule.Instance():TryPromote()
  elseif id == "Btn_Add" then
    WingModule.Instance():TryUpgrade()
  elseif string.sub(id, 1, 5) == "item_" then
    local index = tonumber(string.sub(id, 6))
    local selectSkill = self.skills[index]
    local cell = self.m_node:FindDirect("Group_Right/Group_Skill/Scroll View/List_Skill/" .. id)
    if cell and selectSkill then
      require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(selectSkill, cell, 0)
    end
  elseif id == "Group_Btn" then
    if not _G.CheckCrossServerAndToast() then
      self:setSelectListDisplay()
      self:clearRedPoint()
    end
  elseif strs[1] == "Btn" and strs[2] == "Item" then
    local idx = tonumber(strs[3])
    if idx then
      local info = self.occPlans[idx]
      local p = require("netio.protocol.mzm.gsp.wing.CChangeOccWingPlanReq").new(info.occId)
      gmodule.network.sendProtocol(p)
      self:setSelectListDisplay()
    end
  elseif id == "Btn_ChangerName" then
    if not _G.CheckCrossServerAndToast() then
      local wingData = WingModule.Instance():GetWingData()
      local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
      local curName = wingData:GetOccNameById(wingData:GetCurOccupationId())
      local content = string.format(textRes.Wing[52], curName)
      CommonRenamePanel:ShowPanel(content, true, BasicInfoNode.RenamePanelCallback, self)
    end
  else
    self:hideSelectList()
  end
end
def.static("string", "table", "=>", "boolean").RenamePanelCallback = function(name, self)
  if not self:ValidEnteredName(name) then
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name) then
    Toast(textRes.Pet[18])
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name, "Name") then
    Toast(textRes.Pet[44])
    return true
  elseif name == "" then
    Toast(textRes.Pet[17])
    return true
  else
    warn("rename is:", name)
    local Octets = require("netio.Octets")
    local nameOctet = Octets.rawFromString(name)
    local wingData = WingModule.Instance():GetWingData()
    local p = require("netio.protocol.mzm.gsp.wing.CRenameOccupationPlanNameReq").new(wingData:GetCurOccupationId(), nameOctet)
    gmodule.network.sendProtocol(p)
    return false
  end
end
def.method("string", "=>", "boolean").ValidEnteredName = function(self, enteredName)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Login[15])
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Login[14])
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Pet[46])
    end
    return false
  end
end
def.override("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true then
    self.modelAndWing:SetDir(self.modelAndWing:GetDir() - dx / 2)
  end
end
def.method().setSelectListDisplay = function(self)
  local Group_Select = self.m_node:FindDirect("Group_Right/Group_Attribute/Group_Select")
  local Group_ChooseType = Group_Select:FindDirect("Group_ChooseType")
  local Group_Btn = Group_Select:FindDirect("Group_Btn")
  local toggleEx = Group_Btn:GetComponent("UIToggleEx")
  if Group_ChooseType.activeSelf then
    Group_ChooseType:SetActive(false)
    toggleEx.value = false
  else
    Group_ChooseType:SetActive(true)
    self:setWingSelectList()
    toggleEx.value = true
  end
end
def.method().InitSelectList = function(self)
  self:hideSelectList()
end
def.method().hideSelectList = function(self)
  local Group_Select = self.m_node:FindDirect("Group_Right/Group_Attribute/Group_Select")
  local Group_ChooseType = Group_Select:FindDirect("Group_ChooseType")
  local Group_Btn = Group_Select:FindDirect("Group_Btn")
  Group_Btn:GetComponent("UIToggleEx").value = false
  Group_ChooseType:SetActive(false)
end
def.method().setWingSelectList = function(self)
  local Group_Select = self.m_node:FindDirect("Group_Right/Group_Attribute/Group_Select")
  local List_Item = Group_Select:FindDirect("Group_ChooseType/Img_Bg2/Scroll View/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  local wingData = WingModule.Instance():GetWingData()
  local occInfoList = wingData:GetCurOccPlanNameList()
  self.occPlans = occInfoList
  uiList.itemCount = #occInfoList
  uiList:Resize()
  for i, v in ipairs(occInfoList) do
    local item = List_Item:FindDirect("Item_" .. i)
    local Label_Name2 = item:FindDirect(string.format("Btn_Item_%d/Label_Name2_%d", i, i))
    Label_Name2:GetComponent("UILabel"):set_text(v.name)
  end
end
BasicInfoNode.Commit()
return BasicInfoNode
