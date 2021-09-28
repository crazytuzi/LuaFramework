-- FileName: GuildWar16Layer.lua 
-- Author: bzx
-- Date: 15-1-13 
-- Purpose:  跨服军团战16强到4强

module("GuildWar16Layer", package.seeall)

require "script/ui/guildWar/promotion/GuildWarGuildPromotionSprite"
require "script/ui/guildWar/guildInfo/MyGuildWarInfoDialog"
require "script/ui/guildWar/support/GuildWarSupportData"
require "script/ui/guildWar/promotion/GuildWarPromotionData"
require "script/ui/guildWar/promotion/GuildWarPromotionService"
require "script/ui/guildWar/GuildWarUtil"
require "script/ui/tip/AnimationTip"
require "script/libs/LuaCCLabel"
require "script/ui/guildWar/promotion/GuildWarPromotionUtil"
require "script/ui/guildWar/promotion/GuildWarPromotionController"
require "script/ui/guildWar/GuildWarStageEvent"

local _layer 
local _zOrder						-- 本层Z轴
local _touchPriority				-- 本层触摸优先级
local _cellPositionData 			-- 军团Icon, 线条，按钮位置信息
local _isMenuVisible				-- 进入该界面之前主界面的菜单是否可见
local _isAvatarVisible				-- 进入该界面之前主界面的玩家信息面板是否可见
local _isBulletinVisible			-- 进入该界面之前主界面的跑马灯公告是否可见
local _topNode 						-- 顶部UI
local _bottomNode 					-- 底部UI
local _cellSize 					-- 中部Cell的尺寸
local _tableView 					-- 中部的TableView
local _offset						-- TableView的偏移量
local _leftArrow  					-- TableView左边箭头			
local _rightArrow 					-- TableView右边箭头
local _dragBeganX 					-- touchBegin时TableView的x轴偏移量
local _touchBeganX 					-- touchBegin时触点的x位置
local _isHandleTouch 				-- 是否要处理这个触摸事件
local _lastLayerName                -- 上一个界面的名称
local _addWinCountItem              -- 增加连胜的按钮
local _addWinCountTipNode           -- 增加连胜按钮下面的提示
local _pageIndex                    -- 当前第几页

--[[
	@desc: 				                显示本界面
	@param:    number p_touchPriority 	触摸优先级
	@param:    nubmer p_zOrder			z轴
    @param:    string p_lastLayerName   上一个界面的名称
    @param:    bool   p_isNoRequest     是否需要请求数据
 	@return:			                nil
--]]
 function show(p_touchPriority, p_zOrder, p_lastLayerName, p_isNoRequest)

    _layer = create(p_touchPriority, p_zOrder, p_lastLayerName)
    MainScene.changeLayer(_layer, "GuildWar16Layer") 
    local requestCallback = function ( ... )
        loadTableView()
        loadArrow()
    end
    if not p_isNoRequest then
        local requestCallback2 = function ( ... )
            GuildWarPromotionService.getGuildWarInfo(requestCallback)
        end
        GuildWarMainService.getUserGuildWarInfo(requestCallback2)
    else
        requestCallback()
    end
 end

 function init( ... )
 	_layer 					= nil
 	_zOrder 				= 0
 	_touchPriority  		= 0
 	_cellPositionData  		= {}
 	_isMenuVisible  		= false
 	_isAvatarVisible  		= false
 	_isBulletinVisible  	= false
 	_topNode 				= nil
 	_bottomNode 			= nil
 	_cellSize 				= nil
 	_tableView 				= nil
 	_offset					= nil
 	_leftArrow 				= nil
 	_rightArrow 			= nil
 	_dragBeganX 			= 0
 	_touchBeganX 			= 0
 	_isHandleTouch 			= false
    _lastLayerName          = ""
    _addWinCountItem        = nil
    _addWinCountTipNode     = nil
    _pageIndex              = 0
 end

 function initData( p_touchPriority, p_zOrder, p_lastLayerName )
 	_touchPriority = p_touchPriority or -180
 	_zOrder = p_zOrder or 1
    _lastLayerName = p_lastLayerName or ""
    _pageIndex = 1
 	initPositions()
 end

--[[
	@desc:		初始化军团Icon，线条，按钮的位置信
	@return:	nil
--]]
 function initPositions( ... )
 	local l = function(position, scaleX, scaleY, rotation)
        return {["position"] = position, ["scaleX"] = scaleX, ["scaleY"] = scaleY, ["rotation"] = rotation}
    end
    _cellPositionData = {
        [16] = {
        	-- 军团Icon
            guildPositions = {
                ccp(128, 500), ccp(512, 500), ccp(128, 120), ccp(512, 120)
            },
            -- 晋级线
            lineDatas = {
                l(ccp(230, 500), 1.8), l(ccp(410, 500), 1.8, 1), l(ccp(230, 120), 1.8, 1), l(ccp(410, 120), 1.8, 1)
            },
            -- 助威，查看战报按钮
            btnPositions = {
                ccp(320, 500), ccp(320, 120)
            }
        },
        [8] = {
            lineDatas = {
                l(ccp(320, 420), 1.8, 1, 90), l(ccp(320, 180), 1.8, 1, 90)
            },
            btnPositions = {
                ccp(440, 301)
            }
        },
        [4] = {
            guildPositions = {
                ccp(319, 301)
            },
        }
    }
 end

--[[
	@desc:				                    创建本层
	@param:    number  p_touchPriority	    本层触摸优先级
	@param:    number  p_zOrder 		    z轴	
    @param:    string  p_lastLayerName      上一个界面的名称
--]]
 function create( p_touchPriority, p_zOrder, p_lastLayerName )
 	init()
 	initData(p_touchPriority, p_zOrder, p_lastLayerName)
 	_layer = CCLayer:create()
 	_layer:registerScriptHandler(onNodeEvent)
 	loadBg()
 	loadTop()
 	loadBottom()
 	return _layer
 end

--[[
	@desc:		显示本界面的背景
	@return:	nil
--]]
function loadBg()
    local bg = CCSprite:create("images/lord_war/bg.jpg")
    _layer:addChild(bg)
    bg:setAnchorPoint(ccp(0.5, 0.5))
    bg:setPosition(ccpsprite(0.5, 0.5, _layer))
    bg:setScale(MainScene.bgScale)
end

--[[
	@desc:		显示顶部UI
	@return:	nil
--]]
function loadTop()
    _topNode = GuildWarPromotionUtil.createTopNode("GuildWar16Layer", _touchPriority - 1)
    _layer:addChild(_topNode)
    _topNode:setAnchorPoint(ccp(0.5, 1))
    _topNode:setPosition(ccpsprite(0.5, 1, _layer))
    _topNode:setScale(g_fScaleX)
end

--[[
	@desc:		显示底部UI
--]]
function loadBottom()
    _bottomNode = GuildWarPromotionUtil.createBottomNode("GuildWar16Layer", _touchPriority - 240)
    _layer:addChild(_bottomNode)
    _bottomNode:setScale(g_fScaleX)
    _bottomNode:setAnchorPoint(ccp(0.5, 0))
    _bottomNode:setPosition(ccpsprite(0.5, 0, _layer))
end

--[[
    @desc:                  显示中部TableView
    @return:    nil
--]]
function loadTableView()
    _cellSize = CCSizeMake(g_winSize.width, g_winSize.height - _topNode:getContentSize().height * g_fScaleX - _bottomNode:getContentSize().height * g_fScaleX)
	local tableViewEvent = LuaEventHandler:create(function(p_functionName, p_tableView, p_index, p_cell)
		if p_functionName == "cellSize" then
			return _cellSize
		elseif p_functionName == "cellAtIndex" then
            local cell = createCell(p_index)
            return cell
		elseif p_functionName == "numberOfCells" then
            return 4
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
	_tableView:setPosition(ccp(g_winSize.width * 0.5, _cellSize.height * 0.5 + _bottomNode:getContentSize().height * g_fScaleX))
    _tableView:setDirection(kCCScrollViewDirectionHorizontal)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setTouchEnabled(false)
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
    local rightArrowAction = createArrowAction()
    _rightArrow:runAction(rightArrowAction)
end

--[[
    @desc:                  刷新箭头（是否显示）
    @return:    nil
--]]
function refreshArrow( ... )
	if _leftArrow == nil then
        return
    end
    local offset = _tableView:getContentOffset()
    if offset.x <= -_cellSize.width then
        _leftArrow:setVisible(true)
        if offset.x <= -_cellSize.width * 3 then
            _rightArrow:setVisible(false)
        else
            _rightArrow:setVisible(true)
        end
    else
        _leftArrow:setVisible(false)
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
    local nodeMenu = BTSensitiveMenu:create()
    node:addChild(nodeMenu, 3)
    nodeMenu:setPosition(ccp(0, 0))
    nodeMenu:setContentSize(node:getContentSize())
    nodeMenu:setTouchPriority(_touchPriority - 1)
            
    local groupImages = {"a.png", "b.png", "c.png", "d.png"}
    local group = CCSprite:create(string.format("images/lord_war/%s", groupImages[p_index + 1]))
    cell:addChild(group)
    group:setAnchorPoint(ccp(0.5, 1))
    group:setPosition(ccp(_cellSize.width * 0.5, _cellSize.height))
    group:setScale(MainScene.elementScale)
    for rank, positionData in pairs(_cellPositionData) do
    	-- 显示军团
        if positionData.guildPositions ~= nil then
            for i = 1, #positionData.guildPositions do
                local guildPosition = positionData.guildPositions[i]
                local index = #positionData.guildPositions * p_index + i
                GuildWarPromotionUtil.loadGuildIcon(node, guildPosition, rank, index, "GuildWar16Layer")
            end
        end
        -- 显示晋级线
        if positionData.lineDatas ~= nil then
            for i = 1, #positionData.lineDatas do
                local lineData = positionData.lineDatas[i]
                local index = #positionData.lineDatas * p_index + i
                GuildWarPromotionUtil.loadLine(node, lineData, rank, index)
            end 
        end
        -- 显示两条晋级线对应的按钮（助威，查看战报）
        if positionData.btnPositions ~= nil then
            for i = 1, #positionData.btnPositions do
                local btnPosition = positionData.btnPositions[i]
                local btnIndex = i + p_index * #positionData.btnPositions
                GuildWarPromotionUtil.loadBtn(nodeMenu, btnPosition, rank, btnIndex)
            end
        end
    end
    return cell
end

-- 记录进入该界面时主界面菜单，玩家信息面板和跑马灯公告的显示状态
function recordMainSceneViewsVisibleInfo( ... )
	_isMenuVisible = MainScene.isMenuVisible()
	_isAvatarVisible = MainScene.isAvatarVisible()
	_isBulletinVisible = MainScene.isBulletinVisible()
end

function onTouchesHandler(p_event, p_x, p_y)
	local position = ccp(p_x, p_y)
    if p_event == "began" then
        local rect = _tableView:boundingBox()
        if rect:containsPoint(position) then
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
                _pageIndex = _pageIndex > 4 and 4 or _pageIndex
            end
            local container = _tableView:getContainer()
            local offset = ccp(-(_pageIndex - 1) * _cellSize.width, 0)
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

function onNodeEvent(p_event)
    if (p_event == "enter") then
        _layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority - 2, false)
        _layer:setTouchEnabled(true)
        recordMainSceneViewsVisibleInfo()
        MainScene.setMainSceneViewsVisible(false, false, false)
        GuildWarStageEvent.registerListener(refresh)
    elseif (p_event == "exit") then
    	MainScene.setMainSceneViewsVisible(_isMenuVisible, _isAvatarVisible, _isBulletinVisible)
		_layer:unregisterScriptTouchHandler()
        _layer = nil
        GuildWarStageEvent.removeListener(refresh)
        _title = nil
	end
end

function refresh(p_round, p_status, p_subRound, p_subStatus)
    print("16Layer========", p_round, p_status, p_subRound, p_subStatus)
    if p_round == GuildWarDef.ADVANCED_8 and p_status == GuildWarDef.END then
        GuildWar4Layer.show(_touchPriority, _zOrder, true)
        return
    end
    if p_status == GuildWarDef.FIGHTEND then
        local requestCallback = function ( ... )
            refreshTableView()
        end
        GuildWarPromotionService.getGuildWarInfo(requestCallback)
    end
end

--[[
    @desc:                              刷新当前界面
    @return:    nil
--]]
function refreshTableView()
    if _layer == nil then
        return
    end
    local contentOffset = _tableView:getContentOffset()
    _tableView:reloadData()
    _tableView:setContentOffset(contentOffset)
end

--[[
    @desc:                  得到本层触摸优先级
    @return:    number
--]]
function getTouchPriority( ... )
    return _touchPriority or -180
end

--[[
    @desc:                  得到本层z轴
    @return:    number      
--]]
function getZOrder( ... )
    return _zOrder or 1
end

--[[
    @desc:                  得到上一个界面的名称
    @return:    string
--]]
function getLastLayerName( ... )
    return _lastLayerName
end