-- Filename: HeroLayerCell.lua.
-- Author: fang.
-- Date: 2013-07-07
-- Purpose: 该文件用于实现GetLocalizeStringBy("key_3191")cell

module ("HeroLayerCell", package.seeall)

--[[
	@des 	:技能按钮回调
	@param 	:
	@return :
--]]
function skillItemCallback(tag, itemBtn)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- 学习技能
	if(not DataCache.getSwitchNodeState(ksChangeSkill, true)) then
		return	
	end

    require "script/ui/replaceSkill/EquipmentLayer"
    local closeCb = function ( ... )
     	-- 返回背包
     	local layer = HeroLayer.createLayer()
        MainScene.changeLayer(layer, "HeroLayer")
    end
    EquipmentLayer.showLayer(closeCb)
end

--[[
	@des 	:觉醒按钮回调
	@param 	:
	@return :
--]]
function awakeMenuItemCallback(tag, itemBtn)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local closeCb = function ( ... )
     	-- 返回背包
     	local layer = HeroLayer.createLayer()
        MainScene.changeLayer(layer, "HeroLayer")
    end
    local hid = tag
    require "script/ui/biography/ComprehendLayer"
    ComprehendLayer.show(hid,closeCb, true)
end

--[[
	@des 	:丹药按钮回调
	@param 	:
	@return :
--]]
function pillMenuItemCallback(tag, itemBtn)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    if(not DataCache.getSwitchNodeState(ksSwitchDrug, true)) then
		return	
	end
	
    local closeCb = function ( ... )
     	-- 返回背包
     	local layer = HeroLayer.createLayer()
        MainScene.changeLayer(layer, "HeroLayer")
    end
    local hid = tag
       require "script/ui/pill/PillLayer"
    local layer = PillLayer.createLayer(1, closeCb,nil,nil,hid)
    MainScene.changeLayer(layer, "pillLayer")
end

--[[
	@des 	:天命按钮回调
	@param 	:
	@return :
--]]
function tianMenuItemCallback(tag, itemBtn)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    require "script/ui/redcarddestiny/RedCardDestinyLayer"
    local layer = RedCardDestinyLayer.createLayer(1,tag,-1000)
    MainScene.changeLayer(layer, "RedCardDestinyLayer")
    MainScene.setMainSceneViewsVisible(false,false,false)
end

--[[
	@desc	: 幻化按钮回调
    @param	: pTag,pItem 武将hid，幻化按钮
    @return	: 
—-]]
function turnedItemCallback( pTag, pItem )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    print("进入幻化系统 turnedItemCallback => ",pTag)

    require "script/ui/turnedSys/HeroTurnedLayer"
    HeroTurnedLayer.showLayer(pTag,"HeroLayer")
end

function createStars(filename, count, start_position, space)
	local stars = CCSprite:create(filename)
	local size = stars:getContentSize()
	stars:setPosition(start_position)
	local x = size.width + space
	for i=2, count do
		local tmp = CCSprite:create(filename)
		tmp:setPosition(ccp(x, 0))
		x = x + size.width + space
		stars:addChild(tmp)
	end

	return stars
end

function createCell(tCellValue, touchPriority, pIsBag, pIndex)
	print("hero list tCellValue:")
	print_t(tCellValue)
	local ccCell = CCTableViewCell:create()
	-- 背景
	local cellBg = CCSprite:create("images/hero/attr_bg.png")
	cellBg:setAnchorPoint(ccp(0.5,0))
	cellBg:setPosition(320,0)
	if (tCellValue.tag_bg) then
		ccCell:addChild(cellBg, 10, tCellValue.tag_bg)
	else
		ccCell:addChild(cellBg, 10, 9001)
	end

	-- 武将所属国家
	if tCellValue.country_icon then
		local country = CCSprite:create(tCellValue.country_icon)
		country:setAnchorPoint(ccp(0, 0))
		country:setPosition(ccp(16, 105))
		cellBg:addChild(country)
	end

	
	-- 武将等级
	local lv = CCLabelTTF:create("Lv."..tCellValue.level, g_sFontName, 20, CCSizeMake(130, 30), kCCTextAlignmentCenter)
	lv:setPosition(30, 105)
	lv:setColor(ccc3(0xff, 0xee, 0x3a))
	cellBg:addChild(lv)

	--因为合服后会出现后面加服务器名字的情况，因此显示不下
	--在这里对于长度过长的名字进行名字处截断处理
	require "script/model/utils/HeroUtil"
	local cutName = HeroUtil.getOriginalName(tCellValue.name)
	require "script/ui/redcarddestiny/RedCardDestinyData"
    cutName =  RedCardDestinyData.getHeroRealName(tCellValue.hid)
    local name = DB_Heroes.getDataById(tCellValue.htid).name
    if(cutName==name)then
    	cutName = HeroUtil.getOriginalName(tCellValue.name)
    end
	-- 武将名称
	local name = CCLabelTTF:create(cutName, g_sFontName, 22, CCSizeMake(136, 30), kCCTextAlignmentCenter)
	name:setPosition(139, 106)
	local cccQuality = HeroPublicLua.getCCColorByStarLevel(tCellValue.star_lv)
	name:setColor(cccQuality)
	cellBg:addChild(name)
	-- 星级
	local ccStarLv = createStars("images/hero/star.png", tCellValue.star_lv, ccp(290, 112), 4)
	cellBg:addChild(ccStarLv)
	-- 已上阵
	if tCellValue.isBusy then
		local being_front = CCSprite:create("images/hero/being_fronted.png")
		being_front:setPosition(ccp(534, 82))
		cellBg:addChild(being_front)
	end

	--小伙伴
	if LittleFriendData.isInLittleFriend(tCellValue.hid) then
		local being_front = CCSprite:create("images/hero/littlefriend.png")
		being_front:setPosition(ccp(534, 82))
		cellBg:addChild(being_front)
	end
	--助战军
	require "script/ui/formation/secondfriend/SecondFriendData"
	if SecondFriendData.isInSecondFriendByHid(tCellValue.hid) then
		local being_front = CCSprite:create("images/hero/second_friend.png")
		being_front:setPosition(ccp(534, 82))
		cellBg:addChild(being_front)
	end
	-- 是不是主角
	local dressId = nil
	if(tCellValue.isAvatar) then
		dressId = UserModel.getDressIdByPos(1)
		-- print("主角 dressId = ",dressId)
	end
	-- 头像按钮
	local headMenu = CCMenu:create()
    headMenu:setTouchPriority(touchPriority or -395)
    headMenu:setPosition(ccp(0, 0))
	cellBg:addChild(headMenu,10)

	local head_icon_bg = HeroPublicCC.createHeroHeadIcon(tCellValue, dressId)
	if tCellValue.hero_cb then
		head_icon_bg:registerScriptTapHandler(tCellValue.hero_cb)
	end
	if tCellValue.hero_tag then
		headMenu:addChild(head_icon_bg, 0, tCellValue.hero_tag)
	else
		headMenu:addChild(head_icon_bg)
	end
	
	--新武将表示
	require "script/model/hero/HeroModel"
	if(HeroModel.isNewHero(tCellValue.hid) == true) then
		local newAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/mail/new/new"), -1,CCString:create(""));
        newAnimSprite:setPosition(ccp(head_icon_bg:getContentSize().width*0.5-20,head_icon_bg:getContentSize().height-20))
       	head_icon_bg:addChild(newAnimSprite,3,10)
	end


	if tCellValue.heroQuality == nil then
		tCellValue.heroQuality = DB_Heroes.getDataById(tCellValue.htid).heroQuality
	end
	-- 战斗力值
	local qualityBgSprite = CCSprite:create("images/hero/jianbian.png")
	qualityBgSprite:setAnchorPoint(ccp(0, 0))
	qualityBgSprite:setPosition(105, 65)
	cellBg:addChild(qualityBgSprite)

	local force_value = CCLabelTTF:create(GetLocalizeStringBy("key_2871") .. tCellValue.heroQuality, g_sFontName, 24, CCSizeMake(200, 30), kCCTextAlignmentLeft)
	force_value:setAnchorPoint(ccp(0, 0.5))
	force_value:setPosition(ccp(13, qualityBgSprite:getContentSize().height/2 - 3))
	force_value:setColor(ccc3(0x48, 0x1b, 0))
	qualityBgSprite:addChild(force_value, 1)

	-- added by zhz
	if(tCellValue.lock and tonumber(tCellValue.lock) ==1) then
		local lockSp= CCSprite:create("images/hero/lock.png")
		lockSp:setPosition(145, qualityBgSprite:getContentSize().height/2)
		lockSp:setAnchorPoint(ccp(0.5, 0.5))
		qualityBgSprite:addChild(lockSp)
	end

	-- 进阶，强化Menu，头像，均为MenuItem
	local menu_ms = CCMenu:create()
    menu_ms:setTouchPriority(touchPriority or -395)
	-- if tCellValue.hero_tag then
	-- 	menu_ms:addChild(head_icon_bg, 0, tCellValue.hero_tag)
	-- else
	-- 	menu_ms:addChild(head_icon_bg)
	-- end
	if (tCellValue.type == nil) then
		if( not(BagUtil.isSupportBagCell() and pIsBag) )then
			createTSMenuItems(menu_ms, tCellValue)
		end
	elseif (tCellValue.type == "StarSell") then
		local ccSilverIcon = CCSprite:create("images/common/coin_silver.png")
		ccSilverIcon:setPosition(ccp(360, 46))
		cellBg:addChild(ccSilverIcon)
		--		local ccLabelSilverNumber = CCLabelTTF:create(tCellValue.price, g_sFontName, 24)
		local ccLabelSilverNumber = CCRenderLabel:create(tCellValue.price, g_sFontName, 24, 1, ccc3(0, 0, 0), type_stroke)
		ccLabelSilverNumber:setPosition(400, 46)
		ccLabelSilverNumber:setColor(ccc3(0x6c, 0xff, 0))
		ccLabelSilverNumber:setAnchorPoint(ccp(0, 0))
		cellBg:addChild(ccLabelSilverNumber)
		--createCheckMenuItems(menu_ms, tCellValue)

		local ccSpriteCheckBg = CCSprite:create(tCellValue.menu_items[1].normal)
		ccSpriteCheckBg:setPosition(tCellValue.menu_items[1].pos_x, tCellValue.menu_items[1].pos_y)
		local ccSpriteSelected = CCSprite:create("images/common/checked.png")
		if (tCellValue.checkIsSelected) then
			ccSpriteSelected:setVisible(true)
		else
			ccSpriteSelected:setVisible(false)
		end
		ccSpriteCheckBg:addChild(ccSpriteSelected, 0, 10002)
		cellBg:addChild(ccSpriteCheckBg, 0, 10001)
	elseif tCellValue.type == "HeroSelect" then
		-- 不需要GetLocalizeStringBy("key_3417")标识
		if not tCellValue.withoutExp then
			-- 经验值图标
			local ccSpriteExp = CCSprite:create("images/common/exp.png")
			ccSpriteExp:setPosition(ccp(360, 46))
			cellBg:addChild(ccSpriteExp)
			-- 经验值数据
			local ccLabelSExp = CCRenderLabel:create(tCellValue.soul, g_sFontName, 24, 1, ccc3(0, 0, 0), type_stroke)
			ccLabelSExp:setPosition(420, 46)
			ccLabelSExp:setAnchorPoint(ccp(0, 0))
			ccLabelSExp:setColor(ccc3(0x6c, 0xff, 0))
			cellBg:addChild(ccLabelSExp)
		end
		local ccSpriteCheckBg = CCSprite:create(tCellValue.menu_items[1].normal)
		ccSpriteCheckBg:setPosition(tCellValue.menu_items[1].pos_x, tCellValue.menu_items[1].pos_y)
		local ccSpriteSelected = CCSprite:create("images/common/checked.png")
		if (tCellValue.checkIsSelected) then
			ccSpriteSelected:setVisible(true)
		else
			ccSpriteSelected:setVisible(false)
		end
		ccSpriteCheckBg:addChild(ccSpriteSelected, 0, 10002)
		cellBg:addChild(ccSpriteCheckBg, 0, 10001)
	end
	if (tCellValue.menu_tag) then
		cellBg:addChild(menu_ms, 0, tCellValue.menu_tag)
	else
		cellBg:addChild(menu_ms)
	end

	menu_ms:setPosition(ccp(0, 0))

	-- 如果在新手引导情况下
	if tCellValue.isNoviceGuiding then
		local rect = CCRectMake(0, 0, 3, 3)
		local rectInsets = CCRectMake(1, 1, 1, 1)
		local csTransparent = CCScale9Sprite:create("images/common/transparent.png", rect, rectInsets)
		local tBgSize = cellBg:getContentSize()
		csTransparent:setPosition(tBgSize.width/2, 0)
		csTransparent:setPreferredSize(CCSizeMake(tBgSize.width/2, tBgSize.height))
		cellBg:addChild(csTransparent, 0, 30001)
	end
	--是否开始觉醒能力
	local heroInfo            = HeroModel.getHeroByHid(tCellValue.hid)
	heroInfo.talent           = heroInfo.talent or {}
	heroInfo.talent.confirmed = heroInfo.talent.confirmed or {}
	heroInfo.talent.sealed    = heroInfo.talent.sealed or {}
	local isOpenTalent = false
	for k,v in pairs(heroInfo.talent.confirmed) do
		if tonumber(v) ~= 0 then
			isOpenTalent = true
			break
		end
	end
	for k,v in pairs(heroInfo.talent.sealed) do
		if tonumber(v) ~= 0 then
			isOpenTalent = true
			break
		end
	end
	local tipIconMap = {}
	local openTalentSprite = CCSprite:create("images/common/rect/4.png")
	openTalentSprite:setScale(1)
	if isOpenTalent then
		table.insert(tipIconMap, openTalentSprite)
	end
	local wordLabel = CCLabelTTF:create(GetLocalizeStringBy("lcyx_2021"), g_sFontName, 25)
	wordLabel:setPosition(ccpsprite(0.5, 0.5, openTalentSprite))
	wordLabel:setAnchorPoint(ccp(0.5, 0.5))
	openTalentSprite:addChild(wordLabel)
	
	--服用过丹药图标
	local openPillSprite = CCSprite:create("images/common/rect/3.png")
	openPillSprite:setScale(1)
	if HeroModel.isHeroPillOn(tCellValue.hid) then
		table.insert(tipIconMap, openPillSprite)
	end
	
	local wordLabel = CCLabelTTF:create(GetLocalizeStringBy("lcyx_2022"), g_sFontName, 25)
	wordLabel:setAnchorPoint(ccp(0.5, 0.5))
	wordLabel:setPosition(ccpsprite(0.5, 0.5, openPillSprite))
	openPillSprite:addChild(wordLabel)

	local tipIcon = BaseUI.createHorizontalNode(tipIconMap,nil, nil, 10)
	tipIcon:setAnchorPoint(ccp(0,0))
	tipIcon:setPosition(ccpsprite(0.19, 0.13, cellBg))
	cellBg:addChild(tipIcon, 20)
	
	-- 展开逻辑
	if( BagUtil.isSupportBagCell() and pIsBag)then
		-- 隐藏原来的按钮
		menu_ms:setVisible(false)
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
				HeroLayer.setOpenIndex(nil)
				offsetNum = -addHeight
			else
				HeroLayer.setOpenIndex(pIndex)
				offsetNum = addHeight
			end
			HeroLayer.refreshBagTableView(offsetNum,pIndex)
		end)

		-- 展开按钮
		local curOpneIndex = HeroLayer.getOpenIndex()
		-- print("cell curOpneIndex",curOpneIndex,pIndex)
		if(pIndex == curOpneIndex)then
			openMenuItem:setSelectedIndex(1)
			local openBg = CCScale9Sprite:create("images/common/bg/bg_9s_11.png")
			openBg:setContentSize(CCSizeMake(600,openBgHeight))
	        openBg:setAnchorPoint(ccp(0.5,0))
	        openBg:setPosition(320,10)
	        ccCell:addChild(openBg,1,9002)
	        cellBg:setAnchorPoint(ccp(0.5,0))
			cellBg:setPosition(openBg:getPositionX(),addHeight)

			-- 按钮
			local buttnMenu = CCMenu:create()
			buttnMenu:setPosition(ccp(0,0))
			openBg:addChild(buttnMenu,1,80002)
			local btnArr = {}
			-- local btnPosXArr = {0.85,0.68,0.51,0.34,0.17}
			local btnPosXArr = {0.875,0.725,0.575,0.425,0.275,0.125}
			local allOpen = true
			local heroDbData = HeroUtil.getHeroLocalInfoByHtid( tCellValue.htid )
		    -- 强化
		    if(not tCellValue.isAvatar)then
		    	-- 不是主角有强化
			    local enhanceMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_s_n.png", "images/common/btn/btn_s_h.png",CCSizeMake(81, 76), GetLocalizeStringBy("lic_1422"),ccc3(0xff, 0xf2, 0x5d),24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				enhanceMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				enhanceMenuItem:registerScriptTapHandler(tCellValue.menu_items[2].cb)
				buttnMenu:addChild(enhanceMenuItem, 1, tCellValue.menu_items[2].tag)
				table.insert(btnArr,1,enhanceMenuItem)
			end

			-- 进阶
			local isJinHua = DevelopData.doOpenDevelopByHid(tCellValue.hid)
			local normalFile = "images/common/btn/btn_s_n.png"
			local selectFile = "images/common/btn/btn_s_h.png"
			local fontColor = ccc3(0xff, 0xf2, 0x5d)
			local fontStr = ""
			if( isJinHua )then
				fontStr = GetLocalizeStringBy("lic_1825")
		    else
		    	fontStr = GetLocalizeStringBy("lic_1423")
			end
			local developMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76),fontStr,fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			developMenuItem:setAnchorPoint(ccp(0.5, 0.5))
			developMenuItem:registerScriptTapHandler(tCellValue.menu_items[1].cb)
			buttnMenu:addChild(developMenuItem, 1, tCellValue.menu_items[1].tag)
			table.insert(btnArr,1,developMenuItem)

			-- 第三个按钮
			if(tCellValue.isAvatar)then
				-- 主角 时装
			  	local normalFile = "images/common/btn/btn_s_n.png"
				local selectFile = "images/common/btn/btn_s_h.png"
				local fontColor = ccc3(0xff, 0xf2, 0x5d)
			    local dressMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1831"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				dressMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				dressMenuItem:registerScriptTapHandler(function ( ... )
					require "script/audio/AudioUtil"
					AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
					--进入时装场景
					MainScene.setMainSceneViewsVisible(true, false, true)
					require "script/ui/fashion/FashionLayer"
					local fashionLayer = FashionLayer:createFashion()
					MainScene.changeLayer(fashionLayer, "FashionLayer")
				end)
				buttnMenu:addChild(dressMenuItem, 1)
				table.insert(btnArr,1,dressMenuItem)

				-- 主角 技能
				local isOpen = DataCache.getSwitchNodeState(ksChangeSkill,false)
				local normalFile = nil
				local selectFile = nil
				local fontColor = nil
				if(isOpen)then
				  	normalFile = "images/common/btn/btn_s_n.png"
					selectFile = "images/common/btn/btn_s_h.png"
					fontColor = ccc3(0xff, 0xf2, 0x5d)
				else
					normalFile = "images/common/btn/btn_s_d1.png"
					selectFile = "images/common/btn/btn_s_d2.png"
					fontColor = ccc3(0xff, 0xff, 0xff)
				end
			    local skillMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1826"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				skillMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				skillMenuItem:registerScriptTapHandler(skillItemCallback)
				buttnMenu:addChild(skillMenuItem, 1)
				table.insert(btnArr,1,skillMenuItem)

				-- 开启等级
				if(isOpen == false)then
					require "db/DB_Switch"
					local switchInfo = DB_Switch.getDataById(ksChangeSkill)
					local needLv = switchInfo.level or 1
					local tipFont =  CCRenderLabel:create(GetLocalizeStringBy("lic_1823",needLv), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    		tipFont:setColor(ccc3(0xff, 0xff, 0xff))
		    		tipFont:setAnchorPoint(ccp(0.5,1))
		    		tipFont:setPosition(ccp(skillMenuItem:getContentSize().width*0.5, 0))
		    		skillMenuItem:addChild(tipFont)
		    		allOpen = false
		    	end
			else
				-- 其他武将 觉醒
				if( heroDbData.hero_copy_id )then
					local awakeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_s_n.png", "images/common/btn/btn_s_h.png",CCSizeMake(81, 76), GetLocalizeStringBy("lic_1827"),ccc3(0xff, 0xf2, 0x5d),24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
					awakeMenuItem:setAnchorPoint(ccp(0.5, 0.5))
					awakeMenuItem:registerScriptTapHandler(awakeMenuItemCallback)
					buttnMenu:addChild(awakeMenuItem, 1,tonumber(tCellValue.hid))
					table.insert(btnArr,1,awakeMenuItem)
				end
			end

			-- 丹药
			local isCanPill = HeroModel.isCanPill(tCellValue.hid)
			if( isCanPill )then
				local isOpen = DataCache.getSwitchNodeState(ksSwitchDrug,false)
				local normalFile = nil
				local selectFile = nil
				local fontColor = nil
				if(isOpen)then
				  	normalFile = "images/common/btn/btn_s_n.png"
					selectFile = "images/common/btn/btn_s_h.png"
					fontColor = ccc3(0xff, 0xf2, 0x5d)
				else
					normalFile = "images/common/btn/btn_s_d1.png"
					selectFile = "images/common/btn/btn_s_d2.png"
					fontColor = ccc3(0xff, 0xff, 0xff)
				end
			    local pillMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1828"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				pillMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				pillMenuItem:registerScriptTapHandler(pillMenuItemCallback)
				buttnMenu:addChild(pillMenuItem, 1,tonumber(tCellValue.hid))
				table.insert(btnArr,1,pillMenuItem)

				-- 开启等级
				if(isOpen == false)then
					require "db/DB_Switch"
					local switchInfo = DB_Switch.getDataById(ksSwitchDrug)
					local needLv = switchInfo.level or 1
					local tipFont =  CCRenderLabel:create(GetLocalizeStringBy("lic_1823",needLv), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    		tipFont:setColor(ccc3(0xff, 0xff, 0xff))
		    		tipFont:setAnchorPoint(ccp(0.5,1))
		    		tipFont:setPosition(ccp(pillMenuItem:getContentSize().width*0.5, 0))
		    		pillMenuItem:addChild(tipFont)
		    		allOpen = false
		    	end
		    end

		    -- 不是主角的红卡有 天命
		    if(tCellValue.isAvatar)then
		    else
				if( tonumber(tCellValue.star_lv) >= 7 )then
					local isOpen = true
					local normalFile = nil
					local selectFile = nil
					local fontColor = nil
					if(isOpen)then
					  	normalFile = "images/common/btn/btn_s_n.png"
						selectFile = "images/common/btn/btn_s_h.png"
						fontColor = ccc3(0xff, 0xf2, 0x5d)
					else
						normalFile = "images/common/btn/btn_s_d1.png"
						selectFile = "images/common/btn/btn_s_d2.png"
						fontColor = ccc3(0xff, 0xff, 0xff)
					end
				    local pillMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1838"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
					pillMenuItem:setAnchorPoint(ccp(0.5, 0.5))
					pillMenuItem:registerScriptTapHandler(tianMenuItemCallback)
					buttnMenu:addChild(pillMenuItem, 1,tonumber(tCellValue.hid))
					table.insert(btnArr,1,pillMenuItem)
			    end
			end

			-- 幻化 非主角 玩家等级达到70后开放幻化系统
			-- 幻化按钮的开启条件：1、switch表里的角色等级是否达到 2.heros表里该武将是否可幻化配置不为空
			if ( not tCellValue.isAvatar ) then
				require "script/ui/turnedSys/HeroTurnedData"
				local isCanTurned = HeroTurnedData.isCanTurned(tCellValue.hid)
				if ( isCanTurned ) then
					local normalFile = "images/common/btn/btn_s_n.png"
					local selectFile = "images/common/btn/btn_s_h.png"
					local fontColor = ccc3(0xff, 0xf2, 0x5d)
				    local turnedItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lgx_1110"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
					turnedItem:setAnchorPoint(ccp(0.5, 0.5))
					turnedItem:registerScriptTapHandler(turnedItemCallback)
					buttnMenu:addChild(turnedItem, 1,tonumber(tCellValue.hid))
					table.insert(btnArr,1,turnedItem)
			    end
			end

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
	return ccCell
end
-- 进阶，强化Menu，头像，均为MenuItem
function createTSMenuItems(menu_ms, tCellValue)
	if(tCellValue.isAvatar) then
		local item1 = tCellValue.menu_items[1]
	 	local item2 = tCellValue.menu_items[2]

		require "script/libs/LuaCCMenuItem"
	 	local tSprite = {normal="images/common/btn/btn_blue_n.png", selected="images/common/btn/btn_blue_h.png"}
	 	local tLabel = {text=GetLocalizeStringBy("key_2020"), fontsize=30, }
	 	local ccMenuItemDress = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
	 	ccMenuItemDress:setPosition(item2.pos_x, item2.pos_y)
		ccMenuItemDress:registerScriptTapHandler(function ( ... )
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
			--进入时装场景
			MainScene.setMainSceneViewsVisible(true, false, true)
			require "script/ui/fashion/FashionLayer"
			local fashionLayer = FashionLayer:createFashion()
			MainScene.changeLayer(fashionLayer, "FashionLayer")
		end)
	 	menu_ms:addChild(ccMenuItemDress, 0, item2.tag)
	 	item2.ccObj = ccMenuItemDress


	 	tSprite = {normal="images/common/btn/green01_n.png", selected="images/common/btn/green01_h.png"}
	 	tLabel = {text=GetLocalizeStringBy("key_1730"), fontsize=30, }
	 	local ccMenuItemTransfer = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
	 	ccMenuItemTransfer:setPosition(item1.pos_x, item1.pos_y)
		ccMenuItemTransfer:registerScriptTapHandler(item1.cb)
	 	menu_ms:addChild(ccMenuItemTransfer, 0, item1.tag)
	 	item1.ccObj = ccMenuItemTransfer

	 	return
	end

	if #tCellValue.menu_items == 2 then
		local item
		local tSprite
		local tLabel

		require "script/libs/LuaCCMenuItem"

		require "script/ui/develop/DevelopData"

		if  DevelopData.doOpenDevelopByHid(tCellValue.hid) then
			item = tCellValue.menu_items[1]
		 	tSprite = {normal="images/common/btn/btn_blue_n.png", selected="images/common/btn/btn_blue_h.png"}
		 	tLabel = {text=GetLocalizeStringBy("djn_233"), fontsize=30, }

			local ccMenuEvolution = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
			-- ccMenuEvolution:setAnchorPoint(ccp(0.5,0))
			ccMenuEvolution:setPosition(item.pos_x, item.pos_y)
			ccMenuEvolution:registerScriptTapHandler(item.cb)
			menu_ms:addChild(ccMenuEvolution,0,item.tag)
			item.ccObj = ccMenuEvolution

			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/lvanniu/lvanniu"), -1,CCString:create(""))
		    spellEffectSprite:setPosition(ccMenuEvolution:getContentSize().width*0.5,ccMenuEvolution:getContentSize().height*0.5)
		    ccMenuEvolution:addChild(spellEffectSprite)

		else
			item = tCellValue.menu_items[1]
		 	tSprite = {normal="images/common/btn/green01_n.png", selected="images/common/btn/green01_h.png"}
		 	tLabel = {text=GetLocalizeStringBy("key_1730"), fontsize=30, }
		 	local ccMenuItemTransfer = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
		 	ccMenuItemTransfer:setPosition(item.pos_x, item.pos_y)
			ccMenuItemTransfer:registerScriptTapHandler(item.cb)
		 	menu_ms:addChild(ccMenuItemTransfer, 0, item.tag)
		 	item.ccObj = ccMenuItemTransfer
		end

	 	item = tCellValue.menu_items[2]
	 	tSprite = {normal="images/common/btn/purple01_n.png", selected="images/common/btn/purple01_h.png"}
	 	tLabel = {text=GetLocalizeStringBy("key_1269"), fontsize=30, }
	 	local ccMenuItemStrengthen = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
	 	ccMenuItemStrengthen:setPosition(item.pos_x, item.pos_y)
		ccMenuItemStrengthen:registerScriptTapHandler(item.cb)
	 	menu_ms:addChild(ccMenuItemStrengthen, 0, item.tag)
	 	item.ccObj = ccMenuItemStrengthen
	end
end

-- 出售界面复选框menu_item
function createCheckMenuItems(menu_ms, tCellValue)
	for i=1, #tCellValue.menu_items do
		local menu_item = CCMenuItemImage:create(tCellValue.menu_items[i].normal, tCellValue.menu_items[i].highlighted)
		menu_item:setPosition(ccp(tCellValue.menu_items[i].pos_x, tCellValue.menu_items[i].pos_y))
		local ccSpriteSelected = CCSprite:create("images/common/checked.png")
		if (tCellValue.checkIsSelected) then
			ccSpriteSelected:setVisible(true)
		else
			ccSpriteSelected:setVisible(false)
		end
		menu_item:addChild(ccSpriteSelected, 0, 4001)
		menu_item:registerScriptTapHandler(tCellValue.menu_items[i].cb)
		tCellValue.menu_items[i].ccObj = menu_item
		menu_ms:addChild(menu_item, 0, tCellValue.menu_items[i].tag)
	end
end

function startCellAnimate(cell, animatedIndex )
	local cellBg = tolua.cast(cell:getChildByTag(1), "CCSprite")
	cellBg:setPosition(ccp(cell:getContentSize().width, 0))
	cellBg:runAction(CCMoveTo:create(g_cellAnimateDuration * (animatedIndex ), ccp(0,0)))
end