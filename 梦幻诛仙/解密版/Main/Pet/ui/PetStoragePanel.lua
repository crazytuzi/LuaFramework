local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetStoragePanel = Lplus.Extend(ECPanelBase, "PetStoragePanel")
local def = PetStoragePanel.define
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetMgrInstance = PetMgr.Instance()
local PetStorageMgr = require("Main.Pet.mgr.PetStorageMgr")
local PetModule = Lplus.ForwardDeclare("PetModule")
local PetUtility = require("Main.Pet.PetUtility")
local PetData = Lplus.ForwardDeclare("PetData")
local GUIUtils = require("GUI.GUIUtils")
def.const("table").PetPos = {Storage = 1, Bag = 2}
def.field("table").upetIdList = nil
def.field("table").spetIdList = nil
def.field("table").uiObjs = nil
local instance
def.static("=>", PetStoragePanel).Instance = function()
  if instance == nil then
    instance = PetStoragePanel()
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
  self:CreatePanel(RESPATH.PREFAB_PET_STORAGE_PANEL_RES, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_STORE_POS_UPDATE, PetStoragePanel.OnPetStorePosUpdate)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_STORAGE_CAPACITY_CHANGE, PetStoragePanel.OnPetStorageCapacityChange)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_BAG_CAPACITY_CHANGE, PetStoragePanel.OnPetBagCapacityChange)
  self:InitUI()
  self:Fill()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_STORE_POS_UPDATE, PetStoragePanel.OnPetStorePosUpdate)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_STORAGE_CAPACITY_CHANGE, PetStoragePanel.OnPetStorageCapacityChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_BAG_CAPACITY_CHANGE, PetStoragePanel.OnPetBagCapacityChange)
  self:Clear()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Img_Bg1 = self.uiObjs.Img_Bg0:FindDirect("Img_Bg1")
  self.uiObjs.Label_Page1 = self.uiObjs.Img_Bg1:FindDirect("Label_Page1")
  self.uiObjs.PetList1 = self.uiObjs.Img_Bg1:FindDirect("PetList1")
  self.uiObjs.List_PetList1 = self.uiObjs.PetList1:FindDirect("Img_PetList1/Scroll View_PetList1/List_PetList1")
  self.uiObjs.Img_Bg2 = self.uiObjs.Img_Bg0:FindDirect("Img_Bg2")
  self.uiObjs.Label_Page2 = self.uiObjs.Img_Bg2:FindDirect("Label_Page2")
  self.uiObjs.PetList2 = self.uiObjs.Img_Bg2:FindDirect("PetList2")
  self.uiObjs.List_PetList2 = self.uiObjs.PetList2:FindDirect("Img_PetList2/Scroll View_PetList2/List_PetList2")
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.sub(id, 3, 7) == "item_" then
    self:OnClickPetObj(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Add1" then
    self:OnExtendStorageCapacityButtonClick()
  elseif id == "Btn_Add2" then
    self:OnExtendBagCapacityButtonClick()
  elseif string.sub(id, 1, #"Icon_PetHead_") == "Icon_PetHead_" then
    self:OnClickPetIcon(id)
  end
end
def.method("string").onDoubleClick = function(self, id)
  print(string.format("%s double click event: id = %s", tostring(self), id))
  if string.sub(id, 3, 7) == "item_" then
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
end
def.method("string").onLongPress = function(self, id)
  if string.sub(id, 3, 7) == "item_" then
    self:OnLongPressPet(id)
  end
end
def.method("string", "boolean").onToggle = function(self, id, isActive)
end
def.static("table", "table").OnPetStorePosUpdate = function()
  local self = instance
  self:Fill()
end
def.static("table", "table").OnPetStorageCapacityChange = function()
  local self = instance
  local petList = PetStorageMgr.Instance():GetPetList()
  local petNum = PetStorageMgr.Instance():GetPetNum()
  self:SetStorageCapacityInfo(petNum, PetStorageMgr.Instance():GetStorageCapacity())
end
def.static("table", "table").OnPetBagCapacityChange = function()
  local self = instance
  local petList = PetMgrInstance.petList
  local petNum = PetMgrInstance.petNum
  self:SetBagCapacityInfo(petNum, PetMgrInstance.bagSize)
end
def.method("userdata").OnClickPetObj = function(self, obj)
  local parentObj = obj.transform.parent.gameObject
  local typeNum = tonumber(string.sub(parentObj.name, -1, -1))
  local index = tonumber(string.sub(obj.name, 8, -1))
  local TargetEnum = require("netio.protocol.mzm.gsp.pet.CTransfomPetPlaceReq")
  local target, petId
  if typeNum == PetStoragePanel.PetPos.Bag then
    petId = self.upetIdList[index]
    local pet = PetMgrInstance:GetPet(petId)
    if pet.isFighting then
      Toast(textRes.Pet[57])
      return
    end
    if PetStorageMgr.Instance():GetPetNum() >= PetStorageMgr.Instance():GetStorageCapacity() then
      Toast(textRes.Pet[27])
      return
    end
    target = TargetEnum.TARGET_DEPOT
  elseif typeNum == PetStoragePanel.PetPos.Storage then
    petId = self.spetIdList[index]
    if PetMgrInstance.petNum >= PetMgrInstance.bagSize then
      Toast(textRes.Pet[28])
      return
    end
    target = TargetEnum.TARGET_BAG
  end
  if PetStorageMgr.Instance():TransformPetPlace(petId, target) == PetStorageMgr.CResult.FORBIDDEN_IN_FIGHT then
    Toast(textRes.Pet[86])
  end
end
def.method("string").OnLongPressPet = function(self, id)
  local typeNum = 1
  if self.uiObjs.List_PetList2:FindDirect(id) then
    typeNum = 2
  end
  local index = tonumber(string.sub(id, 8, -1))
  local pet
  if typeNum == PetStoragePanel.PetPos.Bag then
    local petId = self.upetIdList[index]
    pet = PetMgrInstance:GetPet(petId)
  elseif typeNum == PetStoragePanel.PetPos.Storage then
    local petId = self.spetIdList[index]
    pet = PetStorageMgr.Instance():GetPet(petId)
  end
  require("Main.Pet.ui.PetInfoPanel").Instance():ShowPanel(pet)
end
def.method("string").OnClickPetIcon = function(self, id)
  local typeOffset = #"Icon_PetHead_" + 1
  local typeNum = tonumber(string.sub(id, typeOffset, typeOffset))
  local indexOffset = typeOffset + 2
  local index = tonumber(string.sub(id, indexOffset, -1))
  local pet
  if typeNum == PetStoragePanel.PetPos.Bag then
    local petId = self.upetIdList[index]
    pet = PetMgrInstance:GetPet(petId)
  elseif typeNum == PetStoragePanel.PetPos.Storage then
    local petId = self.spetIdList[index]
    pet = PetStorageMgr.Instance():GetPet(petId)
  end
  require("Main.Pet.ui.PetInfoPanel").Instance():ShowPanel(pet)
end
def.method().OnExtendStorageCapacityButtonClick = function(self)
  PetUtility.TryToExpandPetBag(PetModule.PET_STORAGE_BAG_ID, PetStorageMgr.Instance():GetStorageCapacity())
end
def.method().OnExtendBagCapacityButtonClick = function(self)
  PetUtility.TryToExpandPetBag(PetModule.PET_BAG_ID, PetMgrInstance.bagSize)
end
def.method().Fill = function(self)
  self:FillStoragedPet()
  self:FillUnStoragedPet()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().Clear = function(self)
  self.uiObjs = nil
end
def.method().FillStoragedPet = function(self)
  local petList = PetStorageMgr.Instance():GetPetList()
  local petNum = PetStorageMgr.Instance():GetPetNum()
  self:SetStorageCapacityInfo(petNum, PetStorageMgr.Instance():GetStorageCapacity())
  if petNum == 0 then
    self:SetStoredListUIEmpty()
    return
  end
  local grid_petList = self.uiObjs.List_PetList1:GetComponent("UIList")
  grid_petList:set_itemCount(petNum)
  grid_petList:Resize()
  local sortedPetList = {}
  for k, v in pairs(petList) do
    table.insert(sortedPetList, v)
  end
  table.sort(sortedPetList, PetMgr.PetSortFunction)
  self.spetIdList = {}
  for index, pet in ipairs(sortedPetList) do
    self.spetIdList[index] = pet.id
    self:SetStoredListItemInfo(index, pet)
  end
end
def.method("number", "number").SetStorageCapacityInfo = function(self, num, capacity)
  self.uiObjs.Label_Page1:GetComponent("UILabel"):set_text(string.format("%d/%d", num, capacity))
end
def.method().FillUnStoragedPet = function(self)
  local petList = PetMgrInstance.petList
  local petNum = PetMgrInstance.petNum
  self:SetBagCapacityInfo(petNum, PetMgrInstance.bagSize)
  if petList == nil or petNum == 0 then
    self:SetUnstoredListUIEmpty()
    return
  end
  local grid_petList = self.uiObjs.List_PetList2:GetComponent("UIList")
  grid_petList:set_itemCount(petNum)
  grid_petList:Resize()
  local sortedPetList = {}
  for k, v in pairs(petList) do
    table.insert(sortedPetList, v)
  end
  table.sort(sortedPetList, PetMgr.PetSortFunction)
  self.upetIdList = {}
  for index, pet in ipairs(sortedPetList) do
    self.upetIdList[index] = pet.id
    self:SetUnstoredListItemInfo(index, pet)
  end
end
def.method("number", "number").SetBagCapacityInfo = function(self, num, capacity)
  self.uiObjs.Label_Page2:GetComponent("UILabel"):set_text(string.format("%d/%d", num, capacity))
end
def.method().SetStoredListUIEmpty = function(self)
  local grid_petList = self.uiObjs.List_PetList1:GetComponent("UIList")
  grid_petList:set_itemCount(0)
  grid_petList:Resize()
end
def.method().SetUnstoredListUIEmpty = function(self)
  local grid_petList = self.uiObjs.List_PetList2:GetComponent("UIList")
  grid_petList:set_itemCount(0)
  grid_petList:Resize()
end
def.method("number", PetData).SetStoredListItemInfo = function(self, index, pet)
  local petListRoot = self.uiObjs.List_PetList1
  local item = petListRoot:FindDirect("item_" .. index)
  if item ~= nil then
    item.name = "l_" .. item.name
  end
  item = petListRoot:FindDirect("l_item_" .. index)
  item:FindDirect("Label_PetName1_1"):GetComponent("UILabel"):set_text(pet.name)
  item:FindDirect("Label_PetLv1_1"):GetComponent("UILabel"):set_text(string.format(textRes.Pet[1], pet.level))
  local petCfgData = pet:GetPetCfgData()
  local typeText = textRes.Pet.Type[petCfgData.type]
  item:FindDirect("Label_Type1_1"):GetComponent("UILabel"):set_text(typeText)
  item:FindDirect("Label_PowerNum1_1"):GetComponent("UILabel"):set_text(pet:GetYaoLi())
  local Img_BgPetHead = item:FindDirect("Img_BgPetHead1_1")
  local iconObj = Img_BgPetHead:FindDirect("Icon_PetHead1_1")
  if iconObj then
    iconObj.name = string.format("Icon_PetHead_%d_%d", 1, index)
  else
    iconObj = Img_BgPetHead:FindDirect(string.format("Icon_PetHead_%d_%d", 1, index))
  end
  local Img_Xiyou = Img_BgPetHead:FindDirect("Img_Xiyou")
  local isRarity = pet:IsRarity()
  GUIUtils.SetActive(Img_Xiyou, isRarity)
  local uiTexture = iconObj:GetComponent("UITexture")
  local iconId = pet:GetHeadIconId()
  GUIUtils.FillIcon(uiTexture, iconId)
  local Sprite = Img_BgPetHead:FindDirect("Sprite")
  local spriteName = pet:GetHeadIconBGSpriteName()
  GUIUtils.SetSprite(Sprite, spriteName, true)
  local iconObj = uiTexture.gameObject
  local boxCollider = iconObj:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = iconObj:AddComponent("BoxCollider")
    boxCollider:set_size(Vector3.new(uiTexture:get_width(), uiTexture:get_height(), 0))
    uiTexture:set_autoResizeBoxCollider(true)
  end
end
def.method("number", PetData).SetUnstoredListItemInfo = function(self, index, pet)
  local petListRoot = self.uiObjs.List_PetList2
  local item = petListRoot:FindDirect("item_" .. index)
  if item ~= nil then
    item.name = "r_" .. item.name
  end
  item = petListRoot:FindDirect("r_item_" .. index)
  item:FindDirect("Label_PetName2_1"):GetComponent("UILabel"):set_text(pet.name)
  item:FindDirect("Label_PetLv2_1"):GetComponent("UILabel"):set_text(string.format(textRes.Pet[1], pet.level))
  local petCfgData = pet:GetPetCfgData()
  local typeText = textRes.Pet.Type[petCfgData.type]
  item:FindDirect("Label_Type2_1"):GetComponent("UILabel"):set_text(typeText)
  item:FindDirect("Label_PowerNum2_1"):GetComponent("UILabel"):set_text(pet:GetYaoLi())
  if pet.isFighting then
    item:FindDirect("Img_Sign2_1"):SetActive(true)
  else
    item:FindDirect("Img_Sign2_1"):SetActive(false)
  end
  local Img_BgPetHead = item:FindDirect("Img_BgPetHead2_1")
  local iconObj = Img_BgPetHead:FindDirect("Icon_PetHead1_1")
  if iconObj then
    iconObj.name = string.format("Icon_PetHead_%d_%d", 2, index)
  else
    iconObj = Img_BgPetHead:FindDirect(string.format("Icon_PetHead_%d_%d", 2, index))
  end
  local Img_Xiyou = Img_BgPetHead:FindDirect("Img_Xiyou")
  local isRarity = pet:IsRarity()
  GUIUtils.SetActive(Img_Xiyou, isRarity)
  local uiTexture = iconObj:GetComponent("UITexture")
  local iconId = pet:GetHeadIconId()
  GUIUtils.FillIcon(uiTexture, iconId)
  local Sprite = Img_BgPetHead:FindDirect("Sprite")
  local spriteName = pet:GetHeadIconBGSpriteName()
  GUIUtils.SetSprite(Sprite, spriteName, true)
  local boxCollider = iconObj:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = iconObj:AddComponent("BoxCollider")
    boxCollider:set_size(Vector3.new(uiTexture:get_width(), uiTexture:get_height(), 0))
    uiTexture:set_autoResizeBoxCollider(true)
  end
end
PetStoragePanel.Commit()
return PetStoragePanel
