-- FileName: ShowCanFixDialog.lua 
-- Author: licong 
-- Date: 15-1-15 
-- Purpose: 可洗练属性界面


module("ShowCanFixDialog", package.seeall)

require "script/ui/godweapon/godweaponfix/GodWeaponFixData"


local _bgLayer                  		= nil
local _bgSprite 						= nil

local _showItemId 						= nil -- 神兵itemid
local _showItemInfo 					= nil -- 神兵信息
local _fixNum 							= nil -- 洗练属性的总层数
local _showAttrTab 						= nil -- 可洗练的属性数据

local _layer_priority 					= nil -- 界面优先级
local _zOrder 							= nil -- 界面z轴

--[[
    @des    :init
--]]
function init( ... )
	_bgLayer                    		= nil
	_bgSprite 							= nil

	_showItemId 						= nil
	_showItemInfo 						= nil
	_fixNum 							= nil
	_showAttrTab 						= nil

	_layer_priority 					= nil
	_zOrder 							= nil 
end

-------------------------------------------------------- 按钮事件 ---------------------------------------------------------
--[[
	@des 	:touch事件处理
--]]
function layerTouch(eventType, x, y)
    return true
end

--[[
    @des    :回调onEnter和onExit事件
--]]
function onNodeEvent( event )
    if (event == "enter") then
        _bgLayer:registerScriptTouchHandler(layerTouch,false,_layer_priority,true)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then
    end
end

--[[
	@des 	:关闭按钮回调
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

------------------------------------------------------------- 创建UI ----------------------------------------------
--[[
	@des 	:创建底部UI
	@param 	:p_fixId:洗练属性层id
	@return :sprite
--]]
function createAttrUI(p_fixId)

	local retSprite = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	retSprite:setContentSize(CCSizeMake(600, 175))

	-- 层图标
	local iconArr = {"lv.png","lan.png","zi.png","cheng.png","hong.png"} -- 层图标
	local iconSprite = CCSprite:create( "images/god_weapon/fix/" .. iconArr[p_fixId] )
	iconSprite:setAnchorPoint(ccp(0,0.5))
	iconSprite:setPosition(ccp(25,retSprite:getContentSize().height*0.5))
	retSprite:addChild(iconSprite)
	-- 标题
	local titleArr = {GetLocalizeStringBy("lic_1457"),GetLocalizeStringBy("lic_1458"),GetLocalizeStringBy("lic_1459"),GetLocalizeStringBy("lic_1460"),GetLocalizeStringBy("llp_515")}
	local titleFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1456",titleArr[p_fixId]) ,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleFont:setColor(ccc3(0xff,0xf6,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0))
	titleFont:setPosition(ccp(iconSprite:getContentSize().width*0.5,0))
	iconSprite:addChild(titleFont)

	-- 可洗出的属性值
	local curShowAttrTab = _showAttrTab[p_fixId]
	print("curShowAttrTab",table.count(curShowAttrTab),#curShowAttrTab)
	require "db/DB_Affix"
 	local posX = {140,240,340,440}
 	local posY = {15,40,65,90,115,140,165}
 	for i=0,#curShowAttrTab-1 do
 		local temData = DB_Affix.getDataById(curShowAttrTab[i+1])
 		local attrNameFont = CCRenderLabel:create(temData.godarmName,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameFont:setColor(ccc3(0xff,0xff,0xff))
		attrNameFont:setAnchorPoint(ccp(0,1))
		attrNameFont:setPosition(ccp(posX[i%4+1], retSprite:getContentSize().height-posY[math.floor(i/4)+1]))
		retSprite:addChild(attrNameFont)
 	end

	return retSprite
end

--[[
	@des 	: 创建UI
--]]
function createUI()
	-- 返回按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_layer_priority-2)
    _bgLayer:addChild(menuBar,1)

    -- 创建返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(1, 1))
	closeMenuItem:setPosition(ccp( _bgLayer:getContentSize().width-10*g_fElementScaleRatio,_bgLayer:getContentSize().height-10*g_fElementScaleRatio ))
	menuBar:addChild(closeMenuItem)
	closeMenuItem:registerScriptTapHandler(closeButtonCallback)
	closeMenuItem:setScale(g_fElementScaleRatio)

	-- 背景
	_bgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	if(_fixNum>=4)then
		_bgSprite:setContentSize(CCSizeMake(600, 640))
	else
		_bgSprite:setContentSize(CCSizeMake(600, 600))
	end
	
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(_bgSprite)
	_bgSprite:setScale(g_fElementScaleRatio)

	-- 标题背景
	local titleSp = CCSprite:create("images/common/red_2.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height))
	_bgSprite:addChild(titleSp)
	-- 标题
	local titleFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1470") ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleFont:setColor(ccc3(0xff,0xf6,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height*0.5))
	titleSp:addChild(titleFont)

	local cell_icon_count = _fixNum
	local cell_size = CCSizeMake(600,175)

	h = LuaEventHandler:create(function(function_name, table_t, a1, cell)
		if function_name == "cellSize" then
			return cell_size
		elseif function_name == "cellAtIndex" then
			cell = CCTableViewCell:create()
			local cellSprite = createAttrUI(a1+1)
			cell:addChild(cellSprite)
			return cell
		elseif function_name == "numberOfCells" then
			return _fixNum
		elseif function_name == "cellTouched" then
			print("a1=====", a1:getIdx())
		elseif (function_name == "scroll") then
		end
	end)
	local _head_table_view = LuaTableView:createWithHandler(h, CCSizeMake(600, 600))
    _head_table_view:ignoreAnchorPointForPosition(false)
    _head_table_view:setAnchorPoint(ccp(0.5, 0.5))
	_head_table_view:setBounceable(true)
	_head_table_view:setPosition(ccp(_bgSprite:getContentSize().width * 0.5, _bgSprite:getContentSize().height* 0.5))
	_head_table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    _head_table_view:setTouchPriority(_layer_priority - 2)
	_bgSprite:addChild(_head_table_view)

	-- 创建每层属性UI
	-- for i=1,_fixNum do 
	-- 	local attrSprite = createAttrUI(i)
	-- 	attrSprite:setAnchorPoint(ccp(0.5,1))
	-- 	attrSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height - 30 - (attrSprite:getContentSize().height+15)*(i-1) ))
	-- 	_bgSprite:addChild(attrSprite)
	-- end

end

--[[
	@des 	: 显示可洗练属性界面
	@param 	:p_godWeaponItemId:神兵itemid, p_layer_priority:界面优先级, p_zOrder:界面Z轴
	@return :
--]]
function showLayer( p_godWeaponItemId, p_layer_priority, p_zOrder )
	-- 初始化
	init()

	-- 接收参数
	_showItemId = p_godWeaponItemId
	_layer_priority = p_layer_priority or -600
	_zOrder = p_zOrder or 1000

	-- 神兵信息
	_showItemInfo = ItemUtil.getItemByItemId(_showItemId)
	-- 洗练属性的总层数
	_fixNum = GodWeaponFixData.getGodWeapinFixNum(nil,_showItemId)
	-- 可洗练的属性数据
	_showAttrTab = GodWeaponFixData.getGodWeapinCanFixAttrTab(nil,_showItemId)

	_bgLayer = CCLayerColor:create(ccc4(8,8,8,150))
    _bgLayer:registerScriptHandler(onNodeEvent) 

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder,1)

    -- 创建ui
    createUI()
end


















