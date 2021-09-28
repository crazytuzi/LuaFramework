-- Filename: ResolveLayer.lua
-- Author: zhang zihang
-- Date: 2015-2-28
-- Purpose: 炼化页面

module ("ResolveLayer", package.seeall)

require "script/ui/refining/RefiningUtils"
require "script/ui/refining/RefiningData"
require "script/ui/refining/RefiningController"
require "script/ui/refining/FastAddMenuItem"
require "script/ui/tip/AnimationTip"
require "script/ui/refining/preview/ResolvePreviewDialog"
require "script/ui/refining/preview/RefiningPreviewController"
require "script/ui/refining/preview/RefiningPreviewData"

local kPullUp = 0               --上拉菜单打开的状态
local kPullDown = 1             --上拉菜单关闭的状态

local _layer 					--创建的layer
local _baseMenu 				--基础menu
local _resolveMenuItem  		--炼化按钮
local _menuItemContainer 		--存放按钮的容器
local _fastContainer 			--快速添加按钮的容器
local _pullBtn                  --上拉菜单
local _pullMenuArrow            --上拉菜单箭头
local _fastAddBtn               --快速添加按钮
local _fastAddBtnMenu           --快速添加按钮菜单
local _hadFiveStr				--高星武将 或 高级装备提示
local _hadMaxStar				--选择的最高星级

local kSelectNum = 5

local kTipLayerZOrder = 999 	--提示面板z轴

--x坐标位置
local kMenuPosXTable = { g_winSize.width*0.5 , 
						 g_winSize.width*0.5 - 220*g_fScaleX , 
						 g_winSize.width*0.5 + 220*g_fScaleX , 
						 g_winSize.width*0.5 - 130*g_fScaleX , 
						 g_winSize.width*0.5 + 130*g_fScaleX 
					   }
--y坐标位置
local kMenuPosYTable = { g_winSize.height*0.5 + 250*g_fScaleY , 
						 g_winSize.height*0.5 + 130*g_fScaleY , 
						 g_winSize.height*0.5 + 130*g_fScaleY , 
						 g_winSize.height*0.5 - 60*g_fScaleY , 
						 g_winSize.height*0.5 - 60*g_fScaleY 
					   }

--==================== Init ====================
--[[
	@des 	:初始化函数
--]]
function init()
	_layer = nil
	_baseMenu = nil
	_resolveMenuItem = nil
	_pullBtn = nil
	_pullMenuArrow = nil
	_menuItemContainer = {}
	_fastAddBtnMenu = nil
	_fastContainer = {}
	_hadFiveStr = nil
	_hadMaxStar = 0
end

--==================== CallBack ====================
--[[
	@des 	:选择回调
--]]
function selectCallBack(p_tag)
	require "script/ui/refining/RefiningSelectLayer"
	RefiningSelectLayer.createLayer()
end

-- 增加炼化预览 modify by lgx 20160510
--[[
	@desc 	: 炼化普通武将预览回调方法
	@param 	: pSelectedArr 选择的武将或装备等信息
	@param  : pData 炼化获得预览信息
	@return : 
--]]
function previewResolveCallBack( pSelectedArr, pData )
	local previewData = RefiningPreviewData.solveResolvePreviewData(pSelectedArr,pData)
	-- print("-----------------previewResolveCallBack-----------------")
	-- print_t(pSelectedArr)
	-- print_t(pData)
	-- print_t(previewData)
	-- print(_hadFiveStr)
	-- print(_hadMaxStar)
	-- print("-----------------previewResolveCallBack-----------------")
	-- 确认炼化回调
	local confirmCallback = function()
		-- 实际确认炼化
		RefiningController.sureToBreakDown()
	end
	ResolvePreviewDialog.showDialog(previewData, _hadFiveStr, _hadMaxStar, confirmCallback, -1000, 1000)
end

--[[
	@des 	:去炼化
--]]
function gotoBreakDown()
	local selectTable = RefiningData.getSelectArray()
	print("selectTable")
	print_t(selectTable)
	--如果没有选择，则提示
	if table.isEmpty(selectTable) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2419"))
		return
	end
	--记录是否有高星武将 或 高级装备
	_hadFiveStr = nil
	_hadMaxStar = 0

	--得到当前所在tag
	local curTag = RefiningData.getCurSelectTag()
	if curTag == RefiningData.kHeroTag then
		--武将
		--需要进行二次确认的五星武将
		local fiveStarTable = {}
		for i = 1,#selectTable do
			local starLevel = tonumber(selectTable[i].star_lv)
			if starLevel == 5 then
				-- 记录最高星级
				if (starLevel > _hadMaxStar) then
					_hadMaxStar = starLevel
				end
				table.insert(fiveStarTable,selectTable[i])
			end
		end
		if not table.isEmpty(fiveStarTable) then
			_hadFiveStr = GetLocalizeStringBy("lgx_1054")
		end
	elseif curTag == RefiningData.kEquipTag then
		--装备
		--如果道具背包满了
		if  ItemUtil.isPropBagFull(true) then
			return
		end

		local fiveItem = {}
		local sixItem = {}
		for i = 1,#selectTable do
			local itemQuality = tonumber(selectTable[i].itemDesc.quality)
			if itemQuality == 5 then
				-- 记录最高星级
				if (itemQuality > _hadMaxStar) then
					_hadMaxStar = itemQuality
				end
				table.insert(fiveItem,selectTable[i])
			elseif itemQuality == 6 then
				if (itemQuality > _hadMaxStar) then
					_hadMaxStar = itemQuality
				end
				table.insert(sixItem,selectTable[i])
			end
		end
		local needItem = {}
		needItem.fiveItem = fiveItem
		needItem.sixItem = sixItem

		if (not table.isEmpty(fiveItem)) or (not table.isEmpty(sixItem)) then
		 	_hadFiveStr = GetLocalizeStringBy("lgx_1055")
		end
	elseif curTag == RefiningData.kTreasureTag then
		--宝物
		--宝物背包满了
		if ItemUtil.isTreasBagFull(true) then
			return
		end

		local fiveGood = {}
		for i = 1,#selectTable do
			local itemQuality = tonumber(selectTable[i].itemDesc.quality)
			if itemQuality >= 5 then
 				local tmpTable = table.hcopy(selectTable[i],{})
				table.insert(fiveGood,tmpTable)
				local tableLength = table.count(fiveGood)
				fiveGood[tableLength].itemDesc.quality = ItemUtil.getTreasureQualityByItemInfo(tmpTable)
				fiveGood[tableLength].itemDesc.name = ItemUtil.getTreasureNameStrByItemInfo( tmpTable)
				-- 记录最高星级
				if (itemQuality > _hadMaxStar) then
					_hadMaxStar = itemQuality
				end
			end
		end
		if not table.isEmpty(fiveGood) then
			_hadFiveStr = GetLocalizeStringBy("lgx_1060")
		end
	elseif curTag == RefiningData.kClothTag then
		--时装
		--道具背包满了
		if ItemUtil.isPropBagFull(true) then
			return
		end

		local fiveCloth = {}
		for i = 1,#selectTable do
			local itemQuality = tonumber(selectTable[i].itemDesc.quality)
			if itemQuality >= 5 then
				-- 记录最高星级
				if (itemQuality > _hadMaxStar) then
					_hadMaxStar = itemQuality
				end
				table.insert(fiveCloth,selectTable[i])
			end
		end
		if not table.isEmpty(fiveCloth) then
			_hadFiveStr = GetLocalizeStringBy("lgx_1059")
		end
	elseif curTag == RefiningData.kGodTag then
		--神兵
		--神兵背包满了
		if ItemUtil.isGodWeaponBagFull(true) then
			return
		end
		--print("ItemUtil.isPropBagFull",ItemUtil.isPropBagFull() )
		if ItemUtil.isPropBagFull(true) then
			return
		end
		
		local fourGod = {}
		for i = 1,#selectTable do
			local itemQuality = tonumber(selectTable[i].itemDesc.quality)
			if itemQuality >= 4 then
				-- 记录最高星级
				if (itemQuality > _hadMaxStar) then
					_hadMaxStar = itemQuality
				end
				table.insert(fourGod,selectTable[i])
			end
		end
		if not table.isEmpty(fourGod) then
			_hadFiveStr = GetLocalizeStringBy("lgx_1056")
		end
	elseif curTag == RefiningData.kTokenTag then
		--符印
		--如果有紫色的 判断是否确认炼化
		local fiveToken = {}
		for i = 1,#selectTable do
			local itemQuality = tonumber(selectTable[i].itemDesc.quality)
			if itemQuality >= 5 then
				-- 记录最高星级
				if (itemQuality > _hadMaxStar) then
					_hadMaxStar = itemQuality
				end
				table.insert(fiveToken,selectTable[i])
			end
		end
		if not table.isEmpty(fiveToken) then
			_hadFiveStr = GetLocalizeStringBy("lgx_1058")
		end
	elseif curTag == RefiningData.kTallyTag then
		local fiveTally = {}
		for i = 1,#selectTable do
			local itemQuality = tonumber(selectTable[i].itemDesc.quality)
			if itemQuality > 4 then
				-- 记录最高星级
				if (itemQuality > _hadMaxStar) then
					_hadMaxStar = itemQuality
				end
				table.insert(fiveTally,selectTable[i])
			end
		end
		if not table.isEmpty(fiveTally) then
			_hadFiveStr = GetLocalizeStringBy("lgx_1057")
		end
	elseif curTag == RefiningData.kChariotTag then
		-- 战车
		local fiveChariot = {}
		for i = 1,#selectTable do
			local itemQuality = tonumber(selectTable[i].itemDesc.quality)
			if itemQuality > 5 then
				-- 记录最高星级
				if (itemQuality > _hadMaxStar) then
					_hadMaxStar = itemQuality
				end
				table.insert(fiveChariot,selectTable[i])
			end
		end
		if not table.isEmpty(fiveChariot) then
			_hadFiveStr = GetLocalizeStringBy("lgx_1084")
		end
	end
	-- 添加炼化预览 lgx 20160512
	RefiningPreviewController.previewResolve(previewResolveCallBack)
end

--[[
	@des 	:快速添加回调
	@param  :tag值
	@param  :按钮
--]]
function fastAddCallBack(p_tag,p_menuItem)
	local curTag = RefiningData.getCurSelectTag()
	RefiningData.resetChooseData()
	if p_tag ~= curTag then
		-- _fastContainer[curTag]:setBaseVisible(true)
		RefiningData.setCurSelectTag(p_tag)
		RefiningData.setFastBeginNum(0)
		-- _fastAddBtn:setBaseVisible(true)
	end
	--适合的table
	local fitTable = {}
	local tipString
	if p_tag == RefiningData.kHeroTag then
		fitTable = RefiningData.getHeroFit()
		tipString = GetLocalizeStringBy("key_2555")
	elseif p_tag == RefiningData.kEquipTag then
		fitTable = RefiningData.getEquipFit()
		tipString = GetLocalizeStringBy("key_1118")
	elseif p_tag == RefiningData.kTreasureTag then
		fitTable = RefiningData.getTreasFit()
		tipString = GetLocalizeStringBy("key_1875")
	elseif p_tag == RefiningData.kClothTag then
		fitTable = RefiningData.getClothFit()
		tipString = GetLocalizeStringBy("key_2448")
	elseif p_tag == RefiningData.kGodTag then
		fitTable = RefiningData.getGodFit()
		tipString = GetLocalizeStringBy("zzh_1232")
	elseif p_tag == RefiningData.kTokenTag then
		fitTable = RefiningData.getTokenFit()
		tipString = GetLocalizeStringBy("djn_172")
	elseif p_tag == RefiningData.kTallyTag then
		fitTable = RefiningData.getTallyFit()
		tipString = GetLocalizeStringBy("syx_1067")
	elseif p_tag == RefiningData.kChariotTag then
		-- 战车
		fitTable = RefiningData.getChariotFit()
		tipString = GetLocalizeStringBy("lgx_1085")
	end
	print("fitTable")
	print_t(fitTable)
	--如果选择为空
	if table.isEmpty(fitTable) then
		AnimationTip.showTip(tipString)
	else
		--新按钮显示换一组
		_fastAddBtn:setBaseVisible(false)
		-- _fastContainer[p_tag]:setBaseVisible(false)
		local beginPos = RefiningData.getFastBeginPos()
		local selectBeginPos = #fitTable - beginPos
		for i = selectBeginPos,selectBeginPos - kSelectNum + 1,-1 do
			RefiningData.addCurChooseNum(1)
			RefiningData.addFastBeginNum(1)
			RefiningData.addCurChooseId(i)
			RefiningData.addSelectArray(fitTable[i])
			if i <= 1 then
				RefiningData.setFastBeginNum(0)
				break
			end
		end
	end

	for i = 1,kSelectNum do
		_menuItemContainer[i]:removeFromParentAndCleanup(true)
		_menuItemContainer[i] = nil
	end
	_menuItemContainer = {}
	createChooseMenu()
end

--==================== UI ====================
--[[
	@des 	:按钮不可见
--]]
function menuItemUnVisible()
	for i = 1,#_menuItemContainer do
		_menuItemContainer[i]:setVisible(false)
	end
end

--[[
	@des 	:清除按钮上有图片的显示
--]]
function clearItemSprite()
	--本来可是只清除已选择的，结果清除完闪烁不同步，所以都删了吧
	for i = 1,kSelectNum do
		_menuItemContainer[i]:removeFromParentAndCleanup(true)
		_menuItemContainer[i] = nil
		_menuItemContainer[i] = RefiningUtils.createSelectMenuItem()
		_menuItemContainer[i]:setAnchorPoint(ccp(0.5,0.5))
		_menuItemContainer[i]:setPosition(ccp(kMenuPosXTable[i],kMenuPosYTable[i]))
		_menuItemContainer[i]:registerScriptTapHandler(selectCallBack)
		_menuItemContainer[i]:setScale(g_fElementScaleRatio)
		_baseMenu:addChild(_menuItemContainer[i])
	end
end

--[[
	@des 	:清除并显示按钮
--]]
function clearAndShowItem()
	clearItemSprite()
end

--[[
	@des 	:设置按钮不可点
--]]
function disableMenuItem()
	_resolveMenuItem:setEnabled(false)
	_fastAddBtn:setMenuEnable(false)
	for k,btn in pairs(_fastContainer) do
		-- v:setMenuEnable(false)
		btn:setEnabled(false)
	end
end

--[[
	@des 	:设置按钮可点
--]]
function enableMenuItem()
	_resolveMenuItem:setEnabled(true)
	_fastAddBtn:setMenuEnable(true)
	for k,v in pairs(_fastContainer) do
		-- 如果当前tag是选择的
		if k == RefiningData.getCurSelectTag() then
			v:setEnabled(false)
		else
			v:setEnabled(true)
		end
	end
end

--[[
	@des 	:创建选择按钮
--]]
function createChooseMenu()
	--选择table
	local selectTable = RefiningData.getSelectArray()

	for i = 1,kSelectNum do
		local menuItemSprite = RefiningUtils.createSelectMenuItem(selectTable[i])
		menuItemSprite:setAnchorPoint(ccp(0.5,0.5))
		menuItemSprite:setPosition(ccp(kMenuPosXTable[i],kMenuPosYTable[i]))
		menuItemSprite:registerScriptTapHandler(selectCallBack)
		menuItemSprite:setScale(g_fElementScaleRatio)
		_baseMenu:addChild(menuItemSprite)

		--加入容器中
		table.insert(_menuItemContainer,menuItemSprite)
	end
end

--[[
	@des 	:创建炼化按钮
--]]
function createResolveMenu()
	_resolveMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,73),GetLocalizeStringBy("key_3040"),ccc3(0xfe,0xdb, 0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	_resolveMenuItem:setAnchorPoint(ccp(0.5,0.5))
    -- _resolveMenuItem:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*550/960 + 20))
    _resolveMenuItem:setPosition(ccp(g_winSize.width * 0.3,200 * g_fScaleY))
    _resolveMenuItem:registerScriptTapHandler(gotoBreakDown)
    _resolveMenuItem:setScale(g_fElementScaleRatio)
	_baseMenu:addChild(_resolveMenuItem)
end

--[[
	@des 	:创建几个快速选择按钮
--]]
-- function createFastMenuItem()
-- 	local btnInfoTable = {
-- 							{ nameString = GetLocalizeStringBy("key_1524"),headPath = "images/recycle/btn/hero.png",
-- 							  anchor = ccp(0,0.5),pos = ccp(0,g_winSize.height*250/960),tags = RefiningData.kHeroTag },
-- 							{ nameString = GetLocalizeStringBy("djn_173"),headPath = "images/recycle/btn/rune.png",
-- 							  anchor = ccp(0.5,0.5),pos = ccp(g_winSize.width*0.5,g_winSize.height*250/960),tags = RefiningData.kTokenTag },
-- 							{ nameString = GetLocalizeStringBy("key_3286"),headPath = "images/recycle/btn/item.png",
-- 							  anchor = ccp(1,0.5),pos = ccp(g_winSize.width,g_winSize.height*250/960),tags = RefiningData.kEquipTag },
-- 							{ nameString = GetLocalizeStringBy("key_2166"),headPath = "images/recycle/btn/treasure.png",
-- 							  anchor = ccp(0,0.5),pos = ccp(0,g_winSize.height*170/960),tags = RefiningData.kTreasureTag },
-- 							{ nameString = GetLocalizeStringBy("key_1136"),headPath = "images/recycle/btn/cloth.png",
-- 							  anchor = ccp(1,0.5),pos = ccp(g_winSize.width,g_winSize.height*170/960),tags = RefiningData.kClothTag },
-- 							{ nameString = GetLocalizeStringBy("zzh_1231"),headPath = "images/recycle/btn/god.png",
-- 							  anchor = ccp(0.5,0.5),pos = ccp(g_winSize.width*0.5,g_winSize.height*170/960),tags = RefiningData.kGodTag },
--   							{ nameString = GetLocalizeStringBy("syx_1068"),headPath = "images/recycle/btn/bingfu.png",
-- 							  anchor = ccp(0.5,0.5),pos = ccp(g_winSize.width*0.5,g_winSize.height*330/960),tags = RefiningData.kTallyTag }
-- 						 }
-- 	--六个快速添加按钮
-- 	for i = 1,#btnInfoTable do
-- 		local fastInfo = btnInfoTable[i]
-- 		local newFastMenuItem = FastAddMenuItem:new()
-- 		newFastMenuItem:createMenuItem(fastInfo.nameString,fastInfo.headPath)
-- 		newFastMenuItem:registCallBack(fastAddCallBack)
-- 		newFastMenuItem:setAnchorPosScale(fastInfo.anchor,fastInfo.pos,g_fElementScaleRatio)
-- 		newFastMenuItem:addChildToMenu(_baseMenu,fastInfo.tags)
-- 		--如果当前所在这个标签，且选择的不为空
-- 		if (RefiningData.getCurSelectTag() == fastInfo.tags) and (not table.isEmpty(RefiningData.getSelectArray())) then
-- 			newFastMenuItem:setBaseVisible(false)
-- 		else
-- 			newFastMenuItem:setBaseVisible(true)
-- 		end
-- 		_fastContainer[fastInfo.tags] = newFastMenuItem
-- 	end
-- end
--[[
	@des 	:创建上拉菜单
--]]
function createPullUpMenu( ... )
	_pullMenuArrow = CCSprite:create("images/common/arrow_panel.png")
	_pullMenuArrow:setAnchorPoint(ccp(0.5,0.5))
	_pullMenuArrow:setFlipY(true)
	_pullMenuArrow:setPosition(ccp(g_winSize.width - 28 * g_fBgScaleRatio,(225 - 40) * g_fScaleY))
	_pullMenuArrow:setScale(g_fScaleY * 0.85)
	_layer:addChild(_pullMenuArrow)
	createPullBtn(kPullUp)
	--菜单箭头
	local bgSize = CCSizeMake(60,500 + 70)
	local pullMenuBg = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
	pullMenuBg:setContentSize(bgSize)
	pullMenuBg:setAnchorPoint(ccp(0.5,0))
	pullMenuBg:setPosition(ccpsprite(0.5,1,_pullMenuArrow))
	_pullMenuArrow:addChild(pullMenuBg)
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	pullMenuBg:addChild(menu)
	local btnInfoTable = {
							{ nameString = GetLocalizeStringBy("key_1524"),imagePathN = "images/recycle/btn/hero_btn_n.png",
							  imagePathH = "images/recycle/btn/hero_btn_h.png",pos = ccp(0,g_winSize.height*250/960),tags = RefiningData.kHeroTag },
							{ nameString = GetLocalizeStringBy("djn_173"),imagePathN = "images/recycle/btn/rune_btn_n.png",
							  imagePathH = "images/recycle/btn/rune_btn_h.png",pos = ccp(g_winSize.width*0.5,g_winSize.height*250/960),tags = RefiningData.kTokenTag },
							{ nameString = GetLocalizeStringBy("key_3286"),imagePathN = "images/recycle/btn/item_btn_n.png",
							  imagePathH = "images/recycle/btn/item_btn_h.png",pos = ccp(g_winSize.width,g_winSize.height*250/960),tags = RefiningData.kEquipTag },
							{ nameString = GetLocalizeStringBy("key_2166"),imagePathN = "images/recycle/btn/treasure_btn_n.png",
							  imagePathH = "images/recycle/btn/treasure_btn_h.png",pos = ccp(0,g_winSize.height*170/960),tags = RefiningData.kTreasureTag },
							{ nameString = GetLocalizeStringBy("key_1136"),imagePathN = "images/recycle/btn/cloth_btn_n.png",
							  imagePathH = "images/recycle/btn/cloth_btn_h.png",pos = ccp(g_winSize.width,g_winSize.height*170/960),tags = RefiningData.kClothTag },
							{ nameString = GetLocalizeStringBy("zzh_1231"),imagePathN = "images/recycle/btn/god_btn_n.png",
							  imagePathH = "images/recycle/btn/god_btn_h.png",pos = ccp(g_winSize.width*0.5,g_winSize.height*170/960),tags = RefiningData.kGodTag },
  							{ nameString = GetLocalizeStringBy("syx_1068"),imagePathN = "images/recycle/btn/bingfu_btn_n.png",
							  imagePathH = "images/recycle/btn/bingfu_btn_h.png",pos = ccp(g_winSize.width*0.5,g_winSize.height*330/960),tags = RefiningData.kTallyTag },
							-- 战车
							{ nameString = GetLocalizeStringBy("lgx_1086"),imagePathN = "images/recycle/btn/chariot_btn_n.png",
							  imagePathH = "images/recycle/btn/chariot_btn_h.png",pos = ccp(g_winSize.width*0.5,g_winSize.height*330/960),tags = RefiningData.kChariotTag }
						 }
	--六个按钮
	for i,btnInfo in ipairs(btnInfoTable) do
		local btn = CCMenuItemImage:create(btnInfo.imagePathN,btnInfo.imagePathN,btnInfo.imagePathH)
		btn:setAnchorPoint(ccp(0.5,0.5))
		btn:setPosition(ccp(bgSize.width / 2,(465 + 70 - 70 * (i - 1))))
		btn:registerScriptTapHandler(createFastMenuItem)
		menu:addChild(btn,1,btnInfo.tags)
		_fastContainer[btnInfo.tags] = btn
	end
end

-- 设置上拉菜单的状态
function setPullMenuStatus( pTag )
	local desScale = 0
	if pTag == kPullUp then
		desScale = 1
	end
	createPullBtn(pTag)
	local action = CCScaleTo:create(0.2,desScale * g_fScaleY * 0.85)
	_pullMenuArrow:runAction(action)
end

function createPullBtn( pType )
	if not tolua.isnull(_pullBtn) then
		_pullBtn:removeFromParentAndCleanup(true)
		_pullBtn = nil
	end
	local btnInfoMap = {
							[kPullUp] = {imagePath = "images/recycle/btn/pull_btn_up.png",tag = kPullDown},
							[kPullDown] = {imagePath = "images/recycle/btn/pull_btn_down.png",tag = kPullUp}
						}
	local btnInfo = btnInfoMap[pType]
	local imagePath = btnInfo.imagePath
	_pullBtn = CCMenuItemImage:create(imagePath,imagePath)
	_pullBtn:setAnchorPoint(ccp(1,0.5))
	_pullBtn:setPosition(ccp(g_winSize.width,(200 - 40) * g_fScaleY))
	_pullBtn:setScale(g_fScaleY)
	_baseMenu:addChild(_pullBtn,100,btnInfo.tag)
	_pullBtn:registerScriptTapHandler(setPullMenuStatus)
end

function createFastMenuItem( p_tag )
	local curTag = RefiningData.getCurSelectTag()
	if p_tag then
		if p_tag ~= curTag then
			RefiningController.resetChooseData(p_tag)
			clearItemSprite()
			_fastContainer[curTag]:setEnabled(true)
		end
	else
		p_tag = curTag
	end
	if not tolua.isnull(_fastAddBtnMenu) then
		_fastAddBtnMenu:removeFromParentAndCleanup(true)
		_fastAddBtnMenu = nil
	end
	_fastAddBtnMenu = CCMenu:create()
	_fastAddBtnMenu:setAnchorPoint(ccp(0,0))
	_fastAddBtnMenu:setPosition(ccp(0,0))
	_layer:addChild(_fastAddBtnMenu)

	local btnInfoTable = {
							[RefiningData.kHeroTag] 	= { nameString = GetLocalizeStringBy("key_1524"),headPath = "images/recycle/btn/hero.png",
						  									anchor = ccp(0,0.5),pos = ccp(0,g_winSize.height*250/960),tags = RefiningData.kHeroTag },
							[RefiningData.kTokenTag]	= { nameString = GetLocalizeStringBy("djn_173"),headPath = "images/recycle/btn/rune.png",
						  							  		anchor = ccp(0.5,0.5),pos = ccp(g_winSize.width*0.5,g_winSize.height*250/960),tags = RefiningData.kTokenTag },
							[RefiningData.kEquipTag]	= { nameString = GetLocalizeStringBy("key_3286"),headPath = "images/recycle/btn/item.png",
						  							  		anchor = ccp(1,0.5),pos = ccp(g_winSize.width,g_winSize.height*250/960),tags = RefiningData.kEquipTag },
							[RefiningData.kTreasureTag]	= { nameString = GetLocalizeStringBy("key_2166"),headPath = "images/recycle/btn/treasure.png",
						  							  		anchor = ccp(0,0.5),pos = ccp(0,g_winSize.height*170/960),tags = RefiningData.kTreasureTag },
							[RefiningData.kClothTag]	= { nameString = GetLocalizeStringBy("key_1136"),headPath = "images/recycle/btn/cloth.png",
						  							  		anchor = ccp(1,0.5),pos = ccp(g_winSize.width,g_winSize.height*170/960),tags = RefiningData.kClothTag },
							[RefiningData.kGodTag]	    = { nameString = GetLocalizeStringBy("zzh_1231"),headPath = "images/recycle/btn/god.png",
						  							  		anchor = ccp(0.5,0.5),pos = ccp(g_winSize.width*0.5,g_winSize.height*170/960),tags = RefiningData.kGodTag },
							[RefiningData.kTallyTag]	= { nameString = GetLocalizeStringBy("syx_1068"),headPath = "images/recycle/btn/bingfu.png",
						  							  		anchor = ccp(0.5,0.5),pos = ccp(g_winSize.width*0.5,g_winSize.height*330/960),tags = RefiningData.kTallyTag },
						  	-- 战车
						  	[RefiningData.kChariotTag]	= { nameString = GetLocalizeStringBy("lgx_1086"),headPath = "images/recycle/btn/chariot.png",
						  							  		anchor = ccp(0.5,0.5),pos = ccp(g_winSize.width*0.5,g_winSize.height*330/960),tags = RefiningData.kChariotTag }
					 }
	local fastInfo = btnInfoTable[p_tag]
	_fastAddBtn = FastAddMenuItem:new()
	_fastAddBtn:createMenuItem(fastInfo.nameString,fastInfo.headPath)
	_fastAddBtn:registCallBack(fastAddCallBack)
	_fastAddBtn:setAnchorPosScale(ccp(0.5,0.5),ccp(g_winSize.width * 0.7,200 * g_fScaleY),g_fElementScaleRatio)
	_fastAddBtn:addChildToMenu(_fastAddBtnMenu,fastInfo.tags)
	_fastAddBtn:setBaseVisible(true)
	if (RefiningData.getCurSelectTag() == fastInfo.tags) and (not table.isEmpty(RefiningData.getSelectArray())) then
		_fastAddBtn:setBaseVisible(false)
	else
		_fastAddBtn:setBaseVisible(true)
	end
	_fastContainer[fastInfo.tags]:setEnabled(false)
end

--[[
	@des 	:创建UI
--]]
function createUI()
	--创建选择按钮
	createChooseMenu()
	--创建炼化按钮
	createResolveMenu()
	--创建上拉菜单
	createPullUpMenu()
	--创建快速选择按钮
	createFastMenuItem()
end

--[[
	@des 	:创建最基础的layer和menu
--]]
function createBaseUI()
	--背景layer
	_layer = CCLayer:create()
	--基础menu
	_baseMenu = CCMenu:create()
	_baseMenu:setAnchorPoint(ccp(0,0))
	_baseMenu:setPosition(ccp(0,0))
	_layer:addChild(_baseMenu)
end

--==================== Entrance ====================
--[[
	@des 	:初始化函数
	@return :创建好的layer
--]]
function createLayer()
	init()

	RefiningData.setFastBeginNum(0)

	--创建最基本的layer和menu
	createBaseUI()

	--创建UI
	createUI()

	return _layer
end