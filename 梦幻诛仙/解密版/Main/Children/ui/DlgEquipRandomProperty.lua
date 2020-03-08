local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgEquipRandomProperty = Lplus.Extend(ECPanelBase, "DlgEquipRandomProperty")
local GUIUtils = require("GUI.GUIUtils")
local def = DlgEquipRandomProperty.define
local ItemUtils = require("Main.Item.ItemUtils")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local instance
def.field("table").equip = nil
def.field("userdata").childId = nil
def.field("table").uiObjs = nil
def.field("number").wearPos = 0
def.static("=>", DlgEquipRandomProperty).Instance = function()
  if instance == nil then
    instance = DlgEquipRandomProperty()
  end
  return instance
end
def.method("userdata", "table", "number").ShowPanel = function(self, childId, equip, wearPos)
  if self.m_panel ~= nil then
    return
  end
  self.childId = childId
  self.equip = equip
  self.wearPos = wearPos
  self:CreatePanel(RESPATH.PREFAB_CHILD_EQUIP_RANDOM, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.uiObjs = {}
  self.uiObjs.group = self.m_panel:FindDirect("Img_Bg0/Group_RandomLabel/Grid_LabelAtt")
  self.uiObjs.confirm = self.m_panel:FindDirect("Img_Bg0/Btn_Confirm")
  self.uiObjs.item = self.m_panel:FindDirect("Img_Bg0/Img_BgEquipMakeItem")
  self.uiObjs.props = {}
  for i = 1, 4 do
    self.uiObjs.props[i] = self.uiObjs.group:FindDirect("Label_Att0" .. i)
  end
  self.uiObjs.curProp = self.m_panel:FindDirect("Img_Bg0/Group_EquipLabel/Label_NumAtt")
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.EQUIP_PROP_UPDATED, DlgEquipRandomProperty.OnPropUpdated)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DlgEquipRandomProperty.OnBagInfoSynchronized)
end
def.override().OnDestroy = function(self)
  self.childId = nil
  self.uiObjs = nil
  self.equip = nil
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.EQUIP_PROP_UPDATED, DlgEquipRandomProperty.OnPropUpdated)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DlgEquipRandomProperty.OnBagInfoSynchronized)
end
def.override("boolean").OnShow = function(self, show)
  if not show then
    return
  end
  self:ShowInfo()
end
def.static("table", "table").OnPropUpdated = function(p1, p2)
  instance:SetPropValue()
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  instance:ShowItems()
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Btn_Camp_") then
    local idx = tonumber(string.sub(id, #"Btn_Camp_" + 1, -1))
    self:OnSelectMenpai(idx)
  elseif id == "Btn_YuanbaoUse" then
    self:UpdateYuanBaoNum(true)
  elseif id == "Img_BgEquipMakeItem" then
    self:ShowItemTip()
  elseif id == "Img_BgEquip" then
    self:ShowEquipTip()
  elseif id == "Btn_Confirm" then
    self:DoRandom()
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method().ShowInfo = function(self)
  local equip_panel = self.m_panel:FindDirect("Img_Bg0/Img_BgEquip/Img_IconEquip01")
  local ui_texture = equip_panel:GetComponent("UITexture")
  if self.equip then
    local itemBase = ItemUtils.GetItemBase(self.equip.id)
    GUIUtils.FillIcon(ui_texture, itemBase.icon)
  else
    GUIUtils.FillIcon(ui_texture, 0)
  end
  local itemCfg = ChildrenUtils.GetChildEquipItem(self.equip.id)
  local level = self.equip.extraMap[ItemXStoreType.CHILDREN_EQUIP_LEVEL]
  local level_cfg = ChildrenUtils.GetChildEquipLevelCfg(itemCfg.levelTypeid, level)
  self.equip.propList = level_cfg.propList
  self:SetPropValue()
  self:ShowItems()
end
def.method().ShowItems = function(self)
  local itemBase = ItemUtils.GetItemBase(constant.CChildrenConsts.child_random_property_main_item)
  if itemBase then
    local texture = self.uiObjs.item:FindDirect("Icon_EquipMakeItem"):GetComponent("UITexture")
    GUIUtils.FillIcon(texture, itemBase.icon)
    local hasNum = require("Main.Item.ItemData").Instance():GetNumByItemType(ItemModule.BAG, ItemType.CHILDREN_EQUIP_RANDOM_PROP_ITEM)
    self.uiObjs.item:FindDirect("Label_EquipMakeName"):GetComponent("UILabel").text = itemBase.name
    self.uiObjs.item:FindDirect("Label_EquipMakeItem"):GetComponent("UILabel").text = string.format("%d/%d", constant.CChildrenConsts.child_random_property_item_count, hasNum)
    self:UpdateYuanBaoNum(false)
  end
end
def.method().SetPropValue = function(self)
  if self.equip == nil or self.equip.propList == nil then
    return
  end
  local currentPropKey = self.equip.extraMap[ItemXStoreType.CHILDREN_EQUIP_PROP_A]
  for i = 1, #self.uiObjs.props do
    local item_panel = self.uiObjs.props[i]
    local prop = self.equip.propList[i]
    if prop and prop.key > 0 then
      local propstr = tostring(prop.value)
      if prop.key == PropertyType.PHY_CRT_VALUE or prop.key == PropertyType.MAG_CRT_VALUE then
        propstr = string.format("%.1f%%", prop.value / 100)
      end
      item_panel:GetComponent("UILabel").text = string.format("%s+%s", textRes.Children.FightPropertyName[prop.key], propstr)
      if prop.key == currentPropKey then
        self.uiObjs.curProp:GetComponent("UILabel").text = item_panel:GetComponent("UILabel").text
      end
    else
      item_panel:GetComponent("UILabel").text = ""
    end
  end
end
def.method("boolean").UpdateYuanBaoNum = function(self, showtip)
  local toggle = self.m_panel:FindDirect("Img_Bg0/Img_BgEquipMakeItem/Btn_YuanbaoUse"):GetComponent("UIToggle")
  local useYuanbao = toggle.isChecked
  local hasNum = require("Main.Item.ItemData").Instance():GetNumByItemType(ItemModule.BAG, ItemType.CHILDREN_EQUIP_RANDOM_PROP_ITEM)
  if useYuanbao and hasNum >= constant.CChildrenConsts.child_random_property_item_count then
    toggle.value = false
    if showtip then
      Toast(textRes.Item[9504])
    end
    self.uiObjs.confirm:FindDirect("Label_Confirm"):SetActive(true)
    self.uiObjs.confirm:FindDirect("Group_Icon"):SetActive(false)
    return
  end
  self.uiObjs.confirm:FindDirect("Label_Confirm"):SetActive(not useYuanbao)
  self.uiObjs.confirm:FindDirect("Group_Icon"):SetActive(useYuanbao)
  if not useYuanbao then
    return
  end
  require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(constant.CChildrenConsts.child_random_property_main_item, function(price)
    self.uiObjs.confirm:FindDirect("Group_Icon/Label_Confirm"):GetComponent("UILabel").text = price * (constant.CChildrenConsts.child_random_property_item_count - hasNum)
  end)
end
def.method().DoRandom = function(self)
  local pro = require("netio.protocol.mzm.gsp.Children.CChildrenEquipRandomReq").new()
  pro.childrenid = self.childId
  pro.pos = self.wearPos
  local useYuanbao = self.m_panel:FindDirect("Img_Bg0/Img_BgEquipMakeItem/Btn_YuanbaoUse"):GetComponent("UIToggle").isChecked
  pro.useYuanBao = useYuanbao and pro.USE or pro.UNUSE
  pro.totalYuanBaoNum = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetAllYuanBao()
  if useYuanbao then
    pro.useYuanBaoNum = tonumber(self.uiObjs.confirm:FindDirect("Group_Icon/Label_Confirm"):GetComponent("UILabel").text)
    if pro.totalYuanBaoNum:lt(pro.useYuanBaoNum) then
      _G.GotoBuyYuanbao()
      return
    end
  else
    pro.useYuanBaoNum = 0
    local hasNum = require("Main.Item.ItemData").Instance():GetNumByItemType(require("Main.Item.ItemModule").BAG, ItemType.CHILDREN_EQUIP_RANDOM_PROP_ITEM)
    if hasNum < constant.CChildrenConsts.child_random_property_item_count then
      Toast(textRes.Children[3009])
      self:ShowItemTip()
      return
    end
  end
  gmodule.network.sendProtocol(pro)
end
def.method().ShowEquipTip = function(self)
  local sourceObj = self.m_panel:FindDirect("Img_Bg0/Img_BgEquip")
  if self.equip then
    ItemTipsMgr.Instance():ShowTipsEx(self.equip, ItemModule.EQUIPBAG, 1, ItemTipsMgr.Source.ChildrenPanel, sourceObj, 1)
  end
end
def.method().ShowItemTip = function(self)
  local itemId = constant.CChildrenConsts.child_random_property_main_item
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, self.uiObjs.item, -1, true)
end
DlgEquipRandomProperty.Commit()
return DlgEquipRandomProperty
