-- @Author: xurui
-- @Date:   2020-02-12 14:18:52
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-29 15:39:31
local QExtraProp = class("QExtraProp")
local QActorProp = import(".QActorProp")

--[[
【注意！注意！注意！】在这里【新增】全局属性的人，一定要看！！
	这里新增全局属性（目前是1～8）都需要告诉后端，然后让后端去做战斗属性的校验，防止玩家擅自修改属性
]] 
--增加全局属性index需要更新 replay.proto 中的 extraProp 字段的注释，方便后端做战报校验
QExtraProp.HERO_SKIN_TEAM_PROP = 1     --皮肤全队属性
QExtraProp.FASHION_TEAM_PROP = 2       --時裝衣櫃全队属性
QExtraProp.SPAR_PROP = 3     		   --外骨全队属性
QExtraProp.MAGICHERB_PROP = 4     	   --仙品培育全队属性
QExtraProp.HANDBOOK_PROP = 5     	   --魂师图鉴全队属性
QExtraProp.HANDBOOK_BATTLE_PROP = 6    --魂师图鉴战斗属性（不计算战斗力，仅仅战斗中生效）
QExtraProp.GEMSTONE_SSP_PROP = 7       --SS+魂骨全局属性
QExtraProp.MOUNT_SSP_PROP = 8          --SS+暗器全局属性
--[[
【注意！注意！注意！】在这里【新增】全局属性的人，一定要看！！
	这里新增全局属性（目前是1～8）都需要告诉后端，然后让后端去做战斗属性的校验，防止玩家擅自修改属性
]] 
	
QExtraProp.EXTRAPROP_NAME = {
	"皮肤全队属性",
	"時裝衣櫃全队属性",
	"SS外骨全队属性",
	"仙品培育全队属性",
	"魂师图鉴全队属性",
	"图鉴战斗属性（不算战力）",
	"SS+魂骨全局属性",
	"SS+暗器全局属性"
}

--[[
【注意！注意！注意！】在这里【新增】全局属性的人，一定要看！！
	这里新增全局属性（目前是1～8）都需要告诉后端，然后让后端去做战斗属性的校验，防止玩家擅自修改属性
]] 
function QExtraProp:ctor()
	self._extraProp = {}  --存放计算之后的全局属性

	self:didappear()
end

function QExtraProp:didappear()
	self._extraProp = {}
	self._extraProp[self.HERO_SKIN_TEAM_PROP] = {}
	self._extraProp[self.FASHION_TEAM_PROP] = {}
	self._extraProp[self.SPAR_PROP] = {}
	self._extraProp[self.MAGICHERB_PROP] = {}
	self._extraProp[self.HANDBOOK_PROP] = {}
	self._extraProp[self.HANDBOOK_BATTLE_PROP] = {}
	self._extraProp[self.GEMSTONE_SSP_PROP] = {}
	self._extraProp[self.MOUNT_SSP_PROP] = {}
	if remote then
		self._heroSkinProxy = cc.EventProxy.new(remote.heroSkin)
		self._heroSkinProxy:addEventListener(remote.heroSkin.EVENT_HEROSKIN_UPDATE, handler(self, self._calculateHeroSkinTeamProp))

		self._fashionProxy = cc.EventProxy.new(remote.fashion)
		self._fashionProxy:addEventListener(remote.fashion.EVENT_EXTRAPROP_UPDATE, handler(self, self._calculateFashionTeamProp))

		self._sparProxy = cc.EventProxy.new(remote.spar)
		self._sparProxy:addEventListener(remote.spar.EVENT_SS_SPAR_UPDATE, handler(self, self._calculateSparTeamProp))

		self._magicHerbProxy = cc.EventProxy.new(remote.magicHerb)
		self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_MAGIC_HERB_TEAM_PROP_UPDATE, handler(self, self._calculateMagicHerbTeamProp))
		
		self._handBookProxy = cc.EventProxy.new(remote.handBook)
		self._handBookProxy:addEventListener(remote.handBook.EVENT_HANDBOOK_TEAM_PROP_UPDATE, handler(self, self._calculateHandbookTeamProp))

		self._gemstoenSspProxy = cc.EventProxy.new(remote.gemstone)
		self._gemstoenSspProxy:addEventListener(remote.gemstone.EVENT_EXTRAPROP_UPDATE, handler(self, self._calculateGemstoneTeamProp))

		self._mountSspProxy = cc.EventProxy.new(remote.mount)
		self._mountSspProxy:addEventListener(remote.mount.EVENT_SSRMOUNT_EXTRAPROP_UPDATE, handler(self, self._calculateMountTeamProp))

	end
end

function QExtraProp:disappear()
	self._extraProp = {}
	self._extraProp[self.HERO_SKIN_TEAM_PROP] = {}
	self._extraProp[self.FASHION_TEAM_PROP] = {}
	self._extraProp[self.SPAR_PROP] = {}
	self._extraProp[self.MAGICHERB_PROP] = {}
	self._extraProp[self.HANDBOOK_PROP] = {}
	self._extraProp[self.HANDBOOK_BATTLE_PROP] = {}
	self._extraProp[self.GEMSTONE_SSP_PROP] = {}
	self._extraProp[self.MOUNT_SSP_PROP] = {}

	if self._heroSkinProxy then
		self._heroSkinProxy:removeAllEventListeners()
		self._heroSkinProxy = nil
	end

	if self._fashionProxy then
		self._fashionProxy:removeAllEventListeners()
		self._fashionProxy = nil
	end
	
	if self._sparProxy then
		self._sparProxy:removeAllEventListeners()
		self._sparProxy = nil
	end
	if self._magicHerbProxy then
		self._magicHerbProxy:removeAllEventListeners()
		self._magicHerbProxy = nil
	end
	if self._handBookProxy then
		self._handBookProxy:removeAllEventListeners()
		self._handBookProxy = nil
	end

	if self._gemstoenSspProxy then
		self._gemstoenSspProxy:removeAllEventListeners()
		self._gemstoenSspProxy = nil
	end

	if self._mountSspProxy then
		self._mountSspProxy:removeAllEventListeners()
		self._mountSspProxy = nil
	end
end

function QExtraProp:isBattleProp(key)
	if tonumber(key) == self.HANDBOOK_BATTLE_PROP then
		return true
	end
	return false
end

function QExtraProp:getAllExtraProp()
	return self._extraProp or {}
end

function QExtraProp:getExtraPropByType(extraPropType)
	if extraPropType == nil then return {} end

	return self._extraProp[extraPropType] or {}
end

function QExtraProp:getSelfExtraProp()
	return self._extraProp or {}
end

function QExtraProp:getExtraPropByFighter(fighter)
	if q.isEmpty(fighter) then return {} end

	local props = {}

	props[self.HERO_SKIN_TEAM_PROP] = {}
	props[self.FASHION_TEAM_PROP] = {}
	props[self.SPAR_PROP] = {}
	props[self.MAGICHERB_PROP] = {}
	props[self.HANDBOOK_PROP] = {}
	props[self.HANDBOOK_BATTLE_PROP] = {}
	props[self.GEMSTONE_SSP_PROP] = {}
	props[self.MOUNT_SSP_PROP] = {}

	if fighter.heroSkins then
		props[self.HERO_SKIN_TEAM_PROP] = self:_calculateHeroSkinTeamProp({heroSkins = fighter.heroSkins})
	end

	-- 时装衣柜
	if fighter.attrList then
		props[self.FASHION_TEAM_PROP] = self:_calculateFashionTeamProp({skinWardrobe = fighter.attrList.skinWardrobeIds, skinPicture = fighter.attrList.skinPictureIds})
	end

	-- SS外骨
	if fighter.attrList and fighter.attrList.spars then
		props[self.SPAR_PROP] = self:_calculateSparTeamProp({sparList = fighter.attrList.spars})
		-- QKumo(props[self.SPAR_PROP])
	end
	-- QPrintTable(fighter.attrList.spars)

	-- 仙品培养
	if fighter.attrList and fighter.attrList.magicHerbs then
		-- QPrintTable(fighter.attrList.magicHerbs)
		props[self.MAGICHERB_PROP] = self:_calculateMagicHerbTeamProp({magicHerbList = fighter.attrList.magicHerbs})
		-- QKumo(props[self.MAGICHERB_PROP])
	end

	-- SS+魂骨
	if fighter.attrList and fighter.attrList.ssPlusGemstone then
		props[self.GEMSTONE_SSP_PROP] = self:_calculateGemstoneTeamProp({gemstoneList = fighter.attrList.ssPlusGemstone})
	end

	-- SS+暗器
	if fighter.attrList and fighter.attrList.ssPlusZuoqi then
		props[self.MOUNT_SSP_PROP] = self:_calculateMountTeamProp({mountList = fighter.attrList.ssPlusZuoqi})
	end

	-- 魂师图鉴
	if fighter.attrList then
		props[self.HANDBOOK_PROP], props[self.HANDBOOK_BATTLE_PROP] = self:_calculateHandbookTeamProp({heroHandbookList = fighter.attrList.heroHandbookList})
	end

	return props
end

------------------ 属性计算方法 ---------------------

--遍历属性计算到table中
function QExtraProp:_analysisProp(propTbl, info)
    local propFields = QActorProp:getPropFields()
	for name, filed in pairs(propFields) do
		if info[name] ~= nil then
			if propTbl[name] == nil then
				propTbl[name] = 0
			end
			propTbl[name] = info[name] + propTbl[name]		
		end
	end
end


--计算魂师皮肤全队属性
function QExtraProp:_calculateHeroSkinTeamProp(event)
	if event == nil then return {} end

	local heroSkins = event.heroSkins or {}
	local props = {}
	for _, value in pairs(heroSkins) do
		local config = db:getHeroSkinConfigByID(value.skinId)
		if q.isEmpty(config) == false then
	    	self:_analysisProp(props, config)
		end
	end
	if remote and event.name == remote.heroSkin.EVENT_HEROSKIN_UPDATE then
		self._extraProp[self.HERO_SKIN_TEAM_PROP] = props
	end
	
	return props
end

function QExtraProp:_calculateFashionTeamProp(event)
	if event == nil then return {} end

	local props = {}
	if event.skinWardrobe then
		local activedWardrobe = event.skinWardrobe
		local configs = db:getStaticByName("skins_wardrobe_prop")
		if q.isEmpty(configs) == false then
			for _, config in pairs(configs) do
				if q.isEmpty(config) == false then
					for _, id in pairs(activedWardrobe) do
						if tostring(id) == tostring(config.id) then
							-- 時裝寶籙，已經激活的，这里量表是覆盖型数值配表
							-- QKumo(config)
							self:_analysisProp(props, config)
						end
					end
				end
			end
		end
	end

	if event.skinPicture then
		local activedPicture = event.skinPicture
		local configs = db:getStaticByName("skins_combination_skills")
		if q.isEmpty(configs) == false then
			for _, config in pairs(configs) do
				if q.isEmpty(config) == false then
					for _, id in pairs(activedPicture) do
						-- 绘卷量表type为3（remote.fashion.TYPE_FOR_NOT_EXTRAPROP）的激活之后，生效的是单英雄属性，非全队属性，这里剔除（这条作废）
						-- 新规则，针对单独的字段剔除出来，目前仅enter_rage属性不添加
						if tostring(id) == tostring(config.id) then
							-- 羈絆繪卷，已經激活的
							-- QKumo(config)
							local _config = config
							if config["enter_rage"] then
								_config = clone(config)
								_config["enter_rage"] = nil
							end

							self:_analysisProp(props, _config)
						end
					end
				end
			end
		end
	end

	-- QKumo(props)
	if remote and event.name == remote.fashion.EVENT_EXTRAPROP_UPDATE then
		self._extraProp[self.FASHION_TEAM_PROP] = props
	end

	return props
end

-- --计算魂师装备传承魂灵全队属性
-- function QExtraProp:_calculateHeroSoulSpiritTeamProp(event)
-- 	if event == nil then return {} end

-- 	local soulSpiritList = event.soulSpiritList or {}
-- 	local props = {}
-- 	for _, value in pairs(soulSpiritList) do
-- 		local config = db:getSoulSpiritInheritConfig(value.devour_level , value.id)
-- 		if q.isEmpty(config) == false then
-- 	    	self:_analysisProp(props, config)
-- 		end
-- 	end
-- 	if remote and event.name == remote.soulSpirit.EVENT_WEAR_INHERIT_ONE then
-- 		self._extraProp[self.SOULSPIRIT_PROP] = props
-- 	end
	
-- 	return props
-- end


function QExtraProp:_calculateSparTeamProp(event)
	if event == nil then return {} end

	local props = {}
	local sparList = event.sparList or {}
    for _, spar in ipairs(sparList) do
	    --升星属性
		local gradeConfig = db:getGradeByHeroActorLevel(spar.itemId, spar.grade or 0)
		local num = spar.count or 1
		for i=1,num do
			self:_analysisProp(props, gradeConfig)
		end
    end
	if remote and event.name == remote.spar.EVENT_SS_SPAR_UPDATE then
		self._extraProp[self.SPAR_PROP] = props
	end

	return props
end


function QExtraProp:_calculateMagicHerbTeamProp(event)
	if event == nil then return {} end

	local props = {}
	local magicHerbList = event.magicHerbList or {}
	for _, magicHerb in pairs(magicHerbList) do
		local breedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(magicHerb.itemId, magicHerb.breedLevel or 0)
		if breedConfig then
			local num = magicHerb.count or 1
			for i=1,num do
				self:_analysisProp(props, breedConfig)
			end
		end
	end
	-- QKumo(props)
	if remote and event.name == remote.magicHerb.EVENT_MAGIC_HERB_TEAM_PROP_UPDATE then
		self._extraProp[self.MAGICHERB_PROP] = props
	end

	return props
end

function QExtraProp:_calculateGemstoneTeamProp(event)
	if event == nil then return {} end

	local props = {}
	local gemstoneList = event.gemstoneList or {}
	for _, gemstone in pairs(gemstoneList) do
		local refineConfig = db:getRefineConfigByIdAndLevel(gemstone.itemId, gemstone.refine_level or 0)
		if refineConfig then
			self:_analysisProp(props, refineConfig)
		end
		local mixConfig = db:getGemstoneMixConfigByIdAndLv(gemstone.itemId, gemstone.mix_level or 0)
		if mixConfig then
			self:_analysisProp(props, mixConfig)
		end

	end
	if remote and event.name == remote.gemstone.EVENT_EXTRAPROP_UPDATE then
		self._extraProp[self.GEMSTONE_SSP_PROP] = props
	end

	return props
end

--遍历暗器属性计算到table中
function QExtraProp:_analysisMountProp(propTbl, info)
    local propFields = QActorProp:getPropFields()
	for name, filed in pairs(propFields) do
		if info[name] ~= nil and filed.isAllTeam then
			if propTbl[name] == nil then
				propTbl[name] = 0
			end
			propTbl[name] = info[name] + propTbl[name]		
		end
	end
end

-- SS+暗器全局属性
function QExtraProp:_calculateMountTeamProp( event )
	if event == nil then return {} end
	local props = {}
	local mountList = event.mountList or {}
	for _,mountInfo in pairs(mountList) do
    	local gradeConfig = db:getGradeByHeroActorLevel(mountInfo.zuoqiId, mountInfo.grade)
    	if gradeConfig then
    		self:_analysisMountProp(props, gradeConfig)
    	end
    	local mountConfig = db:getCharacterByID(mountInfo.zuoqiId)
    	if q.isEmpty(mountConfig) == false then
    		--雕刻等级属性
			local graveLevelProp = remote.mount:getGraveInfoByAptitudeLv(mountConfig.aptitude,mountInfo.grave_level)
			if graveLevelProp then
				self:_analysisMountProp(props, graveLevelProp)
			end

    		-- 雕刻天赋
    		local graveMasterProp,graveMasterLevel = remote.mount:getGraveTalantMasterInfo(mountConfig.aptitude,mountInfo.grave_level)
 			for _,value in pairs(graveMasterProp or {}) do 
				self:_analysisMountProp(props, value)
			end
    	end
	end
	if remote and event.name == remote.mount.EVENT_SSRMOUNT_EXTRAPROP_UPDATE then
		self._extraProp[self.MOUNT_SSP_PROP] = props
	end
	return props
end

function QExtraProp:_calculateHandbookTeamProp(event)
	if event == nil then return {} end

	local props = {}
	local battleProps = {}
	local heroHandbookList = event.heroHandbookList or {}

    local handbookGradeConfig = db:getStaticByName("hero_handbook")
    local handbookBTConfig = db:getStaticByName("hero_handbook_jiexiantupo")
    local epicPropConfig = db:getStaticByName("hero_handbook_epic")

    local handbookEpicPoint = 0 -- 图鉴史诗点

	for _, handbookInfo in pairs(heroHandbookList) do
		local characterConfig = db:getCharacterByID(handbookInfo.actorId)
        local aptitude = characterConfig.aptitude

        -- 图鉴等级
        local curAptitudeHandbookGradeConfig = handbookGradeConfig[tostring(aptitude)]
        if not q.isEmpty(curAptitudeHandbookGradeConfig) then
            for _, config in pairs(curAptitudeHandbookGradeConfig) do
                if tonumber(config.handbook_level) == tonumber(handbookInfo.level) then
                    self:_analysisProp(props, config)
                    handbookEpicPoint = handbookEpicPoint + config.handbook_score
                elseif tonumber(config.handbook_level) < tonumber(handbookInfo.level) then
                	handbookEpicPoint = handbookEpicPoint + config.handbook_score
                end
            end
        end

        -- 图鉴突破
        local curAptitudeHandbookBTConfig = handbookBTConfig[tostring(aptitude)]
        if not q.isEmpty(curAptitudeHandbookBTConfig) then
            for _, config in pairs(curAptitudeHandbookBTConfig) do
                if tonumber(config.level) == tonumber(handbookInfo.breakthroughLevel) then
                    self:_analysisProp(props, config)
                end
            end
        end
	end

	-- 图鉴史诗
	local curEpicConfig = nil
   	for _, config in pairs(epicPropConfig) do
        if handbookEpicPoint >= config.handbook_score_num then
        	if not curEpicConfig then
        		curEpicConfig = config
        	else
        		if config.handbook_score_num > curEpicConfig.handbook_score_num then
        			curEpicConfig = config
        		end
        	end
        end
    end
    if curEpicConfig then
    	local tbl = {}
    	for key, value in pairs(curEpicConfig) do
    		if key == "physical_damage_percent_attack" or key == "magic_damage_percent_attack"
    		 		or key == "physical_damage_percent_beattack_reduce" or key == "magic_damage_percent_beattack_reduce" 
    		 		then
    		 	-- 主力属性（不加到全局属性里，战斗时候由战斗模块调用生效），pvp和pve都生效
    		 	battleProps[key] = (battleProps[key] or 0) + value
    		else
    			tbl[key] = (tbl[key] or 0) + value
    		end
    	end
    	self:_analysisProp(props, tbl)
    end

	-- QKumo(props)
	if remote and event.name == remote.handBook.EVENT_HANDBOOK_TEAM_PROP_UPDATE then
		self._extraProp[self.HANDBOOK_PROP] = props
		self._extraProp[self.HANDBOOK_BATTLE_PROP] = battleProps
	end

	return props, battleProps
end


return QExtraProp