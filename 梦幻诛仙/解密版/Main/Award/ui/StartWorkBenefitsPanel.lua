local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local StartWorkBenefitsPanel = Lplus.Extend(ECPanelBase, "StartWorkBenefitsPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = StartWorkBenefitsPanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local instance
def.static("=>", StartWorkBenefitsPanel).Instance = function()
  if instance == nil then
    instance = StartWorkBenefitsPanel()
  end
  return instance
end
def.field("table").infos = nil
def.field("number").curIndex = 0
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.curIndex = 0
  self.infos = require("Main.CustomActivity.CustomActivityInterface").Instance():GetStartWorkBenefitsInfo()
  if self.infos == nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_AWARD_STARTWORK_PANEL, 0)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, StartWorkBenefitsPanel.NeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, StartWorkBenefitsPanel.NeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, StartWorkBenefitsPanel.NeedUpdate, self)
  self:UpdateUI()
end
def.method("table").NeedUpdate = function(self, params)
  if self:IsShow() then
    self.infos = require("Main.CustomActivity.CustomActivityInterface").Instance():GetStartWorkBenefitsInfo()
    self.curIndex = 0
    self:UpdateUI()
  end
end
def.method().UpdateUI = function(self)
  local curActive = require("Main.activity.ActivityInterface").Instance():GetCurActive()
  local serverTime = GetServerTime()
  local timeTbl = require("Main.Common.AbsoluteTimer").GetServerTimeTable(serverTime)
  local weekDay = timeTbl.wday
  local root = self.m_panel:FindDirect("Group_StartWork/Group_Item")
  local childCount = root:get_childCount()
  for i = 1, childCount do
    local uiGo = root:FindDirect("Img_Item" .. i)
    if uiGo then
      local weekDayLbl = uiGo:FindDirect("Label_Time")
      local detailLbl = uiGo:FindDirect("Label_Number")
      local icon = uiGo:FindDirect("Img_Bag_" .. i)
      local light = uiGo:FindDirect("Img_Light")
      local info = self.infos[i]
      if info then
        uiGo:SetActive(true)
        weekDayLbl:GetComponent("UILabel"):set_text(textRes.activity[info.weekday] or "")
        local tex = icon:GetComponent("UITexture")
        if info.weekday == weekDay then
          self.curIndex = i
          if info.times > 0 then
            if curActive >= info.minActiveValue then
              light:GetComponent("TweenRotation"):set_enabled(true)
              GUIUtils.FillIcon(tex, info.icon2)
              GUIUtils.SetTextureEffect(tex, GUIUtils.Effect.Normal)
            else
              light:GetComponent("TweenRotation"):set_enabled(false)
              GUIUtils.FillIcon(tex, info.icon1)
              GUIUtils.SetTextureEffect(tex, GUIUtils.Effect.Normal)
            end
          else
            light:GetComponent("TweenRotation"):set_enabled(false)
            GUIUtils.FillIcon(tex, info.icon3)
            GUIUtils.SetTextureEffect(tex, GUIUtils.Effect.Normal)
          end
        elseif self.curIndex ~= 0 then
          light:GetComponent("TweenRotation"):set_enabled(false)
          GUIUtils.FillIcon(tex, info.icon1)
          GUIUtils.SetTextureEffect(tex, GUIUtils.Effect.Normal)
        elseif info.times > 0 then
          light:GetComponent("TweenRotation"):set_enabled(false)
          GUIUtils.FillIcon(tex, info.icon1)
          GUIUtils.SetTextureEffect(tex, GUIUtils.Effect.Gray)
        else
          light:GetComponent("TweenRotation"):set_enabled(false)
          GUIUtils.FillIcon(tex, info.icon3)
          GUIUtils.SetTextureEffect(tex, GUIUtils.Effect.Gray)
        end
        detailLbl:GetComponent("UILabel"):set_text(info.desc)
      else
        uiGo:SetActive(false)
      end
    end
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, StartWorkBenefitsPanel.NeedUpdate)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, StartWorkBenefitsPanel.NeedUpdate)
  Event.UnregisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, StartWorkBenefitsPanel.NeedUpdate)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.sub(id, 1, 8) == "Img_Bag_" then
    local index = tonumber(string.sub(id, 9))
    self:GetStartWorkBenefits(index)
  end
end
def.method("number").GetStartWorkBenefits = function(self, index)
  local info = self.infos[index]
  if info then
    if info.times > 0 then
      local curActive = require("Main.activity.ActivityInterface").Instance():GetCurActive()
      local serverTime = GetServerTime()
      local timeTbl = require("Main.Common.AbsoluteTimer").GetServerTimeTable(serverTime)
      local weekDay = timeTbl.wday
      if weekDay ~= info.weekday then
        if self.curIndex == 0 then
          Toast(textRes.activity[393])
        elseif index > self.curIndex then
          Toast(string.format(textRes.activity[391], textRes.activity[info.weekday]))
        elseif index < self.curIndex then
          Toast(textRes.activity[394])
        end
        return
      end
      if curActive < info.minActiveValue then
        Toast(string.format(textRes.activity[390], info.minActiveValue))
        return
      end
      require("Main.CustomActivity.CustomActivityInterface").Instance():GetStartWorkBenefitsGift(info.id)
    else
      Toast(textRes.activity[392])
    end
  end
end
return StartWorkBenefitsPanel.Commit()
