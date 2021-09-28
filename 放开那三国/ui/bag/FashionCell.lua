-- Filename：	FashionCell.lua
-- Author：		李攀
-- Date：		2014-2-25
-- Purpose：		背包Cell

module("FashionCell", package.seeall)
require "script/ui/fashion/FashionData"

local _enhanceDelegate = nil

-- 强化装备
local function enhanceAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 强化装备
	require "script/ui/fashion/FashionEnhanceLayer"
	local item_id = tag
	local enforceLayer = FashionEnhanceLayer.createLayer(item_id, _enhanceDelegate,true)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(enforceLayer, 10)

	-- 记忆背包位置
	require "script/ui/bag/BagLayer"
	BagLayer.setMarkDressItemId( item_id )
	BagLayer.setOpenIndex(nil)
end 


function createFashionCell( pItemInfo, isSell, enhanceDelegate, isEnhance, isCanTouch, pIsBag, pIndex )
	local tCell = CCTableViewCell:create()
	_enhanceDelegate = enhanceDelegate

	--背景
	-- print("the pItemInfo is ")
	-- print_t(pItemInfo)
	local cellBg = CCSprite:create("images/bag/equip/treas_cellbg.png")
	cellBg:setAnchorPoint(ccp(0.5,0))
	cellBg:setPosition(320,0)
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- require "db/DB_Item_dress"
	-- local fashionInfo = HeroModel.getNecessaryHero().equip.dress
	-- print_t(fashionInfo)
	local dressHtid = pItemInfo.item_template_id
	-- print("the dressHtid is >>>>>>",dressHtid)
	-- icon
	local iconSprite = nil
	if(isCanTouch == false)then
		-- 不可点
		iconSprite = ItemSprite.getItemSpriteByItemId(dressHtid)
	else
		iconSprite = ItemSprite.getItemSpriteById(dressHtid,tonumber(pItemInfo.item_id),enhanceDelegate)
	end
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 等级
    local lvSprite = CCSprite:create("images/common/lv.png")
    lvSprite:setPosition(ccp(30, cellBgSize.height*0.2))
    lvSprite:setAnchorPoint(ccp(0, 0.5))
    cellBg:addChild(lvSprite)

	local t_level = 0
	if( (not table.isEmpty(pItemInfo.va_item_text) and pItemInfo.va_item_text.dressLevel ))then
		t_level = pItemInfo.va_item_text.dressLevel
	end
	local levelLabel = CCRenderLabel:create(t_level, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
    levelLabel:setAnchorPoint(ccp(0.5,0.5))
    levelLabel:setPosition(ccp(80, cellBgSize.height*0.2))
    cellBg:addChild(levelLabel)

    --时装标签
 	local iconName = CCSprite:create("images/fashion/fashion_icon2.png")
    iconName:setAnchorPoint(ccp(0.5, 0))
    iconName:setPosition(ccp(150, 120))
    cellBg:addChild(iconName)

-- 名称
	local name = nil
	local nameColor = HeroPublicLua.getCCColorByStarLevel(pItemInfo.itemDesc.quality)

	local oldhtid = UserModel.getAvatarHtid()
	local model_id = DB_Heroes.getDataById(tonumber(oldhtid)).model_id
	-- print("the model_id is"..model_id)
	-- print_t(pItemInfo.itemDesc.name)

    local nameArray = lua_string_split(pItemInfo.itemDesc.name, ",")
    for k,v in pairs(nameArray) do
    	local array = lua_string_split(v, "|")
    	-- print("the array is")
    	-- print_t(array)
    	if(tonumber(array[1]) == tonumber(model_id)) then
			name = array[2]
			break
    	end
    end

	local nameLabel = CCRenderLabel:create(name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2+ iconName:getContentSize().width+5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)    

-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*370.0/640 + 50, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(pItemInfo.itemDesc.quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*330.0/640 + 50, cellBgSize.height*0.87)
    cellBg:addChild(potentialLabel)

    -- 获得相关数值
    require "db/DB_Item_dress"
	local localData = DB_Item_dress.getDataById(dressHtid)
	local monsterIds = FashionData.getAttrByItemData(pItemInfo,t_level)
	local descString = "" --GetLocalizeStringBy("key_2137") .. enhanceLv .. "\n"
	local i = 0
	for k,v in pairs(monsterIds) do
		i = i+1
		descString = descString .. v.desc.displayName .."+".. v.displayNum .. "\n"
		if(i == 4)then
			break
		end
	end

	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 21, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(cellBgSize.width*0.21, cellBgSize.height*0.4))
	cellBg:addChild(descLabel)

	-- 评分
	local equipScoreLabel = CCRenderLabel:create(localData.score or 0, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    equipScoreLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    -- equipScoreLabel:setAnchorPoint(ccp(0,0))
    equipScoreLabel:setPosition(ccp((cellBgSize.width*1.05-equipScoreLabel:getContentSize().width)/2, cellBgSize.height*0.35))
    cellBg:addChild(equipScoreLabel)

    -- 强化
    local isEnhance = isEnhance
    if(isEnhance == nil)then
    	isEnhance = true
    end
    local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)
    if(isEnhance)then
		local enhanceBtn = LuaMenuItem.createItemImage("images/item/equipinfo/btn_enhance_n.png", "images/item/equipinfo/btn_enhance_h.png", enhanceAction )
		enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
	    enhanceBtn:setPosition(ccp(cellBgSize.width*0.8, cellBgSize.height*0.5))
		menuBar:addChild(enhanceBtn, 1, pItemInfo.item_id)
	end


    if(pItemInfo.equip_hid and tonumber(pItemInfo.equip_hid) > 0)then
		-- local being_front = CCSprite:create("images/hero/being_fronted.png")
		-- being_front:setPosition(ccp(532, 88))
		-- cellBg:addChild(being_front)
		local localHero = HeroUtil.getHeroInfoByHid(pItemInfo.equip_hid)
		local heroName = localHero.localInfo.name
		if(HeroModel.isNecessaryHeroByHid(pItemInfo.equip_hid)) then
			heroName = UserModel.getUserName()
		end
		local onFormationText =  CCRenderLabel:create(GetLocalizeStringBy("key_1381") .. heroName, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    onFormationText:setColor(ccc3(0x8a, 0xff, 0x00))
	    onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.9))
	    cellBg:addChild(onFormationText)
	end


	-- 展开逻辑
	if( BagUtil.isSupportBagCell() and pIsBag)then
		-- 隐藏原来的按钮
		menuBar:setVisible(false)
		-- 展开背景高度
		local openBgHeight = 138
		local addHeight = openBgHeight-10
		-- 展开按钮
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		cellBg:addChild(menu)
		local normal = CCMenuItemImage:create("images/common/down_btn_n.png", "images/common/down_btn_h.png")
		local hight  = CCMenuItemImage:create("images/common/up_btn_n.png", "images/common/up_btn_h.png")
		hight:setAnchorPoint(ccp(0.5, 0.5))
		normal:setAnchorPoint(ccp(0.5, 0.5))
		local openMenuItem = CCMenuItemToggle:create(normal)
		openMenuItem:setAnchorPoint(ccp(0.5, 0.5))
		openMenuItem:addSubItem(hight)
		menu:addChild(openMenuItem)
		openMenuItem:setPosition(ccp(cellBg:getContentSize().width*0.8,cellBg:getContentSize().height*0.45))
		openMenuItem:registerScriptTapHandler(function ( ... )
			-- 展开事件
			local selectIndex = openMenuItem:getSelectedIndex()
			-- print("selectIndex",selectIndex)
			local offsetNum = 0
			if(selectIndex == 0) then
				BagLayer.setOpenIndex(nil)
				offsetNum = -addHeight
			else
				BagLayer.setOpenIndex(pIndex)
				offsetNum = addHeight
			end
			BagLayer.refreshBagTableView(offsetNum,pIndex)
		end)

		-- 展开按钮
		local curOpneIndex = BagLayer.getOpenIndex()
		-- print("cell curOpneIndex",curOpneIndex,pIndex)
		if(pIndex == curOpneIndex)then
			openMenuItem:setSelectedIndex(1)
			local openBg = CCScale9Sprite:create("images/common/bg/bg_9s_11.png")
			openBg:setContentSize(CCSizeMake(600,openBgHeight))
	        openBg:setAnchorPoint(ccp(0.5,0))
	        openBg:setPosition(320,10)
	        tCell:addChild(openBg)
	        cellBg:setAnchorPoint(ccp(0.5,0))
			cellBg:setPosition(openBg:getPositionX(),addHeight)

			-- 按钮
			local buttnMenu = CCMenu:create()
			buttnMenu:setPosition(ccp(0,0))
			openBg:addChild(buttnMenu)
			local btnArr = {}
			local btnPosXArr = {0.85,0.68,0.51,0.34}
			local allOpen = true
		    -- 强化
		    local enhanceMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_s_n.png", "images/common/btn/btn_s_h.png",CCSizeMake(81, 76), GetLocalizeStringBy("lic_1422"),ccc3(0xff, 0xf2, 0x5d),24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			enhanceMenuItem:setAnchorPoint(ccp(0.5, 0.5))
			enhanceMenuItem:registerScriptTapHandler(enhanceAction)
			buttnMenu:addChild(enhanceMenuItem, 1, tonumber(pItemInfo.item_id))
			table.insert(btnArr,enhanceMenuItem)

			for i=1,#btnArr do
				if(allOpen)then
					btnArr[i]:setPosition(ccp(openBg:getContentSize().width*btnPosXArr[i], openBg:getContentSize().height*0.47))
				else
					btnArr[i]:setPosition(ccp(openBg:getContentSize().width*btnPosXArr[i], openBg:getContentSize().height*0.5))
				end
			end
		else
			openMenuItem:setSelectedIndex(0)
		end
	end

	return tCell
end






