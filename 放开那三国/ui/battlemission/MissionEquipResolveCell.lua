-- Filename: MissionEquipResolveCell.lua
-- Author: llp
-- Date: 2014-6-12
-- Purpose: 该文件用于: 装备炼化选择cell

module ("MissionEquipResolveCell", package.seeall)

require "script/ui/battlemission/EquipMissionLayer"

function createEquipCell( equipData, isSell)
	local tCell = CCTableViewCell:create()
	--背景
	local cellBg = CCSprite:create("images/bag/equip/equip_cellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = ItemSprite.getItemSpriteByItemId( tonumber(equipData.item_template_id))
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
    -- levelLabel:setSourceAndTargetColor(ccc3( 0x36, 0xff, 0x00), ccc3( 0x36, 0xff, 0x00));
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    -- levelLabel:setAnchorPoint(ccp(0,0))
    levelLabel:setPosition(ccp(cellBgSize.width*0.1, cellBgSize.height*0.26))
    cellBg:addChild(levelLabel)

	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(equipData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(equipData.itemDesc.quality)
	local nameLabel = CCRenderLabel:create(equipData.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*370.0/640, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(equipData.itemDesc.quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*330.0/640, cellBgSize.height*0.87)
    cellBg:addChild(potentialLabel)

 --    -- 获得相关数值
	-- local t_numerial, t_numerial_pl, t_equip_score = ItemUtil.getTop2NumeralByIID( tonumber(equipData.item_id))
	-- local descString = ""
	-- for key,v_num in pairs(t_numerial) do
	-- 	if (key == "hp") then
	-- 		descString = descString .. GetLocalizeStringBy("key_1765")
	-- 	elseif (key == "gen_att") then
	-- 		descString = descString .. GetLocalizeStringBy("key_2980")
	-- 	elseif(key == "phy_att"  )then
	-- 		descString = descString .. GetLocalizeStringBy("key_2958") 
	-- 	elseif(key == "magic_att")then
	-- 		descString = descString .. GetLocalizeStringBy("key_1536")
	-- 	elseif(key == "phy_def"  )then
	-- 		descString = descString .. GetLocalizeStringBy("key_1588") 
	-- 	elseif(key == "magic_def")then
	-- 		descString = descString .. GetLocalizeStringBy("key_3133") 
	-- 	end
	-- 	descString = descString .."+".. v_num .. "\n"
	-- end

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
    equipScoreLabel:setPosition(ccp((cellBgSize.width*1.05-equipScoreLabel:getContentSize().width)/2, cellBgSize.height*0.35))
    cellBg:addChild(equipScoreLabel)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)

	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:registerScriptTapHandler(EquipMissionLayer.checkedItemAction)
    checkedBtn:setEnabled(false)
    print("======== ",equipData.gid)
	menuBar:addChild(checkedBtn, 1, tonumber(equipData.gid))
	if isSell == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end

	return tCell
end

function createItemSellTableview(_tParentParam,layerWidth,_scrollview_height)
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
			if _tParentParam.filtersItem[a1+1].isSelected == true then
				a2 = createEquipCell(_tParentParam.filtersItem[a1 + 1], true)
			else
				a2 = createEquipCell(_tParentParam.filtersItem[a1 + 1], false)
			end
			a2:setScale(g_fScaleX)
			print("a1a1a1",a1)
			--_tParentParam.filtersItem[a1+1].ccObj = a2
			EquipMissionLayer.updateItemParentParam(a1,a2)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_tParentParam.filtersItem
		elseif (fn == "cellTouched") then
			print("hihihi")
			local m_data = _tParentParam.filtersItem[a1:getIdx()+1]

			local cellBg = tolua.cast(a1:getChildByTag(1), "CCSprite")
			local menubar_m = tolua.cast(cellBg:getChildByTag(9898), "CCMenu")
			local menuBtn_M = tolua.cast(menubar_m:getChildByTag(tonumber(m_data.gid)), "CCMenuItemSprite")
			
			EquipMissionLayer.fnHandlerOfItemTouched(menuBtn_M,m_data)
		end
		
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(layerWidth, _scrollview_height))
	tableView:setAnchorPoint(ccp(0, 0))
	tableView:setBounceable(true)

	return tableView,cellSize.height
end
