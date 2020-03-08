local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GangMergeCandidatesPanel = Lplus.Extend(ECPanelBase, "GangMergeCandidatesPanel")
local def = GangMergeCandidatesPanel.define
local instance
def.field(GangData).data = nil
def.field("boolean").bWaitData = false
def.field("table").gangList = nil
def.field("table").uiTbl = nil
def.field("table").selectedGang = nil
def.static("=>", GangMergeCandidatesPanel).Instance = function(self)
  if nil == instance then
    instance = GangMergeCandidatesPanel()
    instance.data = GangData.Instance()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self.bWaitData = true
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeListReceived, GangMergeCandidatesPanel.OnGangMergeListRecv)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, GangMergeCandidatesPanel.OnGangChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangApplyRes, GangMergeCandidatesPanel.OnGangMergeApplyRes)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGetCombineGangListReq").new())
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeListReceived, GangMergeCandidatesPanel.OnGangMergeListRecv)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, GangMergeCandidatesPanel.OnGangChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangApplyRes, GangMergeCandidatesPanel.OnGangMergeApplyRes)
  self.bWaitData = false
  self.gangList = nil
  self.selectedGang = nil
end
def.static("table", "table").OnGangMergeListRecv = function(params, context)
  local self = GangMergeCandidatesPanel.Instance()
  self.gangList = params[1]
  if self.bWaitData == true then
    self.bWaitData = false
    self:SetModal(true)
    self:CreatePanel(RESPATH.PREFAB_GANG_LIST, 1)
  end
end
def.static("table", "table").OnGangChange = function(params, context)
  if params and params.isBaseInfo then
    GangMergeCandidatesPanel.Instance():DestroyPanel()
  end
end
def.static("table", "table").OnGangMergeApplyRes = function(params, context)
  GangMergeCandidatesPanel.Instance():UpdateUI()
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    return
  end
  self:UpdateUI()
end
def.method().InitUI = function(self)
  self.uiTbl = GangUtility.FillGangListPanelUI(self.uiTbl, self.m_panel)
  self.uiTbl.Img_BgSearchInput:SetActive(false)
  self.uiTbl.Button_Combine:SetActive(true)
  self.uiTbl.Button_Connect:SetActive(true)
end
def.method().UpdateUI = function(self)
  self:FillGangList()
end
def.method("string").ShowEmptyListBg = function(self, content)
  self.uiTbl.Group_List:SetActive(false)
  self.uiTbl.Group_Search:SetActive(false)
  self.uiTbl.Group_Empty:SetActive(true)
  local Label_Empty = self.uiTbl.Group_Empty:FindDirect("Img_Chat/Label_Empty")
  Label_Empty:GetComponent("UILabel"):set_text(content)
  self:ShowGangPurpose(textRes.Gang[53])
end
def.method("=>", "boolean").CheckGang = function(self)
  local combineInfo = self.data:GetCombineGangInfo()
  if combineInfo and combineInfo.targetGangId then
    local gangid = combineInfo.targetGangId
    local gangList = self.gangList
    local gangAmount = #gangList
    for i = 1, gangAmount do
      local gangInfo = gangList[i]
      if Int64.eq(gangid, gangInfo.gangid) then
        if i ~= 1 then
          gangList[i] = gangList[1]
          gangList[1] = gangInfo
        end
        return true
      end
    end
  end
  return false
end
def.method().FillGangList = function(self)
  local isSendGang = self:CheckGang()
  local gangAmount = #self.gangList
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
    local gangInfo = self.gangList[i]
    self:FillGangInfo(gang, i, gangInfo, isSendGang and i == 1)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  self.uiTbl["Scroll View"]:GetComponent("UIScrollView"):ResetPosition()
  if 0 == gangAmount then
    self:ShowEmptyListBg(textRes.Gang[263])
  end
end
def.method("userdata", "number", "table", "boolean").FillGangInfo = function(self, gang, index, gangInfo, isApply)
  local Label_ID = gang:FindDirect(string.format("Label_ID_%d", index))
  local Label_GangName = gang:FindDirect(string.format("Label_GangName_%d", index))
  local Label_RoleName = gang:FindDirect(string.format("Label_RoleName_%d", index))
  local Label_Level = gang:FindDirect(string.format("Label_Level_%d", index))
  local Label_Num = gang:FindDirect(string.format("Label_Num_%d", index))
  local Img_Apply = gang:FindDirect(string.format("Img_Apply_%d", index))
  local gangDisplayId = GangUtility.GangIdToDisplayID(gangInfo.displayid, gangInfo.gangid)
  Img_Apply:SetActive(isApply)
  Label_ID:GetComponent("UILabel"):set_text(Int64.tostring(gangDisplayId))
  Label_GangName:GetComponent("UILabel"):set_text(gangInfo.name)
  Label_RoleName:GetComponent("UILabel"):set_text(gangInfo.leader_name)
  Label_Level:GetComponent("UILabel"):set_text(gangInfo.level)
  Label_Num:GetComponent("UILabel"):set_text(string.format("%d/%d", gangInfo.normal_num, gangInfo.normal_capacity))
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
def.method("string").ShowGangPurpose = function(self, desc)
  self.uiTbl.Label_Tenet:GetComponent("UILabel"):set_text(desc)
end
def.method("number").selectGang = function(self, index)
  local gangInfo = self.gangList[index]
  if gangInfo then
    self.selectedGang = gangInfo
    self:ShowGangPurpose(gangInfo.purpose)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Group_List_") == "Group_List_" then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      local index = tonumber(string.sub(id, #"Group_List_" + 1, -1))
      self:selectGang(index)
    else
      self.selectedGang = nil
      self:ShowGangPurpose(textRes.Gang[53])
    end
  elseif "Btn_ApplyCombine" == id then
    self:ApplyCombine()
  elseif "Btn_Connect" == id then
    self:ContactLeader()
  elseif "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Modal" == id then
    self:DestroyPanel()
  end
end
def.static("number", "table").ApplyCombineCallback = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CCombineGangApplyReq").new(tag.gangid))
  end
end
def.method().ApplyCombine = function(self)
  if not self.selectedGang then
    Toast(textRes.Gang[301])
    return
  end
  if self.data:GetCombineGangStatus() > 0 then
    Toast(textRes.Gang.NormalResult[103])
    return
  end
  local tag = {
    gangid = self.selectedGang.gangid
  }
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Gang[306], self.selectedGang.name), GangMergeCandidatesPanel.ApplyCombineCallback, tag)
end
def.method().ContactLeader = function(self)
  if not self.selectedGang then
    return
  end
  local gangInfo = self.selectedGang
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  local ChatModule = require("Main.Chat.ChatModule")
  SocialDlg.ShowSocialDlg(1)
  ChatModule.Instance():ClearFriendNewCount(gangInfo.leader_id)
  ChatModule.Instance():StartPrivateChat3(gangInfo.leader_id, gangInfo.leader_name, gangInfo.leader_level, gangInfo.leader_menpai, gangInfo.leader_gender, gangInfo.leader_avatarid, gangInfo.leader_avatar_frame)
end
return GangMergeCandidatesPanel.Commit()
