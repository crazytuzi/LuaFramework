local tbUi = Ui:CreateClass("GeneralHelpPanel")
tbUi.tbHelpInfo = {}

function tbUi:RegisterEvent()
    return {
        {UiNotify.emNOTIFY_CLICK_LINK_NPC, self.OnClickLinkNpc},
    }
end

function tbUi:OnClickLinkNpc(nNpcTemplateId, nMapTemplateId)
    Ui:CloseWindow(self.UI_NAME)
end

local function fnInit()
    local tbTemp = {}
    local tbHelpContent = Lib:LoadTabFile("Setting/Help/GeneralHelp.tab", { nIndex = 1, nHead = 1 })
    assert(tbHelpContent, "[Ui GeneralHelp] LoadSetting GeneralHelp Fail")
    for _, tbInfo in pairs(tbHelpContent) do
        local szKey = tbInfo.szHelpKey
        tbTemp[szKey] = tbTemp[szKey] or {szBigTitle = tbInfo.szBigTitle, tbContent = {}}
        if tbInfo.nHead > 0 then
            tbTemp[szKey].tbGuide = {tbInfo.nHead, tbInfo.szTitle, tbInfo.szContent}
        else
            tbTemp[szKey].tbContent[tbInfo.nIndex] = { szContent = tbInfo.szContent, szTitle = tbInfo.szTitle, 
            szFun = tbInfo.Function, szFunParam = tbInfo.FunParam}
        end
    end
    tbUi.tbHelpInfo = tbTemp
end
fnInit()

function tbUi:OnOpen(szName)
    if not szName or not self.tbHelpInfo[szName] then
        return 0
    end

    self.szHelpName = szName
    self:Update()
end

local tbColors = {
    szValid = "00FF00",
    szInvalid = "FF0000",
}
local function getColor(bValid)
    return bValid and tbColors.szValid or tbColors.szInvalid
end

tbUi.tbFunction = 
{
    ["SkillHelp"] = function (self, tbItemContent)
        local nItemId = tonumber(tbItemContent.szFunParam);
        local tbItem = Item:GetClass("SkillPointBook");
        local szMsg = tbItemContent.szContent;
        local tbInfo = tbItem.tbBookInfo[nItemId];
        if tbItem.tbBookInfo[nItemId] then
            local nCount = me.GetUserValue(tbItem.nSavePointGroup, tbInfo.nSaveID);
            szMsg = string.format(szMsg, nCount);
        end

        return szMsg;    
    end;

    ["AddTeacherHelp"] = function(self, tbItemContent)
        local nMinLvDiff = TeacherStudent:GetConnectLvDiff(me.GetVipLevel())
        local tbSetting = TeacherStudent:GetCurrentTimeFrameSettings()
        local nLevel = tbSetting and tbSetting.nStuLvMin or 20
        local bValidLevel = me.nLevel>=nLevel

        local tbMainInfo = TeacherStudent:GetMainInfo() or {
            tbTeachers = {},
            tbStudents = {},
        }
        local bValidTeacherCount = Lib:CountTB(tbMainInfo.tbTeachers or {})<TeacherStudent.Def.nMaxTeachers

        local bValidNotPunish = tbMainInfo.nPunishDeadline<GetTime()
        local szConditions = string.format("[%s]等级达到%s级[-]、[%s]师父数量未满%d人[-]、[%s]当前不处于解除师徒关系惩罚期[-]",
            getColor(bValidLevel), nLevel, getColor(bValidTeacherCount), TeacherStudent.Def.nMaxTeachers, getColor(bValidNotPunish))
        return string.format(tbItemContent.szContent, nMinLvDiff, szConditions)
    end,

    ["AddStudentHelp"] = function(self, tbItemContent)
        local nMinLvDiff = TeacherStudent:GetConnectLvDiff(me.GetVipLevel())
        local tbSetting = TeacherStudent:GetCurrentTimeFrameSettings()
        local nLevel = tbSetting and tbSetting.nTeaLvMin or 50
        local bValidLevel = me.nLevel>=nLevel

        local bValidStudentCount = TeacherStudent:GetUndergraduateCount()<TeacherStudent.Def.nMaxUndergraduate

        local tbMainInfo = TeacherStudent:GetMainInfo() or {
            tbTeachers = {},
            tbStudents = {},
        }

        local nLastAccept = tbMainInfo.nLastAccept or 0
        local nAddStudentCd = TeacherStudent.Def.nAddStudentInterval-(GetTime()-nLastAccept)
        local bValidNoCD = nAddStudentCd<=0
        local bValidNotPunish = (tbMainInfo.nPunishDeadline or 0)<GetTime()
        local szConditions = string.format("[%s]等级达到%s级[-]、[%s]未出师徒弟数量未满%d人[-]、[%s]当前不处于收徒间隔期[-]、[%s]当前不处于解除师徒关系惩罚期[-]",
            getColor(bValidLevel), nLevel, getColor(bValidStudentCount), TeacherStudent.Def.nMaxUndergraduate, getColor(bValidNoCD), getColor(bValidNotPunish))
        return string.format(tbItemContent.szContent, nMinLvDiff, szConditions)
    end,

    ["AddAttributeItemHelp"] = function (self, tbItemContent)
        local nItemId = tonumber(tbItemContent.szFunParam);
        local tbItem = Item:GetClass("AddPlayerAttributeItem")
        local szMsg = tbItemContent.szContent;
        local tbInfo = tbItem.tbItemInfo[nItemId];
        if tbInfo then
            local nCount = me.GetUserValue(tbItem.nSaveGroup, tbInfo.nSaveID);
            szMsg = string.format(szMsg, nCount);
        end

        return szMsg;    
    end;

    ["MarriageMDHelp"] = function(self, tbItemContent)
        local szNextMemorialDay = "无"
        local szName = "-"
        local nMonth = 0
        local tbItems = me.FindItemInBag(Wedding.nMarriagePaperId)
        local pPaper = (tbItems or {})[1]
        if pPaper then
            local nTimestamp = pPaper.GetIntValue(Wedding.nMPTimestamp)
            local nNow = GetTime()
            local nCurMaxMonth = Wedding:GetMaxMemorialMonth(nTimestamp, nNow)
            local nCfgMaxMonth = Wedding:GetMemorialCfgMaxMonth()
            local bFound = false
            for i=nCurMaxMonth, nCfgMaxMonth do
                if Wedding.tbMemorialMonthRewards[i] then
                    local nGuessTimestamp = nTimestamp+24*3600*28*i
                    local nGuessMaxTimestamp = nTimestamp+24*3600*31*i
                    for nTmpTime=nGuessTimestamp, nGuessMaxTimestamp, 24*3600 do
                        if Wedding:GetMaxMemorialMonth(nTimestamp, nTmpTime)==i then
                            if Lib:GetLocalDay(nNow)>=Lib:GetLocalDay(nTmpTime) then
                                break
                            end
                            szNextMemorialDay = Lib:TimeDesc11(nTmpTime)
                            szName = i%12==0 and string.format("%d周年", i/12) or string.format("%d个月", i)
                            nMonth = i
                            bFound = true
                            break
                        end
                    end
                    if bFound then
                        break
                    end
                end
            end
        end
        return string.format(tbItemContent.szContent, szNextMemorialDay, szName, nMonth)
    end;
}

function tbUi:Update()
    local tbInfo = self.tbHelpInfo[self.szHelpName]
    local bShowGuide = tbInfo.tbGuide and true or false
    self.pPanel:SetActive("SpecialHelp", bShowGuide)

    if bShowGuide then
        local tbGuide = tbInfo.tbGuide
        self.pPanel:Label_SetText("Label", tbGuide[1])
        self.pPanel:Label_SetText("TypeTittle", tbGuide[2])
        self.pPanel:Label_SetText("Type", tbGuide[3])
    end

    local function fnUpdateItem(itemObj, nIdx)
        local tbItemContent = tbInfo.tbContent[nIdx]
        if not tbItemContent then
            return
        end

        itemObj.pPanel:Label_SetText("Number", tostring(nIdx))
        itemObj.pPanel:Label_SetText("Tittle", tbItemContent.szTitle)
        local szContent  = "";
        if not Lib:IsEmptyStr(tbItemContent.szFun) and tbUi.tbFunction[tbItemContent.szFun] then
            szContent = tbUi.tbFunction[tbItemContent.szFun](self, tbItemContent);
        end

        if Lib:IsEmptyStr(szContent) then    
            szContent = tbItemContent.szContent;
        end

        szContent = string.gsub(szContent, "\\n", "\n"); 
        itemObj.Content:SetLinkText(szContent)
    end

    self.pPanel:SetActive("SpecialScrollView", bShowGuide)
    self.pPanel:SetActive("ScrollView", not bShowGuide)
    if bShowGuide then
        self.SpecialScrollView:Update(#tbInfo.tbContent, fnUpdateItem)
    else
        self.ScrollView:Update(#tbInfo.tbContent, fnUpdateItem)
    end
    self.pPanel:Label_SetText("Title", tbInfo.szBigTitle)
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbDir = {
    ["TeamFubenHelp"] = function ()
        Ui:OpenWindow("TeamPanel", "TeamActivity", nil, nil, "Member")
    end
}

tbUi.tbOnClick = {
    ["BtnHelpClicker"] = function (self)
        local fnDir = self.tbDir[self.szHelpName]
        if fnDir then
            fnDir()
            Ui:CloseWindow(self.UI_NAME)
        end
    end
}