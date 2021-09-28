-- Filename：	EvolveSuccessLayer.lua
-- Author：		Zhang zihang
-- Date：		2014-12-18
-- Purpose：		神兵进化成功界面

module("EvolveSuccessLayer", package.seeall)

local _touchPriority
local _zOrder
local _layer
local _itemId
local _hid

--==================== Init ====================

--[[
	@des 	:初始化函数
--]]
function init()
	_touchPriority = nil
	_zOrder = nil
	_layer = nil
	_itemId = nil
	_hid = nil
end

--[[
	@des 	:事件函数
	@param 	:事件
--]]
function fnHandlerOfTouch(event)
	if event == "ended" then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil

		require "script/ui/godweapon/GodWeaponEvolveLayer"
		GodWeaponEvolveLayer.createLayer(_itemId,_hid)
	end
	return true
end

--==================== Entrance ====================

--[[
	@des 	:入口函数
	@param 	: $p_hid 				: 武将hid
	@param 	: $p_itemInfo 			: 物品信息
	@param  : $p_newEvolveNum		: 新的总进化次数
	@param  : $p_attrInfo 			: 新老属性信息
	@param  : $p_itemId 			: 物品id
	@param  : $p_touchPriority      : 触摸优先级
	@param  : $p_ZOrder 			: Z轴
--]]
function showLayer(p_hid,p_itemInfo,p_newEvolveNum,p_lv,p_attrInfo,p_itemId,p_touchPriority,p_ZOrder)
	init()

	_touchPriority = p_touchPriority or -1000
	_zOrder = p_ZOrder or 1000
	_itemId = p_itemId

	_layer = CCLayerColor:create(ccc4(0,0,0,255))
	_layer:setTouchEnabled(true)
	_layer:setTouchPriority(_touchPriority)
	_layer:registerScriptTouchHandler(fnHandlerOfTouch,false,_touchPriority,true)

	--转光特效
	local shineLayerSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hero/transfer/zhuanguang"),-1,CCString:create(""))
	shineLayerSprite:setAnchorPoint(ccp(0.5,0.5))
	shineLayerSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.74)
	shineLayerSprite:setVisible(false)
	shineLayerSprite:setScale(g_fElementScaleRatio)
	_layer:addChild(shineLayerSprite,1)

	local animationEnd = function(actionName,xmlSprite)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    
    shineLayerSprite:setDelegate(delegate)
    --进阶成功特效
    local successLayerSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/hero/transfer/jinjiechenggong",-1,CCString:create(""))
	successLayerSprite:setAnchorPoint(ccp(0.5,0.5))
	if(p_newEvolveNum~=2 and p_newEvolveNum~=5 and p_newEvolveNum~=9 and p_newEvolveNum~=14)then
		successLayerSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.43)
	else
		successLayerSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.47)
	end
	successLayerSprite:setScale(g_fElementScaleRatio)
	_layer:addChild(successLayerSprite,1)

	local p_y = g_winSize.height*0.46-successLayerSprite:getContentSize().height*0.5*g_fElementScaleRatio
	if(p_newEvolveNum==2)then
		local tipLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("llp_516"),g_sFontPangWa,25)
		tipLabel_1:setColor(ccc3(0, 0xeb, 0x21))
		local tipLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("llp_521"),g_sFontPangWa,25)
		tipLabel_2:setColor(ccc3(0xd9,0xd9,0xd9))
		local tipLabel_3 = CCLabelTTF:create(GetLocalizeStringBy("llp_517"),g_sFontPangWa,25)
		tipLabel_3:setColor(ccc3(0x51, 0xfb, 0xff))

		local tipLabel = BaseUI.createHorizontalNode({tipLabel_1,tipLabel_2,tipLabel_3})
		tipLabel:setAnchorPoint(ccp(0.5,1))
		tipLabel:setPosition(ccp(g_winSize.width*0.5,p_y-tipLabel:getContentSize().height*1.5))
		tipLabel:setScale(g_fScaleX)
		_layer:addChild(tipLabel)
	elseif(p_newEvolveNum==5)then
		local tipLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("llp_517"),g_sFontPangWa,25)
		tipLabel_1:setColor(ccc3(0x51, 0xfb, 0xff))
		local tipLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("llp_521"),g_sFontPangWa,25)
		tipLabel_2:setColor(ccc3(0xd9,0xd9,0xd9))
		local tipLabel_3 = CCLabelTTF:create(GetLocalizeStringBy("llp_518"),g_sFontPangWa,25)
		tipLabel_3:setColor(ccc3(255, 0, 0xe1))

		local tipLabel = BaseUI.createHorizontalNode({tipLabel_1,tipLabel_2,tipLabel_3})
		tipLabel:setAnchorPoint(ccp(0.5,1))
		tipLabel:setPosition(ccp(g_winSize.width*0.5,p_y-tipLabel:getContentSize().height*1.5))
		tipLabel:setScale(g_fScaleX)
		_layer:addChild(tipLabel)
	elseif(p_newEvolveNum==9)then
		local tipLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("llp_518"),g_sFontPangWa,25)
		tipLabel_1:setColor(ccc3(255, 0, 0xe1))
		local tipLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("llp_521"),g_sFontPangWa,25)
		tipLabel_2:setColor(ccc3(0xd9,0xd9,0xd9))
		local tipLabel_3 = CCLabelTTF:create(GetLocalizeStringBy("llp_519"),g_sFontPangWa,25)
		tipLabel_3:setColor(ccc3(255, 0x84, 0))

		local tipLabel = BaseUI.createHorizontalNode({tipLabel_1,tipLabel_2,tipLabel_3})
		tipLabel:setAnchorPoint(ccp(0.5,1))
		tipLabel:setPosition(ccp(g_winSize.width*0.5,p_y-tipLabel:getContentSize().height*1.5))
		tipLabel:setScale(g_fScaleX)
		_layer:addChild(tipLabel)
	elseif(p_newEvolveNum==14)then
		local tipLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("llp_519"),g_sFontPangWa,25)
		tipLabel_1:setColor(ccc3(255, 0x84, 0))
		local tipLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("llp_521"),g_sFontPangWa,25)
		tipLabel_2:setColor(ccc3(0xd9,0xd9,0xd9))
		local tipLabel_3 = CCLabelTTF:create(GetLocalizeStringBy("llp_520"),g_sFontPangWa,25)
		tipLabel_3:setColor(ccc3(255, 0x27, 0x27))

		local tipLabel = BaseUI.createHorizontalNode({tipLabel_1,tipLabel_2,tipLabel_3})
		tipLabel:setAnchorPoint(ccp(0.5,1))
		tipLabel:setPosition(ccp(g_winSize.width*0.5,p_y-tipLabel:getContentSize().height*1.5))
		tipLabel:setScale(g_fScaleX)
		_layer:addChild(tipLabel)
	end

 	local ccDelegateSuccess = BTAnimationEventDelegate:create()
	ccDelegateSuccess:registerLayerEndedHandler(function (actionName,xmlSprite)
		successLayerSprite:cleanup()
	end)
	ccDelegateSuccess:registerLayerChangedHandler(function (index, xmlSprite)
	end)
	successLayerSprite:setDelegate(ccDelegateSuccess)

    AudioUtil.playEffect("audio/effect/zhuanshengchenggong.mp3")

    --神装拍到屏幕上
	local itemSprite = GodWeaponItemUtil.getWeaponBigSprite(nil,nil,p_hid,p_itemInfo,p_newEvolveNum,true)
	itemSprite:setAnchorPoint(ccp(0.5,0.5))
	itemSprite:setScale(g_fElementScaleRatio)
	itemSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.74 - 10*g_fElementScaleRatio)
	itemSprite:setScale(1.5*g_fElementScaleRatio)
	_layer:addChild(itemSprite,2)
	local sequence = CCSequence:createWithTwoActions(CCScaleTo:create(0.3,0.8*g_fElementScaleRatio),
		CCCallFunc:create(function()
			shineLayerSprite:setVisible(true)
			AudioUtil.playEffect("audio/effect/zhuanguang.mp3")
		end))
	itemSprite:runAction(sequence)

	local quality,showNum = GodWeaponItemUtil.getDBQualityAndShowNum(p_itemInfo.itemDesc.id,p_newEvolveNum)
	local itemNameLabel = CCRenderLabel:create(p_itemInfo.itemDesc.name,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_shadow)
	itemNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
	local itemLevelLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1224",showNum),g_sFontName,30,1,ccc3(0x00,0x00,0x00),type_shadow)
	itemLevelLabel:setColor(ccc3(0x00,0xff,0x18))

	local nameConnectNode = BaseUI.createHorizontalNode({itemNameLabel,itemLevelLabel})
	nameConnectNode:setAnchorPoint(ccp(0.5,0))
	if(p_newEvolveNum~=2 and p_newEvolveNum~=5 and p_newEvolveNum~=9 and p_newEvolveNum~=14)then
		nameConnectNode:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	else
		nameConnectNode:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.53))
	end
	nameConnectNode:setScale(g_fElementScaleRatio)
	_layer:addChild(nameConnectNode)

	local forMax = #p_attrInfo.new + 1
	local attrNameTable = 	{
								["1"] = "life",
								["4"] = "physical_defend",
								["5"] = "magic_defend",
								["9"] = "attack",
							}
	local beginHeigh = g_winSize.height*0.33
	for i = 1,forMax do
		local posY = beginHeigh - (i-1)*g_winSize.height*0.07

		local spriteString_1,spriteString_2,vString_1,vString_2,minus
		if i == 1 then
			spriteString_1 = GetLocalizeStringBy("key_1734") .. "："
			spriteString_2 = GetLocalizeStringBy("key_1734") .. "："
			vString_1 = p_lv
			vString_2 = p_lv
			minus = 0
		else
			if p_attrInfo.old[i-1] == nil then
				spriteString_1 = " "
				vString_1 = " "
				minus = tonumber(p_attrInfo.new[i-1].realNum)
			else
				spriteString_1 = p_attrInfo.new[i-1].name .. "："
				vString_1 = "+" .. p_attrInfo.old[i-1].showNum
				minus = tonumber(p_attrInfo.new[i-1].realNum) - tonumber(p_attrInfo.old[i-1].realNum)
			end
			spriteString_2 = p_attrInfo.new[i-1].name .. "："
			vString_2 = "+" .. p_attrInfo.new[i-1].showNum
		end
		--名字图片
		local nameSprite = CCRenderLabel:create(spriteString_1,g_sFontPangWa,38,1,ccc3(0x00,0x00,0x00),type_shadow)
		nameSprite:setColor(ccc3(25,145,215))
		nameSprite:setScale(g_fElementScaleRatio)
		nameSprite:setAnchorPoint(ccp(0,0.5))
		nameSprite:setPosition(0.02*g_winSize.width,posY)
		_layer:addChild(nameSprite)
		--原始值
		local value_1_label = CCLabelTTF:create(vString_1,g_sFontName,35)
		value_1_label:setScale(g_fElementScaleRatio)
		value_1_label:setColor(ccc3(255, 0x6c,0))
		value_1_label:setPosition(0.2*g_winSize.width,posY)
		value_1_label:setAnchorPoint(ccp(0, 0.5))
		_layer:addChild(value_1_label)
		-- 箭头特效
		local arrowLayerSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/hero/transfer/jiantou",-1,CCString:create(""))
		arrowLayerSprite:setScale(g_fElementScaleRatio)
		arrowLayerSprite:setAnchorPoint(ccp(0,0.5))
		arrowLayerSprite:setPosition(0.48*g_winSize.width,posY)
		_layer:addChild(arrowLayerSprite)

		--名字图片
		local newSprite = CCRenderLabel:create(spriteString_2,g_sFontPangWa,38,1,ccc3(0x00,0x00,0x00),type_shadow)
		newSprite:setColor(ccc3(25,145,215))
		newSprite:setScale(g_fElementScaleRatio)
		newSprite:setAnchorPoint(ccp(0,0.5))
		newSprite:setPosition(0.6*g_winSize.width,posY)
		_layer:addChild(newSprite)

		--新值
		local value_2_label = CCLabelTTF:create(vString_2,g_sFontName,35)
		value_2_label:setScale(g_fElementScaleRatio)
		value_2_label:setPosition(0.78*g_winSize.width,posY)
		value_2_label:setColor(ccc3(0x67,0xf9,0))
		value_2_label:setAnchorPoint(ccp(0,0.5))
		_layer:addChild(value_2_label)

		if minus > 0 then
			local greenSprite = CCSprite:create("images/hero/transfer/arrow_green.png")
			greenSprite:setScale(g_fElementScaleRatio)
			greenSprite:setPosition(0.98*g_winSize.width,posY)
			greenSprite:setAnchorPoint(ccp(1,0.5))
			_layer:addChild(greenSprite)
		end
	end

	MainScene.setMainSceneViewsVisible(false,false,false)
	MainScene.changeLayer(_layer,"EvolveSuccessLayer")
end