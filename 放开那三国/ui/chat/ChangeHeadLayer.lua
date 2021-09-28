-- Filename: ChangeHeadLayer.lua
-- Author: bzx
-- Date: 2014-05-15
-- Purpose: 更换头像

module("ChangeHeadLayer", package.seeall)
require "script/libs/LuaCCSprite"
require "script/ui/star/StarUtil"
require "script/network/RequestCenter"
require "script/model/user/UserModel"
require "db/DB_Star"

local _layer                        -- 当前层
local _touch_priority   = -500      -- 当前层的触摸优先级
local _z                = 10000     -- 当前层的z轴
local _head_table_view              -- 放头像的tableView
local _dialog                       -- 选择头像的对话框
local _radio_menu                   -- 国家选项卡
local _radio_menu_space = 38        -- 国家选项卡之间的距离
local _arrows                       -- 箭头
local _cur_star_list                -- 当前国家的所有头像数据
local _selected_icon                -- 被选中的标记
local _new_head_id                  -- 当前被选中的头像id
local _old_head_id                  -- 当前角色的头像id

function init()
    _arrows         = nil
    _selected_icon  = nil
    _old_head_id    = UserModel.getFigureId() -- todo
    _new_head_id    = _old_head_id
end

function show(p_priority)
    create(p_priority)
    local runing_scene = CCDirector:sharedDirector():getRunningScene()
    runing_scene:addChild(_layer, _z)
end

function create(p_priority)
    init()
    if(p_priority ~= nil)then
        _touch_priority = p_priority
    end
    _layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 100))
    _layer:registerScriptHandler(onNodeEvent)
    local dialog_info = {}
    dialog_info.title = GetLocalizeStringBy("key_8020")
    dialog_info.callbackClose = callbackClose
    dialog_info.size = CCSizeMake(564, 567)
    dialog_info.priority = _touch_priority - 1
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(g_fScaleX)
    
    local radio_data = {
        touch_priority  = _touch_priority - 1,
        space         = _radio_menu_space,
        callback        = callbackCountry,
        items           ={
            {normal = "images/chat/wei_n.png", selected = "images/chat/wei_h.png"},
            {normal = "images/chat/shu_n.png", selected = "images/chat/shu_h.png"},
            {normal = "images/chat/wu_n.png", selected = "images/chat/wu_h.png"},
            {normal = "images/chat/qun_n.png", selected = "images/chat/qun_h.png"}
        }
    }
    _radio_menu = LuaCCSprite.createRadioMenu(radio_data)
    _dialog:addChild(_radio_menu)
    _radio_menu:setAnchorPoint(ccp(0.5, 0.5))
    _radio_menu:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 100))
    
    loadTableView()
    
    local menu = CCMenu:create()
    _dialog:addChild(menu)
    menu:setTouchPriority(_touch_priority - 1)
    menu:setPosition(ccp(0, 0))
    
    local default_btn = CCMenuItemImage:create("images/common/checkbg.png", "images/common/checkbg.png")
    menu:addChild(default_btn)
    default_btn:registerScriptTapHandler(callbackDefaultSelected)
    default_btn:setAnchorPoint(ccp(0.5, 0.5))
    default_btn:setPosition(ccp(240, 132))
    
    if _old_head_id == 0 then
        addSelectedIcon(default_btn)
    end
    
    local default_label = CCLabelTTF:create(GetLocalizeStringBy("key_8021"), g_sFontName, 23)
    default_btn:addChild(default_label)
    default_label:setColor(ccc3(0x00, 0x00, 0x00))
    default_label:setAnchorPoint(ccp(0, 0.5))
    default_label:setPosition(ccp(40, default_btn:getContentSize().height * 0.5))
    
    local confirm_btn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_8022"),ccc3(255,222,0))
    menu:addChild(confirm_btn)
    confirm_btn:setAnchorPoint(ccp(0.5,0.5))
    confirm_btn:setPosition(ccp(165, 80))
    confirm_btn:registerScriptTapHandler(callbackConfirm)

    local cancel_btn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_8023"),ccc3(255,222,0))
    menu:addChild(cancel_btn)
    cancel_btn:setAnchorPoint(ccp(0.5,0.5))
    cancel_btn:setPosition(ccp(395, 80))
    cancel_btn:registerScriptTapHandler(callbackCancel)
    
    local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8024"), g_sFontPangWa, 21)
    _dialog:addChild(tip)
    tip:setAnchorPoint(ccp(0.5, 0.5))
    tip:setPosition(_dialog:getContentSize().width * 0.5, 40)
    tip:setColor(ccc3(0x78, 0x25, 0x00))

    return _layer
end

-- 确定
function callbackConfirm()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _old_head_id == _new_head_id then
        callbackClose()
        return
    end
    local args = CCArray:create()
	args:addObject(CCInteger:create(_new_head_id))
    RequestCenter.user_setFigure(handleSetFigure, args)
end

-- 更换头像的网络回调
function handleSetFigure(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    UserModel.setFigureId(_new_head_id)
    require "script/ui/tip/SingleTip"
    SingleTip.showTip(GetLocalizeStringBy("key_8025"))
    callbackClose()
end

-- 取消
function callbackCancel()
    callbackClose()
end

-- 头像排序的比较器
function compareQuality(hero1, hero2)
    local weight1 = 0   -- 初始权重为0
    local weight2 = 0
    local quality_weight = 1    -- 品质权重
    local starDesc1 = DB_Star.getDataById(hero1.star_tid)
    local starDesc2 = DB_Star.getDataById( hero2.star_tid)
    if tonumber(starDesc1.quality) > tonumber(starDesc2.quality) then
        weight1 = weight1 + quality_weight
    else
        weight2 = weight2 + quality_weight
    end
    return weight1 > weight2
end

-- 选项卡的回调
function callbackCountry(index, item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    if _arrows ~= nil then
        _arrows:setPositionX(53 + (index - 1) * (96 + _radio_menu_space))
    end
    _cur_star_list = {}
    table.hcopy(StarUtil.getStarListByCountry(index), _cur_star_list)
    print_t(_cur_star_list)
    table.sort(_cur_star_list, compareQuality)
    if _head_table_view ~= nil then
        _head_table_view:reloadData()
    end
end


-- 加载头像
function loadTableView()
    local full_rect = CCRectMake(0,0,75, 75)
	local inset_rect = CCRectMake(30,30,15,15)
	local table_view_bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", full_rect, inset_rect)
	table_view_bg:setPreferredSize(CCSizeMake(512, 265))
    _dialog:addChild(table_view_bg)
    table_view_bg:setAnchorPoint(ccp(0.5, 1))
	table_view_bg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _radio_menu:getPositionY() - _radio_menu:getContentSize().height * 0.5 - 10))
    
    _arrows = CCSprite:create("images/chat/arrows.png")
    table_view_bg:addChild(_arrows)
    _arrows:setAnchorPoint(ccp(0.5, 0))
    _arrows:setPosition(ccp(53, table_view_bg:getContentSize().height - 1))
    
    
    local cell_icon_count = 4
	local cell_size = CCSizeMake(479, 125)
	local h = LuaEventHandler:create(function(function_name, table_t, a1, cell)
		if function_name == "cellSize" then
			return cell_size
		elseif function_name == "cellAtIndex" then
			cell = CCTableViewCell:create()
			local start = a1 * cell_icon_count
			for i=1, 4 do
                local index = start + i
				if index <= #_cur_star_list then
                    local tid = tonumber(_cur_star_list[index].star_tid)
					local iconSprite = createHead(tid, tid, callbackSelected, _touch_priority - 1)
		            iconSprite:setAnchorPoint(ccp(0.5, 0.5))
		            iconSprite:setPosition(ccp(cell_size.width/cell_icon_count /2 + (i-1) * cell_size.width/cell_icon_count, cell_size.height * 0.5))
		            cell:addChild(iconSprite)
                    if tid == _old_head_id then
                        addSelectedIcon(iconSprite)
                    end
                end
			end
			return cell
		elseif function_name == "numberOfCells" then
			local count = #_cur_star_list
			return math.ceil(count / cell_icon_count )
		elseif function_name == "cellTouched" then
		elseif (function_name == "scroll") then
		end
	end)
	_head_table_view = LuaTableView:createWithHandler(h, CCSizeMake(479, 240))
    _head_table_view:ignoreAnchorPointForPosition(false)
    _head_table_view:setAnchorPoint(ccp(0.5, 1))
	_head_table_view:setBounceable(true)
	_head_table_view:setPosition(ccp(table_view_bg:getContentSize().width * 0.5, table_view_bg:getContentSize().height - 15))
	_head_table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    _head_table_view:setTouchPriority(_touch_priority - 2)
	table_view_bg:addChild(_head_table_view)
    
        --_selected_icon:setVisible(false)

    return table_view_bg
end

function callbackSelected(tag, head_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    _new_head_id = tag
    addSelectedIcon(head_item)
end

-- 默认
function callbackDefaultSelected(tag, default_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    _new_head_id = 0
    addSelectedIcon(default_item)
end

-- 为头像添加被选择的标记
function addSelectedIcon(node)
    if _selected_icon == nil then
        _selected_icon = CCSprite:create("images/common/checked.png")
        _selected_icon:retain()
        _selected_icon:setAnchorPoint(ccp(0.5, 0.5))
    else
        _selected_icon:removeFromParentAndCleanup(true)
    end
    node:addChild(_selected_icon)
    _selected_icon:setPosition(ccp(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5))
end

-- 创建头像
function createHead( star_tid, tag, callback, touch_priority)
	-- 查找名将的信息
	local starDesc = DB_Star.getDataById(star_tid)
 
	local bgSprite = CCSprite:create("images/base/potential/officer_" .. starDesc.quality .. ".png")
	local iconFile = "images/base/hero/head_icon/" .. starDesc.icon

	-- 按钮Bar
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
    if touch_priority ~= nil then
        menuBar:setTouchPriority(touch_priority)
    end
	bgSprite:addChild(menuBar)
	-- 按钮
	local item_btn = CCMenuItemImage:create(iconFile,iconFile)
	item_btn:registerScriptTapHandler(callback)
	item_btn:setAnchorPoint(ccp(0.5, 0.5))
	item_btn:setPosition(ccp(bgSprite:getContentSize().width * 0.5, bgSprite:getContentSize().height * 0.5))
	menuBar:addChild(item_btn, 1, tag)

    local nameColor = HeroPublicLua.getCCColorByStarLevel(starDesc.quality)
	local nameLabel = CCRenderLabel:create(starDesc.name, g_sFontName, 23, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5, 1))
    nameLabel:setPosition(ccp(item_btn:getContentSize().width * 0.5, -10))
    item_btn:addChild(nameLabel)

	return bgSprite
end


function callbackClose()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _layer ~= nil then
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
    end
end

function onNodeEvent(event)
	if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
        if _selected_icon ~= nil then
            _selected_icon:autorelease()
        end
	end
end

function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		return true
	end
end

