local BoxStateConst = require("app.const.BoxStateConst")
local EffectNode = require("app.common.effects.EffectNode")
local KnightPic = require("app.scenes.common.KnightPic")
local ExpansionDungeonConst = require("app.const.ExpansionDungeonConst")

local ExpansionDungeonGateLayer = class("ExpansionDungeonGateLayer", UFCCSNormalLayer)

local STAGE_NAME_PREFIX = "default_name"
local NAME_WIDGET_TAG_PREFIX = 454
local STAR_NODE_TAG = 1010

function ExpansionDungeonGateLayer.create(tParent, nChapterId, isAutoOpenShop, ...)
	return ExpansionDungeonGateLayer.new("ui_layout/expansiondungeon_GateLayer.json", nil, tParent, nChapterId, isAutoOpenShop, ...)
end

function ExpansionDungeonGateLayer:ctor(json, param, tParent, nChapterId, isAutoOpenShop, ...)
	self._tScene = tParent
	self._nChapterId = nChapterId or 1
	self._isAutoOpenShop = isAutoOpenShop or false
	self._tChapter = G_Me.expansionDungeonData:getChapterById(self._nChapterId)
	self._tChapterTmpl = expansion_dungeon_chapter_info.get(self._nChapterId)
	assert(self._tChapter)
	assert(self._tChapterTmpl)
	self._tStageList = self._tChapter._tStageList

	G_Me.expansionDungeonData:judgeOpenNewStage()
	self._hasNewStage = G_Me.expansionDungeonData:isOpenNewStage()
	self._nNewStageIndex = 0   -- 新开的stage的index (1~8), 1颗星都没有的stage
	self._hasNewStar = false   -- 有没有星数变化

	self._tTimer = nil

	self._tflareEffect = nil
	self._tKnifeEffect = nil

	-- 有没有开新章节
	self._hasNewChapter = G_Me.expansionDungeonData:isOpenNewChapter()


	self.super.ctor(self, json, param, ...)
end

function ExpansionDungeonGateLayer:onLayerLoad()
	self:_showPassLayer()
	self:_loadMap(self._tChapterTmpl.map_index)
	self:_initView()
	self:_initWidgets()
	
	self:_findNewStageIndex()
	self:_updateStages()
	self:_updateChapterBox()
	self:_setChapterName()
	self:_addSceneEffect()
--	self:_flyStageAwards()
end

function ExpansionDungeonGateLayer:onLayerEnter()
	self:registerKeypadEvent(true)

	-- 请求战斗成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EX_DUNGEON_EXCUTE_STAGE_SUCC, self._onOpenBattleSceneSucc, self)
	-- 领取章节奖励成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EX_DUNGEON_GET_CHAPTER_AWARD_SUCC, self._onClaimChapterBoxSucc, self)


	-- if not G_Me.expansionDungeonData:hasEnterChpaterAlready(self._nChapterId) then
	-- 	-- 通知服务器，已经进入过这个章节了
 --    --    G_HandlersManager.myDungeonHandler:sendFirstEnterChapter(self._nChapterId)
 --    else
 --    	self:handleAttackStageStarNumberChanged()
	-- end
	self:handleAttackStageStarNumberChanged()

	local isPassTotalChapter = G_Me.expansionDungeonData:isPassTotalChapter()
	if self._hasNewChapter or self._isAutoOpenShop or G_Me.expansionDungeonData:isFirstPassTotalChapter() then
		self._hasNewChapter = false
		self._isAutoOpenShop = false
		G_Me.expansionDungeonData:setPassTotalChapterState(isPassTotalChapter, isPassTotalChapter)

		self:showWidgetByName("Image_ShopEntry", true)
		self:_onOpenShopLayer()
	else
		local isShowShopEntry = G_Me.expansionDungeonData:isShowChapterShopEntry(self._nChapterId)
		self:showWidgetByName("Image_ShopEntry", isShowShopEntry)
	end
end

function ExpansionDungeonGateLayer:onLayerExit()
	self:_removeTimer()
end

function ExpansionDungeonGateLayer:onLayerUnload()
	
end

function ExpansionDungeonGateLayer:onBackKeyEvent()
    self:_onClickReturn()
    return true
end

function ExpansionDungeonGateLayer:_initView()
	
end

function ExpansionDungeonGateLayer:_initWidgets()
	self:registerBtnClickEvent("Button_Back", handler(self, self._onClickReturn))
	self._tMapLayer:registerBtnClickEvent("Button_Box", handler(self, self._onOpenBox))
	self:registerWidgetClickEvent("Image_ShopEntry", handler(self, self._onClickOpenShopLayer))
end

function ExpansionDungeonGateLayer:_onClickReturn( ... )
	local scene = require("app.scenes.expansiondungeon.ExpansionDungeonMainScene").new()
	uf_sceneManager:replaceScene(scene)
end

function ExpansionDungeonGateLayer:_onOpenBox()
	local btnBox = self._tMapLayer:getButtonByName("Button_Box")
	local pt = btnBox:getPositionInCCPoint()
    local x,y=0,0
    x,y = btnBox:getParent():convertToWorldSpaceXY(pt.x, pt.y, x, y)

    local nChapterId = self._nChapterId
    local tStarPos = ccp(x,y)
    local claimed, could = G_Me.expansionDungeonData:getChapterBoxState(self._nChapterId)
   	local nBoxState = BoxStateConst.CLAIMED
    if claimed then
    	nBoxState = BoxStateConst.CLAIMED
    else
    	if could then
    		nBoxState = BoxStateConst.OPEN
    	else
    		nBoxState = BoxStateConst.CLOSE
    	end
    end

    local claimCallback = function()
    	G_HandlersManager.expansionDungeonHandler:sendGetExpansiveDungeonChapterReward(self._nChapterId)
    end
  
    local boxLayer = require("app.scenes.expansiondungeon.ExpansionDungeonBoxLayer").create(nChapterId, tStarPos, nBoxState, claimCallback)
	self._tScene:addChild(boxLayer)
end

-- 加载地图
function ExpansionDungeonGateLayer:_loadMap(nMapId)
	nMapId = nMapId or 1
	self._tMapLayer = require("app.scenes.expansiondungeon.ExpansionDungeonGateMapLayer").create(nMapId)
	self._tScene:addChild(self._tMapLayer, -1)
	local imgMap = self._tMapLayer:getImageViewByName("ImageView_Bg")
	self._szMapPath = imgMap:textureFile()
end

function ExpansionDungeonGateLayer:_updateChapterBox()
	local btnBox = self._tMapLayer:getButtonByName("Button_Box")
	if btnBox then
		local claimed, could = G_Me.expansionDungeonData:getChapterBoxState(self._nChapterId)
		if not claimed then
			if could then
				btnBox:loadTextureNormal(G_Path.getBoxPic(BoxStateConst.OPEN))
				if not self._tflareEffect then
					self._tflareEffect = EffectNode.new("effect_box_light", function(event, frameIndex) end) 
				    btnBox:addNode(self._tflareEffect)
				    self._tflareEffect:setPosition(ccp(20, 55))
				    self._tflareEffect:play()
				end
			else
				btnBox:loadTextureNormal(G_Path.getBoxPic(BoxStateConst.CLOSE))
			end
		else
			-- 空
			btnBox:loadTextureNormal(G_Path.getBoxPic(BoxStateConst.CLAIMED))
			if self._tflareEffect then
				self._tflareEffect:removeFromParentAndCleanup(true)
				self._tflareEffect = nil
			end
		end
	end
end


function ExpansionDungeonGateLayer:_updateStages()
	-- 本章节的最大索引
	local nMaxStageIndex = 0
	for key, val in pairs(self._tChapter._tStageList) do
		nMaxStageIndex = nMaxStageIndex + 1
	end

	self:_hideBGPanel()

	for key, val in pairs(self._tStageList) do
		local tStage = val
		local nStageId = tStage._nId
		local tStageTmpl = expansion_dungeon_stage_info.get(nStageId)

		local panelStage = self._tMapLayer:getPanelByName("Panel_Stage" .. tStageTmpl.index)
		-- 每个panel记录对应的stage id
		panelStage:setTag(tStageTmpl.id)
		if tStage then
			local isShowEnemy = true 
			if self._hasNewStage and tStageTmpl.index == self._nNewStageIndex then
				isShowEnemy = false
			end
			local nStar = G_Me.expansionDungeonData:getStageStarNum(tStage)
			self:_createStageEnemy(panelStage, tStageTmpl, isShowEnemy)
			self:_setStageEnemyInfo(nStageId, nStar, isShowEnemy)
		end
	end

	-- 定位最合适的位置
	local tPanel = self._tMapLayer:getPanelByName("Panel_Stage" .. nMaxStageIndex)
	local maxStagePanelPos = tPanel:getPositionInCCPoint()

	local nChapterId, nPosY, nScale = G_Me.expansionDungeonData:getMapLayerPosYAndScale()
	if nChapterId ~= self._nChapterId or nPosY == 100 or self._hasNewStage == true then
		self._tMapLayer:updatePosition(maxStagePanelPos.y)
		G_Me.expansionDungeonData:storeMapLayerPosYAndScale(self._nChapterId, self._tMapLayer:getPositionY(), self._tMapLayer:getScale())
	else
		self._tMapLayer:setPositionY(nPosY)
		self._tMapLayer:setScale(nScale)
	end
end

function ExpansionDungeonGateLayer:_createStageEnemy(panelStage, tStageTmpl, isShow)
	if not panelStage or not tStageTmpl then
		return
	end
	isShow = isShow or false

	local function onClickEnemy(sender)
		if not self._tMapLayer:getMoveTouch() then
			-- 记录地图的y轴位置和缩放尺寸
			G_Me.expansionDungeonData:storeMapLayerPosYAndScale(self._nChapterId, self._tMapLayer:getPositionY(), self._tMapLayer:getScale())
			-- TODO: 点击了敌人
			local nStageId = sender:getTag()
			local nStageStar = self._tChapter._tStageList[nStageId]._nStar
			self:_onOpenStageDetail(nStageId)
		end
	end
	local szNewName = STAGE_NAME_PREFIX .. tStageTmpl.id
	local btnStageEnemy = KnightPic.createKnightButton(tStageTmpl.image, panelStage, szNewName, self._tMapLayer, onClickEnemy, true, true)
	btnStageEnemy:setTag(tStageTmpl.id) -- 使用tag值记录stage id
	-- 不断变大缩小,呼吸
	local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
	EffectSingleMoving.run(panelStage, "smoving_idle", nil, {position=true}, 1+ math.floor(math.random()*20))
	btnStageEnemy:setVisible(isShow)

	return btnStageEnemy
end

function ExpansionDungeonGateLayer:_setStageEnemyInfo(nStageId, nStar, isShow)
	nStageId = nStageId or 1
	nStar = nStar or 0
	isShow = isShow or false

	local tStageTmpl = expansion_dungeon_stage_info.get(nStageId)
	local btnStageEnemy = self._tMapLayer:getPanelByName("Panel_Stage" .. tStageTmpl.index):getChildByTag(nStageId)
	assert(btnStageEnemy)
	if btnStageEnemy then
		local nNameWidgetTag = NAME_WIDGET_TAG_PREFIX + nStageId
		local tNameWidget = self._tMapLayer:getChildByTag(nNameWidgetTag)
		if not tNameWidget then
			tNameWidget = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/dungeon_DungeonGateItem.json")
			self._tMapLayer:addChild(tNameWidget)
			tNameWidget:setTag(nNameWidgetTag)
			tNameWidget:setScale(1 - 0.02 * tStageTmpl.index)
			local tPos = self:_getPosByKnight(btnStageEnemy:getParent():getPositionInCCPoint(), btnStageEnemy)
        	tNameWidget:setPosition(tPos)
        	local labelName = tolua.cast(tNameWidget:getChildByName("name"), "Label")
        	labelName:setText(tStageTmpl.name)
        	labelName:createStroke(Colors.strokeBrown, 1)
        	local tNameColor = Colors.qualityColors[tStageTmpl.quality] or Colors.qualityColors[7]
        	labelName:setColor(tNameColor)

        	-- 显示星数
			local tStartNode = tNameWidget:getNodeByTag(STAR_NODE_TAG)
			if not tStartNode then
				local EffectNode = require ("app.common.effects.EffectNode")
	        	tStarNode = EffectNode.new("effect_" .. nStar .. "star", function(event, frameIndex)
	                end)   
	            local ptPosX = labelName:getPositionX()
	            local ptPosY = labelName:getPositionY() + labelName:getContentSize().height
	            tNameWidget:addNode(tStarNode)
	            tStarNode:setPosition(ccp(ptPosX, ptPosY))
	            tStarNode:setTag(STAR_NODE_TAG)
			end

			tNameWidget:setVisible(isShow)

			local nMaxStageId, nIndex = G_Me.expansionDungeonData:getMaxStageIdAndIndex()

			-- if isShow and tStageTmpl.index == self._nNewStageIndex or tStageTmpl.id == nMaxStageId then
			-- 	self._nCurStageId = tStageTmpl.id
			-- 	-- 当前敌人从左还是右，跳进场景当中
			-- 	local nPanelPosX = btnStageEnemy:getParent():getPositionX()
	
			-- 	local x, y = tNameWidget:getPosition()
			-- 	self:_playKnifeAnimation(ccp(x + 5, y + 50))
			-- --	self:_playNPCWhisper(nPanelPosX, self._tMapLayer:getContentSize().width / 2, ccp(x, y))
			-- end

			local show1 = false
			local show2 = false
			if self._hasNewStage and isShow and tStageTmpl.index == self._nNewStageIndex then
				show1 = true
			end
			if not self._hasNewStage and tStageTmpl.id == nMaxStageId then
				show2 = true
			end
			if show1 or show2 then
				self._nCurStageId = tStageTmpl.id
				-- 当前敌人从左还是右，跳进场景当中
				local nPanelPosX = btnStageEnemy:getParent():getPositionX()
	
				local x, y = tNameWidget:getPosition()
				self:_playKnifeAnimation(ccp(x + 5, y + 50))
			--	self:_playNPCWhisper(nPanelPosX, self._tMapLayer:getContentSize().width / 2, ccp(x, y))
			end

		else
			-- 名字没有需要更新的时候，这里不做处理
		end

	end
end

-- 小刀动画
function ExpansionDungeonGateLayer:_playKnifeAnimation(ptPos)
	if G_Me.expansionDungeonData:isLastStageGetThreeStar() then
		return
	end

	if not self._tKnifeEffect then
		self._tKnifeEffect = require("app.common.effects.EffectNode").new("effect_knife")
		self._tMapLayer:addChild(self._tKnifeEffect, 10)
		self._tKnifeEffect:setPosition(ptPos)
		self._tKnifeEffect:play()
	end
end


function ExpansionDungeonGateLayer:_findNewStageIndex()
	if not self._hasNewStage then
		return
	end
	for key, val in pairs(self._tStageList) do
		local tStage = val
		local tStageTmpl = expansion_dungeon_stage_info.get(tStage._nId)
		assert(tStageTmpl)
		if tStage and tStageTmpl then
			if not tStage._bTarget1 then
				self._nNewStageIndex = tStageTmpl.index
			end 
		end
	end
end

function ExpansionDungeonGateLayer:_onOpenStageDetail(nStageId)
	local tLayer = require("app.scenes.expansiondungeon.ExpansionDungeonDetailLayer").create(self._nChapterId, nStageId)
	if tLayer then
		uf_sceneManager:getCurScene():addChild(tLayer)
	end
	G_Me.expansionDungeonData:updateStoredMaxStage()
	G_Me.expansionDungeonData:setAtkStage(G_Me.expansionDungeonData:getStageById(self._nChapterId, nStageId))
end

-- 获取敌人头顶位置
function ExpansionDungeonGateLayer:_getPosByKnight(pos, btnStageEnemy)
    if btnStageEnemy == nil then 
    	return 
    end

--    local tSize = btnStageEnemy:getCascadeBoundingBox(false).size--btnStageEnemy:getContentSize()
	local tSize = btnStageEnemy:getContentSize()
    if g_target ~= kTargetWinRT and g_target ~= kTargetWP8 then
        tSize = btnStageEnemy:getCascadeBoundingBox(false).size
    end

    local tParent = btnStageEnemy:getParent()
    local nHeight = tSize.height * tParent:getScale()
    local ptPos = ccp(0, 0)
    ptPos.x = pos.x
    ptPos.y = pos.y + nHeight
    return ptPos
end

-- 若有了新的星级，则处理这个动画
function ExpansionDungeonGateLayer:handleAttackStageStarNumberChanged()
	local tAtkStage = G_Me.expansionDungeonData:getAtkStage()
	local nStageId = 0
	local nCurStar = 0
	if tAtkStage then
		nStageId = tAtkStage._nId
		local tStage = self._tStageList[nStageId]
		local beforeAtkStar = G_Me.expansionDungeonData:getStageStarNum(tAtkStage)
		nCurStar = G_Me.expansionDungeonData:getStageStarNum(tStage)
		if nCurStar > beforeAtkStar then
			self._hasNewStar = true
		end
		G_Me.expansionDungeonData:clearAtkStage()
	end

	if self._hasNewStar then
		self._hasNewStar = false
		self:_createStarAnimation(nStageId, nCurStar) 
	end
end

-- 如果stage得到了新的星数, 只对eneny stage有效
function ExpansionDungeonGateLayer:_createStarAnimation(nStageId, nStar)
	nStageId = nStageId or 1
	nStar = nStar or 1

	local nNameWidgetTag = NAME_WIDGET_TAG_PREFIX + nStageId 
	local tNameWidget = self._tMapLayer:getChildByTag(nNameWidgetTag)
	local tStarNode = tNameWidget:getNodeByTag(STAR_NODE_TAG)

	-- 创建一个动画 
	local EffectNode = require ("app.common.effects.EffectNode")
	local tStarAni = EffectNode.new("effect_" .. nStar .. "star_play", function(event, frameIndex)
			-- 判断是否开启了新的stage,若开启，则播放后续动画
			self:_showAnimation()
    	end)   
	if tStarAni then
		tNameWidget:addNode(tStarAni)
		tStarAni:setPositionXY(tStarNode:getPosition())
		tStarAni:play()
		tStarNode:setVisible(true)
		tStarNode:removeFromParentAndCleanup(true)
	end
end

-- 显示动画
function ExpansionDungeonGateLayer:_showAnimation()
    if self._hasNewStage and not self._tTimer then
       self._tTimer = G_GlobalFunc.addTimer(0.3, handler(self, self._showNewStageAnimation))
    end

    -- -- 开启了新章节，并且还没有播放开启动画
    -- if G_Me.myDungeonData:getNewChapterId() ~= -1 and G_Me.myDungeonData:needPlayNewChapterAnimation() then
    -- 	G_Me.myDungeonData:finishPlayNewChapterAnimation()
    -- 	uf_sceneManager:getCurScene():addChild(require("app.scenes.mydungeon.MyDungeonSubtitleLayer").create(self._szMapPath))  
    -- end
end

-- 若开启了新的stage, 若只是一个enemy stage,则enemy跳入到场景中，
-- 若还开启了一个box stage, 则先播放宝箱打开动画
function ExpansionDungeonGateLayer:_showNewStageAnimation()
    local panelStage = self._tMapLayer:getPanelByName("Panel_Stage" .. self._nNewStageIndex)
    if panelStage then
    	local tStageTmpl = expansion_dungeon_stage_info.get(panelStage:getTag())
        if tStageTmpl then
            self:_showEnemyEnterStageAction()
        end
		self:_removeTimer()
    else
    	self:_removeTimer()
    end  
end

-- 武将出场动画
function ExpansionDungeonGateLayer:_showEnemyEnterStageAction()
	self._hasNewStage = false
	G_Me.expansionDungeonData:setOpenNewStage(false)

    local panelStage = self._tMapLayer:getPanelByName("Panel_Stage" .. tostring(self._nNewStageIndex))
    if panelStage == nil then return end

    local nStageId = panelStage:getTag()
    local tStageTmpl = expansion_dungeon_stage_info.get(nStageId)
    local btnStageEnemy = panelStage:getChildByTag(nStageId)
    local pt = panelStage:getPositionInCCPoint()
    local startPt = ccp(0,pt.y)
    if pt.x > self._tMapLayer:getContentSize().width/2 then
        startPt.x = self._tMapLayer:getContentSize().width
    end

    local x,y =0,0
    x,y = self._tMapLayer:convertToWorldSpaceXY(startPt.x,startPt.y,x,y)
    local pt_x,pt_y = 0,0
    pt_x,pt_y = self._tMapLayer:convertToWorldSpaceXY(pt.x,pt.y,pt_x,pt_y)

    local JumpBackCard = require("app.scenes.common.JumpBackCard")
    self.jumpMonster = JumpBackCard.create()
    self._tMapLayer:addChild(self.jumpMonster,1000)
    self.jumpMonster:play(tStageTmpl.image, ccp(x,y), panelStage:getScale(), ccp(pt_x,pt_y), panelStage:getScale(), function() 
        if btnStageEnemy then    
           btnStageEnemy:setVisible(true)
        end          
        self:_showNewStageMonsterName()
        self.jumpMonster:removeFromParentAndCleanup(true)
        self.jumpMonster = nil
    end )
end

function ExpansionDungeonGateLayer:_showNewStageMonsterName()
    local panelStage = self._tMapLayer:getPanelByName("Panel_Stage" .. self._nNewStageIndex)
    if panelStage then
    	local nStageId = panelStage:getTag()
    	local NAME_WIDGET_TAG = NAME_WIDGET_TAG_PREFIX + nStageId
        local tNameWidget = self._tMapLayer:getChildByTag(NAME_WIDGET_TAG)
        if tNameWidget then 
            tNameWidget:setVisible(true) 
            local x, y = tNameWidget:getPosition()
        	self:_playKnifeAnimation(ccp(x + 5, y + 50))
        	self._nCurStageId = nStageId
        --	self:_playNPCWhisper(x, self._tMapLayer:getContentSize().width / 2, ccp(x, y))
        end
    end
end

function ExpansionDungeonGateLayer:_removeTimer()
    if self._tTimer then
        G_GlobalFunc.removeTimer(self._tTimer)
        self._tTimer = nil
    end
end

function ExpansionDungeonGateLayer:_onOpenBattleSceneSucc(tData)
	local isPassTotalChapter = G_Me.expansionDungeonData:isPassTotalChapter()
	G_Me.expansionDungeonData:setPassTotalChapterState(nil, isPassTotalChapter)

	local couldSkip = false
    local scene = nil
    local function showFunction( ... )
    	local tAtkStage = G_Me.expansionDungeonData:getAtkStage()
    	scene = require("app.scenes.expansiondungeon.ExpansionDungeonBattleScene").new(tData, couldSkip, self._nChapterId, tAtkStage._nId, ...)
        uf_sceneManager:replaceScene(scene)
    end
    local function finishFunction( ... )
    	if scene ~= nil then
    		scene:play()
    	end
    end
    G_Loading:showLoading(showFunction, finishFunction)
end

function ExpansionDungeonGateLayer:_onClaimChapterBoxSucc(tData)
	self:_flyDropItem(tData.awards)
	self:_updateChapterBox()
end

function ExpansionDungeonGateLayer:_flyDropItem(tAwards)
    local tGoodsPopWindowsLayer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(tAwards, function() end)
    self:addChild(tGoodsPopWindowsLayer)
end

function ExpansionDungeonGateLayer:_hideBGPanel()
	for i=1, 8 do
		local panelStage = self._tMapLayer:getPanelByName("Panel_Stage"..i)
		if panelStage then
			panelStage:setBackGroundColorOpacity(0)
		end
	end
end

function ExpansionDungeonGateLayer:_showPassLayer()
	local nPassType = 0
	local tAtkStage = G_Me.expansionDungeonData:getAtkStage()
	if not tAtkStage then
		return
	end

	local tStageList = self._tChapter._tStageList
	for key, val in pairs(tStageList) do
		local tStage = val
		if tStage._nId == tAtkStage._nId and tStage._nMinUId ~= tAtkStage._nMinUId and tostring(tStage._nMinUId) == tostring(G_Me.userData.id) then
			nPassType = ExpansionDungeonConst.PASS_TYPE.MIN_FIGHT_VALUE
		end
		if tStage._nId == tAtkStage._nId and tStage._nMaxUId ~= tAtkStage._nMaxUId and tostring(tStage._nMaxUId) == tostring(G_Me.userData.id) then
			nPassType = ExpansionDungeonConst.PASS_TYPE.MAX_FIGHT_VALUE
		end
	end
	if nPassType == ExpansionDungeonConst.PASS_TYPE.MAX_FIGHT_VALUE or 
	    nPassType == ExpansionDungeonConst.PASS_TYPE.MIN_FIGHT_VALUE then
	    local tStageTmpl = expansion_dungeon_stage_info.get(tAtkStage._nId)
	    assert(tStageTmpl)

	    local tLayer = require("app.scenes.expansiondungeon.ExpansionDungeonPassLayer").create(nPassType, tStageTmpl.image, tStageTmpl.name, tStageTmpl.quality)
	    if tLayer then
	    --	self._tScene:addChild(tLayer, 2)
	    	uf_notifyLayer:getModelNode():addChild(tLayer, 2)
	    end
	end
end

function ExpansionDungeonGateLayer:_addSceneEffect()
    -- 加载场景动画
    require("app.cfg.scene_effect_info")
    local nSceneId = self._tChapterTmpl.scene_id
    local tSceneEffectTmpl = scene_effect_info.get(1, tonumber(nSceneId))
    local size = self._tMapLayer:getContentSize()

    if tSceneEffectTmpl and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        for i=1,5 do
            if tSceneEffectTmpl["effect_" .. i] ~= "0" then
                local effectNode = EffectNode.new(tSceneEffectTmpl["effect_" .. i], function(event, frameIndex) end)
                effectNode:setPosition(ccp(size.width / 2, size.height / 2))
                self._tMapLayer:getRootWidget():addNode(effectNode, tSceneEffectTmpl["effect_type_" .. i] == 1 and 1 or 20)
                effectNode:play()
            end
        end
    end
end

function ExpansionDungeonGateLayer:_setChapterName()
	local szChapterName = G_lang:get("LANG_EX_DUNGEON_CHAPTER", {num=self._nChapterId, name=self._tChapterTmpl.name})
	G_GlobalFunc.updateLabel(self, "Label_ChapterName", {text=szChapterName, stroke=Colors.strokeBrown})
end

function ExpansionDungeonGateLayer:_flyStageAwards()
	local tStageAwardList = G_Me.expansionDungeonData:getStageAwardList()
	if tStageAwardList and table.nums(tStageAwardList) ~= 0 then
		self:_flyDropItem(tStageAwardList)
	end
end

function ExpansionDungeonGateLayer:_onOpenShopLayer()
	uf_funcCallHelper:callAfterFrameCount(1, function()
		local tLayer = require("app.scenes.expansiondungeon.ExpansionDungeonShopLayer").create(self._nChapterId, handler(self, self._onCloseShop))
		if tLayer then
			self._tScene:addChild(tLayer)
		end
	end)
end

function ExpansionDungeonGateLayer:_onClickOpenShopLayer()
	local tLayer = require("app.scenes.expansiondungeon.ExpansionDungeonShopLayer").create(self._nChapterId, handler(self, self._onCloseShop))
	if tLayer then
		self._tScene:addChild(tLayer)
	end
end

function ExpansionDungeonGateLayer:_onCloseShop()
	self:showWidgetByName("Image_ShopEntry", G_Me.expansionDungeonData:isShowChapterShopEntry(self._nChapterId))
end

return ExpansionDungeonGateLayer