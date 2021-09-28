-- FileName: FightHeroModel.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗武将信息模型
FightHeroModel = class("FightHeroModel")

--[[
	@des:构造方法
--]]
function FightHeroModel:ctor( pHid )
	self._hid = pHid
	self._heroInfo = getHeroByHid(pHid)
	if not self._heroInfo then
		--
end

--[[
	@des:得到hid
	@ret:hid
--]]
function FightHeroModel:getHid()
	local hid = tonumber(self._heroInfo.hid)
	return hid
end

--[[
	@des:得到名称
--]]
function FightHeroModel:getName()
	local name = tonumber(self._heroInfo.name)
	return name
end

--[[
	@des:得到全身像名称
--]]
function FightHeroModel:getBodyImageName()
	local name = self:getDBConfig().action_module_id
	return name
end

--[[
	@des:得到背景卡牌像名称
--]]
function FightHeroModel:getBgImageName()
	local name = tonumber(self._heroInfo.name)
	if not name then
		name = getDBConfig().name
	end
	return name
end

--[[
	@des:得到卡牌偏移量
--]]
function FightHeroModel:getBodyOffset( )
	
end

--[[
	@des:得到数据表配置
	@ret:table
--]]
function FightHeroModel:getDBConfig()
	require "db/DB_Heroes"
	require "db/DB_Monsters_tmpl"
	local dbInfo = DB_Heroes.getDataById(self._heroInfo.htid)
	if not dbInfo then
		dbInfo = DB_Monsters_tmpl.getDataById(self._heroInfo.htid)
	end 
	return dbInfo
end

--[[
	@des:得到卡牌类型 
	@ret:CardType
--]]
function FightHeroModel:getCardType()
	
end


--[[
	@des:
--]]


--[[
	@des:得到卡牌星级
	@ret:number
--]]
function FightHeroModel:getStartLevel()
	local dbInfo = self:getDBConfig()
	return tonumber(dbInfo.star_lv)
end




