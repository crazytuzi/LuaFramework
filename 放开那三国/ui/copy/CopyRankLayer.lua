-- FileName: CopyRankLayer.lua 
-- Author: Li Cong 
-- Date: 14-1-13 
-- Purpose: function description of module 


module("CopyRankLayer", package.seeall)

require "script/utils/BaseUI"

local _bgLayer 					= nil     -- 排行榜层
local _layerBg 					= nil	  -- 层背景
local _winSize					= nil 	  -- 窗口大小
local second_bg                 = nil     -- 二级背景
------------------------- 数据 ----------------------
local _rankingListData 			= nil 	  -- 排行榜数据
local _mySelfData               = nil     -- 自身数据

function init( ... )
	_bgLayer 					= nil     -- 排行榜层
	_layerBg 					= nil	  -- 层背景
    second_bg                   = nil     -- 二级背景
    _rankingListData            = nil       
    _mySelfData                 = nil     -- 自身数据
end


-- 初始化排行榜层
function initRankingsLayer( ... )
	-- 创建背景
	_winSize = CCDirector:sharedDirector():getWinSize()
	_layerBg = BaseUI.createViewBg(CCSizeMake(632,802))
    _layerBg:setAnchorPoint(ccp(0.5,0.5))
    _layerBg:setPosition(ccp(_winSize.width*0.5,_winSize.height*0.5))
    _bgLayer:addChild(_layerBg)
    -- 适配
    setAdaptNode( _layerBg )

    -- 排行榜图片
    local paihangbang = CCSprite:create("images/copy/paihangbang.png")
    paihangbang:setAnchorPoint(ccp(0.5,0.5))
    paihangbang:setPosition(ccp(_layerBg:getContentSize().width*0.5,_layerBg:getContentSize().height))
    _layerBg:addChild(paihangbang)

    -- 自己排名
    local myRank_sprite = CCSprite:create("images/match/paiming.png")
    myRank_sprite:setAnchorPoint(ccp(0,1))
    myRank_sprite:setPosition(ccp(40,_layerBg:getContentSize().height-75))
    _layerBg:addChild(myRank_sprite)
    -- 排名数据
    local myRankData = _mySelfData.rank or " "
    local myRank_font = CCRenderLabel:create( myRankData, g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myRank_font:setAnchorPoint(ccp(0,1))
    myRank_font:setColor(ccc3(0xff,0xf6,0x00))
    myRank_font:setPosition(ccp(myRank_sprite:getPositionX()+myRank_sprite:getContentSize().width+10,_layerBg:getContentSize().height-70))
    _layerBg:addChild(myRank_font)

    -- 副本进度
    local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2730"), g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_font:setAnchorPoint(ccp(0,1))
    myScore_font:setColor(ccc3(0xff,0xff,0xff))
    myScore_font:setPosition(ccp(400,_layerBg:getContentSize().height-78))
    _layerBg:addChild(myScore_font)
    local myScoreData = _mySelfData.score or " " 
    local myScore_Data = CCRenderLabel:create( myScoreData, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_Data:setAnchorPoint(ccp(1,1))
    myScore_Data:setColor(ccc3(0x70,0xff,0x18))
    myScore_Data:setPosition(ccp(myScore_font:getPositionX()+myScore_font:getContentSize().width+myScore_Data:getContentSize().width+5,_layerBg:getContentSize().height-78))
    _layerBg:addChild(myScore_Data)
    local starSprite = CCSprite:create("images/copy/star.png")
    starSprite:setAnchorPoint(ccp(0,1))
    starSprite:setPosition(ccp(myScore_Data:getPositionX()+2,_layerBg:getContentSize().height-78))
    _layerBg:addChild(starSprite)

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

    if(table.count(_rankingListData) == 0 )then
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
    -- local function fnSortFun( a, b )
    --     return tonumber(a.rank) < tonumber(b.rank)
    -- end 
    -- -- 排序
    -- table.sort( _rankingListData, fnSortFun )
    -- print(GetLocalizeStringBy("key_2506"))
    -- print_t(_rankingListData)
    -- cellBg的size
    require "script/ui/copy/CopyRankCell"
    local cellBg = CCSprite:create("images/match/rank_bg.png")
    local cellSize = cellBg:getContentSize() 
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = CCSizeMake(cellSize.width, cellSize.height+10)
        elseif (fn == "cellAtIndex") then
            r = CopyRankCell.createCell( _rankingListData[a1+1] )
        elseif (fn == "numberOfCells") then
            r = #_rankingListData
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


-- 获取排行榜信息回调
function getCopyRankCallFun( cbFlag, dictData, bRet )
    if(dictData.err == "ok")then
        -- 自身数据
        _mySelfData = dictData.ret.user_rank
        -- 排行列表
        _rankingListData = dictData.ret.rank_list
    	-- 初始化界面
    	initRankingsLayer()
    end
end

-- 创建排行榜
function createRankingsLayer()
	init()
	_bgLayer = CCLayer:create()
    _bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-420,true)

	-- 获取排行榜信息  -- 前50名
    local args = CCArray:create()
    args:addObject(CCInteger:create(50))
	RequestCenter.copy_rank(getCopyRankCallFun,args)
	return _bgLayer
end


-- touch事件处理
function cardLayerTouch(eventType, x, y)
   
    return true
    
end


-- 关闭回调
function colseItemFun( ... )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if(_bgLayer ~= nil)then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end
