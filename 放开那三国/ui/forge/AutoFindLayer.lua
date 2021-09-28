-- Filename: AutoFindLayer.lua
-- Author: bzx
-- Date: 2014-07-11
-- Purpose: 自动探宝

module("AutoFindLayer", package.seeall)

require "script/ui/forge/FindTreasureUtil"
require "script/utils/BaseUI"
require "script/model/user/UserModel"
require "db/DB_Explore_long"
require "db/DB_Vip"
require "script/network/RequestCenter"
require "script/ui/forge/FindTreasureLayer"

local _layer
local _dialog
local _touch_priority = -600
local _floor_selections
local _box_selections
local _map_info
local _menu
local _act_count_label
local _gold_count_label
local _vip_tip
local _selected_floor_end_index
local _selected_floor_start_index
local _selected_box_index
local _act_count
local _gold_count

function show()
    create()
    CCDirector:sharedDirector():getRunningScene():addChild(_layer, 100)
end

function init()
    _map_info = FindTreasureUtil.getMapInfo()
    _vip_tip = nil
    _selected_floor_start_index = 0
    _selected_box_index = 1
    _box_selections = nil
end

function create()
    init()
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)
    loadDialog()
    loadTip()
    loadMenu()
    loadBottom()
    loadSelection()
    refreshVipTip()
    return _layer
end

function loadDialog()
    local dialog_info = {
        title = GetLocalizeStringBy("key_8158"),
        callbackClose = closeCallback,
        size = CCSizeMake(630, 884),
        priority = _touch_priority - 1
    }
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5 - 20 * MainScene.elementScale))
    _dialog:setScale(MainScene.elementScale)
end

function loadSelection()
    local bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _dialog:addChild(bg)
    bg:setPreferredSize(CCSizeMake(586, 640))
    bg:setAnchorPoint(ccp(0.5, 1))
    bg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 108))

    local menu = CCMenu:create()
    bg:addChild(menu, 10)
    menu:setPosition(ccp(0, 0))
    menu:setContentSize(bg:getContentSize())
    menu:setTouchPriority(_touch_priority - 1)
    _floor_selections = {}
    local title_bg = CCSprite:create("images/common/line3.png")
    bg:addChild(title_bg)
    title_bg:setAnchorPoint(ccp(0.5, 0.5))
    title_bg:setPosition(bg:getContentSize().width * 0.5, 618)
    local title_label = CCRenderLabel:create(GetLocalizeStringBy("key_8163"), g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
    title_bg:addChild(title_label)
    title_label:setColor(ccc3(0xff, 0xe4, 0x00))
    title_label:setAnchorPoint(ccp(0.5, 0.5))
    title_label:setPosition(ccp(title_bg:getContentSize().width * 0.5, title_bg:getContentSize().height * 0.5))
    local floor_names = {GetLocalizeStringBy("key_8159"), GetLocalizeStringBy("key_8160"), GetLocalizeStringBy("key_8161"), GetLocalizeStringBy("key_8162")}
    for i = 1, #floor_names do
        local floor_name_label = CCRenderLabel:create(floor_names[i], g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
        bg:addChild(floor_name_label)
        floor_name_label:setAnchorPoint(ccp(0, 0.5))
        local position = ccp(74 + (i - 1) % 2 * 279, 574 - math.floor((i - 1) / 2) * 55)
        floor_name_label:setPosition(position)
         _floor_selections[i] = {}
        local normal = nil
        local file_name = "images/common/checkbg.png"
        local event_id = _map_info.map[ _map_info.posid].eid
        if i < _map_info.floor or event_id == 18000 then
            normal = BTGraySprite:create(file_name)
            _floor_selections[i].selected_tag_sprite = -1
            _selected_floor_start_index = i
        else
            normal = CCSprite:create(file_name)
        end
        local selection_btn = CCMenuItemSprite:create(normal, normal)
        menu:addChild(selection_btn)
        selection_btn:registerScriptTapHandler(floorSelectedCallback)
        local menu_position = ccp(position.x + floor_name_label:getContentSize().width + 10, position.y)
        selection_btn:setAnchorPoint(ccp(0, 0.5))
        selection_btn:setPosition(menu_position)
        selection_btn:setTag(i)
        _floor_selections[i].btn = selection_btn
    end
    if _selected_floor_start_index ~= #floor_names and _map_info.hasmove ~= "1" then
        local index = _selected_floor_start_index + 1
        floorSelectedCallback(index, _floor_selections[index].btn)
    end
    local line = CCSprite:create("images/common/line02.png")
    bg:addChild(line)
    line:setAnchorPoint(ccp(0.5, 0.5))
    line:setPosition(ccp(bg:getContentSize().width * 0.5, 484))
    line:setScaleX(4.8)
    
    local title_bg = CCSprite:create("images/common/line3.png")
    bg:addChild(title_bg)
    title_bg:setAnchorPoint(ccp(0.5, 0.5))
    title_bg:setPosition(bg:getContentSize().width * 0.5, 460)
    local title_label = CCRenderLabel:create(GetLocalizeStringBy("key_8164"), g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
    title_bg:addChild(title_label)
    title_label:setColor(ccc3(0xff, 0xe4, 0x00))
    title_label:setAnchorPoint(ccp(0.5, 0.5))
    title_label:setPosition(ccp(title_bg:getContentSize().width * 0.5, title_bg:getContentSize().height * 0.5))
    
    local tip_label_1 = CCRenderLabel:create(GetLocalizeStringBy("key_8217"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(tip_label_1)
    tip_label_1:setColor(ccc3(0x00, 0xe4, 0xff))
    tip_label_1:setAnchorPoint(ccp(0.5, 0.5))
    tip_label_1:setPosition(ccp(bg:getContentSize().width * 0.5, 428))
    
    local tip_label_2 = CCRenderLabel:create(GetLocalizeStringBy("key_8218"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(tip_label_2)
    tip_label_2:setColor(ccc3(0x00, 0xe4, 0xff))
    tip_label_2:setAnchorPoint(ccp(0.5, 0.5))
    tip_label_2:setPosition(ccp(bg:getContentSize().width * 0.5, 402))

    local description_btn = CCMenuItemImage:create("images/recycle/btn/btn_explanation_h.png", "images/recycle/btn/btn_explanation_n.png")
    menu:addChild(description_btn)
    description_btn:setAnchorPoint(ccp(0.5, 0.5))
    description_btn:setPosition(ccp(530, 430))
    description_btn:registerScriptTapHandler(descriptionCallback)
    
    
    _box_selections = {}
    local file_names = {"wu.png", "qingtongbaoxiang.png", "baiyinbaoxiang.png", "huangjinbaoxiang.png"}
    for i = 1, #file_names do
        local y = 336 - (i - 1) * 96
        if i % 2 == 1 then
            local line_bg = CCScale9Sprite:create("images/common/s9_6.png")
            bg:addChild(line_bg)
            line_bg:setPreferredSize(CCSizeMake(580, 96))
            line_bg:setAnchorPoint(ccp(0.5, 0.5))
            line_bg:setPosition(ccp(bg:getContentSize().width * 0.5, y))
        end
        local j_star = nil
        if i >= 2 then
            j_star = 2
        else
            j_star = 1
            local label =  CCRenderLabel:create(GetLocalizeStringBy("key_8219"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
            bg:addChild(label)
            label:setAnchorPoint(ccp(0, 0.5))
            label:setPosition(ccp(130, y))
            label:setColor(ccc3(0xff, 0xf6, 0x00))
        end
        for j = j_star, i do
            local box_icon = CCSprite:create("images/forge/treasure_icon/" .. file_names[j])
            bg:addChild(box_icon)
            box_icon:setAnchorPoint(ccp(0.5, 0.5))
            box_icon:setPosition(ccp(50 + (j - j_star) * 130, y))
            if j < i then
                local add_sprite = CCSprite:create("images/common/add_new.png")
                bg:addChild(add_sprite)
                add_sprite:setAnchorPoint(ccp(0.5, 0.5))
                add_sprite:setPosition(ccp(115 + (j - j_star) * 130, y))
            end
        end
        local explore_long_db = DB_Explore_long.getDataById(1)
        local points = strTableToTable(string.split(explore_long_db.aiExploreRewardPoint, "|"))
        local point_label = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_8220"), points[i]), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        bg:addChild(point_label)
        point_label:setColor(ccc3(0x00, 0xff, 0x18))
        point_label:setAnchorPoint(ccp(1, 0.5))
        point_label:setPosition(bg:getContentSize().width - 60, y)
        
        local selection_btn = CCMenuItemImage:create("images/common/btn/radio_normal.png", "images/common/btn/radio_selected.png", "images/common/btn/radio_selected.png")
        menu:addChild(selection_btn)
        selection_btn:registerScriptTapHandler(boxSelectedCallback)
        local position = ccp(bg:getContentSize().width - 40, y)
        selection_btn:setAnchorPoint(ccp(0.5, 0.5))
        selection_btn:setPosition(position)
        selection_btn:setTag(i)
        _box_selections[i] = {
            ["btn"] = selection_btn,
            ["label"] = point_label
        }
    end
    _selected_box_index = 1
    boxSelectedCallback(_selected_box_index, _box_selections[1].btn)
end

function loadTip()
    local tip1 = CCRenderLabel:create(GetLocalizeStringBy("key_8165"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    _dialog:addChild(tip1)
    tip1:setColor(ccc3(0x04, 0xea, 0x18))
    tip1:setAnchorPoint(ccp(0, 0.5))
    tip1:setPosition(ccp(30, _dialog:getContentSize().height - 65))
    
    local tip2 = {}
    tip2[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8214"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    tip2[1]:setColor(ccc3(0x04, 0xea, 0x18))
    tip2[2] = CCSprite:create("images/common/vip.png")
    tip2[3] = CCRenderLabel:create(GetLocalizeStringBy("key_8166"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    tip2[3]:setColor(ccc3(0x04, 0xea, 0x18))
    local tip2_node = BaseUI.createHorizontalNode(tip2)
    _dialog:addChild(tip2_node)
    tip2_node:setAnchorPoint(ccp(0, 0.5))
    tip2_node:setPosition(ccp(30, _dialog:getContentSize().height - 90))
end

function descriptionCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/forge/AutoFindDescLayer"
    AutoFindDescLayer.show()
end

function loadBottom()
    local act = {}
    act[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8167"), g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
    act[1]:setColor(ccc3(0xff, 0xe4, 0x00))
    act[2] = CCRenderLabel:create("0", g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
    act[2]:setColor(ccc3(0x00, 0xff, 0x18))
    _act_count_label = act[2]
    local act_node = BaseUI.createHorizontalNode(act)
    _dialog:addChild(act_node)
    act_node:setAnchorPoint(ccp(0, 0.5))
    act_node:setPosition(ccp(69, 114))
    
    local gold = {}
    gold[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8168"), g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
    gold[1]:setColor(ccc3(0xff, 0xe4, 0x00))
    gold[2] = CCSprite:create("images/common/gold.png")
    gold[3] = CCRenderLabel:create("0", g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
    gold[3]:setColor(ccc3(0x00, 0xff, 0x18))
    _gold_count_label = gold[3]
    local gold_node = BaseUI.createHorizontalNode(gold)
    _dialog:addChild(gold_node)
    gold_node:setAnchorPoint(ccp(0, 0.5))
    gold_node:setPosition(ccp(69, 74))
    
    local auto_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), GetLocalizeStringBy("key_8169"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(auto_btn)
    auto_btn:setAnchorPoint(ccp(0.5, 0.5))
    auto_btn:setPosition(ccp(470, 79))
    auto_btn:registerScriptTapHandler(autoCallback)
        
end

function autoCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    if _map_info.hasmove == "1" then
        SingleTip.showTip(GetLocalizeStringBy("key_8170"))
        return
    end
    if _selected_floor_start_index == #_floor_selections then
        SingleTip.showTip(GetLocalizeStringBy("key_8171"))
        return
    end
    if _selected_floor_start_index == _selected_floor_end_index then
        SingleTip.showTip(GetLocalizeStringBy("key_8172"))
        return
    end
    if _act_count > _map_info.act then
        SingleTip.showTip(GetLocalizeStringBy("key_8174"))
        return
    end
    if _gold_count > UserModel.getGoldNumber() then
        SingleTip.showTip(GetLocalizeStringBy("key_8175"))
        return
    end
    AlertTip.showAlert(GetLocalizeStringBy("key_8222"), autoFind, true, nil, GetLocalizeStringBy("key_8129"))
end


-- 确认购买血的回调
function autoFind(isConfirm, _argsCB)
    if isConfirm == false then
        return
    end
    local args = Network.argsHandler(_selected_floor_end_index, _selected_box_index - 1)
    RequestCenter.dragonAiDo(handleAuto, args)
end


function handleAuto(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    RequestCenter.dragonGetMap(FindTreasureLayer.handleGetMap, nil)
    UserModel.addGoldNumber(-_gold_count)
    closeCallback()
    require "script/ui/forge/AutoFindResultLayer"
    local data = dictData.ret
    data.act = _act_count
    data.selected_box_index = _selected_box_index
    data.selected_floor_start_index = _selected_floor_start_index
    data.selected_floor_end_index = _selected_floor_end_index
    AutoFindResultLayer.show(data)
end

function refreshVipTip()
    require "script/libs/LuaCC"
    local text = string.format(GetLocalizeStringBy("key_8176"), _map_info.free_ai_num)
    if _vip_tip == nil then
        _vip_tip = {}
        _vip_tip[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8215"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        _vip_tip[1]:setColor(ccc3(0x04, 0xea, 0x18))
        _vip_tip[2] = CCSprite:create("images/common/vip.png")
        _vip_tip[3] = LuaCC.createNumberSprite("images/main/vip", UserModel.getVipLevel())
        _vip_tip[4] = CCRenderLabel:create(text, g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        _vip_tip[4]:setColor(ccc3(0x04, 0xea, 0x18))
        local vip_tip_node = BaseUI.createHorizontalNode(_vip_tip)
        _dialog:addChild(vip_tip_node)
        vip_tip_node:setAnchorPoint(ccp(0, 0.5))
        vip_tip_node:setPosition(ccp(69, 40))
    else
        _vip_tip[4]:setString(text)
    end
end

function loadMenu()
    _menu = CCMenu:create()
    _dialog:addChild(_menu)
    _menu:setPosition(ccp(0, 0))
    _menu:setContentSize(_dialog:getContentSize())
    _menu:setTouchPriority(_touch_priority - 1)
end

function boxSelectedCallback(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    local index = tag
    _box_selections[_selected_box_index].btn:setEnabled(true)
    _selected_box_index = index
    _box_selections[_selected_box_index].btn:setEnabled(false)
    
    refreshActAndGold()
end

function refreshActAndGold()
    local explore_long_db = DB_Explore_long.getDataById(1)
    local acts = strTableToTable(string.split(explore_long_db.aiExploreCostAct, "|"))
    _act_count = acts[_selected_box_index]
    if _selected_box_index == 0 then
        _act_count = 0
    end
    local vip_db = DB_Vip.getDataById(UserModel.getVipLevel() + 1)
    if _selected_floor_start_index == #_floor_selections then
        _act_count = 0
    elseif _selected_floor_end_index ~= nil then
        _act_count = (_selected_floor_end_index - _selected_floor_start_index) * _act_count
        _act_count_label:setString(tostring(_act_count))
    end
    _gold_count = (_act_count - _map_info.free_ai_num) * explore_long_db.aiExplorePay
    if _gold_count < 0 then
        _gold_count = 0
    end
    _gold_count_label:setString(tostring(_gold_count))
end

function floorSelectedCallback(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    if _map_info.hasmove == "1" then
        SingleTip.showTip(GetLocalizeStringBy("key_8170"))
        return
    end
    
    local index = tag
    if _floor_selections[index].selected_tag_sprite == -1 then
        return
    elseif _floor_selections[index].selected_tag_sprite ~= nil then
        index = index - 1
    end
    _selected_floor_end_index = index
    local index_temp = 0
    for i = 1, index do
        local floor_selection = _floor_selections[i]
        if floor_selection. selected_tag_sprite == -1 then
            index_temp = i
        end
        if floor_selection.selected_tag_sprite == nil then
            local selected_tag_sprite = CCSprite:create("images/common/checked.png")
            floor_selection.btn:addChild(selected_tag_sprite, 10)
            selected_tag_sprite:setAnchorPoint(ccp(0.5, 0.5))
            local btn_size = floor_selection.btn:getContentSize()
            selected_tag_sprite:setPosition(ccp(btn_size.width * 0.5, btn_size.height * 0.5))
            floor_selection.selected_tag_sprite = selected_tag_sprite
        end
    end
    for i = index + 1, #_floor_selections do
        local floor_selection = _floor_selections[i]
        if floor_selection.selected_tag_sprite ~= nil then
            floor_selection.selected_tag_sprite:removeFromParentAndCleanup(true)
            floor_selection.selected_tag_sprite = nil
        end
    end
    if _box_selections ~= nil then
        local explore_long_db = DB_Explore_long.getDataById(1)
        local points = strTableToTable(string.split(explore_long_db.aiExploreRewardPoint, "|"))
        for i = 1, 4 do
            _box_selections[i].label:setString(string.format(GetLocalizeStringBy("key_8220"), points[i] * (index - index_temp)))--todo
        end
    end
    refreshActAndGold()
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
       
    _layer:removeFromParentAndCleanup(true)
end