local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local ECGame = Lplus.ForwardDeclare("ECGame")
local PayNewYearRedGiftPanel = Lplus.Extend(ECPanelBase, "PayNewYearRedGiftPanel")
local def = PayNewYearRedGiftPanel.define
local instance
def.field("table").m_UIGO = nil
def.field("function").m_OpenRedGiftCallback = nil
def.field("number").m_timer = -1
def.static("=>", PayNewYearRedGiftPanel).Instance = function()
  if not instance then
    instance = PayNewYearRedGiftPanel()
    instance:SetDepth(GUIDEPTH.TOPMOST2)
  end
  return instance
end
def.override().OnCreate = function(self)
  if self.m_timer ~= -1 then
    GameUtil.RemoveGlobalTimer(self.m_timer)
    self.m_timer = -1
  end
  local delayTime = constant.CPayNewYearConsts.pay_new_year_delay_award_seconds
  self.m_timer = GameUtil.AddGlobalTimer(delayTime, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self:OpenRedGift()
    end
    self.m_timer = -1
    self:DestroyPanel()
  end)
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
end
def.method().ShowDlg = function(self)
  local game = ECGame.Instance()
  if game:GetGameState() ~= _G.GameState.GameWorld then
    return
  end
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_PAYNEWYEAR_REDGIFT_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.method().OpenRedGift = function(self)
  if self.m_OpenRedGiftCallback ~= nil then
    self.m_OpenRedGiftCallback()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Texture" then
    self:OpenRedGift()
    self:DestroyPanel()
  end
end
def.method("function").SetOpenRedGiftCallback = function(self, callback)
  self.m_OpenRedGiftCallback = callback
end
return PayNewYearRedGiftPanel.Commit()
