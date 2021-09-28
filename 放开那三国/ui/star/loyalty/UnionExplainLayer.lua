-- Filename：    UnionExplainLayer.lua
-- Author：      DJN
-- Date：        2015-8-3
-- Purpose：     聚义厅羁绊详细信息弹板

module("UnionExplainLayer",  package.seeall)
require "db/DB_Union_profit"
require "db/DB_Heroes"
local _unionId      --羁绊ID
local _touchPriority
local _zOrder
local _bgLayer
local _cellNum
local _heroTable   --拥有该羁绊的武将的集合
function init( ... )
    _unionId = nil
    _touchPriority = nil
    _zOrder = nil
    _bgLayer = nil
    _cellNum = nil
    _heroTable = {}
end
----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
    if eventType == "began" then
       --print("onTouchesHandler,began")
        return true
    elseif eventType == "moved" then
        --print("onTouchesHandler,moved")
    else
        --print("onTouchesHandler,else")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end

----------------------------------------关闭页面回调
function closeCb()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end
--创建cell
function createCell(p_index)
    local cell = CCTableViewCell:create()
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local cellBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(520,150))
    cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(15,0))
    cell:addChild(cellBg)

    local heroSp = HeroUtil.getHeroIconByHTID(_heroTable[p_index].id) 
    heroSp:setPosition(ccp(10,40))
    cellBg:addChild(heroSp)

    local heroNameLabel = CCRenderLabel:create(_heroTable[p_index].name,g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    heroNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_heroTable[p_index].potential))
    heroNameLabel:setAnchorPoint(ccp(0.5,1))
    heroNameLabel:setPosition(ccpsprite(0.5,-0.01,heroSp))
    heroSp:addChild(heroNameLabel)

    local unionInfo = DB_Union_profit.getDataById(_unionId)
    if(not table.isEmpty(unionInfo))then
        local unionNameLabel =  CCRenderLabel:create(unionInfo.union_arribute_name,g_sFontName,23,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        unionNameLabel:setColor(ccc3(0x00,0xff,0x18))
        unionNameLabel:setAnchorPoint(ccp(0.5,1))
        unionNameLabel:setPosition(ccpsprite(0.6,0.9,cellBg))
        cellBg:addChild(unionNameLabel)

        local line = CCScale9Sprite:create("images/common/line01.png")
        line:setContentSize(CCSizeMake(300, 4))
        line:setAnchorPoint(ccp(0.5,1))
        line:setPosition(ccpsprite(0.6,0.68,cellBg))
        cellBg:addChild(line)

        local desLabel = CCLabelTTF:create(unionInfo.union_arribute_desc,g_sFontName,23,CCSizeMake(280,0),kCCTextAlignmentCenter)
        desLabel:setColor(ccc3(0x78,0x25,0x00))
        desLabel:setAnchorPoint(ccp(0.5,0))
        desLabel:setPosition(ccpsprite(0.6,0.2,cellBg))
        cellBg:addChild(desLabel)

    end
    return cell

end
--创建tableView
function createTableView( ... )
    local heightNum = _cellNum > 4 and 4 or _cellNum
    local tableView_hight = 160 * heightNum
    local tableView_width = 550
     
    -- 显示单元格背景的size
    local cell_bg_size = { width = tableView_width, height = 160 } 
   

    --require "script/ui/main/MainScene"
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = CCSizeMake(cell_bg_size.width , cell_bg_size.height)
        elseif (fn == "cellAtIndex") then
            a2 = createCell(a1+1)
            r=a2
        elseif (fn == "numberOfCells") then
            r = _cellNum
        elseif (fn == "cellTouched") then
            -- print ("a1: ", a1, ", a2: ", a2)
            -- print ("cellTouched, index is: ", a1:getIdx())
        elseif (fn == "scroll") then
            -- print ("scroll, index is: ")
        else
            -- print (fn, " event is not handled.")
        end
        return r
    end)

    return LuaTableView:createWithHandler(handler, CCSizeMake(tableView_width,tableView_hight))
end

--创建UI函数
function createUI( ... )
   
    -- print("_heroTable",table.count(_heroTable))
    -- print_t(_heroTable)
    
    --print("110*_cellNum + 100",110*_cellNum + 100)
    require "script/ui/main/MainScene"
    local heightNum = _cellNum > 4 and 4 or _cellNum
    local bgSize = CCSizeMake(566,160*heightNum + 100)
    local bgScale = MainScene.elementScale

    --主黄色背景
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
    bgSprite:setScale(bgScale)
    _bgLayer:addChild(bgSprite)
    
    -- 顶部标题
    local titleBg= CCSprite:create("images/common/viewtitle1.png")
    titleBg:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height))
    titleBg:setAnchorPoint(ccp(0.5, 0.5))
    bgSprite:addChild(titleBg)

    --标题文本
    local labelTitle = CCLabelTTF:create(GetLocalizeStringBy("lcy_50109"), g_sFontPangWa,33)
    labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
    labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
    titleBg:addChild(labelTitle)

    --“拥有该羁绊的武将”
    local explainLabel = CCLabelTTF:create(GetLocalizeStringBy("djn_202"), g_sFontName,23)
    explainLabel:setColor(ccc3(0x78,0x25,0x00))
    explainLabel:setAnchorPoint(ccp(0.5,1))
    explainLabel:setPosition(ccp(bgSprite:getContentSize().width* 0.5,bgSprite:getContentSize().height-40))
    bgSprite:addChild(explainLabel)

    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)
    -- 关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(bgSize.width*1.03,bgSize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    bgMenu:addChild(closeBtn)

    local tableView = createTableView()
    tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(ccp(0.5, 0))
    tableView:setPosition(ccp(283,37))
    bgSprite:addChild(tableView)
    -- 设置滑动列表的优先级
    tableView:setTouchPriority(_touchPriority-1)

end

--入口函数
--param: 羁绊id 触摸优先级 z轴
function showLayer( p_id,p_touch,p_z)
    print("UnionExplainLayer p_id",p_id)
    init()
    _unionId = tonumber(p_id)
    _touchPriority = p_touch or -499
    _zOrder = p_z or 999
    _heroTable = LoyaltyData.getHeroByUnion(p_id)
    _cellNum = table.count(_heroTable)
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_zOrder)

    createUI()

    return _bgLayer
    -- body
end