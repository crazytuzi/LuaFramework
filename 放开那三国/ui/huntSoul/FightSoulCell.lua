-- FileName: FightSoulCell.lua 
-- Author: Li Cong 
-- Date:     14-2-17 
-- Purpose: function description of module 


module("FightSoulCell", package.seeall)

require "script/ui/common/CheckBoxItem"
require "script/utils/LuaUtil"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/huntSoul/HuntSoulData"
require "script/ui/hero/HeroPublicLua"

local _selectList		 	= nil -- 选择的材料列表

--[[
	@des 	:初始化变量
	@param 	:
	@return :
--]]
function init( ... )
	_selectList		 	= nil 
end

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

--[[
	@des 	: 精炼回调
	@param 	: 
	@return : 
--]]
function evolveItemAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/huntSoul/evolveSoul/EvolveSoulLayer"
	EvolveSoulLayer.showLayer(tag)
	EvolveSoulLayer.setLayerMark(EvolveSoulLayer.kTagBag)

	require "script/ui/huntSoul/FightSoulLayer"
	FightSoulLayer.setMarkSoulItemId( tag )
end

--[[
	@des 	: 进阶回调
	@param 	: 
	@return : 
--]]
function developItemAction(pItemId)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/huntSoul/developSoul/DevelopSoulLayer"
	DevelopSoulLayer.showLayer(pItemId)
	DevelopSoulLayer.setLayerMark(DevelopSoulLayer.kTagBag)

	require "script/ui/huntSoul/FightSoulLayer"
	FightSoulLayer.setMarkSoulItemId( pItemId )

end

-- 升级战魂
function levelUpItemAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/huntSoul/UpgradeFightSoulLayer"
	local tSign = {}
	tSign.sign = "fightSoulBag"
	local layer = UpgradeFightSoulLayer.createUpgradeFightSoulLayer(tag,tSign)
    MainScene.changeLayer(layer,"UpgradeFightSoulLayer")

    require "script/ui/huntSoul/FightSoulLayer"
	FightSoulLayer.setMarkSoulItemId( tag )
end 

-- 创建
function createCell( tCellData, p_isHaveBtn, p_isForMaterial, p_selectList, p_isIconTouch, p_menuPriority, p_callFun )
	init()
	_selectList = p_selectList
	
	local tCell = CCTableViewCell:create()
	-- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(639,169))
    cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = nil
	if(p_isIconTouch == false)then
		iconSprite = ItemSprite.getItemSpriteByItemId( tonumber(tCellData.item_template_id),nil,false)
	else
		iconSprite = ItemSprite.getItemSpriteById( tonumber(tCellData.item_template_id), tonumber(tCellData.item_id), p_callFun,nil,nil,nil,nil,nil,false)
	end
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 等级背景
	local fullRect = CCRectMake(0,0,46,23)
    local insetRect = CCRectMake(20,8,5,1)
	local lvBg = CCScale9Sprite:create("images/common/bg/name_1.png",fullRect, insetRect)
	lvBg:setContentSize(CCSizeMake(92,26))
	lvBg:setAnchorPoint(ccp(0,0))
	lvBg:setPosition(ccp(20,18))
	cellBg:addChild(lvBg)

	-- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0.5))
    lvSp:setPosition(ccp(8,lvBg:getContentSize().height*0.5))
    lvBg:addChild(lvSp)
	-- 等级
	local levelLabel = CCRenderLabel:create(tCellData.va_item_text.fsLevel, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setAnchorPoint(ccp(0,0.5))
    levelLabel:setPosition(ccp(lvSp:getPositionX()+lvSp:getContentSize().width+2, lvBg:getContentSize().height*0.5))
    lvBg:addChild(levelLabel)

	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(tCellData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

    if( table.isEmpty(tCellData.itemDesc))then
    	tCellData.itemDesc = ItemUtil.getItemById(tCellData.item_template_id)
    end
	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(tCellData.itemDesc.quality)
	local nameLabel = CCRenderLabel:create(tCellData.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

	-- 星级
    local potentialLabel = CCRenderLabel:create(tCellData.itemDesc.quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*330.0/640, cellBgSize.height*0.87)
    cellBg:addChild(potentialLabel)
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*370.0/640, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(280,92))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,20))
    cellBg:addChild(attrBg)

    -- 分割线
    local line = CCScale9Sprite:create("images/common/line02.png")
    line:setContentSize(CCSizeMake(90,4))
    line:setAnchorPoint(ccp(0.5,0.5))
    line:setPosition(ccp(180,attrBg:getContentSize().height*0.5))
    attrBg:addChild(line)
    line:setRotation(90)

    -- 获得相关数值
	local tData = HuntSoulData.getFightSoulAttrByItem_id( tonumber(tCellData.item_id))
	-- print("-------------")
	-- print_t(tData)
	local descString = ""
	for k,v in pairs(tData) do
		descString = descString .. v.desc.displayName .."+".. v.displayNum .. "\n"
	end
	if(table.isEmpty(tData))then
		if(not table.isEmpty(tCellData.va_item_text))then
			local allExp = tonumber(tCellData.va_item_text.fsExp) + tonumber(tCellData.itemDesc.baseExp)
			descString = GetLocalizeStringBy("key_2177") .. allExp
		else
			descString = GetLocalizeStringBy("key_2177") .. tCellData.itemDesc.baseExp
		end
	end
	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 23, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(10, attrBg:getContentSize().height*0.35))
	attrBg:addChild(descLabel)

	-- 精炼
    local pinSp = CCSprite:create("images/common/jing.png")
    pinSp:setAnchorPoint(ccp(0, 1))
    pinSp:setPosition(ccp(185, attrBg:getContentSize().height))
    attrBg:addChild(pinSp)

	-- 精炼等级
	local num = 0
	if( not table.isEmpty(tCellData.va_item_text) and tCellData.va_item_text.fsEvolve )then
		num = tCellData.va_item_text.fsEvolve 
	end
	local equipScoreLabel = CCRenderLabel:create( num, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    equipScoreLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    equipScoreLabel:setAnchorPoint(ccp(0,0.5))
    equipScoreLabel:setPosition(ccp(210, 25))
	attrBg:addChild(equipScoreLabel)  

	local jingSp = CCSprite:create("images/common/fs_j.png")
    jingSp:setAnchorPoint(ccp(0, 0.5))
    jingSp:setPosition(ccp(equipScoreLabel:getPositionX()+equipScoreLabel:getContentSize().width+5, equipScoreLabel:getPositionY()))
    attrBg:addChild(jingSp)

    -- 6星以下不显示精炼属性
    if( tonumber(tCellData.itemDesc.quality) < 6 )then 
    	line:setVisible(false)
    	pinSp:setVisible(false)
    	equipScoreLabel:setVisible(false)
    	jingSp:setVisible(false)
    end

    -- 是否显示按钮
    if( p_isHaveBtn )then
	    -- 按钮
		local menuBar = BTSensitiveMenu:create()
		menuBar:setPosition(ccp(0,0))
		cellBg:addChild(menuBar,1, 10)
		if(p_menuPriority)then
			menuBar:setTouchPriority(p_menuPriority)
		end
		-- 升级
		local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	    normalSprite:setContentSize(CCSizeMake(122,64))
	    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
	    selectSprite:setContentSize(CCSizeMake(122,64))
	    local levelUpItem = CCMenuItemSprite:create(normalSprite,selectSprite)
	    levelUpItem:setAnchorPoint(ccp(0.5, 0.5))
	    levelUpItem:registerScriptTapHandler(levelUpItemAction)
		menuBar:addChild(levelUpItem, 1, tCellData.item_id)
	    -- 字体
		local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_1450") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    item_font:setAnchorPoint(ccp(0.5,0.5))
	    item_font:setPosition(ccp(levelUpItem:getContentSize().width*0.5,levelUpItem:getContentSize().height*0.5))
	   	levelUpItem:addChild(item_font)

	   	-- 进阶
		local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	    normalSprite:setContentSize(CCSizeMake(122,64))
	    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
	    selectSprite:setContentSize(CCSizeMake(122,64))
	    local developItem = CCMenuItemSprite:create(normalSprite,selectSprite)
	    developItem:setAnchorPoint(ccp(0.5, 0.5))
	   
	    developItem:registerScriptTapHandler(function ( ... )
	    	-- 橙色进阶需要人物等级
			if( tonumber(tCellData.itemDesc.quality) >= 6 )then
				local needLv = HuntSoulData.getDevelopRedNeedLv()
				if( UserModel.getHeroLevel() < needLv )then
					require "script/ui/tip/AnimationTip"
			        AnimationTip.showTip(GetLocalizeStringBy("lic_1830",needLv))
					return
				end
			end
	    	developItemAction( tCellData.item_id )
	    end)
		menuBar:addChild(developItem, 1, tCellData.item_id)
	    -- 字体
		local item_font = CCRenderLabel:create( GetLocalizeStringBy("lic_1423") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    item_font:setAnchorPoint(ccp(0.5,0.5))
	    item_font:setPosition(ccp(developItem:getContentSize().width*0.5,developItem:getContentSize().height*0.5))
	   	developItem:addChild(item_font)
	   	developItem:setVisible(false)


	   	-- 精炼
		local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	    normalSprite:setContentSize(CCSizeMake(122,64))
	    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
	    selectSprite:setContentSize(CCSizeMake(122,64))
	    local evolveItem = CCMenuItemSprite:create(normalSprite,selectSprite)
	    evolveItem:setAnchorPoint(ccp(0.5, 0.5))
	    evolveItem:registerScriptTapHandler(evolveItemAction)
		menuBar:addChild(evolveItem, 1, tCellData.item_id)
	    -- 字体
		local item_font = CCRenderLabel:create( GetLocalizeStringBy("lic_1639") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    item_font:setAnchorPoint(ccp(0.5,0.5))
	    item_font:setPosition(ccp(evolveItem:getContentSize().width*0.5,evolveItem:getContentSize().height*0.5))
	   	evolveItem:addChild(item_font)
	   	evolveItem:setVisible(false)

	   	-- 按钮显示
	   	local lvNum = HuntSoulData.getSoulMaterialLv()
	   	if( tCellData.itemDesc.is_evolve and tonumber(tCellData.itemDesc.is_evolve) == 1 
	   		and tonumber(tCellData.va_item_text.fsLevel) >= tonumber(tCellData.itemDesc.needSoreLevel)
	   		and UserModel.getHeroLevel() >= lvNum )then 
	   		levelUpItem:setPosition(ccp(cellBgSize.width*0.8, cellBgSize.height*0.57))
	   		developItem:setVisible(true)
	   		developItem:setPosition(ccp(cellBgSize.width*0.8, cellBgSize.height*0.23))
	   	elseif( tonumber(tCellData.itemDesc.quality) >= 6 )then
	   		levelUpItem:setPosition(ccp(cellBgSize.width*0.8, cellBgSize.height*0.57))
	   		evolveItem:setVisible(true)
	   		evolveItem:setPosition(ccp(cellBgSize.width*0.8, cellBgSize.height*0.23))
	   	else
	   		levelUpItem:setPosition(ccp(cellBgSize.width*0.8, cellBgSize.height*0.5))
	   	end
	end

	if( p_isForMaterial )then
		-- 复选框
		local menu = BTSensitiveMenu:create()
		menu:setPosition(ccp(0,0))
		cellBg:addChild(menu,1, 9898)
		if(p_menuPriority)then
			menu:setTouchPriority(p_menuPriority)
		end
		local checkedBtn = CheckBoxItem.create()
		checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
	    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
		menu:addChild(checkedBtn, 1, tonumber(tCellData.item_id) )
		checkedBtn:setEnabled(false)
		-- 检查是否被选择
		handleSelectedCheckedBtn(checkedBtn)
	end

	if(tCellData.equip_hid and tonumber(tCellData.equip_hid) > 0)then
		-- local being_front = CCSprite:create("images/hero/being_fronted.png")
		-- being_front:setPosition(ccp(532, 88))
		-- cellBg:addChild(being_front)
		local localHero = HeroUtil.getHeroInfoByHid(tCellData.equip_hid)
		local heroName = localHero.localInfo.name
		if(HeroModel.isNecessaryHeroByHid(tCellData.equip_hid)) then
			heroName = UserModel.getUserName()
		end
		local onFormationText =  CCRenderLabel:create(GetLocalizeStringBy("key_1783") .. heroName, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    onFormationText:setColor(ccc3(0x8a, 0xff, 0x00))
	    onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.9))
	    cellBg:addChild(onFormationText)
	end
	
	return tCell
end


