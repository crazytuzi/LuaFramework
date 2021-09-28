require "Core.Module.Pattern.Proxy"

DaysTargetProxy = Proxy:New();
function DaysTargetProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RYSevenDayInfo, DaysTargetProxy.RspInfo);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RYSevenDayStatusChg, DaysTargetProxy.RspStatus);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RYSevenDayAward, DaysTargetProxy.RspGetAward);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RYSevenDayFullAward, DaysTargetProxy.RspGetDayAward);

    DaysTargetProxy.InitCfg();
end

function DaysTargetProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RYSevenDayInfo, DaysTargetProxy.RspInfo);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RYSevenDayStatusChg, DaysTargetProxy.RspStatus);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RYSevenDayAward, DaysTargetProxy.RspGetAward);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RYSevenDayFullAward, DaysTargetProxy.RspGetDayAward);
end

local _insert = table.insert;
local _sort = table.sort;
local cfgs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TACT_SEVENDAY_DETAIL);
local config = nil;

function DaysTargetProxy.InitCfg()
	config = {};
	for k, v in pairs(cfgs) do
		if not config[v.type] then config[v.type] = {} end;
		_insert(config[v.type], v);
	end

	for k,v in pairs(config) do
		_sort(v, function(a,b) return a.id < b.id end);
	end
end

DaysTargetProxy.hasAward = false;

local award = {};
local dayst = {};
function DaysTargetProxy.Init(data)
	award = {};
	dayst = {};
	for i, v in ipairs(data.l) do
		award[v.id] = v;
	end

	for i, v in ipairs(data.dl) do
		dayst[v.id] = v;
	end
	
	MessageManager.Dispatch(DaysTargetNotes, DaysTargetNotes.RSP_AWARD);
end

function DaysTargetProxy.SetNotify(data)
	DaysTargetProxy.hasAward = data.sevenday > 0;
	MessageManager.Dispatch(DaysTargetNotes, DaysTargetNotes.RSP_AWARD_CHG);
end

--获取某个配置的奖励状态
function DaysTargetProxy.GetAwrad(id)
	return award[id];
end
function DaysTargetProxy.GetAwradSt(id)
	return award[id] and award[id].st or 0;
end

function DaysTargetProxy.GetDayAward(day)
	return dayst[day] and dayst[day].st or 0;
end

function DaysTargetProxy.GetRedPoint()
	if DaysTargetProxy.hasAward then
		return true;
	end

	for k,v in pairs(config) do
		if DaysTargetProxy.GetDayRedPoint(k) then
			return true;
		end
	end
	return false;
end

function DaysTargetProxy.GetDayRedPoint(day)
	local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TACT_SEVENDAY)[day];
	return DaysTargetProxy.GetDayAwardNum(day) > 0 or 
	( DaysTargetProxy.GetDayAward(day) == 0 and DaysTargetProxy.GetDayFinishNum(day) >= cfg.num );
end

--获取某天的奖励数
function DaysTargetProxy.GetDayAwardNum(day)
	local num = 0;
	local cfgs = config[day];
	for i,v in ipairs(cfgs) do
		if award[v.id] and award[v.id].st == 1 then
			num = num + 1;
		end
	end
	return num;
end

function DaysTargetProxy.GetDayFinishNum(day)
	local num = 0;
	local cfgs = config[day];
	for i,v in ipairs(cfgs) do
		if award[v.id] and award[v.id].st > 0 then
			num = num + 1;
		end
	end
	return num;
end

--获取当前是活动的第几天
local tmpDay = 0;
function DaysTargetProxy.GetCurrentDay()
	local day = 0;
	local act = TimeLimitActManager.GetAct(302);
	if act then
		local now = GetTime();
		if now > act.startTime and now < act.endTime then
			local d1 = os.date("*t", now);
			local d2 = os.date("*t", act.startTime);
			day = d1.yday - d2.yday + 1;
		else
			day = -1;
		end
	else
		error("302 act not open");
		day = -1;
	end
	tmpDay = day;
	return day;
end

function DaysTargetProxy.GetCacheDay()
	return tmpDay;
end


function DaysTargetProxy.GetDayList(day)
	local list = config[day] or {};
	_sort(list, DaysTargetProxy.SortFun);
	return list;
end

function DaysTargetProxy.SortFun(a, b)
	local st1 = DaysTargetProxy.GetAwradSt(a.id);
	local st2 = DaysTargetProxy.GetAwradSt(b.id);
	if st1 == 2 then st1 = -1 end
	if st2 == 2 then st2 = -1 end
	if st1 == st2 then
		return a.id < b.id;
	end
	return st1 > st2;
end






--获取奖励信息
function DaysTargetProxy.ReqInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.RYSevenDayInfo);
end

function DaysTargetProxy.RspInfo(cmd, data)
	if(data ~= nil and data.errCode == nil) then
		DaysTargetProxy.Init(data);
	end
end

--奖励状态更新
function DaysTargetProxy.RspStatus(cmd, data)
	DaysTargetProxy.SetNotify(data);
end

function DaysTargetProxy.ReqGetAward(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.RYSevenDayAward, {id = id});
end

function DaysTargetProxy.RspGetAward(cmd, data)
	if(data ~= nil and data.errCode == nil) then
		local item = award[data.id];
		item.st = 2;
		DaysTargetProxy.hasAward = false;
		MessageManager.Dispatch(DaysTargetNotes, DaysTargetNotes.RSP_AWARD_CHG);
	end
end

function DaysTargetProxy.ReqGetDayAward(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.RYSevenDayFullAward, {id = id});
	--DaysTargetProxy.RspGetDayAward(0, {id = id});
end

function DaysTargetProxy.RspGetDayAward(cmd, data)
	if(data ~= nil and data.errCode == nil) then
		local item = dayst[data.id];
		item.st = 1;
		DaysTargetProxy.hasAward = false;
		MessageManager.Dispatch(DaysTargetNotes, DaysTargetNotes.RSP_AWARD_CHG);
	end
end

