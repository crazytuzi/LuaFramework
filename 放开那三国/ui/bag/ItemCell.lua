-- Filename：	ItemCell.lua
-- Author：		Cheng Liang
-- Date：		2013-7-10
-- Purpose：		ItemCell

module("ItemCell", package.seeall)


require "script/ui/item/ItemSprite"
require "script/ui/common/LuaMenuItem"
require "script/ui/item/ItemUtil"
require "script/utils/LuaUtil"

-- checked 的相应处理
local function checkedAction( tag, itemMenu )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
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

function showDropActionFunc( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	
	require "script/ui/copy/ShowAwardWayLayer"

	ShowAwardWayLayer.showLayer(tag)
 	
end 


function createItemCell( itemData, isSell, useActionFunc, iconFuncDelegate)


	local tCell = CCTableViewCell:create()
	-- 背景
	local cellBg = CCSprite:create("images/bag/item/item_cellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)

	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = ItemSprite.getItemSpriteById( tonumber(itemData.item_template_id), tonumber(itemData.item_id), iconFuncDelegate )
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 数量
	local numberLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1147") .. tonumber(itemData.item_num) , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    numberLabel:setPosition(ccp( ( cellBgSize.width*0.2 - numberLabel:getContentSize().width)/2, cellBgSize.height*0.26))
    cellBg:addChild(numberLabel)

    -- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(itemData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local itemName = itemData.itemDesc.name
	if(tonumber(itemData.item_template_id) >= 1800000 and tonumber(itemData.item_template_id)<= 1900000 ) then
		itemName = ItemSprite.getStringByFashionString(itemName)
	end
	local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.itemDesc.quality)
	local nameLabel = CCRenderLabel:create(itemName, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2+sealSprite:getContentSize().width+5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

    -- added by zhz
    local itemDesc= itemData.itemDesc.desc
	if(tonumber(itemData.item_template_id) >= 1800000 and tonumber(itemData.item_template_id)<= 1900000 ) then
		itemDesc = ItemSprite.getStringByFashionString(itemDesc)
	end

	-- 描述
	local descLabel = CCLabelTTF:create( itemDesc, g_sFontName, 23, CCSizeMake(300, 100), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 1))
	descLabel:setPosition(ccp(cellBgSize.width*0.21, cellBgSize.height*0.65))
	cellBg:addChild(descLabel)

	 -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)

	if (isSell) then
		-- 钱币背景
		local coinBg = CCSprite:create("images/common/coin.png")
		coinBg:setAnchorPoint(ccp(0.5, 0.5))
		coinBg:setPosition(ccp(cellBgSize.width*0.73, cellBgSize.height*0.5))
		cellBg:addChild(coinBg)

		-- 卖多少
		local coinLabel = CCRenderLabel:create( BagLayer.getPriceByEquipData(itemData), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		coinLabel:setColor(ccc3(0x6c, 0xff, 0x00))
		coinLabel:setAnchorPoint(ccp(0, 0.5))
		coinLabel:setPosition(ccp(cellBgSize.width*0.76, cellBgSize.height*0.5))
		cellBg:addChild(coinLabel)

		-- 复选框
		local checkedBtn = CheckBoxItem.create()
		checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
	    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
	    checkedBtn:registerScriptTapHandler(checkedAction)

		menuBar:addChild(checkedBtn, 1, itemData.gid)
		handleCheckedBtn(checkedBtn)
	else
		-- if (itemData.isDirectUse and itemData.isDirectUse == true) then
		local item_type = itemData.itemDesc.item_type
		local item_temple_id= tonumber(itemData.item_template_id)  -- added by zhz
		-- 直接使用类物品/随即礼包/装备碎片/礼包/名将礼物/宠物 <==> 3/8/5/6/9/4  
		-- print("item_template_id is : ",item_temple_id )
		if( item_type == 3 or item_type == 8 or item_type == 6 or item_type == 9 or item_type == 4 or  item_temple_id== 60012 ) then
			-- 使用
			-- local menuBar = CCMenu:create()
			-- menuBar:setPosition(ccp(0,0))
			-- cellBg:addChild(menuBar)
			local useBtn = LuaMenuItem.createItemImage("images/bag/item/btn_use_n.png", "images/bag/item/btn_use_h.png", useActionFunc )
			useBtn:setAnchorPoint(ccp(0.5, 0.5))
		    useBtn:setPosition(ccp(cellBgSize.width*520/640, cellBgSize.height*0.4))
			menuBar:addChild(useBtn, 1, itemData.gid)
		elseif( item_type == 5 or item_type == 17 or item_type == 19 or item_type == 21)then
			-- 装备碎片
			-- print(GetLocalizeStringBy("key_1971"))
			-- print_t(itemData)
			if(tonumber(itemData.itemDesc.need_part_num) <= tonumber(itemData.item_num))then
				local useBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_1363"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				useBtn:registerScriptTapHandler(useActionFunc)
				useBtn:setAnchorPoint(ccp(0.5, 0.5))
			    useBtn:setPosition(ccp(cellBgSize.width*520/640, cellBgSize.height*0.7))
				menuBar:addChild(useBtn, 1, itemData.gid)
				if(item_type == 19)then
					-- 符印碎片
					useBtn:setPosition(ccp(cellBgSize.width*520/640, cellBgSize.height*0.5))
				end
			else
				local ccSpriteInsufficient = CCSprite:create("images/hero/insufficient.png")
				ccSpriteInsufficient:setAnchorPoint(ccp(0.5, 0.5))
				ccSpriteInsufficient:setPosition(ccp(cellBgSize.width*540/640, cellBgSize.height*0.7))
				cellBg:addChild(ccSpriteInsufficient)

				if(item_type == 19)then
					-- 符印碎片
					ccSpriteInsufficient:setPosition(ccp(cellBgSize.width*540/640, cellBgSize.height*0.5))
				end
			end

			local showDropBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_2167"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			showDropBtn:registerScriptTapHandler(showDropActionFunc)
			showDropBtn:setAnchorPoint(ccp(0.5, 0.5))
		    showDropBtn:setPosition(ccp(cellBgSize.width*520/640, cellBgSize.height*0.3))
			menuBar:addChild(showDropBtn, 1, itemData.gid)

			if(item_type == 19)then
				-- 符印碎片
				showDropBtn:setVisible(false)
			end
		else
			print(GetLocalizeStringBy("key_1902"))
		end

	end
	return tCell
end



function setCellValue( itemData )

end

function startItemCellAnimate( itemCell, animatedIndex )
	
	local cellBg = nil
	cellBg = tolua.cast(itemCell:getChildByTag(1), "CCSprite")
	cellBg:setPosition(ccp(cellBg:getContentSize().width, 0))
	cellBg:runAction(CCMoveTo:create(g_cellAnimateDuration * (animatedIndex ), ccp(0,0)))
end
