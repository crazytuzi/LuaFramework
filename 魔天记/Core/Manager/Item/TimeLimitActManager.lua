local TimeLimitActInfo = class("TimeLimitActInfo");

function TimeLimitActInfo:ctor(cfg)
	setmetatable(self, { __index = cfg });
	TimeLimitActInfo.InitTime(self);
end

function TimeLimitActInfo:InitTime()
	local f = nil;
	local now = GetOffsetTime();
	local date = os.date("*t", now);
	local openDay = KaiFuManager.GetKaiFuHasDate();
	if self.type == 1 then
		local vDay = date.day - openDay;
		local val, hour, min, sec;
		f = "(%d+)_(%d+):(%d+):(%d+)";
		val, hour, min, sec = self.open_time:match(f);
		date.day = vDay + val 
		date.hour = hour;
		date.min = min;
		date.sec = sec;
		self.openTime = os.time(date);

		val, hour, min, sec = self.effective_time:match(f);
		date.day = vDay + val
		date.hour = hour;
		date.min = min;
		date.sec = sec;
		self.startTime = os.time(date);

		val, hour, min, sec = self.end_time:match(f);
		date.day = vDay + val
		date.hour = hour;
		date.min = min;
		date.sec = sec;
		self.endTime = os.time(date);

		val, hour, min, sec = self.close_time:match(f);
		date.day = vDay + val
		date.hour = hour;
		date.min = min;
		date.sec = sec;
		self.closeTime = os.time(date);
		
	elseif self.type == 2 then
		--todo
		--f = "(%d+)_(%d+):(%d+):(%d+)";
		--local val, hour, min, sec = self.open_time:match(f);
		

	elseif self.type == 3 then
		f = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)";
		local year, month, day, hour, min, sec;

		year, month, day, hour, min, sec = self.open_time:match(f);
		self.openTime = os.time({year=year, month=month, day=day, hour=hour, min=min, sec=sec});

		year, month, day, hour, min, sec = self.effective_time:match(f);
		self.startTime = os.time({year=year, month=month, day=day, hour=hour, min=min, sec=sec});

		year, month, day, hour, min, sec = self.end_time:match(f);
		self.endTime = os.time({year=year, month=month, day=day, hour=hour, min=min, sec=sec});

		year, month, day, hour, min, sec = self.close_time:match(f);
		self.closeTime = os.time({year=year, month=month, day=day, hour=hour, min=min, sec=sec});

	elseif self.type == 4 then
		f = "(%d+):(%d+)";
		local hour, min;
		local ct = PlayerManager.GetCreateRoleTime();
		hour, min = self.open_time:match(f);
		self.openTime = ct + hour * 3600 + min * 60;

		hour, min = self.effective_time:match(f);
		self.startTime = ct + hour * 3600 + min * 60;

		hour, min = self.end_time:match(f);
		self.endTime = ct + hour * 3600 + min * 60;

		hour, min = self.close_time:match(f);
		self.closeTime = ct + hour * 3600 + min * 60;
		--Warning(now)
		--Warning(self.openTime);
		--Warning(self.closeTime);
	end

	if self.openTime and self.closeTime then
		self.isOpen = now >= self.openTime and now < self.closeTime;
	else
		self.isOpen = false;
	end
end

TimeLimitActManager = {};

--TimeLimitActManager.UPDATE = "TimeLimitActManager.UPDATE";

local cfgs = nil;
local dict = nil;
local acts = nil;
local timer = nil;
local _insert = table.insert;
local _GetOffsetTime = GetOffsetTime

function TimeLimitActManager.Init()
	cfgs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TIME_LIMIT_ACT);
	acts = {};
	dict = {};
	for k, v in pairs(cfgs) do
		local info = TimeLimitActInfo.New(v);
		if TimeLimitActManager.CheckAct(info) then
			_insert(acts, info);
		end
		if not dict[v.sys_id] then dict[v.sys_id] = {} end
		_insert(dict[v.sys_id], info);
	end
	if timer == nil then
		timer = Timer.New(TimeLimitActManager.OnUpdate, 1, - 1, false):Start()
	end

	MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS);
end

function TimeLimitActManager.CheckAct(act)
	if act.isOpen then return true end;
	local now = _GetOffsetTime()
	return now < act.closeTime;
end

function TimeLimitActManager.Clear()
	if timer then
		timer:Stop();
		timer = nil;
	end
end

function TimeLimitActManager.OnUpdate()
	local now = _GetOffsetTime()
	local isChg = false;
	for i, v in ipairs(acts) do
		if v.isOpen then
			if now >= v.closeTime then
				v.isOpen = false;
				isChg = true;
			end
		else
			if now >= v.openTime and now < v.closeTime then
				v.isOpen = true;
				isChg = true;
			end
		end
	end

	if isChg then
		MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS);
	end
end


function TimeLimitActManager.GetList()
	return acts;
end

function TimeLimitActManager.CheckSys(sysId)
    local f = true
	if dict[sysId] then
        f = false
		for i, v in ipairs(dict[sysId]) do
			if v.isOpen then
				f = true
				break;
			end
		end
	end	
	--Warning(sysId .. '----' .. tostring(f))
	return f
end

--获取某个系统的关联活动.(优先)
function TimeLimitActManager.GetAct(sysId)
	local act = nil;
	local infos = dict[sysId];
	if infos then
		for i, v in ipairs(infos) do
			if v.isOpen then
				act = v;
				break;
			end
		end
		if act == nil then
			act = infos[1];
		end
	end
	return act;
end

function TimeLimitActManager.GetDownTime(timeLimitActInfo)
    local gt = timeLimitActInfo.endTime - GetTime()
    --Warning(gt ..'_' ..  timeLimitActInfo.endTime ..'-' .. GetTime())
    return gt
end

function TimeLimitActManager.GetActiveId(timeLimitActInfo)
    return timeLimitActInfo.id
end
