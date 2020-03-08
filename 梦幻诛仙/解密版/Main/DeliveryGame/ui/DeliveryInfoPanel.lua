local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DeliveryInfoPanel = Lplus.Extend(ECPanelBase, "DeliveryInfoPanel")
local GUIUtils = require("GUI.GUIUtils")
local DeliveryGameUtils = require("Main.DeliveryGame.DeliveryGameUtils")
local def = DeliveryInfoPanel.define
local instance
def.static("=>", DeliveryInfoPanel).Instance = function()
  if instance == nil then
    instance = DeliveryInfoPanel()
  end
  return instance
end
def.field("number").activityId = 0
def.field("number").count = 0
def.static("number", "number").ShowDeliveryInfoPanel = function(activityId, count)
  local self = DeliveryInfoPanel.Instance()
  self.count = count
  if self.activityId == activityId then
    if self:IsCreated() then
      if self:IsLoaded() then
        self:UpdateTimes()
        self:UpdateRewards()
      end
    else
      local res = DeliveryGameUtils.GetActivityRes(activityId)
      self:CreatePanel(res.PREFAB_DELIVERY_PANEL, 1)
      self:SetModal(true)
    end
  else
    self:DestroyPanel()
    self.activityId = activityId
    local res = DeliveryGameUtils.GetActivityRes(activityId)
    self:CreatePanel(res.PREFAB_DELIVERY_PANEL, 1)
    self:SetModal(true)
  end
end
def.static().Close = function()
  DeliveryInfoPanel.Instance():DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Item_Change, DeliveryInfoPanel.OnItemUpdate, self)
  Event.RegisterEventWithContext(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Rewards_Change, DeliveryInfoPanel.OnRewardUpdate, self)
  Event.RegisterEventWithContext(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Count_Change, DeliveryInfoPanel.OnCountUpdate, self)
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:UpdateStaticInfo()
    self:UpdateItem()
    self:UpdateTimes()
    self:UpdateRewards()
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Item_Change, DeliveryInfoPanel.OnItemUpdate)
  Event.UnregisterEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Rewards_Change, DeliveryInfoPanel.OnRewardUpdate)
  Event.UnregisterEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Count_Change, DeliveryInfoPanel.OnCountUpdate)
end
def.method("table").OnItemUpdate = function(self, param)
  if self.activityId == param.activityId and self.m_panel and not self.m_panel.isnil then
    self:UpdateItem()
  end
end
def.method("table").OnRewardUpdate = function(self, param)
  if self.activityId == param.activityId and self.m_panel and not self.m_panel.isnil then
    self:UpdateRewards()
  end
end
def.method("table").OnCountUpdate = function(self, param)
  if self.activityId == param.activityId and self.m_panel and not self.m_panel.isnil then
    self.count = param.count or 0
    self:UpdateTimes()
    self:UpdateRewards()
  end
end
def.method("userdata", "boolean", "boolean", "number", "number", "number").FillItem = function(self, uiGo, reached, fetched, count, iconId, index)
  local finish = uiGo:FindDirect(string.format("Img_Finish_%d", index))
  local get = uiGo:FindDirect(string.format("Btn_Get_%d", index))
  if fetched then
    finish:SetActive(true)
    get:SetActive(false)
  elseif reached then
    finish:SetActive(false)
    get:SetActive(true)
    get:GetComponent("UIButton").isEnabled = true
  else
    finish:SetActive(false)
    get:SetActive(true)
    get:GetComponent("UIButton").isEnabled = false
  end
  local lbl = uiGo:FindDirect(string.format("Label_Times_%d", index))
  lbl:GetComponent("UILabel"):set_text(string.format(textRes.DeliveryGame[1], count))
  local icon = uiGo:FindDirect(string.format("Img_Item_%d/Icon_Item_%d", index, index))
  GUIUtils.FillIcon(icon:GetComponent("UITexture"), iconId)
end
def.method().UpdateStaticInfo = function(self)
  local res = DeliveryGameUtils.GetActivityRes(self.activityId)
  local info1 = self.m_panel:FindDirect("Img_Bg0/Group_Title02/Label_Info02")
  info1:GetComponent("UILabel"):set_text(res.text[9])
  local info2 = self.m_panel:FindDirect("Img_Bg0/Group_Fresh/Group_ServerTime/Label_ServerName")
  info2:GetComponent("UILabel"):set_text(res.text[10])
  local info3 = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
  info3:GetComponent("UILabel"):set_text(res.text[11])
end
def.method().UpdateTimes = function(self)
  local numLbl = self.m_panel:FindDirect("Img_Bg0/Group_Fresh/Group_Time/Label_Times")
  numLbl:GetComponent("UILabel"):set_text(tostring(self.count))
end
def.method().UpdateItem = function(self)
  local icon = self.m_panel:FindDirect("Img_Bg0/Group_Trans/Img_Item/Icon_Item")
  local deliveryCfg = DeliveryGameUtils.GetDeliveryCfg(self.activityId)
  GUIUtils.FillIcon(icon:GetComponent("UITexture"), deliveryCfg.iconId)
  local numLbl = self.m_panel:FindDirect("Img_Bg0/Group_Trans/Img_Item/Label_Item")
  local deliveryInfo = require("Main.DeliveryGame.DeliveryGameModule").Instance():GetDeliveryState(self.activityId)
  if deliveryInfo and deliveryInfo.endTime > GetServerTime() then
    numLbl:GetComponent("UILabel"):set_text("1")
  else
    numLbl:GetComponent("UILabel"):set_text("0")
  end
end
def.method().UpdateRewards = function(self)
  local list = self.m_panel:FindDirect("Img_Bg0/Group_List")
  local listCmp = list:GetComponent("UIList")
  local stageCfg = DeliveryGameUtils.GetDeliverStageCfg(self.activityId)
  local stageInfo = require("Main.DeliveryGame.DeliveryGameModule").Instance():GetRewardState(self.activityId)
  local count = #stageCfg.stages
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local reached = stageCfg.stages[i].count <= self.count
    local fetched = stageInfo and stageInfo[i] or false
    self:FillItem(uiGo, reached, fetched, stageCfg.stages[i].count, stageCfg.stages[i].iconId, i)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Help" then
    local deliveryCfg = DeliveryGameUtils.GetDeliveryCfg(self.activityId)
    GUIUtils.ShowHoverTip(deliveryCfg.descId)
  elseif id == "Btn_Trans" then
    require("Main.DeliveryGame.DeliveryGameModule").Instance():ShowRelatedPlayer(self.activityId)
  elseif id == "Btn_Fresh" then
    require("Main.DeliveryGame.DeliveryGameModule").Instance():RequestServerDeliveryCount(self.activityId)
  elseif string.sub(id, 1, 8) == "Btn_Get_" then
    local index = tonumber(string.sub(id, 9))
    local stageCfg = DeliveryGameUtils.GetDeliverStageCfg(self.activityId)
    if self.count >= stageCfg.stages[index].count then
      require("Main.DeliveryGame.DeliveryGameModule").Instance():FetchTimesReward(self.activityId, index)
    else
      Toast(textRes.DeliveryGame[2])
    end
  end
end
DeliveryInfoPanel.Commit()
return DeliveryInfoPanel
