-- FileName: UpgradeFightSoulLayer.lua 
-- Author:   Li Cong 
-- Date:     14-2-18 
-- Purpose: function description of module 


module("UpgradeFightSoulLayer", package.seeall)
require "script/ui/huntSoul/HuntSoulData"
require "script/ui/huntSoul/HuntSoulService"
require "script/utils/LevelUpUtil"
require "script/ui/hero/HeroPublicLua"

local _mainLayer 			= nil
local _bgLayer 				= nil   
local topBg 				= nil
local _silverLabel 			= nil
local _goldLabel 			= nil
local btnFrameSp 			= nil
local _propUpgradeBtn		= nil
local bulletinLayerSize 	= nil
local closeMenuItem  		= nil
local _tSign 				= nil
local yesMenuItem 			= nil
local cancelMenuItem  		= nil
local _desItemData 			= nil
local _progressSp 			= nil
local allOneMenuItem 		= nil
local allTwoMenuItem 		= nil
local _fsoulData 			= nil
local _fsoulDataButton 		= {}
local _bagTableView 		= nil
local fs_bg 				= nil
local expLabel 				= nil
local maxSprrite 			= nil
local bgProress 			= nil
local _maxLevel 			= nil
local upMaskLayer 			= nil
local upAnimSprite 			= nil
local levelLabel 			= nil
local addLevelLabel  		= nil
local realLevelLabel   		= nil
local realLevelNum 			= nil
local addLevelNum 			= nil
local realExpNum 			= nil
local addExpNum 			= nil
local realNeedNum 			= nil
local addNeedNum 			= nil
local level_font  			= nil
local needHeroLv 			= nil
local chooseMenuItem 		= nil
local oldLeveNum			= nil
local _addExpNumFont 		= nil
local totalAddExp 			= nil
local _maxLvLimit 			= nil
local _expUpgradeBtn 		= nil
local _curItemBtn 			= nil
local _curDisplayLayer 		= nil

local attrNameFontArr 		= {}
local attrNumFontArr 		= {}
local realAttrNumArr 		= {}

local addAttrNumArr 		= {}
local addAttrNumFontArr 	= {}

local _isCanCallService 	= false -- 经验超上限触发后端请求

local _curItemId 			= nil

-- 初始化
function init( ... )
	_mainLayer 			= nil
	_bgLayer 			= nil  
	_bgSprite 			= nil
	topBg 				= nil
	_silverLabel 		= nil
	_goldLabel 			= nil
	btnFrameSp 			= nil
	_propUpgradeBtn		= nil
	bulletinLayerSize 	= nil
	closeMenuItem  		= nil
	_tSign 				= nil
	yesMenuItem 		= nil
	cancelMenuItem  	= nil
	_desItemData 		= nil
	_progressSp 		= nil
	allOneMenuItem 		= nil
	allTwoMenuItem 		= nil
	_fsoulData 			= nil
	_fsoulDataButton 	= {}
	_bagTableView 		= nil
	fs_bg 				= nil
	expLabel 			= nil
	maxSprrite 			= nil
	bgProress 			= nil
	_maxLevel 			= nil
	upMaskLayer 		= nil
	upAnimSprite 		= nil
	levelLabel 			= nil
	addLevelLabel  		= nil
	realLevelLabel   	= nil
	realLevelNum 		= nil
	addLevelNum 		= nil
	realExpNum 			= nil
	addExpNum 			= nil
	realNeedNum 		= nil
	addNeedNum 			= nil
	level_font  		= nil
	chooseMenuItem 		= nil
	oldLeveNum			= nil
	_addExpNumFont 		= nil
	totalAddExp 		= nil
	_maxLvLimit 		= nil
	_expUpgradeBtn 		= nil
	_curItemBtn 		= nil
	_curDisplayLayer 	= nil

	attrNameFontArr 	= {}
	attrNumFontArr 		= {}
	realAttrNumArr 		= {}

	addAttrNumArr 		= {}
	addAttrNumFontArr 	= {}
	_isCanCallService 	= false

	_curItemId 			= nil
end

-- 按钮item
local function createButtonItem( str )
	local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
    normalSprite:setContentSize(CCSizeMake(140,64))
    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
    selectSprite:setContentSize(CCSizeMake(140,64))
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
    -- 字体
	local item_font = CCRenderLabel:create( str , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
   	item:addChild(item_font)
   	return item
end

-- 星星 最多6星
function getStarByQuality( num )
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(40*tonumber(num),32))
	for i=1,num do
		local sprite = CCSprite:create("images/common/star.png")
		sprite:setAnchorPoint(ccp(0,0))
		sprite:setPosition(ccp((i-1)*(sprite:getContentSize().width+10),0))
		node:addChild(sprite)
		-- if(i <= tonumber(num))then
			-- local starSprite = CCSprite:create("images/common/star.png")
			-- starSprite:setAnchorPoint(ccp(0.5,0.5))
			-- starSprite:setPosition(ccp(sprite:getContentSize().width*0.5,sprite:getContentSize().height*0.5))
			-- sprite:addChild(starSprite)
		-- end
	end
	return node
end

-- 初始化猎魂界面
function initUpgradeFightSoulLayer( ... )
	-- 公告栏大小
	require "script/ui/main/BulletinLayer"
    bulletinLayerSize = BulletinLayer.getLayerContentSize()

    -- 上标题栏 显示战斗力，银币，金币
	topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
	topBg:setAnchorPoint(ccp(0,1))
	topBg:setPosition(ccp(0, _mainLayer:getContentSize().height-bulletinLayerSize.height*g_fScaleX))
	_mainLayer:addChild(topBg,10)
	topBg:setScale(g_fScaleX)
	
	-- 战斗力
	local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBg:getContentSize().width*0.13,topBg:getContentSize().height*0.43)
    topBg:addChild(powerDescLabel)
    local _powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerDescLabel:setPosition(topBg:getContentSize().width*0.23,topBg:getContentSize().height*0.66)
    topBg:addChild(_powerDescLabel)

	-- 银币
	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)  -- modified by yangrui at 2015-12-03
	_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silverLabel:setAnchorPoint(ccp(0, 0))
	_silverLabel:setPosition(ccp(390, 10))
	topBg:addChild(_silverLabel)

	-- 金币
	_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_goldLabel:setAnchorPoint(ccp(0, 0))
	_goldLabel:setPosition(ccp(522, 10))
	topBg:addChild(_goldLabel)

	--按钮背景
    local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	btnFrameSp:setPosition(ccp(_mainLayer:getContentSize().width/2 , _mainLayer:getContentSize().height-topBg:getContentSize().height*g_fScaleX-bulletinLayerSize.height*g_fScaleX))
	_mainLayer:addChild(btnFrameSp,10)
	btnFrameSp:setScale(g_fScaleX)

	local menuBar = CCMenu:create()
	menuBar:setTouchPriority(-230)
	menuBar:setPosition(ccp(0, 0))
	btnFrameSp:addChild(menuBar)
	-- 道具升级战魂魂
	_propUpgradeBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_2708"),30,28)
	_propUpgradeBtn:setAnchorPoint(ccp(0, 0))
	_propUpgradeBtn:setPosition(ccp(btnFrameSp:getContentSize().width*0.01, btnFrameSp:getContentSize().height*0.1))
	menuBar:addChild(_propUpgradeBtn, 2, 10001)
	_propUpgradeBtn:registerScriptTapHandler(changeUpLayerAction)

	-- 经验升级战魂魂
	_expUpgradeBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("lic_1709"),30,28)
	_expUpgradeBtn:setAnchorPoint(ccp(0, 0))
	_expUpgradeBtn:setPosition(ccp(_propUpgradeBtn:getContentSize().width+_propUpgradeBtn:getPositionX()+10, btnFrameSp:getContentSize().height*0.1))
	menuBar:addChild(_expUpgradeBtn, 2, 10002)
	_expUpgradeBtn:registerScriptTapHandler(changeUpLayerAction)

	-- 大背景
    _bgSprite = CCSprite:create("images/hunt/jing_bg.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height*0.5))
    _mainLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

   	-- 返回按钮
	closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(fnCloseAction)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(btnFrameSp:getContentSize().width-20,btnFrameSp:getContentSize().height*0.5))
	menuBar:addChild(closeMenuItem)

	-- 默认道具升级
	changeUpLayerAction( 10001, _propUpgradeBtn )

end

-- 创建战魂信息
function createFightSoulInfo( ... )
	-- 创建战魂背景
	fs_bg = CCSprite:create("images/hunt/fsoul_bg.png")
	fs_bg:setAnchorPoint(ccp(0.5,0.5))
	local fs_bgPoy = btnFrameSp:getPositionY()-btnFrameSp:getContentSize().height*g_fScaleX- fs_bg:getContentSize().height*0.5*g_fScaleX
	fs_bg:setPosition(ccp(_bgLayer:getContentSize().width*0.23,fs_bgPoy))
	_bgLayer:addChild(fs_bg)
	fs_bg:setScale(g_fScaleX)

	-- 战魂icon
	local iconSprite = ItemSprite.getItemSpriteByItemId(_desItemData.item_template_id,_desItemData.va_item_text.fsLevel,false)
	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(fs_bg:getContentSize().width*0.5,fs_bg:getContentSize().height*0.5))
	fs_bg:addChild(iconSprite)

	-- 星星
	local star_sprite = getStarByQuality(_desItemData.itemDesc.quality)
	star_sprite:setAnchorPoint(ccp(0.5,0))
	star_sprite:setPosition(ccp(fs_bg:getContentSize().width*0.5,0))
	fs_bg:addChild(star_sprite)

	-- 战魂名字
	local name_color = HeroPublicLua.getCCColorByStarLevel(_desItemData.itemDesc.quality)
 	local nameLabel = CCRenderLabel:create(_desItemData.itemDesc.name, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(name_color)
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setPosition(ccp(400,fs_bg:getContentSize().height*0.8))
    fs_bg:addChild(nameLabel,2)
    -- 分割线
    local lineSprite = CCScale9Sprite:create("images/hunt/brownline.png")
    lineSprite:setContentSize(CCSizeMake(185,4))
    lineSprite:setAnchorPoint(ccp(0.5,1))
    lineSprite:setPosition(ccp(nameLabel:getPositionX(),nameLabel:getPositionY()-nameLabel:getContentSize().height-3))
    fs_bg:addChild(lineSprite,2)

    -- 基础类型
    local leixing_font = CCRenderLabel:create( GetLocalizeStringBy("key_2519") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leixing_font:setColor(ccc3(0xff,0xe4,0x00))
    leixing_font:setAnchorPoint(ccp(0,1))
    leixing_font:setPosition(ccp(310,lineSprite:getPositionY()-lineSprite:getContentSize().height-10))
    fs_bg:addChild(leixing_font,2)
	-- 类型
 	local leixingLabel = CCRenderLabel:create(_desItemData.itemDesc.desc, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leixingLabel:setColor(ccc3(0xff,0xff,0xff))
    leixingLabel:setAnchorPoint(ccp(0,1))
    leixingLabel:setPosition(ccp(leixing_font:getPositionX()+leixing_font:getContentSize().width+5,leixing_font:getPositionY()))
    fs_bg:addChild(leixingLabel)
    -- 分割线
    local lineSprite = CCScale9Sprite:create("images/hunt/brownline.png")
    lineSprite:setContentSize(CCSizeMake(185,4))
    lineSprite:setAnchorPoint(ccp(0,1))
    lineSprite:setPosition(ccp(leixing_font:getPositionX()-5,leixing_font:getPositionY()-leixing_font:getContentSize().height-3))
    fs_bg:addChild(lineSprite,2)

    -- 等级
    level_font = CCRenderLabel:create( GetLocalizeStringBy("key_1178") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    level_font:setColor(ccc3(0xff,0xe4,0x00))
    level_font:setAnchorPoint(ccp(0,1))
    level_font:setPosition(ccp(leixing_font:getPositionX(),lineSprite:getPositionY()-lineSprite:getContentSize().height-10))
    fs_bg:addChild(level_font,2)
	-- 等级
	realLevelNum = tonumber(_desItemData.va_item_text.fsLevel)
 	levelLabel = CCRenderLabel:create("Lv." .. _desItemData.va_item_text.fsLevel, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff,0xff,0xff))
    levelLabel:setAnchorPoint(ccp(0,1))
    levelLabel:setPosition(ccp(level_font:getPositionX()+level_font:getContentSize().width+5,level_font:getPositionY()))
    fs_bg:addChild(levelLabel)
    -- 分割线
    local lineSprite = CCScale9Sprite:create("images/hunt/brownline.png")
    lineSprite:setContentSize(CCSizeMake(185,4))
    lineSprite:setAnchorPoint(ccp(0,1))
    lineSprite:setPosition(ccp(level_font:getPositionX()-5,level_font:getPositionY()-level_font:getContentSize().height-3))
    fs_bg:addChild(lineSprite,2)

	--  属性
	local cur_tData = HuntSoulData.getFightSoulAttrByItem_id( tonumber(_desItemData.item_id) )
	print("cur_tData ..")
	print_t(cur_tData)
	local index = 0
	for k,v in pairs(cur_tData) do
		local displayName = v.desc.displayName
		local displayNum = v.displayNum
		index = index + 1
	    local atrr_font = CCRenderLabel:create(displayName .. ":", g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    atrr_font:setColor(ccc3(0xff,0xe4,0x00))
	    atrr_font:setAnchorPoint(ccp(0,1))
	    atrr_font:setPosition(ccp(leixing_font:getPositionX(),lineSprite:getPositionY()-lineSprite:getContentSize().height-(10*index+(index-1)*24)))
	    fs_bg:addChild(atrr_font,2)
		-- 属性值
	 	local atrrLabel = CCRenderLabel:create(displayNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    atrrLabel:setColor(ccc3(0xff,0xff,0xff))
	    atrrLabel:setAnchorPoint(ccp(0,1))
	    atrrLabel:setPosition(ccp(atrr_font:getPositionX()+atrr_font:getContentSize().width+5,atrr_font:getPositionY()))
	    fs_bg:addChild(atrrLabel)

	    -- 保存
		attrNameFontArr[k] = atrr_font
		attrNumFontArr[k] = atrrLabel
		realAttrNumArr[k] = displayNum

	end

end

-- 增加值特效
function setAddAttrAnimation()
	addLevelNum,addExpNum,addNeedNum,totalAddExp = HuntSoulData.getCurLvAndCurExpAndNeedExp( _desItemData.itemDesc.upgradeID, _desItemData.item_id )
	if(addLevelNum > _maxLevel)then
		addLevelNum = _maxLevel
	end
	-- 增加的数值
	local cur_tData = HuntSoulData.getFightSoulAttrByItem_id( tonumber(_desItemData.item_id), addLevelNum )
	for k,v in pairs(cur_tData) do
		addAttrNumArr[k] = v.displayNum
	end
	if(realLevelLabel)then  
		realLevelLabel:removeFromParentAndCleanup(true)
		realLevelLabel = nil
	end

	if(addLevelLabel) then
		addLevelLabel:removeFromParentAndCleanup(true)
		addLevelLabel=nil
	end

	for k,v in pairs(addAttrNumFontArr) do
		if(addAttrNumFontArr[k]) then
			addAttrNumFontArr[k]:removeFromParentAndCleanup(true)
			addAttrNumFontArr[k]=nil
		end
	end

	if(addLevelNum <= realLevelNum)then
		-- 不显示
	else
	 	local growLevelNum = addLevelNum - realLevelNum
		local p_x,p_y = levelLabel:getPositionX()+levelLabel:getContentSize().width+10,levelLabel:getPositionY()
		addLevelLabel = CCRenderLabel:create("+" .. growLevelNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    addLevelLabel:setAnchorPoint(ccp(0,1))
	    addLevelLabel:setPosition(ccp(p_x, p_y))
	    addLevelLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
 		fs_bg:addChild(addLevelLabel)
	   
		-- 增加的数值
		local cur_tData = HuntSoulData.getFightSoulAttrByItem_id( tonumber(_desItemData.item_id), addLevelNum )
		for k,v in pairs(cur_tData) do
			local displayName = v.desc.displayName

			addAttrNumArr[k] = v.displayNum

			local growAddNum = (addLevelNum - realLevelNum) * tonumber(v.growRealNum)
			local a,growNum,b = ItemUtil.getAtrrNameAndNum(tonumber(k),growAddNum)
			local p_x,p_y = attrNumFontArr[k]:getPositionX()+attrNumFontArr[k]:getContentSize().width+10,attrNumFontArr[k]:getPositionY()
			local addAttrLabel = CCRenderLabel:createWithAlign("+" ..growNum, g_sFontPangWa, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke, CCSizeMake(225, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
			addAttrLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
			addAttrLabel:setAnchorPoint(ccp(0, 1))
			addAttrLabel:setPosition(ccp(p_x, p_y))
			fs_bg:addChild(addAttrLabel)

			addAttrNumFontArr[k] = addAttrLabel
		
			local arrActions_1 = CCArray:create()
			arrActions_1:addObject(CCFadeIn:create(0.8))
			arrActions_1:addObject(CCFadeOut:create(0.8))
			local sequence_1 = CCSequence:create(arrActions_1)
			local action_1 = CCRepeatForever:create(sequence_1)
			addLevelLabel:stopAllActions()
			addLevelLabel:runAction(action_1)

			local arrActions_4 = CCArray:create()
			arrActions_4:addObject(CCFadeIn:create(0.8))
			arrActions_4:addObject(CCFadeOut:create(0.8))
			local sequence_4 = CCSequence:create(arrActions_4)
			local action_4 = CCRepeatForever:create(sequence_4)
			addAttrNumFontArr[k]:stopAllActions()
			addAttrNumFontArr[k]:runAction(action_4)
		end
	end
	-- 刷新新增经验条
	local rate = nil
	if(realLevelNum < addLevelNum)then 
		rate = 1
	else
		rate = addExpNum/addNeedNum
	end
	-- 显示
	_addProgressGreenBar:setVisible(true)
	if(rate > 1)then
		rate = 1
	end
	_addProgressGreenBar:setContentSize(CCSizeMake(570 * rate, 22))

	-- 显示增加经验值
	_addExpNumFont:setVisible(true)
	_addExpNumFont:setString("+" .. totalAddExp)
end

-- 移除增加值特效
function removeAddAttrAnimation( ... )
	if(realLevelLabel)then  
		realLevelLabel:removeFromParentAndCleanup(true)
		realLevelLabel = nil
	end
	if(addLevelLabel) then
		addLevelLabel:removeFromParentAndCleanup(true)
		addLevelLabel=nil
	end
	for k,v in pairs(addAttrNumFontArr) do
		if(addAttrNumFontArr[k]) then
			addAttrNumFontArr[k]:removeFromParentAndCleanup(true)
			addAttrNumFontArr[k]=nil
		end
	end
	-- 隐藏
	_addProgressGreenBar:setVisible(false)
	_addExpNumFont:setVisible(false)
end


-- 创建经验进度条
function createExpProgress()
	-- print("id",_desItemData.itemDesc.upgradeID)
	-- print(GetLocalizeStringBy("key_1736"),_desItemData.va_item_text.fsExp)
	-- print("lv",_desItemData.va_item_text.fsLevel)
	realExpNum,realNeedNum = LevelUpUtil.getCurExp(_desItemData.itemDesc.upgradeID,_desItemData.va_item_text.fsExp,_desItemData.va_item_text.fsLevel)
	bgProress = CCScale9Sprite:create("images/hunt/exp_bg.png")
	bgProress:setContentSize(CCSizeMake(_bgLayer:getContentSize().width/g_fScaleX, 49))
	bgProress:setAnchorPoint(ccp(0.5, 0.5))
	local posY = fs_bg:getPositionY()-fs_bg:getContentSize().height*0.5*g_fScaleX-10*g_fScaleX-bgProress:getContentSize().height*0.5*g_fScaleX
	bgProress:setPosition(ccp(_bgLayer:getContentSize().width*0.5, posY))
	_bgLayer:addChild(bgProress)
	bgProress:setScale(g_fScaleX)

	-- 增长经验条
	local rate = realExpNum/realNeedNum
	if(rate > 1)then
		rate = 1
	end
	_addProgressGreenBar = CCScale9Sprite:create("images/hunt/exp_line.png")
	_addProgressGreenBar:setContentSize( CCSizeMake(570 * rate, 22) )
	_addProgressGreenBar:setAnchorPoint(ccp(0,0.5))
	_addProgressGreenBar:setPosition(ccp(35, bgProress:getContentSize().height *0.5))
	bgProress:addChild(_addProgressGreenBar)
	local arrActions = CCArray:create()
	arrActions:addObject(CCFadeIn:create(0.8))
	arrActions:addObject(CCFadeOut:create(0.8))
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)
	_addProgressGreenBar:runAction(action)

	-- 增加的经验显示
	_addExpNumFont = CCLabelTTF:create("+0",g_sFontName,23)
	_addExpNumFont:setColor(ccc3(0x00, 0x00, 0x00))
	_addExpNumFont:setAnchorPoint(ccp(0.5, 0.5))
	_addExpNumFont:setPosition(ccp(bgProress:getContentSize().width*0.75, bgProress:getContentSize().height*0.5))
	bgProress:addChild(_addExpNumFont)
	_addExpNumFont:setVisible(false)

	_progressSp = CCScale9Sprite:create("images/hunt/real_exp_line.png")
	_progressSp:setAnchorPoint(ccp(0, 0.5))
	_progressSp:setPosition(ccp(35, bgProress:getContentSize().height * 0.5+1))
	bgProress:addChild(_progressSp)

	if( realLevelNum < _maxLevel )then 
		_progressSp:setContentSize(CCSizeMake(570 * rate, 22))
		-- 经验值
		expLabel = CCLabelTTF:create(realExpNum .. "/" .. realNeedNum, g_sFontName, 23)
		expLabel:setColor(ccc3(0x00, 0x00, 0x00))
		expLabel:setAnchorPoint(ccp(0.5, 0.5))
		expLabel:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height*0.5))
		bgProress:addChild(expLabel)
	else
		_progressSp:setContentSize(CCSizeMake(570, 22))
		maxSprrite = CCSprite:create("images/common/max.png")
		maxSprrite:setAnchorPoint(ccp(0.5, 0.5))
		maxSprrite:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height * 0.5))
		bgProress:addChild(maxSprrite)
	end
end

-- 刷新真实进度条
function refreshRealProgress( ... )
	-- 刷新进度条
    if( addLevelNum < _maxLevel )then 
    	local rate = addExpNum/addNeedNum
    	if(rate > 1)then
    		rate = 1
    	end
		_progressSp:setContentSize(CCSizeMake(570 * rate, 22))
		-- 经验值
		if(maxSprrite)then
			maxSprrite:removeFromParentAndCleanup(true)
			maxSprrite = nil
		end
		if(expLabel)then
			expLabel:removeFromParentAndCleanup(true)
			expLabel = nil
		end
		expLabel = CCLabelTTF:create(addExpNum .. "/" .. addNeedNum, g_sFontName, 23)
		expLabel:setColor(ccc3(0x00, 0x00, 0x00))
		expLabel:setAnchorPoint(ccp(0.5, 0.5))
		expLabel:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height*0.5))
		bgProress:addChild(expLabel)
		realExpNum 	= addExpNum
		realNeedNum = addNeedNum
	else
		if(maxSprrite)then
			maxSprrite:removeFromParentAndCleanup(true)
			maxSprrite = nil
		end
		if(expLabel)then
			expLabel:removeFromParentAndCleanup(true)
			expLabel = nil
		end
		_progressSp:setContentSize(CCSizeMake(570*1, 22))
		maxSprrite = CCSprite:create("images/common/max.png")
		maxSprrite:setAnchorPoint(ccp(0.5, 0.5))
		maxSprrite:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height * 0.5))
		bgProress:addChild(maxSprrite)
	end
end

-- 刷新真实等级和属性值
function refreshLevelAndAttr( ... )
	if(levelLabel)then
		levelLabel:removeFromParentAndCleanup(true)
		levelLabel = nil
	end
	realLevelNum = addLevelNum

	for k,v in pairs(realAttrNumArr) do
		if(addAttrNumArr[k])then
			realAttrNumArr[k]  = addAttrNumArr[k]
		end
	end
	
	levelLabel = CCRenderLabel:create("Lv." .. addLevelNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff,0xff,0xff))
    levelLabel:setAnchorPoint(ccp(0,1))
    levelLabel:setPosition(ccp(level_font:getPositionX()+level_font:getContentSize().width+5,level_font:getPositionY()))
    fs_bg:addChild(levelLabel)

    for k,v in pairs(addAttrNumArr) do
	    if(addAttrNumArr[k])then
		    if(attrNumFontArr[k])then
				attrNumFontArr[k]:removeFromParentAndCleanup(true)
				attrNumFontArr[k] = nil
			end
			attrNumFontArr[k] = CCRenderLabel:create(addAttrNumArr[k], g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    attrNumFontArr[k]:setColor(ccc3(0xff,0xff,0xff))
		    attrNumFontArr[k]:setAnchorPoint(ccp(0,1))
		    attrNumFontArr[k]:setPosition(ccp(attrNameFontArr[k]:getPositionX()+attrNameFontArr[k]:getContentSize().width+5,attrNameFontArr[k]:getPositionY()))
		    fs_bg:addChild(attrNumFontArr[k])
		end
	end
end

-- 刷新真实等级和属性值 经验超上限用
function refreshLevelAndAttrForCallService( ... )
	if(levelLabel)then
		levelLabel:removeFromParentAndCleanup(true)
		levelLabel = nil
	end
	realLevelNum = tonumber(_desItemData.va_item_text.fsLevel)
	levelLabel = CCRenderLabel:create("Lv." .. realLevelNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff,0xff,0xff))
    levelLabel:setAnchorPoint(ccp(0,1))
    levelLabel:setPosition(ccp(level_font:getPositionX()+level_font:getContentSize().width+5,level_font:getPositionY()))
    fs_bg:addChild(levelLabel)

    local cur_tData = HuntSoulData.getFightSoulAttrByItem_id( tonumber(_desItemData.item_id) )
    for k,v in pairs(cur_tData) do
    	local displayName = v.desc.displayName
		local displayNum = v.displayNum
	    if(attrNumFontArr[k])then
			attrNumFontArr[k]:removeFromParentAndCleanup(true)
			attrNumFontArr[k] = nil
		end
		attrNumFontArr[k] = CCRenderLabel:create(displayNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    attrNumFontArr[k]:setColor(ccc3(0xff,0xff,0xff))
	    attrNumFontArr[k]:setAnchorPoint(ccp(0,1))
	    attrNumFontArr[k]:setPosition(ccp(attrNameFontArr[k]:getPositionX()+attrNameFontArr[k]:getContentSize().width+5,attrNameFontArr[k]:getPositionY()))
	    fs_bg:addChild(attrNumFontArr[k])
	end
end

-- 创建战魂背包
function createFSTableView( ... )
	-- up
	local upSprite = CCSprite:create("images/hunt/up_line.png")
	upSprite:setAnchorPoint(ccp(0.5,1))
	local posY = bgProress:getPositionY()-10*g_fScaleX-bgProress:getContentSize().height*0.5*g_fScaleX
	upSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
	_bgLayer:addChild(upSprite,10)
	upSprite:setScale(g_fScaleX)
	-- down
	local downSprite = CCSprite:create("images/hunt/down_line.png")
	downSprite:setAnchorPoint(ccp(0.5,0))
	local posY = chooseMenuItem:getPositionY()+chooseMenuItem:getContentSize().height*g_fScaleX+15*g_fScaleX
	downSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
	_bgLayer:addChild(downSprite,10)
	downSprite:setScale(g_fScaleX)

	-- 背包里战魂数据
	_fsoulData = HuntSoulData.getBagInfoWithOutDesItem(_desItemData.item_id)
	local cellSize = CCSizeMake(610,120)		--计算cell大小
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width*g_fScaleX, cellSize.height*g_fScaleX)
		elseif (fn == "cellAtIndex") then
		    a2 = CCTableViewCell:create()
		    a2:setContentSize(cellSize)
			local posArrX = {0.1,0.3,0.5,0.7,0.9}
			for i=1,5 do
				if(_fsoulData[a1*5+i] ~= nil)then
					local fsMenu = BTSensitiveMenu:create()
					if(fsMenu:retainCount()>1)then
						fsMenu:release()
						fsMenu:autorelease()
					end
					fsMenu:setAnchorPoint(ccp(0,0))
					fsMenu:setPosition(ccp(0,0))
					a2:addChild(fsMenu)
					fsMenu:setTouchPriority(-131)
					local normalSprite = ItemSprite.getItemSpriteByItemId( tonumber(_fsoulData[a1*5+i].item_template_id),_fsoulData[a1*5+i].va_item_text.fsLevel)
					local selectSprite = ItemSprite.getItemSpriteByItemId( tonumber(_fsoulData[a1*5+i].item_template_id),_fsoulData[a1*5+i].va_item_text.fsLevel)
					local fsMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
					fsMenuItem:setAnchorPoint(ccp(0.5,0.5))
					fsMenuItem:setPosition(ccp(610*posArrX[i],120-fsMenuItem:getContentSize().height*0.5))
					fsMenu:addChild(fsMenuItem,1,tonumber(_fsoulData[a1*5+i].item_id))
					fsMenuItem:registerScriptTapHandler(fsMenuItemAction)
					-- 名字
					local name_color = HeroPublicLua.getCCColorByStarLevel(_fsoulData[a1*5+i].itemDesc.quality)
					local iconName = CCLabelTTF:create(_fsoulData[a1*5+i].itemDesc.name,g_sFontName,18)
					iconName:setColor(name_color)
					iconName:setAnchorPoint(ccp(0.5,0.5))
					iconName:setPosition(ccp(fsMenuItem:getContentSize().width*0.5,-10))
					fsMenuItem:addChild(iconName)
					-- 添加到数据按钮中 以itemId为key
					_fsoulDataButton[tonumber(_fsoulData[a1*5+i].item_id)] = fsMenuItem
					-- 给已经选择的数据添加选择框
					local chooseData = HuntSoulData.getChooseFSItemTable()
					for k,v in pairs(chooseData) do
						if(tonumber(v) == tonumber(_fsoulData[a1*5+i].item_id))then
							local sprite = CCSprite:create("images/hunt/choose.png")
							sprite:setAnchorPoint(ccp(0.5,0.5))
							sprite:setPosition(fsMenuItem:getContentSize().width*0.5,fsMenuItem:getContentSize().height*0.5)
							fsMenuItem:addChild(sprite,1,110)
							local duiSprite = CCSprite:create("images/common/checked.png")
							duiSprite:setAnchorPoint(ccp(0.5,0.5))
							duiSprite:setPosition(sprite:getContentSize().width*0.5,sprite:getContentSize().height*0.5)
							sprite:addChild(duiSprite)
							break
						end
					end
				end
			end
			r = a2
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			num = #_fsoulData
			r = math.ceil(num/5)
		elseif (fn == "cellTouched") then
			-- print ("a1: ", a1, ", a2: ", a2)
			-- print ("cellTouched, index is: ", a1:getIdx())
		else
			-- print (fn, " event is not handled.")
		end
		return r
	end)
	local tableViewHeight = upSprite:getPositionY()-downSprite:getPositionY()-20*g_fScaleX
	_bagTableView  = LuaTableView:createWithHandler(handler, CCSizeMake(610*g_fScaleX,tableViewHeight))
	_bagTableView:setBounceable(true)
	_bagTableView:ignoreAnchorPointForPosition(false)
	_bagTableView:setAnchorPoint(ccp(0.5, 0))
	_bagTableView:setPosition(ccp(_bgLayer:getContentSize().width*0.5, downSprite:getPositionY()+10*g_fScaleX))
	_bgLayer:addChild(_bagTableView,2)
	_bagTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- _bagTableView:setContentOffset(ccp(0,0))
	_bagTableView:setTouchPriority(-132)
end


-- 添加选中高亮 已添加删除，未添加就加上
function setSelectBox( item_id )
	if(_fsoulDataButton[item_id]:getChildByTag(110))then
		-- print("remove .. ")
		_fsoulDataButton[item_id]:getChildByTag(110):removeFromParentAndCleanup(true)
	else
		local sprite = CCSprite:create("images/hunt/choose.png")
		sprite:setAnchorPoint(ccp(0.5,0.5))
		sprite:setPosition(_fsoulDataButton[item_id]:getContentSize().width*0.5,_fsoulDataButton[item_id]:getContentSize().height*0.5)
		_fsoulDataButton[item_id]:addChild(sprite,1,110)
		local duiSprite = CCSprite:create("images/common/checked.png")
		duiSprite:setAnchorPoint(ccp(0.5,0.5))
		duiSprite:setPosition(sprite:getContentSize().width*0.5,sprite:getContentSize().height*0.5)
		sprite:addChild(duiSprite)
	end
end

-- 按钮是否显示 
-- is_close:返回按钮
-- is_choose:取消确定按钮
function menuItemSetVisible( is_close, is_choose )
	closeMenuItem:setVisible(is_close)
	yesMenuItem:setVisible(is_choose)
	cancelMenuItem:setVisible(is_choose)
end

-- 经验超上限发触发请求
function sendCallService()
	local function createNextFun(curLv, totalExp, item_id)
		_isCanCallService = false
		-- 修改目标装备的等级和经验
		if(_desItemData.equip_hid and tonumber(_desItemData.equip_hid) > 0)then
			-- 修改装备战魂数据
			HeroModel.addFSLevelOnHerosBy( _desItemData.equip_hid, _desItemData.pos, curLv, totalExp )
		else
			-- 修改背包战魂数据
			DataCache.changeFSLvByItemId(_desItemData.item_id,curLv,totalExp)
		end
		-- 修改数据
		_desItemData = HuntSoulData.getDesItemInfoByItemId(item_id)
		-- 升级前等级
		oldLeveNum = tonumber(_desItemData.va_item_text.fsLevel)
		-- 刷新真实等级
		refreshLevelAndAttrForCallService()
   	end
	HuntSoulService.promote(_desItemData.item_id,{},createNextFun)
end

-- 确认回调
function yesMenuItemAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(_isCanCallService == true)then
		-- 发触发请求
		sendCallService()
		return
	end

	-- 选择列表
	local chooseTab = HuntSoulData.getChooseFSItemTable()
	if( table.isEmpty(chooseTab) )then
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip( GetLocalizeStringBy("key_2724"))
     	return
	end
	-- print("*-*-*-*-*")
	-- print_t(chooseTab)
	-- 品质不能高于目标品质
	local isTip = false
	for k,v in pairs(chooseTab) do
		local data = ItemUtil.getItemInfoByItemId(v)
		if( tonumber(data.itemDesc.quality) > tonumber(_desItemData.itemDesc.quality) )then
			isTip = true
			break
		end
	end
	if(isTip)then
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip( GetLocalizeStringBy("key_2985"))
     	return
	end
	-- 是否包含4星级以上的战魂要被吞噬
	local isHave = false
	for k,v in pairs(chooseTab) do
		-- print("/*/*///* " ,v)
		local data = ItemUtil.getItemInfoByItemId(v)
		if(tonumber(data.itemDesc.quality) >= 4 )then
			isHave = true
			break
		end
	end
	if(isHave)then
		require "script/ui/tip/AlertTip"
		local str = GetLocalizeStringBy("key_1332")
		AlertTip.showAlert(str,sendHuntSoulService,true,chooseTab)
	else
		sendHuntSoulService(true,chooseTab)
	end
end

-- 发送强化请求
function sendHuntSoulService( isConfirm, chooseTab )
	if(isConfirm == false)then
		return 
	end
	local function createNextFun(curLv, totalExp, item_id)
		-- 修改目标装备的等级和经验
		if(_desItemData.equip_hid and tonumber(_desItemData.equip_hid) > 0)then
			-- 修改装备战魂数据
			HeroModel.addFSLevelOnHerosBy( _desItemData.equip_hid, _desItemData.pos, curLv, totalExp )
		else
			-- 修改背包战魂数据
			DataCache.changeFSLvByItemId(_desItemData.item_id,curLv,totalExp)
		end
		-- 刷新一下背包
		_fsoulData = HuntSoulData.getDifferentData( _fsoulData, chooseTab )
		-- print(GetLocalizeStringBy("key_2516"))
		-- print_t(_fsoulData)
		_bagTableView:reloadData()
		-- 清空选择战魂列表
		HuntSoulData.ClearChooseFSItemTable()
		-- 去除增加值特效
		removeAddAttrAnimation()
		-- 升级特效
		upAnimation()
		-- 刷新
		refreshUI()
		-- 刷新真实进度条
		refreshRealProgress()
		-- 漂增加属性提示
		if(tonumber(oldLeveNum) < tonumber(curLv))then
			local tipArr = addAttrNumAndAtrrName(tonumber(oldLeveNum),tonumber(curLv))
			require "script/utils/LevelUpUtil"
			LevelUpUtil.showFlyText(tipArr)
			oldLeveNum = tonumber(curLv)
		end
		-- 刷新真实等级
		refreshLevelAndAttr()
		-- 修改数据
		_desItemData = HuntSoulData.getDesItemInfoByItemId(item_id)
		
		addLevelNum 		= nil
		addAttrNumArr 		= {}
		addExpNum 			= nil
		addNeedNum 			= nil
   	end
	HuntSoulService.promote(_desItemData.item_id,chooseTab,createNextFun)
end

-- 取消回调
function cancelMenuItemAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 选择列表
	local chooseTab = HuntSoulData.getChooseFSItemTable()
	if( table.isEmpty(chooseTab) )then
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip( GetLocalizeStringBy("key_2724"))
     	return
	end
	-- 清空选择战魂列表
	HuntSoulData.ClearChooseFSItemTable()
	-- 刷新一下背包
	_bagTableView:reloadData()
	-- 刷新ui
	refreshUI()
end

-- 选择战魂回调
function fsMenuItemAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print("选择的战魂itemId==>",tag)
	local chooseData = HuntSoulData.getChooseFSItemTable()
	local isIn = false
	for k,v in pairs(chooseData) do
		if(tonumber(v) == tonumber(tag))then
			isIn = true
		end
	end
	if(isIn)then
		-- print("here ...")
		-- 添加选择数据
		HuntSoulData.addChooseFSItemId(tag)
		-- 添加选择框
		setSelectBox(tag)
		-- 刷新ui
		refreshUI()
	else
		local curLv = tonumber(_desItemData.va_item_text.fsLevel)
		if(curLv >= _maxLvLimit)then 
			-- 等级最大上限
			print("000000000")
			require "script/ui/tip/AnimationTip"
	     	AnimationTip.showTip(GetLocalizeStringBy("lic_1623"))
			return 
		end
		if(curLv >= _maxLevel)then
			print("111111111111111111111111111111111111")
			require "script/ui/tip/AnimationTip"
	     	AnimationTip.showTip(GetLocalizeStringBy("key_3416") .. needHeroLv .. GetLocalizeStringBy("key_3099"))
			return 
		end
		local srcData = ItemUtil.getItemByItemId(tag)
		print("srcData .. ")
		print_t(srcData)
		if( tonumber(_desItemData.itemDesc.quality) < tonumber(srcData.itemDesc.quality) )then
			require "script/ui/tip/AnimationTip"
	     	AnimationTip.showTip( GetLocalizeStringBy("key_2986"))
	     	return
		end
		-- 进行判断是否溢出
		-- 已经选择的战魂可以提供的等级
		local canUpLv,a,b,c = HuntSoulData.getCurLvAndCurExpAndNeedExp( _desItemData.itemDesc.upgradeID, _desItemData.item_id )
		if(canUpLv >= _maxLvLimit)then 
			_isCanCallService = true
			-- 等级最大上限
			print("0000000001")
			require "script/ui/tip/AnimationTip"
	     	AnimationTip.showTip(GetLocalizeStringBy("lic_1623"))
			return 
		end
		if(canUpLv >= _maxLevel)then
			_isCanCallService = true
			print("2222222222222222222222222222222222222")
			require "script/ui/tip/AnimationTip"
	     	AnimationTip.showTip(GetLocalizeStringBy("key_3416") .. needHeroLv .. GetLocalizeStringBy("key_3099"))
			return
		end
		-- 添加选择数据
		HuntSoulData.addChooseFSItemId(tag)
		-- 添加选择框
		setSelectBox(tag)
		-- 刷新ui
		refreshUI()
	end
end

-- 返回按钮回调
function fnCloseAction( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	if(_tSign.sign == "fightSoulBag")then
		require "script/ui/huntSoul/HuntSoulLayer"
		local layer = HuntSoulLayer.createHuntSoulLayer(_tSign.sign)
	    MainScene.changeLayer(layer,"HuntSoulLayer")
	elseif(_tSign.sign == "equipFightSoul")then
		require "script/ui/formation/FormationLayer"
		local layer = FormationLayer.createLayer(_tSign.hid, false, false, false, 2)
		MainScene.changeLayer(layer,"FormationLayer")
	else
		print(GetLocalizeStringBy("key_2288"))
		require "script/ui/huntSoul/HuntSoulLayer"
		local layer = HuntSoulLayer.createHuntSoulLayer("fightSoulBag")
	    MainScene.changeLayer(layer,"HuntSoulLayer")
	end
end

-- 刷新需要变动的UI
-- 根据选择列表刷新数值 chooseTable
function refreshUI()
	-- 刷新右上按钮显示
	local chooseData = HuntSoulData.getChooseFSItemTable()
	-- print("chooseData ----")
	-- print_t(chooseData)
	if(table.isEmpty(chooseData))then
		-- 显示返回按钮
     	-- menuItemSetVisible(true,false)
     	-- 去除增加值特效
     	removeAddAttrAnimation()
	else
		-- 显示取消和确定
		-- menuItemSetVisible(false,true)
		-- 增加值特效
		setAddAttrAnimation()
	end
end

-- 升级特效
function upAnimation( callfun )
	-- if(upMaskLayer)then
	-- 	upMaskLayer:removeFromParentAndCleanup(true)
	-- 	upMaskLayer = nil
	-- end
	-- local runningScene = CCDirector:sharedDirector():getRunningScene()
	-- upMaskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
	-- runningScene:addChild(upMaskLayer, 10000)
	local function fnupAnimSpriteEnd( ... )
		if(upAnimSprite)then
			upAnimSprite:release()
			upAnimSprite:removeFromParentAndCleanup(true)
			upAnimSprite = nil
		end
		if(callfun)then
			callfun()
		end
		-- if(upMaskLayer)then
		-- 	upMaskLayer:removeFromParentAndCleanup(true)
		-- 	upMaskLayer = nil
		-- end
	end
    upAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/fightSoulUp/wuhunshengji"), -1,CCString:create(""))
    upAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    upAnimSprite:setPosition(ccp(122,122))
    fs_bg:addChild(upAnimSprite,888)
    upAnimSprite:retain()
    -- 注册代理
    local downDelegate = BTAnimationEventDelegate:create()
    downDelegate:registerLayerEndedHandler(fnupAnimSpriteEnd)
    upAnimSprite:setDelegate(downDelegate)
end

-- 得到增加的属性
function addAttrNumAndAtrrName( oldLeveNum, newLevelNum )
	local retArr = {}
	local cur_tData = HuntSoulData.getFightSoulAttrByItem_id( tonumber(_desItemData.item_id), newLevelNum )
	for k,v in pairs(cur_tData) do
		local temArr = {}
		temArr.txt = v.desc.displayName
		temArr.num = (newLevelNum - oldLeveNum) * tonumber(v.growRealNum)
		temArr.displayNumType = v.desc.type
		table.insert(retArr,temArr)
	end
	return retArr
end

-- 得到能用来升级的数据
function getFsoulData( ... ) 
	return _fsoulData
end

-- 刷新tableView
function refreshTableView( ... )
	_bagTableView:reloadData()
	refreshUI()
end

-- 自动选择回调
function chooseMenuItemAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local curLv = tonumber(_desItemData.va_item_text.fsLevel)
	if(curLv >= _maxLvLimit)then 
		-- 等级最大上限
		print("000")
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip(GetLocalizeStringBy("lic_1623"))
		return 
	end
	if(curLv >= _maxLevel)then
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip(GetLocalizeStringBy("key_3416") .. needHeroLv .. GetLocalizeStringBy("key_3099"))
		return 
	end
	require "script/ui/huntSoul/UpgradeByStarLayer"
	UpgradeByStarLayer.createLayerStar()
end

function getNeedUpgradeItemDataAndMaxLv( ... )
	return _desItemData,_maxLevel
end

-- 创建升级界面
-- tSign:用于记住返回到哪个界面
function createUpgradeFightSoulLayer(item_id, tSign)
	init()
	_mainLayer = CCLayer:create()

	-- 如果入口是猎魂50次展示面板，关闭展示面板
	require "script/ui/huntSoul/ShowFiftyHuntDialog"
	ShowFiftyHuntDialog.closeTipLayer()

	-- 隐藏玩家信息栏
	MainScene.setMainSceneViewsVisible(true, false, true)

	-- 入口标志
	_tSign = tSign
	_curItemId = item_id
	
	-- 初始化猎魂界面
	initUpgradeFightSoulLayer()


	return _mainLayer
end


--[[
	@des 	: 切换界面按钮回调
	@param 	: 
	@return :
--]]
function createPropUpgradeLayer()

	_bgLayer = CCLayer:create()

	-- 自动选择按钮
	local choose_menuBar = CCMenu:create()
	choose_menuBar:setTouchPriority(-230)
	choose_menuBar:setPosition(ccp(0, 0))
	_bgLayer:addChild(choose_menuBar)
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		chooseMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(198, 73),GetLocalizeStringBy("key_3138"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		chooseMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(198, 73),GetLocalizeStringBy("key_3138"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end	
	chooseMenuItem:setAnchorPoint(ccp(0.5,0))
	chooseMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.18,MenuLayer.getHeight()+10*g_fScaleX))
	choose_menuBar:addChild(chooseMenuItem)
	chooseMenuItem:registerScriptTapHandler(chooseMenuItemAction)
	chooseMenuItem:setScale(g_fScaleX)

	-- 确认按钮
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		yesMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("key_2637"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		yesMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("key_2637"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end	
	yesMenuItem:setAnchorPoint(ccp(0.5,0))
	yesMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.84,MenuLayer.getHeight()+10*g_fScaleX))
	choose_menuBar:addChild(yesMenuItem)
	yesMenuItem:registerScriptTapHandler(yesMenuItemAction)
	yesMenuItem:setScale(g_fScaleX)

	-- 取消按钮 
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		cancelMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(198, 73),GetLocalizeStringBy("key_2982"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		cancelMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(198, 73),GetLocalizeStringBy("key_2982"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	cancelMenuItem:setAnchorPoint(ccp(0.5,0))
	cancelMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.53,MenuLayer.getHeight()+10*g_fScaleX))
	choose_menuBar:addChild(cancelMenuItem)
	cancelMenuItem:registerScriptTapHandler(cancelMenuItemAction)
	cancelMenuItem:setScale(g_fScaleX) 
	
	-- 准备数据
	-- 要升级的目标战魂信息
	_desItemData = HuntSoulData.getDesItemInfoByItemId(_curItemId)
	-- 升级前等级
	oldLeveNum = tonumber(_desItemData.va_item_text.fsLevel)
	-- print("_desItemData")
	-- print_t(_desItemData)
	-- 可以强化到的最大等级
	_maxLevel = HuntSoulData.getMaxLvByFSTempId(_desItemData.item_template_id)
	print("_maxLevel",_maxLevel)
	-- 战魂级别最大上限
	_maxLvLimit = tonumber(_desItemData.itemDesc.maxLevel)

	-- 提升强化等级上限需要英雄的级数（玩家当前等级/10+1 ）*10 向下取整
	needHeroLv = math.floor(UserModel.getHeroLevel()/10+1)*10

	-- 清空选择战魂列表 
	HuntSoulData.ClearChooseFSItemTable()

	-- 创建战魂信息
	createFightSoulInfo()
	
	-- 创建经验条
	createExpProgress()

	-- 创建战魂背包tableView
	createFSTableView()

	return _bgLayer
end


--[[
	@des 	: 切换界面按钮回调
	@param 	: 
	@return :
--]]
function changeUpLayerAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	itemBtn:selected()
	if (_curButton ~= itemBtn) then
		if( not tolua.isnull(_curButton) )then  
			_curButton:unselected()
		end
		_curButton = itemBtn
		_curButton:selected()

		if(_curDisplayLayer) then
			_curDisplayLayer:removeFromParentAndCleanup(true)
			_curDisplayLayer=nil
		end
		if(_curButton == _propUpgradeBtn) then 
			-- 道具升级
			_curDisplayLayer = createPropUpgradeLayer()
		elseif(_curButton == _expUpgradeBtn) then 
			-- 经验升级
			require "script/ui/huntSoul/PropUpSoulLayer"
			_curDisplayLayer = PropUpSoulLayer.createLayer(_curItemId)
		else
		end
		_curDisplayLayer:setPosition(ccp(0,0))
		_mainLayer:addChild(_curDisplayLayer)
	end
end







































