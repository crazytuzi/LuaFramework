require "Core.Module.Pattern.Proxy"

require "Core.Manager.Item.FriendDataManager"

FriendProxy = Proxy:New();
FriendProxy.MESSAGE_GENSHUI_MB_CHANGE = "MESSAGE_GENSHUI_MB_CHANGE";
FriendProxy.MESSAGE_NEAR_PLAYERS_CHANGE = "MESSAGE_NEAR_PLAYERS_CHANGE";
FriendProxy.MESSAGE_APPLYTEARMLIST_CHANGE = "MESSAGE_APPLYTEARMLIST_CHANGE";

FriendProxy.MESSAGE_NEED_SHOW_APPLYTEARMLIST_TIP = "MESSAGE_NEED_SHOW_APPLYTEARMLIST_TIP";

FriendProxy.MESSAGE_GETMYFRIENDSLIST_RESULT = "MESSAGE_GETMYFRIENDSLIST_RESULT";

function FriendProxy:OnRegister()

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.InvToGroudS, FriendProxy.InvToGroudSResult, self);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AddToParty, FriendProxy.AddToPartyResult, self);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AskForJointParty, FriendProxy.AskForJointPartyResult, self);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.LeaveTeam, FriendProxy.LeaveTeamResult, self);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UpToTeamLeader, FriendProxy.UpToTeamLeaderResult1, self);


    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ResultForTeamLeaderAsk, FriendProxy.ResultForTeamLeaderAskResult, self);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ResultForPlayerAsk, FriendProxy.ResultForPlayerAskResult, self);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.DismissTeam, FriendProxy.DismissTeamResult, self);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetTeamFBID, FriendProxy.GetTeamFBIDResult, self);

    ------
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RecLdAskGenShui, FriendProxy.RecLdAskGenShuiResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.LdRecAskGenShui, FriendProxy.LdRecAskGenShuiResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RecLdCancelGenShui, FriendProxy.RecLdCancelGenShuiResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TeamDataOnlineChange, FriendProxy.TeamDataOnlineChangeResult);


    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SendLaderGotoScene, FriendProxy.SendLaderGotoSceneResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RecOnlineTz, FriendProxy.RecOnlineTzResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetApplyTearmList, FriendProxy.GetApplyTearmListResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TreamNumberSceneChange, FriendProxy.TreamNumberSceneChangeResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetMyFriendsList, FriendProxy.GetMyFriendsList_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AskForJointPartyResult, FriendProxy.AskForJointPartyResultResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.PartSetCfData, FriendProxy.PartSetCfDataResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.PartCfData, FriendProxy.PartCfDataResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AccJoinTeam, FriendProxy.AccJoinTeamResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetOutFromTeam, FriendProxy.GetOutFromTeamResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.InviteToTeam, FriendProxy.InviteToTeamResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.CreateArmy, FriendProxy.CreateArmyResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.JoinTeamAsk, FriendProxy.JoinTeamAskResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.NearTeam, FriendProxy.NearTeamResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetPartyDress, FriendProxy.GetPartyDressResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetTeamFBData, FriendProxy.GetTeamFBDataResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RemoveFriend, FriendProxy.RemoveFriendResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SendPrivChatMessage, FriendProxy.SendChatMessageResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetPlayerInfo, FriendProxy.GetPlayerInfoResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.LdAskGenShui, FriendProxy.LdAskGenShuiResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AnswerLdAskGenShui, FriendProxy.AnswerLdAskGenShuiResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.LdCancelGenShui, FriendProxy.LdCancelGenShuiResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GenShuiMbChange, FriendProxy.GenShuiMbChangeResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetNearPlayers, FriendProxy.GetNearPlayersResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.CleanApplyTearmList, FriendProxy.CleanApplyTearmListResult);

    MessageManager.AddListener(GuildNotes, GuildNotes.ENV_GUILD_CHG, FriendProxy._OnGuildChg, self);

    FriendProxy.GetApplyTearmList();


end

function FriendProxy:OnRemove()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.InvToGroudS, FriendProxy.InvToGroudSResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AddToParty, FriendProxy.AddToPartyResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AskForJointParty, FriendProxy.AskForJointPartyResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.LeaveTeam, FriendProxy.LeaveTeamResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UpToTeamLeader, FriendProxy.UpToTeamLeaderResult1);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ResultForTeamLeaderAsk, FriendProxy.ResultForTeamLeaderAskResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ResultForPlayerAsk, FriendProxy.ResultForPlayerAskResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.DismissTeam, FriendProxy.DismissTeamResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetTeamFBID, FriendProxy.GetTeamFBIDResult);

    ------
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RecLdAskGenShui, FriendProxy.RecLdAskGenShuiResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.LdRecAskGenShui, FriendProxy.LdRecAskGenShuiResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RecLdCancelGenShui, FriendProxy.RecLdCancelGenShuiResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TeamDataOnlineChange, FriendProxy.TeamDataOnlineChangeResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SendLaderGotoScene, FriendProxy.SendLaderGotoSceneResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RecOnlineTz, FriendProxy.RecOnlineTzResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetApplyTearmList, FriendProxy.GetApplyTearmListResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetMyFriendsList, FriendProxy.GetMyFriendsList_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AskForJointPartyResult, FriendProxy.AskForJointPartyResultResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.PartSetCfData, FriendProxy.PartSetCfDataResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.PartCfData, FriendProxy.PartCfDataResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AccJoinTeam, FriendProxy.AccJoinTeamResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetOutFromTeam, FriendProxy.GetOutFromTeamResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.InviteToTeam, FriendProxy.InviteToTeamResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.CreateArmy, FriendProxy.CreateArmyResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.JoinTeamAsk, FriendProxy.JoinTeamAskResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.NearTeam, FriendProxy.NearTeamResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetPartyDress, FriendProxy.GetPartyDressResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetTeamFBData, FriendProxy.GetTeamFBDataResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RemoveFriend, FriendProxy.RemoveFriendResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SendPrivChatMessage, FriendProxy.SendChatMessageResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetPlayerInfo, FriendProxy.GetPlayerInfoResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.LdAskGenShui, FriendProxy.LdAskGenShuiResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AnswerLdAskGenShui, FriendProxy.AnswerLdAskGenShuiResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.LdCancelGenShui, FriendProxy.LdCancelGenShuiResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GenShuiMbChange, FriendProxy.GenShuiMbChangeResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetNearPlayers, FriendProxy.GetNearPlayersResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.CleanApplyTearmList, FriendProxy.CleanApplyTearmListResult);





    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TreamNumberSceneChange, FriendProxy.TreamNumberSceneChangeResult);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_GUILD_CHG, FriendProxy._OnGuildChg);
end

function FriendProxy:_OnGuildChg()


    FriendProxy.TryGetTeamFBData();

end

function FriendProxy.TryGetMyFriendList()


    SocketClientLua.Get_ins():SendMessage(CmdType.GetMyFriendsList, { });
end

function FriendProxy.GetMyFriendsList_Result(cmd, data)

    if data.errCode == nil then
        local l = data.l;

        FriendDataManager.Init(l);


        MessageManager.Dispatch(FriendProxy, FriendProxy.MESSAGE_GETMYFRIENDSLIST_RESULT, l);

    end
end

-----------------------------------------------------------------------------------------------------------------
function FriendProxy:GetTeamFBIDResult(cmd, data)

    PartyPanelControll.currTeamFBId = data.instId + 0;

end

function FriendProxy:ResultForPlayerAskResult(cmd, data)

    if data.s == 1 then

    else

        MsgUtils.ShowTips("friend/FriendProxy/tip1");
    end


end

--[[ 队长 解散
]]
function FriendProxy:DismissTeamResult(cmd, data)

    if (data.errCode == nil) then
        PartData.SetMyTeam(nil);

        MsgUtils.ShowTips("friend/FriendProxy/tip2");

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end

function FriendProxy:ResultForTeamLeaderAskResult(cmd, data)

    if data.s == 1 then

    else
        if data.n == nil then
            data.n = data.name;
        end
        MsgUtils.ShowTips("friend/FriendProxy/tip0", { n = data.n });
    end

end

function FriendProxy:UpToTeamLeaderResult1(cmd, data)

    if (data.errCode == nil) then

        if data.pid == nil then
            data.pid = data.id;
        end

        PartData.SetNew_TeamLeader_name(data.pid, data.n);

        MsgUtils.ShowTips("friend/FriendProxy/tip3", { n = data.n });

        -- 如果 自己是队长，
        local isld = PartData.MeIsTeamLeader();
        if isld then
            FriendProxy.LdCancelGenShui()
        end


    end

end

function FriendProxy:LeaveTeamResult(cmd, data)

    if (data.errCode == nil) then

        PartData.MenberLeaveTeam(data.id)

        if data.s == 0 then
            -- 自己离开
            -- PartData.SetMyTeam(nil);  这里如果添加的话， 在  队长 退出 队伍的时候， 那么 自己会 把所有的成员都 隐藏了
            MsgUtils.ShowTips(nil, nil, nil, data.n .. LanguageMgr.Get("friend/FriendProxy/tip4"));
        else
            -- 被踢
            local myHero = HeroController.GetInstance();
            local mydata = myHero.info;

            if mydata.id == data.id then
                MsgUtils.ShowTips("friend/FriendProxy/tip5");
                PartData.SetMyTeam(nil);
            else
                MsgUtils.ShowTips("friend/FriendProxy/tip6", { n = data.n });
            end

        end


    end

end

function FriendProxy:AskForJointPartyResult(cmd, data)

    MessageManager.Dispatch(FriendNotes, FriendNotes.MESSAGE_ASKFORJOINTPARTYRESULT, data);


    FriendProxy.GetApplyTearmList();

end

function FriendProxy:AddToPartyResult(cmd, data)

    PartData.AddMenber(data);
end

function FriendProxy:InvToGroudSResult(cmd, data)


    MessageManager.Dispatch(FriendNotes, FriendNotes.MESSAGE_INVTOGROUDSRESULT, data);


end


----------------------------------------------------------------------------------------------------------------------
function FriendProxy.AskFroAessJointPartyDeal(s, p_id)


    SocketClientLua.Get_ins():SendMessage(CmdType.AskForJointPartyResult, { s = s, pid = p_id });

end

function FriendProxy.AskForJointPartyResultResult(cmd, data)


    if (data.errCode == nil) then

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
        FriendProxy.GetApplyTearmList();

    end

end


function FriendProxy.TryPartSetCfData(t, s)

    SocketClientLua.Get_ins():SendMessage(CmdType.PartSetCfData, { t = t, s = s });

end

function FriendProxy.TryGetTeamFBID()
    SocketClientLua.Get_ins():SendMessage(CmdType.GetTeamFBID, { });
end

function FriendProxy.PartSetCfDataResult(cmd, data)



    if (data.errCode == nil) then

        MessageManager.Dispatch(FriendNotes, FriendNotes.MESSAGE_PARTSETCFDATARESULT, data);

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end


function FriendProxy.TryPartCfData()

    SocketClientLua.Get_ins():SendMessage(CmdType.PartCfData, { });
end


--[[10 获取自动接受邀请/自动接受入队伍参数
输入：

输出：
inv：自动接受组队邀请（0:关闭1:开启）
acc：自动接受入队申请（0:关闭1:开启）
0x0B10
]]
function FriendProxy.PartCfDataResult(cmd, data)



    if (data.errCode == nil) then

        MessageManager.Dispatch(FriendNotes, FriendNotes.MESSAGE_PARTCFDATARESULT, data);

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end


function FriendProxy.TryAccJoinTeam(s, g_id, invId)

    SocketClientLua.Get_ins():SendMessage(CmdType.AccJoinTeam, { s = s, id = g_id, invId = invId });

end

function FriendProxy.AccJoinTeamResult(cmd, data)


    if (data.errCode == nil) then

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end
end


function FriendProxy.TryUpToTeamLeader(pid)

    SocketClientLua.Get_ins():SendMessage(CmdType.UpToTeamLeader, { pid = pid .. "" });

end

--[[function FriendProxy.UpToTeamLeaderResult(cmd, data)

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UpToTeamLeader, FriendProxy.UpToTeamLeaderResult);

    if (data.errCode == nil) then
        PartData.SetNew_TeamLeader_name(data.pid, data.n)
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end
]]
function FriendProxy.TryGetOutFromTeam(pid)


    SocketClientLua.Get_ins():SendMessage(CmdType.GetOutFromTeam, { pid = pid .. "" });
end

function FriendProxy.GetOutFromTeamResult(cmd, data)


    if (data.errCode == nil) then

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end


function FriendProxy.TryInviteToTeam(id, name)

    SocketClientLua.Get_ins():SendMessage(CmdType.InviteToTeam, { id = id .. "" });

    --[[
    local mt = PartData.GetMyTeam();
    if mt == nil then
        SocketClientLua.Get_ins():SendMessage(CmdType.InviteToTeam, { id = id .. "" });
        return;
    end


    if name == nil then
        name = "";
    end

    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
        title = LanguageMgr.Get("common/notice"),
        msg = LanguageMgr.Get("TryInviteToTeam/Tip",{ n = name }),
        ok_Label = LanguageMgr.Get("common/ok"),
        cance_lLabel = LanguageMgr.Get("common/cancle"),
        hander = function()
            SocketClientLua.Get_ins():SendMessage(CmdType.InviteToTeam, { id = id .. "" });
        end,
        target = nil,
        data = nil
    } );
    ]]

end


function FriendProxy.TryJoinTeamAsk(id, name)

    local mt = PartData.GetMyTeam();
    if mt == nil then
        SocketClientLua.Get_ins():SendMessage(CmdType.JoinTeamAsk, { id = id });
        return;
    end

    if name == nil then
        name = "";
    end

    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
        title = LanguageMgr.Get("common/notice"),
        msg = LanguageMgr.Get("TryInviteToTeam/Tip",{ n = name }),
        ok_Label = LanguageMgr.Get("common/ok"),
        cance_lLabel = LanguageMgr.Get("common/cancle"),
        hander = function()
            SocketClientLua.Get_ins():SendMessage(CmdType.JoinTeamAsk, { id = id });
        end,
        target = nil,
        data = nil
    } );



end



function FriendProxy.InviteToTeamResult(cmd, data)


    if (data.errCode == nil) then

        MsgUtils.ShowTips("friend/FriendProxy/tip7");
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end

-- {fun,fun_target,data}
function FriendProxy.TryCreateArmy(param)
    FriendProxy.TryCreateArmyHandlerData = param;

    SocketClientLua.Get_ins():SendMessage(CmdType.CreateArmy, { });

end

function FriendProxy.CreateArmyResult(cmd, data)


    if (data.errCode == nil) then
        MsgUtils.ShowTips("friend/FriendProxy/tip8");

        if FriendProxy.TryCreateArmyHandlerData ~= nil then
            local fun = FriendProxy.TryCreateArmyHandlerData.fun;
            local fun_target = FriendProxy.TryCreateArmyHandlerData.fun_target;
            local data = FriendProxy.TryCreateArmyHandlerData.data;

            fun(fun_target, data);
        end

    end

end




function FriendProxy.JoinTeamAskResult(cmd, data)


    if (data.errCode == nil) then

        MsgUtils.ShowTips("friend/FriendProxy/tip9");
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end


function FriendProxy.TryGetNearTeam()

    SocketClientLua.Get_ins():SendMessage(CmdType.NearTeam, { });
end

--  S <-- 11:16:35.757, 0x0B0C, 13, {"ts":[{"f":1128,"num":1,"k":101000,"id":1,"l":1,"n":"姜小浩"}]}
function FriendProxy.NearTeamResult(cmd, data)


    if (data.errCode == nil) then

        MessageManager.Dispatch(FriendNotes, FriendNotes.MESSAGE_NEARTEAMRESULT, data);

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end

FriendProxy.getIngPartDress = false;

function FriendProxy.GetPartyDress()

    if FriendProxy.GetPartyDressHasSend then

    else

        SocketClientLua.Get_ins():SendMessage(CmdType.GetPartyDress, { });
        FriendProxy.GetPartyDressHasSend = true;

    end

end



function FriendProxy.GetPartyDressResult(cmd, data)


    if (data.errCode == nil) then
        FriendProxy._PartyDressData = data;
        MessageManager.Dispatch(FriendNotes, FriendNotes.MESSAGE_GETPARTYDRESSRESULT, data);

    else
        --[[        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
        ]]
    end

    FriendProxy.GetPartyDressHasSend = false;
end

-- 登录后调用， 获取队伍信息
function FriendProxy.TryGetTeamFBData()

    -- log("---------------------FriendProxy.TryGetTeamFBData-------------------------------");
    SocketClientLua.Get_ins():SendMessage(CmdType.GetTeamFBData, { });
end


--[[ S <-- 20:34:41.648, 0x0B17, 9, {"m":[{"n":"\u9F9A\u73EE","pid":"20100368","k":103000,"hp":3211,"p":0,"mp":3583,"l":41,"f":26393},{"n":"\u8D56\u9704\u5DDD","pid":"20100796","k":101000,"hp":5490,"p":1,"mp":4079,"l":47,"f":47036}],"id":1}
]]
function FriendProxy.GetTeamFBDataResult(cmd, data)


    if (data.errCode == nil) then

        PartData.SetMyTeam(data);

    end


end


function FriendProxy.TryRemoveFriend(tid, name)
    FriendProxy.removeF_name = name;

    -- log("TryRemoveFriend "..tid.."  name "..name);
    SocketClientLua.Get_ins():SendMessage(CmdType.RemoveFriend, { tid = tid });
end

function FriendProxy.RemoveFriendResult(cmd, data)


    if (data.errCode == nil) then
        FriendDataManager.currSelectTarget = nil;
        FriendDataManager.RemoveFriend(data.tid);

        MsgUtils.ShowTips("friend/FriendProxy/tip10", { n = FriendProxy.removeF_name });

        FriendProxy.TryGetMyFriendList()
    end

end


function FriendProxy.TrySendMsg(r_id, msg)

    FriendProxy.curr_msg = { r_id = r_id, msg = msg }


    SocketClientLua.Get_ins():SendMessage(CmdType.SendPrivChatMessage, { t = FriendDataManager.chat_data_type_txt, r_id = r_id, msg = msg });


end

function FriendProxy.SendChatMessageResult(cmd, data)


    if (data.errCode == nil) then

        local myHero = HeroController.GetInstance();
        local mydata = myHero.info;
        local my_id = "" .. mydata.id;
        local my_name = mydata.name;
        local my_kind = mydata.kind .. "";

        local time = data.time;

        local charData = { msg = FriendProxy.curr_msg.msg, s_id = my_id, k = my_kind, c = FriendDataManager.chat_channel_self, t = FriendDataManager.chat_data_type_txt, s_name = my_name };
        charData.time = time;


        FriendDataManager.AddChatMsg(FriendProxy.curr_msg.r_id, charData, false, false);

        MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_SEND_CHAT_MSG_COMPLETE, FriendProxy.curr_msg);

    end

end

function FriendProxy.TryGetPlayerInfo(list)

    if not FriendProxy.getPlayerInfoint then
        FriendProxy.getPlayerInfoint = true;

        SocketClientLua.Get_ins():SendMessage(CmdType.GetPlayerInfo, { l = list });
    end

end

--   S <-- 11:09:19.328, 0x1206, 15, {"l":[{"level":1,"kind":101000,"sex":0,"name":"airter1","id":"20102698","type":3,"fight":30351}]}
function FriendProxy.GetPlayerInfoResult(cmd, data)

    FriendProxy.getPlayerInfoint = false;


    if (data.errCode == nil) then
        FriendDataManager.SetStrangerList(data.l)
    end

end

--[[19 队员下线上线状态改变通知（服务端发出）
输出：
pid：玩家id
s:0:正常1:死亡,2:距离太远,3:离线
0x0B19

]]
function FriendProxy.TeamDataOnlineChangeResult(cmd, data)
    if (data.errCode == nil) then

        local t_pid = data.pid + 0;
        PartData.UpMenberS(t_pid, data.s)
    end

end


--------------------------------------------------------- 队友跟随 -------------------------------------------------------------------------------------
--[[15 队员收到队长邀请跟随（服务端发出）
输出：
id：玩家id
n:玩家呢称

]]
function FriendProxy.RecLdAskGenShuiResult(cmd, data)

    if (data.errCode == nil) then

        -- 如果 已经在跟随状态， 那么就不需要重新答应了
        local heroIns = HeroController:GetInstance();
        -- IsFollowAiCtr
        local isf = heroIns:IsFollowAiCtr();
        if not isf then

            if AutoFightManager.autoGensui then
                -- 自动 答应
                FriendProxy.AnswerLdAskGenShui(1, 1)
            else
                -- 需要 弹出 对话框
                ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM6PANEL, data);
            end

        end



    end

end

--[[17 队长收到队员是否跟随（服务端发出）
输出：
id：玩家id
t:是否跟随0：不跟随 1：跟随
f：是否收到队长邀请：1：收到队长邀请加入 0：主动跟随没有收到队长邀请


]]
function FriendProxy.LdRecAskGenShuiResult(cmd, data)

    if (data.errCode == nil) then

        local f = data.f;

        if f == 1 then

            local t = data.t;
            if t == 0 then

                local id = data.id;
                local md = PartData.FindMyTeammateData(id);
                local name = "";
                if md ~= nil then
                    name = md.n;
                end
                --  ["friend/FriendProxy/tip11"] = "{n}拒绝了你的召唤";
                MsgUtils.ShowTips("friend/FriendProxy/tip11", { n = name });
            end
        end

        FriendProxy.SetcurrList(data.id, data.t)


        --
    end
end

function FriendProxy.SetcurrList(id, t)
    local id = id + 0;
    local hasSet = false;
    local t_num = table.getn(FriendProxy.currList);
    for i = 1, t_num do
        local pid = FriendProxy.currList[i].pid + 0;
        if id == pid then
            FriendProxy.currList[i].t = t;
            hasSet = true;
        end
    end

    if not hasSet then
        FriendProxy.currList[t_num + 1] = { pid = id .. "", t = t };
    end

    FriendProxy.DisGenSuiList(FriendProxy.currList)
end

--[[19 队员收到队长取消跟随消息（服务端发出）
输出：

]]
function FriendProxy.RecLdCancelGenShuiResult(cmd, data)

    if (data.errCode == nil) then
        HeroController:GetInstance():StopFollow();

        FriendProxy.GenShuiMbChange()

    end
end

--[[14 队长邀请队员跟随
输入：
输出：
id：玩家id

]]
function FriendProxy.LdAskGenShui()


    SocketClientLua.Get_ins():SendMessage(CmdType.LdAskGenShui, { });
end

function FriendProxy.LdAskGenShuiResult(cmd, data)


    if (data.errCode == nil) then


    end
end

--[[16 队员是否跟随通知
输入：
f：是否收到队长邀请：1：收到队长邀请加入 0：主动跟随没有收到队长邀请
t:是否跟随0：不跟随 1：跟随
输出：
t:是否跟随0：不跟随 1：跟随


]]
function FriendProxy.AnswerLdAskGenShui(t, f)

    SocketClientLua.Get_ins():SendMessage(CmdType.AnswerLdAskGenShui, { t = t, f = f });
end

function FriendProxy.AnswerLdAskGenShuiResult(cmd, data)


    if (data.errCode == nil) then

        local t = data.t;
        local f = data.f;

        if f == 1 then
            if t == 1 then

                -- 马上进入跟随模式
                local mt = PartData.GetMyTeam();

                if mt ~= nil then
                    local ld = PartData.FindTeamLeader();
                    if ld ~= nil then
                        HeroController:GetInstance():StartFollow(ld.pid, HeroController.FOLLOWTYPE_FOR_TEAM);
                    end
                else
                    MsgUtils.ShowTips("friend/FriendProxy/tip12");
                end

            end



        end


        local me = HeroController:GetInstance();
        local heroInfo = me.info;
        local my_id = heroInfo.id;
        FriendProxy.SetcurrList(my_id, t)

    end
end

------------------------------------------------  LdCancelGenShui  --------------------------------------------------
function FriendProxy.LdCancelGenShui()


    SocketClientLua.Get_ins():SendMessage(CmdType.LdCancelGenShui, { });

end

function FriendProxy.LdCancelGenShuiResult(cmd, data)


    if (data.errCode == nil) then
        FriendProxy.DisGenSuiList( { })
    end
end



FriendProxy.getGenShuiMbChange = false;

--[[ 1A 获取队伍成员跟随状态
输入：
输出：
l:{[pid:玩家Id，t:跟随状态 0：不跟随 1：跟随]}

]]
function FriendProxy.GenShuiMbChange()

    if FriendProxy.getGenShuiMbChange then
        return;
    end

    FriendProxy.getGenShuiMbChange = true;

    SocketClientLua.Get_ins():SendMessage(CmdType.GenShuiMbChange, { });

end




--  S <-- 11:55:12.425, 0x031A, 17, {"l":[{"pid":"20100796","t":0},{"pid":"20100832","t":1}]}
function FriendProxy.GenShuiMbChangeResult(cmd, data)


    if (data.errCode == nil) then
        FriendProxy.DisGenSuiList(data.l);
    end

    FriendProxy.getGenShuiMbChange = false;

end





FriendProxy.currList = { };
function FriendProxy.DisGenSuiList(list)
    FriendProxy.currList = list;
    MessageManager.Dispatch(FriendProxy, FriendProxy.MESSAGE_GENSHUI_MB_CHANGE, list);
end



--------------------------------------------------------------------------------------------------------------------------------
--[[获取 当前 视野中的附近人
]]
function FriendProxy.GetNearPlayers()

    SocketClientLua.Get_ins():SendMessage(CmdType.GetNearPlayers, { });

end

function FriendProxy.GetNearPlayersResult(cmd, data)


    if (data.errCode == nil) then


        MessageManager.Dispatch(FriendProxy, FriendProxy.MESSAGE_NEAR_PLAYERS_CHANGE, data.l);

    end
end

---------------------------------------------------
function FriendProxy.SendLaderGotoScene(id, x, y, z)

    id = id .. "";
    SocketClientLua.Get_ins():SendMessage(CmdType.SendLaderGotoScene, { id = id, x = x, y = y, z = z });

end


-- RecOnlineTzResult
--[[08 通知好友上线，下线（服务端发出）
输出：
id：玩家ID
name:玩家昵称
ft:1:好友 2：仇人
t:（0:下线，1:上线）

]]
function FriendProxy.RecOnlineTzResult(cmd, data)

    if data.errCode == nil then
        local ft = data.ft;
        local name = data.name;
        local t = data.t;

        if ft == 1 then

            if t == 1 then
                MsgUtils.ShowTips("friend/FriendProxy/tip101", { n = name });
            elseif t == 0 then
                MsgUtils.ShowTips("friend/FriendProxy/tip102", { n = name });
            end

        elseif ft == 2 then

            if t == 1 then
                MsgUtils.ShowTips("friend/FriendProxy/tip103", { n = name });
            elseif t == 0 then
                MsgUtils.ShowTips("friend/FriendProxy/tip104", { n = name });
            end

        end

    end

end

--[[ S <-- 11:59:58.609, 0x0B1A, 27, {"z":0,"y":0,"x":0,"id":"709999"}
]]
function FriendProxy.SendLaderGotoSceneResult(cmd, data)

    if (data.errCode == nil) then

        local teamNum = PartData.GetMyTeamNunberNum();
        if teamNum > 1 then
            local meIsLd = PartData.MeIsTeamLeader();
            if not meIsLd then

                -- 自己是否在跟随状态
                local isflo = HeroController:GetInstance():IsFollowAiCtr();

                if isflo then

                    local mapId = data.id;
                    local mapCf = ConfigManager.GetMapById(mapId);

                    if mapCf.type == InstanceDataManager.MapType.Field or
                        mapCf.type == InstanceDataManager.MapType.Main or
                        mapCf.type == InstanceDataManager.MapType.Guild then
                        local toScene
                        if data.x == 0 and data.y == 0 and data.z == 0 then

                        else
                            toScene = { };
                            toScene.sid = data.id;
                            toScene.fid = 0;
                            toScene.position = Vector3.New(data.x, data.y, data.z);
                            -- GameSceneManager.to = toScene;
                        end



                        -- 在跳场景之前必须停止当前 动作
                        HeroController:GetInstance():StopActBeforGoToScene();

                        GameSceneManager.GotoScene(data.id, nil, toScene);
                        GameSceneManager.gotoSceneForFollow = true;


                    end



                end

            end
        end


    end
end


------------------------------------------------------------------------------------------------------------
function FriendProxy.GetApplyTearmList()

    local b = PartData.MeIsTeamLeader();
    if b then

        SocketClientLua.Get_ins():SendMessage(CmdType.GetApplyTearmList, { });
    end

end

--[[22 队员跳转场景信息广播（服务器发出）¶
输出：
pid:玩家id
id：场景ID
x：x
y:y
z:z

]]
function FriendProxy.TreamNumberSceneChangeResult(cmd, data)

    if (data.errCode == nil) then
        PartData.SetNumberInScene(data.pid, data.id);

    end
end

--[[1C 获取玩家申请列表
输出：
l:[{pid:玩家id，n:玩家昵称,k：玩家kind,l:等级,f:战斗力},..]

]]
function FriendProxy.GetApplyTearmListResult(cmd, data)



    if (data.errCode == nil) then

        FriendProxy.Set_applyTearmList(data.l)

    end
end


function FriendProxy.Set_applyTearmList(list)
    PartData.applyTearmList = list;

    MessageManager.Dispatch(FriendProxy, FriendProxy.MESSAGE_APPLYTEARMLIST_CHANGE, PartData.applyTearmList);
    MessageManager.Dispatch(FriendProxy, FriendProxy.MESSAGE_NEED_SHOW_APPLYTEARMLIST_TIP);
end

------------------------------------------------------------------------------------------------------------
function FriendProxy.CleanApplyTearmList()



    SocketClientLua.Get_ins():SendMessage(CmdType.CleanApplyTearmList, { });

end

--[[1C 获取玩家申请列表
输出：
l:[{pid:玩家id，n:玩家昵称,k：玩家kind,l:等级,f:战斗力},..]

]]
function FriendProxy.CleanApplyTearmListResult(cmd, data)


    if (data.errCode == nil) then

        FriendProxy.Set_applyTearmList( { })


    end
end
