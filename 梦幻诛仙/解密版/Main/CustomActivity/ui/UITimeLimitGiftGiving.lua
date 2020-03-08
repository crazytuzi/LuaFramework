local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UITimeLimitGiftGiving = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = UITimeLimitGiftGiving
local def = Cls.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GiftActivityMgr = require("Main.CustomActivity.GiftActivityMgr")
local txtConst = textRes.customActivity
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._GiftBagInfo = nil
def.field("table")._GiftBagCfg = nil
def.field("table")._friendList = nil
def.field("table")._myGivingInfo = nil
def.field("table")._mapRcvrGiftInfo = nil
def.field("table")._currencyData = nil
def.const("table").LIST_TYPE = {TO_GIVE_LIST = 1, BE_GIVE_LIST = 2}
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.override().OnCreate = function(self)
  local giftBag = self._GiftBagInfo
  GiftActivityMgr.SendGetGiftInfoReq(giftBag.activityId, giftBag.id)
  self._uiGOs = self._uiGOs or {}
  self._uiStatus = self._uiStatus or {}
  self._uiStatus.curFocusList = Cls.LIST_TYPE.TO_GIVE_LIST
  self._uiStatus.selFriendIdx = 1
  self._uiStatus.bListDirty = false
  local uiGOs = self._uiGOs
  self._GiftBagCfg = require("Main.CustomActivity.CustomActivityInterface").GetTimeLimitedGiftBagCfg(self._GiftBagInfo.id)
  self._currencyData = CurrencyFactory.Create(self._GiftBagCfg.giftMoneyType)
  uiGOs.groupList = self.m_panel:FindDirect("Img_Bg/Group_List/Group_List")
  uiGOs.scrollView = uiGOs.groupList:FindDirect("Scrolllist")
  uiGOs.groupList:SetActive(true)
  uiGOs.uiList = uiGOs.scrollView:FindDirect("List")
  local lblTips = self.m_panel:FindDirect("Img_Bg/Label_Tips")
  GUIUtils.SetText(lblTips, txtConst[302]:format(self._GiftBagCfg.minFriendIntimacy))
  local rightBottom = self.m_panel:FindDirect("Img_Bg/Group_Info")
  uiGOs.groupInfo = rightBottom
  uiGOs.lblOwnCurrency = rightBottom:FindDirect("Img_BgHaveMoney/Label_HaveMoneyNum")
  uiGOs.imgCurrency = rightBottom:FindDirect("Img_BgHaveMoney/Img_HaveMoneyIcon")
  uiGOs.lblCostCurrency = rightBottom:FindDirect("Img_BgUseMoney/Label_UseMoneyNum")
  uiGOs.imgCostCurrency = rightBottom:FindDirect("Img_BgUseMoney/Img_UseMoneyIcon")
  uiGOs.lblCanGiveNum = rightBottom:FindDirect("List_Info/item_1/Label01")
  uiGOs.lblMaxGiveNum = rightBottom:FindDirect("List_Info/item_2/Label02")
  uiGOs.lblSigleMaxGiveNum = rightBottom:FindDirect("List_Info/item_3/Label03")
  local lblCanGiveName = rightBottom:FindDirect("List_Info/item_1/Label")
  local lblMaxGiveName = rightBottom:FindDirect("List_Info/item_2/Label")
  local lblP2PGiveName = rightBottom:FindDirect("List_Info/item_3/Label")
  GUIUtils.SetText(lblCanGiveName, txtConst[316])
  GUIUtils.SetText(lblMaxGiveName, txtConst[317])
  GUIUtils.SetText(lblP2PGiveName, txtConst[318])
  uiGOs.groupIcon = rightBottom:FindDirect("Group_Icon")
  local btnTab1 = self.m_panel:FindDirect("Img_Bg/Group_List/Group_Tab/Btn_Tab_1")
  btnTab1:GetComponent("UIToggle").value = true
  uiGOs.groupNoData = self.m_panel:FindDirect("Img_Bg/Group_List/Group_NoData")
  uiGOs.lblNoData = uiGOs.groupNoData:FindDirect("Img_Talk/Label")
  self:eventsRegist()
  self:initUI()
end
def.override().OnDestroy = function(self)
  self:eventsUnregist()
  self._uiGOs = nil
  self._uiStatus = nil
  self._GiftBagInfo = nil
  self._GiftBagCfg = nil
  self._myGivingInfo = nil
  self._mapRcvrGiftInfo = nil
  self._friendList = nil
end
def.method().eventsRegist = function(self)
  Event.RegisterEventWithContext(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIVING_INFO_OK, Cls.OnGetGivinInfoOK, self)
  Event.RegisterEventWithContext(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIVING_INFO_FAILED, Cls.OnGetGivinInfoFail, self)
  Event.RegisterEventWithContext(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GIVING_OK, Cls.OnGiveOK, self)
  Event.RegisterEventWithContext(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GIVING_FAILED, Cls.OnGiveFailed, self)
  if self._currencyData then
    self._currencyData:RegisterCurrencyChangedEvent(Cls.OnMoneyUpdate)
  end
end
def.method().eventsUnregist = function(self)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIVING_INFO_OK, Cls.OnGetGivinInfoOK)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIVING_INFO_FAILED, Cls.OnGetGivinInfoFail)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GIVING_OK, Cls.OnGiveOK)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GIVING_FAILED, Cls.OnGiveFailed)
  if self._currencyData then
    self._currencyData:UnregisterCurrencyChangedEvent(Cls.OnMoneyUpdate)
  end
  self._currencyData = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow and self._uiStatus.bListDirty then
    if self._uiStatus.curFocusList == Cls.LIST_TYPE.TO_GIVE_LIST then
      self:updateToGiveList()
    elseif self._uiStatus.curFocusList == Cls.LIST_TYPE.BE_GIVE_LIST then
      self:updateBeGivedList()
    end
    self._uiStatus.bListDirty = false
  end
end
def.method().initUI = function(self)
  self:updateToGiveList()
  self:updateItemInfo()
  self:updateRightMidInfo()
  self:updateCurrencyInfo()
end
def.method("userdata").updateSingleGiveInfo = function(self, roleid)
  if roleid == nil then
    return
  end
  for i = 1, #self._friendList do
    if roleid:eq(self._friendList[i].roleId) then
      local ctrlItem = self._uiGOs.friendList[i]
      local groupMyGive = ctrlItem:FindDirect("Group_MyGift_" .. i)
      local groupCanGive = ctrlItem:FindDirect("Group_AllGift_" .. i)
      groupMyGive:SetActive(false)
      groupCanGive:SetActive(false)
      local rcvinfo = self._mapRcvrGiftInfo[roleid:tostring()]
      if self._uiStatus.curFocusList == Cls.LIST_TYPE.TO_GIVE_LIST then
        groupCanGive:SetActive(true)
        do
          local lblCanGiveNum = groupCanGive:FindDirect("Label_GiftNum_" .. i)
          local countAvaliable = rcvinfo.receive_available
          if countAvaliable < 1 then
            countAvaliable = 0
          end
          GUIUtils.SetText(lblCanGiveNum, countAvaliable)
        end
        break
      end
      if self._uiStatus.curFocusList == Cls.LIST_TYPE.BE_GIVE_LIST then
        groupMyGive:SetActive(true)
        local lblmyGiveNum = groupMyGive:FindDirect("Label_GiftNum_" .. i)
        GUIUtils.SetText(lblmyGiveNum, txtConst[314]:format(rcvinfo.sender2receiver_count, self._GiftBagCfg.maxP2PCount))
      end
      break
    end
  end
end
def.method().updateToGiveList = function(self)
  local friendsList = self:getFiltedFriendList()
  friendsList = self:sortFriendsByCanGive(friendsList, self._mapRcvrGiftInfo)
  self._friendList = friendsList
  local ctrlFriendsList = GUIUtils.InitUIList(self._uiGOs.uiList, #friendsList)
  self._uiGOs.friendList = ctrlFriendsList
  local countFriendLsit = #friendsList
  if countFriendLsit > 0 then
    self._uiStatus.selFriendIdx = math.min(self._uiStatus.selFriendIdx, countFriendLsit)
  else
    self._uiStatus.selFriendIdx = 0
  end
  local selFriendIdx = self._uiStatus.selFriendIdx
  for i = 1, countFriendLsit do
    local friendInfo = friendsList[i]
    self:fillFriendInfo(ctrlFriendsList[i], friendInfo, i)
    local ctrlItem = ctrlFriendsList[i]
    local groupMyGive = ctrlItem:FindDirect("Group_MyGift_" .. i)
    local groupCanGive = ctrlItem:FindDirect("Group_AllGift_" .. i)
    groupMyGive:SetActive(false)
    groupCanGive:SetActive(true)
    local lblCanGiveNum = groupCanGive:FindDirect("Label_GiftNum_" .. i)
    if self._mapRcvrGiftInfo then
      local rcvinfo = self._mapRcvrGiftInfo[friendInfo.roleId:tostring()]
      local countAvaliable = rcvinfo.receive_available
      if countAvaliable < 1 then
        countAvaliable = 0
      end
      GUIUtils.SetText(lblCanGiveNum, countAvaliable)
    else
      GUIUtils.SetText(lblCanGiveNum, txtConst[303])
    end
    local comToggle = ctrlItem:FindDirect("Img_Bg_" .. i):GetComponent("UIToggle")
    if selFriendIdx == i then
      comToggle.value = true
    else
      comToggle.value = false
    end
  end
  if countFriendLsit < 1 then
    self._uiGOs.groupNoData:SetActive(true)
    GUIUtils.SetText(self._uiGOs.lblNoData, txtConst[302]:format(self._GiftBagCfg.minFriendIntimacy))
  else
    self._uiGOs.groupNoData:SetActive(false)
  end
end
def.method().updateBeGivedList = function(self)
  local friendsList = self:getFiltedFriendList()
  friendsList = self:sortFriendsByMyGive(friendsList, self._mapRcvrGiftInfo)
  self._friendList = friendsList
  local ctrlFriendsList = GUIUtils.InitUIList(self._uiGOs.uiList, #friendsList)
  self._uiGOs.friendList = ctrlFriendsList
  local countFriendLsit = #friendsList
  if countFriendLsit > 0 then
    self._uiStatus.selFriendIdx = math.min(self._uiStatus.selFriendIdx, countFriendLsit)
  else
    self._uiStatus.selFriendIdx = 0
  end
  local selFriendIdx = self._uiStatus.selFriendIdx
  for i = 1, countFriendLsit do
    local friendInfo = friendsList[i]
    self:fillFriendInfo(ctrlFriendsList[i], friendInfo, i)
    local ctrlItem = ctrlFriendsList[i]
    local groupMyGive = ctrlItem:FindDirect("Group_MyGift_" .. i)
    local groupCanGive = ctrlItem:FindDirect("Group_AllGift_" .. i)
    groupMyGive:SetActive(true)
    groupCanGive:SetActive(false)
    local lblmyGiveNum = groupMyGive:FindDirect("Label_GiftNum_" .. i)
    if self._mapRcvrGiftInfo then
      local rcvinfo = self._mapRcvrGiftInfo[friendInfo.roleId:tostring()]
      GUIUtils.SetText(lblmyGiveNum, txtConst[314]:format(rcvinfo.sender2receiver_count, self._GiftBagCfg.maxP2PCount))
    else
      GUIUtils.SetText(lblmyGiveNum, txtConst[303])
    end
    local comToggle = ctrlItem:FindDirect("Img_Bg_" .. i):GetComponent("UIToggle")
    if selFriendIdx == i then
      comToggle.value = true
    else
      comToggle.value = false
    end
  end
  if countFriendLsit < 1 then
    self._uiGOs.groupNoData:SetActive(true)
    GUIUtils.SetText(self._uiGOs.lblNoData, txtConst[321])
  else
    self._uiGOs.groupNoData:SetActive(false)
  end
end
def.method("userdata", "table", "number").fillFriendInfo = function(self, ctrl, friendInfo, idx)
  local infoRoot = ctrl:FindDirect("Group_PlayerInfo_" .. idx)
  local imgAvatar = infoRoot:FindDirect("Img_Head_" .. idx)
  local lblLv = imgAvatar:FindDirect("Label_Lv_" .. idx)
  local imgAvatarFrame = infoRoot:FindDirect("Img_AvatarFrame_" .. idx)
  local lblName = infoRoot:FindDirect("Label_Name_" .. idx)
  local lblBkupName = infoRoot:FindDirect("Label_BackName_" .. idx)
  local lblRelationVal = infoRoot:FindDirect("Label_CloseNum_" .. idx)
  local imgSex = infoRoot:FindDirect("Img_Sex_" .. idx)
  local imgOccup = infoRoot:FindDirect("Img_MenPai_" .. idx)
  GUIUtils.SetSprite(imgSex, GUIUtils.GetSexIcon(friendInfo.sex))
  GUIUtils.SetSprite(imgOccup, GUIUtils.GetOccupationSmallIcon(friendInfo.occupationId))
  _G.SetAvatarIcon(imgAvatar, friendInfo.avatarId or 0)
  _G.SetAvatarFrameIcon(imgAvatarFrame, friendInfo.avatarFrameId or 0)
  GUIUtils.SetText(lblLv, friendInfo.roleLevel)
  GUIUtils.SetText(lblName, friendInfo.roleName)
  local remarkName = txtConst[315]
  if friendInfo.remarkName ~= nil and friendInfo.remarkName ~= "" then
    remarkName = friendInfo.remarkName
  end
  GUIUtils.SetText(lblBkupName, remarkName)
  GUIUtils.SetText(lblRelationVal, friendInfo.relationValue)
end
def.method().updateItemInfo = function(self)
  local giftBag = self._GiftBagInfo
  local uiGOs = self._uiGOs
  local lblOriPrice = uiGOs.groupInfo:FindDirect("Group_Money/Img_YuanBaoOld/Label_Num")
  local lblCurPrice = uiGOs.groupInfo:FindDirect("Group_Money/Img_Cost/Label_Num")
  GUIUtils.SetText(lblOriPrice, giftBag.originalPrice)
  GUIUtils.SetText(lblCurPrice, giftBag.currentPrice)
  local Group_Icon = uiGOs.groupIcon
  local MAX_ICON_NUM = 4
  for i = 1, MAX_ICON_NUM do
    local giftObj = Group_Icon:FindDirect("Img_BgIcon" .. i)
    local giftInfo = giftBag.gifts[i]
    self:SetGiftInfo(giftObj, giftInfo, nil)
  end
  local lblBagName = uiGOs.groupInfo:FindDirect("Group_Name/Label_Name")
  GUIUtils.SetText(lblBagName, giftBag.name)
end
def.method("userdata", "table", "table").SetGiftInfo = function(self, giftObj, giftInfo, params)
  if giftInfo == nil then
    GUIUtils.SetActive(giftObj, false)
    return
  end
  GUIUtils.SetActive(giftObj, true)
  local Texture_Icon = giftObj:FindDirect("Texture_Icon")
  local Label_Num = giftObj:FindDirect("Label_Num")
  GUIUtils.SetTexture(Texture_Icon, giftInfo.iconId)
  GUIUtils.SetText(Label_Num, giftInfo.num)
  local namecolor = 0
  local itemBase = ItemUtils.GetItemBase(giftInfo.itemId)
  if itemBase then
    namecolor = itemBase.namecolor
  end
  GUIUtils.SetItemCellSprite(giftObj, namecolor)
end
def.method().updateRightMidInfo = function(self)
  local uiGOs = self._uiGOs
  if self._myGivingInfo == nil then
    GUIUtils.SetText(uiGOs.lblCanGiveNum, txtConst[303])
  else
    GUIUtils.SetText(uiGOs.lblCanGiveNum, txtConst[314]:format(self._myGivingInfo.send_available, self._GiftBagCfg.maxSendCount))
  end
  GUIUtils.SetText(uiGOs.lblMaxGiveNum, self._GiftBagCfg.maxSendCount)
  GUIUtils.SetText(uiGOs.lblSigleMaxGiveNum, self._GiftBagCfg.maxP2PCount)
end
def.method().updateCurrencyInfo = function(self)
  local currencyType = self._GiftBagCfg.giftMoneyType
  local currencyData = CurrencyFactory.Create(currencyType)
  local ownCurrency
  if currencyType == MoneyType.YUANBAO then
    ownCurrency = ItemModule.Instance():getCashYuanBao()
  else
    ownCurrency = ItemModule.Instance():GetCurrencyNumByType(currencyType)
  end
  local uiGOs = self._uiGOs
  GUIUtils.SetText(uiGOs.lblOwnCurrency, ownCurrency:tostring())
  GUIUtils.SetSprite(uiGOs.imgCurrency, currencyData:GetSpriteName())
  GUIUtils.SetText(uiGOs.lblCostCurrency, self._GiftBagCfg.giftPrice)
  GUIUtils.SetSprite(uiGOs.imgCostCurrency, currencyData:GetSpriteName())
end
def.method("table").ShowPanel = function(self, giftBagInfo)
  if self:IsShow() then
    return
  end
  if giftBagInfo == nil then
    return
  end
  self._GiftBagInfo = giftBagInfo
  self:CreatePanel(RESPATH.PREFAB_GIFT_GIVING, 1)
  self:SetModal(true)
end
def.method("=>", "table").getFiltedFriendList = function(self)
  local friendData = require("Main.friend.FriendData").Instance()
  local friendList = friendData:GetFriendList()
  local retFriends = {}
  local minRelationVal = self._GiftBagCfg.minFriendIntimacy
  for i = 1, #friendList do
    local friendInfo = friendList[i]
    if minRelationVal <= friendInfo.relationValue then
      table.insert(retFriends, friendInfo)
    end
  end
  return retFriends
end
def.method("table", "table", "=>", "table").sortFriendsByMyGive = function(self, friendList, sortInfo)
  if friendList == nil or sortInfo == nil then
    return friendList or {}
  end
  local maxRcvCount = self._GiftBagCfg.maxP2PCount
  local filtedList = {}
  for i = 1, #friendList do
    local friendInfo = friendList[i]
    local strRoleId = friendInfo.roleId:tostring()
    if sortInfo[strRoleId] ~= nil and sortInfo[strRoleId].sender2receiver_count > 0 then
      table.insert(filtedList, friendInfo)
    end
  end
  table.sort(filtedList, function(a, b)
    local aRcvMeCount = sortInfo[a.roleId:tostring()].sender2receiver_count
    local bRcvMeCount = sortInfo[b.roleId:tostring()].sender2receiver_count
    if aRcvMeCount >= maxRcvCount and bRcvMeCount < maxRcvCount then
      return false
    elseif aRcvMeCount < maxRcvCount and bRcvMeCount >= maxRcvCount then
      return true
    else
      return a.relationValue > b.relationValue
    end
  end)
  return filtedList
end
def.method("table", "table", "=>", "table").sortFriendsByCanGive = function(self, friendList, sortInfo)
  if friendList == nil or sortInfo == nil then
    return friendList or {}
  end
  local filtedList = {}
  for i = 1, #friendList do
    local friendInfo = friendList[i]
    local strRoleId = friendInfo.roleId:tostring()
    if sortInfo[strRoleId] ~= nil then
      table.insert(filtedList, friendInfo)
    end
  end
  table.sort(filtedList, function(a, b)
    local aRcvCount = sortInfo[a.roleId:tostring()].receive_available
    local bRcvCount = sortInfo[b.roleId:tostring()].receive_available
    if aRcvCount <= 0 and bRcvCount > 0 then
      return false
    elseif aRcvCount > 0 and bRcvCount <= 0 then
      return true
    else
      return a.relationValue > b.relationValue
    end
  end)
  return filtedList
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Btn_Refresh" == id then
    self:onClickBtnRefresh()
  elseif "Btn_Give" == id then
    self:onClickBtnGiving()
  elseif "Btn_Add" == id then
    self:onClickBtnBuyCurrency()
  elseif "Btn_Help" == id then
    self:onClickBtnHoverTips()
  elseif "Btn_Tab_1" == id then
    self:onClickShow2GiveList()
  elseif "Btn_Tab_2" == id then
    self:onClickShowBeGivedList()
  elseif string.find(id, "Img_BgIcon") then
    self:onClickItemIcon(clickObj)
  elseif string.find(id, "Img_Bg_") then
    local idx = tonumber(string.split(id, "_")[3])
    self._uiStatus.selFriendIdx = idx
  end
end
def.method().onClickBtnRefresh = function(self)
  local giftBag = self._GiftBagInfo
  GiftActivityMgr.SendGetGiftInfoReq(giftBag.activityId, giftBag.id)
end
def.method().onClickBtnGiving = function(self)
  local giftBag = self._GiftBagInfo
  if not GiftActivityMgr.IsGiftGivingFeatureOpen() then
    Toast(txtConst[313])
    return
  end
  local isOpen = require("Main.activity.ActivityInterface").Instance():isActivityOpend(giftBag.activityId)
  if not isOpen then
    Toast(txtConst[319])
    return
  end
  local friendInfo = self._friendList[self._uiStatus.selFriendIdx]
  if friendInfo == nil then
    Toast(txtConst[304])
    return
  end
  if self._myGivingInfo.send_available < 1 then
    Toast(txtConst[305])
    return
  end
  local rcvGiftInfo = self._mapRcvrGiftInfo[friendInfo.roleId:tostring()]
  if 1 > rcvGiftInfo.receive_available then
    Toast(txtConst[306]:format(giftBag.name))
    return
  end
  if rcvGiftInfo.sender2receiver_count >= self._GiftBagCfg.maxP2PCount then
    Toast(txtConst[307]:format(giftBag.name))
    return
  end
  local currencyType = self._GiftBagCfg.giftMoneyType
  local ownCurrency
  if currencyType == MoneyType.YUANBAO then
    ownCurrency = ItemModule.Instance():getCashYuanBao()
  else
    ownCurrency = ItemModule.Instance():GetCurrencyNumByType(currencyType)
  end
  if ownCurrency:lt(self._GiftBagCfg.giftPrice) then
    ItemModule.GotoChargeByCurrencyType(currencyType, true)
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local content = txtConst[308]:format(self._GiftBagCfg.giftPrice, giftBag.name, friendInfo.roleName)
  CommonConfirmDlg.ShowConfirm(txtConst[309], content, function(select)
    if select == 1 then
      GiftActivityMgr.CGiveGiftReq(giftBag.activityId, giftBag.id, friendInfo.roleId)
    end
  end, nil)
end
def.method().onClickBtnBuyCurrency = function(self)
  if self._GiftBagCfg.giftMoneyType == MoneyType.YUANBAO then
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  else
    ItemModule.GotoChargeByCurrencyType(self._GiftBagCfg.giftMoneyType, false)
  end
end
def.method().onClickBtnHoverTips = function(self)
  GUIUtils.ShowHoverTip(constant.CTimeLimitGiftBagConsts.GIFT_HOVER_TIP_ID, 0, 0)
end
def.method().onClickShow2GiveList = function(self)
  if self._uiStatus.curFocusList == Cls.LIST_TYPE.TO_GIVE_LIST then
    return
  end
  self._uiStatus.curFocusList = Cls.LIST_TYPE.TO_GIVE_LIST
  self._uiStatus.selFriendIdx = self._uiStatus.lastSelFriendIdx or 1
  self:updateToGiveList()
end
def.method().onClickShowBeGivedList = function(self)
  if self._uiStatus.curFocusList == Cls.LIST_TYPE.BE_GIVE_LIST then
    return
  end
  self._uiStatus.lastSelFriendIdx = self._uiStatus.selFriendIdx
  self._uiStatus.selFriendIdx = 1
  self._uiStatus.curFocusList = Cls.LIST_TYPE.BE_GIVE_LIST
  self:updateBeGivedList()
end
def.method("userdata").onClickItemIcon = function(self, clickObj)
  local id = clickObj.name
  local giftIndex = tonumber(string.sub(id, #"Img_BgIcon" + 1, -1))
  if giftIndex == nil then
    return
  end
  local giftBag = self._GiftBagInfo
  local gift = giftBag.gifts[giftIndex]
  local itemId = gift.itemId
  if itemId == nil then
    return
  end
  require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(itemId, clickObj, 0, false)
end
def.method("table").OnGetGivinInfoOK = function(self, p)
  self._myGivingInfo = self._myGivingInfo or {}
  self._myGivingInfo.send_available = p.send_available
  self._mapRcvrGiftInfo = self._mapRcvrGiftInfo or {}
  for roleid, rcvInfo in pairs(p.receiver_gift_info_map) do
    self._mapRcvrGiftInfo[roleid:tostring()] = rcvInfo
  end
  self:updateRightMidInfo()
  if not self:IsShow() then
    self._uiStatus.bListDirty = true
    return
  end
  if self._uiStatus.curFocusList == Cls.LIST_TYPE.TO_GIVE_LIST then
    self:updateToGiveList()
  else
    self:updateBeGivedList()
  end
end
def.method("table").OnGetGivinInfoFail = function(self, p)
  if p.activity_id == self._GiftBagInfo.activityId then
    self:DestroyPanel()
  end
end
def.method("table").OnGiveOK = function(self, p)
  if self._GiftBagInfo.activityId == p.activity_id then
    self._myGivingInfo = self._myGivingInfo or {}
    self._myGivingInfo.send_available = p.send_available
    self._mapRcvrGiftInfo[p.receiver_id:tostring()] = p.receiver_gift_info
    self:updateSingleGiveInfo(p.receiver_id)
    self:updateRightMidInfo()
  end
end
def.method("table").OnGiveFailed = function(self, p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.qingfu.SGiftError")
  if p.code == ERROR_CODE.RECEIVER_REACH_MAX then
    self._mapRcvrGiftInfo[p.receiver_id:tostring()] = p.receiver_gift_info
    self:updateSingleGiveInfo(p.receiver_id)
  elseif p.code == ERROR_CODE.SENDER_REACH_MAX then
    self._myGivingInfo.send_available = 0
    self:updateRightMidInfo()
  elseif p.code == ERROR_CODE.P2P_REACH_MAX then
    self._mapRcvrGiftInfo[p.receiver_id:tostring()] = p.receiver_gift_info
    self:updateSingleGiveInfo(p.receiver_id)
  elseif p.code == ERROR_CODE.INTIMACY_LOW then
    if not self:IsShow() then
      self._uiStatus.bListDirty = true
      return
    end
    if self._uiStatus.curFocusList == Cls.LIST_TYPE.TO_GIVE_LIST then
      self:updateToGiveList()
    else
      self:updateBeGivedList()
    end
  elseif p.code == ERROR_CODE.MONEY_NOT_ENOUGH then
    self:updateCurrencyInfo()
  end
end
def.static("table", "table").OnMoneyUpdate = function(p, c)
  instance:updateCurrencyInfo()
end
return Cls.Commit()
