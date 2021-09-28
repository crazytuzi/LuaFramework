local p = require "protocoldef.knight.gsp.activity.football.sfootballinfo"
function p:process()
	local _instance = require "ui.shijiebei.shijiebeilabel".getInstance()
	_instance:SetLeftTimes(self.times, self.maxfreetimes, self.maxpaytimes)
	_instance.Show(1)
end

local p = require "protocoldef.knight.gsp.activity.football.sfootballrank"
function p:process()
	local _instance = require "ui.shijiebei.shijiebeilabel".getInstance()
	_instance:SetRankData(self.ranks)
	_instance.Show(2)
end
