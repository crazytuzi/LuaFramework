-- Filename: GodRewardPreview.lua
-- Author: DJN
-- Date: 2014-12-23
-- Purpose: 神兵排行奖励预览

module("GodRewardPreview", package.seeall)
require "script/audio/AudioUtil"
require "script/ui/godweapon/godweaponRank/GodRewardCell"
require "db/DB_Overcome_reward"

local _touchPriority    --触摸优先级
local _ZOrder           --Z轴
local _bgLayer          --触摸屏蔽层


----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil 
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
        print("moved")
    else
        print("end")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end


----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建背景UI
    @param  :
    @return :
--]]
function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(620,840)
    local bgScale = MainScene.elementScale

    --主背景图
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
    bgSprite:setScale(bgScale)
    _bgLayer:addChild(bgSprite)

    --标题背景
    local titleSprite = CCSprite:create("images/common/viewtitle1.png")
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
    bgSprite:addChild(titleSprite)
    
    --标题
    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2295"), g_sFontPangWa, 30)  
    titleLabel:setColor(ccc3(0xff,0xe4,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
    titleSprite:addChild(titleLabel)

    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)
    --关闭按钮
    local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png","images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)
    --后端拉回的发奖时间信息
    local timeStamp = UserModel.getTimeConfig("pass")
    --开始发奖的时间点
    local beganTime = timeStamp.handsOffBeginTime
    beganTime = TimeUtil.getTimeString(beganTime) or " "
    local richInfo = {lineAlignment = 2,elements = {}}
        richInfo.elements[1] = { 
                text = GetLocalizeStringBy("djn_120"),
                font = g_sFontPangWa,
                size = 25,
                color = ccc3(0x78,0x25,0x00)}
        richInfo.elements[2] = {
                text = beganTime,
                font = g_sFontPangWa,
                size = 25,
                color = ccc3(0x00,0x6d,0x2f)}
        richInfo.elements[3] = {
                text = GetLocalizeStringBy("djn_122"),
                font = g_sFontPangWa,
                size = 25,
                color = ccc3(0x78,0x25,0x00)}
    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0.5,0.5))
    midSp:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height*0.9))
    bgSprite:addChild(midSp)
  
    createTableView(bgSprite)  
end

-----------创建中间奖励的tableview
function createTableView( layer )

    local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    tableBackground:setContentSize(CCSizeMake(575, 670))
    tableBackground:setAnchorPoint(ccp(0.5, 0))
    tableBackground:setPosition(ccp(layer:getContentSize().width*0.5, 50))
    layer:addChild(tableBackground)

    
    local  function rewardTableCallback(fn, t_table, a1, a2)
        local cellNum = table.count(DB_Overcome_reward.Overcome_reward)
        print("cellNum",cellNum)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(568, 217)
        elseif fn == "cellAtIndex" then
            a2 = GodRewardCell.create(DB_Overcome_reward.getDataById(a1+1))
            r = a2
        elseif fn == "numberOfCells" then
            r = cellNum
            --print("numberOfCells r = " ,r)
        elseif fn == "cellTouched" then
                
        end
        return r
    end
    local rewardTablView = LuaTableView:createWithHandler(LuaEventHandler:create(rewardTableCallback), CCSizeMake(567,660))
    rewardTablView:setVerticalFillOrder(kCCTableViewFillTopDown)
    rewardTablView:setBounceable(true)
    rewardTablView:setAnchorPoint(ccp(0, 0))
    rewardTablView:setPosition(ccp(0, 0))
    tableBackground:addChild(rewardTablView)
    rewardTablView:setTouchPriority(_touchPriority-20)

end

----------------------------------------回调函数----------------------------------------
--[[
    @des    :关闭回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end


----------------------------------------入口函数----------------------------------------
function showLayer(p_touchPriority,p_ZOrder)
    init()
    _touchPriority = p_touchPriority or -559
    _ZOrder = p_ZOrder or 999
    --绿色触摸屏蔽层
    _bgLayer = CCLayerColor:create(ccc4(0x00,0x2e,0x49,153))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder) 
    --创建背景UI
    createBgUI()

   
end
--[[
    @des    :获得触摸优先级
    @param  :
    @return :触摸优先级
--]]
function getTouchPriority()
    return _touchPriority
end