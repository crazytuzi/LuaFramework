local Lplus = require("Lplus")
local SubPanel = require("Main.Children.ui.SubPanel")
local YouthSubPanel = Lplus.Extend(SubPanel, "YouthSubPanel")
local Child = require("Main.Children.Child")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local ChildrenOperation = require("Main.Children.ui.ChildrenOperation")
local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
local QualityType = require("consts.mzm.gsp.children.confbean.QualityType")
local GUIUtils = require("GUI.GUIUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local ItemUtils = require("Main.Item.ItemUtils")
local ChildEuqipPos = require("consts.mzm.gsp.item.confbean.ChildEuqipPos")
local PetData = require("Main.Pet.data.PetData")
local PetEquipType = require("consts.mzm.gsp.petequip.confbean.PetEquipType")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector3")
local MathHelper = require("Common.MathHelper")
local def = YouthSubPanel.define
local instance
def.field("table").childData = nil
def.field("boolean").isDrag = false
def.field(ChildrenOperation).childOpe = nil
def.field("table").groups = nil
def.field(Child).child = nil
def.field("table").unlockCfgs = nil
def.field("boolean").isViewOnly = false
def.const("table").EquipPos = {
  WEAPON = 1,
  CLOTH = 2,
  SHOES = 3,
  AMULET = 4
}
def.const("table").EquipPosToType = {
  ChildEuqipPos.WEAPON,
  ChildEuqipPos.CLOTHES,
  ChildEuqipPos.SHOES,
  PetEquipType.AMULET
}
def.method().SetViewOnlyMode = function(self)
  self.isViewOnly = true
end
def.override().Hide = function(self)
  if self.m_node and not self.m_node.isnil then
    self.m_node:SetActive(false)
    self:Clear()
  end
end
def.override("table").Show = function(self, data)
  instance = self
  if self.child then
    self.child:Destroy()
    self.child = nil
  end
  if self.m_node == nil or self.m_node.isnil then
    return
  end
  self.m_node:SetActive(true)
  self.groups = {}
  self.groups.toggle = self.m_node:FindDirect("Group_Toggle")
  self.groups.base = self.m_node:FindDirect("Group_Base")
  self.groups.props = self.m_node:FindDirect("Group_Grow")
  self.groups.skill = self.m_node:FindDirect("Group_Skill")
  self.groups.menu = self.m_node:FindDirect("Group_Menu")
  self.groups.menu:FindDirect("Img_Bg"):GetComponent("UIToggleEx").value = false
  self.groups.equip = self.groups.props:FindDirect("Group_Equip")
  self.childData = data
  self:ShowRightInfo()
  if self.isViewOnly then
    return
  end
  self.childOpe = ChildrenOperation.CreateNew(self.m_node:FindDirect("Group_Menu/Group_ChooseType"), data.id)
  self.groups.menu:SetActive(self.groups.toggle:FindDirect("Toggle_Base"):GetComponent("UIToggle").isChecked)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_SPECIAL_SKILL_BOOK, YouthSubPanel.OnUseSpeicalSkillBook)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_GROWTH_ITEM, YouthSubPanel.OnUseGrowthItem)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_CHARACTER_ITEM, YouthSubPanel.OnUseCharacterItem)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPDATE_CHARACTER, YouthSubPanel.OnCharacterChanged)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Growth_Updated, YouthSubPanel.OnGrowthUpdated)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Quality_Updated, YouthSubPanel.OnQualityUpdated)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.SKILL_UNLOCKED, YouthSubPanel.OnSkillUnlocked)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.SKILL_CHANGED, YouthSubPanel.OnSpecialSkillUpdated)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, YouthSubPanel.OnNameChange)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, YouthSubPanel.OnChildrenFashionChange)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPGRADE_CHILD_EQUIP, YouthSubPanel.OnUpgradeEquip)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.RANDOM_CHILD_EQUIP, YouthSubPanel.OnRandomEquip)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_PET_EQUIP, YouthSubPanel.OnUsePetEquip)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPDATE_PET_EQUIP, YouthSubPanel.OnUpdatePetEquip)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.MENPAI_CHANGED, YouthSubPanel.OnMenpaiChanged)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_PROP_UPDATED, YouthSubPanel.OnPropChanged)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.AMULET_SKILL_CHANGED, YouthSubPanel.OnAmuletSkillChanged)
end
def.method().Clear = function(self)
  if self.child then
    self.child:Destroy()
    self.child = nil
  end
  if self.childOpe then
    self.childOpe:Destroy()
    self.childOpe = nil
  end
  self.isDrag = false
end
def.override().Destroy = function(self)
  self:Clear()
  self.groups = nil
  instance = nil
  if self.isViewOnly then
    return
  end
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_SPECIAL_SKILL_BOOK, YouthSubPanel.OnUseSpeicalSkillBook)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_GROWTH_ITEM, YouthSubPanel.OnUseGrowthItem)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_CHARACTER_ITEM, YouthSubPanel.OnUseCharacterItem)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPDATE_CHARACTER, YouthSubPanel.OnCharacterChanged)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Growth_Updated, YouthSubPanel.OnGrowthUpdated)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Quality_Updated, YouthSubPanel.OnQualityUpdated)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.SKILL_UNLOCKED, YouthSubPanel.OnSkillUnlocked)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.SKILL_CHANGED, YouthSubPanel.OnSpecialSkillUpdated)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, YouthSubPanel.OnNameChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, YouthSubPanel.OnChildrenFashionChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPGRADE_CHILD_EQUIP, YouthSubPanel.OnUpgradeEquip)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.RANDOM_CHILD_EQUIP, YouthSubPanel.OnRandomEquip)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_PET_EQUIP, YouthSubPanel.OnUsePetEquip)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPDATE_PET_EQUIP, YouthSubPanel.OnUpdatePetEquip)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.MENPAI_CHANGED, YouthSubPanel.OnMenpaiChanged)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_PROP_UPDATED, YouthSubPanel.OnPropChanged)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.AMULET_SKILL_CHANGED, YouthSubPanel.OnAmuletSkillChanged)
end
def.override("string", "=>", "boolean").onClick = function(self, id)
  if self:IsShow() then
    if id == "Btn_LaernSkill" then
      if self:CheckEnable() then
        require("Main.Children.ui.DlgUpdateSkill").Instance():ShowPanel(self.childData.id)
      end
    elseif id == "Btn_ChangeCamp" then
      if self.isViewOnly then
        return false
      end
      if _G.CheckCrossServerAndToast() then
        return false
      end
      if not self.childData:IsMine() then
        Toast(textRes.Children[3043])
        return false
      end
      require("Main.Children.ui.DlgJoinMenpai").Instance():ShowPanel(self.childData.id)
    elseif id == "Btn_AddPoints" then
      if self:CheckEnable() then
        self:AddPoint()
      end
    elseif id == "Btn_ChildSkill" or id == "Btn_ChangeSkill" then
      if self:CheckEnable() then
        self:LearSpecialSkill()
      end
    elseif id == "Btn_AddGrow" then
      if self:CheckEnable() then
        self:OnAddGrowClicked()
      end
    elseif id == "Btn_LearnCampSkill" then
      if self:CheckEnable() then
        self:ChangeMenpaiSkill()
      end
    elseif id == "Btn_Train" then
      if self:CheckEnable() then
        require("Main.Children.ui.DlgChildPropTraining").Instance():ShowPanel(self.childData.id)
      end
    elseif id == "Toggle_Base" or id == "Toggle_Grow" or id == "Toggle_Skill" then
      self:ShowRightInfo()
    elseif string.find(id, "Img_ItemSkill") then
      local idx = tonumber(string.sub(id, #"Img_ItemSkill" + 1, -1))
      self:OnClickSkill(idx)
    elseif string.find(id, "Img_CampSkill") then
      local idx = tonumber(string.sub(id, #"Img_CampSkill" + 1, -1))
      self:ShowMenpaiSkillTip(idx)
    elseif string.find(id, "Img_CW_BgEquip") then
      local idx = tonumber(string.sub(id, #"Img_CW_BgEquip" + 1, -1))
      self:OnChildEquipmentClick(idx)
    elseif id == "Btn_Add" then
      if self:CheckEnable() then
        self:OnAddCharacterClicked()
      end
    elseif id == "Btn_BaseHelp" then
      local CommonDescDlg = require("GUI.CommonUITipsDlg")
      local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701605024)
      CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
    elseif id == "Img_ChildSkill" then
      self:ShowSpecialSkillTip()
    elseif self.childOpe and self.childOpe:onClick(id) then
      return true
    end
    return false
  else
    return false
  end
end
def.static("table", "table").OnUseSpeicalSkillBook = function(p1, p2)
  local itemKey = p1 and p1[1]
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Children.CStudySpecialSkillReq").new(instance.childData.id, itemKey))
end
def.static("table", "table").OnUseGrowthItem = function(p1, p2)
  local itemKey = p1 and p1[1]
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Children.CUseChildrenGrowthItemReq").new(instance.childData.id, itemKey))
end
def.static("table", "table").OnUseCharacterItem = function(p1, p2)
  local itemKey = p1 and p1[1]
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Children.CUseChildrenCharaterItemReq").new(instance.childData.id, itemKey))
end
def.static("table", "table").OnUsePetEquip = function(p1, p2)
  if not instance:CheckEnable() then
    return
  end
  local itemKey = p1 and p1[2]
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
  local itemBase = ItemUtils.GetItemBase(item.id)
  CommonConfirmDlg.ShowConfirm(textRes.Common[8], string.format(textRes.Pet[36], "FFFF00", itemBase.name, "00FF00", instance.childData.name), function(id, tag)
    if id == 1 then
      local pro = require("netio.protocol.mzm.gsp.Children.CChildrenWearPetEquipReq").new(instance.childData.id, itemKey)
      gmodule.network.sendProtocol(pro)
    end
  end, nil)
end
def.static("table", "table").OnUpdatePetEquip = function(p1, p2)
  instance:ShowPropInfo()
end
def.static("table", "table").OnMenpaiChanged = function(p1, p2)
  instance:ShowMenpaiSkillInfo()
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
def.static("table", "table").OnPropChanged = function(p1, p2)
  instance:SetChildPropValue()
end
def.static("table", "table").OnAmuletSkillChanged = function(p1, p2)
  instance:ShowSkillInfo()
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
  if self.childData == nil or self.groups == nil then
    return
  end
  local info = self.childData.info
  if info == nil then
    return
  end
  self.groups.base:FindDirect("Label_Name/Label_Num"):GetComponent("UILabel").text = self.childData.info.level
  self.groups.menu:FindDirect("Img_Bg/Label_Current"):GetComponent("UILabel").text = self.childData.name
  local menpaiIcon = self.groups.base:FindDirect("Img_Camp")
  menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(self.childData:GetMenpai())
  self:SetChildPropValue()
  self.groups.menu:SetActive(true)
  local modelPanel = self.groups.base:FindDirect("Model_Baby")
  self:ShowChildModel(modelPanel)
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
  local char_slider = self.groups.base:FindDirect("Slider_Character")
  local maxpos = char_slider:GetComponent("UIWidget").width
  for i = 1, 3 do
    local tag = char_slider:FindDirect("Group_Points/Img_Point0" .. i)
    local cfg = characterCfgs[i + 1]
    tag:FindDirect("Label_Name"):GetComponent("UILabel").text = cfg.name
    local rate = cfg.min / constant.CChildrenConsts.child_grow_character_max
    tag.localPosition = Vector.Vector3.new(maxpos * rate, 0, 0)
  end
  ChildrenUtils.SetYouthChildScore(self.groups.base:FindDirect("Group_Score"), self.childData:CalYouthChildScore())
  local Img_Tpye = self.groups.base:FindDirect("Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(constant.CChildrenConsts.cardClassType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.method().SetChildPropValue = function(self)
  if self.childData == nil or self.groups == nil then
    return
  end
  local info = self.childData.info
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
end
def.static("table", "table").OnCharacterChanged = function(p1, p2)
  instance:UpdateCharacter()
end
def.method().UpdateCharacter = function(self)
  if self.childData == nil or self.groups == nil then
    return
  end
  local char_slider = self.groups.base:FindDirect("Slider_Character")
  char_slider:GetComponent("UISlider").value = self.childData.info.character / constant.CChildrenConsts.child_grow_character_max
  char_slider:FindDirect("Label_Slider"):GetComponent("UILabel").text = string.format("%d/%d", self.childData.info.character, constant.CChildrenConsts.child_grow_character_max)
end
def.static("table", "table").OnQualityUpdated = function(p1, p2)
  instance:ShowPropInfo()
end
def.method().ShowPropInfo = function(self)
  if self.childData == nil or self.groups == nil then
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
  self.groups.menu:SetActive(false)
  local panel_weapon = self.groups.equip:FindDirect("Img_CW_BgEquip01")
  local weapon_texture = panel_weapon:FindDirect("Img_CW_IconEquip01"):GetComponent("UITexture")
  for _, pos in pairs(YouthSubPanel.EquipPos) do
    local panel = self.groups.equip:FindDirect("Img_CW_BgEquip0" .. pos)
    local texture = panel:FindDirect("Img_CW_IconEquip0" .. pos)
    local equip
    if pos < YouthSubPanel.EquipPos.AMULET then
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
def.method("number").OnChildEquipmentClick = function(self, index)
  if self.childData == nil then
    return
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  if index == YouthSubPanel.EquipPos.AMULET then
    local itemInfo = self.childData.info.equipPetItem[PetEquipType.AMULET]
    local slot = PetData.PetEquipmentType.EQUIP_AMULET
    if itemInfo then
      local sourceObj = self.groups.equip:FindDirect("Img_CW_BgEquip0" .. index)
      local src = ItemTipsMgr.Source.ChildrenBag
      if self.isViewOnly then
        src = ItemTipsMgr.Source.ChildrenPanel
      end
      local tip = ItemTipsMgr.Instance():ShowTipsEx(itemInfo, ItemModule.EQUIPBAG, 1, src, sourceObj, 1)
      tip:SetOperateContext({slot = slot})
    else
      local CommonUsePanel = require("GUI.CommonUsePanel")
      local PetMgr = require("Main.Pet.mgr.PetMgr")
      local itemIdList = require("Main.Pet.mgr.PetEquipmentMgr").Instance():GetEquipmentSourceItemIdList(slot)
      CommonUsePanel.Instance():SetItemIdList(itemIdList)
      local src = ItemTipsMgr.Source.ChildrenItemBag
      if self.isViewOnly then
        src = ItemTipsMgr.Source.ChildrenPanel
      end
      CommonUsePanel.Instance():ShowPanel(PetMgr.PetEquipmentItemFilter, nil, src, {slot})
    end
  else
    local itemInfo = self.childData.info.equipItem[index]
    if itemInfo == nil then
      return
    end
    local sourceObj = self.groups.equip:FindDirect("Img_CW_BgEquip0" .. index)
    local src = ItemTipsMgr.Source.ChildrenBag
    if self.isViewOnly then
      src = ItemTipsMgr.Source.ChildrenPanel
    end
    local tip = ItemTipsMgr.Instance():ShowTipsEx(itemInfo, ItemModule.EQUIPBAG, 1, src, sourceObj, 1)
    tip:SetOperateContext({slot = index})
  end
end
def.static("table", "table").OnUpgradeEquip = function(p1, p2)
  if instance:CheckEnable() then
    require("Main.Children.ui.DlgEquipUpgrade").Instance():ShowPanel(instance.childData.id)
  end
end
def.static("table", "table").OnRandomEquip = function(p1, p2)
  if instance:CheckEnable() then
    local index = p1[2] and p1[2].slot
    local equip = instance.childData.info.equipItem[YouthSubPanel.EquipPosToType[index]]
    require("Main.Children.ui.DlgEquipRandomProperty").Instance():ShowPanel(instance.childData.id, equip, index)
  end
end
def.static("table", "table").OnSkillUnlocked = function(p1, p2)
  instance:ShowSkillInfo()
end
def.static("table", "table").OnSpecialSkillUpdated = function(p1, p2)
  instance:ShowSkillInfo()
end
def.method().ShowMenpaiSkillInfo = function(self)
  if self.childData == nil or self.groups == nil then
    return
  end
  local fightSkill = self.childData.info.fightSkills[1]
  local menpai = self.childData:GetMenpai()
  local menpaiSkillPanel = self.groups.skill:FindDirect("Group_CampSkill")
  local menpai_skills
  if menpai > 0 then
    menpai_skills = ChildrenUtils.GetMenpaiSkills(menpai)
    menpaiSkillPanel:FindDirect("Btn_ChangeCamp/Label"):GetComponent("UILabel").text = textRes.Children[3045]
  else
    menpaiSkillPanel:FindDirect("Btn_ChangeCamp/Label"):GetComponent("UILabel").text = textRes.Children[3044]
  end
  local menpaiSkill1 = menpaiSkillPanel:FindDirect("Img_CampSkill01/Icon_ItemSkillIcon")
  local menpaiSkill2 = menpaiSkillPanel:FindDirect("Img_CampSkill02/Icon_ItemSkillIcon")
  local menpaiSkill3 = menpaiSkillPanel:FindDirect("Img_CampSkill03/Icon_ItemSkillIcon")
  local menpaiSkill4 = menpaiSkillPanel:FindDirect("Img_CampSkill04/Icon_ItemSkillIcon")
  local menpai_skillid1 = menpai_skills and menpai_skills[1] and menpai_skills[1].skillid or 0
  local menpai_skillid2 = menpai_skills and menpai_skills[2] and menpai_skills[2].skillid or 0
  local menpai_skillid3 = menpai_skills and menpai_skills[3] and menpai_skills[3].skillid or 0
  local menpai_skillid4 = menpai_skills and menpai_skills[4] and menpai_skills[4].skillid or 0
  self:SetSkillIcon(menpaiSkill1, menpai_skillid1)
  self:SetSkillIcon(menpaiSkill2, menpai_skillid2)
  self:SetSkillIcon(menpaiSkill3, menpai_skillid3)
  self:SetSkillIcon(menpaiSkill4, menpai_skillid4)
  menpaiSkillPanel:FindDirect("Img_CampSkill01/Img_FightSign"):SetActive(self.childData:IsFightSkill(menpai_skillid1))
  menpaiSkillPanel:FindDirect("Img_CampSkill02/Img_FightSign"):SetActive(self.childData:IsFightSkill(menpai_skillid2))
  menpaiSkillPanel:FindDirect("Img_CampSkill03/Img_FightSign"):SetActive(self.childData:IsFightSkill(menpai_skillid3))
  menpaiSkillPanel:FindDirect("Img_CampSkill04/Img_FightSign"):SetActive(self.childData:IsFightSkill(menpai_skillid4))
end
def.method().ShowSkillInfo = function(self)
  if self.childData == nil or self.groups == nil then
    return
  end
  self.groups.menu:SetActive(false)
  self:ShowMenpaiSkillInfo()
  local specialSkillPanel = self.groups.skill:FindDirect("Group_ChildSkill/Img_ChildSkill/Icon_ItemSkillIcon")
  self:SetSkillIcon(specialSkillPanel, self.childData.info.specialSkillid)
  self.groups.skill:FindDirect("Group_ChildSkill/Btn_ChildSkill"):SetActive(not self.isViewOnly and self.childData.info.specialSkillid <= 0)
  self.groups.skill:FindDirect("Group_ChildSkill/Btn_ChangeSkill"):SetActive(not self.isViewOnly and self.childData.info.specialSkillid > 0)
  local bookSkillPanel = self.groups.skill:FindDirect("Group_SkillView/Group_Skill/Scroll View_Skill/Grid_Skill")
  local amuletSkillIdx = 1
  local amuletSkills = self:GetAmuletSkills()
  local amulet_skill_count = amuletSkills and #amuletSkills or 0
  for i = 1, 12 do
    local panel_name = string.format("Img_ItemSkill%02d", i)
    local skillPanel = bookSkillPanel:FindDirect(panel_name .. "/Icon_ItemSkillIcon")
    local add_icon = bookSkillPanel:FindDirect(panel_name .. "/Img_SkillAdd")
    bookSkillPanel:FindDirect(panel_name .. "/Img_SkillLock"):SetActive(i > self.childData.info.unLockSkillPosNum + constant.CChildrenConsts.child_init_skill_pos_max + amulet_skill_count and i <= constant.CChildrenConsts.child_common_skill_max + amulet_skill_count)
    local skillId = self.childData.info.skillBookSkills[i]
    local isAmulet = false
    if skillId == nil or skillId == 0 then
      skillId = amuletSkills and amuletSkills[amuletSkillIdx]
      amuletSkillIdx = amuletSkillIdx + 1
      isAmulet = skillId ~= nil and skillId > 0
    end
    if skillId and skillId > 0 then
      self:SetSkillIcon(skillPanel, skillId)
      add_icon:SetActive(false)
    else
      self:SetSkillIcon(skillPanel, 0)
      add_icon:SetActive(i <= self.childData.info.unLockSkillPosNum + constant.CChildrenConsts.child_init_skill_pos_max + amulet_skill_count)
    end
    bookSkillPanel:FindDirect(panel_name .. "/Img_AmuletSign"):SetActive(isAmulet)
    bookSkillPanel:FindDirect(panel_name .. "/Img_SkillFu"):SetActive(i > constant.CChildrenConsts.child_common_skill_max + amulet_skill_count)
  end
end
def.method("userdata").ShowChildModel = function(self, modelPanel)
  if self.child == nil then
    local fashion = self.childData:GetFashionByPhase(self.childData:GetStatus())
    self.child = Child.CreateWithFashionAndWeapon(self.childData:GetModelCfgId(), fashion and fashion.fashionId or 0, self.childData:GetWeaponId())
  end
  local uiModel = modelPanel:GetComponent("UIModel")
  local child_model = self.child:GetModel()
  if child_model then
    uiModel.modelGameObject = child_model.m_model
    self.child:Stand()
  else
    self.child:LoadUIModel(nil, function()
      uiModel.modelGameObject = self.child.model.m_model
      if uiModel.mCanOverflow ~= nil then
        uiModel.mCanOverflow = true
        local camera = uiModel:get_modelCamera()
        if camera then
          camera:set_orthographic(true)
        end
      end
    end)
  end
end
def.method("userdata", "number").SetSkillIcon = function(self, panel, skillId)
  local ui_Texture = panel:GetComponent("UITexture")
  if skillId > 0 then
    local skillInfo = SkillUtility.GetSkillCfg(skillId)
    GUIUtils.FillIcon(ui_Texture, skillInfo.iconId)
    local menpai = self.childData:GetMenpai()
    if menpai > 0 then
      local childEquipLv = self.childData:GetEquipsMinLevel()
      local menpaiSkillMap = ChildrenUtils.GetMenpaiSkillMap(menpai)
      local skillCfgInfo = menpaiSkillMap[skillId]
      if skillCfgInfo then
        if childEquipLv >= skillCfgInfo.needEquipmentLevel then
          GUIUtils.SetTextureEffect(ui_Texture, GUIUtils.Effect.Normal)
        else
          GUIUtils.SetTextureEffect(ui_Texture, GUIUtils.Effect.Gray)
        end
      end
    end
  else
    GUIUtils.FillIcon(ui_Texture, 0)
  end
end
def.method().AddPoint = function(self)
  if self.childData == nil then
    return
  end
  if self.childData.info.occupation < 0 then
    Toast(textRes.Children[3000])
    return
  end
  local panel = require("Main.Children.ui.ChildAutoAssignPropSettingPanel").Instance()
  panel:ShowPanelEx(self.childData.id)
end
def.method().ChangeMenpaiSkill = function(self)
  if self.childData == nil then
    return
  end
  if self.childData:GetMenpai() <= 0 then
    require("Main.Children.ui.DlgJoinMenpai").Instance():ShowPanel(self.childData.id)
  else
    require("Main.Children.ui.DlgSkillTraining").Instance():ShowPanel(self.childData.id)
  end
end
def.method().LearSpecialSkill = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommonUsePanel = require("GUI.CommonUsePanel")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local itemIds = ChildrenUtils.GetAllChildrenSpecialSkillItemIds()
  CommonUsePanel.Instance():SetItemIdList(itemIds)
  local function filter(item, params)
    if item == nil then
      return false
    end
    local itemBase = ItemUtils.GetItemBase(item.id)
    if itemBase == nil then
      return false
    end
    return itemBase.itemType == ItemType.CHILDREN_SPECIAL_SKILL_ITEM
  end
  CommonUsePanel.Instance():ShowPanel(filter, nil, CommonUsePanel.Source.ChildrenBag, nil)
end
def.method("number").OnClickSkill = function(self, index)
  if self.childData == nil then
    return
  end
  local amuletSkills = self:GetAmuletSkills()
  local amulet_skill_count = amuletSkills and #amuletSkills or 0
  if index <= self.childData.info.unLockSkillPosNum + constant.CChildrenConsts.child_init_skill_pos_max + amulet_skill_count then
    if self.isViewOnly or #self.childData.info.skillBookSkills == 0 and index <= amulet_skill_count then
      self:ShowSkillTip(index)
    elseif self:CheckEnable() and not self:ShowSkillTip(index) then
      require("Main.Children.ui.DlgUpdateSkill").Instance():ShowPanel(self.childData.id)
    end
  elseif index <= constant.CChildrenConsts.child_common_skill_max + amulet_skill_count and not self.isViewOnly then
    if _G.CheckCrossServerAndToast() then
      return
    end
    if not self.childData:IsMine() then
      Toast(textRes.Children[3043])
      return
    end
    if self.unlockCfgs == nil then
      self.unlockCfgs = ChildrenUtils.GetChildSkillUnlockCfg()
    end
    local unlockCfgIdx = self.childData.info.unLockSkillPosNum + 1
    local cfg = self.unlockCfgs[unlockCfgIdx]
    if cfg == nil then
      return
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local itemBase = ItemUtils.GetItemBase(cfg.unLockMainItem)
    if itemBase == nil then
      return
    end
    local itemName = string.format("[%s]%s[-][00ff00]X%d[-]", require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor], itemBase.name, cfg.unLockItemNum)
    CommonConfirmDlg.ShowConfirm(textRes.Children[3026], string.format(textRes.Children[3025], tostring(unlockCfgIdx + constant.CChildrenConsts.child_init_skill_pos_max), itemName), function(id, tag)
      if id == 1 then
        if self.childData == nil then
          return
        end
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Children.CUnLockSkillPosReq").new(self.childData.id, self.childData.info.unLockSkillPosNum))
      end
    end, nil)
  end
end
def.method("number", "=>", "boolean").ShowSkillTip = function(self, index)
  local amuletSkills = self:GetAmuletSkills()
  local skillId = self.childData.info.skillBookSkills[index]
  if skillId == nil and amuletSkills then
    skillId = amuletSkills[index - #self.childData.info.skillBookSkills]
  end
  if skillId == nil then
    return false
  end
  local bookSkillsPanel = self.groups.skill:FindDirect("Group_SkillView/Group_Skill/Scroll View_Skill/Grid_Skill")
  local sourceObj = bookSkillsPanel:FindDirect(string.format("Img_ItemSkill%02d", index))
  local context = {
    skill = {id = skillId, isOwnSkill = true},
    needRemember = true
  }
  require("Main.Pet.PetUtility").ShowPetSkillTipEx(skillId, 1, sourceObj, 0, context)
  return true
end
def.method("number").ShowMenpaiSkillTip = function(self, index)
  local CommonSkillTip = require("GUI.CommonSkillTip")
  local sourceObj = self.groups.skill:FindDirect(string.format("Group_CampSkill/Img_CampSkill%02d", index))
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local menpai = self.childData:GetMenpai()
  local menpai_skills = ChildrenUtils.GetMenpaiSkills(menpai)
  local skill_data = menpai_skills[index]
  if skill_data then
    require("Main.Skill.SkillTipMgr").Instance():ShowChildSkillTip(skill_data.skillid, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1, menpai, self.childData:GetId())
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
def.method().OnAddGrowClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommonUsePanel = require("GUI.CommonUsePanel")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local itemIdList = ItemUtils.GetItemTypeRefIdList(ItemType.CHILDREN_GROWTH_ITEM)
  CommonUsePanel.Instance():SetItemIdList(itemIdList)
  local function filter(item, params)
    if item == nil then
      return false
    end
    local itemBase = ItemUtils.GetItemBase(item.id)
    if itemBase == nil then
      return false
    end
    return itemBase.itemType == ItemType.CHILDREN_GROWTH_ITEM
  end
  CommonUsePanel.Instance():ShowPanel(filter, nil, CommonUsePanel.Source.ChildrenBag, nil)
  CommonUsePanel.Instance():SetDescText(string.format(textRes.Pet[145], constant.CChildrenConsts.child_use_grow_item_max - self.childData.info.useGrowthItemCount))
end
def.static("table", "table").OnGrowthUpdated = function(p1, p2)
  if instance.childData == nil or instance.groups == nil then
    return
  end
  instance.groups.props:FindDirect("Group_Grow/Label_Num"):GetComponent("UILabel").text = MathHelper.Round(instance.childData.info.grow * 1000) / 1000
  local commonUsePanel = require("GUI.CommonUsePanel").Instance()
  commonUsePanel:SetDescText(string.format(textRes.Pet[145], constant.CChildrenConsts.child_use_grow_item_max - instance.childData.info.useGrowthItemCount))
end
def.method().OnAddCharacterClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommonUsePanel = require("GUI.CommonUsePanel")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local itemIdList = ItemUtils.GetItemTypeRefIdList(ItemType.CHILDREN_CHARATER_ITEM)
  CommonUsePanel.Instance():SetItemIdList(itemIdList)
  local function filter(item, params)
    if item == nil then
      return false
    end
    local itemBase = ItemUtils.GetItemBase(item.id)
    if itemBase == nil then
      return false
    end
    return itemBase.itemType == ItemType.CHILDREN_CHARATER_ITEM
  end
  CommonUsePanel.Instance():ShowPanel(filter, nil, CommonUsePanel.Source.ChildrenBag, nil)
end
def.method("=>", "boolean").CheckEnable = function(self)
  if self.childData == nil then
    return false
  end
  if self.isViewOnly then
    return false
  end
  if _G.CheckCrossServerAndToast() then
    return false
  end
  if not self.childData:IsMine() then
    Toast(textRes.Children[3043])
    return false
  end
  if self.childData.info.occupation > 0 then
    return true
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm("", textRes.Children[3001], function(id, tag)
    if id == 1 then
      if self.childData == nil then
        return
      end
      require("Main.Children.ui.DlgJoinMenpai").Instance():ShowPanel(self.childData.id)
    end
  end, nil)
  return false
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
def.override("string", "boolean", "=>", "boolean").onToggle = function(self, id, active)
  if self:IsShow() then
    if id == "Img_Bg" then
      if self.childOpe then
        if active then
          self.childOpe:Show(nil)
        else
          self.childOpe:Hide()
        end
      end
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "=>", "boolean").onDragStart = function(self, id)
  if self:IsShow() then
    if id == "Model_Baby" then
      self.isDrag = true
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "=>", "boolean").onDragEnd = function(self, id)
  if self:IsShow() then
    if self.isDrag then
      self.isDrag = false
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "number", "number", "=>", "boolean").onDrag = function(self, id, dx, dy)
  if self:IsShow() then
    if self.isDrag == true and self.child.model then
      self.child.model:SetDir(self.child.model:GetDir() - dx / 2)
      return true
    end
    return false
  else
    return false
  end
end
YouthSubPanel.Commit()
return YouthSubPanel
