return { new = function(src)
local Mnode = require "src/young/node"
local Minteger = require "src/young/component/number/model"
------------------------------------------------------------------------------------
-- 设置默认值
if type(src) ~= "string" then src = "res/component/number/1.png" end
------------------------------------------------------------------------------------
local Myoung = require "src/young/young"; local M = Myoung.beginFunction()
------------------------------------------------------------------------------------
local numbersTexture = TextureCache:addImage(src)
local csize = numbersTexture:getContentSize()
mNumberW = csize.width/10
mNumberH = csize.height

local buildNumberSprite = function(self, number)
	local rect = cc.rect(self.mNumberW * number, 0, self.mNumberW, self.mNumberH)
	local spriteFrame = cc.SpriteFrame:createWithTexture(numbersTexture, rect)
	return Mnode.createSprite( { src = spriteFrame, } )
end

create = function(self, number, margin)
	-- 设置默认值
	if type(number) ~= "number" then number = 0 end
	if type(margin) ~= "number" then margin = 0 end
	
	local content = cc.Node:create()
	local i = 0
	for _, v in Minteger.new(number) do
		Mnode.addChild({
			parent = content,
			child = buildNumberSprite(self, v),
			anchor = cc.p(0, 0),
			pos = cc.p((self.mNumberW + margin) * i, 0),
		})
		i = i + 1
	end
	content:setContentSize( cc.size((self.mNumberW * i + margin * math.max(i - 1, 0)), self.mNumberH) )
	
	return content
end
------------------------------------------------------------------------------------
return M

end }