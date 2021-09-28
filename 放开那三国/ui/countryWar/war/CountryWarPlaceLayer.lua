-- FileName: CountryWarPlaceLayer.lua 
-- Author: licong 
-- Date: 15/11/12 
-- Purpose: 战场主界面


module("CountryWarPlaceLayer", package.seeall)

require "script/ui/countryWar/war/CountryWarController"
require "script/ui/countryWar/signUp/CountryWarSignData"
require "script/ui/countryWar/encourage/CountryWarEncourageData"
require "script/ui/countryWar/encourage/CountryWarEncourageDialog"
require "script/ui/countryWar/foundation/CountryWarFoundationLayer"

------------------------------[[ 模块常量 ]]------------------------------
local kPlayerBloodTag        					= 101
local kPlayerNameTag         					= 102

local kKillType              					= 1 	--击杀获得
local kRobTyp                					= 2 	--抢夺获

local kStreakWin             					= 101	--连续击杀
local kStreakLose            					= 102	--连续击杀被终结

local kRomveTouchDown        					= 103 	-- 达阵离场
local kRomveLose             					= 104 	-- 死亡离场
local kRomveLeave            					= 105 	-- 主动离场或者断线离场

local kButtonAttackerType    					= 0 	--显示攻击方按钮
local kButtondefenderType    					= 1	--显示防御方按钮

local kBranMenuTag           					= 100
local kBranAttackerButtonTag 					= 101
local kBranDefenderButtonTag 					= 102
local kBranAttackerFlagTag   					= 103
local kBranDefenderFlagTag   					= 104

local kMaxZ  			    					= 10000000 

local _touchPriority 							= -405

-- 道路顺序 从左到右 0-3
local _roadPosXArr 								= { 0.2,0.4,0.6,0.8 }
local _roadPosYArr 								= { 0.38,0.38,0.38,0.38 }

--定义四条路的路径，此路线以下方路线为准，上方逆推即可
-- x 方向偏移量 y 方向偏移量
local ROAD_DATA = {
	{
		{dir = "y", value = 430},
	},
	{
		{dir = "y", value = 430},
	},
	{
		{dir = "y", value = 430},
	},
	{
		{dir = "y", value = 430},
	},
}

-- 传送阵顺序
-- 上：4-7
-- 下：0-3
local _joinPosXArr 								= { 0.2,0.4,0.6,0.8, 0.2,0.4,0.6,0.8}
local _joinPosYArr 								= { 0.2,0.2,0.2,0.2, 0.72,0.72,0.72,0.72}

-- 出生点
local BRON_POS = {
	{x =85, y=20},  {x=90, y=20},  {x=85, y=20},  {x=88, y=20},
	{x =85, y=420}, {x=90, y=420}, {x=85, y=420}, {x=88, y=420},
}

------------------------------[[ 模块变量 ]]------------------------------
local _bgLayer 									= nil
local _bgSprite 								= nil
local _roadArray 								= {}
local _joinButtonArray 							= {}
local _playerArray 								= {}
local _failedPlayerArray 						= {}
local _tranferEffects 		 					= {} --出战按钮数组
local _tranferNumLabelArray  		 			= {}
local _topBg 									= nil
local _auditionTimeLabel 						= nil
local _effectDown								= nil -- 加血特效下
local _effectUp 								= nil -- 加血特效上
local _warCoinLabel								= nil
local _goldLabel 								= nil
local _finaltionTimeLabel 						= nil
local _progressSprite 							= nil
local _woResourceLabel							= nil
local _diResourceLabel 							= nil
local _zhongSp 									= nil
local _roadBgArray 								= {}

local _updateTimeScheduler 						= nil
local _timer 									= 0
local _nowDefenderZorder	  					= 0
local _nowAttackerZorder	 					= 0
local _joinCDTime 								= 0
local _isBattleOver 							= false
local _isJionBattle 							= false --玩家是否已经加入战场
local _readyTime 								= 0   -- 准备倒计时
local _isAutoEnter 								= false
local _isShowTip 								= false
local _isConnect 			 					= true -- 网络是否连接 

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer 									= nil
	_bgSprite 									= nil
	_roadArray 									= {}
	_joinButtonArray 							= {}
	_playerArray 								= {}
	_failedPlayerArray 							= {}
	_tranferEffects 		 					= {}
	_tranferNumLabelArray  		 				= {}
	_topBg 										= nil
	_auditionTimeLabel 							= nil
	_effectDown									= nil 
	_effectUp 									= nil
	_warCoinLabel								= nil
	_goldLabel 									= nil
	_finaltionTimeLabel 						= nil
	_progressSprite 							= nil
	_woResourceLabel							= nil
 	_diResourceLabel 							= nil
 	_zhongSp 									= nil
 	_roadBgArray 								= {}

	_updateTimeScheduler 						= nil
	_timer 										= 0
	_nowDefenderZorder	  						= kMaxZ
	_nowAttackerZorder	  						= kMaxZ
	_joinCDTime 								= 0
	_isBattleOver 								= false
	_isJionBattle 								= false
	_readyTime 									= 0 
	_isAutoEnter 								= false
	_isShowTip 									= false
	_isConnect 			 						= true
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
    	AudioUtil.playBgm("audio/bgm/music18.mp3",true)
	elseif (event == "exit") then
		require "script/audio/AudioUtil"
    	AudioUtil.playMainBgm()
    	_bgLayer = nil
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		-- 取消自动参战
		CountryWarEncourageData.setAutoBattleState(false)
	end
end

--[[
	@des:返回按钮
--]]
function closeCallback()
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	local exitBattleScene = function ( isConfirm )
		if isConfirm then
			local leaveCallFun = function ( ... )
				closeBattle()
			end
			CountryWarController.leave(leaveCallFun)
			AudioUtil.playMainBgm()
		end
	end
	if _isJionBattle == true then
		AlertTip.showAlert(GetLocalizeStringBy("lic_1767", tostring(CountryWarPlaceData.getOutCd())) ,exitBattleScene, true)
	else
		exitBattleScene(true)
	end
end

--[[
	@des:closeBattle 关闭战斗回调 不调leve接口
--]]
function closeBattle()
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
	_bgLayer = nil

	--删除网络断开回调
	LoginScene.removeObserverForNetBroken("country_war")
	--删除重新连接回调
	if LoginScene.removeObserverForReconnect then
		LoginScene.removeObserverForReconnect("country_war")
	end

	-- 删除国战断线监听
	Network.removeCountryRegister("countreDisconnected")
	
	require "script/ui/countryWar/CountryWarMainLayer"
	CountryWarMainLayer.show()
end

--[[
	@des 	:点击传送阵按钮
	@param 	:
	@return :
--]]
function joinButtonCallback( tag, sender )
	print("joinButtonCallback", tag)

	-- 1.判断是否参战处于cd状态
	local joinCDTime = CountryWarPlaceData.getCanJoinTime() - TimeUtil.getSvrTimeByOffset(0)
	print("joinCDTime==>",joinCDTime)
	if joinCDTime > 0 then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_136"))
		return
	end
	-- 2.处于准备cd (强制cd)
	if TimeUtil.getSvrTimeByOffset(0) < CountryWarPlaceData.getQuitReadyTime() then 
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_137"))
		return
	end
	-- 3.战场结束
	print("_isBattleOver==>",_isBattleOver)
	if _isBattleOver == true then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_138"))
		return
	end
	-- 4.正在战斗
	print("_isJionBattle",_isJionBattle)
	if _isJionBattle then
		return
	end
	local nextCallFun = function ( p_outTime, p_isCDTime, p_isBattling )
		if p_isCDTime then
			return
		end
		if p_isBattling then
			_isJionBattle = true
			return
		end
		print("join tranform ok")
		showJoinButtons(false)
		addJoinBattleCDTime(p_outTime, tag)
		_isJionBattle = true

		--加入战场提示
		local contentInfo = {}
	    contentInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	    contentInfo.labelDefaultSize = 18
	    contentInfo.defaultType = "CCLabelTTF"
	    contentInfo.lineAlignment = 1
	    contentInfo.labelDefaultFont = g_sFontPangWa
	    contentInfo.elements = {
	    	{
    			text = CountryWarPlaceData.getJoinPoint(),
    			color = ccc3(0x00, 0xff, 0x18)
    		},
		}
		local pos = _bgSprite:convertToWorldSpace( ccpsprite(_joinPosXArr[tag], _joinPosYArr[tag], _bgSprite) )  
		showAlertByRichInfo(GetLocalizeStringBy("lic_1742"),contentInfo, pos)
	end 
	CountryWarController.joinTransfer(tag, nextCallFun )
end

---------------------------[[ 推送事件回调 ]]-------------------------------------
--[[
	@des:网络断开回调
--]]
function networkBreakCallback()
	_isConnect = false
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
end

--[[
	@des:重新连接回调
--]]
function networkReconnectCallback( ... )
	_isConnect = false
	if( _isShowTip == true)then
		return
	end
	_isShowTip = true
	local callback = function ( ... )
		closeBattle()
	end
	AlertTip.showAlert(GetLocalizeStringBy("lic_1766"),callback,nil,nil,nil,nil,nil,nil,false)
end

--[[
	@des :数据刷新回调
--]]
function refreshPushCallback( ... )
	--刷新第二条路的显示
	if(_bgLayer) then
		showSecondRoad()
	end
end

--[[
	@des :结算信息推送回调
--]]
function reckonPushCallback( p_resultInfo )
	print(" reckonPushCallback  over !!!")
	if(_bgLayer) then
		-- 关闭国战基金，设置界面
		CountryWarEncourageDialog.closeSelfCallback()
		CountryWarFoundationLayer.closeFunc()

		if( p_resultInfo and tonumber(p_resultInfo.point) <= 0)then
			-- 国战比赛已结束
	        local callback = function ( ... )
	            closeBattle()
	        end
	        AlertTip.showAlert(GetLocalizeStringBy("lic_1763"),callback,nil,nil,nil,nil,nil,nil,false)
	   	else
			require "script/ui/countryWar/war/CountryWarAfterLayer"
			CountryWarAfterLayer.show(_touchPriority-350, 1010, p_resultInfo)
		end
	end
end

--[[
	@des :玩家战斗胜利推送
--]]
function fightWinPushCallback( p_info )
	local isOut = false
	if p_info.extra.winnerOut == "true" then
		isOut = true
	end
	performWithDelay(_bgLayer, function ( ... )
		local userUuId = CountryWarPlaceData.getUserUuid()
		if isOut == false and _playerArray[tostring(userUuId)] then
			local pos = _playerArray[tostring(userUuId)]:convertToWorldSpace(ccp(0, 0))
			local contentInfo = {}
		    contentInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
		    contentInfo.labelDefaultSize = 18
		    contentInfo.defaultType = "CCLabelTTF"
		    contentInfo.lineAlignment = 1
		    contentInfo.labelDefaultFont = g_sFontPangWa
		    contentInfo.elements = {
		    	{
	    			text = p_info.reward.point,
	    			color = ccc3(0x00, 0xff, 0x18)
	    		},
			}
			showAlertByRichInfo(GetLocalizeStringBy("lic_1743"),contentInfo, pos)

			-- 自动回血特效
			if(p_info.hpRecover and p_info.hpRecover.cost)then
				recoverEffect()
			end

			-- 刷新国战币
			refreshCoin()
		end
	end,1)
	--如果同归于尽那么也删除掉自己
	performWithDelay(_bgLayer, function ( ... )
		if isOut ==  true  then
			fightLosePushCallback()
		end
	end,0.5)
end

--[[
	@des :玩家战败推送
--]]
function fightLosePushCallback( ... )
	if _bgLayer == nil then
		return
	end
	showJoinButtons(true)
	_isJionBattle = false
end

--[[
	@des :达阵事件推送
--]]
function touchDownPushCallback( p_info )
	if _bgLayer == nil then
		return
	end
	performWithDelay(_bgSprite, function ( ... )
		showJoinButtons(true)
		_isJionBattle = false
		local userUuid = CountryWarPlaceData.getUserUuid()
		print("userUuid", userUuid)
		local myInfo = _playerArray[userUuid].info
		print("myInfo")
		print_t(myInfo)

		-- 翻转数据
		local temTransferId = nil
		-- 如果我是攻方
		if( CountryWarPlaceData.isUserAttacker() )then 
			temTransferId = tonumber(myInfo.transferId)+1
		else
			if( tonumber(myInfo.transferId)+1 > 4 )then
				temTransferId = tonumber(myInfo.transferId)+1 - 4
			else
				temTransferId = tonumber(myInfo.transferId)+1 + 4
			end
		end
		local pos = _bgSprite:convertToWorldSpace( ccpsprite(_joinPosXArr[temTransferId+4], _joinPosYArr[temTransferId+4], _bgSprite) )  
		local contentInfo = {}
	    contentInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	    contentInfo.labelDefaultSize = 18
	    contentInfo.defaultType = "CCLabelTTF"
	    contentInfo.lineAlignment = 1
	    contentInfo.labelDefaultFont = g_sFontPangWa
		local tipStr = nil
		if( tonumber(p_info.reward.point) > 0 and tonumber(p_info.reward.resource) > 0 )then
			tipStr = GetLocalizeStringBy("lic_1745")
			contentInfo.elements = {
		    	{
	                text = p_info.reward.point,
	                color = ccc3(0x00, 0xff, 0x18)
	            },
	            {
	                text = p_info.reward.resource,
	                color = ccc3(0x00, 0xff, 0x18)
	            },
			}
		else
			tipStr = GetLocalizeStringBy("lic_1744")
			contentInfo.elements = {
		    	{
	                text = p_info.reward.point,
	                color = ccc3(0x00, 0xff, 0x18)
	            },
			}
		end
		showAlertByRichInfo(tipStr,contentInfo, pos)

		_playerArray[userUuid]:removeFromParentAndCleanup(true)
		_playerArray[userUuid] = nil
	end, 1)
end
--[[
	@des :战斗结束推送
--]]
function battleEndPushCallback( ... )
	_isBattleOver = true
end
--[[
	@des :战报推送回调
--]]
function fightResultPushCallback( p_resultInfo )
	print("add lose player id=", p_resultInfo.loserId)
	performCallfunc(function ( ... )
		if tolua.isnull(_bgLayer) then 
			return
		end
		--播放战斗特效
		local winPlayerInfo = CountryWarPlaceData.getRoadPlayerInfo(p_resultInfo.winnerId)
		local losePlayerInfo = CountryWarPlaceData.getRoadPlayerInfo(p_resultInfo.loserId)
		if winPlayerInfo ~= nil and  losePlayerInfo and winPlayerInfo.transferId then
			local transferId = tonumber(winPlayerInfo.transferId)
			local roadId  = transferId%4 + 1
			local winSprite = _playerArray[p_resultInfo.winnerId]
			local loseSprite = _playerArray[p_resultInfo.loserId]
			if winSprite ~= nil and loseSprite ~= nil then
				local maxY = math.max(winSprite:getPositionY(), loseSprite:getPositionY())
				local minY = math.min(winSprite:getPositionY(), loseSprite:getPositionY())
				local posY = minY + (maxY - minY)/2
				local posX = winSprite:getPositionX()
				playBattleEffect(_roadArray[roadId], ccp(posX, posY))
			end
		end
		table.insert(_failedPlayerArray, p_resultInfo.loserId)
		if p_resultInfo.winnerOut == "true" then
			table.insert(_failedPlayerArray, p_resultInfo.winnerId)
		end
		--连杀提示
		showStreak(p_resultInfo)
	end, 0.5)
end

-------------------------------------------------------------------- 刷新方法 -------------------------------------------------------------------------
--[[
	@des:刷新资源 进度条
--]]
function refreshResourceUI()
	if(tolua.isnull(_bgLayer))then  
		return
	end
	if(tolua.isnull(_progressSprite) or tolua.isnull(_zhongSp) or tolua.isnull(_woResourceLabel) or tolua.isnull(_diResourceLabel) )then  
		return
	end
	local woInfo = CountryWarPlaceData.getOneCountryInfo()
	local diInfo = CountryWarPlaceData.getTwoCountryInfo()
	-- 进度条
	local percentNum = CountryWarPlaceData.getResourcePercent( woInfo.resource )
	_progressSprite:setProgress(percentNum)
	_zhongSp:setPosition(270*percentNum,_progressSprite:getContentSize().height*0.5)
	-- 资源
	_woResourceLabel:setString("[" .. woInfo.resource .. "]")
	_diResourceLabel:setString("[" .. diInfo.resource .. "]")
end

--[[
	@des:刷新金币 国战币
--]]
function refreshCoin()
	if(_bgLayer ~= nil)then 
		_warCoinLabel:setString(CountryWarMainData.getCocoin())
		_goldLabel:setString(UserModel.getGoldNumber())
	end
end

--[[
	@des:回血特效
--]]
function recoverEffect()
	local userUuid = CountryWarPlaceData.getUserUuid()
	if( _playerArray[userUuid] == nil ) then 
		return
	end
	local nodeSprite = _playerArray[userUuid]

	-- 更新数据
	local myInfo = _playerArray[userUuid].info
	myInfo.curHp = myInfo.maxHp
	updatePlayer(_playerArray[userUuid].roadId, myInfo)

	-- 播放特效
	if(not tolua.isnull(_effectDown))then
		_effectDown:removeFromParentAndCleanup(true)
    	_effectDown = nil
	end
	_effectDown = XMLSprite:create("images/country_war/effect/liangcaozhanjiaxue_down/liangcaozhanjiaxue_down",nil,true)
	_effectDown:setPosition(ccpsprite(0.5, 0.25, nodeSprite))
	nodeSprite:addChild(_effectDown, -10)
    _effectDown:registerEndCallback(function ( ... )
    	if( not tolua.isnull(_effectDown) )then
			_effectDown:removeFromParentAndCleanup(true)
	    	_effectDown = nil
		end
    end)

    if( not tolua.isnull(_effectUp) )then
		_effectUp:removeFromParentAndCleanup(true)
    	_effectUp = nil
	end
    _effectUp = XMLSprite:create("images/country_war/effect/liangcaozhanjiaxue_up/liangcaozhanjiaxue_up",nil,true)
	_effectUp:setPosition(ccpsprite(0.5, 0.25, nodeSprite))
	nodeSprite:addChild(_effectUp, 10)
    _effectUp:registerEndCallback(function ( ... )
    	if( not tolua.isnull(_effectUp))then
			_effectUp:removeFromParentAndCleanup(true)
	    	_effectUp = nil
		end
    end)
end

--[[
	@des:是否显示第二条路
--]]
function showSecondRoad( ... )
	local roadState = CountryWarPlaceData.getReadState()
	local isShow = false
	if roadState == 1 then
		-- 第2、3条路隐藏
		isShow = false
	else
		isShow = true
	end
	_roadBgArray[2]:setVisible(isShow)
	_roadArray[2]:setVisible(isShow)
	_joinButtonArray[2]:setVisible(isShow)
	_tranferEffects[2]:setVisible(isShow)
	
	_roadBgArray[3]:setVisible(isShow)
	_roadArray[3]:setVisible(isShow)
	_tranferEffects[3]:setVisible(isShow)
	_joinButtonArray[3]:setVisible(isShow)
	
	_tranferEffects[6]:setVisible(isShow)

	_tranferEffects[7]:setVisible(isShow)
end

--[[
	@des: 显示或者隐藏join按钮
--]]
function showJoinButtons( p_isShow )
	_isJoinButtonShow = p_isShow
	for i=1,4 do
		_joinButtonArray[i]:setVisible(p_isShow)
	end
	showSecondRoad()
end

--[[
	@des:删除玩家
--]]
function removePlayer( p_playerId, kType )
	if(p_playerId ~= CountryWarPlaceData.getUserUuid() ) then 
		_playerArray[p_playerId]:removeFromParentAndCleanup(true)
		_playerArray[p_playerId] = nil
	end
end

--[[
	@des:踢飞特效
--]]
function removeByAction( p_playerId, kType )
	local nodeSprite = _playerArray[p_playerId]
	local pos = nodeSprite:convertToWorldSpace(ccpsprite(0.5, 0.5, nodeSprite))
	nodeSprite:retain()
	nodeSprite:removeFromParentAndCleanup(false)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(nodeSprite, 500)
	nodeSprite:release()
	_playerArray[p_playerId] = nil
	nodeSprite:setScale(MainScene.elementScale * 0.6)
	nodeSprite:setPosition(pos)

	local moveX = 600*MainScene.elementScale
	local moveY = 600*MainScene.elementScale

	-- 翻转数据
	local temTransferId = nil
	-- 如果我是攻方
	if( CountryWarPlaceData.isUserAttacker() )then 
		temTransferId = tonumber(nodeSprite.info.transferId)+1
	else
		if( tonumber(nodeSprite.info.transferId)+1 > 4 )then
			temTransferId = tonumber(nodeSprite.info.transferId)+1 - 4
		else
			temTransferId = tonumber(nodeSprite.info.transferId)+1 + 4
		end
	end
	if(temTransferId < 5) then
		moveY = -moveY
	end
	local spwan = CCSpawn:createWithTwoActions(CCRotateTo:create(1,360*20), CCMoveBy:create(1,ccp(moveX,moveY)))
	local callFunc = CCCallFuncN:create(function ( p_actionNode )
		p_actionNode:removeFromParentAndCleanup(true)
	end)
	local actionArray = CCArray:create()
	actionArray:addObject(spwan)
	actionArray:addObject(callFunc)
	local seq = CCSequence:create(actionArray)
	nodeSprite:runAction(seq)
end

--[[
	@des:更新路上所有玩家信息
--]]
function updatePlayerInfo( p_roadId, p_playerInfo )
	--[[
		如果玩家没有在_playerArray 中则玩家不在屏幕上，那么就创建一个新的玩家出来，再把他添加到_playerArray里面，
		如果玩家已达阵，掉下，退出战场，那么就把这个玩家从屏幕上删除掉。
	]]--
	if(_playerArray[p_playerInfo.id] == nil and p_playerInfo.exit == nil) then
		-- 翻转数据
		local temTransferId = nil
		-- 如果我是攻方
		if( CountryWarPlaceData.isUserAttacker() )then 
			temTransferId = tonumber(p_playerInfo.transferId)+1
		else
			if( tonumber(p_playerInfo.transferId)+1 > 4 )then
				temTransferId = tonumber(p_playerInfo.transferId)+1 - 4
			else
				temTransferId = tonumber(p_playerInfo.transferId)+1 + 4
			end
		end
		--创建新玩家
		_nowDefenderZorder = _nowDefenderZorder - 1
		_nowAttackerZorder = _nowAttackerZorder + 1
		_playerArray[p_playerInfo.id] = createPlayer(p_playerInfo)
		_playerArray[p_playerInfo.id]:setPosition(BRON_POS[(temTransferId-1)%4 + 1].x, BRON_POS[(temTransferId-1)%4 + 1].y)
		_roadArray[(temTransferId-1)%4+1]:addChild(_playerArray[p_playerInfo.id], 0)
		
		_playerArray[p_playerInfo.id].roadX = p_playerInfo.roadX
		_playerArray[p_playerInfo.id].info = p_playerInfo
		_playerArray[p_playerInfo.id].roadId = p_roadId
		if(temTransferId > 4) then
			_playerArray[p_playerInfo.id].rTime = 1
			_roadArray[(temTransferId-1)%4+1]:reorderChild(_playerArray[p_playerInfo.id],_nowDefenderZorder)
		else
			_playerArray[p_playerInfo.id].rTime = -1
			_roadArray[(temTransferId-1)%4+1]:reorderChild(_playerArray[p_playerInfo.id],_nowAttackerZorder)
		end
	else
		if(_playerArray[p_playerInfo.id] ~= nil and _playerArray[p_playerInfo.id].isLose == nil) then
			_playerArray[p_playerInfo.id].info = p_playerInfo
		end
	end
end

--[[
	@de: 战斗玩家位置刷新定时器
--]]
function refreshTimer( p_timer )
	print("curTime:",TimeUtil.getSvrTimeByOffset(0))
	print("p_timer:",p_timer)
	_timer = p_timer
	local fieldInfos = CountryWarPlaceData.getEnterInfo().field
	if table.isEmpty(fieldInfos) then
		return
	end 
	--刷新战场玩家数据
	local roadInfos  = fieldInfos.road
	-- print("roadInfos==>") print_t(roadInfos)
	for k,v in pairs(roadInfos) do
		if(v.transferId ~= nil) then
			local roadId = tonumber(v.transferId)%4 + 1
			updatePlayerInfo(roadId, v)
		end
	end

	--更新场上玩家
	for k,v in pairs(_playerArray) do
		updatePlayer(v.roadId, v.info)
	end
	
	--清除达阵玩家
	fieldInfos.touchdown = fieldInfos.touchdown or {}
	for k,v in pairs(fieldInfos.touchdown) do
		if(_playerArray[v]) then
			performWithDelay(_bgSprite, function ( ... )
				removePlayer(v, kRomveTouchDown)
				print("清除达阵玩家")
			end,1)
		end
	end
	fieldInfos.touchdown = {}

	--清除掉线玩家
	fieldInfos.leave = fieldInfos.leave or {}
	for k,v in pairs(fieldInfos.leave) do
		if(_playerArray[v]) then
			removePlayer(v, kRomveLeave)
			print("清除达阵玩家")
		end
	end
	fieldInfos.leave = {}

	--清除战败玩家
	for k,v in pairs(_failedPlayerArray) do
		if(_playerArray[v]) then
			removeByAction(v, kRomveLose)
			print("remove from _failedPlayerArray id=", v)
		end
	end
	_failedPlayerArray = {}

	-- 决赛时 刷新资源
	local curStage = CountryWarMainData.getCurStage()
	if( curStage == CountryWarDef.FINALTION_READY or curStage == CountryWarDef.FINALTION )then
		refreshResourceUI()
	end
end

--[[
	@des: 更新单个玩家信息
--]]
function updatePlayer(p_roadId, p_playerInfo )

	local playerSprite = _playerArray[p_playerInfo.id]
	if playerSprite == nil then
		return
	end
	--更新位置
	local Lc = 0 	-- 前端路线总长度
	for k,v in pairs(ROAD_DATA[p_roadId]) do
		Lc = Lc + math.abs(v.value)
	end

	local Lh = CountryWarPlaceData.getServerRoadLength(p_roadId)
	local Vh = tonumber(p_playerInfo.speed) * 1000
	local Ph = 0

	--判断守方和攻方
	local roadPathData = ROAD_DATA[p_roadId]

	local temTransferId = nil
	-- 如果我是攻方
	if( CountryWarPlaceData.isUserAttacker() )then 
		temTransferId = tonumber(p_playerInfo.transferId)+1
		Ph = tonumber(playerSprite.roadX)
	else
		if( tonumber(p_playerInfo.transferId)+1 > 4 )then
			temTransferId = tonumber(p_playerInfo.transferId)+1 - 4
		else
			temTransferId = tonumber(p_playerInfo.transferId)+1 + 4
		end
		Ph = Lh - tonumber(playerSprite.roadX)
	end
	if(temTransferId <= 4) then
		playerSprite.rTime = playerSprite.rTime + _timer
	else
		-- 守方反向行走
		playerSprite.rTime = playerSprite.rTime - _timer
	end

	local Vc = Lc/(Lh/Vh)
	local t = Ph/Vh + playerSprite.rTime
	local Pc = Vc * t

	local Sx,Sy,sign = 0,0,1 --分别为出生点到玩家位置x,y的位移量 ,sign是位移方向
	if(Pc < 0) then
		playerSprite:setVisible(false)
	else
		playerSprite:setVisible(true)
	end
	--计算位移量
	local lastW = Pc  -- 最后一段位移
	for i=1, #roadPathData do
		local v = roadPathData[i]
		if(lastW - math.abs(v.value) > 0) then
			if(v.dir == "x") then
				Sx = Sx + v.value
			elseif(v.dir == "y") then
				Sy = Sy + v.value
			else
				error("error dir for ROAD_DATA")
			end
			lastW = lastW - math.abs(v.value)
		else
			if(v.dir == "x") then
				Sx = Sx + lastW * v.valpue * (1/math.abs(v.value))
			elseif(v.dir == "y") then
				Sy = Sy + lastW * v.value * (1/math.abs(v.value))
			else
				error("error dir for ROAD_DATA")
			end
			break
		end
	end
	Sx,Sy = Sx*sign, Sy*sign
	local bronPos = BRON_POS[ (temTransferId-1)%4 + 1 ]
	playerSprite:setPosition(ccp(bronPos.x + Sx, bronPos.y + Sy))
	-- print(string.format("Sx=%f,Sy=%f,Vh=%f,Ph=%f,Lh=%f,Lc=%f,Pc=%f,t=%f,sign=%f,lastW=%f,bronPos.y=%f", Sx,Sy,Vh,Ph,Lh,Lc,Pc,t,sign,lastW,bronPos.y))
	playerSprite.pos = ccp(playerSprite:getPositionX(), playerSprite:getPositionY())
	--更新血量
	local bloodSprite = playerSprite.blood --tolua.cast(playerSprite:getChildByTag(kPlayerBloodTag), "CCProgressTimer")
	bloodSprite:setScaleX(tonumber(p_playerInfo.curHp)/tonumber(p_playerInfo.maxHp))
	--更新名称颜色
	local nameLabel = tolua.cast(playerSprite:getChildByTag(kPlayerNameTag), "CCLabelTTF")
	nameLabel:setColor(getNameColorByStreak(p_playerInfo.winStreak))
end

--[[
	@des: 检查是否可以加入战场，如果可以，自动加入
--]]
function checkAutoJoin( ... )
	if( _isConnect == false)then
		return
	end
	
	_isAutoEnter = CountryWarEncourageData.getAutoBattleState()
	if _isAutoEnter ~= true then
		return
	end
	if _isJionBattle then
		return
	end
	if _isBattleOver == true then
		return
	end

	--找到等待人数最少的传送阵
	local roadState = CountryWarPlaceData.getReadState()
	local minRoadNum = 1
	for i=1,1000 do
		minRoadNum = math.random(4)
		if CountryWarPlaceData.getReadState() == 1 then
			if minRoadNum%4 ~= 2 and minRoadNum%4 ~= 3 then
				break
			end
		end
	end
	joinButtonCallback(minRoadNum, nil)
end

--[[
	@des: 得到玩家是否加入战场
--]]
function getIsJoinBattle( ... )
	return _isJionBattle
end
-------------------------------------------------------------------- 创建UI -------------------------------------------------------------------------
--[[
	@des: 连胜和连胜被终结
--]]
function showStreak( p_resultInfo  )
	print("showStreak==>")
	print_t(p_resultInfo)
	
	local showAlert = function ( p_stringTable, p_colorTable )

		-- 内容
	    local textInfo = {
	     		width = 400, -- 宽度
		        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
		        labelDefaultFont = g_sFontPangWa,      -- 默认字体
		        labelDefaultSize = 21,          -- 默认字体大小
		        elements = {}
		 	}

		for i=1,#p_stringTable do
			local tab = {}
			tab.type = "CCLabelTTF"
			tab.text = p_stringTable[i] 
		    tab.color = p_colorTable[i]
			table.insert(textInfo.elements, tab)
		end

	 	local contentNode = LuaCCLabel.createRichLabel(textInfo)

		local alertBg = CCScale9Sprite:create("images/guild_rob/s_bg.png")
		alertBg:setAnchorPoint(ccp(0.5, 0.5))
		alertBg:setPosition(ccps(0.5, 0.5))
		_bgLayer:addChild(alertBg, 300)
		alertBg:setContentSize(CCSizeMake(contentNode:getContentSize().width + 20, contentNode:getContentSize().height + 10))

		contentNode:setAnchorPoint(ccp(0.5, 0.5))
		contentNode:setPosition(ccpsprite(0.5, 0.5, alertBg))
		alertBg:addChild(contentNode)
		alertBg:setScale(MainScene.elementScale)

		local actionArray = CCArray:create()
		actionArray:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(5),CCMoveBy:create(5, ccp(0, 60))))
		actionArray:addObject(CCCallFunc:create(function ( ... )
			alertBg:removeFromParentAndCleanup(true)
			alertBg = nil
		end))
		local seqAction = CCSequence:create(actionArray)
		alertBg:runAction(seqAction)

		contentNode:setCascadeOpacityEnabled(true)
		contentNode:runAction(CCFadeOut:create(5))
	end

	local showString = nil
	local colorStr 	 = nil
	require "db/DB_National_war_win"
	local allTipNum = table.count(DB_National_war_win.National_war_win)
	--连胜提示
	for i=1, allTipNum do
		local dataInfo = DB_National_war_win.getDataById(i)
		if tonumber(dataInfo.number) == tonumber(p_resultInfo.winStreak) then
			showString = dataInfo.winspeak
			colorStr = dataInfo.wincolor
			break
		end
	end
	if showString then
		local strTab = string.split(showString, "|")
		local curIndex = math.random(#strTab)
		local curStr = strTab[curIndex]
		curStr = string.gsub(curStr, "xxx", p_resultInfo.winnerName)
		local pointNum = CountryWarPlaceData.getKillPoint( p_resultInfo.winStreak )
		print("pointNum==>",pointNum,type(pointNum))
		curStr = string.gsub(curStr, "n", tostring(pointNum))
		print("curStr",curStr)
		curStr = string.split(curStr, "{1}")
		local colorStrTab = string.split(colorStr, "{1}")
		local colorTab = {}
		for i=1, #colorStrTab do
			local tem = string.split(colorStrTab[i], ",")
			local temColor = ccc3(tonumber(tem[1]), tonumber(tem[2]), tonumber(tem[3]))
			table.insert(colorTab,temColor)
		end
		showAlert(curStr, colorTab)
		print("连胜提示 curStr")
		print_t(curStr)
		print_t(colorTab)
	end
	showString = nil
	colorStr = nil
	--连胜被终结
	local baseWinNum = tonumber(DB_National_war_win.getDataById(1).endwinnumber)
	for i=1,allTipNum do
		local dataInfo = DB_National_war_win.getDataById(i)
		if tonumber(dataInfo.endwinnumber) <= tonumber(p_resultInfo.terminalStreak) and tonumber(p_resultInfo.terminalStreak) >= baseWinNum then
			showString = dataInfo.endwin
			colorStr = dataInfo.endwincolor
			break
		end
	end
	if showString then
		local strTab = string.split(showString, "|")
		local curIndex = math.random(#strTab)
		local curStr = strTab[curIndex]

		curStr = string.gsub(curStr, "yyy", p_resultInfo.winnerName)
		curStr = string.gsub(curStr, "xxx", p_resultInfo.loserName)
		curStr = string.gsub(curStr, "{n}", p_resultInfo.terminalStreak)
		local pointNum = CountryWarPlaceData.getEndKillPoint( p_resultInfo.terminalStreak )
		print("terminalPointNum==>",pointNum,type(pointNum))
		curStr = string.gsub(curStr, "n", tostring(pointNum))
		print("curStr",curStr)
		curStr = string.split(curStr, "{1}")
		local colorStrTab = string.split(colorStr, "{1}")
		local colorTab = {}
		for i=1, #colorStrTab do
			local tem = string.split(colorStrTab[i], ",")
			local temColor = ccc3(tonumber(tem[1]), tonumber(tem[2]), tonumber(tem[3]))
			table.insert(colorTab,temColor)
		end
		showAlert(curStr, colorTab)
		print("连胜被终结 curStr")
		print_t(curStr)
	end
end
--[[
	@des: 添加出场cd 时间
--]]
function addJoinBattleCDTime( p_cdTimer, p_tranferId )
	local tranferId = p_tranferId
	_goBattleRoadTime = tonumber(p_cdTimer)-TimeUtil.getSvrTimeByOffset(0)
	print("_goBattleRoadTime==>",_goBattleRoadTime)
	-- local cdTitleLabel = CCRenderLabel:create( GetLocalizeStringBy("lcyx_123"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local cdTitleLabel = CCLabelTTF:create( GetLocalizeStringBy("lcyx_123"), g_sFontName, 18)
	cdTitleLabel:setColor(ccc3(0x00, 0xff, 0x18))

	-- local cdTimeLabel = CCRenderLabel:create(TimeUtil.getTimeString(_goBattleRoadTime), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local cdTimeLabel = CCLabelTTF:create(TimeUtil.getTimeString(_goBattleRoadTime), g_sFontName, 18)
	cdTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))

	local cdInfoNode = BaseUI.createVerticalNode({cdTitleLabel,cdTimeLabel})
	cdInfoNode:setAnchorPoint(ccp(0.5, 0))
	local pos = ccp( _bgSprite:getContentSize().width*_joinPosXArr[tranferId], _bgSprite:getContentSize().height*_joinPosYArr[tranferId] + 40)
	cdInfoNode:setPosition(pos)
	_bgSprite:addChild(cdInfoNode)

	if(tonumber(_goBattleRoadTime) <= 0) then
		cdInfoNode:setVisible(false)
	end
	schedule(cdInfoNode, function ( ... )
		_goBattleRoadTime = _goBattleRoadTime  - 1
		if(_goBattleRoadTime <= 0) then
			_goBattleRoadTime = 0
			cdInfoNode:removeFromParentAndCleanup(true)
			cdInfoNode = nil
		else
			cdTimeLabel:setString(TimeUtil.getTimeString(_goBattleRoadTime))
			cdInfoNode:setVisible(true)
		end
	end, 1)
end

--[[
	@des: 播放战斗碰撞特效
--]]
function playBattleEffect( p_baseNode, p_pos )
	print("playBattleEffect")
	AudioUtil.playEffect("audio/effect/pengzhuang.mp3")
	local effect =  XMLSprite:create("images/guild_rob/effect/pengzhuang/pengzhuang",nil,true)
	effect:setPosition(p_pos)
	p_baseNode:addChild(effect, 100)
    effect:registerEndCallback(function ( ... )
    	effect:removeFromParentAndCleanup(true)
    	effect = nil
    end)
end

--[[
	@des: 战斗开始特效
--]]
function playerBattleStartEffect( ... )
	local scene = CCDirector:sharedDirector():getRunningScene()
	local effect =  XMLSprite:create("images/guild_rob/effect/zhandoukaishi/zhandoukaishi",nil,true)
	effect:setPosition(ccps(0.5, 0.5))
	scene:addChild(effect, 100)
	effect:setScale(MainScene.elementScale)
    effect:registerEndCallback(function ( ... )
    	effect:removeFromParentAndCleanup(true)
    	effect = nil
    end)
end

--[[
	@:显示消息提示
--]]
function showAlertByRichInfo( p_richString, p_richInfo, p_pos)
	local richInfo = p_richInfo or {}
	local richString = p_richString or ""
	local pos = p_pos or ccps(0.5, 0.8)
	local alertBg = CCScale9Sprite:create("images/common/bg/9s_guild.png")
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	alertBg:setPosition(pos)
	_bgLayer:addChild(alertBg, 300)
	alertBg:setScale(MainScene.elementScale)
	
	contentNode = GetLocalizeLabelSpriteBy_2(richString, richInfo)
	alertBg:setContentSize(CCSizeMake(contentNode:getContentSize().width + 20, contentNode:getContentSize().height + 10))
	contentNode:setAnchorPoint(ccp(0.5, 0.5))
	contentNode:setPosition(ccpsprite(0.5, 0.5, alertBg))
	alertBg:addChild(contentNode)

	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveBy:create(3, ccp(0, 80)))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		alertBg:removeFromParentAndCleanup(true)
		alertBg = nil
	end))
	local seqAction = CCSequence:create(actionArray)
	alertBg:runAction(seqAction)
end
--[[
	@des: 根据连胜次数得到玩家名称颜色
--]]
function getNameColorByStreak( p_streakNum )
	-- 颜色分别物品品质颜色
	require "db/DB_National_war"
	local data = DB_National_war.getDataById(1)
	local streakStrTab = string.split(data.kill_color,",")
	local streakTab = {}
	local qualityTab = {}
	for i=1,#streakStrTab do
		local tem = string.split(streakStrTab[i],"|")
		table.insert(streakTab,tonumber(tem[1]))
		table.insert(qualityTab,tonumber(tem[2]))
	end
	local streakNum = p_streakNum or 0
	local retColor = nil
	for i=1,#streakTab do
		if tonumber(streakNum) >= streakTab[i] then
			retColor = HeroPublicLua.getCCColorByStarLevel(qualityTab[i])
		end
		if tonumber(streakNum) < streakTab[1] then
			retColor = HeroPublicLua.getCCColorByStarLevel(2)
		end
	end
	return retColor
end

--[[
	@des: 准备倒计时
--]]
function showReadLayer()
	_readyTime = CountryWarPlaceData.getReadyTime()
	if(_readyTime <= 0) then
		return
	end
	local alertBg = CCScale9Sprite:create("images/tip/animate_tip_bg.png")
	alertBg:setContentSize(CCSizeMake(340, 105))
	alertBg:setPosition(ccps(0.5, 0.5))
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	_bgLayer:addChild(alertBg, 1000)
	alertBg:setScale(MainScene.elementScale)

	-- local readTimeTitle = CCRenderLabel:create( GetLocalizeStringBy("lic_1764") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local readTimeTitle = CCLabelTTF:create( GetLocalizeStringBy("lic_1764") , g_sFontPangWa, 21)
	readTimeTitle:setColor(ccc3(0xff, 0xf6, 0x00))
	readTimeTitle:setAnchorPoint(ccp(0.5, 1))
	readTimeTitle:setPosition(ccpsprite(0.5, 0.9, alertBg))
	alertBg:addChild(readTimeTitle)

	-- local readTimeLabel = CCRenderLabel:create(TimeUtil.getTimeString(_readyTime), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local readTimeLabel = CCLabelTTF:create(TimeUtil.getTimeString(_readyTime), g_sFontPangWa, 21)
	readTimeLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	readTimeLabel:setAnchorPoint(ccp(0.5, 0))
	readTimeLabel:setPosition(ccpsprite(0.5, 0.1, alertBg))
	alertBg:addChild(readTimeLabel)
	-- 准备时间刷新
	schedule(alertBg, function ( ... )
		_readyTime = _readyTime -1
		readTimeLabel:setString(TimeUtil.getTimeString(_readyTime))
		if(_readyTime < 1) then
			alertBg:removeFromParentAndCleanup(true)
			alertBg = nil
			playerBattleStartEffect()
		end
		print("_readyTime", _readyTime)
	end, 1)

end

--[[
	@des: 创建战场玩家
--]]
function createPlayer(p_playerInfo )

	-- 翻转数据
	local temTransferId = nil
	-- 如果我是攻方
	if( CountryWarPlaceData.isUserAttacker() )then 
		temTransferId = tonumber(p_playerInfo.transferId)+1
	else
		if( tonumber(p_playerInfo.transferId)+1 > 4 )then
			temTransferId = tonumber(p_playerInfo.transferId)+1 - 4
		else
			temTransferId = tonumber(p_playerInfo.transferId)+1 + 4
		end
	end

	local iconPath = 1
	if(HeroModel.getSex(p_playerInfo.tid) == 1) then
		--男
		if temTransferId > 4 then
			--守方玩家
			iconPath =	"images/guild_rob/role/lcdh_a1/lcdh_a1"
		else
			--攻方玩家
			iconPath = "images/guild_rob/role/lcdh_a2/lcdh_a2"
		end
	else
		--女
		if temTransferId > 4 then
			--守方玩家
			iconPath = "images/guild_rob/role/lcdh_b2/lcdh_b2"
		else
			--攻方玩家
			iconPath = "images/guild_rob/role/lcdh_b1/lcdh_b1"
		end
	end
	--人物
	local playerSprite = nil
	playerSprite = XMLSprite:create(iconPath,nil,true)
	playerSprite:setAnchorPoint(ccp(0.5,0.5))
	playerSprite:setContentSize(CCSizeMake(67, 200))
	playerSprite:setScale(0.6)
	--血量背景
	local bloodBg = CCSprite:create("images/guild_rob/blod_bg.png")
	bloodBg:setAnchorPoint(ccp(0.5, 0.5))
	bloodBg:setPosition(ccpsprite(0.5 , 0.85, playerSprite))
	playerSprite:addChild(bloodBg)

	--血量
	local bloodSprite = CCSprite:create("images/guild_rob/blod.png")
	bloodSprite:setPosition(ccpsprite(0 , 0.5, bloodBg))
	bloodSprite:setAnchorPoint(ccp(0, 0.5))
	bloodBg:addChild(bloodSprite, 1, kPlayerBloodTag)
    bloodSprite:setScaleX(tonumber(p_playerInfo.curHp)/tonumber(p_playerInfo.maxHp))
    playerSprite.blood = bloodSprite

    --名称
    -- local nameLabel = CCRenderLabel:create(p_playerInfo.name, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    local nameLabel = CCLabelTTF:create(p_playerInfo.name, g_sFontName, 25)
    nameLabel:setColor(ccc3(0x00, 0xff, 0x18))
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    nameLabel:setPosition(ccpsprite(0.5, 1, playerSprite))
    playerSprite:addChild(nameLabel, 1, kPlayerNameTag)

    -- 如果是自己的话加一个光圈特效
    local userUuid = CountryWarPlaceData.getUserUuid()
    if( tonumber(userUuid) == tonumber(p_playerInfo.id) )then
		local myEffect = XMLSprite:create("images/country_war/effect/guanghuan/guanghuan",nil,true)
		myEffect:setPosition(ccpsprite(0.5, 0.25, playerSprite))
		playerSprite:addChild(myEffect, -10)
	end

    return playerSprite
end

--[[
	@des 	: 创建初赛倒计时
	@param 	: 
	@return : 
--]]
function createAuditionTopUI( ... )
	-- 背景
	local fontBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	fontBg:setContentSize(CCSizeMake(400,40))
	fontBg:setAnchorPoint(ccp(0.5,0.5))
	fontBg:setPosition(ccp(_topBg:getContentSize().width*0.5,_topBg:getContentSize().height*0.7))
	_topBg:addChild(fontBg)
	-- 比赛时间
	local bisaiSp = CCSprite:create("images/country_war/bisai.png")
	bisaiSp:setAnchorPoint(ccp(1,0.5))
	bisaiSp:setPosition(ccp(fontBg:getContentSize().width*0.5,fontBg:getContentSize().height*0.5))
	fontBg:addChild(bisaiSp)
	bisaiSp:setScale(0.7)
	-- 时间描述
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local atkEndTime = CountryWarPlaceData.getBattleEndTime()
	local subTime = atkEndTime - curTime
	local timeStr = TimeUtil.getTimeString(subTime)
	-- _auditionTimeLabel = CCRenderLabel:create(timeStr, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_auditionTimeLabel = CCLabelTTF:create(timeStr, g_sFontPangWa, 35)
	_auditionTimeLabel:setColor(ccc3(0xff,0xf6,0x00))
	_auditionTimeLabel:setAnchorPoint(ccp(0,0.5))
	_auditionTimeLabel:setPosition(ccp(bisaiSp:getPositionX()+10,bisaiSp:getPositionY()))
	fontBg:addChild(_auditionTimeLabel)
	_auditionTimeLabel:setScale(0.7)
	local refreshTimeDesNode = function ( ... )
		subTime = subTime-1
		if( subTime < 0)then
			subTime = 0
		end
		local timeStr = TimeUtil.getTimeString(subTime)
		_auditionTimeLabel:setString(timeStr)
	end
	schedule(fontBg, refreshTimeDesNode, 1)
end

--[[
	@des 	: 创建决赛倒计时
	@param 	: 
	@return : 
--]]
function createFinaltionTopUI( ... )

	local woInfo = CountryWarPlaceData.getOneCountryInfo()
	local diInfo = CountryWarPlaceData.getTwoCountryInfo()
	local countryInfo = CountryWarMainData.getForceInfo()
	local mySide = CountryWarMainData.getMySide()
	local enemySide = CountryWarMainData.getEnemySide()
	local mySideInfo = countryInfo[tostring(mySide)]
	local enemySideInfo = countryInfo[tostring(enemySide)]
	-- 魏蜀吴群
	local cStrTab = { GetLocalizeStringBy("lic_1758"),GetLocalizeStringBy("lic_1759"),GetLocalizeStringBy("lic_1760"),GetLocalizeStringBy("lic_1761") }
	-- 我方
	local wofangSp = CCSprite:create("images/country_war/wofang.png")
	wofangSp:setAnchorPoint(ccp(0.5,0.5))
	wofangSp:setPosition(ccp(130,_topBg:getContentSize().height-43))
	_topBg:addChild(wofangSp)
	-- local wofangLabel = CCRenderLabel:create(cStrTab[tonumber(mySideInfo[1])]..cStrTab[tonumber(mySideInfo[2])], g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local wofangLabel = CCLabelTTF:create(cStrTab[tonumber(mySideInfo[1])]..cStrTab[tonumber(mySideInfo[2])], g_sFontName, 18)
	wofangLabel:setColor(ccc3(0xff,0x00,0x00))
	wofangLabel:setAnchorPoint(ccp(0.5,0.5))
	wofangLabel:setPosition(ccp(wofangSp:getPositionX(),wofangSp:getPositionY()-50))
	_topBg:addChild(wofangLabel)

	-- 敌方
	local difangSp = CCSprite:create("images/country_war/difang.png")
	difangSp:setAnchorPoint(ccp(0.5,0.5))
	difangSp:setPosition(ccp(_topBg:getContentSize().width-130,_topBg:getContentSize().height-43))
	_topBg:addChild(difangSp)
	-- local difangLabel = CCRenderLabel:create(cStrTab[tonumber(enemySideInfo[1])]..cStrTab[tonumber(enemySideInfo[2])], g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local difangLabel = CCLabelTTF:create(cStrTab[tonumber(enemySideInfo[1])]..cStrTab[tonumber(enemySideInfo[2])], g_sFontName, 18)
	difangLabel:setColor(ccc3(0x00,0xfc,0xff))
	difangLabel:setAnchorPoint(ccp(0.5,0.5))
	difangLabel:setPosition(ccp(difangSp:getPositionX(),difangSp:getPositionY()-50))
	_topBg:addChild(difangLabel)

	-- 我方 V/S 敌方
	local wofangFontSp = CCSprite:create("images/country_war/wo_font.png")
	wofangFontSp:setAnchorPoint(ccp(0.5,0.5))
	wofangFontSp:setPosition(ccp(264,_topBg:getContentSize().height-25))
	_topBg:addChild(wofangFontSp)

	local vsSp = CCSprite:create("images/arena/vs.png")
	vsSp:setAnchorPoint(ccp(0.5,0.5))
	vsSp:setPosition(ccp(_topBg:getContentSize().width*0.5,_topBg:getContentSize().height-25))
	_topBg:addChild(vsSp)
	vsSp:setScale(0.5)

	local difangFontSp = CCSprite:create("images/country_war/di_font.png")
	difangFontSp:setAnchorPoint(ccp(0.5,0.5))
	difangFontSp:setPosition(ccp(_topBg:getContentSize().width-264,_topBg:getContentSize().height-25))
	_topBg:addChild(difangFontSp)

	-- 时间描述
	-- local timeTipLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1754"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local timeTipLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1754"), g_sFontName, 18)
	timeTipLabel:setColor(ccc3(0xff,0xff,0xff))
	timeTipLabel:setAnchorPoint(ccp(1,0.5))
	timeTipLabel:setPosition(ccp(346,_topBg:getContentSize().height-60))
	_topBg:addChild(timeTipLabel)

	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local atkEndTime = CountryWarPlaceData.getBattleEndTime()
	local subTime = atkEndTime - curTime
	local timeStr = TimeUtil.getTimeString(subTime)
	-- _finaltionTimeLabel = CCRenderLabel:create(timeStr, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_finaltionTimeLabel = CCLabelTTF:create(timeStr, g_sFontName, 18)
	_finaltionTimeLabel:setColor(ccc3(0xff,0xff,0xff))
	_finaltionTimeLabel:setAnchorPoint(ccp(0,0.5))
	_finaltionTimeLabel:setPosition(ccp(timeTipLabel:getPositionX()+3,timeTipLabel:getPositionY()))
	_topBg:addChild(_finaltionTimeLabel)
	local refreshTimeDesNode = function ( ... )
		subTime = subTime-1
		if( subTime < 0)then
			subTime = 0
		end
		local timeStr = TimeUtil.getTimeString(subTime)
		_finaltionTimeLabel:setString(timeStr)
	end
	schedule(_topBg, refreshTimeDesNode, 1)

	-- 资源
	local progressBgSprite = CCScale9Sprite:create("images/common/jin_bg.png")
	progressBgSprite:setContentSize(CCSizeMake(280,13))
	progressBgSprite:setAnchorPoint(ccp(0.5,0.5))
	progressBgSprite:setPosition(ccp(_topBg:getContentSize().width*0.5,_topBg:getContentSize().height-80))
	_topBg:addChild(progressBgSprite)

	local percentNum = CountryWarPlaceData.getResourcePercent( woInfo.resource )
	require "script/ui/guildBossCopy/ProgressBar"
    _progressSprite = ProgressBar:create("images/common/jin_lan.png", "images/common/jin_hong.png", 272, percentNum, true, nil, false)
    _progressSprite:setAnchorPoint(ccp(0.5,0.5))
    _progressSprite:setPosition(ccp(progressBgSprite:getContentSize().width*0.5, progressBgSprite:getContentSize().height*0.5))
    progressBgSprite:addChild(_progressSprite,20)
    _progressSprite:setProgressLabelVisible( false )

    _zhongSp = CCSprite:create("images/common/jin_zhong.png")
    _zhongSp:setAnchorPoint(ccp(0.5,0.5))
    _zhongSp:setPosition(270*percentNum,_progressSprite:getContentSize().height*0.5)
    _progressSprite:addChild(_zhongSp,10)

    -- 我方资源
    -- local ziyuanLabel1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1755"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    local ziyuanLabel1 = CCLabelTTF:create(GetLocalizeStringBy("lic_1755"), g_sFontName, 18)
	ziyuanLabel1:setColor(ccc3(0xff,0xff,0xff))
	ziyuanLabel1:setAnchorPoint(ccp(0,0.5))
	ziyuanLabel1:setPosition(ccp(0,-20))
	progressBgSprite:addChild(ziyuanLabel1)

	-- _woResourceLabel = CCRenderLabel:create("[" .. woInfo.resource .. "]", g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_woResourceLabel = CCLabelTTF:create("[" .. woInfo.resource .. "]", g_sFontName, 18)
	_woResourceLabel:setColor(ccc3(0xff,0xff,0xff))
	_woResourceLabel:setAnchorPoint(ccp(0,0.5))
	_woResourceLabel:setPosition(ccp(ziyuanLabel1:getPositionX()+ziyuanLabel1:getContentSize().width+3,ziyuanLabel1:getPositionY()))
	progressBgSprite:addChild(_woResourceLabel)

	-- 敌方资源
	-- local ziyuanLabel2 = CCRenderLabel:create(GetLocalizeStringBy("lic_1755"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local ziyuanLabel2 = CCLabelTTF:create(GetLocalizeStringBy("lic_1755"), g_sFontName, 18)
	ziyuanLabel2:setColor(ccc3(0xff,0xff,0xff))
	ziyuanLabel2:setAnchorPoint(ccp(0,0.5))
	ziyuanLabel2:setPosition(ccp(180,-20))
	progressBgSprite:addChild(ziyuanLabel2)

	-- _diResourceLabel = CCRenderLabel:create("[" .. diInfo.resource .. "]", g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_diResourceLabel = CCLabelTTF:create("[" .. diInfo.resource .. "]", g_sFontName, 18)
	_diResourceLabel:setColor(ccc3(0xff,0xff,0xff))
	_diResourceLabel:setAnchorPoint(ccp(0,0.5))
	_diResourceLabel:setPosition(ccp(ziyuanLabel2:getPositionX()+ziyuanLabel2:getContentSize().width+3,ziyuanLabel2:getPositionY()))
	progressBgSprite:addChild(_diResourceLabel)
end


--[[
	@des 	: 创建上部分ui
	@param 	: 
	@return : 
--]]
function createTopUI( ... )
	-- 战斗力 国战基金
	local titleBg = CCSprite:create("images/common/top_bg1.png")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height)
    _bgLayer:addChild(titleBg)
    titleBg:setScale(g_fScaleX)
    -- 战斗力
    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(titleBg:getContentSize().width*0.13,titleBg:getContentSize().height*0.43)
    titleBg:addChild(powerDescLabel)

    -- local powerLabel = CCRenderLabel:create( tonumber(UserModel.getFightForceValue()), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    local powerLabel = CCLabelTTF:create( tonumber(UserModel.getFightForceValue()), g_sFontName, 23)
    powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    powerLabel:setAnchorPoint(ccp(0,0.5))
    powerLabel:setPosition(titleBg:getContentSize().width*0.23,titleBg:getContentSize().height*0.47)
    titleBg:addChild(powerLabel)

    -- 国战币
    local warCoinSp = CCSprite:create("images/common/countrycoin.png")
    warCoinSp:setAnchorPoint(ccp(0,0.5))
    warCoinSp:setPosition(titleBg:getContentSize().width*0.55,titleBg:getContentSize().height*0.47)
    titleBg:addChild(warCoinSp)
    local num = CountryWarMainData.getCocoin() 
    _warCoinLabel = CCLabelTTF:create( num,g_sFontName,18)
    _warCoinLabel:setColor(ccc3(0xff,0xe2,0x44))
    _warCoinLabel:setAnchorPoint(ccp(0,0.5))
    _warCoinLabel:setPosition(titleBg:getContentSize().width*0.61,titleBg:getContentSize().height*0.43)
    titleBg:addChild(_warCoinLabel)

    local goldSp = CCSprite:create("images/common/gold.png")
    goldSp:setAnchorPoint(ccp(0,0.5))
    goldSp:setPosition(titleBg:getContentSize().width*0.76,titleBg:getContentSize().height*0.47)
    titleBg:addChild(goldSp)

    _goldLabel = CCLabelTTF:create( UserModel.getGoldNumber(),g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(titleBg:getContentSize().width*0.82,titleBg:getContentSize().height*0.43)
    titleBg:addChild(_goldLabel)

    -- 创建倒计时界面
	local curStage = CountryWarMainData.getCurStage()
	if( curStage == CountryWarDef.AUDITION_READY or curStage == CountryWarDef.AUDITION )then
		-- 倒计时背景
		_topBg = CCSprite:create()
		_topBg:setContentSize(CCSizeMake(640,126))
		_topBg:setAnchorPoint(ccp(0.5,1))
		_topBg:setPosition(_bgLayer:getContentSize().width*0.5, titleBg:getPositionY()-titleBg:getContentSize().height*g_fScaleX)
	    _bgLayer:addChild(_topBg)
	    _topBg:setScale(g_fScaleX)
		-- 初赛准备阶段  初赛阶段
		createAuditionTopUI()
	elseif( curStage == CountryWarDef.FINALTION_READY or curStage == CountryWarDef.FINALTION )then
		_topBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
		_topBg:setContentSize(CCSizeMake(640,126))
		_topBg:setAnchorPoint(ccp(0.5,1))
		_topBg:setPosition(_bgLayer:getContentSize().width*0.5, titleBg:getPositionY()-titleBg:getContentSize().height*g_fScaleX)
	    _bgLayer:addChild(_topBg)
	    _topBg:setScale(g_fScaleX)
		-- 决赛准备阶段  决赛阶段
		createFinaltionTopUI()
	else
		print("Error Stage ==>", curStage)
	end

    -- 按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-20)
    _topBg:addChild(menuBar)

    -- 创建返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	closeMenuItem:setPosition(ccp( _topBg:getContentSize().width-50,_topBg:getContentSize().height*0.5 ))
	menuBar:addChild(closeMenuItem)
	closeMenuItem:registerScriptTapHandler(closeCallback)
end

function createRoadUI( ... )
	--创建路线
	for i=1,4 do
		local roadFile = {"1.png","2.png","3.png","4.png"}
		local roadBgSprite = CCSprite:create("images/country_war/road/" .. roadFile[i] )
		roadBgSprite:setAnchorPoint(ccp(0.5, 0.5))
		roadBgSprite:setPosition(ccpsprite(_roadPosXArr[i], _roadPosYArr[i], _bgSprite))
		_bgSprite:addChild(roadBgSprite)
		table.insert(_roadBgArray,roadBgSprite)

		local subData = {80,55,80,63}
		local roadSprite = CCSprite:create()
		roadSprite:setContentSize(CCSizeMake(roadBgSprite:getContentSize().width,440))
		roadSprite:setAnchorPoint(ccp(0.5, 1))
		roadSprite:setPosition(roadBgSprite:getContentSize().width*0.5,roadBgSprite:getContentSize().height-subData[i])
		roadBgSprite:addChild(roadSprite)
		table.insert(_roadArray, roadSprite)
	end

	-- 下方
	for i=1,4 do
		-- 传送阵按钮
		local menu = CCMenu:create()
		menu:setPosition(ccp(0, 0))
		menu:setAnchorPoint(ccp(0,0))
		menu:setTouchPriority(_touchPriority - 5)
		_roadArray[i]:addChild(menu, 2)

		-- 加入按钮
		local normalSp = CCSprite:create()
		normalSp:setContentSize(CCSizeMake(57,72))
		local secletSp = CCSprite:create()
		secletSp:setContentSize(CCSizeMake(57,72))
		local downJoinButton = CCMenuItemSprite:create(normalSp,secletSp)
		downJoinButton:setAnchorPoint(ccp(0.5, 0.5))
		downJoinButton:setPosition(BRON_POS[i].x,10)
		downJoinButton:registerScriptTapHandler(joinButtonCallback)
		menu:addChild(downJoinButton,1, i)
		_joinButtonArray[i] = downJoinButton

		-- 加入按钮
		-- local downJoinButton = CCMenuItemImage:create("images/guild_rob/attack_btn_n.png","images/guild_rob/attack_btn_h.png")
		-- downJoinButton:setAnchorPoint(ccp(0.5, 0.5))
		-- downJoinButton:setPosition(BRON_POS[i].x,10)
		-- downJoinButton:registerScriptTapHandler(joinButtonCallback)
		-- menu:addChild(downJoinButton,1, i)
		-- _joinButtonArray[i] = downJoinButton

		--进攻方有传送阵
		local tranformSprite = XMLSprite:create("images/country_war/effect/fazhenhuang/fazhenhuang",nil,true)
		tranformSprite:setAnchorPoint(ccp(0.5, 0.5))
		tranformSprite:setPosition(BRON_POS[i].x,0)
		_roadArray[i]:addChild(tranformSprite)
		_tranferEffects[i] = tranformSprite

	end

	-- 上方
	for i=5,8 do
		--上方传送阵
		local tranformSprite = XMLSprite:create("images/country_war/effect/fazhenBLUE/fazhenBLUE",nil,true)
		tranformSprite:setAnchorPoint(ccp(0.5, 0.5))
		tranformSprite:setPosition(BRON_POS[i].x,440)
		_roadArray[i-4]:addChild(tranformSprite)
		_tranferEffects[i] = tranformSprite
	end
end

--[[
	@des 	: 创建一些小物件
	@param 	: 
	@return : 
--]]
function createSmallUI( ... )
	-- 上边俩旗子
	local qiziSp1 = CCSprite:create("images/country_war/small/wu_3.png")
	qiziSp1:setAnchorPoint(ccp(0.5,0))
	qiziSp1:setPosition(ccp(115,686))
	_bgSprite:addChild(qiziSp1,20)

	local qiziSp2 = CCSprite:create("images/country_war/small/wu_3.png")
	qiziSp2:setAnchorPoint(ccp(0.5,0))
	qiziSp2:setPosition(ccp(_bgSprite:getContentSize().width-115,686))
	_bgSprite:addChild(qiziSp2,20)
	qiziSp2:setFlipX(true)

	-- 门前俩栅栏
	local zhalan1 = CCSprite:create("images/country_war/small/wu_2.png")
	zhalan1:setAnchorPoint(ccp(0.5,0))
	zhalan1:setPosition(ccp(255,650))
	_bgSprite:addChild(zhalan1,20)

	local zhalan2 = CCSprite:create("images/country_war/small/wu_2.png")
	zhalan2:setAnchorPoint(ccp(0.5,0))
	zhalan2:setPosition(ccp(_bgSprite:getContentSize().width-255,650))
	_bgSprite:addChild(zhalan2,20)
	zhalan2:setFlipX(true)

	-- 四个塔
	local taSp1 = CCSprite:create("images/country_war/small/wu_1.png")
	taSp1:setAnchorPoint(ccp(0.5,0))
	taSp1:setPosition(ccp(50,600))
	_bgSprite:addChild(taSp1,20)

	local taSp2 = CCSprite:create("images/country_war/small/wu_1.png")
	taSp2:setAnchorPoint(ccp(0.5,0))
	taSp2:setPosition(ccp(185,590))
	_bgSprite:addChild(taSp2,20)

	local taSp3 = CCSprite:create("images/country_war/small/wu_1.png")
	taSp3:setAnchorPoint(ccp(0.5,0))
	taSp3:setPosition(ccp(_bgSprite:getContentSize().width-185,590))
	_bgSprite:addChild(taSp3,20)

	local taSp4 = CCSprite:create("images/country_war/small/wu_1.png")
	taSp4:setAnchorPoint(ccp(0.5,0))
	taSp4:setPosition(ccp(_bgSprite:getContentSize().width-50,600))
	_bgSprite:addChild(taSp4,20)

	-- 两边的稻草
	local taCaoSp1 = CCSprite:create("images/country_war/small/wu_4.png")
	taCaoSp1:setAnchorPoint(ccp(0.5,0))
	taCaoSp1:setPosition(ccp(60,300))
	_bgSprite:addChild(taCaoSp1,20)

	local taCaoSp2 = CCSprite:create("images/country_war/small/wu_4.png")
	taCaoSp2:setAnchorPoint(ccp(0.5,0))
	taCaoSp2:setPosition(ccp(_bgSprite:getContentSize().width-40,400))
	_bgSprite:addChild(taCaoSp2,20)

	-- 四个小栅栏
	local zhalanXiao1 = CCSprite:create("images/country_war/small/wu_6.png")
	zhalanXiao1:setAnchorPoint(ccp(0.5,0))
	zhalanXiao1:setPosition(ccp(40,100))
	_bgSprite:addChild(zhalanXiao1,20)

	local zhalanXiao2 = CCSprite:create("images/country_war/small/wu_6.png")
	zhalanXiao2:setAnchorPoint(ccp(0.5,0))
	zhalanXiao2:setPosition(ccp(185,70))
	_bgSprite:addChild(zhalanXiao2,20)

	local zhalanXiao3 = CCSprite:create("images/country_war/small/wu_6.png")
	zhalanXiao3:setAnchorPoint(ccp(0.5,0))
	zhalanXiao3:setPosition(ccp(_bgSprite:getContentSize().width-185,70))
	_bgSprite:addChild(zhalanXiao3,20)
	zhalanXiao3:setFlipX(true)

	local zhalanXiao4 = CCSprite:create("images/country_war/small/wu_6.png")
	zhalanXiao4:setAnchorPoint(ccp(0.5,0))
	zhalanXiao4:setPosition(ccp(_bgSprite:getContentSize().width-40,100))
	_bgSprite:addChild(zhalanXiao4,20)
	zhalanXiao4:setFlipX(true)

	-- 一个小物件
	local xiaoSp = CCSprite:create("images/country_war/small/wu_8.png")
	xiaoSp:setAnchorPoint(ccp(0.5,0))
	xiaoSp:setPosition(ccp(_bgSprite:getContentSize().width-40,200))
	_bgSprite:addChild(xiaoSp,20)

	-- 下边俩个塔
	local xiaTaSp1 = CCSprite:create("images/country_war/small/wu_7.png")
	xiaTaSp1:setAnchorPoint(ccp(0.5,1))
	xiaTaSp1:setPosition(ccp(40,100))
	_bgSprite:addChild(xiaTaSp1,20)

	local xiaTaSp2 = CCSprite:create("images/country_war/small/wu_7.png")
	xiaTaSp2:setAnchorPoint(ccp(0.5,1))
	xiaTaSp2:setPosition(ccp(_bgSprite:getContentSize().width-40,100))
	_bgSprite:addChild(xiaTaSp2,20)
end

--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function createLayer( ... )
	-- 初始化
	init()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 大背景
    _bgSprite = CCSprite:create("images/country_war/war_bg.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 创建背景上的小物件
    createSmallUI()

    -- 创建上边界面
    createTopUI()

    -- 创建路
    createRoadUI()

    -- 准备倒计时
    showReadLayer()

    --刷新显示更多路
	showSecondRoad()

	_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(refreshTimer, 1/25, false)
	
	CountryWarPlaceService.registerPushRefresh(refreshPushCallback)				--数据刷新回调
	CountryWarPlaceService.registerPushReckon(reckonPushCallback)				--结算推送推送
	CountryWarPlaceService.registerPushFightWin(fightWinPushCallback)			--玩家战斗胜利推送
	CountryWarPlaceService.registerPushFightLose(fightLosePushCallback)			--玩家战败推送
	CountryWarPlaceService.registerPushTouchDown(touchDownPushCallback)			--达阵事件推送
	CountryWarPlaceService.registerPushBattleEnd(battleEndPushCallback)			--pvp战斗结束推送
	CountryWarPlaceService.registerPushFightResult(fightResultPushCallback)

	-- 菜单栏
	addEncourageLayer()

	-- 排行榜
	require "script/ui/countryWar/war/CountryWarRankList"
	CountryWarRankList.show(_touchPriority-10, 1300, _bgLayer)

	--检测自动加入
	checkAutoJoin()

	-- 断线重连
	LoginScene.addObserverForNetBroken("country_war",networkBreakCallback)
	if LoginScene.addObserverForReconnect then
		LoginScene.addObserverForReconnect("country_war",networkReconnectCallback)
	end

	-- 国战socket断开回调
	Network.registerCountryDisconnected("countreDisconnected",networkReconnectCallback)

    return _bgLayer
end


--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function showLayer( ... )
	-- 初始化数据
	CountryWarPlaceData.init()

	local nextCallFun = function ( ... )
		local layer = createLayer()
		MainScene.changeLayer(layer, "WarMainLayer")
	end
	-- 进入战场
	CountryWarController.enterWarPlace(nextCallFun)
end

--[[
	@des: 鼓舞相关 add by yangrui 2015-11-18
--]]
function addEncourageLayer( ... )
	require "script/ui/countryWar/encourage/CountryWarEncourageLayer"
	local layer = CountryWarEncourageLayer.createEncourageLayer()
	_bgLayer:addChild(layer)
end











