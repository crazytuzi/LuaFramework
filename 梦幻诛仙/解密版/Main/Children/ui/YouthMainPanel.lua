local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local YouthMainPanel = Lplus.Extend(ECPanelBase, "YouthMainPanel")
local Child = require("Main.Children.Child")
local GUIUtils = require("GUI.GUIUtils")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local QualityType = require("consts.mzm.gsp.children.confbean.QualityType")
local SkillUtility = require("Main.Skill.SkillUtility")
local ChildrenOperation = require("Main.Children.ui.ChildrenOperation")
local PetEquipType = require("consts.mzm.gsp.petequip.confbean.PetEquipType")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local Vector = require("Types.Vector3")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local MathHelper = require("Common.MathHelper")
local def = YouthMainPanel.define
local instance
def.field("table").childData = nil
def.field(Child).child = nil
def.field("boolean").isDrag = false
def.field("table").groups = nil
def.field(ChildrenOperation).childOpe = nil
def.const("table").EquipPos = {
  WEAPON = 1,
  CLOTH = 2,
  SHOES = 3,
  AMULET = 4
}
def.static("=>", YouthMainPanel).Instance = function()
  if instance == nil then
    instance = YouthMainPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.override().OnCreate = function(self)
  self.groups = {}
  local rightPanel = self.m_panel:FindDirect("Img_Bg0/Group_Right_ZhangCheng")
  self.groups.left = self.m_panel:FindDirect("Img_Bg0/Group_Left")
  self.groups.toggle = rightPanel:FindDirect("Group_Toggle")
  self.groups.base = rightPanel:FindDirect("Group_Base")
  self.groups.props = rightPanel:FindDirect("Group_Grow")
  self.groups.skill = rightPanel:FindDirect("Group_Skill")
  self.groups.menu = self.groups.left:FindDirect("Group_Menu")
  self.groups.equip = self.groups.base:FindDirect("Group_Equip")
  self.childOpe = ChildrenOperation.CreateNew(self.groups.menu:FindDirect("Group_ChooseType"), self.childData.id)
  self.groups.menu:SetActive(self.groups.toggle:FindDirect("Toggle_Base"):GetComponent("UIToggle").isChecked)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPDATE_CHARACTER, YouthMainPanel.OnCharacterChanged)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, YouthMainPanel.OnNameChange)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, YouthMainPanel.OnChildrenFashionChange)
end
def.override().OnDestroy = function(self)
  if self.child then
    self.child:Destroy()
  end
  self.isDrag = false
  self.childData = nil
  self.childOpe:Destroy()
  self.childOpe = nil
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPDATE_CHARACTER, YouthMainPanel.OnCharacterChanged)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, YouthMainPanel.OnNameChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, YouthMainPanel.OnChildrenFashionChange)
end
def.method("userdata").ShowDlg = function(self, childId)
  if self.m_panel ~= nil then
    return
  end
  self.childData = ChildrenDataMgr.Instance():GetChildById(childId)
  if self.childData == nil then
    Debug.LogWarning(string.format("child data not found for id: %s", tostring(childId)))
    return
  end
  self:CreatePanel(RESPATH.PREFAB_CHILDREN_YOUTH, 1)
  self:SetModal(true)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, show)
  if not show then
    if self.child then
      self.child:Destroy()
    end
    self.isDrag = false
    return
  end
  self:ShowLeftInfo()
  self:ShowRightInfo()
end
def.method("string").onClick = function(self, id)
  if id == "Toggle_Base" or id == "Toggle_Grow" or id == "Toggle_Skill" then
    self:ShowRightInfo()
  elseif string.find(id, "Img_ItemSkill") then
    local idx = tonumber(string.sub(id, #"Img_ItemSkill" + 1, -1))
    self:ShowCommonSkillTip(idx)
  elseif string.find(id, "Img_CampSkill") then
    local idx = tonumber(string.sub(id, #"Img_CampSkill" + 1, -1))
    self:ShowMenpaiSkillTip(idx)
  elseif id == "Btn_Stratagy" then
    require("Main.Children.ui.DlgJoinMenpai").Instance():ShowPanel(self.childData.id)
  elseif id == "Btn_Close" then
    self:Hide()
  elseif id == "Img_ChildSkill" then
    self:ShowSpecialSkillTip()
  elseif string.find(id, "Img_CW_BgEquip") then
    local idx = tonumber(string.sub(id, #"Img_CW_BgEquip" + 1, -1))
    self:OnChildEquipmentClick(idx)
  elseif id == "Btn_Help" then
    local CommonDescDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701605024)
    CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
  elseif self.childOpe then
    self.childOpe:onClick(id)
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if id == "Img_Bg" and self.childOpe then
    if active then
      self.childOpe:Show(nil)
    else
      self.childOpe:Hide()
    end
  end
end
def.method().ShowLeftInfo = function(self)
  if self.groups == nil or self.childData == nil then
    return
  end
  self.groups.left:FindDirect("Label_Name/Label_Num"):GetComponent("UILabel").text = self.childData.info.level
  local uiModel = self.groups.left:FindDirect("Model_Baby"):GetComponent("UIModel")
  local fashion = self.childData:GetFashionByPhase(self.childData:GetStatus())
  self.child = Child.CreateWithFashionAndWeapon(self.childData:GetModelCfgId(), fashion and fashion.fashionId or 0, self.childData:GetWeaponId())
  self.child:LoadUIModel(nil, function()
    if self.m_panel == nil or self.m_panel.isnil then
      self.child:Destroy()
      self.child = nil
      return
    end
    if self.child == nil or self.child.model == nil or self.child.model.m_model == nil or self.child.model.m_model.isnil or uiModel == nil or uiModel.isnil then
      return
    end
    uiModel.modelGameObject = self.child.model.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
  self.groups.menu:FindDirect("Img_Bg/Label_Current"):GetComponent("UILabel").text = self.childData.name
  local menpaiIcon = self.groups.left:FindDirect("Img_Camp")
  menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(self.childData.info.occupation)
  self:UpdateCharacter()
  local characterCfgs = ChildrenUtils.GetChildrenCharacterCfg()
  table.sort(characterCfgs, function(a, b)
    if a == nil then
      return true
    elseif b == nil then
      return false
    else
      return a.min < b.min
    end
  end)
  local char_slider = self.groups.left:FindDirect("Slider_Character")
  local maxpos = char_slider:GetComponent("UIWidget").width
  local curCharacter
  for i = 1, #characterCfgs - 1 do
    local tag = char_slider:FindDirect("Group_Points/Img_Point0" .. i)
    local cfg = characterCfgs[i + 1]
    if self.childData.info.character >= cfg.min then
      curCharacter = cfg.name
    end
    if tag then
      tag:FindDirect("Label_Name"):GetComponent("UILabel").text = cfg.name
      local rate = cfg.min / constant.CChildrenConsts.child_grow_character_max
      tag.localPosition = Vector.Vector3.new(maxpos * rate, 0, 0)
    end
  end
  self.groups.left:FindDirect("Label_Character/Label_Name"):GetComponent("UILabel").text = curCharacter or characterCfgs[1].name
  ChildrenUtils.SetYouthChildScore(self.m_panel:FindDirect("Img_Bg0/Group_Score"), self.childData:CalYouthChildScore())
  local Img_Tpye = self.groups.left:FindDirect("Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(constant.CChildrenConsts.cardClassType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.static("table", "table").OnNameChange = function(p1, p2)
  if instance.groups == nil or instance.childData == nil then
    return
  end
  instance.groups.menu:FindDirect("Img_Bg/Label_Current"):GetComponent("UILabel").text = instance.childData.name
end
def.static("table", "table").OnChildrenFashionChange = function(p1, p2)
  if instance.groups == nil or instance.childData == nil then
    return
  end
  if instance.child then
    local fashion_data = instance.childData:GetFashionByPhase(instance.childData.status)
    instance.child:SetCostume(fashion_data and fashion_data.fashionId or 0)
  end
end
def.static("table", "table").OnCharacterChanged = function(p1, p2)
  instance:UpdateCharacter()
end
def.method().UpdateCharacter = function(self)
  if self.childData == nil or self.groups == nil then
    return
  end
  local char_slider = self.groups.left:FindDirect("Slider_Character")
  char_slider:GetComponent("UISlider").value = self.childData.info.character / constant.CChildrenConsts.child_grow_character_max
  char_slider:FindDirect("Label_Slider"):GetComponent("UILabel").text = string.format("%d/%d", self.childData.info.character, constant.CChildrenConsts.child_grow_character_max)
end
def.method().ShowRightInfo = function(self)
  if self.groups.toggle:FindDirect("Toggle_Base"):GetComponent("UIToggle").isChecked then
    self:ShowBasicInfo()
  elseif self.groups.toggle:FindDirect("Toggle_Grow"):GetComponent("UIToggle").isChecked then
    self:ShowPropInfo()
  elseif self.groups.toggle:FindDirect("Toggle_Skill"):GetComponent("UIToggle").isChecked then
    self:ShowSkillInfo()
  end
end
def.method().ShowBasicInfo = function(self)
  if self.groups == nil or self.childData == nil then
    return
  end
  local info = self.childData.info
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local hp_slider = self.groups.base:FindDirect("Group_State/Slider_QiXue")
  hp_slider:FindDirect("Label_Slider"):GetComponent("UILabel").text = string.format("%d/%d", info.propMap[PropertyType.CUR_HP] or 1, info.propMap[PropertyType.MAX_HP] or 1)
  hp_slider:GetComponent("UISlider").value = (info.propMap[PropertyType.CUR_HP] or 1) / (info.propMap[PropertyType.MAX_HP] or 1)
  local mp_slider = self.groups.base:FindDirect("Group_State/Slider_FaLi")
  mp_slider:FindDirect("Label_Slider"):GetComponent("UILabel").text = string.format("%d/%d", info.propMap[PropertyType.CUR_MP] or 1, info.propMap[PropertyType.MAX_MP] or 1)
  mp_slider:GetComponent("UISlider").value = (info.propMap[PropertyType.CUR_MP] or 1) / (info.propMap[PropertyType.MAX_MP] or 1)
  local attrPanel = self.groups.base:FindDirect("Group_Attr")
  attrPanel:FindDirect("Label_WuGong/Label_Num"):GetComponent("UILabel").text = info.propMap[PropertyType.PHYATK]
  attrPanel:FindDirect("Label_FaGong/Label_Num"):GetComponent("UILabel").text = info.propMap[PropertyType.MAGATK]
  attrPanel:FindDirect("Label_WuFang/Label_Num"):GetComponent("UILabel").text = info.propMap[PropertyType.PHYDEF]
  attrPanel:FindDirect("Label_FaFang/Label_Num"):GetComponent("UILabel").text = info.propMap[PropertyType.MAGDEF]
  attrPanel:FindDirect("Label_SuDu/Label_Num"):GetComponent("UILabel").text = info.propMap[PropertyType.SPEED]
  local panel_weapon = self.groups.equip:FindDirect("Img_CW_BgEquip01")
  local weapon_texture = panel_weapon:FindDirect("Img_CW_IconEquip01"):GetComponent("UITexture")
  local ItemUtils = require("Main.Item.ItemUtils")
  for _, pos in pairs(YouthMainPanel.EquipPos) do
    local panel = self.groups.equip:FindDirect("Img_CW_BgEquip0" .. pos)
    local texture = panel:FindDirect("Img_CW_IconEquip0" .. pos)
    local equip
    if pos < YouthMainPanel.EquipPos.AMULET then
      equip = self.childData.info.equipItem[pos]
    else
      equip = self.childData.info.equipPetItem[PetEquipType.AMULET]
    end
    if equip then
      local itemBase = ItemUtils.GetItemBase(equip.id)
      GUIUtils.SetTexture(texture, itemBase.icon)
      panel:FindDirect("Img_CW_Empty"):SetActive(false)
    else
      GUIUtils.SetTexture(texture, 0)
      panel:FindDirect("Img_CW_Empty"):SetActive(true)
    end
  end
end
def.method().ShowPropInfo = function(self)
  if self.groups == nil or self.childData == nil then
    return
  end
  local info = self.childData.info
  local hp_slider = self.groups.props:FindDirect("Group_State/Slider_QiXue")
  hp_slider:FindDirect("Label_QiXue_Slider"):GetComponent("UILabel").text = string.format("%d/%d", info.aptitudeInitMap[QualityType.HP_APT], constant.CChildrenConsts.child_hp_aptitude_max)
  hp_slider:GetComponent("UISlider").value = info.aptitudeInitMap[QualityType.HP_APT] / constant.CChildrenConsts.child_hp_aptitude_max
  local wg_slider = self.groups.props:FindDirect("Group_State/Slider_WuGong")
  wg_slider:FindDirect("Label_WuGong_Slider"):GetComponent("UILabel").text = string.format("%d/%d", info.aptitudeInitMap[QualityType.PHYATK_APT], constant.CChildrenConsts.child_phy_atk_aptitude_max)
  wg_slider:GetComponent("UISlider").value = info.aptitudeInitMap[QualityType.PHYATK_APT] / constant.CChildrenConsts.child_phy_atk_aptitude_max
  local fg_slider = self.groups.props:FindDirect("Group_State/Slider_FaGong")
  fg_slider:FindDirect("Label_FaGong_Slider"):GetComponent("UILabel").text = string.format("%d/%d", info.aptitudeInitMap[QualityType.MAGATK_APT], constant.CChildrenConsts.child_mag_atk_aptitude_max)
  fg_slider:GetComponent("UISlider").value = info.aptitudeInitMap[QualityType.MAGATK_APT] / constant.CChildrenConsts.child_mag_atk_aptitude_max
  local wf_slider = self.groups.props:FindDirect("Group_State/Slider_WuFang")
  wf_slider:FindDirect("Label_WuFang_Slider"):GetComponent("UILabel").text = string.format("%d/%d", info.aptitudeInitMap[QualityType.PHYDEF_APT], constant.CChildrenConsts.child_phy_def_aptitude_max)
  wf_slider:GetComponent("UISlider").value = info.aptitudeInitMap[QualityType.PHYDEF_APT] / constant.CChildrenConsts.child_phy_def_aptitude_max
  local ff_slider = self.groups.props:FindDirect("Group_State/Slider_FaFang")
  ff_slider:FindDirect("Label_FaFang_Slider"):GetComponent("UILabel").text = string.format("%d/%d", info.aptitudeInitMap[QualityType.MAGDEF_APT], constant.CChildrenConsts.child_mag_def_aptitude_max)
  ff_slider:GetComponent("UISlider").value = info.aptitudeInitMap[QualityType.MAGDEF_APT] / constant.CChildrenConsts.child_mag_def_aptitude_max
  local sd_slider = self.groups.props:FindDirect("Group_State/Slider_SuDu")
  sd_slider:FindDirect("Label_SuDu_Slider"):GetComponent("UILabel").text = string.format("%d/%d", info.aptitudeInitMap[QualityType.SPEED_APT], constant.CChildrenConsts.child_speed_aptitude_max)
  sd_slider:GetComponent("UISlider").value = info.aptitudeInitMap[QualityType.SPEED_APT] / constant.CChildrenConsts.child_speed_aptitude_max
  self.groups.props:FindDirect("Group_Grow/Label_Num"):GetComponent("UILabel").text = MathHelper.Round(info.grow * 1000) / 1000
end
def.method().ShowSkillInfo = function(self)
  if self.m_panel == nil then
    return
  end
  local menpaiSkillPanel = self.groups.skill:FindDirect("Group_CampSkill")
  local menpaiSkill1 = menpaiSkillPanel:FindDirect("Img_CampSkill01/Icon_ItemSkillIcon")
  local menpaiSkill2 = menpaiSkillPanel:FindDirect("Img_CampSkill02/Icon_ItemSkillIcon")
  local mempaiSkillIds = {}
  local menpai_skills = ChildrenUtils.GetMenpaiSkills(self.childData:GetMenpai())
  local menpai_skillid1 = menpai_skills[1] and menpai_skills[1].skillid or 0
  local menpai_skillid2 = menpai_skills[2] and menpai_skills[2].skillid or 0
  self:SetSkillIcon(menpaiSkill1, menpai_skillid1)
  self:SetSkillIcon(menpaiSkill2, menpai_skillid2)
  menpaiSkillPanel:FindDirect("Img_CampSkill01/Img_FightSign"):SetActive(self.childData:IsFightSkill(menpai_skillid1))
  menpaiSkillPanel:FindDirect("Img_CampSkill02/Img_FightSign"):SetActive(self.childData:IsFightSkill(menpai_skillid2))
  local specialSkillPanel = self.groups.skill:FindDirect("Group_ChildSkill/Img_ChildSkill/Icon_ItemSkillIcon")
  self:SetSkillIcon(specialSkillPanel, self.childData.info.specialSkillid)
  local bookSkillPanel = self.groups.skill:FindDirect("Group_SkillView/Group_Skill/Scroll View_Skill/Grid_Skill")
  local amuletSkillIdx = 1
  local amuletSkills = self:GetAmuletSkills()
  for i = 1, 12 do
    local panel_name = string.format("Img_ItemSkill%02d/Icon_ItemSkillIcon", i)
    local skillPanel = bookSkillPanel:FindDirect(panel_name)
    local skillId = self.childData.info.skillBookSkills[i]
    local isAmulet = false
    if skillId == nil or skillId == 0 then
      skillId = amuletSkills and amuletSkills[amuletSkillIdx]
      amuletSkillIdx = amuletSkillIdx + 1
      isAmulet = skillId ~= nil and skillId > 0
    end
    bookSkillPanel:FindDirect(string.format("Img_ItemSkill%02d/Img_AmuletSign", i)):SetActive(isAmulet)
    if skillId and skillId > 0 then
      self:SetSkillIcon(skillPanel, skillId)
    else
      self:SetSkillIcon(skillPanel, 0)
    end
  end
end
def.method("userdata", "number").SetSkillIcon = function(self, panel, skillId)
  local ui_Texture = panel:GetComponent("UITexture")
  if skillId > 0 then
    local skillInfo = SkillUtility.GetSkillCfg(skillId)
    GUIUtils.FillIcon(ui_Texture, skillInfo.iconId)
  else
    GUIUtils.FillIcon(ui_Texture, 0)
  end
end
def.method("number").ShowCommonSkillTip = function(self, index)
  local amuletSkills = self:GetAmuletSkills()
  local skillId = self.childData.info.skillBookSkills[index]
  if skillId == nil and amuletSkills then
    skillId = amuletSkills[index - #self.childData.info.skillBookSkills]
  end
  if skillId == nil then
    return
  end
  local bookSkillPanel = self.groups.skill:FindDirect("Group_SkillView/Group_Skill/Scroll View_Skill/Grid_Skill")
  local sourceObj = bookSkillPanel:FindDirect(string.format("Img_ItemSkill%02d", index))
  local context = {
    skill = {id = skillId, isOwnSkill = true},
    needRemember = true
  }
  require("Main.Pet.PetUtility").ShowPetSkillTipEx(skillId, 1, sourceObj, 0, context)
end
def.method("number").ShowMenpaiSkillTip = function(self, index)
  local CommonSkillTip = require("GUI.CommonSkillTip")
  local sourceObj = self.groups.skill:FindDirect(string.format("Group_CampSkill/Img_CampSkill%02d", index))
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local menpai_skills = ChildrenUtils.GetMenpaiSkills(self.childData:GetMenpai())
  local skill_data = menpai_skills[index]
  if skill_data then
    require("Main.Skill.SkillTipMgr").Instance():ShowTipById(skill_data.skillid, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1)
  end
end
def.method().ShowSpecialSkillTip = function(self)
  local CommonSkillTip = require("GUI.CommonSkillTip")
  local sourceObj = self.groups.skill:FindDirect("Group_ChildSkill/Img_ChildSkill/Icon_ItemSkillIcon")
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local skill_id = self.childData.info.specialSkillid
  if skill_id and skill_id > 0 then
    require("Main.Skill.SkillTipMgr").Instance():ShowTipById(skill_id, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1)
  end
end
def.method("number").OnChildEquipmentClick = function(self, index)
  if self.childData == nil then
    return
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local ItemModule = require("Main.Item.ItemModule")
  if index == YouthMainPanel.EquipPos.AMULET then
    local itemInfo = self.childData.info.equipPetItem[PetEquipType.AMULET]
    local PetData = require("Main.Pet.data.PetData")
    local slot = PetData.PetEquipmentType.EQUIP_AMULET
    if itemInfo then
      local sourceObj = self.groups.equip:FindDirect("Img_CW_BgEquip0" .. index)
      local tip = ItemTipsMgr.Instance():ShowTipsEx(itemInfo, ItemModule.EQUIPBAG, 1, ItemTipsMgr.Source.ChildrenPanel, sourceObj, -1)
      tip:SetOperateContext({slot = slot})
    end
  else
    local itemInfo = self.childData.info.equipItem[index]
    if itemInfo == nil then
      return
    end
    local sourceObj = self.groups.equip:FindDirect("Img_CW_BgEquip0" .. index)
    local tip = ItemTipsMgr.Instance():ShowTipsEx(itemInfo, ItemModule.EQUIPBAG, 1, ItemTipsMgr.Source.ChildrenPanel, sourceObj, -1)
    tip:SetOperateContext({slot = index})
  end
end
def.method("=>", "table").GetAmuletSkills = function(self)
  if self.childData == nil or self.childData.info == nil then
    return nil
  end
  local amuletInfo = self.childData.info.equipPetItem[PetEquipType.AMULET]
  if amuletInfo == nil then
    return nil
  end
  local amuletSkills = {}
  amuletSkills[1] = amuletInfo.extraMap[ItemXStoreType.PET_EQUIP_SKILL_ID_1]
  amuletSkills[2] = amuletInfo.extraMap[ItemXStoreType.PET_EQUIP_SKILL_ID_2]
  return amuletSkills
end
def.method("string").onDragStart = function(self, id)
  if id == "Model_Baby" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self.child and self.child.model and self.child.model.m_model then
    self.child.model:SetDir(self.child.model:GetDir() - dx / 2)
  end
end
YouthMainPanel.Commit()
return YouthMainPanel
