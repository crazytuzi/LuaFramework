local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FurnitureBagPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local Vector = require("Types.Vector")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local FurnitureBag = require("Main.Homeland.FurnitureBag")
local HomelandGuideMgr = require("Main.Homeland.HomelandGuideMgr")
local def = FurnitureBagPanel.define
def.const("number").NUM_PER_PAGE = 10
def.field("table").m_UIGOs = nil
def.field("number").m_lastStyleIndex = 1
def.field("number").m_lastTypeIndex = 1
def.field("table").m_furnitureStyleGroups = nil
def.field("table").m_furnitureGroups = nil
def.field("table").m_allFurnitures = nil
def.field("table").m_furnitures = nil
def.field("number").m_curPage = 0
def.field("string").m_dragId = ""
def.field("number").m_dragIndex = 0
def.field("boolean").m_dragEdit = false
def.field("table").m_guideDlg = nil
def.field("boolean").m_inHouse = false
def.field(FurnitureBag).m_furnitureBag = nil
def.field("table").m_shownItems = nil
local pageListController = {}
local instance
def.static("=>", FurnitureBagPanel).Instance = function()
  if instance == nil then
    instance = FurnitureBagPanel()
    instance:Init()
  end
  return instance
end
def.static().ShowPanel = function()
  local self = FurnitureBagPanel.Instance()
  self:Init()
  self:CreatePanel(RESPATH.PREFAB_FURNITURE_BAG_PANEL, 0)
end
def.method().Init = function(self)
  self:SetDepth(_G.GUIDEPTH.BOTTOM)
end
def.override().OnCreate = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfHomeland() then
    print("Player not in self Homeland, close panel: " .. self.m_panelName)
    self:DestroyPanel()
    return
  end
  self:InitData()
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOUSE, FurnitureBagPanel.OnLeaveHouseSence)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_COURTYARD, FurnitureBagPanel.OnLeaveCourtyardSence)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, FurnitureBagPanel.OnSyncFurnitureBagInfo)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, FurnitureBagPanel.OnLoseHomelandControl)
  Toast(textRes.Homeland[79])
  self:CheckToShowGuide()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_furnitureStyleGroups = nil
  self.m_furnitureGroups = nil
  self.m_allFurnitures = nil
  self.m_furnitures = nil
  self.m_curPage = 0
  self.m_dragId = ""
  self.m_dragEdit = false
  self.m_dragIndex = 0
  self:HideGuide()
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOUSE, FurnitureBagPanel.OnLeaveHouseSence)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_COURTYARD, FurnitureBagPanel.OnLeaveCourtyardSence)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, FurnitureBagPanel.OnSyncFurnitureBagInfo)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, FurnitureBagPanel.OnLoseHomelandControl)
end
def.method().InitData = function(self)
  if gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfHouse() then
    self.m_inHouse = true
  else
    self.m_inHouse = false
  end
  self.m_furnitureBag = FurnitureBag.Instance()
end
def.method().InitUI = function(self)
  self:InitShownItems()
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Group_Selected = self.m_UIGOs.Img_Bg0:FindDirect("Group_Selected")
  self.m_UIGOs.Group_ChooseType = self.m_UIGOs.Img_Bg0:FindDirect("Group_ChooseType")
  self.m_UIGOs.ScrollView_Item = self.m_UIGOs.Img_Bg0:FindDirect("Scroll View")
  self.m_UIGOs.Grid_Page = self.m_UIGOs.ScrollView_Item:FindDirect("Grid_Page")
  self.m_UIGOs.List_Point = self.m_UIGOs.Img_Bg0:FindDirect("List_Point")
  pageListController.panel_ori_local_pos = self.m_UIGOs.ScrollView_Item.localPosition
  pageListController.page_width = self.m_UIGOs.Grid_Page:GetComponent("UIGrid"):get_cellWidth()
  local childCount = self.m_UIGOs.Img_Bg0.childCount
  for i = 0, childCount - 1 do
    local childGO = self.m_UIGOs.Img_Bg0:GetChild(i)
    local uiSprite = childGO:GetComponent("UISprite")
    if uiSprite and uiSprite.spriteName == "Bg_List" then
      self.m_UIGOs.Bg_List = childGO
      break
    end
  end
  self:SetGridItemCount(self.m_UIGOs.Group_Selected, 0)
end
def.method().InitShownItems = function(self)
  self.m_shownItems = {}
  local info = HomelandUtils.ReadItemTable()
  self.m_shownItems = info
end
def.method().SaveShownItems = function(self)
  if self.m_shownItems == nil then
    self.m_shownItems = {}
  end
  HomelandUtils.SaveItemInfo(self.m_shownItems)
end
def.method().DestroyShownItems = function(self)
  self.m_shownItems = {}
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  local parentobj = obj.parent
  if id == "Btn_Close" then
    self:SaveShownItems()
    self:DestroyShownItems()
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
    self:DestroyPanel()
  elseif parentobj and parentobj.name == "Group_Selected" then
    local index = tonumber(string.sub(id, #"Btn_1_" + 1, -1))
    if index then
      self:SelectStyle(index)
    end
  elseif parentobj and parentobj.name == "Group_ChooseType" then
    local index = tonumber(string.sub(id, #"Btn_Type_" + 1, -1))
    if index then
      self:SelectGroupType(index)
    end
  elseif parentobj and parentobj.name == "Group_Item" then
    local index = tonumber(string.sub(id, #"Img_ItemBg_" + 1, -1))
    if index then
      local pageIndex = tonumber(string.sub(parentobj.parent.name, #"Page_" + 1, -1))
      self:SelectFurniture(obj, pageIndex, index)
    end
  elseif id == "Btn_Left" then
    self:OnLeftBtnClick()
  elseif id == "Btn_Right" then
    self:OnRightBtnClick()
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self:OnDragPage()
  if self.m_dragEdit then
    local mousePosition = Input.mousePosition
    local map2dPos = ScreenToMap2DPos(mousePosition.x, mousePosition.y)
    gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):OnTouchMove(map2dPos.x, map2dPos.y)
  end
end
def.method("string").onDragEnd = function(self, id)
  self:OnDragPage()
  self.m_dragEdit = false
end
def.method("string").onDragStart = function(self, id)
  self.m_dragId = id
  local index = tonumber(string.sub(self.m_dragId, #"Img_ItemBg_" + 1, -1))
  if index then
    self.m_dragIndex = FurnitureBagPanel.NUM_PER_PAGE * (self.m_curPage - 1) + index
  end
end
def.method("string", "userdata").onDragOut = function(self, id, obj)
  if not string.find(self.m_dragId, "Img_ItemBg_") then
    return
  end
  local index = tonumber(string.sub(self.m_dragId, #"Img_ItemBg_" + 1, -1))
  if index == nil then
    return
  end
  local hitgo = UICamera.Raycast(Input.mousePosition)
  if self.m_dragEdit == false and hitgo == false then
    local furnitureInfo = self.m_furnitures[self.m_dragIndex]
    if furnitureInfo then
      local itemId = furnitureInfo.id
      if HomelandUtils.IsEditableFurniture(itemId) then
        self.m_dragEdit = true
        gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):LoadAndStartEditFurniture(itemId, Int64.new(0))
      end
    end
  end
end
def.method().OnDragPage = function(self)
  if self.m_furnitures == nil then
    return
  end
  local feature_remove = true
  if feature_remove then
    return
  end
  local posOffest = pageListController.panel_ori_local_pos - self.m_UIGOs.ScrollView_Item.localPosition
  local index = (posOffest / pageListController.page_width).x + 1
  local indexUpper = math.floor((#self.m_furnitures - 1) / FurnitureBagPanel.NUM_PER_PAGE) + 1
  local minIndex = math.max(1, math.floor(index))
  local minIndex = math.min(indexUpper, minIndex)
  local maxIndex = math.max(minIndex, math.ceil(index))
  local maxIndex = math.min(indexUpper, maxIndex)
  self:SetGridItemRange(self.m_UIGOs.Grid_Page, minIndex, maxIndex, function(pageGO, index)
    self:OnUpdatePageFurnitures(pageGO, index)
  end)
  self:SetCurrentPage(maxIndex)
end
def.method("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  if self.m_panel == nil then
    return
  end
  if id == "Scroll View" then
    local centerOnChild = scrollView:GetChild(0):GetComponent("UICenterOnChild")
    local conterObject = centerOnChild:get_centeredObject()
    if conterObject == nil then
      return
    end
    local strs = string.split(conterObject.name, "_")
    local index = tonumber(strs[#strs])
    self:OnDragPage()
    if index == nil then
      return
    end
    self:SetCurrentPage(index)
  end
end
def.method().OnLeftBtnClick = function(self)
  if self.m_curPage <= 1 then
    Toast(textRes.Homeland[63])
    return
  end
  self:SelectPage(self.m_curPage - 1)
end
def.method().OnRightBtnClick = function(self)
  local pageCount = self:GetPageCount()
  if pageCount <= self.m_curPage then
    Toast(textRes.Homeland[64])
    return
  end
  self:SelectPage(self.m_curPage + 1)
end
def.method("=>", "number").GetPageCount = function(self)
  if self.m_furnitures == nil then
    return 0
  end
  local furnitureCount = #self.m_furnitures
  local pageCount = math.floor((furnitureCount - 1) / FurnitureBagPanel.NUM_PER_PAGE) + 1
  return pageCount
end
def.method("number").SelectPage = function(self, page)
  local pageGO = self.m_UIGOs.Grid_Page:GetChild(1)
  if pageGO == nil then
    warn("pageGO is nil on select page " .. page)
    return
  end
  pageGO.name = "Page_" .. page
  self:OnUpdatePageFurnitures(pageGO, page)
  self:SetCurrentPage(page)
end
def.method("number").SelectStyle = function(self, styleIndex)
  self.m_lastStyleIndex = styleIndex
  self:UpdateFurnitureStyleGroups()
  self:UpdateFurnitureGroups()
  self:UpdateFurnitures()
end
def.method("number").SelectGroupType = function(self, typeIndex)
  self.m_lastTypeIndex = typeIndex
  self:UpdateFurnitureStyleGroups()
  self:UpdateFurnitureGroups()
  self:UpdateFurnitures()
end
def.method().UpdateUI = function(self)
  self:UpdateFurnitureStyleGroups()
  self:UpdateFurnitureGroups()
  self:UpdateFurnitures()
end
def.method().UpdateFurnitureStyleGroups = function(self)
  self.m_furnitureStyleGroups = self:GetAllFurnitureStyleCfgs()
  self:SetFurnitureStyleGroups(self.m_furnitureStyleGroups)
  local Btn = self.m_UIGOs.Group_Selected:FindDirect("Btn_1_" .. self.m_lastStyleIndex)
  GUIUtils.Toggle(Btn, true)
end
def.method("table").SetFurnitureStyleGroups = function(self, furnitureStyleGroups)
  local count = #furnitureStyleGroups
  self:SetGridItemCount(self.m_UIGOs.Group_Selected, count)
  for i = 1, count do
    local go = self.m_UIGOs.Group_Selected:GetChild(i)
    local groupInfo = furnitureStyleGroups[i]
    self:SetFurnitureStyleGroupInfo(go, groupInfo)
  end
end
def.method("userdata", "table").SetFurnitureStyleGroupInfo = function(self, go, groupInfo)
  local Label = go:FindDirect("Label")
  GUIUtils.SetText(Label, groupInfo.showName)
  local Img_Furniture = go:FindDirect("Img_Furniture")
  local Img_NewFurniture = go:FindDirect("Img_NewFurniture")
  local furnitureNums = self:GetFurnitureNumbersByStyle(groupInfo.id)
  local isNew = self:GetIsNewByStyle(groupInfo.id)
  if furnitureNums > 0 then
    Img_Furniture:SetActive(true)
    local Label_FurnitureNum = Img_Furniture:FindDirect("Label_FurnitureNum")
    GUIUtils.SetText(Label_FurnitureNum, furnitureNums)
  else
    Img_Furniture:SetActive(false)
  end
  if isNew then
    Img_NewFurniture:SetActive(true)
  else
    Img_NewFurniture:SetActive(false)
  end
end
def.method().UpdateFurnitureGroups = function(self)
  if self.m_furnitureGroups == nil then
    self.m_furnitureGroups = self:GetAllFurnitureBagCfgs()
  end
  self:SetFurnitureGroups(self.m_furnitureGroups)
  local Btn = self.m_UIGOs.Group_ChooseType:FindDirect("Btn_Type_" .. self.m_lastTypeIndex)
  GUIUtils.Toggle(Btn, true)
end
def.method("table").SetFurnitureGroups = function(self, furnitureGroups)
  local count = #furnitureGroups
  self:SetGridItemCount(self.m_UIGOs.Group_ChooseType, count)
  for i = 1, count do
    local go = self.m_UIGOs.Group_ChooseType:GetChild(i)
    local groupInfo = furnitureGroups[i]
    self:SetFurnitureGroupInfo(go, groupInfo)
  end
  for i = 1, count do
    local go = self.m_UIGOs.Group_ChooseType:GetChild(i)
    local groupInfo = furnitureGroups[i]
    self:SetFurnitureGroupInfo(go, groupInfo)
  end
end
def.method("userdata", "table").SetFurnitureGroupInfo = function(self, go, groupInfo)
  local Label = go:FindDirect("Label")
  GUIUtils.SetText(Label, groupInfo.showName)
  local Img_Type = go:FindDirect("Img_Type")
  local Img_NewFurniture = go:FindDirect("Img_NewFurniture")
  local style = self:GetLastFurnitureStyleId()
  local subTypes = groupInfo.subTypes
  local furnitureNums = 0
  local isNewGroup = false
  for i, subType in ipairs(subTypes) do
    furnitureNums = furnitureNums + self:GetFurnitureNumbersByStyleAndType(style, subType)
    local isNew = self:GetIsNewByStyleAndType(style, subType)
    if isNew then
      isNewGroup = true
    end
  end
  if isNewGroup then
    Img_NewFurniture:SetActive(true)
  else
    Img_NewFurniture:SetActive(false)
  end
  if furnitureNums > 0 then
    Img_Type:SetActive(true)
    local Label_TypeNum = Img_Type:FindDirect("Label_TypeNum")
    GUIUtils.SetText(Label_TypeNum, furnitureNums)
  else
    Img_Type:SetActive(false)
  end
end
def.method().UpdateFurnitures = function(self)
  local styleId = self:GetLastFurnitureStyleId()
  local types = self:GetLastFurnitureTypes()
  local furnitures = {}
  for i, v in ipairs(types) do
    local furnitureParts = self:GetFurnituresByStyleAndType(styleId, v)
    for j, furnitureInfo in ipairs(furnitureParts) do
      furnitures[#furnitures + 1] = furnitureInfo
    end
  end
  self.m_furnitures = furnitures
  local furnitureCount = #furnitures
  local pageCount = math.floor((furnitureCount - 1) / FurnitureBagPanel.NUM_PER_PAGE) + 1
  self:SetGridItemCount(self.m_UIGOs.Grid_Page, 1)
  for i = 1, 1 do
    local startIndex = (i - 1) * FurnitureBagPanel.NUM_PER_PAGE + 1
    local endIndex = math.min(furnitureCount, i * FurnitureBagPanel.NUM_PER_PAGE)
    local pageGO = self.m_UIGOs.Grid_Page:GetChild(i)
    local pageFurnitures = {}
    for j = startIndex, endIndex do
      pageFurnitures[#pageFurnitures + 1] = furnitures[j]
    end
    self:SetPageFurnitures(pageGO, pageFurnitures)
  end
  self.m_UIGOs.ScrollView_Item:GetComponent("UIScrollView"):ResetPosition()
  self:SetPageCount(pageCount)
  self:SetCurrentPage(1)
end
def.method().UpdateCurPageFurnitures = function(self)
  local index = self.m_curPage
  if index == 0 then
    return
  end
  local pageGO = self.m_UIGOs.Grid_Page:FindDirect("Page_" .. index)
  if pageGO == nil then
    return
  end
  self:OnUpdatePageFurnitures(pageGO, index)
end
def.method("userdata", "number").OnUpdatePageFurnitures = function(self, pageGO, index)
  local furnitures = self.m_furnitures
  local furnitureCount = #furnitures
  local startIndex = (index - 1) * FurnitureBagPanel.NUM_PER_PAGE + 1
  local endIndex = math.min(furnitureCount, index * FurnitureBagPanel.NUM_PER_PAGE)
  local pageFurnitures = {}
  for j = startIndex, endIndex do
    pageFurnitures[#pageFurnitures + 1] = furnitures[j]
  end
  self:SetPageFurnitures(pageGO, pageFurnitures)
end
def.method("userdata", "table").SetPageFurnitures = function(self, pageGO, pageFurnitures)
  local Group_Item = pageGO:FindDirect("Group_Item")
  self:SetGridItemCount(Group_Item, #pageFurnitures)
  for i, v in ipairs(pageFurnitures) do
    local go = Group_Item:GetChild(i)
    self:SetFurnitureInfo(go, v)
    local hasShown = false
    for k2, v2 in pairs(self.m_shownItems) do
      if v.id == v2 then
        hasShown = true
        break
      end
    end
    if not hasShown then
      self.m_shownItems[v.id] = true
    end
  end
end
def.method("userdata", "table").SetFurnitureInfo = function(self, go, info)
  local Img_ItemBg = go
  local Img_Icon = Img_ItemBg:FindDirect("Img_Icon")
  local Label_Number = Img_ItemBg:FindDirect("Label_Number")
  local iconId = 0
  local namecolor = 0
  local itemId = info.id
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase then
    iconId = itemBase.icon
    namecolor = itemBase.namecolor
  end
  GUIUtils.SetItemCellSprite(Img_ItemBg, namecolor)
  GUIUtils.SetTexture(Img_Icon, iconId)
  local nums = self:GetFurnitureNumbersById(itemId)
  if nums > 0 then
    GUIUtils.SetText(Label_Number, nums)
  else
    GUIUtils.SetText(Label_Number, "")
  end
  self:SetItemImgNewFurniture(Img_ItemBg, self:GetIsNewFurnitureById(itemId))
end
def.method("userdata", "boolean").SetItemImgNewFurniture = function(self, obj, isNew)
  local Img_NewFurniture = obj:FindDirect("Img_NewFurniture")
  if isNew then
    Img_NewFurniture:SetActive(true)
  else
    Img_NewFurniture:SetActive(false)
  end
end
def.method("=>", "number").GetLastFurnitureStyleId = function(self)
  if self.m_furnitureStyleGroups == nil then
    return 0
  end
  local styleId = 0
  local styleCfg = self.m_furnitureStyleGroups[self.m_lastStyleIndex]
  if styleCfg then
    styleId = styleCfg.id
  end
  return styleId
end
def.method("=>", "table").GetLastFurnitureTypes = function(self)
  if self.m_furnitureGroups == nil then
    return {}
  end
  local groupInfo = self.m_furnitureGroups[self.m_lastTypeIndex]
  if groupInfo then
    return groupInfo.subTypes
  end
  return {}
end
def.method("userdata", "number").SetGridItemCount = function(self, gridGO, itemCount)
  local childCount = gridGO:get_childCount()
  local template = gridGO:GetChild(0)
  if template == nil then
    warn(string.format("%s don't have a template", gridGO.name))
    return
  end
  template:SetActive(false)
  local visibleChildCount = childCount - 1
  if itemCount > visibleChildCount then
    for i = visibleChildCount + 1, itemCount do
      local childGO = GameObject.Instantiate(template)
      childGO.parent = gridGO
      childGO.localPosition = Vector.Vector3.zero
      childGO.localScale = Vector.Vector3.one
    end
  elseif itemCount < visibleChildCount then
    for i = visibleChildCount, itemCount + 1, -1 do
      local childGO = gridGO:GetChild(i)
      GameObject.DestroyImmediate(childGO)
    end
  end
  local from = 1
  local to = itemCount
  for i = from, to do
    local childGO = gridGO:GetChild(i - from + 1)
    childGO:SetActive(true)
    childGO.name = template.name .. "_" .. i
  end
  gridGO:GetComponent("UIGrid"):Reposition()
  self.m_msgHandler:Touch(gridGO)
end
def.method("userdata", "number", "number", "function").SetGridItemRange = function(self, gridGO, from, to, onUpdate)
  local childCount = gridGO:get_childCount()
  local template = gridGO:GetChild(0)
  if template == nil then
    warn(string.format("%s don't have a template", gridGO.name))
    return
  end
  template:SetActive(false)
  local removedGOs = {}
  for i = 1, childCount - 1 do
    local childGO = gridGO:GetChild(i)
    local strs = string.split(childGO.name, "_")
    local index = tonumber(strs[#strs])
    if index == nil then
      GameObject.Destroy(childGO)
    elseif from > index or to < index then
      table.insert(removedGOs, childGO)
    end
  end
  local function getGO()
    if #removedGOs > 0 then
      return table.remove(removedGOs, 1)
    end
    return GameObject.Instantiate(template)
  end
  local uiGrid = gridGO:GetComponent("UIGrid")
  local cellWidth = uiGrid:get_cellWidth()
  local cellHeight = uiGrid:get_cellHeight()
  local arrangement = uiGrid:get_arrangement()
  if arrangement == 0 then
    cellHeight = 0
  else
    cellWidth = 0
  end
  for i = from, to do
    local goName = template.name .. "_" .. i
    local childGO = gridGO:FindDirect(goName)
    local siblingIndex = i - from + 1
    local bUpdate = false
    if childGO == nil then
      childGO = getGO()
      childGO.parent = gridGO
      childGO.localPosition = Vector.Vector3.new((i - 1) * cellWidth, (i - 1) * cellHeight, 0)
      childGO.localScale = Vector.Vector3.one
      bUpdate = true
    end
    childGO:SetActive(true)
    childGO.name = goName
    childGO.transform:SetSiblingIndex(siblingIndex)
    if bUpdate and onUpdate then
      onUpdate(childGO, i)
    end
  end
  for i, v in ipairs(removedGOs) do
  end
  self.m_msgHandler:Touch(gridGO)
end
def.method("number").SetPageCount = function(self, pageCount)
  local uiList = self.m_UIGOs.List_Point:GetComponent("UIList")
  uiList.itemCount = pageCount
  uiList:Resize()
  uiList:Reposition()
end
def.method("number").SetCurrentPage = function(self, currentPage)
  local pagetCount = self.m_UIGOs.List_Point:get_childCount() - 1
  local currentPage = math.min(pagetCount, currentPage)
  self.m_curPage = currentPage
  if currentPage == 0 then
    return
  end
  local childGO = self.m_UIGOs.List_Point:GetChild(currentPage)
  GUIUtils.Toggle(childGO, true)
end
def.method("userdata", "number", "number").SelectFurniture = function(self, go, pageIndex, offsetIndex)
  self:HideGuide()
  if self.m_furnitures == nil then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local index = FurnitureBagPanel.NUM_PER_PAGE * (pageIndex - 1) + offsetIndex
  local furnitureInfo = self.m_furnitures[index]
  local itemId = furnitureInfo.id
  local haveNum = self:GetFurnitureNumbersById(itemId)
  local items = ItemModule.Instance():GetItems()
  local item = {
    id = itemId,
    flag = 0,
    itemKey = 0,
    extraMap = {}
  }
  local position = go.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  ItemTipsMgr.Instance():ShowTips(item, -1, item.itemKey, ItemTipsMgr.Source.FurnitureBag, screenPos.x, screenPos.y, widget.width, widget.height, 0)
end
def.method().CheckToShowGuide = function(self)
  GameUtil.AddGlobalTimer(0, true, function(...)
    GameUtil.AddGlobalTimer(0, true, function(...)
      if self.m_UIGOs.Bg_List == nil or self.m_UIGOs.Bg_List.isnil then
        return
      end
      if HomelandGuideMgr.Instance():HasGuided(HomelandGuideMgr.GuideStep.CLICK_FURNITURE_ITEM) then
        return
      end
      local content = textRes.Homeland[85]
      HomelandGuideMgr.Instance():ShowGuideTipOnGO(self, self.m_UIGOs.Bg_List, content, HomelandGuideMgr.GuideStyleEnum.UP, function(dlg, target)
        if self.m_panel == nil then
          dlg:Destroy()
          return
        end
        self.m_guideDlg = dlg
        HomelandGuideMgr.Instance():MarkAsGuided(HomelandGuideMgr.GuideStep.CLICK_FURNITURE_ITEM)
      end)
    end)
  end)
end
def.method().HideGuide = function(self)
  if self.m_guideDlg then
    self.m_guideDlg:HideDlg()
    self.m_guideDlg = nil
  end
end
def.method("=>", "table").GetAllFurnitureStyleCfgs = function(self)
  if self.m_inHouse then
    return HomelandUtils.GetAllFurnitureStyleCfgs()
  else
    return HomelandUtils.GetAllCourtyardFurnitureStyleCfgs()
  end
end
def.method("=>", "table").GetAllFurnitureBagCfgs = function(self)
  if self.m_inHouse then
    return HomelandUtils.GetAllFurnitureBagCfgs()
  else
    return HomelandUtils.GetAlltCourtyardFurnitureBagCfgs()
  end
end
def.method("number", "=>", "number").GetFurnitureNumbersById = function(self, itemId)
  return self.m_furnitureBag:GetFurnitureNumbersById(itemId)
end
def.method("number", "=>", "boolean").GetIsNewFurnitureById = function(self, itemId)
  local allFurnitures = self:GetFurnitures()
  local isNew = false
  for i, v in ipairs(allFurnitures) do
    if v.id == itemId and v.isNewProduct and not self:IsShown(v.id) then
      isNew = true
      break
    end
  end
  return isNew
end
def.method("number", "=>", "number").GetFurnitureNumbersByStyle = function(self, style)
  return self.m_furnitureBag:GetFurnitureNumbersByStyle(style)
end
def.method("number", "=>", "boolean").GetIsNewByStyle = function(self, style)
  return self:GetIsNewByStyleAndType(style, nil)
end
def.method("number", "number", "=>", "number").GetFurnitureNumbersByStyleAndType = function(self, style, fType)
  return self.m_furnitureBag:GetFurnitureNumbersByStyleAndType(style, fType)
end
def.method("number", "dynamic", "=>", "boolean").GetIsNewByStyleAndType = function(self, style, fType)
  local allFurnitures = self:GetFurnitures()
  local isNew = false
  for i, v in ipairs(allFurnitures) do
    local furnitureCfg = ItemUtils.GetFurnitureCfg(v.id)
    if furnitureCfg and furnitureCfg.styleId == style and (fType == nil or furnitureCfg.furnitureType == fType) and v.isNewProduct and not self:IsShown(v.id) then
      isNew = true
      break
    end
  end
  return isNew
end
def.method("number", "=>", "boolean").IsShown = function(self, id)
  if self.m_shownItems ~= nil then
    if self.m_shownItems[id] == nil then
      return false
    end
    return true
  end
  return true
end
def.method("number", "number", "=>", "table").GetFurnituresByStyleAndType = function(self, style, subtype)
  local allFurnitures = self:GetFurnitures()
  local furnitures = {}
  for i, v in ipairs(allFurnitures) do
    if v.styleId == style and v.furnitureType == subtype and v.isShowInFurnitureBag then
      furnitures[#furnitures + 1] = v
    end
  end
  return furnitures
end
def.method("=>", "table").GetFurnitures = function(self)
  local allFurnitures = self.m_allFurnitures
  if allFurnitures == nil then
    local ItemUtils = require("Main.Item.ItemUtils")
    allFurnitures = ItemUtils.GetAllFurnitures()
    self.m_allFurnitures = allFurnitures
  end
  return allFurnitures
end
def.static("table", "table").OnLeaveHouseSence = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnLeaveCourtyardSence = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnSyncFurnitureBagInfo = function()
  instance:UpdateCurPageFurnitures()
  instance:UpdateFurnitureStyleGroups()
  instance:UpdateFurnitureGroups()
end
def.static("table", "table").OnLoseHomelandControl = function()
  instance:DestroyPanel()
end
return FurnitureBagPanel.Commit()
