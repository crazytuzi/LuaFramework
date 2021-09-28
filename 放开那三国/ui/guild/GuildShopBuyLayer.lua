-- Filename：	GuildShopBuyLayer.lua
-- Author：		zhz
-- Date：		2014-01-13
-- Purpose：		军团商店购买界面


module("GuildShopBuyLayer",  package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/guild/GuildDataCache"
require "script/ui/guild/GuildUtil"

local _bgLayer 			= nil
local _goodsData 		= nil
local _itemType 		= nil				-- 物品类型 1是物品 2是英雄
local layerBg			= nil
local _numberLabel 		= nil
local _totalPriceLabel 	= nil
local _maxLimitNum 		= 99999
local _curNumber 		= 1
local _totalPrice 		= 0	
local _buyNum 			= 0
local _id 				= 0

local function init(  )
	_bgLayer= nil
	_goodsData= nil
	layerBg= nil
	_numberLabel 		= nil
	_totalPriceLabel 	= nil
	_maxLimitNum 		= 0
	_curNumber 			= 1
	_totalPrice 		= 0	
	_buyNum 			= 0
	_id 				= 0
end



--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	print("hahahahahaha")
    return true
end

-- 关闭
local function closeAction()
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end 

function changeNumberAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if ( tag == 10001 ) then
		-- -10
		_curNumber = _curNumber-10
	elseif ( tag == 10002) then
		-- -1
		_curNumber = _curNumber-1 
	elseif ( tag == 10003 ) then
		-- +1
		_curNumber = _curNumber+1 
	elseif ( tag == 10004 ) then
		-- +10
		_curNumber = _curNumber+10 
	end
	-- 下限
	if ( _curNumber < 1 ) then
		_curNumber = 1
	end
	-- 上限
	if ( _curNumber <= 0 ) then
		_curNumber = 1
	end
	if ( _curNumber > tonumber(_buyNum)) then
		if _buyNum ~= 0 then
			_curNumber = tonumber(_buyNum)
		end
	end
	
    if _curNumber <= 0 then
    	_curNumber = 1
    end
	-- 个数
	_numberLabel:setString(_curNumber)
	_totalPriceLabel:setString(tonumber(_goodsData.costContribution)*_curNumber)
end

-- create 背景2
local function createInnerBg()
	-- 背景2
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560, 330))
	innerBgSp:setAnchorPoint(ccp(0.5, 0))
	innerBgSp:setPosition(ccp(layerBg:getContentSize().width*0.5, 110))
	layerBg:addChild(innerBgSp)

	local innerSize = innerBgSp:getContentSize()
---- 准备数据
	-- 物品名字 和 已经拥有的数量
	local itemName = ""
	local hasNumber = 0
	local _itemData = ActiveUtil.getItemInfo(_itemType,_goodsData.tid)
	if(tonumber(_itemType) == 1)then
		itemName = _itemData.name
		-- local cacheInfo = ItemUtil.getCacheItemInfoBy(_itemData.id)
		-- if( not table.isEmpty(cacheInfo))then
		-- 	hasNumber = cacheInfo.item_num
		-- end
	elseif(tonumber(_itemType) == 3)then
		require "script/model/hero/HeroModel"
		itemName = _itemData.name
		-- local allHeroData = HeroModel.getAllByHtid(tostring(_itemData.id))
		-- if( not table.isEmpty(allHeroData))then
		-- 	hasNumber = table.count(allHeroData)
		-- end
	end

	-- 限购次数
	_maxLimitNum = tonumber(_goodsData.baseNum) - _buyNum
	-- 一共拥有
	-- local totalLael = CCRenderLabel:create(GetLocalizeStringBy("key_2041") .. hasNumber .. GetLocalizeStringBy("key_2557"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
 --    totalLael:setColor(ccc3(0xff, 0xff, 0xff))
 --    totalLael:setPosition(ccp( (innerSize.width-totalLael:getContentSize().width)/2, 295) )
 --    innerBgSp:addChild(totalLael)

    -- 兑换提示
    local buyTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_1438"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_1:setColor(ccc3(0xff, 0xff, 0xff))
    innerBgSp:addChild(buyTipLabel_1)

    -- 物品名称
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 30, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    nameLabel:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2, 250) )
    innerBgSp:addChild(nameLabel)
    buyTipLabel_1:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2 -buyTipLabel_1:getContentSize().width , 240) )

    -- 兑换提示2
    local buyTipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_3113"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_2:setColor(ccc3(0xff, 0xff, 0xff))
    buyTipLabel_2:setPosition(ccp( innerSize.width/2 + nameLabel:getContentSize().width/2, 240) )
    innerBgSp:addChild(buyTipLabel_2)

---- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(-2412)
	innerBgSp:addChild(changeNumBar)

	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, 10001)

	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, 10002)

	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170, 65))
	numberBg:setAnchorPoint(ccp(0.5, 0))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width*0.5, 110))
	innerBgSp:addChild(numberBg)
	-- 数量数字
	_numberLabel = CCRenderLabel:create("1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _numberLabel:setPosition(ccp( (numberBg:getContentSize().width - _numberLabel:getContentSize().width)/2, (numberBg:getContentSize().height + _numberLabel:getContentSize().height)/2) )
    numberBg:addChild(_numberLabel)

	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, 10003)

	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(445, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, 10004)

	-- 总价
	local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2537"), g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    totalTipLabel:setPosition(ccp(110, 72) )
    innerBgSp:addChild(totalTipLabel)
 	-- local goldSp_2 = CCSprite:create("images/common/prestige.png")
	-- goldSp_2:setAnchorPoint(ccp(0,0))
	-- goldSp_2:setPosition(ccp(280, 35))
	-- innerBgSp:addChild(goldSp_2)
	_totalPrice = tonumber(_goodsData.costContribution)
	_totalPriceLabel = CCRenderLabel:create(_totalPrice, g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _totalPriceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _totalPriceLabel:setPosition(ccp(280, 70) )
    innerBgSp:addChild(_totalPriceLabel)
end

local function guildShopBuyCb( cbFlag, dictData, bRet )
    if (dictData.err ~= "ok") then
        return
    end

    local limitType= tonumber(_goodsData.limitType)

    if(limitType ==3 or limitType == 4 or limitType == 5) then
        if(dictData.ret== "failed" ) then
            AnimationTip.showTip(GetLocalizeStringBy("key_1009"))
            return
        end
    end
    local num=0
    local  sum=0

    if(limitType ==1 or limitType == 2 or limitType == 3) then
        num=_curNumber
        sum=0
    elseif(limitType == 4 or limitType == 5) then
        num=_curNumber
        sum = _curNumber
    end
    if( _index ==1) then
        GuildDataCache.addSpecialBuyNumById(_id, sum,num)
    else
        GuildDataCache.addNorBuyNumById(_id, sum,num)
    end
    GuildDataCache.addSigleDonate(-tonumber(_goodsData.costContribution)*_curNumber)
    -- 新增额外消耗扣除
    if (_goodsData.extraCost) then
        local costInfo = _goodsData.extraCost
        costInfo.num = -_curNumber
        ItemUtil.addRewardByTable({costInfo})
    end
    _goodsData.num = _curNumber
    ActiveUtil.showItemGift(_goodsData) 
    GuildShopLayer.refreshMiddleUI()  
    require "script/ui/guild/GuildMainLayer"
    GuildMainLayer.refreshGuildAttr()
end

function buyAction( ... )
	local num = tonumber(_goodsData.costContribution)*_curNumber
	if(GuildDataCache.getSigleDoante()<  num) then
        AnimationTip.showTip( GetLocalizeStringBy("key_2038"))
        return
    end
	-- body
	local args= CCArray:create()
    args:addObject(CCInteger:create(_id))
    args:addObject(CCInteger:create(_curNumber))

    Network.rpc(guildShopBuyCb, "guildshop.buy", "guildshop.buy", args, true)
    closeAction()
     
end


-- create
local function createBg()

	-- 背景
	layerBg = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	layerBg:setContentSize(CCSizeMake(610, 490))
	layerBg:setAnchorPoint(ccp(0.5, 0.5))
	layerBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(layerBg)
	layerBg:setScale(g_fScaleX)	

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(layerBg:getContentSize().width/2, layerBg:getContentSize().height*0.985))
	layerBg:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1745"), g_sFontPangWa, 30)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	layerBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-2412)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(layerBg:getContentSize().width*0.97, layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	buyMenuBar:setTouchPriority(-2412)
	layerBg:addChild(buyMenuBar)

	-- 按钮
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	comfirmBtn:setAnchorPoint(ccp(0, 0))
	comfirmBtn:setPosition(ccp(125, 35	))
	comfirmBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(comfirmBtn, 1, 10001)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0, 0))
	cancelBtn:setPosition(ccp(350, 35))
	cancelBtn:registerScriptTapHandler(closeAction)
	buyMenuBar:addChild(cancelBtn, 1, 10002)

end


-- showPurchaseLayer
function showPurchaseLayer( goods_id, pIndex)
	init()
	_itemType = pIndex
	_id = goods_id
	if(pIndex==1) then
        _goodsData = GuildUtil.getSpcialGooodById(goods_id)
        _buyNum =  _goodsData.baseNum-GuildDataCache.getSpecialBuyNumById(goods_id).sum
    else
        _goodsData = GuildUtil.getNormalGoodById(goods_id)
        _buyNum = _goodsData.personalLimit - GuildDataCache.getNorBuyNumById(goods_id).num
    end

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -2411, true)
	_bgLayer:setTouchEnabled(true)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, 1999)

	-- 创建背景
	createBg()
	-- 创建二级背景
	createInnerBg()
end

