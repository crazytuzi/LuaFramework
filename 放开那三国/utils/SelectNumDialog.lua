--Filename:SelectNumDialog.lua
--Author：lichenyang
--Date：2015-04-21
--Purpose:图片数字类

SelectNumDialog = class("SelectNumDialog", function ()
	local bgSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	bgSprite:setContentSize(CCSizeMake(610, 490))
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccps(0.5, 0.5))
	bgSprite:setScale(g_fScaleX)
	return bgSprite
end)

local kConfirmTag 		= 1001
local kCancelTag		= 1002
local kAddOneTag		= 10001
local kAddTenTag 		= 10002
local kSubOneTag		= 10003
local kSubTenTag		= 10004

function SelectNumDialog:ctor()
	self._imgDir = nil
	self._str = "0"
	self._bgLayer = nil
	self._okCallback = nil
	self._cancelCallback = nil
	self._changeMenu = nil
	self._menuBar = nil
	self._touchPrority = -750
	self._selectNum = 1
	self._limitNum = 100
	self._titleLabel = nil
	self._changeCallback = nil
	self._minNum = 1
end

--[[
	@des:显示对话框
	@parm:p_touchPrority 	优先级
	@parm:p_zOrder 			zOrder
--]]
function SelectNumDialog:show(p_touchPrority, p_zOrder)
	p_touchPrority = p_touchPrority or -750
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	self:setPriority(p_touchPrority)
	runningScene:addChild(self, p_zOrder)
end

--[[
	@des:创建对话框
--]]
function SelectNumDialog:create()
	local instance = SelectNumDialog:new()
	instance:initBg()
	instance:initDialog()
	instance:initInnerBg()
	return instance
end

--[[
	@des:初始化对话框
--]]
function SelectNumDialog:initBg( ... )
	self._bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 100))
	self._bgLayer:setPosition(ccpsprite(0.5, 0.5, self))
	self._bgLayer:setAnchorPoint(ccp(0.5, 0.5))
	self._bgLayer:setTouchEnabled(true)
	self._bgLayer:ignoreAnchorPointForPosition(false)
	self:addChild(self._bgLayer, -1)
end

function SelectNumDialog:initDialog()
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
		-- 播放关闭音效
		require "script/audio/AudioUtil"
    	AudioUtil.playEffect("audio/effect/guanbi.mp3")
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
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
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
		-- 播放关闭音效
		require "script/audio/AudioUtil"
	    AudioUtil.playEffect("audio/effect/guanbi.mp3")
		--取消按钮回调
		if self._cancelCallback then
			self._cancelCallback()
		end
		self:removeFromParentAndCleanup(true)
		self = nil
	end)
	self._menuBar:addChild(cancelBtn, 1, kCancelTag)
end

function SelectNumDialog:initInnerBg()
	-- 背景2
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560, 330))
	innerBgSp:setAnchorPoint(ccp(0.5, 0))
	innerBgSp:setPosition(ccp(self:getContentSize().width*0.5, 110))
	self:addChild(innerBgSp)

	local innerSize = innerBgSp:getContentSize()

    -- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170, 65))
	numberBg:setAnchorPoint(ccp(0.5, 0))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width*0.5, 110))
	innerBgSp:addChild(numberBg)
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
	innerBgSp:addChild(self._changeMenu)

	-- 改变兑换数量
	local changeNumberAction = function ( tag, itemBtn )
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		if(tag == kSubTenTag) then
			-- -10
			self._selectNum = self._selectNum - 10
		elseif(tag == kSubOneTag) then
			-- -1
			self._selectNum = self._selectNum - 1 
		elseif(tag == kAddOneTag) then
			-- +1
			self._selectNum = self._selectNum + 1 
		elseif(tag == kAddTenTag) then
			-- +10
			self._selectNum = self._selectNum + 10 
		end
		if(self._selectNum < self._minNum)then
			self._selectNum = self._minNum
		end
		-- 上限	
		if(self._selectNum > self._limitNum)then
			self._selectNum = self._limitNum
		end
		-- 个数
		self._numberLabel:setString(self._selectNum)
    	self._numberLabel:setPosition(ccpsprite(0.5, 0.5,numberBg))
		if self._changeCallback then
			self._changeCallback(self._selectNum)
		end
	end
	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(reduce10Btn, 1, kSubTenTag)
	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(reduce1Btn, 1, kSubOneTag)
	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(reduce1Btn, 1, kAddOneTag)
	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(445, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	self._changeMenu:addChild(reduce10Btn, 1, kAddTenTag)
end

--[[
	@des:设置标题
	@parm: pTitleText 标题
--]]
function SelectNumDialog:setTitle( pTitleText )
	self._titleLabel:setString(pTitleText)
end

--[[
	@des:得到选择数
	@ret: num 选择数
--]]
function SelectNumDialog:getNum( ... )
	return self._selectNum
end

--[[
	@des: 设置选择数
	@parm: pNum 选择数
--]]
function SelectNumDialog:setNum( pNum )
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
function SelectNumDialog:setMinNum( pNum )
	self._minNum = pNum
	self:setNum(pNum)
end

--[[
	@des: 设置最大选择数
	@parm: pNum 选择数
--]]
function SelectNumDialog:setLimitNum( pNum )
	self._limitNum = pNum
end

--[[
	@des: 设置优先级 
	@parm: pTouchPrority 优先级
--]]
function SelectNumDialog:setPriority( pTouchPrority )
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
function SelectNumDialog:registerChangeCallback( p_callback )
	self._changeCallback = p_callback
end

--[[
	@des: 确定按钮回调
	@parm: p_callback 回调
--]]
function SelectNumDialog:registerOkCallback( p_callback )
	self._okCallback = p_callback
end

--[[
	@des: 取消按钮回调
	@parm: p_callback 回调
--]]
function SelectNumDialog:registerCancelCallback( p_callback )
	self._cancelCallback = p_callback
end




