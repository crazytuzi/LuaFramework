--StoryTalkLayer.lua

require("app.cfg.story_dialogue")
require("app.cfg.knight_info")
require("app.cfg.monster_info")

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local StoryTalkLayer = class("StoryTalkLayer", UFCCSModelLayer)

local DelayTime = 0.5

local MoveStatus = 
{
    STATUS_SHOW = 1,     --出现
    STATUS_HIDE = 2,    --隐藏    
    STATUS_STAND = 3,   --站立
    STATUS_JUMP = 4,
}

local RolePosList = 
{
    [1] = {startPos = ccp(-200,120),endPos=ccp(140,120)},
    [2] = {startPos = ccp(320,-100),endPos=ccp(320,120)},
    [3] = {startPos = ccp(640,120),endPos=ccp(500,120)},
}

local FacePosList = 
{
  [1] = 140,
  [2] = 320,
  [3] = 500,
}


function StoryTalkLayer.create( data )
	return StoryTalkLayer.new("ui_layout/dungeon_StoryTalkLayer.json", ccc4(0,0,0,0), data)
end

function StoryTalkLayer:ctor( ... )
	self._storyId = 0
	self._callback = nil
	self._showTalkRapid = false

	self._storyData = nil
	self._curStep = 1

	self._lastKnightPos = 0
	self._lastKnightPic = nil
	self._knightPic = {}
	self._knightPicIndex = {}
	self._knightName = {}
	self._facePic = {}

	self._knightContainer = nil
	self._talkItemList = {}
	self._lastTalkItem = nil

	self._scrollView = nil
	self._maxScrollHeight = 0
	self._contentNode = nil

	self._posX = 0
	self._posY = 0
	self._isEffecting = false
	self._hightLightTalkList = false

	self.super.ctor(self, ...)

	self:adapterWithScreen()
end

function StoryTalkLayer:onLayerLoad( json, fun, data, ... )
	local array = CCArray:create()
    array:addObject(CCRotateTo:create(100,180))
    array:addObject(CCRotateTo:create(100,360))
    self:getImageViewByName("Image_Circle"):runAction(CCRepeatForever:create(CCSequence:create(array)))

    self._knightContainer = self:getPanelByName("Panel_Role")
    self._scrollView = self:getScrollViewByName("ScrollView_TalkContent")
    if self._scrollView then 
    	self._scrollView:setTouchEnabled(false)
    end
    self:getImageViewByName("Image_Bg"):setVisible(false)
    self:_doInitStoryInfo( data )

    self:registerTouchEvent(false, true, 0 )
end

function StoryTalkLayer:onLayerEnter( ... )
	self:_enterStoryBack( false, function ( ... )
		self:_runStoryPlay()	
	end)	
end


function StoryTalkLayer:_doInitStoryInfo( data )
	if not data then 
		return 
	end

	self._showTalkRapid = data.rapid and true or false
	self._storyId = data.storyId
	self._callback = data.func	
	self._curStep = 1

	self._storyData = story_dialogue.get(self._storyId, self._curStep)

	if self._storyData then 
            local sceneBg = self:getImageViewByName("Image_Bg")
            sceneBg:setScale(2)
            if self._storyData["background"] ~= "0" then
                sceneBg:loadTexture(self._storyData["background"] or "")
            end
            sceneBg:setVisible(self._storyData["background"] ~= "0")

            -- 若一张背景图长度不够一个屏幕的长度，就把背景图复制一遍，加在原来背景图的下面
            local tSize = sceneBg:getSize()
            if tSize.height * 2 < display.height then
            	local x, y = sceneBg:getPosition()
            	local szImgPath = sceneBg:textureFile()
            	local img2 = ImageView:create()
            	img2:loadTexture(szImgPath)
            	img2:setPosition(ccp(x+tSize.width, display.height-tSize.height*2))
            	img2:setAnchorPoint(ccp(0.5, 1))
            	img2:setScale(2)
            	sceneBg:getParent():addChild(img2)
            	img2:setVisible(sceneBg:isVisible())
            end
	end
end

function StoryTalkLayer:_enterStoryBack( isExit, func )
	isExit = isExit or false
	self._isEffecting = true
	local _callFun = function ( ... )
		self._isEffecting = false
		if func then 
			func()
		end
	end
	local backImg = self:getWidgetByName("Image_Base")
	if not backImg then 
		return _callFun()
	end

	local backSize = backImg:getSize()
	local arr = CCArray:create()
	if isExit then 
		 arr:addObject(CCCallFunc:create(function()
                for i = 1, 3 do
                    if self._facePic[i] and self._facePic[i]:getOpacity() == 255 then
                       self:showFaceAction(self._facePic[i], MoveStatus.STATUS_HIDE)
                    end
                end
                for key, value in pairs(self._knightPicIndex) do
                    if value then
                        self:_moveSprite(self._knightPic[value], key, MoveStatus.STATUS_HIDE)
                    end
                end
            end))
        arr:addObject(CCDelayTime:create(DelayTime))
	end
	arr:addObject(CCEaseIn:create(CCMoveBy:create(0.3, ccp(0, isExit and -backSize.height*1.2 or backSize.height)), 0.3))
	arr:addObject(CCCallFunc:create(function()
		_callFun()
		end))

	if not isExit then 
		backImg:setPosition(ccp(0, -backSize.height))
	end

	backImg:runAction(CCSequence:create(arr))
end

function StoryTalkLayer:_exitStoryTalk(  )
	local _exitFun = function ( ... )
		self:_enterStoryBack(true, function ( ... )
			if self._callback then
				self._callback()
			end
				self:close()	
			end)
	end

	if self:getPanelByName("Panel_Prop"):isVisible() == true then
        self:_jumpProp( function ( ... )
          	_exitFun()
        end)
    else
        _exitFun()
    end
end

function StoryTalkLayer:_onTalkFinish( ... )
	self._lastTalkItem = nil
	-- if self._scrollView then 
 --    	self._scrollView:setTouchEnabled(true)
 --    end
 	self:_exitStoryTalk()
end

function StoryTalkLayer:_highlightTalkList( ... )
	if self._hightLightTalkList then
		return 
	end

	self._hightLightTalkList = true
	for key, value in pairs(self._talkItemList) do 
		if value then 
			value:setOpacity(255)
		end
	end
end

function StoryTalkLayer:_runStoryPlay( ... )
	if not self._storyData then 
		self:_onTalkFinish()
		return
	end
        --if self._storyData.common_sound ~= "0" then
        --    G_SoundManager:playSound(G_Path.getVoice(self._storyData.common_sound))
        --end
	if self._storyData.res_id == "0" then 
		local pos, resId = self:_getCurStepPos()
		local name = self:_showRoleAtPos(pos, resId)
		self:showFace( pos )
		self._lastKnightPos = resId

		self:_showTalkText(pos, name, function ( ... )
			self:_playTalkItem(function ( ... )
			end)
		end)
	else
		self:_showProp()
	end
end

function StoryTalkLayer:_showProp( )
	if not self._storyData then 
		return 
	end

	if self._lastTalkItem then 
		self._lastTalkItem:setOpacity(200)
		self._lastTalkItem:showNextIcon(false)
	end

	self._isEffecting = true
    local panl_Prop = self:getPanelByName("Panel_Prop")
    panl_Prop:setVisible(true)
    local prop = self:getImageViewByName("Image_Prop")
    prop:loadTexture(self._storyData.res_id)
    prop:setScale(0)
    self:getLabelByName("Label_PropDesc"):setText(self._storyData.txt)
    self:getLabelByName("Label_PropDesc"):setVisible(true)
    self:showWidgetByName("Label_PropDesc_tip", true)
    self:getLabelByName("Label_PropDesc_tip"):setText(self._storyData.txt2 or "")
    local array = CCArray:create()
    array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.5,1),CCRotateTo:create(0.5,3600)))
    array:addObject(CCCallFunc:create(function()
       self._isEffecting = false
    end))
    prop:runAction(CCSequence:create(array))
    
    if self._storyData.effect ~= "0" then
        local img = self:getImageViewByName("Image_Effect")
        local lightEffect = require("app.common.effects.EffectNode").new(self._storyData.effect)
        img:addNode(lightEffect,0,10)
        lightEffect:play()
    end             
end

function StoryTalkLayer:_jumpProp( func )
    self:getLabelByName("Label_PropDesc"):setVisible(false)
    self:showWidgetByName("Label_PropDesc_tip", false)
   local img = self:getImageViewByName("Image_Effect")
    local lightEffect = img:getNodeByTag(10)
    if lightEffect then
        lightEffect:setVisible(false)
    end
    local prop = self:getImageViewByName("Image_Prop")
    local pt = prop:getPositionInCCPoint()
    local array = CCArray:create()
    array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.5,0),CCSpawn:createWithTwoActions(CCRotateTo:create(0.5,3600),CCJumpTo:create(0.5, ccp(pt.x - 180,pt.y - 300), 100, 1))))
    array:addObject(CCCallFunc:create(function()
        self:getPanelByName("Panel_Prop"):setVisible(false)
        if func then 
        	func()
        end
        --self:showBgAction(false)
    end))
    prop:runAction(CCSequence:create(array))
end

function StoryTalkLayer:_switchNextTalk(  )
	self._curStep = self._curStep + 1
	self._storyData = story_dialogue.get(self._storyId, self._curStep)

	if self._lastTalkItem then 
		self._lastTalkItem:rapidFinishTalk()
	end

	if not story_dialogue.get(self._storyId, self._curStep + 1) and self._scrollView then 
    	self._scrollView:setTouchEnabled(true)
    end

	self:_runStoryPlay()
end

function StoryTalkLayer:_getCurStepPos(  )
	local posId = 0
	local resId = 1
	if self._storyData.monster_id_0 == 0 then 
		posId = 1
	elseif self._storyData.monster_id_0 == self._storyData.monster_id_2 then 
		posId = 2 
		resId = self._storyData.monster_id_2
	elseif self._storyData.monster_id_0 == self._storyData.monster_id_3 then 
		posId = 3
		resId = self._storyData.monster_id_3
	else
		posId = 1
		resId = self._storyData.monster_id_1
	end

	return posId, resId
end

function StoryTalkLayer:_showRoleAtPos( pos, res_Id )
	pos = pos or 1
	local resId = res_Id or self._storyData.monster_id_0
	if type(resId) ~= "number" or resId < 0 then 
		resId = 1
	end

	self._knightPic = self._knightPic or {}
	local knightPic = self._knightPic[resId]
	local knightExist = true
	if not knightPic then 
		local knightResId = 0
		local knightName = 0

		if resId == 1 then 
			local knight_id, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
			local _info  = knight_info.get(baseId)
            if _info then
                -- knightResId = _info.res_id
                knightResId = G_Me.dressData:getDressedPic()
                knightName = _info.name
            end
        else
        	local _info = monster_info.get(resId)
        	if _info then 
            	knightResId = _info.res_id
            	knightName = _info.name
            end
		end

		self._knightPic[resId] = require("app.scenes.common.KnightPic").getHalfNode(knightResId, 0, true)
		self._knightName[resId] = knightName

		local lastIndex = self._knightPicIndex[pos]
		if lastIndex and lastIndex > 0 and self._knightPic[lastIndex] then 
			if lastIndex == self._lastKnightPos then 
				self._lastKnightPic = nil
			end 
			self._knightPic[lastIndex]:removeFromParentAndCleanup(true)
			self._knightPic[lastIndex] = nil
		end
		self._knightPicIndex[pos] = resId
		
		knightPic = self._knightPic[resId]
		knightExist = false

		if knightPic then 
			self._knightContainer:addNode(knightPic)
		end		
	end

	if knightPic then 
		if resId == self._lastKnightPos then 
			self:_moveSprite( knightPic, pos, MoveStatus.STATUS_STAND )
		elseif not knightExist then 
			self:_moveSprite( knightPic, pos, MoveStatus.STATUS_SHOW )
		else
			self:_moveSprite( knightPic, pos, MoveStatus.STATUS_JUMP )
		end

		knightPic:setColor(ccc3(255, 255, 255))
		if not knightPic._tSingleMoving then
			knightPic._tSingleMoving = EffectSingleMoving.run(knightPic, "smoving_idle", nil, {position=true}, 1+ math.floor(math.random()*20))
		end

		if resId ~= self._lastKnightPos then 
			if self._lastKnightPic then 
				self._lastKnightPic:setCascadeColorEnabled(true)
				self._lastKnightPic:setColor(ccc3(100,100,100))

				if self._lastKnightPic._tSingleMoving then
					self._lastKnightPic._tSingleMoving:stop()
					self._lastKnightPic._tSingleMoving = nil
				end
			end
		end

		self._lastKnightPic = knightPic
	end

	return self._knightName[resId] or "[DefaultName]"
end

function StoryTalkLayer:_moveSprite( role, pos, status )
	if not role then 
		return 
	end

	pos = pos or 1
	if pos < 1 then 
		pos = 1
	elseif pos > 3 then 
		pos = 3
	end

	status = status or MoveStatus.STATUS_SHOW
	if status == MoveStatus.STATUS_SHOW then
        --出现
        local position = RolePosList[pos].startPos
        role:setPosition(RolePosList[pos].startPos)
        role:setScale(0.8)
        role:setCascadeOpacityEnabled(true)
        startPos = role:getPositionInCCPoint()
        local arr = CCArray:create()
        arr:addObject(CCEaseBackOut:create(CCMoveTo:create(DelayTime,RolePosList[pos].endPos)))
        role:runAction(CCSequence:create(arr))
    elseif status == MoveStatus.STATUS_HIDE then
        -- 隐藏
        role:runAction(CCSpawn:createWithTwoActions(CCMoveTo:create(DelayTime, RolePosList[pos].startPos), 
        	CCFadeOut:create(DelayTime)))
        if role._tSingleMoving then
        	role._tSingleMoving:stop()
        	role._tSingleMoving = nil
        end
    elseif status == MoveStatus.STATUS_JUMP then 
        -- 原地跳
        local arr = CCArray:create()
        local jumpUp = CCJumpBy:create(0.2,ccp(0,0) , 15, 1)
        arr:addObject(jumpUp)
        role:runAction(CCSequence:create(arr))
    end
end

function StoryTalkLayer:_showTalkText( pos, name, func ) 
	if not self._scrollView or not self._storyData then 
		if func then 
			func()
		end
		return 
	end

	local item = require("app.scenes.common.StoryTalkItem").create(pos, name, 
		self._storyData.substance, self._storyData.dialogue_type, self._storyData.common_sound, self._showTalkRapid)
	if not item then  
		return 
	end

	if not self._contentNode then 
		self._contentNode = Layout:create()
		self._scrollView:addChild(self._contentNode)
	end	

	local itemSize = item:getSize()

	local contentSize = self._contentNode:getSize()
	self._contentNode:addChild(item)
	item:setPosition(ccp(0, self._maxScrollHeight))
	self._maxScrollHeight = self._maxScrollHeight + itemSize.height
	local contentWidth = contentSize.width > itemSize.width and contentSize.width or itemSize.width
	self._contentNode:setSize(CCSizeMake(contentWidth, contentSize.height + itemSize.height))
	contentSize = self._contentNode:getSize()

	local maxSize = self._scrollView:getInnerContainerSize()
	if maxSize.height < contentSize.height then 
		self._scrollView:setInnerContainerSize(CCSizeMake(maxSize.width, contentSize.height))
		self._contentNode:setPosition(ccp((maxSize.width - contentSize.width)/2, 0))
	else
		self._contentNode:setPosition(ccp((maxSize.width - contentSize.width)/2, maxSize.height - contentSize.height))
	end

	table.insert(self._talkItemList, #self._talkItemList + 1, item)
	if self._lastTalkItem then 
		self._lastTalkItem:setOpacity(200)
		self._lastTalkItem:showNextIcon(false)
		self._lastTalkItem:stopAudio()
	end

	self._lastTalkItem = item

	item:animationShow(func)
end

function StoryTalkLayer:showFace(  )
	if not self._storyData then 
		return 
	end

 	local resId = {}
 	resId[1] = self._storyData["face_1"]
 	resId[2] = self._storyData["face_2"]
 	resId[3] = self._storyData["face_3"]

	for i = 1,3 do
		local knightResId = 0
		knightResId = self._storyData["monster_id_"..i] or 0
        if resId[i] ~= 0 then
            if self._facePic[i] == nil then
                self._facePic[i] = ImageView:create()
                self._knightContainer:addChild(self._facePic[i], 4 )
            end
            self._facePic[i]:loadTexture(G_Path.getFaceIco(resId[i]))
             self:showFaceAction(self._facePic[i], MoveStatus.STATUS_SHOW)
             self._facePic[i]:setTag(resId[i])
        else
            if self._facePic[i] and self._facePic[i]:getTag() ~= 0 then
                self:showFaceAction(self._facePic[i], MoveStatus.STATUS_HIDE)
                self._facePic[i]:setTag(0)
            end
        end
        
        -- 设置笑脸位置
        local knightPic = knightResId > 0 and self._knightPic[knightResId]
        if self._facePic[i] and knightPic then
            if knightPic then
                local rect = knightPic:getCascadeBoundingBox()
                -- 230表示从人物脚下的基准坐标位置偏移的固定像素，这样表情不会因为不同图片的高度不同而导致位置不一致，并且可能在其他分辨率(480*800)直接出框的问题
                self._facePic[i]:setPosition(ccp(FacePosList[i], 230))
            end
        end
    end

	-- local faceRes = self._storyData["face_"..pos]
	-- if faceRes > 0 then 
	-- 	local facePic = self._facePic[pos]
	-- 	if not facePic then 
	-- 		facePic = ImageView:create()
	-- 	end
	-- 	facePic:loadTexture(G_Path.getFaceIco(faceRes)
	-- 	self._facePic[pos] = facePic
	-- 	facePic:setColor(ccc3(255, 255, 255))

	-- 	if facePic then 
	-- 		if pos == self._lastKnightPos then 
	-- 			self:_moveSprite( facePic, pos, MoveStatus.STATUS_STAND )
	-- 		elseif not knightExist then 
	-- 			self:showFaceAction(facePic, MoveStatus.STATUS_SHOW)
	-- 			self:_moveSprite( facePic, pos, MoveStatus.STATUS_SHOW )
	-- 		else
	-- 			self:showFaceAction(self.Face[i],MoveStatus.STATUS_HIDE)
	-- 		end
	-- 	end

	-- 	if pos ~= self._lastKnightPos then 
	-- 		if self._lastFacePic then 
	-- 			self._lastFacePic:setCascadeColorEnabled(true)
	-- 			self._lastFacePic:setColor(ccc3(100,100,100))
	-- 		end
	-- 	end

	-- 	if self._lastKnightPic then 
	-- 		local rect = self._lastKnightPic:getCascadeBoundingBox()
 --        	facePic:setPosition(ccp(FacePosList[i], rect.size.height))
 --        end

	-- 	self._lastFacePic = facePic
	-- end        
end

function StoryTalkLayer:showFaceAction(face, _status)
    if _status == MoveStatus.STATUS_SHOW then
        face:setScale(0.2)
    --    face:runAction(CCSpawn:createWithTwoActions(CCEaseBackOut:create(CCScaleTo:create(DelayTime,1)),CCFadeIn:create(DelayTime)))

    	local function moveUpAndDown()
    		face:stopAllActions()
    		local actMoveUp = CCMoveBy:create(0.5, ccp(0, 10))
    		local actMoveDown = CCMoveBy:create(0.5, ccp(0, -10))
    		local actSeq = CCSequence:createWithTwoActions(actMoveDown, actMoveUp)
    		local actRep = CCRepeatForever:create(actSeq)
    		face:runAction(actRep)
    	end
        local actScale1 = CCScaleTo:create(DelayTime - 0.1, 1.2)
        local actScale2 = CCScaleTo:create(0.1, 1)
        local actCallback = CCCallFunc:create(moveUpAndDown)
        local array = CCArray:create()
        array:addObject(actScale1)
        array:addObject(actScale2)
        array:addObject(actCallback)
        local actSeq = CCSequence:create(array)
        face:runAction(CCSpawn:createWithTwoActions(actSeq, CCFadeIn:create(DelayTime)))
    else
    	face:stopAllActions()
        face:runAction(CCFadeOut:create(DelayTime))
    end
end

function StoryTalkLayer:_playTalkItem( func )
	if not self._lastTalkItem then
		if func then 
			func()
		end
		return self:_exitStoryTalk()
	end

	self._lastTalkItem:doPlayTalk(func)
end

function StoryTalkLayer:onTouchBegin( x, y )
	self._posX = x
	self._posY = y
end

function StoryTalkLayer:onTouchEnd( x, y )
	if self._isEffecting then 
		return
	end

	if self:isValidTouch() and (math.abs(x - self._posX) > 10 or math.abs(y - self._posY) > 10) then 
		self:_highlightTalkList()
		return 
	end

  	if not self._lastTalkItem then 
  		--self:_switchNextTalk()
  		return self:_exitStoryTalk()
  	end

    if self._lastTalkItem:isShowing() then 
    	return 
    elseif self._lastTalkItem:isPlayingTalk() then
    	self._lastTalkItem:rapidFinishTalk()
    else
    	self:_switchNextTalk()
    end    
end

return StoryTalkLayer
