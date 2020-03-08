local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetShopSellPanel = Lplus.Extend(ECPanelBase, "PetShopSellPanel")
local def = PetShopSellPanel.define
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local PetData = Lplus.ForwardDeclare("PetData")
local PetUtility = require("Main.Pet.PetUtility")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local ECModel = require("Model.ECModel")
local PetShopMgr = require("Main.Pet.mgr.PetShopMgr")
def.field("table").petList = nil
def.field("number").nextFocusIndex = 0
def.field("table").uiObjs = nil
local instance
def.static("=>", PetShopSellPanel).Instance = function()
  if instance == nil then
    instance = PetShopSellPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:UpdateUI()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_STORE_SELL_PANEL_RES, 1)
  self:SetModal(true)
  PetShopMgr.Instance():ReqCanSellPetNum()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SHOP_SELL_PET_SUCCESS, PetShopSellPanel.OnSellPetSuccess)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SHOP_SELL_PET_SUCCESS, PetShopSellPanel.OnSellPetSuccess)
  self:Clear()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Sell" then
    self:OnSellButtonObjClicked(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  end
end
def.method().Clear = function(self)
  self.uiObjs = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Empty = self.uiObjs.Img_Bg0:FindDirect("Group_Empty")
  self.uiObjs.Group_Sell = self.uiObjs.Img_Bg0:FindDirect("Group_Sell")
  self.uiObjs.Label_Tips = self.uiObjs.Img_Bg0:FindDirect("Label_Tips")
  self.uiObjs.Grid = self.uiObjs.Group_Sell:FindDirect("Scroll View/Grid")
  self.nextFocusIndex = 0
end
def.method().UpdateUI = function(self)
  self:UpdateOnSellPetList()
  self:UpdateCanSellPetAmount()
end
def.method().UpdateOnSellPetList = function(self)
  self.petList = PetShopMgr.Instance():GetCanSellPetList()
  local amount = #self.petList
  if amount == 0 then
    self:ShowEmptyUI(true)
  else
    self:ShowEmptyUI(false)
    self:SetOnSellPetList(self.petList)
  end
end
def.method("boolean").ShowEmptyUI = function(self, state)
  self.uiObjs.Group_Empty:SetActive(state)
  self.uiObjs.Group_Sell:SetActive(not state)
end
def.method("table").SetOnSellPetList = function(self, petList)
  local uiList = self.uiObjs.Grid:GetComponent("UIList")
  local amount = #petList
  uiList.itemCount = amount
  uiList:Resize()
  local itemObjs = uiList.children
  for i = 1, amount do
    local pet = petList[i]
    local petCfg = pet:GetPetCfgData()
    local info = {}
    info.name = pet.name
    info.initName = petCfg.templateName
    info.price = PetShopMgr.Instance():CalcSellPrice(petCfg.buyPrice)
    self:SetOnSellPetInfo(itemObjs[i], info)
  end
  uiList:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
  GameUtil.AddGlobalLateTimer(0, true, function()
    if self.uiObjs == nil then
      return
    end
    local uiScrollView = self.uiObjs.Grid.transform.parent.gameObject:GetComponent("UIScrollView")
    local item = itemObjs[self.nextFocusIndex]
    uiScrollView:UpdatePosition()
    if item then
      uiScrollView:DragToMakeVisible(item.transform, 4)
    end
  end)
end
def.method("userdata", "table").SetOnSellPetInfo = function(self, itemObj, info)
  local nameText
  if info.name == info.initName then
    nameText = info.name
  else
    nameText = string.format(textRes.Pet[78], info.initName, info.name)
  end
  itemObj:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(nameText)
  itemObj:FindDirect("Group_Price/Label_Num"):GetComponent("UILabel"):set_text(info.price)
end
def.method("userdata").OnSellButtonObjClicked = function(self, obj)
  local amount = PetShopMgr.Instance():GetCanSellPetAmount()
  if amount == 0 then
    Toast(textRes.Pet[82])
    return
  end
  local parentId = obj.transform.parent.gameObject.name
  local index = tonumber(string.sub(parentId, #"item_" + 1, -1))
  local pet = self.petList[index]
  if pet.isFighting then
    Toast(textRes.Pet[84])
    return
  end
  PetShopMgr.Instance():SellPet(pet.id)
  if index == #self.petList then
    self.nextFocusIndex = index - 1
  else
    self.nextFocusIndex = index
  end
end
def.method().OnClickPetModel = function(self)
  PetUtility.PlayPetClickedAnimation(self._model)
end
def.method().UpdateCanSellPetAmount = function(self)
  local amount = PetShopMgr.Instance():GetCanSellPetAmount()
  self:SetCanSellPetAmount(amount)
end
def.method("number").SetCanSellPetAmount = function(self, amount)
  local text = string.format(textRes.Pet[81], amount)
  self.uiObjs.Label_Tips:GetComponent("UILabel"):set_text(text)
end
def.static("table", "table").OnSellPetSuccess = function()
  local self = instance
  self:UpdateUI()
end
return PetShopSellPanel.Commit()
