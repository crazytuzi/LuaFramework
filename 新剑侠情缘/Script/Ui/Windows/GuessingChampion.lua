
Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
local tbDef = HuaShanLunJian.tbDef;
local tbGuessingDef     = tbDef.tbChampionGuessing;

local tbUi = Ui:CreateClass("GuessingChampionPanel");
tbUi.tbOnClick = {}; 

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow("GuessingChampionPanel");
end

function tbUi:OnClose()
end

function tbUi:OnOpen(nGameType)
    self.nGameType = nGameType
    self:SetTeamData()
    self:UpdateInfo(); 
end

function tbUi:OnClickTeam(nI)
    local tbFightTeam = self.tbArenaPlan[nI];
    if not tbFightTeam then
        me.CenterMsg("请选择战队", false);
        return;
    end

    Ui:OpenWindow("GuessingSurePanel", tbFightTeam, self.nGameType);
    Ui:CloseWindow("GuessingChampionPanel"); 
end

function tbUi:SetTeamData()
    self.tbArenaPlan = {};
    if not self.nGameType then
        local tbArena = Player:GetServerSyncData("HSLJFinalsMatch");
        if not tbArena then
            return;
        end
        self.tbArenaPlan = tbArena[1] or {};
    else
        local tbSyndata, nSynTimeVersion, nWinTeamId = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. self.nGameType) ;
        if not tbSyndata or nWinTeamId then
            return
        end
        self.tbArenaPlan = { }
        for i=1,16 do
            local v = tbSyndata[i]
            if v then
                table.insert(self.tbArenaPlan,  {szName = v.szName, nId = v.nFightTeamID} );
            else
                break;
            end
        end
    end
end

function tbUi:UpdateInfo()
    local fnSetItem = function (itemObj, index)
        for i=1,2 do
            local nTeamIndex = (index - 1) * 2 + i
            local tbInfo = self.tbArenaPlan[nTeamIndex]
            if tbInfo then
                itemObj.pPanel:SetActive("BtnTeam" .. i, true) 
                itemObj["BtnTeam" .. i].pPanel.OnTouchEvent = function (buttonObj)
                    self:OnClickTeam(nTeamIndex)
                end;
                itemObj["BtnTeam" .. i].pPanel:Label_SetText("TeamName"..i, tbInfo.szName or "");     
            else
                itemObj.pPanel:SetActive("BtnTeam" .. i, false)    
            end
        end
    end

    self.ScrollView:Update(math.ceil(#self.tbArenaPlan / 2), fnSetItem )
end



local tbGuessingSure = Ui:CreateClass("GuessingSurePanel");
tbGuessingSure.tbOnClick = {};

function tbGuessingSure.tbOnClick:BtnClose()
    Ui:CloseWindow("GuessingSurePanel");
end

function tbGuessingSure.tbOnClick:BtnOperation()
    if not self.tbFightTeam then
        me.CenterMsg("请选择战队", true);
        return;
    end

    if not self.nGameType then
        RemoteServer.DoRequesHSLJ("ChampionGuessing", self.tbFightTeam.nId);    
    else
        RemoteServer.DoRequesWLDH("ChampionGuessing", self.tbFightTeam.nId, self.nGameType);    
    end
    
end


function tbGuessingSure:OnOpen(tbFightTeam, nGameType)
    self.tbFightTeam = tbFightTeam;
    self.nGameType = nGameType
    self.pPanel:Label_SetText("TeamName", self.tbFightTeam.szName);
end

function tbGuessingSure:OnSyncData(szName)
    if szName == "HSLJGuessing" or szName == "WLDHGuessing" then
        Ui:CloseWindow("GuessingSurePanel");
    end  
end    

function tbGuessingSure:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
    };

    return tbRegEvent;
end



local tbStakeUi = Ui:CreateClass("GuessingStakePanel");
tbStakeUi.tbOnClick = {};

function tbStakeUi.tbOnClick:BtnClose()
    Ui:CloseWindow("GuessingStakePanel");
end

function tbStakeUi.tbOnClick:BtnOperation()
    if not self.tbFightTeam then
        me.CenterMsg("请选择战队", true);
        return;
    end

    RemoteServer.DoRequesHSLJ("ChampionGuessing", self.tbFightTeam.nId, self.nCurOneNote);    
end

function tbStakeUi.tbOnClick:BtnPlus()
    local nOneNote = self.nCurOneNote + 1;
    self:UpdateNumberInput(nOneNote);
end

function tbStakeUi.tbOnClick:BtnMinus()
    local nOneNote = self.nCurOneNote - 1;
    self:UpdateNumberInput(nOneNote);
end

function tbStakeUi.tbOnClick:Label_Number()
    local function fnUpdate(nInput)
        local nResult = self:UpdateNumberInput(nInput)
        return nResult
    end

    Ui:OpenWindow("NumberKeyboard", fnUpdate)
end

function tbStakeUi:OnClose()
    
end


function tbStakeUi:UpdateNumberInput(nInput)
    local nVip = me.GetVipLevel();
    local nLimtit = HuaShanLunJian:GetGuessingVipLimit(nVip);
    local nCurNote = me.GetUserValue(tbDef.nSaveGuessGroupID, tbDef.nSaveGuessOneNote);
    local nRetCount = nLimtit - nCurNote;
    nInput = math.max(nInput, 0);
    if nInput > nRetCount then
        nInput = nRetCount;
        me.CenterMsg(string.format("当前最多能投%s注", nRetCount), true);
    end

    self.nCurOneNote = nInput;
    self:UpdateCostGlod();
    return self.nCurOneNote;
end

function tbStakeUi:OnOpen(tbFightTeam)
    self.tbFightTeam = tbFightTeam;
    self.nCurOneNote = 0;
    self:UpateInfo();
end

function tbStakeUi:UpateInfo()
    self.pPanel:Label_SetText("InputNumber", string.format("[73cbd5]每注花费[-][c8ff00]%s[-][73cbd5]元宝，请输入数量[-]", tbGuessingDef.nOneNoteGold));
    self.pPanel:Label_SetText("TeamName", self.tbFightTeam.szName);
    self.pPanel:Label_SetText("TxtHaveMoney", tostring(me.GetMoney("Gold")));
    self:UpdateCostGlod();
end    

function tbStakeUi:UpdateCostGlod()
    local nTotalCost = self.nCurOneNote  * tbGuessingDef.nOneNoteGold;
    self.pPanel:Label_SetText("TxtCostMoney", tostring(nTotalCost));
    self.pPanel:Label_SetText("Label_Number", tostring(self.nCurOneNote));
end

function tbStakeUi:OnSyncData(szName)
    if szName == "HSLJGuessing" or szName == "WLDHGuessing" then
        self.nCurOneNote = 0;
        self:UpateInfo();     
    end  
end    

function tbStakeUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
    };

    return tbRegEvent;
end