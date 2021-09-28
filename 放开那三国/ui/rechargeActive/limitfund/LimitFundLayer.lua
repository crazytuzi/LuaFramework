-- FileName: LimitFundLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-9-13
-- Purpose: 限时基金主界面
module("LimitFundLayer",package.seeall)
require "script/ui/rechargeActive/limitfund/LimitFundCell"
require "script/ui/rechargeActive/limitfund/LimitFundData"
require "script/ui/rechargeActive/limitfund/LimitFundBuyLayer"
require "script/ui/rechargeActive/limitfund/LimitFundController"
require "script/utils/BTNumerLabel"
local _bgLayer 
local _data
local _priority
local _zOrder
local _height
local _remainNum
local _viewBgSpriteHeight
local _bg
local _tableView
local _viewBgSprite
local _lastBuyCount
local _countdownTime
local _itemBg
local _leftArrowSp      
local _rightArrowSp
function init( ... )
	_bgLayer = nil
	_data	 = {}
	_priority = nil
	_zOrder  = nil
	_height  = nil
	_remainNum = nil
	_viewBgSpriteHeight = nil
	_tableView = nil
	_bg = nil
	_itemBg = nil
	_viewBgSprite = nil
	_countdownTime = nil
	_lastBuyCount = nil
	_rightArrowSp     = nil -- 右箭头
end

--事件注册
function onTouchesHandler( eventType )
    if(eventType == "began")then
        return true
    elseif(eventType == "moved")then
      
    elseif(eventType == "end")then
      
    end
end

function onNodeEvent( event )
    if(event == "enter")then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false, -300,true)
        _bgLayer:setTouchEnabled(true)
    elseif(event == "exit")then
        stopSchedule()
        _bgLayer:unregisterScriptTouchHandler()
        -- _bgLayer = nil
    end
end

--开启时间调度器
function startSchedule()
     if(_timeCounter == nil)then
        _timeCounter = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
    end
end

--关闭时间调度器
function stopSchedule()
     if(_timeCounter)then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_timeCounter)
        _timeCounter = nil
    end
end

--更新倒计时
function updateTime( ... )
    --获取时间
    local data = LimitFundData.getDataInfo()
    local time = LimitFundData.getEndTime()
	if(LimitFundData.getPeriodOfActivity() == 0 or table.isEmpty(data))then
		time = LimitFundData.getEndTimeOfBuy()
	end
	 local timestr =  tonumber(time) - tonumber(BTUtil:getSvrTimeInterval()) 
     -- local time1 = TimeUtil.getTimeDesByInterval(timestr)
     if(timestr<0)then
     	timestr = 0
     end
     _countdownTime:setString(LimitFundData.getTimeDesByInterval(timestr))
     print("LimitFundData.getPeriodOfActivity() ==",LimitFundData.getPeriodOfActivity())
    print("timestr",timestr)
    --判断如果等于0，就关掉时间调度器
    if(timestr == 0)then
    	print("倒计时为0")
        stopSchedule()
        if(LimitFundBuyLayer.getExitBuyLayer())then
        	LimitFundBuyLayer.closeAction()
        end
        local callback = function ( ... )
	        if(LimitFundData.isActivityOver())then
	        	createTopUIOfBuyTime()
	        else
	        	LimitFundController.getInfo(createTopUIOfBuyTime)
	        end
        end
        performCallfunc(callback, 1.0 )
    end   
end

--活动入口
function createLayer( )
	init()
	_priority =  -400
    _zOrder   =  10
	_bgLayer  = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	require "script/ui/rechargeActive/RechargeActiveMain"
	--消息提示栏和主菜单栏显示可见，主角信息栏不可见
	MainScene.setMainSceneViewsVisible(true, false, false)
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local  activeMainWidth = RechargeActiveMain.getBgWidth()
	local menuLayerSize = MenuLayer.getLayerContentSize()

	local layerSize = {width= 0, height=0}
	layerSize.width= g_winSize.width 
	layerSize.height =g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX- activeMainWidth
	_bgLayer:setContentSize(CCSizeMake(layerSize.width, layerSize.height))
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
	
	local callback = function ( ... )
		createTopUIOfBuyTime(true)
	end
	
	LimitFundController.getInfo(callback)
	return _bgLayer
end

function createTopUIOfBuyTime( isTip )
	local tip = isTip or false
	if(not tip)then
		print("消除----")
		if(_bgLayer)then
			print("移除-----")
			_bgLayer:removeAllChildrenWithCleanup(true)
		end
	end
	
	local monthCardBg= CCSprite:create("images/recharge/buttonsprite.png")
	monthCardBg:setScale(g_fScaleX)
	monthCardBg:setAnchorPoint(ccp(0.5, 0))
	print("_bgLayer----",_bgLayer)
	monthCardBg:setPosition(ccp(_bgLayer:getContentSize().width/2, 0))
	_bgLayer:addChild(monthCardBg)
	--人物背景
	local spriteBoy = CCSprite:create("images/recharge/spritebg.png")
	spriteBoy:setAnchorPoint(ccp(0.5,0.5))
	spriteBoy:setScale(0.9*g_fScaleX)
	spriteBoy:setPosition(ccp(_bgLayer:getContentSize().width*0.3,_bgLayer:getContentSize().height*0.65))
	_bgLayer:addChild(spriteBoy)

	-- 标题
	local spriteBg = CCSprite:create("images/recharge/title.png")
	spriteBg:setAnchorPoint(ccp(0,1))
	spriteBg:setPosition(ccp(0,_bgLayer:getContentSize().height*0.98))
	spriteBg:setScale(g_fScaleX)
	_bgLayer:addChild(spriteBg)
	--活动开始至结束时间
	local beginTime = LimitFundData.getBeginTime()
	local endTime =  LimitFundData.getEndTime()
	local timeLabel = CCRenderLabel:create(TimeUtil.getTimeForDayTwo(beginTime).."至"..TimeUtil.getTimeForDayTwo(endTime),g_sFontName, 20,1, ccc3(0x00,0x00,0x00),type_stroke)
	timeLabel:setColor(ccc3(0x00,0xff,0x18))
	timeLabel:setAnchorPoint(ccp(0,1))
	timeLabel:setScale(g_fScaleX)
	timeLabel:setPosition(ccp(20, _bgLayer:getContentSize().height*0.97-spriteBg:getContentSize().height*g_fScaleX))
	_bgLayer:addChild(timeLabel)
	print("11111111111111")
	local str = GetLocalizeStringBy("fqq_100")
	local endTime = LimitFundData.getEndTime()
	local data = LimitFundData.getDataInfo()
	if(LimitFundData.getPeriodOfActivity() == 0 or table.isEmpty(data))then
		print("第一种情况1111")
		str = GetLocalizeStringBy("fqq_144")
		endTime = LimitFundData.getEndTimeOfBuy()
	end
	
	--倒计时
	local strLable = CCRenderLabel:create(str,g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_stroke)
    strLable:setColor(ccc3(0x00,0xff,0x18))
    strLable:setAnchorPoint(ccp(0,1))
    strLable:setScale(g_fScaleX)
    strLable:setPosition(ccp(20, _bgLayer:getContentSize().height*0.96 -spriteBg:getContentSize().height*g_fScaleX -timeLabel:getContentSize().height*g_fScaleX))
    _bgLayer:addChild(strLable)
  
     --倒计时
      local timestr =  tonumber(endTime) - tonumber(BTUtil:getSvrTimeInterval())
      if(timestr < 0)then
      	timestr = 0
      end
    _countdownTime =CCRenderLabel:create(LimitFundData.getTimeDesByInterval(timestr),g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_stroke)
    _countdownTime:setColor(ccc3(0x00,0xff,0x18))
    _countdownTime:setAnchorPoint(ccp(0,0.5))
    _countdownTime:setPosition(ccp(strLable:getContentSize().width,strLable:getContentSize().height*0.5))
    strLable:addChild(_countdownTime)
    print("timestr------",timestr)
    if(timestr > 0)then
    	startSchedule()
    end

 	local data = LimitFundData.getDataInfo()
	if(LimitFundData.getPeriodOfActivity() == 0 or table.isEmpty(data))then
		local wenziLable_1 = CCRenderLabel:create(GetLocalizeStringBy("fqq_160"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
		wenziLable_1:setColor(ccc3(0xff,0xff,0xff))
	    wenziLable_1:setAnchorPoint(ccp(1,1))
	    wenziLable_1:setScale(g_fScaleX)
	    wenziLable_1:setPosition(ccp(_bgLayer:getContentSize().width-15*g_fScaleX, _bgLayer:getContentSize().height*0.98))
	    _bgLayer:addChild(wenziLable_1)
	    local wenziNum = CCRenderLabel:create("3",g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
	    wenziNum:setColor(ccc3(0x00,0xff,0x18))
	    wenziNum:setAnchorPoint(ccp(1,0.5))
	    wenziNum:setPosition(ccp(0, wenziLable_1:getContentSize().height*0.5))
	    wenziLable_1:addChild(wenziNum)
		local wenziLable_2 = CCRenderLabel:create(GetLocalizeStringBy("fqq_145"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
		wenziLable_2:setColor(ccc3(0xff,0xff,0xff))
	    wenziLable_2:setAnchorPoint(ccp(1,0.5))
	    wenziLable_2:setPosition(ccp(-wenziNum:getContentSize().width, wenziLable_1:getContentSize().height*0.5))
	    wenziLable_1:addChild(wenziLable_2)
	  
	  	_height = _bgLayer:getContentSize().height - wenziLable_1:getContentSize().height*g_fScaleX - 20*g_fScaleX
	end
	--文字描述(可任意选购3种基金类型)
	
	createDownUIOfBuyTime()
end

--创建下半部分内容
function createDownUIOfBuyTime( ... )
	local data = LimitFundData.getDataInfo()
	if(LimitFundData.getPeriodOfActivity() == 0 or table.isEmpty(data))then
		--当前最多还可购买x份
		local curLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_146"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
		curLable:setColor(ccc3(0xff,0xff,0xff))
	    curLable:setAnchorPoint(ccp(1,1))
	    curLable:setScale(g_fScaleX)
	    curLable:setPosition(ccp(_bgLayer:getContentSize().width-80*g_fScaleX, _bgLayer:getContentSize().height*0.93))
	    _bgLayer:addChild(curLable)

	    local curLable_2 = CCRenderLabel:create(GetLocalizeStringBy("fqq_147"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
		curLable_2:setColor(ccc3(0xff,0xff,0xff))
	    curLable_2:setAnchorPoint(ccp(1,1))
	    curLable_2:setScale(g_fScaleX)
	    curLable_2:setPosition(ccp(_bgLayer:getContentSize().width-15*g_fScaleX,_bgLayer:getContentSize().height*0.93))
	    _bgLayer:addChild(curLable_2)

	    local height1 = curLable_2:getPositionX()- curLable_2:getContentSize().width*g_fScaleX
	    local heoght2 = curLable:getPositionX()
	    local height3 = (height1- heoght2)/2+height1
	    local height4 = height3/_bgLayer:getContentSize().width
	    local remainNum = CCRenderLabel:create(LimitFundData.getMaxBuyTimes(),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
	    remainNum:setColor(ccc3(0x00,0xff,0x18))
	    remainNum:setAnchorPoint(ccp(0.5,1))
	    remainNum:setScale(g_fScaleX)
	    remainNum:setPosition(ccp(_bgLayer:getContentSize().width*height4*0.93,_bgLayer:getContentSize().height*0.93))
	    _bgLayer:addChild(remainNum)
	else
		local str = nil
		local typeNumTable = LimitFundData.getTypeOfNumTable()
		local function keySort ( _data1, _data2 )
         	return tonumber(_data1.type) < tonumber(_data2.type)
   	 	end
    	table.sort(typeNumTable,keySort)
    	for i=1,#typeNumTable do
    		local allreadyNum = LimitFundData.getAllreadyNum(tonumber(typeNumTable[i].type))
    		local num = #typeNumTable
    		
    		if(num == 1)then
    			local data1 = LimitFundData.getLimitFundInfoById(1)
    			local str = data1.name
    			if(tonumber(typeNumTable[i].type) == 2)then
    				local data2 = LimitFundData.getLimitFundInfoById(2)
    				str = data2.name
    			elseif tonumber(typeNumTable[i].type) == 3 then
    				local data3 = LimitFundData.getLimitFundInfoById(3)
    			  	str = data3.name
    			end
    			local lable = CCRenderLabel:create(GetLocalizeStringBy("fqq_166"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
				lable:setColor(ccc3(0xff,0xff,0xff))
			    lable:setAnchorPoint(ccp(0,1))
			    lable:setScale(g_fScaleX)
			    lable:setPosition(ccp(_bgLayer:getContentSize().width-260*g_fScaleX, _bgLayer:getContentSize().height*0.92))
			    _bgLayer:addChild(lable)
			    local remainNum = CCRenderLabel:create(allreadyNum..GetLocalizeStringBy("fqq_147"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
			    remainNum:setColor(ccc3(0x00,0xff,0x18))
			    remainNum:setAnchorPoint(ccp(0,0.5))
			    -- remainNum:setScale(g_fScaleX)
			    remainNum:setPosition(ccp(lable:getContentSize().width,lable:getContentSize().height*0.5))
			    lable:addChild(remainNum)
			    local lable1 = CCRenderLabel:create(str,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
				lable1:setColor(ccc3(0xff,0xff,0xff))
			    lable1:setAnchorPoint(ccp(0,0.5))
			    -- lable1:setScale(g_fScaleX)
			    lable1:setPosition(ccp(lable:getContentSize().width+remainNum:getContentSize().width, lable:getContentSize().height*0.5))
			    lable:addChild(lable1)
    		elseif num == 2 then
    			local data1 = LimitFundData.getLimitFundInfoById(1)
    			local str = data1.name
    			if(tonumber(typeNumTable[i].type) == 2)then
    				local data2 = LimitFundData.getLimitFundInfoById(2)
    				str = data2.name
    			elseif tonumber(typeNumTable[i].type) == 3 then
    				local data3 = LimitFundData.getLimitFundInfoById(3)
    			  	str = data3.name
    			end
    			if(i==1)then
    				local lable = CCRenderLabel:create(GetLocalizeStringBy("fqq_166"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
					lable:setColor(ccc3(0xff,0xff,0xff))
				    lable:setAnchorPoint(ccp(0,1))
				    lable:setScale(g_fScaleX)
				    lable:setPosition(ccp(_bgLayer:getContentSize().width-260*g_fScaleX, _bgLayer:getContentSize().height*0.96))
				    _bgLayer:addChild(lable)
				    local remainNum = CCRenderLabel:create(allreadyNum..GetLocalizeStringBy("fqq_147"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
				    remainNum:setColor(ccc3(0x00,0xff,0x18))
				    remainNum:setAnchorPoint(ccp(0,0.5))
				    -- remainNum:setScale(g_fScaleX)
				    remainNum:setPosition(ccp(lable:getContentSize().width,lable:getContentSize().height*0.5))
				    lable:addChild(remainNum)
				    local lable1 = CCRenderLabel:create(str,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
					lable1:setColor(ccc3(0xff,0xff,0xff))
				    lable1:setAnchorPoint(ccp(0,1))
				    lable1:setScale(g_fScaleX)
				    lable1:setPosition(ccp(_bgLayer:getContentSize().width-260*g_fScaleX+lable:getContentSize().width*g_fScaleX+remainNum:getContentSize().width*g_fScaleX, _bgLayer:getContentSize().height*0.96))
				    _bgLayer:addChild(lable1)
    			elseif i==2 then
    				local remainNum = CCRenderLabel:create(allreadyNum..GetLocalizeStringBy("fqq_147"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
				    remainNum:setColor(ccc3(0x00,0xff,0x18))
				    remainNum:setAnchorPoint(ccp(0,1))
				    remainNum:setScale(g_fScaleX)
				    remainNum:setPosition(ccp(_bgLayer:getContentSize().width-200*g_fScaleX,_bgLayer:getContentSize().height*0.9))
				    _bgLayer:addChild(remainNum)
				    local lable1 = CCRenderLabel:create(str,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
					lable1:setColor(ccc3(0xff,0xff,0xff))
				    lable1:setAnchorPoint(ccp(0,0.5))
				    -- lable1:setScale(g_fScaleX)
				    lable1:setPosition(ccp(remainNum:getContentSize().width, remainNum:getContentSize().height*0.5))
				    remainNum:addChild(lable1)
    			end
    		elseif num == 3 then
    			local data1 = LimitFundData.getLimitFundInfoById(1)
    			local str = data1.name
    			if(tonumber(typeNumTable[i].type) == 2)then
    				local data2 = LimitFundData.getLimitFundInfoById(2)
    				str = data2.name
    			elseif tonumber(typeNumTable[i].type) == 3 then
    				local data3 = LimitFundData.getLimitFundInfoById(3)
    			  	str = data3.name
    			end
    			if(i==1)then
    				local lable = CCRenderLabel:create(GetLocalizeStringBy("fqq_166"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
					lable:setColor(ccc3(0xff,0xff,0xff))
				    lable:setAnchorPoint(ccp(0,1))
				    lable:setScale(g_fScaleX)
				    lable:setPosition(ccp(_bgLayer:getContentSize().width-300*g_fScaleX, _bgLayer:getContentSize().height*0.96))
				    _bgLayer:addChild(lable)
				    local remainNum = CCRenderLabel:create(allreadyNum..GetLocalizeStringBy("fqq_147"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
				    remainNum:setColor(ccc3(0x00,0xff,0x18))
				    remainNum:setAnchorPoint(ccp(0,0.5))
				    -- remainNum:setScale(g_fScaleX)
				    remainNum:setPosition(ccp(lable:getContentSize().width,lable:getContentSize().height*0.5))
				    lable:addChild(remainNum)
				    local str = data1.name
				    local lable1 = CCRenderLabel:create(str,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
					lable1:setColor(ccc3(0xff,0xff,0xff))
				    lable1:setAnchorPoint(ccp(0,1))
				    lable1:setScale(g_fScaleX)
				    lable1:setPosition(ccp(_bgLayer:getContentSize().width-300*g_fScaleX+lable:getContentSize().width*g_fScaleX+remainNum:getContentSize().width*g_fScaleX, _bgLayer:getContentSize().height*0.96))
				    _bgLayer:addChild(lable1)
    			elseif i==2 then
    				local remainNum = CCRenderLabel:create(allreadyNum..GetLocalizeStringBy("fqq_147"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
				    remainNum:setColor(ccc3(0x00,0xff,0x18))
				    remainNum:setAnchorPoint(ccp(0,1))
				    remainNum:setScale(g_fScaleX)
				    remainNum:setPosition(ccp(_bgLayer:getContentSize().width-300*g_fScaleX,_bgLayer:getContentSize().height*0.9))
				    _bgLayer:addChild(remainNum)
				    local lable1 = CCRenderLabel:create(str,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
					lable1:setColor(ccc3(0xff,0xff,0xff))
				    lable1:setAnchorPoint(ccp(0,0.5))
				    -- lable1:setScale(g_fScaleX)
				    lable1:setPosition(ccp(remainNum:getContentSize().width, remainNum:getContentSize().height*0.5))
				    remainNum:addChild(lable1)
    			elseif i==3 then
    				local remainNum = CCRenderLabel:create(allreadyNum..GetLocalizeStringBy("fqq_147"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
				    remainNum:setColor(ccc3(0x00,0xff,0x18))
				    remainNum:setAnchorPoint(ccp(1,1))
				    remainNum:setScale(g_fScaleX)
				    remainNum:setPosition(ccp(_bgLayer:getContentSize().width-110*g_fScaleX,_bgLayer:getContentSize().height*0.9))
				    _bgLayer:addChild(remainNum)
				    local lable1 = CCRenderLabel:create(str,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
					lable1:setColor(ccc3(0xff,0xff,0xff))
				    lable1:setAnchorPoint(ccp(0,0.5))
				    -- lable1:setScale(g_fScaleX)
				    lable1:setPosition(ccp(remainNum:getContentSize().width, remainNum:getContentSize().height*0.5))
				    remainNum:addChild(lable1)
    			end
    		end
    	end
	end
	
	--预计总收益
	local moneyNum = LimitFundData.getExpectMoney()
	 local ret_1 = STScale9Sprite:create("images/common/bg/bg_9s_8.png", CCRectMake(22.0, 15.0, 12.0, 25.0)) 
    ret_1:setContentSize(CCSizeMake(235.0, 85.0))
    ret_1:setPercentPositionXEnabled(true)
    ret_1:setPercentPositionX(0.5)
    ret_1:setAnchorPoint(ccp(1, 1))
    ret_1:setScale(g_fScaleX)
    ret_1:setPosition(ccp(_bgLayer:getContentSize().width-20,_bgLayer:getContentSize().height*0.8))
    _bgLayer:addChild(ret_1)
    local ret_2 = STScale9Sprite:create("images/recharge/travel_shop/bg_1.png", CCRectMake(37.0, 13.0, 41.0, 15.0))
    ret_2:setContentSize(CCSizeMake(214.0, 41.0))
    ret_2:setPercentPositionYEnabled(true)
    ret_2:setPercentPositionY(0.8349)
    ret_2:setAnchorPoint(ccp(0.5, 0))
    ret_2:setPosition(ccp(ret_1:getContentSize().width*0.5,ret_1:getContentSize().height*g_fScaleX*0.98))
    ret_1:addChild(ret_2)
  
    local ret2Lable = CCRenderLabel:create(GetLocalizeStringBy("fqq_161"),g_sFontPangWa,22,1,ccc3(0x00,0x00,0x00),type_stroke)
	ret2Lable:setColor(ccc3(0xff,0xf6,0x00))
 	ret2Lable:setAnchorPoint(ccp(0.5,0.5))
	ret2Lable:setPosition(ccp(ret_2:getContentSize().width*0.5,ret_2:getContentSize().height*0.565))
	ret_2:addChild(ret2Lable)
    for i = 1, 5 do
		local numBgSprite = CCSprite:create("images/common/bg/9s_9.png")
		ret_1:addChild(numBgSprite)
		numBgSprite:setAnchorPoint(ccp(0, 0))
		numBgSprite:setPosition(ccp(numBgSprite:getContentSize().width * (i - 1) + 12, 12))
		if scrollViewContentSize == nil then
			numBgWidth = numBgSprite:getContentSize().width
			scrollViewContentSize = CCSizeMake(numBgSprite:getContentSize().width * 5, numBgSprite:getContentSize().height)
		end
	end
	local count = nil
	if _lastBuyCount == nil or _lastBuyCount > tonumber(moneyNum) then
		count = tonumber(moneyNum)
	else
		count = _lastBuyCount
	end
	
	local scrollView = CCScrollView:create()
	ret_1:addChild(scrollView)
	scrollView:setTouchEnabled(false)
	scrollView:setViewSize(scrollViewContentSize)
	scrollView:setContentSize(scrollViewContentSize)
	scrollView:setPosition(ccp(8, 8))

	local numLabel = BTNumerLabel:createWithPath("images/common", count)
	numLabel:setBitNum(5)
	scrollView:addChild(numLabel)
	numLabel:setAnchorPoint(ccp(0, 0.5))
	numLabel:setPosition(ccp(4, scrollView:getContentSize().height * 0.53))
	local numScale = 0.5
	local numWidth = numBgWidth / numScale
	numLabel:setScale(numScale)
	numLabel:setBitWidth(numWidth)


	if count < tonumber(moneyNum) then
		local countStr = tostring(count)
		local sumStr = tostring(moneyNum)
		if string.len(countStr) < string.len(sumStr) then
			countStr = string.rep("0", string.len(sumStr) - string.len(countStr)) .. countStr
		end 
		local startBit = nil
		for i = string.len(sumStr), 1, -1 do
			if string.byte(sumStr, i) ~= string.byte(countStr, i) then
				startBit = i
			end
		end
		local moveCountStr = string.sub(sumStr, startBit)
		local moveLabel = BTNumerLabel:createWithPath("images/common", moveCountStr)
		scrollView:addChild(moveLabel)
		moveLabel:setAnchorPoint(ccp(1, 0.5))
		moveLabel:setPosition(ccp(scrollViewContentSize.width, scrollViewContentSize.height))
		moveLabel:runAction(CCMoveTo:create(0.5, ccp(scrollViewContentSize.width, scrollViewContentSize.height * 0.5)))
		moveLabel:setScale(numScale)
		moveLabel:setBitWidth(numWidth)
		for i=1, string.len(moveCountStr) do
			local numSprite = numLabel:getNumSprite(i)
			numSprite:runAction(CCMoveBy:create(0.5, ccp(0, -numLabel:getContentSize().height)))
		end
	end

	local data = LimitFundData.getDataInfo()
	if(LimitFundData.getPeriodOfActivity() == 0 or table.isEmpty(data))then
	 	local tishi = CCRenderLabel:create(GetLocalizeStringBy("fqq_162"),g_sFontName,19,1,ccc3(0x00,0x00,0x00),type_stroke)
		tishi:setColor(ccc3(0xff,0xff,0xff))
		tishi:setScale(g_fScaleX)
	 	tishi:setAnchorPoint(ccp(1,1))
		tishi:setPosition(ccp(_bgLayer:getContentSize().width-10*g_fScaleX,ret_1:getPositionY() - ret_1:getContentSize().height*g_fScaleX-5*g_fScaleX))
		_bgLayer:addChild(tishi)
	end
    --创建信息板
    local panel = CCScale9Sprite:create("images/recharge/gift_panel.png")
	-- local tableViewHeight = tishi:getPositionY()- tishi:getContentSize().height*g_fScaleX-10*g_fScaleX
	panel:setContentSize(CCSizeMake(635,330))
	panel:setAnchorPoint(ccp(0.5,0))
	panel:setScale(g_fScaleX)
	panel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,20))
	_bgLayer:addChild(panel)
	-- print("g_winSize.height",g_winSize.height)
	-- print("_bgLayer:getContentSize().height",_bgLayer:getContentSize().height)
	-- print("panel:getContentSize().height",panel:getContentSize().height)
	-- 物品的背景
	_itemBg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	_itemBg:setContentSize(CCSizeMake(605,300))
	_itemBg:setPosition(ccp(panel:getContentSize().width/2,  panel:getContentSize().height/2))
	_itemBg:setAnchorPoint(ccp(0.5,0.5))
	panel:addChild(_itemBg)


	local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_priority - 10)
    panel:addChild(menuBar,10)
    local data = LimitFundData.getDataInfo()
	if(LimitFundData.getPeriodOfActivity() == 0 or table.isEmpty(data))then
		 for i=1,3 do
	    	--小背景
	    	local littleSprite =  CCSprite:create("images/recharge/jijinban.png")
	    	littleSprite:setAnchorPoint(ccp(0,1))
	    	littleSprite:setPosition(ccp(25*i+(i-1)*littleSprite:getContentSize().width-25*(i-1),panel:getContentSize().height-30))
	    	-- littleSprite:setScale(g_fScaleX)
	    	panel:addChild(littleSprite)
	    	if(i ~= 1)then
	    		local limitbuyVip = CCSprite:create("images/recharge/v"..i..".png")
		    	limitbuyVip:setAnchorPoint(ccp(0.5,0.5))
		    	limitbuyVip:setPosition(ccp(littleSprite:getContentSize().width*0.17,littleSprite:getContentSize().height*0.96))
		    	littleSprite:addChild(limitbuyVip)
	    	end
	    	
	    	local menuBar = CCMenu:create()
			menuBar:setPosition(ccp(0,0))
			menuBar:setTouchPriority(_priority - 10)
			littleSprite:addChild(menuBar,10)
	    	local data = LimitFundData.getLimitFundInfoById(i)
	    	local color = ccc3(0xff,0xf6,0x00)
	    	if( i == 1)then
	    		color = ccc3(0xff,0xd8,0xc0)
	    	elseif i==2 then
	    		color = ccc3(0xff,0xff,0xff)
	    	end
			--名称 
			local curLable_1 = CCRenderLabel:create(data.name,g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
			curLable_1:setColor(color)
		 	curLable_1:setAnchorPoint(ccp(0.5,1))
			curLable_1:setPosition(ccp(littleSprite:getContentSize().width*0.5,littleSprite:getContentSize().height-10))
			littleSprite:addChild(curLable_1)

			local sprite = CCSprite:create()
				  sprite:setAnchorPoint(ccp(0.5,0.5))
			--价格
			local curLable_2 = CCRenderLabel:create(data.price,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
			curLable_2:setColor(ccc3(0xff,0xf6,0x00))
		 	curLable_2:setAnchorPoint(ccp(0,0))
			curLable_2:setPosition(ccp(0,20))
			sprite:addChild(curLable_2)

			local curLableNum_2 = CCRenderLabel:create(GetLocalizeStringBy("fqq_148"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
			curLableNum_2:setColor(ccc3(0xff,0xff,0xff))
		 	curLableNum_2:setAnchorPoint(ccp(0,0))
			curLableNum_2:setPosition(ccp(curLable_2:getContentSize().width,20))
			sprite:addChild(curLableNum_2)

			sprite:setContentSize(CCSizeMake(curLable_2:getContentSize().width+curLableNum_2:getContentSize().width,curLableNum_2:getContentSize().height))
			littleSprite:addChild(sprite)
			sprite:setPosition(ccp(littleSprite:getContentSize().width*0.5,littleSprite:getContentSize().height*0.5+10))
			--返还量
			local curLable_3 = CCRenderLabel:create(GetLocalizeStringBy("fqq_172"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
			curLable_3:setColor(ccc3(0xff,0xff,0xff))
		 	curLable_3:setAnchorPoint(ccp(0,1))
			curLable_3:setPosition(ccp(littleSprite:getContentSize().width*0.25,littleSprite:getContentSize().height-38-curLable_1:getContentSize().height-curLable_2:getContentSize().height))
			littleSprite:addChild(curLable_3)
			local baifen = data.gold/data.price
			local format = tonumber(string.format("%.2f",baifen))*100
			local curLableNum_3 = CCRenderLabel:create(format.."%",g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
			curLableNum_3:setColor(ccc3(0xff,0x84,0x00))
		 	curLableNum_3:setAnchorPoint(ccp(0,0.5))
			curLableNum_3:setPosition(ccp(curLable_3:getContentSize().width,curLable_3:getContentSize().height*0.5))
			curLable_3:addChild(curLableNum_3)
			--购买按钮
		    local btn = CCMenuItemImage:create("images/newserve/buttonbuy-n.png","images/newserve/buttonbuy-h.png")
		    btn:setAnchorPoint(ccp(0.5,1))
		    btn:setPosition(ccp(littleSprite:getContentSize().width*0.5,-10))
		    btn:registerScriptTapHandler(buycallBcak)
		    menuBar:addChild(btn,1,data.id)
			
			--判断这个基金有没有被购买过
			local isHaveBuy = LimitFundData.getTypeOfNumTableById(i)
			if(isHaveBuy)then	
				-- if()then
				local num = LimitFundData.getAllreadyNum(i)
				local allreadyNumLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_157"),g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
				allreadyNumLable:setColor(ccc3(0xff,0xff,0xff))
			 	allreadyNumLable:setAnchorPoint(ccp(0.5,0))
				allreadyNumLable:setPosition(ccp(littleSprite:getContentSize().width*0.38,littleSprite:getContentSize().height*0.15))
				littleSprite:addChild(allreadyNumLable)
				local allreadyNumLable_1 = CCRenderLabel:create(num,g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
				allreadyNumLable_1:setColor(ccc3(0x00,0xff,0x18))
			 	allreadyNumLable_1:setAnchorPoint(ccp(0,0.5))
				allreadyNumLable_1:setPosition(ccp(allreadyNumLable:getContentSize().width,allreadyNumLable:getContentSize().height*0.5))
				allreadyNumLable:addChild(allreadyNumLable_1)
				local allreadyNumLable_2 = CCRenderLabel:create(GetLocalizeStringBy("fqq_147"),g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
				allreadyNumLable_2:setColor(ccc3(0xff,0xff,0xff))
			 	allreadyNumLable_2:setAnchorPoint(ccp(0,0.5))
				allreadyNumLable_2:setPosition(ccp(allreadyNumLable:getContentSize().width+allreadyNumLable_1:getContentSize().width,allreadyNumLable:getContentSize().height*0.5))
				allreadyNumLable:addChild(allreadyNumLable_2)
			end
		end
	else
		createMiddleUIOfReturn()
	end
   
    -- end

	
end

--返还阶段的UI
function createTopUIOfReturn( ... )
	-- if(_bgLayer)then
	-- 	_bgLayer:removeAllChildrenWithCleanup(true)
	-- end
	--背景
	local BG_full_rect = CCRectMake(0, 0, 196, 198)
    local BG_inset_rect = CCRectMake(61, 80, 46, 36)
    _bg = CCScale9Sprite:create("images/hero/bg_ng.png")
    local preferred_size = CCSizeMake(640,_bgLayer:getContentSize().height)
    -- _bg:setPreferredSize(preferred_size)
    _bg:setContentSize(preferred_size)
    _bg:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height))
    _bg:setAnchorPoint(ccp(0.5, 1))
    _bg:setScale(g_fScaleX)
    _bgLayer:addChild(_bg)
 
	-- 活动名称
	local spriteBg = CCSprite:create("images/recharge/title.png")
	spriteBg:setAnchorPoint(ccp(0.5,1))
	spriteBg:setPosition(ccp(_bg:getContentSize().width*0.5,_bg:getContentSize().height-5))
	_bg:addChild(spriteBg)
	
	-- 描述(基金返还开始啦)
	local curLable_2 = CCRenderLabel:create(GetLocalizeStringBy("fqq_155"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	curLable_2:setColor(ccc3(0xff,0xff,0xff))
 	curLable_2:setAnchorPoint(ccp(0.5,1))
	curLable_2:setPosition(ccp(_bg:getContentSize().width*0.5,_bg:getContentSize().height - spriteBg:getContentSize().height - 10))
	_bg:addChild(curLable_2)
	--活动时间
	local beginTime = LimitFundData.getBeginTime()
	local endTime = LimitFundData.getEndTime()
	local timeLabel = CCRenderLabel:create(TimeUtil.getTimeForDayTwo(beginTime)..GetLocalizeStringBy("fqq_173")..TimeUtil.getTimeForDayTwo(endTime),g_sFontName, 21,1, ccc3(0x00,0,0),type_stroke)
	timeLabel:setColor(ccc3(0x00,0xff,0x18))
	timeLabel:setAnchorPoint(ccp(0,1))
	timeLabel:setPosition(ccp(5, _bg:getContentSize().height - spriteBg:getContentSize().height -15 - curLable_2:getContentSize().height))
	_bg:addChild(timeLabel)
	local endTime = LimitFundData.getEndTime()
	--倒计时
	 local strLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_100"),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    strLable:setColor(ccc3(0x00,0xff,0x18))
    strLable:setAnchorPoint(ccp(0,1))
    strLable:setPosition(ccp(_bg:getContentSize().width*0.55,  _bg:getContentSize().height - spriteBg:getContentSize().height -15 - curLable_2:getContentSize().height))
    _bg:addChild(strLable)
  
     --倒计时
    _countdownTime2 =CCRenderLabel:create(TimeUtil.getRemainTime(endTime),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    _countdownTime2:setColor(ccc3(0x00,0xff,0x18))
    _countdownTime2:setAnchorPoint(ccp(0,0.5))
    _countdownTime2:setPosition(ccp(strLable:getContentSize().width,strLable:getContentSize().height*0.5))
    strLable:addChild(_countdownTime2)
    local timestr =  tonumber(endTime) - tonumber(TimeUtil.getSvrTimeByOffset())
    if(timestr > 0)then
    	startSchedule()
    end
 
     _viewBgSpriteHeight = _bg:getContentSize().height - spriteBg:getContentSize().height -50 - curLable_2:getContentSize().height - timeLabel:getContentSize().height
    -- _viewBgSpriteHeight = strLable:getPositionY()-strLable:getContentSize().height-40
    createMiddleUIOfReturn()
end

--创建TableView背景
function createMiddleUIOfReturn( ... )
	--获取有几条数据
	local typeNumTable = LimitFundData.getTypeOfNumTable()
	
	local dataInfo = LimitFundData.getLimitFundInfo()
	local function keySort ( _data1, _data2 )
         return tonumber(_data1.type) < tonumber(_data2.type)
    end
    table.sort(typeNumTable,keySort)
	_data = {}
	for k1,v1 in pairs(typeNumTable) do
		table.insert(_data,dataInfo[v1.type])
	end
	createTableView()
end

--创建TableView
function createTableView( ... )

		-- 左箭头 
		_leftArrowSp = CCSprite:create("images/formation/btn_left.png")
	    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
	    _leftArrowSp:setPosition(-7,_itemBg:getContentSize().height*0.5)
	    _itemBg:addChild(_leftArrowSp,5)
	    _leftArrowSp:setVisible(false)
	    -- _leftArrowSp:setScale(g_fElementScaleRatio)
	    LimitFundData.runArrowAction(_leftArrowSp)

		-- 右箭头 
	    _rightArrowSp = CCSprite:create("images/formation/btn_right.png")
	    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
	    _rightArrowSp:setPosition(_itemBg:getContentSize().width+7,_itemBg:getContentSize().height*0.5)
	    _itemBg:addChild(_rightArrowSp,5)
	    _rightArrowSp:setVisible(true)
	    -- _rightArrowSp:setScale(g_fElementScaleRatio)
	    LimitFundData.runArrowAction(_rightArrowSp)
	local h = LuaEventHandler:create(function ( fn,p_table,a1,a2)
            local r
            if fn == "cellSize" then
                r = CCSizeMake(210,250)
            elseif fn == "cellAtIndex" then
                a2 = LimitFundCell.createCell(_data, a1 + 1,-630)
                r = a2
            elseif fn == "numberOfCells" then
                r = 5
            elseif fn == "scroll" then
			-- 更新箭头
    		updateArrowShowSttus()
            end
            return r
        end)
	
        _tableView = LuaTableView:createWithHandler(h,CCSizeMake(_itemBg:getContentSize().width,_itemBg:getContentSize().height-10))
        _itemBg:addChild(_tableView)
        _tableView:setDirection(kCCScrollViewDirectionHorizontal)
        _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
        _tableView:setAnchorPoint(ccp(0.5,0.5))
        _tableView:setPosition(ccp(_itemBg:getContentSize().width * 0.5, _itemBg:getContentSize().height * 0.5))
        _tableView:ignoreAnchorPointForPosition(false)
        _tableView:setTouchPriority(-600)
 
end

function updateArrowShowSttus( )
	-- 根据当前的显示的位置,更新箭头显示
	 if (_tableView == nil) then
        return
    end

    local offset = _tableView:getContentSize().width + _tableView:getContentOffset().x - _tableView:getViewSize().width
	if (_rightArrowSp ~= nil) then
		if (offset > 1 or offset < -1) then
			_rightArrowSp:setVisible(true)
		else
			_rightArrowSp:setVisible(false)
		end
	end

	if (_leftArrowSp ~= nil) then
		if (_tableView:getContentOffset().x < 0) then
			_leftArrowSp:setVisible(true)
		else
			_leftArrowSp:setVisible(false)
		end
	end
end
--刷新tableView
function updataTableView( ... )
    local offset = _tableView:getContentOffset()
    _tableView:reloadData()
    _tableView:setContentOffsetInDuration(offset,0)
end
--购买回调
function buycallBcak( tag )
	if(LimitFundData.isActivityOver())then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_114"))
		return
	end
	--用户vip级别
	local vipLevel = UserModel.getVipLevel()
	local gold = UserModel.getGoldNumber()
	local data = LimitFundData.getLimitFundInfoById(tag)
	if(vipLevel < tonumber(data.need_vip))then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_149"))
        return
	end
	if(LimitFundData.getMaxBuyTimes() == 0)then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_150"))
        return
    else
    	if(gold < tonumber(data.price))then
    		require "script/ui/tip/AnimationTip"
	        AnimationTip.showTip(GetLocalizeStringBy("fqq_078"))
	        return
    	end
	end
	LimitFundBuyLayer.showPurchaseLayer(tag)

end