local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local RedGiftPanel = Lplus.Extend(ECPanelBase, "RedGiftPanel")
local def = RedGiftPanel.define
local instance
def.field("table").m_UIGO = nil
def.static("=>", RedGiftPanel).Instance = function()
  if not instance then
    instance = RedGiftPanel()
    instance:SetDepth(GUIDEPTH.TOPMOST2)
  end
  return instance
end
def.override().OnCreate = function(self)
  GameUtil.AddGlobalTimer(30, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self:OpenRedGift()
    end
    self:DestroyPanel()
  end)
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_RED_GIFT_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.method().OpenRedGift = function(self)
  RelationShipChainMgr.GetRedgiftActivityReward({})
end
def.method("string").onClick = function(self, id)
  warn("onClick : ", id)
  if id == "Texture" then
    self:OpenRedGift()
    self:DestroyPanel()
  end
end
return RedGiftPanel.Commit()
