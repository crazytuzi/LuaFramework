-- Filename: HorseLayer.lua
-- Author: llp
-- Date: 2016-3-31
-- Purpose: 马车主界面

module("HorseLayer", package.seeall)

require "db/DB_Mnlm_rule"
require "script/ui/horse/HorseController"
require "script/ui/horse/HorseInviteDialog"
require "script/ui/horse/CarryDialog"
require "script/ui/horse/HorseSprite"
require "db/DB_Switch"
local dbInfo = DB_Mnlm_rule.getDataById(1)
local _bgLayer          --触摸屏蔽层
local _curPageInfos         = {}    -- 当前所有

local _width                = 0
local Middle_Field_Type     = 2     -- 中级
local High_Field_Type       = 1     -- 高级
local Junior_Field_Type     = 3     -- 初级
local Low_Field_Type        = 4     -- 低级
local _curPage              = 1     -- 当前第几页
local _itemPerPage          = 6     -- 每页显示的条数
local _curFieldType         = 1     -- 当前是在普通还是高级
local _current_page         = 1
local _cell_width           = 90    -- 页数按钮的宽度
local kCarryTag             = 100
local kRobTag               = 101
local kHelpTag              = 102
local _updateTimeScheduler  = nil
local _updateNextTimeScheduler  = nil
local _nextlabel            = nil
local _curFieldButton       = nil   -- 当前区
local _fieldMenuBar         = nil
local _pageMenuBarBg        = nil   -- 分页的底
local _curPageBtn           = nil   -- 当前的分页
local _topBg                = nil
local _horseMenu            = nil   -- 马车专用Menu
local _funcBtn              = nil
local _timeLabel            = nil
local _curClick             = nil
local _menuPanel            = nil
local _functionMaksLayer    = nil
local _timePoint            = nil
local _curStart             = nil
local _curEnd               = nil
local _timeNumLabel         = nil
local _curClick             = nil
local _robLable             = nil
local _carryLabel           = nil
local _helpLabel            = nil
local _newCarInfo           = nil
local _xmlSprite            = nil
local _horseItemTable       = {}
local _selfInfo             = {}

local _page_menu_offset                         -- 滑动偏移量
local _page_scroll_view                         -- 页数的ScrollView
local _left_arrows                              -- 左边箭头
local _left_arrows_gray
local _right_arrows                             -- 右边箭头
local _right_arrows_gray
local _first_page_item                          -- 第一页的按钮
local _last_page_item                           -- 最后一页的按钮
local _timer_refresh_arrows                     -- 刷新箭头
local _push_robs
local _push_rob_node
local _isShowed
local _rob_node_scroll_view

local carTable = {
        "images/horse/car/green.png",
        "images/horse/car/blue.png",
        "images/horse/car/purple.png",
        "images/horse/car/red.png"
    }

local carBtnTable = {
        "images/horse/btn/green",
        "images/horse/btn/blue",
        "images/horse/btn/pur",
        "images/horse/btn/org"
    }
local horseColorTable = {
        ccc3(0, 0xeb, 0x21),
        ccc3(0x51, 0xfb, 0xff),
        ccc3(255, 0, 0xe1),
        ccc3(255, 0x84, 0)
    }

local _horseXPosTable = {0.17,0.39,0.61,0.83}
--[[
    @des    : 初始化
    @para   : 
    @return : 
 --]]
function init( ... )
    _width                = 0
    _xmlSprite            = nil
    _updateTimeScheduler  = nil
    _updateNextTimeScheduler  = nil
    _timeNumLabel         = nil
    _newCarInfo           = nil
    _timePoint            = nil
    _timeLabel            = nil
    _functionMaksLayer    = nil
    _menuPanel            = nil
    _bgLayer              = nil
    _funcBtn              = nil
    _horseMenu            = nil   -- 马车专用Menu
    _fieldMenuBar         = nil
    _topBg                = nil
    _nextlabel            = nil
    _pageMenuBarBg        = nil   -- 分页的底
    _curPageBtn           = nil   -- 当前的分页
    _curFieldButton       = nil   -- 当前区
    _curStart             = nil
    _curEnd               = nil
    _page_scroll_view     = nil                    -- 页数的ScrollView
    _left_arrows          = nil                    -- 左边箭头
    _left_arrows_gray     = nil
    _right_arrows         = nil                    -- 右边箭头
    _right_arrows_gray    = nil
    _first_page_item      = nil                    -- 第一页的按钮
    _last_page_item       = nil                    -- 最后一页的按钮
    _timer_refresh_arrows = nil                    -- 刷新箭头
    _rob_node_scroll_view = nil
    _robLable             = nil
    _carryLabel           = nil
    _helpLabel            = nil
    _push_rob_node = nil

    _curFieldType         = 1     -- 当前是在普通还是高级
    Middle_Field_Type     = 3     -- 中级
    High_Field_Type       = 4     -- 高级
    Junior_Field_Type     = 2     -- 初级
    Low_Field_Type        = 1     -- 低级
    _curPage              = 1     -- 当前第几页
    _itemPerPage          = 6     -- 每页显示的条数
    _current_page         = 1
    _cell_width           = 90        -- 页数按钮的宽度
    
    _horseItemTable       = {}
    _curPageInfos         = {}    -- 当前所有
    _selfInfo             = {}
    _push_robs    = {}
    
    _page_menu_offset     = ccp(0,0)                    -- 滑动偏移量
    
    _isShowed             = false
    
end

--[[
    @des    : 处理touches事件
    @para   : 
    @return : 
 --]]
function onTouchesHandler( eventType, x, y )
    return true
end

--[[
    @des    : 回调onEnter和onExit
    @para   : 
    @return : 
 --]]
function onNodeEvent( event )
    if ( event == "enter" ) then
        _isShowed = true
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,-431,true)
        _bgLayer:setTouchEnabled(true)
    elseif ( event == "exit" ) then
        _isShowed = false
        removeXmlSprite()
        if(_updateTimeScheduler~=nil)then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
            _updateTimeScheduler = nil
        end
        if(_updateNextTimeScheduler~=nil)then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateNextTimeScheduler)
            _updateNextTimeScheduler = nil
        end
        _bgLayer:unregisterScriptTouchHandler()
        stopTimerRefreshArrows()
        remove_push()
        _bgLayer = nil
        -- CCDirector:sharedDirector():printLuaStack()
    end
end

function startTimeScheduler()
    if(tolua.isnull(_bgLayer))then
        return
    end
    if(_updateTimeScheduler==nil) then
        -- 倒计时
        _updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 0, false)
        if(_doubleTimeLabel~=nil)then
            addXmlSprite()
            _doubleTimeLabel:setVisible(true)
        end
        if(_nextlabel~=nil)then
            _nextlabel:setVisible(false)
        end
    end
end

function stopTimeScheduler()
    if(_updateTimeScheduler~=nil)then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
        _updateTimeScheduler = nil
    end
    if(tolua.isnull(_bgLayer))then
        return
    end
    if(_doubleTimeLabel~=nil)then
        removeXmlSprite()
        _doubleTimeLabel:setVisible(false)
    end
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    performWithDelay(runningScene,startNextTimeScheduler,1)
end

function startNextTimeScheduler()
    if(tolua.isnull(_bgLayer))then
        return
    end
    if(_updateNextTimeScheduler==nil) then
        -- 倒计时
        _updateNextTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateStartTimer, 0, false)
        if(_nextlabel~=nil)then
            _nextlabel:setVisible(true)
        end
        if(_doubleTimeLabel~=nil)then
            removeXmlSprite()
            _doubleTimeLabel:setVisible(false)
        end
    end
end

function stopNextTimeScheduler()
    if(_updateNextTimeScheduler~=nil)then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateNextTimeScheduler)
        _updateNextTimeScheduler = nil
    end
    if(tolua.isnull(_bgLayer))then
        return
    end
    if(_nextlabel~=nil)then
        addXmlSprite()
        _nextlabel:setVisible(false)
    end
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    performWithDelay(runningScene,startTimeScheduler,1)
end

--[[
    @des    : 关闭自己
    @para   : 
    @return : 
--]]
local function closeAction(tag, itembtn)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    HorseController.leaveHorse(handleLeave)
end

function handleLeave(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    if _page_tip ~= nil then
        _page_tip:removeFromParentAndCleanup(true)
        _page_tip = nil
    end
    -- if(_updateTimeScheduler~=nil)then
    --     CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
    --     _updateTimeScheduler = nil
    -- end
    stopTimerRefreshArrows()
    local activeListr = ActiveList.createActiveListLayer()
    MainScene.changeLayer(activeListr, "activeListr")
end

function updateTime( ... )
    local timeInt = TimeUtil.getSvrTimeByOffset()
    local temp = os.date("*t", timeInt)
    local second = 59 - tonumber(temp.sec)
    local minute = 59 - tonumber(temp.min)
    if(temp.hour>=_timePoint[1] and temp.hour<_timePoint[2])then
        _curStart = _timePoint[1]
        _curEnd = _timePoint[2]
    elseif(temp.hour>=_timePoint[3] and temp.hour<_timePoint[4])then
        _curStart = _timePoint[3]
        _curEnd = _timePoint[4]
    end
    HorseData.setDouble(true)
    local hour = _curEnd - 1 - tonumber(temp.hour)
    if(hour==0 and minute==0 and second==0)then
        if(temp.hour>=_timePoint[2] and temp.hour<_timePoint[3])then
            _curStart = _timePoint[3]
            _curEnd = _timePoint[4]
        elseif(temp.hour>=_timePoint[4])then
            _curStart = _timePoint[1]+24
            _curEnd = _timePoint[2]+24
        end
        HorseData.setDouble(false)
        stopTimeScheduler()
    end
    if(second==0)then
        second="00"
    elseif(second<10)then
        second="0"..second
    end
    if(minute==0)then
        minute="00"
    elseif(minute<10)then
        minute="0"..minute
    end
    if(hour==0)then
        hour="00"
    elseif(hour<10)then
        hour="0"..hour
    end
    local str = hour..":"..minute..":"..second

    _timeNumLabel:setString(str)
end

function addXmlSprite( ... )
    -- body
    local bg = _bgLayer:getChildByTag(123)
    local carryBtn = CCMenuItemImage:create("images/horse/carry.png", "images/horse/carry.png")
    _xmlSprite = XMLSprite:create("images/horse/muniuliumaTX_huo/muniuliumaTX_huo")
    _xmlSprite:setPosition(ccp(bg:getContentSize().width*0.45*g_fBgScaleRatio+(_width*0.5-_doubleTimeLabel:getContentSize().width*0.5*g_fScaleX),bg:getContentSize().height*g_fBgScaleRatio-carryBtn:getContentSize().height*0.5*g_fScaleX-_doubleTimeLabel:getContentSize().height*0.5*g_fScaleX))
    bg:addChild(_xmlSprite)
end

function removeXmlSprite( ... )
    -- body
    if(_xmlSprite~=nil)then
        _xmlSprite:removeFromParentAndCleanup(true)
        _xmlSprite = nil
    end
end

function updateStartTimer( ... )
    -- body
    if(not tolua.isnull(_xmlSprite))then
        removeXmlSprite()
    end
    local timeInt = TimeUtil.getSvrTimeByOffset()
    local temp = os.date("*t", timeInt)
    local second = 59 - tonumber(temp.sec)
    local minute = 59 - tonumber(temp.min)
    if(temp.hour>=_timePoint[2] and temp.hour<_timePoint[3])then
        _curStart = _timePoint[3]
        _curEnd = _timePoint[4]
    elseif(temp.hour>=_timePoint[4])then
        _curStart = _timePoint[1]+24
        _curEnd = _timePoint[2]+24
    end
    local hour = _curStart - 1 - tonumber(temp.hour)
    HorseData.setDouble(false)
    if(hour==0 and minute==0 and second==0)then
        HorseData.setDouble(true)
        stopNextTimeScheduler()
    end
    if(second==0)then
        second="00"
    elseif(second<10)then
        second="0"..second
    end
    if(minute==0)then
        minute="00"
    elseif(minute<10)then
        minute="0"..minute
    end
    if(hour==0)then
        hour="00"
    elseif(hour<10)then
        hour="0"..hour
    end
    local str = hour..":"..minute..":"..second

    _timeNextNumLabel:setString(str)
end

function afterHorseClick( pData,pItem )
    -- body
    require "script/ui/horse/HorseInfoDialog"
    HorseInfoDialog.show(_curClick,pData,pItem)
end

function horseClick( tag,item )
    -- body
    _curClick = tag
    HorseController.lookHorse(tag,afterHorseClick,item)
end

function createHorse( pData )
    -- body
    local totalTime = dbInfo.time
    local servTime = BTUtil:getSvrTimeInterval()
    local pageMenuY = _pageMenuBarBg:getPositionY()+_pageMenuBarBg:getContentSize().height*g_fScaleX +_pageMenuBarBg:getContentSize().height*0.6*g_fScaleX
    local funcMenuY = _funcBtn:getPositionY()-_funcBtn:getContentSize().height*g_fScaleX
    local deltY = funcMenuY - pageMenuY
    for k,v in pairs(pData.page_info) do
        local horseData = {}
              horseData.uname = v.uname
              horseData.begin_time = v.begin_time
              horseData.leftStr = v.be_robbed_num.."/2"
              horseData.guildName = v.guild_name
              horseData.deltY = deltY
              horseData.uid = tonumber(v.uid)
              horseData.beginY = pageMenuY
              horseData.totalTime = totalTime
              horseData.zoneId = _curFieldType
              horseData.uid = tonumber(v.uid)
        local deltTime = (servTime - v.begin_time)/totalTime
        local horseItem = HorseSprite:create(horseData)
              horseItem:setPosition(ccp(_bgLayer:getContentSize().width*_horseXPosTable[tonumber(v.road_id)],deltY*deltTime+pageMenuY))
        _horseMenu:addChild(horseItem,1,tonumber(v.uid))
        horseItem:registerScriptTapHandler(horseClick)
        table.insert(_horseItemTable,horseItem)
    end
end

function freshPage( pData )
    -- body
    -- 刷区 页 道上的马 运送时间
    if(pData~=nil and pData.have_charge_dart~=nil)then
        local isHaveSelf = pData.have_charge_dart
        if(not isHaveSelf)then
            _curFieldType = High_Field_Type
        else
            _curFieldType = tonumber(pData.stage_id)
        end
        createBottomUI(pData)
    else

    end
    _horseItemTable = {}
    if(_horseMenu~=nil)then
        _horseMenu:removeAllChildrenWithCleanup(true)
        _horseMenu = nil
    end
    _horseMenu = CCMenu:create()
    _horseMenu:setTouchPriority(-1000)
    _horseMenu:setPosition(ccp(0,0))
    _bgLayer:addChild(_horseMenu)
    if(table.isEmpty(pData) or table.isEmpty(pData.page_info))then
        AnimationTip.showTip(GetLocalizeStringBy("llp_377"))
        return
    else
        createHorse(pData)
    end
end

function freshSinglePage( pData )
    _curFieldType = tonumber(pData.stage_id)
    -- if(tonumber(pData.page_id)==1)then
        createBottomUI(pData)
    -- end
    _horseItemTable = {}
    if(_horseMenu~=nil)then
        _horseMenu:removeAllChildrenWithCleanup(true)
        _horseMenu = nil
    end
    _horseMenu = CCMenu:create()
    _horseMenu:setTouchPriority(-1000)
    _horseMenu:setPosition(ccp(0,0))
    _bgLayer:addChild(_horseMenu)
    if(table.isEmpty(pData) or table.isEmpty(pData.page_info))then
        AnimationTip.showTip(GetLocalizeStringBy("llp_377"))
        return
    else
        createHorse(pData)
    end
end

function reduceHorseItemTable( pItem )
    -- body
    for k,v in pairs(_horseItemTable) do
        if(v==pItem)then
            table.remove(_horseItemTable,k)
            break
        end
    end
end

-- 请求某区某页
function sendDomainRequestBy( pZone,pPage )
    HorseController.lookZoneAndPageInfo(pZone,pPage)
end

---- 选区
function selectFieldAction( tag, itembtn )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    itembtn:selected()
    _page_menu_offset = ccp(0, 0)
    _page_scroll_view:setContentOffset(_page_menu_offset)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    if(_curFieldButton ~= itembtn ) then
        _curFieldButton:unselected()
        _curFieldButton = itembtn
        _curFieldButton:selected()
        _curFieldType = tag
        _current_page = 1
        sendDomainRequestBy( _curFieldType,_current_page )
    end
end

-- 选中哪一页
local function pageAction( tag, itembtn)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    _curPageBtn:setEnabled(true)
    if(_curPageBtn ~= itembtn) then
        _curPageBtn:unselected()
        _curPageBtn = itembtn
        _curPageBtn:setEnabled(false)
        sendDomainRequestBy( _curFieldType,tag )
        _current_page = tag
    end
end

function outFresh( ... )
    -- body
    if(not tolua.isnull(_bgLayer))then
        sendDomainRequestBy( _curFieldType,_current_page )
    end
end

function timerRefreshArrows(time)
    if(tolua.isnull(_bgLayer))then
        return
    end
    local offset = _page_scroll_view:getContentOffset()
    if offset.x >= 0 then
        _left_arrows:setVisible(false)
        _left_arrows_gray:setVisible(true)
    else
        _left_arrows_gray:setVisible(false)
        _left_arrows:setVisible(true)
    end
    if offset.x <= -_page_scroll_view:getContentSize().width + _page_scroll_view:getViewSize().width then
        _right_arrows:setVisible(false)
        _right_arrows_gray:setVisible(true)
    else
        _right_arrows_gray:setVisible(false)
        _right_arrows:setVisible(true)
    end
end

function startTimerRefreshArrows()
    if _timer_refresh_arrows == nil then
        _timer_refresh_arrows = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerRefreshArrows, 0, false)
    end
end

function stopTimerRefreshArrows()
    if _timer_refresh_arrows ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_timer_refresh_arrows)
        _timer_refresh_arrows = nil
    end
end

-- 分页
function curFieldByPage(pData)
    if(_pageMenuBarBg~=nil)then
        _pageMenuBarBg:removeFromParentAndCleanup(true)
        _pageMenuBarBg=nil
    end
    
    _pageMenuBarBg = CCScale9Sprite:create("images/common/bg/m_9s_bg.png")
    _pageMenuBarBg:setContentSize(CCSizeMake(640, 65))
    _pageMenuBarBg:setAnchorPoint(ccp(0.5, 0.5))
    _pageMenuBarBg:setScale(g_fScaleX)
    _pageMenuBarBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.13))
    _bgLayer:addChild(_pageMenuBarBg,1)

    local totalPageNum = dbInfo.pages
    local totalPages = math.ceil(totalPageNum/_itemPerPage)
    local curIndex = 1
    _curPage =  math.ceil(curIndex/_itemPerPage)
    local pageMenuBar = CCMenu:create()
          pageMenuBar:setPosition(ccp(0,0))
          pageMenuBar:setTouchPriority(-500)
    _pageMenuBarBg:addChild(pageMenuBar)

    local page_menu_layer = CCLayer:create()
    local menu = CCMenu:create()
    menu:setTouchPriority(-500)
    menu:setPosition(ccp(0, 0))
    page_menu_layer:addChild(menu)
    local start = (_curPage-1)*_itemPerPage
    local index_max = totalPageNum
    page_menu_layer:setContentSize(CCSizeMake(_cell_width * index_max, _pageMenuBarBg:getContentSize().height))
    for i = 1, index_max do
        local page_item = CCMenuItemImage:create("images/active/mineral/btn_page_n.png", "images/active/mineral/btn_page_h.png", "images/active/mineral/btn_page_h.png")
        menu:addChild(page_item)
        page_item:setAnchorPoint(ccp(1, 0.5))
        page_item:setPosition(ccp(90 * i - 10, _pageMenuBarBg:getContentSize().height * 0.5))
        page_item:registerScriptTapHandler(pageAction)
        page_item:setTag(i)
        local page_label = CCRenderLabel:create(i , g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        page_label:setAnchorPoint(ccp(0.5, 0.5))
        page_label:setColor(ccc3(0xff, 0xff, 0xff))
        page_label:setPosition(ccp(page_item:getContentSize().width * 0.5, page_item:getContentSize().height * 0.5))
        page_item:addChild(page_label)

        if tonumber(pData.page_id) == i then
            if(page_item.isSelected)then
                page_item:unselected()
            end
            page_item:selected()
            _curPageBtn = page_item
            page_item:setEnabled(false)
        end
    end
    _page_scroll_view = CCScrollView:create()
    _pageMenuBarBg:addChild(_page_scroll_view)
    _page_scroll_view:setDirection(kCCScrollViewDirectionHorizontal)
    _page_scroll_view:setViewSize(CCSizeMake(540, _pageMenuBarBg:getContentSize().height))
    _page_scroll_view:setContentSize(CCSizeMake(page_menu_layer:getContentSize().width, _pageMenuBarBg:getContentSize().height))
    _page_scroll_view:setTouchPriority(menu:getTouchPriority() - 10)
    _page_scroll_view:setPosition(ccp((_pageMenuBarBg:getContentSize().width - _page_scroll_view:getViewSize().width) * 0.5, 0))
    _page_scroll_view:setContainer(page_menu_layer)
    _page_scroll_view:setContentOffset(_page_menu_offset)

    _left_arrows = CCSprite:create("images/active/mineral/btn_left.png")
    _left_arrows:setAnchorPoint(ccp(0.5, 0.5))
    _left_arrows_gray = BTGraySprite:create("images/active/mineral/btn_left.png")
    _left_arrows_gray:setAnchorPoint(_left_arrows:getAnchorPoint())
    local left_arrows_position = ccp(28, _pageMenuBarBg:getContentSize().height * 0.5)
    _left_arrows:setPosition(left_arrows_position)
    _left_arrows_gray:setPosition(left_arrows_position)
    _pageMenuBarBg:addChild(_left_arrows)
    _pageMenuBarBg:addChild(_left_arrows_gray)
    _right_arrows = CCSprite:create("images/active/mineral/btn_right.png")
    _right_arrows:setAnchorPoint(_left_arrows:getAnchorPoint())
    _right_arrows_gray = BTGraySprite:create("images/active/mineral/btn_right.png")
    _right_arrows_gray:setAnchorPoint(_left_arrows:getAnchorPoint())
    local right_arrows_position = ccp(610, _pageMenuBarBg:getContentSize().height * 0.5)
    _right_arrows:setPosition(right_arrows_position)
    _right_arrows_gray:setPosition(right_arrows_position)
    _pageMenuBarBg:addChild(_right_arrows_gray)
    _pageMenuBarBg:addChild(_right_arrows)
    -------------------------------------------
    timerRefreshArrows()
    startTimerRefreshArrows()
end

---- 创建区域按钮
function createFieldButton( )
    if(_fieldMenuBar~=nil)then
        _fieldMenuBar:removeFromParentAndCleanup(true)
        _fieldMenuBar=nil
    end
    _fieldMenuBar = CCMenu:create()
    _fieldMenuBar:setPosition(ccp(0, 0))
    _fieldMenuBar:setTouchPriority(-500)
    _bgLayer:addChild(_fieldMenuBar)

    -- 中级
    local middleBtn = LuaCC.create9ScaleMenuItem("images/horse/purple1.png","images/horse/purple2.png",CCSizeMake(156, 71),GetLocalizeStringBy("llp_354"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    middleBtn:setScale(g_fScaleX)
    middleBtn:setAnchorPoint(ccp(0.5, 0.5))
    middleBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.62, _bgLayer:getContentSize().height*0.05))
    middleBtn:registerScriptTapHandler(selectFieldAction)
    _fieldMenuBar:addChild(middleBtn,1, Middle_Field_Type)

    -- 高级
    local highBtn = LuaCC.create9ScaleMenuItem("images/common/btn/org1.png","images/common/btn/org2.png",CCSizeMake(156, 71),GetLocalizeStringBy("llp_355"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    highBtn:setScale(g_fScaleX)
    highBtn:setAnchorPoint(ccp(0.5, 0.5))
    highBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.87, _bgLayer:getContentSize().height*0.05))
    highBtn:registerScriptTapHandler(selectFieldAction)
    _fieldMenuBar:addChild(highBtn,1,High_Field_Type)

    -- 初级
    local juniorBtn = LuaCC.create9ScaleMenuItem("images/horse/blue1.png","images/horse/blue2.png",CCSizeMake(156, 71), GetLocalizeStringBy("llp_353"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    juniorBtn:setScale(g_fScaleX)
    juniorBtn:setAnchorPoint(ccp(0.5, 0.5))
    juniorBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.38, _bgLayer:getContentSize().height*0.05))
    juniorBtn:registerScriptTapHandler(selectFieldAction)
    _fieldMenuBar:addChild(juniorBtn,1,Junior_Field_Type)

    -- 低级
    local lowBtn = LuaCC.create9ScaleMenuItem("images/horse/green1.png","images/horse/green2.png",CCSizeMake(156, 71), GetLocalizeStringBy("llp_352"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    lowBtn:setScale(g_fScaleX)
    lowBtn:setAnchorPoint(ccp(0.5, 0.5))
    lowBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.13, _bgLayer:getContentSize().height*0.05))
    lowBtn:registerScriptTapHandler(selectFieldAction)
    _fieldMenuBar:addChild(lowBtn,1,Low_Field_Type)

    -- todo

    if(_curFieldType == Middle_Field_Type) then
        _curFieldButton = middleBtn
    elseif _curFieldType == High_Field_Type then
        _curFieldButton = highBtn
    elseif _curFieldType == Junior_Field_Type then
        _curFieldButton = juniorBtn
    elseif(_curFieldType == Low_Field_Type )then
        _curFieldButton = lowBtn
    end
    if(_curFieldButton.isSelected)then
        _curFieldButton:unselected()
    end
    _curFieldButton:selected()
end

local function push_callback( cbFlag, dictData, bRet )
    if(dictData.err ~= "ok")then
        return
    end
    local userId = UserModel.getUserUid()
    local dictData = dictData.ret
    if(tonumber(dictData.uid)==userId)then
        _selfInfo.page_info = dictData
        _selfInfo.have_charge_dart="true"
        _selfInfo.begin_time = dictData.begin_time
        createSelfHorseItem(_selfInfo)
    end
    local totalTime = dbInfo.time
    local servTime = BTUtil:getSvrTimeInterval()
    local pageMenuY = _pageMenuBarBg:getPositionY()+_pageMenuBarBg:getContentSize().height*g_fScaleX +_pageMenuBarBg:getContentSize().height*0.6*g_fScaleX
    local funcMenuY = _funcBtn:getPositionY()-_funcBtn:getContentSize().height*g_fScaleX
    local deltY = funcMenuY - pageMenuY
    if(tonumber(dictData.stage_id) ==_curFieldType and tonumber(dictData.page_id) == _current_page)then
        local horseData = {}
              horseData.uname = dictData.uname
              horseData.begin_time = dictData.begin_time
              horseData.leftStr = dictData.be_robbed_num.."/2"
              horseData.guildName = dictData.guild_name
              horseData.deltY = deltY
              horseData.beginY = pageMenuY
              horseData.totalTime = totalTime
              horseData.zoneId = _curFieldType
              horseData.uid = tonumber(dictData.uid)
        local deltTime = (servTime - dictData.begin_time)/totalTime
        local horseItem = HorseSprite:create(horseData)
              horseItem:setPosition(ccp(_bgLayer:getContentSize().width*_horseXPosTable[tonumber(dictData.road_id)],deltY*deltTime+pageMenuY))
        _horseMenu:addChild(horseItem,1,tonumber(dictData.uid))
        horseItem:registerScriptTapHandler(horseClick)
        table.insert(_horseItemTable,horseItem)
    else
        return
    end
end

function pushFinish( cbFlag, dictData, bRet )
    -- body
    if(dictData.err ~= "ok")then
        return
    end
    local userId = UserModel.getUserUid()
    if(_curFieldType == tonumber(dictData.ret.stage_id) and tonumber(dictData.ret.page_id) == _current_page and tonumber(dictData.ret.uid)~=userId)then
        HorseController.lookZoneAndPageInfo(dictData.ret.stage_id,dictData.ret.page_id)
    end
    if(tonumber(dictData.ret.uid)==userId)then
        _selfInfo.have_charge_dart="false"
        createSelfHorseItem(_selfInfo)
    end
end

--推送
local function push_updatepit()
    Network.re_rpc(push_callback, "push.chargedart.newship", "push.chargedart.newship")
    Network.re_rpc(pushRobCallback, "push.chargedart.berobbed", "push.chargedart.berobbed")
    Network.re_rpc(pushFinish, "push.chargedart.finishbygold", "push.chargedart.finishbygold")
end

--取消推送
function remove_push()
    Network.remove_re_rpc("push.chargedart.newship")
    Network.remove_re_rpc("push.chargedart.berobbed")
    Network.remove_re_rpc("push.chargedart.finishbygold")
end

function pushRobCallback(cbFlag, dictData, bRet, pType)
    local typeStatus = pType or 2
    if dictData.err ~= "ok" then
        return
    end
    if(_curFieldType == tonumber(dictData.ret.stage_id) and tonumber(dictData.ret.page_id) == _current_page)then
        HorseController.lookZoneAndPageInfo(dictData.ret.stage_id,dictData.ret.page_id)
    end
    
    if _isShowed == true then
        dictData.ret.type = typeStatus
        table.insert(_push_robs, dictData.ret)
        showRobInfoNode()
    end
end

function showRobInfoNode()
    if #_push_robs == 0 then
        if _push_rob_node ~= nil then
            _push_rob_node:removeFromParentAndCleanup(true)
            _push_rob_node = nil
        end
        return
    end
    if _push_rob_node == nil then
        _push_rob_node = CCSprite:create("images/main/bulletin_bg.png")
        _bgLayer:addChild(_push_rob_node, 1000)
        _push_rob_node:setAnchorPoint(ccp(0.5, 1))
        _push_rob_node:setPosition(ccp(g_winSize.width * 0.5, _bgLayer:getContentSize().height - _funcBtn:getContentSize().height * _funcBtn :getScale()))
        _push_rob_node:setScale(g_fScaleX)
        _rob_node_scroll_view = CCScrollView:create()
        _push_rob_node:addChild(_rob_node_scroll_view)
        _rob_node_scroll_view:setPosition(ccp(14, 7))
        _rob_node_scroll_view:setViewSize(CCSizeMake(612, 20))
        _rob_node_scroll_view:setTouchEnabled(false)
    end
    local pushRobInfo = _push_robs[1]
    table.remove(_push_robs, 1)

    local horseNameTable = {GetLocalizeStringBy("llp_361"),GetLocalizeStringBy("llp_362"),GetLocalizeStringBy("llp_363"),GetLocalizeStringBy("llp_364")}
    local colors = {ccc3(0xff, 0, 0xe1), ccc3(26, 175, 84), ccc3(252, 13, 27)}
    local tipNodes = {}
    if(pushRobInfo.type==1)then
        tipNodes[1] = CCLabelTTF:create(pushRobInfo.uname, g_sFontName, 21)
        tipNodes[1]:setColor(ccc3(0x00,0xe4,0xff))
        tipNodes[2] = CCLabelTTF:create(GetLocalizeStringBy("llp_393"), g_sFontName, 21)
        tipNodes[3] = CCLabelTTF:create( horseNameTable[tonumber(pushRobInfo.stage_id)] , g_sFontName, 21)
        tipNodes[3]:setColor(horseColorTable[tonumber(pushRobInfo.stage_id)])
        tipNodes[4] = CCLabelTTF:create(GetLocalizeStringBy("llp_394"), g_sFontName, 21)
        tipNodes[5] = CCLabelTTF:create(pushRobInfo.page_id, g_sFontName, 21)
        tipNodes[6] = CCLabelTTF:create(GetLocalizeStringBy("llp_395"), g_sFontName, 21)
    else
        tipNodes[1] = CCLabelTTF:create(pushRobInfo.rob_uname, g_sFontName, 21)
        tipNodes[1]:setColor(ccc3(0x00,0xe4,0xff))
        tipNodes[2] = CCLabelTTF:create(GetLocalizeStringBy("llp_396"), g_sFontName, 21)
        tipNodes[3] = CCLabelTTF:create( pushRobInfo.uname , g_sFontName, 21)
        tipNodes[3]:setColor(ccc3(0x00,0xe4,0xff))
        tipNodes[4] = CCLabelTTF:create(horseNameTable[tonumber(pushRobInfo.stage_id)]..GetLocalizeStringBy("llp_397"), g_sFontName, 21)
        tipNodes[4]:setColor(horseColorTable[tonumber(pushRobInfo.stage_id)])
        tipNodes[5] = CCLabelTTF:create(GetLocalizeStringBy("llp_444"), g_sFontName, 21)
    end
    
    local node = BaseUI.createHorizontalNode(tipNodes)
    _rob_node_scroll_view:addChild(node, 10)
    node:setAnchorPoint(ccp(0, 0.5))
    node:setPosition(ccp(612, 10))
    local actionArray = CCArray:create()
    actionArray:addObject(CCMoveBy:create(10, ccp(-640 - node:getContentSize().width, 0)))
    actionArray:addObject(CCCallFunc:create(function ( ... )
        if(node~=nil)then
            node:removeFromParentAndCleanup(true)
            node = nil
            showRobInfoNode()
        end
    end))
    local seq =  CCSequence:create(actionArray)
    node:runAction(seq)
end

function funAction( tag,item )
    -- body
    if(_menuPanel:getScale()~=0) then
        _menuPanel:stopAllActions()
        local action = CCScaleTo:create(0.2, 0)
        _menuPanel:runAction(action)
        if(_functionMaksLayer) then
            _functionMaksLayer:removeFromParentAndCleanup(true)
        end
    else
        showFuctionMaskLayer()
        _menuPanel:stopAllActions()
        local action = CCScaleTo:create(0.2, 1 * MainScene.elementScale)
        _menuPanel:runAction(action)
    end
end

function showFuctionMaskLayer( ... )
    local touchRect = getSpriteScreenRect(_menuPanel)
    local layer = CCLayer:create()
    layer:setPosition(ccp(0, 0))
    layer:setAnchorPoint(ccp(0, 0))
    layer:setTouchEnabled(true)
    layer:setTouchPriority(-1300)
    layer:registerScriptTouchHandler(function ( eventType,x,y )
        if(eventType == "began") then
            if(touchRect:containsPoint(ccp(x,y))) then
                return false
            else
                _menuPanel:stopAllActions()
                local action = CCScaleTo:create(0.2, 0)
                _menuPanel:runAction(action)
                layer:removeFromParentAndCleanup(true)
                _functionMaksLayer = nil
                return true
            end
        end
    end,false, -1300, true)
    local gw,gh = g_winSize.width, g_winSize.height
    local layerColor = CCLayerColor:create(ccc4(0,0,0,layerOpacity or 150),gw,gh)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    layer:addChild(layerColor)
    _functionMaksLayer = layer
    local onRunningLayer = MainScene.getOnRunningLayer()
    onRunningLayer:addChild(layer,2500)
end

function showCurrentPageTip()
    if _page_tip ~= nil then
        _page_tip:removeFromParentAndCleanup(true)
        _page_tip = nil
    end
    _page_tip = CCSprite:create("images/active/mineral/page_tip_bg.png")
    _page_tip:setScale(g_fScaleX)
    _bgLayer:addChild(_page_tip, 10000)
    _page_tip:setAnchorPoint(ccp(0.5, 0.5))
    _page_tip:setPosition(g_winSize.width * 0.5, g_winSize.height * 0.5)
    local tip_lables = {}
    if _curFieldType == Low_Field_Type then
        tip_lables[1] = CCLabelTTF:create(GetLocalizeStringBy("llp_356"), g_sFontPangWa, 28)
        tip_lables[1]:setColor(ccc3(0x00, 0xeb, 0x21))
    elseif _curFieldType == Junior_Field_Type then
        tip_lables[1] = CCLabelTTF:create(GetLocalizeStringBy("llp_357"), g_sFontPangWa, 28)
        tip_lables[1]:setColor(ccc3(0xff, 0x00, 0xe1))
    elseif _curFieldType == Middle_Field_Type then
        tip_lables[1] = CCLabelTTF:create( GetLocalizeStringBy("llp_358"), g_sFontPangWa, 28)
        tip_lables[1]:setColor(ccc3(0xff, 0x00, 0xe1))
    elseif _curFieldType == High_Field_Type then
        tip_lables[1] = CCLabelTTF:create( GetLocalizeStringBy("llp_359"), g_sFontPangWa, 28)
        tip_lables[1]:setColor(ccc3(0xff, 0x00, 0xe1))
    end
    tip_lables[2] = CCLabelTTF:create(_current_page .. GetLocalizeStringBy("key_2763"), g_sFontPangWa, 28)
    tip_lables[2]:setColor(ccc3(0xff, 0xf6, 00))
    local page_tip_lable = CCSprite:create()
    _page_tip:addChild(page_tip_lable)
    page_tip_lable:setCascadeOpacityEnabled(true)
    local tip_width = 0
    for i = 1, #tip_lables do
        local label = tip_lables[i]
        page_tip_lable:addChild(label)
        label:setAnchorPoint(ccp(0, 0.5))
        label:setPosition(ccp(tip_width, tip_lables[1]:getContentSize().height * 0.5))
        tip_width = tip_width + label:getContentSize().width
    end
    page_tip_lable:setContentSize(CCSizeMake(tip_width, tip_lables[1]:getContentSize().height))
    page_tip_lable:setAnchorPoint(ccp(0.5, 0.5))
    page_tip_lable:setPosition(ccp(_page_tip:getContentSize().width * 0.5, _page_tip:getContentSize().height * 0.5 - 9))
    _page_tip:setCascadeOpacityEnabled(true)
    
    _page_tip:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCFadeOut:create(2)))
end

function desAction( ... )
    -- body
    _menuPanel:setScale(0)
    if(_functionMaksLayer) then
        _functionMaksLayer:removeFromParentAndCleanup(true)
    end
    require "script/ui/horse/HorseDesDialog"
    HorseDesDialog.show()
end

function battleInfoAction( ... )
    -- body
    _menuPanel:setScale(0)
    if(_functionMaksLayer) then
        _functionMaksLayer:removeFromParentAndCleanup(true)
    end
    require "script/ui/horse/RobBattleInforDialog"
    RobBattleInforDialog.show(-1000,1000,3)
end

function createTopUI( ... )
    --按钮Menu
    local btnMenuBar = CCMenu:create()
          btnMenuBar:setTouchPriority(-500)
          btnMenuBar:setPosition(ccp(0,0))

    -- 关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
          closeBtn:setPosition(ccp(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height))
          closeBtn:setAnchorPoint(ccp(1,1))
          closeBtn:setScale(g_fScaleX)
          closeBtn:registerScriptTapHandler(closeAction)
    btnMenuBar:addChild(closeBtn)

    -- 功能按钮
    _funcBtn = CCMenuItemImage:create("images/worldarena/gong_n.png", "images/worldarena/gong_h.png")
    _funcBtn:setScale(g_fScaleX)
    _funcBtn:setPosition(ccp(0,_bgLayer:getContentSize().height-_funcBtn:getContentSize().height*g_fScaleX))
    _funcBtn:setAnchorPoint(ccp(0,0))
    _funcBtn:setEnabled(false)
    _funcBtn:registerScriptTapHandler(funAction)
    btnMenuBar:addChild(_funcBtn,4000)

    _menuPanel = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
    _menuPanel:setContentSize(CCSizeMake(430,147))
    _menuPanel:setAnchorPoint(ccp(0, 1))
    _menuPanel:setPosition(ccp(_funcBtn:getContentSize().width*0.5*g_fScaleX, _bgLayer:getContentSize().height-_funcBtn:getContentSize().height*g_fScaleX*0.5))
    _bgLayer:addChild(_menuPanel, 3000, 1)
    _menuPanel:setScale(0)

    _menuPanelMenu = CCMenu:create()
    _menuPanelMenu:setAnchorPoint(ccp(0,0))
    _menuPanelMenu:setPosition(ccp(0,0))
    _menuPanel:addChild(_menuPanelMenu,1,1)
    _menuPanelMenu:setTouchPriority(-1400)

    -- 说明按钮
    local desBtn = LuaMenuItem.createItemImage("images/horse/des1.png", "images/horse/des2.png", desAction )
          desBtn:setAnchorPoint(ccp(0.5, 0.5))
          desBtn:setPosition(ccp(_menuPanel:getContentSize().width*0.23, _menuPanel:getContentSize().height*0.5))
    _menuPanelMenu:addChild(desBtn,4)

    -- 战报
    local battleInfoBtn = LuaMenuItem.createItemImage("images/horse/battleInfo1.png", "images/horse/battleInfo2.png", desAction )
    battleInfoBtn:setAnchorPoint(ccp(0.5, 0.5))
    battleInfoBtn:setPosition(ccp(_menuPanel:getContentSize().width*0.5, _menuPanel:getContentSize().height*0.44))
    _menuPanelMenu:addChild(battleInfoBtn,4)
    battleInfoBtn:registerScriptTapHandler(battleInfoAction)

    --运送按钮
    local carryMenu = CCMenu:create()
          carryMenu:setPosition(ccp(0,0))
          carryMenu:setTouchPriority(-1400)
    local carryBtn = CCMenuItemImage:create("images/horse/carry.png", "images/horse/carry.png")
          carryBtn:setPosition(ccp(_funcBtn:getContentSize().width*1.2*g_fScaleX,_funcBtn:getPositionY()))
          carryBtn:setAnchorPoint(ccp(0,0))
          carryBtn:registerScriptTapHandler(carryAction)
          carryBtn:setScale(g_fScaleX)
    carryMenu:addChild(carryBtn)
    _bgLayer:addChild(carryMenu,1000)
    _bgLayer:addChild(btnMenuBar,4000)

    local timeArry = string.split(dbInfo.doubletime,",")
    _timePoint = {}
    for k,v in pairs(timeArry)do
        local timeData = string.split(v,"|")
        for key,value in pairs(timeData)do
            local time = tonumber(value)/3600
            table.insert(_timePoint,tonumber(time))
        end
    end
    local cur_time = TimeUtil.getSvrTimeByOffset()
    local temp = os.date("*t", cur_time)

    _doubleTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_414") , g_sFontPangWa, 22, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _doubleTimeLabel:setAnchorPoint(ccp(0.5,1))
    _doubleTimeLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.45,_bgLayer:getContentSize().height-carryBtn:getContentSize().height*0.5*g_fScaleX))
    _doubleTimeLabel:setScale(g_fScaleX)
    _bgLayer:addChild(_doubleTimeLabel)

    _nextlabel = CCRenderLabel:create(GetLocalizeStringBy("llp_454") , g_sFontPangWa, 22, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _nextlabel:setAnchorPoint(ccp(0.5,1))
    _nextlabel:setPosition(ccp(_bgLayer:getContentSize().width*0.45,_bgLayer:getContentSize().height-carryBtn:getContentSize().height*0.5*g_fScaleX))
    _nextlabel:setScale(g_fScaleX)
    _bgLayer:addChild(_nextlabel)

    _timeNumLabel = CCLabelTTF:create("00:00:00", g_sFontPangWa, 22)
    _timeNumLabel:setColor(ccc3(0,0xff,0x18))
    _timeNumLabel:setAnchorPoint(ccp(0,0))
    _timeNumLabel:setPosition(ccp(_doubleTimeLabel:getContentSize().width,0))
    _doubleTimeLabel:addChild(_timeNumLabel)

    _width = _doubleTimeLabel:getContentSize().width*g_fScaleX + _timeNumLabel:getContentSize().width*g_fScaleX

    _timeNextNumLabel = CCLabelTTF:create("00:00:00", g_sFontPangWa, 22)
    _timeNextNumLabel:setColor(ccc3(0,0xff,0x18))
    _timeNextNumLabel:setAnchorPoint(ccp(0,0))
    _timeNextNumLabel:setPosition(ccp(_nextlabel:getContentSize().width,0))
    _nextlabel:addChild(_timeNextNumLabel)
    

    if(temp.hour>=_timePoint[1] and temp.hour<_timePoint[2])then
        _curEnd = _timePoint[2]
        startTimeScheduler()
        return
    elseif(temp.hour>=_timePoint[3] and temp.hour<_timePoint[4])then
        _curEnd = _timePoint[4]
        startTimeScheduler()
        return
    else
        stopTimeScheduler()
    end

    if(temp.hour<_timePoint[1])then
        _curStart = _timePoint[1]
        startNextTimeScheduler()
    elseif(temp.hour>=_timePoint[2] and temp.hour<=_timePoint[3])then
        _curStart = _timePoint[3]
        startNextTimeScheduler()
    elseif(temp.hour>=_timePoint[4])then
        _curStart = _timePoint[1]+24
        startNextTimeScheduler()
    else
        stopNextTimeScheduler()
    end
end

function buyCarryAction( ... )
    -- body
    local horseInfo = HorseData.gethorseInfo()
    local totalNum = horseInfo.shipping_num + horseInfo.rest_ship_num-dbInfo.free_transport-dbInfo.pay_transport
    if(totalNum==0)then
        AnimationTip.showTip(GetLocalizeStringBy("llp_416"))
        return
    end
    require "script/ui/horse/BuyCarryTimeDialog"
    BuyCarryTimeDialog.showBatchBuyLayer(kCarryTag)
end

function buyRobAction( ... )
    -- body
    local horseInfo = HorseData.gethorseInfo()
    local totalNum = horseInfo.rest_rob_num + horseInfo.rob_num-dbInfo.free_loot-dbInfo.pay_loot
    if(totalNum==0)then
        AnimationTip.showTip(GetLocalizeStringBy("llp_416"))
        return
    end
    require "script/ui/horse/BuyCarryTimeDialog"
    BuyCarryTimeDialog.showBatchBuyLayer(kRobTag)
end

function buyHelpAction( ... )
    -- body
    local horseInfo = HorseData.gethorseInfo()
    local totalNum = horseInfo.assistance_num + horseInfo.rest_assistance_num-dbInfo.free_assist-dbInfo.pay_assist
    if(totalNum==0)then
        AnimationTip.showTip(GetLocalizeStringBy("llp_416"))
        return
    end
    require "script/ui/horse/BuyCarryTimeDialog"
    BuyCarryTimeDialog.showBatchBuyLayer(kHelpTag)
end

function freshCarryNum( ... )
    -- body
    local horseInfo = HorseData.gethorseInfo()

    local str = GetLocalizeStringBy("llp_366")..horseInfo.rest_ship_num.."/"..dbInfo.free_transport
    _carryLabel:setString(str)
end

function freshRobNum( ... )
    -- body
    local horseInfo = HorseData.gethorseInfo()

    local str = GetLocalizeStringBy("llp_386")..horseInfo.rest_rob_num.."/"..dbInfo.free_loot
    _robLable:setString(str)
end

function freshHelpNum( ... )
    -- body
    local horseInfo = HorseData.gethorseInfo()

    local str = GetLocalizeStringBy("llp_415")..horseInfo.rest_assistance_num.."/"..dbInfo.free_assist
    _helpLabel:setString(str)
end

function createBottomUI( pData )
    -- 创建分页
    curFieldByPage(pData)
    -- 三个购买
    if(carryBg~=nil)then
        carryBg:removeFromParentAndCleanup(true)
        carryBg = nil
    end
    local carryBg = CCScale9Sprite:create("images/horse/bg.png")
    carryBg:setContentSize(CCSizeMake(_pageMenuBarBg:getContentSize().width*0.33,_pageMenuBarBg:getContentSize().height*0.6))
    carryBg:setAnchorPoint(ccp(0, 0))
    carryBg:setPosition(ccp(0, _pageMenuBarBg:getContentSize().height))
    _pageMenuBarBg:addChild(carryBg)
    local horseInfo = HorseData.gethorseInfo()
    _carryLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_366")..horseInfo.rest_ship_num.."/"..dbInfo.free_transport,g_sFontPangWa,25)
    _carryLabel:setAnchorPoint(ccp(0,0.5))
    
    carryBg:addChild(_carryLabel)

    local carryMenu = CCMenu:create()
          carryMenu:setTouchPriority(-500)
          carryMenu:setPosition(ccp(0,0))
    carryBg:addChild(carryMenu)
    local buyCarryNumItem = CCMenuItemImage:create("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png")
          buyCarryNumItem:setAnchorPoint(ccp(0.8,0.5))
          buyCarryNumItem:registerScriptTapHandler(buyCarryAction)
    carryMenu:addChild(buyCarryNumItem)
    carryBg:setContentSize(CCSizeMake(_pageMenuBarBg:getContentSize().width*0.27,buyCarryNumItem:getContentSize().height*2/3))
    buyCarryNumItem:setPosition(ccp(carryBg:getContentSize().width,carryBg:getContentSize().height*0.5))
    _carryLabel:setPosition(ccp(10,carryBg:getContentSize().height*0.5))
    if(robBg~=nil)then
        robBg:removeFromParentAndCleanup(true)
        robBg = nil
    end
    local robBg = CCScale9Sprite:create("images/horse/bg.png")
    robBg:setContentSize(CCSizeMake(_pageMenuBarBg:getContentSize().width*0.33,_pageMenuBarBg:getContentSize().height*0.6))
    -- robBg:ignoreAnchorPointForPosition(false)
    robBg:setAnchorPoint(ccp(0.5, 0))
    robBg:setPosition(ccp(_pageMenuBarBg:getContentSize().width*0.5, _pageMenuBarBg:getContentSize().height))
    _pageMenuBarBg:addChild(robBg)
    _robLable = CCLabelTTF:create(GetLocalizeStringBy("llp_386")..horseInfo.rest_rob_num.."/"..dbInfo.free_loot,g_sFontPangWa,25)
    _robLable:setAnchorPoint(ccp(0,0.5))

    robBg:addChild(_robLable)
    local robMenu = CCMenu:create()
          robMenu:setTouchPriority(-500)
          robMenu:setPosition(ccp(0,0))
    robBg:addChild(robMenu)
    local buyRobNumItem = CCMenuItemImage:create("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png")
          buyRobNumItem:setAnchorPoint(ccp(0.8,0.5))         
          buyRobNumItem:registerScriptTapHandler(buyRobAction)
    robMenu:addChild(buyRobNumItem)
    robBg:setContentSize(CCSizeMake(_pageMenuBarBg:getContentSize().width*0.27,buyRobNumItem:getContentSize().height*2/3))
    buyRobNumItem:setPosition(ccp(robBg:getContentSize().width,carryBg:getContentSize().height*0.5))
    _robLable:setPosition(ccp(10,carryBg:getContentSize().height*0.5))

    if(helpBg~=nil)then
        helpBg:removeFromParentAndCleanup(true)
        helpBg = nil
    end
    local helpBg = CCScale9Sprite:create("images/horse/bg.png")
    helpBg:setContentSize(CCSizeMake(_pageMenuBarBg:getContentSize().width*0.33,_pageMenuBarBg:getContentSize().height*0.6))
    -- helpBg:ignoreAnchorPointForPosition(false)
    helpBg:setAnchorPoint(ccp(1, 0))
    helpBg:setPosition(ccp(_pageMenuBarBg:getContentSize().width, _pageMenuBarBg:getContentSize().height))
    _pageMenuBarBg:addChild(helpBg)

    _helpLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_415")..horseInfo.rest_assistance_num.."/"..dbInfo.free_assist,g_sFontPangWa,25)
    _helpLabel:setAnchorPoint(ccp(0,0.5))

    helpBg:addChild(_helpLabel)

    local helpMenu = CCMenu:create()
          helpMenu:setTouchPriority(-500)
          helpMenu:setPosition(ccp(0,0))
    helpBg:addChild(helpMenu)
    local buyHelpNumItem = CCMenuItemImage:create("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png")
          buyHelpNumItem:setAnchorPoint(ccp(0.8,0.5))
          buyHelpNumItem:registerScriptTapHandler(buyHelpAction)
    helpMenu:addChild(buyHelpNumItem)
    helpBg:setContentSize(CCSizeMake(_pageMenuBarBg:getContentSize().width*0.27,buyHelpNumItem:getContentSize().height*2/3))
    buyHelpNumItem:setPosition(ccp(helpBg:getContentSize().width,carryBg:getContentSize().height*0.5))
    _helpLabel:setPosition(ccp(10,carryBg:getContentSize().height*0.5))

    local menu = CCMenu:create()
          menu:setPosition(ccp(0,0))
          menu:setTouchPriority(-500)
    helpBg:addChild(menu)

    local isShow = HorseData.isHaveInvite()
    if(isShow)then
        local item =  CCMenuItemImage:create("images/horse/invite.png", "images/horse/invite.png")
              item:setAnchorPoint(ccp(1,0))
              item:setPosition(ccp(helpBg:getContentSize().width,helpBg:getContentSize().height))
              item:registerScriptTapHandler(inviteAction)

        local newAnimSprite = XMLSprite:create("images/horse/mnlm_yao/mnlm_yao")
        newAnimSprite:setPosition(ccpsprite(0.5, 0.5, item))
        newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
        item:addChild(newAnimSprite,-1)
        menu:addChild(item)
    end
    -- 创建区域按钮
    createFieldButton()
end

function inviteAction( ... )
   require "script/ui/horse/HorseReceiveInviteLayer"
   HorseReceiveInviteLayer.showLayer(nil,-1000,1000)
end

function carryAction( ... )
    -- body
    local data = HorseData.gethorseInfo()
    if(data.have_charge_dart=="false" or data.have_charge_dart==false)then
        CarryDialog.show(-1500, 1000, nil)
    else
        AnimationTip.showTip(GetLocalizeStringBy("llp_450"))
    end
end

local function freshHorse()
    if(table.count(_horseItemTable)==0)then
        return
    end
    for k,v in pairs(_horseItemTable) do
        tolua.cast(v,"HorseSprite")
        v:fresh()
    end
end

local function freshHorseTimer( ... )
    -- body
    local layerActionArray = CCArray:create()
    layerActionArray:addObject(CCDelayTime:create(0.1))
    layerActionArray:addObject(CCCallFunc:create(freshHorse))
    local action_2 = CCRepeatForever:create(CCSequence:create(layerActionArray))
    _bgLayer:runAction(action_2)
end

function freshSelfTime( ... )
    -- body
    if(_selfInfo.begin_time + dbInfo.time<=BTUtil:getSvrTimeInterval())then
        _timeLabel:stopAllActions()
        _timeLabel:setString("")
    else
        local time_str = TimeUtil.getTimeString( (_selfInfo.begin_time + dbInfo.time - BTUtil:getSvrTimeInterval()))
        _timeLabel:setString(time_str)
    end
end

function menuPanelItemClick( ... )
    -- body
    _menuPanel:setScale(0)
    if(_functionMaksLayer) then
        _functionMaksLayer:removeFromParentAndCleanup(true)
    end
    if(_selfInfo.stage_id~=nil and _selfInfo.page_id~=nil)then
        HorseController.lookZoneAndPageInfo(_selfInfo.stage_id,_selfInfo.page_id)
    else
        HorseController.lookZoneAndPageInfo(_selfInfo.page_info.stage_id,_selfInfo.page_info.page_id)
    end
end

function tipAction( ... )
    -- body
    AnimationTip.showTip(GetLocalizeStringBy("llp_443"))
end

function createSelfHorseItem( pData )
    -- body
    if(tolua.isnull(_bgLayer))then
        return
    end
    _funcBtn:setEnabled(true)
    local haveHorse = pData.have_charge_dart
    if(_menuPanelMenu:getChildByTag(4))then
        _menuPanelMenu:getChildByTag(4):setVisible(false)
        _menuPanelMenu:removeChildByTag(4,true)
    end
    if(haveHorse=="false" or haveHorse==false)then
        local desBtn = LuaMenuItem.createItemImage("images/horse/btn/green2.png", "images/horse/btn/green1.png", nil )
        desBtn:registerScriptTapHandler(tipAction)
        desBtn:setAnchorPoint(ccp(0.5, 0.5))
        desBtn:setPosition(ccp(_menuPanel:getContentSize().width*0.85, _menuPanel:getContentSize().height*0.544))
        _menuPanelMenu:addChild(desBtn,4,4)
    else
        local desBtn = nil
        if(pData.stage_id~=nil)then
            desBtn = LuaMenuItem.createItemImage(carBtnTable[tonumber(pData.stage_id)].."2.png", carBtnTable[tonumber(pData.stage_id)].."1.png", menuPanelItemClick )
        else
            desBtn = LuaMenuItem.createItemImage(carBtnTable[tonumber(pData.page_info.stage_id)].."2.png", carBtnTable[tonumber(pData.page_info.stage_id)].."1.png", menuPanelItemClick )
        end
        desBtn:setAnchorPoint(ccp(0.5, 0.5))
        desBtn:setPosition(ccp(_menuPanel:getContentSize().width*0.85, _menuPanel:getContentSize().height*0.56))
        _menuPanelMenu:addChild(desBtn,4,4)
        local begin_time = 0
        local uid = UserModel.getUserUid()
        for k,v in pairs(pData.page_info)do
            if(tonumber(v.uid)==uid)then
                _selfInfo.page_info = v
                _selfInfo.begin_time = v.begin_time
                _selfInfo.stage_id = pData.stage_id
                _selfInfo.page_id = pData.page_id
                break
            end
        end
        _timeLabel = CCLabelTTF:create("00:00:00", g_sFontName, 23)
        _timeLabel:setColor(ccc3(0x00, 0xff, 0x18))
        _timeLabel:setAnchorPoint(ccp(0.5, 1))
        _timeLabel:setPosition(ccp(desBtn:getContentSize().width*0.5, 0))
        desBtn:addChild(_timeLabel)

        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(1))
        layerActionArray:addObject(CCCallFunc:create(freshSelfTime))
        local action_2 = CCRepeatForever:create(CCSequence:create(layerActionArray))
        _timeLabel:runAction(action_2)
    end
end

--[[
    @des    : 创建UI
    @param  :
    @return :
--]]
function createUI( ... )
    -- bg
    local bgSp = CCSprite:create("images/horse/mnlmbg.jpg")
          bgSp:setAnchorPoint(ccp(0.5,0.5))
          bgSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
          bgSp:setScale(g_fBgScaleRatio)
    _bgLayer:addChild(bgSp,0,123)

    _horseMenu = CCMenu:create()
    _horseMenu:setTouchPriority(-1000)
    _horseMenu:setPosition(ccp(0,0))
    _bgLayer:addChild(_horseMenu)

    local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/horse/muniuliumatx/muniuliumatx"), -1,CCString:create(""));
    spellEffectSprite:retain()
    spellEffectSprite:setPosition(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * 0.5)
    _bgLayer:addChild(spellEffectSprite);
    spellEffectSprite:release()

    createTopUI()
    
    freshHorseTimer()

    HorseController.enterHorse()
    --监听新车，被掠夺
    push_updatepit()
end

function showLayer( ... )
    -- body
    if not DataCache.getSwitchNodeState(ksSwitchMnlm) then
        return
    end
    -- 背包满了
    if(ItemUtil.isBagFull() == true )then
        return
    end
    require "script/ui/horse/HorseLayer"
    local layer = createLayer()
    MainScene.setMainSceneViewsVisible(false,false,false)
    MainScene.changeLayer(layer,"HorseLayer")
end

function createLayer( ... )
    -- body
    init()
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    createUI()
    return _bgLayer
end