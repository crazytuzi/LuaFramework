-- Filename：	ItemInfoLayer.lua
-- Author：		zhz
-- Date：		2013-8-27
-- Purpose：		产生物品信息

module ("ItemInfoLayer", package.seeall)


require "script/ui/item/ItemUtil"

require "script/utils/LuaUtil"
require "script/ui/item/ItemSprite"
require "script/ui/shop/GiftsTableCell"
require "script/ui/hero/HeroPublicLua"
require "script/ui/bag/RuneData"

local _itemInfoLayer 		-- 灰色的layer
local _itemNum 				-- 物品的数量
local _itemData				-- 物品的本地属性信息
local _layerProperty		-- 物品的优先级


local function init( )
	_itemInfoLayer = nil
	_itemNum = 0
	_itemData = nil
end

-- layer 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end
-- 关闭按钮的回调函数
local function closeCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_itemInfoLayer:removeFromParentAndCleanup(true)
	_itemInfoLayer=nil
end

-- 拦截 vip 礼包的 item_id,以及（测试 Item_gift）
function createOtherInfoLayer( item_id, item_template_id)
	require "db/DB_Item_direct"
	-- 获得GIftInfo 的信息
	--local items = getGiftInfo(item_template_id)
	require "script/utils/ItemTableView"
	local itemData = getGiftInfo(item_template_id)
	print("itemData")
	print_t(itemData)
	local layer = ItemTableView:create(itemData)
	layer:setTitle(GetLocalizeStringBy("key_3213"))

	local alertContent = {}
	local dbData = DB_Item_direct.getDataById(item_template_id)

	-- alertContent[1] = CCSprite:create("images/common/vip.png")
	-- alertContent[2] = LuaCC.createSpriteOfNumbers("images/main/vip", itemData.level, 15)
	alertContent[1] = CCRenderLabel:create("" .. dbData.name, g_sFontName, 24, 2, ccc3(0,0,0))
	alertContent[1]:setColor(ccc3(0xff, 0xe4, 0x00))

	local alert = BaseUI.createHorizontalNode(alertContent)
	layer:setContentTitle(alert)

	return layer
end


function createItemInfoLayer(item_id, item_template_id,menu_property)
	init()

	if( tonumber(item_template_id) <= 12015 and tonumber(item_template_id) >= 12001) then
		layer = createOtherInfoLayer(item_id, item_template_id)
		return layer
	end
	_layerProperty= menu_property or -661
	_itemInfoLayer = CCLayerColor:create(ccc4(11,11,11,166))
	  -- 设置灰色layer的优先级
    _itemInfoLayer:setTouchEnabled(true)
    _itemInfoLayer:registerScriptTouchHandler(layerToucCb,false,_layerProperty,true)
	-- local scene = CCDirector:sharedDirector():getRunningScene()
 	-- scene:addChild(_itemInfoLayer,999,2013)

	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(562,254)

	-- 物品描述beijing
	local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    local itemInfoBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    itemInfoBg:setContentSize(mySize)
    itemInfoBg:setScale(myScale)
    itemInfoBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    itemInfoBg:setAnchorPoint(ccp(0.5,0.5))
    _itemInfoLayer:addChild(itemInfoBg)

    -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_layerProperty-1)
    itemInfoBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    -- 显示物品的灰色背景
    local itemInfoSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    itemInfoSpite:setContentSize(CCSizeMake(514,179))
    itemInfoSpite:setPosition(ccp(23,39))
    itemInfoBg:addChild(itemInfoSpite)

    local background = CCScale9Sprite:create("images/reward/cell_back.png")
	background:setContentSize(CCSizeMake(506, 172))
	background:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5,itemInfoSpite:getContentSize().height*0.5))
	background:setAnchorPoint(ccp(0.5,0.5))
	itemInfoSpite:addChild(background)

	-- 如果item_id 不为空，通过getItemInfoByItemId(item_id)获得缓存信息，
	-- 得到num(item_num)
	if(item_id ~= nil and item_id > 0) then
		local item_data = ItemUtil.getItemInfoByItemId(item_id)
		if( item_data == nil)then
			item_data = RuneData.getRuneInfoByItemId( item_id )
		end
		_itemNum = item_data.item_num 
	end	
	--获取物品DB表里的信息
	if(item_template_id ~= nil) then
		_itemData = ItemUtil.getItemById(item_template_id)
	end

	--  显示物品
	local itemSprite =  ItemSprite.getItemSpriteByItemId(item_template_id)
	itemSprite:setPosition(ccp(29,52))
	itemInfoSpite:addChild(itemSprite)

	local nameColor = HeroPublicLua.getCCColorByStarLevel(tonumber(_itemData.quality) )
	-- 显示名称
	local itemName = ItemUtil.getItemNameByTid( item_template_id )
	local nameLabel = CCRenderLabel:create(itemName,  g_sFontName , 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	--nameLabel:setColor(ccc3(0xff,0xe4,0x00))
	nameLabel:setColor(nameColor)
	nameLabel:setPosition(ccp(133,147))
	itemInfoSpite:addChild(nameLabel)

	-- 竖线
	local lineSp = CCScale9Sprite:create("images/common/line01.png")
	lineSp:setContentSize(CCSizeMake(382,4))
	lineSp:setPosition(ccp(120,106))
	itemInfoSpite:addChild(lineSp)

	--desc
	if(_itemData.desc ~= nil ) then 
		local descStr = nil
		if(tonumber(item_template_id) >= 1800000 and tonumber(item_template_id) <= 1900000 ) then
			-- 时装碎片
			descStr = ItemUtil.getFashionNameByNameStr( _itemData.desc )
		else
			descStr = _itemData.desc
		end
		local descLabel = CCLabelTTF:create(descStr, g_sFontName, 24,CCSizeMake(345,90),kCCTextAlignmentLeft)
		descLabel:setPosition(ccp(132,102))
		descLabel:setColor(ccc3(0x78,0x25,0x00))
		descLabel:setAnchorPoint(ccp(0,1))
		itemInfoSpite:addChild(descLabel)
	end

	-- 数量
	if( _itemNum and _itemNum ~= 0) then
		numberLabel= CCRenderLabel:create(GetLocalizeStringBy("key_1486") .. _itemNum ,g_sFontName,24,1,ccc3(0,0,0), type_stroke)
		numberLabel:setColor(ccc3(0xff,0xff,0xff))

		-- 越南版本 英文版本
		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
			numberLabel:setAnchorPoint(ccp(0.5, 1))
			numberLabel:setPosition(ccp(itemSprite:getContentSize().width*0.5, 0))
			itemSprite:addChild(numberLabel,10)
		else
			numberLabel:setAnchorPoint(ccp(0,0))
			numberLabel:setPosition(ccp(380,113))
			itemInfoSpite:addChild(numberLabel)
		end
	end

	return _itemInfoLayer

end





