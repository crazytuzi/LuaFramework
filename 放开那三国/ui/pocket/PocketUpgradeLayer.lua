 -- FileName: PocketUpgradeLayer.lua
-- Author:
-- Date: 2014-04-00
-- Purpose: 锦囊强化界面
--[[TODO List]]

module("PocketUpgradeLayer", package.seeall)
require "script/utils/LevelUpUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/pocket/PocketData"
require "db/DB_Awake_ability"
require "db/DB_Affix"
require "script/ui/tip/AnimationTip"
local IMG_PATH = "images/astrology/"				-- 图片主路径

_addLevel 					= 0
_desItemData 				= nil
_fsoulData 					= nil
_bagTableView 				= nil
addExpNum 					= nil
addNeedNum 					= nil
oldLeveNum					= nil
_fsoulDataButton 			= {}
_playAction 				= false
local _hid 					= nil
local _itemId				= nil
local isExp 				= false
local _labelbg 				= nil
local _contenterlayer 		= nil
local _affixbg 				= nil
local _bgLayer 				= nil
local topBg 				= nil
local _silverLabel 			= nil
local _goldLabel 			= nil
local btnFrameSp 			= nil
local upgradeBtn			= nil
local bulletinLayerSize 	= nil
local closeMenuItem  		= nil
local _pCallBack 			= nil
local yesMenuItem 			= nil
local cancelMenuItem  		= nil
local _progressSp 			= nil
local allOneMenuItem 		= nil
local allTwoMenuItem 		= nil
local fs_bg 				= nil
local expLabel 				= nil
local maxSprrite 			= nil
local bgProress 			= nil
local upAnimSprite 			= nil
local levelLabel 			= nil
local addLevelLabel  		= nil
local realLevelLabel   		= nil
local realLevelNum 			= nil
local addLevelNum 			= 0
local realExpNum 			= nil
local realNeedNum 			= nil
local level_font  			= nil
local needHeroLv 			= nil
local chooseMenuItem 		= nil
local _addExpNumFont 		= nil
local totalAddExp 			= nil
local _maxLvLimit 			= nil
local attrNameFontArr 		= {}
local attrNumFontArr 		= {}
local realAttrNumArr 		= {}
local addAttrNumArr 		= {}
local addAttrNumFontArr 	= {}
local _isCanCallService 	= false -- 经验超上限触发后端请求

-- 初始化
function init( ... )
	_itemId				= nil
	_playAction 		= false
	isExp 				= false
	_addLevel 			= 0
	_hid 				= nil
	_contenterlayer 	= nil
	_affixbg 			= nil
	_labelbg 			= nil
	_bgLayer 			= nil
	_bgSprite 			= nil
	topBg 				= nil
	_silverLabel 		= nil
	_goldLabel 			= nil
	btnFrameSp 			= nil
	upgradeBtn			= nil
	bulletinLayerSize 	= nil
	closeMenuItem  		= nil
	_pCallBack 			= nil
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
	upAnimSprite 		= nil
	levelLabel 			= nil
	addLevelLabel  		= nil
	realLevelLabel   	= nil
	realLevelNum 		= nil
	addLevelNum 		= 0
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

	attrNameFontArr 	= {}
	attrNumFontArr 		= {}
	realAttrNumArr 		= {}

	addAttrNumArr 		= {}
	addAttrNumFontArr 	= {}
	_isCanCallService 	= false
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
		  node:setAnchorPoint(ccp(0.5,0))
		  node:setContentSize(CCSizeMake(40*tonumber(num)*0.7,32))
	for i=1,num do
		local sprite = CCSprite:create("images/common/star.png")
			  sprite:setAnchorPoint(ccp(0,0))
			  sprite:setPosition(ccp((i-1)*(sprite:getContentSize().width),0))
		node:addChild(sprite)
	end
	return node
end

-- 初始化锦囊界面
function initPocketLayer( ... )
	local menuBar = CCMenu:create()
		  menuBar:setTouchPriority(-230)
		  menuBar:setPosition(ccp(0, 0))
	_bgLayer:addChild(menuBar,1)

	-- 大背景
	_bgSprite = CCSprite:create("images/pocket/normalupgrade.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 界面名称
    local layerNameSprite = CCSprite:create("images/pocket/jinnangqianghua.png")
    	  layerNameSprite:setAnchorPoint(ccp(0,1))
    	  layerNameSprite:setPosition(ccp(0,_bgLayer:getContentSize().height-10*g_fScaleX))
    	  layerNameSprite:setScale(g_fScaleX)
    _bgLayer:addChild(layerNameSprite)

   	-- 返回按钮
	closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:registerScriptTapHandler(fnCloseAction)
	closeMenuItem:setAnchorPoint(ccp(1,1))
	closeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height))
	menuBar:addChild(closeMenuItem)
	closeMenuItem:setScale(g_fScaleX)

	-- 自动选择按钮
	local choose_menuBar = CCMenu:create()
		  choose_menuBar:setTouchPriority(-600)
		  choose_menuBar:setPosition(ccp(0, 0))
	_bgLayer:addChild(choose_menuBar)

	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		chooseMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(198, 73),GetLocalizeStringBy("key_3138"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		chooseMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(198, 73),GetLocalizeStringBy("key_3138"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	chooseMenuItem:setAnchorPoint(ccp(0.5,0))
	chooseMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.18,10))
	chooseMenuItem:registerScriptTapHandler(chooseMenuItemAction)
	chooseMenuItem:setScale(g_fScaleX)
	choose_menuBar:addChild(chooseMenuItem)

	-- 确认按钮
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		yesMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("key_2637"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		yesMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("key_2637"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	yesMenuItem:setAnchorPoint(ccp(0.5,0))
	yesMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.84,10))
	yesMenuItem:registerScriptTapHandler(yesMenuItemAction)
	yesMenuItem:setScale(g_fScaleX)
	choose_menuBar:addChild(yesMenuItem)

	-- 取消按钮
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		cancelMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(198, 73),GetLocalizeStringBy("key_2982"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		cancelMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(198, 73),GetLocalizeStringBy("key_2982"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	cancelMenuItem:setAnchorPoint(ccp(0.5,0))
	cancelMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.53,10))
	cancelMenuItem:registerScriptTapHandler(cancelMenuItemAction)
	cancelMenuItem:setScale(g_fScaleX)
	choose_menuBar:addChild(cancelMenuItem)

	-- 创建锦囊信息
	createPocketInfo()

	-- 创建经验条
	createExpProgress()

	-- 创建锦囊背包tableView
	createFSTableView()

end

local function createArrtributeChangeDes( p_index,p_data,p_growdata )
	-- body
	local baseArr = string.split(p_data,"|")
	local growArr = string.split(p_growdata,"|")
	local attStr = DB_Affix.getDataById(tonumber(baseArr[1]))
	local attLabel = CCLabelTTF:create(attStr.sigleName.."+",g_sFontName,19)
		  attLabel:setAnchorPoint(ccp(0,1))
	
	local attDesLabel = CCLabelTTF:create(baseArr[2]+growArr[2]*(tonumber(_desItemData.va_item_text.pocketLevel)),g_sFontName,19)
		  attLabel:addChild(attDesLabel,0,p_index)
	attDesLabel:setAnchorPoint(ccp(0,1))

	_contenterlayer:addChild(attLabel,0,p_index)

	local rightSprite = CCSprite:create("images/common/right.png")
		  rightSprite:setAnchorPoint(ccp(0,1))
	attDesLabel:addChild(rightSprite,0,p_index)
	local desNum = 0
	if(tonumber(_desItemData.va_item_text.pocketLevel)<_maxLvLimit)then
		desNum = baseArr[2]+growArr[2]*(tonumber(_desItemData.va_item_text.pocketLevel))+growArr[2]
	else
		desNum = baseArr[2]+growArr[2]*(tonumber(_desItemData.va_item_text.pocketLevel))
	end
	local nextAttDesLabel = CCLabelTTF:create(desNum,g_sFontName,19)
		  nextAttDesLabel:setAnchorPoint(ccp(0,1))
	rightSprite:addChild(nextAttDesLabel,0,p_index)
	
	local p_width = 210
	local posHang,posLie = math.modf((p_index-1)/2)

	if(posLie==0.5)then
		attLabel:setPosition(ccp(10+p_width,_contenterlayer:getContentSize().height*0.9-posHang*rightSprite:getContentSize().height))
	else
		attLabel:setPosition(ccp(10,_contenterlayer:getContentSize().height*0.9-posHang*rightSprite:getContentSize().height))
	end
	
	attDesLabel:setPosition(ccp(attLabel:getContentSize().width,attLabel:getContentSize().height))
	rightSprite:setPosition(ccp(attDesLabel:getContentSize().width+10,attDesLabel:getContentSize().height+rightSprite:getContentSize().height*0.25-2))
	nextAttDesLabel:setPosition(ccp(rightSprite:getContentSize().width+5,attDesLabel:getContentSize().height+rightSprite:getContentSize().height*0.25-2))
end

local function createScrollViewInfo()
	-- body
	local baseArr = string.split(_desItemData.itemDesc.baseAtt,",")
	local growArr = string.split(_desItemData.itemDesc.growAtt,",")
	local baseNum = table.count(baseArr)
	for i=1,baseNum do
		createArrtributeChangeDes(i,baseArr[i],growArr[i])
	end
	local posHang,posLie = math.modf((baseNum-1)/2)
	-- 当前锦囊效果label
	local effectDescTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_244"),g_sFontName,20)
		  effectDescTitleLabel:setColor(ccc3(0x00,0xe4,0xff))
		  effectDescTitleLabel:setAnchorPoint(ccp(0,0))
		  effectDescTitleLabel:setPosition(ccp(10,_contenterlayer:getContentSize().height*0.9-(posHang+2)*_contenterlayer:getChildByTag(baseNum):getChildByTag(baseNum):getChildByTag(baseNum):getContentSize().height))
	_contenterlayer:addChild(effectDescTitleLabel,0,99)
	-- 为了label对齐加了个空sprite
	local effectSprite = CCSprite:create()
		  effectSprite:setContentSize(effectDescTitleLabel:getContentSize())
		  effectSprite:setAnchorPoint(ccp(0,0))
		  effectSprite:setPosition(ccp(effectDescTitleLabel:getContentSize().width,effectDescTitleLabel:getContentSize().height))
	effectDescTitleLabel:addChild(effectSprite,0,99)
	-- 当前锦囊效果具体属性
	local descArray = string.split(_desItemData.itemDesc.level_effect,",")
	local effectStr = nil
	for k,v in pairs(descArray) do
		local levelDescArray = string.split(v,"|")
		if(tonumber(_desItemData.va_item_text.pocketLevel)>=tonumber(levelDescArray[1]))then
			effectStr = DB_Awake_ability.getDataById(levelDescArray[2])
			effectStr = effectStr.des
		end
	end

	local effectDescLabel = CCLabelTTF:create(effectStr,g_sFontName,20)
		  effectDescLabel:setAnchorPoint(ccp(0,1))
		  effectSprite:addChild(effectDescLabel,0,99)
	local dimensionsSize = _contenterlayer:getContentSize().width-effectDescTitleLabel:getContentSize().width-15*g_fScaleX
	if(effectDescLabel:getContentSize().width>dimensionsSize)then
		effectDescLabel:setDimensions(CCSizeMake(dimensionsSize, 0))
	end
	effectDescLabel:setHorizontalAlignment(kCCTextAlignmentLeft) 
	effectDescLabel:setPosition(ccp(0,0))
	
	-- 下级锦囊效果
	local str = nil
	for k,v in pairs(descArray) do
		local levelDescArray = string.split(v,"|")
		if(tonumber(_desItemData.va_item_text.pocketLevel)<tonumber(levelDescArray[1]))then
			str = GetLocalizeStringBy("llp_243",levelDescArray[1])
			break
		end
	end
	if(str==nil)then
		return
	end
	local nextEffectDescTitleLabel = CCLabelTTF:create(str,g_sFontName,20)
		  nextEffectDescTitleLabel:setColor(ccc3(0x00,0xe4,0xff))
		  nextEffectDescTitleLabel:setAnchorPoint(ccp(0,0))
		  nextEffectDescTitleLabel:setPosition(ccp(10,effectDescTitleLabel:getPositionY()-effectDescLabel:getContentSize().height-effectDescTitleLabel:getContentSize().height))
	_contenterlayer:addChild(nextEffectDescTitleLabel,0,100)
	local nexteffectSprite = CCSprite:create()
		  nexteffectSprite:setContentSize(nextEffectDescTitleLabel:getContentSize())
		  nexteffectSprite:setAnchorPoint(ccp(0,0))
		  nexteffectSprite:setPosition(ccp(nextEffectDescTitleLabel:getContentSize().width,nextEffectDescTitleLabel:getContentSize().height))
	nextEffectDescTitleLabel:addChild(nexteffectSprite,0,100)
	-- 下个等级阶段锦囊效果具体属性
	local nextEffectStr = nil
	for k,v in pairs(descArray) do
		local levelDescArray = string.split(v,"|")
		if(tonumber(_desItemData.va_item_text.pocketLevel)<tonumber(levelDescArray[1]))then
			nextEffectStr = DB_Awake_ability.getDataById(levelDescArray[2]).des
			break
		end
	end
	local nextEffectDescLabel = CCLabelTTF:create(nextEffectStr,g_sFontName,20)
		  nextEffectDescLabel:setColor(ccc3(0x99,0x99,0x99))
		  nextEffectDescLabel:setAnchorPoint(ccp(0,1))
	nexteffectSprite:addChild(nextEffectDescLabel,0,100)
	local dimensionsSize = _contenterlayer:getContentSize().width-nextEffectDescTitleLabel:getContentSize().width-15*g_fScaleX
	if(nextEffectDescLabel:getContentSize().width>dimensionsSize)then
		nextEffectDescLabel:setDimensions(CCSizeMake(dimensionsSize, 0))
	end
	nextEffectDescLabel:setHorizontalAlignment(kCCTextAlignmentLeft) 
	nextEffectDescLabel:setPosition(ccp(0,0))
end

local function fnCreateDetailContentLayer()
	-- 创建ScrollView
	scrollViewHeight = 315
	local contentScrollView = CCScrollView:create()
		  contentScrollView:setTouchPriority(-403-3 or -703)
		  contentScrollView:setViewSize(CCSizeMake(420, scrollViewHeight))
		  contentScrollView:setDirection(kCCScrollViewDirectionVertical)
		  contentScrollView:setPosition(ccp(0,0))
	
	layerHeight = 315
	_contenterlayer = CCLayer:create()
	_contenterlayer:setContentSize(CCSizeMake(420,layerHeight))
	_contenterlayer:setPosition(ccp(0,scrollViewHeight-layerHeight))
	-- 创建属性小界面内容
	createScrollViewInfo()

	contentScrollView:setContainer(_contenterlayer)
	
	_affixbg:addChild(contentScrollView)
end

local function createPocketItem( ... )
	-- body
	--锦囊法阵
	local pocketEffect = XMLSprite:create("images/pocket/jinnang/".."jinnang")
		  pocketEffect:setAnchorPoint(ccp(0.5,0))
		  pocketEffect:setPosition(ccp(fs_bg:getContentSize().width*0.6,fs_bg:getContentSize().height*0.3))
	fs_bg:addChild(pocketEffect)
	-- 锦囊icon并且上下动
	local iconSprite = ItemSprite.getItemBigSpriteById(_desItemData.item_template_id)
		  iconSprite:setScale(0.7)
		  iconSprite:setAnchorPoint(ccp(0.5,0.5))
		  iconSprite:setPosition(ccp(fs_bg:getContentSize().width*0.6,fs_bg:getContentSize().height*0.5))		  
	fs_bg:addChild(iconSprite)
	local upAction = CCMoveTo:create(1, ccp(iconSprite:getPositionX(),iconSprite:getPositionY()+10))
	local downAction = CCMoveTo:create(1, ccp(iconSprite:getPositionX(),iconSprite:getPositionY()-10))
	local actionArray = CCArray:create()
    	  actionArray:addObject(upAction)
    	  actionArray:addObject(downAction)
    iconSprite:runAction(CCRepeatForever:create(CCSequence:create(actionArray)))
	-- 星星
	local star_sprite = getStarByQuality(_desItemData.itemDesc.quality)
		  star_sprite:setPosition(ccp(fs_bg:getContentSize().width*0.6,10))
	fs_bg:addChild(star_sprite)
	-- 锦囊名字
	local name_color = HeroPublicLua.getCCColorByStarLevel(_desItemData.itemDesc.quality)
 	local nameLabel = CCRenderLabel:create(_desItemData.itemDesc.name, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    	  nameLabel:setColor(name_color)
    	  nameLabel:setAnchorPoint(ccp(0.5,0))
    	  nameLabel:setPosition(ccp(fs_bg:getContentSize().width*0.6,fs_bg:getContentSize().height*0.6+iconSprite:getContentSize().height*0.7*0.5))
    fs_bg:addChild(nameLabel,2)

    -- 等级
    level_font = CCRenderLabel:create( "Lv:" , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    level_font:setColor(ccc3(0xff,0xe4,0x00))
    level_font:setAnchorPoint(ccp(1,1))
    level_font:setPosition(ccp(fs_bg:getContentSize().width*0.6,fs_bg:getContentSize().height*0.5-iconSprite:getContentSize().height*0.7*0.5))
    fs_bg:addChild(level_font,2)
	-- 等级
	realLevelNum = tonumber(_desItemData.va_item_text.pocketLevel)
 	levelLabel = CCRenderLabel:create(_desItemData.va_item_text.pocketLevel, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff,0xff,0xff))
    levelLabel:setAnchorPoint(ccp(0,1))
    levelLabel:setPosition(ccp(fs_bg:getContentSize().width*0.6,fs_bg:getContentSize().height*0.5-iconSprite:getContentSize().height*0.7*0.5))
    fs_bg:addChild(levelLabel)

    --  属性
	local cur_tData = PocketData.getPocketAttrByItem_id( tonumber(_desItemData.item_id) )

	local index = 0
	for k,v in pairs(cur_tData) do
		local displayName = v.desc.displayName
		local displayNum = v.displayNum
		index = index + 1
	    local atrr_font = CCRenderLabel:create(displayName .. ":", g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    	  atrr_font:setColor(ccc3(0xff,0xe4,0x00))
	    	  atrr_font:setAnchorPoint(ccp(0,1))
	    	  atrr_font:setVisible(false)
	    fs_bg:addChild(atrr_font,2)
	    
		-- 属性值
	 	local atrrLabel = CCRenderLabel:create(displayNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    	  atrrLabel:setColor(ccc3(0xff,0xff,0xff))
	    	  atrrLabel:setAnchorPoint(ccp(0,1))
	    	  atrrLabel:setPosition(ccp(atrr_font:getPositionX()+atrr_font:getContentSize().width+5,atrr_font:getPositionY()))
	    	  atrrLabel:setVisible(false)
	    fs_bg:addChild(atrrLabel)
	    
	    -- 保存
		attrNameFontArr[k] = atrr_font
		attrNumFontArr[k] = atrrLabel
		realAttrNumArr[k] = displayNum
	end
end

-- 创建锦囊信息界面
function createPocketInfo( ... )
	-- 创建锦囊背景
	fs_bg = CCSprite:create("images/hunt/fsoul_bg.png")
	fs_bg:setAnchorPoint(ccp(0.5,0.5))
	local fs_bgPoy = _bgLayer:getContentSize().height-closeMenuItem:getContentSize().height*g_fScaleX-100*g_fScaleX- fs_bg:getContentSize().height*0.5*g_fScaleX
		  fs_bg:setPosition(ccp(_bgLayer:getContentSize().width*0.12,fs_bgPoy))
		  fs_bg:setScale(g_fScaleX)
	_bgLayer:addChild(fs_bg)
	-- 创建锦囊整体
	createPocketItem()
	-- 属性描述小界面 begin
	_affixbg = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
    _affixbg:setPreferredSize(CCSizeMake(420,315))
    _affixbg:setAnchorPoint(ccp(0.5,1))
    _affixbg:setPosition(470,fs_bg:getContentSize().height*1.35)
    fs_bg:addChild(_affixbg)

    _labelbg = CCScale9Sprite:create(CCRectMake(25, 15, 20, 10),IMG_PATH .. "astro_labelbg.png")
    _labelbg:setPreferredSize(CCSizeMake(200,40))
    _labelbg:setAnchorPoint(ccp(0.5,0.5))
    _labelbg:setPosition(_affixbg:getContentSize().width*0.5,fs_bg:getContentSize().height*1.3)
    _affixbg:addChild(_labelbg)

    local buttonTitleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("llp_227"),g_sFontPangWa,24)
    	  buttonTitleLabel:setPosition(_labelbg:getContentSize().width*0.5,_labelbg:getContentSize().height*0.5)
    	  buttonTitleLabel:setAnchorPoint(ccp(0.5,0.5))
    	  buttonTitleLabel:setColor(ccc3(0xff,0xf6,0x00))
    _labelbg:addChild(buttonTitleLabel)

    fnCreateDetailContentLayer()
    -- 属性描述小界面 end
end

-- 增加值特效
function setAddAttrAnimation()
	local data = PocketData.getFiltersForItem()
	PocketData.setItemData(data)
	addLevelNum,addExpNum,addNeedNum,totalAddExp = PocketData.getCurLvAndCurExpAndNeedExp( _desItemData.itemDesc.upgradeID, _desItemData.item_id )
	if(addLevelNum > _maxLvLimit)then
		addLevelNum = _maxLvLimit
	end
	-- 增加的数值
	local cur_tData = PocketData.getPocketAttrByItem_id( tonumber(_desItemData.item_id), addLevelNum )
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
	print("realLevelNum==",realLevelNum)

	if(addLevelNum <= realLevelNum)then
		-- 不显示
	else
		local p_x,p_y = levelLabel:getPositionX()+levelLabel:getContentSize().width,levelLabel:getPositionY()
	 	local growLevelNum = addLevelNum - realLevelNum
	 	print("growLevelNum==",growLevelNum)
		addLevelLabel = CCRenderLabel:create("+" .. growLevelNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    addLevelLabel:setAnchorPoint(ccp(0,1))
	    addLevelLabel:setPosition(ccp(p_x, p_y))
	    addLevelLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
 		fs_bg:addChild(addLevelLabel)

		-- 增加的数值
		local cur_tData = PocketData.getPocketAttrByItem_id( tonumber(_desItemData.item_id), addLevelNum )
		for k,v in pairs(cur_tData) do
			local displayName = v.desc.displayName

			addAttrNumArr[k] = v.displayNum
			local growNum = (addLevelNum - realLevelNum) * tonumber(v.growNum)
			local p_x,p_y = attrNumFontArr[k]:getPositionX()+attrNumFontArr[k]:getContentSize().width+10,attrNumFontArr[k]:getPositionY()
			local addAttrLabel = CCRenderLabel:createWithAlign("+" ..growNum, g_sFontPangWa, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke, CCSizeMake(225, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
				  addAttrLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
				  addAttrLabel:setAnchorPoint(ccp(0, 1))
				  addAttrLabel:setPosition(ccp(p_x, p_y))
				  addAttrLabel:setVisible(false)
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
	realExpNum,realNeedNum = LevelUpUtil.getCurExp(_desItemData.itemDesc.upgradeID,_desItemData.va_item_text.pocketExp,_desItemData.va_item_text.pocketLevel)
	bgProress = CCScale9Sprite:create("images/hunt/exp_bg.png")
	bgProress:setContentSize(CCSizeMake(_bgLayer:getContentSize().width/g_fScaleX, 49))
	bgProress:setAnchorPoint(ccp(0.5, 0.5))
	local posY = fs_bg:getPositionY()-fs_bg:getContentSize().height*0.5*g_fScaleX+10*g_fScaleX-bgProress:getContentSize().height*0.5*g_fScaleX
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

	if( realLevelNum < _maxLvLimit )then
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
    if( addLevelNum < _maxLvLimit )then
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
	if(_addLevel~=0 and _addLevel~=nil)then
		realLevelNum = realLevelNum + _addLevel
	end

	local upgradeAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/item/qianghuachenggong", 1, CCString:create(""))
    	  upgradeAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    	  upgradeAnimSprite:setScale(g_fScaleX)
    	  upgradeAnimSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.7))
    _bgLayer:addChild(upgradeAnimSprite,30)
    -- 替换关键帧
    if(_addLevel~=nil and _addLevel >= 1) then
		local addSprite = CCSprite:create("images/common/upgrade.png")
		addSprite:setAnchorPoint(ccp(0.5, 0.5))
		-- 等级
		local levelLabel = CCRenderLabel:create(_addLevel, g_sFontPangWa, 70, 1, ccc3(0, 0, 0), type_stroke)
		levelLabel:setColor(ccc3(255, 255, 255))
		levelLabel:setAnchorPoint(ccp(0.5, 0.5))
		levelLabel:setPosition(ccp(addSprite:getContentSize().width*161.0/270, addSprite:getContentSize().height*43/83))
		addSprite:addChild(levelLabel)
		addSprite:setPosition(ccp(0, -100))
		upgradeAnimSprite:addChild(addSprite,999)
	end

    -- 特效结束回调
    local upgradeAnimationEndCallBack = function ( ... )
    end
    local upgradeDelegate = BTAnimationEventDelegate:create()
    	  upgradeDelegate:registerLayerEndedHandler( upgradeAnimationEndCallBack )
    upgradeAnimSprite:setDelegate(upgradeDelegate)

	for k,v in pairs(realAttrNumArr) do
		if(addAttrNumArr[k])then
			realAttrNumArr[k]  = addAttrNumArr[k]
		end
	end

	levelLabel = CCRenderLabel:create(oldLeveNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff,0xff,0xff))
    levelLabel:setAnchorPoint(ccp(0,1))
    levelLabel:setPosition(ccp(level_font:getPositionX(),level_font:getPositionY()))
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
		    attrNumFontArr[k]:setVisible(false)
		    fs_bg:addChild(attrNumFontArr[k])
		end
	end
	local baseArr = string.split(_desItemData.itemDesc.baseAtt,",")
	local growArr = string.split(_desItemData.itemDesc.growAtt,",")

	for i=1,table.count(baseArr) do
		local baseData = string.split(baseArr[i],"|")
		local growData = string.split(growArr[i],"|")
		local nextLabel = _contenterlayer:getChildByTag(i):getChildByTag(i):getChildByTag(i):getChildByTag(i)
		tolua.cast(nextLabel,"CCLabelTTF")
		if(realLevelNum==0)then
			-- nextLabel:setString(baseData[2]+growData[2]*(tonumber(_desItemData.va_item_text.pocketLevel))+growData[2])
		else
			local curLabel = tolua.cast(_contenterlayer:getChildByTag(i):getChildByTag(i),"CCLabelTTF")
			curLabel:setString(baseData[2]+realLevelNum*growData[2])
			if(tonumber(_desItemData.va_item_text.pocketLevel)<_maxLvLimit)then
				nextLabel:setString(baseData[2]+(realLevelNum+1)*growData[2])
			else
				nextLabel:setString(baseData[2]+(realLevelNum)*growData[2])
			end
			local descArray = string.split(_desItemData.itemDesc.level_effect,",")
			local effectStr = nil
			for k,v in pairs(descArray) do
				local levelDescArray = string.split(v,"|")
				if(tonumber(realLevelNum)>=tonumber(levelDescArray[1]))then
					effectStr = DB_Awake_ability.getDataById(levelDescArray[2])
					effectStr = effectStr.des
				end
			end
			local curEffectLabel = tolua.cast(_contenterlayer:getChildByTag(99):getChildByTag(99):getChildByTag(99),"CCLabelTTF")

			if(effectStr~=nil)then
				curEffectLabel:setString(effectStr)
			end

			local str = nil
			for k,v in pairs(descArray) do
				local levelDescArray = string.split(v,"|")
				if(tonumber(_desItemData.va_item_text.pocketLevel)<tonumber(levelDescArray[1]))then
					str = GetLocalizeStringBy("llp_243",levelDescArray[1])
					break
				end
			end

			local effectLabel = tolua.cast(_contenterlayer:getChildByTag(100),"CCLabelTTF")
			if(str~=nil)then
				effectLabel:setString(str)
			end

			local nexteffectStr = nil
			for k,v in pairs(descArray) do
				local levelDescArray = string.split(v,"|")
				if(tonumber(realLevelNum)<tonumber(levelDescArray[1]))then
					nexteffectStr = DB_Awake_ability.getDataById(levelDescArray[2])
					nexteffectStr = nexteffectStr.des
					break
				end
			end
			local nextEffectLabel = tolua.cast(_contenterlayer:getChildByTag(100):getChildByTag(100):getChildByTag(100),"CCLabelTTF")
			local nextEffectTitleLabel = tolua.cast(_contenterlayer:getChildByTag(100),"CCLabelTTF")
			if(tonumber(_desItemData.va_item_text.pocketLevel)== _maxLvLimit)then
				nextEffectLabel:setVisible(false)
				nextEffectTitleLabel:setVisible(false)
			end
			if(nexteffectStr~=nil)then
				nextEffectLabel:setString(nexteffectStr)
			end
		end
	end
end

-- 刷新真实等级和属性值 经验超上限用
function refreshLevelAndAttrForCallService( ... )
	if(levelLabel)then
		levelLabel:removeFromParentAndCleanup(true)
		levelLabel = nil
	end
	realLevelNum = tonumber(_desItemData.va_item_text.pocketLevel)
	levelLabel = CCRenderLabel:create("Lv." .. realLevelNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff,0xff,0xff))
    levelLabel:setAnchorPoint(ccp(0,1))
    levelLabel:setPosition(ccp(level_font:getPositionX()+level_font:getContentSize().width+5,level_font:getPositionY()))
    fs_bg:addChild(levelLabel)

    local cur_tData = PocketData.getPocketAttrByItem_id( tonumber(_desItemData.item_id) )
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

function getNeedUpgradeItemDataAndMaxLv( ... )
	return _desItemData,_maxLvLimit
end

local function createItemInCell( p_data,a2,p_pos )
	-- body
	local fsMenu = BTSensitiveMenu:create()
	if(fsMenu:retainCount()>1)then
		fsMenu:release()
		fsMenu:autorelease()
	end
	fsMenu:setAnchorPoint(ccp(0,0))
	fsMenu:setPosition(ccp(0,0))
	a2:addChild(fsMenu)
	fsMenu:setTouchPriority(-131)
	local normalSprite = ItemSprite.getItemSpriteByItemId( tonumber(p_data.item_template_id),p_data.va_item_text.pocketLevel)
	local selectSprite = ItemSprite.getItemSpriteByItemId( tonumber(p_data.item_template_id),p_data.va_item_text.pocketLevel)
	local fsMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
		  fsMenuItem:setAnchorPoint(ccp(0.5,0.5))
		  fsMenuItem:setPosition(ccp(610*p_pos,113-fsMenuItem:getContentSize().height*0.5))
		  fsMenuItem:registerScriptTapHandler(fsMenuItemAction)
	fsMenu:addChild(fsMenuItem,1,tonumber(p_data.item_id))
	
	--lv
	local lvLabel = CCRenderLabel:create(p_data.va_item_text.pocketLevel,  g_sFontName , 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		  lvLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
		  lvLabel:setAnchorPoint(ccp(1, 0))
		  lvLabel:setPosition(ccp( fsMenuItem:getContentSize().width*0.85, 0))
	fsMenuItem:addChild(lvLabel)

	-- 名字
	local name_color = HeroPublicLua.getCCColorByStarLevel(p_data.itemDesc.quality)
	local iconName = CCLabelTTF:create(p_data.itemDesc.name,g_sFontName,18)
		  iconName:setColor(name_color)
		  iconName:setAnchorPoint(ccp(0.5,0.5))
		  iconName:setPosition(ccp(fsMenuItem:getContentSize().width*0.5,-10))
	fsMenuItem:addChild(iconName)
	-- 添加到数据按钮中 以itemId为key
	_fsoulDataButton[tonumber(p_data.item_id)] = fsMenuItem
	-- 给已经选择的数据添加选择框
	local chooseData = PocketData.getChooseFSItemTable()
	for k,v in pairs(chooseData) do
		if(tonumber(v) == tonumber(p_data.item_id))then
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

-- 创建锦囊背包
function createFSTableView( ... )
	-- up
	local posY = bgProress:getPositionY()-10*g_fScaleX-bgProress:getContentSize().height*0.5*g_fScaleX+10*g_fScaleX
	local upSprite = CCSprite:create("images/hunt/up_line.png")
		  upSprite:setAnchorPoint(ccp(0.5,1))
		  upSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
		  upSprite:setScale(g_fScaleX)
	_bgLayer:addChild(upSprite,10)
	-- down
	local posY = chooseMenuItem:getContentSize().height*g_fScaleX+10*g_fScaleX

	local downSprite = CCSprite:create("images/hunt/down_line.png")
		  downSprite:setAnchorPoint(ccp(0.5,0))
		  downSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
		  downSprite:setScale(g_fScaleX)
	_bgLayer:addChild(downSprite,10)
	
	-- 去锦囊数据并排序 begin
	_fsoulData = {}
	local bagInfo = DataCache.getBagInfo()
	local herosPockets = HeroUtil.getAllPocketOnHeros()
	for k,v in pairs(bagInfo.pocket) do
		if(_desItemData.item_id~=v.item_id and v.va_item_text~=nil and tonumber(v.va_item_text.lock)~=1)then
			table.insert(_fsoulData, v)
		end
	end
	table.sort( _fsoulData, BagUtil.pocketSortForBag )
	-- 去锦囊数据并排序 end
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
					createItemInCell(_fsoulData[a1*5+i],a2,posArrX[i])
				end
			end
			r = a2
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			num = #_fsoulData
			r = math.ceil(num/5)
		elseif (fn == "cellTouched") then

		else

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
	_bagTableView:setTouchPriority(-132)
end


-- 添加选中高亮 已添加删除，未添加就加上
function setSelectBox( item_id )
	if(_fsoulDataButton[item_id]:getChildByTag(110))then
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

-- 确认回调
function yesMenuItemAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 选择列表
	local chooseTab = PocketData.getChooseFSItemTable()
	if( table.isEmpty(chooseTab) )then
     	AnimationTip.showTip( GetLocalizeStringBy("llp_235"))
     	return
	end

	-- 品质不能高于目标品质
	local isTip = false
	for k,v in pairs(chooseTab) do
		local data = ItemUtil.getItemInfoByItemId(v)
		if( tonumber(data.itemDesc.quality) > tonumber(_desItemData.itemDesc.quality) and data.itemDesc.is_exp~=1)then
			isTip = true
			break
		end
	end
	if(isTip)then
     	AnimationTip.showTip( GetLocalizeStringBy("llp_236"))
     	return
	end
	-- 是否包含4星级以上的锦囊要被吞噬
	local isHave = false
	for k,v in pairs(chooseTab) do
		local data = ItemUtil.getItemInfoByItemId(v)
		if(tonumber(data.itemDesc.quality) >= 4 )then
			isHave = true
			break
		end
	end
	local orangeStr = ""
	local index = 1
	for k,v in pairs(chooseTab) do
		local data = ItemUtil.getItemInfoByItemId(v)
		if(tonumber(data.itemDesc.quality) == 6 and data.itemDesc.is_exp~=1)then
			orangeStr = orangeStr.."［"..data.itemDesc.name.."］"
			index = index+1
			if(index>3)then
				break
			end
		end
	end
	if(isHave)then
		require "script/ui/tip/AlertTip"
		local str = nil
		if(index<=3)then
			str = GetLocalizeStringBy("llp_262")
		else
			str = GetLocalizeStringBy("llp_263")
		end
		
		AlertTip.showAlert(GetLocalizeStringBy("llp_237"),sendService,true,chooseTab)

		local richInfo = {}
	    richInfo.width = 460
	    richInfo.alignment = 2
	    richInfo.labelDefaultFont = g_sFontName
	    richInfo.labelDefaultSize = 25
	    richInfo.elements = 
	    {
	        {
	            type = "CCLabelTTF",
	            text = GetLocalizeStringBy("llp_261"),
	            color = ccc3(0x78, 0x25, 0x00),
	        },
	        {
	            type = "CCLabelTTF",
	            text = orangeStr,
	            color = ccc3(255, 0x84, 0)
	        },
	        {
	            type = "CCLabelTTF",
	            text = str,
	            color = ccc3(0x78, 0x25, 0x00),
	        }
	    }
	    require "script/libs/LuaCCLabel"
	    local richLabel = LuaCCLabel.createRichLabel(richInfo)
	    local runningScene = CCDirector:sharedDirector():getRunningScene()
	    local pBg = runningScene:getChildByTag(345):getChildByTag(345)
	    local pDesLabel = runningScene:getChildByTag(345):getChildByTag(345):getChildByTag(345)
	    if(index>1)then
	    	pBg:addChild(richLabel)
	    end
	    richLabel:setAnchorPoint(ccp(0.5,0.5))
	    richLabel:setPosition(ccp(pBg:getContentSize().width*0.5,pBg:getContentSize().height*0.4))
	else
		sendService(true,chooseTab)
	end
end

-- 发送强化请求
function sendService( isConfirm, chooseTab )
	if(isConfirm == false)then
		return
	end
	
	PocketController.upgradePocketCallback(_desItemData.item_id,chooseTab)
end

-- 取消回调
function cancelMenuItemAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 选择列表
	local chooseTab = PocketData.getChooseFSItemTable()
	if( table.isEmpty(chooseTab) )then
     	AnimationTip.showTip( GetLocalizeStringBy("llp_235"))
     	return
	end

	-- 清空选择锦囊列表
	PocketData.ClearChooseFSItemTable()
	-- 刷新一下背包
	_bagTableView:reloadData()
	addLevelNum,addExpNum,addNeedNum,totalAddExp = PocketData.getCurLvAndCurExpAndNeedExp( _desItemData.itemDesc.upgradeID, _desItemData.item_id )
	-- 刷新ui
	refreshUI()
end



-- 选择锦囊回调
function fsMenuItemAction( tag, itemBtn )
	if(_playAction==true)then
		return
	end
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	isExp = false
	local bagInfo = DataCache.getBagInfo()

	for k,v in pairs(bagInfo.pocket) do
		if(tonumber(v.item_id)==tonumber(tag))then
			local data = DB_Item_pocket.getDataById(v.item_template_id)
			if(tonumber(data.is_exp)==1)then
				isExp = true
			end
			break
		end
	end

	local chooseData = PocketData.getChooseFSItemTable()

	local isIn = false
	if(_fsoulDataButton[tag]:getChildByTag(110)~=nil)then
		isIn = true
	end

	if(isIn)then
		print("11111111")
		-- 添加选择数据
		PocketData.addChooseFSItemId(tag)
		-- 添加选择框
		setSelectBox(tag)
		-- 刷新ui
		refreshUI()
	else
		local curLv = tonumber(_desItemData.va_item_text.pocketLevel)
		if(curLv >= _maxLvLimit)then
			-- 等级最大上限
	     	AnimationTip.showTip(GetLocalizeStringBy("llp_238"))
			return
		end

		local srcData = ItemUtil.getItemByItemId(tag)

		if( tonumber(_desItemData.itemDesc.quality) < tonumber(srcData.itemDesc.quality) and isExp==false )then
	     	AnimationTip.showTip( GetLocalizeStringBy("key_2986"))
	     	return
		end
		-- 进行判断是否溢出
		-- 已经选择的锦囊可以提供的等级
		local canUpLv,a,b,c = PocketData.getCurLvAndCurExpAndNeedExp( _desItemData.itemDesc.upgradeID, _desItemData.item_id )
		if(canUpLv >= _maxLvLimit)then
			_isCanCallService = true
			-- 等级最大上限
	     	AnimationTip.showTip(GetLocalizeStringBy("llp_238"))
			return
		end

		-- 添加选择数据
		PocketData.addChooseFSItemId(tag)
		local chooseData = PocketData.getChooseFSItemTable()
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
	if(_pCallBack~=nil)then
		_pCallBack(_itemId)
		return
	end

	require "script/ui/pocket/PocketMainLayer"
	local layer = PocketMainLayer.createLayer(_hid)
	MainScene.changeLayer(layer,"PocketMainLayer")
end

function getFsoulData( ... )
	return _fsoulData
end

local function updateInfo( ... )
	-- body
	local baseArr = string.split(_desItemData.itemDesc.baseAtt,",")
	local growArr = string.split(_desItemData.itemDesc.growAtt,",")

	for i=1,table.count(baseArr) do
		local baseData = string.split(baseArr[i],"|")
		local growData = string.split(growArr[i],"|")
		local nextLabel = _contenterlayer:getChildByTag(i):getChildByTag(i):getChildByTag(i):getChildByTag(i)
		tolua.cast(nextLabel,"CCLabelTTF")
		local realNum = tonumber(_desItemData.va_item_text.pocketLevel)
		if(addLevelNum==realNum and realNum<_maxLvLimit)then
			print("xiaoyu")
			nextLabel:setString(baseData[2]+growData[2]*(tonumber(_desItemData.va_item_text.pocketLevel))+growData[2])
		else
			nextLabel:setString(baseData[2]+addLevelNum*growData[2])
		end
	end
end

-- 刷新需要变动的UI
-- 根据选择列表刷新数值 chooseTable
function refreshUI()
	-- 刷新右上按钮显示
	local chooseData = PocketData.getChooseFSItemTable()

	if(table.isEmpty(chooseData))then
     	-- 去除增加值特效
     	-- addLevelNum=0
     	removeAddAttrAnimation()
	else
		-- 增加值特效
		setAddAttrAnimation()
	end

	updateInfo()
end

-- 升级特效
function upAnimation( callfun )
	local iconSprite = CCSprite:create("images/pocket/pocketbig.png")
	local function fnupAnimSpriteEnd( ... )
		if(upAnimSprite)then
			upAnimSprite:release()
			upAnimSprite:removeFromParentAndCleanup(true)
			upAnimSprite = nil
		end
		if(callfun)then
			callfun()
		end
	end
    upAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/pocket/jinnanglizi/jinnanglizi"), -1,CCString:create(""))
    upAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    upAnimSprite:setPosition(ccp(fs_bg:getContentSize().width*0.6,fs_bg:getContentSize().height*0.6-iconSprite:getContentSize().height*0.7*0.5))
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

	local cur_tData = PocketData.getPocketAttrByItem_id( tonumber(_desItemData.item_id), newLevelNum )

	for k,v in pairs(cur_tData) do
		local temArr = {}
			  temArr.txt = v.desc.sigleName
			  temArr.num = (newLevelNum - oldLeveNum) * tonumber(v.growNum)
		table.insert(retArr,temArr)
	end
	return retArr
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

	local curLv = tonumber(_desItemData.va_item_text.pocketLevel)

	if(curLv >= _maxLvLimit)then
     	AnimationTip.showTip(GetLocalizeStringBy("llp_238"))
		return
	end

	require "script/ui/pocket/PocketUpgradeByStarLayer"
	PocketUpgradeByStarLayer.createLayerStar()
end
--获取特殊id物品信息
function getDesItemInfoByItemId( item_id,_hid )
	-- body
	local data = PocketData.getFiltersForItem(_hid,true)

	for k,v in pairs(data)do
		if(tonumber(item_id)==tonumber(v.item_id))then
			return v
		end
	end
end

local function initPartData( item_id )
	-- 要升级的目标锦囊信息
	_desItemData = getDesItemInfoByItemId(item_id)
	-- 升级前等级
	oldLeveNum = tonumber(_desItemData.va_item_text.pocketLevel)
	-- 锦囊级别最大上限
	_maxLvLimit = DB_Item_pocket.getDataById(_desItemData.item_template_id).maxlevel
	-- 清空选择锦囊列表
	PocketData.ClearChooseFSItemTable()
end

-- 创建升级界面
-- tSign:用于记住返回到哪个界面
function createPocketLayer(item_id, pCallBack,p_hid)
	init()

	-- 入口标志
	_pCallBack  = pCallBack
	_bgLayer 	= CCLayer:create()
	_hid 	 	= p_hid
	_itemId  	= item_id

	-- 隐藏玩家信息栏
	MainScene.setMainSceneViewsVisible(false, false, false)
	-- 初始化部分该界面数据
	initPartData(item_id)
	-- 初始化升级锦囊界面
	initPocketLayer()

	return _bgLayer
end