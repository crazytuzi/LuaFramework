-- FileName: PocketInfoLayer.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: 锦囊信息界面
--[[TODO List]]

module("PocketInfoLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/pocket/PocketChooseLayer"
require "script/utils/LuaUtil"
require "script/ui/main/MainScene"
require "script/libs/LuaCCLabel"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "db/DB_Normal_config"
require "db/DB_Awake_ability"
require "script/network/PreRequest"
require "script/ui/hero/HeroPublicLua"

local Star_Img_Path = "images/star/intimate/"

local _pCallBack 			= nil
local _strengthenBtn 		= nil
local _layerNameSprite 		= nil
local _bgLayer 				= nil
local _bgSprite 			= nil
local _heroInfo 			= nil
local _bottomBgSprite 		= nil
local _templeId 			= nil
local _desItemData 			= nil
local _downLabel 			= nil
local _pocketDesScrollView  = nil
local _itemId 				= 0
local _pos 					= 0
local _scaleY 				= 0.4
local _scaleId 				= 0
local _pocketNum 			= 2
local _pTouch 				= 0 	

local _isBag 				= false
local _pOpenTable 			= {}
local _pocketTable 			= {}
local _havePocketTable 		= {}
local _pLimitLevel 			= {}


local function init()
	_pCallBack 				= nil
	_templeId 				= nil
	_strengthenBtn 			= nil
	_layerNameSprite 		= nil
	_desItemData 			= nil
	_bgLayer 				= nil
	_bgSprite 				= nil
	_heroInfo 				= nil
	_downLabel 				= nil
	_bottomBgSprite 		= nil
	_pocketDesScrollView  	= nil
	_pocketNum 				= 2
	_itemId 				= 0
	_pos 					= 0
	_scaleId 				= 0
	_pTouch 				= 0 	
	_isBag 					= false
	_havePocketTable 		= {}
	_pOpenTable 			= {}
	_pocketTable 			= {}
	_pLimitLevel 			= {}
end

local function createArrtributeChangeDes( p_index,p_data,p_growdata )
	-- body
	local baseArr = string.split(p_data,"|")
	local growArr = string.split(p_growdata,"|")
	local attStr = DB_Affix.getDataById(tonumber(baseArr[1]))
	local attLabel = CCLabelTTF:create(attStr.sigleName.."＋",g_sFontName,20)
	attLabel:setAnchorPoint(ccp(0.5,1))
	attLabel:setColor(ccc3(0x00,0xff,0x18))
	_contenterlayer:addChild(attLabel,0,p_index)

	local attDesLabel = nil
	if(_itemId~=nil)then
		attDesLabel = CCLabelTTF:create(baseArr[2]+growArr[2]*(tonumber(_desItemData.va_item_text.pocketLevel)),g_sFontName,20)
	else
		attDesLabel = CCLabelTTF:create(baseArr[2],g_sFontName,20)
	end
	attDesLabel:setAnchorPoint(ccp(0,1))
	attDesLabel:setColor(ccc3(0x00,0xff,0x18))
	attLabel:addChild(attDesLabel,0,p_index)

	local p_width = 200
	local posHang,posLie = math.modf((p_index-1)/2)

	if(posLie==0.5)then
		attLabel:setPosition(ccp(_bottomBgSprite:getContentSize().width*0.6,_contenterlayer:getContentSize().height*0.9-posHang*attLabel:getContentSize().height*2))
	else
		attLabel:setPosition(ccp(_bottomBgSprite:getContentSize().width*0.3,_contenterlayer:getContentSize().height*0.9-posHang*attLabel:getContentSize().height*2))
	end
	
	attDesLabel:setPosition(ccp(attLabel:getContentSize().width,attLabel:getContentSize().height))
end

local function createLeftLineSprite()
	-- body
	local leftSprite = CCSprite:create("images/god_weapon/cut_line.png")
	leftSprite:setAnchorPoint(ccp(1,0.5))
	return leftSprite
end

local function createRightLineSprite()
	-- body
	local rightSprite = CCSprite:create("images/god_weapon/cut_line.png")
	rightSprite:setScale(-1)
	rightSprite:setAnchorPoint(ccp(1,0.5))
	return rightSprite
end

local function createScrollViewInfo()
	-- 锦囊属性标签
	local pocketAttributeLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_245"),g_sFontName,25)
		  pocketAttributeLabel:setAnchorPoint(ccp(0.5,1))
		  pocketAttributeLabel:setPosition(ccp(_contenterlayer:getContentSize().width*0.5,_contenterlayer:getContentSize().height))
		  pocketAttributeLabel:setColor(ccc3(0xff,0xf6,0x00))
	_contenterlayer:addChild(pocketAttributeLabel)

	local leftSprite = createLeftLineSprite()
		  leftSprite:setPosition(ccp(_contenterlayer:getContentSize().width*0.5-pocketAttributeLabel:getContentSize().width*0.5,_contenterlayer:getContentSize().height-pocketAttributeLabel:getContentSize().height*0.5))
	_contenterlayer:addChild(leftSprite)

	local rightSprite = createRightLineSprite()
		  rightSprite:setPosition(ccp(_contenterlayer:getContentSize().width*0.5+pocketAttributeLabel:getContentSize().width*0.5,_contenterlayer:getContentSize().height-pocketAttributeLabel:getContentSize().height*0.5))
	_contenterlayer:addChild(rightSprite)
	-- 具体锦囊属性
	local baseArr = nil
	if(_itemId~=nil)then
		baseArr = string.split(_desItemData.itemDesc.baseAtt,",")
	else
		baseArr = string.split(_desItemData.baseAtt,",")
	end
	local growArr = nil
	if(_itemId~=nil)then
		growArr = string.split(_desItemData.itemDesc.growAtt,",")
	else
		growArr = string.split(_desItemData.growAtt,",")
	end
	for i=1,table.count(baseArr) do
		createArrtributeChangeDes(i,baseArr[i],growArr[i])
	end
	-- 锦囊效果标签
	local pocketEffectLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_246"),g_sFontName,25)
		  pocketEffectLabel:setAnchorPoint(ccp(0.5,1))
		  pocketEffectLabel:setPosition(ccp(_contenterlayer:getContentSize().width*0.5,_contenterlayer:getContentSize().height-pocketAttributeLabel:getContentSize().height*2-(math.ceil(table.count(baseArr)/2)*2-1)*pocketAttributeLabel:getContentSize().height))
		  pocketEffectLabel:setColor(ccc3(0xff,0xf6,0x00))
	_contenterlayer:addChild(pocketEffectLabel)

	local effectLeftSprite = createLeftLineSprite()
		  effectLeftSprite:setPosition(ccp(_contenterlayer:getContentSize().width*0.5-pocketEffectLabel:getContentSize().width*0.5,pocketEffectLabel:getPositionY()-pocketEffectLabel:getContentSize().height*0.5))
	_contenterlayer:addChild(effectLeftSprite)

	local effectRightSprite = createRightLineSprite()
		  effectRightSprite:setPosition(ccp(_contenterlayer:getContentSize().width*0.5+pocketEffectLabel:getContentSize().width*0.5,pocketEffectLabel:getPositionY()-pocketEffectLabel:getContentSize().height*0.5))
	_contenterlayer:addChild(effectRightSprite)
	-- 当前锦囊效果
	local effectDescTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_244"),g_sFontName,20)
		  effectDescTitleLabel:setColor(ccc3(0x00,0xff,0x18))
		  effectDescTitleLabel:setAnchorPoint(ccp(0,1))
		  effectDescTitleLabel:setPosition(ccp(100,pocketEffectLabel:getPositionY()-pocketEffectLabel:getContentSize().height*2))
	_contenterlayer:addChild(effectDescTitleLabel,0,99)

	local sprite = CCSprite:create()
		  sprite:setContentSize(effectDescTitleLabel:getContentSize())
		  sprite:setAnchorPoint(ccp(0,0))
    	  sprite:setPosition(ccp(effectDescTitleLabel:getContentSize().width,effectDescTitleLabel:getContentSize().height))
    effectDescTitleLabel:addChild(sprite)
	-- 当前锦囊效果具体属性
	local descArray = nil
	if(_itemId~=nil)then
		descArray = string.split(_desItemData.itemDesc.level_effect,",")
	else
		descArray = string.split(_desItemData.level_effect,",")
	end
	local effectStr = nil
	for k,v in pairs(descArray) do
		local levelDescArray = string.split(v,"|")
		if(_itemId~=nil)then
			if((tonumber(_desItemData.va_item_text.pocketLevel)>=tonumber(levelDescArray[1])))then
				effectStr = DB_Awake_ability.getDataById(levelDescArray[2])
				effectStr = effectStr.des
			end
		else
			effectStr = DB_Awake_ability.getDataById(levelDescArray[2])
			effectStr = effectStr.des
			break
		end
	end

	local effectDescLabel = CCLabelTTF:create(effectStr,g_sFontName,20)
		  effectDescLabel:setAnchorPoint(ccp(0,1))
		  effectDescLabel:setDimensions(CCSizeMake(340, 0))
		  effectDescLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
		  effectDescLabel:setPosition(ccp(0,0))
	sprite:addChild(effectDescLabel,0,99)
end
--[[
    @des    :创建tableView
    @param  :参数table
    @return :创建好的tableView
--]]
local function createScrollView(p_param)
    --创建ScrollView
	local contentScrollView = CCScrollView:create()
		  contentScrollView:setTouchPriority(-403-3 or -703)
		  contentScrollView:setViewSize(p_param.bgSize)
		  contentScrollView:setDirection(kCCScrollViewDirectionVertical)
	scrollViewHeight = 315

	_contenterlayer = CCLayer:create()
	_contenterlayer:setContentSize(p_param.bgSize)
	_contenterlayer:setPosition(ccp(0,0))

	createScrollViewInfo()

	contentScrollView:setContainer(_contenterlayer)
	contentScrollView:setPosition(ccp(0,0))
	return contentScrollView
end

--创建中间锦囊
local function createMiddle( ... )
	local pocketSprite = nil
	if(_itemId~=nil)then
		_pocketData = DB_Item_pocket.getDataById(_desItemData.item_template_id)
		pocketSprite = ItemSprite.getItemBigSpriteById(tonumber(_desItemData.item_template_id))
	else
		_pocketData = DB_Item_pocket.getDataById(_templeId)
		pocketSprite = ItemSprite.getItemBigSpriteById(tonumber(_templeId))
	end
	pocketSprite:setScale(0.7)
	pocketSprite:setAnchorPoint(ccp(0.5,0))
	pocketSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bottomBgSprite:getContentSize().height+80+_strengthenBtn:getContentSize().height))
	_bgSprite:addChild(pocketSprite)

	local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
		  nameBg:setPreferredSize(CCSizeMake(158, 37))
		  nameBg:setAnchorPoint(ccp(0.5, 0))
		  nameBg:setPosition(ccp(pocketSprite:getContentSize().width*0.5,pocketSprite:getContentSize().height))
		  nameBg:setScale(10/7)
		  pocketSprite:addChild(nameBg,10)

	local pocketNameLabel = CCLabelTTF:create(_pocketData.name,g_sFontPangWa,23)
    local nameColor = HeroPublicLua.getCCColorByStarLevel(_pocketData.quality)
    	  pocketNameLabel:setAnchorPoint(ccp(0.5,0.5))
    	  pocketNameLabel:setPosition(ccp(nameBg:getContentSize().width*0.5,nameBg:getContentSize().height*0.5))
    	  pocketNameLabel:setColor(nameColor)
    nameBg:addChild(pocketNameLabel)

    local tableSprite = CCSprite:create("images/pocket/ii.png")
    	  tableSprite:setAnchorPoint(ccp(0.5,1))
    	  tableSprite:setScale(10/7)
    	  tableSprite:setPosition(ccp(pocketSprite:getContentSize().width*0.5,15))
    pocketSprite:addChild(tableSprite,1)

    local pocketEffect = XMLSprite:create("images/pocket/jinnangmiaojihuang/".."jinnangmiaojihuang")
    	  pocketEffect:setAnchorPoint(ccp(0.5,1))
    	  pocketEffect:setPosition(ccp(tableSprite:getContentSize().width*0.5,-20))
    	  pocketEffect:setScale(10/7)
    pocketSprite:addChild(pocketEffect,0)
    -- pocketEffect:setScale(0.7)

    local lvSprite = CCSprite:create("images/common/lv.png")
    	  lvSprite:setAnchorPoint(ccp(1,1))
    	  lvSprite:setPosition(ccp(tableSprite:getContentSize().width*0.5,0))
    tableSprite:addChild(lvSprite)

    local lvLabel = nil
    if(_itemId~=nil)then
    	lvLabel = CCLabelTTF:create(_desItemData.va_item_text.pocketLevel,g_sFontName,23)--_pocketData.va_item_text.pocketLevel
    else
    	lvLabel = CCLabelTTF:create(0,g_sFontName,23)
    end
    lvLabel:setAnchorPoint(ccp(0,1))
    lvLabel:setPosition(ccp(tableSprite:getContentSize().width*0.5,0))
    tableSprite:addChild(lvLabel)

    local typeSprite = BagUtil.getSealSpriteByItemTempId(_pocketData.id)
    	  typeSprite:setAnchorPoint(ccp(0.5,1))
    	  typeSprite:setPosition(ccp(tableSprite:getContentSize().width*10/7,tableSprite:getContentSize().height*0.5*10/7+pocketSprite:getContentSize().height*0.5*0.7))
    tableSprite:addChild(typeSprite)

    --星星底
	local starBgSprite = CCSprite:create("images/recharge/transfer/star_bg.png")
		  starBgSprite:setAnchorPoint(ccp(0.5,0))
		  starBgSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bottomBgSprite:getContentSize().height+80+_strengthenBtn:getContentSize().height+pocketSprite:getContentSize().height))
	_bgSprite:addChild(starBgSprite)

	--星星
	--星星数
	local starNum = 0
	if(_itemId~=nil)then
		starNum = tonumber(_desItemData.itemDesc.quality)
	else
		starNum = tonumber(_desItemData.quality)
	end
	--位置table
	local posXTable = (starNum%2 == 0) and {112.5,140.5,87.5,165.5,62.5,190.5} or {128,103,153,78,178,53,203}
	local posY = starBgSprite:getContentSize().height - 10

	for i = 1,starNum do
		local starSprite = CCSprite:create("images/formation/star.png")
		starSprite:setAnchorPoint(ccp(0.5,1))
		starSprite:setPosition(ccp(posXTable[i],posY))
		starBgSprite:addChild(starSprite)
	end

end

-- 创建底边栏
local function createBottom( ... )
	-- 强化按钮
	local strengthenMenuBar = CCMenu:create()
		  strengthenMenuBar:setPosition(ccp(0, 0))
		  strengthenMenuBar:setTouchPriority(-1002)
	_bgLayer:addChild(strengthenMenuBar,1)
	
	_strengthenBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1269"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_strengthenBtn:setScale(g_fElementScaleRatio)
	_strengthenBtn:setAnchorPoint(ccp(0.5, 0))
    _strengthenBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.5, 0))
    _strengthenBtn:registerScriptTapHandler(upgradeAction)
    _strengthenBtn:setVisible(false)
	strengthenMenuBar:addChild(_strengthenBtn)
	
	local fullRect = CCRectMake(0,0,640,51)
	local insetRect = CCRectMake(314,27,13,6)
	_bottomBgSprite = CCScale9Sprite:create("images/god_weapon/view_bg.png",fullRect, insetRect)
	_bottomBgSprite:setPreferredSize(CCSizeMake(640,450))
	_bottomBgSprite:setPosition(ccp(0,_strengthenBtn:getContentSize().height-20*g_fElementScaleRatio))
	_bgSprite:addChild(_bottomBgSprite)

	_downLabel = CCSprite:create("images/pocket/3.png")
	_downLabel:setAnchorPoint(ccp(0.5,0.5))
	_downLabel:setPosition(ccp(_bottomBgSprite:getContentSize().width*0.5,_bottomBgSprite:getContentSize().height-10*g_fScaleX))
	_bottomBgSprite:addChild(_downLabel)

	-- 创建属性效果scrollView
    local paramTable = {}
    paramTable.bgSize = CCSizeMake(_bottomBgSprite:getContentSize().width,_bottomBgSprite:getContentSize().height-30*g_fScaleX)
    _pocketDesScrollView = createScrollView(paramTable)
    _pocketDesScrollView:setAnchorPoint(ccp(0,0))
    _pocketDesScrollView:setPosition(ccp(0,0))
    _pocketDesScrollView:setTouchPriority(_pTouch - 2)
    _bottomBgSprite:addChild(_pocketDesScrollView)
end

-- 初始化阵容数据、创建滑动参照图、创建英雄身相
local function initMiddleAndBottom()
	-- 创建下边
	createBottom()
	-- 创建中间按钮
	createMiddle()
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		return true
    elseif (eventType == "moved") then
    else
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _pTouch, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

function upgradeAction( ... )
	-- body
	require "script/ui/pocket/PocketUpgradeLayer"
	local layer = PocketUpgradeLayer.createUpgradeFightSoulLayer(_desItemData.item_id,closeCallBack)
	MainScene.changeLayer(layer,"PocketUpgradeLayer")
end

function closeCallBack( p_itemId )
	-- body
	PocketInfoLayer.showLayer(nil,nil,p_itemId,nil,nil)
end

function closeAction( ... )
	-- body
 	_bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

local function createBaseInterface( ... )
	_bgSprite = CCSprite:create("images/pocket/normalupgrade.jpg")
	_bgSprite:setScale(g_fBgScaleRatio)
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(_bgSprite)
	
	_layerNameSprite = CCSprite:create("images/pocket/1.png")
	_layerNameSprite:setAnchorPoint(ccp(0,1))
	_layerNameSprite:setPosition(ccp(20*g_fElementScaleRatio,_bgLayer:getContentSize().height-20*g_fElementScaleRatio))
	_bgLayer:addChild(_layerNameSprite)
	_layerNameSprite:setScale(g_fElementScaleRatio)
	
	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
		  closeMenuBar:setTouchPriority(-1000000000)
		  closeMenuBar:setPosition(ccp(0, 0))
	_bgLayer:addChild(closeMenuBar)
	-- 关闭按钮
	local closeBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
		  closeBtn:setScale(g_fElementScaleRatio)
		  closeBtn:setAnchorPoint(ccp(1, 1))
    	  closeBtn:setPosition(ccp(_bgLayer:getContentSize().width, _bgLayer:getContentSize().height))
    	  closeBtn:registerScriptTapHandler(closeAction)
	closeMenuBar:addChild(closeBtn)
end

local function initCache( ... )
	-- body
	local data = PocketData.getFiltersForItem()
	if(_itemId~=nil)then
		for k,v in pairs(data)do
			if(tonumber(_itemId)==tonumber(v.item_id))then
				_desItemData = v
			end
		end
	else
		_desItemData = DB_Item_pocket.getDataById(_templeId)
	end
end

function createLayer(pTouch,pZorder,pItemId,pTempleId,pIsBag)
	_pTouch = pTouch or -10000
	_itemId = pItemId
	_templeId = pTempleId
	_pCallBack = pCallBack

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBaseInterface()

	initCache()

	initMiddleAndBottom()
	return _bgLayer
end

function showLayer( pTouch,pZorder,pItemId,pTempleId,p_isBag )
	-- body
	_isBag = p_isBag

	-- 判断是不是经验锦囊
	local data = PocketData.getFiltersForItem()
	local pData = nil
	if(pTempleId==nil)then
		for k,v in pairs(data)do
			if(tonumber(pItemId)==tonumber(v.item_id))then
				pData = v
				break
			end
		end
	else
		pData = DB_Item_pocket.getDataById(pTempleId)
	end
	
	if(tonumber(pData.is_exp)==1)then
		return
	end
	-- end
	local pLayer = createLayer(pTouch,pZorder,pItemId,pTempleId)
	local runing_scene = CCDirector:sharedDirector():getRunningScene()
	runing_scene:addChild(pLayer,pZorder)
end