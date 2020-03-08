local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MedalPanel = Lplus.Extend(ECPanelBase, "MedalPanel")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local MedalMgr = require("Main.activity.Medal.MedalMgr")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ExploitConsts = require("netio.protocol.mzm.gsp.exploit.ExploitConsts")
local medalMgr = MedalMgr.Instance()
local def = MedalPanel.define
local instance
def.field("table").activityList = nil
def.const("number").MEDAL_ITEM_ID = 210101409
def.static("=>", MedalPanel).Instance = function()
  if instance == nil then
    instance = MedalPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PERFAB_Panel_ACTIVITY_HONOR, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Info_Change, MedalPanel.OnMedalInfoChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Award_Change, MedalPanel.OnMedalAwardChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Info_Change, MedalPanel.OnMedalInfoChange)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Award_Change, MedalPanel.OnMedalAwardChange)
end
def.static("table", "table").OnMedalInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setActivityList()
  end
end
def.static("table", "table").OnMedalAwardChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setAwardInfo()
  end
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setActivityList()
    self:setAwardInfo()
  else
    self.activityList = nil
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Help" then
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(constant.CExploitConst.EXPLOIT_ACTIVITY_TIPS_CFG_ID)
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
  elseif strs[1] == "Btn" and strs[2] == "Get" then
    local idx = tonumber(strs[3])
    if idx then
      local cfg = self.activityList[idx]
      if cfg then
        if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EXPLOIT) then
          Toast(textRes.activity[407])
          return
        end
        local req = require("netio.protocol.mzm.gsp.exploit.CGetTargetAwardReq").new(constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID, cfg.targetActivityCfgid)
        gmodule.network.sendProtocol(req)
        warn("---------CGetTargetAwardReq:", cfg.targetActivityCfgid)
      else
        warn("!!!!!! error idx:", idx)
      end
    end
  elseif strs[1] == "Btn" and strs[2] == "UnFinish" then
    local idx = tonumber(strs[3])
    if idx then
      local cfg = self.activityList[idx]
      if cfg then
        local activityId = cfg.targetActivityCfgid
        local activityInterface = ActivityInterface.Instance()
        if activityInterface:isAchieveActivityLevel(activityId) and activityInterface:isActivityOpend2(activityId) then
          self:Hide()
          Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {activityId})
        else
          Toast(textRes.activity[270])
        end
      end
    end
  elseif strs[1] == "Img" and strs[2] == "Piece" then
    local idx = tonumber(strs[3])
    if idx then
      local cfg = self.activityList[idx]
      if cfg then
        local position = clickObj:get_position()
        local screenPos = WorldPosToScreen(position.x, position.y)
        local widget = clickObj:GetComponent("UIWidget")
        ItemTipsMgr.Instance():ShowBasicTips(MedalPanel.MEDAL_ITEM_ID, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, false)
      end
    end
  elseif strs[1] == "Item" then
    local idx = tonumber(strs[2])
    if idx then
      local finishNum = medalMgr:getFinishNum()
      local state = medalMgr:getMedalAwardState(idx)
      if idx <= finishNum and state ~= ExploitConsts.ST_HAND_UP then
        if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EXPLOIT) then
          Toast(textRes.activity[407])
          return
        end
        local req = require("netio.protocol.mzm.gsp.exploit.CGetStageAwardReq").new(constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID, idx)
        gmodule.network.sendProtocol(req)
        warn("----------CGetStageAwardReq:", idx)
      else
        local stageAwardCfg = MedalMgr.GetMedalAwardCfgByStage(idx)
        if stageAwardCfg then
          local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(stageAwardCfg.awardCfgid)
          local itemInfo = awardCfg.itemList[1]
          if itemInfo then
            local position = clickObj:get_position()
            local screenPos = WorldPosToScreen(position.x, position.y)
            local widget = clickObj:GetComponent("UIWidget")
            ItemTipsMgr.Instance():ShowBasicTips(itemInfo.itemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, false)
          end
        end
      end
    end
  end
end
def.method("=>", "table").getSortActivityList = function(self)
  local activityList = MedalMgr.GetAllMedalCfgList()
  local activityInterface = ActivityInterface.Instance()
  local function comp(cfg1, cfg2)
    local medalInfo1 = medalMgr:getMedalActivityInfo(cfg1.targetActivityCfgid)
    local medalInfo2 = medalMgr:getMedalActivityInfo(cfg2.targetActivityCfgid)
    if medalInfo1.target_state == ExploitConsts.ST_HAND_UP or medalInfo2.target_state == ExploitConsts.ST_HAND_UP then
      if medalInfo1.target_state == ExploitConsts.ST_HAND_UP and medalInfo2.target_state == ExploitConsts.ST_HAND_UP then
        return cfg1.id < cfg2.id
      end
      if medalInfo1.target_state == ExploitConsts.ST_HAND_UP then
        return false
      else
        return true
      end
    end
    local count1 = medalInfo1.target_param
    local count2 = medalInfo2.target_param
    if count1 >= cfg1.needNum and count2 >= cfg2.needNum then
      return cfg1.id < cfg2.id
    else
      if count1 >= cfg1.needNum then
        return true
      end
      if count2 >= cfg2.needNum then
        return false
      end
      if medalInfo1.target_param > 0 and medalInfo2.target_param > 0 then
        return cfg1.id < cfg2.id
      else
        if medalInfo1.target_param > 0 then
          return true
        end
        if medalInfo2.target_param > 0 then
          return false
        end
      end
      return cfg1.id < cfg2.id
    end
  end
  table.sort(activityList, comp)
  return activityList
end
def.method().setActivityList = function(self)
  local activityList = self:getSortActivityList()
  self.activityList = activityList
  local List = self.m_panel:FindDirect("Img_Bg0/Img_BgList/Scroll View/List")
  local uiList = List:GetComponent("UIList")
  uiList.columns = #activityList
  uiList.itemCount = #activityList
  uiList:Resize()
  for i, v in ipairs(activityList) do
    local Img_BgChar = List:FindDirect("Img_BgChar_" .. i)
    local Slider = Img_BgChar:FindDirect("Slider_" .. i)
    local Slider_Num = Slider:FindDirect("Label_Num_" .. i)
    local Img_Acitivity = Img_BgChar:FindDirect("Img_Acitivity_" .. i)
    local Img_Piece = Img_BgChar:FindDirect(string.format("Img_Piece_%d/Img_Piece_%d", i, i))
    local Label_Num = Img_BgChar:FindDirect(string.format("Img_Piece_%d/Label_Num_%d", i, i))
    local Label_Title = Img_BgChar:FindDirect(string.format("Img_Cover_%d/Label_Title_%d", i, i))
    local Btn_Get = Img_BgChar:FindDirect(string.format("Group_Btn_%d/Btn_Get_%d", i, i))
    local Btn_UnFinish = Img_BgChar:FindDirect(string.format("Group_Btn_%d/Btn_UnFinish_%d", i, i))
    local Btn_Geted = Img_BgChar:FindDirect(string.format("Group_Btn_%d/Btn_Geted_%d", i, i))
    local targetActivityId = v.targetActivityCfgid
    local activityCfg = ActivityInterface.GetActivityCfgById(targetActivityId)
    Label_Title:GetComponent("UILabel"):set_text(activityCfg.activityName)
    local activity_texture = Img_Acitivity:GetComponent("UITexture")
    GUIUtils.FillIcon(activity_texture, activityCfg.activityIcon)
    local medalInfo = medalMgr:getMedalActivityInfo(targetActivityId)
    local count = medalInfo.target_param
    local uiSlider = Slider:GetComponent("UISlider")
    uiSlider.value = count / v.needNum
    Slider_Num:GetComponent("UILabel"):set_text(count .. "/" .. v.needNum)
    local btnGet = Btn_Get:GetComponent("UIButton")
    local Btn_Name = Btn_Get:FindDirect("Label_Name_" .. i)
    if medalInfo.target_state == ExploitConsts.ST_HAND_UP then
      Btn_UnFinish:SetActive(false)
      Btn_Get:SetActive(false)
      Btn_Geted:SetActive(true)
      GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
    else
      Btn_Geted:SetActive(false)
      if count >= v.needNum then
        Btn_Get:SetActive(true)
        Btn_UnFinish:SetActive(false)
        btnGet.isEnabled = true
        GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.Square)
      else
        Btn_Get:SetActive(false)
        Btn_UnFinish:SetActive(true)
        GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
      end
    end
    local Piece_texture = Img_Piece:GetComponent("UITexture")
    GUIUtils.FillIcon(Piece_texture, v.rewardIcon)
    Label_Num:GetComponent("UILabel"):set_text("")
  end
end
def.method().setAwardInfo = function(self)
  local Group_Slider = self.m_panel:FindDirect("Img_Bg0/Group_Slider")
  local Img_BgSlider = Group_Slider:FindDirect("Img_BgSlider")
  local awardInfo = medalMgr:getMedalAwardInfo()
  local finishNum = medalMgr:getFinishNum()
  local allNum = constant.CExploitConst.EXPLOIT_ACTIVITY_MAX_STAGE
  local uiProgress = Img_BgSlider:GetComponent("UIProgressBar")
  uiProgress.value = finishNum / allNum
  local Group_Items = Group_Slider:FindDirect("Group_Items")
  for i = 1, allNum do
    local Item = Group_Items:FindDirect("Item_" .. i)
    local Img_Icon = Item:FindDirect("Img_Icon")
    local icon_texture = Img_Icon:GetComponent("UITexture")
    local state = medalMgr:getMedalAwardState(i)
    if state ~= ExploitConsts.ST_HAND_UP then
      GUIUtils.SetTextureEffect(icon_texture, GUIUtils.Effect.Normal)
      if i <= finishNum then
        GUIUtils.SetLightEffect(Item, GUIUtils.Light.Round)
      else
        GUIUtils.SetLightEffect(Item, GUIUtils.Light.None)
      end
    else
      GUIUtils.SetLightEffect(Item, GUIUtils.Light.None)
      GUIUtils.SetTextureEffect(icon_texture, GUIUtils.Effect.Gray)
    end
  end
end
return MedalPanel.Commit()
