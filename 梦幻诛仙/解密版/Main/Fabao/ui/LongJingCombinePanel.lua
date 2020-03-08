local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local EquipModule = require("Main.Equip.EquipModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local HeroProp = require("Main.Hero.Interface").GetHeroProp()
local LongJingCombinePanel = Lplus.Extend(ECPanelBase, "LongJingCombinePanel")
local def = LongJingCombinePanel.define
def.field("number").m_CombineID = 0
def.field("number").m_CurMaxLevel = 0
def.field("number").m_CurIndex = 0
def.field("table").m_ListData = nil
def.field("table").m_ItemDatas = nil
local instance
def.static("=>", LongJingCombinePanel).Instance = function()
  if not instance then
    instance = LongJingCombinePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  local item = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.FABAO_LONGJING_ITEM)
  local count = 0
  for _, _ in pairs(item) do
    count = count + 1
  end
  if count == 0 then
    Toast(textRes.Fabao[52])
    return
  end
  self:CreatePanel(RESPATH.PREFAB_FABAO_COMPOSE_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitItemData()
  self:Update()
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LJ_COMBINE_SUCCESS, LongJingCombinePanel.OnLongJingCombineSuccess)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, LongJingCombinePanel.OnBagInfoSyncronized)
end
def.override().OnDestroy = function(self)
  self.m_CombineID = 0
  self.m_CurMaxLevel = 0
  self.m_ListData = nil
  self.m_ItemDatas = nil
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LJ_COMBINE_SUCCESS, LongJingCombinePanel.OnLongJingCombineSuccess)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, LongJingCombinePanel.OnBagInfoSyncronized)
end
def.static("table", "table").OnLongJingCombineSuccess = function(p1, p2)
  warn("OnLongJingCombineSuccess", instance, instance.m_panel, instance.m_panel.isnil)
  if instance and instance.m_panel and not instance.m_panel.isnil then
    local longjingInfo = p1.longjingInfo
    if longjingInfo then
      for k, v in pairs(longjingInfo) do
        local itemBase = ItemUtils.GetItemBase(k)
        local name = itemBase.name
        local namecolor = itemBase.namecolor
        local color = require("Main.Chat.HtmlHelper").NameColor[namecolor] or "ffffff"
        Toast(string.format(textRes.Fabao[110], v, color, name))
      end
    end
  end
end
def.static("table", "table").OnBagInfoSyncronized = function()
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateListData()
    instance:UpdateLeftView()
    instance:AutoChoose()
  end
end
def.method().AutoChoose = function(self)
  local item = self.m_ListData[self.m_CurIndex]
  if not item then
    return
  end
  local cfg = ItemUtils.GetLongJingItem(item.id)
  if item.totalNum < 2 or cfg.lv >= self.m_CurMaxLevel then
    for i = 1, 2 do
      instance:UpdateItemData(i, nil)
      instance:UpdateRightTopView(i)
    end
    self.m_CombineID = 0
    self:UpdateRightBottomView(Color.white)
    self:ResetToggleView()
  else
    self.m_CombineID = cfg.nextId
    for i = 1, 2 do
      self:UpdateItemData(i, item)
      self:UpdateRightTopView(i)
    end
    self:UpdateRightBottomView(Color.gray)
  end
end
def.method().LongJingCombine = function(self)
  local params = {}
  if not self.m_ItemDatas[1] or not self.m_ItemDatas[1].id or 0 == self.m_CombineID then
    Toast(textRes.Fabao[53])
    return
  end
  local longjingBase = ItemUtils.GetLongJingItem(self.m_CombineID)
  local longjingLevel = longjingBase.lv
  local limitLevel = math.floor(require("Main.Hero.Interface").GetHeroProp().level / 10)
  if longjingLevel > limitLevel then
    Toast(textRes.Fabao[106])
    return
  end
  local FabaoModule = require("Main.Fabao.FabaoModule")
  FabaoModule.RequestLongjingCompose(self.m_CombineID)
end
def.method().OnClickLongjingCombineAll = function(self)
  local FabaoModule = require("Main.Fabao.FabaoModule")
  FabaoModule.ReqiestLongjingAllCompose()
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
    Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LJCOMBINE_PANEL_CLOSE, nil)
  elseif id == "Btn_Creat" then
    self:LongJingCombine()
  elseif id == "Btn_CreatAll" then
    self:OnClickLongjingCombineAll()
  elseif id == "Btn_Tips" then
    local tipContent = textRes.Fabao[10]
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 50, y = 75})
  elseif id:find("Img_Item1_") == 1 then
    local _, lastIndex = id:find("Img_Item1_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local item = self.m_ListData[index]
    if not item then
      return
    end
    local cfg = ItemUtils.GetLongJingItem(item.id)
    if cfg.nextId == 0 then
      Toast(textRes.Fabao[25])
    elseif cfg.lv >= self.m_CurMaxLevel then
      Toast(textRes.Fabao[27])
    elseif item.totalNum < 2 then
      Toast(textRes.Fabao[11])
    else
      self.m_CurIndex = index
      self.m_CombineID = cfg.nextId
      for i = 1, 2 do
        self:UpdateItemData(i, item)
        self:UpdateRightTopView(i)
      end
      self:UpdateRightBottomView(Color.gray)
    end
  elseif id:find("Img_Item") == 1 then
    local _, lastIndex = id:find("Img_Item")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local btnGO = self.m_panel:FindDirect(("Img_Bg0/Img_Bg1/Group_Creat/%s"):format(id))
    local id = self.m_CombineID
    if index < 3 then
      local item = self.m_ItemDatas[index]
      if not item or not item.id then
        return
      end
      id = item.id
    end
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(id, btnGO, -1, false)
  end
end
def.method("string").onLongPress = function(self, id)
  if id:find("Img_Item1_") == 1 then
    local _, lastIndex = id:find("Img_Item1_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local data = self.m_ListData[index]
    if not data then
      return
    end
    local btnGO = self.m_panel:FindDirect(("Img_Bg0/Img_Bg1/Img_BgBag/Scroll View_Item/List_Item/%s"):format(id))
    ItemTipsMgr.Instance():ShowTipsEx(data.item, ItemModule.BAG, data.item.itemKey, ItemTipsMgr.Source.Bag, btnGO, 0)
  end
end
def.method("string").onDoubleClick = function(self, id)
  print(string.format("%s double click event: id = %s", tostring(self), id))
  if id:find("Img_Item1_") == 1 then
  elseif id:find("Img_Item") == 1 then
    local _, lastIndex = id:find("Img_Item")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    if index < 3 then
      for i = 1, 2 do
        self:UpdateItemData(i, nil)
        self:UpdateRightTopView(i)
      end
      self.m_CombineID = 0
      self:UpdateRightBottomView(Color.white)
    end
  end
end
def.method().InitItemData = function(self)
  self.m_ItemDatas = {}
  for i = 1, 3 do
    self.m_ItemDatas[i] = {}
  end
  self.m_CurMaxLevel = math.floor(HeroProp.level / 10)
end
def.method("number", "table").UpdateItemData = function(self, index, itemData)
  self.m_ItemDatas[index] = itemData
end
def.method().UpdateListData = function(self)
  self.m_ListData = {}
  local temp = {}
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.FABAO_LONGJING_ITEM)
  for _, v in pairs(items) do
    if not temp[v.id] then
      temp[v.id] = {}
      temp[v.id].totalNum = v.number
      temp[v.id].item = v
    else
      temp[v.id].totalNum = temp[v.id].totalNum + v.number
    end
  end
  local index = 0
  for k, v in pairs(temp) do
    index = index + 1
    self.m_ListData[index] = {}
    self.m_ListData[index].id = k
    self.m_ListData[index].item = v.item
    self.m_ListData[index].totalNum = v.totalNum
  end
  table.sort(self.m_ListData, function(l, r)
    if l.id ~= r.id then
      return l.id < r.id
    end
  end)
end
def.method("number").UpdateRightTopView = function(self, index)
  local itemData = self.m_ItemDatas[index]
  local iconGO = self.m_panel:FindDirect(("Img_Bg0/Img_Bg1/Group_Creat/Img_Item%d/Icon_Item%d"):format(index, index))
  local labelGO = self.m_panel:FindDirect(("Img_Bg0/Img_Bg1/Group_Creat/Img_Item%d/Label_Item%d"):format(index, index))
  local icon = 0
  local name = ""
  if itemData and itemData.id then
    local itemBase = ItemUtils.GetItemBase(itemData.id)
    icon = itemBase.icon
    name = itemBase.name
  end
  GUIUtils.SetTexture(iconGO, icon)
  GUIUtils.SetText(labelGO, name)
end
def.method("userdata").UpdateRightBottomView = function(self, color)
  local id = self.m_CombineID
  local iconGO = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Group_Creat/Img_Item3/Icon_Item3")
  local labelGO = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Group_Creat/Img_Item3/Label_Item3")
  local nameGO = self.m_panel:FindDirect("Label_Name")
  local icon = 0
  local name = ""
  local maxLevel = self.m_CurMaxLevel
  if id ~= 0 then
    local itemBase = ItemUtils.GetItemBase(id)
    icon = itemBase.icon
    name = itemBase.name
  end
  GUIUtils.SetTexture(iconGO, icon)
  GUIUtils.SetColor(iconGO, color, GUIUtils.COTYPE.TEXTURE)
  GUIUtils.SetText(labelGO, name)
  GUIUtils.SetText(nameGO, textRes.Fabao[26]:format(maxLevel))
end
def.method().UpdateLeftView = function(self)
  local uiListGO = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Img_BgBag/Scroll View_Item/List_Item")
  local itemCount = #self.m_ListData
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local itemData = self.m_ListData[i]
    local iconGO = itemGO:FindDirect(("Icon_ItemIcon01_%d"):format(i))
    local numGO = itemGO:FindDirect(("Label_Num_%d"):format(i))
    local itemBase = ItemUtils.GetItemBase(itemData.id)
    GUIUtils.SetTexture(iconGO, itemBase.icon)
    GUIUtils.SetText(numGO, itemData.totalNum)
  end
end
def.method().UpdateRightView = function(self)
  for i = 1, 2 do
    self:UpdateRightTopView(i)
  end
  self:UpdateRightBottomView(Color.white)
end
def.method().Update = function(self)
  self:UpdateListData()
  self:UpdateLeftView()
  self:UpdateRightView()
end
def.method().ResetToggleView = function(self)
  local uiListGO = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Img_BgBag/Scroll View_Item/List_Item")
  if not uiListGO then
    return
  end
  local uiList = uiListGO:GetComponent("UIList")
  local listItems = uiList.children
  for i = 1, uiList.itemCount do
    GUIUtils.Toggle(listItems[i], false)
  end
end
return LongJingCombinePanel.Commit()
