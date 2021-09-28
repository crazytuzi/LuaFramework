-- FileName: OneKeyRobDialog.lua
-- Author: lichenyang
-- Date: 14-10-11
-- Purpose: 一键夺宝


module("OneKeyRobDialog", package.seeall)

require "script/ui/treasure/oneKeyRob/OneKeyRobData"
local _bgLayer       --灰色背景屏蔽层
local _touchPriority --触摸优先级
local _ZOrder        --Z轴值
local m_QuickRobInfo --连续抢夺结果数据
local _showIndex
local _autoSelectBtn --自动抽取按钮
local _btnTitle     
local _treasureId
function init()
    _bgLayer       = nil
    _touchPriority = nil
    _ZOrder        = nil
    m_QuickRobInfo = nil
    _showIndex     = 1
    _autoSelectBtn = nil
    _btnTitle      = nil
    _treasureId    = nil
end

--[[
    @des:入口函数
--]]
function showLayer(p_touchPriority,p_ZOrder, pTreasureId)
    init()
    _treasureId = pTreasureId
    _touchPriority = p_touchPriority or -499
    _ZOrder = p_ZOrder or 999
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder)
    createBgUI()

    return _bgLayer
end

--[[
    @des:触摸事件函数
--]]
function onTouchesHandler(eventType,x,y)
    if eventType == "began" then
        print("onTouchesHandler,began")
        return true
    elseif eventType == "moved" then
        print("onTouchesHandler,moved")
    else
        print("onTouchesHandler,else")
    end
end

function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end
--[[
    @des    :关闭按钮回调
    @param  :
    @return :
--]]
function closeMenuCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _bgLayer then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
    require "script/ui/treasure/oneKeyRob/OneKeyRobRewardLayer"
    OneKeyRobRewardLayer.showLayer()
end

--[[
    @des    :抽取按钮回调
    @param  :
    @return :
--]]
function lotteryMenuCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    QuickRobRewardLayer.showLayer()
end

--[[
    @des    :创建结算背景
    @param  :
    @return :
--]]
function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(593,730)
    local bgScale = MainScene.elementScale
    
    --主黄色背景
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
    bgSprite:setScale(bgScale)
    _bgLayer:addChild(bgSprite)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
    titlePanel:setAnchorPoint(ccp(0.5, 0.5))
    titlePanel:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height-6.6 ))
    bgSprite:addChild(titlePanel)
    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lcyx_1981"), g_sFontPangWa, 33)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
    titlePanel:addChild(titleLabel)

    --二级棕色背景
    require "script/utils/BaseUI"
    secondBgSprite = BaseUI.createContentBg(CCSizeMake(515,561))
    secondBgSprite:setAnchorPoint(ccp(0.5, 0))
    secondBgSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, 121))
    bgSprite:addChild(secondBgSprite)
    
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)

    _autoSelectBtn = CCMenuItemImage:create("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png","images/common/btn/btn_hui.png")
    _autoSelectBtn:setAnchorPoint(ccp(0.5,0))
    _autoSelectBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5,25))
    _autoSelectBtn:registerScriptTapHandler(closeMenuCallBack)
    bgMenu:addChild(_autoSelectBtn)

                    -- CCRenderLabel:create( petInfo.roleName , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _btnTitle = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1990"),g_sFontPangWa,35,1, ccc3(0x00, 0x00, 0x00), type_stroke)
    _btnTitle:setColor(ccc3(0xff, 0xe4, 0x00))
    _btnTitle:setAnchorPoint(ccp(0.5, 0.5))
    _btnTitle:setPosition(ccpsprite(0.5, 0.5, _autoSelectBtn))
    _autoSelectBtn:addChild(_btnTitle, 5)

    createRankTabView()
end

--[[
    @des    :创建tabelView
    @param  :
    @return :
--]]
function createRankTabView( ... )
    tableView_hight = secondBgSprite:getContentSize().height
    tableView_width = secondBgSprite:getContentSize().width
    -- 显示单元格背景的size
    local cell_bg_size = { width = tableView_width, height = 110 } 
    require "script/ui/treasure/oneKeyRob/OneKeyRobCell"
    m_QuickRobInfo = {}
    table.insert(m_QuickRobInfo, OneKeyRobData.getCardInfo().detail[_showIndex])
    printTable("m_QuickRobInfo", m_QuickRobInfo)
    local handler = LuaEventHandler:create(function(fn, t1, a1, a2)
        local r
        if (fn == "cellSize") then
            r = CCSizeMake(cell_bg_size.width , cell_bg_size.height)   
        elseif (fn == "cellAtIndex") then
            a2 = OneKeyRobCell.createCell(m_QuickRobInfo[a1+1],a1+1)
            r=a2
        elseif (fn == "numberOfCells") then
            return table.count(m_QuickRobInfo) + 1
        end
        return r
    end)
    m_rankTableView = LuaTableView:createWithHandler(handler, CCSizeMake(tableView_width,tableView_hight))
    m_rankTableView:setBounceable(true)
    m_rankTableView:setAnchorPoint(ccp(0, 0))
    m_rankTableView:setPosition(ccp(0,0))
    secondBgSprite:addChild(m_rankTableView)
    m_rankTableView:setTouchEnabled(false)
    -- 设置单元格升序排列
    m_rankTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    m_rankTableView:setTouchPriority(_touchPriority-1)
    performWithDelay(m_rankTableView, showNextCell, 1)
    _autoSelectBtn:setEnabled(false)
    _btnTitle:setColor(ccc3(100, 100, 100))
end

function showNextCell()
    if _showIndex < table.count(OneKeyRobData.getCardInfo().detail) then
        _showIndex = _showIndex + 1
        table.insert(m_QuickRobInfo, OneKeyRobData.getCardInfo().detail[_showIndex])
        m_rankTableView:reloadData()
        performWithDelay(m_rankTableView, showNextCell, 0.15)
        if m_rankTableView:getContentSize().height > m_rankTableView:getViewSize().height then
            m_rankTableView:setContentOffset(ccp(0, -110))
        end
    else
        _autoSelectBtn:setEnabled(true)
        _btnTitle:setColor(ccc3(0xff, 0xe4, 0x00))
        m_rankTableView:setTouchEnabled(true)
        if m_rankTableView:getContentSize().height > m_rankTableView:getViewSize().height then
            m_rankTableView:setContentOffset(ccp(0, 0))
        end
    end
end

function getRobTreasureId()
    return _treasureId
end
