Require("CommonScript/HuaShanLunJian/LunJianDef.lua");

local tbDef = HuaShanLunJian.tbDef;
local tbUi = Ui:CreateClass("HSLJAccount");
tbUi.nMaxItemCount = 4;
tbUi.tbOnClick = {};

tbUi.nPlayNone   = 0;
tbUi.nPlayWin   = 1;
tbUi.nPlayFail  = 2;
tbUi.nPlayDogfall = 3;

tbUi.szPlayWinSpr = "VictoryMark";
tbUi.szPlayFailSpr = "FailureMark";
tbUi.szPlayDogfallSpr = "DrawnMark";

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow("HSLJAccount");
end

function tbUi:OnClose()
    if self.nCloseTimer then
        Timer:Close(self.nCloseTimer);
        self.nCloseTimer = nil;
    end    

end

function tbUi:OnCloseTimer()
    self.nCloseTimer = nil;
    Ui:CloseWindow("HSLJAccount");
end

function tbUi:OnOpen(tbAllTeam, nMyTeam, nCloseTime)
    self:HideAllItem("My");
    self:HideAllItem("Enemy");
    self:HideAllAgainst();

    if self.nCloseTimer then
        Timer:Close(self.nCloseTimer);
        self.nCloseTimer = nil;
    end    

    if nCloseTime and nCloseTime > 0 then
        self.nCloseTimer = Timer:Register(nCloseTime * Env.GAME_FPS, self.OnCloseTimer, self);
    end

    local nMyPos = -1;
    for nTeam, tbTeamInfo in pairs(tbAllTeam) do
        for nIndex, tbInfo in pairs(tbTeamInfo.tbAllPlayer) do
            if tbInfo.szName == me.szName then
                nMyPos = nIndex;
                if tbInfo.nTeamPos and tbInfo.nTeamPos > 0 then
                    nMyPos = tbInfo.nTeamPos;
                end
            end    
        end   
    end

    for nTeam, tbTeamInfo in pairs(tbAllTeam) do
        local szCamp = "Enemy";
        if nTeam == nMyTeam then
            szCamp = "My";
        end    

        if Lib:IsEmptyStr(tbTeamInfo.szName) then
            self.pPanel:SetActive(szCamp.."Team", false);
        else
            self.pPanel:SetActive(szCamp.."Team", true);
            self.pPanel:Label_SetText(szCamp.."Team", tbTeamInfo.szName or "");
        end
            
        --self.pPanel:SetActive(szCamp.."Team", true);
        tbTeamInfo.nResult = tbTeamInfo.nResult or 0;

        if tbTeamInfo.nResult == tbUi.nPlayWin then 
            self.pPanel:SetActive(szCamp.."Victory", true);
        elseif tbTeamInfo.nResult == tbUi.nPlayFail then
            self.pPanel:SetActive(szCamp.."Failure", true);
        elseif tbTeamInfo.nResult == tbUi.nPlayDogfall then 
            self.pPanel:SetActive(szCamp.."Tie", true);   
        end 

        for nIndex, tbInfo in pairs(tbTeamInfo.tbAllPlayer) do
            local nPos = nIndex;
            if tbInfo.nTeamPos and tbInfo.nTeamPos > 0 then
                nPos = tbInfo.nTeamPos;
            end
                
            self:SetItemShowInfo(szCamp, nPos - 1, tbInfo, tbTeamInfo.nResult ~= 0);
            if tbInfo.nTeamPos then
                self:SetItemAgainstInfo(szCamp, nPos - 1, tbInfo, nMyPos - 1);
            end    
        end   
    end    
end

function tbUi:SetItemAgainstInfo(szCamp, nIndex, tbInfo, nMyIndex)
    local nIPos = 2;
    if szCamp == "My" then
        nIPos = 1;
    end

    self.pPanel:SetActive("Against"..tbInfo.nTeamPos, true);

    if tbInfo.nResult and tbInfo.nResult ~= tbUi.nPlayNone then
        local szUiName = string.format("Against%s_%s", tbInfo.nTeamPos, nIPos);
        self.pPanel:SetActive(szUiName, true);
        local szSpr = tbUi.szPlayFailSpr;
        if tbInfo.nResult == tbUi.nPlayWin then 
            szSpr = tbUi.szPlayWinSpr;

        elseif tbInfo.nResult == tbUi.nPlayFail then
            szSpr = tbUi.szPlayFailSpr;

        elseif tbInfo.nResult == tbUi.nPlayDogfall then 
            szSpr = tbUi.szPlayDogfallSpr;
        end 

        self.pPanel:Sprite_SetSprite(szUiName, szSpr);
    end

    self.pPanel:SetActive(szCamp.."Light"..tostring(nIndex), nIndex == nMyIndex);    
end

function tbUi:SetItemShowInfo(szCamp, nIndex, tbInfo, bResult)
    self.pPanel:SetActive(szCamp.."Light"..tostring(nIndex), false);   
    self.pPanel:SetActive(szCamp..nIndex, true);
    if tbInfo.nHonorLevel > 0 then
        self.pPanel:SetActive(szCamp.."Rank"..tostring(nIndex),true);
        local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel)
        self.pPanel:Sprite_Animation(szCamp.."Rank"..tostring(nIndex), ImgPrefix, Atlas);
    else
        self.pPanel:SetActive(szCamp.."Rank"..tostring(nIndex),false);
    end

    local nTmpBigFace = PlayerPortrait:CheckBigFaceId(tbInfo.nBigFace, tbInfo.nPortrait, tbInfo.nFaction, tbInfo.nSex);
    local szHead, szAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace);
    self.pPanel:Sprite_SetSprite(szCamp.."Head"..tostring(nIndex), szHead, szAtlas);
    local szFactionIcon = Faction:GetIcon(tbInfo.nFaction);
    self.pPanel:Sprite_SetSprite(szCamp.."Faction"..tostring(nIndex),szFactionIcon);
    self.pPanel:Label_SetText(szCamp.."Level"..tostring(nIndex), tbInfo.nLevel.."级");
    self.pPanel:Label_SetText(szCamp.."Name"..tostring(nIndex), tbInfo.szName); 

    if bResult and tbInfo.nKillCount and tbInfo.nDamage then
        self.pPanel:Label_SetText(szCamp.."FightTitle"..tostring(nIndex), "杀人数：");
        self.pPanel:Label_SetText(szCamp.."FightValue"..tostring(nIndex), tbInfo.nKillCount);
        self.pPanel:SetActive(szCamp.."DmgValue"..tostring(nIndex), true);
        self.pPanel:SetActive(szCamp.."DamageTitle"..tostring(nIndex), true);
        self.pPanel:Label_SetText(szCamp.."DamageTitle"..tostring(nIndex), "伤害量：");
        self.pPanel:Label_SetText(szCamp.."DmgValue"..tostring(nIndex), tbInfo.nDamage);
    elseif tbInfo.nJiFen and tbInfo.nRank then
        self.pPanel:Label_SetText(szCamp.."FightTitle"..tostring(nIndex), "排名：");
        local szRank = string.format("%s", tbInfo.nRank);
        if tbInfo.nRank == 1 then
            szRank = string.format("[FFFE0D]%s[-]", tbInfo.nRank);
        end    
        self.pPanel:Label_SetText(szCamp.."FightValue"..tostring(nIndex), szRank);
        self.pPanel:SetActive(szCamp.."DmgValue"..tostring(nIndex), true);
        self.pPanel:SetActive(szCamp.."DamageTitle"..tostring(nIndex), true);
        self.pPanel:Label_SetText(szCamp.."DamageTitle"..tostring(nIndex), "积分：");
        self.pPanel:Label_SetText(szCamp.."DmgValue"..tostring(nIndex), tbInfo.nJiFen);
    else    
        self.pPanel:Label_SetText(szCamp.."FightTitle"..tostring(nIndex), "战力：");
        self.pPanel:Label_SetText(szCamp.."FightValue"..tostring(nIndex), tbInfo.nFightPower);
        self.pPanel:SetActive(szCamp.."DmgValue"..tostring(nIndex), false);
        self.pPanel:SetActive(szCamp.."DamageTitle"..tostring(nIndex), false);
    end

    for nI = 1, 2 do
        local szItemName = string.format("%sItem%s_%s", szCamp, nIndex, nI);
        self.pPanel:SetActive(szItemName, false);
    end

    if tbInfo.tbAward then
        for nI = 1, 2 do
            local szItemName = string.format("%sItem%s_%s", szCamp, nIndex, nI);
            local tbReward = tbInfo.tbAward[nI];
            self.pPanel:SetActive(szItemName, tbReward ~= nil);
            if tbReward then
                self[szItemName]:SetGenericItem(tbReward)
                self[szItemName].fnClick = self[szItemName].DefaultClick
            end 
        end
    end    
end

function tbUi:HideAllItem(szCamp)
    self.pPanel:SetActive(szCamp.."Victory", false);
    self.pPanel:SetActive(szCamp.."Failure", false);
    self.pPanel:SetActive(szCamp.."Team", false);
    self.pPanel:SetActive(szCamp.."Tie", false);
    for nI = 0, self.nMaxItemCount - 1 do
        self.pPanel:SetActive(szCamp..nI, false);
    end    
end

function tbUi:HideAllAgainst()
    for nI = 1, self.nMaxItemCount do
        self.pPanel:SetActive("Against"..nI, false);
        self.pPanel:SetActive(string.format("Against%s_%s", nI, 1), false);
        self.pPanel:SetActive(string.format("Against%s_%s", nI, 2), false);
    end 
end     