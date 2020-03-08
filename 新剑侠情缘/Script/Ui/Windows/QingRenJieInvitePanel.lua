local RepresentSetting = luanet.import_type("RepresentSetting")

local tbUi = Ui:CreateClass("QingRenJieInvitePanel")

tbUi.GROUP = 68
tbUi.TITLE_FLAG = 15
tbUi.SIT_FLAG = 16
tbUi.ACCEPT_DAY = 17
tbUi.ACCEPT_TIMES = 18
-- function tbUi:OnOpen()
    -- if me.GetUserValue(self.GROUP, self.TITLE_FLAG) > 0 and me.GetUserValue(self.GROUP, self.SIT_FLAG) then
    --     return 0
    -- end
-- end

function tbUi:OnOpenEnd()
    self:UpdateBtn()
end

function tbUi:Update(nPercent)
    if nPercent < 1 then
        self.pPanel:SetActive("BtnInteraction", false)
        self.pPanel:SetActive("BtnLeave", false)
    else
        self:UpdateBtn()
    end
end

function tbUi:UpdateBtn()
    self.pPanel:SetActive("BtnInteraction", me.dwID == Activity.QingRenJie.nApplyPlayer and (me.GetUserValue(self.GROUP, self.TITLE_FLAG) == 0 or me.GetUserValue(self.GROUP, self.SIT_FLAG) == 0))
    self.pPanel:SetActive("BtnLeave", true)
end

function tbUi:RegisterEvent()
    return {
        {UiNotify.emNOTIFY_CHUAN_GONG_SEND_ONE, self.Update, self}
    }
end

tbUi.tbOnClick = 
{
    BtnInteraction = function (self)
        if self.nClickTime and self.nClickTime == GetTime() then
            return
        end

        self.nClickTime = GetTime()
        if me.GetUserValue(self.GROUP, self.SIT_FLAG) <= 0 then
            RemoteServer.QingRenJieRespon("Act_QingRenJie_TryDazuo")
        elseif me.GetUserValue(self.GROUP, self.TITLE_FLAG) <= 0 then
            Ui:OpenWindow("QingRenJieTitlePanel")
        else
            me.CenterMsg("玫瑰烟火已盛放完毕！祝二位永结同心！")
        end
    end,
    BtnLeave = function (self)
        RemoteServer.TryLeaveQingRenJieMap()
    end,
}


local tbTitleUi = Ui:CreateClass("QingRenJieTitlePanel")
function tbTitleUi:OnOpenEnd(nItemID, szAct, tbTitle)
    self.nItemID = nItemID
    self.szAct   = szAct
    self.tbTitle = {}
    local tbItem = Item:GetClass("QingRenJieTitleItem")
    for nTID, _ in pairs(tbTitle or tbItem.tbTitle) do
        table.insert(self.tbTitle, nTID)
    end
    table.sort(self.tbTitle)
    local fnSet = function (itemObj, nIdx)
        itemObj.tbParent = self
        itemObj.tbTitleIndx = {}
        for i = 1, 2 do
            local nTitleIdx = (nIdx-1)*2 + i
            local nTitleId = self.tbTitle[nTitleIdx]
            itemObj.pPanel:SetActive("Title" .. i, nTitleId or false)

            if nTitleId then
                local tbInfo = PlayerTitle:GetTitleTemplate(nTitleId)
                local szLabelName = "Name" .. i
                itemObj.pPanel:Label_SetText(szLabelName, tbInfo.Name)
                local MainColor = RepresentSetting.GetColorSet(tbInfo.ColorID)
                itemObj.pPanel:Label_SetColor(szLabelName, MainColor.r * 255, MainColor.g * 255, MainColor.b * 255)
        
                if tbInfo.GTopColorID > 0 and tbInfo.GBottomColorID > 0 then
                    local GTopColor = RepresentSetting.GetColorSet(tbInfo.GTopColorID)
                    local GTBottomColor = RepresentSetting.GetColorSet(tbInfo.GBottomColorID)
                    itemObj.pPanel:Label_SetGradientByColor(szLabelName, GTopColor, GTBottomColor)
                else
                    itemObj.pPanel:Label_SetGradientActive(szLabelName, false)
                end    
        
                local ColorOuline = RepresentSetting.CreateColor(0.0, 0.0, 0.0, 1.0)
                if tbInfo.OutlineColorID > 0 then
                    ColorOuline = RepresentSetting.GetColorSet(tbInfo.OutlineColorID)
                end
        
                itemObj.pPanel:Label_SetOutlineColor(szLabelName, ColorOuline)
            end
            table.insert(itemObj.tbTitleIndx, nTitleIdx)
        end
    end
    local nSVLen = math.ceil(#self.tbTitle/2)
    self.ScrollView:Update(nSVLen, fnSet)
end

function tbTitleUi:OnBtnClick(nBtnIdx)
    self.nCurIdx = nBtnIdx
end

tbTitleUi.tbOnClick = {
    BtnSure = function (self)
        if not self.nCurIdx then
            return
        end
        if self.szAct then
            if self.nItemID then
                RemoteServer.TryUseArborTitleItem(self.tbTitle[self.nCurIdx], self.nItemID)
            end
            Ui:CloseWindow(self.UI_NAME)
            return
        end
        if self.nItemID then
            RemoteServer.TryUseTitleItem(self.tbTitle[self.nCurIdx], self.nItemID)
        else
            RemoteServer.QingRenJieRespon("Act_QingRenJie_ChooseTitle", self.tbTitle[self.nCurIdx], self.nItemID)
        end
        Ui:CloseWindow(self.UI_NAME)
    end,
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end
}

local tbTitleItem = Ui:CreateClass("QingRenJieTitleItem")
tbTitleItem.tbOnClick = {}
for i = 1, 2 do
    tbTitleItem.tbOnClick["Title" .. i] = function (self)
        self.tbParent:OnBtnClick(self.tbTitleIndx[i])
    end
end

local tbNIUi = Ui:CreateClass("NewInfo_QingRenJie")
tbNIUi.szTxt1 = [[

那一年 那一月 那一日
寻一人 觅一人 伴一人
爱一起 爱一生 爱一世
]]

tbNIUi.szTxt2 = [[
活动规则：
1、40级以上侠士达成[FFFE0D]活跃值[-]可获礼物，可赠送增加亲密度，对方获得被赠礼盒[FFFE0D](每天最多5个)[-]，自己也获得回礼
2、回礼可能得到船票，或在襄阳城找[FFFE0D]小紫烟购买[-]，持船票与[FFFE0D]40级以上异性好友2人组队[-]找小紫烟前往小楼听雨舫
3、每人仅有[FFFE0D]一次邀请他人[FFFE0D]和[-]一次被邀请[-]登上小楼听雨舫的机会，请谨慎选择
4、在小楼听雨舫观赏完烟花美景后，[FFFE0D]使用船票[-]的侠士可获得[FFFE0D]情人节头像[-]，[FFFE0D]两位玩家均可获得限时称号[-]
5、[FFFE0D]本日被赠礼盒：%d/5 [-]（[FFFE0D]0点[-]刷新）
]]
function tbNIUi:OnOpen()
    local tbData = Activity.tbActivityData.QingRenJie
    if tbData then
        local tbBegin = os.date("*t", tbData.nStartTime)
        local tbEnd = os.date("*t", tbData.nEndTime)
        local szTime = string.format("活动时间：%d年%d月%d日凌晨4点-%d月%d日凌晨4点", tbBegin.year, tbBegin.month, tbBegin.day, tbEnd.month, tbEnd.day)
        self.pPanel:Label_SetText("QingrenjieTime", szTime)
    end

    self.pPanel:Label_SetText("QingrenjieTxt1", self.szTxt1)
    local nHadAccTimes = me.GetUserValue(tbUi.GROUP, tbUi.ACCEPT_DAY) == Lib:GetLocalDay() and me.GetUserValue(tbUi.GROUP, tbUi.ACCEPT_TIMES) or 0
    local szTxt2 = string.format(self.szTxt2, 5 - nHadAccTimes)
    self.pPanel:Label_SetText("QingrenjieTxt2", szTxt2)
end

tbNIUi.tbOnClick = {
    BtnQingrenjie1 = function (self)
        Ui:CloseWindow("NewInformationPanel")
        Ui:OpenWindow("CalendarPanel", 3)
    end,

    BtnQingrenjie2 = function (self)
        Ui.HyperTextHandle:Handle("[url=npc:text, 95, 10]", 0, 0)
        Ui:CloseWindow("NewInformationPanel")
    end,
}