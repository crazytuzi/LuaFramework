-- Filename：	LimitShopLayer.lua
-- Author：		Zhang Zihang
-- Date：		2014-11-24
-- Purpose：		限时商店界面

module("LimitShopLayer", package.seeall)

require "script/ui/rechargeActive/RechargeActiveMain"
require "script/ui/rechargeActive/limitShop/LimitTableView"
require "script/ui/rechargeActive/limitShop/LimitShopService"
require "script/ui/rechargeActive/limitShop/LimitShopData"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MenuLayer"
require "script/utils/BaseUI"

local _bgLayer 				--背景layer
local _remainLabel 			--剩余时间label
local _itemTableView 		--tableView
local _refreshLabel 		--刷新时间label

----------------------------------------初始化函数----------------------------------------
function init()
	_bgLayer = nil
	_remainLabel = nil
	_itemTableView = nil
	_refreshLabel = nil
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:更新时间
--]]
function updateTime()
	--刷新活动倒计时
	_remainLabel:setString(LimitShopData.activeCountDown())
	--刷新时间倒计时
	-- _refreshLabel:setString(LimitShopData.itemCountDown())
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建UI
--]]
function createUI()
	--背景图片
	local bgSprite = CCScale9Sprite:create(CCRectMake(26,30,6,4),"images/recharge/limit_shop/bg.png")
	bgSprite:setPreferredSize(CCSizeMake(g_winSize.width,g_winSize.height))
	_bgLayer:addChild(bgSprite)

	--标题开始位置
	--走马灯栏大小
	local bulletSize = RechargeActiveMain.getTopSize()
	local titlePosY = g_winSize.height - RechargeActiveMain.getBgWidth() - bulletSize.height*g_fScaleX

	--小镁铝和活动标题
	local titleSprite = CCSprite:create("images/recharge/limit_shop/title.png")
	titleSprite:setAnchorPoint(ccp(0.5,1))
	titleSprite:setPosition(ccp(g_winSize.width/2,titlePosY))
	titleSprite:setScale(g_fScaleX)
	bgSprite:addChild(titleSprite)

	--活动时间
	local timePosX = titleSprite:getContentSize().width/2

	local localInfo = {}
	localInfo.localColor = ccc3(0x00,0xe4,0xff)
	localInfo.localFontSize = 21
	localInfo.localLabelType = "strokeLabel"
	localInfo.font = g_sFontName
	local paramTable = {
							{
								ntype = "strokeLabel",
								fontSize = 21,
								text = LimitShopData.getFormatDate(1) .. "-" .. LimitShopData.getFormatDate(2),
								color = ccc3(0x00,0xff,0x18)
							}
					   }
	local timeSprite = GetLocalizeLabelSpriteBy("zzh_1195",localInfo,paramTable)
	timeSprite:setAnchorPoint(ccp(0.5,0))
	timeSprite:setPosition(ccp(timePosX,30))
	titleSprite:addChild(timeSprite)

	--活动剩余时间
	local remainTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1193"),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	remainTimeLabel:setColor(ccc3(0x00,0xe4,0xff))
	_remainLabel = CCRenderLabel:create(LimitShopData.activeCountDown(),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	_remainLabel:setColor(ccc3(0x00,0xff,0x18))

	local remainNode = BaseUI.createHorizontalNode( {remainTimeLabel,_remainLabel} )
	remainNode:setAnchorPoint(ccp(0.5,0))
	remainNode:setPosition(ccp(timePosX,5))
	titleSprite:addChild(remainNode)

	--刷新剩余时间
	-- local refreshTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1197"),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	-- refreshTimeLabel:setColor(ccc3(0x00,0xe4,0xff))
	-- _refreshLabel = CCRenderLabel:create(LimitShopData.itemCountDown(),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	-- _refreshLabel:setColor(ccc3(0x00,0xff,0x18))

	local refreshNode = BaseUI.createHorizontalNode( {refreshTimeLabel,_refreshLabel} )
	refreshNode:setAnchorPoint(ccp(0.5,0))
	refreshNode:setPosition(ccp(timePosX,0))
	titleSprite:addChild(refreshNode)

	--展示框高度
	--菜单栏大小
	local menuSize = MenuLayer.getLayerContentSize()
	local viewPosY = titlePosY - titleSprite:getContentSize().height*g_fScaleX
	local viewHeight = viewPosY - menuSize.height*g_fScaleX - 25*g_fScaleX

	--tableView背景
	local viewBgSprite = CCScale9Sprite:create(CCRectMake(53,57,10,10),"images/recharge/change/zhong_bg1.png")
	viewBgSprite:setPreferredSize(CCSizeMake(g_winSize.width*630/640,viewHeight))
	viewBgSprite:setAnchorPoint(ccp(0.5,1))
	viewBgSprite:setPosition(ccp(g_winSize.width/2,viewPosY))
	bgSprite:addChild(viewBgSprite)

	--tableView背景大小
	local viewBgSize = viewBgSprite:getContentSize()

	--创建tableView
	_itemTableView = LimitTableView.createTableView(viewBgSize)
	_itemTableView:setAnchorPoint(ccp(0,0))
	_itemTableView:setPosition(ccp(0,0))
	viewBgSprite:addChild(_itemTableView)

	schedule(_bgLayer,updateTime,1)
end

----------------------------------------入口函数----------------------------------------
function createLayer()
	init()

	_bgLayer = CCLayer:create()

	-- local serviceCallBack = function()
	-- 	LimitShopService.getLimitShopDay(createUI)
	-- end

	LimitShopService.getLimitShopInfo(createUI)

	return _bgLayer
end