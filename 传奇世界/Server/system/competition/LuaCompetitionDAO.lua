--LuaCompetitionDAO.lua
--/*-----------------------------------------------------------------
 --* Module:  LuaCompetitionDAO.lua
 --* Author:  seezon
 --* Modified: 2014年12月19日
 --* Purpose: 小功能数据池
 -------------------------------------------------------------------*/
--]]
--------------------------------------------------------------------------------
LuaCompetitionDAO = class(nil, Singleton)

function LuaCompetitionDAO:__init()

	self._staticRewards = {}

	--加载所有的潜能丹原型
	local rewardDBs = require "data.CompetitionDB"
	for _, record in pairs(rewardDBs or table.empty) do
		self._staticRewards[record.q_id] = record
	end

end


--获取奖励数据
function LuaCompetitionDAO:getRewardDB(rewardId)
	if rewardId then
	    return self._staticRewards[rewardId]
	end
end

--根据条件获取奖励ID
function LuaCompetitionDAO:getRewardByCondtion(isNew, rank)
	local type = 2
	if isNew > 0 then
		type = 1
	end

	local tempTB = {}
	for k,v in pairs(self._staticRewards or {}) do
		if type == v.q_type and rank == v.q_rank then
			table.insert(tempTB, v)
		end
	end

	if table.size(tempTB) == 0 then
		return 1
	end

	local randNum = math.random(1, table.size(tempTB))
	local rd = tempTB[randNum]
	return rd.q_id
end

function LuaCompetitionDAO.getInstance()
	return LuaCompetitionDAO()
end