-- Filename: RuneCompoundLayer.lua
-- Author: zhangqiang
-- Date: 2016-07-26
-- Purpose: 符印合成显示

module("RuneCompoundLayer", package.seeall)
require "script/ui/runeCompound/RuneCompoundConst"


kBtnRelativeTouchPriority = -10
kTableViewRelativeTouchPriority = -10
kItemInfoRelativeTouchPriority = -20
kLockRelativeTouchPriority = -100
kShowRewardRelativeTouchPriority = -150

_nBaseZOrder = nil         --黑色半透明屏蔽层的ZOrder
_nBaseTouchPriority = nil  --黑色半透明屏蔽层的触摸优先级
_lyBase = nil              --黑色半透明屏蔽层
_szAdapt = nil             --用于适配的尺寸
_spTableViewBg = nil       --列表背景
_spLeftArrow = nil         --向左的箭头
_spRightArrow = nil        --向右的箭头
_typeMenu = nil            --合成类型菜单
_tvRuneCompound = nil      --合成方案显示列表
_btnCompound = nil         --合成按钮
_spPageIndicator = nil     --页码指示器
_tbPageIndicator = nil     --页码指示器中的每个单元点集合

_lyLock = nil              --屏蔽层，播动画时用于屏蔽部分操作

_lyEffect = nil            --动画层

_nCurMenuItemIdx = nil     --当前合成类型菜单索引
_nCurPageIdx = nil         --当方案页码

_fnOnEnter = nil
_fnOnExit  = nil
_fnTapMenuItemCb = nil
_fnTapCloseCb = nil

--[[
	@desc  : 获取实例
	@param :
	@return: 
--]]
function show( pTouchPriority, pZOrder )
	init()

	_nBaseZOrder        = pZOrder or 999
	_nBaseTouchPriority = pTouchPriority or -999
	_szAdapt = CCSizeMake(g_originalDeviceSize.width, g_winSize.height/g_fScaleX)

	--创建UI
	viewDidLoad()

	--切换到指定页面
	changeMenuAndPage(RuneCompoundConst.MenuItemIdx.kHorseRuneIdx, 1)

	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(_lyBase, _nBaseZOrder)
end

--[[
	@desc  : 切换到指定合成类型和制定页面
	@param : pMenuIdx 菜单索引
	         pPageIdx 页面索引，当值大于当前菜单索引对应数据的最大个数时，会被自动设置成最大个数
	@return: 
--]]
function changeMenuAndPage( pMenuIdx, pPageIdx )
	_nCurMenuItemIdx = pMenuIdx or RuneCompoundConst.MenuItemIdx.kHorseRuneIdx    --设置默认的菜单索引
	_nCurPageIdx = pPageIdx or 1        --设置默认的页码显示

	--刷新界面
	refreshAll()
end

function close( ... )
	if _lyBase ~= nil then
		_lyBase:removeFromParentAndCleanup(true)
		_lyBase = nil
	end
end

--[[
	@desc  : 初始化
	@param :
	@return: 
--]]
function init( ... )
	_nBaseZOrder = nil
	_nBaseTouchPriority = nil
	_lyBase = nil
	_szAdapt = nil
	_spTableViewBg = nil
	_spLeftArrow = nil
	_spRightArrow = nil
	_typeMenu = nil
	_tvRuneCompound = nil
	_btnCompound = nil
	_spPageIndicator = nil
	_tbPageIndicator = nil
	_nCurMenuItemIdx = nil
	_nCurPageIdx = nil

	_lyLock = nil

	_lyEffect = nil

	_fnOnEnter = nil
	_fnOnExit  = nil
	_fnTapMenuItemCb = nil
	_fnTapCloseCb = nil
end

--[[
	@desc  : 初始化UI
	@param :
	@return: 
--]]
function viewDidLoad( ... )
	_lyBase = CCLayerColor:create(ccc4(0,0,0,125))
	_lyBase:setScale(g_fScaleX)
	_lyBase:registerScriptHandler(function ( pEventName )
		onNodeEvent(pEventName)
	end)
	_lyBase:registerScriptTouchHandler(function ( pEventType, pTouchX, pTouchY )
		return true
	end, false, _nBaseTouchPriority, true)
	_lyBase:setTouchEnabled(true)

	_lyEffect = CCLayer:create()
	_lyBase:addChild(_lyEffect, 100)


	-- 背景框
	local bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(636,810))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_szAdapt.width*0.5,_szAdapt.height*0.5))
	_lyBase:addChild(bgSprite)

	-- 标题
	local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height-6.6))
	bgSprite:addChild(titlePanel)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zq_0023"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 返回按钮Menu
	local menu = CCMenu:create()
    menu:setPosition(ccp(0, 0))
    menu:setAnchorPoint(ccp(0,0))
    menu:setTouchPriority(_nBaseTouchPriority+kBtnRelativeTouchPriority)
    bgSprite:addChild(menu, 10)

    -- 返回按钮
    local backItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
    backItem:setAnchorPoint(ccp(0.5,0.5))
    backItem:setPosition(ccp(bgSprite:getContentSize().width*0.955, bgSprite:getContentSize().height*0.975))
    backItem:registerScriptTapHandler(tapCloseCb)
    menu:addChild(backItem,1)

    -- 列表背景
	-- _spTableViewBg = BaseUI.createContentBg(CCSizeMake(580,580))
	-- _spTableViewBg = CCSprite:create("images/athena/compose_bg.png")
	-- _spTableViewBg = CCSprite:create("images/runecompound/page_bg.png")
	_spTableViewBg = CCScale9Sprite:create(CCRectMake(84, 169, 300, 301),"images/runecompound/page_bg.png")
	_spTableViewBg:setContentSize(CCSizeMake(568, 589))
 	_spTableViewBg:setAnchorPoint(ccp(0.5,1))
 	_spTableViewBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-110))
 	bgSprite:addChild(_spTableViewBg)

 	_btnCompound = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("zq_0024"),ccc3(0xfe, 0xdb, 0x1c),36,g_sFontPangWa,2, ccc3(0x00, 0x00, 0x00))
	_btnCompound:setAnchorPoint(ccp(0.5,0))
	_btnCompound:setPosition(bgSprite:getContentSize().width*0.5, 32)
	_btnCompound:registerScriptTapHandler(tapCompoundCb)
	menu:addChild(_btnCompound)

 	-- -- 创建列表
 	-- createTableView()

 	-- 标签菜单
    createTopMenu(bgSprite)

    -- 创建pageView
    createPageView()

end

--[[
	@desc  : 创建符印合成类型标签
	@param : pMenuBg 菜单父类
	@return: 
--]]
function createTopMenu( pMenuBg )
	-- 创建称号类型标签
	local argsTable = {}
	require "script/libs/LuaCCMenuItem"
	local image_n = "images/common/bg/button/ng_tab_n.png"
    local image_h = "images/common/bg/button/ng_tab_h.png"
    local rect_full_n   = CCRectMake(0,0,63,43)
    local rect_inset_n  = CCRectMake(25,20,13,3)
    local rect_full_h   = CCRectMake(0,0,73,53)
    local rect_inset_h  = CCRectMake(35,25,3,3)
    local btn_size_n    = CCSizeMake(225, 60)
    local btn_size_n2   = CCSizeMake(157, 60) --CCSizeMake(270, 60)
    local btn_size_h    = CCSizeMake(230, 65)
    local btn_size_h2   = CCSizeMake(162, 65) --CCSizeMake(275, 65)
    
    local text_color_n  = ccc3(0xf4, 0xdf, 0xcb)
    local text_color_h  = ccc3(0xff, 0xff, 0xff)
    local font          = g_sFontPangWa
    local font_size_n   = 25
    local font_size_h   = 25
    local strokeCor_n   = ccc3(0x00, 0x00, 0x00)
    local strokeCor_h   = ccc3(0x00, 0x00, 0x00)
    local stroke_size_n = 0
    local stroke_size_h = 1

    local radio_data = {}
    radio_data.touch_priority = _nBaseTouchPriority + kBtnRelativeTouchPriority
    radio_data.space = 3
    radio_data.callback = RuneCompoundLayer.tapMenuItemCb
    radio_data.direction = 1
    radio_data.defaultIndex = _nCurMenuItemIdx or RuneCompoundConst.MenuItemIdx.kHorseRuneIdx
    radio_data.items = {}

	-- 1战马印
    local illustrateButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("zq_0021"), text_color_n, text_color_h, text_color_h, font, font_size_n, 
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    -- 2兵书印
    local suitButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("zq_0022"), text_color_n, text_color_h, text_color_h, font, font_size_n, 
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    table.insert(radio_data.items,illustrateButton)
    table.insert(radio_data.items,suitButton)

    _typeMenu = LuaCCSprite.createRadioMenuWithItems(radio_data)
    _typeMenu:setAnchorPoint(ccp(0,0))
    _typeMenu:setPosition(ccp(45,pMenuBg:getContentSize().height-110))
    pMenuBg:addChild(_typeMenu)
end

--[[
	@desc  : 设置当前菜单索引
	@param : 
	@return: 
--]]
function setCurMenuItemIdx( pIdx )
	_nCurMenuItemIdx = pIdx
end

--[[
	@desc  : 获取当前菜单索引
	@param : 
	@return: 
--]]
function getCurMenuItemIdx( ... )
	return _nCurMenuItemIdx
end

--[[
	@desc  : 获取当页码
	@param : 
	@return: 
--]]
function getCurPageIdx( ... )
	return _nCurPageIdx
end

--[[
	@desc  : 创建称号类型标签
	@param : 
	@return: 
--]]
function createPageView( ... )
	-- 左箭头 
	_spLeftArrow = CCSprite:create("images/formation/btn_left.png")
    _spLeftArrow:setAnchorPoint(ccp(0,0.5))
    _spLeftArrow:setPosition(0,_spTableViewBg:getContentSize().height*0.5)
    _spTableViewBg:addChild(_spLeftArrow,10)
    _spLeftArrow:setVisible(false)
    ChariotUtil.runArrowAction(_spLeftArrow)

	-- 右箭头 
    _spRightArrow = CCSprite:create("images/formation/btn_right.png")
    _spRightArrow:setAnchorPoint(ccp(1,0.5))
    _spRightArrow:setPosition(_spTableViewBg:getContentSize().width,_spTableViewBg:getContentSize().height*0.5)
    _spTableViewBg:addChild(_spRightArrow,10)
    _spRightArrow:setVisible(true)
    ChariotUtil.runArrowAction(_spRightArrow)

	-- 创建战车滑动列表
	local tabViewSize = CCSizeMake(_spTableViewBg:getContentSize().width,_spTableViewBg:getContentSize().height)
    local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return tabViewSize
		elseif functionName == "cellAtIndex" then
			-- local chariotInfo = ChariotMainData.getEquipChariotInfoByPos(index)
			-- local tbPageViewData = getPageViewData()
			local tbCellData = RuneCompoundData.getPageByMenuIdxAndPageIdx(_nCurMenuItemIdx, index)
			local tCell = RuneCompoundCell.create(tableView, index, tbCellData)
			return tCell
		elseif functionName == "numberOfCells" then
			local tbPageViewData = RuneCompoundData.getAllPageByMenuIdx(_nCurMenuItemIdx)
			local nPageTotalNum = table.count(tbPageViewData)
			return nPageTotalNum
		elseif functionName == "cellTouched" then
			
		elseif functionName == "scroll" then
			
		elseif functionName == "moveEnd" then
			-- 更新箭头
    		onPageDidSelected(index)
		end
	end
	-- 战车tabView
    _tvRuneCompound = STTableView:create()
    _tvRuneCompound:setDirection(kCCScrollViewDirectionHorizontal)
    _tvRuneCompound:setContentSize(tabViewSize)
	_tvRuneCompound:setEventHandler(eventHandler)
	-- _tvRuneCompound:setPageViewEnabled(true)
	_tvRuneCompound:setPageViewEnabled(true)
	_tvRuneCompound:setTouchPriority(_nBaseTouchPriority+kTableViewRelativeTouchPriority)
	_spTableViewBg:addChild(_tvRuneCompound,5)
end

--[[
	@desc  : 创建页码指示器
	@param : 
	@return: 
--]]
function createPageIndicator( pPageNum )
	local spNode = CCSprite:create()

	local nPageNum = pPageNum or 6
	local tbIndicator, nWidth, nSpaceX = {}, 0, 15
	if nPageNum <= 0 then
		return spNode, tbIndicator
	end

	for i=1,nPageNum do
		local msIndicator = CCMenuItemSprite:create(CCSprite:create("images/runecompound/page_indicator_n.png"),CCSprite:create("images/runecompound/page_indicator_h.png"))
		msIndicator:setPosition(ccp( nWidth, 0 ))
		spNode:addChild(msIndicator)

		nWidth = nWidth + msIndicator:getContentSize().width + nSpaceX

		tbIndicator[i] = msIndicator
	end
	nWidth = nWidth - nSpaceX

	spNode:setContentSize(CCSizeMake(nWidth, 20))

	return spNode, tbIndicator
end

function reloadPageIndicator( ... )
	if _spPageIndicator ~= nil then
		_spPageIndicator:removeFromParentAndCleanup(true)
		_spPageIndicator = nil
		_tbPageIndicator = nil
	end

	--页码标签
	local tbPageViewData = RuneCompoundData.getAllPageByMenuIdx(_nCurMenuItemIdx)
	local nPageTotalNum = table.count(tbPageViewData)
	_spPageIndicator, _tbPageIndicator = createPageIndicator(nPageTotalNum)
	_spPageIndicator:setAnchorPoint(ccp(0.5,0))
	_spPageIndicator:setPosition(_spTableViewBg:getContentSize().width*0.5, 10)
	_spTableViewBg:addChild(_spPageIndicator, 15)
end

--[[
	@desc  : 选择页码指示器
	@param :
	@return: 
--]]
function selectPageIndicator( pIdx)
	if table.isEmpty(_tbPageIndicator) then
		return
	end

	if _nCurPageIdx ~= nil and _tbPageIndicator[_nCurPageIdx] ~= nil then
		local msCurIndicator = _tbPageIndicator[_nCurPageIdx]
		msCurIndicator:unselected()
	end

	local nIdx, bSelected = pIdx or 1, pSelected == nil and false or pSelected
	local msIndicator = _tbPageIndicator[nIdx]
	if msIndicator == nil then
		return
	end
	msIndicator:selected()
	_nCurPageIdx = nIdx
end

--[[
	@desc  : 锁住部分界面操作
	@param :
	@return: 
--]]
function lockOperation( ... )
	unlockOperation()

	_lyLock = CCLayer:create()
	_lyLock:setAnchorPoint(ccp(0, 0))
	_lyLock:setPosition(0, 0)
	_lyBase:addChild(_lyLock)

	_lyLock:registerScriptTouchHandler(function ( pEventName, pTouchX, pTouchY )
		if pEventName == "began" then
			--LuaEngine 向 lua 层传触摸位置时，会将屏幕坐标转换成openGL的世界坐标
			local ptTouch = ccp(pTouchX, pTouchY)

			--点击是否在屏蔽区域
			local tbNeedMaskNode = {
				_typeMenu,                       --屏蔽掉菜单操作
				_tvRuneCompound:getSubNode(),    --屏蔽掉方案列表操作
				_btnCompound,                    --屏蔽掉合成按钮操作
			}
			local bRet = isInMask(tbNeedMaskNode, ptTouch)

			return bRet
		end
	end, false, _nBaseTouchPriority+kLockRelativeTouchPriority, true)
	_lyLock:setTouchEnabled(true)
end

--[[
	@desc  : 判断触摸点pWorldTouchPoint（世界坐标）是否在pNodes所包含的节点的区域
	@param :
	@return: 
--]]
function isInMask( pNodes, pWorldTouchPoint )
	local bRet = false
	if pWorldTouchPoint == nil then
		print("RuneCompoundLayer isInMask pWorldTouchPoint is nil")
		return bRet
	end

	if table.isEmpty(pNodes) then
		print("RuneCompoundLayer isInMask pNodes is empty")
		return bRet
	end

	for k, v in pairs(pNodes) do
		local ndParent = v:getParent()
		print("RuneCompoundLayer isInMask ndParent : ", ndParent)
		if ndParent ~= nil then
			local ptLocal = ndParent:convertToNodeSpace(pWorldTouchPoint)
			print("RuneCompoundLayer isInMask ndParent x: ", ptLocal.x, " y: ", ptLocal.y)
			local rectFrame = v:boundingBox()
			print("RuneCompoundData isInMask rectFrame origin x: ", rectFrame.origin.x, " y: ", rectFrame.origin.y)
			print("RuneCompoundData isInMask rectFrame size width: ", rectFrame.size.width, " height: ", rectFrame.size.height)
			local bContain = rectFrame:containsPoint(ptLocal)
			if bContain == true then
				bRet = true
				break
			end
		end
	end

	return bRet
end

--[[
	@desc  : 解锁界面操作
	@param :
	@return: 
--]]
function unlockOperation( ... )
	if _lyLock ~= nil then
		_lyLock:removeFromParentAndCleanup(true)
		_lyLock = nil
	end
end

--[[
	@desc  : 刷新整个界面
	@param :
	@return: 
--]]
function refreshAll( ... )
	refreshArrow()
	refreshPageView()
end

--[[
	@desc  : 刷新左右箭头
	@param :
	@return: 
--]]
function refreshArrow( ... )
	if _nCurPageIdx ~= nil and _nCurPageIdx == 1 and _spLeftArrow ~= nil then
		_spLeftArrow:setVisible(false)
	else
		if _spLeftArrow ~= nil then
			_spLeftArrow:setVisible(true)
		end
	end

	local tbPageViewData = RuneCompoundData.getAllPageByMenuIdx(_nCurMenuItemIdx)
	local nPageTotalNum = table.count(tbPageViewData)
	if _nCurPageIdx ~= nil and _nCurPageIdx == nPageTotalNum and _spRightArrow ~= nil then
		_spRightArrow:setVisible(false)
	else
		if _spRightArrow ~= nil then
			_spRightArrow:setVisible(true)
		end
	end
end

--[[
	@desc  : 刷新tableView
	@param :
	@return: 
--]]
function refreshPageView( ... )
	--刷新页码（当总页码小于上次总页码，将当前页码设置成较小的页码）
	refreshCurPageIdx()

	--重新创建页码指示器（数量可能不一样），并设置页码指示器状态
	refreshPageIndicator()

	--重新加载页面滑动器
	if _tvRuneCompound == nil then
		return
	end
	_tvRuneCompound:reloadData()

	--同步页面滑动器，与指示器一致
	_tvRuneCompound:showCellByIndex(_nCurPageIdx)
end

--[[
	@desc  : 刷新当前页面索引
	@param :
	@return: 
--]]
function refreshCurPageIdx( ... )
	--设置页码指示器的选择状态
	local tbPageViewData = RuneCompoundData.getAllPageByMenuIdx(_nCurMenuItemIdx)
	local nPageTotalNum = table.count(tbPageViewData)
	if _nCurPageIdx ~= nil and _nCurPageIdx > nPageTotalNum then
		_nCurPageIdx = nPageTotalNum
	end
end

--[[
	@desc  : 重新创建并刷新页码指示器
	@param :
	@return: 
--]]
function refreshPageIndicator( ... )
	--重新创建页码指示器
	reloadPageIndicator()

	--设置页码指示器状态
	selectPageIndicator(_nCurPageIdx)
end

----------------------动画---------------------
--[[
	@desc 	: 创建合成特效动画
	@param 	: pOverCallback 所有特效动画播放完成的回调
	@return : 
--]]
function playCompoundEffect( pOverCallback )
	-- 获取当前符印合成配方的Cell
	local cell = _tvRuneCompound:cellAtIndex(_nCurPageIdx)
	if cell == nil then
		print("RuneCompoundLayer playCompoundEffect cell is nil")
		return
	end
	local tbCellData = RuneCompoundData.getPageByMenuIdxAndPageIdx(_nCurMenuItemIdx, _nCurPageIdx)
	if table.isEmpty(tbCellData) then
		print("RuneCompoundLayer playCompoundEffect tbCellData is empty")
		return
	end

	-- local ptTargetAnchor = ccp(cell.spCenterIcon:getAnchorPoint().x, cell.spCenterIcon:getAnchorPoint().y)
	local ptTarget = ccp(cell.spCenterIcon:getPositionX(), cell.spCenterIcon:getPositionY())
	ptTarget = cell.spCenterIcon:getParent():convertToWorldSpace(ptTarget)
	ptTarget = _lyEffect:convertToNodeSpace(ptTarget)

	local moveEndCallback = function()
		-- 合成特效播放
	    local fuseEffectSprite = XMLSprite:create("images/treasure/effect/bsqdE")
	    fuseEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
	    fuseEffectSprite:setPosition(ccp(ptTarget.x, ptTarget.y))
	    _lyEffect:addChild(fuseEffectSprite,80)

	    local overCallback = function()
	    	-- 移除特效
			fuseEffectSprite:removeFromParentAndCleanup(true)
        	fuseEffectSprite = nil
        	-- 回调
        	if pOverCallback ~= nil then
        		pOverCallback()
        	end
		end
	    fuseEffectSprite:registerEndCallback(overCallback)
	end

	for nIdx, ndSideIcon in ipairs(cell.tbSideIcon) do
		local tbMat = tbCellData.cost_item ~= nil and tbCellData.cost_item[nIdx] or nil
		if not table.isEmpty(tbMat) then
			local ptOrigin = ccp(ndSideIcon:getPositionX(), ndSideIcon:getPositionY())
			ptOrigin = ndSideIcon:getParent():convertToWorldSpace(ptOrigin)
			ptOrigin = _lyEffect:convertToNodeSpace(ptOrigin)

			local needItemTid = tbMat.tid
			local itemSprite = ItemSprite.getItemSpriteByItemId(needItemTid)
			itemSprite:setAnchorPoint(ccp(ndSideIcon:getAnchorPoint().x, ndSideIcon:getAnchorPoint().y))
			itemSprite:setPosition(ptOrigin.x, ptOrigin.y)
			_lyEffect:addChild(itemSprite,30)

			-- 消耗物品特效
			local appearEffectSprite = XMLSprite:create("images/base/effect/astro/zhanxingbao")
	        appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
	        appearEffectSprite:setPosition(ccp(itemSprite:getPositionX(), itemSprite:getPositionY()))
	        _lyEffect:addChild(appearEffectSprite,50)

	        local animationEndCallback = function()
	        	appearEffectSprite:removeFromParentAndCleanup(true)
	        	appearEffectSprite = nil

	        	-- 移动到中心
				local moveTo = CCMoveTo:create(0.8, ccp(ptTarget.x, ptTarget.y))
				local actions = CCArray:create()
				actions:addObject(moveTo)
				actions:addObject(CCCallFunc:create(function()
					itemSprite:removeFromParentAndCleanup(true)
					moveEndCallback()
					-- actions:release()
				end))
				-- actions:retain()

	        	local seqAction = CCSequence:create(actions)
	        	itemSprite:runAction(seqAction)
		    end
		    appearEffectSprite:registerEndCallback( animationEndCallback )

	        print("Rune compound effect, mat tid = ", needItemTid)
		end
	end
end

-----------------回调--------------------------
--[[
	@desc  : 添加界面回调
	@param :
	@return:
--]]
function onNodeEvent( pEventName )
	if (pEventName == "enter") then
		if _fnOnEnter then
			_fnOnEnter()
		end
	elseif (pEventName == "exit") then
		if _fnOnExit then
			_fnOnExit()
		end
	end
end

--[[
	@desc  : 页面选择状态确定回调
	@param :
	@return:
--]]
function onPageDidSelected( pPageIndex )
	--刷新页码指示器
	selectPageIndicator(pPageIndex)

	--刷新左右箭头显示
	refreshArrow()
end

--[[
	@desc  : 关闭按钮回调
	@param :
	@return:
--]]
function tapCloseCb( pTag, pItem )
	if _fnTapCloseCb then
		_fnTapCloseCb(pTag, pItem)
	end
end

--[[
	@desc  : 菜单按钮回调
	@param :
	@return:
--]]
function tapMenuItemCb( pTag, pItem )
	if _fnTapMenuItemCb then
		_fnTapMenuItemCb(pTag, pItem)
	end
end

--[[
	@desc  : 点击合成按钮
	@param :
	@return:
--]]
function tapCompoundCb( pTag, pItem )
	if _tapCompoundCb then
		_tapCompoundCb(pTag, pItem)
	end
end