local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BetPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local def = BetPanel.define
def.field("table").m_UIGOs = nil
def.field("string").m_title = ""
def.field("table").m_stakes = nil
def.field("function").m_stakeDescGenerator = nil
def.field("number").m_selIndex = 0
def.field("function").m_onBet = nil
local instance
def.static("=>", BetPanel).Instance = function()
  if instance == nil then
    instance = BetPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("table").ShowPanel = function(self, params)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  params = params or {}
  self.m_title = params.title or ""
  self.m_stakes = params.stakes or {}
  self.m_stakeDescGenerator = params.stakeDescGenerator or function(index, stake)
    return ""
  end
  self.m_onBet = params.onBet
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CROSS_BATTLE_BET_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_title = ""
  self.m_stakes = nil
  self.m_stakeDescGenerator = nil
  self.m_selIndex = 0
  self.m_onBet = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Stake" then
    self:OnClickStakeBtn()
  elseif id:find("Btn_Gold") then
    local index = tonumber(id:sub(#"Btn_Gold" + 1, -1))
    if index then
      self:OnSelectStake(index)
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Img_Bg01 = self.m_UIGOs.Img_Bg0:FindDirect("Img_Bg01")
  self.m_UIGOs.Group_Tips = self.m_UIGOs.Img_Bg0:FindDirect("Group_Tips")
  self.m_UIGOs.Label_Tips1 = self.m_UIGOs.Group_Tips:FindDirect("Label_Tips1")
  self.m_UIGOs.Label_Tips2 = self.m_UIGOs.Group_Tips:FindDirect("Label_Tips2")
  self:SetStakeDesc("")
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateStakes()
end
def.method().UpdateTitle = function(self)
  GUIUtils.SetText(self.m_UIGOs.Label_Tips1, self.m_title)
end
def.method().UpdateStakes = function(self)
  local Grid = self.m_UIGOs.Img_Bg01:FindDirect("Scroll View/Grid")
  local len = #self.m_stakes
  if len ~= 3 then
    Grid:SetActive(false)
    local Grid1 = self.m_UIGOs.Img_Bg01:FindDirect("Scroll View/Grid_" .. len)
    if Grid1 then
      Grid = Grid1
    end
  end
  Grid:SetActive(true)
  for i, stake in ipairs(self.m_stakes) do
    local group = Grid:FindDirect("Btn_Gold" .. i)
    if group then
      self:SetStakeInfo(group, stake)
    else
      warn(string.format("Btn_Gold%d not found", i))
    end
  end
end
def.method("userdata", "table").SetStakeInfo = function(self, group, stake)
  local currency = require("Main.Currency.CurrencyFactory").Create(stake.type)
  local Label = group:FindDirect("Texture/Label")
  local currencyName = currency:GetName()
  local text = string.format("%s%s", stake.num, currencyName)
  GUIUtils.SetText(Label, text)
end
def.method("number").OnSelectStake = function(self, index)
  self.m_selIndex = index
  local stake = self.m_stakes[index]
  local desc = self.m_stakeDescGenerator(index, stake)
  self:SetStakeDesc(desc)
end
def.method("string").SetStakeDesc = function(self, desc)
  GUIUtils.SetText(self.m_UIGOs.Label_Tips2, desc)
end
def.method().OnClickStakeBtn = function(self)
  local selStake = self.m_stakes[self.m_selIndex]
  if selStake == nil then
    Toast(textRes.CrossBattle.Bet[3])
    return
  end
  local currency = require("Main.Currency.CurrencyFactory").Create(selStake.type)
  local haveNum = currency:GetHaveNum()
  local needNum = selStake.num
  if haveNum:lt(needNum) then
    currency:AcquireWithQuery()
    return
  end
  self.m_onBet(self.m_selIndex, selStake)
  self:DestroyPanel()
end
return BetPanel.Commit()
