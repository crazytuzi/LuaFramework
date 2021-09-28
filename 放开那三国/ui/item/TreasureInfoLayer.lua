-- FileName: TreasureInfoLayer.lua 
-- Author: licong 
-- Date: 15/6/15 
-- Purpose: 宝物信息界面

require "script/ui/item/ItemUtil"
require "script/ui/treasure/TreasureUtil"
require "script/model/utils/HeroUtil"
require "script/ui/treasure/develop/TreasureDevelopData"
require "script/ui/bag/RuneData"
require "script/ui/treasure/TreasureData"

TreasureInfoLayer = class("TreasureInfoLayer",function ()
	return CCLayer:create()
end)

TreasInfoType = {
	BASE_TYPE 							= 101 ,		-- 显示type1 tid  	  无按钮
	BAG_TYPE 							= 102 ,		-- 显示type2 item_id  在背包 精炼 强化 
	FORMATION_TYPE 						= 103 ,		-- 显示type3 item_id  在阵容 更换 卸下 强化 精炼 
	OTHER_FORMATION_TYPE 				= 104 ,		-- 显示type4 item_id  在对方阵容无按钮
	CONFIRM_TYPE 						= 105 ,		-- 显示type5 tid  	  确定按钮
	ROB_TYPE 							= 106 ,		-- 显示type6 tid  	  前往夺宝

}

-- TreasInfoType.BASE_TYPE
-- TreasInfoType.BAG_TYPE
-- TreasInfoType.FORMATION_TYPE
-- TreasInfoType.OTHER_FORMATION_TYPE
-- TreasInfoType.CONFIRM_TYPE
-- TreasInfoType.ROB_TYPE

-- for 新手引导
local comfirmBtn = nil


function TreasureInfoLayer:ctor( ... )
	self._touchPrority 			= -434 		-- layer默认优先级
	self._zOrder 				= 1010 		-- layer默认Z轴

	self._bgSprite       		= nil 		-- 背景
	self._topSprite   			= nil 		-- 宝物标题背景
	self._bottomBg				= nil 		-- 宝物按钮背景
	self._title 				= nil 		-- 标题
	self._jinglianBtn 			= nil 		-- 精炼按钮
	self._qianghuaBtn 			= nil 		-- 强化按钮
	self._changeBtn 			= nil 		-- 更换按钮
	self._removeBtn 			= nil 		-- 卸下按钮

	self._colseMenu 			= nil 		-- 关闭按钮
	self._bottoMenu 			= nil 		-- 底部按钮
	self._developMenu 			= nil       -- 进阶按钮
	self._scrollView 			= nil 		-- scrollview

	self._iconBg 				= nil 		-- 宝物形象
	self._runeBg				= nil 		-- 符印背景
	self._curAttrBg 			= nil 		-- 当前属性背景
	self._lockBg 				= nil 		-- 解锁属性背景
	self._redLockBg 			= nil  	    -- 红色解锁属性背景
	self._jinglianBg 			= nil 		-- 精炼属性背景
	self._jibanBg 				= nil 		-- 羁绊背景
	self._jianjieBg 			= nil 		-- 简介背景	
	self._runeSpriteArr 		= nil   	-- 符印图标

	self._itemInfo 				= nil 		-- 宝物数据
	self._curAttrTab 			= nil 		-- 当前属性数据
	self._lockAttrTab 			= nil 		-- 解锁属性数据
	self._redLockAttrTab        = nil 		-- 红色解锁属性
	self._jinglianAttrTab 		= nil 		-- 精炼属性数据
	self._jibanDataTab			= nil 		-- 羁绊数据   

	self._showType       		= nil 	    -- 显示类型
	self._isCanJinglian 		= false 	-- 是否可以精炼
	self._isShowJinglianBtn 	= false 	-- 是否显示精炼按钮
	self._isCanDevelop  		= false 	-- 是否可以进阶
	self._isShowDevelopBtn 		= false 	-- 是否显示进阶按钮
	self._isShowRuneBg			= false     -- 是否显示符印背景
	self._isShowLockBg 			= false     -- 是否显示解锁属性背景
	self._isShowJinglianBg		= false 	-- 是否显示精炼属性背景
	self._isShowJibanBg 		= false 	-- 是否显示羁绊背景
	self._isCanQianghua 		= false 	-- 是否可以强化
	self._isShowQianghuaBtn 	= false 	-- 是否显示强化按钮
	self._isShowRedLockBg 		= false 	-- 是否显示红色解锁属性

	self._registerCallBack 		= nil 		-- 关闭回调
end

--[[
	@des:创建信息面板
	@parm:p_tid 	物品模板id
--]]
function TreasureInfoLayer:createWithTid( p_tid, p_showType )
	local infoLayer = TreasureInfoLayer:new()
	infoLayer:initWithTid( p_tid, p_showType )
	return infoLayer
end

--[[
	@des:创建信息面板
	@parm:p_itemId 	物品item_id
--]]
function TreasureInfoLayer:createWithItemId( p_itemId, p_showType )
	local infoLayer = TreasureInfoLayer:new()
	infoLayer:initWithItemId( p_itemId, p_showType )
	return infoLayer
end

--[[
	@des:初始化信息面板
	@parm:p_tid 	物品模板id
--]]
function TreasureInfoLayer:initWithTid( p_tid, p_showType )
	-- 显示类型
	self._showType = p_showType or TreasInfoType.BASE_TYPE

	-- 处理宝物数据
	self:initDataWithTid(p_tid)
	
	-- 初始化背景
 	self:initBg()

 	-- 初始化ScrollView
 	self:initShowView()
end

--[[
	@des:初始化信息面板
	@parm:p_itemId 	物品模板id
--]]
function TreasureInfoLayer:initWithItemId( p_itemId, p_showType )
	-- 显示类型
	self._showType = p_showType or TreasInfoType.BASE_TYPE

	-- 处理宝物数据
	self:initDataWithItemId(p_itemId)
	
	-- 初始化背景
 	self:initBg()

 	-- 初始化ScrollView
 	self:initShowView()
end

--[[
	@des:显示信息面板
	@parm:p_touchPrority 	优先级
	@parm:p_zOrder 			zOrder
--]]
function TreasureInfoLayer:show(p_touchPrority, p_zOrder)
	self._touchPrority  = p_touchPrority or -434
	print("show",self._touchPrority)
	self._zOrder = p_zOrder or 1010

	-- 重新设置优先级
	self._colseMenu:setTouchPriority(self._touchPrority-4)
	self._bottoMenu:setTouchPriority(self._touchPrority-4)
	if( self._isShowDevelopBtn )then 
		self._developMenu:setTouchPriority(self._touchPrority-2)
	end
	self._scrollView:setTouchPriority(self._touchPrority-3)

	if(not table.isEmpty(self._runeSpriteArr) )then
		for k,v in pairs(self._runeSpriteArr) do
			local menu = tolua.cast(v:getChildByTag(100),"BTSensitiveMenu")
			menu:setTouchPriority(self._touchPrority-2)
		end
	end

	-- 设置layer
	self:setTouchEnabled(true)

	self:registerScriptTouchHandler(function ( eventType,x,y )
		if(eventType == "began") then
			return true
		end
	end,false, self._touchPrority, true)

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(self, self._zOrder)
end

--[[
	@des:创建背景
--]]
function TreasureInfoLayer:initBg()
	-- 公告栏大小
	require "script/ui/main/BulletinLayer"
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()

	-- 背景
	local nWidth = self:getContentSize().width
	local nHeight = self:getContentSize().height - bulletinLayerSize.height*g_fScaleX
	self._bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	self._bgSprite:setContentSize(CCSizeMake(nWidth/g_fScaleX, nHeight/g_fScaleX))
	self._bgSprite:setAnchorPoint(ccp(0.5, 1))
	self._bgSprite:setPosition(ccp(self:getContentSize().width*0.5, nHeight))
	self:addChild(self._bgSprite)
	self._bgSprite:setScale(g_fScaleX)

	-- 标题背景
	self._topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	self._topSprite:setAnchorPoint(ccp(0.5, 1))
	self._topSprite:setPosition(ccp(self._bgSprite:getContentSize().width*0.5, self._bgSprite:getContentSize().height))
	self._bgSprite:addChild(self._topSprite,10)

	-- 标题 宝物信息
	self._title = CCRenderLabel:create(GetLocalizeStringBy("key_2072"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    self._title:setColor(ccc3(0xff, 0xf6, 0x00))
    self._title:setAnchorPoint(ccp(0.5,0.5))
    self._title:setPosition(ccp(self._topSprite:getContentSize().width*0.5,self._topSprite:getContentSize().height*0.5))
    self._topSprite:addChild(self._title)

    -- 关闭按钮
    self._colseMenu =  CCMenu:create()
	self._colseMenu:setPosition(ccp(0, 0))
	self._topSprite:addChild(self._colseMenu)
	self._colseMenu:setTouchPriority(self._touchPrority-4)

	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(self._topSprite:getContentSize().width*1.01, self._topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(function ( ... )
    	AudioUtil.playEffect("audio/effect/guanbi.mp3")
    	self:closeLayer()
    	-- 回调
		if(self._registerCallBack)then 
			self._registerCallBack()
		end
    end)
	self._colseMenu:addChild(closeBtn)

	-- 底部背景
	self._bottomBg = CCSprite:create("images/common/sell_bottom.png")
	self._bottomBg:setAnchorPoint(ccp(0.5,0))
	self._bottomBg:setPosition(ccp(self._bgSprite:getContentSize().width*0.5,0))
	self._bgSprite:addChild(self._bottomBg,10)

	-- 底部按钮
    self._bottoMenu =  CCMenu:create()
	self._bottoMenu:setPosition(ccp(0, 0))
	self._bottomBg:addChild(self._bottoMenu)
	self._bottoMenu:setTouchPriority(self._touchPrority-4)

	-- 按钮字体大小
	--兼容东南亚英文版
	local fontSize = 35
 	if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 		fontSize = 25
 	end
	-- 精炼按钮
	self._jinglianBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3227"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	self._jinglianBtn:setAnchorPoint(ccp(0.5, 0.5))
	self._bottoMenu:addChild(self._jinglianBtn)
	local jinglianCallBack = function ( ... )
		-- 精炼回调
		self:jinglianBtnCallBack()
	end
	self._jinglianBtn:registerScriptTapHandler(jinglianCallBack)
	self._jinglianBtn:setVisible(false)

	-- 强化按钮
	self._qianghuaBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3391"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	self._qianghuaBtn:setAnchorPoint(ccp(0.5, 0.5))
	self._bottoMenu:addChild(self._qianghuaBtn)
	local qianghuaCallBack = function ( ... )
		-- 强化回调
		self:qianghuaBtnCallBack()
	end
	self._qianghuaBtn:registerScriptTapHandler(qianghuaCallBack)
	self._qianghuaBtn:setVisible(false)

	-- 更换按钮
	self._changeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_1543"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	self._changeBtn:setAnchorPoint(ccp(0.5, 0.5))
	self._bottoMenu:addChild(self._changeBtn)
	local changeCallBack = function ( ... )
		-- 更换回调
		self:changeBtnCallBack()
	end
	self._changeBtn:registerScriptTapHandler(changeCallBack)
	self._changeBtn:setVisible(false)

	-- 卸下按钮
	self._removeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2933"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	self._removeBtn:setAnchorPoint(ccp(0.5, 0.5))
	self._bottoMenu:addChild(self._removeBtn)
	local removeCallBack = function ( ... )
		-- 卸下回调
		self:removeBtnCallBack()
	end
	self._removeBtn:registerScriptTapHandler(removeCallBack)
	self._removeBtn:setVisible(false)

	-- 按钮位置
	if(self._showType == TreasInfoType.BAG_TYPE)then 
		-- 精炼 强化 
		if(self._isCanQianghua)then
			self._qianghuaBtn:setVisible(true)
		end
		if(self._isShowJinglianBtn)then 
			self._jinglianBtn:setVisible(true)
			self._jinglianBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.25, self._bottomBg:getContentSize().height*0.5))
			self._qianghuaBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.75, self._bottomBg:getContentSize().height*0.5))
		else
			self._qianghuaBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.5, self._bottomBg:getContentSize().height*0.5))
		end

	elseif(self._showType == TreasInfoType.FORMATION_TYPE)then 
		-- 更换 卸下 强化 精炼  
		if(self._isCanQianghua)then
			self._qianghuaBtn:setVisible(true)
		end
		self._changeBtn:setVisible(true)
		self._removeBtn:setVisible(true)
		if(self._isShowJinglianBtn)then 
			self._jinglianBtn:setVisible(true)
			self._changeBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.15, self._bottomBg:getContentSize().height*0.5))
			self._removeBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.38, self._bottomBg:getContentSize().height*0.5))
			self._jinglianBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.615, self._bottomBg:getContentSize().height*0.5))
			self._qianghuaBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.85, self._bottomBg:getContentSize().height*0.5))
		else
			self._changeBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.2, self._bottomBg:getContentSize().height*0.5))
			self._removeBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.5, self._bottomBg:getContentSize().height*0.5))
			self._qianghuaBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.8, self._bottomBg:getContentSize().height*0.5))
		end
	elseif(self._showType == TreasInfoType.CONFIRM_TYPE)then 
		-- 确定按钮
		local yesBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		yesBtn:setAnchorPoint(ccp(0.5, 0.5))
		self._bottoMenu:addChild(yesBtn)
		local yesCallBack = function ( ... )
			-- 确定回调
			self:yesBtnCallBack()
		end
		yesBtn:registerScriptTapHandler(yesCallBack)
		yesBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.5, self._bottomBg:getContentSize().height*0.5))
		comfirmBtn = yesBtn
	elseif(self._showType == TreasInfoType.ROB_TYPE)then 
		-- 前往夺宝按钮
		local robBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_2988"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		robBtn:setAnchorPoint(ccp(0.5, 0.5))
		self._bottoMenu:addChild(robBtn)
		local robCallBack = function ( ... )
			-- 前往夺宝回调
			self:robBtnCallBack()
		end
		robBtn:registerScriptTapHandler(robCallBack)
		robBtn:setPosition(ccp(self._bottomBg:getContentSize().width*0.5, self._bottomBg:getContentSize().height*0.5))
	else
		-- 无按钮
		print("NO Btn !!")
	end
end

--[[
	@des:创建ScrollView
--]]
function TreasureInfoLayer:initShowView()

	-- ScrollView
	self._scrollView = CCScrollView:create()
	self._scrollView:setTouchPriority(self._touchPrority-3)
	local scrollViewHeight = self._bgSprite:getContentSize().height - self._topSprite:getContentSize().height - self._bottomBg:getContentSize().height
	self._scrollView:setViewSize(CCSizeMake(self._bgSprite:getContentSize().width, scrollViewHeight))
	self._scrollView:setDirection(kCCScrollViewDirectionVertical)

	local contentLayer = CCLayer:create()

	-- 计算高度
	local contentHeight = 0
	-- 大卡牌
	self._iconBg = self:getIconBgSprite()
	self._iconBg:setAnchorPoint(ccp(0.5,1))
	contentLayer:addChild(self._iconBg)
	contentHeight = contentHeight + self._iconBg:getContentSize().height + 15

	-- 兵书符印
	if( self._isShowRuneBg )then 
		self._runeBg = self:getRunBgSprite()
		self._runeBg:setAnchorPoint(ccp(0.5,1))
		contentLayer:addChild(self._runeBg)
		contentHeight = contentHeight + self._runeBg:getContentSize().height + 30
	end

	-- 当前属性
	self._curAttrBg = self:getCurAttrBgSprite()
	self._curAttrBg:setAnchorPoint(ccp(0.5,1))
	contentLayer:addChild(self._curAttrBg)
	contentHeight = contentHeight + self._curAttrBg:getContentSize().height + 30

	-- 精炼属性
	if( self._isShowJinglianBg )then 
		self._jinglianBg = self:getJinglianAttrBgSprite()
		self._jinglianBg:setAnchorPoint(ccp(0.5,1))
		contentLayer:addChild(self._jinglianBg)
		contentHeight = contentHeight + self._jinglianBg:getContentSize().height + 30
	end

	-- 解锁属性
	if( self._isShowLockBg )then 
		self._lockBg = self:getLockAttrBgSprite( self._lockAttrTab,GetLocalizeStringBy("key_1422") )
		self._lockBg:setAnchorPoint(ccp(0.5,1))
		contentLayer:addChild(self._lockBg)
		contentHeight = contentHeight + self._lockBg:getContentSize().height + 30
	end

	-- 红色解锁属性
	if( self._isShowRedLockBg )then 
		self._redLockBg = self:getLockAttrBgSprite( self._redLockAttrTab,GetLocalizeStringBy("lic_1846") )
		self._redLockBg:setAnchorPoint(ccp(0.5,1))
		contentLayer:addChild(self._redLockBg)
		contentHeight = contentHeight + self._redLockBg:getContentSize().height + 30
	end

	-- 宝物羁绊
	if( self._isShowJibanBg )then 
		self._jibanBg = self:getJibanBgSprite()
		self._jibanBg:setAnchorPoint(ccp(0.5,1))
		contentLayer:addChild(self._jibanBg)
		contentHeight = contentHeight + self._jibanBg:getContentSize().height + 30
	end

	-- 简介
	self._jianjieBg = self:getJianjieBgSprite()
	self._jianjieBg:setAnchorPoint(ccp(0.5,1))
	contentLayer:addChild(self._jianjieBg)
	contentHeight = contentHeight + self._jianjieBg:getContentSize().height + 30

	-- 设置position
	local posY = contentHeight - 15
	self._iconBg:setPosition(ccp(self._bgSprite:getContentSize().width*0.5,posY))
	posY = posY - self._iconBg:getContentSize().height-30

	if( self._isShowRuneBg )then
		self._runeBg:setPosition(ccp(self._bgSprite:getContentSize().width*0.5,posY))
		posY = posY - self._runeBg:getContentSize().height-30
	end

	self._curAttrBg:setPosition(ccp(self._bgSprite:getContentSize().width*0.5,posY))
	posY = posY - self._curAttrBg:getContentSize().height-30

	if( self._isShowJinglianBg )then 
		self._jinglianBg:setPosition(ccp(self._bgSprite:getContentSize().width*0.5,posY))
		posY = posY - self._jinglianBg:getContentSize().height-30
	end

	if( self._isShowLockBg )then 
		self._lockBg:setPosition(ccp(self._bgSprite:getContentSize().width*0.5,posY))
		posY = posY - self._lockBg:getContentSize().height-30
	end

	if( self._isShowRedLockBg )then 
		self._redLockBg:setPosition(ccp(self._bgSprite:getContentSize().width*0.5,posY))
		posY = posY - self._redLockBg:getContentSize().height-30
	end
	
	if( self._isShowJibanBg )then 
		self._jibanBg:setPosition(ccp(self._bgSprite:getContentSize().width*0.5,posY))
		posY = posY - self._jibanBg:getContentSize().height-20
	end

	self._jianjieBg:setPosition(ccp(self._bgSprite:getContentSize().width*0.5,posY))

	--  设置contentLayer
	print("contentHeight==>",contentHeight)
	contentLayer:setContentSize(CCSizeMake(640,contentHeight))
	self._scrollView:setContainer(contentLayer)
	self._scrollView:setPosition(ccp(0,self._bottomBg:getContentSize().height))
	self._bgSprite:addChild(self._scrollView)
	self._scrollView:setContentOffset(ccp(0,self._scrollView:getViewSize().height-contentLayer:getContentSize().height))
end

--------------------------------------------------------- 创建每部分ui -------------------------------------------------------------
--[[
	@des:创建宝物形象相关
--]]
function TreasureInfoLayer:getIconBgSprite()
	local retSprite = CCScale9Sprite:create("images/hero/info_bg.png")
	retSprite:setContentSize(CCSizeMake(587,537))

	-- 星级
	local quality = ItemUtil.getTreasureQualityByItemInfo( self._itemInfo )
	-- 星星底
	local starsBgSp = CCSprite:create("images/formation/stars_bg.png")
	starsBgSp:setAnchorPoint(ccp(0.5, 1))
	starsBgSp:setPosition(ccp(retSprite:getContentSize().width/2,retSprite:getContentSize().height - 15))
	retSprite:addChild(starsBgSp,20)
	
	-- 星星们
	local starsXPositions = {0.5, 0.4, 0.6, 0.3, 0.7, 0.2, 0.8}
	local starsYPositions = {0.75, 0.74, 0.74, 0.71, 0.71, 0.68, 0.68}
	local starsXPositionsDouble = {0.45,0.55,0.35,0.65,0.25,0.75,0.8}
    local starsYPositionsDouble = {0.745,0.745,0.72,0.72,0.7,0.7,0.68}

	for k = 1 ,quality do
		local starSprite = CCSprite:create("images/formation/star.png")
		starSprite:setAnchorPoint(ccp(0.5, 0.5))
		if ((quality%2) ~= 0) then
			starSprite:setPosition(ccp(starsBgSp:getContentSize().width * starsXPositions[k], starsBgSp:getContentSize().height * starsYPositions[k]))
		else
			starSprite:setPosition(ccp(starsBgSp:getContentSize().width * starsXPositionsDouble[k], starsBgSp:getContentSize().height * starsYPositionsDouble[k]))
		end
		starsBgSp:addChild(starSprite)
	end

	-- 宝物卡牌
	local cardIcon = CCSprite:create("images/base/treas/big/" .. self._itemInfo.itemDesc.icon_big)
	cardIcon:setAnchorPoint(ccp(0.5,0.5))
	cardIcon:setPosition(ccp(retSprite:getContentSize().width*0.5,300))
	retSprite:addChild(cardIcon)

	-- 名字
	local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBg:setContentSize(CCSizeMake(200, 40))
	nameBg:setAnchorPoint(ccp(0.5,0.5))
	nameBg:setPosition(ccp(retSprite:getContentSize().width*0.5, 120))
	retSprite:addChild(nameBg,2)

	local nameLabel = ItemUtil.getTreasureNameByItemInfo( self._itemInfo, g_sFontPangWa, 25 ) 
	nameLabel:setAnchorPoint(ccp(0,0.5))
    nameBg:addChild(nameLabel)
    local enhanceLv = 0
    if(not table.isEmpty(self._itemInfo.va_item_text))then
    	enhanceLv = self._itemInfo.va_item_text.treasureLevel
    end
    -- 强化
    local enhanceLvLabel = CCRenderLabel:create("+" .. enhanceLv, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    enhanceLvLabel:setAnchorPoint(ccp(0,0.5))
    enhanceLvLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
    nameBg:addChild(enhanceLvLabel)
    -- 居中
    local posX = (nameBg:getContentSize().width-nameLabel:getContentSize().width-enhanceLvLabel:getContentSize().width-10)*0.5
    nameLabel:setPosition(ccp(posX, nameBg:getContentSize().height*0.5))
    enhanceLvLabel:setPosition(ccp(nameLabel:getPositionX()+nameLabel:getContentSize().width+10,nameLabel:getPositionY()))

    -- 品级
    local  pinSprite = CCSprite:create("images/common/pin.png")
    pinSprite:setAnchorPoint(ccp(0,0.5))
    pinSprite:setPosition(ccp(70,120))
    retSprite:addChild(pinSprite)

    local pinNum = 0
    if(quality < 6)then
        pinNum = self._itemInfo.itemDesc.base_score
    elseif(quality==6)then
        pinNum = self._itemInfo.itemDesc.new_score
    elseif(quality==7)then
        pinNum = self._itemInfo.itemDesc.new_score2
    end
    local pinNumSprite = LuaCC.createSpriteOfNumbers("images/item/equipnum", pinNum, 17)
    pinNumSprite:setAnchorPoint(ccp(0, 0.5))
    pinNumSprite:setPosition(pinSprite:getPositionX()+pinSprite:getContentSize().width+5, pinSprite:getPositionY())
    retSprite:addChild(pinNumSprite)

    if( self._isShowDevelopBtn )then 
		-- 进阶按钮
		self._developMenu = BTSensitiveMenu:create()
		self._developMenu:setPosition(ccp(0, 0))
		retSprite:addChild(self._developMenu)
		self._developMenu:setTouchPriority(self._touchPrority-2)
		-- 进阶按钮
		--兼容东南亚英文版
		local fontSize = 35
	 	if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	 		fontSize = 25
	 	end
		local developMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(170, 73), GetLocalizeStringBy("lic_1559"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		developMenuItem:setAnchorPoint(ccp(0.5, 0.5))
		developMenuItem:setPosition(ccp( retSprite:getContentSize().width*0.5, 60 ))
		self._developMenu:addChild(developMenuItem)
		local developCallback = function ( ... )
			-- 进阶回调
			self:developBtnCallBack()
		end
		developMenuItem:registerScriptTapHandler(developCallback)
	end

	return retSprite
end

--[[
	@des:创建符印相关
--]]
function TreasureInfoLayer:getRunBgSprite()
	local retSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")
	retSprite:setContentSize(CCSizeMake(590, 250))

	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(145, 40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,retSprite:getContentSize().height))
	retSprite:addChild(titleBg,5)

	-- 战马印 兵书符
	local typeName = {GetLocalizeStringBy("lic_1538"),GetLocalizeStringBy("lic_1539")}
	local titleFont = CCRenderLabel:create(typeName[tonumber(self._itemInfo.itemDesc.type)], g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	titleFont:setColor(ccc3(0xfe,0xdb,0x1c))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

	-- 四个符印
	self._runeSpriteArr = {}
	local posX = {0.12,0.37,0.62,0.87}
	for i=1,4 do
		local runeBg = self:getRuneSprite(i)
		runeBg:setAnchorPoint(ccp(0.5,0.5))
		runeBg:setPosition(ccp(retSprite:getContentSize().width*posX[i], retSprite:getContentSize().height*0.5))
		retSprite:addChild(runeBg)
		-- 储存
		table.insert(self._runeSpriteArr,runeBg)
	end

	return retSprite
end

--[[
	@des 	: 刷新符印图标
	@param 	: 
	@return : sprite
--]]
function TreasureInfoLayer:refreshRuneSprite()
	for k,v in pairs(self._runeSpriteArr) do
		v:removeFromParentAndCleanup(true)
	end
	self._runeSpriteArr = {}
	local posX = {0.12,0.37,0.62,0.87}
	for i=1,4 do
		local runeBg = self:getRuneSprite(i)
		runeBg:setAnchorPoint(ccp(0.5,0.5))
		runeBg:setPosition(ccp(self._runeBg:getContentSize().width*posX[i], self._runeBg:getContentSize().height*0.5))
		self._runeBg:addChild(runeBg)
		-- 储存
		table.insert(self._runeSpriteArr,runeBg)
	end
end

--[[
	@des 	: 得到符印图标
	@param 	: p_index 		:第几个符印位置
	@return : sprite
--]]
function TreasureInfoLayer:getRuneSprite(p_index)
	local iconBg = CCSprite:create("images/common/rune_bg_b.png")
	local menuBar = BTSensitiveMenu:create()
	menuBar:setPosition(ccp(0, 0))
	iconBg:addChild(menuBar,1,100)
	menuBar:setTouchPriority(self._touchPrority - 2)
	local normalSp = CCSprite:create()
	normalSp:setContentSize(CCSizeMake(98,96))
	local selectSp = CCSprite:create()
	selectSp:setContentSize(CCSizeMake(98,96))
	local menuItem = CCMenuItemSprite:create(normalSp, selectSp)
	menuItem:setAnchorPoint(ccp(0.5,0.5))
	menuItem:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
	menuBar:addChild(menuItem,1,p_index)
	local runeMenuItemCallBack = function ( ... )
		-- 镶嵌回调
		self:runeBtnCallBack( p_index )
	end
	menuItem:registerScriptTapHandler(runeMenuItemCallBack)

	-- 是否可点击
	if(self._showType == TreasInfoType.OTHER_FORMATION_TYPE)then
		menuItem:setEnabled(false)
	end

	if(self._itemInfo.va_item_text and self._itemInfo.va_item_text.treasureInlay and self._itemInfo.va_item_text.treasureInlay[tostring(p_index)])then
		-- 有符印
		local runeInfo =  self._itemInfo.va_item_text.treasureInlay[tostring(p_index)]
		local runeIcon = ItemSprite.getItemSpriteByItemId(runeInfo.item_template_id)
		runeIcon:setAnchorPoint(ccp(0.5,0.5))
		runeIcon:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
		menuItem:addChild(runeIcon)

		-- 符印名字
		local dbData = ItemUtil.getItemById(runeInfo.item_template_id)
	 	local runeName = CCRenderLabel:create(dbData.name,  g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		runeName:setColor(HeroPublicLua.getCCColorByStarLevel(dbData.quality))
		runeName:setAnchorPoint(ccp(0.5,0))
		runeName:setPosition(ccp(runeIcon:getContentSize().width/2,runeIcon:getContentSize().height+15))
		runeIcon:addChild(runeName)
		-- 符印属性
	    local attrTab = RuneData.getRuneAbilityByItemInfo(runeInfo)
		if(not table.isEmpty(attrTab) )then
			for i=1,#attrTab do
				local attrLabel = CCLabelTTF:create(attrTab[i].name .. "+" .. attrTab[i].showNum ,g_sFontName,20)
				attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
				attrLabel:setAnchorPoint(ccp(0.5, 1))
				attrLabel:setPosition(ccp(runeIcon:getContentSize().width*0.5,-15-(i-1)*30))
				runeIcon:addChild(attrLabel)
			end
		end
	else
		-- 没有符印
		local isOpen,needNum,isUseLv = TreasureData.getRunePosIsOpen(self._itemInfo.item_template_id, self._itemInfo.item_id, self._itemInfo, p_index)
		print("isOpen",isOpen,"needNum",needNum,"isUseLv",isUseLv)
		if(isOpen)then
			-- 开启 加号
			local addSprite = ItemSprite.createLucencyAddSprite()
			addSprite:setAnchorPoint(ccp(0.5,0.5))
			addSprite:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
			menuItem:addChild(addSprite)
		else
			-- 没开启 锁
			local lockSp = CCSprite:create("images/common/rune_lock_b.png")
			lockSp:setAnchorPoint(ccp(0.5,0.5))
			lockSp:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.4))
			menuItem:addChild(lockSp)
			if(isUseLv == true)then
				local tipStr1 = GetLocalizeStringBy("lic_1540")
				local tipStr2 = needNum
				local tipStr3 = GetLocalizeStringBy("lic_1542")
				local tipStrFont1 = CCRenderLabel:create(tipStr1, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont1:setColor(ccc3(0xff, 0x7e, 0x00))
			    tipStrFont1:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont1:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.7))
			    menuItem:addChild(tipStrFont1,2)
			    local tipStrFont2 = CCRenderLabel:create(tipStr2, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont2:setColor(ccc3(0x00, 0xff, 0x18))
			    tipStrFont2:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont2:setPosition(ccp(menuItem:getContentSize().width*0.3,menuItem:getContentSize().height*0.3))
			    menuItem:addChild(tipStrFont2,2)
			    local tipStrFont3 = CCRenderLabel:create(tipStr3, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont3:setColor(ccc3(0xff, 0xff, 0xff))
			    tipStrFont3:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont3:setPosition(ccp(tipStrFont2:getContentSize().width+tipStrFont2:getPositionX()+5,tipStrFont2:getPositionY()))
			    menuItem:addChild(tipStrFont3,2)
			else
				local tipStr1 = GetLocalizeStringBy("lic_1541")
				local tipStr2 = "+" .. needNum
				local tipStr3 = GetLocalizeStringBy("lic_1542")
				local tipStrFont1 = CCRenderLabel:create(tipStr1, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont1:setColor(ccc3(0xff, 0x7e, 0x00))
			    tipStrFont1:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont1:setPosition(ccp(menuItem:getContentSize().width*0.3,menuItem:getContentSize().height*0.7))
			    menuItem:addChild(tipStrFont1,2)
			    local tipStrFont2 = CCRenderLabel:create(tipStr2, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont2:setColor(ccc3(0x00, 0xff, 0x18))
			    tipStrFont2:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont2:setPosition(ccp(tipStrFont1:getContentSize().width+tipStrFont1:getPositionX()+5,menuItem:getContentSize().height*0.7))
			    menuItem:addChild(tipStrFont2,2)
			    local tipStrFont3 = CCRenderLabel:create(tipStr3, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont3:setColor(ccc3(0xff, 0xff, 0xff))
			    tipStrFont3:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont3:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.3))
			    menuItem:addChild(tipStrFont3,2)
			end
			
		end
	end
	return iconBg
end

--[[
	@des:创建当前属性相关
--]]
function TreasureInfoLayer:getCurAttrBgSprite()
	local retSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")

	-- 计算长度
	print("self._curAttrTab") print_t(self._curAttrTab)
	local needHeight = 0
	if( table.count(self._curAttrTab) > 1)then 
		needHeight = table.count(self._curAttrTab)*30+50
		if( self._isCanDevelop )then 
			needHeight = needHeight + 30
		end
	else
		needHeight = 85
	end
	print("needHeight",needHeight)
	retSprite:setContentSize(CCSizeMake(590, needHeight))

	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(145, 40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,retSprite:getContentSize().height))
	retSprite:addChild(titleBg,5)

	-- 当前属性
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_1293"), g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

 	-- 属性
	local posY = retSprite:getContentSize().height - 55

	-- 非经验类宝物
	for k_id,v_num in pairs( self._curAttrTab ) do
        local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(k_id, v_num)
        local attrNameLabel = CCLabelTTF:create(affixDesc.sigleName,g_sFontName,21)
        attrNameLabel:setColor(ccc3(0x78,0x25,0x00))
        attrNameLabel:setAnchorPoint(ccp(0,0))
        attrNameLabel:setPosition(ccp(135,posY))
        retSprite:addChild(attrNameLabel)

        local attrNumLabel = CCRenderLabel:create( "+" .. displayNum, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
        attrNumLabel:setColor(ccc3(0x00,0xff,0x18))
        attrNumLabel:setAnchorPoint(ccp(0,0))
        attrNumLabel:setPosition(ccp(245,attrNameLabel:getPositionY()))
        retSprite:addChild(attrNumLabel)

        posY = posY - 30
	end
	-- 进阶下一层增加属性
	if( self._isCanDevelop )then 
		local curDevelopNum = -1
		if(self._itemInfo.va_item_text and self._itemInfo.va_item_text.treasureDevelop )then
			curDevelopNum = tonumber(self._itemInfo.va_item_text.treasureDevelop)
		end
		local addAttrTab = TreasureDevelopData.getDevelopAttrTab(self._itemInfo.item_template_id, curDevelopNum+1 )
		for k,v in pairs(addAttrTab) do
			local addAttrFont = CCLabelTTF:create(v.name, g_sFontName, 21)
			addAttrFont:setColor(ccc3(0x64,0x64,0x64))
			addAttrFont:setAnchorPoint(ccp(0,0))
			addAttrFont:setPosition(ccp(135,posY))
			retSprite:addChild(addAttrFont)
			local str = ""
			if(curDevelopNum<5)then
				str = GetLocalizeStringBy("lic_1562",curDevelopNum+1)
			else
				str = GetLocalizeStringBy("llp_484",curDevelopNum-5)
			end
			local addAttrNumFont = CCLabelTTF:create("+" .. v.showNum .. str, g_sFontName, 21)
			addAttrNumFont:setColor(ccc3(0x64,0x64,0x64))
			addAttrNumFont:setAnchorPoint(ccp(0,0))
			addAttrNumFont:setPosition(ccp(245,addAttrFont:getPositionY()))
			retSprite:addChild(addAttrNumFont)

			posY = posY - 30
		end
	end


	-- 经验类宝物
	local treasureExp= 0
	if(not table.isEmpty(self._itemInfo.va_item_text))then 
    	treasureExp = self._itemInfo.va_item_text.treasureExp
    end
	if self._itemInfo.itemDesc.isExpTreasure and (tonumber(self._itemInfo.itemDesc.isExpTreasure) == 1) then
		local add_exp = (tonumber(self._itemInfo.itemDesc.base_exp_arr) + tonumber(treasureExp))
		local attrNameLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3242"), g_sFontName, 21)
		attrNameLabel:setColor(ccc3(0x78, 0x25, 0x00))
		attrNameLabel:setAnchorPoint(ccp(0, 0))
		attrNameLabel:setPosition(ccp(135,posY))
		retSprite:addChild(attrNameLabel)

		local attrNumLabel = CCRenderLabel:create( "+" .. add_exp, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
        attrNumLabel:setColor(ccc3(0x00,0xff,0x18))
        attrNumLabel:setAnchorPoint(ccp(0,0))
        attrNumLabel:setPosition(ccp(245,attrNameLabel:getPositionY()))
        retSprite:addChild(attrNumLabel)
	end

	return retSprite 
end

--[[
	@des:创建解锁属性相关
--]]
function TreasureInfoLayer:getLockAttrBgSprite(pAttrTab,pTitleStr)
	local retSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")

	-- 计算长度
	print("pAttrTab") print_t(pAttrTab)
	local needHeight = 0
	if( table.count(pAttrTab) > 1)then 
		needHeight = table.count(pAttrTab)*30+50
	else
		needHeight = 85
	end
	print("needHeight",needHeight)
	retSprite:setContentSize(CCSizeMake(590, needHeight))

	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(145, 40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,retSprite:getContentSize().height))
	retSprite:addChild(titleBg,5)

	-- 解锁属性
	local titleFont = CCLabelTTF:create( pTitleStr, g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

 	-- 属性
	local posY = retSprite:getContentSize().height - 55
	for key, active_info  in pairs( pAttrTab ) do
		local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(active_info.attId, active_info.num)
		local color1 = nil
		local color2 = nil
		local str = nil
		if(active_info.isOpen)then
			color1 = ccc3(0x78, 0x25, 0x00)
			color2 = ccc3(0x00,0xff,0x18)
			str = "+" .. displayNum
		else
			color1 = ccc3(0x64,0x64,0x64)
			color2 = ccc3(0x64,0x64,0x64)
			if( active_info.needDevelopLv )then
				if(tonumber(active_info.needDevelopLv)<6)then
					str = "+" .. displayNum .. GetLocalizeStringBy("lic_1560",active_info.needDevelopLv,active_info.openLv)
				else
					str = "+" .. displayNum .. GetLocalizeStringBy("llp_485",active_info.needDevelopLv-6,active_info.openLv)
				end
				
			else
				str = "+" .. displayNum .. " (" .. active_info.openLv .. GetLocalizeStringBy("key_1066")
			end
		end

        local attrNameLabel = CCLabelTTF:create(affixDesc.sigleName,g_sFontName,21)
        attrNameLabel:setColor(color1)
        attrNameLabel:setAnchorPoint(ccp(0,0))
        attrNameLabel:setPosition(ccp(135,posY))
        retSprite:addChild(attrNameLabel)

        local attrNumLabel = nil
        if(active_info.isOpen)then
        	attrNumLabel = CCRenderLabel:create( str, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
        else
        	attrNumLabel = CCLabelTTF:create( str, g_sFontName,21)
        end
        attrNumLabel:setColor(color2)
        attrNumLabel:setAnchorPoint(ccp(0,0))
        attrNumLabel:setPosition(ccp(245,attrNameLabel:getPositionY()))
        retSprite:addChild(attrNumLabel)

        posY = posY - 30
	end

	return retSprite 
end

--[[
	@des:创建精炼属性相关
--]]
function TreasureInfoLayer:getJinglianAttrBgSprite()
	local retSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")

	-- 计算长度
	print("self._jinglianAttrTab") print_t(self._jinglianAttrTab)
	local needHeight = 0
	if( table.count(self._jinglianAttrTab) > 1)then 
		needHeight = table.count(self._jinglianAttrTab)*30+50
	else
		needHeight = 130
	end
	print("needHeight",needHeight)
	retSprite:setContentSize(CCSizeMake(590, needHeight))

	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(145, 40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,retSprite:getContentSize().height))
	retSprite:addChild(titleBg,5)

	-- 精炼属性
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_2155"), g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

	-- 精炼等级图标
	local diamondBg= CCScale9Sprite:create("images/hero/transfer/bg_ng_orange.png")
	diamondBg:setContentSize(CCSizeMake(430, 44))
	diamondBg:setAnchorPoint(ccp(0,1))
	diamondBg:setPosition(ccp(80,retSprite:getContentSize().height-25))
	retSprite:addChild(diamondBg)

	local curWasterLv = tonumber(self._itemInfo.va_item_text.treasureEvolve)
	for i=1, 10 do
		local sprite = nil
		if(i <= (curWasterLv)%10) then
			sprite 	= TreasureUtil.getFixedLevelSprite(curWasterLv)
		else
			sprite 	= CCSprite:create("images/common/big_gray_gem.png")
		end

		if math.floor(tonumber(curWasterLv)/10) >= 1 and tonumber(curWasterLv)%10==0  then
			sprite 	= TreasureUtil.getFixedLevelSprite(curWasterLv)
		end
		
		sprite:setAnchorPoint(ccp(0.5, 0.5))
		local dis  	= 43
		local x    	= dis/2 + dis * (i-1)
		local y 	= diamondBg:getContentSize().height/2
		sprite:setPosition(ccp(x , y))
		diamondBg:addChild(sprite)
	end

	-- 属性
	local posY = diamondBg:getPositionY()-diamondBg:getContentSize().height - 40

	for k_id,v_num in pairs( self._jinglianAttrTab ) do
        local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(k_id, v_num)
        local attrNameLabel = CCLabelTTF:create(affixDesc.sigleName,g_sFontName,21)
        attrNameLabel:setColor(ccc3(0x78,0x25,0x00))
        attrNameLabel:setAnchorPoint(ccp(0,0))
        attrNameLabel:setPosition(ccp(80,posY))
        retSprite:addChild(attrNameLabel)

        local attrNumLabel = CCRenderLabel:create( "+" .. displayNum, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
        attrNumLabel:setColor(ccc3(0x00,0xff,0x18))
        attrNumLabel:setAnchorPoint(ccp(0,0))
        attrNumLabel:setPosition(ccp(190,attrNameLabel:getPositionY()))
        retSprite:addChild(attrNumLabel)

        posY = posY - 30
	end

	return retSprite 
end

--[[
	@des:创建羁绊相关
--]]
function TreasureInfoLayer:getJibanBgSprite()
	local retSprite = CCSprite:create()

	-- 计算长度
	print("self._jibanDataTab") print_t(self._jibanDataTab)
	local needHeight = table.count(self._jibanDataTab)*(140+15)+50
	print("needHeight",needHeight)
	retSprite:setContentSize(CCSizeMake(590, needHeight))
	-- 宝物羁绊背景
	local flower = CCSprite:create("images/copy/herofrag/cutFlower.png")
	flower:setAnchorPoint(ccp(0.5,0.5))
	flower:setPosition(ccp(retSprite:getContentSize().width*0.5, retSprite:getContentSize().height-20))
	retSprite:addChild(flower)
	-- 宝物羁绊名字
	local tipName = CCRenderLabel:create(GetLocalizeStringBy("key_2449"), g_sFontPangWa,30,2,ccc3(0xff,0xff,0xff),type_shadow)
	tipName:setColor(ccc3(0x78,0x25,0x00))
	tipName:setAnchorPoint(ccp(0.5,0.5))
	tipName:setPosition(ccp(flower:getContentSize().width*0.5, flower:getContentSize().height*0.5))
	flower:addChild(tipName)

	-- 羁绊人物
	local posY = flower:getPositionY()-170
	for k,v in pairs(self._jibanDataTab) do
		local temp = string.split(v,"|")
		local heroHtid = tonumber(temp[1])
		local jibanId = temp[2]

		local attrBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
		attrBg:setPreferredSize(CCSizeMake(590, 140))
		attrBg:setAnchorPoint(ccp(0.5,0))
		attrBg:setPosition(ccp(retSprite:getContentSize().width*0.5,posY))
		retSprite:addChild(attrBg)

		local lineSprite = CCSprite:create("images/item/equipinfo/line.png")
		lineSprite:setAnchorPoint(ccp(0.5, 0.5))
		lineSprite:setScaleX(5)
		lineSprite:setPosition(ccp(attrBg:getContentSize().width*0.5, attrBg:getContentSize().height*0.5+20))
		attrBg:addChild(lineSprite)

		local heroIcon = nil
		local userInfo = UserModel.getUserInfo()
		if( heroHtid == 1 )then
			local genderId = HeroModel.getSex(userInfo.htid)
			heroIcon = HeroUtil.getHeroIconByHTID(userInfo.htid,UserModel.getDressIdByPos(1),genderId, UserModel.getVipLevel())
		else
			heroIcon = HeroUtil.getHeroIconByHTID(heroHtid)
		end
		heroIcon:setPosition(ccp(10, attrBg:getContentSize().height-10))
		heroIcon:setAnchorPoint(ccp(0,1))
		attrBg:addChild(heroIcon)

		local heroNameStr = nil
		if (heroHtid == 1) then 
			heroNameStr = userInfo.uname
		else
			local heroInfo = HeroUtil.getHeroLocalInfoByHtid(heroHtid)
			heroNameStr = heroInfo.name
		end
		heroName = CCRenderLabel:create(heroNameStr, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    heroName:setColor(ccc3(0xff, 0xf6, 0x00))
	    heroName:setAnchorPoint(ccp(0.5, 1))
	    heroName:setPosition(ccp( heroIcon:getContentSize().width*0.5, -5))
	    heroIcon:addChild(heroName)

	    require "db/DB_Union_profit"
	    local unionInfo = DB_Union_profit.getDataById(jibanId)
	    local unionName = CCRenderLabel:create(unionInfo.union_arribute_name, g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    unionName:setColor(ccc3(0x2c, 0xdb, 0x23))
	    unionName:setAnchorPoint(ccp(0.5, 0.5))
	    unionName:setPosition(ccp( attrBg:getContentSize().width*0.5, attrBg:getContentSize().height*2/3+20))
	    attrBg:addChild(unionName)

	    local unionScribe = CCLabelTTF:create(unionInfo.union_arribute_desc, g_sFontName, 20)
	    unionScribe:setColor(ccc3(0x78, 0x25, 0x00))
	    unionScribe:setAnchorPoint(ccp(0.5, 0.5))
	    unionScribe:setPosition(ccp( attrBg:getContentSize().width*0.5, attrBg:getContentSize().height/3))
	    attrBg:addChild(unionScribe)

	    posY = posY - attrBg:getContentSize().height - 15
	end
	
	return retSprite
end

--[[
	@des:创建简介相关
--]]
function TreasureInfoLayer:getJianjieBgSprite()
	local retSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")

	-- 第一行
    local textInfo = {
     		width = 550, -- 宽度
	        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 21,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = self._itemInfo.itemDesc.info,
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local fontNode = LuaCCLabel.createRichLabel(textInfo)
 	
 	needHeight = fontNode:getContentSize().height + 50
	print("needHeight",needHeight)
	retSprite:setContentSize(CCSizeMake(590, needHeight))

	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(145, 40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,retSprite:getContentSize().height))
	retSprite:addChild(titleBg,5)

	-- 简介
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_2371"), g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

	-- 简介描述
	fontNode:setAnchorPoint(ccp(0.5, 1))
 	fontNode:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height-25))
 	retSprite:addChild(fontNode)

 	return retSprite
end
--------------------------------------------------------- 按钮事件 -----------------------------------------------------------------
--[[
	@des:关闭信息面板
--]]
function TreasureInfoLayer:closeLayer()
	self:removeFromParentAndCleanup(true)
	self = nil
end

--[[
	@des:精炼回调
--]]
function TreasureInfoLayer:jinglianBtnCallBack()
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	
	if not DataCache.getSwitchNodeState(ksSwitchTreasureFixed) then
        return
   	end

	require "script/ui/treasure/evolve/TreasureEvolveMainView"
	local treaEvolveLayer = TreasureEvolveMainView.createLayer(self._itemInfo.item_id)
	if(MainScene.getOnRunningLayerSign() == "formationLayer") then
		TreasureEvolveMainView.setFromLayerTag(TreasureEvolveMainView.kFormationListTag)
	else
		-- 记忆宝物背包位置
		require "script/ui/bag/BagLayer"
		BagLayer.setMarkTreasureItemId(self._itemInfo.item_id)
	end
	MainScene.changeLayer(treaEvolveLayer, "treaEvolveLayer")

   	-- 关闭界面
	self:closeLayer()
end

--[[
	@des:强化回调
--]]
function TreasureInfoLayer:qianghuaBtnCallBack()
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local isShow = nil 
	if( self._showType == TreasInfoType.FORMATION_TYPE )then   
		isShow = false
	else
		isShow = true
	end
	require "script/ui/item/TreasReinforceLayer"
	local enforceLayer = TreasReinforceLayer.createLayer(self._itemInfo.item_id, self._registerCallBack, isShow)
	local onRunningLayer = MainScene.getOnRunningLayer()
	onRunningLayer:addChild(enforceLayer, 10)
	if MainScene.getOnRunningLayerSign() == "formationLayer" then
		enforceLayer:setPositionY(MenuLayer.getHeight() * 2)
		enforceLayer:setScale(g_winSize.width / enforceLayer:getContentSize().width)
	end

	-- 关闭界面
	self:closeLayer()
end

--[[
	@des:更换回调
--]]
function TreasureInfoLayer:changeBtnCallBack()
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 更换装备
	require "script/ui/formation/ChangeEquipLayer"
	local changeEquipLayer = ChangeEquipLayer.createLayer( nil, self._itemInfo.hid, self._itemInfo.pos, true)
	MainScene.changeLayer(changeEquipLayer, "changeEquipLayer")

	-- 关闭界面
	self:closeLayer()
	
end

--[[
	@des:卸下回调
--]]
function TreasureInfoLayer:removeBtnCallBack()
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(ItemUtil.isTreasBagFull(true))then
		-- 关闭界面
		self:closeLayer()
		return
	end

	local removeArmingCallback = function ( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			--战斗力信息
			--added by Zhang Zihang
			local _lastFightValue = FightForceModel.dealParticularValues(self._itemInfo.hid)

			HeroModel.removeTreasFromHeroBy(self._itemInfo.hid, self._itemInfo.pos)
			FormationLayer.refreshEquipAndBottom()

			--战斗力信息
			--added by Zhang Zihang
			local _nowFightValue = FightForceModel.dealParticularValues(self._itemInfo.hid)

			require "script/model/utils/UnionProfitUtil"
			UnionProfitUtil.refreshUnionProfitInfo()

			ItemUtil.showAttrChangeInfo(_lastFightValue,_nowFightValue)

			-- 关闭界面
			self:closeLayer()
		end
	end

	local args = Network.argsHandler(self._itemInfo.hid, self._itemInfo.pos)
	RequestCenter.hero_removeTreasure(removeArmingCallback,args )
end

--[[
	@des:确定回调
--]]
function TreasureInfoLayer:yesBtnCallBack()
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 回调
	if(self._registerCallBack)then 
		self._registerCallBack()
	end

	-- 关闭界面
	self:closeLayer()
end

--[[
	@des:前往夺宝回调
--]]
function TreasureInfoLayer:robBtnCallBack()
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 关闭界面
	self:closeLayer()

	if( not DataCache.getSwitchNodeState( ksSwitchRobTreasure ) ) then
		return
	end
	require "script/ui/treasure/TreasureMainView"
	local treasureLayer = TreasureMainView.create()
	MainScene.changeLayer(treasureLayer,"treasureLayer")
end

--[[
	@des:进阶回调
--]]
function TreasureInfoLayer:developBtnCallBack()
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/treasure/develop/TreasureDevelopLayer"
	TreasureDevelopLayer.showLayer(self._itemInfo.item_id)
	if( self._showType == TreasInfoType.FORMATION_TYPE )then 
		-- 设置界面记忆
		TreasureDevelopLayer.setChangeLayerMark( TreasureDevelopLayer.kTagFormation )
	else
		-- 设置界面记忆
		TreasureDevelopLayer.setChangeLayerMark( TreasureDevelopLayer.kTagBag )
	end
	
	-- 关闭界面
	self:closeLayer()
end

--[[
	@des:符印回调
	@param 	: p_index :第几个符印位置
	@return :
--]]
function TreasureInfoLayer:runeBtnCallBack( p_index)
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local isOpen,needNum = TreasureData.getRunePosIsOpen(self._itemInfo.item_template_id, self._itemInfo.item_id, self._itemInfo, p_index)
	if(isOpen == false)then
		return
	end

	-- 符印刷新方法
	local refreshCallFun = function ( ... )
		self:refreshRuneSprite()

		-- 记忆宝物背包位置
		require "script/ui/bag/BagLayer"
		BagLayer.setMarkTreasureItemId(self._itemInfo.item_id)

		-- 手动刷背包数据
		-- 需要修改背包的信息已经过期
		DataCache.setBagStatus(true)
		BagLayer.refreshDataByType()
	end

	if(self._itemInfo.va_item_text and self._itemInfo.va_item_text.treasureInlay and self._itemInfo.va_item_text.treasureInlay[tostring(p_index)])then
		-- 位置上有符印显示详细信息
		require "script/ui/bag/RuneInfoLayer"
		RuneInfoLayer.showLayer( self._itemInfo.va_item_text.treasureInlay[tostring(p_index)].item_id, self._itemInfo.item_id, p_index, refreshCallFun, self._touchPrority-30, self._zOrder+1 )
	else
		-- 没有直接选择
		require "script/ui/treasure/ChooseRuneLayer"
		ChooseRuneLayer.showChooseLayer( self._itemInfo.item_id, p_index, refreshCallFun, self._touchPrority-30, self._zOrder+1 )
	end
end

----------------------------------------------------------- 外部可调用 ----------------------------------------------------------------
--[[
	@des: 注册回调
	@parm: p_callback 回调
--]]
function TreasureInfoLayer:registerCallback( p_callback ) 
	self._registerCallBack = p_callback
end

--[[
	@des: 设置标题
	@parm: str
--]]
function TreasureInfoLayer:setTitleStr( p_str ) 
	self._title:setString(p_str)
end

--[[
	@des: 设置标题 
	@parm: p_image
--]]
function TreasureInfoLayer:setTitleSprite( p_image ) 
	self._title:removeFromParentAndCleanup(true)
	self._title = CCSprite:create(p_image)
	self._title:setAnchorPoint(ccp(0.5,0.5))
    self._title:setPosition(ccp(self._topSprite:getContentSize().width*0.5,self._topSprite:getContentSize().height*0.5))
    self._topSprite:addChild(self._title)
end

-- 新手引导
function TreasureInfoLayer.getGuideObject_2()
  	return comfirmBtn
end  

----------------------------------------------------------- 数据处理 ------------------------------------------------------------------
--[[
	@des: 数据处理
	@param: p_tid 
	@return: 
--]]
function TreasureInfoLayer:initDataWithTid( p_tid )
	-- 宝物信息
	self._itemInfo = {}
	self._itemInfo.item_template_id = p_tid
	self._itemInfo.itemDesc = ItemUtil.getItemById(p_tid)

	-- 当前属性
	self._curAttrTab = TreasAffixModel.getTreasureBaseAffix(self._itemInfo.item_template_id)
	-- 解锁属性
	local allAttrTab = nil
	_, _, allAttrTab, _, _ = ItemUtil.getTreasAttrByTmplId(self._itemInfo.item_template_id)
	-- 宝物解锁属性
	self._lockAttrTab = {}
	-- 宝物天赋属性
	self._redLockAttrTab = {}
	if(not table.isEmpty(allAttrTab) )then
		for i,v in ipairs(allAttrTab) do
			if( v.needDevelopLv < 6 )then
				table.insert(self._lockAttrTab, v)
			else
				-- 红色的
				table.insert(self._redLockAttrTab, v)
			end
		end
	end
	-- 精炼属性
	self._jinglianAttrTab = nil
	-- 宝物羁绊
	if (self._itemInfo.itemDesc.union_info ~= nil) then
		self._jibanDataTab = string.split(self._itemInfo.itemDesc.union_info, ",")
	end
	-- 是否可以强化
	self._isCanQianghua = false
	-- 是否显示强化按钮
	self._isShowQianghuaBtn = false
	-- 是否可以精炼
	self._isCanJinglian = false 
	-- 是否显示精炼按钮
	self._isShowJinglianBtn = false 	
	-- 是否可以进阶		
	self._isCanDevelop = false
	-- 是否显示进阶按钮
	self._isShowDevelopBtn = false 
	-- 是否显示符印背景
	if( self._isCanDevelop )then 
		self._isShowRuneBg = true  
	end  
	-- 是否显示解锁属性背景  
	if( not table.isEmpty(self._lockAttrTab) )then  
		self._isShowLockBg = true    
	end
	-- 是否显示红色解锁属性背景  
	if( not table.isEmpty(self._redLockAttrTab) )then  
		self._isShowRedLockBg = true    
	end
	-- 是否显精炼属性背景
	if( self._isCanJinglian )then 
		self._isShowJinglianBg = true  
	end 
	-- 是否显示宝物羁绊背景
	if( not table.isEmpty(self._jibanDataTab) )then
		self._isShowJibanBg = true
	end
end

--[[
	@des: 数据处理
	@param: p_itemId 
	@return: 
--]]
function TreasureInfoLayer:initDataWithItemId( p_itemId )
	-- 宝物信息
	-- 背包里找
	self._itemInfo = ItemUtil.getItemByItemId(p_itemId)
	-- 阵容上
	if(self._itemInfo == nil)then
		self._itemInfo = ItemUtil.getTreasInfoFromHeroByItemId(p_itemId)
	end
	-- 对方阵容上
	if(self._itemInfo == nil)then
		require "script/ui/active/RivalInfoData"
		self._itemInfo = RivalInfoData.getTreasureByItemId( p_itemId)
	end
	-- print("self._itemInfo") print_t(self._itemInfo)
	-- 当前属性
	self._curAttrTab = TreasAffixModel.getIncreaseAffixByInfo(self._itemInfo)
	-- 解锁属性
	local allAttrTab = nil
	_, _, allAttrTab, _, _ = ItemUtil.getTreasAttrByItemId(nil,self._itemInfo)
	-- 宝物解锁属性
	self._lockAttrTab = {}
	-- 宝物天赋属性
	self._redLockAttrTab = {}
	if(not table.isEmpty(allAttrTab) )then
		for i,v in ipairs(allAttrTab) do
			if( v.needDevelopLv < 6 )then
				table.insert(self._lockAttrTab, v)
			else
				-- 红色的
				table.insert(self._redLockAttrTab, v)
			end
		end
	end
	-- 精炼属性
	self._jinglianAttrTab = TreasAffixModel.getUpgradeAffixByInfo(self._itemInfo)
	-- 宝物羁绊
	if (self._itemInfo.itemDesc.union_info ~= nil) then
		self._jibanDataTab = string.split(self._itemInfo.itemDesc.union_info, ",")
	end

	-- 是否可以强化
	if( tonumber(self._itemInfo.itemDesc.maxStacking) > 1 or self._itemInfo.itemDesc.isStrengthen == nil or tonumber(self._itemInfo.itemDesc.isStrengthen) == 0)then
		self._isCanQianghua = false
	else
		self._isCanQianghua = true
	end
	-- 是否显示强化按钮
	if(self._isCanQianghua)then
		self._isShowQianghuaBtn = true
	end

	-- 是否可以精炼
	if(self._itemInfo.item_id and tonumber(self._itemInfo.itemDesc.isUpgrade) == 1)then
		self._isCanJinglian = true 
	end
	-- 是否显示精炼按钮
	if( self._isCanJinglian and self._showType ~= TreasInfoType.OTHER_FORMATION_TYPE )then
		self._isShowJinglianBtn = true
	end

	-- 是否可以进阶		
	if(self._itemInfo.item_id and tonumber(self._itemInfo.itemDesc.can_evolve) == 1)then
		self._isCanDevelop  = true
	end
	-- 是否显示进阶按钮
	if( self._isCanDevelop and self._showType ~= TreasInfoType.OTHER_FORMATION_TYPE )then
		self._isShowDevelopBtn = true 
	end

	-- 是否显示符印背景
	if( self._isCanDevelop )then 
		self._isShowRuneBg = true  
	end 

	-- 是否显示解锁属性背景  
	if( not table.isEmpty(self._lockAttrTab) )then  
		self._isShowLockBg = true    
	end

	-- 是否显示红色解锁属性背景  
	if( not table.isEmpty(self._redLockAttrTab) )then  
		self._isShowRedLockBg = true    
	end
	
	-- 是否显精炼属性背景
	if( self._isCanJinglian )then 
		self._isShowJinglianBg = true  
	end 

	-- 是否显示宝物羁绊背景
	if( not table.isEmpty(self._jibanDataTab) )then
		self._isShowJibanBg = true
	end
end














