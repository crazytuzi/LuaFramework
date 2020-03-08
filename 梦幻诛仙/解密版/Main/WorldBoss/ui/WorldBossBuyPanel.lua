local EC = require("Types.Vector3")
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local WorldBossMgr = require("Main.WorldBoss.WorldBossMgr")
local WorldBossBuyPanel = Lplus.Extend(ECPanelBase, "WorldBossBuyPanel")
local def = WorldBossBuyPanel.define
def.field("table").uiNodes = nil
local instance
def.static("=>", WorldBossBuyPanel).Instance = function()
  if instance == nil then
    instance = WorldBossBuyPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:UpdateUI()
  else
    self:CreatePanel(RESPATH.PREFAB_WORLDBOSS_BUY_PANEL, 2)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, WorldBossBuyPanel.OnWalletChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, WorldBossBuyPanel.OnWalletChanged)
  Event.RegisterEvent(ModuleId.WORLDBOSS, gmodule.notifyId.WorldBoss.CHALLENGE_COUNT_BOUGHT, WorldBossBuyPanel.OnBuyChallengeCount)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    return
  end
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, WorldBossBuyPanel.OnWalletChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, WorldBossBuyPanel.OnWalletChanged)
  Event.UnregisterEvent(ModuleId.WORLDBOSS, gmodule.notifyId.WorldBoss.CHALLENGE_COUNT_BOUGHT, WorldBossBuyPanel.OnBuyChallengeCount)
  self:ClearUp()
end
def.method().ClearUp = function(self)
end
def.method().InitUI = function(self)
  self.uiNodes = {}
  self.uiNodes.imgBg = self.m_panel:FindDirect("Img _Bg0")
  self.uiNodes.lblCost = self.uiNodes.imgBg:FindDirect("Label_Cost/Img_Bg/Label_Num")
  self.uiNodes.lblOwn = self.uiNodes.imgBg:FindDirect("Label_Own/Img_Bg/Label_Num")
  self.uiNodes.lblBuyTimes = self.uiNodes.imgBg:FindDirect("Label_BuyNum")
end
def.method().UpdateUI = function(self)
  self:UpdateCost()
  self:UpdateOwn()
  self:UpdateBuyTimes()
end
def.method().UpdateCost = function(self)
  local uiLabelCost = self.uiNodes.lblCost:GetComponent("UILabel")
  local cost = WorldBossMgr.Instance():GetCost()
  uiLabelCost.text = cost
end
def.method().UpdateOwn = function(self)
  local uiLabelOwn = self.uiNodes.lblOwn:GetComponent("UILabel")
  local yuanbaoInWallet = Int64.ToNumber(ItemModule.Instance():GetAllYuanBao())
  uiLabelOwn.text = yuanbaoInWallet
end
def.method().UpdateBuyTimes = function(self)
  local uiLabelBuyTimes = self.uiNodes.lblBuyTimes:GetComponent("UILabel")
  local totalBuyCount = WorldBossMgr.Instance():GetTotalBuyCount()
  uiLabelBuyTimes.text = totalBuyCount
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Buy" then
    self:OnBuyBtnClicked()
  end
end
def.method().OnBuyBtnClicked = function(self)
  local maxBuyCount = WorldBossMgr.MAX_BUY_COUNT
  local totalBuyCount = WorldBossMgr.Instance():GetTotalBuyCount()
  if maxBuyCount <= totalBuyCount then
    Toast(textRes.WorldBoss.ErrorCode[6])
  end
  local yuanbaoInWallet = Int64.ToNumber(ItemModule.Instance():GetAllYuanBao())
  local cost = WorldBossMgr.Instance():GetCost()
  if yuanbaoInWallet < cost then
    _G.GotoBuyYuanbao()
    return
  end
  local buyCount = WorldBossMgr.BUY_COUNT
  local p = require("netio.protocol.mzm.gsp.bigboss.CBuyChallengeCount").new(buyCount)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnWalletChanged = function(p1, p2)
  instance:UpdateOwn()
end
def.static("table", "table").OnBuyChallengeCount = function(p1, p2)
  instance:DestroyPanel()
end
return WorldBossBuyPanel.Commit()
