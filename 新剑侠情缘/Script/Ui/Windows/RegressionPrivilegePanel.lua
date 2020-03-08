Require("Script/Recharge/Recharge.lua")
local tbUi = Ui:CreateClass("RegressionPrivilegePanel")
tbUi.WX_PRIVILEGE_URL = "https://w.url.cn/s/AtIuebR"
tbUi.QQ_PRIVILEGE_URL = "https://youxi.vip.qq.com/m/act/5b095ea1ab_jxqy_301410.html?_wv=1&_wwv=4"

tbUi.TAB_FREE      = 1
tbUi.TAB_PRIVILEGE = 2
tbUi.TAB_RECHARGE  = 3
tbUi.TAB_TIANJIAN  = 4
tbUi.TAB_CALLBACK  = 5
tbUi.tbBtnName     = {"Btn1", "Btn2", "Btn3", "Btn4", "Btn5"}
tbUi.tbBtnText     = {"回归福利", "回归特权", "回归好礼", "重出江湖", "侠士召回"}
tbUi.tbUiSetting = {
    {
        {szTitle     = "回归侠士专属称号",
        nParam1      = RegressionPrivilege.HONOR_TITLE,
        szBtnLabel   = "领取"},

        {szTitle     = "回归白银招募令",
        nParam1      = RegressionPrivilege.YINLIANG_CHOUJIANG,
        szBtnLabel   = "领取"},		

        {szTitle     = "回归名侠密探令",
        nParam1      = RegressionPrivilege.YUANBAO_CHOUJIANG,
        szBtnLabel   = "领取"},

        {szTitle     = "回归专属修为",
        nParam1      = RegressionPrivilege.XIUWEI,
        szBtnLabel   = "领取"},
    },
	
    {
        {szTitle     = "家族捐献",
        szContent    = "可以重置今天的捐献次数，享受更高的捐献折扣",
        szMsgContent = "是否重置今天的已捐献次数吗？\n重置后，可从最低价格重新进行捐献",
        szBtnContent = "重置",
        nParam1      = RegressionPrivilege.KINDONATE_TIMES,
        nParam2      = RegressionPrivilege.KINDONATE_TIMES_MAX,
        szServerFunc = "TryBuyKinDonate"},
        
        {szTitle     = "商城优惠限购次数",
        szContent    = "可以重置当前的商城优惠商品的限购次数，享受更多优惠",
        szMsgContent = "是否重置珍宝阁的优惠商品购买次数？\n重置后，可重新购买珍宝阁的优惠商品",
        szBtnContent = "重置",
        nParam1      = RegressionPrivilege.REFRESHSHOP_TIMES,
        nParam2      = RegressionPrivilege.REFRESHSHOP_TIMES_MAX,
        szServerFunc = "TryRefreshShop"},
        
        {szTitle     = "被传功次数重置",
        szContent    = "重置当前被传功次数，获得更多的被传功机会",
        szMsgContent = "是否增加1次被传功次数？",
        szBtnContent = "重置",
        nParam1      = RegressionPrivilege.CHUANGONG_TIMES,
        nParam2      = RegressionPrivilege.CHUANGONG_TIMES_MAX,
        szServerFunc = "TryRestoreChuanGong"},

        {szTitle     = "摇钱树",
        szContent    = "消耗免费次数进行摇钱树",
        szMsgContent = "是否消耗免费次数进行一次摇钱树？",
        szBtnContent = "免费摇钱",
        nParam1      = RegressionPrivilege.MONEYTREE_TIMES,
        nParam2      = RegressionPrivilege.MONEYTREE_TIMES_MAX,
        szServerFunc = "TryRestoreMoneyTree"},
    },
}

tbUi.tbLevelInfo     = {
        szTitle      = "50级免费直升丹",
        szContent    = "[FFFE0D]剑侠尊享6[-]可免费获得或[FFFE0D]亲密度15级以上有直升丹[-]的好友可赠送[FFFE0D]（50级开启）[-]",
        szBtnContent = "了解详情",
        bTemp        = true,
        szBtnUrl     = "[url=openwnd:test, WelfareActivity, 'BuyLevelUp']"
}

tbUi.tbXiulianInfo   = {
        szTitle      = "10倍修炼时间",
        szContent    = "免费获得更多的10倍修炼时间",
        szMsgContent = "领取后将为修炼珠补充满[FFFE0D]7小时[-]修炼时间，侠士确认要领取吗？",
        szBtnContent = "重置",
        nParam1      = RegressionPrivilege.XIULIAN_TIMES,
        nParam2      = RegressionPrivilege.XIULIAN_TIMES_MAX,
        bTemp        = true,
        szServerFunc = "TryAddXiulianTime"
}

tbUi.tbKinStoreInfo  = {
        szTitle      = "家族珍宝坊商品刷新",
        szContent    = "可以重新刷新当前家族珍宝坊中的商品",
        szMsgContent = "是否刷新家族珍宝坊内的商品？\n刷新后，可重新购买家族珍宝坊的商品",
        szBtnContent = "刷新",
        nParam1      = RegressionPrivilege.KINSTORE_TIMES,
        nParam2      = RegressionPrivilege.KINSTORE_TIMES_MAX,
        bTemp        = true,
        szServerFunc = "TryRefreshKinStore"
}

local nGrowInvestTotalGold = Recharge:GetGrowInvestTotalGold(7)
tbUi.tbGrowInvestInfo= {
        szTitle      = "回归专属一本万利",
        szContent    = "侠士可以购买回归专属一本万利",
        szBtnContent = "了解详情",
        bTemp        = true,
        tbAward      = {{"Gold", nGrowInvestTotalGold}},
        szBtnUrl     = "[url=openwnd:test, WelfareActivity, 'GrowInvest', 7]",
}

tbUi.tbYuanQiInfo    = {
        szTitle      = "回归专属元气",
        nParam1      = RegressionPrivilege.YUANQI,
        bTemp        = 1,
        szBtnLabel   = "领取"}

tbUi.tbWaiYiInfo     = {
        szTitle      = "回归专属外装",
        nParam1      = RegressionPrivilege.WAIZHUANG,
        bTemp        = 1,
        szBtnLabel   = "领取"}

tbUi.tbChongzhiInfo  = {
        szTitle      = "回归双倍重置令",
        nParam1      = RegressionPrivilege.CHONGZHI,
        bTemp        = 1,
        szBtnLabel   = "领取"}

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_PRIVILEGE_CALLBACK, self.UpdateContent, self }
    };

    return tbRegEvent;
end

tbUi.tbTab = tbUi.tbTab or {}
function tbUi:OnOpen()
    if RegressionPrivilege:IsTriggerByAct(me) or (Activity:__IsActInProcessByType("NewServerPrivilege") and RegressionPrivilege.bGotoNewServer) then
        local szUrl = Sdk:IsLoginByWeixin() and self.WX_PRIVILEGE_URL or self.QQ_PRIVILEGE_URL
        Sdk:OpenUrl(szUrl)
        return 0
    end
    if not RegressionPrivilege:IsInPrivilegeTime(me) then
        return 0
    end
end

function tbUi:OnOpenEnd()
    self.tbTab = {self.TAB_PRIVILEGE}
    if RegressionPrivilege:IsNewVersionPlayer(me) then
        table.insert(self.tbUiSetting[self.TAB_PRIVILEGE], 1, self.tbXiulianInfo)
        table.insert(self.tbUiSetting[self.TAB_PRIVILEGE], 1, self.tbKinStoreInfo)
        table.insert(self.tbTab, 1, self.TAB_FREE)
        if me.GetVipLevel() >= RegressionPrivilege.nRechargeVipLv then
            table.insert(self.tbTab, self.TAB_RECHARGE)
        end

        if RegressionPrivilege:CheckFreeGainExt(me, RegressionPrivilege.CHONGZHI) then
            table.insert(self.tbUiSetting[self.TAB_FREE], self.tbChongzhiInfo)
        end
        if RegressionPrivilege:CheckFreeGainExt(me, RegressionPrivilege.YUANQI) then
            table.insert(self.tbUiSetting[self.TAB_FREE], self.tbYuanQiInfo)
        end
        if RegressionPrivilege:CheckFreeGainExt(me, RegressionPrivilege.WAIZHUANG) then
            table.insert(self.tbUiSetting[self.TAB_FREE], self.tbWaiYiInfo)
        end

        local tbActInfo = {}
        for szAct, tbInfo in pairs(RegressionPrivilege.DOUBLE_ACT) do
            tbInfo.tbUiInfo.nParam1 = tbInfo.nSaveKey
            tbInfo.tbUiInfo.nParam2 = tbInfo.nMaxSaveKey
            tbInfo.tbUiInfo.bTemp   = true
            table.insert(tbActInfo, tbInfo.tbUiInfo)
        end
        RegressionPrivilege.DayTargetEXT.tbUiInfo.nParam1 = RegressionPrivilege.DayTargetEXT.nSaveKey
        RegressionPrivilege.DayTargetEXT.tbUiInfo.nParam2 = RegressionPrivilege.DayTargetEXT.nMaxSaveKey
        RegressionPrivilege.DayTargetEXT.tbUiInfo.bTemp   = true
        table.insert(tbActInfo, RegressionPrivilege.DayTargetEXT.tbUiInfo)
        table.sort(tbActInfo, function (a, b)
            return a.nParam1 < b.nParam1
        end)
        Lib:MergeTable(self.tbUiSetting[self.TAB_PRIVILEGE], tbActInfo)
    end

    local nItemTID = DirectLevelUp:GetCanBuyItem()
    if me.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.OLD_VIPLEVEL) < RegressionPrivilege.LvUp_VipLv and nItemTID then
        table.insert(self.tbUiSetting[self.TAB_PRIVILEGE], 1, self.tbLevelInfo)
    end

    if RegressionPrivilege:IsNewVersionPlayer(me) then
        if not self.tbUiSetting[self.TAB_RECHARGE] then
            local tbRechargeSetting = {}
            for _, tbInfo in ipairs(RegressionPrivilege.RECHARGE_AWARD) do
                local tbSetting  = {}
                local nLastTimes = me.GetUserValue(RegressionPrivilege.GROUP, tbInfo.nSaveKey)
                tbSetting.szTitle   = tbInfo.szContent
                tbSetting.tbAward   = tbInfo.tbAward
                tbSetting.nSaveKey  = tbInfo.nSaveKey
                tbSetting.nGroupIdx = tbInfo.nRechargeIdx
                tbSetting.nShowPro  = (nLastTimes > 0 and 1000000 or 0) + tbInfo.nShowPro
                table.insert(tbRechargeSetting, tbSetting)
            end
            self.tbUiSetting[self.TAB_RECHARGE] = tbRechargeSetting
        end
        if Recharge:IsShowGrowInvestBack() then
            local bBuyed = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowBuyed[7]) ~= 0
            self.tbGrowInvestInfo.nShowPro = (bBuyed and 0 or 1000000) + 10
            table.insert(self.tbUiSetting[self.TAB_RECHARGE], self.tbGrowInvestInfo)
        end
        table.sort(self.tbUiSetting[self.TAB_RECHARGE], function (a, b)
            return a.nShowPro > b.nShowPro
        end)
    end
    table.insert(self.tbTab, self.TAB_TIANJIAN)
    table.insert(self.tbTab, self.TAB_CALLBACK)

    self:UpdateContent()
end

function tbUi:UpdateContent(nTabIdx)
    nTabIdx = nTabIdx or self.nTabIdx or 1
    self.nTabIdx = nTabIdx
    local nTab = self.tbTab[nTabIdx] or self.tbTab[1]
    if not nTab then
        return
    end
    local fnInit = function (tbItem, nIdx)
        local tbInfo = self.tbUiSetting[nTab][nIdx]
        tbItem.pPanel:SetActive("Return", nTab == self.TAB_FREE)
        tbItem.pPanel:SetActive("Welcome", nTab == self.TAB_PRIVILEGE)
        tbItem.pPanel:SetActive("Recharge", nTab == self.TAB_RECHARGE)
        if nTab == self.TAB_FREE then
            self:UpdateFree(tbItem, tbInfo)
        elseif nTab == self.TAB_PRIVILEGE then
            self:UpdatePrivilege(tbItem, tbInfo)
        elseif nTab == self.TAB_RECHARGE then
            self:UpdateRecharge(tbItem, tbInfo)
        end
    end
    self.pPanel:SetActive("WelfareView", nTab ~= self.TAB_TIANJIAN and nTab ~= self.TAB_CALLBACK)
    self.pPanel:SetActive("JiangHuItem", nTab == self.TAB_TIANJIAN)
    self.pPanel:SetActive("XiaShiItem", nTab == self.TAB_CALLBACK)
    for i = 1, 5 do
        local nCurTab = self.tbTab[i]
        self.pPanel:SetActive("Btn" .. i, nCurTab or false)
        if nCurTab then
            self.pPanel:Label_SetText("LabelLight" .. i, self.tbBtnText[nCurTab])
            self.pPanel:Label_SetText("LabelDark" .. i, self.tbBtnText[nCurTab])
        end
    end
    if nTab == self.TAB_TIANJIAN then
        self:UpdateTianJianDesc()
    elseif nTab == self.TAB_CALLBACK then
        self:UpdateCallback()
    else
        self.WelfareView:Update(self.tbUiSetting[nTab], fnInit)
    end
    self.pPanel:Toggle_SetChecked(self.tbBtnName[nTabIdx], true)
end

function tbUi:UpdatePrivilege(tbItem, tbInfo)
    tbItem.Welcome.pPanel:Label_SetText("TitleName", tbInfo.szTitle)
    tbItem.Welcome.pPanel:Label_SetText("Task", tbInfo.szContent or "")
    local szTimesDesc, nLast
    if tbInfo.nParam1 then
        szTimesDesc, nLast = self:GetTimesDesc(self.TAB_PRIVILEGE, tbInfo.nParam1, tbInfo.nParam2)
    else
        szTimesDesc = ""
        nLast = DirectLevelUp:CheckHadBuyOne(me) and 0 or 1
    end
    tbItem.Welcome.pPanel:Label_SetText("Num", szTimesDesc or "")
    tbItem.Welcome.pPanel:SetActive("BtnReset", nLast > 0)

    if tbInfo.szBtnContent then
        tbItem.Welcome.BtnReset.pPanel:Label_SetText("Label", tbInfo.szBtnContent)
    end

    if tbInfo.szBtnUrl then
        tbItem.Welcome.BtnReset.pPanel.OnTouchEvent = function ()
            Ui.HyperTextHandle:Handle(tbInfo.szBtnUrl, 0, 0)
            if tbInfo.bCloseMyself then
                Ui:CloseWindow(self.UI_NAME)
            end
        end
    elseif tbInfo.szServerFunc then
        tbItem.Welcome.BtnReset.pPanel.OnTouchEvent = function ()
            local _, nLast = self:GetTimesDesc(self.TAB_PRIVILEGE, tbInfo.nParam1, tbInfo.nParam2)
            if nLast <= 0 then
                me.CenterMsg("没有重置次数")
                return
            end

            Ui:OpenWindow("MessageBox", tbInfo.szMsgContent,
            {
                {self.BuyTimes, self, tbInfo.szServerFunc}, {}
            },
            {tbInfo.szBtnContent, "取消"}, nil, nil, true)
        end
    end
    tbItem.pPanel:SetActive("Tip", nLast <= 0)
end

function tbUi:UpdateFree(tbItem, tbInfo)
    tbItem.Return.pPanel:Label_SetText("TitleName", tbInfo.szTitle)
    local bGetButton = RegressionPrivilege:CheckFreeGain(me, tbInfo.nParam1)
    tbItem.Return.pPanel:SetActive("itemflame", bGetButton)
    local tbAward = RegressionPrivilege:GetFreeGainAward(me, tbInfo.nParam1)
    for i = 1, 5 do
        tbItem.Return.pPanel:SetActive("itemflame" .. i, tbAward[i] or false)
        if tbAward[i] then
            tbItem.Return["itemflame" .. i]:SetGenericItem(tbAward[i])
            tbItem.Return["itemflame" .. i].fnClick = tbItem.Return["itemflame" .. i].DefaultClick
        end
    end
    tbItem.Return.pPanel:SetActive("BtnGet", bGetButton or false)
    tbItem.Return.BtnGet.pPanel:Label_SetText("Label", tbInfo.szBtnLabel)
    tbItem.Return.BtnGet.pPanel.OnTouchEvent = function ()
        local bExtCheck, szMsg = RegressionPrivilege:CheckFreeGainExt(me, tbInfo.nParam1)
        if not bExtCheck then
            me.CenterMsg(szMsg)
            return
        end

        Ui:OpenWindow("MessageBox", "侠士是否确定领取对应的回归福利？",
        {
            {self.TryGainFreeGift, self, tbInfo.nParam1}, {}
        },
        {"领取", "取消"}, nil, nil, true)
    end
    tbItem.pPanel:SetActive("Tip", not bGetButton)
end

function tbUi:UpdateRecharge(tbItem, tbInfo)
    tbItem.Recharge.pPanel:Label_SetText("TitleName", tbInfo.szTitle)
    local nLastTimes = 0
    if tbInfo.nSaveKey then
        nLastTimes = me.GetUserValue(RegressionPrivilege.GROUP, tbInfo.nSaveKey)
    end
    tbItem.Recharge.pPanel:SetActive("Times", tbInfo.nSaveKey and nLastTimes > 0)
    if nLastTimes > 0 then
        tbItem.Recharge.pPanel:Label_SetText("Times", string.format("限购次数：%d", nLastTimes))
    end
    local tbAward = tbInfo.tbAward or {}
    for i = 1, 5 do
        tbItem.Recharge.pPanel:SetActive("itemflame" .. i, tbAward[i] or false)
        if tbAward[i] then
            tbItem.Recharge["itemflame" .. i]:SetGenericItem(tbAward[i])
            tbItem.Recharge["itemflame" .. i].fnClick = tbItem.Recharge["itemflame" .. i].DefaultClick
        end
    end
    local bRet = not tbInfo.nSaveKey or nLastTimes > 0
    tbItem.Recharge.pPanel:SetActive("BtnGet", bRet)
    tbItem.Recharge.BtnGet.pPanel:Label_SetText("Label", tbInfo.szBtnContent or "充值")
    tbItem.Recharge.BtnGet.pPanel.OnTouchEvent = function ()
        if tbInfo.szBtnUrl then
            Ui.HyperTextHandle:Handle(tbInfo.szBtnUrl, 0, 0)
        end
        if not tbInfo.nGroupIdx then
            return
        end
        self:TryRecharge(tbInfo.nSaveKey, tbInfo.nGroupIdx)
    end
    tbItem.pPanel:SetActive("Tip", not bRet)
end

function tbUi:UpdateTianJianDesc()
    local tbSubPanel = self.JiangHuItem
    tbSubPanel.pPanel:Label_SetText("DiscountPrice2", string.format("折扣价 %d", RegressionPrivilege.tbTianJian.nPrice))
    tbSubPanel.pPanel:Label_SetText("TitlePrice2", string.format("原价 %d", RegressionPrivilege.tbTianJian.nOriginalPrice))
    tbSubPanel.pPanel:Label_SetText("TxtDetail", "恭喜少侠重出江湖\n\n     如今武林风云再起，少侠云游八方，交游广阔，能够在此时归来，实在令人欣慰，今武林名门世家辈出，想必少侠或有另辟蹊径之意，特赠以天剑令折扣机会，让少侠能够重新选择武学道路，仅可购买一次。\n     少侠的江湖之路，于今朝再度起航！")
    tbSubPanel.itemflame2:SetGenericItem({"Item", RegressionPrivilege.tbTianJian.nItemTID, 1})
    tbSubPanel.itemflame2.fnClick = tbSubPanel.itemflame2.DefaultClick

    local bShaoTJL = me.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.OUTLINE_DAY) >= RegressionPrivilege.tbTianJian.nCanBuyDay
    tbSubPanel.pPanel:SetActive("Price2", bShaoTJL)
    if bShaoTJL then
        local bCanGain = me.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.TIANJIAN_FLAG) == 0
        tbSubPanel.pPanel:SetActive("BtnGuy2", bCanGain)
        if bCanGain then
            tbSubPanel.BtnGuy2.pPanel.OnTouchEvent = function ()
                local nPrice = RegressionPrivilege.tbTianJian.nPrice
                if me.GetMoney("Gold") < nPrice then
                    Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
                    me.CenterMsg("元宝不足，请先充值")
                    return
                end

                RemoteServer.OnCallPregressionPrivilege("TryBuyDiscdTianJian")
                tbSubPanel.pPanel:SetActive("BtnGuy", false)
            end
        end
    end

    local nCanBuyID = DirectLevelUp:GetCanBuyItem()
    tbSubPanel.pPanel:SetActive("Price1", nCanBuyID or false)
    if nCanBuyID then
        local nLevel = KItem.GetItemExtParam(nCanBuyID, 1)
        tbSubPanel.pPanel:Label_SetText("TitlePrice1", string.format("直升%d", nLevel))
        tbSubPanel.itemflame1:SetGenericItem({"Item", nCanBuyID, 1})
        tbSubPanel.itemflame1.fnClick = tbSubPanel.itemflame1.DefaultClick
        tbSubPanel.BtnGuy1.pPanel.OnTouchEvent = function ()
            if not DirectLevelUp:CheckShowPanel() then
                me.CenterMsg("当前没有可购买的直升丹")
                return
            end
            Ui:OpenWindow("WelfareActivity", "BuyLevelUp")
        end
    end
end

tbUi.szCallback1 = [[      侠士重回江湖，实在可喜可贺！如今江湖风云变动，武林福利不减，少侠只需提升等级，即可重新融入江湖。与召回关系的侠士组队，可享受特权加成，还等什么，快找回昔日并肩作战的好友！一同再战江湖！
]]
tbUi.szCallback2 = [[规则&奖励说明
      1、只需有召回关系的两名侠士组队，即可享受「配合默契」及「重聚江湖」状态
      2、55级以上的侠士更可以通过主界面领取回归奖励，福利拿到手软，快速追上武林步伐
]]
tbUi.tbCallbackAward = {{"Item", 3640}, {"Item", 3641}, {"Item", 3643}}
function tbUi:UpdateCallback()
    self.XiaShiItem.pPanel:Label_SetText("TxtDetail1", self.szCallback1)
    self.XiaShiItem.pPanel:Label_SetText("TxtDetail2", self.szCallback2)
    for i = 1, 3 do
        local szIFName = "itemflame" .. (i+2)
        self.XiaShiItem[szIFName]:SetGenericItem(self.tbCallbackAward[i])
        self.XiaShiItem[szIFName].fnClick = self.XiaShiItem[szIFName].DefaultClick
    end
end

function tbUi:GetTimesDesc(nGroup, nParam1, nParam2)
    if nGroup ~= self.TAB_PRIVILEGE then
        return
    end

    local nLast = me.GetUserValue(RegressionPrivilege.GROUP, nParam1)
    local nMax = me.GetUserValue(RegressionPrivilege.GROUP, nParam2)
    local szDesc = string.format("次数：%d/%d", nLast, nMax)
    if nParam1 == RegressionPrivilege.XIULIAN_TIMES then
        local nLastHour = string.format("%0.1f", nLast/3600)
        local nMaxHour = string.format("%0.1f", nMax/3600)
        szDesc = string.format("时间：%s/%s小时", nLastHour, nMaxHour)
    end
    return szDesc, nLast, nMax
end

function tbUi:BuyTimes(szServerFunc)
    RemoteServer.OnCallPregressionPrivilege(szServerFunc)
end

function tbUi:TryGainFreeGift(nId)
    RemoteServer.OnCallPregressionPrivilege("TryGainFreeGift", nId)
end

function tbUi:TryRecharge(nSaveKey, nGroupIndex)
    if me.GetUserValue(RegressionPrivilege.GROUP, nSaveKey) <= 0 then
        me.CenterMsg("已没有优惠充值次数")
        return
    end
    if me.GetVipLevel() < RegressionPrivilege.nRechargeVipLv then
        me.CenterMsg(string.format("达到剑侠尊享%d后可购买", RegressionPrivilege.nRechargeVipLv))
        return
    end
    for _, tbInfo in ipairs(Recharge.tbSettingGroup.BackGift) do
        if tbInfo.nGroupIndex == nGroupIndex then
            Recharge:RequestBuyBackGift(tbInfo)
            return
        end
    end
end

function tbUi:OnClose()
    for nTab = self.TAB_FREE, self.TAB_RECHARGE do
        local nLen = #(self.tbUiSetting[nTab] or {})
        for i = nLen, 1, -1 do
            if self.tbUiSetting[nTab][i] and self.tbUiSetting[nTab][i].bTemp then
                table.remove(self.tbUiSetting[nTab], i)
            end
        end
    end
    self.tbTab = {}
    self.nTabIdx = nil
end

tbUi.tbOnClick = 
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}

for i = 1, 5 do
    tbUi.tbOnClick["Btn" .. i] = function (self)
        self:UpdateContent(i)
    end
end