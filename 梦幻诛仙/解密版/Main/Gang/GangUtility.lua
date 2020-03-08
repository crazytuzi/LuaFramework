local Lplus = require("Lplus")
local GangUtility = Lplus.Class("GangUtility")
local Vector = require("Types.Vector")
local def = GangUtility.define
local instance
def.field("table").constTbl = nil
def.const("string").GANG_SIGN_NOTICE_TOUCHED_DAY = "GangSignNoticeTouched"
def.field("table").gangActivityRedPoint = nil
def.static("=>", GangUtility).Instance = function()
  if nil == instance then
    instance = GangUtility()
    instance.constTbl = {}
    instance:InitConstTbl()
  end
  return instance
end
def.method().InitConstTbl = function(self)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_CONST_CFG, "GANG_BUILD_SYNC_INTERVAL_M")
  self.constTbl.gangBuildSyncInterval = DynamicRecord.GetIntValue(record, "value")
end
def.method("number").AddGangActivityRedPoint = function(self, activityId)
  if self.gangActivityRedPoint == nil then
    self.gangActivityRedPoint = {}
  end
  self.gangActivityRedPoint[activityId] = true
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.ACTIVITY
  })
end
def.method("number").RemoveGangActivityRedPoint = function(self, activityId)
  if self.gangActivityRedPoint then
    self.gangActivityRedPoint[activityId] = nil
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.ACTIVITY
  })
end
def.method("number", "=>", "boolean").IsShowGangActivityRedPointByActivityId = function(self, activityId)
  if self.gangActivityRedPoint and self.gangActivityRedPoint[activityId] then
    return true
  end
  return false
end
def.method("=>", "boolean").IsShowGangActivityRedPoint = function(self)
  if self.gangActivityRedPoint then
    for i, v in pairs(self.gangActivityRedPoint) do
      if v then
        return true
      end
    end
  end
  return false
end
def.static("=>", "number").GetGangBuildSyncInterval = function()
  local self = GangUtility.Instance()
  return self.constTbl.gangBuildSyncInterval
end
def.static("string", "=>", "number").GetGangConsts = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_CONST_CFG, name)
  return DynamicRecord.GetIntValue(record, "value")
end
def.static("string", "=>", "number").GetGangRobberConsts = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_ROBBER_CONST_CFG, name)
  return DynamicRecord.GetIntValue(record, "value")
end
def.static("table", "userdata", "=>", "table").FillNoGangPanelUI = function(uiTbl, node)
  uiTbl = {}
  local Img_Bg0 = node:FindDirect("Img_Bg0")
  local Group_Left = Img_Bg0:FindDirect("Group_Left")
  local Group_Right = Img_Bg0:FindDirect("Group_Right")
  local Group_List = Group_Left:FindDirect("Group_List")
  local Group_Search = Group_Left:FindDirect("Group_Search")
  local Group_Empty = Group_Left:FindDirect("Group_Empty")
  local ScrollView = Group_List:FindDirect("Scroll View")
  local List_Left = ScrollView:FindDirect("List_Left")
  local Btn_Quick = Group_Right:FindDirect("Btn_Quick")
  uiTbl.List_Left = List_Left
  uiTbl["Scroll View"] = ScrollView
  uiTbl.Group_List = Group_List
  uiTbl.Group_Search = Group_Search
  uiTbl.Group_Empty = Group_Empty
  uiTbl.Btn_Quick = Btn_Quick
  local Img_BgSearchInput = Group_Right:FindDirect("Img_BgSearchInput")
  local Label_DefaultSearch = Img_BgSearchInput:FindDirect("Label_DefaultSearch")
  uiTbl.Img_BgSearchInput = Img_BgSearchInput
  uiTbl.Label_DefaultSearch = Label_DefaultSearch
  local Group_Tenet = Group_Right:FindDirect("Group_Tenet")
  local Label_Tenet = Group_Tenet:FindDirect("Label_Tenet")
  uiTbl.Label_Tenet = Label_Tenet
  return uiTbl
end
def.static("table", "userdata", "=>", "table").FillGangListPanelUI = function(uiTbl, node)
  uiTbl = {}
  local Img_Bg0 = node:FindDirect("Img_Bg")
  local Group_Left = Img_Bg0:FindDirect("Group_Left")
  local Group_Right = Img_Bg0:FindDirect("Group_Right")
  local Group_List = Group_Left:FindDirect("Group_List")
  local Group_Search = Group_Left:FindDirect("Group_Search")
  local Group_Empty = Group_Left:FindDirect("Group_Empty")
  local ScrollView = Group_List:FindDirect("Scroll View")
  local List_Left = ScrollView:FindDirect("List_Left")
  uiTbl.List_Left = List_Left
  uiTbl["Scroll View"] = ScrollView
  uiTbl.Group_List = Group_List
  uiTbl.Group_Search = Group_Search
  uiTbl.Group_Empty = Group_Empty
  local Img_BgSearchInput = Group_Right:FindDirect("Img_BgSearchInput")
  local Label_DefaultSearch = Img_BgSearchInput:FindDirect("Label_DefaultSearch")
  uiTbl.Img_BgSearchInput = Img_BgSearchInput
  uiTbl.Label_DefaultSearch = Label_DefaultSearch
  local Group_Tenet = Group_Right:FindDirect("Group_Tenet")
  local Label_Tenet = Group_Tenet:FindDirect("Label_Tenet")
  uiTbl.Label_Tenet = Label_Tenet
  local Button_Combine = Group_Right:FindDirect("Btn_ApplyCombine")
  local Button_Connect = Group_Right:FindDirect("Btn_Connect")
  uiTbl.Button_Combine = Button_Combine
  uiTbl.Button_Connect = Button_Connect
  return uiTbl
end
def.static("table", "userdata", "=>", "table").FillMemberInfoNodeUI = function(uiTbl, node)
  uiTbl = {}
  local Img_BgModel = node:FindDirect("Img_BgModel")
  local ScrollView_Btn = node:FindDirect("Scroll View_Btn")
  local List_Btn = ScrollView_Btn:FindDirect("List_Btn")
  uiTbl.Img_BgModel = Img_BgModel
  uiTbl["Scroll View_Btn"] = ScrollView_Btn
  uiTbl.List_Btn = List_Btn
  return uiTbl
end
def.static("table", "userdata", "=>", "table").FillAffairsInfoNodeUI = function(uiTbl, node)
  uiTbl = {}
  local Group_Left = node:FindDirect("Group_Left")
  uiTbl.Label_IdNum = Group_Left:FindDirect("Group_Id/Label_IdNum")
  uiTbl.Label_LvNum = Group_Left:FindDirect("Group_Lv/Label_LvNum")
  uiTbl.Label_MemberNum = Group_Left:FindDirect("Group_Member/Label_MemberNum")
  uiTbl.Label_StudentNum = Group_Left:FindDirect("Group_Student/Label_StudentNum")
  uiTbl.Label_LeaderNum = Group_Left:FindDirect("Group_Leader/Label_LeaderNum")
  uiTbl.Label_TimeNum = Group_Left:FindDirect("Group_Time/Label_TimeNum")
  uiTbl.Label_UseNum = Group_Left:FindDirect("Group_Use/Label_UseNum")
  uiTbl.Label_ActivityNum = Group_Left:FindDirect("Group_Activity/Label_ActivityNum")
  uiTbl.Img_BgSlider = Group_Left:FindDirect("Group_Money/Img_BgSlider")
  uiTbl.Img_Arrow = Group_Left:FindDirect("Group_Money/Img_Arrow")
  uiTbl.Label_SliderNum = Img_BgSlider:FindDirect("Label_SliderNum")
  uiTbl.Btn_Manage = Group_Left:FindDirect("Btn_Manage")
  uiTbl.Btn_GangList = Group_Left:FindDirect("Btn_GangList")
  uiTbl.Btn_HomeUp = Group_Left:FindDirect("Btn_HomeUp")
  uiTbl.Btn_ApplyList = Group_Left:FindDirect("Btn_ApplyList")
  return uiTbl
end
def.static("number", "=>", "string").GetTime = function(offlineTime)
  local curTime = GetServerTime()
  local offlineDate = os.date("*t", offlineTime)
  local today = os.date("*t", curTime)
  if offlineDate.year == today.year and offlineDate.yday == today.yday then
    return textRes.Gang[289] or ""
  end
  local oneDayAfterOfflineDate = os.date("*t", offlineTime + 86400)
  if oneDayAfterOfflineDate.year == today.year and oneDayAfterOfflineDate.yday == today.yday then
    return textRes.Gang[290] or ""
  end
  local str = string.format("%d/%d", offlineDate.month, offlineDate.day)
  return str
end
def.static("number", "=>", "table").GetAuthority = function(dutyId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_DUTY_CFG, dutyId)
  local tbl = {}
  if record then
    tbl.isCanModifyName = record:GetCharValue("isCanModifyName") == 1
    tbl.isCanTanHe = record:GetCharValue("isCanTanHe") == 1
    tbl.isCanDesignDutyName = record:GetCharValue("isCanDesignDutyName") == 1
    tbl.isCanModifyPurpose = record:GetCharValue("isCanModifyPurpose") == 1
    tbl.isCanLevelUpGang = record:GetCharValue("isCanLevelUpGang") == 1
    tbl.isCanSetGangTask = record:GetCharValue("isCanSetGangTask") == 1
    tbl.isCanAssignDuty = record:GetCharValue("isCanAssignDuty") == 1
    tbl.isCanKick = record:GetCharValue("isCanKick") == 1
    tbl.isCanSetCallState = record:GetCharValue("isCanSetCallState") == 1
    tbl.isCanForbidden = record:GetCharValue("isCanForbidden") == 1
    tbl.isCanPublishAnnouncement = record:GetCharValue("isCanPublishAnnouncement") == 1
    tbl.isCanMgeApplyList = record:GetCharValue("isCanMgeApplyList") == 1
    tbl.isCanInvite = record:GetCharValue("isCanInvite") == 1
    tbl.kickNeedVigor = record:GetIntValue("kickNeedVigor")
    tbl.canActivatePVE = record:GetCharValue("canActivatePVE") == 1
    tbl.canSignUpCrossCompete = record:GetCharValue("canSignUpCrossCompete") == 1
  end
  return tbl
end
def.static("number", "=>", "number").GetDutyLv = function(dutyId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_DUTY_CFG, dutyId)
  local dutyLv = 0
  if record then
    dutyLv = record:GetIntValue("dutyLevel")
  end
  return dutyLv
end
def.static("number", "=>", "string").GetDutyDefaultName = function(dutyId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_DUTY_CFG, dutyId)
  local name = ""
  if record then
    name = record:GetStringValue("templatename")
  end
  return name
end
def.static("string", "=>", "boolean").ValidEnteredName = function(enteredName)
  if SensitiveWordsFilter.ContainsSensitiveWord(enteredName) then
    Toast(textRes.Gang[71] .. textRes.Gang[113])
    return false
  end
  local GangNameValidator = require("Main.Gang.GangNameValidator")
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, num = GangNameValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    local min, max = GangNameValidator.Instance():GetCharacterNum()
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(string.format(textRes.Gang[96], min))
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(string.format(textRes.Gang[95], max))
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Gang[94])
    elseif reason == NameValidator.InvalidReason.AllNumber then
      Toast(textRes.Gang[97])
    end
    return false
  end
end
def.static("string", "=>", "boolean").ValidEnteredContent = function(enteredContent)
  if SensitiveWordsFilter.ContainsSensitiveWord(enteredContent) then
    Toast(textRes.Gang[113])
    return false
  end
  local GangPurposeValidator = require("Main.Gang.GangPurposeValidator")
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, num = GangPurposeValidator.Instance():IsValid(enteredContent)
  if isValid then
    return true
  else
    local min, max = GangPurposeValidator.Instance():GetCharacterNum()
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(string.format(textRes.Gang[96], min))
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(string.format(textRes.Gang[95], max))
    end
    return false
  end
end
def.static("number", "=>", "table").GetGangCfg = function(gangLv)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_LEVEL_CFG, gangLv)
  local tbl
  if record then
    tbl = {}
    tbl.maintainCostMoneyPerDay = record:GetIntValue("maintainCostMoneyPerDay")
    tbl.levelUpNeedMoney = record:GetIntValue("levelUpNeedMoney")
    tbl.levelUpNeedTimeM = record:GetIntValue("levelUpNeedTimeM")
    tbl.needBuildingLevel = record:GetIntValue("needBuildingLevel")
    tbl.needBuildingNum = record:GetIntValue("needBuildingNum")
    tbl.xiangFangMaxLevel = record:GetIntValue("xiangFangMaxLevel")
    tbl.jinKuMaxLevel = record:GetIntValue("jinKuMaxLevel")
    tbl.yaoDianMaxLevel = record:GetIntValue("yaoDianMaxLevel")
    tbl.cangKuMaxLevel = record:GetIntValue("cangKuMaxLevel")
    tbl.shuYuanMaxLevel = record:GetIntValue("shuYuanMaxLevel")
  end
  return tbl
end
def.static("number", "number", "=>", "number").GetDutyMaxNum = function(dutyId, gangLv)
  local dutyLv = GangUtility.GetDutyLv(dutyId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_XIANGFANG_CFG, gangLv)
  local num = 0
  if record then
    local recItemId = record:GetStructValue("dutyStruct")
    local size = recItemId:GetVectorSize("dutyVector")
    local rec = recItemId:GetVectorValueByIdx("dutyVector", dutyLv - 1)
    if rec then
      num = rec:GetIntValue("dutyId")
    end
  end
  return num
end
def.static("number", "=>", "table").GetWingGangBasicCfg = function(gangLv)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_XIANGFANG_CFG, gangLv)
  local tbl
  if record then
    tbl = {}
    tbl.maintainCostMoneyPerDay = record:GetIntValue("maintainCostMoneyPerDay")
    tbl.levelUpNeedMoney = record:GetIntValue("levelUpNeedMoney")
    tbl.levelUpNeedTimeM = record:GetIntValue("levelUpNeedTimeM")
  end
  return tbl
end
def.static("number", "=>", "table").GetCoffersGangBasicCfg = function(gangLv)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_JINKU_CFG, gangLv)
  local tbl
  if record then
    tbl = {}
    tbl.maintainCostMoneyPerDay = record:GetIntValue("maintainCostMoneyPerDay")
    tbl.levelUpNeedMoney = record:GetIntValue("levelUpNeedMoney")
    tbl.levelUpNeedTimeM = record:GetIntValue("levelUpNeedTimeM")
    tbl.gangMoneyLimit = record:GetIntValue("gangMoneyLimit")
  end
  return tbl
end
def.static("number", "=>", "table").GetPharmacyGangBasicCfg = function(gangLv)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_YAODIAN_CFG, gangLv)
  local tbl
  if record then
    tbl = {}
    tbl.maintainCostMoneyPerDay = record:GetIntValue("maintainCostMoneyPerDay")
    tbl.levelUpNeedMoney = record:GetIntValue("levelUpNeedMoney")
    tbl.levelUpNeedTimeM = record:GetIntValue("levelUpNeedTimeM")
    tbl.itemKindNum = record:GetIntValue("itemKindNum")
    tbl.itemNum = record:GetIntValue("itemNum")
    tbl.itemSilverPrice = record:GetIntValue("itemSilverPrice")
    tbl.itemBangGongPrice = record:GetIntValue("itemBangGongPrice")
  end
  return tbl
end
def.static("number", "=>", "table").GetWarehouseGangBasicCfg = function(gangLv)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_CANGKU_CFG, gangLv)
  local tbl
  if record then
    tbl = {}
    tbl.maintainCostMoneyPerDay = record:GetIntValue("maintainCostMoneyPerDay")
    tbl.levelUpNeedMoney = record:GetIntValue("levelUpNeedMoney")
    tbl.levelUpNeedTimeM = record:GetIntValue("levelUpNeedTimeM")
    tbl.fuLiNum = record:GetIntValue("fuLiNum")
    tbl.gridSize = record:GetIntValue("gridSize")
  end
  return tbl
end
def.static("number", "=>", "table").GetBookGangBasicCfg = function(gangLv)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_SHUYUAN_CFG, gangLv)
  local tbl
  if record then
    tbl = {}
    tbl.maintainCostMoneyPerDay = record:GetIntValue("maintainNeedMoney")
    tbl.levelUpNeedMoney = record:GetIntValue("levelUpNeedMoney")
    tbl.levelUpNeedTimeM = record:GetIntValue("levelUpNeedMin")
    tbl.maxSkillLevel = record:GetIntValue("maxSkillLevel")
  end
  return tbl
end
def.static("number", "=>", "number", "number").GetDonateInfo = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_BUILD_DONATE_CFG, id)
  local money = 0
  local banggong = 0
  if record then
    money = record:GetIntValue("donateSilver")
    banggong = record:GetIntValue("redeemBangGong")
  end
  return money, banggong
end
def.static("number", "=>", "number").GetExchangeInfo = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BANGGONG_REDEEM_CFG, id)
  local banggong = 0
  if record then
    banggong = record:GetIntValue("redeemBangGong")
  end
  return banggong
end
def.static("number", "=>", "number").GetYuanBaoExchangeInfo = function(yuanBao)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BANGGONG_YUANBAO_REDEEM_CFG, yuanBao)
  local banggong = 0
  if record then
    banggong = record:GetIntValue("redeem_bang_gong")
  end
  return banggong
end
def.static("number", "=>", "string").GetTimeStr = function(remain)
  local timeStr = ""
  if remain < 0 then
    remain = 0
  end
  if remain >= 86400 then
    local tmp = 86400
    local day, left = math.modf(remain / tmp)
    timeStr = timeStr .. string.format(textRes.Gang[350], day)
    remain = left * 24 * 60 * 60
  end
  if remain >= 3600 then
    local tmp = 3600
    local hour, left = math.modf(remain / tmp)
    timeStr = timeStr .. string.format(textRes.Gang[351], hour)
    remain = left * 60 * 60
  end
  if remain >= 60 then
    local tmp = 60
    local minute, left = math.modf(remain / tmp)
    timeStr = timeStr .. string.format(textRes.Gang[352], minute)
    remain = left * 60
  end
  if remain >= 0 then
    local second = remain
    timeStr = timeStr .. string.format(textRes.Gang[353], second)
  end
  return timeStr
end
def.static("number", "=>", "table").GetMifangInfo = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_MIFANG_CFG, id)
  local tbl
  if record then
    tbl = {}
    tbl.id = record:GetIntValue("id")
    tbl.yaoDianLevel = record:GetIntValue("yaoDianLevel")
    tbl.mustItemSiftId = record:GetIntValue("mustItemSiftId")
    tbl.otherItemSiftId = record:GetIntValue("otherItemSiftId")
    tbl.generLifeSkillId = record:GetIntValue("generLifeSkillId")
    tbl.lowTime = record:GetIntValue("lowTime")
    tbl.maxTime = record:GetIntValue("maxTime")
    tbl.lowPersistTimeM = record:GetIntValue("lowPersistTimeM")
    tbl.needBangGong = record:GetIntValue("needBangGong")
    tbl.miFangName = record:GetStringValue("miFangName")
  end
  return tbl
end
def.static("number", "number", "=>", "string").GetDutyNameByDutyLvAndCfgId = function(cfgId, dutyLv)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_DUTY_NAME_CFG, cfgId)
  local name = ""
  if record then
    local recItemId = record:GetStructValue("dutyStruct")
    local size = recItemId:GetVectorSize("dutyVector")
    local rec = recItemId:GetVectorValueByIdx("dutyVector", dutyLv - 1)
    name = rec:GetStringValue("dutyName")
  end
  return name
end
def.static().ShowRejoinGangPrompt = function()
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Gang[291], textRes.Gang[292], function(id, tag)
    if id == 1 then
      require("Main.Gang.ui.NoGangPanel").Instance():ShowPanel()
    end
  end, nil)
end
def.static("=>", "number").GetGangMaintainceCost = function()
  local data = require("Main.Gang.data.GangData").Instance()
  local gangInfo = data:GetGangBasicInfo()
  local gangTbl = GangUtility.GetGangCfg(gangInfo.level)
  local wingTbl = GangUtility.GetWingGangBasicCfg(gangInfo.wingLevel)
  local coffersTbl = GangUtility.GetCoffersGangBasicCfg(gangInfo.coffersLevel)
  local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
  local warehouseTbl = GangUtility.GetWarehouseGangBasicCfg(gangInfo.warehouseLevel)
  local bookTbl = GangUtility.GetBookGangBasicCfg(gangInfo.bookLevel)
  if nil == gangTbl or nil == wingTbl or nil == coffersTbl or nil == pharmacyTbl or nil == warehouseTbl or nil == bookTbl then
    return -1
  end
  local costMoney = gangTbl.maintainCostMoneyPerDay + wingTbl.maintainCostMoneyPerDay + coffersTbl.maintainCostMoneyPerDay + pharmacyTbl.maintainCostMoneyPerDay + warehouseTbl.maintainCostMoneyPerDay + bookTbl.maintainCostMoneyPerDay
  return costMoney
end
def.static("number").TryGangConstruct = function(typeName)
  local GangBuildingEnum = require("netio.protocol.mzm.gsp.gang.GangBuildingEnum")
  local data = require("Main.Gang.data.GangData").Instance()
  local gangInfo = data:GetGangBasicInfo()
  if not gangInfo then
    return
  end
  local curlvlCfg, nextlvlCfg
  if typeName == GangBuildingEnum.GANG then
    curlvlCfg = GangUtility.GetGangCfg(gangInfo.level)
    nextlvlCfg = GangUtility.GetGangCfg(gangInfo.level + 1)
  elseif typeName == GangBuildingEnum.CANGKU then
    curlvlCfg = GangUtility.GetWarehouseGangBasicCfg(gangInfo.warehouseLevel)
    nextlvlCfg = GangUtility.GetWarehouseGangBasicCfg(gangInfo.warehouseLevel + 1)
  elseif typeName == GangBuildingEnum.JINKU then
    curlvlCfg = GangUtility.GetCoffersGangBasicCfg(gangInfo.coffersLevel)
    nextlvlCfg = GangUtility.GetCoffersGangBasicCfg(gangInfo.coffersLevel + 1)
  elseif typeName == GangBuildingEnum.XIANGFANG then
    curlvlCfg = GangUtility.GetWingGangBasicCfg(gangInfo.wingLevel)
    nextlvlCfg = GangUtility.GetWingGangBasicCfg(gangInfo.wingLevel + 1)
  elseif typeName == GangBuildingEnum.SHUYUAN then
    curlvlCfg = GangUtility.GetBookGangBasicCfg(gangInfo.bookLevel)
    nextlvlCfg = GangUtility.GetBookGangBasicCfg(gangInfo.bookLevel + 1)
  elseif typeName == GangBuildingEnum.YAODIAN then
    curlvlCfg = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
    nextlvlCfg = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel + 1)
  end
  if not curlvlCfg or not nextlvlCfg then
    return
  end
  local curMaintainCost = curlvlCfg.maintainCostMoneyPerDay
  local nextlvlMaintainCost = nextlvlCfg.maintainCostMoneyPerDay
  local lvlUpCost = curlvlCfg.levelUpNeedMoney
  local curTotalMaintainCost = GangUtility.GetGangMaintainceCost()
  local nextTotalMaintainCost = curTotalMaintainCost + nextlvlMaintainCost - curMaintainCost
  local gangFund = data:GetGangBasicInfo().money
  if gangFund < curlvlCfg.levelUpNeedMoney then
    Toast(textRes.Gang[107])
    return
  end
  local function func()
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CStartBuildingLevelUpReq").new(typeName, heroProp.id))
  end
  if nextTotalMaintainCost > gangFund - lvlUpCost then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Gang[293], textRes.Gang[294], function(id, tag)
      if id == 1 then
        func()
      end
    end, nil)
  else
    func()
  end
end
def.static("=>", "table").GetAllSilverExchangeBangGongCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BANGGONG_REDEEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local exchange = {}
    exchange.id = DynamicRecord.GetIntValue(entry, "id")
    exchange.costSilver = DynamicRecord.GetIntValue(entry, "costSilver")
    exchange.redeemBangGong = DynamicRecord.GetIntValue(entry, "redeemBangGong")
    table.insert(cfgs, exchange)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.costSilver < r.costSilver
  end)
  return cfgs
end
def.static("=>", "table").GetAllYuanBaoExchangeBangGongCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BANGGONG_YUANBAO_REDEEM_CFG)
  if entries == nil then
    warn("GetAllYuanBaoExchangeBangGongCfgs return {}")
    return {}
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local exchange = {}
    exchange.costYuanBao = DynamicRecord.GetIntValue(entry, "yuan_bao")
    exchange.redeemBangGong = DynamicRecord.GetIntValue(entry, "redeem_bang_gong")
    table.insert(cfgs, exchange)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.costYuanBao < r.costYuanBao
  end)
  return cfgs
end
local noticeTable = {
  SIGNIN = true,
  BUILD = false,
  APPLY = true,
  HELP = true
}
def.const("table").MainUINoticeTbl = noticeTable
def.static("=>", "boolean").IsWelfareTouchedToday = function()
  local date = GetServerTime()
  local dateTbl = os.date("*t", date)
  local val = dateTbl.year * 1000 + dateTbl.yday
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  local invitedDay = PlayerPref.GetRoleInt(GangUtility.GANG_SIGN_NOTICE_TOUCHED_DAY)
  if invitedDay and invitedDay == val then
    return true
  else
    return false
  end
end
def.static().SaveWelfareTouchedToday = function()
  local date = GetServerTime()
  local dateTbl = os.date("*t", date)
  local val = dateTbl.year * 1000 + dateTbl.yday
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  PlayerPref.SetRoleInt(GangUtility.GANG_SIGN_NOTICE_TOUCHED_DAY, val)
  PlayerPref.Save()
end
def.static().ClearWelfareTouchedRecord = function()
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  PlayerPref.SetRoleInt(GangUtility.GANG_SIGN_NOTICE_TOUCHED_DAY, 0)
  PlayerPref.Save()
end
def.static("=>", "boolean").NeedShowSignInNotice = function()
  local bSignToday = require("Main.Gang.data.GangData").Instance():IsSignToday()
  local bTouched = GangUtility.IsWelfareTouchedToday()
  if bTouched or bSignToday then
    return false
  end
  return true
end
def.static("=>", "boolean").NeedShowBuildNotice = function()
  local bNotStart = require("Main.Gang.data.GangData").Instance():GetIsBuildNotStart()
  if not bNotStart then
    return true
  end
  return false
end
def.static("=>", "boolean").IsHaveHuanHunHelp = function()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local huanhunGangHelp = ActivityInterface.Instance():GetHuanhunGangHelpInfo()
  if huanhunGangHelp then
    for roleId, helpData in pairs(huanhunGangHelp) do
      for boxKey, boxData in pairs(helpData) do
        return true
      end
    end
  end
  return false
end
def.static("=>", "boolean").NeedShowHelpNotice = function()
  local data = require("Main.Gang.data.GangData").Instance()
  local bHelpShow = data:GetHelpShow()
  local bHelpListNotEmpty = GangUtility.IsHaveHuanHunHelp()
  return bHelpShow and bHelpListNotEmpty
end
def.static("boolean", "=>", "boolean").NeedShowWelfareNotice = function(bUseNoticeTbl)
  local bNeedShowSignInNotice = GangUtility.NeedShowSignInNotice()
  local bNeedShowHelpNotice = GangUtility.NeedShowHelpNotice()
  if bUseNoticeTbl then
    bNeedShowSignInNotice = bNeedShowSignInNotice and GangUtility.MainUINoticeTbl.SIGNIN
    bNeedShowHelpNotice = bNeedShowHelpNotice and GangUtility.MainUINoticeTbl.HELP
  end
  return bNeedShowSignInNotice or bNeedShowHelpNotice
end
def.static("=>", "boolean").NeedShowApplyNotice = function()
  local data = require("Main.Gang.data.GangData").Instance()
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if heroProp then
    local memberInfo = data:GetMemberInfoByRoleId(heroProp.id)
    if memberInfo then
      local tbl = GangUtility.GetAuthority(memberInfo.duty)
      if not tbl.isCanMgeApplyList then
        return false
      end
    end
  end
  local bApplyShow = data:GetApplyShow()
  local applierList = data:GetApplierList()
  local bApplyListNotEmpty = applierList and #applierList > 0
  return bApplyShow and bApplyListNotEmpty
end
def.static("=>", "boolean").NeedShowMergeApplyNotice = function()
  local data = require("Main.Gang.data.GangData").Instance()
  return data:IsHaveGangMergeApply()
end
def.static("boolean", "=>", "boolean").NeedShowInternalAffairsNotice = function(bUseNoticeTbl)
  local bNeedShowApplyNotice = GangUtility.NeedShowApplyNotice()
  local bNeedShowBuildNotice = GangUtility.NeedShowBuildNotice()
  local bNeedShowMergeApplyNotice = GangUtility.NeedShowMergeApplyNotice()
  if bUseNoticeTbl then
    bNeedShowApplyNotice = bNeedShowApplyNotice and GangUtility.MainUINoticeTbl.APPLY
    bNeedShowBuildNotice = bNeedShowBuildNotice and GangUtility.MainUINoticeTbl.BUILD
  end
  return bNeedShowApplyNotice or bNeedShowBuildNotice or bNeedShowMergeApplyNotice
end
def.static("=>", "boolean").NeedShowNewGangNotice = function()
  local data = require("Main.Gang.data.GangData").Instance()
  return data:IsHaveNewGangNotice()
end
def.static("boolean", "=>", "boolean").NeedShowMembersNotice = function(bUseNoticeTbl)
  local bNeedShowNewGangNotice = GangUtility.NeedShowNewGangNotice()
  return bNeedShowNewGangNotice
end
def.static("=>", "boolean").NeedShowMainUINotice = function()
  local gangId = require("Main.Gang.data.GangData").Instance():GetGangId()
  local bNeedShowWelfareNotice = GangUtility.NeedShowWelfareNotice(true)
  local bNeedShowInternalAffairsNotice = GangUtility.NeedShowInternalAffairsNotice(true)
  local bNeedShowMembersNotice = GangUtility.NeedShowMembersNotice(true)
  local unlockLevel = GangUtility.GetGangConsts("OPEN_LEVEL")
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  local gangActivityNotice = GangUtility.Instance():IsShowGangActivityRedPoint()
  return unlockLevel <= heroLevel and (bNeedShowWelfareNotice or bNeedShowInternalAffairsNotice or bNeedShowMembersNotice or not gangId or gangActivityNotice)
end
def.static("number", "number", "=>", "number").IsSameDay = function(time1, time2)
  local timeStr1 = os.date("%Y%m%d", time1)
  local timeStr2 = os.date("%Y%m%d", time2)
  if timeStr1 == timeStr2 then
    return 1
  end
  return 0
end
def.static("userdata", "userdata", "=>", "userdata").GangIdToDisplayID = function(displayid, gangId)
  if not gangId or not displayid then
    return Int64.new(0)
  end
  if displayid > Int64.new(0) then
    return displayid
  end
  local step = 4096
  local gangIndex = gangId / step
  return gangIndex
end
def.static("=>", "boolean").HeroIsBangZhu = function()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local data = require("Main.Gang.data.GangData").Instance()
  local heroMember = data:GetMemberInfoByRoleId(heroProp.id)
  local bangzhuId = GangUtility.GetGangConsts("BANGZHU_ID")
  if heroMember then
    return heroMember.duty == bangzhuId
  end
  return false
end
def.static("number", "=>", "boolean").IsGangMap = function(mapId)
  local gangMapId = GangUtility.GetGangConsts("GANG_MAP")
  return mapId == gangMapId
end
def.static("=>", "boolean").IsHeroInGangMap = function()
  local curMapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  return GangUtility.IsGangMap(curMapId)
end
def.static("=>", "boolean").IsHeroInSelfGangMap = function()
  if not GangUtility.IsHeroInGangMap() then
    return false
  end
  local mapInstanceId = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapInstanceId
  local gangData = require("Main.Gang.data.GangData").Instance()
  local gangMapInstanceId = gangData:GetGangMapInstanceId()
  return mapInstanceId == gangMapInstanceId
end
return GangUtility.Commit()
