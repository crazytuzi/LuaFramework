-- FileName: TopGoldSilver.lua 
-- Author: licong 
-- Date: 16/2/1 
-- Purpose: 战斗力 金币 银币 标题栏 


module("TopGoldSilver", package.seeall)

local _bgSprite 							= nil
local _powerLabel 							= nil
local _silverLabel 							= nil
local _goldLabel 							= nil

--[[
	@des 	: init
	@param 	: 
	@return :
--]]
function init( ... )
	_bgSprite 								= nil
	_powerLabel 							= nil
	_silverLabel 							= nil
	_goldLabel 								= nil
end

--[[
    @des    :回调onEnter和onExit事件
    @param  :
    @return :
--]]
function onNodeEvent( event )
    if (event == "enter") then
    elseif (event == "exit") then
    end
end

--[[
	@des 	: 创建sprite
	@param 	: 
	@return :
--]]
function create( ... )
	-- 初始化
	init()

	-- 背景
	_bgSprite = CCSprite:create("images/hero/avatar_attr_bg.png")
    _bgSprite:registerScriptHandler(onNodeEvent) 

	-- 战斗力
    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_bgSprite:getContentSize().width*0.13,_bgSprite:getContentSize().height*0.43)
    _bgSprite:addChild(powerDescLabel)

    _powerLabel = CCRenderLabel:create(UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerLabel:setAnchorPoint(ccp(0,0.5))
    _powerLabel:setPosition(_bgSprite:getContentSize().width*0.23,_bgSprite:getContentSize().height*0.47)
    _bgSprite:addChild(_powerLabel)

    -- 银币
    _silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,18) 
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(_bgSprite:getContentSize().width*0.61,_bgSprite:getContentSize().height*0.43)
    _bgSprite:addChild(_silverLabel)

    -- 金币
    _goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(),g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(_bgSprite:getContentSize().width*0.82,_bgSprite:getContentSize().height*0.43)
    _bgSprite:addChild(_goldLabel)

    return _bgSprite
end


--[[
    @des    : 刷新金币方法
    @param  : 
    @return :
--]]
function refreshGoldCallback()
    if tolua.isnull(_goldLabel) then
        return
    end
    _goldLabel:setString(UserModel.getGoldNumber())
end

--[[
    @des    : 刷新银币方法
    @param  : 
    @return :
--]]
function refreshSilverCallback()
    if tolua.isnull(_silverLabel) then
        return
    end
    _silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
end



