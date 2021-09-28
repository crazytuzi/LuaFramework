-- Filename: LordWar32Layer.lua
-- Author: bzx
-- Date: 2014-08-05
-- Purpose: 跨服赛32进4

module("LordWar32Layer", package.seeall)

require "script/ui/lordWar/LordWarUtil"
require "script/libs/LuaCCSprite"
require "script/ui/lordWar/LordWarData"
require "script/utils/TimeUtil"
require "script/ui/tip/SingleTip"
require "script/ui/lordWar/LordWarUtil"
require "script/ui/lordWar/LordWarCheerLayer"

-- 32进4和4进1界面的按钮状态
BtnStatus = {
    cheer_disabled = 1, -- 助威不可点击
    cheer = 2,          -- 助威
    look_disabled = 3,  -- 查看不可点击
    look = 4            -- 查看
}

local _layer
local _top_node                     -- 上部分节点
local _bottom_node                  -- 下部分节点
local _touch_priority       = -180  -- 本层触摸优先级
local _remain_time_label
local _remain_title_label           
local _time_bg
local _remain_time_node             -- 轮次的剩余时间
local _calculating_label            -- 结算中
local _stage_label                  -- 当前排名
local _table_view                   -- 滑动层
local _arrow_right                  -- 右箭头
local _arrow_left                   -- 左箭头
local _drag_began_x                 -- 触摸开始时_table_view的x偏移量
local _touch_began_x                -- 触摸的开始位置
local _cell_size                    -- cell的尺寸
local _offset                       -- tableView的偏移量
local _page_index                   -- 当前组别
local _is_handle_touch              -- 是否处理本次触摸事件
local _stage                        -- 当前排名
local _schedule_node                -- 绑定定时器的节点
local _schedule_functions           -- 定时执行的方法的集合            
local _cur_time                     -- 当前时间
local _lord_type                    -- 两大组中的哪一组
local _cell_data                    -- 每个cell的信息            
local _is_running                   -- 本层是否在舞台上
local _innerOrCross
local _title 

function show(p_InnerOrCross)
    local layer = create(p_InnerOrCross)
    MainScene.changeLayer(layer, "LordWar32Layer")
end

function init(p_InnerOrCross)
    _refre_label = nil
    _remain_time_label = nil
    _remain_time_node = nil
    _calculating_label = nil
    _stage_label = nil
    _table_view = nil
    _arrow_left = nil
    _arrow_right = nil
    _arrow_right = 0
    _innerOrCross = p_InnerOrCross
    _stage = LordWarData.getCurRound()
    _schedule_functions = {}
    _schedule_node = nil
    _layer = nil
    _is_running = true
    _offset = nil
    initPositions()
end

function initPositions()
    local l = function(position, scale_x, scale_y, rotation)
        return {["position"] = position, ["scale_x"] = scale_x, ["scale_y"] = scale_y, ["rotation"] = rotation}
    end
    _cell_data = {
        [32] = {
            hero_positions = {
                ccp(70, 530), ccp(222, 530), ccp(70, 127), ccp(222, 127),
                ccp(418, 530), ccp(570, 530), ccp(418, 127), ccp(570, 127)
            },
            line_datas = {
                l(ccp(102, 442)), l(ccp(190, 442), -1, 1), l(ccp(102, 165), 1, -1), l(ccp(190, 165), -1, -1), 
                l(ccp(450, 442)), l(ccp(538, 442), -1, 1), l(ccp(450, 165), 1, -1), l(ccp(538, 165), -1, -1)
            },
            btn_positions = {
                ccp(143, 420), ccp(143, 190), ccp(492, 420), ccp(492, 190)
            }
        },
        [16] = {
            line_datas = {
                l(ccp(145, 380), nil, nil, 90), l(ccp(145, 236), nil, nil, 90), 
                l(ccp(495, 380), nil, nil, 90), l(ccp(495, 236), nil, nil, 90)
            },
            btn_positions = {
                ccp(50, 310), ccp(590, 310)
            }
        },
        [8] = {
            hero_positions = {
                ccp(143, 322), ccp(497, 322)
            },
            line_datas = {
                l(ccp(225, 307)), l(ccp(415, 307))
            },
            btn_positions = {
                ccp(320, 161)
            }
        },
        [4] = {
            hero_positions = {
                ccp(319, 301)
            },
        }
    }
end

function create(p_InnerOrCross)
    init(p_InnerOrCross)
    MainScene.setMainSceneViewsVisible(false, false, false)
    _layer = CCLayer:create()
    _layer:registerScriptHandler(onNodeEvent)
    loadBg()
    loadTop()
    loadBottom()
    loadTableView()
    scheduleTime()
    startSchedule()
    registerCallback()
    return _layer
end

function loadBg()
    local bg = CCSprite:create("images/lord_war/bg.jpg")
    _layer:addChild(bg)
    bg:setAnchorPoint(ccp(0.5, 0.5))
    bg:setPosition(ccpsprite(0.5, 0.5, _layer))
    bg:setScale(MainScene.bgScale)
end

function refresh(p_round, p_status, event)
    if event ~= "roundChange" then
        return
    end
    if _is_running == true then
        print("在lordWar32Layer界面，刷新")
        local handleRefresh = function()
            if p_status == LordWarData.kRoundFighted then
                LordWarData.setShowWinEffect(true)
            end
            refreshTableView()
            LordWarData.setShowWinEffect(false)
            print("p_round=", p_round, "p_status=", p_status)
            if (p_round == LordWarData.kInner8To4  or p_round == LordWarData.kCross8To4) and p_status >= LordWarData.kRoundFighted then
                local actions = CCArray:create()
                actions:addObject(CCDelayTime:create(3))
                actions:addObject(CCCallFunc:create(showLordWar4Layer))
                _layer:runAction(CCSequence:create(actions))
            end
        end
        if p_status == LordWarData.kRoundFighted then
            LordWarService.getPromotionInfo(handleRefresh)
            if p_round == LordWarData.kInner8To4 or p_round == LordWarData.kCross8To4 then
                _is_running = false
            end
        else
            refreshTableView()
        end
    else
        print("不在lordWar32Layer界面，不刷新")
    end
end

function showLordWar4Layer()
    LordWarCheerLayer.close()
    LordWar4Layer.show()
end

function registerCallback()
    LordWarEventDispatcher.addListener("LordWar32Layer.refresh", refresh)
end

function refreshTableView()
    _table_view:reloadData()
    if _offset ~= nil then
        _table_view:setContentOffset(_offset)
    end
end

function loadTop()
    _top_node = CCNode:create()
    _layer:addChild(_top_node)
    _top_node:setAnchorPoint(ccp(0.5, 1))
    _top_node:setPosition(ccpsprite(0.5, 1, _layer))
    _top_node:setScale(g_fScaleX)
    _top_node:setContentSize(CCSizeMake(640, 256))
    
    _title = LordWarUtil.createTitleSprite()
    _top_node:addChild(_title)
    _title:setAnchorPoint(ccp(0.5, 0.5))
    _title:setPosition(ccp(320, 224))
    
    local roundTitle = LordWarUtil.getRoundTitle()
    _top_node:addChild(roundTitle)
    roundTitle:setAnchorPoint(ccp(0.5, 0.5))
    roundTitle:setPosition(ccp(320, 180))
    
    local timeTitleNode = LordWarUtil.getTimeTitle()
    _top_node:addChild(timeTitleNode)
    timeTitleNode:setAnchorPoint(ccp(0.5, 0.5))
    timeTitleNode:setPosition(320, 128)
    
    local menu = CCMenu:create()
    _top_node:addChild(menu)
    menu:setAnchorPoint(ccp(0, 0))
    menu:setPosition(ccp(0, 0))
    menu:setContentSize(_top_node:getContentSize())
    menu:setTouchPriority(_touch_priority - 1)
    
    local desc_btn = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
    menu:addChild(desc_btn)
    desc_btn:setAnchorPoint(ccp(0.5, 0.5))
    desc_btn:setPosition(ccp(56, 199))
    desc_btn:registerScriptTapHandler(descCallback)
     
    local back_btn = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
    menu:addChild(back_btn)
    back_btn:setAnchorPoint(ccp(0.5, 0.5))
    back_btn:setPosition(ccp(588, 213))
    back_btn:registerScriptTapHandler(backCallback)
    
    local radio_data = {
        touch_priority      = _touch_priority -1,
        space               = 71,
        callback            = groupCallback,
        direction           = 1,
        items               = {}
    }
    local size = CCSizeMake(238, 89)
    local items_data = {
        {
            normal_image = "images/lord_war/audio_btn2_n.png",
            selected_image = "images/lord_war/audio_btn2_h.png",
            arrow = "images/lord_war/arrow2.png",
            text = GetLocalizeStringBy("key_8237"),
            normal_color = ccc3(0xff, 0xff, 0xff),
            selected_color = ccc3(0xAC, 0x85, 0xC6)
        },
        {
            normal_image = "images/lord_war/audio_btn1_n.png",
            selected_image = "images/lord_war/audio_btn1_h.png",
            arrow = "images/lord_war/arrow1.png",
            text = GetLocalizeStringBy("key_8238"),
            normal_color = ccc3(0xff, 0xff, 0xff),
            selected_color = ccc3(0x8c, 0xc5, 0x84)
        }
    }
    for i = 1, #items_data do
        local item_data = items_data[i]
         local normal = CCScale9Sprite:create(item_data.normal_image)
        normal:setPreferredSize(size)
        local normal_label = CCLabelTTF:create(item_data.text, g_sFontPangWa, 33)
        normal:addChild(normal_label)
        normal_label:setColor(item_data.normal_color)
        normal_label:setAnchorPoint(ccp(0.5, 0.5))
        normal_label:setPosition(ccpsprite(0.5, 0.55, normal))
        local selected = CCScale9Sprite:create(item_data.selected_image)
        selected:setPreferredSize(size)
        local arrow = CCSprite:create(item_data.arrow)
        selected:addChild(arrow)
        arrow:setAnchorPoint(ccp(0.5, 0))
        arrow:setPosition(ccpsprite(0.5, 0, selected))
        local selected_label = CCLabelTTF:create(item_data.text, g_sFontPangWa, 33)
        selected:addChild(selected_label)
        selected_label:setColor(item_data.selected_color)
        selected_label:setAnchorPoint(ccp(0.5, 0.5))
        selected_label:setPosition(ccpsprite(0.5, 0.55, selected))
        radio_data.items[i] = CCMenuItemSprite:create(normal, nil, selected)
    end
    local group_menu = LuaCCSprite.createRadioMenuWithItems(radio_data)
    _top_node:addChild(group_menu)
    group_menu:setAnchorPoint(ccp(0.5, 0.5))
    group_menu:setPosition(ccp(320, 59))
    
    local line = CCSprite:create("images/common/separator_top.png")
    line:setPosition(ccp(320, 0))
    line:setAnchorPoint(ccp(0.5, 0.5))
    _top_node:addChild(line)
end

function loadBottom()
    _bottom_node = CCNode:create()
    _layer:addChild(_bottom_node)
    _bottom_node:setScale(g_fScaleX)
    _bottom_node:setContentSize(CCSizeMake(640, 95))
    _bottom_node:setAnchorPoint(ccp(0.5, 0))
    _bottom_node:setPosition(ccpsprite(0.5, 0, _layer))
    
    local line = CCSprite:create("images/common/separator_top.png")
    _bottom_node:addChild(line)
    line:setScaleY(-1)
    line:setPosition(ccp(320, _bottom_node:getContentSize().height))
    line:setAnchorPoint(ccp(0.5, 0.5))

    local menu = CCMenu:create()
    _bottom_node:addChild(menu)
    menu:setContentSize(_bottom_node:getContentSize())
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touch_priority - 500)
    
    local my_info_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(260, 73), GetLocalizeStringBy("key_8239"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(my_info_btn)
    my_info_btn:setAnchorPoint(ccp(0.5, 0.5))
    my_info_btn:setPosition(ccp(186, 48))
    my_info_btn:registerScriptTapHandler(myInfoCallback)
    
    local refresh_fight_info_node = LordWarUtil.createUpdateInfoButton("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(260, 73), 
    menu:getTouchPriority())
    _bottom_node:addChild(refresh_fight_info_node)
    refresh_fight_info_node:setAnchorPoint(ccp(0.5, 0.5))
    refresh_fight_info_node:setPosition(ccp(458, 48))
end

function loadTableView()
    _cell_size = CCSizeMake(g_winSize.width, g_winSize.height - _top_node:getContentSize().height * g_fScaleX - _bottom_node:getContentSize().height * g_fScaleX)
	local table_view_event = LuaEventHandler:create(function(function_name, table_t, index, cell)
		if function_name == "cellSize" then
			return _cell_size
		elseif function_name == "cellAtIndex" then
            cell = createCell(index)
            return cell
		elseif function_name == "numberOfCells" then
            return 4
		elseif function_name == "cellTouched" then
		elseif (function_name == "scroll") then
            if _arrow_left == nil then
                return
            end
            local offset = _table_view:getContentOffset()
            if offset.x <= -_cell_size.width then
                _arrow_left:setVisible(true)
                if offset.x <= -_cell_size.width * 3 then
                    _arrow_right:setVisible(false)
                else
                    _arrow_right:setVisible(true)
                end
            else
                _arrow_left:setVisible(false)
            end
		end
	end)
	_table_view = LuaTableView:createWithHandler(table_view_event, _cell_size)
    _layer:addChild(_table_view)
    _table_view:ignoreAnchorPointForPosition(false)
    _table_view:setAnchorPoint(ccp(0.5, 0.5))
    _table_view:setTouchEnabled(false)
	_table_view:setPosition(ccp(g_winSize.width * 0.5, _cell_size.height * 0.5 + _bottom_node:getContentSize().height * g_fScaleX))
    _table_view:setDirection(kCCScrollViewDirectionHorizontal)
    _table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    _table_view:setTouchPriority(_touch_priority - 2)
    if _offset ~= nil then
        _table_view:setContentOffset(_offset)
    else
        local page_index = LordWarData.getMyPageIndex(_lord_type)
        _table_view:setContentOffset(ccp(-(page_index - 1) * _cell_size.width, _table_view:getContainer():getPositionY()))
        _offset = _table_view:getContentOffset()
    end
    _arrow_left = CCSprite:create( "images/common/arrow_up_h.png")
    _layer:addChild(_arrow_left)
    _arrow_left:setAnchorPoint(ccp(0.5, 0.5))
    _arrow_left:setPosition(ccp(30 * g_fScaleX, _table_view:getPositionY() + 50 * g_fScaleX))
    _arrow_left:setRotation(-90)
    _arrow_left:setVisible(false)
    _arrow_left:setScale(g_fScaleX)
    local arrow_left_array = CCArray:create()
    arrow_left_array:addObject(CCFadeIn:create(1))
    arrow_left_array:addObject(CCFadeOut:create(1))
    _arrow_left:runAction(CCRepeatForever:create(CCSequence:create(arrow_left_array)))
    _arrow_right = CCSprite:create( "images/common/arrow_up_h.png")
    _layer:addChild(_arrow_right)
    _arrow_right:setPosition(ccp(g_winSize.width - 30 * g_fScaleX, _table_view:getPositionY() + 50 * g_fScaleX))
    _arrow_right:setAnchorPoint(ccp(0.5, 0.5))
    _arrow_right:setRotation(90)
    _arrow_right:setScale(g_fScaleX)
    local arrow_right_array = CCArray:create()
    arrow_right_array:addObject(CCFadeIn:create(1))
    arrow_right_array:addObject(CCFadeOut:create(1))
    _arrow_right:runAction(CCRepeatForever:create(CCSequence:create(arrow_right_array)))
end

function createCell(index)
    local cell = CCTableViewCell:create()
    local node = CCNode:create()
    --[[
    while tolua.type(node) ~= "CCNode" do
        node = CCNode:create()
    end
    --]]
    cell:addChild(node)
    node:setScale(MainScene.elementScale)
    node:setAnchorPoint(ccp(0.5, 0.5))
    node:setContentSize(CCSizeMake(640, 602))
    node:setPosition(ccp(_cell_size.width * 0.5, _cell_size.height * 0.5))
    local node_menu = BTSensitiveMenu:create()
    node:addChild(node_menu, 3)
    node_menu:setPosition(ccp(0, 0))
    node_menu:setContentSize(node:getContentSize())
    node_menu:setTouchPriority(_touch_priority - 1)
            
    local group_images = {"a.png", "b.png", "c.png", "d.png"}
    local group = CCSprite:create(string.format("images/lord_war/%s", group_images[index + 1]))
    cell:addChild(group)
    group:setAnchorPoint(ccp(0.5, 1))
    group:setPosition(ccp(_cell_size.width * 0.5, _cell_size.height))

    for k, v in pairs(_cell_data) do
        local stage = k
        local stage_data = v
        if stage_data.hero_positions ~= nil then
            for i = 1, #stage_data.hero_positions do
                local hero_position = stage_data.hero_positions[i]
                local hero_data = LordWarData.getProcessPromotionInfoBy(_lord_type, stage, i + index * #stage_data.hero_positions)
                local hero = createHero(hero_data, stage)
                node:addChild(hero, 2)
                hero:setAnchorPoint(ccp(0.5, 0.5))
                hero:setPosition(hero_position)
            end
        end
        if stage_data.line_datas ~= nil then
            for i = 1, #stage_data.line_datas do
                local line_data = stage_data.line_datas[i]
                local hero_data = LordWarData.getProcessPromotionInfoBy(_lord_type, stage, i + index * #stage_data.line_datas)
                local is_light = hero_data ~= nil and hero_data.userStatus == LordWarData.kUserWin
                local line_image = nil
                if stage == 32 then
                    if is_light then
                        line_image = "images/olympic/line/downRightLine_light.png"
                    else
                        line_image = "images/olympic/line/downRightLine_gray.png"
                    end
                else
                    if is_light then
                        line_image = "images/olympic/line/horizontalLine_light.png"
                    else
                        line_image = "images/olympic/line/horizontalLine_gray.png"
                    end
                end
                local line = CCSprite:create(line_image)
                node:addChild(line, 1)
                line:setPosition(line_data.position)
                line:setAnchorPoint(ccp(0.5, 0.5))
                if line_data.rotation ~= nil then
                    line:setRotation(line_data.rotation)
                end
                if line_data.scale_x ~= nil then
                    line:setScaleX(line_data.scale_x)
                end
                if line_data.scale_y ~= nil then
                    line:setScaleY(line_data.scale_y)
                end
            end 
        end
        if stage_data.btn_positions ~= nil then
            for i = 1, #stage_data.btn_positions do
                local btn_position = stage_data.btn_positions[i]
                local normal = nil
                local selected = nil
                local disabled = nil
                local btn_index = i + index * #stage_data.btn_positions
                local btn_status = getBtnStatus(stage, btn_index)
                local callback = nil
                if btn_status == BtnStatus.cheer or btn_status == BtnStatus.cheer_disabled then
                    normal = CCSprite:create("images/olympic/cheer_up/cheer_n.png")
                    selected = CCSprite:create("images/olympic/cheer_up/cheer_h.png")
                    disabled = BTGraySprite:create("images/olympic/cheer_up/cheer_n.png")
                    callback = cheerCallback
                else
                    normal = CCSprite:create("images/olympic/checkbutton/check_btn_h.png")
                    selected = CCSprite:create("images/olympic/checkbutton/check_btn_n.png")
                    disabled = BTGraySprite:create("images/olympic/checkbutton/check_btn_h.png")
                    callback = lookCallback
                end
                local btn = CCMenuItemSprite:create(normal, selected, disabled)
                node_menu:addChild(btn)
                btn:setTag(stage * 1000 + btn_index)
                btn:setPosition(btn_position)
                btn:setAnchorPoint(ccp(0.5, 0.5))
                btn:registerScriptTapHandler(callback)
                if btn_status == BtnStatus.look_disabled or btn_status == BtnStatus.cheer_disabled then
                    btn:setEnabled(false)
                end
            end
        end
    end
    return cell
end

function cheerCallback(tag, btn)
    local btn_index = math.mod(tag, 1000)
    local stage = math.floor(tag / 1000)
    print(btn_index, stage)
    require "script/ui/lordWar/LordWarCheerLayer"
    local data = {}
    data.group = _lord_type 
    data.rank = stage
    data.position_1 = btn_index * 2 - 1
    data.position_2 = btn_index * 2
    data.btn_index = btn_index
    data.refreshCallback = function()
        _table_view:reloadData()
        if _offset ~= nil then
            _table_view:setContentOffset(_offset)
        end
    end
    LordWarCheerLayer.show(data)
    --]]
end

function lookCallback(tag, menu_item)
    local btn_index = math.mod(tag, 1000)
    local rank = math.floor(tag / 1000)
    local round = LordWarData.getRoundByRoundRank(rank, _innerOrCross)
    local position_1 = btn_index * 2 - 1
    local position_2 = btn_index * 2
    local hero_1 = LordWarData.getProcessPromotionInfoBy(_lord_type, rank, position_1)
    local hero_2 = LordWarData.getProcessPromotionInfoBy(_lord_type, rank, position_2)
    local ret = 0
    if hero_1 ~= nil then
        ret = ret + 1
    end
    if hero_2 ~= nil then
        ret = ret + 1
    end
    if ret == 1 then
        SingleTip.showTip(GetLocalizeStringBy("key_8240"))
    elseif ret == 0 then
        SingleTip.showTip(GetLocalizeStringBy("key_8241"))
    else
        local lookCallFunc= function(ret)
            local fight_info = {}
            fight_info.hero_1 = hero_1
            fight_info.hero_2 = hero_2
            local is_inner = LordWarData.isInInner(_innerOrCross)
            require "script/ui/lordWar/warReport/WarReportLayer"
            WarReportLayer.showLayer(ret, _touch_priority - 600, _layer:getZOrder() + 10, is_inner, nil, nil, nil, nil, fight_info)
        end
        local teamType = LordWarData.getServerTeamType(_lord_type)
        LordWarService.getPromotionBtl(round, teamType, hero_1.serverId, hero_1.uid, hero_2.serverId, hero_2.uid, lookCallFunc)
    end
end

-- 获取按钮状态
function getBtnStatus(stage, index)
    -- 当前阶段
    local curRound = LordWarData.getCurRound()
    -- 当前阶段状态
    local curRoundStatus = LordWarData.getCurRoundStatus()
    if _innerOrCross == LordWarData.kInnerType then
        curRound = LordWarData.kInner8To4
        curRoundStatus = LordWarData.kRoundEnd
    elseif _innerOrCross == LordWarData.kCrossType then
        curRound = LordWarData.kCross8To4
        curRoundStatus = LordWarData.kRoundEnd
    end
    -- test
     --curRound = 3
     --curRoundStatus = 100
     --stage = 32
    --print("按钮状态：curRound=", curRound, "curRoundStatus=", curRoundStatus)
    local btn_status = nil
    local round = LordWarData.getRoundByRoundRank(stage, _innerOrCross)
    if curRound == round then
        if curRoundStatus < LordWarData.kRoundFighting then
            btn_status = BtnStatus.cheer
        else
            btn_status = BtnStatus.look
        end
    elseif curRound > round then
        btn_status = BtnStatus.look
    else
        if round - curRound == 1 and curRoundStatus >= LordWarData.kRoundFighted then
           btn_status = BtnStatus.cheer
        else
            btn_status = BtnStatus.cheer_disabled
        end
    end
    -- test
    --return BtnStatus.cheer
    return btn_status
end

function createHero(hero_data, stage)
    local node = CCNode:create()
    local bg = nil
    if stage == 4 then
        bg = CCSprite:create("images/lord_war/4hero_bg.png")
        local stage_sprite = CCSprite:create("images/olympic/final4.png")
        bg:addChild(stage_sprite)
        stage_sprite:setAnchorPoint(ccp(0.5, 0))
        stage_sprite:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height))
        node:setContentSize(bg:getContentSize())
        local bgAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/txkfaguang/txkfaguang"), -1,CCString:create(""))
        bgAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
        bgAnimSprite:setPosition(ccpsprite(0.5,0.5,node))
        node:addChild(bgAnimSprite,-2)
    else
        bg = CCSprite:create("images/everyday/headBg1.png")
        node:setContentSize(bg:getContentSize())
    end
    node:addChild(bg)
    bg:setAnchorPoint(ccp(0.5, 0.5))
    bg:setPosition(ccpsprite(0.5, 0.5, node))
    
	if hero_data == nil then
        local tipFont = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8242"), stage), g_sFontPangWa, 27)
        node:addChild(tipFont)
        tipFont:setColor(ccc3(0xd2, 0xd2, 0xcf))
        tipFont:setAnchorPoint(ccp(0.5, 0.5))
        tipFont:setPosition(ccpsprite(0.5, 0.5, node))
    else    
        -- 玩家头像
		local headIcon = nil
        local result_tag_sprite = nil
        if hero_data.userStatus == LordWarData.kUserFail and stage ~= 4 then
            headIcon =  HeroUtil.getHeroIconByHTID(tonumber(hero_data.htid), hero_data.dress["1"], nil, 0)
            headIcon = BTGraySprite:createWithNodeAndItChild(headIcon)
            result_tag_sprite = CCSprite:create("images/olympic/lost.png")
        else
            if hero_data.userStatus == LordWarData.kUserWin and stage ~= 4 then
                result_tag_sprite = CCSprite:create("images/olympic/win.png")
            end
            headIcon = HeroUtil.getHeroIconByHTID(tonumber(hero_data.htid), hero_data.dress["1"], nil, hero_data.vip)
        end
		headIcon:setAnchorPoint(ccp(0.5, 0.5))
        if stage == 4 then
            headIcon:setPosition(ccp(66, 75))
        else
            headIcon:setPosition(ccpsprite(0.5,0.5,node))
        end
		node:addChild(headIcon)
        
        if result_tag_sprite ~= nil then
            headIcon:addChild(result_tag_sprite, 10)
            result_tag_sprite:setAnchorPoint(ccp(0.5, 0.5))
            result_tag_sprite:setPosition(ccp(12, 80))
        end
        -- 是否已经助威
        if LordWarData.isCheered(hero_data, stage) == true then
            local cheered_tag_sprite = CCSprite:create("images/lord_war/yizhuwei.png")
            headIcon:addChild(cheered_tag_sprite)
            cheered_tag_sprite:setAnchorPoint(ccp(0, 0.5))
            cheered_tag_sprite:setPosition(ccp(45, 100))
        end
		-- 战斗力
		local fightSp = CCSprite:create("images/lord_war/fight_bg.png")
		fightSp:setAnchorPoint(ccp(0.5,0.5))
		fightSp:setPosition(ccp(node:getContentSize().width * 0.5 + 5, 2))
		node:addChild(fightSp)
		-- 战斗力数值
		local fightLable = CCRenderLabel:create(hero_data.fightForce, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	    fightLable:setColor(ccc3(0xff,0x00,0x00))
	    fightLable:setAnchorPoint(ccp(0,0.5))
	    fightLable:setPosition(ccp(34, fightSp:getContentSize().height*0.5))
	   	fightSp:addChild(fightLable)
	   	-- 玩家名字
        local font_name = nil 
        if stage == 4 then
            font_name = g_sFontPangWa
        else
            font_name = g_sFontName
        end
	   	local userNameLable = CCRenderLabel:create(hero_data.uname, font_name, 22, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	    userNameLable:setColor(ccc3(0xff,0xff,0xff))
	    userNameLable:setAnchorPoint(ccp(0.5,0.5))
	    userNameLable:setPosition(ccp(node:getContentSize().width*0.5,-18))
	   	node:addChild(userNameLable)
        if tostring(hero_data.uid) == tostring(UserModel.getUserUid()) then
            userNameLable:setColor(ccc3(0xE4, 0x00, 0xFF))
        end
        
        if not LordWarData.isInInner(_innerOrCross) then
            -- 服务器名字
            local serviceNameLable = CCRenderLabel:create( string.format("(%s)", hero_data.serverName), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
            serviceNameLable:setColor(ccc3(0xff,0xff,0xff))
            serviceNameLable:setAnchorPoint(ccp(0.5,0.5))
            serviceNameLable:setPosition(ccp(node:getContentSize().width * 0.5, -40))
            node:addChild(serviceNameLable)
        end
        if LordWarData.isShowWinEffect() == true and 
            (stage == LordWarData.getCurMinRank() or (stage == LordWarData.kRank32 and LordWarData.getCurMinRank() == LordWarData.kRank16 and tonumber(hero_data.rank) == LordWarData.kRank16)) then
            LordWarUtil.playWinEffect(node)
        end
    end
    return node
end

function onTouchesHandler(event, x, y)
    if event == "began" then
        local rect = _table_view:boundingBox()
        local position = ccp(x, y)
        if rect:containsPoint(position) then
            _table_view:setBounceable(true)
            _drag_began_x = _table_view:getContentOffset().x
            _touch_began_x = x
            _is_handle_touch = true
        else
            _is_handle_touch = false
        end
        return true
    elseif event == "moved" then
        if _is_handle_touch == true then
            local offset = _table_view:getContentOffset()
            offset.x = _drag_began_x + x - _touch_began_x
            _table_view:setContentOffset(offset)
        end
    elseif event == "ended" or event == "cancelled" then
        if _is_handle_touch == true then
            local drag_ended_x = _table_view:getContentOffset().x
            local drag_distance = drag_ended_x - _drag_began_x
            local offset = _table_view:getContentOffset()
            if drag_distance >= 100 then
                offset.x = _drag_began_x + _cell_size.width
            elseif drag_distance <= -100 then
                offset.x = _drag_began_x - _cell_size.width
            else
                offset.x = _drag_began_x
            end
            _table_view:setBounceable(false)
            if offset.x > 0 then
                offset.x = 0
            end
            local container = _table_view:getContainer()
            if offset.x < -container:getContentSize().width + _table_view:getViewSize().width then
                offset.x = -container:getContentSize().width + _table_view:getViewSize().width
            end
            local array = CCArray:create()
            local startCallFunc = function()
                _layer:setTouchEnabled(false)
            end
            array:addObject(CCCallFunc:create(startCallFunc))
            array:addObject(CCMoveTo:create(0.3, offset))
            local endCallFunc = function()
                _layer:setTouchEnabled(true)
            end
            array:addObject(CCCallFunc:create(endCallFunc))
            container:runAction(CCSequence:create(array))
            _offset = offset
        end
    end
end

function onNodeEvent(event)
    if (event == "enter") then
        _layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority - 2, false)
        _layer:setTouchEnabled(true)
        _is_running = true
    elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
        _is_running = false
        _title = nil
	end
end

function scheduleTime()
    _cur_time = BTUtil:getSvrTimeInterval()
    for k, v in pairs(_schedule_functions) do
        v()
    end
end

function updateScheduleFunctions(key, value)
    _schedule_functions[key] = value
    if table.isEmpty(_schedule_functions) and _schedule ~= nil then
        stopSchedule()
    elseif not table.isEmpty(_schedule_functions) and _schedule == nil then
        startSchedule()
    end
end

function stopSchedule()
    _schedule_node:stopAllActions()
end

function startSchedule()
    if _layer == nil then
        return
    end
    if _schedule_node == nil then
        _schedule_node = CCNode:create()
        _layer:addChild(_schedule_node)
    end
    schedule(_schedule_node, scheduleTime, 1)
end

function refreshStageLabel()
    -- 当前阶段
	local curRound = LordWarData.getCurRound()
	-- 当前阶段状态
	local curRoundStatus = LordWarData.getCurRoundStatus()
	-- 当前阶段开始时间
	local curRoundStarTime = LordWarData.getRoundStartTime(curRound)
	-- 当前阶段结束时间
	local curRoundEndTime = LordWarData.getRoundEndTime(curRound)
    
	-- 刷新小标题
	local text = LordWarUtil.getTitleStrByCurRound(curRound, curRoundStatus, _innerOrCross, "LordWar32Layer")

    if _stage_label == nil then
        _stage_label = CCLabelTTF:create(text, g_sFontPangWa, 25)
         --CCRenderLabel:create(text, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_shadow)
        _top_node:addChild(_stage_label)
        _stage_label:setAnchorPoint(ccp(0.5, 0.5))
        _stage_label:setPosition(ccp(320, 180))
        _stage_label:setColor(ccc3(0x00, 0xe4, 0xff))
    else
        _stage_label:setString(text)
    end
end

-- 我的信息
function myInfoCallback()
    require "script/ui/lordWar/MyInfoLayer"
    local infoLayer = MyInfoLayer.show(_touch_priority - 700, _layer:getZOrder() + 10)
end

-- 返回
function backCallback()
    if _innerOrCross ~= nil then
        local curRound = LordWarData.getCurRound()
        -- 当前阶段状态
        local curRoundStatus = LordWarData.getCurRoundStatus()
        if curRound == LordWarData.kCross2To1 and curRoundStatus == LordWarData.kRoundEnd then
            LordWar4Layer.show(_innerOrCross)
        else
            LordWar4Layer.show()
        end
    else
        LordWarMainLayer.show()
    end
end

-- 说明
function descCallback()
    require "script/ui/lordWar/LordWarExplainDialog"
	LordWarExplainDialog.show(_touch_priority - 600)
end

-- 选组
function groupCallback(tag, menu_item)
    local lord_types={LordWarData.kWinLordType, LordWarData.kLoseLordType}
    _lord_type = lord_types[tag]
    if _table_view ~= nil then
        _table_view:reloadData()
        _table_view:setContentOffset(ccp(-(LordWarData.getMyPageIndex(_lord_type) - 1) * _cell_size.width, _table_view:getContainer():getPositionY()))
    end
end
