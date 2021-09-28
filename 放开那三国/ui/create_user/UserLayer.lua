-- Filename： UserLayer.lua
-- Author：		zhz
-- Date：		2013-9-2
-- Purpose：		创建用户

module("UserLayer",  package.seeall)

require "script/network/RequestCenter"
require "script/ui/tip/AnimationTip"
require "script/libs/LuaCCLabel"
require "script/ui/create_user/SelectUserLayer"

local IMG_PATH = "images/new_user/"

local _newUserLayer 			-- 新用户的layer
local _newUserBg 					-- 背景
local _boyBtn 					-- 男主的按钮
local _girlBtn					-- 女主的按钮
local _boySpriteItem				-- 男主的图片
local _girlSpriteItem				-- 女主的图片
local _ksUserSpriteTag
local _curShowUser				-- 当前显示的主角 1： 女主，2：男主
local _curUserSprite 			-- 当前显示主角的sprite
local _nextUserSprite 			-- 另外一个主角的sprite
local _boyBtnTag  				-- 男主按钮的Tag值
local _girlBtnTag 				-- 女主按钮的Tag值
local _user_ZOrder  
local _max_user_ZOrder			-- 最大的Z轴
local _touchBeganPoint			-- 开始的位置
local _userStage				-- 站台
local function init()
	_newUserLayer = nil
	_newUserBg = nil
	_boyBtn = nil
	_girlBtn = nil
	_curShowUser = 2
	_curUserSprite = nil
	_nextUserSprite = nil
	_boyBtnTag = 101
	_girlBtnTag = 102
	_ksUserSpriteTag = 999
	release = nil
	_boySpriteItem = nil
	_girlSpriteItem = nil
	_userStage= nil
end

-- 释放
local function  release()
	_newUserLayer:removeFromParentAndCleanup(true)
	_newUserLayer = nil
end


-- 下一步的回调函数，点击男主或是女主的图片与点击下一步产生的效果一样
local function userSelectCb( tag, item )
	release()
	SelectUserLayer.createSelectLayer(_curShowUser)
end

local function animatedEndAction( )
	_girlSpriteItem:setColor(ccc3(255,255,255))
	_newUserLayer:reorderChild(_boySpriteItem ,110)
	_newUserLayer:reorderChild(_girlSpriteItem,111)
end
local function animatedEndAction1(  )
	_boySpriteItem:setColor(ccc3(255,255,255))
	_newUserLayer:reorderChild(_girlSpriteItem ,110)
	_newUserLayer:reorderChild(_boySpriteItem,111)
end

-- 已到后面变灰
local function actionCurCb( )
	_boySpriteItem:setColor(ccc3(0xcd,0xc9,0xc9))
end

local function actionCurCb1( )
	_girlSpriteItem:setColor(ccc3(0xcd,0xc9,0xc9))
end

-- 女主 精灵,_curShowUser =2 时为男主，1 时为女主
local function switchUser( )

	local curMoveToP --= ccps(0.6, 331/960)
	local nextMoveToP --= ccps(0.2, 600/960)

	--_curUserSprite:runAction(CCMoveTo:create(0.1, nextMoveToP))
	if(_curShowUser == 2) then
		curMoveToP = ccps(0.2,600/960)
		nextMoveToP = ccps(0.52 ,331/960)
		local actionCur = CCArray:create()
		actionCur:addObject(CCMoveTo:create(0.10, curMoveToP))
		local scale = _boySpriteItem:getScale()
		actionCur:addObject(CCScaleTo:create(0.10,0.63*scale))
		actionCur:addObject(CCCallFuncN:create(actionCurCb))
		_boySpriteItem:runAction(CCSpawn:create(actionCur))

		local actionArr = CCArray:create()
		actionArr:addObject(CCMoveTo:create(0.10, nextMoveToP))
		local scale = _girlSpriteItem:getScale()
		actionArr:addObject(CCScaleTo:create(0.10,1/0.63*scale))
		actionArr:addObject(CCCallFuncN:create(animatedEndAction))
		_girlSpriteItem:runAction(CCSpawn:create(actionArr))
		-- 按钮更换
		_girlBtn:selected()
		_boyBtn:unselected()
		_curShowUser =1
	elseif(_curShowUser == 1) then
		curMoveToP = ccps(0.3,600/960)
		nextMoveToP = ccps(0.408,331/960)
		local actionCur = CCArray:create()
		actionCur:addObject(CCMoveTo:create(0.1, curMoveToP))
		local scale = _girlSpriteItem:getScale()
		actionCur:addObject(CCScaleTo:create(0.1,0.63*scale))
		actionCur:addObject(CCCallFuncN:create(actionCurCb1))
		_girlSpriteItem:runAction(CCSpawn:create(actionCur))

		local actionArr = CCArray:create()
		actionArr:addObject(CCMoveTo:create(0.1, nextMoveToP))
		local scale = _boySpriteItem:getScale()
		actionArr:addObject(CCScaleTo:create(0.1,1/0.63*scale))
		actionArr:addObject(CCCallFuncN:create(animatedEndAction1))
		_boySpriteItem:runAction(CCSpawn:create(actionArr))
		-- 按钮更换
		_girlBtn:unselected()
		_boyBtn:selected()

		_curShowUser =2
	end
	
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )

	if (eventType == "began") then	
		_touchBeganPoint = ccp(x, y)
		
		if( _touchBeganPoint.x>0 and _touchBeganPoint.y>_userStage:getContentSize().height*_userStage:getScale()+_userStage:getPositionY() ) then --and vPosition.x < _curUserSprite:getContentSize().width and vPosition.y < _curUserSprite:getContentSize().height ) then
			print("began true")
		    return true
		else
		return false
		end
		return true
    elseif(eventType == "moved") then
    	
    else
    	print("end")
    	local xOffset = x- _touchBeganPoint.x;
    	if(math.abs(xOffset)> 10 ) then
    		switchUser()
    	elseif(math.abs(xOffset)<10) then
    		release()
			SelectUserLayer.createSelectLayer(_curShowUser)

    	end


	end
end


local function createUserSprite( )

	_boySpriteItem = CCSprite:create(IMG_PATH .. "boy.png")
	setAdaptNode(_boySpriteItem)
	_boySpriteItem:setPosition(ccps(0.408, 331/960))
	_boySpriteItem:setAnchorPoint(ccp(0.5,0))
	--_boySpriteItem:registerScriptTapHandler(userSelectCb)
	_newUserLayer:addChild(_boySpriteItem,10)
	-- 女主的图片
	_girlSpriteItem = CCSprite:create(IMG_PATH .. "girl.png" )
	_girlSpriteItem:setPosition(ccps(0.28, 600/960))
	setAdaptNode(_girlSpriteItem)
	_girlSpriteItem:setAnchorPoint(ccp(0.5,0))
	_girlSpriteItem:setColor(ccc3(0xcd,0xc9,0xc9))
	--_girlSpriteItem:registerScriptTapHandler(userSelectCb)
	local scale = _girlSpriteItem:getScale()
	_girlSpriteItem:setScale(0.63*scale)
	_newUserLayer:addChild(_girlSpriteItem)

	--_boyBtn:isSelected()

end


local function boyBtnCb( tag, item )
	_girlBtn:unselected()
	_boyBtn:selected()
	if(_curShowUser == 2) then
		return
	end
	switchUser()

end

local function girlBtnCb( tag, item )
	_girlBtn:selected()
	_boyBtn:unselected()
	if(_curShowUser == 1) then
		return
	end
	switchUser()
end
--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_newUserLayer:registerScriptTouchHandler(onTouchesHandler, false, -127, true)
		_newUserLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_newUserLayer:unregisterScriptTouchHandler()
	end
end


 -- 创建选择角色的layer
function createUserLayer( )
	init()
	_newUserLayer = CCLayer:create()
	_newUserLayer:registerScriptHandler(onNodeEvent)

	-- 背景
	_newUserBg = CCSprite:create(IMG_PATH .. "user_bg.jpg")
	_newUserBg:setPosition(ccps(0.5,0.5))
	_newUserBg:setAnchorPoint(ccp(0.5,0.5))
	_newUserLayer:addChild(_newUserBg)
	setAllScreenNode(_newUserBg)

	-- sprite 选择角色
	local selectSprite = CCSprite:create(IMG_PATH .. "user_select.png")
	selectSprite:setPosition(ccps(0.5,840/960))
	selectSprite:setAnchorPoint(ccp(0.5,0))
	_newUserLayer:addChild(selectSprite,200)
	setAdaptNode(selectSprite)

	-- vip 继承提示
	local hasVip, vipLv = UserHandler.hasVip()
	if( hasVip==true and vipLv>0)then
		require "script/model/utils/UserUtil"
		local vipTipSprite = UserUtil.getVipTipSpriteByVipNum( vipLv )
	    vipTipSprite:setAnchorPoint(ccp(0.5,0.5))
	    vipTipSprite:setPosition(_newUserLayer:getContentSize().width*0.5, _newUserLayer:getContentSize().height*0.85)
	    _newUserLayer:addChild(vipTipSprite,200)
	    vipTipSprite:setScale(g_fElementScaleRatio)
	end

	-- 站台
	_userStage = CCSprite:create(IMG_PATH .. "stage.png")
	_userStage:setPosition(ccps(0.5,240/960))
	_userStage:setAnchorPoint(ccp(0.5,0))
	setAdaptNode(_userStage)
	_newUserLayer:addChild(_userStage)


	-- -- 选择男主，女主 按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	--setAdaptNode(menu)
	_newUserLayer:addChild(menu)

	_boyBtn = CCMenuItemImage:create(IMG_PATH .. "boy_btn/boy_h.png", IMG_PATH .. "boy_btn/boy_n.png")
	_boyBtn:setPosition(ccps(0.25,167/960))
	_boyBtn:setAnchorPoint(ccp(0.5,0))
	setAdaptNode(_boyBtn)
	_boyBtn:registerScriptTapHandler(boyBtnCb)
	_boyBtn:selected()
	menu:addChild(_boyBtn,0,_boyBtnTag)
	local boyLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1412"), g_sFontName, 24)
	boyLabel:setPosition(ccps(0.25,136/960))
	setAdaptNode(boyLabel)
	boyLabel:setAnchorPoint(ccp(0.5,0))
	boyLabel:setColor(ccc3(0xff,0xff,0xff))

	_newUserLayer:addChild(boyLabel)

	_girlBtn = CCMenuItemImage:create(IMG_PATH .. "girl_btn/girl_h.png" , IMG_PATH .. "girl_btn/girl_n.png")
	_girlBtn:setPosition(ccps(0.75,167/960))
	_girlBtn:setAnchorPoint(ccp(0.5,0))
	setAdaptNode(_girlBtn)
	_girlBtn:registerScriptTapHandler(girlBtnCb)
	menu:addChild(_girlBtn,0,_girlBtnTag)
	local girlLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2870"), g_sFontName, 24)
	girlLabel:setPosition(ccps(0.75,136/960))
	girlLabel:setAnchorPoint(ccp(0.5,0))
	setAdaptNode(girlLabel)
	girlLabel:setColor(ccc3(0xff,0xff,0xff))
	_newUserLayer:addChild(girlLabel)

	-- 下一步按钮
	local nextStepBtn = CCMenuItemImage:create(IMG_PATH .. "next_btn/next_n.png" , IMG_PATH .. "next_btn/next_h.png")
	nextStepBtn:setPosition(ccps(0.5,41/960))
	nextStepBtn:setAnchorPoint(ccp(0.5,0))
	setAdaptNode(nextStepBtn)
	nextStepBtn:registerScriptTapHandler(userSelectCb)
	menu:addChild(nextStepBtn)

	createUserSprite()

	return _newUserLayer
end




