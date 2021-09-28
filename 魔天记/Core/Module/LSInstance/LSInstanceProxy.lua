require "Core.Module.Pattern.Proxy"

LSInstanceProxy = Proxy:New();
function LSInstanceProxy:OnRegister()

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryStarTeamFB, LSInstanceProxy.TryStarTeamFBResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SetNpc, LSInstanceProxy.SetNpcResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AskForStarTeamFBAcc, LSInstanceProxy.AskForStarTeamFBAccResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TreamCancleToFb, LSInstanceProxy.TreamCancleToFbResult);

end

function LSInstanceProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryStarTeamFB, LSInstanceProxy.TryStarTeamFBResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SetNpc, LSInstanceProxy.SetNpcResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AskForStarTeamFBAcc, LSInstanceProxy.AskForStarTeamFBAccResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TreamCancleToFb, LSInstanceProxy.TreamCancleToFbResult);



end

function LSInstanceProxy.TryStarTeamFB(instId)

    local b = AppSplitDownProxy.Loaded();
    if not b then
        MsgUtils.ShowTips("LSInstanceProxy/Tip1");
        return;
    end

    PartData.ReSetAllAccept();

    SocketClientLua.Get_ins():SendMessage(CmdType.TryStarTeamFB, { instId = instId .. "" });
end

function LSInstanceProxy.SendSetNpc(id)


    SocketClientLua.Get_ins():SendMessage(CmdType.SetNpc, { npcId = tonumber(id) });
end

function LSInstanceProxy.SetNpcResult(cmd, data)

    if (data and data.errCode == nil) then
        --        local npc = ConfigManager.GetNpcById(data.npcId)
        --        if (npc) then
        --            local instId = ""
        --            local tempStr = string.split(npc.func, "#")
        --            if string.sub(tempStr[2], 1, 3) == "Nav" then
        --                local args = string.split(tempStr[2], "_");
        --                instId = args[2]
        --                local fbCf = InstanceDataManager.GetMapCfById(instId)
        --                GameSceneManager.GotoScene(fbCf.map_id);
        --            else
        --                log("npcfunc配置有误" .. data.npcId)
        --            end
        --        end
    end
end

function LSInstanceProxy.TryStarTeamFBResult(cmd, data)


    if (data.errCode == nil) then

        -- 如果 队伍只有 一个人， 而且 副本  min_num == 1 的时候， 那么就不需要 弹出窗口
        local f = data.f;
        -- f==1 是成功
        if f == 1 then
            local p_num = PartData.GetMyTeamNunberNum();
            if p_num > 1 then
                local res = { instId = data.instId, mc = data.mc };
                ModuleManager.SendNotification(LSInstanceNotes.OPEN_LSWAITFORJOINPANEL, res);
            end

        end

    end

end

function LSInstanceProxy.AskTeamToFbTip_OK()
    LSInstanceProxy.AskTeamToFbAcc(1);
end

function LSInstanceProxy.AskTeamToFbTip_Cancel()
    LSInstanceProxy.AskTeamToFbAcc(0);
end

function LSInstanceProxy.AskTeamToFbAcc(s)

    local team = PartData.GetMyTeam();


    SocketClientLua.Get_ins():SendMessage(CmdType.AskForStarTeamFBAcc, { tid = team.id, s = s });

end


function LSInstanceProxy.AskForStarTeamFBAccResult(cmd, data)


    if (data.errCode == nil) then


    end

end

LSInstanceProxy.MESSAGE_TREAMCANCLETOFB = "MESSAGE_TREAMCANCLETOFB";

function LSInstanceProxy.TreamCancleToFbResult(cmd, data)


    if (data.errCode == nil) then

        MsgUtils.ShowTips("LSInstanceProxy/Tip", { n = data.name });

        MessageManager.Dispatch(LSInstanceProxy, LSInstanceProxy.MESSAGE_TREAMCANCLETOFB);
    end

end


-------------------------------------------------------------------------------------------------------------------
