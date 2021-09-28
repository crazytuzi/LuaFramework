-- Filename：	FormationSettingLayer.lua
-- Author：		bzx
-- Date：		2015-3-3
-- Purpose：		设置阵型

module ("FormationSettingLayer", package.seeall)

LayerType = {
	GoldTree = 1,
	WorldBoss = 2,
}

local _layer
local _type 			-- 界面类型（摇钱树阵型、世界Boss阵型）
local _touchPriority 
local _zOrder
local _cellSize 					-- 中部Cell的尺寸
local _tableView 					-- 中部的TableView
local _offset						-- TableView的偏移量
local _leftArrow  					-- TableView左边箭头			
local _rightArrow 					-- TableView右边箭头
local _dragBeganX 					-- touchBegin时TableView的x轴偏移量
local _touchBeganX 					-- touchBegin时触点的x位置
local _isHandleTouch 				-- 是否要处理这个触摸事件
local _pageIndex                    -- 当前第几页

function show(p_type, p_touchPriority, p_zOrder )
	_layer = create(p_type, p_touchPriority, p_zOrder)
	_layer:registerScriptHandler(onNodeEvent)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, p_zOrder)
end

function init()
	_layer = nil
	_type = 0
	_priority = 0
	_zOrder = 0
	_cellSize 				= nil
 	_tableView 				= nil
 	_offset					= nil
 	_leftArrow 				= nil
 	_rightArrow 			= nil
 	_dragBeganX 			= 0
 	_touchBeganX 			= 0
 	_isHandleTouch 			= false
    _pageIndex              = 0
end

function initData(p_type, p_touchPriority, p_zOrder)
	_type = p_type or 0
	_touchPriority = p_touchPriority or -200
	_zOrder = p_zOrder or -200
	_pageIndex = 1
end

function create(p_type, p_touchPriority, p_zOrder)
	init()
	initData(p_type, p_touchPriority, p_zOrder)
	_layer = CCLayerColor:create(ccc4(0, 0, 0, 0xaa))
	loadFormation()
	return _layer
end

function loadFormation( ... )
	_cellSize = CCSizeMake(g_winSize.width,  690 * g_fScaleX)
	local tableViewEvent = LuaEventHandler:create(function(p_functionName, p_tableView, p_index, p_cell)
		if p_functionName == "cellSize" then
			return _cellSize
		elseif p_functionName == "cellAtIndex" then
            local cell = createCell(p_index + 1)
            return cell
		elseif p_functionName == "numberOfCells" then
            return getNumberOfCells()
		elseif p_functionName == "cellTouched" then
		elseif p_functionName == "scroll" then
			refreshArrow()
		end
	end)
	_tableView = LuaTableView:createWithHandler(tableViewEvent, _cellSize)
    _layer:addChild(_tableView)
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setAnchorPoint(ccp(0.5, 0.5))
    _tableView:setTouchEnabled(false)
	_tableView:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _tableView:setDirection(kCCScrollViewDirectionHorizontal)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setTouchEnabled(false)
    loadArrow()
end

function getNumberOfCells( ... )
	local cellCount = 1
	if _type == LayerType.GoldTree then
		if DataCache.getTreeFormationInfo() == nil then
			cellCount = 1
		else
			cellCount = 2
		end
	elseif _type == LayerType.WorldBoss then
		if table.isEmpty(BossData.getFormation()) then
			cellCount = 1
		else
			cellCount = 2
		end
	end
	return cellCount
end

--[[
    @descL:                 显示TableView两边的箭头
    @return:    nil
--]]
function loadArrow( ... )
	 _leftArrow = CCSprite:create( "images/common/arrow_up_h.png")
    _layer:addChild(_leftArrow)
    _leftArrow:setAnchorPoint(ccp(0.5, 0.5))
    _leftArrow:setPosition(ccp(30 * g_fScaleX, _tableView:getPositionY() + 50 * g_fScaleX))
    _leftArrow:setRotation(-90)
    _leftArrow:setVisible(false)
    _leftArrow:setScale(g_fScaleX)
    local leftArrowAction = createArrowAction()
    _leftArrow:runAction(leftArrowAction)

    _rightArrow = CCSprite:create( "images/common/arrow_up_h.png")
    _layer:addChild(_rightArrow)
    _rightArrow:setPosition(ccp(g_winSize.width - 30 * g_fScaleX, _tableView:getPositionY() + 50 * g_fScaleX))
    _rightArrow:setAnchorPoint(ccp(0.5, 0.5))
    _rightArrow:setRotation(90)
    _rightArrow:setScale(g_fScaleX)
    _rightArrow:setVisible(false)
    local rightArrowAction = createArrowAction()
    _rightArrow:runAction(rightArrowAction)
    refreshArrow()
end

--[[
    @desc:                  刷新箭头（是否显示）
    @return:    nil
--]]
function refreshArrow( ... )
	if _leftArrow == nil then
        return
    end
    if _pageIndex == 1 then
    	_leftArrow:setVisible(false)
    else
    	_leftArrow:setVisible(true)
    end
    if _pageIndex == getNumberOfCells() then
    	_rightArrow:setVisible(false)
    else
    	_rightArrow:setVisible(true)
    end
end

--[[
    @desc:              创建箭头闪动动画
    @return:    nil
--]]
function createArrowAction( ... )
	local arrowActions = CCArray:create()
    arrowActions:addObject(CCFadeIn:create(1))
    arrowActions:addObject(CCFadeOut:create(1))
    local action = CCRepeatForever:create(CCSequence:create(arrowActions))
    return action
end

function createCell(p_index)
    local cell = CCTableViewCell:create()
    local node = CCNode:create()
    cell:addChild(node)
    node:setScale(MainScene.elementScale)
    node:setAnchorPoint(ccp(0.5, 0.5))
    node:setContentSize(CCSizeMake(640, 602))
    node:setPosition(ccp(_cellSize.width * 0.5, _cellSize.height * 0.5))
    local bg = CCScale9Sprite:create("images/forge/tip_bg.png")
    node:addChild(bg)
    bg:setPreferredSize(CCSizeMake(577, 660))
    bg:setAnchorPoint(ccp(0.5, 0.5))
    bg:setPosition(ccpsprite(0.476, 0.5, node))
    
    local title = nil
    local formationData = nil
    if p_index == getNumberOfCells() then
    	title = CCSprite:create("images/forge/cur_formation.png")
    	formationData = DataCache.getCurFormation()
	else
		if _type == LayerType.GoldTree then
	    	title = CCSprite:create("images/forge/gold_tree_formation.png")
	    	formationData = DataCache.getTreeFormationInfo()
	    elseif _type == LayerType.WorldBoss then
	    	title = CCSprite:create("images/forge/boss_formation.png")
	    	formationData = BossData.getFormation()
	    end
	end
    bg:addChild(title)
    title:setAnchorPoint(ccp(0.5, 0.5))
    title:setPosition(ccp(bg:getContentSize().width * 0.5 + 18, bg:getContentSize().height - 5))
	for i = 1, 6 do
		local box = CCSprite:create("images/forge/hero_bg.png")
		bg:addChild(box)
		box:setAnchorPoint(ccp(0.5, 0.5))
		box:setPosition(ccp(130 + (i - 1) % 3 * 170, 500 - math.floor((i - 1) / 3) * 230))
		box:setScale(0.9)

		local heroData = formationData[tostring(i - 1)] or formationData[i]
		if heroData ~= nil then
			if HeroModel.isNecessaryHero(heroData.htid) then
				heroData.name = UserModel.getUserName()
			end
			require "script/battle/BattleCardUtil"
			heroData.dress = heroData.dress or {}
			local hero = HeroSprite.createHeroSpriteByHeroData(heroData)
			bg:addChild(hero, 7 - i)
			hero:setAnchorPoint(ccp(0.5, 0.5))
			hero:setPosition(ccp(box:getPositionX(), box:getPositionY() - 16))
			hero:setScale(0.9)
		end
	end

    local nodeMenu = BTSensitiveMenu:create()
    node:addChild(nodeMenu, 3)
    nodeMenu:setPosition(ccp(0, 0))
    nodeMenu:setContentSize(node:getContentSize())
    nodeMenu:setTouchPriority(_touchPriority - 1)
    
    local backItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(200, 73), GetLocalizeStringBy("key_8546"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	nodeMenu:addChild(backItem)
	backItem:setAnchorPoint(ccp(0.5, 0.5))
	backItem:setPosition(ccpsprite(0.5, 0.13, nodeMenu))
	backItem:registerScriptTapHandler(backCallback)
	if p_index == getNumberOfCells() then
		backItem:setPosition(ccpsprite(0.22, 0.13, nodeMenu))
		local saveItem = nil
		if _type == LayerType.GoldTree then
			saveItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png", "images/common/btn/btn_red_h.png", CCSizeMake(350, 73), GetLocalizeStringBy("key_8547"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		elseif _type == LayerType.WorldBoss then
			saveItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png", "images/common/btn/btn_red_h.png", CCSizeMake(350, 73), GetLocalizeStringBy("key_8548"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		end
		nodeMenu:addChild(saveItem)
		saveItem:setAnchorPoint(ccp(0.5, 0.5))
		saveItem:setPosition(ccpsprite(0.67, 0.13, nodeMenu))
		saveItem:registerScriptTapHandler(saveCallback)
	end
    return cell
end

function backCallback( ... )
	close()
end

function saveCallback( ... )
	if _type == LayerType.GoldTree then
		RequestCenter.copy_refreshBattleInfo(saveHandler, nil)
	elseif _type == LayerType.WorldBoss then
		BossNet.setBossFormation(saveSucceed)
	end
end

--[[
	@desc:			保存摇钱树阵型的网络回调
	@return:	nil
--]]
function saveHandler( cbFlag, dictData, bRet )
	if not bRet then
		return 
	end
	local formationData = DataCache.getCurFormation()
	DataCache.setTreeFormationInfo(formationData)
	saveSucceed()
end

--[[
	@desc:			保存阵型成功
--]]
function saveSucceed( ... )
	AnimationTip.showTip(GetLocalizeStringBy("key_10023"))
	close()
end

function close( ... )
	_layer:removeFromParentAndCleanup(true)
end

function onNodeEvent( p_event )
	if p_event == "enter" then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_layer:setTouchEnabled(true)
	elseif p_event == "exit" then
		_layer:unregisterScriptTouchHandler()
	end
end

function onTouchesHandler(p_event, p_x, p_y)
	local position = ccp(p_x, p_y)
    if p_event == "began" then
        local rect = _tableView:boundingBox()
        if rect:containsPoint(position) and getNumberOfCells() > 1 then
            _dragBeganX = _tableView:getContentOffset().x
            _touchBeganX = position.x
            _isHandleTouch = true
        else
            _isHandleTouch = false
        end
        return true
    elseif p_event == "moved" then
        if _isHandleTouch == true then
            local offset = _tableView:getContentOffset()
            offset.x = _dragBeganX + position.x - _touchBeganX
            local maxX = 0
            local minX = -_cellSize.width * (getNumberOfCells() - 1)
           	offset.x = offset.x > maxX and maxX or offset.x
           	offset.x = offset.x < minX and minX or offset.x
            _tableView:setContentOffset(offset)
        end
    elseif p_event == "ended" or p_event == "cancelled" then
        if _isHandleTouch == true then
            local dragEndedX = _tableView:getContentOffset().x
            local dragDistance = dragEndedX - _dragBeganX
            local offset = _tableView:getContentOffset()
            if dragDistance >= 100 then
                _pageIndex = _pageIndex - 1
                _pageIndex = _pageIndex < 1 and 1 or _pageIndex
            elseif dragDistance <= -100 then
                _pageIndex = _pageIndex + 1
                _pageIndex = _pageIndex > getNumberOfCells() and getNumberOfCells() or _pageIndex
            end
            refreshArrow()
            local container = _tableView:getContainer()
            local offset = ccp(-(_pageIndex - 1) * _cellSize.width, 0)
       		local offsetTemp = _tableView:getContentOffset()
       		if offset.x ~= offsetTemp.x then
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
        	end
            _offset = offset
        end
    end
end
