-- Filename：    ComprehendPreviewDialog.lua
-- Author：      lgx
-- Date：        2016-04-13
-- Purpose：     武将领悟预览界面

module("ComprehendPreviewDialog", package.seeall)

require "db/DB_Normal_config"

local _touchPriority 	= nil
local _zOrder 		 	= nil
local _bgLayer 		 	= nil
local _leftArrowSp 		= nil
local _rightArrowSp 	= nil
-- 记录总共页数
local _totalPage 		= 0

--[[
	@desc:	初始化方法
--]]
local function init()
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
	_leftArrowSp	 = nil
	_rightArrowSp 	 = nil
	_totalPage 		 = 0
end

--[[
	@desc:	显示界面方法
	@param: pIndex 觉醒能力索引
	@param:	pTouchPriority 触摸优先级
	@param:	pZorder 显示层级
--]]
function showLayer( pIndex, pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -666
	_zOrder = pZorder or 1000
	local scene = CCDirector:sharedDirector():getRunningScene()
    local layer = createLayer(pIndex,_touchPriority, _zOrder)
    scene:addChild(layer,_zOrder)
end

--[[
	@desc:	背景层触摸回调
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc: 回调onEnter和onExit事件
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
	end
end

--[[
	@desc:	创建背景Layer
	@param: pIndex 觉醒能力索引
	@param:	pTouchPriority 触摸优先级
	@param:	pZorder 显示层级
--]]
function createLayer( pIndex, pTouchPriority, pZorder )
	-- 初始化
	init()

	_touchPriority = pTouchPriority or -666
	_zOrder = pZorder or 1000

	_bgLayer = CCLayerColor:create(ccc4(8,8,8,225))
    _bgLayer:registerScriptHandler(onNodeEvent)

    -- 创建UI
    createMainUI(pIndex)

    return _bgLayer
end

--[[
	@desc:		创建箭头闪烁动画
	@param: 	pArrow 箭头精灵
--]]
local function runArrowAction( pArrow )
	local actionArrs = CCArray:create()
	actionArrs:addObject(CCFadeOut:create(1))
	actionArrs:addObject(CCFadeIn:create(1))
	local sequenceAction = CCSequence:create(actionArrs)
	local foreverAction = CCRepeatForever:create(sequenceAction)
	pArrow:runAction(foreverAction)
end

--[[
	@desc:		更新箭头显示状态
	@param: 	pIndex 当前觉醒能力索引
--]]
local function updateArrowShowSttus( pIndex )
	-- 根据当前的显示的页数,更新箭头显示
	if (pIndex == 1) then 
		_leftArrowSp:setVisible(false)
		_rightArrowSp:setVisible(true)
	elseif (pIndex == _totalPage) then 
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(false)
	else
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(true)
	end
end

--[[
	@desc:	创建主UI界面
	@param: pIndex 觉醒能力索引
--]]
function createMainUI( pIndex )
	-- 返回按钮菜单
    local backMenu = CCMenu:create()
    backMenu:setAnchorPoint(ccp(0,0))
    backMenu:setPosition(ccp(0,0))
    backMenu:setTouchPriority(_touchPriority-2)
    _bgLayer:addChild(backMenu)

    -- 创建返回按钮
	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	backItem:setAnchorPoint(ccp(1, 1))
	backItem:setPosition(ccp( _bgLayer:getContentSize().width-15*g_fElementScaleRatio,_bgLayer:getContentSize().height-15*g_fElementScaleRatio ))
	backMenu:addChild(backItem)
	backItem:registerScriptTapHandler(backItemCallback)
	backItem:setScale(g_fElementScaleRatio)

	-- 标题
	local titleSprite = CCSprite:create("images/biography/preview_title.png")
    titleSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-60*g_fElementScaleRatio))
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(titleSprite)

	-- 读取DB中配置数据
	require "script/utils/LuaUtil"
	local normalConfigDb = DB_Normal_config.getDataById(1)
	local awakeShowTab = parseField(normalConfigDb.awake_show)
	_totalPage = table.count(awakeShowTab)

	-- 左箭头
    _leftArrowSp = CCSprite:create( "images/common/left_big.png")
    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
    _leftArrowSp:setPosition(0,_bgLayer:getContentSize().height*0.5)
    _bgLayer:addChild(_leftArrowSp,1)
    _leftArrowSp:setVisible(false)
    _leftArrowSp:setScale(g_fElementScaleRatio)
    runArrowAction(_leftArrowSp)

    -- 右箭头
    _rightArrowSp = CCSprite:create( "images/common/right_big.png")
    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
    _rightArrowSp:setPosition(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height*0.5)
    _bgLayer:addChild(_rightArrowSp,1)
    _rightArrowSp:setVisible(true)
    _rightArrowSp:setScale(g_fElementScaleRatio)
    runArrowAction(_rightArrowSp)

    -- 更新箭头状态
    updateArrowShowSttus(pIndex)

    -- 创建觉醒信息列表
    local pretabViewSize = CCSizeMake(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height-100*g_fElementScaleRatio)
    local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return pretabViewSize
		elseif functionName == "cellAtIndex" then
			return createEachPageCell(index,awakeShowTab[index])
		elseif functionName == "numberOfCells" then
			return _totalPage
		elseif functionName == "cellTouched" then
			
		elseif functionName == "scroll" then
			
		elseif functionName == "moveEnd" then
			-- 更新箭头
    		updateArrowShowSttus(index)
		end
	end
	-- 觉醒信息tabView
    local preTabView = STTableView:create()
    preTabView:setDirection(kCCScrollViewDirectionHorizontal)
    preTabView:setContentSize(pretabViewSize)
	preTabView:setEventHandler(eventHandler)
	preTabView:setPageViewEnabled(true)
	preTabView:setTouchPriority(_touchPriority - 10)
	_bgLayer:addChild(preTabView)
	preTabView:reloadData()

	-- 设置显示当前页
	preTabView:showCellByIndex(pIndex)

end

--[[
	@desc:		创建每一页Cell
	@param: 	pIndex 觉醒能力索引
	@param:		pAwakeData 觉醒能力预览信息
	@return: 	STTableViewCell
--]]
function createEachPageCell( pIndex, pAwakeData )
	local cell = STTableViewCell:create()

	local titleArrs = {"key_8080", "key_8081", "lcy_1004"}

	-- 背景
	local bgSprite = CCScale9Sprite:create(CCRectMake(52, 10, 3, 5),"images/biography/preview_bg.png")
	bgSprite:setContentSize(CCSizeMake(540, 180*3+100))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	cell:addChild(bgSprite)
	bgSprite:setScale(g_fElementScaleRatio)

	-- 标题背景
	local titleSp = CCScale9Sprite:create(CCRectMake(250,75,10,8),"images/biography/preview_title_bg.png")
	titleSp:setContentSize(CCSizeMake(530, 180*3+148))
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.5+23))
	bgSprite:addChild(titleSp)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy(titleArrs[pIndex]) ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleLabel:setColor(ccc3(0xff,0xf6,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height-26))
	titleSp:addChild(titleLabel)

	-- 可觉醒能力
 	for i=0,#pAwakeData-1 do
 		local awakeName = pAwakeData[i+1]
 		local row = math.floor(i/4)+1
 		local col = i%4+1
 		local awakeNameLabel = CCRenderLabel:create(awakeName,g_sFontName,20,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		awakeNameLabel:setColor(ccc3(0xff,0xff,0xff))
		awakeNameLabel:setAnchorPoint(ccp(0,1))
		awakeNameLabel:setPosition(ccp(48+125*(col-1), bgSprite:getContentSize().height-35-40*(row-1)))
		bgSprite:addChild(awakeNameLabel)
 	end

	return cell
end

--[[
	@desc:	返回按钮回调,关闭界面
--]]
function backItemCallback()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if not tolua.isnull(_bgLayer) then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end
