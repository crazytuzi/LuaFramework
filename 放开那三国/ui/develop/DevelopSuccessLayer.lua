-- Filename: DevelopSuccessLayer.lua
-- Author: zhangqiang
-- Date: 2014-09-10
-- Purpose: 进化成功后的显示层

module("DevelopSuccessLayer", package.seeall)
require "script/ui/develop/DevelopData"
require "script/ui/develop/DevelopLayer"

local kAdaptiveSize = CCSizeMake(640, g_winSize.height/g_fScaleX)
local kUINodeSize = CCSizeMake(640,738)

local kStarPosition = {
	ccp(230,697), ccp(266,699), ccp(302,700), ccp(338,700), ccp(374,699), ccp(410,697)
}
local _starIndex = nil

local kMainLayerPriority = -650
local kMenuPriority = -651

local _mainLayer = nil
local _blackLayer = nil
local _uiNode = nil
local _starBg = nil
local _heroBeforeDevelop = nil
local _nameBg = nil
local _heroNameLabel = nil
local _infoBtn = nil
local _bottomLabel = nil

--[[
	@desc :	初始化
	@param:	
	@ret  :
--]]
function init( ... )
	_starIndex = 1
	_mainLayer = nil
	_blackLayer = nil
	_uiNode = nil
	_starBg = nil
	_heroBeforeDevelop = nil
	_nameBg = nil
	_heroNameLabel = nil
	_infoBtn = nil
	_bottomLabel = {}
end

--[[
	@desc :	创建UI
	@param:	
	@ret  :
--]]
function createUI( ... )
	local node = CCNode:create()
	node:setContentSize(kUINodeSize)
	local nodeSize = CCSizeMake(640,0)

	-- --底部描述
	-- local bottomDesc = {" ", " "--[[GetLocalizeStringBy("zz_88"), GetLocalizeStringBy("zz_87")--]]}
	-- for i = 1,2 do
	-- 	_bottomLabel[i] = CCRenderLabel:create(bottomDesc[i], g_sFontPangWa, 28, 1, ccc3(0x00,0x00,0x00), type_shadow)
	-- 	_bottomLabel[i]:setColor(ccc3(0x00,0xff,0x18))
	-- 	_bottomLabel[i]:setVisible(false)
	-- 	_bottomLabel[i]:setAnchorPoint(ccp(0.5,0))
	-- 	_bottomLabel[i]:setPosition(320,nodeSize.height)
	-- 	node:addChild(_bottomLabel[i])
	-- 	nodeSize.height = nodeSize.height + _bottomLabel[i]:getContentSize().height + 5
	-- end
	nodeSize.height = nodeSize.height + 109 + 66

	local menu = CCMenu:create()
	menu:setTouchPriority(kMenuPriority)
	menu:setPosition(0,0)
	node:addChild(menu,1)
	--查看信息按钮
	require "script/libs/LuaCC"
	require "script/ui/develop/DevelopLayer"
	-- local infoBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",
	-- 	                                       CCSizeMake(160,56), GetLocalizeStringBy("zz_84"),ccc3(0xff,0xe4,0x00),30)
	_infoBtn = CreateUI.createScale9MenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png", nil,
			                                      CCSizeMake(168,65), GetLocalizeStringBy("zz_84"),28)
	_infoBtn:registerScriptTapHandler(DevelopLayer.tapInfoBtnCb)
	_infoBtn:setVisible(false)
	_infoBtn:setAnchorPoint(ccp(0.5,0))
	_infoBtn:setPosition(320,nodeSize.height)
	menu:addChild(_infoBtn)
	nodeSize.height = nodeSize.height + _infoBtn:getContentSize().height + 20

	--武将名字背景
	_nameBg = CCScale9Sprite:create("images/star/intimate/namebg.png")
	local nameBgSize = CCSizeMake(216,40)
	_nameBg:setPreferredSize(nameBgSize)
	_nameBg:setAnchorPoint(ccp(0.5,0))
	_nameBg:setPosition(320,nodeSize.height)
	_nameBg:runAction(CCFadeIn:create(0.5))
	node:addChild(_nameBg,1)
	nodeSize.height = nodeSize.height + nameBgSize.height

	--武将名字
	local curHeroInfo = DevelopData.getCurHeroInfo()
	local nameColor = HeroPublicLua.getCCColorByStarLevel(curHeroInfo.star_lv)
	_heroNameLabel = CCRenderLabel:create(curHeroInfo.heroName, g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_shadow)
	_heroNameLabel:setColor(nameColor)
	_heroNameLabel:setAnchorPoint(ccp(0.5,0.5))
	_heroNameLabel:setPosition(nameBgSize.width*0.5, nameBgSize.height*0.5+2)
	_heroNameLabel:runAction(CCFadeIn:create(0.5))
	_nameBg:addChild(_heroNameLabel)

	--武将图片
	--getHeroBodyImgByHTID
	local heroBodyPath = HeroUtil.getHeroBodyImgByHTID(curHeroInfo.htid)
	_heroBeforeDevelop = CCSprite:create(heroBodyPath)
	_heroBeforeDevelop:setAnchorPoint(ccp(0.5,0))
	_heroBeforeDevelop:setPosition(320,nodeSize.height)
	_heroBeforeDevelop:runAction(CCSequence:createWithTwoActions(CCFadeIn:create(0.5),CCCallFunc:create(runWholeEffect)))
	--_heroBeforeDevelop:setVisible(false)
	node:addChild(_heroBeforeDevelop)
	nodeSize.height = nodeSize.height + 356

	--星星背景
	_starBg = CCSprite:create("images/formation/stars_bg.png")
	_starBg:setAnchorPoint(ccp(0.5,0))
	_starBg:setPosition(320,nodeSize.height)
	_starBg:setVisible(false)
	node:addChild(_starBg,1)
	nodeSize.height = nodeSize.height + _starBg:getContentSize().height

	-- node:setContentSize(nodeSize)
	-- print("node:setContentSize",nodeSize.height)

	return node
end

--[[
	@desc :	进化成功后的全景特效
	@param:	
	@ret  :
--]]
require "script/audio/AudioUtil"
function runWholeEffect(  )
	if(Platform.getOS()~= "wp")then
		AudioUtil.playEffect("audio/effect/wujiangjinjie.mp3")
	end
	local size = _uiNode:getContentSize()

	-- local blackLayer = CCLayerColor:create(ccc4(0,0,0,255))
	-- blackLayer:setPosition(0,0)
	-- _mainLayer:addChild(blackLayer)

	local wholeEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/herodevelop/gyjinjie"), -1, CCString:create(""))
	--wholeEffect:setScale(0.625)
	wholeEffect:setAnchorPoint(ccp(0.5,0.5))
	wholeEffect:setPosition(size.width*0.5,460)
	_uiNode:addChild(wholeEffect)

	--替换
	local curDevelopInfo = DevelopData.getCurDevelopInfo()
	local imgPath = HeroUtil.getHeroBodyImgByHTID(curDevelopInfo.htid)
	local replaceFrame = tolua.cast(wholeEffect:getChildByTag(1004), "CCXMLSprite")
	replaceFrame:setReplaceFileName(CCString:create(imgPath))

	local effectDelegate = BTAnimationEventDelegate:create()
	wholeEffect:setDelegate(effectDelegate)

	local endedCb = function (actionName,xmlSprite)
		wholeEffect:cleanup()

		_mainLayer:setTouchEnabled(true)
		--_blackLayer:removeFromParentAndCleanup(true)
	end

	local changedCb = function (frameIndex,xmlSprite)
		-- print("frameIndex", frameIndex, xmlSprite:getCurrFrameNum(), xmlSprite:getCurAnimationIndex(), xmlSprite:getMyKeyFrameCount())
		if frameIndex == 44 then
			local replaceFrame = tolua.cast(wholeEffect:getChildByTag(1005), "CCXMLSprite")
			replaceFrame:setReplaceFileName(CCString:create(imgPath))
		elseif frameIndex == 45 then
			_heroBeforeDevelop:setVisible(false)
			_nameBg:setVisible(false)
			_heroNameLabel:setVisible(false)
		elseif frameIndex == 90 then
			_starBg:setVisible(true)
			runMultiStarEffect()

			--更新名字
			_heroNameLabel:setString(curDevelopInfo.heroName)
			_nameBg:setVisible(true)
			local nameColor = HeroPublicLua.getCCColorByStarLevel(curDevelopInfo.star_lv)
			_heroNameLabel:setColor(nameColor)
			_heroNameLabel:setVisible(true)

			_infoBtn:setVisible(true)

			runLabelEffect()

			_blackLayer:runAction(CCFadeOut:create(1))

			for k,v in ipairs(_bottomLabel) do
				v:setVisible(true)
			end
		else

		end
	end

	effectDelegate:registerLayerEndedHandler(endedCb)
	effectDelegate:registerLayerChangedHandler(changedCb)
end

--[[
	@desc :	进化成功label的特效
	@param:	
	@ret  :
--]]
function runLabelEffect( )
	AudioUtil.playEffect("audio/effect/zhuanshengchenggong.mp3")
	local size = _uiNode:getContentSize()

	local labelEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/herodevelop/jinhuacg"), -1, CCString:create(""))
	labelEffect:setAnchorPoint(ccp(0.5,1))
	labelEffect:setPosition(size.width*0.5,132)
	_uiNode:addChild(labelEffect)

	local effectDelegate = BTAnimationEventDelegate:create()
	labelEffect:setDelegate(effectDelegate)

	local endedCb = function (actionName,xmlSprite)
		labelEffect:cleanup()
		-- local successSprite = CCSprite:create("images/develop/develop_success_label.png")
		-- successSprite:setAnchorPoint(ccp(0.5,1))
		-- successSprite:setPosition(size.width*0.5+3,182)
		-- _uiNode:addChild(successSprite)
	end

	local changedCb = function (frameIndex,xmlSprite)
		-- body
	end
	effectDelegate:registerLayerEndedHandler(endedCb)
	effectDelegate:registerLayerChangedHandler(changedCb)
end

--[[
	@desc :	单个星星特效
	@param:	
	@ret  :
--]]
function runSingleStarEffect()
	if _starIndex > #kStarPosition then
		return
	end
	AudioUtil.playEffect("audio/effect/zhaojiangxingji.mp3")
	local position = kStarPosition[_starIndex]
	_starIndex = _starIndex+1

	local starEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/herodevelop/xxbao"), -1, CCString:create(""))
	starEffect:setAnchorPoint(ccp(0.5,0.5))
	starEffect:setPosition(position.x, position.y)
	_uiNode:addChild(starEffect,1)

	local effectDelegate = BTAnimationEventDelegate:create()
	starEffect:setDelegate(effectDelegate)

	local endedCb = function (actionName,xmlSprite)
		starEffect:removeFromParentAndCleanup(true)
		local star = CCSprite:create("images/shop/pub/star.png")
		star:setAnchorPoint(ccp(0.5,0.5))
		star:setPosition(position.x, position.y)
		_uiNode:addChild(star,1)
	end

	local changedCb = function (frameIndex,xmlSprite)
		-- body
	end
	effectDelegate:registerLayerEndedHandler(endedCb)
	effectDelegate:registerLayerChangedHandler(changedCb)
end

--[[
	@desc :	多个星星特效
	@param:	
	@ret  :
--]]
function runMultiStarEffect( ... )
	local actionArr = CCArray:create()
	for i = 1,6 do
		actionArr:addObject(CCCallFuncN:create(runSingleStarEffect))
		actionArr:addObject(CCDelayTime:create(0.5))
	end
	_uiNode:runAction(CCSequence:create(actionArr))
end

--[[
	@desc :	创建层
	@param:	
	@ret  :
--]]
function createLayer( ... )
	init()

	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)
	_mainLayer:setScale(g_fScaleX)

	local layerBg = CCSprite:create("images/develop/success_bg.jpg")
	layerBg:setScale(MainScene.bgScale/g_fScaleX)
	layerBg:setAnchorPoint(ccp(0.5,0))
	layerBg:setPosition(320,0)
	_mainLayer:addChild(layerBg)

	_blackLayer = CCLayerColor:create(ccc4(0,0,0,255))
	_blackLayer:setContentSize(kAdaptiveSize)
	_blackLayer:setPosition(0,0)
	_mainLayer:addChild(_blackLayer)

	local menu = CCMenu:create()
	menu:setPosition(0,0)
	menu:setTouchPriority(kMenuPriority)
	_mainLayer:addChild(menu,1)

	--返回按钮
	local goBackBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	goBackBtn:registerScriptTapHandler(tapGoBackBtnCb)
	goBackBtn:setAnchorPoint(ccp(0,0))
	goBackBtn:setPosition(540, kAdaptiveSize.height-100)
	menu:addChild(goBackBtn)

	_uiNode = createUI()
	_uiNode:setAnchorPoint(ccp(0.5,0.5))
	_uiNode:setPosition(320,kAdaptiveSize.height*0.5)
	_mainLayer:addChild(_uiNode,1)

	--runWholeEffect()

	return _mainLayer
end

--[[
	@desc :	显示层
	@param:	
	@ret  :
--]]
function showLayer( ... )
	local scene = CCDirector:sharedDirector():getRunningScene()

	local mainLayer = createLayer()
	mainLayer:setPosition(0,0)
	scene:addChild(mainLayer)
end

-----------------------------------------------------------[[回调函数]]---------------------------------------------------------
--[[
	@desc :	层创建和释放时的回调
	@param:	
	@ret  :	
--]]
function onNodeEvent( p_eventType )
	local touchLayerCb = function ( p_eventType, p_touchX, p_touchY )
		if p_eventType == "began" then
			return true
		elseif p_eventType == "ended" then
			-- if _mainLayer ~= nil then
			-- 	_mainLayer:removeFromParentAndCleanup(true)
			-- 	_mainLayer = nil
			-- end
			--DevelopLayer.setUIVisible(true)
			--DevelopLayer.tapGoBackBtnCb()
		else
			print("moved")
		end
	end

	if p_eventType == "enter" then
		_mainLayer:registerScriptTouchHandler(touchLayerCb, false, kMainLayerPriority, true)
		_mainLayer:setTouchEnabled(false)
	elseif p_eventType == "exit" then
		_mainLayer:unregisterScriptTouchHandler()
	else

	end
end

function tapGoBackBtnCb( p_tag, p_item )
	_mainLayer:removeFromParentAndCleanup(true)
	_mainLayer = nil

	DevelopLayer.tapGoBackBtnCb(p_tag, p_item)
end