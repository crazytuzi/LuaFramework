--[[--
	场景管理器:

	--By: yun.bo
	--2013/7/15
]]
local TFBaseManager 		= require('TFFramework.client.manager.TFBaseManager')
local TFSceneManager 		= class('TFSceneManager', TFSceneManager)
local TFSceneManagerModel 	= {}

TFSceneChangeType_Replace 	= 0
TFSceneChangeType_PushBack 	= 1
TFSceneChangeType_PopBack 	= 2

TFSceneChangeEffect_Fade 				= 0
TFSceneChangeEffect_FlipX 				= 1
TFSceneChangeEffect_FlipY 				= 2
TFSceneChangeEffect_FlipAngular 		= 3
TFSceneChangeEffect_ZoomFlipX			= 4
TFSceneChangeEffect_ZoomFlipY			= 5
TFSceneChangeEffect_ZoomFlipAngular 	= 6
TFSceneChangeEffect_PageTurn			= 7
	
TFSceneChangeEffect_ShrinkGrow			= 8
TFSceneChangeEffect_RotoZoom			= 9
TFSceneChangeEffect_MoveIn				= 10
TFSceneChangeEffect_SlideIn				= 11
TFSceneChangeEffect_Split				= 12
TFSceneChangeEffect_RotoZoom			= 13

TFSceneChangeEffect_JumpZoom 			= 14
TFSceneChangeEffect_ProgressRadialCW	= 15
TFSceneChangeEffect_ProgressRadialCCW	= 16
TFSceneChangeEffect_ProgressHorizontal 	= 17
TFSceneChangeEffect_ProgressVertical 	= 18
TFSceneChangeEffect_ProgressInOut 		= 19
TFSceneChangeEffect_ProgressOutIn 		= 20
TFSceneChangeEffect_CrossFade 			= 21
TFSceneChangeEffect_FadeTR 				= 22
TFSceneChangeEffect_FadeBL 				= 23
TFSceneChangeEffect_FadeUp 				= 24
TFSceneChangeEffect_FadeDown 			= 25
TFSceneChangeEffect_TurnOffTiles 		= 26
TFSceneChangeEffect_Shatter        		= 27

local tMap = {}
tMap[TFSceneChangeEffect_Fade] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local color = tEffectParam.color
	if color then
		return CCTransitionFade:create(duration, objScene, color)
	else
		return CCTransitionFade:create(duration, objScene)
	end
end

tMap[TFSceneChangeEffect_FlipX] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szType = tEffectParam.type or "right"
	if szType == "right" then
		return CCTransitionFlipX:create(duration, objScene, kCCTransitionOrientationRightOver)
	else -- left
		return CCTransitionFlipX:create(duration, objScene, kCCTransitionOrientationLeftOver)
	end
end

tMap[TFSceneChangeEffect_FlipY] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szType = tEffectParam.type or "up"
	if szType == "up" then
		return CCTransitionFlipY:create(duration, objScene, kCCTransitionOrientationUpOver)
	else -- down
		return CCTransitionFlipY:create(duration, objScene, kCCTransitionOrientationDownOver)
	end
end

tMap[TFSceneChangeEffect_FlipAngular] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szType = tEffectParam.type or "right"
	if szType == "right" then
		return CCTransitionFlipAngular:create(duration, objScene, kCCTransitionOrientationRightOver)
	elseif szType == "left" then
		return CCTransitionFlipAngular:create(duration, objScene, kCCTransitionOrientationLeftOver)
	end
end

tMap[TFSceneChangeEffect_ZoomFlipX] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szTypeszTypeszTypeszType = tEffectParam.type or "right"
	if szTypeszTypeszTypeszType == "right" then
		return CCTransitionZoomFlipX:create(duration, objScene, kCCTransitionOrientationRightOver)
	elseif szTypeszTypeszTypeszType == "left" then
		return CCTransitionZoomFlipX:create(duration, objScene, kCCTransitionOrientationLeftOver)
	end
end

tMap[TFSceneChangeEffect_ZoomFlipY] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szTypeszTypeszType = tEffectParam.type or "up"
	if szTypeszTypeszType == "up" then
		return CCTransitionZoomFlipY:create(duration, objScene, kCCTransitionOrientationUpOver)
	elseif szTypeszTypeszType == "down" then
		return CCTransitionZoomFlipY:create(duration, objScene, kCCTransitionOrientationDownOver)
	end
end

tMap[TFSceneChangeEffect_ZoomFlipAngular] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szTypeszType = tEffectParam.type or "right"
	if szTypeszType == "right" then
		return CCTransitionZoomFlipAngular:create(duration, objScene, kCCTransitionOrientationRightOver)
	elseif szTypeszType == "left" then
		return CCTransitionZoomFlipAngular:create(duration, objScene, kCCTransitionOrientationLeftOver)
	end
end

tMap[TFSceneChangeEffect_PageTurn] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szType = tEffectParam.type or "right"
	if szType == "right" then
		return CCTransitionPageTurn:create(duration, objScene, true)
	elseif szType == "left" then
		return CCTransitionPageTurn:create(duration, objScene, false)
	end
end

tMap[TFSceneChangeEffect_ShrinkGrow] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionShrinkGrow:create(duration, objScene)
end

tMap[TFSceneChangeEffect_RotoZoom] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionRotoZoom:create(duration, objScene)
end

tMap[TFSceneChangeEffect_MoveIn] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szType = tEffectParam.type or "right"
	if szType == "right" then
		return CCTransitionMoveInR:create(duration, objScene)
	elseif szType == "left" then
		return CCTransitionMoveInL:create(duration, objScene)
	elseif szType == "up" then
		return CCTransitionMoveInT:create(duration, objScene)
	elseif szType == "down" then
		return CCTransitionMoveInB:create(duration, objScene)
	end
end

tMap[TFSceneChangeEffect_SlideIn] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szTypeszType = tEffectParam.type or "right"
	if szTypeszType == "right" then
		return CCTransitionSlideInR:create(duration, objScene)
	elseif szTypeszType == "left" then
		return CCTransitionSlideInL:create(duration, objScene)
	elseif szTypeszType == "up" then
		return CCTransitionSlideInT:create(duration, objScene)
	elseif szTypeszType == "down" then
		return CCTransitionSlideInB:create(duration, objScene)
	end
end

tMap[TFSceneChangeEffect_Split] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	local szType = tEffectParam.type or "row"
	local nCnt = tEffectParam.count or 3
	if szType == "row" then
		return CCTransitionSplitRows:create(duration, objScene, nCnt)
	elseif szType == "col" then
		return CCTransitionSplitCols:create(duration, objScene, nCnt)
	end
end

tMap[TFSceneChangeEffect_JumpZoom] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionJumpZoom:create(duration, objScene)
end

tMap[TFSceneChangeEffect_ProgressRadialCW] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionProgressRadialCW:create(duration, objScene)
end

tMap[TFSceneChangeEffect_ProgressRadialCCW] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionProgressRadialCCW:create(duration, objScene)
end

tMap[TFSceneChangeEffect_ProgressHorizontal] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionProgressHorizontal:create(duration, objScene)
end

tMap[TFSceneChangeEffect_ProgressVertical] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionProgressVertical:create(duration, objScene)
end

tMap[TFSceneChangeEffect_ProgressInOut] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionProgressInOut:create(duration, objScene)
end

tMap[TFSceneChangeEffect_ProgressOutIn] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionProgressOutIn:create(duration, objScene)
end

tMap[TFSceneChangeEffect_CrossFade] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionCrossFade:create(duration, objScene)
end

tMap[TFSceneChangeEffect_FadeTR] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionFadeTR:create(duration, objScene)
end

tMap[TFSceneChangeEffect_FadeBL] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionFadeBL:create(duration, objScene)
end

tMap[TFSceneChangeEffect_FadeUp] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionFadeUp:create(duration, objScene)
end

tMap[TFSceneChangeEffect_FadeDown] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionFadeDown:create(duration, objScene)
end

tMap[TFSceneChangeEffect_TurnOffTiles] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	return CCTransitionTurnOffTiles:create(duration, objScene)
end
--[[
	tEffectParam的参数意义：
	minGlassSide    ：最中间小块的碎块的三角形径向边长
	circleScale     ：相邻的两个圈的的径向大小比例
	backColor       ：后面快的颜色设置，是个table{r,g,b}
	pauseTime       ： 碎裂中间停顿时间长,单位：s
	moveSpeed       :  碎块径向移动速度,单位:像素/s
	rotateSpeedAngle:  碎块旋转速度，单位: 度/s
	backTextureFile ：碎裂背面的纹理设置，设置文件名
	frontTexture	: 前面纹理设置，为CCTexture2D
]]--
tMap[TFSceneChangeEffect_Shatter] = function(objScene, tEffectParam)
	local duration = tEffectParam.duration or 1
	-- return TFTransitionShatter:create(duration, objScene)
	local effectScene = TFTransitionShatter:create(duration, objScene)
	if tEffectParam.minGlassSide then
		effectScene:setMinGlassSide(tEffectParam.minGlassSide)
	end
	if tEffectParam.circleScale then
		effectScene:setCircleScale(tEffectParam.circleScale)
	end
	if tEffectParam.backColor and tEffectParam.backColor.r and tEffectParam.backColor.g and tEffectParam.backColor.b then
		effectScene:setBackColor(ccc3(tEffectParam.backColor.r, tEffectParam.backColor.g, tEffectParam.backColor.b))
	end
	if tEffectParam.pauseTime then
		effectScene:setPauseTime(tEffectParam.pauseTime)
	end
	if tEffectParam.moveSpeed then 
		effectScene:setMoveSpeed(tEffectParam.moveSpeed)
	end
	if tEffectParam.rotateSpeedAngle then
		effectScene:setRotateSpeedAngle(tEffectParam.rotateSpeedAngle)
	end
	if tEffectParam.backTextureFile then
		effectScene:setBackTextureFile(tEffectParam.backTextureFile)
	end
	if tEffectParam.frontTexture then
		effectScene:setFrontTexture(tEffectParam.frontTexture)
	end

	return effectScene
end

function TFSceneManager:getSceneEffectFunc()
	return function(objScene, szChangeEffect, tEffectParam)
		if not tMap[szChangeEffect] then return objScene end

		return tMap[szChangeEffect](objScene, tEffectParam)
	end
end

function TFSceneManager:generateSceneChangeEffect(objScene, szChangeEffect, tEffectParam)
	if szChangeEffect then
		self.sceneEffectFunc = self.sceneEffectFunc or self:getSceneEffectFunc()
		return self.sceneEffectFunc(objScene, szChangeEffect, tEffectParam)
	end
	return objScene
end

function TFSceneManager:reset()
	TFSceneManagerModel.objLastScene = TFArray:new()
	TFSceneManagerModel.szLastSceneType = TFArray:new()
	TFSceneManagerModel.objCurScene = nil
	TFSceneManagerModel.szCurSceneType = nil
end

function TFSceneManager:ctor()
	TFSceneManagerModel.objLastScene = TFArray:new()
	TFSceneManagerModel.szLastSceneType = TFArray:new()
	TFSceneManagerModel.objCurScene = nil
	TFSceneManagerModel.szCurSceneType = nil
end

function TFSceneManager:createMEEditorScene(tSceneData, szPrePath, bIsNotLoadLogicFile)
	local scene = TFScene:create()
	local UIArr = TFDirector:loadUI(tSceneData, szPrePath, bIsNotLoadLogicFile)
	scene.mainLayer	= TFLayer:create()
	scene.mainLayer	:scheduleUpdate()
	scene:addChild(scene.mainLayer)

	local ui
	while UIArr:front() do
		ui = UIArr:popFront()	
		scene.mainLayer:addChild(ui)
	end
	function scene:enter()
		-- scene:addChild(scene.mainLayer)
	end
	function scene:leave()
		TFDirector:unLoadUI(tSceneData)
	end

	return scene
end

function TFSceneManager:readGameConfig(szGameConfigPath)
	local tGameConfig = require(szGameConfigPath)
	TFSceneManagerModel.szGameConfigPathDir = self:getFileDir(szGameConfigPath)
	TFSceneManagerModel.tScenes = {}
	for nID, tScene in pairs(tGameConfig.scenes) do
		local szPath = tScene.path
		szPath = string.trim(szPath)
		szPath = string.gsub(szPath, '/', '.')
		if string.lower(szPath['-4']) == '.lua' then
			szPath = szPath['1:-5']
		end
		TFSceneManagerModel.tScenes[tScene.name] = TFSceneManagerModel.szGameConfigPathDir .. szPath
	end
	return TFSceneManagerModel.tScenes
end

function TFSceneManager:getFileDir(szPath)
	local szPrePath = ''
	if string.lower(szPath['-4']) == '.lua' then
		szPrePath = szPath[':-5']
	else
		szPrePath = szPath
	end
	local nLen = #szPrePath
	while nLen > 0 do
		if szPrePath[nLen] == '.' then
			szPrePath = szPrePath[{1, nLen}]
			break
		end
		nLen = nLen - 1
	end
	return szPrePath
end

function TFSceneManager:createCustomScene(szSceneType, tData)
	local objScene
	if TFSceneManagerModel.tScenes and TFSceneManagerModel.tScenes[szSceneType] ~= nil then
		szSceneType = TFSceneManagerModel.tScenes[szSceneType]
	end
	objScene = require(szSceneType)
	--TFDirector:unRequire(szSceneType)
	local objCurScene = nil
	if instanceOf(objScene) ~= NONE_CLASS then
		objCurScene = objScene:new(tData)
	else
		local tSceneData = objScene
		local szPrePath = self:getFileDir(szSceneType)
		objCurScene = self:createMEEditorScene(tSceneData, szPrePath, tData)
	end
	return objCurScene
end

function TFSceneManager:restoreTempScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
	TFSceneManagerModel.tempSceneData = TFSceneManagerModel.tempSceneData or {}
	if type(TFSceneManagerModel.tempSceneData.szSceneType) == 'userdata' then TFSceneManagerModel.tempSceneData.szSceneType:release() end
	TFSceneManagerModel.tempSceneData.szSceneType 		= szSceneType
	TFSceneManagerModel.tempSceneData.tData 			= tData
	TFSceneManagerModel.tempSceneData.szChangType 		= szChangType
	TFSceneManagerModel.tempSceneData.szChangeEffect 	= szChangeEffect
	TFSceneManagerModel.tempSceneData.tEffectParam 		= tEffectParam
	if type(TFSceneManagerModel.tempSceneData.szSceneType) == 'userdata' then TFSceneManagerModel.tempSceneData.szSceneType:retain() end
end

function TFSceneManager:cleanTempScene()
	TFSceneManagerModel.tempSceneData = TFSceneManagerModel.tempSceneData or {}
	if type(TFSceneManagerModel.tempSceneData.szSceneType) == 'userdata' then TFSceneManagerModel.tempSceneData.szSceneType:release() end
	TFSceneManagerModel.tempSceneData.szSceneType 		= nil
	TFSceneManagerModel.tempSceneData.tData 			= nil
	TFSceneManagerModel.tempSceneData.szChangType 		= nil
	TFSceneManagerModel.tempSceneData.szChangeEffect 	= nil
	TFSceneManagerModel.tempSceneData.tEffectParam 		= nil
end

function TFSceneManager:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
	local objTmpScene = TFSceneManager:currentScene()
	if objTmpScene.__isEffectScene then 
		self:restoreTempScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
		objTmpScene:addMEListener(TFWIDGET_CLEANUP, function()
			TFDirector:addTimer(0, 1, function()
				local szSceneType 		= TFSceneManagerModel.tempSceneData.szSceneType 		
				local tData 			= TFSceneManagerModel.tempSceneData.tData 			
				local szChangType 		= TFSceneManagerModel.tempSceneData.szChangType 		
				local szChangeEffect 	= TFSceneManagerModel.tempSceneData.szChangeEffect 	
				local tEffectParam 		= TFSceneManagerModel.tempSceneData.tEffectParam 		
				self:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
				self:cleanTempScene()
			end)
		end)
		return
	end
	local szTmpSceneType = TFSceneManagerModel.szCurSceneType
	if szChangType == nil or szChangType == TFSceneChangeType_Replace then
		objTmpScene:addMEListener(TFWIDGET_EXIT, function()
				TFDirector:clearMovieClipCache()
				me.FrameCache:removeUnusedSpriteFrames()
				--me.TextureCache:removeUnusedTextures()
		end)
		
		local objCurScene 
		if type(szSceneType) == 'string' then
			objCurScene = self:createCustomScene(szSceneType, tData)
		else
			objCurScene = szSceneType
		end
		local objEffectCurScene = TFSceneManager:generateSceneChangeEffect(objCurScene, szChangeEffect, tEffectParam)
		if szChangeEffect then 
			objEffectCurScene.__isEffectScene = true 
			objEffectCurScene.__targetScene = objCurScene 
		end
		if objTmpScene then
			me.Director:replaceScene(objEffectCurScene)
		else
			me.Director:runWithScene(objEffectCurScene)
		end
		TFSceneManagerModel.objCurScene = objCurScene
		TFSceneManagerModel.szCurSceneType = szSceneType
		if objTmpScene and objTmpScene.leave then
			objTmpScene:leave()
		end
		TFFunction.call(objCurScene.enter, objCurScene, tData)
		return objCurScene

	elseif szChangType == TFSceneChangeType_PushBack then
		local objScene = nil
		local objCurScene = nil
		if type(szSceneType) == "string" then
			objCurScene = self:createCustomScene(szSceneType, tData)
		else
			objCurScene = szSceneType	--use for scene type
		end
		local objEffectCurScene = TFSceneManager:generateSceneChangeEffect(objCurScene, szChangeEffect, tEffectParam)
		if szChangeEffect then 
			objEffectCurScene.__isEffectScene = true 
			objEffectCurScene.__targetScene = objCurScene 
		end
		me.Director:pushScene(objEffectCurScene)
		
		TFSceneManagerModel.objLastScene:pushBack(objTmpScene)
		TFSceneManagerModel.szLastSceneType:pushBack(szTmpSceneType)
		TFSceneManagerModel.objCurScene = objCurScene
		TFSceneManagerModel.szCurSceneType = szSceneType
		TFFunction.call(objCurScene.enter, objCurScene, tData)
		return objCurScene
	elseif szChangType == TFSceneChangeType_PopBack then
		objTmpScene:addMEListener(TFWIDGET_EXIT, function()
			if objTmpScene and objTmpScene.leave then
				objTmpScene:leave()
				TFDirector:clearMovieClipCache()
				me.FrameCache:removeUnusedSpriteFrames()
				--me.TextureCache:removeUnusedTextures()
			end
		end)
		local objCurScene = TFSceneManagerModel.objLastScene:popBack()
		me.Director:popScene()
		TFSceneManagerModel.objCurScene = objCurScene
		TFSceneManagerModel.szCurSceneType = TFSceneManagerModel.szLastSceneType:popBack()
		return objCurScene
	end
end

function TFSceneManager:currentScene()
	return me.Director:getRunningScene()
end

function TFSceneManager:nextScene()
	return me.Director:getNextScene()
end

function TFSceneManager:clearScaleLayer()
	TFDirector.objControlLayer = nil
	TFDirector.objTouchLayer = nil
end

function TFSceneManager:setScaleLayer(objScene, objControlLayer, objTouchLayer, smallest, bigest)
	TFDirector.objControlLayer = objControlLayer
	TFDirector.objTouchLayer = objTouchLayer

	local initDistant = nil
    local lastDistant = nil
    local TouchFingerCount = 0;
    local PointArray = {}
    local ViewHeight = me.Director:getWinSize().height
    local ViewWidth = me.Director:getWinSize().width
    local width = me.EGLView:getFrameSize().width
    local height = me.EGLView:getFrameSize().height
    local curWidth = width
    local curHeight = height
    local deltW = 0
    local deltH = 0
    local curScale = 1
    local nx = 0
    local ny = 0
    local nMaxScale0 = math.min(smallest[1] / ViewWidth, smallest[2] / ViewHeight)
    local nMinScale0 = math.min(bigest[1] / ViewWidth, bigest[2] / ViewHeight)
    local nMaxScale, nMinScale = math.max(nMaxScale0, nMinScale0), math.min(nMaxScale0, nMinScale0)
    print("minScale, maxScale:", nMinScale, nMaxScale)

    local bIsMultiTouch = false

	TFDirector:registerKeyDown(90, {nGap = 500}, function() -- 'z'
		bIsMultiTouch = true	
	end)

	local mainLayer	= TFLayer:create()

function converPointToTouches(points)
    touches = {}
    local count = 0
    for i, v in pairs(points) do
        print("points::::::::::::::", v.x, v.y)
        touches[count+1] = v.x
        touches[count+2] = v.y
        touches[count+3] = i
        count = count + 3
    end
    return touches
end

local function onTouchBegan(eventType,touches)
    touches = converPointToTouches(touches)
	objTouchLayer:setTouchEnabled(false)
	print("MultiTouch began")
	for i=1, #touches, 3 do
	    TouchFingerCount = TouchFingerCount + 1
	    PointArray[TouchFingerCount] = {touches[i], touches[i+1]}

	    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 and bIsMultiTouch then
	    	local img1 = TFImage:create()
	       	img1:setTexture("test/reset.png")
	        img1:setPosition(ccp(touches[i], touches[i+1]))
	        img1:setSize(CCSizeMake(50, 50))
	        img1:setColor(ccc3(255, 0, 0))
	        img1:setShaderProgram("GrayShader", true)
	        img1:setTag(touches[i+2])
	        mainLayer:addChild(img1)

	        TouchFingerCount = TouchFingerCount + 1
	        PointArray[TouchFingerCount] = {ViewWidth - touches[i], ViewHeight - touches[i+1]}

	        local img2 = TFImage:create()
	        img2:setTexture("test/reset.png")
	        img2:setPosition(ccp(ViewWidth - touches[i], ViewHeight - touches[i+1]))
	        img2:setSize(CCSizeMake(50, 50))
	        img2:setColor(ccc3(255, 0, 0))
	        img2:setShaderProgram("GrayShader", true)
	        img2:setTag(touches[i+2]+1)
	        mainLayer:addChild(img2)
	    end

	    if (TouchFingerCount == 2) then
	        local deltX = (PointArray[1][1] - PointArray[2][1])*(PointArray[1][1] - PointArray[2][1])
	        local deltY = (PointArray[1][2] - PointArray[2][2])*(PointArray[1][2] - PointArray[2][2])
	        initDistant = math.sqrt(deltX + deltY)
	        nx = (PointArray[1][1] + PointArray[2][1])/2 - objControlLayer:getPosition().x;
	        ny = (PointArray[1][2] + PointArray[2][2])/2 - objControlLayer:getPosition().y;
	    end
	end
end

local function onTouchMoved(eventType,touches)
    touches = converPointToTouches(touches)
	if TouchFingerCount == 2 and #touches == 6 or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
	    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
	        touches[4], touches[5] = ViewWidth-touches[1], ViewHeight-touches[2]

	        local img = mainLayer:getWidgetByTag(touches[3])
	        if img ~= nil then
	            img:setPosition(ccp(touches[1], touches[2]))
	        end
	        img = mainLayer:getWidgetByTag(touches[3]+1)
	        if img ~= nil then
	            img:setPosition(ccp(touches[4], touches[5]))
	        end
	    end

	    local i = 1;
	    local x0, y0 = touches[i], touches[i+1]
	    PointArray[1] = { x0, y0 }
	    i = i+3
	    local x1, y1 = touches[i], touches[i+1]
	    PointArray[2] = { x1, y1 }
	    local deltX = (x0 - x1)*(x0 - x1)
	    local deltY = (y0 - y1)*(y0 - y1)
	    lastDistant = math.sqrt(deltX + deltY)

	    local per = lastDistant / initDistant 
	    objControlLayer:setPosition(ccp((x0+x1)/2 - nx*per, (y0+y1)/2 - ny*per))
	    objControlLayer:setScale(curScale * per)

	    if objControlLayer:getScale() < nMinScale then
	    	objControlLayer:setScale(nMinScale)
	    	per = nMinScale / curScale
	    	objControlLayer:setPosition(ccp((x0+x1)/2 - nx*per, (y0+y1)/2 - ny*per))
	    elseif objControlLayer:getScale() > nMaxScale then
	    	objControlLayer:setScale(nMaxScale)
	    	per = nMaxScale / curScale
	    	objControlLayer:setPosition(ccp((x0+x1)/2 - nx*per, (y0+y1)/2 - ny*per))
		end
	end
end

local function onTouchEnded(eventType,touches)
    touches = converPointToTouches(touches)
    for i=1, #touches, 3 do
        TouchFingerCount = TouchFingerCount-1
        local x = touches[i]
        local y = touches[i+1]
        for i, v in pairs(PointArray) do 
            if x == v[1] and y == v[2] then
                v[1] = 0
                v[2] = 0
                break
            end
        end
        if TouchFingerCount < 2 then
            curScale = objControlLayer:getScale()
        end
        if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
            PointArray = {}
            TouchFingerCount = 0
            local img = mainLayer:getWidgetByTag(touches[i+2])
            mainLayer:removeWidgetAndCleanUp(img, true)

            img = mainLayer:getWidgetByTag(touches[i+2]+1)
            mainLayer:removeWidgetAndCleanUp(img, true)
        end
    end
    if TouchFingerCount < 2 then
    	objTouchLayer:setTouchEnabled(true)
        objControlLayer:setAnchorPoint(ccp( 0, 0 ))
    	bIsMultiTouch = false
    end
end

	

    mainLayer:setSize(CCSizeMake(1000, 900))
    mainLayer:addMEListener(TFWIDGET_TOUCHBEGAN,onTouchBegan)
    mainLayer:addMEListener(TFWIDGET_TOUCHMOVED,onTouchMoved)
    mainLayer:addMEListener(TFWIDGET_TOUCHENDED,onTouchEnded)
    mainLayer:setTouchMode(kCCTouchesAllAtOnce)
	mainLayer:setTouchEnabled(true)
	objScene:addChild(mainLayer)
	print("MultiTouch Init Completed.")
end

return TFSceneManager:new()
