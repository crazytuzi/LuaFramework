local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetShopBuyPanel = Lplus.Extend(ECPanelBase, "PetShopBuyPanel")
local def = PetShopBuyPanel.define
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local PetData = Lplus.ForwardDeclare("PetData")
local PetUtility = require("Main.Pet.PetUtility")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local ECModel = require("Model.ECModel")
local PetShopMgr = require("Main.Pet.mgr.PetShopMgr")
local PetMgr = require("Main.Pet.mgr.PetMgr")
def.const("number").SAME_CATCH_LEVEL_MAX_PET = 3
def.field("number").neededPetTemplateId = 0
def.field("table").neededPetInfo = nil
def.field("boolean").closeWhenFinished = false
def.field("table").canBuyPetList = nil
def.field("table").selectedPos = nil
def.field("boolean").isMoneyEnough = false
def.field("table").uiObjs = nil
def.field("table").models = nil
def.field("string").dragObjId = ""
def.field("number").curPetCatchMapId = 0
local instance
def.static("=>", PetShopBuyPanel).Instance = function()
  if instance == nil then
    instance = PetShopBuyPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:UpdateUI()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_STORE_BUY_PANEL_RES, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, PetShopBuyPanel.OnSilverMoneyChanged)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SHOP_BUY_PET_SUCCESS, PetShopBuyPanel.OnBuyPetSuccess)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, PetShopBuyPanel.OnTaskInfoChanged)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SELL_LIST_CHANGED, PetShopBuyPanel.OnPetSellListChanged)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, PetShopBuyPanel.OnSilverMoneyChanged)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SHOP_BUY_PET_SUCCESS, PetShopBuyPanel.OnBuyPetSuccess)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, PetShopBuyPanel.OnTaskInfoChanged)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SELL_LIST_CHANGED, PetShopBuyPanel.OnPetSellListChanged)
  self:Clear()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:UpdateUI()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Lv" then
    self:OnCatchLevelObjClicked(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Buy" then
    self:OnBuyPetButtonClick()
  elseif string.sub(id, 1, #"Img_BgPet_") == "Img_BgPet_" then
    local index = tonumber(string.sub(id, #"Img_BgPet_" + 1, -1))
    self:OnClickPetModel(index)
  elseif id == "Btn_Go" then
    self:OnCatchPetButtonClicked()
  elseif id == "Btn_Add" then
    self:OnAddSilverButtonClicked()
  end
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.selectedPos = nil
  self.neededPetTemplateId = 0
  for k, v in pairs(self.models) do
    v:Destroy()
  end
  self.models = nil
  self.canBuyPetList = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.List_Lv = self.uiObjs.Img_Bg0:FindDirect("Group_Lv/Group_Lv/Scroll View/List_Lv")
  self.uiObjs.Group_Pet1 = self.uiObjs.Img_Bg0:FindDirect("Group_Pet1")
  self.uiObjs.Group_Buy = self.uiObjs.Img_Bg0:FindDirect("Group_Buy")
  self.uiObjs.Label_UseNum = self.uiObjs.Group_Buy:FindDirect("Img_BgUseMoney/Label_UseNum")
  self.uiObjs.Label_HaveNum = self.uiObjs.Group_Buy:FindDirect("Img_BgHaveMoney/Label_HaveNum")
  for i = 1, PetShopBuyPanel.SAME_CATCH_LEVEL_MAX_PET do
    local modelObj = self.uiObjs.Group_Pet1:FindDirect(string.format("Pet%d/Img_BgPet%d", i, i))
    modelObj.name = "Img_BgPet_" .. i
  end
  self.models = {}
end
def.method().UpdateUI = function(self)
  self.canBuyPetList = PetShopMgr.Instance():GetCanBuyPetList()
  self:SetPetLevelList(self.canBuyPetList)
  if self.neededPetTemplateId == 0 then
    self.neededPetTemplateId = PetShopMgr.Instance():GetNextNeededPetTemplateId()
  end
  local pos = self:FindNeededPetPos()
  self.selectedPos = pos
  self:UpdateSameCatchLevelPetsInfo()
end
def.method("number", "boolean").SetNeededPetTemplateId = function(self, petTemplateId, isClose)
  self.neededPetTemplateId = petTemplateId
  self.closeWhenFinished = isClose
end
def.method("=>", "table").FindNeededPetPos = function(self)
  for i, v in ipairs(self.canBuyPetList) do
    for j, pet in ipairs(v) do
      if self.neededPetTemplateId == pet.templateId then
        return {i, j}
      end
    end
  end
  return self:GetDefaultPetPos()
end
def.method("=>", "table").GetDefaultPetPos = function(self)
  if self.selectedPos then
    return self.selectedPos
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local amount = #self.canBuyPetList
  for i = amount, 1, -1 do
    local v = self.canBuyPetList[i]
    if heroProp.level >= v.catchLevel then
      return {i, 1}
    end
  end
  return {amount, 1}
end
def.method("table").SetPetLevelList = function(self, petList)
  local petList = self.canBuyPetList
  local uiList = self.uiObjs.List_Lv:GetComponent("UIList")
  local amount = #petList
  uiList.itemCount = amount
  uiList:Resize()
  local itemObjs = uiList.children
  for i = 1, amount do
    local pet = petList[i]
    self:SetPetCatchLevelInfo(itemObjs[i], pet.catchLevel)
  end
  uiList:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "number").SetPetCatchLevelInfo = function(self, itemObj, catchLevel)
  local text = string.format(textRes.Common[3], catchLevel)
  itemObj:FindDirect("Label_Lv"):GetComponent("UILabel"):set_text(text)
end
def.method().UpdateSameCatchLevelPetsInfo = function(self)
  if not self:IsShow() then
    return
  end
  self:SetSameCatchLevelPetsInfo(self.selectedPos)
end
def.method("table").SetSameCatchLevelPetsInfo = function(self, pos)
  local catchLevelIndex = pos[1]
  local uiToggle = self.uiObjs.List_Lv:FindDirect(string.format("item_%d/Btn_Lv", catchLevelIndex)):GetComponent("UIToggle")
  uiToggle.value = true
  local sameCatchLevelPets = self.canBuyPetList[catchLevelIndex]
  for i = 1, PetShopBuyPanel.SAME_CATCH_LEVEL_MAX_PET do
    local itemObj = self.uiObjs.Group_Pet1:FindDirect("Pet" .. i)
    local petInfo = sameCatchLevelPets[i]
    self:SetPetInfo(i, itemObj, petInfo)
  end
  self:FocusOnCatchLevelIndex(catchLevelIndex)
  self:UpdateSelectedPetInfo()
end
def.method("number").FocusOnCatchLevelIndex = function(self, index)
  local item = self.uiObjs.List_Lv:FindDirect("item_" .. index)
  GameUtil.AddGlobalLateTimer(0, true, function()
    GameUtil.AddGlobalLateTimer(0, true, function()
      if self:IsShow() then
        local uiScrollView = self.uiObjs.List_Lv.transform.parent.gameObject:GetComponent("UIScrollView")
        uiScrollView:UpdatePosition()
        uiScrollView:DragToMakeVisible(item.transform, 4)
      end
    end)
  end)
end
def.method("number", "userdata", "table").SetPetInfo = function(self, index, itemObj, petInfo)
  if petInfo == nil then
    itemObj:SetActive(false)
    return
  end
  itemObj:SetActive(true)
  local petCfg = PetUtility.Instance():GetPetCfg(petInfo.templateId)
  itemObj:FindDirect("Group_Price/Label_Num"):GetComponent("UILabel"):set_text(petCfg.buyPrice)
  itemObj:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(petCfg.templateName)
  local isNeeded = PetShopMgr.Instance():IsNeeded(petInfo.templateId)
  local ui_Img_Sigh = itemObj:FindDirect("Img_Sigh")
  ui_Img_Sigh:SetActive(isNeeded)
  local uiModel = itemObj:FindDirect("Model"):GetComponent("UIModel")
  self:SetPetModel(index, uiModel, petCfg)
end
def.method("number", "userdata", "table").SetPetModel = function(self, index, uiModel, petCfg)
  local modelPath = GetModelPath(petCfg.modelId)
  local model = self.models[index]
  if model ~= nil then
    model:Destroy()
  end
  local PetUIModel = require("Main.Pet.PetUIModel")
  self.models[index] = PetUIModel.new(petCfg.templateId, uiModel)
  self.models[index]:LoadDefault(nil)
  uiModel.mCanOverflow = true
end
def.method("table").SetSelectedPetCostInfo = function(self, petInfo)
  local petCfg = PetUtility.Instance():GetPetCfg(petInfo.templateId)
  local useMoney = petCfg.buyPrice
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  if moneySilver:lt(useMoney) then
    self.isMoneyEnough = false
    useMoney = string.format("[ff0000]%s[-]", useMoney)
  else
    self.isMoneyEnough = true
  end
  self.uiObjs.Label_UseNum:GetComponent("UILabel"):set_text(useMoney)
  self.uiObjs.Label_HaveNum:GetComponent("UILabel"):set_text(tostring(moneySilver))
end
def.method().UpdateSelectedPetInfo = function(self)
  local petInfo = self:GetSelectedPetInfo()
  self:SetSelectedPetCostInfo(petInfo)
  self:SetSelectedPetCatchInfo(petInfo)
  local index = self.selectedPos[2]
  local ui_Img_BgPet = self.uiObjs.Group_Pet1:FindDirect("Pet" .. index):FindDirect("Img_BgPet_" .. index)
  ui_Img_BgPet:GetComponent("UIToggle"):set_value(true)
end
def.method("=>", "table").GetSelectedPetInfo = function(self)
  local pos = self.selectedPos
  local petInfo = self.canBuyPetList[pos[1]][pos[2]]
  return petInfo
end
def.method("table").SetSelectedPetCatchInfo = function(self, petInfo)
  local mapId = PetMgr.Instance():GetPetCanBeCatchedMapId(petInfo.templateId)
  self.curPetCatchMapId = mapId
end
def.method("userdata").OnCatchLevelObjClicked = function(self, obj)
  local parentId = obj.transform.parent.gameObject.name
  local index = tonumber(string.sub(parentId, #"item_" + 1, -1))
  self.selectedPos[1] = index
  self.selectedPos[2] = 1
  self:UpdateSameCatchLevelPetsInfo()
end
def.method().OnBuyPetButtonClick = function(self)
  if not self.isMoneyEnough then
    Toast(textRes.Common[13])
  elseif PetMgr.Instance():IsPetFullest() then
    PetModule.Instance():ShowPetBagIsFullConfirm()
  else
    local petInfo = self:GetSelectedPetInfo()
    PetShopMgr.Instance():BuyPet(petInfo.templateId)
  end
end
def.method("string").onDragStart = function(self, id)
  print("onDragStart", id)
  self.dragObjId = id
end
def.method("string").onDragEnd = function(self, id)
  self.dragObjId = ""
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if string.sub(id, 1, #"Img_BgPet_") ~= "Img_BgPet_" then
    return
  end
  local index = tonumber(string.sub(id, #"Img_BgPet_" + 1, -1))
  if self.models[index] then
    self.models[index]:SetDir(self.models[index].m_ang - dx / 2)
  end
end
def.method("number").OnClickPetModel = function(self, index)
  self.selectedPos[2] = index
  self:UpdateSelectedPetInfo()
  PetUtility.PlayPetClickedAnimation(self.models[index])
end
def.method().OnCatchPetButtonClicked = function(self)
  PetMgr.Instance():GoToCatchPet(self.curPetCatchMapId)
  self:DestroyPanel()
end
def.method().OnAddSilverButtonClicked = function(self)
  GoToBuySilver(false)
end
def.method().RefreshNeededPet = function(self)
  if self.canBuyPetList == nil then
    return
  end
  local templateId = PetShopMgr.Instance():GetNextNeededPetTemplateId()
  if templateId == 0 and self.closeWhenFinished then
    self.closeWhenFinished = false
    self:DestroyPanel()
    return
  end
  self:SetNeededPetTemplateId(templateId, self.closeWhenFinished)
  self.selectedPos = self:FindNeededPetPos()
  self:UpdateSameCatchLevelPetsInfo()
end
def.static("table", "table").OnSilverMoneyChanged = function()
  local self = instance
  if self.selectedPos == nil then
    return
  end
  if not self:IsShow() then
    return
  end
  self:UpdateSelectedPetInfo()
end
def.static("table", "table").OnBuyPetSuccess = function(params)
  local self = instance
  self:RefreshNeededPet()
end
def.static("table", "table").OnTaskInfoChanged = function(params)
  local self = instance
  require("Main.Common.FunctionQueue").Instance():Push(function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self:RefreshNeededPet()
  end)
end
def.static("table", "table").OnPetSellListChanged = function(params)
  local self = instance
  if not self:IsShow() then
    return
  end
  self:UpdateUI()
end
return PetShopBuyPanel.Commit()
