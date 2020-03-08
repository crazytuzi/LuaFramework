Require("Script/Ui/Logic/Notify.lua")

function WelfareActivity:Init()
    self.tbActivity = Lib:LoadTabFile("Setting/WelfareActivity/Activity.tab", { nLevelMin = 0, nLevelMax = 0, bActive = 0 })
    assert(self.tbActivity, "[WelfareActivity LoadSetting] LoadFile Fail")

    for _, tbInfo in ipairs(self.tbActivity) do
        local szRedPoint = "Activity_" .. tbInfo.szKey
        tbInfo.szRedPointKey = Ui.tbRedPoint[szRedPoint] and szRedPoint or ""
    end
end

function WelfareActivity:AddLocalActivity(tbInfo)
    if not tbInfo.szKey or not tbInfo.szName then
        Log("Error", "AddLocalActivity Failed Need Key and Name Param")
        return
    end
    for _, tbExistInfo in pairs( self.tbActivity ) do
        if tbExistInfo.szKey == tbInfo.szKey then
            Log("Error", "AddLocalActivity Exist Key", tbExistInfo.szKey)
            return
        end
    end
    local szRedPoint = "Activity_" .. tbInfo.szKey
    tbInfo.nLevelMin =  tbInfo.nLevelMin or 0
    tbInfo.nLevelMax = tbInfo.nLevelMax or 0
    tbInfo.szRedPointKey = Ui.tbRedPoint[szRedPoint] and szRedPoint or ""
    table.insert(self.tbActivity, tbInfo)
end

local tbActiveFunc = {
    GrowInvest = function ()
        --if Client:IsCloseIOSEntry() then
        --    return false
        --end
        return Recharge:IsShowGrowInvest()
    end;

    RechargeInstruction = function ()
        return true;
    end;

    RechargeGift = function ()
        return Recharge:IsShowProGroupInPanel("DaysCard", "RechargeGift")
    end;

    DailyRechargeGift = function ()
        return Recharge:IsShowProGroupInPanel("DayGift", "DailyRechargeGift")
    end;

    FirstRecharge = function (self)
        return self.bShowFirstRecharge
    end;
    OnHook = function ()
        return OnHook:IsOpen(me)
    end;
    SupplementPanel = function ()
        return SupplementAward:IsShowUi()
    end;
    QQVipPrivilege = function ()
        return Sdk:ShowQQVipPrivilege();
    end;
    SummerGift = function ()
        local nCurIdx = SummerGift:GetCurDayIndex()
        return nCurIdx > 0 and nCurIdx <= (SummerGift.nActAltDay + SummerGift.nGetGiftDay)
    end;
    BuyLevelUp = function ()
        return DirectLevelUp:CheckShowPanel()
    end;
    NewYearBuyGift = function ()
        return Activity:__IsActInProcessByType("RechargeNewYearBuyGift")
    end;
    StrengthenUpGift = function ()
        local tbProds = Recharge:GetCanBuyDirectEnhanceProds()
        if not next(tbProds) then
            return false
        end
        return true;
    end;
    fnCheckShowPandora = function (self, tbInfo)
        return Pandora:IsShowIcon("WelfareActivity", tbInfo.szKey)
    end;
    FriendInvitationGift = function (self)
        return Sdk:IsQQInviteFriendActOn() and Sdk:IsLoginByQQ();
    end;
    PresentBoxPanel = function ( self )
        return Activity.RechargeSumOpenBox:IsShowUi( )
    end;
    WuXunMiLingpanel = function ()
        --return Activity.tbSecretCard:CheckCanJoin(me)
    end;
}

WelfareActivity.tbCheckRedPoint =
{
     OnHook = function ()
         --  OnHook:RefreshRedPoint()
    end;

    fnPandoraCheckRp = function (tbInfo)
        if Pandora:IsShowRedPoint("WelfareActivity", tbInfo.szKey) then
            Ui:SetRedPointNotify(tbInfo.szRedPoint)
        else
            Ui:ClearRedPointNotify(tbInfo.szRedPoint)
        end
    end;

    WuXunMiLingpanel = function ()
        --Activity.tbSecretCard:CheckRedPoint()
    end;
}

local tbShowNewFlagIconFunc = {
    GrowInvest = function ()
        return Recharge:IsShowGrowInvestAct()
    end;
    NewYearBuyGift = function ()
        return true
    end;
    WuXunMiLingpanel = function ()
        return true
    end;
    PresentBoxPanel = function ()
        return true
    end;

    fnCheckPandoraWelfareNewIcon = function ()
        return true
    end;
    -- SupplementPanel = function ()
    --     local nDiscount = SupplementAward:GetDiscount()
    --     return nDiscount < 1
    -- end;
};

WelfareActivity.tbSpecialNameFunc =
{
    GrowInvest = function (tbInfo)
        local nGroup = Recharge:GetAutoShowGrowInvest()
        if not nGroup then
            return
        end
        tbInfo.szName = Recharge.tbSettingGroup.GrowInvest[nGroup].szDesc
    end;
    NewYearBuyGift = function (tbInfo)
        --tbInfo.szName = Recharge.tbNewYearBuyGiftActSetting.RechargeNewYearBuyGift.szNameInPanel
        tbInfo.szName = Recharge.tbNewYearBuyGiftActSetting.szNameInPanel
    end;

}

WelfareActivity.tbClickFunc = {
    fnClickPandora = function (tbInfo)
        Pandora:Open("WelfareActivity", tbInfo.szKey)
    end,
}

WelfareActivity.tbSwitchFunc = {
    fnSwitchPandora = function (tbInfo)
        Pandora:Hide("WelfareActivity", tbInfo.szKey)
    end,
}

function WelfareActivity:OnClickTab(tbInfo)
    if not tbInfo or  not tbInfo.szClickFunc then
        return
    end

    local fnClick = self.tbClickFunc[tbInfo.szClickFunc]

    if fnClick then
        fnClick(tbInfo)
    end
end

function WelfareActivity:OnSwitchTab(tbInfo)
     if not tbInfo or  not tbInfo.szSwitchFunc then
        return
    end

    local fnSwitch = self.tbSwitchFunc[tbInfo.szSwitchFunc]

    if fnSwitch then
        fnSwitch(tbInfo)
    end
end

function WelfareActivity:GetActivityList()
    local tbActiveList = {};
    local nSort = 1000
    for _, tbInfo in pairs(self.tbActivity) do
        local nLevelMin   = tbInfo.nLevelMin;
        local nLevelMax   = tbInfo.nLevelMax;
        local bLevelLegal = (nLevelMin <= 0 or me.nLevel >= nLevelMin) and (nLevelMax <= 0 or me.nLevel <= nLevelMax);

        local fnActive = tbActiveFunc[tbInfo.szCheckShowFunc or tbInfo.szKey]
        local bActive  = not fnActive or fnActive(self, tbInfo)
        if bLevelLegal and bActive then
            local fnShowFlogFunc = tbShowNewFlagIconFunc[tbInfo.szCheckNewIconFunc or tbInfo.szKey]
            local bShowNewIcon = fnShowFlogFunc and fnShowFlogFunc(self, tbInfo) or false
            tbInfo.bShowNewIcon = bShowNewIcon
            nSort = nSort - 1;
            tbInfo.nSort = nSort + (bShowNewIcon and 10000 or 0)
            local fnpecialNameFunc = self.tbSpecialNameFunc[tbInfo.szKey]
            if fnpecialNameFunc then
                fnpecialNameFunc(tbInfo)
            end
            table.insert(tbActiveList, tbInfo)
        end
    end

    table.sort(tbActiveList, function (a, b)
        return a.nSort >  b.nSort
    end )

    return tbActiveList
end

function WelfareActivity:GetAllActivityKey()
    local tbKey = {}
    for _, tbInfo in pairs(self.tbActivity) do
        table.insert(tbKey, tbInfo.szKey)
    end
    return tbKey
end

function WelfareActivity:GetActivityOpenLevel(szKey)
    for _, tbInfo in pairs(self.tbActivity) do
        if szKey == tbInfo.szKey then
            return tbInfo.nLevelMin
        end
    end
end

function WelfareActivity:OnLogin(bReconnect)
    self:CheckAllActRP()
    local tbData = Client:GetUserInfo("WelfareActivity")
    if not tbData.nDayLoginTime or Lib:IsDiffDay(0, tbData.nDayLoginTime) then
        tbData.nDayLoginTime = GetTime()
        tbData.bDayFirstLogin = true
    else
        tbData.bDayFirstLogin = false
    end
    Client:SaveUserInfo()

    local bGetFirstRecharge = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE) == 1
    self.bShowFirstRecharge = not bGetFirstRecharge

    RegressionPrivilege:OnLogin()
    FriendRecall:OnLogin(bReconnect)
end

function WelfareActivity:OnLogout()
    FriendRecall:OnLogout();
    Activity.BeautyPageant:OnLogout();
    Activity.KinElect:OnLogout();
end

function WelfareActivity:IsDayFirstLogin()
    local tbData = Client:GetUserInfo("WelfareActivity")
    return tbData.bDayFirstLogin
end

function WelfareActivity:ClearFirstLogin()
    local tbData = Client:GetUserInfo("WelfareActivity")
    tbData.bDayFirstLogin = false
end

function WelfareActivity:OnLevelUp()
    self:CheckAllActRP()
end

function WelfareActivity:CheckAllActRP()
    for _, tbInfo in pairs(self.tbActivity) do
        if not Lib:IsEmptyStr(tbInfo.szRedPointKey) and me.nLevel < tbInfo.nLevelMin then
            Ui:ClearRedPointNotify(tbInfo.szRedPointKey)
        end
    end

    SignInAwards:CheckRedPoint()
    LoginAwards:CheckRedPoint()
    Recharge:CheckRedPoint()
    JuBaoPen:CheckRedPoint();
    MoneyTree:CheckRedPoint()
    SupplementAward:CheckRedPoint()
    SummerGift:CheckRedPoint()
    --Activity.RechargeSumOpenBox:CheckRedPoint()
end

WelfareActivity:Init()

--------------------------签到--------------------------
function SignInAwards:OnGetAwardsCallback(szMsg)
    UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "SignInAwards");
    me.CenterMsg(szMsg);
    self:CheckRedPoint()
end

function SignInAwards:OnLogin()
    self:CheckRedPoint()
end

function SignInAwards:OnNewDayBegin()
    self:CheckRedPoint()
    UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "SignInAwards")
end

function SignInAwards:CheckRedPoint()
    local nOpenLevel   = WelfareActivity:GetActivityOpenLevel("SignInAwards")
    local bLevelEnough = me.nLevel >= nOpenLevel
    if bLevelEnough and self:CanGainAwards() then
        Ui:SetRedPointNotify("Act_Sign")
    else
        Ui:ClearRedPointNotify("Act_Sign")
    end

end

function SignInAwards:CanGainAwards()
    local nLoginDay = me.GetUserValue(SignInAwards.SIGNIN_AWARD_GROUP, SignInAwards.LOGIN_DAYS);
    for i = 1, nLoginDay do
        if self:CheckState(i) then
            return true;
        end
    end
    return false;
end

function SignInAwards:CheckState(nDayIdx)
    local bGetAvailable, bMark;
    local nFlag         = me.GetUserValue(SignInAwards.SIGNIN_AWARD_GROUP, SignInAwards.NORMAL_FLAG);
    local nToday        = me.GetUserValue(SignInAwards.SIGNIN_AWARD_GROUP, SignInAwards.LOGIN_DAYS);
    local tbAwardsInfo  = SignInAwards:GetAwardInfo(nDayIdx);
    local bToday        = (nDayIdx == nToday);

    if nDayIdx <= nToday then
        if  Lib:LoadBits(nFlag, nDayIdx - 1, nDayIdx - 1) == 0 or
            (bToday and tbAwardsInfo.nVipLevel > 0 and me.GetVipLevel() >= tbAwardsInfo.nVipLevel and
            tbAwardsInfo.nVipLevel > me.GetUserValue(SignInAwards.SIGNIN_AWARD_GROUP, SignInAwards.VIPLEVEL_ONGET)) then --补领当天双倍奖励，非当天vip奖励无法补领
            bGetAvailable = true;
        else
            bMark = true;
        end
    end
    return bGetAvailable, bToday, bMark;
end

--------------------------登陆奖励--------------------------
function LoginAwards:OnLogin()
    self:Init()
    self:CheckRedPoint()
end

function LoginAwards:OnDataRefresh()
    self:CheckRedPoint()
end

function LoginAwards:CheckRedPoint()
    if self:IsActivityActive() and self:HasAwardCanGet() then
        Ui:SetRedPointNotify("Activity_Login")
    else
        Ui:ClearRedPointNotify("Activity_Login")
    end
end

function LoginAwards:OnGetAwardsCallback(szMsg)
    self:OnDataChange()
    me.CenterMsg(szMsg);
    self:CheckRedPoint()
end

function LoginAwards:LoadActSetting(szPath, nBeginTime)
    self.nActBeginTime = nBeginTime
    if self.tbActSetting then
        return self.tbActSetting
    end

    self.tbActSetting = {}
    local tbFile = Lib:LoadTabFile(szPath, {nResId = 1, nCostGold = 1})
    for _, tbInfo in ipairs(tbFile) do
        tbInfo.tbAward = Lib:GetAwardFromString(tbInfo.szAward)
        table.insert(self.tbActSetting, tbInfo)
    end
end

function LoginAwards:OnGetActAwardsCallback(nDayIdx)
    self:OnDataChange()
    if not self.tbActSetting then
        return
    end
    local tbInfo = self.tbActSetting[nDayIdx]
    Ui:OpenWindow("LoginActNpcPanel", tbInfo.nResId, tbInfo.szContent)
end

function LoginAwards:OnDataChange()
    UiNotify.OnNotify(UiNotify.emNOTIFY_LOGINAWARDS_CALLBACK)
    Activity:CheckRedPoint()
end

function LoginAwards:IsActivityActive()
    if me.nLevel < self.SHOW_LEVEL then
        return false
    end

    local nMaxDay = self:GetActLen()
    local nDay    = me.GetUserValue(self.LOGIN_AWARDS_GROUP, self.LOGIN_DAYS)
    local nFlag   = me.GetUserValue(self.LOGIN_AWARDS_GROUP, self.RECEIVE_FLAG)
    local nTime   = me.GetUserValue(self.LOGIN_AWARDS_GROUP, self.LAST_LOGIN_TIME)
    if nDay < nMaxDay then
        return true
    else
        for nIdx = 1, nMaxDay do
            local nDayFlag = Lib:LoadBits(nFlag, nIdx - 1, nIdx - 1);
            if nDayFlag == 0 then
                return true
            end
        end

        if not Lib:IsDiffDay(self.REFRESH_TIME, nTime) then
            return true
        end

        return false
    end
end

function LoginAwards:HasAwardCanGet()
    local nFlag = me.GetUserValue(self.LOGIN_AWARDS_GROUP, self.RECEIVE_FLAG)
    local nMaxDays = self:GetActLen()
    local nDay = math.min(me.GetUserValue(LoginAwards.LOGIN_AWARDS_GROUP, LoginAwards.LOGIN_DAYS), nMaxDays)
    for nIdx = 1, nDay do
        if Lib:LoadBits(nFlag, nIdx - 1, nIdx - 1) == 0 then
            return true
        end
    end

    return false
end

function LoginAwards:GetPartnerTime(bNoSec)
    local nLoginDay = me.GetUserValue(self.LOGIN_AWARDS_GROUP, self.LOGIN_DAYS)
    if nLoginDay >= 7 then
        return
    end

    local nLastLoginTime = me.GetUserValue(self.LOGIN_AWARDS_GROUP, self.LAST_LOGIN_TIME)
    if Lib:IsDiffDay(self.REFRESH_TIME, nLastLoginTime) then
        nLoginDay = nLoginDay + 1
    end

    local bPartner = nLoginDay < 3
    local nCalDay  = bPartner and 3 or 7
    local szTitle  = bPartner and (version_tx and "天后领明星同伴" or "天后领月眉儿") or "天后领礼盒"
    local nLastTime = math.max(0, (nCalDay - nLoginDay)) * 24*60*60
    nLastTime = nLastTime - Lib:GetTodaySec(GetTime() - self.REFRESH_TIME)
    if nLastTime <= 0 then
        return
    end

    local nHour = math.floor(nLastTime/3600)
    local nMin = nLastTime%3600/60
    if bNoSec and nLastTime > 24*60*60 then
        local nDay = math.ceil(nHour/24)
        if nHour%24 == 0 and nMin > 0 then
            nDay = nDay + 1
        end
        return string.format("%d%s", nDay, szTitle)
    else
        return string.format("%02d:%02d:%02d", nHour, nMin, nLastTime%60)
    end
end

------------------------------摇钱树------------------------------
function MoneyTree:OnRespond(tbGain)
    self:CheckRedPoint()
    UiNotify.OnNotify(UiNotify.emNOTIFY_MONEYTREE_RESPOND, tbGain);
end

function MoneyTree:CheckRedPoint()
    if me.nLevel >= WelfareActivity:GetActivityOpenLevel("MoneyTreePanel") and
        me.GetUserValue(self.Def.SAVE_GROUP, self.Def.FREE_SHAKE) == 0 then
        Ui:SetRedPointNotify("MoneyTree_Free")
    else
        Ui:ClearRedPointNotify("MoneyTree_Free")
    end
end

function MoneyTree:GetMoneyIdx(nMoney)
    for nIdx, nCoin in ipairs(self.tbCoinBySort) do
        if nMoney == nCoin or
            nMoney == nCoin*self.Def.BONUSES_RATE or --vip等级可能跟摇的时候不一样
            nMoney == nCoin*(1+self.Def.LAUNCH_PRIVILEGE_RATE) or
            nMoney == nCoin*(self.Def.LAUNCH_PRIVILEGE_RATE+self.Def.BONUSES_RATE) then
            return nIdx
        end
    end
    return 1
end

---聚宝盆
function JuBaoPen:UpdateMoney(nMoney)
    UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_JUBAOPEN, nMoney);
end

function JuBaoPen:TakeMoneyScucess(nMoney)
    local _, szEmotion = Shop:GetMoneyName("Coin");
    me.CenterMsg(string.format("成功领取%d%s", nMoney, szEmotion))
    self:CheckRedPoint();
    UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_JUBAOPEN, 0);
end

function JuBaoPen:CheckRedPoint()
    if me.nLevel >= self.OPEN_LEVEL and me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_TAKE) ~= 0 and self:GetTakeMoneyCDTime(me) <= 0 then
        Ui:SetRedPointNotify("Activity_JuBaoPlate")
    else
        Ui:ClearRedPointNotify("Activity_JuBaoPlate")
    end
end

--------------------------------------夏日好礼--------------------------------------
function SummerGift:CheckRedPoint()
    local nCurIdx = self:GetCurDayIndex()
    if me.nLevel < 20 or nCurIdx <= 0 or nCurIdx > (self.nActAltDay + self.nGetGiftDay) then
        Ui:ClearRedPointNotify("Activity_SummerGift")
        return
    end

    local tbToday = self.tbAct[nCurIdx]
    for i = 1, 2 do
        local nSavePos = self.BEGIN_FLAG + i - 1
        local nCurTimes = me.GetUserValue(self.GROUP, nSavePos)
        if nCurTimes > 0 then
            Ui:ClearRedPointNotify("Activity_SummerGift")
            return
        end
    end

    Ui:SetRedPointNotify("Activity_SummerGift")
end

function SummerGift:OnJoinAct()
    self:CheckRedPoint()
end



-----------------------------------QingRenJie-----------------------------------
Require("Script/Ui/Logic/Notify.lua")
Activity.QingRenJie = Activity.QingRenJie or {}
local tbAct = Activity.QingRenJie
function tbAct:OnMapLoaded(nMapTID)
    if nMapTID == self.MAP_TID then
        BindCameraToPos(845, 1120)
        Ui:OpenWindow("QingRenJieInvitePanel")
    end
end

function tbAct:OnLeaveMap(nMapTID)
    if nMapTID ~= self.MAP_TID then
        return
    end
    Ui.CameraMgr.ResetMainCamera(true)
    BindCameraToNpc(0, 0)
    Ui:CloseWindow("QingRenJieInvitePanel")
    Ui:CloseWindow("QingRenJieTitlePanel")
end

UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, tbAct.OnMapLoaded, tbAct)
UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, tbAct.OnLeaveMap, tbAct)