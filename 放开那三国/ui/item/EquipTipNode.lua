-- Filename：	EquipTipNode.lua

module("EquipTipNode", package.seeall)
require "script/ui/item/EquipFixedData"

local _confirmCallBack
local _touchPriority
local _zOrder
local _alertLayer
local _closeCallBack
----------------------------------------初始化函数----------------------------------------
local function init()
	_confirmCallBack = nil
	_touchPriority = nil
	_zOrder = nil
	_alertLayer = nil
	_closeCallBack = nil
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("moved")
    else
    	print("otherEventType")
	end
end

local function onNodeEvent(event)
	if (event == "enter") then
		_alertLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_alertLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_alertLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_alertLayer:removeFromParentAndCleanup(true)
	_alertLayer = nil
	if(_closeCallBack~=nil)then
		_closeCallBack()
	end
end

--[[
	@des 	:按钮回调
	@param 	:
	@return :
--]]
local function menuAction(tag,itemBtn)
	if(tag == 10001) then
		-- 回调
		if (_confirmCallBack) then
			_confirmCallBack(true)
		end
	end

	--关闭
	closeAction()
end

----------------------------------------入口函数----------------------------------------
--[[
	@des 	:入口函数
	@param 	:$ p_comingNode 		: 传入的要添加到板子上的node
	@param  :$ p_confirmCallBack 	: 点击确定后的回调
	@param  :$ p_tipSize 			: 板子大小
	@param  :$ p_touchPriority 		: 触摸优先级
	@param  :$ p_zOrder 			: 板子Z轴
	@return :
--]]
function showLayer(itemId,fixedMode,num)
	init()
	_closeCallBack = p_closeCallBack
	_touchPriority = p_touchPriority or -1000
	_zOrder = p_zOrder or 2000
	_confirmCallBack = p_confirmCallBack
	
	local tipSize = p_tipSize or CCSizeMake(560,480)

	--确定按钮文字
	local confirmTitle = GetLocalizeStringBy("key_1985")

	--触摸屏蔽层
	_alertLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_alertLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_alertLayer, _zOrder)

	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local alertBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	alertBg:setPreferredSize(tipSize)
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	alertBg:setPosition(ccp(_alertLayer:getContentSize().width*0.5,_alertLayer:getContentSize().height*0.5))
	alertBg:setScale(g_fScaleX)
	_alertLayer:addChild(alertBg)

	local alertBgSize = alertBg:getContentSize()

	local titleSprite = CCSprite:create("images/hero/star_sell/title_bg.png")
		  titleSprite:setAnchorPoint(ccp(0.5,0.5))
		  titleSprite:setPosition(ccp(alertBg:getContentSize().width*0.5,alertBg:getContentSize().height*0.987))
	alertBg:addChild(titleSprite)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_523"),g_sFontPangWa,30)
		  titleLabel:setAnchorPoint(ccp(0.5,0.5))
		  titleLabel:setColor(ccc3(255,255,0))
		  titleLabel:setPosition(ccp(titleSprite:getContentSize().width*0.5,titleSprite:getContentSize().height*0.5))
	titleSprite:addChild(titleLabel)
	
	--装备属性显示面板
	local infoPanle  = CCScale9Sprite:create("images/common/bg/white_text_ng.png")
	infoPanle:setContentSize(CCSizeMake(alertBgSize.width*0.8, alertBgSize.height - 175))
	infoPanle:setAnchorPoint(ccp(0.5, 0.5))
	infoPanle:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height * 0.54))
	alertBg:addChild(infoPanle)

	local potentialityContainer = CCNode:create()
	potentialityContainer:setContentSize(infoPanle:getContentSize())
	infoPanle:addChild(potentialityContainer)

	local potentInfo = EquipFixedData.getEquipFixedInfo(itemId, fixedMode)
	local equipInfo = ItemUtil.getItemInfoByItemId(itemId)
	local quality = nil
    if _quality ~= nil and _quality ~= -1 then
        quality = _quality
    else
    	
		if(equipInfo == nil) then
			-- 是否武将身上的装备
			equipInfo = ItemUtil.getEquipInfoFromHeroByItemId( itemId )
		end
        quality = ItemUtil.getEquipQualityByItemInfo(equipInfo)
    end
    if quality == nil then
        quality = potentInfo.desc.quality
    end
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create( potentInfo.name, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setColor(nameColor)
	nameLabel:setAnchorPoint(ccp(0.5, 1))
	nameLabel:setPosition(ccp(potentialityContainer:getContentSize().width * 0.5, potentialityContainer:getContentSize().height - 15))
	potentialityContainer:addChild(nameLabel)
	
	for i=1,table.maxn(potentInfo.fixedInfo) do
		local v = potentInfo.fixedInfo[i]
		local potentialityNameLabel = CCLabelTTF:create(v.name .. ":", g_sFontPangWa, 23)
		potentialityNameLabel:setColor(ccc3(0x78, 0x25, 0x00))
		potentialityNameLabel:setAnchorPoint(ccp(1, 0))
		potentialityNameLabel:setPosition(ccp(125, potentialityContainer:getContentSize().height - 50 - 43 * i))
		potentialityContainer:addChild(potentialityNameLabel)

		local baseValueLabel = CCLabelTTF:create((v.potentiality or 0 ), g_sFontName, 23)
		baseValueLabel:setColor(ccc3(0x00, 0x00, 0x00))
		baseValueLabel:setAnchorPoint(ccp(0, 0))
		baseValueLabel:setPosition(ccp(130, potentialityNameLabel:getPositionY()))
		potentialityContainer:addChild(baseValueLabel)

		local rightSprite = CCSprite:create("images/common/right1.png")
			  rightSprite:setAnchorPoint(ccp(0, 0.5))
			  rightSprite:setPosition(ccp(baseValueLabel:getContentSize().width,baseValueLabel:getContentSize().height*0.5))
		baseValueLabel:addChild(rightSprite)

		local addNum = tonumber(v.fixedPotentiality)
		local fixNum = v.potentiality or 0
		local potentialityLabel =  CCLabelTTF:create(((addNum+fixNum) or 0 ), g_sFontName, 23)
		potentialityLabel:setColor(ccc3(0x00, 0x00, 0x00))
		potentialityLabel:setAnchorPoint(ccp(0, 0))
		potentialityLabel:setPosition(ccp(215, potentialityNameLabel:getPositionY()))
		potentialityContainer:addChild(potentialityLabel)

		local potentialityFixedLabel =  CCRenderLabel:create( (v.fixedPotentiality or 0 ).. "", g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		potentialityFixedLabel:setColor(ccc3(0x00, 0xff, 0x18))
		potentialityFixedLabel:setAnchorPoint(ccp(0, 0))
		potentialityFixedLabel:setPosition(ccp(277, potentialityNameLabel:getPositionY()))
		potentialityContainer:addChild(potentialityFixedLabel)

		if(v.fixedPotentiality ~= nil and tonumber(v.fixedPotentiality) < 0) then
			potentialityFixedLabel:setColor(ccc3(0xFF, 0x00, 0x00))
		end

		if(i==table.maxn(potentInfo.fixedInfo))then
			local costLabel =  CCRenderLabel:create( GetLocalizeStringBy("key_2434"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			costLabel:setColor(ccc3(0xff, 0x7a, 0x2e))
			costLabel:setAnchorPoint(ccp(0, 0))
			costLabel:setPosition(ccp(135-potentialityNameLabel:getContentSize().width, potentialityFixedLabel:getPositionY()-potentialityFixedLabel:getContentSize().height*2.2))
			potentialityContainer:addChild(costLabel)

			local costStone = CCSprite:create("images/common/fixed_gem.png")
				  costStone:setPosition(ccp(costLabel:getPositionX()+costLabel:getContentSize().width,costLabel:getPositionY()))
			potentialityContainer:addChild(costStone)	

			local costInfo= EquipFixedData.getFixedCost(equipInfo.itemDesc.fixedPotentialityID, fixedMode)
			local costNumLabel = CCRenderLabel:create( (tonumber(costInfo.item.num) * (num)), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				  costNumLabel:setColor(ccc3(0x00, 0xff, 0x18))  
				  costNumLabel:setAnchorPoint(ccp(0,0))
				  costNumLabel:setPosition(ccp(costStone:getPositionX()+costStone:getContentSize().width,costStone:getPositionY()))
			potentialityContainer:addChild(costNumLabel)

			--更新金币
			if(costInfo.gold ~= nil and tonumber(costInfo.gold)>0) then
				local goldStone = CCSprite:create("images/common/gold.png")
				  	  goldStone:setPosition(ccp(costNumLabel:getPositionX()+costNumLabel:getContentSize().width*1.5,costLabel:getPositionY()))
				potentialityContainer:addChild(goldStone)	
				local goldNumLabel = CCRenderLabel:create( (tonumber(costInfo.gold) * tonumber(num)), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				  	  goldNumLabel:setColor(ccc3(0x00, 0xff, 0x18))  
				  	  goldNumLabel:setAnchorPoint(ccp(0,0))
				  	  goldNumLabel:setPosition(ccp(goldStone:getPositionX()+goldStone:getContentSize().width,costLabel:getPositionY()))
				potentialityContainer:addChild(goldNumLabel)
			end
			--更新银币
			if(costInfo.silver ~= nil and tonumber(costInfo.silver)>0) then
				local silverStone = CCSprite:create("images/common/coin_silver.png")
				  	  silverStone:setPosition(ccp(costNumLabel:getPositionX()+costNumLabel:getContentSize().width*1.5,costLabel:getPositionY()))
				potentialityContainer:addChild(silverStone)	
				local silverNumLabel = CCRenderLabel:create( (tonumber(costInfo.silver) * tonumber(num)), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				  	  silverNumLabel:setColor(ccc3(0x00, 0xff, 0x18))  
				  	  silverNumLabel:setAnchorPoint(ccp(0,0))
				  	  silverNumLabel:setPosition(ccp(silverStone:getPositionX()+silverStone:getContentSize().width,costLabel:getPositionY()))
				potentialityContainer:addChild(silverNumLabel)
			end
		end
		-- local upSprite = nil
		-- if(v.fixedPotentiality ~= nil and tonumber(v.fixedPotentiality) > 0) then
		-- 	upSprite = CCSprite:create("images/item/equipFixed/up.png")
		-- 	upSprite:setAnchorPoint(ccp(0, 0))
		-- 	upSprite:setPosition(potentialityFixedLabel:getPositionX() + potentialityFixedLabel:getContentSize().width + 10, potentialityFixedLabel:getPositionY())
		-- 	potentialityContainer:addChild(upSprite)
		-- elseif(v.fixedPotentiality ~= nil and tonumber(v.fixedPotentiality) < 0) then
		-- 	upSprite = CCSprite:create("images/item/equipFixed/down.png")
		-- 	upSprite:setAnchorPoint(ccp(0, 0))
		-- 	upSprite:setPosition(potentialityFixedLabel:getPositionX() + potentialityFixedLabel:getContentSize().width + 10, potentialityFixedLabel:getPositionY())
		-- 	potentialityContainer:addChild(upSprite)
		-- else

		-- end				
		-- if(v.fixedPotentiality ~= nil and tonumber(v.fixedPotentiality) == 0 and v.potentiality ~= nil and tonumber(v.potentiality) >= tonumber(v.maxFixed)) then
		-- 	potentialityFixedLabel:setString(GetLocalizeStringBy("key_3187"))
		-- 	if(upSprite ~= nil) then
		-- 		upSprite:setVisible(false)
		-- 	end
		-- end

		if(tonumber(v.maxFixed)==tonumber(fixNum))then
			local leftKh = CCLabelTTF:create("("..GetLocalizeStringBy("key_10198")..")", g_sFontName, 23)
			leftKh:setColor(ccc3(255, 0x27, 0x27))
			leftKh:setAnchorPoint(ccp(0, 0))
			leftKh:setPosition(ccp(potentialityFixedLabel:getPositionX()+potentialityFixedLabel:getContentSize().width, potentialityFixedLabel:getPositionY()))
			potentialityContainer:addChild(leftKh)
		end

	end

	-- 关闭按钮bar
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(_touchPriority - 1)
	alertBg:addChild(menuBar)

    -- 确认
	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), confirmTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
	confirmBtn:setPosition(ccp(alertBgSize.width*0.5,60))
    confirmBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(confirmBtn, 1, 10001)
end