-- Filename: FindTreasureLayer.lua
-- Author: bzx
-- Date: 2014-06-10
-- Purpose: 寻龙探宝

---
-- @type FindTreasureLayer
module("FindTreasureLayer", package.seeall)

require "db/DB_Explore_long_event"
require "script/libs/LuaCC"
require "script/ui/tip/SingleTip"
require "db/DB_Explore_long_event"
require "db/DB_Explore_long"
require "script/ui/forge/TreasureDialog"
require "script/ui/forge/FindFormationLayer"
require "script/utils/LuaUtil"
require "script/ui/forge/FindTreasureService"
require "script/model/user/UserModel"
require "script/ui/tip/AlertTip"
require "script/ui/forge/SelecteBuyCountLayer"
require "db/DB_Vip"
require "script/utils/BaseUI"
require "script/libs/LuaCCSprite"
require "script/ui/forge/FindTreasureResetDialog"
require "script/ui/forge/FindTreasureTrialLayer"
require "script/ui/forge/AutoFindResultLayer"
require "script/ui/star/loyalty/LoyaltyData"

local _layer
local _menu                         -- 本层的菜单
local _map                          -- 所有地块的父节点
local _map_sprites_node             -- 所有事件icon的父节点
local _map_sprites                  -- 所有事件icon的集合
local _map_blocks                   -- 所有地块的集合
local _player_index                 -- 玩家的下标
local _map_info                     -- 地图信息
local _scroll_view                  -- 地图滑动
local _touch_priority       = -410  -- 当前层触摸优先级
local _cols                         -- 总列数
local _rows                         -- 总行数
local _next_player_index            -- 玩家下一步要到达的下标
local _player                       -- 玩家
local _player_arrows                -- 玩家脚下的箭头
local _point_label                  -- 积分
local _act_label                    -- 行动力
local _floor_label                  -- 第几层
local _hp_label                     -- 血槽值
local _blocks_menu                  -- 地块的菜单节点
local _blocks_node                  -- 地块节点
local _hp_progress                  -- 血槽
local _player_world_x_min           -- 角色跟踪x方向向左的临界点
local _player_world_x_max           -- 角色跟踪x方向向右的临界点
local _block_width          = 101   -- 地块宽度
local _block_height         = 89    -- 地块长度
local _block_space_y        = 0     -- 地块y方向间隔
local _block_space_x        = 0     -- 地块x方向间隔
local _refresh_node                 -- 有刷新数据的节点 行动力、血槽
local _refresh_node_menu            -- 有刷新数据的菜单
local _top_node                     -- 顶部的节点
local _top_node_menu                -- 顶部的菜单
local _map_bg_node                  -- 地图的背景
local _speed                = 0.1     -- 人物的移动速度，每1秒移动100像素
local _reset_map_btn                -- 重置地图
local _look_formation_btn           -- 查看阵型
local _auto_btn         
local _buy_act_count                -- 购买行动力时，保存购买的次数
local _buy_act_total_gold_count     -- 购买行动力时，保存所花的金币
local _buy_hp_gold_count            -- 购买血量时，保存购买的次数
local _reset_map_gold_count         -- 购买血量时，保存所花的金币
local _map_blocks_node_y            -- 地块距离屏幕底的高度
local _addition_node                -- 攻击加成标记
local _end_layer                    -- 探宝结束面板
local _add_act_btn                  -- 购买行动力
local _add_hp_btn                   -- 购买血量
local _reset_data                   -- 重置地图的网络数据
local _old_map_info
local _map_db
local _path
local _arrows
local _mist_sprite
local _bg_music
local _selected_floor_index
local _selected_box_index
local _auto_gold_count
local _auto_act_count
-- 新手引导
local _act_title                    -- 行动力标题
local _hp_bg                        -- 血槽背景
local _title_sprite
local _itemResetCount 

---
-- @function [parent=#FindTreasureLayer] show
-- @param self
function show()
    FindTreasureService.dragonGetMap(handleFirstTimeGetMap)
end

function handleFirstTimeGetMap()
    if FindTreasureData.isFirstTime() == true then
        FindTreasureResetDialog.show()
    else
        show2()
    end
end

function show2( ... )
    create()
    MainScene.changeLayer(_layer, "FindTreasureLayer")
        -- 拉取阵型
    FindTreasureService.dragonGetUserBf(handleFirstTimeGetUserBf)
end

function handleFirstTimeGetUserBf( ... )
    handleFormation()
    handleGetMap()
end

function init()
    _map = nil
    _map_sprites = nil
    _point_label = nil
    _floor_label = nil
    _act_label = nil
    _hp_label = nil
    _scroll_view = nil
    _map_sprites_node = nil
    _blocks_node = nil
    _reset_map_btn = nil
    _look_formation_btn = nil
    _auto_btn = nil
    _player_arrows = nil
    _addition_node = nil
    _end_layer = nil
    _reset_data = nil
    _player_world_x_min   = 150 * MainScene.elementScale
    _player_world_x_max   = g_winSize.width - 150 * MainScene.elementScale
    _map_db = parseDB(DB_Explore_long.getDataById(1))
    _mist_sprite = nil
    _bg_music = DB_Explore_long.getDataById(1).exploreMusic
    _title_sprite = nil
end

function create()
    init()
    _layer = MainScene.createBaseLayer(nil, false, false, true)
    _layer:registerScriptHandler(onLayerEvent)
    local bg = CCScale9Sprite:create("images/forge/bg.png", CCRectMake(0, 0, 640, 465), CCRectMake(10, 100, 10, 10))
    _layer:addChild(bg)
    bg:setAnchorPoint(ccp(0, 0))
    bg:setPosition(ccp(0, 0))
    bg:setContentSize(CCSizeMake(640, g_winSize.height / MainScene.elementScale))
    bg:setScale(g_fScaleX / MainScene.elementScale)
    createMenu()
    createTopNode()
    createRefreshNode()
    _map_blocks_node_y = ((_refresh_node:getPositionY() - _refresh_node:getContentSize().height) / g_fScaleX) * 0.5 - (_block_height + _block_space_y) * 3 + _block_height * 0.5 - 50
    print("_map_blocks_node=", _map_blocks_node_y)
    
    return _layer
end

-- 创建下面的按钮
function createMenu()
    _menu = CCMenu:create()
    _layer:addChild(_menu, 10)
    _menu:setTouchPriority(_touch_priority - 10)
    _menu:setPosition(ccp(0, 0))
    _menu:setContentSize(g_winSize)
end

function refreshMist()
    --[[
    if _mist_sprite ~= nil then
        _mist_sprite:removeFromParentAndCleanup(true)
    end
    local dest_sprite = CCSprite:create("images/forge/nanzhujiao_1.png")
    _mist_sprite = BTMistSprite:create(ccc4(0, 0, 0, 200), dest_sprite, CCSizeMake(_map:getContentSize().width, _block_height * _rows))
    _map:addChild(_mist_sprite, 21)
    _mist_sprite:setPosition(ccp(0, _map_blocks_node_y))
    --]]
end
-- 刷新攻击加成标识
function refreAddtion(addition)
    if _addition_node ~= nil then
        _addition_node:removeFromParentAndCleanup(true)
        _addition_node = nil
    end
    if addition ~= 0 then
        local additions = {}
        additions[1] = CCLabelTTF:create(GetLocalizeStringBy("key_8103"), g_sFontName, 21)
        additions[1]:setColor(ccc3(0xff, 0x00, 0x00))
        additions[2] = CCSprite:create("images/active/mineral/arrow.png")
        additions[3] = CCLabelTTF:create(tostring(addition) .. "%", g_sFontName, 21)
        additions[3]:setColor(ccc3(0xff, 0x00, 0x00))
        _addition_node = BaseUI.createHorizontalNode(additions)
        _refresh_node:addChild(_addition_node)
        _addition_node:setAnchorPoint(ccp(0, 0.5))
        _addition_node:setPosition(ccp(510, _refresh_node_menu:getContentSize().height - 118))
    end
end

-- 刷新下面的按钮，免费重置与重置探宝的切换
function refreshBtn()
    if _reset_map_btn ~= nil then 
        _reset_map_btn:removeFromParentAndCleanup(true)
    end
    local text = nil
    local tip_sprite = nil


    
    local tipNum = 0
    if _map_info.free_reset_num > 0 then
        tipNum = _map_info.free_reset_num
    else
        local itemCount = FindTreasureData.initItemResetCount()
        tipNum = itemCount
    end

    if _map_info.free_reset_num > 0 then
        text = GetLocalizeStringBy("key_8104")
    else
        text = GetLocalizeStringBy("key_8105")
    end

    if tipNum > 0 then
        tip_sprite = LuaCCSprite.createTipSpriteWithNum(tipNum)
    end
    local reset_map_btn_size = CCSizeMake(200, 73)
    _reset_map_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", reset_map_btn_size, text, ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(_reset_map_btn)
    _reset_map_btn:setAnchorPoint(ccp(0.5, 0.5))
    _reset_map_btn:setPosition(ccp(g_winSize.width / MainScene.elementScale * 0.5, 37))
    _reset_map_btn:registerScriptTapHandler(resetMapCallback)
    if tip_sprite ~= nil then
        _reset_map_btn:addChild(tip_sprite)
        tip_sprite:setPosition(ccp(reset_map_btn_size.width - 10, reset_map_btn_size.height - 10))
    end
     
    if _look_formation_btn == nil then
        _look_formation_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), GetLocalizeStringBy("key_8106"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        _menu:addChild(_look_formation_btn)
        _look_formation_btn:setAnchorPoint(ccp(0.5, 0.5))
        _look_formation_btn:setPosition(ccp(100, 37))
        _look_formation_btn:registerScriptTapHandler(lookFormationCallback)
    end
    
    if _auto_btn == nil then
         _auto_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), GetLocalizeStringBy("key_8216"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        _menu:addChild(_auto_btn)
        _auto_btn:setAnchorPoint(ccp(0.5, 0.5))
        _auto_btn:setPosition(ccp(g_winSize.width / MainScene.elementScale - 100, 37))
        _auto_btn:registerScriptTapHandler(autoCallback)
    end
end

function autoCallback()
    require "script/ui/tip/AlertTip2"
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    if _map_info.map[_player_index].eid == 18000 or _map_info.map[_player_index].eid == 21000 then
        SingleTip.showTip(GetLocalizeStringBy("key_8171"))
        return
    end

    if _map_info.hasmove == "1" then
        if _map_info.mode == "1" then
            SingleTip.showTip(GetLocalizeStringBy("key_8471"))
        else
            SingleTip.showTip(GetLocalizeStringBy("key_8170"))
        end
        return
    end
    _selected_floor_index = _map_info.floor
    _selected_box_index = 4
    local explore_long_db = DB_Explore_long.getDataById(1)
    local acts = strTableToTable(string.split(explore_long_db.aiExploreCostAct, "|"))
    _auto_act_count = acts[_selected_box_index]

    if FindTreasureData.isFreeAutoFind() then
        _auto_gold_count = 0
    else
        _auto_gold_count = _auto_act_count * explore_long_db.aiExplorePay
    end
    if _map_info.mode == "0" then
        local others = {}
        AlertTip2.showAlert(nil, nil, autoFind, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, others)
        local chinese_number = {"key_8107", "key_8108", "key_8109", "key_8110", "key_8111", "key_8112", "key_8113", "key_8114", "key_8115", "key_8116"}
        local floor_name = GetLocalizeStringBy("key_8117", GetLocalizeStringBy(chinese_number[_selected_floor_index]))


        local alertBgSize = others.bg:getContentSize()
        local tip1 = {}
        tip1[1] = CCLabelTTF:create(GetLocalizeStringBy("key_8224"), g_sFontName, 25)
        tip1[1]:setColor(ccc3(0x78, 0x25, 0x00))
        if _auto_gold_count > 0 then
            tip1[2] = CCSprite:create("images/common/gold.png")
            tip1[3] = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8225"), _auto_gold_count, _auto_act_count, floor_name), g_sFontName, 25)
            tip1[3]:setColor(ccc3(0x78, 0x25, 0x00))
        else
            tip1[2] = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_10273"), _auto_act_count, floor_name), g_sFontName, 25)
            tip1[2]:setColor(ccc3(0x78, 0x25, 0x00))
        end

        local tip1_node = BaseUI.createHorizontalNode(tip1)
        others.bg:addChild(tip1_node)
        tip1_node:setAnchorPoint(ccp(0.5, 0.5))
        tip1_node:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height - 150))
        
        local tip2 = CCLabelTTF:create(GetLocalizeStringBy("key_8226"), g_sFontName, 25)
        others.bg:addChild(tip2)
        tip2:setColor(ccc3(0x78, 0x25, 0x00))
        tip2:setAnchorPoint(ccp(0.5, 0.5))
        tip2:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height - 180))
        
        local tip3_text = nil 
        if _selected_floor_index == 4 then
            tip3_text = GetLocalizeStringBy("key_8223")
        else
            tip3_text = GetLocalizeStringBy("key_8222")
        end
        local tip3 = CCLabelTTF:create(tip3_text, g_sFontName, 25)
        others.bg:addChild(tip3)
        tip3:setAnchorPoint(ccp(0.5, 0.5))
        tip3:setColor(ccc3(0x78, 0x25, 0x00))
        tip3:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height - 210))
        
        local tip4 = CCLabelTTF:create(GetLocalizeStringBy("key_8227"), g_sFontName, 25)
        others.bg:addChild(tip4)
        tip4:setAnchorPoint(ccp(0.5, 0.5))
        tip4:setColor(ccc3(0x78, 0x25, 0x00))
        tip4:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height - 240))

        if LoyaltyData.isFunOpen(2) then
            local tip5 = CCLabelTTF:create(GetLocalizeStringBy("key_10281"), g_sFontName, 25)
            others.bg:addChild(tip5)
            tip5:setAnchorPoint(ccp(0.5, 0.5))
            tip5:setColor(ccc3(0x78, 0x25, 0x00))
            tip5:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height - 270))
        end
    else
        local richInfo = {}
        richInfo.elements = {}
        if _auto_gold_count > 0 then
            local element = {
                type = "CCSprite",
                image = "images/common/gold.png"
            }
            table.insert(richInfo.elements, element)
            local element = {
                text = _auto_gold_count
            }
            table.insert(richInfo.elements, element)
        end
        local element = {
                text = _auto_act_count
        }
        table.insert(richInfo.elements, element)
        if LoyaltyData.isFunOpen(2) then
            local element = {
                newLine = true,
                text = "\n" .. GetLocalizeStringBy("key_10281")
            }
            table.insert(richInfo.elements, element)
        end

        local newRichInfo = nil
        if _auto_gold_count <= 0 then
            newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10274"),  richInfo)
        else
            newRichInfo = GetNewRichInfo("key_8469", richInfo)
        end
        RichAlertTip.showAlert(newRichInfo, autoFind, true, nil, GetLocalizeStringBy("key_8129"))
    end
end

-- 确认自动寻宝
function autoFind(isConfirm, _argsCB)
    if isConfirm == false then
        return
    end
     if _auto_act_count > _map_info.act then
        SingleTip.showTip(GetLocalizeStringBy("key_8174"))
        return
    end
    if _auto_gold_count > UserModel.getGoldNumber() then
        SingleTip.showTip(GetLocalizeStringBy("key_8175"))
        return
    end
    FindTreasureService.dragonAiDo(handleAuto, {_selected_floor_index, _selected_box_index - 1}, _auto_gold_count, _auto_act_count, _selected_box_index, _selected_floor_index)
end


function handleAuto()
    if _selected_floor_index == 5 then
        FindTreasureService.dragonGetMap(handleGetMap, true)
    else
        FindTreasureService.dragonGetMap(handleGetMap)
    end
    AutoFindResultLayer.show(FindTreasureData.getAiDoData())
end

-- 创建上面要刷新的节点
function createRefreshNode()
    _refresh_node = CCNode:create()
    _layer:addChild(_refresh_node, 10)
    _refresh_node:setAnchorPoint(ccp(0.5, 1))
    _refresh_node:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height - 137 * g_fScaleX))
    _refresh_node:setContentSize(CCSizeMake(640, 150))
    _refresh_node_menu = CCMenu:create()
    _refresh_node:addChild(_refresh_node_menu)
    _refresh_node_menu:setPosition(ccp(0, 0))
    _refresh_node_menu:setContentSize(_refresh_node:getContentSize())
    _refresh_node_menu:setTouchPriority(_touch_priority - 10)
end

-- 创建顶部的节点
function createTopNode()
    _top_node = CCNode:create()
    _layer:addChild(_top_node, 10)
    _top_node:setScale(g_fScaleX / MainScene.elementScale)
    _top_node:setAnchorPoint(ccp(0.5, 1))
    _top_node:setPosition(g_winSize.width * 0.5, g_winSize.height - 25 * g_fScaleX)
    _top_node:setContentSize(CCSizeMake(640, 115))
    _top_node_menu= CCMenu:create()
    _top_node:addChild(_top_node_menu)
    _top_node_menu:setPosition(ccp(0, 0))
    _top_node_menu:setContentSize(_top_node:getContentSize())
    
    local back_btn = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
    _top_node_menu:addChild(back_btn)
    back_btn:setAnchorPoint(ccp(0.5, 0.5))
    back_btn:setPosition(ccp(587, 55))
    back_btn:registerScriptTapHandler(backCallback)
    
    local description_btn = CCMenuItemImage:create("images/recycle/btn/btn_explanation_h.png", "images/recycle/btn/btn_explanation_n.png")
    _top_node_menu:addChild(description_btn)
    description_btn:setAnchorPoint(ccp(0.5, 0.5))
    description_btn:setPosition(ccp(499, 55))
    description_btn:registerScriptTapHandler(descriptionCallback)
    
    local forge_btn = CCMenuItemImage:create("images/forge/forge_n.png", "images/forge/forge_h.png")
    _top_node_menu:addChild(forge_btn)
    forge_btn:setAnchorPoint(ccp(0.5, 0.5))
    forge_btn:setPosition(ccp(409, 58))
    forge_btn:registerScriptTapHandler(callbackForge)
    
    local exchange_btn = CCMenuItemImage:create("images/forge/exchange_n.png", "images/forge/exchange_h.png")
    _top_node_menu:addChild(exchange_btn)
    exchange_btn:setAnchorPoint(ccp(0.5, 0.5))
    exchange_btn:setPosition(ccp(314, 58))
    exchange_btn:registerScriptTapHandler(exchangeCallback)
    
    local spliter_sprite = CCSprite:create("images/common/separator_top.png")
    spliter_sprite:setPosition(ccp(_top_node:getContentSize().width * 0.5, 0))
    spliter_sprite:setAnchorPoint(ccp(0.5, 0.5))
    _top_node:addChild(spliter_sprite)
end

function refreshTitle( ... )
    if _title_sprite ~= nil and _title_sprite:getTag() ~= tonumber(_map_info.mode) then
        _title_sprite:removeFromParentAndCleanup(true)
        _title_sprite = nil
    end
    if _title_sprite == nil then
        local image = "images/forge/title.png"
        if _map_info.mode == "1" then
            image = "images/forge/title2.png"
        end
        _title_sprite = CCSprite:create(image)
        _top_node:addChild(_title_sprite)
        _title_sprite:setAnchorPoint(ccp(0.5, 0.5))
        _title_sprite:setPosition(105, 52)
        _title_sprite:setTag(tonumber(_map_info.mode))
    end
end

-- todo
function exchangeCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 寻龙积分兑换 by ZQ
    -- require "script/ui/exchange/FindLongExchangeLayer"
    -- local exchangeLayer = FindLongExchangeLayer.create()
    require "script/ui/shopall/FindLongExchangeLayer"
    FindLongExchangeLayer.show()
end

-- 打开说明界面
function descriptionCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/forge/FindTreasureDescLayer"
    require "script/ui/forge/FindTreasureDescLayer"

    FindTreasureDescLayer.show()
end

-- 返回到活动
function backCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/active/ActiveList"
    local  activeList = ActiveList.createActiveListLayer()
    MainScene.changeLayer(activeList, "activeList")
end

-- 跟踪到某一个精灵
function calibration(sprite, is_run_action, action_end_callfunc)
    local speed = 0.15 -- 移动100的时间
    local world_position = _map:convertToWorldSpace(ccp(sprite:getPositionX(), sprite:getPositionY()))
    local new_position = ccp(world_position.x, world_position.y)
    new_position.x = g_winSize.width * 0.5
    local offset = _scroll_view:getContentOffset()
    offset.x = offset.x + new_position.x - world_position.x
    offset = getOffset(_scroll_view, offset)
    if is_run_action == true then
        local old_offset = _scroll_view:getContentOffset()
        local time = speed * math.sqrt(math.pow(old_offset.x - offset.x, 2) + math.pow(old_offset.y - offset.y, 2)) / 100
        
        local args = CCArray:create()
        args:addObject(CCMoveBy:create(time, ccp(offset.x - old_offset.x, offset.y)))
        if action_end_callfunc ~= nil then
            args:addObject(CCCallFuncN:create(action_end_callfunc))
        end
        local action = CCSequence:create(args)
        _map:runAction(action)
    else
        _scroll_view:setContentOffset(offset)
    end
end

-- 刷新地块
function refreshBlocks()
    if _blocks_node == nil then
        _blocks_node = CCNode:create()
        _map:addChild(_blocks_node)
        _blocks_node:setContentSize(_map:getContentSize())
        _blocks_menu = BTSensitiveMenu:create()
        if _blocks_menu:retainCount() > 1 then
			_blocks_menu:release()
			_blocks_menu:autorelease()
		end
        _blocks_node:addChild(_blocks_menu, 10)
        _blocks_menu:setPosition(ccp(0, 0))
        _blocks_menu:setTouchPriority(_touch_priority - 9)
        _blocks_menu:setContentSize(_map:getContentSize())
        for i = 2, 6 do
            local block_sprite = CCSprite:create("images/forge/dizhuan_2.png")
            block_sprite:setScale(0.9)
            _blocks_node:addChild(block_sprite)
            block_sprite:setAnchorPoint(ccp(0.5, 0.5))
            local x = math.floor((i - 1) / _rows) * (_block_width + _block_space_x) + _block_width * 0.5
            local y = (_rows - (i - 1) % _rows) * (_block_height + _block_space_y) - _block_height * 0.5 - _block_space_y + _map_blocks_node_y
            block_sprite:setPosition(ccp(x, y))
        end
        _map_blocks = {}
    end
    local block_animation_infos = {
        ["2"] = "landi",
        ["3"] = "lvdi",
        ["1"] = "huangdi",
    }
    for i = 1, _cols * _rows do
        local block_info = _map_info.map[i]
        local old_block_info = nil
        if _old_map_info ~= nil then
            old_block_info = _old_map_info.map[i]
        end
        if old_block_info == nil or block_info.display ~= old_block_info.display or i == _old_map_info.posid or i == _map_info.posid then
            if _map_blocks[tostring(i)] ~= nil then
                _map_blocks[tostring(i)]:removeFromParentAndCleanup(true)
                _map_blocks[tostring(i)] = nil
            end
            local block_id = nil
            if block_info.display == 0 then
                if i == _map_info.posid then
                    block_id = 4
                else
                    block_id = 2
                end
            elseif block_info.display == 1 or block_info.display == 3 then
                block_id = 3
            elseif block_info.display == 2 then
                block_id = 1
            end
            if block_info.eid ~= 1 then
                local node_mormal = CCLayerColor:create(ccc4(100, 0, 0, 0), _block_width, _block_height)
                block_sprite = CCSprite:create(string.format("images/forge/dizhuan_%d.png", block_id))
                node_mormal:addChild(block_sprite)
                local block_animation_info = block_animation_infos[tostring(block_id)]
                --[[
                if false then
                   local action_sprite =  CCLayerSprite:layerSpriteWithName(CCString:create(string.format("images/treasure/effect/%s/%s", block_animation_info, block_animation_info)), -1,CCString:create(""));
                    node_mormal:addChild(action_sprite, -1)
                    action_sprite:setAnchorPoint(ccp(0.5, 0.5))
                    action_sprite:setPosition(ccp(_block_width * 0.5, _block_width * 0.5))
                end
                --]]
                
                block_sprite:setScale(0.9)
                block_sprite:setAnchorPoint(ccp(0.5, 0.5))
                block_sprite:setPosition(ccp(_block_width * 0.5, _block_height * 0.5))
                
                
                local block_btn = CCMenuItemSprite:create(node_mormal, node_mormal)
                _blocks_menu:addChild(block_btn)
                block_btn:setTag(i)
                block_btn:registerScriptTapHandler(callbackBlock)
                block_btn:setAnchorPoint(ccp(0.5, 0.5))
                local x = (math.floor((i - 1) / _rows) + 1) * (_block_width + _block_space_x) + _block_width * 0.5
                local y = (_rows - (i - 1) % _rows) * (_block_height + _block_space_y) - _block_height * 0.5 - _block_space_y + _map_blocks_node_y
                block_btn:setPosition(ccp(x, y))
                _map_blocks[tostring(i)] = block_btn
                
                --[[ test
                local label = CCLabelTTF:create(tostring(i), g_sFontName, 21)
                --block_btn:addChild(label)
                label:setPosition(ccp(50, 50))
                local event_id_label = CCLabelTTF:create(tostring(_map_info.map[i].eid), g_sFontName, 22)
                --block_btn:addChild(event_id_label)
                event_id_label:setPosition(ccp(10, 10))
                --]]
            end
        end
    end
end

-- 刷新地图背景
function refreshMap()
    local map_bg_size = CCSizeMake(83, g_winSize.height - 138 * g_fScaleX)
    _rows = FindTreasureData.getRows()
    _cols = FindTreasureData.getCols()
    if _scroll_view == nil then
        _scroll_view = CCScrollView:create()
        _layer:addChild(_scroll_view)
        _scroll_view:setPosition(ccp(g_winSize.width * 0.5, 0))
        _scroll_view:setTouchPriority(_touch_priority - 10)
        _scroll_view:setViewSize(CCSizeMake(g_winSize.width / MainScene.elementScale, map_bg_size.height / MainScene.elementScale))
        _scroll_view:ignoreAnchorPointForPosition(false)
        _scroll_view:setAnchorPoint(ccp(0.5, 0))
        _scroll_view:setBounceable(false)
        _scroll_view:setDirection(kCCScrollViewDirectionHorizontal)
        _map = CCNode:create()
        _scroll_view:setContainer(_map)
    else
        _map:removeAllChildrenWithCleanup(true)
        _map_sprites_node = nil
        _blocks_node = nil
        _player_arrows = nil
    end
    _scroll_view:setContentSize(CCSizeMake((_cols + 1) * (_block_width + _block_space_x) - _block_space_x + 20, map_bg_size.height / MainScene.elementScale + 2))
    _map:setPositionY(-1)
    _map_bg_node = CCNode:create()
    _map:addChild(_map_bg_node)
    _map_bg_node:setContentSize(_scroll_view:getContentSize())
    local bg_count = math.ceil(_scroll_view:getContentSize().width / map_bg_size.width)
    for i = 1, bg_count do
        local map_bg = CCSprite:create("images/forge/map_bg.png")
        _map_bg_node:addChild(map_bg)
        map_bg:setAnchorPoint(ccp(0, 1))
        map_bg:setPosition(ccp((i - 1) * map_bg_size.width, (map_bg_size.height - 25) / MainScene.elementScale))
    end
    local light_size = CCSizeMake(180, 100)
    local light_count = math.ceil(_scroll_view:getContentSize().width / light_size.width)
    for i = 1, light_count do
        local light_up = CCSprite:create("images/forge/light.png")
        _map:addChild(light_up, 30)
        light_up:setAnchorPoint(ccp(0, 1))
        light_up:setPosition(ccp((i - 1) * light_size.width, map_bg_size.height / MainScene.elementScale))
        local light_down = CCSprite:create("images/forge/light.png")
        _map:addChild(light_down, 30)
        light_down:setAnchorPoint(ccp(0, 1))
        light_down:setPosition(ccp((i - 1) * light_size.width, -5))
        light_down:setScaleY(-1)
    end
    local bg2_size = CCSizeMake(83, 651)
    local bg2_count = math.ceil(_scroll_view:getContentSize().width / bg2_size.width)
    for i = 1, bg2_count do
        local bg2 = CCSprite:create("images/forge/map_bg2.png")
        _map_bg_node:addChild(bg2)
        bg2:setAnchorPoint(ccp(0, 0.5))
        local y = 4 * (_block_height + _block_space_y) - _block_height * 0.5 - _block_space_y + _map_blocks_node_y
        bg2:setPosition(ccp((i - 1) * bg2_size.width, y))
    end
    local door = CCSprite:create("images/forge/door.png")
    _map:addChild(door, 20)
    door:setAnchorPoint(ccp(0, 0.5))
    door:setPosition(ccp(-10, 3 * (_block_height + _block_space_y) + _block_height * 0.5 + _map_blocks_node_y))
    refreshMist()
    refreshBlocks()
    refreshMapSprites()
    showDragTip()
end

-- 可滑动提示
function showDragTip()
    local drag_tip = CCSprite:create("images/forge/drag_tip.png")
    _layer:addChild(drag_tip)
    drag_tip:setAnchorPoint(ccp(1, 0.5))
    drag_tip:setPosition(ccp(g_winSize.width  - 80 * MainScene.elementScale, _map_blocks_node_y + 500 * MainScene.elementScale))
    local hand = CCSprite:create("images/forge/shou.png")
    drag_tip:addChild(hand)
    hand:setAnchorPoint(ccp(0.5, 1))
    local begin_point = ccp(140, 0)
    local end_point = ccp(-70, 0)
    local drag_time = 1.5
    hand:setPosition(begin_point)
    local args = CCArray:create()
    args:addObject(CCMoveBy:create(drag_time, end_point))
    args:addObject(CCPlace:create(begin_point))
    args:addObject(CCMoveBy:create(drag_time, end_point))
    local moveEndCallFunc = function()
        drag_tip:removeFromParentAndCleanup(true)
    end
    args:addObject(CCCallFunc:create(moveEndCallFunc))
    hand:runAction(CCSequence:create(args))
end

-- 刷新积分
function refreshPoint()
    if _point_label == nil then
        local point_title = CCSprite:create("images/forge/get_point.png")
        _refresh_node:addChild(point_title)
        point_title:setAnchorPoint(ccp(0, 0.5))
        point_title:setPosition(ccp(117, _refresh_node:getContentSize().height - 68))
        _point_label = CCRenderLabel:create(tostring(_map_info.point), g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        _point_label:setAnchorPoint(ccp(0, 0.5))
        _point_label:setPosition(ccp(240, _refresh_node:getContentSize().height - 68))
        _point_label:setColor(ccc3(0x00, 0xff, 0x18))
        _refresh_node:addChild(_point_label)
    else
        _point_label:setString(tostring(_map_info.point))
    end
end

-- 刷新第几层
function refreshFloor()
    if _floor_label == nil then
        local floor_title_bg = CCSprite:create("images/forge/floor_title_bg.png")
        _refresh_node:addChild(floor_title_bg)
        floor_title_bg:setAnchorPoint(ccp(0.5, 1))
        floor_title_bg:setPosition(ccp(_refresh_node:getContentSize().width * 0.5, _refresh_node:getContentSize().height - 5))
        _floor_label = CCRenderLabel:create("0", g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_shadow)
        floor_title_bg:addChild(_floor_label)
        _floor_label:setColor(ccc3(0xff, 0xf6, 0x00))
        _floor_label:setAnchorPoint(ccp(0.5, 0.5))
        _floor_label:setPosition(ccp(floor_title_bg:getContentSize().width * 0.5, floor_title_bg:getContentSize().height * 0.5))
    end
    local chinese_number = {"key_8107", "key_8108", "key_8109", "key_8110", "key_8111", "key_8112", "key_8113", "key_8114", "key_8115", "key_8116"}
    local floor_name = string.format(GetLocalizeStringBy("key_8117"), GetLocalizeStringBy(chinese_number[_map_info.floor]))
    if _map_info.floor == 5 then
        floor_name = GetLocalizeStringBy("key_10166")
    end
    _floor_label:setString(floor_name)
end

-- 刷新行动力
function refreshAct()
     if _act_label == nil then
        local act_title = CCSprite:create("images/forge/act.png")
        _act_title = act_title
        _refresh_node:addChild(act_title)
        act_title:setAnchorPoint(ccp(0, 0.5))
        act_title:setPosition(ccp(326, _refresh_node:getContentSize().height - 68))
        _act_label = CCRenderLabel:create(tostring(_map_info.act) .. "/" .. DB_Explore_long.getDataById(1).beginAct, g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        _refresh_node:addChild(_act_label)
        _act_label:setAnchorPoint(ccp(0, 0.5))
        _act_label:setPosition(ccp(426, _refresh_node:getContentSize().height - 68))
        _act_label:setColor(ccc3(0x00,0xff,0x18))
        local add_act_btn = CCMenuItemImage:create("images/forge/add_h.png", "images/forge/add_n.png", "images/forge/add_n.png")
        _refresh_node_menu:addChild(add_act_btn)
        add_act_btn:setAnchorPoint(ccp(0.5, 0.5))
        add_act_btn:setPosition(ccp(512, _refresh_node_menu:getContentSize().height - 68))
        add_act_btn:registerScriptTapHandler(buyActCallback)
        _add_act_btn = add_act_btn
    else
        _act_label:setString(tostring(_map_info.act) .. "/" .. DB_Explore_long.getDataById(1).beginAct)
    end
end

-- 购买行动力
function buyActCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    local map_db = _map_db
    local vip_limit = DB_Vip.getDataById(UserModel.getVipLevel() + 1).exploreLongActNum
    if _map_info.act >= 80 then
        SingleTip.showTip(GetLocalizeStringBy("key_8118"))
        return
    elseif _map_info.buyactnum == vip_limit then
        SingleTip.showTip(GetLocalizeStringBy("key_8119"))
        return
    end
    local args = {}
    args.title = GetLocalizeStringBy("key_8120")
    args.item_name = GetLocalizeStringBy("key_8121")
    args.count_limit = vip_limit  - _map_info.buyactnum
    if args.count_limit > 80 - _map_info.act then
        args.count_limit = 80 - _map_info.act
    end
    args.remain_count = vip_limit - _map_info.buyactnum
    args.getTotalPriceByCount = function(count)
        local total_gold_count = 0
        for i = 1, count do
            local gold_count = map_db.actPay[1] + map_db.addActPay[1] * (_map_info.buyactnum + i - 1)
            if gold_count > map_db.addActPay[2] then
                gold_count = map_db.addActPay[2]
            end
            total_gold_count = total_gold_count + gold_count
        end
        return total_gold_count
    end
    args.is_increase = true
    args.buyCallFunc = buyAct
    SelecteBuyCountLayer.show(args)
end

-- 购买行动力
function buyAct(count, total_gold_count)
    local map_db = _map_db
    if UserModel.getGoldNumber() < total_gold_count then
        SingleTip.showTip(GetLocalizeStringBy("key_8122"))
        return
    end
    FindTreasureService.dragonBuyAct(handleBuyAct, {0, count}, total_gold_count, count)
    _buy_act_count = count
    _buy_act_total_gold_count = total_gold_count
end

-- 购买行动力网络回调
function handleBuyAct()
    refreshAct()
    SelecteBuyCountLayer.close()
    SingleTip.showTip(GetLocalizeStringBy("key_8123"))
end

-- 刷新血槽
function refreshHp()
    local max_hp = FindTreasureData.getFormationMaxHp()
    local map_db = _map_db
     if _hp_label == nil then
        local hp_bg = CCScale9Sprite:create("images/achie/exp.png")
        _hp_bg = hp_bg
        _refresh_node:addChild(hp_bg)
        hp_bg:setAnchorPoint(ccp(0, 0.5))
        hp_bg:setPosition(ccp(212, _refresh_node:getContentSize().height - 118))
        hp_bg:setContentSize(CCSizeMake(244, hp_bg:getContentSize().height))
        local hp_title = CCRenderLabel:create(GetLocalizeStringBy("key_8124"), g_sFontPangWa, 21, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
        _refresh_node:addChild(hp_title)
        hp_title:setColor(ccc3(0xff, 0xf6, 0x00))
        hp_title:setAnchorPoint(ccp(0, 0.5))
        hp_title:setPosition(ccp(115, _refresh_node:getContentSize().height - 118))
        _hp_progress = CCScale9Sprite:create("images/forge/hp_bar.png")
        _hp_progress:setAnchorPoint(ccp(0, 0))
        _hp_progress:setPosition(ccp(26, 4))
        hp_bg:addChild(_hp_progress)
        _hp_label = CCRenderLabel:create(tostring(math.floor(_map_info.hppool / max_hp * 100)) .. "%/" .. tostring(map_db.beginHp) .. "%" , g_sFontName, 20, 1, ccc3(0x00,0x00,0x00), type_shadow)
        hp_bg:addChild(_hp_label)
        _hp_label:setAnchorPoint(ccp(0.5, 0))
        _hp_label:setPosition(ccp(hp_bg:getContentSize().width * 0.5, 5))
        _hp_label:setColor(ccc3(0x00,0xff,0x18))
        local add_hp_btn = CCMenuItemImage:create("images/forge/add_h.png", "images/forge/add_n.png", "images/forge/add_n.png")
        _refresh_node_menu:addChild(add_hp_btn)
        add_hp_btn:setAnchorPoint(ccp(0.5, 0.5))
        add_hp_btn:setPosition(ccp(482, _refresh_node_menu:getContentSize().height - 118))
        add_hp_btn:registerScriptTapHandler(buyHpCallback)
        _add_hp_btn = add_hp_btn
    else
        _hp_label:setString(tostring(math.floor(_map_info.hppool / max_hp * 100)) .. "%/" .. tostring(map_db.beginHp) .. "%")
    end
    local progress = math.floor(_map_info.hppool / max_hp * 100)
    if progress > map_db.beginHp then
        progress = map_db.beginHp
    end
    if progress == 0 then
        _hp_progress:setVisible(false)
    else
        _hp_progress:setVisible(true)
        _hp_progress:setPreferredSize(CCSizeMake(192 * progress / map_db.beginHp, 23))
    end
end

-- 刷新人物周围的箭头
function refreshArrows()
    if _player_arrows == nil then
        local player_size = _player:getContentSize()
        _player_arrows = CCNode:create()
        _map_sprites_node:addChild(_player_arrows)
        _player_arrows:setContentSize(player_size)
        _player_arrows:setAnchorPoint(ccp(0.5, 0.5))
        _player_arrows:setPosition(_player:getPosition())
        local distance = 60
        local arrows_infos = {}
        arrows_infos.R = {position = ccp(player_size.width * 0.5 + distance, player_size.height * 0.5), rotation = 0} -- 右
        arrows_infos.L = {position = ccp(player_size.width * 0.5 - distance, player_size.height * 0.5), rotation = 180} -- 左
        arrows_infos.U = {position = ccp(player_size.width * 0.5, player_size.height * 0.5 + distance), rotation = 270} -- 上
        arrows_infos.D = {position = ccp(player_size.width * 0.5, player_size.height * 0.5 - distance), rotation = 90} -- 下
        _arrows = {}
        for k, v in pairs(arrows_infos) do
            local arrows_info = v
            local arrows = CCLayerSprite:layerSpriteWithName(CCString:create("images/treasure/effect/jiantouzou/jiantouzou"), -1,CCString:create(""));
            _player_arrows:addChild(arrows)
            arrows:setScaleX(0.5)
            arrows:setAnchorPoint(ccp(0.5, 0.5))
            arrows:setPosition(arrows_info.position)
            arrows:setRotation(arrows_info.rotation)
            _arrows[k] = arrows
        end
    end
    local row, col =  FindTreasureData.getMapPosition(_player_index)
    local direction_infos = {}
    direction_infos.R = {1, 0}
    direction_infos.L = {-1, 0}
    direction_infos.U = {0, 1}
    direction_infos.D = {0, -1}
    for k, v in pairs(direction_infos) do
        local direction_info = v
        local index = FindTreasureData.getIndex(col + direction_info[1], row + direction_info[2])
        if index ~= -1 and _map_info.map[index].eid ~= 1 then
            _arrows[k]:setVisible(true)-- 右
        else
            _arrows[k]:setVisible(false)
        end
    end
    _player_arrows:setVisible(true)
    _player_arrows:setPosition(_player:getPosition())
end

-- 刷新所有事件icon
function refreshMapSprites()
    if _map_sprites_node == nil then
        _map_sprites_node = CCNode:create()
        _map:addChild(_map_sprites_node, 20)
        _map_sprites_node:setContentSize(_map:getContentSize())
        _map_sprites_node:setAnchorPoint(ccp(0, 0))
        _map_sprites_node:setPosition(ccp(0, 0))
        _player_index = _map_info.posid
        local sex = UserModel.getUserSex()
        if sex == 1 then
            _player = CCSprite:create("images/forge/nanzhujiao_1.png")
        elseif sex == 2 then
            _player = CCSprite:create("images/forge/nvzhujiao_1.png")
        end
        _map_sprites_node:addChild(_player, 10)
        _player:setAnchorPoint(ccp(0.5, 0.5))
        _player:setPosition(_map_blocks[tostring(_player_index)]:getPosition())
        -- _mist_sprite:refresh(ccp(_player:getPositionX(), _player:getPositionY() - _map_blocks_node_y))
        _map_sprites = {}
    end
    refreshArrows()
    for i = 1, _cols * _rows do
        local map_sprite = nil
        local map_block = _map_blocks[tostring(i)]
        if map_block ~= nil then
            local event_info = _map_info.map[i]
            local old_event_info = nil
            if _old_map_info ~= nil then
                old_event_info = _old_map_info.map[i]
            end
            if old_event_info == nil or event_info.display ~= old_event_info.display then
                if _map_sprites[tostring(i)] ~= nil then
                    _map_sprites[tostring(i)]:removeFromParentAndCleanup(true)
                    _map_sprites[tostring(i)] = nil
                end
                if event_info.display ~= 0 then
                    local event_db = DB_Explore_long_event.getDataById(event_info.eid)
                    local action = nil
                    if event_info.display == 2 then
                        map_sprite = CCSprite:create("images/forge/dizhuan_1.png")
                    else
                        map_sprite = CCSprite:create("images/forge/treasure_icon/" .. event_db.isIcon)
                        map_sprite:setScale(0.6)
                        local action_args = CCArray:create()
                        action_args:addObject(CCMoveBy:create(0.5, ccp(0, 10)))
                        action_args:addObject(CCMoveBy:create(0.5, ccp(0, -10)))
                        action = CCRepeatForever:create(CCSequence:create(action_args))
                        map_sprite:runAction(action)
                    end
                    if event_info.eid == 0 then
                         _map_sprites_node:addChild(map_sprite, 20)
                    else
                        _map_sprites_node:addChild(map_sprite)
                    end
                    map_sprite:setAnchorPoint(ccp(0.5, 0.5))
                    map_sprite:setPosition(map_block:getPosition())
                    _map_sprites[tostring(i)] = map_sprite
                end
            end
        end
    end
end

-- 进入铸造界面
function callbackForge()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    require "script/ui/forge/NewForgeLayer"
    NewForgeLayer.showLayer()
end

-- 重置地图
function resetMapCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local reset_limit = DB_Vip.getDataById(UserModel.getVipLevel() + 1).exploreLongNum
    local tip2 = GetLocalizeStringBy("key_8125")
    if _map_info.free_reset_num == 0 and reset_limit <= _map_info.resetnum then
        local resetItemInfo = FindTreasureData.getResetItemInfo()
        local itemCount = FindTreasureData.getItemResetCount() 
        if itemCount > 0 then
            _reset_map_gold_count = 0
            local richInfo = {}
            richInfo.elements = {
                {   
                    ["type"] = "CCSprite",
                    ["image"] = "images/common/compass_icon.png",
                },
                {
                    ["text"] = resetItemInfo[2],
                },
                {   
                    ["type"] = "CCSprite",
                    ["image"] = "images/common/compass_icon.png",
                },
                {
                    ["text"] = itemCount,
                },
            }
            local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10275") .. tip2, richInfo)
            RichAlertTip.showAlert(newRichInfo, retsetMap, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, 425)
        else
            SingleTip.showTip(GetLocalizeStringBy("key_8126"))
        end
    else
        local tip = nil
        if _map_info.free_reset_num > 0 then
            _reset_map_gold_count = 0
            tip = GetLocalizeStringBy("key_8127")
        else
            local map_db = _map_db
            if _map_info.resetnum == 1 then
                _reset_map_gold_count = map_db.resetPay
            else
                _reset_map_gold_count = map_db.resetPay + map_db.addPay[1] * (_map_info.resetnum - 1)
            end
            if _reset_map_gold_count > map_db.addPay[2] and map_db.addPay[2] ~= 0 then
                _reset_map_gold_count= map_db.addPay[2]
            end
            tip = string.format(GetLocalizeStringBy("key_8128"), _reset_map_gold_count)
        end
        require "script/ui/tip/AlertTip2"
        AlertTip2.showAlert(tip, tip2,retsetMap, true, nil, GetLocalizeStringBy("key_8129"))
    end
end

-- 确认重置的回调
function retsetMap(isConfirm, _argsCB)
    if isConfirm == false then
        return
    end
    if UserModel.getGoldNumber() < _reset_map_gold_count then
        SingleTip.showTip(GetLocalizeStringBy("key_8130"))
        return
    end
    FindTreasureResetDialog.show()
end




-- 查看阵型
function lookFormationCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    FindTreasureService.dragonGetUserBf(handleLookFormation)
end

function handleLookFormation(cbFlag, dictData, bRet)
    FindFormationLayer.show(FindTreasureData.getFormationInfo())
end

-- 购买血
function buyHpCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local map_db = _map_db
    _buy_hp_gold_count = map_db.hpPay[1] + map_db.addHpPay[1] * _map_info.buyhpnum
    if _buy_hp_gold_count > map_db.addHpPay[2] then
        _buy_hp_gold_count = map_db.addHpPay[2]
    end
    AlertTip.showAlert(string.format(GetLocalizeStringBy("key_8131"), _buy_hp_gold_count, map_db.hpPay[2]), buyHp, true, nil, GetLocalizeStringBy("key_8129"))
end

-- 确认购买血的回调
function buyHp(isConfirm, _argsCB)
    if isConfirm == false then
        return
    end
    local map_db = _map_db
    if UserModel.getGoldNumber() < _buy_hp_gold_count then
        SingleTip.showTip(GetLocalizeStringBy("key_8122"))
        return
    end
    FindTreasureService.dragonBuyHp(handleBuyHp, {0}, _map_db, _buy_hp_gold_count)
end

-- 买血成功
function handleBuyHp()
    local map_db = _map_db
    refreshHp()
    if _map_info.hppool == 0 then
        SingleTip.showTip(string.format(GetLocalizeStringBy("key_8132"), map_db.hpPay[2]))
    else
        SingleTip.showTip(string.format(GetLocalizeStringBy("key_8133"), map_db.hpPay[2]))
    end
end



function handleAutoMove(dictData)
    if dictData.ret == "false" or dictData.ret == false then
        print("路径没有通过服务器的验证")
        return
    end
    local path = {}
    for i = 1, #_path do
        local point = _path[i]
        local index = FindTreasureData.getIndex(point.x, point.y)
        local block = _map_blocks[tostring(index)]
        local to_position = ccp(block:getPositionX(), block:getPositionY())
        table.insert(path, to_position)
    end
    moveTo(path)
end

-- 点击地块的回调
function callbackBlock(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local index = tag
    local direction = FindTreasureData.getRelativePosition(index, _player_index)
    local could_move = false
    if direction == 6 then -- 下
        could_move = true
    elseif direction == 2 then -- 左
        could_move = true
    elseif direction == 8 then -- 右
        could_move = true
    elseif direction == 4 then -- 上
        could_move = true
    elseif direction == 5 then -- 原地
        return
    end
    if _map_info.map[index].display == 2 then
        return
    end
    _path = nil
    if could_move == false and _map_info.map[index].display == 0 then
        local index = tag
        require "script/ui/forge/PathUtil"
        local deleget = {}
        deleget.g = function(point1, point2)
            return math.abs(point1.x - point2.x) + math.abs(point1.y - point2.y)
        end
        deleget.h = deleget.g
        deleget.getValue = function(j, i)
            local index = FindTreasureData.getIndex(j, i)
            local map_info = _map_info.map[index]
            if map_info.display == 0 and map_info.eid ~= 1 then
                return 0
            end
            return 1
        end
        deleget.directions = {{-1, 0}, {0, -1}, {0, 1}, {1, 0}} -- 左，上，下，右
        deleget.width = _cols
        deleget.height = _rows
        
        local dest_row, dest_col = FindTreasureData.getMapPosition(tag)
        local dest_point = PathUtil.createPoint(dest_col, dest_row)
        local start_row, start_col = FindTreasureData.getMapPosition(_player_index)
        local start_point = PathUtil.createPoint(start_col, start_row)
        _path = PathUtil.findPath(deleget, start_point, dest_point)
        if _path ~= nil and checkMove() then 
            if _map_info.act > 0 then
                local args = {}
                for i = #_path - 1, 1, -1 do
                    local point = _path[i]
                    local index = FindTreasureData.getIndex(point.x, point.y)
                    table.insert(args, index -1)
                end
                _next_player_index = index
                FindTreasureService.dragonAutoMove(handleAutoMove, {args})
            else
                SingleTip.showTip(GetLocalizeStringBy("key_8433"))
            end
        end
        return
    end
    if could_move == true then
        if _map_info.map[_player_index].eid == 18000 then
            SingleTip.showTip(GetLocalizeStringBy("key_8134"))
            return
        end
    end
    if _map_info.map[index].display == 0 then
        if checkMove() == true then
            _next_player_index = index
            FindTreasureService.dragonMove(handleMove, {index - 1}, index)
        end
    elseif _map_info.map[index].display ~= 2 then
        local args = {}
        if could_move == true then
            args.moveCallFunc = function()
                local event_id = _map_info.map[index].eid
                if checkMove() == true then
                    _next_player_index = index
                    FindTreasureService.dragonMove(handleMove, {index - 1}, index)
                end
            end
        end
        local event_db = parseDB(DB_Explore_long_event.getDataById(_map_info.map[index].eid))
        TreasureDialog.previewTreasure(event_db, could_move, args)
    end
    --]]
end

-- 检察是否可移动（血和行动力的限制）
function checkMove()
    local could_move = true
    if _map_info.act == 0 then
        SingleTip.showTip(GetLocalizeStringBy("key_8135"))
        could_move = false
    elseif FindTreasureData.getFormationHp() <= 0 then
        SingleTip.showTip(GetLocalizeStringBy("key_8136"))
        could_move = false
    end
    return could_move
end

function setMapInfo( mapInfo )
    _map_info = mapInfo
end

-- 检察是否已经到终点
function checkEnd()
    local event_info = _map_info.map[ _player_index]
    print("checkEnd")
    print_t(event_info)
    if (event_info.status[4] == "1" or event_info.status[2] == "1") and (event_info.eid == 18000 or event_info.eid == 21000) then
        _end_layer = CCLayerColor:create(ccc4(0, 0, 0, 100), g_winSize.width / MainScene.elementScale, (_block_height + _block_space_y) * _rows)
        _end_layer:registerScriptHandler(onEndLayerEvent)
        _layer:addChild(_end_layer, 9)
        _end_layer:ignoreAnchorPointForPosition(true)
        _end_layer:setPosition(ccp(0, _map_blocks_node_y * MainScene.elementScale))
        local tip_bg = CCScale9Sprite:create("images/forge/tip_bg.png")
        _end_layer:addChild(tip_bg)
        tip_bg:setPreferredSize(CCSizeMake(577, 350))
        tip_bg:setAnchorPoint(ccp(0.5, 0.5))
        tip_bg:setPosition(ccp(_end_layer:getContentSize().width * 0.5, _end_layer:getContentSize().height * 0.5 + 100))
        local tip_title = CCSprite:create("images/forge/end_title.png")
        tip_bg:addChild(tip_title)
        tip_title:setAnchorPoint(ccp(0.5, 0.5))
        tip_title:setPosition(ccp(tip_bg:getContentSize().width * 0.5 + 18, tip_bg:getContentSize().height - 5))
        local richInfo = {}
        richInfo.alignment = 2 -- 对齐方式  1 左对齐，2 居中， 3右对齐
        richInfo.labelDefaultFont = g_sFontPangWa      -- 默认字体
        richInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)  -- 默认字体颜色
        richInfo.labelDefaultSize = 21          -- 默认字体大小
        richInfo.elements = {
            {
                newLine = true,
                text = _map_info.point,
                color = ccc3(0x00, 0xff, 0x18)
            }
        }
        local tip_node = GetLocalizeLabelSpriteBy_2("key_8434", richInfo)
        tip_bg:addChild(tip_node)
        tip_node:setAnchorPoint(ccp(0.5, 1))
        tip_node:setPosition(ccp(tip_bg:getContentSize().width * 0.5, tip_bg:getContentSize().height - 35))
    
        local move_data = FindTreasureData.getMoveData()
        if move_data.other.drop ~= nil and table.isEmpty(move_data.other.drop) == false then
            local center_bar = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
            tip_bg:addChild(center_bar)
            center_bar:setPreferredSize(CCSizeMake(420, 140))
            center_bar:setAnchorPoint(ccp(0.5, 0.5))
            center_bar:setPosition(ccp(tip_bg:getContentSize().width * 0.5 + 18, 160))

            local title = CCRenderLabel:create(GetLocalizeStringBy("zzh_1185"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
            center_bar:addChild(title)
            title:setColor(ccc3(0xff, 0xf6, 0x00))
            title:setAnchorPoint(ccp(0.5, 0.5))
            title:setPosition(ccp(center_bar:getContentSize().width * 0.5, center_bar:getContentSize().height))

            local item_id = nil
            local item_count = nil
            for k, v in pairs(move_data.other.drop.item) do
               item_id = tonumber(k)
               item_count = tonumber(v)
            end
            local item_normal = DB_Item_normal.getDataById(item_id)
            local goodsValues = {}
            goodsValues.type = "item"
            goodsValues.tid = item_id
            goodsValues.num = item_count
            local icon= ItemUtil.createGoodsIcon(goodsValues, -700, 1010, -800, nil)
            center_bar:addChild(icon)
            icon:setAnchorPoint(ccp(0.5, 0.5))
            icon:setPosition(ccp(100, center_bar:getContentSize().height * 0.5 + 5))
            
            local name_label = CCRenderLabel:create(item_normal.name, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
            --icon:addChild(name_label)
            name_label:setColor(ccc3(0xff, 0xf6, 0x00))
            name_label:setAnchorPoint(ccp(0.5, 1))
            name_label:setPosition(ccp(icon:getContentSize().width * 0.5, -8))
            local desc = CCLabelTTF:create(item_normal.desc, g_sFontPangWa, 21)
            center_bar:addChild(desc)
            desc:setAnchorPoint(ccp(0, 0.5))
            desc:setPosition(ccp(icon:getPositionX() + 60, center_bar:getContentSize().height * 0.5 - 10))
            desc:setDimensions(CCSizeMake(240, 110))
            desc:setHorizontalAlignment(kCCTextAlignmentLeft)
        else
            local subHeight = 140
            tip_bg:setPreferredSize(CCSizeMake(577, 210))
            tip_node:setPositionY(tip_node:getPositionY() - subHeight)
            tip_title:setPositionY(tip_title:getPositionY() - subHeight)
        end
        local menu = CCMenu:create()
        tip_bg:addChild(menu)
        menu:setPosition(ccp(0, 0))
        menu:setContentSize(tip_bg:getContentSize())
        menu:setTouchPriority(_touch_priority - 21)
       if _map_info.free_reset_num > 0 then
            text = GetLocalizeStringBy("key_8104")
        else
            text = GetLocalizeStringBy("key_8105")
        end
        local reset_map_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), text, ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        menu:addChild(reset_map_btn)
    
        reset_map_btn:setAnchorPoint(ccp(0.5, 0.5))
        reset_map_btn:setPosition(ccp(tip_bg:getContentSize().width * 0.5 + 18, 45))
        reset_map_btn:registerScriptTapHandler(resetMapCallback)
        _add_hp_btn:setEnabled(false)
        _add_act_btn:setEnabled(false)
        return true
    end
    return false
end

-- 到终点后屏蔽地块的点击
function onTouchesHandler(event, x, y)
    local point = ccp(x, y)
    local bounding_box = _end_layer:boundingBox()
    if bounding_box:containsPoint(point) then
        return true
    end
    return false
end

function onLayerEvent(event_type)
    if event_type == "enter" then
        playBgm()
	elseif event_type == "exit" then
        AudioUtil.playMainBgm()
    end
end

function playBgm()
    if(Platform.getOS() ~= "wp")then
        AudioUtil.playBgm("audio/bgm/" .. _bg_music)
    end
end

function onEndLayerEvent(event_type)
    if event_type == "enter" then
        _end_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority - 20, true)
        _end_layer:setTouchEnabled(true)
	elseif event_type == "exit" then
		_end_layer:unregisterScriptTouchHandler()
    end
end

-- 移动结束
function moveEnd()
    _old_map_info = table.hcopy(_map_info, {})
    _player_index = _next_player_index
    _blocks_menu:setTouchEnabled(true)
    _scroll_view:setTouchEnabled(true)
    print("player_index=", _player_index)
    local event_info = _map_info.map[_player_index]
    if checkEnd() == false and event_info.status[1] == "0" and event_info.status[2] == "0" then
        if event_info.eid ~= 0 then
            event_info.status[1] = "1"
            event_info.display = 0
        end
        local event_db = parseDB(DB_Explore_long_event.getDataById(event_info.eid))
        if event_db.exploreType ~= 0 then
            local dialogCloseCallFunc = nil
            local args = nil
            if event_db.exploreConditions[1] == 10 then -- 换位
                dialogCloseCallFunc = function(args)
                    exchangePosition(event_db.exploreConditions[2])
                end
            elseif event_db.exploreConditions[1] == 9 then -- 指路
                dialogCloseCallFunc = function(args)
                    showAllBlock()
                    refreshBlocks()
                    --showBlock(event_db.exploreConditions[2])
                end
            elseif event_db.exploreConditions[1] == 17 then -- 下一层
                SingleTip.showTip(GetLocalizeStringBy("key_8139"))
                FindTreasureService.dragonGetMap(handleGetMap)
                return
            elseif event_db.exploreConditions[1] == 11 then
                 FindTreasureData.bomb(_player_index)
            end
            local dialog_call_func_info = {
                closeCallFunc = dialogCloseCallFunc,
                close_call_func_args = args
            }
            if event_db.exploreType == 8 then
                FindTreasureTrialLayer.show(_touch_priority - 22, 1000, event_db.id, false, backFromTrialLayerCallback)
            else
                TreasureDialog.show(event_db, dialog_call_func_info)
            end
            if event_db.exploreConditions[1] == 5 then
                refreAddtion(event_db.exploreConditions[2] / 100)
            end
        end
    end
    FindTreasureData.setPlayerIndex(_player_index)
    refreshBlocks()
    refreshMapSprites()
    refreshAct()
    refreshFloor()
    refreshHp()
    refreshPoint()
    _old_map_info = nil
end


-- 点亮所有的地块
function showAllBlock()
    FindTreasureData.showAllBlock()
    refreshMapSprites()
end

-- 检测位置是否触发事件
function checkTreasure(index)
    local event_info = _map_info.map[_player_index]
    print("event_info======", index)
    print_t(event_info)
    if checkEnd() == true  or (event_info.status[4] == "1" or event_info.status[2] == "1") then
        return
    end
    print(event_info.eid)
    local event_db = parseDB(DB_Explore_long_event.getDataById(event_info.eid))
    if event_db.exploreType == 8 then
        FindTreasureTrialLayer.show(_touch_priority - 22, 1000, event_db.id, false, backFromTrialLayerCallback)
    else
        TreasureDialog.show(event_db, nil)
    end
end

function backFromTrialLayerCallback( ... )
    checkEnd()
    refreshAct()
    refreshFloor()
    refreshHp()
    refreshPoint()
end

-- 让某一地块的迷雾消失
--[[
function showBlock(index)
    local args = CCArray:create()
    local showStartCallFunc = function(node)
        calibration(_map_sprites[index])
    end
    args:addObject(CCCallFuncN:create(showStartCallFunc))
    local showCallFunc = function()
        local args = CCArray:create()
        local event_sprite = CCSprite:create("images/item/bg/itembg_1.png")
        _map_sprites_node:addChild(event_sprite, -1)
        event_sprite:setAnchorPoint(ccp(0.5, 0.5))
        event_sprite:setPosition(ccp(_map_blocks[index]:getPosition()))
        args:addObject(CCFadeOut:create(10))
        local fadeInEndCallFunc = function(node)
            node:removeFromParentAndCleanup(true)
            calibration(_player)
        end
        args:addObject(CCCallFuncN:create(fadeInEndCallFunc))
        local action = CCSequence:create(args)
        _map_sprites[index]:runAction(action)
        _map_sprites[index] = event_sprite
    end
    args:addObject(CCCallFunc:create(showCallFunc))
    local action = CCSequence:create(args)
    _player:stopAllActions()
    _player:runAction(action)
end
--]]

-- 换位
function exchangePosition(to_index)
    _blocks_menu:setTouchEnabled(false)
    local args = CCArray:create()
    args:addObject(CCScaleTo:create(0.5, 0.1))
    local exchangeStartCallFunc = function()
        calibration(_map_blocks[tostring(to_index)])
        _player:setPosition(_map_blocks[tostring(to_index)]:getPosition())
    end
    args:addObject(CCCallFunc:create(exchangeStartCallFunc))
    args:addObject(CCScaleTo:create(0.5, 1))
    local exchangeEndCallback = function()
        _next_player_index = to_index
        moveEnd()
    end
    args:addObject(CCCallFunc:create(exchangeEndCallback))
    local action = CCSequence:create(args)
    _player:stopAllActions()
    _player:runAction(action)
    _player_arrows:setVisible(false)
end

-- 拉取地图信息的网络回调
function handleGetMap(isNotCheckTreasure)
    _map_info = FindTreasureData.getMapInfo()
    _old_map_info = nil
    refreshMap()
    refreshAct()
    refreshFloor()
    refreshPoint()
    refreshHp()
    refreshBtn()
    refreshTitle()
    calibration(_player)
    if isNotCheckTreasure ~= true then
        checkTreasure(_map_info.posid)
    end

    -- 新手引导
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
            -- 寻龙探宝
            addGuideXunLongGuide3()
        end))
    _layer:runAction(seq)
end

-- 重置的网络回调
function handleResetMap(dictData)
    local map_db = _map_db
    _reset_data = {["dictData"] = dictData}
    FindTreasureService.dragonGetUserBf(handleFormation)
    if _map_info.free_reset_num == 0  and _map_info.resetnum == 0 then
        refreshBtn()
    end
    if _end_layer ~= nil then
        _end_layer:removeFromParentAndCleanup(true)
        _end_layer = nil
    end
    _add_act_btn:setEnabled(true)
    _add_hp_btn:setEnabled(true)
    refreAddtion(0)
    refreshMap()
    refreshAct()
    refreshFloor()
    refreshPoint()
    refreshHp()
    refreshBtn()
    refreshTitle()
    calibration(_player)
end

-- 移动的网络回调
function handleMove()
    local block_btn = _map_blocks[tostring(_next_player_index)]
    local path = {}
    local to_position = ccp(block_btn:getPositionX(), block_btn:getPositionY())
    table.insert(path, to_position)
    local cur_position = ccp(_player:getPositionX(), _player:getPositionY())
    table.insert(path, cur_position)
    moveTo(path)
end

function moveTo(path)
    _blocks_menu:setTouchEnabled(false)
    _scroll_view:setTouchEnabled(false)
    _player_arrows:setVisible(false)
    --[[
    local time = _speed * math.sqrt(math.pow(to_position.x - _player:getPositionX(), 2) + math.pow(to_position.y - _player:getPositionY(), 2)) / 100
     --]]
    local player_args = CCArray:create()
    local map_args = CCArray:create()
    for i = #path - 1, 1, -1 do
        local player_time = _speed * _block_width / 100
        local to_position = path[i]
        local cur_position = path[i + 1]
        player_args:addObject(CCMoveTo:create(player_time, to_position))
        local curMoveEnd = function()
            local index = nil
            if _path ~= nil then
                index = FindTreasureData.getIndex(_path[i].x, _path[i].y)
            else
                index = _next_player_index
            end
            FindTreasureData.setPlayerIndex(index)
            refreshBlocks()
            refreshMapSprites()
            _player_arrows:setVisible(false)
        end
        player_args:addObject(CCCallFunc:create(curMoveEnd))
        
        local world_position = _map:convertToWorldSpace(to_position)
        local distance_x = cur_position.x - to_position.x
        if (distance_x > 0 and world_position.x <= _player_world_x_min)  or (distance_x < 0 and world_position.x >= _player_world_x_max) then
            local offset = _scroll_view:getContentOffset()
            local to_offset = ccp(offset.x + distance_x, offset.y)
            to_offset = getOffset(_scroll_view, to_offset)
            distance_x = to_offset.x - offset.x
            local map_time = _speed * math.abs(distance_x) / 100
            if map_time > 0 then
                map_args:addObject(CCMoveBy:create(map_time, ccp(distance_x, 0)))
                if map_time < player_time then
                    map_args:addObject(CCDelayTime:create(player_time - map_time))
                elseif map_time == player_time then
                else
                    print("时间计算有误")
                end
            end
        else
            map_args:addObject(CCDelayTime:create(player_time))
        end
    end
    player_args:addObject(CCCallFunc:create(moveEnd))
    _player:runAction(CCSequence:create(player_args))
    if map_args:count() >= 1 then
        _map:runAction(CCSequence:create(map_args))
    end
end

-- 较正偏移量，不超过界限
function getOffset(scrollview, offset)
    local content_size = scrollview:getContentSize()
    local view_size = scrollview:getViewSize()
    local container = scrollview:getContainer()
    local offset_min_x = view_size.width - content_size.width * container:getScaleX()
    local offset_min_y = view_size.height - content_size.height * container:getScaleY()
    local offset_min = ccp(offset_min_x, offset_min_y)
    local offset_max = ccp(0, 0)
    local offset_x = math.max(offset_min.x, math.min(offset_max.x, offset.x))
    local offset_y = math.max(offset_min.y, math.min(offset_max.y, offset.y));
    return ccp(offset_x, offset_y)
end

-- 拉取阵型的网络回调
function handleFormation()
    if _reset_data ~= nil then
        handleGetMap()
        _reset_data = nil
    end
end

function getHpBg()
    return _hp_bg
end

function getActTitle()
    return _act_title
end

---[==[寻龙 第3步
---------------------新手引导---------------------------------
function addGuideXunLongGuide3( ... )
    require "script/guide/NewGuide"
    require "script/guide/XunLongGuide"
    if(NewGuide.guideClass ==  ksGuideFindDragon and(XunLongGuide.stepNum == 2002 or XunLongGuide.stepNum == 2) ) then
        XunLongGuide.show(3, nil)
    end
end
---------------------end-------------------------------------
--]==]
return nil


