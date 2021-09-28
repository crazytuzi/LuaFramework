require "Core.Module.Pattern.Proxy"
require "net/CmdType"
require "net/SocketClientLua"

require "Core.Info.RankInfo";

RankProxy = Proxy:New();
local insert = table.insert
local _sortfunc = table.sort 

function RankProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_Fight, RankProxy._RspListRoleFight);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_Level, RankProxy._RspListRoleLevel);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_Gold, RankProxy._RspListRoleGold);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_Money, RankProxy._RspListRoleMoney);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_Pet, RankProxy._RspListPet);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_Realm, RankProxy._RspListRealm);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_Wing, RankProxy._RspListWing);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_GuildFight, RankProxy._RspListGuildFight);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_GuildRank, RankProxy._RspListGuildRank);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_Xuling, RankProxy._RspListXuling);

       SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_List_AutoFight, RankProxy._RspAutoFight);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_Item_Info, RankProxy._RspRoleinfo);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Rank_Send_Flower, RankProxy._RspSendFlower);
   
end

function RankProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_Fight, RankProxy._RspListRoleFight);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_Level, RankProxy._RspListRoleLevel);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_Gold, RankProxy._RspListRoleGold);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_Money, RankProxy._RspListRoleMoney);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_Pet, RankProxy._RspListPet);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_Realm, RankProxy._RspListRealm);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_Wing, RankProxy._RspListWing);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_GuildFight, RankProxy._RspListGuildFight);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_GuildRank, RankProxy._RspListGuildRank);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_Xuling, RankProxy._RspListXuling);
     SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_List_AutoFight, RankProxy._RspAutoFight);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_Item_Info, TaskProxy._RspRoleinfo);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Rank_Send_Flower, TaskProxy._RspSendFlower);
end

function RankProxy.ReqList(t, page)
    if t == RankConst.Type.ARENA then
        SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetPVPRank, RankProxy._RspListArena);
        SocketClientLua.Get_ins():SendMessage(CmdType.GetPVPRank, { p = page - 1});
    else
        local cmd = RankConst.Req[t];
        if cmd then
            SocketClientLua.Get_ins():SendMessage(cmd, {idx = page});
        else
            log("cmd is nil " .. t)
        end
    end
end

function RankProxy._RspList(t, data)
    
    if(data == nil or data.errCode ~= nil) then
        return;
    end
    
    if data.idx > 1 and #data.l == 0 then
        return;
    end

    local tmp = {};
    for i,v in ipairs(data.l) do
        local item = RankInfo.New(v);
        item.type = t;
        if t == RankConst.Type.ARENA then
            item:UpdateWithArena(v);
        end
        insert(tmp, item);
    end

    local myData = RankInfo.New();
    myData.type = t;
    myData:GetMyInfo(data);
    MessageManager.Dispatch(RankNotes, RankNotes.RSP_LIST, {t = t, p = data.idx ,list = tmp, my = myData});
end

function RankProxy.ReqRoleInfo(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.Rank_Item_Info, {id = id});
end

function RankProxy._RspRoleinfo(cmd, data)
    if(data == nil or data.errCode ~= nil) then
        return;
    end
    
    MessageManager.Dispatch(RankNotes, RankNotes.RSP_ITEM, data);
end

function RankProxy.ReqSendFlower(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.Rank_Send_Flower, {id = id});
end

function RankProxy._RspSendFlower(cmd, data)
    if(data == nil or data.errCode ~= nil) then
        return;
    end

    MessageManager.Dispatch(RankNotes, RankNotes.RSP_SEND_FLOWER, data);
end

function RankProxy._RspListRoleFight(cmd, data)
    RankProxy._RspList(RankConst.Type.FIGHT, data);
end

function RankProxy._RspListRoleLevel(cmd, data)
    RankProxy._RspList(RankConst.Type.LEVEL, data);
end

function RankProxy._RspListRoleGold(cmd, data)
    RankProxy._RspList(RankConst.Type.GOLD, data);
end

function RankProxy._RspListRoleMoney(cmd, data)
    RankProxy._RspList(RankConst.Type.MONEY, data);
end

function RankProxy._RspListPet(cmd, data)
    RankProxy._RspList(RankConst.Type.PET, data);
end

function RankProxy._RspListRealm(cmd, data)
    RankProxy._RspList(RankConst.Type.REALM, data);
end

function RankProxy._RspListWing(cmd, data)
    RankProxy._RspList(RankConst.Type.WING, data);
end

function RankProxy._RspListGuildFight(cmd, data)
    RankProxy._RspList(RankConst.Type.GUILD_FIGHT, data);
end

function RankProxy._RspListGuildRank(cmd, data)
    RankProxy._RspList(RankConst.Type.GUILD_RANK, data);
end

function RankProxy._RspListArena(cmd, data)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetPVPRank, RankProxy._RspListArena);
    if (data and data.errCode == nil) then
        local list = data.ps;
        _sortfunc(list, function(a,b) return a.r < b.r end);
        local tmp = {idx = data.p + 1, l = list};
        RankProxy._RspList(RankConst.Type.ARENA, tmp);
    else

    end
end

function RankProxy._RspListXuling(cmd, data)
    RankProxy._RspList(RankConst.Type.XULING, data);
end

function RankProxy._RspAutoFight(cmd, data)
    RankProxy._RspList(RankConst.Type.AUTOFIGHT, data);
end


