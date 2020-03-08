local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FabaoExpPanel = Lplus.Extend(ECPanelBase, "FabaoExpPanel")
local def = FabaoExpPanel.define
def.field("boolean").m_CanAdd = true
def.field("number").m_CurExp = 0
def.field("number").m_CurLv = 0
def.field("number").m_NextExp = 0
def.field("number").m_NeedRoleLv = 0
def.field("number").m_CurIndex = 0
def.field("table").m_ItemData = nil
def.field("table").m_ItemListData = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", FabaoExpPanel).Instance = function()
  if not instance then
    instance = FabaoExpPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_FABAO_EXP_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.EXP_SUCCESS, FabaoExpPanel.OnExpSuccess)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FabaoExpPanel.OnBagInfoSyncronized)
end
def.override().OnDestroy = function(self)
  self.m_CanAdd = true
  self.m_CurExp = 0
  self.m_CurLv = 0
  self.m_NextExp = 0
  self.m_CurIndex = 0
  self.m_NeedRoleLv = 0
  self.m_ItemData = nil
  self.m_ItemListData = nil
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.EXP_SUCCESS, FabaoExpPanel.OnExpSuccess)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FabaoExpPanel.OnBagInfoSyncronized)
end
def.static("table", "table").OnExpSuccess = function()
end
def.static("table", "table").OnBagInfoSyncronized = function()
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance:Update()
  end
end
def.method("boolean", "=>", "boolean").CanAddExp = function(self, showTip)
  if not self.m_CanAdd and showTip then
    Toast(textRes.Fabao[61]:format(self.m_NeedRoleLv))
  end
  return self.m_CanAdd
end
def.method().AddExpEx = function(self)
  local item = self.m_ItemListData[self.m_CurIndex]
  if not item then
    return
  end
  local params = {}
  params.expUuidList = {}
  for k, v in pairs(item.UID) do
    if v then
      params.expUuidList[k] = 1
      break
    end
  end
  params.bagid = self.m_ItemData.bagType
  params.fabaoid = self.m_ItemData.data.dynamicData.itemKey
  FabaoMgr.AddExp(params)
end
def.method().AddAllExp = function(self)
  local item = self.m_ItemListData[self.m_CurIndex]
  local params = {}
  params.expUuidList = {}
  local num = item.totalNum
  for k, v in pairs(item.UID) do
    if v >= num then
      params.expUuidList[k] = num
      break
    else
      params.expUuidList[k] = v
      num = num - v
    end
  end
  params.bagid = self.m_ItemData.bagType
  params.fabaoid = self.m_ItemData.data.dynamicData.itemKey
  FabaoMgr.AddExp(params)
end
def.method("number").ShowItemTip = function(self, index)
  local data = self.m_ItemListData[index]
  local items = ItemModule.Instance():GetItemsByItemID(ItemModule.BAG, data.id)
  local item = items[data.itemKey]
  if not item then
    return
  end
  local itemId = item.id
  local itemKey = item.itemKey
  local source = self.m_UIGO.ImgBG
  local tip = ItemTipsMgr.Instance():ShowTipsEx(item, ItemModule.BAG, itemKey, ItemTipsMgr.Source.FabaoExp, source, 0)
  tip:SetOperateContext(nil)
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
    Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAOEXP_PANEL_CLOSE, nil)
  elseif id == "Btn_Use" then
  elseif id:find("Img_BgItem_") then
    if self.m_CurLv >= FabaoMgr.MAXLEVEL then
      Toast(textRes.Fabao[43])
      return
    end
    local _, lastIndex = id:find("Img_BgItem_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    self.m_CurIndex = index
    self:ShowItemTip(index)
  elseif id:find("Img_Delete_") then
    local _, lastIndex = id:find("Img_Delete_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
  end
end
def.method("table").SetItem = function(self, item)
  self.m_ItemData = item
end
def.method("number", "number", "=>", "number").GetItemExp = function(self, type, id)
  if self.m_ItemData then
    if type == ItemType.FABAO_EXP_ITEM then
      local cfg = ItemUtils.GetFabaoExpItem(id)
      return cfg.exp
    elseif type == ItemType.FABAO_FRAG_ITEM then
      local cfg = ItemUtils.GetFabaoFragmentItem(id)
      return self.m_ItemData.data.templateData.data.fragmentId == id and cfg.expEx or cfg.exp
    end
  end
  return 0
end
def.method("=>", "number").GetAddExp = function(self)
  local sum = 0
  local items = self.m_ItemListData
  for _, v in pairs(items) do
    sum = sum + v.addExp
  end
  return sum
end
def.method().UpdateData = function(self)
  self.m_ItemListData = {}
  local typeEnum = {
    ItemType.FABAO_EXP_ITEM,
    ItemType.FABAO_FRAG_ITEM
  }
  local expItems = FabaoMgr.GetFabaoExpItem()
  local index = 0
  for k, v in pairs(expItems) do
    index = index + 1
    self.m_ItemListData[index] = {}
    self.m_ItemListData[index].id = k
    self.m_ItemListData[index].type = v.type
    self.m_ItemListData[index].curNum = 0
    self.m_ItemListData[index].addExp = 0
    self.m_ItemListData[index].UID = v.UID
    self.m_ItemListData[index].totalNum = v.totalNum
    self.m_ItemListData[index].itemKey = v.itemKey
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(self.m_ItemData.bagType, self.m_ItemData.data.dynamicData.itemKey)
  local levelId = self.m_ItemData.data.templateData.data.levelId
  local level = item.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local levelCfg = FabaoMgr.GetFabaoLevelCfg(levelId, level)
  local nextlevelCfg = FabaoMgr.GetFabaoLevelCfg(levelId, level + 1)
  self.m_CurLv = level
  self.m_CurExp = item.extraMap[ItemXStoreType.FABAO_CUR_EXP]
  self.m_NextExp = levelCfg.needExp
  self.m_NeedRoleLv = nextlevelCfg and nextlevelCfg.roleLv or 0
end
def.method("boolean", "number").UpdateCurNum = function(self, isAdd, index)
  local itemData = self.m_ItemListData[index]
  if itemData then
    local num = isAdd and 1 or -1
    local curNum = itemData.curNum + num
    if curNum > itemData.totalNum then
      curNum = itemData.totalNum
    elseif curNum < 0 then
      curNum = 0
    end
    local addExp = curNum * self:GetItemExp(itemData.type, itemData.id)
    self.m_ItemListData[index].curNum = curNum
    self.m_ItemListData[index].addExp = addExp
  else
    warn("ListData doesn't exsit", index)
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.ImgBG = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGO.List_Bag = self.m_panel:FindDirect("Img_Bg0/Group_Bag/Scroll View_Bag/List_Bag")
  self.m_UIGO.Img_BgSlider1 = self.m_panel:FindDirect("Img_Bg0/Group_Slider/Group_Times/Img_BgSlider1")
  self.m_UIGO.Slider_ExpAdd = self.m_panel:FindDirect("Img_Bg0/Group_Slider/Group_Times/Img_BgSlider1/Slider_ExpAdd")
  self.m_UIGO.Label = self.m_panel:FindDirect("Img_Bg0/Group_Slider/Group_Times/Img_BgSlider1/Label")
end
def.method("number").UpdateItemView = function(self, index)
  local uiListGO = self.m_UIGO.List_Bag
  local imgDelGO = uiListGO:FindDirect(("Img_BgItem_%d/Img_Delete_%d"):format(index, index))
  local labelGO = uiListGO:FindDirect(("Img_BgItem_%d/Label_Num_%d"):format(index, index))
  local itemData = self.m_ItemListData[index]
  GUIUtils.SetActive(imgDelGO, itemData.curNum ~= 0)
  GUIUtils.SetText(labelGO, ("%d/%d"):format(itemData.curNum, itemData.totalNum))
end
def.method().UpdateListView = function(self)
  local uiListGO = self.m_UIGO.List_Bag
  local itemLists = GUIUtils.InitUIList(uiListGO, #self.m_ItemListData)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, #self.m_ItemListData do
    local itemList = itemLists[i]
    local itemData = self.m_ItemListData[i]
    local itemBase = ItemUtils.GetItemBase(itemData.id)
    local imgDelGO = itemList:FindDirect(("Img_Delete_%d"):format(i))
    local labelGO = itemList:FindDirect(("Label_Num_%d"):format(i))
    local nameGO = itemList:FindDirect(("Label_Name_%d"):format(i))
    local textureGO = itemList:FindDirect(("Texture_Icon_%d"):format(i))
    GUIUtils.SetText(labelGO, ("%d"):format(itemData.totalNum))
    GUIUtils.SetText(nameGO, itemBase.name)
    GUIUtils.SetTexture(textureGO, itemBase.icon)
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateProgressView = function(self)
  local sliderGO = self.m_UIGO.Img_BgSlider1
  local sliderAddGO = self.m_UIGO.Slider_ExpAdd
  local labelGO = self.m_UIGO.Label
  local addExp = self:GetAddExp()
  local HeroProp = require("Main.Hero.Interface").GetHeroProp()
  local roleLv = HeroProp.level
  local desc = ("%d/%d"):format(self.m_CurExp + addExp, self.m_NextExp)
  if self.m_CurLv == FabaoMgr.MAXLEVEL then
    self.m_CurExp = self.m_NextExp
    desc = "-/-"
  end
  GUIUtils.SetText(labelGO, desc)
  GUIUtils.SetProgress(sliderGO, GUIUtils.COTYPE.SLIDER, self.m_CurExp / self.m_NextExp)
  GUIUtils.SetProgress(sliderAddGO, GUIUtils.COTYPE.SLIDER, (self.m_CurExp + addExp) / self.m_NextExp)
  self.m_CanAdd = roleLv >= self.m_NeedRoleLv
end
def.method().Update = function(self)
  self:UpdateData()
  self:UpdateListView()
  self:UpdateProgressView()
end
return FabaoExpPanel.Commit()
