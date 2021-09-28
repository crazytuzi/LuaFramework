return { new = function(params)
------------------------------------------------------------------------------------
local Mnode = require "src/young/node"
------------------------------------------------------------------------------------
-- 设置参数默认值
params = type(params) ~= "table" and {} or params

-- 按钮背景图片
local src = type(params.src) ~= "string" and "res/component/button/1.png" or params.src
------------------------------------------------------------------------------------
local button = MenuButton:create(src); local M = Mnode.beginNode(button)
local csize = button:getContentSize()
------------------------------------------------------------------------------------
local menu = cc.Menu:create()
menu:setContentSize(csize)

Mnode.addChild(
{
	parent = menu,
	child = button,
	pos = cc.p(csize.width/2, csize.height/2),
	tag = params.tab,
})

menu.mButton = button

menu.getButton = function(menu)
	return menu.mButton
end

if params.b2s then button:setSmallToBigMode(false) end
------------------------------------------------------------------------------------
-- 按钮标签
setLabel = function(self, label)
	local size = self:getContentSize()
	local center = cc.p(size.width/2, size.height/2)
	
	if self:getChildByTag(9) then self:removeChildByTag(9) end
	
	-- 标签是图片
	if type(label) == "string" then
		Mnode.createSprite(
		{
			src = label,
			parent = self,
			pos = center,
			tag = 9,
		})
	-- 标签是文本
	elseif type(label) == "table" then
		label.parent = self
		label.pos = center
		label.tag = require("src/config/CommDef").TAG_LABEL_IN_MENU_BUTTON
		Mnode.createLabel(label)
	end
end; button:setLabel(params.label)

-- 点击事件的回调函数
local cb = type(params.cb) ~= "function" and function() end or params.cb
callback = function(self, cb)
	if type(cb) == "function" and self.mCallback ~= cb then
		self.mCallback = cb
		self:unregisterScriptTapHandler()
		self:registerScriptTapHandler(cb)
	else
		return self.mCallback
	end
end; button:callback(cb)
------------------------------------------------------------------------------------
params.child = menu
Mnode.addChild(params)
------------------------------------------------------------------------------------
return menu, button

end }