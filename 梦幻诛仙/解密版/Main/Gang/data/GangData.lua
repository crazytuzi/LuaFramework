local Lplus = require("Lplus")
local GangUtility = require("Main.Gang.GangUtility")
local GangData = Lplus.Class("GangData")
local def = GangData.define
local instance
def.field("userdata").gangId = nil
def.field("userdata").displayid = nil
def.field("string").name = ""
def.field("string").bangZhu = ""
def.field("number").level = 0
def.field("number").money = 0
def.field("number").vitality = 0
def.field("string").purpose = ""
def.field("number").designDutyNameId = 0
def.field("number").createTime = 0
def.field("number").buildEndTime = 0
def.field("number").tanHeEndTime = 0
def.field("userdata").tanHeRoleId = nil
def.field("number").xueTuMaxLevel = 0
def.field("table").applierList = nil
def.field("table").memberList = nil
def.field("table").gangList = nil
def.field("table").gangHelpList = nil
def.field("table").announcementList = nil
def.field("table").svrAnnouncementList = nil
def.field("number").lastTime = 0
def.field("boolean").bApplyShow = true
def.field("boolean").bHelpShow = true
def.field("number").unReadAnnoNum = 0
def.field("userdata").lastReadAnnouncementTime = nil
def.field("number").wingEndTime = 0
def.field("number").wingLevel = 0
def.field("number").lastWingTime = 0
def.field("number").warehouseEndTime = 0
def.field("number").warehouseLevel = 0
def.field("number").lastWarehouseTime = 0
def.field("number").totalFuli = 0
def.field("number").avaliableFuli = 0
def.field("number").avaliableLiHe = 0
def.field("number").coffersEndTime = 0
def.field("number").coffersLevel = 0
def.field("number").lastCoffersTime = 0
def.field("number").pharmacyEndTime = 0
def.field("number").pharmacyLevel = 0
def.field("number").lastPharmacyTime = 0
def.field("table").drugList = nil
def.field("boolean").bDrugListRefresh = false
def.field("number").bookEndTime = 0
def.field("number").bookLevel = 0
def.field("number").lastBookTime = 0
def.field("number").mapInstanceId = 0
def.field("number").redeemBangGong = 0
def.field("number").redeemBangGong_timestamp = 0
def.field("number").yuanBaoRedeemBangGong = 0
def.field("number").yuanBaoRedeemBangGong_timestamp = 0
def.field("number").isGetMiFang = 0
def.field("number").tiggerMiFangId = 0
def.field("table").mifangNeedItemList = nil
def.field("number").mifangId = 0
def.field("userdata").mifangEndTime = nil
def.field("userdata").mifangStartTime = nil
def.field("userdata").mifangHaveTime = nil
def.field("number").mifangUseCount = 0
def.field("number").mifangTotalCount = 0
def.field("boolean").isTiggerMiFang = false
def.field("number").isGetFuLi = 0
def.field("string").strSign = ""
def.field("number").isSignToday = 0
def.field("userdata").fuli_timestamp = nil
def.field("userdata").get_fuli_timestamp = nil
def.field("userdata").sign_timestamp = nil
def.field("boolean").isKickedOffline = false
def.field("table").mergeInfo = nil
def.field("boolean").newGangNotice = false
def.field("number").gangInfo_timestamp = 0
def.const("table").SortType = {
  Name = 1,
  Level = 2,
  Occupation = 3,
  Duty = 4,
  Banggong = 5,
  Offline = 6
}
def.field("table").sortTimesTbl = nil
def.field("table").giftSortTimesTbl = nil
def.static("=>", GangData).Instance = function()
  if nil == instance then
    instance = GangData()
    instance.applierList = {}
    instance.memberList = {}
    instance.gangList = {}
    instance.gangHelpList = {}
    instance.announcementList = {}
    instance.sortTimesTbl = {}
    instance.giftSortTimesTbl = {}
    instance.drugList = {}
    instance.mifangNeedItemList = {}
    instance.mergeInfo = {}
  end
  return instance
end
def.method().SetAllNull = function(self)
  self.gangId = nil
  self.displayid = nil
  self.name = ""
  self.bangZhu = ""
  self.level = 0
  self.money = 0
  self.vitality = 0
  self.purpose = ""
  self.designDutyNameId = 0
  self.createTime = 0
  self.buildEndTime = 0
  self.tanHeEndTime = 0
  self.tanHeRoleId = nil
  self.xueTuMaxLevel = 0
  self.applierList = {}
  self.memberList = {}
  self.gangList = {}
  self.gangHelpList = {}
  self.announcementList = {}
  self.svrAnnouncementList = nil
  self.lastTime = 0
  self.bApplyShow = true
  self.bHelpShow = true
  self.unReadAnnoNum = 0
  self.lastReadAnnouncementTime = nil
  self.sortTimesTbl = {}
  self.giftSortTimesTbl = {}
  self.wingEndTime = 0
  self.wingLevel = 0
  self.lastWingTime = 0
  self.warehouseEndTime = 0
  self.warehouseLevel = 0
  self.lastWarehouseTime = 0
  self.totalFuli = 0
  self.avaliableFuli = 0
  self.avaliableLiHe = 0
  self.coffersEndTime = 0
  self.coffersLevel = 0
  self.lastCoffersTime = 0
  self.pharmacyEndTime = 0
  self.pharmacyLevel = 0
  self.lastPharmacyTime = 0
  self.drugList = {}
  self.bDrugListRefresh = false
  self.bookEndTime = 0
  self.bookLevel = 0
  self.lastBookTime = 0
  self.mapInstanceId = 0
  self.isGetMiFang = 0
  self.isTiggerMiFang = false
  self.mifangNeedItemList = {}
  self.mifangId = 0
  self.tiggerMiFangId = 0
  self.mifangEndTime = nil
  self.mifangStartTime = nil
  self.mifangHaveTime = nil
  self.mifangUseCount = 0
  self.mifangTotalCount = 0
  self.fuli_timestamp = nil
  self.get_fuli_timestamp = nil
  self.isGetFuLi = 0
  self.strSign = ""
  self.isSignToday = 0
  self.isKickedOffline = false
  self.mergeInfo = {}
  require("Main.Gang.GangGroup.GangGroupMgr").Instance():Reset()
end
def.method("table").SyncGangInfo = function(self, p)
  self.memberList = {}
  self.gangList = {}
  self.announcementList = {}
  self.sortTimesTbl = {}
  self.giftSortTimesTbl = {}
  self.drugList = {}
  self.gangId = p.gangId
  self.displayid = p.displayid
  self.name = p.name
  self.bangZhu = p.bangZhu
  self.level = p.level
  self.money = p.money
  self.vitality = p.vitality
  self.purpose = p.purpose
  self.designDutyNameId = p.designDutyNameId
  self.createTime = p.createTime
  self.buildEndTime = p.buildEndTime
  self.tanHeEndTime = p.tanHeEndTime
  self.tanHeRoleId = p.tanHeRoleId
  self.xueTuMaxLevel = p.xueTuMaxLevel
  self.wingEndTime = p.xiangFangInfo.levelUpEndTime
  self.wingLevel = p.xiangFangInfo.level
  self.warehouseEndTime = p.cangKuInfo.levelUpEndTime
  self.warehouseLevel = p.cangKuInfo.level
  self.totalFuli = p.cangKuInfo.totalFuli
  self.avaliableFuli = p.cangKuInfo.avaliableFuli
  self.avaliableLiHe = p.cangKuInfo.avaliableLiHe
  self.coffersEndTime = p.jinKuInfo.levelUpEndTime
  self.coffersLevel = p.jinKuInfo.level
  self.pharmacyEndTime = p.yaoDianInfo.levelUpEndTime
  self.pharmacyLevel = p.yaoDianInfo.level
  self.bookEndTime = p.shuYuanInfo.levelUpEndTime
  self.bookLevel = p.shuYuanInfo.level
  self.fuli_timestamp = p.fuli_timestamp
  self.mifangStartTime = p.mifang_start_time
  self.mifangEndTime = p.mifang_end_time
  self.gangInfo_timestamp = GetServerTime()
  self:SetDrugListNull()
  for k, v in pairs(p.yaoDianInfo.shopItemList) do
    self:AddDrug(v)
  end
  self.mapInstanceId = p.mapInstanceId
  self.svrAnnouncementList = p.announcementList
  self:UpdateGangInfoState()
  for k, v in pairs(p.memberList) do
    self:AddMember(v)
  end
end
def.method().UpdateGangInfoState = function(self)
  if self.get_fuli_timestamp and self.fuli_timestamp then
    if self.get_fuli_timestamp:ToNumber() > self.fuli_timestamp:ToNumber() then
      self.isGetFuLi = 1
    else
      self.isGetFuLi = 0
    end
  end
  if self.mifangStartTime and self.mifangHaveTime and self.mifangEndTime then
    local mifangStart = self.mifangStartTime:ToNumber()
    local mifangEnd = self.mifangEndTime:ToNumber()
    local mifangHave = self.mifangHaveTime:ToNumber()
    if mifangStart < mifangHave and mifangEnd > mifangHave then
      self.isGetMiFang = 1
    else
      self.isGetMiFang = 0
    end
  end
  if self.svrAnnouncementList and self.lastReadAnnouncementTime then
    self.announcementList = {}
    for k, v in pairs(self.svrAnnouncementList) do
      table.insert(self.announcementList, v)
      if v.publishTime > self.lastReadAnnouncementTime then
        self.unReadAnnoNum = self.unReadAnnoNum + 1
      end
    end
    self:SortAnnouncementList()
  end
  if self.sign_timestamp then
    self.isSignToday = GangUtility.IsSameDay(GetServerTime(), self.sign_timestamp:ToNumber() / 1000)
  end
end
def.method("table").SyncSelfInfo = function(self, p)
  self.mifangHaveTime = p.have_mifang_timestamp
  self.get_fuli_timestamp = p.get_fuli_timestamp
  self.strSign = p.signStr
  self.sign_timestamp = p.sign_timestamp
  self.redeemBangGong = p.redeemBangGong
  self.redeemBangGong_timestamp = GetServerTime()
  self.yuanBaoRedeemBangGong = p.yuan_bao_redeem_bang_gong
  self.yuanBaoRedeemBangGong_timestamp = GetServerTime()
  self.lastReadAnnouncementTime = p.read_announcement_timestamp
  self:UpdateGangInfoState()
end
def.method().SortAnnouncementList = function(self)
  table.sort(self.announcementList, function(a, b)
    return a.publishTime > b.publishTime
  end)
  local num = GangUtility.GetGangConsts("ANNOUNCEMENT_NUM_LIMIT")
  for i = num + 1, #self.announcementList do
    table.remove(self.announcementList, i)
  end
end
def.method("table").AddAnno = function(self, anno)
  table.insert(self.announcementList, anno)
  self:SortAnnouncementList()
end
def.method("boolean").SetDrugListRefresh = function(self, b)
  self.bDrugListRefresh = b
end
def.method("=>", "boolean").GetDrugListRefresh = function(self)
  return self.bDrugListRefresh
end
def.method().SetDrugListNull = function(self)
  self.drugList = {}
end
def.method("=>", "table").GetDrugList = function(self)
  return self.drugList
end
def.method("table").AddDrug = function(self, drugInfo)
  table.insert(self.drugList, drugInfo)
end
def.method("number", "number").UpdateDrugRemainNum = function(self, drugId, drugNum)
  for k, v in pairs(self.drugList) do
    if v.itemId == drugId then
      v.itemNum = drugNum
      break
    end
  end
end
def.method("=>", "boolean").IsGetMifang = function(self)
  return self.isGetMiFang == 1
end
def.method("number").SetMifang = function(self, b)
  self.isGetMiFang = b
end
def.method("=>", "boolean").IsTiggerMifang = function(self)
  return self.isTiggerMiFang
end
def.method("boolean").SetTiggerMifang = function(self, b)
  self.isTiggerMiFang = b
end
def.method().CheckFuLiTimeStamp = function(self)
  local curTime = GetServerTime() * 1000
  local gangTime = self.fuli_timestamp:ToNumber() / 1000
  if not GangData.IsSameWeek(gangTime) then
    self.isGetFuLi = 0
    self.avaliableFuli = self.totalFuli
    self.fuli_timestamp = Int64.new(curTime)
  end
end
def.method().CheckGangInfoTimeStamp = function(self)
  if not GangData.IsSameWeek(self.gangInfo_timestamp) then
    self.gangInfo_timestamp = GetServerTime()
    for k, v in pairs(self.memberList) do
      v.isRewardLiHe = GangData.GetRewardLiHe(v.getLiHeTime)
      v.weekBangGong = GangData.GetWeekBangGong(v)
      v.weekItem_banggong_count = GangData.GetWeekItemBangGong(v)
    end
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangLiHeReset, nil)
  end
end
def.method("=>", "boolean").IsGetFuli = function(self)
  self:CheckFuLiTimeStamp()
  return self.isGetFuLi == 1
end
def.method("number").SetFuli = function(self, b)
  self.get_fuli_timestamp = Int64.new(GetServerTime() * 1000)
  self.isGetFuLi = b
end
def.method("=>", "string").GetStrSign = function(self)
  return self.strSign
end
def.method("string").SetStrSign = function(self, str)
  self.strSign = str
end
def.method("=>", "boolean").IsSignToday = function(self)
  return self.isSignToday == 1
end
def.method("number").SetSignToday = function(self, b)
  self.isSignToday = b
end
def.method("=>", "number").GetRemainFuli = function(self)
  return self.avaliableFuli
end
def.method("number").SetRemainFuli = function(self, num)
  self.avaliableFuli = num
end
def.method("=>", "number").GetRemainLihe = function(self)
  return self.avaliableLiHe
end
def.method("number").SetRemainLihe = function(self, num)
  self.avaliableLiHe = num
end
def.method("=>", "number").GetTotalFuli = function(self)
  return self.totalFuli
end
def.method("number").SetTotalFuli = function(self, num)
  self.totalFuli = num
end
def.method("table").SetMifangNeedItemList = function(self, tbl)
  self.mifangNeedItemList = {}
  for k, v in pairs(tbl) do
    table.insert(self.mifangNeedItemList, v)
  end
end
def.method("=>", "table").GetMifangNeedItemList = function(self)
  return self.mifangNeedItemList
end
def.method("number").SetMifangCfgId = function(self, id)
  self.mifangId = id
end
def.method("=>", "number").GetMifangCfgId = function(self)
  return self.mifangId
end
def.method("number").SetTiggerMifangCfgId = function(self, id)
  self.tiggerMiFangId = id
end
def.method("=>", "number").GetTiggerMifangCfgId = function(self)
  return self.tiggerMiFangId
end
def.method("userdata").SetMifangEndTime = function(self, time)
  self.mifangEndTime = time
end
def.method("=>", "userdata").GetMifangEndTime = function(self)
  return self.mifangEndTime / 1000
end
def.method("number").SetMifangUseCount = function(self, count)
  self.mifangUseCount = count
end
def.method("=>", "number").GetMifangUseCount = function(self)
  return self.mifangUseCount
end
def.method("number").SetMifangTotalCount = function(self, count)
  self.mifangTotalCount = count
end
def.method("=>", "number").GetMifangTotalCount = function(self)
  return self.mifangTotalCount
end
def.method("=>", "table").GetAnnoList = function(self)
  return self.announcementList
end
def.method("=>", "number").GetUnReadAnnoNum = function(self)
  return self.unReadAnnoNum
end
def.method("number").SetUnReadAnnoNum = function(self, num)
  self.unReadAnnoNum = num
end
def.method("=>", "userdata").GetLastReadAnnoTime = function(self)
  return self.lastReadAnnouncementTime
end
def.method("userdata").SetLastReadAnnoTime = function(self, time)
  self.lastReadAnnouncementTime = time
end
def.method("boolean").SetRequireAnnoList = function(self, b)
  self.bRequireAnnoList = b
end
def.method("=>", "boolean").GetRequireAnnoList = function(self)
  return self.bRequireAnnoList
end
def.method("number").SetMapInstanceId = function(self, instanceId)
  self.mapInstanceId = instanceId
end
def.method("table").SyncGangHelpList = function(self, helpList)
  for k, v in pairs(helpList) do
    self:AddHelp(v)
  end
end
def.method("table").AddHelp = function(self, help)
  table.insert(self.gangHelpList, help)
end
def.method("table").RemoveHelp = function(self, uIdTbl)
  for k, v in pairs(uIdTbl) do
    for m, n in pairs(self.gangHelpList) do
      if n.uId == v then
        table.remove(self.gangHelpList, m)
      end
    end
  end
end
def.method("=>", "table").GetGangHelpList = function(self)
  return self.gangHelpList
end
def.method("=>", "table").GetGangBasicInfo = function(self)
  local tbl = {}
  tbl.gangId = self.gangId
  tbl.displayid = self.displayid
  tbl.name = self.name
  tbl.bangZhu = self.bangZhu
  tbl.level = self.level
  tbl.money = self.money
  tbl.vitality = self.vitality
  tbl.purpose = self.purpose
  tbl.designDutyNameId = self.designDutyNameId
  tbl.createTime = self.createTime
  tbl.buildEndTime = self.buildEndTime
  tbl.tanHeEndTime = self.tanHeEndTime
  tbl.tanHeRoleId = self.tanHeRoleId
  tbl.xueTuMaxLevel = self.xueTuMaxLevel
  tbl.wingEndTime = self.wingEndTime
  tbl.wingLevel = self.wingLevel
  tbl.warehouseEndTime = self.warehouseEndTime
  tbl.warehouseLevel = self.warehouseLevel
  tbl.coffersEndTime = self.coffersEndTime
  tbl.coffersLevel = self.coffersLevel
  tbl.pharmacyEndTime = self.pharmacyEndTime
  tbl.pharmacyLevel = self.pharmacyLevel
  tbl.mapInstanceId = self.mapInstanceId
  tbl.redeemBangGong = self.redeemBangGong
  tbl.yuanBaoRedeemBangGong = self.yuanBaoRedeemBangGong
  tbl.bookEndTime = self.bookEndTime
  tbl.bookLevel = self.bookLevel
  return tbl
end
def.method("=>", "number").GetGangMapInstanceId = function(self)
  return self.mapInstanceId
end
def.method("=>", "number").GetDesignDutyNamId = function(self)
  return self.designDutyNameId
end
def.method("boolean").SetApplyShow = function(self, bShow)
  self.bApplyShow = bShow
end
def.method("=>", "boolean").GetApplyShow = function(self)
  return self.bApplyShow
end
def.method("boolean").SetHelpShow = function(self, bShow)
  self.bHelpShow = bShow
end
def.method("=>", "boolean").GetHelpShow = function(self)
  return self.bHelpShow
end
def.method("string").SetGangName = function(self, name)
  self.name = name
end
def.method("string").SetBangzhu = function(self, name)
  self.bangZhu = name
end
def.method("string").SetGangPurpose = function(self, purpose)
  self.purpose = purpose
end
def.method("=>", "string").GetGangPurpose = function(self)
  return self.purpose
end
def.method("number").SetGangDutyNameId = function(self, id)
  self.designDutyNameId = id
end
def.method("number").SetGangBuildEndTime = function(self, time)
  self.buildEndTime = time
end
def.method("number").SetGangWingEndTime = function(self, time)
  self.wingEndTime = time
end
def.method("number").SetGangCoffersEndTime = function(self, time)
  self.coffersEndTime = time
end
def.method("number").SetGangWarehouseEndTime = function(self, time)
  self.warehouseEndTime = time
end
def.method("number").SetGangPharmacyEndTime = function(self, time)
  self.pharmacyEndTime = time
end
def.method("number").SetGangBookEndTime = function(self, time)
  self.bookEndTime = time
end
def.method("number").SetGangMoney = function(self, money)
  self.money = money
end
def.method("number").SetGangvitality = function(self, vitality)
  self.vitality = vitality
end
def.method("=>", "number").GetVitality = function(self)
  return self.vitality
end
def.method("number").SetGangTanheEndTime = function(self, time)
  self.tanHeEndTime = time
end
def.method("userdata").SetGangTanheRoleId = function(self, id)
  self.tanHeRoleId = id
end
def.method("number").SetGangXueTuMaxLevel = function(self, xueTuMaxLevel)
  self.xueTuMaxLevel = xueTuMaxLevel
end
def.method("number").SetGangLevel = function(self, level)
  self.level = level
end
def.method("=>", "number").GetGangLevel = function(self)
  return self.level
end
def.method("number").SetWingLevel = function(self, level)
  self.wingLevel = level
end
def.method("=>", "number").GetWingLevel = function(self)
  return self.wingLevel
end
def.method("number").SetBookLevel = function(self, level)
  self.bookLevel = level
end
def.method("=>", "number").GetBookLevel = function(self)
  return self.bookLevel
end
def.method("number").SetCoffersLevel = function(self, level)
  self.coffersLevel = level
end
def.method("=>", "number").GetCoffersLevel = function(self)
  return self.coffersLevel
end
def.method("number").SetWarehouseLevel = function(self, level)
  self.warehouseLevel = level
end
def.method("=>", "number").GetWarehouseLevel = function(self)
  return self.warehouseLevel
end
def.method("number").SetPharmacyLevel = function(self, level)
  self.pharmacyLevel = level
end
def.method("=>", "number").GetPharmacyLevel = function(self)
  return self.pharmacyLevel
end
def.method("number").SetRedeemBangGong = function(self, redeemBangGong)
  self.redeemBangGong_timestamp = GetServerTime()
  self.redeemBangGong = redeemBangGong
end
def.method("=>", "number").GetRedeemBangGong = function(self)
  if not GangData.IsSameWeek(self.redeemBangGong_timestamp) then
    self.redeemBangGong = 0
    self.redeemBangGong_timestamp = GetServerTime()
  end
  return self.redeemBangGong
end
def.method("number").SetYuanBaoRedeemBangGong = function(self, redeemBangGong)
  self.yuanBaoRedeemBangGong_timestamp = GetServerTime()
  self.yuanBaoRedeemBangGong = redeemBangGong
end
def.method("=>", "number").GetYuanBaoRedeemBangGong = function(self)
  if not GangData.IsSameWeek(self.yuanBaoRedeemBangGong_timestamp) then
    self.yuanBaoRedeemBangGong = 0
    self.yuanBaoRedeemBangGong_timestamp = GetServerTime()
  end
  return self.yuanBaoRedeemBangGong
end
def.method("=>", "boolean").GetIsKickedOffline = function(self)
  return self.isKickedOffline
end
def.method("boolean").SetIsKickedOffline = function(self, bKickdedOffline)
  self.isKickedOffline = bKickdedOffline
end
def.method("userdata", "=>", "number").GetJoinTimeByMemberRoleId = function(self, roleId)
  for i, v in pairs(self.memberList) do
    if v.roleId == roleId then
      return GangData.GetJoinDays(v.joinTime)
    end
  end
  return 0
end
def.method("=>", "number").GetHeroJoinTime = function(self)
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId
  return self:GetJoinTimeByMemberRoleId(myId)
end
def.method("userdata", "=>", "number").GetJoinTimestampByMemberRoleId = function(self, roleId)
  for i, v in pairs(self.memberList) do
    if v.roleId == roleId then
      return (v.joinTime / 1000):ToNumber()
    end
  end
  return 0
end
def.method("=>", "number").GetHeroJoinTimestamp = function(self)
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId
  return self:GetJoinTimestampByMemberRoleId(myId)
end
def.method("=>", "number", "number").GetOnlineAndAllBangzhongNum = function(self)
  local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
  local memberList = self:GetMemberList()
  local onlineNum = 0
  local allNum = 0
  for k, v in pairs(memberList) do
    if v.duty ~= xuetuId then
      allNum = allNum + 1
      if v.offlineTime == -1 then
        onlineNum = onlineNum + 1
      end
    end
  end
  return onlineNum, allNum
end
def.method("=>", "number", "number", "number").GetXuetuNumOnlineAllPromote = function(self)
  local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
  local xueTuMaxLevel = self.xueTuMaxLevel
  local memberList = self:GetMemberList()
  local onlineNum = 0
  local allNum = 0
  local promoteNum = 0
  for k, v in pairs(memberList) do
    if v.duty == xuetuId then
      allNum = allNum + 1
      if v.offlineTime == -1 then
        onlineNum = onlineNum + 1
      end
      if v.level == xueTuMaxLevel then
        promoteNum = promoteNum + 1
      end
    end
  end
  return onlineNum, allNum, promoteNum
end
def.method("userdata", "table").SetMemberBangGong = function(self, roleId, info)
  local memberInfo = self:GetMemberInfoByRoleId(roleId)
  if memberInfo ~= nil then
    memberInfo.curBangGong = info.bangGong
    memberInfo.historyBangGong = info.HistoryBangGong
    memberInfo.weekBangGong = info.weekBangGong
    memberInfo.weekItem_banggong_count = info.weekitem_banggong_count
    memberInfo.add_banggong_time = info.add_banggong_time
    memberInfo.item_banggong_time = info.item_banggong_time
  end
end
def.method("=>", "userdata").GetGangId = function(self)
  return self.gangId
end
def.method("=>", "string").GetLastAnnouncementContene = function(self)
  if #self.announcementList > 0 then
    return self.announcementList[1].announcement
  else
    return ""
  end
end
def.method("table").AddGang = function(self, gang)
  table.insert(self.gangList, gang)
end
def.method().SortGangListByGangId = function(self)
  table.sort(self.gangList, function(a, b)
    return a.gangId < b.gangId
  end)
end
def.method("=>", "table").GetGangList = function(self)
  return self.gangList
end
def.method().SetGangListNull = function(self)
  self.gangList = {}
end
def.static("userdata", "=>", "number").TimeToSecond = function(timeInt64)
  if Int64.gt(timeInt64, 0) then
    return Int64.ToNumber(timeInt64) / 1000
  else
    return -1
  end
end
def.static("userdata", "=>", "number").GetForbiddenTalkTime = function(timeInt64)
  if Int64.gt(timeInt64, 0) then
    local time = Int64.ToNumber(timeInt64) / 1000
    if time > GetServerTime() then
      return time
    end
  end
  return 0
end
def.static("userdata", "=>", "number").GetJoinDays = function(timeInt64)
  if Int64.gt(timeInt64, 0) then
    local curTime = GetServerTime()
    local joinTime = timeInt64:ToNumber() / 1000
    if os.date("%Y%m%d", curTime) == os.date("%Y%m%d", joinTime) or curTime < joinTime then
      return 0
    end
    local time = os.date("*t", joinTime + 86400)
    joinTime = os.time({
      year = time.year,
      month = time.month,
      day = time.day,
      hour = 0,
      min = 0,
      sec = 0
    })
    local days = math.floor((curTime - joinTime) / 86400) + 1
    return days
  else
    return 0
  end
end
def.static("userdata", "=>", "number").GetRewardLiHe = function(timeInt64)
  if Int64.gt(timeInt64, 0) then
    local getTime = timeInt64:ToNumber() / 1000
    if GangData.IsSameWeek(getTime) then
      return 1
    end
  end
  return 0
end
def.static("table", "=>", "number").GetWeekBangGong = function(memberInfo)
  local timeInt64 = memberInfo.add_banggong_time
  if Int64.gt(timeInt64, 0) then
    local getTime = timeInt64:ToNumber() / 1000
    if GangData.IsSameWeek(getTime) then
      return memberInfo.weekBangGong
    end
  end
  return 0
end
def.static("table", "=>", "number").GetWeekItemBangGong = function(memberInfo)
  local timeInt64 = memberInfo.item_banggong_time
  if Int64.gt(timeInt64, 0) then
    local getTime = timeInt64:ToNumber() / 1000
    if GangData.IsSameWeek(getTime) then
      return memberInfo.weekItem_banggong_count or 0
    end
  end
  return 0
end
def.static("number", "=>", "boolean").IsSameWeek = function(time)
  local curTime = GetServerTime()
  local getTime = time
  if curTime < getTime then
    local temp = curTime
    curTime = getTime
    getTime = temp
  end
  local timeValue = curTime - getTime
  if timeValue < 604800 then
    local getWeek = tonumber(os.date("%w", getTime))
    local curWeek = tonumber(os.date("%w", curTime))
    if getWeek == 0 then
      getWeek = 7
    end
    if curWeek == 0 then
      curWeek = 7
    end
    if curWeek == getWeek and timeValue < 86400 then
      return true
    end
    if getWeek < curWeek then
      return true
    end
  end
  return false
end
def.method("table").AddMember = function(self, memberInfo)
  local pinyinName = GameUtil.ConvertStringToPY(memberInfo.name)
  memberInfo.pinyinName = pinyinName
  memberInfo.offlineTime = GangData.TimeToSecond(memberInfo.offlineTime)
  memberInfo.forbiddenTalk = GangData.GetForbiddenTalkTime(memberInfo.forbiddenTalk)
  memberInfo.joinDays = GangData.GetJoinDays(memberInfo.joinTime)
  memberInfo.isRewardLiHe = GangData.GetRewardLiHe(memberInfo.getLiHeTime)
  memberInfo.weekBangGong = GangData.GetWeekBangGong(memberInfo)
  memberInfo.weekItem_banggong_count = GangData.GetWeekItemBangGong(memberInfo)
  table.insert(self.memberList, memberInfo)
end
def.method("table").UpdateMember = function(self, memberInfo)
  for k, v in pairs(self.memberList) do
    if v.roleId == memberInfo.roleId then
      v.name = memberInfo.name
      v.level = memberInfo.level
      v.gender = memberInfo.gender
      v.occupationId = memberInfo.occupationId
      v.duty = memberInfo.duty
      v.avatarId = memberInfo.avatarId
      v.avatar_frame = memberInfo.avatar_frame
      v.curBangGong = memberInfo.curBangGong
      v.historyBangGong = memberInfo.historyBangGong
      v.offlineTime = GangData.TimeToSecond(memberInfo.offlineTime)
      v.forbiddenTalk = GangData.GetForbiddenTalkTime(memberInfo.forbiddenTalk)
      v.joinDays = GangData.GetJoinDays(memberInfo.joinTime)
      v.isRewardLiHe = GangData.GetRewardLiHe(memberInfo.getLiHeTime)
      v.weekBangGong = GangData.GetWeekBangGong(memberInfo)
      v.weekItem_banggong_count = GangData.GetWeekItemBangGong(memberInfo)
      local pinyinName = GameUtil.ConvertStringToPY(memberInfo.name)
      v.pinyinName = pinyinName
      v.gongXun = memberInfo.gongXun
    end
  end
  local bangzhuId = GangUtility.GetGangConsts("BANGZHU_ID")
  if memberInfo.duty == bangzhuId then
    self:SetBangzhu(memberInfo.name)
  end
end
def.method("userdata", "number").UpdateMemberGongXunByRoleId = function(self, roleId, gongXun)
  for k, v in pairs(self.memberList) do
    if v.roleId == roleId then
      v.gongXun = gongXun
      return
    end
  end
end
def.method("table").SyncAllMemberGongXun = function(self, roleId2gongxun)
  local gongXunMap = {}
  for k, v in pairs(roleId2gongxun) do
    gongXunMap[k:tostring()] = roleId2gongxun[k]
  end
  for k, v in pairs(self.memberList) do
    v.gongXun = gongXunMap[v.roleId:tostring()]
    if v.gongXun == nil then
      v.gongXun = 0
    end
  end
end
def.method().InitSortMemberList = function(self)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local memberInfo = self:GetMemberInfoByRoleId(heroProp.id)
  self:RemoveMemberByRoleId(heroProp.id)
  local offlineList = {}
  local onineList = {}
  local list = {}
  for k, v in pairs(self.memberList) do
    if v.offlineTime == -1 then
      table.insert(onineList, v)
    else
      table.insert(offlineList, v)
    end
  end
  table.sort(onineList, function(a, b)
    local dutyLvA = GangUtility.GetDutyLv(a.duty)
    local dutyLvB = GangUtility.GetDutyLv(b.duty)
    return dutyLvA < dutyLvB
  end)
  table.sort(offlineList, function(a, b)
    local dutyLvA = GangUtility.GetDutyLv(a.duty)
    local dutyLvB = GangUtility.GetDutyLv(b.duty)
    return dutyLvA < dutyLvB
  end)
  self.memberList = {}
  table.insert(self.memberList, 1, memberInfo)
  for k, v in pairs(onineList) do
    table.insert(self.memberList, v)
  end
  for k, v in pairs(offlineList) do
    table.insert(self.memberList, v)
  end
  self.sortTimesTbl[GangData.SortType.Name] = 0
  self.sortTimesTbl[GangData.SortType.Level] = 0
  self.sortTimesTbl[GangData.SortType.Occupation] = 0
  self.sortTimesTbl[GangData.SortType.Duty] = 0
  self.sortTimesTbl[GangData.SortType.Banggong] = 0
  self.sortTimesTbl[GangData.SortType.Offline] = 0
end
def.method().InitGiftSortMemberList = function(self)
  self.giftSortTimesTbl[GangData.SortType.Name] = 1
  self.giftSortTimesTbl[GangData.SortType.Level] = 1
  self.giftSortTimesTbl[GangData.SortType.Occupation] = 1
  self.giftSortTimesTbl[GangData.SortType.Duty] = 1
  self.giftSortTimesTbl[GangData.SortType.Banggong] = 1
  self.giftSortTimesTbl[GangData.SortType.Offline] = 1
end
def.method("number").AddSortTimes = function(self, type)
  self.sortTimesTbl[type] = self.sortTimesTbl[type] + 1
end
def.method("=>", "table").GetSortTimesTbl = function(self)
  return self.sortTimesTbl
end
def.method("=>", "table").GetGiftSortTimesTbl = function(self)
  return self.giftSortTimesTbl
end
def.method("number").AddGiftSortTimes = function(self, type)
  self.giftSortTimesTbl[type] = self.giftSortTimesTbl[type] + 1
end
def.method("table").SyncApplicants = function(self, applicants)
  self.applierList = {}
  if #applicants == 0 then
    return
  end
  for i = 1, #applicants do
    table.insert(self.applierList, applicants[i])
  end
end
def.method("table").AddApplicant = function(self, applicant)
  table.insert(self.applierList, 1, applicant)
end
def.method("userdata").RemoveApplicantByRoleId = function(self, roleId)
  for k, v in pairs(self.applierList) do
    if v.roleId == roleId then
      table.remove(self.applierList, k)
      return
    end
  end
end
def.method("userdata").RemoveMemberByRoleId = function(self, roleId)
  for k, v in pairs(self.memberList) do
    if v.roleId == roleId then
      table.remove(self.memberList, k)
    end
  end
end
def.method().ClearApplierList = function(self)
  self.applierList = {}
end
def.method("userdata", "=>", "table").GetMemberInfoByRoleId = function(self, roleId)
  for k, v in pairs(self.memberList) do
    if v.roleId == roleId then
      return v
    end
  end
  return nil
end
def.method("string", "=>", "table").GetMemberInfoByRoleName = function(self, roleName)
  for k, v in pairs(self.memberList) do
    if v.name == roleName then
      return v
    end
  end
  return nil
end
def.method("=>", "table").GetMemberList = function(self)
  return self.memberList
end
def.method("=>", "table").GetApplierList = function(self)
  return self.applierList
end
def.method("=>", "string").GetGangName = function(self)
  return self.name
end
def.method("=>", "number").GetGangCreateTime = function(self)
  return self.createTime
end
def.method("number", "=>", "string").GetDutyName = function(self, dutyId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_DUTY_NAME_CFG, self.designDutyNameId)
  local dutyLv = GangUtility.GetDutyLv(dutyId)
  local name = ""
  if record then
    local recItemId = record:GetStructValue("dutyStruct")
    local size = recItemId:GetVectorSize("dutyVector")
    local rec = recItemId:GetVectorValueByIdx("dutyVector", dutyLv - 1)
    if rec then
      name = rec:GetStringValue("dutyName")
    end
  end
  return name
end
def.method("number", "=>", "string").GetDutyNameByLv = function(self, dutyLv)
  return GangUtility.GetDutyNameByDutyLvAndCfgId(self.designDutyNameId, dutyLv)
end
def.method("table", "table").MembersSortByName = function(self, sortTbl, memberTbl)
  local times = sortTbl[GangData.SortType.Name] % 2
  if times == 0 then
    table.sort(memberTbl, function(a, b)
      return a.pinyinName < b.pinyinName
    end)
  elseif times == 1 then
    table.sort(memberTbl, function(a, b)
      return a.pinyinName > b.pinyinName
    end)
  end
end
def.method("table", "table").MembersSortByLevel = function(self, sortTbl, memberTbl)
  local times = sortTbl[GangData.SortType.Level] % 2
  local count = #memberTbl
  if times == 1 then
    for i = 2, count do
      for j = count, i, -1 do
        if memberTbl[j].level > memberTbl[j - 1].level then
          local tmp = memberTbl[j]
          memberTbl[j] = memberTbl[j - 1]
          memberTbl[j - 1] = tmp
        end
      end
    end
  elseif times == 0 then
    for i = 2, count do
      for j = count, i, -1 do
        if memberTbl[j].level < memberTbl[j - 1].level then
          local tmp = memberTbl[j]
          memberTbl[j] = memberTbl[j - 1]
          memberTbl[j - 1] = tmp
        end
      end
    end
  end
end
def.method("table", "table").MembersSortByOccupation = function(self, sortTbl, memberTbl)
  local times = sortTbl[GangData.SortType.Occupation] % 2
  local count = #memberTbl
  if times == 0 then
    for i = 2, count do
      for j = count, i, -1 do
        if memberTbl[j].occupationId > memberTbl[j - 1].occupationId then
          local tmp = memberTbl[j]
          memberTbl[j] = memberTbl[j - 1]
          memberTbl[j - 1] = tmp
        end
      end
    end
  elseif times == 1 then
    for i = 2, count do
      for j = count, i, -1 do
        if memberTbl[j].occupationId < memberTbl[j - 1].occupationId then
          local tmp = memberTbl[j]
          memberTbl[j] = memberTbl[j - 1]
          memberTbl[j - 1] = tmp
        end
      end
    end
  end
end
def.method("table", "table").MembersSortByDuty = function(self, sortTbl, memberTbl)
  local times = sortTbl[GangData.SortType.Duty] % 2
  local count = #memberTbl
  if times == 1 then
    for i = 2, count do
      for j = count, i, -1 do
        local dutyLvA = GangUtility.GetDutyLv(memberTbl[j].duty)
        local dutyLvB = GangUtility.GetDutyLv(memberTbl[j - 1].duty)
        if dutyLvA < dutyLvB then
          local tmp = memberTbl[j]
          memberTbl[j] = memberTbl[j - 1]
          memberTbl[j - 1] = tmp
        end
      end
    end
  elseif times == 0 then
    for i = 2, count do
      for j = count, i, -1 do
        local dutyLvA = GangUtility.GetDutyLv(memberTbl[j].duty)
        local dutyLvB = GangUtility.GetDutyLv(memberTbl[j - 1].duty)
        if dutyLvA > dutyLvB then
          local tmp = memberTbl[j]
          memberTbl[j] = memberTbl[j - 1]
          memberTbl[j - 1] = tmp
        end
      end
    end
  end
end
def.method("table", "table").MembersSortByBanggong = function(self, sortTbl, memberTbl)
  local times = sortTbl[GangData.SortType.Banggong] % 2
  local count = #memberTbl
  if times == 1 then
    for i = 2, count do
      for j = count, i, -1 do
        if memberTbl[j].historyBangGong > memberTbl[j - 1].historyBangGong then
          local tmp = memberTbl[j]
          memberTbl[j] = memberTbl[j - 1]
          memberTbl[j - 1] = tmp
        end
      end
    end
  elseif times == 0 then
    for i = 2, count do
      for j = count, i, -1 do
        if memberTbl[j].historyBangGong < memberTbl[j - 1].historyBangGong then
          local tmp = memberTbl[j]
          memberTbl[j] = memberTbl[j - 1]
          memberTbl[j - 1] = tmp
        end
      end
    end
  end
end
def.method("table", "table").MembersSortByOfflineTime = function(self, sortTbl, memberTbl)
  local offlineList = {}
  local onineList = {}
  local list = {}
  for k, v in pairs(memberTbl) do
    if v.offlineTime == -1 then
      table.insert(onineList, v)
    else
      table.insert(offlineList, v)
    end
  end
  local times = sortTbl[GangData.SortType.Offline] % 2
  if times == 1 then
    local count = #offlineList
    table.sort(offlineList, function(a, b)
      return a.offlineTime > b.offlineTime
    end)
    for k, v in pairs(onineList) do
      table.insert(list, v)
    end
    for k, v in pairs(offlineList) do
      table.insert(list, v)
    end
  elseif times == 0 then
    table.sort(offlineList, function(a, b)
      return a.offlineTime < b.offlineTime
    end)
    for k, v in pairs(offlineList) do
      table.insert(list, v)
    end
    for k, v in pairs(onineList) do
      table.insert(list, v)
    end
  end
  self.memberList = list
end
def.method("userdata", "number").SetMemberOffline = function(self, roleId, time)
  local memberInfo = self:GetMemberInfoByRoleId(roleId)
  if memberInfo then
    memberInfo.offlineTime = time
  end
end
def.method("=>", "boolean").GetIsBuildNotStart = function(self)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local bNotStart = gangInfo.buildEndTime <= 0 and 0 >= gangInfo.wingEndTime and 0 >= gangInfo.coffersEndTime and 0 >= gangInfo.pharmacyEndTime and 0 >= gangInfo.warehouseEndTime and 0 >= gangInfo.bookEndTime
  return bNotStart
end
def.method("=>", "number").GetMaintainCost = function(self)
  local gangInfo = self:GetGangBasicInfo()
  local gangTbl = GangUtility.GetGangCfg(gangInfo.level)
  local wingTbl = GangUtility.GetWingGangBasicCfg(gangInfo.wingLevel)
  local coffersTbl = GangUtility.GetCoffersGangBasicCfg(gangInfo.coffersLevel)
  local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
  local warehouseTbl = GangUtility.GetWarehouseGangBasicCfg(gangInfo.warehouseLevel)
  local bookTbl = GangUtility.GetBookGangBasicCfg(gangInfo.bookLevel)
  if nil == gangTbl or nil == wingTbl or nil == coffersTbl or nil == pharmacyTbl or nil == warehouseTbl or nil == bookTbl then
    return 0
  end
  local costMoney = gangTbl.maintainCostMoneyPerDay + wingTbl.maintainCostMoneyPerDay + coffersTbl.maintainCostMoneyPerDay + pharmacyTbl.maintainCostMoneyPerDay + warehouseTbl.maintainCostMoneyPerDay + bookTbl.maintainCostMoneyPerDay
  return costMoney
end
def.method("number", "userdata", "string").SetCombineGangInfo = function(self, time, gangid, gangname)
  local mergeInfo = self.mergeInfo
  mergeInfo.applyEndTime = time
  mergeInfo.targetGangId = gangid
  if gangid then
    if gangname ~= "" then
      mergeInfo.targetGaneName = gangname
    end
  else
    mergeInfo.targetGaneName = ""
  end
end
def.method("=>", "table").GetCombineGangInfo = function(self)
  return self.mergeInfo
end
def.method("userdata").SetCombineApplyGangId = function(self, gangid)
  self.mergeInfo.applyGangId = gangid
end
def.method("=>", "number").GetCombineGangStatus = function(self)
  if self.mergeInfo then
    local time = self.mergeInfo.applyEndTime or -1
    if time > 0 then
      local curTime = GetServerTime()
      if time > curTime then
        return 1
      else
        return 2
      end
    end
  end
  return 0
end
def.method("=>", "boolean").IsBeCombineGang = function(self)
  local status = self:GetCombineGangStatus()
  if status == 1 then
    return true
  elseif status == 2 then
    local selfGangId = self.gangId
    local applyGangId = self.mergeInfo.applyGangId
    if applyGangId and Int64.eq(selfGangId, applyGangId) then
      return true
    end
  end
  return false
end
def.method("boolean").SetHaveGangMergeApply = function(self, haveApply)
  self.mergeInfo.haveApply = haveApply
end
def.method("=>", "boolean").IsHaveGangMergeApply = function(self)
  if self.mergeInfo.haveApply then
    return true
  end
  return false
end
def.method("boolean").SetNewGangNotice = function(self, new)
  self.newGangNotice = new
end
def.method("=>", "boolean").IsHaveNewGangNotice = function(self)
  if self.newGangNotice then
    return true
  end
  return false
end
def.method("userdata", "string").SaveGangName = function(self, gangid, gangname)
  local savename = self.mergeInfo.savename
  if not savename then
    savename = {}
    self.mergeInfo.savename = savename
  end
  local key = tostring(gangid)
  savename[key] = gangname
end
def.method("userdata", "=>", "string").GetSaveGangName = function(self, gangid)
  local savename = self.mergeInfo.savename
  if savename then
    local key = tostring(gangid)
    return savename[key] or ""
  end
  return ""
end
GangData.Commit()
return GangData
