-- Filename: CCMenuLayer.lua.
-- Author: zhz.
-- Date: 2013-09-09
-- Purpose: 该文件用于菜单

module ("CCMenuLayer", package.seeall)

require "script/ui/main/MenuLayer"
require "script/ui/main/MainScene"
require "script/audio/AudioUtil"

local _bgLayer 		            	--
local _titileSprite 				-- 标题sprite
local _cellInterval 	= 18
local _cellHeight 		= 124
local _ksBGMusicTag 	= 1001
local _ksSoundTag 		= 1002
local _ksRewardTag 		= 1003
local _ks91Tag 			= 1004
local _ksHeroShowTag 	= 1005			-- 武将图鉴
local _ksLogout 		= 1006 			-- 登出
local _ksExitGame 		= 1007			-- 退出游戏
local _ksGiftTag 		= 20001			-- 每日分享奖励
local _ksWeiBoTag		= 20002			-- 绑定微博
local _ksGetRewardRecord = 1008			-- 领奖记录
local _ksNotificationTag = 1009         -- 推动设置
local _ksWebActivityTag 	= 1010			-- 打开web端网页活动

local _ksNoticeTag= 10006

local _menuArray = {
					{ name = "",nameSp = "images/menu/share.png", images_n = "images/menu/gift_n.png", images_h = "images/menu/gift_h.png",type =2 , desc = "",tag = _ksGiftTag},
		 			{ name = GetLocalizeStringBy("key_2111"), images_open_n = "images/menu/sound_n.png", images_open_h = "images/menu/sound_h.png",  images_close_n = "images/menu/sclience_n.png", images_close_h = "images/menu/sclience_h.png",type =1 , tag = _ksBGMusicTag} ,
		 			{ name = GetLocalizeStringBy("key_1590"),images_open_n = "images/menu/sound_n.png", images_open_h = "images/menu/sound_h.png",  images_close_n = "images/menu/sclience_n.png", images_close_h = "images/menu/sclience_h.png", type = 1 , tag = _ksSoundTag},
		 			{name =GetLocalizeStringBy("yr_8000"),images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png" , desc = GetLocalizeStringBy("key_1272"), type = 2, tag = _ksNotificationTag },
		 			{name =GetLocalizeStringBy("key_2820"),images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png" , desc = GetLocalizeStringBy("key_1272"), type = 2, tag = _ksHeroShowTag },
		 			{name =GetLocalizeStringBy("cl_1023"),images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png" , desc = GetLocalizeStringBy("key_1272"), type = 2, tag = _ksWebActivityTag },
		 			{name =GetLocalizeStringBy("key_2171"),images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png" , desc = GetLocalizeStringBy("key_1272"), type = 2, tag = _ksNoticeTag },
		 			{name =GetLocalizeStringBy("key_2638"),images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png" , desc = GetLocalizeStringBy("key_2689"), type = 2, tag = _ksRewardTag },
		 			{name =GetLocalizeStringBy("llp_221"),images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png" , desc = GetLocalizeStringBy("key_1272"), type = 2, tag = _ksGetRewardRecord },
		 			{name = Platform.getPlatformName() ,images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png" ,desc = GetLocalizeStringBy("key_1831") , type = 2 , tag = _ks91Tag },
		 			{name =GetLocalizeStringBy("cl_1002"),images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png" , desc = GetLocalizeStringBy("cl_1004"), type = 2, tag = _ksLogout },
		 			-- {name =GetLocalizeStringBy("cl_1003"),images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png" , desc = GetLocalizeStringBy("cl_1005"), type = 2, tag = _ksExitGame },
		 	--		{ name = "",nameSp = "images/menu/weipo.png", images_n = "images/common/btn/btn_blue_n.png", images_h = "images/common/btn/btn_blue_h.png",type =3 , desc = GetLocalizeStringBy("key_3258"),tag = _ksWeiBoTag},
				}


-- 创建菜单标题
local function createTitle( )
	require "script/ui/main/BulletinLayer"
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local averSize = MainScene.getAvatarLayerContentSize()
	local height =  g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height+averSize.height)*g_fScaleX +10*g_fScaleX

	_titileSprite = CCSprite:create("images/common/title_bg.png")
	_titileSprite:setScale(g_fScaleX/g_fElementScaleRatio)
	_titileSprite:setPosition(ccp(0,height))
	_titileSprite:setAnchorPoint(ccp(0,1))
	_bgLayer:addChild(_titileSprite)

	-- 文字 菜单
	local menuLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_3390"), g_sFontPangWa, 33, 1,ccc3(0x00,0x00,0x00), type_stroke)
	menuLabel:setColor(ccc3(0xff,0xe4,0x00))
	menuLabel:setPosition(ccp(_titileSprite:getContentSize().width*0.5,_titileSprite:getContentSize().height*0.5+3))
	menuLabel:setAnchorPoint(ccp(0.5,0.5))
	_titileSprite:addChild(menuLabel)
end

-- 创建用于scrowViw 的list
function createMenuList(  )
	local listView = CCScrollView:create()
	listView:setContentSize(CCSizeMake(_bgLayer:getContentSize().width,(_cellInterval+_cellHeight)*(#_menuArray))) --_bgLayer:getContentSize().height -_titileSprite:getContentSize().height*g_fScaleX))
	listView:setViewSize(CCSizeMake(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height -_titileSprite:getContentSize().height*g_fScaleX))
    listView:setScale(1/MainScene.elementScale)
	-- 设置弹性属性
	listView:setBounceable(true)
	listView:setTouchPriority(-130)
	listView:setDirection(kCCScrollViewDirectionVertical)
	listView:setPosition(ccp(0,0))
	_bgLayer:addChild(listView)

	-- 创建显示内容layer Container
	local layer = CCLayer:create()
	layer:setContentSize(CCSizeMake(listView:getViewSize().width,(_cellInterval+_cellHeight)*(#_menuArray+1) *g_fScaleX))
	listView:setContainer(layer)
	layer:setPosition(ccp(0,0))
	-- 默认显示最上方(设置偏移值)
	listView:setContentOffset(ccp(0,listView:getViewSize().height-layer:getContentSize().height))

	-- 获取系统平台
	local platformName = BTUtil:getPlatform()
	-- 需要屏蔽的
	for k,v in pairs(_menuArray) do
		if Platform.isAdShow == true  then
			-- 礼包码兑换，需要屏蔽
			if _menuArray[k].tag == _ksRewardTag then
				table.remove(_menuArray, k)
			end
		end
		-- 应策划要求  暂时先不显示 等以后热更新时才打开 TODO
		if( v.tag == _ksNotificationTag )then
			if( platformName == kBT_PLATFORM_WP8 or NotificationUtil.isSupportPackage()==false )then
				-- wp没有推送不创建
				table.remove(_menuArray, k)
			end
		end
		if(v.tag == _ksWebActivityTag)then
			if(MainScene.getWebActivityUrl() == nil)then
				-- web端的运营活动没开启
				table.remove(_menuArray, k)
			end
		end
	end
	-- _menuArray[#_menuArray].name = Platform.getPlatformName()
	for i,itemInfo in ipairs(_menuArray) do
		local whiteSpite = CCScale9Sprite:create( "images/menu/white_bottom.png")
		whiteSpite:setContentSize(CCSizeMake(543,125))
		whiteSpite:setPosition(ccp(layer:getContentSize().width*0.5, layer:getContentSize().height-(_cellHeight+ _cellInterval)*i*g_fScaleX))
		whiteSpite:setAnchorPoint(ccp(0.5,0))
		whiteSpite:setScale(g_fScaleX)
		layer:addChild(whiteSpite)
		local descLabel = CCLabelTTF:create("" .. itemInfo.name, g_sFontPangWa,36)
		descLabel:setPosition(ccp(57/543*whiteSpite:getContentSize().width,whiteSpite:getContentSize().height*0.5))
		descLabel:setAnchorPoint(ccp(0,0.5))
		descLabel:setColor(ccc3(0x78,0x25,0x00))
		whiteSpite:addChild(descLabel)
		-- 创建图片文字，有的可能没有文字，只有图片，像是没事分享奖励
		if(itemInfo.nameSp) then
			createSpriteTxt(itemInfo.nameSp ,whiteSpite)
		end
		-- 按钮
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		whiteSpite:addChild(menu)
		local menuItem = createCellBtn(itemInfo)
		menuItem:setPosition(ccp(whiteSpite:getContentSize().width*0.75,whiteSpite:getContentSize().height*0.5))
		menuItem:setAnchorPoint(ccp(0.5,0.5))
		menu:addChild(menuItem,0, itemInfo.tag)
		menuItem:registerScriptTapHandler(itemCb)
	end
end

-- 创建图片文字，如：每日分享奖励
function createSpriteTxt( imgPath,whiteSpite )
	local txtSprite = CCSprite:create(imgPath)
	txtSprite:setPosition(ccp(0/543*whiteSpite:getContentSize().width,whiteSpite:getContentSize().height*0.5))
	txtSprite:setAnchorPoint(ccp(0,0.5))
	whiteSpite:addChild(txtSprite)
end

function itemCb(tag, item_obj)

	-- print("m_isBgmOpen 2 is : " ,AudioUtil.m_isBgmOpen)
	-- 背景音乐
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == _ksBGMusicTag) then
		local menuItem = tolua.cast(item_obj, "CCMenuItemToggle")
		setBgMusic(menuItem)
	-- 设置音效
	elseif(tag == _ksSoundTag) then
		local menuItem = tolua.cast(item_obj, "CCMenuItemToggle")
		setSoundMusic(menuItem)

	elseif(tag == _ksWebActivityTag)then
		-- web运营活动
		require "script/ui/menu/WebNoticeLayer"
		WebNoticeLayer.show()

	elseif(tag == _ksNotificationTag) then
		
		require "script/ui/menu/NotificationSwitchPanel"
		NotificationSwitchPanel.show()
	elseif(tag == _ksRewardTag ) then
		require "script/ui/reward_code/RewardCodeLayer"
		RewardCodeLayer.createLayer()
	elseif(tag == _ks91Tag ) then
		print("========== 91 cb +=========")
		Platform.enterUserCenter()
	elseif( tag == _ksGetRewardRecord) then
		require "script/ui/rewardCenter/RewardRecordLayer"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		local runScene = CCDirector:sharedDirector():getRunningScene()
		local rewardLayer  = RewardRecordLayer.create()
		runScene:addChild(rewardLayer,1500)
	elseif( tag == _ksHeroShowTag) then
  		require "script/ui/copy/BattleLand"
    	-- local layer = BattleLand.create(_city_id, dictData)
    	-- MainScene.changeLayer(layer, "BattleLand")
		require "script/ui/menu/IllustrateLayer"
		local illustrateLayer = IllustrateLayer.createLayer()
		MainScene.changeLayer(illustrateLayer, "illustrateLayer")
		-- require "script/ui/upgrade_tip/UpgradeLayer"
		-- UpgradeLayer.createLayer()
		-- require "script/ui/active/RivalInfoLayer"
		-- RivalInfoLayer.createLayer(UserModel.getUserUid() )

	--每日分享奖励
	elseif(tag == _ksGiftTag) then

		require "script/utils/BaseUI"
		local shareImagePath = BaseUI.getScreenshots()
		print("shareImagePath = ",shareImagePath)
		--add by zhang zihang
		require "script/ui/share/ShareLayer"
		ShareLayer.show(nil,nil,nil,nil,function ( ... )
			 MainScene.updateAvatarInfo()
		end)
		print(GetLocalizeStringBy("key_2140"))
	-- 绑定微博
	elseif(tag == _ksWeiBoTag) then
		print(GetLocalizeStringBy("key_3258"))
	elseif(tag== _ksNoticeTag) then
		print(GetLocalizeStringBy("key_3261"))
		require "script/ui/main/GameNotice02"
		GameNotice02.showGameNotice()

	elseif(tag == _ksLogout)then
		print("_ksLogout")
		local function confirmCBFunc( ... )
			print("confirmCBFunc")
			Network.closeAllSocket()
			LoginScene.loginAgain(1)
		end
		AlertTip.showAlert( GetLocalizeStringBy("cl_1006"), confirmCBFunc, false, nil, GetLocalizeStringBy("cl_1004"), nil, nil)
	elseif(tag == _ksExitGame)then
		print("_ksExitGame")
		local function confirmCBFunc( ... )
			Platform.quit()
		end
		AlertTip.showAlert( GetLocalizeStringBy("cl_1007"), confirmCBFunc, false, nil, GetLocalizeStringBy("key_3344"), nil, nil)
	end

end

-- 创建ScrowView 上的背景
function createCellBtn( cellValues )
	local menuItem
	if(cellValues.type == 1) then
		local item_open = CCMenuItemImage:create(cellValues.images_open_h,cellValues.images_open_n)
		item_open:setAnchorPoint(ccp(0.5,0.5))
		local item_close = CCMenuItemImage:create(cellValues.images_close_h, cellValues.images_open_n)
		item_close:setAnchorPoint(ccp(0.5,0.5))
		menuItem = CCMenuItemToggle:create(item_open)
		menuItem:addSubItem(item_close)
		-- 判断音效按钮开启状态
		setItemStatus(menuItem,cellValues.tag)
	elseif(cellValues.type == 2) then
		menuItem = CCMenuItemImage:create(cellValues.images_n,cellValues.images_h)
		local BtnName =  CCRenderLabel:create("" .. cellValues.desc , g_sFontPangWa, 30, 2 ,ccc3(0x00,0x00,0x00), type_stroke)
		BtnName:setColor(ccc3(0xfe,0xdb,0x1c))
		BtnName:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
		BtnName:setAnchorPoint(ccp(0.5,0.5))
		menuItem:addChild(BtnName)
	elseif(cellValues.type==3) then
		local image_n = cellValues.images_n
		local image_h = cellValues.images_h
		local rect_full_n 	= CCRectMake(0,0,164,64)
		local rect_inset_n 	= CCRectMake(25,20,13,3)
		local rect_full_h 	= CCRectMake(0,0,164,64)
		local rect_inset_h 	= CCRectMake(35,25,3,3)
		local btn_size_n	= CCSizeMake(164, 64)
		local btn_size_h	= CCSizeMake(164, 64)

		local text_color_n	= ccc3(0xfe, 0xdb, 0x1c)
		local text_color_h	= ccc3(0xfe, 0xdb, 0x1c)
		local font			= g_sFontName
		local font_size		= 30
		local strokeCor_n	= ccc3(0x00,0x00,0x00)
		local strokeCor_h	= ccc3(0x00,0x00,0x00)
		local stroke_size	= 1
		-- menuItem


		local btnSize =  CCSizeMake(164,64)
		local normalReceiveSprite = CCScale9Sprite:create(cellValues.images_n)
		normalReceiveSprite:setContentSize(btnSize)
		local normalLabel = CCRenderLabel:create("" .. cellValues.desc, g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
		normalLabel:setColor(ccc3(0xfe,0xdb,0x1c))
		normalLabel:setPosition(ccp(btnSize.width*0.5,btnSize.height*0.5))
		normalLabel:setAnchorPoint(ccp(0.5,0.5))
		normalReceiveSprite:addChild(normalLabel,0,101)
		-- selectedSprite,
		local selectReceiveSprite = CCScale9Sprite:create(cellValues.images_h)
		selectReceiveSprite:setContentSize(btnSize)
		local selectLabel = CCRenderLabel:create(""..cellValues.desc, g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
		selectLabel:setColor(ccc3(0xfe,0xdb,0x1c))
		selectLabel:setPosition(ccp(btnSize.width*0.5,btnSize.height*0.5))
		selectLabel:setAnchorPoint(ccp(0.5,0.5))
		selectReceiveSprite:addChild(selectLabel,0,101)
		menuItem =CCMenuItemSprite:create(normalReceiveSprite, selectReceiveSprite)


	end
	return menuItem
end
-- 设置背景音乐
function setBgMusic( item_obj)
	local selectIndex = item_obj:getSelectedIndex()
	if(selectIndex == 0) then
		print("m_isBgmOpen 3 is : " ,AudioUtil.m_isBgmOpen)
		AudioUtil.openBgm()
	--	AudioUtil.playMainBgm()
		print("m_isBgmOpen 4 is : " ,AudioUtil.m_isBgmOpen)
	elseif(selectIndex == 1) then
		AudioUtil.muteBgm()
		print("m_isBgmOpen 5 is : " ,AudioUtil.m_isBgmOpen)
	end
end

-- 设置音效音乐
function setSoundMusic(item_obj )
	local selectIndex = item_obj:getSelectedIndex()
	if(selectIndex == 0) then
		AudioUtil.openSoundEffect()
		--AudioUtil.playEffect(effect,isLoop)
	else
		AudioUtil.muteSoundEffect()
	end
end

-- 判断音效按钮的状态
function setItemStatus( menuItem ,tag)
	--AudioUtil.initAudioInfo()
	if(AudioUtil.m_isBgmOpen == false and tag == _ksBGMusicTag) then
		menuItem:setSelectedIndex(1)
	end
	if(AudioUtil.m_isSoundEffectOpen == false and tag == _ksSoundTag ) then
		menuItem:setSelectedIndex(1)
	end


end

-- 创建界面的背景
local function createBackground(  )
	local spriteBg = CCScale9Sprite:create("images/common/bg/bg_ng.png")
	spriteBg:setContentSize(CCSizeMake(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height))
	spriteBg:setPosition(_bgLayer:getContentSize().width*0.5,0)
	spriteBg:setScale(1/MainScene.elementScale)
	spriteBg:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(spriteBg)
end

function createMenuLayer( )
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, true, true)
	createBackground()
	createTitle()
	createMenuList()


	return _bgLayer
end
