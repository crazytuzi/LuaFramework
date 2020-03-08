local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MondayFreePanel = Lplus.Extend(ECPanelBase, "MondayFreePanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local MondayFreeMgr = require("Main.Award.mgr.MondayFreeMgr")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = MondayFreePanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local instance
def.static("=>", MondayFreePanel).Instance = function()
  if instance == nil then
    instance = MondayFreePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_PRIZE_HAPPY_MONDAY, 0)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, MondayFreePanel.OnMondayFreeInfoChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, MondayFreePanel.OnMondayFreeInfoChange)
end
def.static("table", "table").OnMondayFreeInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setAwardInfo()
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setActivityInfo()
    self:setAwardInfo()
  else
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_SunDayRewardGet" then
    local p = require("netio.protocol.mzm.gsp.mondayfree.CGetSundayAwardReq").new()
    gmodule.network.sendProtocol(p)
  elseif id == "Btn_Mission01" then
    if MondayFreeMgr.Instance():isInTime(constant.CMondayFreeConsts.MondayTimeDurationCfgid) then
      local p = require("netio.protocol.mzm.gsp.mondayfree.CFinishShimenReq").new()
      gmodule.network.sendProtocol(p)
    else
      Toast(textRes.activity.MondayFree[8])
    end
  elseif id == "Btn_Mission02" then
    if MondayFreeMgr.Instance():isInTime(constant.CMondayFreeConsts.MondayTimeDurationCfgid) then
      local p = require("netio.protocol.mzm.gsp.mondayfree.CFinishBaotuReq").new()
      gmodule.network.sendProtocol(p)
    else
      Toast(textRes.activity.MondayFree[8])
    end
  elseif id == "Btn_MondayGiftGet" then
    local p = require("netio.protocol.mzm.gsp.mondayfree.CGetMondayAwardReq").new()
    gmodule.network.sendProtocol(p)
  elseif id == "Btn_SunDayRewardGetGary" then
    Toast(textRes.activity.MondayFree[7])
  elseif id == "Btn_Help" then
    require("GUI.GUIUtils").ShowHoverTip(constant.CMondayFreeConsts.Tips, 0, 0)
  elseif id == "Img_Gift" then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(constant.CMondayFreeConsts.MondayAwardDisplayItemid, obj, 0, false)
  elseif id == "Img_BgIcon" then
    local activityTip = require("Main.activity.ui.ActivityTip").Instance()
    local pName = obj.parent.name
    if pName == "Group_Mission01" then
      activityTip:SetActivityID(constant.ShimenActivityCfgConsts.SHIMEN_ACTIVITY_ID)
      activityTip:ShowDlg()
    elseif pName == "Group_Mission02" then
      activityTip:SetActivityID(constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID)
      activityTip:ShowDlg()
    end
  end
end
def.method().setActivityInfo = function(self)
  local shimenActivityId = constant.ShimenActivityCfgConsts.SHIMEN_ACTIVITY_ID
  local shimenActivityCfg = ActivityInterface.GetActivityCfgById(shimenActivityId)
  local Group_Mission01 = self.m_panel:FindDirect("Group_HappyMonday/Group_Mission01")
  local shimen_Img_Icon = Group_Mission01:FindDirect("Img_BgIcon")
  GUIUtils.FillIcon(shimen_Img_Icon:GetComponent("UITexture"), shimenActivityCfg.activityIcon)
  local shime_Label_Name = Group_Mission01:FindDirect("Label_Name")
  shime_Label_Name:GetComponent("UILabel"):set_text(shimenActivityCfg.activityName)
  local baotuActivityId = constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID
  local baotuActivityCfg = ActivityInterface.GetActivityCfgById(baotuActivityId)
  local Group_Mission02 = self.m_panel:FindDirect("Group_HappyMonday/Group_Mission02")
  local baotu_Img_Icon = Group_Mission02:FindDirect("Img_BgIcon")
  GUIUtils.FillIcon(baotu_Img_Icon:GetComponent("UITexture"), baotuActivityCfg.activityIcon)
  local baotu_Label_Name = Group_Mission02:FindDirect("Label_Name")
  baotu_Label_Name:GetComponent("UILabel"):set_text(baotuActivityCfg.activityName)
  local Group_MondayGift = self.m_panel:FindDirect("Group_HappyMonday/Group_MondayGift")
  local Img_Texture = Group_MondayGift:FindDirect("Img_Gift/Img_Texture")
  local awardItem = ItemUtils.GetItemBase(constant.CMondayFreeConsts.MondayAwardDisplayItemid)
  GUIUtils.FillIcon(Img_Texture:GetComponent("UITexture"), awardItem.icon)
  local Label_Name = Group_MondayGift:FindDirect("Label_Name")
  Label_Name:GetComponent("UILabel"):set_text(textRes.activity.MondayFree[4])
  local Label_MondayTips = self.m_panel:FindDirect("Group_HappyMonday/Label_MondayTips")
  Label_MondayTips:GetComponent("UILabel"):set_text(textRes.activity.MondayFree[3])
end
def.method().setAwardInfo = function(self)
  local mondayFreeMgr = MondayFreeMgr.Instance()
  local Group_HappyMonday = self.m_panel:FindDirect("Group_HappyMonday")
  local Btn_SunDayRewardGet = Group_HappyMonday:FindDirect("Group_SunDayReward/Btn_SunDayRewardGet")
  local Btn_SunDayRewardGetGary = Group_HappyMonday:FindDirect("Group_SunDayReward/Btn_SunDayRewardGetGary")
  local sunday_Img_Finish = Group_HappyMonday:FindDirect("Group_SunDayReward/Img_Finish")
  local sundayAward = mondayFreeMgr:canGetSundayAward()
  if mondayFreeMgr:isInTime(constant.CMondayFreeConsts.SundayTimeDurationCfgid) then
    Btn_SunDayRewardGetGary:SetActive(false)
    if sundayAward then
      Btn_SunDayRewardGet:SetActive(true)
      sunday_Img_Finish:SetActive(false)
    else
      Btn_SunDayRewardGet:SetActive(false)
      sunday_Img_Finish:SetActive(true)
    end
  else
    Btn_SunDayRewardGet:SetActive(false)
    sunday_Img_Finish:SetActive(false)
    Btn_SunDayRewardGetGary:SetActive(true)
    local Img_Red = Btn_SunDayRewardGetGary:FindDirect("Img_Red")
    Img_Red:SetActive(false)
  end
  local Img_Red = Btn_SunDayRewardGet:FindDirect("Img_Red")
  Img_Red:SetActive(sundayAward)
  local Btn_Mission01 = Group_HappyMonday:FindDirect("Group_Mission01/Btn_Mission01")
  local Img_Finish1 = Group_HappyMonday:FindDirect("Group_Mission01/Img_Finish")
  local Label_Mission01Tips = Group_HappyMonday:FindDirect("Group_Mission01/Label_Mission01Tips")
  local Btn_Mission02 = Group_HappyMonday:FindDirect("Group_Mission02/Btn_Mission02")
  local Img_Finish2 = Group_HappyMonday:FindDirect("Group_Mission02/Img_Finish")
  local Label_Mission02Tips = Group_HappyMonday:FindDirect("Group_Mission02/Label_Mission02Tips")
  local isMonday = mondayFreeMgr:isInTime(constant.CMondayFreeConsts.MondayTimeDurationCfgid)
  if isMonday then
    Label_Mission01Tips:SetActive(false)
    Label_Mission02Tips:SetActive(false)
    if mondayFreeMgr:isShowFinishShimen() then
      Btn_Mission01:SetActive(false)
      Img_Finish1:SetActive(true)
    else
      Btn_Mission01:SetActive(true)
      Img_Finish1:SetActive(false)
      Btn_Mission01:GetComponent("UIButton").isEnabled = mondayFreeMgr:canDoShimen()
    end
    if mondayFreeMgr:isShowFinsihBaotu() then
      Btn_Mission02:SetActive(false)
      Img_Finish2:SetActive(true)
    else
      Btn_Mission02:SetActive(true)
      Img_Finish2:SetActive(false)
      Btn_Mission02:GetComponent("UIButton").isEnabled = mondayFreeMgr:canDoBaotu()
    end
  else
    Label_Mission01Tips:SetActive(true)
    Label_Mission02Tips:SetActive(true)
    Btn_Mission01:SetActive(true)
    Img_Finish1:SetActive(false)
    Btn_Mission02:SetActive(true)
    Img_Finish2:SetActive(false)
  end
  local Top_Label = self.m_panel:FindDirect("Group_HappyMonday/Group_TopTalk/Label")
  local Bottom_Label = self.m_panel:FindDirect("Group_HappyMonday/Group_BottomTalk/Label")
  if isMonday then
    Top_Label:GetComponent("UILabel"):set_text(textRes.activity.MondayFree[5])
    Bottom_Label:GetComponent("UILabel"):set_text(textRes.activity.MondayFree[6])
  else
    Top_Label:GetComponent("UILabel"):set_text(textRes.activity.MondayFree[1])
    Bottom_Label:GetComponent("UILabel"):set_text(textRes.activity.MondayFree[2])
  end
  local Btn_MondayGiftGet = Group_HappyMonday:FindDirect("Group_MondayGift/Btn_MondayGiftGet")
  local Monday_Img_Finish = Group_HappyMonday:FindDirect("Group_MondayGift/Img_Finish")
  local Label_MondayGiftTips = Group_HappyMonday:FindDirect("Group_MondayGift/Label_MondayGiftTips")
  local mondayAward = mondayFreeMgr:canGetMondayAward()
  if isMonday then
    Label_MondayGiftTips:SetActive(false)
    if mondayAward then
      Btn_MondayGiftGet:SetActive(true)
      Monday_Img_Finish:SetActive(false)
    else
      Btn_MondayGiftGet:SetActive(false)
      Monday_Img_Finish:SetActive(true)
    end
  else
    Btn_MondayGiftGet:SetActive(false)
    Monday_Img_Finish:SetActive(false)
    Label_MondayGiftTips:SetActive(true)
  end
end
return MondayFreePanel.Commit()
