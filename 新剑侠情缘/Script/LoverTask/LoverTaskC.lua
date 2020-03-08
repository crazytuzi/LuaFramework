local tbTaskDefendFuben = LoverTask.tbSetting[LoverTask.TASK_TYPE_DEFEND]
LoverTask.nRecommondCD = 10
function LoverTask:OnSynDefendSeriesData(tbData)
	local tbSetting = tbData or {}
    local tbTextInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
    if me.nMapTemplateId ~= tbTaskDefendFuben.nFubenMapTemplateId then
        return
    end

    for i = #tbTextInfo,1,-1 do
       tbTextInfo[i] = nil
    end

    for szKey,tbInfo in pairs(tbSetting) do
        for nRoad,tbNpc in pairs(tbInfo) do
            local tbTemp = LoverTask:GetSeriesSetting(szKey,tbNpc.nSeries)
            if tbTemp then
                tbTemp.XPos = tbNpc.nNpcX
                tbTemp.YPos = tbNpc.nNpcY
                table.insert(tbTextInfo,tbTemp)
            end
        end
    end
end

function LoverTask:OnLeaveDefendMap()
	Ui:CloseWindow("HomeScreenFuben","TeamFuben")
end

function LoverTask:OnPlayDialogEnd()
    LoverTask:TrackTask()
end

function LoverTask:PlayTaskDialog(nDialogId)
    Ui:TryPlaySitutionalDialog(nDialogId, nil, {self.OnPlayDialogEnd})
end

function LoverTask:OnRecommondLover(tbRecommondPlayer)
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RECOMMOND_LOVER, tbRecommondPlayer);
end

function LoverTask:ChangeRecommondLover()
    if GetTime() - (me.nRecommondTime or 0) < self.nRecommondCD then
        me.CenterMsg("操作过于频繁", true)
        return
    end
    me.nRecommondTime = GetTime()
    self:SynRecommondLover()
end

function LoverTask:SynRecommondLover()
    RemoteServer.LoverTaskOnClientCall("RecommondLover");
end

function LoverTask:TrackTask()
    if me.nMapTemplateId == 15 then
        Ui.HyperTextHandle:Handle("[url=npc:燕若雪, 631, 15]",0,0)
    else
        Ui.HyperTextHandle:Handle("[url=npc:燕若雪, 631, 10]",0,0)
    end 
end

function LoverTask:GiveUpTask()
    local bRet, szMsg = LoverTask:CheckGiveUpTask(me)
    if not bRet then
        me.CenterMsg(szMsg, true)
        return 
    end
    me.MsgBox("是否放弃任务？", {{"确定", function ()
                RemoteServer.LoverTaskOnClientCall("GiveUpTask");
            end}, {"取消"}})
end

function LoverTask:OnGiveUpTask()
    UiNotify.OnNotify(UiNotify.emNOTIFY_LOVER_TASK_STATE_CHANGE);
end

function LoverTask:OnFinishTask()
    UiNotify.OnNotify(UiNotify.emNOTIFY_LOVER_TASK_STATE_CHANGE);
end

function LoverTask:OnAcceptTask()
    UiNotify.OnNotify(UiNotify.emNOTIFY_LOVER_TASK_STATE_CHANGE);
end

function LoverTask:OnNextTaskStep()
    UiNotify.OnNotify(UiNotify.emNOTIFY_LOVER_TASK_STATE_CHANGE);
end

function LoverTask:OnShowDialogEnd()
    RemoteServer.LoverTaskOnClientCall("DoTask", LoverTask.PROCESS_SHOW_TASK_PANEL);
end

function LoverTask:GetFinishCount(pPlayer)
    local nNowTime = GetTime()
    local nFinishCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.nFinishCountIdx);
    local nFinishTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.nUpdateTimeIdx);
    if Lib:IsDiffWeek(nNowTime, nFinishTime) then
       nFinishCount = 0
    end
    return nFinishCount
end

function LoverTask:ShowDialog(nDialogId)
    Ui:TryPlaySitutionalDialog(nDialogId, nil, {self.OnShowDialogEnd})
end

function LoverTask:GetTaskDegreeInfo()
    local nFinishCount = LoverTask:GetFinishCount(me)
    return string.format("次数：%d/%d", LoverTask.MAX_FINISH_COUNT - nFinishCount, LoverTask.MAX_FINISH_COUNT)
end

function LoverTask:IsCompleteTask()
     local nFinishCount = LoverTask:GetFinishCount(me)
     return nFinishCount >= LoverTask.MAX_FINISH_COUNT
end

function LoverTask:IsOpen()
    return LoverTask:CheckLevel(me)
end

function LoverTask:OnDoActionInteract()
    AutoFight:Stop()
end