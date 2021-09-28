local function _updateLabel(target, name, params)
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, 1)
    end
   
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end 
end

local function _updateImageView(target, name, params)
    local img = target:getImageViewByName(name)
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end 
end

local TimeDungeonMainLayer = class("TimeDungeonMainLayer", UFCCSNormalLayer)

local DESC_STAGE = {
	OPEN = 1,
	CLOSE = 2,
}

local MAX_STAGE_COUNT = 8

function TimeDungeonMainLayer.create(nChapterId, nEndTime, scenePack, isAutoOpenDesc, ...)
    return TimeDungeonMainLayer.new("ui_layout/timedungeon_TimeDungeonMainLayer.json", nil, nChapterId, nEndTime, scenePack, isAutoOpenDesc, ...)
end

function TimeDungeonMainLayer:ctor(json, param, nChapterId, nEndTime, scenePack, isAutoOpenDesc, ...)
	self.super.ctor(self, json, param, ...)
	self:adapterWithScreen()
	
	self._tCurDungenoInfo = G_Me.timeDungeonData:getCurDungeonInfo()
	self._nCurIndex = self._tCurDungenoInfo and self._tCurDungenoInfo._nIndex or 1
	self._nChapterId = nChapterId or 1
	self._nEndTime = nEndTime or 1
	self._scenePack = scenePack
	self._isAutoOpenDesc = isAutoOpenDesc or false
	self._nDescState = DESC_STAGE.OPEN

	self._isOnProcess = false

	self:_initWidgets()
	self:_registerBtnEvent()
	self:_loadMap()
	self:_initRoad()
	self:_scrollToBottom()
	self:_addMapEffect()
end

function TimeDungeonMainLayer:onLayerEnter()
	self:registerTouchEvent(false,false,0)
	self:registerKeypadEvent(true)
	-- 限时挑战请求战斗成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_DUNGEON_OPEN_BATTLE_SCENE, self._onOpenBattleScene, self)
	-- 若GM后台修改了正在进行的活动的结束时间，要判断下当前是否还处在活动中，不在，则把玩家T到征战界面
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_DUNGEON_CHECK_HAS_DUNGEON, self._onCheckDungeonFinished, self)


	self:adapterWidgetHeight("ScrollView_Knight", "", "", 0, 0)
	self:_updateStage()
	self:_showDescOnEnter()

	self._tTimer = G_GlobalFunc.addTimer(1, handler(self, self._showCountDown))
end

function TimeDungeonMainLayer:onLayerExit()
	if self._tTimer then
		G_GlobalFunc.removeTimer(self._tTimer)
		self._tTimer = nil
	end
	uf_eventManager:removeListenerWithTarget(self)
end

function TimeDungeonMainLayer:_initWidgets()
	-- 剧情简介
	_updateLabel(self, "Label_Intro", {text=G_lang:get("LANG_STORYDUNGEON_INTRO"), stroke=Colors.strokeBrown})
	local tChapterTmpl = time_dungeon_chapter_info.get(self._nChapterId)
	if tChapterTmpl then
		_updateLabel(self, "Label_Desc", {text=tChapterTmpl.directions, stroke=Colors.strokeBrown})
	end
	
	-- 主要产出物
	self:_mainProduct()
	-- 副本标题
	_updateImageView(self, "Image_Title", {texture=G_Path.getTimeDungeonChapterNameImage(self._nChapterId)})
	-- 副本难度
	local nStageId = self._tCurDungenoInfo and self._tCurDungenoInfo._nId or 1
	local tStage = time_dungeon_stage_info.get(nStageId)
	if tStage then
		_updateLabel(self, "Label_Difficulty", {text=G_lang:get("LANG_TIME_DUNGEON_DIFFICULTY", {num=tStage.level_min}), stroke=Colors.strokeBrown})
	end
	-- 当前累计
	self:_curTotalGet()


	self._labelEndTime = self:getLabelByName("Label_EndTime")
 	self._labelTime = self:getLabelByName("Label_Time")
 	self._btnDesc = self:getButtonByName("Button_Desc")
 	_updateLabel(self, "Label_EndTime", {text=""})
 	_updateLabel(self, "Label_Time", {text=""})
end

function TimeDungeonMainLayer:_registerBtnEvent()
	-- 帮助按钮
	self:registerBtnClickEvent("Button_Help", handler(self, self._onOpenHelpLayer))
	-- 返回按钮
	self:registerBtnClickEvent("Button_Back", handler(self, self._onClickReturn))
	-- 副本介绍
	self:registerBtnClickEvent("Button_Desc", handler(self, self._openAndCloseDesc))
	-- 布阵
	self:registerBtnClickEvent("Button_Lineup", handler(self, self._onClickLineup))
end

-- 主要产出物
function TimeDungeonMainLayer:_mainProduct()
	local tChapterTmpl = time_dungeon_chapter_info.get(self._nChapterId)
	if tChapterTmpl then
		local nType = tChapterTmpl.item_type
		local nValue = tChapterTmpl.item_value
		local nSize = 1
		local tGoods = G_Goods.convert(nType, nValue, nSize)
		local imgBg = self:getImageViewByName("ImageView_bouns")
		if not tGoods then
			imgBg:setVisible(false)
		else
			imgBg:loadTexture(G_Path.getEquipIconBack(tGoods.quality))
			-- 掉落物品的品质框
			local imgQulaity = self:getImageViewByName("bouns1")
			imgQulaity:loadTexture(G_Path.getEquipColorImage(tGoods.quality, tGoods.type))
			-- 掉落数量 
			local labelDropNum = tolua.cast(imgQulaity:getChildByName("bounsnum"), "Label")
			labelDropNum:setText("x".. tGoods.size)
			labelDropNum:createStroke(Colors.strokeBrown,1)
			labelDropNum:setVisible(false)
			-- 掉落的物品icon
			local imgIcon = self:getImageViewByName("ico1")
			imgIcon:loadTexture(tGoods.icon)
			-- 主要产出物的名字
			_updateLabel(self, "Label_ProductName", {text=tGoods.name, stroke=Colors.strokeBrown, color=Colors.getColor(tGoods.quality)})
			-- 主要产出物（文字）
			_updateLabel(self, "Label_MainProduct", {text=G_lang:get("LANG_TIME_DUNGEON_CHRUN_OUT"), stroke=Colors.strokeBrown})
		end
	end
end

-- 当前累计
function TimeDungeonMainLayer:_curTotalGet()
	local nTotalGet = 0
	local nStageId = self._tCurDungenoInfo and self._tCurDungenoInfo._nId or 1
	local tStageTmpl = time_dungeon_stage_info.get(nStageId)
	if tStageTmpl then
		for i=1, MAX_STAGE_COUNT do
			if i < self._nCurIndex then
				local nDungeonId = tStageTmpl["dungeon_" .. i]
				local tDungeonTmpl = time_dungeon_info.get(nDungeonId)
				if tDungeonTmpl then
					local nSize = tDungeonTmpl["award_size"..1]
					nTotalGet = nTotalGet + nSize
				end
			end
		end

		if self._nCurIndex == 0 then
			for i=1, MAX_STAGE_COUNT do
				local nDungeonId = tStageTmpl["dungeon_" .. i]
				local tDungeonTmpl = time_dungeon_info.get(nDungeonId)
				if tDungeonTmpl then
					local nSize = tDungeonTmpl["award_size"..1]
					nTotalGet = nTotalGet + nSize
				end
			end
		end
	end
	nTotalGet = G_GlobalFunc.ConvertNumToCharacter(nTotalGet)
	_updateLabel(self, "Label_TotalGet", {text=G_lang:get("LANG_TIME_DUNGEON_TOTAL_GET", {num=nTotalGet}), stroke=Colors.strokeBrown})
end

-- 更新代表8个关卡的stage
function TimeDungeonMainLayer:_updateStage()
	-- 0表示整个章节的8个关卡都打通关了
	if self._nCurIndex == 0 then
		for i=1, MAX_STAGE_COUNT do
			self:registerBtnClickEvent("Button_Stage" .. i, handler(self, self._onClickStage))
			local btnStage = self:getButtonByName("Button_Stage" .. i)
			if btnStage then
				local tChapterTmpl = time_dungeon_chapter_info.get(self._nChapterId)
				if tChapterTmpl then
					btnStage:loadTextureNormal(G_Path.getTimeDungeonCityImage(tChapterTmpl.image))
				end
				btnStage:showAsGray(true)
			end
			self:showWidgetByName("Image_Pass" .. i, true)
		end	
	else
		for i=1, MAX_STAGE_COUNT do
			self:registerBtnClickEvent("Button_Stage" .. i, handler(self, self._onClickStage))
			local btnStage = self:getButtonByName("Button_Stage" .. i)
			local isShowGray = false
			local isShowPass = false
			if i < self._nCurIndex then
				isShowGray = true
				isShowPass = true
			end
			if i > self._nCurIndex then
				isShowGray = false
			end
			if btnStage then
				local tChapterTmpl = time_dungeon_chapter_info.get(self._nChapterId)
				if tChapterTmpl then
					btnStage:loadTextureNormal(G_Path.getTimeDungeonCityImage(tChapterTmpl.image))
				end
				btnStage:setTag(i)
				btnStage:showAsGray(isShowGray)
			end
			self:showWidgetByName("Image_Pass" .. i, isShowPass)

			-- 小刀特效
			if i == self._nCurIndex then
				local tKnifeEffect = self:_addKnifeEffect(btnStage)
			end

		end
	end

	-- 设置关卡名字，位于城池头顶上
	local nCurStageId = G_Me.timeDungeonData:getCurDungeonInfo()._nId
	local tStageTmpl = time_dungeon_stage_info.get(nCurStageId)
	if tStageTmpl then
		for i=1, MAX_STAGE_COUNT do
			local nDungeonId = tStageTmpl["dungeon_" .. i]
			local tDungeonTmpl = time_dungeon_info.get(nDungeonId)
			local nGateName = (tDungeonTmpl and tDungeonTmpl.name) and tDungeonTmpl.name or ""
			_updateLabel(self, "Label_Stage"..i, {text=nGateName, stroke=Colors.strokeBrown})
		end
	end

end

function TimeDungeonMainLayer:_loadMap()
	local tMapLayer = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/timedungeon_TimeDungeonMapLayer.json")
    self:addWidget(tMapLayer)
    self._tScrollView = self:getScrollViewByName("ScrollView_Knight")
    self._tInnerContainer = self._tScrollView:getInnerContainer()
    self._tMapLayer = tMapLayer 
end

function TimeDungeonMainLayer:onBackKeyEvent()
    self:_onClickReturn()
    return true
end

function TimeDungeonMainLayer:_onClickStage(sender)
	local nStageIndex = sender:getTag()
	if nStageIndex < self._nCurIndex or self._nCurIndex == 0 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_TIME_DUNGEON_CUR_STAGE_FINISHED"))
		return
	end

	if nStageIndex >= 1 and nStageIndex <= MAX_STAGE_COUNT then
		self:_onOpenDetailLayer(nStageIndex)
	end
end

function TimeDungeonMainLayer:_onOpenDetailLayer(nStageIndex)
	self._tCurDungenoInfo = G_Me.timeDungeonData:getCurDungeonInfo()
	local nStageId = self._tCurDungenoInfo and self._tCurDungenoInfo._nId or 1
	local tDetailLayer = require("app.scenes.timedungeon.TimeDungeonDetailLayer").create(nStageId, nStageIndex, self._nEndTime, self._nCurIndex)
	if tDetailLayer then
		uf_sceneManager:getCurScene():addChild(tDetailLayer)
	end
end

function TimeDungeonMainLayer:_onClickLineup()
	G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
    require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
end


function TimeDungeonMainLayer:_onOpenHelpLayer()
	require("app.scenes.common.CommonHelpLayer").show({
		{title=G_lang:get("LANG_TIME_DUNGEON_HELP_TITLE1"), content=G_lang:get("LANG_TIME_DUNGEON_HELP_CONTENT1")}
      } )
end

function TimeDungeonMainLayer:_onClickReturn()
	if self._scenePack then
		-- TODO:
		return
	end
	uf_sceneManager:replaceScene(require("app.scenes.mainscene.PlayingScene").new())
end

-- 打开战斗场景
function TimeDungeonMainLayer:_onOpenBattleScene(msg)
	local couldSkip = false
    local scene = nil
    local function showFunction( ... )
    	scene = require("app.scenes.timedungeon.TimeDungeonBattleScene").new(msg, couldSkip, self._scenePack)
        uf_sceneManager:replaceScene(scene)
    end
    local function finishFunction( ... )
    	if scene ~= nil then
    		scene:play()
    	end
    end
    G_Loading:showLoading(showFunction, finishFunction)
end

function TimeDungeonMainLayer:_onCheckDungeonFinished()
	self:_forceBackToPlayScene()
end

-- 强制T到征战界面
function TimeDungeonMainLayer:_forceBackToPlayScene()
	G_MovingTip:showMovingTip(G_lang:get("LANG_TIME_DUNGEON_CUR_DUNGEON_FINISHED"))
	local scene = require("app.scenes.mainscene.PlayingScene").new()
    uf_sceneManager:replaceScene(scene)
end

function TimeDungeonMainLayer:_openAndCloseDesc()
	if self._isOnProcess then
		return
	end
	self._isOnProcess = true

	if self._nDescState == DESC_STAGE.OPEN then
		self._nDescState = DESC_STAGE.CLOSE
		self:showWidgetByName("Image_Knight", false)
		self:showWidgetByName("Image_Up", true)
		self:playAnimation("expand",function(name,_status) 
			if name == "expand" and _status == kAnimationFinish then
				self._isOnProcess = false
			end
		end)
	elseif self._nDescState == DESC_STAGE.CLOSE then 
		self._nDescState = DESC_STAGE.OPEN
		self:showWidgetByName("Image_Knight", true)
		self:showWidgetByName("Image_Up", false)
		self:playAnimation("up",function(name,_status) 
			if name == "up" and _status == kAnimationFinish then
				self._isOnProcess = false
			end
		end)
	end
end

function TimeDungeonMainLayer:_showDescOnEnter()
	if not self._isAutoOpenDesc then
		return
	end
	self._isOnProcess = true
	local arr = CCArray:create()
    arr:addObject(CCCallFunc:create(function()
        self:playAnimation("expand",function(name,_status) 
        	self:showWidgetByName("Image_Knight", false)
			self:showWidgetByName("Image_Up", true)
        end)
    end))
    arr:addObject(CCDelayTime:create(3))
    arr:addObject(CCCallFunc:create(function()
        self:playAnimation("up",function(name,_status) 
        	self:showWidgetByName("Image_Knight", true)
			self:showWidgetByName("Image_Up", false)
			if _status == kAnimationFinish then
				self._isOnProcess = false
			end
        end)
    end))

    self:runAction(CCSequence:create(arr))
end

-- 将秒转化为时、分、秒
function TimeDungeonMainLayer:_formatTime(nTotalSecond)
	local nDay = math.floor(nTotalSecond / 24 / 3600)
	local nHour = math.floor((nTotalSecond - nDay*24*3600) / 3600)
	local nMinute = math.floor((nTotalSecond - nDay*24*3600 - nHour*3600) / 60)
	local nSeceod = (nTotalSecond - nDay*24*3600 - nHour*3600) % 60
	return nDay, nHour, nMinute, nSeceod
end

-- 若第一个活动结束以后，紧接着又有一个活动，就要强制刷新界面
function TimeDungeonMainLayer:_forceUpdate()
	-- 判断当前有没有新活动
	local hasDungeon, nChapterId = G_Me.timeDungeonData:currentTimeHasDungeon()
	if not hasDungeon then
		return
	end
	self._tCurDungenoInfo = G_Me.timeDungeonData:getCurDungeonInfo()
	self._nCurIndex = self._tCurDungenoInfo and self._tCurDungenoInfo._nIndex or 1
	self._nChapterId = nChapterId or 1
	self:_initWidgets()
end

-- 在当前战斗的关卡顶上加一个小刀的特效
function TimeDungeonMainLayer:_addKnifeEffect(tParent)
	if not tParent then
		return
	end
    local EffectNode = require "app.common.effects.EffectNode"
    knifeEffect = EffectNode.new("effect_knife", function(event, frameIndex) end)
    local tSize = tParent:getContentSize()
    knifeEffect:setPositionXY(0, tSize.height * 3/4)
    knifeEffect:setScale(1 / tParent:getScale())
    knifeEffect:play()
    tParent:addNode(knifeEffect, 10, 110)

    return knifeEffect
end

function TimeDungeonMainLayer:_scrollToBottom()
	local nIndex = (self._nCurIndex == 0) and MAX_STAGE_COUNT or self._nCurIndex 
	local nPercent = 100 - math.floor(100/MAX_STAGE_COUNT) * nIndex
	self._tScrollView:scrollToPercentVertical(nPercent, 0, false)
end

function TimeDungeonMainLayer:_initRoad()
	for i=1, MAX_STAGE_COUNT-1 do
		if i >= self._nCurIndex then
			for j=1, 4 do
				local imgRoad = self:getImageViewByName("Image_Road_" .. i .."_" .. j)
				if imgRoad then
					imgRoad:showAsGray(true)
				end
			end
		end
	end
end

function TimeDungeonMainLayer:_showCountDown()
	local nCurTime = G_ServerTime:getTime()
	local nLastTime = self._nEndTime - nCurTime
	nLastTime = math.max(0, nLastTime-1)
	local nDay, nHour, nMinute, nSecond = self:_formatTime(nLastTime)
	local szTime = ""
	if nDay > 0 then
		szTime = G_lang:get("LANG_TIME_DUNGEON_FORMAT_1",{dayValue=nDay, hourValue=nHour, minValue=nMinute, secondValue=nSecond})
	elseif nDay == 0 and nHour > 0 then
		szTime = G_lang:get("LANG_TIME_DUNGEON_FORMAT_2",{hourValue=nHour, minValue=nMinute, secondValue=nSecond})
	elseif nDay == 0 and nHour == 0 then
		szTime = G_lang:get("LANG_TIME_DUNGEON_FORMAT_3",{minValue=nMinute, secondValue=nSecond})
	end  

	_updateLabel(self, "Label_EndTime", {text=G_lang:get("LANG_TIME_DUNGEON_END_TIME"), stroke=Colors.strokeBrown})
	_updateLabel(self, "Label_Time", {text=szTime, stroke=Colors.strokeBrown})
	self:_centerAlign()

	-- 活动结束
	if nLastTime == 0 then
		if self._tTimer then
			G_GlobalFunc.removeTimer(self._tTimer)
			self._tTimer = nil
		end
		self:_forceBackToPlayScene()
	end
end

-- 将秒转化为时、分、秒
function TimeDungeonMainLayer:_formatTime(nTotalSecond)
	local nDay = math.floor(nTotalSecond / 24 / 3600)
	local nHour = math.floor((nTotalSecond - nDay*24*3600) / 3600)
	local nMinute = math.floor((nTotalSecond - nDay*24*3600 - nHour*3600) / 60)
	local nSeceod = (nTotalSecond - nDay*24*3600 - nHour*3600) % 60
	return nDay, nHour, nMinute, nSeceod
end

function TimeDungeonMainLayer:_centerAlign()
	local nTotalLen = self._labelEndTime:getContentSize().width + self._labelTime:getContentSize().width
	local len = self:getPanelByName("Panel_97"):getContentSize().width
	len = (len - nTotalLen) / 2
	self._labelEndTime:setPositionX(len)
	self._labelTime:setPositionX(len + self._labelEndTime:getContentSize().width)
end

-- 若剧情介绍框是打开的情况下，点击屏幕任意地方，会关闭介绍框
function TimeDungeonMainLayer:_clickScreenToCloseDesc()
	if self._nDescState == DESC_STAGE.CLOSE then
		self:_openAndCloseDesc()
	end
end

function TimeDungeonMainLayer:onTouchBegin(xPos, yPos)
	if self._isOnProcess then
		return
	end

	local x, y = self._btnDesc:convertToNodeSpaceXY(xPos, yPos)
	local tSize = self._btnDesc:getContentSize()
	local tRect = CCRectMake(0, 0, tSize.width, tSize.height)

	local imgDesc = self:getImageViewByName("Image_Bg")
	local tSize2 = imgDesc:getContentSize()
	local tRect2 = CCRectMake(0, 0, tSize2.width, tSize2.height)

	local x1, y1 = self._btnDesc:getParent():convertToWorldSpaceXY(self._btnDesc:getPosition())
	if  xPos >= x1 - tSize.width / 2 and xPos <= x1 + tSize.width / 2 then
		if yPos >= y1 - tSize.height / 2 and yPos <= y1 + tSize.height / 2 then
			return
		end 
	end

	if not G_WP8.CCRectContainPt(tRect, x, y) and not G_WP8.CCRectContainXY(tRect2, x, y) then
	--if (not tRect:containsPoint(ccp(x, y))) and (not tRect2:containsPoint(ccp(x, y))) then
		self:_clickScreenToCloseDesc()
	end
end

function TimeDungeonMainLayer:onTouchMove(xPos, yPos)

end

function TimeDungeonMainLayer:onTouchEnd(xPos, yPos)
    
end

function TimeDungeonMainLayer:_addMapEffect()
	local bgImg = tolua.cast(UIHelper:seekWidgetByName(self._tMapLayer, "ImageView_BG"), "ImageView")

	local tParent = bgImg
	local EffectNode = require "app.common.effects.EffectNode"
	local eff = tParent:getNodeByTag(33)
	if not eff and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
		eff = EffectNode.new("effect_xstiaozhan", function(event, frameIndex)
			if event == "finish" then
	
			end
		end)
		eff:play()
		local tSize = tParent:getContentSize()
		eff:setPosition(ccp(tSize.width / 2, tSize.height / 2))
		eff:setScale(1/tParent:getScale())
		tParent:addNode(eff, 0, 33)
	end
end


return TimeDungeonMainLayer