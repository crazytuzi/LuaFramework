local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local HeroReturnNode = Lplus.Extend(AwardPanelNodeBase, "HeroReturnNode")
local HeroReturnMgr = require("Main.Award.mgr.HeroReturnMgr")
local Vector = require("Types.Vector")
local def = HeroReturnNode.define
local dlg
def.field("number").timerId = 0
def.override().InitUI = function(self)
  AwardPanelNodeBase.InitUI(self)
end
def.override().OnShow = function(self)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  dlg = AwardPanel.Instance().nodes[AwardPanel.NodeId.HeroReturn]
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.HERO_RETURN_AWARD_UPDATE, HeroReturnNode.OnAwardUpdate)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.backgame.CGetBackScoreAwardInfo").new())
  HeroReturnNode.OnAwardUpdate(nil, nil)
  if dlg.timerId <= 0 then
    dlg.timerId = GameUtil.AddGlobalTimer(1, false, HeroReturnNode.UpdateTime)
  end
  HeroReturnNode.UpdateTime()
end
def.override().OnHide = function(self)
  if dlg and dlg.timerId > 0 then
    GameUtil.RemoveGlobalTimer(dlg.timerId)
    dlg.timerId = 0
  end
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.HERO_RETURN_AWARD_UPDATE, HeroReturnNode.OnAwardUpdate)
  dlg = nil
end
def.static("=>", "table").GetDlg = function(self)
  return dlg
end
def.override("=>", "boolean").IsOpen = function(self)
  return HeroReturnMgr.Instance().returnGameInfo ~= nil
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return HeroReturnMgr.Instance():IsHaveNotifyMessage()
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  local tipId
  if id == "Btn_TakePrize" then
    local mgr = HeroReturnMgr.Instance()
    local data = mgr.returnGameInfo
    if data == nil then
      return
    end
    local index_cfg = mgr:GetIndexCfg(data.indexId)
    if data.currentPoint < index_cfg.point then
      Toast(textRes.activity[193])
    else
      local p = require("netio.protocol.mzm.gsp.backgame.CGetBackScoreAward").new()
      gmodule.network.sendProtocol(p)
    end
  elseif id == "Btn_LevelUp" then
    require("Main.Award.ui.AwardPanel").Instance():DestroyPanel()
    local ActivityMain = require("Main.activity.ui.ActivityMain")
    ActivityMain.Instance():ShowDlgToProductType(ActivityMain.ActivityType.DAILY, ActivityMain.ProductType.EXP)
  elseif id == "Btn_GetXY" then
    require("Main.Award.ui.AwardPanel").Instance():DestroyPanel()
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_ACTIVITY_CLICK, nil)
  elseif id == "Btn_JoinActivity" then
    local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    if _G.IsFeatureOpen(Feature.TYPE_ACTIVITY_COMPENSATE) then
      local awardPanel = require("Main.Award.ui.AwardPanel").Instance()
      awardPanel:SwitchToNode(awardPanel:GetTabNodeId("Tab_ActivityGetBack"))
    end
  elseif id == "Btn_ServiceXianyuan" then
    tipId = 701609902
  elseif id == "Btn_ServiceAdd" then
    tipId = 701609901
  elseif id == "Btn_ExpStorage" then
    tipId = 701609900
  elseif id == "Btn_Tips" then
    tipId = 701609903
  end
  if tipId and tipId > 0 then
    local CommonDescDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
    CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
  end
end
def.static("table", "table").OnAwardUpdate = function(p1, p2)
  if dlg == nil then
    return
  end
  local mgr = HeroReturnMgr.Instance()
  local data = mgr.returnGameInfo
  if data == nil then
    return
  end
  local btn = dlg.m_node:FindDirect("Btn_TakePrize")
  local getxy = dlg.m_node:FindDirect("Btn_GetXY")
  local index_cfg = mgr:GetIndexCfg(data.indexId)
  if index_cfg == nil then
    return
  end
  local GUIUtils = require("GUI.GUIUtils")
  if data.indexId == data.claimedIdx then
    btn:FindDirect("Label"):GetComponent("UILabel").text = textRes.activity[192]
    btn:GetComponent("UIButton"):set_isEnabled(false)
    btn:SetActive(true)
    getxy:SetActive(false)
    GUIUtils.RemoveLightEffectAtPanel("panel_prize/Img_Bg0/Group_HeroBack/Btn_TakePrize")
  else
    btn:GetComponent("UIButton"):set_isEnabled(true)
    btn:FindDirect("Label"):GetComponent("UILabel").text = textRes.activity[191]
    btn:SetActive(data.currentPoint >= index_cfg.point)
    getxy:SetActive(data.currentPoint < index_cfg.point)
    if data.currentPoint >= index_cfg.point then
      GUIUtils.AddLightEffectToPanel("panel_prize/Img_Bg0/Group_HeroBack/Btn_TakePrize", GUIUtils.Light.Square)
    else
      GUIUtils.RemoveLightEffectAtPanel("panel_prize/Img_Bg0/Group_HeroBack/Btn_TakePrize")
    end
  end
  dlg.m_node:FindDirect("Label_XianyuanNumber"):GetComponent("UILabel").text = tostring(data.currentPoint)
  dlg.m_node:FindDirect("Label_LeastNumber"):GetComponent("UILabel").text = tostring(index_cfg.point)
  dlg:SetAwardValue()
end
def.static().UpdateTime = function()
  if dlg == nil or HeroReturnMgr.Instance().returnGameInfo == nil then
    return
  end
  local endtime = HeroReturnMgr.Instance().returnGameInfo.endTime
  local curtime = _G.GetServerTime()
  endtime = endtime:ToNumber()
  if curtime > endtime + 0.99 then
    if dlg.timerId > 0 then
      GameUtil.RemoveGlobalTimer(dlg.timerId)
    end
    dlg.timerId = 0
    HeroReturnMgr.Instance().returnGameInfo = nil
    dlg:Hide()
    local AwardPanel = require("Main.Award.ui.AwardPanel")
    AwardPanel.Instance():ArrangeTabPos()
    return
  end
  local lefttime = endtime - curtime
  if lefttime < 0 then
    lefttime = 0
  end
  local t = Seconds2HMSTime(lefttime)
  dlg.m_node:FindDirect("Label_Count/Label_Time"):GetComponent("UILabel").text = string.format("%d:%02d:%02d", t.h, t.m, t.s)
end
def.method().SetAwardValue = function(self)
  if dlg and dlg.m_node and HeroReturnMgr.Instance().returnGameInfo then
    local money = HeroReturnMgr.Instance().returnGameInfo.awardMoney
    dlg.m_node:FindDirect("Label_SiliverNumber"):GetComponent("UILabel").text = money and money:tostring() or ""
    dlg.m_node:FindDirect("Label_ExpNumber"):GetComponent("UILabel").text = tostring(HeroReturnMgr.Instance().returnGameInfo.awardExp)
  end
end
HeroReturnNode.Commit()
return HeroReturnNode
