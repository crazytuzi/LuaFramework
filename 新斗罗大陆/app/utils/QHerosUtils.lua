--
-- Author: Your Name
-- Date: 2014-06-16 18:08:30
-- 魂师数据处理以及缓存类 实例对象保存在remote中
--
local QBaseModel = import("..models.QBaseModel")
local QHerosUtils = class("QHerosUtils",QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QHeroModel = import("..models.QHeroModel")
local QUIHeroModel = import("..models.QUIHeroModel")
local QVIPUtil = import("..utils.QVIPUtil")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QActorProp = import("..models.QActorProp")
local QReplayUtil = import("..utils.QReplayUtil")

QHerosUtils.EVENT_HERO_PROP_UPDATE = "EVENT_HERO_PROP_UPDATE" 
QHerosUtils.EVENT_HERO_LEVEL_UPDATE = "EVENT_HERO_LEVEL_UPDATE"
QHerosUtils.EVENT_HERO_EXP_UPDATE = "EVENT_HERO_EXP_UPDATE"
QHerosUtils.EVENT_HERO_EQUIP_UPDATE = "EVENT_HERO_EQUIP_UPDATE"
QHerosUtils.EVENT_HERO_BREAK_BY_ONEKEY = "EVENT_HERO_BREAK_BY_ONEKEY"

QHerosUtils.EVENT_HERO_SPAR_INFO_UPDATE = "EVENT_HERO_SPAR_INFO_UPDATE"


QHerosUtils.EVENT_HERO_EXP_CHECK = "EVENT_HERO_EXP_CHECK"
QHerosUtils.EVENT_SAVE_STRENGTHEN_EXP = "EVENT_SAVE_STRENGTHEN_EXP"
QHerosUtils.EVENT_REFESH_BATTLE_FORCE = "EVENT_REFESH_BATTLE_FORCE"

QHerosUtils.TYPE_ALL = "TYPE_ALL"
QHerosUtils.TYPE_TANK = "TYPE_TANK"
QHerosUtils.TYPE_TREAMENT = "TYPE_TREAMENT"
QHerosUtils.TYPE_CONTENTATTACH = "TYPE_CONTENTATTACH"
QHerosUtils.TYPE_MAGICATTACH = "TYPE_MAGICATTACH"

QHerosUtils.BATTLEFORCE_UPDATE = "BATTLEFORCE_UPDATE"

-- 键 表中配置的检查魂师是否所需 TopN中的基数
QHerosUtils.CONFIGURATION_CHECK_NEED_HERO_BASE = "CHECK_NEED_HERO_BASE"

function QHerosUtils:ctor(options)
	QHerosUtils.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.heros = {}
	self.herosRefineInfo = {} -- 为洗炼专门保留的部分属性
	self._heroProp = {}
	self.oldHeros = {}
	self._uiHeros = {}
	self._keyHeros = {}
	self._keyHaveHeros = {}
	self._attribute = {}
	self._equipment = {}
	self._advancePoint = 0
	self._glyphTeamInfo = {}
	self._godarmTeamProp = {}
end

function QHerosUtils:didappear()
	self._itemProxy = cc.EventProxy.new(remote.items)
	self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.itemsUpdateEventHandler))
	self._gemstoneProxy = cc.EventProxy.new(remote.gemstone)
	self._gemstoneProxy:addEventListener(remote.gemstone.EVENT_UPDATE, handler(self, self.gemstoneUpdateEventHandler))
	self._gemstoneProxy:addEventListener(remote.gemstone.EVENT_SSPLUS_UPDATE, handler(self, self.gemstoneSSPUpdateEventHandler))
	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(remote.DUNGEON_UPDATE_EVENT, handler(self, self.itemsUpdateEventHandler))
	self._userProxy = cc.EventProxy.new(remote.user)
	self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.userUpdateEventHandler))
	self._dragonTotemProxy = cc.EventProxy.new(remote.dragonTotem)
	self._dragonTotemProxy:addEventListener(remote.dragonTotem.EVENT_TOTEM_UPDATE, handler(self, self.dragonTotemUpdateEventHandler))
	self._sparProxy = cc.EventProxy.new(remote.spar)
	self._sparProxy:addEventListener(remote.spar.EVENT_SPAR_UPDATE, handler(self, self.sparUpdateEventHandler))
	self._sparProxy:addEventListener(remote.spar.EVENT_SS_SPAR_UPDATE_HERO, handler(self, self.sparSSUpdateEventHandler))	--获得ss外骨刷新全局属性

	self._mountProxy = cc.EventProxy.new(remote.mount)
	self._mountProxy:addEventListener(remote.mount.EVENT_SSRMOUNT_EXTRAPROP_UPDATE_HERO, handler(self, self.mountSSRUpdateEventHandler))	--获得ss+暗器刷新全局属性

	self._soulTrialProxy = cc.EventProxy.new(remote.soulTrial)
	self._soulTrialProxy:addEventListener(remote.soulTrial.EVENT_SOULTRIAL_UPDATE, handler(self, self.soulTrialUpdateEventHandler))
	self._headPropProxy = cc.EventProxy.new(remote.headProp)
	self._headPropProxy:addEventListener(remote.headProp.HEAD_UNLOCK_UPDATE, handler(self, self.avatarUpdateEventHandler))
	self._magicHerbProxy = cc.EventProxy.new(remote.magicHerb)
	self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_REFRESH_MAGIC_HERB, handler(self, self.magicHerbUpdateEventHandler))
	self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_SS_MAGIC_HERB_UPDATE_HERO, handler(self, self.magicHerbSSUpdateEventHandler))

	self._handbookProxy = cc.EventProxy.new(remote.handBook)
	self._handbookProxy:addEventListener(remote.handBook.EVENT_HANDBOOK_TEAM_PROP_UPDATE_HERO, handler(self, self.handbookUpdateEventHandler))

	self._soulSpiritProxy = cc.EventProxy.new(remote.soulSpirit)
	self._soulSpiritProxy:addEventListener(remote.soulSpirit.EVENT_REFRESH_SOUL_SPIRIT, handler(self, self.soulSpiritUpdateEventHandler))
	self._mountProxy = cc.EventProxy.new(remote.mount)
	self._mountProxy:addEventListener(remote.mount.EVENT_REFRESH_FORCE, handler(self, self.mountUpdateEventHandler))

	self._fashionProxy = cc.EventProxy.new(remote.fashion)
	self._fashionProxy:addEventListener(remote.fashion.EVENT_REFRESH_FORCE, handler(self, self.updateHerosEventHandler))


	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_SKILL_CHANGE, self.unionSkillUpdateEventHandler, self)
end

function QHerosUtils:disappear()
	if self._itemProxy then
		self._itemProxy:removeAllEventListeners()
	end
	if self._gemstoneProxy then
		self._gemstoneProxy:removeAllEventListeners()
	end
	if self._remoteProxy then
		self._remoteProxy:removeAllEventListeners()
	end
	if self._userProxy then
		self._userProxy:removeAllEventListeners()
	end
	if self._dragonTotemProxy then
		self._dragonTotemProxy:removeAllEventListeners()
	end
	if self._sparProxy then
		self._sparProxy:removeAllEventListeners()
	end
	if self._soulTrialProxy then
		self._soulTrialProxy:removeAllEventListeners()
	end
	if self._headPropProxy then
		self._headPropProxy:removeAllEventListeners()
	end
	if self._magicHerbProxy then
		self._magicHerbProxy:removeAllEventListeners()
	end
	if self._soulSpiritProxy then
		self._soulSpiritProxy:removeAllEventListeners()
	end
	if self._mountProxy then
		self._mountProxy:removeAllEventListeners()
	end
	if self._handbookProxy then
		self._handbookProxy:removeAllEventListeners()
	end

	if self._mountProxy then
		self._mountProxy:removeAllEventListeners()
	end

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_SKILL_CHANGE, self.unionSkillUpdateEventHandler, self)
end

--重新计算魂师装备信息
function QHerosUtils:itemsUpdateEventHandler()
	local isUpdate = false
	for _,uiModel in pairs(self._uiHeros) do
		isUpdate = uiModel:heroBreakHandler()
		uiModel:initGemstone()
		uiModel:initMount()
		uiModel:initArtifact()
		uiModel:initSpar()
		uiModel:initSoulSpirit()
		-- if isUpdate then
		self:dispatchEvent({name = QHerosUtils.EVENT_HERO_EQUIP_UPDATE, actorId = uiModel._heroInfo.actorId})
		-- end
	end
end

--重新计算魂师宝石信息
function QHerosUtils:gemstoneUpdateEventHandler()
	for _,uiModel in pairs(self._uiHeros) do
		uiModel:initGemstone()
		self:dispatchEvent({name = QHerosUtils.EVENT_HERO_EQUIP_UPDATE, actorId = uiModel._heroInfo.actorId})
	end
end

--重新计算魂师装备信息
function QHerosUtils:userUpdateEventHandler()
	for _,uiModel in pairs(self._uiHeros) do
		uiModel:heroBreakHandler(uiModel.SPEICAL_UPDATE)
	end
end

--图腾信息刷新
function QHerosUtils:dragonTotemUpdateEventHandler()
	self:validate()
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--[[
	考古信息刷新
]]
function QHerosUtils:archaeologyUpdateEventHandler()
	-- 在更新整个self.heros之前验证一下，防止被修改的内存被“洗白”
	self:validate()
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--[[
	宗门技能信息
]]
function QHerosUtils:unionSkillUpdateEventHandler()
	-- 在更新整个self.heros之前验证一下，防止被修改的内存被“洗白”
	self:validate()
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--[[
	Author: xurui
	头像框信息刷新
]]
function QHerosUtils:avatarUpdateEventHandler()
	-- 在更新整个self.heros之前验证一下，防止被修改的内存被“洗白”
	self:validate()
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--[[
	Author: xurui
	魂灵图鉴信息刷新
]]
function QHerosUtils:soulSpiritUpdateEventHandler()
	-- 在更新整个self.heros之前验证一下，防止被修改的内存被“洗白”
	self:validate()
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

function QHerosUtils:mountUpdateEventHandler()
	-- 在更新整个self.heros之前验证一下，防止被修改的内存被“洗白”
	self:validate()
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

function QHerosUtils:updateHerosEventHandler()
	-- 在更新整个self.heros之前验证一下，防止被修改的内存被“洗白”
	self:validate()
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--魂力试炼刷新
function QHerosUtils:soulTrialUpdateEventHandler()
	self:validate()
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--重新计算魂师晶石信息
function QHerosUtils:sparUpdateEventHandler()
	local isUpdate = false
	for _,uiModel in pairs(self._uiHeros) do
		uiModel:initSpar()
		self:dispatchEvent({name = QHerosUtils.EVENT_HERO_EQUIP_UPDATE, actorId = uiModel._heroInfo.actorId})
	end
	self:dispatchEvent({name = QHerosUtils.EVENT_HERO_SPAR_INFO_UPDATE})

end

--ss外骨刷新重置魂师全局属性
function QHerosUtils:sparSSUpdateEventHandler()
	self:validate()
	-- self:updateHeros(self.heros)
	--只更新魂师属性不刷新其他
	print("sparSSUpdateEventHandler")
	self:updateHerosProps(self.heros)	
end

--ss+暗器刷新重置魂师全局属性
function QHerosUtils:mountSSRUpdateEventHandler( )
	self:validate()
	print("mountSSRUpdateEventHandler")
	self:updateHerosProps(self.heros)
end
--ss外骨刷新重置魂师全局属性
function QHerosUtils:gemstoneSSPUpdateEventHandler()
	self:validate()
	-- self:updateHeros(self.heros)
	--只更新魂师属性不刷新其他
	print("gemstoneSSPUpdateEventHandler")
	self:updateHerosProps(self.heros)	
end

--ss仙品刷新重置魂师全局属性
function QHerosUtils:magicHerbSSUpdateEventHandler()
	self:validate()
	print("magicHerbSSUpdateEventHandler")
	self:updateHerosProps(self.heros)
end

function QHerosUtils:handbookUpdateEventHandler()
	self:validate()
	print("handbookUpdateEventHandler")
	self:updateHerosProps(self.heros)
end


--重新计算魂师仙品信息
function QHerosUtils:magicHerbUpdateEventHandler()
	local isUpdate = false
	for _,uiModel in pairs(self._uiHeros) do
		uiModel:initMagicHerb()
		self:dispatchEvent({name = QHerosUtils.EVENT_HERO_EQUIP_UPDATE, actorId = uiModel._heroInfo.actorId})
	end
end

--[[
	从配置中读取所有魂师
]]
function QHerosUtils:initHero()
	if #self._keyHeros == 0 then
		local herosConfig = QStaticDatabase:sharedDatabase():getCharacter() or {}
		for _,value in pairs(herosConfig) do
			if value.npc_type == NPC_TYPE.HERO then
				local grade_info = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(value.id, 0)
				if grade_info ~= nil then
					table.insert(self._keyHeros, value.id)
				else
					printInfo("actorId: "..value.id.." garde config is nil!!!")
				end
			end
		end
	end
	-- part 3: sort not be summoned heros
	table.sort(self._keyHeros, function(actorId1, actorId2)
		local characher1 = QStaticDatabase:sharedDatabase():getCharacterByID(actorId1)
		local grade_info1 = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(actorId1, characher1.grade or 0)
		if grade_info1 == nil then
			printInfo("grade_info1："..actorId1)
		end
		local soulGemId1 = grade_info1.soul_gem
		local currentGemCount1 = remote.items:getItemsNumByID(soulGemId1)
		local needGemCount1 = QStaticDatabase:sharedDatabase():getNeedSoulByHeroActorLevel(actorId1, characher1.grade or 0)

		local characher2 = QStaticDatabase:sharedDatabase():getCharacterByID(actorId2)
		local grade_info2 = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(actorId2, characher2.grade or 0)
		if grade_info2 == nil then
			printInfo("grade_info2："..actorId2)
		end
		local soulGemId2 = grade_info2.soul_gem
		local currentGemCount2 = remote.items:getItemsNumByID(soulGemId2)
		local needGemCount2 = QStaticDatabase:sharedDatabase():getNeedSoulByHeroActorLevel(actorId2, characher2.grade or 0)

		if currentGemCount1 > 0 and currentGemCount2 == 0 then
			return true
		elseif currentGemCount1 == 0 and currentGemCount2 > 0 then
			return false
		else
			if needGemCount1 < needGemCount2 then
				return true
			elseif needGemCount1 > needGemCount2 then
				return false
			else
				if currentGemCount1 > currentGemCount2 then
					return true
				elseif currentGemCount1 < currentGemCount2 then
					return false
				else
					if soulGemId1 < soulGemId2 then
						return true
					elseif soulGemId1 > soulGemId2 then
						return false
					else
						if actorId1 < actorId2 then
							return true
						else
							return false
						end
					end
				end
			end
		end
    end )
	self:initHeroEquipment()
end

--区分装备是否是饰品
function QHerosUtils:initHeroEquipment()
	local breakthrough = QStaticDatabase:sharedDatabase():getBreakthrough()
	for key,heroBreak in pairs(breakthrough) do
		self._equipment[key] = {}
		for _,value in ipairs(heroBreak) do
			value = q.cloneShrinkedObject(value)
			for _,pos in pairs(EQUIPMENT_TYPE) do
				self._equipment[key][value[pos]] = {pos = pos, breakInfo = value}
			end
		end
	end
end

--更新魂师
function QHerosUtils:updateHeros(heros, isServer)
	self._maxHerosInfos = nil
	self._localMaxHeroInfos = nil
	self:addPeripheralSkills(heros)
	self:addArchaeologyProp(heros)
	self:addSoulTrialProp(heros)
	self:addUnionSkillProp(heros)
	self:addHeadListProp(heros)
	self:addDragonTotemProp(heros)
	self:addSoulSpiritCombinationProp(heros)
	self:addSoulSpiritOccultProp(heros,true)
	self:addMountReformTeamProp(heros)
	self:addGodarmReformTeamProp(heros)

    for _,value in pairs(heros) do
    	self.oldHeros[value.actorId] = self.heros[value.actorId]
        self.heros[value.actorId] = value

        -- 专门为了洗炼特别保留一份属性
        if value.refineHeroInfo then
        	if not self.herosRefineInfo[tonumber(value.actorId)] then
        		self.herosRefineInfo[tonumber(value.actorId)] = {}
        	end

        	if value.refineHeroInfo.openGrid then
        		self.herosRefineInfo[tonumber(value.actorId)]["openGrid"] = value.refineHeroInfo.openGrid
        	end

        	if value.refineHeroInfo.refineAttrsPre then
        		self.herosRefineInfo[tonumber(value.actorId)]["refineAttrsPre"] = value.refineHeroInfo.refineAttrsPre
        	end

        	if value.refineHeroInfo.refineMoneyConsume then
        		self.herosRefineInfo[tonumber(value.actorId)]["refineMoneyConsume"] = value.refineHeroInfo.refineMoneyConsume
        	end
        end

    end

	self:addAttrListProp(heros)

	self:addCombinationProp(heros)
	self:addGlyphTeamProp(self.heros)
	self:addMountCombinationProp(self.heros)

	for _,value in pairs(heros) do
		if self._uiHeros[value.actorId] == nil then
			self._uiHeros[value.actorId] = QUIHeroModel.new({heroInfo = value})
		else
			self._uiHeros[value.actorId]:updateInfo(value)
		end
		self:createHeroProp(value, true)
		-- if app:hasObject(value.actorId) == true then
		-- 	app:setObject(value.actorId,QHeroModel.new(value))
		-- end
	end
	self._oldKeyHaveHeros = self._keyHaveHeros
	self._keyHaveHeros = {}
	for _,value in pairs(self.heros) do
		table.insert(self._keyHaveHeros, value.actorId)
	end
  	self:sortHero()
  	if isServer == true then
  		self:setAdvancePoint(0)
  	end

  	-- nzhang: 任何导致self.heros有任何一点点变动，都必须重新调用self:_updateValidation()
	self:_updateValidation()
end


function QHerosUtils:updateHerosProps(heros)
	self:addAttrListProp(heros)

	for _,value in pairs(heros) do
		if self._uiHeros[value.actorId] == nil then
			self._uiHeros[value.actorId] = QUIHeroModel.new({heroInfo = value})
		else
			self._uiHeros[value.actorId]:updateInfo(value)
		end
		self:createHeroProp(value, true)
		-- if app:hasObject(value.actorId) == true then
		-- 	app:setObject(value.actorId,QHeroModel.new(value))
		-- end
	end
	self:sortHero()
  	-- nzhang: 任何导致self.heros有任何一点点变动，都必须重新调用self:_updateValidation()
	self:_updateValidation()
end


--xurui
--更新全队体技信息
function QHerosUtils:updateGlyphTeamInfo(glyphsInfo)
	if next(self._glyphTeamInfo) == nil then
		self._glyphTeamInfo = glyphsInfo
	else
		local deleteFunc
		deleteFunc = function(glyphs) 
			for i = 1, #self._glyphTeamInfo do
				if glyphs.actorId == self._glyphTeamInfo[i].actorId and glyphs.glyphId == self._glyphTeamInfo[i].glyphId and 
					glyphs.glyphLevel == self._glyphTeamInfo[i].glyphLevel then
					table.remove(self._glyphTeamInfo, i)
					break
				end
			end
		end

		local modifyFunc
		modifyFunc = function(glyphs) 
			for i = 1, #self._glyphTeamInfo do
				if glyphs.actorId == self._glyphTeamInfo[i].actorId and glyphs.glyphId == self._glyphTeamInfo[i].glyphId then
					self._glyphTeamInfo[i] = glyphs
					return 
				end
			end
			self._glyphTeamInfo[#self._glyphTeamInfo+1] = glyphs
		end

		for i = 1, #glyphsInfo do 
			if glyphsInfo[i].type == "DELETE" then   -- type == "MODIFY" 时添加或更新, type == "DELETE" 时删除 
				deleteFunc(glyphsInfo[i])
			else
				modifyFunc(glyphsInfo[i])
			end
		end
	end

	-- 当雕纹信息更新的时候，移除所有的 heroModel ,重新刷新魂师属性
	self:removeAllHeroProp()
	-- for _,value in pairs(self.heros) do
	-- 	if app:hasObject(value.actorId) == true then
	-- 		app:removeObject(value.actorId)
	-- 	end
	-- end
end

-- 暗器图鉴属性更新
function QHerosUtils:updataMountCombinationProp()
	-- 当雕纹信息更新的时候，移除所有的 heroModel ,重新刷新魂师属性
	self:removeAllHeroProp()
	-- for _,value in pairs(self.heros) do
	-- 	if app:hasObject(value.actorId) == true then
	-- 		app:removeObject(value.actorId)
	-- 	end
	-- end
end

--创建heromodel通过actorid 只能创建自己的魂师对象
function QHerosUtils:createSelfHeroByActorId(actorId)
	local heroInfo = self:getHeroByID(actorId)
	if heroInfo ~= nil then
		local additionalInfos = QReplayUtil:getSelfAdditionalInfos()
        local actor = app:createHeroWithoutCache(heroInfo, nil, additionalInfos)
		return actor
	end
end

--更新魂师战力
function QHerosUtils:updateHerosForce(heroForceModifies)
	for _,value in ipairs(heroForceModifies) do
        if self.heros[value.actorId] ~= nil then
        	self.heros[value.actorId].force = value.force 
    	end
	end
  	-- nzhang: 任何导致self.heros有任何一点点变动，都必须重新调用self:_updateValidation()
	self:_updateValidation()
end

--更新校验. 任何导致self.heros有任何一点点变动，都必须重新调用self:_updateValidation()
function QHerosUtils:_updateValidation()
	if ENABLE_QHEROSUTILS_VALIDATION then
		self.herosValidation = q.createValidationForTable(self.heros)
	end
end

--检查校验
function QHerosUtils:validate()
	if ENABLE_QHEROSUTILS_VALIDATION then
		q.validateForTable(self.heros, self.herosValidation)
	end
end

--解锁饰品时添加装备
function QHerosUtils:unlockBadge()
	-- 在更新整个self.heros之前验证一下，防止被修改的内存被“洗白”
	self:validate()

	for _,uiModel in pairs(self._uiHeros) do
		uiModel:unlockBadge()
	end
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--解锁纹章时添加装备
function QHerosUtils:unlockGad()
	-- 在更新整个self.heros之前验证一下，防止被修改的内存被“洗白”
	self:validate()

	for _,uiModel in pairs(self._uiHeros) do
		uiModel:unlockGad()
	end
	self:updateHeros(self.heros)
	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--[[
	@wkwang
	增加考古属性到heroinfo中
]]
function QHerosUtils:addArchaeologyProp(heros)
    local archaeologyProp = {}
	if remote.user.ArchaeologyId ~= nil then
		archaeologyProp = getArchaeologyPropByFragmentID(remote.user.ArchaeologyId)
	end
	for _, hero in pairs(heros) do
		hero.archaeologyProp = archaeologyProp
	end
end


--[[
	@Kumo.Wang
	增加魂靈圖鑒属性到heroinfo中
]]
function QHerosUtils:addSoulSpiritCombinationProp(heros)
	local soulSpiritCombinationProp = {}
	if remote.soulSpirit:checkSoulSpiritUnlock() then
		local soulSpiritHandBookInfoList = remote.soulSpirit:getMySoulSpiritHandBookInfoList()
		soulSpiritCombinationProp = db:calculateSoulSpiritCombinationProp(soulSpiritHandBookInfoList)
	end
	for _, hero in pairs(heros) do
		hero.soulSpiritCombinationProp = soulSpiritCombinationProp
	end
end

function QHerosUtils:addSoulSpiritOccultProp( heros,isMyself,occultMap)
	local allChildConfig = {}
	local soulFireMap = {}
	if remote.soulSpirit:checkSoulSpiritUnlock() then
	    -- 魂火属性
	    -- local soulFireMap = {}
	    if isMyself then
	    	soulFireMap= remote.soulSpirit:getSoulSpritOccultMapInfo() or {}
	    else
	    	soulFireMap = occultMap or {}
	    end

     --    for _,mapInfo in pairs(soulFireMap) do
     --        for _,detailInfo in pairs(mapInfo.detailInfo) do
     --        	local childConfig = db:getChildSoulFireInfo(mapInfo.mapId,detailInfo.bigPointId,detailInfo.smallPointId)
     --        	if childConfig then
     --            	table.insert(allChildConfig,childConfig) 
     --            end
     --        end
    	-- end
	end
	
	for _, hero in pairs(heros) do
		if hero.soulSpirit then
			hero.soulSpirit.soulSpiritMapInfo = soulFireMap
		end
	end
end

--[[
	@Kumo
	增加魂力试炼属性到heroinfo中
]]
function QHerosUtils:addSoulTrialProp(heros)
	if not heros and self.heros then
		heros = self.heros
	end
	
    local soulTrialProp = remote.soulTrial:getSoulTrialProp()
	for _, hero in pairs(heros) do
		hero.soulTrialProp = soulTrialProp
	end
end

--[[
	@wkwang
	增加宗门技能
]]
function QHerosUtils:addUnionSkillProp(heros)
    local unionSkillProp = {}
	-- if remote.user.ArchaeologyId ~= nil then
	-- 	unionSkillProp = getArchaeologyPropByFragmentID(remote.user.ArchaeologyId)
	-- end

	for _, hero in pairs(heros) do
		hero.unionSkillProp = remote.union:getUnionSkillProp()
	end
end

--[[
	Author: zxs  
	Date: 2018-1-6
	增加头像属性到heroinfo中
]]
function QHerosUtils:addHeadListProp(heros)
   	local userTitle = remote.headProp:getHeadList()
    local headProp = db:calculateAvatarProp(remote.user.avatar, remote.user.title, userTitle)  
	for _, hero in pairs(heros) do
		hero.headProp = headProp
	end
end

--[[
	Author: zxs  
	Date: 2018-1-6
	增加全局属性到heroinfo中
]]
function QHerosUtils:addAttrListProp(heros)
	local attrListProp = {}
	local soulGuidProp = db:calculateSoulGuideLevelProp(remote.user.soulGuideLevel or 0)
    QActorProp:getPropByConfig(soulGuidProp, attrListProp)
    
    --改造属性
	for _, hero in pairs(self.heros) do
    	local mountInfo = hero.zuoqi
    	if mountInfo and mountInfo.reformLevel and mountInfo.reformLevel > 0 then
	    	local mountConfig = db:getCharacterByID(mountInfo.zuoqiId)
			local refromProp = db:getReformConfigByAptitudeAndLevel(mountConfig.aptitude, mountInfo.reformLevel) or {}
	    	QActorProp:getPropByConfig(refromProp, attrListProp)
	    end
    end

	for _, hero in pairs(heros) do
		hero.attrListProp = attrListProp
	end
end

--[[
	Author: wk
	Date:2017-2-9
	增加图腾属性到魂师中
]]
function QHerosUtils:addDragonTotemProp(heros)
	local totemInfos = {}
    if remote.dragonTotem:checkTotemUnlock() then
    	for i=1,7 do
    		local info = remote.dragonTotem:getDragonInfoById(i)
    		if info == nil then
    			info = {dragonDesignId = i, grade = 1}
    		end
    		table.insert(totemInfos, info)
    	end
	end
	for _, hero in pairs(heros) do
		hero.totemInfos = totemInfos
	end
end

--[[
	Aurhor: xurui
	Date: 2016-5-14
	增加组合属性到heroinfo中
]]
function QHerosUtils:addCombinationProp(heros) 
	for _, hero in pairs(heros) do
		hero.combinationProp = self:countHeroCombinationProp(hero.actorId)
	end
end

--[[
	Aurhor: xurui
	Date: 2016-8-25
	增加体技全队属性到heroinfo中
]]
function QHerosUtils:addGlyphTeamProp(heros) 
	for _, hero in pairs(heros) do
		hero.teamGlyphInfo = self._glyphTeamInfo or {}
	end
end

--[[
	Aurhor: xurui
	Date: 2016-8-25
	增加暗器图鉴全队属性到heroinfo中
]]
function QHerosUtils:addMountCombinationProp(heros) 
	for _, hero in pairs(heros) do
		local mountCombinationProp = db:calculateMountCombinationProp(remote.user.collectedZuoqis)
		hero.mountCombinationProp = mountCombinationProp
	end
end

--[[
	Aurhor: zxs
	Date: 2019-1-17
	增加暗器改造全队属性到heroinfo中
]]
function QHerosUtils:addMountReformTeamProp(heros)
	local mountReformProp = {}
	for _, hero in pairs(heros) do
		if hero.zuoqi and hero.zuoqi.reformLevel and hero.zuoqi.reformLevel > 0 then
			local mountConfig = db:getCharacterByID(hero.zuoqi.zuoqiId)
			local refromProp = db:getReformConfigByAptitudeAndLevel(mountConfig.aptitude, hero.zuoqi.reformLevel) or {}
    		QActorProp:getPropByConfig(refromProp, mountReformProp)
    	end
	end
	for _, hero in pairs(heros) do
		hero.mountReformProp = mountReformProp
	end
end

--[[
	Author: mousecute
	Date: Sep-2-2016
	返回雕纹全堆属性
]]
function QHerosUtils:getGlyphTeamProp()
	return self._glyphTeamInfo or {}
end

--[[
	@lxb
	增加神器属性到heroinfo中
]]
function QHerosUtils:addGodarmReformTeamProp(heros)
	local godarmReformProp = {}
	if remote.godarm:checkGodArmUnlock() then
    	local haveGodarmList = remote.godarm:getHaveGodarmList() or {}
    	godarmReformProp = db:getGodArmPropByList(haveGodarmList)
		self._godarmTeamProp = godarmReformProp
		for _, hero in pairs(heros) do
			hero.godarmReformProp = godarmReformProp
		end
	end

end

function QHerosUtils:getGodarmReformProp()
	return self._godarmTeamProp or {}
end

-- @qinyuanji
-- Some equipment enchant may attach new skill to hero
-- Check every equipment on hero to know if it has skill attached
-- Compare with hero's native skills to see if it matches and higher, then replace it
-- If not found, add it to peripheralSkills structure
function QHerosUtils:addPeripheralSkills(heros)
	if heros == nil then return end
	local index= 1
	for _, hero in pairs(heros) do
		index = index + 1
		local peripheralSkills = {}
		local db = QStaticDatabase:sharedDatabase()
		for _, equipment in ipairs(hero.equipments or {}) do
			if equipment.enchants and equipment.enchants > 0 then
				local peripheralSkill = db:getEnchantSkill(equipment.itemId, equipment.enchants, hero.actorId)
				if peripheralSkill then
					peripheralSkill = string.split(peripheralSkill,";")
					for _,skillStr in ipairs(peripheralSkill) do
						local skills = string.split(skillStr, ":")
						table.insert(peripheralSkills, {id = tonumber(skills[1]), level = tonumber(skills[2])})
					end
					-- nzhang: since proto2 does not support map struction, i make peripheralSkills an array
				end
			end
		end
		hero.peripheralSkills = peripheralSkills
	end
end

function QHerosUtils:removeHeroes(heroes)
	self._maxHerosInfos = nil
	self._localMaxHeroInfos = nil
	for k, value in pairs(heroes) do
		-- if app:hasObject(k) == true then
		-- 	app:removeObject(k)
		-- end
		self:removeAllHeroProp()
		if self.heros[value] then
			self.heros[value] = nil 
		end
		if self._uiHeros[value] then 
			self._uiHeros[value] = nil
		end
	end
	self:_updateValidation()
	self._keyHaveHeros = {}
	for _,value in pairs(self.heros) do
		table.insert(self._keyHaveHeros, value.actorId)
	end
  	self:sortHero()
end

-- 用于查看玩家信息所以保留的临时数据
------- temp hero ----------
function QHerosUtils:cleanTempHeros(isTemp)
	self._isTemp = isTemp or false
	self._tempHeros = {}
	self._tempUIHeros = {}
end

function QHerosUtils:setTempHeroByID(heroInfo)
	if not heroInfo then return end
	self._tempHeros[heroInfo.actorId] = heroInfo
	self._tempUIHeros[heroInfo.actorId] = QUIHeroModel.new({heroInfo = heroInfo})
end

------- temp hero ----------
function QHerosUtils:getHeroByID(actorId)
    if self._isTemp then
    	return self._tempHeros[tonumber(actorId)]
    else
		return self.heros[tonumber(actorId)]
	end
end

function QHerosUtils:getHeroRefineInfoByID(actorId)
	QPrintTable(self.herosRefineInfo)
	return self.herosRefineInfo[tonumber(actorId)]
end

function QHerosUtils:getOldHeroById(actorId)
	return self.oldHeros[actorId]
end

function QHerosUtils:getUIHeroByID(actorId)
	if self._isTemp then
    	return self._tempUIHeros[tonumber(actorId)]
    else
		return self._uiHeros[tonumber(actorId)]
	end
end

function QHerosUtils:getHeroesSortByLevel(max)
	local count = 0
	local heroes = {}
	for _, value in pairs(self.heros) do
		heroes[#heroes + 1] = value
	end
	table.sort(heroes, function(h1, h2)
		if h1.level == h2.level then
			return h1.actorId > h2.actorId
		else
			return h1.level > h2.level
		end
	end)
	for i = max + 1, #heroes do
		heroes[i] = nil
	end
	for i = 1, #heroes do
		local hero = heroes[i]
		heroes[i] = nil
		heroes[hero.actorId] = hero.actorId
	end
	return heroes
end

--获取所有的魂师ID
function QHerosUtils:getHerosKey()
	local tbl = {}
	for _, actorId in ipairs(self._keyHeros) do
		if not db:checkHeroShields(actorId) then
			table.insert(tbl, actorId)
		end
	end
	return tbl
end

--获取所有的魂师ID（已拥有的和有灵魂石还未召唤的），但是不包括character.hero_show ~= 1（除非意外获得了，比如gm后台或者别的什么途径）的魂师（魂师暂时不开启）
function QHerosUtils:getShowHerosKey()
	local tbl = {}
	local db = QStaticDatabase:sharedDatabase()
	for _,actorId in pairs(self._keyHeros) do
		local heroInfo = self:getHeroByID(actorId)
		if heroInfo ~= nil then
			table.insert(tbl, actorId)
		else
			if db:getCharacterByID(actorId).hero_show == 1 and not db:checkHeroShields(actorId) then
				local grade_info = db:getGradeByHeroActorLevel(actorId, 0)
				local soulGemId = grade_info.soul_gem
				local currentGemCount = remote.items:getItemsNumByID(soulGemId)
				table.insert(tbl, actorId)
			end
		end
	end
	return tbl
end

--获取已经拥有的魂师ID
function QHerosUtils:getHaveHero(level)
	local heroKeys = {}
	if level == nil then level = 0 end
	for _,actorId in pairs(self._keyHaveHeros) do
		local heroInfo = self:getHeroByID(actorId)
		if heroInfo ~= nil and heroInfo.level >= level then
			table.insert(heroKeys, actorId)
		end
	end
	return heroKeys
end

--获取已经拥有的SS魂师ID
function QHerosUtils:getHaveSuperHero(level)
	local heroKeys = {}
	if level == nil then level = 0 end
	for _,actorId in pairs(self._keyHaveHeros) do
		local heroInfo = self:getHeroByID(actorId)
		if heroInfo and heroInfo.godSkillGrade > 0 and heroInfo.level >= level then
			table.insert(heroKeys, actorId)
		end
	end
	return heroKeys
end

--获取上一次updatHeros之前拥有的魂师ID
function QHerosUtils:getOldHaveHero(level)
	local heroKeys = {}
	if level == nil then level = 0 end
	for _,actorId in pairs(self._oldKeyHaveHeros) do
		local heroInfo = self:getHeroByID(actorId)
		if heroInfo ~= nil and heroInfo.level >= level then
			table.insert(heroKeys, actorId)
		end
	end
	return heroKeys
end

--获取已经拥有可进阶的魂师ID
function QHerosUtils:getHaveHeroCanGrade()
	local heroKeys = {}
	if level == nil then level = 0 end
	for _,actorId in pairs(self._keyHaveHeros) do
		local heroInfo = self:getHeroByID(actorId)
		if heroInfo ~= nil and QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(actorId, heroInfo.grade+1) ~= nil then
			table.insert(heroKeys, actorId)
		end
	end
	return heroKeys
end

--传入魂师和经验减值计算最终魂师数据
function QHerosUtils:subHerosExp(level, exp, subExp)
  while true do
    if exp >= subExp then
      	exp = exp - subExp
      	break
    elseif level > 0 then
      	subExp = subExp - exp - 1
      	level = level - 1
      	if level == 0 then
      		level = 1
      		break
      	end
      	exp = QStaticDatabase:sharedDatabase():getExperienceByLevel(level) - 1
    else
      	level = 1
      	exp = 0
      	break
    end
  end
    return level,exp
end

--检查所有魂师是否需要显示小红点
function QHerosUtils:checkAllHerosIsTip()
	if self:checkAllHerosBreakthrough() == true then
		return true
	elseif self:checkAllHerosEvolutionByID() == true then
		return true
	elseif app.unlock:getUnlockGemStone() and self:checkAllHerosGemstoneRedTips() == true then
		return true
	elseif self:checkAllHerosGrade() == true then
		return true
	elseif app.unlock:getUnlockEnchant() and self:checkAllHeroEnchantByID() then
		return true
	elseif app.unlock:getUnlockSkill() and self:checkAllHerosSkill() == true then
		return true
	elseif self:checkAllHerosComposite() == true then
		return true
	elseif app.unlock:getUnlockTraining() and remote.user.trainMoney >= 500 and remote.stores._trainTips == false and self:checkAllHerosCanTrain() then
		return true
	elseif self:checkAllHerosMountRedTips() then
		return true
	elseif self:checkAllHerosArtifactRedTips() then
		return true
	elseif self:checkAllHerosSparRedTips() then
		return true
	elseif self:checkAllHerosSkinRedTips() then
		return true
	elseif self:checkAllHerosMagicHerbRedTips() then
		return true
	elseif self:checkAllHerosSoulSpiritRedTips() then
		return true
	elseif remote.fashion:checkRedTips() then
		return true
	else
		return false
	end
end

--检查指定魂师是否需要显示小红点
function QHerosUtils:checkHerosIsTipByID(actorId)
	if self:checkHerosBreakthroughByID(actorId) == true then
		return true
	elseif self:checkHerosGradeByID(actorId) == true then
		return true
	elseif self:checkHerosEvolutionByID(actorId) ~= nil then
		return true
	elseif app.unlock:getUnlockGemStone() and self:checkHerosGemstoneRedTipsByID(actorId) == true then
		return true
	elseif app.unlock:getUnlockSkill() and self:checkHerosSkillByID(actorId) == true then
		return true
	elseif app.unlock:getUnlockEnchant() and self:checkHeroEnchantByID(actorId) ~= nil then
		return true
	elseif app.unlock:getUnlockTraining() and remote.user.trainMoney >= 500 and remote.stores._trainTips == false and self:checkHerosCanTrain(actorId) then
		return true
	elseif self:checkHerosMountRedTipsByID(actorId) then
		return true
	elseif self:checkHerosArtifactRedTipsByID(actorId) then
		return true
	elseif self:checkHerosSparRedTipsByID(actorId) then
		return true
	elseif self:checkHerosSkinRedTipsByID(actorId) then
		return true
	elseif self:checkHerosMagicHerbRedTipsByID(actorId) then
		return true
	elseif self:checkHerosSoulSpiritRedTipsByID(actorId) then
		return true
	else
		return false
	end
end

--检查所有魂师是否培养满了
function QHerosUtils:checkAllHerosCanTrain()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosCanTrain(heroInfos[i].id) then
			return true
		end
	end
end

--检查指定魂师是否培养满了
function QHerosUtils:checkHerosCanTrain(actorId)
	return self:getUIHeroByID(actorId):getCanTrain()
end

function QHerosUtils:checkHerosIsNeedTipByID(actorId) 
	if actorId == nil then return false end

	local heroInfos, count = self:getMaxForceHeros()

    for i = 1, count, 1 do
    	if heroInfos[i].id == actorId then
    		return true
		end
    end
    return false
end

function QHerosUtils:getMaxForceHero(isLocal) 
	local heros = self:getMaxForceHeros(isLocal)
	return heros[1]
end

function QHerosUtils:getMaxSoulSpiritForce(isLocal) 
	local force = remote.soulSpirit:getMaxForceSkill(isLocal)
	return force
end

function QHerosUtils:getMaxGodarmForce( isLocal )
	local force = 0
	local godarmForeList = {}
	local haveGodarmList = remote.godarm:getHaveGodarmList() or {}
	for _,godarmInfo in pairs(haveGodarmList) do
    	local godarmConfig = db:getCharacterByID(godarmInfo.id)
		table.insert(godarmForeList, {id = godarmInfo.id, force = godarmInfo.main_force, godArmType = godarmConfig.label})
	end
	local godarmTeamCount = self:getGodarmUnlockTeamNum()
    table.sort(godarmForeList, function(a, b) 
    		if a.force ~= b.force then
    			return a.force > b.force 
    		end
    		return a.id  > b.id
    	end)

    local index = 0
    local typeDist = {}
    for _, value in ipairs(godarmForeList) do
    	if typeDist[value.godArmType] == nil then
    		typeDist[value.godArmType] = 0
    	end
    	if index < godarmTeamCount and typeDist[value.godArmType] < 2 then
    		force = force + value.force
    		typeDist[value.godArmType] = typeDist[value.godArmType] + 1
    		index = index + 1
    	end
    end

	return force
end
-- 根据战队已解锁格子，获取战力最强N个魂师
-- herosInfos: 所有魂师战力从高到低
-- count: top N
function QHerosUtils:getMaxForceHeros(isLocal)
	local _maxHerosInfos = nil
	local _maxBattleForce = nil
	local _teamCount = self._teamCount
	if isLocal == true then
		_maxHerosInfos = self._localMaxHeroInfos
		_maxBattleForce = self._localMaxBattleForce
	else
		_maxHerosInfos = self._maxHerosInfos
		_maxBattleForce = self._maxBattleForce
	end

	if _maxHerosInfos == nil or true then
		_maxHerosInfos = {}
	    _maxBattleForce = 0
	    _teamCount = self:getUnlockTeamNum()
	    local heros = self:getHaveHero()

	    if next(heros) == nil then return {}, 0, 0 end

	    for i = 1, #heros, 1 do
	    	if isLocal then
		    	local heroProp = remote.herosUtil:createHeroPropById(heros[i])
		    	table.insert(_maxHerosInfos, {id = heros[i], force = heroProp:getBattleForce(isLocal)})
		    else
		    	local heroInfo = remote.herosUtil:getHeroByID(heros[i])
		    	table.insert(_maxHerosInfos, {id = heros[i], force = heroInfo.force or 0})
		    end
	    end
	    table.sort(_maxHerosInfos, function(a, b) 
	    		if a.force ~= b.force then
	    			return a.force > b.force 
	    		end
	    		return a.id  > b.id
	    	end)
	    for i=1,_teamCount do
	    	if _maxHerosInfos[i] ~= nil then
	    		_maxBattleForce = _maxBattleForce + _maxHerosInfos[i].force
	    	end
	    end

	    self._teamCount = _teamCount
		if isLocal == true then
			self._localMaxHeroInfos = _maxHerosInfos
			self._localMaxBattleForce = _maxBattleForce
		else
			self._maxHerosInfos = _maxHerosInfos
			self._maxBattleForce = _maxBattleForce
		end
	end

    return _maxHerosInfos, _teamCount, _maxBattleForce
end

--检查某个ID是不是topN
function QHerosUtils:checkIdInTopN(actorId)
    local herosInfos = {}
    local count = self:getUnlockTeamNum()
    local heros = self:getHaveHero()

    if next(heros) == nil then return {}, 0, 0 end

    for i = 1, #heros, 1 do
    	local heroInfo = remote.herosUtil:getHeroByID(heros[i])
    	table.insert(herosInfos, {id = heros[i], force = heroInfo.force or 0})
    end
    table.sort(herosInfos, function(a, b) 
    		if a.force ~= b.force then
    			return a.force > b.force 
    		end
    		return a.id  > b.id
    	end)
    for i=1,count do
    	if herosInfos[i] ~= nil and herosInfos[i].id == actorId then
    		return true
    	end
    end
    return false
end

-- xurui
-- 获取已解锁的战队格子数
function QHerosUtils:getUnlockTeamNum()
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
	if teamVO then
		return teamVO:getHerosMaxCountByIndex(1) + teamVO:getHerosMaxCountByIndex(2) + teamVO:getHerosMaxCountByIndex(3) + teamVO:getHerosMaxCountByIndex(4)
	end
	return 2
end

-- 获取已解锁的战队格子数
function QHerosUtils:getGodarmUnlockTeamNum()
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
	if teamVO then
		return teamVO:getHerosMaxCountByIndex(5)
	end
	return 0
end

--检查所有魂师是否可以突破
function QHerosUtils:checkAllHerosBreakthrough()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosBreakthroughByID(heroInfos[i].id) == true then
			return true
		end
	end
	return false
end

--检查魂师是否可以突破
function QHerosUtils:checkHerosBreakthroughByID(actorId)
	local heroUIModel = self:getUIHeroByID(actorId)
	if heroUIModel == nil then
		return false
	end
	local iscan,dropId, dropNum = heroUIModel:getCanBreak()
	return iscan
end

--检查所有魂师是否可以进阶
function QHerosUtils:checkAllHerosGrade()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosGradeByID(heroInfos[i].id) == true then
			return true
		end
	end
	return false
end

--检查当前魂师是否可以进阶
function QHerosUtils:checkHerosGradeByID(actorId)
	local heroInfo = self.heros[actorId]
	local gradeConfig = db:getGradeByHeroActorLevel(heroInfo.actorId, heroInfo.grade+1)
	if gradeConfig == nil then return false end

	local isAwake = (gradeConfig.awake or 0) == 1
	local superExp = gradeConfig.super_devour_consume 
	if superExp and superExp > 0 then
		local expTotal = 0
		local expItem = db:getItemByID(ITEM_TYPE.SUPER_EXP)	-- 魂师经验碎片
		local soulNum = remote.items:getItemsNumByID(expItem.id)
		expTotal = expTotal + (expItem.devour_exp or 0)*soulNum

		local expItem = db:getItemByID(ITEM_TYPE.POWERFUL_PIECE) -- 万能碎片
		local soulNum = remote.items:getItemsNumByID(expItem.id)
		expTotal = expTotal + (expItem.devour_exp or 0)*soulNum

		local fragments = remote.items:getAllSuperGradeFragment()
		for i, fragment in pairs(fragments) do
			local isNeed = remote.stores:checkItemIsNeed(fragment.type, 1)
			if not isNeed then
				local fragmentExp = db:getItemByID(fragment.type).devour_exp or 0
				expTotal = expTotal + fragment.count * fragmentExp
			end
		end
		if expTotal >= superExp and heroInfo.level >= gradeConfig.hero_level_limit  then --ss魂师升星也需要判断魂师限制等级
			return true, isAwake
		else
			return false, isAwake
		end
	else 
		local soulNum = remote.items:getItemsNumByID(gradeConfig.soul_gem) -- 魂力精魄的数量
		if gradeConfig.soul_gem ~= nil and gradeConfig.soul_gem ~= 0 then
			if soulNum >= gradeConfig.soul_gem_count and heroInfo.level >= gradeConfig.hero_level_limit then
				return true, isAwake
			else
				return false, isAwake
			end
		end
	end
	return false, false
end

--检查所有魂师是否可以升级技能
function QHerosUtils:checkAllHerosSkill()
	--技能未开启
	if app.unlock:getUnlockSkill() == false then
		return false
	end
	local point, lastTime = remote.herosUtil:getSkillPointAndTime()
	if point <= 0 then
        return false
	end
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosSkillByID(heroInfos[i].id) then
			return true
		end
	end
	return false
end

--检查当前魂师是否可以升级技能
function QHerosUtils:checkHerosSkillByID(actorId)
	--技能未开启
	if app.unlock:getUnlockSkill() == false then
		return false
	end
	local heroInfo = self.heros[actorId]
	if heroInfo and heroInfo.godSkillGrade and heroInfo.godSkillGrade > 0 then
		local gradeConfig = db:getGradeByHeroActorLevel(actorId, 0)
        local godSkillConfig = db:getGodSkillByIdAndGrade(actorId, heroInfo.godSkillGrade + 1)
		if godSkillConfig then
			local soulNum = remote.items:getItemsNumByID(gradeConfig.soul_gem)
			return soulNum >= godSkillConfig.stunt_num
		end
	end
	local point, lastTime = remote.herosUtil:getSkillPointAndTime()
    local maxPoint = QVIPUtil:getSkillPointCount() or 0
	if point < maxPoint then
        return false
	end
	local canUp, upSkillId, needMoney = self:getUIHeroByID(actorId):checkAllSkillCanUpgrade()
	if canUp and needMoney then
		canUp = (needMoney or 0) <= remote.user.money and canUp or false
	end
    return canUp , upSkillId, needMoney
end

--检查所有未召唤魂师是否可召唤
function QHerosUtils:checkAllHerosComposite()
	for _,key in pairs(self._keyHeros) do
		if self:checkHerosCompositeByID(key) then
			return true
		end
	end
	return false
end

--检查当前魂师是否可以合成
function QHerosUtils:checkHerosCompositeByID(actorId)
	local heroInfo = self:getHeroByID(actorId)
	if heroInfo ~= nil then return false end --已经存在无需召唤
	local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(actorId, 1)
	if gradeConfig == nil then return false end
	local soulNum = remote.items:getItemsNumByID(gradeConfig.soul_gem) -- 魂力精魄的数量
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
	local needGemCount = QStaticDatabase:sharedDatabase():getNeedSoulByHeroActorLevel(actorId, characher.grade or 0)
	if soulNum >= needGemCount then
		return true
	end
	return false
end

--获取魂师最大等级
function QHerosUtils:getHeroMaxLevel()
	local data = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level) or {}
	return data.hero_limit or 1
end

--魂师是否能升级
function QHerosUtils:heroCanUpgrade(actorId)
	local hero = self:getHeroByID(actorId)
	local exp = QStaticDatabase:sharedDatabase():getExperienceByLevel(hero.level)	
	local maxLevel = self:getHeroMaxLevel()
	if hero.level < maxLevel or (hero.level == maxLevel and hero.exp < (exp-1)) then
		return true
	else
		return false
	end
end

--魂师是否能升级 - 如果等级已达上限，无论是否能吃药水，返回false
function QHerosUtils:heroCanUpgrade2(actorId)
	local hero = self:getHeroByID(actorId)
	local exp = QStaticDatabase:sharedDatabase():getExperienceByLevel(hero.level)	
	local maxLevel = self:getHeroMaxLevel()
	if hero.level < maxLevel then
		return true
	else
		return false
	end
end

--检查某个魂师觉醒等级，取拥有装备的最低等级
function QHerosUtils:getHeroEnchantLevel(actorId)
	assert("QHerosUtils:getHeroEnchantLevel(actorId) is obsolete")
	local minLevel = 99
	local heroInfo = remote.herosUtil:getHeroByID(actorId)
	local equipments = heroInfo.equipments or {}
	for _, value in pairs(equipments) do
		local enchant = self:getWearByItem(actorId, value.itemId)
		if enchant.enchants == nil then
			minLevel = 0
			break
		elseif enchant.enchants < minLevel then
			minLevel = enchant.enchants or 0
		end
	end

	return minLevel == 99 and 0 or minLevel
end

--检查所有魂师是否有装备可以觉醒
function QHerosUtils:checkAllHeroEnchantByID()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHeroEnchantByID(heroInfos[i].id) then
			return true
		end
	end
	return false
end

--检查某个魂师是否有装备可以觉醒
function QHerosUtils:checkHeroEnchantByID(actorId)
	-- Check if has enchant material
	local heroInfo = remote.herosUtil:getHeroByID(actorId)
	local equipments = heroInfo.equipments or {}
	for _, value in pairs(equipments) do
		if self:checkEquipmentEnchantById(actorId, value.itemId, heroInfo.level) then
			return value.itemId
		end
	end

	return nil
end

function QHerosUtils:checkEquipmentEnchantById(actorId, itemId)
	local enchant = self:getWearByItem(actorId, itemId)
	local heroInfo = self:getHeroByID(actorId)

	if enchant.enchants == nil or enchant.enchants < QStaticDatabase:sharedDatabase():getMaxEnchantLevel(itemId,actorId) then
		local enchantConfig = QStaticDatabase:sharedDatabase():getEnchant(itemId, (enchant.enchants or 0) + 1, actorId)
		if enchantConfig.money <= remote.user.money and enchantConfig.hero_level_limit <= heroInfo.level then
			for i = 1, 3 do
				if enchantConfig["enchant_item"..i] and enchantConfig["enchant_num"..i] > remote.items:getItemsNumByID(enchantConfig["enchant_item"..i]) then
					return false
				end
			end
			return true
		else
			return false
		end
	end
	return false
end

--检查所有魂师是否有装备可以突破
function QHerosUtils:checkAllHerosEvolutionByID()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosEvolutionByID(heroInfos[i].id) ~= nil then
			return true
		end
	end
	return false
end

--检查某个魂师是否有装备可以突破 此处检查魂师等级
function QHerosUtils:checkHerosEvolutionByID(actorId)
	local heroUIModel = self:getUIHeroByID(actorId)
	return heroUIModel:checkHerosEvolutionById(actorId)
end

--检查所有魂师是否有宝石红点
function QHerosUtils:checkAllHerosGemstoneRedTips()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosGemstoneRedTipsByID(heroInfos[i].id) ~= false then
			return true
		end
	end
	return false
end

--检查某个魂师是否有宝石红点
function QHerosUtils:checkHerosGemstoneRedTipsByID(actorId)

	local heroUIModel = self:getUIHeroByID(actorId)
	return heroUIModel:checkHerosGemstoneRedTips() 
end

--检查所有魂师是否有宝石红点
function QHerosUtils:checkAllHerosMountRedTips()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosMountRedTipsByID(heroInfos[i].id) ~= false then
			return true
		end
	end
	return false
end

--检查某个魂师是否有暗器红点
function QHerosUtils:checkHerosMountRedTipsByID(actorId)

	local heroUIModel = self:getUIHeroByID(actorId)
	return heroUIModel:checkHerosMountRedTips() or heroUIModel:getMountDressingTip() or heroUIModel:getMountGraveTip()
end

--检查所有魂师是否有武魂真身红点
function QHerosUtils:checkAllHerosArtifactRedTips()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosArtifactRedTipsByID(heroInfos[i].id) ~= false then
			return true
		end
	end
	return false
end

function QHerosUtils:checkHerosArtifactRedTipsByID(actorId)
	local heroUIModel = self:getUIHeroByID(actorId)
	return heroUIModel:checkHerosArtifactRedTips() 
end

--检查所有魂师是否有晶石红点
function QHerosUtils:checkAllHerosSparRedTips()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosSparRedTipsByID(heroInfos[i].id) ~= false then
			return true
		end
	end
	return false
end

--检查魂师是否有晶石红点
function QHerosUtils:checkHerosSparRedTipsByID(actorId)
	local heroUIModel = self:getUIHeroByID(actorId)
	return heroUIModel:checkHerosSparsRedTips() 
end


--检查所有魂师是否有皮肤道具
function QHerosUtils:checkAllHerosSkinRedTips()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosSkinRedTipsByID(heroInfos[i].id) ~= false then
			return true
		end
	end
	return false
end

--检查所有魂师仙品小红点
function QHerosUtils:checkAllHerosMagicHerbRedTips()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosMagicHerbRedTipsByID(heroInfos[i].id) ~= false then
			return true
		end
	end
	return false
end

function QHerosUtils:checkAllHerosSoulSpiritRedTips()
	local heroInfos, count = self:getMaxForceHeros()
	for i = 1, count, 1 do
		if heroInfos[i] ~= nil and self:checkHerosSoulSpiritRedTipsByID(heroInfos[i].id) ~= false then
			return true
		end
	end
	return false
end

--检查魂师是否有皮肤道具
function QHerosUtils:checkHerosSkinRedTipsByID(actorId)
	return remote.heroSkin:checkHeroHaveSkinItem(actorId) 
end

--检查魂师是否有仙品红点
function QHerosUtils:checkHerosMagicHerbRedTipsByID(actorId)
	local heroUIModel = self:getUIHeroByID(actorId)
	return heroUIModel:checkHeroMagicHerbRedTips()
end

--检查魂师是否有魂灵红点
function QHerosUtils:checkHerosSoulSpiritRedTipsByID(actorId)
	local heroUIModel = self:getUIHeroByID(actorId)
	return heroUIModel:checkSoulSpiritRedTips()
end

--检查某个魂师可以突破的ID
function QHerosUtils:getHerosEvolutionIdByActorId(actorId)
	local heroUIModel = self:getUIHeroByID(actorId)
	return heroUIModel:getHerosEvolutionIdCheckWithLevel(actorId)
end

--获取某个魂师某件装备的突破等级
function QHerosUtils:getHeroEquipmentEvolutionByID(actorId, itemId)
	local heroUIModel = self:getUIHeroByID(actorId)
	local equipmentName, breakInfo = heroUIModel:getEquipmentPosition(itemId)
	if breakInfo ~= nil then
		return breakInfo.breakthrough_level
	end
	return 0
end

--检查某个魂师的某个装备突破的材料是否可以掉落
function QHerosUtils:checkHeroEquipmentDropByID(actorId, itemId)
	local heroUIModel = self:getUIHeroByID(actorId)
	local equipmentInfo = heroUIModel:getEquipmentInfoByItemId(itemId)
	if equipmentInfo.nextBreakInfo ~= nil then
		return remote.items:getComposeItemIsCanDrop(equipmentInfo.nextBreakInfo[equipmentInfo.pos])
	end
	return false,false
end


--检查某个魂师的某个装备是否可以通过战斗得到
function QHerosUtils:checkFarm(actorId)
	local heroEquipments = self:getHeroEquipmentForBreakthrough(actorId)
	if self:getFarmEquipment(heroEquipments[EQUIPMENT_TYPE.HAT], actorId) then
		self._equpmentId = heroEquipments[EQUIPMENT_TYPE.HAT]
		return self._equpmentId
	elseif self:getFarmEquipment(heroEquipments[EQUIPMENT_TYPE.CLOTHES], actorId) then
		self._equpmentId = heroEquipments[EQUIPMENT_TYPE.CLOTHES]
		return self._equpmentId
	elseif self:getFarmEquipment(heroEquipments[EQUIPMENT_TYPE.SHOES], actorId) then
		self._equpmentId = heroEquipments[EQUIPMENT_TYPE.SHOES]
		return self._equpmentId
	elseif self:getFarmEquipment(heroEquipments[EQUIPMENT_TYPE.WEAPON], actorId) then
		self._equpmentId = heroEquipments[EQUIPMENT_TYPE.WEAPON]
		return self._equpmentId
	elseif self:getFarmEquipment(heroEquipments[EQUIPMENT_TYPE.BRACELET], actorId) then
		self._equpmentId = heroEquipments[EQUIPMENT_TYPE.BRACELET]
		return self._equpmentId
	elseif self:getFarmEquipment(heroEquipments[EQUIPMENT_TYPE.JEWELRY], actorId) then
		self._equpmentId = heroEquipments[EQUIPMENT_TYPE.JEWELRY]
		return self._equpmentId
	end

    return nil
end

--检查某个魂师的某个装备是否可以通过战斗得到
function QHerosUtils:getFarmEquipment(id, actorId)
	local hero = self:getHeroByID(actorId)
	local isWear = self:checkIsWear(actorId, id)
	local isHaveItem = remote.items:getItemIsHaveNumByID(id,1)
	if isWear == false then
		if isHaveItem == false then
			local isCanDrop = remote.items:getItemIsCanDrop(id)
			if isCanDrop then
				return true
			else
				return false
			end
		end
	end
end

--检查某个魂师的装备是否强化到上限 
function QHerosUtils:checkHerosEnhanceByID(actorId)
  local heroInfo = remote.herosUtil:getHeroByID(actorId)
  local equipments = heroInfo.equipments or {}
  for _,value in pairs(equipments) do
    if self:checkHeroEquipmentStrengthenByID(actorId, value.itemId) == true then
      return value.itemId
    end   
  end

  return nil
end

--检查某个魂师的某个装备是否可以强化
function QHerosUtils:checkHeroEquipmentStrengthenByID(actorId, itemId)
  local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
  local maxStrengthenLevel = remote.user.level * 2
  if maxStrengthenLevel > self:getEquipmentStrengthenMaxLevel() then
  	maxStrengthenLevel = self:getEquipmentStrengthenMaxLevel()
  end
  local equipment = remote.herosUtil:getWearByItem(actorId, itemId)
  if equipment.level < maxStrengthenLevel then
    return true
  else
    return false
  end
end

--检查某个魂师是否穿了某个装备
function QHerosUtils:checkIsWear(actorId, itemId)
	return self:getWearByItem(actorId, itemId) ~= nil
end

--获取某个魂师穿戴的装备格子属性
function QHerosUtils:getWearByItem(actorId, itemId)
	local heroInfo = self:getHeroByID(actorId)
	if heroInfo ~= nil then
		local equipments = heroInfo.equipments or {}
		for _,equipment in pairs(equipments) do
			if equipment.itemId == itemId then
				return equipment
			end
		end
	end
	return nil
end

--获取某个魂师某个装备的装备位置
function QHerosUtils:getEquipeName(actorId, itemId)
	local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
	return self._equipment[characterInfo.talent][itemId].pos
end

--获取某个魂师某个装备的突破信息
function QHerosUtils:getEquipeBreakInfo(actorId, itemId)
	local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
	return self._equipment[characterInfo.talent][itemId].breakInfo
end

--魂师当前装备跟突破相关
function QHerosUtils:getHeroEquipmentForBreakthrough(actorId)
	local heroUIModel = self:getUIHeroByID(actorId)
	local items = {}
	for _,typeName in pairs(EQUIPMENT_TYPE) do
		local equipmentInfo = heroUIModel:getEquipmentInfoByPos(typeName)
		items[typeName] = equipmentInfo.info.itemId
	end
	return items
end

--魂师吃经验
function QHerosUtils:heroEatExp(expNum,actorId)
	local heroUIModel = self:getUIHeroByID(actorId)
	if heroUIModel == nil then
		return false
	end
	local isSucc,addLevel,addExp = heroUIModel:addExp(expNum)
	if isSucc == false then return false end
	-- self:dispacthHeroPropUpdate(actorId, "经验：+ "..addExp)
	-- self:_updateAttribute("经验：+ ", addExp)
	self:dispatchEvent({name = QHerosUtils.EVENT_HERO_EXP_UPDATE, actorId = actorId, exp = addExp})
	if addLevel > 0 then
		heroUIModel:initGemstone()
		heroUIModel:initMount()
		heroUIModel:initArtifact()
		heroUIModel:initSpar()
		self:dispacthHeroPropUpdate(actorId, "等级 + "..addLevel)
		self:_updateAttribute("等级 ", addLevel)
		self:dispatchEvent({name = QHerosUtils.EVENT_HERO_LEVEL_UPDATE, actorId = actorId})
		local heroInfo = heroUIModel:getHeroInfo()
		local oldHero = clone(heroInfo)
		oldHero.level = oldHero.level - addLevel
		self:heroUpdate(oldHero, heroInfo, true)
	end
    return true
end

--xurui: 魂师饰品强化
function QHerosUtils:heroJewelryEatExp(expNum, actorId, equipPos)
	local heroUIModel = self:getUIHeroByID(actorId)
	if heroUIModel == nil then
		return false
	end
	local isSucc,addLevel,addExp = heroUIModel:checkHerosJewelryById(expNum, equipPos)
	if isSucc == false then return false end
	if addLevel > 0 then
		self:dispatchEvent({name = QHerosUtils.EVENT_HERO_EQUIP_UPDATE, actorId = actorId})
	end
    return true, addLevel
end

--xurui: 魂师晶石强化
function QHerosUtils:heroSparEatExp(expNum, actorId, index)
	local heroUIModel = self:getUIHeroByID(actorId)
	if heroUIModel == nil then
		return false
	end
	local isSucc,addLevel,addExp = heroUIModel:updateSparStrengthLevel(expNum, index)
	if isSucc == false then return false end
	if addLevel > 0 then
		self:dispatchEvent({name = QHerosUtils.EVENT_HERO_EQUIP_UPDATE, actorId = actorId})
	end
    return true, addLevel
end

-- 检测 戒指 或者 项链 可以强化升级
function QHerosUtils:checkJewelryCanLevelUp( actorId, equipPos, expNum)
	-- body
	local heroUIModel = self:getUIHeroByID(actorId)
	if heroUIModel == nil then
		return false
	end
	return heroUIModel:checkHerosJewelryCanLevelUp(expNum, equipPos)
end

function QHerosUtils:heroUpdate(oldHero, newHero, isAdd, interval)
	local oldProp = QActorProp.new(oldHero)
	local newProp = QActorProp.new(newHero)
	self:_changePropIsDispacth(oldHero.actorId, "生命 ", newProp:getMaxHp() - oldProp:getMaxHp(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "攻击 ", newProp:getMaxAttack() - oldProp:getMaxAttack(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "命中 ", newProp:getMaxHit() - oldProp:getMaxHit(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "闪避 ", newProp:getMaxDodge() - oldProp:getMaxDodge(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "暴击 ", newProp:getMaxCrit() - oldProp:getMaxCrit(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "抗暴 ", newProp:getMaxCriReduce() - oldProp:getMaxCriReduce(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "格挡 ", newProp:getMaxBlock() - oldProp:getMaxBlock(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "攻速 ", newProp:getMaxHaste() - oldProp:getMaxHaste(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "物理防御 ", newProp:getMaxArmorPhysical() - oldProp:getMaxArmorPhysical(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "法术防御 ", newProp:getMaxArmorMagic() - oldProp:getMaxArmorMagic(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "物理穿透 ", newProp:getMaxPhysicalPenetration() - oldProp:getMaxPhysicalPenetration(), isAdd, interval)
	self:_changePropIsDispacth(oldHero.actorId, "法术穿透 ", newProp:getMaxMagicPenetration() - oldProp:getMaxMagicPenetration(), isAdd, interval)
end

--遍历队伍获得魂师属性并按照比例累加
function QHerosUtils:updatePropByTeams(prop, teams , scale_value,isCollegeTrain,chapterId)
	for _,acotrId in pairs(teams) do
		local heroModel = remote.herosUtil:createHeroPropById(acotrId)
		if isCollegeTrain then
			heroModel = remote.collegetrain:getHeroModelById(chapterId,acotrId)
		end
		for type_,value in pairs(prop) do
			if type_ == "hp" then
				prop[type_] = prop[type_]  + heroModel:getMaxHp() * scale_value
			elseif type_ == "attack" then
				prop[type_]  = prop[type_]  + heroModel:getMaxAttack() * scale_value
			elseif type_ == "magicArmor" then
				prop[type_]  = prop[type_]  + heroModel:getMaxArmorMagic() * scale_value
			elseif type_ == "physicalArmor" then
				prop[type_]  = prop[type_]  + heroModel:getMaxArmorPhysical() * scale_value
			elseif type_ == "hit" then
				prop[type_]  = prop[type_]  + heroModel:getMaxHit() * scale_value
			elseif type_ == "dodge" then
				prop[type_]  = prop[type_]  + heroModel:getMaxDodge() * scale_value
			elseif type_ == "block" then
				prop[type_]  = prop[type_]  + heroModel:getMaxBlock() * scale_value
			elseif type_ == "crit" then
				prop[type_]  = prop[type_]  + heroModel:getMaxCrit() * scale_value
			elseif type_ == "haste" then
				prop[type_]  = prop[type_]  + heroModel:getMaxHaste() * scale_value
			elseif type_ == "physical_penetration" then
				prop[type_]  = prop[type_]  + heroModel:getMaxPhysicalPenetration() * scale_value
			elseif type_ == "magic_penetration" then
				prop[type_]  = prop[type_]  + heroModel:getMaxMagicPenetration() * scale_value
			elseif type_ == "crit_reduce_rating" then
				prop[type_]  = prop[type_]  + heroModel:getMaxCriReduce() * scale_value
			elseif type_ == "physical_damage_percent_attack" then
				prop[type_]  = prop[type_]  + heroModel:getPhysicalDamagePercentAttack() * scale_value
			elseif type_ == "physical_damage_percent_beattack_reduce" then
				prop[type_]  = prop[type_]  + heroModel:getPhysicalDamagePercentBeattackReduceTotal() * scale_value			
			elseif type_ == "magic_damage_percent_attack" then
				prop[type_]  = prop[type_]  + heroModel:getMagicDamagePercentAttack() * scale_value
			elseif type_ == "magic_damage_percent_beattack_reduce" then
				prop[type_]  = prop[type_]  + heroModel:getMagicDamagePercentBeattackReduceTotal() * scale_value
			end
		end
	end	
end

function QHerosUtils:getUiFiedMap( prop )
	-- body
	local prop_map ={}
	for _,v in ipairs(QActorProp._uiFields) do
		if prop[v.fieldName] ~= nil then
			prop_map[v.fieldName] = v
		end
	end

	return prop_map
end

function QHerosUtils:getUiPropMapByActorProp(display_prop,heroModel )
	local prop_map = self:getUiFiedMap(display_prop)
	local prop_value ={}
	if heroModel then
		for type_,v in pairs(display_prop) do
			if prop_map[type_] == nil then 
			else
				local totle_type = prop_map[type_]["actor_prop"]
				if totle_type ~= nil then
					self:_updatePropAttribute(prop_value ,type_ , heroModel._totalProp[totle_type])
				else
				end
			end
		end
	end

	local result = {} 
	for type_,v in pairs(prop_value) do
		local value_str_ = v
		local name_ = "1"
		if prop_map[type_] ~= nil then 
			if prop_map[type_].handlerFun ~= nil then
				value_str_ = prop_map[type_].handlerFun(value_str_)
			else
				value_str_ = math.floor(value_str_)
			end
			if prop_map[type_].name_full ~= nil then
				name_ = prop_map[type_].name_full 
			else
				name_ = prop_map[type_].name 
			end
		end
		result[type_] =  {name = name_, value_str = value_str_}
	end

	return result
	
end


function QHerosUtils:getUiPVPPropMapByTeams(teams,param)
	local helpProp = {}
	for _,acotrId in pairs(teams) do
		local heroModel = nil
		if param.isCollegeTeam then
			heroModel = remote.collegetrain:getHeroModelById(param.chapterId,acotrId)
		elseif param.isMockBattle then
			heroModel = remote.mockbattle:getCardUiInfoById(acotrId)
		else
			heroModel = remote.herosUtil:createHeroPropById(acotrId)
		end
		if heroModel then
            helpProp.pvp_physical_damage_percent_attack = (helpProp.pvp_physical_damage_percent_attack or 0) + (heroModel:getPVPPhysicalAttackPercent() - heroModel:getArchaeologyPVPPhysicalAttackPercent()) /4
            helpProp.pvp_physical_damage_percent_beattack_reduce = (helpProp.pvp_physical_damage_percent_beattack_reduce or 0) + (heroModel:getPVPPhysicalReducePercent() - heroModel:getArchaeologyPVPPhysicalReducePercent())  /4
            helpProp.pvp_magic_damage_percent_attack = (helpProp.pvp_magic_damage_percent_attack or 0) + (heroModel:getPVPMagicAttackPercent() - heroModel:getArchaeologyPVPMagicAttackPercent())  /4
            helpProp.pvp_magic_damage_percent_beattack_reduce = (helpProp.pvp_magic_damage_percent_beattack_reduce or 0) + (heroModel:getPVPMagicReducePercent() - heroModel:getArchaeologyPVPMagicReducePercent()) /4
		end
	end
	return helpProp
end



function QHerosUtils:getUiPropMapByTeams(prop, teams , scale_value,param)

	local prop_map = self:getUiFiedMap(prop)

	local prop_value ={}

	for _,acotrId in pairs(teams) do
		local heroModel = nil
		if param.isCollegeTeam then
			heroModel = remote.collegetrain:getHeroModelById(param.chapterId,acotrId)
		elseif param.isMockBattle then
			heroModel = remote.mockbattle:getCardUiInfoById(acotrId)
		else
			heroModel = remote.herosUtil:createHeroPropById(acotrId)
		end
		if heroModel then
			for type_,v in pairs(prop) do
				if prop_map[type_] == nil then 
					print("Notice----add ui_field in QActorProp's _uiFields  fieldName = "..type_)
				else
					local totle_type = prop_map[type_]["actor_prop"]
					if totle_type ~= nil then
						self:_updatePropAttribute(prop_value ,type_ , heroModel._totalProp[totle_type])
					else
						print("Notice----add actor_prop in QActorProp's _uiFields  fieldName = "..type_)
					end
				end
			end
		end
	end

	local result = {} 
	for type_,v in pairs(prop_value) do
		local value_str_ = v * scale_value
		local percent_value_str_ = nil
		local name_ = "1"
		if prop_map[type_] ~= nil then 
			if prop_map[type_].handlerFun ~= nil then
				value_str_ = prop_map[type_].handlerFun(value_str_)
				percent_value_str_ = v * scale_value
			else
				value_str_ = math.floor(value_str_)
			end
			if prop_map[type_].name_full ~= nil then
				name_ = prop_map[type_].name_full 
			else
				name_ = prop_map[type_].name 
			end
		end
		result[type_] =  {name = name_, value_str = value_str_,percent_value_str = percent_value_str_}
	end

	return result
end


function QHerosUtils:updateAllPropByTeams(prop, teams , scale_value)

	for _,acotrId in pairs(teams) do
		local heroModel = remote.herosUtil:createHeroPropById(acotrId,true)
		for type_,field_ in pairs(heroModel._totalProp) do
			if field_ >  0  then
				self:_updatePropAttribute(prop,type_ , field_ * scale_value)
			end
		end
	end

end

function QHerosUtils:_updatePropAttribute(prop , key, value)
	-- 统计从玩家开始连续吃经验，直到结束，这整个过程中所有属性的总和
	if prop[key] == nil then
		prop[key] = value
	else
		prop[key] = prop[key] + value
	end
end

function QHerosUtils:_updateAttribute(key, value)
	-- 统计从玩家开始连续吃经验，直到结束，这整个过程中所有属性的总和
    self:_updatePropAttribute(self._attribute,key, value)
	-- if self._attribute[key] == nil then
	-- 	self._attribute[key] = value
	-- else
	-- 	self._attribute[key] = self._attribute[key] + value
	-- end
end

function QHerosUtils:getAttribute()
	return self._attribute
end

function QHerosUtils:getAttributeKeys()
	-- 这里能控制和调整报告的格式和先后顺序
	local keys = { --[["经验：", ]]"等级 ", "生命 ", "攻击 ", "命中 ", "闪避 ", "暴击 ", "抗暴 ", "格挡 ", "攻速 ", "物理防御 ", "法术防御 ", "物理穿透 ", "法术穿透 " }
	return keys
end

function QHerosUtils:cleanAttribute()
	self._attribute = nil
	self._attribute = {}
end

function QHerosUtils:dispacthBattleforceUpdate(actorId)
	self:dispatchEvent( {name = QHerosUtils.BATTLEFORCE_UPDATE, actorId = actorId} )
end

function QHerosUtils:_changePropIsDispacth(actorId, name, value, isAdd, interval)
    if value ~= nil and value > 0 then
    	if isAdd == true then
    		self:_updateAttribute(name, value)
    	else
			self:dispacthHeroPropUpdate(actorId, name.."+ "..string.format("%.1f",value), interval)		
		end
    end
end

--检查魂师是否是收集中
function QHerosUtils:checkHeroIsNeed(actorId)
	local heroInfo = self:getHeroByID(actorId)
	if heroInfo == nil then return false end
	local gradeConfig = db:getGradeByHeroActorLevel(heroInfo.actorId, heroInfo.grade+1)
	if gradeConfig == nil then return false end

	if not self._checkHeroNeedCount then
		self._checkHeroNeedCount = app.unlock:getUnlockTeamHelpNum()
		local configBaseNum = db:getConfigurationValue(QHerosUtils.CONFIGURATION_CHECK_NEED_HERO_BASE) or 4
		self._checkHeroNeedCount = self._checkHeroNeedCount + configBaseNum
	end

	local index = 1
	for _, actor in ipairs(self._keyHaveHeros) do
		if index <= self._checkHeroNeedCount then
			if actor == actorId then
				return true
			end
		else
			return false
		end
		index = index + 1
	end

	return false
end

--魂师数据排序
function QHerosUtils:sortHero()
    table.sort(self._keyHeros, handler(self,self._sortHero))
    table.sort(self._keyHaveHeros, function (a,b)
    	local forceA = 0
    	local forceB = 0
    	local heroA = self:getHeroByID(a)
    	local heroB = self:getHeroByID(b)
    	if heroA and heroB then
    		forceA = heroA.force or 0
    		forceB = heroB.force or 0
    	end
    	if forceA ~= forceB then
    		return forceA > forceB
    	else
    		return self:_sortHero(a, b, true)
    	end
    end)
end

-- @qinyuanji WOW-6661 
-- 魂师列表界面，已经获得的魂师排序：1）第一序按照战斗力从高到低；2）第二序星级；未获得的魂师排序：1）已有灵魂石数量从高到低；2）星级
function QHerosUtils:_sortHero(a,b, skipForceCompare)
	local heroA = self:getHeroByID(a)
	local heroB = self:getHeroByID(b)

	if heroA and heroB and not skipForceCompare then
    	local forceA = heroA.force or 0
    	local forceB = heroB.force or 0

		if forceA ~= forceB then
			return forceA > forceB
		end
	end

	local characherA = QStaticDatabase:sharedDatabase():getCharacterByID(a)
	local characherB = QStaticDatabase:sharedDatabase():getCharacterByID(b)
	if characherA ~= nil and characherB ~= nil then
		return characherA.grade > characherB.grade
	end
	return a > b
end

--检查魂师是否在战队
function QHerosUtils:_checkHeroInTeam(herosID)
	if next(remote.teamManager) == nil then 
		return false
	end
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
	if teamVO:contains(herosID) then
		return true
	end
	return false
end

function QHerosUtils:dispacthHeroPropUpdate(actorId,value,interval)
	if interval == nil then interval = 0.3 end
	scheduler.performWithDelayGlobal(function ()
		self:dispatchEvent({name = QHerosUtils.EVENT_HERO_PROP_UPDATE, actorId = actorId, value = value})
	end,interval)
end

--[[
	获取技能点数和刷新时间 已经计算过
]]
function QHerosUtils:getSkillPointAndTime()
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	local totalPoint = QVIPUtil:getSkillPointCount()
	local stageTime = tonumber(config.SP_RECOVE_SPEED.value)
	if remote.activity:checkMonthCardActive(1) then
		stageTime = stageTime/2
	end
	local startPoint = remote.user.skillTickets or 0
	local lastRefreshTime = remote.user.skillTicketsRefreshedAt or 0
	lastRefreshTime = lastRefreshTime / 1000
	local currentTime = q.serverTime()
	if startPoint >= totalPoint or (currentTime - lastRefreshTime) < stageTime then
		return startPoint - self._advancePoint, (stageTime - (currentTime - lastRefreshTime)), startPoint
	else
		while true do
			if startPoint >= totalPoint or (currentTime - lastRefreshTime) < stageTime then
				break
			else
				lastRefreshTime = lastRefreshTime + stageTime
				startPoint = startPoint + 1
			end
		end
	end
	return startPoint - self._advancePoint, (stageTime - (currentTime - lastRefreshTime)), startPoint
end

--[[
	设置预支技能点
]]
function QHerosUtils:setAdvancePoint(point)
	self._advancePoint = point
end

--[[
	获取预支技能点
]]
function QHerosUtils:getAdvancePoint(point)
	return self._advancePoint or 0
end

--[[
	保存技能升级到后台 
]]
function QHerosUtils:requestSkillUp()
	for _,uihero in pairs(self._uiHeros) do
		local skillCache = uihero:getSkillCache()
		if skillCache ~= nil and table.nums(skillCache) > 0 then
			local data = {}
			local totalCount = 0
			for key,count in pairs(skillCache) do
				table.insert(data, {slotId = key, count = count})
				totalCount = totalCount + count
			end
			uihero:resetSkillCache()
			app:getClient():improveSkill(uihero:getHeroInfo().actorId, data, function ()
				remote.user:addPropNumForKey("todaySkillImprovedCount", totalCount)
				self:setAdvancePoint(0)
			end)
		end
	end
end

--[[
	魂师突破等级变化
	对应 白绿蓝紫橙
]]
function QHerosUtils:getBreakThrough(breakthroughLevel)
	local offsetLevel,level = self:getBreakThroughLevel(breakthroughLevel)
	return offsetLevel,EQUIPMENT_QUALITY[level]
end

--[[
	计算突破的级别
]]
function QHerosUtils:getBreakThroughLevel(breakthroughLevel)
	if not breakthroughLevel then breakthroughLevel = 0 end
	local breakLevel = {0,2,7,12,17,22,27} --whilte,green,blue,purple,orange,red,yellow
	local perNum = 0
	for index,value in pairs(breakLevel) do
		if breakthroughLevel < value then
			local offsetLevel = breakthroughLevel-perNum
			if offsetLevel < 0 then offsetLevel = 0 end
			return offsetLevel,index
		end
		perNum = value
	end
	return 0,1
end

--获取所有魂师突破所需物品数量
--@param isWear 是否当前身上穿的装备，如果true则查询身上装备突破所需，如果false则查询突破所需 
function QHerosUtils:getAllHeroBreakNeedItem(isWear)
	local herosKey = table.keys(self.heros)
	self._items = {}
	if self._itemCraftFun == nil then
		self._itemCraftFun = function (itemId)
			local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(itemId)
			if itemCraftConfig ~= nil then
				local index = 0
				while true do
					index = index + 1
					local materialId = tonumber(itemCraftConfig["component_id_"..index])
					if materialId ~= nil then
						if QStaticDatabase:sharedDatabase():getItemCraftByItemId(materialId) ~= nil then
							self._itemCraftFun(materialId)
						else
							if self._items[materialId] == nil then
								self._items[materialId] = 0
							end
							self._items[materialId] = self._items[materialId] + itemCraftConfig["component_num_"..index] 
						end
					else
						break
					end
				end
			end
		end
	end
	for _,actorId in pairs(herosKey) do
		local uiHero = self:getUIHeroByID(actorId)
		local heroInfo = self.heros[actorId]
		if heroInfo then
			for _,equipment in pairs(heroInfo.equipments) do
				local itemId = equipment.itemId
				local equipment = uiHero:getEquipmentInfoByItemId(itemId)
				if equipment ~= nil then
					if equipment.nextBreakInfo ~= nil and (equipment.breakLevel == heroInfo.breakthrough or isWear == true) then
						self._itemCraftFun(equipment.nextBreakInfo[equipment.pos])
					end
				end
			end
		end
	end
	for key,value in pairs(self._items) do
		self._items[key] = self._items[key] - remote.items:getItemsNumByID(key)
	end
	return self._items
end

--获取所有魂师单个突破材料的最大值
function QHerosUtils:getAllHeroOneBreakNeedMaxNum()
	local herosKey = table.keys(self.heros)
	self._items2 = {}
	self._itemCraftFun2 = function (itemId)
		local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(itemId)
		if itemCraftConfig ~= nil then
			local index = 0
			while true do
				index = index + 1
				local materialId = tonumber(itemCraftConfig["component_id_"..index])
				if materialId ~= nil then
					if QStaticDatabase:sharedDatabase():getItemCraftByItemId(materialId) ~= nil then
						self._itemCraftFun2(materialId)
					else
						if self._items2[materialId] == nil then
							self._items2[materialId] = 0
						end
						self._items2[materialId] = self._items2[materialId] < itemCraftConfig["component_num_"..index] and itemCraftConfig["component_num_"..index] or self._items2[materialId]
					end
				else
					break
				end
			end
		end
	end
	for _,actorId in pairs(herosKey) do
		local heroInfo = self.heros[actorId]
		local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(heroInfo.actorId)
		local breakthroughInfo = QStaticDatabase:sharedDatabase():getBreakthroughByTalentLevel(characterInfo.talent, heroInfo.breakthrough+1)
		for _,equipment in pairs(heroInfo.equipments) do
			local itemId = equipment.itemId
			local equipmentName = remote.herosUtil:getEquipeName(actorId, itemId)
			if breakthroughInfo ~= nil and breakthroughInfo[equipmentName] ~= itemId then
				self._itemCraftFun2(breakthroughInfo[equipmentName])
			end
		end
	end
	for key,value in pairs(self._items2) do
		self._items2[key] = self._items2[key] - remote.items:getItemsNumByID(key)
	end
	return self._items2
end

function QHerosUtils:getManualSkillsByActorId(actorId)
	local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(actorId, 3)
	return QStaticDatabase:sharedDatabase():getSkillByID(skillId)
end

function QHerosUtils:getMostHeroBattleForce(isLocal)
	local heroInfos, count = self:getMaxForceHeros(isLocal)
	local soulSpiritForce = self:getMaxSoulSpiritForce(isLocal)
	local godarmForce = self:getMaxGodarmForce(isLocal)
	
	local maxBattleForce = 0

    for i = 1, count, 1 do
    	if heroInfos[i] ~= nil then
			maxBattleForce = maxBattleForce + heroInfos[i].force
		end
    end
    return maxBattleForce + soulSpiritForce + godarmForce
end

--xurui: 根据魂师星级获得显示星星数量和icon   WOW-9762
function QHerosUtils:getStarIconByStarNum(star, isBig)
	local icons = {{["1"] = "ui/common/one_star.png", ["2"] = "ui/Fighting.plist/Big_star.png"},
					{["1"] = "ui/common/one_moon.png", ["2"] = "ui/Fighting.plist/Big_moon.png"},
					{["1"] = "ui/common/one_sun.png", ["2"] = "ui/Fighting.plist/Big_sun.png"}
				}
	local index = "1"
	if isBig then
		index = "2"
	end

	if star >= 1 and star <= GRAD_MAX then
		return star, icons[1][index]
	elseif star >= GRAD_MAX+1 and star <= GRAD_MAX*2 then
		return star-GRAD_MAX, icons[2][index]
	elseif star >= GRAD_MAX*2+1 and star <= GRAD_MAX*3 then
		return star-(GRAD_MAX*2), icons[3][index]
	else
		return nil
	end
end

function QHerosUtils:getJobTitleByGradeLevelNum(gradeLevel)
	local jobTitles = { "魂士",
						"魂师",
						"大魂师",
						"魂尊",
						"魂宗",
						"魂王",
						"魂帝",
						"魂圣",
						"魂斗罗",
						"封号斗罗",
						"超级斗罗",
						"巅峰斗罗",
						"半神",
						"神",
						"神王",
					}
	if gradeLevel >= 1 and gradeLevel <= GRAD_MAX*3 then
		return jobTitles[gradeLevel]
	end
	return nil
end

--xurui: 根据进阶等级获取魂师当前进阶名称
function QHerosUtils:getGradeNameByGradeLevel(gradeLevel)
	if gradeLevel >= 1 and gradeLevel <= GRAD_MAX then
		return "星", gradeLevel
	elseif gradeLevel >= GRAD_MAX+1 and gradeLevel <= GRAD_MAX*2 then
		return "月亮", gradeLevel - GRAD_MAX
	elseif gradeLevel >= GRAD_MAX*2+1 and gradeLevel <= GRAD_MAX*3 then
		return "太阳", gradeLevel - GRAD_MAX*2
	end
	return "星", gradeLevel
end

--xurui: 获取当前装备强化上限
function QHerosUtils:getEquipmentStrengthenMaxLevel()
	local maxLevel = (remote.user.level or 0) * 2
	maxLevel = math.min(maxLevel, QStaticDatabase:sharedDatabase():getConfiguration().EQUIPMENT_MAX_LEVEL.value)
	return maxLevel
end

--xurui: 获取当前饰品强化上限
function QHerosUtils:getJewelryStrengthenMaxLevel()
	local maxLevel = (remote.user.level or 0) * 2
	maxLevel = math.min(maxLevel, QStaticDatabase:sharedDatabase():getConfiguration().JEWELRY_MAX_LEVEL.value)
	return maxLevel
end

--nie 检查一个魂师是否可以培养
function QHerosUtils:checkHeroCanTraining( actorId )
	-- body
	local train_id = QStaticDatabase:sharedDatabase():getCharacterByID(actorId).train_id
	local attributes = remote.herosUtil:getHeroByID(actorId).trainAttr or {}
	local level = remote.herosUtil:getHeroByID(actorId).level
	local hpUpperLimit = QStaticDatabase:sharedDatabase():getTrainingAttribute(train_id, level)["hp_value"] or 0
	local attackUpperLimit = QStaticDatabase:sharedDatabase():getTrainingAttribute(train_id, level)["attack_value"] or 0
	local physicalDefendUpperLimit = QStaticDatabase:sharedDatabase():getTrainingAttribute(train_id, level)["armor_physical"] or 0
	local magicalDefendUpperLimit = QStaticDatabase:sharedDatabase():getTrainingAttribute(train_id, level)["armor_magic"] or 0


	if (attributes["hp"] or 0) >= hpUpperLimit and (attributes["attack"] or 0) >= attackUpperLimit
		and (attributes["armorPhysical"] or 0) >= physicalDefendUpperLimit and (attributes["armorMagic"] or 0) >= magicalDefendUpperLimit then
		return false
	end
	return true
end

--从魂师列表中找一个战力最高的出来
function QHerosUtils:getMaxForceBySelfHeros()
	local maxHero = nil
	for _,value in pairs(self.heros) do
		if maxHero == nil then
			maxHero = value
		else
			local force = value.force or 0
			if force > (maxHero.force or 0) then
				maxHero = value
			end
		end
	end
	return maxHero
end

--从魂师列表中找一个id匹配的出来
function QHerosUtils:getSpecifiedHeroById(heroInfo, actorId)
	if heroInfo.heros ~= nil then 
		for _,value in ipairs(heroInfo.heros) do
			if value.actorId == actorId then
				return value
			end
		end
		if heroInfo.subheros ~= nil then
			for _,value in ipairs(heroInfo.subheros) do
				if value.actorId == actorId then
					return value
				end
			end
		end
		if heroInfo.sub2heros ~= nil then
			for _,value in ipairs(heroInfo.sub2heros) do
				if value.actorId == actorId then
					return value
				end
			end
		end
		if heroInfo.sub3heros ~= nil then
			for _,value in ipairs(heroInfo.sub3heros) do
				if value.actorId == actorId then
					return value
				end
			end
		end
	end
end

--从魂师列表中找一个战力最高的出来
function QHerosUtils:getMaxForceByHeros(heroInfo)
	local maxHero = nil
	local maxForce = 0

	local calculateForceFunc = function(heros)
		for _, value in ipairs(heros) do
			local force = value.force or 0
			if force > maxForce then
				maxForce = force
				maxHero = value
			end
		end
	end

	calculateForceFunc(heroInfo.heros or {})
	calculateForceFunc(heroInfo.subheros or {})
	calculateForceFunc(heroInfo.sub2heros or {})
	calculateForceFunc(heroInfo.sub3heros or {})

	return maxHero
end

--从魂师列表中找一个战力最高的出来
function QHerosUtils:getMaxForceBySecondTeamHeros(heroInfo)
	local maxHero = nil
	local maxForce = 0

	local calculateForceFunc = function(heros)
		for _, value in ipairs(heros) do
			local force = value.force or 0
			if force > maxForce then
				maxForce = force
				maxHero = value
			end
		end
	end

	calculateForceFunc(heroInfo.main1Heros or {})
	calculateForceFunc(heroInfo.sub1heros or {})
	return maxHero
end

--删除所有的魂师属性对象的缓存
function QHerosUtils:removeAllHeroProp()
	self._heroProp = {}
end

--创建魂师的属性对象
function QHerosUtils:createHeroProp(heroInfo, isForce , isOnlyProp)
	if heroInfo == nil then return nil end
	local hero = nil
	if isOnlyProp then
		hero = QActorProp.new()
		hero:setOnlyProp(true)
		hero:setHeroInfo(heroInfo)
	elseif isForce ~= true and self._heroProp[heroInfo.actorId] ~= nil then
		hero = self._heroProp[heroInfo.actorId]
	else
		hero = QActorProp.new(heroInfo)
		self._heroProp[heroInfo.actorId] = hero
	end
	return hero
end

--获取魂师的属性对象通过ID
function QHerosUtils:createHeroPropById(actorId,onlyProp_)
	if onlyProp_ then
		return self:createHeroProp(self:getHeroByID(actorId) , false ,true)
	else
		return self:createHeroProp(self:getHeroByID(actorId))
	end
end

--删除魂师的属性对象
function QHerosUtils:removeHeroProp(actorId)
    if actorId ~= nil then
        if self._heroProp[heroInfo.actorId] ~= nil then
            self._heroProp[heroInfo.actorId] = nil
        end
    end
end

function QHerosUtils:addExtendsPropById(prop, extendName, actorId)
	local heroInfo = remote.herosUtil:getHeroByID(actorId)
	if heroInfo ~= nil then
		local actor = remote.herosUtil:createHeroProp(heroInfo)
		actor:addExtendsProp(prop, extendName)
		-- actor:_disableHpChangeByPropertyChange()
		-- actor:_applyStaticActorNumberProperties()
	end
end

--附加属性到魂师身上
function QHerosUtils:addExtendsProp(prop, extendName, isEvent)
	self._maxHerosInfos = nil
	self._localMaxHeroInfos = nil
    local heros = self:getHaveHero()
    if next(heros) == nil then return end
    for i = 1, #heros, 1 do
    	self:addExtendsPropById(prop, extendName, heros[i])
    end
    if isEvent then
		remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
	end
end

function QHerosUtils:getIsHasExtendsPropById(extendName, actorId)
	local heroInfo = remote.herosUtil:getHeroByID(actorId)
	local actor = remote.herosUtil:createHeroProp(heroInfo)
	if actor:getIsHasExtendsProp(extendName) then
		return true
	end
	return false
end

--获取是否添加了特殊属性
function QHerosUtils:getIsHasExtendsProp(extendName)
    local heros = self:getHaveHero()
    if next(heros) == nil then return false end
    for i = 1, #heros, 1 do
    	if self:getIsHasExtendsPropById(extendName, heros[i]) then
    		return true
    	end
    end
    return false
end

--移除属性通过ID
function QHerosUtils:removeExtendsPropById(extendName, actorId)
	local heroInfo = remote.herosUtil:getHeroByID(actorId)
	local actor = remote.herosUtil:createHeroProp(heroInfo)
	if actor:getIsHasExtendsProp(extendName) then
		actor:removeExtendsProp(extendName)
	end
end

--移除附加属性到魂师身上
function QHerosUtils:removeExtendsProp(extendName, isEvent)
	self._maxHerosInfos = nil
	self._localMaxHeroInfos = nil
    local heros = self:getHaveHero()
    if next(heros) == nil then return end
    for i = 1, #heros, 1 do
    	self:removeExtendsPropById(extendName, heros[i])
    end
    if isEvent then
		remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
	end
end

-- xurui
-- 检查魂师是否有合体魂师
-- return  是否有合体魂师， 合体是否激活
function QHerosUtils:checkHeroHaveAssistHero(actorId)
    local assistHeroInfo = QStaticDatabase:sharedDatabase():getAssistSkill(actorId)
    if assistHeroInfo == nil then return false, false end
   	
    local teams = remote.user.collectedHeros or {}
	if self:checkHeroHavePast(actorId) == false then return false, false end

    local assistHero = true
    local haveAssistHero = false

    local index = 1
    while assistHeroInfo["Deputy_hero"..index] do
    	if assistHeroInfo["show_hero"..index] == 1 then return true, false end
        local isHave = false
        for i = 1, #teams, 1 do
            if teams[i] == assistHeroInfo["Deputy_hero"..index] then
                isHave = true
                break
            end
        end
        if isHave == false then
            haveAssistHero = false
            break
        else
            haveAssistHero = isHave
        end
        index = index + 1
    end
    return assistHero, haveAssistHero
end

function QHerosUtils:getCombinationInfo(teams)
	local count = 0
	for i, actorId in pairs(teams) do
	    local combinationInfos = db:getCombinationInfoByHeroId(actorId)
	    for _, value in pairs(combinationInfos) do
		   	local isActive = remote.herosUtil:checkHeroCombination(value.hero_id, value)
	        if isActive then
	        	count = count + 1
	        end
	    end
	end
	return count
end

function QHerosUtils:getCombinationCount()
	return self._combinationCount or 0
end

-- xurui
-- 检查魂师是否曾经获得过
function QHerosUtils:checkHeroHavePast(actorId, isUpdate)
	local teams = remote.user.collectedHeros or {}
	for i = 1, #teams, 1 do
		if teams[i] == tonumber(actorId) then
			return true
		end
	end
	if isUpdate then
		self._combinationCount = self:getCombinationInfo(teams)

		teams[#teams+1] = actorId
		remote.user:update({collectedHeros = teams})

		-- 历史魂师发生变化时刷新魂师战力
		self:validate()
		self:updateHeros(self.heros)
		remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
	end
	return false
end

--xurui 
-- 检查魂师组合是否激活
function QHerosUtils:checkHeroCombination(actorId, combination)
	if actorId  == nil or combination == nil then return false end

    local teams = remote.user.collectedHeros or {}
	if self:getHeroByID(actorId) == nil then return false end

    local isActive = false

    local index = 1
    while combination["combination_hero_"..index] do
    	if combination["show_hero"..index] == 1 then return false end
        local isHave = false
        for i = 1, #teams, 1 do
            if teams[i] == combination["combination_hero_"..index] then
                isHave = true
                break
            end
        end
        if isHave == false then
            isActive = false
            break
        else
            isActive = isHave
        end
        index = index + 1
    end
    return isActive
end

-- xurui
-- 检查觉醒组合是否激活
function QHerosUtils:checkEnchantCombination(actorId, combination)
	if actorId  == nil or combination == nil or combination.badge_gad_1 == nil then return false end

	local heroModel = self:getUIHeroByID(actorId)

	local equipmentInfo1 = heroModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1)
	local equipmentInfo2 = heroModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2)
	if equipmentInfo1.info.enchants == nil or equipmentInfo2.info.enchants == nil then return false end

	if equipmentInfo1.info.enchants >= combination.badge_gad_1 and equipmentInfo2.info.enchants >= combination.badge_gad_1 then
		return true
	end
	return false
end 

-- xurui
-- 计算魂师的组合属性
function QHerosUtils:countHeroCombinationProp(actorId)
	local combinationInfo = QStaticDatabase:sharedDatabase():getCombinationInfoByHeroId(actorId)
	if combinationInfo == nil then return {} end

	local combinationProp = {}
	local countProp = function(data)
		for name,filed in pairs(QActorProp._field) do
			if data[name] ~= nil then
				if combinationProp[name] == nil then
					combinationProp[name] = data[name]
				else
					combinationProp[name] = data[name] + combinationProp[name]
				end
			end
		end
	end

	for i = 1, #combinationInfo do
		if self:checkHeroCombination(actorId, combinationInfo[i]) then
			countProp(combinationInfo[i])
		end
	end
	
	return combinationProp
end

--[[
	获取某个魂师启用的雕纹（战魂）配置
]]
function QHerosUtils:getHeroGlyphsByID(actorId)
	local heroInfo = self:getHeroByID(actorId)
	if heroInfo.glyphs then
		local db = QStaticDatabase:sharedDatabase()
		return db:getGlyphSkillsByGlyphs(heroInfo.glyphs)
	else
		return {}
	end
end

--[[
	获取魂师的职业 通过Id
]]
function QHerosUtils:getProessionByActorId(actorId, isTwo)
	local db = QStaticDatabase:sharedDatabase()
	if db:isDPS(actorId) then
		if isTwo then
			if db:isDPS_M(actorId) then
				return HERO_FUNC_TYPE_DESC.DPS_M
			elseif db:isDPS_P(actorId) then
				return HERO_FUNC_TYPE_DESC.DPS_P
			end
		else
			return HERO_FUNC_TYPE_DESC.DPS
		end
	elseif db:isTank(actorId) then
		return HERO_FUNC_TYPE_DESC.TANK
	elseif db:isHealth(actorId) then
		return HERO_FUNC_TYPE_DESC.HEALTH
	end
end

--从英雄列表中找一个战力最高的出来,不是辅助治疗
function QHerosUtils:getMaxAttackForceByHeros(heroInfo)
	local maxHero = nil
	local maxForce = 0
	if heroInfo.heros ~= nil then 
		for _,value in ipairs(heroInfo.heros) do
			local force = value.force or 0
			local heroConfig = db:getCharacterByID(value.actorId)
			if heroConfig.func ~= "health" and force > maxForce then
				maxForce = force
				maxHero = value
			end
		end
	end
	if heroInfo.subheros ~= nil then
		for _,value in ipairs(heroInfo.subheros) do
			local force = value.force or 0
			local heroConfig = db:getCharacterByID(value.actorId)
			if heroConfig.func ~= "health" and force > maxForce then
				maxForce = force
				maxHero = value
			end
		end
	end
	if heroInfo.sub2heros ~= nil then
		for _,value in ipairs(heroInfo.sub2heros) do
			local force = value.force or 0
			local heroConfig = db:getCharacterByID(value.actorId)
			if heroConfig.func ~= "health" and force > maxForce then
				maxForce = force
				maxHero = value
			end
		end
	end
	if heroInfo.sub3heros ~= nil then
		for _,value in ipairs(heroInfo.sub3heros) do
			local force = value.force or 0
			local heroConfig = db:getCharacterByID(value.actorId)
			if heroConfig.func ~= "health" and force > maxForce then
				maxForce = force
				maxHero = value
			end
		end
	end
	--攻击阵容里
	if heroInfo.mainHeroIds ~= nil then
		for k, heroId in ipairs(heroInfo.mainHeroIds) do
	        local value = remote.herosUtil:getHeroByID(heroId)
	        local force = value.force or 0
			local heroConfig = db:getCharacterByID(value.actorId)
			if heroConfig.func ~= "health" and force > maxForce then
				maxForce = force
				maxHero = value
			end
	    end
	end
	if heroInfo.sub1HeroIds ~= nil then
		for k, heroId in ipairs(heroInfo.sub1HeroIds) do
	        local value = remote.herosUtil:getHeroByID(heroId)
	        local force = value.force or 0
			local heroConfig = db:getCharacterByID(value.actorId)
			if heroConfig.func ~= "health" and force > maxForce then
				maxForce = force
				maxHero = value
			end
	    end
	end
	if heroInfo.sub2HeroIds ~= nil then
		for k, heroId in ipairs(heroInfo.sub2HeroIds) do
	        local value = remote.herosUtil:getHeroByID(heroId)
	        local force = value.force or 0
			local heroConfig = db:getCharacterByID(value.actorId)
			if heroConfig.func ~= "health" and force > maxForce then
				maxForce = force
				maxHero = value
			end
	    end
	end

	return maxHero
end

--计算一组英雄的战力
function QHerosUtils:countForceByHeros(actorIds, isLocal)
	if q.isEmpty(actorIds) == true then return 0 end

	local force = 0
	for _,actorId in ipairs(actorIds) do
    	if isLocal then
	    	local heroProp = remote.herosUtil:createHeroPropById(actorId)
	    	if heroProp ~= nil then
	    		force = force + heroProp:getBattleForce(isLocal)
	    	end
	    else
	    	local heroInfo = remote.herosUtil:getHeroByID(actorId)
	    	if heroInfo ~= nil then
    			force = force + heroInfo.force
	    	end
	    end
	end
	return force
end


function QHerosUtils:calculateForceColor(force)
	if force <= 10000 then
		return UNITY_COLOR_LIGHT.white
	elseif force <= 100000 then
		return UNITY_COLOR_LIGHT.green
	elseif force <= 500000 then
		return UNITY_COLOR_LIGHT.blue
	elseif force <= 1000000 then
		return UNITY_COLOR_LIGHT.purple
	elseif force <= 5000000 then
		return UNITY_COLOR_LIGHT.orange
	else
		return UNITY_COLOR_LIGHT.red
	end

	return UNITY_COLOR_LIGHT.white
end

function QHerosUtils:calculateForceColorAndOutline(force)
	if force <= 10000 then
		return FONTCOLOR_TO_OUTLINECOLOR[1]
	elseif force <= 100000 then
		return FONTCOLOR_TO_OUTLINECOLOR[2]
	elseif force <= 500000 then
		return FONTCOLOR_TO_OUTLINECOLOR[3]
	elseif force <= 1000000 then
		return FONTCOLOR_TO_OUTLINECOLOR[4]
	elseif force <= 5000000 then
		return FONTCOLOR_TO_OUTLINECOLOR[5]
	else
		return FONTCOLOR_TO_OUTLINECOLOR[6]
	end

	return FONTCOLOR_TO_OUTLINECOLOR[1]
end

-- 获取神技的显示等级
-- @level 可缺省，缺省时，显示英雄当前的神技等级；也可以指定显示level等级
-- 返回 神技的显示等级和最大真实等级
function QHerosUtils:getGodSkillLevelByActorId(actorId, level)
	local needLevel = nil
	if level then
		needLevel = tostring(level)
	else
		local heroInfo = self:getHeroByID(actorId)
		if not q.isEmpty(heroInfo) and heroInfo.godSkillGrade then
			needLevel = tostring(heroInfo.godSkillGrade)
		end
	end

	local showLevel = -1
	local maxRealLevel = 0
	if needLevel and actorId then
		local godSkillConfig = db:getStaticByName("god_skill")
		local curGodSkillConfig = godSkillConfig[tostring(actorId)]
		if not q.isEmpty(curGodSkillConfig) then
			for _, value in pairs(curGodSkillConfig) do
				if tostring(value.level) == needLevel then
					showLevel = tonumber(value.grade)
				end
				if tonumber(value.level) > maxRealLevel then
					maxRealLevel = tonumber(value.level)
				end
			end
		end
	end

	return showLevel, maxRealLevel
end


return QHerosUtils