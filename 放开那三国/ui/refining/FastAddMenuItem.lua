-- Filename：	FastAddMenuItem.lua
-- Author：		zhang zihang
-- Date：		2015-4-27
-- Purpose：		炼化的批量添加按钮

FastAddMenuItem = class("FastAddMenuItem")

--[[
	@des 	:构造函数
--]]
function FastAddMenuItem:ctor()
	self.baseMenuItem = nil
	self.changeMenuItem = nil
	self.baseHeadSprite = nil
	self.changeHeadSprite = nil
	self.btnSize = nil
end

--[[
	@des 	:创建按钮
	@param  :按钮名字string,p_size：按钮尺寸
	@param  :头像路径
--]]
function FastAddMenuItem:createMenuItem(p_nameString,p_headImgPath,p_size)
	p_size = p_size or CCSizeMake(210,73)
	self.baseMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",p_size,p_nameString,ccc3(0xfe,0xdb,0x1c),29,g_sFontPangWa,1,ccc3(0x00,0x00,0x00),ccp(-20,0))
	self.changeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",p_size,GetLocalizeStringBy("key_2699"),ccc3(0xfe,0xdb,0x1c),29,g_sFontPangWa,1,ccc3(0x00,0x00,0x00),ccp(-20,0))
	--按钮大小
	self.btnSize = self.baseMenuItem:getContentSize()
	--添加底层按钮头像
	self.baseHeadSprite = CCSprite:create(p_headImgPath)
	self.baseHeadSprite:setAnchorPoint(ccp(1,0.5))
	self.baseHeadSprite:setPosition(ccp(self.btnSize.width - 25,self.btnSize.height*0.5))
	self.baseMenuItem:addChild(self.baseHeadSprite)
	--添加改变按钮头像
	self.changeHeadSprite = CCSprite:create(p_headImgPath)
	self.changeHeadSprite:setAnchorPoint(ccp(1,0.5))
	self.changeHeadSprite:setPosition(ccp(self.btnSize.width - 25,self.btnSize.height*0.5))
	self.changeMenuItem:addChild(self.changeHeadSprite)
end

--[[
	@des 	:给按钮注册回调
	@param  :回调
--]]
function FastAddMenuItem:registCallBack(p_callBack)
	self.baseMenuItem:registerScriptTapHandler(p_callBack)
	self.changeMenuItem:registerScriptTapHandler(p_callBack)
end

--[[
	@des 	:设置锚点，位置，缩放
	@param  :锚点
	@param  :位置
	@param  :缩放
--]]
function FastAddMenuItem:setAnchorPosScale(p_anchorPoint,p_position,p_scale)
	self.baseMenuItem:setAnchorPoint(p_anchorPoint)
	self.baseMenuItem:setPosition(p_position)
	self.baseMenuItem:setScale(p_scale)

	self.changeMenuItem:setAnchorPoint(p_anchorPoint)
	self.changeMenuItem:setPosition(p_position)
	self.changeMenuItem:setScale(p_scale)
end

--[[
	@des 	:向按钮层上添加
	@param  :按钮层
	@param  :tag值
--]]
function FastAddMenuItem:addChildToMenu(p_menu,p_tag)
	p_menu:addChild(self.baseMenuItem,1,p_tag)
	p_menu:addChild(self.changeMenuItem,1,p_tag)
end

--[[
	@des 	:设置主按钮是否可见
	@param  :是否可见
--]]
function FastAddMenuItem:setBaseVisible(p_visible)
	self.baseMenuItem:setVisible(p_visible)
	self.changeMenuItem:setVisible(not p_visible)
end

--[[
	@des 	:设置是否可点击
	@param  :是否可点击
--]]
function FastAddMenuItem:setMenuEnable(p_enable)
	self.baseMenuItem:setEnabled(p_enable)
	self.changeMenuItem:setEnabled(p_enable)
end