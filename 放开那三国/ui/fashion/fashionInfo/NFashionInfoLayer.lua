-- Filename: NFashionInfoLayer.lua
-- Author: zhangqiang
-- Date: 2016-05-30
-- Purpose: 时装信息UI

module("NFashionInfoLayer", package.seeall)

_kMenuRelativePriority = -2
_kScrollViewRelativePriority = -1

_kBackgroundZOrder = 1
_kMenuLayerZOrder = 10
_kMenuBarBgZOrder = 5

_kBottomBarChangeBtnTag     = 1        --更换按钮
_kBottomBarUnequipBtnTag    = 2        --卸下按钮
_kBottomBarStrengthenBtnTag = 3        --强化按钮
_kBottomBarCloseBtnTag      = 4        --关闭按钮 

_fnOnEnter = nil
_fnOnExit = nil
_fnTapClose = nil
_fnTapChange = nil
_fnTapUnequip = nil
_fnTapStrengthen = nil

--UI
_nBaseTouchPriority = nil
_nBaseZOrder = nil
_szAdapt = nil
_szBullet = nil
_szBg = nil
_lyMain  = nil
_menuLayer = nil
_spBottomBarBg = nil
_tbBottomBarBtns = nil
_spMidInfoBg = nil
_svInfoScroll = nil
_lyContainer = nil

--[[
	desc: 显示UI
	param:
	return:
--]]
function show( ... )
	if _lyMain ~= nil then
		local scene = CCDirector:sharedDirector():getRunningScene()
		scene:addChild(_lyMain, _nBaseZOrder)
	end
end

--[[
	desc: 关闭界面
	param:
	return:
--]]
function close( ... )
	if _lyMain ~= nil then
		_lyMain:removeFromParentAndCleanup(true)
		_lyMain = nil
	end
end


--[[
	desc: 关闭界面
	param:
	return:
--]]
function deinit( ... )
	_lyMain  = nil
	_menuLayer = nil
	_spBottomBarBg = nil
	_tbBottomBarBtns = nil
	_spMidInfoBg = nil
	_svInfoScroll = nil
	_lyContainer = nil
end


--[[
	desc: 创建显示层
	param:
	return:
--]]
function init( pTouchPriority, pZOrder )
	initData()
	initUI(pTouchPriority, pZOrder)
end

--[[
	desc: 初始化数据
	param:
	return:
--]]
function initData( ... )
	_fnOnEnter = nil
	_fnOnExit = nil
	_fnTapClose = nil
	_fnTapChange = nil
	_fnTapUnequip = nil
	_fnTapStrengthen = nil

end

--[[
	desc: 刷新整个界面
	param:
	return:
--]]
function refreshAll( ... )
	reloadScrollView()
	refreshBottomBarBtns()
end

--[[
	desc: 初始化UI
	param:
	return:
--]]
function initUI( pTouchPriority, pZOrder  )
	_nBaseTouchPriority = pTouchPriority or -999
	_szAdapt = CCSizeMake(640, g_winSize.height/g_fScaleX)   --用于适配的尺寸
	_szBullet = BulletinLayer.getLayerContentSize()
	print("initUI( pTouchPriority, pZOrder  )pTouchPriority", pTouchPriority, " pZOrder", pZOrder)
	_nBaseZOrder = pZOrder or 1000


	--创建屏蔽层
	-- _lyMain = MainScene.createBaseLayer(nil, false, false, true)   --屏蔽层
	MainScene.setMainSceneViewsVisible(false, false, true)
	_lyMain = CCLayer:create()
	_lyMain:setScale(g_fScaleX)
	_lyMain:registerScriptHandler(function ( pEventName )
		onNodeEvent(pEventName)
	end)
	_lyMain:registerScriptTouchHandler(function ( pEventType, pTouchX, pTouchY )
		return true
	end, false, _nBaseTouchPriority, true)
	_lyMain:setTouchEnabled(true)

	-- --设置屏蔽层颜色
	-- local mainLayer = tolua.cast(_lyMain, "CCLayerColor")
	-- mainLayer:setColor(ccc3(0, 0, 0))
	-- mainLayer:setOpacity(125)

	--创建底部的button menu
	_spBottomBarBg = CCSprite:create("images/common/sell_bottom.png")
	_spBottomBarBg:setAnchorPoint(ccp(0.5, 0))
	_spBottomBarBg:setPosition(_szAdapt.width/2,0)
	_lyMain:addChild(_spBottomBarBg, _kMenuBarBgZOrder)

	--计算背景大小
	_szBg = CCSizeMake(_szAdapt.width, _szAdapt.height - _szBullet.height - _spBottomBarBg:getContentSize().height + 32)

	--创建信息背景
	_spMidInfoBg = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	_spMidInfoBg:setContentSize(_szBg)
	_spMidInfoBg:setAnchorPoint(ccp(0.5, 0.5))
	_spMidInfoBg:setPosition(_szBg.width/2, _szAdapt.height - _szBullet.height - _szBg.height/2)
	_lyMain:addChild(_spMidInfoBg, _kBackgroundZOrder)

	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(_spMidInfoBg:getContentSize().width*0.5, _spMidInfoBg:getContentSize().height))
	_spMidInfoBg:addChild(topSprite, 2)
	-- topSprite:setScale(myScale)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1073"), g_sFontPangWa, 33, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(topSprite:getContentSize().width/2, topSprite:getContentSize().height*0.6))
    topSprite:addChild(titleLabel)

    -- menu 层
	_menuLayer = CCMenu:create()
	_menuLayer:setAnchorPoint(ccp(0, 0))
	_menuLayer:setPosition(0, 0)
	_menuLayer:setContentSize(_szAdapt)
	_lyMain:addChild(_menuLayer, _kMenuLayerZOrder)

    --关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(_szAdapt.width - closeBtn:getContentSize().width*0.4, _szAdapt.height - _szBullet.height - closeBtn:getContentSize().height*0.4)
    closeBtn:registerScriptTapHandler(function ( pTag, pSender )
    	if _fnTapClose then
    		_fnTapClose(pTag, pSender)
    	end
    end)
	_menuLayer:addChild(closeBtn)
	_menuLayer:setTouchPriority(_nBaseTouchPriority + _kMenuRelativePriority)

	--底部按钮
	createBottomBarBtns()
	
	--创建信息滚动视图
	createInfoScrollView()
	-- reloadScrollView()
end

--[[
	desc: 创建底部按钮
	param:
	return:
--]]
function createBottomBarBtns( ... )
	--去掉当前的按钮
	if not table.isEmpty(_tbBottomBarBtns) then
		for k, v in pairs(_tbBottomBarBtns) do
			v:removeFromParentAndCleanup(true)
		end
	end
	_tbBottomBarBtns = {}

	local tbBtnData = {
		[1] = {"images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(200, 73), GetLocalizeStringBy("key_2761"), _kBottomBarChangeBtnTag},
		[2] = {"images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(200, 73), GetLocalizeStringBy("lic_1701"), _kBottomBarUnequipBtnTag},
		[3] = {"images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(200, 73), GetLocalizeStringBy("key_1269"), _kBottomBarStrengthenBtnTag},
		[4] = {"images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(200, 73), GetLocalizeStringBy("key_1284"), _kBottomBarCloseBtnTag},
	}
	-- local nBottomBarBtnX, nSpace = 5, 16
	for k, v in ipairs(tbBtnData) do
		local btn = LuaCC.create9ScaleMenuItem(v[1],v[2],v[3],v[4],ccc3(0xfe, 0xdb, 0x1c),36,g_sFontPangWa,2, ccc3(0x00, 0x00, 0x00))
		btn:setTag(v[5])
		btn:setVisible(false)
		btn:setAnchorPoint(ccp(0,0))
		-- btn:setPosition(nBottomBarBtnX, 10)
		btn:registerScriptTapHandler(function ( pTag, pSender )
			tapBottomBarBtn(pTag, pSender)
		end)
		_menuLayer:addChild(btn)

		-- nBottomBarBtnX = nBottomBarBtnX + v[3].width + nSpace

		_tbBottomBarBtns[v[5]] = btn
	end
end

--[[
	desc: 刷新底部按钮
	param:
	return:
--]]
function refreshBottomBarBtns( ... )
	if table.isEmpty(_tbBottomBarBtns) then
		return
	end

	--先初始化成隐藏状态
	for k, v in pairs(_tbBottomBarBtns) do
		v:setVisible(false)
	end

	--取出需要显示的按钮
	local nShowType = NFashionInfoData.getShowType()
	local bOnHero   = NFashionInfoData.isOnHero()
	local tbShowBtns = {}
	if nShowType == NFashionInfoData._kFashionInfoOnly then
		--关闭按钮
		tbShowBtns = {
			[1]=_kBottomBarCloseBtnTag
		}
	elseif nShowType == NFashionInfoData._kFashionInfoOperation and not bOnHero then
		--强化、关闭
		tbShowBtns = {
			[1]=_kBottomBarStrengthenBtnTag, [2]=_kBottomBarCloseBtnTag, 
		}
	elseif nShowType == NFashionInfoData._kFashionInfoOperation and bOnHero then
		--更换、卸下、强化
		tbShowBtns = {
			[1]=_kBottomBarChangeBtnTag, [2]=_kBottomBarUnequipBtnTag, [3]=_kBottomBarStrengthenBtnTag,
		}
	elseif nShowType == NFashionInfoData._kFashionInfoManual then
		local bChangeShow = NFashionInfoData.getChangeShow()
		local bUnequipShow = NFashionInfoData.getUnequipShow()
		local bStrengthenShow = NFashionInfoData.getStrengthenShow()
		local bCloseShow = NFashionInfoData.getCloseShow()

		tbShowBtns[#tbShowBtns + 1] = (bChangeShow and bOnHero) and _kBottomBarChangeBtnTag or nil
		tbShowBtns[#tbShowBtns + 1] = (bUnequipShow and bOnHero) and _kBottomBarUnequipBtnTag or nil
		tbShowBtns[#tbShowBtns + 1] = bStrengthenShow and _kBottomBarStrengthenBtnTag or nil
		tbShowBtns[#tbShowBtns + 1] = bCloseShow and _kBottomBarCloseBtnTag or nil
	else

	end

	--重新计算位置
	local nNum = table.count(tbShowBtns)
	if nNum > 0 then
		local nUnitWidth = _szAdapt.width / nNum
		local nOriginX, nOriginY = (nUnitWidth-200)*0.5, 10
		for nIdx, nTag in ipairs(tbShowBtns) do
			local btn = _tbBottomBarBtns[nTag]
			if btn ~= nil then
				btn:setVisible(true)
				btn:setAnchorPoint(ccp(0,0))
				btn:setPosition(nOriginX, nOriginY)
				btn:setTag(nTag)

				nOriginX = nOriginX + nUnitWidth
			end
		end
	end
end

--[[
	desc: 创建信息滚动视图
	param:
	return:
--]]
function createInfoScrollView( ... )
	if _spMidInfoBg == nil then
		return
	end

	_svInfoScroll = CCScrollView:create()
	_svInfoScroll:setViewSize(CCSizeMake(_szBg.width, _szBg.height - 72))
	_svInfoScroll:setTouchPriority(_nBaseTouchPriority + _kScrollViewRelativePriority)
	_svInfoScroll:setBounceable(true)
	_svInfoScroll:setDirection(kCCScrollViewDirectionVertical)
	_svInfoScroll:setPosition(0, 20)
	_spMidInfoBg:addChild(_svInfoScroll)

	_lyContainer = CCLayer:create()
	_svInfoScroll:setContainer(_lyContainer)

end

--[[
	desc: 　刷新信息滚动视图
	param:
	return:
--]]
function reloadScrollView( ... )
	if _svInfoScroll == nil then
		return
	end

	local lyContainer = _svInfoScroll:getContainer()
	lyContainer:removeAllChildrenWithCleanup(true)

	local szContainer = CCSizeMake(_szAdapt.width, 0)

	local tbCreateFunc = {
		[1] = createFigure,                --创建时装图标
		[2] = createCurAttr,               --创建当前属性
		[3] = createStrengthenIncrement,   --创建强化成长属性
		[4] = createTalent,                --创建时装天赋
		[5] = createBrief,                 --创建简介
	}
	local nMaxFuncNum = #tbCreateFunc
	for i = nMaxFuncNum, 1, -1 do
		local spNode = tbCreateFunc[i]()
		if spNode ~= nil then
			spNode:setAnchorPoint(ccp(0, 0))
			spNode:setPosition(0, szContainer.height)
			lyContainer:addChild(spNode)

			local nTopSpace = 15
			if tbCreateFunc[i] ~= createFigure and tbCreateFunc[i] ~= createCurAttr then
				nTopSpace = 3
			end

			szContainer.height = szContainer.height + spNode:getContentSize().height + nTopSpace
		end
	end

	lyContainer:setContentSize(szContainer)
	local cpOffset = ccp(0, _svInfoScroll:getViewSize().height - szContainer.height)
	_svInfoScroll:setContentOffset(cpOffset)
end

--[[
	desc: 重新加载图片
	param:
	return:
--]]
function loadFile( pSprite, pFile )
	if pSprite == nil or pFile == nil then
		print("load file ========== ", pSprite, pFile)
		return
	end

	local sprite = CCSprite:create(pFile)
	if sprite ~= nil then
		pSprite:setTexture(sprite:getTexture())
		pSprite:setTextureRect(sprite:boundingBox())
	end
end

--[[
	desc: 创建星星
	param:
	return:
--]]
function createStars( pSolidStarNum )
	--星数
	local spStarBg = CCSprite:create("images/shop/star_bottom.png")

	local nNum = tonumber(pSolidStarNum or 0)
	local nPositionX, nPositionY = 50, 38
	local tbPositionX = {50, 85, 120, 155, 189, 224, 260}
	local tbPositionY = {38, 40,  42,  43,  42,  40,  38}
	if nNum > 0 then
		for i = 1, nNum do
			nPositionX = tbPositionX[i] or tbPositionX[1]
			nPositionY = tbPositionY[i] or tbPositionY[1]
			local spStar = CCSprite:create("images/digCowry/star.png")
			spStar:setAnchorPoint(ccp(0.5,0.5))
			spStar:setPosition(nPositionX, nPositionY)
			spStarBg:addChild(spStar)

			-- nPositionX = nPositionX + 35
		end
	end

	return spStarBg
end

--[[
	desc: 创建时装图标
	param:
	return:
--]]
function createFigure( ... )
	local tbData = NFashionInfoData.getFashionBaseInfo()

	local spNode = CCSprite:create()
	local szNode = CCSizeMake(_szAdapt.width, 443)

	--背景
	local sp9Bg = CCScale9Sprite:create(CCRectMake(36, 36, 3, 3), "images/item/equipinfo/info_bg.png")
	local szBg = CCSizeMake(585, 441)
	sp9Bg:setContentSize(szBg)
	sp9Bg:setAnchorPoint(ccp(0.5,0.5))
	sp9Bg:setPosition(szNode.width*0.5, szNode.height*0.5)
	spNode:addChild(sp9Bg)

	--星数
	local nStarNum = table.isEmpty(tbData) and 0 or tbData.quality
	local spStarBg = createStars(nStarNum)
	spStarBg:setAnchorPoint(ccp(0.5, 0.5))
	spStarBg:setPosition(szBg.width*0.5, 385)
	sp9Bg:addChild(spStarBg, 10)

	--时装图片
	local spFashion = CCSprite:create()
	spFashion:setAnchorPoint(ccp(0.5,0.5))
	spFashion:setPosition(szBg.width*0.5, szBg.height*0.5)
	sp9Bg:addChild(spFashion, 5)

	if tbData ~= nil and tbData.icon_big ~= nil then
		-- loadFile(spFashion, "images/base/fashion/big/big_nvzhu_shizhuang_1.png")
		loadFile(spFashion, tbData.icon_big)
	end

	--品级
	local spScore = CCSprite:create("images/common/pin.png")
	spScore:setAnchorPoint(ccp(0, 0))
	spScore:setPosition(70,27)
	sp9Bg:addChild(spScore)

	-- local lbScore = CCRenderLabel:create("999", g_sFontName, 25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    -- lbScore:setColor(ccc3(0xff, 0xf6, 0x00))
    local nScore = table.isEmpty(tbData) and 0 or tbData.score
    local lbScore = LuaCC.createSpriteOfNumbers("images/item/equipnum", nScore, 17)
    lbScore:setAnchorPoint(ccp(0,0))
    lbScore:setPosition(145, 33)
    sp9Bg:addChild(lbScore)

	--名字
	local spNameBg = CCSprite:create("images/treasure/name_bg.png")
	spNameBg:setAnchorPoint(ccp(0.5, 0.5))
	spNameBg:setPosition(szBg.width*0.5, 45)
	sp9Bg:addChild(spNameBg)

	local sName = table.isEmpty(tbData) and "----" or tbData.name
	local c3NameColor = HeroPublicLua.getCCColorByStarLevel(nStarNum)
	local lbName = CCRenderLabel:create(sName, g_sFontPangWa, 28, 2, ccc3(0x00, 0x00, 0x00), type_stroke)
	lbName:setColor(c3NameColor)
	lbName:setAnchorPoint(ccp(0.5, 0.5))
	lbName:setPosition(spNameBg:getContentSize().width*0.5, spNameBg:getContentSize().height*0.5)
	spNameBg:addChild(lbName)

	--强化等级
	local sDressLevel = table.isEmpty(tbData) and "+0" or ("+" .. tbData.dressLevel)
	local lbStrengtenLv = CCRenderLabel:create(sDressLevel, g_sFontPangWa, 28, 2, ccc3(0, 0, 0), type_stroke)
	lbStrengtenLv:setColor(ccc3(0,255,66))
	lbStrengtenLv:setAnchorPoint(ccp(0, 0.5))
	lbStrengtenLv:setPosition(lbName:getPositionX() + lbName:getContentSize().width*0.5 + 10, spNameBg:getContentSize().height*0.5)
	spNameBg:addChild(lbStrengtenLv)

	spNode:setContentSize(szNode)
	return spNode
end

--[[
	desc: 创建基础UI(带有标题的背景)
	param:
	return:
--]]
function createBgWithTitle( pTitle )
	local spNode = CCSprite:create()

	--背景
	local sp9Bg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	local szBg = CCSizeMake(598, 30)
	sp9Bg:setContentSize(szBg)
	sp9Bg:setAnchorPoint(ccp(0,1))
	spNode:addChild(sp9Bg)

	--标题
	local sp9TitleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	sp9TitleBg:setAnchorPoint(ccp(0, 0.5))
	sp9TitleBg:setPosition(0, szBg.height)
	sp9Bg:addChild(sp9TitleBg)

	local lbTitle = CCLabelTTF:create( pTitle or "title", g_sFontName, 25)
	lbTitle:setColor(ccc3(0, 0, 0))
	lbTitle:setAnchorPoint(ccp(0, 0.5))
	lbTitle:setPosition(15, sp9TitleBg:getContentSize().height*0.5)
	sp9TitleBg:addChild(lbTitle)

	--设置标题背景宽
	sp9TitleBg:setContentSize(CCSizeMake(lbTitle:getContentSize().width+40, sp9TitleBg:getContentSize().height))
	--设置整个节点的宽高
	spNode:setContentSize(CCSizeMake(_szAdapt.width, sp9TitleBg:getPositionY() + sp9TitleBg:getContentSize().height * 0.5))

	--设置背景的位置
	sp9Bg:setPosition((spNode:getContentSize().width-szBg.width)*0.5, szBg.height)


	return spNode, sp9TitleBg, sp9Bg
end

--[[
	desc: 创建当前属性
	param:
	return:
--]]
function createCurAttr( ... )
	local spNode, sp9TitleBg, sp9Bg = createBgWithTitle(GetLocalizeStringBy("key_1293"))
	local szNode, szBg = spNode:getContentSize(), sp9Bg:getContentSize()

	local tbContentData = NFashionInfoData.getFashionCurAttr()
	if table.isEmpty(tbContentData) then
		return nil
	end


	local nOriginX, nOriginY, nMaxNum = 130, 24, table.count(tbContentData)
	local nHSpace, nVSpace = 202, 35
	local nMaxRow = math.ceil(nMaxNum/2)
	for i = nMaxNum, 1, -1 do
		local tbTemp = tbContentData[i]
		--计算位置
		local nCurRow = math.ceil(i/2)
		local nPositionX, nPositionY = nOriginX + ((i+1)%2)*nHSpace, nOriginY + (nMaxRow-nCurRow)*nVSpace

		--属性名
		local lbName = CCLabelTTF:create(tbTemp.desc.displayName .. ":", g_sFontName, 21)
		lbName:setColor(ccc3(0x78, 0x25, 0x00))
		lbName:setAnchorPoint(ccp(0, 0))
		lbName:setPosition(nPositionX, nPositionY)
		sp9Bg:addChild(lbName)

		--属性值
		local lbNum = CCLabelTTF:create(tbTemp.displayNum, g_sFontName, 21)
		lbNum:setColor(ccc3(0x00, 0x6d, 0x2f))
		lbNum:setAnchorPoint(ccp(0, 0))
		lbNum:setPosition(nPositionX + lbName:getContentSize().width + 10, nPositionY)
		sp9Bg:addChild(lbNum)
	end

	local nDeltaHeight = nMaxRow*nVSpace
	spNode:setContentSize(CCSizeMake(szNode.width, szNode.height + nDeltaHeight))    --重新计算node的宽高
	sp9Bg:setContentSize(CCSizeMake(szBg.width, szBg.height + nDeltaHeight))         --重新计算背景的宽高
	sp9Bg:setPositionY(sp9Bg:getPositionY() + nDeltaHeight)         --重新计算背景的位置 
	sp9TitleBg:setPositionY(sp9TitleBg:getPositionY() + nDeltaHeight)   --重新计算标题的位置

	return spNode
end

--[[
	desc: 创建强化成长属性
	param:
	return:
--]]
function createStrengthenIncrement( ... )
	local spNode, sp9TitleBg, sp9Bg = createBgWithTitle(GetLocalizeStringBy("lic_1655"))
	local szNode, szBg = spNode:getContentSize(), sp9Bg:getContentSize()

	local tbContentData = NFashionInfoData.getFashionStrenghtenIncrement()
	if table.isEmpty(tbContentData) then
		return
	end

	local nOriginX, nOriginY, nMaxNum = 130, 24, table.count(tbContentData)
	local nHSpace, nVSpace = 202, 35
	local nMaxRow = math.ceil(nMaxNum/2)
	-- for k, v in ipairs(tbContentData) do
	for i = nMaxNum, 1, -1 do
		local tbTemp = tbContentData[i]

		--计算位置
		local nCurRow = math.ceil(i/2)
		local nPositionX, nPositionY = nOriginX + ((i+1)%2)*nHSpace, nOriginY + (nMaxRow-nCurRow)*nVSpace

		--属性名
		local lbName = CCLabelTTF:create(tbTemp.desc.displayName .. ":", g_sFontName, 21)
		lbName:setColor(ccc3(0x78, 0x25, 0x00))
		lbName:setAnchorPoint(ccp(0, 0))
		lbName:setPosition(nPositionX, nPositionY)
		sp9Bg:addChild(lbName)

		--属性值
		local lbNum = CCLabelTTF:create("+" .. tbTemp.displayNum, g_sFontName, 21)
		lbNum:setColor(ccc3(0x00, 0x6d, 0x2f))
		lbNum:setAnchorPoint(ccp(0, 0))
		lbNum:setPosition(nPositionX + lbName:getContentSize().width + 10, nPositionY)
		sp9Bg:addChild(lbNum)
	end

	local nDeltaHeight = nMaxRow*nVSpace
	spNode:setContentSize(CCSizeMake(szNode.width, szNode.height + nDeltaHeight))    --重新计算node的宽高
	sp9Bg:setContentSize(CCSizeMake(szBg.width, szBg.height + nDeltaHeight))         --重新计算背景的宽高
	sp9Bg:setPositionY(sp9Bg:getPositionY() + nDeltaHeight)         --重新计算背景的位置 
	sp9TitleBg:setPositionY(sp9TitleBg:getPositionY() + nDeltaHeight)   --重新计算标题的位置

	return spNode
end

--[[
	desc: 创建时装天赋
	param:
	return:
--]]
function createTalent( ... )
	local spNode, sp9TitleBg, sp9Bg = createBgWithTitle(GetLocalizeStringBy("zq_0004"))
	local szNode, szBg = spNode:getContentSize(), sp9Bg:getContentSize()

	local tbContentData = NFashionInfoData.getFashionTalent()
	if table.isEmpty(tbContentData) then
		return
	end

	--初始值
	local nOriginX, nOriginY = 130, 24
	local nHSpace, nVSpace = 202, 35
	local nDeltaHeight = 0

	--"时装天赋为上阵武将增加属性"
	local lbTalentDesc = CCLabelTTF:create(GetLocalizeStringBy("zq_0005"), g_sFontPangWa, 21)
	lbTalentDesc:setColor(ccc3(0xff, 0x84, 0x00))
	lbTalentDesc:setAnchorPoint(ccp(0, 0))
	lbTalentDesc:setPosition(nOriginX, nOriginY)
	sp9Bg:addChild(lbTalentDesc)

	--计算下一个元素的位置
	nDeltaHeight = nDeltaHeight + lbTalentDesc:getContentSize().height + 10
	nOriginY = nOriginY + nDeltaHeight

	-- local tbContentData = {
	-- 	[1] = {"tongshuai:", 99999, 12},
	-- 	[2] = {"wuli:", 99999, 13},
	-- 	[3] = {"zhili:", 99999, 14},
	-- 	[4] = {"gongji:", 99999, 15},
	-- 	[5] = {"shengming:", 99999, 16},
	-- }
	-- if table.isEmpty(tbContentData) then
	-- 	return
	-- end


	local nMaxNum = table.count(tbContentData)
	local nMaxRow = math.ceil(nMaxNum)
	local nDressLevel = NFashionInfoData.getFashionStrengthenLevel()
	for i = nMaxNum, 1, -1 do
		local tbTemp = tbContentData[i]

		--计算位置
		local nCurRow = i
		local nPositionX, nPositionY = nOriginX, nOriginY + (nMaxRow-nCurRow)*nVSpace

		--属性名
		local lbName = CCLabelTTF:create(tbTemp.desc.displayName .. ":", g_sFontName, 21)
		lbName:setColor(ccc3(0x78, 0x25, 0x00))
		lbName:setAnchorPoint(ccp(0, 0))
		lbName:setPosition(nPositionX, nPositionY)
		sp9Bg:addChild(lbName)

		--属性值
		local lbNum = CCLabelTTF:create("+" .. tbTemp.displayNum, g_sFontName, 21)
		lbNum:setColor(ccc3(0x00, 0x6d, 0x2f))
		lbNum:setAnchorPoint(ccp(0, 0))
		lbNum:setPosition(nPositionX + lbName:getContentSize().width + 10, nPositionY)
		sp9Bg:addChild(lbNum)

		
		--属性没有解锁时
		if tbTemp.unlockLevel ~= nil and nDressLevel < tbTemp.unlockLevel then
			--置灰
			lbName:setColor(ccc3(125, 125, 125))
			lbNum:setColor(ccc3(125, 125, 125))

			--开启条件
			local lbCondition = CCLabelTTF:create(GetLocalizeStringBy("zq_0006", tbTemp.unlockLevel), g_sFontName, 21)
			lbCondition:setColor(ccc3(0x78, 0x25, 0x00))
			lbCondition:setAnchorPoint(ccp(0, 0))
			lbCondition:setPosition(lbNum:getPositionX() + lbNum:getContentSize().width + 20, nPositionY)
			sp9Bg:addChild(lbCondition)
		end
	end

	nDeltaHeight = nDeltaHeight + nMaxRow*nVSpace
	spNode:setContentSize(CCSizeMake(szNode.width, szNode.height + nDeltaHeight))    --重新计算node的宽高
	sp9Bg:setContentSize(CCSizeMake(szBg.width, szBg.height + nDeltaHeight))         --重新计算背景的宽高
	sp9Bg:setPositionY(sp9Bg:getPositionY() + nDeltaHeight)         --重新计算背景的位置 
	sp9TitleBg:setPositionY(sp9TitleBg:getPositionY() + nDeltaHeight)   --重新计算标题的位置

	return spNode
end

--[[
	desc: 创建简介
	param:
	return:
--]]
function createBrief( ... )
	--获取简介内容
	local sBrief = NFashionInfoData.getFashionBrief()

	local spNode, sp9TitleBg, sp9Bg = createBgWithTitle(GetLocalizeStringBy("key_2371"))
	local szNode, szBg = spNode:getContentSize(), sp9Bg:getContentSize()

	local nOriginX, nOriginY = 130, 24
	--简介
	local lbBrief = CCLabelTTF:create(sBrief, g_sFontName, 21)
	lbBrief:setColor(ccc3(0x78, 0x25, 0x00))
	lbBrief:setDimensions(CCSizeMake(432, 0))
	lbBrief:setHorizontalAlignment(kCCTextAlignmentLeft)
	lbBrief:setAnchorPoint(ccp(0, 0))
	lbBrief:setPosition(nOriginX, nOriginY)
	sp9Bg:addChild(lbBrief)

	local nDeltaHeight = lbBrief:getContentSize().height + 15
	spNode:setContentSize(CCSizeMake(szNode.width, szNode.height + nDeltaHeight))    --重新计算node的宽高
	sp9Bg:setContentSize(CCSizeMake(szBg.width, szBg.height + nDeltaHeight))         --重新计算背景的宽高
	sp9Bg:setPositionY(sp9Bg:getPositionY() + nDeltaHeight)         --重新计算背景的位置 
	sp9TitleBg:setPositionY(sp9TitleBg:getPositionY() + nDeltaHeight)   --重新计算标题的位置

	return spNode
end





-----------------回调--------------------------
--[[
	desc: 
	param:
	return:
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
	desc: 
	param:
	return:
--]]
function tapBottomBarBtn( pTag, pSender )
	print("tapBottomBarBtn pTag =========", pTag)		
	if pTag == _kBottomBarChangeBtnTag and _fnTapChange then
		_fnTapChange(pTag, pSender)
	elseif pTag == _kBottomBarUnequipBtnTag and _fnTapUnequip then
		_fnTapUnequip(pTag, pSender)
	elseif pTag == _kBottomBarStrengthenBtnTag and _fnTapStrengthen then
		_fnTapStrengthen(pTag, pSender)
	elseif pTag == _kBottomBarCloseBtnTag and _fnTapClose then
		_fnTapClose(pTag, pSender)
	else

	end
end