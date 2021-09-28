-- Filename: MissionGoodResolveCell.lua
-- Author: llp
-- Date: 2014-6-12
-- Purpose: 该文件用于: 宝物炼化选择cell

module ("MissionGoodResolveCell", package.seeall)

require "script/ui/battlemission/GoodMissionLayer"

function createTreasCell( treasData, isSell)
	local tCell = CCTableViewCell:create()
	--背景
	local cellBg = CCSprite:create("images/bag/equip/treas_cellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = ItemSprite.getItemSpriteByItemId( tonumber(treasData.item_template_id), tonumber(treasData.item_id) )
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 等级
	local t_level = 0
	if( (not table.isEmpty(treasData.va_item_text) and treasData.va_item_text.treasureLevel ))then
		t_level = treasData.va_item_text.treasureLevel
	end
	local levelLabel = CCRenderLabel:create("+" .. t_level, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
    levelLabel:setAnchorPoint(ccp(0.5,0.5))
    levelLabel:setPosition(ccp(cellBgSize.width*0.1, cellBgSize.height*0.2))
    cellBg:addChild(levelLabel)

    -- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(treasData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local quality = ItemUtil.getTreasureQualityByItemInfo( treasData )
	local nameLabel = ItemUtil.getTreasureNameByItemInfo( treasData, g_sFontName, 28 )
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2+ sealSprite:getContentSize().width+5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*370.0/640, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*330.0/640, cellBgSize.height*0.87)
    cellBg:addChild(potentialLabel)

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

	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 23, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(cellBgSize.width*0.21, cellBgSize.height*0.4))
	cellBg:addChild(descLabel)

	-- 评分
	local equipScoreLabel = CCRenderLabel:create(score_t.num, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    equipScoreLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    -- equipScoreLabel:setAnchorPoint(ccp(0,0))
    equipScoreLabel:setPosition(ccp((cellBgSize.width*1.05-equipScoreLabel:getContentSize().width)/2, cellBgSize.height*0.35))
    cellBg:addChild(equipScoreLabel)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)
	
	-- local coinBg = CCSprite:create("images/common/coin.png")
	-- coinBg:setAnchorPoint(ccp(0.5, 0.5))
	-- coinBg:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.5))
	-- cellBg:addChild(coinBg)

	-- 卖多少
	-- local coinLabel = CCRenderLabel:create( BagLayer.getPriceByEquipData(treasData), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- coinLabel:setColor(ccc3(0x6c, 0xff, 0x00))
	-- coinLabel:setAnchorPoint(ccp(0, 0.5))
	-- coinLabel:setPosition(ccp(cellBgSize.width*0.73, cellBgSize.height*0.5))
	-- cellBg:addChild(coinLabel)

	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:registerScriptTapHandler(GoodMissionLayer.checkedGoodAction)
    checkedBtn:setEnabled(false)
    
	menuBar:addChild(checkedBtn, 1, treasData.gid)
	--handleCheckedBtn(checkedBtn)

	if isSell == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end

	return tCell
end


function createGoodSellTableview(_tParentParam,layerWidth,_scrollview_height)
--require "script/ui/recycle/EquipResolveCell"
	local cellBg = CCSprite:create("images/bag/item/item_cellbg.png")
	local cellSize = cellBg:getContentSize()			--计算cell大小
	cellSize.width = cellSize.width * g_fScaleX
	cellSize.height = cellSize.height * g_fScaleX
	cellBg = nil

	local _visiableCellNum = math.floor(_scrollview_height/(cellSize.height*g_fScaleX))
	--_arrItemValue = getItemList(_tParentParam)

	local handler = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			if _tParentParam.filtersGood[a1+1].isSelected == true then
				print("这是真的~~~")
				a2 = createTreasCell(_tParentParam.filtersGood[a1 + 1], true)
			else
				print("这是假的~~~")
				a2 = createTreasCell(_tParentParam.filtersGood[a1 + 1], false)
			end
			a2:setScale(g_fScaleX)
			print("a1a1a1",a1)
			--_tParentParam.filtersItem[a1+1].ccObj = a2
			GoodMissionLayer.updateGoodParentParam(a1,a2)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_tParentParam.filtersGood
		elseif (fn == "cellTouched") then
			print("hihihi")
			local m_data = _tParentParam.filtersGood[a1:getIdx()+1]

			local cellBg = tolua.cast(a1:getChildByTag(1), "CCSprite")
			local menubar_m = tolua.cast(cellBg:getChildByTag(9898), "CCMenu")
			local menuBtn_M = tolua.cast(menubar_m:getChildByTag(tonumber(m_data.gid)), "CCMenuItemSprite")
			
			GoodMissionLayer.fnHandlerOfGoodTouched(menuBtn_M,m_data)
		end
		
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(layerWidth, _scrollview_height))
	tableView:setAnchorPoint(ccp(0, 0))
	tableView:setBounceable(true)

	return tableView,cellSize.height
end
