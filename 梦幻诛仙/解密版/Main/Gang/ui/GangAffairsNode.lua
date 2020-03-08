local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local FriendUtils = Lplus.ForwardDeclare("FriendUtils")
local GangAffairsNode = Lplus.Extend(TabNode, "GangAffairsNode")
local def = GangAffairsNode.define
def.field(GangData).data = nil
def.field("table").uiTbl = nil
local instance
def.static("=>", GangAffairsNode).Instance = function()
  if instance == nil then
    instance = GangAffairsNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.data = GangData.Instance()
end
def.override().OnShow = function(self)
  self:InitUI()
  self:ArrangeBtnPos()
  self:FillAffairsInfo()
  self:UpdateRedLabels()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Offline, GangAffairsNode.OnMemberUpdate)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, GangAffairsNode.OnMemberChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MoneyChange, GangAffairsNode.OnGangMoneyChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BuildComplete, GangAffairsNode.OnBuildComplete)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, GangAffairsNode.OnGangNoticeStatesChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_VitalityChanged, GangAffairsNode.OnVitalityChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamRedDotChg, GangAffairsNode.OnGangTeamRedDotChg)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Offline, GangAffairsNode.OnMemberUpdate)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, GangAffairsNode.OnMemberChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MoneyChange, GangAffairsNode.OnGangMoneyChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BuildComplete, GangAffairsNode.OnBuildComplete)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, GangAffairsNode.OnGangNoticeStatesChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_VitalityChanged, GangAffairsNode.OnVitalityChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamRedDotChg, GangAffairsNode.OnGangTeamRedDotChg)
  self:ResetNotice()
end
def.method().ResetNotice = function(self)
  GangData.Instance():SetApplyShow(false)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {2})
end
def.method().Clear = function(self)
end
def.method().InitUI = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  self.uiTbl = {}
  local Group_Left = self.m_node:FindDirect("Group_Left")
  self.uiTbl.Label_IdNum = Group_Left:FindDirect("Group_Id/Label_IdNum")
  self.uiTbl.Label_LvNum = Group_Left:FindDirect("Group_Lv/Label_LvNum")
  self.uiTbl.Label_MemberNum = Group_Left:FindDirect("Group_Member/Label_MemberNum")
  self.uiTbl.Label_StudentNum = Group_Left:FindDirect("Group_Student/Label_StudentNum")
  self.uiTbl.Label_LeaderNum = Group_Left:FindDirect("Group_Leader/Label_LeaderNum")
  self.uiTbl.Label_TimeNum = Group_Left:FindDirect("Group_Time/Label_TimeNum")
  self.uiTbl.Label_UseNum = Group_Left:FindDirect("Group_Use/Label_UseNum")
  self.uiTbl.Label_ActivityNum = Group_Left:FindDirect("Group_Activity/Label_ActivityNum")
  self.uiTbl.Img_BgSlider = Group_Left:FindDirect("Group_Money/Img_BgSlider")
  self.uiTbl.Img_Arrow = Group_Left:FindDirect("Group_Money/Img_Arrow")
  self.uiTbl.Label_SliderNum = Group_Left:FindDirect("Group_Money/Img_BgSlider/Label_SliderNum")
  self.uiTbl.Widget = Group_Left:FindDirect("Widget")
  self.uiTbl.Btn_Manage = Group_Left:FindDirect("Widget/Btn_Manage")
  self.uiTbl.Btn_GangTeam = Group_Left:FindDirect("Widget/Btn_TaamManage")
  local bShow = require("Main.Gang.GangTeamMgr").IsFeatureOpen()
  self.uiTbl.Btn_GangTeam:SetActive(bShow)
  self:_updateGangTeamRedDot()
  self.uiTbl.Btn_GangList = Group_Left:FindDirect("Widget/Btn_GangList")
  self.uiTbl.Btn_HomeUp = Group_Left:FindDirect("Widget/Btn_HomeUp")
  self.uiTbl.Btn_ApplyList = Group_Left:FindDirect("Widget/Btn_ApplyList")
  self.uiTbl.Img_BgRed = Group_Left:FindDirect("Widget/Btn_Manage/Img_BgRed")
  self.uiTbl.Img_BgRed:SetActive(GangData.Instance():IsHaveGangMergeApply())
  self.uiTbl.BtnList = {
    self.uiTbl.Btn_GangList,
    self.uiTbl.Btn_HomeUp
  }
end
def.method()._updateGangTeamRedDot = function(self)
  local imgRed = self.uiTbl.Btn_GangTeam:FindDirect("Img_BgRed")
  local bShow = require("Main.Gang.GangTeamMgr").IsShowRedDot()
  imgRed:SetActive(bShow)
end
def.method().ArrangeBtnPos = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  local bCanMngApplierList = false
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local memberInfo = self.data:GetMemberInfoByRoleId(heroProp.id)
  if memberInfo then
    local tbl = GangUtility.GetAuthority(memberInfo.duty)
    bCanMngApplierList = tbl.isCanMgeApplyList
  end
  self.uiTbl.Btn_ApplyList:SetActive(bCanMngApplierList)
  self.uiTbl.Btn_Manage:SetActive(bCanMngApplierList)
  if bCanMngApplierList then
    table.insert(self.uiTbl.BtnList, self.uiTbl.Btn_ApplyList)
    table.insert(self.uiTbl.BtnList, self.uiTbl.Btn_Manage)
  end
  if #self.uiTbl.BtnList < 4 then
    local containerSizeX = self.uiTbl.Widget:GetComponent("UIWidget").width
    local containerPos = self.uiTbl.Widget:get_localPosition()
    local step = containerSizeX / (#self.uiTbl.BtnList + 1)
    local posY = self.uiTbl.BtnList[1]:get_localPosition().y
    local startX = containerPos.x - containerSizeX / 2
    for i = 1, #self.uiTbl.BtnList do
      local posX = startX + i * step
      self.uiTbl.BtnList[i].transform.localPosition = Vector.Vector3.new(posX, posY, 0)
    end
  end
end
def.method().FillAffairsInfo = function(self)
  local gangInfo = self.data:GetGangBasicInfo()
  if not self.m_node or self.m_node.isnil or not gangInfo.gangId then
    return
  end
  local gangDisplayId = GangUtility.GangIdToDisplayID(gangInfo.displayid, gangInfo.gangId)
  self.uiTbl.Label_IdNum:GetComponent("UILabel"):set_text(Int64.tostring(gangDisplayId))
  self.uiTbl.Label_LvNum:GetComponent("UILabel"):set_text(gangInfo.level)
  self.uiTbl.Label_LeaderNum:GetComponent("UILabel"):set_text(gangInfo.bangZhu)
  self.uiTbl.Label_ActivityNum:GetComponent("UILabel"):set_text(gangInfo.vitality)
  local last = os.date("*t", gangInfo.createTime)
  self.uiTbl.Label_TimeNum:GetComponent("UILabel"):set_text(string.format(textRes.Friend[33], last.year, last.month, last.day))
  local costMoney = self.data:GetMaintainCost()
  self.uiTbl.Label_UseNum:GetComponent("UILabel"):set_text(costMoney)
  local bangzhongId = GangUtility.GetGangConsts("BANGZHONG_ID")
  local bangzhongMax = GangUtility.GetDutyMaxNum(bangzhongId, gangInfo.wingLevel)
  local onlineBangzhong, allBangzhong = self.data:GetOnlineAndAllBangzhongNum()
  self.uiTbl.Label_MemberNum:GetComponent("UILabel"):set_text(string.format("%d/%d/%d", onlineBangzhong, allBangzhong, bangzhongMax))
  local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
  local xuetuMax = GangUtility.GetDutyMaxNum(xuetuId, gangInfo.wingLevel)
  local onlineXuetu, allXuetu = self.data:GetXuetuNumOnlineAllPromote()
  self.uiTbl.Label_StudentNum:GetComponent("UILabel"):set_text(string.format("%d/%d/%d", onlineXuetu, allXuetu, xuetuMax))
  local coffersTbl = GangUtility.GetCoffersGangBasicCfg(gangInfo.coffersLevel)
  local curRate = gangInfo.money / coffersTbl.gangMoneyLimit
  self.uiTbl.Img_BgSlider:GetComponent("UISlider"):set_sliderValue(curRate)
  self.uiTbl.Label_SliderNum:GetComponent("UILabel"):set_text(string.format("%d/%d", gangInfo.money, coffersTbl.gangMoneyLimit))
  local minRate = costMoney / coffersTbl.gangMoneyLimit
  local width = self.uiTbl.Img_BgSlider:GetComponent("UISprite"):get_width()
  minRate = minRate + 20 / width
  local pos_BgSlider = self.uiTbl.Img_BgSlider:get_localPosition()
  local posX = pos_BgSlider.x
  if minRate <= 0.5 then
    posX = posX - (0.5 - minRate) * width
  else
    if minRate > 1 then
      minRate = 1
    end
    posX = posX + minRate * width
  end
  local pos = self.uiTbl.Img_Arrow:get_localPosition()
  self.uiTbl.Img_Arrow:set_localPosition(Vector.Vector3.new(posX, pos.y, pos.z))
end
def.method().UpdateRedLabels = function(self)
  local ImgRedBuilding = self.uiTbl.Btn_HomeUp:FindDirect("Img_BgRed")
  local ImgRedApplicants = self.uiTbl.Btn_ApplyList:FindDirect("Img_BgRed")
  ImgRedBuilding:SetActive(GangUtility.NeedShowBuildNotice())
  ImgRedApplicants:SetActive(GangUtility.NeedShowApplyNotice())
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Manage" == id then
    self:OnManageGangClick()
  elseif "Btn_GangList" == id then
    self:OnGangListClick()
  elseif "Btn_HomeUp" == id then
    self:OnBuildingLvUpClick()
  elseif "Btn_ApplyList" == id then
    self:OnApplierListClick()
  elseif "Btn_MoneyTips" == id then
    self:OnMoneyTipsClick()
  elseif "Btn_ActivityTips" == id then
    self:OnActivityTipsClick()
  elseif "Img_Arrow" == id then
    self:OnArrowTipsClick()
  elseif "Label_MemberNum" == id or "Label_MemberName" == id then
    self:OnMemNumClick()
  elseif "Btn_Tip" == id then
    self:OnStuNumClick()
  elseif "Btn_OffGang" == id then
    self:OnQuitGangClick()
  elseif "Btn_TaamManage" == id then
    require("Main.Gang.GangTeam.ui.GangTeamPanel").Instance():ShowPanel()
  end
end
def.method().OnManageGangClick = function(self)
  local ManagementGangPanel = require("Main.Gang.ui.GangManagment.ManagementGangPanel")
  ManagementGangPanel.ShowManagementGangPanel(nil, 1)
end
def.method().OnGangListClick = function(self)
  require("Main.Gang.ui.GangListPanel").Instance():ShowPanel()
end
def.method().OnBuildingLvUpClick = function(self)
  local GangLevelUpPanel = require("Main.Gang.ui.GangLevelUp.GangLevelUpPanel")
  GangLevelUpPanel.ShowGangLevelUpPanel()
end
def.method().OnApplierListClick = function(self)
  local GangApplicantsPanel = require("Main.Gang.ui.GangApplicantsPanel")
  GangApplicantsPanel.Instance():ShowPanel()
end
def.method().OnMoneyTipsClick = function(self)
  local tipsId = GangUtility.GetGangConsts("GANG_MONEY_TIPS_ID")
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method().OnActivityTipsClick = function(self)
  local tipsId = GangUtility.GetGangConsts("GANG_LIVELY_TIPS_ID")
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method().OnArrowTipsClick = function(self)
  local tipsId = GangUtility.GetGangConsts("GANG_MONEY_ARROW_TIPS_ID")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipsId)
  local costMoney = self.data:GetMaintainCost()
  local content = string.format(tipContent, costMoney)
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tmpPosition = {x = 0, y = 0}
  CommonDescDlg.ShowCommonTip(content, tmpPosition)
end
def.method().OnMemNumClick = function(self)
  local tipsId = 701602012
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, -122, 127)
end
def.method().OnStuNumClick = function(self)
  local tipsId = 701602012
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, -122, 127)
end
def.static("number", "table").QuitGangCallback = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CQuitGangReq").new())
  end
end
def.method().OnQuitGangClick = function(self)
  local bangzhuId = GangUtility.GetGangConsts("BANGZHU_ID")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = self.data:GetMemberInfoByRoleId(heroProp.id)
  local memberList = self.data:GetMemberList()
  if memberInfo == nil then
    return
  end
  if memberInfo.duty == bangzhuId and #memberList > 1 then
    Toast(textRes.Gang[76])
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local tag = {id = self}
  CommonConfirmDlg.ShowConfirm("", textRes.Gang[75], GangAffairsNode.QuitGangCallback, tag)
end
def.static("table", "table").OnMemberUpdate = function(params, tbl)
  instance:FillAffairsInfo()
end
def.static("table", "table").OnMemberChange = function(params, tbl)
  instance:FillAffairsInfo()
end
def.static("table", "table").OnGangNoticeStatesChange = function(params, tbl)
  local node = params[1]
  local HaveGangPanel = require("Main.Gang.ui.HaveGangPanel")
  if node == HaveGangPanel.NodeId.AFFAIRS then
    instance:UpdateRedLabels()
  end
  instance.uiTbl.Img_BgRed:SetActive(GangData.Instance():IsHaveGangMergeApply())
end
def.static("table", "table").OnGangMoneyChange = function(params, tbl)
  instance:FillAffairsInfo()
end
def.static("table", "table").OnBuildComplete = function(params, tbl)
  instance:FillAffairsInfo()
end
def.static("table", "table").OnVitalityChange = function(params, tbl)
  instance:FillAffairsInfo()
end
def.static("table", "table").OnGangTeamRedDotChg = function(p, c)
  instance:_updateGangTeamRedDot()
end
GangAffairsNode.Commit()
return GangAffairsNode
