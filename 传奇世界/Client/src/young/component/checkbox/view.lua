return { new = function(params)

local Mnode = require "src/young/node"
------------------------------------------------------------------------------------
local res = "res/component/checkbox/"
-- 设置默认值
params = type(params) ~= "table" and {} or params

local check = type(params.check) ~= "string" and (res .. "2.png") or params.check
local box = type(params.box) ~= "string" and (res .. "1.png") or params.box
local label = type(params.label) ~= "table" and { src = "请设置标签", } or params.label
local margin = type(params.margin) ~= "number" and 15 or params.margin
------------------------------------------------------------------------------------
local root = cc.Node:create(); local M = Mnode.beginNode(root)
------------------------------------------------------------------------------------
mValue = params.value
mCb = type(params.cb) ~= "function" and function() end or params.cb

local check = cc.Sprite:create(check)
local box = cc.Sprite:create(box)
local boxSize = box:getContentSize()

check:setPosition(boxSize.width/2, boxSize.height/2)
box:addChild(check)
check:setVisible(value)

Mnode.listenTouchEvent({
	node = box,
	
	swallow = false,
	
	begin = function(touch)
		return Mnode.isTouchInNodeAABB(box, touch)
	end,
	
	ended = function(touch)
		if not Mnode.isTouchInNodeAABB(box, touch) then return end
		local newValue = not root.mValue
		root.mValue = newValue
		if tolua.cast(check,"cc.Sprite") then
			check:setVisible(newValue)
		end
		root.mCb(newValue)
	end,
})

Mnode.combineNode({
	root = root,
	nodes = { box, Mnode.createLabel(label), },
	margins = margin,
})

value = function(self)
	return self.mValue
end

------------------------------------------------------------------------------------
return root

end }