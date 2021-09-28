-- Filename: PetTipPanel.lua
-- Author: ZQ
-- Date: 2014-07-09
-- Purpose: 点击宠物图鉴中头标后弹出的信息层
module("PetTipPanel",package.seeall)
local kDarkLayerZOrder = 1000
local kDarkLayerTouchPriority = -600
local KCloseBtnTouchPriority = -601
local kPetHeadIconTouchPriority = -600
local kPetHeadIconNameFontSize = 23
local kPetDescFontSize = 18
local kPetTipFontSize = 18

local _tipPanelBgSpriteContentSize = nil
local _petBrownBgSpriteContentSize = nil
local _topDescLabelDimensions = nil
local _bottomTipLabelDimensions = nil

local _darkShieldLayer = nil
local _petTipPanelBgSprite = nil


--[[
	@des:		初始化各全局变量
	@param:		none
	@retrun:	none
--]]
function init()
	_tipPanelBgSpriteContentSize = CCSizeMake(0,0)
	_petBrownBgSpriteContentSize = CCSizeMake(0,0)
	_topDescLabelDimensions = CCSizeMake(0,0)
	_bottomTipLabelDimensions = CCSizeMake(0,0)

	_darkShieldLayer = nil
	_petTipPanelBgSprite = nil
end

--[[
	@des:		简单数据处理获取所需数据
	@param		none
	@return:	none
--]]
function load(p_tidNum)
	-- 宠物描述
	local descString = PetDescriptionData.getValueByKeyForId(p_tidNum,"des")
	if descString == nil then descString = " " end
	_topDescLabelDimensions = PetDescriptionData.getStringToLineDimensions(descString, 13, kPetDescFontSize)
	_topDescLabelDimensions.height = _topDescLabelDimensions.height < 40 and 40 or _topDescLabelDimensions.height

	require "script/ui/pet/description/PetDescriptionData"
	local tipInfoString = PetDescriptionData.getTipString(p_tidNum)
	_bottomTipLabelDimensions = PetDescriptionData.getStringToLineDimensions(tipInfoString, 18, kPetTipFontSize)

	_tipPanelBgSpriteContentSize.width = 467
	_tipPanelBgSpriteContentSize.height = 250 + _topDescLabelDimensions.height + _bottomTipLabelDimensions.height

	_petBrownBgSpriteContentSize.width = 386
	_petBrownBgSpriteContentSize.height = _tipPanelBgSpriteContentSize.height - 70
end

--[[
	@des:		创建宠物提示层内容
	@param:		p_tidNum 宠物模版id
	@return:	none
--]]
function createLayer(p_tidNum)
	_darkShieldLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_darkShieldLayer:setContentSize(CCSizeMake(g_winSize.width/g_fScaleX,g_winSize.height/g_fScaleX))
	_darkShieldLayer:setScale(g_fScaleX)
	_darkShieldLayer:registerScriptHandler(onNodeEvent)

	-- panel背景
	_petTipPanelBgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	_petTipPanelBgSprite:setPreferredSize(_tipPanelBgSpriteContentSize)
	_petTipPanelBgSprite:setAnchorPoint(ccp(0.5,0.5))
	_petTipPanelBgSprite:setPosition(g_winSize.width/(2*g_fScaleX),g_winSize.height/(2*g_fScaleX))
	_darkShieldLayer:addChild(_petTipPanelBgSprite)

	-- 顶部宠物描述背景
	local topPetDescBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	topPetDescBgSprite:setPreferredSize(_petBrownBgSpriteContentSize)
	topPetDescBgSprite:setAnchorPoint(ccp(0.5,0.5))
	topPetDescBgSprite:setPosition(_tipPanelBgSpriteContentSize.width/2,_tipPanelBgSpriteContentSize.height/2)
	_petTipPanelBgSprite:addChild(topPetDescBgSprite)

	-- 顶部宠物头标
	require "script/ui/pet/PetUtil"
	local petHeadIcon = PetUtil.getPetHeadIconByItid(p_tidNum, p_tidNum, nil, kPetHeadIconTouchPriority)
	petHeadIcon:setAnchorPoint(ccp(0,1))
	petHeadIcon:setPosition(25,_petBrownBgSpriteContentSize.height-25)
	topPetDescBgSprite:addChild(petHeadIcon)

	-- 宠物名称
	require "script/ui/pet/description/PetDescriptionData"
	local nameString = PetDescriptionData.getValueByKeyForId(p_tidNum,"roleName")
	local nameLabel = CCRenderLabel:create(nameString, g_sFontPangWa, kPetHeadIconNameFontSize, 1, ccc3(0x00,0x00,0x00), type_shadow)
	local quality = PetDescriptionData.getValueByKeyForId(p_tidNum,"quality")
	require "script/ui/hero/HeroPublicLua"
	local fontColor = HeroPublicLua.getCCColorByStarLevel(quality)
	nameLabel:setColor(fontColor)
	nameLabel:setAnchorPoint(ccp(0,0))
	nameLabel:setPosition(135,_petBrownBgSpriteContentSize.height-54)
	topPetDescBgSprite:addChild(nameLabel)

	-- 宠物描述
	local descString = PetDescriptionData.getValueByKeyForId(p_tidNum,"des")
	if descString == nil then descString = "" end
	--local descLabel = CCRenderLabel:create(descString, g_sFontName, kPetDescFontSize, 1, ccc3(0x00,0x00,0x00), type_shadow)
	local descLabel = CCLabelTTF:create(descString, g_sFontName, kPetDescFontSize)
	descLabel:setColor(ccc3(0xff,0xff,0xff))
	descLabel:setDimensions(_topDescLabelDimensions)
	descLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
	descLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
	descLabel:setAnchorPoint(ccp(0,1))
	descLabel:setPosition(147,_petBrownBgSpriteContentSize.height-64)
	topPetDescBgSprite:addChild(descLabel)

	-- 中部横线
	local middleLine = CCScale9Sprite:create("images/common/line02.png")
	middleLine:setPreferredSize(CCSizeMake(376,4))
	middleLine:setAnchorPoint(ccp(0.5,0.5))
	middleLine:setPosition(_petBrownBgSpriteContentSize.width/2,_petBrownBgSpriteContentSize.height-85-_topDescLabelDimensions.height)
	topPetDescBgSprite:addChild(middleLine)

	-- 获得方法label
	local tipTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("zz_12"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
	tipTitleLabel:setColor(ccc3(0xff,0xf6,0x00))
	tipTitleLabel:setAnchorPoint(ccp(0,0))
	tipTitleLabel:setPosition(37,_petBrownBgSpriteContentSize.height-125-_topDescLabelDimensions.height)
	topPetDescBgSprite:addChild(tipTitleLabel)

	-- 宠物获得途径描述
	require "script/ui/pet/description/PetDescriptionData"
	local tipInfoString = PetDescriptionData.getTipString(p_tidNum)
	--local tipInfoLabel = CCRenderLabel:create(tipInfoString, g_sFontName, kPetTipFontSize, 1, ccc3(0x00,0x00,0x00), type_shadow)
	local tipInfoLabel = CCLabelTTF:create(tipInfoString, g_sFontName, kPetTipFontSize)
	tipInfoLabel:setColor(ccc3(0xff,0xff,0xff))
	tipInfoLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
	tipInfoLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
	tipInfoLabel:setDimensions(_bottomTipLabelDimensions)
	tipInfoLabel:setAnchorPoint(ccp(0,1))
	tipInfoLabel:setPosition(37, _petBrownBgSpriteContentSize.height-135-_topDescLabelDimensions.height)
	topPetDescBgSprite:addChild(tipInfoLabel)

	-- 关闭按钮
	local closeMenu = CCMenu:create()
	closeMenu:setPosition(0,0)
	closeMenu:setTouchPriority(KCloseBtnTouchPriority)
	_petTipPanelBgSprite:addChild(closeMenu)
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:registerScriptTapHandler(closeBtnTapCb)
	closeBtn:setAnchorPoint(ccp(1,1))
	closeBtn:setPosition(_tipPanelBgSpriteContentSize.width*1.03, _tipPanelBgSpriteContentSize.height*1.03)
	closeMenu:addChild(closeBtn)
end

--[[
	@des:		显示屏蔽层及其内容
	@param:		p_tidNum 宠物模版id
	@return:	none
--]]
function showLayer(p_tidNum)
	init()
	load(p_tidNum)
	createLayer(p_tidNum)

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_darkShieldLayer, kDarkLayerZOrder)
end

--[[
	@des:		屏蔽层创建和退出事件回调函数
	@param:		事件类型
	@return:	none
--]]
function onNodeEvent(p_eventType)
	--触摸事件回调
	local function onTouchEvent(p_eventType, p_x, p_y)
		if p_eventType == "began" then
			return true
		end
	end

	--"enter": 被创建事件 "exit": 退出事件
	if p_eventType == "enter" then
		_darkShieldLayer:registerScriptTouchHandler(onTouchEvent, false, kDarkLayerTouchPriority, true)
		_darkShieldLayer:setTouchEnabled(true)
	elseif p_eventType == "exit" then
		_darkShieldLayer:unregisterScriptTouchHandler()
	else
	end
end

--[[
	@des:		右上角关闭按钮点击回调
	@param:		p_tagNum 被点击对象tag
				p_itemObj 被点击对象
	@return:	none
--]]
function closeBtnTapCb(p_tagNum, p_itemObj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_darkShieldLayer:removeFromParentAndCleanup(true)
	_darkShieldLayer = nil
end