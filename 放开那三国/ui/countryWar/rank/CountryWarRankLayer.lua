-- FileName:CountryWarRankLayer.lua
-- Author:FQQ
-- Data:2015-11-9
-- Purpose:国战积分排行榜主界面

module ("CountryWarRankLayer",package.seeall)
require "script/ui/countryWar/rank/CountryWarRankCell"
require "script/ui/countryWar/rank/CountryWarRankController"
local _bgLayer = nil
local _touchPriority = nil
local _zOrder = nil
local _tableBackground = nil
local _tableView = nil
local _number = nil
local _curData = nil
local _cell = nil
-- 排行榜数据
local _rankData = nil
-- 装标签的数组
local _btnAry = nil
-- 是否已经助威
local _isSupported = nil
function init( ... )
    _imagePath = {
        bg = "images/common/viewbg1.png",
        titlePanel = "images/common/viewtitle1.png",
        closeMenuItem_n = "images/common/btn_close_n.png",
        closeMenuItem_h = "images/common/btn_close_h.png",
        tableViewBg = "images/common/bg/bg_ng_attr.png",
        btn_blue_n = "images/common/btn/btn_blue_n.png",
        btn_blue_h = "images/common/btn/btn_blue_h.png",
        tap_btn_n = "images/common/btn/tab_button/btn1_n.png",
        tap_btn_h = "images/common/btn/tab_button/btn1_h.png"
    }
    _bgLayer = nil
    _touchPriority = nil
    _zOrder = nil
    _tableBackground = nil
    _tableView = nil
    _number = nil
    _cell   = nil
    _rankData = nil
    _isSupported = nil
    _btnAry = {}
end
function layerTouchCb( eventType,x,y )
    if eventType == "began" then
        return true
    end
end

function show( pTouchPriority, pZorder )
    --先要拉取排行榜的全部信息
    -- MainScene.setMainSceneViewsVisible(true,false,false)
    CountryWarRankController.getFinalMembers(function (pData)
        init()
        _touchPriority = pTouchPriority or -750
        _zOrder = pZorder or 1
        _rankData = pData.memberInfo
        local scene = CCDirector:sharedDirector():getRunningScene()
        local layer = createLayer(_touchPriority,_zOrder)
        scene:addChild(layer,_zOrder)
    end)
end
function createLayer( pTouchPriority, pZorder )
    _bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
    _bgLayer:setPosition(ccp(0,0))
    _bgLayer:registerScriptTouchHandler(layerTouchCb,false,_touchPriority,true)
    _bgLayer:setTouchEnabled(true)

    -- 背景
    local _backPanel = CCScale9Sprite:create("images/common/viewbg1.png")
    _backPanel:setContentSize(CCSizeMake(630,796))
    _backPanel:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_backPanel)
    _backPanel:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    AdaptTool.setAdaptNode(_backPanel)

    --标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
    titlePanel:setAnchorPoint(ccp(0.5, 0.5))
    titlePanel:setPosition(_backPanel:getContentSize().width/2, _backPanel:getContentSize().height - 7 )
    _backPanel:addChild(titlePanel)

    local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_010"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
    local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
    titleLabel:setPosition(ccp(x , y))
    titlePanel:addChild(titleLabel)
    -- 按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority - 10)
    _backPanel:addChild(menuBar,10)
    --关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccpsprite(1.02, 1.03, _backPanel))
    menuBar:addChild(closeBtn)
    closeBtn:registerScriptTapHandler(closeLayer)
    -- 标签文本
    local btnLabel = {
        GetLocalizeStringBy("fqq_011"),
        GetLocalizeStringBy("fqq_012"),
        GetLocalizeStringBy("fqq_013"),
        GetLocalizeStringBy("fqq_014")
    }
    for i=1,4 do
        local btn = createBtn(btnLabel[i])
        btn:setPosition(ccp(105 + 140 * (i - 1),725))
        if i == 1 then
            btn:setEnabled(false)
        else
            btn:setEnabled(true)
        end
        menuBar:addChild(btn,1,i)
        table.insert(_btnAry,btn)
    end
    _curData = _rankData["1"]
    _tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _tableBackground:setContentSize(CCSizeMake(575, 650))
    _tableBackground:setAnchorPoint(ccp(0.5, 0))
    _tableBackground:setPosition(ccp(_backPanel:getContentSize().width*0.5, 50))
    _backPanel:addChild(_tableBackground)
    createTableView()
    return _bgLayer
end

function createBtn( text )
    local insertRect = CCRectMake(35,20,1,1)
    local tapBtnN = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_n)
    tapBtnN:setPreferredSize(CCSizeMake(130,53))
    local tapBtnH = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_h)
    tapBtnH:setPreferredSize(CCSizeMake(130,57))
    local btn = CCMenuItemSprite:create(tapBtnN, nil,tapBtnH)
    btn:setAnchorPoint(ccp(0.5,0.5))
    btn:registerScriptTapHandler(setContentType)
    local label = CCRenderLabel:create(text, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    label:setColor(ccc3(0xfe, 0xdb, 0x1c))
    label:setAnchorPoint(ccp(0.5,0.5))
    label:setPosition(ccp(btn:getContentSize().width*0.5,btn:getContentSize().height*0.5))
    btn:addChild(label)
    return btn
end

function setContentType( value )
    if(_number ~= value)then
        _number = value
        _curData = _rankData[tostring(_number)]
        for i=1,4 do
            if (i == value) then
                _btnAry[i]:setEnabled(false)
            else
                _btnAry[i]:setEnabled(true)
            end
        end
        refresh()
    end
end
--排名列表
function createTableView( ... )
    local createTableCallback = function(fn, t_table, a1, a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(575, 115)
        elseif fn == "cellAtIndex" then
            local data = _curData[a1 + 1]
            a2 = CountryWarRankCell.new(data, a1 + 1,_isSupported)
            a2.pid = data.pid
            a2.server_id = data.server_id
            r = a2
        elseif fn == "numberOfCells" then
            r = table.count(_curData)
        elseif fn == "cellTouched" then
        end
        return r
    end
    _tableView = LuaTableView:createWithHandler(LuaEventHandler:create(createTableCallback), CCSizeMake(575,640))
    _tableView:setAnchorPoint(ccp(0, 0))
    _tableView:setPosition(ccp(0, 0))
    _tableView:setTouchPriority(_touchPriority-20)
    _tableBackground:addChild(_tableView)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end
--[[
    @des    : 助威成功后刷新
    @param  : 
    @return : 
--]]
function refreshAfterCheer( ... )
    -- body
    _isSupported = true
    refresh()
end

function refresh( ... )
    if (_tableView) then
        _tableView:removeFromParentAndCleanup(true)
        _tableView = nil
    end
    createTableView()
end

function closeLayer( ... )
    -- 播放关闭音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _bgLayer then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end







