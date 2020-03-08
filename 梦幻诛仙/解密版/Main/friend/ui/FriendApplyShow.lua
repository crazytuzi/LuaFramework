local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FriendUtils = require("Main.friend.FriendUtils")
local FriendData = Lplus.ForwardDeclare("FriendData")
local SocialPanel = Lplus.ForwardDeclare("SocialPanel")
local FriendApplyShow = Lplus.Class("FriendApplyShow")
local def = FriendApplyShow.define
local instance
def.field("userdata")._panel = nil
def.field(SocialPanel)._base = nil
def.field(FriendData)._friendData = nil
def.static("=>", FriendApplyShow).Instance = function(self)
  if nil == instance then
    instance = FriendApplyShow()
    instance._friendData = FriendData.Instance()
  end
  return instance
end
def.method("userdata", SocialPanel).SetPanelAndBase = function(self, panel, base)
  self._panel = panel
  self._base = base
end
def.method().Clear = function(self)
  local WidgetFriend = self._panel:FindDirect("Img_BgFriend/Widget_Friend")
  local gridTemplate = WidgetFriend:FindDirect("Img_BgApply"):FindDirect("Scroll View_FriendApply/Grid_FriendApply")
  local haveCount = gridTemplate:get_childCount()
  for i = 1, haveCount do
    local template = gridTemplate:GetChild(i - 1)
    if i == 1 then
      template:SetActive(false)
    else
      Object.Destroy(template)
      template = nil
    end
  end
end
def.method("table", "userdata").FillList = function(self, list, gridTemplate)
  local listNum = #list
  local uiList = gridTemplate:GetComponent("UIList")
  uiList:set_itemCount(listNum)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local friendsUI = uiList:get_children()
  for i = 1, #friendsUI do
    local friendUI = friendsUI[i]
    local friendInfo = list[i]
    self:FillApplyInfo(friendUI, i, friendInfo)
  end
  self._base:TouchGameObject(self._base.m_panel, self._base.m_parent)
end
def.method("userdata", "number", "table").FillApplyInfo = function(self, applyNew, index, applyInfo)
  local tbl = {
    level = string.format("Label_NumFriendApply_%d", index),
    name = string.format("Label_FriendApplyName_%d", index),
    icon = string.format("Img_IconHeadFriendApply_%d", index),
    occupation = string.format("Img_SchoolFriendApply_%d", index),
    cover = string.format("Img_CoverFriendApply_%d", index)
  }
  local bOnline = require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE == applyInfo.onlineStatus
  FriendUtils.FillBasicInfo(applyNew, tbl, applyInfo, bOnline)
  local coverSprite = applyNew:FindDirect(string.format("Img_CoverFriendApply_%d", index))
  local offLineSprite = applyNew:FindDirect(string.format("Img_OffLine_%d", index))
  coverSprite:SetActive(false)
  offLineSprite:SetActive(false)
  local timeRemain, timeStr = FriendUtils.ComputeRemainTime(FriendUtils.GetApplyTimeMax(), applyInfo.applyTime)
  applyNew:FindDirect(string.format("Label_TimeFriendApply_%d", index)):GetComponent("UILabel"):set_text(string.format(textRes.Friend[15], timeRemain, timeStr))
  if nil ~= applyInfo.content then
    applyNew:FindDirect(string.format("Label_WordPreviewFriendApply_%d", index)):SetActive(true)
    applyNew:FindDirect(string.format("Label_WordPreviewFriendApply_%d", index)):GetComponent("UILabel"):set_text(applyInfo.content)
  else
    applyNew:FindDirect(string.format("Label_WordPreviewFriendApply_%d", index)):SetActive(false)
  end
end
def.method("number", "=>", "number").ShowApplicants = function(self, applyLastNum)
  local WidgetFriend = self._panel:FindDirect("Img_BgFriend/Widget_Friend")
  local ApplyImg = WidgetFriend:FindDirect("Img_BgApply")
  ApplyImg:SetActive(true)
  local applicantList = self._friendData:GetApplicantList()
  applyLastNum = #applicantList
  local gridTemplate = ApplyImg:FindDirect("Scroll View_FriendApply/Grid_FriendApply")
  table.sort(applicantList, function(a, b)
    return a.applyTime > b.applyTime
  end)
  local ApplyTitle = ApplyImg:FindDirect("Img_BgFriendApplyTitle")
  ApplyTitle:FindDirect("Label_FriendApplyTitle"):GetComponent("UILabel"):set_text(textRes.Friend[16])
  local strApply = textRes.Friend[12] .. #applicantList
  ApplyTitle:FindDirect("Btn_BackToFriend01/Label_BackToFriend01"):GetComponent("UILabel"):set_text(strApply)
  self:FillList(applicantList, gridTemplate)
  self._base:TouchGameObject(self._base.m_panel, self._base.m_parent)
  GameUtil.AddGlobalTimer(0.05, true, function()
    if self._base.m_panel and false == self._base.m_panel.isnil then
      ApplyImg:FindDirect("Scroll View_FriendApply"):GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  return applyLastNum
end
def.method("string").OnRefuseApplyClick = function(self, name)
  local refuseFriendId = self._friendData:GetApplicantIdByName(name)
  if nil ~= refuseFriendId then
    FriendApplyShow.Refuse(refuseFriendId)
  end
end
def.method("string").OnAcceptApplyClick = function(self, name)
  if #self._friendData:GetFriendList() >= FriendUtils.GetMaxFriendNum() then
    Toast(textRes.Friend[7])
    return
  end
  local agreeFriendId = self._friendData:GetApplicantIdByName(name)
  if nil ~= agreeFriendId then
    FriendApplyShow.Agree(agreeFriendId)
  end
end
def.static("userdata").Agree = function(agreeFriendId)
  if agreeFriendId ~= nil then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CAgreeApply").new(agreeFriendId))
  end
end
def.static("userdata").Refuse = function(refuseFriendId)
  if refuseFriendId ~= nil then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CDisAgreeApply").new(refuseFriendId))
  end
end
FriendApplyShow.Commit()
return FriendApplyShow
