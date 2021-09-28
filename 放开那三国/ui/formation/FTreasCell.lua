-- Filename：	FTreasCell.lua
-- Author：		Cheng Liang
-- Date：		2013-11-6
-- Purpose：		宝物cell

module("FTreasCell", package.seeall)


-- require "script/ui/item/ItemSprite"
require "script/utils/LuaUtil"

local Tag_CellBg = 10001

-- 宝物更换
function createEquipCell(treasData, callbackDelegate, hid, curEquioPos, addUnionProfitCount)

	local tCell = CCTableViewCell:create()

	-- 背景
	local cellBg = CCSprite:create("images/bag/equip/treas_cellbg.png")
	tCell:addChild(cellBg, 1, Tag_CellBg)
	local cellBgSize = cellBg:getContentSize()

	-- 图像
	local iconSP = ItemSprite.getItemSpriteById(tonumber(treasData.item_template_id), tonumber(treasData.item_id), callbackDelegate,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
	iconSP:setAnchorPoint(ccp(0.5, 0.5))
	iconSP:setPosition(ccp(cellBgSize.width*0.095, cellBgSize.height*0.6))
	cellBg:addChild(iconSP)

	-- 等级
	local levelLabel = CCRenderLabel:create("+" .. treasData.va_item_text.treasureLevel, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
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
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)


    -- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*370.0/640, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

    -- 星级
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*330.0/640, cellBgSize.height*0.88)
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

    --兼容东南亚英文版
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	potentialLabel:setPosition(290, cellBgSize.height*0.36)
	    starSp:setPosition(ccp( 325, cellBgSize.height*0.3))
	    equipScoreLabel:setPosition(ccp(370, cellBgSize.height*0.35))
    else
	    potentialLabel:setPosition(cellBgSize.width*365.0/640, cellBgSize.height*0.88)
	    starSp:setPosition(ccp( cellBgSize.width*395.0/640, cellBgSize.height*0.8))
	    equipScoreLabel:setPosition(ccp((cellBgSize.width*1.05-equipScoreLabel:getContentSize().width)/2, cellBgSize.height*0.35))
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
	     --兼容东南亚英文版
    	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    		onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.3))
    	else
	    	onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.85))
	    end
	    cellBg:addChild(onFormationText)
	end
	if addUnionProfitCount > 0 then
		local addUnionProfitCountLabel =  CCRenderLabel:create(string.format(GetLocalizeStringBy("keybu0_102"), addUnionProfitCount), g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    addUnionProfitCountLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    	addUnionProfitCountLabel:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.3))
	    cellBg:addChild(addUnionProfitCountLabel)
	end

	return tCell
end

