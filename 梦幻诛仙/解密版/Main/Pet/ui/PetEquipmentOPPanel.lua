local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetEquipmentOPPanel = Lplus.Extend(ECPanelBase, "PetEquipmentOPPanel")
local def = PetEquipmentOPPanel.define
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
local PetData = Lplus.ForwardDeclare("PetData")
local PetUtility = require("Main.Pet.PetUtility")
local PetModule = require("Main.Pet.PetModule")
local PetEquipmentMgr = require("Main.Pet.mgr.PetEquipmentMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local EasyItemTipHelper = require("Main.Pet.EasyItemTipHelper")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local instance
local NOT_SET = -1
local NOT_ASSOCIATE_PET = Int64.new(-1)
def.const("table").Page = {Composite = 1, Refresh = 2}
def.field("number").selectedPage = 1
def.field("table").petItemKeyList = nil
def.field("number").petItemNum = 0
def.field("number").compItemKey1 = NOT_SET
def.field("number").compItemKey2 = NOT_SET
def.field("number").compTargetItemKey = NOT_SET
def.field("number").selectedAmuletKey = NOT_SET
def.field("userdata").selectedAmuletPetId = nil
def.field("number").selectedAmuletPetType = -1
def.field("number").xiLianItemNum = 0
def.field("number").xilianItemId = 0
def.field("table").canOperateItems = nil
def.field("number").selectedGridItemIndex = 0
def.field(EasyItemTipHelper).easyItemTipHelper = nil
def.field("userdata").ui_Gride_ItemCreat = nil
def.field("table").uiObjs = nil
def.static("=>", PetEquipmentOPPanel).Instance = function()
  if instance == nil then
    instance = PetEquipmentOPPanel()
    instance.selectedAmuletPetId = NOT_ASSOCIATE_PET
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_EQUIPEMENT_OP_PANEL_RES, 2)
  self:SetModal(true)
end
def.method("number").SetActivePage = function(self, page)
  self.selectedPage = page
  if self:IsShow() then
    self:UpdateItem()
  end
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
  self:Clear()
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.SUCCESS_COMPOSITE_EQUIPMENT, PetEquipmentOPPanel.OnSuccessCompositeEquipment)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetEquipmentOPPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REFRESH_AMULET_SUCCESS, PetEquipmentOPPanel.OnRefreshAmuletSucc)
  self:UpdateItem()
  self.easyItemTipHelper = EasyItemTipHelper()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.SUCCESS_COMPOSITE_EQUIPMENT, PetEquipmentOPPanel.OnSuccessCompositeEquipment)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetEquipmentOPPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REFRESH_AMULET_SUCCESS, PetEquipmentOPPanel.OnRefreshAmuletSucc)
  self.ui_Gride_ItemCreat = nil
  self.uiObjs = nil
  self.selectedPage = PetEquipmentOPPanel.Page.Composite
  self.easyItemTipHelper = nil
  self.canOperateItems = nil
  self.selectedAmuletPetId = NOT_ASSOCIATE_PET
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.ui_Gride_ItemCreat = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Img_BgCreat/Scroll View_ItemCreat/Gride_ItemCreat")
  self.uiObjs.Gride_ItemCreat = self.ui_Gride_ItemCreat
  self.uiObjs.fxObj = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Widget_Particle")
  self.uiObjs.fxObj:SetActive(false)
  self:FindChild("Label_WashTips01"):SetActive(false)
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Creat" then
    self:OnCompositeButtonClick()
  elseif id == "Img_ItemCreatA" then
    self:OnCompSourceAClick()
  elseif id == "Img_ItemCreatB" then
    self:OnCompSourceBClick()
  elseif id == "Img_ItemCreatC" then
    self:OnCompTargetClick()
  elseif string.sub(id, 1, 14) == "Img_ItemCreat_" then
    self:OnClickPetEquipment(id)
  elseif id == "Btn_Wash" then
    self:OnRefreshAmuletButtonClick()
  elseif id == "Tap_Creat" or id == "Tap_Wash" then
    self:onTapClick(id)
  elseif id == "Btn_Tips" then
    self:OnTipsButtonClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif self.easyItemTipHelper:CheckItem2ShowTip(id) then
  end
end
def.method("string").onDoubleClick = function(self, id)
  print(string.format("%s double click event: id = %s", tostring(self), id))
  if string.sub(id, 1, 14) == "Img_ItemCreat_" then
    self:OnDoubleClickPetEquipment(id)
  elseif id == "Img_ItemCreatA" then
    self:OnCompSourceADoubleClick()
  elseif id == "Img_ItemCreatB" then
    self:OnCompSourceBDoubleClick()
  end
end
def.method("string").onTapClick = function(self, id)
  if id == "Tap_Creat" and self.selectedPage ~= PetEquipmentOPPanel.Page.Composite then
    self.selectedPage = PetEquipmentOPPanel.Page.Composite
    self:FillPetEquipmentCompPage()
  elseif id == "Tap_Wash" and self.selectedPage ~= PetEquipmentOPPanel.Page.Refresh then
    self.selectedPage = PetEquipmentOPPanel.Page.Refresh
    self:FillPetAmuletRefreshPage()
  end
end
def.method().OnCompTargetClick = function(self)
  if self.compTargetItemKey ~= NOT_SET then
    self:ShowItemTip(self.compTargetItemKey, "Img_ItemCreatC")
  end
end
def.method().OnCompSourceAClick = function(self)
  if self.compItemKey1 ~= NOT_SET then
    self:ShowItemTip(self.compItemKey1, "Img_ItemCreatA")
  end
end
def.method().OnCompSourceBClick = function(self)
  if self.compItemKey2 ~= NOT_SET then
    self:ShowItemTip(self.compItemKey2, "Img_ItemCreatB")
  end
end
def.method("string").OnClickPetEquipment = function(self, id)
  local index = tonumber(string.sub(id, 15, -1))
  if self.canOperateItems[index] == nil then
    return
  end
  self.selectedGridItemIndex = index
  local isCompPage = self.m_panel:FindChild("Tap_Creat"):GetComponent("UIToggle").value
  local itemKey = self.petItemKeyList[index]
  if isCompPage then
  else
    self.selectedAmuletPetType = self.canOperateItems[index].type or -1
    if itemKey == nil then
      itemKey = NOT_SET
      if self.canOperateItems[index].petId ~= nil then
        self.selectedAmuletPetId = self.canOperateItems[index].petId
      else
        self.selectedAmuletPetId = NOT_ASSOCIATE_PET
      end
    end
    self.selectedAmuletKey = itemKey
    self:UpdateAmuletRefreshNeed()
  end
  if itemKey ~= NOT_SET then
    self:ShowItemTip(itemKey, "Img_ItemCreat_" .. index)
  else
    self:ShowPetEquipItemTip(self.selectedAmuletPetType, self.canOperateItems[index].petId, "Img_ItemCreat_" .. index)
  end
  local Img_ItemCreat = self.uiObjs.Gride_ItemCreat:FindDirect("Img_ItemCreat_" .. index)
  GUIUtils.Toggle(Img_ItemCreat, true)
end
def.method("string").OnDoubleClickPetEquipment = function(self, id)
  if not self.m_panel:FindChild("Tap_Creat"):GetComponent("UIToggle").value then
    return
  end
  local index = tonumber(string.sub(id, 15, -1))
  local itemKey = self.petItemKeyList[index]
  if itemKey == nil then
    return
  end
  local dirty = false
  if self.compItemKey1 == NOT_SET and self.compItemKey2 == NOT_SET then
    self.compItemKey1 = itemKey
    dirty = true
  elseif self.compItemKey1 == NOT_SET and self.compItemKey2 ~= NOT_SET then
    local item1 = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
    local equipCfg1 = PetUtility.GetPetEquipmentCfg(item1.id)
    local item2 = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, self.compItemKey2)
    local equipCfg2 = PetUtility.GetPetEquipmentCfg(item2.id)
    if equipCfg1.equipLevel == equipCfg2.equipLevel and equipCfg1.equipType == equipCfg2.equipType then
      self.compItemKey1 = itemKey
      dirty = true
    else
      Toast(textRes.Pet[37])
    end
  elseif self.compItemKey1 ~= NOT_SET and self.compItemKey2 == NOT_SET then
    local item1 = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, self.compItemKey1)
    local equipCfg1 = PetUtility.GetPetEquipmentCfg(item1.id)
    local item2 = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
    local equipCfg2 = PetUtility.GetPetEquipmentCfg(item2.id)
    if equipCfg1.equipLevel == equipCfg2.equipLevel and equipCfg1.equipType == equipCfg2.equipType then
      self.compItemKey2 = itemKey
      dirty = true
    else
      Toast(textRes.Pet[37])
    end
  else
    Toast(textRes.Pet[38])
  end
  if dirty then
    self.compTargetItemKey = NOT_SET
    self:UpdatePetEquipmentItem()
  end
end
def.method().OnCompSourceADoubleClick = function(self)
  self.compItemKey1 = NOT_SET
  self:UpdatePetEquipmentItem()
end
def.method().OnCompSourceBDoubleClick = function(self)
  self.compItemKey2 = NOT_SET
  self:UpdatePetEquipmentItem()
end
def.method().OnCompositeButtonClick = function(self)
  if self.compItemKey1 ~= NOT_SET and self.compItemKey2 ~= NOT_SET then
    PetEquipmentMgr.Instance():MergePetEquipReq(self.compItemKey1, self.compItemKey2)
    self.compItemKey1 = NOT_SET
    self.compItemKey2 = NOT_SET
  else
    Toast(textRes.Pet[39])
  end
end
def.method().OnRefreshAmuletButtonClick = function(self)
  if (self.selectedAmuletKey ~= NOT_SET or self.selectedAmuletPetId ~= NOT_ASSOCIATE_PET) and self.xiLianItemNum >= PetModule.PET_REFRESH_AMULET_USE_ITEM_NUM then
    if self.selectedAmuletPetType == GameUnitType.CHILDREN then
      require("Main.Children.mgr.YouthMgr").Instance():AmuletRefreshReq(self.selectedAmuletPetId, 0)
    else
      PetEquipmentMgr.Instance():AmuletRefreshReq(self.selectedAmuletKey, false, 0, self.selectedAmuletPetId)
    end
  elseif (self.selectedAmuletKey ~= NOT_SET or self.selectedAmuletPetId ~= NOT_ASSOCIATE_PET) and self.xiLianItemNum < PetModule.PET_REFRESH_AMULET_USE_ITEM_NUM then
    local function callback(select)
      if self.m_panel and not self.m_panel.isnil then
        if select > 0 then
          local yuanbaoNum = select
          if self.selectedAmuletPetType == GameUnitType.CHILDREN then
            require("Main.Children.mgr.YouthMgr").Instance():AmuletRefreshReq(self.selectedAmuletPetId, yuanbaoNum)
          else
            PetEquipmentMgr.Instance():AmuletRefreshReq(self.selectedAmuletKey, true, yuanbaoNum, self.selectedAmuletPetId)
          end
        else
          Toast(textRes.Pet[41])
        end
      end
    end
    local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
    ItemConsumeHelper.Instance():ShowItemConsume("", textRes.Pet[151], self.xilianItemId, PetModule.PET_REFRESH_AMULET_USE_ITEM_NUM, callback)
  elseif 0 < #self.petItemKeyList then
    Toast(textRes.Pet[147])
  else
    Toast(textRes.Pet[146])
  end
end
def.static("table", "table").OnSuccessCompositeEquipment = function(param1)
  local itemKey = param1[1]
  local self = instance
  self.compItemKey1 = NOT_SET
  self.compItemKey2 = NOT_SET
  self.compTargetItemKey = itemKey
  self:UpdatePetEquipmentItem()
  local Vector = require("Types.Vector")
  local targetItem = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Group_Creat/Img_ItemCreatC")
  local fxObj = GameObject.Instantiate(self.uiObjs.fxObj)
  fxObj.transform.parent = targetItem.transform
  fxObj.transform.localPosition = Vector.Vector3.zero
  fxObj:SetActive(false)
  fxObj:SetActive(true)
  GameUtil.AddGlobalTimer(0.71, true, function()
    if fxObj and not fxObj.isnil then
      GameObject.Destroy(fxObj)
      fxObj = nil
    end
  end)
  Toast(textRes.Pet[40])
end
def.static("table", "table").OnBagInfoSynchronized = function()
  local self = instance
  if self.selectedPage == PetEquipmentOPPanel.Page.Composite then
    self:UpdatePetEquipmentItem()
  else
    self:UpdatePetAmuletItem()
  end
end
def.static("table", "table").OnRefreshAmuletSucc = function(params)
  local self = PetEquipmentOPPanel.Instance()
  local Vector = require("Types.Vector")
  if self.selectedGridItemIndex ~= 0 and (self.selectedAmuletKey ~= NOT_SET or self.selectedAmuletPetId ~= NOT_ASSOCIATE_PET) then
    local gridItem = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Img_BgCreat/Scroll View_ItemCreat/Gride_ItemCreat/Img_ItemCreat_" .. tostring(self.selectedGridItemIndex))
    if gridItem and not gridItem.isnil then
      do
        local fxObj = GameObject.Instantiate(self.uiObjs.fxObj)
        if fxObj and not fxObj.isnil then
          fxObj.transform.parent = gridItem.transform
          fxObj.transform.localPosition = Vector.Vector3.zero
          fxObj:set_localScale(Vector3.new(1, 1, 1))
          fxObj:SetActive(true)
          do
            local gridObj = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Img_BgCreat/Scroll View_ItemCreat/Gride_ItemCreat")
            local uiGrid = gridObj:GetComponent("UIGrid")
            GameUtil.AddGlobalLateTimer(0.71, true, function()
              if fxObj and not fxObj.isnil and uiGrid then
                GameObject.Destroy(fxObj)
                fxObj = nil
                uiGrid:Reposition()
              end
            end)
          end
        end
      end
    end
  end
end
def.method().FillPetEquipmentCompPage = function(self)
  self.compItemKey1 = NOT_SET
  self.compItemKey2 = NOT_SET
  self.compTargetItemKey = NOT_SET
  self.selectedGridItemIndex = 0
  self:UpdatePetEquipmentItem()
end
def.method().Clear = function(self)
  self.petItemKeyList = nil
  self.petItemNum = 0
  self.compItemKey1 = NOT_SET
  self.compItemKey2 = NOT_SET
  self.compTargetItemKey = NOT_SET
end
def.method().UpdatePetEquipmentItem = function(self)
  self:SetPetEquipmentItems(nil)
  self:SetCompSourceItems()
  self:SetCompTargetItem()
end
def.method("function").SetPetEquipmentItems = function(self, filter)
  local gridObj = self.m_panel:FindChild("Gride_ItemCreat")
  local gridComponent = gridObj:GetComponent("UIGrid")
  local itemTemplateRaw = gridObj:FindChild("Img_ItemCreat")
  if itemTemplateRaw then
    itemTemplateRaw.name = "Img_ItemCreat_0"
    itemTemplateRaw:SetActive(false)
    itemTemplateRaw:GetComponent("UIToggle").optionCanBeNone = true
    local gridItemCount = gridComponent:GetChildListCount()
    local gridChildList = gridComponent:GetChildList()
    for i = 1, gridItemCount do
      if gridChildList[i].gameObject.name == "Img_ItemCreat" then
        gridChildList[i].gameObject:SetActive(false)
        GameObject.Destroy(gridChildList[i].gameObject)
        gridChildList[i] = nil
      end
    end
  else
    itemTemplateRaw = gridObj:FindChild("Img_ItemCreat_0")
  end
  self.petItemKeyList = {}
  self.canOperateItems = {}
  local count = 0
  local items = ItemModule.Instance():GetItemsByBagId(ItemModule.BAG)
  if self.selectedPage == PetEquipmentOPPanel.Page.Refresh then
    local PetMgrInstance = require("Main.Pet.mgr.PetMgr").Instance()
    local petList = PetMgrInstance:GetPetList()
    local petCount = PetMgrInstance:GetPetNum()
    for id, petData in pairs(petList) do
      local amuletItem = petData.equipments[PetData.PetEquipmentType.EQUIP_AMULET]
      if amuletItem ~= nil then
        local itemBase = ItemUtils.GetItemBase(amuletItem.id)
        local itemData = {}
        itemData.item = amuletItem
        itemData.itemBase = itemBase
        itemData.petId = petData.id
        itemData.type = GameUnitType.PET
        table.insert(self.canOperateItems, itemData)
        count = count + 1
      end
    end
    local children = require("Main.Children.ChildrenDataMgr").Instance():GetFightChildren()
    if children then
      for _, child in pairs(children) do
        local PetEquipType = require("consts.mzm.gsp.petequip.confbean.PetEquipType")
        local amulet = child.info.equipPetItem[PetEquipType.AMULET]
        if amulet then
          local itemBase = ItemUtils.GetItemBase(amulet.id)
          local itemData = {}
          itemData.item = amulet
          itemData.itemBase = itemBase
          itemData.petId = child.id
          itemData.type = GameUnitType.CHILDREN
          table.insert(self.canOperateItems, itemData)
          count = count + 1
        end
      end
    end
  end
  for key, item in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(item.id)
    if itemBase.itemType == ItemType.PET_EQUIP and key ~= self.compItemKey1 and key ~= self.compItemKey2 and (filter == nil or filter(item)) then
      local itemData = {}
      itemData.item = item
      itemData.itemBase = itemBase
      table.insert(self.canOperateItems, itemData)
      count = count + 1
      self.petItemKeyList[count] = key
    end
  end
  local count = #self.canOperateItems
  for i = 1, count do
    local itemData = self.canOperateItems[i]
    self:AddItem(gridObj, i, itemData.item, itemData.itemBase)
  end
  gridComponent:Reposition()
  local gridItemCount = gridComponent:GetChildListCount()
  local gridChildList = gridComponent:GetChildList()
  for i = count + 1, gridItemCount do
    gridComponent:RemoveChild(gridChildList[i])
    GameObject.Destroy(gridChildList[i].gameObject)
    gridChildList[i] = nil
  end
  gridComponent:Reposition()
  gridComponent.gameObject.transform.parent.gameObject:GetComponent("UIScrollView"):ResetPosition()
  self:TouchGameObject(self.m_panel, self.m_parent)
  self.petItemNum = count
end
def.method("userdata", "number", "table", "table").AddItem = function(self, gridObj, index, itemInfo, itemBase)
  local gridComponent = gridObj:GetComponent("UIGrid")
  local itemTemplate = gridObj:FindDirect("Img_ItemCreat_0")
  local newItem = gridObj:FindDirect("Img_ItemCreat_" .. index)
  if newItem == nil then
    newItem = GameObject.Instantiate(itemTemplate)
    newItem.name = "Img_ItemCreat_" .. index
    newItem:SetActive(true)
    gridComponent:AddChild(newItem.transform)
    newItem:set_localScale(Vector3.new(1, 1, 1))
  end
  newItem:GetComponent("UIToggle"):set_value(false)
  if index == self.selectedGridItemIndex then
    newItem:GetComponent("UIToggle"):set_value(true)
  end
  local uiTexture = newItem:FindChild("Icon_ItemCreatIcon01"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local Img_EquipMark = newItem:FindDirect("Img_EquipMark01")
  if self.petItemKeyList[index] == nil then
    GUIUtils.SetActive(Img_EquipMark, true)
  else
    GUIUtils.SetActive(Img_EquipMark, false)
  end
end
def.method().SetCompSourceItems = function(self)
  local uiTexture = self.m_panel:FindChild("Icon_ItemCreatA"):GetComponent("UITexture")
  if self.compItemKey1 ~= NOT_SET then
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, self.compItemKey1)
    local itemBase = ItemUtils.GetItemBase(item.id)
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    self.m_panel:FindChild("Label_ItemCreatA"):GetComponent("UILabel").text = itemBase.name
  else
    uiTexture.mainTexture = nil
    self.m_panel:FindChild("Label_ItemCreatA"):GetComponent("UILabel").text = ""
  end
  local uiTexture = self.m_panel:FindChild("Icon_ItemCreatB"):GetComponent("UITexture")
  if self.compItemKey2 ~= NOT_SET then
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, self.compItemKey2)
    local itemBase = ItemUtils.GetItemBase(item.id)
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    self.m_panel:FindChild("Label_ItemCreatB"):GetComponent("UILabel").text = itemBase.name
  else
    uiTexture.mainTexture = nil
    self.m_panel:FindChild("Label_ItemCreatB"):GetComponent("UILabel").text = ""
  end
end
def.method().SetCompTargetItem = function(self)
  local uiTexture = self.m_panel:FindChild("Img_Bg0/Img_Bg1/Group_Creat/Img_ItemCreatC/Icon_ItemCreatC"):GetComponent("UITexture")
  if self.compTargetItemKey ~= NOT_SET then
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, self.compTargetItemKey)
    if item == nil then
      return
    end
    local itemBase = ItemUtils.GetItemBase(item.id)
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    self.m_panel:FindChild("Label_ItemCreatCNum"):GetComponent("UILabel").text = itemBase.name
  else
    uiTexture.mainTexture = nil
    self.m_panel:FindChild("Label_ItemCreatCNum"):GetComponent("UILabel").text = ""
  end
end
def.method("number", "string").ShowItemTip = function(self, itemKey, sourceObjName)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
  local source = self.m_panel:FindChild(sourceObjName)
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, itemKey, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
end
def.method("number", "userdata", "string").ShowPetEquipItemTip = function(self, petType, petId, sourceObjName)
  local source = self.m_panel:FindChild(sourceObjName)
  local equipment
  if petType == GameUnitType.PET then
    local PetMgrInstance = require("Main.Pet.mgr.PetMgr").Instance()
    local petData = PetMgrInstance:GetPet(petId)
    equipment = petData.equipments[PetData.PetEquipmentType.EQUIP_AMULET]
  elseif petType == GameUnitType.CHILDREN then
    local child_data = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(petId)
    local PetEquipType = require("consts.mzm.gsp.petequip.confbean.PetEquipType")
    equipment = child_data.info.equipPetItem[PetEquipType.AMULET]
  end
  if equipment then
    PetUtility.ShowPetEquipmentTip(equipment, source)
  end
end
def.method().UpdateItem = function(self)
  if self.selectedPage == PetEquipmentOPPanel.Page.Composite then
    self.m_panel:FindDirect("Img_Bg0/Tap_Creat"):GetComponent("UIToggle"):set_value(true)
    self.m_panel:FindDirect("Img_Bg0/Tap_Wash"):GetComponent("UIToggle"):set_value(false)
    self:FillPetEquipmentCompPage()
  else
    self.m_panel:FindDirect("Img_Bg0/Tap_Creat"):GetComponent("UIToggle"):set_value(false)
    self.m_panel:FindDirect("Img_Bg0/Tap_Wash"):GetComponent("UIToggle"):set_value(true)
    self:FillPetAmuletRefreshPage()
  end
end
def.method().FillPetAmuletRefreshPage = function(self)
  self.selectedAmuletKey = NOT_SET
  self.selectedAmuletPetId = NOT_ASSOCIATE_PET
  self.compItemKey1 = NOT_SET
  self.compItemKey2 = NOT_SET
  self.compTargetItemKey = NOT_SET
  self.selectedGridItemIndex = 0
  self:UpdatePetAmuletItem()
end
def.method().UpdatePetAmuletItem = function(self)
  self:SetPetEquipmentItems(PetEquipmentOPPanel.PetAmuletFilter)
  self:UpdateAmuletRefreshNeed()
end
def.static("table", "=>", "boolean").PetAmuletFilter = function(item)
  local itemId = item.id
  local equipCfg = PetUtility.GetPetEquipmentCfg(itemId)
  if equipCfg == nil then
    warn("item(" .. itemId .. ") isn't a pet equipment.")
    return false
  end
  if equipCfg.equipType == PetData.PetEquipmentType.EQUIP_AMULET then
    return true
  end
  return false
end
def.method().UpdateAmuletRefreshNeed = function(self)
  local label_needItemNum = self.m_panel:FindChild("Label_ItemWashNum"):GetComponent("UILabel")
  local label_needItemName = self.m_panel:FindChild("Label_ItemWash"):GetComponent("UILabel")
  local texture_needItemIcon = self.m_panel:FindChild("Icon_ItemWash"):GetComponent("UITexture")
  if self.selectedAmuletKey == NOT_SET and self.selectedAmuletPetId == NOT_ASSOCIATE_PET then
    label_needItemNum.text = ""
    label_needItemName.text = ""
    texture_needItemIcon.mainTexture = nil
  else
    local equipData = self.canOperateItems[self.selectedGridItemIndex]
    local selectedAumlet = equipData.item
    local equipCfg = PetUtility.GetPetEquipmentCfg(selectedAumlet.id)
    local useItemNum = PetModule.PET_REFRESH_AMULET_USE_ITEM_NUM
    local xiLianItemCfg = PetUtility.GetPetXiLianItemCfg()
    local itemId, itemCount, itemLevel = nil, 0, equipCfg.equipLevel - 1
    local itemIdList
    repeat
      itemLevel = itemLevel + 1
      itemIdList = xiLianItemCfg[itemLevel]
      if itemIdList then
        itemCount = 0
        for i, id in ipairs(itemIdList) do
          itemCount = itemCount + ItemModule.Instance():GetItemCountById(id)
          itemId = id
        end
      end
      print(itemCount, itemId)
    until itemIdList == nil or itemCount > 0
    if itemIdList == nil then
      itemLevel = equipCfg.equipLevel
      itemId = xiLianItemCfg[itemLevel][1]
      itemCount = 0
    end
    if itemLevel > equipCfg.equipLevel then
      self:FindChild("Label_WashTips01"):SetActive(true)
    else
      self:FindChild("Label_WashTips01"):SetActive(false)
    end
    print("item id", itemId)
    self.xiLianItemNum = itemCount
    self.xilianItemId = itemId
    local itemBase = ItemUtils.GetItemBase(itemId)
    label_needItemNum.text = _G.GetFormatItemNumString(itemCount, useItemNum)
    label_needItemName.text = itemBase.name
    GUIUtils.FillIcon(texture_needItemIcon, itemBase.icon)
    local clickedObj = texture_needItemIcon.gameObject.transform.parent.gameObject
    self.easyItemTipHelper:RegisterItem2ShowTip(itemId, clickedObj)
  end
end
def.method().OnTipsButtonClicked = function(self)
  local tipId = 0
  if self.selectedPage == PetEquipmentOPPanel.Page.Composite then
    tipId = PetModule.PET_COMPOSITE_EQUIPMENT_TIP_ID
  else
    tipId = PetModule.PET_REFRESH_AMULET_TIP_ID
  end
  require("GUI.GUIUtils").ShowHoverTip(tipId)
end
return PetEquipmentOPPanel.Commit()
