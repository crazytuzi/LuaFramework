local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ActivityNode = Lplus.Extend(TabNode, "ActivityNode")
local ECPanelBase = require("GUI.ECPanelBase")
local BTGJiFen = require("Main.BackToGame.mgr.BTGJiFen")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ItemModule = require("Main.Item.ItemModule")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local def = ActivityNode.define
def.field("table").m_activityData = nil
def.field("table").m_items = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ActivityUpdate, ActivityNode.OnUpdate, self)
  Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, ActivityNode.OnActivityInfoChanged, self)
  Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, ActivityNode.OnActivityInfoChanged, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, ActivityNode.OnCreditChange, self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ActivityUpdate, ActivityNode.OnUpdate)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, ActivityNode.OnActivityInfoChanged)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, ActivityNode.OnActivityInfoChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, ActivityNode.OnCreditChange)
  self.m_activityData = nil
  self.m_items = nil
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Tip" then
    local tipsId = BTGJiFen.Instance():GetTipsId()
    GUIUtils.ShowHoverTip(tipsId)
  elseif string.sub(id, 1, 9) == "Btn_Join_" then
    local index = tonumber(string.sub(id, 10))
    if index then
      local info = self.m_activityData[index]
      if info then
        self.m_base:DestroyPanel()
        Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
          info.activityId
        })
      end
    end
  elseif string.sub(id, 1, 8) == "Img_Gift" then
    local index = tonumber(string.sub(id, 9))
    if self.m_items[index] then
      local info = self.m_items[index]
      local icon = self.m_node:FindDirect("Group_Gift/" .. id .. "/Img_Icon")
      if icon then
        ItemTipsMgr.Instance():ShowBasicTipsWithGO(info.itemId, icon, 0, false)
      end
    end
  elseif id == "Btn_Join" then
    self:OnBtnExchangeClick()
  end
end
def.method("table").OnActivityInfoChanged = function(self, param)
  local activityId = param[1]
  if self.m_activityData then
    for k, v in pairs(self.m_activityData) do
      if activityId == v.activityId then
        self:UpdateUI()
        break
      end
    end
  end
end
def.method("table").OnCreditChange = function(self, params)
  self:UpdateJifen()
end
def.method("table").OnUpdate = function(self, param)
  self:UpdateUI()
end
def.method().UpdateUI = function(self)
  local actData, items = BTGJiFen.Instance():GetActivityAndJifenData()
  self.m_activityData = actData
  self.m_items = items
  self:UpdateActivity()
  self:UpdateItems()
  self:UpdateJifen()
end
def.method().UpdateActivity = function(self)
  local scroll = self.m_node:FindDirect("Group_Activity/Scroll View")
  local list = scroll:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  local count = #self.m_activityData
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.m_activityData[i]
    self:FillItem(uiGo, info, i)
    self.m_base.m_msgHandler:Touch(uiGo)
  end
end
def.method("userdata", "table", "number").FillItem = function(self, uiGo, data, index)
  local icon = uiGo:FindDirect(string.format("Img_BgIcon_%d", index))
  local name = uiGo:FindDirect(string.format("Label_Name_%d", index))
  local num = uiGo:FindDirect(string.format("Label_Num_%d", index))
  local active = uiGo:FindDirect(string.format("Label_ActiveNum_%d", index))
  local btn = uiGo:FindDirect(string.format("Btn_Join_%d", index))
  local fin = uiGo:FindDirect(string.format("Img_Finish_%d", index))
  GUIUtils.FillIcon(icon:GetComponent("UITexture"), data.icon)
  name:GetComponent("UILabel"):set_text(data.name)
  local showCount = data.count > data.times and data.times or data.count
  num:GetComponent("UILabel"):set_text(string.format("%d/%d", showCount, data.times))
  active:GetComponent("UILabel"):set_text(string.format("%d/%d", data.point * showCount, data.point * data.times))
  if data.count >= data.times then
    btn:SetActive(false)
    fin:SetActive(true)
  else
    btn:SetActive(true)
    fin:SetActive(false)
  end
end
def.method().UpdateItems = function(self)
  local group = self.m_node:FindDirect("Group_Gift")
  for i = 1, 5 do
    local Img_Gift = group:FindDirect(string.format("Img_Gift%02d", i))
    local item = self.m_items[i]
    if item then
      local itemBase = ItemUtils.GetItemBase(item.itemId)
      if itemBase then
        Img_Gift:SetActive(true)
        local icon = Img_Gift:FindDirect("Img_Texture")
        local bg = Img_Gift:FindDirect("Img_Icon")
        GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
        bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
      else
        Img_Gift:SetActive(false)
      end
    else
      Img_Gift:SetActive(false)
    end
  end
end
def.method().UpdateJifen = function(self)
  local Label_Score = self.m_node:FindDirect("Label_Score")
  local value = ItemModule.Instance():GetCredits(TokenType.BACK_GAME_ACTIVITY_POINT) or Int64.new(0)
  GUIUtils.SetText(Label_Score, value:tostring())
  local Btn_Join = self.m_node:FindDirect("Btn_Join")
  local Img_Red = Btn_Join:FindDirect("Img_Red")
  GUIUtils.SetActive(Img_Red, BTGJiFen.Instance():HasJifenNotify())
end
def.method("=>", "boolean").IsOpen = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_POINT)
  return open
end
def.method().OnBtnExchangeClick = function(self)
  BTGJiFen.Instance():MarkViewedJifen(true)
  BTGJiFen.Instance():GoToExchangeShop()
end
ActivityNode.Commit()
return ActivityNode
