-- Filename：	FashionInfo.lua
-- Author：		Li Pan
-- Date：		2014-2-11
-- Purpose：		时装

module("FashionInfo", package.seeall)

require "script/ui/fashion/FashionLayer"

local _ksTagClose 			= 1      -- 关闭
local _ksTagEnhance 		= 2      -- 强化
local _ksTagChange 			= 3      -- 更换
local _ksTagDown 			= 4      -- 卸下
local _item_id				= nil
local _enhanceDelegate      = nil
local _isChange 			= false
local _touchPrority 		= nil
local _zOrderNum 			= nil

--新版时装信息界面   2016.06.02 zhangqiang
function create( dressHtid, item_id, isEnhance, isChange, enhanceDelegate,p_info_layer_priority, p_zOrderNum )
	require "script/ui/fashion/fashionInfo/NFashionInfoCtrl"
	NFashionInfoCtrl.showLayer(dressHtid, item_id, isEnhance, isChange, enhanceDelegate,p_info_layer_priority, p_zOrderNum)
end

--旧版时装信息界面   2016.06.02 zhangqiang
--[[
function create(dressHtid, item_id, isEnhance, isChange, enhanceDelegate,p_info_layer_priority, p_zOrderNum)
	_item_id = item_id
	_enhanceDelegate = enhanceDelegate
	_isChange = isChange

	_touchPrority = p_info_layer_priority or -2000
	_zOrderNum = p_zOrderNum or 1010

	local maskLayer = BaseUI.createMaskLayer(_touchPrority)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(maskLayer,_zOrderNum,90903)

  	local bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	bgSprite:setContentSize(CCSizeMake(632, 700))
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	maskLayer:addChild(bgSprite, 1)
    AdaptTool.setAdaptNode(bgSprite)

	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height))
	bgSprite:addChild(topSprite, 2)
	-- topSprite:setScale(myScale)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1073"), g_sFontPangWa, 33, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(topSprite:getContentSize().width/2, topSprite:getContentSize().height*0.6))
    topSprite:addChild(titleLabel)
	
	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	topSprite:addChild(closeMenuBar)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeSelf)
	closeMenuBar:addChild(closeBtn)
	closeMenuBar:setTouchPriority(_touchPrority-1)

-- 内容
	-- 卡牌背景	
	local _cardSprite = getFashionBigCard(dressHtid)
	bgSprite:addChild(_cardSprite)
	_cardSprite:setAnchorPoint(ccp(0.5, 0))
	_cardSprite:setPosition(ccp(bgSprite:getContentSize().width*0.25, 140))

	--简介
	---------------------------------------------- 属性介绍 -----------------------------------------
	createPro(bgSprite, dressHtid, item_id)

	--按钮
	--------------------------- 几个按钮 ------------------------------
	local actionMenuBar = CCMenu:create()
	actionMenuBar:setPosition(ccp(0, 0))	
	actionMenuBar:setTouchPriority(_touchPrority-1)
	bgSprite:addChild(actionMenuBar)

-- 更换
	if(isChange == true) then
		local changeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2731"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		changeBtn:setAnchorPoint(ccp(0.5, 0.5))
	    changeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.2, bgSprite:getContentSize().height*0.1))
	    changeBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(changeBtn, 1, _ksTagChange)

		local enhanceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3391"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
	    enhanceBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.1))
	    enhanceBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(enhanceBtn, 1, _ksTagEnhance)

		local removeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2933"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		removeBtn:setAnchorPoint(ccp(0.5, 0.5))
	    removeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.8, bgSprite:getContentSize().height*0.1))
	    removeBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(removeBtn, 1, _ksTagDown)
	else
		local closeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2474"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		closeBtn:setAnchorPoint(ccp(0.5, 0.5))
	    closeBtn:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height*0.1))
	    closeBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(closeBtn, 1, _ksTagClose)
		if(isEnhance)then 
			local enhanceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3391"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
		    enhanceBtn:setPosition(ccp(bgSprite:getContentSize().width*0.3, bgSprite:getContentSize().height*0.1))
		    enhanceBtn:registerScriptTapHandler(menuAction)
			actionMenuBar:addChild(enhanceBtn, 1, _ksTagEnhance)
			closeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.7, bgSprite:getContentSize().height*0.1))
		end
	end
end
--]]

--简介
function createPro(parents, dressHtid, item_id)
	local itemData = nil
	if(item_id)then
		itemData = ItemUtil.getItemInfoByItemId(item_id)
		if( itemData == nil )then
			-- 背包中没有 检查英雄身上
			itemData = ItemUtil.getFashionFromHeroByItemId(item_id)
			if( not table.isEmpty(itemData))then
				require "db/DB_Item_dress"
				itemData.itemDesc = DB_Item_arm.getDataById(itemData.item_template_id)
			end
		end
 	end
	require "db/DB_Item_dress"
	local localData = DB_Item_dress.getDataById(tonumber(dressHtid))

	local fullRect_attr = CCRectMake(0,0,61,47)
	local insetRect_attr = CCRectMake(10,10,41,27)
	-- 属性背景
	local attrBg = CCScale9Sprite:create("images/copy/fort/textbg.png", fullRect_attr, insetRect_attr)
	attrBg:setPreferredSize(CCSizeMake(282, 440))
	attrBg:setAnchorPoint(ccp(0.5, 0))
	attrBg:setPosition(ccp(parents:getContentSize().width*0.75, 140))
	parents:addChild(attrBg)

	-- ScrollView
	local scrollView = CCScrollView:create()
	scrollView:setTouchPriority(_touchPrority-1)
	local scrollViewWidth = attrBg:getContentSize().width
	local scrollViewHeight = attrBg:getContentSize().height-30
	scrollView:setViewSize(CCSizeMake(scrollViewWidth, scrollViewHeight))
	scrollView:setDirection(kCCScrollViewDirectionVertical)

	local contentLayer = CCLayer:create()
	-- 计算高度
	local contentHeight = 0

	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(localData.quality)
    local dressName = FashionLayer.getIconPath(dressHtid, "name")
	local nameLabel = CCRenderLabel:create(dressName, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setColor(nameColor)
    contentLayer:addChild(nameLabel)

    contentHeight = contentHeight + nameLabel:getContentSize().height

    -- 等级数值
    local lvNum = 0
    if( itemData )then
	    if(itemData.va_item_text)then
	    	if(itemData.va_item_text.dressLevel)then
	    		lvNum = tonumber(itemData.va_item_text.dressLevel)
	    	end
	    end
	end
	local levelLabel = CCLabelTTF:create("+" .. lvNum, g_sFontPangWa, 25)
	levelLabel:setColor(ccc3(0x00, 0x8d, 0x3d))
	levelLabel:setAnchorPoint(ccp(0, 1))
	contentLayer:addChild(levelLabel)

    -- 简介
	local infoTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2371"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    infoTitleLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    infoTitleLabel:setAnchorPoint(ccp(0, 0))
    contentLayer:addChild(infoTitleLabel)

    contentHeight = contentHeight + infoTitleLabel:getContentSize().height

    -- 分割线
	local lineSprite1 = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite1:setAnchorPoint(ccp(0, 0))
	lineSprite1:setScaleX(2)
	contentLayer:addChild(lineSprite1)

	contentHeight = contentHeight + lineSprite1:getContentSize().height

    -- 描述
    local desc = FashionLayer.getIconPath(dressHtid, "info")
	local noLabel = CCLabelTTF:create(desc, g_sFontName, 23, CCSizeMake(245, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	noLabel:setColor(ccc3(0x78, 0x25, 0x00))
	noLabel:setAnchorPoint(ccp(0, 1))
	contentLayer:addChild(noLabel)

	contentHeight = contentHeight + noLabel:getContentSize().height

	-- 当前属性
	local attrLabelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1293"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	attrLabelTitle:setColor(ccc3(0x8a, 0xff, 0x00))
	attrLabelTitle:setAnchorPoint(ccp(0, 0))
	contentLayer:addChild(attrLabelTitle)

	contentHeight = contentHeight + attrLabelTitle:getContentSize().height

	-- 分割线
	local lineSprite2 = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite2:setAnchorPoint(ccp(0, 0))
	lineSprite2:setScaleX(2)
	contentLayer:addChild(lineSprite2)

	contentHeight = contentHeight + lineSprite2:getContentSize().height

	-- 各种属性描述
	local monsterIds = {}
	if( itemData )then
		monsterIds = FashionData.getAttrByItemData(itemData,itemData.va_item_text.dressLevel)
	else
		monsterIds = FashionData.getAttrByItemData(localData,0)
	end
	
	local descString = "" 
	for k,v in pairs(monsterIds) do
		descString = descString .. v.desc.displayName .."+".. v.displayNum .. "\n"
	end
	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 23, CCSizeMake(225, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 1))
	contentLayer:addChild(descLabel)

	contentHeight = contentHeight + descLabel:getContentSize().height

	-- 强化成长属性
	local growAttrLabelTitle = CCRenderLabel:create(GetLocalizeStringBy("lic_1655"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	growAttrLabelTitle:setColor(ccc3(0x8a, 0xff, 0x00))
	growAttrLabelTitle:setAnchorPoint(ccp(0, 0))
	contentLayer:addChild(growAttrLabelTitle)

	contentHeight = contentHeight + growAttrLabelTitle:getContentSize().height

	-- 分割线
	local lineSprite3 = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite3:setAnchorPoint(ccp(0, 0))
	lineSprite3:setScaleX(2)
	contentLayer:addChild(lineSprite3)

	contentHeight = contentHeight + lineSprite3:getContentSize().height

	-- 强化成长属性值
	local growDescString = "" 
	for k,v in pairs(monsterIds) do
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(tonumber(k),v.growData)
		growDescString = growDescString .. v.desc.displayName .."+".. displayNum .. "\n"
	end
	-- 描述
	local growDesccLabel = CCLabelTTF:create(growDescString, g_sFontName, 23, CCSizeMake(225, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	growDesccLabel:setColor(ccc3(0x78, 0x25, 0x00))
	growDesccLabel:setAnchorPoint(ccp(0, 1))
	contentLayer:addChild(growDesccLabel)

	contentHeight = contentHeight + growDesccLabel:getContentSize().height + 100

	--  设置contentLayer
	contentLayer:setContentSize(CCSizeMake(scrollViewWidth,contentHeight))
	scrollView:setContainer(contentLayer)
	scrollView:ignoreAnchorPointForPosition(false) 
	scrollView:setAnchorPoint(ccp(0.5,0.5))
	scrollView:setPosition(ccp(attrBg:getContentSize().width*0.5,attrBg:getContentSize().height*0.5))
	attrBg:addChild(scrollView)
	scrollView:setContentOffset(ccp(0,scrollView:getViewSize().height-contentLayer:getContentSize().height))

	-- 设置坐标
    nameLabel:setPosition(ccp(contentLayer:getContentSize().width*0.5, contentLayer:getContentSize().height))
	levelLabel:setPosition(ccp(nameLabel:getPositionX()+nameLabel:getContentSize().width*0.5+5,nameLabel:getPositionY()))
    infoTitleLabel:setPosition(ccp( contentLayer:getContentSize().width*0.08, nameLabel:getPositionY()-nameLabel:getContentSize().height-30))
	lineSprite1:setPosition(ccp(contentLayer:getContentSize().width*0.02, infoTitleLabel:getPositionY()-10))
	noLabel:setPosition(ccp(contentLayer:getContentSize().width*0.07, lineSprite1:getPositionY()-10))
	attrLabelTitle:setPosition(ccp(contentLayer:getContentSize().width*0.08,noLabel:getPositionY()-noLabel:getContentSize().height-35))
	lineSprite2:setPosition(ccp(contentLayer:getContentSize().width*0.02, attrLabelTitle:getPositionY()-10))
	descLabel:setPosition(ccp(contentLayer:getContentSize().width*0.07, lineSprite2:getPositionY()-10))
	growAttrLabelTitle:setPosition(ccp(contentLayer:getContentSize().width*0.08,descLabel:getPositionY()-descLabel:getContentSize().height-35))
	lineSprite3:setPosition(ccp(contentLayer:getContentSize().width*0.02, growAttrLabelTitle:getPositionY()-10))
	growDesccLabel:setPosition(ccp(contentLayer:getContentSize().width*0.07, lineSprite3:getPositionY()-10))


end

function closeSelf( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:removeChildByTag(90903, true)
end

function menuAction(tag, sender)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 记忆背包位置
	require "script/ui/bag/BagLayer"
	BagLayer.setMarkDressItemId( _item_id )

	if(tag == _ksTagChange) then
		require "script/ui/fashion/ChangeFashion"
		closeSelf()
		local changeLayer = ChangeFashion.create()
		MainScene.changeLayer(changeLayer, "changeLayer")
	elseif(tag == _ksTagDown) then
		--判断背包是否已满
		
		FashionNet.offFashion(function ( ... )
			local heroHtid = HeroModel.getNecessaryHero().equip.dress["1"].item_template_id 
			local item_id = HeroModel.getNecessaryHero().equip.dress["1"].item_id 
			local itemData = HeroModel.getNecessaryHero().equip.dress["1"]
	
			HeroModel.getNecessaryHero().equip.dress["1"] = "0"

			-- 刷新时装属性缓存
			require "script/model/affix/DressAffixModel"
			DressAffixModel.getAffixByHid(HeroModel.getNecessaryHero().hid, true)
			DressAffixModel.getUnLockAffix(true)
			closeSelf()
			require "script/ui/fashion/FashionLayer"
			local mark = FashionLayer.getMark()
			local fashionLayer = FashionLayer:createFashion()
			MainScene.changeLayer(fashionLayer, "FashionLayer")		
 			FashionLayer.setMark(mark)

			FashionLayer.addPro(heroHtid, true, item_id, itemData )
		end, tag)
	elseif(tag == _ksTagClose) then
		-- 关闭
		closeSelf()
	elseif(tag == _ksTagEnhance)then
		-- 强化
		local isNeed = false
		if(_isChange)then
			isNeed = false
		else
			isNeed = true
		end
		require "script/ui/fashion/FashionEnhanceLayer"
		local enforceLayer = FashionEnhanceLayer.createLayer(_item_id, _enhanceDelegate, isNeed)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(enforceLayer, 10)
		-- 关闭
		closeSelf()
	else

	end
end


-- 时装大卡牌
function getFashionBigCard( dressHtid  )
	require "db/DB_Item_dress"
	local localData = DB_Item_dress.getDataById(dressHtid)
	-- 卡牌背景	
	local _cardSprite = CCSprite:create("images/item/equipinfo/card/equip_" .. localData.quality .. ".png")

    -- icon
    local iconPath = FashionLayer.getIconPath(dressHtid,"icon_big")
    local iconSprite = CCSprite:create("images/base/fashion/big/" .. iconPath)
    iconSprite:setAnchorPoint(ccp(0.5, 0.5))
    iconSprite:setPosition(ccp(_cardSprite:getContentSize().width/2, _cardSprite:getContentSize().height*0.55))
    _cardSprite:addChild(iconSprite)

--时装标签
 	local iconName = CCSprite:create("images/fashion/fashion_icon.png")
    iconName:setAnchorPoint(ccp(0.5, 0))
    iconName:setPosition(ccp(40, 60))
    _cardSprite:addChild(iconName)

    -- 星级
    for i=1, localData.quality do
    	local starSp = CCSprite:create("images/formation/star.png")
    	starSp:setAnchorPoint(ccp(0.5, 0.5))
    	starSp:setPosition(ccp( _cardSprite:getContentSize().width * 0.9 - _cardSprite:getContentSize().width* 27.0/300 * (i-1), _cardSprite:getContentSize().height * 410/440))
    	_cardSprite:addChild(starSp)
    end

    
    --品质
    require "script/libs/LuaCC"
    local scoreSprite = LuaCC.createSpriteOfNumbers("images/item/equipnum", localData.score, 17)
    if (scoreSprite ~= nil) then
        scoreSprite:setAnchorPoint(ccp(0, 0))
        scoreSprite:setPosition(_cardSprite:getContentSize().width*110.0/301, _cardSprite:getContentSize().height*0.05)
        _cardSprite:addChild(scoreSprite)
    end

    -- 平台相关装备名字显示兼容
    local plName = Platform.getPlatformFlag()
    if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" ) then
        local nameLabel = CCRenderLabel:create(FashionLayer.getIconPath(dressHtid,"name"), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        local nameColor = HeroPublicLua.getCCColorByStarLevel(localData.quality)
    	nameLabel:setColor(nameColor)
        nameLabel:setPosition(ccp( _cardSprite:getContentSize().width*0.5, _cardSprite:getContentSize().height*0.18))
        _cardSprite:addChild(nameLabel,3)
    elseif (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	local nameLabel = CCRenderLabel:create(FashionLayer.getIconPath(dressHtid,"name"), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        local nameColor = HeroPublicLua.getCCColorByStarLevel(localData.quality)
    	nameLabel:setColor(nameColor)
        nameLabel:setPosition(ccp( _cardSprite:getContentSize().width*0.5, _cardSprite:getContentSize().height*0.18))
        _cardSprite:addChild(nameLabel,3)
    else
        local nameLabel = CCRenderLabel:createWithAlign(FashionLayer.getIconPath(dressHtid,"name"), g_sFontName, 24,
                                      1 , ccc3(0, 0, 0 ), type_stroke, CCSizeMake(25,180), kCCTextAlignmentCenter,
                                      kCCVerticalTextAlignmentCenter);
        local nameColor = HeroPublicLua.getCCColorByStarLevel(localData.quality)
    	nameLabel:setColor(nameColor)
        nameLabel:setPosition(ccp( _cardSprite:getContentSize().width*0.02, _cardSprite:getContentSize().height*0.98))
        _cardSprite:addChild(nameLabel,3)
    end

    return _cardSprite
end






