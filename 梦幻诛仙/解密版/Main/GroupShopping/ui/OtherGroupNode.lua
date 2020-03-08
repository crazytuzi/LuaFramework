local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local OtherGroupNode = Lplus.Extend(TabNode, "OtherGroupNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local def = OtherGroupNode.define
def.field("number").m_curPage = 0
def.field("number").m_fullPage = 0
def.field("number").m_filterId = 0
def.field("table").m_filters = nil
def.field("table").m_groupData = nil
def.field("boolean").m_refresh = false
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.method().InitGroupData = function(self)
  self.m_curPage = 0
  self.m_fullPage = 0
  self.m_filterId = 0
end
def.method("table").SetSwitchParams = function(self, params)
  if params and params.filterId then
    self:RequestPage(self.m_curPage, params.filterId)
  end
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.BuyCountChange, OtherGroupNode.OnBuyCountChange, self)
  self:InitGroupData()
  self:UpdatePage()
  self:UpdateGroups()
  self:RequestPage(self.m_curPage, self.m_filterId)
  self:UpdateFilter(false)
end
def.method("table").OnBuyCountChange = function(self, params)
  local groupId = params.groupId
  local memberNum = params.memberNum
  if groupId and memberNum and self.m_groupData then
    for k, v in pairs(self.m_groupData) do
      if v:GetGroupId() == groupId then
        v:SetCurNum(memberNum)
        break
      end
    end
    self:UpdateGroups()
  end
end
def.method("number", "number").RequestPage = function(self, _page, _filter)
  self.m_filterId = _filter
  if self.m_node and not self.m_node.isnil then
    self.m_node:FindDirect("List_Item"):SetActive(false)
  end
  require("Main.GroupShopping.GroupShoppingModule").Instance():RequestGroupPageWithCallBack(_page, _filter, function(groupList, page, last_page, group_shopping_item_cfgid)
    if self.m_filterId == group_shopping_item_cfgid then
      self.m_curPage = page
      self.m_fullPage = last_page
      self.m_filterId = group_shopping_item_cfgid
      self.m_groupData = groupList
      self:UpdatePage()
      self:UpdateGroups()
      self:UpdateFilter(false)
      if self.m_refresh then
        Toast(textRes.GroupShopping[49])
        self.m_refresh = false
      end
    end
  end)
end
def.method("boolean").UpdateFilter = function(self, open)
  local btn = self.m_node:FindDirect("Btn_Item")
  btn:GetComponent("UIToggleEx"):set_value(open)
  local list = btn:FindDirect("Group_Zone")
  if open then
    if self.m_filters == nil then
      self.m_filters = require("Main.GroupShopping.GroupShoppingModule").Instance():GetAllCfgSmallGroup()
      table.insert(self.m_filters, 1, 0)
    end
    local count = #self.m_filters
    list:SetActive(true)
    local listCmp = list:FindDirect("Group_ChooseType/List"):GetComponent("UIList")
    listCmp:set_itemCount(count)
    listCmp:Resize()
    local items = listCmp:get_children()
    for i = 1, #items do
      local uiGo = items[i]
      local label = uiGo:FindDirect(string.format("Label_Name_%d", i))
      local cfgId = self.m_filters[i]
      local name = textRes.GroupShopping[7]
      if cfgId > 0 then
        local cfg = GroupShoppingUtils.GetGroupCfg(cfgId)
        if cfg then
          local itemBase = ItemUtils.GetItemBase(cfg.itemId)
          if itemBase then
            name = itemBase.name
          end
        end
      end
      label:GetComponent("UILabel"):set_text(name)
      self.m_base.m_msgHandler:Touch(uiGo)
    end
  else
    list:SetActive(false)
  end
  local name = textRes.GroupShopping[7]
  if 0 < self.m_filterId then
    local cfg = GroupShoppingUtils.GetGroupCfg(self.m_filterId)
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        name = itemBase.name
      end
    end
  end
  btn:FindDirect("Label"):GetComponent("UILabel"):set_text(name)
end
def.method().ToggleFilter = function(self)
  local btn = self.m_node:FindDirect("Btn_Item")
  local toggleOn = btn:GetComponent("UIToggleEx"):get_value()
  self:UpdateFilter(toggleOn)
end
def.method().UpdatePage = function(self)
  local lbl = self.m_node:FindDirect("Group_Bottom/Group_Page/Img_BgPage/Label_Page")
  lbl:GetComponent("UILabel"):set_text(string.format("%d/%d", self.m_curPage + 1, self.m_fullPage + 1))
end
def.method().UpdateGroups = function(self)
  local list = self.m_node:FindDirect("List_Item")
  local noData = self.m_node:FindDirect("Group_NoData")
  local count = self.m_groupData and #self.m_groupData or 0
  if count <= 0 then
    noData:SetActive(true)
    list:SetActive(false)
  else
    noData:SetActive(false)
    list:SetActive(true)
    local listCmp = list:GetComponent("UIList")
    listCmp:set_itemCount(count)
    listCmp:Resize()
    local items = listCmp:get_children()
    for i = 1, #items do
      local uiGo = items[i]
      self:FillGroup(uiGo, self.m_groupData[i], i)
      self.m_base.m_msgHandler:Touch(uiGo)
    end
  end
end
def.method("userdata", "table", "number").FillGroup = function(self, uiGo, info, index)
  local cfgId = info:GetCfgId()
  local cfg = GroupShoppingUtils.GetGroupCfg(cfgId)
  if cfg then
    local itemBase = ItemUtils.GetItemBase(cfg.itemId)
    if itemBase then
      local nameLbl = uiGo:FindDirect(string.format("Label_Name_%d", index))
      local iconBg = uiGo:FindDirect(string.format("Img_BgIcon_%d", index))
      local icon = uiGo:FindDirect(string.format("Img_BgIcon_%d/Img_Icon_%d", index, index))
      nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
      iconBg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
      GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
      local countLbl = uiGo:FindDirect(string.format("Group_CurPeople_%d/Label_GroupNum_%d", index, index))
      countLbl:GetComponent("UILabel"):set_text(string.format("%d/%d", info:GetCurNum(), cfg.groupSize))
      local creatorName = uiGo:FindDirect(string.format("Group_People_%d/Label_PlayerName_%d", index, index))
      creatorName:GetComponent("UILabel"):set_text(info:GetCreatorName())
      local money = uiGo:FindDirect(string.format("Group_Prize_%d/Label_PrizeNum_%d", index, index))
      money:GetComponent("UILabel"):set_text(info:GetPrice())
      local mark = uiGo:FindDirect(string.format("Img_Finish_%d", index))
      local joinBtn = uiGo:FindDirect(string.format("Btn_Join_%d", index))
      local isInSmallGroup = require("Main.GroupShopping.GroupShoppingModule").Instance():IsInSmallGroup(info:GetGroupId())
      if isInSmallGroup then
        mark:SetActive(true)
        joinBtn:SetActive(false)
      else
        mark:SetActive(false)
        joinBtn:SetActive(true)
      end
    end
  end
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.BuyCountChange, OtherGroupNode.OnBuyCountChange)
  self.m_curPage = 0
  self.m_fullPage = 0
  self.m_groupData = nil
  self.m_filterId = 0
  self.m_filters = nil
  self.m_refresh = false
end
def.override("string").onClick = function(self, id)
  if id == "Btn_GroupPlatform" then
  elseif id == "Btn_Next" then
    self:RequestPage(self.m_curPage + 1, self.m_filterId)
  elseif id == "Btn_Back" then
    if self.m_curPage > 0 then
      self:RequestPage(self.m_curPage - 1, self.m_filterId)
    end
  elseif id == "Btn_Fresh" then
    self:RequestPage(self.m_curPage, self.m_filterId)
    self.m_refresh = true
  elseif id == "Btn_Item" then
    self:ToggleFilter()
  elseif string.sub(id, 1, 7) == "Img_Bg_" then
    local index = tonumber(string.sub(id, 8))
    local filterId = self.m_filters and self.m_filters[index] or 0
    self:UpdateFilter(false)
    self:RequestPage(self.m_curPage, filterId)
  elseif string.sub(id, 1, 10) == "Btn_Share_" then
    local index = tonumber(string.sub(id, 11))
    if index then
      local info = self.m_groupData[index]
      if info then
        require("Main.GroupShopping.ui.GroupShoppingShare").ShowShareGroup(textRes.GroupShopping[32], textRes.GroupShopping[33], info:GetCfgId(), info:GetGroupId())
      end
    end
  elseif string.sub(id, 1, 9) == "Btn_Join_" then
    local index = tonumber(string.sub(id, 10))
    if index then
      do
        local info = self.m_groupData[index]
        if info then
          do
            local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_GROUP)
            if not open then
              Toast(textRes.GroupShopping[28])
              return
            end
            local GroupShoppingModule = require("Main.GroupShopping.GroupShoppingModule")
            GroupShoppingModule.Instance():RequestCfgDetailInfo(info:GetCfgId(), function(itemInfo)
              GroupShoppingModule.Instance():JoinGroupBuy(info:GetGroupId(), info:GetCfgId(), itemInfo.buyCount, itemInfo.remain)
            end)
          end
        end
      end
    end
  elseif string.sub(id, 1, 11) == "Img_BgItem_" then
    local index = tonumber(string.sub(id, 12))
    if index then
      local info = self.m_groupData[index]
      if info then
        require("Main.GroupShopping.ui.ShoppingGroupInfoPanel").ShowShoppingGroupByInfo(info)
      end
    end
  end
end
OtherGroupNode.Commit()
return OtherGroupNode
