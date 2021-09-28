--GuideManager.lua

require("app.cfg.newplay_guide_info")
require("app.cfg.function_stage_info")

local GuideManager = class("GuideManager")


function GuideManager:ctor( ... )
	self._currentStep = 0
	self._isGuiding = false

	self._maxGuideStep = 10000000
	--self._maxGuideStep = newplay_guide_info.getLength()
	self._guideData = nil
	self._filterLayer = nil
	self._hasCreateRole = false

	self._unlockGuideSteps = nil
	self._boxGuideList = {}

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ALL_DATA_READY, handler(self,self._onReady), self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GUIDE_MODULE_STEP_ID, self._onModuleGuide, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CREATED_ROLE, self._onCreateRole, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DUNGEON_EXECUTESTAGE, self._onDungeonExecuteStage, self)
end

function GuideManager:_initGuideInfo(  )
	self._currentStep = G_Me.userData.guide_id
	-- tip1: the code below can change the guide id forcely
	-- self._currentStep = 1901
	__Log("guide from step:[%d]", self._currentStep)

	-- tip2: the code below can force to finish guide
	-- self._currentStep = 63
	-- G_HandlersManager.guideHandler:sendSaveGuideId(self._currentStep)

	__Log("reset to step:[%d]", self._currentStep)
	--if newplay_guide_info.getLength() <= self._currentStep then
	if self._maxGuideStep <= self._currentStep then
		self._currentStep = -1
	end	

	self:_initBoxGuide()
	--self._unlockGuideSteps = G_moduleUnlock:checkUnopenModuleGuide(self._currentStep) or {}
	--dump(self._unlockGuideSteps)
end

function GuideManager:_onReady( ... )
	self:_initGuideInfo()
	if self._currentStep < 0 or not SHOW_NEW_USER_GUIDE then
		 uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ENTER_GAME, nil, false) 
		 uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
		 return
	end

	local startGuide = function ( ... )
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_GUIDE_START, self._currentStep)
		self:_runNextGuideStep( true )
	end

	if self._hasCreateRole then 

		local battleScene = require("app.scenes.guide.GuideBattleScene").new(0,2, nil, function ( ... )

	    		local secondCaption = require("app.scenes.guide.CaptionsScene").new(nil, nil, "LANG_GUIDE_CAPTION_TEXT_2", function ( ... )
	                		startGuide()
	            		end)

	    	        	uf_sceneManager:replaceScene(secondCaption)

	    	        	self._hasCreateRole = false

		end)
		uf_sceneManager:replaceScene(battleScene)

	else
		startGuide()
	end	
end

function GuideManager:isCurrentGuiding( ... )
	return self._isGuiding
end

function GuideManager:_initForGuide(  )
	if not self._filterLayer then
		self._filterLayer = require("app.scenes.guide.GuideFilterLayer").create()
	end
end

-- 增加对主线副本地图宝箱的领取监听，有两个宝物需要做引导
function GuideManager:_initBoxGuide( ... )
	local _doInitBoxGuide = function ( ... )
		
		self._boxGuideList = {}
		for loopi = 1, function_stage_info.getLength(), 1 do 
			local funStageInfo = function_stage_info.get(loopi)
			if funStageInfo then 
				local data = G_Me.dungeonData:getStageData(funStageInfo.chapter_id, funStageInfo.stage_id)
				__Log("-------gudie:chapter_id:%d, stage_id:%d", funStageInfo.chapter_id, funStageInfo.stage_id)
				if data and not data._isFinished then 
				--if data then
					--if funStageInfo and G_Me.dungeonData:isOpenDungeon(funStageInfo.chapter_id, funStageInfo.stage_id) then
					table.insert(self._boxGuideList, #self._boxGuideList + 1, {funStageInfo.stage_id, funStageInfo.guideStartId})
				end
			end
		end
		dump(self._boxGuideList)

		if #self._boxGuideList > 0 then 
			uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DUNGEON_EXECUTESTAGE, self._onDungeonExecuteStage, self)
		else
			uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_DUNGEON_EXECUTESTAGE)
		end
	end
	if G_Me.dungeonData:isNeedRequestChapter() then 
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DUNGEON_RECVCHAPTERLIST, function ( ... )
            _doInitBoxGuide()
        end, self)
	else
		_doInitBoxGuide()
	end
end

function GuideManager:_onDungeonExecuteStage( data )
	if not data or #self._boxGuideList < 1 then 
		return 
	end

	for key, value in pairs(self._boxGuideList) do 
		if type(value) == "table" and value[1] == data.id then 
			self:_startStageGuide(value[2])
			--uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GUIDE_STAGE_GUIDE, nil, true, value[2] or 0)
			table.remove(self._boxGuideList, key)

			if #self._boxGuideList < 1 then 
				uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_DUNGEON_EXECUTESTAGE)
			end
			return 
		end
	end
end

-- 开始宝箱引导
function GuideManager:_startStageGuide( stepId )
	if type(stepId) ~= "number" or stepId < 1 then 
		return 
	end

	local checkEquipGuide = function ( guideId )
		if type(guideId) ~= "number" or guideId < 1 then 
			return 0
		end

		local funStage = function_stage_info.get(1)
		if not funStage or funStage.guideStartId ~= guideId then 
			return guideId
		end

		local equips = G_Me.formationData:getFightEquipByPos(1, 1) or {}
		if not equips["slot_1"] or equips["slot_1"] < 1 then 
			return guideId
		else 
			local equipmentInfo = G_Me.bagData.equipmentList:getItemByKey(equips["slot_1"])
			if not equipmentInfo then 
				return 0
			elseif equipmentInfo.level == 1 then
				return 1701
			else
				return 0
			end
		end
	end

	local equipGuide = checkEquipGuide(stepId)
	__Log("_startStageGuide:stepId:%d, equipGuide:%d", stepId, equipGuide)
	if equipGuide < 1 then 
		return 
	end

	self._currentStep = equipGuide
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_GUIDE_START, stepId)
	self:_runGuideStep(false)
	if self._filterLayer then 
		self._filterLayer:resetFilterScene(uf_sceneManager:getCurScene())
	end
	G_HandlersManager.guideHandler:sendSaveGuideId(self._currentStep)
end

-- 开始下一步引导
-- isStart:是否是引导首步
function GuideManager:_runNextGuideStep( isStart )
	isStart = isStart or false

	local curStepInfo = newplay_guide_info.get(self._currentStep)
	if isStart then
		if curStepInfo and curStepInfo.reset_Id >= 0 then
			__Log("reset step from [%d] to [%d]", self._currentStep, curStepInfo.reset_Id)
			self._currentStep = curStepInfo.reset_Id
		else
			self._currentStep = self._currentStep + 1	
		end
	elseif curStepInfo and curStepInfo.next_step > 0 then
		self._currentStep = curStepInfo.next_step
	else 
		self._currentStep = self._currentStep + 1
	end

	if curStepInfo and self:_checkStepFinish(self._currentStep) then
		local nextStepInfo = newplay_guide_info.get(self._currentStep)
		local isInValidStep = true
		local count = 0
		while nextStepInfo and isInValidStep and count < 10 do
			count = count + 1
			if nextStepInfo.jump_step > 0 then
				self._currentStep = nextStepInfo.jump_step
			end
			__Log("curStepInfo:jump_step:%d, _currentStep:%d", nextStepInfo.jump_step, self._currentStep)
			--self:_runGuideStep(isStart)
			nextStepInfo = newplay_guide_info.get(self._currentStep)
			isInValidStep = nextStepInfo and self:_checkStepFinish(self._currentStep)
		end

		self:_runGuideStep(isStart)
	else
		self:_runGuideStep(isStart)
	end
end

-- 检查引导步骤的条件是否满足（硬代码）
function GuideManager:_checkStepFinish( guideId )
	if type(guideId) ~= "number" or guideId < 1 then 
		return false
	end

	local guideData = newplay_guide_info.get(guideId)
	if not guideData or guideData.check_data == 0 then 
		return false
	end

	-- æ£€æŸ¥å…³å¡æ˜¯å¦æ‰“è¿‡äº†
	local _checkBattle = function ( stepId, battleId )
		if type(battleId) ~= "number" then 
			return false
		end

		local dunegonData = G_Me.dungeonData:getStageData(1, battleId)
		if not dunegonData then
		__Log("dungeonData is nil") 
			return false
		end

		return dunegonData._star > 0 or dunegonData._isFinished
	end
	-- æ£€æŸ¥é˜µå®¹ä½æ˜¯å¦åŠ è¿‡æ­¦å°†äº?
	local _addKnight = function ( stepId, heroIndex )
		if type(heroIndex) ~= "number" then 
			return false
		end

		local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, heroIndex)
		return knightId and knightId > 0
	end
	-- æ£€æŸ¥è£…å¤‡ä½æ˜¯å¦ä¸Šè¿‡è£…å¤‡äº?
	local _addFightEquip = function ( stepId, equipIndex )
		if type(equipIndex) ~= "number" then 
			return false
		end

		local equipId = G_Me.formationData:getFightEquipmentBySlot(1, 1, 1)
		return equipId and equipId > 0
	end

	local _addFightTreasure = function ( stepId, equipIndex )
		local equipId = G_Me.formationData:getFightTreasureBySlot(1, 1, 1)
		local requireEquip = G_Me.bagData:getTreasureListByType(1)

		return (equipId and equipId > 0) or (#requireEquip < 1)
	end

	-- æ£€æŸ¥é˜µå®¹ç•Œé¢è£…å¤?æ­¦å°†æ˜¯å¦å®Œæˆå¼•å¯¼
	local _heroLayerGuide = function ( guideData, param )
		if not guideData then 
			return false
		end

		if guideData.click_widget == "Button_1" then 
			return _addFightEquip(guideData.step_id, param)
		elseif guideData.click_widget == "Button_5" then 
			return _addFightTreasure(guideData.step_id, param)
		else
			return _addKnight(guideData.step_id, param)
		end
	end
	-- æ£€æŸ¥å®ç®±æ˜¯å¦èŽ·å–è¿‡
	local _getBoxBonus = function ( stepId, boxIndex )
		if type(boxIndex) ~= "number" then 
			return false
		end

		__Log("boxIndex:%d", boxIndex)
		if boxIndex > 0 and boxIndex < 1000 then
			local dunegonData = G_Me.dungeonData:getStageData(1, boxIndex)
			dump(dunegonData)
			if not dunegonData then 
				return false
			end
			return dunegonData._isFinished
		elseif boxIndex > 1000 then
			local status1, status2, status3 = G_Me.dungeonData:getBoxStuatus(1)
			if boxIndex == 1001 then 
				return status1
			elseif boxIndex == 1002 then 
				return status2
			elseif boxIndex == 1003 then 
				return status3
			end

			return false
		else
			return false
		end
	end
	local _chooseKnight = function ( stepId, knightType )
		local ret = G_Me.shopData:isGodlyKnightDropEnabled() 
		if (not ret) and (not G_Me.shopData:checkDropInfo()) then 
			ret = true
		end
		return not ret
	end

	local _knightStrength = function ( stepId, knightLevel )
		local knightList = G_Me.bagData.knightsData:getKnightsIdListCopy() or {}
		if #knightList < 2 then 
			return false
		end

		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightList[2] or 0)
		dump(knightInfo)
		if not knightInfo then 
			return false
		end

		return knightInfo["level"] ~= knightLevel
	end
	local _knightJingjie = function ( stepId, jingJieLevel )
		if type(jingJieLevel) ~= "number" or jingJieLevel < 1 then 
			return false
		end

		local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
		local mainKnightInfo = knight_info.get(baseId)
		__Log("mainKnightInfo:%d, advanced_level:%d", mainKnightInfo and 1 or 0,
		 mainKnightInfo and mainKnightInfo.advanced_level or 0)
		if not mainKnightInfo then 
			return false
		end

		__Log("advanced_level:%d, jingJieLevel:%d", mainKnightInfo.advanced_level, jingJieLevel)
		return mainKnightInfo.advanced_level >= jingJieLevel
	end
	local _knightStrengthJingjie = function ( stepId, param )
		if stepId < 50 then 
			return _knightStrength(stepId, param)
		else
			return _knightJingjie(stepId, param)
		end
	end

	local _mingxingLevel = function ( stepId, mingXingCount )
		if type(mingXingCount) ~= "number" or mingXingCount < 1 then 
			return false
		end

		local lastMingXingId = G_Me.sanguozhiData:getLastUsedId() or 0
		local fragmentCount = G_Me.bagData:getSanguozhiFragmentCount() or 0

		__Log("lastMingXingId:%d, fragmentCount:%d", lastMingXingId, fragmentCount)
		return (lastMingXingId >= mingXingCount) or (fragmentCount < mingXingCount)
	end
	
	local _equipStrength = function ( stepId, equipLevel )
		if type(equipLevel) ~= "number" or equipLevel < 1 then 
			return false
		end

		local fightEquipment = G_Me.formationData:getFightEquipmentBySlot(1, 1, 1) or 0
		local equipmentInfo = G_Me.bagData.equipmentList:getItemByKey(fightEquipment)
		if not equipmentInfo then 
			return false
		end

		return equipmentInfo["level"] >= equipLevel
	end

	local _recycleKnight = function ( stepId, knightQuality )
		local _knights = {}
    	local knightList = G_Me.bagData.knightsData:getKnightsList()
    	require "app.cfg.knight_info"
    
    	for key, knight in pairs(knightList) do
        	local knightBaseInfo = knight_info.get(knight.base_id)
        	if knightBaseInfo and knightBaseInfo.potential >= 12 and knightBaseInfo.potential <= 13 and 
            	G_Me.formationData:getKnightTeamId(knight.id) == 0 then
           	 	knight.potential = knight_info.get(knight.base_id).potential
            	_knights[#_knights + 1] = knight
        	end
    	end

    	return #_knights < 1
	end

	local _wushLayer = function ( stepId, param )
		local curStep = G_Me.wushData:getFloor() or 0
		return curStep > 1
	end

	local _vipLayer = function ( stepId, param )
		local count = G_Me.vipData:getLeftCount() or 0
		if count < 1 then 
			return true
		end

		return G_Me.userData.vit < 20
	end

	local _shopScoreBuy = function ( stepId, param )
		return G_Me.shopData:checkScoreMaxPurchaseNumber(10029) or false
	end

	local _checkTreasureCompose = function ( guideData, param )
		if not guideData then 
			return true
		end

		if guideData.click_widget == "Panel_pageView" then 
			return not G_Me.bagData:checkFragmentForGuide()
		elseif guideData.click_widget == "Button_compose" then 
			return not G_Me.bagData:checkSiMaFaForGuide()
		elseif guideData.click_widget == "Panel_listViewContainer" then
			return G_Me.bagData.treasureList:getCount() < 1
		end

		return false
	end

	local _checkHaveEquip = function ( stepId, param )
		return G_Me.bagData.equipmentList:getCount() < 1
	end

	local _checkValidStrength = function( stepId, param )
		local firstTeam = G_Me.formationData:getFirstTeamKnightIds()
		local secondTeam = G_Me.formationData:getSecondTeamKnightIds()

		local exceptArr = {}
		if firstTeam then
			table.foreach(firstTeam, function ( i , value )
				if value > 0 then
					exceptArr[value] = 1
				end
			end)
		end
		if secondTeam then
			table.foreach(secondTeam, function ( i , value )
				if value > 0 then
					exceptArr[value] = 1
				end
			end)
		end
		if self._mainKnightId ~= nil and exceptArr[self._mainKnightId] == nil then
			exceptArr[self._mainKnightId] = 1
		end

		self._materialKnights = G_Me.bagData.knightsData:getMaterialKnight( exceptArr )
		return #self._materialKnights < 5
	end

	local _checkHaveEnoughItem = function ( stepId, param )
		return G_Me.userData.spirit >= 200 or G_Me.bagData.propList:getCount() < 2 
	end

	local ret = false
	if guideData.layer_name == "DungeonEnterGateLayer" then 
		ret = _checkBattle(guideId, guideData.check_data)
	elseif guideData.layer_name == "heroArray" then
		ret = _heroLayerGuide(guideData, guideData.check_data)
	elseif guideData.layer_name == "DungeonTopLayer" then
		ret = _getBoxBonus(guideId, guideData.check_data)
	elseif guideData.layer_name == "ShopDropMainLayer" then
		ret = _chooseKnight(guideId, guideData.check_data)
	elseif guideData.layer_name == "ShopDropGodlyKnightLayer" then
		ret = _chooseKnight(guideId, guideData.check_data)
	elseif guideData.layer_name == "heroDevelopLayer" then
		ret = _knightStrength(guideId, guideData.check_data)
	elseif guideData.layer_name == "HeroJingJieLayer" then
		ret = _knightJingjie(guideId, guideData.check_data)
	elseif guideData.layer_name == "Sanguozhi" then
		ret = _mingxingLevel(guideId, guideData.check_data)
	elseif guideData.layer_name == "HeroFosterLayer" then
		ret = _knightStrengthJingjie(guideId, guideData.check_data)
	elseif guideData.layer_name == "DevelopeLayer" then
		ret = _equipStrength(guideId, guideData.check_data)
	elseif guideData.layer_name == "RecycleKnightMainLayer" then
		ret = _recycleKnight(guideId, guideData.check_data)
	elseif guideData.layer_name == "WushMainLayer" then
		ret = _wushLayer(guideId, guideData.check_data)
	elseif guideData.layer_name == "VipMapLayer" then
		ret = _vipLayer(guideId, guideData.check_data)
	elseif guideData.layer_name == "ShopScoreLayer" then
		ret = _shopScoreBuy(guideId, guideData.check_data)
	elseif guideData.layer_name == "TreasureListLayer" then
		ret = _checkTreasureCompose(guideData, guideData.check_data)
	elseif guideData.layer_name == "EquipmentListLayer" then
		ret = _checkHaveEquip(guideId, guideData.check_data)
	elseif guideData.layer_name == "HeroStrengthChoose" then
		ret = _checkValidStrength(guideId, guideData.check_data)
	elseif guideData.layer_name == "BagLayer" then
		ret = _checkHaveEnoughItem(guideId, guideData.check_data)
	end

	__Log("_checkStepFinish:layer[%s], checkData[%d], ret[%d]", guideData.layer_name, guideData.check_data, ret and 1 or 0)
	return ret
end

function GuideManager:_runGuideStep( isStart )
	self._guideData = newplay_guide_info.get(self._currentStep)

	local __should_force_end_guide_ = function ( guideId )
		-- if guideId == 1002 then 
		-- 	return true
		-- end

		return false
	end

	if __should_force_end_guide_(self._currentStep) or not self._guideData then
		self._isGuiding = false
		__LogError("invalid guide step:%d, end to mainScene", self._currentStep or 0)
		self:exitGuide( isStart )
		uf_keypadHandler:enableKeypadEvent(true)
		return 
	end

	uf_keypadHandler:enableKeypadEvent(false)
	self._isGuiding = true
	self:_doStep(isStart)
end

function GuideManager:exitGuide( isStart )
	if self._filterLayer then
		self._filterLayer:finishGuide()
		self._filterLayer = nil
	end

	self._currentStep = 1000000
	G_HandlersManager.guideHandler:sendSaveGuideId(self._currentStep)
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_GUIDE_END, self._currentStep)
	uf_funcCallHelper:callNextFrame(function ( ... )
		self:checkUnlockGuideSteps(isStart)
	end, self)

	--uf_eventManager:removeListenerWithTarget(self)
	if isStart then
		uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
	end	
end

function GuideManager:quitGuide( ... )
	if self._filterLayer then
		self._filterLayer:finishGuide()
		self._filterLayer = nil
	end
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_GUIDE_END, self._currentStep)
	self._unlockGuideSteps = {}
end

function GuideManager:_onModuleGuide( stepId, comment, start )
	stepId = stepId or 0
	if stepId < 1 then 
		return false
	end

	__Log("--------run module guide:stepId=%d, comment=%s--------", stepId, comment)

	self._currentStep = stepId
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_GUIDE_START, self._currentStep)
	self:_runGuideStep(start)
	G_HandlersManager.guideHandler:sendSaveGuideId(self._currentStep)

	return true
end

function GuideManager:_onCreateRole( ... )
	self._hasCreateRole = true
end

function GuideManager:_prepareDataForStep( guideData )
	if not guideData then
		return 
	end

	-- 新手第一次进入游戏时，不是通过副本主界面进入的，所以需要手动配置章节数据
	if guideData.step_id == 1 and G_Me.dungeonData then
		--__Log("step_id:%d, scene_param1:%d", guideData.step_id, guideData.scene_param1)
		G_Me.dungeonData:setCurrChapterId(1)
		G_HandlersManager.guideHandler:sendSaveGuideId(1)
	end
end

function GuideManager:_doStep( isStart )
	__Log("Run Step:[%d] ", self._currentStep)
	local finishGuideCallback = function ( event, param )
		self:_onFinishGuideStep( event, param )
	end

	local __createGuideScene = function ( isStart, sceneName, guideData, callbackFunc )
		if not sceneName or not guideData then
			return nil
		end

		local scenePair = {
			["CaptionsScene"] = {"app.scenes.guide.CaptionsScene", true, },
			["GuideScene"] = {"app.scenes.guide.GuideScene", true, },
			["GuideBattle"] = {"app.scenes.guide.GuideBattleScene", true,},
			["MainScene"] = {"app.scenes.mainscene.MainScene", false,},
			["DungeonMainScene"] = {"app.scenes.dungeon.DungeonMainScene", false,},
			["DungeonGateScene"] = {"app.scenes.dungeon.DungeonGateScene", false,},
			["HeroScene"] = {"app.scenes.hero.HeroScene", false, },
			["ShopScene"] = {"app.scenes.shop.ShopScene", false,},
			["VipMapScene"] = {"app.scenes.vip.VipMapScene", false,},
			["PlayingScene"] = {"app.scenes.mainscene.PlayingScene", false},
			["WushScene"] = {"app.scenes.wush.WushScene", false},
			["SanguozhiMainScene"] = {"app.scenes.sanguozhi.SanguozhiMainScene", false},
			["ShopScoreScene"] = {"app.scenes.shop.score.ShopScoreScene", false},
		}

		if scenePair[sceneName] then
			local scene = require(scenePair[sceneName][1])
			if not scenePair[sceneName][2] and not isStart then
				return nil
			end

			if scene and not scene._guide_create_ then
				scene._guide_create_ = function ( step_id, callbackFunc )
					if scenePair[sceneName][2] then
						return scene.new(step_id, nil, callbackFunc)
					else
						return scene.new()
					end
				end
			end

			self:_prepareDataForStep(guideData)
			return scene._guide_create_(guideData.step_id, callbackFunc)
		else
			__Log("scenePair for %s is nil", sceneName)
		end
	end

	local __createGuideLayer = function ( guideData, callbackFunc )
		if guideData.layer_name == "DungeonStoryTalkLayer" and guideData.text_id > 0 then
			uf_notifyLayer:getModelNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create(
					{storyId = guideData.text_id, func = function ( ... )
					callbackFunc()
				end }))
			return true
		end

		return false
	end

	local layer = __createGuideLayer(self._guideData,
		function ( ... )
			__Log("finish1")
			self:_onFinishGuideStep(0)
		end)
	
	if not self._filterLayer then
		self:_initForGuide()
	end
	self._filterLayer:filterWithStepId(self._currentStep, finishGuideCallback)

	-- 如果当前是引导的开始，则首个场景可能需要被引导创建出来
	local scene = __createGuideScene( isStart, self._guideData.scene_name,self._guideData, function ( ... )
			__Log("finish2")
		self:_onFinishGuideStep(0)
	end)
	if scene then
		uf_sceneManager:popToRootAndReplaceScene(scene)
	end
end

function GuideManager:_onFinishGuideStep( event, param )
	-- 当前步骤为“结束”或“事件等待结束”时，则认为该步骤已结束
	param = param and 1 or 0
	__Log("finish current step:[%d] and event:%d, param:%d, saveFlag:%d",
	 self._currentStep, event, param, ((event == 0) or (event == 1 and param == 1)) and 1 or 0)
	
	if (event == 0) or (event == 1 and param == 1) then
		-- 如果当前步骤是辅助步骤，则不保存该引导步骤
		if self._guideData and self._guideData.is_assistant < 1 then
			__Log("save guide step id:[%d]", self._currentStep)
			G_HandlersManager.guideHandler:sendSaveGuideId(self._currentStep)
		end
	end
	
	if event == 0 then 
		self:_runNextGuideStep()
	end
end

function GuideManager:checkUnlockGuideSteps( start )
	if not self._unlockGuideSteps or #self._unlockGuideSteps < 1 then 
		return 
	end

	local firstGuide = self._unlockGuideSteps[1]
	table.remove(self._unlockGuideSteps, 1)

	if type(firstGuide) == "table" and #firstGuide > 0 then
		self:_onModuleGuide(firstGuide[1], firstGuide[2], start)
	end
end

return GuideManager
