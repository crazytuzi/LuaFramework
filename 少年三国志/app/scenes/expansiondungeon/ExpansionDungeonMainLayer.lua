local EffectNode = require("app.common.effects.EffectNode")

local ExpansionDungeonMainLayer = class("ExpansionDungeonMainLayer", UFCCSNormalLayer)

local CHAPTER_TOTAL_STAR = 24

local SCROLL_PERCENT = {
	100, 100, 100, 75, 50, 10, 10, 5
}

function ExpansionDungeonMainLayer.create(...)
	return ExpansionDungeonMainLayer.new("ui_layout/expansiondungeon_MainLayer.json", nil, ...)
end

function ExpansionDungeonMainLayer:ctor(json, param, ...)
	self._nMaxChapterId = G_Me.expansionDungeonData:getMaxChapterId()
	self._tChapterList = G_Me.expansionDungeonData:getChapterList()
	self._tScrollView = self:getScrollViewByName("ScrollView_Map")
	assert(self._tScrollView)
	self._tInnerContainer = self._tScrollView:getInnerContainer()

	self._tKnifeEffect = nil
	self._tOpenChapterEffect = nil
	self._hasNewChapter = G_Me.expansionDungeonData:isOpenNewChapter()
	G_Me.expansionDungeonData:setOpenNewChapter(false)

	self._tMapEffect = nil

	G_Me.expansionDungeonData:clearLoginMark()

	self.super.ctor(self, json, param, ...)
end

function ExpansionDungeonMainLayer:onLayerLoad()
	self:_initView()
	self:_addMapEffect()
end

function ExpansionDungeonMainLayer:onLayerEnter()
	self:registerKeypadEvent(true)
	self:adapterWidgetHeight("ScrollView_Map", "", "", 0, 40)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EX_DUNGEON_GET_CHAPTER_LIST_SUCC, self._initLayer, self)

	if G_Me.expansionDungeonData:hasChapterData() then
		self:_initLayer()
	else
		G_HandlersManager.expansionDungeonHandler:sendGetExpansiveDungeonChapterList()
	end
end

function ExpansionDungeonMainLayer:onLayerExit()
	
end

function ExpansionDungeonMainLayer:onLayerUnload()
	
end

-- 如果没有章节数据，要先拉数据
function ExpansionDungeonMainLayer:_initLayer()
	self:_initWidgets()
	self:_updateChatperList()
	self:_adjustMap()
	self:_handlerOpenNewChapter()
end

function ExpansionDungeonMainLayer:_initView()
	G_GlobalFunc.updateLabel(self, "Label_Activity", {stroke=Colors.strokeBrown})
end

function ExpansionDungeonMainLayer:_initWidgets()
	for i=1, expansion_dungeon_chapter_info.getLength() do
		local nChapterId = i
		self:registerBtnClickEvent(string.format("Button_Chapter%d", nChapterId), function()
			self:_onOpenGateLayer(nChapterId, false)
		end)

		local isShowShopEntry = G_Me.expansionDungeonData:isShowChapterShopEntry(nChapterId)
		if isShowShopEntry then
			self:registerBtnClickEvent(string.format("Button_ShopEntry_%d", nChapterId), function()
				self:_onOpenGateLayer(nChapterId, true)
			end)
		end
	end

	self:registerBtnClickEvent("Button_Back", handler(self, self._onClickReturn))

	self:registerBtnClickEvent("Button_Help", function()
		require("app.scenes.common.CommonHelpLayer").show({
			{title=G_lang:get("LANG_EX_DUNGEON_HELP_TITLE1"), content=G_lang:get("LANG_EX_DUNGEON_HELP_CONTENT1")},
			{title=G_lang:get("LANG_EX_DUNGEON_HELP_TITLE2"), content=G_lang:get("LANG_EX_DUNGEON_HELP_CONTENT2")},
			{title=G_lang:get("LANG_EX_DUNGEON_HELP_TITLE3"), content=G_lang:get("LANG_EX_DUNGEON_HELP_CONTENT3")},
    	})
	end)
end

function ExpansionDungeonMainLayer:_onClickReturn()
	uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new(nil, nil, true))
end

function ExpansionDungeonMainLayer:onBackKeyEvent()
    self:_onClickReturn()
    return true
end

function ExpansionDungeonMainLayer:_onOpenGateLayer(nChapterId, isAutoOpenShop)
	local tChapter = self._tChapterList[nChapterId]
	if not tChapter then
		G_MovingTip:showMovingTip(G_lang:get("LANG_EX_DUNGEON_CHAPTER_NOT_OPEN"))
		return
	end

	G_Me.expansionDungeonData:setAtkChapterId(nChapterId)
	local scene = require("app.scenes.expansiondungeon.ExpansionDungeonGateScene").new(nChapterId, isAutoOpenShop)
	uf_sceneManager:replaceScene(scene)
end

function ExpansionDungeonMainLayer:_adjustMap()
	local nOpenChapterCount = table.nums(self._tChapterList)
	if nOpenChapterCount == 0 then
		nOpenChapterCount = 1
	end
	local nPercent = SCROLL_PERCENT[1]
	local nAtkChapterId = G_Me.expansionDungeonData:getAtkChapterId()
	if nAtkChapterId ~= 0 then
		nPercent = SCROLL_PERCENT[nAtkChapterId]
	else
		nPercent = SCROLL_PERCENT[nOpenChapterCount]
	end
	self._tScrollView:scrollToPercentVertical(nPercent, 0, false)
end

function ExpansionDungeonMainLayer:_updateChatperList()
	local nChpaterCount = expansion_dungeon_chapter_info.getLength()
	for i=1, nChpaterCount do
		local tChapterTmpl = expansion_dungeon_chapter_info.indexOf(i)
		local btnChapter = self:getButtonByName(string.format("Button_Chapter%d", i))
		local tChapter = G_Me.expansionDungeonData:getChapterById(tChapterTmpl.id)
		if btnChapter then
			local nChapterStar = 0
			local showGray = true

			if tChapter then
				nChapterStar = G_Me.expansionDungeonData:getChapterStarNum(tChapterTmpl.id)
				showGray = false
			else
				self:showWidgetByName(string.format("Label_Chapter%d", i), false)
				self:showWidgetByName(string.format("Panel_Star%d", i), false)
			end

			G_GlobalFunc.updateLabel(self, string.format("Label_Chapter%d", i), {text=G_lang:get("LANG_EX_DUNGEON_CHAPTER", {num=i, name=tChapterTmpl.name}), stroke=Colors.strokeBrown})
			G_GlobalFunc.updateLabel(self, string.format("Label_StarNum%d", i), {text=nChapterStar.."/"..CHAPTER_TOTAL_STAR, stroke=Colors.strokeBrown})
	        local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
	            self:getLabelByName(string.format("Label_StarNum%d", i)),
	            self:getImageViewByName(string.format("Image_Star%d", i)),
	        }, "C")
	        self:getLabelByName(string.format("Label_StarNum%d", i)):setPositionXY(alignFunc(1))
	        self:getImageViewByName(string.format("Image_Star%d", i)):setPositionXY(alignFunc(2))
	       	self:showWidgetByName(string.format("Image_Star%d", i), true)

	       	btnChapter:showAsGray(showGray)

	       	if self._hasNewChapter then
	       		if tChapter and tChapter._nId == self._nMaxChapterId then
	       			btnChapter:showAsGray(true)
	       			self:showWidgetByName(string.format("Label_Chapter%d", i), false)
					self:showWidgetByName(string.format("Panel_Star%d", i), false)
	       		end
	       	end

	       	local showRedTips = G_Me.expansionDungeonData:showChapterRedTips(tChapterTmpl.id)
	       	self:showWidgetByName(string.format("Image_RedTips%d", i), showRedTips)

	       	local isShowShopEntry = G_Me.expansionDungeonData:isShowChapterShopEntry(tChapterTmpl.id)
	       	self:showWidgetByName(string.format("Panel_Action_%d", i), isShowShopEntry)

	       	if isShowShopEntry then
   		        -- 气泡动画
                local bubble = self:getPanelByName(string.format("Panel_Action_%d", i))
                if bubble then
	                bubble:stopAllActions()
	                bubble:setScale(0.38)
	                bubble:runAction(CCSequence:createWithTwoActions(CCEaseBounceOut:create(CCScaleTo:create(0.5, 1)), CCCallFunc:create(function()
	                    bubble:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(0.4, ccp(0, 5)), CCMoveBy:create(0.4, ccp(0, -5)))))
	                end)))
	            end
	       	end
		end
	end
end

function ExpansionDungeonMainLayer:_addKnifeEffect()
	if G_Me.expansionDungeonData:isPassTotalChapter() then
		return
	end
	if not self._tKnifeEffect then
		self._tKnifeEffect = EffectNode.new("effect_knife")
		local tParent = self:getPanelByName(string.format("Panel_KnifeEffect%d", self._nMaxChapterId))
		if tParent then
			tParent:addNode(self._tKnifeEffect)
			self._tKnifeEffect:play()
		end
	end
end

function ExpansionDungeonMainLayer:_handlerOpenNewChapter()
	if not self._hasNewChapter then
		self:_addKnifeEffect()
		return
	end
	if not self._tOpenChapterEffect then
		self._tOpenChapterEffect = EffectNode.new("effect_qunyinzhan_win", function(event, frameIndex)
			if event == "finish" then
				local btnChapter = self:getButtonByName(string.format("Button_Chapter%d", self._nMaxChapterId))
				if btnChapter then
					btnChapter:showAsGray(false)
					self:showWidgetByName(string.format("Label_Chapter%d", self._nMaxChapterId), true)
					self:showWidgetByName(string.format("Panel_Star%d", self._nMaxChapterId), true)
				end
				self:_addKnifeEffect()

				if self._tOpenChapterEffect then
					self._tOpenChapterEffect:removeFromParentAndCleanup(true)
					self._tOpenChapterEffect = nil
				end
			end
		end)
		local btnChapter = self:getButtonByName(string.format("Button_Chapter%d", self._nMaxChapterId))
		if btnChapter then
			self._tOpenChapterEffect:setScale(1.5)
			btnChapter:addNode(self._tOpenChapterEffect)
			self._tOpenChapterEffect:play()
		end
	end

end

function ExpansionDungeonMainLayer:_getCurrentScrollPercent()
	local posY = self._tInnerContainer:getPositionY()
    local innerContainerTopLeftY = self._tInnerContainer:getContentSize().height
    local scrollAreaHeight = innerContainerTopLeftY - self._tScrollView:getContentSize().height
    return math.abs(1-posY/scrollAreaHeight)
end

function ExpansionDungeonMainLayer:_addMapEffect()
	local bgImg = self:getImageViewByName("ImageView_BG")

	local tParent = bgImg
	if not tParent then
		return
	end
	if not self._tMapEffect and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
		self._tMapEffect = EffectNode.new("effect_qunyingzhan_bg", function(event, frameIndex)
			if event == "finish" then
	
			end
		end)
		self._tMapEffect:play()
		local tSize = tParent:getContentSize()
		self._tMapEffect:setPosition(ccp(tSize.width / 2, tSize.height / 2))
		self._tMapEffect:setScale(1/tParent:getScale())
		tParent:addNode(self._tMapEffect)
	end
end

return ExpansionDungeonMainLayer