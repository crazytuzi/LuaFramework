-- FileName: BigNumberSelectDialog.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]
require "script/ui/tip/AnimationTip"
BigNumberSelectDialog = class("BigNumberSelectDialog", function ()
	local bgSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	bgSprite:setContentSize(CCSizeMake(610, 590))
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccps(0.5, 0.5))
	bgSprite:setScale(g_fScaleX)
	return bgSprite
end)

local kAnd1Tag    = 100
local kAnd10Tag   = 101
local kAnd100Tag  = 102
local kSub1Tag    = 200
local kSub10Tag   = 201
local kSub100Tag  = 202
local kConfirmTag = 1001
local kCancelTag  = 1002


function BigNumberSelectDialog:ctor()
	self._imgDir = nil
	self._str = "0"
	self._bgLayer = nil
	self._okCallback = nil
	self._cancelCallback = nil
	self._changeMenu = nil
	self._menuBar = nil
	self._touchPrority = -512
	self._selectNum = 1
	self._limitNum = 10000
	self._titleLabel = nil
	self._changeCallback = nil
	self._minNum = 1
end

--[[
	@des:显示对话框
	@parm:p_touchPrority 	优先级
	@parm:p_zOrder 			zOrder
--]]
function BigNumberSelectDialog:show(p_touchPrority, p_zOrder)
	self._touchPrority = p_touchPrority or -499
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	self:setPriority(self._touchPrority)
	runningScene:addChild(self, p_zOrder)
end
--[[
	@des:创建对话框
--]]
function BigNumberSelectDialog:create(pWidth, pHeight)
	local tempWidth = pWidth or 610
	local tempHeight = pHeight or 590
	local instance = BigNumberSelectDialog:new(tempWidth, tempHeight)
	instance:setContentSize(CCSizeMake(tempWidth, tempHeight))
	instance._width = tempWidth
	instance._height = tempHeight
	instance:initBg()
	instance:initDialog()
	instance:initInnerBg()
	return instance
end

--[[14
	@des:初始化对话框
--]]
function BigNumberSelectDialog:initBg( ... )
	self._bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 100))
	self._bgLayer:setPosition(ccpsprite(0.5, 0.5, self))
	self._bgLayer:setAnchorPoint(ccp(0.5, 0.5))
	self._bgLayer:setTouchEnabled(true)
	self._bgLayer:ignoreAnchorPointForPosition(false)
	self:addChild(self._bgLayer, -1)
end

function BigNumberSelectDialog:initDialog()
	-- 背景
	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(self:getContentSize().width/2, self:getContentSize().height*0.985))
	self:addChild(titleSp)
	self._titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1910"), g_sFontPangWa, 30)
	self._titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	self._titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	self._titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(self._titleLabel)

	-- 关闭按钮bar
	self._menuBar = CCMenu:create()
	self._menuBar:setPosition(ccp(0,0))
	self._menuBar:setTouchPriority(self._touchPrority - 10)
	self:addChild(self._menuBar)
	-- 关闭按钮
	local closeAction = function ( ... )
		--取消按钮回调
		if self._cancelCallback then
			self._cancelCallback()
		end
		self:removeFromParentAndCleanup(true)
		self = nil
	end
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(self:getContentSize().width*0.97, self:getContentSize().height*0.98))
	self._menuBar:addChild(closeBtn)

	-- 按钮
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	comfirmBtn:setAnchorPoint(ccp(0, 0))
	comfirmBtn:setPosition(ccp(125, 35	))
	comfirmBtn:registerScriptTapHandler(function ( ... )
		--确定按钮回调
		if self._okCallback then
			self._okCallback()
		end
		self:removeFromParentAndCleanup(true)
		self = nil
	end)
	self._menuBar:addChild(comfirmBtn, 1, kConfirmTag)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0, 0))
	cancelBtn:setPosition(ccp(350, 35))
	cancelBtn:registerScriptTapHandler(function ( ... )
		--取消按钮回调
		if self._cancelCallback then
			self._cancelCallback()
		end
		self:removeFromParentAndCleanup(true)
		self = nil
	end)
	self._menuBar:addChild(cancelBtn, 1, kCancelTag)
end

function BigNumberSelectDialog:initInnerBg()
	-- 背景2
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(self._width - 50, self._height - 190))
	innerBgSp:setAnchorPoint(ccp(0.5, 0))
	innerBgSp:setPosition(ccp(self:getContentSize().width*0.5, 110))
	self:addChild(innerBgSp)

	local contentNode = CCSprite:create()
	contentNode:setContentSize(CCSizeMake(560, 400))
	contentNode:setAnchorPoint(ccp(0.5, 0.5))
	contentNode:setPosition(ccpsprite(0.5, 0.5, innerBgSp))
	innerBgSp:addChild(contentNode)

	local innerSize = contentNode:getContentSize()

    -- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170, 65))
	numberBg:setAnchorPoint(ccp(0.5, 0))
	numberBg:setPosition(ccp(contentNode:getContentSize().width*0.5, 250))
	contentNode:addChild(numberBg)
	-- 数量数字CCLabelTTF:create(self._selectNum, g_sFontPangWa, 36) 
	self._numberLabel = CCRenderLabel:create(self._selectNum, g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    self._numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    self._numberLabel:setPosition(ccpsprite(0.5, 0.5,numberBg))
    self._numberLabel:setAnchorPoint(ccp(0.5, 0.5))
    numberBg:addChild(self._numberLabel, 10)
    
	-- 加减道具的按钮
	self._changeMenu = CCMenu:create()
	self._changeMenu:setPosition(ccp(0,0))
	self._changeMenu:setTouchPriority(self._touchPrority - 10)
	contentNode:addChild(self._changeMenu)

	-- 改变兑换数量
	local changeNumberAction = function ( tag, itemBtn )
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		if(tag == kSub1Tag) then
			-- -10
			self._selectNum = self._selectNum - 1
		elseif(tag == kSub10Tag) then
			-- -1
			self._selectNum = self._selectNum - 10
		elseif(tag == kSub100Tag) then
			-- -1
			self._selectNum = self._selectNum - 100
		elseif(tag == kAnd1Tag) then
			-- +1
			self._selectNum = self._selectNum + 1 
		elseif(tag == kAnd10Tag) then
			-- +1
			self._selectNum = self._selectNum + 10
		elseif(tag == kAnd100Tag) then
			-- +1
			self._selectNum = self._selectNum + 100
		end
		if(self._selectNum < self._minNum)then
			self._selectNum = self._minNum
		end
		-- 上限	
		if(self._selectNum > self._limitNum)then
			AnimationTip.showTip(GetLocalizeStringBy("key_1703"))
			self._selectNum = self._limitNum
		end
		-- 个数
		self._numberLabel:setString(self._selectNum)
    	self._numberLabel:setPosition(ccpsprite(0.5, 0.5,numberBg))
		if self._changeCallback then
			self._changeCallback(self._selectNum)
		end
	end
	-- +1
	local add1Btn = CCMenuItemImage:create("images/common/btn/anniu_red_btn_n.png", "images/common/btn/anniu_red_btn_h.png")
	add1Btn:setPosition(ccpsprite(0.2, 0.45, contentNode))
	add1Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(add1Btn, 1, kAnd1Tag)
	add1Btn:setAnchorPoint(ccp(0.5, 0.5))
	local add1Label =CCRenderLabel:create("+1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    add1Label:setColor(ccc3(0xfe, 0xdb, 0xec))
    add1Label:setPosition(ccpsprite(0.5, 0.5,add1Btn))
    add1Label:setAnchorPoint(ccp(0.5, 0.5))
    add1Btn:addChild(add1Label, 10)

    -- +10
	local add10Btn = CCMenuItemImage:create("images/common/btn/anniu_red_btn_n.png", "images/common/btn/anniu_red_btn_h.png")
	add10Btn:setPosition(ccpsprite(0.5, 0.45, contentNode))
	add10Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(add10Btn, 1, kAnd10Tag)
	add10Btn:setAnchorPoint(ccp(0.5, 0.5))
	local add10Label =CCRenderLabel:create("+10", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    add10Label:setColor(ccc3(0xfe, 0xdb, 0xec))
    add10Label:setPosition(ccpsprite(0.5, 0.5,add10Btn))
    add10Label:setAnchorPoint(ccp(0.5, 0.5))
    add10Btn:addChild(add10Label, 10)

    -- +100
	local add100Btn = CCMenuItemImage:create("images/common/btn/anniu_red_btn_n.png", "images/common/btn/anniu_red_btn_h.png")
	add100Btn:setPosition(ccpsprite(0.8, 0.45, contentNode))
	add100Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(add100Btn, 1, kAnd100Tag)
	add100Btn:setAnchorPoint(ccp(0.5, 0.5))
	local add100Label =CCRenderLabel:create("+100", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    add100Label:setColor(ccc3(0xfe, 0xdb, 0xec))
    add100Label:setPosition(ccpsprite(0.5, 0.5,add100Btn))
    add100Label:setAnchorPoint(ccp(0.5, 0.5))
    add100Btn:addChild(add100Label, 10)

    -- -1
	local sub1Btn = CCMenuItemImage:create("images/common/btn/anniu_blue_btn_n.png", "images/common/btn/anniu_blue_btn_h.png")
	sub1Btn:setPosition(ccpsprite(0.2, 0.2, contentNode))
	sub1Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(sub1Btn, 1, kSub1Tag)
	sub1Btn:setAnchorPoint(ccp(0.5, 0.5))
	local sub1Label =CCRenderLabel:create("-1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    sub1Label:setColor(ccc3(0xfe, 0xdb, 0xec))
    sub1Label:setPosition(ccpsprite(0.5, 0.5,sub1Btn))
    sub1Label:setAnchorPoint(ccp(0.5, 0.5))
    sub1Btn:addChild(sub1Label, 10)

    -- -10
	local sub10Btn = CCMenuItemImage:create("images/common/btn/anniu_blue_btn_n.png", "images/common/btn/anniu_blue_btn_h.png")
	sub10Btn:setPosition(ccpsprite(0.5, 0.2, contentNode))
	sub10Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(sub10Btn, 1, kSub10Tag)
	sub10Btn:setAnchorPoint(ccp(0.5, 0.5))
	local sub10Label =CCRenderLabel:create("-10", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    sub10Label:setColor(ccc3(0xfe, 0xdb, 0xec))
    sub10Label:setPosition(ccpsprite(0.5, 0.5,sub10Btn))
    sub10Label:setAnchorPoint(ccp(0.5, 0.5))
    sub10Btn:addChild(sub10Label, 10)

    -- -100
	local sub100Btn = CCMenuItemImage:create("images/common/btn/anniu_blue_btn_n.png", "images/common/btn/anniu_blue_btn_h.png")
	sub100Btn:setPosition(ccpsprite(0.8, 0.2, contentNode))
	sub100Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(sub100Btn, 1, kSub100Tag)
	sub100Btn:setAnchorPoint(ccp(0.5, 0.5))
	local sub00Label =CCRenderLabel:create("-100", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    sub00Label:setColor(ccc3(0xfe, 0xdb, 0xec))
    sub00Label:setPosition(ccpsprite(0.5, 0.5,sub100Btn))
    sub00Label:setAnchorPoint(ccp(0.5, 0.5))
    sub100Btn:addChild(sub00Label, 10)
end

--[[
	@des:设置标题
	@parm: pTitleText 标题
--]]
function BigNumberSelectDialog:setTitle( pTitleText )
	self._titleLabel:setString(pTitleText)
end

--[[
	@des:得到选择数
	@ret: num 选择数
--]]
function BigNumberSelectDialog:getNum( ... )
	return self._selectNum
end

--[[
	@des: 设置选择数
	@parm: pNum 选择数
--]]
function BigNumberSelectDialog:setNum( pNum )
	local num = 0
	if pNum > self._limitNum then
		num = self._limitNum
	elseif pNum <self._minNum then
		num = self._minNum
	else
		num = pNum
	end
	self._selectNum = num
	self._numberLabel:setString(self._selectNum)
	self._numberLabel:setAnchorPoint(ccp(0.5,0.5))
	self._numberLabel:setPosition(ccpsprite(0.5, 0.5,self._numberLabel:getParent()))
end

--[[
	@des:设置最小值	
	@parm:pNum 最小值
--]]
function BigNumberSelectDialog:setMinNum( pNum )
	self._minNum = pNum
	self:setNum(pNum)
end

--[[
	@des: 设置最大选择数
	@parm: pNum 选择数
--]]
function BigNumberSelectDialog:setLimitNum( pNum )
	self._limitNum = pNum
end

--[[
	@des: 设置优先级
	@parm: pTouchPrority 优先级
--]]
function BigNumberSelectDialog:setPriority( pTouchPrority )
	self._touchPrority = pTouchPrority
	print(tolua.type())

	self._bgLayer:setTouchPriority(self._touchPrority)
	self._menuBar:setTouchPriority(self._touchPrority - 10)
	self._changeMenu:setTouchPriority(self._touchPrority - 10)
	self._bgLayer:registerScriptTouchHandler(function ( eventType,x,y )
		if(eventType == "began") then
			return true
		end
		print(eventType)
	end,false, self._touchPrority, true)
end

--[[
	@des: 注册选择变更回调
	@parm: p_callback 回调
--]]
function BigNumberSelectDialog:registerChangeCallback( p_callback )
	self._changeCallback = p_callback
end

--[[
	@des: 确定按钮回调
	@parm: p_callback 回调
--]]
function BigNumberSelectDialog:registerOkCallback( p_callback )
	self._okCallback = p_callback
end

--[[
	@des: 取消按钮回调
	@parm: p_callback 回调
--]]
function BigNumberSelectDialog:registerCancelCallback( p_callback )
	self._cancelCallback = p_callback
end
