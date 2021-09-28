-- Filename: HeroEnterLayer.lua
-- Author: llp
-- Date: 2014-05-15
-- Purpose: 列传英雄入口

module("HeroEnterLayer", package.seeall)
require "script/libs/LuaCCSprite"
require "script/ui/star/StarUtil"
require "script/network/RequestCenter"
require "script/model/user/UserModel"

local _layer
local _touch_priority   = -500
local _z                = 1000
local _head_table_view  = nil
local _dialog           = nil
local _radio_menu       = nil
local _radio_menu_space = 38
local _arrows           = nil
local _cur_star_list    = nil
local _selected_icon    = nil
local _new_head_id 
local _old_head_id

local starTable = {}

function init()
    _arrows         = nil
    _selected_icon  = nil
    _old_head_id    = UserModel.getFigureId() -- todo
    _new_head_id    = _old_head_id
    starTable       = {}
    _head_table_view  = nil
    _cur_star_list    = nil
    _dialog           = nil
    _radio_menu       = nil
end

function show()
    create()
    local runing_scene = CCDirector:sharedDirector():getRunningScene()
    runing_scene:addChild(_layer, _z , 10)
    -- 列传新手引导 3
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
            addGuideLieZhuanGuide3()
        end))
    _layer:runAction(seq)
end

function create()
    init()
    
    MainScene.setMainSceneViewsVisible(true,false,true)
    bulletinLayerSize = BulletinLayer.getLayerContentSize()
    bottomBg = CCSprite:create("images/common/sell_bottom.png")

    _layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 100))
    _layer:registerScriptHandler(onNodeEvent)
    local dialog_info = {}
    dialog_info.title = GetLocalizeStringBy("key_2037")
    dialog_info.callbackClose = callbackClose
    dialog_info.size = CCSizeMake(564, 802)
    dialog_info.priority = _touch_priority - 1
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    local labelBg = _dialog:getChildByTag(1)

    local bottom_label = CCLabelTTF:create(GetLocalizeStringBy("llp_13"), g_sFontPangWa, 23)
    labelBg:addChild(bottom_label)
    bottom_label:setColor(ccc3(0x78, 0x25, 0x00))
    bottom_label:setAnchorPoint(ccp(0.5, 0.5))
    bottom_label:setPosition(ccp(labelBg:getContentSize().width * 0.5, bottom_label:getContentSize().height*1.3))

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
    
    return _layer
end

function callbackConfirm()
    if _old_head_id == _new_head_id then
        callbackClose()
        return
    end
    local args = CCArray:create()
	args:addObject(CCInteger:create(_new_head_id))
    RequestCenter.user_setFigure(handleSetFigure, args)
end

function handleSetFigure(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    UserModel.setFigureId(_new_head_id)
    require "script/ui/tip/SingleTip"
    SingleTip.showTip(GetLocalizeStringBy("key_10024"))
    print(GetLocalizeStringBy("key_10024"))
    print_t(dictData)
    callbackClose()
end

function callbackCancel()
    callbackClose()
end

function callbackCountry(index, item)
    if _arrows ~= nil then
        _arrows:setPositionX(53 + (index - 1) * (96 + _radio_menu_space))
    end
    starTable = {}
    _cur_star_list = StarUtil.getStarListByCountry(index)
    for i=1,table.count(_cur_star_list) do
        local starDesc = DB_Star.getDataById(_cur_star_list[i].star_tid)
       
        if(tonumber(starDesc[3])==5)then
            print("iamin")
            table.insert(starTable,starDesc)
        end
    end
    if _head_table_view ~= nil then
        _head_table_view:reloadData()
    end
end

function loadTableView()
    local full_rect = CCRectMake(0,0,75, 75)
	local inset_rect = CCRectMake(30,30,15,15)
	local table_view_bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", full_rect, inset_rect)
	table_view_bg:setPreferredSize(CCSizeMake(512, 600))
    _dialog:addChild(table_view_bg)
    table_view_bg:setAnchorPoint(ccp(0.5, 1))
	table_view_bg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _radio_menu:getPositionY() - _radio_menu:getContentSize().height * 0.5 - 10))
    -- _dialog:setScale(g_fScaleX)
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
			print("a1=====", a1)
			cell = CCTableViewCell:create()
			-- 五个star

			local start = a1 * cell_icon_count
			for i=1, 4 do
                local index = start + i
				if index <= #starTable then
                    local tid = tonumber(starTable[index][1])
                    print("tid====="..tid)
					local iconSprite = createHead(tid, tid, callbackSelected, _touch_priority - 1)
		            iconSprite:setAnchorPoint(ccp(0.5, 0.5))
		            iconSprite:setPosition(ccp( cell_size.width/cell_icon_count /2 + (i-1) * cell_size.width/cell_icon_count, cell_size.height * 0.5))
		            cell:addChild(iconSprite)
            
                    if(HeroPublicLua.isBusyWithHtid(tid))then
                        print("HeroPublicLuaHeroPublicLua")
                        local hasonSprite = CCSprite:create("images/famoushero/isOn.png")
                        iconSprite:addChild(hasonSprite)
                        hasonSprite:setPosition(ccp(iconSprite:getContentSize().width*0.2,iconSprite:getContentSize().height*0.4))
                    end  
                end
			end
			return cell
		elseif function_name == "numberOfCells" then
			local count = #starTable
			return math.ceil(count / cell_icon_count )

		elseif function_name == "cellTouched" then
			print("a1=====", a1:getIdx())
		elseif (function_name == "scroll") then
		end
	end)
	_head_table_view = LuaTableView:createWithHandler(h, CCSizeMake(479, 575))
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
    if(ItemUtil.isBagFull() == true )then
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
        return
    end
    require "script/ui/heroCpy/HeroEnter"
    _new_head_id = tag
    print("_new_head_id".._new_head_id)
    local heroInfo = DB_Heroes.getDataById(_new_head_id)
    if(heroInfo.hero_copy_id == nil)then
        AnimationTip.showTip(GetLocalizeStringBy("llp_34"))
        return
    end
    local isUp = FormationUtil.isHadSameTemplateOnFormationByHtid(tonumber(_new_head_id))
    if(isUp == true)then
        HeroEnter.showLayer(tonumber(_new_head_id))
        _layer:setVisible(false)
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
    else
        AnimationTip.showTip(GetLocalizeStringBy("key_2387"))
    end
end

function callbackDefaultSelected(tag, default_item)
end

function createHead( star_tid, tag, callback, touch_priority)
	-- 查找名将的信息
	require "db/DB_Star"
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
    local nameLabel = CCRenderLabel:create( starDesc.name, g_sFontPangWa, 25, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xe4,0x00,0xff))
    nameLabel:setAnchorPoint(ccp(0.5,1))
    item_btn:addChild(nameLabel)
    nameLabel:setPosition(ccp(item_btn:getContentSize().width*0.5,0))
	item_btn:registerScriptTapHandler(callback)
	item_btn:setAnchorPoint(ccp(0.5, 0.5))
	item_btn:setPosition(ccp(bgSprite:getContentSize().width * 0.5, bgSprite:getContentSize().height * 0.5))
	menuBar:addChild(item_btn, 1, tag)

	return bgSprite
end


function callbackClose()
    -- MainScene.setMainSceneViewsVisible(true,true,true)
    _layer:removeFromParentAndCleanup(true)
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

---[==[武将列传 第3步
---------------------新手引导---------------------------------
function addGuideLieZhuanGuide3( ... )
    require "script/guide/NewGuide"
    require "script/guide/LieZhuanGuide"
    if(NewGuide.guideClass ==  ksGuideHeroBiography and LieZhuanGuide.stepNum == 2) then
        LieZhuanGuide.show(3, nil)
    end
end
---------------------end-------------------------------------
--]==]
