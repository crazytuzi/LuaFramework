-- Filename: TitleMainLayer.lua
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号系统主界面

module("TitleMainLayer", package.seeall)
require "script/ui/title/TitleController"
require "script/ui/title/TitleDef"
require "script/ui/title/TitleData"
require "script/ui/title/TitleUtil"
require "script/ui/item/ItemUtil"

local _curOpenIndex 	= nil -- 当前点开的cellindex
local _lastOpenIndex 	= nil -- 上次点开的cellindex
local _visiableCellNum 	= 0   -- 可视的Cell个数
local _curTitleType 	= 0   -- 当前选择的称号类型
local _touchPriority 	= nil -- 触摸优先级
local _zOrder 		 	= nil -- 显示层级
local _bgLayer 		 	= nil -- 背景层
local _titleTableView 	= nil -- 称号列表
local _titleListData 	= nil -- 称号列表数据
local _cutTimeLabel		= nil -- 失效倒计时Label
local _titleEffect		= nil -- 称号特效或图片
local _upArrowSp 		= nil -- 上箭头
local _downArrowSp 		= nil -- 下箭头
local _isNeedShowArrow 	= false -- 是否显示箭头

local _attrLabels 		= {}  -- 存放称号装备属性Label，用于刷新移除

local kTagTipSprite 	= 1000 -- 小红点的tag

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_curOpenIndex 	= nil
	_lastOpenIndex 	= nil
	_curTitleType 	 = TitleDef.kTitleTypeNormal -- 默认普通称号
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
	_titleTableView  = nil
	_titleListData 	 = nil
	_cutTimeLabel	 = nil
	_titleEffect	 = nil 
	_upArrowSp 		 = nil
	_downArrowSp 	 = nil
	_isNeedShowArrow = false
	_attrLabels		 = {}
end

--[[
	@desc 	: 显示界面方法
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -700
	_zOrder = pZorder or 700
    -- 判断是否支持下拉列表
    if (not BagUtil.isSupportBagCell()) then
        -- 提示玩家更新底包
        AnimationTip.showTip(GetLocalizeStringBy("lgx_1027"))
        return
    end
    if (not DataCache.getSwitchNodeState(ksSwitchTitle)) then
        return
    end
	-- 使用MainSence.changeLayer进入
	MainScene.setMainSceneViewsVisible(false,false,false)
    local titleMainLayer = createLayer(_touchPriority, _zOrder)
	MainScene.changeLayer(titleMainLayer, "TitleMainLayer")
end

--[[
	@desc 	: 背景层触摸回调
	@param 	: eventType 事件类型 x,y 触摸点
	@return : 
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc 	: 回调onEnter和onExit事件
	@param 	: event 事件名
	@return : 
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc	: 创建箭头闪烁动画
	@param	: pArrow 箭头精灵
	@return : 
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
	@desc 	: 创建Layer及UI
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createLayer( pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -700
	_zOrder = pZorder or 700

	-- 背景层
	_bgLayer = CCLayer:create()
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景图
	local bgSprite = CCSprite:create("images/title/title_bg.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	-- 标题
	local titleSprite = CCSprite:create("images/title/title_top.png")
    titleSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-titleSprite:getContentSize().height/2-15*g_fElementScaleRatio))
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(titleSprite)

	-- 返回按钮Menu
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
   	local illustrateItem = CCMenuItemImage:create("images/title/btn_title_illustrate_n.png","images/title/btn_title_illustrate_h.png")
    illustrateItem:setScale(g_fElementScaleRatio)
    illustrateItem:setAnchorPoint(ccp(1,0.5))
    illustrateItem:setPosition(ccp(_bgLayer:getContentSize().width-(backItem:getContentSize().width+30)*g_fElementScaleRatio,_bgLayer:getContentSize().height-60*g_fElementScaleRatio))
    illustrateItem:registerScriptTapHandler(illustrateItemCallback)
    backMenu:addChild(illustrateItem,1)

    -- 底下花边
	local buttomSprite = CCSprite:create("images/god_weapon/buttom_flower.png")
	buttomSprite:setAnchorPoint(ccp(0.5,0))
	buttomSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.49,0))
	buttomSprite:setScale(g_fScaleX)
	_bgLayer:addChild(buttomSprite)

	-- 上箭头
	_upArrowSp = CCSprite:create( "images/common/arrow_up_h.png")
    _upArrowSp:setAnchorPoint(ccp(0.5,1))
    _upArrowSp:setScale(g_fElementScaleRatio)
    _upArrowSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-350*g_fElementScaleRatio))
    _bgLayer:addChild(_upArrowSp,1)
    runArrowAction(_upArrowSp)

	-- 下箭头
    _downArrowSp = CCSprite:create( "images/common/arrow_down_h.png")
    _downArrowSp:setAnchorPoint(ccp(0.5,0))
    _downArrowSp:setScale(g_fElementScaleRatio)
    _downArrowSp:setPosition(_bgLayer:getContentSize().width*0.5,0)
    _bgLayer:addChild(_downArrowSp,1)
    runArrowAction(_downArrowSp)

    -- 左青龙
	local leftFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
	leftFlowerSprite:setAnchorPoint(ccp(0,0.5))
	leftFlowerSprite:setPosition(ccp(-10*g_fScaleX,_bgLayer:getContentSize().height-110*g_fElementScaleRatio))
	leftFlowerSprite:setScaleX(g_fScaleX)
	leftFlowerSprite:setScaleY(g_fElementScaleRatio)
	_bgLayer:addChild(leftFlowerSprite)

	-- 右白虎
	local rightFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
	rightFlowerSprite:setScaleX(-g_fScaleX)
	rightFlowerSprite:setScaleY(g_fElementScaleRatio)
	rightFlowerSprite:setAnchorPoint(ccp(0,0.5))
	rightFlowerSprite:setPosition(ccp(_bgLayer:getContentSize().width + 10*g_fScaleX,_bgLayer:getContentSize().height-110*g_fElementScaleRatio))
	_bgLayer:addChild(rightFlowerSprite)

	-- 总览
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1034"), g_sFontPangWa,33)
    titleLabel:setColor(ccc3(0xff,0xf6,0x00))
    titleLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-110*g_fElementScaleRatio))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(titleLabel)

   	-- 创建称号信息
	createTitleInfo()
	-- 创建标签
    createTopMenu()

    return _bgLayer
end

--[[
	@desc 	: 创建当前称号信息
	@param 	: 
	@return : 
--]]
function createTitleInfo()
    -- 用户头像
    require "script/model/utils/HeroUtil"
	local htid = UserModel.getAvatarHtid()
	local ccHeadIcon = HeroUtil.getHeroIconByHTID(htid ,UserModel.getDressIdByPos(1), nil,UserModel.getVipLevel())
	ccHeadIcon:setPosition(30*g_fElementScaleRatio, _bgLayer:getContentSize().height-235*g_fElementScaleRatio)
	ccHeadIcon:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(ccHeadIcon)

    -- 称号属性
    local attrLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1035") , g_sFontName,25,1, ccc3(0x00,0x00,0x00), type_stroke)
    attrLabel:setColor(ccc3(0xff,0xff,0xff))
    attrLabel:setPosition(ccp(150*g_fElementScaleRatio,_bgLayer:getContentSize().height-205*g_fElementScaleRatio))
    attrLabel:setAnchorPoint(ccp(0,0.5))
    attrLabel:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(attrLabel)

	-- 创建 特效 属性 倒计时
	local curTitleId = UserModel.getTitleId()
	createTitleEffectAndAttr(curTitleId)

    -- 创建称号列表
    createTitleList()
	
end

--[[
	@desc 	: 创建称号特效及属性相关信息
	@param 	: pCurTitleId 当前装备的称号ID
	@return : 
--]]
function createTitleEffectAndAttr( pCurTitleId )
	if (pCurTitleId > 0 and TitleData.getTitleStatusById(pCurTitleId) == TitleDef.kTitleStatusEquiped) then
		-- 称号特效/图片
	    _titleEffect = TitleUtil.createTitleNormalSpriteById(pCurTitleId)
	    _titleEffect:setPosition(ccp(230*g_fElementScaleRatio,_bgLayer:getContentSize().height-155*g_fElementScaleRatio))
	    _titleEffect:setAnchorPoint(ccp(0.5,0.5))
	    _titleEffect:setScale(g_fElementScaleRatio)
	    _bgLayer:addChild(_titleEffect,2)

	    local userTitleInfo = TitleData.getTitleInfoById(pCurTitleId)

	    _attrLabels = {}
	    -- 增加全体上阵武将的属性提示
	    if (userTitleInfo.property_type == TitleDef.kTitleAttrAll) then
	    	local attrAllStrLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1067"),g_sFontName,22,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrAllStrLabel:setColor(ccc3(0xff,0xf6,0x00))
			attrAllStrLabel:setAnchorPoint(ccp(0,0.5))
			attrAllStrLabel:setPosition(ccp(305*g_fElementScaleRatio, _titleEffect:getPositionY()))
			attrAllStrLabel:setScale(g_fElementScaleRatio)
			_bgLayer:addChild(attrAllStrLabel,2)
			table.insert(_attrLabels,attrAllStrLabel)
	    end

	    -- 属性数值
	    local i = 0
	    local attrInfo = TitleData.getTitleEquipAttrInfoById(pCurTitleId)
	    for k,v in pairs(attrInfo) do
	    	local row = math.floor(i/2)+1
 			local col = i%2+1
	    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v)
	    	local attrStr = affixDesc.sigleName .. "+" .. displayNum
	    	local attrStrLabel = CCRenderLabel:create(attrStr,g_sFontName,25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrStrLabel:setColor(ccc3(0x00,0xff,0x18))
			attrStrLabel:setAnchorPoint(ccp(0,0.5))
			attrStrLabel:setPosition(ccp((285+165*(col-1))*g_fElementScaleRatio, _bgLayer:getContentSize().height-(205+35*(row-1))*g_fElementScaleRatio))
			attrStrLabel:setScale(g_fElementScaleRatio)
			_bgLayer:addChild(attrStrLabel,2)
			table.insert(_attrLabels,attrStrLabel)
	    	i = i+1
	    end


        -- 剩余时间
	    local timeLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1036") , g_sFontName,25,1, ccc3(0x00,0x00,0x00), type_stroke)
	    timeLabel:setColor(ccc3(0xff,0xff,0xff))
	    timeLabel:setPosition(ccp(150*g_fElementScaleRatio,_bgLayer:getContentSize().height-270*g_fElementScaleRatio))
	    timeLabel:setAnchorPoint(ccp(0,0.5))
	    timeLabel:setScale(g_fElementScaleRatio)
	    _bgLayer:addChild(timeLabel,2)
	    table.insert(_attrLabels,timeLabel)

	    local timeStr = GetLocalizeStringBy("lgx_1039")
	    local disappearTime = 0
	    if (userTitleInfo.time_type == TitleDef.kTimeTypeLimited) then
	    	disappearTime = tonumber(userTitleInfo.deadline)
	    	timeStr = TitleUtil.getRemainTime(disappearTime)
	    end

	    _cutTimeLabel = CCLabelTTF:create(timeStr , g_sFontName,25)
	    _cutTimeLabel:setColor(ccc3(0xff,0x00,0x00))
	    _cutTimeLabel:setPosition(ccp(285*g_fElementScaleRatio,_bgLayer:getContentSize().height-270*g_fElementScaleRatio))
	    _cutTimeLabel:setAnchorPoint(ccp(0,0.5))
	    _cutTimeLabel:setScale(g_fElementScaleRatio)
	    _bgLayer:addChild(_cutTimeLabel,2)

	    local serverTime = TimeUtil.getSvrTimeByOffset()
	    if (disappearTime > serverTime) then
	    	-- 起定时器
	    	schedule(_cutTimeLabel,function()
	    		_cutTimeLabel:setString(TitleUtil.getRemainTime(disappearTime))
	    		-- print(TitleUtil.getRemainTime(disappearTime))
	    		-- print("disappearTime:",disappearTime)
	    		-- print("serverTime:",serverTime)
	    		-- 判断是否到失效时间
	    		local curServerTime = TimeUtil.getSvrTimeByOffset()
	    		-- print("curServerTime:",curServerTime)
	    		if (disappearTime <= curServerTime) then
	    			-- print("TitleMainLayer updateTitleInfoAndList")
	    			-- 停定时器
	    			_cutTimeLabel:stopAllActions()

	    			-- 记录失效的称号ID
	    			local disTitleId = UserModel.getTitleId()
	    			if (disTitleId > 0) then
						TitleData.setLastDisappearTitleId(disTitleId)
					end

	    			-- 移除失效称号
	    			UserModel.setTitleId(0)

	    			-- 刷新界面
	    			updateTitleInfoAndList()
	    		end
	    	end,1)
	    end
	else
		-- 属性显示 无 
		_attrLabels = {}
		local noAttrLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1554") , g_sFontName,25,1, ccc3(0x00,0x00,0x00), type_stroke)
    	noAttrLabel:setColor(ccc3(0x00,0xff,0x18))
    	noAttrLabel:setPosition(ccp(285*g_fElementScaleRatio,_bgLayer:getContentSize().height-205*g_fElementScaleRatio))
    	noAttrLabel:setAnchorPoint(ccp(0,0.5))
    	noAttrLabel:setScale(g_fElementScaleRatio)
    	_bgLayer:addChild(noAttrLabel)
    	table.insert(_attrLabels,noAttrLabel)
	end
end

--[[
	@desc 	: 移除称号特效及属性相关信息
	@param 	: 
	@return : 
--]]
function removeTitleEffectAndAttr()
	-- 移除特效
	if (_titleEffect ~= nil and (not tolua.isnull(_titleEffect))) then
		-- print("removeTitleEffectAndAttr _titleEffect")
		_titleEffect:removeFromParentAndCleanup(true)
		_titleEffect = nil
	end
	-- 移除Labels
	if (not table.isEmpty(_attrLabels)) then
		for k,v in pairs(_attrLabels) do
			-- print("removeTitleEffectAndAttr _attrLabels")
			print_t(_attrLabels)
			if (v ~= nil and (not tolua.isnull(v))) then
	    		v:removeFromParentAndCleanup(true)
				v = nil
			end
	    end
	end
    -- 移除倒计时
	if (_cutTimeLabel ~= nil and (not tolua.isnull(_cutTimeLabel))) then
		-- print("removeTitleEffectAndAttr _cutTimeLabel")
		_cutTimeLabel:stopAllActions()
		_cutTimeLabel:removeFromParentAndCleanup(true)
		_cutTimeLabel = nil
	end
end


--[[
	@desc 	: 创建称号类型标签
	@param 	: 
	@return : 
--]]
function createTopMenu()
	-- 创建称号类型标签
	local argsTable = {}
	require "script/libs/LuaCCMenuItem"
	local image_n = "images/active/rob/btn_title_n.png"
    local image_h = "images/active/rob/btn_title_h.png"
    local rect_full_n   = CCRectMake(0,0,184,66)
    local rect_inset_n  = CCRectMake(90,35,2,3)
    local rect_full_h   = CCRectMake(0,0,184,66)
    local rect_inset_h  = CCRectMake(90,35,2,3)
    local btn_size_n    = CCSizeMake(184, 66)
    local btn_size_n2   = CCSizeMake(184, 66)
    local btn_size_h    = CCSizeMake(184, 66)
    local btn_size_h2   = CCSizeMake(184, 66)
    
    local text_color_n  = ccc3(0xff, 0xe4, 0x00)
    local text_color_h  = ccc3(0x48, 0x85, 0xb5)
    local font          = g_sFontPangWa
    local font_size_n   = 34
    local font_size_h   = 28
    local strokeCor_n   = ccc3(0x00, 0x00, 0x00)
    local strokeCor_h   = ccc3(0x00, 0x00, 0x00)
    local stroke_size_n = 1
    local stroke_size_h = 0

    local radio_data = {}
    radio_data.touch_priority = _touchPriority - 50
    radio_data.space = 0
    radio_data.callback = changeTypeCallBack
    radio_data.direction = 1
    radio_data.defaultIndex = 1
    radio_data.items = {}

	-- 1普通称号
    local normalButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("lgx_1031"), text_color_n, text_color_h, text_color_h, font, font_size_n,
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    -- 2活动称号
    local activityButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("lgx_1032"), text_color_n, text_color_h, text_color_h, font, font_size_n, 
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    -- 3跨服称号
    local crossButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("lgx_1033"), text_color_n, text_color_h, text_color_h, font, font_size_n, 
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    table.insert(radio_data.items,normalButton)
    table.insert(radio_data.items,activityButton)
    table.insert(radio_data.items,crossButton)

    local typeMenu = LuaCCSprite.createRadioMenuWithItems(radio_data)
    typeMenu:setAnchorPoint(ccp(0,0))
    typeMenu:setPosition(ccp(5,_bgLayer:getContentSize().height-355*g_fElementScaleRatio))
    typeMenu:setScale(MainScene.elementScale)
    _bgLayer:addChild(typeMenu)

    -- 添加小红点提示
    showTipSprite(activityButton,TitleData.isNeedShowRedTipByType(TitleDef.kTitleTypeActivity))
    showTipSprite(crossButton,TitleData.isNeedShowRedTipByType(TitleDef.kTitleTypeCross))

    -- 按钮底部的线
    local lineSprite = CCSprite:create("images/common/line5.png")
    lineSprite:setAnchorPoint(ccp(0,0))
    lineSprite:setPosition(ccp(0,_bgLayer:getContentSize().height-350*g_fElementScaleRatio))
    lineSprite:setScaleY(_bgLayer:getContentSize().width/lineSprite:getContentSize().width)
    lineSprite:setRotation(90)
    _bgLayer:addChild(lineSprite)
end

--[[
	@desc 	: 显示/隐藏 按钮上边的提示小红点
	@param 	: pItem 添加的按钮 pIsVisible 是否显示
	@return : 
--]]
function showTipSprite( pItem, pIsVisible )
    if (pItem == nil) then
        return
    end
    if (pItem:getChildByTag(kTagTipSprite) ~= nil ) then
        local tipSprite = tolua.cast(pItem:getChildByTag(kTagTipSprite),"CCSprite")
        tipSprite:setVisible(pIsVisible)
    else
    	if (pIsVisible) then
	        local tipSprite = CCSprite:create("images/common/tip_2.png")
	        tipSprite:setAnchorPoint(ccp(0.5,0.5))
	        tipSprite:setPosition(ccp(pItem:getContentSize().width*0.9,pItem:getContentSize().height*0.85))
	        pItem:addChild(tipSprite,1,kTagTipSprite)
	        tipSprite:setVisible(pIsVisible)
    	end
    end
end

--[[
	@desc 	: 创建称号列表
	@param 	: 
	@return : 
--]]
function createTitleList()
	-- 根据选择的称号类型获取数据
	_titleListData = TitleData.getSortedTitleInfoByType(_curTitleType)

	local cellSize = CCSizeMake(640,95)
	cellSize.width = cellSize.width * g_fScaleX 
	cellSize.height = cellSize.height * g_fScaleX

	local createTableCallback = function(fn, t_table, a1, a2)
		require "script/ui/title/TitleEquipCell"
		local r
		if fn == "cellSize" then
			if( _curOpenIndex == a1 )then 
				r = CCSizeMake(cellSize.width, cellSize.height+97*g_fScaleX)
			else
				r = CCSizeMake(cellSize.width, cellSize.height)
			end
		elseif fn == "cellAtIndex" then
			a2 = TitleEquipCell.createCell(_titleListData[a1 + 1],a1)
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_titleListData
		elseif fn == "cellTouched" then
			-- 展开事件
			local addHeight = 97
			local offsetNum = 0
			local cIndex = a1:getIdx()
			local offsetNum = 0
			if(_curOpenIndex == cIndex) then
				setOpenIndex(nil)
				offsetNum = -addHeight
			else
				setOpenIndex(cIndex)
				offsetNum = addHeight
			end
			refreshTitleTableView(offsetNum,cIndex)
		end
		return r
	end

	local tableViewH = _bgLayer:getContentSize().height - 370*g_fElementScaleRatio
	_titleTableView = LuaTableView:createWithHandler(LuaEventHandler:create(createTableCallback), CCSizeMake(_bgLayer:getContentSize().width,tableViewH))
	_titleTableView:setBounceable(true)
	_titleTableView:setAnchorPoint(ccp(0, 0))
	_titleTableView:setPosition(ccp(0, 15*g_fElementScaleRatio))
	_bgLayer:addChild(_titleTableView)
	_titleTableView:setTouchPriority(_touchPriority-60)

	-- 记录可视的Cell个数
	_visiableCellNum = math.floor(tableViewH/cellSize.height)
	-- print("TitleMainLayer tableViewH->",tableViewH)
	-- print("TitleMainLayer cellSizeHeight->",cellSize.height)
	-- print("TitleMainLayer visiableCellNum->",_visiableCellNum)

	-- 默认没有展开Cell
	setOpenIndex(nil)

	-- 刷新箭头显示状态
	local refreshArrowFunc = function()
		if (_isNeedShowArrow) then
	        local offset =  _titleTableView:getViewSize().height-_titleTableView:getContentSize().height
	        -- print("TitleMainLayer offset => ",offset)
	        -- print("TitleMainLayer y => ",_titleTableView:getContentOffset().y)
	        if (_titleTableView:getContentOffset().y >= 0) then
	            _upArrowSp:setVisible(true)
	            _downArrowSp:setVisible(false)
	        elseif (_titleTableView:getContentOffset().y <= offset ) then
	        	_upArrowSp:setVisible(false)
	            _downArrowSp:setVisible(true)
	        else
	        	_upArrowSp:setVisible(true)
	            _downArrowSp:setVisible(true)
	        end
	    else
	    	_upArrowSp:setVisible(false)
	        _downArrowSp:setVisible(false)
    	end
    end
    schedule(_bgLayer, refreshArrowFunc, 1)
end

--[[
	@desc 	: 更新称号列表
	@param 	: pIsOffset 是否保留偏移量
	@return : 
--]]
function updateTitleListWithIsOffset( pIsOffset )

	local offset = _titleTableView:getContentOffset()
	_titleListData = TitleData.getSortedTitleInfoByType(_curTitleType)
	_titleTableView:reloadData()
	if (pIsOffset) then
		_titleTableView:setContentOffset(offset)
	end

	-- 记录箭头显示状态
	if (_visiableCellNum >= #_titleListData) then
		_isNeedShowArrow = false
		_upArrowSp:setVisible(_isNeedShowArrow)
		_downArrowSp:setVisible(_isNeedShowArrow)
	else
		_isNeedShowArrow = true
	end
end

--[[
	@desc 	: 装备成功更新称号界面
	@param 	: 
	@return : 
--]]
function updateTitleInfoAndList()
	if( tolua.isnull(_bgLayer) ) then
		print("updateTitleInfoAndList faild!")  
		return
	end

	local curTitleId = UserModel.getTitleId()

	-- 先移除原来的UI
	removeTitleEffectAndAttr()

	-- 创建新UI
	createTitleEffectAndAttr(curTitleId)

	-- 刷新列表
	updateTitleListWithIsOffset(true)
end


--[[
	@desc 	: 点击称号类型标签
	@param 	: pTag 按钮tag pItem 按钮
	@return : 
--]]
function changeTypeCallBack( pTag , pItem )
	-- if (_titleTableView) then
		AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	-- end
	if (pTag == 1) then
		_curTitleType = TitleDef.kTitleTypeNormal
	elseif (pTag == 2) then
		_curTitleType = TitleDef.kTitleTypeActivity
	elseif (pTag == 3) then
		_curTitleType = TitleDef.kTitleTypeCross
	else
		print("changeTypeCallBack tag error!")
	end

	-- 默认没有展开Cell
	setOpenIndex(nil)
	-- print("称号类型:".._curTitleType)
	updateTitleListWithIsOffset(false)

	-- 隐藏小红点
	showTipSprite(pItem,false)
end

--[[
	@desc 	: 图鉴按钮回调,进入称号图鉴界面
	@param 	: 
	@return : 
--]]
function illustrateItemCallback()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/title/illustrate/TitleIllustrateLayer"
	TitleIllustrateLayer.showLayer(_touchPriority-100,_zOrder+100)
end

--[[
	@desc 	: 返回按钮回调,关闭切回到主界面
	@param 	: 
	@return : 
--]]
function backItemCallback()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    -- 置空最近获得称号ID数组 小红点提示
    if (TitleData.isNeedShowRedTip()) then
		TitleData.clearLastGotTitleIds()
	end
	-- 进入主界面
	require "script/ui/main/MainBaseLayer"
	local mainBaseLayer = MainBaseLayer.create()
	MainScene.changeLayer(mainBaseLayer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
end

--[[
	@desc 	: 设置展开的cellIndex
	@param 	: pIndex
	@return :
--]]
function setOpenIndex( pIndex )
	_lastOpenIndex = _curOpenIndex
	_curOpenIndex = pIndex
end

--[[
	@desc 	: 得到展开的cellIndex
	@param 	:
	@return : pIndex
--]]
function getOpenIndex()
	return _curOpenIndex
end

--[[
	@des 	: 刷新称号列表
	@param 	: pAddHeight 增加的高度 pIndex 展开的索引
	@return : 
--]]
function refreshTitleTableView( pAddHeight , pIndex )
	if(tolua.isnull(_bgLayer))then  
		return
	end
	-- print("TitleMainLayer refreshTitleTableView pAddHeight->",pAddHeight)
	-- 偏移量记忆
	local offset = _titleTableView:getContentOffset()
	_titleTableView:reloadData()
	if( (_lastOpenIndex == 0 or pIndex == 0) and _visiableCellNum <= #_titleListData  )then
		offset.y = 0
	elseif( _lastOpenIndex == nil or _lastOpenIndex == pIndex )then
		offset.y = offset.y-pAddHeight*g_fScaleX
	end
	-- print("TitleMainLayer refreshTitleTableView offsetY->",offset.y)
	_titleTableView:setContentOffset(offset)
end