local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local LimitActivityTip = Lplus.Extend(ECPanelBase, "LimitActivityTip")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = LimitActivityTip.define
local instance, isSetModal
def.field("number")._activityId = 0
def.field("number")._timerId = 0
def.static("=>", LimitActivityTip).Instance = function()
  instance = LimitActivityTip()
  instance:Init()
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("number").ShowDlg = function(self, activityId)
  self._activityId = activityId
  if self:IsShow() == false then
    self:CreatePanel(RESPATH.PREFAB_UI_LIMIT_ACTIVITY_TIP, _G.GUILEVEL.NORMAL)
    if isSetModal then
      self:SetModal(false)
    else
      isSetModal = true
      self:SetModal(true)
    end
  end
end
def.method("number").setActivityInfo = function(self, activityId)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if activityCfg then
    local timeLimitTipCfg = ActivityInterface.GetTimeLimitTipCfg(activityCfg.panelCfgid)
    local img_bg = self.m_panel:FindDirect("Img_0")
    local label_title = img_bg:FindDirect("Label_Title")
    label_title:GetComponent("UILabel"):set_text(activityCfg.activityName)
    if timeLimitTipCfg then
      local label_content = img_bg:FindDirect("Img_BgWords/Label")
      label_content:GetComponent("UILabel"):set_text(timeLimitTipCfg.description)
      local group_item = img_bg:FindDirect("Group_Items")
      local awardItems = timeLimitTipCfg.awardItemIds
      if #awardItems > 0 then
        local ItemUtils = require("Main.Item.ItemUtils")
        group_item:SetActive(true)
        for i = 1, 3 do
          local id = awardItems[i]
          local item_bg = group_item:FindDirect(string.format("Item_%03d", i))
          if id and id > 0 then
            item_bg:SetActive(true)
            local itemBaseCfg = ItemUtils.GetItemBase(id)
            local img_icon = item_bg:FindDirect("Img_Icon")
            local icon_texture = img_icon:GetComponent("UITexture")
            GUIUtils.FillIcon(icon_texture, itemBaseCfg.icon)
          else
            item_bg:SetActive(false)
          end
        end
      else
        group_item:SetActive(false)
      end
    else
      self:HideDlg()
    end
  else
    self:HideDlg()
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self._activityId = 0
    isSetModal = nil
    if self._timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self._timerId)
    end
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  local strs = string.split(id, "_")
  if strs[1] == "Btn" and strs[2] == "Cancel" then
    self:HideDlg()
  elseif strs[1] == "Btn" and strs[2] == "Confirm" then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
      self._activityId
    })
    self:HideDlg()
  elseif strs[1] == "Item" then
    local idx = tonumber(strs[2])
    local activityCfg = ActivityInterface.GetActivityCfgById(self._activityId)
    local timeLimitTipCfg = ActivityInterface.GetTimeLimitTipCfg(activityCfg.panelCfgid)
    local awardItems = timeLimitTipCfg.awardItemIds
    if awardItems[idx] and awardItems[idx] ~= 0 then
      local img_bg = self.m_panel:FindDirect("Img_0/Group_Items/Item_" .. strs[2] .. "/Img_Bg")
      local sprite = img_bg:GetComponent("UISprite")
      local position = img_bg:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      ItemTipsMgr.Instance():ShowBasicTips(awardItems[idx], screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
    end
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setActivityInfo(self._activityId)
    GameUtil.AddGlobalTimer(30, true, function()
      self._timerId = 0
      self:HideDlg()
    end)
  end
end
LimitActivityTip.Commit()
return LimitActivityTip
