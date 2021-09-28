-- FileName: GodWeaponSelectLayer.lua 
-- Author: licong 
-- Date: 14-12-18 
-- Purpose: 强化材料选择界面 


module("GodWeaponSelectLayer", package.seeall)

require "script/ui/bag/GodWeaponBagCell"
require "script/ui/bag/ItemCell"
require "script/ui/item/ItemUtil"
require "script/ui/godweapon/GodWeaponData"

local _bgLayer 							= nil
local _bgSprite 						= nil
local _topBg 							= nil
local _bottomBg 						= nil

local _disItemId 						= nil -- 要强化的目标item_id
local _callBack 						= nil -- 关闭回调
local _layer_priority 					= nil -- 界面优先级
local _zOrderNum 						= nil -- 界面z轴
local _materialListData 				= {}  -- 材料列表数据
local _selectList 						= {}  -- 已选择列表
local _maxSelectNum 					= nil

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

	_disItemId 							= nil
	_callBack  							= nil
	_layer_priority 					= nil 
	_zOrderNum  						= nil
	_materialListData 					= {} 
	_selectList 						= {} 
	_maxSelectNum 						= nil
	
end

--[[
	@des 	:初始化数据
	@param 	:
	@return :
--]]
function initSelectData( )
	-- 得到材料列表
	local materialListData = GodWeaponData.getMaterialForGodWeapon(_disItemId)
	-- 得到已选择的列表
	_selectList = GodWeaponData.getMaterialSelectList()
	print("_selectList++") print_t(_selectList)

	-- 排序 已选择的放在最上边
	local tab1 = {}
	local tab2 = {}
	local tab3 = {}
	for k,v in pairs(materialListData) do
		if(tonumber(v.itemDesc.maxStacking) > 1 )then
			table.insert(tab3,v)
		else
			local isIn = false
			for k,select_Data in pairs(_selectList) do
				if( tonumber(select_Data.item_id) == tonumber(v.item_id) )then
					isIn = true
					table.insert(tab1,v)
					break
				end
			end
			if(isIn == false)then
				table.insert(tab2,v)
			end
		end
	end
	for k,v in pairs(tab2) do
		table.insert(_materialListData,v)
	end
	for k,v in pairs(tab1) do
		table.insert(_materialListData,v)
	end
	for k,v in pairs(tab3) do
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
function checkedSelectCell( item_id, p_num )

	local isIn = GodWeaponData.getIsInSelectListByItemId(item_id)
	print("isIn",isIn,item_id)
	local chooseNum = table.count(_selectList)
	if( chooseNum >= _maxSelectNum and isIn == false)then  
		-- 五个了 不能再选择了
		AnimationTip.showTip(GetLocalizeStringBy("lic_1431"))
		return true
	end

	--  添加材料
	GodWeaponData.addMaterialToSelectList(item_id, p_num)

	-- 更新数据
	_selectList = GodWeaponData.getMaterialSelectList()

	print("choos==>_selectList")
	print_t(_selectList)

	return isIn
end
---------------------------------------------------------------- 创建ui --------------------------------------------------------------------
--[[
	@des 	:刷新底部ui
	@param 	:
	@return :
--]]
function refreshBottomSprite()
	local chooseNum = 0
	for k,v in pairs(_selectList) do
		chooseNum = chooseNum + v.num
	end
	_itemNumLabel:setString(chooseNum)

	local totalExpNum = GodWeaponData.getOfferExpBySelectList(_selectList)
	_totalExpLabel:setString(totalExpNum)
end

--[[
	@des 	:创建上部ui
	@param 	:
	@return :
--]]
function createTopUi( )
	-- 上边背景
	_topBg = CCSprite:create("images/hero/select/title_bg.png")
	_topBg:setAnchorPoint(ccp(0.5, 1))
	_topBg:setPosition(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height)
	_bgLayer:addChild(_topBg)
	_topBg:setScale(g_fScaleX)

	-- 选择材料标题
	local titleSp = CCSprite:create("images/common/title_1.png")
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
function createBottomUi()
	_bottomBg = CCSprite:create("images/common/sell_bottom.png")
	_bottomBg:setAnchorPoint(ccp(0.5, 0))
	_bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,0))
	_bgLayer:addChild(_bottomBg, 10)
	_bottomBg:setScale(g_fScaleX)

	-- 已选择材料
	local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1430"), g_sFontName, 25)
	tipLabel:setColor(ccc3(0xff, 0xff, 0xff))
	tipLabel:setAnchorPoint(ccp(0, 0.5))
	tipLabel:setPosition(ccp(10, _bottomBg:getContentSize().height*0.4))
	_bottomBg:addChild(tipLabel)

	-- 材料数量背景
	local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(10,10,14,12)
	local itemNumSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	itemNumSprite:setPreferredSize(CCSizeMake(65, 38))
	itemNumSprite:setAnchorPoint(ccp(0,0.5))
	itemNumSprite:setPosition(ccp(tipLabel:getPositionX()+tipLabel:getContentSize().width+2, tipLabel:getPositionY()))
	_bottomBg:addChild(itemNumSprite)

	-- 物品数量
	_itemNumLabel = CCLabelTTF:create(0, g_sFontName, 25)
	_itemNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_itemNumLabel:setAnchorPoint(ccp(0.5, 0.5))
	_itemNumLabel:setPosition(ccp(itemNumSprite:getContentSize().width*0.5, itemNumSprite:getContentSize().height*0.4))
	itemNumSprite:addChild(_itemNumLabel)

	-- 获得经验
	local tipExpLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3142"), g_sFontName, 25)
	tipExpLabel:setColor(ccc3(0xff, 0xff, 0xff))
	tipExpLabel:setAnchorPoint(ccp(0, 0.5))
	tipExpLabel:setPosition(ccp(itemNumSprite:getPositionX()+itemNumSprite:getContentSize().width+10, tipLabel:getPositionY()))
	_bottomBg:addChild(tipExpLabel) 

	-- 获得经验背景
	local totalExpSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	totalExpSprite:setPreferredSize(CCSizeMake(75, 38))
	totalExpSprite:setAnchorPoint(ccp(0,0.5))
	totalExpSprite:setPosition(ccp(tipExpLabel:getPositionX()+tipExpLabel:getContentSize().width+2, tipExpLabel:getPositionY()))
	_bottomBg:addChild(totalExpSprite)
	
	-- 获得经验数量
	_totalExpLabel = CCLabelTTF:create(0, g_sFontName, 25)
	_totalExpLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_totalExpLabel:setAnchorPoint(ccp(0.5, 0.5))
	_totalExpLabel:setPosition(ccp(totalExpSprite:getContentSize().width*0.5, totalExpSprite:getContentSize().height*0.4))
	totalExpSprite:addChild(_totalExpLabel)

	-- 确定按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(_layer_priority-5)
	_bottomBg:addChild(menu)

	local okBtn =  LuaMenuItem.createItemImage("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png" )
	okBtn:setAnchorPoint(ccp(0.5, 0.5))
    okBtn:setPosition(ccp(_bottomBg:getContentSize().width*0.88, _bottomBg:getContentSize().height*0.4))
    okBtn:registerScriptTapHandler(closeButtonCallback)
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

	local visiableCellNum = math.floor(_scrollview_height/(cellSize.height*g_fScaleX)) --计算可视的有几个cell
	
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
            a2 = GodWeaponBagCell.createCell( _materialListData[a1 + 1], nil, true, true, _selectList, false, nil, _layer_priority-2, _maxSelectNum  )
            a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_materialListData
		elseif fn == "cellTouched" then
			local m_data = _materialListData[a1:getIdx()+1]
			local cellBg = tolua.cast(a1:getChildByTag(1), "CCSprite")
			local menubar_m = tolua.cast(cellBg:getChildByTag(9898), "CCMenu")
			local menuBtn_M = tolua.cast(menubar_m:getChildByTag(tonumber(m_data.item_id)), "CCMenuItemSprite")
			if( tonumber(m_data.itemDesc.maxStacking) > 1 )then
			else
				local isIn = checkedSelectCell(tonumber(m_data.item_id),1)
				if(isIn == true) then
					menuBtn_M:unselected()
				else
					menuBtn_M:selected()
				end
			end
			refreshBottomSprite()
		else
		end
		return r
	end)
	local listTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width, _scrollview_height))
    listTableView:setAnchorPoint(ccp(0,0))
	listTableView:setBounceable(true)
	listTableView:setTouchPriority(_layer_priority-3)
	listTableView:setPosition(ccp(0,nHeightOfBottom))
	_bgLayer:addChild(listTableView)

	-- 刷新底部
	refreshBottomSprite()
end

--[[
	@des 	: 初始化材料界面
	@param 	: 
	@return :
--]]
function initSelectLayer()
	-- 上部分ui
	createTopUi()

	-- 创建底部ui
	createBottomUi()

	-- 创建选择列表
	createSelectTableView()
end

--[[
	@des 	: 显示选择材料界面
	@param 	: p_disItemId 要强化的目标item_id
	@return :
--]]
function showSelectLayer( p_disItemId, p_CallBack, p_layer_priority, p_zOrderNum, p_maxNum )

	-- 初始化变量
	init()

	-- 接收参数
	_disItemId = tonumber(p_disItemId)
	_callBack = p_CallBack
	_layer_priority = p_layer_priority or -550
	_zOrderNum = p_zOrderNum or 1000
	_maxSelectNum = p_maxNum

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
















































