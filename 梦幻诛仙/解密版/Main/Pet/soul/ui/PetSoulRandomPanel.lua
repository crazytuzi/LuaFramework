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
local PetSoulRandomPanel = Lplus.Extend(ECPanelBase, "PetSoulRandomPanel")
local def = PetSoulRandomPanel.define
local instance
def.static("=>", PetSoulRandomPanel).Instance = function()
  if instance == nil then
    instance = PetSoulRandomPanel()
  end
  return instance
end
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("table")._uiObjs = nil
def.field("userdata")._petId = nil
def.field("number")._pos = 0
def.field("table")._soulInfo = nil
def.field("boolean")._bUseYB = false
def.field("number")._useYuanBaoNum = 0
def.static("userdata", "number").ShowPanel = function(petId, pos)
  if not PetSoulMgr.Instance():IsOpen(true) then
    if PetSoulRandomPanel.Instance():IsShow() then
      PetSoulRandomPanel.Instance():DestroyPanel()
    end
    return
  end
  PetSoulRandomPanel.Instance():InitData(petId, pos)
  if PetSoulRandomPanel.Instance():IsShow() then
    PetSoulRandomPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_PET_SOUL_RANDOM_PANEL, 2)
end
def.method("userdata", "number").InitData = function(self, petId, pos)
  self._petId = petId
  self._pos = pos
end
def.override().OnCreate = function(self)
  self.itemTipHelper = EasyBasicItemTip()
  self:SetModal(false)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Icon = self.m_panel:FindDirect("Img_Bg0/Img_Icon")
  self._uiObjs.Label_Attr = self.m_panel:FindDirect("Img_Bg0/Group_EquipLabel/Label_NumAtt")
  self._uiObjs.List_Attr = self.m_panel:FindDirect("Img_Bg0/Group_RandomLabel/List_LabelAtt")
  self._uiObjs.uiList = self._uiObjs.List_Attr:GetComponent("UIList")
  self._uiObjs.costItemGroup = self.m_panel:FindDirect("Img_Bg0/Img_BgEquipMakeItem")
  self._uiObjs.Icon_Item = self._uiObjs.costItemGroup:FindDirect("Icon_EquipMakeItem")
  self._uiObjs.Img_Bg = self._uiObjs.costItemGroup:FindDirect("Img_Bg")
  self._uiObjs.Label_ItemNum = self._uiObjs.costItemGroup:FindDirect("Label_EquipMakeItem")
  self._uiObjs.Label_ItemName = self._uiObjs.costItemGroup:FindDirect("Label_EquipMakeName")
  self._uiObjs.Btn_YuanbaoUse = self.m_panel:FindDirect("Img_Bg0/Img_BgEquipMakeItem/Btn_YuanbaoUse")
  self._uiObjs.Label_Confirm = self.m_panel:FindDirect("Img_Bg0/Btn_Confirm/Label_Confirm")
  self._uiObjs.Group_RandomYB = self.m_panel:FindDirect("Img_Bg0/Btn_Confirm/Group_Icon")
  self._uiObjs.Label_RandomYB = self._uiObjs.Group_RandomYB:FindDirect("Label_Confirm")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:UpdateSoulInfo()
  self:ShowAttrs()
  self:ShowCostItem()
  self:UpdateRandomState(self._bUseYB)
end
def.method().UpdateSoulInfo = function(self)
  local pet = PetMgr.Instance():GetPet(self._petId)
  if pet then
    local soulProp = pet and pet.soulProp
    self._soulInfo = soulProp and soulProp:GetSoulInfoByPos(self._pos)
  else
    warn("[ERROR][PetSoulRandomPanel:UpdateUI] pet nil for self._petId:", Int64.tostring(self._petId))
    self:DestroyPanel()
    return
  end
  if nil == self._soulInfo or nil == self._soulInfo.level or self._soulInfo.level < 1 then
    warn("[ERROR][PetSoulRandomPanel:UpdateUI] soulInfo nil or level==0 at pos:", self._pos)
    self:DestroyPanel()
    return
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self.itemTipHelper = nil
  self._pos = 0
  self._petId = nil
  self._soulInfo = nil
  self._bUseYB = false
  self._useYuanBaoNum = 0
end
def.method().ShowAttrs = function(self)
  local posCfg = PetSoulData.Instance():GetPosCfg(self._pos)
  if nil == posCfg then
    warn("[ERROR][PetSoulRandomPanel:ShowAttrs] posCfg nil at pos:", self._pos)
    return
  end
  local level = self._soulInfo.level
  local propIdx = self._soulInfo.propIndex and self._soulInfo.propIndex or 0
  GUIUtils.SetTexture(self._uiObjs.Img_Icon, posCfg.img)
  local prop = PetSoulData.Instance():GetSoulPropByIdx(self._soulInfo.pos, level, propIdx)
  local attrStr = PetSoulUtils.GetAttrString(prop)
  GUIUtils.SetText(self._uiObjs.Label_Attr, attrStr)
  local propList = PetSoulData.Instance():GetSoulPropList(self._soulInfo.pos, level)
  local propCount = propList and #propList or 0
  self._uiObjs.uiList.itemCount = propCount
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
  for idx = 1, propCount do
    local listItem = self._uiObjs.uiList.children[idx]
    local prop = propList[idx]
    local attrStr = PetSoulUtils.GetAttrString(prop)
    GUIUtils.SetText(listItem, attrStr)
  end
end
def.method().ShowCostItem = function(self)
  local itemId = PetUtility.Instance():GetPetConstants("soul_random_property_sub_item")
  local need = PetUtility.Instance():GetPetConstants("soul_random_property_item_count")
  local itemBase = ItemUtils.GetItemBase(itemId)
  if not itemBase then
    warn("[PetSoulRandomPanel:ShowCostItem] itemBase nil for id ", itemId)
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
    local itemId = PetUtility.Instance():GetPetConstants("soul_random_property_sub_item")
    local need = PetUtility.Instance():GetPetConstants("soul_random_property_item_count")
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
  local costItemId = PetUtility.Instance():GetPetConstants("soul_random_property_main_item")
  local price = MallUtility.GetPriceByItemId(costItemId)
  warn("[PetSoulRandomPanel:GetCostItemPrice] price for item, lackCount:", price, costItemId, count)
  return price * count
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Confirm" then
    self:OnBtn_Confirm()
  elseif id == "Btn_YuanbaoUse" then
    self:OnBtn_YuanbaoUse()
  elseif id == "Img_BgEquipMakeItem" then
    self.itemTipHelper:CheckItem2ShowTip(id, -1, true)
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Confirm = function(self)
  local function DoRandom()
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.Soul.RANDOM_CONFIRM_TITLE, textRes.Pet.Soul.RANDOM_CONFIRM_CONTENT, function(id, tag)
      if id == 1 then
        local haveYB = ItemModule.Instance():GetAllYuanBao()
        PetSoulProtocols.SendCPetSoulRandomPropReq(self._petId, self._pos, self._bUseYB and 1 or 0, self._useYuanBaoNum, haveYB)
      else
        self:DestroyPanel()
      end
    end, nil)
  end
  local function CheckUseYB()
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.Soul.RANDOM_CONFIRM_TITLE, textRes.Pet.Soul.RANDOM_CONFIRM_CONTENT_USE_YB, function(id, tag)
      if id == 1 then
        self:UpdateRandomState(true)
      end
    end, nil)
  end
  if self._bUseYB then
    DoRandom()
  else
    local itemId = PetUtility.Instance():GetPetConstants("soul_random_property_sub_item")
    local need = PetUtility.Instance():GetPetConstants("soul_random_property_item_count")
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
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetSoulRandomPanel.OnPetInfoUpdate)
    eventFunc(ModuleId.PET, gmodule.notifyId.Pet.PET_DELETED, PetSoulRandomPanel.OnPetDeleted)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetSoulRandomPanel.OnBagInfoSynchronized)
  end
end
def.static("table", "table").OnPetInfoUpdate = function(params)
  local petId = params[1]
  local self = instance
  if not self:IsShow() then
    return
  end
  if self._petId == petId then
    self:UpdateUI()
  end
end
def.static("table", "table").OnPetDeleted = function(params)
  local petId = params[1]
  local self = instance
  if not self:IsShow() then
    return
  end
  if self._petId == petId then
    self:DestroyPanel()
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
PetSoulRandomPanel.Commit()
return PetSoulRandomPanel
