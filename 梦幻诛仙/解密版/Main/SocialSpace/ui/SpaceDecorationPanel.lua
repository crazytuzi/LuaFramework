local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceDecorationPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceDecorationPanel.define
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECDebugOption = require("Main.ECDebugOption")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local SocialSpacePanel = Lplus.ForwardDeclare("Main.SocialSpace.ui.SocialSpacePanel")
local ItemModule = require("Main.Item.ItemModule")
local DecorationNotificationMan = require("Main.SocialSpace.DecorationNotificationMan")
def.field("table").m_UIGOs = nil
def.field("boolean").m_isOnlyShowOwned = false
def.field("table").m_decoTypeInfos = nil
def.field("table").m_decoItems = nil
def.field("number").m_selTabIndex = 0
def.field(SocialSpacePanel).m_spacePanel = nil
def.field("table").m_previewItems = nil
def.field("dynamic").m_targetItemId = nil
def.field("dynamic").m_targetDecoType = nil
local instance
def.static("=>", SpaceDecorationPanel).Instance = function()
  if instance == nil then
    instance = SpaceDecorationPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method(SocialSpacePanel, "table").ShowPanel = function(self, spacePanel, params)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  params = params or {}
  self.m_spacePanel = spacePanel
  self.m_targetItemId = params.targetItemId
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_DECORATION_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  GameUtil.AddGlobalTimer(true, 0, function()
    GameUtil.AddGlobalTimer(true, 0, function()
      if not self:IsLoaded() then
        return
      end
      self.m_panel:SetLayer(ClientDef_Layer.UI)
      self:UpdateUI()
    end)
  end)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SaveDecoSuccess, SpaceDecorationPanel.OnSaceDecoSuccess, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.DecorateDataChanged, SpaceDecorationPanel.OnDecorateDataChanged, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.DecorateDataChanged, SpaceDecorationPanel.OnDecorateDataChanged)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SaveDecoSuccess, SpaceDecorationPanel.OnSaceDecoSuccess)
  self:RecoverSpaceDeco()
  self.m_UIGOs = nil
  self.m_isOnlyShowOwned = false
  self.m_decoTypeInfos = nil
  self.m_decoItems = nil
  self.m_selTabIndex = 0
  self.m_spacePanel = spacePanel
  self.m_previewItems = nil
  self.m_targetItemId = nil
  self.m_targetDecoType = nil
  DecorationNotificationMan.Instance():IgnoreAllNewDecoNotifications()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id:find("DecoTypeTab_") then
    self:OnClickDecoTypeTab(obj)
  elseif id:sub(1, #"item_") == "item_" then
    self:OnClickDecoItem(obj)
  elseif id == "Btn_Confirm" then
    self:OnClickConfirmBtn()
  elseif id == "Img_Get" then
    self:OnClickImgGet()
  end
end
def.method().InitData = function(self)
  self.m_previewItems = clone(ECSocialSpaceMan.Instance():GetSavedDecorateData())
  if self.m_targetItemId then
    local decoItemCfg = SocialSpaceUtils.GetDecorationItemCfg(self.m_targetItemId)
    if decoItemCfg then
      self.m_previewItems[decoItemCfg.decoType] = self.m_targetItemId
      self.m_targetDecoType = decoItemCfg.decoType
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Group_Top = self.m_panel:FindDirect("Group_Top")
  self.m_UIGOs.Group_Bottom = self.m_panel:FindDirect("Group_Bottom")
  self.m_UIGOs.Group_Selected = self.m_UIGOs.Group_Bottom:FindDirect("Group_Selected")
  self.m_UIGOs.Group_Item = self.m_UIGOs.Group_Bottom:FindDirect("Group_Item")
  self.m_UIGOs.Img_Get = self.m_UIGOs.Group_Bottom:FindDirect("Img_Get")
  self.m_UIGOs.ScrollView_Item = self.m_UIGOs.Group_Item:FindDirect("Scroll View")
  self.m_UIGOs.List_Item = self.m_UIGOs.ScrollView_Item:FindDirect("List_Item")
  local animateGOs = {}
  local Img_Bg0 = self.m_UIGOs.Group_Bottom:FindDirect("Img_Bg0")
  table.insert(animateGOs, Img_Bg0)
  local Img_Bg0 = self.m_UIGOs.Group_Top:FindDirect("Img_Bg0")
  table.insert(animateGOs, Img_Bg0)
  for i, go in ipairs(animateGOs) do
    local uiTweener = Img_Bg0:GetComponent("UITweener")
    if uiTweener then
      uiTweener:ResetToBeginning()
    end
  end
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local tweenAlpha = Img_Bg0:GetComponent("TweenAlpha")
  if tweenAlpha and tweenAlpha.enabled then
    tweenAlpha:set_value(tweenAlpha:get_from())
  end
  self.m_panel:SetLayer(ClientDef_Layer.Invisible)
end
def.method().UpdateUI = function(self)
  self:UpdateImgGet()
  self:UpdateDecorationTypeGrid()
  if #self.m_decoTypeInfos > 0 then
    local index = self:GetAutoSelectTabIndex()
    self:SelectTab(index)
  end
end
def.method("=>", "number").GetAutoSelectTabIndex = function(self)
  local index
  if self.m_targetDecoType then
    for i, v in ipairs(self.m_decoTypeInfos) do
      if v.decoType == self.m_targetDecoType then
        index = i
        break
      end
    end
  end
  return index or 1
end
def.method().UpdateImgGet = function(self)
  GUIUtils.Toggle(self.m_UIGOs.Img_Get, self.m_isOnlyShowOwned)
end
def.method().UpdateDecorationTypeGrid = function(self)
  self.m_decoTypeInfos = SocialSpaceUtils.GetAllDecorationTypeDisplayCfgs()
  local typeNum = #self.m_decoTypeInfos
  GUIUtils.ResizeGrid(self.m_UIGOs.Group_Selected, typeNum, "DecoTypeTab_")
  for i = 1, typeNum do
    local decoTypeInfo = self.m_decoTypeInfos[i]
    local go = self.m_UIGOs.Group_Selected:GetChild(i)
    self:SetDecoTypeTab(go, decoTypeInfo)
  end
end
def.method("userdata", "table").SetDecoTypeTab = function(self, go, decoTypeInfo)
  local Label = go:FindDirect("Label")
  local Img_RedNew = go:FindDirect("Img_RedNew")
  GUIUtils.SetText(Label, decoTypeInfo.name or "nil")
  local hasNotification = DecorationNotificationMan.Instance():HasNewDecoNotificationOnDecoType(decoTypeInfo.decoType)
  GUIUtils.SetActive(Img_RedNew, hasNotification)
end
def.method("userdata").OnClickDecoTypeTab = function(self, go)
  local index = tonumber(go.name:split("_")[2])
  if index == nil then
    return
  end
  self:SelectTab(index)
end
def.method("number").SelectTab = function(self, index)
  local go = self.m_UIGOs.Group_Selected:FindDirect("DecoTypeTab_" .. index)
  if go == nil then
    return
  end
  GUIUtils.Toggle(go, true)
  self.m_selTabIndex = index
  local decoTypeInfo = self.m_decoTypeInfos[index]
  self:ShowDecoTypeItems(decoTypeInfo.decoType, true)
  self:AutoFocusOnItem()
end
def.method("number", "boolean").ShowDecoTypeItems = function(self, decoType, resetPosition)
  self.m_decoItems = self:GetDecoTypeItems(decoType)
  local itemCount = #self.m_decoItems
  local ScrollView = self.m_UIGOs.ScrollView_Item
  local List_Item = self.m_UIGOs.List_Item
  local uiList = List_Item:GetComponent("UIList")
  uiList:set_itemCount(itemCount)
  uiList:Resize()
  local children = uiList.children
  for i = 1, itemCount do
    local groupGO = children[i]
    local decoItem = self.m_decoItems[i]
    self:SetDecoItem(groupGO, decoItem)
  end
  if resetPosition then
    GameUtil.AddGlobalTimer(0, true, function()
      if _G.IsNil(ScrollView) then
        return
      end
      ScrollView:GetComponent("UIScrollView"):ResetPosition()
    end)
  end
end
def.method("userdata", "table").SetDecoItem = function(self, groupGO, decoItem)
  local itemBase = ItemUtils.GetItemBase(decoItem.id)
  if itemBase == nil then
    return
  end
  local Img_ItemBg = groupGO:FindDirect("Img_ItemBg")
  local Img_Icon = groupGO:FindDirect("Img_Icon")
  local Img_RedNew = groupGO:FindDirect("Img_RedNew")
  GUIUtils.SetTexture(Img_Icon, itemBase.icon)
  local namecolor = itemBase.namecolor
  local uiTexture = Img_Icon:GetComponent("UITexture")
  if decoItem.unlocked then
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  else
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
    namecolor = 7
  end
  GUIUtils.SetItemCellSprite(Img_ItemBg, namecolor)
  local hasNotification = DecorationNotificationMan.Instance():HasNewDecoNotificationOnItem(decoItem.id)
  GUIUtils.SetActive(Img_RedNew, hasNotification)
end
def.method("userdata").OnClickDecoItem = function(self, go)
  local index = tonumber(go.name:split("_")[2])
  local decoItem = self.m_decoItems[index]
  local itemId = decoItem.id
  if decoItem.unlocked then
    local needSource = false
    self:ShowItemTips(itemId, go, needSource)
  else
    local items = ItemModule.Instance():GetItemsByItemID(ItemModule.BAG, itemId)
    local count = table.nums(items)
    if count > 0 then
      local _, item = next(items)
      local position = go:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local widget = go:GetComponent("UIWidget")
      local itemTip = ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, item.itemKey or 0, ItemTipsMgr.Source.SpaceDecoPanel, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    else
      local needSource = true
      self:ShowItemTips(itemId, go, needSource)
    end
  end
  self:SelectDecoItem(index, go)
end
def.method("number", "userdata", "boolean").ShowItemTips = function(self, itemId, go, needSource)
  local position = go.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  local pos = {
    auto = true,
    tipType = "y",
    sourceX = screenPos.x,
    sourceY = screenPos.y,
    sourceW = widget.width,
    sourceH = widget.height,
    prefer = 1
  }
  ItemTipsMgr.Instance():ShowBasicTipsWithPos(itemId, pos, needSource)
end
def.method("number", "userdata").SelectDecoItem = function(self, index, go)
  local decoItem = self.m_decoItems[index]
  if decoItem == nil then
    return
  end
  if go == nil then
    go = self.m_UIGOs.List_Item:FindDirect("item_" .. index)
  end
  GUIUtils.Toggle(go, true)
  self:SetSpaceDeco(decoItem.decoType, decoItem.id)
end
def.method("number", "number").SetSpaceDeco = function(self, decoType, itemId)
  if not self.m_spacePanel:IsLoaded() then
    return
  end
  self.m_spacePanel:SetSpaceDeco(decoType, itemId)
  self.m_previewItems[decoType] = itemId
end
def.method().RecoverSpaceDeco = function(self)
  if not self.m_spacePanel:IsLoaded() then
    return
  end
  self.m_spacePanel:UpdateDecorations()
end
def.method().OnClickConfirmBtn = function(self)
  ECSocialSpaceMan.Instance():SaveSpaceDecorate(self.m_previewItems)
end
def.method("number", "=>", "table").GetDecoTypeItems = function(self, decoType)
  local decoDatas = ECSocialSpaceMan.Instance():GetDecorateDatas()
  local decoTypeCfg = SocialSpaceUtils.GetDecorationTypeCfg(decoType)
  local decoItems = {}
  if decoTypeCfg then
    for i, v in ipairs(decoTypeCfg.itemIds) do
      local decoItem = {
        id = v,
        decoType = decoType,
        resId = 0,
        sort = 0,
        unlocked = false
      }
      local decoItemCfg = SocialSpaceUtils.GetDecorationItemCfg(decoItem.id)
      if decoItemCfg then
        decoItem.sort = decoItemCfg.displayIndex
        decoItem.resId = decoItemCfg.resId
      end
      if decoDatas[decoType] and decoDatas[decoType][decoItem.id] then
        decoItem.unlocked = true
      end
      if self.m_isOnlyShowOwned and decoItem.unlocked or not self.m_isOnlyShowOwned then
        table.insert(decoItems, decoItem)
      end
    end
    table.sort(decoItems, function(l, r)
      if l.unlocked and not r.unlocked then
        return true
      elseif not l.unlocked and r.unlocked then
        return false
      else
        return l.sort < r.sort
      end
    end)
  end
  return decoItems
end
def.method("=>", "number").GetSelectedTypeItemIndex = function(self)
  local decoTypeInfo = self.m_decoTypeInfos[self.m_selTabIndex]
  local decoType = decoTypeInfo.decoType
  local itemId = self.m_previewItems[decoType]
  if itemId == nil then
    local savedDecoData = ECSocialSpaceMan.Instance():GetSavedDecorateData()
    itemId = savedDecoData[decoType]
  end
  if itemId == nil or self.m_decoItems == nil then
    return 0
  end
  local index
  for i, v in ipairs(self.m_decoItems) do
    if itemId == v.id then
      index = i
      break
    end
  end
  return index or 0
end
def.method().AutoFocusOnItem = function(self)
  local ScrollView = self.m_UIGOs.ScrollView_Item
  local List_Item = self.m_UIGOs.List_Item
  local uiList = List_Item:GetComponent("UIList")
  local index = self:GetSelectedTypeItemIndex()
  if index > 0 then
    do
      local itemGO = List_Item:FindDirect("item_" .. index)
      self:SelectDecoItem(index, itemGO)
      GameUtil.AddGlobalTimer(0, true, function()
        if _G.IsNil(itemGO) then
          return
        end
        ScrollView:GetComponent("UIScrollView"):DragToMakeVisible(itemGO.transform, 4)
      end)
    end
  else
    local template = uiList:get_template()
    local toggleGroup = template:GetComponent("UIToggle"):get_group()
    local activeToggle = UIToggle.GetActiveToggle(toggleGroup)
    if activeToggle then
      activeToggle:set_value(false)
    end
  end
end
local xMove
def.method("string").onDragStart = function(self, id)
  if id == "Box_Preview" then
    xMove = 0
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if id == "Box_Preview" and xMove then
    xMove = xMove + dx
    if math.abs(xMove) > 40 then
      if xMove > 0 then
        self:SelectPrevDecoItem()
      else
        self:SelectNextDecoItem()
      end
      xMove = nil
    end
  end
end
def.method("string").onDragEnd = function(self, id, go)
  xMove = nil
end
def.method().SelectNextDecoItem = function(self)
  if #self.m_decoItems == 0 then
    return
  end
  local curIndex = self:GetSelectedTypeItemIndex()
  local nextIndex = curIndex + 1
  if nextIndex > #self.m_decoItems then
    nextIndex = 1
  end
  self:SelectDecoItem(nextIndex, nil)
end
def.method().SelectPrevDecoItem = function(self)
  if #self.m_decoItems == 0 then
    return
  end
  local curIndex = self:GetSelectedTypeItemIndex()
  local prevIndex = curIndex - 1
  if prevIndex <= 0 then
    prevIndex = #self.m_decoItems
  end
  self:SelectDecoItem(prevIndex, nil)
end
def.method().OnClickImgGet = function(self)
  self.m_isOnlyShowOwned = not self.m_isOnlyShowOwned
  self:UpdateImgGet()
  self:UpdateSelectedTypeItems(true)
end
def.method("boolean").UpdateSelectedTypeItems = function(self, resetPosition)
  local index = self.m_selTabIndex
  local decoTypeInfo = self.m_decoTypeInfos[index]
  self:ShowDecoTypeItems(decoTypeInfo.decoType, resetPosition)
  self:AutoFocusOnItem()
end
def.method("table").OnSaceDecoSuccess = function(self, params)
  self:DestroyPanel()
end
def.method("table").OnDecorateDataChanged = function(self, params)
  self:UpdateSelectedTypeItems(false)
end
return SpaceDecorationPanel.Commit()
