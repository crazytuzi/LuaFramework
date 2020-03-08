local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local PetExchangeMgr = Lplus.ForwardDeclare("PetExchangeMgr")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local PetExChangePanel = Lplus.Extend(ECPanelBase, "PetExChangePanel")
local def = PetExChangePanel.define
def.field("number").m_TargetPetType = 0
def.field("number").m_SelectPetId = 0
def.field("table").m_TargetPetsCfg = nil
def.field("table").m_uiObjs = nil
def.field("table").m_NeedItems = nil
local instance
def.static("=>", PetExChangePanel).Instance = function()
  if nil == instance then
    instance = PetExChangePanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, targetType)
  if self:IsShow() then
    return
  end
  self.m_SelectPetId = 0
  self.m_TargetPetType = targetType
  self:CreatePanel(RESPATH.PREFAB_PET_SHENSHOU_EXCHANGE_RES, 1)
  self:SetModal(true)
end
local function onBagInfoSynChange()
  local self = PetExChangePanel.Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateNeedItemView()
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, onBagInfoSynChange)
  self:InitUI()
  self:InitData()
  self:UpdateNeedData()
  self:UpdateUI()
end
def.override("boolean").OnShow = function(self, s)
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  self.m_uiObjs.ScrollView = self.m_panel:FindDirect("Img_Bg0/Container/Img_BgItem/Scroll View_Item")
  self.m_uiObjs.GridView = self.m_uiObjs.ScrollView:FindDirect("Grid_Item")
  self.m_uiObjs.NeedItemView = self.m_panel:FindDirect("Img_Bg0/Item_001")
  self.m_uiObjs.NeedItemTip = self.m_panel:FindDirect("Img_Bg0/Label")
  self.m_uiObjs.NeedItemView.name = "NeedItemBtn"
end
def.method().InitData = function(self)
  self.m_TargetPetsCfg = PetExchangeMgr.Instance():GetTargetPetsCfg(self.m_TargetPetType)
end
def.method().UpdateNeedData = function(self)
  self.m_NeedItems = PetExchangeMgr.Instance():GetShenShouDuiHuanNeedItems(self.m_SelectPetId)
end
def.method().UpdateUI = function(self)
  local petNum = #self.m_TargetPetsCfg
  local typeName = string.format("%s%s", textRes.Pet[138], textRes.Pet[136])
  if self.m_TargetPetType == PetType.MOSHOU then
    typeName = string.format("%s%s", textRes.Pet[138], textRes.Pet[137])
  end
  local typeLabel = self.m_panel:FindDirect("Img_Bg0/Container/Label1")
  typeLabel:GetComponent("UILabel"):set_text(typeName)
  self:ResizeGridView(petNum)
  self:FillGridView()
  self:UpdateNeedItemView()
end
def.method().UpdateNeedItemView = function(self)
  local LabelName = self.m_uiObjs.NeedItemView:FindDirect("Label_Name")
  local LabelNum = self.m_uiObjs.NeedItemView:FindDirect("Label_Num")
  local ItemTexture = self.m_uiObjs.NeedItemView:FindDirect("Img_Icon")
  local BgSprite = self.m_uiObjs.NeedItemView:FindDirect("Img_Bg")
  if nil ~= self.m_NeedItems then
    self.m_uiObjs.NeedItemTip:SetActive(true)
    self.m_uiObjs.NeedItemView:SetActive(true)
    local itemsInfo = self.m_NeedItems
    if itemsInfo and #itemsInfo > 0 then
      local itemIdList = itemsInfo[1].itemIdList
      local needItemId = itemIdList[1]
      local needItemBase = ItemUtils.GetItemBase(needItemId)
      local needItemCount = itemsInfo[1].itemCount
      local hasItemNum = 0
      for _, itemId in pairs(itemIdList) do
        hasItemNum = hasItemNum + ItemModule.Instance():GetItemCountById(itemId)
      end
      local itemLabelStr = string.format("%d/%d", needItemCount, hasItemNum)
      if needItemCount > hasItemNum then
        LabelNum:GetComponent("UILabel"):set_textColor(Color.red)
      else
        LabelNum:GetComponent("UILabel"):set_textColor(Color.white)
      end
      LabelNum:GetComponent("UILabel"):set_text(itemLabelStr)
      LabelName:GetComponent("UILabel"):set_text(needItemBase.name)
      local bgSpriteName = string.format("Cell_%02d", needItemBase.namecolor)
      BgSprite:GetComponent("UISprite"):set_spriteName(bgSpriteName)
      local icon = needItemBase.icon
      GUIUtils.FillIcon(ItemTexture:GetComponent("UITexture"), icon)
      return
    end
  end
  LabelName:GetComponent("UILabel"):set_text(textRes.Pet[135])
  LabelNum:GetComponent("UILabel"):set_textColor(Color.white)
  LabelNum:GetComponent("UILabel"):set_text("0/0")
  BgSprite:GetComponent("UISprite"):set_spriteName("Cell_00")
  GUIUtils.FillIcon(ItemTexture:GetComponent("UITexture"), 0)
  self.m_uiObjs.NeedItemView:SetActive(false)
  self.m_uiObjs.NeedItemTip:SetActive(false)
end
def.method("number").ResizeGridView = function(self, totalNum)
  local listNum = self.m_uiObjs.GridView:GetComponent("UIGrid"):GetChildListCount()
  local needAddNum = totalNum - listNum
  local template = self.m_uiObjs.GridView.transform:GetChild(listNum - 1).gameObject
  if template then
    if needAddNum > 0 then
      for i = 1, needAddNum do
        local newObj = GameObject.Instantiate(template)
        newObj.name = string.format("Item_0%02d", listNum + i)
        newObj.transform.parent = self.m_uiObjs.GridView.transform
        newObj.transform.localScale = Vector.Vector3.one
        newObj:SetActive(true)
      end
    elseif needAddNum < 0 then
      for i = listNum - 1, totalNum - 1, -1 do
        local itemObj = self.m_uiObjs.GridView.transform:GetChild(i).gameObject
        itemObj:SetActive(false)
      end
    end
  end
end
def.method().FillGridView = function(self)
  local itemNum = self.m_uiObjs.GridView:GetComponent("UIGrid"):GetChildListCount()
  for i = 1, itemNum do
    local itemObj = self.m_uiObjs.GridView:FindDirect(string.format("Item_0%02d", i))
    if itemObj then
      local texture = itemObj:FindDirect("Img_Icon")
      local nameLabel = itemObj:FindDirect("Label_Name")
      local petcfg = self.m_TargetPetsCfg[i]
      if petcfg and texture and nameLabel then
        local icon = petcfg.icon
        local name = petcfg.name
        GUIUtils.FillIcon(texture:GetComponent("UITexture"), icon)
        nameLabel:GetComponent("UILabel"):set_text(name)
      end
    end
  end
  self.m_msgHandler:Touch(self.m_uiObjs.ScrollView)
end
def.override().OnDestroy = function(self)
  if self.m_uiObjs then
    for k, v in pairs(self.m_uiObjs) do
      v = nil
    end
  end
  self.m_uiObjs = nil
  self.m_TargetPetType = 0
  self.m_SelectPetId = 0
  self.m_TargetPetsCfg = nil
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, onBagInfoSynChange)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local objName = clickObj.name
  if objName == "Btn_Close" then
    self:DestroyPanel()
  elseif objName == "Btn_TuJian" then
    self:OnClickTuJianBtn()
  elseif objName == "Btn_Sell" then
    self:OnClickDuiHuanShenShou()
  elseif string.find(objName, "Item_") then
    local strs = string.split(objName, "_")
    local index = tonumber(strs[2])
    self.m_SelectPetId = self.m_TargetPetsCfg[index].id
    local uiToggle = clickObj:GetComponent("UIToggle")
    if uiToggle then
      uiToggle.value = true
    end
    self:UpdateNeedData()
    self:UpdateNeedItemView()
  elseif objName == "NeedItemBtn" and self.m_NeedItems then
    local wPos = clickObj.position
    local screenPos = WorldPosToScreen(wPos.x, wPos.y)
    local uiWidget = clickObj:GetComponent("UIWidget")
    local width = uiWidget:get_width()
    local height = uiWidget:get_height()
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    local itemIdList = self.m_NeedItems[1].itemIdList
    ItemTipsMgr.Instance():ShowBasicTips(itemIdList[1], screenPos.x, screenPos.y, width, height, 0, true)
  end
end
def.method("string").onLongPress = function(self, id)
  if string.find(id, "Item_") then
    local pressObj = self.m_panel:FindDirect("Img_Bg0/Container/Img_BgItem/Scroll View_Item/Grid_Item/" .. id)
    if pressObj then
      local uiToggle = pressObj:GetComponent("UIToggle")
      if uiToggle then
        uiToggle.value = true
      end
      local strs = string.split(id, "_")
      local index = tonumber(strs[2])
      self.m_SelectPetId = self.m_TargetPetsCfg[index].id
      self:UpdateNeedData()
      self:UpdateNeedItemView()
      self:OnClickTuJianBtn()
    end
  end
end
def.method().OnClickTuJianBtn = function(self)
  if self.m_SelectPetId == 0 then
    PetExchangeMgr.Instance():ShowTuJianPanel()
  else
    PetExchangeMgr.Instance():ShowSpecifyTuJianPanel(self.m_SelectPetId)
  end
end
def.method().OnClickDuiHuanShenShou = function(self)
  if self.m_NeedItems and 0 ~= self.m_SelectPetId then
    if not self:hasEnoughExChangeItem() then
      Toast(textRes.Pet[141])
      return
    end
    if self.m_TargetPetType == PetType.SHENSHOU then
      PetExchangeMgr.Instance():CGoldPetRedeemReq(self.m_SelectPetId)
    elseif self.m_TargetPetType == PetType.MOSHOU then
      PetExchangeMgr.Instance():CMoShouPetRedeemReq(self.m_SelectPetId)
    end
  else
    Toast(textRes.Pet[140])
  end
end
def.method("=>", "boolean").hasEnoughExChangeItem = function(self)
  if self.m_NeedItems and 0 ~= self.m_SelectPetId then
    for k, itemsInfo in pairs(self.m_NeedItems) do
      local itemIds = itemsInfo.itemIdList
      local itemNeedCount = itemsInfo.itemCount
      local hasCount = 0
      for _, itemId in pairs(itemIds) do
        hasCount = hasCount + ItemModule.Instance():GetItemCountById(itemId)
      end
      if itemNeedCount > hasCount then
        return false
      end
    end
    return true
  else
    return false
  end
end
PetExChangePanel.Commit()
return PetExChangePanel
