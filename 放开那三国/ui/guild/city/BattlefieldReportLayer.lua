-- Filename：    BattlefieldReportLayer.lua
-- Author：      bzx
-- Date：        2014-04-21
-- Purpose：     夺城战报

module("BattlefieldReportLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/network/RequestCenter"
require "script/ui/guild/city/CityData"
require "script/utils/BaseUI"
require "script/ui/guild/GuildImpl"
require "script/libs/LuaCCSprite"
require "script/model/user/UserModel"
require "script/network/Network"
require "script/ui/guild/GuildDataCache"

local _layer
local _BG                       -- 战报背景
local _report_table_view        -- 展示战报的TableView
local _touch_priority = -453    -- 当前层触摸优先级
local _tag = 999                -- 当前层tag
local _z_oder = 1010            -- 当前层zoder
local _event_call_func          -- 事件回调
local _city_id                  -- 城池ID
local _battle_city_id           -- 有没有在其它城池的战场中，没有为nil，否则为该城池id
local _report_datas             -- 战报数据
local _time_datas               -- 战场的开始时间/结束时间
local _time_lables              -- 按钮下的时间
local _menu_items               -- 各场战斗的按钮
local _timer_refresh_time       -- 刷新时间的定时器
local _prepare_time             -- 准备时间
local _next_begin_time          -- 下一场开始的时间
local _next_begin_time_node
local _next_open_index          -- 下一场的角标
local _npc_name                 -- npc的名字
local _fight_index              -- 点击进入战场是角标
local _selected_btn
local _selected_tag    = 12345

EventType = {                   -- 事件枚举
    close   = 1,
    look    = 2,
    fight   = 3
}

FightStatus = {                 -- 战斗的状态
    not_began   = 1,
    waiting     = 2,
    fighting    = 3,
    ended       = 4
}

function init(city_id)
    _layer = nil
    _event_call_func = nil
    _city_id = city_id
    _time_datas = {}
    _time_datas = table.hcopy(CityData.getTimeTable().arrAttack, _time_datas)
    _prepare_time = CityData.getTimeTable().prepare
   --------------------------------------- test bzx
   --[[
    _time_datas[1][1] = BTUtil:getSvrTimeInterval() + 2 * 30
    _time_datas[1][2] = _time_datas[1][1] + 2 * 60
    
   _time_datas[2][1] = _time_datas[1][1] + 2*60
    _time_datas[2][2] = _time_datas[2][1] + 3 * 60
    --]]
    ----------------------------------------
    _time_lables = {}
    _menu_items = {}
    _next_begin_time = {}
    _next_open_index = nil
    _next_begin_time_node = nil
    _npc_name = CityData.getNpcNameByCityId(city_id)
    _battle_city_id = nil
    _fight_index = nil
    _report_datas = {}
end

function getReportDatas()
    return _report_datas
end

function show(city_id)
    init(city_id)
    local data = CCArray:create()
	data:addObject(CCInteger:create(city_id))
    RequestCenter.battlefieldReport(handleReportData, data)
end

function create()
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 155))
    _layer:registerScriptHandler(onNodeEvent)
    loadBG()
    loadReportList()
    loadBar()
    loadNextFightTime()
    loadAutoFightTip()
    return _layer
end

-- 战斗结束
function battleEnd(city_id)
    if city_id == _city_id then
        local data = CCArray:create()
        data:addObject(CCInteger:create(city_id))
        RequestCenter.battlefieldReport(handleReportResult, data)
    end
end

-- 通过角标获取战斗的状态
function getFightStatusByIndex(index)
    local began_time = tonumber(_time_datas[index][1])
    --local end_time = tonumber(_time_datas[index][2])
    local current_time = BTUtil:getSvrTimeInterval()
    local fight_status = nil
    if current_time > began_time then
        fight_status = FightStatus.fighting
    elseif current_time > began_time - _prepare_time then
        fight_status = FightStatus.waiting
    else
        fight_status = FightStatus.not_began
    end
    local report_data = _report_datas[index]
    if report_data.replay ~= "0" then
        fight_status = FightStatus.ended
    end
    
    -- local remain_time = end_time - current_time
    -- if remain_time < 0 then
    --    remain_time = 0
    --end
    return fight_status--, remain_time
end

function handleReportResult(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    _report_datas = dictData.ret
end

function handleReportData(cbFlag, dictData, bRet)
	if dictData.err ~= "ok" then
		return 
	end
    print(GetLocalizeStringBy("key_1218"))
    print_t(dictData)

     _report_datas = dictData.ret
    --[[
    _report_datas = {
        {
            attack = {
                guild_id = 1,
                guild_name = "哈哈"
            },
            defend = {
                guild_id = 1,
                guild_name = "哈哈"
            },
            result = "1",
            replay = "0"
        },
        {
            attack = {
                guild_id = 1,
                guild_name = "哈哈"
            },
            defend = {
                guild_id = 4,
                guild_name = GetLocalizeStringBy("key_1640")
            },
            result = "1",
            replay = "0"
        }
    }
    fuck = "1"
    --]]
    if _layer == nil then
        create()
        local scene = CCDirector:sharedDirector():getRunningScene()
        scene:addChild(_layer, _z_oder, _tag)
    end
end

function loadBG()
	--[[
	local mySize = CCSizeMake(620, 585)
    --]]
    local dialog_info = {
        title = GetLocalizeStringBy("key_2602"),
        callbackClose = callbackClose,
        size = CCSizeMake(620, 670),
        priority = _touch_priority - 1
    }
    _BG = LuaCCSprite.createDialog_1(dialog_info)
    _layer:addChild(_BG)
    _BG:setScale(MainScene.elementScale)
    _BG:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _BG:setAnchorPoint(ccp(0.5, 0.5))
end

function loadNextFightTime()
    _next_begin_time[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2312"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
    --CCLabelTTF:create(GetLocalizeStringBy("key_2312"), g_sFontPangWa, 21)
    _next_begin_time[1]:setColor(ccc3(0xff, 0xf6, 0x00))
    _next_begin_time[2] = CCRenderLabel:create("1", g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
    _next_begin_time[3] =  CCRenderLabel:create(GetLocalizeStringBy("key_2030"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
    --CCLabelTTF:create(GetLocalizeStringBy("key_2030"), g_sFontPangWa, 21)
    _next_begin_time[3]:setColor(ccc3(0xff, 0xf6, 0x00))
    _next_begin_time[4] = CCLabelTTF:create("00:00:00", g_sFontPangWa, 23)
    _next_begin_time[4]:setColor(ccc3(0x20, 0x88, 0x01))
    _next_begin_time_node = BaseUI.createHorizontalNode(_next_begin_time)
    _BG:addChild(_next_begin_time_node)
    _next_begin_time_node:setAnchorPoint(ccp(0.5, 0.5))
    _next_begin_time_node:setPosition(ccp(_BG:getContentSize().width * 0.5, 132))
end

function loadAutoFightTip()
    local tip_1 =  CCRenderLabel:create(GetLocalizeStringBy("key_8228"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
    _BG:addChild(tip_1)
    tip_1:setAnchorPoint(ccp(0.5, 0.5))
    tip_1:setPosition(ccp(_BG:getContentSize().width * 0.5, 92))
    tip_1:setColor(ccc3(0x00, 0xff, 0x18))
    local tip_2 = {}
    tip_2[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8229"), g_sFontPangWa, 21, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    tip_2[1]:setColor(ccc3(0x00, 0xff, 0x18))
    require "script/utils/LuaUtil"
    local necessary_vip_level = getNecessaryVipLevel("offlineEnter", 0)
    tip_2[2] = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_8230"), necessary_vip_level), g_sFontPangWa, 21, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    tip_2[2]:setColor(ccc3(0xff, 0xf6, 0x00))
    tip_2[3] = CCRenderLabel:create("）", g_sFontPangWa, 21, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    tip_2[3]:setColor(ccc3(0x00, 0xff, 0x18))
    tip_2_node = BaseUI.createHorizontalNode(tip_2)
    _BG:addChild(tip_2_node)
    tip_2_node:setAnchorPoint(ccp(0.5, 0.5))
    tip_2_node:setPosition(ccp(_BG:getContentSize().width * 0.5, 56))

end

function loadBar()
    local full_rect = CCRectMake(0, 0, 74, 63)
	local inset_rect = CCRectMake(34, 18, 4, 1)
    local bar = CCScale9Sprite:create("images/battle/battlefield_report/bar.png",full_rect,inset_rect)
    _BG:addChild(bar)
    bar:setPreferredSize(CCSizeMake(564, 63))
    bar:setAnchorPoint(ccp(0.5, 0.5))
    bar:setPosition(ccp(_BG:getContentSize().width * 0.5, _BG:getContentSize().height - 85))
    
    local text_y = 40
    local cutting_line_y = 20
    -- 场次
    local times = CCSprite:create("images/battle/battlefield_report/times.png")
    bar:addChild(times)
    times:setAnchorPoint(ccp(0.5, 0.5))
    times:setPosition(ccp(49, text_y))
    local cutting_line_1 = CCSprite:create("images/battle/battlefield_report/cutting_line.png")
    bar:addChild(cutting_line_1)
    cutting_line_1:setPosition(ccp(101, cutting_line_y))
    
    -- 对战军团
    local battle_team = CCSprite:create("images/battle/battlefield_report/battle_team.png")
    bar:addChild(battle_team)
    battle_team:setPosition(ccp(270, text_y))
    battle_team:setAnchorPoint(ccp(0.5, 0.5))
    local cutting_line_2 = CCSprite:create("images/battle/battlefield_report/cutting_line.png")
    bar:addChild(cutting_line_2)
    cutting_line_2:setPosition(437, cutting_line_y)
    
    -- 查看战报
    local look_report = CCSprite:create("images/battle/battlefield_report/look_report.png")
    bar:addChild(look_report)
    look_report:setAnchorPoint(ccp(0.5, 0.5))
    look_report:setPosition(ccp(497, text_y))
end

function onNodeEvent(event)
	if event == "enter" then
        timerRefreshTimeLable()
        _timer_refresh_time = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerRefreshTimeLable, 1, false)
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
		_layer:setTouchEnabled(true)
        
        
        GuildImpl.registerCallBackFun("BattlefieldReportLayer", callbackClose)

	elseif (event == "exit") then
        if _timer_refresh_time ~= nil then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_timer_refresh_time)
            _timer_refresh_time = nil
        end
		_layer:unregisterScriptTouchHandler()
        _layer = nil
        GuildImpl.registerCallBackFun("BattlefieldReportLayer", nil)
	end
end

function onTouchesHandler( eventType, x, y )
	if eventType == "began" then
		-- print("began")
	    return true
    elseif eventType == "moved" then
    else
        -- print("end")
	end
end

function callbackClose()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
       
    _layer:removeFromParentAndCleanup(true)
end

function loadReportList()
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
   	local table_view_BG = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
    _BG:addChild(table_view_BG)
    table_view_BG:setAnchorPoint(ccp(0.5, 1))
    table_view_BG:setPosition(ccp(_BG:getContentSize().width * 0.5, _BG:getContentSize().height - 94))
    table_view_BG:setPreferredSize(CCSizeMake(554, 416))
    
    _report_table_view = createReportList()
    table_view_BG:addChild(_report_table_view)
end

function createReportList()
    local cell_size = CCSizeMake(550, 206)
    local cell_count = #_report_datas
    local layer = CCLayer:create()
    local height = cell_size.height * cell_count
    if height < 390 then
        height = 390
    end
    layer:setContentSize(CCSizeMake(cell_size.width, height))
    for i = 1, cell_count do
        local cell = createCell(i)
        layer:addChild(cell)
        cell:setContentSize(cell_size)
        cell:setAnchorPoint(ccp(0.5, 0))
        cell:setPosition(ccp(cell_size.width * 0.5, layer:getContentSize().height - cell_size.height * i))
    end
    local scroll_view = CCScrollView:create()
    scroll_view:setViewSize(CCSizeMake(550, 390))
    scroll_view:setContainer(layer)
    scroll_view:setPosition(ccp(0, 0))
    scroll_view:setBounceable(true)
    scroll_view:setTouchPriority(_touch_priority - 2)
    scroll_view:setDirection(kCCScrollViewDirectionVertical)
    scroll_view:setContentOffset(ccp(0, scroll_view:getViewSize().height - scroll_view:getContentSize().height))
    return scroll_view
end

-- 刷新时间的定时器
function timerRefreshTimeLable()

------------------------------- test
--    local current_time = BTUtil:getSvrTimeInterval()
--    if current_time == _time_datas[1][1] + 60 then
--        battleEnd(_city_id)
--    end
-------------------------------
    local all_status_is_ended = true
    for i = 1, #_menu_items do
        local status = getFightStatusByIndex(i)
        if _menu_items[i].status ~= status then
            local report_table_view_parent = _report_table_view:getParent()
            _report_table_view:removeFromParentAndCleanup(true)
            _report_table_view = createReportList()
            report_table_view_parent:addChild(_report_table_view)
        end
        if status ~= FightStatus.ended then
            all_status_is_ended = false
        end
    end
    if all_status_is_ended == true then
        if _timer_refresh_time ~= nil then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_timer_refresh_time)
        end
        _timer_refresh_time = nil
    end
    if _next_open_index ~= nil then
        local parent = _next_begin_time[2]:getParent()
        local anchor_point = _next_begin_time[2]:getAnchorPoint()
        local position = ccp(_next_begin_time[2]:getPositionX(), _next_begin_time[2]:getPositionY())
        _next_begin_time[2]:removeFromParentAndCleanup(true)
        _next_begin_time[2] = CCRenderLabel:create(tostring(_next_open_index), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
        
        parent:addChild(_next_begin_time[2])
        _next_begin_time[2]:setAnchorPoint(anchor_point)
        _next_begin_time[2]:setPosition(position)
        
        local next_remain_time = tonumber(_time_datas[_next_open_index][1]) - BTUtil:getSvrTimeInterval()
        _next_begin_time[4]:setString(TimeUtil.getTimeString(next_remain_time))
    else
        if _next_begin_time_node ~= nil then
          _next_begin_time_node:setVisible(false)
        end
    end
end

function createCell(index)
    local data_index = index
    local report_data = _report_datas[data_index]
    if report_data == nil then
        report_data = {}
    end
    local cell =  CCTableViewCell:create()
    local cutting_line = CCSprite:create("images/common/line02.png")
    cutting_line:setScaleX(550 / 116)
    cell:addChild(cutting_line)
    
    if data_index == #_report_datas + 1 then
        _next_begin_time[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2312"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
        _next_begin_time[1]:setColor(ccc3(0x00, 0xff, 0x18))
        _next_begin_time[2] = CCRenderLabel:create("1", g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
        _next_begin_time[3] = CCRenderLabel:create(GetLocalizeStringBy("key_2030"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
        _next_begin_time[3]:setColor(ccc3(0x00, 0xff, 0x18))
        _next_begin_time[4] = CCRenderLabel:create("00:00:00", g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
        _next_begin_time[4]:setColor(ccc3(0x20, 0x88, 0x01))
        _next_begin_time_node = BaseUI.createHorizontalNode(_next_begin_time)
        cell:addChild(_next_begin_time_node)
        _next_begin_time_node:setAnchorPoint(ccp(0.5, 0.5))
        _next_begin_time_node:setPosition(ccp(275, 50))
        return cell
    end
    -- 第几场
    local counter = CCSprite:create("images/battle/battlefield_report/counter.png")
    cell:addChild(counter, 2)
    counter:setAnchorPoint(ccp(0.5, 0.5))
    counter:setPosition(55, 146)
    local times_lable = CCLabelTTF:create(tostring(data_index), g_sFontPangWa, 21)
    counter:addChild(times_lable)
    times_lable:setAnchorPoint(ccp(0.5, 0.5))
    times_lable:setPosition(counter:getContentSize().width * 0.5, counter:getContentSize().height * 0.5)
    -- 分割线
   
    
    -- 结果
    local vs = CCSprite:create("images/arena/vs.png")
    cell:addChild(vs, 2)
    vs:setAnchorPoint(ccp(0.5, 0.5))
    vs:setPosition(ccp(550 * 0.5, 146))
    local result = tonumber(report_data.result)
    local result_tag_position_1 = {ccp(150, 173), ccp(2 * vs:getPositionX() - 150, 173)}
    local result_tag_position_0 = {ccp(2 * vs:getPositionX() - 150, 173), ccp(150, 173)}
    local result_tag_position = {result_tag_position_0, result_tag_position_1}
    
    local fight_status = getFightStatusByIndex(data_index)
    if fight_status == FightStatus.ended then
        local victory_tag = CCSprite:create("images/battle/battlefield_report/sheng.png")
        victory_tag:setAnchorPoint(ccp(0.5, 0.5))
        
        victory_tag:setPosition(result_tag_position[result + 1][1])
        cell:addChild(victory_tag)
        
        local failure_tag = CCSprite:create("images/battle/battlefield_report/fu.png")
        failure_tag:setAnchorPoint(ccp(0.5, 0.5))
        failure_tag:setPosition(result_tag_position[result + 1][2])
        cell:addChild(failure_tag)
    end

    local default_name
    if data_index == 1 then
        default_name = ""
    else
        default_name = GetLocalizeStringBy("key_2886") .. (data_index - 1) .. GetLocalizeStringBy("key_2910")
    end
    
    if report_data.attack.guild_id == "0" then
        report_data.attack.guild_name = default_name
    elseif report_data.attack.guild_id == "1" then
        report_data.attack.guild_name = _npc_name
    end
    local left_name_lable = CCLabelTTF:create(report_data.attack.guild_name .. " ", g_sFontName, 21)
    vs:addChild(left_name_lable)
    left_name_lable:setColor(ccc3(0x00, 0xe4, 0xff))
    left_name_lable:setAnchorPoint(ccp(1, 0.5))
    left_name_lable:setPosition(ccp(0, vs:getContentSize().height * 0.5 - 10))
    
    if report_data.defend.guild_id == "0" then
        report_data.defend.guild_name = default_name
    elseif report_data.defend.guild_id == "1" then
        report_data.defend.guild_name = _npc_name
    end
    local right_name_lable = CCLabelTTF:create(" " .. report_data.defend.guild_name, g_sFontName, 21)
    vs:addChild(right_name_lable)
    right_name_lable:setColor(ccc3(0xff, 0xff, 0xff))
    right_name_lable:setAnchorPoint(ccp(0, 0.5))
    right_name_lable:setPosition(ccp(vs:getContentSize().width, vs:getContentSize().height * 0.5 - 10))
    -- 按钮
    local menu = CCMenu:create()
    cell:addChild(menu, 2)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touch_priority - 1)
    
    _time_lables[data_index] = CCLabelTTF:create(TimeUtil.getTimeFormatAtDay(tonumber(_time_datas[data_index][1])) .. GetLocalizeStringBy("key_2563"), g_sFontName, 21)
    _time_lables[data_index]:setColor(ccc3(0x00, 0xff, 0x18))
    _time_lables[data_index]:setAnchorPoint(ccp(0.5, 1))
    
    
    if fight_status == FightStatus.ended then
    
    
        local look_report_btn = CCMenuItemImage:create("images/battle/battlefield_report/look_n.png",
                                                    "images/battle/battlefield_report/look_h.png")
        menu:addChild(look_report_btn)
        look_report_btn:setTag(data_index)
        look_report_btn:registerScriptTapHandler(callbackLook)
        look_report_btn:setPosition(ccp(459, 121))
        _menu_items[data_index] = {btn = look_report_btn, status = fight_status}
    elseif fight_status == FightStatus.waiting then
        local fight_n = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/jinruzhanchang/jinruzhanchang"), 1,CCString:create(""));
        local fight_btn = CCMenuItemImage:create("images/battle/battlefield_report/go_n.png",
                                                   "images/battle/battlefield_report/go_h.png")
        local fight_normal = fight_btn:getNormalImage()
        local fight_normal_new = CCNode:create()
        local fight_btn_size = fight_normal:getContentSize()
        fight_normal_new:setContentSize(fight_btn_size)
        fight_n:setAnchorPoint(ccp(0.5, 0.5))
        fight_n:setPosition(ccp(fight_btn_size.width * 0.5, fight_btn_size.height * 0.5))
        fight_normal_new:addChild(fight_n)
        fight_btn:setNormalImage(fight_normal_new)
        menu:addChild(fight_btn)
        fight_btn:setAnchorPoint(ccp(0.5, 0.5))
        fight_btn:setPosition(ccp(480, 151))
        fight_btn:setTag(data_index)
        fight_btn:registerScriptTapHandler(callbackFight)
        fight_btn:addChild(_time_lables[data_index])
        _time_lables[data_index]:setPosition(ccp(fight_btn:getContentSize().width * 0.5, -2))
        _menu_items[data_index] = {btn = fight_btn, status = fight_status}
    elseif fight_status == FightStatus.fighting then
         local fighting_btn = CCMenuItemImage:create("images/battle/battlefield_report/fighting_n.png",
                                                    "images/battle/battlefield_report/fighting_h.png")
        menu:addChild(fighting_btn)
        fighting_btn:setAnchorPoint(ccp(0.5, 0.5))
        fighting_btn:setPosition(ccp(480, 151))
        fighting_btn:setTag(data_index)
        _time_lables[data_index]:setPosition(ccp(fighting_btn:getContentSize().width * 0.5, -2))
        fighting_btn:registerScriptTapHandler(callbackFighting)
        _menu_items[data_index] = {btn = fighting_btn, status = fight_status}
    elseif fight_status == FightStatus.not_began then
        local not_began_lable = CCLabelTTF:create(GetLocalizeStringBy("key_2498"), g_sFontName, 21)
        cell:addChild(not_began_lable)
        not_began_lable:setAnchorPoint(ccp(0.5, 0.5))
        not_began_lable:setPosition(ccp(480, 151))
        not_began_lable:addChild(_time_lables[data_index])
        _time_lables[data_index]:setPosition(ccp(not_began_lable:getContentSize().width * 0.5, -2))
        _menu_items[data_index] = {btn = nil, status = fight_status}
    end
    if fight_status ~= FightStatus.not_began and fight_status ~= FightStatus.waiting then
        if data_index == #_report_datas then
            _next_open_index = nil
        else
            _next_open_index = data_index + 1
        end
    elseif data_index == 1 then
        _next_open_index = data_index
    end
    -- 离线入场
    local normal_node = CCScale9Sprite:create("images/common/checkbg.png")
    normal_node:setPreferredSize(CCSizeMake(53, 48))
    local selecte_btn = CCMenuItemSprite:create(normal_node, normal_node)
    menu:addChild(selecte_btn)
    selecte_btn:setTag(index)
    selecte_btn:registerScriptTapHandler(selectedCallback)
    selecte_btn:setAnchorPoint(ccp(0.5, 0.5))
    selecte_btn:setPosition(ccp(211, 55))
    local auto_fight_label = CCRenderLabel:create(GetLocalizeStringBy("key_8231"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
    cell:addChild(auto_fight_label)
    auto_fight_label:setAnchorPoint(ccp(0, 0.5))
    auto_fight_label:setPosition(ccp(251, 53))
    auto_fight_label:setColor(ccc3(40, 228, 251))
    print_t(CityData.getOffline())
    if CityData.getOffline()[tostring(index)] == tostring(_city_id) then
        addSelectedTagSprite(selecte_btn)
    end
    return cell
end

-- 离线入场按钮点击回调
function selectedCallback(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local fight_status = getFightStatusByIndex(tag)
    
    if fight_status ~= FightStatus.not_began then
        AnimationTip.showTip(GetLocalizeStringBy("key_8232"))
        return
    end
    
    local necessary_vip_level = getNecessaryVipLevel("offlineEnter", 0)
    if necessary_vip_level > UserModel.getVipLevel() then
        AnimationTip.showTip(string.format(GetLocalizeStringBy("key_8233"), necessary_vip_level))
        return
    end
 
    local guild_id = GuildDataCache.getGuildId()
    for i = 1, #_report_datas do
        local report_data = _report_datas[i]
        if tostring(guild_id) == report_data.attack.guild_id or
            tostring(guild_id) == report_data.defend.guild_id then
            break
        elseif i == #_report_datas then
            AnimationTip.showTip(GetLocalizeStringBy("key_8234"))
            return
        end
    end
    
    local offline_city_id = CityData.getOffline()[ tostring(tag)]
    if offline_city_id ~= nil and offline_city_id ~= tostring(_city_id) then
        local city_name = CityData.getDataById(tonumber(offline_city_id)).name
        AnimationTip.showTip(string.format(GetLocalizeStringBy("key_8235"), city_name, tag))
        return
    end
    _selected_btn = menu_item
    local args = Network.argsHandler(_city_id, tag - 1)
    local selected_tag_sprite = _selected_btn:getChildByTag(_selected_tag)
    if selected_tag_sprite == nil then
        RequestCenter.citywarOfflineEnter(handleSelected, args)
    else
        RequestCenter.citywarCancelOfflineEnter(handleSelected, args)
    end
end

-- 为选择的离线入场加标记
function addSelectedTagSprite(menu_item)
    local selected_tag_sprite = CCSprite:create("images/common/checked.png")
    menu_item:addChild(selected_tag_sprite)
    selected_tag_sprite:setAnchorPoint(ccp(0.5, 0.5))
    selected_tag_sprite:setPosition(ccp(menu_item:getContentSize().width * 0.5, menu_item:getContentSize().height * 0.5))
    selected_tag_sprite:setTag(_selected_tag)
end

-- 离线入场网络回调
function handleSelected(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    if dictData.ret == "ok" then
        local selected_tag_sprite = _selected_btn:getChildByTag(_selected_tag)
        if selected_tag_sprite == nil then
            addSelectedTagSprite(_selected_btn)
            CityData.getOffline()[ tostring(_selected_btn:getTag())] = tostring(_city_id)
        else
            selected_tag_sprite:removeFromParentAndCleanup(true)
            CityData.getOffline()[ tostring(_selected_btn:getTag())] = nil
        end
    end
end

function callbackLook(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local index = tag
    local data = CCArray:create()
	data:addObject(CCInteger:create(tonumber(_report_datas[index].replay)))--(60831))--))
    RequestCenter.battlefieldReportLook(handleLookReport, data)
    if _event_call_func ~= nil then
        _event_call_func(EventType.look, {report_ID = _report_datas[index].replay})
    end
end

function handleLookReport(cbFlag, dictData, bRet)
	if dictData.err ~= "ok" then
        print(GetLocalizeStringBy("key_1904"))
        print_t(dictData)
		return
	end
    print(GetLocalizeStringBy("key_2849"))
    local base64Data = Base64.decodeWithZip(dictData.ret)
    local data = amf3.decode(base64Data)
    print_t(data)
    require "script/ui/guild/copy/GuildBattleReportLayer"
    require "script/battle/GuildBattle"
    local reportData = {}
    reportData.server = data
    require "script/ui/guild/city/VisitorBattleLayer"
     local closeCallback = function()
                require "script/battle/GuildBattle"
                GuildBattle.closeLayer()
            end

    local visitor_battle_layer = VisitorBattleLayer.createAfterBattleLayer(reportData, false, closeCallback)
    GuildBattle.createLayer(reportData, GuildBattle.BattleForCity, visitor_battle_layer, true)
end

function callbackFighting(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    AnimationTip.showTip(GetLocalizeStringBy("key_1900"))
end

function handleGetBattleCity(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    _battle_city_id = dictData.ret
    if _battle_city_id == "0" or _battle_city_id == tostring(_city_id) then
        local data = CCArray:create()
        data:addObject(CCInteger:create(_city_id))
        RequestCenter.enterBattleLand(handleEnterBattle, data)
    else
        local city_name = CityData.getDataById(tonumber(_battle_city_id)).name
        local tip_text = GetLocalizeStringBy("key_1641") .. city_name .. GetLocalizeStringBy("key_2863")
        AnimationTip.showTip(tip_text)
    end
end

-- 进入战场
function handleEnterBattle(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    local ret = dictData.ret.ret
    if ret == "ok" then
        enterFight(dictData)
    elseif ret == "limit" then
        AnimationTip.showTip(GetLocalizeStringBy("key_2861"))
    elseif ret == "nobattle" then
        AnimationTip.showTip(GetLocalizeStringBy("key_1318"))
    else
        AnimationTip.showTip(GetLocalizeStringBy("key_1481"))
    end
end

function enterFight(dictData)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    require "script/ui/guild/city/CityInfoLayer"
    CityInfoLayer.closeButtonCallback()
    _layer:removeFromParentAndCleanup(true)
    
    require "script/ui/copy/BattleLand"
    local layer = BattleLand.create(_city_id, dictData)
    MainScene.changeLayer(layer, "BattleLand")
end

function callbackFight(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    _fight_index = tag
    
    local offline_city_id = CityData.getOffline()[ tostring(tag)]
    if offline_city_id ~= nil then
        if offline_city_id ~= tostring(_city_id) then
            local city_name = CityData.getDataById(tonumber(offline_city_id)).name
            AnimationTip.showTip(string.format(GetLocalizeStringBy("key_8236"), city_name, tag))
            return
        end
    end

    
    local status = getFightStatusByIndex(_fight_index)
    local guild_id = GuildDataCache.getGuildId()
    
    if guild_id ~= tonumber(_report_datas[_fight_index].attack.guild_id) and
            guild_id ~= tonumber(_report_datas[_fight_index].defend.guild_id) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1896"))
        return
    end
    
    RequestCenter.battlefieldReportGetBattleCityId(handleGetBattleCity, nil)
    
    if _event_call_func ~= nil then
        _event_call_func(EventType.fight, {report_ID = _report_datas[_fight_index].replay})
    end
end

function setEventCallFunc(call_func)
    _event_call_func = call_func
end
