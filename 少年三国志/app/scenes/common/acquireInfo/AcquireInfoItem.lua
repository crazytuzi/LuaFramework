--AcquireInfoItem.lua


require("app.cfg.way_function_info")

local FunctionLevelConst = require("app.const.FunctionLevelConst")
local AcquireInfoItem = class("AcquireInfoItem", function ( _, _, jsonName )
	return CCSItemCellBase:create(jsonName or "ui_layout/dropinfo_AcquireItem.json")
end)


function AcquireInfoItem:ctor( ... )
	self._functionId = 0
	self._functionValue = 0
	self._chapterId = 0

	self._funcOpen = false
	self:enableLabelStroke("Label_title", Colors.strokeBrown, 2)
	--self:enableLabelStroke("Label_desc", Colors.strokeBrown, 1)

	self:setTouchEnabled(true)
	self:registerBtnClickEvent("Button_go", function ( widget )
		self:selectedCell(0, 1)

		self:_doWayFunction()
	end)

	self:registerCellClickEvent(function ( ... )
		if self._funcOpen then 
			self:_doWayFunction()
		end
	end)
end

function AcquireInfoItem:_doWayFunction( ... )
	if self._functionId < 1 then 
		return 
	end

	--self._functionId = 3
	--self._functionValue = 6
	local moduleId = 0

	local sceneName = nil
	if self._functionId == 1 then
		sceneName = "app.scenes.dungeon.DungeonMainScene"
	elseif self._functionId == 2 then
		sceneName = "app.scenes.storydungeon.StoryDungeonMainScene"
		moduleId = FunctionLevelConst.STORY_DUNGEON
	elseif self._functionId == 3 then
		sceneName = "app.scenes.shop.ShopScene"
	elseif self._functionId == 4 then
		sceneName = "app.scenes.secretshop.SecretShopScene"
		moduleId = FunctionLevelConst.SECRET_SHOP
	elseif self._functionId == 5 then
		sceneName = "app.scenes.shop.score.ShopScoreScene"
		self._chapterId = 1
		moduleId = FunctionLevelConst.ARENA_SCENE
	elseif self._functionId == 6 then
		self._chapterId = 4
		sceneName = "app.scenes.shop.score.ShopScoreScene"
		moduleId = FunctionLevelConst.TOWER_SCENE
	elseif self._functionId == 7 then
		sceneName = "app.scenes.treasure.TreasureComposeScene"
		moduleId = FunctionLevelConst.TREASURE_COMPOSE
	elseif self._functionId == 8 then
		sceneName = "app.scenes.shop.ShopScene"
	elseif self._functionId == 9 then
		sceneName = "app.scenes.shop.ShopScene"
	elseif self._functionId == 10 then
		--not open at present
		sceneName = "app.scenes.moshen.MoShenScene"
		moduleId = FunctionLevelConst.MOSHENG_SCENE
	elseif self._functionId == 11 then
		sceneName = "app.scenes.recycle.RecycleScene"
	elseif self._functionId == 12 then
		sceneName = "app.scenes.recycle.RecycleScene"
	elseif self._functionId == 13 then 
		sceneName = "app.scenes.vip.VipMapScene"
	elseif self._functionId == 14 then 
		sceneName = "app.scenes.arena.ArenaScene"
	elseif self._functionId == 15 then 
		sceneName = "app.scenes.wush.WushScene"
	elseif self._functionId == 16 then 
		self._chapterId = 2
		sceneName = "app.scenes.shop.score.ShopScoreScene"
		moduleId = FunctionLevelConst.MOSHENG_SCENE
	elseif self._functionId == 17 then
		if G_Me.legionData:hasCorp() then
			sceneName = "app.scenes.legion.LegionScene"
    	else
    		sceneName = "app.scenes.legion.LegionListScene"    	
    	end
	elseif self._functionId == 18 then
		if G_Me.legionData:hasCorp() then
			self._chapterId = 6
			sceneName = "app.scenes.shop.score.ShopScoreScene"
    	else
    		sceneName = "app.scenes.legion.LegionListScene"    	
    	end
	elseif self._functionId == 19 then
		if G_Me.legionData:hasCorp() and G_Me.legionData:getDungeonOpen() then
			sceneName = "app.scenes.legion.LegionNewDungeionScene"
    	else
    		sceneName = "app.scenes.legion.LegionListScene"    	
    	end
	elseif self._functionId == 20 then
		sceneName = "app.scenes.city.CityScene" 	
	elseif self._functionId == 21 then
		if G_Me.legionData:hasCorp() then
			sceneName = "app.scenes.legion.LegionSacrificeScene"
    	else
    		sceneName = "app.scenes.legion.LegionListScene"    	
    	end
	elseif self._functionId == 22 then
		if G_Me.legionData:hasCorp() then
			sceneName = "app.scenes.legion.LegionHallScene"
    	else
    		sceneName = "app.scenes.legion.LegionListScene"    	
    	end
    elseif self._functionId == 23 then
    	sceneName = "app.scenes.wheel.WheelScene"
    elseif self._functionId == 24 then
    	sceneName = "app.scenes.harddungeon.HardDungeonMainScene"
		moduleId = FunctionLevelConst.HARDDUNGEON
    elseif self._functionId == 25 then
    	sceneName = "app.scenes.awakenshop.AwakenShopScene"
		moduleId = FunctionLevelConst.AWAKEN
	elseif self._functionId == 26 then
		sceneName = "app.scenes.bag.BagScene"
		moduleId = FunctionLevelConst.AWAKEN
		self._functionValue = 2
	elseif self._functionId == 27 then
		moduleId = 0
		if self._functionValue == 1 then
			sceneName = "app.scenes.wheel.WheelScene"
		elseif self._functionValue == 2 then
			sceneName = "app.scenes.dafuweng.RichScene"
		elseif self._functionValue == 3 then
			moduleId = FunctionLevelConst.TRIGRAMS
			sceneName = "app.scenes.shop.score.ShopScoreScene"
			self._chapterId = SCORE_TYPE.TRIGRAMS
		end	
	elseif self._functionId == 28 then
		moduleId = FunctionLevelConst.CROSS_WAR
		self._chapterId = 8
		sceneName = "app.scenes.shop.score.ShopScoreScene"
	elseif self._functionId == 29 then
		moduleId = FunctionLevelConst.INVITOR
		self._functionValue = G_Me.activityData:getInvitorIndex()
		sceneName = "app.scenes.activity.ActivityMainScene"
	elseif self._functionId == 30 then
		sceneName = "app.scenes.treasure.TreasureComposeScene"
		moduleId = FunctionLevelConst.TREASURE_SMELT
	elseif self._functionId == 31 then
		sceneName = "app.scenes.crusade.CrusadeScene"
		moduleId = FunctionLevelConst.CRUSADE
	elseif self._functionId == 32 then
		sceneName = "app.scenes.pet.shop.PetShopScene"
		moduleId = FunctionLevelConst.PET_SHOP
	elseif self._functionId == 33 then
		sceneName = "app.scenes.bag.itemcompose.ItemComposeScene"
		moduleId = FunctionLevelConst.ITEM_COMPOSE
	elseif self._functionId == 34 then
		-- 决战赤壁界面不能直接前往（因为活动未配置时没有默认界面），只跳一个提示
		G_MovingTip:showMovingTip(G_lang:get("LANG_TITLE_ACTIVITY_DUANWU"))
		moduleId = FunctionLevelConst.CROSS_PVP
	elseif self._functionId == 36 then
		sceneName = "app.scenes.shop.score.ShopScoreScene"
		moduleId = FunctionLevelConst.DAILY_PVP
		self._chapterId = SCORE_TYPE.DAILY_PVP
	elseif self._functionId == 37 then  -- 点将台
		sceneName = "app.scenes.herosoul.HeroSoulScene"
		moduleId = FunctionLevelConst.HERO_SOUL
	elseif self._functionId == 38 then  -- 名将试炼
		sceneName = "app.scenes.herosoul.HeroSoulScene"
		moduleId = FunctionLevelConst.HERO_SOUL
	elseif self._functionId == 39 then  -- 将灵商店
		sceneName = "app.scenes.herosoul.HeroSoulShopScene"
		moduleId = FunctionLevelConst.HERO_SOUL
	elseif self._functionId == 40 then  -- 奇遇商店, 是积分商店
		sceneName = "app.scenes.shop.score.ShopScoreScene"
		moduleId = FunctionLevelConst.HERO_SOUL
	elseif self._functionId == 41 then  -- 将灵背包，直接分解将灵
		sceneName = "app.scenes.herosoul.HeroSoulScene"
		moduleId = FunctionLevelConst.HERO_SOUL
	end

	__Log("-- self._functionId = %d", self._functionId)

	__Log("AcquireInfoItem function_id:%d, function_value:%d, chapterId:%d", self._functionId, self._functionValue, self._chapterId)
	--dump(self._scenePack)

	if moduleId > 0 and not G_moduleUnlock:checkModuleUnlockStatus(moduleId) then 
		return 
	end

	if moduleId == FunctionLevelConst.TRIGRAMS and G_Me.trigramsData:isClose() then
		G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_ITEM_IS_OVER"))
		return
	end

	self:startGuideIfNeed(self._functionId, self._functionValue, self._chapterId)

	if sceneName then
		if self._functionId == 1 then 
			uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, self._functionValue, self._chapterId, self._scenePack))
		--elseif self._functionId == 3 or self._functionId == 8 or self._functionId == 9 then 

		elseif self._functionId == 29 then 
			uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(self._functionValue))
		elseif self._functionId == 37 then
			uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, self._scenePack, require("app.const.HeroSoulConst").TERRACE))
		elseif self._functionId == 38 then
			uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, self._scenePack, require("app.const.HeroSoulConst").TRIAL))
		elseif self._functionId == 39 then
			uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(self._scenePack))
		elseif self._functionId == 40 then
			uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(SCORE_TYPE.HERO_SOUL,nil,nil,nil, self._scenePack))
		elseif self._functionId == 41 then
			uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, self._scenePack, require("app.const.HeroSoulConst").BAG))
		else
			uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, self._functionValue, self._chapterId, self._scenePack))
		end
	elseif self._functionId == 35 then
		-- 运营活动
		 G_MovingTip:showMovingTip(G_lang:get("LANG_ACQUIRE_ATTENTION"))
	end
end

function AcquireInfoItem:initWithWayId( wayId )
	if not wayId then
		return false
	end

	local wayInfo = way_function_info.get(wayId)
	if not wayInfo then
		__Log("wrong wayId:%d", wayId)
		return false
	end

	self._functionId = wayInfo.function_id
	self._functionValue = wayInfo.function_value
	self._chapterId = wayInfo.chapter_id

	self:getImageViewByName("Image_icon"):loadTexture(G_Path.getWayIcon(wayInfo.icon), UI_TEX_TYPE_LOCAL)

	self:showTextWithLabel("Label_title", wayInfo.name)
	self:showTextWithLabel("Label_desc", wayInfo.directions)

	local curCount = 0
	local maxCount = 0
	if self._functionId == 1 then 
		curCount, maxCount = G_Me.dungeonData:getCurAndMaxChallengeTimes(self._chapterId, self._functionValue)
	elseif self._functionId == 24 then
		curCount, maxCount = G_Me.hardDungeonData:getCurAndMaxChallengeTimes(self._chapterId, self._functionValue)
	end

	if curCount > 0 or maxCount > 0 then 
		self:showTextWithLabel("Label_addition", G_lang:get("LANG_DUNGEON_LEFT_COUNTS", {count1=curCount, count2=maxCount}))
	else
		self:showTextWithLabel("Label_addition", "")
	end

	local isFunctionOpen = function ( funId, funValue, chapterId, level )
		if wayInfo.level > G_Me.userData.level then 
			return false
		end

	 	local flag = true 
		if funId == 1 then 
			if funValue > 0 then 
				flag = not G_Me.dungeonData:isNeedRequestChapter()
				flag = flag and G_Me.dungeonData:isOpenDungeon(chapterId, funValue)
			else
				flag = true
			end
		elseif funId == 2 then
			if funValue > 0 then
				flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.STORY_DUNGEON)
				flag = flag and G_Me.storyDungeonData:isOpenDungeon(funValue)
			end
		elseif funId == 4 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.SECRET_SHOP)
		elseif funId == 5 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ARENA_SCENE)
		elseif funId == 6 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TOWER_SCENE)
		elseif funId == 7 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_COMPOSE)
		elseif funId == 10 then 
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.MOSHENG_SCENE)
		elseif funId == 13 then 
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.VIP_SCENE)
			flag = flag and G_Me.userData.vip >= chapterId or false
		elseif funId == 17 or funId == 18 or funId == 19 or funId == 21 or funId == 22 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.LEGION)
		elseif funId == 20 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CITY_PLUNDER)
    	elseif funId == 24 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HARDDUNGEON)
            if funValue > 0 then 
                    flag = not G_Me.hardDungeonData:isNeedRequestChapter()
                    flag = flag and G_Me.hardDungeonData:isOpenDungeon(chapterId, funValue)
            else
                    flag = true
            end
    	elseif funId == 25 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN)
        elseif funId == 27 then
        	flag = funValue == 1 and (G_Me.wheelData:getState() < 3) or (G_Me.richData:getState() < 3)
        	if funValue == 3 then
        		flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TRIGRAMS)
        	end
    	elseif funId == 29 then
    		flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.INVITOR) and  G_Setting:get("open_invitor") == "1"
    	elseif funId == 30 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_COMPOSE)
		elseif funId == 31 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CRUSADE)
		elseif funId == 32 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.PET_SHOP)
		elseif funId == 33 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ITEM_COMPOSE)
		elseif funId == 34 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP)
		elseif funId == 36 then
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.DAILY_PVP)
		elseif funId == 37 then -- 点将台
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HERO_SOUL)
		elseif funId == 38 then -- 名次试炼
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HERO_SOUL)
		elseif funId == 39 then -- 将灵商店
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HERO_SOUL)
		elseif funId == 49 then -- 奇遇商店 
			flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HERO_SOUL)
		end

		return flag
	end


	self._funcOpen = isFunctionOpen(self._functionId, self._functionValue, self._chapterId, wayInfo.level)
	__Log("initWithWayId:%d function_id:%d, function_value:%d, chapterId:%d, level:%d, open=%d",
	 wayId or 0, self._functionId, self._functionValue, self._chapterId, wayInfo.level, self._funcOpen and 1 or 0)

	self:showWidgetByName("Button_go", self._funcOpen)
	self:showWidgetByName("Image_lock", not self._funcOpen)

	return self._functionId == 1 and G_Me.dungeonData:isNeedRequestChapter()	
end

function AcquireInfoItem:startGuideIfNeed( funId, funValue, chapterId )
	if (funId == 1 and funValue > 0) or funId == 3 or funId == 8 or funId == 9 or funId == 24 then 
		local acquireGuide = require("app.scenes.common.acquireInfo.AcquireInfoGuide")
		if funId == 1 and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.DUNGEON_SAODANG) then
			-- local statgeData = G_Me.dungeonData:getStageData(chapterId, funValue)
   --          if statgeData and statgeData._star == 3 then
			-- 	funId = 20
			-- end
			if G_Me.dungeonData:isOnSweepStatus(chapterId, funValue) then 
				funId = 20
			end
		end

		if funId == 24 and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HARDDUNGEON) then 
			-- local statgeData = G_Me.hardDungeonData:getStageData(chapterId, funValue)
   --          if statgeData and statgeData._star == 3 then
			-- 	funId = 30
			-- end
			if G_Me.hardDungeonData:isOnSweepStatus(chapterId, funValue) then 
				funId = 30
			end
		end

		local ret = acquireGuide.runGuide(funId, chapterId, funValue)
		__Log("runGuide: funId:%d, funValue:%d, chapterId:%d, ret=%d", funId, funValue, chapterId, ret and 1 or 0)
	end
end

function AcquireInfoItem:isOpen()
	return self._funcOpen
end

return AcquireInfoItem

