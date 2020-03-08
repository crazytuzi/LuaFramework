local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SkillPanelNodeBase = require("Main.Skill.ui.SkillPanelNodeBase")
local LivingSkillNode = Lplus.Extend(SkillPanelNodeBase, "LivingSkillNode")
local SkillMgr = require("Main.Skill.SkillMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = LivingSkillNode.define
local LivingSkillData = require("Main.Skill.data.LivingSkillData")
local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local MakeMedicine = require("Main.Skill.ui.MakeMedicine")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GangModule = require("Main.Gang.GangModule")
local SkillPanel = Lplus.ForwardDeclare("SkillPanel")
local instance
def.field("userdata").ui_List_Skill = nil
def.field("userdata").Group_Life_SkillName = nil
def.field("userdata").Group_Activity = nil
def.field("userdata").Group_Life_Weapon = nil
def.field("userdata").Group_Life_Food = nil
def.field("userdata").Group_Life_Use = nil
def.field("userdata").Group_Life_Have = nil
def.field("number").lastSelectedIndex = 1
def.field("number").lastSelectedItemNum = 0
def.field("number").lastSelectedWeaponIndex = 0
def.field("number").lastSelectedFoodIndex = 0
def.field("number").selectSkillBagId = 0
def.field("table").baglist = nil
def.static("=>", LivingSkillNode).Instance = function()
  if instance == nil then
    instance = LivingSkillNode()
    LivingSkillData.Instance():InitLivingSkillBags()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  SkillPanelNodeBase.Init(self, base, node)
  self:InitUI()
end
def.override().OnShow = function(self)
  self.selectSkillBagId = SkillPanel.Instance():GetSelectSkillBagId()
  SkillPanel.Instance():SetSelectSkillBagId(0)
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, LivingSkillNode.OnEnergyChanged)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_COMMON_INFO, LivingSkillNode.CommonInfoReturn)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_BAG_LEVEL_UP_SUCCESS, LivingSkillNode.SucceedSkillBagLevelUp)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_BAG_LEVEL_RESET_SUCCESS, LivingSkillNode.SucceedSkillBagLevelReset)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_COOK_RES, LivingSkillNode.SucceedMakeFoodItem)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_WEAPON_RES, LivingSkillNode.SucceedMakeWeaponItem)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BanggongChanged, LivingSkillNode.OnBanggongChanged)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, LivingSkillNode.OnLeaveHomeland)
end
def.override().OnHide = function(self)
  self.selectSkillBagId = 0
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, LivingSkillNode.OnEnergyChanged)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_COMMON_INFO, LivingSkillNode.CommonInfoReturn)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_BAG_LEVEL_UP_SUCCESS, LivingSkillNode.SucceedSkillBagLevelUp)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_BAG_LEVEL_RESET_SUCCESS, LivingSkillNode.SucceedSkillBagLevelReset)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_COOK_RES, LivingSkillNode.SucceedMakeFoodItem)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_WEAPON_RES, LivingSkillNode.SucceedMakeWeaponItem)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BanggongChanged, LivingSkillNode.OnBanggongChanged)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, LivingSkillNode.OnLeaveHomeland)
  SkillPanelNodeBase.OnHide(self)
  self.baglist = nil
end
def.method().ClearNode = function(self)
  self.lastSelectedItemNum = 0
  self.selectSkillBagId = 0
end
def.override().InitUI = function(self)
  SkillPanelNodeBase.InitUI(self)
  local node = self.m_node
  self.ui_List_Skill = node:FindDirect("Img_Life_BgList/Scroll View_Life_List/List_Life_Skill")
  self.Group_Life_SkillName = node:FindDirect("Group_Life_SkillName")
  self.Group_Activity = node:FindDirect("Group_Activity")
  self.Group_Life_Weapon = node:FindDirect("Group_Life_Weapon")
  self.Group_Life_Food = node:FindDirect("Group_Life_Food")
  self.Group_Life_Use = node:FindDirect("Group_Life_LvUp/Group_Life_Use")
  self.Group_Life_Have = node:FindDirect("Group_Life_LvUp/Group_Life_Have")
end
def.override("=>", "boolean").IsUnlock = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  return heroProp.level >= LivingSkillUtility.GetLivingSkillConst("OPEN_LEVEL")
end
def.method().UpdateUI = function(self)
  self:FillLivingBagList()
  self:FillSelectedSkillBag()
end
def.method("table", "function", "=>", "table").filterSkillBagList = function(self, skillBagList, func)
  if skillBagList == nil or func == nil then
    return
  end
  local retData = {}
  for i = 1, #skillBagList do
    local skillBag = skillBagList[i]
    if not func(skillBag) then
      table.insert(retData, skillBag)
    end
  end
  return retData
end
def.method("=>", "table").GetBagList = function(self)
  if self.baglist == nil then
    local skillBagList = LivingSkillData.Instance():GetBagList()
    skillBagList = self:filterSkillBagList(skillBagList, require("Main.Gang.GodMedicine.GodMedicineMgr").filterSkillBagFunc)
    self.baglist = skillBagList
  end
  return self.baglist
end
def.method().FillLivingBagList = function(self)
  local skillBagList = self:GetBagList()
  local uiList = self.ui_List_Skill:GetComponent("UIList")
  local skillBagAmount = #skillBagList
  uiList:set_itemCount(skillBagAmount)
  uiList:Resize()
  local items = uiList:get_children()
  for i = 1, skillBagAmount do
    do
      local item = items[i]
      local skillBag = skillBagList[i]
      for k, v in pairs(skillBag.itemIdList) do
        if v.bagId == self.selectSkillBagId then
          self.lastSelectedIndex = i
        end
      end
      local itemList = skillBag.itemIdList
      if nil == itemList then
        return
      end
      local canMakeMaxIndex = 1
      for k, v in pairs(itemList) do
        if skillBag.level >= v.openLevel and k > canMakeMaxIndex then
          canMakeMaxIndex = k
        end
      end
      local itemInfo = itemList[canMakeMaxIndex]
      self:FillLivingBagInfo(item, i, skillBag, itemInfo)
      local uiToggle = item:GetComponent("UIToggle")
      GameUtil.AddGlobalTimer(0.1, true, function()
        if self.m_base.m_panel and false == self.m_base.m_panel.isnil then
          if self.lastSelectedIndex == i then
            uiToggle:set_value(true)
          else
            uiToggle:set_value(false)
          end
        end
      end)
    end
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("userdata", "number", "table", "table").FillLivingBagInfo = function(self, item, index, skillBag, itemInfo)
  local ui_Label_SkillGroup = item:FindDirect(string.format("Label_Life_Skill_%d", index))
  ui_Label_SkillGroup:GetComponent("UILabel"):set_text(skillBag.name)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local maxLevel = heroProp.level + LivingSkillUtility.GetLivingSkillConst("SKILLBAG_MORE_THAN_ROLE_LEVEL")
  maxLevel = math.min(maxLevel, LivingSkillUtility.GetLivingSkillConst("SKILLBAG_MAX_LEVEL"))
  local levelInfo = skillBag.level .. "/" .. maxLevel
  local ui_Label_Lv = item:FindDirect(string.format("Label_Life_Lv_%d", index))
  ui_Label_Lv:GetComponent("UILabel"):set_text(levelInfo)
  local ui_Texture_IconGroup = item:FindDirect(string.format("Img_Life_BgIconGroup_%d/Texture_IconGroup_%d", index, index))
  local uiTexture = ui_Texture_IconGroup:GetComponent("UITexture")
  local itemId = itemInfo.id
  local itemBase
  if itemInfo.bItem then
    itemBase = ItemUtils.GetItemBase(itemId)
  else
    itemBase = ItemUtils.GetItemFilterCfg(itemId)
  end
  local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
  if skillBag.showType == LifeSkillBagShowTypeEnum.type1 then
    require("GUI.GUIUtils").FillIcon(uiTexture, itemBase.icon)
  else
    require("GUI.GUIUtils").FillIcon(uiTexture, skillBag.iconId)
  end
end
def.method().FillSelectedSkillBag = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  if nil == skillBag then
    return
  end
  self.Group_Life_SkillName:FindDirect("Label_Life_SkillName"):GetComponent("UILabel"):set_text(skillBag.name)
  self.Group_Life_SkillName:FindDirect("Label_Life_Lv"):GetComponent("UILabel"):set_text(string.format(textRes.Skill[69], skillBag.level))
  self.Group_Life_SkillName:FindDirect("Label_Life_Describe"):GetComponent("UILabel"):set_text(skillBag.desc)
  self.Group_Life_SkillName:FindDirect("Label_Life_SkillName"):GetComponent("UILabel"):set_text(skillBag.name)
  local needSilver, needBanggong = LivingSkillUtility.GetLevelUpInfo(skillBag.levelUpTypeId, skillBag.level)
  self.Group_Life_Use:FindDirect("Label_Life_UseMoneyNum"):GetComponent("UILabel"):set_text(needSilver)
  self.Group_Life_Use:FindDirect("Label_Life_UseGangNum"):GetComponent("UILabel"):set_text(needBanggong)
  local costVigor = LivingSkillUtility.GetCostVigor(skillBag.id, skillBag.level)
  self.Group_Activity:FindDirect("Label_Life_NeedNum"):GetComponent("UILabel"):set_text(costVigor)
  local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
  if skillBag.showType == LifeSkillBagShowTypeEnum.type1 then
    self.Group_Life_Weapon:SetActive(true)
    self.Group_Life_Food:SetActive(false)
    self.Group_Life_Weapon:FindDirect("Label_Life_TipsW2"):GetComponent("UILabel"):set_text(skillBag.templatename)
    local tex = self.Group_Life_Weapon:FindDirect("Texture"):GetComponent("UITexture")
    GUIUtils.FillIcon(tex, skillBag.iconId)
    self:UpdateWeaponSkill()
  elseif skillBag.showType == LifeSkillBagShowTypeEnum.type2 or skillBag.showType == LifeSkillBagShowTypeEnum.type3 then
    self.Group_Life_Weapon:SetActive(false)
    self.Group_Life_Food:SetActive(true)
    self:UpdateFoodSkill()
    self.Group_Life_Food:FindDirect("Label_Life_TipsF2"):GetComponent("UILabel"):set_text(skillBag.templatename)
    local tex = self.Group_Life_Food:FindDirect("Texture"):GetComponent("UITexture")
    GUIUtils.FillIcon(tex, skillBag.iconId)
    local gridTemplate = self.Group_Life_Food:FindDirect("Scroll View_Life_Food/Grid_Life_Food")
    if #skillBag.itemIdList >= self.lastSelectedFoodIndex and 0 ~= self.lastSelectedFoodIndex then
      gridTemplate:GetChild(self.lastSelectedFoodIndex - 1):GetComponent("UIToggle"):set_isChecked(false)
    end
    self.lastSelectedFoodIndex = 0
  end
  local Btn_ReSet = self.Group_Life_SkillName:FindDirect("Btn_ReSet")
  GUIUtils.SetActive(Btn_ReSet, self:IsResetLivingSkillOpen())
  self:UpdateSilverMoney()
  self:UpdateGangMoney()
  self:UpdateEnergy()
end
def.method().UpdateSilverMoney = function(self)
  self.Group_Life_Have:FindDirect("Label_Life_UseMoneyNum"):GetComponent("UILabel"):set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)))
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  if nil == skillBag then
    return
  end
  local needSilver, needBanggong = LivingSkillUtility.GetLevelUpInfo(skillBag.levelUpTypeId, skillBag.level)
  if Int64.gt(needSilver, Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER))) then
    self.Group_Life_Use:FindDirect("Label_Life_UseMoneyNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    self.Group_Life_Use:FindDirect("Label_Life_UseMoneyNum"):GetComponent("UILabel"):set_textColor(Color.Color(0.31, 0.188, 0.094, 1))
  end
end
def.override("table", "table").OnSilverMoneyChanged = function(self, params, context)
  self:UpdateSilverMoney()
end
def.static("table", "table").OnBanggongChanged = function(self, params, context)
  local self = instance
  self:UpdateGangMoney()
end
def.static("table", "table").OnLeaveHomeland = function(self, params, context)
  local self = instance
  self.m_base:DestroyPanel()
end
def.method().UpdateGangMoney = function(self)
  local curBanggong = GangModule.Instance():GetHeroCurBanggong()
  self.Group_Life_Have:FindDirect("Label_Life_UseGangNum"):GetComponent("UILabel"):set_text(curBanggong)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  if nil == skillBag then
    return
  end
  local needSilver, needBanggong = LivingSkillUtility.GetLevelUpInfo(skillBag.levelUpTypeId, skillBag.level)
  if curBanggong < needBanggong then
    self.Group_Life_Use:FindDirect("Label_Life_UseGangNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    self.Group_Life_Use:FindDirect("Label_Life_UseGangNum"):GetComponent("UILabel"):set_textColor(Color.Color(0.31, 0.188, 0.094, 1))
  end
end
def.method().UpdateEnergy = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  self.Group_Activity:FindDirect("Label_Life_HaveNum"):GetComponent("UILabel"):set_text(heroProp.energy)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  if nil == skillBag then
    return
  end
  local costVigor = 0
  local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
  if skillBag.showType == LifeSkillBagShowTypeEnum.type1 then
    local itemList = skillBag.itemIdList
    local itemInfo = itemList[self.lastSelectedWeaponIndex]
    costVigor = LivingSkillUtility.GetCostVigor(skillBag.id, itemInfo.openLevel)
  elseif skillBag.showType == LifeSkillBagShowTypeEnum.type2 or skillBag.showType == LifeSkillBagShowTypeEnum.type3 then
    costVigor = LivingSkillUtility.GetCostVigor(skillBag.id, skillBag.level)
  end
  if costVigor > heroProp.energy then
    self.Group_Activity:FindDirect("Label_Life_NeedNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    self.Group_Activity:FindDirect("Label_Life_NeedNum"):GetComponent("UILabel"):set_textColor(Color.Color(0.31, 0.188, 0.094, 1))
  end
end
def.static("table", "table").OnEnergyChanged = function(params, context)
  LivingSkillNode.Instance():UpdateEnergy()
end
def.method().ClearItemObjects = function(self)
  local gridTemplate = self.Group_Life_Food:FindDirect("Scroll View_Life_Food/Grid_Life_Food")
  for i = 1, self.lastSelectedItemNum do
    LivingSkillUtility.DeleteLastGroup(self.lastSelectedItemNum, "Img_Life_BgIconFood%d", gridTemplate)
    self.lastSelectedItemNum = self.lastSelectedItemNum - 1
  end
  local uiGrid = gridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("number").CreateItemObjects = function(self, curItemListNum)
  local gridTemplate = self.Group_Life_Food:FindDirect("Scroll View_Life_Food/Grid_Life_Food")
  local itemTemplate = gridTemplate:FindDirect("Img_Life_BgIconFood")
  itemTemplate:SetActive(false)
  for j = 1, curItemListNum do
    self.lastSelectedItemNum = self.lastSelectedItemNum + 1
    LivingSkillUtility.AddLastGroup(self.lastSelectedItemNum, "Img_Life_BgIconFood%d", gridTemplate, itemTemplate)
  end
  local uiGrid = gridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method().UpdateFoodItemObjects = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local itemList = skillBag.itemIdList
  self:ClearItemObjects()
  self:CreateItemObjects(#itemList)
end
def.method().FillFoodSkill = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local itemList = skillBag.itemIdList
  if nil == itemList then
    return
  end
  local gridTemplate = self.Group_Life_Food:FindDirect("Scroll View_Life_Food/Grid_Life_Food")
  for i = 1, #itemList do
    local item = gridTemplate:GetChild(i)
    local itemInfo = itemList[i]
    local level = skillBag.level
    self:FillFoodItemInfo(itemInfo, item, level)
  end
end
def.method("table", "userdata", "number").FillFoodItemInfo = function(self, itemInfo, item, level)
  local Texture_IconFood = item:FindDirect("Texture_IconFood"):GetComponent("UITexture")
  local Img_Life_LockFood = item:FindDirect("Img_Life_LockFood")
  local Label_Life_LvFood = item:FindDirect("Label_Life_LvFood")
  local itemId = itemInfo.id
  local openLv = itemInfo.openLevel
  local itemBase
  if itemInfo.bItem then
    itemBase = ItemUtils.GetItemBase(itemId)
  else
    itemBase = ItemUtils.GetItemFilterCfg(itemId)
  end
  local itemIcon
  if itemBase ~= nil then
    itemIcon = itemBase.icon
  end
  GUIUtils.FillIcon(Texture_IconFood, itemIcon)
  if level >= openLv then
    Img_Life_LockFood:SetActive(false)
    Label_Life_LvFood:SetActive(false)
    Texture_IconFood:set_color(Color.Color(1, 1, 1, 1))
  else
    Img_Life_LockFood:SetActive(true)
    Label_Life_LvFood:SetActive(true)
    Label_Life_LvFood:GetComponent("UILabel"):set_text(openLv)
    Label_Life_LvFood:GetComponent("UILabel"):set_textColor(Color.red)
    Texture_IconFood:set_color(Color.Color(0.3, 0.3, 0.3, 1))
  end
end
def.method().UpdateFoodSkill = function(self)
  self:UpdateFoodItemObjects()
  self:FillFoodSkill()
end
def.method().FillWeaponSkill = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local itemList = skillBag.itemIdList
  if nil == itemList then
    return
  end
  self.lastSelectedWeaponIndex = 0
  local canMakeMaxIndex = 1
  for k, v in pairs(itemList) do
    if skillBag.level >= v.openLevel then
      canMakeMaxIndex = k
    end
    if v.bagId == self.selectSkillBagId then
      self.lastSelectedWeaponIndex = k
    end
  end
  if self.lastSelectedWeaponIndex == 0 then
    self.lastSelectedWeaponIndex = canMakeMaxIndex
  end
  self:UpdateWeaponSelectButton()
  self:FillWeaponItemInfo(itemList[self.lastSelectedWeaponIndex], skillBag.level)
end
def.method().UpdateWeaponSelectButton = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local itemList = skillBag.itemIdList
  local nextItemInfo = itemList[self.lastSelectedWeaponIndex + 1]
  self.Group_Life_Weapon:FindDirect("Btn_Left"):SetActive(true)
  self.Group_Life_Weapon:FindDirect("Btn_Right"):SetActive(true)
  if self.lastSelectedWeaponIndex - 1 < 1 then
    self.Group_Life_Weapon:FindDirect("Btn_Left"):SetActive(false)
  end
  if nextItemInfo == nil or nextItemInfo.openLevel > skillBag.level then
    self.Group_Life_Weapon:FindDirect("Btn_Right"):SetActive(false)
  end
end
def.method("table", "number").FillWeaponItemInfo = function(self, itemInfo, level)
  local itemId = itemInfo.id
  local openLv = itemInfo.openLevel
  local itemBase
  if itemInfo.bItem then
    itemBase = ItemUtils.GetItemBase(itemId)
  else
    itemBase = ItemUtils.GetItemFilterCfg(itemId)
  end
  local Img_Life_BgIconWeapon = self.Group_Life_Weapon:FindDirect("Img_Life_BgIconWeapon")
  local Texture_IconWeapon = Img_Life_BgIconWeapon:FindDirect("Texture_IconWeapon"):GetComponent("UITexture")
  local Img_Life_LockWeapon = Img_Life_BgIconWeapon:FindDirect("Img_Life_LockWeapon")
  local Label_Life_LvWeapon = Img_Life_BgIconWeapon:FindDirect("Label_Life_LvWeapon")
  local Label_Life_Weapon = self.Group_Life_Weapon:FindDirect("Label_Life_Weapon")
  GUIUtils.FillIcon(Texture_IconWeapon, itemBase.icon)
  if level >= openLv then
    Img_Life_LockWeapon:SetActive(false)
    Label_Life_LvWeapon:SetActive(false)
    Texture_IconWeapon:set_color(Color.Color(1, 1, 1, 1))
  else
    Img_Life_LockWeapon:SetActive(true)
    Label_Life_LvWeapon:SetActive(true)
    Label_Life_LvWeapon:GetComponent("UILabel"):set_text(openLv)
    Label_Life_LvWeapon:GetComponent("UILabel"):set_textColor(Color.red)
    Texture_IconWeapon:set_color(Color.Color(0.3, 0.3, 0.3, 1))
  end
  Label_Life_Weapon:GetComponent("UILabel"):set_text(itemBase.name)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local costVigor = LivingSkillUtility.GetCostVigor(skillBag.id, openLv)
  self.Group_Activity:FindDirect("Label_Life_NeedNum"):GetComponent("UILabel"):set_text(costVigor)
end
def.method().UpdateWeaponSkill = function(self)
  self:FillWeaponSkill()
end
def.method().OnLeftWeaponSelect = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local itemList = skillBag.itemIdList
  if 1 <= self.lastSelectedWeaponIndex - 1 then
    self.lastSelectedWeaponIndex = self.lastSelectedWeaponIndex - 1
  end
  self:UpdateWeaponSelectButton()
  self:FillWeaponItemInfo(itemList[self.lastSelectedWeaponIndex], skillBag.level)
end
def.method().OnRightWeaponSelect = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local itemList = skillBag.itemIdList
  if self.lastSelectedWeaponIndex + 1 <= #itemList then
    self.lastSelectedWeaponIndex = self.lastSelectedWeaponIndex + 1
  end
  self:UpdateWeaponSelectButton()
  self:FillWeaponItemInfo(itemList[self.lastSelectedWeaponIndex], skillBag.level)
end
def.method("number", "number").SkillBagLevelUpSucceed = function(self, skillbagId, level)
  local unLockItemIdList = {}
  local skillBagList = self:GetBagList()
  local selectSkillBagId = skillBagList[self.lastSelectedIndex].id
  local skillName = ""
  for k, v in pairs(skillBagList) do
    if v.id == skillbagId then
      skillName = v.name
      local itemIdList = v.itemIdList
      for m, n in pairs(itemIdList) do
        if n.openLevel > v.level and level >= n.openLevel then
          local itemBase
          if n.bItem then
            itemBase = ItemUtils.GetItemBase(n.id)
          else
            itemBase = ItemUtils.GetItemFilterCfg(n.id)
          end
          local name = ""
          if nil ~= itemBase then
            name = itemBase.name
          end
          Toast(string.format(textRes.Skill[52], name))
          table.insert(unLockItemIdList, n.id)
        end
      end
      break
    end
  end
  Toast(string.format(textRes.Skill[5], skillName, level))
  LivingSkillData.Instance():SetSkillBagLevel(skillbagId, level)
  if self.m_panel:get_activeInHierarchy() then
    self:FillLivingBagList()
    if selectSkillBagId == skillbagId then
      self:FillSelectedSkillBag()
    end
  end
end
def.method("number", "number", "userdata", "userdata").SkillBagLevelResetSucceed = function(self, skillbagId, level, returnSilver, returnBanggong)
  local skillBagList = self:GetBagList()
  local selectSkillBagId = skillBagList[self.lastSelectedIndex].id
  local skillName = ""
  for k, v in pairs(skillBagList) do
    if v.id == skillbagId then
      skillName = v.name
      break
    end
  end
  LivingSkillData.Instance():SetSkillBagLevel(skillbagId, level)
  if self.m_panel:get_activeInHierarchy() then
    self:FillLivingBagList()
    if selectSkillBagId == skillbagId then
      self:FillSelectedSkillBag()
    end
  end
  local tips = {}
  table.insert(tips, string.format(textRes.Skill[138], skillName, level))
  table.insert(tips, string.format(textRes.Skill[140], RESPATH.COMMONATLAS, "Icon_Sliver", returnSilver:tostring()))
  table.insert(tips, string.format(textRes.Skill[139], RESPATH.COMMONATLAS, "Icon_Bang", returnBanggong:tostring()))
  local tipsStr = table.concat(tips, "&nbsp;&nbsp;")
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(tipsStr)
  local effectId = LivingSkillUtility.GetLivingSkillConst("LIFESKILL_LEVEL_RESET_EFFECT_ID")
  if effectId ~= 0 then
    local effectCfg = _G.GetEffectRes(effectId)
    if nil == effectCfg then
      warn("ResetLivingSkill effet cfg is nil, id = " .. effectId)
      return
    end
    local GUIFxMan = require("Fx.GUIFxMan")
    local fx = GUIFxMan.Instance():Play(effectCfg.path, "ResetLivingSkill", 0, 0, -1, false)
  end
end
def.method().RequireToLevelUp = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.lifeskill.CLifeSkillLevelUpReq").new(skillBag.id))
end
def.static("number", "table").LevelUpCallback = function(i, tag)
  if i == 1 then
    GoToBuySilver(false)
  end
end
def.method().OnLevelUpClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  if skillBag.level >= LivingSkillUtility.GetLivingSkillConst("SKILLBAG_MAX_LEVEL") then
    Toast(textRes.Skill[72])
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local maxLevel = heroProp.level + LivingSkillUtility.GetLivingSkillConst("SKILLBAG_MORE_THAN_ROLE_LEVEL")
  if maxLevel <= skillBag.level then
    Toast(textRes.Skill[51])
    return
  end
  local needSilver, needBanggong = LivingSkillUtility.GetLevelUpInfo(skillBag.levelUpTypeId, skillBag.level)
  if Int64.gt(needSilver, ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)) then
    local tag = {id = self}
    local content = string.format(textRes.Skill[50], skillBag.name)
    CommonConfirmDlg.ShowConfirm("", content, LivingSkillNode.LevelUpCallback, tag)
    return
  end
  local curBanggong = GangModule.Instance():GetHeroCurBanggong()
  if needBanggong > curBanggong then
    local bHasGang = GangModule.Instance():HasGang()
    if false == bHasGang then
      Toast(textRes.Skill[70])
      return
    end
    Toast(textRes.Skill[71])
    return
  end
  self:RequireToLevelUp()
end
def.method().UpdateNeed = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local needSilver, needBanggong = LivingSkillUtility.GetLevelUpInfo(skillBag.levelUpTypeId, skillBag.level)
  self.Group_Life_Use:FindDirect("Label_Life_UseMoneyNum"):GetComponent("UILabel"):set_text(needSilver)
  self.Group_Life_Use:FindDirect("Label_Life_UseGangNum"):GetComponent("UILabel"):set_text(needBanggong)
  local costVigor = 0
  local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
  if skillBag.showType == LifeSkillBagShowTypeEnum.type1 then
    local itemList = skillBag.itemIdList
    local itemInfo = itemList[self.lastSelectedWeaponIndex]
    costVigor = LivingSkillUtility.GetCostVigor(skillBag.id, itemInfo.openLevel)
  elseif skillBag.showType == LifeSkillBagShowTypeEnum.type2 or skillBag.showType == LifeSkillBagShowTypeEnum.type3 then
    costVigor = LivingSkillUtility.GetCostVigor(skillBag.id, skillBag.level)
  end
  self.Group_Activity:FindDirect("Label_Life_NeedNum"):GetComponent("UILabel"):set_text(costVigor)
end
def.static("table", "table").SucceedMakeFoodItem = function(params, context)
  LivingSkillNode.Instance():UpdateNeed()
end
def.static("table", "table").CommonInfoReturn = function(params, context)
end
def.static("table", "table").SucceedSkillBagLevelUp = function(params, context)
  local skillBagId = params[1]
  local level = params[2]
  LivingSkillNode.Instance():SkillBagLevelUpSucceed(skillBagId, level)
end
def.static("table", "table").SucceedSkillBagLevelReset = function(params, context)
  local skillBagId = params[1]
  local level = params[2]
  local returnSilver = params[3]
  local returnBanggong = params[4]
  LivingSkillNode.Instance():SkillBagLevelResetSucceed(skillBagId, level, returnSilver, returnBanggong)
end
def.method().MakeMedicineItem = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local skillTbl = LivingSkillData.Instance():GetUnLockSkill(skillBag.id)
  if 0 == #skillTbl then
    local minUnlockLevel = LivingSkillData.Instance():GetSkillMinUnlockLevel(skillBag.id)
    Toast(string.format(textRes.Skill[73], minUnlockLevel))
    return
  end
  local costVigor = LivingSkillUtility.GetCostVigor(skillBag.id, skillBag.level)
  MakeMedicine.ShowMakeMedicinePanel(nil, nil, costVigor, skillBag.id)
end
def.method().MakeFoodItem = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local skillTbl = LivingSkillData.Instance():GetUnLockSkill(skillBag.id)
  if 0 == #skillTbl then
    local minUnlockLevel = LivingSkillData.Instance():GetSkillMinUnlockLevel(skillBag.id)
    Toast(string.format(textRes.Skill[74], skillBag.name, minUnlockLevel))
    return
  end
  local bBagFull = ItemModule.Instance():IsBagFull(ItemModule.BAG)
  if bBagFull then
    Toast(textRes.Skill.LivingSkillMakeRes[1])
    return
  end
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.lifeskill.CCookReq").new(skillBag.id))
end
def.static("table", "table").SucceedMakeWeaponItem = function(params, context)
  LivingSkillNode.Instance():UpdateNeed()
end
def.method().MakeWeaponItem = function(self)
  local bLock = false
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local itemList = skillBag.itemIdList
  local itemInfo = itemList[self.lastSelectedWeaponIndex]
  if skillBag.level < itemInfo.openLevel then
    bLock = true
  end
  if bLock then
    Toast(string.format(textRes.Skill[59], skillBag.name, skillBag.templatename))
    return
  end
  local bBagFull = ItemModule.Instance():IsBagFull(ItemModule.BAG)
  if bBagFull then
    Toast(textRes.Skill.LivingSkillMakeRes[1])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.lifeskill.CMakeWuQIFuReq").new(skillBag.id, itemInfo.id))
end
def.method().OnMakeItemClick = function(self)
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
  if skillBag.showType == LifeSkillBagShowTypeEnum.type1 then
    self:MakeWeaponItem()
  elseif skillBag.showType == LifeSkillBagShowTypeEnum.type2 then
    self:MakeFoodItem()
  elseif skillBag.showType == LifeSkillBagShowTypeEnum.type3 then
    self:MakeMedicineItem()
  end
end
def.static("number", "number").RequireToUseLivingSkill = function(skillBagId, itemId)
  local skillBag = LivingSkillData.Instance():GetSkillBagById(skillBagId)
  local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
  if skillBag.showType == LifeSkillBagShowTypeEnum.type1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.lifeskill.CMakeWuQIFuReq").new(skillBagId, itemId))
  elseif skillBag.showType == LifeSkillBagShowTypeEnum.type2 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.lifeskill.CCookReq").new(skillBagId))
  elseif skillBag.showType == LifeSkillBagShowTypeEnum.type3 then
    local costVigor = LivingSkillUtility.GetCostVigor(skillBagId, skillBag.level)
    MakeMedicine.ShowMakeMedicinePanel(nil, nil, costVigor, skillBagId)
  end
end
def.method("number").OnSkillBagSelected = function(self, index)
  self.lastSelectedIndex = index
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  self.selectSkillBagId = skillBag.id
  self:FillSelectedSkillBag()
end
def.method("userdata").ShowWeaponTips = function(self, clickobj)
  local bLock = false
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local itemList = skillBag.itemIdList
  local itemInfo = itemList[self.lastSelectedWeaponIndex]
  if skillBag.level < itemInfo.openLevel then
    bLock = true
  end
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  local itemId = itemInfo.id
  local itemBase
  if itemInfo.bItem then
    itemBase = ItemUtils.GetItemBase(itemId)
  else
    itemBase = ItemUtils.GetItemFilterCfg(itemId)
  end
  if itemInfo.bItem then
    if false == bLock then
      ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, false)
    else
      local str = string.format(textRes.Skill[68], skillBag.name, itemInfo.openLevel)
      ItemTipsMgr.Instance():ShowBasicTipsEX(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, false, str)
    end
  elseif false == bLock then
    ItemTipsMgr.Instance():ShowItemFilterTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, false)
  else
    local str = string.format(textRes.Skill[68], skillBag.name, itemInfo.openLevel)
    ItemTipsMgr.Instance():ShowItemFilterTipsEX(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, str, false)
  end
end
def.method("userdata").ShowFoodTips = function(self, clickobj)
  local bLock = false
  local index = tonumber(string.sub(clickobj.name, #"Img_Life_BgIconFood" + 1, -1))
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local itemList = skillBag.itemIdList
  local itemInfo = itemList[index]
  if skillBag.level < itemInfo.openLevel then
    bLock = true
  end
  self.lastSelectedFoodIndex = index
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  local itemId = itemInfo.id
  local itemBase
  if itemInfo.bItem then
    itemBase = ItemUtils.GetItemBase(itemId)
  else
    itemBase = ItemUtils.GetItemFilterCfg(itemId)
  end
  if itemInfo.bItem then
    if false == bLock then
      ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, false)
    else
      local str = string.format(textRes.Skill[68], skillBag.name, itemInfo.openLevel)
      ItemTipsMgr.Instance():ShowBasicTipsEX(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, false, str)
    end
  elseif false == bLock then
    ItemTipsMgr.Instance():ShowItemFilterTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, false)
  else
    local str = string.format(textRes.Skill[68], skillBag.name, itemInfo.openLevel)
    ItemTipsMgr.Instance():ShowItemFilterTipsEX(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, str, false)
  end
end
def.method().OnResetLivingSkill = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not self:CheckResetLivingSkillOpenAndToast() then
    return
  end
  local skillBagList = self:GetBagList()
  local skillBag = skillBagList[self.lastSelectedIndex]
  local resetSkillLevel = LivingSkillUtility.GetLivingSkillConst("LIFESKILL_LEVEL_RESET_TO")
  if resetSkillLevel >= skillBag.level then
    Toast(string.format(textRes.Skill[132], resetSkillLevel))
    return
  end
  require("Main.Skill.ui.ResetLivingSkillConfirmPanel").Instance():ShowPanelWithSkillBag(skillBag)
end
def.method("=>", "boolean").IsReachResetLivingSkillLevel = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return false
  end
  local needLevel = LivingSkillUtility.GetLivingSkillConst("LIFESKILL_LEVEL_RESET_ROLE_LEVEL")
  return needLevel <= heroProp.level
end
def.method("=>", "boolean").IsResetLivingSkillFunctionOpen = function(self)
  local isOpen = _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LIFE_SKILL_RESET)
  return isOpen
end
def.method("=>", "boolean").IsResetLivingSkillOpen = function(self)
  if not self:IsResetLivingSkillFunctionOpen() then
    return false
  end
  if not self:IsReachResetLivingSkillLevel() then
    return false
  end
  return true
end
def.method("=>", "boolean").CheckResetLivingSkillOpenAndToast = function(self)
  if not self:IsResetLivingSkillFunctionOpen() then
    Toast(textRes.Skill[130])
    return false
  end
  if not self:IsReachResetLivingSkillLevel() then
    local needLevel = LivingSkillUtility.GetLivingSkillConst("LIFESKILL_LEVEL_RESET_ROLE_LEVEL")
    Toast(string.format(textRes.Skill[131], needLevel))
    return false
  end
  return true
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Img_Life_BgSkillGroup_") == "Img_Life_BgSkillGroup_" then
    local index = tonumber(string.sub(id, #"Img_Life_BgSkillGroup_" + 1, -1))
    self:OnSkillBagSelected(index)
  elseif "Btn_Left" == id then
    self:OnLeftWeaponSelect()
  elseif "Btn_Right" == id then
    self:OnRightWeaponSelect()
  elseif "Btn_Life_LvUp" == id then
    self:OnLevelUpClick()
  elseif "Img_Life_BgIconWeapon" == id then
    self:ShowWeaponTips(clickobj)
  elseif string.find(id, "Img_Life_BgIconFood") then
    self:ShowFoodTips(clickobj)
  elseif "Btn_Make" == id then
    self:OnMakeItemClick()
  elseif "Btn_ReSet" == id then
    self:OnResetLivingSkill()
  end
end
return LivingSkillNode.Commit()
