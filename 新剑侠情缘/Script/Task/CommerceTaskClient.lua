function CommerceTask:OnRespondSync(tbData, tbHelp)
    tbData.tbHelp = tbHelp;
    CommerceTask.tbCommerceData = tbData;
    Task:UpdateNpcTaskState();
    Task:OnTaskUpdate(Task.tbDailyTaskSettings[Task.emDAILY_COMMERCE].nTaskId)
    Task:OnCommerceTaskUpdate()
    
    UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_COMMERCE_DATA, tbData);
end

function CommerceTask:OnRespondHelp(szInfo)
    Kin:UpdateMemberList();
    me.CenterMsg(szInfo);
    
    UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_COMMERCE_HELP);
end

function CommerceTask:OnNoHelpTimes(nNextVip)
    Ui:CloseWindow("CommerceHelpPanel")
    if nNextVip == 0 then
        me.CenterMsg("协助失败，商会协助次数已耗尽")
        return
    end

    local fnConfirm = function ()
        Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
    end
    
    local szMsg = string.format("商会协助次数耗尽，[FFFE0D] 【剑侠尊享%d】 [-]可增加每日商会协助次数，还有[FFFE0D] 超多福利[-]，是否前往？", nNextVip)
    Ui:OpenWindow("MessageBox", szMsg, { {fnConfirm}, {} }, {"前往", "取消"})
end

function CommerceTask:GetHeadTip(pNpc)
    if pNpc.szClass == "CommerceTask" and  me.nLevel >= CommerceTask.START_LEVEL then
        if self:IsDoingTask(me) then
            local tbCommerceData = CommerceTask.tbCommerceData;
            local nFinishCount = 0;
            for k,v in pairs(tbCommerceData.tbTask) do
                if v.bFinish then
                    nFinishCount = nFinishCount + 1;
                end
            end

            if nFinishCount >= self.COMPLETE_COUNT then
                return Task.STATE_CAN_FINISH;
            else
                return Task.STATE_ON_DING;
            end
        end

        if self:CanAcceptTask(me) then
            return Task.STATE_CAN_ACCEPT;
        end
    end

    return Task.STATE_NONE
end

function CommerceTask:GetGatherName(nGatherId)
    local tbGather = self.tbCommerceSetting[nGatherId];
    if tbGather then
        return tbGather.Name;
    end
end

function CommerceTask:GetGatherIcon(nGatherId)
    local tbGather = self.tbCommerceSetting[nGatherId];
    if tbGather then
        return tbGather.Icon;
    end
end

function CommerceTask:GetGatherPosition(nGatherId)
    if not self.tbPosInfo or not self.tbPosInfo[nGatherId] then
        return;
    end

    local tbPos = self.tbPosInfo[nGatherId];
    if not tbPos or not next(tbPos) then
        return;
    end

    local tbCurMapPos = {};
    for _, tbInfo in pairs(tbPos) do
        if tbInfo.nMapId == me.nMapId then
            table.insert(tbCurMapPos, tbInfo);
        end
    end

    local bCurMap = #tbCurMapPos > 0;
    local nRan = bCurMap and MathRandom(1, #tbCurMapPos) or MathRandom(1, #tbPos);
    local tbPosInfo = bCurMap and tbCurMapPos[nRan] or tbPos[nRan];
    return {tbPosInfo.nMapId, tbPosInfo.nPosX, tbPosInfo.nPosY};
end

function CommerceTask:GetTaskNpc()
    if self.tbCommerceNpc[me.nMapId] then
        return me.nMapId, self.tbCommerceNpc[me.nMapId].nNpc
    end 
    local nRan = MathRandom(1000000)
    local nSum = 0
    local tbDefault
    for nMapTID, tbInfo in pairs(self.tbCommerceNpc) do
        nSum = nSum + tbInfo.nRandom
        if nRan <= nSum then
            return nMapTID, tbInfo.nNpc
        end
        tbDefault = tbDefault or {nMapTID, tbInfo.nNpc}
    end
    return unpack(tbDefault)
end

function CommerceTask:AutoPathToTaskNpc()
    local nMapTID, nNpcTID = self:GetTaskNpc()
    local nPosX, nPosY = AutoPath:GetNpcPos(nNpcTID, nMapTID)
    local fnCallback = function ()
        local nNpcId = AutoAI.GetNpcIdByTemplateId(nNpcTID);
        if nNpcId then
            Operation.SimpleTap(nNpcId);
        end
    end
    AutoPath:GotoAndCall( nMapTID, nPosX, nPosY, fnCallback, Npc.DIALOG_DISTANCE );
end

function CommerceTask:LoadCommerceSetting()
    self.tbPosInfo         = {};
    self.tbCommerceSetting = LoadTabFile("Setting/Npc/NpcCommerce.tab", "dss", "TemplateID", {"TemplateID", "Name", "Icon"});

    for _, nMapTemplateId in pairs(CommerceTask.tbWildMap) do
        self:LoadMapCommerceNpc(nMapTemplateId);
    end
end

function CommerceTask:LoadMapCommerceNpc(nMapTemplateId)
    local szPath = Map:GetMapInfoPath(nMapTemplateId);
    local tbNpc  = LoadTabFile(szPath, "ddd", nil, {"NpcTemplateId", "XPos", "YPos"});
    for _, tbNpcInfo in pairs(tbNpc) do
        local nTemplateId = tbNpcInfo.NpcTemplateId;
        if self.tbCommerceSetting[nTemplateId] then
            self.tbPosInfo[nTemplateId] = self.tbPosInfo[nTemplateId] or {};
            table.insert(self.tbPosInfo[nTemplateId], {nMapId = nMapTemplateId, nPosX = tbNpcInfo.XPos, nPosY = tbNpcInfo.YPos});
        end
    end
end

CommerceTask:LoadCommerceSetting();

function CommerceTask:IsCommerceTask(nTaskId)
    if not nTaskId then
        return
    end

    local tbInfo = Task.tbDailyTaskSettings[Task.emDAILY_COMMERCE]
    if nTaskId == tbInfo.nTaskId then
        return true
    end
end

function CommerceTask:GetCompleteText()
    local nDegree = DegreeCtrl:GetDegree(me, "CommerceTask")
    if nDegree > 0 or self:IsDoingTask(me) then
        return ""
    end
    if self.tbCommerceData.bFinish then
        return "[0aff19]已完成"
    end
    if self.tbCommerceData.bGiveUp then
        return "[ff0a2f]已放弃"
    end
end

function CommerceTask:GetLastHelpTimes()
    local nHelpMax = self:GetHelpTimes(me)
    local nCurDay = Lib:GetLocalDay()
    local tbHelpOtherData = self.tbCommerceData.tbHelpOtherData
    if not tbHelpOtherData or
        not tbHelpOtherData.nHelpTimes or
        not tbHelpOtherData.nLastHelpDay or
        tbHelpOtherData.nLastHelpDay < nCurDay then
        return nHelpMax
    end

    return nHelpMax - tbHelpOtherData.nHelpTimes
end