-- Filename: MonthSignAlertGet.lua
-- Author: DJN
-- Date: 2014-10-18
-- Purpose: 该文件用于: 月签到领取后弹窗提示
----打算作为一个公共的方法，用于弹窗展示获取的奖品，调用接口的第二个参数为关闭页面后的回调

module ("MonthSignAlertGet", package.seeall)
require "script/audio/AudioUtil"

require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"
require "script/ui/rechargeActive/MonthSignLayer"
require "script/libs/LuaCCSprite"



local _bgLayer       --灰色背景屏蔽层
local _touchPriority --触摸优先级
local _ZOrder        --Z轴值
local layer_zOrder   --icon的Z轴值
local _info --奖励数据
local _closeCb       --关闭页面时候的回调函数
----------------------------------------初始化函数
local function init()
    _bgLayer       = nil
    _touchPriority = nil
    _ZOrder        = nil
    layer_zOrder = _ZOrder or 2100
    _info = nil
end
----------------------------------------触摸事件函数
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
   -- MonthSignLayer.createScrollView()
   if(_closeCb ~= nil)then
        _closeCb()
    end
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
   

end

----------------------------------------UI函数
--[[
    @des    :创建展示背景
    @param  :
    @return :
--]]
local function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(566,408)
    local bgScale = MainScene.elementScale
    
    --主黄色背景
    bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
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
    local labelTitle = CCLabelTTF:create(GetLocalizeStringBy("djn_67"), g_sFontPangWa,33)
    labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
    labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
    titleBg:addChild(labelTitle)

    --"恭喜主公获得"的底
    local str_line = CCScale9Sprite:create("images/common/line2.png")
    str_line:setContentSize(CCSizeMake(293,36))
    str_line:setAnchorPoint(ccp(0.5,0.5))
    str_line:setPosition(bgSprite:getContentSize().width*0.5,335)
    bgSprite:addChild(str_line)
    --“恭喜主公获得”的字
    local str = CCRenderLabel:create(GetLocalizeStringBy("key_1682"),g_sFontPangWa , 23, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
    str:setAnchorPoint(ccp(0.5,0.5))
    str:setColor(ccc3(0xff,0xf6,0x00))
    str:setPosition(str_line:getContentSize().width*0.5,str_line:getContentSize().height*0.5)
    str_line:addChild(str)


    
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
    -- 确定按钮
    local confirmBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(190, 73),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    confirmBtn:setAnchorPoint(ccp(0.5,0))
    confirmBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5,37))
    confirmBtn:registerScriptTapHandler(closeCb)
    bgMenu:addChild(confirmBtn)

    LuaCCSprite.runShowAction(bgSprite)

end

----------------------------------------创建奖励的TableView函数
--[[
    @des    :
    @param  :
    @return :
--]]

function loadTableView (...)

--      Table
-- (
-- Cocos2d: [LUA-print]     [1] => Table
--         (
-- Cocos2d: [LUA-print]             [type] => gold
-- Cocos2d: [LUA-print]             [num] => 10
-- Cocos2d: [LUA-print]             [tid] => gold,gold
-- Cocos2d: [LUA-print]         )
-- Cocos2d: [LUA-print]     [2] => Table
--         (
-- Cocos2d: [LUA-print]             [type] => item
-- Cocos2d: [LUA-print]             [num] => 1
-- Cocos2d: [LUA-print]             [tid] => 10041
-- Cocos2d: [LUA-print]         )
-- Cocos2d: [LUA-print]     [3] => Table
--         (
-- Cocos2d: [LUA-print]             [type] => item
-- Cocos2d: [LUA-print]             [num] => 1
-- Cocos2d: [LUA-print]             [tid] => 40031

    
    local full_rect = CCRectMake(0,0,61,47)
   -- local inset_rect = CCRectMake(30,30,15,15)
    local table_view_bg = CCScale9Sprite:create("images/copy/fort/textbg.png", full_rect)
    table_view_bg:setPreferredSize(CCSizeMake(510, 170))
    table_view_bg:setAnchorPoint(ccp(0.5, 0))
    table_view_bg:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 120))
    bgSprite:addChild(table_view_bg)
    
    local cell_icon_count = 4 
    local height = 150
    local cell_size = CCSizeMake(489, 150)

    local items = _info
    ----------奖励表格
    local h = LuaEventHandler:create(function(function_name, table_t, a1, cell)
        if function_name == "cellSize" then
            return cell_size
        elseif function_name == "cellAtIndex" then
            cell = CCTableViewCell:create()
            local start = a1 * cell_icon_count
            for i=1, 4 do
                local index = start + i
                if(index>cell_icon_count)then
                   line_num = math.ceil((index - cell_icon_count)/cell_icon_count)
                   height = height - 150 * line_num
                end  
                if index <= #items then
                    local iconSprite = ItemUtil.createGoodsIcon(items[index])
                    iconSprite:setAnchorPoint(ccp(0.5, 0.5))
                    iconSprite:setPosition(ccp(cell_size.width/cell_icon_count /2 + (i-1) * cell_size.width/cell_icon_count, height * 0.5))
                    cell:addChild(iconSprite)
                    
                end
            end
            return cell
        elseif function_name == "numberOfCells" then
            local count = #items
            return math.ceil(count / cell_icon_count )
        elseif function_name == "cellTouched" then
        elseif (function_name == "scroll") then
        end
    end)
    local item_table_view = LuaTableView:createWithHandler(h, CCSizeMake(500, 145))
    item_table_view:ignoreAnchorPointForPosition(false)
    item_table_view:setAnchorPoint(ccp(0.5, 0))
    item_table_view:setBounceable(true)
    item_table_view:setPosition(ccp(table_view_bg:getContentSize().width * 0.5, 15 ))
    item_table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    item_table_view:setTouchPriority(_touchPriority - 2)
    table_view_bg:addChild(item_table_view)
    
    return table_view_bg
end

----------------------------------------入口函数
--[[
    @des    :
    @param  :
    @return :
--]]
function showLayer(p_reward,p_closeCb,p_touchPriority,p_ZOrder)
     init()
        
        _touchPriority = p_touchPriority or -550
        _ZOrder = p_ZOrder or 999
        _info = p_reward
        _closeCb = p_closeCb
        -- print("数据结构")
        -- print_t(_info)

        _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
        _bgLayer:registerScriptHandler(onNodeEvent)
        local curScene = CCDirector:sharedDirector():getRunningScene()
        curScene:addChild(_bgLayer,_ZOrder)
        
        createBgUI()
        loadTableView()
    
    return _bgLayer

end






