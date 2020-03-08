local tbUi = Ui:CreateClass("WLDHRankPanel");
local tbDef = WuLinDaHui.tbDef

function tbUi:OnOpen(nGameType)
    WuLinDaHui:CheckRequestTopTeamData(nGameType)
    WuLinDaHui:CheckRequestTeamData(nGameType)
    
    local tbGameFormat = WuLinDaHui.tbGameFormat[nGameType] 
    self.pPanel:Label_SetText("Title", string.format("%s初赛排行", tbGameFormat.szName) )

    self.nGameType = nGameType
    self:UpdateList();
end

function tbUi:UpdateList()
    local tbSyndataMy = Player:GetServerSyncData("WLDHFightTeamInfo" .. self.nGameType) ;
    local tbSyndata, nSynTimeVersion = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. self.nGameType) ;
    tbSyndata = tbSyndata or {};

    if not tbSyndataMy or not tbSyndataMy.szName then
        self.pPanel:SetActive("MyInformation", false)
    else
        --同步过来的跨服战队数据信息的战队id 是和本服不一样的 ,也没有对应关系
        self.pPanel:SetActive("MyInformation", true)
        self.pPanel:Label_SetText("Rank", tbSyndataMy.nRank == 0 and "-" or tbSyndataMy.nRank)
        self.pPanel:Label_SetText("Name", tbSyndataMy.szName)
        self.pPanel:Label_SetText("VictoryTime", tbSyndataMy.nWinCount)
        self.pPanel:Label_SetText("MatchTime", Lib:TimeDesc2(tbSyndataMy.nPlayerTime))
        self.pPanel:Label_SetText("Integral", tbSyndataMy.nJiFen)
        self.pPanel:Label_SetText("Server", string.format("%s", tbSyndataMy.szServerName)) --%d服tbSyndata.nServerIdx, 
    end
    
   local fnSetItem = function (itemObj, index)
        local tbData = tbSyndata[index]
        itemObj.pPanel:Label_SetText("Rank", index)
        itemObj.pPanel:Label_SetText("Name", tbData.szName)
        itemObj.pPanel:Label_SetText("VictoryTime", tbData.nWinCount)
        itemObj.pPanel:Label_SetText("MatchTime", Lib:TimeDesc2(tbData.nPlayerTime)  )
        itemObj.pPanel:Label_SetText("Integral", tbData.nJiFen )
        itemObj.pPanel:Label_SetText("Server", string.format("%s", tbData.szServerName) ) --tbData.nServerIdx, 
   end
   self.ScrollView:Update(tbSyndata, fnSetItem)
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,  self.OnSyncData},
        { UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
    };

    return tbRegEvent;
end

function tbUi:OnSyncData(szType)
    if szType == "WLDHTopPreFightTeamList" .. self.nGameType or szType == "WLDHFightTeamInfo" .. self.nGameType then
        self:UpdateList()
    end
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)
    Ui:CloseWindow(self.UI_NAME)
end

