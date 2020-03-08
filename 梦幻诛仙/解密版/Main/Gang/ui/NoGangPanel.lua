local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local NoGangPanel = Lplus.Extend(ECPanelBase, "NoGangPanel")
local def = NoGangPanel.define
local instance
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangModule = require("Main.Gang.GangModule")
def.field(GangData).data = nil
def.field("table").uiTbl = nil
def.field("boolean").bWaitToUpdate = false
def.field("table").searchGangInfo = nil
def.field("table").selectGang = nil
def.field("boolean").bFirstShow = false
def.field("boolean").canQuickApply = true
def.static("=>", NoGangPanel).Instance = function(self)
  if nil == instance then
    instance = NoGangPanel()
    instance.data = GangData.Instance()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self.bFirstShow = false
  self:RequireToGangList()
  self.bFirstShow = true
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_RequireNewGangList, NoGangPanel.OnNewGangList)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FailedSearch, NoGangPanel.OnFailedSearch)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_SucceedSearch, NoGangPanel.OnSucceedSearch)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FailedCreate, NoGangPanel.OnFailedCreate)
end
def.method().RequireToGangList = function(self)
  local id = Int64.new(0)
  local gangList = GangData.Instance():GetGangList()
  local num = 9
  if #gangList > 0 then
    if self.bFirstShow == false then
      if num > 9 then
        num = #gangList
      end
      GangData.Instance():SetGangListNull()
    else
      id = gangList[#gangList].gangId
    end
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGetGangListReq").new(id, num))
end
def.static("table", "table").OnNewGangList = function(params, context)
  for k, v in pairs(params[1]) do
    GangData.Instance():AddGang(v)
  end
  GangData.Instance():SortGangListByGangId()
  if NoGangPanel.Instance().m_panel then
    if NoGangPanel.Instance().bWaitToUpdate then
      NoGangPanel.Instance():FillGangList()
      NoGangPanel.Instance().bWaitToUpdate = false
    end
  else
    NoGangPanel.Instance().bWaitToUpdate = false
    NoGangPanel.Instance():SetModal(true)
    NoGangPanel.Instance():CreatePanel(RESPATH.PREFAB_NO_GANG_PANEL, 1)
  end
end
def.override().OnCreate = function(self)
  self.uiTbl = GangUtility.FillNoGangPanelUI(self.uiTbl, self.m_panel)
  self:HideSearchShowList()
  self:FillGangList()
end
def.method().HideSearchShowList = function(self)
  self.uiTbl.Group_List:SetActive(true)
  self.uiTbl.Group_Search:SetActive(false)
  self.uiTbl.Group_Empty:SetActive(false)
  self.uiTbl.Btn_Quick:FindDirect("UI_Particle"):SetActive(true)
  GUIUtils.EnableButton(self.uiTbl.Btn_Quick, true)
  local gangList = self.data:GetGangList()
  if 0 == #gangList then
    self:ShowEmptySearch(textRes.Gang[65])
  end
end
def.method().ShowSearchHideList = function(self)
  self.uiTbl.Group_List:SetActive(false)
  self.uiTbl.Group_Search:SetActive(true)
  self.uiTbl.Group_Empty:SetActive(false)
  GUIUtils.EnableButton(self.uiTbl.Btn_Quick, false)
  self.uiTbl.Btn_Quick:FindDirect("UI_Particle"):SetActive(false)
end
def.method("string").ShowEmptySearch = function(self, content)
  self.uiTbl.Group_List:SetActive(false)
  self.uiTbl.Group_Search:SetActive(false)
  self.uiTbl.Group_Empty:SetActive(true)
  GUIUtils.EnableButton(self.uiTbl.Btn_Quick, false)
  self.uiTbl.Btn_Quick:FindDirect("UI_Particle"):SetActive(false)
  local Label_Empty = self.uiTbl.Group_Empty:FindDirect("Img_Chat/Label_Empty")
  Label_Empty:GetComponent("UILabel"):set_text(content)
  self:ShowGangDesc(textRes.Gang[52])
end
def.method().FillGangList = function(self)
  local gangList = self.data:GetGangList()
  local gangAmount = #gangList
  local uiList = self.uiTbl.List_Left:GetComponent("UIList")
  uiList:set_itemCount(gangAmount)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local gangs = uiList:get_children()
  for i = 1, gangAmount do
    local gang = gangs[i]
    local gangInfo = gangList[i]
    self:FillGangInfo(gang, i, gangInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  if false == self.bWaitToUpdate then
    self.uiTbl["Scroll View"]:GetComponent("UIScrollView"):ResetPosition()
  end
  if 0 == gangAmount then
    self:ShowEmptySearch(textRes.Gang[65])
  end
end
def.method("userdata", "number", "table").FillGangInfo = function(self, gang, index, gangInfo)
  local Label_ID = gang:FindDirect(string.format("Label_ID_%d", index))
  local Label_GangName = gang:FindDirect(string.format("Label_GangName_%d", index))
  local Label_RoleName = gang:FindDirect(string.format("Label_RoleName_%d", index))
  local Label_Level = gang:FindDirect(string.format("Label_Level_%d", index))
  local Label_Num = gang:FindDirect(string.format("Label_Num_%d", index))
  local gangDisplayId = GangUtility.GangIdToDisplayID(gangInfo.displayid, gangInfo.gangId)
  Label_ID:GetComponent("UILabel"):set_text(Int64.tostring(gangDisplayId))
  Label_GangName:GetComponent("UILabel"):set_text(gangInfo.name)
  Label_RoleName:GetComponent("UILabel"):set_text(gangInfo.bangZhu)
  Label_Level:GetComponent("UILabel"):set_text(gangInfo.level)
  local bangzhongId = GangUtility.GetGangConsts("BANGZHONG_ID")
  local bangzhongMax = GangUtility.GetDutyMaxNum(bangzhongId, gangInfo.xiangFangLevel)
  Label_Num:GetComponent("UILabel"):set_text(string.format("%d/%d", gangInfo.memberNum, bangzhongMax))
  local Img_Bg1 = gang:FindDirect(string.format("Img_Bg1_%d", index))
  local Img_Bg2 = gang:FindDirect(string.format("Img_Bg2_%d", index))
  if index % 2 == 0 then
    Img_Bg1:SetActive(false)
    Img_Bg2:SetActive(true)
  else
    Img_Bg1:SetActive(true)
    Img_Bg2:SetActive(false)
  end
end
def.method("string").onDragStart = function(self, id)
end
def.method("string").onDragEnd = function(self, id)
  self:DrugScrollView()
end
def.method().DrugScrollView = function(self)
  local dragAmount = self.uiTbl["Scroll View"]:GetComponent("UIScrollView"):GetDragAmount()
  if dragAmount.y > 1 and self.bWaitToUpdate == false then
    self:RequireToGangList()
    self.bWaitToUpdate = true
  end
end
def.static("table", "table").OnFailedSearch = function(params, context)
  NoGangPanel.Instance():FailedSearchGang()
end
def.static("table", "table").OnSucceedSearch = function(params, context)
  NoGangPanel.Instance():SucceedSearchGang(params[1])
end
def.method().FailedSearchGang = function(self)
  self:ShowEmptySearch(textRes.Gang[66])
end
def.method("table").SucceedSearchGang = function(self, gangInfo)
  self.searchGangInfo = {}
  self.searchGangInfo = gangInfo
  self:ShowSearchHideList()
  self:SelectSearchInfo(true)
  local gangDisplayId = GangUtility.GangIdToDisplayID(gangInfo.displayid, gangInfo.gangId)
  local Group_GangSearch = self.uiTbl.Group_Search:FindDirect("Group_GangSearch")
  Group_GangSearch:FindDirect("Label_ID"):GetComponent("UILabel"):set_text(Int64.tostring(gangDisplayId))
  Group_GangSearch:FindDirect("Label_GangName"):GetComponent("UILabel"):set_text(gangInfo.name)
  Group_GangSearch:FindDirect("Label_RoleName"):GetComponent("UILabel"):set_text(gangInfo.bangZhu)
  Group_GangSearch:FindDirect("Label_Level"):GetComponent("UILabel"):set_text(gangInfo.level)
  local bangzhongId = GangUtility.GetGangConsts("BANGZHONG_ID")
  local bangzhongMax = GangUtility.GetDutyMaxNum(bangzhongId, gangInfo.xiangFangLevel)
  Group_GangSearch:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(string.format("%d/%d", gangInfo.memberNum, bangzhongMax))
end
def.method().SearchByInput = function(self)
  local searchGang = self.uiTbl.Label_DefaultSearch:GetComponent("UILabel"):get_text()
  if searchGang ~= "" then
    self:Search(searchGang)
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  if id == "Img_Search" then
    self:SearchByInput()
  end
end
def.method("string").Search = function(self, searchName)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CSearchGangListReq").new(searchName))
end
def.method().CanelSearch = function(self)
  self.searchGangInfo = nil
  self:HideSearchShowList()
  if self.selectGang then
    self:ShowGangDesc(self.selectGang.purpose)
  else
    self:ShowGangDesc(textRes.Gang[52])
  end
  self.uiTbl.Label_DefaultSearch:GetComponent("UILabel"):set_text(textRes.Gang[51])
  self.uiTbl.Img_BgSearchInput:GetComponent("UIInput"):set_value("")
end
def.method("string").ShowGangDesc = function(self, desc)
  self.uiTbl.Label_Tenet:GetComponent("UILabel"):set_text(desc)
end
def.method("number").SelectGang = function(self, index)
  local gangList = self.data:GetGangList()
  local gangInfo = gangList[index]
  if gangInfo then
    self.selectGang = gangInfo
    self:ShowGangDesc(gangInfo.purpose)
  end
end
def.method("boolean").SelectSearchInfo = function(self, selected)
  if self.searchGangInfo and selected then
    self:ShowGangDesc(self.searchGangInfo.purpose)
  else
    self:ShowGangDesc(textRes.Gang[52])
  end
end
def.method().CreateGang = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local level = GangUtility.GetGangConsts("CREATE_NEED_ROLE_LEVEL")
  if level > heroProp.level then
    Toast(string.format(textRes.Gang[61], level))
    return
  end
  local CreateGangPanel = require("Main.Gang.ui.CreateGangPanel")
  local tag = {id = self}
  CreateGangPanel.ShowCreateGangPanel(NoGangPanel.CreateGangCallback, tag)
end
def.static("table").CreateGangCallback = function(tag)
  local self = tag.id
  self:Hide()
end
def.static("table", "table").OnFailedCreate = function(params, context)
  Toast(textRes.Gang[params[1]])
end
def.method().QuickApplyGang = function(self)
  if not self.canQuickApply then
    Toast(textRes.Gang[179])
    return
  end
  local gangId = GangModule.Instance().data:GetGangId()
  if gangId then
    return
  end
  local gangList = self.data:GetGangList()
  if 0 == #gangList then
    Toast(textRes.Gang[67])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CBroadcastJoinGangReq").new())
  self.canQuickApply = false
  GameUtil.AddGlobalLateTimer(5, true, function()
    self.canQuickApply = true
  end)
end
def.method().ApplyGang = function(self)
  if nil == self.selectGang and nil == self.searchGangInfo then
    Toast(textRes.Gang[62])
    return
  end
  local gangId = GangModule.Instance().data:GetGangId()
  if gangId then
    return
  end
  local selectGangId = 0
  if self.selectGang then
    selectGangId = self.selectGang.gangId
  elseif self.searchGangInfo then
    selectGangId = self.searchGangInfo.gangId
  end
  GangModule.Instance():ApplyGang(selectGangId)
end
def.method().SucceedApplyGang = function(self)
end
def.method().Hide = function(self)
  self.searchGangInfo = nil
  self.selectGang = nil
  self:DestroyPanel()
  self = nil
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_RequireNewGangList, NoGangPanel.OnNewGangList)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FailedSearch, NoGangPanel.OnFailedSearch)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_SucceedSearch, NoGangPanel.OnSucceedSearch)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FailedCreate, NoGangPanel.OnFailedCreate)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Img_Search" == id then
    self:SearchByInput()
  elseif "Img_Wrong" == id then
    self:CanelSearch()
  elseif "Group_GangSearch" == id then
  elseif string.sub(id, 1, #"Group_List_") == "Group_List_" then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      local index = tonumber(string.sub(id, #"Group_List_" + 1, -1))
      self:SelectGang(index)
    else
      self.selectGang = nil
      self:ShowGangDesc(textRes.Gang[52])
    end
  elseif "Btn_Creat" == id then
    self:CreateGang()
  elseif "Btn_Quick" == id then
    self:QuickApplyGang()
  elseif "Btn_Apply" == id then
    self:ApplyGang()
  elseif "Btn_Close" == id then
    self:Hide()
  elseif "Modal" == id then
    self:Hide()
  end
end
return NoGangPanel.Commit()
