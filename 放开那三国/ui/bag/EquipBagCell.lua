-- Filename：	EquipBagCell.lua
-- Author：		Cheng Liang
-- Date：		2013-7-12
-- Purpose：		EquipCell

module("EquipBagCell", package.seeall)


require "script/ui/common/CheckBoxItem"
require "script/utils/LuaUtil"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"

local _enhanceDelegate = nil
--[[
	@des 	: 装备进阶回调 add by yangrui 15-10-29
	@param 	: 
	@return : 
--]]
function devBtnCallback( tag, itemBtn )
	if DataCache.getSwitchNodeState(ksSwitchRedEquip) then
		local equipId = tag
		-- 进入进阶
		require "script/ui/redequip/RedEquipLayer"
		RedEquipLayer.setChangeLayerMark(RedEquipLayer.kTagBag)
		RedEquipLayer.showLayer(equipId)
		-- 记忆背包位置
		require "script/ui/bag/BagLayer"
		BagLayer.setMarkEquipItemId( equipId )
	end
end

-- 强化装备
local function enhanceAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 强化装备
	local item_id = tag
	local enforceLayer = EquipReinforceLayer.createLayer(item_id, _enhanceDelegate)
	local onRunningLayer = MainScene.getOnRunningLayer()
	onRunningLayer:addChild(enforceLayer, 10)

	-- 记忆背包位置
	require "script/ui/bag/BagLayer"
	BagLayer.setMarkEquipItemId( item_id )
	-- 默认cell关闭状态
	BagLayer.setOpenIndex(nil)
end 

-- 洗练装备
local function breachAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 洗练装备
	if(not DataCache.getSwitchNodeState(ksSwitchEquipFixed, true)) then
		return	
	end

	local item_id = tag
	require "script/ui/item/EquipFixedLayer"
	EquipFixedLayer.show(item_id, EquipFixedLayer.kEquipBagType)

	-- 记忆背包位置
	require "script/ui/bag/BagLayer"
	BagLayer.setMarkEquipItemId( item_id )
end 

-- checked 的相应处理
local function checkedAction( tag, itemMenu )

	local sellList = BagLayer.getSellEquipList()
	if ( table.isEmpty(sellList) ) then
		sellList = {}
		table.insert(sellList, tag)
		itemMenu:selected()
	else
		local isIn = false
		local index = -1
		for k,g_id in pairs(sellList) do
			if ( tonumber(g_id) == tag ) then
				isIn = true
				index = k
				break
			end
		end
		if (isIn) then
			table.remove(sellList, index)
			itemMenu:unselected()
		else
			table.insert(sellList, tag)
			itemMenu:selected()
		end
	end
	BagLayer.setSellEquipList(sellList)
end

-- 检查checked按钮
local function handleCheckedBtn( checkedBtn )

	local sellList = BagLayer.getSellEquipList()
	if ( table.isEmpty(sellList) ) then
		checkedBtn:unselected()
	else
		local isIn = false
		for k,g_id in pairs(sellList) do
			if ( tonumber(g_id) == checkedBtn:getTag() ) then
				isIn = true
				break
			end
		end
		if (isIn) then
			checkedBtn:selected()
		else
			checkedBtn:unselected()
		end
	end
end

-- 创建
function createEquipCell( equipData, isSell, enhanceDelegate, pIsBag, pIndex )
	local itemData = ItemUtil.getItemByItemId(tonumber(equipData.item_id))
	if(itemData == nil)then
		itemData = ItemUtil.getEquipInfoFromHeroByItemId(tonumber(equipData.item_id))
	end
	if( table.isEmpty(itemData.itemDesc) )then
		itemData.itemDesc = ItemUtil.getItemById(tonumber(itemData.item_template_id))
	end

	_enhanceDelegate = enhanceDelegate
	local tCell = CCTableViewCell:create()
	--背景
	local cellBg = CCSprite:create("images/bag/equip/equip_cellbg.png")
	cellBg:setAnchorPoint(ccp(0.5,0))
	cellBg:setPosition(320,0)
	tCell:addChild(cellBg,10,1)
	local cellBgSize = cellBg:getContentSize()
	-- icon
	local iconSprite = ItemSprite.getItemSpriteById( tonumber(equipData.item_template_id), tonumber(equipData.item_id), enhanceDelegate,nil,nil,nil,nil,nil,nil,nil,true,nil,nil,nil,nil,equipData )
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	if(equipData.itemDesc.jobLimit and equipData.itemDesc.jobLimit > 0)then
		local suitTagSprite = CCSprite:create("images/common/suit_tag.png")
		suitTagSprite:setAnchorPoint(ccp(0.5, 0.5))
		suitTagSprite:setPosition(ccp(iconSprite:getContentSize().width*0.25, iconSprite:getContentSize().height*0.9))
		iconSprite:addChild(suitTagSprite)
	end
	-- 等级
	local levelLabel = CCRenderLabel:create(equipData.va_item_text.armReinforceLevel, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setPosition(ccp(cellBgSize.width*0.1, cellBgSize.height*0.26))
    cellBg:addChild(levelLabel)
	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(equipData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)
	-- 名称
	local quality = ItemUtil.getEquipQualityByItemInfo( equipData )

	local nameLabel = ItemUtil.getEquipNameByItemInfo(equipData,g_sFontName,28)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)
	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    cellBg:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    cellBg:addChild(potentialLabel)

	-- 映射关系
	local showAttrId = {1,9,2,3,4,5}
	local baseData = EquipAffixModel.getEquipAffixById(equipData.item_id)
	local fixData = EquipAffixModel.getEquipFixedAffix(equipData)
	local developData = EquipAffixModel.getDevelopAffixByInfo(equipData)
	for k,v in pairs(baseData) do
		if(fixData[k])then 
			baseData[k] = baseData[k]+fixData[k] 
		end
		if(developData[k])then 
			baseData[k] = baseData[k] + developData[k] 
		end
	end
	local descString = ""
	local i = 0
	for k,v_id in pairs(showAttrId) do
		if( baseData[v_id] > 0 )then
			i = i + 1
		    local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(v_id,baseData[v_id])
		    descString = descString .. affixDesc.sigleName .. " +"
			descString = descString .. displayNum .. "\n"
			if( i >= 3)then
				break
			end
		end
	end

	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 23, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(cellBgSize.width*0.21, cellBgSize.height*0.4))
	cellBg:addChild(descLabel)

	-- 评分
	local equipScoreLabel = CCRenderLabel:create(equipData.itemDesc.base_score, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    equipScoreLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    cellBg:addChild(equipScoreLabel)

     --兼容东南亚英文版
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	potentialLabel:setPosition(335, cellBgSize.height*0.36)  -- x:+45
	    starSp:setPosition(ccp( 370, cellBgSize.height*0.3))  -- x:+45
	    equipScoreLabel:setPosition(ccp(370, cellBgSize.height*0.35))
    else
	    potentialLabel:setPosition(cellBgSize.width*375.0/640, cellBgSize.height-18)  -- x:+45  y:*0.87
	    starSp:setPosition(ccp( cellBgSize.width*410.0/640, cellBgSize.height-35))  -- x:+45  y:*0.8
	    equipScoreLabel:setPosition(ccp((cellBgSize.width*1.05-equipScoreLabel:getContentSize().width)/2, cellBgSize.height*0.35))
    end

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)
	
	if (isSell) then
		-- 钱币背景
		local coinBg = CCSprite:create("images/common/coin.png")
		coinBg:setAnchorPoint(ccp(0.5, 0.5))
		coinBg:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.5))
		cellBg:addChild(coinBg)

		-- 卖多少
		local coinLabel = CCRenderLabel:create( BagLayer.getPriceByEquipData(equipData), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		coinLabel:setColor(ccc3(0x6c, 0xff, 0x00))
		coinLabel:setAnchorPoint(ccp(0, 0.5))
		coinLabel:setPosition(ccp(cellBgSize.width*0.73, cellBgSize.height*0.5))
		cellBg:addChild(coinLabel)

		-- 复选框
		local checkedBtn = CheckBoxItem.create()
		checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
	    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
	    checkedBtn:registerScriptTapHandler(checkedAction)

		menuBar:addChild(checkedBtn, 1, tonumber(equipData.gid))
		handleCheckedBtn(checkedBtn)
	else
		if( not(BagUtil.isSupportBagCell() and pIsBag) )then
			-- 强化
			local enhanceBtn = LuaMenuItem.createItemImage("images/item/equipinfo/btn_enhance_n.png", "images/item/equipinfo/btn_enhance_h.png", enhanceAction )
			enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
		    enhanceBtn:setPosition(ccp(cellBgSize.width*0.88, cellBgSize.height*0.6))  -- x:0.8 modify by yangrui
		    -- enhanceBtn:registerScriptTapHandler(menuAction)
			menuBar:addChild(enhanceBtn, 1, equipData.item_id)

			-- 洗练
			require "script/libs/LuaCC"
			--兼容越南 东南亚英文版
			local fontSize = nil
	    	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	    		fontSize = 22
	    	else
	    		fontSize = 30
	    	end
			local breachBtn = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("key_1719"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			breachBtn:setAnchorPoint(ccp(0.5, 0.5))
			breachBtn:registerScriptTapHandler(breachAction)
			breachBtn:setPosition(ccp(cellBgSize.width*0.88, cellBgSize.height*0.25))  -- x:0.8 modify by yangrui
			menuBar:addChild(breachBtn, 1, equipData.item_id )
			-- 进阶 add by yangrui 15-10-29
			if equipData.itemDesc.new_quality ~= nil then
				require "db/DB_Normal_config"
				local userLv = UserModel.getHeroLevel()
				local showLv = DB_Normal_config.getDataById(1).jinjiedisplay_lv
				if (userLv >= showLv) then
					-- 进阶按钮
					local devBtn = CCMenuItemImage:create("images/treasure/develop/develop_n.png", "images/treasure/develop/develop_h.png")
					devBtn:setAnchorPoint(ccp(0.5,0.5))
					devBtn:registerScriptTapHandler(devBtnCallback)
					devBtn:setPosition(ccp(cellBgSize.width*0.72,cellBgSize.height*0.5))
					devBtn:setScale(0.9)  -- 不得已缩小了0.9 得到了策划的同意
					menuBar:addChild(devBtn,1,tonumber(equipData.item_id))
				end
			end
		end
	end
	if(equipData.equip_hid and tonumber(equipData.equip_hid) > 0)then
		local localHero = HeroUtil.getHeroInfoByHid(equipData.equip_hid)
		local heroName = localHero.localInfo.name
		if(HeroModel.isNecessaryHeroByHid(equipData.equip_hid)) then
			heroName = UserModel.getUserName()
		end
		local onFormationText =  CCRenderLabel:create(GetLocalizeStringBy("key_1381") .. heroName, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    onFormationText:setColor(ccc3(0x8a, 0xff, 0x00))
	    onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.9))
	    cellBg:addChild(onFormationText)
	end

	-- add by licong 紫色5星装备图标 加锁icon
	if(equipData.va_item_text.lock and tonumber(equipData.va_item_text.lock) ==1) then
		local lockSp= CCSprite:create("images/hero/lock.png")
		lockSp:setAnchorPoint(ccp(0.5,0.5))
		local posX = iconSprite:getPositionX()+iconSprite:getContentSize().width/2
		local posY = iconSprite:getPositionY()+iconSprite:getContentSize().height/2
		lockSp:setPosition(ccp(posX,posY))
		cellBg:addChild(lockSp)
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
		    local enhanceMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_s_n.png", "images/common/btn/btn_s_h.png",CCSizeMake(81, 76), GetLocalizeStringBy("lic_1422"),ccc3(0xfe, 0xdb, 0x1c),24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			enhanceMenuItem:setAnchorPoint(ccp(0.5, 0.5))
			enhanceMenuItem:registerScriptTapHandler(enhanceAction)
			buttnMenu:addChild(enhanceMenuItem, 1, tonumber(equipData.item_id))
			table.insert(btnArr,enhanceMenuItem)
			-- 洗练
			if(tonumber(equipData.itemDesc.fixedPropertyRefreshable) == 1)then
				local isOpen = DataCache.getSwitchNodeState(ksSwitchEquipFixed,false)
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
				local fixMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1822"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				fixMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				fixMenuItem:registerScriptTapHandler(breachAction)
				buttnMenu:addChild(fixMenuItem, 1, tonumber(equipData.item_id))
				table.insert(btnArr,1,fixMenuItem)

				-- 开启等级
				if(isOpen == false)then
					require "db/DB_Switch"
					local switchInfo = DB_Switch.getDataById(ksSwitchEquipFixed)
					local needLv = switchInfo.level or 1
					local tipFont =  CCRenderLabel:create(GetLocalizeStringBy("lic_1823",needLv), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    		tipFont:setColor(ccc3(0xff, 0xff, 0xff))
		    		tipFont:setAnchorPoint(ccp(0.5,1))
		    		tipFont:setPosition(ccp(fixMenuItem:getContentSize().width*0.5, 0))
		    		fixMenuItem:addChild(tipFont)

		    		allOpen = false
		    	end
			end

			-- 进阶
			if(equipData.itemDesc.new_quality ~= nil)then
				local isOpen = DataCache.getSwitchNodeState(ksSwitchRedEquip,false)
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
			    local developMenuItem =LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1423"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				developMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				developMenuItem:registerScriptTapHandler(devBtnCallback)
				buttnMenu:addChild(developMenuItem, 1, tonumber(equipData.item_id))
				table.insert(btnArr,1,developMenuItem)

				-- 开启等级
				if(isOpen == false)then
					require "db/DB_Switch"
					local switchInfo = DB_Switch.getDataById(ksSwitchRedEquip)
					local needLv = switchInfo.level or 1
					local tipFont =  CCRenderLabel:create(GetLocalizeStringBy("lic_1823",needLv), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    		tipFont:setColor(ccc3(0xff, 0xff, 0xff))
		    		tipFont:setAnchorPoint(ccp(0.5,1))
		    		tipFont:setPosition(ccp(developMenuItem:getContentSize().width*0.5, 0))
		    		developMenuItem:addChild(tipFont)

		    		allOpen = false
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

	return tCell
end

function setCellValue( ... )

end

function startEquipCellAnimate( equipCell, animatedIndex )
	
	-- local cellBg = tolua.cast(equipCell:getChildByTag(1), "CCSprite")
	-- cellBg:setPosition(ccp(cellBg:getContentSize().width, 0))
	local posX = equipCell:getPositionX()
	local posY = equipCell:getPositionY()
	equipCell:setPosition(ccp(posX+640, posY))
	equipCell:runAction(CCMoveTo:create(g_cellAnimateDuration*animatedIndex, ccp(posX,posY)))
end
