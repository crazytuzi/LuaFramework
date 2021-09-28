-- FileName: TDevelopSuccessLayer.lua 
-- Author: licong 
-- Date: 15/5/11 
-- Purpose: 宝物进阶成功界面 


module("TDevelopSuccessLayer", package.seeall)

require "script/animation/XMLSprite"
require "script/ui/treasure/develop/TreasureDevelopLayer"

local _touchPriority                		= nil
local _zOrder 								= nil
local _layer								= nil
local _showItemIfon 						= nil
local _addAttrTab 							= nil

local _mark 								= nil

--[[
	@des 	:初始化函数
--]]
function init()
	_touchPriority 							= nil
	_zOrder 								= nil
	_layer 									= nil
	_addAttrTab 							= nil
	_mark 									= nil
end

--[[
	@des 	:事件函数
	@param 	:事件
--]]
function fnHandlerOfTouch(event)
	if event == "ended" then
		TreasureDevelopLayer.showLayer(_showItemIfon.item_id)
		-- 设置界面记忆
		TreasureDevelopLayer.setChangeLayerMark( _mark )
	end
	return true
end


--[[
	@des 	:入口函数
	@param  : $p_itemInfo 			: 物品详细信息
	@param  : $p_addAttrTab 		: 新增属性信息
	@param  : $p_touchPriority      : 触摸优先级
	@param  : $p_ZOrder 			: Z轴
--]]
function showLayer(p_itemInfo, p_addAttrTab)
	init()

	_touchPriority = -1000
	_showItemIfon = p_itemInfo
	_addAttrTab = p_addAttrTab
	
	_mark = TreasureDevelopLayer.getChangeLayerMark()

	_layer = CCLayerColor:create(ccc4(0,0,0,255))
	_layer:setTouchEnabled(true)
	_layer:setTouchPriority(_touchPriority)
	_layer:registerScriptTouchHandler(fnHandlerOfTouch,false,_touchPriority,true)

	--转光特效
	local shineLayerSprite = XMLSprite:create("images/base/effect/hero/transfer/zhuanguang")
	shineLayerSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.74)
	-- shineLayerSprite:setVisible(false)
	shineLayerSprite:setScale(g_fElementScaleRatio)
	_layer:addChild(shineLayerSprite,1)

    --进阶成功特效
    local successLayerSprite = XMLSprite:create("images/base/effect/hero/transfer/jinjiechenggong")
	successLayerSprite:setAnchorPoint(ccp(0.5,0.5))
	successLayerSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.43)
	successLayerSprite:setScale(g_fElementScaleRatio)
	_layer:addChild(successLayerSprite,1)
	successLayerSprite:setReplayTimes(1,false)

    AudioUtil.playEffect("audio/effect/zhuanshengchenggong.mp3")

    --神装拍到屏幕上
	local itemSprite = TreasureDevelopLayer.createCardSpriteUI( _showItemIfon )
	itemSprite:setAnchorPoint(ccp(0.5,0.5))
	itemSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.74 - 10*g_fElementScaleRatio)
	_layer:addChild(itemSprite,2)
	itemSprite:setScale(itemSprite:getScale()*1.2)

	-- 新增属性
	local newFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1557") ,g_sFontPangWa,40,1,ccc3(0x00,0x00,0x00),type_shadow)
	newFont:setColor(ccc3(25,145,215))
	newFont:setScale(g_fElementScaleRatio)
	newFont:setAnchorPoint(ccp(0.5,0.5))
	newFont:setPosition(0.5*g_winSize.width,0.35*g_winSize.height)
	_layer:addChild(newFont)

	local posY = newFont:getPositionY()-50*g_fElementScaleRatio
	for attr_id,attr_value in pairs(_addAttrTab) do
		local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(attr_id,attr_value)
		local attrNameLabel = CCRenderLabel:create( affixInfo.displayName .. "：", g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameLabel:setColor(ccc3(0x00, 0xff, 0x18))
		attrNameLabel:setAnchorPoint(ccp(1, 0))
		posY = posY-40*g_fElementScaleRatio
		attrNameLabel:setPosition(ccp(0.5*g_winSize.width,posY))
		_layer:addChild(attrNameLabel)
		attrNameLabel:setScale(g_fElementScaleRatio)

		local attrNumLabel = CCRenderLabel:create("+" .. showNum,g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNumLabel:setColor(ccc3(0x00, 0xff, 0x18))
		attrNumLabel:setAnchorPoint(ccp(0, 0))
		attrNumLabel:setPosition(ccp(attrNameLabel:getPositionX()+10*g_fElementScaleRatio,attrNameLabel:getPositionY()))
		_layer:addChild(attrNumLabel)
		attrNumLabel:setScale(g_fElementScaleRatio)
	end

	MainScene.changeLayer(_layer,"TDevelopSuccessLayer")
end










