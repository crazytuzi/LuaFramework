-- FileName: WorldArenaAfterBattle.lua 
-- Author: licong 
-- Date: 15/7/8 
-- Purpose: 巅峰对决结算


module("WorldArenaAfterBattle", package.seeall)

local _bgLayer  						= nil

local _touchPriority  					= nil

local _isWin 							= false
local _callBack 						= nil
local _rewardTab 						= nil

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer  							= nil

	_touchPriority  					= nil
	_isWin 								= false
	_callBack 							= nil
	_rewardTab 							= nil
end

--[[
	@des 	: touch事件处理
	@param 	: 
	@return : 
--]]
local function onTouchesHandler( eventType, x, y )
	return true
end

--[[
	@des 	:确定按钮回调
	@param 	:
	@return :
--]]
function okMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

   	require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    require "script/audio/AudioUtil"
    AudioUtil.playBgm("audio/bgm/music15.mp3",true)

   	if(_callBack)then 
   		_callBack()
   	end
end

--[[
	@des 	:重播按钮回调
	@param 	:
	@return :
--]]
function replayMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/battle/BattleLayer"
    BattleLayer.replay()
   
end


--------------------------------------------------------------------- 创建ui ---------------------------------------------------------------------------------

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer( p_touchPriority, p_isWin, p_callBack, p_rewardTab, p_curContiNum, p_curTerminalContiNum )
	-- 初始化
	init()

	_isWin = p_isWin
	_callBack = p_callBack
	_rewardTab = p_rewardTab

	_touchPriority = p_touchPriority or -500

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))

	-- 背景
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(520,400))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(bgSprite)
	bgSprite:setScale(g_fElementScaleRatio)

	-- 按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-3)
    bgSprite:addChild(menuBar)
    
    -- 确定按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local okMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    okMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	okMenuItem:registerScriptTapHandler(okMenuItemCallBack)
	okMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.7,bgSprite:getContentSize().height*0.2))
	menuBar:addChild(okMenuItem)

    local font1 = CCRenderLabel:create( GetLocalizeStringBy("key_1985") , g_sFontPangWa, 30, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font1:setAnchorPoint(ccp(0.5,0.5))
    font1:setColor(ccc3(0xff, 0xf6, 0x00))
    font1:setPosition(ccp(okMenuItem:getContentSize().width*0.5,okMenuItem:getContentSize().height*0.5))
    okMenuItem:addChild(font1,10)


	-- 重播按钮
	local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local replayMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    replayMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	replayMenuItem:registerScriptTapHandler(replayMenuItemCallBack)
	replayMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.3,bgSprite:getContentSize().height*0.2))
	menuBar:addChild(replayMenuItem)

	local font2 = CCRenderLabel:create( GetLocalizeStringBy("key_2184") , g_sFontPangWa, 30, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font2:setAnchorPoint(ccp(0.5,0.5))
    font2:setColor(ccc3(0xff, 0xf6, 0x00))
    font2:setPosition(ccp(replayMenuItem:getContentSize().width*0.5,replayMenuItem:getContentSize().height*0.5))
    replayMenuItem:addChild(font2,10)

    if( _isWin )then
	    -- 胜利特效
	    local winSprite1 = XMLSprite:create("images/battle/xml/report/zhandoushengli01")
	    winSprite1:setAnchorPoint(ccp(0.5,0.5))
	    winSprite1:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-20))
	    bgSprite:addChild(winSprite1,10)
	    winSprite1:setReplayTimes(1)

	    local winSprite2 = XMLSprite:create("images/battle/xml/report/zhandoushengli02")
	    winSprite2:setAnchorPoint(ccp(0.5,0.5))
	    winSprite2:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-20))
	    bgSprite:addChild(winSprite2,9)
	    winSprite2:setReplayTimes(1)

	    local winSprite3 = XMLSprite:create("images/battle/xml/report/zhandoushengli03")
	    winSprite3:setAnchorPoint(ccp(0.5, 0.5))
	    winSprite3:setPosition(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height)
	    bgSprite:addChild(winSprite3,-1)
	    winSprite3:setVisible(false)
	    local function showWinSprite3( ... )
	    	winSprite3:setVisible(true)
	    end 
	    performWithDelay(winSprite3, showWinSprite3, 1)

	    -- 恭喜您获得了胜利
	    local tipFont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1618") , g_sFontPangWa, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    tipFont1:setAnchorPoint(ccp(0.5,1))
	    tipFont1:setColor(ccc3(0xff, 0xf6, 0x00))
	    tipFont1:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-50))
	    bgSprite:addChild(tipFont1)

	    if( not table.isEmpty(_rewardTab) )then
	    	local tipNode1 = nil
			local tipNode2 = nil
			local tipNode3 = nil
			local posY = bgSprite:getContentSize().height - 130
			if( not table.isEmpty(_rewardTab.win_reward) )then
				tipNode1 = WorldArenaMainLayer.getRewardDesTip( _rewardTab.win_reward, GetLocalizeStringBy("lic_1620"),500,1 )
				tipNode1:setAnchorPoint(ccp(0,0))
		    	tipNode1:setPosition(ccp(65,posY))
		    	bgSprite:addChild(tipNode1)
		    	posY = posY - 60
			end
			if( not table.isEmpty(_rewardTab.conti_reward) and p_curContiNum ~= nil and tonumber(p_curContiNum) > 1 )then
				tipNode2 = WorldArenaMainLayer.getRewardDesTip( _rewardTab.conti_reward, GetLocalizeStringBy("lic_1621",tonumber(p_curContiNum)) ,500,1 )
				tipNode2:setAnchorPoint(ccp(0,0))
		    	tipNode2:setPosition(ccp(65,posY))
		    	bgSprite:addChild(tipNode2)
		    	posY = posY - 60
			end
			if( not table.isEmpty(_rewardTab.terminal_conti_reward) and tonumber(p_curTerminalContiNum) > 1 )then
				tipNode3 = WorldArenaMainLayer.getRewardDesTip( _rewardTab.terminal_conti_reward, GetLocalizeStringBy("lic_1622") ,500,1 )
				tipNode3:setAnchorPoint(ccp(0,0))
		    	tipNode3:setPosition(ccp(65,posY))
		    	bgSprite:addChild(tipNode3)
			end

	    end

	else
	 
	    -- 失败特效
	    local failSprite1 = XMLSprite:create("images/battle/xml/report/zhandoushibai")
	    failSprite1:setAnchorPoint(ccp(0.5,0.5))
	    failSprite1:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-20))
	    bgSprite:addChild(failSprite1)
	    failSprite1:setReplayTimes(1)

	    -- 很遗憾您失败了
	    local tipFont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1619") , g_sFontPangWa, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    tipFont1:setAnchorPoint(ccp(0.5,1))
	    tipFont1:setColor(ccc3(0xff, 0xf6, 0x00))
	    tipFont1:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-50))
	    bgSprite:addChild(tipFont1)

	    if( not table.isEmpty(_rewardTab) )then
	    	local tipNode1 = nil
	    	local posY = bgSprite:getContentSize().height - 130
	    	if( not table.isEmpty(_rewardTab.lose_reward) )then
				tipNode1 = WorldArenaMainLayer.getRewardDesTip( _rewardTab.lose_reward, GetLocalizeStringBy("lic_1620") ,500,1 )
				tipNode1:setAnchorPoint(ccp(0,0))
		    	tipNode1:setPosition(ccp(65,posY))
		    	bgSprite:addChild(tipNode1)
			end
	    end

	end

    -- 音效
    bgSprite:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
        	require "script/audio/AudioUtil"
        	if( _isWin )then
            	AudioUtil.playEffect("audio/effect/zhandoushengli.mp3")
            else
            	AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")
            end
        end
    end)

	return _bgLayer
end








































