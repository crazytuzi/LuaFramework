local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local MObserver = require "src/young/observer"
-----------------------------------------------------
observable = MObserver.new()

-- 观察者监听
register = function(self, observer)
	self.observable:register(observer)
end

-- 观察者取消监听
unregister = function(self, observer)
	self.observable:unregister(observer)
end

-- 向观察者发送广播
broadcast = function(self, ...)
	self.observable:broadcast(self, ...)
end
-----------------------------------------------
local g_ScriptEntry = nil

local stop_timer = function()
	if g_ScriptEntry ~= nil then
		Director:getScheduler():unscheduleScriptEntry(g_ScriptEntry)
		g_ScriptEntry = nil
	end
end

local start_timer = function(func)
	stop_timer()
	g_ScriptEntry = Director:getScheduler():scheduleScriptFunc(function(dt) func(dt) end, 1.0, false)
end

local g_versus_info = nil
get_versus_info = function(self)
	return g_versus_info
end

-- 应战
accept = function(self)
	g_msgHandlerInst:sendNetDataByTableExEx(COMPETITION_CS_ACCEPT, "CompetitionAcceptProtocol", {})
end

-- 领取奖励
get_reward = function(self)
	if G_ROLE_MAIN and G_ROLE_MAIN.obj_id then
		g_msgHandlerInst:sendNetDataByTableExEx(COMPETITION_CS_PICK_REWARD, "CompetitionPickRewardProtocol", {})
	end
end

-- 领取奖励结果返回
g_msgHandlerInst:registerMsgHandler(COMPETITION_SC_PICK_REWARD_RET, function(buf)
	TIPS({ type = 1  , str = game.getStrByKey("get_lq")..game.getStrByKey("success") })
	
	g_versus_info = nil
	
	local t = g_msgHandlerInst:convertBufferToTable("CompetitionPickRewardRetProtocol", buf)
	dump(t, "领取奖励结果返回")
	
	local has_award_enter_bag = t.isInBag
	--M:broadcast("vs_over", has_award_enter_bag, award)
end)

-- 注销
on_logout = function(self)
	g_versus_info = nil
	stop_timer()
end

-- 通知客户端拼战信息
g_msgHandlerInst:registerMsgHandler(COMPETITION_SC_NOTIFY_COMPETITION, function(buf)
	dump("COMPETITION_SC_NOTIFY_COMPETITION", "通知客户端拼战信息")
	---------------------------------------------------------------
	local t = g_msgHandlerInst:convertBufferToTable("CompetitionNotifyStarProtocol", buf)
	dump(t, "通知客户端拼战信息")
	
	local isFriend = t.isFriend
	local time_remaining = t.remainTime
	local is_first = t.isFirst == 1
	local awards = t.tReward
	local player_num = t.playerNum
	local st = t.playerData
	local players = {}
	local ranking = {}
	for i = 1, player_num do
		local cur = st[i]
		local player_name = tostring(cur.roleName)
		local school = tonumber(cur.school)
		local sex = tonumber(cur.sex)
		local weaponID = tonumber(cur.weaponID) --武器原形
		local clothID = tonumber(cur.clothID) --衣服原形
		local wingID = tonumber(cur.wingID) --翅膀原形
		local result = tonumber(cur.value) -- 战斗力
	
		players[player_name] = 
		{
			school = school,
			rank = i,
			result = result,
			sex = sex,
			weaponID=weaponID,
			clothID=clothID,
			wingID=wingID
		}
		ranking[i] = player_name
	end
	---------------------------------------------------------------
	local versus_info = {
		time_remaining = time_remaining,
		award = awards,
		player_num = player_num,
		players = players,
		ranking = ranking,
		status = "vs_begin",
		is_first = is_first,
		isFriend = isFriend,
	}
	dump(versus_info, "通知客户端拼战信息")
	
	g_versus_info = versus_info
	
	start_timer(function(dt)
		local time_remaining = tonumber(versus_info.time_remaining)
		if time_remaining == nil then
			stop_timer()
			return
		end
		
		if time_remaining <= 0 then
			stop_timer()
			versus_info.status = "vs_time_over"
			M:broadcast("vs_time_over", versus_info)
		else
			versus_info.status = "vs_countdown"
			versus_info.time_remaining = time_remaining - 1
			M:broadcast("vs_countdown", versus_info)
			
			if versus_info.time_remaining < 60 and not versus_info.time_sync then
				versus_info.time_sync = true
				
				-- 发送校对时间请求返回
				g_msgHandlerInst:registerMsgHandler(COMPETITION_SC_SYN_TIME_RET, function(buf)
					local t = g_msgHandlerInst:convertBufferToTable("CompetitionSynTimeRetProtocol", buf)
					--dump(t, "发送校对时间请求返回")
					local remaining = t.time
					versus_info.time_remaining = remaining
				end)
				
				-- 发送校对时间请求
				g_msgHandlerInst:sendNetDataByTableExEx(COMPETITION_CS_SYN_TIME, "CompetitionSynTimeProtocol", {})
				addNetLoading(COMPETITION_CS_SYN_TIME, COMPETITION_SC_SYN_TIME_RET)
			end
		end
	end)
	
	M:broadcast("vs_begin", versus_info)
end)

on_vs_begin = function(self, info)
	info.is_first = false
	local ranking = info.ranking
	local is_self = ranking[1] == MRoleStruct:getAttr(ROLE_NAME)
	-- 应战界面
	Mversus_accept = require "src/layers/random_versus/versus_accept"
	local Manimation = require "src/young/animation"
	Manimation:transit(
	{
		node = Mversus_accept.new({initiator = is_self and ranking[2] or ranking[1], versus_info = info }),
		sp = g_scrCenter,
		--trend = "-",
		curve = "-",
		zOrder = 200,
		swallow = true,
	})
end

on_vs_end = function(self, info)
	if info ~= nil and info.award == 3 and info.ranking == 3 then return end
	
	require("src/layers/random_versus/versus_end").new(info)
end

on_vs_ing = function(self)
	local info = self:get_versus_info()
	if info ~= nil then
		local status = info.status
		if status == "vs_begin" or status == "vs_countdown" then
			if info.is_first then -- 最初
				self:on_vs_begin(info)
				return true
			end
				
			local Manimation = require "src/young/animation"
			Manimation:transit(
			{
				node = require("src/layers/random_versus/versus_view"):new(info),
				sp = g_scrCenter,
				ep = g_scrCenter,
				--trend = "-",
				zOrder = 200,
				curve = "-",
				swallow = true,
			})
			
			return true
		else
			TIPS({ type = 1  , str = "拼战已结束" })
			return false
		end
	else
		TIPS({ type = 1  , str = "没有进行中的拼战" })
		return false
	end
end

-- 通知客户端奖励信息
g_msgHandlerInst:registerMsgHandler(COMPETITION_SC_NOTIFY_REWARD, function(buf)
	dump(COMPETITION_SC_NOTIFY_REWARD, "通知客户端奖励信息")
	
	stop_timer()
	----------------------------------------------
	local t = g_msgHandlerInst:convertBufferToTable("CompetitionNotifyRewardProtocol", buf)
	dump(t, "通知客户端奖励信息")
	local award = t.rewardId
	local rank = t.rank -- 1第一名, 2第二名
	----------------------------------------------
	local versus_info = {
		award = award,
		ranking = rank,
		status = "vs_end",
	}
	dump(versus_info, "通知客户端奖励信息")
	
	g_versus_info = versus_info
	
	M:broadcast("vs_end", versus_info)
end)