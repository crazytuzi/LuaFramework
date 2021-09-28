-- FileName: FightHeroModel.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗武将信息模型
FightHeroEntity = class("FightHeroEntity")

--[[
	@des:构造方法
--]]
function FightHeroEntity:ctor(...)
	self._hid = pHid

end

function FightHeroEntity:createWithHtid( pHtid )
	local instance = FightHeroEntity.new()
	instance._heroInfo = {}
	instance._heroInfo.htid = pHtid
	return instance
end

function FightHeroEntity:createWithHid( pHid )
	local instance = FightHeroEntity.new()
	instance._hid = pHid
	instance:initWithHid(pHid)
	-- printTable("instance._heroInfo", instance._heroInfo)
	return instance
end

function FightHeroEntity:initWithHid( pHid )
	self._heroInfo = HeroModel.getHeroByHid(pHid)
	local battleHeroInfo = FightStrModel.getHeroInfoByHid(pHid)
	if battleHeroInfo then
		self._heroInfo = battleHeroInfo
	else
		local monsterInfo = DB_Monsters.getDataById(pHid)
		if monsterInfo then
			self._heroInfo = {}
			self._heroInfo.htid = monsterInfo.htid
			self._heroInfo.level =  monsterInfo.level
		end
	end
end

--[[
	@des:得到hid
	@ret:hid
--]]
function FightHeroEntity:getHid()
	local hid = tonumber(self._heroInfo.hid) or 0
	return hid
end

--[[
	@des:得到时装id
	@ret:hid
--]]
function FightHeroEntity:getDressId()
	local dressId = nil
	if self._heroInfo.dress then
		dressId = tonumber(self._heroInfo.dress["1"])
	end
	if self:getHid() == tonumber(HeroModel.getNecessaryHero().hid) then
		dressId = UserModel.getDress()["1"]
	end
	if tonumber(dressId) == 0 then 
		dressId = nil 
	end
	return dressId
end

--[[
	@des:得到hid
	@ret:hid
--]]
function FightHeroEntity:getHtid()
	return self._heroInfo.htid
end


--[[
	@des:得到背景卡牌像名称
--]]
function FightHeroEntity:getName()
	local name = self._heroInfo.name
	if not name then
		name = self:getDBConfig().name
	end
	if self:getHid() == tonumber(HeroModel.getNecessaryHero().hid) then
		name = UserModel.getUserName()
	end
	return name
end

--[[
	@des:得到全身像名称
--]]
function FightHeroEntity:getBodyImagePath()
	local name = self:getBodyImageName()
	local cardType = self:getCardType()
	local path = "images/base/hero/"
	if cardType == CardType.NORMAL then
		path = path .. "action_module/"
	elseif cardType == CardType.BOSS then
		path = path .. "action_module_b/"
	elseif cardType == CardType.BLACK_BOSS then
		path = path .. "action_module_b/"
	elseif cardType == CardType.GOD_BOSS then
		path = path .. "body_img/"
		name = self:getDBConfig().body_img_id
	end
	path = path .. name
	return path
end

--[[
	@des:得到角色动作模型名称
--]]
function FightHeroEntity:getBodyImageName()
	local name = self:getDBConfig().action_module_id
	--检查时装信息
	local dressId = self:getDressId()
	if dressId then
		local dress = DB_Item_dress.getDataById(tonumber(dressId))
        if(dress and dress.changeModel) then
            local modelArray = lua_string_split(dress.changeModel,",")
            for modelIndex=1,#modelArray do
                local baseHtid = lua_string_split(modelArray[modelIndex],"|")[1]
                local dressFile = lua_string_split(modelArray[modelIndex],"|")[2]
                local heroTmpl = DB_Heroes.getDataById(tonumber(self._heroInfo.htid))
                if(heroTmpl.model_id == tonumber(baseHtid))then
                    name = dressFile
                end
            end
        end
	end
	return name
end

--[[
	@des:得到卡牌偏移量
--]]
function FightHeroEntity:getBodyOffset( )
	require "script/battle/BattleCardUtil"
	local name = self:getBodyImageName()
	local isBoss = (self:getCardType() ==  CardType.BOSS) or (self:getCardType() ==  CardType.BLACK_BOSS)
	local offset = BattleCardUtil.getDifferenceYByImageName(self._heroInfo.htid,name, isBoss)
	if isBoss then
		offset = offset + 35
	else
		offset = offset + 25
	end
	return offset
end

--[[
	@des:得到数据表配置
	@ret:table
--]]
function FightHeroEntity:getDBConfig()
	require "db/DB_Heroes"
	require "db/DB_Monsters_tmpl"
	require "db/DB_Monsters"
	local dbInfo = DB_Heroes.getDataById(self._heroInfo.htid)
	if not dbInfo then
		local monsterInfo = DB_Monsters.getDataById(self._heroInfo.htid)
		dbInfo = DB_Monsters_tmpl.getDataById(monsterInfo.htid)
	end 
	return dbInfo
end

--[[
	@des:得到卡牌类型 大卡牌，小卡牌，boss卡牌
	@ret:CardType
--]]
function FightHeroEntity:getCardType()
	if self._hid == nil then
		return CardType.NORMAL
	end
	local cardType      = CardType.NORMAL
	local armyId        = nil
	local armyInfo      = nil
	local teamInfo      = nil
	if FightModel.getbModel() == BattleModel.SINGLE then
		--战斗串战斗
		armyId = FightScene.getArmyId()
		if armyId == nil then
			return CardType.NORMAL
		end
		print("getCardType ArmyId:", armyId)
	else
		--副本战斗
		local armyIndex = FightMainLoop.getArmyIndex()
		armyId = FightModel.getArmyIdByIndex(armyIndex)
	end
	armyInfo      = DB_Army.getDataById(armyId)
	teamInfo      = DB_Team.getDataById(armyInfo.monster_group)
	--副本战斗
	local cardType = CardType.NORMAL
	if tonumber(self._hid) == tonumber(teamInfo.bossID) then
		cardType = CardType.BOSS
	elseif  tonumber(self._hid) == tonumber(teamInfo.outlineId) then
		cardType = CardType.GOD_BOSS
	elseif  tonumber(self._hid) == tonumber(teamInfo.demonLoadId) then
		cardType = CardType.BLACK_BOSS
	end
	return cardType
end

--[[
    @des:判断战斗中武将的神兵羁绊有木有开
    @parm:p_hid 武将hid
    @ret: true 开启 false 未开启
--]]
function FightHeroEntity:isOpenGodUnion()
    if not self._hid then
        return false
    end
    local unionInfo = GodWeaponItemUtil.unionInfoForFight(self._heroInfo)
    printTable("unionInfo", unionInfo)
    if not table.isEmpty(unionInfo) then
        return true
    else
        return false
    end
end

--[[
	@des:得到怒气头像
--]]
function FightHeroEntity:getRageHeadIconName()
	local dressId = self:getDressId()
	local modelId = self:getDBConfig().model_id
	local rageIconName = nil
	if dressId then
		local iconStr = DB_Item_dress.getDataById(dressId).changeRageHeadIcon
		local iconMap = string.split(iconStr, ",")
		for k,v in pairs(iconMap) do
			local nameMap 	= string.split(v, "|")
			local htid 		= nameMap[1]
			local iconName 	= nameMap[2]
			if tonumber(modelId) == tonumber(htid) then
				rageIconName = iconName
			end
		end
	end
	if not rageIconName then
		rageIconName = self:getDBConfig().rage_head_icon_id
	end
	return rageIconName
end

--[[
	@des:得到卡牌星级
	@ret:number
--]]
function FightHeroEntity:getStartLevel()
	local dbInfo = self:getDBConfig()
	return tonumber(dbInfo.star_lv)
end

--[[
	@des:得到卡牌位置编号
--]]
function FightHeroEntity:getPosNum()
	return tonumber(self._position)
end

--[[
	@des:设置卡牌位置编号
--]]
function FightHeroEntity:setPosNum( pNum )
	self._position = pNum
end

--[[
	@des:得到卡牌最大生命值
--]]
function FightHeroEntity:getMaxHp()
	return tonumber(self._heroInfo.maxHp) or 1000
end

--[[
	@des:得到初始血值
--]]
function FightHeroEntity:getInitHp()
	if self._heroInfo.currHp then
		return tonumber(self._heroInfo.currHp)
	else
		return self:getMaxHp()
	end
end

--[[
	@des:得到卡牌最大生命值
--]]
function FightHeroEntity:getRage()
	return tonumber(self._heroInfo.currRage) or 0
end

