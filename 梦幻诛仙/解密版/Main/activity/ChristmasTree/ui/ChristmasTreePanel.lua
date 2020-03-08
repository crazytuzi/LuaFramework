local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChristmasTreePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ChristmasTreeMgr = require("Main.activity.ChristmasTree.ChristmasTreeMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local EC = require("Types.Vector3")
local def = ChristmasTreePanel.define
def.field("table").uiObjs = nil
def.field(AwardItemTipHelper).itemTipHelper = nil
local instance
def.static("=>", ChristmasTreePanel).Instance = function()
  if instance == nil then
    instance = ChristmasTreePanel()
  end
  return instance
end
def.method().ShowCurrentVisitTree = function(self)
  local currentTree = ChristmasTreeMgr.Instance():GetCurrentVisitTree()
  if currentTree == nil then
    warn("there is no visit tree to show")
    return
  end
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateChristmasTreeInfo()
  else
    self:SetModal(true)
    self:CreatePanel(RESPATH.PREFAB_CHRISTMAS_TREE_PANEL, 1)
  end
end
def.override().OnCreate = function(self)
  self.itemTipHelper = AwardItemTipHelper()
  self:InitUI()
  self:InitBasicInfo()
  self:UpdateChristmasTreeInfo()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ChristmasTree_Hang_Stock, ChristmasTreePanel.OnChristmasTreeHangStock)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ChristmasTree_Change, ChristmasTreePanel.OnChristmasTreeChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.itemTipHelper = nil
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ChristmasTree_Hang_Stock, ChristmasTreePanel.OnChristmasTreeHangStock)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ChristmasTree_Change, ChristmasTreePanel.OnChristmasTreeChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Tips = self.uiObjs.Img_Bg0:FindDirect("Label_Tips")
  self.uiObjs.Group_Reward = self.uiObjs.Img_Bg0:FindDirect("Group_Reward")
  self.uiObjs.FlyItem = self.uiObjs.Img_Bg0:FindDirect("Item")
  self.uiObjs.FlyTatget = self.uiObjs.Img_Bg0:FindDirect("Target")
  local tweenScales = self.uiObjs.FlyItem:GetComponents("TweenScale")
  for i, v in ipairs(tweenScales) do
    GameObject.Destroy(v)
  end
  local tweenAlphas = self.uiObjs.FlyItem:GetComponents("TweenAlpha")
  for i, v in ipairs(tweenAlphas) do
    GameObject.Destroy(v)
  end
end
def.method().InitBasicInfo = function(self)
  GUIUtils.SetText(self.uiObjs.Label_Tips, textRes.activity.ChristmasTree[3])
  local awardList = {
    constant.CChristmasStockingConsts.DISPLAY_ITEM_CFG_ID1,
    constant.CChristmasStockingConsts.DISPLAY_ITEM_CFG_ID2,
    constant.CChristmasStockingConsts.DISPLAY_ITEM_CFG_ID3,
    constant.CChristmasStockingConsts.DISPLAY_ITEM_CFG_ID4,
    constant.CChristmasStockingConsts.DISPLAY_ITEM_CFG_ID5
  }
  for i = #awardList, 1, -1 do
    if awardList[i] == 0 then
      table.remove(awardList, i)
    end
  end
  local List_Reward = self.uiObjs.Group_Reward:FindDirect("List_Reward")
  local uiList = List_Reward:GetComponent("UIList")
  uiList.itemCount = #awardList
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #awardList do
    local uiItem = uiItems[i]
    local Img_Icon = uiItem:FindDirect("Img_Icon")
    local Label_Number = uiItem:FindDirect("Label_Number")
    local Img_Lv = uiItem:FindDirect("Img_Lv")
    local itemBase = ItemUtils.GetItemBase(awardList[i])
    GUIUtils.SetTexture(Img_Icon, itemBase.icon)
    GUIUtils.SetText(Label_Number, "")
    GUIUtils.SetItemCellSprite(Img_Lv, itemBase.namecolor)
    self.itemTipHelper:RegisterItem2ShowTip(awardList[i], uiItem)
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return
  end
  local currentTree = ChristmasTreeMgr.Instance():GetCurrentVisitTree()
  local Btn_Get = self.uiObjs.Img_Bg0:FindDirect("Btn_Get")
  GUIUtils.SetActive(Btn_Get, Int64.eq(heroProp.id, currentTree:GetRoleId()))
end
def.method().UpdateChristmasTreeInfo = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return
  end
  local currentTree = ChristmasTreeMgr.Instance():GetCurrentVisitTree()
  local Label_Name = self.uiObjs.Img_Bg0:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, string.format(textRes.activity.ChristmasTree[4], currentTree:GetRoleName()))
  local histories = currentTree:GetOperationHistory() or {}
  local Group_Log = self.uiObjs.Img_Bg0:FindDirect("Group_Log")
  local Log = Group_Log:FindDirect("Log")
  local Scrollview = Log:FindDirect("Scrollview")
  local List = Scrollview:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #histories
  uiList:Resize()
  local reverseHistory = {}
  for i = #histories, 1, -1 do
    table.insert(reverseHistory, histories[i])
  end
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    local history = reverseHistory[i]
    local roleId = history.role_id
    local roleName = _G.GetStringFromOcts(history.role_name)
    local time = history.time
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local t = AbsoluteTimer.GetServerTimeTable(Int64.ToNumber(time / 1000))
    local timeStr = string.format("%d/%d/%d %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
    local Label_Describe = uiItem:FindDirect("Label_Describe")
    if Int64.eq(heroProp.id, currentTree:GetRoleId()) then
      if not Int64.eq(heroProp.id, roleId) then
        Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(string.format(textRes.activity.ChristmasTree[5], roleName, timeStr, roleId:tostring()))
      else
        Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(string.format(textRes.activity.ChristmasTree[18], timeStr, roleId:tostring()))
      end
    elseif not Int64.eq(heroProp.id, roleId) then
      Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(string.format(textRes.activity.ChristmasTree[16], roleName, timeStr, roleId:tostring()))
    else
      Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(string.format(textRes.activity.ChristmasTree[18], timeStr, roleId:tostring()))
    end
  end
  GameUtil.AddGlobalTimer(0.1, true, function()
    if not _G.IsNil(Scrollview) then
      uiList:Resize()
      Scrollview:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local Group_Icon = self.uiObjs.Img_Bg0:FindDirect("Group_Icon")
  local Grid_Icon = Group_Icon:FindDirect("Grid_Icon")
  for i = 1, constant.CChristmasStockingConsts.TREE_HANG_MAX_NUM do
    local Img_ItemGet = Grid_Icon:FindDirect("Img_ItemGet_" .. i)
    local Img_Icon = Img_ItemGet:FindDirect("Img_Icon_" .. i)
    local Img_Add = Img_ItemGet:FindDirect("Img_Add")
    if currentTree:IsEmpytyPosition(i) then
      GUIUtils.SetActive(Img_Add, true)
      GUIUtils.SetActive(Img_Icon, false)
      GUIUtils.SetLightEffect(Img_ItemGet, GUIUtils.Light.NONE)
    else
      GUIUtils.SetActive(Img_Add, false)
      GUIUtils.SetActive(Img_Icon, true)
      GUIUtils.SetTexture(Img_Icon, constant.CChristmasStockingConsts.TREE_NOT_EMPTY_POSITION_ICON_ID)
      if currentTree:IsAwardPosition(i) then
        GUIUtils.SetLightEffect(Img_ItemGet, GUIUtils.Light.Square)
      else
        GUIUtils.SetLightEffect(Img_ItemGet, GUIUtils.Light.NONE)
      end
    end
  end
  local Group_Tree = self.uiObjs.Img_Bg0:FindDirect("Group_Tree")
  local Group_Item = Group_Tree:FindDirect("Group_Item")
  for i = 1, constant.CChristmasStockingConsts.TREE_HANG_MAX_NUM do
    local Img_Item = Group_Item:FindDirect(string.format("Img_Item%02d", i))
    local Img_Icon = Img_Item:FindDirect("Img_Icon")
    local boxCollider = Img_Item:GetComponent("BoxCollider")
    local tweenRotation = Img_Icon:GetComponent("TweenRotation")
    if currentTree:IsEmpytyPosition(i) then
      GUIUtils.SetTexture(Img_Icon, constant.CChristmasStockingConsts.TREE_EMPTY_POSITION_ICON_ID)
      boxCollider.enabled = false
      tweenRotation.enabled = false
    else
      GUIUtils.SetTexture(Img_Icon, constant.CChristmasStockingConsts.TREE_NOT_EMPTY_POSITION_ICON_ID)
      boxCollider.enabled = true
      if currentTree:IsAwardPosition(i) then
        tweenRotation.enabled = true
      else
        tweenRotation.enabled = false
      end
    end
  end
end
def.method("number").FlyStockToPos = function(self, pos)
  local Group_Icon = self.uiObjs.Img_Bg0:FindDirect("Group_Icon")
  local Grid_Icon = Group_Icon:FindDirect("Grid_Icon")
  local Img_ItemGet = Grid_Icon:FindDirect("Img_ItemGet_" .. pos)
  local Group_Tree = self.uiObjs.Img_Bg0:FindDirect("Group_Tree")
  local Group_Item = Group_Tree:FindDirect("Group_Item")
  local Img_Item = Group_Item:FindDirect(string.format("Img_Item%02d", pos))
  if _G.IsNil(Img_ItemGet) or _G.IsNil(Img_Item) then
    return
  end
  local stock = GameObject.Instantiate(self.uiObjs.FlyItem)
  stock.parent = self.uiObjs.Img_Bg0
  stock.localScale = EC.Vector3.one
  GUIUtils.FillIcon(stock:GetComponent("UITexture"), constant.CChristmasStockingConsts.TREE_NOT_EMPTY_POSITION_ICON_ID)
  local fromPos = Img_ItemGet.transform:TransformPoint(EC.Vector3.new(0, 0, 0))
  stock.localPosition = self.uiObjs.Img_Bg0.transform:InverseTransformPoint(fromPos)
  local targetPos = Img_Item.transform:TransformPoint(EC.Vector3.new(0, 0, 0))
  self.uiObjs.FlyTatget.localPosition = self.uiObjs.Img_Bg0.transform:InverseTransformPoint(targetPos)
  GUIUtils.SetActive(stock, true)
  GUIUtils.SetActive(Img_Item, false)
  GameUtil.AddGlobalTimer(1.5, true, function()
    if self.uiObjs == nil then
      return
    end
    GUIUtils.SetActive(Img_Item, true)
  end)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Bth_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Img_ItemGet_") then
    local idx = tonumber(string.sub(id, #"Img_ItemGet_" + 1))
    self:OnClickAddStock(idx)
  elseif string.find(id, "Img_Item") then
    local idx = tonumber(string.sub(id, #"Img_Item" + 1))
    self:OnClickGetAward(idx)
  elseif id == "Bth_Help" then
    self:OnClickHelp()
  elseif string.find(id, "btn_visit_") then
    local roleId = string.sub(id, #"btn_visit_" + 1)
    self:OnClickVisitOther(Int64.new(roleId))
  elseif id == "Btn_Get" then
    self:OnClickOnKeyGetAward()
  elseif id == "Btn_Refresh" then
    self:OnClickRefreshCurrentTree()
  else
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.method("number").OnClickAddStock = function(self, idx)
  local currentTree = ChristmasTreeMgr.Instance():GetCurrentVisitTree()
  if not currentTree:IsEmpytyPosition(idx) then
    self:OnClickGetAward(idx)
    return
  end
  if not ChristmasTreeMgr.Instance():CheckIsOpenAndToast() then
    return
  end
  if currentTree:IsFullHangNumOnTree() then
    if currentTree:IsMyChristmasTree() then
      Toast(textRes.activity.ChristmasTree[19])
    else
      Toast(textRes.activity.ChristmasTree[9])
    end
    return
  end
  if ChristmasTreeMgr.Instance():IsTodayFullHangNum() then
    Toast(textRes.activity.ChristmasTree[10])
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local itemModule = ItemModule.Instance()
  local ids = {}
  ids[constant.CChristmasStockingConsts.CONSUME_ITEM_ID] = constant.CChristmasStockingConsts.CONSUME_ITEM_ID
  local itemList = {}
  local items = itemModule:GetItemsByItemIds(ItemModule.BAG, ids)
  for i, v in pairs(items) do
    table.insert(itemList, v)
  end
  if #itemList == 0 then
    Toast(textRes.activity.ChristmasTree[7])
    return
  end
  local function filterFunc(item)
    if ids[item.id] then
      return true
    end
    return false
  end
  local CommonUsePanel = require("GUI.CommonUsePanel")
  CommonUsePanel.Instance():ShowPanelWithItems(filterFunc, nil, CommonUsePanel.Source.Other, itemList, {
    roleId = currentTree:GetRoleId(),
    pos = idx
  })
  CommonUsePanel.Instance():SetPos(-160, -30)
end
def.method("number").OnClickGetAward = function(self, idx)
  local currentTree = ChristmasTreeMgr.Instance():GetCurrentVisitTree()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return
  end
  if not Int64.eq(heroProp.id, currentTree:GetRoleId()) then
    Toast(textRes.activity.ChristmasTree[13])
    return
  end
  if currentTree:IsEmpytyPosition(idx) then
    Toast(textRes.activity.ChristmasTree[11])
    return
  end
  if not currentTree:IsAwardPosition(idx) then
    Toast(textRes.activity.ChristmasTree[12])
    return
  end
  ChristmasTreeMgr.Instance():GetChristmasStockAward(idx)
end
def.method().OnClickHelp = function(self)
  GUIUtils.ShowHoverTip(constant.CChristmasStockingConsts.HOVER_TIPS_CFG_ID, 0, 0)
end
def.method("userdata").OnClickVisitOther = function(self, roleId)
  self:DestroyPanel()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return
  end
  if not Int64.eq(heroProp.id, roleId) then
    gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):VisitHome(roleId)
  elseif gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):HaveHome() then
    gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):ReturnHome()
  end
end
def.method().OnClickOnKeyGetAward = function(self)
  local currentTree = ChristmasTreeMgr.Instance():GetCurrentVisitTree()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return
  end
  if not Int64.eq(heroProp.id, currentTree:GetRoleId()) then
    Toast(textRes.activity.ChristmasTree[13])
    return
  end
  local hasStock = false
  for i = 1, constant.CChristmasStockingConsts.TREE_HANG_MAX_NUM do
    if not currentTree:IsEmpytyPosition(i) then
      hasStock = true
      break
    end
  end
  if not hasStock then
    Toast(textRes.activity.ChristmasTree[17])
    return
  end
  local hasAward = false
  for i = 1, constant.CChristmasStockingConsts.TREE_HANG_MAX_NUM do
    if currentTree:IsAwardPosition(i) then
      ChristmasTreeMgr.Instance():GetChristmasStockAward(i)
      hasAward = true
    end
  end
  if not hasAward then
    Toast(textRes.activity.ChristmasTree[12])
  end
end
def.method().OnClickRefreshCurrentTree = function(self)
  local currentTree = ChristmasTreeMgr.Instance():GetCurrentVisitTree()
  if currentTree == nil then
    return
  end
  ChristmasTreeMgr.Instance():GetChristmasTreeInfo(currentTree:GetRoleId())
end
def.static("table", "table").OnChristmasTreeHangStock = function(params, context)
  local CommonUsePanel = require("GUI.CommonUsePanel")
  CommonUsePanel.Instance():DestroyPanel()
  instance:FlyStockToPos(params.pos)
end
def.static("table", "table").OnChristmasTreeChange = function(params, context)
  instance:UpdateChristmasTreeInfo()
end
return ChristmasTreePanel.Commit()
