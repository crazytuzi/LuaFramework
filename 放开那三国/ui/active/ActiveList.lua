-- FileName: ActiveList.lua
-- Author: Li Cong
-- Date: 13-8-10
-- Purpose: function description of module
-- 活动入口

module("ActiveList", package.seeall)
require "script/model/DataCache"
require "script/ui/item/ItemUtil"
require "script/ui/active/ActiveListService"
require "script/ui/active/ActiveListData"

-- local 全局变量
local IMG_PATH = "images/active/activeList/"					-- 图片主路径
local cellHeight = 232                                          -- 单元格高度
local cellInterval = 5                                         	-- 单元格间隔距离
local m_activeList 					= nil       				-- 活动列表层
local layerSize    					= nil                       -- 活动列表层大小
local titleSize    					= nil						-- 上方标题栏宽高
local refreshActiveListGold 		= nil						-- 刷新金币函数
local liebiao      					= nil  						-- 列表
local menuItem_arr 					= {} 						-- 新手按钮对象	
local _topMenuBg 					= nil							
local _topMenuData 					= nil 						-- 置顶图标数据

local _lastMeunNum 					= 0 						-- 上次剩余按钮数量

_ksTagTreasure 		= 1 -- 夺宝
_ksTagjingjichang 	= 2 -- 竞技场
_ksTagshilianta 	= 3 -- 试练塔
_ksTagbiwu 			= 4 -- 比武
_ksTagziyuankuang 	= 5 -- 资源矿
_ksTagLianYu		= 6 -- 炼狱挑战
_ksTagHorse 		= 7 -- 木牛流马
_ksTagGodWeaponCopy = 8 -- 过关斩将
_ksTagShuiYue 		= 9 -- 水月之境
_ksTagxunlong 	  	= 10 -- 寻龙探宝
_ksTagkfbw          = 11 -- 跨服比武
_ksTagshijieboss 	= 12 -- 世界boss
_ksTagOlympic 		= 13 -- 擂台争霸
_ksTagDevilTower    = 14 -- 试炼梦魇

local _allList 			= {}
local _allNum 			= 0
-- 普通类活动
local _normalList 		= {
	{name = "duobao",tag = _ksTagTreasure, switchId = ksSwitchRobTreasure },
	{name = "jingjichang",tag = _ksTagjingjichang, switchId = ksSwitchArena },
	{name = "shilianta",tag = _ksTagshilianta, switchId = ksSwitchTower },
	{name = "biwu",tag = _ksTagbiwu, switchId = ksSwitchContest },
	{name = "ziyuankuang",tag = _ksTagziyuankuang, switchId = ksSwitchResource },
	{name = "lianyu",tag = _ksTagLianYu, switchId = ksSwitchHellCopy },
	{name = "mnlm",tag = _ksTagHorse, switchId = ksSwitchMnlm },
	{name = "godweapon",tag = _ksTagGodWeaponCopy, switchId = ksSwitchGodWeapon },
	{name = "shuiyue",tag = _ksTagShuiYue, switchId = ksSwitchMoon },
	{name = "xunlong",tag = _ksTagxunlong, switchId = ksFindDragon },
	{name = "kfbw",tag = _ksTagkfbw, switchId = ksSwitchKFBW },
}
-- 限时类活动
local _specialList 		= {
	{name = "shijieboss",tag = _ksTagshijieboss, switchId = ksSwitchWorldBoss },
	{name = "olympic",tag = _ksTagOlympic, switchId = ksOlympic },
}
	

function init( ... )
	m_activeList 				= nil       							    	
	layerSize    				= nil                                     	
	titleSize    				= nil										
	refreshActiveListGold 		= nil								
	liebiao      				= nil  										
	menuItem_arr 				= {} 
	_topMenuBg 					= nil
	_topMenuData 				= nil 
	_allList 					= {}
	_allNum 					= 0
end

--[[
	@des 	:处理enter和exit事件
	@param 	:
	@return :
--]]
local function onNodeEvent( event )
	if (event == "enter") then
		require "script/ui/shop/RechargeLayer"
		RechargeLayer.registerChargeGoldCb(refreshActiveListGold)
	elseif (event == "exit") then
		require "script/ui/shop/RechargeLayer"
		RechargeLayer.registerChargeGoldCb(nil)
		-- 记忆列表offset
		if( not tolua.isnull(liebiao) )then
			local offset = liebiao:getContentOffset()
			MainScene.setOffsetForList(offset)
		end
		_lastMeunNum = table.count(_topMenuData)
	end
end

--  活动入口MenuItme回调
local function activeItemCallFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    require "script/guide/ArenaGuide"
    require "script/guide/MineralGuide"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if (tag == _ksTagjingjichang) then
		-- print (GetLocalizeStringBy("key_2467"))
		if(ItemUtil.isBagFull() == true )then
			ArenaGuide.closeGuide()
			return
		end
		-- 判断武将满了
		require "script/ui/hero/HeroPublicUI"
	    if HeroPublicUI.showHeroIsLimitedUI() then
 
	    	return
	    end
		---[==[竞技场 清除新手引导
		---------------------新手引导---------------------------------
		--add by licong 2013.09.29
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideArena) then
			require "script/guide/ArenaGuide"
			ArenaGuide.cleanLayer()
		end
		---------------------end-------------------------------------
		--]==]
		local canEnter = DataCache.getSwitchNodeState( ksSwitchArena )
		if( canEnter ) then
			require "script/ui/arena/ArenaLayer"
			local arenaLayer = ArenaLayer.createArenaLayer()
			MainScene.changeLayer(arenaLayer, "arenaLayer")
		end
	-- Add by yangrui on 15-09-23
	elseif ( tag == _ksTagkfbw ) then
		local canEnter = DataCache.getSwitchNodeState( ksSwitchKFBW )
		if ( canEnter ) then
			-- 跨服比武
			require "script/ui/kfbw/KuafuLayer"
			KuafuLayer.showKFBWLayer()
		end
	elseif (tag == _ksTagziyuankuang) then
		-- print (GetLocalizeStringBy("key_2551"))
		---[==[资源矿 新手引导屏蔽层
		---------------------新手引导---------------------------------
		--add by licong 2013.09.29
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideResource) then
			require "script/guide/MineralGuide"
			MineralGuide.changLayer()
		end
		---------------------end-------------------------------------
		--]==]
		local canEnter = DataCache.getSwitchNodeState( ksSwitchResource )
		if( canEnter ) then
			require "script/ui/active/mineral/MineralLayer"
			local mineralLayer = MineralLayer.createLayer()
			MainScene.changeLayer(mineralLayer, "mineralLayer")
		end
	elseif (tag == _ksTagbiwu) then
		-- print (GetLocalizeStringBy("key_1842"))
		if(ItemUtil.isBagFull() == true )then
			return
		end
		-- 判断武将满了
		require "script/ui/hero/HeroPublicUI"
	    if HeroPublicUI.showHeroIsLimitedUI() then
	    	return
	    end
		---[==[比武 新手引导屏蔽层
		---------------------新手引导---------------------------------
		--add by licong 2013.09.29
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideContest) then
			require "script/guide/MatchGuide"
			MatchGuide.changLayer()
		end
		---------------------end-------------------------------------
		--]==]
		local canEnter = DataCache.getSwitchNodeState( ksSwitchContest )
		if( canEnter ) then
			require "script/ui/match/MatchLayer"
			local matchLayer = MatchLayer.createMatchLayer()
			MainScene.changeLayer(matchLayer, "matchLayer")
		end
	elseif(tag == _ksTagTreasure) then
		require "script/guide/NewGuide"
		if(ItemUtil.isBagFull() == true )then
			if(NewGuide.guideClass == ksGuideRobTreasure) then
				--	如果背包满的话，关闭夺宝新手引导
				RobTreasureGuide.cleanLayer()
				RobTreasureGuide.stepNum =0
				NewGuide.guideClass = ksGuideClose
				BTUtil:setGuideState(false)
			end
			return
		end
		-- 判断武将满了
		require "script/ui/hero/HeroPublicUI"
	    if HeroPublicUI.showHeroIsLimitedUI() then
			if(NewGuide.guideClass == ksGuideRobTreasure) then
				--	如果武将满的话，关闭夺宝新手引导
				RobTreasureGuide.cleanLayer()
				RobTreasureGuide.stepNum =0
				NewGuide.guideClass = ksGuideClose
				BTUtil:setGuideState(false)
			end
	    	return
	    end
		if(DataCache.getSwitchNodeState( ksSwitchRobTreasure ) ~= true) then
			return
		end
		require "script/ui/treasure/TreasureMainView"
		local treasureLayer = TreasureMainView.create()
		MainScene.changeLayer(treasureLayer,"treasureLayer")

		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideRobTreasure) then
			RobTreasureGuide.changLayer()
		end
	elseif (tag == _ksTagshilianta) then
		print (GetLocalizeStringBy("key_1704"))
		if(ItemUtil.isBagFull() == true )then
			return
		end
		local canEnter = DataCache.getSwitchNodeState( ksSwitchTower )
		if( canEnter ) then
			require "script/ui/tower/TowerMainLayer"
			local towerMainLayer = TowerMainLayer.createLayer()
			MainScene.changeLayer(towerMainLayer, "towerMainLayer")
		end
	elseif (tag == _ksTagshijieboss) then
		print (GetLocalizeStringBy("key_10201"))
		local canEnter = DataCache.getSwitchNodeState( ksSwitchWorldBoss )
		if( canEnter ) then
			--世界boss
			require "script/ui/boss/BossMainLayer"
			local bossLayer = BossMainLayer.createBoss()
			MainScene.changeLayer(bossLayer, "bossLayer")
		end
	elseif(tag == _ksTagxunlong) then
		---[==[寻龙 新手引导屏蔽层
		---------------------新手引导---------------------------------
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideFindDragon) then
			require "script/ui/forge/FindTreasureResetDialog"
	        XunLongGuide.changLayer()
		end
		---------------------end-------------------------------------
		--]==]
  		--寻龙探宝入口
  		if not DataCache.getSwitchNodeState(ksFindDragon) then
			return
		end
        require "script/ui/forge/FindTreasureLayer"
        FindTreasureLayer.show()
  	elseif(tag == _ksTagOlympic) then
  		if not DataCache.getSwitchNodeState(ksOlympic) then
			return
		end
		if(NewGuide.guideClass == ksGuideOlympic) then
			require "script/guide/RobTreasureGuide"
			OlympicGuild.closeGuide()
		end
  		require "script/ui/olympic/OlympicPrepareLayer"
        OlympicPrepareLayer.enter()
    elseif(tag == _ksTagGodWeaponCopy) then
    	-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchGodWeapon) then
			return
		end
		-- 背包满了
		if(ItemUtil.isBagFull() == true )then
			return
		end
    	-- 神兵副本
  		require "script/ui/godweapon/godweaponcopy/GodWeaponCopyMainLayer"
		local pLayer = GodWeaponCopyMainLayer.createLayer()
		MainScene.setMainSceneViewsVisible(false,false,false)
		MainScene.changeLayer(pLayer,"GodWeaponCopyMainLayer")
	elseif(tag == _ksTagShuiYue) then
    	-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchMoon) then
			return
		end
    	-- 水月之境
  		require "script/ui/moon/MoonLayer"
    	MoonLayer.show()
    elseif(tag == _ksTagLianYu) then
    	-- 炼狱挑战
    	-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchHellCopy) then
			return
		end
		require "script/ui/purgatorychallenge/PurgatoryMainLayer"
		PurgatoryMainLayer.showLayer()
  	elseif(tag == _ksTagHorse) then
  		-- 木牛流马
  		require "script/ui/horse/HorseLayer"
		HorseLayer.showLayer()
	elseif (tag == _ksTagDevilTower) then
		-- 试炼梦魇  
		require "script/ui/deviltower/DevilTowerLayer"
		DevilTowerLayer.showLayer()  
	end
end


-- 创建活动入口层
function initActiveListLayer()
	-- 列表layer大小
	layerSize = m_activeList:getContentSize()

	require "script/model/user/UserModel"

	-- 上标题栏 显示战斗力，银币，金币
	local topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    topBg:setAnchorPoint(ccp(0,1))
    topBg:setPosition(0,layerSize.height)
    topBg:setScale(g_fScaleX/MainScene.elementScale)
    m_activeList:addChild(topBg)
    titleSize = topBg:getContentSize()

    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBg:getContentSize().width*0.13,topBg:getContentSize().height*0.43)
    topBg:addChild(powerDescLabel)

    m_powerLabel = CCRenderLabel:create( tonumber(UserModel.getFightForceValue()), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    m_powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    m_powerLabel:setAnchorPoint(ccp(0,0.5))
    m_powerLabel:setPosition(topBg:getContentSize().width*0.23,topBg:getContentSize().height*0.47)
    topBg:addChild(m_powerLabel)

    m_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    m_silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    m_silverLabel:setAnchorPoint(ccp(0,0.5))
    m_silverLabel:setPosition(topBg:getContentSize().width*0.61,topBg:getContentSize().height*0.43)
    topBg:addChild(m_silverLabel)

    m_goldLabel = CCLabelTTF:create( UserModel.getGoldNumber(),g_sFontName,18)
    m_goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    m_goldLabel:setAnchorPoint(ccp(0,0.5))
    m_goldLabel:setPosition(topBg:getContentSize().width*0.82,topBg:getContentSize().height*0.43)
    topBg:addChild(m_goldLabel)

    -- 创建置顶图标
    _topMenuData = ActiveListData.getShowMenuData()
    if( table.count(_topMenuData) > 0)then
    	createTopMenu()
    end

    -- 创建滑动列表
    createScrollViewLayer()

    -- 上边箭头
    local posY = nil
    if( table.count(_topMenuData) > 0)then
    	posY = _topMenuBg:getPositionY()-_topMenuBg:getContentSize().height*MainScene.elementScale-18*MainScene.elementScale
    else
    	posY = topBg:getPositionY()-topBg:getContentSize().height*MainScene.elementScale-18*MainScene.elementScale
    end
    local upArrow = CCSprite:create("images/formation/btn_right.png")
    upArrow:setAnchorPoint(ccp(0.5,0.5))
    upArrow:setRotation(270)
    upArrow:setPosition(ccp(m_activeList:getContentSize().width-upArrow:getContentSize().width*0.5*MainScene.elementScale-10*MainScene.elementScale,posY))
    m_activeList:addChild(upArrow,10)
    upArrow:setScale(g_fScaleX/MainScene.elementScale)

    -- 下边箭头
    local downArrow = CCSprite:create("images/formation/btn_right.png")
    downArrow:setAnchorPoint(ccp(0.5,0.5))
    downArrow:setRotation(90)
    downArrow:setPosition(ccp(m_activeList:getContentSize().width-downArrow:getContentSize().width*0.5*MainScene.elementScale-10*MainScene.elementScale,downArrow:getContentSize().height*0.5*MainScene.elementScale+10*MainScene.elementScale))
    m_activeList:addChild(downArrow,10)
    downArrow:setScale(g_fScaleX/MainScene.elementScale)

end

--[[
	@des 	: 创建置顶图标
	@param 	:
	@return :
--]]
function createTopMenuCell( p_data )
	local tCell = CCTableViewCell:create()

	local menu = BTSensitiveMenu:create()
	menu:setTouchPriority(-210)
	menu:setPosition(ccp(0,0))
	tCell:addChild(menu)
	-- 创建各个活动对应的MenuItem
	local menuItem = CCMenuItemImage:create(p_data.image_n, p_data.image_h )
	menuItem:setAnchorPoint(ccp(0.5,0.5))
	menuItem:setPosition(ccp(55,59))
	menu:addChild(menuItem,1,p_data.tag)
	-- 注册item回调
	menuItem:registerScriptTapHandler(activeItemCallFun)

	return tCell
end

--[[
	@des 	: 创建置顶图标
	@param 	:
	@return :
--]]
function createTopMenu( ... )
	_topMenuBg = CCSprite:create("images/active/activeList/top_icon/bg.png")
	_topMenuBg:setAnchorPoint(ccp(0.5,1))
	_topMenuBg:setPosition(m_activeList:getContentSize().width*0.5,m_activeList:getContentSize().height-titleSize.height*g_fScaleX)
	m_activeList:addChild(_topMenuBg)
    _topMenuBg:setScale(g_fScaleX/MainScene.elementScale)

    -- 创建tableview
	require "script/ui/everyday/EverydayCell"
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(110, 118)
		elseif fn == "cellAtIndex" then
			r = createTopMenuCell(_topMenuData[a1+1])
		elseif fn == "numberOfCells" then
			r =  #_topMenuData
		else
		end
		return r
	end)

	local tableView = LuaTableView:createWithHandler(h, CCSizeMake(570, 118))
	tableView:setBounceable(true)
	tableView:setTouchPriority(-230)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setDirection(kCCScrollViewDirectionHorizontal)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:setAnchorPoint(ccp(0.5,0.5))
	tableView:setPosition(ccp(_topMenuBg:getContentSize().width*0.5,_topMenuBg:getContentSize().height*0.5))
	_topMenuBg:addChild(tableView)

	-- 左箭头
    local _leftArrowSp = CCSprite:create( "images/common/arrow_left.png")
    _leftArrowSp:setPosition(0, _topMenuBg:getContentSize().height*0.5)
    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
    _topMenuBg:addChild(_leftArrowSp,1, 101)
    _leftArrowSp:setVisible(false)


    -- 右箭头
    local _rightArrowSp = CCSprite:create( "images/common/arrow_right.png")
    _rightArrowSp:setPosition(_topMenuBg:getContentSize().width, _topMenuBg:getContentSize().height*0.5)
    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
    _topMenuBg:addChild(_rightArrowSp,1, 102)
    _rightArrowSp:setVisible(true)

    arrowAction(_rightArrowSp)
    arrowAction(_leftArrowSp)

    local refreshArrowFun = function ( ... )
        local offset =  tableView:getViewSize().width-tableView:getContentSize().width
        -- print("offset==>",offset)
        -- print("x",tableView:getContentOffset().x)
        if(tableView:getContentOffset().x == 0) then
            _leftArrowSp:setVisible(false)
            _rightArrowSp:setVisible(true)
        elseif(tableView:getContentOffset().x == offset ) then
        	_leftArrowSp:setVisible(true)
            _rightArrowSp:setVisible(false)
        else
        	_leftArrowSp:setVisible(true)
            _rightArrowSp:setVisible(true)
        end
    end
    schedule(_topMenuBg, refreshArrowFun, 1)
end

-- 箭头的动画
function arrowAction( arrow)
    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(1))
    arrActions_2:addObject(CCFadeIn:create(1))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    arrow:runAction(action_2)
end

-- 创建滑动列表ScrollViewLayer
function createScrollViewLayer( ... )

	-- 改变世界boss、擂台赛 顺序
	local isBossFirist = ActiveListData.isBossNeedFirst()
	local isOlympicFirst = ActiveListData.isOlympicNeedFirst()
	if(isBossFirist)then 
		local showIndex = getShowIndex(_ksTagshijieboss)
		local temData = _allList[showIndex] 
		table.remove(_allList,showIndex)
		table.insert(_allList,1,temData)
	elseif(isOlympicFirst)then
		local showIndex = getShowIndex(_ksTagOlympic)
		local temData = _allList[showIndex]
		table.remove(_allList,showIndex)
		table.insert(_allList,1,temData)
	else
	end

	-- scrollView
	liebiao = CCScrollView:create()

	local contentSize = nil
	local viewSize = nil
    if( table.count(_topMenuData) > 0)then
    	contentSize = CCSizeMake(layerSize.width,layerSize.height - titleSize.height*g_fScaleX - _topMenuBg:getContentSize().height*g_fScaleX )
    	viewSize = CCSizeMake(layerSize.width,layerSize.height - titleSize.height*g_fScaleX - _topMenuBg:getContentSize().height*g_fScaleX )
    else
    	contentSize = CCSizeMake(layerSize.width,layerSize.height - titleSize.height*g_fScaleX)
    	viewSize = CCSizeMake(layerSize.width,layerSize.height - titleSize.height*g_fScaleX )
    end

	liebiao:setContentSize(contentSize)
	liebiao:setViewSize(viewSize)
    liebiao:setScale(1/MainScene.elementScale)
	-- 设置弹性属性
	-- liebiao:setBounceable(false)
	-- 设置滑动列表的优先级
	liebiao:setTouchPriority(-130)
	-- 垂直方向滑动
	liebiao:setDirection(kCCScrollViewDirectionVertical)
	liebiao:setPosition(ccp(0,0))
	m_activeList:addChild(liebiao)
	-- 创建显示内容layer Container
	local container_layer = CCLayer:create()
	container_layer:setContentSize(CCSizeMake(liebiao:getViewSize().width, ((cellInterval+cellHeight)*_allNum + cellInterval)*g_fScaleX))
	liebiao:setContainer(container_layer)
	-- 如果是点击比武cell时，列表显示最底部。 列表不用设偏移量
	require "script/guide/NewGuide"
	require "script/guide/MatchGuide"
    if(NewGuide.guideClass ==  ksGuideRobTreasure) then
    	-- 夺宝
    	-- 默认显示第key-1个(设置偏移值)
    	local showIndex = getShowIndex(_ksTagTreasure)
		liebiao:setContentOffset(ccp(0,liebiao:getViewSize().height-container_layer:getContentSize().height+((cellInterval+cellHeight)*(showIndex-1) + cellInterval)*g_fScaleX))
    elseif(NewGuide.guideClass ==  ksGuideArena)then
    	-- 竞技场
    	-- 默认显示第key-1个(设置偏移值)
    	local showIndex = getShowIndex(_ksTagjingjichang)
    	liebiao:setContentOffset(ccp(0,liebiao:getViewSize().height-container_layer:getContentSize().height+((cellInterval+cellHeight)*(showIndex-1) + cellInterval)*g_fScaleX))
    elseif(NewGuide.guideClass ==  ksGuideResource)then
    	-- 资源矿
    	-- 默认显示第key-2个(设置偏移值)
    	local showIndex = getShowIndex(_ksTagziyuankuang)
    	liebiao:setContentOffset(ccp(0,liebiao:getViewSize().height-container_layer:getContentSize().height+((cellInterval+cellHeight)*(showIndex-2) + cellInterval)*g_fScaleX))
    elseif(NewGuide.guideClass ==  ksGuideFindDragon)then
    	-- 寻龙探宝
    	-- 默认显示第key-2个(设置偏移值)
    	local showIndex = getShowIndex(_ksTagxunlong)
    	liebiao:setContentOffset(ccp(0,liebiao:getViewSize().height-container_layer:getContentSize().height+((cellInterval+cellHeight)*(showIndex-2) + cellInterval)*g_fScaleX))
    elseif(NewGuide.guideClass ==  ksGuideContest)then
    	-- 比武
    	-- 默认显示第key-3个(设置偏移值)
    	local showIndex = getShowIndex(_ksTagbiwu)
    	liebiao:setContentOffset(ccp(0,liebiao:getViewSize().height-container_layer:getContentSize().height+((cellInterval+cellHeight)*(showIndex-2) + cellInterval)*g_fScaleX))
    elseif(NewGuide.guideClass ==  ksGuideOlympic)then
    	--擂台争霸
    	if(isOlympicFirst)then
    		liebiao:setContentOffset(ccp(0,liebiao:getViewSize().height-container_layer:getContentSize().height))
    	else
    		local showIndex = getShowIndex(_ksTagOlympic)
    		liebiao:setContentOffset(ccp(0,liebiao:getViewSize().height-container_layer:getContentSize().height+((cellInterval+cellHeight)*(showIndex-2) + cellInterval)*g_fScaleX))
    	end
    else
    	local offset = MainScene.getOffsetForList()
    	if(offset and isBossFirist ~= true and isOlympicFirst ~= true)then
    		if( _lastMeunNum > 0 and  table.count(_topMenuData) == 0 )then 
    			offset.y = offset.y + 118*g_fScaleX
    		end
    		-- 读取记忆偏移量
	    	liebiao:setContentOffset(offset)
    	else
	    	-- 默认显示最上方(设置偏移值)
	    	liebiao:setContentOffset(ccp(0,liebiao:getViewSize().height-container_layer:getContentSize().height))
	    end
	end

	-- 创建活动单元格
	local posY = 0
	for i=1, _allNum do 
		local posY = container_layer:getContentSize().height-(cellHeight+cellInterval)*i*g_fScaleX
		-- 创建最上层单元格背景
		local isOpen = DataCache.getSwitchNodeState(_allList[i].switchId,false)
		local CCSpriteTemp = nil
	    if(isOpen)then
	        CCSpriteTemp = CCSprite
	    else
	        CCSpriteTemp = BTGraySprite
	    end
		local bgSprite = CCSpriteTemp:create(IMG_PATH .. "activeItem_bg.png")
		bgSprite:setAnchorPoint(ccp(0.5,0))
		bgSprite:setPosition(ccp(container_layer:getContentSize().width*0.5,posY))
		container_layer:addChild(bgSprite,3,i)
        bgSprite:setScale(g_fScaleX)
		-- print("i",i, bgSprite:getContentSize().width,bgSprite:getContentSize().height)
		-- print("Position",bgSprite:getPositionX(),bgSprite:getPositionY())

		-- 创建活动入口menu
		local activeMenu = BTSensitiveMenu:create()
		activeMenu:setPosition(ccp(0,0))
		bgSprite:addChild(activeMenu,-1)
		-- 创建各个活动对应的MenuItem
		local meunItem = createActiveMenuItem(_allList[i],isOpen)
		meunItem:setAnchorPoint(ccp(0.5,0.5))
		meunItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.5-2.5))
		activeMenu:addChild(meunItem,1,_allList[i].tag)
		-- 注册item回调
		meunItem:registerScriptTapHandler(activeItemCallFun)
		-- 新手需求
		menuItem_arr[_allList[i].tag] = bgSprite
	end

end


-- 创建列表menuItem
function createActiveMenuItem( sCellValue, p_isOpen )
	if(sCellValue ~= nil)then
		local CCSpriteTemp = nil
	    if(p_isOpen)then
	        CCSpriteTemp = CCSprite
	    else
	        CCSpriteTemp = BTGraySprite
	    end
		local normalSprite = CCSpriteTemp:create(IMG_PATH .. sCellValue.name .. "Item.png")
		local selectSprite = CCSpriteTemp:create(IMG_PATH .. sCellValue.name .. "Item.png")
		-- 创建第二层阴影边框
		local itemBox = CCSpriteTemp:create(IMG_PATH .. "activeItem_box.png")
		itemBox:setAnchorPoint(ccp(0.5,0.5))
		itemBox:setPosition(ccp(selectSprite:getContentSize().width*0.5,selectSprite:getContentSize().height*0.5))
		selectSprite:addChild(itemBox,2)
		local item = CCMenuItemSprite:create(normalSprite,selectSprite)
		-- 添加各个活动的标题
		local titleSprite = CCSpriteTemp:create(IMG_PATH .. sCellValue.name .. ".png")
		titleSprite:setAnchorPoint(ccp(0,1))
		titleSprite:setPosition(ccp(25,item:getContentSize().height-10))
		item:addChild(titleSprite,1,1)
		-- 添加各个活动描述
		local filePath = nil
		if( sCellValue.name == "shuiyue" and DataCache.getSwitchNodeState(ksSwitchTally, false) )then
			filePath = IMG_PATH .. sCellValue.name .. "_des2.png"
		elseif( sCellValue.name == "mnlm")then
			require "script/ui/horse/HorseData"
			filePath = HorseData.getTipLabelStr()
		else
			filePath = IMG_PATH .. sCellValue.name .. "_des.png"
		end
		local desSprite = CCSpriteTemp:create(filePath)
		desSprite:setAnchorPoint(ccp(0.5,0))
		desSprite:setPosition(ccp(item:getContentSize().width*0.5,10))
		item:addChild(desSprite,1,2)
		-- 世界boss描述2
		if( sCellValue.name == "shijieboss")then
			local desSprite = CCSpriteTemp:create(IMG_PATH .. sCellValue.name .. "_des2.png")
			desSprite:setAnchorPoint(ccp(0.5,0))
			desSprite:setPosition(ccp(item:getContentSize().width*0.5,40))
			item:addChild(desSprite,1,2)
		end

		if(p_isOpen == false) then
			require "db/DB_Switch"
			local switchInfo = DB_Switch.getDataById(sCellValue.switchId)
			local needLv = switchInfo.level or 1
	    	local openSprite = CCSprite:create("images/copy/acopy/lock_bg.png")
	    	openSprite:setAnchorPoint(ccp(0.5,0.5))
	    	openSprite:setPosition(ccp(item:getContentSize().width*0.5 , item:getContentSize().height*0.5))
	    	item:addChild(openSprite)
	    	local lockSprite = CCSprite:create("images/copy/acopy/lock.png")
	    	lockSprite:setAnchorPoint(ccp(0.5,0.5))
	    	lockSprite:setPosition(ccp(openSprite:getContentSize().width*0.1, openSprite:getContentSize().height*0.5))
	    	openSprite:addChild(lockSprite)
	    	local openLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1823",needLv), g_sFontPangWa, 32)
			openLabel:setColor(ccc3(0xff, 0xf6, 0x00))
			openLabel:setAnchorPoint(ccp(0.5, 0.5))
			openLabel:setPosition(ccp(openSprite:getContentSize().width*0.6, openSprite:getContentSize().height*0.5))
			openSprite:addChild(openLabel,10)
	    end

		-- 返回item
		return item
	end
end

-- 创建活动列层
function createActiveListLayer()

	init()

	-- 准备数据
	local noOpneTem = {}
	for i=1,#_normalList do 
		local isOpen = DataCache.getSwitchNodeState( _normalList[i].switchId,false )
		if(isOpen)then
			table.insert(_allList,_normalList[i])
		else
			table.insert(noOpneTem,_normalList[i])
		end
	end
	local noSOpneTem = {}
	for i=1,#_specialList do  
		local isOpen = DataCache.getSwitchNodeState( _specialList[i].switchId,false )
		if(isOpen)then
			table.insert(_allList,_specialList[i])
		else
			table.insert(noSOpneTem,_specialList[i])
		end
	end

	for i=1,#noOpneTem do
		table.insert(_allList,noOpneTem[i])
	end
	for i=1,#noSOpneTem do
		table.insert(_allList,noSOpneTem[i])
	end

	_allNum = table.count(_allList)


    m_activeList = MainScene.createBaseLayer(IMG_PATH .. "activeList_bg.jpg",true,false,false)
    m_activeList:registerScriptHandler(onNodeEvent)

	function nextCallBack( p_data )
		if(p_data.err ~= "ok")then
			return
		end

		ActiveListData.setListInfo(p_data.ret)

		-- 初始化top按钮数据
		ActiveListData.initTopMenuTab()

		-- 初始化
		MainScene.setMainSceneViewsVisible(true,false,false)

    	initActiveListLayer()

	    --添加擂台赛红圈提示
	    addRebTip()

	    -- 爬塔添加提示重置次数
		-- addTipSprite( _ksTagshilianta )

	    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
	    		-- 竞技场
				addGuideArenaGuide2()
				-- 资源矿
				addGuideMineralGuide2()
				-- 比武
				addGuideMatchGuide2()
				--夺宝
				addGuideRobTreasure()
				-- 寻龙探宝
				addGuideXunLongGuide2()
				-- 擂台争霸
				addGuideOlympic()
			end))
		m_activeList:runAction(seq)

	end
	ActiveListService.getTopActivityInfo( nextCallBack )

    return m_activeList
end

-- 添加提示
function addTipSprite( index )
	local item = getMenuItemNode(tonumber(index))
	local itemNode = tolua.cast(item,"CCMenuItemSprite")
	if( itemNode:getChildByTag(100) ~= nil )then
		itemNode:getChildByTag(100):removeFromParentAndCleanup(true)
	end
	require "script/utils/ItemDropUtil"
	if(tonumber(index) == _ksTagshilianta )then
		-- 试练塔
		require "script/ui/tower/TowerCache"
		local num = TowerCache.getResetTowerTimes()
		local tipSprite = ItemDropUtil.getTipSpriteByNum(num)
		tipSprite:setPosition(itemNode:getContentSize().width*0.95, itemNode:getContentSize().height*0.9)
		tipSprite:setAnchorPoint(ccp(1,1))
		itemNode:addChild(tipSprite,1,100)
		if(num<=0)then
			tipSprite:setVisible(false)
		end
	end
end

-- 新手引导
-- num:第几个itme 自上而下从1开始
function getMenuItemNode( num )
	return menuItem_arr[num]
end


--[[
	@des ： 添加红圈提示
--]]
function addRebTip( ... )

	--添加擂台赛红圈提示
	local olympicItem = getMenuItemNode(ActiveList._ksTagOlympic)
	local tipSprite   = CCSprite:create("images/common/tip_1.png")
	tipSprite:setAnchorPoint(ccp(0.5, 0.5))
	tipSprite:setPosition(ccpsprite(0.92, 0.8, olympicItem))
	olympicItem:addChild(tipSprite)
	-- 添加擂台赛开启时间描述
	require "script/ui/olympic/OlympicData"

	local durTime = OlympicData.getOlympicOpenTime() + 1800 - BTUtil:getSvrTimeInterval()
	if(OlympicData.getOlympicOpenTime() > BTUtil:getSvrTimeInterval() or (OlympicData.getOlympicOpenTime() + 1800) < BTUtil:getSvrTimeInterval()) then
		tipSprite:setVisible(false)
	else
		local actionArray = CCArray:create()
		actionArray:addObject(CCDelayTime:create(durTime))
		actionArray:addObject(CCCallFunc:create(function ( ... )
			tipSprite:setVisible(false)
		end))
		local seq =  CCSequence:create(actionArray)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		tipSprite:runAction(seq)
	end

	local openTimeLabel = CCRenderLabel:create(OlympicData.getStartTimeDes(), g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	openTimeLabel:setAnchorPoint(ccp(0.5,0.5))
	openTimeLabel:setPosition(303, 82)
	openTimeLabel:setColor(ccc3(237, 184, 0))
	olympicItem:addChild(openTimeLabel)

end

---[==[竞技场 第2步∏
---------------------新手引导---------------------------------
function addGuideArenaGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/ArenaGuide"
    if(NewGuide.guideClass == ksGuideArena and ArenaGuide.stepNum == 1) then
        local arenaButton = getMenuItemNode(ActiveList._ksTagjingjichang)
        local touchRect   = getSpriteScreenRect(arenaButton)
        ArenaGuide.show(2, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


---[==[资源矿 第2步
---------------------新手引导---------------------------------
function addGuideMineralGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/MineralGuide"
    if(NewGuide.guideClass ==  ksGuideResource and MineralGuide.stepNum == 1) then
        local mineralButton = getMenuItemNode(ActiveList._ksTagziyuankuang)
        local touchRect   = getSpriteScreenRect(mineralButton)
        MineralGuide.show(2, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


---[==[比武 第2步
---------------------新手引导---------------------------------
function addGuideMatchGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/MatchGuide"
    if(NewGuide.guideClass ==  ksGuideContest and MatchGuide.stepNum == 1) then
        local matchGuidButton = getMenuItemNode(ActiveList._ksTagbiwu)
        local touchRect   = getSpriteScreenRect(matchGuidButton)
        MatchGuide.show(2, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[寻龙 第2步
---------------------新手引导---------------------------------
function addGuideXunLongGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/XunLongGuide"
    if(NewGuide.guideClass ==  ksGuideFindDragon and XunLongGuide.stepNum == 1) then
        local button = getMenuItemNode(ActiveList._ksTagxunlong)
        local touchRect   = getSpriteScreenRect(button)
        XunLongGuide.show(2, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


--[[
	@des:	夺宝系统
]]
function addGuideRobTreasure( ... )
	require "script/guide/RobTreasureGuide"
    if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 0) then
       	require "script/ui/active/ActiveList"
        local robTreasure = ActiveList.getMenuItemNode(ActiveList._ksTagTreasure)
        local touchRect   = getSpriteScreenRect(robTreasure)
        RobTreasureGuide.show(1, touchRect)
    end
    if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 11) then
       	require "script/ui/active/ActiveList"
       	RobTreasureGuide.changLayer()
        local robTreasure = ActiveList.getMenuItemNode(ActiveList._ksTagTreasure)
        local touchRect   = getSpriteScreenRect(robTreasure)
        RobTreasureGuide.show(12, touchRect)
    end
end

--[[
	@des :	擂台争霸
--]]
function addGuideOlympic( ... )

	require "script/guide/OlympicGuild"
    if(NewGuide.guideClass ==  ksGuideOlympic and OlympicGuild.stepNum == 0) then
       	require "script/ui/active/ActiveList"
        local olympicBtn = ActiveList.getMenuItemNode(ActiveList._ksTagOlympic)
        local touchRect   = getSpriteScreenRect(olympicBtn)
        OlympicGuild.show(1, touchRect)
    end

end


-- 刷新活动列表界面金币
refreshActiveListGold = function ( ... )
	if(m_goldLabel)then
		m_goldLabel:setString( UserModel.getGoldNumber() )
	end
end


function closeNewGuide( ... )
	require "script/guide/ArenaGuide"
    require "script/guide/MineralGuide"
    require "script/guide/MatchGuide"
    require "script/guide/RobTreasureGuide"

    if(NewGuide.guideClass == ksGuideArena) then
		require "script/guide/ArenaGuide"
		ArenaGuide.closeGuide()
	end

    if(NewGuide.guideClass == ksGuideResource) then
		require "script/guide/MineralGuide"
		MineralGuide.closeGuide()
	end
	if(NewGuide.guideClass == ksGuideContest) then
		require "script/guide/MatchGuide"
		MatchGuide.closeGuide()
	end
	if(NewGuide.guideClass == ksGuideRobTreasure) then
		require "script/guide/RobTreasureGuide"
		RobTreasureGuide.closeGuide()
	end
	if(NewGuide.guideClass == ksGuideOlympic) then
		require "script/guide/RobTreasureGuide"
		OlympicGuild.closeGuide()
	end
end



--[[
	@des 	: 得到活动显示位置
	@param 	:
	@return :
--]]
function getShowIndex( p_tag )
	local retIndex = 1
	for i=1,#_allList do 
		if( p_tag == _allList[i].tag )then
			retIndex = i
			break
		end
	end
	return retIndex
end

