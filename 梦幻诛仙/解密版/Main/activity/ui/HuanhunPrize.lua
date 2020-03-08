local Lplus = require("Lplus")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local HuanhunPrize = Lplus.Extend(ECPanelBase, "HuanhunPrize")
local def = HuanhunPrize.define
local inst
local Vector = require("Types.Vector")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemTips = require("Main.Item.ui.ItemTips")
def.field("boolean").isshowing = false
def.static("=>", HuanhunPrize).Instance = function()
  if inst == nil then
    inst = HuanhunPrize()
    inst:Init()
  end
  return inst
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_HUANHUN_PRIZE, 2)
    self:SetOutTouchDisappear()
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Get" then
    HuanhunPrize.OnBtn_Get(self)
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
  self.isshowing = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
  else
    self.isshowing = false
  end
end
def.method().Fill = function(self)
  local ItemUtils = require("Main.Item.ItemUtils")
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local Img_BgPrize = self.m_panel:FindDirect("Img_BgPrize")
  local Texture_Prize = Img_BgPrize:FindDirect("Texture_Prize")
  local itemBase = ItemUtils.GetItemBase(constant.HuanHunMiShuConsts.HUANHUN_AWARD_ITEM_ID)
  local uiTexture = Texture_Prize:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local Label_PrizeNum = Img_BgPrize:FindDirect("Label_PrizeNum")
  Label_PrizeNum:GetComponent("UILabel"):set_text(tostring(constant.HuanHunMiShuConsts.HUANHUN_AWARD_ITEM_NUM))
end
def.static(HuanhunPrize).OnBtn_Get = function(self)
  local self = inst
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  local SSynHuanhuiInfo = require("netio.protocol.mzm.gsp.huanhun.SSynHuanhuiInfo")
  if activityInterface._huanhunStatus == SSynHuanhuiInfo.ST_HUN__HAND_UP then
    Toast(textRes.activity[205])
    return
  end
  local p = require("netio.protocol.mzm.gsp.huanhun.CGetHuanhunAwardReq").new()
  gmodule.network.sendProtocol(p)
  self:HideDlg()
end
HuanhunPrize.Commit()
return HuanhunPrize
