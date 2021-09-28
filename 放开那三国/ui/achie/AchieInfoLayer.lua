-- Filename: AchieInfoLayer.lua
-- Author: llp
-- Date: 2014-06-3
-- Purpose: 成就总览

module("AchieInfoLayer", package.seeall)
require "script/libs/LuaCCSprite"
require "script/ui/star/StarUtil"
require "script/network/RequestCenter"
require "script/model/user/UserModel"

local _layer
local _touch_priority   = -500
local _z                = 1000
local _head_table_view
local _dialog
local _radio_menu
local _radio_menu_space = 38
local _arrows
local _cur_star_list
local _selected_icon
local _new_head_id
local _old_head_id
local haveNum = 0
local totalNum = 0
local achieLabel  		= CCRenderLabel:create(GetLocalizeStringBy("llp_27"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
local progressLabel 	= CCRenderLabel:create(GetLocalizeStringBy("key_2504") .. 0 .. "/" ..  100, g_sFontName,18,1,ccc3(0x0,0x0,0x0), type_stroke)
local progressSp 		= CCScale9Sprite:create("images/common/exp_progress_blue.png")
local starTable 		= {}
local dataCpy 			= {}
local cellCount 		= 0
local cellIndex 		= 1
function init()
    _arrows         = nil
    _selected_icon  = nil
    progressSpDown 		= CCScale9Sprite:create("images/common/exp_progress_blue.png")
    achieLabel  	= CCRenderLabel:create(GetLocalizeStringBy("llp_27"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    progressLabelDown 	= CCRenderLabel:create(GetLocalizeStringBy("key_2504") .. 0 .. "/" ..  100, g_sFontName,18,1,ccc3(0x0,0x0,0x0), type_stroke)
    _old_head_id    = UserModel.getFigureId() -- todo
    _new_head_id    = _old_head_id
    starTable       = {}
    cellCount 		= 0
    cellIndex 		= 1
    haveNum = 0
	totalNum = 0
end

function show(datacpy,have,total)
	dataCpy = datacpy
	starTable = nil
	starTable = {}
	starTable = dataCpy[1]
	haveNumUp = have
	totalNumUp = total
	print("have"..haveNum)
	print("totalNum"..totalNum)
	-- for k,v in pairs(starTable)do
	-- 	if(tonumber(v.status)~=0)then
	-- 		haveNum = haveNum+1
	-- 	end
	-- 	totalNum = totalNum+1
	-- end
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
    print("g_winSize"..g_winSize.width.."height"..g_winSize.height)
    MainScene.setMainSceneViewsVisible(true,false,true)
    bulletinLayerSize = BulletinLayer.getLayerContentSize()
    bottomBg = CCSprite:create("images/common/sell_bottom.png")

    _layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 100))
    _layer:registerScriptHandler(onNodeEvent)

    local dialog_info = {}
    dialog_info.title = GetLocalizeStringBy("llp_169")
    dialog_info.callbackClose = callbackClose
    dialog_info.size = CCSizeMake(640, 900)
    dialog_info.priority = _touch_priority - 1
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    local labelBg = _dialog:getChildByTag(1)

    -- _dialog:setScale(g_fScaleY)
    setAdaptNode(_dialog)
    -- 完成度
    local fullRect = CCRectMake(0,0,101,37)
	local insetRect = CCRectMake(48,20,6,6)
    local progressBg= CCScale9Sprite:create("images/achie/exp.png",fullRect,insetRect)
    progressBg:setContentSize(CCSizeMake(580 ,37))
    -- progressBg:setScale(g_fScaleX)
    progressBg:setAnchorPoint(ccp(0.5,1))
    progressBg:setPosition(_dialog:getContentSize().width/2,_dialog:getContentSize().height- 180 )
    _dialog:addChild(progressBg)

    print("have1"..haveNumUp)
	print("totalNum1"..totalNumUp)
    local progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
    progressSp:setContentSize(CCSizeMake(530* haveNumUp/totalNumUp ,23))
    progressSp:setPosition(26,progressBg:getContentSize().height/2-4)
    progressSp:setAnchorPoint(ccp(0,0.5))
    progressBg:addChild(progressSp)

    local progressLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2504") .. haveNumUp .. "/" ..  totalNumUp, g_sFontName,18,1,ccc3(0x0,0x0,0x0), type_stroke)
    progressLabel:setPosition(ccp(progressBg:getContentSize().width/2,progressBg:getContentSize().height/2))
    progressLabel:setAnchorPoint(ccp(0.5,0.5))
    progressBg:addChild(progressLabel)

    _layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))


    local radio_data = {
        touch_priority  = _touch_priority - 1,
        space         = _radio_menu_space,
        callback        = callbackCountry,
        items           ={
            {normal = "images/achie/copy_n.png", selected = "images/achie/copy_h.png"},
            {normal = "images/achie/person_n.png", selected = "images/achie/person_h.png"},
            {normal = "images/achie/hero_n.png", selected = "images/achie/hero_h.png"},
            {normal = "images/achie/equip_n.png", selected = "images/achie/equip_h.png"}
        }
    }
    _radio_menu = LuaCCSprite.createRadioMenu(radio_data)
    _dialog:addChild(_radio_menu)
    _radio_menu:setAnchorPoint(ccp(0.5, 0.5))
    _radio_menu:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 100))

    local full_rect = CCRectMake(0,0,75, 75)
	local inset_rect = CCRectMake(30,30,15,15)
	local table_view_bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", full_rect, inset_rect)
	table_view_bg:setPreferredSize(CCSizeMake(580, 600))
    _dialog:addChild(table_view_bg,0,10)
    table_view_bg:setAnchorPoint(ccp(0.5, 1))
	table_view_bg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _radio_menu:getPositionY() - _radio_menu:getContentSize().height * 0.5 - 70))

    loadTableView()

    return _layer
end

function callbackCancel()
    callbackClose()
end

function loadTableView()
	table_view_bg = _dialog:getChildByTag(10)

	local node = CCNode:create()
	local flower = CCSprite:create("images/copy/herofrag/cutFlower.png")
	flower:setAnchorPoint(ccp(0.5,0.5))

	node:addChild(flower,10)

	table_view_bg:addChild(node,10)
	achieLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_27"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	achieLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	achieLabel:setAnchorPoint(ccp(0.5,0.5))
	achieLabel:setPosition(ccp(flower:getContentSize().width*0.5,flower:getContentSize().height*0.5))
	flower:addChild(achieLabel,10)
	node:setPosition(ccp(table_view_bg:getContentSize().width*0.5,table_view_bg:getContentSize().height-achieLabel:getContentSize().height*0.5))
    -- _dialog:setScale(g_fScaleX)
    -- _arrows = CCSprite:create("images/chat/arrows.png")
    -- -- table_view_bg:addChild(_arrows)
    -- _arrows:setAnchorPoint(ccp(0.5, 0))
    -- _arrows:setPosition(ccp(53, table_view_bg:getContentSize().height - 1))
    -- 完成度
    local progressBg= CCScale9Sprite:create("images/common/exp_bg.png")
    progressBg:setContentSize(CCSizeMake(400 ,23))
    -- progressBg:setScale(g_fScaleX)
    progressBg:setAnchorPoint(ccp(0.5,1))
    progressBg:setPosition(table_view_bg:getContentSize().width/2,table_view_bg:getContentSize().height-achieLabel:getContentSize().height )
    table_view_bg:addChild(progressBg,0,1)

    local hasHeroNum = 10
    local allHeroNum = 50
    -- progressSpDown = CCScale9Sprite:create("images/common/exp_progress_blue.png")
    progressSpDown:setContentSize(CCSizeMake(400* haveNum/totalNum ,23))
    progressSpDown:setPosition(1,progressBg:getContentSize().height/2)
    progressSpDown:setAnchorPoint(ccp(0,0.5))
    progressBg:addChild(progressSpDown,0,2)

    progressLabelDown:setString(GetLocalizeStringBy("key_2504") .. haveNum .. "/" ..  totalNum)
    progressLabelDown:setPosition(ccp(progressBg:getContentSize().width/2,progressBg:getContentSize().height/2))
    progressLabelDown:setAnchorPoint(ccp(0.5,0.5))
    progressBg:addChild(progressLabelDown,0,3)
    local iconSprite = BTGraySprite:create("images/base/potential/props_" .. 3 .. ".png")
    local nameLabel = CCRenderLabel:create( "11", g_sFontPangWa, 25, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)

    local cell_icon_count = 4
    -- cellCount = table.count(starTable)
	local countIndex = (math.modf((cellCount-1)/4))
	print("countIndexasdfsfs==="..countIndex)
	local cell_size = CCSizeMake(479,(iconSprite:getContentSize().height+nameLabel:getContentSize().height))

	h = LuaEventHandler:create(function(function_name, table_t, a1, cell)
		if function_name == "cellSize" then
			return cell_size
		elseif function_name == "cellAtIndex" then
			print("a1=====", a1)
			cell = CCTableViewCell:create()
			-- 五个star
			local nameLabel = CCRenderLabel:create( "11", g_sFontPangWa, 25, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
			cellCount = table.count(starTable)
			print("个数是"..cellCount)
			local cell_icon_count = 4
			local start = a1 * cell_icon_count
			print("start===="..start)
			print("cellCount===="..cellCount)
			for i=1, 4 do
                local index = start + i
				if index <= cellCount then
					local iconSprite = createHead(starTable[index], callbackSelected, _touch_priority - 1)
		            iconSprite:setAnchorPoint(ccp(0.5, 0.5))
		            iconSprite:setPosition(ccp(cell_size.width/cell_icon_count /1.5 + (i-1) * cell_size.width/cell_icon_count*1.2, cell_size.height * 0.5))
		            cell:addChild(iconSprite)
                end
			end
			return cell
		elseif function_name == "numberOfCells" then
			local x = (math.modf((cellCount-1)/4))
			return x

		elseif function_name == "cellTouched" then
			print("a1=====", a1:getIdx())
		elseif (function_name == "scroll") then
		end
	end)
	_head_table_view = LuaTableView:createWithHandler(h, CCSizeMake(600, 525))
    _head_table_view:ignoreAnchorPointForPosition(false)
    _head_table_view:setAnchorPoint(ccp(0.5, 1))
	_head_table_view:setBounceable(true)
	_head_table_view:setPosition(ccp(table_view_bg:getContentSize().width * 0.5, table_view_bg:getContentSize().height - 75))
	_head_table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    _head_table_view:setTouchPriority(_touch_priority - 2)
	table_view_bg:addChild(_head_table_view)

        --_selected_icon:setVisible(false)

    return table_view_bg
end

function callbackCountry(index, item)
	starTable = nil
	-- table_view_bg = _dialog:getChildByTag(10)
	-- starTable = {}
	print("indexindexindex"..index)
    starTable = dataCpy[index]
    cellCount = table.count(starTable)
    if _head_table_view ~= nil then
        _head_table_view:reloadData()
    end
    haveNum = 0
    totalNum = 0

    for k,v in pairs(starTable)do
		if(v.status~=0)then
			haveNum = haveNum+1
		end
		totalNum = totalNum+1
	end
    local table_view_bg_cpy = _dialog:getChildByTag(10)
    progressSpDown:setContentSize(CCSizeMake(400* haveNum/totalNum ,23))
    progressLabelDown:setString(haveNum.."/"..totalNum)
    if(index == 1)then
    	achieLabel:setString(GetLocalizeStringBy("llp_27"))
	elseif(index == 2)then
		achieLabel:setString(GetLocalizeStringBy("llp_28"))
	elseif(index == 3)then
		achieLabel:setString(GetLocalizeStringBy("llp_29"))
	elseif(index == 4)then
		achieLabel:setString(GetLocalizeStringBy("llp_30"))
	end
end

function callbackSelected(tag, head_item)
    if(ItemUtil.isBagFull() == true )then
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
        return
    end
    require "script/ui/heroCpy/HeroEnter"
    _new_head_id = tag
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

function createHead( tcellData, callback, touch_priority)
	-- 图标底
	local bgSprite = nil
	if(tonumber(tcellData.status)==0)then
		bgSprite = BTGraySprite:create("images/base/potential/props_" .. tcellData.achie_quality .. ".png")
	else
		bgSprite = CCSprite:create("images/base/potential/props_" .. tcellData.achie_quality .. ".png")
	end

	-- 真正的图标
	local iconFile = ("images/achie/".. tcellData.achie_icon)

	-- 按钮Bar
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
    if touch_priority ~= nil then
        menuBar:setTouchPriority(touch_priority)
    end
	bgSprite:addChild(menuBar)

	-- 按钮
	local item_btn = nil
	if(tonumber(tcellData.status)==0)then
		local sp = BTGraySprite:create(iconFile)
		item_btn = CCMenuItemSprite:create(sp, sp)
	else
		item_btn = CCMenuItemImage:create(iconFile,iconFile)
	end

    local nameLabel = CCRenderLabel:create( tcellData.achie_name, g_sFontPangWa, 15, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    if(tonumber(tcellData.status)==0)then
    	nameLabel:setColor(ccc3(125,125,125))
    else
	    if(tonumber(tcellData.achie_quality)==5)then
	    	nameLabel:setColor(ccc3(0xe4,0x00,0xff))
	    elseif(tonumber(tcellData.achie_quality)==4)then
	    	nameLabel:setColor(ccc3(0,228,255))
	    elseif(tonumber(tcellData.achie_quality)==3)then
	    	nameLabel:setColor(ccc3(0,255,24))
	    end
	end
    nameLabel:setAnchorPoint(ccp(0.5,1))
    item_btn:addChild(nameLabel)
    nameLabel:setPosition(ccp(item_btn:getContentSize().width*0.5,0))
	-- item_btn:registerScriptTapHandler(callback)
	item_btn:setAnchorPoint(ccp(0.5, 0.5))
	item_btn:setPosition(ccp(bgSprite:getContentSize().width * 0.5, bgSprite:getContentSize().height * 0.5))
	menuBar:addChild(item_btn, 1)

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
