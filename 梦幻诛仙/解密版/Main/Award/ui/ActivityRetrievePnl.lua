local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ActivityRetrievePnl = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Cls = ActivityRetrievePnl
local def = Cls.define
local instance
local RetrieveUtils = require("Main.Award.ActivityRetrieve.ActivityRetrieveUtils")
local RetrieveMgr = require("Main.Award.mgr.ActivityRetrieveMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.Award.ActivityRetrieve
local const = constant.CActivityCompensateConsts
def.field("table")._uiStatus = nil
def.field("table")._uiGOs = nil
def.field("table")._allActivities = nil
def.field("table")._curActivities = nil
def.field("table")._activitiesGroup = nil
local GetType = require("netio.protocol.mzm.gsp.activitycompensate.CGetAllAwardReq")
def.const("table").RETRIEVE_TYPE = {
  FREE = GetType.GET_TYPE_FREE,
  GOLD = GetType.GET_TYPE_GOLD,
  YUANBAO = GetType.GET_TYPE_YUANBAO
}
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().eventsRegist = function(self)
  Event.RegisterEventWithContext(ModuleId.AWARD, gmodule.notifyId.Award.ACTIVITY_RETRIEVE_SUCCESS, Cls.OnRetrieveSuccess, self)
  Event.RegisterEventWithContext(ModuleId.AWARD, gmodule.notifyId.Award.EASY_RETRIEVE_SUCCESS, Cls.OnEasyRetrieveSuccess, self)
  Event.RegisterEventWithContext(ModuleId.AWARD, gmodule.notifyId.Award.ACTIVITY_RETRIEVE_INFO_CHG, Cls.OnRetrieveInfoChg, self)
end
def.method().eventsUnregist = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACTIVITY_RETRIEVE_SUCCESS, Cls.OnRetrieveSuccess)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.EASY_RETRIEVE_SUCCESS, Cls.OnEasyRetrieveSuccess)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACTIVITY_RETRIEVE_INFO_CHG, Cls.OnRetrieveInfoChg)
end
def.override().OnCreate = function(self)
  self.m_TrigGC = true
  self._activitiesGroup = {}
  self._uiStatus = {}
  self._uiGOs = {}
  self._allActivities = {}
  self._uiStatus.selGroupType = self:ReadRetrieveType()
  self:eventsRegist()
  local uiGOs = self._uiGOs
  uiGOs.scrollView = self.m_panel:FindDirect("Group_ActivityGetBack/Group_Item/Scrollview_Item")
  uiGOs.uiList = uiGOs.scrollView:FindDirect("List_Item")
  local btnTab = self.m_panel:FindDirect("Group_ActivityGetBack/Group_BtnList/Btn_Free")
  if self._uiStatus.selGroupType == Cls.RETRIEVE_TYPE.GOLD then
    btnTab = self.m_panel:FindDirect("Group_ActivityGetBack/Group_BtnList/Btn_JinBi")
  elseif self._uiStatus.selGroupType == Cls.RETRIEVE_TYPE.YUANBAO then
    btnTab = self.m_panel:FindDirect("Group_ActivityGetBack/Group_BtnList/Btn_YuanBao")
  end
  btnTab:GetComponent("UIToggle").value = true
  uiGOs.texLeft = self.m_panel:FindDirect("Group_ActivityGetBack/Group_SaleNum/Texture")
  uiGOs.groupNoData = self.m_panel:FindDirect("Group_ActivityGetBack/Group_NoData")
  GUIUtils.SetText(uiGOs.groupNoData:FindDirect("Img_Talk/Label"), txtConst[9])
  uiGOs.lblDblPt = self.m_panel:FindDirect("Group_ActivityGetBack/Group_Point/Label_Point")
  GUIUtils.SetText(uiGOs.lblDblPt, self:GetDoublePt())
  uiGOs.imgDblPt = self.m_panel:FindDirect("Group_ActivityGetBack/Group_Point/Img_Use")
  uiGOs.imgDblPt:GetComponent("UIToggle").value = self:ReadToggleState()
end
def.override().OnDestroy = function(self)
  self:eventsUnregist()
  self:SaveToggleState()
  self:SaveRetrieveType()
  if self._uiStatus.bSort and self._uiStatus.bSort == true then
    for _, retrieveType in pairs(Cls.RETRIEVE_TYPE) do
      local list = self._activitiesGroup[retrieveType] or {}
      RetrieveMgr.GetData():SortActivities(list)
    end
  end
  self._uiStatus = nil
  self._uiGOs = nil
  self._allActivities = nil
  self._curActivities = nil
  self._activitiesGroup = nil
end
def.method()._initUI = function(self)
  if self._curActivities == nil then
    self:GetOpenActivities()
  end
  self:initUIRetrieveList()
end
def.method().initUIRetrieveList = function(self)
  GUIUtils.SetText(self._uiGOs.lblDblPt, self:GetDoublePt())
  local groupType = self._uiStatus.selGroupType
  local retrieveList = self._activitiesGroup[groupType] or {}
  local ctrlUIList = self._uiGOs.uiList
  local ctrlUIActList = GUIUtils.InitUIList(ctrlUIList, #retrieveList)
  self._uiGOs.ctrlUIActList = ctrlUIActList
  for i = 1, #ctrlUIActList do
    self:fillRetrieveInfo(ctrlUIActList[i], retrieveList[i], groupType, i)
  end
  self._uiGOs.groupNoData:SetActive(#ctrlUIActList < 1)
  local texId = const.FreeIcon
  if groupType == Cls.RETRIEVE_TYPE.FREE then
    texId = const.FreeIcon
  elseif groupType == Cls.RETRIEVE_TYPE.GOLD then
    texId = const.GoldIcon
  elseif groupType == Cls.RETRIEVE_TYPE.YUANBAO then
    texId = const.YuanbaoIcon
  end
  GUIUtils.SetTexture(self._uiGOs.texLeft, texId)
end
def.method("userdata", "table", "number", "number").fillRetrieveInfo = function(self, ctrl, info, groupType, idx)
  local lblActName = ctrl:FindDirect("Label_ActName_" .. idx)
  local lblExpVal = ctrl:FindDirect(("Group_Exp_%d/Label_ExpNum_%d"):format(idx, idx))
  local imgAward = ctrl:FindDirect(("Img_BgIcon_%d"):format(idx))
  imgAward = imgAward:FindChildByPrefix("Img_Icon_" .. idx)
  local groupCost = ctrl:FindDirect("Group_Cost_" .. idx)
  local lblCostName = groupCost:FindDirect("Label_CostName_" .. idx)
  local lblCostVal = groupCost:FindDirect("Label_CostNum_" .. idx)
  local imgCurrency = groupCost:FindDirect("Img_Icon_" .. idx)
  local btnGetBk = groupCost:FindDirect("Btn_GetBack_" .. idx)
  local imgFinish = ctrl:FindDirect("Img_Finish_" .. idx)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local actCfg = ActivityInterface.GetActivityCfgById(info.activityid)
  local retrieveInfo = RetrieveMgr.GetData():GetActivityInfo(info.activityid)
  GUIUtils.SetText(lblActName, txtConst[3]:format(actCfg.activityName, retrieveInfo.times))
  local retrieveCfg = RetrieveUtils.GetRetrieveActivityById(info.activityid)
  local costAndGetInfo = self:GetRetrieveInfoByGroupType(retrieveCfg, retrieveInfo, groupType)
  local totolExp = retrieveInfo.times * costAndGetInfo.exp
  GUIUtils.SetText(lblExpVal, totolExp)
  local itemBase = costAndGetInfo.itemBase
  GUIUtils.SetTexture(imgAward, itemBase.icon)
  imgAward.name = string.format("Img_Icon_%d_%d", idx, itemBase.itemid)
  local currencyData = costAndGetInfo.currencyData
  imgCurrency:SetActive(currencyData ~= nil)
  lblCostName:SetActive(false)
  if currencyData == nil then
    GUIUtils.SetText(lblCostVal, txtConst[1])
  else
    GUIUtils.SetText(lblCostName, txtConst[2])
    GUIUtils.SetSprite(imgCurrency, currencyData:GetSpriteName())
    local totalCurrency = costAndGetInfo.currencyNum
    GUIUtils.SetText(lblCostVal, totalCurrency)
  end
  imgFinish:SetActive(retrieveInfo.times < 1)
  btnGetBk:SetActive(retrieveInfo.times > 0)
end
def.method("table", "table", "number", "=>", "table").GetRetrieveInfoByGroupType = function(self, cfg, info, groupType)
  if cfg == nil then
    return nil
  end
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local retData = {}
  if groupType == Cls.RETRIEVE_TYPE.FREE then
    retData.itemBase = ItemUtils.GetItemBase(cfg.freeItemid)
    retData.exp = info.free_exp
  elseif groupType == Cls.RETRIEVE_TYPE.GOLD then
    retData.currencyData = CurrencyFactory.Create(MoneyType.GOLD)
    retData.currencyNum = cfg.gold
    retData.itemBase = ItemUtils.GetItemBase(cfg.goldItemid)
    retData.exp = info.gold_exp
  elseif groupType == Cls.RETRIEVE_TYPE.YUANBAO then
    retData.currencyData = CurrencyFactory.Create(MoneyType.YUANBAO)
    retData.currencyNum = cfg.yuanbao
    retData.itemBase = ItemUtils.GetItemBase(cfg.yuanbaoItemid)
    retData.exp = info.yuanbao_exp
  end
  return retData
end
def.method("number").updateUIRetrieveItemByActId = function(self, actId)
  GUIUtils.SetText(self._uiGOs.lblDblPt, self:GetDoublePt())
  local groupType = self._uiStatus.selGroupType
  local retrieveList = self._activitiesGroup[groupType] or {}
  for i = 1, #retrieveList do
    if retrieveList[i].activityid == actId then
      if 1 > retrieveList[i].times then
        self._uiStatus.bSort = true
        self:initUIRetrieveList()
        break
      end
      self:fillRetrieveInfo(self._uiGOs.ctrlUIActList[i], retrieveList[i], groupType, i)
      break
    end
  end
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:_initUI()
  end
end
def.method().ShowPanel = function(self)
  if self and not _G.IsNil(self.m_panel) then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_PNL_ACT_RETRIEVE, 0)
end
def.method("=>", "table").GetOpenActivities = function(self)
  local allActivities = RetrieveMgr.GetData():GetRetrieveList()
  warn("======>allActivities", #allActivities)
  self._curActivities = self._curActivities or {}
  self._activitiesGroup = {}
  for i = 1, #allActivities do
    local retrieveAct = allActivities[i]
    table.insert(self._curActivities, retrieveAct)
    local retrieveCfg = RetrieveUtils.GetRetrieveActivityById(retrieveAct.activityid)
    retrieveAct.id = retrieveCfg.id
    local groupType = 0
    if retrieveCfg.freeItemid ~= 0 then
      groupType = Cls.RETRIEVE_TYPE.FREE
      self:pushToGroup(groupType, retrieveAct)
    end
    if retrieveCfg.goldItemid ~= 0 then
      groupType = Cls.RETRIEVE_TYPE.GOLD
      self:pushToGroup(groupType, retrieveAct)
    end
    if retrieveCfg.yuanbaoItemid ~= 0 then
      groupType = Cls.RETRIEVE_TYPE.YUANBAO
      self:pushToGroup(groupType, retrieveAct)
    end
  end
  RetrieveMgr.GetData():SetRetrieveGroup(self._activitiesGroup)
  return self._curActivities
end
def.method("number", "table").pushToGroup = function(self, groupType, retrieveCfg)
  local group = self._activitiesGroup[groupType]
  if group == nil then
    group = {}
    table.insert(group, retrieveCfg)
    self._activitiesGroup[groupType] = group
    return
  end
  table.insert(group, retrieveCfg)
end
def.method("number", "=>", "userdata").GetOwnCurrency = function(self, currencyType)
  local ItemModule = require("Main.Item.ItemModule")
  if currencyType == MoneyType.YUANBAO then
    return ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
  else
    if currencyType == MoneyType.SILVER then
      currencyType = ItemModule.MONEY_TYPE_SILVER
    elseif currencyType == MoneyType.GOLD then
      currencyType = ItemModule.MONEY_TYPE_GOLD
    elseif currencyType == MoneyType.GOLD_INGOT then
      currencyType = ItemModule.MONEY_TYPE_GOLD_INGOT
    end
    return ItemModule.Instance():GetMoney(currencyType) or Int64.new(0)
  end
end
def.method("table", "number", "=>", "number").totalCostByGrouptype = function(self, retrieveList, groupType)
  local retData = 0
  if retrieveList == nil then
    return retData
  end
  for i = 1, #retrieveList do
    local retrieveAct = retrieveList[i]
    local retrieveCfg = RetrieveUtils.GetRetrieveActivityById(retrieveAct.activityid)
    if groupType == Cls.RETRIEVE_TYPE.GOLD then
      retData = retData + retrieveCfg.gold * retrieveAct.times
    elseif groupType == Cls.RETRIEVE_TYPE.YUANBAO then
      retData = retData + retrieveCfg.yuanbao * retrieveAct.times
    end
  end
  return retData
end
def.method("=>", "number").GetDoublePt = function(self)
  local DoublePointData = require("Main.OnHook.DoublePointData")
  local doublePoint = DoublePointData.Instance():GetGetingPoolPointNum()
  local frozenPoint = DoublePointData.Instance():GetFrozenPoolPointNum()
  doublePoint = frozenPoint + doublePoint
  return doublePoint
end
def.method("=>", "boolean").IsUseDoublePt = function(self)
  return self._uiGOs.imgDblPt:GetComponent("UIToggle").value
end
local keyUseDblPt = "ActivityRetrieve_IsUseDblPt"
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
def.method("=>", "boolean").ReadToggleState = function(self)
  local str = LuaPlayerPrefs.GetRoleString(keyUseDblPt)
  return string.find(str, "true") ~= nil
end
def.method().SaveToggleState = function(self)
  LuaPlayerPrefs.SetRoleString(keyUseDblPt, tostring(self:IsUseDoublePt()))
end
local keyLastRetrieveType = "ActivityRetrieve_LastRetrieveType"
def.method("=>", "number").ReadRetrieveType = function(self)
  local str = LuaPlayerPrefs.GetRoleString(keyLastRetrieveType)
  if str and str ~= "" then
    return tonumber(str)
  else
    return Cls.RETRIEVE_TYPE.FREE
  end
end
def.method().SaveRetrieveType = function(self)
  LuaPlayerPrefs.SetRoleString(keyLastRetrieveType, tostring(self._uiStatus.selGroupType))
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("id", id)
  if "Btn_Free" == id then
    self._uiStatus.selGroupType = Cls.RETRIEVE_TYPE.FREE
    self:initUIRetrieveList()
  elseif "Btn_JinBi" == id then
    self._uiStatus.selGroupType = Cls.RETRIEVE_TYPE.GOLD
    self:initUIRetrieveList()
  elseif "Btn_YuanBao" == id then
    self._uiStatus.selGroupType = Cls.RETRIEVE_TYPE.YUANBAO
    self:initUIRetrieveList()
  elseif "Btn_One" == id then
    self:OnClickBtnEasyRetrieve()
  elseif "Btn_Help" == id then
    GUIUtils.ShowHoverTip(const.tips, 0, 0)
  elseif "Img_Use" == id then
    if clickObj:GetComponent("UIToggle").value then
      Toast(txtConst[12])
    end
  elseif string.find(id, "Img_BgIcon_") then
    local child = clickObj:FindChildByPrefix("Img_Icon_")
    local strs = string.split(child.name, "_")
    local itemId = tonumber(strs[4])
    self:OnClickAwardItem(clickObj, itemId)
  elseif string.find(id, "Btn_GetBack_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:OnClickBtnRetrieve(idx)
  end
end
def.method().OnClickBtnEasyRetrieve = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local selGroupType = self._uiStatus.selGroupType
  if selGroupType ~= Cls.RETRIEVE_TYPE.FREE then
    local retrieveList = self._activitiesGroup[selGroupType] or {}
    local totalCurrency = self:totalCostByGrouptype(retrieveList, selGroupType)
    local ownCurrency = 0
    local currencyData
    if selGroupType == Cls.RETRIEVE_TYPE.GOLD then
      ownCurrency = self:GetOwnCurrency(MoneyType.GOLD)
      currencyData = CurrencyFactory.Create(MoneyType.GOLD)
      if ownCurrency:lt(totalCurrency) then
        Toast(txtConst[5]:format(currencyData:GetName()))
        return
      end
    elseif selGroupType == Cls.RETRIEVE_TYPE.YUANBAO then
      ownCurrency = self:GetOwnCurrency(MoneyType.YUANBAO)
      currencyData = CurrencyFactory.Create(MoneyType.YUANBAO)
      if ownCurrency:lt(totalCurrency) then
        Toast(txtConst[5]:format(currencyData:GetName()))
        return
      end
    end
    local content = txtConst[7]:format(totalCurrency, currencyData:GetName())
    if #retrieveList < 1 then
      Toast(txtConst[9])
      return
    end
    CommonConfirmDlg.ShowConfirm(txtConst[6], content, function(select)
      if select == 1 then
        RetrieveMgr.SendEasyGetAllAwards(selGroupType, self:IsUseDoublePt())
      end
    end, nil)
  else
    CommonConfirmDlg.ShowConfirm(txtConst[6], txtConst[11], function(select)
      if select == 1 then
        RetrieveMgr.SendEasyGetAllAwards(selGroupType, self:IsUseDoublePt())
      end
    end, nil)
  end
end
def.method("userdata", "number").OnClickAwardItem = function(self, clickObj, itemId)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, clickObj, 0, false)
end
def.method("number").OnClickBtnRetrieve = function(self, idx)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local selGroupType = self._uiStatus.selGroupType
  local selRetrieveAct = self._activitiesGroup[selGroupType][idx]
  if selRetrieveAct == nil then
    return
  end
  local retrieveCfg = RetrieveUtils.GetRetrieveActivityById(selRetrieveAct.activityid)
  local costAndGetInfo = self:GetRetrieveInfoByGroupType(retrieveCfg, selRetrieveAct, selGroupType)
  if selRetrieveAct.times < 1 then
    Toast(txtConst[4])
    return
  end
  if selGroupType ~= Cls.RETRIEVE_TYPE.FREE then
    local ownCurrency
    if selGroupType == Cls.RETRIEVE_TYPE.GOLD then
      ownCurrency = self:GetOwnCurrency(MoneyType.GOLD)
    elseif selGroupType == Cls.RETRIEVE_TYPE.YUANBAO then
      ownCurrency = self:GetOwnCurrency(MoneyType.YUANBAO)
    end
    if ownCurrency:lt(costAndGetInfo.currencyNum) then
      Toast(txtConst[5]:format(costAndGetInfo.currencyData:GetName()))
      return
    end
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local actCfg = ActivityInterface.GetActivityCfgById(retrieveCfg.actId)
    local content = txtConst[8]:format(costAndGetInfo.currencyNum, costAndGetInfo.currencyData:GetName(), actCfg.activityName)
    CommonConfirmDlg.ShowConfirm(txtConst[6], content, function(select)
      if select == 1 then
        RetrieveMgr.SendGetAwardReq(retrieveCfg.actId, selGroupType, selRetrieveAct.times, self:IsUseDoublePt())
      end
    end, nil)
  else
    RetrieveMgr.SendGetAwardReq(retrieveCfg.actId, selGroupType, selRetrieveAct.times, self:IsUseDoublePt())
  end
end
def.method("table").OnRetrieveSuccess = function(self, p)
  self:updateUIRetrieveItemByActId(p.actId)
end
def.method("table").OnEasyRetrieveSuccess = function(self, p)
  if self:IsShow() and self._uiStatus.selGroupType == p.getType then
    self:initUIRetrieveList()
  end
end
def.method("table").OnRetrieveInfoChg = function(self, p)
  if self:IsShow() then
    self:GetOpenActivities()
    self:initUIRetrieveList()
  end
end
return Cls.Commit()
