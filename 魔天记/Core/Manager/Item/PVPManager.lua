PVPManager = {};

require "Core.Module.PVP.PVPNotes"

PVPManager.SELFPVPRANKCHANGE = "SELFPVPRANKCHANGE"
PVPManager.MESSAGE_VIP_BUY_TIME_CHANGE = "MESSAGE_VIP_BUY_TIME_CHANGE";


local _sortfunc = table.sort
PVPManager.PVPReadyTime = 5
local _otherPlayer = {}
local _pvpHadBuyTime = 0
local _pvpLimitTime = 0
local _pvpPoint = 0
local _pvpRank = 0
local _oldPVPRank = 0
local _rankData = {}
local _pvpReward = nil

function PVPManager.Init()
	_otherPlayer = {}
	-- _pvpHadBuyTime = 0
	_pvpPoint = {}
	-- _pvpLimitTime = 0
	_rankData = {}
	_pvpRank = 0
	_oldPVPRank = 0
	_pvpReward = nil
end

function PVPManager.Dispose()
	
end

function PVPManager.InitData(data)
	
	PVPManager._data = data
	_pvpPoint = data.s 
	_pvpLimitTime = data.t
	_pvpHadBuyTime = data.bt
	PVPManager._InitPVPPlayerData(data)
end

function PVPManager._InitPVPPlayerData(data)
	_otherPlayer = {}
	if(data) then
		for k, v in pairs(data.ps) do
			if _otherPlayer[v.idx] == nil then
				_otherPlayer[v.idx] = {}
			end
			
			_otherPlayer[v.idx].idx = v.idx
			_otherPlayer[v.idx].rank = v.r
			_otherPlayer[v.idx].playerId = v.p
			_otherPlayer[v.idx].name = v.n
			_otherPlayer[v.idx].kind = v.k
			--            local config = ConfigManager.GetCareerByKind(v.k)
			--            _otherPlayer[v.idx].model_id = config.model_id;
			--            _otherPlayer[v.idx].weapon_id = config.weapon_id;
			--            _otherPlayer[v.idx].hang_point = config.hang_point;
			--            _otherPlayer[v.idx].skeleton_id = config.skeleton_id;
			local dress = {a = v.a, b = v.b, w = v.w}
			_otherPlayer[v.idx].dress = dress
			_otherPlayer[v.idx].level = v.l
			_otherPlayer[v.idx].power = v.f
		end
		_sortfunc(_otherPlayer, function(a, b) return a.rank < b.rank end);
	end
	
end

-- 更新自己的排名
function PVPManager.UpdatePVPRank(rank)
	if(rank) then
		_pvpRank = rank
		MessageManager.Dispatch(PVPManager, PVPManager.SELFPVPRANKCHANGE)
	end
end

function PVPManager.UpdatePVPLimitTime(time)
	_pvpLimitTime = time
	ModuleManager.SendNotification(PVPNotes.UPDATE_PVPPANEL_LIMITTIME)
end

function PVPManager.UpdatePVPPoint(point)
	_pvpPoint = point
	ModuleManager.SendNotification(PVPNotes.UPDATE_PVPPANEL_PVPPOINT)
end

function PVPManager.UpdatePVPBuyTime(buyTime)
	_pvpHadBuyTime = buyTime
	MessageManager.Dispatch(PVPManager, PVPManager.MESSAGE_VIP_BUY_TIME_CHANGE);
end

function PVPManager.GetPVPPlayerData()
	return _otherPlayer
end

function PVPManager.GetPVPLimitTime()
	return _pvpLimitTime
end

function PVPManager.GetPVPPoint()
	return _pvpPoint
end

function PVPManager.GetPVPBuyTime()
	return _pvpHadBuyTime
end

function PVPManager.SetPVPBuyTime(t)
	_pvpHadBuyTime = t
end

function PVPManager.GetPVPDailyReward(rank)
	if(_pvpReward == nil) then
		_pvpReward = {}
		local rewardConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ARENA_REWARD)
		for k, v in ipairs(rewardConfig) do
			_pvpReward[k] = {}
			_pvpReward[k].start_id = v.start_id
			_pvpReward[k].end_id = v.end_id
			_pvpReward[k].diamond = v.diamond
			_pvpReward[k].dailyReward = PVPManager.GetRewardParse(v.award)
			_pvpReward[k].win_award_before = PVPManager.GetRewardParse(v.win_award_before)
			_pvpReward[k].defeat_award_before = PVPManager.GetRewardParse(v.defeat_award_before)
			_pvpReward[k].win_award_after = PVPManager.GetRewardParse(v.win_award_after)
			_pvpReward[k].defeat_award_after = PVPManager.GetRewardParse(v.defeat_award_after)
		end
	end
	
	for k, v in ipairs(_pvpReward) do
		if(rank >= v.start_id and rank <= v.end_id) then
			return ConfigManager.Clone(v.dailyReward)
		end
	end
	
end
local insert = table.insert
function PVPManager.SetPVPRankData(data)
	if(_rankData == nil) then
		_rankData = {}
	end
	
	for k, v in ipairs(data.ps) do
		insert(_rankData, v)
	end
	
	--    PVPManager._rankData = data.ps
	_sortfunc(_rankData, function(a, b)
		return a.r < b.r
	end)
end

function PVPManager.ResetPVPRankData()
	_rankData = {}
end

function PVPManager.GetPVPRankData()
	return _rankData
end

function PVPManager.GetRewardParse(strs)
	local reward = {}
	for k, v in ipairs(strs) do
		local temp = string.split(v, "_")
		local data = {}
		data.itemId = tonumber(temp[1])
		data.itemValueAdd = tonumber(temp[2])
		data.itemValueBase = tonumber(temp[3])
		insert(reward, data)
	end
	return reward
end

function PVPManager.GetPVPRank()
	return _pvpRank or 0
end

function PVPManager.SetOldPVPRank()
	_oldPVPRank = _pvpRank
end

function PVPManager.GetOldPVPRank()
	return _oldPVPRank
end 