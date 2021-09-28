return { new = function(params)
----------------------------------------------------------------
local Mnode = require "src/young/node"
local MColor = require "src/config/FontColor"
local MMenuButton = require "src/component/button/MenuButton"
----------------------------------------------------------------
params = type(params) ~= "table" and {} or params

local src = params.src

local close = params.close or {}

local title = params.title
----------------------------------------------------------------
-- 底板
local root = nil
----------------------------------------------------------------

if src == "res/common/2.jpg" then
	root,closebtn = createBgSprite(params.parent,title,nil,params.quick)
	root.closeBtn = closebtn
else
	root = type(src) == "string" and Mnode.createSprite({ src = src }) or src
	-- 关闭按钮
	local closeBtn = MMenuButton.new(
	{
		src = close.src or "res/component/button/X.png",
		zOrder = 99,
		effect = "none",
		cb = close.handler and function()
			close.handler(root)
		end or function()
			if root then
				removeFromParent(root)
				root = nil
			end
		end,
	})
	Mnode.overlayNode(
	{
		parent = root,
		{
			node = closeBtn,
			origin = close.origin or "rt",
			offset = close.offset,
			scale = close.scale,
			zOrder = close.zOrder,
		}
	})
	-- 标题
	if title then
		Mnode.overlayNode(
		{
			parent = root,
			{
				node = type(title) == "table" and Mnode.createLabel(title) or title,
				origin = title.origin or "tc",
				offset = title.offset or { y = -30 },
			}
		})
	end
	root.closeBtn = closeBtn
end
----------------------------------------------------------------
return root

end }

