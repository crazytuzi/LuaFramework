
Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
local tbDef = HuaShanLunJian.tbDef;
local tbRelatedUi = Ui:CreateClass("TeamRelatedPanel");
tbRelatedUi.tbOnClick = {};
tbRelatedUi.tbDefSize = {260, 320};
tbRelatedUi.tbNumberSize = {260, 380};

function tbRelatedUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME);
end

function tbRelatedUi.tbOnClick:BtnCreate()
    Ui:OpenWindow("CreateTeamPanel", self.nWLDHType);
end

function tbRelatedUi.tbOnClick:BtnGroup()
    if self.nWLDHType then
        RemoteServer.DoRequesWLDH("JoinFightTeam", self.nWLDHType);    
    else
        RemoteServer.DoRequesHSLJ("JoinFightTeam");
    end
end

function tbRelatedUi.tbOnClick:BtnOut()
    if self.nWLDHType then
        RemoteServer.DoRequesWLDH("QuitFightTeam", self.nWLDHType);    
    else
        RemoteServer.DoRequesHSLJ("QuitFightTeam");    
    end
end

function tbRelatedUi.tbOnClick:BtnNumber()
    local tbTeamInfo;
    if not self.nWLDHType then
        tbTeamInfo = Player:GetServerSyncData("HSLJFightTeamInfo");
    else
        tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. self.nWLDHType);
    end
    if not tbTeamInfo or not tbTeamInfo.szName then
        me.CenterMsg("当前没有创建战队");
        return;
    end 

    Ui:OpenWindow("PlayerNumberPanel", self.nWLDHType);
end

function tbRelatedUi:OnOpen(nWLDHType)
    self.nWLDHType = nWLDHType
    self:UpdateInfo();
end

function tbRelatedUi:UpdateInfo()
    local tbGameFormat;
    if self.nWLDHType then
        tbGameFormat = WuLinDaHui.tbGameFormat[self.nWLDHType]
    else
        local tbStateData = Player:GetServerSyncData("HSLJStateData") or {};
        tbGameFormat = tbDef.tbGameFormat[1];
        if tbStateData.nGameFormatType and tbDef.tbGameFormat[tbStateData.nGameFormatType] then
            tbGameFormat = tbDef.tbGameFormat[tbStateData.nGameFormatType];
        end
    end

    local tbSize = tbRelatedUi.tbDefSize;
    self.pPanel:SetActive("BtnNumber", false);    
    if tbGameFormat.szPKClass and tbGameFormat.szPKClass == "PlayDuel" then
        tbSize = tbRelatedUi.tbNumberSize;
        self.pPanel:SetActive("BtnNumber", true);    
    end

    self.pPanel:Widget_SetSize("Bg", tbSize[1], tbSize[2]);    
end    

local tbCreateUi = Ui:CreateClass("CreateTeamPanel");
tbCreateUi.tbOnClick = {};

function tbCreateUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME);
end

function tbCreateUi.tbOnClick:BtnSure()
    local szTeamName = self.pPanel:Input_GetText("InputTxtTitle");
    if Lib:IsEmptyStr(szTeamName) then
        me.CenterMsg("请输入名字", true);
        return;
    end
    if self.bIsLingJueFengTeam then
        Fuben.LingJueFengWeek:TrySignUpTeam(szTeamName);
        self.bIsLingJueFengTeam = nil;
        Ui:CloseWindow(self.UI_NAME);
        return;
    end

    if not self.nWLDHType then
        local tbStateData = Player:GetServerSyncData("HSLJStateData") or {};
        local tbGameFormat = tbDef.tbGameFormat[1];
        if tbStateData.nGameFormatType and tbDef.tbGameFormat[tbStateData.nGameFormatType] then
            tbGameFormat = tbDef.tbGameFormat[tbStateData.nGameFormatType];
        end

        local tbMember = TeamMgr:GetTeamMember() or {};
        local nMemberCount = Lib:CountTB(tbMember);
        if nMemberCount >= tbGameFormat.nFightTeamCount - 1 then
            RemoteServer.DoRequesHSLJ("CreateFightTeam", szTeamName);
        else
            local funCallBack = function ()
                RemoteServer.DoRequesHSLJ("CreateFightTeam", szTeamName);
            end;

            local szMsg = string.format("本赛制允许战队人数[FFFE0D]%s[-]人，当前队员未满，是否依然创建战队？",  tbGameFormat.nFightTeamCount);
            me.MsgBox(szMsg, {{"确认", funCallBack}, {"取消"}});
        end    
    else
        RemoteServer.DoRequesWLDH("CreateFightTeam", szTeamName, self.nWLDHType);
    end
    
end

function tbCreateUi.tbOnClick:BtnCancel()
    Ui:CloseWindow("CreateTeamPanel");
end

function tbCreateUi:OnOpen(nWLDHType , bIsLingJueFengTeam)
    self.nWLDHType = nWLDHType;
    self.bIsLingJueFengTeam = bIsLingJueFengTeam;
end


local tbNumberUi = Ui:CreateClass("PlayerNumberPanel");
tbNumberUi.tbOnClick = {};
tbNumberUi.nTotalSelect = 3;
tbNumberUi.tbUiPopupOnChange = 
{
}

for nI = 1, tbNumberUi.nTotalSelect do
    tbNumberUi.tbUiPopupOnChange["BtnSelect"..nI] = function (self, szWndName, val)
        if self.bLoack then
            return;
        end

        local _, _, nRetPos = string.find(szWndName, "BtnSelect(%d+)");
        local nTeamPos = tonumber(nRetPos);
        local tbSuItem = self.tbAllPlayerInfo[nTeamPos];
        local nFindePos = nTeamPos;
        for nPos, tbInfo in pairs(self.tbAllPlayerInfo) do
            if tbInfo.szName == val then
                nFindePos = nPos;
            end    
        end

        if nFindePos == nTeamPos then
            return;
        end

        self.bChangeTeam = true;
        local tbFindPos = self.tbAllPlayerInfo[nFindePos];
        self.tbAllPlayerInfo[nFindePos] = tbSuItem;
        self.tbAllPlayerInfo[nTeamPos] = tbFindPos;
        Timer:Register(1, function ()
            self:UpdateAllItem();
        end)
    end
end    

function tbNumberUi.tbOnClick:BtnClose()
    if self.bChangeTeam then
        me.MsgBox("未保存是否要关闭？", {{"确定", function () Ui:CloseWindow("PlayerNumberPanel"); end}, {"取消"}});
    else
        Ui:CloseWindow("PlayerNumberPanel");
    end    
end

function tbNumberUi.tbOnClick:BtnSure()
    local tbChangeData = {};
    for nNum, tbInfo in pairs(self.tbAllPlayerInfo) do
        tbChangeData[tbInfo.nPlayerID] = nNum;
    end    
    if self.nWLDHType then
        RemoteServer.DoRequesWLDH("ChangeTeamNum", tbChangeData, self.nWLDHType);    
    else
        RemoteServer.DoRequesHSLJ("ChangeTeamNum", tbChangeData);
    end
    
    self.bChangeTeam = false; 
end

function tbNumberUi:OnOpen(nWLDHType)
  if WuLinDaHui:IsInMap(me.nMapTemplateId) then
        nWLDHType = 3
    end
    self.nWLDHType = nWLDHType
    if nWLDHType then
        RemoteServer.DoRequesWLDH("RequestFightTeam", nWLDHType);
    else
        RemoteServer.DoRequesHSLJ("RequestFightTeam");
    end
    
    self.tbAllPlayerInfo = {};
    self:UpdateInfo();
end

function tbNumberUi:GetServerSynKey()
    if self.nWLDHType then
        return "WLDHFightTeamInfo" .. self.nWLDHType
    else
        return "HSLJFightTeamInfo"
    end
end

function tbNumberUi:UpdateInfo()
    local tbTeamInfo = Player:GetServerSyncData(self:GetServerSynKey());
    if not tbTeamInfo or not tbTeamInfo.tbAllPlayer then
        return;
    end

    self:ClearAllSubItem();
    self.tbAllPlayerInfo = {};
    for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
        local tbShowInfo = {};
        tbShowInfo.nPlayerID = nPlayerID;
        tbShowInfo.szName = tbPlayerInfo.szName;
        self.tbAllPlayerInfo[tbPlayerInfo.nNum] = tbShowInfo;
    end

    self:UpdateAllItem();   
end

function tbNumberUi:UpdateAllItem()
    self.bLoack = true;
    for nI, tbInfo in pairs(self.tbAllPlayerInfo) do
        self:SetSubItem(nI);
    end
    self.bLoack = false;  
end

function tbNumberUi:SetSubItem(nIndex)
    self.pPanel:SetActive("BtnSelect"..nIndex, true);
    self.pPanel:SetActive("Number"..nIndex, true);

    local szUiName = "BtnSelect"..nIndex;
    self.pPanel:PopupList_Clear(szUiName)

    for _, tbPlayerInfo in pairs(self.tbAllPlayerInfo) do
        self.pPanel:PopupList_AddItem(szUiName,  tbPlayerInfo.szName)
    end

    self.pPanel:PopupList_Select("BtnSelect"..nIndex, self.tbAllPlayerInfo[nIndex].szName) 
end    

function tbNumberUi:ClearAllSubItem()
    for nI = 1, tbNumberUi.nTotalSelect do
        self.pPanel:SetActive("BtnSelect"..nI, false);
        self.pPanel:SetActive("Number"..nI, false);
    end    
end

function tbNumberUi:OnSyncData(szType)
    if szType == "HSLJFightTeamInfo" then
        self:UpdateInfo();
    elseif type(szType) == "string" and string.find(szType,"WLDHFightTeamInfo") then 
        self:UpdateInfo();
    end    
end

function tbNumberUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
    };

    return tbRegEvent;
end