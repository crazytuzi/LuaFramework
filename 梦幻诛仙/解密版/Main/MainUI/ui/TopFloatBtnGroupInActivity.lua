local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnGroupInActivity = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local MainUIUtils = require("Main.MainUI.MainUIUtils")
local BitMap = require("Types.BitMap")
local MainUIMainMenu = require("Main.MainUI.ui.MainUIMainMenu")
local mainuiConfig = require("Main.MainUI.data.config")
local def = TopFloatBtnGroupInActivity.define
local MainUIPanel = require("Main.MainUI.ui.MainUIPanel")
local mainui = MainUIPanel.Instance()
local BtnDefs = {
  Btn_FightTreasure = {
    node = require("Main.YiYuanDuoBao.ui.MainUIDuoBaoEntry")()
  },
  Btn_LuckyAnniversary = {
    node = require("Main.AllLotto.ui.AllLottoMainUIEntry")()
  }
}
def.field("table").m_UIGOs = nil
def.field(BitMap).m_displayableBitMap = nil
local instance
def.static("=>", TopFloatBtnGroupInActivity).Instance = function()
  if instance == nil then
    instance = TopFloatBtnGroupInActivity()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self:SetDepth(GUIDEPTH.BOTTOM)
  self.m_displayableBitMap = MainUIUtils.SetUndisplayScenes(self.m_displayableBitMap, mainuiConfig.DisplayableBinding[mainuiConfig.ComponentId.TopButtonGroupInActivity].undisplay)
end
def.method().Create = function(self)
  if MainUIUtils.CanDisplayByUndisplayBitmap(self.m_displayableBitMap) then
    if self.m_panel and not self.m_panel.isnil then
      return
    end
    self:CreatePanel(RESPATH.MAINUI_SECOND_TOP_PANEL_RES, 0)
  else
    self:Destroy()
  end
end
def.method().Destroy = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.OPEN_MAINMENU, TopFloatBtnGroupInActivity.OnMainMenuOpen)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.CLOSE_MAINMENU, TopFloatBtnGroupInActivity.OnMainMenuClose)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.OPEN_MAINMENU, TopFloatBtnGroupInActivity.OnMainMenuOpen)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.CLOSE_MAINMENU, TopFloatBtnGroupInActivity.OnMainMenuClose)
  for btnName, v in pairs(BtnDefs) do
    if v.node then
      v.node:Destroy()
    end
  end
  self.m_UIGOs = nil
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:CheckDisplay()
  end
end
def.static("table", "table").OnMainMenuOpen = function(p1, p2)
  TopFloatBtnGroupInActivity.Instance():CheckDisplay()
end
def.static("table", "table").OnMainMenuClose = function(p1, p2)
  GameUtil.AddGlobalTimer(0.3, true, function()
    TopFloatBtnGroupInActivity.Instance():CheckDisplay()
  end)
end
def.method().CheckDisplay = function(self)
  if self.m_panel and not self.m_panel.isnil then
    if MainUIMainMenu.Instance():MenuGroupIsOpen() then
      self.m_UIGOs.Scroll_View:SetActive(false)
    else
      self.m_UIGOs.Scroll_View:SetActive(true)
      self:UpdateBtnPos()
    end
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if BtnDefs[id] then
    local btnDef = BtnDefs[id]
    if btnDef.node then
      btnDef.node:onClick(id)
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Grid_Btn = self.m_UIGOs.Img_Bg:FindDirect("Scroll_View/Grid_Btn")
  self.m_UIGOs.Scroll_View = self.m_UIGOs.Img_Bg:FindDirect("Scroll_View")
  local widget = self.m_UIGOs.Img_Bg:GetComponent("UIWidget")
  widget:set_rawPivot(8)
  widget:SetAnchor_3(self.m_panel, 0, 88, -200, 0)
  self.m_UIGOs.Grid_Btn.localPosition = Vector.Vector3.zero
  self.m_UIGOs.Grid_Btn:GetComponent("UIGrid"):set_pivot(2)
  local childrenCount = self.m_UIGOs.Grid_Btn.childCount
  for i = 0, childrenCount - 1 do
    local child = self.m_UIGOs.Grid_Btn:GetChild(i)
    if child then
      child:SetActive(false)
    end
  end
  for btnName, v in pairs(BtnDefs) do
    local btnGO = self.m_UIGOs.Grid_Btn:FindDirect(btnName)
    if btnGO == nil then
      Debug.LogError(string.format("[TopFloatBtnGroupInActivity]: %s not found!", btnName))
    end
    if v.node then
      v.node:Init(self, btnGO)
    end
  end
end
def.method().UpdateUI = function(self)
  self:UpdateBtns()
end
def.method().UpdateBtns = function(self)
  if self.m_panel and not self.m_panel.isnil and self.m_UIGOs then
    for btnName, v in pairs(BtnDefs) do
      if v.node then
        if v.node:IsOpen() then
          v.node:ShowBtn()
        else
          v.node:HideBtn()
        end
      end
    end
    self:UpdateBtnPos()
  end
end
def.method().UpdateBtnPos = function(self)
  local uiGrid = self.m_UIGOs.Grid_Btn:GetComponent("UIGrid")
  uiGrid:set_hideInactive(true)
  uiGrid:Reposition()
end
def.method("table").OnMainUIExpand = function(self, params)
  if self.m_panel and not self.m_panel.isnil then
    local isExpand = params.isExpand
    MainUIUtils.AlphaExpand(instance.m_panel, isExpand, nil)
  end
end
return TopFloatBtnGroupInActivity.Commit()
