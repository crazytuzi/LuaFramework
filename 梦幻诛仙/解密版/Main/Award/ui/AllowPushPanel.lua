local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AllowPushPanel = Lplus.Extend(ECPanelBase, "AllowPushPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = AllowPushPanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local instance
def.static("=>", AllowPushPanel).Instance = function()
  if instance == nil then
    instance = AllowPushPanel()
  end
  return instance
end
def.field("boolean").checkState = false
def.field("table").items = nil
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_AWARD_ALLOWPUSH_PANEL, 0)
end
def.override().OnCreate = function(self)
  self.checkState = false
  Event.RegisterEventWithContext(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, AllowPushPanel.NeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, AllowPushPanel.NeedUpdate2, self)
  self.items = nil
  self:UpdateStaticUI()
  self:UpdateDynamicUI()
  require("Main.CustomActivity.CustomActivityInterface").Instance():RemoveRed()
end
def.method("table").NeedUpdate = function(self, params)
  if params.activityId == constant.PushAwardConst.activityid and self:IsShow() then
    self:UpdateDynamicUI()
  end
end
def.method("table").NeedUpdate2 = function(self, params)
  local activityId = params.activityId
  if activityId == constant.PushAwardConst.activityid then
    GameUtil.AddGlobalTimer(0.01, true, function()
      if self:IsShow() then
        self:UpdateDynamicUI()
      end
    end)
  end
end
def.method().UpdateStaticUI = function(self)
  local introLabel = self.m_panel:FindDirect("Group_TuiSongPrize/Group_Top/Img_Chat/Label")
  local tipLabel = self.m_panel:FindDirect("Group_TuiSongPrize/Label_Tip")
  introLabel:GetComponent("UILabel"):set_text(textRes.Award[79])
  tipLabel:GetComponent("UILabel"):set_text(textRes.Award[80])
  local listUI = self.m_panel:FindDirect("Group_TuiSongPrize/Bg_Items/List_Items")
  local awardId = require("Main.CustomActivity.CustomActivityInterface").Instance():GetAllowPushAwardInfo()
  if awardId > 0 then
    local awardInfo = ItemUtils.GetGiftAwardCfgByAwardId(awardId)
    local itemNum = awardInfo and #awardInfo.itemList or 0
    if itemNum > 0 then
      self.items = awardInfo.itemList
      listUI:SetActive(true)
      local listCmp = listUI:GetComponent("UIList")
      listCmp:set_itemCount(itemNum)
      listCmp:Resize()
      local items = listCmp:get_children()
      for i = 1, #items do
        local uiGo = items[i]
        self:FillIcon(uiGo, awardInfo.itemList[i].itemId, awardInfo.itemList[i].num, i)
        self.m_msgHandler:Touch(uiGo)
      end
    else
      listUI:SetActive(false)
    end
  else
    listUI:SetActive(false)
  end
end
def.method("userdata", "number", "number", "number").FillIcon = function(self, ui, itemId, num, index)
  local Texture_Icon = ui:FindDirect("Texture_Icon")
  local Label_Num = ui:FindDirect("Label_Num")
  local Label_Name2 = ui:FindDirect("Label_Name2")
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase then
    ui:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
    GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), itemBase.icon)
    Label_Num:GetComponent("UILabel"):set_text(tostring(num))
    Label_Name2:GetComponent("UILabel"):set_text(itemBase.name)
  end
end
def.method().UpdateDynamicUI = function(self)
  local btnLabel = self.m_panel:FindDirect("Group_TuiSongPrize/Btn_Agree/Label")
  if require("Main.CustomActivity.CustomActivityInterface").Instance():IsAllowPushHasThing() then
    if self.checkState then
      btnLabel:GetComponent("UILabel"):set_text(textRes.Award[82])
    else
      btnLabel:GetComponent("UILabel"):set_text(textRes.Award[81])
    end
  else
    btnLabel:GetComponent("UILabel"):set_text(textRes.Award[83])
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, AllowPushPanel.NeedUpdate)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Agree" then
    if require("Main.CustomActivity.CustomActivityInterface").Instance():IsAllowPushHasThing() then
      if self.checkState then
        self:RequestAward()
      else
        self:CheckAllowPush()
      end
    else
      Toast(textRes.Award[86])
    end
  elseif string.sub(id, 1, 5) == "item_" then
    local index = tonumber(string.sub(id, 6))
    if self.items and self.items[index] then
      local info = self.items[index]
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(info.itemId, obj, 0, false)
    end
  end
end
def.method().CheckAllowPush = function(self)
  if not self.checkState then
    if ZLUtil and ZLUtil.isPushNotificationEnabled then
      self.checkState = ZLUtil.isPushNotificationEnabled()
      if self.checkState then
        Toast(textRes.Award[85])
      else
        Toast(textRes.Award[84])
      end
    else
      Toast(textRes.Award[88])
    end
    self:UpdateDynamicUI()
  end
end
def.method().RequestAward = function(self)
  require("Main.CustomActivity.CustomActivityInterface").Instance():RequestAllowPush()
end
return AllowPushPanel.Commit()
