-- Filename：	TreasBagCell.lua
-- Author：		Cheng Liang
-- Date：		2013-7-12
-- Purpose：		EquipCell

module("TreasBagCell", package.seeall)


require "script/ui/common/CheckBoxItem"
require "script/utils/LuaUtil"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/item/TreasReinforceLayer"

local _enhanceDelegate = nil
local _selectList = nil

--[[
	@des  : 进阶回调
--]]
function developBtnAction( tag, itemBtn  )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	
	require "script/ui/treasure/develop/TreasureDevelopLayer"
	local item_id = tag
	TreasureDevelopLayer.showLayer(item_id)
	-- 设置界面记忆
	TreasureDevelopLayer.setChangeLayerMark( TreasureDevelopLayer.kTagBag )
	
	-- 记忆背包位置
	BagLayer.setMarkTreasureItemId(item_id)
end

local function enhanceAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if not DataCache.getSwitchNodeState(ksSwitchTreasureForge,true) then
        return
    end

	-- 强化装备
	local item_id = tag
	local enforceLayer = TreasReinforceLayer.createLayer(item_id, _enhanceDelegate,true)
	local onRunningLayer = MainScene.getOnRunningLayer()
	onRunningLayer:addChild(enforceLayer, 10)

	-- 记忆背包位置
	BagLayer.setMarkTreasureItemId(item_id)
	-- 默认cell关闭状态
	BagLayer.setOpenIndex(nil)
end 

-- 洗练宝物
local function breachAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 
	if not DataCache.getSwitchNodeState(ksSwitchTreasureFixed,true) then
        return
    end

	local item_id = tag
	local treasureInfo 			= ItemUtil.getItemInfoByItemId(tonumber(item_id))
	if(table.isEmpty(treasureInfo))then
		treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(item_id))
	end
	if(tonumber(treasureInfo.itemDesc.isUpgrade)  ~= 1) then
		require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2022"), nil, false, nil)
        return
	end
	require "script/ui/treasure/evolve/TreasureEvolveMainView"
	local upgradeLayer = TreasureEvolveMainView.createLayer(item_id, _enhanceDelegate)
	TreasureEvolveMainView.setFromLayerTag(TreasureEvolveMainView.kTreasureListTag)
	MainScene.changeLayer(upgradeLayer, "evolveLayer")

	-- 记忆背包位置
	BagLayer.setMarkTreasureItemId(item_id)
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

-- -- 检查checked 的宝物
-- local function handleSelectedCheckedBtn( checkedBtn )
-- 	local selecedList = TreasReinforceLayer.getMaterialsArr()
-- 	if ( table.isEmpty(selecedList) ) then
-- 		checkedBtn:unselected()
-- 	else
-- 		local isIn = false
-- 		for k,v in pairs(selecedList) do
-- 			if ( tonumber(v.item_id) == tonumber(checkedBtn:getTag()) ) then
-- 				isIn = true
-- 				break
-- 			end
-- 		end
-- 		if (isIn) then
-- 			checkedBtn:selected()
-- 		else
-- 			checkedBtn:unselected()
-- 		end
-- 	end
-- end

--[[
	@des 	:检查被选择的材料
	@param 	:
	@return :
--]]
function handleSelectedCheckedBtn( checkedBtn )
	if(_selectList == nil)then
		return
	end
	if ( table.isEmpty(_selectList) ) then
		checkedBtn:unselected()
	else
		local isIn = false
		for k,v in pairs(_selectList) do
			if ( tonumber(v.item_id) == tonumber(checkedBtn:getTag()) ) then
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

-- 宝物强化选择的cai
local function enhanceCheckedAction( tag, itemBtn )
	
end 

-- 创建 isForEnhanceMaterial <==> 作为强化的备选材料
function createTreasCell( treasData, isSell, enhanceDelegate, isForEnhanceMaterial, p_menuPriority, p_selectList, pIsBag, pIndex )
	_enhanceDelegate = enhanceDelegate
	_selectList = p_selectList
	-- 是否是叠加宝物
	local isMany = false
	if( tonumber(treasData.itemDesc.maxStacking) > 1 )then
		isMany = true
	end

	local tCell = CCTableViewCell:create()
	-- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(640,240))
    cellBg:setAnchorPoint(ccp(0.5,0))
    cellBg:setPosition(320,0)
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = ItemSprite.getItemSpriteById( tonumber(treasData.item_template_id), tonumber(treasData.item_id), enhanceDelegate )
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

  	-- 等级
	local lvBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
    lvBg:setContentSize(CCSizeMake(100,30))
    lvBg:setAnchorPoint(ccp(0,1))
    lvBg:setPosition(ccp(18,cellBgSize.height-170))
	cellBg:addChild(lvBg)

    if(isMany)then
    	-- 叠加物品
    	-- 数量
		local numLabel = CCRenderLabel:create( GetLocalizeStringBy("lic_1584") .. treasData.item_num, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    numLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    numLabel:setAnchorPoint(ccp(0.5,0.5))
	    numLabel:setPosition(ccp(lvBg:getContentSize().width*0.5, lvBg:getContentSize().height*0.5))
	    lvBg:addChild(numLabel)
    else
		local t_level = 0
		if( (not table.isEmpty(treasData.va_item_text) and treasData.va_item_text.treasureLevel ))then
			t_level = treasData.va_item_text.treasureLevel
		end
		local levelLabel = CCRenderLabel:create("+" .. t_level, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    levelLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
	    levelLabel:setAnchorPoint(ccp(0.5,0.5))
	    levelLabel:setPosition(ccp(lvBg:getContentSize().width*0.5, lvBg:getContentSize().height*0.5))
	    lvBg:addChild(levelLabel)
	end

    -- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(treasData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height-40))
    cellBg:addChild(sealSprite)

	-- 名称
	local quality = ItemUtil.getTreasureQualityByItemInfo( treasData)
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = ItemUtil.getTreasureNameByItemInfo( treasData, g_sFontName, 28 )
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	nameLabel:setVisible(false)
    end
    nameLabel:setPosition(ccp(cellBgSize.width*0.2+ sealSprite:getContentSize().width+5, cellBgSize.height-40))
    cellBg:addChild(nameLabel)

	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))

	-- 星级
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setAnchorPoint(ccp(0.5, 0.5))

    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(280,100))
    attrBg:setAnchorPoint(ccp(0,1))
    attrBg:setPosition(ccp(120,cellBgSize.height-65))
    cellBg:addChild(attrBg)

    -- 分割线
    local line = CCScale9Sprite:create("images/common/line02.png")
    line:setContentSize(CCSizeMake(90,4))
    line:setAnchorPoint(ccp(0.5,0.5))
    line:setPosition(ccp(160,attrBg:getContentSize().height*0.5))
    attrBg:addChild(line)
    line:setRotation(90)

    -- 获得相关数值
	local attr_arr, score_t, ext_active = ItemUtil.getTreasAttrByItemId( tonumber(treasData.item_id), treasData)
	local descString = ""
	local i = 0
	for key,attr_info in pairs(attr_arr) do
		i = i + 1
	    local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(attr_info.attId, attr_info.num)
	    descString = descString .. affixDesc.sigleName .. " +"
		descString = descString .. displayNum .. "\n"
		if( i >= 3)then
			break
		end
	end

	-- 处理 经验金马 经验银马 经验金书 经验银书
	if( (tonumber(treasData.itemDesc.isExpTreasure) == 1) )then
		descString = GetLocalizeStringBy("key_2531")
		
		-- 提供经验的数值
		local add_exp = tonumber(treasData.itemDesc.base_exp_arr)
		if(treasData.va_item_text and treasData.va_item_text.treasureExp)then
			add_exp = add_exp + tonumber(treasData.va_item_text.treasureExp)
		end
		local add_exp_label = CCLabelTTF:create("+" .. add_exp, g_sFontName, 23)
		add_exp_label:setColor(ccc3(0x00, 0x6d, 0x2f))
		add_exp_label:setAnchorPoint(ccp(0, 0.5))
		add_exp_label:setPosition(ccp(10, attrBg:getContentSize().height*0.5))
		attrBg:addChild(add_exp_label)

		-- 经验银书马转特效
		if( tonumber(treasData.item_template_id) == 501001 or tonumber(treasData.item_template_id) == 502001 )then
			if( add_exp > tonumber(treasData.itemDesc.base_exp_arr) )then 
				local effectSp = XMLSprite:create("images/base/effect/suit/lzpurple")
				effectSp:setPosition(ccp(iconSprite:getContentSize().width*0.5, iconSprite:getContentSize().height*0.5))
				iconSprite:addChild(effectSp,10)
			end
		end
	end

	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 23, CCSizeMake(300, 100), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(10, attrBg:getContentSize().height*0.35))
	attrBg:addChild(descLabel)

	-- 品级
    local pinSp = CCSprite:create("images/god_weapon/pin.png")
    pinSp:setAnchorPoint(ccp(0, 1))
    pinSp:setPosition(ccp(185, attrBg:getContentSize().height))
    attrBg:addChild(pinSp)

	-- 评分
	local equipScoreLabel = CCRenderLabel:create(score_t.num, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    equipScoreLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    equipScoreLabel:setAnchorPoint(ccp(0,0))

    --兼容东南亚英文版
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	potentialLabel:setPosition(210, 30)
    	attrBg:addChild(potentialLabel)
	    starSp:setPosition(ccp( 250, 30))
	    attrBg:addChild(starSp)
	    equipScoreLabel:setPosition(ccp(170, 20))
	    attrBg:addChild(equipScoreLabel)
    else
	    potentialLabel:setPosition(cellBgSize.width*365.0/640, cellBgSize.height-40)
	    cellBg:addChild(potentialLabel)
	    starSp:setPosition(ccp( cellBgSize.width*390.0/640, cellBgSize.height-40))
	    cellBg:addChild(starSp)
	    equipScoreLabel:setPosition(ccp(192, 20))
	    attrBg:addChild(equipScoreLabel)
    end

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)

	if(p_menuPriority)then
		menuBar:setTouchPriority(p_menuPriority)
	end

	if (isSell) then
		-- print_t(treasData)
		-- 钱币背景
		local coinBg = CCSprite:create("images/common/coin.png")
		coinBg:setAnchorPoint(ccp(0.5, 0.5))
		coinBg:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.5))
		cellBg:addChild(coinBg)

		-- 卖多少
		local coinLabel = CCRenderLabel:create( BagLayer.getPriceByEquipData(treasData), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		coinLabel:setColor(ccc3(0x6c, 0xff, 0x00))
		coinLabel:setAnchorPoint(ccp(0, 0.5))
		coinLabel:setPosition(ccp(cellBgSize.width*0.73, cellBgSize.height*0.5))
		cellBg:addChild(coinLabel)

		-- 复选框
		local checkedBtn = CheckBoxItem.create()
		checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
	    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
	    checkedBtn:registerScriptTapHandler(checkedAction)

		menuBar:addChild(checkedBtn, 1, treasData.gid)
		handleCheckedBtn(checkedBtn)
	elseif(isForEnhanceMaterial)then
		-- 经验
		local expSprite = CCSprite:create("images/common/exp.png")
		expSprite:setAnchorPoint(ccp(0.5, 0.5))
		expSprite:setPosition(ccp(cellBgSize.width*450/640, cellBgSize.height*0.5))
		cellBg:addChild(expSprite)

		-- 经验数字
		local addExp = tonumber(treasData.itemDesc.base_exp_arr) 
		if(treasData.va_item_text and treasData.va_item_text.treasureExp)then
			addExp = addExp +tonumber(treasData.va_item_text.treasureExp)
		end
		local expNumLabel = CCRenderLabel:create(addExp, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    expNumLabel:setColor(ccc3(0x8a, 0xff, 0x00))
	    expNumLabel:setAnchorPoint(ccp(0.5,0.5))
	    expNumLabel:setPosition(ccp(cellBgSize.width*505/640, cellBgSize.height*0.5))
	    cellBg:addChild(expNumLabel)

		if( isMany )then
			-- 已选择数量
			local num = 0
			for k,v in pairs(_selectList) do 
				if(tonumber(v.item_id) == tonumber(treasData.item_id) )then 
					num = v.num
				end
			end
			local chooseLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1586",num), g_sFontName,20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
		    chooseLabel:setColor(ccc3(0x00, 0xff, 0x18))
		    chooseLabel:setAnchorPoint(ccp(0.5,0.5))
		    chooseLabel:setPosition(cellBgSize.width*0.8, cellBgSize.height*0.3)
		    cellBg:addChild(chooseLabel)

			-- 选择回调
			local chooseBtnCallBack = function ( )
				-- print("chooseBtnCallBack11")
				-- 音效
				require "script/audio/AudioUtil"
				AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
				local selectList = TreasReinforceLayer.getMaterialsArr()
				local chooseNum = table.count(selectList)
				if( chooseNum >= 5 )then  
					-- 五个了 不能再选择了
					AnimationTip.showTip(GetLocalizeStringBy("key_1861"))
					return
				end

				require "script/utils/SelectNumDialog"
			    local dialog = SelectNumDialog:create()
			    dialog:setTitle(GetLocalizeStringBy("lic_1585"))
			    dialog:show(-560, 1010)
			    dialog:setMinNum(0)
			    local maxNum = 50
			    if(tonumber(treasData.item_num) < 50)then
			    	maxNum = tonumber(treasData.item_num)
			    end
			    dialog:setLimitNum(maxNum)

			    local curNum = 0
			    for k,v in pairs(selectList) do
			    	if(tonumber(v.item_id) == tonumber(treasData.item_id))then
			    		curNum = v.num
			    		break
			    	end
			    end
			    dialog:setNum(curNum)
		    	dialog:registerOkCallback(function ()
		          	local chooseNum = dialog:getNum()
		          	chooseLabel:setString(GetLocalizeStringBy("lic_1586",chooseNum))
		         
	          		TreasSelectLayer.checkedSelectCell(treasData.item_id,chooseNum)
	          		TreasSelectLayer.refreshBottomSprite()
		          	
		        end)

		        -- 最多选择50个
		        local maxLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1587"), g_sFontName,30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
			    maxLabel:setColor(ccc3(0xff, 0xf6, 0x00))
			    maxLabel:setAnchorPoint(ccp(0.5,0.5))
			    maxLabel:setPosition(dialog:getContentSize().width*0.5, dialog:getContentSize().height*0.7)
			    dialog:addChild(maxLabel)
			end 

		 	-- 选择
			local chooseBtn = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("lic_1585"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			chooseBtn:setAnchorPoint(ccp(0.5, 0.5))
		    chooseBtn:setPosition(ccp(cellBgSize.width*0.8, cellBgSize.height*0.7))
			menuBar:addChild(chooseBtn, 1)
			chooseBtn:registerScriptTapHandler(chooseBtnCallBack)
			
		else
			-- 复选框
			local checkedBtn = CheckBoxItem.create()
			checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
		    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
			menuBar:addChild(checkedBtn, 1, tonumber(treasData.item_id) )
			checkedBtn:setEnabled(false)
			-- 检查是否被选择
			handleSelectedCheckedBtn(checkedBtn)
		end	
	else
		if( not(BagUtil.isSupportBagCell() and pIsBag) )then
			local enhanceBtn = LuaMenuItem.createItemImage("images/item/equipinfo/btn_enhance_n.png", "images/item/equipinfo/btn_enhance_h.png" )
			enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
		    enhanceBtn:setPosition(ccp(cellBgSize.width*0.87, cellBgSize.height*0.6))
		    enhanceBtn:registerScriptTapHandler(enhanceAction)
			menuBar:addChild(enhanceBtn, 1, tonumber(treasData.item_id))

			-- 洗练
			require "script/libs/LuaCC"
			--兼容越南 东南亚英文版
			local fontSize = nil
	    	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	    		fontSize = 22
	    	else
	    		fontSize = 30
	    	end
			local breachBtn = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("key_2943"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			breachBtn:setAnchorPoint(ccp(0.5, 0.5))
			breachBtn:registerScriptTapHandler(breachAction)
			breachBtn:setPosition(ccp(cellBgSize.width*0.87, cellBgSize.height*0.25))
			menuBar:addChild(breachBtn, 1, tonumber(treasData.item_id) )

			-- 进阶
			if(tonumber(treasData.itemDesc.can_evolve) == 1)then
				local developBtn = CCMenuItemImage:create("images/treasure/develop/develop_n.png", "images/treasure/develop/develop_h.png")
				developBtn:setAnchorPoint(ccp(0.5, 0.5))
				developBtn:registerScriptTapHandler(developBtnAction)
				developBtn:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.5))
				menuBar:addChild(developBtn, 1, tonumber(treasData.item_id) )
			end

			if(isMany)then 
				enhanceBtn:setVisible(false)
				breachBtn:setVisible(false)
			end

			-- 1可强化
			if( treasData.itemDesc.isStrengthen == nil or tonumber(treasData.itemDesc.isStrengthen) == 0 )then
				enhanceBtn:setVisible(false)
				breachBtn:setVisible(false)
			end
		end
	end
	if(treasData.equip_hid and tonumber(treasData.equip_hid) > 0)then
		-- local being_front = CCSprite:create("images/hero/being_fronted.png")
		-- being_front:setPosition(ccp(532, 88))
		-- cellBg:addChild(being_front)
		local localHero = HeroUtil.getHeroInfoByHid(treasData.equip_hid)
		local heroName = localHero.localInfo.name
		if(HeroModel.isNecessaryHeroByHid(treasData.equip_hid)) then
			heroName = UserModel.getUserName()
		end
		local onFormationText =  CCRenderLabel:create(GetLocalizeStringBy("key_1783").. heroName, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    onFormationText:setColor(ccc3(0x8a, 0xff, 0x00))
	    onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.9))
	    cellBg:addChild(onFormationText)
	end

	if(tonumber(treasData.itemDesc.can_evolve) == 1)then
		-- 若可以镶嵌
		local posX = {155,220,285,350}
		for i=1,4 do
			local runeBg = getRuneSprite(i,treasData)
			runeBg:setAnchorPoint(ccp(0.5,0.5))
			runeBg:setPosition(ccp(posX[i], 40))
			cellBg:addChild(runeBg)
			runeBg:setScale(0.5)
		end
	end

	-- 展开逻辑
	if( isMany == false and BagUtil.isSupportBagCell() and pIsBag)then
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
			local isOpen = DataCache.getSwitchNodeState(ksSwitchTreasureForge,false)
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
			local enhanceMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1422"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			enhanceMenuItem:setAnchorPoint(ccp(0.5, 0.5))
			enhanceMenuItem:registerScriptTapHandler(enhanceAction)
			buttnMenu:addChild(enhanceMenuItem, 1, tonumber(treasData.item_id))
			table.insert(btnArr,1,enhanceMenuItem)
			-- 开启等级
			if(isOpen == false)then
				require "db/DB_Switch"
				local switchInfo = DB_Switch.getDataById(ksSwitchTreasureForge)
				local needLv = switchInfo.level or 1
				local tipFont =  CCRenderLabel:create(GetLocalizeStringBy("lic_1823",needLv), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    		tipFont:setColor(ccc3(0xff, 0xff, 0xff))
	    		tipFont:setAnchorPoint(ccp(0.5,1))
	    		tipFont:setPosition(ccp(enhanceMenuItem:getContentSize().width*0.5, 0))
	    		enhanceMenuItem:addChild(tipFont)
	    		allOpen = false
	    	end

			-- 洗炼
			if(tonumber(treasData.itemDesc.isUpgrade) == 1)then
				local isOpen = DataCache.getSwitchNodeState(ksSwitchTreasureFixed,false)
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
				local fixMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1824"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				fixMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				fixMenuItem:registerScriptTapHandler(breachAction)
				buttnMenu:addChild(fixMenuItem, 1, tonumber(treasData.item_id))
				table.insert(btnArr,1,fixMenuItem)

				-- 开启等级
				if(isOpen == false)then
					require "db/DB_Switch"
					local switchInfo = DB_Switch.getDataById(ksSwitchTreasureFixed)
					local needLv = switchInfo.level or 1
					local tipFont =  CCRenderLabel:create(GetLocalizeStringBy("lic_1823",needLv), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    		tipFont:setColor(ccc3(0xff, 0xff, 0xff))
		    		tipFont:setAnchorPoint(ccp(0.5,1))
		    		tipFont:setPosition(ccp(fixMenuItem:getContentSize().width*0.5, 0))
		    		fixMenuItem:addChild(tipFont)
		    		allOpen = false
		    	end
			end
			
			if(tonumber(treasData.itemDesc.can_evolve) == 1)then
				-- 进阶
			  	local normalFile = "images/common/btn/btn_s_n.png"
				local selectFile = "images/common/btn/btn_s_h.png"
				local fontColor = ccc3(0xff, 0xf2, 0x5d)
			    local developMenuItem =LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1423"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				developMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				developMenuItem:registerScriptTapHandler(developBtnAction)
				buttnMenu:addChild(developMenuItem, 1, tonumber(treasData.item_id))
				table.insert(btnArr,1,developMenuItem)

				-- 符印
				-- 战马印 兵书符
				local typeName = {GetLocalizeStringBy("lic_1538"),GetLocalizeStringBy("lic_1539")}
				local normalFile = "images/common/btn/btn_s_n.png"
				local selectFile = "images/common/btn/btn_s_h.png"
				local fontColor = ccc3(0xff, 0xf2, 0x5d)
			    local runeMenuItem =LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), typeName[tonumber(treasData.itemDesc.type)],fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				runeMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				runeMenuItem:registerScriptTapHandler(function ( ... )
					-- 音效
					require "script/audio/AudioUtil"
					AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
					-- 宝物信息
					require "script/ui/item/TreasureInfoLayer"
					local treasInfoLayer = TreasureInfoLayer:createWithItemId(tonumber(treasData.item_id), TreasInfoType.BAG_TYPE)
					treasInfoLayer:show()
					-- 记忆背包位置
					BagLayer.setMarkTreasureItemId(tonumber(treasData.item_id))
					-- 默认cell关闭状态
					BagLayer.setOpenIndex(nil)
					if(enhanceDelegate)then
						enhanceDelegate()
					end
				end)
				buttnMenu:addChild(runeMenuItem, 1, tonumber(treasData.item_id))
				table.insert(btnArr,1,runeMenuItem)
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


function startTreasCellAnimate( equipCell, animatedIndex )
	
	local cellBg = tolua.cast(equipCell:getChildByTag(1), "CCSprite")
	cellBg:setPosition(ccp(cellBg:getContentSize().width, 0))
	cellBg:runAction(CCMoveTo:create(g_cellAnimateDuration * (animatedIndex ), ccp(0,0)))
end


--[[
	@des 	: 得到符印图标
	@param 	: $p_index 		:第几个符印位置,p_tresData宝物数据
	@return : sprite
--]]
function getRuneSprite(p_index,p_tresData)
	local iconBg = CCSprite:create("images/common/rune_bg_b.png")
	
	if(p_tresData.va_item_text and p_tresData.va_item_text.treasureInlay and p_tresData.va_item_text.treasureInlay[tostring(p_index)] )then
		-- 有符印
		local runeItemInfo = p_tresData.va_item_text.treasureInlay[tostring(p_index)]
		local runeIcon = ItemSprite.getItemSpriteByItemId(runeItemInfo.item_template_id)
		runeIcon:setAnchorPoint(ccp(0.5,0.5))
		runeIcon:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
		iconBg:addChild(runeIcon)
	else
		-- 没有符印
		require "script/ui/treasure/TreasureData"
		local isOpen,needNum = TreasureData.getRunePosIsOpen(p_tresData.item_template_id,p_tresData.item_id,p_tresData,p_index)
		if(isOpen)then
			-- 开启 加号
			local addSprite = CCSprite:create("images/common/add_new.png")
			addSprite:setAnchorPoint(ccp(0.5,0.5))
			addSprite:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
			iconBg:addChild(addSprite)
		else
			-- 没开启 锁
			local lockSp = CCSprite:create("images/common/rune_lock_b.png")
			lockSp:setAnchorPoint(ccp(0.5,0.5))
			lockSp:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
			iconBg:addChild(lockSp)
		end
	end
	return iconBg
end
