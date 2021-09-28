-- FileName: WorldArenaMainLayer.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 巅峰对决主界面
--[[TODO List]]

module("WorldArenaMainLayer", package.seeall)

require "script/ui/WorldArena/WorldArenaMainService"
require "script/ui/WorldArena/WorldArenaMainData"
require "script/ui/WorldArena/WorldArenaController"
require "script/ui/WorldArena/WorldArenaUtil"
require "script/ui/WorldArena/WorldArenaBody"

local _bgLayer 							= nil   
local _bgSprite  						= nil
local _topSprite 						= nil
local _killFont 						= nil
local _killFontNum 						= nil
local _curContiFont 					= nil
local _curContiFontNum 					= nil
local _maxContiFont 					= nil
local _maxContiFontNum 					= nil
local _protectFont 						= nil
local _protectTimeLabel 				= nil
local _challengeFont					= nil
local _challengeFontNum					= nil
local _goldResetCostFont 				= nil
local _silverResetCostFont 				= nil
local _silverResetFont 					= nil
local _silverResetFontNum 				= nil
local _skipMenuItem 					= nil
local _skipSprite 						= nil
local _goldResetMenuItem  				= nil
local _silverResetMenuItem   			= nil
local _protectFontNum 					= nil
local _buyMenuItem 						= nil
local _moveMaskLayer 					= nil
local _balckLayer 						= nil
local _allMenuItem 						= nil
local _allMenuBg 						= nil
local _allMenuMaksLayer 				= nil
local _timeDesNode 						= nil
local _challengeCDFont 					= nil
local _challengeCDFontNum 				= nil

local _playerSpriteTab 					= {}

local _playerInfo 						= nil
local _protectTime 						= nil
local _challengeCDTime 					= nil

local _menu_priority 					= -405

-- 人物坐标
local  _posX = {0.17,0.5,0.83,0.5}
local  _posY = {0.6,0.6,0.6,0.1}

--[[
	@des 	:初始化
--]]
function init( ... )
	_bgLayer 							= nil
	_bgSprite 							= nil
	_topSprite 							= nil
	_killFont 							= nil
	_killFontNum 						= nil
	_curContiFont 						= nil
	_curContiFontNum 					= nil
	_maxContiFont 						= nil
	_maxContiFontNum 					= nil
	_protectFont 						= nil
	_protectTimeLabel 					= nil
	_challengeFont						= nil
	_challengeFontNum					= nil
	_goldResetCostFont 					= nil
	_goldResetMenuItem  				= nil
	_silverResetMenuItem   				= nil
	_silverResetCostFont 				= nil
	_silverResetFont 					= nil
	_silverResetFontNum 				= nil
	_skipMenuItem 						= nil
	_skipSprite 						= nil
	_protectFontNum 					= nil
	_buyMenuItem 						= nil
	_moveMaskLayer 						= nil
	_balckLayer 						= nil
	_allMenuItem 						= nil
	_allMenuBg 							= nil
	_allMenuMaksLayer 					= nil
	_timeDesNode 						= nil
	_challengeCDFont 					= nil
	_challengeCDFontNum 				= nil

	_playerSpriteTab 					= {}

	_playerInfo 						= nil
	_protectTime 						= nil
	_challengeCDTime 					= nil

end

---------------------------------------------------------------------------- 按钮事件 -------------------------------------------------------------------------
--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
		-- 背景音乐
		require "script/audio/AudioUtil"
    	AudioUtil.playBgm("audio/bgm/music15.mp3",true)
	elseif (event == "exit") then
		require "script/audio/AudioUtil"
    	AudioUtil.playMainBgm()
	end
end

--[[
	@des 	:返回按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
end

--[[
	@des 	:功能按钮回调
	@param 	:
	@return :
--]]
function allMenuItemCallFunc( tag, sender ) 
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local toggleItem  = tolua.cast(sender, "CCMenuItemToggle")
	local selectIndex = toggleItem:getSelectedIndex()

	if(selectIndex == 0) then
		-- print("toogle 0 select index:", selectIndex)
		_allMenuBg:stopAllActions()
		local action = CCScaleTo:create(0.2, 0)
		_allMenuBg:runAction(action)
		if(_allMenuMaksLayer) then
			_allMenuMaksLayer:removeFromParentAndCleanup(true)
		end
	else
		-- print("toogle select index:",selectIndex)
		showAllMenuLayer()
		_allMenuBg:stopAllActions()
		local action = CCScaleTo:create(0.2, 1 )
		_allMenuBg:runAction(action)
	end

end

--[[
	@des 	:奖励预览按钮回调
	@param 	:
	@return :
--]]
function rewardMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/ui/WorldArena/reward/WorldArenaRewardLayer"
    WorldArenaRewardLayer.showLayer( _menu_priority-30, 1010 )
end

--[[
	@des 	:排行榜按钮回调
	@param 	:
	@return :
--]]
function rankMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- 1.活动时间结束不可拉
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local endTime = WorldArenaMainData.getWorldArenaEndTime()
	if( curTime >= endTime )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1616"))
		return
	end

    --2.判断是否已经报过名
	local mySignUpTime = WorldArenaMainData.getMySignUpTime()
	if(mySignUpTime <= 0)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1610"))
		return
	end

    require "script/ui/WorldArena/rank/WorldArenaRankLayer"
    WorldArenaRankLayer.showLayer( _menu_priority-30, 1010 )
end

--[[
	@des 	:战报按钮回调
	@param 	:
	@return :
--]]
function recrordMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 1.活动时间结束不可拉
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local endTime = WorldArenaMainData.getWorldArenaEndTime()
	if( curTime >= endTime )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1616"))
		return
	end

    --2.判断是否已经报过名
	local mySignUpTime = WorldArenaMainData.getMySignUpTime()
	if(mySignUpTime <= 0)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1610"))
		return
	end

    require "script/ui/WorldArena/recrord/WorldArenaRecordLayer"
    WorldArenaRecordLayer.showLayer( _menu_priority-30, 1010 )
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

    require "script/ui/WorldArena/WorldArenaExplainDialog"
    WorldArenaExplainDialog.showLayer( _menu_priority-30, 1010 )
end

--[[
	@des 	:购买按钮回调
	@param 	:
	@return :
--]]
function buyMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
 	
 	-- 最大次数限制
	local maxNum = WorldArenaMainData.getBuyAtkMaxNum()
	-- 已购买次数
	local haveBuyNum = WorldArenaMainData.getHaveBuyAtkNum()
	if(haveBuyNum >= maxNum)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1697"))
		return
	end

	local nextCallFun = function ( p_num )
		-- print("buyMenuItemCallback p_num", p_num)
		-- 确认购买
		local refreshCallBack = function ( ... )
			-- 刷新
		    local challengeNum = WorldArenaMainData.getAtkNum()
		    _challengeFontNum:setString(challengeNum)
		end
		WorldArenaController.buyAtkNumCallback(p_num,refreshCallBack)
	end

	WorldArenaUtil.showBuyAtkNumDialog( nextCallFun )
end

--[[
	@des 	:金币重置按钮回调
	@param 	:
	@return :
--]]
function goldResetMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local nextCallFun = function ( ... )
    	-- 刷新自己
    	_playerInfo[4].hp_percent = 10000
    	_playerSpriteTab[4]:refreshCallFunc(_playerInfo[4])
	    -- 价格
	   local goldCost = WorldArenaMainData.getNextResetCostByGold()
    	_goldResetCostFont:setString(goldCost)
    end

    WorldArenaController.resetCallback("gold",nextCallFun)
end

--[[
	@des 	:银币重置按钮回调
	@param 	:
	@return :
--]]
function silverResetMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local nextCallFun = function ( ... )
    	-- 刷新自己
    	_playerInfo[4].hp_percent = 10000
    	_playerSpriteTab[4]:refreshCallFunc(_playerInfo[4])
    	-- 刷新剩余次数
    	 local silverResetMaxNum = WorldArenaMainData.getMaxResetNumBySilver()
	    local silverResetUseNum = WorldArenaMainData.getHaveResetNumBySilver()
	    _silverResetFontNum:setString(silverResetMaxNum-silverResetUseNum.. GetLocalizeStringBy("lic_1696"))
	    -- 价格
	    local silverCost = WorldArenaMainData.getNextResetCostBySilver()
    	_silverResetCostFont:setString(string.formatBigNumber1(silverCost))
    end

    WorldArenaController.resetCallback("silver",nextCallFun)
end

--[[
	@des 	:跳过战斗按钮回调
	@param 	:
	@return :
--]]
function skipMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local skip = WorldArenaMainData.getSkipData()
    if( skip == 1)then
    	_skipMenuItem:unselected()
    	WorldArenaMainData.setSkipData(0)
    else
    	_skipMenuItem:selected()
    	WorldArenaMainData.setSkipData(1)
    end
end

--[[
	@des 	:挑战按钮回调
	@param 	:
	@return :
--]]
function challengeMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local skip = WorldArenaMainData.getSkipData()
    -- print("tag==>",tag,"skip",skip)

    local nextCallFun = function ( p_retData )
    
    	-- 正常可打
    	if(p_retData.ret == "ok")then
    		-- 加奖励
    		WorldArenaMainData.addRewardData( p_retData.reward )
    		-- 战斗胜负判断
		    local isWin = nil
		    if( p_retData.appraisal ~= "E" and p_retData.appraisal ~= "F" )then
		        isWin = true
		    else
		        isWin = false
		    end

    		local flyCallFun = function ( ... )
    			--飘奖励
				flyReward( p_retData.reward, p_retData.cur_conti_num, p_retData.terminal_conti_num )
    		end

	    	if( skip == 1)then
	    		-- 跳过 播放动画
	    		challengeAction( tag, isWin, refreshMiddleUI, flyCallFun )
	    	else
	    		-- 结算回调
			    local afterBattleCallFun = function ( ... )
		    		challengeAction( tag, isWin, refreshMiddleUI, nil )
	    		end
	    		-- 不跳过 播放战斗
	    		require "script/battle/BattleLayer"
	    		require "script/ui/WorldArena/WorldArenaAfterBattle"
			 	local layer = WorldArenaAfterBattle.createLayer( -600, isWin, afterBattleCallFun, p_retData.reward, p_retData.cur_conti_num, p_retData.terminal_conti_num)
			    BattleLayer.showBattleWithString(p_retData.fightRet, nil, layer, "zhiyanzhanchang.jpg","music11.mp3")

	    	end
	    else
	    	refreshMiddleUI()
	    end
    end
    WorldArenaController.attackCallback(  _playerInfo[tag],skip, nextCallFun, _challengeCDTime)

end
------------------------------------------------------------------- 创建UI --------------------------------------------------------------
--[[
	@des:显示功能按钮子菜单
--]]
function showAllMenuLayer( ... )
	local touchRect = getSpriteScreenRect(_allMenuBg)
	local layer = CCLayer:create()
    layer:setPosition(ccp(0, 0))
    layer:setAnchorPoint(ccp(0, 0))
    layer:setTouchEnabled(true)
    layer:registerScriptTouchHandler(function ( eventType,x,y )
        if(eventType == "began") then
            if(touchRect:containsPoint(ccp(x,y))) then
                return false
            else
                _allMenuBg:stopAllActions()
				local action = CCScaleTo:create(0.2, 0)
				_allMenuBg:runAction(action)
				layer:removeFromParentAndCleanup(true)
				_allMenuMaksLayer = nil
				_allMenuItem:setSelectedIndex(0)
                return true
            end
        end
    end,false, _menu_priority-3, true)
    local layerColor = CCLayerColor:create(ccc4(0,0,0,150))
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    layer:addChild(layerColor)
 	_allMenuMaksLayer = layer
 	_bgLayer:addChild(_allMenuMaksLayer,1000)
end

--[[
	@des 	: 飘奖励
	@param 	: p_rewardData：奖励数据
	@return : 
--]]
function getRewardDesTip( p_rewardData, p_text, p_width, p_alignment )
	-- 第一条 恭喜你获得了胜利，获得：XXXXX
	local rewardData = WorldArenaMainData.getRewardData(p_rewardData)
    local richInfo = {
 		width = p_width or 600, -- 宽度
        alignment = p_alignment or 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        labelDefaultFont = g_sFontPangWa,      -- 默认字体
        labelDefaultSize = 24,          -- 默认字体大小
        elements =
        {	
        	{
        		type = "CCRenderLabel",
                text = p_text,
                color = ccc3(0xff, 0xf6, 0x00)
        	},
        }
 	}
 	for k,v in pairs(rewardData) do
 		local tab1 = {
    		type = "CCRenderLabel",
            text = v.name,
            color = ccc3(0xff, 0xf6, 0x00)
 		}
 		table.insert(richInfo.elements,tab1)
 		local tab2 = {
    		type = "CCSprite",
            image = "images/common/prestige.png"
 		}
 		table.insert(richInfo.elements,tab2)
 		local tab3 = {
    		type = "CCRenderLabel",
            text = v.num,
            color = ccc3(0x00,0xff,0x18)
 		}
 		table.insert(richInfo.elements,tab3)
 	end
 	local tipDes = LuaCCLabel.createRichLabel(richInfo)
 	return tipDes
end

--[[
	@des 	: 飘奖励
	@param 	: p_rewardData：奖励数据 p_curContiNum:当前连杀 p_curTerminalContiNum 当前终结连杀
	@return : 
--]]
function flyReward( p_rewardData, p_curContiNum, p_curTerminalContiNum )
	local height = 0
	local tipNode1 = nil
	local tipNode2 = nil
	local tipNode3 = nil
	local tipNode4 = nil
	if( not table.isEmpty(p_rewardData.win_reward) )then
		tipNode1 = getRewardDesTip( p_rewardData.win_reward, GetLocalizeStringBy("lic_1611") )
		height = height + tipNode1:getContentSize().height + 10
	end
	if( not table.isEmpty(p_rewardData.conti_reward) and tonumber(p_curContiNum) > 1)then
		tipNode2 = getRewardDesTip( p_rewardData.conti_reward, GetLocalizeStringBy("lic_1612",tonumber(p_curContiNum)) )
		height = height + tipNode2:getContentSize().height + 10
	end
	if( not table.isEmpty(p_rewardData.terminal_conti_reward and tonumber(p_curTerminalContiNum) > 1) )then
		tipNode3 = getRewardDesTip( p_rewardData.terminal_conti_reward, GetLocalizeStringBy("lic_1613") )
		height = height + tipNode3:getContentSize().height + 10
	end
	if( not table.isEmpty(p_rewardData.lose_reward) )then
		tipNode4 = getRewardDesTip( p_rewardData.lose_reward, GetLocalizeStringBy("lic_1617") )
		height = height + tipNode4:getContentSize().height + 10
	end

	local tipSp = CCSprite:create()
	tipSp:setContentSize(CCSizeMake(600,height))
	tipSp:setAnchorPoint(ccp(0.5,0.5))
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(tipSp,2000)
    tipSp:setScale(g_fElementScaleRatio)

    local posY = tipSp:getContentSize().height - 30
    if(tipNode1 ~= nil)then
    	tipNode1:setAnchorPoint(ccp(0.5,0))
    	tipNode1:setPosition(ccp(tipSp:getContentSize().width*0.5,posY))
    	tipSp:addChild(tipNode1)
    	posY = posY - 30
    end

    if(tipNode2 ~= nil)then
    	tipNode2:setAnchorPoint(ccp(0.5,0))
    	tipNode2:setPosition(ccp(tipSp:getContentSize().width*0.5,posY))
    	tipSp:addChild(tipNode2)
    	posY = posY - 30
    end

    if(tipNode3 ~= nil)then
    	tipNode3:setAnchorPoint(ccp(0.5,0))
    	tipNode3:setPosition(ccp(tipSp:getContentSize().width*0.5,posY))
    	tipSp:addChild(tipNode3)
    	posY = posY - 30
    end

    if(tipNode4 ~= nil)then
    	tipNode4:setAnchorPoint(ccp(0.5,0))
    	tipNode4:setPosition(ccp(tipSp:getContentSize().width*0.5,posY))
    	tipSp:addChild(tipNode4)
    	posY = posY - 30
    end

    -- 动画action
	tipSp:setPosition(ccp(runningScene:getContentSize().width*0.5,runningScene:getContentSize().height*0.4))
    local nextMoveToP = ccp(runningScene:getContentSize().width*0.5,runningScene:getContentSize().height*0.55)
    -- 设置遍历子节点  透明度
    tipSp:setCascadeOpacityEnabled(true)
    local actionArr = CCArray:create()
	actionArr:addObject(CCEaseOut:create(CCMoveTo:create(4, nextMoveToP),1))
	actionArr:addObject(CCFadeOut:create(0.8))
	actionArr:addObject(CCCallFuncN:create(function ( ... )
		tipSp:removeFromParentAndCleanup(true)
		tipSp = nil
	end))
	tipSp:runAction(CCSequence:create(actionArr))
	
end

--[[
	@des 	: 创建上部分ui
	@param 	: p_index:位置，p_isWin：输赢，p_refreshCallFun刷新函数 p_flyRewardCallFun飘字
	@return : 
--]]
function challengeAction( p_index, p_isWin, p_refreshCallFun, p_flyRewardCallFun )

	-- 加移动屏蔽层 
	_moveMaskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_moveMaskLayer, 10000)

	local destSprite = _playerSpriteTab[p_index]
	local mySprite = _playerSpriteTab[4]
	local isWin = p_isWin

	-- 第二步
	local secondCallFun = function ( ... )
		local moveSprite = nil
		local moveNum = 0
		local moveTime = 0
		if(isWin)then
			destSprite:setVisible(true)
			mySprite:setVisible(false)
			moveSprite = destSprite
			moveNum = 100*g_fElementScaleRatio
			moveTime = 1
		else
			destSprite:setVisible(true)
			mySprite:setVisible(true)
			moveSprite = mySprite
			local y = moveSprite:getPositionY()
			moveNum = -y-100*g_fElementScaleRatio
			moveTime = 0.5
		end
		
		local spwanArray = CCArray:create()
	    spwanArray:addObject(CCMoveBy:create(moveTime, ccp(0, moveNum)))
	    spwanArray:addObject(CCFadeTo:create(1, 0))
	    spwanArray:addObject(CCRotateTo:create(1, 3200))
	    spwanArray:addObject(CCScaleTo:create(1, 0))

	    local spwan = CCSpawn:create(spwanArray)
	    local callFunc1 = CCCallFuncN:create(function ( p_actionNode )
	    	-- 黑屏
			_balckLayer = BaseUI.createMaskLayer(-5000,nil,nil,220)
			runningScene:addChild(_balckLayer, 10001)
			-- 刷新
			if(p_refreshCallFun)then
				p_refreshCallFun()
			end
		end)
	    local delayFunc = CCDelayTime:create(0.5)
		local callFunc3 = CCCallFuncN:create(function ( p_actionNode )

			_balckLayer:removeFromParentAndCleanup(true)
			_balckLayer = nil

			_moveMaskLayer:removeFromParentAndCleanup(true)
			_moveMaskLayer = nil

			-- 飘字
			if(p_flyRewardCallFun)then
				p_flyRewardCallFun()
			end
		end)
		local actionArray = CCArray:create()
		actionArray:addObject(spwan)
		actionArray:addObject(callFunc1)
		actionArray:addObject(delayFunc)
		actionArray:addObject(callFunc3)
		local seq = CCSequence:create(actionArray)
		moveSprite:runAction(seq)
	end

	-- 自己移动到目标位置
	local x,y = destSprite:getPosition()
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveTo:create(0.2, ccp(x,y)))
	actionArray:addObject(CCCallFunc:create(function ( ... )
            -- 爆炸特效
            local bomSprite = XMLSprite:create("images/worldarena/effect/dianfengtexiao")
		    bomSprite:setAnchorPoint(ccp(0.5,0.5))
		    bomSprite:setPosition(ccp(destSprite:getContentSize().width*0.5,destSprite:getContentSize().height*0.5))
		    destSprite:addChild(bomSprite,100)
		    bomSprite:setReplayTimes(1)
            bomSprite:registerEndCallback(secondCallFun)
            -- 自己隐身
            mySprite:setVisible(false)
        end))
	local seq = CCSequence:create(actionArray)
	mySprite:runAction(seq)

end

--[[
	@des 	: 显示哪个界面
	@param 	: 
	@return : 
--]]
function showWichLayer( ... )
	-- 时间向左偏移1秒
	local curTime = TimeUtil.getSvrTimeByOffset()
	local signEndTime = WorldArenaMainData.getSignUpEndTime()
	local atkStartTime = WorldArenaMainData.getAttackStartTime()
	local atkEndTime = WorldArenaMainData.getAttackEndTime()
	if( curTime < atkStartTime )then
		-- 显示报名界面
		require "script/ui/WorldArena/WorldArenaRegisterLayer"
		WorldArenaRegisterLayer.showLayer( _menu_priority-30, 1010 )
		-- delay 显示主界面
		local delayTime = atkStartTime - curTime
		performWithDelay(_bgLayer, showLayer, delayTime)
	elseif(curTime >= atkStartTime  and curTime < atkEndTime)then
		-- 关闭报名界面
		require "script/ui/WorldArena/WorldArenaRegisterLayer"
		WorldArenaRegisterLayer.closeLayer()
		-- delay 活动结束界面
		local delayTime = atkEndTime - curTime
		performWithDelay(_bgLayer, showLayer, delayTime)
	elseif( curTime >= atkEndTime )then
		-- 显示活动结束界面

	else

	end
end

--[[
	@des 	: 刷新保护时间
	@param 	: 
	@return : 
--]]
function refreshProtectCDLable( ... )
	-- 更新信息按钮cd
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	if( _protectTime <= curTime )then
		_protectFont:stopAllActions()
		_protectFont:setVisible(false)
		_protectFontNum:setString("00:00:00")
		return
	end
	_protectFontNum:setString( TimeUtil.getTimeString(_protectTime - curTime) )
end

--[[
	@des 	: 刷新挑战cd
	@param 	: 
	@return : 
--]]
function refreshChallengeCDLable( ... )
	-- 更新信息按钮cd
	local curTime = TimeUtil.getSvrTimeByOffset(0) 
	if( _challengeCDTime <= curTime )then
		_challengeCDFont:stopAllActions() 
		_challengeCDFont:setVisible(false)
		_challengeCDFontNum:setString("00:00:00") 
		return
	end
	_challengeCDFontNum:setString( TimeUtil.getTimeString(_challengeCDTime - curTime) )
end

--[[
	@des 	: 刷新中部分ui
	@param 	: 
	@return : 
--]]
function refreshMiddleUI( ... )
	-- 刷新全身像
	_playerInfo = WorldArenaMainData.getPlayer()
	-- print("refreshMiddleUI==>")
	-- print_t(_playerInfo)

	for i=1,#_playerSpriteTab do
		_playerSpriteTab[i]:setVisible(true)
		_playerSpriteTab[i]:setOpacity(255)
		_playerSpriteTab[i]:setRotation(0)
		_playerSpriteTab[i]:setScale(1*g_fElementScaleRatio)
		_playerSpriteTab[i]:refreshCallFunc(_playerInfo[i])
		_playerSpriteTab[i]:registerScriptCallFunc(challengeMenuItemCallBack)
		_playerSpriteTab[i]:setPosition(ccp(_bgLayer:getContentSize().width*_posX[i],_bgLayer:getContentSize().height*_posY[i]))
	end
	-- 击杀数
	local killNum = WorldArenaMainData.getMyKillNum()
    _killFontNum:setString( killNum)
    -- 当前连杀
	local curContiNum = WorldArenaMainData.getMyCurContiNum()
    _curContiFontNum:setString(curContiNum)
    -- 最大连杀
 	local maxContiNum = WorldArenaMainData.getMyMaxContiNum()
    _maxContiFontNum:setString( maxContiNum)
    
   	-- 更新保护时间
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	_protectTime = tonumber(_playerInfo[4].protect_time)
	if( _protectTime > curTime )then
		_protectFont:setVisible(true)
		_protectFontNum:setString( TimeUtil.getTimeString(_protectTime - curTime) )
		schedule(_protectFont, refreshProtectCDLable, 1)
	end

	-- 更新挑战冷却时间
	local isInTen = WorldArenaMainData.getIsInLastTen()
   	local needCD = WorldArenaMainData.getFightCDLastTen()
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local lastAtkTime = WorldArenaMainData.getLastAttackTime()
	-- print("lastAtkTime",lastAtkTime,needCD)
	_challengeCDTime = lastAtkTime + needCD
	-- print("_challengeCDTime",_challengeCDTime,curTime)
	if( isInTen and _challengeCDTime > curTime )then
		_challengeCDFont:setVisible(true)
		_challengeCDFontNum:setString( TimeUtil.getTimeString(_challengeCDTime - curTime) )
		schedule(_challengeCDFont, refreshChallengeCDLable, 1)
	end

	-- 更新剩余挑战次数
    local challengeNum = WorldArenaMainData.getAtkNum()
    _challengeFontNum:setString(challengeNum)
end

--[[
	@des 	: 创建中部分ui
	@param 	: 
	@return : 
--]]
function createMiddleUI( ... )

	-- 击杀数
	_killFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1689"), g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _killFont:setColor(ccc3(0xff, 0xff, 0xff))
    _killFont:setAnchorPoint(ccp(0,0.5))
    _killFont:setPosition(ccp(15*g_fElementScaleRatio,_topSprite:getPositionY()-_topSprite:getContentSize().height*g_fScaleX-20*g_fElementScaleRatio))
    _bgLayer:addChild(_killFont,20)
    _killFont:setScale(g_fElementScaleRatio)

    local killNum = WorldArenaMainData.getMyKillNum()
    _killFontNum = CCRenderLabel:create( killNum, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _killFontNum:setColor(ccc3(0xff, 0xf6, 0x00))
    _killFontNum:setAnchorPoint(ccp(0,0.5))
    _killFontNum:setPosition(ccp(_killFont:getContentSize().width,_killFont:getContentSize().height*0.5))
    _killFont:addChild(_killFontNum,10)

    -- 当前连杀数
	_curContiFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1690"), g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _curContiFont:setColor(ccc3(0xff, 0xff, 0xff))
    _curContiFont:setAnchorPoint(ccp(0,0.5))
    _curContiFont:setPosition(ccp(232*g_fElementScaleRatio,_killFont:getPositionY()))
    _bgLayer:addChild(_curContiFont,20)
    _curContiFont:setScale(g_fElementScaleRatio)

    local curContiNum = WorldArenaMainData.getMyCurContiNum()
    _curContiFontNum = CCRenderLabel:create( curContiNum, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _curContiFontNum:setColor(ccc3(0xff, 0xf6, 0x00))
    _curContiFontNum:setAnchorPoint(ccp(0,0.5))
    _curContiFontNum:setPosition(ccp(_curContiFont:getContentSize().width,_curContiFont:getContentSize().height*0.5))
    _curContiFont:addChild(_curContiFontNum,10)

    -- 最大连杀数
	_maxContiFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1691"), g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _maxContiFont:setColor(ccc3(0xff, 0xff, 0xff))
    _maxContiFont:setAnchorPoint(ccp(0,0.5))
    _maxContiFont:setPosition(ccp(450*g_fElementScaleRatio,_killFont:getPositionY()))
    _bgLayer:addChild(_maxContiFont,20)
    _maxContiFont:setScale(g_fElementScaleRatio)

    local maxContiNum = WorldArenaMainData.getMyMaxContiNum()
    _maxContiFontNum = CCRenderLabel:create( maxContiNum, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _maxContiFontNum:setColor(ccc3(0xff, 0xf6, 0x00))
    _maxContiFontNum:setAnchorPoint(ccp(0,0.5))
    _maxContiFontNum:setPosition(ccp(_maxContiFont:getContentSize().width,_maxContiFont:getContentSize().height*0.5))
    _maxContiFont:addChild(_maxContiFontNum,10)

    -- 人物
	_playerInfo = WorldArenaMainData.getPlayer()
	-- print("_playerInfo==>")
	-- print_t(_playerInfo)
	for i=1,#_playerInfo do
		local body = WorldArenaBody:createWithData( _playerInfo[i] )
		body:setAnchorPoint(ccp(0.5,0.5))
		body:setPosition(ccp(_bgLayer:getContentSize().width*_posX[i],_bgLayer:getContentSize().height*_posY[i]))
		_bgLayer:addChild(body)
		body:setScale(g_fElementScaleRatio)
		-- 注册点击事件
		body:registerScriptCallFunc(challengeMenuItemCallBack)
		-- 保存body
		table.insert(_playerSpriteTab,body)
	end

	-- 保护时间
	_protectFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1692"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _protectFont:setColor(ccc3(0xff, 0xff, 0xff))
    _protectFont:setAnchorPoint(ccp(0,0.5))
    _protectFont:setPosition(ccp(10*g_fElementScaleRatio,75*g_fElementScaleRatio))
    _bgLayer:addChild(_protectFont,20)
    _protectFont:setScale(g_fElementScaleRatio)
    _protectFont:setVisible(false)

    _protectFontNum = CCRenderLabel:create("00:00:00", g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _protectFontNum:setColor(ccc3(0x00, 0xff, 0x18))
    _protectFontNum:setAnchorPoint(ccp(0,0.5))
    _protectFontNum:setPosition(ccp(_protectFont:getContentSize().width,_protectFont:getContentSize().height*0.5))
    _protectFont:addChild(_protectFontNum, 10)

   	-- 更新保护时间
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	_protectTime = tonumber(_playerInfo[4].protect_time)
	if( _protectTime > curTime )then
		_protectFont:setVisible(true)
		_protectFontNum:setString( TimeUtil.getTimeString(_protectTime - curTime) )
		schedule(_protectFont, refreshProtectCDLable, 1)
	end

	-- 挑战冷却时间
	_challengeCDFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1739"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _challengeCDFont:setColor(ccc3(0xff, 0xff, 0xff))
    _challengeCDFont:setAnchorPoint(ccp(0,0.5))
    _challengeCDFont:setPosition(ccp(10*g_fElementScaleRatio,100*g_fElementScaleRatio))
    _bgLayer:addChild(_challengeCDFont,20)
    _challengeCDFont:setScale(g_fElementScaleRatio)
    _challengeCDFont:setVisible(false)

    _challengeCDFontNum = CCRenderLabel:create("00:00:00", g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _challengeCDFontNum:setColor(ccc3(0x00, 0xff, 0x18))
    _challengeCDFontNum:setAnchorPoint(ccp(0,0.5))
    _challengeCDFontNum:setPosition(ccp(_challengeCDFont:getContentSize().width,_challengeCDFont:getContentSize().height*0.5))
    _challengeCDFont:addChild(_challengeCDFontNum, 10)

   	-- 更新保护时间
   	local isInTen = WorldArenaMainData.getIsInLastTen()
   	local needCD = WorldArenaMainData.getFightCDLastTen()
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local lastAtkTime = WorldArenaMainData.getLastAttackTime()
	_challengeCDTime = lastAtkTime + needCD
	if( isInTen and _challengeCDTime > curTime )then
		_challengeCDFont:setVisible(true)
		_challengeCDFontNum:setString( TimeUtil.getTimeString(_challengeCDTime - curTime) )
		schedule(_challengeCDFont, refreshChallengeCDLable, 1)
	end
end

--[[
	@des 	: 创建下部分ui
	@param 	: 
	@return : 
--]]
function createBottomUI( ... )

    -- 剩余挑战次数
	_challengeFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1693"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _challengeFont:setColor(ccc3(0xff, 0xff, 0xff))
    _challengeFont:setAnchorPoint(ccp(0,0.5))
    _challengeFont:setPosition(ccp(10*g_fElementScaleRatio,30*g_fElementScaleRatio))
    _bgLayer:addChild(_challengeFont,20)
    _challengeFont:setScale(g_fElementScaleRatio)

    local challengeNum = WorldArenaMainData.getAtkNum()
    _challengeFontNum = CCRenderLabel:create(challengeNum, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _challengeFontNum:setColor(ccc3(0x00, 0xff, 0x18))
    _challengeFontNum:setAnchorPoint(ccp(0,0.5))
    _challengeFontNum:setPosition(ccp(_challengeFont:getContentSize().width-8,_challengeFont:getContentSize().height*0.5))
    _challengeFont:addChild(_challengeFontNum)
   

    -- 按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_menu_priority)
    _bgLayer:addChild(menuBar,20)

    -- 购买次数按钮
	_buyMenuItem = CCMenuItemImage:create("images/common/btn/btn_plus_h.png","images/common/btn/btn_plus_n.png")
	_buyMenuItem:setAnchorPoint(ccp(0, 0.5))
	_buyMenuItem:registerScriptTapHandler(buyMenuItemCallback)
	_buyMenuItem:setPosition(ccp(_challengeFont:getPositionX()+_challengeFont:getContentSize().width*g_fElementScaleRatio+20*g_fElementScaleRatio,_challengeFont:getPositionY()))
	menuBar:addChild(_buyMenuItem)
	_buyMenuItem:setScale(g_fElementScaleRatio)

	-- 金币重置按钮
	_goldResetMenuItem = CCMenuItemImage:create("images/worldarena/gold_n.png","images/worldarena/gold_h.png")
	_goldResetMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	_goldResetMenuItem:registerScriptTapHandler(goldResetMenuItemCallback)
	_goldResetMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.9,240*g_fElementScaleRatio))
	menuBar:addChild(_goldResetMenuItem)
	_goldResetMenuItem:setScale(g_fElementScaleRatio)

    local font1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1694"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font1:setColor(ccc3(0xff,0xf6,0x00))
    font1:setAnchorPoint(ccp(0,0.5))
    _goldResetMenuItem:addChild(font1)
    local goldIcon = CCSprite:create("images/common/gold.png")
    goldIcon:setAnchorPoint(ccp(0,0.5))
    _goldResetMenuItem:addChild(goldIcon)

    local goldCost = WorldArenaMainData.getNextResetCostByGold()
    _goldResetCostFont = CCRenderLabel:create(goldCost, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _goldResetCostFont:setColor(ccc3(0xff,0xf6,0x00))
    _goldResetCostFont:setAnchorPoint(ccp(0,0.5))
    _goldResetMenuItem:addChild(_goldResetCostFont)
   	local posX = (_goldResetMenuItem:getContentSize().width - font1:getContentSize().width - goldIcon:getContentSize().width-_goldResetCostFont:getContentSize().width)/2
   	font1:setPosition(ccp(posX,-3))
   	goldIcon:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,font1:getPositionY()))
   	_goldResetCostFont:setPosition(ccp(goldIcon:getPositionX()+goldIcon:getContentSize().width,font1:getPositionY()))

	-- 银币重置按钮
	_silverResetMenuItem = CCMenuItemImage:create("images/worldarena/coin_n.png","images/worldarena/coin_h.png")
	_silverResetMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	_silverResetMenuItem:registerScriptTapHandler(silverResetMenuItemCallback)
	_silverResetMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.9,145*g_fElementScaleRatio))
	menuBar:addChild(_silverResetMenuItem)
	_silverResetMenuItem:setScale(g_fElementScaleRatio)

	local font2 = CCRenderLabel:create(GetLocalizeStringBy("lic_1694"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font2:setColor(ccc3(0xff,0xf6,0x00))
    font2:setAnchorPoint(ccp(0,0.5))
    _silverResetMenuItem:addChild(font2)
    local silverIcon = CCSprite:create("images/common/coin.png")
    silverIcon:setAnchorPoint(ccp(0,0.5))
    _silverResetMenuItem:addChild(silverIcon)

    local silverCost = WorldArenaMainData.getNextResetCostBySilver()
    _silverResetCostFont = CCRenderLabel:create(string.formatBigNumber1(silverCost), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _silverResetCostFont:setColor(ccc3(0xff,0xf6,0x00))
    _silverResetCostFont:setAnchorPoint(ccp(0,0.5))
    _silverResetMenuItem:addChild(_silverResetCostFont)
   	local posX = (_silverResetMenuItem:getContentSize().width - font2:getContentSize().width - silverIcon:getContentSize().width-_silverResetCostFont:getContentSize().width)/2
   	font2:setPosition(ccp(posX,-3))
   	silverIcon:setPosition(ccp(font2:getPositionX()+font2:getContentSize().width,font2:getPositionY()))
   	_silverResetCostFont:setPosition(ccp(silverIcon:getPositionX()+silverIcon:getContentSize().width,font2:getPositionY()))

   	-- 剩余银币重置次数
   	_silverResetFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1695"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _silverResetFont:setColor(ccc3(0xff, 0xff, 0xff))
    _silverResetFont:setAnchorPoint(ccp(0,0.5))
    _silverResetFont:setPosition(ccp(_bgLayer:getContentSize().width*0.72,72*g_fElementScaleRatio))
    _bgLayer:addChild(_silverResetFont,20)
    _silverResetFont:setScale(g_fElementScaleRatio)

    local silverResetMaxNum = WorldArenaMainData.getMaxResetNumBySilver()
    local silverResetUseNum = WorldArenaMainData.getHaveResetNumBySilver()
    _silverResetFontNum = CCRenderLabel:create(silverResetMaxNum-silverResetUseNum .. GetLocalizeStringBy("lic_1696"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _silverResetFontNum:setColor(ccc3(0x00, 0xff, 0x18))
    _silverResetFontNum:setAnchorPoint(ccp(0,0.5))
    _silverResetFontNum:setPosition(ccp(_silverResetFont:getContentSize().width-8,_silverResetFont:getContentSize().height*0.5))
    _silverResetFont:addChild(_silverResetFontNum,10)

    -- 跳过战斗
	_skipMenuItem = CCMenuItemImage:create("images/common/duigou_n.png","images/common/duigou_h.png")
	_skipMenuItem:setAnchorPoint(ccp(0, 0.5))
	_skipMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.74,28*g_fElementScaleRatio))
	menuBar:addChild(_skipMenuItem)
	_skipMenuItem:registerScriptTapHandler(skipMenuItemCallback)
 	_skipMenuItem:setScale(g_fElementScaleRatio)

 	_skipSprite = CCSprite:create("images/worldarena/skip.png")
 	_skipSprite:setAnchorPoint(ccp(0, 0.5))
	_skipSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.83,28*g_fElementScaleRatio))
	_bgLayer:addChild(_skipSprite,20)
 	_skipSprite:setScale(g_fElementScaleRatio)

 	local skip = WorldArenaMainData.getSkipData()
    if( skip == 1)then
    	_skipMenuItem:selected()
    end
end

--[[
	@des 	: 创建上部分ui
	@param 	: 
	@return : 
--]]
function createTopUI( ... )
	-- 背景
	_topSprite = CCScale9Sprite:create("images/common/bg/hui_bg.png")
	_topSprite:setContentSize(CCSizeMake(640,126))
	_topSprite:setAnchorPoint(ccp(0.5,1))
	_topSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height))
	_bgLayer:addChild(_topSprite)
	_topSprite:setScale(g_fScaleX)

	-- 标题
	local titleSp = XMLSprite:create("images/worldarena/effect/dfduijue/dfduijue")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_topSprite:getContentSize().width*0.5, _topSprite:getContentSize().height*0.6))
	_topSprite:addChild(titleSp)

	-- 时间描述
	_timeDesNode = WorldArenaUtil.getTimeDesNode()
	if( _timeDesNode ~= nil )then
		_timeDesNode:setAnchorPoint(ccp(0.5,0.5))
		_timeDesNode:setPosition(ccp(_topSprite:getContentSize().width*0.5,_topSprite:getContentSize().height*0.2))
		_topSprite:addChild(_timeDesNode)
		local refreshTimeDesNode = function ( ... )
			if( _timeDesNode ~= nil )then
				_timeDesNode:removeFromParentAndCleanup(true)
				_timeDesNode = nil
			end
			_timeDesNode = WorldArenaUtil.getTimeDesNode()
			_timeDesNode:setAnchorPoint(ccp(0.5,0.5))
			_timeDesNode:setPosition(ccp(_topSprite:getContentSize().width*0.5,_topSprite:getContentSize().height*0.2))
			_topSprite:addChild(_timeDesNode)
		end
		schedule(_topSprite, refreshTimeDesNode, 1)
	end

	-- 按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_menu_priority)
    _topSprite:addChild(menuBar)

    -- 创建返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	closeMenuItem:setPosition(ccp( _topSprite:getContentSize().width-50,_topSprite:getContentSize().height*0.6 ))
	menuBar:addChild(closeMenuItem)
	closeMenuItem:registerScriptTapHandler(closeButtonCallBack)

	--创建功能按钮
    local menuBar1 = CCMenu:create()
    menuBar1:setAnchorPoint(ccp(0,0))
    menuBar1:setPosition(ccp(0,0))
    menuBar1:setTouchPriority(_menu_priority-5)
    _bgLayer:addChild(menuBar1,1010)

	local normal = CCMenuItemImage:create("images/worldarena/gong_n.png", "images/worldarena/gong_n.png")
	local hight  = CCMenuItemImage:create("images/worldarena/gong_h.png", "images/worldarena/gong_h.png")
	hight:setAnchorPoint(ccp(0.5, 0.5))
	normal:setAnchorPoint(ccp(0.5, 0.5))
	_allMenuItem = CCMenuItemToggle:create(normal)
	_allMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	_allMenuItem:addSubItem(hight)
	_allMenuItem:registerScriptTapHandler(allMenuItemCallFunc)
	menuBar1:addChild(_allMenuItem)
	_allMenuItem:setScale(g_fElementScaleRatio)
	_allMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.1,_bgLayer:getContentSize().height*0.94))

	-- 创建功能按钮背景
	_allMenuBg = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
	_allMenuBg:setContentSize(CCSizeMake(520,147))
	_allMenuBg:setAnchorPoint(ccp(0, 1))
	_allMenuBg:setPosition(_allMenuItem:getContentSize().width*0.5, _allMenuItem:getContentSize().height*0.5)
	_allMenuItem:addChild(_allMenuBg,-10)
	-- 设置初始状态
	_allMenuItem:setSelectedIndex(0)
	_allMenuBg:setScale(0)

	-- 子按钮
	local menuBar2 = CCMenu:create()
    menuBar2:setAnchorPoint(ccp(0,0))
    menuBar2:setPosition(ccp(0,0))
    menuBar2:setTouchPriority(_menu_priority-5)
    _allMenuBg:addChild(menuBar2)

	-- 奖励预览按钮
    local rewardMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
    rewardMenuItem:setAnchorPoint(ccp(0.5,0.5))
    rewardMenuItem:setPosition(ccp( _allMenuBg:getContentSize().width*0.85,_allMenuBg:getContentSize().height*0.5 ))
    menuBar2:addChild(rewardMenuItem)
    rewardMenuItem:registerScriptTapHandler(rewardMenuItemCallBack)

    -- 排行榜按钮
    local rankMenuItem = CCMenuItemImage:create("images/match/paihang_n.png","images/match/paihang_h.png")
    rankMenuItem:setAnchorPoint(ccp(0.5,0.5))
    rankMenuItem:setPosition(ccp( _allMenuBg:getContentSize().width*0.6,_allMenuBg:getContentSize().height*0.5 ))
    menuBar2:addChild(rankMenuItem)
    rankMenuItem:registerScriptTapHandler(rankMenuItemCallBack)

    -- 战报按钮
    local recrordMenuItem = CCMenuItemImage:create("images/guild_rob/report_btn_n.png","images/guild_rob/report_btn_h.png")
    recrordMenuItem:setAnchorPoint(ccp(0.5,0.5))
    recrordMenuItem:setPosition(ccp( _allMenuBg:getContentSize().width*0.4,_allMenuBg:getContentSize().height*0.5 ))
    menuBar2:addChild(recrordMenuItem)
    recrordMenuItem:registerScriptTapHandler(recrordMenuItemCallBack)

    --活动说明
	local explainMenuItem = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
	explainMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	explainMenuItem:setPosition(ccp(_allMenuBg:getContentSize().width*0.15,_allMenuBg:getContentSize().height*0.5 ))
	menuBar2:addChild(explainMenuItem)
	explainMenuItem:registerScriptTapHandler(explainMenuItemCallFunc)
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

	-- 隐藏下排按钮
	MainScene.setMainSceneViewsVisible(false, false, false)

	-- 大背景
    _bgSprite = XMLSprite:create("images/worldarena/effect/kuafujjc/kuafujjc")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 创建上部分
    createTopUI()

    local isShow = WorldArenaMainData.getIsShowBottomUI()
    print("isShow==>",isShow)
    if( isShow )then
	    -- 创建下部分
	    createBottomUI()

	    -- 创建下部分
	    createMiddleUI()
	end

	return _bgLayer
end

--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function showLayer( ... )
	
	local nextCallFun = function ( retData )
		-- 缓存数据
		WorldArenaMainData.setWorldArenaInfo(retData)

		local layer = createLayer()
		MainScene.changeLayer(layer, "WorldArenaMainLayer")

		-- 显示哪个界面
		showWichLayer()

		-- 进入主界面了
		WorldArenaMainData.setIsIn(true)
	end
	WorldArenaMainService.getWorldArenaInfo(nextCallFun)

end



































