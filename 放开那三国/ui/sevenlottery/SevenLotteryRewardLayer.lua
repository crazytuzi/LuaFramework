-- Filename：	SevenLotteryRewardLayer.lua
-- Author：		LLP
-- Date：		2016-8-3
-- Purpose：		七星潭

module("SevenLotteryRewardLayer", package.seeall)

require "script/ui/sevenlottery/SevenLotteryController"

local _totalData 	 		= nil
local _lastTimeLabel 		= nil
local _bottomNode  	 		= nil
local _getRewardNode 		= nil
local _callStarMenu  		= nil
local _leftTimeNumLabel 	= nil
local _titleSprite 			= nil
local progressSp 			= nil
local expLabel 				= nil
local kuangSp 				= nil
local _beforeValue 			= 0
local _index 				= 1
local _typeNum 				= 0
local _mainBgTag 	 		= 1 
local _topSpriteBgTag 		= 2
local _bodyMenuAndItemTag 	= 3
local _passNameBgTag 		= 4
local _bgProressTag  		= 5
local _nextRewardLabelTag 	= 6
local _kuangSpTag 		    = 7
local _tipTag 				= 1034
local _touch_priority     	= -500
local _canTouch 			= false
local _posTable 		    = {}
local _isShow 				= false
--初始化
function init( ... )
	_index 				= 1
	_typeNum 				= 0
	_isShow 				= false
	_canTouch 			= false
	_beforeValue 			= 0
	kuangSp 				= nil
	expLabel 				= nil
	progressSp 			= nil
	_totalData 			= nil
	_lastTimeLabel  	= nil
	_bottomNode  		= nil
	_getRewardNode  	= nil
	_callStarMenu   	= nil
	_leftTimeNumLabel 	= nil
	_posTable 		    = {}
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
	local str = _totalData.period_end
	require "script/utils/TimeUtil"
	local timeLabel = CCLabelTTF:create(TimeUtil.getRemainTimeHMS(str),g_sFontPangWa,25)
		  timeLabel:setScale(g_fElementScaleRatio)
		  timeLabel:setAnchorPoint(ccp(1,1))
		  timeLabel:setVisible(false)
		  timeLabel:setPosition(ccp(_mainLayer:getContentSize().width*0.45,_mainLayer:getContentSize().height*0.7))
	_mainLayer:addChild(timeLabel,2)
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
end

function createNextRewardLabel( ... )
	if(_mainLayer:getChildByTag(_nextRewardLabelTag))then
		_mainLayer:removeChildByTag(_nextRewardLabelTag,true)
	end

	local nextRewardLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_491"),g_sFontPangWa,25)
		  nextRewardLabel:setAnchorPoint(ccp(0,1))
		  nextRewardLabel:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height*0.7))
		  nextRewardLabel:setScale(g_fElementScaleRatio)
	_mainLayer:addChild(nextRewardLabel,2,_nextRewardLabelTag)
	local nameStr = DB_Sevenstar_altar.getDataById(_totalData.next_id).name
	_rewardLabel = CCLabelTTF:create(nameStr,g_sFontPangWa,25)
	_rewardLabel:setAnchorPoint(ccp(0,0))
	_rewardLabel:setPosition(ccp(nextRewardLabel:getContentSize().width*g_fElementScaleRatio,0))
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
	-- createMiddle()
	--创建底部布局
	createBottom()
	createTimeLabel()
	refreshBottom()
	createProgress()
	MainScene.changeLayer(_mainLayer, "SevenLotteryRewardLayer")
	MainScene.setMainSceneViewsVisible(false,false,false)
end

--刷新
function refreshFunc( pInfo )
	_totalData = pInfo
	-- body
	refreshBottom()
	createTimeLabel()
end
-----------------------------------------------命令相关END-----------------------------------

-----------------------------------------------上中下布局相关创建BEGIN-----------------------------------
function createBg()
	--背景图片
	local mainBg = CCSprite:create("images/sevenlottery/bg.png" )
	mainBg:setScale(g_fBgScaleRatio)
	mainBg:setAnchorPoint(ccp(0.5,0.5))
	mainBg:setPosition(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height*0.5)
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

	local runningScene = CCDirector:sharedDirector():getRunningScene()
    performWithDelay(runningScene,refreshBottom,0.1)
	-------特效类
	--法阵闪
	--光柱
	local guangzhuAnimation = XMLSprite:create("images/sevenlottery/qixingtai_fazhen/qixingtai_fazhen")
	guangzhuAnimation:setPosition(ccp(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height*0.42))
    mainBg:addChild(guangzhuAnimation,1)
    local function cleanGuangZhuAnimation( ... )
    	guangzhuAnimation:removeFromParentAndCleanup(true)
    end
    local function shakeLayer( ... )
    	local upAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX(),mainBg:getPositionY()-20*g_fElementScaleRatio))
		local downAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX(),mainBg:getPositionY()+10*g_fElementScaleRatio))
		local leftAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX()-7*g_fElementScaleRatio,mainBg:getPositionY()))
		local rightAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX()+13*g_fElementScaleRatio,mainBg:getPositionY()))
		local backAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX(),mainBg:getPositionY()))
		local actionArray = CCArray:create()
	    actionArray:addObject(upAction)
	    actionArray:addObject(leftAction)
	    actionArray:addObject(rightAction)
	    actionArray:addObject(upAction)
	    actionArray:addObject(leftAction)
	    -- actionArray:addObject(downAction)
	    
	    actionArray:addObject(backAction)
	    mainBg:runAction(CCSequence:create(actionArray))
	    refreshMiddle()
    end 
    guangzhuAnimation:registerKeyFrameCallback(shakeLayer)
    guangzhuAnimation:registerEndCallback(cleanGuangZhuAnimation)
    --经验条闪
	-- addShineFunction()
end

--创建上边栏
function createTop( ... )
	_titleSprite = CCSprite:create("images/godweaponcopy/getreward.png")
	_titleSprite:setAnchorPoint(ccp(0.5,1))
	_titleSprite:setScale(g_fElementScaleRatio)
	_titleSprite:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height-10*g_fElementScaleRatio))
	_titleSprite:setVisible(false)
	_mainLayer:addChild(_titleSprite,1)
end

--动画特效 我日一闪一闪亮晶晶
function getStarEffect( item )
	AudioUtil.playEffect("audio/effect/wupindakai.mp3")
	local godOpenEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/sevenlottery/qixingtai_tubiao/qixingtai_tubiao"), 1,CCString:create(""));
	--增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(function ( ... )
	    godOpenEffect:removeFromParentAndCleanup(true)
    end)
    godOpenEffect:setDelegate(delegate)
	return godOpenEffect
end

function scaleFunc( item,index )
	item:setScale(0.0*g_fElementScaleRatio)
	item:setVisible(true)
	local scale_1 = CCScaleTo:create(0, 1.1*g_fElementScaleRatio)
	local scale_2 = CCScaleTo:create(0, 0.9*g_fElementScaleRatio)
	local scale_3 = CCScaleTo:create(0, 1*g_fElementScaleRatio)
	local pIndex = index
	local function afterCallBack( item )
		addShine(pIndex)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		performWithDelay(runningScene,addShineFunction,0.6)
	end
	local array = CCArray:create()
	array:addObject(scale_1)
    array:addObject(scale_2)
    array:addObject(scale_3)
    array:addObject(CCMoveTo:create(0.1,_posTable[index]))
    array:addObject(CCCallFuncN:create(afterCallBack))
    local seq = CCSequence:create(array)
    item:runAction(seq)
    
 --    local runningScene = CCDirector:sharedDirector():getRunningScene()
	-- performWithDelay(runningScene,addShine,0.4)
end

function addShine( index )
	local starEffect = getStarEffect(item)
	starEffect:setAnchorPoint(ccp(0,0))
	_mainLayer:addChild(starEffect,1)
	starEffect:setPosition(_posTable[index])
end

function appear( ... )
	_titleSprite:setVisible(true)
end

function createMiddle( ... )
	local titleSprite = CCSprite:create("images/godweaponcopy/getreward.png")
	local index = 1
	for k,v in pairs(_totalData.reward.item) do
		local rewardSp = ItemSprite.getItemSpriteById(k)
			  rewardSp:setScale(g_fElementScaleRatio)
			  rewardSp:setAnchorPoint(ccp(0.5,0.5))
			  rewardSp:setPosition(ccp(_mainLayer:getContentSize().width*0.1+(index-1)*rewardSp:getContentSize().width*g_fElementScaleRatio+(index-1)*50*g_fElementScaleRatio+rewardSp:getContentSize().width*0.5*g_fElementScaleRatio,_mainLayer:getContentSize().height*0.62+rewardSp:getContentSize().height*0.5*g_fElementScaleRatio))
		_posTable[index] = ccp(_mainLayer:getContentSize().width*0.1+(index-1)*rewardSp:getContentSize().width*g_fElementScaleRatio+(index-1)*50*g_fElementScaleRatio+rewardSp:getContentSize().width*0.5*g_fElementScaleRatio,_mainLayer:getContentSize().height*0.62+rewardSp:getContentSize().height*0.5*g_fElementScaleRatio)
		rewardSp:setScale(0)
		_mainLayer:addChild(rewardSp,1,index+10)
		rewardSp:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height*0.42))
		scaleFunc(rewardSp,index)
		local nameStr = ItemUtil.getItemNameByTid(k)
		local numLabel = CCLabelTTF:create(nameStr,g_sFontName,20)
			  numLabel:setAnchorPoint(ccp(0.5,1))
			  numLabel:setPosition(ccp(rewardSp:getContentSize().width*0.5,-10*g_fElementScaleRatio))
		rewardSp:addChild(numLabel)
		local countLabel = CCRenderLabel:create(v,g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
			  countLabel:setAnchorPoint(ccp(1,0))
			  countLabel:setPosition(ccp(rewardSp:getContentSize().width-10,5))
			  countLabel:setColor(ccc3(0,255,0))
		rewardSp:addChild(countLabel)
		local dataDesc = ItemUtil.getItemById(tonumber(k))
		local nameColor = HeroPublicLua.getCCColorByStarLevel(dataDesc.quality)
		numLabel:setColor(nameColor)
		index = index + 1
	end
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	local sp = ItemSprite.getStarPointIcon()
		  sp:setScale(g_fElementScaleRatio)
		  sp:setAnchorPoint(ccp(0.5,0.5))
		  sp:setPosition(ccp(_mainLayer:getContentSize().width*0.1+(index-1)*sp:getContentSize().width*g_fElementScaleRatio+(index-1)*50*g_fElementScaleRatio+sp:getContentSize().width*0.5*g_fElementScaleRatio,_mainLayer:getContentSize().height*0.62+sp:getContentSize().height*0.5*g_fElementScaleRatio))
		  _posTable[index] = ccp(_mainLayer:getContentSize().width*0.1+(index-1)*sp:getContentSize().width*g_fElementScaleRatio+(index-1)*50*g_fElementScaleRatio+sp:getContentSize().width*0.5*g_fElementScaleRatio,_mainLayer:getContentSize().height*0.62+sp:getContentSize().height*0.5*g_fElementScaleRatio)
	_mainLayer:addChild(sp,1,index+10)
	local numLabel = CCLabelTTF:create( GetLocalizeStringBy("llp_494"),g_sFontName,20)
		  numLabel:setAnchorPoint(ccp(0.5,1))
		  numLabel:setPosition(ccp(sp:getContentSize().width*0.5,-10*g_fElementScaleRatio))
	sp:addChild(numLabel)
	local countLabel = CCRenderLabel:create(dbData.code_once,g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		  countLabel:setAnchorPoint(ccp(1,0))
		  countLabel:setPosition(ccp(sp:getContentSize().width-10,5))
		  countLabel:setColor(ccc3(0,255,0))
	sp:addChild(countLabel)
	numLabel:setColor(ccc3(255, 0, 0xe1))
	sp:setScale(0)
	
	sp:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height*0.42))
	scaleFunc(sp,index)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    performWithDelay(runningScene,appear,0.2)
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
	local levelExp = tonumber(_beforeValue)
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

	kuangSp = CCSprite:create("images/sevenlottery/1.png")
	kuangSp:setScale(g_fElementScaleRatio)
	kuangSp:setAnchorPoint(ccp(0.5, 0))
	kuangSp:setPosition(ccp(_mainLayer:getContentSize().width*0.5, _getRewardNode:getPositionY()+_getRewardNode:getContentSize().height+20*g_fElementScaleRatio))
	_mainLayer:addChild(kuangSp,1,_kuangSpTag)

	-- 经验值
	expLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_497")..expStr, g_sFontName, 20)
	expLabel:setColor(ccc3(0xff, 0xff, 0xff))
	expLabel:setAnchorPoint(ccp(0.5, 0.5))
	expLabel:setPosition(ccp(kuangSp:getContentSize().width*0.5, kuangSp:getContentSize().height*0.5))
	kuangSp:addChild(expLabel,2)

	if(tonumber(needExp)==levelExp)then
		local littleFireAnimation = XMLSprite:create("images/sevenlottery/qixingtai_uitiao_1/qixingtai_uitiao_1")
		littleFireAnimation:setPosition(ccp(kuangSp:getContentSize().width*0.5,kuangSp:getContentSize().height*0.5))
    	kuangSp:addChild(littleFireAnimation,3)
	end
	if(_index>1 and levelExp~=0 )then
		showFloatText(_totalData.deltaluck,nil,nil,3)
	end
	_index = _index + 1
end

function freshProgress( ... )
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	local needExp = dbData.lucky_max
	--经验条相关处理
	local function fresh( ... )
		_beforeValue = _beforeValue + 1
		if(_beforeValue==tonumber(_totalData.lucky))then
			local bg = _mainLayer:getChildByTag(_mainBgTag)
			bg:stopAllActions()
		end
		if(tonumber(_beforeValue)==tonumber(needExp))then
			local littleFireAnimation = XMLSprite:create("images/sevenlottery/qixingtai_uitiao_1/qixingtai_uitiao_1")
			littleFireAnimation:setPosition(ccp(kuangSp:getContentSize().width*0.5,kuangSp:getContentSize().height*0.5))
	    	kuangSp:addChild(littleFireAnimation,3)
		end
		expWidth = 483 * _beforeValue/needExp
		progressSp:setTextureRect(CCRectMake(0,0,expWidth,23))
		expLabel:setString(GetLocalizeStringBy("llp_497").._beforeValue.."/"..needExp)
	end
	local effectActionArray = CCArray:create()
    effectActionArray:addObject(CCDelayTime:create(0.1))
    effectActionArray:addObject(CCCallFunc:create(fresh))
    local sequence_2 = CCSequence:create(effectActionArray)
    local action_2 = CCRepeatForever:create(sequence_2)
    if(tonumber(_beforeValue)<tonumber(needExp))then
    	local bg = _mainLayer:getChildByTag(_mainBgTag)
    	bg:runAction(action_2)
    end
    if(_index>1 and tonumber(_totalData.deltaluck)>0 )then
		showFloatText(_totalData.deltaluck,nil,nil,3)
	end
	_index = _index + 1
end

--创建底边栏
function createBottom( ... )
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	local goldForHeightSprite = CCSprite:create("images/common/gold.png")
	local itemData = string.split(dbData.cost_item,"|")
	--剩余召星次数
	_leftTimeSprite = CCSprite:create()
	_leftTimeSprite:setAnchorPoint(ccp(1,0))
	_mainLayer:addChild(_leftTimeSprite,1)
	if(ItemUtil.getCacheItemNumBy(itemData[2])>=tonumber(itemData[3]))then
		local leftTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_509"),g_sFontName,21)
		  leftTimeLabel:setPosition(ccp(0,0))
		  leftTimeLabel:setScale(g_fElementScaleRatio)
		_leftTimeSprite:addChild(leftTimeLabel,1)
		_leftTimeNumLabel = CCLabelTTF:create(ItemUtil.getCacheItemNumBy(itemData[2]),g_sFontName,21)
		_leftTimeNumLabel:setColor(ccc3(0,255,0))
		_leftTimeNumLabel:setPosition(ccp(leftTimeLabel:getContentSize().width*g_fElementScaleRatio,0))
		_leftTimeNumLabel:setScale(g_fElementScaleRatio)
		_leftTimeSprite:addChild(_leftTimeNumLabel)

		local timeLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1090"),g_sFontName,21) 
		timeLabel:setPosition(ccp(leftTimeLabel:getContentSize().width*g_fElementScaleRatio+_leftTimeNumLabel:getContentSize().width*g_fElementScaleRatio,0))
		timeLabel:setScale(g_fElementScaleRatio)
		_leftTimeSprite:addChild(timeLabel)

		_leftTimeSprite:setContentSize(CCSizeMake(leftTimeLabel:getContentSize().width*g_fElementScaleRatio+_leftTimeNumLabel:getContentSize().width*g_fElementScaleRatio+timeLabel:getContentSize().width*g_fElementScaleRatio,_leftTimeNumLabel:getContentSize().height*g_fElementScaleRatio))
		_leftTimeSprite:setPosition(ccp(_mainLayer:getContentSize().width*0.92,20*g_fElementScaleRatio))
	else
		local leftTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_498"),g_sFontName,21)
		  leftTimeLabel:setPosition(ccp(0,0))
		  leftTimeLabel:setScale(g_fElementScaleRatio)
		_leftTimeSprite:addChild(leftTimeLabel,1)
		local num = tonumber(dbData.daily_times)-tonumber(_totalData.num)
		_leftTimeNumLabel = CCLabelTTF:create(num,g_sFontName,21)
		_leftTimeNumLabel:setColor(ccc3(0,255,0))
		_leftTimeNumLabel:setPosition(ccp(leftTimeLabel:getContentSize().width*g_fElementScaleRatio,0))
		_leftTimeNumLabel:setScale(g_fElementScaleRatio)
		_leftTimeSprite:addChild(_leftTimeNumLabel)

		local timeLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1086"),g_sFontName,21) 
		timeLabel:setPosition(ccp(leftTimeLabel:getContentSize().width*g_fElementScaleRatio+_leftTimeNumLabel:getContentSize().width*g_fElementScaleRatio,0))
		timeLabel:setScale(g_fElementScaleRatio)
		_leftTimeSprite:addChild(timeLabel)

		_leftTimeSprite:setContentSize(CCSizeMake(leftTimeLabel:getContentSize().width*g_fElementScaleRatio+_leftTimeNumLabel:getContentSize().width*g_fElementScaleRatio+timeLabel:getContentSize().width*g_fElementScaleRatio,_leftTimeNumLabel:getContentSize().height*g_fElementScaleRatio))
		_leftTimeSprite:setPosition(ccp(_mainLayer:getContentSize().width*0.85,20*g_fElementScaleRatio))
	end
	
	--免费还是消耗道具什么的
	if(tonumber(_totalData.free)>0)then
		_buyFreeLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_487"),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		_buyFreeLabel:setColor(ccc3(0x00,0xff,0x18))
		_buyFreeLabel:setAnchorPoint(ccp(0.5,0))
		_buyFreeLabel:setScale(g_fElementScaleRatio)
		_buyFreeLabel:setPosition(ccp(_mainLayer:getContentSize().width*0.90-_leftTimeSprite:getContentSize().width*0.5,_leftTimeSprite:getContentSize().height+30*g_fElementScaleRatio))
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
		_bottomNode:setPosition(ccp(_mainLayer:getContentSize().width*0.90-_leftTimeSprite:getContentSize().width*0.5,_leftTimeSprite:getContentSize().height+30*g_fElementScaleRatio))
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
		_bottomNode:setPosition(ccp(_mainLayer:getContentSize().width*0.85-_leftTimeSprite:getContentSize().width*0.5,_leftTimeSprite:getContentSize().height+30*g_fElementScaleRatio))
		_mainLayer:addChild(_bottomNode,1)
	end

	_callStarMenu = CCMenu:create()
	_callStarMenu:setTouchPriority(_touch_priority-1)
	_callStarMenu:setPosition(ccp(0,0))
	_mainLayer:addChild(_callStarMenu,1)

	local quitItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("lic_1314"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  quitItem:setScale(g_fElementScaleRatio)
		  quitItem:setAnchorPoint(ccp(0,0))
		  quitItem:registerScriptTapHandler(quitAction)
		  quitItem:setPosition(ccp(_mainLayer:getContentSize().width*0.15,_leftTimeSprite:getContentSize().height+10*g_fElementScaleRatio+goldForHeightSprite:getContentSize().height*g_fElementScaleRatio+30*g_fElementScaleRatio))
	_callStarMenu:addChild(quitItem)

	local callItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_493"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  callItem:setScale(g_fElementScaleRatio)
		  callItem:setAnchorPoint(ccp(1,0))
		  callItem:registerScriptTapHandler(callAction)
		  callItem:setPosition(ccp(_mainLayer:getContentSize().width*0.85,_leftTimeSprite:getContentSize().height+10*g_fElementScaleRatio+goldForHeightSprite:getContentSize().height*g_fElementScaleRatio+30*g_fElementScaleRatio))
	_callStarMenu:addChild(callItem)

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
	_getRewardNode:setPosition(ccp(_mainLayer:getContentSize().width*0.5,callItem:getPositionY()+callItem:getContentSize().height*g_fElementScaleRatio+10*g_fElementScaleRatio))
end
-----------------------------------------------上中下布局相关创建END-----------------------------------

-----------------------------------------------上中下布局刷新创建BEGIN-----------------------------------
function fly( ... )
	createMiddle()
end
--刷新中间 删除重建
function refreshMiddle( ... )
	for i=1,table.count(_totalData.reward.item)+1 do
		_mainLayer:removeChildByTag(i+10,true)
	end
	fly()
	-- local runningScene = CCDirector:sharedDirector():getRunningScene()
 --    performWithDelay(runningScene,fly,0.3)
end

function removeMiddle( ... )
	for i=1,4 do
		_mainLayer:removeChildByTag(i+10,true)
	end
end

--刷新底边
function refreshBottom( ... )
	_leftTimeSprite:removeFromParentAndCleanup(true)
	_callStarMenu:removeFromParentAndCleanup(true)
	_getRewardNode:removeFromParentAndCleanup(true)
	if(_buyFreeLabel~=nil)then
		_buyFreeLabel:removeFromParentAndCleanup(true)
		_buyFreeLabel = nil
	else
		_bottomNode:removeFromParentAndCleanup(true)
		_bottomNode = nil
	end
	createBottom()
end

function removeBottom( ... )
	_callStarMenu:removeFromParentAndCleanup(true)
	if(_buyFreeLabel~=nil)then
		_buyFreeLabel:removeFromParentAndCleanup(true)
		_buyFreeLabel = nil
	else
		_bottomNode:removeFromParentAndCleanup(true)
		_bottomNode = nil
	end
end

-----------------------------------------------上中下布局刷新创建END-----------------------------------
function createLayer(pInfo,pValue)
	init()
	--创建layer
	_beforeValue = pValue
	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)
	_mainLayer:setPosition(ccp(0, 0))
	_mainLayer:setAnchorPoint(ccp(0, 0))
	getCopyInfoFunc(pInfo)
	return _mainLayer
end

function showLayer(pInfo,pValue)
	-- body
	createLayer(pInfo,pValue)
end

-----------------------------------------------各种回调BEGIN-----------------------------------
--飞字
function showFloatText( tipText ,frontName, colors, time )
	-- if(string.len(tipText)<=0)then
	-- 	return
	-- end
	if(tipText==nil or tipText=="")then
		return
	end
	local color = colors  or { red = 0xff, green=0xf6 , blue =0x00 }
	local timeInterval = time or 1

	if(frontName == nil) then
		frontName = g_sFontPangWa
	end
	
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	--提示背景
	local tipNode = CCNode:create()
	runningScene:addChild(tipNode,2013,_tipTag)
	
	local labelSprite = CCSprite:create()
		  labelSprite:setAnchorPoint(ccp(0.5,0))
	local oneLable = CCRenderLabel:create( GetLocalizeStringBy("llp_501") , g_sFontPangWa, 24, 2, ccc3(0x00, 0x00, 0x00), type_stroke)
		  oneLable:setAnchorPoint(ccp(0,0))
		  oneLable:setPosition(ccp(0,0))
		  oneLable:setScale(g_fElementScaleRatio)
	labelSprite:addChild(oneLable)
	-- 描述
	local descLabel =  CCRenderLabel:create( tipText , g_sFontPangWa, 25, 2, ccc3(0x00, 0x00, 0x00), type_stroke)
	descLabel:setScale(g_fElementScaleRatio)
	descLabel:setColor(ccc3(0,255,0))
	descLabel:setAnchorPoint(ccp(0, 0))
	local width = (runningScene:getContentSize().width)/2 
	descLabel:setPosition(ccp(oneLable:getContentSize().width*g_fElementScaleRatio, 0))
	labelSprite:addChild(descLabel)

	local threeLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_500") , g_sFontPangWa, 24, 2, ccc3(0x00, 0x00, 0x00), type_stroke)
		  threeLabel:setAnchorPoint(ccp(0,0))
		  threeLabel:setPosition(ccp(descLabel:getPositionX()+descLabel:getContentSize().width*g_fElementScaleRatio,0))
		  threeLabel:setScale(g_fElementScaleRatio)
	labelSprite:addChild(threeLabel)

	labelSprite:setContentSize(CCSizeMake((oneLable:getContentSize().width+descLabel:getContentSize().width+threeLabel:getContentSize().width)*g_fElementScaleRatio,oneLable:getContentSize().height*g_fElementScaleRatio))
	labelSprite:setPosition(ccp(width, _getRewardNode:getPositionY()+_getRewardNode:getContentSize().height+50*g_fElementScaleRatio))
	tipNode:addChild(labelSprite)
	local function endCallback( tipNode )
		runningScene:removeChildByTag(_tipTag,true)
		_canTouch = true
	end 
	local actionArr = CCArray:create()
	actionArr:addObject(CCMoveTo:create(0.8,ccp(width, _getRewardNode:getPositionY()+_getRewardNode:getContentSize().height+80*g_fElementScaleRatio)))
	actionArr:addObject(CCFadeOut:create(0.8))
	actionArr:addObject(CCCallFuncN:create(endCallback))
	labelSprite:runAction(CCSequence:create(actionArr))
end

--经验条闪一下特效
function addShineFunction( ... )
	local bgSprite = _mainLayer:getChildByTag(_mainBgTag)
	local kuangSp = _mainLayer:getChildByTag(_kuangSpTag)
	local littleFireAnimation = XMLSprite:create("images/sevenlottery/qixingtai_uitiao_2/qixingtai_uitiao_2")
		  littleFireAnimation:setScale(g_fElementScaleRatio)
		  littleFireAnimation:setPosition(ccp(_mainLayer:getContentSize().width*0.5, _getRewardNode:getPositionY()+_getRewardNode:getContentSize().height+20*g_fElementScaleRatio+kuangSp:getContentSize().height*0.5*g_fElementScaleRatio))
	local function cleanAnimation( ... )
		littleFireAnimation:removeFromParentAndCleanup(true)
	end
	littleFireAnimation:registerEndCallback(cleanAnimation)
    _mainLayer:addChild(littleFireAnimation,3)
    if(tonumber(_totalData.lucky)~=0)then
    	freshProgress()
    else
    	_beforeValue = 0
    	createProgress()
    	_canTouch = true
    end
end
--召星回调
function callStarCallBack( pInfo )
	_canTouch = false
	require "db/DB_Sevenstar_altar"
	local dbData = DB_Sevenstar_altar.getDataById(_totalData.curr_id)
	_beforeValue = tonumber(_totalData.lucky)
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
	local data = string.split(dbData.lucky_rewards,"|")
	if(tonumber(pInfo.lucky)==0)then
		_totalData.reward.item = {}
		_totalData.reward.item[data[2]] = data[3]
	else
		_totalData.reward = pInfo
	end 

	_titleSprite:setVisible(false)
	removeMiddle()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    performWithDelay(runningScene,refreshBottom,0.1)
	
	-------特效类
	local mainBg = _mainLayer:getChildByTag(_mainBgTag)
	--法阵闪
	--光柱
	local guangzhuAnimation = XMLSprite:create("images/sevenlottery/qixingtai_fazhen/qixingtai_fazhen")
		  guangzhuAnimation:setPosition(ccp(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height*0.42))
    mainBg:addChild(guangzhuAnimation,1)
    local function cleanGuangZhuAnimation( ... )
    	guangzhuAnimation:removeFromParentAndCleanup(true)
    end
    local function shakeLayer( ... )
    	local upAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX(),mainBg:getPositionY()-20*g_fElementScaleRatio))
		local downAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX(),mainBg:getPositionY()+10*g_fElementScaleRatio))
		local leftAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX()-7*g_fElementScaleRatio,mainBg:getPositionY()))
		local rightAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX()+13*g_fElementScaleRatio,mainBg:getPositionY()))
		local backAction = CCMoveTo:create(0.03, ccp(mainBg:getPositionX(),mainBg:getPositionY()))
		local actionArray = CCArray:create()
	    actionArray:addObject(upAction)
	    actionArray:addObject(leftAction)
	    actionArray:addObject(rightAction)
	    actionArray:addObject(upAction)
	    actionArray:addObject(leftAction)
	    -- actionArray:addObject(downAction)
	    
	    actionArray:addObject(backAction)
	    mainBg:runAction(CCSequence:create(actionArray))
	    refreshMiddle()
    end 
	guangzhuAnimation:registerKeyFrameCallback(shakeLayer)
	guangzhuAnimation:registerEndCallback(cleanGuangZhuAnimation)
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
	if(_canTouch)then
		SevenLotteryController.lottery(callStarCallBack,_typeNum)
	end
end

-- 返回
function quitAction(tag, itembtn)
	if(_canTouch)then
		_mainLayer:stopAllActions()
		require "script/ui/sevenlottery/SevenLotteryLayer"
		SevenLotteryLayer.showLayer()
	end
end

--积分商店按钮回调
function shopAction()
	require "script/ui/sevenlottery/shop/SevenLotteryShopLayer"
	SevenLotteryShopLayer.show()
end

--中间英雄item点击回调
function bodyClickAction( tag,itembtn )
	SevenLotteryController.getInfo(refreshFunc)
end
-----------------------------------------------各种回调END-----------------------------------