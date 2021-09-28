-- Filename: EquipmentLayer.lua
-- Author: DJN
-- Date: 2014-08-08
-- Purpose: 武将更换装备技能展示

module ("EquipmentLayer", package.seeall)
require "script/ui/main/MainScene"
require "script/model/hero/HeroModel"
require "script/ui/replaceSkill/EquipmentTableView"
require "script/audio/AudioUtil"
require "script/ui/fashion/FashionLayer"
require "script/libs/LuaCCSprite"

local _ksTagSpecialEquip = 1001
local _ksTagNormalEquip = 1002
local _cs9TitleBar
local _touchPriority    --触摸优先级
local _ZOrder           --Z轴
local _bgLayer
local _tableView
local _shouldStopFashionLayerBgm = true
local _normalEquipmentItem     
local _specialEquipmentItem    
local _curMenuTag       --记录当前点击的menu
local _closeCb          --别的界面调用这个界面时传的 点击返回时的回调
local function init()
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil
    _tableView = nil
    _cs9TitleBar = nil
    _normalEquipmentItem = nil
    _specialEquipmentItem = nil
    _jumpTag = nil
    _curMenuTag = nil
end
----------------------------------------触摸事件函数----------------------------------------

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
        if _shouldStopFashionLayerBgm == true then
            FashionLayer.stopBgm()
        end
        _shouldStopFashionLayerBgm = true
    end
end

--[[
    @des: 创建背景
--]]
function createLayer()
    _bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
    require "script/ui/main/BulletinLayer"
    require "script/ui/main/MainScene"
    require "script/ui/main/MenuLayer"

    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local avatarLayerSize = MainScene.getAvatarLayerContentSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
    local layerSize = {}
    -- 层高等于设备总高减去“公告层”，“avatar层”，GetLocalizeStringBy("key_2785")高
    layerSize.height =  g_winSize.height - (bulletinLayerSize.height+avatarLayerSize.height+menuLayerSize.height)*g_fScaleX
    layerSize.width = g_winSize.width

    _bgLayer:setContentSize(CCSizeMake(layerSize.width, layerSize.height))
    _bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
    --_bgLayer:setScale(g_fScaleX)

    local ccSpriteBg = CCSprite:create("images/main/module_bg.png")
    ccSpriteBg:setScale(g_fBgScaleRatio)
    ccSpriteBg:setAnchorPoint(ccp(0.5, 0.5))
    ccSpriteBg:setPosition(ccp(layerSize.width/2, layerSize.height/2))
    _bgLayer:addChild(ccSpriteBg)
    
    --设置显示公告层和avatar层，底部menu
    MainScene.getAvatarLayerObj():setVisible(true)
    MenuLayer.getObject():setVisible(true)
    BulletinLayer.getLayer():setVisible(true)
   

    --创建“技能装备”的tab
    local tArgs = {}
    tArgs[1] = {text=GetLocalizeStringBy("djn_164"), x=10, tag =_ksTagSpecialEquip, handler = fnHandlerOfTitleButtons} 
    tArgs[2] = {text=GetLocalizeStringBy("djn_165"), x=210, tag = _ksTagNormalEquip , handler = fnHandlerOfTitleButtons}
    local cs9TitleBar = LuaCCSprite.createTitleBar(tArgs)
    _cs9TitleBar = cs9TitleBar
    cs9TitleBar:setAnchorPoint(ccp(0, 1))
    --+19*g_fScaleX
    cs9TitleBar:setPosition(0, layerSize.height+19*g_fScaleX)
    cs9TitleBar:setScale(g_fScaleX)
    _bgLayer:addChild(cs9TitleBar)

    _curMenuTag = _ksTagSpecialEquip

    local selectMenu = tolua.cast(_cs9TitleBar:getChildByTag(10001), "CCMenu")
    local selectMenuItem = tolua.cast(selectMenu:getChildByTag(_ksTagSpecialEquip), "CCMenuItem")
    selectMenuItem:selected()
    selectMenuItem:activate()
    --tArgs[1].handler()

    --先初始化一下tableview里面的tag
    _tableView = EquipmentTableView.createTableView(_bgLayer:getContentSize().width,
                 _bgLayer:getContentSize().height-85*g_fScaleX)
    _tableView:setAnchorPoint(ccp(0.5,0))
    _tableView:ignoreAnchorPointForPosition(false)

    _tableView:setPosition(ccp(_bgLayer:getContentSize().width/2,5*g_fScaleX))
    --table:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
    _bgLayer:addChild(_tableView,_ZOrder+100)


    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    cs9TitleBar:addChild(bgMenu)
    
    --关闭按钮
    local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    closeButton:setAnchorPoint(ccp(0.5, 0.5))
    closeButton:registerScriptTapHandler(closeButtonCallFunc)
    closeButton:setPosition(ccp(587 ,50))
    bgMenu:addChild(closeButton)
   -- closeButton:setScale(g_fScaleX)

    return _bgLayer
end

--[[
    @des: 入口函数 p_CloseCb是关闭页面后的回调函数 因为这个界面是changeLayer过来的  关闭后必然要创建新的
--]]
function showLayer(p_CloseCb,p_touchPriority,p_ZOrder)
    init()
    _closeCb = p_CloseCb
    _touchPriority = p_touchPriority or -550
    _ZOrder = p_ZOrder or 600
    MainScene.changeLayer(EquipmentLayer.createLayer(), "EquipmentLayer")  
end

--[[
    @des: 关闭按钮回调事件
    
--]]
function closeButtonCallFunc( ... )
    --音效
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    doCloseCb()

end
function doCloseCb( ... )
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    _closeCb()
end

--[[
    @des: tab回调事件
--]]
function fnHandlerOfTitleButtons(p_tag) 
    -- 音效
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if(p_tag == _curMenuTag)then
        return
    else
        --设置两个tab的状态
        local lastselectMenu = tolua.cast(_cs9TitleBar:getChildByTag(10001), "CCMenu")
        local lastselectMenuItem = tolua.cast(lastselectMenu:getChildByTag(_curMenuTag), "CCMenuItem")
        lastselectMenuItem:unselected()
        _curMenuTag = p_tag
        local selectMenu = tolua.cast(_cs9TitleBar:getChildByTag(10001), "CCMenu")
        local selectMenuItem = tolua.cast(selectMenu:getChildByTag(_curMenuTag), "CCMenuItem")
        selectMenuItem:selected()
        --EquipmentTableView.setCurMenuTag(_curMenuTag)   
        --刷新
        EquipmentTableView.refreshCurList()
        --调用_tableView:reloadData()之前必须先调用EquipmentTableView.refreshCurList()
        _tableView:reloadData()

    end

end
--[[
    @des: 返回table 供reload函数使用
--]]
function getTableView(...)
    return _tableView
end
--[[
    @des: 返回touchpriority
--]]
function getTouchPriority(...)
    return _touchPriority
end
function getCurMenuTag( ... )
    return _curMenuTag
end