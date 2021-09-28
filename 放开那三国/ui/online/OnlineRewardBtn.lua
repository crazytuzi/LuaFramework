-- Filename: OnlineLayer.lua
-- Author: zhz
-- Date: 2013-07-23
-- Purpose: 该文件用于:创建在线奖励按钮2
module ("OnlineRewardBtn", package.seeall)

require "script/ui/main/MenuLayer"
require "script/ui/main/MainScene"
require "script/network/RequestCenter"
require "script/ui/online/OnlineLayerCell"
require "script/ui/online/TimeCache"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/ui/rewardCenter/AdaptTool"
require "script/audio/AudioUtil"
require "script/utils/ItemDropUtil"

local _ksTagOnline=4001				-- 按钮菜单的tag
local _menu 						-- 按钮菜单
local _rewardImgItem = nil			-- 在线奖励的按钮 ,
local _timeLabel					-- 剩余时间,展示在按钮下面的
local _canReceiveLabel
local _tipSprite					-- 在线奖励的按钮上的感叹号sprite
-- local _boolReceived				-- 是否可以领取

local _remianTimeLabel				-- 剩余时间，展示在layer上的。
local _curShowCell =0 				-- 当前展示的cell数量

local IMG_PATH = "images/online/" 
local _onRunningLayer				-- 当前运行的层
local _bgLayer
local _bgLayerStatus =false        	-- 判断bgLayer  是否存在
local _remianTime = 0				--  还有多少时间
local _updateTimeSign = 0 			-- layer 层中的unschedule函数
local _BtnUnschedule= nil				-- 按钮上的unschedule函数
local _receiveBtn 					-- 接受按钮
local _sub_modules={
	{name="online", tag=_ksTagOnline, pos_x=350, pos_y=250}, -- 位置不定呀
} 
local _rewardData ={}           	-- 在线奖励的奖品信息

local _timeData ={
	isReceived =false,
	id=0,
	currentTime= nil,
	futureTime = nil,
	accumulate_time= nil,
	_BtnUnschedule= nil

}
-- 定义函数名
local onlineDataCallback
local createBtnImage

--  初始化方法
local function init( )
	_rewardImgItem = nil
	_tipSprite= nil
	_bgLayerStatus =false 
	_receiveBtn = nil	
end
-- 更改时间的格式 如将 180 装换 成 00：03：00
local function transferTime(timeInt )
	if(timeInt < 0) then
		timeInt =0
	end
	local s= string.format("%02d:%02d:%02d",math.floor(timeInt/(60*60)),math.floor((timeInt/60)%60),timeInt%60)
	
	return s
end
-- 更改时间格式，如将 180 转换成 03：00
local function tranferMinTime( timeInt)
	if(timeInt < 0) then
		timeInt =0
	end
	local s = string.format("%02d:%02d", math.floor((timeInt/60)%60),timeInt%60)
	return s
end
-- 改变图标
local function BtnChange( )
	_onRunningLayer = tolua.cast(_onRunningLayer, "CCLayer")
	if ( _onRunningLayer and _onRunningLayer:getChildByTag(_ksTagOnline) )then
		local rewardItem = _onRunningLayer:getChildByTag(_ksTagOnline):getChildByTag(1)
		if rewardItem ~=nil then
			local pSFrame=CCSpriteFrame:create(IMG_PATH.."open/open_n.png",CCRect(0,0,107,103))
			rewardItem:setNormalSpriteFrame(pSFrame)
			pSFrame=CCSpriteFrame:create(IMG_PATH .. "open/open_h.png",CCRect(0,0,107,103))
			rewardItem:setSelectedSpriteFrame(pSFrame)
			_tipSprite:setVisible(true)
			
		end
	end
end
-- 改变成原来的图标
local function BtnBack()
	_onRunningLayer = tolua.cast(_onRunningLayer, "CCLayer")
	if ( _onRunningLayer and _onRunningLayer:getChildByTag(_ksTagOnline) )then
		local rewardItem = _onRunningLayer:getChildByTag(_ksTagOnline):getChildByTag(1)
		if _rewardImgItem ~= nil then
			local pSFrame=CCSpriteFrame:create(IMG_PATH.."close/close_n.png",CCRect(0,0,107,103))
			_rewardImgItem:setNormalSpriteFrame(pSFrame)
			pSFrame=CCSpriteFrame:create(IMG_PATH .. "close/close_h.png",CCRect(0,0,107,103))
			_rewardImgItem:setSelectedSpriteFrame(pSFrame)
			_tipSprite:setVisible(false)
		end
	end
end
-- 这里设置每帧调用上面的函数tick 
local function tick()
	if TimeCache.getFutureTime() ~= nil then 
		_remianTime = TimeCache.getFutureTime() - BTUtil:getSvrTimeInterval() - _timeData.accumulate_time
	else
		_remianTime = _timeData.futureTime - BTUtil:getSvrTimeInterval() - _timeData.accumulate_time
	end
	
	if _remianTime <= 0 then
		_remianTime =0
		_timeLabel = tolua.cast(_timeLabel,"CCLabelTTF")
    	if(_timeLabel and _timeLabel:getString()) then
			_timeLabel:setString("")
			_canReceiveLabel:setVisible(true)
		end
    	-- _timeLabel:setString(GetLocalizeStringBy("key_1563"))
    	_timeData.isReceived =true
    --	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_BtnUnschedule)
    	BtnChange()
    else
    	BtnBack()
    	local s = transferTime(_remianTime)
    	_timeLabel = tolua.cast(_timeLabel,"CCLabelTTF")
    	if(_timeLabel and _timeLabel:getString()) then
			_timeLabel:setString(s)
			_timeLabel:setPosition(ccp(_rewardImgItem:getContentSize().width*0.5,_rewardImgItem:getContentSize().height*0.04+10))
			_timeLabel:setColor(ccc3(0xff,0x20,0x00))
			_canReceiveLabel:setVisible(false)
		end
		-- changed in 2013-11-20
		_timeData.isReceived =false
    end
end

-- 创建 timeLabel ，在按钮下显示。
local function createTimeLabel()

	_timeLabel = CCLabelTTF:create("",g_sFontName,18)-- ,1,ccc3(0x49,0x17,0x00),type_stroke)
	_timeLabel:setColor(ccc3(0xff,0x20,0x00))
	_timeLabel:setAnchorPoint(ccp(0.5,1))
	_timeLabel:setPosition(ccp(_rewardImgItem:getContentSize().width*0.5,_rewardImgItem:getContentSize().height*0.04))
	_rewardImgItem:addChild(_timeLabel)

	_canReceiveLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1051"), g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	_canReceiveLabel:setColor(ccc3(0x00,0xff,0x18))
	_canReceiveLabel:setAnchorPoint(ccp(0,1))
	_canReceiveLabel:setVisible(false)
 	_canReceiveLabel:setPosition(ccp(_rewardImgItem:getContentSize().width*0.22,_rewardImgItem:getContentSize().height*0.04))
 	_rewardImgItem:addChild(_canReceiveLabel)
 	require "db/DB_Online_reward"
   	if tonumber(_timeData.accumulate_time) < tonumber(DB_Online_reward.getDataById(_timeData.id).count_down_time ) then
   		local leftTime = TimeCache.getFutureTime() - BTUtil:getSvrTimeInterval() - _timeData.accumulate_time
    	_timeLabel:setString(transferTime(leftTime))
    	-- 这里设置每帧调用上面的函数tick  
    	_BtnUnschedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.5, false)
    else
     	_timeData.isReceived=true
     	 BtnChange()
     	 _canReceiveLabel:setVisible(true)
    end
end
-- 释放按钮函数
local function release( )
	local menu = _onRunningLayer:getChildByTag(_ksTagOnline)
	menu:removeFromParentAndCleanup(true)
	menu= nil
end

 -- 创建本次所得的表，并且显示出来
local function createRewardData( )
	  -- 创建本次所得的表，并且显示出来
	  require "db/DB_Online_reward"
  	local RewardtmpData= DB_Online_reward.getDataById(_timeData.id)
	local rewardData = {}
	for i=1,RewardtmpData.reward_num do
	    if(RewardtmpData["reward_type" .. i]~= nil) then
	        local t = {}
	        t.reward_type = RewardtmpData["reward_type" .. i]
	        t.reward_quality = RewardtmpData["reward_quality" ..i]
	        t.reward_desc = RewardtmpData["reward_desc" .. i]
	        if(t.reward_type == 6) then
	            t.reward_ID = RewardtmpData["reward_values" .. i]
	            t.reward_values = 1
	        elseif(t.reward_type == 7) then
	            t.reward_ID =  lua_string_split(RewardtmpData["reward_values" .. i],'|')[1]
	            t.reward_values = lua_string_split(RewardtmpData["reward_values" .. i],'|')[2]
	        elseif(t.reward_type == 10) then
	        	t.reward_ID =  RewardtmpData["reward_values" .. i]
	        	t.reward_values = 1
	        else
	            t.reward_values =  RewardtmpData["reward_values" .. i]
	        end
	        table.insert(rewardData,t)
	    end
	end
  	TimeCache.setRewardData(rewardData)

end


-- preRequest.lua 中调用
function calFutureTime( dictData)
	require "db/DB_Online_reward"
	local Online_reward= DB_Online_reward.Online_reward
    local rewardNum = table.count(Online_reward)

     if tonumber(dictData.ret.step ) > tonumber(rewardNum) - 1 then
		-- local menu = _onRunningLayer:getChildByTag(_ksTagOnline)
		-- menu:removeFromParentAndCleanup(true)
		-- menu= nil
		-- futureTime == 0 时 数据读完，消失
		_timeData.futureTime= 0 
		TimeCache.setFutureTime(0)
		return
   	end

    _timeData.id= dictData.ret.step+1 
    _timeData.futureTime= BTUtil:getSvrTimeInterval() + DB_Online_reward.getDataById(_timeData.id).count_down_time
	--    print("_timeData.futureTime is :" .. _timeData.futureTime)
    _timeData.accumulate_time = dictData.ret.accumulate_time
    -- 将未来的时间放到缓存中去

    TimeCache.setFutureTime(_timeData.futureTime)

    -- changed by zhz
    _timeData.isReceived = false
    createRewardData()
end

--  后端传来的数据
onlineDataCallback = function(cbFlag, dictData, bRet)
	if not bRet then
        return
    end
    require "db/DB_Online_reward"
    -- 时间到了，按钮消失,释放按钮
    local Online_reward= DB_Online_reward.Online_reward
    local rewardNum = table.count(Online_reward)
	--    print("the number Online_reward is : " ,table.count(Online_reward))
    if tonumber(dictData.ret.step ) > tonumber(rewardNum) - 1 then
		local menu = _onRunningLayer:getChildByTag(_ksTagOnline)
		menu:removeFromParentAndCleanup(true)
		menu= nil
		-- futureTime == 0 时 数据读完，消失
		_timeData.futureTime= 0 
		TimeCache.setFutureTime(0)

		return
   	end
   	-- 创建按钮 createBtnImage()
   	createBtnImage()

    _timeData.id= dictData.ret.step+1 
    _timeData.futureTime= BTUtil:getSvrTimeInterval() + DB_Online_reward.getDataById(_timeData.id).count_down_time
	--    print("_timeData.futureTime is :" .. _timeData.futureTime)
    _timeData.accumulate_time = dictData.ret.accumulate_time
    -- 将未来的时间放到缓存中去
 	-- if TimeCache.getFutureTime() == nil then
    	TimeCache.setFutureTime(_timeData.futureTime)
 

  	createTimeLabel()

  	createRewardData()

  	cancelBtnCallBack()
end

--  取消按钮的回调函数
function cancelBtnCallBack(tag, menuItem)

	--CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(updateTime)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeSign)
	_bgLayerStatus = false
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer= nil
	require "script/ui/main/MainMenuLayer"
	MainMenuLayer.updateTopButton()
end

---------------------------------------- the below function is for OnlineLayer --------------------------------------------
local updateTime = function (  )

	 if _remianTime <= 0 then
	 	_remianTime = 0
	 	local s = transferTime(_remianTime)
	 	_remianTimeLabel:setString(s)
	 	_timeData.isReceived = true
	 	_receiveBtn:setEnabled(true)
	 	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeSign)
	 		 
	 else
	 	local s = transferTime(_remianTime)
	 	if _bgLayerStatus ~=false then
	 	 	_remianTimeLabel:setString(s)
	 	end
     end

end
local function receiveActionCb(cbFlag, dictData, bRet)

	if(dictData.err ~= "ok" )then
	 	return
	 end
	
	--BtnBack()
	_timeLabel:setString("")
	TimeCache.setFutureTime(nil)
	_remianTime= 0

	RequestCenter.online_getOnlineInfo(onlineDataCallback)
	-- 
	_receiveBtn:setEnabled(false)
	_timeData.isReceived =false

	--	获得的奖励如金银币，银币，将魂等
	local userInfo = UserModel.getUserInfo()
	local getReward = TimeCache.getRewardData()
	for i=1,7 do
		if(getReward[i] ~= nil) then
			if getReward[i].reward_type == 1 then
			 	UserModel.addSilverNumber(getReward[i].reward_values)
			 	elseif getReward[i].reward_type == 2 then 
			 		UserModel.addSoulNum(getReward[i].reward_values)
			 	elseif getReward[i].reward_type == 3 then 
			 		UserModel.addGoldNumber(getReward[i].reward_values)
			 	elseif getReward[i].reward_type == 4 then
			 		UserModel.addEnergyValue(getReward[i].reward_values)
			 	elseif getReward[i].reward_type == 5 then
			 		UserModel.addStaminaNumber(getReward[i].reward_values)
			 	elseif(getReward[i].reward_type== 8 ) then
					local silver = tonumber(getReward[i].reward_values)*tonumber(userInfo.level)
					UserModel.addSilverNumber(silver)
				elseif(getReward[i].reward_type ==9) then
					local soul  = tonumber(getReward[i].reward_values)*tonumber(userInfo.level)
					UserModel.addSoulNum(soul)
			end
		end
	end
	-- 弹出获得奖励的提示
	local txt = GetLocalizeStringBy("key_1914")
	for i=1, #getReward do
		txt = txt .. getReward[i].reward_desc .. "*" .. getReward[i].reward_values .. "\n"
	end
	--AnimationTip.showTip(txt)
	-- _bgLayerStatus = false
	-- _bgLayer:removeFromParentAndCleanup(true)
	-- _bgLayer= nil
	require "script/utils/ItemDropUtil"
	ItemDropUtil.showGiftLayer(getReward)

	

end

 -- 点击领取奖励的回调函数
local function receiveAction(tag, menuItem)
	require "script/ui/item/ItemUtil"
	if (ItemUtil.isBagFull()) then
		-- AnimationTip.showTip(GetLocalizeStringBy("key_1817"))
		cancelBtnCallBack()
		return 
    end

    local getReward = TimeCache.getRewardData()
    local isHero = false
    for i=1,#getReward do
    	if(getReward[i].reward_type ==10)then
    		isHero= true
    		break
    	end
    end

    require "script/ui/hero/HeroPublicUI"
	if( isHero and HeroPublicUI.showHeroIsLimitedUI()) then
		cancelBtnCallBack()
		return
	end


    -- 判断是否可以领取
	if(_timeData.isReceived == false ) then
		return
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(_timeData.id))
	RequestCenter.online_gainGift(receiveActionCb,args)


end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")
	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end
-- 创建在线奖励界面
local function createOnlineLayer()

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayerStatus = true
	_bgLayer:registerScriptHandler(onNodeEvent)
	-- 九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	local onlineBG = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	onlineBG:setPreferredSize(CCSizeMake(524, 438))
	onlineBG:setPosition(ccp(g_winSize.width*0.5, g_winSize.height*0.5))
	onlineBG:setAnchorPoint(ccp(0.5,0.5))
	_bgLayer:addChild(onlineBG)
	require "script/ui/rewardCenter/AdaptTool"
	AdaptTool.setAdaptNode(onlineBG)

	--createBgAction(onlineBG)

	-- 在线奖励的背景
	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(onlineBG:getContentSize().width*0.5,onlineBG:getContentSize().height -6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	onlineBG:addChild(titleBg)
	--在线奖励的标题文本
	local labelTitle = CCLabelTTF:create (GetLocalizeStringBy("key_2819"), g_sFontName, 35, CCSizeMake(315, 61), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	labelTitle:setPosition(ccp(titleBg:getContentSize().width/2, (titleBg:getContentSize().height-1)/2))
	labelTitle:setAnchorPoint(ccp(0.5, 0.5))
	labelTitle:setColor(ccc3(0xff,0xf0,0x49))
	titleBg:addChild(labelTitle)

	local fullRect_1 = CCRectMake(0,0,75,75)
	local insetRect_1 = CCRectMake(20,20,45,45)
	local item_back = CCScale9Sprite:create("images/online/item_back.png",fullRect_1,insetRect_1)
	item_back:setPreferredSize(CCSizeMake(450,140))
	item_back:setPosition(ccp(onlineBG:getContentSize().width*0.5,129))
	item_back:setAnchorPoint(ccp(0.5,0))
	onlineBG:addChild(item_back)

	-- rewardDataCache
  	local rewardData = TimeCache.getRewardData()
  	local cellNum = #rewardData
	local cellSize = CCSizeMake(100,150)	
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif (fn == "cellAtIndex") then
            a2=OnlineLayerCell.createCell(rewardData[a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            r=  cellNum
		elseif (fn == "cellTouched") then
		else
		end
		return r
	end)
	local tableView= LuaTableView:createWithHandler(handler,CCSizeMake(410,onlineBG:getContentSize().height*0.5))
	tableView:setBounceable(true)
	tableView:setTouchPriority(-551)
	tableView:setDirection(kCCScrollViewDirectionHorizontal)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:setPosition(ccp(onlineBG:getContentSize().width*0.12,95))
	onlineBG:addChild(tableView)
	-- 接受奖励的菜单
	local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	onlineBG:addChild(menu)
	menu:setTouchPriority(-551)
	--receiveBtn:registerScriptTapHandler(receiveAction)
	-- 取消的按钮
	local cancelBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	cancelBtn:setAnchorPoint(ccp(1, 1))
	cancelBtn:setPosition(ccp(onlineBG:getContentSize().width+14, onlineBG:getContentSize().height+14))
	cancelBtn:registerScriptTapHandler(cancelBtnCallBack)
	menu:addChild(cancelBtn)

	--距离下一次奖励还有多少时间还有：
	local leftTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2157"), g_sFontName,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	leftTimeLabel:setPosition(ccp(84,375))
	-- leftTimeLabel:setAnchorPoint(ccp(1,0))
	leftTimeLabel:setSourceAndTargetColor(ccc3( 0xff, 0xed, 0x55), ccc3( 0xff, 0xed, 0x55));
	onlineBG:addChild(leftTimeLabel)
	-- 显示时间的背景
	local rect = CCRectMake(0,0,80,23)
	local insetRect = CCRectMake(4,4,70,17)
	local leftTimeSp = CCScale9Sprite:create("images/online/bottom.png",rect,insetRect)
	leftTimeSp:setPreferredSize(CCSizeMake(220, 40))
	leftTimeSp:setPosition(ccp(onlineBG:getContentSize().width*0.28,289))
	onlineBG:addChild(leftTimeSp)
	
	_remianTimeLabel = CCLabelTTF:create("" .. transferTime(_remianTime) , g_sFontName,30)
	_remianTimeLabel:setPosition(ccp(leftTimeSp:getContentSize().width*0.5,leftTimeSp:getContentSize().height*0.5))
	_remianTimeLabel:setAnchorPoint(ccp(0.5,0.5))
	_remianTimeLabel:setColor(ccc3(0xff,0xf6,0x00))
	leftTimeSp:addChild(_remianTimeLabel)
	_updateTimeSign = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)

	-- 接受奖励按钮
	local normalSp =CCSprite:create(IMG_PATH .. "receive/receive_n.png")
	local selectedSp =CCSprite:create(IMG_PATH .. "receive/receive_h.png") 
	local disabledSp = BTGraySprite:create(IMG_PATH .. "receive/receive_n.png")
	 _receiveBtn = CCMenuItemSprite:create(normalSp,selectedSp, disabledSp)
	_receiveBtn:setEnabled(_timeData.isReceived)
	_receiveBtn:setPosition(ccp(onlineBG:getContentSize().width*0.5,51))
	_receiveBtn:setAnchorPoint(ccp(0.5,0))
	_receiveBtn:registerScriptTapHandler(receiveAction)
	menu:addChild(_receiveBtn)



	CCDirector:sharedDirector():getRunningScene():addChild(_bgLayer,999)
end

-- 创建动画：背景打出屏幕得效果
function createBgAction( background)
	local args = CCArray:create()
	local scale1 = CCScaleBy:create(0.08,1.2)
	local scale2 = CCScaleBy:create(0.05,0.9)
    local scale3 = CCScaleBy:create(0.07,1)
    args:addObject(scale1)
    args:addObject(scale2)
    args:addObject(scale3)

    background:runAction(CCSequence:create(args))
	
end


-- 点击按钮事件函数
local function OnlineBtnCallback()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	createOnlineLayer()
end

-- 创建在线奖励按钮
createBtnImage =  function()
	local bgSize = _onRunningLayer:getContentSize()
	if(_rewardImgItem ~= nil ) then
		_rewardImgItem:removeFromParentAndCleanup(true)
		_rewardImgItem = nil
	end
	if _timeData.isReceived== false then
		_rewardImgItem =CCMenuItemImage:create(IMG_PATH .."close/close_n.png",IMG_PATH .. "close/close_h.png")
		_rewardImgItem:setAnchorPoint(ccp(0, 0))
		_rewardImgItem:setPosition(0, 0)
	else
		_rewardImgItem =CCMenuItemImage:create(IMG_PATH .."open/open_n.png",IMG_PATH .. "open/open_h.png")
		_rewardImgItem:setAnchorPoint(ccp(0, 0))
		_rewardImgItem:setPosition(0, 0)
	end
	_menu:addChild(_rewardImgItem,1,1)
	_rewardImgItem:registerScriptTapHandler(OnlineBtnCallback)

	createTipSprite()
end

-- 释放 schedule
local function nodeEvent( event )
	if (event == "enter") then
		-- _onRunningLayer:registerScriptTouchHandler(onlineTouchesHandler)-- , false, -550, true)
		-- _onRunningLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_onRunningLayer:unregisterScriptHandler()
		if(_BtnUnschedule ~= nil) then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_BtnUnschedule)
		end

		--_BtnUnschedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.5, false)

	end
end

-- 创建按钮上的感叹号sprite
function createTipSprite(  )
	_tipSprite=   ItemDropUtil.getTipSpriteByNum(1) --CCSprite:create("images/common/tip_1.png")
	_tipSprite:setPosition(ccp(_rewardImgItem:getContentSize().width*0.97, _rewardImgItem:getContentSize().height*0.98))
	_tipSprite:setAnchorPoint(ccp(1,1))
	_rewardImgItem:addChild(_tipSprite,1)

	-- local numLabel = CCLabelTTF:create("1",g_sFontName, 21)
	-- -- numLabel:setColor()
	-- numLabel:setPosition(ccp(_tipSprite:getContentSize().width/2-3,_tipSprite:getContentSize().height/2+2))
	-- numLabel:setAnchorPoint(ccp(0.5,0.5))
	-- _tipSprite:addChild(numLabel)

	-- _tipSprite:setVisible(false)
	if(_timeData.isReceived == false) then
		_tipSprite:setVisible(false)
	else
		_tipSprite:setVisible(true)
	end
end


-- 创建按钮
function createOnlineRewardBtn( bglayer)
	_onRunningLayer= bglayer
	_onRunningLayer:registerScriptHandler(nodeEvent)
	 _menu =CCMenu:create()
	_menu:setPosition(ccp(0,0))
	_onRunningLayer:addChild(_menu,0,_ksTagOnline)
	init()
	 _timeData.futureTime = TimeCache.getFutureTime()

	 -- timeData.futureTime == 0 时 物品领完，消失
	if(_timeData.futureTime == nil ) then
		RequestCenter.online_getOnlineInfo(onlineDataCallback)
	elseif(_timeData.futureTime == 0) then
		return
	else
		createBtnImage()
		createTimeLabel()
	end
	tick()
end

-- 释放这个按钮
local function releaseBtn( )
	local menu = _onRunningLayer:getChildByTag(_ksTagOnline)
	menu:removeFromParentAndCleanup(true)
	menu= nil
end

function isShow()
	if not tolua.isnull(_rewardImgItem) then
		if _rewardImgItem:isVisible() then
			return true
		end
	end
	return false
end


