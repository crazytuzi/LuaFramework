-- FileName: MatchRankingsLayer.lua 
-- Author: Li Cong 
-- Date: 13-11-11 
-- Purpose: function description of module 

require "script/utils/BaseUI"
module("MatchRankingsLayer", package.seeall)

local _bgLayer 					= nil     -- 排行榜层
local _layerBg 					= nil	  -- 层背景
local _winSize					= nil 	  -- 窗口大小
local second_bg                 = nil     -- 二级背景
function init( ... )
	_bgLayer 					= nil     -- 排行榜层
	_layerBg 					= nil	  -- 层背景
    second_bg                   = nil     -- 二级背景
end


-- 初始化排行榜层
function initMatchRankingsLayer( ... )
	-- 创建背景
	_winSize = CCDirector:sharedDirector():getWinSize()
	_layerBg = BaseUI.createViewBg(CCSizeMake(632,802))
    _layerBg:setAnchorPoint(ccp(0.5,0.5))
    _layerBg:setPosition(ccp(_winSize.width*0.5,_winSize.height*0.5))
    _bgLayer:addChild(_layerBg)
    -- 适配
    setAdaptNode( _layerBg )

    -- 排行榜图片
    local paihangbang = CCSprite:create("images/match/paihangbang.png")
    paihangbang:setAnchorPoint(ccp(0.5,0.5))
    paihangbang:setPosition(ccp(_layerBg:getContentSize().width*0.5,_layerBg:getContentSize().height))
    _layerBg:addChild(paihangbang)

    -- 自己排名
    local myRank_sprite = CCSprite:create("images/match/paiming.png")
    myRank_sprite:setAnchorPoint(ccp(0,1))
    myRank_sprite:setPosition(ccp(40,_layerBg:getContentSize().height-75))
    _layerBg:addChild(myRank_sprite)
    -- 排名数据
    local myRank_font = CCRenderLabel:create( MatchData.getMyRank(), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myRank_font:setAnchorPoint(ccp(0,1))
    myRank_font:setColor(ccc3(0xff,0xf6,0x00))
    myRank_font:setPosition(ccp(myRank_sprite:getPositionX()+myRank_sprite:getContentSize().width+10,_layerBg:getContentSize().height-70))
    _layerBg:addChild(myRank_font)

    -- 积分
    local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2248"), g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_font:setAnchorPoint(ccp(1,1))
    myScore_font:setColor(ccc3(0xff,0xff,0xff))
    myScore_font:setPosition(ccp(500,_layerBg:getContentSize().height-78))
    _layerBg:addChild(myScore_font)
    local myScore_Data = CCRenderLabel:create( MatchData.getMyScore(), g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_Data:setAnchorPoint(ccp(0,1))
    myScore_Data:setColor(ccc3(0x70,0xff,0x18))
    myScore_Data:setPosition(ccp(myScore_font:getPositionX(),_layerBg:getContentSize().height-78))
    _layerBg:addChild(myScore_Data)

    -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-430)
    _layerBg:addChild(menu)
    local colseItem = CCMenuItemImage:create("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png")
    colseItem:setAnchorPoint(ccp(0.5,0))
    colseItem:setPosition(ccp(_layerBg:getContentSize().width*0.5,35))
    colseItem:registerScriptTapHandler(colseItemFun)
    menu:addChild(colseItem)
    -- 字体
    colseItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2474") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    colseItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    colseItem_font:setAnchorPoint(ccp(0.5,0.5))
    colseItem_font:setPosition(ccp(colseItem:getContentSize().width*0.5,colseItem:getContentSize().height*0.5))
    colseItem:addChild(colseItem_font)

    -- 二级背景
    second_bg = BaseUI.createContentBg(CCSizeMake(575,572))
    second_bg:setAnchorPoint(ccp(0.5,0.5))
    second_bg:setPosition(ccp(_layerBg:getContentSize().width*0.5,_layerBg:getContentSize().height*0.5))
    _layerBg:addChild(second_bg)

    if(table.count(MatchData.m_rankingListData) == 0 )then
        local tishi_font = CCRenderLabel:create( GetLocalizeStringBy("key_3175") , g_sFontPangWa, 40, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        tishi_font:setColor(ccc3(0xff, 0xff, 0xff))
        tishi_font:setAnchorPoint(ccp(0.5,0.5))
        tishi_font:setPosition(ccp(second_bg:getContentSize().width*0.5,second_bg:getContentSize().height*0.5))
        second_bg:addChild(tishi_font)
    else
        -- 创建列表
        createRankingList()
    end

    -- 屏蔽穿透层 优先级为-429
    -- touch事件处理
    local pingbiLayer = CCLayer:create()
    -- local pingbiLayer = CCLayerColor:create(ccc4(255,0,0,100))
    local function cardLayerTouch(eventType, x, y)
        local rect = getSpriteScreenRect(pingbiLayer)
        if(rect:containsPoint(ccp(x,y))) then
            return true
        else
            return false
        end
    end
    pingbiLayer:setContentSize(CCSizeMake(632,120))
    pingbiLayer:setTouchEnabled(true)
    pingbiLayer:registerScriptTouchHandler(cardLayerTouch,false,-429,true)
    pingbiLayer:ignoreAnchorPointForPosition(false)
    pingbiLayer:setAnchorPoint(ccp(0.5,0))
    pingbiLayer:setPosition(_layerBg:getContentSize().width*0.5,0)
    _layerBg:addChild(pingbiLayer)
end

-- 创建列表
function createRankingList( ... )
    local function fnSortFun( a, b )
        return tonumber(a.rank) < tonumber(b.rank)
    end 
    -- 排序
    table.sort( MatchData.m_rankingListData, fnSortFun )
    print(GetLocalizeStringBy("key_2506"))
    print_t(MatchData.m_rankingListData)
    -- cellBg的size
    local cellBg = CCSprite:create("images/match/rank_bg.png")
    local cellSize = cellBg:getContentSize() 
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = CCSizeMake(cellSize.width, cellSize.height+10)
        elseif (fn == "cellAtIndex") then
            r = createCell( MatchData.m_rankingListData[a1+1] )
        elseif (fn == "numberOfCells") then
            r = #MatchData.m_rankingListData
        elseif (fn == "cellTouched") then
            -- print ("a1: ", a1, ", a2: ", a2)
            -- print ("cellTouched, index is: ", a1:getIdx())
        else
            -- print (fn, " event is not handled.")
        end
        return r
    end)

    _rankTableView  = LuaTableView:createWithHandler(handler, CCSizeMake(570,562))
    _rankTableView:setBounceable(true)
    _rankTableView:setAnchorPoint(ccp(0, 0))
    _rankTableView:setPosition(ccp(5, 5))
    second_bg:addChild(_rankTableView,2)
    -- 设置单元格升序排列
    _rankTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    _rankTableView:setTouchPriority(-420)
end

-- 创建排行榜
function createMatchRankingsLayer()
	init()
	_bgLayer = CCLayer:create()
    _bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-420,true)
	-- 初始化界面
	initMatchRankingsLayer()

	return _bgLayer
end


-- touch事件处理
function cardLayerTouch(eventType, x, y)
   
    return true
    
end


-- 关闭回调
function colseItemFun( ... )
    if(_bgLayer ~= nil)then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end


-- 创建单元格
function createCell( tCellValue )
    local cell = CCTableViewCell:create()
    -- 背景
    local cellBg = nil
    if( tonumber(tCellValue.rank) == 1 )then
        cellBg = CCSprite:create("images/match/first_bg.png")
    elseif( tonumber(tCellValue.rank) == 2 )then
        cellBg = CCSprite:create("images/match/second_bg.png")
    elseif( tonumber(tCellValue.rank) == 3 )then
        cellBg = CCSprite:create("images/match/third_bg.png")
    else
        cellBg = CCSprite:create("images/match/rank_bg.png")
    end
    cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(0,0))
    cell:addChild(cellBg,1)

    -- 名次图标
    local rank_font = nil
    if( tonumber(tCellValue.rank) == 1 )then
        rank_font = CCSprite:create("images/match/one.png")
    elseif( tonumber(tCellValue.rank) == 2 )then
        rank_font = CCSprite:create("images/match/two.png")
    elseif( tonumber(tCellValue.rank) == 3 )then
        rank_font = CCSprite:create("images/match/three.png")
    else
        rank_font = CCRenderLabel:create( tCellValue.rank , g_sFontPangWa, 50, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        rank_font:setColor(ccc3(0xff, 0xf6, 0x00))
    end
    rank_font:setAnchorPoint(ccp(0.5,0.5))
    rank_font:setPosition(ccp(53,cellBg:getContentSize().height*0.5))
    cellBg:addChild(rank_font)
    -- 名
    local ming = CCSprite:create("images/match/ming.png")
    ming:setAnchorPoint(ccp(0,0))
    ming:setPosition(ccp(90,20))
    cellBg:addChild(ming)
    -- 头像
    local icon_bg = CCSprite:create("images/match/head_bg.png")
    icon_bg:setAnchorPoint(ccp(0,0.5))
    icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
    cellBg:addChild(icon_bg)
    local iconMenu = CCMenu:create()
    iconMenu:setTouchPriority(-420)
    iconMenu:setPosition(ccp(0,0))
    icon_bg:addChild(iconMenu)
    require "script/model/utils/HeroUtil"
    local dressId = nil
    local genderId = nil
    if( not table.isEmpty(tCellValue.squad[1].dress) and (tCellValue.squad[1].dress["1"])~= nil and tonumber(tCellValue.squad[1].dress["1"]) > 0 )then
        dressId = tCellValue.squad[1].dress["1"]
        genderId = HeroModel.getSex(tCellValue.squad[1].htid)
    end
    -- added by zhz , VIP等级产生的特效
    local vip= tCellValue.vip or 0
    local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.squad[1].htid, dressId, genderId, vip)
    local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
    heroIconItem:setAnchorPoint(ccp(0.5,0.5))
    heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
    iconMenu:addChild(heroIconItem,1,tonumber( tCellValue.uid ))
    heroIconItem:registerScriptTapHandler(userFormationItemFun)

    -- lv.
    local lv_sprite = CCSprite:create("images/common/lv.png")
    lv_sprite:setAnchorPoint(ccp(0,1))
    cellBg:addChild(lv_sprite)
    -- 等级
    local lv_data = CCRenderLabel:create( tCellValue.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setAnchorPoint(ccp(0,1))
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    cellBg:addChild(lv_data)
    -- 居中
    local posX = (cellBg:getContentSize().width-lv_sprite:getContentSize().width-lv_data:getContentSize().width)*0.6
    lv_sprite:setPosition(ccp(posX,cellBg:getContentSize().height*0.9))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+2,cellBg:getContentSize().height*0.9))
    -- 名字
    local name = CCRenderLabel:create( tCellValue.uname , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
     if( tonumber(tCellValue.rank) == 1 )then
        name:setColor(ccc3(0xf9, 0x59, 0xff))
    elseif( tonumber(tCellValue.rank) == 2 )then
        name:setColor(ccc3(0x00, 0xe4, 0xff))
    elseif( tonumber(tCellValue.rank) == 3 )then
        name:setColor(ccc3(0x70, 0xff, 0x18))
    else
        name:setColor(ccc3(0xff, 0xff, 0xff))
    end
    name:setAnchorPoint(ccp(0.5,0.5))
    name:setPosition(ccp(cellBg:getContentSize().width*0.6,cellBg:getContentSize().height*0.5))
    cellBg:addChild(name)

    -- 军团名字
    if(tCellValue.guild_name)then
        local guildNameStr = tCellValue.guild_name or " "
        local guildNameFont = CCRenderLabel:create( "[" .. guildNameStr .. "]" , g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        guildNameFont:setAnchorPoint(ccp(0.5,0))
        guildNameFont:setColor(ccc3(0xff, 0xf6, 0x00))
        guildNameFont:setPosition(ccp(cellBg:getContentSize().width*0.6,cellBg:getContentSize().height*0.1))
        cellBg:addChild(guildNameFont)
    end

    -- 积分
    local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2248"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_font:setAnchorPoint(ccp(0,1))
    myScore_font:setColor(ccc3(0xff,0xff,0xff))
    myScore_font:setPosition(ccp(443,cellBg:getContentSize().height-20))
    cellBg:addChild(myScore_font)
    local myScore_Data = CCRenderLabel:create( tCellValue.point, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_Data:setAnchorPoint(ccp(0.5,0))
    myScore_Data:setColor(ccc3(0x70,0xff,0x18))
    myScore_Data:setPosition(ccp(500,23))
    cellBg:addChild(myScore_Data)

    return cell
end


-- 对方阵容回调
function userFormationItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2710") .. tag )
    -- local str1 = GetLocalizeStringBy("key_3038")
    -- require "script/ui/tip/AnimationTip"
    -- AnimationTip.showTip(str1)
    require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tonumber(tag))
end






