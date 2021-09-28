-- Filename：	EquipCell.lua
-- Author：		Cheng Liang
-- Date：		2013-7-6
-- Purpose：		装备Cell

module("EquipCell", package.seeall)


require "script/ui/item/ItemSprite"
require "script/utils/LuaUtil"

local Tag_CellBg = 10001

--[[
	@desc	装备Cell的创建
	@para 	table cellValues,
			int animatedIndex, 
			boolean isAnimate
	@return CCTableViewCell
--]]
function createEquipCell(quipData, callbackDelegate)

	local tCell = CCTableViewCell:create()

	-- 背景
	local cellBg = CCSprite:create("images/bag/equip/equip_cellbg.png")
	tCell:addChild(cellBg, 1, Tag_CellBg)
	local cellBgSize = cellBg:getContentSize()

	-- 图像
	local quality = ItemUtil.getEquipQualityByItemInfo( quipData )
	local iconSP = ItemSprite.getItemSpriteByItemId(tonumber(quipData.item_template_id), nil, nil,nil, quality )
	iconSP:setAnchorPoint(ccp(0.5, 0.5))
	iconSP:setPosition(ccp(cellBgSize.width*0.095, cellBgSize.height*0.6))
	cellBg:addChild(iconSP)
	if(quipData.itemDesc.jobLimit and quipData.itemDesc.jobLimit > 0)then
		local suitTagSprite = CCSprite:create("images/common/suit_tag.png")
		suitTagSprite:setAnchorPoint(ccp(0.5, 0.5))
		suitTagSprite:setPosition(ccp(iconSP:getContentSize().width*0.25, iconSP:getContentSize().height*0.9))
		iconSP:addChild(suitTagSprite)
	end
	
	-- 等级
	local levelLabel = CCRenderLabel:create(quipData.va_item_text.armReinforceLevel, g_sFontName,21, 1, ccc3(0x89, 0x00, 0x1a), type_stroke)
    -- levelLabel:setSourceAndTargetColor(ccc3( 0xf9, 0xff, 0xc8), ccc3(0xff, 0xd7, 0x4e));
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setPosition(cellBgSize.width*0.1, cellBgSize.height*0.28)
    cellBg:addChild(levelLabel)

    -- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(quipData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local nameLabel =  ItemUtil.getEquipNameByItemInfo(quipData,g_sFontName,28)
	nameLabel:setAnchorPoint(ccp(0, 0.5))
	nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

    -- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    cellBg:addChild(starSp)

    -- 星级
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    -- potentialLabel:setSourceAndTargetColor(ccc3( 0xf9, 0xff, 0xc8), ccc3(0xff, 0xd7, 0x4e));
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    cellBg:addChild(potentialLabel)

 --    -- 获得相关数值
	-- local t_numerial, t_numerial_pl, t_equip_score = ItemUtil.getTop2NumeralByIID( tonumber(quipData.item_id))
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
	-- 	descString = descString .."+" .. v_num .. "\n"
	-- end

	-- 映射关系
	local showAttrId = {1,9,2,3,4,5}
	local baseData = EquipAffixModel.getEquipAffixById(quipData.item_id)
	local fixData = EquipAffixModel.getEquipFixedAffix(quipData)
	local developData = EquipAffixModel.getDevelopAffixByInfo(quipData)
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
	local equipScoreLabel = CCRenderLabel:create(quipData.itemDesc.base_score, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    equipScoreLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    cellBg:addChild(equipScoreLabel)

    --兼容东南亚英文版
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	potentialLabel:setPosition(340, cellBgSize.height*0.36)
	    starSp:setPosition(ccp( 395, cellBgSize.height*0.3))
	    equipScoreLabel:setPosition(ccp(370, cellBgSize.height*0.35))
    else
	    potentialLabel:setPosition(cellBgSize.width*380.0/640, cellBgSize.height*0.88)
	    starSp:setPosition(ccp( cellBgSize.width*420.0/640, cellBgSize.height*0.8))
	    equipScoreLabel:setPosition(ccp((cellBgSize.width*1.05-equipScoreLabel:getContentSize().width)/2, cellBgSize.height*0.35))
    end

	if(quipData.equip_hid and tonumber(quipData.equip_hid) > 0)then
		-- local being_front = CCSprite:create("images/hero/being_fronted.png")
		-- being_front:setPosition(ccp(532, 88))
		-- cellBg:addChild(being_front)
		local localHero = HeroUtil.getHeroInfoByHid(quipData.equip_hid)
		local heroName = localHero.localInfo.name
		if(HeroModel.isNecessaryHeroByHid(quipData.equip_hid)) then
			heroName = UserModel.getUserName()
		end
		local onFormationText =  CCRenderLabel:create(GetLocalizeStringBy("key_1783").. heroName, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    onFormationText:setColor(ccc3(0x8a, 0xff, 0x00))
	     --兼容东南亚英文版
    	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    		onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.3))
    	else
	    	onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.85))
	    end
	    cellBg:addChild(onFormationText)
	end

	return tCell
end

