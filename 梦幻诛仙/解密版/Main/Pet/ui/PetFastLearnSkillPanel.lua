local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetFastLearnSkillPanel = Lplus.Extend(ECPanelBase, "PetFastLearnSkillPanel")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = PetFastLearnSkillPanel.define
local LearnSource = {
  NONE = 0,
  PETSKILL = 1,
  HUASHENG = 2
}
local SkillBookLevel = {LOW = 0, HIGH = 1}
local SkillBookSmallGroupId = {LOW = 360100020, HIGH = 360100021}
local instance
def.field("table").uiObjs = nil
def.field("userdata").processPetId = nil
def.field("number").selectSkillBookLevel = SkillBookLevel.LOW
def.field("number").curSkillBookPage = 1
def.field("number").maxSkillBookPage = 0
def.field("boolean").skipCommerceConfirm = false
def.field("number").selectedFastLearnSkillBookId = 0
def.field("number").fastLearnSource = LearnSource.NONE
def.field("table").willRepeatSkills = nil
def.static("=>", PetFastLearnSkillPanel).Instance = function()
  if instance == nil then
    instance = PetFastLearnSkillPanel()
  end
  return instance
end
def.method("userdata").ShowFastLearnForPetSkillPanel = function(self, petId)
  if self.m_panel ~= nil and not self.m_panel.isnil then
    return
  end
  self.processPetId = petId
  self.fastLearnSource = LearnSource.PETSKILL
  self:CreatePanel(RESPATH.PREFAB_PS_FASTLEARN, 0)
end
def.method("userdata", "table").ShowFastLearnForPetHuaSheng = function(self, petId, mainPetSkills)
  if self.m_panel ~= nil and not self.m_panel.isnil then
    return
  end
  self.processPetId = petId
  self.fastLearnSource = LearnSource.HUASHENG
  self.willRepeatSkills = mainPetSkills
  self:CreatePanel(RESPATH.PREFAB_HS_FASTLEARN, 2)
  self:SetModal(true)
end
def.method("boolean").SetPanelVisible = function(self, isShow)
  self:Show(isShow)
end
def.method().ClosePanel = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.processPetId = nil
  self.selectSkillBookLevel = SkillBookLevel.LOW
  self.curSkillBookPage = 1
  self.maxSkillBookPage = 0
  self.selectedFastLearnSkillBookId = 0
  self.fastLearnSource = LearnSource.NONE
  self.willRepeatSkills = nil
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetFastLearnSkillPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.COMMERCE_ITEM_PRICE_CHANGE, PetFastLearnSkillPanel.OnSkillBookPriceChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Get_NewOne, PetFastLearnSkillPanel.OnGetNewItem)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LEARN_SKILL_SUCCESS, PetFastLearnSkillPanel.OnPetLearnSkillSuccess)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_FAST_LEARN_SKILL, PetFastLearnSkillPanel.OnPetFastLearnSkill)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowCurrentPageFastLearnSkillBooks()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetFastLearnSkillPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.COMMERCE_ITEM_PRICE_CHANGE, PetFastLearnSkillPanel.OnSkillBookPriceChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Get_NewOne, PetFastLearnSkillPanel.OnGetNewItem)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LEARN_SKILL_SUCCESS, PetFastLearnSkillPanel.OnPetLearnSkillSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_FAST_LEARN_SKILL, PetFastLearnSkillPanel.OnPetFastLearnSkill)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_SkillBook = self.m_panel:FindDirect("Group_SkillBook")
  self.uiObjs.BtnSkipCommerceConfirm = self.uiObjs.Group_SkillBook:FindDirect("Btn_Off")
  self.uiObjs.Btn_Learn = self.uiObjs.Group_SkillBook:FindDirect("Btn_Learn")
  self.uiObjs.Label_Page = self.uiObjs.Group_SkillBook:FindDirect("Group_Page/Img_BgPage/Label_Page")
  GUIUtils.SetText(self.uiObjs.Label_Page, "0/0")
  self.uiObjs.BtnSkipCommerceConfirm:GetComponent("UIToggle").value = self.skipCommerceConfirm
end
def.method().ShowCurrentPageFastLearnSkillBooks = function(self)
  self:UpdateFastLearnSkillBooks()
  self:AjustFastLearnSkillBookPosition()
  self:RefeshCommerce()
end
def.method().ShowNextPageFastLearnSkillBooks = function(self)
  if self.curSkillBookPage >= self.maxSkillBookPage then
    return
  end
  self.curSkillBookPage = self.curSkillBookPage + 1
  self:ShowCurrentPageFastLearnSkillBooks()
end
def.method().ShowPrePageFastLearnSkillBooks = function(self)
  if self.curSkillBookPage <= 1 then
    return
  end
  self.curSkillBookPage = self.curSkillBookPage - 1
  self:ShowCurrentPageFastLearnSkillBooks()
end
def.method().ShowFastLearnHighSkillBooks = function(self)
  self.selectSkillBookLevel = SkillBookLevel.HIGH
  self.curSkillBookPage = 1
  self:ShowCurrentPageFastLearnSkillBooks()
end
def.method().ShowFastLearnLowSkillBooks = function(self)
  self.selectSkillBookLevel = SkillBookLevel.LOW
  self.curSkillBookPage = 1
  self:ShowCurrentPageFastLearnSkillBooks()
end
def.method().UpdateFastLearnSkillBooks = function(self)
  local commerceData = require("Main.CommerceAndPitch.data.CommerceData").Instance()
  local skillBookGroupId = SkillBookSmallGroupId.LOW
  if self.selectSkillBookLevel == SkillBookLevel.HIGH then
    skillBookGroupId = SkillBookSmallGroupId.HIGH
  end
  local bigGroup, smallGroup = commerceData:GetGroupIndexBySmallGroupId(skillBookGroupId)
  local skillBooks, curPage, maxPage, subTypeId = commerceData:GetItemList(bigGroup, smallGroup, self.curSkillBookPage)
  self.curSkillBookPage = curPage
  self.maxSkillBookPage = maxPage
  local ScrollView = self.uiObjs.Group_SkillBook:FindDirect("Scroll View_BgComItem")
  local Grid_BgComItem = ScrollView:FindDirect("Grid_BgComItem")
  local uiList = Grid_BgComItem:GetComponent("UIList")
  uiList.itemCount = #skillBooks
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #skillBooks do
    local item = uiItems[i]
    self:FillFastLearnSkillBookInfo(skillBooks, i, item)
  end
  GUIUtils.SetText(self.uiObjs.Label_Page, string.format("%d/%d", curPage, maxPage))
end
def.method("table", "number", "userdata").FillFastLearnSkillBookInfo = function(self, skillBooks, index, item)
  local Img_BgComItem = item:FindDirect(string.format("Img_BgComItem_%d", index))
  local Texture_ComIcon = Img_BgComItem:FindDirect(string.format("Texture_ComIcon_%d", index))
  local Label_ComItemName = item:FindDirect(string.format("Label_ComItemName_%d", index))
  local Label_ComPrice = item:FindDirect(string.format("Label_ComPrice_%d", index))
  local Label_ItemState = item:FindDirect(string.format("Label_ItemState_%d", index))
  local Group_UpDown = item:FindDirect(string.format("Group_UpDown_%d", index))
  local Img_Arrow = Group_UpDown:FindDirect(string.format("Img_Arrow_%d", index))
  local Img_Equal = Group_UpDown:FindDirect(string.format("Img_Equal_%d", index))
  local Label_Percent = Group_UpDown:FindDirect(string.format("Label_Percent_%d", index))
  local itemId = skillBooks[index]
  local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
  item:GetComponent("UIToggle"):set_isChecked(itemId == self.selectedFastLearnSkillBookId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local eqpBase = require("Main.Equip.EquipUtils").GetEquipMakeMaterialInfo(itemId)
  Label_ComItemName:GetComponent("UILabel"):set_text(itemBase.name)
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  Label_ComItemName:GetComponent("UILabel"):set_textColor(Color.Color(0.56, 0.24, 0.13, 1))
  if eqpBase and (eqpBase.sex == prop.gender and eqpBase.menpai == prop.occupation or eqpBase.sex == gender.ALL and eqpBase.menpai == prop.occupation or eqpBase.sex == prop.gender and eqpBase.menpai == occupation.ALL or eqpBase.sex == gender.ALL and eqpBase.menpai == occupation.ALL) then
    Label_ComItemName:GetComponent("UILabel"):set_textColor(Color.Color(0.22, 0.54, 0.22, 1))
  end
  local commerceData = require("Main.CommerceAndPitch.data.CommerceData").Instance()
  local itemInfo = commerceData:GetItemInfo(itemId)
  if nil == itemInfo then
    Label_ComPrice:GetComponent("UILabel"):set_text("--")
    Img_Equal:SetActive(true)
    Label_Percent:SetActive(false)
    Img_Arrow:SetActive(false)
    return
  end
  Label_ComPrice:GetComponent("UILabel"):set_text(itemInfo.price)
  local extent = itemInfo.rise / 10000 * 100
  extent = tonumber(string.format("%0.2f", extent))
  if extent > 0 then
    Img_Equal:SetActive(false)
    Label_Percent:SetActive(true)
    Img_Arrow:SetActive(true)
    Label_Percent:GetComponent("UILabel"):set_text(math.abs(extent) .. "%")
    CommercePitchUtils.FillIcon("Img_Up", Img_Arrow:GetComponent("UISprite"), 1)
  elseif extent < 0 then
    Img_Equal:SetActive(false)
    Label_Percent:SetActive(true)
    Img_Arrow:SetActive(true)
    Label_Percent:GetComponent("UILabel"):set_text(math.abs(extent) .. "%")
    CommercePitchUtils.FillIcon("Img_Down", Img_Arrow:GetComponent("UISprite"), 1)
  elseif extent == 0 then
    Img_Equal:SetActive(true)
    Label_Percent:SetActive(false)
    Img_Arrow:SetActive(false)
  end
  if self.fastLearnSource == LearnSource.HUASHENG then
    if self:IsSkillRepeatWithPreDefine(itemId) then
      GUIUtils.SetText(Label_ItemState, textRes.Pet[220])
    elseif not self:PetCanLearnSkill(self.processPetId, itemId) then
      GUIUtils.SetText(Label_ItemState, textRes.Pet[221])
    else
      GUIUtils.SetText(Label_ItemState, "")
    end
  end
end
def.method().AjustFastLearnSkillBookPosition = function(self)
  local ScrollView = self.uiObjs.Group_SkillBook:FindDirect("Scroll View_BgComItem")
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if not ScrollView.isnil then
        ScrollView:GetComponent("UIScrollView"):ResetPosition()
      end
    end)
  end)
end
def.method().RefeshCommerce = function(self)
  if self.curSkillBookPage then
    local skillBookGroupId = SkillBookSmallGroupId.LOW
    if self.selectSkillBookLevel == SkillBookLevel.HIGH then
      skillBookGroupId = SkillBookSmallGroupId.HIGH
    end
    local p = require("netio.protocol.mzm.gsp.shanghui.CRefreshShopingListReq").new(skillBookGroupId, self.curSkillBookPage)
    gmodule.network.sendProtocol(p)
    require("Main.CommerceAndPitch.data.CommerceData").Instance():SetOnceFinished(false)
  end
end
def.method().FastLearnSkillForPet = function(self)
  local skillBookId = self.selectedFastLearnSkillBookId
  if skillBookId ~= 0 then
    do
      local level = require("Main.Hero.Interface").GetHeroProp().level
      if level < CommercePitchUtils.GetCommerceOpenLevel() then
        Toast(string.format(textRes.Commerce[17], CommercePitchUtils.GetCommerceOpenLevel()))
        return
      end
      local petId = self.processPetId
      if not self:PetCanLearnSkill(petId, skillBookId) then
        Toast(textRes.Pet[70])
        return
      end
      local commerceData = require("Main.CommerceAndPitch.data.CommerceData").Instance()
      local itemInfo = commerceData:GetItemInfo(skillBookId)
      if not itemInfo then
        CommonConfirmDlg.ShowConfirm("", textRes.Commerce[21], nil, nil)
        return
      end
      local function buyAndLearnSkill()
        local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
        local price = itemInfo.price
        if itemInfo.rise / 10000 < 0.5 and itemInfo.rise / 10000 >= 0.1 then
          local rate = CommercePitchUtils.GetCommerceUpStopBuyRate()
          price = itemInfo.price * rate
        end
        if Int64.lt(gold, price) then
          CommonConfirmDlg.ShowConfirm("", textRes.Commerce.ErrorCode[3], function(result)
            if result == 1 then
              GoToBuyGold(false)
            end
          end, {
            unique = "commercebuy"
          })
          return
        end
        local p = require("netio.protocol.mzm.gsp.shanghui.CBuyItemReq").new(gold, skillBookId, 1)
        gmodule.network.sendProtocol(p)
        Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_FAST_LEARN_SKILL, nil)
      end
      if not self.skipCommerceConfirm then
        local item = ItemUtils.GetItemBase(skillBookId)
        CommonConfirmDlg.ShowConfirm("", string.format(textRes.Pet[193], itemInfo.price, item.name), function(result)
          if result == 1 then
            buyAndLearnSkill()
          end
        end, nil)
      else
        buyAndLearnSkill()
      end
    end
  else
    Toast(textRes.Pet[192])
  end
end
def.method("userdata", "number", "=>", "boolean").PetCanLearnSkill = function(self, petId, skillBookId)
  local skillBookCfg = PetUtility.GetPetSkillBookItemCfg(skillBookId)
  local skillId = skillBookCfg.skillId
  local pet = PetMgr.Instance():GetPet(petId)
  local canStudySkillBook = true
  for i, id in ipairs(pet.skillIdList) do
    if skillId == id then
      canStudySkillBook = false
      break
    end
  end
  return canStudySkillBook
end
def.method("number", "=>", "boolean").IsSkillRepeatWithPreDefine = function(self, skillBookId)
  local skillBookCfg = PetUtility.GetPetSkillBookItemCfg(skillBookId)
  local skillId = skillBookCfg.skillId
  if self.willRepeatSkills == nil then
    return false
  end
  for idx, id in ipairs(self.willRepeatSkills) do
    if skillId == id then
      return true
    end
  end
  return false
end
def.method("table").FastLearnSkillFromBook = function(self, itemParams)
  if self.selectedFastLearnSkillBookId == itemParams.itemId then
    local petId = self.processPetId
    if itemParams.keyList[1] ~= nil then
      PetSkillMgr.Instance():StudySkillBookReq(petId, itemParams.keyList[1])
    else
      warn("no fast learn skillbook")
    end
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.find(id, "Img_BgComItem_") then
    local index = tonumber(string.sub(id, #"Img_BgComItem_" + 1))
    if index ~= nil then
      self:OnSkillBookIconClicked(index, obj)
    end
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_High" then
    self:OnFastLearnHighButtonClicked()
  elseif id == "Btn_Low" then
    self:OnFastLearnLowButtonClicked()
  elseif id == "Btn_Off" then
    self:OnSkipCommerceConfirmClicked()
  elseif string.find(id, "Group_ComItem") then
    self:OnFastLearnSkillBookClicked()
  elseif id == "Btn_Close" then
    self:ClosePanel()
  elseif id == "Btn_Learn" then
    self:OnLearnButtonClicked()
  elseif id == "Btn_Last" then
    self:ShowPrePageFastLearnSkillBooks()
  elseif id == "Btn_Next" then
    self:ShowNextPageFastLearnSkillBooks()
  end
end
def.method().OnFastLearnHighButtonClicked = function(self)
  self:ShowFastLearnHighSkillBooks()
end
def.method().OnFastLearnLowButtonClicked = function(self)
  self:ShowFastLearnLowSkillBooks()
end
def.method().OnSkipCommerceConfirmClicked = function(self)
  self.skipCommerceConfirm = self.uiObjs.BtnSkipCommerceConfirm:GetComponent("UIToggle").value
end
def.method().OnFastLearnSkillBookClicked = function(self)
  self.selectedFastLearnSkillBookId = self:GetSelectedFastLearnSkillBookId()
end
def.method("number", "userdata").OnSkillBookIconClicked = function(self, index, source)
  local commerceData = require("Main.CommerceAndPitch.data.CommerceData").Instance()
  local skillBookGroupId = SkillBookSmallGroupId.LOW
  if self.selectSkillBookLevel == SkillBookLevel.HIGH then
    skillBookGroupId = SkillBookSmallGroupId.HIGH
  end
  local bigGroup, smallGroup = commerceData:GetGroupIndexBySmallGroupId(skillBookGroupId)
  local skillBooks, curPage, maxPage, subTypeId = commerceData:GetItemList(bigGroup, smallGroup, self.curSkillBookPage)
  if skillBooks ~= nil then
    local skillBookId = skillBooks[index]
    if skillBookId ~= nil then
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(skillBookId, source, 0, false)
    end
  end
end
def.method("=>", "number").GetSelectedFastLearnSkillBookId = function(self)
  local selectedIndex = 0
  local ScrollView = self.uiObjs.Group_SkillBook:FindDirect("Scroll View_BgComItem")
  local Grid_BgComItem = ScrollView:FindDirect("Grid_BgComItem")
  local uiList = Grid_BgComItem:GetComponent("UIList")
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local item = uiItems[i]
    if item:GetComponent("UIToggle").value then
      selectedIndex = i
    end
  end
  local commerceData = require("Main.CommerceAndPitch.data.CommerceData").Instance()
  local skillBookGroupId = SkillBookSmallGroupId.LOW
  if self.selectSkillBookLevel == SkillBookLevel.HIGH then
    skillBookGroupId = SkillBookSmallGroupId.HIGH
  end
  local bigGroup, smallGroup = commerceData:GetGroupIndexBySmallGroupId(skillBookGroupId)
  local skillBooks, curPage, maxPage, subTypeId = commerceData:GetItemList(bigGroup, smallGroup, self.curSkillBookPage)
  if skillBooks[selectedIndex] ~= nil then
    return skillBooks[selectedIndex]
  end
  return 0
end
def.method().OnLearnButtonClicked = function(self)
  self:FastLearnSkillForPet()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:UpdateFastLearnSkillBooks()
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
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local self = instance
  if self ~= nil then
    self:UpdateFastLearnSkillBooks()
  end
end
def.static("table", "table").OnSkillBookPriceChange = function(params, context)
  local self = instance
  if self == nil then
    return
  end
  self:UpdateFastLearnSkillBooks()
end
def.static("table", "table").OnPetLearnSkillSuccess = function(params, context)
  local petId = params.petId
  if petId ~= instance.processPetId then
    return
  end
  instance:EnableLearnSkillBtn()
end
def.static("table", "table").OnPetFastLearnSkill = function(params, context)
  instance:DisableLearnSkillBtn()
end
def.static("table", "table").OnGetNewItem = function(params, context)
  local self = instance
  if self == nil then
    return
  end
  if params.bagId == ItemModule.BAG then
    self:FastLearnSkillFromBook(params)
  end
end
return PetFastLearnSkillPanel.Commit()
