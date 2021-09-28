-- Filename: GuildWarRewardDialog.lua
-- Author: DJN
-- Date: 2015-01-20
-- Purpose: 个人跨服赛奖励预览界面

module("GuildWarRewardDialog", package.seeall)
require "script/audio/AudioUtil"
--require "script/ui/lordWar/reward/LordWarRewardTableView"
require "script/ui/guildWar/reward/GuildWarRewardTableView"
-- require "script/model/utils/ActivityConfigUtil"

local _touchPriority    --触摸优先级
local _ZOrder           --Z轴
local _bgLayer          --触摸屏蔽层
local _curMenuItem      --傲视群雄、初出茅庐、关闭 的索引
local _curMenuTag       --当前按钮索引的tag
local _OnWarTag  = 101  --上场奖励的tag
local _OtherTag  = 102  --未上场奖励的tag
local _preViewLayer     --TableView
--local _serverTag        --记录当前是服内还是跨服的tag 1:服内 2:跨服

----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil
    _curMenuTag = 101
    _curMenuItem = nil
    _preViewLayer = nil
   -- _serverTag = nil 
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
    
    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("djn_142"), g_sFontPangWa, 30)
 
    titleLabel:setColor(ccc3(0xff,0xe4,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
    titleSprite:addChild(titleLabel)
    --本届用来测试*****那句话
    -- local noteStr = CCLabelTTF:create(GetLocalizeStringBy("djn_38"), g_sFontPangWa, 25)
    -- noteStr:setColor(ccc3(0x78,0x25,0x00))
    -- noteStr:setAnchorPoint(ccp(0.5,1))
    -- noteStr:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 36))
    -- bgSprite:addChild(noteStr)

    --二级背景
    local brownSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    brownSprite:setContentSize(CCSizeMake(575,665))
    brownSprite:setAnchorPoint(ccp(0.5,0.5))
    brownSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2-15))
    bgSprite:addChild(brownSprite)

    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-10)
    bgSprite:addChild(bgMenu)
    
    --出战成员按钮
    --local fullRect = CCRectMake(0,0,73,53)
    local insertRect = CCRectMake(35,20,1,1)
    local btnMenuN_OnWar = CCScale9Sprite:create(insertRect,"images/common/btn/tab_button/btn1_n.png")
    btnMenuN_OnWar:setPreferredSize(CCSizeMake(211,43))
    local btnMenuH_OnWar = CCScale9Sprite:create(insertRect,"images/common/btn/tab_button/btn1_h.png")
    btnMenuH_OnWar:setPreferredSize(CCSizeMake(211,53))
   
    local OnWarMenuItem = CCMenuItemSprite:create(btnMenuN_OnWar, nil,btnMenuH_OnWar)
    OnWarMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.45,brownSprite:getContentSize().height*0.5+brownSprite:getPositionY()))
    OnWarMenuItem:setAnchorPoint(ccp(1,0))
    OnWarMenuItem:registerScriptTapHandler(menuCallBack)
    bgMenu:addChild(OnWarMenuItem,1,_OnWarTag)
    OnWarMenuItem:setEnabled(false)
    --设置出战成员为默认选中的button
    _curMenuItem = OnWarMenuItem
    _curMenuTag = _OnWarTag


    --"出战成员"的字 根据是否被点击的状态创建两种字
    local labelOnWar_N = CCLabelTTF:create(GetLocalizeStringBy("djn_139"), g_sFontPangWa, 25)
    labelOnWar_N:setColor(ccc3(0xf4,0xdf,0xcb))
    labelOnWar_N:setAnchorPoint(ccp(0.5,0.5))
    labelOnWar_N:setPosition(ccp(btnMenuN_OnWar:getContentSize().width*0.5,btnMenuN_OnWar:getContentSize().height*0.5))
    btnMenuN_OnWar:addChild(labelOnWar_N)

    local labelOnWar_H = CCRenderLabel:create(GetLocalizeStringBy("djn_139"),g_sFontPangWa , 28, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
    labelOnWar_H:setColor(ccc3(0xff,0xff,0xff))
    labelOnWar_H:setAnchorPoint(ccp(0.5,0.5))
    labelOnWar_H:setPosition(ccp(btnMenuH_OnWar:getContentSize().width*0.5,btnMenuH_OnWar:getContentSize().height*0.5-2))
    btnMenuH_OnWar:addChild(labelOnWar_H)

   
    --场下人员按钮 
    local btnMenuN_Other = CCScale9Sprite:create(insertRect,"images/common/btn/tab_button/btn1_n.png")
    btnMenuN_Other:setPreferredSize(CCSizeMake(211,43))
    local btnMenuH_Other = CCScale9Sprite:create(insertRect,"images/common/btn/tab_button/btn1_h.png")
    btnMenuH_Other:setPreferredSize(CCSizeMake(211,53))
    local OtherMenuItem = CCMenuItemSprite:create(btnMenuN_Other, nil,btnMenuH_Other)
    OtherMenuItem:setPosition(ccp(OnWarMenuItem:getPositionX()+33 ,brownSprite:getContentSize().height*0.5+brownSprite:getPositionY()))
    OtherMenuItem:setAnchorPoint(ccp(0,0))
    
    OtherMenuItem:registerScriptTapHandler(menuCallBack)
    bgMenu:addChild(OtherMenuItem,1,_OtherTag)

    --"场下人员"的字 根据是否被点击的状态创建两种字
    local labelOther_N = CCLabelTTF:create(GetLocalizeStringBy("djn_140"), g_sFontPangWa, 25)
    labelOther_N:setColor(ccc3(0xf4,0xdf,0xcb))
    labelOther_N:setAnchorPoint(ccp(0.5,0.5))
    labelOther_N:setPosition(ccp(btnMenuN_Other:getContentSize().width*0.5,btnMenuN_Other:getContentSize().height*0.5))
    btnMenuN_Other:addChild(labelOther_N)

    local labelOther_H = CCRenderLabel:create(GetLocalizeStringBy("djn_140"),g_sFontPangWa , 28, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
    labelOther_H:setColor(ccc3(0xff,0xff,0xff))
    labelOther_H:setAnchorPoint(ccp(0.5,0.5))
    labelOther_H:setPosition(ccp(btnMenuH_Other:getContentSize().width*0.5,btnMenuH_Other:getContentSize().height*0.5-2))
    btnMenuH_Other:addChild(labelOther_H)

    --关闭按钮
    local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png","images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)

    -- 默认进入时展示出战的奖励
    -- 参数 1：参战 2：未上场
    _preViewLayer = GuildWarRewardTableView.createTableView(_curMenuTag)
    _preViewLayer:setAnchorPoint(ccp(0,0))
    _preViewLayer:setPosition(ccp(0,2))
    _preViewLayer:setTouchPriority(_touchPriority-2)
    brownSprite:addChild(_preViewLayer)
    

   
   
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
----------------------------------------回调函数----------------------------------------
--[[
    @des    :Menu回调
    @param  :
    @return :
--]]

function menuCallBack(tag, item )
    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    require "script/ui/tip/AnimationTip"
    _curMenuItem:setEnabled(true)
   -- _curMenuItem:unselected()
    item:setEnabled(false)
    _curMenuItem= item

    if(_curMenuTag == tag) then
        return
    end
    _curMenuTag = tag
    GuildWarRewardTableView.setStage(_curMenuTag)      
    _preViewLayer:reloadData()      

end

----------------------------------------入口函数----------------------------------------
function showLayer(p_touchPriority,p_ZOrder)
    init()
    _touchPriority = p_touchPriority or -550
    _ZOrder = p_ZOrder or 999
    --_serverTag = server
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