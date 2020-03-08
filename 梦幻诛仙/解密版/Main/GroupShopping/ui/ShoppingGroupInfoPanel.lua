local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ShoppingGroupInfoPanel = Lplus.Extend(ECPanelBase, "ShoppingGroupInfoPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local NotifyBar = require("Main.GroupShopping.ui.NotifyBar")
local def = ShoppingGroupInfoPanel.define
def.const("table").InfoType = {Static = 1, Dynamic = 2}
def.field("number").m_type = 1
def.field("table").m_itemInfo = nil
def.field("table").m_groupInfo = nil
def.field("number").m_timer = 0
def.field(NotifyBar).m_bar = nil
local instance
def.static("=>", ShoppingGroupInfoPanel).Instance = function()
  if instance == nil then
    instance = ShoppingGroupInfoPanel()
  end
  return instance
end
def.static("number").ShowGroupShoppingItem = function(cfgId)
  require("Main.GroupShopping.GroupShoppingModule").Instance():RequestCfgDetailInfo(cfgId, function(itemInfo)
    local dlg = ShoppingGroupInfoPanel.Instance()
    dlg:ShowInfoPanel(itemInfo, nil, ShoppingGroupInfoPanel.InfoType.Static)
  end)
end
def.static("userdata").ShowShoppingGroupById = function(groupId)
  require("Main.GroupShopping.GroupShoppingModule").Instance():RequestGroupDetailInfo(groupId, function(groupInfo)
    ShoppingGroupInfoPanel.ShowShoppingGroupByInfo(groupInfo)
  end)
end
def.static("table").ShowShoppingGroupByInfo = function(groupInfo)
  require("Main.GroupShopping.GroupShoppingModule").Instance():RequestCfgDetailInfo(groupInfo:GetCfgId(), function(itemInfo)
    local dlg = ShoppingGroupInfoPanel.Instance()
    dlg:ShowInfoPanel(itemInfo, groupInfo, ShoppingGroupInfoPanel.InfoType.Dynamic)
  end)
end
def.static("string").AddNotify = function(notify)
  local self = ShoppingGroupInfoPanel.Instance()
  if self:IsShow() and self.m_bar then
    self.m_bar:AddNotify(notify)
  end
end
def.method("table", "table", "number").ShowInfoPanel = function(self, itemInfo, groupInfo, type)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_itemInfo = itemInfo
  self.m_groupInfo = groupInfo
  self.m_type = type
  self:CreatePanel(RESPATH.PREFAB_GROUP_SHOPPING_INFO, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.BuyCountChange, ShoppingGroupInfoPanel.OnBuyCountChange, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ShoppingGroupInfoPanel.OnFeatureChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.NeedRefreshData, ShoppingGroupInfoPanel.OnUpdate, self)
  self:UpdateStatic()
  self:UpdateDynamic()
  self.m_bar = NotifyBar.Create(self.m_panel:FindDirect("Img_Bg0/Group_Message"))
end
def.method("table").OnFeatureChange = function(self, params)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING and params.open == false then
    self:DestroyPanel()
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
    local notify = require("Main.GroupShopping.GroupShoppingModule").Instance():GetNotify()
    self.m_bar:SetNotify(notify)
  end
end
def.method("table").OnBuyCountChange = function(self, params)
  local cfgId = params.cfgId
  if self.m_itemInfo and cfgId == self.m_itemInfo.cfgId then
    require("Main.GroupShopping.GroupShoppingModule").Instance():RequestCfgDetailInfo(cfgId, function(itemInfo)
      if self:IsShow() then
        self.m_itemInfo = itemInfo
        self:UpdateStatic()
        self:UpdateDynamic()
      end
    end)
  end
end
def.method("table").OnUpdate = function(self, params)
  local cfgId = params.cfgId
  if self.m_itemInfo and cfgId == self.m_itemInfo.cfgId then
    require("Main.GroupShopping.GroupShoppingModule").Instance():RequestCfgDetailInfo(cfgId, function(itemInfo)
      if self:IsShow() then
        self.m_itemInfo = itemInfo
        self:UpdateStatic()
        self:UpdateDynamic()
      end
    end)
  end
end
local minSec = 60
local hourSec = 60 * minSec
local daySec = 24 * hourSec
local function sec2str(sec)
  local day = math.floor(sec / daySec)
  local hour = math.floor((sec - day * daySec) / hourSec)
  local min = math.floor((sec - day * daySec - hour * hourSec) / minSec)
  local second = sec - day * daySec - hour * hourSec - min * minSec
  local timeTbl = {}
  if day > 0 then
    table.insert(timeTbl, day .. textRes.Common.Day)
  end
  if hour > 0 or #timeTbl > 0 then
    table.insert(timeTbl, hour .. textRes.Common.Hour)
  end
  if min > 0 or #timeTbl > 0 then
    table.insert(timeTbl, min .. textRes.Common.Minute)
  end
  table.insert(timeTbl, second .. textRes.Common.Second)
  return table.concat(timeTbl)
end
def.method().UpdateStatic = function(self)
  local cfgId = self.m_itemInfo.cfgId
  local cfg = GroupShoppingUtils.GetSmallGroupCfg(cfgId)
  if cfg then
    local itemBase = ItemUtils.GetItemBase(cfg.itemId)
    if itemBase then
      local groupItem = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_Item")
      local iconBg = groupItem:FindDirect("Img_BgIcon")
      local icon = iconBg:FindDirect("Img_Icon")
      local name = groupItem:FindDirect("Label_Name")
      local originPrice = groupItem:FindDirect("Group_OriPrice/Label_Price")
      local groupPrice = groupItem:FindDirect("Group_CurPrice/Label")
      local needTime = groupItem:FindDirect("Group_Date/Label_Date")
      local typeName = groupItem:FindDirect("Group_Info/Label_Type")
      local desc = groupItem:FindDirect("Group_Info/Label_Content")
      local needNum = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_People/Label_Num")
      iconBg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
      GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
      name:GetComponent("UILabel"):set_text(itemBase.name)
      originPrice:GetComponent("UILabel"):set_text(tostring(cfg.originalPrice))
      groupPrice:GetComponent("UILabel"):set_text(tostring(cfg.groupPrice))
      needTime:GetComponent("UILabel"):set_text(sec2str(cfg.duration * 60))
      typeName:GetComponent("UILabel"):set_text(itemBase.itemTypeName)
      desc:GetComponent("UILabel"):set_text(require("Main.Chat.HtmlHelper").RemoveHtmlTag(itemBase.desc))
      needNum:GetComponent("UILabel"):set_text(cfg.groupSize)
      local directBuyMoney = self.m_panel:FindDirect("Img_Bg0/Group_Bottom/Group_Option/Group_Option01/Group_SalePrice/Label_SalePrice")
      directBuyMoney:GetComponent("UILabel"):set_text(cfg.singlePrice)
      local left = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_Rest/Label_Num")
      local myLeft = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_Num/Label_Num")
      if self.m_itemInfo.remain >= 0 then
        left:GetComponent("UILabel"):set_text(string.format(textRes.GroupShopping[10], self.m_itemInfo.remain))
      else
        left:GetComponent("UILabel"):set_text(textRes.GroupShopping[5])
      end
      if 0 < cfg.maxBuyNum then
        myLeft:GetComponent("UILabel"):set_text(string.format(textRes.GroupShopping[11], self.m_itemInfo.buyCount, cfg.maxBuyNum))
      else
        myLeft:GetComponent("UILabel"):set_text(textRes.GroupShopping[5])
      end
    end
  end
end
def.method().UpdateDynamic = function(self)
  if self.m_type == ShoppingGroupInfoPanel.InfoType.Static then
    self:UpdateItemInfo()
  elseif self.m_type == ShoppingGroupInfoPanel.InfoType.Dynamic then
    self:UpdateGroupInfo()
  end
end
def.method().UpdateGroupInfo = function(self)
  local options = self.m_panel:FindDirect("Img_Bg0/Group_Bottom/Group_Option")
  local option2 = options:FindDirect("Group_Option02")
  local option3 = options:FindDirect("Group_Option03")
  local option4 = options:FindDirect("Group_Option04")
  local option5 = options:FindDirect("Group_Option05")
  option2:SetActive(false)
  option3:SetActive(false)
  option4:SetActive(false)
  option5:SetActive(true)
  local creatorName = option5:FindDirect("Group_label/Label_CreatName")
  local joinNum = option5:FindDirect("Group_label/Label_JoinNum")
  local leftTime = option5:FindDirect("Group_label/Label_EndNum")
  creatorName:GetComponent("UILabel"):set_text(self.m_groupInfo:GetCreatorName())
  joinNum:GetComponent("UILabel"):set_text(string.format(textRes.GroupShopping[12], self.m_groupInfo:GetCurNum()))
  local endSec = self.m_groupInfo:GetEndTime()
  local leftTimeLbl = leftTime:GetComponent("UILabel")
  local sec = endSec - GetServerTime()
  if sec > 0 then
    leftTimeLbl:set_text(sec2str(sec))
  else
    leftTimeLbl:set_text(textRes.GroupShopping[13])
  end
  if sec > 0 then
    self.m_timer = GameUtil.AddGlobalTimer(1, false, function()
      if not leftTimeLbl.isnil then
        sec = endSec - GetServerTime()
        if sec > 0 then
          leftTimeLbl:set_text(sec2str(sec))
        else
          GameUtil.RemoveGlobalTimer(self.m_timer)
          self.m_timer = 0
          leftTimeLbl:set_text(textRes.GroupShopping[13])
        end
      else
        GameUtil.RemoveGlobalTimer(self.m_timer)
        self.m_timer = 0
      end
    end)
  end
end
def.method().UpdateItemInfo = function(self)
  local cfgId = self.m_itemInfo.cfgId
  local options = self.m_panel:FindDirect("Img_Bg0/Group_Bottom/Group_Option")
  local option2 = options:FindDirect("Group_Option02")
  local option3 = options:FindDirect("Group_Option03")
  local option4 = options:FindDirect("Group_Option04")
  local option5 = options:FindDirect("Group_Option05")
  local isBuying = require("Main.GroupShopping.GroupShoppingModule").Instance():IsBuyingItem(cfgId)
  if isBuying then
    option2:SetActive(false)
    option3:SetActive(false)
    option4:SetActive(true)
    option5:SetActive(false)
  else
    option2:SetActive(true)
    option3:SetActive(true)
    option4:SetActive(false)
    option5:SetActive(false)
    local curGroupNum = self.m_itemInfo.groupNum
    local curGroupLbl = option2:FindDirect("Label_Name")
    curGroupLbl:GetComponent("UILabel"):set_text(string.format(textRes.GroupShopping[9], curGroupNum))
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.BuyCountChange, ShoppingGroupInfoPanel.OnBuyCountChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ShoppingGroupInfoPanel.OnFeatureChange)
  Event.UnregisterEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.NeedRefreshData, ShoppingGroupInfoPanel.OnUpdate)
  self.m_type = 1
  self.m_itemInfo = nil
  self.m_groupInfo = nil
  GameUtil.RemoveGlobalTimer(self.m_timer)
  self.m_timer = 0
  self.m_bar = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Help" then
    GUIUtils.ShowHoverTip(constant.CGroupShoppingConsts.DESCRIPTION_TIP_ID, 0, 0)
  elseif id == "Btn_Trans" then
    if self.m_itemInfo then
      if self.m_groupInfo then
        require("Main.GroupShopping.ui.GroupShoppingShare").ShowShareGroup(textRes.GroupShopping[32], textRes.GroupShopping[33], self.m_itemInfo.cfgId, self.m_groupInfo:GetGroupId())
      else
        require("Main.GroupShopping.ui.GroupShoppingShare").ShowShareGroup(textRes.GroupShopping[32], textRes.GroupShopping[33], self.m_itemInfo.cfgId, nil)
      end
    end
  elseif id == "Btn_Buy" then
    local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_SINGLE)
    if not open then
      Toast(textRes.GroupShopping[29])
      return
    end
    require("Main.GroupShopping.GroupShoppingModule").Instance():PriceBuy(self.m_itemInfo.cfgId, self.m_itemInfo.buyCount)
  elseif id == "Btn_Join" then
    if self.m_itemInfo and self.m_groupInfo then
      local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_GROUP)
      if not open then
        Toast(textRes.GroupShopping[28])
        return
      end
      local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
      local state = self.m_groupInfo:UpdateStatus()
      if state == ShoppingGroupInfo.INCOMPLETED then
        require("Main.GroupShopping.GroupShoppingModule").Instance():JoinGroupBuy(self.m_groupInfo:GetGroupId(), self.m_itemInfo.cfgId, self.m_itemInfo.buyCount, self.m_itemInfo.remain)
      else
        Toast(textRes.GroupShopping[40])
      end
    end
  elseif id == "Btn_Creat" then
    require("Main.GroupShopping.GroupShoppingModule").Instance():CreateGroupShopping(self.m_itemInfo.cfgId, self.m_itemInfo.buyCount, self.m_itemInfo.remain)
  elseif id == "Btn_Watch" then
    require("Main.GroupShopping.GroupShoppingModule").Instance():ShowShoppingGroupPlatform({
      filterId = self.m_itemInfo.cfgId
    })
  elseif id == "Btn_Look" then
    require("Main.GroupShopping.GroupShoppingModule").Instance():ShowMyShoppingGroup(nil)
  elseif string.sub(id, 1, 14) == "shoppingGroup_" then
    require("Main.GroupShopping.GroupShoppingModule").Instance():ShareClick(id)
  end
end
ShoppingGroupInfoPanel.Commit()
return ShoppingGroupInfoPanel
