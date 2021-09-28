-- FileName: ArenaChallenge.lua 
-- Author: Li Cong 
-- Date: 13-8-13 
-- Purpose: function description of module 


module("ArenaChallenge", package.seeall)

-- 全局变量
m_prestigeLabel = nil						-- 声望
curRanking = nil  							-- 当前名次
challengeTableView = nil					-- 竞技列表

--  local 全局变量
local mainLayer = nil						-- 竞技层
local tableView_width = 0                   -- 滑动列表的宽
local tableView_hight = 0 					-- 滑动列表的高


-- 创建竞技挑战层
function createArenaChallengeLayer( ... )
	mainLayer = CCLayer:create()
	-- mainLayer = CCLayerColor:create(ccc4(255,255,255,100))

	-- 当前排名
	local curRanking_font = CCLabelTTF:create(GetLocalizeStringBy("key_2128"), g_sFontName, 24*MainScene.elementScale)
	curRanking_font:setAnchorPoint(ccp(0,1))
	curRanking_font:setPosition(ccp(50*MainScene.elementScale, ArenaLayer.menuBg:getPositionY()-ArenaLayer.menuBg:getContentSize().height*MainScene.elementScale-10*MainScene.elementScale))
	mainLayer:addChild(curRanking_font)
	-- 当前排名数据
	local curData = ArenaData.getSelfRanking() or 0
	curRanking = CCLabelTTF:create( curData, g_sFontName, 24*MainScene.elementScale)
	curRanking:setAnchorPoint(ccp(0,1))
	curRanking:setColor(ccc3(0xff,0xf6,0x01))
	curRanking:setPosition(ccp(curRanking_font:getPositionX()+curRanking_font:getContentSize().width+10*MainScene.elementScale, curRanking_font:getPositionY()-2*MainScene.elementScale))
	mainLayer:addChild(curRanking)

	-- 当前声望
	local m_prestigeLabel_font = CCLabelTTF:create(GetLocalizeStringBy("key_1188"), g_sFontName, 24*MainScene.elementScale)
	m_prestigeLabel_font:setAnchorPoint(ccp(0,1))
	m_prestigeLabel_font:setPosition(ccp(50*MainScene.elementScale, curRanking_font:getPositionY()-curRanking_font:getContentSize().height-10*MainScene.elementScale))
	mainLayer:addChild(m_prestigeLabel_font)
	-- 声望图标
	local prestigeIcon = CCSprite:create("images/common/prestige.png")
	prestigeIcon:setAnchorPoint(ccp(0,1))
	prestigeIcon:setPosition(ccp(m_prestigeLabel_font:getPositionX()+m_prestigeLabel_font:getContentSize().width+10*MainScene.elementScale,curRanking_font:getPositionY()-curRanking_font:getContentSize().height-10*MainScene.elementScale))
	mainLayer:addChild(prestigeIcon)
	prestigeIcon:setScale(g_fScaleX)
	--------------------
	-- 今日剩余挑战次数数据 这种算法已舍弃
	-- local numData = ArenaData.getTodaySurplusNum()
	--------------------
	-- 当前声望值
	local numData = UserModel.getPrestigeNum() or 0
	m_prestigeLabel = CCLabelTTF:create( numData, g_sFontName, 24*MainScene.elementScale)
	m_prestigeLabel:setAnchorPoint(ccp(0,1))
	m_prestigeLabel:setColor(ccc3(0xff,0xf6,0x01))
	m_prestigeLabel:setPosition(ccp(m_prestigeLabel_font:getPositionX()+m_prestigeLabel_font:getContentSize().width+45*MainScene.elementScale, m_prestigeLabel_font:getPositionY()-2*MainScene.elementScale))
	mainLayer:addChild(m_prestigeLabel)

	-- 奖励发放提示
	local awardPrompt = CCLabelTTF:create(GetLocalizeStringBy("key_1709"), g_sFontName, 24*MainScene.elementScale)
	awardPrompt:setColor(ccc3(0x36,0xff,0x00))
	awardPrompt:setAnchorPoint(ccp(1,1))
	awardPrompt:setPosition(ccp(ArenaLayer.layerSize.width-40*MainScene.elementScale, ArenaLayer.menuBg:getPositionY()-ArenaLayer.menuBg:getContentSize().height*MainScene.elementScale-10*MainScene.elementScale))
	mainLayer:addChild(awardPrompt)

	-- 领奖倒计时
	local getAwardTime_font = CCLabelTTF:create(GetLocalizeStringBy("key_3180"), g_sFontName, 24*MainScene.elementScale)
	getAwardTime_font:setColor(ccc3(0x36,0xff,0x00))
	getAwardTime_font:setAnchorPoint(ccp(1,1))
	getAwardTime_font:setPosition(ccp(ArenaLayer.layerSize.width-168*MainScene.elementScale, awardPrompt:getPositionY()-awardPrompt:getContentSize().height-10*MainScene.elementScale))
	mainLayer:addChild(getAwardTime_font)
	-- 倒计时数据
	local timeStr = nil
	-- 判断是否在领奖中 倒计时时间小于等于0
	if( ArenaData.getAwardTime() <= 0 )then
		timeStr = GetLocalizeStringBy("key_2723")
	else
		-- 倒计时大于0
		timeStr = TimeUtil.getTimeString(ArenaData.getAwardTime())
	end
	local awardTime_font = CCLabelTTF:create(timeStr, g_sFontName, 24*MainScene.elementScale)
	awardTime_font:setColor(ccc3(0x00,0xe4,0xff))
	awardTime_font:setAnchorPoint(ccp(0,1))
	awardTime_font:setPosition(ccp(getAwardTime_font:getPositionX()+3, getAwardTime_font:getPositionY()-2))
	mainLayer:addChild(awardTime_font)
	awardTime_font:registerScriptHandler(function ( eventType,node )
		if(eventType == "exit") then
			if(ArenaData.arenaScheduleId[1] ~= nil)then
   				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.arenaScheduleId[1])
   				ArenaData.arenaScheduleId[1] = nil
	   		end
		end
	end)
	-- 更新倒计时
	local function updateRewardTime1()
	    -- print("updateRewardTime1")
		if (ArenaData.getAwardTime() <= 0) then 
			-- 到期取消定时器
			awardTime_font:setString(GetLocalizeStringBy("key_2723"))
			if(ArenaData.arenaScheduleId[1] ~= nil)then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.arenaScheduleId[1])
				ArenaData.arenaScheduleId[1] = nil
			end
			return
		end
		local timeStr = TimeUtil.getTimeString(ArenaData.getAwardTime())
		awardTime_font:setString(timeStr)
	end
	if (ArenaData.getAwardTime() > 0 ) then 
		-- 启动定时器
		if( ArenaData.arenaScheduleId[1] == nil )then
			ArenaData.arenaScheduleId[1] = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateRewardTime1, 1, false)
		end
	end
	-- 上分界线
	local topSeparator = CCSprite:create("images/common/separator_top.png")
	topSeparator:setAnchorPoint(ccp(0.5,1))
	topSeparator:setPosition(ccp(ArenaLayer.layerSize.width*0.5,getAwardTime_font:getPositionY()-getAwardTime_font:getContentSize().height-10))
	mainLayer:addChild(topSeparator,2)
    topSeparator:setScale(g_fScaleX)
	-- 创建人物滑动列表tabView
	tableView_width = ArenaLayer.layerSize.width
	tableView_hight = topSeparator:getPositionY()-10
	createChallengeTabView()
	return mainLayer
end


-- 创建人物滑动列表
function createChallengeTabView()
	-- cellBg的size
	local cellBg = CCSprite:create("images/arena/arena_cellbg.png")
	local cellSize = cellBg:getContentSize() 
	-- 得到竞技场的所有玩家
	ArenaData.allUserData = ArenaData.getOpponentsData()
	local user_count = table.count(ArenaData.allUserData)
	-- print(GetLocalizeStringBy("key_2881")) 
	-- print_t(ArenaData.allUserData)

	require "script/ui/arena/ChallengeCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 10
			r = CCSizeMake(cellSize.width*g_fScaleX, (cellSize.height + interval)*g_fScaleX)
		elseif (fn == "cellAtIndex") then
			r = ChallengeCell.createCell(ArenaData.allUserData[a1+1])
            r:setScale(g_fScaleX)
			-- print("a1",a1)
			-- print_t(ArenaData.allUserData[a1+1])
		elseif (fn == "numberOfCells") then
			r = #ArenaData.allUserData
		elseif (fn == "cellTouched") then
			-- print ("a1: ", a1, ", a2: ", a2)
			-- print ("cellTouched, index is: ", a1:getIdx())
		else
			-- print (fn, " event is not handled.")
		end
		return r
	end)

	challengeTableView  = LuaTableView:createWithHandler(handler, CCSizeMake(tableView_width,tableView_hight))
	challengeTableView:setBounceable(true)
	challengeTableView:setAnchorPoint(ccp(0, 0))
	challengeTableView:setPosition(ccp(0, 0))
	mainLayer:addChild(challengeTableView)
	-- 设置单元格升序排列
	challengeTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	challengeTableView:setTouchPriority(-130)

	-- 如果玩家不足10名 不居中显示
	if(user_count >= 10)then
		-- 设置偏移量 让自己居中
		local index = nil
		for k,v in pairs(ArenaData.allUserData) do
			if( tonumber(v.uid) == UserModel.getUserUid() )then
				-- 如果是主角
				index = tonumber(k)
			end
		end
		-- 1默认显示在顶部,2名正常显示,11名显示底部,其他显示中间
		if(index ~= 1 and index ~= 2 and index ~= 11)then
			-- 设置偏移量 把自己显示在中间
			challengeTableView:setContentOffset( ccp(0, (index-10)*(cellSize.height+10)-18 ))
		end
		-- 如果是最后一名 
		if(index == 11)then
			-- 设置偏移量 把自己显示在最底部
			challengeTableView:setContentOffset( ccp(0, (index-11)*(cellSize.height+10)+15 ))
		end
	end
end



--  更新竞技滑动列表 推送专用
function updateArenaChallengeTableView()
	if(ArenaChallenge.challengeTableView ~= nil)then
		-- 更新玩家列表UI
		ArenaData.allUserData = ArenaData.getOpponentsData()
		ArenaChallenge.challengeTableView:reloadData()
		-- 设置偏移量 让自己居中
		local cellBg = CCSprite:create( "images/arena/arena_cellbg.png")
		local cellSize = cellBg:getContentSize() 
		local index = nil
		require "script/model/user/UserModel"
		for k,v in pairs(ArenaData.allUserData) do
			if( tonumber(v.uid) == UserModel.getUserUid() )then
				-- 如果是主角
				index = tonumber(k)
			end
		end
		-- 1默认显示在顶部,2名正常显示,11名显示底部,其他显示中间
		if(index ~= 1 and index ~= 2 and index ~= 11)then
			-- 设置偏移量 把自己显示在中间
			ArenaChallenge.challengeTableView:setContentOffset( ccp(0, (index-10)*(cellSize.height+10)-18 ))
		end
		-- 如果是最后一名 
		if(index == 11)then
			-- 设置偏移量 把自己显示在最底部
			ArenaChallenge.challengeTableView:setContentOffset( ccp(0, (index-11)*(cellSize.height+10)+15 ))
		end
	end
end















