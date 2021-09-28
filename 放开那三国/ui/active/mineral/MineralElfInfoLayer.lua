-- Filename：	MineralElfInfoLayer.lua
-- Author：		bzx
-- Date：		2015-5-15
-- Purpose：		宝藏信息

module ("MineralElfInfoLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/ui/active/mineral/MineralMenuItem"
require "script/utils/BaseUI"
require "script/ui/active/mineral/MineralUtil"
require "db/DB_Normal_config"
require "script/ui/tip/SingleTip"
require "script/utils/LuaUtil"
require "db/DB_Vip"
require "script/libs/LuaCCSprite"
require "script/libs/LuaCCLabel"
----------------------------------
local _bgLayer 				= nil
local _curMineralInfo 		= nil	-- 当前矿的信息
local _occupyBtn			= nil	-- 占领按钮
local _forceOccupyBtn 		= nil	-- 强占
local _occupyCountUpLabel 	= nil	-- 占领市场
local _protectLabel			= nil	-- 保护时间

local attr_arr				= nil	-- 属性的解析
local _updateTimeScheduler	= nil	-- sche
------------------------------------------ added by bzx
local _layer_touch_priority = -450
local _helper_name_labels
local _guard_time_label
local _remainTimeLabel   			-- 剩余开启倒计时 
------------------------------------------

-- 初始化
local function init( )
	_bgLayer 				= nil
	_curMineralInfo 		= nil	-- 当前矿的信息
	_occupyBtn				= nil	-- 占领按钮
	_forceOccupyBtn 		= nil	-- 强占
	_occupyCountUpLabel 	= nil	-- 占领市场
    _guard_time_label       = nil
	attr_arr				= nil	-- 属性的解析
	_protectLabel			= nil	-- 保护时间
    _remainTimeLabel 		= nil
    _helper_name_labels     = {}
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		return true
    elseif (eventType == "moved") then
	
    else
    	
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _layer_touch_priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
        stopTimeScheduler()
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
function closeAction( tag, itembtn )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    close()
end 

function close( ... )
	if tolua.isnull(_bgLayer) then
		return
	end
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function stopTimeScheduler()
    if _updateTimeScheduler ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

function starTimeScheduler()
    if _updateTimeScheduler == nil then
        _updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
    end
end

-- 获取标题 的sprite格式
local function getTitleSpriteByText( text )
	local titleSp = CCScale9Sprite:create("images/hero/info/title_bg.png", CCRectMake(0, 0, 122, 40))
	titleSp:setAnchorPoint(ccp(0,0.5))
	local titleLabel = CCLabelTTF:create(text, g_sFontName, 21)
	titleLabel:setColor(ccc3(0x00, 0x00, 0x00))
	titleLabel:setAnchorPoint(ccp(0, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width * 0.1, titleSp:getContentSize().height * 0.5 + 2))
	titleSp:addChild(titleLabel)
	titleSp:setPreferredSize(CCSizeMake(titleLabel:getContentSize().width + 40, 40))
	return titleSp
end

-- 
function occupyCallback(ret)
	if ret == "occupylimit" then
		AnimationTip.showTip(GetLocalizeStringBy("key_10352"))
		return
	end
	if ret == "noelves" then
		AnimationTip.showTip(GetLocalizeStringBy("key_10353"))
		return
	end
    require "script/battle/BattleLayer"
    local amf3_obj = Base64.decodeWithZip(ret.fight_ret)
    local lua_obj = amf3.decode(amf3_obj)
    local appraisal = lua_obj.appraisal
    -- 敌人uid
    local uid1 = lua_obj.team1.uid
    local uid2 = lua_obj.team2.uid
    local enemyUid = 0
    if(tonumber(uid1) ==  UserModel.getUserUid() )then
        enemyUid = tonumber(uid2)
    end
    if(tonumber(uid2) ==  UserModel.getUserUid() )then
        enemyUid = tonumber(uid1)
    end
    require "script/ui/active/mineral/AfterMineral"
    local is_npc = true
    if _curMineralInfo.uid ~= "0" then
        is_npc = nil
    end
    local layer = AfterMineral.createAfterMineralLayer(ret.appraisal, enemyUid, MineralLayer.callbackBattleLayerEnd, ret.fight_ret, is_npc)
    BattleLayer.showBattleWithString(ret.fight_ret, nil, layer, "shandong.jpg")
	closeAction()
end

-- 占领的Action
local function occupyAction	( tag, itembtn)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
	MineralElvesService.occupyMineralElves(_curMineralInfo.domain_id, occupyCallback)
end

--
local function createUI()
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local bgSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
    bgSprite:setPreferredSize(CCSizeMake(560, 675))

	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.45))
	bgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(bgSprite)


	-- 标题
	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height*0.99))
	bgSprite:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_10354"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(_layer_touch_priority - 1)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.97, bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

---- 中间的UI
	-- 
	local fullRect_2 = CCRectMake(0, 0, 48, 48)
	local insetRect_2 = CCRectMake(20, 20, 10, 8)

    -- 当前位置
    local info_bar_y = bgSprite:getContentSize().height - 44
    -- 间距
    local info_bar_pitch = 7
    -- 单行的高度
    local info_bar_height_1 = 48
    local cell_x = 160
	-- 开启倒计时
	local remainTimeSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	remainTimeSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	remainTimeSprite:setAnchorPoint(ccp(0.5, 1))
	remainTimeSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(remainTimeSprite)
	-- 标题
	local remainTimeTitleSp = getTitleSpriteByText(GetLocalizeStringBy("key_10355"))
	remainTimeTitleSp:setPosition(ccp(0, remainTimeSprite:getContentSize().height * 0.5))
	remainTimeSprite:addChild(remainTimeTitleSp)
	
	_remainTimeLabel = CCLabelTTF:create("00:00:00", g_sFontName, 23)
	_remainTimeLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
	_remainTimeLabel:setAnchorPoint(ccp(0, 0.5))
	_remainTimeLabel:setPosition(ccp(cell_x, remainTimeSprite:getContentSize().height * 0.5))
	remainTimeSprite:addChild(_remainTimeLabel)
	startRefreshRemainTimeLabel()
	if tolua.isnull(_bgLayer) then
		return
	end
	info_bar_y = info_bar_y - remainTimeSprite:getContentSize().height - info_bar_pitch

	---- 占领者
	local occupyManSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	occupyManSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	occupyManSprite:setAnchorPoint(ccp(0.5, 1))
	occupyManSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(occupyManSprite)
	-- 标题
	local occupyManTitleSp = getTitleSpriteByText(GetLocalizeStringBy("key_3200"))
	occupyManTitleSp:setPosition(ccp(0, occupyManSprite:getContentSize().height*0.5))
	occupyManSprite:addChild(occupyManTitleSp)
	-- 
	local uname = GetLocalizeStringBy("key_1554")
	if(tonumber(_curMineralInfo.uid) >0 ) then
		uname = _curMineralInfo.uname
	end
	local occupyNumLabel = CCRenderLabel:create(uname, g_sFontName, 23, 1,ccc3(0x00, 0x00, 0x00), type_stroke)
    --occupyNumLabel:setColor(ccc3(0x78, 0x25, 0x00))
    if tonumber(_curMineralInfo.uid) == UserModel. getUserUid() then
        occupyNumLabel:setColor(ccc3(0x00, 0xff, 0x18))
    end
	occupyNumLabel:setAnchorPoint(ccp(0, 0.5))
	occupyNumLabel:setPosition(ccp(240, occupyManSprite:getContentSize().height/2))
	occupyManSprite:addChild(occupyNumLabel)

	if(tonumber(_curMineralInfo.uid) >0 ) then
		local levelLabel = CCRenderLabel:create("Lv." .. _curMineralInfo.level, g_sFontName, 21, 1,ccc3(0x00, 0x00, 0x00), type_stroke)
		levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
		levelLabel:setPosition(ccp(cell_x, occupyManSprite:getContentSize().height - (occupyManSprite:getContentSize().height-levelLabel:getContentSize().height)/2))
		occupyManSprite:addChild(levelLabel)
	end
    info_bar_y = info_bar_y - occupyManSprite:getContentSize().height - info_bar_pitch

    if tonumber(_curMineralInfo.uid) > 0 and tonumber(_curMineralInfo.uid) ~= UserModel.getUserUid() then
	    local occupyMenu = CCMenu:create()
	    occupyManSprite:addChild(occupyMenu)
	    occupyMenu:setPosition(ccp(0, 0))
	    occupyMenu:setTouchPriority(_layer_touch_priority - 1)
	    local lookFormationBtn = CCMenuItemImage:create("images/olympic/checkbutton/check_btn_h.png", "images/olympic/checkbutton/check_btn_n.png")
	    occupyMenu:addChild(lookFormationBtn)
	    lookFormationBtn:registerScriptTapHandler(lookFormationCallback)
	    lookFormationBtn:setAnchorPoint(ccp(0.5, 0.5))
	    lookFormationBtn:setScale(0.88)
	    lookFormationBtn:setPosition(ccpsprite(0.92, 0.5, occupyManSprite))
	end
    -- 说明
	local fullRect_3 = CCRectMake(0,0,162,43)
	local insetRect_3 = CCRectMake(70,20,22,3)
	local descSprite = CCScale9Sprite:create("images/common/bg/bg_9s_1.png", fullRect, insetRect)
	descSprite:setPreferredSize(CCSizeMake(420, 130))
	descSprite:setAnchorPoint(ccp(0.5, 0))
	descSprite:setPosition(ccp(bgSprite:getContentSize().width * 0.5, bgSprite:getContentSize().height - 300))
	bgSprite:addChild(descSprite)	

	local descTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3022"), g_sFontPangWa, 33)
	descTitleLabel:setColor(ccc3(0xff, 0xff, 0xff))
	descTitleLabel:setAnchorPoint(ccp(0.5, 0))
	descTitleLabel:setPosition(ccp(descSprite:getContentSize().width * 0.5, 85))
	descSprite:addChild(descTitleLabel)
    

    local richInfo = {}
	richInfo.defaultType = "CCRenderLabel"
    richInfo.labelDefaultSize = 21
    richInfo.elements = {
        {
            text = GetLocalizeStringBy("key_10356"),
            color = ccc3(0xFF, 0x00, 0xE1)
        }
    }
    local descLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10357"), richInfo)
    descSprite:addChild(descLabel)
    descLabel:setAnchorPoint(ccp(0.5, 0))
    descLabel:setPosition(ccp(descSprite:getContentSize().width * 0.5, 20))

     
    -- 列表背景
    _listHight = 221
    _listWidth = 500
    local listBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/bg/9s_1.png")

    listBg:setContentSize(CCSizeMake(_listWidth,_listHight))
    listBg:setAnchorPoint(ccp(0.5,0))
    listBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,115))
    bgSprite:addChild(listBg)
    -- 标题
    local fullRect = CCRectMake(0,0,75,35)
    local insetRect = CCRectMake(35,14,5,6)
    local titleSp = CCScale9Sprite:create("images/astrology/astro_labelbg.png",fullRect, insetRect)
    titleSp:setContentSize(CCSizeMake(182,35))
    titleSp:setAnchorPoint(ccp(0.5,0.5))
    titleSp:setPosition(ccp(listBg:getContentSize().width*0.5,listBg:getContentSize().height))
    listBg:addChild(titleSp)
    local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_2295"), g_sFontPangWa, 24)
    titleFont:setColor(ccc3(0xff,0xf6,0x00))
    titleFont:setAnchorPoint(ccp(0.5,0.5))
    titleFont:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height*0.5))
    titleSp:addChild(titleFont)

    -- 创建tableView
    local cellSize = CCSizeMake(500, 140)
    local needNum = 4
    local _showItems = ItemUtil.getItemsDataByStr(MineralElvesData.getElvesDb().reward)
	local handler = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.1,0.3,0.5,0.7,0.9}
			for i=1,needNum do
				if(_showItems[a1*needNum+i] ~= nil)then
					local item_sprite = ItemUtil.createGoodsIcon(_showItems[a1*needNum+i], _layer_touch_priority - 1, 1010, _layer_touch_priority - 10, nil ,true,nil)
					item_sprite:setAnchorPoint(ccp(0.5,1))
					item_sprite:setPosition(ccp(590*posArrX[i],130))
					a2:addChild(item_sprite)
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_showItems
			r = math.ceil(num/needNum)
		else
		end
		return r
	end)

    _listTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_listWidth,_listHight-22*g_fScaleX))
    _listTableView:setBounceable(true)
    _listTableView:setAnchorPoint(ccp(0, 0))
    _listTableView:setPosition(ccp(11, 1))
    listBg:addChild(_listTableView)
    -- 设置单元格升序排列
    _listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    _listTableView:setTouchPriority(-623)


    if UserModel.getUserUid() == tonumber(_curMineralInfo.uid) then
    	local occupySp = CCSprite:create("images/active/mineral/occupy.png")
		occupySp:setAnchorPoint(ccp(0.5,0))
		occupySp:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 30))
		bgSprite:addChild(occupySp)
    else
    	-- 占领按钮
		local occupyMenuBar =  CCMenu:create()
		occupyMenuBar:setPosition(ccp(0, 0))
		occupyMenuBar:setTouchPriority(_layer_touch_priority - 1)
		bgSprite:addChild(occupyMenuBar)


	    local force_occupy_btn_info = {
	        normal = "images/common/btn/btn1_d.png",
	        selected = "images/common/btn/btn1_n.png",
	        size = CCSizeMake(200, 73),
	        icon = "images/common/gold.png",
	        text = GetLocalizeStringBy("key_3409"),
	        number = "0"
	    }

	    _forceOccupyBtn = LuaCCSprite.createNumberMenuItem(force_occupy_btn_info)
	    occupyMenuBar:addChild(_forceOccupyBtn, 2, 10002)
	   	_forceOccupyBtn:setAnchorPoint(ccp(0.5, 0))
		_forceOccupyBtn:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 30))
		_forceOccupyBtn:registerScriptTapHandler(occupyAction)
		
    end
end

function lookFormationCallback( ... )
	require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tonumber(_curMineralInfo.uid))
end

function startRefreshRemainTimeLabel( ... )
    refreshRemainTimeLabel()
    if tolua.isnull(_bgLayer) then
    	return
    end
    schedule(_bgLayer, refreshRemainTimeLabel, 1)
end

function refreshRemainTimeLabel( ... )
	local remainTime = MineralElvesData.getCurElvesEndRemainTime()
	if remainTime <= 0 then
		close()
		return
	end
	_remainTimeLabel:setString(TimeUtil.getTimeString(remainTime))
end

function show(mineral_info)
    local mineralElfInfoLayer = MineralElfInfoLayer.createLayer(mineral_info)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if mineralElfInfoLayer == nil then
		return
	end
	runningScene:addChild(mineralElfInfoLayer)
end

-- create
function createLayer(mineral_info)
	init()
	_curMineralInfo = mineral_info
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	createUI()

	return _bgLayer
end

function refresh(mineral_info)
    if MineralUtil.isEqual(mineral_info, _curMineralInfo) then
        if _bgLayer ~= nil then
            stopTimeScheduler()
            _bgLayer:removeFromParentAndCleanup(true)
            show(mineral_info)
        end
    end
end
