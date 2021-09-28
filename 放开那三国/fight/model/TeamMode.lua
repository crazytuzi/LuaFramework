-- FileName: TeamMode.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗组信息模型

TeamMode = class("TeamMode")


function TeamMode:ctor( ... )
	self._teamInfo = nil
	self._petId = nil
	self._warcraftId = nil
end

--[[
	@des:得到武将模型对象
	@pram: 武将hid
--]]
function TeamMode:createByArmyId( pArmyId )
	
end

function TeamMode:createByBattleTeam( pTeamInfo )
	
end

function TeamMode:createWithFormation( pFormationInfo )
	
end

--[[
	@des:得到武将模型对象
	@pram: 武将hid
--]]
function TeamMode:getHeroModelByHid( p_hid )
	
end

--[[
	@des:得到部队bossId
--]]
function TeamMode:getBossId()
	
end

--[[
	@des:得到boss卡牌类型
	@ret:CardType
--]]
function TeamMode:getBossCardType()
	
end

