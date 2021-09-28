-- Filename: RefiningSelectLayer.lua
-- Author: zhang zihang
-- Date: 2015-3-2
-- Purpose: 炼化炉选择界面

module ("RefiningSelectLayer", package.seeall)

require "script/ui/refining/RefiningData"
require "script/ui/refining/RefiningUtils"

local _bgLayer												--背景layer
local _chooseDesLabel 										--底部提示label
local _chooseNumLabel 										--选择数量label
local _curTagMenu 											--当前menu
local _curTag 												--当前tag
local _bottomGap 											--底部距离
local _upGap 												--顶部距离
local _tableView 											--tableView
local _scrollView                                           --顶端标签超过5个后的scrollview
local _kLeftTag     =1001                                    --顶端左箭头标签
local _kRightTag    =1002                                    --顶端右箭头标签
local _menuBarCount                                           --顶端menuBar有几个标签
--cell大小
local _sizeTable = {
						CCSizeMake(640*g_fScaleX,160*g_fScaleX),
						CCSizeMake(640*g_fScaleX,170*g_fScaleX),
						CCSizeMake(640*g_fScaleX,170*g_fScaleX),
						CCSizeMake(640*g_fScaleX,170*g_fScaleX),
						CCSizeMake(640*g_fScaleX,170*g_fScaleX),
						CCSizeMake(640*g_fScaleX,170*g_fScaleX),
						CCSizeMake(640*g_fScaleX,170*g_fScaleX),
						CCSizeMake(640*g_fScaleX,170*g_fScaleX),
						CCSizeMake(640*g_fScaleX,160*g_fScaleX),
						CCSizeMake(640*g_fScaleX,190*g_fScaleX),
				   }

local kHeroTag = RefiningData.kHeroTag   					--英雄tag
local kEquipTag = RefiningData.kEquipTag 					--装备tag
local kTreasureTag = RefiningData.kTreasureTag				--宝物tag
local kClothTag = RefiningData.kClothTag					--时装tag
local kGodTag = RefiningData.kGodTag						--神兵tag
local kTokenTag = RefiningData.kTokenTag                    --符印tag
local kPocketTag = RefiningData.kPocketTag					--锦囊tag
local kHeroJHTag = RefiningData.kHeroJHTag                 	--武将精华tag
local kTallyTag = RefiningData.kTallyTag                    --兵符tag
local kChariotTag = RefiningData.kChariotTag 				--战车tag
local kResolveTag = RefiningData.kResolveMainTag 			--炼化tag
local kResurrectTag = RefiningData.kResurrectMainTag		--重生tag
local kSoulTag = RefiningData.kSoulMainTag					--化魂tag
--炼化已选择label
local _resolveChooseLabelTable = {
								GetLocalizeStringBy("key_1529"),
								GetLocalizeStringBy("key_1351"),
								GetLocalizeStringBy("key_1979"),
								GetLocalizeStringBy("key_2806"),
								GetLocalizeStringBy("zzh_1229"),
								GetLocalizeStringBy("djn_174"),
								"",
								"",
								GetLocalizeStringBy("syx_1070"),
								GetLocalizeStringBy("lgx_1087"), -- 战车
						  }
--重生已选择label
local _reasureChooseLabelTable = {
								GetLocalizeStringBy("key_1529"),
								GetLocalizeStringBy("key_1351"),
								GetLocalizeStringBy("key_1979"),
								GetLocalizeStringBy("key_2806"),
								GetLocalizeStringBy("zzh_1229"),
								"",
								GetLocalizeStringBy("djn_217"),
								"",
								GetLocalizeStringBy("syx_1070"),
								GetLocalizeStringBy("lgx_1087"), -- 战车
						  }
local _soulChooseLabelTable  = {
								[kHeroTag] = GetLocalizeStringBy("key_1529"),
								[kHeroJHTag] = GetLocalizeStringBy("syx_1059"),
						  }

local kSureTag = 2001 										--确定tag
local kReturnTag = 2002										--返回tag
--==================== Init ====================
--[[
	@des 	:初始化函数
--]]
function init()
	_bgLayer = nil
	_chooseDesLabel = nil
	_chooseNumLabel = nil
	_curTagMenu = nil
	_curTag = nil
	_bottomGap = nil
	_upGap = nil
	_tableView = nil
	_scrollView = nil
	_menuBarCount = 0
end

--==================== CallBack ====================
function onNodeEvent(event)
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(cardLayerTouch, false, -200, true)
		_bgLayer:setTouchEnabled(true)

	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end
function cardLayerTouch(p_event,p_x,p_y )
	if(p_event == "began") then
		return true
	elseif(p_event == "moved")then
	elseif(p_event == "ended" or p_event == "cancelled")then
		refreshArrow()
	end
	-- body
end
--[[
	@des 	:下方按钮回调
	@param  :按钮tag
--]]
function overCallBack(p_tag)
	--点了确定，将选择的添加到选择数组里
	if p_tag == kSureTag then
		--将临时数据转正
		RefiningData.setCurData()
		--清除用于选择的数组
		RefiningData.clearSelectArray()

		local fitInfo
		local curTag = RefiningData.getCurSelectTag()
		if curTag == kHeroTag then
			fitInfo = RefiningData.getHeroFit()
		elseif curTag == kEquipTag then
			fitInfo = RefiningData.getEquipFit()
		elseif curTag == kTreasureTag then
			fitInfo = RefiningData.getTreasFit()
		elseif curTag == kClothTag then
			fitInfo = RefiningData.getClothFit()
		elseif curTag == kGodTag then
			fitInfo = RefiningData.getGodFit()
		elseif curTag == kTokenTag then
			fitInfo = RefiningData.getTokenFit()
		elseif curTag == kPocketTag then
			fitInfo = RefiningData.getPocketFit()
		elseif curTag == kHeroJHTag then
			fitInfo = RefiningData.getHeroJHFit()
		elseif curTag == kTallyTag then
			fitInfo = RefiningData.getTallyFit()
		elseif curTag == kChariotTag then
			-- 战车
			fitInfo = RefiningData.getChariotFit()
		end

		local chooseTable = RefiningData.getCurChooseIdTable()

		for i = #fitInfo,1,-1 do
			if chooseTable[i] ~= nil then
				if curTag == kHeroJHTag then
					fitInfo[i].selectNum = chooseTable[i]
				end
				RefiningData.addSelectArray(fitInfo[i])
			end
		end
	end

	require "script/ui/refining/RefiningMainLayer"
	RefiningMainLayer.createLayer()
end

--[[
	@des 	:转换模式回调
	@param  :按钮tag
	@param  :按钮
--]]
function changeModeCallBack(p_tag,p_menu)
	local curTag = RefiningData.getTempChooseTag()

	--按下显示转换
	_curTagMenu:unselected()
	p_menu:selected()

	--如果当前tag和原来的是同一个，则不做处理
	if _curTag == p_tag then
		return
	end

	RefiningData.setTempChooseTag(p_tag)
	--设置当前tag和menu
	setCurTagAndMenu(p_tag,p_menu)
	--重置临时对象
	RefiningData.resetTempData()

	--类别label
	if(RefiningData.getCurMainTag() == kResolveTag) then
		_chooseDesLabel:setString(_resolveChooseLabelTable[p_tag])
	elseif RefiningData.getCurMainTag() == kResurrectTag then
		_chooseDesLabel:setString(_reasureChooseLabelTable[p_tag])
	elseif RefiningData.getCurMainTag() == kSoulTag then
		_chooseDesLabel:setString(_soulChooseLabelTable[p_tag])
	end
	--更新选择数量
	refreshNumLabel()

	if _tableView ~= nil then
		_tableView:removeFromParentAndCleanup(true)
		_tableView = nil
	end
	createSelectView(p_tag)
end

--[[
	@des 	:刷新数量label
--]]
function refreshNumLabel()
	--已选择数目
	local haveChooseNum = RefiningData.getTempChooseNum()
	--可选择数目
	local canChooseNum = RefiningData.getMaxChooseNum()
	--已选择label
	_chooseNumLabel:setString(haveChooseNum .. "/" .. canChooseNum)
end

--[[
	@des 	:设置当前tag和Menu
	@param  :按钮tag
	@param  :按钮
--]]
function setCurTagAndMenu(p_tag,p_menu)
	_curTag = p_tag
	_curTagMenu = p_menu
end

--==================== TablelView ====================
--[[
	@des 	:创建背景UI
	@param  :tag值
--]]
function createSelectView(p_tag)
	local cellSize = _sizeTable[p_tag]
	-- cellSize.width = cellSize.width*g_fScaleX
	-- cellSize.height = cellSize.height*g_fScaleX

	local viewInfo
	if p_tag == kHeroTag then
		viewInfo = RefiningData.getHeroFit()
	elseif p_tag == kEquipTag then
		viewInfo = RefiningData.getEquipFit()
	elseif p_tag == kTreasureTag then
		viewInfo = RefiningData.getTreasFit()
	elseif p_tag == kClothTag then
		viewInfo = RefiningData.getClothFit()
	elseif p_tag == kGodTag then
		viewInfo = RefiningData.getGodFit()
	elseif p_tag == kTokenTag then
		viewInfo = RefiningData.getTokenFit()
	elseif p_tag == kPocketTag then
		viewInfo = RefiningData.getPocketFit()
	elseif p_tag == kHeroJHTag then
		viewInfo = RefiningData.getHeroJHFit()
	elseif p_tag == kTallyTag then
		viewInfo = RefiningData.getTallyFit()
	elseif p_tag == kChariotTag then
		-- 战车
		viewInfo = RefiningData.getChariotFit()
	end

	local handler = LuaEventHandler:create(function(fn,p_table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width,cellSize.height)
		elseif fn == "cellAtIndex" then
			local isSelected = RefiningData.isTempChoose(a1 + 1)
			if p_tag == kHeroTag then
				a2 = RefiningUtils.createHeroCell(viewInfo[a1 + 1],isSelected)
				RefiningData.setHeroA2(a1 + 1,a2)
			elseif p_tag == kEquipTag then
				a2 = RefiningUtils.createEquipCell(viewInfo[a1 + 1],isSelected)
				RefiningData.setEquipA2(a1 + 1,a2)
			elseif p_tag == kTreasureTag then
				a2 = RefiningUtils.createTreasCell(viewInfo[a1 + 1],isSelected)
				RefiningData.setTreasA2(a1 + 1,a2)
			elseif p_tag == kClothTag then
				a2 = RefiningUtils.createClothCell(viewInfo[a1 + 1],isSelected)
				RefiningData.setClothA2(a1 + 1,a2)
			elseif p_tag == kGodTag then
				a2 = RefiningUtils.createGodWeaponCell(viewInfo[a1 + 1],isSelected)
				RefiningData.setGodA2(a1 + 1,a2)
			elseif p_tag == kTokenTag then
				a2 = RefiningUtils.createTokenCell(viewInfo[a1 + 1],isSelected)
				RefiningData.setTokenA2(a1 + 1,a2)
			elseif p_tag == kPocketTag then
				a2 = RefiningUtils.createPocketCell(viewInfo[a1 + 1],isSelected)
				RefiningData.setPocketA2(a1 + 1,a2)
			elseif p_tag == kHeroJHTag then
				a2 = RefiningUtils.createHeroJHCell(viewInfo[a1 + 1],isSelected,a1 + 1)
			elseif p_tag == kTallyTag then
				a2 = RefiningUtils.createTallyCell(viewInfo[a1 + 1],isSelected)
				RefiningData.setTallyA2(a1 + 1,a2)
			elseif p_tag == kChariotTag then
				-- 战车
				a2 = RefiningUtils.createChariotCell(viewInfo[a1 + 1],isSelected)
				RefiningData.setChariotA2(a1 + 1,a2)
			end
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #viewInfo
		elseif fn == "cellTouched" then
			if RefiningData.getCurMainTag() == kResolveTag then
				RefiningUtils.tapResolveSelect(a1:getIdx() + 1)
			elseif RefiningData.getCurMainTag() == kResurrectTag then
				RefiningUtils.tapResurrectSelect(a1:getIdx() + 1)
			elseif RefiningData.getCurMainTag() == kSoulTag then
				if p_tag == kHeroTag then
					RefiningUtils.tapSoulSelect(a1:getIdx() + 1)
				end
			end
		end
		
		return r
	end)

	local scrollHeight = g_winSize.height - _bottomGap*g_fScaleX - _upGap*g_fScaleX

	_tableView = LuaTableView:createWithHandler(handler,CCSizeMake(g_winSize.width,scrollHeight))
	_tableView:setAnchorPoint(ccp(0,0))
	_tableView:setTouchPriority(-401)
	_tableView:setBounceable(true)
	_tableView:setPosition(ccp(0,_bottomGap*g_fScaleX))
	local upOffset = RefiningData.getBiggestOffset() or #viewInfo
	_tableView:setContentOffset(ccp(0,scrollHeight - upOffset*cellSize.height))
	_bgLayer:addChild(_tableView)
end

--==================== UI ====================
--[[
	@des 	:创建背景UI
--]]
function createBgUI()
	--背景图
	local bgSprite = CCSprite:create("images/main/module_bg.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)
end

--[[
	@des 	:创建底部UI
--]]
function createBottomUI()
	--底部背景
	local bgSprite = CCSprite:create("images/common/sell_bottom.png")
	bgSprite:setAnchorPoint(ccp(0.5,0))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,0))
	bgSprite:setScale(g_fScaleX)
	_bgLayer:addChild(bgSprite)

	--得到背景大小
	local bgSize = bgSprite:getContentSize()

	_bottomGap = bgSize.height

	--当前分页tag
	local curTag = RefiningData.getTempChooseTag()
	--y坐标
	local posX = bgSize.width*0.5 - 145
	local posY = 25
	--已选择label
	local chooseStr = nil
	--类别label
	if(RefiningData.getCurMainTag() == kResolveTag) then
		chooseStr = _resolveChooseLabelTable[curTag]
	elseif RefiningData.getCurMainTag() == kResurrectTag then
		chooseStr = _reasureChooseLabelTable[curTag]
	elseif RefiningData.getCurMainTag() == kSoulTag then
		chooseStr = _soulChooseLabelTable[curTag]
	end
	_chooseDesLabel = CCLabelTTF:create(chooseStr,g_sFontName,25)
	_chooseDesLabel:setColor(ccc3(0xff,0xff,0xff))
	_chooseDesLabel:setAnchorPoint(ccp(1,0))
	_chooseDesLabel:setPosition(ccp(posX,posY))
	bgSprite:addChild(_chooseDesLabel)
	--数量框背景
	local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(12,12,10,6)
	local numBgSize = CCSizeMake(70,36)
	local numBgSprite = CCScale9Sprite:create("images/common/checkbg.png",fullRect,insetRect)
	numBgSprite:setAnchorPoint(ccp(0,0))
	numBgSprite:setPreferredSize(numBgSize)
	numBgSprite:setPosition(ccp(posX,posY))
	bgSprite:addChild(numBgSprite)
	--已选择数目
	local haveChooseNum = RefiningData.getTempChooseNum()
	--可选择数目
	local canChooseNum = RefiningData.getMaxChooseNum()
	--已选择label
	_chooseNumLabel = CCLabelTTF:create (haveChooseNum .. "/" .. canChooseNum,g_sFontName,25)
	_chooseNumLabel:setColor(ccc3(0xff,0xff,0xff))
	_chooseNumLabel:setAnchorPoint(ccp(0.5,0.5))
	_chooseNumLabel:setPosition(ccp(numBgSize.width*0.5,numBgSize.height*0.5))
	numBgSprite:addChild(_chooseNumLabel)

	-- 确定按钮
	local bgMenu = CCMenu:create()
	bgMenu:setTouchPriority(-405)
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgSprite:addChild(bgMenu)
	--按钮位置Y
	local menuPosY = 10
	--确定按钮
	local sureMenuItem = CCMenuItemImage:create("images/tip/btn_confirm_n.png","images/tip/btn_confirm_h.png")
	sureMenuItem:setAnchorPoint(ccp(0,0))
	sureMenuItem:setPosition(ccp(505,menuPosY))
	sureMenuItem:registerScriptTapHandler(overCallBack)
	bgMenu:addChild(sureMenuItem,1,kSureTag)
	--取消按钮
	local returnMenuItem = CCMenuItemImage:create("images/tip/btn_cancel_n.png","images/tip/btn_cancel_h.png")
	returnMenuItem:setAnchorPoint(ccp(0,0))
	returnMenuItem:setPosition(ccp(340,menuPosY))
	returnMenuItem:registerScriptTapHandler(overCallBack)
	bgMenu:addChild(returnMenuItem,1,kReturnTag)
end

--[[
	@des 	:创建选择按钮UI
--]]
function createSelectUI()
	--创建主菜单标签
	local argsTable = {}
    --local isResolveFlag = false --是否是炼化界面的标志位 因为炼化的顶端的menuBar是scrollview（因为已经放不下）
    --要对炼化重生分开处理
	
	if RefiningData.getCurMainTag() == kResolveTag then
		--炼化
		--isResolveFlag = true
		argsTable[1] = {text = GetLocalizeStringBy("key_1453"),x = -5,tag = kHeroTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		argsTable[2] = {text = GetLocalizeStringBy("key_2025"),x = 120,tag = kEquipTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		argsTable[3] = {text = GetLocalizeStringBy("key_1848"),x = 245,tag = kTreasureTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		argsTable[4] = {text = GetLocalizeStringBy("key_2020"),x = 370,tag = kClothTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		argsTable[5] = {text = GetLocalizeStringBy("lic_1418"),x = 495,tag = kGodTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		--炼化新增符印 重生没有符印
		argsTable[6] = {text = GetLocalizeStringBy("lic_1531"),x = 620,tag = kTokenTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		-- 兵符
		argsTable[7] = {text = GetLocalizeStringBy("lic_1773"),x = 745,tag = kTallyTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		-- 战车
		argsTable[8] = {text = GetLocalizeStringBy("zq_0019"),x = 870,tag = kChariotTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
	elseif RefiningData.getCurMainTag() == kResurrectTag then 
		argsTable[1] = {text = GetLocalizeStringBy("key_1453"),x = -5,tag = kHeroTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		argsTable[2] = {text = GetLocalizeStringBy("key_2025"),x = 120,tag = kEquipTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		argsTable[3] = {text = GetLocalizeStringBy("key_1848"),x = 245,tag = kTreasureTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		argsTable[4] = {text = GetLocalizeStringBy("key_2020"),x = 370,tag = kClothTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		argsTable[5] = {text = GetLocalizeStringBy("lic_1418"),x = 495,tag = kGodTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		--重生新加锦囊 
		argsTable[6] = {text = GetLocalizeStringBy("lic_1625"),x = 620,tag = kPocketTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		argsTable[7] = {text = GetLocalizeStringBy("lic_1773"),x = 745,tag = kTallyTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		-- 战车
		argsTable[8] = {text = GetLocalizeStringBy("zq_0019"),x = 870,tag = kChariotTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
	elseif RefiningData.getCurMainTag() == kSoulTag then
		--化魂
		argsTable[1] = {text = GetLocalizeStringBy("key_1453"),x = -5,tag = kHeroTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		if SoulLayer.kIsHeroJHOpen then
			argsTable[2] = {text = GetLocalizeStringBy("syx_1062"),x = 120,tag = kHeroJHTag,handler = changeModeCallBack,normalN = "images/recycle/btn_title_h.png",normalH = "images/recycle/btn_title_n.png",nFontsize = 33}
		end
	end
    _menuBarCount = #argsTable
	--走马灯大小
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local menuPosY = g_winSize.height - bulletinLayerSize.height*g_fScaleX
    --创建顶部菜单栏的公用方法
	local topMenu = LuaCCSprite.createTitleBar(argsTable,0.95,-400,true)
	
	if(#argsTable >5 )then
		_scrollView = CCScrollView:create()
	    _scrollView:setContentSize(CCSizeMake(g_winSize.width + (#argsTable -5 )*125, topMenu:getContentSize().height))
	    _scrollView:setViewSize(CCSizeMake(g_winSize.width, topMenu:getContentSize().height))
	    _scrollView:setScale(g_fScaleX)
	    _scrollView:setBounceable(false)
	    _scrollView:ignoreAnchorPointForPosition(false)
	    _scrollView:setAnchorPoint(ccp(0,1))	    
	    _scrollView:setPosition(g_winSize.width*0,menuPosY)
	    _scrollView:setTouchPriority(-401)
	    _scrollView:setDirection(kCCScrollViewDirectionHorizontal)
	    _scrollView:setContentOffset(ccp(0,0))
	    _bgLayer:addChild(_scrollView)

        topMenu:setAnchorPoint(ccp(0,0))
		--topMenu:setScale(g_fScaleX)
		topMenu:setPosition(0,0)		
		_scrollView:addChild(topMenu)
        
        --加箭头
		createShiningArrow(_kRightTag,menuPosY-topMenu:getContentSize().height*g_fScaleX + 10*g_fScaleX)
		createShiningArrow(_kLeftTag,menuPosY-topMenu:getContentSize().height*g_fScaleX + 10*g_fScaleX)
		refreshArrow()
	else
		topMenu:setAnchorPoint(ccp(0,1))
		topMenu:setScale(g_fScaleX)
		topMenu:setPosition(0,menuPosY)		
		_bgLayer:addChild(topMenu)
	end

	
	_upGap = topMenu:getContentSize().height + bulletinLayerSize.height

	--获取两个分标签
	local tempMenu = tolua.cast(topMenu:getChildByTag(10001),"CCMenu")
	--当前所在分页面
	local curBranchTag = RefiningData.getTempChooseTag()
	--当前页面
	local curMenuItem = tolua.cast(tempMenu:getChildByTag(curBranchTag),"CCMenuItem")
	--选定
	curMenuItem:selected()
	print("curBranchTag",curBranchTag)
	if(table.count(argsTable) >5)then
		--当前选择的标签已经在屏幕之外。。。要对scrollView做一下偏移
		_scrollView:setContentOffset(ccp(-(curBranchTag - 5)*125,0))
	end
	--设置当前tag和menu
	setCurTagAndMenu(curBranchTag,curMenuItem)
	--创建TableView
	createSelectView(curBranchTag)
end
--[[
	@des 	:创建闪动箭头
--]]
function createShiningArrow(p_index,p_poxY)
	local imagesPath
	local anchorPoint = ccp(0,0)
	local arrowSpPositon = ccp(0,0)
	
	if p_index == _kLeftTag then
		imagesPath = "images/formation/btn_left.png"
		anchorPoint = ccp(0,0)
		arrowSpPositon = ccp(0,p_poxY)
	elseif p_index == _kRightTag then
		imagesPath = "images/formation/btn_right.png"
		anchorPoint = ccp(1,0)
		arrowSpPositon = ccp(g_winSize.width,p_poxY)
	end
    
	local arrowSp = CCSprite:create(imagesPath)
	arrowSp:setScale(g_fScaleX)
	arrowSp:setPosition(arrowSpPositon)
	arrowSp:setAnchorPoint(anchorPoint)
	_bgLayer:addChild(arrowSp,3,p_index)

	--动画
	local arrActions = CCArray:create()
	arrActions:addObject(CCFadeOut:create(1))
	arrActions:addObject(CCFadeIn:create(1))
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)
	arrowSp:runAction(action)
end
--[[
	@des 	:刷新闪动箭头
--]]
function refreshArrow( ... )
	if not _scrollView then
		return
	end
	local contentOffset = _scrollView:getContentOffset()
	if(contentOffset.x == 0)then
		--在最左面 左箭头不用显示
		setArrowVisible(_kLeftTag,false)
		setArrowVisible(_kRightTag,true)
	elseif( contentOffset.x <= -125 * (_menuBarCount - 5))then
    	--在最右面 右箭头不用显示
    	setArrowVisible(_kRightTag,false)
    	setArrowVisible(_kLeftTag,true)
    else
    	setArrowVisible(_kLeftTag,true)
    	setArrowVisible(_kRightTag,true)
    end


end
--设置箭头是否可见
function setArrowVisible( p_index,p_visible)
	local nineSprite = tolua.cast(_bgLayer:getChildByTag(p_index),"CCSprite")
	 nineSprite:setVisible(p_visible)
end
--[[
	@des 	:创建UI
--]]
function createUI()
	--创建背景UI
	createBgUI()
	--创建底部UI
	createBottomUI()
	--创建选择按钮
	createSelectUI()
end

--==================== Entrance ====================
--[[
	@des 	:入口函数
--]]
function createLayer()
	init()

	--设置缓存数据
	RefiningData.setTempData()

	_bgLayer = CCLayer:create()
    
	createUI()
	_bgLayer:registerScriptHandler(onNodeEvent)
	MainScene.setMainSceneViewsVisible(false,false,true)
	MainScene.changeLayer(_bgLayer,"RefiningSelectLayer")
end