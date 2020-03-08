
local tbUi = Ui:CreateClass("RuinsTreasureEntrance");
local DEFINE = Fuben.KeyQuestFuben.DEFINE

function tbUi:OnOpen()
    self.pPanel:Label_SetText("Title", DEFINE.NAME)
    self.pPanel:Label_SetText("Txt1", string.format("参与次数：%d/%d", DegreeCtrl:GetDegree(me, "KeyQuestFuben"), DegreeCtrl:GetMaxDegree("KeyQuestFuben", me)))
    self.pPanel:Label_SetText("Txt2", DEFINE.JOIN_UI_TIME_DESC )
    self.pPanel:ResetGeneralHelp("BtnTip", DEFINE.HELP_KEY)
    self.pPanel:SetActive("PreparationTime", false)
    RemoteServer.KeyQuestFubenRequest("RequestReadyMapTime")
end

function tbUi:UpdateLeftTime(  )
    if self.nTimerReady then
        Timer:Close(self.nTimerReady)
    end
    local nBattelReadyMapTime = Player:GetServerSyncData("KeyQuestFubenlReadyMapTime")
    nBattelReadyMapTime = nBattelReadyMapTime + 1;
    self.pPanel:SetActive("PreparationTime", true)
    local fnUpdate = function ( )
        nBattelReadyMapTime = nBattelReadyMapTime - 1
        if nBattelReadyMapTime < 0 then
            self.nTimerReady = nil;
            return 
        end
        self.pPanel:Label_SetText("PreparationTime", string.format("本场准备时间：[FFFE0D]%s[-]", Lib:TimeDesc(nBattelReadyMapTime)))
        return true
    end
    fnUpdate()
    self.nTimerReady = Timer:Register(Env.GAME_FPS * 1, fnUpdate)
end

function tbUi:OnClose()
    if self.nTimerReady then
        Timer:Close(self.nTimerReady)
        self.nTimerReady = nil;
    end
end

function tbUi:OnLeaveMap(  )
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnSyncData( szType )
    if szType == "KeyQuestFubenlReadyMapTime" then
        self:UpdateLeftTime()
    end
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose( ... )
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnSingleJoin()
    if TeamMgr:HasTeam() then
        me.CenterMsg("您当前已经有队伍")
        return
    end
    
    Fuben.KeyQuestFuben:TrySignUp()
end

function tbUi.tbOnClick:BtnTeamJoin()
    if not TeamMgr:HasTeam() then
        me.CenterMsg("您当前没有队伍")
        return
    end
    
    Fuben.KeyQuestFuben:TrySignUp()
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,        self.OnLeaveMap},
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
    };

    return tbRegEvent;
end
