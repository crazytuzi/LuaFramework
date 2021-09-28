-- Filename：	StarTriger.lua
-- Author：		Cheng Liang
-- Date：		2013-8-14
-- Purpose：		答题

module ("StarTriger", package.seeall)

require "script/network/RequestCenter"


require "script/utils/LuaUtil"
require "script/ui/main/MainScene"

require "script/ui/star/StarUtil"
require "script/libs/LuaCCLabel"

require "script/ui/tip/AnimationTip"



local Star_Img_Path = "images/star/intimate/"


local _curStarId 	= nil	-- 当前的star_id
local _curTrigerId	= nil	-- 答题id
local _callbackFunc = nil	-- 答题完了回调

local _curAnswer 	= nil

local _bgLayer 		= nil
-----------------------

local function init()
	_bgLayer 		= nil
	_curStarId 		= nil	-- 当前的star_id
	_curTrigerId	= nil	-- 答题id
	_callbackFunc 	= nil	-- 答题完了回调
	_curAnswer 		= nil
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		return true
    elseif (eventType == "moved") then
	
    else
    	
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -151, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end


-- 关闭
function closeAction( tag, itembtn )
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end 

local function trigerCallback( cbFlag, dictData, bRet )
	if(dictData.err=="ok") then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
		
		require "db/DB_Star_triger"
		local trigerData = DB_Star_triger.getDataById(tonumber(_curTrigerId))


		local rewardArr = string.split( trigerData["reward" .. _curAnswer], "," )
		local prizeType = tonumber(rewardArr[1])
		local prizeNum = tonumber(rewardArr[2])

		if(rewardArr[3] == "1") then
			prizeNum = prizeNum * UserModel.getHeroLevel()
		end

		local text = ""
		if( prizeType == 1) then
			UserModel.changeSilverNumber(prizeNum)
			text = GetLocalizeStringBy("key_1687")
		elseif( prizeType == 2) then
			UserModel.changeGoldNumber(prizeNum)
			text = GetLocalizeStringBy("key_1491")
		elseif( prizeType == 3) then
			UserModel.addSoulNum(prizeNum)
			text = GetLocalizeStringBy("key_1616")
		elseif( prizeType == 4) then
			UserModel.changeStaminaNumber(prizeNum)
			text = GetLocalizeStringBy("key_2021")
		elseif( prizeType == 5) then
			UserModel.changeEnergyValue(prizeNum)
			text = GetLocalizeStringBy("key_1032")
		elseif( prizeType == 6) then
			DataCache.addExpToStar( _allStarInfoArr[_curStarIndex].star_id, prizeNum)
			text = GetLocalizeStringBy("key_1628")
		elseif( prizeType == 7) then
			UserModel.addExpValue(prizeNum,"startriger")
			text = GetLocalizeStringBy("key_1907")
		end
		
		if (_callbackFunc) then
			text = text .. GetLocalizeStringBy("key_2784")  .. prizeNum
			-- _callbackFunc(text)
			AnimationTip.showTip(text)
		end
	end
end 

-- 答题
function trigerAction( tag, itembtn )
	_curAnswer = tag-90000
	local args = Network.argsHandler(_curStarId, _curTrigerId, _curAnswer)
	RequestCenter.star_answer(trigerCallback, args)
end

-- 创建
local function createUI()
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local _bgSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
	_bgSprite:setPreferredSize(CCSizeMake(470, 430))
	_bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.45))
	_bgLayer:addChild(_bgSprite)	

	-- 标题
	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_bgSprite:getContentSize().width/2, _bgSprite:getContentSize().height*0.988))
	_bgSprite:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2540"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	_bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-152)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.98, _bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

---- 数据
	require "db/DB_Star_triger"
	local trigerData = DB_Star_triger.getDataById(tonumber(_curTrigerId))
	

	-- 描述
	local descLabel = CCLabelTTF:create(trigerData.description1, g_sFontName, 23, CCSizeMake(390, 160), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0.5, 1))
	descLabel:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height *0.85))
	_bgSprite:addChild(descLabel)

---- 按钮sprite
	local fullRect_1 = CCRectMake(0,0,56,56)
	local insetRect_1 = CCRectMake(20,20,16,16)

	local optionMenuBar = CCMenu:create()
	optionMenuBar:setPosition(ccp(0,0))
	optionMenuBar:setTouchPriority(-152)
	_bgSprite:addChild(optionMenuBar)

---- 选项按钮1
	local btnSprite_1_n = CCScale9Sprite:create("images/star/triger/triger9s_n.png", fullRect_1, insetRect_1)
	btnSprite_1_n:setPreferredSize(CCSizeMake(385, 56))
	local btnSprite_1_h= CCScale9Sprite:create("images/star/triger/triger9s_h.png", fullRect_1, insetRect_1)
	btnSprite_1_h:setPreferredSize(CCSizeMake(385, 56))
	
	local option_1 = CCMenuItemSprite:create(btnSprite_1_n, btnSprite_1_h)
	option_1:setAnchorPoint(ccp(0.5, 1))
	option_1:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height*0.5))
	option_1:registerScriptTapHandler(trigerAction)
	optionMenuBar:addChild(option_1,2,90001)

	local descLabel = CCLabelTTF:create( "A." .. trigerData.option1, g_sFontName, 23)
	descLabel:setColor(ccc3(0xff, 0xff, 0xff))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(10, option_1:getContentSize().height *0.5))
	option_1:addChild(descLabel)

---- 选项按钮1
	local btnSprite_2_n = CCScale9Sprite:create("images/star/triger/triger9s_n.png", fullRect_1, insetRect_1)
	btnSprite_2_n:setPreferredSize(CCSizeMake(385, 56))
	local btnSprite_2_h= CCScale9Sprite:create("images/star/triger/triger9s_h.png", fullRect_1, insetRect_1)
	btnSprite_2_h:setPreferredSize(CCSizeMake(385, 56))
	
	local option_2 = CCMenuItemSprite:create(btnSprite_2_n, btnSprite_2_h)
	option_2:setAnchorPoint(ccp(0.5, 1))
	option_2:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height*0.3))
	option_2:registerScriptTapHandler(trigerAction)
	optionMenuBar:addChild(option_2,2,90002)

	local descLabel_2 = CCLabelTTF:create( "B." .. trigerData.option2, g_sFontName, 23)
	descLabel_2:setColor(ccc3(0xff, 0xff, 0xff))
	descLabel_2:setAnchorPoint(ccp(0, 0.5))
	descLabel_2:setPosition(ccp(10, option_1:getContentSize().height *0.5))
	option_2:addChild(descLabel_2)

end

---- 默认的starId
function createLayer(star_id, triger_id, callbackFunc)
	init()

	_curStarId = star_id
	_curTrigerId = triger_id
	_callbackFunc = callbackFunc
	_bgLayer = CCLayer:create()
	
	_bgLayer:registerScriptHandler(onNodeEvent)
	createUI()
	
	return _bgLayer
end

