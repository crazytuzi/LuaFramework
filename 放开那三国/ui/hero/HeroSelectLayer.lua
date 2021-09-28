-- Filename: HeroSelectLayer.lua
-- Author: fang
-- Date: 2013-07-05
-- Purpose: 该文件用于: 武将选择系统

module("HeroSelectLayer", package.seeall)

m_sign="HeroSelectLayer"

-- 最多能选择的武将个数
local _nMaxCount
-- 武将选择系统当前运行层
local _onRunningLayer

-- scrollview高度
local _scrollview_height

-- tableview中的菜单tag
local _ksTagTableViewMenu=101
-- tableview中的背景tag
local _ksTagTableViewBg = 201
-- 复选框背景tag
local _ksTagCheckBg = 3001
-- 英雄tableview的tag
local _ksTagHeroTableView = 4001
-- “确定”按钮的tag
local _ksTagSure=5001
-- “确定”按钮
local _cmiiSureButton

local _arrSelectedHeroes = nil
-- 来自父级界面的参数结构
local _tParentParam

-- 获得经验值2dx控件
local _ccExpValue

-- 已选择武将个数
local _nSelectedCount
-- 已选择武将个数2dx控件
local _ccHeroCount


-- 返回按钮回调处理
local function fnHandlerOfReturn(tag, item_obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
-- 测试代码，用于测试新手引导
-- 	if true then
-- 	local runningScene = CCDirector:sharedDirector():getRunningScene()
-- 	local cmiStrengthen = get3SelectCellObjs()
-- 	local rect = getSpriteScreenRect(cmiStrengthen[3])
-- 	local clButton = BaseUI.createMaskLayer(-5000, rect)

-- 	runningScene:addChild(clButton, 1000, 1000)
-- --	return
-- --		get3SelectCellObjs()
-- 	end

	---[==[强化所新手引导屏蔽层
	---------------------新手引导---------------------------------
		--add by licong 2013.09.06
		require "script/guide/NewGuide"
		if(NewGuide.guideClass ==  ksGuideForge) then
			require "script/guide/StrengthenGuide"
			StrengthenGuide.changLayer()
		end
	---------------------end-------------------------------------
	--]==]
-- 正式代码，正常逻辑
	_arrSelectedHeroes = {}
	for i = 1, #_arrHeroesValue do
		if (_arrHeroesValue[i].checkIsSelected == true) then
			table.insert(_arrSelectedHeroes, _arrHeroesValue[i])
		end
	end
	require "script/ui/main/MainScene"
	local tArgs = {}
	if _tParentParam.reserved then
		tArgs = table.hcopy(_tParentParam.reserved, tArgs)
	end
	tArgs.selectedHeroes=_arrSelectedHeroes

	MainScene.changeLayer(_tParentParam.fnCreate(tArgs), _tParentParam.sign)

	---[==[ 强化所第8步
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.07
	    require "script/guide/NewGuide"
	    print("g_guideClass = ", NewGuide.guideClass)
		require "script/guide/StrengthenGuide"
	    if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 7) then
		    require "script/ui/hero/HeroStrengthenLayer"
		    local strengthenButton = HeroStrengthenLayer.getCardStrengthenButtonForGuide(2)
		    local touchRect = getSpriteScreenRect(strengthenButton)
		    StrengthenGuide.show(8, touchRect)
		end
	 ---------------------end-------------------------------------
	--]==]
end

function getSelectedHeroes( ... )
	return _arrSelectedHeroes
end

function clearSelectedHeroes( ... )
	_arrSelectedHeroes = nil
end

local function menu_item_tap_handler(tag, item_obj)
	local nIndexItem = -1

	for i=1, #_arrHeroesValue do
		for j=1, #_arrHeroesValue[i].menu_items do
			if (_arrHeroesValue[i].menu_items[j].tag == tag) then
				nIndexItem = i
				break
			end
		end
		if nIndexItem ~= -1 then
			break
		end
	end
	if nIndexItem ~= -1 then
		local ccSpriteSelected = tolua.cast(item_obj:getChildByTag(_ksTagHeroTableView), "CCSprite")
		if ccSpriteSelected:isVisible() then
			_arrHeroesValue[nIndexItem].checkIsSelected = false
			ccSpriteSelected:setVisible(false)
		else
			ccSpriteSelected:setVisible(true)
			_arrHeroesValue[nIndexItem].checkIsSelected = true
			if _tParentParam.isSingle then
				local tArgs={}
				tArgs.selectedHeroes=_arrHeroesValue[nIndexItem]
				MainScene.changeLayer(_tParentParam.fnCreate(tArgs), _tParentParam.sign)
			end
		end
	end
end

-- scrollview内容cell中的按钮
local _cell_menu_item_data = {
	{normal="images/common/checkbg.png", highlighted="images/common/checkbg.png", 
		pos_x=548, pos_y=46, tag=_ksTagCheckBg, 
		ccObj=nil, focus=true, cb=menu_item_tap_handler},
}

-- 创建标题面板
local function createTitleLayer( ... )
	--require "script/libs/LuaCCSprite"
	-- 标题背景底图
	local bg = CCSprite:create("images/hero/select/title_bg.png")
	bg:setScale(g_fScaleX)
	-- 加入背景标题底图进层
	-- 标题
	local ccSpriteTitle = CCSprite:create("images/hero/select/title.png")
	ccSpriteTitle:setPosition(ccp(45, 50))
	bg:addChild(ccSpriteTitle)

	local tItems = {
		{normal="images/hero/btn_back_n.png", highlighted="images/hero/btn_back_h.png", pos_x=473, pos_y=40, cb=fnHandlerOfReturn},
	}
	local menu = LuaCC.createMenuWithItems(tItems)
	menu:setPosition(ccp(0, 0))
	bg:addChild(menu)

	return bg
end

-- 选择武将中获取武将互表
function getHeroList(tParam)
	local hids = HeroModel.getAllHeroesHid()
	-- 武将数值
	local heroesValue = {}
	require "script/utils/LuaUtil"
	require "db/DB_Heroes"
	require "script/model/hero/HeroModel"
	require "script/ui/hero/HeroFightSimple"
	for i=1, #hids do
		-- 去除需要过滤的武将们
		local bIsFiltered = false
		if tParam.filters then
			for k=1, #tParam.filters do
				if tParam.filters[k] == hids[i] then
					bIsFiltered = true
					break
				end
			end 
		end
		if not bIsFiltered then
			local value = {}
			value.hid = hids[i]
			value.isBusy=false
			local hero = HeroModel.getHeroByHid(value.hid)
			value.htid = hero.htid
			value.level = hero.level
			value.evolve_level = hero.evolve_level
			
			local db_hero = DB_Heroes.getDataById(value.htid)
			value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)

			value.isAvatar = HeroModel.isNecessaryHero(value.htid)
			if value.isAvatar then
				value.name = UserModel.getUserName()
			else
				value.name = db_hero.name
			end
			-- value.name = db_hero.name
			 -- 经验值(将魂值)
			value.soul = tonumber(hero.soul) + db_hero.decompos_soul
			value.decompos_soul=value.soul
			value.lv_up_soul_coin_ratio = db_hero.lv_up_soul_coin_ratio
			value.star_lv = db_hero.star_lv
			value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
			value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
			value.quality_h = "images/hero/quality/highlighted.png"
			value.price = tonumber(db_hero.recruit_gold)
			value.exp_id = db_hero.exp
			value.heroQuality = db_hero.heroQuality
			
			value.menu_items = {}
			table.hcopy(_cell_menu_item_data, value.menu_items)
			for j=1, #value.menu_items do
				value.menu_items[j].tag = value.menu_items[j].tag + #heroesValue
			end
			value.type = "HeroSelect"
			value.withoutExp = tParam.withoutExp
			-- 判断是否默认为选中
			local bIsSelected = false
			if tParam.selected then
				for k=1, #tParam.selected do
					if tParam.selected[k] == hids[i] then
						bIsSelected = true
						break
					end
				end 
			end
			value.checkIsSelected = bIsSelected
			value.menu_tag = _ksTagTableViewMenu
			value.tag_bg = _ksTagTableViewBg
			heroesValue[#heroesValue+1] = value
		end
	end

	-- 按经验值排序
	local function sort(w1, w2)
		return w1.soul > w2.soul
	end
	require "script/ui/hero/HeroSort"
	heroesValue = HeroSort.sortForHeroList(heroesValue)
	return heroesValue
end

-- 中间内容列表显示区域 scrollview
-- 武将系统武将列表显示
local function createHeroSellTableView(layer)
	local cellBg = CCSprite:create("images/hero/attr_bg.png")
	local cellSize = cellBg:getContentSize()
	cellSize.width = cellSize.width * g_fScaleX
	cellSize.height = cellSize.height * g_fScaleX
	cellBg = nil

	_visiableCellNum = math.floor(_scrollview_height/(cellSize.height*g_fScaleX))

	_arrHeroesValue = getHeroList(_tParentParam)
	--将被选择的材料置于顶端
	_arrHeroesValue = setSelectedTop(_arrHeroesValue)
	local bIsNoviceGuiding = true
	if bIsNoviceGuiding then
		for i=1, #_arrHeroesValue do
			_arrHeroesValue[i].isNoviceGuiding = true
		end
	end

	require "script/ui/hero/HeroLayerCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif (fn == "cellAtIndex") then
			local len = #_arrHeroesValue
			local value = _arrHeroesValue[len-a1]
			a2 = HeroLayerCell.createCell(value, _tParentParam.touchPriority)
			a2:setScale(g_fScaleX)
			_arrHeroesValue[len-a1].ccObj = a2
			r = a2
		elseif (fn == "numberOfCells") then
			r = #_arrHeroesValue
		elseif (fn == "cellTouched") then
			--print ("cellTouched, index is: ", a1:getIdx())
			---[==[强化所新手引导屏蔽层
			---------------------新手引导---------------------------------
				--add by licong 2013.09.06
				require "script/guide/NewGuide"
				if(NewGuide.guideClass ==  ksGuideForge) then
					require "script/guide/StrengthenGuide"
					StrengthenGuide.changLayer()
				end
			---------------------end-------------------------------------
			--]==]
			fnHandlerOfCellTouched(a1:getIdx())

			-- add by licong  2013.09.10 新手引导
			local count = #_arrHeroesValue - tonumber(a1:getIdx())
			print("count = ",count)
			if( count == 1)then
				---[==[ 强化所第5步
				---------------------新手引导---------------------------------
				    --add by licong 2013.09.07
				    require "script/guide/NewGuide"
				    print("g_guideClass = ", NewGuide.guideClass)
					require "script/guide/StrengthenGuide"
				    if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 4) then
					    require "script/ui/hero/HeroSelectLayer"
					    local strengthenButton = HeroSelectLayer.get3SelectCellObjs()
					    local touchRect = getSpriteScreenRect(strengthenButton[2])
					    StrengthenGuide.show(5, touchRect)
					end
				 ---------------------end-------------------------------------
				--]==]
			end
			if( count == 2)then
				---[==[ 强化所第6步
				---------------------新手引导---------------------------------
				    --add by licong 2013.09.07
				    require "script/guide/NewGuide"
				    print("g_guideClass = ", NewGuide.guideClass)
					require "script/guide/StrengthenGuide"
				    if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 5) then
					    require "script/ui/hero/HeroSelectLayer"
					    local strengthenButton = HeroSelectLayer.get3SelectCellObjs()
					    local touchRect = getSpriteScreenRect(strengthenButton[3])
					    StrengthenGuide.show(6, touchRect)
					end
				 ---------------------end-------------------------------------
				--]==]
			end
			if( count == 3)then
				---[==[ 强化所第7步
				---------------------新手引导---------------------------------
				    --add by licong 2013.09.07
				    require "script/guide/NewGuide"
				    print("g_guideClass = ", NewGuide.guideClass)
					require "script/guide/StrengthenGuide"
				    if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 6) then
					    require "script/ui/hero/HeroSelectLayer"
					    local strengthenButton = HeroSelectLayer.getSureButton()
					    local touchRect = getSpriteScreenRect(strengthenButton)
					    StrengthenGuide.show(7, touchRect)
					end
				 ---------------------end-------------------------------------
				--]==]
			end
		else
			-- print (fn, " event is not handled.")
		end
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(layer:getContentSize().width, _scrollview_height))
	tableView:setAnchorPoint(ccp(0, 0))
	tableView:setBounceable(true)
    tableView:setTouchPriority(_tParentParam.touchPriority or -390)
	return tableView
end

--判断pHid是否在选择列表中，若在返回索引值，否则返回0
function isSelected( pHid )
	if table.isEmpty(_arrSelectedHeroes) then return 0 end

	local ret = 0
	for k,v in pairs(_arrSelectedHeroes) do
		if tonumber(v) == tonumber(pHid) then
			ret = k
			break
		end
	end
	return ret
end

--将被选择的材料置于顶端
function setSelectedTop( pTable )
	if table.isEmpty(pTable) or table.isEmpty(_arrSelectedHeroes) then return pTable end

	local ret = {}
	local notSelectedIndex = #_arrSelectedHeroes + 1
	for k,v in ipairs(pTable) do
		local tempIndex = isSelected(v.hid)
		if tempIndex ~= 0 then
			ret[tempIndex] = v
		else
			ret[notSelectedIndex] = v
			notSelectedIndex = notSelectedIndex + 1
		end
	end
	return ret
end

-- 英雄出售底
local function createBottomPanel()
	-- 背景
	local bg = CCSprite:create("images/common/sell_bottom.png")
	bg:setScale(g_fScaleX)
	-- 已选择武将(label)
	local ccLabelSelected = CCLabelTTF:create (GetLocalizeStringBy("key_1529"), g_sFontName, 25)
	ccLabelSelected:setPosition(ccp(4, 26))
	bg:addChild(ccLabelSelected)

	-- 出售英雄个数背景(9宫格)
	local fullRect = CCRectMake(0, 0, 34, 32)
	local insetRect = CCRectMake(12, 12, 10, 6)
	local ccHeroNumberBG = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	ccHeroNumberBG:setPreferredSize(CCSizeMake(70, 36))
	ccHeroNumberBG:setPosition(ccp(ccLabelSelected:getContentSize().width+ccLabelSelected:getPositionX()-10, ccLabelSelected:getPositionY()))
	bg:addChild(ccHeroNumberBG)
	-- 已选择英雄个数
	_ccHeroCount = CCLabelTTF:create ("0", g_sFontName, 25, CCSizeMake(70, 36), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
	_ccHeroCount:setPosition(ccHeroNumberBG:getPositionX(), ccHeroNumberBG:getPositionY()+2)
	bg:addChild(_ccHeroCount)

	-- 获得经验
	local ccLabelTotal = CCLabelTTF:create (GetLocalizeStringBy("key_3142"), g_sFontName, 25)
	ccLabelTotal:setPosition(ccHeroNumberBG:getContentSize().width+ccHeroNumberBG:getPositionX()+30, 26)
	bg:addChild(ccLabelTotal)
	-- 总计出售背景
	local ccTotalSilverBG = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	ccTotalSilverBG:setPreferredSize(CCSizeMake(132, 36))
	ccTotalSilverBG:setPosition(ccp(ccLabelTotal:getContentSize().width+ccLabelTotal:getPositionX()-10, ccLabelTotal:getPositionY()))
	bg:addChild(ccTotalSilverBG)

	-- 获得经验值显示label
	_ccExpValue = CCLabelTTF:create ("0", g_sFontName, 25)
	_ccExpValue:setPosition(ccTotalSilverBG:getPositionX()+10, ccTotalSilverBG:getPositionY()+2)
	bg:addChild(_ccExpValue)

	-- 确定按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(_tParentParam.touchPriority ~= nil and _tParentParam.touchPriority - 20 or -403)
	local cmiiSure = CCMenuItemImage:create("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png")
	_cmiiSureButton = cmiiSure
	cmiiSure:registerScriptTapHandler(fnHandlerOfReturn)
	menu:addChild(cmiiSure, 0, _ksTagSure)
	menu:setPosition(ccp(504, 10))
	bg:addChild(menu)

	return bg
end

function createLayer(tParam)
	-- 保存父页面传入的参数，以方便页面跳转
	_tParentParam = tParam
	_arrSelectedHeroes = _tParentParam.selected
	_nSelectedCount = 0
	if _arrSelectedHeroes then
		_nSelectedCount = #_arrSelectedHeroes
	end

	-- 最多能选择的武将个数，最多为5个
	_nMaxCount = 5
	local layer = CCLayer:create()
	-- 加载模块背景图
	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setScale(g_fBgScaleRatio)
	layer:addChild(bg)

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	MainScene.setMainSceneViewsVisible(false,false,true)
	MenuLayer.getObject():setVisible(false)
	local tBottomSize = {width=0, height=0}
	local ccBottomPanel = nil
	if not _tParentParam.isSingle then
		ccBottomPanel = createBottomPanel()
		tBottomSize = ccBottomPanel:getContentSize()
	end

	-- 隐藏avatar层
	local ccObjAvatar = MainScene.getAvatarLayerObj()
	ccObjAvatar:setVisible(false)

	local layerRect = {}
	layerRect.width = g_winSize.width
	layerRect.height = g_winSize.height - bulletinLayerSize.height*g_fScaleX
	layer:setContentSize(CCSizeMake(g_winSize.width, layerRect.height))

	local ccLayerTitle = createTitleLayer()
	ccLayerTitle:setPosition(0, layerRect.height)
	ccLayerTitle:setAnchorPoint(ccp(0, 1))
	layer:addChild(ccLayerTitle)

	local nHeightOfBottom = (tBottomSize.height-12)*g_fScaleX
	local nHeightOfTitle = (ccLayerTitle:getContentSize().height-16)*g_fScaleX

	-- 12个像素偏移是因为下底框有12个像素的通明高度
	_scrollview_height = g_winSize.height - bulletinLayerSize.height*g_fScaleX - nHeightOfBottom - nHeightOfTitle

	local tableview = createHeroSellTableView(layer)
	tableview:setPosition(0, nHeightOfBottom)
	layer:addChild(tableview)
-- 加入底层面板
	if ccBottomPanel then
		layer:addChild(ccBottomPanel)
	end
	_onRunningLayer = layer
	fnUpdateSelectionInfo()
	return layer
end

-- 处理单元格被点击事件
fnHandlerOfCellTouched = function (pIndex)
	local nIndex = #_arrHeroesValue - pIndex

	local ccCellObj = tolua.cast(_arrHeroesValue[nIndex].ccObj:getChildByTag(_ksTagTableViewBg), "CCSprite")
	local ccSpriteCheckBox = tolua.cast(ccCellObj:getChildByTag(10001), "CCSprite")
	local ccSpriteSelected =  tolua.cast(ccSpriteCheckBox:getChildByTag(10002), "CCSprite")

	if _tParentParam.isSingle then
		-- if _arrHeroesValue[nIndex].checkIsSelected then
		-- 	_arrHeroesValue[nIndex].checkIsSelected = false
		-- 	ccSpriteSelected:setVisible(false)
		-- else
			local tArgs = {}
			if _tParentParam.reserved then
				tArgs = table.hcopy(_tParentParam.reserved, tArgs)
			end
			tArgs.selectedHeroes=_arrHeroesValue[nIndex]

			MainScene.changeLayer(_tParentParam.fnCreate(tArgs), _tParentParam.sign)
			return
--		end
	else
		if (_arrHeroesValue[nIndex].checkIsSelected == false) then
			if _nSelectedCount >= 5 then
				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(GetLocalizeStringBy("key_1703"))
				return
			end
			_arrHeroesValue[nIndex].checkIsSelected = true
			ccSpriteSelected:setVisible(true)
			_nSelectedCount = _nSelectedCount + 1
		else
			_arrHeroesValue[nIndex].checkIsSelected = false
			ccSpriteSelected:setVisible(false)
			_nSelectedCount = _nSelectedCount - 1
		end
	end
	fnUpdateSelectionInfo()
end
-- 更新武将选择提示信息
fnUpdateSelectionInfo = function ()
-- 更新选择个数
	if _tParentParam and _tParentParam.isSingle then
		return
	end
	_ccHeroCount:setString(_nSelectedCount)
	local nTotalExp = 0
	local nObjCount = #_arrHeroesValue

	for i=1, nObjCount do
		if _arrHeroesValue[i].checkIsSelected then
			nTotalExp = nTotalExp + _arrHeroesValue[i].soul
		end
	end
-- 更新能获得的经验值
	_ccExpValue:setString(nTotalExp)
end

-- 新手引导
-- 获得可点击3个武将的方法
function get3SelectCellObjs( ... )
	local tCellObjs = {}
	local nObjCount = #_arrHeroesValue
	if nObjCount > 3 then
		nObjCount = 3
	end
	for i=1, nObjCount do
		local cellObj = tolua.cast(_arrHeroesValue[nObjCount-i+1].ccObj:getChildByTag(_ksTagTableViewBg), "CCSprite")
		local csTransparent = tolua.cast(cellObj:getChildByTag(30001), "CCSprite")
		table.insert(tCellObjs, csTransparent)
	end
	tCellObjs = table.reverse(tCellObjs)
	return tCellObjs
end
-- 新手引导
-- 获得“确定”按钮
function getSureButton( ... )
	return _cmiiSureButton
end

-- 释放HeroSelectLayer模块占用资源
function release()
	HeroSelectLayer = nil
	for k, v in pairs(package.loaded) do
		local s, e = string.find(k, "/HeroSelectLayer")
		if s and e == string.len(k) then
			package.loaded[k] = nil
		end
	end
end
