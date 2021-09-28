-- Filename: LevelRewardLayer.lua
-- Author: zhz
-- Date: 2013-8-29
-- Purpose: 该文件用于: 等级礼包

module ("LevelRewardLayer", package.seeall)

require "script/ui/level_reward/LevelRewardCell"
require "script/network/RequestCenter"
require "script/ui/level_reward/LevelRewardUtil"
require "script/audio/AudioUtil"

-- add by licong
local didCreateTableViewFunc = nil
local didClickCell = nil
-- end
local _bgLayer
local _rewardTableView					-- 奖励的TableView
local _rewardSpite						-- 奖励黑色的背景
local _curRewardInfo 
local _closeBtn

local levelRewardDidLoadCallback = nil

local levelRewardLayerCloseCallback = nil

local function init()
	_bgLayer = nil
	_rewardTableView = nil
	_rewardSpite = nil
	_curRewardInfo = nil
	_closeBtn = nil
end

-- layer 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end

-- 关闭按钮的回调函数
 function closeCb( )

	---[==[等级礼包新手引导屏蔽层
		---------------------新手引导---------------------------------
		--add by licong 2013.09.09
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideFiveLevelGift) then
			require "script/guide/LevelGiftBagGuide"
			LevelGiftBagGuide.changLayer()
		end
		---------------------end-------------------------------------
	--]==]
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	require "script/ui/level_reward/LevelRewardBtn"
	LevelRewardBtn.releaseEffect()

	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = true

	if( LevelRewardBtn.isReceivedAll() ) then

		LevelRewardBtn.releaseBtn()
	end



	-- release 
	-- _rewardTableView:removeFromParentAndCleanup(true)
	-- _rewardTableView = nil
	-- _rewardSpite:removeFromParentAndCleanup(true)
	-- _rewardSpite = nil
	-- _curRewardInfo = nil

	---[==[ 第四步等级礼包关闭按钮
		---------------------新手引导---------------------------------
	    --add by licong 2013.09.09
	    require "script/guide/NewGuide"
		print("g_guideClass = ", NewGuide.guideClass)
	    require "script/guide/LevelGiftBagGuide"
	    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 3) then
	        require "script/ui/main/MenuLayer"
	        local levelGiftBagGuide_button = MenuLayer.getMenuItemNode(5)
	        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
	        LevelGiftBagGuide.show(4, touchRect)
	    end
		---------------------end-------------------------------------
	--]==]
	if(levelRewardLayerCloseCallback ~= nil)then
		levelRewardLayerCloseCallback()
	end
	
	require "script/ui/main/MainMenuLayer"
	MainMenuLayer.updateTopButton()

end

-- 新手引导， for 李晨阳
-- 通过cellIndex 获得 领取按钮的按钮
function  getReceiveBtn(cellIndex)
	local rewardData = LevelRewardUtil.getAllRewardData()
	local curCell = tolua.cast(_rewardTableView:cellAtIndex(cellIndex),"CCTableViewCell")
	local receiveTag = tonumber(rewardData[cellIndex+1].id ) +1000
	local receiveBtn = curCell:getChildByTag(101):getChildByTag(receiveTag)

	return receiveBtn
end

-- 返回关闭按钮
function getCloseBtn(  )
	return _closeBtn
end

--
local function createTableView(isChange,tag)
	-- if(_rewardTableView)then
	-- 	_rewardTableView:removeFromParentAndCleanup(true)
	-- 	_rewardTableView = nil
	-- end
	local change = isChange or false
	local cellSize = CCSizeMake(583,191)
	local rewardData = LevelRewardUtil.getAllRewardData()
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			a2 = LevelRewardCell.createCell(rewardData[a1+1])
			if(change)then
				print("应该这样走这")
				a2 = LevelRewardCell.createCell(rewardData[a1+1],change,tag)	
			end
			r = a2
		elseif fn == "numberOfCells" then
			r = #rewardData
		elseif fn == "cellTouched" then
			print("cellTouched", a1:getIdx())

		elseif (fn == "scroll") then
			
		end
		return r
	end)
	_rewardTableView = LuaTableView:createWithHandler(h,CCSizeMake(583,640))
	_rewardTableView:setPosition(ccp(5,8))
	_rewardTableView:setTouchPriority(-552)
	--_rewardTableView:setAnchorPoint(ccp(0.5,0))
	_rewardTableView:setBounceable(true)
	_rewardTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_rewardSpite:addChild(_rewardTableView)

    -- 增加方法调用前判断 2013.09.09 by licong
	if(didCreateTableViewFunc ~= nil)then
		didCreateTableViewFunc()
	end

	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			if(levelRewardDidLoadCallback ~= nil)then
				levelRewardDidLoadCallback()
			end
		end))
	_rewardTableView:runAction(seq)
	refreshTableView()
end
function refresh( tag )
	 _rewardTableView:removeFromParentAndCleanup(true)
	 _rewardTableView = nil
	 createTableView(true,tag)
	local offset = _rewardTableView:getContentOffset()
	 -- _rewardTableView:reloadData()
	 _rewardTableView:setContentOffset(offset)
end

-- 打开界面时自动跳到当前可领取的那一栏位置
function refreshTableView()
	local contentOffset = _rewardTableView:getContentOffset()
	local index= LevelRewardUtil.getFirstRewardIndex()
	print("index is :  ", index)

	contentOffset.y = contentOffset.y+ index*191

	_rewardTableView:setContentOffset(contentOffset)
end

-- 获取等级礼包的网络信息
local function rewardInfoCallback(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	_curRewardInfo = dictData.ret
	print_t(_curRewardInfo)
	LevelRewardUtil.setRewardInfo(_curRewardInfo)
	createTableView()

end


function createLevelRewardLayer()
	init()
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,-444,true)
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(_bgLayer,999,2013)

	-- 屏蔽层
	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(629,751)

	-- 等级礼包的背景
	local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    local levelRewardBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    levelRewardBg:setContentSize(mySize)
    levelRewardBg:setScale(myScale)
    levelRewardBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    levelRewardBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(levelRewardBg)

  --  createBgAction(levelRewardBg)

    -- 顶部的等级礼包
    local rewardTopSp = CCSprite:create("images/level_reward/level_reward_top.png")
    rewardTopSp:setPosition(ccp(levelRewardBg:getContentSize().width*0.5,levelRewardBg:getContentSize().height+10))
    rewardTopSp:setAnchorPoint(ccp(0.5,0.5))
    levelRewardBg:addChild(rewardTopSp,101)

    -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    levelRewardBg:addChild(menu)
    menu:setTouchPriority(-551)
    _closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    _closeBtn:setPosition(ccp(levelRewardBg:getContentSize().width*1.01, levelRewardBg:getContentSize().height*1.02))
    _closeBtn:setAnchorPoint(ccp(1,1))
    _closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(_closeBtn)

     -- 显示物品的灰色背景
    _rewardSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _rewardSpite:setContentSize(CCSizeMake(590,655))
    _rewardSpite:setPosition(ccp(levelRewardBg:getContentSize().width*0.5,38))
    _rewardSpite:setAnchorPoint(ccp(0.5,0))
    levelRewardBg:addChild(_rewardSpite,102)


    -- 创建TableView
   	_curRewardInfo = LevelRewardUtil.getRewardInfo()
    if(table.isEmpty(_curRewardInfo) ) then
    	RequestCenter.levelfund_getLevelfundInfo(rewardInfoCallback, nil)
    else
     	createTableView()
    end

end

-- 创建动画：背景打出屏幕得效果
function createBgAction( background)
	local args = CCArray:create()
	local scale1 = CCScaleBy:create(0.09,1.1)
	local scale2 = CCScaleBy:create(0.05,0.9)
    local scale3 = CCScaleTo:create(0.07,1)
    args:addObject(scale1)
--    args:addObject(scale2)
    args:addObject(scale3)

    background:runAction(CCSequence:create(args))
end


-- add by licong 2013.09.09
-------------------------------------
--table view 创建事件
function registerDidTableViewCallBack( callback )
	didCreateTableViewFunc = callback
end
--------------------end----------------

--add by lichenyang

function registerLevelRewardDidLoadCallback( p_callback )
	levelRewardDidLoadCallback = p_callback
end

function registerLevelRewardCloseCallback( p_callback )
	levelRewardLayerCloseCallback = p_callback
end


