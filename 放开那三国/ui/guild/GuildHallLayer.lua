

-- Filename：	GuildHallLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-12-21
-- Purpose：		军团大厅

module("GuildHallLayer", package.seeall)


local Tag_Normal_Build 	= 10001
local Tag_Middle_Build 	= 10002
local Tag_New_Build 	= 10003
local Tag_High_Build 	= 10004
local Tag_Super_Build	= 10005


local _bgLayer 		= nil
local _topBgSprite 	= nil
local _bgSprite 	= nil

local _curDonateInfo = nil
local _curDonateType = nil

local _listTableView = nil               -- 贡献信息列表
local _listBg        = nil 				 -- 贡献信息列表背景	

local powerLabel      = nil              -- 个人总贡献lable
local silverLabel 	  = nil              -- 银币lable
local goldLabel		  = nil				 -- 金币lable
local levelDataLabel  = nil 			 -- 军团等级lable
local numDataLabel    = nil  			 -- 总建设度lable
local needDataLabel   = nil  			 -- 升到下级所需的建设度lable	
local hallSprite      = nil  			 -- 大厅背景	
local refreshGold 	  = nil 			 -- 充值后刷新界面金币注册函数
local buildingSprite_1 =  nil            -- 第一种捐献背景
local buildingSprite_2 =  nil 			 -- 第二种捐献背景
local buildingSprite_3 =  nil            -- 第三种捐献背景

-- added by zhz
local _updateTimer =nil 				 -- 定时器

function init()
	_bgLayer 		= nil
	_topBgSprite 	= nil
	_bgSprite 		= nil
	_curDonateInfo 	= nil
	_curDonateType 	= nil
	_listTableView  = nil 
	_listBg        	= nil 	
	powerLabel      = nil             
	silverLabel 	= nil             
	goldLabel		= nil	
	levelDataLabel  = nil
	numDataLabel    = nil 
	hallSprite      = nil 
	refreshGold 	= nil
	buildingSprite_1 =  nil 
	buildingSprite_2 =  nil 
	buildingSprite_3 =  nil  
	_updateTimer	 = nil

end

--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		GuildDataCache.setIsInGuildFunc(true)
		require "script/ui/shop/RechargeLayer"
		RechargeLayer.registerChargeGoldCb(refreshGold)
	elseif (event == "exit") then
		init()
		GuildDataCache.setIsInGuildFunc(false)
		require "script/ui/shop/RechargeLayer"
		RechargeLayer.registerChargeGoldCb(nil)
	end
end

-- 创建头部
function createTopUI()

	local bgLayerSize = _bgLayer:getContentSize()
	_topBgSprite = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBgSprite:setAnchorPoint(ccp(0,1))
    _topBgSprite:setPosition(0, bgLayerSize.height)
    local myScale = _bgLayer:getContentSize().width/_topBgSprite:getContentSize().width/_bgLayer:getElementScale()
    _topBgSprite:setScale(myScale)
    _bgLayer:addChild(_topBgSprite)

    --添加战斗力文字图片
    local powerDescLabel = CCSprite:create("images/guild/guangong/alltribute.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBgSprite:getContentSize().width*0.15, _topBgSprite:getContentSize().height*0.43)
    _topBgSprite:addChild(powerDescLabel)

    --读取用户信息
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
    
    --总贡献
    powerLabel = CCRenderLabel:create(GuildDataCache.getSigleDoante(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    powerLabel:setColor(ccc3(0xff, 0xff, 0xff))
    --m_powerLabel:setAnchorPoint(ccp(0,0.5))
    powerLabel:setPosition(_topBgSprite:getContentSize().width*0.27, _topBgSprite:getContentSize().height*0.66)
    _topBgSprite:addChild(powerLabel)
    
    --银币
	silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    silverLabel:setAnchorPoint(ccp(0,0.5))
    silverLabel:setPosition(_topBgSprite:getContentSize().width*0.61,_topBgSprite:getContentSize().height*0.43)
    _topBgSprite:addChild(silverLabel)
    
    --金币
    goldLabel = CCLabelTTF:create(tostring(userInfo.gold_num),g_sFontName,18)
    goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    goldLabel:setAnchorPoint(ccp(0,0.5))
    goldLabel:setPosition(_topBgSprite:getContentSize().width*0.82,_topBgSprite:getContentSize().height*0.43)
    _topBgSprite:addChild(goldLabel)
end


-- 创建底部
function createBottom()
	local _bottomSpite = GuildBottomSprite.createBottomSprite(false)
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local myScale = _bgLayer:getContentSize().width/_bottomSpite:getContentSize().width/_bgLayer:getElementScale()
	_bottomSpite:setScale(myScale)
	_bottomSpite:setAnchorPoint(ccp(0, 0))
	_bottomSpite:setPosition(ccp(0, -menuLayerSize.height*g_fScaleX))
	_bgLayer:addChild(_bottomSpite)
	
end

-- 创建中间的主UI
function createMainUI()
	local bgSpriteSize = _bgSprite:getContentSize()

	-- 大厅PNG
	hallSprite = CCSprite:create("images/guild/hall.png")
	hallSprite:setAnchorPoint(ccp(0.5, 0.5))
	hallSprite:setPosition(ccp(bgSpriteSize.width*0.25, bgSpriteSize.height*0.7))
	hallSprite:setScale(MainScene.elementScale)
	_bgSprite:addChild(hallSprite)


-- 大厅描述
	local levelLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2936"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xff, 0xff))
    levelLabel:setAnchorPoint(ccp(0, 0))
    levelLabel:setPosition(ccp(10, 60))
    hallSprite:addChild(levelLabel)


	levelDataLabel = CCRenderLabel:create(GuildDataCache.getGuildInfo().guild_level, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelDataLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    levelDataLabel:setAnchorPoint(ccp(0, 0))
    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    levelDataLabel:setPosition(ccp(120, 60))
else
    levelDataLabel:setPosition(ccp(100, 60))
end
    hallSprite:addChild(levelDataLabel)

	local numLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1152"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    numLabel:setColor(ccc3(0xff, 0xff, 0xff))
    numLabel:setAnchorPoint(ccp(0, 0))
    numLabel:setPosition(ccp(10, 35))
    hallSprite:addChild(numLabel)

    local number = GuildDataCache.getGuildInfo().curr_exp

	numDataLabel = CCRenderLabel:create(number, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    numDataLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    numDataLabel:setAnchorPoint(ccp(0, 0))
    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    numDataLabel:setPosition(ccp(200, 35))
else
    numDataLabel:setPosition(ccp(100, 35))
end
    hallSprite:addChild(numDataLabel)

    local needLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2550"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    needLabel:setColor(ccc3(0xff, 0xff, 0xff))
    needLabel:setAnchorPoint(ccp(0, 0))
    needLabel:setPosition(ccp(10, 10))
    hallSprite:addChild(needLabel)
    local curLv = tonumber(GuildDataCache.getGuildInfo().guild_level)
    local needNumber = 0
    if(curLv >= GuildUtil.getMaxGuildLevel())then
    	needNumber = "--"
    else
    	needNumber = GuildUtil.getNeedExpByLv( curLv+1 )
    end
	needDataLabel = CCRenderLabel:create(needNumber, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    needDataLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    needDataLabel:setAnchorPoint(ccp(0, 0))
    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    needDataLabel:setPosition(ccp(170, 10))
else
    needDataLabel:setPosition(ccp(100, 10))
end
    hallSprite:addChild(needDataLabel)


-- 贡献列表
	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
	_listBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
	_listBg:setAnchorPoint(ccp(0.5,0.5))
	_listBg:setPreferredSize(CCSizeMake(330, 320))
	_listBg:setPosition(ccp(bgSpriteSize.width*0.75 - 20, bgSpriteSize.height*0.7))
	_bgSprite:addChild(_listBg)
	_listBg:setScale(MainScene.elementScale)
	-- 贡献信息列表
	createContributeTableView()

	-- aded by zhz
	createBuildSrcowView()
-- ------ 普通建设
-- 	buildingSprite_1 = createBuildingBgSprite( Tag_Normal_Build )
-- 	buildingSprite_1:setAnchorPoint(ccp(0.5, 0.5))
-- 	buildingSprite_1:setPosition(ccp(bgSpriteSize.width*0.18, bgSpriteSize.height * 0.25))
-- 	_bgSprite:addChild(buildingSprite_1)
-- 	buildingSprite_1:setScale(MainScene.elementScale)
	

-- ------ 中级建设
-- 	buildingSprite_2 = createBuildingBgSprite( Tag_Middle_Build )
-- 	buildingSprite_2:setAnchorPoint(ccp(0.5, 0.5))
-- 	buildingSprite_2:setPosition(ccp(bgSpriteSize.width*0.5, bgSpriteSize.height * 0.25))
-- 	_bgSprite:addChild(buildingSprite_2)
-- 	buildingSprite_2:setScale(MainScene.elementScale)

-- ------ 高级建设
-- 	buildingSprite_3 = createBuildingBgSprite( Tag_High_Build )
-- 	buildingSprite_3:setAnchorPoint(ccp(0.5, 0.5))
-- 	buildingSprite_3:setPosition(ccp(bgSpriteSize.width*0.82, bgSpriteSize.height * 0.25))
-- 	_bgSprite:addChild(buildingSprite_3)
-- 	buildingSprite_3:setScale(MainScene.elementScale)

end

-- 创建SrcowView 的背景 ,added by zhz
function createBuildSrcowView( )


	local height = _bgSprite:getContentSize().height
	_contentScrollView = CCScrollView:create()
	_contentScrollView:setViewSize(CCSizeMake( (_bgSprite:getContentSize().width-16)/MainScene.elementScale ,height))
	_contentScrollView:setDirection(kCCScrollViewDirectionHorizontal)
	_contentScrollView:setScale(MainScene.elementScale)
	local scrollLayer = CCLayer:create()
	_contentScrollView:setContainer(scrollLayer)

	_rewardTagTable = {Tag_Normal_Build , Tag_Middle_Build , Tag_New_Build, Tag_High_Build,Tag_Super_Build}
	_buildSpriteTab= {}
	-- scrollLayer:setContentSize(CCSizeMake(_bgSprite:getContentSize().width,335))
	scrollLayer:setPosition(ccp(0,0))

	local scrWidth=_bgSprite:getContentSize().width*0.322*(#_rewardTagTable)/MainScene.elementScale
	print("scrWidth ",scrWidth , " MainScene.elementScale is ", MainScene.elementScale)

	for i=1, #_rewardTagTable do

		print("_rewardTagTable[i]  is  ", _rewardTagTable[i])
		local buildSprite = createBuildingBgSprite( _rewardTagTable[i])
		buildSprite:setAnchorPoint(ccp(0, 0))
		buildSprite:setPosition(ccp(_bgSprite:getContentSize().width*(i-1)*0.32/MainScene.elementScale, _bgSprite:getContentSize().height*0.24/MainScene.elementScale - buildSprite:getContentSize().height/2 ))--_bgSprite:getContentSize().width.height * 0.25))
		_contentScrollView:addChild(buildSprite,1,100+i )
		_contentScrollView:setScale(MainScene.elementScale  )
		table.insert(_buildSpriteTab, buildSprite )
		--scrWidth= scrWidth+ buildSprite:getContentSize().width*MainScene.elementScale
	end

	scrollLayer:setContentSize(CCSizeMake(scrWidth,height))
	_contentScrollView:setContentSize(CCSizeMake(scrWidth,height))

	_contentScrollView:setPosition(8,0)

	_bgSprite:addChild(_contentScrollView)

	_leftArrowSp = CCSprite:create( "images/common/arrow_left.png")
	_leftArrowSp:setPosition( 3, _bgSprite:getContentSize().height * 0.25)
	_leftArrowSp:setAnchorPoint(ccp(0,0.5))
	_leftArrowSp:setScale(MainScene.elementScale)
	_bgSprite:addChild(_leftArrowSp,1, 101)
	_leftArrowSp:setVisible(false)


	-- 向下的箭头
	_rightArrowSp = CCSprite:create( "images/common/arrow_right.png")
	_rightArrowSp:setPosition(_bgSprite:getContentSize().width-3 ,_bgSprite:getContentSize().height * 0.25)
	_rightArrowSp:setAnchorPoint(ccp(1,0.5))
	_rightArrowSp:setScale(MainScene.elementScale )
	_bgSprite:addChild(_rightArrowSp,1, 102)
	_rightArrowSp:setVisible(true)

	arrowAction(_leftArrowSp)
	arrowAction(_rightArrowSp)
	_updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateShieldTime, 1, false)

	print("_contentScrollView  offset is ",  _contentScrollView:getContentOffset().x)

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



-- 创建贡献显示列表
function createContributeTableView( ... )
	-- require "script/model/utils/HeroUtil"
	-- -- 显示单元格背景的size
	-- local cell_bg_size = { width = 334, height = 34 } 
	-- -- 得到列表数据
	-- -- print(GetLocalizeStringBy("key_2241"))
	-- -- print_t(GuildDataCache._recordList)

	-- --创建不同高度的cell
	-- --本来想用a1，结果用a1为nil，代表这时候不能用，所有才用此下策
	-- --added by Zhang Zihang

	-- local a1_tag = 0
	-- local handler = LuaEventHandler:create(function(fn, table, a1, a2)
	-- 	local r
	-- 	if (fn == "cellSize") then
	-- 		a1_tag = a1_tag + 1

	-- 		-- 显示单元格的间距
	-- 		local interval = 5
	-- 		local realHeight = cell_bg_size.height + interval
	-- 		--如果是合服后的名字
	-- 		if GuildDataCache._recordList[a1_tag] ~= nil and HeroUtil.isMergeName(GuildDataCache._recordList[a1_tag].uname) then
	-- 			realHeight = 2*cell_bg_size.height + interval
	-- 		end
	-- 		r = CCSizeMake(cell_bg_size.width, realHeight)
	-- 	elseif (fn == "cellAtIndex") then
	-- 		r = createContributeInfoCell(GuildDataCache._recordList[a1+1],isHaveGuild)
	-- 		-- r:setScale(g_fScaleX/MainScene.elementScale)
	-- 	elseif (fn == "numberOfCells") then
	-- 		r = #GuildDataCache._recordList
	-- 	elseif (fn == "cellTouched") then
	-- 	elseif (fn == "scroll") then
	-- 		-- print ("scroll, index is: ")
	-- 	else
	-- 		-- print (fn, " event is not handled.")
	-- 	end
	-- 	return r
	-- end)

	-- _listTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_listBg:getContentSize().width,_listBg:getContentSize().height))
	-- _listTableView:setBounceable(true)
	-- _listTableView:setAnchorPoint(ccp(0, 0))
	-- _listTableView:setPosition(ccp(0,0))
	-- _listBg:addChild(_listTableView)
	-- -- 设置单元格升序排列
	-- _listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- -- 设置滑动列表的优先级
	-- _listTableView:setTouchPriority(-130)

	--当前tableView不支持不同高度的cell，所以用scrollview创了
	--added by Zhang Zihang

	_listTableView = CCScrollView:create()
	_listTableView:setViewSize(CCSizeMake(_listBg:getContentSize().width,_listBg:getContentSize().height))
	_listTableView:setDirection(kCCScrollViewDirectionVertical)
	_listTableView:setTouchPriority(-130)

	local layer = CCLayer:create()
	_listTableView:setContainer(layer)

	local underY = 0

	for i = #GuildDataCache._recordList,1,-1 do
		local record_data = GuildDataCache._recordList[i].record_data or " "
		local contriDataLabel = CCRenderLabel:create(record_data, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		contriDataLabel:setColor(ccc3(0x36, 0xff, 0x00))
		contriDataLabel:setAnchorPoint(ccp(0, 0))
		layer:addChild(contriDataLabel)

		local contrisLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1592"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    contrisLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    contrisLabel:setAnchorPoint(ccp(0, 0))
	    layer:addChild(contrisLabel)

	    local name = GuildDataCache._recordList[i].uname or " "
		local nameLabel = CCRenderLabel:create(name, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    nameLabel:setAnchorPoint(ccp(0, 0))
	    layer:addChild(nameLabel)

	    local contriLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1142"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    contriLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    contriLabel:setAnchorPoint(ccp(0, 0))
	    layer:addChild(contriLabel)

		--如果是合服后的名字
		if HeroUtil.isMergeName(GuildDataCache._recordList[i].uname) then    
		    contrisLabel:setPosition(ccp(10, underY))
		    underY = underY + 34
			nameLabel:setPosition(ccp(10,underY))
			contriLabel:setPosition(ccp(nameLabel:getPositionX()+nameLabel:getContentSize().width+5, underY))
			contriDataLabel:setPosition(ccp(contriLabel:getPositionX()+contriLabel:getContentSize().width+5,underY))
			underY = underY + 34
		else
			nameLabel:setPosition(ccp(10,underY))
			contriLabel:setPosition(ccp(nameLabel:getPositionX()+nameLabel:getContentSize().width+5, underY))
			contriDataLabel:setPosition(ccp(contriLabel:getPositionX()+contriLabel:getContentSize().width+5, underY))
			contrisLabel:setPosition(ccp(contriDataLabel:getPositionX()+contriDataLabel:getContentSize().width+5, underY))
			underY = underY + 34
		end
	end

	layer:setContentSize(CCSizeMake(_listBg:getContentSize().width,underY))
	layer:setPosition(ccp(0,_listBg:getContentSize().height-underY))

	_listTableView:setPosition(ccp(0,0))

	_listBg:addChild(_listTableView)
end

-- 创建贡献信息列表cell
-- function createContributeInfoCell( tCellValue )
-- 	-- 创建cell
--  	local cell = CCTableViewCell:create()

--  	-- 玩家名字
--  	local name = tCellValue.uname or " "
-- 	local nameLabel = CCRenderLabel:create(name, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
--     nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
--     nameLabel:setAnchorPoint(ccp(0, 0))
--     nameLabel:setPosition(ccp(10, 0))
--     cell:addChild(nameLabel)

-- 	local contriLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1142"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
--     contriLabel:setColor(ccc3(0xff, 0xff, 0xff))
--     contriLabel:setAnchorPoint(ccp(0, 0))
--     contriLabel:setPosition(ccp(nameLabel:getPositionX()+nameLabel:getContentSize().width+5, 0))
--     cell:addChild(contriLabel)

--     -- 建设度值
-- 	local record_data = tCellValue.record_data or " "
-- 	local contriDataLabel = CCRenderLabel:create(record_data, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
--     contriDataLabel:setColor(ccc3(0x36, 0xff, 0x00))
--     contriDataLabel:setAnchorPoint(ccp(0, 0))
--     contriDataLabel:setPosition(ccp(contriLabel:getPositionX()+contriLabel:getContentSize().width+5, 0))
--     cell:addChild(contriDataLabel)

--     local contrisLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1592"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
--     contrisLabel:setColor(ccc3(0xff, 0xff, 0xff))
--     contrisLabel:setAnchorPoint(ccp(0, 0))
--     contrisLabel:setPosition(ccp(contriDataLabel:getPositionX()+contriDataLabel:getContentSize().width+5, 0))
--     cell:addChild(contrisLabel)

--  	return cell
-- end

-- 解析活动倍数
function parseData( openData, d_type )
	local sigleRate = 1
	local guildRate = 1
	local str1_arr = string.split(openData, ",")
	for k,v in pairs(str1_arr) do
		local str2_arr = string.split(v, "|")
		if(tonumber(str2_arr[1]) == d_type - 10000 )then
			-- 初级建设
			guildRate = tonumber(str2_arr[2])/10000
			sigleRate = tonumber(str2_arr[3])/10000
			break
		end
	end

	return sigleRate, guildRate
end

-- 创建建设的通用sprite
function createBuildingBgSprite( type_tag )

	local sigleRate = 1
	local guildRate = 1

	require "script/ui/rechargeActive/BenefitActiveLayer"
	local isOpen, openData = BenefitActiveLayer.isConstructionOpen()
	if(isOpen == true)then
		sigleRate, guildRate = parseData(openData, type_tag)
	end

	local t_title = nil
	local png_file = nil
	if(type_tag == Tag_Normal_Build)then
		t_title = GetLocalizeStringBy("key_2855")
		png_file = "images/common/more_silver.png"
	elseif(type_tag == Tag_Middle_Build)then
		t_title = GetLocalizeStringBy("key_2337")
		png_file = "images/common/little_gold.png"
	elseif(type_tag == Tag_New_Build) then
		t_title = GetLocalizeStringBy("key_2620")
		png_file = "images/common/little_gold.png"
	elseif(type_tag == Tag_High_Build)then
		t_title = GetLocalizeStringBy("key_4030")
		png_file = "images/common/more_gold.png"
	elseif(type_tag== Tag_Super_Build ) then
		t_title = GetLocalizeStringBy("zzh_1207")
		png_file = "images/common/much_gold.png"
	end

	-- 普通建设
	local buildingSprite_1 = CCScale9Sprite:create("images/common/bg/9s_1.png")
	buildingSprite_1:setContentSize(CCSizeMake(205, 335))
	
	-- 标题
	local titleSprite = CCScale9Sprite:create("images/common/astro_labelbg.png")
	titleSprite:setContentSize(CCSizeMake(165, 35))
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(buildingSprite_1:getContentSize().width*0.5, buildingSprite_1:getContentSize().height))
	buildingSprite_1:addChild(titleSprite)
	-- 标题文字
	local titleLabel = CCRenderLabel:create(t_title, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width*0.5 - titleLabel:getContentSize().width*0.5, titleSprite:getContentSize().height*0.5 + titleLabel:getContentSize().height*0.5))
    titleSprite:addChild(titleLabel)

    -- 银币sprite
	local silverSprite = CCSprite:create(png_file)
	silverSprite:setAnchorPoint(ccp(0.5, 0.5))
	silverSprite:setPosition(ccp(97, 250))
	buildingSprite_1:addChild(silverSprite)

	local donate_1_arr = GuildUtil.getDonateInfoBy(type_tag - 10000)

	if(type_tag == Tag_Normal_Build)then
		-- 文字提示
		local n_label_1 = CCRenderLabel:create(GetLocalizeStringBy("key_1771") .. donate_1_arr.silver .. GetLocalizeStringBy("key_1687") , g_sFontName, 20, 1, ccc3(0,0,0), type_stroke)
		n_label_1:setColor(ccc3(0xff, 0xff, 0xff))
		n_label_1:setAnchorPoint(ccp(0.5, 0.5))
		n_label_1:setPosition(ccp( buildingSprite_1:getContentSize().width*0.5, 180))
		buildingSprite_1:addChild(n_label_1)
	else
		-- 文字提示
		local n_label_1 = CCRenderLabel:create(GetLocalizeStringBy("key_1771") , g_sFontName, 20, 1, ccc3(0,0,0), type_stroke)
		n_label_1:setColor(ccc3(0xff, 0xff, 0xff))
		n_label_1:setAnchorPoint(ccp(0, 0.5))
		buildingSprite_1:addChild(n_label_1)
		local label_2 = CCRenderLabel:create( donate_1_arr.gold .. GetLocalizeStringBy("key_1491") , g_sFontName, 20, 1, ccc3(0,0,0), type_stroke)
		label_2:setColor(ccc3(0xff, 0xf6, 0x00))
		label_2:setAnchorPoint(ccp(0, 0.5))
		buildingSprite_1:addChild(label_2)

		-- 计算位置
		local n_label_2_length = n_label_1:getContentSize().width + label_2:getContentSize().width
		local pos_start_2 = (buildingSprite_1:getContentSize().width - n_label_2_length) * 0.5
		-- 设定位置
		n_label_1:setPosition(ccp( pos_start_2, 180))
		label_2:setPosition(ccp( pos_start_2 + n_label_1:getContentSize().width, 180))
	end

	-- 增加军团建设
	local n_label_2 = CCRenderLabel:create(GetLocalizeStringBy("key_2784") , g_sFontName, 20, 1, ccc3(0,0,0), type_stroke)
	n_label_2:setColor(ccc3(0xff, 0xff, 0xff))
	n_label_2:setAnchorPoint(ccp(0, 0.5))
	buildingSprite_1:addChild(n_label_2)
	-- 
	local n_label_2_2 = CCRenderLabel:create( donate_1_arr.guildDonate * guildRate .. GetLocalizeStringBy("key_2132") , g_sFontName, 20, 1, ccc3(0,0,0), type_stroke)
	n_label_2_2:setColor(ccc3(0x6c, 0xff, 0x00))
	n_label_2_2:setAnchorPoint(ccp(0, 0.5))
	buildingSprite_1:addChild(n_label_2_2)
	-- 
	local n_label_2_3 = CCRenderLabel:create( GetLocalizeStringBy("key_1849") , g_sFontName, 20, 1, ccc3(0,0,0), type_stroke)
	n_label_2_3:setColor(ccc3(0xff, 0xff, 0xff))
	n_label_2_3:setAnchorPoint(ccp(0, 0.5))
	buildingSprite_1:addChild(n_label_2_3)
	-- 计算位置
	local n_label_2_length = n_label_2:getContentSize().width + n_label_2_2:getContentSize().width + n_label_2_3:getContentSize().width
	local pos_start_2 = (buildingSprite_1:getContentSize().width - n_label_2_length) * 0.5
	-- 设定位置
	n_label_2:setPosition(ccp( pos_start_2, 140))
	n_label_2_2:setPosition(ccp( pos_start_2 + n_label_2:getContentSize().width, 140))
	n_label_2_3:setPosition(ccp( pos_start_2 + n_label_2:getContentSize().width + n_label_2_2:getContentSize().width, 140))

	-- 增加个人贡献
	local n_label_3 = CCRenderLabel:create(GetLocalizeStringBy("key_2784") , g_sFontName, 20, 1, ccc3(0,0,0), type_stroke)
	n_label_3:setColor(ccc3(0xff, 0xff, 0xff))
	n_label_3:setAnchorPoint(ccp(0, 0.5))
	buildingSprite_1:addChild(n_label_3)
	-- 
	local n_label_3_2 = CCRenderLabel:create( donate_1_arr.sigleDonate * sigleRate .. GetLocalizeStringBy("key_2132") , g_sFontName, 20, 1, ccc3(0,0,0), type_stroke)
	n_label_3_2:setColor(ccc3(0x6c, 0xff, 0x00))
	n_label_3_2:setAnchorPoint(ccp(0, 0.5))
	buildingSprite_1:addChild(n_label_3_2)
	-- 
	local n_label_3_3 = CCRenderLabel:create( GetLocalizeStringBy("key_1974") , g_sFontName, 20, 1, ccc3(0,0,0), type_stroke)
	n_label_3_3:setColor(ccc3(0xff, 0xff, 0xff))
	n_label_3_3:setAnchorPoint(ccp(0, 0.5))
	buildingSprite_1:addChild(n_label_3_3)
	-- 计算位置
	local n_label_3_length = n_label_3:getContentSize().width + n_label_3_2:getContentSize().width + n_label_3_3:getContentSize().width
	local pos_start_3 = (buildingSprite_1:getContentSize().width - n_label_3_length) * 0.5
	-- 设定位置
	n_label_3:setPosition(ccp( pos_start_3, 100))
	n_label_3_2:setPosition(ccp( pos_start_3 + n_label_3:getContentSize().width, 100))
	n_label_3_3:setPosition(ccp( pos_start_3 + n_label_3:getContentSize().width + n_label_3_2:getContentSize().width, 100))
	
	-- menuBar
	local m_menuBar = CCMenu:create()
	m_menuBar:setPosition(ccp(0,0))
	buildingSprite_1:addChild(m_menuBar,1,100)

	-- 建设按钮
	-- require "script/libs/LuaCC"
	-- local buildBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_1738"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- buildBtn:setAnchorPoint(ccp(0.5, 0))
	-- buildBtn:registerScriptTapHandler(buildAction)
	-- buildBtn:setPosition(ccp(buildingSprite_1:getContentSize().width*0.5, 10))
	-- m_menuBar:addChild(buildBtn, 2, type_tag )

	local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	normalSprite:setContentSize(CCSizeMake(160,70))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
    selectSprite:setContentSize(CCSizeMake(160,70))
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_blue_hui.png")
    disabledSprite:setContentSize(CCSizeMake(160,70))
    local buildBtn = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    buildBtn:setAnchorPoint(ccp(0.5, 0))
	buildBtn:registerScriptTapHandler(buildAction)
	buildBtn:setPosition(ccp(buildingSprite_1:getContentSize().width*0.5, 10))
	m_menuBar:addChild(buildBtn, 2, type_tag )
	-- 建设文字
	local itemFont =  CCRenderLabel:create( GetLocalizeStringBy("key_1738") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    itemFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
    itemFont:setAnchorPoint(ccp(0.5,0.5))
    itemFont:setPosition(ccp(buildBtn:getContentSize().width*0.5,buildBtn:getContentSize().height*0.5))
    buildBtn:addChild(itemFont,1,10)

    --建设完毕后 置灰
    if(GuildDataCache.getMineDonateTimes()<=0)then
		buildBtn:setEnabled(false)
    	itemFont:setColor(ccc3(0xf1,0xf1,0xf1))
	end

	return buildingSprite_1
end

-- 建设回调
function buildCallback(  cbFlag, dictData, bRet  )
	if( dictData.ret == "ok")then
		local sigleRate = 1
		local guildRate = 1
		require "script/ui/rechargeActive/BenefitActiveLayer"
		local isOpen, openData = BenefitActiveLayer.isConstructionOpen()
		if(isOpen == true)then
			sigleRate, guildRate = parseData(openData, _curDonateType)
		end
		AnimationTip.showTip(GetLocalizeStringBy("key_2362") .. _curDonateInfo.guildDonate*guildRate .. GetLocalizeStringBy("key_3380") .. _curDonateInfo.sigleDonate*sigleRate .. GetLocalizeStringBy("key_2158"))
		
		-- 修改UserModel
		if(_curDonateInfo.silver and _curDonateInfo.silver > 0)then
			UserModel.addSilverNumber(-_curDonateInfo.silver)
		elseif(_curDonateInfo.gold and _curDonateInfo.gold > 0)then
			UserModel.addGoldNumber(-_curDonateInfo.gold)
		end
		-- 修改军团
		GuildDataCache.addMineDonateTimes(-1)
		GuildDataCache.addSigleDonate(_curDonateInfo.sigleDonate*sigleRate)
		GuildDataCache.addGuildDonate(_curDonateInfo.guildDonate*guildRate)

		-- 插入自己捐献的数据 更新贡献信息列表
		local tab = {}
		tab.uname = UserModel.getUserName()
		tab.record_data = _curDonateInfo.guildDonate*guildRate
		table.insert(GuildDataCache._recordList,1,tab)
		--_listTableView:reloadData()
		_listTableView:removeFromParentAndCleanup(true)
		createContributeTableView()


		-- 建设大厅特效
		local img_path = CCString:create("images/base/effect/jianzhushengji/jianzhushengji")
	    local buildAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
	    buildAnimSprite:setAnchorPoint(ccp(0.5, 0))
	    buildAnimSprite:setPosition(ccp(hallSprite:getContentSize().width*0.5,hallSprite:getContentSize().width*0.45))
	    hallSprite:addChild(buildAnimSprite,30)
		-- 刷新变动ui
		refreshAllLable()
		-- 置灰三个捐献按钮
		-- tolua.cast(buildingSprite_1:getChildByTag(100):getChildByTag( Tag_Normal_Build ),"CCMenuItemSprite"):setEnabled(false)
		-- tolua.cast(buildingSprite_1:getChildByTag(100):getChildByTag( Tag_Normal_Build ):getChildByTag(10),"CCLabelTTF"):setColor(ccc3(0xf1,0xf1,0xf1))
		-- tolua.cast(buildingSprite_2:getChildByTag(100):getChildByTag( Tag_Middle_Build ),"CCMenuItemSprite"):setEnabled(false)
		-- tolua.cast(buildingSprite_2:getChildByTag(100):getChildByTag( Tag_Middle_Build ):getChildByTag(10),"CCLabelTTF"):setColor(ccc3(0xf1,0xf1,0xf1))
		-- tolua.cast(buildingSprite_3:getChildByTag(100):getChildByTag( Tag_High_Build ),"CCMenuItemSprite"):setEnabled(false)
		-- tolua.cast(buildingSprite_3:getChildByTag(100):getChildByTag( Tag_High_Build ):getChildByTag(10),"CCLabelTTF"):setColor(ccc3(0xf1,0xf1,0xf1))

		tolua.cast(_buildSpriteTab[1]:getChildByTag(100):getChildByTag( Tag_Normal_Build ),"CCMenuItemSprite"):setEnabled(false)
		tolua.cast(_buildSpriteTab[1]:getChildByTag(100):getChildByTag( Tag_Normal_Build ):getChildByTag(10),"CCLabelTTF"):setColor(ccc3(0xf1,0xf1,0xf1))
		tolua.cast(_buildSpriteTab[2]:getChildByTag(100):getChildByTag( Tag_Middle_Build ),"CCMenuItemSprite"):setEnabled(false)
		tolua.cast(_buildSpriteTab[2]:getChildByTag(100):getChildByTag( Tag_Middle_Build ):getChildByTag(10),"CCLabelTTF"):setColor(ccc3(0xf1,0xf1,0xf1))
		tolua.cast(_buildSpriteTab[3]:getChildByTag(100):getChildByTag( Tag_New_Build ),"CCMenuItemSprite"):setEnabled(false)
		tolua.cast(_buildSpriteTab[3]:getChildByTag(100):getChildByTag( Tag_New_Build ):getChildByTag(10),"CCLabelTTF"):setColor(ccc3(0xf1,0xf1,0xf1))
		tolua.cast(_buildSpriteTab[4]:getChildByTag(100):getChildByTag( Tag_High_Build ),"CCMenuItemSprite"):setEnabled(false)
		tolua.cast(_buildSpriteTab[4]:getChildByTag(100):getChildByTag( Tag_High_Build ):getChildByTag(10),"CCLabelTTF"):setColor(ccc3(0xf1,0xf1,0xf1))
		tolua.cast(_buildSpriteTab[5]:getChildByTag(100):getChildByTag( Tag_Super_Build ),"CCMenuItemSprite"):setEnabled(false)
		tolua.cast(_buildSpriteTab[5]:getChildByTag(100):getChildByTag( Tag_Super_Build ):getChildByTag(10),"CCLabelTTF"):setColor(ccc3(0xf1,0xf1,0xf1))
	elseif(dictData.ret== "insigntime") then
		AnimationTip.showTip(GetLocalizeStringBy("key_1814"))
	end
end

-- 建设Action
function buildAction( type_tag, itemBtn )
	print("type_tag===", type_tag)
	_curDonateInfo = GuildUtil.getDonateInfoBy(type_tag - 10000)
	_curDonateType = type_tag

	local isCan = false

	if(GuildDataCache.getMineDonateTimes()<=0)then
		AnimationTip.showTip(GetLocalizeStringBy("key_1897"))
		return
	end

	-- vip
	if(UserModel.getVipLevel() < _curDonateInfo.needVip)then
		AnimationTip.showTip(GetLocalizeStringBy("key_3067") .. _curDonateInfo.needVip)
		return
	end
		
	if(_curDonateInfo.silver and _curDonateInfo.silver > 0)then
		if(UserModel.getSilverNumber() < _curDonateInfo.silver )then
			AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
			return
		else
			isCan = true
		end

	elseif(_curDonateInfo.gold and _curDonateInfo.gold > 0)then
		if(UserModel.getGoldNumber() < _curDonateInfo.gold )then
			-- 金币不足提示
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
			return
		else
			isCan = true
		end
	end

	

	if(isCan == true)then
		local args = Network.argsHandler(type_tag-10000)
		RequestCenter.guild_contribute(buildCallback, args)
	end
end

-- added by zhz
function updateShieldTime( )

	local offset =  _contentScrollView:getContentSize().width+ _contentScrollView:getContentOffset().x- _bgSprite:getContentSize().width+16
	if(_rightArrowSp ~= nil )  then
		if(offset>1 or offset<-1) then
			_rightArrowSp:setVisible(true)
		else
			_rightArrowSp:setVisible(false)
		end
	end

	if(_leftArrowSp ~= nil) then

		if( _contentScrollView:getContentOffset().x ~=0) then
			_leftArrowSp:setVisible(true)
		else
			_leftArrowSp:setVisible(false)
		end
	end
end


-- added by zhz
function onNodeEvent( eventType )

    if(eventType == "exit") then
        print("eventType is ", eventType)
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
    end
end

-- 创建中间
function createMainBg( )
	local myScale = _bgLayer:getContentSize().width/640/_bgLayer:getElementScale()
	-- 背景
	local fullRect = CCRectMake(0,0,196, 198)
	local insetRect = CCRectMake(50,50,96,98)
	_bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png", fullRect, insetRect)
	_bgSprite:setPreferredSize( CCSizeMake(_bgLayer:getContentSize().width, _bgLayer:getContentSize().height-_topBgSprite:getContentSize().height*MainScene.elementScale))  -- (CCSizeMake(640, 930))
	_bgSprite:setAnchorPoint(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgSprite:setPosition(ccp(0, 0 ))
	_bgLayer:addChild(_bgSprite)
	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height))
	topSprite:setScale(myScale)
	_bgLayer:addChild(topSprite, 2)
	_bgSprite:setScale(1/MainScene.elementScale)
	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1553"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width)/2, topSprite:getContentSize().height*0.55))
    topSprite:addChild(titleLabel)


    local closeMenuBar = CCMenu:create()
    closeMenuBar:setPosition(ccp(0, 0))
    topSprite:addChild(closeMenuBar)

    -- 关闭按钮
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeAction)
	closeMenuBar:addChild(closeBtn)
	-- closeMenuBar:setTouchPriority(_menu_priority-1)

end

function closeAction()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/guild/GuildMainLayer"
	local guildMainLayer = GuildMainLayer.createLayer(false)
	MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end

function createUI()
	-- 创建头部
	createTopUI()
	-- 创建底部
	createBottom()
	-- 创建中间
	createMainBg()
	-- 创建中间的主UI
	createMainUI()
end

-- 创建
function createLayer()
	init()

	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false, true)
	_bgLayer:registerScriptHandler(onNodeEvent)
	MainScene.setMainSceneViewsVisible(false, false, true)

	createUI()

	return _bgLayer
end

-- 充值后刷新界面金币
refreshGold = function ( ... )
	if(goldLabel)then
		goldLabel:setString( UserModel.getGoldNumber() )
	end
end

-- 刷新界面变化的数值
function refreshAllLable( ... )
	-- 刷新银币
	if(silverLabel)then
		silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))  -- modified by yangrui at 2015-12-03
	end
	-- 刷新金币
	if(goldLabel)then
		goldLabel:setString( UserModel.getGoldNumber() )
	end
	-- 刷新个人总贡献
	if(powerLabel)then
		powerLabel:removeFromParentAndCleanup(true)
		powerLabel = nil
		powerLabel = CCRenderLabel:create(GuildDataCache.getSigleDoante(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    powerLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    powerLabel:setPosition(_topBgSprite:getContentSize().width*0.27, _topBgSprite:getContentSize().height*0.66)
	    _topBgSprite:addChild(powerLabel)
	end
    -- 刷新军团级别
    if(levelDataLabel)then
	    levelDataLabel:removeFromParentAndCleanup(true)
	    levelDataLabel = nil
	    levelDataLabel = CCRenderLabel:create(GuildDataCache.getGuildInfo().guild_level, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    levelDataLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    levelDataLabel:setAnchorPoint(ccp(0, 0))
	    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    levelDataLabel:setPosition(ccp(120, 60))
else
    levelDataLabel:setPosition(ccp(100, 60))
end
	    hallSprite:addChild(levelDataLabel)
	end
    -- 刷新总建设度
    if(numDataLabel)then
	    numDataLabel:removeFromParentAndCleanup(true)
	    numDataLabel = nil
	    local number = GuildDataCache.getGuildInfo().curr_exp
		numDataLabel = CCRenderLabel:create(number, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    numDataLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    numDataLabel:setAnchorPoint(ccp(0, 0))
	    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    numDataLabel:setPosition(ccp(200, 35))
else
    numDataLabel:setPosition(ccp(100, 35))
end
	    hallSprite:addChild(numDataLabel)
	end
	-- 刷新下级需要建设度
	if(needDataLabel)then
		needDataLabel:removeFromParentAndCleanup(true)
	    needDataLabel = nil
	    local curLv = tonumber(GuildDataCache.getGuildInfo().guild_level)
    	local needNumber = GuildUtil.getNeedExpByLv( curLv+1 )
		needDataLabel = CCRenderLabel:create(needNumber, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    needDataLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    needDataLabel:setAnchorPoint(ccp(0, 0))
	    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    needDataLabel:setPosition(ccp(170, 10))
else
    needDataLabel:setPosition(ccp(100, 10))
end
	    hallSprite:addChild(needDataLabel)
	end
end


