-- FileName: ChooseViewCell.lua 
-- Author: licong 
-- Date: 14-6-14 
-- Purpose: function description of module 


module("ChooseViewCell", package.seeall)

require "script/ui/common/CheckBoxItem"
require "script/utils/LuaUtil"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"

-- 查看物品信息返回回调 为了显示下排按钮
function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, true)
end

-- checked 的相应处理
local function checkedAction( tag, itemMenu )
	-- 更新状态
	ChooseViewLayer.checkedChooseCell(tag)
end

-- 检查checked按钮
local function handleCheckedBtn( checkedBtn )
	local chooseList = ChooseViewLayer.getChooseList()
	print("cell chooseList")
	print_t(chooseList)
	if ( table.isEmpty(chooseList) ) then
		checkedBtn:unselected()
	else
		local isIn = false
		for k,g_id in pairs(chooseList) do
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
function createEquipCell( equipData )
	local tCell = CCTableViewCell:create()
	--背景
	local cellBg = CCSprite:create("images/bag/equip/equip_cellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local quality = ItemUtil.getEquipQualityByItemInfo( equipData )
	local iconSprite = ItemSprite.getItemSpriteByItemId(tonumber(equipData.item_template_id), nil, nil,nil, quality )
	-- local iconSprite = ItemSprite.getItemSpriteById( tonumber(equipData.item_template_id), tonumber(equipData.item_id), showDownMenu )
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
	local nameLabel =  ItemUtil.getEquipNameByItemInfo(equipData,g_sFontName,28)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*420.0/640, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*380.0/640, cellBgSize.height*0.87)
    cellBg:addChild(potentialLabel)

 --    -- 获得相关数值
	-- local t_numerial, t_numerial_pl, t_equip_score = ItemUtil.getTop2NumeralByIID( tonumber(equipData.item_id))
	-- -- 映射关系
	-- local potentialityConfig = { hp = 1, gen_att = 9, phy_att = 2, magic_att =3, phy_def = 4, magic_def = 5}
	-- -- 洗练的结果
	-- local water_result = nil
	-- if(equipData and equipData.va_item_text and (not table.isEmpty(equipData.va_item_text.armPotence)))then
	-- 	water_result = table.hcopy(equipData.va_item_text.armPotence, {})
	-- end

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
	-- 	if( not table.isEmpty(water_result) )then
	-- 		for k,v in pairs(water_result) do
	-- 			if(potentialityConfig[key] == tonumber(k))then
					
	-- 				v_num = tonumber(v_num) + tonumber(v)
	-- 				break
	-- 			end
	-- 		end
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
	menuBar:setTouchPriority(-602)

	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:registerScriptTapHandler(checkedAction)
	menuBar:addChild(checkedBtn, 1, tonumber(equipData.gid))

	handleCheckedBtn(checkedBtn)

	return tCell
end











