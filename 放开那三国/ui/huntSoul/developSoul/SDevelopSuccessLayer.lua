-- FileName: SDevelopSuccessLayer.lua 
-- Author: licong 
-- Date: 15/9/6 
-- Purpose: 战魂进阶成功界面 


module("SDevelopSuccessLayer", package.seeall)

require "script/animation/XMLSprite"


local _touchPriority                		= nil
local _zOrder 								= nil
local _layer								= nil
local _showItemIfon 						= nil
local _addAttrTab 							= nil

local _mark 								= nil

-- 页面跳转tag
kTagBag 				= 100
kTagFormation 			= 101

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

---------------------------------------------------------------- 界面跳转记忆 --------------------------------------------------------------------

--[[
	@des 	:页面跳转记忆
	@param 	:
	@return :
--]]
function layerMark()
  	if(_mark == kTagBag)then
  		-- 背包
  		require "script/ui/huntSoul/HuntSoulLayer"
		local layer = HuntSoulLayer.createHuntSoulLayer("fightSoulBag")
		MainScene.changeLayer(layer,"HuntSoulLayer")
  	elseif(_mark == kTagFormation)then
  		-- 阵容
  		require("script/ui/formation/FormationLayer")
        local formationLayer = FormationLayer.createLayer(_showItemIfon.hid, false, false, false, 2)
        MainScene.changeLayer(formationLayer, "formationLayer")
  	else
  		-- 背包
  		require "script/ui/huntSoul/HuntSoulLayer"
		local layer = HuntSoulLayer.createHuntSoulLayer("fightSoulBag")
		MainScene.changeLayer(layer,"HuntSoulLayer")
  	end
end
---------------------------------------------------------------- 按钮事件 --------------------------------------------------------------------

--[[
	@des 	:事件函数
	@param 	:事件
--]]
function fnHandlerOfTouch(event)
	if event == "ended" then
	    -- 跳转
		layerMark()
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
function showLayer(p_itemInfo, p_addAttrTab, p_mark)
	init()

	_touchPriority = -1000
	_showItemIfon = p_itemInfo
	_addAttrTab = p_addAttrTab
	_mark = p_mark

	-- 隐藏按钮
	MainScene.setMainSceneViewsVisible(false, false, false)

	_layer = CCLayerColor:create(ccc4(0,0,0,255))
	_layer:setTouchEnabled(true)
	_layer:setTouchPriority(_touchPriority)
	_layer:registerScriptTouchHandler(fnHandlerOfTouch,false,_touchPriority,true)

	--转光特效
	local shineLayerSprite = XMLSprite:create("images/hunt/effect/zhanhunBJ/zhanhunBJ")
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
	local itemSprite = ItemSprite.getItemSpriteByItemId(_showItemIfon.item_template_id,_showItemIfon.va_item_text.fsLevel,true)
	itemSprite:setAnchorPoint(ccp(0.5,0.5))
	itemSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.74 - 10*g_fElementScaleRatio)
	_layer:addChild(itemSprite,2)
	itemSprite:setScale(itemSprite:getScale()*1.2)

	-- 属性
	local newFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1641") ,g_sFontPangWa,40,1,ccc3(0x00,0x00,0x00),type_shadow)
	newFont:setColor(ccc3(25,145,215))
	newFont:setScale(g_fElementScaleRatio)
	newFont:setAnchorPoint(ccp(0.5,0.5))
	newFont:setPosition(0.5*g_winSize.width,0.35*g_winSize.height)
	_layer:addChild(newFont)

	local posY = newFont:getPositionY()-40*g_fElementScaleRatio
	for k,v in pairs(_addAttrTab) do
		local displayName = v.desc.displayName
		local displayNum = v.displayNum
		local attrNameLabel = CCRenderLabel:create(displayName .. "：", g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameLabel:setColor(ccc3(0x00, 0xff, 0x18))
		attrNameLabel:setAnchorPoint(ccp(1, 0))
		posY = posY-40*g_fElementScaleRatio
		attrNameLabel:setPosition(ccp(0.5*g_winSize.width,posY))
		_layer:addChild(attrNameLabel)
		attrNameLabel:setScale(g_fElementScaleRatio)

		local attrNumLabel = CCRenderLabel:create("+" .. displayNum,g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNumLabel:setColor(ccc3(0x00, 0xff, 0x18))
		attrNumLabel:setAnchorPoint(ccp(0, 0))
		attrNumLabel:setPosition(ccp(attrNameLabel:getPositionX()+10*g_fElementScaleRatio,attrNameLabel:getPositionY()))
		_layer:addChild(attrNumLabel)
		attrNumLabel:setScale(g_fElementScaleRatio)
	end

	-- 开启精炼属性
	local dbData = ItemUtil.getItemById(_showItemIfon.item_template_id)
	local str = nil
	if( tonumber(dbData.quality) >= 6 )then
		str = GetLocalizeStringBy("lic_1829")
	else
		str = GetLocalizeStringBy("lic_1644")
	end
	local newFont = CCRenderLabel:create( str ,g_sFontPangWa,40,1,ccc3(0x00,0x00,0x00),type_shadow)
	newFont:setColor(ccc3(0x00,0xff,0x18))
	newFont:setScale(g_fElementScaleRatio)
	newFont:setAnchorPoint(ccp(0.5,0))
	newFont:setPosition(0.5*g_winSize.width,posY-100*g_fElementScaleRatio)
	_layer:addChild(newFont)

	MainScene.changeLayer(_layer,"SDevelopSuccessLayer")
end






















