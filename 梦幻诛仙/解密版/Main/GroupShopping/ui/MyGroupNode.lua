local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local MyGroupNode = Lplus.Extend(TabNode, "MyGroupNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local def = MyGroupNode.define
def.field("number").m_curPage = 0
def.field("number").m_filterId = 0
def.field("table").m_filters = nil
def.field("table").m_groupData = nil
def.field("number").m_timer = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.method().InitGroupData = function(self)
  self.m_curPage = 0
  self.m_filterId = 0
  self.m_groupData = require("Main.GroupShopping.GroupShoppingModule").Instance():GetMyShoppingGroups(self.m_filterId)
end
def.method().RefreshData = function(self)
  self.m_curPage = 0
  self.m_groupData = require("Main.GroupShopping.GroupShoppingModule").Instance():GetMyShoppingGroups(self.m_filterId)
end
def.method("table").SetSwitchParams = function(self, params)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.GroupMemberChange, MyGroupNode.OnGroupMemberChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.MyGroupListChange, MyGroupNode.OnGroupListChange, self)
  self:InitGroupData()
  self:UpdatePage()
  self:UpdateGroups()
  self:UpdateFilter(false)
end
def.method("table").OnGroupMemberChange = function(self, params)
  local groupId = params.groupId
  if self.m_groupData then
    local needUpdate = false
    for i = 1, constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE do
      local info = self.m_groupData[self.m_curPage * constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE + i]
      if info then
        if info:GetGroupId() == groupId then
          needUpdate = true
          break
        end
      else
        break
      end
    end
    if needUpdate then
      self:UpdateGroups()
    end
  end
end
def.method("table").OnGroupListChange = function(self, params)
  self:InitGroupData()
  self:UpdatePage()
  self:UpdateGroups()
  self:UpdateFilter(false)
end
def.method("boolean").UpdateFilter = function(self, open)
  local btn = self.m_node:FindDirect("Btn_Item")
  btn:GetComponent("UIToggleEx"):set_value(open)
  local list = btn:FindDirect("Group_Zone")
  if open then
    if self.m_filters == nil then
      self.m_filters = require("Main.GroupShopping.GroupShoppingModule").Instance():GetAllCfgGroup()
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
  local fullPage = math.ceil(#self.m_groupData / constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE)
  if fullPage == 0 then
    fullPage = 1 or fullPage
  end
  lbl:GetComponent("UILabel"):set_text(string.format("%d/%d", self.m_curPage + 1, fullPage))
end
def.method().UpdateGroups = function(self)
  GameUtil.RemoveGlobalTimer(self.m_timer)
  self.m_timer = 0
  local list = self.m_node:FindDirect("List_Item")
  local noData = self.m_node:FindDirect("Group_NoData")
  local count = #self.m_groupData - self.m_curPage * constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE >= constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE and constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE or #self.m_groupData - self.m_curPage * constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE
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
      self:FillGroup(uiGo, self.m_groupData[self.m_curPage * constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE + i], i)
      self.m_base.m_msgHandler:Touch(uiGo)
    end
    self.m_timer = GameUtil.AddGlobalTimer(1, false, function()
      if self.m_node.isnil then
        GameUtil.RemoveGlobalTimer(self.m_timer)
        self.m_timer = 0
        return
      end
      for i = 1, count do
        local group = self.m_groupData[self.m_curPage * constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE + i]
        if group and group:GetStatus() ~= group:UpdateStatus() then
          GameUtil.RemoveGlobalTimer(self.m_timer)
          self.m_timer = 0
          self:UpdateGroups()
          break
        end
      end
    end)
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
      local mark = uiGo:FindDirect(string.format("Img_State_%d", index))
      local state = info:UpdateStatus()
      if state == ShoppingGroupInfo.INCOMPLETED then
        mark:GetComponent("UISprite"):set_spriteName("Img_Doing")
      elseif state == ShoppingGroupInfo.COMPLETED then
        mark:GetComponent("UISprite"):set_spriteName("Img_End")
      elseif state == ShoppingGroupInfo.FAILED then
        mark:GetComponent("UISprite"):set_spriteName("Img_Fail")
      end
    end
  end
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.GroupMemberChange, MyGroupNode.OnGroupMemberChange)
  Event.UnregisterEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.MyGroupListChange, MyGroupNode.OnGroupListChange)
  self.m_curPage = 0
  self.m_filterId = 0
  self.m_groupData = nil
  self.m_filters = nil
  GameUtil.RemoveGlobalTimer(self.m_timer)
  self.m_timer = 0
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Next" then
    if (self.m_curPage + 1) * constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE < #self.m_groupData then
      self.m_curPage = self.m_curPage + 1
      self:UpdatePage()
      self:UpdateGroups()
    end
  elseif id == "Btn_Back" then
    if self.m_curPage > 0 then
      self.m_curPage = self.m_curPage - 1
      self:UpdatePage()
      self:UpdateGroups()
    end
  elseif id == "Btn_Item" then
    self:ToggleFilter()
  elseif string.sub(id, 1, 7) == "Img_Bg_" then
    local index = tonumber(string.sub(id, 8))
    self.m_filterId = self.m_filters[index]
    self:RefreshData()
    self:UpdatePage()
    self:UpdateGroups()
    self:UpdateFilter(false)
  elseif string.sub(id, 1, 11) == "Img_BgItem_" then
    local index = tonumber(string.sub(id, 12))
    if index then
      local info = self.m_groupData[self.m_curPage * constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE + index]
      if info then
        local cfgId = info:GetCfgId()
        local type = GroupShoppingUtils.GetGroupType(cfgId)
        if type == 0 then
          require("Main.GroupShopping.ui.ShoppingGroupInfoPanel").ShowShoppingGroupByInfo(info)
        elseif type == 1 then
          self.m_base:DestroyPanel()
          local GroupShoppingMainPanel = require("Main.GroupShopping.ui.GroupShoppingMainPanel")
          GroupShoppingMainPanel.ShowPanelTo(GroupShoppingMainPanel.NodeId.BigNode, {cfgId = cfgId})
        end
      end
    end
  elseif string.sub(id, 1, 10) == "Btn_Share_" then
    local index = tonumber(string.sub(id, 11))
    if index then
      local data = self.m_groupData[self.m_curPage * constant.CGroupShoppingConsts.GROUP_SHOPPING_PLATFORM_PAGE_SIZE + index]
      if data then
        require("Main.GroupShopping.ui.GroupShoppingShare").ShowShareGroup(textRes.GroupShopping[32], textRes.GroupShopping[33], data:GetCfgId(), data:GetGroupId())
      end
    end
  end
end
MyGroupNode.Commit()
return MyGroupNode
