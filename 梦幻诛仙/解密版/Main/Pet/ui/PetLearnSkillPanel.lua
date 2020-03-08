local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetLearnSkillPanel = Lplus.Extend(ECPanelBase, "PetLearnSkillPanel")
local def = PetLearnSkillPanel.define
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetData = Lplus.ForwardDeclare("PetData")
local PetUtility = require("Main.Pet.PetUtility")
local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local EasyItemTipHelper = require("Main.Pet.EasyItemTipHelper")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local PetFastLearnSkillPanel = require("Main.Pet.ui.PetFastLearnSkillPanel")
local instance
def.field("userdata").petId = nil
def.field("number").skillIndex = 0
def.field("number").selectedSkillId = 0
def.field("boolean").canRemember = false
def.field("boolean").canUnremember = false
def.field("number").selectedItemIndex = 0
def.field("table").itemList = nil
def.field("boolean").isFastLearnSkill = false
def.field(PetFastLearnSkillPanel).fastLearnSkillPanel = nil
def.field(EasyItemTipHelper).easyItemTipHelper = nil
def.field("table").uiObjs = nil
def.static("=>", PetLearnSkillPanel).Instance = function()
  if instance == nil then
    instance = PetLearnSkillPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_LEARN_SKILL_PANEL_RES, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
  self:Clear()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.easyItemTipHelper = EasyItemTipHelper()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REMEMBERED_SKILL_SUCCESS, PetLearnSkillPanel.OnPetRememberedSkillSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_UNREMEMBERED_SKILL_SUCCESS, PetLearnSkillPanel.OnPetUnrememberedSkillSuccess)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetLearnSkillPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetLearnSkillPanel.OnPetInfoUpdate)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LEARN_SKILL_SUCCESS, PetLearnSkillPanel.OnPetLearnSkillSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetLearnSkillPanel.OnPetYaoLiChange)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_FAST_LEARN_SKILL, PetLearnSkillPanel.OnPetFastLearnSkill)
  self:Fill()
  self:SelectSkill(1)
end
def.override("boolean").OnShow = function(self, s)
  if self.isFastLearnSkill and self.fastLearnSkillPanel ~= nil then
    self.fastLearnSkillPanel:SetPanelVisible(s)
  end
  if s == false then
    return
  end
  self:UpdatePetSkillBooks()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REMEMBERED_SKILL_SUCCESS, PetLearnSkillPanel.OnPetRememberedSkillSuccess)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_UNREMEMBERED_SKILL_SUCCESS, PetLearnSkillPanel.OnPetUnrememberedSkillSuccess)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetLearnSkillPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetLearnSkillPanel.OnPetInfoUpdate)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LEARN_SKILL_SUCCESS, PetLearnSkillPanel.OnPetLearnSkillSuccess)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetLearnSkillPanel.OnPetYaoLiChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_FAST_LEARN_SKILL, PetLearnSkillPanel.OnPetFastLearnSkill)
  self:Clear()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Img_BgPower = self.uiObjs.Img_Bg0:FindDirect("Img_BgPower")
  self.uiObjs.Img_Bg1 = self.uiObjs.Img_Bg0:FindDirect("Img_Bg1")
  self.uiObjs.Img_BgSkill = self.uiObjs.Img_Bg1:FindDirect("Img_BgSkill")
  self.uiObjs.Gride_ItemSkill = self.uiObjs.Img_BgSkill:FindDirect("Gride_ItemSkill")
  self.uiObjs.Group_Remember = self.uiObjs.Img_BgSkill:FindDirect("Group_Remember")
  self.uiObjs.Group_Remove = self.uiObjs.Img_BgSkill:FindDirect("Group_Remove")
  self.uiObjs.fxObj = self.m_panel:FindDirect("UI_Panel_PetSkill_ChongWuDaShu")
  self.uiObjs.Group_Bag = self.uiObjs.Img_Bg1:FindDirect("Group_Bag")
  self.uiObjs.Group_Empty = self.uiObjs.Group_Bag:FindDirect("Group_Empty")
  self.uiObjs.Group_Bag2 = self.uiObjs.Group_Bag:FindDirect("Group_Bag")
  self.uiObjs.Btn_FastLearn = self.uiObjs.Group_Bag:FindDirect("Btn_FastLearn")
  self.uiObjs.Img_BgBag = self.uiObjs.Group_Bag2:FindDirect("Img_BgBag")
  self.uiObjs.Gride_Bag = self.uiObjs.Img_BgBag:FindDirect("Scroll View/Gride_Bag")
  self.uiObjs.Btn_Learn = self.uiObjs.Group_Bag:FindDirect("Btn_Learn")
  local template = self.uiObjs.Gride_Bag:FindDirect("Img_Item01")
  template.name = "Img_Item_0"
  template:GetComponent("UIToggle").group = 17
  template:GetComponent("UIToggle").optionCanBeNone = true
  template:SetActive(false)
  self.uiObjs.GridItemTemplate = template
  self.uiObjs.Group_Bag:FindDirect("Btn_Tips").name = "Btn_LearnTips"
end
def.method().Clear = function(self)
  self.easyItemTipHelper = nil
  self.uiObjs = nil
  self.itemList = nil
  self.selectedSkillId = 0
  self.selectedItemIndex = 0
  self.skillIndex = 0
  self.canRemember = false
  self.isFastLearnSkill = false
  if self.fastLearnSkillPanel ~= nil then
    self.fastLearnSkillPanel:ClosePanel()
    self.fastLearnSkillPanel = nil
  end
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Remember" then
    self:OnRememberButtonClick()
  elseif id == "Btn_Remove" then
    self:OnUnrememberButtonClick()
  elseif string.sub(id, 1, 13) == "Img_ItemSkill" then
    local index = tonumber(string.sub(id, -2, -1))
    self:OnSkillItemClick(index)
  elseif string.sub(id, 1, #"Img_Item_") == "Img_Item_" then
    local index = tonumber(string.sub(id, #"Img_Item_" + 1, -1))
    self:OnSkillBookItemClick(index)
  elseif id == "Btn_Channel" then
    self:OnRequirePetSkillBookSource()
  elseif id == "Btn_Learn" then
    self:OnLearnSkillButtonClicked()
  elseif id == "Btn_RememberTips" then
    self:OnRememberTipClicked()
  elseif id == "Btn_LearnTips" then
    self:OnLearnSkillTipClicked()
  elseif id == "Btn_Promote" then
    self:OnPromoteButtonClicked()
  elseif id == "Btn_FastLearn" then
    self:OnFastLearnButtonClicked()
  elseif self.easyItemTipHelper:CheckItem2ShowTip(id) then
  end
end
def.method("string", "boolean").onToggle = function(self, id, isActive)
  if string.sub(id, 1, -3) == "Img_ItemSkill" then
    self:OnSkillItemToggle(id, isActive)
  else
  end
end
def.method("userdata").SetActivePet = function(self, petId)
  self.petId = petId
end
def.method().OnRememberButtonClick = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet.rememberedSkillId ~= PetData.NOT_SET then
    Toast(textRes.Pet[10])
    return
  end
  if self.canRemember then
    PetModule.Instance():RememberSkill(self.petId, self.selectedSkillId, {})
  else
    Toast(textRes.Pet[63])
  end
end
def.method().OnUnrememberButtonClick = function(self)
  if self.canUnremember then
    PetSkillMgr.Instance():UnrememberSkill(self.petId, self.selectedSkillId)
  else
    Toast(textRes.Pet[23])
  end
end
def.method("number").OnSkillItemClick = function(self, index)
  self:SelectSkill(index)
  local pet = PetMgr.Instance():GetPet(self.petId)
  local skillId = pet.skillIdList[index]
  if skillId == nil then
    return
  end
  local sourceObj = self.uiObjs.Gride_ItemSkill:FindDirect(string.format("Img_ItemSkill%02d", 4))
  local context = {
    pet = pet,
    skill = {id = skillId, isOwnSkill = true},
    needRemember = true
  }
  PetUtility.ShowPetSkillTipEx(skillId, pet.level, sourceObj, 0, context)
end
def.method("number").SelectSkill = function(self, index)
  local pet = PetMgr.Instance():GetPet(self.petId)
  self.skillIndex = index
  self:UnSelectSkillBook()
  local sourceObj = self.uiObjs.Gride_ItemSkill:FindDirect(string.format("Img_ItemSkill%02d", index))
  sourceObj:GetComponent("UIToggle").value = true
end
def.method("string", "boolean").OnSkillItemToggle = function(self, id, isActive)
  if not isActive then
    return
  end
  local index = tonumber(string.sub(id, -2, -1))
end
def.method().Fill = function(self)
  self:UpdatePetYaoLi()
  self:UpdateSkillList()
  local grid = self.uiObjs.Gride_ItemSkill:GetComponent("UIGrid")
  local gridItemCount = grid:GetChildListCount()
  local gridChildList = grid:GetChildList()
  for i = 1, gridItemCount do
    if i == 1 then
      gridChildList[i].gameObject:GetComponent("UIToggle"):set_value(true)
    else
      gridChildList[i].gameObject:GetComponent("UIToggle"):set_value(false)
    end
  end
  self:UpdatePetSkillBooks()
end
def.method().UpdatePetYaoLi = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  PetUtility.SetYaoLiUIFromPet(self.uiObjs.Img_BgPower, pet)
end
def.method().UpdateSkillList = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  local grid = self.uiObjs.Gride_ItemSkill:GetComponent("UIGrid")
  local gridItemCount = grid:GetChildListCount()
  local gridChildList = grid:GetChildList()
  for i = 1, gridItemCount do
    local skillId = pet.skillIdList[i]
    local objIndex = string.format("%02d", i)
    if skillId then
      local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
      local uiTexture = gridChildList[i].gameObject:FindDirect("Icon_ItemSkillIcon" .. objIndex):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, skillCfg.iconId)
      PetUtility.SetPetSkillBgColor(gridChildList[i].gameObject, skillId)
      if pet.rememberedSkillId == skillId then
        gridChildList[i].gameObject:FindDirect("Img_Sign"):SetActive(true)
      else
        gridChildList[i].gameObject:FindDirect("Img_Sign"):SetActive(false)
      end
    else
      local uiTexture = gridChildList[i].gameObject:FindDirect("Icon_ItemSkillIcon" .. objIndex):GetComponent("UITexture")
      uiTexture.mainTexture = nil
      PetUtility.SetOriginPetSkillBg(gridChildList[i].gameObject, "Img_SkillFg")
    end
  end
  self:UpdateRememberSkillInfo()
end
def.method().UpdateRememberSkillInfo = function(self)
  self.uiObjs.Group_Remember:SetActive(false)
  self.uiObjs.Group_Remove:SetActive(false)
end
def.method().SetRememberNeed = function(self)
  local itemType = require("consts.mzm.gsp.item.confbean.ItemType").PET_REMEBER_SKILL_ITEM
  local ItemModule = require("Main.Item.ItemModule")
  local itemId = PetUtility.Instance():GetPetConstants("PET_REMEBER_SKILL_ITEM_ID")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, itemType)
  local count = 0
  for k, v in pairs(items) do
    count = count + v.number
  end
  local itemNum = count
  local USE_ITEM_NUM = PetModule.PET_REMEMBER_SKILL_USE_ITEM_NUM
  print("itemType:", itemType, "itemNum: ", itemNum)
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
  local iconId = itemBase.icon
  local Img_Item = self.uiObjs.Group_Remember:FindDirect("Img_Item")
  local numText
  if itemNum >= USE_ITEM_NUM then
    self.canRemember = true
    numText = textRes.Common[12]
  else
    self.canRemember = false
    numText = textRes.Common[11]
  end
  Img_Item:FindDirect("Label_ItemNum"):GetComponent("UILabel"):set_text(string.format(numText, itemNum, USE_ITEM_NUM))
  local uiTexture = Img_Item:FindDirect("Icon_Item"):GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, iconId)
  local clickedObj = uiTexture.gameObject.transform.parent.gameObject
  self.easyItemTipHelper:RegisterItem2ShowTip(itemId, clickedObj)
end
def.method().SetUnrememberNeed = function(self)
  local costSilver = PetUtility.Instance():GetPetConstants("PET_UNREMEMBER_SKILL_COST_SILVER")
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  local Label_CostNum = self.uiObjs.Group_Remove:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel")
  Label_CostNum:set_text(costSilver)
  self.uiObjs.Group_Remove:FindDirect("Label_Have/Img_BgHave/Label_HaveNum"):GetComponent("UILabel"):set_text(tostring(moneySilver))
  if moneySilver:lt(costSilver) then
    self.canUnremember = false
    Label_CostNum:set_color(Color.red)
  else
    self.canUnremember = true
    Label_CostNum:set_color(Color.white)
  end
end
def.method().UpdatePetSkillBooks = function(self)
  if not self.isFastLearnSkill then
    local items = PetMgr.Instance():GetPetSkillBooks()
    self.itemList = items
    if #self.itemList > 0 then
      self:ShowPetSkillBookBag(self.itemList)
      self:RefreshSelectedItemIndex()
    else
      self:ShowSkillBookSourceInfo()
    end
  else
    self.uiObjs.Group_Empty:SetActive(false)
    self.uiObjs.Group_Bag2:SetActive(false)
  end
end
def.method("table").ShowPetSkillBookBag = function(self, items)
  self.uiObjs.Group_Empty:SetActive(false)
  self.uiObjs.Group_Bag2:SetActive(true)
  self:ResizeItemBagGrid(#items)
  for i, item in pairs(items) do
    self:SetItemBagItem(i, item)
  end
end
def.method("number").ResizeItemBagGrid = function(self, count)
  local uiGrid = self.uiObjs.Gride_Bag:GetComponent("UIGrid")
  local gridItemCount = uiGrid:GetChildListCount()
  if count > gridItemCount then
    for i = gridItemCount + 1, count do
      local gridItem = GameObject.Instantiate(self.uiObjs.GridItemTemplate)
      gridItem.name = "Img_Item_" .. i
      gridItem.transform.parent = self.uiObjs.Gride_Bag.transform
      gridItem.transform.localScale = Vector.Vector3.one
      gridItem:SetActive(true)
    end
  elseif count < gridItemCount then
    for i = gridItemCount, count + 1, -1 do
      local gridItem = self.uiObjs.Gride_Bag:FindDirect("Img_Item_" .. i)
      gridItem.transform.parent = nil
      GameObject.Destroy(gridItem)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  uiGrid:Reposition()
end
def.method("number", "table").SetItemBagItem = function(self, index, item)
  local gridItem = self.uiObjs.Gride_Bag:FindDirect("Img_Item_" .. index)
  local itemNum = item.number
  if itemNum == 0 then
    itemNum = ""
  end
  GUIUtils.SetText(gridItem:FindDirect("Label_Num"), item.number)
  local bang = gridItem:FindDirect("Img_Bang")
  local zhuan = gridItem:FindDirect("Img_Zhuan")
  local rarity = gridItem:FindDirect("Img_Xiyou")
  local itemBase = ItemUtils.GetItemBase(item.id)
  if bang and zhuan then
    if itemBase.isProprietary then
      bang:SetActive(false)
      zhuan:SetActive(true)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsItemBind(item) then
      bang:SetActive(true)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsRarity(item.id) then
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, true)
    else
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    end
  end
  local itemBase = ItemUtils.GetItemBase(item.id)
  local iconId = itemBase.icon
  local uiTexture = gridItem:FindDirect("Icon_ItemIcon01"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
end
def.method().ShowSkillBookSourceInfo = function(self)
  self.uiObjs.Group_Empty:SetActive(true)
  self.uiObjs.Group_Bag2:SetActive(false)
end
def.method().OnRequirePetSkillBookSource = function(self)
  self:ShowSkillBookSource()
end
def.method().OnLearnSkillButtonClicked = function(self)
  local hasShow = self:ShowFirstTimeUseGuide()
  if hasShow then
    if not self.isFastLearnSkill then
      self:LearnSkillFromBook()
    elseif self.fastLearnSkillPanel ~= nil then
      self.fastLearnSkillPanel:FastLearnSkillForPet()
    end
  end
end
def.method().LearnSkillFromBook = function(self)
  local items = PetMgr.Instance():GetPetSkillBooks()
  if #items == 0 then
    Toast(textRes.Pet[102])
    return
  end
  if self.selectedItemIndex == 0 then
    Toast(textRes.Pet[101])
    return
  end
  local item = self.itemList[self.selectedItemIndex]
  self:UsePetSkillBook(item.itemKey)
end
def.method("=>", "boolean").ShowFirstTimeUseGuide = function(self)
  if not PetMgr.Instance():IsFirstTimeLearnSkill() then
    return true
  end
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet[131], textRes.Pet[132], function(s, tag)
    PetMgr.Instance():MarkLearnSkillTipAsReaded()
    if s == 1 then
      if not self.isFastLearnSkill then
        self:LearnSkillFromBook()
      elseif self.fastLearnSkillPanel ~= nil then
        self.fastLearnSkillPanel:FastLearnSkillForPet()
      end
    end
  end, nil)
  return false
end
def.method("number").UsePetSkillBook = function(self, itemKey)
  local petId = self.petId
  local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr")
  local ItemModule = require("Main.Item.ItemModule")
  local skillBook = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
  local skillBookCfg = PetUtility.GetPetSkillBookItemCfg(skillBook.id)
  local skillId = skillBookCfg.skillId
  local pet = PetMgr.Instance():GetPet(petId)
  local canStudySkillBook = true
  for i, id in ipairs(pet.skillIdList) do
    if skillId == id then
      canStudySkillBook = false
      break
    end
  end
  if canStudySkillBook then
    self:DisableLearnSkillBtn()
    PetSkillMgr.Instance():StudySkillBookReq(petId, itemKey)
  else
    Toast(textRes.Pet[70])
  end
end
def.method().DisableLearnSkillBtn = function(self)
  if self.uiObjs.Btn_Learn ~= nil then
    self.uiObjs.Btn_Learn:GetComponent("UIButton"):set_isEnabled(false)
  end
end
def.method().EnableLearnSkillBtn = function(self)
  if self.uiObjs.Btn_Learn ~= nil then
    self.uiObjs.Btn_Learn:GetComponent("UIButton"):set_isEnabled(true)
  end
end
def.method("number").OnSkillBookItemClick = function(self, index)
  local item = self.itemList[index]
  if item == nil then
    return
  end
  self:UnSelectSkill()
  self.selectedItemIndex = index
  self:ShowItemTip(index)
  GUIUtils.Toggle(self.uiObjs.Gride_Bag:FindDirect("Img_Item_" .. index), true)
end
def.method().UnSelectSkillBook = function(self)
  local index = self.selectedItemIndex
  self.uiObjs.Gride_Bag:FindDirect("Img_Item_" .. index):GetComponent("UIToggle"):set_value(false)
  self.selectedItemIndex = 0
end
def.method().UnSelectSkill = function(self)
  local grid = self.uiObjs.Gride_ItemSkill:GetComponent("UIGrid")
  local gridItemCount = grid:GetChildListCount()
  local gridChildList = grid:GetChildList()
  for i = 1, gridItemCount do
    gridChildList[i].gameObject:GetComponent("UIToggle").optionCanBeNone = true
    gridChildList[i].gameObject:GetComponent("UIToggle").value = false
  end
  self.selectedSkillId = 0
end
def.method("number").ShowItemTip = function(self, index)
  local item = self.itemList[index]
  if item == nil then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local sourceObj = self.uiObjs.Img_BgBag
  local itemId = item.id
  local itemKey = item.itemKey
  local source = self.uiObjs.Img_BgBag
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local tip = ItemTipsMgr.Instance():ShowTips(item, 0, itemKey, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
end
def.method().ShowSkillBookSource = function(self)
  local sourceObj = self.uiObjs.Group_Empty:FindDirect("Btn_Channel")
  local sourceItemId = PetMgr.SKILL_BOOK_SOURCE_ITEM_ID
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local ItemAccessMgr = require("Main.Item.ItemAccessMgr")
  local tip = ItemAccessMgr.Instance():ShowSource(sourceItemId, 207, 153, 0, 0, 0)
end
def.method().RefreshSelectedItemIndex = function(self)
  if self.selectedItemIndex == 0 then
    return
  end
  local itemCount = #self.itemList
  if itemCount < self.selectedItemIndex then
    self.selectedItemIndex = itemCount
  end
  self:UpdateSelectedItemIndex()
end
def.method().UpdateSelectedItemIndex = function(self)
  local index = self.selectedItemIndex
  local Img_Item = self.uiObjs.Gride_Bag:FindDirect("Img_Item_" .. index)
  Img_Item:GetComponent("UIToggle"):set_value(true)
  self:ShowItemTip(index)
end
def.method().OnRememberTipClicked = function(self)
  local tipId = PetUtility.Instance():GetPetConstants("MINGJI_TIPS")
  require("GUI.GUIUtils").ShowHoverTip(tipId)
end
def.method().OnLearnSkillTipClicked = function(self)
  local tipId = PetUtility.Instance():GetPetConstants("LEAN_SKILL_TIPS")
  require("GUI.GUIUtils").ShowHoverTip(tipId)
end
def.static("table", "table").OnPetRememberedSkillSuccess = function(params)
  local self = instance
  self:UpdateSkillList()
end
def.static("table", "table").OnPetUnrememberedSkillSuccess = function(params)
  local self = instance
  self:UpdateSkillList()
end
def.method("number").PlayFxOnSkill = function(self, skillId)
  local pet = PetMgr.Instance():GetPet(self.petId)
  local index = 0
  for i, id in ipairs(pet.skillIdList) do
    if id == skillId then
      index = i
      break
    end
  end
  if index == 0 then
    warn("no satisfied skill", debug.traceback())
    return
  end
  local targetObj = self.uiObjs.Gride_ItemSkill:FindDirect(string.format("Img_ItemSkill%02d", index))
  warn(targetObj, self.uiObjs.fxObj)
  if targetObj and self.uiObjs.fxObj then
    self.uiObjs.fxObj.transform.parent = targetObj.transform
    self.uiObjs.fxObj.transform.localPosition = Vector.Vector3.zero
    self.uiObjs.fxObj:SetActive(false)
    self.uiObjs.fxObj:SetActive(true)
  end
end
def.method().OnPromoteButtonClicked = function(self)
  PetUtility.OpenPetBianqingDlg()
end
def.method().OnFastLearnButtonClicked = function(self)
  self:ToggleFastLearnSkill()
end
def.method().ToggleFastLearnSkill = function(self)
  self.isFastLearnSkill = not self.isFastLearnSkill
  self:UpdateFastLearnSkillView()
  if self.isFastLearnSkill then
    self:ShowFastLearnSkillBooks()
  else
    self:HideFastLearnSkillBooks()
  end
end
def.method().UpdateFastLearnSkillView = function(self)
  if self.isFastLearnSkill then
    GUIUtils.SetText(self.uiObjs.Btn_FastLearn:FindDirect("Label_Learn"), textRes.Pet[191])
  else
    GUIUtils.SetText(self.uiObjs.Btn_FastLearn:FindDirect("Label_Learn"), textRes.Pet[190])
  end
  self:UpdatePetSkillBooks()
end
def.method().ShowFastLearnSkillBooks = function(self)
  if self.fastLearnSkillPanel == nil then
    self.fastLearnSkillPanel = require("Main.Pet.ui.PetFastLearnSkillPanel").Instance()
    self.fastLearnSkillPanel:ShowFastLearnForPetSkillPanel(self.petId)
  else
    self.fastLearnSkillPanel:SetPanelVisible(true)
  end
end
def.method().HideFastLearnSkillBooks = function(self)
  if self.fastLearnSkillPanel ~= nil then
    self.fastLearnSkillPanel:SetPanelVisible(false)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  if instance:IsShow() then
    instance:UpdatePetSkillBooks()
  end
  instance:UpdateRememberSkillInfo()
end
def.static("table", "table").OnPetInfoUpdate = function(params, context)
  local petId = params[1]
  if petId ~= instance.petId then
    return
  end
  instance:UpdateSkillList()
end
def.static("table", "table").OnPetLearnSkillSuccess = function(params, context)
  local petId = params.petId
  if petId ~= instance.petId then
    return
  end
  instance:PlayFxOnSkill(params.skillId)
  instance:EnableLearnSkillBtn()
end
def.static("table", "table").OnPetYaoLiChange = function(params, context)
  local self = instance
  if self.petId ~= params.petId then
    return
  end
  local pet = PetMgr.Instance():GetPet(params.petId)
  local Img_BgPower = self.uiObjs.Img_BgPower
  PetUtility.TweenYaoLiUIFromPet(Img_BgPower, pet, params)
end
def.static("table", "table").OnPetFastLearnSkill = function(params, context)
  local self = instance
  if self == nil then
    return
  end
  self:DisableLearnSkillBtn()
end
def.method("string", "boolean").onPress = function(self, id, state)
  if id == "Img_BgPower" then
    self:OnYaoLiPress(state)
  end
end
def.method("boolean").OnYaoLiPress = function(self, state)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local position = UICamera.lastWorldPosition
  local screenPos = WorldPosToScreen(position.x, position.y)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTip(textRes.Pet[139], screenPos.x, screenPos.y, 10, 10, -1)
end
return PetLearnSkillPanel.Commit()
