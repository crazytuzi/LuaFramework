local Lplus = require("Lplus")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local FriendUtils = require("Main.friend.FriendUtils")
local FriendTestDlg = require("Main.friend.ui.FriendTestDlg")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local Vector = require("Types.Vector")
local FriendMainDlg = Lplus.Extend(TabNode, "FriendMainDlg")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local FriendData = Lplus.ForwardDeclare("FriendData")
local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
local HeroModule = require("Main.Hero.HeroModule")
require("Main.module.ModuleId")
local UpdateNoticeModule = require("Main.UpdateNotice.UpdateNoticeModule")
local SocialPanel = Lplus.ForwardDeclare("SocialPanel")
local FriendApplyShow = require("Main.friend.ui.FriendApplyShow")
local FriendShieldShow = require("Main.friend.ui.FriendShieldShow")
local FriendListShow = require("Main.friend.ui.FriendListShow")
local Mail = require("Main.friend.ui.Mail")
local MailInfoPanel = require("Main.friend.ui.MailInfoPanel")
local SystemSetting = require("netio.protocol.mzm.gsp.systemsetting.SystemSetting")
local GangAnnouncementInMailPanel = require("Main.friend.ui.GangAnnouncementInMailPanel")
local def = FriendMainDlg.define
def.field(FriendData)._friendData = nil
def.field(FriendListShow)._friendListShow = nil
def.field(FriendApplyShow)._friendApplyShow = nil
def.field(FriendShieldShow)._friendShieldShow = nil
def.field(Mail)._mailShow = nil
def.field("string")._addFriendName = ""
def.field("userdata")._addFriendId = nil
def.field("boolean")._bApplyListInit = false
def.field("table")._addFriend = nil
def.field("number")._mailInfoIndex = 0
def.field("table").m_RecommendFriendList = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self._friendData = FriendData.Instance()
  self._friendListShow = FriendListShow.Instance()
  self._friendListShow:SetPanelAndBase(self.m_panel, self.m_base)
  self._friendApplyShow = FriendApplyShow.Instance()
  self._friendApplyShow:SetPanelAndBase(self.m_panel, self.m_base)
  self._friendShieldShow = FriendShieldShow.Instance()
  self._friendShieldShow:SetPanelAndBase(self.m_panel, self.m_base)
  self._mailShow = Mail.Instance()
  self._mailShow:SetPanelAndBase(self.m_panel, self.m_base)
  self._addFriendName = ""
  self._addFriendId = nil
  self._bApplyListInit = false
  self._addFriend = nil
  self._mailInfoIndex = 0
  self.m_RecommendFriendList = {}
end
def.override().OnShow = function(self)
  self._friendData:RefreshFriendGroup()
  self._friendData:ReSortFriendShowList()
  self.m_base.state = SocialPanel.StateConst.Friend
  self.m_base.subState[SocialPanel.StateConst.Friend] = SocialPanel.StateConst.FriendList
  local friendListImg = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend/Img_FriendList")
  friendListImg:SetActive(true)
  friendListImg:FindDirect("Scroll View_Friend"):SetActive(true)
  self:HideSearchInfo()
  self._friendListShow:ShowMainFriendList()
  self.m_panel:FindDirect("Img_BgFriend/Widget_Friend/Group_Mail"):SetActive(false)
  self:CloseOpenMail()
  self:ClearRecommendList()
end
def.method().HideSearchInfo = function(self)
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  FriendListImg:FindDirect("Img_BgSearch"):SetActive(true)
  FriendListImg:FindDirect("Img_BgSearch"):FindDirect("Img_BgInput"):SetActive(true)
  FriendListImg:FindDirect("Img_BgSearch"):FindDirect("Img_BgSearchShort/Img_BgSearchInput"):GetComponent("UIInput"):set_value("")
  FriendListImg:FindDirect("Img_BgSearch"):FindDirect("Img_BgSearchShort"):SetActive(false)
  FriendListImg:FindDirect("Img_BgSearchFriend"):SetActive(false)
end
def.method().ShowSearchShort = function(self)
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  FriendListImg:FindDirect("Img_BgSearch"):SetActive(true)
  FriendListImg:FindDirect("Img_BgSearch"):FindDirect("Img_BgInput"):SetActive(false)
  FriendListImg:FindDirect("Img_BgSearch"):FindDirect("Img_BgSearchShort/Img_BgSearchInput"):GetComponent("UIInput"):set_value("")
  FriendListImg:FindDirect("Img_BgSearch"):FindDirect("Img_BgSearchShort"):SetActive(true)
  FriendListImg:FindDirect("Img_BgSearchFriend"):SetActive(false)
end
def.override().OnHide = function(self)
  self:CloseOpenMail()
end
def.method().ClearRecommendList = function(self)
  local recommendListView = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend/Img_FriendList/List_TuiJianFriend")
  if recommendListView ~= nil and not recommendListView.isnil then
    recommendListView:SetActive(false)
  end
  if self.m_RecommendFriendList == nil then
    return
  end
  for k, v in pairs(self.m_RecommendFriendList) do
    v = nil
  end
  self.m_RecommendFriendList = {}
end
def.method().Clear = function(self)
  self._addFriendName = ""
  self._addFriendId = nil
  self._bApplyListInit = false
  self._addFriend = nil
  self._mailInfoIndex = 0
  self._mailShow:Clear()
  self._friendListShow:Clear()
  self._friendApplyShow:Clear()
  self._friendShieldShow:Clear()
  self:ClearRecommendList()
  self.m_RecommendFriendList = nil
end
def.method().UpdateNewApplicantName = function(self)
  self._friendListShow:UpdateNewApplicantName()
end
def.method().DeleteLastMail = function(self)
  self._mailShow:DeleteLastMail()
end
def.method().AddLastMail = function(self)
  self._mailShow:AddLastMail()
end
def.method().UpdateFriendList = function(self)
  self._friendListShow:UpdateFriendList()
end
def.method().ShowShieldList = function(self)
  self._friendShieldShow:ShowShieldList()
end
def.method().HideSearchResultItem = function(self)
  local friendListView = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend/Img_FriendList")
  local searchResultItem = friendListView:FindDirect("Img_BgSearchFriend")
  searchResultItem:SetActive(false)
end
def.method("table").OnUpdateAfterAddRecommendFriend = function(self, friendInfo)
  local recommendListView = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend/Img_FriendList/List_TuiJianFriend")
  if recommendListView and not recommendListView.isnil and recommendListView:get_activeInHierarchy() and self.m_RecommendFriendList and #self.m_RecommendFriendList > 0 and friendInfo and friendInfo.roleId then
    local theOne
    local index = 0
    for k, v in pairs(self.m_RecommendFriendList) do
      index = index + 1
      if v.roleId:eq(friendInfo.roleId) then
        theOne = v
        break
      end
    end
    if theOne then
      table.remove(self.m_RecommendFriendList, index)
      self:OnUpdateRecommendFriendList(self.m_RecommendFriendList)
    end
  end
end
def.method("table").OnUpdateRecommendFriendList = function(self, recommendFriendList)
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  if recommendFriendList == nil then
    return
  end
  self.m_RecommendFriendList = recommendFriendList
  local recommendListView = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend/Img_FriendList/List_TuiJianFriend")
  if recommendListView == nil then
    return
  end
  recommendListView:SetActive(true)
  local friendNum = #recommendFriendList
  local uiList = recommendListView:GetComponent("UIList")
  uiList:set_itemCount(friendNum)
  uiList:Resize()
  local itemChildren = uiList:get_children()
  for i = 1, #itemChildren do
    local item = itemChildren[i]
    local nameLabel = item:FindDirect(string.format("Label_SearchFriendName_%d", i)):GetComponent("UILabel")
    local roleIdLabel = item:FindDirect(string.format("Label_SearchFriendID_%d", i)):GetComponent("UILabel")
    local roleSprite = item:FindDirect(string.format("Img_SearchFriendIconHead_%d", i)):GetComponent("UISprite")
    local occupationSprite = item:FindDirect(string.format("Img_SearchFriendSchool_%d", i)):GetComponent("UISprite")
    local recommendSprite = item:FindDirect(string.format("Img_TuiJian_%d", i))
    local levelLabel = item:FindDirect(string.format("Img_SearchFriendIconHead_%d/Label_SearchHead_%d", i, i)):GetComponent("UILabel")
    local coverSprite = item:FindDirect(string.format("Img_SearchFriendCover_%d", i))
    local AddBtn = item:FindDirect(string.format("Btn_Add_%d", i))
    if AddBtn then
      AddBtn.name = string.format("Add_Recommend_%d", i)
    end
    recommendSprite:SetActive(true)
    coverSprite:SetActive(false)
    local recommendInfo = recommendFriendList[i]
    local HeroUtils = require("Main.Hero.HeroUtility").Instance()
    nameLabel:set_text(recommendInfo.roleName)
    local displayId = HeroUtils:RoleIDToDisplayID(recommendInfo.roleId)
    roleIdLabel:set_text(tostring(displayId))
    levelLabel:set_text(recommendInfo.roleLevel)
    local occupationIconId = FriendUtils.GetOccupationIconId(recommendInfo.occupationId)
    FriendUtils.FillIcon(occupationIconId, occupationSprite, 3)
    local roleIconId = FriendUtils.GetFriendIconId(recommendInfo.sex, recommendInfo.occupationId)
    FriendUtils.FillIcon(roleIconId, roleSprite, 1)
  end
  self.m_base.m_msgHandler:Touch(recommendListView)
  GameUtil.AddGlobalLateTimer(0, true, function()
    if recommendListView ~= nil and uiList ~= nil then
      uiList:Reposition()
    end
  end)
end
def.static("number", "table").AddShieldCallback = function(i, tag)
  if 1 == i then
    FriendShieldShow.AddShield(tag.id)
  end
end
def.static("userdata", "string").AddShield = function(roleId, roleName)
  local tag = {id = roleId}
  CommonConfirmDlg.ShowConfirm(textRes.Friend[47], string.format(textRes.Friend[48], roleName), FriendMainDlg.AddShieldCallback, tag)
end
def.static("string").RemoveShield = function(shieldName)
  FriendShieldShow.RemoveShield(shieldName)
end
def.static("userdata").RemoveShieldById = function(shieldId)
  FriendShieldShow.RemoveShieldById(shieldId)
end
def.method("userdata", "string").SetAddFriend = function(self, roleId, roleName)
  self._addFriendId = roleId
  self._addFriendName = roleName
end
def.static("number", "table").RemoveShieldCallback = function(i, tag)
  if i == 1 then
    local roleId = tag.roleId
    local self = tag.id
    if self == nil then
      FriendMainDlg.AddFriend(roleId)
    elseif self._addFriend.friendSet == SystemSetting.STATE_NOT_SETTING then
      FriendMainDlg.AddFriend(self._addFriendId)
      self:AfterAddFriend()
    elseif self._addFriend.friendSet == SystemSetting.STATE_SETTING then
      FriendTestDlg.ShowTest(self._addFriendId, string.format(textRes.Friend[14], self._addFriendName), FriendMainDlg.AddFriendCallback, {id = self})
    end
  elseif i == 0 then
  end
end
def.method("number").OnClickAddRecommendFriend = function(self, index)
  local recommendInfo = self.m_RecommendFriendList[index]
  if recommendInfo == nil then
    return
  end
  local roleId = recommendInfo.roleId
  local roleName = recommendInfo.roleName
  if FriendModule.Instance():IsFriend(roleId) then
    Toast(string.format(textRes.Friend[61], roleName))
    return
  elseif FriendModule.Instance():IsInApplyList(roleId) then
    Toast(textRes.Friend[63])
    return
  else
    if #self._friendData:GetFriendList() >= FriendUtils.GetMaxFriendNum() then
      Toast(textRes.Friend[7])
      return
    end
    if recommendInfo.friendSet == SystemSetting.STATE_NOT_SETTING then
      FriendMainDlg.AddFriend(roleId)
    elseif recommendInfo.friendSet == SystemSetting.STATE_SETTING then
      FriendTestDlg.ShowTest(roleId, string.format(textRes.Friend[14], roleName), FriendMainDlg.AddRecommendFriendCallback, {id = self})
    end
  end
end
def.method().OnAddFriendClick = function(self)
  if FriendModule.Instance():IsFriend(self._addFriendId) then
    FriendMainDlg.RemoveFriend(self._addFriendId, self._addFriendName)
  elseif FriendModule.Instance():IsInApplyList(self._addFriendId) then
    Toast(textRes.Friend[63])
    return
  else
    if #self._friendData:GetFriendList() >= FriendUtils.GetMaxFriendNum() then
      Toast(textRes.Friend[7])
      return
    end
    local shieldInfo = FriendData.Instance():GetShieldInfo(self._addFriendId)
    if shieldInfo ~= nil then
      CommonConfirmDlg.ShowConfirm("", textRes.Friend[51], FriendMainDlg.RemoveShieldCallback, {
        roleId = self._addFriendId,
        id = self
      })
    elseif self._addFriend.friendSet == SystemSetting.STATE_NOT_SETTING then
      FriendMainDlg.AddFriend(self._addFriendId)
      self:AfterAddFriend()
    elseif self._addFriend.friendSet == SystemSetting.STATE_SETTING then
      FriendTestDlg.ShowTest(self._addFriendId, string.format(textRes.Friend[14], self._addFriendName), FriendMainDlg.AddFriendCallback, {id = self})
    end
  end
end
def.static("userdata", "string").ShowTestDlg = function(roleId, roleName)
  FriendTestDlg.ShowTest(roleId, string.format(textRes.Friend[14], roleName), FriendMainDlg.AddFriendCallback, nil)
end
def.static("userdata", "string").RequireToAddFriend = function(roleId, roleName)
  if FriendModule.Instance():IsFriend(roleId) then
    FriendMainDlg.RemoveFriend(roleId, roleName)
  elseif FriendModule.Instance():IsInApplyList(roleId) then
    Toast(textRes.Friend[63])
    return
  else
    if #FriendData.Instance():GetFriendList() >= FriendUtils.GetMaxFriendNum() then
      Toast(textRes.Friend[7])
      return
    end
    local shieldInfo = FriendData.Instance():GetShieldInfo(roleId)
    if shieldInfo ~= nil then
      CommonConfirmDlg.ShowConfirm("", textRes.Friend[51], FriendMainDlg.RemoveShieldCallback, {roleId = roleId, id = nil})
    else
      FriendMainDlg.AddFriend(roleId)
    end
  end
end
def.method().OnCancelSearchClick = function(self)
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  FriendListImg:FindDirect("Img_BgSearchFriend"):SetActive(false)
  FriendListImg:FindDirect("Scroll View_Friend"):SetActive(true)
  WidgetFriend:FindDirect("Img_BgBlock"):SetActive(false)
end
def.method().OnApplyEntranceClick = function(self)
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  WidgetFriend:FindDirect("Img_FriendList"):SetActive(false)
  WidgetFriend:FindDirect("Img_BgApply"):SetActive(true)
  WidgetFriend:FindDirect("Img_BgBlock"):SetActive(false)
  self:ShowApplicants()
end
def.method().CloseOpenMail = function(self)
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailClose, nil)
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnGangClose, nil)
end
def.method().OnBackToFriendClick = function(self)
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  WidgetFriend:SetActive(true)
  WidgetFriend:FindDirect("Img_FriendList"):SetActive(true)
  WidgetFriend:FindDirect("Img_BgApply"):SetActive(false)
  WidgetFriend:FindDirect("Img_BgBlock"):SetActive(false)
  WidgetFriend:FindDirect("Group_Mail"):SetActive(false)
  WidgetFriend:FindDirect("Img_FriendList"):FindDirect("Scroll View_Friend"):SetActive(true)
  self:HideSearchInfo()
  self._friendListShow:ShowMainFriendList()
  self:CloseOpenMail()
end
def.method("string").OnRefuseApplyClick = function(self, name)
  self._friendApplyShow:OnRefuseApplyClick(name)
end
def.method("string").OnAcceptApplyClick = function(self, name)
  self._friendApplyShow:OnAcceptApplyClick(name)
end
def.method("string").OnCancelBlockClick = function(self, name)
  if nil ~= name then
    FriendMainDlg.RemoveShield(name)
  end
end
def.method().ShowApplicants = function(self)
  local num = self._friendListShow:GetApplyLastNum()
  num = self._friendApplyShow:ShowApplicants(num)
  self._friendListShow:SetApplyLastNum(num)
end
def.method("string").Search = function(self, searchName)
  local displayId = tonumber(searchName)
  local roleId
  if nil ~= displayId then
    roleId = require("Main.Hero.Interface").DisplayIDToRoleID(Int64.new(displayId))
    roleId = Int64.tostring(roleId)
  else
    roleId = searchName
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CFindPlayer").new(roleId))
end
def.static("number", "table").DeleteFriendCallback = function(i, tag)
  if 1 == i and nil ~= tag.id then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CDelFriend").new(tag.id))
  end
end
def.static("userdata").AddFriend = function(addRoleId)
  if CheckCrossServerAndToast() then
    return
  end
  if nil ~= addRoleId then
    local friendNum = #FriendData.Instance():GetFriendList()
    if friendNum >= FriendUtils.GetMaxFriendNum() then
      Toast(textRes.Friend[7])
      return
    end
    local roleId = HeroModule.Instance():GetMyRoleId()
    if roleId == addRoleId then
      Toast(textRes.Friend[5])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CAddFriend").new(addRoleId))
  end
end
def.method().AfterAddFriend = function(self)
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  if FriendListImg:get_activeInHierarchy() then
    GameUtil.AddGlobalTimer(0.5, true, function()
      if self.m_panel and false == self.m_panel.isnil then
        self:OnBackToFriendClick()
      end
    end)
  end
end
def.static("userdata", "string", "table").AddRecommendFriendCallback = function(friendId, content, tag)
  if nil ~= friendId then
    local data = FriendData.Instance()
    local friendNum = #data:GetFriendList()
    if friendNum >= FriendUtils.GetMaxFriendNum() then
      Toast(textRes.Friend[7])
      return
    end
    local roleId = HeroModule.Instance():GetMyRoleId()
    if roleId == friendId then
      Toast(textRes.Friend[5])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CAppplyAddFriend").new(friendId, content))
    Toast(textRes.Friend[19])
  end
end
def.static("userdata", "string", "table").AddFriendCallback = function(friendId, content, tag)
  if nil ~= friendId then
    local data = FriendData.Instance()
    local friendNum = #data:GetFriendList()
    if friendNum >= FriendUtils.GetMaxFriendNum() then
      Toast(textRes.Friend[7])
      return
    end
    local roleId = HeroModule.Instance():GetMyRoleId()
    if roleId == friendId then
      Toast(textRes.Friend[5])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CAppplyAddFriend").new(friendId, content))
    Toast(textRes.Friend[19])
    if tag ~= nil then
      local self = tag.id
      self:AfterAddFriend()
    end
  end
end
def.static("userdata", "string").RemoveFriend = function(friendId, friendName)
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo and mateInfo.mateId == friendId then
    Toast(textRes.Friend[53])
    return
  end
  local swornMgr = require("Main.Sworn.SwornMgr")
  if swornMgr.IsSwornMember(friendId) then
    Toast(textRes.Friend.CommonResult[12])
    return
  end
  local tag = {id = friendId}
  CommonConfirmDlg.ShowConfirm(textRes.Friend[2], string.format(textRes.Friend[17], friendName), FriendMainDlg.DeleteFriendCallback, tag)
end
def.method().UpdateAddFriendDlg = function(self)
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  if FriendListImg then
    local str = textRes.Friend[2]
    if false == FriendModule.Instance():IsFriend(self._addFriendId) then
      str = textRes.Friend[1]
    end
    local SearchFriend = FriendListImg:FindDirect("Img_BgSearchFriend")
    SearchFriend:FindDirect("Btn_Add/Label_Add"):GetComponent("UILabel"):set_text(str)
  end
end
def.method().CheckNewApply = function(self)
  self._friendListShow:CheckNewApply()
end
def.method().onGetNewApplicant = function(self)
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  local Img_FriendList = WidgetFriend:FindDirect("Img_FriendList")
  local Img_BgApply = WidgetFriend:FindDirect("Img_BgApply")
  local bApplyActive = Img_BgApply:get_activeInHierarchy()
  self:UpdateNewApplicantName()
  self:CheckNewApply()
  if bApplyActive then
    self:ShowApplicants()
  end
end
def.method("table").ShowSearchResult = function(self, searchInfo)
  if nil == searchInfo then
    Toast(textRes.Friend[10])
  else
    local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
    local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
    local serachPanel = FriendListImg:FindDirect("Img_BgSearchFriend")
    serachPanel:SetActive(true)
    local tbl = {
      level = "Label_SearchHead",
      name = "Label_SearchFriendName",
      icon = "Img_SearchFriendIconHead",
      occupation = "Img_SearchFriendSchool",
      cover = "Img_SearchFriendCover"
    }
    local bOnline = require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE == searchInfo.onlineStatus
    FriendUtils.FillBasicInfo(serachPanel, tbl, searchInfo, bOnline)
    local displayId = require("Main.Hero.Interface").RoleIDToDisplayID(searchInfo.roleId)
    serachPanel:FindDirect("Label_SearchFriendID"):GetComponent("UILabel"):set_text(displayId)
    local str = ""
    if FriendModule.Instance():IsFriend(searchInfo.roleId) then
      str = textRes.Friend[2]
    else
      str = textRes.Friend[1]
    end
    serachPanel:FindDirect("Btn_Add/Label_Add"):GetComponent("UILabel"):set_text(str)
    self:SetAddFriend(searchInfo.roleId, searchInfo.roleName)
    self._addFriend = searchInfo
  end
end
def.method("number").SelectMailByMailIndex = function(self, mailIndex)
  self._mailShow:SelectMailByMailIndex(mailIndex)
end
def.method().ShowMailsList = function(self)
  self._mailShow:ShowMailsList()
end
def.method().OnMailClick = function(self)
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  WidgetFriend:SetActive(true)
  WidgetFriend:FindDirect("Img_BgBlock"):SetActive(false)
  WidgetFriend:FindDirect("Img_BgApply"):SetActive(false)
  WidgetFriend:FindDirect("Img_FriendList"):SetActive(false)
  WidgetFriend:FindDirect("Group_Mail"):SetActive(true)
  self.m_panel:FindDirect("Img_BgFriend/Img_BgChat"):SetActive(false)
  self:ShowMailsList()
end
def.method().UpdateUnReadMailsLabel = function(self)
  self._friendListShow:UpdateUnRead()
  self._mailShow:UpdateUnRead()
end
def.method().UpdateMailReadPointAttach = function(self)
  self._mailShow:UpdateMailReadPointAttach()
end
def.method("number").SetUnReadMailsNum = function(self, num)
  self._friendListShow:UpdateUnRead(num)
  self._mailShow:UpdateUnRead(num)
end
def.method().UpdateMailRemainTime = function(self)
  self._mailShow:UpdateMailRemainTime()
end
def.method().HideLastMailInfo = function(self)
  self._mailShow:Hide()
end
def.method("number").SetMailInfoIndex = function(self, index)
  self._mailInfoIndex = index
end
def.method("=>", "number").GetMailInfoIndex = function(self)
  return self._mailInfoIndex
end
def.method().OnAutoButtonClick = function(self)
  self._mailShow:OnAutoButtonClick()
end
def.method("string").OnMailSelect = function(self, name)
  local index = tonumber(string.sub(name, string.len("Group_Mail_") + 1))
  self._mailShow:ShowSelectMailDetail(index)
end
def.method().UpdateAutoButtonLabel = function(self)
  self._mailShow:UpdateAutoButtonLabel()
end
def.method().SucceedAttach = function(self)
  self._mailShow:SucceedAttach()
end
def.method().SucceedRead = function(self)
  self._mailShow:SucceedRead()
end
def.override("string", "userdata").onSubmit = function(self, id, ctrl)
  if id == "Img_BgSearchInput" then
    self:SearchByInput()
  end
end
def.method().SearchByInput = function(self)
  local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  local searchName = FriendListImg:FindDirect("Img_BgSearch/Img_BgSearchShort/Img_BgSearchInput"):GetComponent("UIInput"):get_value()
  local roleId = require("Main.Hero.Interface").GetHeroProp().id
  local roleId = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(roleId)
  local roleId = tostring(roleId)
  local roleName = require("Main.Hero.Interface").GetHeroProp().name
  if searchName == roleId or searchName == roleName then
    Toast(textRes.Friend[60])
    return
  end
  self:ClearRecommendList()
  self:Search(searchName)
end
def.method().OnGangAnnoClick = function(self)
  GangAnnouncementInMailPanel.ShowGangAnnouncementInMailPanel()
end
def.method("number").OnAnnouncementsChanged = function(self, unRead)
  if self._mailShow then
    self._mailShow:OnAnnouncementsChanged(unRead)
  end
end
def.method().OnSyncAnnoClick = function(self)
  UpdateNoticeModule.OpenNoticePanel(UpdateNoticeModule.NoticeSceneType.EnterWorldAlert, function(ret)
    if ret == false then
      Toast(textRes.UpdateNotice[1])
    end
  end)
  self:ShowMailsList()
  self:UpdateUnReadMailsLabel()
  FriendModule.UpdateMailChange()
end
def.method().OnClickRequestRecommendList = function(self)
  self:ClearRecommendList()
  local p = require("netio.protocol.mzm.gsp.friend.CRecomandFriend").new()
  gmodule.network.sendProtocol(p)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Btn_Right_") then
    local index = tonumber(string.sub(id, string.len("Btn_Right_") + 1))
    local friendList = self._friendData:GetAllFriends()
    local roleId = friendList[index].roleId
    FriendCommonDlgManager.ApplyShowFriendCommonDlg(roleId, FriendCommonDlgManager.StateConst.Null)
  elseif "Img_BgSearchFriend" == id then
    FriendCommonDlgManager.ApplyShowFriendCommonDlg(self._addFriend.roleId, FriendCommonDlgManager.StateConst.Null)
  elseif string.find(id, "Img_BgFriendApply_") then
    local index = tonumber(string.sub(id, string.len("Img_BgFriendApply_") + 1))
    local applyList = self._friendData:GetApplicantList()
    FriendCommonDlgManager.ApplyShowFriendCommonDlg(applyList[index].roleId, FriendCommonDlgManager.StateConst.Null)
  elseif string.find(id, "Img_BgBlock00") then
    local index = tonumber(string.sub(id, string.len("Img_BgBlock00") + 1))
    local shieldList = self._friendData:GetShieldList()
    FriendCommonDlgManager.ApplyShowFriendCommonDlg(shieldList[index].roleId, FriendCommonDlgManager.StateConst.Null)
  elseif string.find(id, "Img_BgFriend_") then
    local index = tonumber(string.sub(id, string.len("Img_BgFriend_") + 1))
    FriendUtils.OnFriendClearNewMsgClick(clickobj, string.format("Label_FriendName_%d", index))
  elseif string.find(id, "Btn_Clear_") then
    local index = tonumber(string.sub(id, string.len("Btn_Clear_") + 1))
    local tbl = {
      labelName = string.format("Label_FriendName_%d", index),
      pointLblName = string.format("Label_NewRedPiont_%d", index),
      pointImgName = string.format("Img_NewRedPiont_%d", index)
    }
    local friendInfo = clickobj.parent:FindDirect(string.format("Scroll View_%d", index)):FindDirect(string.format("Img_BgFriend_%d", index))
    FriendUtils.OnFriendClearAllMsgClick(friendInfo, tbl)
  elseif "Img_BgInput" == id then
    local WidgetFriend = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
    local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
    self:ShowSearchShort()
    FriendListImg:FindDirect("Scroll View_Friend"):SetActive(false)
    self:OnClickRequestRecommendList()
  elseif "Img_BgSearchInput" == id then
    self:HideSearchResultItem()
  elseif "Btn_Add" == id then
    self:OnAddFriendClick()
  elseif string.find(id, "Add_Recommend_") then
    local strs = string.split(id, "_")
    if strs[3] ~= nil then
      local index = tonumber(strs[3])
      self:OnClickAddRecommendFriend(index)
    end
  elseif "Img_BgApplyEntrance" == id then
    self:OnApplyEntranceClick()
  elseif string.find(id, "Btn_BackToFriend0") then
    self:OnBackToFriendClick()
  elseif string.find(id, "Btn_FriendApplyRefuse_") then
    local index = tonumber(string.sub(id, string.len("Btn_FriendApplyRefuse_") + 1))
    local name = clickobj.parent:FindDirect(string.format("Label_FriendApplyName_%d", index)):GetComponent("UILabel"):get_text()
    self:OnRefuseApplyClick(name)
  elseif string.find(id, "Btn_FriendApplyAccept_") then
    local index = tonumber(string.sub(id, string.len("Btn_FriendApplyAccept_") + 1))
    local name = clickobj.parent:FindDirect(string.format("Label_FriendApplyName_%d", index)):GetComponent("UILabel"):get_text()
    self:OnAcceptApplyClick(name)
  elseif string.find(id, "Btn_BlockCancel_") then
    local index = tonumber(string.sub(id, string.len("Btn_BlockCancel_") + 1))
    local name = clickobj.parent:FindDirect(string.format("Label_BlockName_%d", index)):GetComponent("UILabel"):get_text()
    self:OnCancelBlockClick(name)
  elseif "Img_BgMail" == id then
    self:OnMailClick()
  elseif "Btn_Shortcut" == id then
    self:OnAutoButtonClick()
  elseif string.find(id, "Img_MailGang_") then
    self:OnMailSelect(clickobj.parent.name)
  elseif "Btn_Close" == id then
    self:CloseOpenMail()
    self:Clear()
  elseif "Img_Search" == id then
    self:SearchByInput()
  elseif "Btn_Cancel02" == id then
    self:ClearRecommendList()
    self:OnBackToFriendClick()
  elseif "Img_GangNotice" == id then
    self:OnGangAnnoClick()
  elseif "Img_BgNotice" == id then
    self:OnSyncAnnoClick()
  elseif string.find(id, "voice_") then
    local index = tonumber(string.sub(id, 7))
    require("Main.Chat.SpeechMgr").Instance():DownloadAndPlay(index, nil)
  end
end
FriendMainDlg.Commit()
return FriendMainDlg
