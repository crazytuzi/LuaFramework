function WuLinDaShi:ShowTip()
    local tbTask = WuLinDaShi:CheckFubenTask(me)
    if not tbTask then
        me.CenterMsg("没有指定任务")
        return
    end

    local bInFieldMap = Fuben.tbSafeMap[me.nMapTemplateId] or Map:GetClassDesc(me.nMapTemplateId) == "fight"
    if bInFieldMap and me.nFightMode == 1 then
        local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
        if nX and nY then
            me.CenterMsg("当前不允许参与，正在自动寻路回安全区")
            AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, function ()
                WuLinDaShi:ShowTip()
            end)
        else
            me.CenterMsg("当前地图无法进入副本")
        end
        return
    end

    local tbBtn = {{"前去组队", function () WuLinDaShi:FindTeamer() end}}
    local szMsg = "大侠现在尚未组队"
    if TeamMgr:HasTeam() then
        if not TeamMgr:IsCaptain() then
            me.CenterMsg("你不是队长，无法操作")
            return
        end
        table.insert(tbBtn, {"去意已决", function ()
            if self.nActivityId ~= TeamMgr:GetCurActivityId() then
                RemoteServer.OnClientCallWuLinDaShiFunc("TryEnterFuben")
            else
                TeamMgr:EnterActivity()
            end
        end})
        local tbTeamMember = TeamMgr:GetTeamMember()
        local szNum = Lib:Transfer4LenDigit2CnNum(#tbTeamMember + 1)
        szMsg = string.format("大侠现在队伍拥有%s人，是否进入副本", szNum)
    end

    me.MsgBox(szMsg, tbBtn)
end

function WuLinDaShi:FindTeamer()
    local nForbidMap = Player:GetServerSyncData("ForbidTeamAllInfo") or 0
    if not TeamMgr:CanClientOperTeam(me.nMapTemplateId) or nForbidMap == me.nMapTemplateId then
        me.CenterMsg("当前地图不允许组队")
        return
    end

    if not TeamMgr:CanTeam(me.nMapTemplateId) then
        me.CenterMsg("当前地图不允许组队")
        return
    end

    RemoteServer.OnClientCallWuLinDaShiFunc("TrySetTarget")
end

function WuLinDaShi:NotifyTargetChanged()
    if Ui:WindowVisible("TeamPanel") == 1 then
        UiNotify.OnNotify(UiNotify.emNOTIFY_QUICK_TEAM_UPDATE, "TargetId")
    else
        Ui:OpenWindow("TeamPanel", "TeamActivity")
    end
end

WuLinDaShi.MAP_ID   = 6101
function WuLinDaShi:OnMapLoaded(nMapTID)
    if nMapTID ~= self.MAP_ID then
        Ui:CloseWindow("WuLinDaShiZhanBao")
        return
    end
    Ui:OpenWindow("WuLinDaShiZhanBao")
end

function WuLinDaShi:OnSyncSectionInfo(nSection, nSectionDay, nSectionMaxDay, tbSectionDay)
    self.nDataDay       = Lib:GetLocalDay(GetTime() - 4*3600)
    self.nSection       = nSection
    self.nSectionDay    = nSectionDay
    self.nSectionMaxDay = nSectionMaxDay
    self.tbSectionDay   = tbSectionDay
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_WULINDASHI_SECTION, nSection, nSectionDay, nSectionMaxDay, tbSectionDay)
end

function WuLinDaShi:GetSectionInfo()
    if self.nDataDay == Lib:GetLocalDay(GetTime() - 4*3600) then
        return self.nSection, self.nSectionDay, self.nSectionMaxDay, self.tbSectionDay
    end
    RemoteServer.OnClientCallWuLinDaShiFunc("RequestSectionInfo")
end

function WuLinDaShi:OnSyncActivityId(nActivityId)
    self.nActivityId = nActivityId
end

function WuLinDaShi:CheckCurActivityId()
    return self.nActivityId and self.nActivityId == TeamMgr:GetCurActivityId()
end

function WuLinDaShi:GetInstructions4TeamPanel()
    return "龙潭虎穴", "完颜洪烈性多疑，为防刺杀，偶尔不宿营帐，带亲信另觅隐秘之处扎营。此次获知其密营，我等必须一击即中，建此大功！"
end

function WuLinDaShi:GetCyclePercent()
    local nSection, nSectionDay, _, tbSectionDay = self:GetSectionInfo()
    if not nSection then
        return 0, 1
    end
    local nPassDay = 0
    local nAllDay = 0
    for i = 1, #tbSectionDay do
        if i < nSection then
            nPassDay = nPassDay + tbSectionDay[i]
        end
        nAllDay = nAllDay + tbSectionDay[i]
    end
    nPassDay = nPassDay + nSectionDay - 1
    return math.max(0, nPassDay/nAllDay), nPassDay + 1
end