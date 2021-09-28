-- Filename: AutoFindResultLayer.lua
-- Author: bzx
-- Date: 2014-07-15
-- Purpose: 探宝结果

module("AutoFindResultLayer", package.seeall)

local _layer
local _data                     -- 服务器传来的数据
local _touch_priority = -450
local _menu
local _bg
local _items_node               -- 所有物品的父节点
local _confirm_btn              -- 确定
local _center_x                 -- 面板的中间位置（图的左右不对称：images/forge/tip_bg.png）
local _maxFloor

function show(data)
    local new_data = {}
    new_data.events = {}
    new_data.floors = 0
    for k, v in pairs(data.events) do
        new_data.events[k] = {}
        new_data.floors = new_data.floors + 1
        for i = 1, #v do
            table.insert(new_data.events[k], v[i])
        end
    end
    new_data.drop = {}
    new_data.drop.item = {}
    if data.drop.item ~= nil then
        for k, v in pairs(data.drop.item) do
            table.insert(new_data.drop.item, {id = tonumber(k), num = tonumber(v)})
        end
    end
    new_data.act = data.act
    new_data.selected_box_index = data.selected_box_index
    create(new_data)
    CCDirector:sharedDirector():getRunningScene():addChild(_layer, 150)
end

function init(data)
    _data = data
end

function create(data)
    init(data)
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)
    loadBg()
    loadItems()
    loadMenu()
    loadEventDesc()
    return _layer
end

function loadBg()
    _bg = CCScale9Sprite:create("images/forge/tip_bg.png")
    _layer:addChild(_bg)
    _bg:setPreferredSize(CCSizeMake(577, 653))
    _bg:setAnchorPoint(ccp(0.5, 0.5))
    _bg:setPosition(ccp(g_winSize.width * 0.5 - 18, g_winSize.height * 0.5))
    _bg:setScale(g_fScaleX)
    local title = CCSprite:create("images/forge/result_title.png")
    _bg:addChild(title)
    title:setAnchorPoint(ccp(0.5, 0.5))
    title:setPosition(ccp(_bg:getContentSize().width * 0.5 + 18, _bg:getContentSize().height - 5))
    _center_x = _bg:getContentSize().width * 0.5 + 18
end

-- 物品
function loadItems()
    local get_award_title_label = CCRenderLabel:create(GetLocalizeStringBy("key_8177"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    _bg:addChild(get_award_title_label)
    get_award_title_label:setColor(ccc3(0xff, 0xe4, 0x00))
    get_award_title_label:setAnchorPoint(ccp(0.5, 0.5))
    get_award_title_label:setPosition(ccp(_center_x, 520))
    
    _items_node = CCLayerColor:create(ccc4(100, 100, 100, 0))
    _bg:addChild(_items_node)
    _items_node:ignoreAnchorPointForPosition(false)
    _items_node:setAnchorPoint(ccp(0.5, 1))
    _items_node:setPosition(ccp(_center_x, _bg:getContentSize().height - 160))
    local item_width = 90
    local item_height = item_width + 20
    local item_x_space = 15
    local item_y_space = 20
    _items_node:setContentSize(CCSizeMake((item_width + item_x_space) * 4 + item_width, (item_height + item_y_space) * math.floor((#_data.drop.item - 1) / 5) + item_height))
    for i = 1, #_data.drop.item do
        local item_info = _data.drop.item[i]
        local goodsValues = {}
        goodsValues.type = "item"
        goodsValues.tid = item_info.id
        goodsValues.num = item_info.num
        local icon= ItemUtil.createGoodsIcon(goodsValues, -700, 1010, -800, nil)
        _items_node:addChild(icon)
        icon:setAnchorPoint(ccp(0.5, 1))
        icon:setPosition(ccp((item_width + item_x_space) * ((i - 1) % 5) + item_width * 0.5, _items_node:getContentSize().height - ((item_height + item_y_space) * math.floor((i - 1) / 5))))
    end
end

-- 事件的描述
function loadEventDesc()
    local bg = CCScale9Sprite:create("images/common/s9_4.png")
    _bg:addChild(bg)
    bg:setPreferredSize(CCSizeMake(519, _items_node:getPositionY() - _items_node:getContentSize().height - _confirm_btn:getPositionY() - 50))
    bg:setAnchorPoint(ccp(0.5, 0))
    bg:setPosition(ccp(_center_x, 93))

    local scrollview = CCScrollView:create()
    bg:addChild(scrollview)
    scrollview:ignoreAnchorPointForPosition(false)
    scrollview:setAnchorPoint(ccp(0.5, 0.5))
    scrollview:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.5))
    scrollview:setTouchPriority(_touch_priority - 1)
	scrollview:setViewSize(CCSizeMake(480, bg:getContentSize().height - 8))
	scrollview:setDirection(kCCScrollViewDirectionVertical)

    local nodes = {}
    local height = 0
    local floors = {GetLocalizeStringBy("key_8178"), GetLocalizeStringBy("key_8179"), GetLocalizeStringBy("key_8180"), GetLocalizeStringBy("key_8181")}
    local point = 0
    for i = 1, 5 do
        local floor = tostring(i)
        local events = _data.events[floor]
        if events ~= nil then
            _maxFloor = i
            local compareEvent = function(event_id1, event_id2)
                local event_db1 = DB_Explore_long_event.getDataById(event_id1)
                local event_db2 = DB_Explore_long_event.getDataById(event_id2)
                return event_db1.aiExploreSort < event_db2.aiExploreSort
            end
            table.sort(events, compareEvent)
            for j = 1, #events do
                local event_db = parseDB(DB_Explore_long_event.getDataById(events[j]))
                local node = CCLayerColor:create(ccc4(100, 0, 0, 0))
                node:ignoreAnchorPointForPosition(false)
                node:setContentSize(CCSizeMake(478, 61))
                local floorName = floors[i] 
                if floorName == nil then
                    floorName = floors[1]
                end
                local floor_label = CCLabelTTF:create(floorName, g_sFontName, 18)
                node:addChild(floor_label)
                floor_label:setColor(ccc3(0xff, 0xe4, 0x00))
                floor_label:setAnchorPoint(ccp(0, 0.5))
                floor_label:setPosition(ccp(0, 40))
                
                local times_label = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8182"), j), g_sFontName, 18)
                node:addChild(times_label)
                times_label:setColor(ccc3(0xff, 0xe4, 0x00))
                times_label:setAnchorPoint(ccp(0, 0.5))
                times_label:setPosition(ccp(0, 22))
                
                local act_label = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8183"), -1), g_sFontName, 18)
                node:addChild(act_label)
                act_label:setAnchorPoint(ccp(0, 0.5))
                act_label:setPosition(ccp(100, 40))
                if type(event_db.integralReward[1]) ~= "table" then
                    local integral_reward = event_db.integralReward
                    event_db.integralReward = {integral_reward}
                end
                point = point + event_db.aiExplorePoint
                local point_label = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8221"), event_db.aiExplorePoint), g_sFontName, 18)
                node:addChild(point_label)
                point_label:setAnchorPoint(ccp(0, 0.5))
                point_label:setPosition(ccp(295, 40))
                
               
                local desc_label = CCLabelTTF:create(event_db.aiTips, g_sFontName, 18)
                node:addChild(desc_label)
                desc_label:setAnchorPoint(ccp(0, 1))
                desc_label:setPosition(ccp(100, node:getContentSize().height - 30))
                desc_label:setDimensions(CCSizeMake(370, 70))
                desc_label:setHorizontalAlignment(kCCTextAlignmentLeft)
                height = height + node:getContentSize().height
                table.insert(nodes, node)
            end
        end
    end
    scrollview:setContentSize(CCSizeMake(478, height))
    scrollview:setContentOffset(ccp(0, scrollview:getViewSize().height - scrollview:getContentSize().height))
    for i = 1, #nodes do
        local node = nodes[i]
        scrollview:addChild(node)
        node:setAnchorPoint(ccp(0.5, 1))
        node:setPosition(ccp(scrollview:getContentSize().width * 0.5, height))
        height = height - node:getContentSize().height
    end
    
    local total_title_label = CCRenderLabel:create(GetLocalizeStringBy("key_8184"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    _bg:addChild(total_title_label)
    total_title_label:setColor(ccc3(0xff, 0xe4, 0x00))
    total_title_label:setAnchorPoint(ccp(0.5, 0.5))
    total_title_label:setPosition(ccp(_center_x, _bg:getContentSize().height - 41))
    
    local act_label = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8185"), -_data.act), g_sFontName, 18)
    _bg:addChild(act_label)
    act_label:setAnchorPoint(ccp(0, 0.5))
    act_label:setPosition(ccp(155, _bg:getContentSize().height - 82))
    local add_point = 0
    local map_db = DB_Explore_long.getDataById(1)
    local aiExploreRewardPoint = strTableToTable(string.split(map_db.aiExploreRewardPoint, "|"))
    add_point = add_point + aiExploreRewardPoint[_data.selected_box_index]
    point = point + add_point * _data.floors 

    local point_label = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8186"), point), g_sFontName, 18)
    _bg:addChild(point_label)
    point_label:setAnchorPoint(ccp(0, 0.5))
    point_label:setPosition(ccp(347, _bg:getContentSize().height - 82))

    local extraPoint = FindTreasureData.getExtraPoint()
    local mapInfo = FindTreasureData.getMapInfo()
    if extraPoint > 0 and tonumber(mapInfo.floor) == 5 then
        act_label:setPosition(ccp(120, _bg:getContentSize().height - 82))
        point_label:setPosition(ccp(250, _bg:getContentSize().height - 82))
        local extraLabel = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_10272"), extraPoint), g_sFontName, 18)
        _bg:addChild(extraLabel)
        extraLabel:setAnchorPoint(ccp(0, 0.5))
        extraLabel:setPosition(ccp(410, _bg:getContentSize().height - 82))
    end
end

function loadMenu()
    _menu = CCMenu:create()
    _bg:addChild(_menu)
    _menu:setPosition(ccp(0, 0))
    _menu:setContentSize(_bg:getContentSize())
    _menu:setTouchPriority(_touch_priority - 1)
    
    _confirm_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), GetLocalizeStringBy("key_8187"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(_confirm_btn)
    _confirm_btn:setAnchorPoint(ccp(0.5, 0.5))
    _confirm_btn:setPosition(ccp(_center_x, 54))
    _confirm_btn:registerScriptTapHandler(closeCallback)
end

function onTouchesHandler(event)
    return true
end

function onNodeEvent(event)
    if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function closeCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _maxFloor == 5 then
        require "script/ui/forge/FindTreasureTrialLayer"
        local mapInfo = FindTreasureData.getMapInfo()
        local eventId = mapInfo.map[mapInfo.posid].eid
        FindTreasureTrialLayer.show(_touch_priority - 5, 1000, eventId, false, FindTreasureLayer.backFromTrialLayerCallback)
    end
    _layer:removeFromParentAndCleanup(true)
end
