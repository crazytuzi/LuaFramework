--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂力试炼数据管理

local QBaseModel = import("...models.QBaseModel")
local QSoulTrial = class("QSoulTrial", QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QActorProp = import("...models.QActorProp")

local lock_max_id = 99999

QSoulTrial.EVENT_SOULTRIAL_UPDATE = "EVENT_SOULTRIAL_UPDATE"
function QSoulTrial:ctor()
	QSoulTrial.super.ctor(self)
end

function QSoulTrial:init()
	self._remoteProexy = cc.EventProxy.new(remote.user)
	self.soulTrialdbConfig = {}

	self.soulTrialConfig = {} -- 按照章节归类整理的量表
	self._isRedTips = false -- 总的小红点
	self._preChapter = nil -- 上一个章节
	self._curChapter = nil -- 当前章节

    self:_analysisConfig()
end

function QSoulTrial:_analysisConfig()
	local config = QStaticDatabase.sharedDatabase():getSoulTrial()
	--QPrintTable(config)
	local tbl = {}
	local tbl2 = {}
	for _, value in pairs(config) do
		-- QPrintTable(value)
		if not tbl[tonumber(value.index)] then
			tbl[tonumber(value.index)] = {}
		end
		if value.id < lock_max_id then
			table.insert(tbl2, value)
			table.insert(tbl[tonumber(value.index)], value)
		end
	end
	for _, value in ipairs(tbl) do
		table.sort(value, function(a, b)
				return tonumber(a.id) < tonumber(b.id)
			end)
	end
	table.sort(tbl2, function(a, b)
		return tonumber(a.id) < tonumber(b.id)
	end)
	self.soulTrialConfig = tbl
	self.soulTrialdbConfig = tbl2
	--QPrintTable(self.soulTrialConfig)
end

function QSoulTrial:disappear()

end

function QSoulTrial:loginEnd()
end

function QSoulTrial:newDayUpdate()
end

function QSoulTrial:openSoulTrial()
	if app.unlock:checkLock("SOUL_TRIAL_UNLOCK", true) == false then
        return
    end
    self._isRedTips = false
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTrialClient"})
end

--------------数据储存.KUMOFLAG.--------------


--------------调用素材.KUMOFLAG.--------------

function QSoulTrial:getGlassImgPath()
	return "ui/Chenghao/chenghao_glass.png"
end

function QSoulTrial:getMaskImgPath()
	return "ui/Chenghao/qiu_mengban.png"
end

function QSoulTrial:getLightImgPath()
	return "ui/Chenghao/qiu_qipao.png"
end

function QSoulTrial:getWaterImgPath()
	return "ui/Chenghao/qiu_yanse.jpg"
end

--------------便民工具.KUMOFLAG.--------------

-- 获取称号名的图片资源
function QSoulTrial:getSoulTrialTitleSpAndFrame( soulTrial )
	if not soulTrial then return nil, nil end
	
	local soulTrial = tonumber(soulTrial)
	local _, preChapter = self:getCurChapter( soulTrial )
	local curBossConfig = self:getBossConfigByChapter( preChapter )
	local url = curBossConfig.title_icon3
	if url then
		local sprite = CCSprite:create(url)
		local frame = QSpriteFrameByPath(url)
		return sprite, frame
	end
	return nil, nil
end

-- 抛出事件，刷新魂师数据，魂师详细面板的数据是前端计算刷新的。
function QSoulTrial:dispatchSoulTrialUpdateHerosEvent()
	self:dispatchEvent({name = QSoulTrial.EVENT_SOULTRIAL_UPDATE})
end

-- 红点规则
function QSoulTrial:redTips()
	-- 根据条件完成情况标记颜色
	-- 修改按钮灰明状态
	local _, curConfig = self:getChapterById( remote.user.soulTrial + 1 )

	if curConfig and #curConfig > 0 then
		if curConfig.boss == 1 then
			local force = remote.herosUtil:getMostHeroBattleForce()
			if force >= curConfig.recommend_force then
				-- print(" QSoulTrial:redTips() true", force, curConfig.recommend_force)
				return true
			end
		end

		local conditionNum = 0
		local completeNum = 0

		-- 条件1
		if curConfig.condition_1 then
			conditionNum = conditionNum + 1
			local isComplete = self:checkCondition(curConfig.condition_1, string.split(curConfig.num_1, ";"))
			if isComplete then
				completeNum = completeNum + 1
			end
		end
		
		-- 条件2
		if curConfig.condition_2 then
			conditionNum = conditionNum + 1
			local isComplete = self:checkCondition(curConfig.condition_2, string.split(curConfig.num_2, ";"))
			if isComplete then
				completeNum = completeNum + 1
			end
		end

		if conditionNum == completeNum then
			-- print(" QSoulTrial:redTips() true", conditionNum, completeNum)
			return true
		end
	end
	-- print(" QSoulTrial:redTips() false")
	return false
end

-- 获得魂力试炼的属性
function QSoulTrial:getSoulTrialProp()
	-- print("  QSoulTrial:getSoulTrialProp() ", remote.user.soulTrial)
	local tbl = {}
	if remote.user.soulTrial ~= nil and remote.user.soulTrial > 0 then
		local _, preChapter = self:getCurChapter( remote.user.soulTrial, true )
		local preBossConfig = self:getBossConfigByChapter( preChapter )
		
		for key, value in pairs( preBossConfig ) do
			if QActorProp._field[key] then
				if not tbl[key] then
					tbl[key] = tonumber(value)
				else
					tbl[key] = tbl[key] + tonumber(value)
				end
			end
		end
	end

	return tbl
end

-- 根据最新激活的章节boss关卡和上一个章节boss关卡信息，获得最新获得的属性数组
function QSoulTrial:getImproveProp( curConfig, preConfig )
	if not curConfig then return {} end
	if not preConfig then preConfig = {} end

	local tbl = {}
	for key, value in pairs(curConfig) do
		if QActorProp._field[key] then
			local addValue = tonumber(value) - tonumber(preConfig[key] or 0)
			if addValue > 0 then
				local name = QActorProp._field[key].archaeologyName or QActorProp._field[key].name
				table.insert(tbl, {name = name, addValue = addValue, oldValue = tonumber(preConfig[key] or 0), newValue = tonumber(value)})
			end
		end
	end

	return tbl
end

-- 获取当前章节数和上一个章节数
function QSoulTrial:getCurChapter( id, isReset )
	-- print("  QSoulTrial:getCurChapter() ", id)
	-- if not isReset and self._curChapter and self._preChapter then
	-- 	return self._curChapter, self._preChapter
	-- end

	if id == 0 then
		return 1, 0
	end

	local chapter, config = self:getChapterById(id)
	local preChapter = 0
	local curChapter = 1
	if config.boss == 1 then
		-- 目前待激活的是新章节的第一个节点
		preChapter = chapter
		curChapter = chapter + 1
	else
		-- 目前待激活的不是新章节的第一个节点
		preChapter = chapter - 1
		curChapter = chapter
	end
	-- self._preChapter = preChapter
	-- self._curChapter = curChapter

	-- return self._curChapter, self._preChapter
	return curChapter, preChapter
end

-- 根据id获取 章节数 和 该id数组
function QSoulTrial:getChapterById( id )
	--local config = QStaticDatabase.sharedDatabase():getSoulTrial()
	local config = self.soulTrialdbConfig
	for _, value in pairs(config) do
		if tonumber(value.id) == id then
			return value.index, value
		end
	end
	return 0, {}
end

-- 根据id获取 当前章节数，以及前后各2个章节的章节数以及相应的boss数组
function QSoulTrial:getChapterListById( id )
	local chapter, config = self:getChapterById(id)
	local curChapter = 0
	if config and config.boss == 1 then
		-- 当前章节
		curChapter = chapter + 1
	else
		-- 当前章节
		curChapter = chapter
	end
	local chapterList = {} -- 章节数list
	local bossDic = {} -- key: 字符串类型的章节数；value：boss数组
	local offsetIndex = -2 
	while true do
		local tmpc = curChapter + offsetIndex
		table.insert(chapterList, tmpc)
		if tmpc >= 0 then
			local tmpConfig = self:getBossConfigByChapter(tmpc)
			if tmpConfig then
				bossDic[tostring(tmpc)] = tmpConfig
				
			else
				print("注意：第"..tmpc.."章节量表，没有配置boss节点！")
			end
		end
		offsetIndex = offsetIndex + 1
		if offsetIndex > 2 then
			break
		end
	end

	table.sort(chapterList, function(a, b)
			return a < b
		end)

	return chapterList, bossDic
end

function QSoulTrial:getBossConfigByChapter( chapter )
	local configs = self.soulTrialConfig[tonumber(chapter)] or {}
	for _, config in ipairs(configs) do
		if config.boss == 1 then
			return config
		end
	end

	return {}
end

-- function QSoulTrial:getResourceByName( name )
-- 	local configs = QStaticDatabase.sharedDatabase():getResource()
-- 	for _, config in ipairs(configs) do
-- 		if config.name == name then
-- 			return config
-- 		else
-- 			local tbl = string.split(config.cname, ",")
-- 			for _, value in ipairs(tbl) do
-- 				if value == name then
-- 					return config
-- 				end
-- 			end
-- 		end
-- 	end

-- 	return nil
-- end

function QSoulTrial:checkCondition( conditionId, numList )
	local conditionId = tonumber(conditionId)
	local returnValue = false
	local isShow = true
	local conditionStr = ""
	if not numList then
		return returnValue, conditionStr, isShow
	end
	if conditionId == 101 then
		returnValue, conditionStr = self:_checkForce(numList[1])
	elseif conditionId == 102 then
		returnValue, conditionStr = self:_checkGrade(numList[1], numList[2])
	elseif conditionId == 106 then
		returnValue, conditionStr = self:_checkArenaRank(numList[1])
	elseif conditionId == 109 then
		returnValue, conditionStr = self:_checkSunWarChapter(numList[1])
	elseif conditionId == 112 then
		returnValue, conditionStr = self:_checkThunderHistoryMaxStar(numList[1])
	elseif conditionId == 117 then
		returnValue, conditionStr = self:_checkEquipmentEnchantMasterLevel(numList[1], numList[2])
	elseif conditionId == 119 then
		returnValue, conditionStr = self:_checkEquipmentMasterLevel(numList[1], numList[2])
	elseif conditionId == 122 then--索托斗魂场历史最高排名N名
		returnValue, conditionStr = self:_checkStormArenaRank(numList[1])
	elseif conditionId == 123 then--N名SS魂师神技达到N星
		returnValue, conditionStr = self:_checkSSHeroGodSkillStar(numList[1], numList[2])
	elseif conditionId == 124 then--N名魂灵强化大师达到N级
		returnValue, conditionStr = self:_checkSoulSpiritMasterLevel(numList[1], numList[2])
	elseif conditionId == 125 then--金属之城通关到N关
		returnValue, conditionStr = self:_checkMetalCityChapter(numList[1])
	elseif conditionId == 126 then--N名魂师仙品升级大师达到N级
		returnValue, conditionStr = self:_checkMagicHerbsMasterLevel(numList[1], numList[2])
	elseif conditionId == 127 then--N个S级武魂真身达到N星
		returnValue, conditionStr = self:_checkArtifactStar(numList[1], numList[2])
	elseif conditionId == 201 then
		returnValue = true
		isShow = false
	end

	return returnValue, conditionStr, isShow
end

-- 战队topn最高战力达到 num
function QSoulTrial:_checkForce( num )
	if not num then return false, "" end
	local num = tonumber(num)
	local force = 0
	if remote.herosUtil:getMostHeroBattleForce() > remote.user.maxHisTopnForce then
		force = remote.herosUtil:getMostHeroBattleForce()
	else
		force = remote.user.maxHisTopnForce
	end
	local n1,u1 = q.convertLargerNumber(force)
	local n2,u2 = q.convertLargerNumber(num)
	return force >= num, "("..n1..u1.."/"..n2..u2..")"
end

-- num1 个魂师的最高星级达到 num2 星
function QSoulTrial:_checkGrade( num1, num2 )
	if not num1 or not num2 then return false, "" end
	local num1 = tonumber(num1)
	local num2 = tonumber(num2)
	local count = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _, actorId in ipairs(heroList) do
		-- local uiHero = remote.herosUtil:getUIHeroByID(actorId)
		local hero = remote.herosUtil:getHeroByID(actorId)
		if hero.grade >= num2 then
			count = count + 1
		end
	end

	return count >= num1, "("..count.."/"..num1..")"
end

-- 斗魂场排名达到 num 名
function QSoulTrial:_checkArenaRank( num )
	if not num then return false, "" end
	local num = tonumber(num)
	return remote.user.arenaTopRank <= num, "("..remote.user.arenaTopRank.."/"..num..")"
end

-- 海神岛通关第 num 章节
function QSoulTrial:_checkSunWarChapter( num )
	if not num then return false, "" end
	local num = tonumber(num)
	local chapterId = remote.sunWar:getLastPassChapterWithLastWaveID()
	return chapterId >= num, "("..chapterId.."/"..num..")"
end

-- 杀戮之塔获得 num 颗星星
function QSoulTrial:_checkThunderHistoryMaxStar( num )
	if not num then return false, "" end
	local num = tonumber(num)
	return (remote.user.thunderHistoryMaxStar or 0) >= num, "("..(remote.user.thunderHistoryMaxStar or 0).."/"..num..")"
end

-- num1 个魂师装备觉醒大师达到 num2 级
function QSoulTrial:_checkEquipmentEnchantMasterLevel( num1, num2 )
	if not num1 or not num2 then return false, "" end
	local num1 = tonumber(num1)
	local num2 = tonumber(num2)
	local count = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _, actorId in ipairs(heroList) do
		local heroUIModel = remote.herosUtil:getUIHeroByID(actorId)
		local masterLevel = heroUIModel:getMasterLevelByType(heroUIModel.EQUIPMENT_ENCHANT_MASTER)
		-- local hero = remote.herosUtil:getHeroByID(actorId)
		if masterLevel >= num2 then
			count = count + 1
		end
	end

	return count >= num1, "("..count.."/"..num1..")"
end

-- num1 个魂师装备强化大师达到 num2 级
function QSoulTrial:_checkEquipmentMasterLevel( num1, num2 )
	if not num1 or not num2 then return false, "" end
	local num1 = tonumber(num1)
	local num2 = tonumber(num2)
	local count = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _, actorId in pairs(heroList) do
		local heroUIModel = remote.herosUtil:getUIHeroByID(actorId)
		local masterLevel = heroUIModel:getMasterLevelByType(heroUIModel.EQUIPMENT_MASTER)
		-- local hero = remote.herosUtil:getHeroByID(actorId)
		if masterLevel >= num2 then
			count = count + 1
		end
	end

	return count >= num1, "("..count.."/"..num1..")"
end
--索托斗魂场历史最高排名num名
function QSoulTrial:_checkStormArenaRank( num )
	local num = tonumber(num)
	return remote.user.stormTopRank <= num, "("..remote.user.stormTopRank.."/"..num..")"
end

-- num1 名SS魂师神技达到 num2 星
function QSoulTrial:_checkSSHeroGodSkillStar( num1, num2 )
	if not num1 or not num2 then return false, "" end
	local num1 = tonumber(num1)
	local num2 = tonumber(num2)
	local count = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _, actorId in ipairs(heroList) do
		-- local uiHero = remote.herosUtil:getUIHeroByID(actorId)
		local character = db:getCharacterByID(actorId)
		if character and character.aptitude == APTITUDE.SS then
			local hero = remote.herosUtil:getHeroByID(actorId)
			if hero.godSkillGrade >= num2 then
				count = count + 1
			end
		end      
	end
	return count >= num1, "("..count.."/"..num1..")"
end


-- num1名魂灵强化大师达到num2级
function QSoulTrial:_checkSoulSpiritMasterLevel( num1, num2 )
	if not num1 or not num2 then return false, "" end
	local num1 = tonumber(num1)
	local num2 = tonumber(num2)
	local count = 0
	local soulSpiritList = remote.soulSpirit:getMySoulSpiritInfoList()
	for _, info in ipairs(soulSpiritList) do
    	local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(info.id)
		if characterConfig then
	    	local _masterConfigListWithAptitude = remote.soulSpirit:getMasterConfigByAptitudeAndMasterLevel(characterConfig.aptitude,num2)
	    	if _masterConfigListWithAptitude then
				if info.level >= _masterConfigListWithAptitude.condition then
					count = count + 1
				end   
	    	end
		end
	end
	return count >= num1, "("..count.."/"..num1..")"
end

--金属之城通关到num关
function QSoulTrial:_checkMetalCityChapter( num )
	if not num then return false, "" end
	local num = tonumber(num)
	local chapterId = remote.metalCity:getMetalCityMyInfo().metalNum or 1
	chapterId = chapterId + 1
	local targetChapterInfo = remote.metalCity:getMetalCityConfigByChapter(num)
	-- local chapterStr = targetChapterInfo.metalcity_chapter or 1
	-- local floorStr = targetChapterInfo.metalcity_floor or 0
	chapterId = tonumber(chapterId)
	print("_checkMetalCityChapter"..chapterId)

	return chapterId >= num, ""
end

-- num1名仙品强化大师达到num2级
function QSoulTrial:_checkMagicHerbsMasterLevel( num1, num2 )
	if not num1 or not num2 then return false, "" end
	local num1 = tonumber(num1)
	local num2 = tonumber(num2)
	local count = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _, actorId in pairs(heroList) do
		local heroUIModel = remote.herosUtil:getUIHeroByID(actorId)
		local masterLevel = heroUIModel:getMasterLevelByType(heroUIModel.MAGICHERB_UPLEVEL_MASTER)
		print("_checkMagicHerbsMasterLevel"..masterLevel)
		if masterLevel >= num2 then
			count = count + 1
		end
	end
	return count >= num1, "("..count.."/"..num1..")"
end

-- num1个S级武魂真身达到num2星
function QSoulTrial:_checkArtifactStar( num1, num2 )
	if not num1 or not num2 then return false, "" end
	local num1 = tonumber(num1)
	local num2 = tonumber(num2)
	local count = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _, actorId in ipairs(heroList) do
		local hero = remote.herosUtil:getHeroByID(actorId)
		if hero.artifact and hero.artifact.artifactBreakthrough and hero.artifact.artifactBreakthrough >= num2 then
			count = count + 1
		end     
	end
	return count >= num1, "("..count.."/"..num1..")"
end

--------------数据处理.KUMOFLAG.--------------

function QSoulTrial:responseHandler( response, successFunc, failFunc )
	-- QPrintTable( response )

	-- self:_calculateForce()

	if successFunc then 
        successFunc(response) 
        -- self:_dispatchAll()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    -- self:_dispatchAll()
end

function QSoulTrial:pushHandler( data )
    -- QPrintTable(data)
end

 --[[
 	//魂力试炼API定义
	USER_SOUL_TRIAL_IMPROVE                     = 204;                      // 玩家魂力试炼进阶，无参数
]]

-- 玩家魂力试炼进阶，无参数
function QSoulTrial:soulTrialImproveRequest(success, fail, status)
    local request = { api = "USER_SOUL_TRIAL_IMPROVE" }
    app:getClient():requestPackageHandler("USER_SOUL_TRIAL_IMPROVE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------



return QSoulTrial
