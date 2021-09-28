-- FileName: SoulRebornLayer.lua 
-- Author: licong 
-- Date: 15/9/24 
-- Purpose: 战魂重生界面


module("SoulRebornLayer", package.seeall)

require "script/ui/rechargeActive/soulReborn/SoulRebornController"

local _bgLayer 							= nil
local _addSp  							= nil
local _rebornFontNum  					= nil
local _topHeight 						= nil
local _bottomHeight 					= nil
local _chooseItemSp 					= nil
local _maskLayer 						= nil

local _lastItemId 						= nil
local _chooseItemId 					= nil
local _choosItemTid 					= nil
local _subRebornNum 					= nil

local _touchPriority 					= -410

--[[
	@des 	:初始化
--]]
function init( ... )
	_bgLayer 							= nil
	_addSp  							= nil
	_rebornFontNum  					= nil
	_topHeight 							= nil
	_bottomHeight 						= nil
	_chooseItemSp 						= nil
	_maskLayer 							= nil

	_lastItemId 						= nil
	_chooseItemId 						= nil
	_choosItemTid 						= nil
	_subRebornNum 						= nil

end

--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
	elseif (event == "exit") then
	end
end

--[[
	@des 	:活动说明按钮回调
	@param 	:
	@return :
--]]
function explainMenuItemCallFunc( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/ui/rechargeActive/soulReborn/ExplainDialogLayer"
    ExplainDialogLayer.showLayer( _touchPriority-30, 1010, GetLocalizeStringBy("key_2934"), GetLocalizeStringBy("lic_1702") )
end

--[[
	@des 	:加号按钮回调
	@param 	:
	@return :
--]]
function addMenuItemAction( tag, itemBtn )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local addCallBack = function ( ... )
    	_chooseItemId = SoulRebornData.getChooseItemId()
    	print("_chooseItemId==>",_lastItemId,_chooseItemId)
    	if( _lastItemId == nil or tonumber(_lastItemId) ~= _chooseItemId )then
    		refreshChooseSoulUI()
    	end
    end

    require "script/ui/rechargeActive/soulReborn/ChooseSoulLayer"
    ChooseSoulLayer.showSelectLayer( addCallBack, _touchPriority-30, 1010 ) 

end

--[[
	@des 	:重生按钮回调
	@param 	:
	@return :
--]]
function rebornMenuItemCallBack( tag, itemBtn )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local nextCallBack = function ( p_retData, p_subNum )
    	-- 隐藏加号
    	_addSp:setVisible(false)
    	if(not tolua.isnull(_chooseItemSp))then
			_chooseItemSp:removeFromParentAndCleanup(true)
			_chooseItemSp = nil
		end

    	AudioUtil.playEffect("audio/effect/chongshen.mp3")
		--炉子特效
		local stoveAnimation = XMLSprite:create("images/base/effect/recycle/chongsheng")
		stoveAnimation:setReplayTimes(1)
		stoveAnimation:setScale(g_fElementScaleRatio)
		stoveAnimation:setPosition(g_winSize.width*0.5,g_winSize.height*0.5 + 110*g_fScaleY)
		_bgLayer:addChild(stoveAnimation)
		local endCallBack = function ( ... )
			-- 干掉屏蔽层
			if(_maskLayer ~= nil)then
				_maskLayer:removeFromParentAndCleanup(true)
				_maskLayer = nil
			end

			-- 弹奖励
			require "script/ui/rechargeActive/soulReborn/SoulRewardLayer"
			SoulRewardLayer.showTip( p_retData, _touchPriority-30, 1010 )

			-- 显示加号刷新选择战魂
			_chooseItemId = nil
			refreshChooseSoulUI()
			_addSp:setVisible(true)

			-- 刷新次数
		    _subRebornNum = p_subNum
		    _rebornFontNum:setString(_subRebornNum)
		end
		stoveAnimation:registerEndCallback(endCallBack)
		--法轮大法特效
		local wheelAnimation = XMLSprite:create("images/base/effect/recycle/fazhen")
		wheelAnimation:setReplayTimes(1)
		wheelAnimation:setScale(g_fElementScaleRatio)
		wheelAnimation:setPosition(g_winSize.width*0.5,g_winSize.height*0.5 - 90*g_fScaleY)
		_bgLayer:addChild(wheelAnimation)
    end

    local maskLayerCallBack = function ( ... )
		-- 添加特效屏蔽层
	    if(_maskLayer ~= nil)then
			_maskLayer:removeFromParentAndCleanup(true)
			_maskLayer = nil
		end
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		_maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
		runningScene:addChild(_maskLayer, 10000)
	end
    SoulRebornController.rebornCallback( _chooseItemId, _choosItemTid, nextCallBack, p_maskLayerCallBack )
end

--[[
	@des 	: 刷新选择的战魂
	@param 	: 
	@return : 
--]]
function refreshChooseSoulUI( ... )

	if( _chooseItemId == nil )then 
		if(not tolua.isnull(_chooseItemSp))then
			_chooseItemSp:removeFromParentAndCleanup(true)
			_chooseItemSp = nil
		end
		return
	end
	
	if(not tolua.isnull(_chooseItemSp))then
		_chooseItemSp:removeFromParentAndCleanup(true)
		_chooseItemSp = nil
	end
	local choosItemData = ItemUtil.getItemByItemId(_chooseItemId)
	_choosItemTid = choosItemData.item_template_id
	_chooseItemSp = ItemSprite.getItemSpriteByItemId(choosItemData.item_template_id,choosItemData.va_item_text.fsLevel,true)
	_chooseItemSp:setAnchorPoint(ccp(0.5, 0.5))
	_chooseItemSp:setPosition(ccp(_addSp:getContentSize().width*0.5, _addSp:getContentSize().height*0.5))
	_addSp:addChild(_chooseItemSp,10,110)
	-- 选择物品名字
    local nameColor = HeroPublicLua.getCCColorByStarLevel(choosItemData.itemDesc.quality)
	local chooseItemName = CCRenderLabel:create(choosItemData.itemDesc.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	chooseItemName:setColor(nameColor)
	chooseItemName:setAnchorPoint(ccp(0.5,1))
	chooseItemName:setPosition(ccp(_chooseItemSp:getContentSize().width*0.5 ,0))
	_chooseItemSp:addChild(chooseItemName)
end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createUI( ... )
	require "script/ui/main/BulletinLayer"
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	_topHeight = RechargeActiveMain.getBgWidth()+bulletinLayerSize.height*g_fScaleX
	_bottomHeight = MenuLayer.getHeight()

	-- 标题
	local titleSp = CCSprite:create("images/recharge/soulReborn/title.png")
	titleSp:setAnchorPoint(ccp(0.5,1))
	titleSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-_topHeight))
	_bgLayer:addChild(titleSp,10)
	titleSp:setScale(g_fElementScaleRatio)

	-- 说明文字
	local tipSp = CCSprite:create("images/recharge/soulReborn/tip.png")
	tipSp:setAnchorPoint(ccp(0.5,1))
	tipSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,titleSp:getPositionY()-(titleSp:getContentSize().height+10)*g_fElementScaleRatio ))
	_bgLayer:addChild(tipSp,10)
	tipSp:setScale(g_fElementScaleRatio)

	-- 炉子
	local luSprite = CCSprite:create("images/recycle/owen.png")
	luSprite:setAnchorPoint(ccp(0.5,0.5))
	luSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(luSprite)
	luSprite:setScale(g_fElementScaleRatio)

	-- 炉子上按钮
	local luMenu = CCMenu:create()
	luMenu:setPosition(0,0)
	luSprite:addChild(luMenu)
	luMenu:setTouchPriority(_touchPriority-2)
	local sprite1 = CCSprite:create()
	sprite1:setContentSize(CCSizeMake(90,93))
	local sprite2 = CCSprite:create()
	sprite2:setContentSize(CCSizeMake(90,93))
	local addMenuItem = CCMenuItemSprite:create(sprite1,sprite2)
	addMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	addMenuItem:setPosition(ccp(luSprite:getContentSize().width*0.5, luSprite:getContentSize().height*0.7))
	luMenu:addChild(addMenuItem)
	-- 注册回调
	addMenuItem:registerScriptTapHandler(addMenuItemAction)
	-- 加号
	_addSp = ItemSprite.createAddSprite()
	_addSp:setAnchorPoint(ccp(0.5,0.5))
	_addSp:setPosition(ccp(addMenuItem:getContentSize().width*0.5,addMenuItem:getContentSize().height*0.5))
	addMenuItem:addChild(_addSp,5)

	-- 按钮
	local menu = CCMenu:create()
	menu:setPosition(0,0)
	_bgLayer:addChild(menu)
	menu:setTouchPriority(_touchPriority-2) 

	-- 创建重生按钮 
	local rebornMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(190, 73), GetLocalizeStringBy("lic_1657"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	rebornMenuItem:setAnchorPoint(ccp(0.5, 0))
	rebornMenuItem:setPosition(ccp( _bgLayer:getContentSize().width*0.5, _bottomHeight+110*g_fElementScaleRatio ))
	menu:addChild(rebornMenuItem)
	rebornMenuItem:registerScriptTapHandler(rebornMenuItemCallBack)
	rebornMenuItem:setScale(g_fElementScaleRatio)

	--活动说明
	local explainMenuItem = CCMenuItemImage:create("images/recycle/btn/btn_explanation_h.png", "images/recycle/btn/btn_explanation_n.png")
	explainMenuItem:setAnchorPoint(ccp(0, 1))
	explainMenuItem:setPosition(ccp(20,titleSp:getPositionY()-10*g_fElementScaleRatio ))
	menu:addChild(explainMenuItem)
	explainMenuItem:registerScriptTapHandler(explainMenuItemCallFunc)
	explainMenuItem:setScale(g_fElementScaleRatio)

	-- 剩余重生次数
   	local rebornFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1658"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    rebornFont:setColor(ccc3(0xff, 0xff, 0xff))
    rebornFont:setAnchorPoint(ccp(0.5,0))
    rebornFont:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bottomHeight+90*g_fElementScaleRatio))
    _bgLayer:addChild(rebornFont,10)
    rebornFont:setScale(g_fElementScaleRatio)

    local allNum = SoulRebornData.getRebornAllNum()
    local haveUseNum = SoulRebornData.getHaveRebornNum()
    _subRebornNum = allNum - haveUseNum
    _rebornFontNum = CCRenderLabel:create(_subRebornNum, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _rebornFontNum:setColor(ccc3(0x00, 0xff, 0x18))
    _rebornFontNum:setAnchorPoint(ccp(0,0.5))
    _rebornFontNum:setPosition(ccp(rebornFont:getContentSize().width-8,rebornFont:getContentSize().height*0.5))
    rebornFont:addChild(_rebornFontNum,10)

    -- 提示
    local font1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1659"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font1:setColor(ccc3(0x00, 0xff, 0x18))
    font1:setAnchorPoint(ccp(0.5,0))
    font1:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bottomHeight+50*g_fElementScaleRatio))
    _bgLayer:addChild(font1,10)
    font1:setScale(g_fElementScaleRatio)

    -- 活动时间
    local timeFont = CCRenderLabel:create( GetLocalizeStringBy("key_2707"), g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    timeFont:setColor(ccc3(0x00,0xff,0x18))
    timeFont:setAnchorPoint(ccp(0,0.5))
    timeFont:setPosition(ccp(45*g_fElementScaleRatio,_bottomHeight+30*g_fElementScaleRatio))
    _bgLayer:addChild(timeFont)
    timeFont:setScale(g_fElementScaleRatio)
    -- 开始时间 --- 结束时间
    -- 开始时间
    local startTime = SoulRebornData.getRebornStartTime()
    local startTimeStr = TimeUtil.getTimeToMin( tonumber(startTime) ) or " "
    -- 结束时间
    local endTime = SoulRebornData.getRebornEndTime()
    local endTimeStr = TimeUtil.getTimeToMin( tonumber(endTime) ) or " "
    local timeStr = startTimeStr .. " —— " ..  endTimeStr
    -- local timeStr = "2015-08-08 00:00:00 -- 2015-08-09 00:00:00"
    local timeStr_font = CCRenderLabel:create( timeStr, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    timeStr_font:setColor(ccc3(0x00,0xff,0x18))
    timeStr_font:setAnchorPoint(ccp(0,0.5))
    timeStr_font:setPosition(ccp(timeFont:getPositionX()+timeFont:getContentSize().width*g_fElementScaleRatio+20*g_fElementScaleRatio,timeFont:getPositionY()))
    _bgLayer:addChild(timeStr_font)
    timeStr_font:setScale(g_fElementScaleRatio)

end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer( ... )
	-- 初始化
	init()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 大背景
    _bgSprite = CCSprite:create("images/recycle/recyclebg.png")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

   local nextCallBack = function ( p_retData )
   		-- 设置已经重生次数
   		SoulRebornData.setHaveRebornNum( p_retData.num )
   		-- 清空上次选择的
   		SoulRebornData.cleanSelectList()
   	 	-- 创建UI
    	createUI()
    end
   	SoulRebornService.getInfo( nextCallBack )

	return _bgLayer
end