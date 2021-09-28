-- FileName: MissionRankLayer.lua
-- Author:lcy
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("MissionRankLayer", package.seeall)

require "script/ui/mission/rank/MissionRankData"
require "script/ui/mission/rank/MissionRankService"
require "script/ui/purgatorychallenge/STPurgatoryRankLayer"
local _touchPriority   = nil
local _zOrder          = nil
local _bgLayer         = nil
local _backPanel       = nil
local _rankListData    = nil    --显示物品列表
local _reflushButton   = nil
local _lastReflushTime = nil    --上次刷新的时间
local _rankLabel       = nil
local _fameLabel       = nil

function init(...)
    _touchPriority   = nil
    _zOrder          = nil
    _bgLayer         = nil
    _backPanel       = nil
    _reflushButton   = nil
    _rankLabel       = nil
    _fameLabel       = nil
end

function show( pTouchPriority, pZorder )
    _touchPriority = pTouchPriority or -512
    _zOrder = pZorder or 512
    local scene = CCDirector:sharedDirector():getRunningScene()
    local layer = createLayer(_touchPriority, _zOrder)
    scene:addChild(layer,_zOrder,1231)
end


local function layerToucCb(eventType, x, y)
    return true
end

function createLayer(pTouchPriority, pZorder)
    _touchPriority = pTouchPriority or -512
    _zOrder = pZorder or 512

    _bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
    _bgLayer:setPosition(ccp(0, 0))
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,_touchPriority,true)
    _bgLayer:setTouchEnabled(true)
    _bgLayer:setAnchorPoint(ccp(0, 0))

    local g_winSize = CCDirector:sharedDirector():getWinSize()
    _backPanel = CCScale9Sprite:create("images/common/viewbg1.png")
    _backPanel:setContentSize(CCSizeMake(630, 796))
    _backPanel:setAnchorPoint(ccp(0.5, 0.5))
    _backPanel:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
    _bgLayer:addChild(_backPanel)
    AdaptTool.setAdaptNode(_backPanel)

    --标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
    titlePanel:setAnchorPoint(ccp(0.5, 0.5))
    titlePanel:setPosition(_backPanel:getContentSize().width/2, _backPanel:getContentSize().height - 7 )
    _backPanel:addChild(titlePanel)

    local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1965"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
    local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
    titleLabel:setPosition(ccp(x , y))
    titlePanel:addChild(titleLabel)
    -- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-10)
    _backPanel:addChild(menuBar, 10)
    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
    closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccpsprite(1.03, 1.03, _backPanel))
    menuBar:addChild(closeBtn)
    closeBtn:registerScriptTapHandler(closeLayer)

    _reflushButton = CCMenuItemImage:create("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png","images/common/btn/btn1_g.png")
    _reflushButton:setAnchorPoint(ccp(0.5, 0.5))
    _reflushButton:setPosition(ccpsprite(0.8, 0.9, _backPanel))
    _reflushButton:registerScriptTapHandler(reflushButtonCallback)
    menuBar:addChild(_reflushButton)

    _btnDes = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1977"), g_sFontPangWa, 24, 0.5, ccc3(0, 0, 0))
    _btnDes:setAnchorPoint(ccp(0.5, 0.5))
    _btnDes:setPosition(ccpsprite(0.5, 0.5, _reflushButton))
    _btnDes:setColor(ccc3(255, 246, 0))
    _reflushButton:addChild(_btnDes)

    _cdTimeLabel = CCLabelTTF:create("00:00:00",g_sFontName, 25)
    _cdTimeLabel:setAnchorPoint(ccp(0.5,0.5))
    _cdTimeLabel:setPosition(ccpsprite(0.5, -0.2, _reflushButton))
    _reflushButton:addChild(_cdTimeLabel)
    _cdTimeLabel:setVisible(false)
    _cdTimeLabel:setColor(ccc3(0, 0, 0))

    --物品列表
    local createUI = function ( ... )
        createTableView()
        createDes()
        updateUI()
        schedule(_cdTimeLabel, updateUI, 1)
    end
    local rankInfo = MissionRankData.getInfo()
    if rankInfo == nil then 
        MissionRankService.getRankList(function( pRetData )
            MissionRankData.setInfo(pRetData)
            createUI()
        end)
    else
        createUI()
    end
    return _bgLayer
end

--[[
    @des:创建描述
--]]
function createDes( ... )
    local rankDes = GetLocalizeStringBy("lcyx_1968")
    local rankDesLabel = CCLabelTTF:create(rankDes, g_sFontPangWa, 25)
    rankDesLabel:setAnchorPoint(ccp(0, 0.5))
    rankDesLabel:setPosition(ccpsprite(0.08 , 0.9, _backPanel))
    rankDesLabel:setColor(ccc3(0x78, 0x25, 0x00))
    _backPanel:addChild(rankDesLabel)

    local mineRank = MissionRankData.getMineRank()
    local rank = mineRank == "-1" and GetLocalizeStringBy("lcyx_1969") or mineRank
    _rankLabel = CCRenderLabel:create(rank, g_sFontPangWa, 25, 1, ccc3(0,0,0))
    _rankLabel:setAnchorPoint(ccp(0, 0.5))
    _rankLabel:setPosition(ccpsprite(1.1 , 0.5, rankDesLabel))
    _rankLabel:setColor(ccc3(113, 246, 47))
    rankDesLabel:addChild(_rankLabel)

    local fameDes = GetLocalizeStringBy("lcyx_1970")
    local fameDesLabel = CCLabelTTF:create(fameDes, g_sFontPangWa, 25)
    fameDesLabel:setAnchorPoint(ccp(0, 0.5))
    fameDesLabel:setPosition(ccpsprite(0.08 , 0.85, _backPanel))
    fameDesLabel:setColor(ccc3(0x78, 0x25, 0x00))
    _backPanel:addChild(fameDesLabel)

    local fame = MissionRankData.getMineFame()
    _fameLabel = CCRenderLabel:create(tostring(fame), g_sFontPangWa, 25, 1, ccc3(0,0,0))
    _fameLabel:setAnchorPoint(ccp(0, 0.5))
    _fameLabel:setPosition(ccpsprite(1.1 , 0.5, fameDesLabel))
    _fameLabel:setColor(ccc3(113, 246, 47))
    fameDesLabel:addChild(_fameLabel)
end


--[[
    @des:排名列表
--]]
function createTableView( ... )
    local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    tableBackground:setContentSize(CCSizeMake(575, 595))
    tableBackground:setAnchorPoint(ccp(0.5, 0))
    tableBackground:setPosition(ccp(_backPanel:getContentSize().width*0.5, 50))
    _backPanel:addChild(tableBackground)
    _rankListData = MissionRankData.getRankList()

    printTable("_rankListData",_rankListData)
    local createTableCallback = function(fn, t_table, a1, a2)
        require "script/ui/rewardCenter/RewardTableCell"
        local r
        if fn == "cellSize" then
            r = CCSizeMake(500, 115)
        elseif fn == "cellAtIndex" then
            a2 = createCell(_rankListData[a1 + 1], a1 + 1)
            r = a2
        elseif fn == "numberOfCells" then
            r = #_rankListData
        elseif fn == "cellTouched" then

        end
        return r
    end
    _tableView = LuaTableView:createWithHandler(LuaEventHandler:create(createTableCallback), CCSizeMake(575,585))
    _tableView:setBounceable(true)
    _tableView:setAnchorPoint(ccp(0, 0))
    _tableView:setPosition(ccp(0, 0))
    _tableView:setTouchPriority(_touchPriority-20)
    tableBackground:addChild(_tableView)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
    @des:创建cell
--]]
function createCell(pInfo, p_index )
    local rankInfo = pInfo
    local tCell = CCTableViewCell:create()

    local cellSprite = STPurgatoryRankLayer:createCell()
    cellSprite:setAnchorPoint(ccp(0, 0))
    cellSprite:setPosition(ccp(0, 0))
    tCell:addChild(cellSprite)
    local cellBg = cellSprite:getChildByName("cellBg")
    local rankSprite = cellBg:getChildByName("rankSprite")
    local rankLabel = cellBg:getChildByName("rankLabel")
    local bgFilenames = {"first_bg.png", "second_bg.png", "third_bg.png", "rank_bg.png"}
    local bgIndex = rankInfo.rank
    if bgIndex > 4 then
        bgIndex = 4
    end
    cellBg:setFilename("images/match/" .. bgFilenames[bgIndex])
    -- 名字
    local playerNameLabel = cellBg:getChildByName("playerNameLabel")
    playerNameLabel:setString(rankInfo.uname)
    if rankInfo.rank <= 3 then
        local filenames = {"one.png", "two.png", "three.png"}
        rankSprite:setFilename("images/match/" .. filenames[rankInfo.rank])
        rankLabel:removeFromParent()
        local nameColors = {ccc3(0xf9, 0x59, 0xff), ccc3(0x00, 0xe4, 0xff), ccc3(0xff, 0xfb, 0xd9)}
        playerNameLabel:setColor(nameColors[rankInfo.rank])
    else
        rankLabel:setString(tostring(rankInfo.rank))
        rankSprite:removeFromParent()
    end
    -- 服务器名字
    local serverNameLabel = cellBg:getChildByName("serverNameLabel")
    serverNameLabel:setString(rankInfo.server_name)
    serverNameLabel:setColor(playerNameLabel:getColor())
    -- 头像
    local headBg = cellBg:getChildByName("headBg")
    require "script/model/utils/HeroUtil"
    local dressId = nil
    local genderId = nil
    if not table.isEmpty(rankInfo.dress) and (rankInfo.dress["1"] ~= nil and tonumber(rankInfo.dress["1"]) > 0) then
        dressId = rankInfo.dress["1"]
        genderId = HeroModel.getSex(rankInfo.htid)
    end
    --vip 特效
    local vip = rankInfo.vip or 0
    local heroIcon = HeroUtil.getHeroIconByHTID(rankInfo.htid, dressId, dressId,vip)
    local heroIconNode = STNode:create()
    heroIconNode:addChild(heroIcon)
    heroIcon:setAnchorPoint(ccp(0.5, 0.5))
    heroIconNode:setContentSize(heroIcon:getContentSize())
    heroIcon:setPosition(ccpsprite(0.5, 0.5, heroIconNode))

    local heroBtn = STButton:createWithNode(heroIconNode)
    headBg:addChild(heroBtn, 1, rankInfo.rank)
    heroBtn:setAnchorPoint(ccp(0.5,0.5))
    heroBtn:setPosition(ccpsprite(0.5, 0.5, headBg))
    heroBtn:setTouchPriority(_touchPriority - 1)

    -- 等级
    local levelLabel = cellBg:getChildByName("levelLabel")
    levelLabel:setString(rankInfo.level)

    local fameDes = cellBg:getChildByName("Text_17_0_0")
    fameDes:setString(GetLocalizeStringBy("lcyx_1976"))

    -- 积分数量
    local pointLabel = cellBg:getChildByName("pointLabel")
    pointLabel:setString(rankInfo.fame)

    return tCell
end

--[[
    @des:刷新按钮回调事件
--]]
function reflushButtonCallback( ... )
    MissionRankService.getRankList(function( pRetData )
        MissionRankData.setInfo(pRetData)
        _lastReflushTime = TimeUtil.getSvrTimeByOffset()
        updateUI()
        _rankListData = MissionRankData.getRankList()
        _tableView:reloadData()
    end)
end

--[[
    @des:刷新ui
--]]
function updateUI( ... )
    local mineRank = MissionRankData.getMineRank()
    local rank = mineRank =="-1" and GetLocalizeStringBy("lcyx_1969") or mineRank
    local fame = MissionRankData.getMineFame()
    _rankLabel:setString(rank)
    _fameLabel:setString(fame)
    local cdTimeVisible = false
    local canReflush = true
    if _lastReflushTime ~= nil then
        local nowCd = MissionRankData.getCDTime() - (TimeUtil.getSvrTimeByOffset() - _lastReflushTime)
        if nowCd > 0 then
            _cdTimeLabel:setString(TimeUtil.getTimeString(nowCd))
            cdTimeVisible = true
            canReflush = false
        end
    end
    _cdTimeLabel:setVisible(cdTimeVisible)
    _reflushButton:setEnabled(canReflush)
    if canReflush then
        _btnDes:setColor(ccc3(255, 248, 0))
    else
        _btnDes:setColor(ccc3(100, 100, 100))
    end
end

function closeLayer( ... )
    _bgLayer:removeFromParentAndCleanup(true)
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
end




