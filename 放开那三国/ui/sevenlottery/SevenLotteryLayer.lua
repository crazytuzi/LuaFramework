-- Filename：	SevenLotteryLayer.lua
-- Author：		LLP
-- Date：		2016-8-3
-- Purpose：		七星潭


module("SevenLotteryLayer", package.seeall)

require "script/ui/sevenlottery/SevenLotteryController"

local _totalData 	 = nil
local _lastTimeLabel = nil
local _buyFreeLabel  = nil
local _bottomNode  	 = nil
local _getRewardNode = nil
local _callStarMenu  = nil
local _beforeValue   = 0
local _typeNum 		 = 0
local _mainBgTag 	 = 1 
local _topSpriteBgTag = 2
local _bodyMenuAndItemTag = 3
local _passNameBgTag = 4
local _bgProressTag  = 5
local _nextRewardLabelTag = 6
local _timeLabelTag 	  = 7
local _clockSpTag 		  = 8
local _kuangSpTag 		  = 9
local _touch_priority     = -500
local _canClick      = true
--初始化
function init( ... )
	_canClick      = true
	_beforeValue   = 0
	_typeNum 		 = 0
	_buyFreeLabel  = nil
	_totalData 		= nil
	_lastTimeLabel  = nil
	_bottomNode  	= nil
	_getRewardNode  = nil
	_callStarMenu   = nil
end

--layer进入退出
function onNodeEvent(event)
	if (event == "enter") then
		_mainLayer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _mainLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_mainLayer:unregisterScriptTouchHandler()
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	end
end
--layer触摸事件
function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		return false
	end
end

-----------------------------------------------命令相关BEGIN-----------------------------------
--发送enter命令
function sendCommond( ... )
	-- body
	SevenLotteryController.getInfo(createLayer)
end

function createTimeLabel( ... )
	-- body
	if(_mainLayer:getChildByTag(_timeLabelTag))then
		_mainLayer:removeChildByTag(_timeLabelTag,true)
	end
	if(_mainLayer:getChildByTag(_clockSpTag))then
		_mainLayer:removeChildByTag(_clockSpTag,true)
	end
	local str = _totalData.period_end
	require "script/utils/TimeUtil"
	local timeLabel = CCLabelTTF:create(TimeUtil.getRemainTimeHMS(str),g_sFontPangWa,21)
		  timeLabel:setScale(g_fElementScaleRatio)
		  timeLabel:setAnchorPoint(ccp(1,1))
		  timeLabel:setPosition(ccp(_mainLayer:getContentSize().width*0.45,_mainLayer:getContentSize().height*0.8))
		  timeLabel:setColor(ccc3(0x00,0xff,0x18))
	_mainLayer:addChild(timeLabel,2,_timeLabelTag)
	local actions1 = CCArray:create()
            actions1:addObject(CCDelayTime:create(1))
            actions1:addObject(CCCallFunc:create(function ( ... )
            	local timeStr = TimeUtil.getRemainTimeHMS(str)
                timeLabel:setString(timeStr)
                if(timeStr=="00:00:00")then
                	SevenLotteryController.getInfo(refreshFunc)
                	_mainLayer:stopAllActions()
                end
            end))
    local sequence = CCSequence:create(actions1)
    local action = CCRepeatForever:create(sequence)
    _mainLayer:runAction(action)
    local clockSp = CCSprite:create("images/sevenlottery/time.png")
    	  clockSp:setScale(g_fElementScaleRatio)
    	  clockSp:setAnchorPoint(ccp(1,1))
    	  clockSp:setPosition(ccp(_mainLayer:getContentSize().width*0.45 - timeLabel:getContentSize().width*g_fElementScaleRatio-10*g_fElementScaleRatio,_mainLayer:getContentSize().height*0.8))
    _mainLayer:addChild(clockSp,2,_clockSpTag)
end

function createNextRewardLabel( ... )
	if(_mainLayer:getChildByTag(_nextRewardLabelTag))then
		_mainLayer:removeChildByTag(_nextRewardLabelTag,true)
	end
	local nextRewardLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_491"),g_sFontPangWa,21)
		  nextRewardLabel:setColor(ccc3(0xff,0x7a,0x2e))
		  nextRewardLabel:setAnchorPoint(ccp(0,1))
		  nextRewardLabel:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height*0.8))
		  nextRewardLabel:setScale(g_fElementScaleRatio)
	_mainLayer:addChild(nextRewardLabel,2,_nextRewardLabelTag)
	local nameStr = DB_Sevenstar_altar.getDataById(_totalData.next_id).name
	_rewardLabel = CCLabelTTF:create(nameStr,g_sFontPangWa,21)
	_rewardLabel:setAnchorPoint(ccp(0,0))
	_rewardLabel:setPosition(ccp(nextRewardLabel:getContentSize().width,0))
	_rewardLabel:setColor(ccc3(255,0,0))
	nextRewardLabel:addChild(_rewardLabel)
end
--获取copyInfo信息
function getCopyInfoFunc( pInfo )
	_totalData = pInfo
	--创建背景
	createBg()
	--创建上边栏
	createTop()
	--创建中间布局
	createMiddle()
	--创建底部布局
	createBottom()
	createTimeLabel()
	createNextRewardLabel()
	createProgress()
	-- 刷新
	refreshTop()
	refreshBottom()
	MainScene.changeLayer(_mainLayer, "SevenLotteryLayer")
	MainScene.setMainSceneViewsVisible(false,false,false)
end

--刷新
function refreshFunc( pInfo )
	_totalData = pInfo
	-- body
	refreshTop()
	refreshBottom()
	refreshMiddle()
	createNextRewardLabel()
	createProgress()
	createTimeLabel()
end
-----------------------------------------------命令相关END-----------------------------------

-----------------------------------------------上中下布局相关创建BEGIN-----------------------------------
function createBg()
	--背景图片
	local mainBg = CCSprite:create("images/sevenlottery/bg.png" )
	mainBg:setScale(g_fBgScaleRatio)
	mainBg:setAnchorPoint(ccp(0.5,0.5))
	mainBg:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height*0.5))
	_mainLayer:addChild(mainBg,1,_mainBgTag)

	local _xmlSprite = XMLSprite:create("images/redcarddestiny/tainmingliuxing/tainmingliuxing")
    _xmlSprite:setPosition(ccp(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height*0.5))
    mainBg:addChild(_xmlSprite)

	local fazhenAnimation = XMLSprite:create("images/sevenlottery/qixingtai_fazhen_1/qixingtai_fazhen_1")
	fazhenAnimation:setPosition(ccp(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height*0.42))
    mainBg:addChild(fazhenAnimation,1)

    local littleFireAnimation = XMLSprite:create("images/sevenlottery/qixingtai_lizi/qixingtai_lizi")
	littleFireAnimation:setPosition(ccp(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height*0.5))
    mainBg:addChild(littleFireAnimation,3)
end

--返回当前是哪关
function getPassName( ... )
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	return dbData.name
end

--创建上边栏
function createTop( ... )
	local titleSprite = CCSprite:create("images/sevenlottery/title.png")
		  titleSprite:setScale(g_fElementScaleRatio)
		  titleSprite:setAnchorPoint(ccp(0.5,1))
		  titleSprite:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height))
	_mainLayer:addChild(titleSprite,1)

	local _passNameBg = CCScale9Sprite:create("images/common/bg/9s_purple.png")
	_passNameBg:setScale(g_fElementScaleRatio)
    _passNameBg:setContentSize(CCSizeMake(250, 46))
    _passNameBg:setAnchorPoint(ccp(0.5, 0))
    _passNameBg:setPosition(ccp(_mainLayer:getContentSize().width*0.5, _mainLayer:getContentSize().height*0.8+10*g_fElementScaleRatio))

	local str = getPassName()
	--具体关卡名字
	local _passNameLabel = CCRenderLabel:create(str,g_sFontPangWa,30,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_passNameLabel:setColor(ccc3(255,0,0))
	_passNameBg:addChild(_passNameLabel,1,1)
	_passNameLabel:setAnchorPoint(ccp(0.5,0.5))
	_passNameLabel:setPosition(ccp(_passNameBg:getContentSize().width*0.5,_passNameBg:getContentSize().height*0.5))
	
	_mainLayer:addChild(_passNameBg,1,_passNameBgTag)

	--上边Menu
	local clickMenu = CCMenu:create()
	clickMenu:setTouchPriority(_touch_priority-1)
	clickMenu:setAnchorPoint(ccp(0,0))
	clickMenu:setPosition(ccp(0,0))
	_mainLayer:addChild(clickMenu,1)

	--shopItem
	local shopItem = CCMenuItemImage:create("images/sevenlottery/shop1.png", "images/sevenlottery/shop2.png")
	shopItem:setScale(0.95*g_fElementScaleRatio)
	clickMenu:addChild(shopItem,1,1)
	shopItem:setAnchorPoint(ccp(0,1))
	shopItem:registerScriptTapHandler(shopAction)
	shopItem:setPosition(ccp(10*g_fElementScaleRatio,_mainLayer:getContentSize().height-20*g_fElementScaleRatio))

	local preBoxMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
	preBoxMenuItem:setScale(0.95*g_fElementScaleRatio)
	preBoxMenuItem:setAnchorPoint(ccp(0,1))
	preBoxMenuItem:setPosition(ccp(10*g_fElementScaleRatio, shopItem:getPositionY()-shopItem:getContentSize().height*g_fElementScaleRatio-20*g_fElementScaleRatio))
	preBoxMenuItem:registerScriptTapHandler(preAction)
	clickMenu:addChild(preBoxMenuItem)
	-- 返回Item
	_closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	_closeMenuItem:setScale(g_fElementScaleRatio)
	_closeMenuItem:registerScriptTapHandler(backAction)
	clickMenu:addChild(_closeMenuItem)
	_closeMenuItem:setAnchorPoint(ccp(1,1))
	_closeMenuItem:setPosition(ccp(_mainLayer:getContentSize().width-10*g_fElementScaleRatio,_mainLayer:getContentSize().height-20*g_fElementScaleRatio))
end

function getBodyStr( ... )
	-- body
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	local heroBodyStr = dbData.display
	return heroBodyStr
end

--创建中间布局
function createMiddle( ... )
	local middleBg = CCSprite:create("images/sevenlottery/round.png")
		  middleBg:setAnchorPoint(ccp(0.5,0.5))
		  middleBg:setPosition(ccp(_mainLayer:getChildByTag(_mainBgTag):getContentSize().width*0.5,_mainLayer:getChildByTag(_mainBgTag):getContentSize().height*0.55))
	_mainLayer:getChildByTag(_mainBgTag):addChild(middleBg,1,_bodyMenuAndItemTag)

	local upAction = CCMoveTo:create(1.5, ccp(middleBg:getPositionX(),middleBg:getPositionY()+10))
	local downAction = CCMoveTo:create(1.5, ccp(middleBg:getPositionX(),middleBg:getPositionY()-10))
	local actionArray = CCArray:create()
    actionArray:addObject(upAction)
    actionArray:addObject(downAction)
    middleBg:runAction(CCRepeatForever:create(CCSequence:create(actionArray)))

	local heroBodyStr = getBodyStr()
	local bodyMenu = CCMenu:create()
	bodyMenu:setAnchorPoint(ccp(0,0))
	bodyMenu:setPosition(ccp(0,0))
	middleBg:addChild(bodyMenu,1)
	bodyMenu:setTouchPriority(_touch_priority-1)
	local bodyItem = nil
	bodyItem = CCMenuItemImage:create("images/base/hero/body_img/"..heroBodyStr, "images/base/hero/body_img/"..heroBodyStr)
	bodyItem:setScale(0.6)
    bodyMenu:addChild(bodyItem,1,_bodyMenuAndItemTag)
	bodyItem:setAnchorPoint(ccp(0.5,0.5))
	bodyItem:setPosition(ccp(middleBg:getContentSize().width*0.5,middleBg:getContentSize().height*0.5))
	bodyItem:registerScriptTapHandler(bodyClickAction)
end

function createProgress( ... )
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	if(_mainLayer:getChildByTag(_bgProressTag))then
		_mainLayer:removeChildByTag(_bgProressTag,true)
	end
	if(_mainLayer:getChildByTag(_kuangSpTag))then
		_mainLayer:removeChildByTag(_kuangSpTag,true)
	end
	local bgProress = CCSprite:create("images/sevenlottery/3.png")
	bgProress:setScale(g_fElementScaleRatio)
	bgProress:setAnchorPoint(ccp(0.5, 0))
	bgProress:setPosition(ccp(_mainLayer:getContentSize().width*0.5, _getRewardNode:getPositionY()+_getRewardNode:getContentSize().height+20*g_fElementScaleRatio))
	_mainLayer:addChild(bgProress,1,_bgProressTag)
	
	--经验条相关处理
	local expStr, expWidth = nil, nil
	local maxSp = nil
	local levelExp = tonumber(_totalData.lucky)
	local needExp = dbData.lucky_max
	if(levelExp>=tonumber(needExp))then
		levelExp = needExp
	end
	expStr = levelExp .. "/" .. needExp
	expWidth = 483 * levelExp/needExp
	progressSp = CCSprite:create("images/sevenlottery/2.png")
	progressSp:setTextureRect(CCRectMake(0,0,expWidth,23))
	progressSp:setAnchorPoint(ccp(0, 0.5))
	progressSp:setPosition(ccp(0,bgProress:getContentSize().height*0.5))
	bgProress:addChild(progressSp,1)

	local kuangSp = CCSprite:create("images/sevenlottery/1.png")
	kuangSp:setScale(g_fElementScaleRatio)
	kuangSp:setAnchorPoint(ccp(0.5, 0))
	kuangSp:setPosition(ccp(_mainLayer:getContentSize().width*0.5, _getRewardNode:getPositionY()+_getRewardNode:getContentSize().height+20*g_fElementScaleRatio))
	_mainLayer:addChild(kuangSp,1,_kuangSpTag)

	-- 经验值
	local expLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_497")..expStr, g_sFontName, 20)
	expLabel:setColor(ccc3(0xff, 0xff, 0xff))
	expLabel:setAnchorPoint(ccp(0.5, 0.5))
	expLabel:setPosition(ccp(kuangSp:getContentSize().width*0.5, kuangSp:getContentSize().height*0.5))
	kuangSp:addChild(expLabel,2)

	if(tonumber(needExp)==levelExp)then
		local littleFireAnimation = XMLSprite:create("images/sevenlottery/qixingtai_uitiao_1/qixingtai_uitiao_1")
		littleFireAnimation:setPosition(ccp(kuangSp:getContentSize().width*0.5,kuangSp:getContentSize().height*0.5))
    	kuangSp:addChild(littleFireAnimation,3)
	end
end
--创建底边栏
function createBottom( ... )
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	local itemData = string.split(dbData.cost_item,"|")
	if(tonumber(_totalData.free)>0)then
		_lastTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_508"),g_sFontName,21)
		_lastTimeLabel:setAnchorPoint(ccp(0.5,0))
		_lastTimeLabel:setScale(g_fElementScaleRatio)
		_lastTimeLabel:setPosition(ccp(_mainLayer:getContentSize().width*0.5,20*g_fElementScaleRatio))
		_mainLayer:addChild(_lastTimeLabel,1)
	elseif(ItemUtil.getCacheItemNumBy(itemData[2])>=tonumber(itemData[3]))then
		_lastTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_509"),g_sFontName,21)
		_lastTimeLabel:setAnchorPoint(ccp(0.5,0))
		_lastTimeLabel:setScale(g_fElementScaleRatio)
		_lastTimeLabel:setPosition(ccp(_mainLayer:getContentSize().width*0.47,20*g_fElementScaleRatio))
		_mainLayer:addChild(_lastTimeLabel,1)
		local lastTimeNumLabel = CCLabelTTF:create(ItemUtil.getCacheItemNumBy(itemData[2]),g_sFontName,21)
		lastTimeNumLabel:setAnchorPoint(ccp(0,0))
		lastTimeNumLabel:setPosition(ccp(_lastTimeLabel:getContentSize().width,0))
		lastTimeNumLabel:setColor(ccc3(0x00,0xff,0x18))
		_lastTimeLabel:addChild(lastTimeNumLabel,1)
		local geLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1090"),g_sFontName,21)
		geLabel:setAnchorPoint(ccp(0,0))
		geLabel:setPosition(ccp(lastTimeNumLabel:getContentSize().width,0))
		-- geLabel:setColor(ccc3(0x00,0xff,0x18))
		lastTimeNumLabel:addChild(geLabel,1)
	else
		_lastTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_486"),g_sFontName,21)
		_lastTimeLabel:setAnchorPoint(ccp(0.5,0))
		_lastTimeLabel:setScale(g_fElementScaleRatio)
		_lastTimeLabel:setPosition(ccp(_mainLayer:getContentSize().width*0.47,20*g_fElementScaleRatio))
		_mainLayer:addChild(_lastTimeLabel,1)
		local num = tonumber(dbData.daily_times)-tonumber(_totalData.num)
		local lastTimeNumLabel = CCLabelTTF:create(num.."/"..dbData.daily_times,g_sFontName,21)
		lastTimeNumLabel:setAnchorPoint(ccp(0,0))
		lastTimeNumLabel:setPosition(ccp(_lastTimeLabel:getContentSize().width,0))
		lastTimeNumLabel:setColor(ccc3(0x00,0xff,0x18))
		_lastTimeLabel:addChild(lastTimeNumLabel,1)
	end
	
	
	if(tonumber(_totalData.free)>0)then
		_buyFreeLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_487"),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		_buyFreeLabel:setColor(ccc3(0x00,0xff,0x18))
		_buyFreeLabel:setAnchorPoint(ccp(0.5,0))
		_buyFreeLabel:setScale(g_fElementScaleRatio)
		_buyFreeLabel:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_lastTimeLabel:getContentSize().height*g_fElementScaleRatio+40*g_fElementScaleRatio))
		_mainLayer:addChild(_buyFreeLabel,1)
	elseif(ItemUtil.getCacheItemNumBy(itemData[2])>=tonumber(itemData[3]))then
		_bottomNode = CCSprite:create()
		local itemSprite = CCSprite:create("images/base/props/qixinglingxiao.png")
			  itemSprite:setPosition(ccp(0,0))
			  itemSprite:setScale(g_fElementScaleRatio)
		_bottomNode:addChild(itemSprite)
		local costLabel = CCLabelTTF:create(itemData[3],g_sFontName,25)
			  costLabel:setPosition(ccp(itemSprite:getContentSize().width*g_fElementScaleRatio+10*g_fElementScaleRatio,0))
			  costLabel:setScale(g_fElementScaleRatio)
			  costLabel:setColor(ccc3(0x00,0xff,0x18))
		_bottomNode:addChild(costLabel)
		_bottomNode:setContentSize(CCSizeMake(itemSprite:getContentSize().width*g_fElementScaleRatio+10*g_fElementScaleRatio+costLabel:getContentSize().width*g_fElementScaleRatio,itemSprite:getContentSize().height*g_fElementScaleRatio))
		_bottomNode:setAnchorPoint(ccp(0.5,0))
		_bottomNode:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_lastTimeLabel:getContentSize().height*g_fElementScaleRatio+40*g_fElementScaleRatio))
		_mainLayer:addChild(_bottomNode,1)
	else
		_bottomNode = CCSprite:create()
		local goldSprite = CCSprite:create("images/common/gold.png")
			  goldSprite:setPosition(ccp(0,0))
			  goldSprite:setScale(g_fElementScaleRatio)
		_bottomNode:addChild(goldSprite)
		local costLabel = CCLabelTTF:create(dbData.cost_once,g_sFontName,25)
			  costLabel:setPosition(ccp(goldSprite:getContentSize().width*g_fElementScaleRatio,0))
			  costLabel:setScale(g_fElementScaleRatio)
			  costLabel:setColor(ccc3(0x00,0xff,0x18))
		_bottomNode:addChild(costLabel)
		_bottomNode:setContentSize(CCSizeMake(goldSprite:getContentSize().width*g_fElementScaleRatio+costLabel:getContentSize().width*g_fElementScaleRatio,goldSprite:getContentSize().height*g_fElementScaleRatio))
		_bottomNode:setAnchorPoint(ccp(0.5,0))
		_bottomNode:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_lastTimeLabel:getContentSize().height*g_fElementScaleRatio+30*g_fElementScaleRatio))
		_mainLayer:addChild(_bottomNode,1)
	end
	_callStarMenu = CCMenu:create()
	_callStarMenu:setPosition(ccp(0,0))
	_callStarMenu:setTouchPriority(_touch_priority-1)
	_mainLayer:addChild(_callStarMenu,1)
	local callStarItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_488"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	callStarItem:setAnchorPoint(ccp(0.5, 0))
	if(_buyFreeLabel~=nil)then
		callStarItem:setPosition(ccp(_mainLayer:getContentSize().width*0.5, _buyFreeLabel:getContentSize().height*g_fElementScaleRatio+_buyFreeLabel:getPositionY()+10*g_fElementScaleRatio))
	else
		callStarItem:setPosition(ccp(_mainLayer:getContentSize().width*0.5, _bottomNode:getContentSize().height+_bottomNode:getPositionY()+10*g_fElementScaleRatio))
	end
	callStarItem:registerScriptTapHandler(callAction)
	callStarItem:setScale(g_fElementScaleRatio)
	_callStarMenu:addChild(callStarItem, 2, 10002)
	_getRewardNode = CCSprite:create()
	_getRewardNode:setAnchorPoint(ccp(0.5,0))
	_mainLayer:addChild(_getRewardNode,1)
	local levelExp = tonumber(_totalData.lucky)
	local needExp = tonumber(dbData.lucky_max)
	if(levelExp>=tonumber(needExp))then
		levelExp = needExp
	end
	local str = ""
	if(levelExp==needExp)then
		str = GetLocalizeStringBy("llp_492")
	else
		str = GetLocalizeStringBy("llp_489")
	end
	local tipLabel =  CCLabelTTF:create(str,g_sFontName,25)
		  tipLabel:setColor(ccc3(0xff,0xf6,0x00))
		  tipLabel:setPosition(ccp(0,0))
		  tipLabel:setScale(g_fElementScaleRatio)
	_getRewardNode:addChild(tipLabel)
	local data = ItemUtil.getItemsDataByStr(dbData.lucky_rewards)
	local rewardLabel = CCLabelTTF:create(dbData.name.."*"..data[1].num,g_sFontName,25)
		  rewardLabel:setColor(ccc3(255,0,0))
		  rewardLabel:setPosition(ccp(tipLabel:getContentSize().width*g_fElementScaleRatio+10*g_fElementScaleRatio,0))
		  rewardLabel:setScale(g_fElementScaleRatio)
	_getRewardNode:addChild(rewardLabel)
	_getRewardNode:setContentSize(CCSizeMake(tipLabel:getContentSize().width*g_fElementScaleRatio+rewardLabel:getContentSize().width*g_fElementScaleRatio,rewardLabel:getContentSize().height*g_fElementScaleRatio))
	_getRewardNode:setPosition(ccp(callStarItem:getPositionX(),callStarItem:getPositionY()+callStarItem:getContentSize().height*g_fElementScaleRatio+10*g_fElementScaleRatio))
end
-----------------------------------------------上中下布局相关创建END-----------------------------------

-----------------------------------------------上中下布局刷新创建BEGIN-----------------------------------
--刷新上方 删除重建
function refreshTop()
	_mainLayer:removeChildByTag(_passNameBgTag,true)
	createTop()
end

function removeTop( ... )
	_mainLayer:removeChildByTag(_passNameBgTag,true)
end

--刷新中间 删除重建
function refreshMiddle( ... )
	if(_mainLayer:getChildByTag(_mainBgTag)~=nil and _mainLayer:getChildByTag(_mainBgTag):getChildByTag(_bodyMenuAndItemTag)~=nil)then
		_mainLayer:getChildByTag(_mainBgTag):removeChildByTag(_bodyMenuAndItemTag,true)
	end
	if(_mainLayer:getChildByTag(_bodyMenuAndItemTag)~=nil)then
		_mainLayer:removeChildByTag(_bodyMenuAndItemTag,true)
	end
	createMiddle()
end

function removeMiddle( ... )
	if(_mainLayer:getChildByTag(_mainBgTag)~=nil and _mainLayer:getChildByTag(_mainBgTag):getChildByTag(_bodyMenuAndItemTag)~=nil)then
		_mainLayer:getChildByTag(_mainBgTag):removeChildByTag(_bodyMenuAndItemTag,true)
	end
	if(_mainLayer:getChildByTag(_bodyMenuAndItemTag)~=nil)then
		_mainLayer:removeChildByTag(_bodyMenuAndItemTag,true)
	end
end

--刷新底边
function refreshBottom( ... )
	_lastTimeLabel:removeFromParentAndCleanup(true)
	_callStarMenu:removeFromParentAndCleanup(true)
	if(_buyFreeLabel~=nil)then
		_buyFreeLabel:removeFromParentAndCleanup(true)
		_buyFreeLabel = nil
	else
		_bottomNode:removeFromParentAndCleanup(true)
		_bottomNode = nil
	end
	_getRewardNode:removeFromParentAndCleanup(true)
	createBottom()
end

function removeBottom( ... )
	_lastTimeLabel:removeFromParentAndCleanup(true)
	_callStarMenu:removeFromParentAndCleanup(true)
	if(_buyFreeLabel~=nil)then
		_buyFreeLabel:removeFromParentAndCleanup(true)
		_buyFreeLabel = nil
	else
		_bottomNode:removeFromParentAndCleanup(true)
		_bottomNode = nil
	end
	_getRewardNode:removeFromParentAndCleanup(true)
end

-----------------------------------------------上中下布局刷新创建END-----------------------------------
function createLayer(pInfo)
	init()
	--创建layer
	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)
	_mainLayer:setPosition(ccp(0, 0))
	_mainLayer:setAnchorPoint(ccp(0, 0))
	getCopyInfoFunc(pInfo)
	return _mainLayer
end

function showLayer()
	-- body
	sendCommond()
end

-----------------------------------------------各种回调BEGIN-----------------------------------
function delayCallBack( ... )
	_mainLayer:stopAllActions()
	require "script/ui/sevenlottery/SevenLotteryRewardLayer"
	SevenLotteryRewardLayer.showLayer(_totalData,_beforeValue)
	_canClick = true
end

--召星回调
function callStarCallBack( pInfo )
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	if(tonumber(pInfo.lucky)>tonumber(_totalData.lucky))then
		local needExp = tonumber(dbData.lucky_max)
		if(tonumber(pInfo.lucky)>=tonumber(needExp))then
			pInfo.lucky = needExp
		end
		_totalData.deltaluck = tonumber(pInfo.lucky)-tonumber(_totalData.lucky)
	end
	_totalData.lucky = pInfo.lucky
	if(tonumber(_totalData.free)>0)then
		_totalData.free = _totalData.free - 1
	elseif(tonumber(_totalData.free)==0 and _typeNum==2)then
		_totalData.num = _totalData.num + 1
	end
	_totalData.reward = {}
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	local data = string.split(dbData.lucky_rewards,"|")
	if(tonumber(pInfo.lucky)==0)then
		_totalData.reward.item = {}
		_totalData.reward.item[data[2]] = data[3]
	else
		_totalData.reward = pInfo
	end
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    performWithDelay(runningScene,delayCallBack,0.1)
end
--召星
function callAction( ... )
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	local itemData = string.split(dbData.cost_item,"|")
	if(tonumber(_totalData.num)==tonumber(dbData.daily_times) and tonumber(_totalData.free)==0 and ItemUtil.getCacheItemNumBy(itemData[2])==0)then
		 AnimationTip.showTip(GetLocalizeStringBy("llp_495"))
		 return
	end

	if(ItemUtil.isBagFull())then
        return
    end

	_typeNum = 0
	if(tonumber(_totalData.free)>0)then

	elseif(ItemUtil.getCacheItemNumBy(itemData[2])>=tonumber(itemData[3]))then
		_typeNum = 1
	else
		local  needGoldNum = tonumber(dbData.cost_once)
		if(needGoldNum <= UserModel.getGoldNumber())then
			_typeNum = 2
		else
			LackGoldTip.showTip()
			return
		end
	end
	if(_canClick)then
		_canClick = false
		_beforeValue = _totalData.lucky
		SevenLotteryController.lottery(callStarCallBack,_typeNum)
	end
end

function preAction( ... )
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	local rewardData = ItemUtil.getItemsDataByStr(dbData.show_items)
	require "script/ui/sevenlottery/SevenLotteryRewardShowDialog"
	SevenLotteryRewardShowDialog.showDialog(rewardData, nil, nil, nil, -3000, 1000)
end

-- 返回
function backAction(tag, itembtn)
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
end

--积分商店按钮回调
function shopAction()
	require "script/ui/sevenlottery/shop/SevenLotteryShopLayer"
	SevenLotteryShopLayer.show()
end

--中间英雄item点击回调
function bodyClickAction( tag,itembtn )
	-- SevenLotteryController.getInfo(refreshFunc)
end
-----------------------------------------------各种回调END-----------------------------------