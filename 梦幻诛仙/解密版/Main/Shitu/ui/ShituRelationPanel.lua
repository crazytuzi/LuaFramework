local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ShituRelationPanel = Lplus.Extend(ECPanelBase, "ShituRelationPanel")
local GUIUtils = require("GUI.GUIUtils")
local ShituData = require("Main.Shitu.ShituData")
local ShituModule = require("Main.Shitu.ShituModule")
local ShituUIMgr = require("Main.Shitu.ShituUIMgr")
local def = ShituRelationPanel.define
local instance
def.const("number").UpdateThreshold = 3
def.const("string").PlayerItemPreFix = "PlayerItem_"
def.field("table")._uiObjs = nil
def.field("table")._apprenticeList = nil
def.field("table")._classmateList = nil
def.static("=>", ShituRelationPanel).Instance = function()
  if instance == nil then
    instance = ShituRelationPanel()
  end
  return instance
end
def.method().ShowShituRelation = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SHITU_INFO, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowShituRelationData()
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, ShituRelationPanel.OnShituChange)
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ReceiveChushiApprenticeList, ShituRelationPanel.OnReceiveChushiApprenticeList)
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ReceiveClassMateApprenticeList, ShituRelationPanel.OnReceiveClassMateApprenticeList)
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ReceiveNewAward, ShituRelationPanel.OnReceiveNewAward)
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.PayRespectDataChange, ShituRelationPanel.OnPayRespectDataChange)
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self._uiObjs.Btn_Qingan = self._uiObjs.Img_Bg:FindDirect("Btn_Qingan")
  self._uiObjs.Group_Master = self._uiObjs.Img_Bg:FindDirect("Group_Master")
  self._uiObjs.Group_Bottom = self._uiObjs.Img_Bg:FindDirect("Group_Bottom")
  self._uiObjs.Label_TotalNumber = self._uiObjs.Group_Bottom:FindDirect("Label_TotalNumber")
  self._uiObjs.Group_Pupil = self._uiObjs.Img_Bg:FindDirect("Group_Pupil")
  self._uiObjs.List_Pupil = self._uiObjs.Group_Pupil:FindDirect("List_Pupil")
  self._uiObjs.Apprentice_ScrollView = self._uiObjs.List_Pupil:FindDirect("Scroll View")
  self._uiObjs.Apprentice_List = self._uiObjs.Apprentice_ScrollView:FindDirect("List_Pupil")
  self._uiObjs.Label_NoPupil = self._uiObjs.Group_Pupil:FindDirect("Label_NoPupil")
  self._uiObjs.Group_Classmate = self._uiObjs.Img_Bg:FindDirect("Group_Classmate")
  self._uiObjs.List_Classmate = self._uiObjs.Group_Classmate:FindDirect("List_Classmate")
  self._uiObjs.ClassMate_ScrollView = self._uiObjs.List_Classmate:FindDirect("Scroll View")
  self._uiObjs.ClassMate_List = self._uiObjs.ClassMate_ScrollView:FindDirect("List_Classmate")
  self._uiObjs.Label_NoClassmate = self._uiObjs.Group_Classmate:FindDirect("Label_NoClassmate")
  self._uiObjs.Btn_Chengwei = self._uiObjs.Group_Bottom:FindDirect("Btn_Chengwei")
  self._uiObjs.Group_Bottom:FindDirect("Btn_Fund/Img_RedPoint"):SetActive(false)
end
def.method().ShowShituRelationData = function(self)
  self:SetQinAnStatus()
  self:SetAwardStatus()
  self:SetMasterInfo()
  self:SetApprenticeCount()
  self:SetApprenticeList()
  self:SetClassMateList()
end
def.method().SetQinAnStatus = function(self)
  local shituData = ShituData.Instance()
  local visible = shituData:HasMaster() and not shituData:IsChushi()
  if not ShituModule.IsQingAnFunctionOpen() then
    visible = false
  end
  self._uiObjs.Btn_Qingan:SetActive(visible)
  local redPoiont = self._uiObjs.Btn_Qingan:FindDirect("Img_RedPoint")
  redPoiont:SetActive(ShituUIMgr.Instance():HasPayRespectNotify())
end
def.method().SetAwardStatus = function(self)
  local redPoiont = self._uiObjs.Btn_Chengwei:FindDirect("Img_RedPoint")
  redPoiont:SetActive(ShituUIMgr.Instance():HasNewChushiAwardNotify())
end
def.method().SetMasterInfo = function(self)
  local shituData = ShituData.Instance()
  local masterInfo = shituData:GetMaster()
  local masterLabel = self._uiObjs.Group_Master:FindDirect("Label_MasterName")
  local masterHead = self._uiObjs.Group_Master:FindDirect("Img_MasterIcon")
  local masterIcon = masterHead:FindDirect("Img_Touxiang")
  local masterEmpty = masterHead:FindDirect("Img_Empty")
  local masterName = ""
  local masterPic
  if shituData:HasMaster() then
    masterName = masterInfo.roleName
    masterPic = string.format("%d-%d", masterInfo.occupationId, masterInfo.gender)
  else
    masterName = textRes.Shitu[3]
  end
  if masterPic == nil then
    masterEmpty:SetActive(true)
    masterIcon:SetActive(false)
  else
    masterEmpty:SetActive(false)
    masterIcon:SetActive(true)
    GUIUtils.SetSprite(masterIcon, masterPic)
  end
  GUIUtils.SetText(masterLabel, masterName)
end
def.method().SetApprenticeCount = function(self)
  local shituData = ShituData.Instance()
  GUIUtils.SetText(self._uiObjs.Label_TotalNumber, shituData:GetTotalApprenticeNum())
end
def.method().SetApprenticeList = function(self)
  local GUIScrollList = self._uiObjs.Apprentice_List:GetComponent("GUIScrollList")
  GUIScrollList = GUIScrollList or self._uiObjs.Apprentice_List:AddComponent("GUIScrollList")
  local UIScrollList = self._uiObjs.Apprentice_List:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(UIScrollList, function(item, i)
    self:FillApprenticeInfo(item, i)
    if self:IsNeddPullNextPageApprentice(i) then
      self:PullNextPageApprentice()
    end
  end)
  self._apprenticeList = {}
  self._apprenticeList.listView = UIScrollList
  self._apprenticeList.isWaitForUpdate = false
  self._apprenticeList.noDataTips = self._uiObjs.Label_NoPupil
  local shituData = ShituData.Instance()
  shituData:ClearCurrentCachedChushiApprentice()
  local showCount = shituData:GetCurrentCachedApprenticeCount()
  self:UpdateListData(self._apprenticeList, showCount)
  if shituData:HasNotCachedApprenticeData() then
    self:PullNextPageApprentice()
  end
end
def.method("userdata", "number").FillApprenticeInfo = function(self, item, idx)
  local shituData = ShituData.Instance()
  local roleInfo = shituData:GetApprenticeByIdx(idx)
  if idx <= shituData:GetNowApprenticeCount() then
    self:FillPlayerInfo(item, roleInfo, false)
  else
    self:FillPlayerInfo(item, roleInfo, true)
  end
end
def.method("userdata", "table", "boolean").FillPlayerInfo = function(self, playerItem, roleInfo, isChushi)
  if playerItem == nil or roleInfo == nil then
    return
  end
  playerItem.name = ShituRelationPanel.PlayerItemPreFix .. roleInfo.roleId:tostring()
  local LabelName = playerItem:FindDirect("Label_TongmenName")
  local ImgChushi = playerItem:FindDirect("Img_Apply")
  local ImgPlayerHead = playerItem:FindDirect("Img_TouxiangKuang/Img_TouxiangIcon")
  GUIUtils.SetText(LabelName, roleInfo.roleName)
  GUIUtils.SetActive(ImgChushi, isChushi)
  GUIUtils.SetSprite(ImgPlayerHead, string.format("%d-%d", roleInfo.occupationId, roleInfo.gender))
end
def.method("number", "=>", "boolean").IsNeddPullNextPageApprentice = function(self, curIdx)
  local shituData = ShituData.Instance()
  return not self._apprenticeList.isWaitForUpdate and shituData:HasNotCachedApprenticeData() and shituData:GetCurrentCachedApprenticeCount() - curIdx <= ShituRelationPanel.UpdateThreshold
end
def.method().PullNextPageApprentice = function(self)
  self._apprenticeList.isWaitForUpdate = true
  ShituModule.Instance():GetChuShiApprenticeInfo()
end
def.method().RefreshApprenticeList = function(self)
  local shituData = ShituData.Instance()
  local showCount = shituData:GetCurrentCachedApprenticeCount()
  self:UpdateListData(self._apprenticeList, showCount)
end
def.method("table", "number").UpdateListData = function(self, list, showCount)
  list.isWaitForUpdate = false
  ScrollList_setCount(list.listView, showCount)
  ScrollList_forceUpdate(list.listView)
  if showCount <= 0 then
    list.noDataTips:SetActive(true)
  else
    list.noDataTips:SetActive(false)
  end
end
def.method().SetClassMateList = function(self)
  local GUIScrollList = self._uiObjs.ClassMate_List:GetComponent("GUIScrollList")
  GUIScrollList = GUIScrollList or self._uiObjs.ClassMate_List:AddComponent("GUIScrollList")
  local UIScrollList = self._uiObjs.ClassMate_List:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(UIScrollList, function(item, i)
    self:FillClassmateInfo(item, i)
    if self:IsNeddPullNextPageClassmate(i) then
      self:PullNextPageClassmate()
    end
  end)
  self._classmateList = {}
  self._classmateList.listView = UIScrollList
  self._classmateList.isWaitForUpdate = false
  self._classmateList.noDataTips = self._uiObjs.Label_NoClassmate
  local shituData = ShituData.Instance()
  shituData:ClearCurrentCachedClassmate()
  local showCount = shituData:GetCurrentCachedClassmateCount()
  self:UpdateListData(self._classmateList, showCount)
  if shituData:HasMaster() then
    self:PullNextPageClassmate()
  end
end
def.method("userdata", "number").FillClassmateInfo = function(self, item, idx)
  local shituData = ShituData.Instance()
  local roleInfo = shituData:GetClassmateByIdx(idx)
  if idx <= shituData:GetNowClassmateCount() then
    self:FillPlayerInfo(item, roleInfo, false)
  else
    self:FillPlayerInfo(item, roleInfo, true)
  end
end
def.method("number", "=>", "boolean").IsNeddPullNextPageClassmate = function(self, curIdx)
  local shituData = ShituData.Instance()
  return not self._classmateList.isWaitForUpdate and shituData:HasNotCachedClassmateData() and shituData:GetCurrentCachedClassmateCount() - curIdx <= ShituRelationPanel.UpdateThreshold
end
def.method().PullNextPageClassmate = function(self)
  self._classmateList.isWaitForUpdate = true
  ShituModule.Instance():GetClassMateApprenticeInfo()
end
def.method().RefreshClassmateList = function(self)
  local shituData = ShituData.Instance()
  local showCount = shituData:GetCurrentCachedClassmateCount()
  self:UpdateListData(self._classmateList, showCount)
end
def.method("userdata").ShowMasterInfo = function(self, source)
  local shituData = ShituData.Instance()
  local masterInfo = shituData:GetMaster()
  if shituData:HasMaster() then
    self:GetAndShowPlayerInfo(masterInfo.roleId, source)
  end
end
def.method("userdata", "userdata").GetAndShowPlayerInfo = function(self, roleId, source)
  ShituModule.Instance():GetRoleInfo(roleId, function(roleInfo)
    self:ShowPlayerInfo(roleInfo, source)
  end)
end
def.method("table", "userdata").ShowPlayerInfo = function(self, roleInfo, source)
  local position = source.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  require("Main.Pubrole.PubroleTipsMgr").Instance():ShowTipXY(roleInfo, screenPos.x, screenPos.y, nil)
end
def.static("table", "table").OnShituChange = function(params, tbl)
  instance:SetQinAnStatus()
  instance:SetMasterInfo()
  instance:SetApprenticeCount()
  instance:RefreshApprenticeList()
end
def.static("table", "table").OnReceiveChushiApprenticeList = function(params, context)
  instance:RefreshApprenticeList()
end
def.static("table", "table").OnReceiveClassMateApprenticeList = function(params, context)
  instance:RefreshClassmateList()
end
def.static("table", "table").OnReceiveNewAward = function(params, context)
  instance:SetAwardStatus()
end
def.static("table", "table").OnPayRespectDataChange = function(params, context)
  instance:SetQinAnStatus()
end
def.method("userdata").onClickObj = function(self, obj)
  if obj.name == "Img_TouxiangKuang" then
    local parent = obj.transform.parent
    if parent ~= nil then
      local parentName = obj.transform.parent.name
      local roleId = string.sub(parentName, #ShituRelationPanel.PlayerItemPreFix + 1)
      self:GetAndShowPlayerInfo(Int64.new(roleId), obj)
    end
  elseif obj.name == "Img_MasterIcon" then
    self:ShowMasterInfo(obj)
  else
    self:onClick(obj.name)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif id == "Btn_Chengwei" then
    ShituModule.Instance():ShowAwardPanel()
  elseif id == "Btn_Fund" then
    require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
    ShituModule.GotoShituNPC()
  elseif id == "Btn_Qingan" then
    ShituModule.ShowQinganPanel()
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  self._apprenticeList = nil
  self._classmateList = nil
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, ShituRelationPanel.OnShituChange)
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ReceiveChushiApprenticeList, ShituRelationPanel.OnReceiveChushiApprenticeList)
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ReceiveClassMateApprenticeList, ShituRelationPanel.OnReceiveClassMateApprenticeList)
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.PayRespectDataChange, ShituRelationPanel.OnPayRespectDataChange)
end
ShituRelationPanel.Commit()
return ShituRelationPanel
