-- Filename：	HeroFragInfoLayer.lua
-- Author：		zhang zihang
-- Date：		2013-11-8
-- Purpose：		好运武魂界面



module ("HeroFragInfoLayer", package.seeall)

require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/shopall/MysteryMerchant/MysteryMerchantDialog"

function init()
	_bgLayer 		= nil
	_mySize			= nil
	_myScale		= nil
	spriteBg 		= nil
	itemInfoSpite   = nil
	heroFragInfo    = {}
end


local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end

 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -5005, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then

		_bgLayer:unregisterScriptTouchHandler()
	end
end

function scanFrag()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
	require "script/ui/main/MainScene"
	require "script/ui/hero/HeroLayer"
	MainScene.changeLayer(HeroLayer.createLayer({index = HeroLayer.m_indexOfSoul}),"HeroLayer")
    ---------------------------------- added by bzx
    MysteryMerchantDialog.checkAndShow()
    -- 点击进入武魂时
    ----------------------------------
end

function closeCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
    --------------------------------- added by bzx
    MysteryMerchantDialog.checkAndShow()
    -- 点击确定或者关闭时
    ---------------------------------
end

function createBackground()
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	spriteBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
	spriteBg:setContentSize(_mySize)
	spriteBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	spriteBg:setScale(_myScale)
	spriteBg:setAnchorPoint(ccp(0.5,0.5))
	_bgLayer:addChild(spriteBg)

	itemInfoSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    itemInfoSpite:setContentSize(CCSizeMake(spriteBg:getContentSize().width-40,spriteBg:getContentSize().height-220))
    itemInfoSpite:setPosition(ccp(spriteBg:getContentSize().width/2,spriteBg:getContentSize().height/2))
    itemInfoSpite:setAnchorPoint(ccp(0.5,0.5))
    spriteBg:addChild(itemInfoSpite)

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-5006)
    spriteBg:addChild(menu,99)

    local scanFragBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2812"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,2, ccc3(0x00, 0x00, 0x00))
    scanFragBtn:setPosition(ccp(spriteBg:getContentSize().width*0.5-180,25))
    scanFragBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(scanFragBtn)
    --local scanFragLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2812"), g_sFontPangWa,35,2,ccc3(0x00,0x00,0x00),type_stroke)
    --scanFragLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    --local width = (scanFragBtn:getContentSize().width - scanFragLabel:getContentSize().width)/2
    --scanFragLabel:setPosition(width,58)
    --scanFragBtn:addChild(scanFragLabel)
    scanFragBtn:registerScriptTapHandler(scanFrag)
    
    require "script/guide/NewGuide"
    --require "script/switch/SwitchOpen"
	if(NewGuide.guideClass ~= ksGuideClose) then
		scanFragBtn:setEnabled(false)
	end


    local okBtn = CCMenuItemImage:create("images/common/btn/btn_green_n.png", "images/common/btn/btn_green_h.png")
    okBtn:setPosition(ccp(spriteBg:getContentSize().width*0.5+180,25))
    okBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(okBtn)
    local okLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1465"), g_sFontPangWa,35,2,ccc3(0x00,0x00,0x00),type_stroke)
    okLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (okBtn:getContentSize().width - okLabel:getContentSize().width)/2
    okLabel:setPosition(width,58)
    okBtn:addChild(okLabel)
    okBtn:registerScriptTapHandler(closeCb)

    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(_mySize.width*1.03-10,_mySize.height*1.04))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)
end

function createTitle()
	--好运标题
	local _titileSprite = CCSprite:create("images/common/title_bg.png")
	_titileSprite:setPosition(ccp(spriteBg:getContentSize().width/2,spriteBg:getContentSize().height-10))
	_titileSprite:setAnchorPoint(ccp(0.5,0.5))
	spriteBg:addChild(_titileSprite)

	local _goodluck = CCSprite:create("images/common/luck.png")
	_goodluck:setPosition(ccp(spriteBg:getContentSize().width/2,spriteBg:getContentSize().height-10))
	_goodluck:setAnchorPoint(ccp(0.5,0.5))
	spriteBg:addChild(_goodluck)

	--武将名称
	local explainLabel1 = CCRenderLabel:create(GetLocalizeStringBy("key_1682"), g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_shadow)
	explainLabel1:setPosition(ccp(spriteBg:getContentSize().width/2-100, spriteBg:getContentSize().height-80))
	explainLabel1:setColor(ccc3(0xff,0xf0,0x00))
	explainLabel1:setAnchorPoint(ccp(0.5,0.5))
	spriteBg:addChild(explainLabel1)
	
	local heroFragName = heroFragInfo.name
	local explainLabel2 = CCRenderLabel:create(heroFragName, g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_shadow)
	explainLabel2:setPosition(ccp(spriteBg:getContentSize().width/2+20, spriteBg:getContentSize().height-80))

	--武将品质
	local heroQuality = heroFragInfo.quality
	explainLabel2:setColor(HeroPublicLua.getCCColorByStarLevel(heroQuality))
	explainLabel2:setAnchorPoint(ccp(0,0.5))
	spriteBg:addChild(explainLabel2)
end

function createItemInfo(fragInhandNum,fragNeedNum)
	heroid = heroFragInfo.aimItem
	require "script/model/utils/HeroUtil"
	local heroImage = HeroUtil.getHeroIconByHTID(heroid)
	heroImage:setPosition(ccp(itemInfoSpite:getContentSize().width/2, itemInfoSpite:getContentSize().height-65))
	heroImage:setAnchorPoint(ccp(0.5,0.5))
	itemInfoSpite:addChild(heroImage)

	local explainLabel3 = CCLabelTTF:create(GetLocalizeStringBy("key_2770"), g_sFontPangWa , 24)
	explainLabel3:setPosition(ccp(itemInfoSpite:getContentSize().width/2-85, itemInfoSpite:getContentSize().height-155))
	explainLabel3:setColor(ccc3(0xff,0xf0,0x00))
	explainLabel3:setAnchorPoint(ccp(0.5,0))
	itemInfoSpite:addChild(explainLabel3)

	local heroFragName = heroFragInfo.name
	local explainLabel2 = CCLabelTTF:create(heroFragName, g_sFontPangWa , 33)
	explainLabel2:setPosition(ccp(itemInfoSpite:getContentSize().width/2-30, itemInfoSpite:getContentSize().height-155))
	
	--武将品质
	local heroQuality = heroFragInfo.quality
	explainLabel2:setColor(HeroPublicLua.getCCColorByStarLevel(heroQuality))
	explainLabel2:setAnchorPoint(ccp(0,0))
	itemInfoSpite:addChild(explainLabel2)

	local explainLabel4 = CCLabelTTF:create(GetLocalizeStringBy("key_1686"), g_sFontPangWa , 24)
	explainLabel4:setPosition(ccp(itemInfoSpite:getContentSize().width/2, itemInfoSpite:getContentSize().height-190))
	explainLabel4:setColor(ccc3(0xff,0xf0,0x00))
	explainLabel4:setAnchorPoint(ccp(0.5,0))
	itemInfoSpite:addChild(explainLabel4)

	local flower = CCSprite:create("images/copy/herofrag/cutFlower.png")
	flower:setPosition(ccp(itemInfoSpite:getContentSize().width/2, itemInfoSpite:getContentSize().height-240))
	flower:setAnchorPoint(ccp(0.5,0.5))
	itemInfoSpite:addChild(flower)

	local shortcut = CCRenderLabel:create(GetLocalizeStringBy("key_2371"), g_sFontPangWa,30,2,ccc3(0xff,0xff,0xff),type_shadow)
	shortcut:setPosition(ccp(itemInfoSpite:getContentSize().width/2, itemInfoSpite:getContentSize().height-240))
	shortcut:setColor(ccc3(0x78,0x25,0x00))
	shortcut:setAnchorPoint(ccp(0.5,0.5))
	itemInfoSpite:addChild(shortcut)

	local heroShortcut = CCLabelTTF:create(heroFragInfo.desc, g_sFontName , 24)
	heroShortcut:setPosition(ccp(itemInfoSpite:getContentSize().width/2, itemInfoSpite:getContentSize().height-300))
	heroShortcut:setColor(ccc3(0xff,0xff,0xff))
	heroShortcut:setAnchorPoint(ccp(0.5,0.5))
	itemInfoSpite:addChild(heroShortcut)

	local flower2 = CCSprite:create("images/copy/herofrag/cutFlower.png")
	flower2:setPosition(ccp(itemInfoSpite:getContentSize().width/2, 130))
	flower2:setAnchorPoint(ccp(0.5,0.5))
	itemInfoSpite:addChild(flower2)

	local shortcut2 = CCRenderLabel:create(GetLocalizeStringBy("key_3222"), g_sFontPangWa,30,2,ccc3(0xff,0xff,0xff),type_shadow)
	shortcut2:setPosition(ccp(itemInfoSpite:getContentSize().width/2, 130))
	shortcut2:setColor(ccc3(0x78,0x25,0x00))
	shortcut2:setAnchorPoint(ccp(0.5,0.5))
	itemInfoSpite:addChild(shortcut2)

	local explainLabel5 = CCLabelTTF:create(GetLocalizeStringBy("key_2569") .. fragInhandNum .. "/" .. fragNeedNum, g_sFontPangWa , 24)
	explainLabel5:setPosition(ccp(itemInfoSpite:getContentSize().width/2, 65))
	explainLabel5:setColor(ccc3(0xff,0xf0,0x00))
	explainLabel5:setAnchorPoint(ccp(0.5,0.5))
	itemInfoSpite:addChild(explainLabel5)
end

-- 创建
function createLayer(item_template_id, item_num)

	init()

	--if item_num == 0 then 
	--	item_num = 1
	--end

	require "script/model/hero/HeroModel"

	local fragNumInfo = {}
	fragNumInfo = HeroModel.getNumByItemTemplateId(item_template_id)

	local fragInhandNum = fragNumInfo.item_num

	local fragNeedNum = fragNumInfo.need_num

	heroFragInfo = ItemUtil.getItemById(item_template_id)

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	require "script/ui/main/MainScene"
    _myScale = MainScene.elementScale
	_mySize = CCSizeMake(640,800)

	createBackground()

	createTitle()

	createItemInfo(fragInhandNum,fragNeedNum)

	return _bgLayer;

end
