require "Core.Module.DaysRank.DaysRankInfo"
DaysRankManager = {};

DaysRankManager.displayInToday = false;

DaysRankManager.Type = {
	LEVEL = 1;
	PET  = 3;
	WING = 4; -- 翅膀升星
	RMB  = 5;
	GEM = 6;
	FIGHT = 7;
}

-- TRUMP  EQUIP
DaysRankManager.Max = 6;
DaysRankManager.Days = {1,3,4,5,6,7};

local insert = table.insert
local _sortfunc = table.sort 

--登录后初始化开服活动的标识
function DaysRankManager.Init()
    local lastTime = 0;
    lastTime = Util.GetFloat("DaysRankTime_" .. PlayerManager.playerId, lastTime);
    
    if lastTime > 0 then
    	local lastDate = os.date("*t", lastTime);
    	local d = os.date("*t", GetOffsetTime());
    	if d.day ~= lastDate.day then
    		DaysRankManager.displayInToday = true;
	   	else
	   		DaysRankManager.displayInToday = false;
	   	end
    else
    	DaysRankManager.displayInToday = true;
    end
end

function DaysRankManager.GetListByDay(d)

	local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_DAYSRANK);
	local ret = {};
	for k, v in pairs(cfg) do
		if v.effective_time == d then
			insert(ret, v);
		end
	end

	_sortfunc(ret, function(a,b) return a.reward_rank < b.reward_rank end);
	return ret;
end

function DaysRankManager.GetOpenDay()
	local day = KaiFuManager.GetKaiFuHasDate();
	if day == nil or day > 7 or day <=0 then 
		day = 1;
	end
	--第一天判断
	if day < 3 then 
		day = 1;
	end
	return day;
end

function DaysRankManager.GetDays()
	local days = {};

	local day = DaysRankManager.GetOpenDay();
	--[[
	if day > DaysRankManager.Days[#DaysRankManager.Days] then
		return DaysRankManager.Days;
	end
	]]

	local idx = 1;
	for i, v in ipairs(DaysRankManager.Days) do
		if v == day then idx = i; break; end
	end
	for i = idx, DaysRankManager.Max do
		insert(days, DaysRankManager.Days[i]);
	end

	local d = 1;
	while(#days < DaysRankManager.Max) do
		insert(days, DaysRankManager.Days[d]);
		d = d+1;
	end
	
	return days;
end

function DaysRankManager.OpenPanel()
	if DaysRankManager.displayInToday then
		DaysRankManager.displayInToday = false;
		--记录打开时间
		Util.SetFloat("DaysRankTime_"..PlayerManager.playerId,  GetOffsetTime());

		MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS);
	end
end