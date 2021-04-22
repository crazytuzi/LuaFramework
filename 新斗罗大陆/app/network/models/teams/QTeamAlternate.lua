-- @Author: zhouxiaoshu
-- @Date:   2019-09-07 17:48:49
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-05 16:10:59
local QTeamNormal = import(".QTeamNormal")
local QTeamAlternate = class("QTeamAlternate", QTeamNormal)

function QTeamAlternate:ctor(options)
	QTeamAlternate.super.ctor(self, options)
end

--根据战队序号获取解锁的魂师最大位置
function QTeamAlternate:getHerosMaxCountByIndex(index)
	local count = 0
	if index == 1 then
		count = 4
	elseif index == 2 then
		if app.unlock:getUnlockTeamAlternateHelp4() then
			count = 4
		elseif app.unlock:getUnlockTeamAlternateHelp3() then
			count = 3
		elseif app.unlock:getUnlockTeamAlternateHelp2() then
			count = 2
		elseif app.unlock:getUnlockTeamAlternateHelp1() then
			count = 1
		end
	elseif index == 3 then
		if app.unlock:getUnlockTeamAlternateHelp9() then
			count = 5
		elseif app.unlock:getUnlockTeamAlternateHelp8() then
			count = 4
		elseif app.unlock:getUnlockTeamAlternateHelp7() then
			count = 3
		elseif app.unlock:getUnlockTeamAlternateHelp6() then
			count = 2
		elseif app.unlock:getUnlockTeamAlternateHelp5() then
			count = 1
		end
	elseif index == 5 then
		if app.unlock:getUnlockTeamGodarmHelp4() then
			count = 4
		elseif app.unlock:getUnlockTeamGodarmHelp3() then
			count = 3
		elseif app.unlock:getUnlockTeamGodarmHelp2() then
			count = 2
		elseif app.unlock:getUnlockTeamGodarmHelp1() then
			count = 1
		end	
	else
		count = 0
	end

	return count
end

--检查一个战队中某个小队的精灵是否满员
function QTeamAlternate:checkAlternateIsFullByIndex(index)
	local alternateIds = self:getTeamAlternatesByIndex(index)
	local maxCount = self:getAlternateMaxCountByIndex(index)
	return #alternateIds >= maxCount
end

--获取战队的最大队伍数量
function QTeamAlternate:getTeamMaxIndex()
	return 3
end

function QTeamAlternate:getDefaultTeam()
	return team
end

--排序战队中的魂师
function QTeamAlternate:sortTeam()
	local count = self:getTeamMaxIndex()
	for i = 1, count do
		local heros = self:getTeamActorsByIndex(i)
		if q.isEmpty(heros) == false then
			if i == 1 then
				remote.teamManager:sortTeam(heros)
			else
				remote.teamManager:sortTeamByForce(heros)
			end
		end
	end
end

function QTeamAlternate:getHelpUnlockLevel(index)
	if index == nil then return 0 end
	local unlockLevel = app.unlock:getConfigByKey("UNLOCK_SOTO_TEAM_"..index).team_level
	return unlockLevel
end

--检查战队中的魂师是否存在，不存在就删除掉
function QTeamAlternate:checkTeamHero()
	local maxIndex = self:getTeamMaxIndex()
	for i=1,maxIndex do
		local actorIds = self:getTeamActorsByIndex(i)
		if q.isEmpty(actorIds) == false then
			local index = #actorIds
			while index > 0 do
				local actorId = actorIds[index]
				if q.isEmpty(remote.herosUtil:getHeroByID(actorId)) then
					table.remove(actorIds, index)
				end
				index = index - 1
			end
			self:setTeamActorsByIndex(i, actorIds)
		end
	end
end

return QTeamAlternate
