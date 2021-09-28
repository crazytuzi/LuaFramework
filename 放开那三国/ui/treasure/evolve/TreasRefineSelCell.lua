-- Filename：	TreasRefineSelCell.lua
-- Author：		zhz
-- Date：		2014-01-07
-- Purpose：		宝物洗练的cell

module("TreasRefineSelCell", package.seeall)

require "script/ui/common/CheckBoxItem"
require "script/utils/LuaUtil"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"


local _callbackFn= nil

function checkedAction( tag, item)
	-- 音效
	require "script/ui/treasure/evolve/TreasRefineSelLayer"
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- itemMenu:selected()
	local selecedList = TreasRefineSelLayer.getSelCheckedArr()
	local lastSelecedList = selecedList
	if ( selecedList== nil ) then
		selecedList = tag
		item:selected()
	else
		-- local isIn = false
	
		-- if (tonumber(selecedList) == tag ) then
		-- 	isIn = true
		-- end
		-- if (isIn) then
		-- 	selecedList = nil
		-- 	item:unselected()
		-- else
			selecedList= tonumber(tag)
			item:selected()
		-- end
	end
	TreasRefineSelLayer.setSelCheckedArr(selecedList)
	print("lastSelecedList  is : ", lastSelecedList)
	print("selecedList is ========== : ", selecedList)
	TreasRefineSelLayer.updateIndexCellByTid(lastSelecedList)

	if(_callbackFn ~= nil) then
		_callbackFn()
	end

end


-- 处理检查checked 的宝物
function handleSelectedCheckedBtn( checkedBtn )
	require "script/ui/treasure/evolve/TreasRefineSelLayer"

	local selecedList = TreasRefineSelLayer.getSelCheckedArr()
	if ( selecedList== nil ) then
		checkedBtn:unselected()
	else
		local isIn = false
		if ( tonumber(selecedList)== tonumber(checkedBtn:getTag()) ) then
			isIn = true
		end
		if (isIn) then
			checkedBtn:selected()
		else
			checkedBtn:unselected()
		end
	end
end





function createCell(treasData ,callbackfn)

	_callbackFn = callbackfn
	local tCell = CCTableViewCell:create()

	--背景
	local cellBg = CCSprite:create("images/bag/equip/treas_cellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	cellBg:addChild(menu)

	local  function showTreasureInfoLayer( tag,sender )
		require "script/ui/item/TreasureInfoLayer"
		local treasInfoLayer = TreasureInfoLayer:createWithItemId(treasData.item_id, TreasInfoType.OTHER_FORMATION_TYPE)
		treasInfoLayer:show(-512, 1010)
	end

	local norSprite  = ItemSprite.getItemSpriteById(tonumber(treasData.item_template_id), tonumber(treasData.item_id), nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
	local selSprite  = ItemSprite.getItemSpriteById(tonumber(treasData.item_template_id), tonumber(treasData.item_id), nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
	local iconItem   =  CCMenuItemSprite:create(norSprite, selSprite)
	iconItem:setAnchorPoint(ccp(0.5, 0.5))
	iconItem:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	iconItem:registerScriptTapHandler(showTreasureInfoLayer)
	menu:addChild(iconItem)

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

	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:registerScriptTapHandler(checkedAction)

	menuBar:addChild(checkedBtn, 1, tonumber(treasData.item_id) )
	handleSelectedCheckedBtn(checkedBtn)

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

    return tCell

end



