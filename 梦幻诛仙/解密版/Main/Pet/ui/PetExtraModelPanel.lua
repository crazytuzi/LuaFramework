local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetExtraModelPanel = Lplus.Extend(ECPanelBase, "PetExtraModelPanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
local PetData = require("Main.Pet.data.PetData")
local ECUIModel = require("Model.ECUIModel")
local def = PetExtraModelPanel.define
def.const("number").MIN_ITEM_GRID_COUNT = 20
def.const("table").Operation = {ChangeExtraModel = 1, UnlockExtraModel = 2}
def.field("userdata").petId = nil
def.field("table").uiObjs = nil
def.field("number").operation = 0
def.field("number").selectedExtraModelId = 0
def.field("table").petModel = nil
def.field("boolean").isDrag = false
local instance
def.static("=>", PetExtraModelPanel).Instance = function()
  if nil == instance then
    instance = PetExtraModelPanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, petId)
  if self:IsShow() then
    return
  end
  self.petId = petId
  self:CreatePanel(RESPATH.PREFAB_PET_SHAPE_BAG_PANEL_RES, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowPetOwnExtraModelList()
  self:FillPetOwnExtraModelList()
  self:FillPetExtraModelItemsInBag()
  self:UpdatePetUIModel()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetExtraModelPanel.OnPetInfoUpdate)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_UNLOCK_NEW_EXTRAM_MODEL, PetExtraModelPanel.OnPetUnlockNewExtraModel)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetExtraModelPanel.OnBagInfoSynchronized)
end
def.override().OnDestroy = function(self)
  self.petId = nil
  self.uiObjs = nil
  self.operation = 0
  self.selectedExtraModelId = 0
  if self.petModel ~= nil then
    self.petModel:Destroy()
  end
  self.isDrag = false
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetExtraModelPanel.OnPetInfoUpdate)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_UNLOCK_NEW_EXTRAM_MODEL, PetExtraModelPanel.OnPetUnlockNewExtraModel)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetExtraModelPanel.OnBagInfoSynchronized)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Group_Pet = self.uiObjs.Img_Bg:FindDirect("Group_Pet")
  self.uiObjs.Btn_Change = self.uiObjs.Group_Pet:FindDirect("Btn_Change")
  self.uiObjs.Group_Tab = self.uiObjs.Img_Bg:FindDirect("Group_Tab")
  self.uiObjs.Btn_Tab_1 = self.uiObjs.Group_Tab:FindDirect("Btn_Tab_1")
  self.uiObjs.Btn_Tab_2 = self.uiObjs.Group_Tab:FindDirect("Btn_Tab_2")
  self.uiObjs.Group_Info = self.uiObjs.Img_Bg:FindDirect("Group_Info")
  self.uiObjs.Group_Bag = self.uiObjs.Img_Bg:FindDirect("Group_Bag")
end
def.method().ShowPetOwnExtraModelList = function(self)
  GUIUtils.Toggle(self.uiObjs.Btn_Tab_1, true)
  GUIUtils.Toggle(self.uiObjs.Btn_Tab_2, false)
  GUIUtils.SetActive(self.uiObjs.Group_Info, true)
  GUIUtils.SetActive(self.uiObjs.Group_Bag, false)
  GUIUtils.SetActive(self.uiObjs.Btn_Change, true)
  self.operation = PetExtraModelPanel.Operation.ChangeExtraModel
  self:FillPetOwnExtraModelList()
  self:UpdatePetUIModel()
  self:UpdateOperationButtonName()
end
def.method().FillPetOwnExtraModelList = function(self)
  local Group_List = self.uiObjs.Group_Info:FindDirect("Group_List")
  local Group_NoData = self.uiObjs.Group_Info:FindDirect("Group_NoData")
  local Group_ShapeNum = self.uiObjs.Group_Info:FindDirect("Group_ShapeNum")
  local Label_ShapeNum = Group_ShapeNum:FindDirect("Label_ShapeNum")
  local maxModelCount = PetUtility.Instance():GetPetConstants("OWN_MAX_EXTRA_MODEL_NUM")
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    GUIUtils.SetActive(Group_List, false)
    GUIUtils.SetActive(Group_NoData, true)
    GUIUtils.SetText(Label_ShapeNum, string.format(textRes.Pet[246], 0, maxModelCount))
    return
  end
  local extraModelList = pet:GetSortedExtraModelList()
  if #extraModelList == 0 then
    GUIUtils.SetActive(Group_List, false)
    GUIUtils.SetActive(Group_NoData, true)
    GUIUtils.SetText(Label_ShapeNum, string.format(textRes.Pet[246], 0, maxModelCount))
  else
    GUIUtils.SetActive(Group_List, true)
    GUIUtils.SetActive(Group_NoData, false)
    GUIUtils.SetText(Label_ShapeNum, string.format(textRes.Pet[246], #extraModelList, maxModelCount))
  end
  self:UpdatePetExtraModelList()
end
def.method().UpdatePetExtraModelList = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  local extraModelList = pet:GetSortedExtraModelList()
  local hasSelectedModelId = false
  for i = 1, #extraModelList do
    if self.selectedExtraModelId == extraModelList[i] then
      hasSelectedModelId = true
      break
    end
  end
  if not hasSelectedModelId or self.selectedExtraModelId == 0 then
    self.selectedExtraModelId = pet.extraModelCfgId
  end
  local Group_List = self.uiObjs.Group_Info:FindDirect("Group_List")
  local Scrollview = Group_List:FindDirect("Scrollview")
  local List = Scrollview:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #extraModelList
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    local Img_Bg = uiItem:FindDirect("Img_Bg")
    local Img_BgPet = uiItem:FindDirect("Img_BgPet")
    local Icon_Pet01 = Img_BgPet:FindDirect("Icon_Pet01")
    local Label_ShapeName = uiItem:FindDirect("Label_ShapeName")
    local Img_SignUse = uiItem:FindDirect("Img_SignUse")
    local Img_SignTry = uiItem:FindDirect("Img_SignTry")
    local itemId = extraModelList[i]
    local itemBase = ItemUtils.GetItemBase(itemId)
    GUIUtils.SetTexture(Icon_Pet01, self:GetPetExtraModelIconId(itemId))
    GUIUtils.SetItemCellSprite(Img_BgPet, itemBase.namecolor)
    GUIUtils.SetText(Label_ShapeName, itemBase.name)
    GUIUtils.SetActive(Img_SignUse, false)
    GUIUtils.SetActive(Img_SignTry, false)
    if extraModelList[i] == pet.extraModelCfgId then
      GUIUtils.SetActive(Img_SignUse, true)
    elseif extraModelList[i] == self.selectedExtraModelId then
      GUIUtils.SetActive(Img_SignTry, true)
    end
    Img_Bg:GetComponent("UIToggle").optionCanBeNone = true
    if extraModelList[i] == self.selectedExtraModelId then
      GUIUtils.Toggle(Img_Bg, true)
    else
      GUIUtils.Toggle(Img_Bg, false)
    end
    uiItem.name = "PetExralModel_" .. extraModelList[i]
  end
end
def.method("number", "=>", "number").GetPetExtraModelIconId = function(self, itemId)
  local itemInfo = ItemUtils.GetPetHuiZhiItemCfg(itemId)
  if itemInfo == nil then
    return 0
  end
  local modeId = itemInfo.modelId
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modeId)
  if modelRecord then
    return modelRecord:GetIntValue("headerIconId")
  end
  return 0
end
def.method().ShowPetExtraModelItemsInBag = function(self)
  GUIUtils.Toggle(self.uiObjs.Btn_Tab_1, false)
  GUIUtils.Toggle(self.uiObjs.Btn_Tab_2, true)
  GUIUtils.SetActive(self.uiObjs.Group_Info, false)
  GUIUtils.SetActive(self.uiObjs.Group_Bag, true)
  GUIUtils.SetActive(self.uiObjs.Btn_Change, true)
  self.operation = PetExtraModelPanel.Operation.UnlockExtraModel
  self:FillPetExtraModelItemsInBag()
  self:UpdatePetUIModel()
  self:UpdateOperationButtonName()
end
def.method().FillPetExtraModelItemsInBag = function(self)
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.PET_CHANGEMODEL_ITEM)
  local sortedItems = {}
  for itemKey, item in pairs(items) do
    table.insert(sortedItems, item)
  end
  local Scrollview = self.uiObjs.Group_Bag:FindDirect("Group_List/Scrollview")
  local List = Scrollview:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = math.max(#sortedItems, PetExtraModelPanel.MIN_ITEM_GRID_COUNT)
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    if sortedItems[i] then
      self:SetIcon(uiItem, sortedItems[i])
      uiItem.name = "PetExralModelItem_" .. sortedItems[i].id
    else
      self:ClearIcon(uiItem)
      uiItem.name = "PetExralModelNoneItem_" .. i
    end
  end
end
def.method("userdata", "table").SetIcon = function(self, item, itemInfo)
  local icon = item:FindDirect("Img_Icon")
  local uiTexture = icon:GetComponent("UITexture")
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  icon:SetActive(true)
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local num = item:FindDirect("Label_Num")
  if itemInfo.number > 1 then
    num:SetActive(true)
    num:GetComponent("UILabel"):set_text(string.format("%2d", itemInfo.number))
  else
    num:SetActive(false)
  end
  item:FindDirect("Img_New"):SetActive(false)
  item:FindDirect("Img_Tpye"):SetActive(false)
  item:FindDirect("Img_Select"):SetActive(true)
  local bg = item:FindDirect("Img_Bg")
  GUIUtils.SetSprite(bg, ItemUtils.GetItemFrame(itemInfo, itemBase))
  local broken = item:FindDirect("Img_EquipBroken")
  broken:SetActive(false)
  local bang = item:FindDirect("Img_Bang")
  local zhuan = item:FindDirect("Img_Zhuan")
  local rarity = item:FindDirect("Img_Xiyou")
  if bang and zhuan then
    if itemBase.isProprietary then
      bang:SetActive(false)
      zhuan:SetActive(true)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsItemBind(itemInfo) then
      bang:SetActive(true)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsRarity(itemInfo.id) then
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, true)
    else
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    end
  end
  local red = item:FindDirect("Img_Red")
  red:SetActive(false)
end
def.method("userdata").ClearIcon = function(self, icon)
  local bg = icon:FindDirect("Img_Bg")
  bg:GetComponent("UISprite"):set_spriteName("Cell_00")
  icon:FindDirect("Label_Num"):SetActive(false)
  icon:FindDirect("Img_Icon"):SetActive(false)
  icon:FindDirect("Img_New"):SetActive(false)
  icon:FindDirect("Img_EquipBroken"):SetActive(false)
  icon:FindDirect("Img_Tpye"):SetActive(false)
  local bang = icon:FindDirect("Img_Bang")
  if bang then
    bang:SetActive(false)
  end
  local zhuan = icon:FindDirect("Img_Zhuan")
  if zhuan then
    zhuan:SetActive(false)
  end
  local rarity = icon:FindDirect("Img_Xiyou")
  if rarity then
    rarity:SetActive(false)
  end
  local red = icon:FindDirect("Img_Red")
  if red then
    red:SetActive(false)
  end
end
def.method().UpdateOperationButtonName = function(self)
  if self.operation == PetExtraModelPanel.Operation.ChangeExtraModel then
    self:SetOperationButtonName(textRes.Pet[243])
    local pet = PetMgr.Instance():GetPet(self.petId)
    if pet ~= nil then
      if self.selectedExtraModelId == pet.extraModelCfgId and pet.extraModelCfgId ~= 0 then
        self:SetOperationButtonName(textRes.Pet[244])
      else
        self:SetOperationButtonName(textRes.Pet[243])
      end
    end
  elseif self.operation == PetExtraModelPanel.Operation.UnlockExtraModel then
    self:SetOperationButtonName(textRes.Pet[245])
  end
end
def.method("string").SetOperationButtonName = function(self, name)
  local Label_Btn = self.uiObjs.Btn_Change:FindDirect("Label_Btn")
  GUIUtils.SetText(Label_Btn, name)
end
def.method("=>", "number").GetSelectedExtraModelId = function(self)
  if self.operation == PetExtraModelPanel.Operation.ChangeExtraModel then
    return self.selectedExtraModelId
  elseif self.operation == PetExtraModelPanel.Operation.UnlockExtraModel then
    return self:GetSelectedExtraModelItemId()
  else
    return 0
  end
end
def.method("=>", "number").GetSelectedExtraModelItemId = function(self)
  local Scrollview = self.uiObjs.Group_Bag:FindDirect("Group_List/Scrollview")
  local List = Scrollview:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    if uiItem:GetComponent("UIToggle").value then
      local objName = uiItem.name
      local itemId = tonumber(string.sub(objName, #"PetExralModelItem_" + 1)) or 0
      return itemId
    end
  end
  return 0
end
def.method().UpdatePetUIModel = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  local Model = self.uiObjs.Group_Pet:FindDirect("Model")
  local uiModel = Model:GetComponent("UIModel")
  if self.petModel ~= nil then
    self.petModel:Destroy()
  end
  local selectedExtraModelId = self:GetSelectedExtraModelId()
  if selectedExtraModelId == 0 then
    selectedExtraModelId = pet.extraModelCfgId
  end
  if selectedExtraModelId == 0 then
    self.petModel = PetUtility.CreateAndAttachPetUIModel(pet, uiModel, nil)
  else
    do
      local item = ItemUtils.GetPetHuiZhiItemCfg(selectedExtraModelId)
      local modelId = item.modelId
      local colorId = item.colorId
      local modelPath = _G.GetModelPath(modelId)
      self.petModel = ECUIModel.new(modelId)
      self.petModel:LoadUIModel(modelPath, function(ret)
        if self.uiObjs == nil then
          return
        end
        uiModel.modelGameObject = self.petModel.m_model
        if uiModel.mCanOverflow ~= nil then
          uiModel.mCanOverflow = true
          local camera = uiModel:get_modelCamera()
          camera:set_orthographic(true)
        end
        if colorId > 0 then
          local colorcfg = _G.GetModelColorCfg(colorId)
          self.petModel:SetColoration(colorcfg)
        else
          self.petModel:SetColoration(nil)
        end
      end)
      self.petModel:SetOrnament(pet.isDecorated)
      self.petModel:SetMagicMark(pet:GetPetDisplayMarkModelId())
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Tab_1" then
    self:ShowPetOwnExtraModelList()
  elseif id == "Btn_Tab_2" then
    self:ShowPetExtraModelItemsInBag()
  elseif string.find(id, "PetExralModelItem_") then
    self:OnClickPetExralModelItem(clickObj)
  elseif string.find(id, "PetExralModelNoneItem_") then
    self:OnClickPetExralModelNoneItem(clickObj)
  elseif id == "Img_Bg" then
    local parent = clickObj.transform.parent
    if string.find(parent.name, "PetExralModel_") then
      self:OnClickPetExralModel(parent)
    end
  elseif id == "Btn_Del" then
    local parent = clickObj.transform.parent
    if string.find(parent.name, "PetExralModel_") then
      self:OnClickDeletPetExralModel(parent)
    end
  elseif id == "Btn_Change" then
    self:OnClickBtnOperation()
  end
end
def.method("userdata").OnClickPetExralModelItem = function(self, itemObj)
  if itemObj == nil then
    return
  end
  itemObj:GetComponent("UIToggle").value = true
  local objName = itemObj.name
  local itemId = tonumber(string.sub(objName, #"PetExralModelItem_" + 1))
  if itemId == nil then
    return
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, itemObj:FindDirect("Img_Bg"), 0, false)
  self:UpdatePetUIModel()
end
def.method("userdata").OnClickPetExralModelNoneItem = function(self, itemObj)
  if itemObj == nil then
    return
  end
  itemObj:GetComponent("UIToggle").value = false
end
def.method("userdata").OnClickPetExralModel = function(self, itemObj)
  if itemObj == nil then
    return
  end
  local objName = itemObj.name
  local itemId = tonumber(string.sub(objName, #"PetExralModel_" + 1))
  if itemId == nil then
    return
  end
  self.selectedExtraModelId = itemId
  self:UpdatePetExtraModelList()
  self:UpdatePetUIModel()
  self:UpdateOperationButtonName()
end
def.method("userdata").OnClickDeletPetExralModel = function(self, itemObj)
  if itemObj == nil then
    return
  end
  local objName = itemObj.name
  local itemId = tonumber(string.sub(objName, #"PetExralModel_" + 1))
  if itemId == nil then
    return
  end
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  if pet.extraModelCfgId == itemId then
    Toast(textRes.Pet[256])
    return
  end
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet[252], textRes.Pet[253], function(selection, tag)
    if selection == 1 then
      PetMgr.Instance():C2S_CDeletePetModel(self.petId, itemId)
    end
  end, nil)
end
def.method().OnClickBtnOperation = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  if self.operation == PetExtraModelPanel.Operation.ChangeExtraModel then
    local selectedExtraModelId = self:GetSelectedExtraModelId()
    if pet.extraModelCfgId ~= 0 and pet.extraModelCfgId == selectedExtraModelId then
      self:OnClickBtnCancelExtraModel()
    else
      self:OnClickBtnChangeExtraModel()
    end
  elseif self.operation == PetExtraModelPanel.Operation.UnlockExtraModel then
    self:OnClickBtnUnlockExtraModel()
  end
end
def.method().OnClickBtnChangeExtraModel = function(self)
  local selectedExtraModelId = self:GetSelectedExtraModelId()
  if selectedExtraModelId == 0 then
    Toast(textRes.Pet[257])
    return
  end
  PetMgr.Instance():C2S_CSWitchPetModel(self.petId, selectedExtraModelId)
end
def.method().OnClickBtnCancelExtraModel = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  if _G.PlayerIsInFight() then
    Toast(textRes.Pet[205])
    return
  end
  local fightPet = PetMgr.Instance():GetFightingPet()
  if fightPet ~= nil and fightPet.id == pet.id then
    Toast(textRes.Pet[206])
    return
  end
  local displayPet = PetMgr.Instance():GetDisplayPet()
  if displayPet ~= nil and displayPet.id == pet.id then
    Toast(textRes.Pet[207])
    return
  end
  local petCfg = pet:GetPetCfgData()
  local needItemId = PetUtility.Instance():GetPetConstants("CANCEL_PET_CHANGEMODEL_ITEM_ID")
  local needItemNum = PetUtility.Instance():GetPetConstants("CANCEL_PET_CHANGEMODEL_ITEM_COST_NUM")
  local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
  ItemConsumeHelper.Instance():ShowItemConsume(textRes.Pet[201], string.format(textRes.Pet[202], pet.name, textRes.Pet.Type[petCfg.type]), needItemId, needItemNum, function(select)
    local function CancelPetModelChangeItemReq(petId, useYuanBao, needYuanbao)
      if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_CHANGE_MODEL) then
        Toast(textRes.Pet[219])
        return
      end
      PetMgr.Instance():CancelPetModelChangeItemReq(petId, useYuanBao, needYuanbao)
    end
    if select < 0 then
    elseif select == 0 then
      CancelPetModelChangeItemReq(pet.id, false, 0)
    else
      CancelPetModelChangeItemReq(pet.id, true, select)
    end
  end)
end
def.method().OnClickBtnUnlockExtraModel = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  local itemId = self:GetSelectedExtraModelItemId()
  if itemId == 0 then
    Toast(textRes.Pet[247])
    return
  end
  if pet:HasExtraModel(itemId) then
    Toast(textRes.Pet[258])
    return
  end
  local function unlockPetExtraModel(pet, itemKey, item)
    local newExtraModel = ItemUtils.GetItemBase(itemId)
    local confirmStr
    if pet.extraModelCfgId ~= 0 then
      local existModelInfo = ItemUtils.GetItemBase(pet.extraModelCfgId)
      if existModelInfo == nil then
        warn("pet huizhi item not exist:" .. pet.extraModelCfgId)
        return
      end
      confirmStr = string.format(textRes.Pet[214], existModelInfo.name, newExtraModel.name)
    else
      confirmStr = string.format(textRes.Pet[215], newExtraModel.name)
    end
    require("GUI.CommonConfirmDlg").ShowConfirm("", confirmStr, function(result)
      if result == 1 then
        PetMgr.Instance():UsePetChangeModelItemReq(pet.id, itemKey)
      end
    end, nil)
  end
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.PET_CHANGEMODEL_ITEM)
  for itemKey, item in pairs(items) do
    if item.id == itemId then
      unlockPetExtraModel(pet, itemKey, item)
      break
    end
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self.petModel then
    self.petModel:SetDir(self.petModel.m_ang - dx / 2)
  end
end
def.static("table", "table").OnPetInfoUpdate = function(params, context)
  local self = instance
  local petId = params[1]
  if self.petId ~= nil and petId ~= nil and Int64.eq(self.petId, petId) then
    self:FillPetOwnExtraModelList()
    self:UpdatePetUIModel()
    self:UpdateOperationButtonName()
  end
end
def.static("table", "table").OnPetUnlockNewExtraModel = function(params, context)
  local self = instance
  local petId = params[1]
  if self.petId ~= nil and petId ~= nil and Int64.eq(self.petId, petId) then
    self:ShowPetOwnExtraModelList()
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local bagId = params.bagId
  local self = instance
  if bagId == ItemModule.BAG then
    self:FillPetExtraModelItemsInBag()
    self:UpdatePetUIModel()
    self:UpdateOperationButtonName()
  end
end
PetExtraModelPanel.Commit()
return PetExtraModelPanel
