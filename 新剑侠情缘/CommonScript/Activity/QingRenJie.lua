if not MODULE_GAMESERVER then
    Activity.QingRenJie = Activity.QingRenJie or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("QingRenJie") or Activity.QingRenJie
tbAct.DAZUO_SEC = 60         --交互时间
tbAct.EXP_TIMES = 10         --加经验的次数   
tbAct.MAP_TID = 1600         --船的地图ID

if MODULE_GAMESERVER then
    return
end

function tbAct:OnGetInvite(nInviteId, szName)
    local fnAgree = function ()
        if not TeamMgr:HasTeam() then
            me.CenterMsg("没有队伍")
            return
        end

        local tbMember = TeamMgr:GetTeamMember()
        if #tbMember ~= 1 then
            me.CenterMsg("只能两个人队伍")
            return
        end

        if tbMember[1].nPlayerID ~= nInviteId then
            me.CenterMsg("邀请已过期")
            return
        end
        RemoteServer.QingRenJieRespon("Act_QingRenJie_AgreeInvite", nInviteId, true)
    end

    local fnDisagree = function ()
        RemoteServer.QingRenJieRespon("Act_QingRenJie_AgreeInvite", nInviteId)
    end

    local fnClose = function ()
        Ui:CloseWindow("MessageBox")
    end

    local szMsg = string.format("%s邀请你一同前往小楼听雨舫, 是否愿意？\n(%%d秒后自动关闭)", szName)
    me.MsgBox(szMsg, {{"同意", fnAgree}, {"拒绝", fnDisagree}}, nil, 20, fnClose)
end

function tbAct:OnGetDazuoInvite(nInviteId, szName)
    local fnAgree = function ()
        if not TeamMgr:HasTeam() then
            me.CenterMsg("当前没有队伍")
            return
        end

        local tbMember = TeamMgr:GetTeamMember()
        if #tbMember ~= 1 then
            me.CenterMsg("队伍中有且仅能有两个人")
            return
        end

        if tbMember[1].nPlayerID ~= nInviteId then
            me.CenterMsg("邀请已过期")
            return
        end

        RemoteServer.QingRenJieRespon("Act_QingRenJie_AgreeInviteDazuo", nInviteId, true)
    end

    local fnDisagree = function ()
        RemoteServer.QingRenJieRespon("Act_QingRenJie_AgreeInviteDazuo", nInviteId)
    end

    local fnClose = function ()
        Ui:CloseWindow("MessageBox")
    end

    local szMsg = string.format("%s邀请你共赏玫瑰烟火, 是否愿意与他并肩席坐，同赏美景？\n(%%d秒后自动关闭)", szName)
    me.MsgBox(szMsg, {{"同意", fnAgree}, {"拒绝", fnDisagree}}, nil, 20, fnClose)
end

function tbAct:OnBeginDazuo()
    Ui:OpenWindow("ChuangGongPanel", nil, nil, nil, nil, nil, true)
    Ui:OpenWindow("QingRenJieDazuoPanel")
    Ui:CloseWindow("QingRenJieInvitePanel")
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHUAN_GONG_SEND_ONE, 0)
end

function tbAct:ContinueDazuo(nLastTime)
    if nLastTime%(self.DAZUO_SEC/self.EXP_TIMES) == 0 then
        local nPercent = (self.DAZUO_SEC-nLastTime)/self.DAZUO_SEC
        UiNotify.OnNotify(UiNotify.emNOTIFY_CHUAN_GONG_SEND_ONE, nPercent)
    end

    if nLastTime%12 == 0 then
        UiNotify.OnNotify(UiNotify.emNOTIFY_QINGRENJIE_TEXIAO)
    end
end

function tbAct:OnDazuoEnd(bOpenInvitePanel)
    Ui:CloseWindow("ChuangGongPanel")
    Ui:CloseWindow("QingRenJieDazuoPanel")
    Ui:OpenWindow("QingRenJieInvitePanel")
    if bOpenInvitePanel then
        Ui:OpenWindow("QingRenJieTitlePanel")
    end
end

function tbAct:OnSetApplyPlayer(nApplyPlayer)
    self.nApplyPlayer = nApplyPlayer
end