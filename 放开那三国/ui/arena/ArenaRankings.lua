-- FileName: ArenaRankings.lua 
-- Author: Li Cong 
-- Date: 13-8-13 
-- Purpose: function description of module 


module("ArenaRankings", package.seeall)


-- 创建竞技排名层
function createArenaRankingsLayer( ... )
	mainLayer = CCLayer:create()
	-- mainLayer = CCLayerColor:create(ccc4(255,0,0,100))
	
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
	local todaySurplusNum_font = CCLabelTTF:create(GetLocalizeStringBy("key_1188"), g_sFontName, 24*MainScene.elementScale)
	todaySurplusNum_font:setAnchorPoint(ccp(0,1))
	todaySurplusNum_font:setPosition(ccp(50*MainScene.elementScale, curRanking_font:getPositionY()-curRanking_font:getContentSize().height-10*MainScene.elementScale))
	mainLayer:addChild(todaySurplusNum_font)
	-- 声望图标
	local prestigeIcon = CCSprite:create("images/common/prestige.png")
	prestigeIcon:setAnchorPoint(ccp(0,1))
	prestigeIcon:setPosition(ccp(todaySurplusNum_font:getPositionX()+todaySurplusNum_font:getContentSize().width+10*MainScene.elementScale,curRanking_font:getPositionY()-curRanking_font:getContentSize().height-10*MainScene.elementScale))
	mainLayer:addChild(prestigeIcon)
	prestigeIcon:setScale(g_fScaleX)
	-- 当前声望值
	local numData = UserModel.getPrestigeNum() or 0
	todaySurplusNum = CCLabelTTF:create( numData, g_sFontName, 24*MainScene.elementScale)
	todaySurplusNum:setAnchorPoint(ccp(0,1))
	todaySurplusNum:setColor(ccc3(0xff,0xf6,0x01))
	todaySurplusNum:setPosition(ccp(todaySurplusNum_font:getPositionX()+todaySurplusNum_font:getContentSize().width+45*MainScene.elementScale, todaySurplusNum_font:getPositionY()-2*MainScene.elementScale))
	mainLayer:addChild(todaySurplusNum)

	-- 创建幸运排名按钮
	local luckMenu = CCMenu:create()
	luckMenu:setTouchPriority(-150)
	luckMenu:setPosition(ccp(0,0))
	mainLayer:addChild(luckMenu)
	local luckMenuItem = CCMenuItemImage:create("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png")
	luckMenuItem:setAnchorPoint(ccp(1,1))
	luckMenuItem:setPosition(ccp(ArenaLayer.layerSize.width-15*MainScene.elementScale, ArenaLayer.menuBg:getPositionY()-ArenaLayer.menuBg:getContentSize().height*MainScene.elementScale-8*MainScene.elementScale))
	luckMenu:addChild(luckMenuItem)
	luckMenuItem:setScale(g_fScaleX)
	-- 注册挑战回调
	luckMenuItem:registerScriptTapHandler(luckMenuItemCallFun)
	-- 幸运排名文字
	local fontSize = 30
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		fontSize = 22
	end
	local luckFont = CCRenderLabel:create( GetLocalizeStringBy("key_3319") , g_sFontPangWa, fontSize, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    luckFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
    luckFont:setPosition(ccp(36,luckMenuItem:getContentSize().height-10))
   	luckMenuItem:addChild(luckFont)

	-- 上分界线
	local topSeparator = CCSprite:create("images/common/separator_top.png")
	topSeparator:setAnchorPoint(ccp(0.5,1))
	topSeparator:setPosition(ccp(ArenaLayer.layerSize.width*0.5,todaySurplusNum_font:getPositionY()-todaySurplusNum_font:getContentSize().height-10*MainScene.elementScale))
	mainLayer:addChild(topSeparator,2)
	topSeparator:setScale(g_fScaleX)

	-- 创建人物滑动列表tabView
	tableView_width = ArenaLayer.layerSize.width
	tableView_hight = topSeparator:getPositionY()-10
	-- 创建下一步ui
	local function createNext( ... )
		-- 创建列表
		createRankTabView()
   	end
   	-- 初始化列表数据
	ArenaService.getRankList(createNext)

	return mainLayer
end


-- 创建排行榜滑动列表
function createRankTabView()
	-- cellBg的size
	local cellBg = CCSprite:create( "images/arena/arena_cellbg.png")
	local cellSize = cellBg:getContentSize() 
	-- 得到竞技场的所有玩家
	local topTenData = ArenaData.getTopTenData( ArenaData.rankListData )
	-- print(GetLocalizeStringBy("key_2105")) 
	-- print_t(topTenData)

	require "script/ui/arena/RankingsCell"
	-- local rewardList = RewardCenterData.getRewardList()
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 10
			r = CCSizeMake(cellSize.width*g_fScaleX, (cellSize.height + interval)*g_fScaleX)
		elseif (fn == "cellAtIndex") then
			r = RankingsCell.createCell(topTenData[a1+1])
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			r = #topTenData
		elseif (fn == "cellTouched") then
			-- print ("a1: ", a1, ", a2: ", a2)
			-- print ("cellTouched, index is: ", a1:getIdx())
		else
			-- print (fn, " event is not handled.")
		end
		return r
	end)

	rankTableView  = LuaTableView:createWithHandler(handler, CCSizeMake(tableView_width,tableView_hight))
	rankTableView:setBounceable(true)
	rankTableView:setAnchorPoint(ccp(0, 0))
	rankTableView:setPosition(ccp(0, 0))
	mainLayer:addChild(rankTableView)
	-- 设置单元格升序排列
	rankTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	rankTableView:setTouchPriority(-130)
end


-- 幸运排名按钮回调
function luckMenuItemCallFun( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print("here is  幸运排名回调!" )
	require "script/ui/arena/LuckRankingList"
	LuckRankingList.createLuckRankingLayer()
end






