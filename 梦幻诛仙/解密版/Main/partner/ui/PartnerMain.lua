local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local PartnerMain = Lplus.Extend(ECPanelBase, "PartnerMain")
local def = PartnerMain.define
local inst
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local LV1Property = require("consts.mzm.gsp.partner.confbean.LV1Property")
local LV2Property = require("consts.mzm.gsp.partner.confbean.LV2Property")
local PartnerFaction = require("consts.mzm.gsp.partner.confbean.PartnerFaction")
local PartnerSex = require("consts.mzm.gsp.partner.confbean.PartnerSex")
local PartnerType = require("consts.mzm.gsp.partner.confbean.PartnerType")
local UnlockItem = require("consts.mzm.gsp.partner.confbean.UnlockItem")
local ItemUtils = require("Main.Item.ItemUtils")
local PubroleInterface = require("Main.Pubrole.PubroleInterface")
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
local PersonalHelper = require("Main.Chat.PersonalHelper")
def.static("=>", PartnerMain).Instance = function()
  if inst == nil then
    inst = PartnerMain()
    inst:Init()
  end
  return inst
end
local TabType = {
  Tab_XL = 1,
  Tab_BZ = 2,
  Tab_YS = 3
}
local TabDefine = {
  [TabType.Tab_XL] = {tabName = "Tab_XL", order = 1},
  [TabType.Tab_BZ] = {tabName = "Tab_BZ", order = 2},
  [TabType.Tab_YS] = {
    tabName = "Tab_YS",
    order = 3,
    isOpen = function()
      return PartnerMain.IsYuanShenOpen()
    end
  }
}
def.field("table")._partnerList = nil
def.field("number")._selectedIndex = 0
def.const("number").AutoSelected_PARTNER_FIRST_UNIVITED = 1
def.const("number").AutoSelected_PARTNER_FIRST_JOINED = 2
def.const("number").AutoSelected_SPEC_TAB = 3
def.field("number")._autoSelectedType = 0
def.field("number")._SelectLineupPosition = 0
def.field("number")._editZhenfaIndex = 0
def.field(UIModelWrap)._UIModelWrap = nil
def.field("table")._modleTable = nil
def.field("number")._defaultTab = TabType.Tab_XL
def.field("number")._costItemId = 0
def.const("table").TabType = TabType
local PartnerMain_ListGrid = require("Main.partner.ui.PartnerMain_ListGrid")
local PartnerMain_Info = require("Main.partner.ui.PartnerMain_Info")
local PartnerMain_Lineup = require("Main.partner.ui.PartnerMain_Lineup")
local PartnerMain_God2 = require("Main.partner.ui.PartnerMain_God2")
def.field(PartnerMain_ListGrid)._panelListGrid = nil
def.field(PartnerMain_Info)._panelInfo = nil
def.field(PartnerMain_Lineup)._panelLineup = nil
def.field(PartnerMain_God2)._panelGod = nil
def.method().Init = function(self)
  self._partnerList = {}
  self._modleTable = {}
  self.m_TrigGC = true
  self.m_TryIncLoadSpeed = true
end
def.method().ShowDlgFirstUnivited = function(self)
  self._autoSelectedType = PartnerMain.AutoSelected_PARTNER_FIRST_UNIVITED
  self:ShowDlg()
end
def.method().ShowDlgFirstJoined = function(self)
  self._autoSelectedType = PartnerMain.AutoSelected_PARTNER_FIRST_JOINED
  self:ShowDlg()
end
def.method().ShowDlg = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    self:CreatePanel(RESPATH.PREFAB_UI_PARTNER_MAIN, 1)
    self:SetModal(true)
  end
end
def.method("number").ShowDlgByCostItemId = function(self, costItemId)
  self._costItemId = costItemId
  self:ShowDlg()
end
def.method("number").ShowDlgByTabType = function(self, tabType)
  self._autoSelectedType = PartnerMain.AutoSelected_SPEC_TAB
  local isOpen = PartnerMain.IsTabOpen(tabType)
  if isOpen then
    self._defaultTab = tabType
  end
  self:ShowDlg()
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self._panelListGrid = PartnerMain_ListGrid.New(self)
  self._panelInfo = PartnerMain_Info.New(self)
  self._panelLineup = PartnerMain_Lineup.New(self)
  self._panelGod = PartnerMain_God2.New(self)
  self._panelListGrid:OnCreate()
  self._panelInfo:OnCreate()
  self._panelLineup:OnCreate()
  self._panelGod:OnCreate()
  Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupChanged, PartnerMain.OnPartnerLineupChanged)
  if self._defaultTab == TabType.Tab_XL then
    self:_OnTab_XL()
  elseif self._defaultTab == TabType.Tab_BZ then
    self:_OnTab_BZ()
  elseif self._defaultTab == TabType.Tab_YS then
    self:_OnTab_YS()
  end
end
def.method().InitUI = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local opendTabs = {}
  for tabType, tabDef in pairs(TabDefine) do
    local tabGO = Img_Bg0:FindDirect(tabDef.tabName)
    local isOpen = PartnerMain.IsTabOpen(tabType)
    GUIUtils.SetActive(tabGO, isOpen)
    if isOpen and tabGO then
      table.insert(opendTabs, tabType)
    end
  end
  local tab1 = Img_Bg0:FindDirect(TabDefine[TabType.Tab_XL].tabName)
  local tab2 = Img_Bg0:FindDirect(TabDefine[TabType.Tab_BZ].tabName)
  local initPos = tab1.localPosition
  local posDelta = tab2.localPosition - tab1.localPosition
  table.sort(opendTabs, function(l, r)
    return TabDefine[l].order < TabDefine[r].order
  end)
  for i, tabType in ipairs(opendTabs) do
    local tabGO = Img_Bg0:FindDirect(TabDefine[tabType].tabName)
    tabGO.localPosition = initPos + posDelta * (i - 1)
  end
  local Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
  local Yuanshen = self.m_panel:FindDirect("Img_Bg0/Group_YuanShen")
  GUIUtils.SetActive(Group_Right, true)
  GUIUtils.SetActive(Yuanshen, false)
end
def.override().OnDestroy = function(self)
  self._panelListGrid:OnDestroy()
  self._panelInfo:OnDestroy()
  self._panelLineup:OnDestroy()
  self._panelGod:OnDestroy()
  Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupChanged, PartnerMain.OnPartnerLineupChanged)
  self._defaultTab = TabType.Tab_XL
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self._panelListGrid:OnShow(s)
    if self._panelInfo:IsShow() == true then
      self._panelInfo:OnShow(s)
    end
    if self._panelLineup:IsShow() == true then
      self._panelLineup:OnShow(s)
    end
    if self._panelGod:IsShow() == true then
      self._panelGod:OnShow(s)
    end
    if self._autoSelectedType == PartnerMain.AutoSelected_SPEC_TAB and self._panelGod:IsShow() then
      return
    end
    self:FillListGrid()
    if self._autoSelectedType == PartnerMain.AutoSelected_PARTNER_FIRST_UNIVITED then
      local LineUp = partnerInterface:GetDefaultLineUpNum()
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      local firstUnlock = 0
      local firstUninvited = 0
      for k, v in pairs(self._partnerList) do
        local joined = partnerInterface:IsPartnerInLineup(v.id, LineUp)
        local lock = heroProp.level < v.unlockLevel
        local invited = partnerInterface:HasThePartner(v.id)
        if lock == false and firstUnlock <= 0 then
          firstUnlock = k
        end
        if lock == false and invited == false then
          firstUninvited = k
          break
        end
      end
      if firstUninvited > 0 then
        self._selectedIndex = firstUninvited
      elseif firstUnlock > 0 then
        self._selectedIndex = firstUnlock
      end
    elseif self._autoSelectedType == PartnerMain.AutoSelected_PARTNER_FIRST_JOINED then
      local LineUp = partnerInterface:GetDefaultLineUpNum()
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      for k, v in pairs(self._partnerList) do
        local joined = partnerInterface:IsPartnerInLineup(v.id, LineUp)
        if joined == true then
          self._selectedIndex = k
          break
        end
      end
    elseif 0 < self._costItemId then
      for k, v in pairs(self._partnerList) do
        if v.unlockItemId == self._costItemId then
          self._selectedIndex = k
          break
        end
      end
    end
    if self._selectedIndex == 0 then
      self._selectedIndex = 1
    end
    if self._panelInfo:IsShow() == true then
      self:SetSelected(self._selectedIndex)
      self._panelListGrid:ScrollSelectedIndex(self._selectedIndex)
      PartnerMain.OnTab_XL(self)
      if self._autoSelectedType == PartnerMain.AutoSelected_PARTNER_FIRST_JOINED then
        self:onClick("Btn_XL")
      end
    end
  else
    self._costItemId = 0
    self._panelListGrid:OnShow(s)
    self._panelInfo._isShow = true
    self._panelInfo:OnShow(s)
    self._panelLineup._isShow = true
    self._panelLineup:OnShow(s)
    self._panelGod:OnShow(s)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  if not self._panelListGrid:onClickObj(clickObj) then
    self:onClick(clickObj.name)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:HideDlg()
    return
  end
  local fnTable = {}
  fnTable.Tab_XL = PartnerMain.OnTab_XL
  fnTable.Tab_BZ = PartnerMain.OnTab_BZ
  fnTable.Tab_YS = PartnerMain.OnTab_YS
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
    return
  end
  local res = self._panelListGrid:onClick(id)
  if res == false and self._panelInfo:IsShow() then
    res = self._panelInfo:onClick(id)
  end
  if res == false and self._panelLineup:IsShow() then
    res = self._panelLineup:onClick(id)
  end
  if res == false and self._panelGod:IsShow() then
    res = self._panelGod:onClick(id)
  end
end
def.method("string").onDoubleClick = function(self, id)
  local res = self._panelListGrid:onDoubleClick(id)
end
def.method("string").onDragStart = function(self, id)
  print("onDragStart", id)
  if self._panelInfo:IsShow() == true then
    self._panelInfo:onDragStart(id)
  end
end
def.method("string").onDragEnd = function(self, id)
  if self._panelInfo:IsShow() == true then
    self._panelInfo:onDragEnd(id)
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self._panelInfo:IsShow() == true then
    self._panelInfo:onDrag(id, dx, dy)
  end
end
def.method().FillListGrid = function(self)
  self._panelListGrid:_FillListGrid()
end
def.method().FillPanelInfo = function(self)
  local panel = self.m_panel:FindDirect("Img_Bg0")
  local Group_Info = panel:FindDirect("Group_Right/Group_Info")
  if Group_Info:get_activeInHierarchy() == true then
    local index = self._selectedIndex
    local cfg = self._partnerList[self._selectedIndex]
    self._panelInfo:_FillSelectedLV1Prop(index, cfg)
  end
end
def.method().FillPaneLineup = function(self)
  local panel = self.m_panel:FindDirect("Img_Bg0")
  local Table = panel:FindDirect("Group_Right/Table")
  if Table:get_activeInHierarchy() == true then
    self._panelLineup:FillLineup()
  end
end
def.method("number").SetSelected = function(self, index)
  self._selectedIndex = index
  self._panelListGrid:_SetSelectedList(index)
  self._panelListGrid:_SetSelectedGrid(index)
  if self._panelGod:IsShow() then
    self._panelGod:setPartnerInfo()
  end
  self:FillPanelInfo()
end
def.static("table", "table").OnPartnerLineupChanged = function(p1, p2)
  local self = inst
  self:FillListGrid()
end
def.method()._OnTab_XL = function(self)
  local Tab_XL = self.m_panel:FindDirect("Img_Bg0/Tab_XL")
  local Img_TabXLSelect = Tab_XL:FindDirect("Img_TabXLSelect")
  local Label_TabXL = Tab_XL:FindDirect("Label_TabXL")
  local Tab_BZ = self.m_panel:FindDirect("Img_Bg0/Tab_BZ")
  local Img_TabBZSelect = Tab_BZ:FindDirect("Img_TabBZSelect")
  local Label_TabBZ = Tab_BZ:FindDirect("Label_TabBZ")
  local Tab_YS = self.m_panel:FindDirect("Img_Bg0/Tab_YS")
  local Img_TabYSSelect = Tab_YS:FindDirect("Img_TabYSSelect")
  local Label_TabYS = Tab_YS:FindDirect("Label_TabYS")
  Img_TabXLSelect:SetActive(true)
  Label_TabXL:SetActive(false)
  Img_TabBZSelect:SetActive(false)
  Label_TabBZ:SetActive(true)
  Img_TabYSSelect:SetActive(false)
  Label_TabYS:SetActive(true)
  local Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
  local Group_Info = Group_Right:FindDirect("Group_Info")
  local Table = Group_Right:FindDirect("Table")
  local Yuanshen = self.m_panel:FindDirect("Img_Bg0/Group_YuanShen")
  local Group_List = self.m_panel:FindDirect("Img_Bg0/Group_List")
  Group_List:SetActive(true)
  local Group_InfoActive = Group_Info:get_activeInHierarchy()
  local TableActive = Table:get_activeInHierarchy()
  if Group_InfoActive == false then
    Group_Info:SetActive(true)
    self._panelInfo:OnShow(true)
  end
  if TableActive == true then
    Table:SetActive(false)
    self._panelLineup:OnShow(false)
  end
  local YuanshenActive = Yuanshen:get_activeInHierarchy()
  if YuanshenActive then
    Yuanshen:SetActive(false)
    self._panelGod:OnShow(false)
  end
end
def.static(PartnerMain).OnTab_XL = function(self)
  self._editZhenfaIndex = partnerInterface:GetDefaultLineUpNum() + 1
  self:_OnTab_XL()
  self:FillListGrid()
  self:FillPanelInfo()
  self._panelLineup:_ClearSwapLineupPosition()
end
def.method()._OnTab_BZ = function(self)
  local Tab_XL = self.m_panel:FindDirect("Img_Bg0/Tab_XL")
  local Img_TabXLSelect = Tab_XL:FindDirect("Img_TabXLSelect")
  local Label_TabXL = Tab_XL:FindDirect("Label_TabXL")
  local Tab_BZ = self.m_panel:FindDirect("Img_Bg0/Tab_BZ")
  local Img_TabBZSelect = Tab_BZ:FindDirect("Img_TabBZSelect")
  local Label_TabBZ = Tab_BZ:FindDirect("Label_TabBZ")
  local Tab_YS = self.m_panel:FindDirect("Img_Bg0/Tab_YS")
  local Img_TabYSSelect = Tab_YS:FindDirect("Img_TabYSSelect")
  local Label_TabYS = Tab_YS:FindDirect("Label_TabYS")
  Img_TabXLSelect:SetActive(false)
  Label_TabXL:SetActive(true)
  Img_TabBZSelect:SetActive(true)
  Label_TabBZ:SetActive(false)
  Img_TabYSSelect:SetActive(false)
  Label_TabYS:SetActive(true)
  local Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
  local Group_Info = Group_Right:FindDirect("Group_Info")
  local Table = Group_Right:FindDirect("Table")
  local Yuanshen = self.m_panel:FindDirect("Img_Bg0/Group_YuanShen")
  local Group_List = self.m_panel:FindDirect("Img_Bg0/Group_List")
  Group_List:SetActive(true)
  local Group_InfoActive = Group_Info:get_activeInHierarchy()
  local TableActive = Table:get_activeInHierarchy()
  if Group_InfoActive == true then
    Group_Info:SetActive(false)
    self._panelInfo:OnShow(false)
  end
  if TableActive == false then
    Table:SetActive(true)
    self._panelLineup:OnShow(true)
  end
  local YuanshenActive = Yuanshen:get_activeInHierarchy()
  if YuanshenActive then
    Yuanshen:SetActive(false)
    self._panelGod:OnShow(false)
  end
end
def.static(PartnerMain).OnTab_BZ = function(self)
  self:_OnTab_BZ()
  self:FillListGrid()
  self:FillPaneLineup()
end
def.static(PartnerMain).OnTab_YS = function(self)
  self:_OnTab_YS()
end
def.method()._OnTab_YS = function(self)
  local Tab_XL = self.m_panel:FindDirect("Img_Bg0/Tab_XL")
  local Img_TabXLSelect = Tab_XL:FindDirect("Img_TabXLSelect")
  local Label_TabXL = Tab_XL:FindDirect("Label_TabXL")
  local Tab_BZ = self.m_panel:FindDirect("Img_Bg0/Tab_BZ")
  local Img_TabBZSelect = Tab_BZ:FindDirect("Img_TabBZSelect")
  local Label_TabBZ = Tab_BZ:FindDirect("Label_TabBZ")
  local Tab_YS = self.m_panel:FindDirect("Img_Bg0/Tab_YS")
  local Img_TabYSSelect = Tab_YS:FindDirect("Img_TabYSSelect")
  local Label_TabYS = Tab_YS:FindDirect("Label_TabYS")
  Img_TabXLSelect:SetActive(false)
  Label_TabXL:SetActive(true)
  Img_TabBZSelect:SetActive(false)
  Label_TabBZ:SetActive(true)
  Img_TabYSSelect:SetActive(true)
  Label_TabYS:SetActive(false)
  local Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
  local Group_Info = Group_Right:FindDirect("Group_Info")
  local Table = Group_Right:FindDirect("Table")
  local Yuanshen = self.m_panel:FindDirect("Img_Bg0/Group_YuanShen")
  local Group_List = self.m_panel:FindDirect("Img_Bg0/Group_List")
  local Group_InfoActive = Group_Info:get_activeInHierarchy()
  local TableActive = Table:get_activeInHierarchy()
  if Group_InfoActive == true then
    Group_Info:SetActive(false)
    self._panelInfo:OnShow(false)
  end
  if TableActive == true then
    self._panelLineup:_ClearSwapLineupPosition()
    Table:SetActive(false)
    self._panelLineup:OnShow(false)
  end
  local YuanshenActive = Yuanshen:get_activeInHierarchy()
  if not YuanshenActive then
    Group_List:SetActive(false)
    Yuanshen:SetActive(true)
    self._panelGod:OnShow(true)
  end
end
def.static("number", "=>", "boolean").IsTabOpen = function(tabType)
  local tabDef = TabDefine[tabType]
  if tabDef == nil then
    return false
  end
  if tabDef.isOpen == nil then
    return true
  end
  return tabDef.isOpen()
end
def.static("=>", "boolean").IsYuanShenOpen = function()
  return require("Main.partner.PartnerYuanShenMgr").Instance():IsFeatureOpen()
end
PartnerMain.Commit()
return PartnerMain
