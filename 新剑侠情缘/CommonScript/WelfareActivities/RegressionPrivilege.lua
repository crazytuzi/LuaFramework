RegressionPrivilege.GROUP = 61

RegressionPrivilege.TOTAL_RECHARGE  = 1 --充值总数，老玩家回新服使用
RegressionPrivilege.GAINED_MAXLEVEL = 2 --礼包已经领取的等级，老玩家回新服使用

--基础数值，每次重置
RegressionPrivilege.BEGIN_TIME       = 3
RegressionPrivilege.ITEM_USED_FLAG   = 4
RegressionPrivilege.OUTLINE_DAY      = 5
RegressionPrivilege.ACTIVITY_TRIGGER = 6
RegressionPrivilege.NEW_VERSION      = 22 --新版本功能标识
RegressionPrivilege.LOCK_OUTDAY      = 44 --冻结特权期间离线天数

--回归特权
RegressionPrivilege.KINDONATE_TIMES       = 8 --捐献次数
RegressionPrivilege.KINDONATE_TIMES_MAX   = 9 --捐献次数
RegressionPrivilege.REFRESHSHOP_TIMES     = 10 --重置商城折扣
RegressionPrivilege.REFRESHSHOP_TIMES_MAX = 11 --重置商城折扣
RegressionPrivilege.GIFTBOX_TIMES         = 12 --家族礼盒次数
RegressionPrivilege.GIFTBOX_TIMES_MAX     = 13 --家族礼盒次数
RegressionPrivilege.CHUANGONG_TIMES       = 14 --传功次数
RegressionPrivilege.CHUANGONG_TIMES_MAX   = 15 --传功次数
RegressionPrivilege.XIULIAN_TIMES         = 16 --修炼时间
RegressionPrivilege.XIULIAN_TIMES_MAX     = 17 --修炼时间
RegressionPrivilege.MONEYTREE_TIMES       = 18
RegressionPrivilege.MONEYTREE_TIMES_MAX   = 19
RegressionPrivilege.TIANJIAN_FLAG         = 20 --打折天剑令标志
RegressionPrivilege.PAUSE_FLAG            = 21 --暂停特权标志
RegressionPrivilege.KINSTORE_TIMES        = 35 --珍宝坊重置
RegressionPrivilege.KINSTORE_TIMES_MAX    = 36
RegressionPrivilege.YUANQI_AWARD          = 43 --触发特权时玩家能拿到的元气值


--免费领取
RegressionPrivilege.OLD_VIPLEVEL       = 7
RegressionPrivilege.FREE_GAIN          = 23
-----------------标志位位置-----------------
RegressionPrivilege.HONOR_TITLE        = 1
RegressionPrivilege.YINLIANG_CHOUJIANG = 2
RegressionPrivilege.YUANBAO_CHOUJIANG  = 3
RegressionPrivilege.XIUWEI             = 4
RegressionPrivilege.YUANQI             = 5
RegressionPrivilege.WAIZHUANG          = 6
RegressionPrivilege.CHONGZHI           = 7
--------------------------------------------
-- 免费领取对应的奖励
RegressionPrivilege.FREE_GAIN_ITEM        = {{"Item", 2708, 1},         --回归称号
                                             {"Item", 2760, 1},         --银两抽卡招募令
                                             {"Item", 3526, 1},         --元宝抽卡招募令
                                             {"SkillExp", 360},         --修为
                                             {"Energy", 1},             --元气
                                             {"Item", 4759, 1},         --限时门派外装挑选礼盒
                                             {"Item", 3564, 1},}         --双倍重置令

RegressionPrivilege.DOUBLE_ACT            = {
    Boss                                  = {nSaveKey = 24, nMaxSaveKey = 37, nDayPer = 2.5, szMsg = "(回归特权额外获得[FFFE0D]%d贡献[-])",
                                             tbUiInfo = {szTitle = "武林盟主奖励翻倍", szContent = "武林盟主单人奖励贡献翻倍", szBtnContent = "查看活动", bCloseMyself = true, szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 1]"}},
    CommerceTask                          = {nSaveKey = 25, nMaxSaveKey = 38, nDayPer = 5, szMsg = "商会任务回归特权额外奖励",
                                             tbUiInfo = {szTitle = "商会任务奖励翻倍", szContent = "商会任务奖励的银两及藏宝图或卷轴奖励加倍", szBtnContent = "查看活动", bCloseMyself = true, szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 2]"}},
    HeroChallenge                         = {nSaveKey = 26, nMaxSaveKey = 39, nDayPer = 0.5, szMsg = "英雄挑战回归特权额外奖励",
                                             tbUiInfo = {szTitle = "英雄挑战奖励翻倍", szContent = "英雄挑战每次挑战获得两次随机奖励", szBtnContent = "查看活动", bCloseMyself = true, szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 23]"}},
    KinGather                             = {nSaveKey = 27, nMaxSaveKey = 40, nDayPer = 1.25, szMsg = "家族答题回归特权额外奖励",
                                             tbUiInfo = {szTitle = "烤火答题奖励翻倍", szContent = "家族烤火答题时获得双倍贡献", szBtnContent = "查看活动", bCloseMyself = true, szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 18]"}},
    RankBattle                            = {nSaveKey = 28, nMaxSaveKey = 41, nDayPer = 5, szMsg = "武神殿回归特权额外奖励",
                                             tbUiInfo = {szTitle = "武神殿奖励翻倍", szContent = "武神殿领取奖励时额外获得一个同样的武神宝箱", szBtnContent = "查看活动", bCloseMyself = true, szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 9]"}},
}
RegressionPrivilege.DayTargetEXT          = {nSaveKey = 29, nMaxSaveKey = 42, nDayPer = 1,
                                             tbUiInfo = {szTitle = "每日目标额外奖励", szContent = "完成每日目标可额外获得大量经验、银两、贡献奖励", szBtnContent = "前去查看", bCloseMyself = true, szBtnUrl = "[url=openwnd:test, CalendarPanel, 3]"}}


--充值特权
RegressionPrivilege.RECHARGE_AWARD        = { --充值额外奖励（nSaveKey不能修改）
	{ nSaveKey = 30, nShowPro = 2, nDayPer = 3,  nRechargeIdx = 1, szContent = "$0.99回归元宝礼包"},
	{ nSaveKey = 31, nShowPro = 1, nDayPer = 30, nRechargeIdx = 2, szContent = "$4.99回归元宝礼包"},
	{ nSaveKey = 32, nShowPro = 5, nDayPer = 6,  nRechargeIdx = 3, szContent = "$3.99超值回归礼包"},
	{ nSaveKey = 33, nShowPro = 4, nDayPer = 2,  nRechargeIdx = 4, szContent = "$5.99超值福利礼包"},
	{ nSaveKey = 34, nShowPro = 3, nDayPer = 4,  nRechargeIdx = 5, szContent = "$14.99超值豪华礼包"},
}

Require("CommonScript/Recharge/Recharge.lua")
if Recharge.tbSettingGroup.BackGift ~= nil then
	for _, tbInfo in ipairs(RegressionPrivilege.RECHARGE_AWARD) do
		tbInfo.nMoney = Recharge.tbSettingGroup.BackGift[tbInfo.nRechargeIdx].nMoney
		tbInfo.tbAward = Recharge.tbSettingGroup.BackGift[tbInfo.nRechargeIdx].tbAward
	end
end

local DAY_SEC = 24*3600
RegressionPrivilege.Privilege_Time  = 30*DAY_SEC --特权有效时间
RegressionPrivilege.Privilege_CD    = 60*DAY_SEC --回流CD，从上次特权开始时算起
RegressionPrivilege.Outline_Days    = 10    --离线天数，必须大于等于该等级才算回归
RegressionPrivilege.Max_OutlineDays = 150 --最大离线天数
RegressionPrivilege.Privilege_Lv    = 55 --符合回流玩家的最低等级

RegressionPrivilege.nClearItemVipLv = 4 --双倍重置令需要vip等级
RegressionPrivilege.nRechargeVipLv = 5
RegressionPrivilege.LvUp_VipLv = 6 --到达该VIP等级可以免费获得直升令
RegressionPrivilege.tbTianJian = {nCanBuyDay = 20, nItemTID = 2682, nPrice = 1500, nOriginalPrice = 5000} --打折天剑令
RegressionPrivilege.nDoubleCZLDay = 20 --双倍重置令需要离线这么多天才能领取

RegressionPrivilege.LEVEL_GOLD_ITEM_ID = 2854 --新服符合条件返回金币道具ID
RegressionPrivilege.LEVEL_GIFT_ITEM_ID = 2855 --等级礼包
RegressionPrivilege.tbEnergy = {
    {6, 2000},
    {7, 2200},
    {8, 2800},
    {11, 4000},
    {14, 5200},
    {999, 6000},
}
RegressionPrivilege.tbDayTargetAward = {
    {{"BasicExp", 30}, {"Coin", 2000}, {"Contrib", 200}},
    {{"BasicExp", 30}, {"Coin", 4000}, {"Contrib", 400}},
    {{"BasicExp", 30}, {"Coin", 6000}, {"Contrib", 600}},
    {{"BasicExp", 30}, {"Coin", 8000}, {"Contrib", 800}},
    {{"BasicExp", 30}, {"Coin", 10000}, {"Contrib", 1000}},
}

RegressionPrivilege.tbNoCdTime = {nStart = Lib:ParseDateTime("2017/9/7"), nEnd = Lib:ParseDateTime("2017/9/27")}

function RegressionPrivilege:IsCloseMarketStall(pPlayer)
    if not Activity:__IsActInProcessByType("NewServerPrivilege") then
        return
    end

    return self:IsTriggerByAct(pPlayer), "摆摊暂时关闭，请领取老玩家回归特权"
end

function RegressionPrivilege:IsInPrivilegeTime(pPlayer)
    local nPrivilegeEndTime = self:GetPrivilegeTime(pPlayer)
    return nPrivilegeEndTime > GetTime()
end

function RegressionPrivilege:IsNewVersionPlayer(pPlayer)
    return pPlayer.GetUserValue(self.GROUP, self.NEW_VERSION) > 0
end

function RegressionPrivilege:GetPrivilegeTime(pPlayer)
    return pPlayer.GetUserValue(self.GROUP, self.BEGIN_TIME) + self.Privilege_Time
end

function RegressionPrivilege:IsTriggerByAct(pPlayer)
    return pPlayer.GetUserValue(self.GROUP, self.ACTIVITY_TRIGGER) > 0 and pPlayer.GetUserValue(self.GROUP, self.ITEM_USED_FLAG) <= 0
end

function RegressionPrivilege:GetEnergy(nVip, nOutday)
    local nEnergy = 0
    if GetTimeFrameState("OpenLevel69") ~= 1 then
        return nEnergy
    end

    local nTimeFrameOpenDay = TimeFrame:CalcRealOpenDay("OpenLevel69");
    local nOpenDay = Lib:GetServerOpenDay()
    nOpenDay = math.max(0, nOpenDay - nTimeFrameOpenDay);
    for _, tbInfo in ipairs(self.tbEnergy) do
        if nVip <= tbInfo[1] then
            nEnergy = tbInfo[2]
            break
        end
    end
    nEnergy = nEnergy * 0.6 * math.min(90, nOpenDay, nOutday)
    return math.floor(nEnergy)
end

--免费领取
function RegressionPrivilege:CheckFreeGain(pPlayer, nId)
    local nFreeGain = pPlayer.GetUserValue(self.GROUP, self.FREE_GAIN)
    local nFlag = KLib.GetBit(nFreeGain, nId)
    return nFlag == 0
end

function RegressionPrivilege:CheckFreeGainExt(pPlayer, nId)
    if nId == self.WAIZHUANG then
        if pPlayer.GetUserValue(self.GROUP, self.OLD_VIPLEVEL) < self.nClearItemVipLv then
            return false, string.format("需达到VIP%d才可领取", self.nClearItemVipLv)
        end
    elseif nId == self.YUANQI then
        return pPlayer.GetUserValue(self.GROUP, self.YUANQI_AWARD) > 0, "尚未开放"
    elseif nId == self.CHONGZHI then
        return pPlayer.GetUserValue(self.GROUP, self.OUTLINE_DAY) >= self.nDoubleCZLDay
    end
    return true
end

function RegressionPrivilege:GetFreeGainAward(pPlayer, nId)
    local tbAward = {unpack(self.FREE_GAIN_ITEM[nId])}
    local nCountPos = #tbAward
    local nOutlineDay = pPlayer.GetUserValue(self.GROUP, self.OUTLINE_DAY)
    if nId == self.YINLIANG_CHOUJIANG or nId == self.XIUWEI then
        tbAward[nCountPos] = tbAward[nCountPos]*nOutlineDay
    elseif nId == self.YUANBAO_CHOUJIANG then
        tbAward[nCountPos] = tbAward[nCountPos]*math.ceil(nOutlineDay/3)
    elseif nId == self.YUANQI then
        tbAward[nCountPos] = pPlayer.GetUserValue(self.GROUP, self.YUANQI_AWARD)
    end
    if Player.AwardType[tbAward[1]] == Player.award_type_item then
        tbAward[4] = self:GetPrivilegeTime(pPlayer)
    end
    return {tbAward}
end

function RegressionPrivilege:GetChuanGongTimes(pPlayer)
    if not self:IsInPrivilegeTime(pPlayer) then
        return 0
    end

    if self:IsTriggerByAct(pPlayer) then
        return 0
    end

    return pPlayer.GetUserValue(self.GROUP, self.CHUANGONG_TIMES)
end

function RegressionPrivilege:IsShowGrowInvest(pPlayer)
    if not self:IsInPrivilegeTime(pPlayer) or not self:IsNewVersionPlayer(pPlayer) or pPlayer.GetVipLevel() < self.nRechargeVipLv then
        return
    end

    local nBeginDay = Lib:GetLocalDay(pPlayer.GetUserValue(self.GROUP, self.BEGIN_TIME))
    if Lib:GetLocalDay() - nBeginDay <= 0 then
        return
    end

    return true
end

if MODULE_GAMESERVER then
    return
end

-------------------client-------------------
function RegressionPrivilege:OnLogin()
    MarketStall:RegisterCheckOpen("RegressionPrivilege", function(pPlayer)
        local bRet, szMsg = self:IsCloseMarketStall(pPlayer)
        return not bRet, szMsg
    end)
end

function RegressionPrivilege:OnBuyCallBack()
    UiNotify.OnNotify(UiNotify.emNOTIFY_PRIVILEGE_CALLBACK)
end

function RegressionPrivilege:IsShowButton()
    if self:IsInPrivilegeTime(me) then
        return true
    end

    return Activity:__IsActInProcessByType("NewServerPrivilege") and (self:IsTriggerByAct(me) or self.bGotoNewServer)
end

function RegressionPrivilege:GetDayTargetAward(nIdx)
    if not self:IsInPrivilegeTime(me) then
        return
    end

    if not self:IsNewVersionPlayer(me) then
        return
    end

    if me.GetUserValue(self.GROUP, self.DayTargetEXT.nSaveKey) <= 0 then
        return
    end

    local tbAward = self.tbDayTargetAward[nIdx]
    return tbAward
end

function RegressionPrivilege:OnPlayerGotoNewServer()
    self.bGotoNewServer = true
end

function RegressionPrivilege:OnLogout()
    self.bGotoNewServer = nil
end
