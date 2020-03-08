local tbUi = Ui:CreateClass("LoginAwardsPanel")
local tbTips = {
    "[FFFE0D]「身世」[-]昔日江湖中名气最响亮的两名剑客，「北上官，南熙烈」中的上官飞龙便是我父亲，如今江湖最大势力之一「御下三盟」中飞龙堡的女主人，月眉儿。",
    "[FFFE0D]「家破」[-]时隔多年，我依然记得，杨熙烈为争天下第一，逼迫我父亲比武，最终两人同归于尽，母亲也随夫而去，是他害我家破人亡！",
    "[FFFE0D]「痛恨」[-]如今他的儿子杨影枫，非但没有悔改，反而变本加厉，自小以天下第一为目标，四处与人比武，让人厌恶至极。",
    "[FFFE0D]「复仇」[-]心中只有武功天下第一的人，注定无法成为大侠，我要杀了他。不仅是为父报仇，也为了……让自己死心……",
    "[FFFE0D]「剑说」[-]我本善使双刀，当年机缘巧合修习了翠烟门失传多年的冰心仙子，但，要杀他报仇，必须用剑。",
    "[FFFE0D]「造化」[-]纳兰…或许该叫玉潜凛，纳兰真，素未谋面的父亲与妹妹，而真儿，竟也爱上了那个不可一世的剑客，造化弄人…",
    "[FFFE0D]「相让」[-]真儿性格温和，定能让他有所收敛，放下天下第一的执念，我下不了手，他与真儿均是我最重要的人，若能幸福快乐，于我而言，已是最好的结局。",
}

--Copy By Activity.NewYearLoginAct
tbUi.GROUP = 68
tbUi.DATA_KEY = 1
tbUi.AWARD_FLAG_BEGIN = 2
tbUi.LOGIN_FLAG_BEGIN = 6

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_LOGINAWARDS_CALLBACK, self.Update, self },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {
    BtnBg = function (self)
        local nLoginDay = me.GetUserValue(LoginAwards.LOGIN_AWARDS_GROUP, LoginAwards.LOGIN_DAYS)
        local szMsg = tbTips[1]
        for i = 2, nLoginDay do
            szMsg = szMsg .. "\n" .. tbTips[i]
        end
    	Ui:OpenWindow("AttributeDescription", szMsg)
    end,
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}

tbUi.tbOnDrag = 
{
    PartnerView = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
    end,
}

tbUi.tbOnDragEnd = {
    PartnerView = function (self, szWnd, nX, nY)
    end,
}

function tbUi:CheckActOpen()
    if me.nLevel < LoginAwards.NEWYEAR_ACT_LEVEL then
        return string.format("等级不足%d，无法领取", LoginAwards.NEWYEAR_ACT_LEVEL)
    end
    if not Activity:__IsActInProcessByType("NewYearLoginAct") then
        return "该活动已结束"
    end
    if not LoginAwards.tbActSetting then
        return "未知错误"
    end
end

function tbUi:OnOpen(bAct)
    if bAct then
        local szErrMsg = self:CheckActOpen()
        if szErrMsg then
            me.CenterMsg(szErrMsg)
            return 0
        end
    end
end

function tbUi:OnOpenEnd(bAct)
    self.bAct = bAct
    self:Update()
    self:ChangeDialog()
    self:ShowCountDown()
end

function tbUi:Update()
    -- self.pPanel:NpcView_Open("PartnerView");
    -- self.pPanel:NpcView_ShowNpc("PartnerView", 430);
    self:Refresh();
end

function tbUi:ShowCountDown()
    if self.bAct then
        self.pPanel:SetActive("Countdown", false)
        return
    end
    self.pPanel:SetActive("Countdown", true)
    self:UpdateCountDown()
    self.nCountDownTimer = Timer:Register(Env.GAME_FPS, self.UpdateCountDown, self)
end

function tbUi:UpdateCountDown()
    local szTime = LoginAwards:GetPartnerTime()
    if not szTime then
        self.pPanel:SetActive("Countdown", false)
        self.nCountDownTimer = nil
        return
    end

    self.pPanel:Label_SetText("Time2", szTime)
    local nLoginDay = me.GetUserValue(LoginAwards.LOGIN_AWARDS_GROUP, LoginAwards.LOGIN_DAYS)
    local szPartner = version_tx and "明星同伴领取倒计时" or "月眉儿领取倒计时"
    local szTimeTitle = nLoginDay >= 3 and "三阶稀有首饰礼盒领取倒计时" or szPartner
    self.pPanel:Label_SetText("TimeTitle", szTimeTitle)
    return true
end

function tbUi:LoadDialog()
    if self.tbContent then
        return
    end

    self.tbContent  = {}
    local tbContent = Lib:LoadTabFile("Setting/WelfareActivity/LoginAwardsDialog.tab", {Day = 1})
    for _, tbInfo in ipairs(tbContent) do
        local nDayIdx = tbInfo.Day
        self.tbContent[nDayIdx] = self.tbContent[nDayIdx] or {}
        table.insert(self.tbContent[nDayIdx], tbInfo.Content)
    end
end
tbUi:LoadDialog()

function tbUi:OnClose()
    -- self.pPanel:NpcView_Close("PartnerView");
    self.bShowDialog = false
    if self.nDialogTimer then
        Timer:Close(self.nDialogTimer)
        self.nDialogTimer = nil
    end

    if self.nCountDownTimer then
        Timer:Close(self.nCountDownTimer)
        self.nCountDownTimer = nil
    end
end

function tbUi:ChangeDialog()
    if self.bAct then
        self.pPanel:SetActive("Chat", false)
        return
    end
	if self.bShowDialog then
		self.pPanel:SetActive("Chat", false)
		self.bShowDialog = false
    	self.nDialogTimer = Timer:Register(5 * Env.GAME_FPS, self.ChangeDialog, self)
		return
	end

    if not self.tbContent then
        self:LoadDialog()
    end

	local nLoginDay  = me.GetUserValue(LoginAwards.LOGIN_AWARDS_GROUP, LoginAwards.LOGIN_DAYS)
	local tbDayList  = self.tbContent[nLoginDay]
	local nRandom    = MathRandom(1, #tbDayList)
	local szContent  = tbDayList[nRandom]
	self.bShowDialog = true
    self.pPanel:SetActive("Chat", true)
    self.pPanel:Label_SetText("DialogLabel", szContent)
    self.nDialogTimer = Timer:Register(10 * Env.GAME_FPS, self.ChangeDialog, self)
end

function tbUi:GetAwards(nIdx)
    Log("LoginAwards TryGetAward", nIdx)
    if self.bAct then
        RemoteServer.TryCallNewYearLoginActFunc("TryGetAward", nIdx)
    else
        RemoteServer.GetLoginAwards(nIdx);
    end
end

function tbUi:Sort()
    local tbDay = {};
    local nFont = 1;
    local nFlag = me.GetUserValue(LoginAwards.LOGIN_AWARDS_GROUP, LoginAwards.RECEIVE_FLAG);
    local nMaxDays = self.bAct and #LoginAwards.tbActSetting or LoginAwards:GetActLen()
    for nIdx = 1, nMaxDays do
        local bNotGet = Lib:LoadBits(nFlag, nIdx - 1, nIdx - 1) == 0;
        if self.bAct then
            local nSaveKey, nFlagIdx = LoginAwards:GetSaveInfo(nIdx, self.AWARD_FLAG_BEGIN)
            local nFlag = me.GetUserValue(self.GROUP, nSaveKey)
            bNotGet = KLib.GetBit(nFlag, nFlagIdx) == 0
        end
        local nInsertPos = bNotGet and nFont or (#tbDay + 1);
        nFont = bNotGet and nFont + 1 or nFont;
        table.insert(tbDay, nInsertPos, nIdx);
    end
    return tbDay;
end

function tbUi:Refresh()
    local tbDay = self:Sort();
    
    local fnOnClick = function (nIdx)
        self:GetAwards(nIdx);
    end

    local fnSetItem = function(itemObj, nIdx)
        local nDayIdx = tbDay[nIdx];
        itemObj:Update(self.bAct, nDayIdx, fnOnClick);
    end

    local nMaxDays = #tbDay
    self.ScrollViewCatalog:Update(nMaxDays, fnSetItem);

    -- self.pPanel:Texture_SetTexture("mainpannle", self.bAct and "UI/Textures/NewYearRole.png" or "UI/Textures/LoginAwardsRole.png")
    self.pPanel:Texture_SetTexture("mainpannle", self.bAct and "UI/Textures/BeautyAwardsRole.png" or "UI/Textures/LoginAwardsRole.png")
    self.pPanel:SetActive("texiao", self.bAct or false)
end

-------------------------------------------ScrollViewItem-------------------------------------------
local tbItem  = Ui:CreateClass("LoginAwardsPanelItem")
local TITLE = {"初见之礼", "再遇之礼", "相识之礼", "结交之礼", "把酒之礼", "知心之礼", "共死之礼"}
tbItem.tbOnClick = {
	BtnGet = function (self)
    	self:GetAwards();
	end
};

function tbItem:CheckActGoldGet()
    local nSaveKey, nFlagIdx = LoginAwards:GetSaveInfo(self.nIdx, tbUi.LOGIN_FLAG_BEGIN)
    local nLoginFlag = me.GetUserValue(tbUi.GROUP, nSaveKey)
    nLoginFlag = KLib.GetBit(nLoginFlag, nFlagIdx)
    return nLoginFlag == 0
end

function tbItem:GetAwards()
    local function fnGetAwards()
        self.fnOnClick(self.nIdx)
    end

    if self.bAct and self:CheckActGoldGet() then
        local nGold = LoginAwards.tbActSetting[self.nIdx].nCostGold
        local szMoneyName = Shop:GetMoneyName("Gold")
        if me.GetMoney("Gold") < nGold then
            local szMsg = szMoneyName .. "不足，请先充值"
            me.CenterMsg(szMsg)
            Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
        else
            me.MsgBox(string.format("是否花费%d%s补领奖励？", nGold, szMoneyName),
            {
                {"确定", fnGetAwards},
                {"取消"},
            })
        end
        return
    end
    fnGetAwards()
end

function tbItem:Update(bAct, nIdx, fnOnClick)
    self.nIdx       = nIdx
    self.bAct       = bAct
    self.fnOnClick  = fnOnClick

    local nFlag     = me.GetUserValue(LoginAwards.LOGIN_AWARDS_GROUP, LoginAwards.RECEIVE_FLAG)
    local nLoginDay = me.GetUserValue(LoginAwards.LOGIN_AWARDS_GROUP, LoginAwards.LOGIN_DAYS)
    local nDayFlag  = Lib:LoadBits(nFlag, nIdx - 1, nIdx - 1)
    if bAct then
        local nSaveKey, nFlagIdx = LoginAwards:GetSaveInfo(nIdx, tbUi.AWARD_FLAG_BEGIN)
        local nGetFlag = me.GetUserValue(tbUi.GROUP, nSaveKey)
        nDayFlag = KLib.GetBit(nGetFlag, nFlagIdx)
        nLoginDay =  LoginAwards:GetCurDayIdx(LoginAwards.nActBeginTime)
    end

    self.pPanel:SetActive("DayOne", not bAct)
    self.pPanel:Label_SetText("DayOne", string.format("%d", nIdx));
    self.pPanel:Label_SetText("Title", TITLE[nIdx] or "")
    self.pPanel:SetActive("BtnGet", nDayFlag == 0 and nLoginDay >= nIdx);
    self.pPanel:SetActive("BtnLabel", nDayFlag == 0 and nLoginDay >= nIdx)
    self.pPanel:SetActive("TagGeted", nDayFlag == 1 or nIdx > nLoginDay);
    self.pPanel:Label_SetText("TagGeted", nIdx > nLoginDay and "[90c4f8]暂不可领" or "[64fa50]已领取");

    local tbAwardsInfo = {}
    if bAct then
        tbAwardsInfo = LoginAwards.tbActSetting[nIdx].tbAward
    else
        tbAwardsInfo = LoginAwards:GetDayAward(nIdx)
    end
    for nSubIdx = 1, 4 do
        local tbAwards = tbAwardsInfo[nSubIdx];
        if tbAwards then
            self.pPanel:SetActive("itemframe" .. nSubIdx, true);
            self["itemframe" .. nSubIdx]:SetGenericItem(tbAwards);
            self["itemframe" .. nSubIdx].fnClick = self["itemframe" .. nSubIdx].DefaultClick;
        else
            self.pPanel:SetActive("itemframe" .. nSubIdx, false);
        end
    end

    local szBtnContent = "领取"
    local szTimeDesc = "第      天"
    if bAct then
        local tbTime = os.date("*t", LoginAwards.nActBeginTime + 24*60*60 * (nIdx - 1))
        szTimeDesc = string.format("%s月%s日", tbTime.month, tbTime.day)

        if self:CheckActGoldGet() then
            local _, szEmotion = Shop:GetMoneyName("Gold")
            szBtnContent = string.format("%d%s补领", LoginAwards.tbActSetting[nIdx].nCostGold, szEmotion)
        end
    end
    self.pPanel:Label_SetText("BtnLabel", szBtnContent)
    self.pPanel:Label_SetText("Label", szTimeDesc)
end