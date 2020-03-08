--道具产出表，现供同伴道具使用

OutputTable.FUBEN           = 1;    --副本
OutputTable.TEAM_FUBEN      = 2;    --组队秘境
OutputTable.RANDOM_FUBEN    = 3;    --凌绝峰
OutputTable.TOP_BOSS        = 4;    --武林盟主
OutputTable.WILD_BOSS       = 5;    --野外首领
OutputTable.GREAT_GEN       = 6;    --历代名将
OutputTable.SHOP_Treasure   = 7;    --商店珍宝阁

function OutputTable:AnalyseFubenOutput()
    self.tbAllOutputInfo = {};
    self:LoadOtherSetting();
    self:TraverseFuben();
end

function OutputTable:TraverseFuben()
    for nFubenLevel = PersonalFuben.PERSONAL_LEVEL_NORMAL, PersonalFuben.PERSONAL_LEVEL_ELITE do
        local nSectionNum = PersonalFuben:GetMaxSectionCount(nFubenLevel);
        for nSectionIdx = 1, nSectionNum do
            local nSubSectionNum = #((PersonalFuben:GetSectionInfo(nSectionIdx, nFubenLevel) or {}).tbSectionInfo or {});
            for nSubSectionIdx = 1, nSubSectionNum do
                self:AnalyseFubenAward(nFubenLevel, nSectionIdx, nSubSectionIdx);
            end
        end
    end
end

function OutputTable:AnalyseFubenAward(nFubenLevel, nSectionIdx, nSubSectionIdx)
    local nFubenIdx       = PersonalFuben:GetFubenIndex(nSectionIdx, nSubSectionIdx, nFubenLevel);
    local tbFubenInfo     = PersonalFuben:GetPersonalFubenInfo(nFubenIdx);
    local tbFubenTemplate = Fuben.tbFubenTemplate[tbFubenInfo.nMapTemplateId or -1] or {};
    local tbAllAward      = tbFubenTemplate.tbAllAward or {};
    local tbAward         = tbAllAward[nFubenLevel] or {};

    for k, tbInfo in pairs(tbAward) do
        local nType = Player.AwardType[tbInfo[1]]
        if nType == Player.award_type_item then
            local nItemID = tbInfo[2]
            self.tbAllOutputInfo[nItemID] = self.tbAllOutputInfo[nItemID] or {};
            local bRepeat;
            for _, tbOutput in pairs(self.tbAllOutputInfo[nItemID]) do
                if tbOutput.nType == self.FUBEN and tbOutput.tbInfo.nFubenIdx == nFubenIdx then
                    bRepeat = true;
                    break;
                end
            end
            if not bRepeat then
                table.insert(self.tbAllOutputInfo[nItemID],
                    {nType = self.FUBEN, tbInfo = {nFubenLevel = nFubenLevel, nSectionIdx = nSectionIdx, nSubSectionIdx = nSubSectionIdx, nFubenIdx = nFubenIdx}});
            end
        end
    end
end

function OutputTable:LoadOtherSetting()
    local tbSetting = Lib:LoadTabFile("Setting/OutputTable/PartnerEquipOutput.tab", { TemplateID = 0, Type = 0, ExtPar1 = 0, ExtPar2 = 0, ExtPar3 = 0 });
    for k, tbInfo in pairs(tbSetting) do
        local nTemplateID = tbInfo.TemplateID;
        self.tbAllOutputInfo[nTemplateID] = self.tbAllOutputInfo[nTemplateID] or {};
        local tbOutput = {nType = tbInfo.Type, tbInfo = {szDesc = tbInfo.Desc}};
        if tbInfo.Type == self.TEAM_FUBEN then
            tbOutput.tbInfo.nLevel = tbInfo.ExtPar1;
        --TODO 暂时其他的没什么操作
        end
        table.insert(self.tbAllOutputInfo[nTemplateID], tbOutput);
    end
end

function OutputTable:GetOutputList(nItemTemplateID)
    local tbInfo = self.tbAllOutputInfo[nItemTemplateID] or {};
    return tbInfo;
end

function OutputTable:GetRuneOutputList(nItemTemplateID)
    local tbItemAllOutput = self:GetOutputList(nItemTemplateID);
    local tbRuneOutput    = {};
    for _, tbInfo in pairs(tbItemAllOutput) do
        if tbInfo.nType == self.FUBEN then
            table.insert(tbRuneOutput, tbInfo);
        end
    end
    return tbRuneOutput;
end

function OutputTable:GotoGainUi(tbGainInfo)
    local nType = tbGainInfo.nType;
    if nType == self.FUBEN then
        local nFubenLevel    = tbGainInfo.tbInfo.nFubenLevel or 1;
        local nSectionIdx    = tbGainInfo.tbInfo.nSectionIdx or 1;
        local nSubSectionIdx = tbGainInfo.tbInfo.nSubSectionIdx or 1;

        local bRet, _, _, _, _, _, bUseGold = PersonalFuben:CheckCanSweep(me, nSectionIdx, nSubSectionIdx, nFubenLevel)
        local bCanOnceSweep = not bUseGold or Ui:CheckNotShowTips("OnceSweepUseGold")
        if bRet and bCanOnceSweep then
            Ui:OpenWindow("ShowAward")
            RemoteServer.TrySweep(nSectionIdx, nSubSectionIdx, nFubenLevel)
        else
            Ui:OpenWindow("PersonalFubenEntrance", nSectionIdx, nSubSectionIdx, nFubenLevel);
        end
    elseif nType == self.TEAM_FUBEN then
        Ui:OpenWindow("TeamFubenPanel");
    elseif nType == self.RANDOM_FUBEN then
        Ui:OpenWindow("TeamPanel", "TeamActivity");
    elseif nType == self.TOP_BOSS then
        Ui:OpenWindow("BossPanel");
    elseif nType == self.WILD_BOSS then
        Ui:OpenWindow("CalendarPanel");
    elseif nType == self.GREAT_GEN then
        Ui:OpenWindow("CalendarPanel");
    elseif nType == self.SHOP_Treasure then
        Ui:OpenWindow("CommonShop", "Treasure");
    end
end

function OutputTable:GetGainInfo(tbGainInfo)
    local bEnable, szDesc, szBgSprite, szIcon;
    bEnable            = self:IsGainEnable(tbGainInfo);
    szDesc             = self:GetOutputDesc(tbGainInfo);
    szBgSprite, szIcon = self:GetTypeIconAndBg(tbGainInfo.nType, bEnable);
    return bEnable, szDesc, szBgSprite, szIcon;
end

function OutputTable:IsGainEnable(tbGainInfo)
    local nType   = tbGainInfo.nType;
    local bEnable = true;
    if nType == self.FUBEN then
        local tbInfo = tbGainInfo.tbInfo;
        bEnable = PersonalFuben:CanCreateFubenCommon(me, tbInfo.nSectionIdx, tbInfo.nSubSectionIdx, tbInfo.nFubenLevel);
    elseif nType == self.TEAM_FUBEN then
        local nLevel = tbGainInfo.tbInfo.nLevel;
        if me.nLevel >= nLevel then
            bEnable = true
        end
    end
    return bEnable;
end

local szGetDescFunc = {"GetFubenOutputDesc", "GetTeamFubenOutpuDesc"};
function OutputTable:GetOutputDesc(tbGainInfo)
    local szDesc = "";
    local nType = tbGainInfo.nType;
    local szFunc = szGetDescFunc[nType];
    if self[szFunc] then
        szDesc = self[szFunc](self, tbGainInfo.tbInfo);
    else
        szDesc = tbGainInfo.tbInfo.szDesc;
    end
    return szDesc;
end

local tbSectionCn = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
function OutputTable:GetFubenOutputDesc(tbOutputInfo)
    local szSectionTitle = string.format("第%s章：", tbSectionCn[tbOutputInfo.nSectionIdx]) or "第一章";
    local szSectionName  = PersonalFuben:GetSectionName(tbOutputInfo.nSectionIdx, tbOutputInfo.nSubSectionIdx, tbOutputInfo.nFubenLevel);
    local szLevel        = tbOutputInfo.nFubenLevel == PersonalFuben.PERSONAL_LEVEL_NORMAL and "(普通)" or "(精英)"
    local szTitle        = string.format("%s %s %s", szSectionTitle, szSectionName, szLevel);
    return szTitle;
end

function OutputTable:GetTeamFubenOutpuDesc(tbOutputInfo)
    local szTitle = string.format("%s（%d级）", tbOutputInfo.szDesc, tbOutputInfo.nLevel);
    return szTitle;
end

local tbHeadEnable = {"GuanqiaIcon", "ZuduimijingIcon", "LingjuefengIcon", "WulinmengzhuIcon", "YewaishoulingIcon", "LidaimingjiangIcon", "TreasureIcon_"};
function OutputTable:GetTypeIconAndBg(nType, bEnable)
    local szBgSprite = bEnable and "BtnListMainNormal" or "BtnListMainDisabled";
    local szIcon     = tbHeadEnable[nType];
    szIcon = string.format("%s%s", szIcon, bEnable and "01" or "02");
    return szBgSprite, szIcon;
end