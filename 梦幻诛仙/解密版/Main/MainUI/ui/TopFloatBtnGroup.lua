local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnGroup = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local MainUIUtils = require("Main.MainUI.MainUIUtils")
local BitMap = require("Types.BitMap")
local mainuiConfig = require("Main.MainUI.data.config")
local def = TopFloatBtnGroup.define
local MainUIPanel = require("Main.MainUI.ui.MainUIPanel")
local TopFloatBtnGroupInActivity = require("Main.MainUI.ui.TopFloatBtnGroupInActivity")
local mainui = MainUIPanel.Instance()
local BtnDefs = {
  Btn_LuckyStar = {
    node = require("Main.LuckyStar.ui.LuckyStarEntry").Instance()
  },
  Btn_TianDi = {
    node = require("Main.activity.TianDiBaoKu.ui.TianDiBaoKuEntry").Instance()
  },
  Btn_ActivityHonor = {
    node = require("Main.activity.Medal.ui.MedalEntry").Instance()
  },
  Btn_SummerParty = {
    node = require("Main.Carnival.ui.CarnivalEntry").Instance()
  },
  Btn_ComeBack = {
    node = require("Main.BackToGame.ui.BackToGameMainUIEntry").Instance()
  },
  Btn_NewCarvinal = {
    node = require("Main.WelcomeParty.ui.WelcomePartyEntry").Instance()
  },
  Btn_MonkeyRun = {
    node = require("Main.activity.MonkeyRun.ui.MonkeyRunEntry").Instance()
  },
  Btn_GroupBuying = {
    node = require("Main.GroupShopping.ui.GroupShoppingMainUIEntry").Instance()
  },
  Btn_FightTreasure = {
    node = require("Main.YiYuanDuoBao.ui.MainUIDuoBaoEntry").Instance()
  },
  Btn_LuckyAnniversary = {
    node = require("Main.AllLotto.ui.AllLottoMainUIEntry").Instance()
  },
  Btn_MonkeyEggs = {
    node = require("Main.activity.MonkeyRun.ui.MonkeyRunEggEntry").Instance()
  },
  Btn_AuctionHouse = {
    node = require("Main.Auction.ui.AuctionEntry").Instance()
  },
  Btn_DragonBaoKu = {
    node = require("Main.activity.DragonBaoKu.ui.DragonBaoKuEntry").Instance()
  }
}
def.field(BitMap).m_displayableBitMap = nil
def.field("table").m_UIGOs = nil
local instance
def.static("=>", TopFloatBtnGroup).Instance = function()
  if instance == nil then
    instance = TopFloatBtnGroup()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self:SetDepth(GUIDEPTH.BOTTOM)
  self.m_TryIncLoadSpeed = true
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.MAINUI_SECOND_TOP_PANEL_RES, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  self:SetUndisplayScenes(mainuiConfig.DisplayableBinding[mainuiConfig.ComponentId.TopButtonGroup].undisplay)
  self:CheckDisplayable()
  if gmodule.moduleMgr:GetModule(ModuleId.MAINUI):IsHideIncomplete() then
    self:ShowEntry(false)
  end
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.HIDE_INCOMPLETE, TopFloatBtnGroup.OnHideIncomplete)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.ON_EXPAND, TopFloatBtnGroup.OnMainUIExpand)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.SCENE_CHANGE, TopFloatBtnGroup.OnMainUISceneChange)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, TopFloatBtnGroup.OnTopFloatMenuChange)
end
def.override().OnDestroy = function(self)
  for btnName, v in pairs(BtnDefs) do
    if v.node then
      v.node:Destroy()
    end
  end
  self.m_UIGOs = nil
  self.m_displayableBitMap = nil
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.HIDE_INCOMPLETE, TopFloatBtnGroup.OnHideIncomplete)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.ON_EXPAND, TopFloatBtnGroup.OnMainUIExpand)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.SCENE_CHANGE, TopFloatBtnGroup.OnMainUISceneChange)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, TopFloatBtnGroup.OnTopFloatMenuChange)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateBtnPos()
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
  for btnName, v in pairs(BtnDefs) do
    local btnGO = self.m_UIGOs.Grid_Btn:FindDirect(btnName)
    if btnGO == nil then
      Debug.LogError(string.format("[TopFloatBtnGroup]: %s not found!", btnName))
    end
    if v.node then
      v.node:Init(self, btnGO)
    else
      GUIUtils.SetActive(btnGO, false)
    end
  end
  self.m_UIGOs.Grid_BtnPosition = self.m_UIGOs.Grid_Btn.localPosition
end
def.method().UpdateUI = function(self)
  self:UpdateBtns()
end
def.method().UpdateBtns = function(self)
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
  TopFloatBtnGroupInActivity.Instance():UpdateBtns()
end
def.method().UpdateBtnPos = function(self)
  local uiGrid = self.m_UIGOs.Grid_Btn:GetComponent("UIGrid")
  uiGrid:set_hideInactive(true)
  uiGrid:Reposition()
end
def.method("boolean", "number").SwitchBtnGroupState = function(self, isOpen, aniDuration)
  self:SwitchBtnGroupStateInner(isOpen, aniDuration, 0)
end
def.method("boolean", "number", "number").SwitchBtnGroupStateInner = function(self, isOpen, aniDuration, stage)
  local Grid_Btn = self.m_UIGOs.Grid_Btn
  local targetPos
  if isOpen then
    targetPos = self.m_UIGOs.Grid_BtnPosition
  else
    targetPos = self:GetAnchorLocalPosition()
  end
  if stage == 0 then
    local curPos = Grid_Btn.localPosition
    local deltaPos = curPos - targetPos
    if math.abs(deltaPos.x) < 1.0E-6 and 1.0E-6 > math.abs(deltaPos.y) then
      return
    end
  end
  local uiGrid = Grid_Btn:GetComponent("UIGrid")
  local childList = self:GetActiveSelfChildList(Grid_Btn)
  local maxPreLine = uiGrid:get_maxPerLine()
  local cellWidth = uiGrid:get_cellWidth()
  local cellHeight = uiGrid:get_cellHeight()
  for i, btn in ipairs(childList) do
    local toPosition, toAlpha
    if stage == 0 then
      toPosition = Vector.Vector3.zero
      toAlpha = 0
    else
      local col, row
      if maxPreLine > 0 then
        col = (i - 1) % maxPreLine
        row = math.floor((i - 1) / maxPreLine)
      else
        col = i - 1
        row = 0
      end
      local x = col * cellWidth
      local y = -row * cellHeight
      local z = 0
      toPosition = Vector.Vector3.new(x, y, z)
      toAlpha = 1
    end
    TweenPosition.Begin(btn, aniDuration, toPosition)
    TweenAlpha.Begin(btn, aniDuration, toAlpha)
  end
  if stage == 0 then
    GameUtil.AddGlobalTimer(aniDuration, true, function()
      if not self:IsLoaded() then
        return
      end
      if not mainui:IsLoaded() then
        return
      end
      targetPos = self:GetAnchorLocalPosition()
      Grid_Btn.localPosition = targetPos
      self:SwitchBtnGroupStateInner(isOpen, aniDuration, stage + 1)
    end)
  end
end
def.method("userdata", "=>", "table").GetActiveSelfChildList = function(self, group)
  local childCount = group:get_childCount()
  local childList = {}
  for i = 0, childCount - 1 do
    local childGO = group:GetChild(i)
    if childGO:get_activeSelf() then
      table.insert(childList, childGO)
    end
  end
  return childList
end
def.method().SetBtnGroupAnchorRight = function(self)
  local targetPos = self:GetAnchorRightLocalPosition()
  self.m_UIGOs.Grid_Btn.localPosition = targetPos
end
def.method().SetBtnGroupAnchorLeft = function(self)
  local targetPos = self:GetAnchorLeftLocalPosition()
  self.m_UIGOs.Grid_Btn.localPosition = targetPos
end
def.method("=>", "table").GetAnchorLeftLocalPosition = function(self)
  if mainui:IsMainInfoUIGroupOpened() then
    return self.m_UIGOs.Grid_BtnPosition
  end
  local targetWPos = mainui:GetTopBtnGroupAnchorLeftPosition()
  local targetPos = self.m_UIGOs.Grid_Btn.parent.transform:InverseTransformPoint(targetWPos)
  return targetPos + Vector.Vector3.new(10, 0, 0)
end
def.method("=>", "table").GetAnchorRightLocalPosition = function(self)
  if mainui:IsMainInfoUIGroupOpened() then
    return self.m_UIGOs.Grid_BtnPosition
  end
  local Grid_Btn = self.m_UIGOs.Grid_Btn
  local targetRWPos = mainui:GetTopBtnGroupAnchorRightPosition()
  local targetRPos = Grid_Btn.parent.transform:InverseTransformPoint(targetRWPos)
  local uiGrid = Grid_Btn:GetComponent("UIGrid")
  local childListCount = uiGrid:GetChildListCount()
  local maxPreLine = uiGrid:get_maxPerLine()
  local cellWidth = uiGrid:get_cellWidth()
  local lineCount = math.min(childListCount, maxPreLine)
  local offsetX = -(lineCount - 1) * cellWidth
  local targetPos = Vector.Vector3.new(targetRPos.x + offsetX, targetRPos.y, targetRPos.z)
  return targetPos
end
def.method("=>", "table").GetAnchorLocalPosition = function(self)
  if mainui:IsTopBtnOpposite() then
    return self:GetAnchorRightLocalPosition()
  else
    return self:GetAnchorLeftLocalPosition()
  end
end
def.method("table").SetUndisplayScenes = function(self, sceneids)
  self.m_displayableBitMap = MainUIUtils.SetUndisplayScenes(self.m_displayableBitMap, sceneids)
end
def.method().CheckDisplayable = function(self)
  if MainUIUtils.CanDisplayByUndisplayBitmap(self.m_displayableBitMap) then
    self:ShowEntry(true)
    TopFloatBtnGroupInActivity.Instance():Destroy()
  else
    self:ShowEntry(false)
    TopFloatBtnGroupInActivity.Instance():Create()
  end
end
def.method("boolean").ShowEntry = function(self, isShow)
  GUIUtils.SetActive(self.m_UIGOs.Img_Bg, isShow)
  if isShow then
    self:UpdateBtnPos()
  end
end
def.static("table", "table").OnHideIncomplete = function(params)
  local isHide = params.isHide
  if isHide then
    instance:ShowEntry(false)
    TopFloatBtnGroupInActivity.Instance():Show(false)
  else
    instance:CheckDisplayable()
    TopFloatBtnGroupInActivity.Instance():Show(true)
  end
end
def.static("table", "table").OnMainUIExpand = function(params)
  local isExpand = params.isExpand
  MainUIUtils.AlphaExpand(instance.m_panel, isExpand, nil)
  TopFloatBtnGroupInActivity.Instance():OnMainUIExpand(params)
end
def.static("table", "table").OnMainUISceneChange = function(params)
  instance:CheckDisplayable()
end
local refreshTimer = 0
def.static("table", "table").OnTopFloatMenuChange = function(params)
  if refreshTimer == 0 then
    refreshTimer = GameUtil.AddGlobalLateTimer(0.01, true, function()
      refreshTimer = 0
      instance:UpdateBtns()
    end)
  end
end
return TopFloatBtnGroup.Commit()
