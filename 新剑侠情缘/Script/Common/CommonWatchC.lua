
local RepresentMgr = luanet.import_type("RepresentMgr");
CommonWatch.tbShowWatchData = CommonWatch.tbShowWatchData or {};

function CommonWatch:ResetShowData(tbSyncData)
    self.tbShowWatchData = {};
    local tbTeamShowData = {};
    for nTeam, tbAllPlayer in pairs(tbSyncData or {}) do
        local tbInfo = {};
        tbInfo.nTeam = nTeam;
        tbInfo.tbAllPlayer = {};
        for nNpcID, tbPlayer in pairs(tbAllPlayer) do
            table.insert(tbInfo.tbAllPlayer, {name = tbPlayer.szName, id = nNpcID});
            RepresentMgr.AddShowRepNpc(nNpcID);
        end

        if Lib:HaveCountTB(tbInfo.tbAllPlayer) then
            table.sort(tbInfo.tbAllPlayer, function (a, b) return a.id < b.id; end)
        end
            
        table.insert(tbTeamShowData, tbInfo);    
    end

    if Lib:HaveCountTB(tbTeamShowData) then
        table.sort(tbTeamShowData, function (a, b) return a.nTeam < b.nTeam; end)
    end

    for _, tbInfo in ipairs(tbTeamShowData) do
        table.insert(self.tbShowWatchData, tbInfo.tbAllPlayer);
    end 
end

function CommonWatch:WatchNpc(tbSyncData, bNotChangeUI)
    self.bOpenWatchNpc = true;
    self:ResetShowData(tbSyncData);
    self:EndWatch();
    self.szWatchLeave = self.szWatchLeave or "";
    self.bNotChangeUI = bNotChangeUI;

    if not self.bNotChangeUI then
        if Ui:WindowVisible("QYHLeavePanel") == 1 then
            Ui("QYHLeavePanel"):SetBtnWitnessWar("CommonWatch", true);   
        else
            Ui:OpenWindow("QYHLeavePanel", "CommonWatch", {BtnWitnessWar = true})
        end
    end

    Log("CommonWatch WatchNpc");    
end

function CommonWatch:GetWatchShowInfo()
    local tbData = 
    {
        nCurWatchId = self.nWatchNpcID or 0,
        szType = "CommonWatchMenu",
        tbPlayer = self.tbShowWatchData,
    }

    return tbData;
end

function CommonWatch:CheckNpcExist(nNpcID)
    local npcRep = RepresentMgr.GetNpcRepresent(nNpcID);
    if not npcRep then
        return false;
    end

    return true;    
end

function CommonWatch:CloseWatchTimer()
    if self.nWatchTimer then
        Timer:Close(self.nWatchTimer);
        self.nWatchTimer = nil;
    end    
end

function CommonWatch:DoStartWatch(nNpcID)
    self:CloseWatchTimer();
    local bRet = self:CheckNpcExist(nNpcID);
    if bRet then
        self:StartWatchNpcID(nNpcID);
    else
        self.nWatchTimer = Timer:Register(Env.GAME_FPS, self.OnStartWatchTimer, self, nNpcID);    
    end    
end

function CommonWatch:OnStartWatchTimer(nNpcID)
    local bRet = self:CheckNpcExist(nNpcID);
    if not bRet then
        return true;
    end

    self:CloseWatchTimer();
    self:StartWatchNpcID(nNpcID);
end

function CommonWatch:DoEndWatch(bNotState)
    if not self.bOpenWatchNpc then
        return;
    end

    if bNotState then
        self.nUiChangeUiState = nil;
    end    

    self:EndWatch();  
    self.tbShowWatchData = {};

    if not self.bNotChangeUI then
        if Ui:WindowVisible("QYHLeavePanel") == 1 then
            Ui("QYHLeavePanel"):SetBtnWitnessWar("CommonWatch", false);
        end
        if Ui:WindowVisible("WatchMenuPanel") == 1 then
            Ui:CloseWindow("WatchMenuPanel");
        end
    end
        
    RepresentMgr.ClearShowRepNpc();
    self.bOpenWatchNpc = false;
end

function CommonWatch:StartWatchNpcID(nNpcID)
    local bRet = self:CheckNpcExist(nNpcID);
    if not bRet then
        return;
    end

    if not self.nUiChangeUiState then
        self.nUiChangeUiState = Ui.nChangeUiState;
        self.bUiHideStateWnd = Ui.bHideStateWnd;

        if Ui:WindowVisible("QYHLeavePanel") == 1 then
            if Ui("QYHLeavePanel").pPanel:IsActive("BtnLeave") then
                self.szWatchLeave = "BtnLeave";
                Ui("QYHLeavePanel").pPanel:SetActive("BtnLeave", false);
            end
        end        
    end    
        
    Operation:DisableWalking()

    Ui:ChangeUiState(Ui.STATE_WATCH_FIGHT);
        
    BindCameraToNpc(nNpcID, 220);
    self.nWatchNpcID = nNpcID;

    if not self.bNotChangeUI then
        local tbData = self:GetWatchShowInfo();
        UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH, tbData);
    end    
end


function CommonWatch:EndWatch()
    self:CloseWatchTimer();
    if not self.nWatchNpcID then
        return;
    end

    if self.nUiChangeUiState then
        Ui:ChangeUiState(self.nUiChangeUiState, self.bUiHideStateWnd);
        self.nUiChangeUiState = nil;
    end    

    self.nWatchNpcID = nil;
    BindCameraToNpc(0, 0)
    Operation:EnableWalking();

    if not self.bNotChangeUI then
        local tbData = self:GetWatchShowInfo();
        UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH, tbData)
    end
        
    if Ui:WindowVisible("QYHLeavePanel") == 1 and self.szWatchLeave == "BtnLeave" then
        Ui("QYHLeavePanel").pPanel:SetActive(self.szWatchLeave, true);
        self.szWatchLeave = "";
    end     
end

function CommonWatch:OnMapLoaded()
    self:DoEndWatch(true);

    if self.nAutoTimerRegister then
        Timer:Close(self.nAutoTimerRegister);
        self.nAutoTimerRegister = nil;
    end 

    if self.bLoadMapAutoPath then
        self.bLoadMapAutoPath = false;
        Timer:Register(1, function ()
            if CommonWatch.tbAutoData and CommonWatch.tbAutoData.nMapId == me.nMapId then
                AutoPath:GotoAndCall(CommonWatch.tbAutoData.nMapId, CommonWatch.tbAutoData.nDstX, CommonWatch.tbAutoData.nDstY, CommonWatch.OnFinishAutoPath, 10);
            end
        end)    
    end    
end

CommonWatch.tbAutoPathFun =
{
    ["HSLJ"] = function (tbData)
        if WuLinDaHui:IsInMap(me.nMapTemplateId) then
            RemoteServer.DoRequesWLDH("PlayerWatchTeamPlayer", tbData.tbParam[1], true);
        else
            RemoteServer.DoRequesHSLJ("PlayerWatchTeamPlayer", tbData.tbParam[1], true);
        end
    end;
}

function CommonWatch.OnFinishAutoPath()
    if not CommonWatch.tbAutoData then
        return;
    end

    local funCall = CommonWatch.tbAutoPathFun[CommonWatch.tbAutoData.szType];
    if not funCall then
        return;
    end

    funCall(CommonWatch.tbAutoData);
end

function CommonWatch:StopAutoPath()
    local _, nX, nY = me.GetWorldPos();
    AutoPath:GotoAndCall(me.nMapId, nX + 1, nY, function()  end);
end

function CommonWatch:AutoPathWatch(tbAutoData)
    self.tbAutoData = tbAutoData;
    self.bLoadMapAutoPath = false;    
    if tbAutoData.nMapId == me.nMapId then
        AutoPath:GotoAndCall(tbAutoData.nMapId, tbAutoData.nDstX, tbAutoData.nDstY, CommonWatch.OnFinishAutoPath, 10);
    else
        self.bLoadMapAutoPath = true;

        if tbAutoData.nMapTemplateId == me.nMapTemplateId then
            if self.nAutoTimerRegister then
                Timer:Close(self.nAutoTimerRegister);
                self.nAutoTimerRegister = nil;
            end 

            self.nAutoTimerRegister = Timer:Register(Env.GAME_FPS, function ()
                if not CommonWatch.tbAutoData then
                    self.nAutoTimerRegister = nil;
                    self.bLoadMapAutoPath = false;
                    return;
                end

                if CommonWatch.tbAutoData.nMapId ~= me.nMapId then
                    return true;
                end   

                self.nAutoTimerRegister = nil;
                self.bLoadMapAutoPath = false;
                AutoPath:GotoAndCall(CommonWatch.tbAutoData.nMapId, CommonWatch.tbAutoData.nDstX, CommonWatch.tbAutoData.nDstY, CommonWatch.OnFinishAutoPath, 10);
            end)  
        end    
    end    
end

PlayerEvent:RegisterGlobal("OnMapLoaded",       CommonWatch.OnMapLoaded, CommonWatch);