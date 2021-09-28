-- FileName: GodInheritChooseLayer.lua 
-- Author: licong 
-- Date: 15/4/2 
-- Purpose: 神兵洗练属性传承选择列表 


module("GodInheritChooseLayer", package.seeall)

require "script/ui/bag/GodWeaponBagCell"
require "script/ui/bag/ItemCell"
require "script/ui/item/ItemUtil"
require "script/ui/godweapon/godweaponfix/GodWeaponFixData"

local _bgLayer 							= nil
local _bgSprite 						= nil
local _topBg 							= nil
local _bottomBg 						= nil
local _listTableView 					= nil

local _srcItemId 						= nil -- 要强化的目标item_id
local _callBack 						= nil -- 关闭回调
local _layer_priority 					= nil -- 界面优先级
local _zOrderNum 						= nil -- 界面z轴
local _materialListData 				= {}  -- 可选择列表数据
local _selectList 						= {}  -- 已选择列表
local _lastSelectList 					= nil -- 上次选择的列表

--[[  
	@des 	:初始化
	@param 	:
	@return :
--]]
function init()
	_bgLayer 							= nil
	_bgSprite 							= nil
	_topBg 								= nil
	_bottomBg 							= nil
	_listTableView 						= nil

	_srcItemId 							= nil
	_callBack  							= nil
	_layer_priority 					= nil 
	_zOrderNum  						= nil
	_materialListData 					= {} 
	_selectList 						= {} 
	_lastSelectList 					= nil
end

--[[
	@des 	:初始化数据
	@param 	:
	@return :
--]]
function initSelectData( )
	-- 得到材料列表
	local materialListData = GodWeaponFixData.getCanInheritGodWeapon(_srcItemId)
	-- 得到已选择的列表
	_selectList = GodWeaponFixData.getSelectGodList()
	print("_selectList++") print_t(_selectList)

	-- 报存上次选择的列表
	_lastSelectList = {}
	for k,v in pairs(_selectList) do
		table.insert(_lastSelectList,v)
	end

	-- 排序 已选择的放在最上边
	local tab1 = {}
	local tab2 = {}
	for k,v in pairs(materialListData) do
		local isIn = false
		for k,select_v in pairs(_selectList) do
			if( tonumber(select_v.item_id) == tonumber(v.item_id) )then
				isIn = true
				table.insert(tab1,v)
				break
			end
		end
		if(isIn == false)then
			table.insert(tab2,v)
		end
	end
	for k,v in pairs(tab2) do
		table.insert(_materialListData,v)
	end
	for k,v in pairs(tab1) do
		table.insert(_materialListData,v)
	end

end

---------------------------------------------------------------- 按钮事件 --------------------------------------------------------------------
--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
local function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerTouch,false,_layer_priority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
	end
end

--[[
	@des 	:返回按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end

	-- 返回还原原来的
	GodWeaponFixData.setSelectGodList(_lastSelectList)

	-- 调回调
	if(_callBack ~= nil)then 
		_callBack()
	end
end

--[[
	@des 	:确定按钮回调
	@param 	:
	@return :
--]]
function oKButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end

	-- 调回调
	if(_callBack ~= nil)then 
		_callBack()
	end
end
---------------------------------------------------------------- 工具方法 ------------------------------------------------------------------
--[[
	@des 	:添加到选择列表
	@param 	:
	@return :
--]]
function checkedSelectCell( item_id )
	local isIn = GodWeaponFixData.getIsInSelectListByItemId(item_id)
	if(isIn == false)then
		-- 清除选择的神兵
		GodWeaponFixData.cleanSelectGodList()
		--  添加材料
		GodWeaponFixData.addGodToSelectList(item_id)
	else
		--  添加材料
		GodWeaponFixData.addGodToSelectList(item_id)
	end

	-- 更新数据
	_selectList = GodWeaponFixData.getSelectGodList()

	return isIn
end
---------------------------------------------------------------- 创建ui --------------------------------------------------------------------

--[[
	@des 	:创建上部ui
	@param 	:
	@return :
--]]
function createTopUI( )
	-- 上边背景
	_topBg = CCSprite:create("images/hero/select/title_bg.png")
	_topBg:setAnchorPoint(ccp(0.5, 1))
	_topBg:setPosition(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height)
	_bgLayer:addChild(_topBg)
	_topBg:setScale(g_fScaleX)

	-- 选择材料标题
	local titleSp = CCSprite:create("images/common/god_title.png")
	titleSp:setAnchorPoint(ccp(0,0))
	titleSp:setPosition(ccp(45, 50))
	_topBg:addChild(titleSp)

	-- 返回按钮
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_layer_priority-5)
    _topBg:addChild(menu)

   -- 创建返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/hero/btn_back_n.png","images/hero/btn_back_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:setPosition(ccp(473, 40))
	menu:addChild(closeMenuItem)
	closeMenuItem:registerScriptTapHandler(closeButtonCallback)
end

--[[
	@des 	:创建底部ui
	@param 	:
	@return :
--]]
function createBottomUI()
	_bottomBg = CCSprite:create("images/common/sell_bottom.png")
	_bottomBg:setAnchorPoint(ccp(0.5, 0))
	_bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,0))
	_bgLayer:addChild(_bottomBg, 10)
	_bottomBg:setScale(g_fScaleX)

	-- 确定按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(_layer_priority-5)
	_bottomBg:addChild(menu)

	local okBtn =  LuaMenuItem.createItemImage("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png" )
	okBtn:setAnchorPoint(ccp(0.5, 0.5))
    okBtn:setPosition(ccp(_bottomBg:getContentSize().width*0.5, _bottomBg:getContentSize().height*0.4))
    okBtn:registerScriptTapHandler(oKButtonCallback)
	menu:addChild(okBtn)
end

--[[
	@des 	:创建选择列表
	@param 	:
	@return :
--]]
function createSelectTableView( ... )
	print("_materialListData:")
	print_t(_materialListData)

	local cellSize = CCSizeMake(635,190)
	cellSize.width = cellSize.width * g_fScaleX 
	cellSize.height = cellSize.height * g_fScaleX

    local nHeightOfBottom = (_bottomBg:getContentSize().height-12)*g_fScaleX
	local nHeightOfTitle = (_topBg:getContentSize().height-16)*g_fScaleX
	local _scrollview_height = _bgLayer:getContentSize().height - nHeightOfBottom - nHeightOfTitle

	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
            a2 = GodWeaponBagCell.createCell( _materialListData[a1 + 1], nil, true, false, _selectList, false  )
            a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_materialListData
		elseif fn == "cellTouched" then
			local m_data = _materialListData[a1:getIdx()+1]
			local cellBg = tolua.cast(a1:getChildByTag(1), "CCSprite")
			local menubar_m = tolua.cast(cellBg:getChildByTag(9898), "CCMenu")
			local menuBtn_M = tolua.cast(menubar_m:getChildByTag(tonumber(m_data.item_id)), "CCMenuItemSprite")
			
			local isIn = checkedSelectCell(tonumber(m_data.item_id))
			if(isIn == true) then
				menuBtn_M:unselected()
			else
				menuBtn_M:selected()
			end

			-- 刷新tableview
			local offset = _listTableView:getContentOffset() 
			_listTableView:reloadData()
			_listTableView:setContentOffset(offset)
		else
		end
		return r
	end)
	_listTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width, _scrollview_height))
    _listTableView:setAnchorPoint(ccp(0,0))
	_listTableView:setBounceable(true)
	_listTableView:setTouchPriority(_layer_priority-3)
	_listTableView:setPosition(ccp(0,nHeightOfBottom))
	_bgLayer:addChild(_listTableView)
end

--[[
	@des 	: 初始化材料界面
	@param 	: 
	@return :
--]]
function initSelectLayer()
	-- 上部分ui
	createTopUI()

	-- 创建底部ui
	createBottomUI()

	-- 创建选择列表
	createSelectTableView()
end

--[[
	@des 	: 显示选择材料界面
	@param 	: p_srcItemId 要强化的目标item_id
	@return :
--]]
function showSelectLayer( p_srcItemId, p_CallBack, p_layer_priority, p_zOrderNum )

	-- 初始化变量
	init()

	-- 接收参数
	_srcItemId = tonumber(p_srcItemId)
	_callBack = p_CallBack
	_layer_priority = p_layer_priority or -550
	_zOrderNum = p_zOrderNum or 1000

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrderNum,1)

    -- 大背景
    _bgSprite = CCSprite:create("images/main/module_bg.png")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 初始化数据
    initSelectData()

    -- 初始化界面
    initSelectLayer()
end










































































































