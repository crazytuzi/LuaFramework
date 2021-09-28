--LegionHitEggLayer.lua


local LegionHitEggLayer = class("LegionHitEggLayer", UFCCSNormalLayer)

function LegionHitEggLayer.create( ... )
	return LegionHitEggLayer.new("ui_layout/legion_DungeonHitEgg.json")
end

function LegionHitEggLayer:ctor( ... )
	self._eggItemList = nil
	self._normalText = {}
	self._hitEggText = {}

	self.super.ctor(self, ...)
end

function LegionHitEggLayer:onLayerLoad( ... )
	self:enableLabelStroke("Label_time", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_left", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_right", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_award_tip", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_jungong", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_jungong_value", Colors.strokeBrown, 1 )

	self:registerBtnClickEvent("Button_return", handler(self, self._onBackClick))
    self:registerBtnClickEvent("Button_preview", handler(self, self._onTreasurePreviewClick))
    self:registerWidgetClickEvent("Image_mm", function ( ... )
    	self:_showDialogueText(2)
    end)
end

function LegionHitEggLayer:onLayerEnter( ... )
	self:callAfterFrameCount(1, function ( ... )
		self:adapterWidgetHeight("Panel_bottom", "Panel_top", "", 0, -50)
		--self:adapterWidgetHeight("Panel_egg_list", "Panel_top", "", 15, 0)
		self:_initEggList()
		
	end)	

	self:initDungeonAwardCorpTip()
	self:_initCountDonwTime()
	self:_initFinishAward()

	local array = CCArray:create()
    array:addObject(CCRotateTo:create(100,180))
    array:addObject(CCRotateTo:create(100,360))
    self:getImageViewByName("Image_22"):runAction(CCRepeatForever:create(CCSequence:create(array)))

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_DUNGEON_AWARD, self._onGetDungeonAward, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_FLUSH_DUNGEON_AWARD, self._onFlushDungeonAward, self)
   	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_DUNGEON_AWARD_CORP_POINT, self._onGetDungeonAwardCorpPoint, self)
   	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
        G_HandlersManager.legionHandler:disposeCorpDismiss(dismiss)
    end, self)

   	self:_initDialogueText()
   	self:_showDialogueText(2) 
   	local appstoreVersion = (G_Setting:get("appstore_version") == "1")
   	if appstoreVersion then 
   	    GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_mm"))
   	end
end

function LegionHitEggLayer:onLayerExit( ... )
	
	self:_removeTimer()
end

function LegionHitEggLayer:_initCountDonwTime( ... )
	self._countDownTime = G_Me.legionData:getLeftDungeonTime()
	local _updateTime = function ( ... )
		if self._countDownTime < 0 then 
			self._countDownTime = 0
			self:_onCountDownFinish()
		end
		local hour = math.floor(self._countDownTime/3600)
		local min = math.floor((self._countDownTime%3600)/60)
		local sec = self._countDownTime%60
		self:showTextWithLabel("Label_time", string.format("%02d:%02d:%02d", hour, min, sec))
		self._countDownTime = self._countDownTime -1	
	end
	_updateTime()
	if not self._timer then 
		self._timer = G_GlobalFunc.addTimer(1,function()
			if _updateTime then 
				_updateTime()
			end
		end)
	end

	self:showTextWithLabel("Label_attack_value", G_lang:get("LANG_LEGION_HIT_EGG_LEFT_COUNT",
	 {leftCount = G_Me.legionData:haveAcquireAward() and 0 or 1}) )
end

function LegionHitEggLayer:_onCountDownFinish( ... )
	self:_removeTimer()

	local corpChapters = G_Me.legionData:getCorpChapters()
	if corpChapters then
		G_HandlersManager.legionHandler:sendGetCorpChapter()
		G_HandlersManager.legionHandler:sendGetDungeonAwardList()
	end
end

function LegionHitEggLayer:_removeTimer( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
	end
end

function LegionHitEggLayer:_initFinishAward( ... )
	local corpChapter = G_Me.legionData:getCorpChapters()
	if not corpChapter then 
		return 
	end
	local chapterInfo = corps_dungeon_chapter_info.get(corpChapter.today_chid or 1)
	if not chapterInfo then 
		return __LogError("[LegionHitEggLayer:_initFinishAward] ")
	end

__Log("canAcquireFinishAward:%d, ", G_Me.legionData:canAcquireFinishAward() and 1 or 0)
	self:showTextWithLabel("Label_jungong_value", chapterInfo.finish_award)

	local hasRight = G_Me.legionData:hasAwardRight()
	local canAcquireAward = G_Me.legionData:canAcquireFinishAward()
	local haveAcquireAward = hasRight and not G_Me.legionData:canAcquireFinishAward()

	self:showWidgetByName("Button_get", (hasRight and canAcquireAward) or (not hasRight))
	self:showWidgetByName("Image_have_get", hasRight and not canAcquireAward)
	self:registerBtnClickEvent("Button_get", function ( ... )
		if not G_Me.legionData:hasAwardRight() then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_HIT_EGG_NO_RIGHT"))
		end

		if corpChapter.hp > 0 then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CHAPTER_FINISH_AWARD_UNCOMPLETE"))
		end
		if not G_Me.legionData:hasAcquireFinishAward() then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CHAPTER_FINISH_AWARD_COMPLETE"))
		end

		G_HandlersManager.legionHandler:sendGetDungeonAwardCorpPoint()
	end)
end

function LegionHitEggLayer:_onBackClick( ... )
	if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionMapScene").new())
	end
end

function LegionHitEggLayer:_initDialogueText( ... )
	require("app.cfg.shop_dialogue_info")
	self._normalText = {}
	self._hitEggText = {}
	for i = 1, shop_dialogue_info:getLength() do
		local dialogue = shop_dialogue_info.indexOf(i)
		if dialogue.type == 5 then 
			if dialogue.trigger == 1 then 
				table.insert(self._hitEggText, dialogue)
			else
				table.insert(self._normalText, dialogue)
			end
		end
	end
end

function LegionHitEggLayer:_showDialogueText( trigger )
	if type(trigger) ~= "number" then 
		return 
	end

	if trigger == 1 and #self._hitEggText < 1 then 
		return 
	elseif trigger == 2 and #self._normalText < 1 then 
		return 
	end

	local index = math.random(trigger == 1 and #self._hitEggText or #self._normalText) 
	local str = (trigger == 1) and self._hitEggText[index] or self._normalText[index]

	self:showTextWithLabel("Label_dialoge_text", str and str["content"] or "")
end

function LegionHitEggLayer:_onTreasurePreviewClick( ... )
	require("app.scenes.legion.LegionTreasurePreviewLayer").show()
end

function LegionHitEggLayer:_initEggList( ... )
	if not self._eggItemList then 
		local panel = self:getPanelByName("Panel_egg_list")
		if panel == nil then
			return 
		end

		self._eggItemList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._eggItemList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionHitEggItem").new(list, index)
    	end)
    	self._eggItemList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1)
    		end
    	end)
    	self._eggItemList:setSpaceBorder(0, 140)
	end

    self._eggItemList:reloadWithLength(16)
end

function LegionHitEggLayer:_onGetDungeonAward( ret, awards )
	self:showTextWithLabel("Label_attack_value", G_lang:get("LANG_LEGION_HIT_EGG_LEFT_COUNT",
	 {leftCount = G_Me.legionData:haveAcquireAward() and 0 or 1}) )

	if self._eggItemList then 
		self._eggItemList:refreshAllCell()
	end

   	self:_showDialogueText(1) 

	if type(awards) == "table" then
		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards, function ( ... )
    	end)
    	self:addChild(_layer)
	end
end

function LegionHitEggLayer:_onFlushDungeonAward( ... )
	if self._eggItemList then 
		self._eggItemList:refreshAllCell()
	end
end

function LegionHitEggLayer:initDungeonAwardCorpTip( ... )
	self:showWidgetByName("Image_finish_award_tip", G_Me.legionData:hasAcquireFinishAward())
end

function LegionHitEggLayer:_onGetDungeonAwardCorpPoint( ret, corpPoint, hasPoint )
	self:initDungeonAwardCorpTip()
	self:_initFinishAward()
	if type(corpPoint) == "number" and corpPoint > 0 then
		G_flyAttribute.addNormalText(G_lang:get("LANG_LEGION_CHAPTER_FINISH_AWARD_GET", {contriCount = corpPoint}), Colors.titleGreen)
		G_flyAttribute.play(function ( ... )
		end)
	end
end

return LegionHitEggLayer
