-- FileName: RivalChariotLayer.lua 
-- Author: lgx
-- Date: 2016-07-06
-- Purpose: 查看对方阵容 战车界面 

module("RivalChariotLayer", package.seeall)

require "script/ui/active/RivalInfoData"
require "script/ui/chariot/ChariotMainData"
require "script/ui/chariot/ChariotUtil"
require "script/ui/chariot/ChariotDef"
require "script/ui/chariot/ChariotEquipCell"

local _touchPriority    = nil -- 触摸优先级
local _zOrder           = nil -- 显示层级
local _bgLayer          = nil -- 背景层
local _leftArrowSp      = nil -- 左箭头
local _rightArrowSp     = nil -- 右箭头
local _chariotTabView   = nil -- 战车tabView

--[[
    @desc   : 初始化方法
    @param  : 
    @return : 
--]]
local function init()
    _touchPriority   = nil
    _zOrder          = nil
    _bgLayer         = nil
    _leftArrowSp     = nil
    _rightArrowSp    = nil
    _chariotTabView  = nil
end

--[[
    @desc   : 背景层触摸回调
    @param  : eventType 事件类型 x,y 触摸点
    @return : 
--]]
local function layerToucCallback( eventType, x, y )
    return true
end

--[[
    @desc   : 回调onEnter和onExit事件
    @param  : event 事件名
    @return : 
--]]
function onNodeEvent( event )
    if (event == "enter") then
        _bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,false)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then
        _bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
    end
end

--[[
    @desc   : 创建Layer及UI
    @param  : pSize 层大小
    @param  : pTouchPriority 触摸优先级
    @param  : pZorder 显示层级
    @return : CCLayer 背景层
--]]
function createLayer( pSize, pTouchPriority, pZorder )
    -- 初始化
    init()

    _touchPriority = pTouchPriority or -1000
    _zOrder = pZorder or 500

    -- 背景层
    local bgSize = pSize or CCSizeMake(640,568)
    _bgLayer = CCLayer:create()
    _bgLayer:setPosition(ccp(0, 0))
    _bgLayer:registerScriptHandler(onNodeEvent)
    _bgLayer:setContentSize(bgSize)
    _bgLayer:setAnchorPoint(ccp(0, 0))

    -- 背景图
    local bgSprite = CCSprite:create("images/chariot/main_bg.png")
    bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,0)
    bgSprite:setAnchorPoint(ccp(0.5,0))
    bgSprite:setScaleX(bgSize.width/bgSprite:getContentSize().width)
    bgSprite:setScaleY(bgSize.height/bgSprite:getContentSize().height)
    _bgLayer:addChild(bgSprite)

    -- 黑烟特效
    local effectSprite = XMLSprite:create("images/chariot/effect/bgzhanche/bgzhanche")
    effectSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
    effectSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(effectSprite,5)

    local chariotArr = RivalInfoData.getChariotInfo()

    if (table.isEmpty(chariotArr)) then
        -- 未装备
        local emptyLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1092"), g_sFontPangWa, 30,1, ccc3(0x00,0x00,0x00),type_stroke)
        emptyLabel:setColor(ccc3(0x82,0x82,0x82))
        emptyLabel:setAnchorPoint(ccp(0.5, 0.5))
        emptyLabel:setPosition(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5+50*g_fElementScaleRatio)
        _bgLayer:addChild(emptyLabel,5)
    else
        -- 创建战车列表
        createChariotListWithInfo(chariotInfo)
    end

    return _bgLayer
end

--[[
    @desc   : 创建战车列表UI
    @param  : pArrChatiot 战车信息
    @return : 
--]]
function createChariotListWithInfo( pArrChatiot )
    local posNum = ChariotMainData.getCanEquipPosNum()
    -- 位置大于 1 ，才创建滑动提示箭头
    if (posNum > 1) then
        -- 左箭头 
        _leftArrowSp = CCSprite:create("images/formation/btn_left.png")
        _leftArrowSp:setAnchorPoint(ccp(0,0.5))
        _leftArrowSp:setPosition(0,_bgLayer:getContentSize().height*0.5)
        _bgLayer:addChild(_leftArrowSp,5)
        _leftArrowSp:setVisible(false)
        ChariotUtil.runArrowAction(_leftArrowSp)

        -- 右箭头 
        _rightArrowSp = CCSprite:create("images/formation/btn_right.png")
        _rightArrowSp:setAnchorPoint(ccp(1,0.5))
        _rightArrowSp:setPosition(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height*0.5)
        _bgLayer:addChild(_rightArrowSp,5)
        _rightArrowSp:setVisible(true)
        ChariotUtil.runArrowAction(_rightArrowSp)
    end

    -- 创建战车滑动列表
    local tabViewSize = CCSizeMake(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height)
    local eventHandler = function ( functionName, tableView, index, cell )
        if functionName == "cellSize" then
            return tabViewSize
        elseif functionName == "cellAtIndex" then
            local chariotInfo = RivalInfoData.getChariotInfoByPos(index)
            local tCell = ChariotEquipCell.createCell(ChariotDef.kCellShowTypeRival,chariotInfo,index,tabViewSize,_touchPriority)
            return tCell
        elseif functionName == "numberOfCells" then
            return posNum
        elseif functionName == "cellTouched" then
            
        elseif functionName == "scroll" then
            
        elseif functionName == "moveEnd" then
            -- 更新箭头
            updateArrowShowSttus(index)
        end
    end
    -- 战车tabView
    _chariotTabView = STTableView:create()
    _chariotTabView:setDirection(kCCScrollViewDirectionHorizontal)
    _chariotTabView:setContentSize(tabViewSize)
    _chariotTabView:setEventHandler(eventHandler)
    -- _chariotTabView:setPageViewEnabled(true)
    _chariotTabView:setPageViewEnabled((posNum > 1))
    _chariotTabView:setTouchPriority(_touchPriority - 10)
    _bgLayer:addChild(_chariotTabView,10)
    _chariotTabView:reloadData()
end

--[[
    @desc   : 更新箭头显示状态
    @param  : pIndex 当前位置
    @return :
--]]
function updateArrowShowSttus( pIndex )
    -- 根据当前的显示的位置,更新箭头显示
    local posNum = ChariotMainData.getCanEquipPosNum()
    if (posNum > 1) then
        if (pIndex == 1) then 
            _leftArrowSp:setVisible(false)
            _rightArrowSp:setVisible(true)
        elseif (pIndex == posNum) then 
            _leftArrowSp:setVisible(true)
            _rightArrowSp:setVisible(false)
        else
            _leftArrowSp:setVisible(true)
            _rightArrowSp:setVisible(true)
        end
    end
end
