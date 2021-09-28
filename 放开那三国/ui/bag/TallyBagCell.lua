-- FileName: TallyBagCell.lua 
-- Author: licong 
-- Date: 16/1/4 
-- Purpose: 兵符背包


module("TallyBagCell", package.seeall)

require "script/ui/common/CheckBoxItem"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"
require "script/libs/LuaCC"
require "script/ui/tally/TallyBuildLayer"

local _callBack  			= nil -- 回调事件
local _selectList		 	= nil -- 选择的材料列表

--[[
	@des 	:初始化变量
	@param 	:
	@return :
--]]
function init( ... )
	_callBack  			= nil
	_selectList		 	= nil 
end
--------------------------------------------------------------- 按钮事件 ----------------------------------------------------------------------------------
--[[
	@des 	:进阶按钮回调
	@param 	:
	@return :
--]]
function developBtnCallBack( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local item_id = tag
	
	TallyBuildLayer.show(item_id,TallyBuildLayer.kDevMode)

	-- 设置界面记忆
	TallyBuildLayer.setChangeLayerMark(TallyBuildLayer.kTagBag)
	-- 记忆兵符背包位置
	BagLayer.setMarkTallyItemId(item_id)
end

--[[
	@des 	:强化按钮回调
	@param 	:
	@return :
--]]
function enhanceBtnCallBack( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/godweapon/GodWeaponReinforceLayer"
	local item_id = tag
	
	TallyBuildLayer.show(item_id,TallyBuildLayer.kEnhanceMode)

	-- 设置界面记忆
	TallyBuildLayer.setChangeLayerMark(TallyBuildLayer.kTagBag)

	-- 记忆神兵背包位置
	BagLayer.setMarkTallyItemId(item_id)
end 

--[[
	@des 	:洗练按钮回调
	@param 	:
	@return :
--]]
function evolveBtnCallBack( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local item_id = tag
	
	TallyBuildLayer.show(item_id,TallyBuildLayer.kWashMode)

	-- 设置界面记忆
	TallyBuildLayer.setChangeLayerMark(TallyBuildLayer.kTagBag)

  	-- 记忆神兵背包位置
	BagLayer.setMarkTallyItemId(item_id)
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
--------------------------------------------------------------- 创建cell ----------------------------------------------------------------------------------
--[[
	@des 	:创建cell
	@param 	:p_data:物品数据, p_callBack:回调函数, p_isForMaterial:是否作为选择列表, p_isShowExp:是否显示经验, p_selectList:选择的列表数据,p_isIconTouch:图标是否可以点击
			 p_isNoBtn:为true时则没有按钮,p_menuPriority:cell按钮上的优先级
	@return :
--]]
function createCell( p_data, p_callBack, p_isForMaterial, p_selectList, p_isIconTouch, p_isNoBtn,p_menuPriority  )
	print("p_data==>")
	print_t(p_data)
	
	init()

	_callBack = p_callBack
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
		iconSprite = ItemSprite.getItemSpriteByItemId( tonumber(p_data.item_template_id),nil,nil, tonumber(p_data.item_id))
	else
		iconSprite = ItemSprite.getItemSpriteById( tonumber(p_data.item_template_id), tonumber(p_data.item_id), nil,nil,nil,nil,nil,nil,nil,nil,true,nil,_callBack )
	end
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 加锁
	if(p_data.va_item_text and p_data.va_item_text.lock and tonumber(p_data.va_item_text.lock) ==1) then
		local lockSp= CCSprite:create("images/hero/lock.png")
		lockSp:setAnchorPoint(ccp(0.5,0.5))
		lockSp:setPosition(iconSprite:getContentSize().width,iconSprite:getContentSize().height)
		iconSprite:addChild(lockSp,100)
	end

	-- 精炼
    local pinSp = CCSprite:create("images/common/fs_j.png")
    pinSp:setAnchorPoint(ccp(1, 0))
    pinSp:setPosition(ccp(70, 2))
    iconSprite:addChild(pinSp)

	-- 精炼等级
	local curEvolvenum = 0
	if( not table.isEmpty(p_data.va_item_text) and p_data.va_item_text.tallyEvolve )then 
		curEvolvenum = p_data.va_item_text.tallyEvolve 
	end
	local evolveLabel = CCRenderLabel:create( curEvolvenum, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    evolveLabel:setColor(ccc3(0x00, 0xff, 0x18))
    evolveLabel:setAnchorPoint(ccp(0,0))
    evolveLabel:setPosition(ccp(pinSp:getPositionX(), 2))
	iconSprite:addChild(evolveLabel)  

	-- 等级背景
	local fullRect = CCRectMake(0,0,46,23)
    local insetRect = CCRectMake(20,8,5,1)
	local lvBg = CCScale9Sprite:create("images/common/bg/name_1.png",fullRect, insetRect)
	lvBg:setContentSize(CCSizeMake(92,26))
	lvBg:setAnchorPoint(ccp(0,0))
	lvBg:setPosition(ccp(20,20))
	cellBg:addChild(lvBg)

	-- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0.5))
    lvSp:setPosition(ccp(8,lvBg:getContentSize().height*0.5))
    lvBg:addChild(lvSp)
	-- 等级
	local levelLabel = CCRenderLabel:create(p_data.va_item_text.tallyLevel, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setAnchorPoint(ccp(0,0.5))
    levelLabel:setPosition(ccp(lvSp:getPositionX()+lvSp:getContentSize().width+2, lvBg:getContentSize().height*0.5))
    lvBg:addChild(levelLabel)

	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(p_data.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(p_data.itemDesc.quality)
	local nameLabel = CCRenderLabel:create(p_data.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

    -- 进阶数
    if( tonumber(p_data.va_item_text.tallyDevelop) > 0 )then 
		local developLabel = CCRenderLabel:create(p_data.va_item_text.tallyDevelop .. GetLocalizeStringBy("zzh_1159"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    developLabel:setColor(ccc3(0x00,0xff,0x18))
	    developLabel:setAnchorPoint(ccp(0,0.5))
	    developLabel:setPosition(ccp(nameLabel:getContentSize().width+nameLabel:getPositionX()+4, nameLabel:getPositionY()))
	    cellBg:addChild(developLabel)
    end

    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(280,92))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,20))
    cellBg:addChild(attrBg)

    -- 属性
    require "script/model/affix/TallyAffixModel"
    local allAffix = TallyAffixModel.getAllAffixByItemInfo( p_data )
    -- 显示士气属性
    local attNum = allAffix[109] or 0
    local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(109, attNum)
    local attrLabel = CCLabelTTF:create(affixDesc.sigleName .. ":" .. displayNum ,g_sFontName,23)
	attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
	attrLabel:setAnchorPoint(ccp(0, 0.5))
	attrLabel:setPosition(ccp(10,attrBg:getContentSize().height-20))
	attrBg:addChild(attrLabel)

	-- 显示精炼名字
	local effectData = TallyAffixModel.getEvolveEffectDesByTid( p_data.item_template_id, curEvolvenum )
	local evolveName = CCLabelTTF:create(effectData.name,g_sFontName,23)
	evolveName:setColor(ccc3(0x78, 0x25, 0x00))
	evolveName:setAnchorPoint(ccp(0, 0.5))
	evolveName:setPosition(ccp(10,attrLabel:getPositionY()-30))
	attrBg:addChild(evolveName)

	-- 显示精炼效果
	-- local evolveAttr = TallyAffixModel.getEvolveAffixByItemInfo( p_data )
	-- local posY = attrLabel:getPositionY()
	-- for k_id,v_num in pairs(evolveAttr) do
	-- 	posY = posY - 25
	-- 	local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(k_id, v_num)
	-- 	local attrLabel = CCLabelTTF:create(affixDesc.sigleName .. ":" .. displayNum ,g_sFontName,23)
	-- 	attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
	-- 	attrLabel:setAnchorPoint(ccp(0, 0.5))
	-- 	attrLabel:setPosition(ccp(10,posY))
	-- 	attrBg:addChild(attrLabel)
	-- end

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)
	if(p_menuPriority)then
		menuBar:setTouchPriority(p_menuPriority)
	end

	if( p_isNoBtn ~= true )then
		if( p_isForMaterial )then 
			-- 复选框
			local checkedBtn = CheckBoxItem.create()
			checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
		    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
			menuBar:addChild(checkedBtn, 1, tonumber(p_data.item_id) )
			checkedBtn:setEnabled(false)
			-- 检查是否被选择
			handleSelectedCheckedBtn(checkedBtn)
		else
			-- 强化
			local enhanceBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("lic_1422"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
		    enhanceBtn:setPosition(ccp(cellBgSize.width*0.87, cellBgSize.height*0.6))
			menuBar:addChild(enhanceBtn, 1, tonumber(p_data.item_id))
			enhanceBtn:registerScriptTapHandler(enhanceBtnCallBack)

			-- 精炼
			local evolveBtn = LuaCC.create9ScaleMenuItem("images/common/btn/purple01_n.png", "images/common/btn/purple01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("lic_1639"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			evolveBtn:setAnchorPoint(ccp(0.5, 0.5))
			evolveBtn:registerScriptTapHandler(evolveBtnCallBack)
			evolveBtn:setPosition(ccp(cellBgSize.width*0.87, cellBgSize.height*0.25))
			menuBar:addChild(evolveBtn, 1, tonumber(p_data.item_id ))

			-- 进阶
			local developBtn = CCMenuItemImage:create("images/treasure/develop/develop_n.png", "images/treasure/develop/develop_h.png")
			developBtn:setAnchorPoint(ccp(0.5, 0.5))
			developBtn:registerScriptTapHandler(developBtnCallBack)
			developBtn:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.5))
			menuBar:addChild(developBtn, 1, tonumber(p_data.item_id ))
		end
	end

	if(p_data.equip_hid and tonumber(p_data.equip_hid) > 0)then
		local localHero = HeroUtil.getHeroInfoByHid(p_data.equip_hid)
		local heroName = localHero.localInfo.name
		if(HeroModel.isNecessaryHeroByHid(p_data.equip_hid)) then
			heroName = UserModel.getUserName()
		end
		local onFormationText =  CCRenderLabel:create(GetLocalizeStringBy("key_1381") .. heroName, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    onFormationText:setColor(ccc3(0x8a, 0xff, 0x00))
	    onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.9))
	    cellBg:addChild(onFormationText)
	end

	return tCell
end






