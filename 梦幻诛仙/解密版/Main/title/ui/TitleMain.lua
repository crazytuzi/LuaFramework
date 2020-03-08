local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local TitleMain = Lplus.Extend(ECPanelBase, "TitleMain")
local def = TitleMain.define
local _instance
local TitleInterface = require("Main.title.TitleInterface")
local titleInterface = TitleInterface.Instance()
local STitleNormalInfo = require("netio.protocol.mzm.gsp.title.STitleNormalInfo")
local UIModelWrap = require("Model.UIModelWrap")
def.field("table")._titleCfgs = nil
def.field("table")._appellationTypes = nil
def.field("number")._reaminUpdateFrame = 2
def.field("number")._selectedChengweiType = 0
def.field("number")._selectedChengwei = 0
def.field("number")._selectedTitle = 0
def.field("number")._refreshTimerID = 0
def.field(UIModelWrap)._UIModelWrap = nil
def.field("number")._forceShowTab = 0
def.static("=>", TitleMain).Instance = function()
  if _instance == nil then
    _instance = TitleMain()
    _instance:Init()
  end
  return _instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    print("TitleMain.CreatePanel()")
    self:CreatePanel(RESPATH.PREFAB_UI_TITLE_MAIN, 1)
    self:SetModal(true)
    self._refreshTimerID = GameUtil.AddGlobalTimer(0.32, true, TitleMain.onRefreshTimer)
  end
  if self:IsShow() then
    self:_LoadAppellationCfgs()
    self:_LoadTitleCfgs()
    self:_Fill()
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  Img_Bg:FindDirect("Group_ChenWei/Btn_Equip"):set_name("Btn_Equip_Chengwei")
  Img_Bg:FindDirect("Group_TouXian/Btn_Equip"):set_name("Btn_Equip_Title")
  Img_Bg:FindDirect("Group_ChenWei/Btn_UnEquip"):set_name("Btn_UnEquip_Chengwei")
  Img_Bg:FindDirect("Group_TouXian/Btn_UnEquip"):set_name("Btn_UnEquip_Title")
  local Table_List = Img_Bg:FindDirect("Group_ChenWei/Scroll View/Table_List")
  local Tab_1 = Table_List:FindDirect("Tab_1")
  Tab_1:SetActive(false)
  local Img_ChenWei = Tab_1:FindDirect("Img_ChenWei")
  Img_ChenWei:set_name("Img_ChenWei_1")
  local Btn_ChenWei = Tab_1:FindDirect("tween/Btn_ChenWei")
  Btn_ChenWei:set_name("Btn_ChenWei_1")
  local Group_Info = self.m_panel:FindDirect("Img_Bg/Group_ChenWei/Group_Info")
  local Label1 = Group_Info:FindDirect("Bg_01/Label2")
  Label1:GetComponent("UILabel"):set_text("")
  local Label2 = Group_Info:FindDirect("Bg_02/Label2")
  Label2:GetComponent("UILabel"):set_text("")
  local Label3 = Group_Info:FindDirect("Bg_03/Label2")
  Label3:GetComponent("UILabel"):set_text("")
  local Toggle = Group_Info:FindDirect("Bg_03/Toggle")
  Toggle:SetActive(false)
  local Label4 = Group_Info:FindDirect("Bg_04/Label2")
  Label4:GetComponent("UILabel"):set_text("")
  local Group_Info = self.m_panel:FindDirect("Img_Bg/Group_TouXian/Group_Info")
  local Label2 = Group_Info:FindDirect("Bg_02/Label2")
  Label2:GetComponent("UILabel"):set_text("")
  local Label3 = Group_Info:FindDirect("Bg_03/Label2")
  Label3:GetComponent("UILabel"):set_text("")
  local Label4 = Group_Info:FindDirect("Bg_04/Label2")
  Label4:GetComponent("UILabel"):set_text("")
  local Texture = Group_Info:FindDirect("Texture")
  local Model = Group_Info:FindDirect("Model")
  local uiModel = Model:GetComponent("UIModel")
  uiModel:set_orthographic(true)
  uiModel:set_pivotCenter(true)
  uiModel.mCanOverflow = true
  self._UIModelWrap = UIModelWrap.new(uiModel)
end
def.override().OnDestroy = function(self)
  self:DestroyModel()
  self._UIModelWrap = nil
end
def.method().DestroyModel = function(self)
  if self._UIModelWrap ~= nil then
    self._UIModelWrap:Destroy()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:_LoadAppellationCfgs()
    self:_LoadTitleCfgs()
    self:_Fill()
    Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActivePropertyChanged, TitleMain.OnActivePropertyChanged)
    Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveTitleChanged, TitleMain.OnActiveTitleChanged)
    Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveAppellationChanged, TitleMain.OnActiveAppellationChanged)
    Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnAppellationChanged, TitleMain.OnOwnAppellationChanged)
    Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnTitleChanged, TitleMain.OnOwnTitleChanged)
    Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnAppellationDeleted, TitleMain.OnOwnAppellationDeleted)
    Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnTitleDeleted, TitleMain.OnOwnTitleDeleted)
    Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.InfoChanged, TitleMain.OnInfoChanged)
  else
    self._titleCfgs = nil
    self._appellationTypes = nil
    Timer:RemoveIrregularTimeListener(self.OnUpdateTime)
    Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActivePropertyChanged, TitleMain.OnActivePropertyChanged)
    Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveTitleChanged, TitleMain.OnActiveTitleChanged)
    Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveAppellationChanged, TitleMain.OnActiveAppellationChanged)
    Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnAppellationChanged, TitleMain.OnOwnAppellationChanged)
    Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnTitleChanged, TitleMain.OnOwnTitleChanged)
    Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnAppellationDeleted, TitleMain.OnOwnAppellationDeleted)
    Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnTitleDeleted, TitleMain.OnOwnTitleDeleted)
    Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.InfoChanged, TitleMain.OnInfoChanged)
  end
end
def.static("table", "table").OnActivePropertyChanged = function(p1, p2)
  local self = _instance
  self:_FillSelectedChengwei()
end
def.static("table", "table").OnActiveTitleChanged = function(p1, p2)
  local self = _instance
  self:_FillSelectedTouxian()
  self:_FillCurrTouxianCheck()
end
def.static("table", "table").OnActiveAppellationChanged = function(p1, p2)
  local self = _instance
  self:_FillSelectedChengwei()
  self:_FillCurrChengweiCheck()
end
def.static("table", "table").OnOwnAppellationChanged = function(p1, p2)
  local self = _instance
  self:_Fill()
end
def.static("table", "table").OnOwnTitleChanged = function(p1, p2)
  local self = _instance
  self:_Fill()
end
def.static("table", "table").OnOwnAppellationDeleted = function(p1, p2)
  local self = _instance
  self:_Fill()
end
def.static("table", "table").OnOwnTitleDeleted = function(p1, p2)
  local self = _instance
  self:_Fill()
end
def.static("table", "table").OnInfoChanged = function(p1, p2)
  local self = _instance
  self:_Fill()
end
def.static().onRefreshTimer = function()
  local self = _instance
  if self:IsShow() then
    self._refreshTimerID = GameUtil.AddGlobalTimer(0.32, true, TitleMain.onRefreshTimer)
    self:_FillSelectedTouxianPeriodTime()
    self:_FillSelectedChengweiPeriodTime()
  end
end
def.method("number").OnUpdateTime = function(self, dt)
  self._reaminUpdateFrame = self._reaminUpdateFrame - 1
  if self._reaminUpdateFrame <= 0 then
    Timer:RemoveIrregularTimeListener(self.OnUpdateTime)
  end
  self:_DoRepositionChenWei()
end
def.method()._DoRepositionChenWei = function(self)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_ChenWei/Scroll View/Table_List")
  local table = Table_List:GetComponent("UITable")
  local count = #self._appellationTypes
  for i = 1, count do
    local Tab = Table_List:FindDirect(string.format("Tab_%d", i))
    local Img_ChenWei = Tab:FindDirect(string.format("Img_ChenWei_%d", i))
    local Img_Select = Img_ChenWei:FindDirect("Img_Select")
    local active = Img_Select:get_activeSelf()
    local tween = Tab:FindDirect("tween")
    local table2 = tween:GetComponent("UITable")
    table2:Reposition()
  end
  table:Reposition()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HideDlg()
  end
  local fnTable = {}
  fnTable.Tab_TouXian = TitleMain.OnTabTouXian
  fnTable.Tab_ChenWei = TitleMain.OnTabChenWei
  fnTable.Btn_Equip_Chengwei = TitleMain.OnBtnEquipChengweiClick
  fnTable.Btn_Equip_Title = TitleMain.OnBtnEquipTitleClick
  fnTable.Btn_UnEquip_Chengwei = TitleMain.OnBtnUnEquipChengweiClick
  fnTable.Btn_UnEquip_Title = TitleMain.OnBtnUnEquipTitleClick
  fnTable.Toggle = TitleMain.OnBtnEquipPropertyClick
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
    return
  end
  local strs = string.split(id, "_")
  if strs[1] == "Img" and strs[2] == "ChenWei" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:_SetSelectedChengweiType(index)
    end
  elseif strs[1] == "Btn" and strs[2] == "ChenWei" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:SetSelectedChengwei(index)
    end
  elseif strs[1] == "Img" and strs[2] == "TouXiani" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:SetSelectedTouXiani(index)
    end
  end
end
def.method().OnTabTouXian = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Tab_TouXian = Img_Bg:FindDirect("Tab_TouXian")
  local Tab_ChenWei = Img_Bg:FindDirect("Tab_ChenWei")
  local Img_Select_TouXian = Tab_TouXian:FindDirect("Img_Select")
  local Img_Select_ChenWei = Tab_ChenWei:FindDirect("Img_Select")
  local isTabTouxian = Img_Select_TouXian:get_activeSelf()
  if isTabTouxian == true then
    return
  end
  if #self._titleCfgs <= 0 then
    Toast(textRes.Title[32])
    return
  end
  Img_Select_TouXian:SetActive(isTabTouxian == false)
  Img_Select_ChenWei:SetActive(isTabTouxian == true)
  local Group_ChenWei = Img_Bg:FindDirect("Group_ChenWei")
  local Group_TouXian = Img_Bg:FindDirect("Group_TouXian")
  Group_TouXian:SetActive(isTabTouxian == false)
  Group_ChenWei:SetActive(isTabTouxian == true)
  self:_FillSelectedTouxianIcon()
end
def.method().OnTabChenWei = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Tab_TouXian = Img_Bg:FindDirect("Tab_TouXian")
  local Tab_ChenWei = Img_Bg:FindDirect("Tab_ChenWei")
  local Img_Select_TouXian = Tab_TouXian:FindDirect("Img_Select")
  local Img_Select_ChenWei = Tab_ChenWei:FindDirect("Img_Select")
  local isTabTouxian = Img_Select_TouXian:get_activeSelf()
  if isTabTouxian == false then
    return
  end
  if #self._appellationTypes <= 0 then
    Toast(textRes.Title[31])
    return
  end
  Img_Select_TouXian:SetActive(isTabTouxian == false)
  Img_Select_ChenWei:SetActive(isTabTouxian == true)
  local Group_ChenWei = Img_Bg:FindDirect("Group_ChenWei")
  local Group_TouXian = Img_Bg:FindDirect("Group_TouXian")
  Group_TouXian:SetActive(isTabTouxian == false)
  Group_ChenWei:SetActive(isTabTouxian == true)
  self._reaminUpdateFrame = 2
  Timer:RegisterIrregularTimeListener(self.OnUpdateTime, self)
end
def.method().OnBtnEquipChengweiClick = function(self)
  local appellationType = self._appellationTypes[self._selectedChengweiType]
  if appellationType == nil then
    return
  end
  local appellationCfgs = appellationType.appellations
  local appellationCfg = appellationCfgs[self._selectedChengwei]
  if appellationCfg == nil then
    return
  end
  local changeId = appellationCfg.id
  local changeType = STitleNormalInfo.APPELLATION
  local appellationID = titleInterface:GetActiveAppellation()
  if appellationID == changeId then
    return
  end
  local CChangeTitleOrAppellationReq = require("netio.protocol.mzm.gsp.title.CChangeTitleOrAppellationReq").new(changeId, changeType)
  gmodule.network.sendProtocol(CChangeTitleOrAppellationReq)
  local activePropertyID = titleInterface:GetActiveProperty()
  if activePropertyID == changeId then
    return
  end
  if #appellationCfg.properties == 0 then
    return
  end
  if activePropertyID <= 0 then
    local CChangePropertyReq = require("netio.protocol.mzm.gsp.title.CChangePropertyReq").new(changeId)
    gmodule.network.sendProtocol(CChangePropertyReq)
    return
  end
  local TitleConfirm = require("Main.title.ui.TitleConfirm")
  TitleConfirm.Instance():ShowDlg(activePropertyID, changeId)
end
def.method().OnBtnEquipPropertyClick = function(self)
  local appellationType = self._appellationTypes[self._selectedChengweiType]
  if appellationType == nil then
    return
  end
  local appellationCfgs = appellationType.appellations
  local appellationCfg = appellationCfgs[self._selectedChengwei]
  if appellationCfg == nil then
    return
  end
  local changeId = appellationCfg.id
  local changeType = STitleNormalInfo.APPELLATION
  local activePropertyID = titleInterface:GetActiveProperty()
  if activePropertyID == changeId then
    return
  end
  local CChangePropertyReq = require("netio.protocol.mzm.gsp.title.CChangePropertyReq").new(changeId)
  gmodule.network.sendProtocol(CChangePropertyReq)
end
def.method().OnBtnEquipTitleClick = function(self)
  local titleCfg = self._titleCfgs[self._selectedTitle]
  if titleCfg == nil then
    return
  end
  local changeId = titleCfg.id
  local changeType = STitleNormalInfo.TITLE
  local CChangeTitleOrAppellationReq = require("netio.protocol.mzm.gsp.title.CChangeTitleOrAppellationReq").new(changeId, changeType)
  gmodule.network.sendProtocol(CChangeTitleOrAppellationReq)
end
def.method().OnBtnUnEquipChengweiClick = function(self)
  local changeType = STitleNormalInfo.APPELLATION
  local CChangeTitleOrAppellationReq = require("netio.protocol.mzm.gsp.title.CChangeTitleOrAppellationReq").new(0, changeType)
  gmodule.network.sendProtocol(CChangeTitleOrAppellationReq)
end
def.method().OnBtnUnEquipTitleClick = function(self)
  local changeType = STitleNormalInfo.TITLE
  local CChangeTitleOrAppellationReq = require("netio.protocol.mzm.gsp.title.CChangeTitleOrAppellationReq").new(0, changeType)
  gmodule.network.sendProtocol(CChangeTitleOrAppellationReq)
end
def.method()._LoadAppellationCfgs = function(self)
  local appellationTypeInfos = {}
  for k, v in pairs(titleInterface._ownAppellation) do
    local cfg = TitleInterface.GetAppellationCfg(v)
    local appellationTypeInfo = appellationTypeInfos[cfg.bigAppellation]
    if appellationTypeInfo == nil then
      local appellationTypeCfg = TitleInterface.GetAppellationTypeCfg(cfg.bigAppellation)
      appellationTypeInfo = {}
      appellationTypeInfo.cfg = appellationTypeCfg
      appellationTypeInfo.appellations = {}
      appellationTypeInfos[cfg.bigAppellation] = appellationTypeInfo
    end
    table.insert(appellationTypeInfo.appellations, cfg)
  end
  self._appellationTypes = {}
  for k, v in pairs(appellationTypeInfos) do
    table.insert(self._appellationTypes, v)
  end
  local sortFn = function(l, r)
    return l.cfg.rank < r.cfg.rank
  end
  table.sort(self._appellationTypes, sortFn)
end
def.method()._LoadTitleCfgs = function(self)
  self._titleCfgs = {}
  for k, v in pairs(titleInterface._ownTitle) do
    local cfg = TitleInterface.GetTitleCfg(v)
    table.insert(self._titleCfgs, cfg)
    print("************  Load TitleCfg", cfg.templateName)
  end
end
def.method()._Fill = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Tab_TouXian = Img_Bg:FindDirect("Tab_TouXian")
  local Tab_ChenWei = Img_Bg:FindDirect("Tab_ChenWei")
  local Img_Select_TouXian = Tab_TouXian:FindDirect("Img_Select")
  local Img_Select_ChenWei = Tab_ChenWei:FindDirect("Img_Select")
  local numAppellationType = #self._appellationTypes
  local numTitleCfg = #self._titleCfgs
  if numAppellationType > 0 and self._forceShowTab ~= 2 then
    Img_Bg:FindDirect("Group_ChenWei"):SetActive(true)
    Img_Bg:FindDirect("Group_TouXian"):SetActive(false)
    Img_Select_ChenWei:SetActive(true)
    Img_Select_TouXian:SetActive(false)
  elseif numTitleCfg > 0 and self._forceShowTab ~= 1 then
    Img_Bg:FindDirect("Group_ChenWei"):SetActive(false)
    Img_Bg:FindDirect("Group_TouXian"):SetActive(true)
    Img_Select_ChenWei:SetActive(false)
    Img_Select_TouXian:SetActive(true)
  end
  self._forceShowTab = 0
  Img_Bg:FindDirect("Group_ChenWei/Btn_Equip_Chengwei"):SetActive(false)
  Img_Bg:FindDirect("Group_ChenWei/Btn_UnEquip_Chengwei"):SetActive(false)
  Img_Bg:FindDirect("Group_TouXian/Btn_Equip_Title"):SetActive(false)
  Img_Bg:FindDirect("Group_TouXian/Btn_UnEquip_Title"):SetActive(false)
  self:_FillTouxian()
  self:_FillChengwei()
  self:_SetSelectedChengweiType(1)
  self:SetSelectedTouXiani(1)
end
def.method()._FillTouxian = function(self)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_TouXian/Scroll View/Table_List")
  local list = Table_List:GetComponent("UIList")
  list.itemCount = #self._titleCfgs
  list:Resize()
  for k, v in pairs(self._titleCfgs) do
    self:_FillTouxianItem(k, v)
  end
  list:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "table")._FillTouxianItem = function(self, index, titleCfg)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_TouXian/Scroll View/Table_List")
  local Img_TouXiani = Table_List:FindDirect(string.format("Img_TouXiani_%d", index))
  local Label = Img_TouXiani:FindDirect(string.format("Label_%d", index))
  Label:GetComponent("UILabel"):set_text(titleCfg.titleName)
end
def.method()._FillCurrTouxianCheck = function(self)
  local TitleID = titleInterface:GetActiveTitle()
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_TouXian/Scroll View/Table_List")
  local list = Table_List:GetComponent("UIList")
  local count = list:get_itemCount()
  for i = 1, count do
    local Img_TouXiani = Table_List:FindDirect(string.format("Img_TouXiani_%d", i))
    local Img_Equiped = Img_TouXiani:FindDirect(string.format("Img_Equiped_%d", i))
    local titleCfg = self._titleCfgs[i]
    Img_Equiped:SetActive(titleCfg ~= nil and titleCfg.id == TitleID)
  end
end
def.method()._FillChengwei = function(self)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_ChenWei/Scroll View/Table_List")
  local table = Table_List:GetComponent("UITable")
  for k, v in pairs(self._appellationTypes) do
    self:_FillChengweiTypeItem(k, v)
  end
  for k, v in pairs(self._appellationTypes) do
    self:_FillChengweiTypeSubItem(k, v)
  end
  table:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "table")._FillChengweiTypeItem = function(self, index, typeCfg)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_ChenWei/Scroll View/Table_List")
  local table = Table_List:GetComponent("UITable")
  local Tab_1 = Table_List:FindDirect("Tab_1")
  local Tab = Table_List:FindDirect(string.format("Tab_%d", index))
  if Tab ~= nil then
    Tab:SetActive(true)
  else
    Tab = Object.Instantiate(Tab_1)
    Tab:set_name(string.format("Tab_%d", index))
    Tab.parent = Tab_1.parent
    Tab:set_localScale(Vector.Vector3.one)
    local Img_ChenWei = Tab:FindDirect("Img_ChenWei_1")
    Img_ChenWei:set_name(string.format("Img_ChenWei_%d", index))
    table:Reposition()
  end
  local Img_ChenWei = Tab:FindDirect(string.format("Img_ChenWei_%d", index))
  local Label = Img_ChenWei:FindDirect("Label")
  Label:GetComponent("UILabel"):set_text(typeCfg.cfg.name)
end
def.method("number", "table")._FillChengweiTypeSubItem = function(self, index, typeCfg)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_ChenWei/Scroll View/Table_List")
  local table = Table_List:GetComponent("UITable")
  local Tab_1 = Table_List:FindDirect("Tab_1")
  local Tab = Table_List:FindDirect(string.format("Tab_%d", index))
  local tween = Tab:FindDirect("tween")
  tween:SetActive(false)
  local table = tween:GetComponent("UITable")
  if typeCfg.appellations ~= nil and #typeCfg.appellations > 0 then
    for k, v in pairs(typeCfg.appellations) do
      self:_FillChengweiItem(tween, k, v)
    end
  end
  table:Reposition()
end
def.method("userdata", "number", "table")._FillChengweiItem = function(self, node, index, ChengweiCfg)
  local table = node:GetComponent("UITable")
  local Btn_ChenWei_1 = node:FindDirect("Btn_ChenWei_1")
  local Btn_ChenWei = node:FindDirect(string.format("Btn_ChenWei_%d", index))
  if Btn_ChenWei ~= nil then
    Btn_ChenWei:SetActive(true)
  else
    Btn_ChenWei = Object.Instantiate(Btn_ChenWei_1)
    Btn_ChenWei:set_name(string.format("Btn_ChenWei_%d", index))
    Btn_ChenWei.parent = Btn_ChenWei_1.parent
    Btn_ChenWei:set_localScale(Vector.Vector3.one)
    table:Reposition()
  end
  local Label_BtnList = Btn_ChenWei:FindDirect("Label_BtnList")
  local Img_Select = Btn_ChenWei:FindDirect("Img_Select")
  local Label_BtnListSelect = Img_Select:FindDirect("Label_BtnListSelect")
  local strAppellation = ChengweiCfg.appellationName
  local appArgs = titleInterface:GetAppellationArgs(ChengweiCfg.id)
  if appArgs ~= nil then
    strAppellation = string.format(ChengweiCfg.appellationName, unpack(appArgs))
  end
  Label_BtnList:GetComponent("UILabel"):set_text(strAppellation)
  Label_BtnListSelect:GetComponent("UILabel"):set_text(strAppellation)
end
def.method()._FillCurrChengweiCheck = function(self)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_ChenWei/Scroll View/Table_List")
  local selectedAppellationType = self._appellationTypes[self._selectedChengweiType]
  local appellationCfgs = selectedAppellationType.appellations
  local count = #appellationCfgs
  local Tab = Table_List:FindDirect(string.format("Tab_%d", self._selectedChengweiType))
  local tween = Tab:FindDirect("tween")
  local appellationID = titleInterface:GetActiveAppellation()
  for i = 1, count do
    local Btn_ChenWei = tween:FindDirect(string.format("Btn_ChenWei_%d", i))
    local Img_Equiped = Btn_ChenWei:FindDirect("Img_Equiped")
    local appellationCfg = appellationCfgs[i]
    Img_Equiped:SetActive(appellationCfg ~= nil and appellationCfg.id == appellationID)
  end
end
def.method("number")._SetSelectedChengweiType = function(self, index)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_ChenWei/Scroll View/Table_List")
  local table = Table_List:GetComponent("UITable")
  local count = #self._appellationTypes
  for i = 1, count do
    local Tab = Table_List:FindDirect(string.format("Tab_%d", i))
    local Img_ChenWei = Tab:FindDirect(string.format("Img_ChenWei_%d", i))
    local Img_Select = Img_ChenWei:FindDirect("Img_Select")
    Img_Select:SetActive(i == index)
    local tween = Tab:FindDirect("tween")
    tween:SetActive(i == index)
    if i == index then
      self._selectedChengweiType = index
      self:SetSelectedChengwei(1)
    end
  end
  self._reaminUpdateFrame = 2
  Timer:RegisterIrregularTimeListener(self.OnUpdateTime, self)
end
def.method("number")._SetSelectedChengwei = function(self, index)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_ChenWei/Scroll View/Table_List")
  local selectedAppellationType = self._appellationTypes[self._selectedChengweiType]
  local appellationCfgs = selectedAppellationType.appellations
  local count = #appellationCfgs
  local Tab = Table_List:FindDirect(string.format("Tab_%d", self._selectedChengweiType))
  local tween = Tab:FindDirect("tween")
  local appellationID = titleInterface:GetActiveAppellation()
  for i = 1, count do
    local Btn_ChenWei = tween:FindDirect(string.format("Btn_ChenWei_%d", i))
    local Img_Select = Btn_ChenWei:FindDirect("Img_Select")
    local Label_BtnList = Btn_ChenWei:FindDirect("Label_BtnList")
    local Label_BtnListSelect = Img_Select:FindDirect("Label_BtnListSelect")
    Img_Select:SetActive(i == index)
    Label_BtnListSelect:SetActive(i == index)
    Label_BtnList:SetActive(i ~= index)
    if i == index then
      self._selectedChengwei = index
    end
    local Img_Equiped = Btn_ChenWei:FindDirect("Img_Equiped")
    local appellationCfg = appellationCfgs[i]
    Img_Equiped:SetActive(appellationCfg ~= nil and appellationCfg.id == appellationID)
  end
end
def.method("number").SetSelectedChengwei = function(self, index)
  self:_SetSelectedChengwei(index)
  self:_FillSelectedChengwei()
end
def.method("number")._SetSelectedTouXiani = function(self, index)
  local Table_List = self.m_panel:FindDirect("Img_Bg/Group_TouXian/Scroll View/Table_List")
  local list = Table_List:GetComponent("UIList")
  local ActiveTitleID = titleInterface:GetActiveTitle()
  local count = list:get_itemCount()
  for i = 1, count do
    local Img_TouXiani = Table_List:FindDirect(string.format("Img_TouXiani_%d", i))
    local Img_Select = Img_TouXiani:FindDirect(string.format("Img_Select_%d", i))
    Img_Select:SetActive(i == index)
    if i == index then
      print("***** _SetSelectedTouXiani   i == index")
      self._selectedTitle = index
    end
    local Img_Equiped = Img_TouXiani:FindDirect(string.format("Img_Equiped_%d", i))
    local titleCfg = self._titleCfgs[i]
    Img_Equiped:SetActive(titleCfg ~= nil and titleCfg.id == ActiveTitleID)
  end
end
def.method("number").SetSelectedTouXiani = function(self, index)
  self:_SetSelectedTouXiani(index)
  self:_FillSelectedTouxian()
end
def.method()._FillSelectedTouxian = function(self)
  local titleCfg = self._titleCfgs[self._selectedTitle]
  if titleCfg == nil then
    return
  end
  local Group_TouXian = self.m_panel:FindDirect("Img_Bg/Group_TouXian")
  local Group_Info = Group_TouXian:FindDirect("Group_Info")
  self:_FillSelectedTouxianIcon()
  local Label2 = Group_Info:FindDirect("Bg_02/Label2")
  Label2:GetComponent("UILabel"):set_text(titleCfg.description)
  local Label3 = Group_Info:FindDirect("Bg_03/Label2")
  Label3:GetComponent("UILabel"):set_text(titleCfg.getMethod)
  local Label3 = Group_Info:FindDirect("Bg_03/Label2")
  Label3:GetComponent("UILabel"):set_text(titleCfg.getMethod)
  local Btn_Equip_Title = Group_TouXian:FindDirect("Btn_Equip_Title")
  local Btn_UnEquip_Title = Group_TouXian:FindDirect("Btn_UnEquip_Title")
  local activeTitleID = titleInterface:GetActiveTitle()
  Btn_Equip_Title:SetActive(activeTitleID ~= titleCfg.id)
  Btn_UnEquip_Title:SetActive(activeTitleID == titleCfg.id)
  self:_FillSelectedTouxianPeriodTime()
end
def.method()._FillSelectedTouxianIcon = function(self)
  local titleCfg = self._titleCfgs[self._selectedTitle]
  if titleCfg == nil then
    return
  end
  local Group_Info = self.m_panel:FindDirect("Img_Bg/Group_TouXian/Group_Info")
  local Texture = Group_Info:FindDirect("Texture")
  local Model = Group_Info:FindDirect("Model")
  local uiModel = Model:GetComponent("UIModel")
  local resourcePath, resourceType = GetIconPath(titleCfg.picId)
  if resourceType == 1 then
    if Model:get_activeInHierarchy() == false then
      return
    end
    Texture:SetActive(false)
    if resourcePath == "" then
      warn(" resourcePath == \"\" iconId = " .. titleCfg.picId)
    end
    self._UIModelWrap._defaultDir = 0
    self._UIModelWrap._defaultScale = 3
    self._UIModelWrap:Load(resourcePath)
  else
    Texture:SetActive(true)
    self:DestroyModel()
    local uiTexture = Texture:GetComponent("UITexture")
    local GUIUtils = require("GUI.GUIUtils")
    GUIUtils.FillIcon(uiTexture, titleCfg.picId)
  end
end
def.method()._FillSelectedTouxianPeriodTime = function(self)
  local titleCfg = self._titleCfgs[self._selectedTitle]
  if titleCfg == nil then
    return
  end
  local Group_Info = self.m_panel:FindDirect("Img_Bg/Group_TouXian/Group_Info")
  local Label4 = Group_Info:FindDirect("Bg_04/Label2")
  local PeriodTimeStr = titleInterface:GetPeriodTimeStr(titleCfg.id, titleCfg.titleOutTime, titleCfg.titleLimit)
  Label4:GetComponent("UILabel"):set_text(PeriodTimeStr)
end
def.method()._FillSelectedChengwei = function(self)
  local appellationType = self._appellationTypes[self._selectedChengweiType]
  if appellationType == nil then
    return
  end
  local appellationCfgs = appellationType.appellations
  local appellationCfg = appellationCfgs[self._selectedChengwei]
  if appellationCfg == nil then
    return
  end
  local Group_ChenWei = self.m_panel:FindDirect("Img_Bg/Group_ChenWei")
  local Group_Info = Group_ChenWei:FindDirect("Group_Info")
  local Label1 = Group_Info:FindDirect("Bg_01/Label2")
  Label1:GetComponent("UILabel"):set_text(appellationCfg.description)
  local Label2 = Group_Info:FindDirect("Bg_02/Label2")
  Label2:GetComponent("UILabel"):set_text(appellationCfg.getMethod)
  local Label3 = Group_Info:FindDirect("Bg_03/Label2")
  local strProperty = ""
  for k, v in pairs(appellationCfg.properties) do
    local PropNameCfg = GetCommonPropNameCfg(v.propertyID)
    if strProperty ~= "" then
      strProperty = strProperty .. "  "
    end
    strProperty = strProperty .. string.format("%s +%d", PropNameCfg.propName, v.value)
  end
  if strProperty == "" then
    strProperty = textRes.Title[4]
  end
  Label3:GetComponent("UILabel"):set_text(strProperty)
  local Toggle = Group_Info:FindDirect("Bg_03/Toggle")
  Toggle:SetActive(#appellationCfg.properties > 0)
  local Img_Select = Toggle:FindDirect("Img_Select")
  local ActivePropertyID = titleInterface:GetActiveProperty()
  Img_Select:SetActive(ActivePropertyID == appellationCfg.id)
  local Btn_Equip_Chengwei = Group_ChenWei:FindDirect("Btn_Equip_Chengwei")
  local Btn_UnEquip_Chengwei = Group_ChenWei:FindDirect("Btn_UnEquip_Chengwei")
  local activeAppellationID = titleInterface:GetActiveAppellation()
  Btn_Equip_Chengwei:SetActive(activeAppellationID ~= appellationCfg.id)
  Btn_UnEquip_Chengwei:SetActive(activeAppellationID == appellationCfg.id)
  self:_FillSelectedChengweiPeriodTime()
end
def.method()._FillSelectedChengweiPeriodTime = function(self)
  local appellationType = self._appellationTypes[self._selectedChengweiType]
  if appellationType == nil then
    return
  end
  local appellationCfgs = appellationType.appellations
  local appellationCfg = appellationCfgs[self._selectedChengwei]
  if appellationCfg == nil then
    return
  end
  local Group_Info = self.m_panel:FindDirect("Img_Bg/Group_ChenWei/Group_Info")
  local Label4 = Group_Info:FindDirect("Bg_04/Label2")
  local PeriodTimeStr = titleInterface:GetPeriodTimeStr(appellationCfg.id, appellationCfg.appellationOutTime, appellationCfg.appellationLimit)
  Label4:GetComponent("UILabel"):set_text(PeriodTimeStr)
end
TitleMain.Commit()
return TitleMain
