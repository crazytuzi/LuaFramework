local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local SmallGroupNode = Lplus.Extend(TabNode, "SmallGroupNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local def = SmallGroupNode.define
def.field("number").m_curPage = 0
def.field("table").m_goodsData = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.method().InitGoodsData = function(self)
  self.m_goodsData = require("Main.GroupShopping.GroupShoppingModule").Instance():GetAllCfgSmallGroup()
  local fullPage = math.ceil(#self.m_goodsData / constant.CGroupShoppingConsts.SMALL_GROUP_SHOPPING_PAGE_SIZE)
  if fullPage == 0 then
    fullPage = 1 or fullPage
  end
  if fullPage <= self.m_curPage then
    self.m_curPage = 0
  end
end
def.method("table").SetSwitchParams = function(self, params)
end
def.override().OnShow = function(self)
  self:InitGoodsData()
  self:UpdatePage()
  self:UpdateGoods()
end
def.method().UpdatePage = function(self)
  local lbl = self.m_node:FindDirect("Group_Page/Img_BgPage/Label_Page")
  local fullPage = math.ceil(#self.m_goodsData / constant.CGroupShoppingConsts.SMALL_GROUP_SHOPPING_PAGE_SIZE)
  if fullPage == 0 then
    fullPage = 1 or fullPage
  end
  lbl:GetComponent("UILabel"):set_text(string.format("%d/%d", self.m_curPage + 1, fullPage))
end
def.method().UpdateGoods = function(self)
  local list = self.m_node:FindDirect("List_Item")
  local listCmp = list:GetComponent("UIList")
  local count = #self.m_goodsData - self.m_curPage * constant.CGroupShoppingConsts.SMALL_GROUP_SHOPPING_PAGE_SIZE >= constant.CGroupShoppingConsts.SMALL_GROUP_SHOPPING_PAGE_SIZE and constant.CGroupShoppingConsts.SMALL_GROUP_SHOPPING_PAGE_SIZE or #self.m_goodsData - self.m_curPage * constant.CGroupShoppingConsts.SMALL_GROUP_SHOPPING_PAGE_SIZE
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    self:FillGoods(uiGo, self.m_goodsData[self.m_curPage * constant.CGroupShoppingConsts.SMALL_GROUP_SHOPPING_PAGE_SIZE + i], i)
    self.m_base.m_msgHandler:Touch(uiGo)
  end
end
def.method("userdata", "number", "number").FillGoods = function(self, uiGo, cfgId, index)
  local cfg = GroupShoppingUtils.GetSmallGroupCfg(cfgId)
  if cfg then
    local itemBase = ItemUtils.GetItemBase(cfg.itemId)
    if itemBase then
      local nameLbl = uiGo:FindDirect(string.format("Label_Name_%d", index))
      local iconBg = uiGo:FindDirect(string.format("Img_BgIcon_%d", index))
      local icon = uiGo:FindDirect(string.format("Img_BgIcon_%d/Img_Icon_%d", index, index))
      local originPrice = uiGo:FindDirect(string.format("Group_OriPrice_%d/Label_Price_%d", index, index))
      local groupPrice = uiGo:FindDirect(string.format("Group_CurPrice_%d/Label_Price_%d", index, index))
      nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
      iconBg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
      GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
      originPrice:GetComponent("UILabel"):set_text(tostring(cfg.originalPrice))
      groupPrice:GetComponent("UILabel"):set_text(tostring(cfg.groupPrice))
    end
  end
end
def.override().OnHide = function(self)
  self.m_goodsData = nil
end
def.override("string").onClick = function(self, id)
  if id == "Btn_GroupPlatform" then
    require("Main.GroupShopping.GroupShoppingModule").Instance():ShowShoppingGroupPlatform(nil)
  elseif id == "Btn_Next" then
    if (self.m_curPage + 1) * constant.CGroupShoppingConsts.SMALL_GROUP_SHOPPING_PAGE_SIZE < #self.m_goodsData then
      self.m_curPage = self.m_curPage + 1
      self:UpdatePage()
      self:UpdateGoods()
    end
  elseif id == "Btn_Back" then
    if self.m_curPage > 0 then
      self.m_curPage = self.m_curPage - 1
      self:UpdatePage()
      self:UpdateGoods()
    end
  elseif string.sub(id, 1, 11) == "Group_Item_" then
    local index = tonumber(string.sub(id, 12))
    if index then
      local cfgId = self.m_goodsData[self.m_curPage * constant.CGroupShoppingConsts.SMALL_GROUP_SHOPPING_PAGE_SIZE + index]
      if cfgId then
        if not require("Main.GroupShopping.GroupShoppingModule").Instance():IsBan(cfgId) then
          require("Main.GroupShopping.ui.ShoppingGroupInfoPanel").ShowGroupShoppingItem(cfgId)
        else
          Toast(textRes.GroupShopping[35])
        end
      end
    end
  end
end
SmallGroupNode.Commit()
return SmallGroupNode
