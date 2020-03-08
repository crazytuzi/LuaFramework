local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local DailySignInNode = Lplus.Extend(AwardPanelNodeBase, "DailySignInNode")
local ECMSDK = require("ProxySDK.ECMSDK")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local DailySignInMgr = require("Main.Award.mgr.DailySignInMgr")
local Vector = require("Types.Vector")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local GUIUtils = require("GUI.GUIUtils")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local AwardUtils = require("Main.Award.AwardUtils")
local def = DailySignInNode.define
def.field("number").selectedItem = 0
def.field("table").catchedTime = nil
def.field(AwardItemTipHelper).itemTipHelper = nil
def.field("table").awardList = nil
def.field("table").uiObjs = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
  self.awardType = GiftType.SIGN_GIFT
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_SIGN_IN_STATE_UPDATE, DailySignInNode.OnSignInStateUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_SIGN_IN_STATE_UPDATE, DailySignInNode.OnSignInStateUpdate)
  self:Clear()
end
def.override("=>", "boolean").IsOpen = function(self)
  return DailySignInMgr.Instance():IsOpen()
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  do break end
  do break end
  self:onClick(id)
end
def.override("string").onClick = function(self, id)
  self:UnSelectLastSelectedItem()
  if id == "Btn_Tips" then
    self:OnShowTipButtonClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif string.sub(id, 1, #"Group_Date_") == "Group_Date_" then
    local index = tonumber(string.sub(id, #"Group_Date_" + 1, -1))
    self:OnAwardItemClicked(index)
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return DailySignInMgr.Instance():IsHaveNotifyMessage()
end
def.override().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_BgTitle = self.m_node:FindDirect("Img_BgTitle")
  self.uiObjs.Label_Month = self.uiObjs.Img_BgTitle:FindDirect("Label_Month")
  self.uiObjs.Label_Qian = self.uiObjs.Img_BgTitle:FindDirect("Label_Qian")
  self.uiObjs.Label_BuQian = self.m_node:FindDirect("Label_BuQian")
  self.uiObjs.Group_WX = self.m_node:FindDirect("Group_Wechat")
  self.uiObjs.Group_QQ = self.m_node:FindDirect("Group_QQ")
  self.uiObjs.ScrollView = self.m_node:FindDirect("Scroll View")
  self.uiObjs.Grid = self.uiObjs.ScrollView:FindDirect("Grid")
  self.uiObjs.Group_Date_Template = self.uiObjs.Grid:FindDirect("Group_Date1")
  self.uiObjs.Group_Date_Template:SetActive(false)
  self.itemTipHelper = AwardItemTipHelper()
end
def.method().UpdateUI = function(self)
  local signInStates = DailySignInMgr.Instance():GetSignInStates()
  self.catchedTime = signInStates.date
  self.uiObjs.Label_Month:GetComponent("UILabel"):set_text(self.catchedTime.month)
  self.uiObjs.Label_Qian:GetComponent("UILabel"):set_text(signInStates.signedDays)
  self.uiObjs.Label_BuQian:GetComponent("UILabel"):set_text(signInStates.canRedressTimes)
  self:UpdateExtraAwardView()
  self:UpdateAwardList()
end
def.method().UpdateExtraAwardView = function(self)
  local groupQQ = self.uiObjs.Group_QQ
  local groupWX = self.uiObjs.Group_WX
  local loginTypeInfo, qqVipInfo = RelationShipChainMgr.GetPrivilegeAwardCfg()
  local vipLevel = RelationShipChainMgr.GetSepicalVIPLevel()
  GUIUtils.SetActive(groupQQ, _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(groupWX, ECMSDK.IsWXGameCenter() and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(groupQQ:FindDirect("Group_ExtraPrize"), vipLevel ~= 0)
  GUIUtils.SetActive(groupQQ:FindDirect("Group_ExtraPrize/Img_SvipIcon"), vipLevel == 2)
  GUIUtils.SetActive(groupQQ:FindDirect("Group_ExtraPrize/Img_VipIcon"), vipLevel == 1)
  GUIUtils.SetActive(groupQQ:FindDirect("Group_GameCenterPrize"), ECMSDK.IsQQGameCenter())
  if loginTypeInfo then
    GUIUtils.SetText(groupQQ:FindDirect("Group_GameCenterPrize/Label_GameCenterNumber"), tostring(loginTypeInfo.sign_extra_award_num))
    GUIUtils.SetText(groupWX:FindDirect("Label_ExtraNumber"), tostring(loginTypeInfo.sign_extra_award_num))
  end
  if qqVipInfo then
    GUIUtils.SetText(groupQQ:FindDirect("Group_ExtraPrize/Label_ExtraNumber"), tostring(qqVipInfo.sign_extra_award_num))
  end
end
def.method().UpdateAwardList = function(self)
  local awardList = DailySignInMgr.Instance():GetWholeMonthAwardList(self.catchedTime.year, self.catchedTime.month)
  self.awardList = awardList
  local signInStates = DailySignInMgr.Instance():GetSignInStates()
  self:SetAwardList(awardList, signInStates)
end
def.method("table", "table").SetAwardList = function(self, awardList, signInStates)
  self.itemTipHelper:Clear()
  for i, award in ipairs(awardList) do
    self:SetAwardItem(i, award, signInStates)
  end
  local MAX_GRID_ITEM = 31
  for i = MAX_GRID_ITEM, #awardList + 1, -1 do
    local gridItem = self.uiObjs.Grid:FindDirect("Group_Date_" .. i)
    if gridItem then
      GameObject.Destroy(gridItem)
    end
  end
  self.uiObjs.Grid:GetComponent("UIGrid"):Reposition()
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("number", "table", "table").SetAwardItem = function(self, index, award, signInStates)
  local gridItem = self.uiObjs.Grid:FindDirect("Group_Date_" .. index)
  if gridItem == nil then
    gridItem = GameObject.Instantiate(self.uiObjs.Group_Date_Template)
    gridItem.name = "Group_Date_" .. index
    gridItem:SetActive(true)
    gridItem.transform.parent = self.uiObjs.Grid.transform
    gridItem.transform.localScale = Vector.Vector3.one
  end
  gridItem:FindDirect("Img_KeLing"):SetActive(false)
  gridItem:FindDirect("Img_YiLing"):SetActive(false)
  gridItem:FindDirect("Img_BuQian"):SetActive(false)
  local Img_Days = gridItem:FindDirect("Img_Days")
  Img_Days:SetActive(false)
  if index % 5 == 0 then
    Img_Days:SetActive(true)
    local label = Img_Days:FindDirect("Label")
    if label then
      label:GetComponent("UILabel").text = string.format(textRes.Award[4], index)
    end
  end
  local itemId = award.itemId
  if not ItemUtils.GetItemBase(itemId) then
    local itemBase = {icon = 0, namecolor = 0}
  end
  local iconId = itemBase.icon
  local Img_BgIcon = gridItem:FindDirect("Img_BgIcon")
  local uiSprite = Img_BgIcon:GetComponent("UISprite")
  local itemName = itemBase.name
  local LabelName = gridItem:FindDirect("Label")
  GUIUtils.SetText(LabelName, itemName)
  local uiTexture = Img_BgIcon:FindDirect("Texture_Icon"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
  GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  local text = award.num > 1 and award.num or ""
  GUIUtils.SetText(Img_BgIcon:FindDirect("Label_Num"), text)
  if itemId ~= 0 then
    local quality = itemBase.namecolor
    uiSprite:set_spriteName(string.format("Cell_%02d", quality))
  end
  local canSign, canRedress
  if DailySignInMgr.Instance():IsSigned(index) then
    self:MarkAsSigned(gridItem, uiTexture, uiSprite)
  elseif DailySignInMgr.Instance():CanSigne(index) then
    self:MarkAsCanSigne(gridItem)
    self:DragToMakeVisible(self.uiObjs.ScrollView, gridItem, 24)
    canSign = true
  elseif DailySignInMgr.Instance():CanRedress(index) then
    self:MarkAsCanRedress(gridItem)
    self:DragToMakeVisible(self.uiObjs.ScrollView, gridItem, 24)
    if signInStates.isTodaySigned and DailySignInMgr.Instance():IsFirstRedressDay(index) then
      canRedress = true
    end
  end
  if itemId ~= 0 and not canSign and not canRedress then
    self.itemTipHelper:RegisterItem2ShowTip(itemId, gridItem)
  end
end
def.method("userdata", "userdata", "userdata").MarkAsSigned = function(self, gridItem, uiTexture, uiSprite)
  gridItem:FindDirect("Img_YiLing"):SetActive(true)
  GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  uiSprite.spriteName = "Cell_07"
end
def.method("userdata").MarkAsCanSigne = function(self, gridItem)
  GameUtil.AddGlobalTimer(0.5, true, function()
    if not _G.IsNil(gridItem) then
      gridItem:FindDirect("Img_KeLing"):SetActive(true)
    end
  end)
end
def.method("userdata").MarkAsCanRedress = function(self, gridItem)
  GameUtil.AddGlobalTimer(0.5, true, function()
    if not _G.IsNil(gridItem) then
      gridItem:FindDirect("Img_KeLing"):SetActive(true)
    end
  end)
  gridItem:FindDirect("Img_BuQian"):SetActive(true)
end
def.method("number").OnAwardItemClicked = function(self, index)
  local result = DailySignInMgr.Instance():SignInOrRedress(index)
  if result == DailySignInMgr.CResult.SUCCESS then
    DailySignInMgr.Instance():RegisterAwardNotice(index, self.awardList[index])
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.DAILYSIGN, {index})
  elseif result == DailySignInMgr.CResult.NOT_SIGN_IN or result == DailySignInMgr.CResult.NOT_FIRST_REDRESS_DAY then
    Toast(textRes.Award[61])
  end
  self.selectedItem = index
  self:SetItemToggleState(index, true)
end
def.method().OnShowTipButtonClicked = function(self)
  local tipId = AwardUtils.GetAwardConsts("TIP_ID")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.static("table", "table").OnSignInStateUpdate = function(params)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  local instance = AwardPanel.Instance().nodes[AwardPanel.NodeId.DailySignIn]
  instance:UpdateUI()
end
def.method().UnSelectLastSelectedItem = function(self)
  if self.selectedItem ~= 0 then
    self:SetItemToggleState(self.selectedItem, false)
    self.selectedItem = 0
  end
end
def.method("number", "boolean").SetItemToggleState = function(self, index, state)
  local uiToggle = self.uiObjs.Grid:FindDirect("Group_Date_" .. index):GetComponent("UIToggle")
  uiToggle.value = state
end
def.method().Clear = function(self)
  self:UnSelectLastSelectedItem()
  self.uiObjs = nil
  self.awardList = nil
end
return DailySignInNode.Commit()
