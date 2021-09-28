require "Core.Module.Pattern.Proxy"

XMBossProxy = Proxy:New();

XMBossProxy.MESSAGE_GETXMBOSSMAININFOS = "MESSAGE_GETXMBOSSMAININFOS";
XMBossProxy.MESSAGE_XMBOSS_GETXMBOSSRANK = "MESSAGE_XMBOSS_GETXMBOSSRANK";
XMBossProxy.MESSAGE_XMBOSS_GETXMBOSSJOININFOS = "MESSAGE_XMBOSS_GETXMBOSSJOININFOS";
XMBossProxy.MESSAGE_XMBOSS_GETFB_ELSETIME = "MESSAGE_XMBOSS_GETFB_ELSETIME";

XMBossProxy.MESSAGE_XMBOSS_HP_CHANGE = "MESSAGE_XMBOSS_HP_CHANGE";
XMBossProxy.MESSAGE_XMBOSS_MAO_JOININFO = "MESSAGE_XMBOSS_MAO_JOININFO";

XMBossProxy.MESSAGE_XMBOSS_BOX_CHANGE = "MESSAGE_XMBOSS_BOX_CHANGE";

XMBossProxy.MESSAGE_XMBOSS_GET_FULI_COMPLETE = "MESSAGE_XMBOSS_GET_FULI_COMPLETE";

XMBossProxy.MESSAGE_XMBOSS_FENPEI_COMPLETE = "MESSAGE_XMBOSS_FENPEI_COMPLETE";

XMBossProxy.MESSAGE_XMBOSS_GETJOINNUM_COMPLETE = "MESSAGE_XMBOSS_GETJOINNUM_COMPLETE";

XMBossProxy.MESSAGE_XMBOSS_ZHAOHUAN_SUCCESS = "MESSAGE_XMBOSS_ZHAOHUAN_SUCCESS";

function XMBossProxy:OnRegister()

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.MXBossPhChange, XMBossProxy.MXBossPhChangeResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XMBossBoxChange, XMBossProxy.XMBossBoxChangeResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXMBossFBFenPeiBox, XMBossProxy.GetXMBossFBFenPeiBoxResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XMBossFenPeiPro, XMBossProxy.XMBossFenPeiProResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXMBossFBJoinNum, XMBossProxy.GetXMBossFBJoinNumResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXMBossFBFuLiInfo, XMBossProxy.GetXMBossFBFuLiInfoResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetXMBossBox, XMBossProxy.TryGetXMBossBoxResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetXMBossMapInfo, XMBossProxy.TryGetXMBossMapInfoResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryMXBossZaoHuang, XMBossProxy.TryMXBossZaoHuangResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetFB_ElseTime, XMBossProxy.TryGetXMBossFB_ElseTimeResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXMBossMainInfos, XMBossProxy.GetXMBossMainInfosResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXMBossRank, XMBossProxy.GetXMBossRankResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXMBossJoinInfos, XMBossProxy.GetXMBossJoinInfosResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXMBossFBResult, XMBossProxy.GetXMBossFBResultResult);



    -- XMBossBoxChange
end

function XMBossProxy:OnRemove()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.MXBossPhChange, XMBossProxy.MXBossPhChangeResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XMBossBoxChange, XMBossProxy.XMBossBoxChangeResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXMBossFBJoinNum, XMBossProxy.GetXMBossFBJoinNumResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXMBossFBFenPeiBox, XMBossProxy.GetXMBossFBFenPeiBoxResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XMBossFenPeiPro, XMBossProxy.XMBossFenPeiProResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXMBossFBFuLiInfo, XMBossProxy.GetXMBossFBFuLiInfoResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetXMBossBox, XMBossProxy.TryGetXMBossBoxResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetXMBossMapInfo, XMBossProxy.TryGetXMBossMapInfoResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryMXBossZaoHuang, XMBossProxy.TryMXBossZaoHuangResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXMBossMainInfos, XMBossProxy.GetXMBossMainInfosResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXMBossRank, XMBossProxy.GetXMBossRankResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXMBossJoinInfos, XMBossProxy.GetXMBossJoinInfosResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXMBossFBResult, XMBossProxy.GetXMBossFBResultResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetFB_ElseTime, XMBossProxy.TryGetXMBossFB_ElseTimeResult);


end

--------------------------------------------- GetXMBossFBJoinNum  ---------------------------------------------------------------
function XMBossProxy.GetXMBossFBJoinNum()


    SocketClientLua.Get_ins():SendMessage(CmdType.GetXMBossFBJoinNum, { });
end

--[[
0D 获取活动人数
输出：
n:参加活动人数

]]
function XMBossProxy.GetXMBossFBJoinNumResult(cmd, data)


    if (data.errCode == nil) then
        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETJOINNUM_COMPLETE, data);

    end
end


------------------------------------------- GetXMBossFBFenPeiBox -------------------------------------------------------
function XMBossProxy.GetXMBossFBFenPeiBox()


    SocketClientLua.Get_ins():SendMessage(CmdType.GetXMBossFBFenPeiBox, { pid = pid, sl = sl, n1 = n1 });
end


function XMBossProxy.GetXMBossFBFenPeiBoxResult(cmd, data)


    if (data.errCode == nil) then

        MsgUtils.ShowTips("XMBoss/XMBossProxy/label1");


        GuildDataManager.awardMyNum = 0;
        MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_UPDATE_REDPOINT, nil);
        MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_AWARD_INFO, nil);
    end
end




------------------- XMBossFenPeiPro 

function XMBossProxy.XMBossFenPeiPro(pid, sl, n1)


    SocketClientLua.Get_ins():SendMessage(CmdType.XMBossFenPeiPro, { pid = pid, sl = sl, nl = n1 });
end


--[[
 S <-- 20:03:19.029, 0x1609, 21, {"pid":"20100452","l":[{"num":4,"spId":501201}],"pl":[]}
]]
function XMBossProxy.XMBossFenPeiProResult(cmd, data)


    if (data.errCode == nil) then

        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_FENPEI_COMPLETE, data);


        local l = data.l;
        local t_num = 0;

        for key, value in pairs(l) do
            if value.num > 0 then
                t_num = t_num + 1;
            end
        end


        GuildDataManager.awardFpNum = t_num;

        -- MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_UPDATE_REDPOINT, nil);
        --    MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_AWARD_INFO, nil);
        MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_UPDATE_AWARD_REDPOINT, nil);
    end
end


----------------------------------------------------------------------------------------------------------------------------------------------

function XMBossProxy.GetXMBossFBFuLiInfo()


    SocketClientLua.Get_ins():SendMessage(CmdType.GetXMBossFBFuLiInfo, { });
end

--[[
0B 获取仙盟仓库信息
输入：
输出：
l1：太清门伤害列表[id：玩家排名,n:玩家呢称，s:伤害比例,r:[spId:道具id，num:数量 ] ]
l2：魔玄宗伤害列表[id：玩家排名,n:玩家呢称，s:伤害比例,r:[spId:道具id，num:数量] ]
l3：天工宗治疗列表[id：玩家排名,n:玩家呢称，s:治疗比例,r:[spId:道具id，num:数量] ]
l4：天妖谷承受伤害列表[id：玩家排名,n:玩家呢称，s:承受伤比例,r:[spId:道具id，num:数量] ]
l:{[spId：道具ID，num：数量]...} 仓库物品

]]

function XMBossProxy.GetXMBossFBFuLiInfoResult(cmd, data)


    if (data.errCode == nil) then
        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GET_FULI_COMPLETE, data);

    end
end


---------------------------------------------------------------------------------------------------------------

function XMBossProxy.TryGetXMBossBox(idx)


    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetXMBossBox, { idx = idx });
end

--[[
07 领取宝箱
输入：
idx：下标（1到3）
输出：
i:{["spId":道具ID,"num":数量]}


]]

function XMBossProxy.TryGetXMBossBoxResult(cmd, data)


    if (data.errCode == nil) then
        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_BOX_CHANGE, { idx = data.idx, s = data.s });

    end
end

function XMBossProxy.XMBossBoxChangeResult(cmd, data)
    if (data.errCode == nil) then
        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_BOX_CHANGE, { idx = data.idx, s = data.s });

    end
end



----------------------------------------------------------------------------------------------
function XMBossProxy.TryGetXMBossMapInfo()



    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetXMBossMapInfo, { });
end

--[[
06 进入副本获取boss信息，宝箱信息
输入：
输出：
mid：怪物defId
hp：当前血量
mhp：最大血量
lv：当前等级
chest：{[idx:下标，s:状态（0：没有获得，1：获得，2：领取）]}

]]

function XMBossProxy.TryGetXMBossMapInfoResult(cmd, data)


    if (data.errCode == nil) then
        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_MAO_JOININFO, data);
    end
end


-----------------------------------------------------------------------------------


--[[
05 活动boss血量改变（服务器发出）
输出：
mid：怪物defId
hp：当前血量
mhp：最大血量

]]
function XMBossProxy.MXBossPhChangeResult(cmd, data)

    if (data.errCode == nil) then
        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_HP_CHANGE, data);

    end
end

----------------------------------------------------------------------------------------------

function XMBossProxy.TryMXBossZaoHuang()



    SocketClientLua.Get_ins():SendMessage(CmdType.TryMXBossZaoHuang, { });
end

--[[
04 召唤副本活动
输入：
输出：
f:召唤成功标示（0：成功，-1失败）

]]

function XMBossProxy.TryMXBossZaoHuangResult(cmd, data)


    if (data.errCode == nil) then

        local f = data.f;
        if f == 0 then
            MsgUtils.ShowTips("XMBoss/XMBossProxy/label2");
            XMBossProxy.s = 2;
            MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_ZHAOHUAN_SUCCESS);


        elseif f == -1 then
            MsgUtils.ShowTips("XMBoss/XMBossProxy/label3");
        end

    end
end

-----------------------------------------------------------------------------------------------------------

function XMBossProxy.TryGetXMBossFB_ElseTime()


    SocketClientLua.Get_ins():SendMessage(CmdType.GetFB_ElseTime, { });
end



function XMBossProxy.TryGetXMBossFB_ElseTimeResult(cmd, data)


    if (data.errCode == nil) then

        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETFB_ELSETIME, data.t);
    end
end

------------------------------------------


function XMBossProxy.GetXMBossMainInfos()

    SocketClientLua.Get_ins():SendMessage(CmdType.GetXMBossMainInfos, { });
end


function XMBossProxy.GetXMBossMainInfosResult(cmd, data)

    if (data.errCode == nil) then
        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_GETXMBOSSMAININFOS, data);
    end
end


function XMBossProxy.GetXMBossRank()

    SocketClientLua.Get_ins():SendMessage(CmdType.GetXMBossRank, { });
end



function XMBossProxy.GetXMBossRankResult(cmd, data)

    if (data.errCode == nil) then
        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETXMBOSSRANK, data);
    end
end

function XMBossProxy.GetXMBossJoinInfos()

    SocketClientLua.Get_ins():SendMessage(CmdType.GetXMBossJoinInfos, { });
end


function XMBossProxy.GetXMBossJoinInfosResult(cmd, data)

    if (data.errCode == nil) then

        MessageManager.Dispatch(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETXMBOSSJOININFOS, data);
    end
end


function XMBossProxy.GetXMBossFBResult()

    SocketClientLua.Get_ins():SendMessage(CmdType.GetXMBossFBResult, { });
end


function XMBossProxy.GetXMBossFBResultResult(cmd, data)

    if (data.errCode == nil) then

    end
end


