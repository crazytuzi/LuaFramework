-- FileName: ConsumeLayer.lua 
-- Author: Li Cong 
-- Date: 14-1-8 
-- Purpose: function description of module 

module("ConsumeLayer", package.seeall)
require "script/utils/BaseUI"
require "script/ui/rechargeActive/ActiveCache"
require "script/utils/TimeUtil"
require "script/model/utils/ActivityConfigUtil"

local _bgLayer 				= nil
local _mineBg               = nil	-- 大背景
local tableView_bg 			= nil	
local tableView_height      = nil 
local _consumeInfo          = nil   -- 消费累积的数据信息

function init( ... )
	_bgLayer 				= nil
	_mineBg              	= nil	-- 大背景
	tableView_bg 			= nil	
    tableView_height        = nil 
    _consumeInfo            = nil   -- 消费累积的数据信息
end

-- 初始化界面
function initConsumeLayer( ... )
    require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = RechargeActiveMain.getTopSize()
	print("width",_bgLayer:getContentSize().width,"height",_bgLayer:getContentSize().height)
	local topMenuHeight = RechargeActiveMain.getBgWidth()+bulletinLayerSize.height*g_fScaleX
	print(topMenuHeight)
    -- 人物背景
    _mineBg = CCScale9Sprite:create("images/recharge/consume/bg.png")
    _mineBg:setAnchorPoint(ccp(0.5,1))
    _mineBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-topMenuHeight))
    _bgLayer:addChild(_mineBg)
    _mineBg:setScale(g_fScaleX)
    -- 累积消费
	local titleSprite = CCSprite:create("images/recharge/consume/title.png")
	titleSprite:setAnchorPoint(ccp(0.5,0))
	titleSprite:setPosition(ccp(188,_mineBg:getContentSize().height-87))
	_mineBg:addChild(titleSprite)

	-- 消费广告
	local tip_bg = CCScale9Sprite:create("images/recharge/content_bg.png")
	tip_bg:setContentSize(CCSizeMake(390,100))
	tip_bg:setAnchorPoint(ccp(0,1))
	tip_bg:setPosition(ccp(0,titleSprite:getPositionY()-5))
	_mineBg:addChild(tip_bg)
	-- 广告语
    local strSprite = CCSprite:create("images/recharge/consume/font_sprite.png")
    strSprite:setAnchorPoint(ccp(0.5,0.5))
    strSprite:setPosition(ccp(tip_bg:getContentSize().width*0.5,tip_bg:getContentSize().height*0.5))
    tip_bg:addChild(strSprite)

    -- 开放时间
    local timeBg = CCScale9Sprite:create("images/recharge/time_bg.png")
    timeBg:setContentSize(CCSizeMake(_mineBg:getContentSize().width,30))
    timeBg:setAnchorPoint(ccp(0.5,1))
    timeBg:setPosition(ccp(_mineBg:getContentSize().width*0.5,tip_bg:getPositionY()-tip_bg:getContentSize().height-15))
    _mineBg:addChild(timeBg)
    local timeFont = CCRenderLabel:create( GetLocalizeStringBy("key_2707"), g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    timeFont:setColor(ccc3(0x00,0xff,0x18))
    timeFont:setAnchorPoint(ccp(0,0.5))
    timeFont:setPosition(ccp(45,timeBg:getContentSize().height*0.5))
    timeBg:addChild(timeFont)
    -- 开始时间 --- 结束时间
    -- 开始时间
    local startTime = ActiveCache.getSpendStartTime()
    local startTimeStr = TimeUtil.getTimeToMin( tonumber(startTime) ) or " "
    -- 结束时间
    local endTime = ActiveCache.getSpendEndTime()
    local endTimeStr = TimeUtil.getTimeToMin( tonumber(endTime) ) or " "
    local timeStr = startTimeStr .. " —— " ..  endTimeStr
    local timeStr_font = CCRenderLabel:create( timeStr, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    timeStr_font:setColor(ccc3(0x00,0xff,0x18))
    timeStr_font:setAnchorPoint(ccp(0,0.5))
    timeStr_font:setPosition(ccp(timeFont:getPositionX()+timeFont:getContentSize().width+20,timeBg:getContentSize().height*0.5-2))
    timeBg:addChild(timeStr_font)

    -- 内容背景
    local downMenuSize = MenuLayer.getLayerFactSize()
    tableView_height = _bgLayer:getContentSize().height-topMenuHeight-_mineBg:getContentSize().height*g_fScaleX-downMenuSize.height-20*g_fScaleX
    print("tableView_height",tableView_height)
    tableView_bg = BaseUI.createContentBg(CCSizeMake(605,tableView_height/g_fScaleX))
    tableView_bg:setAnchorPoint(ccp(0.5,1))
    tableView_bg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-topMenuHeight-_mineBg:getContentSize().height*g_fScaleX))
    _bgLayer:addChild(tableView_bg)
    tableView_bg:setScale(g_fScaleX)

    -- 创建列表
    createTableViewList()

end

-- 创建列表
function createTableViewList( ... )
	local listData = ActiveCache.getDataByActiveId()
    print("listData +++ ")
    print_t(listData)
	require "script/ui/rechargeActive/ConsumeCell"
    local cellSize = CCSizeMake(588,197)
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif (fn == "cellAtIndex") then
            r = ConsumeCell.createCell( listData[a1+1] )
        elseif (fn == "numberOfCells") then
            r = #listData
        elseif (fn == "cellTouched") then
            -- print ("a1: ", a1, ", a2: ", a2)
            -- print ("cellTouched, index is: ", a1:getIdx())
        else
            -- print (fn, " event is not handled.")
        end
        return r
    end)

    _listTableView  = LuaTableView:createWithHandler(handler, CCSizeMake(588,tableView_height/g_fScaleX-2*g_fScaleX))
    _listTableView:setBounceable(true)
    _listTableView:setAnchorPoint(ccp(0, 0))
    _listTableView:setPosition(ccp(8, 1))
    tableView_bg:addChild(_listTableView)
    -- 设置单元格升序排列
    _listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    _listTableView:setTouchPriority(-132)
end


local function getConsumeActiveInfoCallBack( cbFlag, dictData, bRet )
    if(dictData.err == "ok") then
        print(GetLocalizeStringBy("key_1705"))
     
        ActiveCache.setConsumeServiceInfo( dictData.ret )

        -- 消费累积的数据
        _consumeInfo = ActiveCache.getConsumeServiceInfo()
        
        -- 初始化界面
        initConsumeLayer()
    end
end

-- 创建消费累积界面
function createConsumeLayer( ... )
	init()
	_bgLayer = CCLayer:create()

    -- 拉取消费累积数据
    Network.rpc(getConsumeActiveInfoCallBack, "spend.getInfo", "spend.getInfo", nil, true)
	return _bgLayer
end


-- 是否开启活动
function isOpenConsume( ... )
    local isOpen = false
    if(not table.isEmpty(ActivityConfigUtil.getDataByKey("spend"))) then
        isOpen = ActivityConfigUtil.isActivityOpen("spend")
    else
        isOpen = false
    end
    return isOpen
end































