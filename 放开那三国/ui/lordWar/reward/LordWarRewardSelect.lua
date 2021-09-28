-- Filename: LordWarRewardSelect.lua
-- Author: DJN
-- Date: 2014-07-31
-- Purpose: 跨服赛奖励预览选择界面

module("LordWarRewardSelect", package.seeall)
require "script/audio/AudioUtil"
require "script/ui/lordWar/reward/LordWarRewardLayer"

local _touchPriority    --触摸优先级
local _ZOrder           --Z轴
local _bgLayer          --触摸屏蔽层
local _bgSprite         --弹出的窗体
local _PositionX        --窗体坐标，跟随奖励预览按钮位置
local _PositionY        --窗体坐标，跟随奖励预览按钮位置
----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil
    _bgSprite = nil
    _PositionX = nil
    _PositionY = nil
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
        print("moved")
    else
        print("end")
        closeCallBack()  
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
    --弹窗背景图
    require "script/ui/main/MainScene"
    local bgScale = MainScene.elementScale
    local bgSize = CCSizeMake(430,150)
    _bgSprite = CCScale9Sprite:create("images/common/bg/9s_1.png")
    _bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    _bgSprite:setAnchorPoint(ccp(1,1))
    _bgSprite:setPosition(ccp(_PositionX,_PositionY))
    _bgSprite:setScale(0)
    _bgLayer:addChild(_bgSprite)
    
    --奖励预览按钮层
    local PreviewMenu = CCMenu:create()
    PreviewMenu:setPosition(ccp(0,0))
    PreviewMenu:setTouchPriority(_touchPriority-1)
    _bgLayer:addChild(PreviewMenu)
    
    --奖励预览按钮
    --因为这个选择界面出现的时候按钮已经是被点击的状态，所以图片素材中h与n相反
    local rewardPreviewButton = CCMenuItemImage:create("images/match/reward_h.png","images/match/reward_n.png")
    rewardPreviewButton:setScale(bgScale)
    rewardPreviewButton:setAnchorPoint(ccp(0.5, 0.5))
    rewardPreviewButton:setPosition(ccp(_PositionX,_PositionY))
    rewardPreviewButton:registerScriptTapHandler(closeCallBack)
    PreviewMenu:addChild(rewardPreviewButton)
    
    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    _bgSprite:addChild(bgMenu)
     --跨服奖励按钮
    local KuafuItem = CCMenuItemImage:create("images/lord_war/rewardpreview/kuafu_n.png", "images/lord_war/rewardpreview/kuafu_h.png")
    KuafuItem:setPosition(ccp(100,70))
    KuafuItem:setAnchorPoint(ccp(0.5,0.5))
    KuafuItem:registerScriptTapHandler(KuafuCallBack)
    bgMenu:addChild(KuafuItem)
     --服内奖励按钮
    local FuneiItem = CCMenuItemImage:create("images/lord_war/rewardpreview/funei_n.png", "images/lord_war/rewardpreview/funei_h.png")
    FuneiItem:setPosition(ccp(300,70))
    FuneiItem:setAnchorPoint(ccp(0.5,0.5))
    FuneiItem:registerScriptTapHandler(FuneiCallBack)
    bgMenu:addChild(FuneiItem)

    
    local action = CCScaleTo:create(0.2, 1 * MainScene.elementScale)
    _bgSprite:runAction(action)
 end 

----------------------------------------回调函数----------------------------------------
--[[
    @des    :关闭回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
        local closeActionArray = CCArray:create()
        closeActionArray:addObject(CCScaleTo:create(0.2,0))
        closeActionArray:addObject(CCCallFuncN:create(function (...)
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            end))
        _bgSprite:runAction(CCSequence:create(closeActionArray)) 
end
--]]

-- 下面调用LordWarRewardLayer.showLayer()  参数：1为服内 2为跨服
--[[
    @des    :跨服奖励回调
    @param  :
    @return :
--]]
function KuafuCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    LordWarRewardLayer.showLayer(1)
end
--[[
    @des    :服内奖励回调
    @param  :
    @return :
--]]
function FuneiCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    LordWarRewardLayer.showLayer(2)
end

----------------------------------------入口函数----------------------------------------
function showLayer(x,y,p_touchPriority,p_ZOrder)
    init()
    _touchPriority = (p_touchPriority-1) or -550
    _ZOrder = p_ZOrder or 999
    _PositionX = x
    _PositionY = y
    --触摸屏蔽层
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder) 
 
    createBgUI()

end
