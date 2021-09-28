-- Filename: AlertGold.lua
-- Author: DJN
-- Date: 2014-11-07
-- Purpose:积分轮盘中提示玩家是否确认花钱抽奖

module("AlertGold", package.seeall)

require "script/audio/AudioUtil"
require "script/model/utils/ActivityConfig"

local _touchPriority    --触摸优先级
local _ZOrder           --Z轴
local _bgLayer          --触摸屏蔽层
local _goldTime         -- 想要花金币抽多少次
local _callBack        

----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil
    _goldTime = nil
    _callBack = nil
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

----------------------------------------回调函数----------------------------------------
--[[
    @des    :按钮回调
    @param  :
    @return :
--]]
function CallBack(tag)
    print("选中的tag",tag)
    if(tag == 1)then

        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

        require "script/model/user/UserModel"
        local curgold = UserModel.getGoldNumber()
        local cost = ScoreWheelData.getOneCost()
        if(cost ~= 0)then
            if(tonumber(curgold) >= tonumber(cost)*tonumber(_goldTime))then
                --金币够，扣金币，去抽奖
                print("金币够，去抽奖")

                --UserModel.addGoldNumber(-(tonumber(cost)*tonumber(_goldTime)))
                require "script/ui/rechargeActive/scoreWheel/ScoreWheelLayer"
                ScoreWheelData.setNeedGold(tonumber(cost)*tonumber(_goldTime))
                ScoreWheelLayer.setConfirmTag(true)
            else
                --提示金币不足，去充值
                print("金币不够，去充值")
                require "script/ui/tip/LackGoldTip"
                LackGoldTip.showTip()
            end
        end

    elseif(tag == 2)then
        AudioUtil.playEffect("audio/effect/guanbi.mp3")
    elseif(tag == 3)then
        AudioUtil.playEffect("audio/effect/guanbi.mp3")
    end

    if(_callBack ~= nil)then
        _callBack()
    end
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil 
end
----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建背景UI
    @param  :
    @return :
--]]
function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(520,400)
    local bgScale = MainScene.elementScale

    --主背景图
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
    bgSprite:setScale(bgScale)
    _bgLayer:addChild(bgSprite)

    -- --标题背景
    -- local titleSprite = CCSprite:create("images/common/viewtitle1.png")
    -- titleSprite:setAnchorPoint(ccp(0.5,0.5))
    -- titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
    -- bgSprite:addChild(titleSprite)
    
    -- local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 30)
    -- titleLabel:setColor(ccc3(0xff,0xe4,0x00))
    -- titleLabel:setAnchorPoint(ccp(0.5,0.5))
    -- titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
    -- titleSprite:addChild(titleLabel)、
 
    local note = CCLabelTTF:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 35)
    note:setColor(ccc3(0x78,0x25,0x00))
    note:setAnchorPoint(ccp(0.5,0))
    note:setPosition(ccp(bgSprite:getContentSize().width/2,280))
    bgSprite:addChild(note)
   
    --每次抽取花费*** 是否确认抽取 那句话
    local cost = tonumber(ActivityConfig.ConfigCache.roulette.data[1]["WheelCost"])
    cost = cost * _goldTime
    local firstLine = CCLabelTTF:create(GetLocalizeStringBy("djn_77")..cost, g_sFontName, 25)
    firstLine:setColor(ccc3(0x78,0x25,0x00))
    firstLine:setAnchorPoint(ccp(1,0))
    firstLine:setPosition(ccp(bgSprite:getContentSize().width *0.45,200))
    bgSprite:addChild(firstLine)

    local gold = CCSprite:create("images/common/gold.png")
    gold:setPosition(firstLine:getPositionX()+2,firstLine:getPositionY())
    bgSprite:addChild(gold)

    local secondLine = CCLabelTTF:create(","..GetLocalizeStringBy("key_1523"), g_sFontName, 25)
    secondLine:setColor(ccc3(0x78,0x25,0x00))
    secondLine:setPosition(ccp(gold:getContentSize().width + gold:getPositionX(),firstLine:getPositionY()))
    bgSprite:addChild(secondLine)

    local thirdLine = CCLabelTTF:create(_goldTime, g_sFontName, 25)
    thirdLine:setColor(ccc3(0x78,0x25,0x00))
    thirdLine:setPosition(ccp(secondLine:getContentSize().width + secondLine:getPositionX(),firstLine:getPositionY()))
    bgSprite:addChild(thirdLine)

    local forthLine = CCLabelTTF:create(GetLocalizeStringBy("djn_93"), g_sFontName, 25)
    forthLine:setColor(ccc3(0x78,0x25,0x00))
    forthLine:setPosition(ccp(thirdLine:getContentSize().width + thirdLine:getPositionX(),firstLine:getPositionY()))
    bgSprite:addChild(forthLine)
    -- --二级背景
    -- local brownSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    -- brownSprite:setContentSize(CCSizeMake(394,258))
    -- brownSprite:setAnchorPoint(ccp(0.5,0.5))
    -- brownSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2+20))
    -- bgSprite:addChild(brownSprite)
    
    
    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)

    --取消按钮
    local closeMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180, 73),GetLocalizeStringBy("key_2326"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width * 0.55,bgSprite:getContentSize().height*0.2))
    closeMenuItem:setAnchorPoint(ccp(0,0))
    closeMenuItem:registerScriptTapHandler(CallBack)
    bgMenu:addChild(closeMenuItem)
    closeMenuItem:setTag(2)
    
    --确定按钮
    local confirmMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180, 73),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    confirmMenuItem:setPosition(ccp(bgSprite:getContentSize().width * 0.45,bgSprite:getContentSize().height*0.2))
    confirmMenuItem:setAnchorPoint(ccp(1, 0))
    confirmMenuItem:registerScriptTapHandler(CallBack)
    bgMenu:addChild(confirmMenuItem)
    confirmMenuItem:setTag(1)

    -- 关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(CallBack)
    bgMenu:addChild(closeBtn)
    closeBtn:setTag(3)
    
end




----------------------------------------入口函数----------------------------------------
--第一个参数代表想花金币抽多少次，不可缺省
function showLayer(p_goldTime,p_callBack,p_touchPriority,p_ZOrder)
    init()
    _touchPriority = p_touchPriority or -550
    _ZOrder = p_ZOrder or 999
    _goldTime = p_goldTime
    _callBack = p_callBack
    --绿色触摸屏蔽层
    _bgLayer = CCLayerColor:create(ccc4(0x00,0x00,0x00,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder) 
    --创建背景UI
    createBgUI()
   
end

