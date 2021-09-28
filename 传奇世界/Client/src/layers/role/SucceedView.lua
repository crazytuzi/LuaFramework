return { new = function(title)
-----------------------------------------------------------------------
local Mbaseboard = require "src/functional/baseboard"
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = res .. "62.png",
	close = {
		scale = 0.8,
		offset = { x = 15, y = 15 },
	},
})

local effect = cc.Sprite:create(res .. "light.png")
local rotate = cc.RotateBy:create(0.1, 6)
local forever = cc.RepeatForever:create(rotate)
effect:runAction(forever)

-- 加上标题
Mnode.overlayNode(
{
	parent = root,
	{
		node = Mnode.overlayNode(
		{
			parent = cc.Sprite:create(res .. "63.png"),
			{
				node = Mnode.overlayNode(
				{
					parent = cc.Sprite:create(title),
					{
						node = effect,
						zOrder = -1,
					}
				}),
			}
		}),
		
		origin = "t",
		offset = { y = 25 },
	}
})
-----------------------------------------------------------------------
return root
end }