-- FileName: HeroTurnedLayer.lua
-- Author: lgx
-- Date: 2016-09-13
-- Purpose: 武将幻化系统主界面

module("HeroTurnedLayer", package.seeall)

require "script/ui/turnedSys/HeroTurnedController"
require "script/ui/turnedSys/HeroTurnedData"
require "script/ui/turnedSys/HeroTurnedCell"
require "script/model/utils/HeroUtil"

local kTagScheduler 		= 999 -- 刷新计时器的tag

-- UI控件引用变量 --
local _bgLayer				= nil -- 背景层
local _turnTableView 		= nil -- 幻化TableView
local _bottomBg 			= nil -- 底部按钮背景
local _leftArrowSp			= nil -- 左箭头
local _rightArrowSp 		= nil -- 右箭头

-- 模块局部变量 --
local _curHid 				= nil 	-- 武将hid
local _enterSign 			= nil 	-- 进入标志
local _touchPriority		= nil 	-- 触摸优先级
local _zOrder				= nil 	-- 显示层级
local _layerSize			= nil 	-- 背景层大小
local _viewHeight 			= nil 	-- tableView高度
local _cellSize 			= nil 	-- 武将cell大小
local _hScale 				= nil 	-- tableView缩放比
local _turnedNum 			= nil  	-- 幻化形象总数
local _curIndex 			= nil  	-- 当前居中index
local _tableViewIsMoving  	= false	-- 是否在滑动
local _isHandleTouch 		= false -- 是否触摸
local _dragBeganX 			= nil 	-- 开始拖拽X坐标
local _touchBeganX 			= nil 	-- 开始点击X坐标
local _refreshScheduler 	= nil 	-- 刷新计时器

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_bgLayer 			= nil
	_turnTableView 		= nil
	_bottomBg 			= nil
	_leftArrowSp 		= nil
	_rightArrowSp 		= nil
	_curHid 			= nil
	_enterSign 			= nil
	_touchPriority 		= nil
	_zOrder 			= nil
	_layerSize 			= nil
	_cellSize 			= nil
	_hScale 			= nil
	_turnedNum 			= nil
	_curIndex 			= nil
	_tableViewIsMoving 	= false
	_isHandleTouch 		= false
	_dragBeganX 		= nil
	_touchBeganX 		= nil
	_refreshScheduler 	= nil
end

--[[
	@desc	: 背景层触摸回调
    @param	: eventType 事件类型 x,y 触摸点
    @return	: 
—-]]
local function layerToucCallback( eventType, x, y )
	-- print("------ layerToucCallback ------")
	if _tableViewIsMoving == true then
		_isHandleTouch = false
		return true
	end
	local position = _turnTableView:convertToNodeSpace(ccp(x, y))

    if eventType == "began" then
        local rect = _turnTableView:boundingBox()
        if rect:containsPoint(_turnTableView:getParent():convertToNodeSpace(ccp(x, y))) then
            _dragBeganX = _turnTableView:getContentOffset().x
            _touchBeganX = position.x
            -- 开启计时器
            startScheduler()
            _isHandleTouch = true
        else
            _isHandleTouch = false
        end
        
        return true
    elseif eventType == "moved" then
        if _isHandleTouch == true then
            local distance = position.x - _touchBeganX
            local offsetDistance = _turnTableView:getContentOffset().x - _dragBeganX
       		if offsetDistance > 0 and offsetDistance > _cellSize.width then
       			return
       		elseif offsetDistance < 0 and offsetDistance < -_cellSize.width then
       			return
       		end
       		local offset = _turnTableView:getContentOffset()
       		offset.x = _dragBeganX + distance
       		local minX = -(_turnedNum - 1) * _cellSize.width
            if offset.x < minX then
                offset.x = minX
            elseif offset.x > 0 then
            	offset.x = 0
            end
            _turnTableView:setContentOffset(offset)
        end
    elseif eventType == "ended" or eventType == "cancelled" then
        if _isHandleTouch == true then
            local dragEndedX = _turnTableView:getContentOffset().x
            local touchEndPosition = _turnTableView:getParent():convertToNodeSpace(ccp(x, y))
            local dragDistance = touchEndPosition.x - _touchBeganX
            local offset = _turnTableView:getContentOffset()
            offset.x = -(_curIndex - 1) * _cellSize.width
            _tableViewIsMoving = true
            local array = CCArray:create()
            array:addObject(CCMoveTo:create(0.15, offset))
            local container = _turnTableView:getContainer()
            local endCallback = function()
            	_turnTableView:setContentOffset(offset)

            	refreshTurnCell()
            	-- 结束计时器
            	stopScheduler()
                _tableViewIsMoving = false
            end
            array:addObject(CCCallFunc:create(endCallback))
            container:runAction(CCSequence:create(array))
            -- print("cellCount =>", container:getChildren():count())
        end
    end
end

--[[
	@desc	: 回调onEnter和onExit事件
    @param	: event 事件名
    @return	: 
—-]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,false)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc 	: 显示界面方法
	@param 	: pHid 武将hid
	@param 	: pEnterSign 进入标志(区分从阵容还是武将背包进入)
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pHid, pEnterSign, pTouchPriority, pZorder )

	-- 判断功能节点是否开启
    if (not DataCache.getSwitchNodeState(ksSwitchHeroTurned)) then
        return
    end

	-- 判断功能是否开启
	if ( HeroTurnedData.isCanTurned(pHid) ==  false ) then
		return
	end

	-- changeLayer 进入
	MainScene.setMainSceneViewsVisible(true,false,false)
	local layer = createLayer(pHid, pEnterSign, pTouchPriority, pZorder)
	MainScene.changeLayer(layer, "HeroTurnedLayer")
end

--[[
	@desc 	: 创建Layer及UI
	@param 	: pHid 武将hid
	@param 	: pEnterSign 进入标志
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : CCLayer 背景层
--]]
function createLayer( pHid, pEnterSign, pTouchPriority, pZorder )
	-- 初始化
	init()

	_curHid = pHid
	_enterSign = pEnterSign or "HeroLayer"
	_touchPriority = pTouchPriority or -500
	_zOrder = pZorder or 500

	local menuLayerSize = MenuLayer.getLayerContentSize()

	_layerSize = CCSizeMake(g_winSize.width, g_winSize.height - (menuLayerSize.height)*g_fScaleX)

	-- 背景层
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setContentSize(_layerSize)
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
	
	-- 背景图
	local bgSprite = CCSprite:create("images/fashion/fashion_bg.jpg")
	bgSprite:setScale(g_fBgScaleRatio)
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccp(_layerSize.width/2,_layerSize.height*0.58))
	_bgLayer:addChild(bgSprite)

	-- 顶部背景
	local topSprite = CCSprite:create("images/turnedSys/top_bg.png")
    topSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height))
    topSprite:setAnchorPoint(ccp(0.5,1))
    topSprite:setScale(g_fScaleX)
    _bgLayer:addChild(topSprite)

	-- 标题
	local titleSprite = CCSprite:create("images/turnedSys/turned_title.png")
    titleSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-titleSprite:getContentSize().height/2-30*g_fElementScaleRatio))
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(titleSprite)

	-- 按钮菜单
	local backMenu = CCMenu:create()
    backMenu:setPosition(ccp(0, 0))
    backMenu:setTouchPriority(_touchPriority-30)
    _bgLayer:addChild(backMenu, 10)

	-- 返回按钮
	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    backItem:setScale(g_fElementScaleRatio)
    backItem:setAnchorPoint(ccp(1,0.5))
    backItem:setPosition(ccp(_bgLayer:getContentSize().width-20,_bgLayer:getContentSize().height-60*g_fElementScaleRatio))
    backItem:registerScriptTapHandler(backItemCallback)
    backMenu:addChild(backItem,1)

	-- 图鉴按钮
	local illustrateItem = CCMenuItemImage:create("images/turnedSys/btn_turn_illustrate_n.png","images/turnedSys/btn_turn_illustrate_h.png")
    illustrateItem:setScale(g_fElementScaleRatio)
    illustrateItem:setAnchorPoint(ccp(0,0.5))
    illustrateItem:setPosition(ccp(20,_bgLayer:getContentSize().height-60*g_fElementScaleRatio))
    illustrateItem:registerScriptTapHandler(illustrateItemCallback)
    backMenu:addChild(illustrateItem,1)

	-- 创建底部按钮等
	createBottomUI()

	-- 拉取武将可幻化的id
	HeroTurnedController.getTurnInfoByHid(function()
		-- 创建武将可幻化列表
		createTurnTableView()
	end, _curHid)
	
	return _bgLayer
end

--[[
	@desc	: 创建武将可幻化列表
    @param	: 
    @return	: 
—-]]
function createTurnTableView()
	-- 左箭头 
	_leftArrowSp = CCSprite:create("images/common/left_big.png")
    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
    _leftArrowSp:setPosition(0,_bgLayer:getContentSize().height*0.4)
    _bgLayer:addChild(_leftArrowSp,5)
    _leftArrowSp:setVisible(false)
    _leftArrowSp:setScale(g_fElementScaleRatio)
    HeroTurnedUtil.runArrowAction(_leftArrowSp)

	-- 右箭头 
    _rightArrowSp = CCSprite:create("images/common/right_big.png")
    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
    _rightArrowSp:setPosition(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height*0.4)
    _bgLayer:addChild(_rightArrowSp,5)
    _rightArrowSp:setVisible(true)
    _rightArrowSp:setScale(g_fElementScaleRatio)
    HeroTurnedUtil.runArrowAction(_rightArrowSp)

	_viewHeight = _bgLayer:getContentSize().height - 150*g_fElementScaleRatio
	print("_viewHeight =>",_viewHeight)

	_cellSize = CCSizeMake(math.ceil(_bgLayer:getContentSize().width / 3), _viewHeight)
	_hScale = _viewHeight/_bgLayer:getContentSize().height
	_turnedNum = table.count(HeroTurnedData.getAllTurnedIdsByHid(_curHid))
	local cellCount = _turnedNum + 2

	local curHero = HeroUtil.getHeroInfoByHid(_curHid)

    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if fn == "cellSize" then
            r = _cellSize
        elseif fn == "cellAtIndex" then
            r = HeroTurnedCell.createCell(a1,curHero,_cellSize,_turnedNum+1,_hScale)
        elseif fn == "numberOfCells" then
            r = cellCount
        elseif fn == "cellTouched" then
        elseif fn == "scroll" then
        else
        end
        return r
    end)

    _turnTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_bgLayer:getContentSize().width, _viewHeight))
    _bgLayer:addChild(_turnTableView)
    _turnTableView:setAnchorPoint(ccp(0.5, 0.5))
    _turnTableView:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * 0.55))
    _turnTableView:ignoreAnchorPointForPosition(false)
    _turnTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _turnTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _turnTableView:setTouchPriority(_touchPriority - 10)
    _turnTableView:setTouchEnabled(false)

    refreshAllUI()
end

--[[
	@desc	: 更新箭头显示状态
	@param	: pIndex 当前位置
	@return	:
--]]
function updateArrowShowSttus( pIndex )
	-- 根据当前的显示的位置,更新箭头显示
	if (pIndex == 1) then 
		_leftArrowSp:setVisible(false)
		_rightArrowSp:setVisible(true)
	elseif (pIndex == _turnedNum) then 
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(false)
	else
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(true)
	end
end

--[[
	@desc	: 刷新所有UI
    @param	: 
    @return	: 
—-]]
function refreshAllUI()
	_curIndex = HeroTurnedData.getCurIndexByHid(_curHid) or 1
    local offset = _turnTableView:getContentOffset()
    print("_curIndex =>",_curIndex," offset.x =>",offset.x)
    if _curIndex > 0 or _curIndex < _turnedNum then
    	offset.x = -(_curIndex-1) * _cellSize.width
    	print("_curIndex =>",_curIndex," offset.x =>",offset.x)
    	_turnTableView:setContentOffset(offset)
	end

	-- 刷新幻化列表Cell
    refreshTurnCell()

    -- 刷新底部UI 幻化按钮等
	refreshBottomUI()

	-- 刷新箭头显示
	updateArrowShowSttus(_curIndex)
end

--[[
	@desc	: 刷新幻化列表Cell
    @param	: 
    @return	: 
—-]]
function refreshTurnCell()
	if _turnTableView ~= nil and _turnTableView:getContainer():getChildren():count() > 0  then
		local container = _turnTableView:getContainer()
		local cells = container:getChildren()
		local mainIndex = 0
		local maxScale = 0
		for i = 0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = cell:getChildByTag(TurnedDef.kTagTurnSprite)
			if hero ~= nil then
				local position = cell:convertToWorldSpace(ccp(hero:getPositionX(), hero:getPositionY()))
				local scale = 1 - (math.abs(_bgLayer:getContentSize().width * 0.5 - position.x) / _bgLayer:getContentSize().width)*1.5
				hero:setScale(_hScale * scale *MainScene.elementScale * 1.2)
				hero:setPositionY(math.abs(_bgLayer:getContentSize().width * 0.5 - position.x) / _bgLayer:getContentSize().width * 0.5 * _viewHeight*g_fScaleX / (_hScale*MainScene.elementScale * 1.2) * 1.1)
				if scale > maxScale then
					mainIndex = cell:getIdx()
					maxScale = scale
				end
				container:reorderChild(cell, hero:getScale() * 10)
			end
		end
		for i=0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = tolua.cast(cell:getChildByTag(TurnedDef.kTagTurnSprite), "CCSprite")
			if ( hero ~= nil ) then
				local nameBg = tolua.cast(hero:getChildByTag(TurnedDef.kTagTurnName), "CCScale9Sprite")
				if cell:getIdx() ~= mainIndex then
					hero:setColor(ccc3(0xaa, 0xaa, 0xaa))
					if ( nameBg ~= nil ) then
						nameBg:setVisible(true)
					end
				else
					hero:setColor(ccc3(0xff, 0xff, 0xff))
					if ( nameBg ~= nil ) then
						nameBg:setVisible(false)
					end
				end
			end
		end
		if _curIndex ~= mainIndex and mainIndex ~= 0 and mainIndex ~= _turnedNum + 1 then
    		_curIndex = mainIndex
    		-- 刷新底部显示
    		refreshBottomUI()
    		-- 刷新箭头显示
			updateArrowShowSttus(_curIndex)
		end
	end
end

--[[
	@desc	: 启动刷新定时器
    @param	: 
    @return	: 
—-]]
function startScheduler()
	if (_refreshScheduler == nil) then
		_refreshScheduler = schedule(_bgLayer,refreshTurnCell,1/60)
    	_refreshScheduler:setTag(kTagScheduler)
    end
end

--[[
	@desc	: 停止刷新定时器
    @param	: 
    @return	: 
—-]]
function stopScheduler()
	if (_refreshScheduler ~= nil) then
		if (not tolua.isnull(_bgLayer)) then
			_bgLayer:stopActionByTag(kTagScheduler)
		end
		_refreshScheduler = nil
	end
end

--[[
	@desc	: 创建底部UI
    @param	: 
    @return	: 
—-]]
function createBottomUI()
	-- 底部背景
	_bottomBg = CCSprite:create()
    _bottomBg:setContentSize(CCSizeMake(634,200))
	_bottomBg:setAnchorPoint(ccp(0.5,1))
	_bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_layerSize.height * 0.23))
	_bgLayer:addChild(_bottomBg,10)
	_bottomBg:setScale(g_fElementScaleRatio)
end

--[[
	@desc	: 刷新底部UI
    @param	: 
    @return	: 
—-]]
function refreshBottomUI()
	if ( _bottomBg == nil ) then 
		return
	end

	if _curIndex == 0 or _curIndex == _turnedNum + 1 then
		return
	end

	-- 移除原有的
	_bottomBg:removeAllChildrenWithCleanup(true)

	local turnId = HeroTurnedData.getTurnIdByHidAndIndex(_curHid,_curIndex)
	local curTurnId = HeroTurnedData.getCurTurnedIdByHid(_curHid)
	local isUnLock = HeroTurnedData.isUnLockedTurnId(turnId)
	-- 默认形象
	if (_curIndex == 1) then
		isUnLock = true
	end
	print("hid =>",_curHid,"pIndex =>",_curIndex,"turnId =>",turnId,"curTurnId =>",curTurnId)

	-- 按钮状态
	if ( curTurnId == 0 and _curIndex == 1 ) then
		print("默认 当前形象")
		-- 默认 当前形象
		local curDress = CCSprite:create("images/dress_room/cur_tag.png")
		_bottomBg:addChild(curDress)
		curDress:setAnchorPoint(ccp(0.5, 0.5))
		curDress:setPosition(ccp(_bottomBg:getContentSize().width*0.5, _bottomBg:getContentSize().height*0.3))
	elseif ( curTurnId == turnId ) then
		print("当前形象")
		-- 当前形象
		local curDress = CCSprite:create("images/dress_room/cur_tag.png")
		_bottomBg:addChild(curDress)
		curDress:setAnchorPoint(ccp(0.5, 0.5))
		curDress:setPosition(ccp(_bottomBg:getContentSize().width*0.5, _bottomBg:getContentSize().height*0.3))
	elseif ( (isUnLock and curTurnId ~= turnId) or (curTurnId ~= 0 and _curIndex == 1) ) then
		print("可幻化")
		-- 可幻化
		-- 底部按钮
		local bottoMenu = CCMenu:create()
		bottoMenu:setPosition(ccp(0, 0))
		_bottomBg:addChild(bottoMenu)
		bottoMenu:setTouchPriority(_touchPriority-4)

		-- 幻化按钮
		local turnedItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("lgx_1110"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		turnedItem:setAnchorPoint(ccp(0.5, 0.5))
		bottoMenu:addChild(turnedItem)
		turnedItem:registerScriptTapHandler(turnedItemCallback)
		turnedItem:setPosition(ccp(_bottomBg:getContentSize().width*0.5, _bottomBg:getContentSize().height*0.3))
	else
		-- 其他 未解锁
	end

	-- 形象名称
	local nameBg = HeroTurnedUtil.createTurnNameSpriteById(turnId,_curIndex,isUnLock)
	nameBg:setAnchorPoint(ccp(0.5,1))
	nameBg:setPosition(ccp(_bottomBg:getContentSize().width*0.5, _bottomBg:getContentSize().height))
	_bottomBg:addChild(nameBg,1)

	-- 提示文字
	local noteStr = HeroTurnedData.getTurnUnlockNoteStr(turnId,isUnLock,curTurnId,_curIndex)
	local noteLabel = CCRenderLabel:create(noteStr, g_sFontName, 23,1, ccc3(0x00,0x00,0x00),type_stroke)
    noteLabel:setColor(ccc3(0xff,0xff,0xff))
    noteLabel:setPosition(_bottomBg:getContentSize().width*0.5, _bottomBg:getContentSize().height-50)
    noteLabel:setAnchorPoint(ccp(0.5,1))
    _bottomBg:addChild(noteLabel)

end

--[[
	@desc	: 幻化成功后，当前cell播放scale动画
    @param	: 
    @return	: 
—-]]
function playCellScaleAnimation()
	if ( _turnTableView ~= nil and _turnTableView:getContainer():getChildren():count() > 0 ) then
		local container = _turnTableView:getContainer()
		local cells = container:getChildren()
		local cellCount = cells:count() - 1
		for i = 0, cellCount do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = tolua.cast(cell:getChildByTag(TurnedDef.kTagTurnSprite), "CCSprite")
			if ( hero ~= nil ) then
				if ( cell:getIdx() == _curIndex ) then
					local curScale = hero:getScale()
				 	hero:setScale(0)
				 	local array = CCArray:create()
				    local scale1 = CCScaleTo:create(0.15,1.2*curScale)
				    local fade = CCFadeIn:create(0.15)
				    local spawn = CCSpawn:createWithTwoActions(scale1,fade)
				    local scale2 = CCScaleTo:create(0.1,1*curScale)
				    local scale3 = CCScaleTo:create(0.1,1.15*curScale)
				    local scale4 = CCScaleTo:create(0.1,1*curScale)
				    local endFunc = CCCallFunc:create(function()
				    	hero:setScale(curScale)
				    end)
				    array:addObject(spawn)
				    array:addObject(scale2)
				    array:addObject(scale3)
				    array:addObject(scale4)
				    array:addObject(endFunc)
				    local seq = CCSequence:create(array)
				    hero:runAction(seq)
				end
			end
		end
	end
end

--[[
	@desc	: 幻化按钮回调
    @param	: 
    @return	: 
—-]]
function turnedItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 幻化成功回调
	local turnCallback = function()
		-- 播放幻化成功音效
    	AudioUtil.playEffect("audio/effect/jinbizhaojiangbao.mp3")

    	-- 放大动画
        -- playCellScaleAnimation()
    	
    	-- 播放幻化成功特效
	    local turnEffectSprite = XMLSprite:create("images/item/equipFixed/lizibaokai/lizibaokai")
	    turnEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
	    turnEffectSprite:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * 0.5))
	    turnEffectSprite:setScale(g_fElementScaleRatio)
	    _bgLayer:addChild(turnEffectSprite,999)

	    local endCallback = function()
	    	-- 移除特效
			turnEffectSprite:removeFromParentAndCleanup(true)
        	turnEffectSprite = nil
        	
        	-- 提示
        	require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lgx_1123"))
		end
	    turnEffectSprite:registerEndCallback(endCallback)

		-- 刷新UI
		refreshAllUI()
	end
	local turnId = HeroTurnedData.getTurnIdByHidAndIndex(_curHid,_curIndex)
	-- 如果是默认形象，发给后端0 
	if (_curIndex == 1) then
		turnId = 0
	end
	HeroTurnedController.heroTruned(turnCallback,_curHid,turnId)
end

--[[
	@desc	: 图鉴按钮回调，显示幻化图鉴
    @param	: 
    @return	: 
—-]]
function illustrateItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local getInfoCallback = function()
		-- 计算图鉴总数量
		HeroTurnedData.calculateAllTurnNum()
		require "script/ui/turnedSys/TurnedIllustrateLayer"
		TurnedIllustrateLayer.showLayer()
	end
	HeroTurnedController.getAllTurnInfo( getInfoCallback )
end

--[[
	@desc	: 返回按钮回调，切回上个界面
    @param	: 
    @return	: 
—-]]
function backItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
   	if (_enterSign == "FormationLayer") then
        require("script/ui/formation/FormationLayer")
        local formationLayer = FormationLayer.createLayer()
        MainScene.changeLayer(formationLayer, "formationLayer")
    else
        require "script/ui/hero/HeroLayer"
        MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
    end
end