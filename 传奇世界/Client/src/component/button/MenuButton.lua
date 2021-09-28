return { new = function(params)
------------------------------------------------------------------------------------
local Mnode = require "src/young/node"
------------------------------------------------------------------------------------
-- 设置参数默认值
params = type(params) ~= "table" and {} or params

-- 按钮背景图片
local src = params.src
local nodefaultMus = params.nodefaultMus or false
local noInsane = params.noInsane
if noInsane ~= nil and type(noInsane) ~= "number" then noInsane = 0.2 end
------------------------------------------------------------------------------------
local effect = params.effect or "s2b"

local arg1, arg2, arg3 = nil, nil, nil
if type(src) == "table" then
	arg1 = src[1]
	arg2 = src[2]
	arg3 = src[3]
else
	arg1 = src
end

local button = MenuButton:create(arg1, arg2, arg3)

if effect == "b2s" then
	button:setSmallToBigMode(false)
elseif effect == "none" then
	button:setSelectAction(cc.DelayTime:create(0.0))
end

local M = Mnode.beginNode(button)

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

-- !!! 对button(menuItem)不要用registerScriptHandler函数，否则有行为异常
local insane_flag = false
button:registerScriptTapHandler(function(tag, node)
	if not nodefaultMus then
		AudioEnginer.playTouchPointEffect()
	end
	
	-- 处理疯狂按的问题
	if noInsane then
		if insane_flag then
			TIPS({ type = 1  , str = "操作频繁" })
			return
		end
		
		insane_flag = true
		local DelayTime = cc.DelayTime:create(noInsane)
		local CallFunc = cc.CallFunc:create(function(node)
			insane_flag = false
		end)
		
		local Sequence = cc.Sequence:create(DelayTime, CallFunc)
		menu:runAction(Sequence) -- 不知道为什么用 node:runAction(Sequence) 会失灵
	end
	
	cb(tag, node)
end)
callback = function(self, cb)
	if type(cb) == "function" and self.mCallback ~= cb then
		self.mCallback = cb
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