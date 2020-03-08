local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local NationalDayUtils = require("Main.activity.NationalDay.NationalDayUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local PanelXLSQ = Lplus.Extend(ECPanelBase, "PanelXLSQ")
local def = PanelXLSQ.define
local instance
def.static("=>", PanelXLSQ).Instance = function()
  if instance == nil then
    instance = PanelXLSQ()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table").ingredients = nil
def.field("table").composeCfg = nil
def.field("table").product = nil
def.field("table").ingredientsNum = nil
def.static().ShowPanel = function()
  if PanelXLSQ.Instance():IsShow() then
    PanelXLSQ.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_ACTIVITY_NATIONAL_DAY_XLSQ, 1)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  local Label_Tips = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
  Label_Tips:GetComponent("UILabel"):set_text(textRes.activity.NationalDay[15])
  self._uiObjs = {}
  self._uiObjs.Group_Left = self.m_panel:FindDirect("Img_Bg0/Group_Left")
  local downtip = self._uiObjs.Group_Left:FindDirect("Label_Tips")
  downtip:GetComponent("UILabel"):set_text(textRes.activity.NationalDay[16])
  self._uiObjs.left_items = {}
  self._uiObjs.selectIcons = {}
  for i = 1, 4 do
    local item = self._uiObjs.Group_Left:FindDirect("Group_Item/Img_ItemGet0" .. i)
    self._uiObjs.left_items[i] = item
    if i > 1 then
      local sel = item:FindDirect("Img_ItemSelect")
      self._uiObjs.selectIcons[i] = sel
      sel:SetActive(false)
    end
  end
  self._uiObjs.Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
  self._uiObjs.right_items = {}
  for i = 1, 3 do
    self._uiObjs.right_items[i] = self._uiObjs.Group_Right:FindDirect("Img_Item0" .. i)
  end
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PanelXLSQ.OnBagInfoSynchronized)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CMidAutumnHolidayConst.COOKIE_CAKE_ID)
    local time_label = self.m_panel:FindDirect("Img_Bg0/Group_Time/Label_Time")
    time_label:GetComponent("UILabel"):set_text(activityCfg.timeDes)
    self:UpdateUI()
  end
end
def.method().UpdateUI = function(self)
  if self.ingredients == nil then
    self.ingredients = NationalDayUtils.GetMooncakeIngredientCfg(1)
  end
  if self.composeCfg == nil then
    self.composeCfg = gmodule.moduleMgr:GetModule(ModuleId.NATIONAL_DAY).composeCfg or NationalDayUtils.GetMooncakeComposeCfg(1)
  end
  local _, defaultProduct = next(self.composeCfg.products)
  self.product = defaultProduct
  self:UpdateIngredients()
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  instance:UpdateIngredients()
end
def.method().UpdateIngredients = function(self)
  if self.ingredients == nil then
    return
  end
  if self.ingredientsNum == nil then
    self.ingredientsNum = {}
  end
  for i = 1, 4 do
    local itemId
    if i <= #self.ingredients.requisite then
      itemId = self.ingredients.requisite[i]
    else
      itemId = self.ingredients.options[i - #self.ingredients.requisite]
    end
    if itemId and itemId > 0 then
      local num = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetItemCountById(itemId)
      self.ingredientsNum[itemId] = num
      self:SetIcon(self._uiObjs.left_items[i], itemId, num)
    end
  end
  self:SetProductInfo(self.product)
end
def.method("userdata", "number", "number").SetIcon = function(self, item, itemId, itemNum)
  local icon = item:FindDirect("Img_Icon")
  local uiTexture = icon:GetComponent("UITexture")
  local itemBase = ItemUtils.GetItemBase(itemId)
  icon:SetActive(true)
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local Label_Name = item:FindDirect("Label_Name")
  if Label_Name then
    local itemName = itemBase.name
    local color = HtmlHelper.NameColor[itemBase.namecolor]
    if color then
      itemName = string.format("[%s]%s[-]", color, itemName)
    end
    GUIUtils.SetText(Label_Name, itemName)
  end
  local Label_Number = item:FindDirect("Label_Number")
  GUIUtils.SetText(Label_Number, itemNum)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PanelXLSQ.OnBagInfoSynchronized)
  self._uiObjs = nil
  self.ingredients = nil
  self.composeCfg = nil
  self.product = nil
  self.ingredientsNum = nil
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Img_ItemGet0") == 1 then
    local idx = tonumber(string.sub(id, -1, -1))
    self:SelectIngredient(idx)
  elseif string.find(id, "Img_Item0") == 1 then
    if self.product == nil then
      return
    end
    local idx = tonumber(string.sub(id, -1, -1))
    local itemId = self.product.itemIds[idx] or self.product.createItemId
    local anchorGO = self._uiObjs.right_items[idx]
    if itemId and anchorGO then
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, anchorGO, 0, false)
    end
  elseif id == "Bth_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Make" then
    self:CookReq(false)
  elseif id == "Btn_MakeAll" then
    self:CookReq(true)
  elseif id == "Btn_Help" then
    if self.ingredients == nil then
      return
    end
    _G.ShowCommonCenterTip(self.ingredients.tipsId)
  end
end
def.method("number").SelectIngredient = function(self, idx)
  if self.ingredients == nil then
    return
  end
  for k, v in pairs(self._uiObjs.selectIcons) do
    v:SetActive(k == idx)
  end
  local optionIdx = idx - #self.ingredients.requisite
  if optionIdx > 0 then
    local itemId = self.ingredients.options[optionIdx]
    local item_ingredients = {}
    for k, v in pairs(self.ingredients.requisite) do
      table.insert(item_ingredients, v)
    end
    table.insert(item_ingredients, itemId)
    local product = self:GetProductByIngredients(item_ingredients)
    if product then
      self.product = product
      self:SetProductInfo(product)
    else
      warn("[SelectIngredient]product is nil")
    end
  end
end
def.method("boolean").CookReq = function(self, isAll)
  if self.product == nil then
    return
  end
  for idx, v in pairs(self.product.itemIds) do
    if self.ingredientsNum[v] == nil or self.ingredientsNum[v] < self.product.itemNums[idx] then
      Toast(textRes.activity.NationalDay.MOONCAKE_ERROR[7])
      return
    end
  end
  local pro = require("netio.protocol.mzm.gsp.cookiecake.CCreateItemReq").new()
  pro.activity_id = constant.CMidAutumnHolidayConst.COOKIE_CAKE_ID
  pro.create_item_id = self.product.createItemId
  if isAll then
    pro.action_type = pro.CREATE_ALL
  else
    pro.action_type = pro.CREATE_ONE
  end
  gmodule.network.sendProtocol(pro)
end
def.method("table", "=>", "table").GetProductByIngredients = function(self, items)
  if self.composeCfg == nil then
    return nil
  end
  local products = self.composeCfg.products
  for k, v in pairs(products) do
    local isAllMatched = true
    for _, id in pairs(v.itemIds) do
      if not table.indexof(items, id) then
        isAllMatched = false
      end
    end
    if isAllMatched then
      return v
    end
  end
  return nil
end
def.method("table").SetProductInfo = function(self, product)
  if product == nil then
    return
  end
  for i = 1, #product.itemIds do
    local item = self._uiObjs.right_items[i]
    local itemId = product.itemIds[i]
    local itemNum = product.itemNums[i]
    if item and itemId and itemNum then
      self:SetIcon(item, itemId, itemNum)
      local Label_Number = item:FindDirect("Label_Number")
      local has = self.ingredientsNum[itemId]
      local numstr
      if itemNum > has then
        numstr = string.format("[ff0000]%d[-]", itemNum)
      else
        numstr = string.format("[ffffff]%d[-]", itemNum)
      end
      GUIUtils.SetText(Label_Number, numstr)
    end
  end
  local productItem = self._uiObjs.right_items[#self._uiObjs.right_items]
  self:SetIcon(productItem, product.createItemId, product.createItemNum)
end
PanelXLSQ.Commit()
return PanelXLSQ
