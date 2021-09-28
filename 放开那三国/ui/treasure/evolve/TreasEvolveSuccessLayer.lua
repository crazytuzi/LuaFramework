-- Filename：	TreasEvolveSuccessLayer.lua
-- Author：		zhz
-- Date：		2014-01-07
-- Purpose：		宝物精炼成功的特效layer
module("TreasEvolveSuccessLayer", package.seeall)


require "script/ui/item/TreasCardSprite"

local colorLayer= nil
function init(  )
	colorLayer = nil
end

local function fnHandlerOfTouch(event, x, y)
		if event == "ended" then
			colorLayer:removeFromParentAndCleanup(true)
		end
		return true
end

--[[
	@des:创建宝物精炼的特效
	@tparam: tparam{
		limitLv, 
		curWasterLv 
		item_temple_id
		affix{
		{
		{
			id:
			name:
			oldNum:
			newNum:
		 	isNew = true
		 }
		}
	}
]]
function fnCreateTransferEffect( tparam)

	init()

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
	colorLayer:setTouchEnabled(true)
	colorLayer:setTouchPriority(-3276)
	
	colorLayer:registerScriptTouchHandler(fnHandlerOfTouch, false, -3276, true)
	-- 等级、生命、物攻、法攻、物防、法防
	local nHeightOfAttrBg = 350*g_fElementScaleRatio
	local cs9Attr = CCScale9Sprite:create("images/hero/transfer/level_up/bg_ng_attr.png", CCRectMake(0, 0, 209, 49), CCRectMake(86, 14, 45, 20))
	cs9Attr:setPreferredSize(CCSizeMake(g_winSize.width, nHeightOfAttrBg))
	cs9Attr:setPosition(0, 80*g_fScaleY)
	--	cs9Attr:setScale(g_fScaleX)
	colorLayer:addChild(cs9Attr, 10, 1000)

	local nHeightOfUnit = nHeightOfAttrBg/5

	local y=nHeightOfUnit/2
	local affix = tparam.affix
	-- 0x51, 0xfb, 0xff
	for i=1, #affix do
		local csAttrName
		if(affix[i].isNew == false) then
			csAttrName=  CCRenderLabel:create(affix[i].name .. ":", g_sFontName,36,1,ccc3(0x0,0x0,0x0),type_stroke)
			csAttrName:setColor(ccc3(0x51, 0xfb, 0xff))
		else 
			csAttrName= CCRenderLabel:create(GetLocalizeStringBy("key_2671"), g_sFontName,36,1,ccc3(0,0,0), type_stroke)
			csAttrName:setColor(ccc3(0x67,0xf9,0x00))
		end	
		csAttrName:setScale(g_fElementScaleRatio)
		csAttrName:setAnchorPoint(ccp(0, 0.5))
		csAttrName:setPosition(0.117*g_winSize.width, y)
		cs9Attr:addChild(csAttrName, 1001, 1001)

		if(affix[i].isNew == false) then
			local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(tonumber(affix[i].id), tonumber(affix[i].oldNum))
			local csAttrValue01 = CCLabelTTF:create("".. displayNum , g_sFontName, 35)
			csAttrValue01:setScale(g_fElementScaleRatio)
			csAttrValue01:setColor(ccc3(255, 0x6c, 0))
			csAttrValue01:setPosition(0.243*g_winSize.width, y)
			csAttrValue01:setAnchorPoint(ccp(0, 0.5))
			cs9Attr:addChild(csAttrValue01, 1001, 1002)
		end
		-- 箭头特效
		local sImgPathArrow=CCString:create("images/base/effect/hero/transfer/jiantou")
		local clsEffectArrow=CCLayerSprite:layerSpriteWithNameAndCount(sImgPathArrow:getCString(), -1, CCString:create(""))
		clsEffectArrow:setScale(g_fElementScaleRatio)
		clsEffectArrow:setAnchorPoint(ccp(0, 0.5))
		clsEffectArrow:setPosition(0.51*g_winSize.width, y)
		cs9Attr:addChild(clsEffectArrow, 1001, 1003)

		local csAttrName_02=  CCRenderLabel:create(affix[i].name .. ":", g_sFontName,36,1,ccc3(0x0,0x0,0x0),type_stroke)
		csAttrName_02:setColor(ccc3(0x51, 0xfb, 0xff))
		csAttrName_02:setScale(g_fElementScaleRatio)
		csAttrName_02:setAnchorPoint(ccp(0, 0.5))
		csAttrName_02:setPosition(0.6*g_winSize.width, y)
		cs9Attr:addChild(csAttrName_02, 1001, 1001)

		local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(tonumber(affix[i].id), tonumber(affix[i].newNum))
		local csAttrValue02 = CCLabelTTF:create("" .. displayNum, g_sFontName, 35)
		csAttrValue02:setScale(g_fElementScaleRatio)
		csAttrValue02:setPosition(0.6*g_winSize.width+csAttrName_02:getContentSize().width*g_fElementScaleRatio +5, y)
		csAttrValue02:setColor(ccc3(0x67, 0xf9, 0))
		csAttrValue02:setAnchorPoint(ccp(0, 0.5))
		cs9Attr:addChild(csAttrValue02, 1001, 1004)

		if(affix[i].isNew == false) then
			local csArrowGreen = CCSprite:create("images/hero/transfer/arrow_green.png")
			csArrowGreen:setScale(g_fElementScaleRatio)
			csArrowGreen:setPosition(0.85*g_winSize.width, y)
			csArrowGreen:setAnchorPoint(ccp(0, 0.5))
			cs9Attr:addChild(csArrowGreen, 1001, 1005)
		end

		y = y + nHeightOfUnit
	end

	-- 钻石
	local diamondNode = getDiamondSprite(tparam.limitLv,tparam.curWasterLv)
	diamondNode:setPosition(cs9Attr:getContentSize().width/2,250*g_fElementScaleRatio)
	diamondNode:setAnchorPoint(ccp(0.5,0))
	diamondNode:setScale(g_fElementScaleRatio)
	cs9Attr:addChild(diamondNode)

	-- 转光特效
	local sImgPath=CCString:create("images/base/effect/hero/transfer/zhuanguang")
	local clsEffectZhuanGuang=CCLayerSprite:layerSpriteWithNameAndCount(sImgPath:getCString(), -1, CCString:create(""))
	clsEffectZhuanGuang:setPosition(g_winSize.width/2, 740*g_fScaleY)
	clsEffectZhuanGuang:setScale(g_fElementScaleRatio)
	colorLayer:addChild(clsEffectZhuanGuang, 11, 100)
	clsEffectZhuanGuang:setVisible(false)

	
	-- 进阶成功特效
	local sImgPathSuccess=CCString:create("images/treasure/evolve/jianlianchenggong/jianlianchenggong")
	local clsEffectSuccess=CCLayerSprite:layerSpriteWithNameAndCount(sImgPathSuccess:getCString(), -1, CCString:create(""))
	clsEffectSuccess:setAnchorPoint(ccp(0.5, 0.5))
	clsEffectSuccess:setScale(g_fElementScaleRatio)
	clsEffectSuccess:setPosition(g_winSize.width/2, 460*g_fScaleY)
	colorLayer:addChild(clsEffectSuccess, 999, 999)
	-- clsEffectSuccess:retain()
	local ccDelegateSuccess=BTAnimationEventDelegate:create()
	ccDelegateSuccess:registerLayerEndedHandler(function (actionName, xmlSprite)
		clsEffectSuccess:cleanup()
	end)
	ccDelegateSuccess:registerLayerChangedHandler(function (index, xmlSprite)

	end)
	clsEffectSuccess:setDelegate(ccDelegateSuccess)

	-- if _tHeroTransferedAttr then
	-- print(" DestinyData.changeHeroHtid()  is : ",  DestinyData.changeHeroHtid())
	local csCardShow = TreasCardSprite.createSprite(tonumber(tparam.item_temple_id), tparam.item_id ) --HeroPublicCC.createSpriteCardShow( DestinyData.changeHeroHtid() )
	csCardShow:setAnchorPoint(ccp(0.5, 0.5))
	csCardShow:setScale(g_fElementScaleRatio)
	csCardShow:setPosition(g_winSize.width/2, 740*g_fScaleY)
	colorLayer:addChild(csCardShow, 999, 999)
	csCardShow:setScale(1.5*g_fElementScaleRatio)
	local sequence = CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 0.8*g_fElementScaleRatio),
		CCCallFunc:create(function ( ... )
			clsEffectZhuanGuang:setVisible(true)
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/zhuanguang.mp3")
		end))
	csCardShow:runAction(sequence)
	-- end
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhuanshengchenggong.mp3")
	runningScene:addChild(colorLayer, 32767, 32767)
end

function getDiamondSprite(limitLv, curWasterLv )
	limitLv = 10
	local diamondNode= CCNode:create()
	diamondNode:setContentSize(CCSizeMake( 47* tonumber(limitLv),0))
	-- diamondNode:setAnchorPoint(ccp(0.5,0))
	limitLv = tonumber(limitLv)
	print("limitLv is : ", limitLv)
	for i=1, limitLv do
		local gemBg= CCSprite:create("images/common/big_gray_gem.png")
		gemBg:setPosition(ccp((i-1)*47 ,0))
		diamondNode:addChild(gemBg)
		if(i<= tonumber(curWasterLv)%10) then
			local gemSprite= TreasureUtil.getFixedLevelSprite(curWasterLv)
			gemSprite:setPosition(ccp(gemBg:getContentSize().width/2,gemBg:getContentSize().height/2 ))
			gemSprite:setAnchorPoint(ccp(0.5,0.5))
			gemBg:addChild(gemSprite)
			if(i==tonumber(curWasterLv)%10 ) then
				addDiamondEffect(gemSprite)
			end
		end
		if math.floor(tonumber(curWasterLv)/10) >= 1 and tonumber(curWasterLv)%10==0  then
			local gemSprite= TreasureUtil.getFixedLevelSprite(curWasterLv)
			gemSprite:setPosition(ccp(gemBg:getContentSize().width/2,gemBg:getContentSize().height/2 ))
			gemSprite:setAnchorPoint(ccp(0.5,0.5))
			gemBg:addChild(gemSprite)
			if(i==tonumber(curWasterLv)%10 ) then
				addDiamondEffect(gemSprite)
			end
		end

	end
	return diamondNode
end

function addDiamondEffect( gemSprite)


	local sImgPathSuccess=CCString:create("images/treasure/evolve/zuanshi/zuanshi")
	local clsEffectSuccess=CCLayerSprite:layerSpriteWithNameAndCount(sImgPathSuccess:getCString(), 0, CCString:create(""))
	clsEffectSuccess:setAnchorPoint(ccp(0.5, 0.5))
	clsEffectSuccess:setPosition(gemSprite:getContentSize().width/2,gemSprite:getContentSize().height/2)
	gemSprite:addChild(clsEffectSuccess)
	clsEffectSuccess:retain()
	 local animationEnd = function(actionName,xmlSprite)
	    print("actionName  is :", actionName)
	    print("xmlSprite  is : ",xmlSprite )
	    clsEffectSuccess:autorelease()
        clsEffectSuccess:removeFromParentAndCleanup(true)
        clsEffectSuccess = nil
    end

     local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    -- delegate:registerLayerChangedHandler(animationFrameChanged)
    clsEffectSuccess:setDelegate(delegate)
end






