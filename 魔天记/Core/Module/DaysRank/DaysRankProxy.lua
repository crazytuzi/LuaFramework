require "Core.Module.Pattern.Proxy"

DaysRankProxy = Proxy:New();
function DaysRankProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.DaysRank_List, DaysRankProxy._RspRankDetail);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.DaysRank_Award, DaysRankProxy._RspRankAward);
    
end

function DaysRankProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.DaysRank_List, DaysRankProxy._RspRankDetail);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.DaysRank_Award, DaysRankProxy._RspRankAward);
end

local award = {};
function DaysRankProxy.SetAward(data)
    award = {};
    --data = {{t = 1, r = 1, s = 0}}
    if data then
        for i, v in ipairs(data) do
            award[v.t * 10 + v.r] = v.s;
        end
    end
    MessageManager.Dispatch(DaysRankNotes, DaysRankNotes.ENV_DAYS_AWARD_CHG);
end

function DaysRankProxy.GetAward(type, rank)
    return award[type * 10 + rank] or -1;
end

function DaysRankProxy.ReqRankDetail(type)
	--DaysRankProxy.reqType = type;
	--DaysRankProxy._RspRankDetail(nil, {l = {}, type = type});
	SocketClientLua.Get_ins():SendMessage(CmdType.DaysRank_List, {t = type});
end
local insert = table.insert
local _sortfunc = table.sort 

function DaysRankProxy._RspRankDetail(cmd, data)
	if(data == nil or data.errCode ~= nil) then
        return;
    end

    local info = {};
    info.list = {};
    for i,v in ipairs(data.l) do 
    	if data.t == DaysRankManager.Type.RMB then
            --[[
            if v.pid == PlayerManager.playerId then
               v.v = math.ceil(v.v / 100); 
            end
            ]]
            if tonumber(v.v) <= 0 then
                v.v = "-";
            else
                v.v = math.ceil(v.v / 100);
            end
    	end
    	insert(info.list, DaysRankInfo.Init(v, data.t));
    end
    
    _sortfunc(info.list, function(a,b) return a.id < b.id end);

    info.my = DaysRankInfo.GetMyVal(data.t, data);
    MessageManager.Dispatch(DaysRankNotes, DaysRankNotes.RSP_DAYS_DETAIL, info);
end

function DaysRankProxy.ReqRankAward(type)
    SocketClientLua.Get_ins():SendMessage(CmdType.DaysRank_Award, {t = type});
end

function DaysRankProxy._RspRankAward(cmd, data)
    if(data == nil or data.errCode ~= nil) then
        return;
    end

    if data.rg then
        DaysRankProxy.SetAward(data.rg);
    end
end

function DaysRankProxy.GetRedPoint()
    for k, v in pairs(award) do
        if v == 0 then
            return true;
        end
    end
    return false;
end

function DaysRankProxy.GetDayRedPoint(day)
    for k, v in pairs(award) do
        if math.floor(k / 10) == day then
            if v == 0 then
                return true;
            end
        end
    end
    return false;
end

function DaysRankProxy.GetDayAwardIdx(day)
    local idx = 0;
    for k, v in pairs(award) do
        if math.floor(k / 10) == day and v == 0 then
            idx = k % 10;
        end
    end
    return idx;
end