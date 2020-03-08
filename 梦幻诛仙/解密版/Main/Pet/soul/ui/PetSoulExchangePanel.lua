local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PetSoulMgr = require("Main.Pet.soul.PetSoulMgr")
local PetSoulUtils = require("Main.Pet.soul.PetSoulUtils")
local PetSoulData = require("Main.Pet.soul.data.PetSoulData")
local PetSoulPos = require("consts.mzm.gsp.petsoul.confbean.PetSoulPos")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetSoulProtocols = require("Main.Pet.soul.PetSoulProtocols")
local PetUtility = require("Main.Pet.PetUtility")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local PetSoulExchangePanel = Lplus.Extend(ECPanelBase, "PetSoulExchangePanel")
local def = PetSoulExchangePanel.define
local instance
def.static("=>", PetSoulExchangePanel).Instance = function()
  if instance == nil then
    instance = PetSoulExchangePanel()
  end
  return instance
end
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("table")._uiObjs = nil
def.field("table")._petLeft = nil
def.field("table")._petRight = nil
def.field("boolean")._bUseYB = false
def.field("number")._useYuanBaoNum = 0
def.static().ShowPanel = function()
  if not PetSoulMgr.Instance():IsOpen(true) then
    if PetSoulExchangePanel.Instance():IsShow() then
      PetSoulExchangePanel.Instance():DestroyPanel()
    end
    return
  end
  PetSoulExchangePanel.Instance():CreatePanel(RESPATH.PREFAB_PET_SOUL_EXCHANGE_PANEL, 1)
end
def.override().OnCreate = function(self)
  self.itemTipHelper = EasyBasicItemTip()
  self:SetModal(false)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Up = self.m_panel:FindDirect("Label_Up")
  self._uiObjs.Group_Left = self.m_panel:FindDirect("Img_Bg/Img_BgL")
  self._uiObjs.Group_Right = self.m_panel:FindDirect("Img_Bg/Img_BgR")
  self._uiObjs.costItemGroup = self.m_panel:FindDirect("Img_Bg/Img_PropItem")
  self._uiObjs.Icon_Item = self._uiObjs.costItemGroup:FindDirect("Icon_EquipMakeItem")
  self._uiObjs.Img_Bg = self._uiObjs.costItemGroup:FindDirect("Img_Bg")
  self._uiObjs.Label_ItemNum = self._uiObjs.costItemGroup:FindDirect("Label_EquipMakeItem")
  self._uiObjs.Label_ItemName = self._uiObjs.costItemGroup:FindDirect("Label_EquipMakeName")
  self._uiObjs.Btn_YuanbaoUse = self.m_panel:FindDirect("Img_Bg/Btn_YuanbaoUse")
  self._uiObjs.Label_Confirm = self.m_panel:FindDirect("Img_Bg/Btn_Confirm/Label_Confirm")
  self._uiObjs.Group_RandomYB = self.m_panel:FindDirect("Img_Bg/Btn_Confirm/Group_Icon")
  self._uiObjs.Label_RandomYB = self._uiObjs.Group_RandomYB:FindDirect("Label_Confirm")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:ShowExchangeTip()
    self:UpdateUI()
  else
  end
end
def.method().ShowExchangeTip = function(self)
  local tipId = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_TIP")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  GUIUtils.SetText(self._uiObjs.Label_Up, tipContent)
end
def.method().UpdateUI = function(self)
  self:ShowPet(self._petLeft, self._uiObjs.Group_Left)
  self:ShowPet(self._petRight, self._uiObjs.Group_Right)
  self:ShowCostItem()
  self:UpdateRandomState(self._bUseYB)
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self.itemTipHelper = nil
  self._petLeft = nil
  self._petRight = nil
  self._bUseYB = false
  self._useYuanBaoNum = 0
end
def.method("table", "userdata").ShowPet = function(self, pet, group)
  if nil == group then
    warn("[ERROR][PetSoulExchangePanel:ShowPet] group nil!")
    return
  end
  local Group_ChoosePet = group:FindDirect("Img_Bg_Pet/Label_ChoosePet")
  local Group_PetInfo = group:FindDirect("Img_Bg_Pet/Img_Selected_Pet01")
  local Group_Soul = group:FindDirect("Sprite_ExchangeNum")
  if pet then
    GUIUtils.SetActive(Group_ChoosePet, false)
    GUIUtils.SetActive(Group_Soul, true)
    GUIUtils.SetActive(Group_PetInfo, true)
    local Icon_Pet = Group_PetInfo:FindDirect("Img_HS_IconPet01")
    GUIUtils.SetTexture(Icon_Pet, pet:GetHeadIconId())
    local Label_PetName = Group_PetInfo:FindDirect("Label_PetName")
    GUIUtils.SetText(Label_PetName, pet.name)
    local Label_PetLv01 = Group_PetInfo:FindDirect("Label_PetLv01")
    GUIUtils.SetText(Label_PetLv01, string.format(textRes.Common[3], pet.level))
    local Img_BgPower = Group_PetInfo:FindDirect("Img_BgPower")
    PetUtility.SetYaoLiUIFromPet(Img_BgPower, pet)
    PetSoulUtils.ShowPetSoul(pet, Group_Soul, false)
  else
    GUIUtils.SetActive(Group_ChoosePet, true)
    GUIUtils.SetActive(Group_Soul, false)
    GUIUtils.SetActive(Group_PetInfo, false)
  end
end
def.method().ShowCostItem = function(self)
  local itemId = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_SUM_ITEM")
  local need = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_ITEM_COUNT")
  local itemBase = ItemUtils.GetItemBase(itemId)
  if not itemBase then
    warn("[ERROR][PetSoulExchangePanel:ShowCostItem] itemBase nil for id ", itemId)
    return
  end
  GUIUtils.SetTexture(self._uiObjs.Icon_Item, itemBase.icon)
  GUIUtils.SetSprite(self._uiObjs.Img_Bg, string.format("Cell_%02d", itemBase.namecolor))
  local count = ItemModule.Instance():GetItemCountById(itemId)
  local textColor = need <= count and Color.green or Color.red
  GUIUtils.SetTextAndColor(self._uiObjs.Label_ItemNum, count .. "/" .. need, textColor)
  GUIUtils.SetText(self._uiObjs.Label_ItemName, itemBase.name)
  self.itemTipHelper:RegisterItem2ShowTip(itemId, self._uiObjs.costItemGroup)
end
def.method("boolean").UpdateRandomState = function(self, bUseYB)
  self._bUseYB = bUseYB
  GUIUtils.Toggle(self._uiObjs.Btn_YuanbaoUse, self._bUseYB)
  if self._bUseYB then
    GUIUtils.SetActive(self._uiObjs.Label_Confirm, false)
    GUIUtils.SetActive(self._uiObjs.Group_RandomYB, true)
    local itemId = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_SUM_ITEM")
    local need = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_ITEM_COUNT")
    local count = ItemModule.Instance():GetItemCountById(itemId)
    local lackCount = math.max(0, need - count)
    self._useYuanBaoNum = self:GetCostItemPrice(lackCount)
    GUIUtils.SetText(self._uiObjs.Label_RandomYB, self._useYuanBaoNum)
  else
    GUIUtils.SetActive(self._uiObjs.Label_Confirm, true)
    GUIUtils.SetActive(self._uiObjs.Group_RandomYB, false)
    self._useYuanBaoNum = 0
  end
end
def.method("number", "=>", "number").GetCostItemPrice = function(self, count)
  local MallUtility = require("Main.Mall.MallUtility")
  local costItemId = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_MAIN_ITEM")
  local price = MallUtility.GetPriceByItemId(costItemId)
  warn("[PetSoulExchangePanel:GetCostItemPrice] price for item, lackCount:", price, costItemId, count)
  return price * count
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Question" then
    self:OnBtn_Tips()
  elseif id == "Btn_Confirm" then
    self:OnBtn_Confirm()
  elseif id == "Btn_YuanbaoUse" then
    self:OnBtn_YuanbaoUse()
  elseif id == "Img_Bg_Pet" then
    self:OnBtn_AddPet(clickObj)
  elseif id == "Img_Selected_Pet01" then
    self:OnBtn_Pet(clickObj)
  elseif id == "Img_PropItem" then
    self.itemTipHelper:CheckItem2ShowTip(id, -1, true)
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Tips = function(self)
  local tipId = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_DETAIL_TIP")
  GUIUtils.ShowHoverTip(tipId)
end
def.method().OnBtn_Confirm = function(self)
  local petIdL = self._petLeft and self._petLeft.id
  local petIdR = self._petRight and self._petRight.id
  if nil == petIdL or nil == petIdR then
    Toast(textRes.Pet.Soul.EXCHANGE_FAIL_CHOOSE_PET)
    return
  elseif Int64.eq(petIdL, petIdR) then
    Toast(textRes.Pet.Soul.EXCHANGE_FAIL_SAME_PET)
    return
  end
  local function DoRandom()
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.Soul.EXCHANGE_CONFIRM_TITLE, textRes.Pet.Soul.EXCHANGE_CONFIRM_CONTENT, function(id, tag)
      if id == 1 then
        local haveYB = ItemModule.Instance():GetAllYuanBao()
        PetSoulProtocols.SendCPetSoulExchangeReq(petIdL, petIdR, self._bUseYB and 1 or 0, self._useYuanBaoNum, haveYB)
      end
    end, nil)
  end
  local function CheckUseYB()
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.Soul.EXCHANGE_CONFIRM_TITLE, textRes.Pet.Soul.EXCHANGE_CONFIRM_CONTENT_USE_YB, function(id, tag)
      if id == 1 then
        self:UpdateRandomState(true)
      end
    end, nil)
  end
  if self._bUseYB then
    DoRandom()
  else
    local itemId = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_SUM_ITEM")
    local need = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_ITEM_COUNT")
    local count = ItemModule.Instance():GetItemCountById(itemId)
    if need > count then
      CheckUseYB()
    else
      DoRandom()
    end
  end
end
def.method().OnBtn_YuanbaoUse = function(self)
  local bUseYB = self._uiObjs.Btn_YuanbaoUse:GetComponent("UIToggle").value
  self:UpdateRandomState(bUseYB)
end
def.method("userdata").OnBtn_AddPet = function(self, clickObj)
  local bLeft = clickObj.parent.name == self._uiObjs.Group_Left.name
  self:DoShowPetList(bLeft)
end
def.method("userdata").OnBtn_Pet = function(self, clickObj)
  local parent = clickObj.parent
  parent = parent and parent.parent
  local bLeft = parent and parent.name == self._uiObjs.Group_Left.name
  self:DoShowPetList(bLeft)
end
def.method("boolean").DoShowPetList = function(self, bLeft)
  warn("[PetSoulLevelupPanel:DoShowPetList] bLeft:", bLeft)
  local petList = PetMgr.Instance():GetPetList()
  local chooseList = {}
  if petList then
    for _, pet in pairs(petList) do
      if bLeft and (nil == self._petLeft or not Int64.eq(self._petLeft.id, pet.id)) then
        table.insert(chooseList, pet)
      elseif not bLeft and (nil == self._petRight or not Int64.eq(self._petRight.id, pet.id)) then
        table.insert(chooseList, pet)
      end
    end
  end
  require("Main.Pet.ui.PetSelectPanel").Instance():ShowPanel(chooseList, textRes.Pet.Soul.EXCHANGE_CHOOSE_TITLE, function(index, pet, userParams)
    if bLeft then
      if pet and self._petRight and Int64.eq(self._petRight.id, pet.id) then
        Toast(textRes.Pet.Soul.EXCHANGE_CHOOSE_SAME_PET)
      else
        self._petLeft = pet
        self:ShowPet(self._petLeft, self._uiObjs.Group_Left)
      end
    elseif pet and self._petLeft and Int64.eq(self._petLeft.id, pet.id) then
      Toast(textRes.Pet.Soul.EXCHANGE_CHOOSE_SAME_PET)
    else
      self._petRight = pet
      self:ShowPet(self._petRight, self._uiObjs.Group_Right)
    end
  end, nil)
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetSoulExchangePanel.OnPetInfoUpdate)
    eventFunc(ModuleId.PET, gmodule.notifyId.Pet.PET_DELETED, PetSoulExchangePanel.OnPetDeleted)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetSoulExchangePanel.OnBagInfoSynchronized)
  end
end
def.static("table", "table").OnPetInfoUpdate = function(params)
  local petId = params[1]
  local self = instance
  if not self:IsShow() then
    return
  end
  if self._petLeft and Int64.eq(self._petLeft.id, petId) then
    self._petLeft = PetMgr.Instance():GetPet(petId)
    self:ShowPet(self._petLeft, self._uiObjs.Group_Left)
  elseif self._petRight and Int64.eq(self._petRight.id, petId) then
    self._petRight = PetMgr.Instance():GetPet(petId)
    self:ShowPet(self._petRight, self._uiObjs.Group_Right)
  end
end
def.static("table", "table").OnPetDeleted = function(params)
  local petId = params[1]
  local self = instance
  if not self:IsShow() then
    return
  end
  if self._petLeft and Int64.eq(self._petLeft.id, petId) then
    self._petLeft = nil
    self:ShowPet(self._petLeft, self._uiObjs.Group_Left)
  elseif self._petRight and Int64.eq(self._petRight.id, petId) then
    self._petRight = nil
    self:ShowPet(self._petRight, self._uiObjs.Group_Right)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(self)
  local self = instance
  if not self:IsShow() then
    return
  end
  self:ShowCostItem()
  self:UpdateRandomState(self._bUseYB)
end
PetSoulExchangePanel.Commit()
return PetSoulExchangePanel
