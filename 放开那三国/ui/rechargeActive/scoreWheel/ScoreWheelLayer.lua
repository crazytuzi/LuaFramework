-- Filename：	ScoreWheelLayer.lua
-- Author：		DJN
-- Date：		2014-11-5
-- Purpose：    积分轮盘主界面


module ("ScoreWheelLayer", package.seeall)

-- require "script/utils/BaseUI"
-- require "script/ui/rechargeActive/RechargeActiveMain"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/utils/GoodTableView"
require "script/ui/rechargeActive/scoreWheel/ScoreWheelData"
require "script/ui/rechargeActive/scoreWheel/ScoreWheelService"
require "script/model/user/UserModel"
require "db/DB_Vip"
require "script/utils/TimeUtil"
require "script/model/utils/ActivityConfigUtil"
require "script/audio/AudioUtil"
require "script/ui/rechargeActive/scoreWheel/BoxLayer"
require "script/ui/tip/AnimationTip"
require "script/ui/item/ReceiveReward"
--require "script/model/utils/ActivityConfig"
local _bgLayer               --整个背景layer
local _packBackground        --主背景图片
local _touchPriority         --触摸优先级
local _zOrder                --z轴
local _pointerSprite         --转盘指针
local _selectedItemBg        --转盘被选中物品的背景
local _turntableBg           --转盘背景
-- local _turntableCenter       
local ONETAG  =  1           --menu 的tag
local TENTAG  =  10          --menu 的tag
local _updateTimer           --_selectedItemBg跟随指针的监听
local _firstTime       --记录进入这个界面后是否是第一次转动转盘，为指针设置偏移使用
local _confirmGold     --玩家是否确认花费金币并且金币够的tag
local _oneWheelBtn     --抽一次的按钮
local _tenWheelBtn     --抽十次的按钮
local _lineBottom      --下方UI依附的父节点，用于刷新
-- local _clockSound
local _oneLabel        --抽一次的文字label，因为免费次数用光后按钮上的的字需要刷新成用金币购买
local _node            --包装转盘和底部UI的node，用于适配，能都显示在屏幕内
local _freeTimeLabel   --剩余免费次数的label，刷新使用
local _goldTimeLabel   --剩余金币购买次数label，刷新用
local _scoreTime       --记录抽了几次，用于提示获得积分
local args             --用于给updateSignData传数据的参数  args[1]是消耗免费次数 args[2]是消耗金币购买次数 
local _canMenuAction   --记录是否正在执行转盘动作 转盘过程中不可以点其他按钮

function init()
	_bgLayer = nil
	_packBackground = nil
	_touchPriority = nil
	_zOrder = nil
	_pointerSprite = nil
	_selectedItemBg = nil
	_wheelTag = nil
	_updateTimer = nil
	_firstTime = true
	_confirmGold = false
	_oneWheelBtn = nil
	_tenWheelBtn = nil	
	_lineBottom = nil
	-- _clockSound = true
	_oneLabel = nil
	_node = nil
	_freeTimeLabel = nil
	_goldTimeLabel = nil
	_scoreTime = nil
	args = {}
	_canMenuAction = true
end
----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then

        return true
    elseif (eventType == "moved") then
        print("moved")
    else
        print("end")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
    	--SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
    	
        _bgLayer:unregisterScriptTouchHandler()
    end
end

-----------------------------[[ 节点事件 ]]------------------------------
function registerNodeEvent( ... )
	_pointerSprite:registerScriptHandler(function ( nodeType )
		if(nodeType == "exit") then
			if(_updateTimer ~= nil)then
			CCDirector:sharedDirector():getScheduler():setTimeScale(1)
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
			_selectedItemBg = nil
			end
		end
	end)
end
---------------------活动说明回调
function explainButtonCallFunc( ... )
	if(not _canMenuAction)then
		return
	end
	require "script/ui/rechargeActive/scoreWheel/WheelIntroLayer"
	WheelIntroLayer.showLayer(_touchPriority-20,_zOrder)

end
---------------------排行榜回调
function rankButtonCallFunc( ... )
	if(not _canMenuAction)then
		return
	end
	local callFun = function ( ... )
		require "script/ui/rechargeActive/scoreWheel/WheelRankLayer"
		WheelRankLayer.showLayer(_touchPriority - 20,_zOrder +10)
	end
	--if(ScoreWheelData.isInWheel())then
		--还在可转盘的期间。登陆的时候没拉排行数据，这里要拿
	ScoreWheelService.getRankInfo(callFun)
	--else
	--end
	
end
---------------------点击转盘上的icon的回调，做奖励预览展示
function itemIconClickCb(tag)
	if(not _canMenuAction)then
		return
	end
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local scoreWheelPreList = ScoreWheelData.getItemPreviewList(tag)
	ReceiveReward.showRewardWindow(scoreWheelPreList,nil,_zOrder+1,_touchPriority-20,GetLocalizeStringBy("djn_125"))
end
------------updatetimer 回调
function updateTimeFunc( ... )
	--AudioUtil.playEffect("audio/effect/zhuanpan01.mp3")
	local pr = _pointerSprite:getRotation()
	if(tonumber(pr) > 1080)then
		CCDirector:sharedDirector():getScheduler():setTimeScale(1.5)
	end
	local oldRotation = _selectedItemBg:getRotation()
	local mod = math.mod(oldRotation,360)
	--print("输出rotation",pr)
	local sr = math.floor((pr)/36) * 36 +18
	local srMod = math.mod(sr,360)

	if(srMod < mod )then
		AudioUtil.playEffect("audio/effect/zhuanpan02.mp3")
	end
	
	if(oldRotation ~= sr)then
       AudioUtil.playEffect("audio/effect/zhuanpan01xiugai.mp3")
	end
	_selectedItemBg:setRotation(sr)
end
--点击宝箱的回调
function BoxCallback(tag )
	--print("box传来的tag",tag)
	if(not _canMenuAction)then
		return
	end
	BoxLayer.showLayer(tag,_touchPriority-20,_zOrder)
end
--点击转盘按钮的回调
function ButtonCallback( tag )
	--2014/7/31改了需求 没有金币购买次数限制的上限了  所以一些goldtime的逻辑被注释掉
	
	local rouletteFun = function ( ... )
		--SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
		
	  --  print("执行roulettefunc")
		local vip = tonumber(UserModel.getVipLevel())
		local todayFreemNum = tonumber(DB_Vip.getDataById(vip+1).FreeTimes)
		--local totalGoldNum = tonumber(DB_Vip.getDataById(vip+1).Totalnum)
		local signData = ScoreWheelData.getSignData()
		if(tonumber(tag) == ONETAG )then

			--获取玩家vip等级下今天可以免费抽多少次，如果有剩余，就抽，没有剩余，提示是否用金币抽     
            if(tonumber(signData.today_free_num) < todayFreemNum)then
            	--print("用免费次数抽一次")
            	--AudioUtil.playBgm("audio/effect/zhuanpan01.mp3")
                _oneWheelBtn:setEnabled(false)
				_tenWheelBtn:setEnabled(false)
                _scoreTime = 1
				--ScoreWheelService.Roulette(1,ScoreWheelService.getRouletteInfo,refreshDataLabelForOne)
				args[1] = 1
				args[2] = 0

				ScoreWheelService.Roulette(1,ScoreWheelData.updateSignData,args,refreshDataLabelForOne)
			else
			--if(tonumber(totalGoldNum - tonumber(signData.accum_gold_num)) >= 1 )then
				
				local calBack = function ( ... )
					if(_confirmGold == true)then
					--print("花金币抽一次")
					--AudioUtil.playBgm("audio/effect/zhuanpan01.mp3")
					_confirmGold = false

					_oneWheelBtn:setEnabled(false)
					_tenWheelBtn:setEnabled(false)
                    _scoreTime = 1
					--ScoreWheelService.Roulette(1,ScoreWheelService.getRouletteInfo,refreshDataLabelForOne)
					args[1] = 0
					args[2] = 1
					ScoreWheelService.Roulette(1,ScoreWheelData.updateSignData,args,refreshDataLabelForOne)
					end
				end
				
				showGoldAlert(1,calBack)
			-- else
			-- 	AnimationTip.showTip(GetLocalizeStringBy("djn_90"))
			end
				
		elseif(tonumber(tag)== TENTAG)then
			local free = todayFreemNum - tonumber(signData.today_free_num)
			--local goldTime = totalGoldNum - tonumber(signData.accum_gold_num)
			--print("goldnum当前为",goldTime)
			if(free >= 10)then
				--免费次数够10次，全用免费次数
				--print("用免费次数抽十次")
				_oneWheelBtn:setEnabled(false)
				_tenWheelBtn:setEnabled(false)
				_scoreTime = 10

				--ScoreWheelService.Roulette(10,ScoreWheelService.getRouletteInfo,refreshDataLabelForTen)
				args[1] = 10
				args[2] = 0
				ScoreWheelService.Roulette(10,ScoreWheelData.updateSignData,args,refreshDataLabelForTen)
				
			elseif( free > 0)then
				--部分使用免费次数
				--print("部分使用免费次数")
				local needGold = 10 - free
				-- if(goldTime >= needGold)then
					
				-- else
				-- 	--不能抽十次了，能抽多少次抽多少次
				-- 	needGold = goldTime
				-- end

				local callBack = function ( ... )
					if(_confirmGold == true)then
					   -- print("扣完金币可以抽奖")					
						_confirmGold = false					
						local needGold = 10 - free
						--print("加上花金币，共抽",free+goldTime)
						_oneWheelBtn:setEnabled(false)
						_tenWheelBtn:setEnabled(false)
						_scoreTime = free+needGold
						--ScoreWheelService.Roulette(tonumber(free+needGold),ScoreWheelService.getRouletteInfo,refreshDataLabelForTen)
						args[1] = free
						args[2] = needGold
						ScoreWheelService.Roulette((free+needGold),ScoreWheelData.updateSignData,args,refreshDataLabelForTen)
					end
				end

				showGoldAlert(needGold,callBack)
	
			else
				--已经没有免费次数
				--if(goldTime >= 10)then
					--print("金币剩余次数够10次")
				local callBack = function ( ... )
					if(_confirmGold == true)then
						--print("扣完金币可以抽奖")	
						_confirmGold = false
						--print("纯花金币抽10次")
						_oneWheelBtn:setEnabled(false)
						_tenWheelBtn:setEnabled(false)
						_scoreTime = 10

						--ScoreWheelService.Roulette(10,ScoreWheelService.getRouletteInfo,refreshDataLabelForTen)
						args[1] = 0
						args[2] = 10
						ScoreWheelService.Roulette(10,ScoreWheelData.updateSignData,args,refreshDataLabelForTen)
					end
				end
				showGoldAlert(10,callBack)

					
				-- elseif(goldTime >0)then
				-- 	--print("金币剩余不够10次，有几次抽几次")
				-- 	--print("goldnum当前为",goldTime)
				-- 	local callBack = function ( ... )
				-- 		if(_confirmGold == true)then
				-- 			_confirmGold = false
				-- 			--print("纯花金币抽次--",goldTime)
				-- 			_oneWheelBtn:setEnabled(false)
				-- 			_tenWheelBtn:setEnabled(false)
				-- 			_scoreTime = goldTime
				-- 			--ScoreWheelService.Roulette(tonumber(goldTime),ScoreWheelService.getRouletteInfo,refreshDataLabelForTen)
				-- 			args[1] = 0
				-- 			args[2] = goldTime
				-- 			ScoreWheelService.Roulette(goldTime,ScoreWheelData.updateSignData,args,refreshDataLabelForTen)
				-- 		end
				-- 	end
				-- 	showGoldAlert(goldTime,callBack)
					
				-- else
				-- 	--print("金币抽奖次数也没了")
				-- 	AnimationTip.showTip(GetLocalizeStringBy("djn_90"))
				--end
			end
		else
			--tag不是抽一次也不是抽十次 暂无处理
		end
		
	end
	-- print("选中的tag",tag)
	--最先判断是否在可转盘期
	if(ScoreWheelData.isInWheel())then
	    --判断背包是否已经满了
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		if (ScoreWheelData.isAllBagFull() )then
	        --背包满，不做操作，给提示
		else
			--ScoreWheelService.getRouletteInfo(rouletteFun)
			rouletteFun()
		end
	else
		---给提示，不可转了
		AnimationTip.showTip(GetLocalizeStringBy("djn_158"))
	end

end
--设置_confirmtag
function setConfirmTag( p_tag )
	_confirmGold = p_tag
end
--弹出是否确认花费金币
function showGoldAlert(p_time, calback)
   require "script/ui/rechargeActive/scoreWheel/AlertGold"
   AlertGold.showLayer(p_time,calback,_touchPriority-30)
end

--弹出抽到的物品面板
function showItemList ( ... )
		AudioUtil.playEffect("audio/effect/zhuanpan03.mp3")
        _oneWheelBtn:setEnabled(true)
	    _tenWheelBtn:setEnabled(true)
       
       local scoreWheelResult = ScoreWheelData.getWheelData()
		-- print("showItemList 输出获取的抽奖结果")
		-- print_t(scoreWheelResult)
		local tableCount = table.count(scoreWheelResult)
		local itemData = {}	
        --local item = ItemUtil.getItemsDataByStrByBack(scoreWheelResult)
        local item = ItemUtil.getItemsDataByStr(nil,scoreWheelResult)
        itemData = item
		ReceiveReward.showRewardWindow(itemData,nil ,_zOrder,_touchPriority-30)
		--showScore()
		
end
--展示获取多少积分
function showScore( ... )
	if(_scoreTime ~= nil)then
		_scoreTime = tonumber(_scoreTime)
		AnimationTip.showTip(GetLocalizeStringBy("key_1248").._scoreTime*tonumber(ActivityConfig.ConfigCache.roulette.data[1]["WheelScore"])..GetLocalizeStringBy("djn_86"),0.8)
	end
end
--转盘动作
function raffleAction( p_index )
	_canMenuAction = false
	_updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimeFunc, 0.01, false)

	local raffleInfo = nil
	local old = _pointerSprite:getRotation()%360
	
	-- local itemsInfo = ScoreWheelData.getItemsForAction()
	-- print("itemsInfo")
	-- print_t(itemsInfo)
	-- local r = 0
	-- for i=1,#itemsInfo do
	-- 	local v = itemsInfo[i]
	-- 	if(tonumber(v[2]) == tonumber(p_tid)) then
	-- 		raffleInfo = v
	-- 		break
	-- 	end
	-- 	r = r + 36
	-- end
	local r = tonumber(p_index)*36 - 36
	r = r + 360 * 4 + (360 - old) + 18
	if(_firstTime)then

		_selectedItemBg:setRotation(18)
		_selectedItemBg:setVisible(true)
		--_selectedItemBg:setRotation(18)
		
		_firstTime = false
	end
	local rotationAction = CCRotateBy:create(10, r)
	-- local easeAction     = CCEaseInOut:create(rotationAction, 4)
	-- easeAction:reverse()

	local easeAction     = CCEaseExponentialOut:create(rotationAction)


    local clearTimer = function ( ... )
        --print("函数中解除绑定")
    	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
    	CCDirector:sharedDirector():getScheduler():setTimeScale(1)
    	_updateTimer = nil
    	_canMenuAction = true
    end
	local actionArray = CCArray:create()
	actionArray:addObject(easeAction)
	actionArray:addObject(CCCallFunc:create(showItemList))
	actionArray:addObject(CCCallFunc:create(refreshOtherUi))
	actionArray:addObject(CCCallFunc:create(showScore))
	actionArray:addObject(CCCallFunc:create(clearTimer))
	local seqAction =	CCSequence:create(actionArray)
	 
	_pointerSprite:runAction(seqAction)

end

--创建转盘
function createTurntable( ... )
	_turntableBg = CCSprite:create("images/recharge/score_wheel/circle.png")
	_turntableBg:setAnchorPoint(ccp(0.5,1))
	_turntableBg:setScale(1.3)
	_turntableBg:setPosition(_node:getContentSize().width/2 , _node:getContentSize().height+5)
    _node:addChild(_turntableBg)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	menu:setTouchPriority(_touchPriority -10)
	_turntableBg:addChild(menu,2)

    
    _oneWheelBtn = CCMenuItemImage:create("images/recharge/score_wheel/pauseUp_n.png","images/recharge/score_wheel/pauseUp_h.png")
    _oneWheelBtn:setAnchorPoint(ccp(0.5,0))
    _oneWheelBtn:setPosition(ccp(_turntableBg:getContentSize().width/2, _turntableBg:getContentSize().height/2+10))
    menu:addChild(_oneWheelBtn)
    _oneWheelBtn:registerScriptTapHandler(ButtonCallback)
    _oneWheelBtn:setTag(ONETAG)


    _tenWheelBtn = CCMenuItemImage:create("images/recharge/score_wheel/pauseDown_n.png","images/recharge/score_wheel/pauseDown_h.png")
    _tenWheelBtn:setAnchorPoint(ccp(0.5,1))
    _tenWheelBtn:setPosition(ccp(_turntableBg:getContentSize().width/2, _turntableBg:getContentSize().height/2-10))
    menu:addChild(_tenWheelBtn)
    _tenWheelBtn:registerScriptTapHandler(ButtonCallback)
    _tenWheelBtn:setTag(TENTAG)

  
	local tenLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_85"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tenLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	tenLabel:setAnchorPoint(ccp(0.5,0))
	tenLabel:setPosition(ccp(_tenWheelBtn:getContentSize().width *0.5,40))
	_tenWheelBtn:addChild(tenLabel)

    local tenTimeGoldSprite = CCNode:create()
	local tenTimeGoldNum = CCRenderLabel:create(ScoreWheelData.getOneCost()*10,g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tenTimeGoldNum:setColor(ccc3(0xff,0xff,0xff))
	tenTimeGoldNum:setAnchorPoint(ccp(0,0.5))
	tenTimeGoldNum:setPosition(ccp(0,tenTimeGoldNum:getContentSize().height *0.5))
	tenTimeGoldSprite:addChild(tenTimeGoldNum)

	local goldSprite = CCSprite:create("images/common/gold.png")
	goldSprite:setAnchorPoint(ccp(0,0.5))
	goldSprite:setPosition(ccp(tenTimeGoldNum:getContentSize().width,tenTimeGoldNum:getPositionY()))
	tenTimeGoldSprite:addChild(goldSprite)

	tenTimeGoldSprite:setContentSize(CCSizeMake(goldSprite:getContentSize().width + tenTimeGoldNum:getContentSize().width,goldSprite:getContentSize().height))
    tenTimeGoldSprite:ignoreAnchorPointForPosition(false)
    tenTimeGoldSprite:setAnchorPoint(ccp(0.5,0))
	tenTimeGoldSprite:setPosition(ccp(_tenWheelBtn:getContentSize().width *0.5,15))
	_tenWheelBtn:addChild(tenTimeGoldSprite)


	_pointerSprite = CCSprite:create("images/recharge/score_wheel/pointer.png")
	_pointerSprite:setPosition(_turntableBg:getContentSize().width/2, _turntableBg:getContentSize().height/2)
	_pointerSprite:setAnchorPoint(ccp(0.5, -0.9))
	_turntableBg:addChild(_pointerSprite,3)
		
	local itemsInfo = ScoreWheelData.getRaffleItems()
	local count = table.count(itemsInfo)
	local ox,oy = _turntableBg:getContentSize().width/2 ,_turntableBg:getContentSize().height/2
	local iconMenuItem = {}
	for i = 1,#itemsInfo do
		local v = ItemUtil.getItemsDataByStr(itemsInfo[i])
	    local rotation =math.rad(i * 360/count + 54 + 18) 
   		local moveDis = -170
	    local nx = math.cos(rotation) 	* moveDis + ox + 5
    	local ny = - math.sin(rotation) * moveDis + oy + 10

    	-- 按钮外框
    	local item = ItemUtil.createGoodsIcon(v[1],nil,nil,nil,nil,nil,true)
    	item:setScale(0.8)
  		-- local item = ItemSprite.getItemSpriteByItemId(tonumber(v[1].tid))
  		iconMenuItem[i] = CCMenuItemSprite:create(item,item)
		iconMenuItem[i]:setPosition(nx, ny)
		iconMenuItem[i]:setAnchorPoint(ccp(0.5, 0.5))
		menu:addChild(iconMenuItem[i])
		iconMenuItem[i]:registerScriptTapHandler(itemIconClickCb)
		iconMenuItem[i]:setTag(i)

		--_turntableBg:addChild(item, 2)
		
	end

	_selectedItemBg = CCSprite:create("images/recharge/score_wheel/selected.png")
	_selectedItemBg:setPosition(_turntableBg:getContentSize().width/2, _turntableBg:getContentSize().height/2)
	_selectedItemBg:setAnchorPoint(ccp(0.5, -1.4))
	_selectedItemBg:setVisible(false)
	_turntableBg:addChild(_selectedItemBg,1)

	
end
--创建其他不需要刷新的ui
function  createOtherUi( ... )
	 -- 上面的花边
  
    local border_filename = "images/recharge/mystery_merchant/border.png"
    _border_top = CCSprite:create(border_filename)
    _packBackground:addChild(_border_top,1,1)

    _border_top:setAnchorPoint(ccp(0.5,0))
    
    _border_top:setScale(g_fScaleX)
    _border_top:setScaleY(-g_fScaleX)
   
    --local border_top_y = g_winSize.height - bulletinLayerSize.height * g_fScaleX - activeMainWidth
    _border_top:setPosition( _packBackground:getContentSize().width*0.5, _packBackground:getContentSize().height)

    -- 下面的花边
    local menuLayerSize = MenuLayer.getLayerContentSize()
    _border_bottom = CCSprite:create(border_filename)
    _packBackground:addChild(_border_bottom,1,1)

    _border_bottom:setAnchorPoint(ccp(0.5, 0))
     _border_bottom:setScale(g_fScaleX)
    --local border_bottom_y = menuLayerSize.height * g_fScaleX
    _border_bottom:setPosition( _packBackground:getContentSize().width *0.5,0)

    local introMenu = CCMenu:create()
	introMenu:setPosition(ccp(0, 0))
	introMenu:setAnchorPoint(ccp(0, 0))
	introMenu:setTouchPriority(_touchPriority-5)
	_packBackground:addChild(introMenu,1,1)


    local explainButton = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
	explainButton:setAnchorPoint(ccp(1, 1))
	explainButton:registerScriptTapHandler(explainButtonCallFunc)
	explainButton:setScale(g_fScaleX)
	explainButton:setPosition(ccp(_packBackground:getContentSize().width -5,_packBackground:getContentSize().height -5))
	introMenu:addChild(explainButton,1)

	local noteSprite = CCSprite:create("images/recharge/score_wheel/jifen.png")
	noteSprite:setAnchorPoint(ccp(0,1))
	noteSprite:setPosition(ccp(5,_packBackground:getContentSize().height -15))
	noteSprite:setScale(g_fScaleX)
	_packBackground:addChild(noteSprite,1,2)

	local rankButton = CCMenuItemImage:create("images/recharge/score_wheel/rank_btn_n.png","images/recharge/score_wheel/rank_btn_h.png")
	rankButton:setAnchorPoint(ccp(0, 1))
	rankButton:registerScriptTapHandler(rankButtonCallFunc)
	rankButton:setScale(g_fScaleX)
	rankButton:setPosition(ccp(5,noteSprite:getPositionY() - noteSprite:getContentSize().height - 20 ))
	introMenu:addChild(rankButton,1)



end
--刷新界面上的积分、次数等显示 抽一次的
function refreshDataLabelForOne( ... )
	-- print("转盘结果")
	-- print_t(ScoreWheelData.getWheelData())
	local scoreWheelResult = (ScoreWheelData.getWheelData())[1].point
	--local tid = tonumber(scoreWheelResult[1].id)
	raffleAction(scoreWheelResult)
  
end
--刷新界面上的积分、次数等显示  抽十次的
function refreshDataLabelForTen( ... )
	--本来一次和十次的动作是相同的，期间策划改需求，一度相同，一度不同，所以分开写了
    --local scoreWheelResult = (ScoreWheelData.getWheelData())[1].point
	-- local tid = tonumber(scoreWheelResult[1].id)
	--raffleAction(scoreWheelResult)
	showItemList()
	showScore()
	refreshOtherUi()
	
  
end
--创建或刷新那些需要数据刷新的ui，主要在转盘下方
function refreshOtherUi( ... )
	if(_lineBottom ~= nil)then
		_lineBottom:removeFromParentAndCleanup(true)
		_lineBottom = nil
	end
	local lineBottom = CCSprite:create("images/recharge/score_wheel/rateBottom.png")
	lineBottom:setScaleX(1.1)

	_lineBottom = CCNode:create()
	_lineBottom:addChild(lineBottom)
	
	lineBottom:setAnchorPoint(ccp(0.5,0))
	_lineBottom:setContentSize(lineBottom:getContentSize())
	lineBottom:setPosition(ccp(_lineBottom:getContentSize().width * 0.5,0))
	--_lineBottom = CCSprite:create("images/recharge/score_wheel/rateBottom.png")
	_lineBottom:setAnchorPoint(ccp(0.5,0))
	_lineBottom:setPosition(ccp(_node:getContentSize().width/2,130))
	--_lineBottom:setScaleX(1.2)
	_node:addChild(_lineBottom)
	--_lineBottom:setPosition(ccp(_packBackground:getContentSize().width/2,280))
	
	--_packBackground:addChild(_lineBottom)
    --_lineBottom:setScale(MainScene.elementScale)
	local signInfo = ScoreWheelData.getSignData()

	local oneStr = ""
	local vip = tonumber(UserModel.getVipLevel())
	--print("获取的vip",vip)
	local todayFreemNum = tonumber(DB_Vip.getDataById(vip+1).FreeTimes)
	--local totalGoldNum = tonumber(DB_Vip.getDataById(vip+1).Totalnum)
	local oneTimeGoldSprite = nil
	if(tonumber(signInfo.today_free_num) < todayFreemNum)then
		oneStr = GetLocalizeStringBy("djn_84")
	else
		oneStr = GetLocalizeStringBy("key_1773")
		oneTimeGoldSprite = CCNode:create()
		local oneTimeGoldNum = CCRenderLabel:create(ScoreWheelData.getOneCost(),g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		oneTimeGoldNum:setColor(ccc3(0xff,0xff,0xff))
		oneTimeGoldNum:setAnchorPoint(ccp(0,0.5))
		oneTimeGoldNum:setPosition(ccp(0,oneTimeGoldNum:getContentSize().height *0.5))
	    oneTimeGoldSprite:addChild(oneTimeGoldNum)

	    local goldSprite = CCSprite:create("images/common/gold.png")
	    goldSprite:setAnchorPoint(ccp(0,0.5))
	    goldSprite:setPosition(ccp(oneTimeGoldNum:getContentSize().width,oneTimeGoldNum:getPositionY()))
	    oneTimeGoldSprite:addChild(goldSprite)

	    oneTimeGoldSprite:setContentSize(CCSizeMake(goldSprite:getContentSize().width + oneTimeGoldNum:getContentSize().width,goldSprite:getContentSize().height))

	end
	if(_oneLabel ~= nil)then
		_oneLabel:removeFromParentAndCleanup(true)
		_oneLabel = nil
	end
	_oneLabel = CCRenderLabel:create(oneStr, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_oneLabel:setAnchorPoint(ccp(0.5,0))
	_oneLabel:setPosition(ccp(_oneWheelBtn:getContentSize().width*0.5,20))
	_oneLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_oneWheelBtn:addChild(_oneLabel)

	if(oneTimeGoldSprite ~= nil)then
		oneTimeGoldSprite:ignoreAnchorPointForPosition(false)
		oneTimeGoldSprite:setAnchorPoint(ccp(0.5,0))
		oneTimeGoldSprite:setPosition(ccp(_oneWheelBtn:getContentSize().width *0.5,50))
		_oneWheelBtn:addChild(oneTimeGoldSprite)
		
	end
    
	local freeeNum = todayFreemNum - tonumber(signInfo.today_free_num)
	if(freeeNum <0 )then
		freeeNum = 0
	end
	_freeTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_88")..freeeNum, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_freeTimeLabel:setColor(ccc3(0xff,0xff,0xff))
	_freeTimeLabel:setAnchorPoint(ccp(0.5,1))
	_freeTimeLabel:setPosition(ccp(_oneLabel:getContentSize().width *0.5,-20))
	_oneLabel:addChild(_freeTimeLabel)

	-- local goldNum = totalGoldNum - tonumber(signInfo.accum_gold_num)
	-- if(goldNum < 0)then
	-- 	goldNum = 0
	-- end
	-- local goldTimeStr = CCRenderLabel:create(GetLocalizeStringBy("djn_89"), g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- goldTimeStr:setColor(ccc3(0xff,0xff,0xff))
	-- goldTimeStr:setAnchorPoint(ccp(0,0.5))
	-- goldTimeStr:setPosition(ccp(_lineBottom:getContentSize().width*0.65,60))
	-- _lineBottom:addChild(goldTimeStr)

	-- _goldTimeLabel = CCRenderLabel:create(goldNum, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- _goldTimeLabel:setColor(ccc3(0x00,0xff,0x18))
	-- _goldTimeLabel:setAnchorPoint(ccp(0,0.5))
	-- _goldTimeLabel:setPosition(ccp(goldTimeStr:getContentSize().width ,goldTimeStr:getContentSize().height *0.5))
	-- goldTimeStr:addChild(_goldTimeLabel)
	
	-- local tip = CCSprite:create("images/recharge/score_wheel/rateLine.png")
	-- tip:setAnchorPoint(ccp(0.5,0))
	-- tip:setPosition(ccp(_lineBottom:getContentSize().width*0.5,5))
	-- _lineBottom:addChild(tip,2,3)

  
    -- 积分进度条
    ----对越界积分要做处理
    local boxId = ScoreWheelData.getBoxId()
	--print("输出解析的所有积分")
	--print_t(boxId)
	local scoreA = tonumber(boxId[1][2])
	local scoreB = tonumber(boxId[2][2])
	local scoreC = tonumber(boxId[3][2])
	--print("输出解析的三个积分",scoreA,scoreB,scoreC)
    local score = tonumber(signInfo.integeral)
    local lenghRate = 0
    if(score >= scoreA and score <= scoreC)then
		if(score <= scoreB)then
			lenghRate = 0.5*(score - scoreA )/(scoreB - scoreA)
        else
        	lenghRate = 0.5 + 0.5*(score - scoreB )/(scoreC - scoreB)
        end
    elseif(score > scoreC) then
    	lenghRate  = 1
	end

	local line = CCSprite:create("images/recharge/score_wheel/rate.png")
	line:setAnchorPoint(ccp(0,0))
	line:setPosition(ccp(25,13))
	line:setScaleX(lenghRate*1.1)
	_lineBottom:addChild(line)



    local boxInfo = signInfo.va_boxreward
    local PATH = "images/copy/reward/box/"
    local pathTable = {"box_copper_","box_silver_","box_gold_"}
    local layerSprite = {"images/base/effect/copy/copperBox/tongxiangzi","images/base/effect/copy/silverBox/yinxiangzi","images/base/effect/copy/goldBox/jinxiangzi"}
    local colors = {ccc3(0x00, 0xff, 0x18),ccc3(0x00, 0xe4, 0xff),ccc3(0xe4, 0x00, 0xff)}
    -- print("后端箱子信息")
    -- print_t(boxInfo)

    local boxMenu = CCMenu:create()
	boxMenu:setPosition(ccp(0, 0))
	boxMenu:setAnchorPoint(ccp(0, 0))
	boxMenu:setTouchPriority(_touchPriority -10)
	_lineBottom:addChild(boxMenu)

	local boxMenuItem = {}
	local scoreStrLabel = {}

    for i=1,3 do
    	--local j = tostring(i-1)
    	--print("当前箱子索引",i)
    	print_t(boxInfo[i])
    	local boxTag = boxInfo[i].status
    	
    	local boxPath_n = PATH..pathTable[i]..boxTag.."_n.png"
    	local boxPath_h = PATH..pathTable[i]..boxTag.."_h.png"
    	--print("输出箱子路径",boxPath_n)
    	boxMenuItem[i] = CCMenuItemImage:create(boxPath_n,boxPath_h)
    	boxMenuItem[i]:setAnchorPoint(ccp(0.5,1))
    	boxMenuItem[i]:setPosition(ccp((i-1)/2*_lineBottom:getContentSize().width + (i-2)*5,50))
    	boxMenu:addChild(boxMenuItem[i])
    	boxMenuItem[i]:setScale(1.1)
    	boxMenuItem[i]:registerScriptTapHandler(BoxCallback)
    	boxMenuItem[i]:setTag(i)
  
        if(tonumber(boxTag)==2)then
			-- 铜宝箱
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(layerSprite[i]), -1,CCString:create(""))
		    --spellEffectSprite:retain()
		    spellEffectSprite:setPosition(boxMenuItem[i]:getContentSize().width*0.5,boxMenuItem[i]:getContentSize().height*0.5+5)
		    boxMenuItem[i]:addChild(spellEffectSprite)
		    --spellEffectSprite:release()
		end
       
    	scoreStrLabel[i] = CCRenderLabel:create(boxId[i][2]..GetLocalizeStringBy("djn_86"),g_sFontName,23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        
    	scoreStrLabel[i]:setColor(colors[i])
    	scoreStrLabel[i]:setAnchorPoint(ccp(0.5,0))
    	scoreStrLabel[i]:setPosition(ccp(boxMenuItem[i]:getContentSize().width*0.5,-10))
    	boxMenuItem[i]:addChild(scoreStrLabel[i])

    end
    --当前积分
	local scoreStr = CCRenderLabel:create(GetLocalizeStringBy("djn_79"), g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	scoreStr:setColor(ccc3(0xff, 0xf6, 0x00))
	scoreStr:setPosition(ccp(-10,80))
	_lineBottom:addChild(scoreStr)
	local info = signInfo.integeral or ""
	local scoreNum = CCRenderLabel:create(info, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	scoreNum:setColor(ccc3(0x00, 0xff, 0x18))
	scoreNum:setPosition(ccp(scoreStr:getContentSize().width+5,scoreStr:getContentSize().height))
	scoreStr:addChild(scoreNum)

	-- local noteStr = CCRenderLabel:create(GetLocalizeStringBy("djn_80"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- noteStr:setColor(ccc3(0xff, 0xf6, 0x00))
	-- noteStr:setAnchorPoint(ccp(0.5,0))
	-- noteStr:setPosition(ccp(_lineBottom:getContentSize().width/2,-140))
	-- _lineBottom:addChild(noteStr)
	local titleLabel = CCRenderLabel:create("",g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleLabel:setColor(ccc3(0x00, 0xff, 0x18))
	titleLabel:setAnchorPoint(ccp(0.5,0))
	titleLabel:setPosition(ccp(_lineBottom:getContentSize().width/2,-100))
	_lineBottom:addChild(titleLabel)	
	local refreshTitleLabel = function ( ... )
		local timeStr = nil
	    if(ScoreWheelData.isInWheel())then
			local startTime = ActivityConfigUtil.getDataByKey("roulette").start_time
			startTime = TimeUtil.getTimeFormatChnYMDHM(startTime) 
			--local endTime = ActivityConfigUtil.getDataByKey("roulette").end_time
			local endTime = ScoreWheelData.getWheelEndTime()
			endTime = TimeUtil.getTimeFormatChnYMDHM(endTime) 
			timeStr = GetLocalizeStringBy("key_2707")..startTime..GetLocalizeStringBy("djn_81")..endTime
		else
			timeStr = GetLocalizeStringBy("djn_169")
		end
		titleLabel:setString(timeStr)
	end   
	refreshTitleLabel()

	local timeNode = CCNode:create()
	local intervalTime = ScoreWheelData.getWheelEndTime()- tonumber(TimeUtil.getSvrTimeByOffset())
	local titmeTitleStr = nil
	local isInWheel = ScoreWheelData.isInWheel()
    if(isInWheel)then
		intervalTime = ScoreWheelData.getWheelEndTime()- tonumber(TimeUtil.getSvrTimeByOffset())
		titmeTitleStr = GetLocalizeStringBy("djn_167")
	else
		intervalTime = tonumber(ActivityConfigUtil.getDataByKey("roulette").end_time)- tonumber(TimeUtil.getSvrTimeByOffset())
        titmeTitleStr = GetLocalizeStringBy("djn_168")
	end
	intervalTime = TimeUtil.getTimeDesByInterval(intervalTime)
	local timeTitle = CCRenderLabel:create(titmeTitleStr,g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	timeTitle:setColor(ccc3(0x00, 0xff, 0x18))
	timeTitle:setAnchorPoint(ccp(0,0.5))
	timeNode:addChild(timeTitle)

    local timeLabel = CCRenderLabel:create(intervalTime,g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    timeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    timeLabel:setPosition(timeTitle:getContentSize().width+2,timeTitle:getPositionY())
    timeLabel:setAnchorPoint(ccp(0,0.5))
    
    timeNode:addChild(timeLabel)

    timeNode:setContentSize(CCSizeMake(timeLabel:getContentSize().width+timeTitle:getContentSize().width,timeLabel:getContentSize().height))
    --timeNode:ignoreAnchorPointForPosition(false)

    timeNode:setAnchorPoint(ccp(0.5,1))
    timeNode:setPosition(ccp(_lineBottom:getContentSize().width/2,titleLabel:getPositionY()+10))
    _lineBottom:addChild(timeNode)
    
    --离开时间倒计时 
	local updateTime = function ( ... )
		local curTime = TimeUtil.getSvrTimeByOffset()
		local leftTime = nil
		if(isInWheel)then
			leftTime = ScoreWheelData.getWheelEndTime() - TimeUtil.getSvrTimeByOffset()
			if leftTime <= 0 then
				isInWheel = false
				-- timeNode:cleanup()
				refreshTitleLabel()
				timeTitle:setString(GetLocalizeStringBy("djn_168"))
			end
		else
			leftTime = tonumber(ActivityConfigUtil.getDataByKey("roulette").end_time)- tonumber(TimeUtil.getSvrTimeByOffset())
		end
		--leftTime = leftTime < 0 and 0 or leftTime
		
		local timeStr = TimeUtil.getTimeDesByInterval(leftTime)
		timeLabel:setString(timeStr)
	end
	
	--倒计时动作
	schedule(timeNode, updateTime, 1)
	
end
--创建背景
-----------------------------
function createLayer( p_index )

    if( _packBackground ~= nil ) then
		_packBackground:removeFromParentAndCleanup(true)
		_packBackground = nil
	end
	_packBackground = CCScale9Sprite:create("images/recharge/mystery_merchant/bg.png")
	-- _layer:setScale(1/MainScene.elementScale)

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	require "script/ui/rechargeActive/RechargeActiveMain"
	
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()-15*g_fScaleX

	_packBackground:setContentSize(CCSizeMake(g_winSize.width,height))
    _bgLayer:setContentSize(CCSizeMake(g_winSize.width,height))
	--_packBackground:setContentSize(CCSizeMake(640,960))
	_packBackground:setPosition(ccp(0,menuLayerSize.height*g_fScaleX+15*g_fScaleX))
    _bgLayer:addChild(_packBackground)
    

	_node = CCLayer:create()
	_node:ignoreAnchorPointForPosition(false)
	_node:setAnchorPoint(ccp(0.5,0.5))
	_node:setPosition(ccp(g_winSize.width*0.5,height*0.5))
	_node:setContentSize(CCSizeMake(700,830))
	_packBackground:addChild(_node,2,3)

	local maxScaleX = g_winSize.width / 700
	local maxScaleY = height / 830
	_node:setScale(math.min(maxScaleX,maxScaleY))

	createOtherUi()
	createTurntable()	
    refreshOtherUi()

	registerNodeEvent()
	
end

--返回当前页面touchpriority
function getTouchPriority( ... )
	return _touchPriority
end
-----入口函数
function showLayer(p_touchPriority,p_zOrder)
	init()
	_touchPriority = p_touchPriority or -389
	_zOrder = p_zOrder or 999
	_bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
	ScoreWheelService.getRouletteInfo(createLayer)
	return _bgLayer

end



