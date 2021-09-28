-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_vit_tips = i3k_class("wnd_vit_tips", ui.wnd_base)

function wnd_vit_tips:ctor()
	
end

function wnd_vit_tips:configure()
	local widgets = self._layout.vars
	
	self.nowTime = widgets.nowTime
	self.boughtTimes = widgets.boughtTimes
	self.nextVitTime = widgets.nextVitTime
	self.maxVitTime = widgets.maxVitTime
	self.intervalTimeLabel = widgets.intervalTime
end

function wnd_vit_tips:refresh()
	local serverTime = g_i3k_get_GMTtime(i3k_game_get_time())
	local H = os.date("%H",serverTime)
	local M = os.date("%M",serverTime)
	local S = os.date("%S",serverTime)
	local time = string.format("%s:%s:%s",H,M,S) 
	self.nowTime:setText(time)
	
	local viplvl = g_i3k_game_context:GetVipLevel()
	local dayMaxTimes = i3k_db_kungfu_vip[viplvl].buyVitTimes
	local number = g_i3k_game_context:GetBuyVitTimes()
	local timesStr = string.format("%s/%s",number,dayMaxTimes)
	self.boughtTimes:setText(timesStr)
	
	local currentVit = g_i3k_game_context:GetVit()
	local maxVitValue = g_i3k_game_context:GetVitMax()
	local value = g_i3k_db.i3k_db_get_common_cfg().buyVit.recoverValue
	local intervalTime = g_i3k_db.i3k_db_get_common_cfg().buyVit.intervalTime
	local currentVitTime = g_i3k_game_context:GetVitRecoverTime()
	local time = i3k_game_get_time()
	local differ = intervalTime - (time - currentVitTime)
	local totalTime = (maxVitValue - currentVit - 1) / value * intervalTime + differ
	if currentVit >= maxVitValue then
		local str = string.format("00:00:00")
		self.nextVitTime:setText(str)
		self.maxVitTime:setText(str)
	else
		local nextH, nextM, nextS = self:getTime(differ)
		local next_time = string.format("%s:%s:%s", nextH, nextM, nextS)
		self.nextVitTime:setText(next_time)
		local maxH,maxM,maxS = self:getTime(totalTime)
		local maxtime = string.format("%s:%s:%s", maxH, maxM, maxS)
		self.maxVitTime:setText(maxtime)
	end
	
	local interval = math.modf(intervalTime / 60)
	self.intervalTimeLabel:setText(string.format("%s分钟",interval))
end

function wnd_vit_tips:getTime(t)
	local hour = math.modf(t/3600)
	local minute = math.modf(t%3600/60)
	local second = math.modf(t-hour*3600-60*minute)
	if hour < 10 then
		hour = string.format("0%s",hour)
	end
	if minute < 10 then
		minute = string.format("0%s",minute)
	end
	if second < 10 then
		second = string.format("0%s",second)
	end
	return hour, minute, second
end

function wnd_create(layout)
	local wnd = wnd_vit_tips.new()
		wnd:create(layout)
	return wnd
end

