local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangListPanel = Lplus.Extend(ECPanelBase, "GangListPanel")
local def = GangListPanel.define
local instance
def.field(GangData).data = nil
def.field("table").uiTbl = nil
def.field("boolean").bFirstQuery = true
def.field("boolean").bWaitToUpdate = false
def.field("table").selectedGang = nil
def.const("number").GangListPageSize = 9
def.static("=>", GangListPanel).Instance = function(self)
  if nil == instance then
    instance = GangListPanel()
    instance.data = GangData.Instance()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self.bFirstQuery = true
  self:RequireToGangList()
  self.bFirstQuery = false
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_RequireNewGangList, GangListPanel.OnNewGangList)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FailedSearch, GangListPanel.OnFailedSearch)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_SucceedSearch, GangListPanel.OnSucceedSearch)
end
def.override().OnCreate = function(self)
  self.uiTbl = GangUtility.FillGangListPanelUI(self.uiTbl, self.m_panel)
  self:HideSearchShowList()
  self:FillGangList()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_RequireNewGangList, GangListPanel.OnNewGangList)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FailedSearch, GangListPanel.OnFailedSearch)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_SucceedSearch, GangListPanel.OnSucceedSearch)
  self.selectedGang = nil
end
def.method().RequireToGangList = function(self)
  local id = Int64.new(0)
  local gangList = GangData.Instance():GetGangList()
  if #gangList > 0 then
    if self.bFirstQuery == true then
      GangData.Instance():SetGangListNull()
    else
      id = gangList[#gangList].gangId
    end
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGetGangListReq").new(id, GangListPanel.GangListPageSize))
end
def.static("table", "table").OnNewGangList = function(params, context)
  for k, v in pairs(params[1]) do
    GangData.Instance():AddGang(v)
  end
  GangData.Instance():SortGangListByGangId()
  if GangListPanel.Instance().m_panel then
    if GangListPanel.Instance().bWaitToUpdate then
      GangListPanel.Instance():FillGangList()
      GangListPanel.Instance().bWaitToUpdate = false
    end
  else
    GangListPanel.Instance().bWaitToUpdate = false
    GangListPanel.Instance():SetModal(true)
    GangListPanel.Instance():CreatePanel(RESPATH.PREFAB_GANG_LIST, 1)
  end
end
def.method().HideSearchShowList = function(self)
  self.uiTbl.Group_List:SetActive(true)
  self.uiTbl.Group_Search:SetActive(false)
  self.uiTbl.Group_Empty:SetActive(false)
  local gangList = self.data:GetGangList()
  if 0 == #gangList then
    self:ShowEmptyListBg(textRes.Gang[65])
  end
end
def.method().ShowSearchHideList = function(self)
  self.uiTbl.Group_List:SetActive(false)
  self.uiTbl.Group_Search:SetActive(true)
  self.uiTbl.Group_Empty:SetActive(false)
end
def.method("string").ShowEmptyListBg = function(self, content)
  self.uiTbl.Group_List:SetActive(false)
  self.uiTbl.Group_Search:SetActive(false)
  self.uiTbl.Group_Empty:SetActive(true)
  local Label_Empty = self.uiTbl.Group_Empty:FindDirect("Img_Chat/Label_Empty")
  Label_Empty:GetComponent("UILabel"):set_text(content)
  self:ShowGangPurpose(textRes.Gang[53])
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
    self:ShowEmptyListBg(textRes.Gang[65])
  end
end
def.method("userdata", "number", "table").FillGangInfo = function(self, gang, index, gangInfo)
  local Label_ID = gang:FindDirect(string.format("Label_ID_%d", index))
  local Label_GangName = gang:FindDirect(string.format("Label_GangName_%d", index))
  local Label_RoleName = gang:FindDirect(string.format("Label_RoleName_%d", index))
  local Label_Level = gang:FindDirect(string.format("Label_Level_%d", index))
  local Label_Num = gang:FindDirect(string.format("Label_Num_%d", index))
  local Img_Apply = gang:FindDirect(string.format("Img_Apply_%d", index))
  local gangDisplayId = GangUtility.GangIdToDisplayID(gangInfo.displayid, gangInfo.gangId)
  Img_Apply:SetActive(false)
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
  GangListPanel.Instance():FailedSearchGang()
end
def.static("table", "table").OnSucceedSearch = function(params, context)
  GangListPanel.Instance():SucceedSearchGang(params[1])
end
def.method().FailedSearchGang = function(self)
  self:ShowEmptyListBg(textRes.Gang[66])
end
def.method("table").SucceedSearchGang = function(self, gangInfo)
  self:ShowSearchHideList()
  self:ShowGangPurpose(gangInfo.purpose)
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
  self:HideSearchShowList()
  if self.selectedGang then
    self:ShowGangPurpose(self.selectedGang.purpose)
  else
    self:ShowGangPurpose(textRes.Gang[53])
  end
  self.uiTbl.Label_DefaultSearch:GetComponent("UILabel"):set_text(textRes.Gang[51])
  self.uiTbl.Img_BgSearchInput:GetComponent("UIInput"):set_value("")
end
def.method("string").ShowGangPurpose = function(self, desc)
  self.uiTbl.Label_Tenet:GetComponent("UILabel"):set_text(desc)
end
def.method("number").selectGang = function(self, index)
  local gangList = self.data:GetGangList()
  local gangInfo = gangList[index]
  if gangInfo then
    self.selectedGang = gangInfo
    self:ShowGangPurpose(gangInfo.purpose)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Img_Search" == id then
    self:SearchByInput()
  elseif "Img_Wrong" == id then
    self:CanelSearch()
  elseif string.sub(id, 1, #"Group_List_") == "Group_List_" then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      local index = tonumber(string.sub(id, #"Group_List_" + 1, -1))
      self:selectGang(index)
    else
      self.selectedGang = nil
      self:ShowGangPurpose(textRes.Gang[53])
    end
  elseif "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Modal" == id then
    self:DestroyPanel()
  end
end
return GangListPanel.Commit()
