


function PlayerTitle:LoadSetting()
    self.tbTitleTemplate    = {};

    local tbFileData = Lib:LoadTabFile("Setting/Player/Title.tab", {TitleID = 1, ColorID = 1, Timeout = 1, EffectResID = 1, Rank  = 1,
        GTopColorID = 1, GBottomColorID = 1, OutlineColorID = 1, Quality = 1, Icon = 1});
    for _, tbInfo in pairs(tbFileData) do
        if not Lib:IsEmptyStr(tbInfo.Achievement) and not MODULE_GAMECLIENT then
            tbInfo.tbAchievement = Lib:SplitStr(tbInfo.Achievement, ";");
        end
        if MODULE_GAMECLIENT then
            tbInfo.Timeout = nil
            tbInfo.WorldNotify = nil
        end
        self.tbTitleTemplate[tbInfo.TitleID] = tbInfo;
    end
end

PlayerTitle:LoadSetting();

function PlayerTitle:GetTitleTemplate(nTitleID)
    return self.tbTitleTemplate[nTitleID];
end