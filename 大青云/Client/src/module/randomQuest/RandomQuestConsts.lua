--[[
奇遇任务 常量
2015年7月30日15:34:17
haohu
]]
--------------------------------------------------------------

_G.RandomQuestConsts = {}

local qiyuRoundsPerDay
function RandomQuestConsts:GetRoundsPerDay()
	if not qiyuRoundsPerDay then
		qiyuRoundsPerDay = _G.t_consts[89].val1
	end
	return qiyuRoundsPerDay
end
